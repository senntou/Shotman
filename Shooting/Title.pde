public class Title{
    float windowWidth,windowHeight;
    int selectingNumber;
    int maxLv;
    float interval;
    float textHeight;
    int upflag;
    int downflag;
    int zflag;
    
    public Title() {
        this.windowWidth  = width  * 0.7;
        this.windowHeight = height * 0.7;
        this.selectingNumber = 1;
        this.maxLv = 5;
        
        this.textHeight = this.windowHeight * 0.05;
        this.interval = this.textHeight;
        upflag = 0;
        downflag = 0;
        zflag = 0;
    }
    protected void show() {
        pushMatrix();
        translate(width / 2,height / 2);
        translate( -windowWidth / 2, -windowHeight / 2);
        
        fill(255);
        strokeWeight(3);
        stroke(0);
        rect(0,0,windowWidth,windowHeight);
        
        fill(0);
        translate(textHeight,textHeight);
        textSize(textHeight);
        textAlign(LEFT,CENTER);
        text("select enemy",0,0);
        
        translate(0,textHeight * 2);
        
        //選択肢の箇条書き
        for (int i = 1;i <= maxLv;i++) {
            fill(0);
            text("level" + i,0,0);
            if (selectingNumber == i) {
                stroke(255,100,100);
                line(0, - textHeight * 0.6,windowWidth - 2*textHeight, - textHeight * 0.6);
                line(0,textHeight * 0.6,windowWidth - 2*textHeight,textHeight * 0.6);
            }
            translate(0,textHeight + interval);
        }
        
        popMatrix();
    }
    public void gameStart(){
        switch (selectingNumber) {
                case 1:
                    gamemode = Gamemode.ACTIVE;
                    changePlayer2(new LevelOne(width / 2,height / 4));
                    player1.resetPoint();
                    break;
                case 2:
                    gamemode = Gamemode.ACTIVE;
                    changePlayer2(new LevelTwo(width/2,height/4));
                    player1.resetPoint();
                    break;
                case 3:
                    gamemode = Gamemode.ACTIVE;
                    changePlayer2(new LevelThree(width/2,height/4));
                    player1.resetPoint();
                    break;
                case 4:
                    gamemode = Gamemode.ACTIVE;
                    changePlayer2(new LevelFour(width/2,height/4));
                    player1.resetPoint();
                    player1.putUnder();
                    break;
                case 5:
                    gamemode = Gamemode.ACTIVE;
                    changePlayer2(new LevelFive(width/2,height/4));
                    player1.resetPoint();
                    player1.putUnder();
                    break;
            }
        player2.resetPoint();
    }
    public void update(){
        this.show();

        //カーソル移動
        if(key_up_flag)upflag++;
        if(key_down_flag)downflag++;
        if(key_z_flag)zflag++;

        if(!key_up_flag)upflag = 0;
        if(!key_down_flag)downflag = 0;
        if(!key_z_flag)zflag = 0;

        if(keyPressed && keyCode == UP && upflag == 1){
            selectingNumber = (selectingNumber - 1 + maxLv) % maxLv;
            if(selectingNumber == 0)selectingNumber = maxLv;
            upflag++;
        }
        if(keyPressed && keyCode == DOWN && downflag == 1){
            selectingNumber = (selectingNumber + 1 + maxLv) % maxLv;
            if(selectingNumber == 0)selectingNumber = maxLv;
        }
        //画面遷移
        if(key_enter_flag){
            this.gameStart();
        }
    }
}