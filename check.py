import os
import glob

for f in glob.glob('**/*.swift', recursive=True):
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
            c_open = content.count('{')
            c_close = content.count('}')
            if c_open != c_close:
                print(f"MISMATCH in {f}: {c_open} open, {c_close} close")
    except Exception as e:
        print(f"Error {f}: {e}")
