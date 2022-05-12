# Image correlation
## Having a template of size NxM and an image of size HxW
### we want to get the correlation value of each pixel in the original image with respect to the template
#### to do that we iterate the image matrix in blocks of NxM (size of template) and apply the correlation function
#### Finally we store the values in a new image called correlation
#### Because the computational overload is O(n^4) if implemented with 4 for loops (estimated time to run once ~ =  30-40 minutes)
#### we instead use matrix slicing and matrix subdivision to achieve a time of (~18sec)