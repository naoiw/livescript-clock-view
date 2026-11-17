const { test } = require('node:test');
const assert = require('node:assert/strict');
const { timeParts, formatTime, formatDate, timeHue, shouldExplode, geometry, createParticles, moveParticle } =
  require('../dist/clock.js');

test('fractional time and formatting', () => {
  const d = new Date(2026, 10, 17, 13, 30, 15, 500);
  const t = timeParts(d);
  assert.equal(t.smoothSeconds, 15.5);
  assert.ok(t.smoothMinutes > 30);
  assert.ok(t.smoothHours > 1);
  assert.equal(formatTime(d), '13:30');
  assert.equal(formatDate(d), '2026年11月17日火曜日');
});

test('minute boundary explodes only after initialization', () => {
  assert.equal(shouldExplode(null, 1), false);
  assert.equal(shouldExplode(1, 1), false);
  assert.equal(shouldExplode(1, 2), true);
});

test('time hue and geometry match other clocks', () => {
  assert.equal(timeHue(0, 0), 0);
  assert.equal(timeHue(12, 0), 180);
  assert.ok(timeHue(23, 59) < 360);
  const phone = geometry(320, 640);
  const desktop = geometry(1920, 1080);
  assert.ok(phone.r * 1.15 < 160);
  assert.ok(desktop.r <= 214);
  assert.equal(phone.x, 160);
  assert.equal(desktop.y, 540);
});

test('particles have stable count and elapsed-time physics', () => {
  const items = createParticles(50, 100, 20, 180, () => 0.5);
  assert.equal(items.length, 60);
  const p = items[0];
  const moved = moveParticle(p, 250);
  assert.equal(moved.x, p.x + p.vx * 0.25);
  assert.equal(moved.y, p.y + p.vy * 0.25);
  assert.equal(moved.age, 250);
  assert.equal(p.age, 0);
});
