PImage img;
int pointillize = 16;

void setup() {
 	// using iPhone 6/7's aspect ratio
	size(1334,750);
	// TODO load backgroud image
	img = loadImage("img/test.png");
	background(0);
	smooth();
}

void drawSceneCollection() {

}

void drawSceneStarInfo(){

}

void drawSceneFactory(){
	
}


void draw() {
	// Pick a random point
	int x = int(random(img.width));
	int y = int(random(img.height));
	int loc = x + y*img.width;
	
	// Look up the RGB color in the source image
	loadPixels();
	float r = red(img.pixels[loc]);
	float g = green(img.pixels[loc]);
	float b = blue(img.pixels[loc]);
	noStroke();
	
	// Draw an ellipse at that location with that color
	fill(r,g,b,100);
	ellipse(x,y,pointillize,pointillize);
}


