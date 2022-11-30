public class Bullet{
    protected float theta;
    protected float x,y;
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
        this(x,y,theta,BULLET_SPEED,BULLET_RADIUS);
    }
    public Bullet(float x,float y,float theta,float speed){
        this(x,y,theta,speed,BULLET_RADIUS);
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
    public float getSpeed(){
        return this.speed;
    }   
    public void update(){
        this.move();
        this.show();
    }
    protected void move(){
        this.x += this.speed * sin(radians(this.theta));
        this.y -= this.speed * cos(radians(this.theta));
    }
    protected void show(){
        ellipse(this.x,this.y,this.radius*2,this.radius*2);
    }
}
public class TrackingBullet extends Bullet{
    private ShotMan enemy;
    private int frameCount;
    private int maxFrame;
    public TrackingBullet(float x,float y,float theta,float speed,float radius,ShotMan enemy){
        super(x,y,theta,speed,radius);
        this.enemy = enemy;
        this.frameCount = 0;
        this.maxFrame = 120;
    }
    public TrackingBullet(float x,float y,float theta,float speed,ShotMan enemy){
        this(x,y,theta,speed,BULLET_RADIUS,enemy);
    }
    public TrackingBullet(float x,float y,float theta,ShotMan enemy){
        this(x,y,theta,BULLET_SPEED,BULLET_RADIUS,enemy);
    }
    protected void move(){
        frameCount = constrain(frameCount + 1,0,maxFrame);
        //NPC.aim(float x,float y) と同じような処理を考えて、敵をホーミングする
        float dx = enemy.getX() - this.getX();
        float dy = -(enemy.getY() - this.getY());
        float targetDirection;
        if(dy == 0){
            if(dx >= 0) targetDirection = 90;
            else targetDirection = 270;
        } else {
            targetDirection = degrees(atan(dx/dy));
        }
        if(dy < 0) targetDirection += 180;

        //向いている方向が、敵の左側か、右側かを考える
        float dstx = this.getX() + sin(radians(this.theta)) * 10;
        float dsty = this.getY() - cos(radians(this.theta)) * 10;

        //ホーミングの角速度は時間で変化させる
        float rotateSpeed = TRACKING_BULLET_MAX_ROTATING_SPEED * 0.5 * 
        (-cos(2 * PI * frameCount / maxFrame) + 1) * (-cos(2 * PI * frameCount / maxFrame) + 1);

        //自分が敵の左側を向いている場合
        if(pointAndLine(enemy.getX(),enemy.getY(),this.getX(),this.getY(),dstx,dsty)){
            this.theta -= rotateSpeed;
        } else {
            this.theta += rotateSpeed;
        }
        float nxtx = this.getX() + sin(radians(this.theta)) * 10;
        float nxty = this.getY() - cos(radians(this.theta)) * 10;
        
        if(pointAndLine(enemy.getX(),enemy.getY(),this.getX(),this.getY(),dstx,dsty) 
            != pointAndLine(enemy.getX(),enemy.getY(),this.getX(),this.getY(),nxtx,nxty)){
                this.theta = targetDirection;
        }

        super.move();
    }
}
public class SpiralBullet extends Bullet{
    private float a;
    private float r;
    private float firstX,firstY;
    SpiralBullet(float x,float y,float theta,float speed,float radius){
        super(x,y,theta,speed,radius);
        this.r = 0;
        this.firstX = x;
        this.firstY = y;
        this.a = 500;
    }
    SpiralBullet(float x,float y,float theta,float speed){
        this(x,y,theta,speed,BULLET_RADIUS);
    }
    SpiralBullet(float x,float y,float theta){
        this(x,y,theta,BULLET_SPEED,BULLET_RADIUS);
    }
    public void move(){
        r += this.getSpeed()/a;
        this.x = -( a*r*cos(r)*cos(radians(theta)) - a*r*sin(r)*sin(radians(theta)) ) + firstX;
        this.y = -( a*r*cos(r)*sin(radians(theta)) + a*r*sin(r)*cos(radians(theta)) ) + firstY;
    }
}
public class Ray{
    private float x1,y1,x2,y2;
    private float rayWidth;
    private float length;
    private float theta;
    private float speed;
    private color clr;
    public Ray(float x,float y,float theta,color clr){
        this.x1 = x;
        this.y1 = y;
        this.x2 = x;
        this.y2 = y;
        this.rayWidth = 7;
        this.length = RAY_LENGTH;
        this.theta = theta;
        this.speed = RAY_SPEED;
        this.clr = clr;
    }
    public void update(){
        move();
        show();
    }
    protected void move(){
        this.x2 += this.speed * sin(radians(this.theta));
        this.y2 -= this.speed * cos(radians(this.theta));

        if( (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1) >= length * length ){
            this.x1 = this.x2 - this.length * sin(radians(this.theta));
            this.y1 = this.y2 + this.length * cos(radians(this.theta));
        }
    }
    protected void show(){
        strokeWeight((this.rayWidth));
        stroke(clr);
        line(x1,y1,x2,y2);
        strokeWeight(1);
    }
    public float getX1(){
        return this.x1;
    }
    public float getX2(){
        return this.x2;
    }
    public float getY1(){
        return this.y1;
    }
    public float getY2(){
        return this.y2;
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
        strokeWeight(1);
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

