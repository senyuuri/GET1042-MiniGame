import processing.sound.*;

// using iPhone 6/7's aspect ratio
int displayWidth = 1334;
int displayHeight = 750;
String imgBasePath = "../img/";
String placeholderPath = imgBasePath + "placeholder.png";
int currentScene = 0;
Star[] stars = new Star[20];
Star currentStar;
// initialise collection scene
PImage cBackground;
SoundFile hover;


/* ======================================================
 * Object classes
 * ====================================================== 
 */
class Star{
	float MAX_SCALE = 1.1;
	String name;
	// w, h: the actual width/height to be drawn
	// origW, origH: the original width/height
	// delta: amount of w/h change in 1 frame
	int x, y, w, h, origW, origH;
	float scalef = 1.03;
  	boolean isLocked;
	boolean isFXPlayed;
	PImage starImg, placeholderImg;
	Star(String name, int x, int y, int w, int h, PImage starImage, PImage placeholderImg){
		this.name = name;
		this.x = x; 
		this.y = y;
		this.w = w;
		this.h = h;
		this.origW = w;
		this.origH = h;
		// TODO change to true
		this.isLocked = true;
		this.starImg = starImage;
		this.isFXPlayed = false;
		this.placeholderImg =  placeholderImg;
		printInfo();
	}

	void draw(){
		// (x,y) are the left upper corner coordinates(CORNER mode)
		// Draw in CENTRE mode to allow scale animation
		pushMatrix();
		imageMode(CENTER);
		translate(w/2, h/2);
		
		if(isMouseOver()){
			if(w < origW * MAX_SCALE && currentScene == 0){
				w *= scalef;
				h *= scalef;
			}

			if(isLocked){
				image(placeholderImg, x, y, w, h);
				System.out.printf("%d %d %d %d\n", x, y, w, h);
			} else {
				image(starImg, x, y, w, h);
			}

			if(!isFXPlayed && currentScene == 0){
				hover.play();
				isFXPlayed = true;
			}
		}else{
			w = origW;
			h = origH;
			isFXPlayed = false;
			tint(90);
			if(isLocked){
				image(placeholderImg, x, y, w, h);
			} else {
				image(starImg, x, y, w, h);
			}
			noTint();
		}

		// show name
		fill(255);
		text(this.name, x, y+h/2+10, 100, 100);
		// imageMode(CORNER);
		popMatrix();
	}

	void unlock(){
		isLocked = false;
	}

	boolean isMouseOver(){
		if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h){
			return true;
		} else {
			return false;
		}
	}

	void printInfo(){
		println("[Star]"+name+":("+x+","+y+"), w:"+w+",h:"+h+",isLocked:"+isLocked+",isMouseOver:"+isMouseOver());
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
	frameRate(30);
	// load collection scene resources
	cBackground = loadImage(imgBasePath + "sky canvas wo arrows.png");
	hover = new SoundFile(this, "hover.mp3");

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
	imageMode(CORNER);
	background(0);
	//image(cBackground, 0, 0, displayWidth, displayHeight);
	// draw stars
	for(int i = 0; i < stars.length; i++){
		if(stars[i] != null){
			stars[i].draw();
		}
	}
}

void drawSceneStarInfo(){
	fill(128, 200);
	rect(0, 0, width, height);
	// draw message box
	fill(255);
	rect(420, 100, 480, 550, 15);
}

void drawSceneFactory(){

}


void draw() {
	if(currentScene == 0){
		drawSceneCollection();
	} else if (currentScene == 1){
		drawSceneCollection();
		drawSceneStarInfo();
	}
	
	// show fps
	fill(255);
	text(String.format("%.02f", frameRate) + " fps", 0, 0, 50, 50);
}

void mouseClicked() {
	if(currentScene == 0){
		boolean found = false;
		for(int i = 0; i < stars.length; i++){
			if(stars[i] != null && stars[i].isMouseOver()){
				found = true;
				currentStar = stars[i];
				break;
			}
		}
		// star clicked, show info box
		if(found){
			currentScene = 1;
		}
	}
	else if(currentScene == 1){
		if(mouseX<=420 || mouseY <= 100 || mouseX>=900 || mouseY>=650){
			currentScene = 0;
		}
	}
}
