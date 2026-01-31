import networkx as nx
from sage.graphs.graph_plot import GraphPlot
import matplotlib.pyplot as plt

# setup
y = var('y')
z = var('z')

# [0/1/2, value, degree, [linking]]

def createGraphInfo(f):
	INVERSES = (f-y).roots(z)
	NUMBRANCH = len(INVERSES)

	fMinOne = f - 1

	ZEROS = f.roots()
	ONES = (f-1).roots()

	combinedZeros 	= [(0, i[0]) for i in ZEROS]
	combinedOnes	= [(1, i[0]) for i in ONES]
	
	vertexData = combinedZeros + combinedOnes

	edgeData = [ ((f-y).roots(z)[i][0].limit(y=0), (f-y).roots(z)[i][0].limit(y=1)) for i in range(NUMBRANCH) ]

	return edgeData, vertexData


def cmap(t):
	initial = (0,0,0)
	final = (1,1,1)
	return t * final + (1 - t) * initial

def genVertexColourMaps(VD):
	colDict = {}

	for v in VD:
		if v[0] == 0:
			colDict.update({v[1]: 0})
		else:
			colDict.update({v[1]: 1})
	return colDict

def drawDessin(f):
	if(type(f) != sage.symbolic.expression.Expression):
		print("[ERROR] have not passed a symbolic expression!")
		return 0
	
	ED, VD = createGraphInfo(f)
	print(f)
	print(VD)
	print(ED)

	dessin = nx.MultiGraph()
	dessin.add_edges_from(ED)
	print(dessin)

	################
	# PLT SETUP
	################
	fig, ax = plt.subplots()
	pos = nx.spectral_layout(dessin)

	################
	# VERTICES
	################
	cmapParamVal = genVertexColourMaps(VD)
	vals = [cmapParamVal.get(v, 0.25) for v in dessin.nodes()]

	nx.draw_networkx_nodes(dessin, pos=pos, ax=ax, cmap=plt.get_cmap('grey'), node_color=vals, edgecolors='k')

	#################
	# EDGES
	#################
	repeatedEdges = []
	for e in range(len(ED)):
		dessin.remove_edge(ED[e][0], ED[e][1])
		if ED[e] in ED:
			repeatedEdges.append(ED[e])
		dessin.add_edge(ED[e][0], ED[e][1])

	singleEdges = list(set(dessin.edges()) - set(repeatedEdges))
	print(f"singleEdges:   {singleEdges}\nrepeatedEdges: {repeatedEdges}")
	nx.draw_networkx_edges(dessin, pos, ax=ax, edgelist=singleEdges)
	radOfCurve = 0.25
	nx.draw_networkx_edges(dessin, pos, ax=ax, edgelist=repeatedEdges, connectionstyle=f'arc3, rad = {radOfCurve}')

	################
	# LABELS
	################
	offset = -0.075
	label_pos = {}
	keys = pos.keys()

	for key in keys:
		x, y = pos[key]
		label_pos[key] = (x, y + offset)

	nx.draw_networkx_labels(dessin, pos=label_pos, ax=ax)

	plt.show()




