Powerball = artifacts.require("Powerball");

contract('Powerball', (accounts) => {
    let lottery = Powerball.at(Powerball.address);

    it('treba da kupi 100 karti', function () {
        var buys = [];
        for (var i = 0; i < 100; i++) {
            var numbers = [];
            numbers.push(generateRandomNumbers());
        }
        let tx = lottery.buy(numbers, { from: accounts[0], value: 2e16 });
        buys.push();
        return Promise.all(tx);
    })
})

function generateRandomNumbers() {
    var numbers = []
    var i = 0;
    while (i < 5) {
        var num = Math.ceil(Math.random() * 69);
        if (numbers.includes(num))
            continue;
        numbers.push(num);
        i++;
    }
    numbers.push(Math.ceil(Math.random() * 26));
    return numbers;
}