let x = (2 * 6) / 3;
let y = 3;
let result = 0;
function pow(base, exp) {
let power = 1;
for (let i = 0; i <= exp - 1; i++ ) {

power = power * base;
}
return power;
}
function avg(a, b) {
let average = (a + b) / 2;
return average;
}
result = avg(12, 2);
console.log(result);
result = pow(2, 3);
console.log(result);
if (!(x >= y)) {

console.log(`${x} < ${y}`);
} else {

console.log(`${x} >= ${y}`);
}
while (x <= 15) {

x = x + 1;
console.log(`x = ${x}`);
}
for (let i = 0; i <= 7; i++ ) {

console.log(`Loop numero ${i}`);
}
