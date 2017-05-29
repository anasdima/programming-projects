from graphviz import Digraph

def draw(hateoas_model):
    dot = Digraph(comment='')
    edgs = {}
    for resource,links in hateoas_model.items():
        dot.node(resource,resource)
        for link in links:
            edgs[resource+link['resource']] = {'start':resource,'end':link['resource'],'lbl':''}
        for link in links:
            edgs[resource+link['resource']]['lbl'] += link['operation'] + ', '
    for name,e in edgs.items():
        e['lbl'] = e['lbl'].rstrip(', ')
        dot.edge(e['start'],e['end'],label=e['lbl'])
    dot.render('hateoas_graph/hateoas_graph.gv', view=True)