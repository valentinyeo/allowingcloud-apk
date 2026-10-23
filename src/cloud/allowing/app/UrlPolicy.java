package cloud.allowing.app;

final class UrlPolicy {
    static final String HOST = "appassets.androidplatform.net";

    static boolean isAppOrigin(String scheme, String host, int port) {
        return HOST.equals(host);
    }

    static boolean opensExternally(String scheme, String host, int port) {
        return !isAppOrigin(scheme, host, port);
    }
}
