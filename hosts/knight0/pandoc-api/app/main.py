from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import FileResponse
import os
import subprocess
import uuid

app = FastAPI()

UPLOAD_DIR = "/tmp/uploads"
OUTPUT_DIR = "/tmp/outputs"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

@app.post("/convert")
async def convert_file(
    file: UploadFile = File(...),
    to_format: str = Form("markdown")  # 'markdown' or 'epub'
):
    input_ext = os.path.splitext(file.filename)[-1]
    input_path = os.path.join(UPLOAD_DIR, f"{uuid.uuid4()}{input_ext}")
    output_path = os.path.join(OUTPUT_DIR, f"{uuid.uuid4()}.{to_format}")

    with open(input_path, "wb") as f:
        f.write(await file.read())

    # Run Pandoc
    cmd = [
        "pandoc",
        input_path,
        "-f", "pdf",
        "-t", to_format,
        "-o", output_path
    ]

    try:
        subprocess.run(cmd, check=True)
        return FileResponse(output_path, media_type="application/octet-stream", filename=os.path.basename(output_path))
    except subprocess.CalledProcessError as e:
        return {"error": f"Pandoc failed: {e}"}
