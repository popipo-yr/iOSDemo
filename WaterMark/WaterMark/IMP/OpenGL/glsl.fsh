precision mediump float;

uniform sampler2D bg_t;
uniform sampler2D text_t;

uniform vec4 textRange;
uniform vec2 bgSize;

varying vec2 vc2_coords;

void main (void) {
    vec4 originSample = texture2D(bg_t, vc2_coords);
    
    float bgWidth = bgSize[0];
    float bgHeight = bgSize[1];
    
    float offsetX_text = textRange[0];
    float offsetY_text = textRange[1];
    float textWidth = textRange[2];
    float textHeight = textRange[3];

    float x = vc2_coords.x * bgWidth;
    float y = vc2_coords.y * bgHeight;
    //不在文字纹理范围直接返回原始样本
    if ( x  < offsetX_text
        || x > (offsetY_text + textWidth)
        || y > (bgHeight - offsetY_text)
        || y < (bgHeight - (offsetY_text + textHeight)) ) {
        // 返回原图对应像素点色值
        gl_FragColor = vec4(originSample.rgb, 1.0);
        return;
    }
    
    //转换坐标到文字纹理
    float textX = (vc2_coords.x * bgWidth - offsetX_text) / textWidth;
    float textY = (vc2_coords.y * bgHeight - bgHeight + offsetY_text + textHeight) / textHeight;
    
    vec2 textPoint = vec2(textX, textY);
    
    vec4 textSample = texture2D(text_t, textPoint);
    
    //文字纹理处无颜色值直接返回原始样本
    if(textSample.a == 0.0)
    {
        gl_FragColor = vec4(originSample.rgb, 1.0);
        return;
    }
    
    //获取亮度
    float b_hsb = max( max(originSample.r, originSample.g), originSample.b);
    bool isLight = b_hsb > 0.5;
    
    //通过亮度进行颜色反转
    if(isLight){
        //浅色变黑
        gl_FragColor = vec4(0, 0, 0, 1.0);
        
    }else{
        //深色变白
        gl_FragColor = vec4(1, 1, 1, 1.0);
    }
}


