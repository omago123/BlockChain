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

    enum BlockStatus {
        Checkable,
        NotRevealed,
        BlockLimitPassed
    }
    enum BettingResult {
        Fail,
        Win,
        Draw
    }
    event BET(
        uint256 index,
        address bettor,
        uint256 amount,
        bytes1 cahllenges,
        uint256 answerBlockNumber
    );

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

    // save bet bet to the queue
    function bet(bytes1 challenges) public payable returns (bool result) {
        // Check the proper ether is sent
        require(msg.value == BET_AMOUNT, "Not enough ETH");

        // Push bet to the queue
        require(pushBet(challenges), "Fail to add a new Bet Info");

        // emit event
        emit BET(
            _tail - 1,
            msg.sender,
            msg.value,
            challenges,
            block.number + BET_BLOCK_INTERVAL
        );

        return true;
    }

    /**
     * @dev 베팅글자와 정답을 확인한다.
     * @param challenges 베팅 글자
     * @param answer 블락 해시
     * @return 정답결과
     */

    function isMatch(bytes1 challenges, bytes32 answer)
        public
        pure
        returns (BettingResult)
    {
        // challenges 0xab
        // answer 0xab...... ff 3 bytes

        bytes1 c1 = challenges;
        bytes1 c2 = challenges;

        bytes1 a1 = answer[0];
        bytes1 a2 = answer[0];

        // Get first number
        c1 = c1 >> 4; // 0xab -> 0x0a
        c1 = c1 << 4; // 0x0a -> 0xa0

        a1 = a1 >> 4;
        a1 = a1 << 4;

        // Get Second number
        c2 = c2 << 4; // 0xab -> 0xb0
        c2 = c2 >> 4; // 0xb0 -> 0x0b

        a2 = a2 << 4;
        a2 = a2 >> 4;

        if (a1 == c1 && a2 == c2) {
            return BettingResult.Win;
        }

        if (a1 == c1 || a2 == c2) {
            return BettingResult.Draw;
        }

        return BettingResult.Fail;
    }

    // Distribute
    function distribute() public {
        // head 3 4 5 6 7 8 9 10 11 12 tail
        uint256 cur;
        BetInfo memory b;
        BlockStatus currentBlockStatus;
        for (cur = _head; cur < _tail; cur++) {
            b = _bets[cur];
            currentBlockStatus = getBlockStatus(b.answerBlockNumber);

            // Checkable : block.number >  AnswerBlockNumber && BLOCK_LIMIT + AnswerBlockNumber
            if (currentBlockStatus == BlockStatus.Checkable) {
                // if win, bettor gets pot
                // if fail, bettor`s money goes pot
                // if draw, refund bettor`s money
            }

            // Not Revealed : block.number <= answerblocknumber
            if (currentBlockStatus == BlockStatus.NotRevealed) {
                break;
            }

            // Block Limit Passed : block.number >= answerblocknumber + block_limit
            if (currentBlockStatus == BlockStatus.BlockLimitPassed) {
                // refund
                // emit refund
            }
            popBet(cur);
        }
    }

    function getBlockStatus(uint256 answerBlockNumber)
        internal
        view
        returns (BlockStatus)
    {
        if (
            block.number > answerBlockNumber &&
            block.number < BLOCK_LIMIT + answerBlockNumber
        ) {
            return BlockStatus.Checkable;
        }

        if (block.number <= answerBlockNumber) {
            return BlockStatus.NotRevealed;
        }

        if (block.number >= answerBlockNumber + BLOCK_LIMIT) {
            return BlockStatus.BlockLimitPassed;
        }
        return BlockStatus.BlockLimitPassed;
    }

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

    function pushBet(bytes1 challenges) internal returns (bool) {
        BetInfo memory b;
        b.bettor = msg.sender;
        //block.number(uint) : current block number
        b.answerBlockNumber = block.number + BET_BLOCK_INTERVAL;
        b.challenges = challenges;

        _bets[_tail] = b;
        _tail++;

        return true;
    }

    function popBet(uint256 index) internal returns (bool) {
        delete _bets[index];
        return true;
    }
}
