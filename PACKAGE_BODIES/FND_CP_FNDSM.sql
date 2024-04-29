--------------------------------------------------------
--  DDL for Package Body FND_CP_FNDSM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CP_FNDSM" as
/* $Header: AFCPFSMB.pls 120.7.12010000.10 2017/11/20 19:17:08 pferguso ship $ */

procedure mark_shutdown_fndsm( node IN varchar2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_CP_FNDSM.MARK_SHUTDOWN_FNDSM',
                  'mark_shutdown_fndsm called for node'||node);
        end if;

	update FND_CONCURRENT_PROCESSES
	   set PROCESS_STATUS_CODE = 'S',
	       LAST_UPDATE_DATE = sysdate
	 where CONCURRENT_QUEUE_ID =
		( select CONCURRENT_QUEUE_ID
		    from FND_CONCURRENT_QUEUES
		   where MANAGER_TYPE = '6'
		     and NODE_NAME = node)
	   and PROCESS_STATUS_CODE not in ('S', 'K');
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_CP_FNDSM.MARK_SHUTDOWN_FNDSM',
                  to_char(SQL%ROWCOUNT) ||' fnd_concurrent_processes rows updated');
        end if;

	update FND_CONCURRENT_QUEUES
	   set running_processes = 0,
	       max_processes = 0,
	       control_code = null
	 where MANAGER_TYPE = '6'
	   and NODE_NAME = node;
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_CP_FNDSM.MARK_SHUTDOWN_FNDSM',
                  to_char(SQL%ROWCOUNT) ||' fnd_concurrent_queues rows updated');
        end if;

    commit;

exception
        when others then
           rollback;
           raise;
end mark_shutdown_fndsm;

procedure mark_killed_fndsm( node IN varchar2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_CP_FNDSM.MARK_KILLED_FNDSM',
                  'mark_shutdown_fndsm called for node'||node);
        end if;
	update FND_CONCURRENT_PROCESSES
	   set PROCESS_STATUS_CODE = 'K',
	       LAST_UPDATE_DATE = sysdate
	 where CONCURRENT_QUEUE_ID =
		( select CONCURRENT_QUEUE_ID
		    from FND_CONCURRENT_QUEUES
		   where MANAGER_TYPE = '6'
		     and NODE_NAME = node)
	   and PROCESS_STATUS_CODE not in ('S', 'K');
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_CP_FNDSM.MARK_SHUTDOWN_FNDSM',
                  to_char(SQL%ROWCOUNT) ||' fnd_concurrent_processes rows updated');
        end if;

	update FND_CONCURRENT_QUEUES
	   set running_processes = 0,
	       max_processes = 0,
   	       control_code = null
	 where MANAGER_TYPE = 6
	   and NODE_NAME = node;
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
	    fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                  'fnd.plsql.FND_CP_FNDSM.MARK_SHUTDOWN_FNDSM',
                  to_char(SQL%ROWCOUNT) ||' fnd_concurrent_queues rows updated');
        end if;

    commit;

exception
        when others then
           rollback;
           raise;

end mark_killed_fndsm;

procedure shutdown_all_fndsm
is
begin
	update FND_CONCURRENT_PROCESSES
	   set PROCESS_STATUS_CODE = 'S',
	       LAST_UPDATE_DATE = sysdate
	 where MANAGER_TYPE = 6
	   and PROCESS_STATUS_CODE not in ('S', 'K');

	update FND_CONCURRENT_QUEUES
	   set running_processes = 0,
	       max_processes = 0,
	       control_code = null
	 where MANAGER_TYPE = '6';
end shutdown_all_fndsm;

/* 2849672- Add IN parameter twotask, so that the process row for each
   FNDSM will have db_instance populated.  */
/* 5867853- register_fndsm_fcp is used by ICM to insert FNDSM row, then FNDSM
   is spawned and uses register_fndsm_db to update the row. This procedure
   should be an autonomous transaction with a commit so that it is instantly
   available to FNDSM for update. */
procedure register_fndsm_fcp( cpid  IN number,
	                      node  IN varchar2,
			      ospid IN number,
			    logfile IN varchar2,
		           mgrusrid IN number,
                            twotask IN varchar2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
dummy               number;
begin

    -- Bugfix for 8724518
    -- 14364164- In case of ICM migration, old ICM may have a lock on this
    -- FND_CONCURRENT_QUEUES row from mark_shutdown_fndsm or mark_killed_fndsm.
    -- Wait 5 seconds for old ICM to commmit when selecting fnd_concurrent_queue
    -- row for update.
    select 1 into dummy from fnd_concurrent_queues
    where manager_type = 6 and node_name = node
    for update of running_processes ,max_processes , control_code
    wait 5;

    update FND_CONCURRENT_QUEUES
	set running_processes = 1,
	    max_processes = 1,
	    control_code = null
	where MANAGER_TYPE = 6 and NODE_NAME = node;

           INSERT INTO FND_CONCURRENT_PROCESSES
                    (CONCURRENT_PROCESS_ID, ORACLE_PROCESS_ID,
                     QUEUE_APPLICATION_ID,  CONCURRENT_QUEUE_ID,
                                            SESSION_ID,
                     Creation_Date,         Created_By,
                     LAST_UPDATE_DATE,      LAST_UPDATED_BY,
                     PROCESS_START_DATE,    PROCESS_STATUS_CODE,
                     MANAGER_TYPE,          OS_PROCESS_ID,
		     LOGFILE_NAME,
                     NODE_NAME,             SQLNET_STRING)

               (select
                             cpid, '999999',

			     Q.APPLICATION_ID, Q.CONCURRENT_QUEUE_ID,

                                        '999999',
                             sysdate,   mgrusrid,
                             SYSDATE,   mgrusrid,
                             SYSDATE,   'A',
                             6,         ospid,
			     logfile,
                             node,      twotask

			     from FND_CONCURRENT_QUEUES Q
			 where Q.MANAGER_TYPE = 6
		         and Q.NODE_NAME = node
              );
    commit;

     exception
        when others then
           rollback;
           raise;

end register_fndsm_fcp;

PROCEDURE register_fndsm_fcq(node varchar2)
is
	mgr_name varchar2(256);
	sm_name  varchar2(241);
	qcount	 number;
	ncount   number;
	dummy    number;
begin
	mgr_name := 'FNDSM_' || node;
	IF lengthb(mgr_name) > 256
	THEN
		mgr_name := substrb(mgr_name,1,256);
	END IF;

        select count(*)
	into qcount
	from fnd_concurrent_queues
	where node_name = node
	 and  manager_type = '6';



        if (qcount = 0) then
	        select count(*)
		into ncount
		from fnd_concurrent_queues
		where upper(CONCURRENT_QUEUE_NAME) = upper(mgr_name);

		if (ncount <> 0) then
			select fnd_concurrent_queues_s.nextval
			into dummy
			from dual;

			mgr_name := substrb('FNDSM_'||dummy||'_'||node,
						1, 256);
		end if;

	    sm_name := fnd_message.get_string('FND', 'CONC-FNDSM NAME');
		if(sm_name = 'CONC-FNDSM NAME') then
			sm_name := 'Service Manager';
		end if;

		delete from fnd_concurrent_queues_tl
                  where upper(CONCURRENT_QUEUE_NAME) = upper(mgr_name)
                  AND application_id = (SELECT application_id FROM fnd_application WHERE application_short_name = 'FND');

	    begin
		fnd_manager.register(sm_name || ': ' || node, 'FND',
			mgr_name, sm_name, 'Service Manager',
			     null, null, node, null, null, null,
			     	'FNDSM', 'FND', null, 'US'  );
	    end;
	end if;

end register_fndsm_fcq;

PROCEDURE register_fndim_fcq(node varchar2)
is
	mgr_name varchar2(256);
	im_name  varchar2(241);
	ncount	 number;
	qcount	 number;
	dummy    number;
        svcparams varchar2(256);
begin
	mgr_name := 'FNDIM_' || node;
	IF lengthb(mgr_name) > 256
	THEN
		mgr_name := substrb(mgr_name,1,256);
	END IF;

        select count(*)
	into qcount
	from fnd_concurrent_queues
	where manager_type = '2'
	 and  node_name = node;

	if (qcount = 0) then
		select count(*)
		into ncount
		from fnd_concurrent_queues
		where upper(CONCURRENT_QUEUE_NAME) = upper(mgr_name);

		if (ncount <> 0) then
			select fnd_concurrent_queues_s.nextval
			into dummy
			from dual;

			mgr_name := substrb('FNDIM_'||dummy||'_'||node,
						1, 256);
		end if;

	    im_name := fnd_message.get_string('FND', 'CONC-FNDIM NAME');
		if(im_name = 'CONC-FNDIM NAME') then
			im_name := 'Internal Monitor';
		end if;

		delete from fnd_concurrent_queues_tl
                  where upper(CONCURRENT_QUEUE_NAME) = upper(mgr_name)
                  AND application_id = (SELECT application_id FROM fnd_application WHERE application_short_name = 'FND');

	    begin
		fnd_manager.register(im_name || ': ' || node, 'FND',
			mgr_name, im_name, 'Internal Monitor',
			     null, null, node, null, null, null,
			     	'FNDIMON', 'FND', null, 'US'  );
                fnd_manager.assign_work_shift(manager_short_name=>mgr_name,
                       manager_application=>'FND',
                       work_shift_id => 0,
                       processes=>1,
                       sleep_seconds=>30,
                               svc_params=>svcparams);

                update fnd_concurrent_queues
                    set control_code = NULL
                    where upper(concurrent_queue_name) = upper(mgr_name);
	    end;
	end if;

end register_fndim_fcq;

PROCEDURE register_oamgcs_fcq(node IN varchar2,Oracle_home IN varchar2
DEFAULT null, interval IN number DEFAULT 300000)
is
	mgr_name varchar2(256);
	name  varchar2(241);
	svcparams varchar2(256);
	qcount	 number;
	ncount   number;
	dummy    number;
begin
	mgr_name := 'OAMGCS_' || node;
	svcparams := 'NODE=' || node || ';ORACLE_HOME='|| Oracle_home ||';LOADINTERVAL=' ||TO_CHAR(interval) ||
';RTI_KEEP_DAYS=1;FRD_KEEP_DAYS=7';
	IF lengthb(mgr_name) > 256
	THEN
		mgr_name := substrb(mgr_name,1,256);
	END IF;

    select count(*)
	into qcount
	from fnd_concurrent_queues
	where node_name = node
	 and TO_NUMBER(manager_type) = (select service_id
		from fnd_cp_services where service_handle='OAMGCS');

        if (qcount = 0) then
	        select count(*)
		into ncount
		from fnd_concurrent_queues
		where upper(CONCURRENT_QUEUE_NAME) = upper(mgr_name);

		if (ncount <> 0) then
			select fnd_concurrent_queues_s.nextval
			into dummy
			from dual;

			mgr_name := substrb('OAMGCS_'||dummy||'_'||node,
						1, 256);
		end if;

  	        name := fnd_message.get_string('FND', 'CONC-OAMGCS NAME');

		if(name = 'CONC-OAMGCS NAME') then
			name := 'OAM Generic Collection Service';
		end if;

		delete from fnd_concurrent_queues_tl
                  where upper(CONCURRENT_QUEUE_NAME) = upper(mgr_name)
                  AND application_id = (SELECT application_id FROM fnd_application WHERE application_short_name = 'FND');

	    begin
  		if not fnd_manager.Manager_exists(name || ':' ||node,'FND') then
		  fnd_manager.register_si(manager=>name || ': ' || node,
					application=>'FND',
					short_name=>mgr_name,
					service_handle=>'OAMGCS',
					PRIMARY_NODE=>node);
		end if;
                /* Bug 2557014: use work_shift_id parameter insted of
                   workshift_name parameter to ensure Standard workshift
                   is found in NLS instances */
  		if not fnd_manager.manager_work_shift_exists(name || ':' ||node,'FND','Standard') then
     fnd_manager.assign_work_shift(manager_short_name=>mgr_name,
                       manager_application=>'FND',
                       work_shift_id => 0,
                       processes=>1,
		       sleep_seconds=>30,
	                       svc_params=>svcparams);
		end if;
	    end;
	end if;

end register_oamgcs_fcq;


procedure register_fndsm_db( ospid IN number,
			     cpid  IN number,
		          instance IN varchar2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
	nodename fnd_concurrent_processes.node_name%type;
	opid number;
	audsid number;
	dbname varchar2(8);
	dbdomain varchar2(120);
	dbinstname varchar2(16);
	insnum number;
begin
	select instance_number
	  into insnum
	  from v$instance;

	select instance_name
	  into dbinstname
	  from v$instance;

	select sys_context('userenv','db_name')
	  into dbname
	  from dual;

	select value
	  into dbdomain
	  from v$parameter
	 where name = 'db_domain';

	select userenv('SESSIONID')
	  into audsid
	  from dual;

	select p.pid
	  into opid
	  from v$process p, v$session s
	 where s.audsid = userenv('SESSIONID')
	   and p.addr = s.paddr;

	select node_name
	  into nodename
	  from fnd_concurrent_processes
	 where concurrent_process_id = cpid;

	update fnd_concurrent_processes
		set oracle_process_id = opid,
		    session_id = audsid,
                    db_name = dbname,
                    db_domain = dbdomain,
                    db_instance = dbinstname,
                    sqlnet_string = instance,
                    instance_number = insnum
		where os_process_id = ospid
                  and process_status_code = 'A'
		  and node_name = nodename;

	commit;

     exception
        when others then
           rollback;

end register_fndsm_db;

procedure insert_service_fcp( cmpid IN number,
			      qapid IN number,
				qid IN number,
			   mgrusrid IN number,
			    mgrtype IN varchar2,
                               node IN varchar2)
is
PRAGMA AUTONOMOUS_TRANSACTION;
begin
	INSERT INTO FND_CONCURRENT_PROCESSES
        	(CONCURRENT_PROCESS_ID, ORACLE_PROCESS_ID,
		QUEUE_APPLICATION_ID,  CONCURRENT_QUEUE_ID,
		OS_PROCESS_ID,         SESSION_ID,
		Creation_Date,         Created_By,
		LAST_UPDATE_DATE,      LAST_UPDATED_BY,
		PROCESS_START_DATE,    PROCESS_STATUS_CODE,
		MANAGER_TYPE,          NODE_NAME,
		Lk_Handle)
		VALUES
		(cmpid,    '999999',
		 qapid,    qid,
		 '999999',  '999999',
		 Sysdate,   mgrusrid,
		 SYSDATE,   mgrusrid,
		 SYSDATE,   'Z',
		 mgrtype,  upper(node),
		 'SERVICE');

	commit;

     exception
        when others then
           rollback;
           raise;

end insert_service_fcp;

end fnd_cp_fndsm;

/
