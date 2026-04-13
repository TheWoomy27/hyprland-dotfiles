#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float timex2;
    float sizeW;
    float maxSizeW;
    float isPlaying;
    float excludedRadius;
};

float f(float x) {
    float t1 = 0.03;
    float t2 = 1.03;
    float r = smoothstep(t2, t1, x) * smoothstep(t1, t2, x);

    float n = sizeW / max(maxSizeW, 1.0);
    float A = min(max(1.2, 2.0 * n), 1.7) * isPlaying;
    float b = max(1.2, 9.0 * n);
    float tmp = A * sin((b * x - time));

    return r * tmp * tmp;
}

float f2(float x) {
    float t1 = 0.1;
    float t2 = 1.0;
    float r = smoothstep(t2, t1, x) * smoothstep(t1, t2, x);

    float n = sizeW / max(maxSizeW, 1.0);
    float A = min(1.3, 4.0 * n) * isPlaying;
    float b = max(1.0, 9.6 * n);
    float tmp = A * sin((b * x - timex2));

    return r * tmp * tmp;
}

void main() {
    vec2 uv = qt_TexCoord0;
    uv.y = 1.0 - uv.y;
    uv.y += 0.08;

    float y = f(uv.x);
    float y2 = f2(uv.x);
    float edge = excludedRadius / max(maxSizeW, 1.0);
    float exclude = step(edge, uv.x) * step(uv.x, 1.0 - edge);

    float sin1 = smoothstep(y, y + 0.18, uv.y);
    float sin2 = smoothstep(y2, y2 + 0.18, uv.y);
    vec4 col = vec4(0.0);

    col = mix(vec4(0.48627450980392156, 0.6862745098039216, 1.0, 0.72), col, sin2);
    col = mix(vec4(0.23137254901960785, 0.38823529411764707, 0.8117647058823529, 0.42), col, sin1);

    fragColor = col * qt_Opacity * exclude;
}
