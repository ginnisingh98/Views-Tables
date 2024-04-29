--------------------------------------------------------
--  DDL for Package Body FND_PERFMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PERFMON" as
/* $Header: AFPMMONB.pls 115.8 2003/08/22 20:49:29 fskinner ship $ */




--
-- SET_WAIT_SAMPLE_EXPIRATION
-- Set the number of days that wait_samples will be stored in the db.
-- Then delete expired samples.
--
procedure SET_WAIT_SAMPLE_EXPIRATION(new_expire float) is
begin
  update fnd_perf_variables set value = to_char(new_expire)
    where variable = 'wait_sample_expiration';

  /* Delete expired samples. */
  delete from fnd_wait_samples
    where snapdate < sysdate - new_expire;
  commit;
end;



--
-- GET_WAIT_SAMPLE_EXPIRATION
-- Return the current expiration limit (ie: the number of days that
-- wait_samples will be stored in the db).
--
function GET_WAIT_SAMPLE_EXPIRATION return float is
wait_sample_expiration	float;
begin
  select to_number(value) into wait_sample_expiration
    from fnd_perf_variables
    where variable = 'wait_sample_expiration';
  return(wait_sample_expiration);
end;



--
-- TAKE_WAIT_SAMPLE
-- Sample v$session_wait to capture:
-- encoded event, background or foreground, batch or real-time, snapdate,
-- and group similar events so it records a count for the group.
--
procedure TAKE_WAIT_SAMPLE is
wait_sample_expiration 	float;
begin

  /* Delete expired samples. */
  wait_sample_expiration := get_wait_sample_expiration;
  delete from fnd_wait_samples
    where snapdate < sysdate - wait_sample_expiration;

  /* Take sample. */
  insert into fnd_wait_samples( ct, event, detail, fgbg, rtbt, snapdate )
    -- Identify the DB Message wait sessions
    select count (*),
       'DBW',
       decode( w.wait_time, 0, decode( w.event, 'latch free', w.p2, w.p1 ), NULL ),
       decode( s.type, 'BACKGROUND', 'B', 'F' ),
       decode( substr( s.program, 1, 7 ),
              '   ?  @',  /* real-time programs have this funny name */
	      decode( s.terminal, NULL, 'B', 'R' ),
              'B' ),
       sysdate
    from v$session_wait w, v$session s
    where s.sid = w.sid
    and s.sid not in
      (select s2.sid from v$session s2
       where s2.audsid = userenv( 'SESSIONID' ))
    and w.wait_time <> 0
    and exists  ( select 1
	from v$session s3
	where
	s.paddr = s3.paddr
	and s.sid <> s3.sid  )
    group by 2,
       decode( w.wait_time, 0, decode( w.event, 'latch free', w.p2, w.p1 ), NULL ),
       decode( s.type, 'BACKGROUND', 'B', 'F' ),
       decode( substr( program, 1, 7 ),
              '   ?  @', decode( s.terminal, NULL, 'B', 'R' ),
              'B' ),
       sysdate
    UNION ALL
    -- All other cases
    select count (*),
       decode( w.wait_time,
              0, decode( w.event,
                        'client message', 'CM',
                        'Null event', 'N',
                        'db file scattered read', 'DSR',
                        'db file sequential read', 'DRR',
                        'latch free', 'LF',
                        'enqueue', 'NQ',
                        'rdbms ipc message', 'RM',
                        'rdbms ipc reply', 'RR',
                        'control file sequential read', 'CSR',
                        'control file parallel write', 'CPW',
                        'db file parallel write', 'DPW',
                        'db file single write', 'DSW',
                        'log file parallel write', 'LPW',
                        'log file space/switch', 'LSS',
                        'log file sync', 'LS',
                        'library cache pin', 'LCP',
                        'library cache load lock', 'LCL',
                        'row cache lock', 'RCL',
                        'PL/SQL lock timer', 'LT',
                        'pmon timer', 'PT',
                        'smon timer', 'ST',
                        'free buffer available', 'FBA',
                        'free buffer waits', 'FBW',
			'SQL*Net message from client', 'NMC',
                        w.event ),
              'C' ),    /* If not waiting, then likely doing CPU */
       decode( w.wait_time, 0, decode( w.event, 'latch free', w.p2, w.p1 ), NULL ),
       decode( s.type, 'BACKGROUND', 'B', 'F' ),
       decode( substr( s.program, 1, 7 ),
              '   ?  @',  /* real-time programs have this funny name */
	      decode( s.terminal, NULL, 'B', 'R' ),
              'B' ),
       sysdate
    from v$session_wait w, v$session s
    where s.sid = w.sid
    and s.sid not in
      (select s2.sid from v$session s2
       where s2.audsid = userenv( 'SESSIONID' ))
    and (w.wait_time = 0
       or not exists  ( select 1
	    from v$session s3
	    where
	    s.paddr = s3.paddr
	    and s.sid <> s3.sid ) )
    group by decode( w.wait_time,
                    0, decode( w.event,
                              'client message', 'CM',
                              'Null event', 'N',
                              'db file scattered read', 'DSR',
                              'db file sequential read', 'DRR',
                              'latch free', 'LF',
                              'enqueue', 'NQ',
                              'rdbms ipc message', 'RM',
                              'rdbms ipc reply', 'RR',
                              'control file sequential read', 'CSR',
                              'control file parallel write', 'CPW',
                              'db file parallel write', 'DPW',
                              'db file single write', 'DSW',
                              'log file parallel write', 'LPW',
                              'log file space/switch', 'LSS',
                              'log file sync', 'LS',
                              'library cache pin', 'LCP',
                              'library cache load lock', 'LCL',
                              'row cache lock', 'RCL',
                              'PL/SQL lock timer', 'LT',
                              'pmon timer', 'PT',
                              'smon timer', 'ST',
                              'free buffer available', 'FBA',
                              'free buffer waits', 'FBW',
			      'SQL*Net message from client', 'NMC',
                              w.event ),
                    'C' ),
       decode( w.wait_time, 0, decode( w.event, 'latch free', w.p2, w.p1 ), NULL ),
       decode( s.type, 'BACKGROUND', 'B', 'F' ),
       decode( substr( s.program, 1, 7 ),
              '   ?  @', decode( s.terminal, NULL, 'B', 'R' ),
              'B' ),
       sysdate;
  commit;
end TAKE_WAIT_SAMPLE;





--
-- SET_SQL_SAMPLE_EXPIRATION
-- Set the number of days that sql_samples will be stored in the db.
-- Then delete expired samples.
--
procedure SET_SQL_SAMPLE_EXPIRATION(new_expire float) is
begin
  update fnd_perf_variables set value = to_char(new_expire)
    where variable = 'sql_sample_expiration';

  /* Delete expired samples. */
  delete from fnd_sql_samples
    where snapdate < sysdate - new_expire;
  commit;
end;



--
-- GET_SQL_SAMPLE_EXPIRATION
-- Return the current expiration limit (ie: the number of days that
-- sql_samples will be stored in the db).
--
function GET_SQL_SAMPLE_EXPIRATION return float is
sql_sample_expiration	float;
begin
  select to_number(value) into sql_sample_expiration
    from fnd_perf_variables
    where variable = 'sql_sample_expiration';
  return(sql_sample_expiration);
end;



--
-- TAKE_SQL_SAMPLE
-- Sample v$session to capture
-- the sql currently being executed by every session.
--
procedure TAKE_SQL_SAMPLE is
sql_sample_expiration 	float;
begin

  /* Delete expired samples. */
  sql_sample_expiration := get_sql_sample_expiration;
  delete from fnd_sql_samples
    where snapdate < sysdate - sql_sample_expiration;

  /* Take sample. */
  insert into fnd_sql_samples(sql_hash_value, type, program, snapdate)
    select s.sql_hash_value,
      decode(w.WAIT_TIME,
	0, decode(w.event, 'db file sequential read', 'R', 'S'),
	'C'),
      substr(s.program,1,8),
      sysdate
    from v$session s, v$session_wait w
    where
    w.sid = s.sid
    and ((w.WAIT_TIME <> 0   -- CPU case
	  and not exists
	  (select 1 from v$session s3 where s.paddr = s3.paddr and s.sid <> s3.sid))
	 or
	 (w.WAIT_TIME = 0    -- I/O case
	  and w.event in ('db file scattered read', 'db file sequential read')
	  ));
  commit;
end TAKE_SQL_SAMPLE;



/*
begin  -- package init

     we should init wait_sample_expiration here,
     but a bug in dbms_job (Rel 7.1.6) re-initilizes package
     each time the job is called.
     So, init wait_sample_expiration when fnd_perf_variables
     table is created.
  set_wait_sample_expiration(7 * 6);
  */

end FND_PERFMON;

/
