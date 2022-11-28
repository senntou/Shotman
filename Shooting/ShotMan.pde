abstract class ShotMan{
    protected float theta;
    protected float speed;
    protected float rotateSpeed;
    protected float x,y;
    //rect
    public float edgeLength;
    protected int bodyColor;
    protected int damageFlag;
    protected boolean aliveFlag;
    protected boolean motionFlag;
    protected DestroyMotion dMotion;

    protected int bulletDamage;
    
    protected int maxHP;
    protected int HP;
    //BulletとRayはハッシュマップみたいな感じでとってる
    public Map<Integer,Bullet> bullets;
    public Map<Integer,Ray> rays;
    
    protected int beamFrameCount;
    protected int bulletFrameCount;
    protected int bulletBetweenFrame;
    protected ShotMan enemy;
    
    public ShotMan(float x,float y,float theta) {
        this.theta = theta;
        this.speed = SHOTMAN_SPEED;
        this.rotateSpeed = SHOTMAN_ROTATE_SPEED;
        this.x = x;
        this.y = y;
        this.edgeLength = 50;
        this.bullets = new HashMap<Integer,Bullet>();
        this.rays = new HashMap<Integer,Ray>();
        this.bodyColor = PLAYER_COLOR[0];
        this.damageFlag = 0;
        this.aliveFlag = true;
        this.motionFlag = false;
        this.dMotion = new DestroyMotion(this.x,this.y,color(this.bodyColor));
        this.maxHP = PLAYER_HP;
        this.HP = PLAYER_HP;
        this.beamFrameCount = 0;
        this.bulletBetweenFrame = 2;
        this.bulletFrameCount = 0;
        this.bulletDamage = BULLET_DAMAGE;
        this.setEnemy();
    }
    public ShotMan(float x,float y) {
        this(x,y,0);
    }
    abstract void setEnemy();
    public void setColor(int i) {
        this.bodyColor = PLAYER_COLOR[i];
    }
    public void update() {
        this.checkCollision();
        this.countBulletFrame();
        this.move();
        this.shot();
        this.beam();
        if (this.aliveFlag) {
            this.show();
            this.drawHP();
        } else {
            this.dMotion.show();
            if (this.dMotion.finished()) this.motionFlag = false;
        }
        
    }
    private void countBulletFrame(){
        if(this.bulletFrameCount != 0) bulletFrameCount = (bulletFrameCount + 1) % bulletBetweenFrame;
    }
    protected void setBulletBetweenFrame(int x){
        this.bulletBetweenFrame = x;
    }
    protected void setBulletDamage(int x){
        this.bulletDamage = x;
    }
    public boolean isActive() {
        return this.aliveFlag || this.motionFlag;
    }
    public boolean isAlive() {
        return this.aliveFlag;
    }
    abstract void move();
    protected void drive() {
        this.x += this.speed * sin(radians(this.theta));
        this.y -= this.speed * cos(radians(this.theta));
        this.x = constrain(this.x,0,width);
        this.y = constrain(this.y,0,height);
    }
    protected void back() {
        this.x -= this.speed * sin(radians(this.theta));
        this.y += this.speed * cos(radians(this.theta));
    }
    protected void turnRight() {
        this.theta += this.rotateSpeed;
    }
    protected void turnLeft() {
        this.theta -= this.rotateSpeed;
    }
    protected void show() {
        fill(this.bodyColor);
        stroke(0,255);
        strokeWeight(1);
        
        for (Bullet b : this.bullets.values()) {
            b.update();
        }
        for (Ray r : this.rays.values()) {
            r.update();
        }

        fill(this.bodyColor);
        if (this.damageFlag != 0) {
            damageFlag = (damageFlag + 1) % DAMAGE_EFFECT_FRAME;
            fill(255,150,150);
        }
        stroke(0,255);
        strokeWeight(1);
        pushMatrix();
        translate(this.x,this.y);
        rotate(radians(this.theta));
        rect( -this.edgeLength / 2, -this.edgeLength / 2,this.edgeLength,this.edgeLength);
        popMatrix();    
    }
    public void damaged(int d) {
        damageFlag = 1;
        if (HP > 0)this.HP -= d;
        if (HP <= 0) {
            HP = 0;
            this.destroy();
        }
    }
    public void destroy() {
        if (this.aliveFlag) {
            this.aliveFlag = false;
            this.dMotion = new DestroyMotion(this.x,this.y,color(this.bodyColor));
            this.motionFlag = true;
        }
    }
    public void shot() {
        if (beamFrameCount != 0) return;
        if (bulletFrameCount != 0) return;
        bulletFrameCount += 1;
        
        int num = (int)random(0,10000);
        while(bullets.containsKey(num)) {
            num = (num + 1) % 10000;
        }
        bullets.put(num,new Bullet(this.x,this.y,this.theta));
    }
    public void beam(boolean keyflag) {
        if (keyflag && beamFrameCount == 0) {
            beamFrameCount++;
            int num = (int)random(0,10000);
            while(rays.containsKey(num)) {
                num = (num + 1) % 10000;
            }
            rays.put(num,new Ray(this.x,this.y,this.theta,color(this.bodyColor)));
        } else if (beamFrameCount != 0) {
            beamFrameCount = (beamFrameCount + 1) % RAY_EMIT_FRAME;
        }
    }
    abstract void beam();
    protected void checkCollision() {
        ArrayList<Integer> bulletFlag = new ArrayList<Integer>();
        for (int i : this.bullets.keySet()) {
            Bullet b = bullets.get(i);
            if (circleInRect(b.getX(),b.getY(),b.getRadius(),
                enemy.getX1(), enemy.getY1(), enemy.getX2(), enemy.getY2(),
                enemy.getX3(), enemy.getY3(), enemy.getX4(), enemy.getY4())
                && enemy.isAlive()) {
                enemy.damaged(this.bulletDamage);
                bulletFlag.add(i);
            }
            else if (b.getX() <= -b.getRadius() || width + b.getRadius() <= b.getX()
                || b.getY() <= -b.getRadius() || height + b.getRadius() <= b.getY()) {
                bulletFlag.add(i);
            }
        }
        for (int i : bulletFlag) {
            bullets.remove(i);
        }
        for (Ray r : this.rays.values()) {
            if (rayInShotMan(r,enemy)) {
                enemy.damaged(RAY_DAMAGE);
            }
        }
    }
    public void resetPoint(){
        this.x = random(0,width);
        this.y = random(0,height);
    }
    //位置を下の方にする
    public void putUnder(){
        this.y = random(height*8/10,height);
    }
    public float getX(){
        return this.x;
    }
    public float getY(){
        return this.y;
    }
    public float getX1() {
        return this.x + this.edgeLength * sin(radians(this.theta - 45)) / sqrt(2);
    }
    public float getY1() {
        return this.y - this.edgeLength * cos(radians(this.theta - 45)) / sqrt(2);
    }
    public float getX2() {
        return this.x + this.edgeLength * sin(radians(this.theta + 45)) / sqrt(2);
    }
    public float getY2() {
        return this.y - this.edgeLength * cos(radians(this.theta + 45)) / sqrt(2);
    }
    public float getX3() {
        return this.x + this.edgeLength * sin(radians(this.theta - 135)) / sqrt(2);
    }
    public float getY3() {
        return this.y - this.edgeLength * cos(radians(this.theta - 135)) / sqrt(2);
    }
    public float getX4() {
        return this.x + this.edgeLength * sin(radians(this.theta + 135)) / sqrt(2);
    }
    public float getY4() {
        return this.y - this.edgeLength * cos(radians(this.theta + 135)) / sqrt(2);
    }
    public void drawHP() {
        strokeWeight(1);
        pushMatrix();
        float barWidth = 100;
        float barHeight = 10;
        float margin = 50;
        
        fill(255,0);
        translate(this.x,this.y);
        rect( -barWidth / 2, -margin,barWidth,barHeight);
        
        fill(0);
        rect( -barWidth / 2, -margin,barWidth * this.HP / this.maxHP,barHeight);
        
        popMatrix();
    }
    protected void increaseHP(float zoomRate){
        this.HP *= zoomRate;
        this.maxHP *= zoomRate;
    }
}
public class PlayerOne extends ShotMan{
    public PlayerOne(float x,float y) {
        super(x,y,0);
        super.setColor(0);
    }
    public void move() {
        if (key_up_flag && !key_down_flag) {
            super.drive();
        }
        if (key_down_flag && !key_up_flag) {
            super.back();
        }
        if (key_right_flag && !key_left_flag) {
            super.turnRight();
        }
        if (key_left_flag && !key_right_flag) {
            super.turnLeft();
        }
        
        if (x <= 0) x = 0;
        if (width <= x) x = width;
        if (y <= 0) y = 0;
        if (height <= y) y = height;
    }
    public void shot() {
        if (key_z_flag) {
            super.shot();
        }
    }
    public void beam() {
        super.beam(key_x_flag);
    }
    public void setEnemy(){
        this.enemy = player2;
    }
}
public class PlayerTwo extends ShotMan{
    public PlayerTwo(float x,float y) {
        super(x,y,180);
        super.setColor(1);
    }
    public void move() {
        if (key_w_flag && !key_s_flag) {
            super.drive();
        }
        if (key_s_flag && !key_w_flag) {
            super.back();
        }
        if (key_d_flag && !key_a_flag) {
            super.turnRight();
        }
        if (key_a_flag && !key_d_flag) {
            super.turnLeft();
        }
        
        if (x <= 0) x = 0;
        if (width <= x) x = width;
        if (y <= 0) y = 0;
        if (height <= y) y = height;
        //text(this.speed,100,100);
    }
    public void shot() {
        if (key_enter_flag) {
            super.shot();
        }
    }
    public void beam() {
        super.beam(false);
    }
    public void setEnemy(){
        this.enemy = player1;
    }
}
