package cloud.allowing.app;

public class UrlPolicyTest {
    static int failures;

    static void check(String name, boolean actual, boolean expected) {
        if (actual != expected) {
            System.out.println("FAIL " + name);
            failures++;
        }
    }

    public static void main(String[] args) {
        check("A1", UrlPolicy.isAppOrigin("https", UrlPolicy.HOST, -1), true);
        check("A2", UrlPolicy.isAppOrigin("https", UrlPolicy.HOST, 443), true);
        check("A3", UrlPolicy.isAppOrigin("http", UrlPolicy.HOST, -1), false);
        check("A4", UrlPolicy.isAppOrigin("https", UrlPolicy.HOST, 8443), false);
        check("A5", UrlPolicy.isAppOrigin("file", UrlPolicy.HOST, -1), false);
        check("A6", UrlPolicy.isAppOrigin("https", "example.com", -1), false);
        check("A7", UrlPolicy.isAppOrigin(null, null, -1), false);
        check("E1", UrlPolicy.opensExternally("https", "example.com", -1), true);
        check("E2", UrlPolicy.opensExternally("HTTPS", "example.com", -1), true);
        check("E3", UrlPolicy.opensExternally("http", "example.com", -1), false);
        check("E4", UrlPolicy.opensExternally("intent", "example.com", -1), false);
        check("E5", UrlPolicy.opensExternally("file", null, -1), false);
        check("E6", UrlPolicy.opensExternally("javascript", null, -1), false);
        check("E7", UrlPolicy.opensExternally("content", "x", -1), false);
        check("E8", UrlPolicy.opensExternally("https", UrlPolicy.HOST, -1), false);
        check("E9", UrlPolicy.opensExternally(null, null, -1), false);
        if (failures > 0) {
            System.out.println(failures + " failed");
            System.exit(1);
        } else {
            System.out.println("all passed");
        }
    }
}
