class ErrorMessageHelper {
  static String getErrorMessage(String error) {
    if (error.contains('Failed host lookup') ||
        error.contains('No address associated with hostname')) {
      return 'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.';
    }

    if (error.contains('Connection timed out') || error.contains('timeout')) {
      return 'Koneksi timeout. Coba lagi dalam beberapa saat.';
    }

    if (error.contains('Connection refused') ||
        error.contains('Connection failed')) {
      return 'Gagal terhubung ke server. Coba lagi nanti.';
    }

    if (error.contains('404')) {
      return 'Data tidak ditemukan.';
    }

    if (error.contains('500') ||
        error.contains('502') ||
        error.contains('503')) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }

    if (error.contains('Failed to load restaurant list')) {
      return 'Gagal memuat daftar restoran. Periksa koneksi internet Anda.';
    }

    if (error.contains('Failed to search restaurants')) {
      return 'Gagal mencari restoran. Coba kata kunci yang berbeda.';
    }

    if (error.contains('Failed to load restaurant detail')) {
      return 'Gagal memuat detail restoran. Coba lagi nanti.';
    }

    if (error.contains('Failed to add review')) {
      return 'Gagal menambahkan review. Coba lagi nanti.';
    }

    return 'Terjadi kesalahan. Coba lagi nanti.';
  }

  static String getEmptyStateMessage(String? searchQuery) {
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return 'Tidak ditemukan restoran dengan kata kunci "$searchQuery"';
    }
    return 'Belum ada restoran tersedia';
  }
}
