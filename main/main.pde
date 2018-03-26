// using iPhone 6/7's aspect ratio
int displayWidth = 1334;
int displayHeight = 750;
int currentScene;
PShape cBackground;

void setup() {
  	size(displayWidth, displayHeight);
	background(0);
	smooth();
	// load collection scene resources
	cBackground = loadShape("../img/sky canvas wo arrows.svg");
}

void drawSceneCollection() {
	shape(cBackground, 0, 0, displayWidth, displayHeight);
}

void drawSceneStarInfo(){

}

void drawSceneFactory(){

}


void draw() {
	drawSceneCollection();
}
