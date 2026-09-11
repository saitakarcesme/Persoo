# Doğrulama kaydı — 2026-09-11

## Geçen kontroller
- PersooCore: 8 test. Kalıcı kuyruk, duplicate giriş, seçilmeyen alan, hatalı para, soru ile state mutation ayrımı, undo sonrası geç yanıt, bozuk dosyayı koruma.
- Connect: 10 Python testi. Gerçek TLS soketi, onay öncesi erişim engeli, token hash saklama, süre aşımı/reddetme, sertifikaya bağlı kısa kod, bozuk model yanıtı, meşgul/eksik model.
- macOS native yardımcı: derlendi ve açıldı; mevcut Ollama `qwen3:1.7b` bulundu.
- iOS 26.5 Simulator arm64 build geçti, Live Activity extension dahil.
- Bonjour ile bilgisayar adı iPhone Simulator'da bulundu, iki ekranda aynı kod görüldü.
- Gerçek yerel Qwen 3 1.7B: sentetik birleşik cümleden EUR 2500 minor unit harcama ve gelecekteki bacak antrenmanı çıkarıldı. İlk soğuk test, Simulator ilk açılışıyla aynı zamanda 64.26 saniye sürdü. Bu performans hedefi değildir.

## Sınırlar
Simulator mikrofon/kilit ekranı testinin yerine geçmez. Action Button ve Live Activity gerçek iPhone'da doğrulanmadı. LM Studio adaptörü canlı modelle denenmedi. Tek örnek model doğruluğu genellenemez.

## Geliştirme ortamı sorunu ve çözümü
Documents/iCloud kaynakları ve `.git` nesneleri dataless oldu; Git konfigürasyonu okuma aşamasında bekledi. FileManager.startDownloadingUbiquitousItem ile dosyalar indirildi. GitHub'dan yerel checkout alındı, tüm yeni checkpoint nesneleri ve çalışma değişiklikleri korundu; `git fsck --no-reflogs --connectivity-only` ile zincir kontrol edildi. Aktif yol `~/Developer/Persoo`; eski yol symlink. Eski kopyalar silinmedi.

## Son uçtan uca sonuç
Simulator'da IP girmeden bilgisayar seçildi, iki kod karşılaştırılarak onaylandı ve Keychain kaydı başarılı oldu. Kurulumun isim/hoş geldin/çoklu seçim adımları geçildi. `Test: I spent 25 EUR on groceries.` girdisi yerel modelden finance önerisine dönüştü. İlk testte modelin 25 minor unit üretmesi saptandı ve öneri reddedildi. Eklenen deterministik dönüştürme + Swift kaynak doğrulaması sonrası öneri €25.00 oldu, onaylandı, Finans kartında 1 kayıt ve grafikte 1 gözlem görüldü. Uygulama yeniden açıldığında kayıt ve eşleştirme korundu. Önceki geri alınan testler geri gelmedi.

Simulator'daki örnek kullanıcı Deniz ve tüm kayıtlar sentetiktir. UI otomasyonunda AX setValue sonrası bir klavye olayı SwiftUI binding'i güncellemek için gerekliydi; yalnızca AX metninin değişmiş olmasını kayıt doğruluğu kabul etmeyin.

Son build: iOS Simulator arm64 ad-hoc signing açık. İlk unsigned build Keychain erişimini engelliyordu; güvenli saklama kapatılmadan signing düzeltildi.
