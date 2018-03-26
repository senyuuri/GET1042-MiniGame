// using iPhone 6/7's aspect ratio
int displayWidth = 1334;
int displayHeight = 750;
String imgBasePath = ".../img/";
int currentScene;
// initialise collection scene
PImage cBackground;
Star[] stars = new Star[10];


class Star{
	String name;
	int x, y, w, h;
  	boolean isLocked;
	boolean isMouseOver;
	PImage starImg, placeholderImg;
	StarBadge(String name, int x, int y, int w, int h, PImage starImage, PImage placeholderImg){
		name = name;
		x = x; 
		y = y;
		w = w;
		h = h;
		isLocked = true;
		isMouseOver = false;
		starImg = starImage;
		placeholderImg =  placeholderImg;
	}

	void draw(){
		if(isLocked){
			//TODO draw placeholder img
			ellipse(x, y, w, h);
		} else {
			image(starImg, x, y, w, h);
		}
	}

	void unlock(){
		isLocked = false;
	}

	void updateMouseOver(){
		float disX = x - mouseX;
		float disY = y - mouseY;
		if(sqrt(sq(disX) + sq(disY)) < diameter/2 )
			isMouseOver = true;
			println("Mouseover detected!");
			printInfo();
		} else {
			isMouseOver = false
		}
	}

	void printInfo(){
		println("[Star]"+name+":("+x+","+y+"), w:"+width+",h:"+height+",isLocked:"+isLocked+",isMouseOver:"+isMouseOver);
	}
}

void setup() {
  	size(displayWidth, displayHeight);
	background(0);
	smooth();
	// load collection scene resources
	cBackground = loadImage(imgBasePath + "sky canvas wo arrows.png");
	// load stars
}

void drawSceneCollection() {
	image(cBackground, 0, 0, displayWidth, displayHeight);
	// draw stars
	
	//
}

void drawSceneStarInfo(){

}

void drawSceneFactory(){

}


void draw() {
	drawSceneCollection();
}
