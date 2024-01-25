extension StringUtils on String {
  String removeTrailingZero() {
    if (!this.contains('.')) {
      return this;
    }
    var newString = this.replaceAll(RegExp(r'0*$'), '');
    if (newString.endsWith('.')) {
      newString = newString.substring(0, newString.length - 1);
    }
    return newString;
  }
}
