pragma solidity >=0.4.21 <0.6.0;

contract Lottery {
    struct BetInfo {
        uint256 answerBlockNumber;
        // 정답을 맞추면 이 주소로 이더를 보내줘야 함 특정주소에 트랜스퍼를 하려면 payable 필요
        address payable bettor;
        bytes1 challenges;
    }

    uint256 private _tail;
    uint256 private _head;
    mapping(uint256 => BetInfo) private _bets;

    address public owner;

    uint256 internal constant BLOCK_LIMIT = 256;
    // 배팅한 블록은 3번째 건너의 블록
    uint256 internal constant BET_BLOCK_INTERVAL = 3;
    // 배팅금액을 0.005ETH로 고정
    // ※ ** 거듭제곱;
    uint256 internal constant BET_AMOUNT = 5 * 10**15;

    uint256 private _pot;

    constructor() public {
        // msg.sender (address): sender of the message (current call)
        owner = msg.sender;
    }

    //smart contract 변수를 참조하기 위해서는 view가 들어가야함 변경은 불가
    function getPot() public view returns (uint256 pot) {
        return _pot;
    }

    // Bet
    /**
     * @dev 베팅을 한다. 유저는 0.005 ETH를 보내야 하고, 배팅을 1 byte 글자를 보낸다.
     * 큐에 저장된 베팅 정보는 이후 distrubute 함수에서 해결된다.
     * @param challenges 유저가 베팅하는 글자
     * @return 함수가 잘 수행되었는지 확인하는 bool 값
     */

    function bet(bytes1 challenges) public payable returns (bool result) {
        // check the proper ether is sent
        require(msg.value == BET_AMOUNT

        // push bet to the queue

        // emit event

        return true;
    }

    // save bet bet to the queue
    // Distribute
    // check the answer

    function getBetInfo(uint256 index)
        public
        view
        returns (
            uint256 answerBlockNumber,
            address bettor,
            bytes1 challenges
        )
    {
        BetInfo memory b = _bets[index];
        answerBlockNumber = b.answerBlockNumber;
        bettor = b.bettor;
        challenges = b.challenges;
    }

    function pushBet(bytes1 challenges) public returns (bool) {
        BetInfo memory b;
        b.bettor = msg.sender;
        //block.number(uint) : current block number
        b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL;
        b.challenges = challenges;

        _bets[_tail] = b;
        _tail++;

        return true;
    }

    function popBet(uint256 index) public returns (bool) {
        delete _bets[index];
        return true;
    }
}
