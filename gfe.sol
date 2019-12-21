contract GFE{



struct  Player {

    uint256 pID;       
    address payable addr;      
    uint256 affId;      
    uint256 totalBet;  

    uint256 curGen;   
    uint256 curAff;    
    string  inviteCode;
   
    uint256 lastBet;   
    uint256 lastReleaseTime;
    bool    isaffer;

}

struct playerReward{
     uint256 canWithDrawGen;  
     uint256 canWithDrawAff;   
     uint256 reward;  
     uint256 totalGen;  
     uint256 totalAff; 
     uint256 deepAff;
     uint8   level; 
   

}


struct levelReward {    
    uint256 genRate;
    uint256 deepAff;

}


uint256 ethWei = 1 ether;

 uint256  private minbeteth_ = ethWei;         
 uint256 constant private getoutBeishu = 3;                                  
 uint256  genReleTime_ = 24  hours;              
 bool public activated_ = true;     
 mapping (string   => uint256) public pIDInviteCode_;
 mapping (address => uint256)   public pIDxAddr_;      

 uint256[30] affRate = [300,200,100,80,50,50,50,50,50,50,30,30,30,30,30,10,10,10,10,10,5,5,5,5,5,5,5,5,5,5];
 
uint256 public luckyPot_ = 0;
uint256 public openLuckycc_ = 100;
uint256  public  luckyRound_ = 1;

uint256 public Pot_ = 0;
uint256 public zTime_ = 240 hours;
uint256 public zStartTime_ = 0;
uint256  public  zhuoyueRound_ = 1;

modifier isActivated() {
    require(activated_ == true, "its not ready yet.  check ?eta in discord");
    _;
}


modifier isHuman() {
    address _addr = msg.sender;
    uint256 _codeLength;

    assembly {_codeLength := extcodesize(_addr)}
    require(_codeLength == 0, "sorry humans only");
    _;
}


modifier isWithinLimits(uint256 _eth) {
    require(_eth >= minbeteth_, "pocket lint: not a valid currency");
    require(_eth <= 100000000000000000000000, "no vitalik, no");
    _;
}

constructor()
public
{
    levelReward_[1] = levelReward(6,1);
    levelReward_[2] = levelReward(8,10);
    levelReward_[3] = levelReward(10,20);
    levelReward_[4] = levelReward(12,30);
   
}

function buyCore(uint256 _pID,uint256 _eth)
    private
{
    
   uint256 _com = _eth.mul(2)/100;
    if(_com>0){
        bose.transfer(_com);
    }
    
   uint256 _st = _eth.mul(3)/100;
    if(_st>0){
        sc.transfer(_st);
        sCoin = stTotalCoin.add(_st);
    }
    
    uint256 _baoxian = _eth.mul(1)/100;
    if(_baoxian>0){
        
        bc.transfer(_baoxian);
        bCoin = bxTotalCoin.add(_baoxian);
    }
    
    gBet_ = gBet_.add(_eth);
    gBetcc_= gBetcc_ + 1; 
   
    dealwithluckyPot(_pID,_eth);
    dealwithZhuoyuePot(_eth);
    
    checkOut(_pID);
    
    plyr_[_pID].totalBet = _eth.add(plyr_[_pID].totalBet);
    plyr_[_pID].lastBet  = _eth;
    plyrReward_[_pID].reward = _eth.mul(getoutBeishu).add(plyrReward_[_pID].reward);

    

    uint256 _curBaseGen = _eth.mul(levelReward_[getLevel(_eth)].genRate) /1000;
    plyr_[_pID].baseGen = plyr_[_pID].baseGen.add(_curBaseGen);

 
    affUpdate(_pID,_curBaseGen,0,1);

 

    if(!plyr_[_pID].isaffer){
        plyr_[_pID].isaffer = true;
    }
    
    plyrReward_[_pID].level = getLevel(plyr_[_pID].totalBet);
    plyr_[_pID].lastReleaseTime = now;
  


   
}

function checkInviteCode(string memory _code)  public view returns(uint256 _pID){
    
    _pID = pIDInviteCode_[_code];
    
}

function dealwithluckyPot (uint256 _pID,uint256 _eth) 
private 
{
   
     uint256 _luckpot = _eth.mul(15)/1000;
     luckyPot_ = luckyPot_.add(_luckpot);
     uint256 cc = gBetcc_%openLuckycc_;

     if(cc == 0){
       
        uint256 _pot = luckyPot_/3;
        for(uint256 i =0;i<luckyId_[luckyRound_].length;i++){

            playerPot_[luckyId_[luckyRound_][i]].luckpot = playerPot_[luckyId_[luckyRound_][i]].luckpot.add(_pot);
        }
        luckyRound_++;
        luckyPot_ = 0;
        
     }else{

      
       if(cc == 33 || cc == 66 || cc == 99){
            luckyId_[luckyRound_].push(_pID);
       }    
     }
     

}


function dealwithZhuoyuePot (uint256 _eth) 
private
{


    uint256 _zhuoyuepot = _eth.mul(2)/100;

    if(now - zuoyuePotDaoshuStartTime_ >= zuoyuePotDaoshuTime_){
        if(bestDongtaiBaseUser_[zhuoyueRound_].length>0){
        uint256 _pot = zhuoyuePot_/bestDongtaiBaseUser_[zhuoyueRound_].length;
        for(uint256 i =0;i<bestDongtaiBaseUser_[zhuoyueRound_].length;i++)
        {
            playerPot_[bestDongtaiBaseUser_[zhuoyueRound_][i]].zhuoyuepot = playerPot_[bestDongtaiBaseUser_[zhuoyueRound_][i]].zhuoyuepot.add(_pot);
           
        }
        zhuoyuePot_= 0;
        }
        zuoyuePotDaoshuStartTime_ = now;
        zhuoyueRound_++;
        
    }

    zhuoyuePot_ = zhuoyuePot_ .add(_zhuoyuepot);

}


function getLevel (uint256 _betEth) 
public
view
returns(uint8 level) 
{
    uint8 _level = 0;
     if(_betEth>=31 * ethWei){
        _level = 4;

    }else if(_betEth>=11 * ethWei){
        _level = 3;

    }else if(_betEth>=6 * ethWei){
        _level = 2;

    }else if(_betEth>=1 * ethWei){
        _level = 1;

    }
    return _level;
}


function getsystemMsg()
public
view
returns(uint256 _gbet,uint256 _gcc,uint256 _luckpot,uint256 _zypot,uint256 _zytime,uint256)
{
    return
    (
        gBet_,
        gBetcc_,
        luckyPot_,
        zPot_,
        luckyRound_,
        zRound_,
    
    );
}

function getbestDongtaiBaseUser (uint256 _rid,uint256 _weizhi) 
public
view
returns(uint256 _pID,uint256 _totalBet,uint256 _baseAff) 
{
     _pID = bestDongtaiBaseUser_[_rid][_weizhi];
    return
    (
        _pID,
        plyr_[_pID].totalBet,
        affBijiao_[_rid][_pID]

    );
}
function compareStr(string memory _str, string memory str) internal pure returns(bool) {
        if (keccak256(abi.encodePacked(_str)) == keccak256(abi.encodePacked(str))) {
            return true;
        }
        return false;
    }

}