//Using Throw Keyword
function divide_with_throw(num1, num2) {
    if (num2 == 0) {
        throw new Error('Division by zero error');
    }
    return num1 / num2;
}

export {divide_with_throw};

