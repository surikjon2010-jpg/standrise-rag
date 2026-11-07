#import <Foundation/Foundation.h>
#import <substrate.h>
#import <objc/runtime.h>

NSURLSessionDataTask* (*orig_dataTaskWithRequest)(id, SEL, NSURLRequest*, void (^)(NSData*, NSURLResponse*, NSError*));

NSURLSessionDataTask* my_dataTaskWithRequest(id self, SEL _cmd, NSURLRequest *request, void (^completionHandler)(NSData*, NSURLResponse*, NSError*)) {
    
    NSString *urlStr = request.URL.absoluteString;
    
    // Проверяем, похож ли запрос на проверку триала
    if ([urlStr containsString:@"trial"] || [urlStr containsString:@"check"] || [urlStr containsString:@"api"] || [urlStr containsString:@"lstrial"]) {
        NSLog(@"[Bypass] Заблокирован запрос: %@", urlStr);
        
        // Отдаем фейковый ответ
        NSData *fakeData = [@"{\"status\":\"success\",\"trial\":true,\"expire\":9999999999}" dataUsingEncoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *fakeResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
        
        if (completionHandler) {
            completionHandler(fakeData, fakeResponse, nil);
        }
        return nil;
    }
    
    // Все остальные запросы (игровые) пропускаем
    return orig_dataTaskWithRequest(self, _cmd, request, completionHandler);
}

__attribute__((constructor))
static void init() {
    MSHookMessageEx(objc_getClass("NSURLSession"), @selector(dataTaskWithRequest:completionHandler:), (IMP)&my_dataTaskWithRequest, (IMP*)&orig_dataTaskWithRequest);
}
