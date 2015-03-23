/* COLOR TOWNS
  Interactive community building visualization that is driven by user input and ... destiny?
  
  Created for ARTS444 at University of Illinois
  Authored by Alyssa Reyes, 2014
*/


int dotSize = 10;
int numStartDots = 80; 
int childRadius = dotSize+100;  //radius from parent

boolean keepDrawing;

ArrayList<Dot> dots;
ArrayList<MarriedDot> marriedDots;
ArrayList<Dot> oldDots;

void setup() {
  keepDrawing = true;
  size(displayWidth, displayHeight); 
  background(255);
  dots = new ArrayList();
  marriedDots = new ArrayList();
  oldDots = new ArrayList();

  // initialize dots
  for (int i=0; i<numStartDots; i++)
    dots.add(new Dot(random(width), random(height), color(random(255), random(255), random(255)), null));

  // make soul mates
  for (int i=0; i<numStartDots; i++)
    dots.get(i).setTrueLove();

  initNewDots(numStartDots);
}

void initNewDots(int amount) {
  // initialize dots
  for (int i=0; i<amount; i++)
    dots.add(new Dot(random(width), random(height), color(random(255), random(255), random(255)), null));

  // make soul mates
  for (int i=0; i<amount; i++)
    dots.get(i).setTrueLove();
}


void draw() {
  background(255);
  
  //draw dots & move them towards their true love
  for (int i=0; i<dots.size(); i++) {
    dots.get(i).drawDot();
    dots.get(i).findTrueLove();
  }
  //check if dots are close enough to be married
  checkProximity();

  //draw married dots
  for (int i=0; i<marriedDots.size(); i++)
    marriedDots.get(i).drawDot();
  //draw married dots
  for (int i=0; i<oldDots.size(); i++)
    oldDots.get(i).drawDot();
    
  drawControls();
}


void drawControls() {
   fill(240, 220);
   rect(0, height-90, 200, 200); 
   fill(0);
   text("TAB - renew", 20, height-60);
   text("BACKSPACE - clear", 20, height-40);
   text("r/g/b - add red/green/blue", 20, height-20);
   
}



//hand of fate -- make dots gravitate towards mouse
void mouseMoved() {
  for (int i=0; i<dots.size(); i++) {
    if (dots.get(i).isNear(mouseX, mouseY, 200))
      dots.get(i).gravitate(mouseX, mouseY, 0.005);
  }
  
}

void keyPressed() {
  if (key==TAB)
    renewPopulation();
  if (key==BACKSPACE) 
    cleansePopulation();
  if(key=='r') 
     plasticSurgery("RED");
  if(key=='b')
    plasticSurgery("BLUE");
  if(key=='g')
    plasticSurgery("GREEN");
  
}


void plasticSurgery(String trendy) {
  color newTrend;
  int x = mouseX;
  int y = mouseY;
  for(int i=0; i<dots.size(); i++) {
    Dot currDot = dots.get(i);
    
    if(currDot.isNear(x, y, 100) ) {
      if(trendy.equals("RED")) 
        newTrend = color(random(200,255), random(0,200), random(0,200));
      else if(trendy.equals("GREEN"))
         newTrend = color(random(0,200), random(200,255), random(0,200));
      else
         newTrend = color(random(0,200), random(0,200), random(200,255));
      currDot.body = newTrend;   
    }
  }
  
  
}


// clear all dots
void cleansePopulation() {
  for (int i=dots.size()-1; i>=0; i--) {
    dots.remove(i);
  }
  for (int i=marriedDots.size()-1; i>=0; i--) {
    marriedDots.remove(i);
  }
  
  for(int i=oldDots.size()-1; i>=0; i--)
    oldDots.remove(i);
}

// fade old dots, and add new ones
void renewPopulation() {
  keepDrawing = false;
  noLoop();

  //clear old dots
  for (int i=dots.size()-1; i>=0; i--) {
    Dot currDot = dots.get(i);
    currDot.isDead = true;
    oldDots.add(currDot); 
    dots.remove(i);
  }
  for(int i=0; i<marriedDots.size(); i++) 
    marriedDots.get(i).isDead = true;
  
  initNewDots(numStartDots/2);
  loop();
  keepDrawing = true;
}


// checks all dots against each other, and marry them if they are close
void checkProximity() {
  noLoop();
  keepDrawing = false;
  for (int i=0; i<dots.size(); i++) {
    for (int j=0; j<dots.size(); j++) {
      if (i!=j && dots.get(i).isClose(dots.get(j).x, dots.get(j).y)) {
        marryDots(dots.get(i), dots.get(j));
        break;
      }
    }
  }
  loop();
  keepDrawing = true;
}



void marryDots(Dot dot1, Dot dot2) {
  // siblings cannot marry
  if (dot1.parent !=null && dot1.parent == dot2.parent)
    return;
  dots.remove(dot2);
  dots.remove(dot1);

  // replace two dots with one married dot
  MarriedDot tempCouple = new MarriedDot(dot1.x, dot1.y, dot1.body, dot2.body, dot2.parent, dot1.parent);
  marriedDots.add(tempCouple);  
  makeChildren(tempCouple);
}


// makes 1-5 children, each with a color randomly between the two parent's colors
void makeChildren(MarriedDot parent) {  
  //  position points in circle around a point: http://processing.org/discourse/beta/num_1207766233.html
  float radius = childRadius;
  int numPoints = int(random(1, 5));
  float angle=TWO_PI/(float)numPoints;
  for (int i=0;i<numPoints;i++)
  {
    color child = lerpColor(parent.body, parent.body2, random(1));
    Dot childDot = new Dot(radius*sin(angle*i)+parent.x, radius*cos(angle*i)+parent.y, child, parent);
    childDot.setTrueLove();
    dots.add(childDot);
  }
}


class Dot {
  float x;
  float y;
  color body;  
  boolean isMarried;
  float leftBound, rightBound, topBound, bottomBound;
  MarriedDot parent;
  int generation;
  Dot trueLove;
  int weight;
  boolean isDead;

  Dot(float x, float y, color body, MarriedDot parent) {
    this.x = x;
    this.y = y;
    this.body = body;
    this.setBounds();
    isMarried = false;
    this.parent = parent;
    weight = dotSize;
    isDead = false;
  }

  void setTrueLove() {
    noLoop();
    keepDrawing = false;
    int trueLoveIndex = (int)random(dots.size()-1);
    trueLove = dots.get(trueLoveIndex);
    keepDrawing = true;
    loop();
  }

  void setBounds() {
    leftBound = this.x - dotSize/2;
    rightBound = this.x + dotSize/2;
    topBound = this.y - dotSize/2;
    bottomBound = this.y + dotSize/2;
  }

  boolean isClose(float xPos, float yPos) {
    return isNear(xPos, yPos, 0);
  }

  boolean isNear(float xPos, float yPos, int radius) {
    if (xPos > leftBound-radius && xPos < rightBound+radius && yPos > topBound-radius && yPos < bottomBound+radius)
      return true;
    else
      return false;
  }


  void drawDot() {
    connectToParent(parent);
    noStroke();
    if (isDead)
      fill(body, 30);
    else
      fill(body); 
    ellipse(x, y, weight, weight);
  }

  void connectToParent(MarriedDot mum) {
    if (mum!=null) {
      strokeWeight(2);
      if (isDead)  
        stroke(body, 20);
      else
        stroke(body, 50);
      line(x, y, mum.x, mum.y);
    }
  }

  void move(float newX, float newY) {
    x = newX;
    y = newY;
    setBounds();
  } 


  // easing towards a target point: http://processing.org/examples/easing.html
  void gravitate(float targetX, float targetY, float easing) {
    float newX = this.x;
    float newY = this.y;
    float dx = targetX - this.x;
    float dy = targetY - this.y;

    if (abs(dx) > 1) 
      newX += dx * easing;  
    if (abs(dy) > 1)
      newY += dy * easing;
    this.move(newX, newY);
  }

  void findTrueLove() {
    if (trueLove == null)
      return;
    else
      gravitate(trueLove.x, trueLove.y, 0.001);
  }
}



class MarriedDot extends Dot {
  color body2;
  MarriedDot parent2;

  MarriedDot(float x, float y, color man, color wife, MarriedDot parent1, MarriedDot parent2) {
    super(x, y, man, parent1);
    this.parent2 = parent2;
    body2 = wife;
    isMarried = true;
    trueLove = null;
    weight = weight*3;
  }

  void drawDot() {
    connectToParent(parent);
    connectToParent(parent2);
    noStroke();
    fill(body);
    arc(x, y, weight, weight, 0, PI);
    fill(body2);
    arc(x, y, weight, weight, PI, 2*PI);
    if (weight>2)
      weight--;
  }

  void move(float x, float y) {
    return;
  }
}

