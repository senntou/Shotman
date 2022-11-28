import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map;
import java.util.HashMap;

enum Gamemode {
    TITLE,
    ACTIVE,
};

final float SHOTMAN_SPEED = 8;
final float BULLET_SPEED = 16;
final float BULLET_RADIUS = 5;
final float TRACKING_BULLET_MAX_ROTATING_SPEED = 3;
final float SHOTMAN_ROTATE_SPEED = 6;
final float RAY_LENGTH = 100;
final float RAY_SPEED = 20;
final int RAY_EMIT_FRAME = 20;
final int DAMAGE_EFFECT_FRAME = 12;
final float SMALL_RECT_SIZE = 30;
final int PLAYER_HP = 100;
final int BULLET_DAMAGE = 1;
final int RAY_DAMAGE = 2;

Gamemode gamemode = Gamemode.TITLE;
Title title;

final boolean DRAW_KEYBOARD_FLAG = true;

final int PLAYER_COLOR[] = { 0 , 255 };

boolean key_up_flag = false;
boolean key_down_flag = false;
boolean key_right_flag = false;
boolean key_left_flag = false;
boolean key_enter_flag = false;

boolean key_w_flag = false;
boolean key_a_flag = false;
boolean key_s_flag = false;
boolean key_d_flag = false;
boolean key_z_flag = false;
boolean key_x_flag = false;

boolean key_r_flag = false;

ShotMan player1;
ShotMan player2;

int winner = 0;

void keyPressed() {
    if (keyCode == UP) key_up_flag = true;
    if (keyCode == DOWN) key_down_flag = true;
    if (keyCode == RIGHT) key_right_flag = true;
    if (keyCode == LEFT) key_left_flag = true;
    if (key == 'z') key_z_flag = true;
    if (key == 'x') key_x_flag = true;
    
    if (key == 'w') key_w_flag = true;
    if (key == 'a') key_a_flag = true;
    if (key == 's') key_s_flag = true;
    if (key == 'd') key_d_flag = true;
    if (keyCode == ENTER) key_enter_flag = true;
    
    if (key == 'r' && !key_r_flag) {
        key_r_flag = true;
        reset();
    }
}
void keyReleased() {
    if (keyCode == UP) key_up_flag = false;
    if (keyCode == DOWN) key_down_flag = false; 
    if (keyCode == LEFT) key_left_flag = false;
    if (keyCode == RIGHT) key_right_flag = false;
    if (key == 'z') key_z_flag = false;
    if (key == 'x') key_x_flag = false;
    
    if (key == 'w') key_w_flag = false;
    if (key == 'a') key_a_flag = false;
    if (key == 's') key_s_flag = false;
    if (key == 'd') key_d_flag = false;
    if (keyCode == ENTER) key_enter_flag = false;
    
    if (key == 'r') key_r_flag = false;
}
//直線（ベクトル）より点が左側にあるときのみtrueを返す
public boolean pointAndLine(float x,float y,float x1,float y1,float x2,float y2) {
    float a1 = x - x1;
    float a2 = y - y1;
    float b1 = x2 - x1;
    float b2 = y2 - y1;
    return 0 <= a1 * b2 - b1 * a2;
}
public boolean pointInQuad(float x,float y,float x1,float y1,float x2,float y2,
    float x3,float y3,float x4,float y4) {
    if (pointAndLine(x,y,x1,y1,x2,y2)) return false;
    if (pointAndLine(x,y,x2,y2,x4,y4)) return false;
    if (pointAndLine(x,y,x4,y4,x3,y3)) return false;
    if (pointAndLine(x,y,x3,y3,x1,y1)) return false;
    return true;
}
public boolean circleInRect(float x,float y,float r,float x1,float y1,
    float x2,float y2,float x3,float y3,float x4,float y4) {
    
    float dx = (x1 - x3);
    float dy = (y1 - y3);
    float a = sqrt(dx * dx + dy * dy);
    
    if (pointInQuad(x,y,x1 + r * dx / a,y1 + r * dy / a,
        x2 +r * dx / a,y2 + r * dy / a,
        x3 -r * dx / a,y3 - r * dy / a,
        x4 -r * dx / a,y4 - r * dy / a)) {
        return true;
    }

    dx = (x2 - x1);
    dy = (y2 - y1);
    a = sqrt(dx * dx + dy * dy);
    
    if (pointInQuad(x,y,x1 - r * dx / a,y1 - r * dy / a,
        x2 -r * dx / a,y2 - r * dy / a,
        x3 +r * dx / a,y3 + r * dy / a,
        x4 +r * dx / a,y4 + r * dy / a)) {
        return true;
    }
    
    if ((x1 - x) * (x1 - x) + (y1 - y) * (y1 - y) <= r * r) return true;
    if ((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y) <= r * r) return true;
    if ((x3 - x) * (x3 - x) + (y3 - y) * (y3 - y) <= r * r) return true;
    if ((x4 - x) * (x4 - x) + (y4 - y) * (y4 - y) <= r * r) return true;
    
    return false;
    
    
}
public boolean LineAndPoint(float ax,float ay,float bx,float by,float px,float py) {
    if ((bx - ax) * (py - ay) - (by - ay) * (px - ax) >= 0) return true;
    return false;
}
public boolean LineAndLine(float A1x, float A1y, float A2x, float A2y, float B1x, float B1y, float B2x, float B2y) {
    {
        	float baseX = B2x - B1x;
        	float baseY = B2y - B1y;
        	float sub1X = A1x - B1x;
        	float sub1Y = A1y - B1y;
        	float sub2X = A2x - B1x;
        	float sub2Y = A2y - B1y;
        
        	float bs1 = baseX * sub1Y - baseY * sub1X;
        	float bs2 = baseX * sub2Y - baseY * sub2X;
        	float re = bs1 * bs2;
        	if (re> 0) {
            		return false;
            	}
        }
    {
        	float baseX = A2x - A1x;
        	float baseY = A2y - A1y;
        	float sub1X = B1x - A1x;
        	float sub1Y = B1y - A1y;
        	float sub2X = B2x - A1x;
        	float sub2Y = B2y - A1y;
        
        	float bs1 = baseX * sub1Y - baseY * sub1X;
        	float bs2 = baseX * sub2Y - baseY * sub2X;
        	float re = bs1 * bs2;
        	if (re> 0) {
            		return false;
            	}
        }
    return true;
}
public boolean rayInShotMan(Ray r,ShotMan shotman) {
    if( LineAndLine(r.getX1(),r.getY1(),r.getX2(),r.getY2(),
        shotman.getX1(),shotman.getY1(),shotman.getX2(),shotman.getY2()) ) return true;
    if( LineAndLine(r.getX1(),r.getY1(),r.getX2(),r.getY2(),
        shotman.getX2(),shotman.getY2(),shotman.getX4(),shotman.getY4()) ) return true;
    if( LineAndLine(r.getX1(),r.getY1(),r.getX2(),r.getY2(),
        shotman.getX4(),shotman.getY4(),shotman.getX3(),shotman.getY3()) ) return true;
    if( LineAndLine(r.getX1(),r.getY1(),r.getX2(),r.getY2(),
        shotman.getX4(),shotman.getY4(),shotman.getX1(),shotman.getY1()) ) return true;
    
    return false;
}
public void reset() {
    player1 = new PlayerOne(width / 2,height*3 / 4);
    player1.setColor(0);
    player2 = new PlayerTwo(width / 2,height / 4);
    player2.setColor(1);

    player1.setEnemy();
    player2.setEnemy();
    title = new Title();
    this.gamemode = Gamemode.TITLE;

    winner = 0;
}
public void changePlayer2(ShotMan s){
    player2 = s;
    player1.setEnemy();
}
void drawKey(float x,float y,char c,boolean flag) {
    fill(flag ? 230 : 255);
    stroke(0);
    rect( - x / 2, - y / 2,x,y);
    fill(0);
    textAlign(CENTER,CENTER);
    textSize(30);
    text(c,0,0);
}
void drawKeyboard() {
    strokeWeight(1);
    float drawWidth = width / 3;
    float drawHeight = height / 6;
    float x = drawWidth * 2;
    float y = 0;
    pushMatrix();
    translate(x,y);
    translate( - width / 100,height / 100);
    
    float unitx = drawWidth / 6;
    float unity = drawHeight / 4;
    float keyWidth = unitx * 2 * 0.8;
    float keyHeight = unity * 2 * 0.8;
    pushMatrix();
    translate(unitx * 3,unity);
    drawKey(keyWidth,keyHeight,'↑',key_up_flag);
    popMatrix();
    
    pushMatrix();
    translate(unitx,unity * 3);
    drawKey(keyWidth,keyHeight,'←',key_left_flag);
    translate(unitx * 2,0);
    drawKey(keyWidth,keyHeight,'↓',key_down_flag);
    translate(unitx * 2,0);
    drawKey(keyWidth,keyHeight,'→',key_right_flag);
    popMatrix();
    
    popMatrix();
}
void drawBackGround() {
    int numx = 9;
    int numy = 13;
    float unitx = width / numx;
    float unity = height / numy;
    noStroke();
    for (int i = 0;i < numy;i++) {
        if (i % 2 == 1) {
            fill(0,8);
            rect(0,i * unity,width,unity);
        } 
    }
    for (int i = 0;i < numx;i++) {
        if (i % 2 == 1) {
            fill(0,8);
            rect(i * unitx,0,unitx,height);
        } 
    }
}
void setWinner(int w){
    if(winner == 0) winner = w;
}
void drawWinner(){
    if(winner == 0) return;
    pushMatrix();

    translate(width/2,height/10);
    textAlign(CENTER,CENTER);

    textSize(50);
    fill(PLAYER_COLOR[winner - 1] * 0.5);
    text("Winner : Player" + winner,0,0);

    popMatrix();
}
void setup() {
    size(800,900);
    frameRate(60);
    smooth();
    reset();
}
void draw() {
    background(255);
    drawBackGround();
    
    if (gamemode == Gamemode.TITLE) {
        title.update();
    } else if (gamemode == Gamemode.ACTIVE) {
        if (player1.isActive())player1.update();
        else setWinner(2);
        if (player2.isActive())player2.update();
        else setWinner(1);

        drawWinner();
        //drawKeyboard();
    }
    
}