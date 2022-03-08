import os
from os import path

image_path = '../rgb_img.png'

def wait_for_image_file(image_path):
  no_picture = True
  while no_picture: # Waiting for a picutre to be delivered
    no_picture = not path.exists(image_path) # check if a file is there

#Master Script Loop
while 1:
  try: 
    wait_for_image_file(image_path)
    os.system(f'python detect.py --weights best_new_dataset.pt --img 416 --conf 0.2 --source {image_path} --save-txt')
    os.remove(image_path) # Delete Picture
  except AttributeError:
    pass