// using iPhone 6/7's aspect ratio
int displayWidth = 1334;
int displayHeight = 750;
String imgBasePath = "../img/";
String placeholderPath = imgBasePath + "blackhole.png";
int currentScene;
// initialise collection scene
PImage cBackground;
Star[] stars = new Star[10];


/* ======================================================
 * Object classes
 * ====================================================== 
 */
class Star{
	String name;
	int x, y, w, h;
  	boolean isLocked;
	boolean isMouseOver;
	PImage starImg, placeholderImg;
	Star(String name, int x, int y, int w, int h, PImage starImage, PImage placeholderImg){
		this.name = name;
		this.x = x; 
		this.y = y;
		this.w = w;
		this.h = h;
		this.isLocked = true;
		this.isMouseOver = false;
		this.starImg = starImage;
		this.placeholderImg =  placeholderImg;
		printInfo();
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
		if(sqrt(sq(disX) + sq(disY)) < width/2 ){
			isMouseOver = true;
			println("Mouseover detected!");
			printInfo();
		} else {
			isMouseOver = false;
		}
	}

	void printInfo(){
		println("[Star]"+name+":("+x+","+y+"), w:"+w+",h:"+h+",isLocked:"+isLocked+",isMouseOver:"+isMouseOver);
	}
}

/* ======================================================
 * Initialisation
 * ====================================================== 
 */
void setup() {
  	size(displayWidth, displayHeight);
	background(0);
	smooth();
	loadStars();
	// load collection scene resources
	cBackground = loadImage(imgBasePath + "sky canvas wo arrows.png");

}

void loadStars(){
	// load placeholder image
	//PImage placeholderImg = loadImage(placeholderPath);

	// load star information from file
	println("* Loading star objects......");
	String[] lines = loadStrings("data/starlist.txt");
	for (int i = 0 ; i < lines.length; i++) {
		if(!lines[i].contains("#")){
			String[] params = lines[i].split(",");
			println(params);
			PImage starImg = loadImage(imgBasePath + params[5]);
			int x = Integer.parseInt(params[1]);
			int y = Integer.parseInt(params[2]);
			int w = Integer.parseInt(params[3]);
			int h = Integer.parseInt(params[4]);
			stars[i] = new Star(params[0], x, y, w, h, starImg, starImg);
		}
	}
}


/* ======================================================
 * Draw functions 
 * ====================================================== 
 */
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
