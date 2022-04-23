pragma solidity ^0.4.18;

contract uap 
{
    uint newsCount; //total number of news created
    uint validatorCount; //total number of validator present
    uint VratingCount; //total number of rating given
    address owner; //address of contact owner
    struct news
    {
       uint id;
       string title;
       string message;
       string area;
       uint rating; //summation of rating given to this news
       uint finalRating; //mean rating of this news 
       bool isRated; 
       uint ratingCount; //number of validators that rated this news
    }
    mapping(uint=>news)public newses; //news array
    struct vRatingTrack //track the validator aticivity towqrds a specific news
    {
        uint newsId;
        uint[] vRatingTrack;
    }
    mapping(uint=>vRatingTrack)public vRatingTracker;
    struct validator
    {
        uint id;
        uint pWeight; //validator weight
        string area; //validator area
    }
    mapping(uint=>validator)public validators;
    mapping(address=>bool) checkUser; //to check if validator has already rated a particular news
    struct vRating
    {
        uint id;
        uint newsId; //news id
        uint vId; // validator id
        uint areaWeight; //calculated area weight for rating
        uint pRating; // validator given rating
        uint finalRating; //final rating generated 
        address vAddress; //validator address
    }
    mapping(uint=>vRating)public validatorRating;
    function stringToUint(string memory s)internal returns (uint result) 
    {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) 
        {
            uint c = uint(uint8(b[i]));
            if (c >= 48 && c <= 57) 
            {
                result = result * 10 + (c - 48);
            }
        }
    }
    constructor()public
    {
        owner=msg.sender;
    }
    modifier avi 
    {
        require(msg.sender==owner);
        _;
    }
    function createValidor(string memory _area) public //function to create a validator
    {
        // require(!checkUser[msg.sender]);
        validatorCount++;
        validators[validatorCount]=validator(validatorCount, 10, _area);
        checkUser[msg.sender]=true;
    }
     function vRatingCalculation(uint _id, uint vId)private view returns(uint) //function to generate final validator rating
    {
        // uint areaRating=validatorRating[_id].areaWeight+validatorRating[_id].pRating;
        // areaRating/=2;
        uint finalR=validatorRating[_id].pRating*validators[vId].pWeight;
        finalR/=10;
        return finalR;
    }
    function validatorWeight()public avi //function to generate validator weight only called by contract owner
    {
        for(uint i=1; i<=newsCount; i++)
        {
            for(uint j=0; j<newses[i].ratingCount; j++)
            {
                uint rId=vRatingTracker[i].vRatingTrack[j]; //rating id
                //address vAd = validatorRating[rId].vAddress; //validator address
                uint vAd = validatorRating[rId].vId;
                uint pRating = validatorRating[rId].pRating; //validator personal rating
                uint fRating = validatorRating[rId].finalRating; //validator final rating
                uint nRating = newses[i].finalRating; //news rating
                if(pRating>=(nRating+2) || pRating<=(nRating-2))
                {
                    validators[vAd].pWeight-=1;
                }
                if(fRating>=(nRating+2) || fRating<=(nRating-2))
                {
                    validators[vAd].pWeight-=1;
                }
            }
        }
    }
    function getValidatorCount()public view returns(uint)
    {
        return validatorCount;
    }
   function getValidators(uint _id) public view returns(uint, string memory)

    {
        return (validators[_id].pWeight, validators[_id].area);
    }
