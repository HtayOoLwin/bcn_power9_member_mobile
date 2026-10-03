// Static English NRC township-code reference grouped by state/region number.
// Source reference: public Myanmar NRC township datasets. Values are normalized
// to uppercase and de-duplicated before being returned to the UI.

const Map<String, List<String>> _rawNrcTownshipCodes = {
  '1': [
    'AhGaYa','BaMaNa','DaHpaYa','HaPaNa','HpaKaNa','KaMaNa','KaMaTa','KaPaTa',
    'KhaHpaNa','KhaLaHpa','LaGaNa','MaKaNa','MaKaTa','MaKhaBa','MaLaNa','MaMaNa',
    'MaNyaNa','MaSaNa','NaMaNa','PaNaDa','PaTaAh','PaWaNa','SaBaNa','SaDaNa',
    'SaLaNa','SaPaBa','SaPaYa','TaNaNa','TaSaLa','WaMaNa','YaBaYa','YaKaNa',
  ],
  '2': [
    'BaLaKha','DaMaSa','HpaSaNa','HpaYaSa','LaKaNa','MaSaNa','YaTaNa','YaThaNa',
  ],
  '3': [
    'BaAhNa','BaGaLa','BaThaSa','HpaPaNa','KaDaNa','KaDaNa','KaDaTa','KaKaYa',
    'KaMaMa','KaSaKa','LaBaNa','LaThaNa','MaWaTa','PaKaNa','SaKaLa','ThaTaKa',
    'ThaTaNa','WaLaMa','YaYaTha',
  ],
  '4': [
    'HaKhaNa','HpaLaNa','HtaTaLa','KaKhaNa','KaPaLa','MaTaNa','MaTaPa','PaLaWa',
    'SaMaNa','TaTaNa','TaZaNa','YaKhaDa','YaZaNa',
  ],
  '5': [
    'AhTaNa','AhYaTa','BaMaNa','BaTaLa','DaPaYa','HaMaLa','HpaPaNa','HtaKhaNa',
    'KaBaLa','KaLaHta','KaLaNa','KaLaTa','KaLaWa','KaMaNa','KaNaNa','KaThaNa',
    'KhaOuNa','KhaOuTa','KhaPaNa','KhaTaNa','LaHaNa','LaYaNa','MaKaNa','MaLaNa',
    'MaMaNa','MaMaTa','MaYaNa','NaYaNa','NgaZaNa','PaLaBa','PaLaNa','SaKaNa',
    'SaLaKa','TaMaNa','TaSaNa','TaZaNa','WaLaNa','WaThaNa','YaBaNa','YaMaPa',
    'YaOuNa',
  ],
  '6': [
    'BaPaNa','HtaWaNa','KaLaAh','KaSaNa','KaThaNa','KaYaYa','KhaMaNa','LaLaNa',
    'MaAhYa','MaMaNa','MaTaNa','PaLaNa','PaLaTa','TaThaYa','ThaYaKha','YaHpaNa',
  ],
  '7': [
    'AhHpaNa','AhTaNa','DaOuNa','HpaMaNa','HtaTaPa','KaKaNa','KaPaKa','KaTaKha',
    'KaWaNa','LaPaTa','MaLaNa','MaNyaNa','NaTaLa','NyaLaPa','PaKhaNa','PaKhaTa',
    'PaMaNa','PaNaKa','PaTaNa','PaTaSa','PaTaTa','TaNgaNa','ThaKaNa','ThaNaPa',
    'ThaSaNa','ThaWaTa','WaMaNa','YaKaNa','YaTaNa','YaTaYa','ZaKaNa',
  ],
  '8': [
    'AhLaNa','GaGaNa','HtaLaNa','KaHtaNa','KaMaNa','KhaMaNa','MaBaNa','MaHtaNa',
    'MaHtaNa','MaKaNa','MaLaNa','MaMaNa','MaTaNa','MaTaNa','MaThaNa','NaMaNa',
    'NgaHpaNa','PaHpaNa','PaKhaKa','PaMaNa','SaHpaNa','SaLaNa','SaMaNa','SaPaWa',
    'SaTaYa','TaTaKa','ThaYaNa','YaNaKha','YaSaKa',
  ],
  '9': [
    'AhMaYa','AhMaZa','DaKhaTha','KaPaTa','KaSaNa','KhaAhZa','KhaMaSa','LaWaNa',
    'MaHaMa','MaHtaLa','MaKaNa','MaKhaNa','MaLaNa','MaMaNa','MaNaMa','MaNaTa',
    'MaTaYa','MaThaNa','MaYaMa','MaYaTa','NaHtaKa','NgaThaYa','NgaThaYa','NgaZaNa',
    'NyaOuNa','OuTaTha','PaBaNa','PaBaTha','PaKaKha','PaMaNa','PaOuLa','PaThaKa',
    'SaKaNa','SaKaTa','TaKaNa','TaKaNa','TaKaTa','TaTaOu','TaThaNa','ThaPaKa',
    'ThaSaNa','WaTaNa','YaMaTha','ZaBaTha','ZaYaTha',
  ],
  '10': [
    'BaLaNa','KaHtaNa','KaMaYa','KhaSaNa','KhaZaNa','LaMaNa','MaDaNa','MaLaMa',
    'PaMaNa','ThaHpaYa','ThaHtaNa','YaMaNa',
  ],
  '11': [
    'AhMaNa','BaThaTa','GaMaNa','KaHpaNa','KaTaLa','KaTaNa','MaAhNa','MaAhNa',
    'MaAhTa','MaOuNa','MaPaNa','MaPaTa','MaTaNa','PaNaKa','PaNaTa','PaTaNa',
    'SaTaNa','TaKaNa','TaPaWa','ThaTaNa','YaBaNa','YaThaTa',
  ],
  '12': [
    'AhLaNa','AhSaNa','BaHaNa','BaTaHta','DaGaMa','DaGaNa','DaGaSa','DaGaTa',
    'DaGaYa','DaLaNa','DaPaNa','HtaTaPa','KaKaKa','KaKhaKa','KaMaNa','KaMaTa',
    'KaMaYa','KaTaNa','KaTaTa','KhaYaNa','LaKaNa','LaMaNa','LaMaTa','LaThaNa',
    'LaThaYa','MaBaNa','MaGaDa','MaGaTa','MaYaKa','OuKaMa','OuKaNa','OuKaTa',
    'PaBaTa','PaZaTa','SaKaKha','SaKaNa','SaKhaNa','TaKaNa','TaMaNa','TaTaHta',
    'TaTaNa','ThaGaKa','ThaKaTa','ThaKhaNa','ThaLaNa','YaKaNa','YaPaTha',
  ],
  '13': [
    'AhKhaNa','AhTaNa','HaPaNa','HaPaTa','HaTaNa','HpaKhaNa','KaHaNa','KaKhaNa',
    'KaLaDa','KaLaHpa','KaLaNa','KaLaNa','KaLaTa','KaMaNa','KaMaSa','KaTaLa',
    'KaTaNa','KaTaTa','KaThaNa','KaYaNa','KhaLaNa','KhaMaNa','KhaYaHa','LaHaNa',
    'LaHtaNa','LaKaNa','LaKaNa','LaKaTa','LaKhaNa','LaKhaNa','LaKhaTa','LaLaNa',
    'LaYaNa','MaBaNa','MaBaNa','MaHaYa','MaHpaNa','MaHpaNa','MaKaNa','MaKaNa',
    'MaKhaNa','MaLaNa','MaMaNa','MaMaNa','MaMaNa','MaMaNa','MaMaSa','MaMaTa',
    'MaMaTa','MaNaNa','MaNgaNa','MaPaNa','MaPaNa','MaPaNa','MaSaNa','MaSaTa',
    'MaTaNa','MaTaNa','MaTaNa','MaTaTa','MaYaNa','MaYaNa','MaYaNa','MaYaTa',
    'NaHpaNa','NaKaNa','NaKhaNa','NaKhaNa','NaKhaTa','NaKhaTa','NaKhaWa','NaMaTa',
    'NaPhaNa','NaSaNa','NaSaNa','NaTaNa','NaTaYa','NaWaNa','NyaYaNa','PaKhaNa',
    'PaLaNa','PaLaTa','PaPaKa','PaSaNa','PaTaYa','PaWaNa','PaYaNa','SaHpaNa',
    'SaSaNa','TaKaNa','TaKhaLa','TaLaNa','TaMaNya','TaYaNa','ThaNaNa','ThaPaNa',
    'YaHpaNa','YaLaNa','YaNgaNa','YaSaNa',
  ],
  '14': [
    'AhGaPa','AhMaNa','AhMaTa','BaKaLa','DaDaYa','DaNaHpa','HaKaKa','HaThaTa',
    'HpaPaNa','KaKaHta','KaKaNa','KaKhaNa','KaLaNa','KaPaNa','LaMaNa','LaPaTa',
    'MaAhNa','MaAhPa','MaMaKa','MaMaNa','NgaPaTa','NgaSaNa','NgaThaKha','NgaThaYa',
    'NgaYaKa','NyaTaNa','PaSaLa','PaTaNa','PaThaNa','PaThaYa','ThaPaNa','WaKhaMa',
    'YaKaNa','YaThaYa','ZaLaNa',
  ],
};

List<String> nrcTownshipsForState(String stateCode) {
  final codes = _rawNrcTownshipCodes[stateCode] ?? const <String>[];
  final normalized = codes.map((code) => code.toUpperCase()).toSet().toList();
  normalized.sort();
  return List.unmodifiable(normalized);
}
