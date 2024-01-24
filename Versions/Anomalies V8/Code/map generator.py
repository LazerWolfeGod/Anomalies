import pygame,math,random,sys,os
import PyUI as pyui
pygame.init()
screenw = 1200
screenh = 900
screen = pygame.display.set_mode((screenw, screenh),pygame.RESIZABLE)
ui = pyui.UI()
done = False
clock = pygame.time.Clock()

def draw_hex(x,y,side,col):
    r3 = 3**0.5
    cords = [[-r3/2*side,-side/2],[-r3/2*side,side/2],[0,side],
            [r3/2*side,side/2],[r3/2*side,-side/2],[0,-side]]
    for a in cords:
        a[0]+=x
        a[1]+=y
    pygame.draw.polygon(screen,col,cords)
    
def draw_grid(grid,side):
    for y,row in enumerate(grid):
        for x,o in enumerate(grid[y]):
            draw_hex(((3**0.5)*x+((y%2)-1)*-(3**0.5)/2)*side,1.5*y*side,side,key[o])

def linearinterpolate(a,b,i):
    return a+(b-a)*i
def interpolate(a,b,i):
    return linearinterpolate(a,b,(6*i**5-15*i**4+10*i**3))
def interpolate2d(points,x,y):
    p1 = interpolate(points[0][0],points[0][1],x)
    p2 = interpolate(points[1][0],points[1][1],x)
    out = interpolate(p1,p2,y)
    return out
def dot(v1,v2):
    return v1[0]*v2[0]+v1[1]*v2[1]
def perlin_maker(width=40,height=40,gridsize=3):
    grid = []
    p = math.pi
    gridpoints = [int(width/gridsize)+1,int(height/gridsize)+1]
    for b in range(gridpoints[1]):
        grid.append([])
        for a in range(gridpoints[0]):
            ang = random.random()*math.pi*2
            grid[-1].append((math.cos(ang),math.sin(ang)))

    gridw = gridsize
    gridh = gridsize
    
    points = [[] for a in range(gridh*len(grid)-1)]
    for y in range(len(grid)-1):
        for x in range(len(grid[y])-1):
            for a in range(gridh):
                for b in range(gridw):
                    p = [[dot(grid[y][x],(b/gridw,a/gridh)),dot(grid[y][x+1],(b/gridw-1,a/gridh))],
                         [dot(grid[y+1][x],(b/gridw,a/gridh-1)),dot(grid[y+1][x+1],(b/gridw-1,a/gridh-1))]]
                    points[gridh*y+a].append(interpolate2d(p,b/gridw,a/gridh))
    
    return points

def perlin_overwrite(limit,overwrite,grid,gridsize=3):
    perlin = perlin_maker(len(grid[0]),len(grid),gridsize)
    for y,row in enumerate(perlin):
        for x,o in enumerate(perlin[y]):
            if perlin[y][x]>limit:
                grid[y][x] = overwrite

def randompoint(p,r):
    ang = random.random()*2*math.pi
    mod = r*(random.random()*2+1)
    return [p[0]+mod*math.cos(ang),p[1]+mod*math.sin(ang)]
def check_accepted(p,grid,r):
    lis = []
    for y in range(int(p[1]//r)-1,int(p[1]//r)+2):
        for x in range(int(p[0]//r)-1,int(p[0]//r)+2):
            try:
                lis+=grid[y][x][:]
            except Exception as e:
                pass
    for l in lis:
        if ((p[0]-l[0])**2+(p[1]-l[1])**2)**0.5<r:
            return False
    return True

def poisson_disk_sampling(w,h,r,k=30):
    active = [[random.random()*w,random.random()*h]]
    output = []
    grid = [[[] for x in range(w//r)] for y in range(h//r)]
    grid[int(active[-1][1]//r)][int(active[-1][0]//r)].append(active[-1])
    while len(active)>0:
        i = active[-1]
        for attempt in range(k):
            np = randompoint(i,r)
            if np[0]>0 and np[0]<w and np[1]>0 and np[1]<h and check_accepted(np,grid,r):
                active.append(np)
                grid[int(np[1]//r)][int(np[0]//r)].append(np)
        output.append(i)
        active.remove(i)
    return output

def poisson_overwrite(r,overwrite,grid):
    poisson = poisson_disk_sampling(len(grid[0]),len(grid),r)
    for p in poisson:
        grid[int(p[1])][int(p[0])] = overwrite
    
def map_generator(w,h):
    random.seed(11)
    grid = [[1 for a in range(w)] for b in range(h)]
    
    perlin_overwrite(0.3,5,grid)
    perlin_overwrite(0.4,2,grid)
    poisson_overwrite(5,3,grid)
    perlin_overwrite(0.1,4,grid,7)
    
    ran = [random.randint(0,h-1),random.randint(0,w-1)]
    while grid[ran[0]][ran[1]]!= 1:
        ran = [random.randint(0,h-1),random.randint(0,w-1)]
    grid[ran[0]][ran[1]] = 6

    return grid





key = {0:(0,0,0),1:(42,139,42),2:(150,149,149),3:(218,73,73),4:(40,110,174),5:(61,150,61),6:(150,30,140)}
grid = map_generator(60,40)

##points = poisson_disk_sampling(800,800,10)

while not done:
    for event in ui.loadtickdata():
        if event.type == pygame.QUIT:
            done = True

    screen.fill(pyui.Style.wallpapercol)
    draw_grid(grid,30)
##    for a in points:
##        pygame.draw.circle(screen,(0,0,255),a,4)
    ui.rendergui(screen)
    pygame.display.flip()
    clock.tick(60)                                               
pygame.quit() 
