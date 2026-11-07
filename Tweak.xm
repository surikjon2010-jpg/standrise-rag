#import <Foundation/Foundation.h>
#import <substrate.h>
#import <objc/runtime.h>

// Хукаем отправку данных
NSURLSessionDataTask* (*orig_dataTaskWithRequest)(id, SEL, NSURLRequest*, void (^)(NSData*, NSURLResponse*, NSError*));

NSURLSessionDataTask* my_dataTaskWithRequest(id self, SEL _cmd, NSURLRequest *request, void (^completionHandler)(NSData*, NSURLResponse*, NSError*)) {
    
    // Если это запрос от чита к их серверу
    if (request.URL.absoluteString.length > 0) {
        NSLog(@"[Bypass] Перехвачен запрос: %@", request.URL.absoluteString);
        
        // Возвращаем фейковый ответ, чтобы триал был вечным
        NSData *fakeData = [@"{\"status\":\"success\",\"trial\":true,\"expire\":9999999999}" dataUsingEncoding:NSUTF8StringEncoding];
        NSHTTPURLResponse *fakeResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
        
        // Вызываем completionHandler, чтобы игра думала, что сервер ответил
        if (completionHandler) {
            completionHandler(fakeData, fakeResponse, nil);
        }
        
        // Возвращаем пустую задачу (заглушку)
        NSURLSessionDataTask *task = orig_dataTaskWithRequest(self, _cmd, request, completionHandler);
        return task;
    }
    
    return orig_dataTaskWithRequest(self, _cmd, request, completionHandler);
}

__attribute__((constructor))
static void init() {
    // Перехватываем стандартный метод отправки запросов
    MSHookMessageEx(objc_getClass("NSURLSession"), @selector(dataTaskWithRequest:completionHandler:), (IMP)&my_dataTaskWithRequest, (IMP*)&orig_dataTaskWithRequest);
}
