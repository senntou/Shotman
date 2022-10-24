import java.util.ArrayList;

final float SHOTMANSPEED = 8;
final float BULLETSPEED = 16;
final float BULLETRADIUS = 3;
final float SHOTMANROTATESPEED = 6;
final color PLAYERCOLORONE = color(0);

final boolean DRAW_KEYBOARD_FLAG = true;

boolean key_up_flag = false;
boolean key_down_flag = false;
boolean key_right_flag = false;
boolean key_left_flag = false;
boolean key_z_flag = false;

ShotMan player1;

void keyPressed(){
    if(keyCode == UP) key_up_flag = true;
    if(keyCode == DOWN) key_down_flag = true;
    if(keyCode == RIGHT) key_right_flag = true;
    if(keyCode == LEFT) key_left_flag = true;
    if(key == 'z') key_z_flag = true;
}
void keyReleased() {
    if(keyCode == UP) key_up_flag = false;
    if(keyCode == DOWN) key_down_flag = false; 
    if(keyCode == LEFT) key_left_flag = false;
    if(keyCode == RIGHT) key_right_flag = false;
    if(key == 'z') key_z_flag = false;
}
public class Bullet{
    private float theta;
    private float x,y;
    private float speed;
    private float radius;
    public Bullet(float x,float y,float theta,
            float speed,float radius){
        this.theta = theta;
        this.x = x;
        this.y = y;
        this.speed = speed;
        this.radius = radius;
    }
    public Bullet(float x,float y,float theta){
        this(x,y,theta,BULLETSPEED,BULLETRADIUS);
    }
    public void update(){

        this.move();
        this.show();
    }
    private void delete(){

    }
    private void move(){
        this.x += this.speed * sin(radians(this.theta));
        this.y -= this.speed * cos(radians(this.theta));
    }
    private void show(){
        ellipse(this.x,this.y,this.radius*2,this.radius*2);
    }
}
public class ShotMan{
    private float theta;
    private float speed;
    private float rotateSpeed;
    private float x,y;
    //rect
    private float edgeLength;

    public ArrayList<Bullet> bullets;

    public ShotMan(float x,float y,float theta){
        this.theta = theta;
        this.speed = SHOTMANSPEED;
        this.rotateSpeed = SHOTMANROTATESPEED;
        this.x = x;
        this.y = y;
        this.edgeLength = 50;
        this.bullets = new ArrayList<Bullet>();
    }
    public ShotMan(float x,float y){
        this(x,y,0);
    }
    public void update(){
        this.move();
        this.shot();
        this.show();
    }
    private void move(){
        if(key_up_flag && !key_down_flag){
            this.x += this.speed * sin(radians(this.theta));
            this.y -= this.speed * cos(radians(this.theta));
        }
        if(key_down_flag && !key_up_flag){
            this.x -= this.speed * sin(radians(this.theta));
            this.y += this.speed * cos(radians(this.theta));
        }
        if(key_right_flag && !key_left_flag){
            this.theta += this.rotateSpeed;
        }
        if(key_left_flag && !key_right_flag){
            this.theta -= this.rotateSpeed;
        }
    }
    private void show(){
        fill(PLAYERCOLORONE);
        pushMatrix();
        translate(this.x,this.y);
        rotate(radians(this.theta));
        rect(-this.edgeLength/2,-this.edgeLength/2,this.edgeLength,this.edgeLength);
        popMatrix();

        for(Bullet b:this.bullets){
            b.update();
        }
    }
    private void shot(){
        if(key_z_flag){
            bullets.add(new Bullet(this.x,this.y,this.theta));
        }
    }
}
void drawKey(float x,float y,char c,boolean flag){
    fill( flag ? 230 : 255);
    rect(-x/2,-y/2,x,y);
    fill(0);
    textAlign(CENTER,CENTER);
    textSize(30);
    text(c,0,0);
}
void drawKeyboard(){
    float drawWidth = width / 3;
    float drawHeight = height / 6;
    float x = drawWidth * 2;
    float y = 0;
    pushMatrix();
    translate(x,y);
    translate(-width / 100,height/100);

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
void setup(){
    size(800,900);
    player1 = new ShotMan(width/2,height/2);
}
void draw(){
    background(255);
    player1.update();
    drawKeyboard();

    text(key,width - 200,height - 100);
}

