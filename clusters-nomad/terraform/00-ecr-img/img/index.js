
function printLn() {
    console.log(`${new Date()} Hello from Nomad !`);
    setTimeout(() => { printLn(); }, 1000);
}

printLn();
