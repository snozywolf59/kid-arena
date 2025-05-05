enum Subject {
  mathematics('Toán', '📊'),
  science('Khoa học', '🔬'),
  literature('Văn học', '📚'),
  history('Lịch sử', '🏛️'),
  foreignLanguage('Tiếng Anh', '🌐'),
  mixed('Tổng hợp', '🔍');


  final String displayName;
  final String emoji;

  const Subject(this.displayName, this.emoji);
}
