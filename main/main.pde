import processing.sound.*;
import java.util.Random;

// DEBUG mode for factory scene
// currentScene is ignored and is always set to 4 
boolean DEBUG_FACTORY = false;

// using iPhone 6/7's aspect ratio
int displayWidth = 1334;
int displayHeight = 750;
String imgBasePath = "../img/";
String placeholderPath = imgBasePath + "placeholder.png";
int currentScene = 0;
BgStar[] bgstars = new BgStar[100];
Star[] stars = new Star[20];
Star currentStar;
Random rand = new Random();
// JSON values from config.json
JSONObject values;
// initialise collection scene
PImage cBackground;
SoundFile hover;
SoundFile bgm;
// initialise info scene

// initialise factory scene
Machine[] m = new Machine[5];
int selected = -1;
int current = -1;
int[] deg = {0, 0, 0, 0, 0};
int speed = 0;
int dir = -1;
int rdir = -1;
int[] chance = {3, 3, 3, 3, 3};
float[] value = {-100, -100, -100, -100, -100};
PImage[] image= new PImage[6];
PImage[] scale = new PImage[5];
PImage factoryimg;
PImage pointerimg;

// Since enum doesn't work out-of-box in processing, 
// use static abstract class as a hack
static abstract class State {
  static final int STARTER = 0;
  static final int LOCKED = 1;
  static final int UNLOCKED = 2;
  static final int CLEAR = 3;
}

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
	boolean isFXPlayed;
	PImage starImg, placeholderImg;
	int state;

	Star(String name, int x, int y, int w, int h, PImage starImage, PImage placeholderImg, int state){
		this.name = name;
		this.x = x; 
		this.y = y;
		this.w = w;
		this.h = h;
		this.origW = w;
		this.origH = h;
		this.state = state;
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

			if(this.state == State.UNLOCKED || this.state == State.LOCKED){
				image(placeholderImg, x, y, w, h);
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
			
			if(this.state == State.LOCKED){
				tint(90);
				image(placeholderImg, x, y, w, h);
				noTint();
			} else if(this.state == State.UNLOCKED){
				image(placeholderImg, x, y, w, h);
			}
			else {
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
		if(this.state == State.UNLOCKED || this.state == State.LOCKED){
			image(this.placeholderImg, xx, yy, ww, hh);
		} else{
			image(this.starImg, xx, yy, ww, hh);
		}
  	}

	void unlock(){
		this.state = State.UNLOCKED;
	}
	
	void setClear(){
		this.state = State.CLEAR;
	}

	boolean isMouseOver(){
		if(mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h){
			return true;
		} else {
			return false;
		}
	}

	void printInfo(){
		println("[Star]"+name+":("+x+","+y+"), w:"+w+",h:"+h+",state:"+this.state+",isMouseOver:"+isMouseOver());
	}
}

class BgStar{
	int x;
	int y;
	float size;
	float brightness;
	//change of brightness in a second
	float delta;
	boolean isIncrease;
	int color_idx;
	
	BgStar(){
		this.x = rand.nextInt(displayWidth);
		this.y = rand.nextInt(displayHeight);
		this.size = 5.0f + rand.nextFloat() * 5.0f;
		this.brightness = rand.nextFloat() * 1.0f;
		this.delta = 0.7;
		this.isIncrease = true;
		this.color_idx = 0;
		// randomly pick some stars to be colored yellow and blue 
		int tmp = rand.nextInt(100);
		if(tmp < 10 ){
			this.color_idx = 1;
		}else if(tmp > 90){
			this.color_idx = 2;
		}
	}

	void twinkle(){
		if(isIncrease){
			this.brightness += delta / 60;
		} else {
			this.brightness -= delta / 60;
		}

		if(this.brightness >= 0.8){
			this.brightness = 0.8;
			this.isIncrease = false;
		} 
		else if(this.brightness <= 0.0){
			this.brightness = 0.0;
			this.isIncrease = true;
		}
	}

	void draw(){
		pushMatrix();
		translate(this.x, this.y);
		if(color_idx == 0){
			// white 
			fill(255, 255, 255, Math.round(this.brightness * 255));
		}
		else if(color_idx == 1){
			// yellow
			scale(1.2);
			fill(255, 255, 0, Math.round(this.brightness * 255));
		}
		else{
			// blue
			scale(1.2);
			fill(0, 153, 255, Math.round(this.brightness * 255));
		}
		noStroke();
		ellipse(0, 0, this.size/2, this.size/2);
		twinkle();
		popMatrix();
	}
}

class Machine{
	float inixpos;
	float iniypos;
	float xpos;
	float ypos;
	float xx;
	float yy;
	int h;
	int w;
	int type;
	PImage img;
	
	Machine(float x, float y, int t, PImage m) { 
		inixpos = x;
		iniypos = y;
		xpos = inixpos;
		ypos = iniypos;
		type = t;
		img = m;
		h = 60;
		w = 160;
		xx = 0;
		yy = 0;
	}
	
	void updatePos(){
		if (selected == type){
			if (!mousePressed){
				selected = -1;
				if (xpos >= 260 && xpos <= 320 && ypos >= 220 && ypos <= 260){
					current = type;
					xpos = 290;
					ypos = 240;
				}else{
					if (current == type){
						current = -1;
					}
					xpos = inixpos;
					ypos = iniypos;
				}
			}else{
				xpos = mouseX-w/2;
				ypos = mouseY-h/2;
			}
		}else{
			if (current != type){
				xpos = inixpos;
				ypos = iniypos;
			}
		}
	}
	
	void display(){
		image(img, xpos, ypos, w, h);
	}
}

/* ======================================================
 * Initialisation
 * ====================================================== 
 */
void setup() {
  	size(displayWidth, displayHeight);
	background(0);
	smooth(4);
	loadStars();
	frameRate(60);
	// load collection scene resources
	cBackground = loadImage(imgBasePath + "sky_canvas.png");
	hover = new SoundFile(this, "hover.mp3");
	bgm = new SoundFile(this, "menu.mp3");
	bgm.play();
	// create background stars
	for(int i=0; i < bgstars.length; i++){
		bgstars[i] = new BgStar();
	}
	// load factory scene resource
	for (int i = 0; i < 6; i++){
		image[i] = loadImage("../img/m"+str(i)+".png");
	}
	factoryimg = loadImage("../img/factory.png");
	pointerimg = loadImage("../img/pointer.png");
	for (int i = 0; i < 5; i++){
		m[i] = new Machine(50, i*110+200, i, image[i]);
		scale[i] = loadImage("../img/p"+str(i)+".png");
	}
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
		String rawState = star.getString("state");
		int state;
		if(rawState.equals("starter")){
			state = State.STARTER;
		} else if (rawState.equals("locked")){
			state = State.LOCKED;
		} else if (rawState.equals("unlocked")){
			state = State.UNLOCKED;
		} else if (rawState.equals("clear")){
			state = State.CLEAR;
		} else {
			state = State.LOCKED;
			System.out.printf("WARNING: Can't interprete star state: %s --> %s\n", name, rawState);
		}
		PImage starImg = loadImage(imgBasePath + star.getString("imgPath"));
		// create new star
		stars[i] = new Star(name, x, y, width, height, starImg, placeholderImg, state);
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
	// draw background stars
	for(int i=0; i < bgstars.length; i++){
		if(bgstars[i] != null){
			bgstars[i].draw();
      		
		}
	}
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
	if(currentStar.state == State.LOCKED){
		fill(209, 211, 212);
	} else {
		if (mouseX >= 450 && mouseX <= 860 && mouseY >= 415 && mouseY <= 465) {
			fill(209, 211, 212);
		} else {
			fill(255, 255, 255);
		}
	}
	stroke(0);
	rect(450, 415, 410, 50, 10);
	// draw button text
	textSize(22);
	if(currentStar.state == State.LOCKED){
		fill(100);
		text("‎Locked", 610, 428, 150, 80);
	} else {
		fill(50);
		text("Start", 625, 428, 150, 80);
	}
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
	background(20, 40, 70); 
	pushMatrix();
	translate(650, 400);
	rotate(radians(speed*.1*rdir));
	rdir = -rdir;
	image(factoryimg,-400, -250, 800, 500);
	popMatrix();
	
	
	for (int i = 0; i < 5; i++){
		if(mouseX >= m[i].xpos && mouseX <= m[i].xpos + m[i].w && mouseY >= m[i].ypos && mouseY <= m[i].ypos + m[i].h && mousePressed){
			if (selected == -1){
				selected = i;
			}
		}
		m[i].updatePos();
		m[i].display();
	}
	
	if (current != -1){  
		if (current == 0){
			value[current] = (float)Math.pow(10, deg[current]/45.0 - 1);
			text(nfc(value[current], 1), 940, 680);
			textSize(30);
			text("Mass(solar mass)", 270, 210);
			image(scale[current], 460, 400, 300, 150);
		}else if (current == 1){
			value[current] = 20-(float)deg[current]/180*40;
			text(nfc(value[current], 1), 940, 680);      
			textSize(30);
			text("Surface Brightness(magnitude)", 270, 210);
			image(scale[current], 460, 400, 300, 150);
		}else if (current == 2){
			value[current] = (float)Math.pow(10, deg[current]/20.0);
			text(nfc(value[current], 1), 940, 680);
			textSize(30);
			text("Radius(km)", 270, 210);
			image(scale[current], 460, 400, 300, 150);
		}else if (current == 3){
			value[current] = (float)Math.pow(10, deg[current]/20.0);
			text(nfc(value[current], 1), 940, 680);
			textSize(30);
			text("Temperature(K)", 270, 210);
			image(scale[current], 460, 400, 300, 150);
		}else if (current == 4){
			value[current] = deg[current]/180.0*7;
			if (value[current]<1){
				fill(255);
			}else if (value[current]>=1 && value[current]<2){
				fill(130, 250, 100);
			}else if (value[current]>=2 && value[current]<3){
				fill(255, 240, 80);
			}else if (value[current]>=3 && value[current]<4){
				fill(255, 270, 80);
			}else if (value[current]>=4 && value[current]<5){
				fill(255, 110, 80);
			}else if (value[current]>=5 && value[current]<6){        
				fill(100,200,255);
			}else if (value[current]>=6 && value[current]<7){
				fill(0);
			}
			image(scale[current], 460, 400, 300, 150);
			rect(940, 660, 60, 30); 
			fill(255);
			textSize(30);
			text("Colour", 270, 210);
		}
		
		
		pushMatrix();
		translate(603, 556);
		rotate(radians(0+deg[current]));
		image(pointerimg, -140, -10, 150, 20);
		popMatrix();
		
		fill(180, 50, 50);
		noStroke();
		rect(440, 650, 120, 50);
		
		textSize(30);
		fill(255);
		text("Mix!", 470, 685);
		
		textSize(20);
		text(chance[current], 700, 680);
		text("Chance(s) left   Value: ", 718, 680);
		if(mouseX >= 440 && mouseX <= 560 && mouseY >= 670 && mouseY <= 720 && mousePressed & chance[current] != 0){
			if(speed < 20){
				speed = speed + 4;
			}
		}else{
			if (speed > 0){
				speed --;
			}
		}
		if (deg[current] >= 180){
			deg[current] = 180;
			dir = -dir;
		}else if (deg[current] <= 0){
			deg[current] = 0;
			dir = -dir;
		}
		deg[current] = deg[current] + speed * dir;
	}
	
	noFill();
	stroke(255);
	rect(940, 50, 350, 200);
	line(800, 270, 940, 150);
	textSize(15);
	if (value[0] == -100){text("Mass(solar mass): ???", 970, 80);}else{text("Mass(solar mass): "+nfc(value[0], 1), 970, 80);}
	if (value[1] == -100){text("Surface Brightness(magnitude): ???", 970, 110);}else{text("Surface Brightness(magnitude): "+nfc(value[1], 1), 970, 110);}
	if (value[2] == -100){text("Radius(km): ???", 970, 140);}else{text("Radius(km): "+nfc(value[2], 1), 970, 140);}
	if (value[3] == -100){text("Temperature(K): ???", 970, 170);}else{text("Temperature(K): "+nfc(value[3], 1), 970, 170);}
	if (value[4] == -100){text("Colour: ???", 970, 200);}else{
		text("Colour: ", 970, 200);
		noStroke();
			if (value[4]<1){
				fill(255);
			}else if (value[4]<2){
				fill(130, 250, 100);
			}else if (value[4]<3){
				fill(255, 240, 80);
			}else if (value[4]<4){
				fill(255, 270, 80);
			}else if (value[4]<5){
				fill(255, 110, 80);
			}else if (value[4]<6){
				fill(100,200,255);
			}else if (value[4]<7){
				fill(0);
			}
			rect(1030, 180, 60, 30); 
			fill(255);

	}
	
	if (value[0] != -100 && value[1] != -100 && value[2] != -100 && value[3] != -100 && value[4] != -100){
	fill(180, 50, 50);
	noStroke();
	rect(1100, 450, 140, 50);
		
	textSize(30);
	fill(255);
	text("Bake!", 1130, 485);
	}

	textSize(10);
	text(str(mouseX)+" "+str(mouseY), mouseX, mouseY);

}


void draw() {
	if(DEBUG_FACTORY){
		drawSceneFactory();
	}
	else if(currentScene == 0){
		drawSceneCollection();
	} else if (currentScene == 1){
		drawSceneCollection();
		drawSceneStarInfo();
	} else if (currentScene == 4){
		drawSceneFactory();
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

void mouseReleased() {
	if (currentScene == 4 && mouseX >= 440 && mouseX <= 560 && mouseY >= 670 && mouseY <= 720 && current != -1) {
		if (chance[current] != 0){
			chance[current] --;
		}
		if(chance[current] == 0){
			m[current].img = image[5];      
		}
	}
}
