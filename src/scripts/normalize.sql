--
--
--

drop table if exists events cascade;
drop table if exists event_types cascade;
drop table if exists targets cascade;
drop table if exists teams cascade;
drop table if exists requests cascade;
drop table if exists spass_types cascade;

-- event types

select distinct(library_definition) as description
  into event_types
  from import.master_plan;

alter table event_types add id serial primary key;

-- targets

select distinct(target) as description
  into targets
  from import.master_plan;

alter table targets add id serial primary key;

-- teams

select distinct(team) as description
  into teams
  from import.master_plan;

alter table teams add id serial primary key;

-- requests

select distinct(request_name) as description
  into requests
  from import.master_plan;

alter table requests add id serial primary key;

-- spass types

select distinct(spass_type) as description
  into spass_types
  from import.master_plan;

alter table spass_types add id serial primary key;

-- events

create table events(
  id serial primary key,
  time_stamp timestamptz not null,
  title varchar(500),
  description text,
  event_type_id int references event_types(id),
  spass_type_id int references spass_types(id),
  target_id int references targets(id),
  team_id int references teams(id),
  request_id int references requests(id)
);

insert into events(time_stamp, title, description, event_type_id, target_id, team_id, request_id, spass_type_id)
select import.master_plan.start_time_utc::timestamptz at time zone 'UTC',
       import.master_plan.title,
       import.master_plan.description,
       event_types.id as event_type_id,
       targets.id as target_id,
       teams.id as team_id,
       requests.id as request_id,
       spass_types.id as spass_type_id
  from import.master_plan
         left join event_types
             on event_types.description = import.master_plan.library_definition
         left join targets
             on targets.description = import.master_plan.target
         left join teams
             on teams.description = import.master_plan.team
         left join requests
             on requests.description = import.master_plan.request_name
         left join spass_types
             on spass_types.description = import.master_plan.spass_type;

drop view if exists enceladus_events;
create materialized view enceladus_events as
  select
    events.id,
    events.title,
    events.description,
    events.time_stamp,
    events.time_stamp::date as date,
    event_types.description as event,
    -- https://www.postgresql.org/docs/current/textsearch-controls.html
    to_tsvector(event_types.description) as search
  from events
    inner join event_types
      on event_types.id = events.event_type_id
  where events.target_id = (select id from targets where description = 'Enceladus')
  order by events.time_stamp;

create index idx_event_search on enceladus_events using GIN(search);

-- INMS
-- cleanup
delete from import.inms where sclk IS NULL or sclk = '';
delete from import.inms where sclk = 'sclk';

drop materialized view if exists flyby_altitudes;
create materialized view flyby_altitudes as
select
    (sclk::timestamp) as time_stamp,
    (alt_t::numeric(10,3)) as altitude
from import.inms
where target = 'ENCELADUS'
and alt_t IS NOT NULL;
