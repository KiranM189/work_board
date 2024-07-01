from transformers import TrOCRProcessor, VisionEncoderDecoderModel
from PIL import Image
import cv2
import sys
import image_enhancer
from inference import get_model

def main(input_path, output_path, api_key):
    # Load models
    processor = TrOCRProcessor.from_pretrained("microsoft/trocr-base-handwritten")
    model1 = VisionEncoderDecoderModel.from_pretrained("microsoft/trocr-base-handwritten")
    
    # Read image
    img = cv2.imread(input_path)
    if img is None:
        print(f"Error: Unable to load image from {input_path}")
        return

    # Enhance image
    enhanced_image = image_enhancer.whiteboard_enhance(img)
    
    # Infer model
    model = get_model(model_id="handwrittenv2/2", api_key=api_key)
    results = model.infer(enhanced_image)
    
    for i in results[0].predictions:
        if i.class_name == "oval" or i.class_name == "circle":
            center_x, center_y = int(i.x), int(i.y)  # Center coordinates
            width, height = int(i.width), int(i.height)  # Width and height of the ellipse
            # Draw the ellipse on the image
            x1 = int(i.x - i.width / 2)
            y1 = int(i.y - i.height / 2)
            x2 = int(i.x + i.width / 2)
            y2 = int(i.y + i.height / 2)
            cv2.rectangle(enhanced_image, (x1, y1), (x2, y2), (255, 255, 255), thickness=-1)
            cv2.ellipse(enhanced_image, (center_x, center_y), (width // 2, height // 2), 0, 0, 360, (255, 255, 255), thickness=-1)
            cv2.ellipse(enhanced_image, (center_x, center_y), (width // 2, height // 2), 0, 0, 360, (0, 0, 0), thickness=2)
        elif i.class_name == "rectangle":
            x1 = int(i.x - i.width / 2)
            y1 = int(i.y - i.height / 2)
            x2 = int(i.x + i.width / 2)
            y2 = int(i.y + i.height / 2)
            cv2.rectangle(enhanced_image, (x1, y1), (x2, y2), (255, 255, 255), -1)
            cv2.rectangle(enhanced_image, (x1, y1), (x2, y2), (0, 0, 0), 2)
        elif i.class_name == "rhombus":
            x = int(i.x)
            y = int(i.y)
            x1 = int(i.x - i.width / 2)
            x2 = int(i.x + i.width / 2)
            y1 = int(i.y - i.height / 2)
            y2 = int(i.y + i.height / 2)
            cv2.rectangle(enhanced_image, (x1, y1), (x2, y2), (255, 255, 255), -1)
            cv2.line(enhanced_image, (x1, y), (x, y1), (0, 0, 0), 3)
            cv2.line(enhanced_image, (x2, y), (x, y1), (0, 0, 0), 3)
            cv2.line(enhanced_image, (x1, y), (x, y2), (0, 0, 0), 3)
            cv2.line(enhanced_image, (x2, y), (x, y2), (0, 0, 0), 3)
        elif i.class_name == "text":
            x1 = int(i.x - i.width / 2)
            x2 = int(i.x + i.width / 2)
            y1 = int(i.y - i.height / 2)
            y2 = int(i.y + i.height / 2)
            text_image = enhanced_image[y1:y2, x1:x2]
            image_rgb = cv2.cvtColor(text_image, cv2.COLOR_BGR2RGB)
            image_pil = Image.fromarray(image_rgb).convert("RGB")
            pixel_values = processor(image_pil, return_tensors="pt").pixel_values
            generated_ids = model1.generate(pixel_values)
            generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]
            print(generated_text)
    
    # Save the enhanced image to the output path
    cv2.imwrite(output_path, enhanced_image)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <input_path> <output_path> <api_key>")
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    api_key = sys.argv[3]

    main(input_path, output_path, api_key)
