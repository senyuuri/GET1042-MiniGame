// using iPhone 6/7's aspect ratio
int displayWidth = 1334;
int displayHeight = 750;
String imgBasePath = "../img/";
String placeholderPath = imgBasePath + "placeholder.png";
int currentScene;
Star[] stars = new Star[20];
// initialise collection scene
PImage cBackground;



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
		// TODO change to true
		this.isLocked = true;
		this.isMouseOver = false;
		this.starImg = starImage;
		this.placeholderImg =  placeholderImg;
		printInfo();
	}

	void draw(){
		if(isLocked){
			tint(90);
			image(placeholderImg, x, y, w, h);
			noTint();
		} else {
			image(starImg, x, y, w, h);
		}
		
		// show name
		fill(255);
		text(this.name, x+35, y+h+10, 100, 100);
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
	PImage placeholderImg = loadImage(placeholderPath);

	// load star information from file
	println("* Loading star objects......");
	JSONObject values = loadJSONObject("data/config.json");
	JSONArray starlist = values.getJSONArray("starlist");
	for (int i = 0; i < starlist.size(); i++) {
		JSONObject star = starlist.getJSONObject(i); 
		String name = star.getString("name");
		int x = star.getInt("x");
		int y = star.getInt("y");
		int width = star.getInt("width");
		int height = star.getInt("height");
		PImage starImg = loadImage(imgBasePath + star.getString("imgPath"));
		stars[i] = new Star(name, x, y, width, height, starImg, placeholderImg);
	}
}


/* ======================================================
 * Draw functions 
 * ====================================================== 
 */
void drawSceneCollection() {
	image(cBackground, 0, 0, displayWidth, displayHeight);
	// draw stars
	for(int i = 0; i < stars.length; i++){
		if(stars[i] != null){
			stars[i].draw();
		}
	}
	//
}

void drawSceneStarInfo(){

}

void drawSceneFactory(){

}


void draw() {
	drawSceneCollection();
}
