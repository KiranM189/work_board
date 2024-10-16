from datetime import datetime
from flask import Flask, request, send_file, jsonify
import os
from PIL import Image
from io import BytesIO
# import florence
import shapes_and_text

app=Flask(__name__)

# Ensure the 'uploads' directory exists
UPLOAD_FOLDER='uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/upload', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify(error='No file uploaded'), 400

    file=request.files['image']
    if file.filename=='':
        return jsonify(error='No file selected'), 400

    try:
        # Save the uploaded image
        curr_date_time=datetime.now().strftime("%Y%m%d%H%M%S")
        input_filename=f"{curr_date_time}_{file.filename}"
        input_path=os.path.join(UPLOAD_FOLDER, input_filename)
        file.save(input_path)

        output_filename=f"processed_{input_filename}"
        output_path=os.path.join(UPLOAD_FOLDER, output_filename)
        
        api_key='abcd'
        shapes_and_text.run(input_path, output_path, api_key)
        # task_prompt='<MORE_DETAILED_CAPTION>'
        # analysis=florence.run(task_prompt, input_path)

        with Image.open(output_path) as output_image:
            img_io=BytesIO()
            output_image.save(img_io, 'PNG')
            img_io.seek(0)
        os.remove(input_path)
        os.remove(output_path)
        response=send_file(
            img_io,
            mimetype='image/png',
            as_attachment=True,
            download_name='processed_image.png'
        )

        # Add custom headers
        response.headers['Analysis']="ABCD"
        return response

    except Exception as e:
        app.logger.error(f"Error processing image: {e}")
        return jsonify(error='An error occurred while processing the image'), 500

if __name__=="__main__":
    print("Listening on port 5000")
    app.run(host='0.0.0.0', port=5000)
