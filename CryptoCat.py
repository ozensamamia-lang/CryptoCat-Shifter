"""
CRYPTO CAT v5.0 - Кот-шифровальщик с сохранением отпечатков лап
Автор: Ваше имя (или псевдоним)
GitHub: ваш_аккаунт
"""

import random
import json
import os
from datetime import datetime
import hashlib

class CryptoCats:
    """Кот-шифровальщик с разными стилями ходьбы и сохранением следов."""
    
    def __init__(self, seed=None, name="КриптоКот", style="random", save_dir="paw_prints"):
        if seed is None:
            seed = random.randint(0, 10000)
        
        random.seed(seed)
        self.seed = seed
        self.name = name
        self.style = style
        self.paw_signature = "=^..^= ~~"
        self.history = []
        self.save_dir = save_dir
        
        os.makedirs(save_dir, exist_ok=True)
        
        self.style_descriptions = {
            'random': "Случайный топот (1-9)",
            'careful': "Осторожные шажки (1-3)",
            'chaotic': "Хаотичный бег (7-12)",
            'zigzag': "Зигзаг (±3)",
            'gallop': "Галоп (2,4,2,4,6)",
            'spiral': "Спираль (1→5→1)",
            'sleepy': "Сонный (часто 0)"
        }
        
        cat_id_str = f"{name}_{style}_{seed}_{datetime.now().timestamp()}"
        self.cat_id = hashlib.md5(cat_id_str.encode()).hexdigest()[:8]
    
    def _generate_shifts(self, length):
        """Генерирует сдвиги согласно стилю."""
        random.seed(self.seed)
        
        if self.style == 'random':
            return [random.randint(1, 9) for _ in range(length)]
        elif self.style == 'careful':
            return [random.randint(1, 3) for _ in range(length)]
        elif self.style == 'chaotic':
            return [random.randint(7, 12) for _ in range(length)]
        elif self.style == 'zigzag':
            return [3 if i % 2 == 0 else -3 for i in range(length)]
        elif self.style == 'gallop':
            pattern = [2, 4, 2, 4, 6]
            return [pattern[i % len(pattern)] for i in range(length)]
        elif self.style == 'spiral':
            shifts = []
            direction = 1
            current = 1
            for _ in range(length):
                shifts.append(current)
                current += direction
                if current >= 5: direction = -1
                elif current <= 1: direction = 1
            return shifts
        elif self.style == 'sleepy':
            return [0 if random.random() < 0.4 else random.randint(1, 4) 
                    for _ in range(length)]
        else:
            return [random.randint(1, 9) for _ in range(length)]
    
    def encrypt(self, text, style=None, save=True):
        """Шифрует текст."""
        if style: self.style = style
        
        shifts = self._generate_shifts(len(text))
        encrypted = ''.join(chr(ord(char) + shifts[i]) 
                          for i, char in enumerate(text))
        
        if save:
            self._save_paw_print('encrypt', text, shifts, encrypted)
        
        return encrypted
    
    def decrypt(self, encrypted_text, save=True):
        """Расшифровывает текст."""
        shifts = self._generate_shifts(len(encrypted_text))
        decrypted = ''.join(chr(ord(char) - shifts[i]) 
                          for i, char in enumerate(encrypted_text))
        
        if save:
            self._save_paw_print('decrypt', encrypted_text, shifts, decrypted)
        
        return decrypted
    
    def _save_paw_print(self, operation, text, shifts, result):
        """Сохраняет отпечаток лапы в JSON."""
        paw_print = {
            'cat_id': self.cat_id,
            'cat_name': self.name,
            'style': self.style,
            'seed': self.seed,
            'operation': operation,
            'timestamp': datetime.now().isoformat(),
            'original_text': text if len(text) < 50 else text[:47] + "...",
            'result_text': result if len(result) < 50 else result[:47] + "...",
            'shifts_sample': shifts[:10],
            'avg_shift': sum(abs(s) for s in shifts) / len(shifts) if shifts else 0
        }
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{self.cat_id}_{timestamp}.json"
        filepath = os.path.join(self.save_dir, filename)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(paw_print, f, ensure_ascii=False, indent=2)
        
        return filepath
    
    def get_info(self):
        """Возвращает информацию о коте."""
        return f"""
        🐱 Имя: {self.name}
        🎭 Стиль: {self.style} - {self.style_descriptions.get(self.style, '?')}
        🔑 Seed: {self.seed}
        🆔 ID: {self.cat_id}
        💾 Следы в: {self.save_dir}/
        """

# Простой пример использования
if __name__ == "__main__":
    print("="*50)
    print("ДЕМО КРИПТОКОТА v5.0")
    print("="*50)
    
    # Создаём кота
    cat = CryptoCats(name="Пушистик", style="spiral", seed=42)
    print(cat.get_info())
    
    # Тест
    text = "Привет, мир!"
    encrypted = cat.encrypt(text)
    print(f"📝 Текст: '{text}'")
    print(f"🔐 Шифр: '{encrypted}'")
    
    decrypted = cat.decrypt(encrypted)
    print(f"🔓 Расшифровка: '{decrypted}'")
    
    if decrypted == text:
        print("✅ Всё работает!")
    
    print(f"\n💾 Отпечатки сохранены в папке: {os.path.abspath(cat.save_dir)}/")
    print("="*50)
