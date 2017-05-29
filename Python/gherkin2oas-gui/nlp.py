import nltk
from nltk.corpus import treebank
import re
# from nltk.tag import StanfordPOSTagger
from nltk.tag import SennaTagger
import inflect
import re
import ast
import sys
import progressbar
from dateutil.parser import parse

HTTP_verbs = {
'post': ["create", "add", "produce", "make", "put", "write", "pay", "send", "build", "raise", "develop", "register", "post", "submit", "apply", "order"],
'get': ["retrieve", "check", "choose", "request", "search", "contact", "get", "take", "see", "ask", "show", "watch", "read", "open", "reach", "return", "receive", "view", "load", "review", "select"],
'put': ["perform", "mark", "evaluate", "update", "set", "change", "edit"],
'delete': ["delete", "destroy", "kill", "remove","cancel"]}

# response code lists
L404 = ['not found','doesn\'t exist','does not exist','unable to find','can\'t find']
L401 = ['unauthorized','not allowed','rejected','denied']
L400 = ['failed','unsuccessful']

# st = StanfordPOSTagger("C:/Users/Tasos/OneDriveThesis/Thesis/src/lib/stanford-postagger-full-2015-12-09/models/english-left3words-distsim.tagger",
#                "C:/Users/Tasos/OneDriveThesis/Thesis/src/lib/stanford-postagger-full-2015-12-09/stanford-postagger.jar")

senna_tagger = SennaTagger("C:/Users/Tasos/OneDriveThesis/Thesis/src/lib/senna")
p = inflect.engine()

def resource_analysis(resources,resource_names):
    model = {}
    hateoas_graph = {}
    for resource,scenarios in resources.items():
        hateoas_graph[resource] = []
        model[resource]= {'get':{'request_params':[],'response':{'params':[],'links':[]}},
        'post':{'request_params':[],'response':{'params':[],'links':[]}},
        'put':{'request_params':[],'response':{'params':[],'links':[]}},
        'delete':{'request_params':[],'response':{'params':[],'links':[]}},'resource_hierarchy':'','resource_roles':{}}
        resource_roles = []
        for scenario,steps_types in scenarios.items():
            if scenario == 'background':
                for steps_type,steps in steps_types.items():
                     if steps_type == 'Given':
                        for step in steps:
                            resource_hierarchy = detect_other_resources(step['sentence'],resource,resource_names)
                            roles = detect_roles(step['sentence'],resource_names,resource_roles)
                            if resource_hierarchy:
                                model[resource]['resource_hierarchy'] = resource_hierarchy
                            elif roles:
                                for role in roles:
                                    resource_roles.append(role)
                                    model[resource]['resource_roles'][role] = []
            when_ops = []
            scenario_roles = []
            for steps_type,steps in steps_types.items():
                if steps_type == 'Given':
                    for step in steps:
                        roles = detect_roles(step['sentence'],resource_names,resource_roles)
                        if roles:
                            for role in roles:
                                if role not in scenario_roles:
                                    scenario_roles.append(role)                                    
            for steps_type,steps in steps_types.items():
                if steps_type == 'When':
                    table_params = []
                    for step in steps:
                        if not when_ops:
                            when_ops = detect_operations(nltk.word_tokenize(step['sentence']),resource_names,steps_type)
                        params = detect_parameters(nltk.word_tokenize(step['sentence']),resource_names)
                        for op in when_ops:
                            for param in params:
                                if param not in model[resource][op]['request_params']:
                                    model[resource][op]['request_params'].append(param)
                            for step in steps:
                                if step['data_table'] and not step['data_table'] in model[resource][op]['request_params']:
                                    domain_table = domain_from(step['data_table'])
                                    if not domain_table in model[resource][op]['request_params']:
                                        model[resource][op]['request_params'].append(domain_table)
                            for resource_role in resource_roles:
                                scope = {'operation':op, 'resource':resource}
                                if scope not in model[resource]['resource_roles'][resource_role]:
                                    model[resource]['resource_roles'][resouce_role].append(scope)
                            for scenario_role in scenario_roles:
                                if scenario_role not in list(model[resource]['resource_roles'].keys()):
                                    model[resource]['resource_roles'][scenario_role] = []
                                scope = {'operation':op, 'resource':resource}
                                if scope not in model[resource]['resource_roles'][scenario_role]:
                                    model[resource]['resource_roles'][scenario_role].append(scope)
                elif steps_type == 'Then':
                    #preprocessing makes sure that 'when' is analyzed before 'then', so by now we know the scenario operations
                    table_params = []
                    for step in steps:
                        message = detect_messages(step['sentence'])
                        if message['text']:
                            for op in when_ops:
                                model[resource][op]['response']['params'].append({'message':message})
                        else:
                            links = detect_operations(nltk.word_tokenize(step['sentence']),resource_names,steps_type)
                            if links and not step['data_table']:
                                for op in when_ops:
                                    for linked_resource,http_verbs in links.items():       
                                        for http_verb in http_verbs:
                                            if not ({'operation':http_verb['http'],'resource':linked_resource} in model[resource][op]['response']['links']):
                                                flag = False
                                                for oper in model[resource].keys():
                                                    if 'response' in model[resource][oper]:
                                                        if {'operation':http_verb['http'],'resource':linked_resource} in model[resource][oper]['response']['links']:
                                                            flag = True
                                                if flag == False:
                                                    hateoas_graph[resource].append({'operation':http_verb['natural'],'resource':linked_resource})
                                                model[resource][op]['response']['links'].append({'operation':http_verb['http'],'resource':linked_resource})
                            elif not links or step['data_table']:
                                params = detect_parameters(nltk.word_tokenize(step['sentence']),resource_names)
                                for op in when_ops:
                                    for param in params:
                                        if param not in model[resource][op]['response']['params']:
                                            model[resource][op]['response']['params'].append(param)
                                    for step in steps:
                                        if step['data_table'] and not step['data_table'] in model[resource][op]['response']['params']:
                                            domain_table = domain_from(step['data_table'])
                                            model[resource][op]['response']['params'].append(domain_table)
        progressbar.progress += 1
    return {'model':model,'graph':hateoas_graph}

def detect_other_resources(sentence,resource,resource_names):
    for token in nltk.word_tokenize(sentence):
        if token != resource:
            if token in resource_names:
                return token

def detect_roles(sentence,resource_names,resource_roles):
    tagged_tokens = senna_tagger.tag(nltk.word_tokenize(sentence))
    roles = []
    has_resources = any(resource_name in nltk.word_tokenize(sentence) for resource_name in resource_names)
    if not has_resources: 
        for tagged_token in tagged_tokens:
            if tagged_token[0] not in resource_roles:
                if tagged_token[1][0:2] == 'NN':
                    roles.append(tagged_token[0])
    elif has_resources:
        if detect_http_verbs(nltk.word_tokenize(sentence)):
            for tagged_token in tagged_tokens:
                if tagged_token[0] not in resource_roles:
                    if tagged_token[1][0:2] == 'NN':
                        roles.append(tagged_token[0])
    return roles

def detect_messages(sentence):
    message = {'text':'','type':''}
    quoted_phrase = find_quoted_text(sentence)

    #assuming there is only one quoted phrase atm
    if quoted_phrase:
        plain_phrase = quoted_phrase[0].lower()
        for token in nltk.word_tokenize(sentence):
            if token == 'message':
                message['text'] = quoted_phrase[0]
                if ([text for text in L404 if re.search(text,plain_phrase)]):
                    message['type'] = 'Not Found'
                elif ([text for text in L401 if re.search(text,plain_phrase)]):
                    message['type'] = 'Unauthorized'
                elif ([text for text in L400 if re.search(text,plain_phrase)]):
                    message['type'] = 'Bad Request'
                if not message['type']:
                    message['type'] = 'success'
    return message

def detect_operations(tokenized_sentence,resource_names,step_type):
    # by convention a when_step can have ops and params in the same sentence
    # on the contrary a then_step sentence that describes hateoas cannot also have params
    operations = {}

    for token in tokenized_sentence:
        if step_type == 'When':
            detected_verbs = []
            for detected_verb in detect_http_verbs(tokenized_sentence):
                detected_verbs.append(detected_verb['http'])
            return detected_verbs
        elif step_type == 'Then' and token in resource_names:
            operations[token] = []
            for detected_verb in detect_http_verbs(tokenized_sentence):
                if token != detected_verb['natural']:
                    operations[token].append(detected_verb)
            return operations

def detect_parameters(tokenized_sentence,resource_names):
    tagged_tokens = senna_tagger.tag(tokenized_sentence)
    parameters = []

    for tagged_token in tagged_tokens: # a tagged token has the word at position 0 and the tag at position 1
         if tagged_token[1][0:2] == 'NN':
            if not tagged_token[0] in resource_names:
                parameters.append(tagged_token[0])

    return parameters

def detect_http_verbs(tokenized_sentence):
    tagged_tokens = senna_tagger.tag(tokenized_sentence)
    verbs = []
    for tagged_token in tagged_tokens: # a tagged token has the word at position 0 and the tag at position 1
        if tagged_token[1][0:2] == 'VB':           
            for http_verb, language_verbs in HTTP_verbs.items():
                if tagged_token[0] in language_verbs:
                   verbs.append({'http': http_verb, 'natural': tagged_token[0]})

    return verbs

def plural_extend(words_in_dict_keys):
    return list(words_in_dict_keys) + [p.plural(word) for word in list(words_in_dict_keys)]

def domain_from(table):
    # patterns = [(r'^-?[0-9]+(.[0-9]+)?$', 'CD')]
    # regexp_tagger = nltk.RegexpTagger(patterns)
    domain = []
    top_row = table[0]
    most_left_column = []
    second_row = []
    second_column = []
    for row in table:
        most_left_column.append(row[0])
    if len(table) > 1:
        second_row = table[1]
        for row in table:
            second_column.append(row[1])
    elif len(table) == 1:
        if len(table[0]) > 1:
            second_column.append(table[0][1])

    if not any(is_data_type(cell) for cell in top_row): #domain is on the top row
        if second_row:
            if all(is_data_type(cell) for cell in second_row):
                for top_cell,bottom_cell in zip(top_row,second_row):
                    domain_type = type_of_value(bottom_cell)
                    if domain_type is float:
                        domain.append({'name':top_cell,'type':'number','format':'float'})
                    elif domain_type is int:
                        domain.append({'name':top_cell,'type':'integer','format':'int32'})
                    elif domain_type is bool:
                        domain.append({'name':top_cell,'type':'boolean'})
                    elif is_array(bottom_cell):                                  
                        content = is_array(bottom_cell)[0]
                        values = []
                        collection_format = ''
                        if ',' in content:
                            collection_format = 'csv'
                            values = content.split(',')                            
                        elif ' ' in content:
                            collection_format = 'ssv'
                            values = content.split(' ')
                        elif '\t' in content:
                            collection_format = 'tsv'
                            values = content.split('\t')
                        elif '|' in content:
                            collection_format = 'pipes'
                            values = content.split('|') 
                        types = type_of_value(values[0]) # assuming that user did not submit an array with different data types
                        if types is float:
                            domain.append({'name':top_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'number','format':'float'}})
                        elif types is int:
                            domain.append({'name':top_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'integer','format':'int32'}})
                        elif types is bool:
                            domain.append({'name':top_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'boolean'}})
                        else:
                            domain.append({'name':top_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'string'}})
                    else:
                        if top_cell == 'password' or top_cell == 'Password' or top_cell == 'PASSWORD':
                            domain.append({'name':top_cell,'type':'string','format':'password'})
                        elif not is_quoted_text(bottom_cell):
                            if domain_type == 'file':
                                domain.append({'name':top_cell,'type':'file'})
                            elif is_date(bottom_cell):
                                if ':' in bottom_cell:
                                    domain.append({'name':top_cell,'type':'string','format':'date-time'})
                                else:
                                    domain.append({'name':top_cell,'type':'string','format':'date'})
                        else:
                            domain.append({'name':top_cell,'type':'string'})
            else:
                sys.exit("Incorrect table format")
        else:
            for cell in top_row:
                domain.append({'name':cell,'type':'string'})  
    elif not any(is_data_type(cell) for cell in most_left_column): #domain is on the most left column  
        if second_column:
            if all(is_data_type(cell) for cell in second_column):
                for left_cell,right_cell in zip(most_left_column,second_column):
                    domain_type = type_of_value(right_cell)
                    if domain_type is float:
                        domain.append({'name':left_cell,'type':'number','format':'float'})
                    elif domain_type is int:
                        domain.append({'name':left_cell,'type':'integer','format':'int32'})
                    elif domain_type is bool:
                        domain.append({'name':left_cell,'type':'boolean'})
                    elif is_array(right_cell):                            
                        content = is_array(right_cell)[0]
                        values = []
                        collection_format = ''
                        if ',' in content:
                            collection_format = 'csv'
                            values = content.split(',')                            
                        elif ' ' in content:
                            collection_format = 'ssv'
                            values = content.split(' ')
                        elif '\t' in content:
                            collection_format = 'tsv'
                            values = content.split('\t')
                        elif '|' in content:
                            collection_format = 'pipes'
                            values = content.split('|')
                        types = type_of_value(values[0]) # assuming that user did not submit an array with different data types
                        if types is float:
                            domain.append({'name':left_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'number','format':'float'}})
                        elif types is int:
                            domain.append({'name':left_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'integer','format':'int32'}})
                        elif types is bool:
                            domain.append({'name':left_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'boolean'}})
                        else:
                            domain.append({'name':left_cell,'type':'array','collectionFormat':collection_format,'items':{'type':'string'}})
                    else:
                        if left_cell == 'password' or left_cell == 'Password' or left_cell == 'PASSWORD':
                            domain.append({'name':left_cell,'type':'string','format':'password'})
                        elif not is_quoted_text(right_cell):
                            if domain_type == 'file':
                                domain.append({'name':left_cell,'type':'file'})
                            elif is_date(right_cell):
                                if ':' in right_cell:
                                    domain.append({'name':left_cell,'type':'string','format':'date-time'})
                                else:
                                    domain.append({'name':left_cell,'type':'string','format':'date'})
                        else:
                            domain.append({'name':left_cell,'type':'string'})
            else:
                sys.exit("Incorrect table format")
        else:
            for cell in most_left_column:
                domain.append({'name':cell,'type':'string'})
    else:
        sys.exit("Incorrect table format")
    
    return domain

def type_of_value(var):
    try:
       return type(ast.literal_eval(var))
    except Exception:
        if var == 'true' or var == 'false':
            return bool
        elif var == 'file':
            return 'file'
        else:
            return str

def is_date(string):
    try: 
        parse(string)
        return True
    except ValueError:
        return False

def find_quoted_text(string):
    return re.findall(r'\"(.+?)\"',string)

def is_array(string):
    return re.findall(r'\[(.+?)\]',string)

def is_quoted_text(string):
    if re.findall(r'\'(.+?)\'',string):
        return True
    else:
        return False

def is_data_type(string):
    value_type = type_of_value(string)
    if (value_type is float) or (value_type is int) or (value_type is bool) or (value_type is list) or (value_type == 'file') or is_quoted_text(string) or is_array(string):
        return True
    elif is_date(string):
        return True
    else:
        return False