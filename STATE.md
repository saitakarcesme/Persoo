# Güncel durum — sonraki sohbet buradan devam eder

Son güncelleme: 2026-09-11. İlk çalışan uçtan uca temel tamamlandı; ürünün tamamı değil.

## Çalışma yeri ve yetki
- Aktif checkout: `/Users/ibrahimsaitakarcesme/Developer/Persoo`.
- Eski `/Users/ibrahimsaitakarcesme/Documents/ChatGPT/Harness/Persoo` yolu buraya symlink.
- Kullanıcı GitHub Persoo içeriğini sıfırlama, geliştirmeye başlama ve yaklaşık dakikalık checkpoint commitleri istedi. Normal push yetkili; geçmiş silme/force push yok.
- Repo: `https://github.com/saitakarcesme/Persoo`, branch `main`.
- Eski ürün: `archive/pre-rebuild-2026-09-11` etiketi. Yerel eski içerik `Documents/ChatGPT/Harness/Persoo-archive-2026-09-11`; iCloud çalışma yedeği `Persoo-iCloud-backup-2026-09-11`. Silinmedi.

## Ürün kararları
Herkes için yerel modelle kişisel kayıt/takip. Kurulum: IP girmeden bilgisayar/model bağla → isim → hoş geldin → çoklu alan seçimi. Üç sekme: Anlat, Hayatım, Planlar. SwiftUI siyah zemin, renkli alan kartları ve native Liquid Glass. Action Button ile arayüz açılmadan kayıt temel gereksinim. Bulut fallback yok.

## Çalışan ve doğrulananlar
- Connect: native macOS arayüzü, Python stdlib TLS köprü, Bonjour keşfi, iki ekranda aynı kod, masaüstünde onay, sertifika pinleme ve Keychain. Yeniden açılışta otomatik bağlantı doğrulandı.
- Mevcut Ollama `qwen3:1.7b` bulundu; yeni model indirilmedi. Gerçek birleşik girdi finance + fitness olarak ayrıldı.
- iOS onboarding tüm adımları Simulator'da geçildi (sentetik Deniz kullanıcısı; notes/finance/fitness seçili).
- Klavye girdisi → yerel model → kaynakla doğrulanan €25.00 önerisi → kullanıcı onayı → Finans kartı → gerçek kayıt sayısı grafiği uçtan uca geçti.
- Uygulama yeniden başlatıldığında onaylı kayıt ve Keychain eşleşmesi korundu. Geri alınan iki test önerisi geri gelmedi.
- Para: modelin 25 EUR'yu 25 cent döndürdüğü hata yakalandı. Tek açık tutar deterministik dönüştürülür; telefon öneri ve onay aşamasında kaynak metinle karşılaştırır. Desteklenmeyen para biçimi tahmin edilmez.

## Kod var, gerçek cihaz doğrulaması bekliyor
Mikrofon, cihaz üstü Türkçe transkripsiyon, yarım kalan seslerin saklanması, AudioRecordingIntent, Live Activity/Dynamic Island. Simulator build geçmesi Action Button'ın kilitli iPhone'da çalıştığını kanıtlamaz. Kesintisiz sesli model sohbeti/yanıtı uygulanmadı.

## Doğrulama
- Swift çekirdek: 8 test geçti.
- Python köprü: 10 test geçti.
- macOS uygulaması ve iOS arm64 Simulator + Live Activity extension build geçti.
- Ayrıntılar: docs/verification.md. Görseller: docs/screenshots/receipt.png ve finance.png; tamamı test verisi.
- LM Studio adaptörü canlı modelle denenmedi.

## Komutlar
`swift test --package-path packages/PersooCore --scratch-path /tmp/persoo-core-build --jobs 2`
`python3 -m unittest discover -s apps/connect -p 'test_*.py'`
`./scripts/build-connect.sh` → `/tmp/persoo-connect-build/Persoo Connect.app`
`./scripts/build-ios.sh` → `/tmp/persoo-ios-build/Build/Products/Debug-iphonesimulator/Persoo.app`
`python3 scripts/test-local-model.py --model Ollama:qwen3:1.7b` (sentetik gerçek inference)
Simulator: `B2B453DF-B03F-4B42-9CEB-558493741704`, Persoo iPhone, iOS 26.5. Tek cihaz kullan.

## Sonraki somut iş
1. Gerçek iPhone'da Action Button → kayıt → durdurma → yerel yazıya çevirme → makbuz; kilitli ekran, izin reddi, arama kesintisi ve bilgisayar çevrimdışı senaryolarını doğrula/düzelt.
2. Kayıt önerilerini onay öncesi düzenleme ve belirsiz alanı sorma arayüzü.
3. QR eşleştirme alternatifi ve dağıtılabilir Connect paketi (gömülü runtime, notarization, Windows).
4. Alanlara özgü finans ledger, okul takvimi, plan adımları; daha sonra kayıtlara dayalı öneriler ve sesli yanıt.

## Diğer eksikler / sınırlar
- Şu anda alan ekranları ortak kayıt listesi/sayısı grafiğidir; tam finans veya sağlık ürünü değildir.
- QR, model indirme sihirbazı, telefonda LLM, WAN bağlantısı, bildirim planlama yok.
- Bekleyen girdilerde elle “Modelle işle” var; otomatik yeniden işleme kuyruğu yok.
- Türkçe arayüz/dikte başlangıcı; dil seçimi ve diğer diller sonra.
- Connect `/usr/bin/python3` 3.9+ gerektirir; son kullanıcı kurucusu henüz hazır değil.
- 8 GB RAM: tek build, iki iş, tek Simulator. Ollama çıkarımında think=false, çıktı 1024 token, keep_alive=60s. Bu ayarlar diğer kullanıcı uygulamalarını kapatmaz.
- iCloud dataless sorunu çözüldü: yeni yerel checkout'ta checkpoint zinciri korundu. Disk alanı sınırlı olmaya devam ediyor; eski arşivleme alan açmış sayılmaz.
