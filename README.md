# Jarvis iOS

Sesli komut ve yazı girişi ile çalışan AI asistanı iOS uygulaması.

## Özellikler

✅ Sesli komut desteği (Speech Recognition)
✅ Yazı girişi
✅ Gemini API entegrasyonu
✅ Mikrofon mute (F4 / Cmd+M)
✅ Konuşma çıkışı (Text-to-Speech)
✅ Chat geçmişi

## Gereksinimler

- macOS 12.0+
- Xcode 14+
- iOS 15.0+
- Gemini API Anahtarı

## Kurulum

1. **Repo'yu klonla:**
```bash
git clone https://github.com/mjb4c7z98h-kripto/Jarvis-iOS.git
cd Jarvis-iOS
```

2. **Xcode'da aç:**
```bash
open Jarvis.xcodeproj
```

3. **API Anahtarını ekle:**
   - `Config/Config.swift` dosyasını aç
   - `GEMINI_API_KEY` değerini gir
   - https://aistudio.google.com'dan al

4. **Çalıştır:**
   - Xcode'da ▶️ Play butonuna bas
   - Veya Cmd+R

## Kullanım

### Sesli Komut
- Microphone butonuna bas
- "Jarvis" de veya direkt sorunuzu sorun
- Konuş ve yayını bitir

### Yazı Girişi
- Metin kutusuna yazı yaz
- Enter tuşuna bas

### Mikrofonu Kapat
- Microphone butonuna tekrar bas
- Veya F4 / Cmd+M

## Proje Yapısı

```
Jarvis-iOS/
├── Jarvis.xcodeproj
├── Jarvis/
│   ├── App/
│   │   └── JarvisApp.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   └── ChatBubble.swift
│   ├── Models/
│   │   ├── Message.swift
│   │   └── GeminiResponse.swift
│   ├── Services/
│   │   ├── GeminiService.swift
│   │   ├── SpeechService.swift
│   │   └── TextToSpeechService.swift
│   ├── Config/
│   │   └── Config.swift
│   └── Assets.xcassets
└── README.md
```

## API Limitleri

- Gemini API: Saatlik 60 istek (free tier)
- Günlük: 1500 istek

## Sorun Giderme

### Mikrofon Çalışmıyor
- Settings → Jarvis → Microphone izni ver

### API Hatası
- API anahtarı doğru mu kontrol et
- Rate limit'i aştın mı kontrol et

### Sesli Komut Tanınmıyor
- Türkçe dil paketini yükle
- Sesini net konuş

## Lisans

MIT

## İletişim

Sorun veya önerilerini GitHub Issues'te bildir.