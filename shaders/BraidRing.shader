shader_type canvas_item;

//position of the ring: (0,5,0,5) -> middle of screen
uniform vec2 pos = vec2(0.1, 0.1);

//size of the ring: à -> invisible, 0.5 -> diameter of screen
uniform float circleSize: hint_range(0,0.5);



//give te resolution of the screen, to calculate ratio
uniform vec2 screenResolution = vec2(800, 1000);

// the speed at which the ring and zoom effect pulsates 
uniform float frequency : hint_range(20, 200, 10);

// the size of each luminosity pulsation of the outer part. smaller -> more visible 
uniform float pulsationSize : hint_range(0, 1, 0.001);

//the speed at which the zoom effet dcreases with the distance of the ring
uniform float depth : hint_range(0, 0.3, 0.01);

//the amount of zoom the ring and wave effect produce. 0 -> invisible, 10 -> drunken
uniform float zoomPower : hint_range(0, 3, 0.01);

//the amount of increase of the ring size wile pulsating.
uniform float pulsePercent: hint_range(0,1);

//percentage of the circle that is a light border. 0 -> circle all white, 1-> no border
uniform float borderLimit = 0.85;

//luminosity of light pulse
uniform float ringLuminosity : hint_range(0,1);

//background shade of the ring circle. set the alpha for a nice result
uniform vec4 ringColor : hint_color;

//a background texture for the ring circle 
uniform sampler2D stainsTex;


float smoothSin(float x)
{
	return (sin(x) / 2.0) + 0.5;
}

mat2 rotate2d(float _angle, vec2 ratio){
    return mat2(vec2(cos(_angle),-sin(_angle)) * ratio.x,
                vec2(sin(_angle),cos(_angle)) * ratio.y);
}


void fragment() {
	vec2 ratio = screenResolution / min(screenResolution.x, screenResolution.y);
	vec2 uv = SCREEN_UV;

	//distance to center of ring
	float dist = distance(pos * ratio, uv * ratio);
	float invDist = clamp((1.0 /  log(1.0 + dist) - depth), -100.0, 1000.0);

	//frequence of radial effects (zoom, luminosity wave)
	float pulse = sin(TIME)  * frequency / 2000.0;
	float ringExpansion = pulse * pulsePercent;

	//ok, invdist * dist is maybe unecessary, but it doesn't work without :/
	float outerRimModifier = cos(max(dist - circleSize, 0.0) * 50.0 * invDist);	
	float zoom =  pulse * invDist * zoomPower * dist * outerRimModifier;

	//angle of point to the center of ring
	vec2 deltaTexCoord = uv - pos;
	float angle = atan(deltaTexCoord.y, deltaTexCoord.x);

	//zoom from the center of the ring
	uv.x -= (cos(angle) * zoom);
	uv.y -= (sin(angle) * zoom);
	vec4 c = textureLod(SCREEN_TEXTURE, uv, 0.0);
	

	//circle of ring
	if (dist + pulse * ringExpansion < circleSize) {
		//rotation of dots in clockwise / reverse-clockwise way
		float rotationWay = sign(sin(dist * 500.0));
		//rotationWay = 1.0;	

		//rotation of circle
		vec2 st = SCREEN_UV; 
		st -= pos;		
    	st = rotate2d(TIME * rotationWay / 10.0, ratio)* st;
		st += pos;
		
		//keep same texture size no matter the size of the ring
		float scaleStain = 1.0 / ((circleSize - pulse * ringExpansion)*2.0);
		
		//get stain texture
		vec4 stain = textureLod(stainsTex, (vec2(0.5) - pos * scaleStain) + st * scaleStain, 0.0);

		//color the inner circle with the stain color	
		float opacity = (stain.r * ringColor.a);
			
		c.rgb = c.rgb * (1.0 - opacity) + ringColor.rgb * (stain.r * opacity);
		c.rgb *= 1.1;
		//outer border of ring is brighter
		if (dist + pulse * ringExpansion > borderLimit * circleSize)
			c.rgb *= 2.0;
	}
	//luminosity light ring wave
	else
	{ 
		//when moving the center of ring, the wave does not move with it
		float distToOrig = distance(vec2(0), pos * ratio);
		
		//50 = pulsation size
		float ringPers = (smoothSin(pulsationSize * (dist - distToOrig) - TIME * (frequency / 10.0))) * ringLuminosity;
		c.rgb *= 1.0 + ringPers;
	}
	COLOR.rgb = c.rgb;
}
