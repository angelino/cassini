

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
