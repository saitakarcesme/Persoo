# Microcommit kuralları

Bu dosya tüm modeller ve sohbetler için geçerlidir.

- Aktif geliştirmede yaklaşık her 60 saniyede anlamlı, gözden geçirilebilir bir checkpoint oluştur. Uzun derleme/ağ beklemesinde boş commit üretme; bekleme bitince checkpoint al.
- Başlık: `checkpoint: kisa Turkce aciklama` (tercihen 50 karakterden kısa).
- Örnekler: `checkpoint: model eslestirme`, `checkpoint: kayit kuyrugu`.
- İlgili dosyaları açıkça stage et. Körlemesine `git add .` kullanma. Anahtarlar, kişisel kayıtlar, sesler, build dosyaları ve model ağırlıkları commit edilmez.
- Commit öncesi staged diff'i kontrol et. Her commit tam ürün olmak zorunda değil; eksik veya doğrulanmamış iş STATE.md içinde açıkça belirtilir.
- Özellik ve doğrulama kilometre taşlarında STATE.md güncelle. Sohbet sonunda mutlaka son durum, çalıştırma komutları, testler ve sıradaki somut işi yaz.
- Checkpoint yerel committir. Bu yeniden kurulumda kullanıcı GitHub reposunun boşaltılıp geliştirilmesini istedi; normal push yetkili. Force push ve geçmişi silmek bu kapsama girmez.
- Devam ederken: AGENTS.md → MICROCOMMIT.md → STATE.md → docs/architecture.md oku; git status ve son 5 commiti kontrol et.
- Çalışma süresi dışında kendiliğinden commit döngüsü veya zamanlanmış görev başlatma.
