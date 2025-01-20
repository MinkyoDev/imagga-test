function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    var routes = {
        "/": "/index.html",
        "/main": "/main.html",
        "/about": "/pages/about.html"
    };
    
    // routes에 정의된 경로가 있으면 그 경로로 변환
    if (routes.hasOwnProperty(uri)) {
        request.uri = routes[uri];
    }
    
    return request;
}