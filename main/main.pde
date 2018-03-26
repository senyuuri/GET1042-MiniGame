import processing.sound.*;

// using iPhone 6/7's aspect ratio
int displayWidth = 1334;
int displayHeight = 750;
String imgBasePath = "../img/";
String placeholderPath = imgBasePath + "placeholder.png";
int currentScene = 0;
Star[] stars = new Star[20];
Star currentStar;
// JSON values from config.json
JSONObject values;
// initialise collection scene
PImage cBackground;
SoundFile hover;
// initialise info scene



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
	int mass[], magnitude[], volume[], temperature[];
	String ccolor;
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
		this.isLocked = false;
		this.starImg = starImage;
		this.isFXPlayed = false;
		this.placeholderImg =  placeholderImg;
		this.mass = new int[2];
		this.magnitude = new int[2];
		this.volume = new int[2];
		this.temperature = new int[2];
		this.ccolor = "";
		printInfo();
	}

	void setMass(JSONArray raw){
		this.mass[0] = raw.getInt(0);
		this.mass[1] = raw.getInt(1);
	}

	void setMagnitude(JSONArray raw){
		this.magnitude[0] = raw.getInt(0);
		this.magnitude[1] = raw.getInt(1);
	}

	void setVolume(JSONArray raw){
		this.volume[0] = raw.getInt(0);
		this.volume[1] = raw.getInt(1);
	}

	void setTemperature(JSONArray raw){
		this.temperature[0] = raw.getInt(0);
		this.temperature[1] = raw.getInt(1);
	}

	void setColor(String ccolor){
		this.ccolor = ccolor;
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
			
			if(isLocked){
				tint(90);
				image(placeholderImg, x, y, w, h);
				noTint();
			} else {
				image(starImg, x, y, w, h);
			}
			
		}

		// show name
		textSize(13);
		fill(255);
		text(this.name, x, y+h/2+10, 100, 100);
		// imageMode(CORNER);
		popMatrix();
	}

	void drawAt(int xx, int yy, int ww, int hh){
		if(isLocked){
			image(this.placeholderImg, xx, yy, ww, hh);
		} else{
			image(this.starImg, xx, yy, ww, hh);
		}
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
	cBackground = loadImage(imgBasePath + "sky_canvas_preview.png");
	hover = new SoundFile(this, "hover.mp3");

}

void loadStars(){
	// load placeholder image
	PImage placeholderImg = loadImage(placeholderPath);

	// load star information from file
	println("* Loading star objects......");
	values = loadJSONObject("data/config.json");
	JSONArray starlist = values.getJSONArray("starlist");
	for (int i = 0; i < starlist.size(); i++) {
		JSONObject star = starlist.getJSONObject(i); 
		String name = star.getString("name");
		int x = star.getInt("x");
		int y = star.getInt("y");
		int width = star.getInt("width");
		int height = star.getInt("height");
		PImage starImg = loadImage(imgBasePath + star.getString("imgPath"));
		// create new star
		stars[i] = new Star(name, x, y, width, height, starImg, placeholderImg);
		stars[i].setMass(star.getJSONArray("mass"));
		stars[i].setMagnitude(star.getJSONArray("magnitude"));
		stars[i].setVolume(star.getJSONArray("volume"));
		stars[i].setTemperature(star.getJSONArray("temperature"));
		stars[i].setColor(star.getString("color"));
	}
}


/* ======================================================
 * Draw functions 
 * ====================================================== 
 */
void drawSceneCollection() {
	imageMode(CORNER);
	background(0);
	image(cBackground, 0, 0, displayWidth, displayHeight);
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
	fill(36, 60, 104);
	strokeWeight(1); 
	stroke(0, 201, 211);
	rect(420, 100, 480, 390, 15);
	if(currentStar == null){
		return;
	}
	// draw star
	currentStar.drawAt(450, 130, 150, 150);
	fill(255);
	textSize(30);
	text(currentStar.name, 550, 145, 350, 100); 
	
	// draw progress bar
	drawProgressBar("Mass", 450, 210, 0, 1000, 800, color(251, 190, 71));
	drawProgressBar("Magnitude", 450, 250, 0, 1000, 400, color(242, 120, 79));
	drawProgressBar("Radius", 450, 290, 0, 1000, 500, color(219, 94, 92));
	drawProgressBar("Temperature", 450, 330, 0, 1000, 200, color(253, 215, 104));
	drawProgressBar("Color", 450, 370, 0, 1000, 1000, color(229, 117, 42));
	// draw button
	if (mouseX >= 450 && mouseX <= 860 && mouseY >= 415 && mouseY <= 465) {
		fill(209, 211, 212);
	} else {
		fill(255, 255, 255);
	}
	stroke(0);
	rect(450, 415, 410, 50, 10);
}

void drawProgressBar(String name, int x, int y, int min, int max, int value, color c){
	fill(255);
	textSize(13);
	text(name, x, y, 100, 50);
	noStroke();
	fill(255);
	rect(x+100, y, 310, 20, 5);
	fill(c);
	rect(x+100, y, 310 * (1.0f * value/max), 20, 5);	
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
	textSize(12);
	fill(255);
	text(String.format("%.02f", frameRate) + " fps", 0, 0, 70, 15);
	text(mouseX+","+mouseY, 0, 15, 70, 15);
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
