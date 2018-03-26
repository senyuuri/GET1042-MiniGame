int currentScene;
PShape cbackground;


void setup() {
 	// using iPhone 6/7's aspect ratio
	size(1334,750);
	// TODO load backgroud image
	// img = loadImage("img/test.png");
	background(0);
	currentScene = 4
	drawSceneFactory();
	cbackground = loadShape("/img/type_two_supernova.svg");
}

void drawSceneCollection() {

}

void drawSceneStarInfo(){

}

void drawSceneFactory(){
	shape(cbackground,10,10,300,300);
}


void draw() {
	shape(cbackground,10,10);
}

void mouseClicked(){
	if (currentScene === 4) {
    }
}
