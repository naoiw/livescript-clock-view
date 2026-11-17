// Run the generated LiveScript against mocked browser APIs, not just the compiler.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const elements = {};
const draws = [];
const ctx = {
  setTransform: (...args) => draws.push(['transform', ...args]),
  fillRect: (...args) => draws.push(['fillRect', ...args]),
  beginPath: () => draws.push(['beginPath']),
  arc: (...args) => draws.push(['arc', ...args]),
  stroke: () => draws.push(['stroke']),
  fill: () => draws.push(['fill']),
};
const canvas = { style: {}, width: 0, height: 0, getContext: () => ctx };
elements['clock-canvas'] = canvas;
elements['digital-time'] = { textContent: '--:--' };
elements['date-text'] = { textContent: '' };
const listeners = {};
const queue = [];
const document = {
  hidden: false,
  getElementById: key => elements[key],
  addEventListener: (name, fn) => { listeners[name] = fn; },
};
const window = {
  innerWidth: 800,
  innerHeight: 600,
  devicePixelRatio: 2,
  matchMedia: () => ({ matches: false }),
  requestAnimationFrame: fn => (queue.push(fn), queue.length),
  cancelAnimationFrame: () => {},
  addEventListener: (name, fn) => { listeners[name] = fn; },
};
vm.runInNewContext(fs.readFileSync('dist/clock.js', 'utf8'),
  { window, document, Math, Date, console }, { filename: 'clock.js', timeout: 5000 });

assert.equal(canvas.width, 1600);
assert.equal(canvas.height, 1200);
assert.equal(typeof queue[0], 'function');
queue.shift()(16);
assert.match(elements['digital-time'].textContent, /^\d{2}:\d{2}$/);
assert.match(elements['date-text'].textContent, /^\d{4}年\d{1,2}月\d{1,2}日[日月火水木金土]曜日$/);
assert.ok(draws.some(x => x[0] === 'arc'));
assert.ok(draws.some(x => x[0] === 'stroke'));
assert.equal(typeof listeners.resize, 'function');
assert.equal(typeof listeners.visibilitychange, 'function');
window.innerWidth = 450;
listeners.resize();
assert.equal(canvas.width, 900);
document.hidden = true;
listeners.visibilitychange();
document.hidden = false;
listeners.visibilitychange();
assert.ok(queue.length > 0);
console.log('LiveScript browser smoke passed');
