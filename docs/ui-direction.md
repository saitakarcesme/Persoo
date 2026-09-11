# UI yönü — 2026-09-11

Kullanıcı önceki görünümü Apple kalitesinde bulmadı; bu yön kullanıcı tarafından henüz onaylanmış değildir.

Ana görev: konuşarak/yazarak kayıt bırakmak. Model bağlantısı, alan seçimi, tüm kayıt geçmişi, onay/geri alma, ses kurtarma ve erişilebilir kontroller korunur.

Önceki sorun: ana sayfa tek kayıtta bile büyük boşluklu bir listeye dönüşüyor. Mikrofon kapsülü ve sekmeler iki ayrı dock gibi duruyor. Alan kartları aynı hiyerarşi ve yoğunluğa sahip. Siyah üstündeki cam çevresinden neredeyse hiç görsel bilgi alamıyor.

Yeni yapı:
- Ana sayfa her zaman sakin bir anlatma alanı; son etkinliğin kısa özeti ve ayrı geçmiş paneli. Tek kayıtta ana ekranın kimliği değişmez.
- Native TabView + tabViewBottomAccessory: mikrofon/klavye sistemin cam gezinme alanıyla bütünleşir. Yazı düzenleyicisi odaklı bir sheet; kayıt durumu aynı aksesuar içinde.
- Siyah temel üzerinde düşük yoğunluklu renk ışığı. Cam yalnızca kontrollerde; veriler okunaklı, cam olmayan yüzeylerde.
- Hayatım: toplam kayıt özeti, alanlara göre farklı renk, büyük sayılar ve son kayıt bağlamı. Detay: belirgin metrik, gerçek veri grafiği ve gruplanmış liste.
- Sistem font rolleri/Dynamic Type, 44pt+ dokunma alanı, Reduce Motion/Transparency tercihlerine uyum. Sabit sahte grafik veya örnek üretim verisi yok.

Doğrulama: aynı tek finans kaydıyla önce/sonra, ana ekran/geçmiş/Hayatım/Finans/klavye, yeniden açılış, büyük metin ve azaltılmış hareket. Gerçek mikrofon kaydı bu görsel turda başlatılmaz.
