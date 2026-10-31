package com.codequest.util;

/**
 * Small helper used by JSP scriptlets to safely print text
 * (prevents HTML / script injection from user input).
 */
public class HtmlUtil {

    private HtmlUtil() {
    }

    public static String escape(Object value) {
        if (value == null) {
            return "";
        }
        String s = value.toString();
        StringBuilder sb = new StringBuilder(s.length());
        for (char c : s.toCharArray()) {
            switch (c) {
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '&': sb.append("&amp;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#39;"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }
}
