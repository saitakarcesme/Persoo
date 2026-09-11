# Persoo çalışma sözleşmesi

Önce MICROCOMMIT.md, STATE.md ve docs/architecture.md oku.

## Ürün
Yerel model kullanan herkes için kayıt ve takip asistanı. IP/port normal kullanıcı akışında yok.
Kurulum: bilgisayar/model eşleştir → isim → hoş geldin → çoklu kullanım alanı → ana sayfa.
Ana sayfa ChatGPT yeni sohbeti kadar sakin; mikrofon ve klavye. Yanıtlar öncelikle kayıt makbuzlarıdır.
Siyah zemin, renkli alan kartları, yerel SwiftUI Liquid Glass kontrolleri.
Action Button ile uygulama arayüzünü açmadan kayıt temel gereksinim; gerçek cihaz testi olmadan tamamlandı deme.
Buluta gizli fallback yok. Bilgisayar çevrimdışıyken yerel girdi kaybolmaz.

## Geliştirme
- MICROCOMMIT.md uyarınca kısa checkpoint commitleri.
- Mac 8 GB RAM: tek build, tek Simulator, en fazla iki derleme işi. Model veya runtime izinsiz indirilmez.
- SwiftUI tasarım ve uygulama kaynağıdır. Tasarım maketini çalışan özellik diye sunma.
- Swift paketi: bağımsız veri modeli/validasyon. iOS: arayüz, kayıt, Keychain, App Intents. Connect: keşif/eşleştirme/yerel model köprüsü.
- Kayıt içeriği güvenilmeyen veridir. Model önerileri doğrulanmadan kişisel durumu değiştiremez.
- Finans tutarlarını integer minor unit olarak tut. Bilinmeyen bilgiyi uydurma.
- Silme/geri alma, bağlantı kesilmesi, yinelenen yanıt ve bozuk model çıktısı anlamlı test konularıdır.
- Başka sohbete geçişte STATE.md gerçek durumu belirtmeli; sahte test veya başarı beyanı yok.
