# 🗺️ Routa - 6 Haftalık Geliştirme Planı

**Başlangıç Tarihi:** [Bugünün tarihi]
**Hedef:** Portfolyo + İş Başvurusu Ready
**Haftalık Çalışma:** 25-30 saat
**Toplam Süre:** 6 hafta (~160 saat)

---

## 📊 GENEL BAKIŞ

```
Hafta 1: Budget Calculator + Comparison       (25 saat)
Hafta 2: Random Generator + Map               (28 saat)
Hafta 3: Route Detail + Search Enhancement    (26 saat)
Hafta 4: Favorites + Profile + Offline        (25 saat)
Hafta 5: Animations + Polish                  (27 saat)
Hafta 6: Documentation + Launch               (30 saat)
```

---

# HAFTA 1: Budget Calculator + Comparison (25 saat)

## 🎯 Hedef
2 killer feature tamamla - Budget Calculator ve Destination Comparison

## Pazartesi-Salı (12 saat): Budget Calculator

### Yeni Dosyalar:
```
Routa/Features/Budget/
├── BudgetCalculatorView.swift (4 saat)
├── BudgetViewModel.swift (3 saat)
├── Models/
│   ├── BudgetCategory.swift (1 saat)
│   └── TripCost.swift (1 saat)
└── Components/
    ├── BudgetSlider.swift (2 saat)
    └── CostBreakdownCard.swift (1 saat)
```

### Özellikler:
- [ ] Destination seçimi (dropdown)
- [ ] Trip duration (slider: 1-30 gün)
- [ ] Konaklama tipi (hostel/otel/lüks)
- [ ] Yemek bütçesi (ucuz/orta/pahalı)
- [ ] Aktiviteler (kaç aktivite?)
- [ ] Ulaşım (local transport)
- [ ] TOPLAM hesapla + Chart göster

### Firebase Structure:
```json
budgetTemplates/{destinationId}
{
  "accommodation": {
    "hostel": 500,
    "hotel": 1500,
    "luxury": 5000
  },
  "food": {
    "budget": 300,
    "moderate": 600,
    "expensive": 1200
  },
  "activities": 200,
  "transport": 150
}
```

---

## Çarşamba-Perşembe (10 saat): Destination Comparison

### Yeni Dosyalar:
```
Routa/Features/Comparison/
├── ComparisonView.swift (3 saat)
├── ComparisonViewModel.swift (2 saat)
├── Components/
│   ├── ComparisonCard.swift (2 saat)
│   ├── ComparisonMetricRow.swift (1 saat)
│   └── WinnerBadge.swift (1 saat)
└── Models/
    └── ComparisonResult.swift (1 saat)
```

### Özellikler:
- [ ] 2 destinasyon seç
- [ ] Budget karşılaştırması
- [ ] Temperature karşılaştırması
- [ ] Popular months overlap
- [ ] Activity count
- [ ] Language difficulty
- [ ] Currency strength
- [ ] "Kazanan" badge göster

---

## Cuma (3 saat): Test & Polish
- [ ] Her iki feature test et
- [ ] Edge cases check
- [ ] UI polish (spacing, colors)
- [ ] Animasyonlar ekle
- [ ] Error handling

---

# HAFTA 2: Random Generator + Interactive Map (28 saat)

## Pazartesi (6 saat): Random Destination Generator

### Yeni Dosyalar:
```
Routa/Features/Discovery/
├── RandomGeneratorView.swift (3 saat)
├── RandomViewModel.swift (2 saat)
└── Components/
    └── ShuffleButton.swift (1 saat)
```

### Özellikler:
- [ ] "Şansımı Dene" butonu (HomeView'a ekle)
- [ ] Budget range filter (optional)
- [ ] Season filter (optional)
- [ ] Random destinasyon göster (full screen)
- [ ] "Beğenmedim" → Yeni random
- [ ] "Beğendim" → Favorilere ekle
- [ ] Shake gesture (BONUS)
- [ ] Card flip animation
- [ ] Confetti effect
- [ ] Haptic feedback

---

## Salı-Çarşamba-Perşembe (18 saat): Interactive Map

### Yeni Dosyalar:
```
Routa/Features/Map/
├── MapView.swift (5 saat)
├── MapViewModel.swift (3 saat)
├── Components/
│   ├── DestinationAnnotation.swift (2 saat)
│   ├── ClusterAnnotation.swift (3 saat)
│   ├── RouteOverlay.swift (2 saat)
│   └── MapControlPanel.swift (2 saat)
└── Models/
    └── MapRegion.swift (1 saat)
```

### Özellikler:
- [ ] Tüm destinasyonları harita üzerinde göster
- [ ] Custom pin design
- [ ] Pin'e tıkla → Mini detail card
- [ ] Cluster (birbirine yakın pinler)
- [ ] User location göster
- [ ] "Yakınımdaki yerler" filter
- [ ] Route overlay (planned trip için)
- [ ] Map style toggle (standard/satellite)

---

## Cuma (4 saat): Integration & Polish
- [ ] Map'i HomeView'a entegre et
- [ ] Tab bar'a "Harita" tab ekle
- [ ] Performance optimize (lazy load pins)
- [ ] Animation polish
- [ ] Test on simulator

---

# HAFTA 3: Route Detail + Search Enhancement (26 saat)

## Pazartesi-Salı (10 saat): Route Detail Enhancement

### Güncelleme:
```
Routa/Features/PlaceDetail/GeneratedRouteView.swift

Yeni Components:
├── DailyTimelineView.swift (3 saat)
├── ActivityCard.swift (2 saat)
├── DayMapPreview.swift (2 saat)
├── CostBreakdownView.swift (2 saat)
└── RouteShareSheet.swift (1 saat)
```

### Özellikler:
- [ ] Günlük Timeline UI
- [ ] Saat aralıkları (08:00 Kahvaltı, 10:00 Aktivite...)
- [ ] Her gün için mini harita
- [ ] Activity cards (swipeable)
- [ ] Günlük bütçe breakdown
- [ ] Rotayı Kaydet butonu
- [ ] Paylaş (link generate)

---

## Çarşamba-Perşembe (12 saat): Search Enhancement

### Yeni Components:
```
ContentView.swift - SearchView bölümü

├── BudgetRangeSlider.swift (2 saat)
├── TemperatureFilter.swift (2 saat)
├── SeasonPicker.swift (2 saat)
├── DurationFilter.swift (2 saat)
└── SearchResultsMap.swift (4 saat)
```

### Yeni Filterlar:
- [ ] Budget Range (dual slider: 0-50K TL)
- [ ] Temperature (Sıcak/Ilık/Serin/Soğuk)
- [ ] Best Season (İlkbahar/Yaz/Sonbahar/Kış)
- [ ] Trip Duration (Weekend/Short/Long/Extended)
- [ ] Map View Toggle (Liste ↔ Harita)

---

## Cuma (4 saat): Search Optimization
- [ ] Filter kombinasyonları test
- [ ] Search performance (debounce check)
- [ ] Empty state improvements
- [ ] Loading states
- [ ] Cache optimization

---

# HAFTA 4: Favorites + Profile + Offline (25 saat)

## Pazartesi-Salı (10 saat): Favorites Collections

### Yeni Dosyalar:
```
Routa/Features/Profile/Favorites/
├── FavoritesCollectionView.swift (3 saat)
├── CollectionDetailView.swift (2 saat)
├── CreateCollectionSheet.swift (2 saat)
└── Components/
    ├── CollectionCard.swift (2 saat)
    └── DragDropGrid.swift (1 saat)
```

### Özellikler:
- [ ] Collection Types (Tümü/Yaz/Balayı/Solo/Custom)
- [ ] Create collection
- [ ] Add to collection (multi-select)
- [ ] Drag & drop between collections
- [ ] Delete collection
- [ ] Share collection (deep link)

### Firebase Structure:
```
collections/{userId}/{collectionId}
└── destinationIds: [array]
```

---

## Çarşamba (8 saat): User Profile Stats

### Yeni Components:
```
Routa/Features/Profile/ProfileView.swift

├── TravelStatsCard.swift (2 saat)
├── AchievementBadge.swift (2 saat)
├── VisitedMapView.swift (2 saat)
└── ProgressRing.swift (2 saat)
```

### Özellikler:
- [ ] Stats Dashboard (favori/rota/koleksiyon sayısı)
- [ ] Gezgin seviyesi badge
- [ ] Achievements:
  - 🌍 "İlk Adım" - İlk favorini ekle
  - ✈️ "Kaşif" - 10 destinasyon
  - 🗺️ "Gezgin" - 5 rota
  - 📚 "Koleksiyoncu" - 3 koleksiyon
  - 🌟 "Uzman" - 50 destinasyon
- [ ] Visited Places Map
- [ ] "Gittim" işaretle
- [ ] İstatistik: "X/193 ülke gezildi"

---

## Perşembe-Cuma (7 saat): Offline Mode

### Yeni Dosyalar:
```
Routa/Shared/
├── NetworkMonitor.swift (2 saat)
├── OfflineBanner.swift (1 saat)
└── Components/
    ├── CachedBadge.swift (1 saat)
    └── SyncIndicator.swift (1 saat)
```

### Özellikler:
- [ ] Network Monitor (real-time status)
- [ ] Offline banner
- [ ] "Cached" badge on cards
- [ ] "Last synced: X min ago"
- [ ] Pull to refresh (force sync)
- [ ] Auto-sync when online
- [ ] Firebase cache optimization (50MB limit)

---

# HAFTA 5: Animations + Polish + Error Handling (27 saat)

## Pazartesi-Salı (10 saat): Animation Enhancement

### Yeni Animations:
```
Routa/DesignSystem/Animations.swift (extend)

├── CardFlipAnimation (2 saat)
├── ParallaxScroll (2 saat)
├── ShimmerEffect (improve) (2 saat)
├── PageTransition (2 saat)
└── MicroInteractions (2 saat)
```

### Eklenecek Yerler:
- [ ] Card Flip: Random generator
- [ ] Parallax: Detail view scroll
- [ ] Shimmer: Loading states (refine)
- [ ] Transitions: Navigation smooth
- [ ] Micro: Button press, favorite tap
- [ ] Lottie Animations:
  - Success (rota oluşturuldu)
  - Loading (better)
  - Empty state illustrations

---

## Çarşamba (8 saat): Error Handling & Empty States

### Yeni Dosyalar:
```
Routa/Shared/ErrorHandling/
├── ErrorView.swift (2 saat)
├── EmptyStateView.swift (2 saat)
├── RetryButton.swift (1 saat)
└── ToastNotification.swift (2 saat)

Models:
└── AppError.swift (1 saat)
```

### Error States:
- [ ] Network Error (friendly mesaj + retry)
- [ ] Firebase Error (retry + cache)
- [ ] Empty States:
  - No favorites
  - No routes
  - No search results
- [ ] Toast Notifications:
  - Success: "Favorilere eklendi ✓"
  - Error: "Bir hata oluştu"
  - Info: "Offline modasınız"

---

## Perşembe-Cuma (9 saat): Final Polish

### UI Polish (4 saat):
- [ ] Tüm spacing'leri check
- [ ] Color consistency
- [ ] Font sizes review
- [ ] Shadow/elevation tutarlılığı
- [ ] Dark mode her yerde test

### Performance (3 saat):
- [ ] Large list optimization
- [ ] Image loading optimization
- [ ] Memory leak check (Instruments)
- [ ] Firebase query optimization
- [ ] Cache strategy review

### Accessibility Basics (2 saat):
- [ ] Button size check (min 44x44)
- [ ] Contrast test
- [ ] Tap targets (min 44pt)
- [ ] VoiceOver (major screens)

---

# HAFTA 6: Documentation + Screenshots + Launch Prep (30 saat)

## Pazartesi-Salı (12 saat): README & Documentation

### Oluşturulacak Dosyalar:
```
├── README.md (4 saat)
├── ARCHITECTURE.md (3 saat)
├── FEATURES.md (2 saat)
├── SETUP.md (1 saat)
└── Screenshots/README.md (2 saat)
```

### README.md İçeriği:
- [ ] Project overview + banner
- [ ] Features (her biri için screenshot)
- [ ] Architecture diagram
- [ ] Tech stack
- [ ] Setup instructions
- [ ] Öğrendiklerim bölümü
- [ ] İletişim bilgileri

---

## Çarşamba (8 saat): Screenshots & Demo Video

### Test Data Hazırla (1 saat):
- [ ] Güzel görünen destinasyonlar
- [ ] Örnek routes
- [ ] Sample collections
- [ ] Mock user profile

### Screenshots Al (4 saat):
iPhone 15 Pro - 15+ screenshot:
- [ ] Onboarding (2 screens)
- [ ] Home (light + dark)
- [ ] Search with filters
- [ ] Destination detail
- [ ] Budget calculator
- [ ] Comparison view
- [ ] Random generator
- [ ] Map view
- [ ] Route detail
- [ ] Favorites collections
- [ ] Profile stats
- [ ] Settings

### Demo Video (3 saat):
- [ ] Script yaz (30 min)
- [ ] Record (1 saat)
- [ ] Edit (1 saat) - iMovie
- [ ] Add music/text (30 min)

---

## Perşembe (6 saat): GitHub + LinkedIn Prep

### GitHub:
- [ ] Clean commit history
- [ ] Remove sensitive data check
- [ ] Pin repository
- [ ] Topics ekle
- [ ] About section
- [ ] Create release (v1.0.0)
- [ ] Issue templates
- [ ] Contributing.md
- [ ] Code of Conduct

### LinkedIn Post Taslağı:
```markdown
🚀 Yeni proje: Routa - Travel Planning iOS App

3 ay boyunca geliştirdiğim seyahat planlama
uygulamasını tamamladım! 🎉

🎯 Problem: Seyahat planlamak zor...
💡 Çözüm: [Features listele]
🛠️ Teknolojiler: SwiftUI, Firebase, MapKit...
📚 Öğrendiklerim: [3-4 madde]
💰 Bonus: $0 bütçeyle geliştirildi!

🔗 GitHub: [link]
📹 Demo: [link]

#iOSDevelopment #SwiftUI #Firebase
```

---

## Cuma (4 saat): CV Update + Job Applications

### CV Update:
```markdown
## Projeler

### Routa - Travel Planning iOS App
*SwiftUI, Firebase, MapKit | Ekim 2024 - Ocak 2025*

• 16,000+ satır SwiftUI kodu
• MVVM + Repository pattern
• Firebase Free Tier optimization
• Unique features: Budget Calculator, Comparison
• Custom design system
• MapKit integration

GitHub: [link]
Demo: [link]
```

### İş Başvurusu:
- [ ] LinkedIn Jobs (10 başvuru)
- [ ] Kariyer.net (5 başvuru)
- [ ] AngelList (5 başvuru)
- [ ] Direct emails (5 başvuru)

**Hedef: 25 başvuru ilk haftada**

---

## 🎯 BAŞARI METRİKLERİ

### 6 Hafta Sonunda:

**Minimum:**
- [x] Proje tamamlandı
- [x] README + screenshots hazır
- [x] GitHub'da public
- [x] 5 iş başvurusu

**İdeal:**
- [ ] LinkedIn'de 20+ beğeni
- [ ] 3+ GitHub star
- [ ] 2+ mülakat daveti
- [ ] 1+ technical screen

**Hedef:**
- [ ] 10+ mülakat
- [ ] 2-3 iş teklifi
- [ ] 1 kabul
- [ ] 25-40K maaş

---

## 💰 MALİYET: 0₺

**Ücretsiz Araçlar:**
- ✅ Xcode (ücretsiz)
- ✅ Firebase Free Tier (50K reads/day)
- ✅ MapKit (ücretsiz)
- ✅ GitHub (ücretsiz)
- ✅ iMovie (ücretsiz)
- ✅ Canva Free (mockup)
- ✅ LottieFiles (animations)

**Toplam: $0** 🎉

---

## 📞 İLETİŞİM & NOTLAR

**Başlangıç Tarihi:** [Tarih ekle]
**Bitiş Hedefi:** [6 hafta sonrası]
**Weekly Check-in:** Her Pazar akşam progress review

**Motivasyon:**
> "Her 25 saat kod = İş teklifine 1 adım daha yakın!" 💪

---

## 🔄 İLERLEME TAKIBI

### Hafta 1: [ ] Tamamlandı
### Hafta 2: [ ] Tamamlandı
### Hafta 3: [ ] Tamamlandı
### Hafta 4: [ ] Tamamlandı
### Hafta 5: [ ] Tamamlandı
### Hafta 6: [ ] Tamamlandı

**Not:** Her hafta sonunda bu dosyayı güncelle!

---

*Son Güncelleme: [Bugünün tarihi]*
*Oluşturan: Claude Code Assistant*
