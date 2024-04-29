--------------------------------------------------------
--  DDL for Package Body FND_CONC_STAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_STAT" AS
/* $Header: AFAMRSCB.pls 115.8 2003/11/21 22:19:47 pferguso ship $ */


   -- Overview of statistic collection:

   -- A concurrent request may be comprised of one or two
   -- resource-consuming processes: a sql*net shadow process which consumes
   -- database server resources, and a front-end process (such as a C
   -- executable).  We collect data for both types of processes.  For the
   -- front-end process, we currently collect only the CPU time used.  For a
   -- complete list of the statistics available for the shadow process,
   -- select * from the V$STATNAME view.

   -- There are four levels of collection, set at the program level in
   -- the STAT_COLLECT column of FND_CONCURRENT_PROGRAMS:
   --
   --          O = Off
   --          S = Standard
   --          E = Extra which includes S
   --          A = All
   --
   -- The statistics corresponding to these levels are set in the table
   -- FND_CONC_STAT_LIST. The STATISTIC# is from V$STATNAME and the
   -- COLLECT_LEVEL is  'S' or 'E'. The level 'E' is made up of all
   -- those in S plus any in E. So S is included in E.  If the system
   -- profile CONC_REQUEST_STAT <> 'Y', or if  STAT_COLLECT is NULL or 'O'
   -- no statistics will be collected for that program. The front-end CPU
   -- statistics do not correspond to any entries in V$STATNAME.
   -- These correspond to the statistics: -1 "system seconds",
   -- -2 "system microseconds", -3 "user seconds",
   -- -4 "user microseconds", and -5 "real-world seconds".

   --   stat_collect_level:
   --      Called by 'collect()', 'put_frontend_cpu()' ,'store_initial()',
   --      and  'store_final()'
   --   Do we collect statistics ? If so, at what level.
   --      IS the 'CONC_REQUEST_STAT' profile SET to 'Y' AND
   --      IS STAT_COLLECT not set to NULL ?
   --      IF SO, return STAT_COLLECT, otherwise return 'O' for off
   --
   --      NOTE: STAT_COLLECT values are :
   --          NULL  ( unchanged )
   --          O = off
   --          S = Standard
   --          E = Extra which includes S
   --          A = All

   --
   -- PRIVATE VARIABLES
   --
   P_CPU_REQ_ID	       integer         := null;
   P_SHADOW_REQ_ID     integer         := null;


   FUNCTION stat_collect_level RETURN VARCHAR2 IS
	crs      VARCHAR2(80);
        f_stat_collect VARCHAR2(1);
   BEGIN
      fnd_profile.get('CONC_REQUEST_STAT', crs);
      IF crs = 'Y' THEN
          SELECT stat_collect
           INTO f_stat_collect
           FROM fnd_concurrent_programs
           WHERE concurrent_program_id = fnd_global.conc_program_id
           AND  application_id = fnd_global.prog_appl_id;
         IF f_stat_collect IS NULL THEN
          RETURN 'O';
         ELSE
          RETURN f_stat_collect;
         END IF;
      ELSE
	 RETURN 'O';
      END IF;
   END stat_collect_level;


   FUNCTION rt_perf_stat_enabled RETURN BOOLEAN IS
       rt_perf   BOOLEAN := FALSE;
       rt_perf_val VARCHAR2(1);
   BEGIN
      if( fnd_profile.defined('RT_PERF_STAT') ) then
        fnd_profile.get('RT_PERF_STAT', rt_perf_val );
        if ( rt_perf_val = 'Y' ) then
          rt_perf := TRUE;
        end if;
      end if;
	  return rt_perf;
   END;


   -- put_frontend_cpu:
   --   Called by the frontend process to insert CPU time
   --   and real seconds into the stats tables.
   --   Frontend process computes CPU time on its
   --   own; this is just an insert statement we do here.

   PROCEDURE put_frontend_cpu(sys_sec IN NUMBER,
			      sys_mic IN NUMBER,
			      usr_sec IN NUMBER,
			      usr_mic IN NUMBER)
     IS
	p_req_id NUMBER;
        p_actual_start_date DATE;
   BEGIN
      p_req_id := fnd_global.conc_request_id;
      if P_CPU_REQ_ID = p_req_id then
	return;
      else
        P_CPU_REQ_ID := p_req_id;
      end if;

      IF stat_collect_level <> 'O' THEN

      SELECT actual_start_date
        INTO p_actual_start_date
        FROM fnd_concurrent_requests fcr
        WHERE fcr.request_id = p_req_id;

      INSERT INTO fnd_conc_req_stat (req_id, process_type, statistic#, value)
	VALUES (p_req_id, 'F', SYS_SEC_ID, sys_sec);

      INSERT INTO fnd_conc_req_stat (req_id, process_type, statistic#, value)
	VALUES (p_req_id, 'F', SYS_MIC_ID, sys_mic);

      INSERT INTO fnd_conc_req_stat (req_id, process_type, statistic#, value)
	VALUES (p_req_id, 'F', USR_SEC_ID, usr_sec);

      INSERT INTO fnd_conc_req_stat (req_id, process_type, statistic#, value)
	VALUES (p_req_id, 'F', USR_MIC_ID, usr_mic);

      INSERT INTO fnd_conc_req_stat (req_id, process_type, statistic#, value)
	VALUES (p_req_id, 'F', REAL_SEC_ID, (SYSDATE - p_actual_start_date ) * DAYSECS );
      END IF;

   END put_frontend_cpu;


   --  collect:
   --    collect stats for a shadow process
   --    "Collect" is run after request completion, if a
   --    request runs in its own database session.
   --    see also store_initial and store_final
   --    NOTE: collection levels decode to
   --          S = Standard
   --          E = Extra which includes S
   --          A = All

   PROCEDURE collect IS
      p_req_id NUMBER;
      p_stat_collect VARCHAR2(1);
      session  NUMBER;
   BEGIN

      p_req_id := fnd_global.conc_request_id;

      if P_SHADOW_REQ_ID = p_req_id then
	return;
      else
        P_SHADOW_REQ_ID := p_req_id;
      end if;
      p_stat_collect := stat_collect_level;

      IF p_stat_collect <> 'O'  THEN

      SELECT sid
	INTO session
	FROM v$session
	WHERE audsid = userenv('SESSIONID');

      IF p_stat_collect = 'S' THEN
        INSERT INTO fnd_conc_req_stat(req_id, process_type, statistic#, value)
          SELECT p_req_id, 'S', slist.statistic#, vstat.value
          FROM v$sesstat vstat, fnd_conc_stat_list slist
          WHERE vstat.sid = session
          AND slist.statistic# = vstat.statistic#
          AND slist.collect_level = 'S';
      ELSIF p_stat_collect = 'E' THEN
        INSERT INTO fnd_conc_req_stat(req_id, process_type, statistic#, value)
          SELECT p_req_id, 'S', slist.statistic#, vstat.value
          FROM v$sesstat vstat, fnd_conc_stat_list slist
          WHERE vstat.sid = session
          AND slist.statistic# = vstat.statistic#;
      ELSIF p_stat_collect = 'A' THEN
        INSERT INTO fnd_conc_req_stat(req_id, process_type, statistic#, value)
          SELECT p_req_id, 'S', vstat.statistic#, vstat.value
          FROM v$sesstat vstat
          WHERE vstat.sid = session;
      END IF;

      END IF;

      -- Call performace package.
      if ( rt_perf_stat_enabled ) then
         fnd_apd.collect;
      end if;

   END collect;

   -- store_initial:
   --    store_initial and store_final are used if a request uses
   --    the manager's existing session.
   --    store_initial is called prior to request execution and store_final
   --    is used immediately after the request completes.
   --    Store_initial stores the initial values, store_final stores the
   --    difference between the initial values and the values at the
   --    time the request completes

   PROCEDURE store_initial IS
      p_req_id NUMBER;
      p_stat_collect VARCHAR2(1);
      session  NUMBER;
   BEGIN

      p_stat_collect := stat_collect_level;

      IF p_stat_collect <> 'O'  THEN

      p_req_id := fnd_global.conc_request_id;

      SELECT sid
	INTO session
	FROM v$session
	WHERE audsid = userenv('SESSIONID');

      IF p_stat_collect = 'S' THEN
        INSERT INTO fnd_conc_req_stat(req_id, process_type, statistic#, value)
          SELECT - p_req_id, 'S', slist.statistic#, vstat.value
          FROM v$sesstat vstat, fnd_conc_stat_list slist
          WHERE vstat.sid = session
          AND slist.statistic# = vstat.statistic#
          AND slist.collect_level = 'S';
      ELSIF p_stat_collect = 'E' THEN
        INSERT INTO fnd_conc_req_stat(req_id, process_type, statistic#, value)
          SELECT - p_req_id, 'S', slist.statistic#, vstat.value
          FROM v$sesstat vstat, fnd_conc_stat_list slist
          WHERE vstat.sid = session
          AND slist.statistic# = vstat.statistic#;
      ELSIF p_stat_collect = 'A' THEN
        INSERT INTO fnd_conc_req_stat(req_id, process_type, statistic#, value)
          SELECT - p_req_id, 'S', vstat.statistic#, vstat.value
          FROM v$sesstat vstat
          WHERE vstat.sid = session;
      END IF;

      END IF; -- end of if p_stat_collect.

      -- Call performace package.
      if ( rt_perf_stat_enabled ) then
         fnd_apd.store_initial;
      end if;

   END store_initial;

   -- store_final:
   --    store_initial and store_final are used if a request uses
   --    the manager's existing session.
   --    store_initial is called prior to request execution and store_final
   --    is used immediately after the request completes.
   --    Store_initial stores the initial values, store_final stores the
   --    difference between the initial values and the values at the
   --    time the request completes

   PROCEDURE store_final IS

      CURSOR initial_values IS
	 SELECT statistic#, value
	   FROM fnd_conc_req_stat
	   WHERE req_id = - fnd_global.conc_request_id;

      curr_val NUMBER;
      p_req_id NUMBER;
      session  NUMBER;
   BEGIN

      IF stat_collect_level <> 'O' THEN

      p_req_id := fnd_global.conc_request_id;

      SELECT sid
	INTO session
	FROM v$session
	WHERE audsid = userenv('SESSIONID');

      FOR oldstat IN initial_values LOOP

	 SELECT value
           INTO curr_val
           FROM v$sesstat vstat
           WHERE vstat.sid = session
           AND statistic# = oldstat.statistic#;

	 UPDATE fnd_conc_req_stat
	   SET value = curr_val - oldstat.value, req_id = p_req_id
	   WHERE req_id = - p_req_id
	   AND statistic# = oldstat.statistic#;

      END LOOP;

      END IF; -- end of if p_stat_collect.

      -- Call performace package.
      if ( rt_perf_stat_enabled ) then
         fnd_apd.store_final;
      end if;

   END store_final;

END fnd_conc_stat;

/
