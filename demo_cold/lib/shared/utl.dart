String utlTrimLeft(String content, String trim) {
  if (content == null) {
    return null;
  }
  return content.startsWith(trim) ? content.substring(trim.length) : content;
}
