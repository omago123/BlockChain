const Lottery = artifacts.require("Lottery");


contract('Lottery', function([deployer, user1, user2]){
    let lottery;
    beforeEach(async () =>{
        console.log('Before each')
        lottery = await Lottery.new();
    })

    

    // mocha에서 테스트시 특정테스트만 하기위해서는 .only를 붙여준다.
    it.only('getPot should return current pot', async () => {
        let pot = await lottery.getPot();
        assert.equal(pot, 0)
    })

});