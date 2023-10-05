/////////////////////////////////////////////////////
//
// Asteroids
// DM2 "UED 131 - Programmation impérative" 2021-2022
// NOM         :      MAZOUZ
// Prénom      :      Mohamed El Amine
// N° étudiant :      20215477
//
// Collaboration avec : myself
//
/////////////////////////////////////////////////////

//===================================================
// les variables globale
import processing.sound.*;
SoundFile fire;
SoundFile bangLarge;
SoundFile bangSmall;
SoundFile thrust;
//===================================================

//////////////////////
// Pour le vaisseau //
float shipX, shipY, 
  shipSpeedX, shipSpeedY;
float shipAcceleration = 0.25;
float shipSpeed = 0;
int shipSize = 10;
boolean shipMoving;
float shipAngle;
//////////////////////

//////////////////////
// Pour le missile  //
float missileX, missileY, missileAngle;
float missileSpeedX, missileSpeedY;
int missileSpeed = 0;
//////////////////////

//////////////////////
// Pour l'astéroïde //
int nbAsteroids = 4;
float[] asteroidsX = new float[nbAsteroids];
float[] asteroidsY = new float[nbAsteroids];
float[] taille = new float[nbAsteroids];
float[] asteroidsAngle = new float[nbAsteroids];
float[] asteroidsSpeedX = new float[nbAsteroids];
float[] asteroidsSpeedY = new float[nbAsteroids];
float asteroidsSpeed;
//////////////////////

////////////////////////////
// Pour la gestion du jeu //
int score;
int meilleurScore = 0;
////////////////////////////

////////////////////////////////////
// Pour la gestion de l'affichage //
PFont courier;
boolean gameOver;
boolean init;
////////////////////////////////////

//===================================================
// l'initialisation
//===================================================
void setup() {
  size(800, 800);
  initGame();
  init = true;
  fire =  new SoundFile(this, "fire.mp3");
  bangLarge = new SoundFile(this, "bangLarge.mp3");
  bangSmall = new SoundFile(this, "bangSmall.mp3");
  thrust = new SoundFile(this, "thrust.mp3");
}

// -------------------- //
// Initialise le jeu    //
// -------------------- //
void initGame() {
  score = 0;
  initShip();
  initAsteroids();
}

//===================================================
// la boucle de rendu
//===================================================
void draw() {
  background(0);
  for (int i = 0; i < nbAsteroids; i++) {
    if (init) {
      displayInitScreen();
    } else {
      if (gameOver == true) {
        displayGameOverScreen();
      } else {
        displayScore();
        displayBullets();
        moveBullets();
        displayShip(shipX, shipY, shipAngle);
        displayAsteroids(asteroidsX[i], asteroidsY[i], taille[i]);
        moveAsteroids();
        if (collision(missileX, missileY, 0, asteroidsX[i], asteroidsY[i], taille[i])) {
          initAsteroid(i);
          deleteBullet(i);
          score++;
          bangSmall.play();
        }
      }
      if (collision(shipX, shipY, shipSize, asteroidsX[i], asteroidsY[i], taille[i])) {
        gameOver = true;
        bangLarge.play();
      }
    }
  }
}
// ------------------------ //
//  Initialise le vaisseau  //
// ------------------------ //
void initShip() {
  shipSpeed = 0;

  shipX = 400;
  shipY = 400;

  shipAngle = 3*PI/2;
}

// --------------------- //
//  Deplace le vaisseau  //
// --------------------- //
void moveShip() {
  shipSpeed += shipAcceleration;  

  shipSpeedX = cos(shipAngle)*shipSpeed;
  shipSpeedY = sin(shipAngle)*shipSpeed;

  shipX += shipSpeedX;
  shipY += shipSpeedY;

  if (shipX >= width)
    shipX -= width;
  if (shipX <= 0)
    shipX += width;
  if (shipY >= height)
    shipY -= height;
  if (shipY <= 0)
    shipY += height;

  thrust.play();
}

// -------------------------- //
//  Crée un nouvel asteroïde  //
// -------------------------- //
void initAsteroids() {
  missileX = -100;
  missileY = -100;
  missileSpeed = 0;
  for (int i = 0; i < nbAsteroids; i++) {
    initAsteroid(i);
  }
}

void initAsteroid(int i) {
  float indexX, indexY;
  float[] X = {0, 800, random(800)};
  float[] Y = {0, 800};
  int[] t = {30, 60, 90};
  indexX = X[int(random(X.length))];
  if (indexX == 0 || indexX == 800) {
    indexY = random(800);
  } else {
    indexY = Y[int(random(1))];
  }
  asteroidsX[i] = indexX;
  asteroidsY[i] = indexY;
  taille[i] = t[int(random(t.length))];
  asteroidsAngle[i] = random(TWO_PI);
}

// ------------------------------ //
//  Crée la forme de l'asteroïde  //
// ------------------------------ //
// i : l'indice de l'asteroïde dans le tableau
//
void createAsteroid(int i) {
}

// --------------------- //
//  Deplace l'asteroïde  //
// --------------------- //
void moveAsteroids() {  
  asteroidsSpeed = 1;
  for (int i = 0; i < nbAsteroids; i++) {
    asteroidsSpeedX[i] = cos(asteroidsAngle[i])*asteroidsSpeed;
    asteroidsSpeedY[i] = sin(asteroidsAngle[i])*asteroidsSpeed;

    asteroidsX[i] += asteroidsSpeedX[i];
    asteroidsY[i] += asteroidsSpeedY[i];

    if (asteroidsX[i] >= width)
      asteroidsX[i] -= width;

    if (asteroidsX[i] <= 0)
      asteroidsX[i] += width;

    if (asteroidsY[i] >= height)
      asteroidsY[i] -= height;

    if (asteroidsY[i] <= 0)
      asteroidsY[i] += height;
  }
}

// ------------------------ //
//  Détecte les collisions  //
// ------------------------ //
// o1X, o1Y : les coordonnées (x,y) de l'objet1
// o1D      : le diamètre de l'objet1
// o2X, o2Y : les coordonnées (x,y) de l'objet2
// o2D      : le diamètre de l'objet2
//
boolean collision(float o1X, float o1Y, float o1D, float o2X, float o2Y, float o2D) {

  float d = dist(o1X, o1Y, o2X, o2Y) - (o1D + o2D);

  if (d <= 0)
    return true;
  else
    return false;
}

// ----------------- //
//  Tire un missile  //
// ----------------- //
void shoot() {
  missileX = shipX;
  missileY = shipY;
  missileAngle = shipAngle;

  missileSpeed = 5;
  moveBullets();
}
// ------------------------------------------- //
//  Calcule la trajectoire du ou des missiles  //
// ------------------------------------------- //
void moveBullets() {
  int i = 0;
  missileSpeedX = cos(missileAngle)*missileSpeed;
  missileSpeedY = sin(missileAngle)*missileSpeed;

  missileX += missileSpeedX;
  missileY += missileSpeedY;

  if (missileX >= width ||missileX <= 0 ||missileY >= height ||missileY <= 0 )
    deleteBullet(i);
}

// --------------------- //
//  Supprime un missile  //
// --------------------- //
// idx : l'indice du missile à supprimer
//
void deleteBullet(int idx) {
  missileX = -100;
  missileY = -100;
  missileSpeed = 0;
}

// --------------------- //
//  touche un astéroïde  //
// --------------------- //
// idx    : l'indice de l'atéroïde touché
// vx, vy : le vecteur vitesse du missile
//
void shootAsteroid(int idx, float vx, float vy) {
}

// ----------------------- //
//  supprime un astéroïde  //
// ----------------------- //
// idx    : l'indice de l'atéroïde touché
//
void deleteAsteroid(int idx) {
}

//===================================================
// Gère les affichages
//===================================================

// ------------------- //
// Ecran d'accueil     //
// ------------------- //
void displayInitScreen() {
  pushMatrix();
  courier = createFont("courier", 100);
  textFont(courier);
  textAlign(CENTER, CENTER);
  textFont(courier);
  fill(255);
  text("ASTEROIDS", 400, 200);
  textSize(20);
  text("<< SPACE to start >>", 400, 700);
  textAlign(LEFT, CENTER);
  text("Commandes : ", 50, 400);
  text("RIGHT to turn right", 50, 430);
  text("LEFT  to turn left", 50, 460);
  text("UP to turn on the motor", 50, 490);
  text("SPACE to shoot", 50, 520);
  text("ENTER/BACKSPACE to a random teleport", 50, 550);
  scale(5);
  shipMoving = true;
  displayShip(80, 70, 5*PI/4);
  popMatrix();
}

// -------------- //
//  Ecran de fin  //
// -------------- //
void displayGameOverScreen() {
  courier = createFont("courier", 60);
  textFont(courier);
  textAlign(CENTER, CENTER);
  textFont(courier);
  fill(255);
  text("Game Over", 400, 300);
  text("Score :", 375, 400);
  text(score, 550, 400);
  text("meilleur score :", 340, 500);
  text(meilleurScore, 700, 500);
  textSize(20);
  text("<< Any key to restart >>", 400, 700);
}

// --------------------- //
//  Affiche le vaisseau  //
// --------------------- //
void displayShip(float x, float y, float a) {
  pushMatrix();
  fill(0);
  translate(x, y);
  rotate(a);
  if (shipMoving == true) {
    stroke(255, 0, 0);
    beginShape();
    vertex(-15, 0);
    vertex(-5, 5);
    vertex(-5, -5);
    endShape(CLOSE);
  }
  stroke(255);
  beginShape();
  vertex(10, 0);
  vertex(-7, 7);
  vertex(-5, 0);
  vertex(-7, -7);
  endShape(CLOSE);
  popMatrix();
}

// ------------------------ //
//  Affiche les asteroïdes  //
// ------------------------ //
void displayAsteroids(float x, float y, float t) {
  pushMatrix();
  noFill();
  float angle = TWO_PI / 6;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float s;
    s = random(t);
    float sx = x + cos(a) * s;
    float sy = y + sin(a) * s;
    vertex(sx, sy);
  }
  endShape(CLOSE);
  popMatrix();
}

// ---------------------- //
//  Affiche les missiles  //
// ---------------------- //
void displayBullets() {
  stroke(255);
  line(missileX, missileY, missileX+missileSpeedX, missileY+missileSpeedY);
}

// ------------------- //
//  Affiche le chrono  //
// ------------------- //
void displayChrono() {
}

// ------------------- //
//  Affiche le score   //
// ------------------- //
void displayScore() {
  meilleurScore = (score > meilleurScore)? score: meilleurScore;
  textAlign(CENTER, CENTER);
  textSize(20);
  fill(255);

  text("Score :", 50, 50);
  text(score, 130, 50);

  text("meilleur score :", 600, 50);
  text(meilleurScore, 725, 50);
}

//===================================================
// Gère l'interaction clavier
//===================================================

// ------------------------------- //
//  Quand une touche est enfoncée  //
// ------------------------------- //
// flèche droite  = tourne sur droite
// flèche gauche  = tourne sur la gauche
// flèche haut    = accélère
// barre d'espace = tire
// entrée         = téléportation aléatoire
//
void keyPressed() {
  if (gameOver == true) {
    initGame();
    displayInitScreen();
    init = true;
    gameOver = false;
  }

  if (key == ' ') {
    init = false;
  }

  if ( keyCode == RIGHT || key == 'd' || key == 'D') {
    shipAngle += radians(5);
  }

  if (keyCode == LEFT || key == 'q' || key == 'Q') {
    shipAngle -= radians(5);
  }

  if (key == ' ') {
    shoot();
    fire.play();
  }

  if  (keyCode == ENTER || keyCode == BACKSPACE) {
    shipX = random(800);
    shipY = random(800);
  }

  if (keyCode == UP || key == 'z' || key == 'Z') {
    moveShip();
    shipMoving = true;
  }
}
// ------------------------------- //
//  Quand une touche est relâchée  //
// ------------------------------- //
void keyReleased() {
  shipSpeed = 0;
  shipMoving = false;
}
