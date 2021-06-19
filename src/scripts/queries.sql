

select targets.description as target,
       event_types.description as event,
       time_stamp::date as date,
       title
  from events
         left join targets
             on targets.id = events.target_id
         left join event_types
             on event_types.id = events.event_type_id
  where title ilike '%flyby%' or title ilike '%fly by%';
  -- where title ~* '^T[A-Z0-9_].*? flyby';


select target, title, date
  from import.master_plan
 where start_time_utc::date = '2005-02-17'
       order by start_time_utc::date;

select
  targets.description as target,
  events.time_stamp,
  event_types.description as event
from events
  inner join targets
    on targets.id = events.target_id
  inner join event_types
    on event_types.id = events.event_type_id
where events.time_stamp::date = '2005-02-17'
and events.target_id = (select id from targets where description = 'Enceladus')
order by events.time_stamp;

select * from enceladus_events
where date='2005-02-17'::date;

select * from enceladus_events
where date='2005-03-09'::date;

-- find the thermal results
select id, date, title
from enceladus_events
where date between '2005-02-01'::date
  and '2005-02-28'::date
and search @@ to_tsquery('thermal');

select count(*) as activity, teams.description
from events
  inner join teams on teams.id = events.team_id
where events.time_stamp::date = '2005-03-09'
and events.target_id = (select id from targets where description = 'Enceladus')
group by teams.description
order by activity desc;

select id, title
from enceladus_events
where search @@ to_tsquery('closest');

-- see more about matchers: https://www.postgresql.org/docs/current/functions-textsearch.html

select
  (time_stamp at time zone 'UTC'),
  title
from events
where (time_stamp at time zone 'UTC')::date='2009-11-02'
order by time_stamp;