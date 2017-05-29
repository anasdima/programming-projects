import preprocessor
import nlp
import json
from collections import OrderedDict
import sys
import time
import nltk
import formatter
import yaml
from swagger_spec_validator import validator20
import graph
import argparse
import configparser

start_time = time.time()

parser = argparse.ArgumentParser(description='Gherkin2OAS')
parser.add_argument('-f','--folder', help='Resource folder path', required=False)
parser.add_argument('-m','--model', help='Model file path', required=False)
parser.add_argument('-fg','--fixgraph', action='store_true', help='Enable graph fixing', required=False)
args = vars(parser.parse_args())
if not args['folder'] and not args['model']:
    sys.exit("Need one input file, type -h for help")
if args['folder'] and args['model']:
    sys.exit("Choose either folder or model")

oas_settings = configparser.ConfigParser()
oas_settings.read('spec_config.ini')
if not oas_settings:
    sys.exit("Something went wrong when reading settings file")

model = {}
resource_graph = {}
state_graph = {}
if args['model']:
    print('Loading model...')
    nlp_model = {}
    with open(args['model']) as data_file:    
        nlp_model = json.load(data_file)
    model = nlp_model['model']
    resource_graph = nlp_model['resource_graph']
    state_graph = nlp_model['state_graph']
elif args['folder']:
    print('Parsing resources...')
    resources = preprocessor.main(args['folder'])
    if not resources:
        print('No resources found, did you insert the correct resources folder?')
        sys.exit()
    resource_names = nlp.plural_extend(resources)
    print('Processing resources...')
    nlp_model = nlp.resource_analysis(resources,resource_names)
    model = nlp_model['model']
    resource_graph = nlp_model['resource_graph']
    state_graph = nlp_model['state_graph']
    with open('output_files/nlp_model.json', 'w') as outfile:
        json.dump(nlp_model, outfile, indent=4)

print('Generating files...')
graph.draw(resource_graph,state_graph,args['fixgraph'])

oas_schema = formatter.generate_swagger(model)
oas_schema['swagger'] = '2.0'
oas_schema['info'] = {  "title":            oas_settings['INFO']['title'],
                        "description":      oas_settings['INFO']['description'],
                        "version":          oas_settings['INFO']['version'],
                        "termsOfService":   oas_settings['INFO']['termsOfService'],
                        "contact":          {'name':oas_settings['CONTACT']['name'],
                                            'url': oas_settings['CONTACT']['url'],
                                            'email': oas_settings['CONTACT']['email']},
                        "license":          {'name': oas_settings['LICENSE']['name'],
                                            'url': oas_settings['LICENSE']['url']}
}
oas_schema['host'] = oas_settings['HOST']['host']
oas_schema['schemes'] = ['https','http']
oas_schema['basePath'] = oas_settings['BASEPATH']['basePath']
oas_schema['produces'] = ['application/json']

with open('output_files/swagger.json', 'w') as outfile:
    json.dump(oas_schema, outfile, indent=4)

with open('output_files/swagger.yaml', 'w') as outfile:
    yaml.dump(oas_schema, outfile, indent=4)

validator20.validate_spec(oas_schema)
elapsed_time = time.time() - start_time
print("Successfully generated valid swagger")
print(elapsed_time)

