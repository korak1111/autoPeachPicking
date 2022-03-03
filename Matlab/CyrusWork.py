import torch
import numpy as np
import cv2
from PIL import Image
import time
import os.path
from os import path

class PeachDetector:

  def __init__(self, capture_index, model_name):
    self.capture_index = capture_index
    self.model = self.load_model(model_name)
    self.classes = self.model.names
    self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
    print('Using Device:', self.device)

  def get_video_capture(self):
    return cv2.VideoCapture(self.capture_index)
  
  def load_model(self, model_name):
    if model_name:
      return torch.hub.load('ultralytics/yolov5', 'custom', path=model_name, force_reload=True)
    else:
      return torch.hub.load('ultralytics/yolov5', 'yolov5s', pretrained=True)

  def detect_peaches(self, frame):
    self.model.to(self.device)
    frame = [frame]
    results = self.model(frame)
    labels, coord = results.xyxyn[0][:, -1], results.xyxyn[0][:, :-1]
    return labels, coord

  def class_to_label(self, x):
    return self.classes[int(x)]
  
  def plot_boxes(self, results, frame):
    labels, coord = results
    n = len(labels)
    x_shape, y_shape = frame.shape[1], frame.shape[0]
    coordinates = []
    for i in range(n):
      row = coord[i]
      if row[4] >= 0.2: ## Thresholding
        x1, y1, x2, y2 = int(row[0]*x_shape), int(row[1]*y_shape), int(row[2]*x_shape), int(row[3]*y_shape)
        coordinates.append([x1, y1, x2, y2])
        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
        cv2.putText(frame, self.class_to_label(labels[i]), (x1, y1), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2, cv2.LINE_AA)

    return frame, coordinates

  def predict(self, image):
    frame = cv2.imread(image)
    original_height, original_width = frame.shape[0], frame.shape[1]

    frame = cv2.resize(frame, (416, 416))

    results = self.detect_peaches(frame)
    frame, coordinates = self.plot_boxes(results, frame)

    translated_coordinates = []

    for x1, y1, x2, y2 in coordinates:
      x1_translated = (original_width/416) * x1
      y1_translated = (original_height/416) * y1
      x2_translated = (original_width/416) * x2
      y2_translated = (original_height/416) * y2

      center_x = (x1_translated + x2_translated)/2
      center_y = (y1_translated + y2_translated)/2
      translated_coordinates.append([center_x, center_y])

    return translated_coordinates #resized to proper res


# Initialize NN 

detector = PeachDetector(capture_index=1, model_name='best.pt')

file_name='test_peach_img.jpeg'

#Master Script Loop
while 1:
  no_picture = True
  while no_picture: # Waiting for a picutre to be delivered
    no_picture = not path.exists(file_name) # check if a file is there
    print("No Picture Found")

  time.sleep(0.5)
  coords = detector.predict(file_name)  # Get Coordinates of Bounding Box
  os.remove(file_name) # Delete Picture



  with open('coords.txt', 'x') as f: #Write to a file and release control of file
    for x, y in coords:
      line = str(x) + ' ' + str(y)
      f.write(str(line))
      f.write('\n')




