import java.util.ArrayList;

final float SHOTMANSPEED = 8;
final float BULLETSPEED = 14;
final float BULLETRADIUS = 5;
final float SHOTMANROTATESPEED = 6;
final int DAMAGE_EFFECT_FRAME = 12;
final float SMALL_RECT_SIZE = 30;
final int PLAYER_HP = 100;

final boolean DEBUG_DONT_MOVE_PLAYERTWO = true;

final boolean DRAW_KEYBOARD_FLAG = true;

final int PLAYER_COLOR[] = { 0 , 255 };

boolean key_up_flag = false;
boolean key_down_flag = false;
boolean key_right_flag = false;
boolean key_left_flag = false;
boolean key_ENTER_flag = false;

boolean key_w_flag = false;
boolean key_a_flag = false;
boolean key_s_flag = false;
boolean key_d_flag = false;
boolean key_z_flag = false;

boolean key_r_flag = false;

ShotMan player1;
ShotMan player2;

void keyPressed(){
    if(keyCode == UP) key_up_flag = true;
    if(keyCode == DOWN) key_down_flag = true;
    if(keyCode == RIGHT) key_right_flag = true;
    if(keyCode == LEFT) key_left_flag = true;
    if(key == 'z') key_z_flag = true;

    if(key == 'w') key_w_flag = true;
    if(key == 'a') key_a_flag = true;
    if(key == 's') key_s_flag = true;
    if(key == 'd') key_d_flag = true;
    if(keyCode == ENTER) key_ENTER_flag = true;

    if(key == 'r' && !key_r_flag){
        key_r_flag = true;
        reset();
    }
}
void keyReleased() {
    if(keyCode == UP) key_up_flag = false;
    if(keyCode == DOWN) key_down_flag = false; 
    if(keyCode == LEFT) key_left_flag = false;
    if(keyCode == RIGHT) key_right_flag = false;
    if(key == 'z') key_z_flag = false;

    if(key == 'w') key_w_flag = false;
    if(key == 'a') key_a_flag = false;
    if(key == 's') key_s_flag = false;
    if(key == 'd') key_d_flag = false;
    if(keyCode == ENTER) key_ENTER_flag = false;

    if(key == 'r') key_r_flag = false;
}
public boolean circleInRect(float x,float y,float r,float x1,float y1,float x2,float y2){
    if( x1 <= x && x <= x2 && y1 - r <= y && y <= y2 + r){
        return true;
    }
    if( x1 - r <= x && x <= x2 + r && y1 <= y && y <= y2){
        return true;
    }
    if( (x1 - x) * (x1 - x) + (y1 - x) * (y1 - x) <= r*r ) return true;
    if( (x1 - x) * (x1 - x) + (y2 - x) * (y2 - x) <= r*r ) return true;
    if( (x2 - x) * (x2 - x) + (y1 - x) * (y1 - x) <= r*r ) return true;
    if( (x2 - x) * (x2 - x) + (y2 - x) * (y2 - x) <= r*r ) return true;

    return false;


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
    public float getX(){
        return this.x;
    }
    public float getY(){
        return this.y;
    }
    public float getRadius(){
        return this.radius;
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
        
        /*
        textSize(10);
        text("(*∂ｖ∂)",this.x,this.y);
        */
    }
}
public class SmallRect{
    float x,y;
    float theta;
    float rotateTheta;
    float speed;
    float accelerationRate;
    float transparency;
    color clr;

    boolean finished;
    public SmallRect(float x,float y,float theta,float speed,color clr){
        this.x = x;
        this.y = y;
        this.theta = theta;
        this.rotateTheta = this.theta * 2;
        this.speed = speed;
        this.accelerationRate = 0.95;
        this.transparency = 255;
        this.clr = clr;
    }
    public void update(){
        this.move();
        this.show();
    }
    protected void show(){
        fill(this.clr,this.transparency);
        stroke(0,this.transparency);
        pushMatrix();
        translate(x,y);

        rotate(radians(this.rotateTheta));

        rect(- SMALL_RECT_SIZE/2, - SMALL_RECT_SIZE/2,SMALL_RECT_SIZE,SMALL_RECT_SIZE);
        popMatrix();

        this.rotateTheta += 10;
        this.transparency -= 2;
    }
    protected void move(){
        this.x += this.speed * sin(radians(this.theta));
        this.y -= this.speed * cos(radians(this.theta));

        this.speed *= this.accelerationRate;
    }
    public boolean finished(){
        return this.transparency <= 0;
    }
}
public class DestroyMotion{
    float x,y;
    color clr;
    ArrayList<SmallRect> rects;
    int num;

    public DestroyMotion(float x,float y,color clr){
        this.x = x;
        this.y = y;
        this.clr = clr;
        this.num = 50;
        rects = new ArrayList<SmallRect>();
        for(int i = 0;i < num;i++){
            float theta = random(0,360);
            float speed = random(5,10);
            rects.add( new SmallRect(x,y,theta,speed,clr) );
        }
    }
    public void show(){
        for(int i = 0;i < num;i++){
            rects.get(i).update();
        }
    }
    public boolean finished(){
        return rects.get(0).finished();
    }
}
abstract class ShotMan{
    protected float theta;
    protected float speed;
    protected float rotateSpeed;
    public float x,y;
    //rect
    public float edgeLength;
    protected int bodyColor;
    protected int damageFlag;
    protected boolean aliveFlag;
    protected boolean motionFlag;
    protected DestroyMotion dMotion;

    protected int HP;

    public ArrayList<Bullet> bullets;

    public ShotMan(float x,float y,float theta){
        this.theta = theta;
        this.speed = SHOTMANSPEED;
        this.rotateSpeed = SHOTMANROTATESPEED;
        this.x = x;
        this.y = y;
        this.edgeLength = 50;
        this.bullets = new ArrayList<Bullet>();
        this.bodyColor = PLAYER_COLOR[0];
        this.damageFlag = 0;
        this.aliveFlag = true;
        this.motionFlag = false;
        this.dMotion = new DestroyMotion(this.x,this.y,color(this.bodyColor));
        this.HP = PLAYER_HP;
    }
    public ShotMan(float x,float y){
        this(x,y,0);
    }
    public void setColor(int i){
      this.bodyColor = PLAYER_COLOR[i];
    }
    public void update(){
        this.move();
        this.shot();
        if(this.aliveFlag){
            this.show();
            this.drawHP();
        } else {
            this.dMotion.show();
            if( this.dMotion.finished() ) this.motionFlag = false;
        }

    }
    public boolean isActive(){
        return this.aliveFlag || this.motionFlag;
    }
    abstract void move();
    protected void show(){
        fill(this.bodyColor);
        stroke(0,255);
        if(this.damageFlag != 0){
            damageFlag = (damageFlag + 1) % DAMAGE_EFFECT_FRAME;
            fill(255,150,150);
        }

        for(Bullet b:this.bullets){
            b.update();
        }

        pushMatrix();
        translate(this.x,this.y);
        rotate(radians(this.theta));
        rect(-this.edgeLength/2,-this.edgeLength/2,this.edgeLength,this.edgeLength);
        popMatrix();

        
    }
    public void damaged(int d){
        damageFlag = 1;
        if(HP > 0)this.HP -= d;
        if(HP <= 0){
            HP = 0;
            this.destroy();
        }
    }
    public void destroy(){
        if(this.aliveFlag){
            this.aliveFlag = false;
            this.dMotion = new DestroyMotion(this.x,this.y,color(this.bodyColor));
            this.motionFlag = true;
        }
    }
    abstract void shot();
    public float getX1(){
        return this.x - this.edgeLength / 2;
    }
    public float getY1(){
        return this.y - this.edgeLength / 2;
    }
    public float getX2(){
        return this.x + this.edgeLength/2;
    }
    public float getY2(){
        return this.y + this.edgeLength/2;
    }
    public void drawHP(){
        pushMatrix();
        float barWidth = 100;
        float barHeight = 10;
        float margin = 50;

        fill(255,0);
        translate(this.x,this.y);
        rect(-barWidth/2,-margin,barWidth,barHeight);
        
        fill(0);
        rect(-barWidth/2,-margin,barWidth * this.HP / PLAYER_HP,barHeight);

        popMatrix();
    }
}
public class PlayerOne extends ShotMan{
    public PlayerOne(float x,float y){
        super(x,y,0);
    }
    public void update(){
        this.checkCollision();
        super.update();
    }
    public void move(){
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
    public void shot(){
        if(key_ENTER_flag){
            bullets.add(new Bullet(this.x,this.y,this.theta));
        }
    }
    public void checkCollision(){
        for(Bullet b : this.bullets){
            if(circleInRect(b.getX(),b.getY(),b.getRadius(),
            player2.getX1(), player2.getY1(), player2.getX2(), player2.getY2()) ){
                    player2.damaged(1);
                }
        }
    }
}
public class PlayerTwo extends ShotMan{
    public PlayerTwo(float x,float y){
        super(x,y,180);
    }
    public void update(){
        this.checkCollision();
        super.update();
    }
    public void move(){
        if(key_w_flag && !key_s_flag){
            this.x += this.speed * sin(radians(this.theta));
            this.y -= this.speed * cos(radians(this.theta));
        }
        if(key_s_flag && !key_w_flag){
            this.x -= this.speed * sin(radians(this.theta));
            this.y += this.speed * cos(radians(this.theta));
        }
        if(key_d_flag && !key_a_flag){
            this.theta += this.rotateSpeed;
        }
        if(key_a_flag && !key_d_flag){
            this.theta -= this.rotateSpeed;
        }
        //text(this.speed,100,100);
    }
    public void shot(){
        if(key_z_flag){
            bullets.add(new Bullet(this.x,this.y,this.theta));
        }
    }
    public void checkCollision(){
        for(Bullet b : this.bullets){
            if(circleInRect(b.getX(),b.getY(),b.getRadius(),
            player1.getX1(), player1.getY1(), player1.getX2(), player1.getY2()) ){
                    player1.damaged(1);
                }
        }
    }
}
public void reset(){
    player1 = new PlayerOne(width/2,height/2);
    player1.setColor(0);
    player2 = new PlayerTwo(width/2,height/4);
    player2.setColor(1);
}
void drawKey(float x,float y,char c,boolean flag){
    fill( flag ? 230 : 255);
    stroke(0);
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
    frameRate(60);
    smooth();
    reset();
}
void draw(){
    background(255);
    if(player1.isActive())player1.update();
    if(player2.isActive())player2.update();
    drawKeyboard();

    //text(key,width - 200,height - 100);
}
