import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/revenuecat_service.dart';
import '../../providers/pro_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  Offerings? _offerings;
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    final offerings = await RevenueCatService.getOfferings();
    setState(() {
      _offerings = offerings;
      if (offerings != null && offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // Default select annual or first package
        _selectedPackage = offerings.current!.availablePackages.firstWhere(
          (p) => p.packageType == PackageType.annual,
          orElse: () => offerings.current!.availablePackages.first,
        );
      }
      _isLoading = false;
    });
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;

    setState(() => _isPurchasing = true);
    final success = await RevenueCatService.purchasePackage(_selectedPackage!);
    setState(() => _isPurchasing = false);

    if (success) {
      await ref.read(proAccessProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tebrikler! Pro özelliklere artık erişebilirsiniz.")),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Satın alma tamamlanamadı. Lütfen tekrar deneyin.")),
        );
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    final success = await RevenueCatService.restorePurchases();
    setState(() => _isPurchasing = false);

    if (success) {
      await ref.read(proAccessProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Satın alımlarınız başarıyla geri yüklendi.")),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Geri yüklenecek bir satın alma bulunamadı.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF311B92),
              Color(0xFF1A237E),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative blurry blobs
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withOpacity(0.3),
                ),
              ).applyBlur(),
            ),
            SafeArea(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildBenefits(),
                          const SizedBox(height: 40),
                          if (_offerings != null && _offerings!.current != null)
                            ..._offerings!.current!.availablePackages.map(_buildPackageCard).toList()
                          else
                            const Text(
                              "Şu an için uygun paket bulunamadı.",
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 30),
                          _buildPurchaseButton(),
                          const SizedBox(height: 20),
                          _buildLegalLinks(),
                        ],
                      ),
                    ),
            ),
            if (_isPurchasing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amberAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
          ),
          child: const Text(
            "Sınav Sayacı PRO",
            style: TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Potansiyelinizi Açığa Çıkarın",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _buildBenefitRow("Sınırsız Sınav ve Deneme Takibi"),
              const SizedBox(height: 16),
              _buildBenefitRow("Tüm Premium Cam Temalar"),
              const SizedBox(height: 16),
              _buildBenefitRow("Reklamsız Deneyim"),
              const SizedBox(height: 16),
              _buildBenefitRow("Öncelikli Yeni Özellikler"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.greenAccent, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(Package package) {
    final isSelected = _selectedPackage?.identifier == package.identifier;
    final isAnnual = package.packageType == PackageType.annual;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.deepPurpleAccent.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.deepPurpleAccent : Colors.white.withOpacity(0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Selection Indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white54,
                            width: 2,
                          ),
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.deepPurpleAccent)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Package details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.storeProduct.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (package.storeProduct.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  package.storeProduct.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Price
                      Text(
                        package.storeProduct.priceString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isAnnual)
              Positioned(
                top: -12,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Text(
                    "En Popüler",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return ElevatedButton(
      onPressed: _selectedPackage == null || _isPurchasing ? null : _purchase,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: Colors.amberAccent,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        shadowColor: Colors.amberAccent.withOpacity(0.5),
      ),
      child: const Text(
        "Şimdi Pro'ya Geç",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: _restore,
          child: const Text(
            "Satın Almaları Yükle (Restore)",
            style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://example.com/terms')),
              child: const Text(
                "Kullanım Koşulları",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const Text(" • ", style: TextStyle(color: Colors.white54)),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse('https://docs.google.com/document/d/1Db7_A3KAjtkmroCn2NJqCiE_bn5Bj7zCtRnHi5sVZbo/edit?usp=sharing')),
              child: const Text(
                "Gizlilik Politikası",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        )
      ],
    );
  }
}

extension on Widget {
  Widget applyBlur() {
    return ImageFilter.blur(sigmaX: 50, sigmaY: 50).runtimeType == null 
       ? this
       : BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: this,
          );
  }
}
