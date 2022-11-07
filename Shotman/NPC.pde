abstract class NPC extends ShotMan{
    protected boolean beamFlag;
    protected boolean shotFlag;

    //デフォルトの動き
    //ex)targeting is true => 相手にエイム
    protected boolean targeting;
    public NPC(float x,float y){
        super(x,y,180);
        this.beamFlag = false;
        this.shotFlag = false;
        this.targeting = false;
        super.setColor(1);
    }
    public void setEnemy(){
        this.enemy = player1;
    }
    public void update(){
        if(this.targeting) this.aim();
        
        super.update();
    }
    abstract void move();
    public void beam(){
        super.beam(this.beamFlag);
    }
    public void shot(){
        if(this.shotFlag) super.shot();
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
}
public class LevelOne extends NPC{
    private int targetingFrameCount;
    public LevelOne(float x,float y){
        super(x,y);
        this.targetingFrameCount = 0;
    }
    public void update(){
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