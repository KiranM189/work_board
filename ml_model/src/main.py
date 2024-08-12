from inference import get_model
from datetime import datetime
from flask import Flask, request, send_file, jsonify
import image_enhancer
import os
import cv2
# from transformers import TrOCRProcessor, VisionEncoderDecoderModel
from  PIL import Image
# import numpy as np
from io import BytesIO

app = Flask(__name__)

# Ensure the 'uploads' directory exists
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/upload', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify(error='No file uploaded'), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify(error='No file selected'), 400

    try:
        curr_date_time = datetime.now().strftime("%Y%m%d%H%M%S")
        input_filename = f"{curr_date_time}_{file.filename}"
        input_path = os.path.join(UPLOAD_FOLDER, input_filename)
        file.save(input_path)

        output_filename = f"processed_{input_filename}"
        output_path = os.path.join(UPLOAD_FOLDER, output_filename)
        api_key='W3qPqcMolWonRsfEjphV'
        print("Function called")
        main(input_path,output_path,api_key) 

        # Open the processed image from the output path and prepare it for sending
        with Image.open(output_path) as output_image:
            img_io = BytesIO()
            output_image.save(img_io, 'PNG')
            img_io.seek(0)

        return send_file(img_io, mimetype='image/png', as_attachment=True, download_name=output_filename)
    except Exception as e:
        app.logger.error(f"Error processing image: {e}")
        return jsonify(error='An error occurred while processing the image'), 500



def main(input_path,output_path,api_key):
    # processor = TrOCRProcessor.from_pretrained("microsoft/trocr-base-handwritten")
    # model123 = VisionEncoderDecoderModel.from_pretrained("microsoft/trocr-base-handwritten")

    model = get_model(model_id="handwrittenv2/2", api_key=api_key)
    imgg = cv2.imread(input_path)
    enim = image_enhancer.whiteboard_enhance(imgg)
    results = model.infer(enim)

    para=0
    circles = 0
    rectan = 0
    rhom = 0

    white_color = (255, 255, 255)
    arrow=0
    for i in results[0].predictions:
        if i.class_name == "head000":
            arrow+=1
            center_x, center_y = int(i.x), int(i.y)  # Center coordinates
            width, height = int(i.width), int(i.height)

            # Calculate the corners of the rhombus
            x1 = int(center_x - (width-30) / 2)
            x2 = int(center_x + (width-30)/ 2)
            y1 = int(center_y - (height-30) / 2)
            y2 = int(center_y + (height-30) / 2)

            # Points of the rhombus
            points = [
            [center_x, y1],  # Top point
            [x2, center_y],  # Right point
            [center_x, y2],  # Bottom point
            [x1, center_y]   # Left point
            ]
            points = points.reshape((-1, 1, 2))

            # Draw and fill the rectangle
            top_left_x = center_x - width // 2
            top_left_y = center_y - height // 2
            bottom_right_x = center_x + width // 2
            bottom_right_y = center_y + height // 2
            cv2.rectangle(enim, (top_left_x, top_left_y), (bottom_right_x, bottom_right_y), white_color, thickness=-1)

            # Fill the rhombus with black
            cv2.fillPoly(enim, [points], color=(0, 0, 0))

            # Draw the edges of the rhombus (optional, for better visualization)
            cv2.polylines(enim, [points], isClosed=True, color=(0, 0, 0), thickness=2)

        if i.class_name == "oval" or i.class_name == "circle":
            center_x, center_y = int(i.x), int(i.y)  # Center coordinates
            width, height = int(i.width), int(i.height)  # Width and height of the ellipse

            # Define the grey color (in BGR format)
            

            # Draw the ellipse on the image
            #cv2.rectangle(enim, (top_left_x, top_left_y), (bottom_right_x, bottom_right_y), white_color_color, thickness=-1)
            cv2.ellipse(enim, (center_x, center_y), (width // 2, height // 2), 0, 0, 360,white_color, thickness=-1)
            cv2.ellipse(enim, (center_x, center_y), (width // 2, height // 2), 0, 0, 360,(0,0,0), thickness=2)

            circles += 1

        if i.class_name == "parallelogram":
            center_x, center_y = int(i.x), int(i.y)  # Center coordinates
            width, height = int(i.width), int(i.height)  # Width and height of the canvas

            # Calculate the top-left and bottom-right corners of the rectangle
            top_left_x = center_x - width // 2
            top_left_y = center_y - height // 2
            bottom_right_x = center_x + width // 2
            bottom_right_y = center_y + height // 2
            offset = width // 10

            # Define the four vertices of the parallelogram
            pt1 = (top_left_x, top_left_y)  # Top left
            pt2 = (bottom_right_x, top_left_y)  # Top right
            pt3 = (bottom_right_x - offset, bottom_right_y)  # Bottom right
            pt4 = (top_left_x - offset, bottom_right_y)  # Bottom left
            cv2.rectangle(enim, (top_left_x-offset, top_left_y), (bottom_right_x+offset, bottom_right_y), white_color, thickness=-1)
            # Draw the four sides of the parallelogram
            cv2.line(enim, pt1, pt2, (0,0,0), 2)
            cv2.line(enim, pt2, pt3, (0,0,0), 2)
            cv2.line(enim, pt3, pt4, (0,0,0), 2)
            cv2.line(enim, pt4, pt1, (0,0,0), 2)
            para+=1
            
        if i.class_name == "rectangle" or i.class_name == "square" :
            center_x, center_y = int(i.x), int(i.y)  # Center coordinates
            width, height = int(i.width), int(i.height)  # Width and height of the canvas

            # Calculate the top-left and bottom-right corners of the rectangle
            top_left_x = center_x - width // 2
            top_left_y = center_y - height // 2
            bottom_right_x = center_x + width // 2
            bottom_right_y = center_y + height // 2

            cv2.rectangle(enim, (top_left_x, top_left_y), (bottom_right_x, bottom_right_y), white_color, thickness=-1)
            cv2.rectangle(enim, (top_left_x, top_left_y), (bottom_right_x, bottom_right_y), (0,0,0), thickness=2)

            rectan += 1

        if i.class_name == "rhombus":
            center_x, center_y = int(i.x), int(i.y)  # Center coordinates
            width, height = int(i.width), int(i.height)
            x=(int)(i.x)
            y=(int)(i.y)
            x1=(int)(i.x-i.width/2)
            x2=(int)(i.x+i.width/2)
            y1=(int)(i.y-i.height/2)
            y2=(int)(i.y+i.height/2)
            top_left_x = center_x - width // 2
            top_left_y = center_y - height // 2
            bottom_right_x = center_x + width // 2
            bottom_right_y = center_y + height // 2
            cv2.rectangle(enim, (top_left_x, top_left_y), (bottom_right_x, bottom_right_y), white_color, thickness=-1)        
            cv2.line(enim,(x1,y),(x,y1),(0,0,0),2)
            cv2.line(enim,(x2,y),(x,y1),(0,0,0),2)
            cv2.line(enim,(x1,y),(x,y2),(0,0,0),2)
            cv2.line(enim,(x2,y),(x,y2),(0,0,0),2)
            rhom += 1
        
    # for i in results[0].predictions:
    #     if i.class_name == "text":
    #         center_x, center_y = int(i.x), int(i.y)  # Center coordinates
    #         width, height = int(i.width), int(i.height)
    #         top_left_x = center_x - width // 2
    #         top_left_y = center_y - height // 2
    #         bottom_right_x = center_x + width // 2
    #         bottom_right_y = center_y + height // 2
    #         cropped_image = imgg[top_left_y:bottom_right_y, top_left_x:bottom_right_x]
    #         image_rgb = cv2.cvtColor(cropped_image, cv2.COLOR_BGR2RGB)

    #         # Convert the OpenCV image to a PIL image
    #         image_pil = Image.fromarray(image_rgb)

    #         # Tokenize the image using the TrOCR processor
    #         pixel_values = processor(image_pil, return_tensors="pt").pixel_values

    #         # Generate text from the pixel values
    #         generated_ids = model123.generate(pixel_values)
    #         generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
    #         #font = cv2.FONT_HERSHEY_SCRIPT_SIMPLEX
    #         font = cv2.FONT_HERSHEY_SIMPLEX
    #         thickness = 2
    #         x = center_x - width // 2
    #         y = center_y - height // 2

    # # Calculate the font scale based on the rectangle size and text length
    #         font_scale = min(width, height) / 10  # Adjust this factor as needed

    # # Calculate the text size to check if it fits into the rectangle
    #         (text_width, text_height), _ = cv2.getTextSize(generated_text, font, font_scale, thickness)

    # # Adjust font scale to fit text into the rectangle
    #         while text_width > width or text_height > height:
    #             font_scale -= 0.05
    #             (text_width, text_height), _ = cv2.getTextSize(generated_text, font, font_scale, thickness)

    # # Calculate text position to center it in the rectangle
    #         text_x = x + (width - text_width) // 2
    #         text_y = y + (height + text_height) // 2

    # # Draw the rectangle and text on the image
    #         cv2.rectangle(enim, (x, y), (x + width, y + height), (249,249,249),-1)  # White rectangle border
    #         cv2.putText(enim,generated_text, (text_x, text_y), font, font_scale, (0,0,0), thickness)
    #         print(generated_text)
    cv2.imwrite(output_path, enim)
    # print("circles : %3d \n rectangles : %3d \n rhombus : %3d \n text : %3d \n parallelogram : %3d" % (circles, rectan, rhom,para))
if __name__ == "__main__":
    print("Listening on port 5000")
    app.run(host='0.0.0.0',debug=True,port=5000)