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
from tkinter import *
from tkinter import filedialog
import tkinter.ttk as ttk
from tkinter import messagebox
import progressbar
from threading import Thread
import graph

api_conf_fields = 'title', 'description', 'version', 'basePath', 'host', 'resource files folder'
number_of_files = 0

def progress(entries, root):
  resources = {}
  for entry in entries:
    field = entry[0]
    text  = entry[1].get()
    if field == 'resource files folder':
      if text:
        resources = preprocessor.main(text)
        number_of_files = len(resources)
      else:
        messagebox.showerror("Error", "No resource path specified")
        return 
  local = DoubleVar()
  # defines indeterminate progress bar (used while thread is alive) #
  pb1 = ttk.Progressbar(root, orient='horizontal', variable=local, maximum = number_of_files)

  # defines determinate progress bar (used when thread is dead) #
  pb2 = ttk.Progressbar(root, orient='horizontal', mode='determinate')
  pb2['value'] = 100

  # places and starts progress bar #
  pb1.pack(fill=X, expand=1)

  # starts thread #
  thread = Thread(target=generate_schema, args=(entries,resources))
  thread.start()

  # checks whether thread is alive #
  while thread.is_alive():
    local.set(progressbar.progress)
    root.update()#_idletasks()
    pass

  # once thread is no longer active, remove pb1 and place the '100%' progress bar #
  pb1.destroy()
  pb2.pack()

  return

def generate_schema(entries,resources):
  resource_names = nlp.plural_extend(resources)
  model = {}
  hateoas_model = {}
  nlp_model = nlp.resource_analysis(resources,resource_names)
  model = nlp_model['model']
  hateoas_model = nlp_model['graph']
  with open('data.txt', 'w') as outfile:
    json.dump(model, outfile, indent=4)
  with open('graph.txt', 'w') as outfile:
    json.dump(hateoas_model, outfile, indent=4)
  # with open('data.txt') as data_file:    
  #     model = json.load(data_file)
  # with open('graph.txt') as data_file:    
  #     hateoas_model = json.load(data_file)
  graph.draw(hateoas_model)
  oas_schema = formatter.generate_swagger(model)
  oas_schema['info'] = {}
  for entry in entries:
    field = entry[0]
    text  = entry[1].get()
    if field in ['title', 'description', 'version']:
      oas_schema['info'][field] = text
    elif field in ['basePath', 'host']:
      oas_schema[field] = text
  oas_schema['swagger'] = '2.0'
  oas_schema['schemes'] = ['https']
  oas_schema['produces'] = ['application/json']

  with open('swagger.json', 'w') as outfile:
      json.dump(oas_schema, outfile, indent=4)
  with open('swagger.yaml', 'w') as outfile:
      yaml.dump(oas_schema, outfile, indent=4)

def makeform(root, fields):
  entries = []
  for field in api_conf_fields:
    row = Frame(root)
    lab = Label(row, width=15, text=field, anchor='w')
    ent = Entry(row)
    row.pack(side=TOP, fill=X, padx=5, pady=5)
    lab.pack(side=LEFT)
    ent.pack(side=RIGHT, expand=YES, fill=X)
    entries.append((field, ent))
  return entries

def resource_folder(entries):
  resource_location = filedialog.askdirectory()
  for entry in entries:
    field = entry[0]
    if field == 'resource files folder':
      set_text(entry[1],resource_location)
      return

def set_text(e,text):
  e.delete(0,END)
  e.insert(0,text)
  return

start_time = time.time()
if __name__ == '__main__':
  root = Tk()
  ents = makeform(root, api_conf_fields)
  root.bind('<Return>', (lambda event, e=ents: progress(e,root)))   
  b1 = Button(root, text='Generate OpenAPI Specification',
          command=(lambda e=ents: progress(e,root)))
  b1.pack(side=LEFT, padx=5, pady=5)
  b2 = Button(root, text='Done', command=root.quit)
  b2.pack(side=LEFT, padx=5, pady=5)
  b3 = Button(root, text="...", command=(lambda e=ents: resource_folder(e)))
  b3.pack(side=LEFT, padx=5, pady=5)
  progressbar.init() 
  root.mainloop()
elapsed_time = time.time() - start_time
print(elapsed_time)


