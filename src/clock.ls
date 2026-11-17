# LiveScript Clock — Canvas implementation matching Coffee/Rust/Nim.
TAU = Math.PI * 2
HALF = Math.PI / 2
BG = '#0b0f18'
COUNT = 60

timeParts = (d) ->
  hours = d.getHours!
  minutes = d.getMinutes!
  seconds = d.getSeconds!
  smoothSeconds = seconds + d.getMilliseconds! / 1000
  smoothMinutes = minutes + smoothSeconds / 60
  smoothHours = hours % 12 + smoothMinutes / 60
  {hours, minutes, seconds, smoothSeconds, smoothMinutes, smoothHours, minuteKey: Math.floor(d.getTime! / 60000)}

formatTime = (d) ->
  pad = (n) -> String(n).padStart(2, '0')
  "#{pad d.getHours!}:#{pad d.getMinutes!}"

formatDate = (d) ->
  d.toLocaleDateString('ja-JP', {year: 'numeric', month: 'long', day: 'numeric', weekday: 'long'})

timeHue = (h, m) -> (h * 60 + m) / 1440 * 360
shouldExplode = (prev, current) -> prev? and prev isnt current

geometry = (w, h) ->
  x: w / 2
  y: h / 2
  r: Math.min(w * 0.42, h * 0.34, 214)

createParticles = (cx, cy, radius, hue, random = Math.random) ->
  for i in [0 til COUNT]
    angle = TAU * i / COUNT - HALF + (random! - 0.5) * 0.28
    speed = 55 + random! * 115
    {
      x: cx + Math.cos(angle) * radius
      y: cy + Math.sin(angle) * radius
      vx: Math.cos(angle) * speed
      vy: Math.sin(angle) * speed
      hue
      age: 0
      life: 650 + random! * 550
    }

moveParticle = (p, elapsed) ->
  {
    x: p.x + p.vx * elapsed / 1000
    y: p.y + p.vy * elapsed / 1000
    vx: p.vx
    vy: p.vy
    hue: p.hue
    age: p.age + elapsed
    life: p.life
  }

resizeCanvas = (canvas, ctx) ->
  w = window.innerWidth
  h = window.innerHeight
  dpr = Math.min(window.devicePixelRatio or 1, 2)
  canvas.style.width = "#{w}px"
  canvas.style.height = "#{h}px"
  canvas.width = Math.max(1, Math.round(w * dpr))
  canvas.height = Math.max(1, Math.round(h * dpr))
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
  ctx.fillStyle = BG
  ctx.fillRect(0, 0, w, h)
  {w, h}

ring = (ctx, x, y, radius, progress, color, weight) ->
  return unless progress > 0
  ctx.beginPath!
  ctx.arc(x, y, radius, -HALF, TAU * progress - HALF)
  ctx.strokeStyle = color
  ctx.lineWidth = weight
  ctx.lineCap = 'round'
  ctx.stroke!

drawFace = (ctx, viewport, geo, t, reduced) ->
  {w, h} = viewport
  {x, y, r} = geo
  ctx.fillStyle = if reduced then BG else 'rgba(11, 15, 24, 0.28)'
  ctx.fillRect(0, 0, w, h)
  for rr in [r * 0.65, r * 0.83, r]
    ring(ctx, x, y, rr, 1, 'rgba(235, 240, 255, 0.085)', Math.max(2, r * 0.016))
  ring(ctx, x, y, r * 0.65, t.smoothHours / 12, "hsl(#{timeHue t.hours, t.minutes}, 86%, 68%)", Math.max(5, r * 0.04))
  ring(ctx, x, y, r * 0.83, t.smoothMinutes / 60, 'rgba(229, 237, 250, 0.88)', Math.max(4, r * 0.027))
  progress = if reduced then t.seconds / 60 else t.smoothSeconds / 60
  ring(ctx, x, y, r, progress, 'rgba(158, 188, 220, 0.78)', Math.max(2, r * 0.014))
  ctx.fillStyle = 'rgba(219, 232, 250, 0.65)'
  for i in [0 til t.seconds]
    angle = TAU * i / 60 - HALF
    ctx.beginPath!
    ctx.arc(x + Math.cos(angle) * r * 1.11, y + Math.sin(angle) * r * 1.11, Math.max(1, r * 0.009), 0, TAU)
    ctx.fill!

drawParticle = (ctx, p, radius) ->
  alpha = Math.max(0, 1 - p.age / p.life)
  ctx.fillStyle = "hsla(#{p.hue}, 88%, 72%, #alpha)"
  ctx.beginPath!
  ctx.arc(p.x, p.y, Math.max(1.5, radius * 0.012), 0, TAU)
  ctx.fill!

renderFrame = (ctx, viewport, state, d, elapsed, reduced) ->
  t = timeParts d
  geo = geometry viewport.w, viewport.h
  hue = timeHue t.hours, t.minutes
  drawFace(ctx, viewport, geo, t, reduced)
  particles = if reduced then [] else state.particles
  if not reduced and shouldExplode(state.lastMinute, t.minuteKey)
    particles = particles.concat createParticles(geo.x, geo.y, geo.r * 1.11, hue)
  particles = [moveParticle(p, elapsed) for p in particles]
  particles = particles.filter (p) -> p.age < p.life
  for p in particles
    drawParticle(ctx, p, geo.r)
  {lastMinute: t.minuteKey, particles}

run = ->
  canvas = document.getElementById 'clock-canvas'
  return unless canvas?
  ctx = canvas.getContext '2d'
  return unless ctx?
  timeLabel = document.getElementById 'digital-time'
  dateLabel = document.getElementById 'date-text'
  reduced = false
  reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches if window.matchMedia?
  viewport = resizeCanvas canvas, ctx
  state = {lastMinute: null, particles: []}
  lastFrame = null
  frameId = null

  animate = (stamp) ->
    elapsed = if lastFrame? then Math.min(50, Math.max(0, stamp - lastFrame)) else 16
    lastFrame = stamp
    now = new Date!
    timeText = formatTime now
    dateText = formatDate now
    timeLabel.textContent = timeText if timeLabel? and timeLabel.textContent isnt timeText
    dateLabel.textContent = dateText if dateLabel? and dateLabel.textContent isnt dateText
    state := renderFrame(ctx, viewport, state, now, elapsed, reduced)
    frameId := window.requestAnimationFrame animate

  window.addEventListener 'resize', ->
    viewport := resizeCanvas canvas, ctx
    state.particles = []

  document.addEventListener 'visibilitychange', ->
    if document.hidden
      window.cancelAnimationFrame(frameId) if frameId?
      frameId := null
      lastFrame := null
    else unless frameId?
      frameId := window.requestAnimationFrame animate

  frameId = window.requestAnimationFrame animate

if typeof module isnt 'undefined' and module.exports?
  module.exports = {timeParts, formatTime, formatDate, timeHue, shouldExplode, geometry, createParticles, moveParticle}
else if typeof document isnt 'undefined'
  run!
