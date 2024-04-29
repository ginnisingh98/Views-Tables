--------------------------------------------------------
--  DDL for Package Body FND_APD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APD" as
/* $Header: AFRTPRFB.pls 120.1 2005/07/02 04:15:26 appldev ship $ */

/*
 * Procedure: collect
 *
 * Purpose:
 *
 * Arguments:
 *
 */
PROCEDURE collect is
   p_req_id      NUMBER;
   session       NUMBER;
   parentreqid   NUMBER;
   vdbname       varchar2(16);
   vversion      varchar2(17);
   vsql          varchar2(256);
   errmsg        varchar2(80);
   tracefile     varchar2(30);
   udump         varchar2(64);
   module_id     varchar2(10);
   flow_id       varchar2(30);
   vduration     NUMBER;
   sdate         date;
   cdate         date;
   status_code   varchar2(1);
   phase_code   varchar2(1);
BEGIN
  p_req_id := fnd_global.conc_request_id;

  BEGIN
    SELECT sid
    INTO   session
    FROM   v$session
    WHERE  audsid = userenv('SESSIONID');
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:Collect:Error while getting session Id ');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:Collect:Error while getting session Id ');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

  BEGIN
    SELECT value
    INTO   udump
    FROM   v$parameter
    WHERE  name = 'user_dump_dest';
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:Collect:Error getting user dump destination ');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:Collect:Error getting user dump destination ');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

  BEGIN
     select application_short_name , concurrent_program_name,
            round((sysdate-fcr.actual_start_date)*24*60*60,2)
            , fcr.phase_code , fcr.status_code , actual_start_date,
             actual_completion_date,
           lower(instance_name) || '_ora_' || fcr.oracle_process_id
           || '.trc'  , instance_name, parent_request_id,
           version
     into   module_id, flow_id, vduration, phase_code , status_code,
            sdate, cdate, tracefile , vdbname, parentreqid, vversion
     from   fnd_concurrent_requests fcr, fnd_application fa,
            fnd_concurrent_programs fcp, v$instance
     where  fcr.request_id = p_req_id
     and    fcr.program_application_id = fa.application_id
     and    fcr.concurrent_program_id = fcp.concurrent_program_id
     and    fcr.program_application_id = fcp.application_id;
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:Collect:Error getting data from FND tables...');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:Collect:Error getting data from FND tables...');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

  BEGIN
   vsql := 'begin gatherCPStat@rtperf(:1,:2,:3, ''C'',:4, :5, :6, :7, :8, :9 , :10); end; ';
   execute immediate vsql using p_req_id,session,vdbname,parentreqid,vversion,tracefile,udump,module_id,flow_id,vduration;
   EXCEPTION
   when others then
    errmsg := substr(sqlerrm,1,80);
    fnd_file.put_line(fnd_file.log,'fnd_apd:Collect:Error during remote procedure call');
    fnd_file.put_line(fnd_file.log,errmsg);
  END;

END collect;

/*
 * Procedure: store_initial
 *
 * Purpose:
 *
 * Arguments:
 *
 */
PROCEDURE  store_initial is
   p_req_id      NUMBER;
   session       NUMBER;
   parentreqid   NUMBER;
   vdbname       varchar2(16);
   vversion      varchar2(17);
   vsql          varchar2(256);
   errmsg        varchar2(80);
   tracefile     varchar2(30);
   udump         varchar2(64);
   module_id     varchar2(10);
   flow_id       varchar2(30);
   vduration     NUMBER;
   sdate         date;
   cdate         date;
   status_code   varchar2(1);
   phase_code   varchar2(1);
BEGIN
  p_req_id := fnd_global.conc_request_id;
  BEGIN
    vsql :=  'alter session set tracefile_identifier = ' || p_req_id ;
    execute immediate vsql ;
    EXCEPTION
    when others then
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;
  BEGIN
    SELECT sid
    INTO   session
    FROM   v$session
    WHERE  audsid = userenv('SESSIONID');
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_initial:Error while getting session Id ');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_initial:Error while getting session Id ');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

  BEGIN
    SELECT value
    INTO   udump
    FROM   v$parameter
    WHERE  name = 'user_dump_dest';
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_initial:Error getting user dump destination ');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_initial:Error getting user dump destination ');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

  BEGIN
     select application_short_name , concurrent_program_name,
           lower(instance_name) || '_ora_' || fcr.oracle_process_id
           || '_' || p_req_id || '.trc'  , instance_name, parent_request_id,
           version
     into   module_id, flow_id, tracefile , vdbname, parentreqid, vversion
     from   fnd_concurrent_requests fcr, fnd_application fa,
            fnd_concurrent_programs fcp, v$instance
     where  fcr.request_id = p_req_id
     and    fcr.program_application_id = fa.application_id
     and    fcr.concurrent_program_id = fcp.concurrent_program_id
     and    fcr.program_application_id = fcp.application_id;
    EXCEPTION
    when no_data_found then
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_initial:Error getting data from FND tables...');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_initial:Error getting data from FND tables...');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;
  BEGIN
   vsql := 'begin gatherCPStat@rtperf(:1,:2,:3, ''I'',:4, :5, :6, :7, :8, :9 , :10); end; ';
   execute immediate vsql using p_req_id,session,vdbname,parentreqid,vversion,tracefile,udump,module_id,flow_id,vduration;
    EXCEPTION
    when others then
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_initial:Error during remote procedure call');
      fnd_file.put_line(fnd_file.log,errmsg);
  END;
END store_initial;

/*
 * Procedure: store_final
 *
 * Purpose:
 *
 * Arguments:
 *
 */
PROCEDURE  store_final is
   p_req_id      NUMBER;
   session       NUMBER;
   parentreqid   NUMBER;
   vdbname       varchar2(16);
   vversion      varchar2(17);
   vsql          varchar2(256);
   errmsg        varchar2(80);
   tracefile     varchar2(30);
   udump         varchar2(64);
   module_id     varchar2(10);
   flow_id       varchar2(30);
   vduration     NUMBER;
   sdate         date;
   cdate         date;
   status_code   varchar2(1);
   phase_code   varchar2(1);
 BEGIN
  p_req_id := fnd_global.conc_request_id;
  BEGIN
    SELECT sid
    INTO   session
    FROM   v$session
    WHERE  audsid = userenv('SESSIONID');
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_final:Error while getting session Id ');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_final:Error while getting session Id ');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

  BEGIN
    SELECT value
    INTO   udump
    FROM   v$parameter
    WHERE  name = 'user_dump_dest';
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_final:Error getting user dump destination ');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_final:Error getting user dump destination ');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

  BEGIN
     select application_short_name , concurrent_program_name,
            round((sysdate-fcr.actual_start_date)*24*60*60,2),
           lower(instance_name) || '_ora_' || fcr.oracle_process_id
           || '_' || p_req_id || '.trc'  , instance_name, parent_request_id,
           version
     into  module_id,flow_id,vduration,tracefile,vdbname,parentreqid,vversion
     from   fnd_concurrent_requests fcr, fnd_application fa,
            fnd_concurrent_programs fcp, v$instance
     where  fcr.request_id = p_req_id
     and    fcr.program_application_id = fa.application_id
     and    fcr.concurrent_program_id = fcp.concurrent_program_id;
    EXCEPTION
    when no_data_found then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_final:Error getting data from FND tables...');
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_final:Error getting data from FND tables...');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;
  BEGIN
    vsql := 'begin gatherCPStat@rtperf(:1,:2,:3, ''F'',:4, :5, :6, :7, :8, :9 , :10); end; ';
    execute immediate vsql using p_req_id,session,vdbname,parentreqid,vversion,tracefile,udump,module_id,flow_id,vduration;
    EXCEPTION
    when others then
      fnd_file.put_line(fnd_file.log,'fnd_apd:store_final:Error during remote procedure call');
      errmsg := substr(sqlerrm,1,80);
      fnd_file.put_line(fnd_file.log,errmsg);
  END;

END store_final;


PROCEDURE RTTrace  is
icxid number ;
vspid number ;
vsql varchar2(1024) ;
vinstance varchar2(16) ;
vtechstack varchar2(16) ;
vrequest_id number;
errmsg varchar2(80);
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

BEGIN
-- Call performace package.
if ( rt_perf_stat_enabled ) then

 BEGIN
  icxid := icx_sec.g_session_id;
  if (fnd_global.form_id > 0) then
   vtechstack := 'F';
  elsif (fnd_global.conc_request_id > 0) then
   vrequest_id := fnd_global.conc_request_id ;
   vtechstack := 'C';
  else
   vtechstack := 'J';
  end if;
  if ( icxid > 0 ) then
    vsql := 'alter session set tracefile_identifier = ''' || icxid || '''' ;
   else
    vsql := 'alter session set tracefile_identifier = ''' || '''' ;
  end if;
  EXECUTE IMMEDIATE vsql ;
  vsql := 'alter session set events ''10046 trace name context forever , level 8''';
  EXECUTE IMMEDIATE vsql ;
 END;
 BEGIN
  select spid into vspid
  from   v$process p,v$session s
  where  p.addr = s.paddr
  and    s.audsid = userenv('SESSIONID');
  EXCEPTION
  when no_data_found then
    raise_application_error(-20100,'Error select SPID ...');
  when others then
    errmsg := substr(sqlerrm,1,80);
    raise_application_error(-20100,errmsg);
 END;
 BEGIN
  select instance_name
  into   vinstance
  from   v$instance i;
  EXCEPTION
  when no_data_found then
    raise_application_error(-20100,'Error select Instance ...');
  when others then
    errmsg := substr(sqlerrm,1,80);
    raise_application_error(-20100,errmsg);
 END;
 BEGIN
  if ( icxid > 0 ) then
    vsql := 'insert into rt_icx_data@rtperf
             ( icxid , spid , instance , techstack , creation_date, request_id)              select :b1 , :b2, upper(:b3), :b4, sysdate, :b5 from dual
             where not exists ( select ''x'' from rt_icx_data@rtperf
              where icxid = :b6 and   spid = :b7 and   instance = upper(:b8)
              and   techstack = upper(:b9)) ';
    EXECUTE IMMEDIATE vsql using icxid , vspid , vinstance, vtechstack, vrequest_id, icxid, vspid, vinstance, vtechstack;
    commit;
  end if;
  EXCEPTION
  when others then
    rollback;
    errmsg := substr(sqlerrm,1,80);
    raise_application_error(-20100,errmsg);
 END;
end if;
END RTTrace;

end;

/
