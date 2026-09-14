const test = require('node:test')
const assert = require('node:assert')
const Model = require('../Model.js')

const EVENTS = [
  { id: 'a', dateKey: '2026-08-10', title: 'Standup', color: '#f83a22', start: '2026-08-10T09:00:00-05:00' },
  { id: 'b', dateKey: '2026-08-10', title: 'Lunch', color: '#7bd148', start: '2026-08-10T12:00:00-05:00' },
  { id: 'c', dateKey: '2026-08-10', title: 'Retro', color: '#f83a22', start: '2026-08-10T16:00:00-05:00' },
  { id: 'd', dateKey: '2026-08-12', title: 'Dentist', color: '#ffad46', start: '2026-08-12T10:00:00-05:00' }
]

test('indexEventsByDate groups by dateKey', () => {
  const index = Model.indexEventsByDate(EVENTS)
  assert.equal(index['2026-08-10'].length, 3)
  assert.equal(index['2026-08-12'].length, 1)
  assert.equal(index['2026-08-11'], undefined)
})

test('indexEventsByDate tolerates an empty list', () => {
  assert.deepEqual(Model.indexEventsByDate([]), {})
})

test('indexEventsByDate tolerates null', () => {
  assert.deepEqual(Model.indexEventsByDate(null), {})
})

test('eventsForDateKey returns an empty array for an unknown day', () => {
  const index = Model.indexEventsByDate(EVENTS)
  assert.deepEqual(Model.eventsForDateKey(index, '2026-01-01'), [])
})

test('eventColors dedupes and preserves first-seen order', () => {
  const index = Model.indexEventsByDate(EVENTS)
  assert.deepEqual(Model.eventColors(index, '2026-08-10', 5), ['#f83a22', '#7bd148'])
})

test('eventColors respects the limit', () => {
  const index = Model.indexEventsByDate(EVENTS)
  assert.deepEqual(Model.eventColors(index, '2026-08-10', 1), ['#f83a22'])
})

// monthGrid returns an array of 6 week objects, each { week, days }.
// It is not wrapped in an outer object.
test('monthGrid without an index behaves as before', () => {
  const weeks = Model.monthGrid(2026, 7, 1, '2026-08-10')
  assert.equal(weeks.length, 6)
  const cells = weeks.flatMap(week => week.days)
  assert.equal(cells.length, 42)
  assert.ok(cells.every(cell => cell.hasEvent === false))
  assert.ok(cells.every(cell => Array.isArray(cell.dots) && cell.dots.length === 0))
})

test('monthGrid marks days that have events', () => {
  const index = Model.indexEventsByDate(EVENTS)
  const cells = Model.monthGrid(2026, 7, 1, '2026-08-10', index).flatMap(week => week.days)
  const tenth = cells.find(cell => cell.key === '2026-08-10')
  const eleventh = cells.find(cell => cell.key === '2026-08-11')
  assert.equal(tenth.hasEvent, true)
  assert.deepEqual(tenth.dots, ['#f83a22', '#7bd148'])
  assert.equal(eleventh.hasEvent, false)
})

test('monthGrid preserves the existing cell fields', () => {
  const cells = Model.monthGrid(2026, 7, 1, '2026-08-10').flatMap(week => week.days)
  const tenth = cells.find(cell => cell.key === '2026-08-10')
  assert.equal(tenth.day, 10)
  assert.equal(tenth.inMonth, true)
  assert.equal(tenth.today, true)
})

test('syncState reports missing when there is no document', () => {
  assert.equal(Model.syncState(null, Date.parse('2026-08-10T12:00:00Z'), 300), 'missing')
})

test('syncState reports missing when syncedAt is absent', () => {
  assert.equal(Model.syncState({}, Date.parse('2026-08-10T12:00:00Z'), 300), 'missing')
})

test('syncState reports ok for a recent sync', () => {
  const doc = { syncedAt: '2026-08-10T11:58:00Z' }
  assert.equal(Model.syncState(doc, Date.parse('2026-08-10T12:00:00Z'), 300), 'ok')
})

test('syncState tolerates one missed run', () => {
  // 300s interval, staleness threshold is 4x that, so 15 minutes is still ok.
  const doc = { syncedAt: '2026-08-10T11:48:00Z' }
  assert.equal(Model.syncState(doc, Date.parse('2026-08-10T12:00:00Z'), 300), 'ok')
})

test('syncState reports stale past the threshold', () => {
  const doc = { syncedAt: '2026-08-10T10:00:00Z' }
  assert.equal(Model.syncState(doc, Date.parse('2026-08-10T12:00:00Z'), 300), 'stale')
})

test('syncState reports missing for an unparseable syncedAt', () => {
  const doc = { syncedAt: 'not a date' }
  assert.equal(Model.syncState(doc, Date.parse('2026-08-10T12:00:00Z'), 300), 'missing')
})

test('dateFromKey builds a local date, not a UTC one', () => {
  const d = Model.dateFromKey('2026-08-10', null)
  assert.equal(d.getFullYear(), 2026)
  assert.equal(d.getMonth(), 7)
  assert.equal(d.getDate(), 10)
})

test('dateFromKey returns the fallback for a malformed key', () => {
  const fallback = new Date(2000, 0, 1)
  assert.equal(Model.dateFromKey('nope', fallback), fallback)
  assert.equal(Model.dateFromKey('', fallback), fallback)
  assert.equal(Model.dateFromKey(null, fallback), fallback)
  assert.equal(Model.dateFromKey('2026-08', fallback), fallback)
})

test('dateFromKey returns the fallback for non-numeric parts', () => {
  const fallback = new Date(2000, 0, 1)
  assert.equal(Model.dateFromKey('yyyy-mm-dd', fallback), fallback)
})

const DOC = {
  version: 1,
  events: [
    { id: 'a', calendarId: 'work@x', calendarName: 'Destify', color: '#ffad46', dateKey: '2026-08-10' },
    { id: 'b', calendarId: 'moon@x', calendarName: 'Phases of the Moon', color: '#fad165', dateKey: '2026-08-10' },
    { id: 'c', calendarId: 'work@x', calendarName: 'Destify', color: '#ffad46', dateKey: '2026-08-11' }
  ]
}

test('calendarsInDocument lists each calendar once, sorted by name', () => {
  assert.deepEqual(Model.calendarsInDocument(DOC), [
    { id: 'work@x', name: 'Destify', color: '#ffad46' },
    { id: 'moon@x', name: 'Phases of the Moon', color: '#fad165' }
  ])
})

test('calendarsInDocument tolerates a null document', () => {
  assert.deepEqual(Model.calendarsInDocument(null), [])
  assert.deepEqual(Model.calendarsInDocument({}), [])
})

test('toggleHiddenCalendar adds then removes', () => {
  const once = Model.toggleHiddenCalendar([], 'moon@x')
  assert.deepEqual(once, ['moon@x'])
  assert.deepEqual(Model.toggleHiddenCalendar(once, 'moon@x'), [])
})

test('toggleHiddenCalendar does not mutate its input', () => {
  const before = ['moon@x']
  Model.toggleHiddenCalendar(before, 'work@x')
  assert.deepEqual(before, ['moon@x'])
})

test('toggleHiddenCalendar tolerates a null list', () => {
  assert.deepEqual(Model.toggleHiddenCalendar(null, 'moon@x'), ['moon@x'])
})

test('visibleEvents drops hidden calendars only', () => {
  const visible = Model.visibleEvents(DOC.events, ['moon@x'])
  assert.equal(visible.length, 2)
  assert.ok(visible.every(e => e.calendarId === 'work@x'))
})

test('visibleEvents returns everything when nothing is hidden', () => {
  assert.equal(Model.visibleEvents(DOC.events, []).length, 3)
  assert.equal(Model.visibleEvents(DOC.events, null).length, 3)
})

test('isCalendarHidden matches by id', () => {
  assert.equal(Model.isCalendarHidden(['moon@x'], 'moon@x'), true)
  assert.equal(Model.isCalendarHidden(['moon@x'], 'work@x'), false)
  assert.equal(Model.isCalendarHidden([], 'work@x'), false)
})

const NOW = Date.parse('2026-08-10T09:00:00-05:00')
const at = (iso, extra = {}) => ({ id: iso, title: 'X', start: iso, allDay: false, ...extra })

test('nextEvent picks the soonest future event', () => {
  const events = [
    at('2026-08-10T18:00:00-05:00', { title: 'Later' }),
    at('2026-08-10T10:00:00-05:00', { title: 'Soon' }),
    at('2026-08-10T08:00:00-05:00', { title: 'Past' })
  ]
  assert.equal(Model.nextEvent(events, NOW).title, 'Soon')
})

test('nextEvent ignores events already started', () => {
  assert.equal(Model.nextEvent([at('2026-08-10T08:59:00-05:00')], NOW), null)
})

test('nextEvent ignores all-day events', () => {
  const events = [at('2026-08-10T00:00:00-05:00', { allDay: true }), at('2026-08-10T23:00:00-05:00', { title: 'Real' })]
  assert.equal(Model.nextEvent(events, NOW).title, 'Real')
})

test('nextEvent ignores unparseable starts', () => {
  assert.equal(Model.nextEvent([at('not a date')], NOW), null)
})

test('nextEvent returns null on an empty or null list', () => {
  assert.equal(Model.nextEvent([], NOW), null)
  assert.equal(Model.nextEvent(null, NOW), null)
})

test('formatCountdown renders minutes, hours and now', () => {
  assert.equal(Model.formatCountdown(30 * 1000), 'now')
  assert.equal(Model.formatCountdown(10 * 60 * 1000), 'in 10min')
  assert.equal(Model.formatCountdown(60 * 60 * 1000), 'in 1h')
  assert.equal(Model.formatCountdown(72 * 60 * 1000), 'in 1h 12min')
})

test('formatCountdown gives up past a day and on bad input', () => {
  assert.equal(Model.formatCountdown(25 * 60 * 60 * 1000), null)
  assert.equal(Model.formatCountdown(-1), null)
  assert.equal(Model.formatCountdown(null), null)
  assert.equal(Model.formatCountdown(NaN), null)
})

test('shouldAnnounce only fires inside the lead window', () => {
  const soon = at('2026-08-10T09:10:00-05:00')
  const far = at('2026-08-10T12:00:00-05:00')
  assert.equal(Model.shouldAnnounce(soon, NOW, 15), true)
  assert.equal(Model.shouldAnnounce(soon, NOW, 5), false)
  assert.equal(Model.shouldAnnounce(far, NOW, 15), false)
  assert.equal(Model.shouldAnnounce(null, NOW, 15), false)
})

test('millisUntil is null for an unreadable start', () => {
  assert.equal(Model.millisUntil(at('nope'), NOW), null)
  assert.equal(Model.millisUntil(null, NOW), null)
})

test('nextEventToday ignores events on other days', () => {
  const events = [
    at('2026-08-11T09:00:00-05:00', { title: 'Tomorrow' }),
    at('2026-08-10T18:00:00-05:00', { title: 'Tonight' })
  ]
  events[0].dateKey = '2026-08-11'
  events[1].dateKey = '2026-08-10'
  assert.equal(Model.nextEventToday(events, NOW, '2026-08-10').title, 'Tonight')
})

test('nextEventToday returns null once the day is done', () => {
  const tomorrow = at('2026-08-11T09:00:00-05:00')
  tomorrow.dateKey = '2026-08-11'
  assert.equal(Model.nextEventToday([tomorrow], NOW, '2026-08-10'), null)
})

test('announceLabel keeps the clock and appends the event', () => {
  assert.equal(
    Model.announceLabel('lundi 15:46', 'Standup', 'in 10min'),
    'lundi 15:46  ·  Standup in 10min'
  )
})

test('announceLabel returns the clock alone when nothing is announced', () => {
  assert.equal(Model.announceLabel('lundi 15:46', 'Standup', ''), 'lundi 15:46')
  assert.equal(Model.announceLabel('lundi 15:46', 'Standup', null), 'lundi 15:46')
})

test('announceLabel falls back to the clock when the title is empty', () => {
  assert.equal(Model.announceLabel('lundi 15:46', '', 'in 10min'), 'lundi 15:46')
})

test('truncateTitle only cuts what is too long', () => {
  assert.equal(Model.truncateTitle('Standup', 28), 'Standup')
  assert.equal(Model.truncateTitle('a'.repeat(40), 10), 'a'.repeat(9) + '…')
})

test('truncateTitle cuts mid-word rather than hunting for a boundary', () => {
  assert.equal(Model.truncateTitle('Design process solution here', 12), 'Design proc…')
})

test('truncateTitle does not leave a dangling space before the ellipsis', () => {
  // The cut lands exactly on the space after "Design".
  assert.equal(Model.truncateTitle('Design process', 8), 'Design…')
})

test('truncateTitle tolerates null', () => {
  assert.equal(Model.truncateTitle(null, 10), '')
})
