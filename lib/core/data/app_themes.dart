import 'package:flutter/material.dart';
import '../models/app_theme_model.dart';

class AppThemeCatalog {
  static const List<AppThemeModel> themes = [
    // 1 — Varsayılan, kilitli değil
    AppThemeModel(
      id: 'uzay_boslugu',
      name: 'Uzay Boşluğu',
      description: 'Derin lacivert arkaplan, mistik leylak vurgular',
      isUnlocked: true,
      surface: Color(0xFF0B1326),
      surfaceBright: Color(0xFF31394D),
      onSurface: Color(0xFFDAE2FD),
      primary: Color(0xFFD0BCFF),
      secondary: Color(0xFFADC6FF),
      tertiary: Color(0xFFFFAFD3),
      outline: Color(0xFF958EA0),
      previewGradient: [Color(0xFF0B1326), Color(0xFF1A1F3A), Color(0xFF6B21A8)],
    ),

    // 2
    AppThemeModel(
      id: 'kizil_safak',
      name: 'Kızıl Şafak',
      description: 'Koyu kırmızı tonlar, ateşli turuncu vurgular',
      isUnlocked: false,
      surface: Color(0xFF1A0A0A),
      surfaceBright: Color(0xFF3D1515),
      onSurface: Color(0xFFFFD9D9),
      primary: Color(0xFFFF8A80),
      secondary: Color(0xFFFFB74D),
      tertiary: Color(0xFFFF6E40),
      outline: Color(0xFF8D4040),
      previewGradient: [Color(0xFF1A0A0A), Color(0xFF3D1515), Color(0xFFB71C1C)],
    ),

    // 3
    AppThemeModel(
      id: 'okyanus_derinligi',
      name: 'Okyanus Derinliği',
      description: 'Koyu teal derinliği, su yeşili parıltılar',
      isUnlocked: false,
      surface: Color(0xFF041E2B),
      surfaceBright: Color(0xFF0D3347),
      onSurface: Color(0xFFB2EBF2),
      primary: Color(0xFF80DEEA),
      secondary: Color(0xFF80CBC4),
      tertiary: Color(0xFFA5D6A7),
      outline: Color(0xFF37747A),
      previewGradient: [Color(0xFF041E2B), Color(0xFF0D3347), Color(0xFF006064)],
    ),

    // 4
    AppThemeModel(
      id: 'orman_gecesi',
      name: 'Orman Gecesi',
      description: 'Koyu orman yeşili, nane ve yaprak tonları',
      isUnlocked: false,
      surface: Color(0xFF071A0E),
      surfaceBright: Color(0xFF133320),
      onSurface: Color(0xFFC8E6C9),
      primary: Color(0xFFA5D6A7),
      secondary: Color(0xFF80CBC4),
      tertiary: Color(0xFFFFF9C4),
      outline: Color(0xFF3E7046),
      previewGradient: [Color(0xFF071A0E), Color(0xFF133320), Color(0xFF1B5E20)],
    ),

    // 5
    AppThemeModel(
      id: 'gun_batimi',
      name: 'Gün Batımı',
      description: 'Koyu turuncu-mor karışımı, sıcak sarı tonlar',
      isUnlocked: false,
      surface: Color(0xFF1A0F00),
      surfaceBright: Color(0xFF3E2200),
      onSurface: Color(0xFFFFE0B2),
      primary: Color(0xFFFFCC80),
      secondary: Color(0xFFFFAB40),
      tertiary: Color(0xFFFF7043),
      outline: Color(0xFF8D5524),
      previewGradient: [Color(0xFF1A0F00), Color(0xFF7B2D00), Color(0xFFFF6D00)],
    ),

    // 6
    AppThemeModel(
      id: 'buz_firtinasi',
      name: 'Buz Fırtınası',
      description: 'Derin lacivert, parlak buz mavisi yansımalar',
      isUnlocked: false,
      surface: Color(0xFF020B18),
      surfaceBright: Color(0xFF0D2137),
      onSurface: Color(0xFFE3F2FD),
      primary: Color(0xFF82B1FF),
      secondary: Color(0xFF80D8FF),
      tertiary: Color(0xFFEA80FC),
      outline: Color(0xFF2D5B8A),
      previewGradient: [Color(0xFF020B18), Color(0xFF0D2137), Color(0xFF01579B)],
    ),

    // 7
    AppThemeModel(
      id: 'altin_cag',
      name: 'Altın Çağ',
      description: 'Koyu amber zemin, saf altın parıltıları',
      isUnlocked: false,
      surface: Color(0xFF1A1200),
      surfaceBright: Color(0xFF3D2B00),
      onSurface: Color(0xFFFFF8E1),
      primary: Color(0xFFFFD54F),
      secondary: Color(0xFFFFCA28),
      tertiary: Color(0xFFFFA726),
      outline: Color(0xFF7A5800),
      previewGradient: [Color(0xFF1A1200), Color(0xFF3D2B00), Color(0xFFF57F17)],
    ),

    // 8
    AppThemeModel(
      id: 'pembe_bulut',
      name: 'Pembe Bulut',
      description: 'Koyu mauve atmosfer, yumuşak pembe tonlar',
      isUnlocked: false,
      surface: Color(0xFF1A0D14),
      surfaceBright: Color(0xFF3D1F32),
      onSurface: Color(0xFFFCE4EC),
      primary: Color(0xFFF48FB1),
      secondary: Color(0xFFCE93D8),
      tertiary: Color(0xFFF8BBD0),
      outline: Color(0xFF7B3F5E),
      previewGradient: [Color(0xFF1A0D14), Color(0xFF3D1F32), Color(0xFFAD1457)],
    ),
  ];

  static AppThemeModel get defaultTheme => themes.first;

  static AppThemeModel findById(String id) {
    return themes.firstWhere(
      (t) => t.id == id,
      orElse: () => defaultTheme,
    );
  }
}
