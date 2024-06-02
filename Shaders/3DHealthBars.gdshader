shader_type spatial;
render_mode blend_mix,depth_draw_opaque,
cull_back,diffuse_toon,specular_disabled,
shadows_disabled,unshaded,
depth_test_disabled;

uniform sampler2D bar_texture_base : source_color,filter_linear_mipmap,repeat_disable;
uniform sampler2D bar_texture_alpha : source_color,filter_linear_mipmap,repeat_disable;
uniform vec3 bar_color : source_color;
uniform vec3 bar_empty_color : source_color;

uniform float progress:hint_range(0.0, 1.0, 0.01);

void vertex() {
	// Billboard Effect
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0],
		INV_VIEW_MATRIX[1],
		INV_VIEW_MATRIX[2],
		MODEL_MATRIX[3]);
	
	// Fixed Size Effect
	//float sc = -(MODELVIEW_MATRIX)[3].z;
	//MODELVIEW_MATRIX[0]*=sc;
	//MODELVIEW_MATRIX[1]*=sc;
	//MODELVIEW_MATRIX[2]*=sc;
}

void fragment() {
	float progress_texture = smoothstep(-progress,-progress + 0.05,-UV.x);
	ALBEDO = texture(bar_texture_base,UV).rgb * mix(bar_color,bar_empty_color, clamp(1.5 + -progress * 2.5,0,1)) * progress_texture;
	ALPHA = texture(bar_texture_alpha,UV).a;
}
