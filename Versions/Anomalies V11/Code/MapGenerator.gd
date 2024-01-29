var rng = RandomNumberGenerator.new()

const hex_key = {
	0:"None",
	1:"Forest",
	2:"Rock",
	3:"City",
	4:"Water",
	5:"Meadow",
	6:"Core"
}

func linearinterpolate(a,b,i):
	return a+(b-a)*i
func interpolate(a,b,i):
	return linearinterpolate(a,b,(6*i**5-15*i**4+10*i**3))
func interpolate2d(points,x,y):
	var p1 = interpolate(points[0][0],points[0][1],x)
	var p2 = interpolate(points[1][0],points[1][1],x)
	var out = interpolate(p1,p2,y)
	return out
func dot(v1,v2):
	return v1[0]*v2[0]+v1[1]*v2[1]
func perlin_maker(width=40,height=40,gridsize=3):
	var grid = []
	var p = PI
	var gridpoints = [int(width/gridsize)+1,int(height/gridsize)+1]
	for b in range(gridpoints[1]):
		grid.append([])
		for a in range(gridpoints[0]):
			var ang = rng.randf()*PI*2
			grid[-1].append([cos(ang),sin(ang)])

	var gridw = float(gridsize)
	var gridh = float(gridsize)
	
	var points = []
	for a in range(gridh*len(grid)-1):
		points.append([])
	
	for y in range(len(grid)-1):
		for x in range(len(grid[y])-1):
			for a in range(gridh):
				for b in range(gridw):
					p = [[dot(grid[y][x],[b/gridw,a/gridh]),dot(grid[y][x+1],[b/gridw-1,a/gridh])],
						 [dot(grid[y+1][x],[b/gridw,a/gridh-1]),dot(grid[y+1][x+1],[b/gridw-1,a/gridh-1])]]
					points[gridh*y+a].append(interpolate2d(p,b/gridw,a/gridh))
	
	return points

func perlin_overwrite(limit,overwrite,grid,gridsize=3):
	var perlin = perlin_maker(len(grid[0]),len(grid),gridsize)
	for y in range(perlin.size()):
		for x in range(perlin[y].size()):
			if perlin[y][x]>limit:
				grid[y][x] = overwrite

func randompoint(p,r):
	var ang = rng.randf()*2*PI
	var mod = r*(rng.randf()*2+1)
	return [p[0]+mod*cos(ang),p[1]+mod*sin(ang)]
func check_accepted(p,grid,r):
	var lis = []
	for y in range(int(p[1]/r)-1,int(p[1]/r)+2):
		for x in range(int(p[0]/r)-1,int(p[0]/r)+2):
			if y>-1 and y<grid.size() and x>-1 and x<grid[y].size():
				lis+=grid[y][x]
	for l in lis:
		if ((p[0]-l[0])**2+(p[1]-l[1])**2)**0.5<r:
			return false
	return true

func poisson_disk_sampling(w,h,r,k=30):
	var active = [[rng.randf()*w,rng.randf()*h]]
	var output = []
	var grid = [] #[[[] for x in range(w//r)] for y in range(h//r)]
	for y in range(int(h/r)):
		grid.append([])
		for x in range(int(w/r)):
			grid[-1].append([])
	
	grid[int(active[-1][1]/r)][int(active[-1][0]/r)].append(active[-1])
	while len(active)>0:
		var i = active[-1]
		for attempt in range(k):
			var np = randompoint(i,r)
			if np[0]>0 and np[0]<w and np[1]>0 and np[1]<h and check_accepted(np,grid,r):
				active.append(np)
				grid[int(np[1]/r)][int(np[0]/r)].append(np)
		output.append(i)
		active.remove_at(active.find(i))
	return output

func poisson_overwrite(r,overwrite,grid):
	var poisson = poisson_disk_sampling(len(grid[0]),len(grid),r)
	for p in poisson:
		grid[int(p[1])][int(p[0])] = overwrite
	
func map_generator(w,h):
	var grid = [] #[[1 for a in range(w)] for b in range(h)]
	for b in range(h):
		grid.append([])
		for a in range(w):
			grid[-1].append(1)
	
	
	perlin_overwrite(0.3,5,grid)
	perlin_overwrite(0.4,2,grid)
	poisson_overwrite(5,3,grid)
	perlin_overwrite(0.1,4,grid,7)
	
	var ran = [rng.randi_range(0,h-1),rng.randi_range(0,w-1)]
	while grid[ran[0]][ran[1]]!= 1:
		ran = [rng.randi_range(0,h-1),rng.randi_range(0,w-1)]
	grid[ran[0]][ran[1]] = 6
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			grid[y][x] = hex_key[grid[y][x]]
	return grid
