#!/bin/bash

routes=$(cat routes.json | jq -c '.routes')

# url-router.js 생성
cat > url-router.js << EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    // 라우팅 규칙
    var routes = $routes;
    
    // 정의된 라우트가 있으면 해당 경로로 변환
    if (Object.prototype.hasOwnProperty.call(routes, uri)) {
        request.uri = routes[uri];
    }
    
    return request;
}
EOF

echo "url-router.js has been generated!"