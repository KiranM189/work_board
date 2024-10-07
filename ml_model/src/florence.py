from transformers import AutoProcessor, AutoModelForCausalLM
from PIL import Image
import torch
# %matplotlib inline

def run(task_prompt, path):
    model_id = 'microsoft/Florence-2-large'
    model2 = AutoModelForCausalLM.from_pretrained(model_id, trust_remote_code=True, torch_dtype='auto').eval().cuda()
    processor2 = AutoProcessor.from_pretrained(model_id, trust_remote_code=True)
    image = Image.open(path).convert("RGB")
    prompt = task_prompt
    inputs = processor2(text=prompt, images=image, return_tensors="pt").to('cuda', torch.float16)
    generated_ids = model2.generate(
      input_ids=inputs["input_ids"].cuda(),
      pixel_values=inputs["pixel_values"].cuda(),
      max_new_tokens=1024,
      early_stopping=False,
      do_sample=False,
      num_beams=3,
    )
    generated_text = processor2.batch_decode(generated_ids, skip_special_tokens=False)[0]
    parsed_answer = processor2.post_process_generation(
        generated_text,
        task=task_prompt,
        image_size=(image.width, image.height)
    )

    return parsed_answer


