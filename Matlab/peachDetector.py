import torch
import numpy as np
import cv2
from PIL import Image
from time import time

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
    for i in range(n):
      row = coord[i]
      if row[4] >= 0.2: ## Thresholding
        x1, y1, x2, y2 = int(row[0]*x_shape), int(row[1]*y_shape), int(row[2]*x_shape), int(row[3]*y_shape)
        cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
        cv2.putText(frame, self.class_to_label(labels[i]), (x1, y1), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2, cv2.LINE_AA)
    return frame

  def __call__(self):
    frame = cv2.imread('test_peach_img.jpeg')
    frame = cv2.resize(frame, (416, 416))

    start_time = time()
    results = self.detect_peaches(frame)
    frame = self.plot_boxes(results, frame)
    end_time = time()
    fps = 1/np.round(end_time - start_time, 2)
    # print(f'Frames Per Second : {fps}')

    # cv2.putText(frame, f'FPS: {int(fps)}', (20,70), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 255, 0), 2)
    # cv2.imshow('YOLOv5 Detection', frame)

    # cv2.namedWindow('imageWindow')
    # cv2.imshow('imageWindow', frame)

    # wait = True
    # while wait:
    #   if cv2.waitKey(5) & 0xFF == 27:
    #     break

def predict():
  detector = PeachDetector(capture_index=1, model_name='best.pt')
  detector()