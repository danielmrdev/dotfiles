"""Turn Google Calendar event resources into contract rows.

Pure functions only. No I/O, no subprocess, no clock reads. Everything this
module needs is passed in, which is what makes the timezone behaviour
testable without freezing time.
"""

from datetime import date, datetime, time, timedelta

NO_TITLE = "(no title)"


def normalize_all(gevents, calendar, tz):
    """Normalize a list of Google events, flattening the per-day rows."""
    rows = []
    for gevent in gevents:
        rows.extend(normalize_event(gevent, calendar, tz))
    return rows


def normalize_event(gevent, calendar, tz):
    """Return one contract row per local day this event covers.

    Rows produced from a single Google event share its id, so consumers must
    key on id plus dateKey, never on id alone.
    """
    if gevent.get("status") == "cancelled":
        return []

    start_node = gevent.get("start") or {}
    if not start_node:
        return []

    end_node = gevent.get("end") or start_node

    try:
        start_dt, all_day = _parse_endpoint(start_node, tz)
        end_dt, _ = _parse_endpoint(end_node, tz)
    except (KeyError, ValueError, TypeError):
        return []

    if all_day:
        # Google's all-day end.date must be strictly after start.date.
        if end_dt.date() <= start_dt.date():
            return []
    elif end_dt < start_dt:
        # A zero-length timed event (end == start) is a legal marker.
        return []

    title = (gevent.get("summary") or "").strip() or NO_TITLE
    location = gevent.get("location") or ""
    start_iso = start_dt.isoformat()
    end_iso = end_dt.isoformat()

    return [
        {
            "id": gevent.get("id", ""),
            "calendarId": calendar["id"],
            "calendarName": calendar["name"],
            "color": calendar["color"],
            "dateKey": day.isoformat(),
            "start": start_iso,
            "end": end_iso,
            "allDay": all_day,
            "title": title,
            "location": location,
        }
        for day in _covered_days(start_dt, end_dt, all_day)
    ]


def _parse_endpoint(node, tz):
    """Return (aware datetime in tz, is_all_day) for a Google start/end node."""
    if "date" in node:
        parsed = date.fromisoformat(node["date"])
        return datetime(parsed.year, parsed.month, parsed.day, tzinfo=tz), True
    parsed_dt = datetime.fromisoformat(node["dateTime"])
    if parsed_dt.tzinfo is None:
        # A naive dateTime has no offset. Guessing the system timezone
        # would make output depend on the machine running this code, so
        # treat it as unusable instead.
        raise ValueError("dateTime has no timezone offset")
    return parsed_dt.astimezone(tz), False


def _covered_days(start_dt, end_dt, all_day):
    """Inclusive list of local dates the event occupies."""
    first = start_dt.date()

    if all_day:
        # Google's all-day end.date is exclusive.
        last = end_dt.date() - timedelta(days=1)
    else:
        last = end_dt.date()
        # Ending exactly at midnight means the event never occupied that day.
        if end_dt.timetz().replace(tzinfo=None) == time(0, 0) and last > first:
            last -= timedelta(days=1)

    if last < first:
        last = first

    days = []
    cursor = first
    while cursor <= last:
        days.append(cursor)
        cursor += timedelta(days=1)
    return days
