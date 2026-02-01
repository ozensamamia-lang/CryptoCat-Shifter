import random
import math
import json
import os
from datetime import datetime
import hashlib

class CryptoCats:
    """
    Кот-шифровальщик 5.0: с сохранением отпечатков лап!
    Каждый стиль оставляет уникальный 'след' в файле.
    """
    
    def __init__(self, seed=None, name="КриптоКот", style="random", save_dir="paw_prints"):
        """Инициализация кота с папкой для следов."""
        if seed is None:
            seed = random.randint(0, 10000)
            print(f"🐱 {name} выбрал seed: {seed} и стиль '{style}'")
        
        random.seed(seed)
        self.seed = seed
        self.name = name
        self.style = style
        self.paw_signature = "=^..^= ~~"
        self.history = []
        self.save_dir = save_dir
        
        # Создаём папку для следов, если её нет
        os.makedirs(save_dir, exist_ok=True)
        
        # Стили
        self.style_descriptions = {
            'random': "Классический случайный топот",
            'careful': "Осторожные шажки (1-3)",
            'chaotic': "Хаотичное бешенство (7-12)",
            'zigzag': "Зигзагообразная походка (±3)",
            'gallop': "Ритмичный галоп (2,4,2,4...)",
            'spiral': "Спиральное движение (1→5→1)",
            'sleepy': "Сонное вялое топтание (часто 0)"
        }
        
        # Идентификатор кота (уникальный хэш)
        cat_id_str = f"{name}_{style}_{seed}_{datetime.now().timestamp()}"
        self.cat_id = hashlib.md5(cat_id_str.encode()).hexdigest()[:8]
        
        print(f"   ID кота: {self.cat_id}")
        print(f"   Следы будут сохранены в: {os.path.abspath(save_dir)}/")
    
    def _generate_shifts(self, length):
        """Генерирует сдвиги согласно выбранному стилю."""
        random.seed(self.seed)
        
        if self.style == 'random':
            return [random.randint(1, 9) for _ in range(length)]
        
        elif self.style == 'careful':
            return [random.randint(1, 3) for _ in range(length)]
        
        elif self.style == 'chaotic':
            return [random.randint(7, 12) for _ in range(length)]
        
        elif self.style == 'zigzag':
            shifts = []
            for i in range(length):
                if i % 2 == 0:
                    shifts.append(3)
                else:
                    shifts.append(-3)
            return shifts
        
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
                if current >= 5:
                    direction = -1
                elif current <= 1:
                    direction = 1
            return shifts
        
        elif self.style == 'sleepy':
            shifts = []
            for _ in range(length):
                if random.random() < 0.4:
                    shifts.append(0)
                else:
                    shifts.append(random.randint(1, 4))
            return shifts
        
        else:
            return [random.randint(1, 9) for _ in range(length)]
    
    def _create_paw_print(self, operation_type, text, shifts, result):
        """Создаёт отпечаток лапы (словарь с данными)."""
        return {
            'cat_id': self.cat_id,
            'cat_name': self.name,
            'style': self.style,
            'style_description': self.style_descriptions.get(self.style, ""),
            'seed': self.seed,
            'operation': operation_type,  # 'encrypt' или 'decrypt'
            'timestamp': datetime.now().isoformat(),
            'original_length': len(text),
            'original_text': text if len(text) < 50 else text[:47] + "...",
            'result_text': result if len(result) < 50 else result[:47] + "...",
            'shifts_sample': shifts[:20],  # Первые 20 сдвигов для примера
            'avg_shift': sum(abs(s) for s in shifts) / len(shifts) if shifts else 0,
            'shift_stats': {
                'min': min(shifts) if shifts else 0,
                'max': max(shifts) if shifts else 0,
                'positive': sum(1 for s in shifts if s > 0),
                'negative': sum(1 for s in shifts if s < 0),
                'zero': sum(1 for s in shifts if s == 0)
            },
            'paw_signature': self.paw_signature
        }
    
    def _save_paw_print(self, paw_print):
        """Сохраняет отпечаток лапы в JSON файл."""
        # Формируем имя файла
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        filename = f"{self.cat_id}_{self.style}_{timestamp}.json"
        filepath = os.path.join(self.save_dir, filename)
        
        # Сохраняем в JSON
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(paw_print, f, ensure_ascii=False, indent=2)
        
        return filepath
    
    def encrypt(self, text, style=None, save=True):
        """Шифрование с сохранением отпечатка."""
        if style:
            self.style = style
        
        if not text:
            return ""
        
        shifts = self._generate_shifts(len(text))
        encrypted_chars = []
        
        for i, char in enumerate(text):
            shift = shifts[i]
            new_char = chr(ord(char) + shift)
            encrypted_chars.append(new_char)
        
        encrypted_text = ''.join(encrypted_chars)
        
        # Сохраняем в историю
        self.history.append({
            'type': 'encrypt',
            'style': self.style,
            'original': text,
            'encrypted': encrypted_text,
            'shifts': shifts.copy()
        })
        
        # Создаём и сохраняем отпечаток лапы
        if save:
            paw_print = self._create_paw_print('encrypt', text, shifts, encrypted_text)
            saved_path = self._save_paw_print(paw_print)
            print(f"💾 Отпечаток лапы сохранён: {os.path.basename(saved_path)}")
        
        return encrypted_text
    
    def decrypt(self, encrypted_text, save=True):
        """Расшифровка с сохранением отпечатка."""
        if not encrypted_text:
            return ""
        
        shifts = self._generate_shifts(len(encrypted_text))
        decrypted_chars = []
        
        for i, char in enumerate(encrypted_text):
            decrypted_chars.append(chr(ord(char) - shifts[i]))
        
        decrypted_text_result = ''.join(decrypted_chars)
        
        # Сохраняем в историю
        self.history.append({
            'type': 'decrypt',
            'style': self.style,
            'encrypted': encrypted_text,
            'decrypted': decrypted_text_result,
            'shifts': shifts.copy()
        })
        
        # Создаём и сохраняем отпечаток лапы
        if save:
            paw_print = self._create_paw_print('decrypt', encrypted_text, shifts, decrypted_text_result)
            saved_path = self._save_paw_print(paw_print)
            print(f"💾 Отпечаток лапы сохранён: {os.path.basename(saved_path)}")
        
        return decrypted_text_result
    
    def load_paw_prints(self, cat_id=None, style=None, limit=5):
        """Загружает и показывает сохранённые отпечатки лап."""
        print(f"\n📂 Загрузка отпечатков лап из: {self.save_dir}/")
        
        paw_files = []
        for filename in os.listdir(self.save_dir):
            if filename.endswith('.json'):
                if cat_id and cat_id not in filename:
                    continue
                if style and style not in filename:
                    continue
                paw_files.append(os.path.join(self.save_dir, filename))
        
        paw_files.sort(key=os.path.getmtime, reverse=True)  # Сначала новые
        
        if not paw_files:
            print("   (нет сохранённых отпечатков)")
            return []
        
        prints_loaded = []
        for i, filepath in enumerate(paw_files[:limit]):
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    paw_print = json.load(f)
                
                prints_loaded.append(paw_print)
                
                print(f"\n[{i+1}] 📄 {os.path.basename(filepath)}")
                print(f"   Кот: {paw_print['cat_name']} ({paw_print['cat_id']})")
                print(f"   Стиль: {paw_print['style']}")
                print(f"   Операция: {paw_print['operation']}")
                print(f"   Время: {paw_print['timestamp']}")
                print(f"   Длина текста: {paw_print['original_length']} симв.")
                print(f"   Средний сдвиг: {paw_print['avg_shift']:.2f}")
                
            except Exception as e:
                print(f"   Ошибка загрузки {filename}: {e}")
        
        return prints_loaded
    
    def print_statistics(self):
        """Показывает статистику по всем сохранённым следам этого кота."""
        print(f"\n📊 СТАТИСТИКА КОТА {self.name} ({self.cat_id})")
        print("-" * 60)
        
        all_prints = self.load_paw_prints(cat_id=self.cat_id, limit=1000)
        
        if not all_prints:
            print("Нет данных для статистики")
            return
        
        # Статистика по операциям
        encrypts = [p for p in all_prints if p['operation'] == 'encrypt']
        decrypts = [p for p in all_prints if p['operation'] == 'decrypt']
        
        print(f"Всего отпечатков: {len(all_prints)}")
        print(f"  🔒 Шифрований: {len(encrypts)}")
        print(f"  🔓 Расшифрований: {len(decrypts)}")
        
        # Статистика по стилям (если кот менял стили)
        styles_count = {}
        for p in all_prints:
            style = p['style']
            styles_count[style] = styles_count.get(style, 0) + 1
        
        if len(styles_count) > 1:
            print("\n🎭 Использованные стили:")
            for style, count in styles_count.items():
                desc = self.style_descriptions.get(style, "?")
                print(f"  {style:10}: {count:3} раз - {desc}")
        
        # Самый активный день
        dates = []
        for p in all_prints:
            date = p['timestamp'].split('T')[0]
            dates.append(date)
        
        if dates:
            from collections import Counter
            date_counts = Counter(dates)
            most_active = date_counts.most_common(1)[0]
            print(f"\n🗓️  Самый активный день: {most_active[0]} ({most_active[1]} операций)")
    
    def create_pawprint_report(self, output_file="pawprint_report.txt"):
        """Создаёт текстовый отчёт со всеми отпечатками лап."""
        all_prints = self.load_paw_prints(limit=1000)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("=" * 70 + "\n")
            f.write(f"ОТЧЁТ ОБ ОТПЕЧАТКАХ ЛАП КОТА-ШИФРОВАЛЬЩИКА\n")
            f.write(f"Кот: {self.name} (ID: {self.cat_id})\n")
            f.write(f"Сгенерировано: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("=" * 70 + "\n\n")
            
            for i, p in enumerate(all_prints, 1):
                f.write(f"ОТПЕЧАТОК #{i}\n")
                f.write(f"Файл: {p.get('filename', 'N/A')}\n")
                f.write(f"Кот: {p['cat_name']} | Стиль: {p['style']}\n")
                f.write(f"Операция: {p['operation']} | Время: {p['timestamp']}\n")
                f.write(f"Текст: '{p['original_text']}'\n")
                f.write(f"Результат: '{p['result_text']}'\n")
                f.write(f"Сдвиги (пример): {p['shifts_sample']}\n")
                f.write(f"Статистика: ср.сдвиг={p['avg_shift']:.2f}, "
                       f"min={p['shift_stats']['min']}, max={p['shift_stats']['max']}\n")
                f.write("-" * 50 + "\n")
            
            f.write(f"\nВсего отпечатков: {len(all_prints)}\n")
            f.write("=" * 70 + "\n")
        
        print(f"📄 Полный отчёт сохранён в: {output_file}")
        return output_file

# ======== ДЕМОНСТРАЦИЯ СОХРАНЕНИЯ ========
if __name__ == "__main__":
    print("\n" + "💾" * 35)
    print("ДЕНЬ 5: КОТ СОХРАНЯЕТ ОТПЕЧАТКИ ЛАП В ФАЙЛЫ")
    print("💾" * 35)
    
    # Создаём кота, который будет сохранять следы
    cat = CryptoCats(
        seed=777,
        name="Архивариус",
        style="spiral",
        save_dir="cat_paw_prints"  # Папка для сохранения
    )
    
    print(cat.introduce())
    
    # Тестовые сообщения для шифрования
    messages = [
        "Секретное послание для кота",
        "Шифр, оставленный на клавиатуре",
        "ыщовивщвтцдтадчлвтвщраладаша - кот был здесь",
        "Snickers содержит олово"
    ]
    
    print("\n" + "🔐" * 30)
    print("ШИФРОВАНИЕ С СОХРАНЕНИЕМ СЛЕДОВ:")
    print("🔐" * 30)
    
    for msg in messages:
        print(f"\n📝 Сообщение: '{msg}'")
        encrypted = cat.encrypt(msg, save=True)
        print(f"   🔐 Зашифровано: '{encrypted}'")
        
        # Расшифровка тоже сохранит след
        decrypted = cat.decrypt(encrypted, save=True)
        print(f"   🔓 Расшифровано: '{decrypted}'")
    
    # Загружаем и показываем сохранённые следы
    print("\n" + "📂" * 30)
    print("ЗАГРУЗКА СОХРАНЁННЫХ ОТПЕЧАТКОВ:")
    print("📂" * 30)
    
    cat.load_paw_prints(limit=3)
    
    # Показываем статистику
    cat.print_statistics()
    
    # Создаём полный отчёт
    report_file = cat.create_pawprint_report("cat_mission_report.txt")
    
    # Демонстрация разных котов
    print("\n" + "🐈" * 30)
    print("РАЗНЫЕ КОТЫ - РАЗНЫЕ СЛЕДЫ:")
    print("🐈" * 30)
    
    cats_team = [
        CryptoCats(name="Шушун", style="careful", save_dir="cat_paw_prints"),
        CryptoCats(name="Вихрь", style="chaotic", save_dir="cat_paw_prints"),
        CryptoCats(name="Соня", style="sleepy", save_dir="cat_paw_prints")
    ]
    
    for kitty in cats_team:
        test_msg = "Проверка следа"
        encrypted = kitty.encrypt(test_msg, save=True)
        print(f"{kitty.name} ({kitty.style}): '{test_msg}' → '{encrypted[:15]}...'")
    
    print("\n" + "💾" * 35)
    print("ВСЕ ОТПЕЧАТКИ СОХРАНЕНЫ В ПАПКЕ 'cat_paw_prints/'")
    print("Можете открывать JSON-файлы и изучать следы котов!")
    print("💾" * 35)
    
    # Показываем пример содержимого файла
    print("\n📄 Пример содержимого файла отпечатка (cat_paw_prints/*.json):")
    print("""
{
  "cat_id": "a1b2c3d4",
  "cat_name": "Архивариус",
  "style": "spiral",
  "style_description": "Спиральное движение (1→5→1)",
  "seed": 777,
  "operation": "encrypt",
  "timestamp": "2024-01-15T14:30:45.123456",
  "original_text": "Секретное послание для кота",
  "result_text": "Тйлсуёър рсъбзкйё лёз мсѓб",
  "shifts_sample": [1, 2, 3, 4, 5, 4, 3, 2, 1, 2, ...],
  "avg_shift": 2.85,
  "shift_stats": {
    "min": 1,
    "max": 5,
    "positive": 24,
    "negative": 0,
    "zero": 0
  },
  "paw_signature": "=^..^= ~~"
}
""")
