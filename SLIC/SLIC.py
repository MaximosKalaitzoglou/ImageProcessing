import math
from skimage import io, color
import numpy as np
import copy

#K areas or nsp
# so K centers (m)   of superpixels 


class Cluster():
    cluster_indx = 1

    def __init__(self,x,y,r,g,b):
        #update cluster coordinates
        self.update(x,y,r,g,b)
        # pixels in cluster region
        self.pixels = []
        #cuurent cluster number
        self.indx = self.cluster_indx
        # new cluster += 1 
        Cluster.cluster_indx += 1

    def update(self,x,y,r,g,b):
        self.x = x
        self.y = y
        self.r = r 
        self.g = g
        self.b = b
    
    def __str__(self):
        return "X:{},Y:{}:R:{} G:{} B:{} ".format(self.x, self.y, self.r, self.g, self.b)

    def __repr__(self):
        return self.__str__()

class SLIC():
    
   

    def __init__(self,filename,Nsp,Dcm):
        #superreigon size
        self.Nsp = Nsp
        self.Dcm = Dcm
        #image data
        self.data = self.read_image(filename)
        self.img_height = self.data.shape[0]
        self.img_width = self.data.shape[1]
        # img size W*H
        self.N = self.img_height * self.img_width

        #S region based on size of img and super-region size
        self.S = int(math.sqrt(self.N/self.Nsp))

        #set dist to infinite
        self.Dist = np.full((self.img_height,self.img_width),np.inf)
        #set L = -1 
        self.Lp = np.full((self.img_height,self.img_width),-1)

        #initialize cluster array
        self.clusters = []

    #make cluster
    def make_cluster(self,x,y):
        return Cluster(x,y,self.data[x][y][0],self.data[x][y][1],self.data[x][y][2])


    #initialize clusters
    def init_clusters(self):
        for i in range(0,self.img_height,self.S):
            for j in range(0,self.img_width,self.S):
                         
                self.clusters.append(self.make_cluster(i,j))

        #print(self.clusters)

    def calculate_distance(self):
        region = 2*self.S
        for cluster in self.clusters:
            for h in range(cluster.x - region,cluster.x + region):
                if h < 0 or h >= self.img_height:continue
                for w in range(cluster.y - region,cluster.y + region):
                    if w < 0 or w >= self.img_width:continue
                    R,G,B = self.data[h][w]
                    
                    dc = math.sqrt(math.pow(R - cluster.r,2) + math.pow(G - cluster.g,2) + math.pow(B - cluster.b,2))

                    ds = math.sqrt(math.pow(h - cluster.x,2) + math.pow(w - cluster.y,2))

                    #print("DC distance between center (%d,%d) and pixel (%d,%d) = %f" % (cluster.x,cluster.y,h,w,dc))

                    D = math.sqrt(math.pow(dc/self.Dcm,2) + math.pow(ds/self.S,2))
                    #print("Final distance D between center (%d,%d) and pixel (%d,%d) = %f" % (cluster.x,cluster.y,h,w,D))
                    if D < self.Dist[h][w]:
                        self.Dist[h][w] = D
                        self.Lp[h][w] = cluster.indx
                        cluster.pixels.append([h,w])

                        #print("At pixel(%d,%d) distance updated = %f and Lp = %d" %(h,w,self.Dist[h][w],self.Lp[h][w]))

                #exit(0)
                    
    def updateClusters(self):
        #print("BEFORE")
        #print("\n",self.clusters[:10])
        for cluster in self.clusters:
            C = len(cluster.pixels)
            sum_x = sum_y = 0
            for p in cluster.pixels:
                sum_x += p[0]
                sum_y += p[1]

            sum_x = int(sum_x /C)
            sum_y = int(sum_y / C)
            R,G,B = self.data[sum_x][sum_y]
            cluster.update(sum_x,sum_y,R,G,B)
        #print("AFTER")
        #print("\n",self.clusters[:10])      

    def read_image(self,filename):

        img = io.imread(filename)
        arr = color.rgb2lab(img)
        #print(arr)
        return arr
    
    def calculate_error(self,temp):
        Error = 0
        for i in range(0,len(self.clusters)):
            Error += math.sqrt(math.pow(self.clusters[i].x - temp[i].x,2) + math.pow(self.clusters[i].y - temp[i].y,2))
        print(Error)
        return Error


    def save_image(self,filename):
        new_img = self.data
        for cluster in self.clusters:
            for p in cluster.pixels:
                new_img[p[0]][p[1]][0] = cluster.r
                new_img[p[0]][p[1]][1] = cluster.g
                new_img[p[0]][p[1]][2] = cluster.b
            new_img[cluster.x][cluster.y][0] = 0
            new_img[cluster.x][cluster.y][1] = 0
            new_img[cluster.x][cluster.y][2] = 0
        rgb_img = color.lab2rgb(new_img)
        io.imsave(filename,rgb_img)



    def Iterate(self,filename):
        self.init_clusters()
        self.calculate_distance()
        self.updateClusters()
        celling = 27
        Error = 30

        while(Error > celling ):
            temp = copy.deepcopy(self.clusters)
            

           
            
            self.calculate_distance()
            self.updateClusters()
            print("Temp =",temp[:5])
            print("clusters = ",self.clusters[:5])
            Error = self.calculate_error(temp)
            print("Error = %f" % Error)

        
        print("The algorithm stopped successfully!!!")
        self.save_image(filename)



if __name__ == '__main__':
    new_img = SLIC("Lenna.jpg",200,40)
    new_img.Iterate("Lena_200_40.jpg")
    
    new_img = SLIC("Lenna.jpg",300,60)
    new_img.Iterate("Lena_300_60.jpg")

    new_img = SLIC("Lenna.jpg",400,100)
    new_img.Iterate("Lena_400_100.jpg")

    new_img = SLIC("Lenna.jpg",600,5)
    new_img.Iterate("Lena_600_5.jpg")

    new_img = SLIC("Lenna.jpg",1000,90)
    new_img.Iterate("Lena_1000_90.jpg")

    new_img = SLIC("Lenna.jpg",700,300)
    new_img.Iterate("Lena_700_300.jpg")