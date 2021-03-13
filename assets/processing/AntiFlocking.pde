Bird[] _flock;
int _numBirds;

void setup() {
  size(600, 600);
  frameRate(48);
  translate(width/2, height/2);
  _numBirds = 1000;
  restart();
}

void restart() {
  fill(0);
  stroke(0);
  // rect(0,0,width,height);
  background(0);
  _flock = new Bird[_numBirds];
  for(int x = 0; x < _numBirds; x++){
    Bird newBird = new Bird();
    _flock[x] = newBird;
  }
  
  for(int x = 0; x < _numBirds; x++){
    _flock[x].setFlock(_flock);
  }
}

void draw(){
  // background(200, .1);
  fill(0, 5);
  stroke(0);
  rect(0,0,width,height);
  for(int x = 0; x < _numBirds; x++){
    _flock[x].calcNextState();
  }
  
  for(int x = 0; x < _numBirds; x++){
     _flock[x].drawMe();
     // line((float)_flock[x].x,(float) _flock[x].y, (float)_flock[(x+1) % _flock.length].x, (float)_flock[(x+1) % _flock.length].y);
  }
}

void mousePressed(){
  restart();
}

class Bird {
  double x,y; // Position
  double a,b; // Direction
  double v;   // Velocity
  int type; // Smelly or not
  
  double r,g,l;
  
  double nexta, nextb;
  
  Bird[] neighbors;
  Bird[] flock;
  double[] neighborsX;
  double[] neighborsY;
  double minDist;
  
  Bird(){
    this(random(1) * width, random(1) * height);
  }
  
  Bird(double x, double y){
    this(x,y,random(2) - 1, random(2) - 1);
  }
  
  Bird(double x, double y, double a, double b){
    this(x,y,a,b,random(1));
  }
  
  Bird(double x, double y, double a, double b, double v){
    type = floor(random(3));
    this.x = x;
    this.y = y;
    this.a = a;
    this.b = b;
    this.v = v;
    this.nexta = a;
    this.nextb = b;
    this.neighbors = new Bird[0];
    this.flock = new Bird[0];
    minDist = 1;
    r = Math.floor(random(3));
    g = Math.floor(random(3));
    l = Math.floor(random(3));
  }
  
  void setFlock(Bird[] flock){
    this.flock = flock;
  }
  
  void findNeighbors(){
    this.neighbors = new Bird[0];
    this.neighborsX = new double[0];
    this.neighborsY = new double[0];
    for(int i = 0; i < flock.length; i++){
      double dist = Math.sqrt(Math.pow(flock[i].x - (this.x + this.a * minDist/3) ,2) + Math.pow(flock[i].y - (this.y + this.b * minDist/3) ,2));
      if( dist <= minDist ){
        this.neighbors = (Bird[])append(neighbors, flock[i]);
        this.neighborsX = (double[])append(neighborsX, flock[i].x);
        this.neighborsY = (double[])append(neighborsY, flock[i].y);
      }
    }
    if(neighbors.length > 10){
      minDist *= .9;
    }
    else if (neighbors.length < 2){
      minDist *= 1.1;
    }
  }
  
  void calcNextState(){
    this.findNeighbors();
    double avoidX = 0, avoidY = 0;
    double alignX = 0, alignY = 0;
    double togetherX = 0, togetherY = 0;
    for(int i = 0; i < neighbors.length; i++){
      double currDist;
      double currX, currY;
      currX = neighbors[i].x - this.x;
      currY = neighbors[i].y - this.y;
      currDist = Math.sqrt(Math.pow(currX,2) + Math.pow(currY,2));
      if (currDist != 0){
        if (neighbors[i].type == this.type){
          // How much to avoid
          avoidX += currX * 1/Math.pow(currDist/9,1.5);
          avoidY += currY * 1/Math.pow(currDist/9,1.5);
          // How much to align
          alignX += neighbors[i].a;
          alignY += neighbors[i].b;
          // How much to stay together;
          togetherX += currX;
          togetherY += currY;
        } else {
          // How much to avoid
          avoidX += currX * 1/Math.pow(currDist/9,1.5);
          avoidY += currY * 1/Math.pow(currDist/9,1.5);
          // How much to stay together;
          togetherX -= currX;
          togetherY -= currY;
        }
      }
    }
    
    //togetherX *= 2;
    //togetherY *= 2;
    //alignX *= 0;
    //alignY *= 0;
    
    double dira = .98 * this.a + 0.02 * (-1 * avoidX/Math.sqrt(neighbors.length) + 0.5*(togetherX + alignX)/neighbors.length);
    double dirb = .98 * this.b + 0.02 * (-1 * avoidY/Math.sqrt(neighbors.length) + 0.5*(togetherY + alignY)/neighbors.length);
    
    this.nexta = dira / Math.sqrt(dira * dira + dirb * dirb);
    this.nextb = dirb / Math.sqrt(dira * dira + dirb * dirb);
  }
  
  void drawMe(){
    smooth();
    strokeWeight(1);
    if (type == 0) {
      stroke(255,150,0);
    } else if (type == 1) {
      stroke(0,150,255);
    } else {
      stroke(100,255,100);
    }
    
    for (int i = 0; i < neighbors.length; i++){
      if (this.type == neighbors[i].type){
        line((float)x,(float)y,(float)neighborsX[i],(float)neighborsY[i]);
      } else {
      }
    }
    
    a = nexta;
    b = nextb;
    x = (x+a+width) % width;
    y = (y+b+height) % height;
    
    //line((float)(x-a*5), (float)(y-b*5), (float)(x+a*5), (float)(y+b*5));
  }
}
