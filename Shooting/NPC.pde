abstract class NPC extends ShotMan{
    protected boolean beamFlag;
    protected boolean shotFlag;

    protected boolean aimFinished;

    protected boolean targeting;

    int escape_state;
    float escape_for_theta;
    int escape_framecount;

    public NPC(float x,float y){
        super(x,y,180);
        this.beamFlag = false;
        this.shotFlag = false;
        this.targeting = false;
        super.setColor(1);
        this.aimFinished = false;
        escape_state = 0;
        escape_framecount = 0;
    }
    public NPC(){
        this(width/2,height/4);
    }
    public void setEnemy(){
        this.enemy = player1;
    }
    public void update(){
        super.update();
    }
    abstract void move();
    public void beam(){
        super.beam(this.beamFlag);
    }
    public void shot(){
        if(this.shotFlag) super.shot();
    }
    protected void shotEnemy(){
        this.shotFlag = true;
        this.aim();
    }
    protected boolean aim(){
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
        float dstx = this.x + sin(radians(this.theta)) * 10;
        float dsty = this.y - cos(radians(this.theta)) * 10;

        //自分が敵の左側を向いている場合
        if(pointAndLine(enemy.getX(),enemy.getY(),this.x,this.y,dstx,dsty)){
            this.theta -= SHOTMAN_ROTATE_SPEED;
        } else {
            this.theta += SHOTMAN_ROTATE_SPEED;
        }
        float nxtx = this.x + sin(radians(this.theta)) * 10;
        float nxty = this.y - cos(radians(this.theta)) * 10;
        
        if(pointAndLine(enemy.getX(),enemy.getY(),this.x,this.y,dstx,dsty) 
            != pointAndLine(enemy.getX(),enemy.getY(),this.x,this.y,nxtx,nxty)){
                this.theta = targetDirection;
                return true;
        }
        
        //for DEBUG
        /*
        {
            fill(255,0,0);
            float tarx = this.x + sin(radians(targetDirection)) * 1000;
            float tary = this.y - cos(radians(targetDirection)) * 1000;
            line(this.x,this.y,tarx,tary);
            text(targetDirection,100,100);

            ellipse((this.getX1() + this.getX2()) / 2,(this.getY1()+this.getY2())/2,50,50);
        }
        */
        return false;
    }
    protected boolean aim(float x,float y){
        float dx = x - this.getX();
        float dy = -(y - this.getY());
        float targetDirection;
        if(dy == 0){
            if(dx >= 0) targetDirection = 90;
            else targetDirection = 270;
        } else {
            targetDirection = degrees(atan(dx/dy));
        }
        if(dy < 0) targetDirection += 180;

        //向いている方向が、敵の左側か、右側かを考える
        float dstx = this.x + sin(radians(this.theta)) * 10;
        float dsty = this.y - cos(radians(this.theta)) * 10;

        //自分が敵の左側を向いている場合
        if(pointAndLine(x,y,this.x,this.y,dstx,dsty)){
            this.theta -= SHOTMAN_ROTATE_SPEED;
        } else {
            this.theta += SHOTMAN_ROTATE_SPEED;
        }
        float nxtx = this.x + sin(radians(this.theta)) * 10;
        float nxty = this.y - cos(radians(this.theta)) * 10;
        
        if(pointAndLine(x,y,this.x,this.y,dstx,dsty) 
            != pointAndLine(x,y,this.x,this.y,nxtx,nxty)){
                this.theta = targetDirection;
                return true;
        }
        
        //for DEBUG
        /*
        {
            fill(255,0,0);
            float tarx = this.x + sin(radians(targetDirection)) * 1000;
            float tary = this.y - cos(radians(targetDirection)) * 1000;
            line(this.x,this.y,tarx,tary);
            text(targetDirection,100,100);

            ellipse((this.getX1() + this.getX2()) / 2,(this.getY1()+this.getY2())/2,50,50);
        }
        */
        return false;
    }
    protected boolean aim(float theta){
        float distLeft = (this.theta - theta + 360) % 360;
        float distRight = (theta - this.theta + 360) % 360;
        if(distLeft <= SHOTMAN_ROTATE_SPEED || distRight <= SHOTMAN_ROTATE_SPEED){
            this.theta = theta;
            return true;
        }
        if(distLeft >= distRight){
            this.theta += SHOTMAN_ROTATE_SPEED;
        } else {
            this.theta -= SHOTMAN_ROTATE_SPEED;
        }
        return false;
    }
    protected boolean escape(){
        //escape_state
        //0 -> 開始　1 -> 回転中　2 -> 移動中　

        //targetDirectionの確定
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

        //escapeの方向に、デバッグ用にガイドを表示
        //lineFromPoint(this.getX(),this.getY(),targetDirection - 60);
        //lineFromPoint(this.getX(),this.getY(),targetDirection + 60);

        switch(escape_state){
            case 0:
                //自分からenemyに向かうベクトルが画面の中央点の右にむかっていればtrue
                if(pointAndLine( width/2,height/2,getX(),getY(),
                getX() + sin(radians(targetDirection)) * 100,
                getY() - cos(radians(targetDirection)) * 100) ){
                    this.escape_for_theta = targetDirection - 60;
                }
                else this.escape_for_theta = targetDirection + 60;

                this.escape_for_theta = (this.escape_for_theta + 360) % 360;

                this.escape_state += 1;
            break;
            case 1:
                if(this.aim(escape_for_theta)) escape_state += 1;
                this.drive();
            break;
            case 2:
                if(escape_framecount++ <= 60) this.drive();
                else {
                    escape_framecount = 0;
                    escape_state = 0;
                    return true;
                }
            break;
            default:
                escape_framecount = 0;
                escape_state = 0;
                return true;
        }
        return false;
    }

    protected void lineFromPoint(float x,float y,float theta){
        stroke(255,0,0);
        line(x,y,x + sin(radians(theta)) * 1000,y - cos(radians(theta)) * 1000);
    }
}

public class LevelOne extends NPC{
    int nextPointNum;
    float pointx[];
    float pointy[];
    boolean moveFlag;
    int frameCount;
    public LevelOne(float x,float y){
        super(x,y);
        float unitx = width * 0.1;
        float unity = height * 0.1;
        this.pointx = new float[]{unitx,width - unitx,width - unitx,unitx};
        this.pointy = new float[]{unity,unity,height - unity,height-unity};
        this.nextPointNum = -1;
        this.moveFlag = false;
        this.frameCount = 0;
    }
    public void update(){
        aimFinished = false;
        frameUpdate();
        if(this.shotFlag){
            this.aim();
        } else {
            if(this.targeting) aimFinished = this.aim(pointx[nextPointNum],pointy[nextPointNum]);
            if(this.moveFlag) this.moveToPoint();
        }
        super.update();
    }
    public void frameUpdate(){
        this.frameCount = (frameCount + 1) % 100;
        if(frameCount == 0) this.shotFlag = random(0,100) < 30 ? true : false;
    }
    public void move(){
        if(this.aimFinished){
            targeting = false;
            moveFlag = true;
        }
        if(!moveFlag && !targeting){
            targeting = true;
            nextPointNum = (nextPointNum + 1) % 4;
        }
    }
    public void moveToPoint(){
        this.drive();
        //後ろにいるときを直線を使用して判定
        float leftx = this.x - cos(radians(theta)) * 100;
        float lefty = this.y - sin(radians(theta)) * 100;

        float rightx = this.x + cos(radians(theta)) * 100;
        float righty = this.y + sin(radians(theta)) * 100;

        if( !pointAndLine(pointx[nextPointNum],pointy[nextPointNum],
            leftx,lefty,rightx,righty) ) {
                this.moveFlag = false;
        };

    }
}

public class LevelTwo extends NPC{
    private int targetingFrameCount;
    public LevelTwo(float x,float y){
        super(x,y);
        this.targetingFrameCount = 0;
    }
    public void update(){
        aimFinished = false;
        if(this.targeting) aimFinished = this.aim();

        super.update();
    }
    public void move(){
        targetingFrameCount++;
        if(!enemy.isAlive()){
            this.targeting = false;
            this.shotFlag = false;
            return ;
        }
        if(( targetingFrameCount / 60) % 2 == 0){
            this.targeting = true;
            this.shotFlag = false;
        } else {
            this.targeting = true;
            this.shotFlag = true;
        }
    }
}

public class LevelThree extends NPC{
    private int frameCount;
    private boolean escaping;
    private int shootingFrame;
    public LevelThree(float x,float y){
        super(x,y);
        this.frameCount = 0;
        this.escaping = true;
        this.shootingFrame = 80;
    }
    public void move(){
        if(escaping){
            if(escape())escaping = false;
            shotFlag = false;
        }
        else {
            if(frameCount++ <= this.shootingFrame) shotEnemy();
            else {
                frameCount = 0;
                escaping = true;
            }
        }
    }
}
public class LevelFour extends NPC{
    public LevelFour(float x,float y){
        super(x,y);
        this.setBulletBetweenFrame(8);
        this.setBulletDamage(BULLET_DAMAGE * 4);
        this.increaseHP(1.8);
    }
    public void shot(){
        if (this.beamFrameCount != 0) return;
        if (this.bulletFrameCount != 0) return;
        this.bulletFrameCount += 1;
        
        int num = (int)random(0,10000);
        while(bullets.containsKey(num)) {
            num = (num + 1) % 10000;
        }
        bullets.put(num,new TrackingBullet(
            this.x,this.y,this.theta,BULLET_SPEED / 4,BULLET_RADIUS*3/4,this.enemy));
    }
    public void move(){
        if(!enemy.isActive()) return ;
        this.aim();
        this.shot();
    }
    public void resetPoint(){
        this.x = width/2;
        this.y = height/12;
    }
}
public class LevelFive extends NPC{
    public LevelFive(float x,float y){
        super(x,y);
    }
    public void shot(){
        if (this.beamFrameCount != 0) return;
        if (this.bulletFrameCount != 0) return;
        this.bulletFrameCount += 1;
        
        for(int i = 0;i < 4;i++){
            int num = (int)random(0,10000);
            while(bullets.containsKey(num)) {
                num = (num + 1) % 10000;
            }
            bullets.put(num,new SpiralBullet(this.x,this.y,(this.theta + i * 90) % 360) );
        }
    }
    public void move(){
        if(!enemy.isActive()) return ;
        this.shot();
    }
    public void resetPoint(){
        this.x = width/2;
        this.y = height/12;
    }
}