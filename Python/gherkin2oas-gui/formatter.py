import re
import nlp
import sys

def generate_swagger(model):
    paths_object = {}
    definitions_object = {}
    security_definitions_object = {}
    empty = {'get':{'request_params':[],'response':{'params':[],'links':[]}},
        'post':{'request_params':[],'response':{'params':[],'links':[]}},
        'put':{'request_params':[],'response':{'params':[],'links':[]}},
        'delete':{'request_params':[],'response':{'params':[],'links':[]}}}
    path_hierarchy = {}
    roles = {}
    for resource,operations in model.items():
        path_hierarchy[resource] = model[resource].pop('resource_hierarchy')
        roles[resource] = model[resource].pop('resource_roles')
        # ---------------path seeds--------------------        
        collection_path = '/' + resource
        single_resource_path = ''
        paths_object[collection_path] = {}        
        # ---------------resource identifications--------------------
        for operation,op_model in operations.items():
            if op_model != empty[operation] and (operation != 'post'):
                param = list(flatten(op_model['request_params']))
                if param:
                    if (len(param) == 1 and param[0] in ['name','id']):
                        single_resource_path = collection_path + '/{' + resource + '_' + param[0] + '}'
                        if single_resource_path not in paths_object.keys():
                            paths_object[single_resource_path] = {}
                        if param[0] == 'name':
                            paths_object[single_resource_path][operation] = {'parameters':[{'name':resource + '_name','type':'string','in':'path','required':True}]}
                        else:
                            paths_object[single_resource_path][operation] = {'parameters':[{'name':resource + '_id','type':'integer','format':'int32','in':'path','required':True}]}
        for operation,op_model in operations.items():
            params = list(flatten(op_model['request_params']))
            if (op_model != empty[operation]) and (operation != 'post'):
                if len(params) <= 1:
                    if single_resource_path:
                        found_operations = list(paths_object[single_resource_path].keys())
                        if operation not in found_operations and found_operations[0]:
                            paths_object[single_resource_path][operation] = {'parameters':[]}
                            paths_object[single_resource_path][operation]['parameters'].extend(paths_object[single_resource_path][found_operations[0]]['parameters'])
                    else:
                        single_resource_path = collection_path + '/{' + resource + '_id}'
                        paths_object[single_resource_path][operation] = {'parameters':[{'name':resource + '_id','type':'integer','format':'int32','in':'path','required':True}]}
                else:
                    if (operation == 'get' or operation == 'delete'):
                        paths_object[collection_path][operation] = {'parameters':[]}                         
                        for param in params:
                            paths_object[collection_path][operation]['parameters'].append({'name':param[0],'type':'string','in':'query','description':param})
        for operation,op_model in operations.items():
            if op_model != empty[operation] and (operation == 'put'):
                params = list(flatten(op_model['request_params']))
                if len(params) > 1:
                    found_operations = list(paths_object[single_resource_path].keys())
                    if single_resource_path:
                        if 'put' not in found_operations and found_operations[0]: # found_operations[0] is a random choice between possible get/delete pair
                            paths_object[single_resource_path]['put'] = {'parameters':[]}
                            paths_object[single_resource_path]['put']['parameters'].extend(paths_object[single_resource_path][found_operations[0]]['parameters'])
                    else:
                        single_resource_path = collection_path + '/{' + resource + '_id}'
                        paths_object[single_resource_path]['put'] = {'parameters':[]}
                        paths_object[single_resource_path]['put']['parameters'].append({'name':resource + '_id','type':'integer','format':'int32','in':'path','required':True})        
        # ---------------bodies--------------------
                object_name = ''
                if op_model['request_params']:
                    object_name = resource + '_' + operation + '_request_body'
                    definitions_object[object_name] = {}
                    definitions_object[object_name]['type'] = 'object'
                    definitions_object[object_name]['properties'] = {}
                    paths_object[single_resource_path]['put']['parameters'].append({'name':object_name,'in':'body','schema':{'$ref':'#/definitions/' + object_name}})
                for param in op_model['request_params']:
                    if type(param) is list:
                        for domain_param in param:
                            if domain_param['type'] == 'file':
                                paths_object[single_resource_path]['put']['consumes'] = ["multipart/form-data","application/x-www-form-urlencoded"]
                                paths_object[single_resource_path]['put']['parameters'].clear() # cannot have body AND formData parameters at the same time   
                                paths_object[single_resource_path]['put']['parameters'].append({'name':domain_param['name'],'in':'formData','type':domain_param['type']}) 
                                break # no other parameters can co-exist with a file parameter
                            elif domain_param['type'] == 'array':
                                definitions_object[object_name]['properties'][domain_param['name']] = {'type':domain_param['type'],'items':domain_param['items']}
                            else:
                                definitions_object[object_name]['properties'][domain_param['name']] = {'type':domain_param['type']}  
                                if 'format' in domain_param:
                                    definitions_object[object_name]['properties'][domain_param['name']]['format'] = domain_param['format']                                 
                    else:
                        definitions_object[object_name]['properties'][param] = {'type':'string'}
            elif op_model != empty[operation] and operation == 'post':
                object_name = ''
                if op_model['request_params']:
                    paths_object[collection_path]['post'] = {'parameters':[]}
                    object_name = resource + '_' + operation + '_request_body'
                    definitions_object[object_name] = {}
                    definitions_object[object_name]['type'] = 'object'
                    definitions_object[object_name]['properties'] = {}
                    paths_object[collection_path]['post']['parameters'].append({'name':object_name,'in':'body','schema':{'$ref':'#/definitions/' + object_name}})
                else:
                    sys.exit('Resource ' + resource + ' missing body. Help: a post operation MUST have a body')
                for param in op_model['request_params']:
                    if type(param) is list:
                        for domain_param in param:
                            if domain_param['type'] == 'file':
                                paths_object[collection_path]['post']['consumes'] = ["multipart/form-data","application/x-www-form-urlencoded"]
                                paths_object[collection_path]['post']['parameters'].clear() # cannot have body AND formData parameters at the same time  
                                paths_object[collection_path]['post']['parameters'].append({'name':domain_param['name'],'in':'formData','type':domain_param['type']}) 
                                # no other parameters can co-exist with a file parameter
                            elif domain_param['type'] == 'array':
                                definitions_object[object_name]['properties'][domain_param['name']] = {'type':domain_param['type'],'items':domain_param['items']}
                            else:
                                definitions_object[object_name]['properties'][domain_param['name']] = {'type':domain_param['type']} 
                                if 'format' in domain_param:
                                    definitions_object[object_name]['properties'][domain_param['name']]['format'] = domain_param['format']                     
                    else:
                        definitions_object[object_name]['properties'][param] = {'type':'string'}
    # ---------------path hierarchies--------------------
    found_resource_paths = list(paths_object.keys())
    for resource,operations in model.items():
        if path_hierarchy[resource]:
            path_base = ''
            path = ''
            path_param = {}
            for found_resource_path in found_resource_paths:
                if re.search(path_hierarchy[resource] + '/{',found_resource_path):
                    path_base = found_resource_path
                    # if the path_base has a param in it, we must also add that param to the lower hierarchy resource
                    for op,op_model in paths_object[found_resource_path].items():
                        if op in ['put','get','delete'] and paths_object[found_resource_path][op]['parameters']:
                            for param in paths_object[found_resource_path][op]['parameters']:
                                if param['in'] == 'path':
                                    path_param = param
                                    break
            for found_resource_path in found_resource_paths:
                if re.search(resource,found_resource_path):
                    path = found_resource_path
                    new_path = path_base+path
                    paths_object[new_path] = paths_object.pop(found_resource_path)
                    if path_param:
                        for op,op_model in paths_object[new_path].items():
                            paths_object[new_path][op]['parameters'].append(path_param)
    # ---------------oauth roles & scopes--------------------
    found_paths = list(paths_object.keys())
    for resource,operations in model.items():
        for role,scopes in roles[resource].items():
            security_definitions_object[role] = {'type':'oauth2','flow':'implicit',"authorizationUrl": "http://swagger.io/api/oauth/dialog",'scopes':{}}
            for scope in scopes:
                for found_path in found_paths:
                    if re.search(scope['resource'],found_path) and scope['operation'] in list(paths_object[found_path].keys()):
                        security_definitions_object[role]['scopes'][scope['operation']+':'+found_path] = 'No description'
    # ---------------responses--------------------
    found_paths = list(paths_object.keys())
    for resource,operations in model.items():
        single_resource_path = ''
        collection_path = ''
        for found_path in found_paths:
            if re.search('/'+resource+'.*}$',found_path):
                single_resource_path = found_path
            elif re.search('/' + resource +'$',found_path):
                collection_path = found_path
        for operation,op_model in operations.items():
            this_path = ''
            if op_model != empty[operation]:
                object_name = ''
                if single_resource_path and operation != 'post':
                    this_path = single_resource_path
                else:
                    this_path = collection_path
                if op_model['response']['params'] or op_model['response']['links']:
                    paths_object[this_path][operation]['responses'] = {}
                    object_name = resource + '_' + operation + '_response'         
                if op_model['response']['params']:
                    definitions_object[object_name] = {}
                    definitions_object[object_name]['type'] = 'object'
                    definitions_object[object_name]['properties'] = {}     
                    for param in op_model['response']['params']:
                        if type(param) is list:
                            for domain_param in param:
                                if domain_param['type'] == 'array':
                                    definitions_object[object_name]['properties'][domain_param['name']] = {'type':domain_param['type'],'items':domain_param['items']}
                                else:
                                    definitions_object[object_name]['properties'][domain_param['name']] = {'type':domain_param['type']}
                                    if 'format' in domain_param:
                                        definitions_object[object_name]['properties'][domain_param['name']]['format'] = domain_param['format'] 
                                    # if domain_param['type'] == 'file':
                                        # response can't have file type: not supported by JSON Schema Core
                                paths_object[this_path][operation]['responses']['200'] = {'description':'Success','schema':{'$ref':'#/definitions/' + object_name}}
                        elif type(param) is dict:
                            for param_name,param_value in param.items():
                                if param_name == 'message':
                                    definitions_object[object_name]['properties'][param_name] = {'description':param_value['text'],'type':'string'}
                                    if param_value['type'] == 'Not Found':
                                        paths_object[this_path][operation]['responses']['404'] = {'description':param_value['text'],'schema':{'$ref':'#/definitions/' + object_name}}
                                    elif param_value['type'] == 'Unauthorized':
                                        paths_object[this_path][operation]['responses']['401'] = {'description':param_value['text'],'schema':{'$ref':'#/definitions/' + object_name}}
                                    elif param_value['type'] == 'Bad Request':
                                        paths_object[this_path][operation]['responses']['404'] = {'description':param_value['text'],'schema':{'$ref':'#/definitions/' + object_name}}
                                    elif param_value['type'] == 'success':
                                        paths_object[this_path][operation]['responses']['200'] = {'description':param_value['text'],'schema':{'$ref':'#/definitions/' + object_name}}
                                else:
                                    definitions_object[object_name]['properties'][param_name] = {'description':param_value,'type':'string'}
                                    paths_object[this_path][operation]['responses']['200'] = {'description':'Success','schema':{'$ref':'#/definitions/' + object_name}}
                        else:
                            definitions_object[object_name]['properties'][param] = {'type':'string'}
                            paths_object[this_path][operation]['responses']['200'] = {'description':'Success','schema':{'$ref':'#/definitions/' + object_name}}
                if op_model['response']['links']:
                    message_code = '200'
                    if not paths_object[this_path][operation]['responses']:
                        paths_object[this_path][operation]['responses'][message_code] = {}
                    else:
                        if not '200' in paths_object[this_path][operation]['responses'].keys():
                            paths_object[this_path][operation]['responses'][message_code] = {}
                    paths_object[this_path][operation]['responses'][message_code]['x-links'] = []                          
                    for link in op_model['response']['links']:
                        link_path = ''
                        for found_path in list(paths_object.keys()):
                            if link['operation'] != 'post' and re.search('/'+link['resource']+'.*}$',found_path):
                                link_path = found_path                       
                        if not link_path:
                            for found_path in list(paths_object.keys()):
                                if re.search('/'+link['resource']+'$',found_path):
                                    link_path = found_path
                            if not link_path:
                                sys.exit("Cannot find response link path for resource: " + resource + ", operation: " + operation)
                        paths_object[this_path][operation]['responses'][message_code]['description'] = 'Success'
                        paths_object[this_path][operation]['responses'][message_code]['x-links'].append({'path':link_path,'operation':link['operation']})

    return {'paths':paths_object,'definitions':definitions_object,'securityDefinitions':security_definitions_object}

def flatten(container):
    for i in container:
        if isinstance(i, (list,tuple)):
            for j in flatten(i):
                yield j
        else:
            yield i