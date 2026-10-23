package cloud.allowing.app;

final class UrlPolicy {
    static final String HOST = "appassets.androidplatform.net";

    static boolean isAppOrigin(String scheme, String host, int port) {
        return "https".equalsIgnoreCase(scheme) && HOST.equalsIgnoreCase(host) && (port == -1 || port == 443);
    }

    static boolean opensExternally(String scheme, String host, int port) {
        return "https".equalsIgnoreCase(scheme) && host != null && !isAppOrigin(scheme, host, port);
    }
}
