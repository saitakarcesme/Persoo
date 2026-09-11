# Güncel durum

Tarih: 2026-09-11. Aktif yeniden kurulum.

## Yetki ve kararlar
Kullanıcı GitHub Persoo içeriğini sıfırlama ve yaklaşık dakikalık checkpoint commitleri istedi. Normal push yetkili; geçmiş korunur. IP normal kurulumda yok. Yerel model, kullanıcı adı, hoş geldin, çoklu alan seçimi sırası.

## Yapıldı
- Eski içerik Git etiketinde: `archive/pre-rebuild-2026-09-11`; yerel arşiv `../Persoo-archive-2026-09-11`.
- GitHub main sıfırlama ve mimari commitleri gönderildi.
- MICROCOMMIT.md ve AGENTS.md devam sözleşmesi.
- Swift RecordStore: atomik yerel kuyruk, şema doğrulama, inceleme/onay, undo, tekrar işlemeye dayanıklılık.
- Persoo Connect: macOS SwiftUI yardımcı, Python stdlib TLS köprü, Bonjour yayını, kod onayı, hashed bearer token, localhost Ollama/LM Studio adaptörleri.
- iOS: keşif/eşleştirme + sertifika pinleme + Keychain; onboarding, kayıt ekranı, renkli alanlar, gerçek kayıt sayı grafikleri.
- Mikrofon, yalnızca cihaz üstü Türkçe transkripsiyon, kurtarılabilir ses dosyaları, AudioRecordingIntent, Live Activity kodu.

## Doğrulama
- Swift çekirdek: 5 test geçti.
- Köprü: 8 test geçti (TLS, onay, yetkisiz erişim, bozuk model çıktısı, meşgul/çevrimdışı).
- Connect macOS uygulaması derlendi ve açıldı.
- iOS ilk build eksik import nedeniyle başarısızdı; düzeltildi, yeniden derleniyor.
- Gerçek yerel model inference ve telefon eşleştirmesi henüz uçtan uca denenmedi.
- Action Button/arka plan/kilitli iPhone henüz gerçek cihazda doğrulanmadı. Kod var ≠ özellik doğrulandı.

## Komutlar
`swift test --package-path packages/PersooCore --scratch-path /tmp/persoo-core-build --jobs 2`
`python3 -m unittest discover -s apps/connect -p 'test_*.py'`
`./scripts/build-connect.sh` → `/tmp/persoo-connect-build/Persoo Connect.app`
`./scripts/build-ios.sh` → `/tmp/persoo-ios-build`
Simulator: `B2B453DF-B03F-4B42-9CEB-558493741704` (Persoo iPhone, iOS 26.5).

## Sıradaki iş
1. iOS build bitir, tek Simulator'da görsel/etkileşim kontrolü.
2. Gerçek model varsa eşleştirme ve kayıt akışını doğrula; yoksa protokol testini gerçek inference diye sunma.
3. Devir belgeleri ve README'yi son duruma getir, kalan checkpointleri push et.

## Bilinen eksikler
QR alternatifi, paketlenmiş Python runtime/noter onayı/Windows dağıtımı, model indirme sihirbazı, telefonda LLM, WAN erişimi yok. Şimdiki Connect Apple command-line Python gerektirir. Alan ekranları ortak kayıt görünümüdür; özel finans ledger/okul takvimi/plan kilometre taşları henüz yok. Kayıt önerisini satır bazında düzenleme ve sesli model yanıtı sonraki iş. Otomatik kuyruk işleme henüz yok; bekleyen kayıtta Modelle işle düğmesi var.
