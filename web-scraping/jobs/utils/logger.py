# Standard Library Imports
import json
from datetime import datetime

class Logger:
    @staticmethod
    def log_json(level, message, context=None):
        """Log the message as a JSON object with timestamp, level, message, and context (if present)."""
        log_entry = {
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "level": level,
            "message": message
        }
        
        if context:
            log_entry["context"] = context
        
        print(json.dumps(log_entry))
