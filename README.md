# Persoo

**Anlat. Kaydet. Takip et. Kendi modelinle.**

Yerel model kullananlar için native iPhone kayıt asistanı. İlk çalışan geliştirme sürümü: SwiftUI + Liquid Glass, IP yazmadan bilgisayar eşleştirme, yerel kayıt kuyruğu ve modelden denetlenebilir kayıt önerileri.

Güncel tasarım: [ana sayfa](docs/screenshots/redesign/after-home.png) · [Hayatım](docs/screenshots/redesign/after-life.png) · [Finans](docs/screenshots/redesign/after-finance.png).

## Çalışan temel

- Kurulum: bilgisayarı/modeli bağla → isim → hoş geldin → birden fazla kullanım alanı.
- Persoo Connect: Bonjour keşfi, iki ekranda kod karşılaştırma, bilgisayarda onay, TLS sertifika pinleme ve iPhone Keychain.
- Ollama / LM Studio localhost adaptörleri; mevcut modeli kullanır, model indirmez. Gerçek inference testi Ollama Qwen 3 1.7B ile yapıldı.
- Klavye girdisi önce telefona atomik kaydolur. Model çıktısı şema ve açık para tutarı açısından doğrulanır; kullanıcı onaylar veya geri alır.
- Seçilen alanlara göre renkli kartlar ve kayıt sayılarından grafikler.
- Cihaz üstü Türkçe dikte, kurtarılabilir ses kaydı, Action Button App Intent ve Live Activity uygulaması. Gerçek iPhone davranışı henüz doğrulanmadı.

Bu sürüm App Store ürünü değildir. [Güncel durum ve kalan işler](STATE.md), [doğrulama kaydı](docs/verification.md).

## Geliştirme

Gereksinimler: macOS, Xcode/iOS 26 SDK, Swift 6.2+, XcodeGen; Connect için `/usr/bin/python3` (3.9+). Model sunucusu ayrıca kurulu ve açık olmalı. Şu an dağıtılabilir, noter onaylı bir Connect kurucusu yok.

```sh
./scripts/build-connect.sh
open '/tmp/persoo-connect-build/Persoo Connect.app'
./scripts/build-ios.sh
```

`apps/ios/Persoo.xcodeproj` Xcode'da da açılabilir. Gerçek iPhone'a yükleme için kendi signing team/provisioning ayarını seç. Build betiği tek arm64 Simulator hedefini, iki derleme işini ve repo dışı `/tmp/persoo-ios-build` dizinini kullanır.

```sh
swift test --package-path packages/PersooCore --scratch-path /tmp/persoo-core-build --jobs 2
python3 -m unittest discover -s apps/connect -p 'test_*.py'
# İsteğe bağlı: sentetik veriyle gerçek yerel inference (mevcut modeli çalıştırır)
python3 scripts/test-local-model.py --model Ollama:qwen3:1.7b
```

## Veri ve bağlantı

Kayıtlar iPhone uygulama alanında; eşleştirme anahtarı Keychain'de. Connect yalnızca eşleştirilmiş telefonlara model erişimi verir. Bilgisayardaki kimlik bilgileri Application Support/PersooConnect altında, repo dışında saklanır. Transkripsiyon buluta düşmez; cihaz üstü Türkçe tanıma kullanılamıyorsa ses korunur.

İlk sürüm aynı yerel ağ içindir. Bilgisayar çevrimdışıyken girdiler telefonda bekler. Bekleyen kayıtta **Modelle işle** düğmesi vardır. Para ayrıştırıcısı sınırlı açık sayısal biçimleri destekler; belirsiz para birimi veya desteklenmeyen biçim tahmin edilmez.

## Yeni model / sohbet ile devam

Önce [AGENTS.md](AGENTS.md) → [MICROCOMMIT.md](MICROCOMMIT.md) → [STATE.md](STATE.md) → [mimari](docs/architecture.md) oku. Kısa checkpoint commitleriyle ilerle:

```sh
./scripts/checkpoint.sh 'kayit duzenleme' ilgili/dosya.swift STATE.md
```

Eski tasarım ve filmler `archive/pre-rebuild-2026-09-11` Git etiketinde korunur. Geçmiş silinmedi. Depoya özel kayıt, ses, anahtar veya model ağırlığı ekleme.
