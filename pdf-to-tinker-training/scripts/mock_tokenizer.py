import sys
from types import ModuleType
from transformers import AutoTokenizer

def mock_tml_tokenizers():
    if "tml_tokenizers" in sys.modules:
        return
    
    # Create mock tml_tokenizers module
    tml_tokenizers = ModuleType("tml_tokenizers")
    sys.modules["tml_tokenizers"] = tml_tokenizers
    
    tinker_tokenizers = ModuleType("tml_tokenizers.tinker_tokenizers")
    tml_tokenizers.tinker_tokenizers = tinker_tokenizers
    sys.modules["tml_tokenizers.tinker_tokenizers"] = tinker_tokenizers
    
    def get_tinker_tokenizer(tokenizer_id):
        return AutoTokenizer.from_pretrained("thinkingmachines/Inkling", trust_remote_code=True)
        
    tinker_tokenizers.get_tinker_tokenizer = get_tinker_tokenizer

mock_tml_tokenizers()
