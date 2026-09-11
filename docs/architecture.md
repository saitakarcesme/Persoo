# Persoo v2 mimarisi

## Katmanlar
- `apps/ios`: iOS 26+ native SwiftUI uygulaması. Onboarding, kayıt akışı, alan kartları, ses, Action Button.
- `apps/connect`: hafif macOS yardımcı uygulaması ve Python standart kütüphaneli köprü. Mevcut yerel modelleri kullanır; model ağırlığı yüklemez.
- `packages/PersooCore`: UI'dan bağımsız, test edilebilir kayıt protokolü, alanlar ve kalıcı girdi kuyruğu.
- `docs`: kararlar ve kullanıcı akışları. `STATE.md`: sohbetler arası güncel devir.

## Eşleştirme tasarımı
Bonjour `_persoo._tcp` ile keşif. IP normal arayüzde gösterilmez. Telefon ve bilgisayarda aynı kısa kodun karşılaştırılıp bilgisayarda onaylanması. TLS sertifikası eşleştirmede sabitlenir; bearer token Keychain'de saklanır. Onaysız telefon modele veya kayıtlara erişemez. QR sonraki alternatif taşıma yöntemidir; ağ izolasyonunu aşmaz.

Connect önce Mac'te çalışan Ollama ve LM Studio'nun localhost API'lerini kontrol eder. Sunucu çalışmıyorsa açık durum gösterir. Model/servis kurulumu, model indirme ve WAN erişimi ilk iskelet kapsamı dışındadır.

## Kayıt yaşam döngüsü
Ham girdi hemen atomik yerel dosyaya kaydolur → pending → model yapılandırılmış öneri üretir → şema/alan doğrulama → makbuz. İstek kimliği ile yinelenen işleme önlenir. Kullanıcı düzeltir veya geri alır. Sorular kayıt değişikliği değildir. Kullanıcının seçtiği alanlar dışında otomatik kayıt yapılmaz.

## Yerellik
İnternet gerektiren inference/transkripsiyon fallback'i yok. Aynı ağdaki kullanıcı bilgisayarı ilk model hedefi. Telefon içinde LLM ve ev dışı güvenli erişim ayrı kilometre taşları. Ses tanıma yalnızca cihaz üstü destek varsa; aksi halde açıkça kullanılamıyor durumu.

## Donanım bütçesi
Tek iOS Simulator runtime/device, `-jobs 2`, Xcode GUI zorunlu değil. Build verisi repo dışında `/tmp/persoo-build`. Eski içerik Git geçmişi ve repo dışındaki arşivde; arşivleme disk alanı açmış sayılmaz.

## İlk doğrulama sırası
1. Çekirdek kuyruk: yeniden açılma, duplicate, bozuk çıktı, undo.
2. Connect: keşif, kullanıcı onayı, kimlik doğrulama, yerel model erişimi.
3. iOS onboarding → klavye kaydı → kalıcılık → sonuç kartı.
4. Mikrofon + Action Button + Live Activity: gerçek iPhone'da kilitli/arka plan senaryoları.

## Yerel geliştirme konumu (2026-09-11)
Aktif checkout `/Users/ibrahimsaitakarcesme/Developer/Persoo`. Documents altındaki eski yol bu konuma symlink'tir. iCloud kaynak dosyaları ve Git nesnelerini `dataless` yaptığı için taşındı. Önce tüm dosyalar indirildi, yeni checkout'a commit nesneleri aktarıldı ve bağlantı bütünlüğü doğrulandı. iCloud'daki kopya `Persoo-iCloud-backup-2026-09-11` olarak korundu. Geliştirmeyi tekrar Documents/iCloud'a taşımayın.

Ollama kayıt çıkarımı: native `/api/chat`, `think: false`, en fazla 1024 çıktı tokenı, 60 saniye idle keep-alive. Aynı anda tek inference. Kaynak: https://docs.ollama.com/api/chat . Bu sınırlar yeni model indirmez veya başka uygulamanın ayarlarını değiştirmez.
