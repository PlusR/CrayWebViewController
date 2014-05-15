//
// Created by azu on 2013/06/28.
//


#import "CrayTabWebViewController.h"
#import "NJKWebViewProgressView.h"

@interface CrayTabWebViewController ()
@property(nonatomic, strong) NJKWebViewProgress *progressProxy;
@property(nonatomic, strong) NJKWebViewProgressView *progressView;
@property(weak, nonatomic) IBOutlet UIWebView *contentWebView;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *backWebViewButton;

- (IBAction)handleBackButton:(id) sender;
@end

@implementation CrayTabWebViewController

- (void)goToAddress:(NSString *) URL {
    NSURL *url = [NSURL URLWithString:URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.contentWebView loadRequest:request];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressProxy = [[NJKWebViewProgress alloc] init];
    self.contentWebView.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;

    CGFloat progressBarHeight = 2.5f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight,
        navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];

    [self goToAddress:self.URL];
}

- (void)webViewDidStartLoad:(UIWebView *) webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *) webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.backWebViewButton.enabled = self.contentWebView.canGoBack;
}

- (BOOL)webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
    NSURL *requestURL = request.URL;
    NSString *scheme = requestURL.scheme;
    if (![scheme isEqual:@"http"] && ![scheme isEqual:@"https"] && ![scheme isEqual:@"file"]) {
        if ([[UIApplication sharedApplication] canOpenURL:requestURL]) {
            [[UIApplication sharedApplication] openURL:requestURL];
            return NO;
        }
    }
    return YES;
}

- (IBAction)handleBackButton:(id) sender {
    if ([self.contentWebView canGoBack]) {
        [self.contentWebView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
}
#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *) webViewProgress updateProgress:(float) progress {
    [self.progressView setProgress:progress animated:YES];
    self.navigationItem.title = [self.contentWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
@end