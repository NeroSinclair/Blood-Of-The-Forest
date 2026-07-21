shader_type canvas_item;

// Mengambil tekstur layar di belakang node ini
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// Variabel untuk mengontrol kekuatan blur, bisa diatur lewat Inspector nanti
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    // Mengambil warna dari tekstur layar dengan level mipmap tertentu untuk efek blur
    COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);

    // Opsional: Untuk sedikit menggelapkan lagi lewat shader
    // COLOR.rgb *= 0.8; // Mengalikan warna RGB dengan 0.8 (lebih gelap)
}