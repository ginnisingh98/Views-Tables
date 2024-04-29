--------------------------------------------------------
--  DDL for Package Body FND_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_JOBS_PKG" as
/* $Header: AFJOBPKB.pls 120.1 2005/07/02 04:08:45 appldev noship $ */
  C_LOG_HEAD 	CONSTANT VARCHAR2(30) := 'fnd.plsql.FND_JOBS_PKG.';
--
  procedure APPS_INITIALIZE_SYSADMIN is
    L_USER_ID      number;
    L_RESP_ID      number;
    L_RESP_APPL_ID number;
  begin
    begin
      select USER_ID into L_USER_ID from FND_USER where USER_NAME = 'SYSADMIN';
    exception when OTHERS then
      L_USER_ID := 0;
    end;
    begin
      select R.APPLICATION_ID, R.RESPONSIBILITY_ID
        into L_RESP_APPL_ID, L_RESP_ID
        from FND_APPLICATION A, FND_RESPONSIBILITY R
       where R.APPLICATION_ID = A.APPLICATION_ID
         and A.APPLICATION_SHORT_NAME = 'SYSADMIN'
         and R.RESPONSIBILITY_KEY = 'SYSTEM_ADMINISTRATOR';
    exception when OTHERS then
      L_RESP_APPL_ID := 1;
      L_RESP_ID := 20420;
    end;
    FND_GLOBAL.APPS_INITIALIZE(USER_ID      => L_USER_ID,
                               RESP_ID      => L_RESP_ID,
                               RESP_APPL_ID => L_RESP_APPL_ID);
  end APPS_INITIALIZE_SYSADMIN;
--
  /*
  ** No AOL equivalent - replace with body of code that combines
  ** calls to FND_CONC_MAINTAIN.APPS_INITIALIZE_FOR_MGR,
  **          FND_CONC_MAINTAIN.GET_PENDING_REQUEST_ID,
  **      and FND_REQUEST.SUBMIT_REQUEST
  */
  function SUBMIT_JOB(P_APPLICATION_SHORT_NAME  in varchar2,
                      P_CONCURRENT_PROGRAM_NAME in varchar2,
                      P_ALTERNATE_PROGRAM       in varchar2)
    return number is
    JOB_NUMBER number;
    JOB_BROKEN varchar2(30);
    JOB_SID    number;
    JOB_STRING varchar2(4000);
  begin
    JOB_STRING := P_ALTERNATE_PROGRAM||';';
    begin
/*
      select J.JOB, J.BROKEN, R.SID
        into JOB_NUMBER, JOB_BROKEN, JOB_SID
        from DBA_JOBS J, DBA_JOBS_RUNNING R
       where J.WHAT = JOB_STRING
         and J.JOB = R.JOB(+);
*/
      if (JOB_BROKEN = 'Y') then
        -- If the job is broken, remove it (### and resubmit ###)
        DBMS_JOB.REMOVE(JOB_NUMBER);
      elsif (JOB_SID is null) then
        return(null); -- Job is pending but not running
      end if;
    exception when NO_DATA_FOUND then
      JOB_NUMBER := null;
    end;
    /* Job is either running or doesn't exist, so submit it */
    DBMS_JOB.SUBMIT(JOB_NUMBER, JOB_STRING);
    return(JOB_NUMBER);
  exception when OTHERS then
    return(0); -- Job submission failed for some reason
  end SUBMIT_JOB;
--
  function SUBMIT_MENU_COMPILE return varchar2 is
    l_api_name CONSTANT VARCHAR2(30) := 'SUBMIT_MENU_COMPILE';
    request_id number;
    phase varchar2(80);
    status varchar2(80);
    dev_phase varchar2(30);
    dev_status varchar2(30);
    message varchar2(255);
    result boolean;
  begin
    /* Submit a concurrent request to compile the marked menus. */
    --
    /*
    ** Make sure that we are intialized as the special user
    ** that will submit the request
    */
    begin
      FND_CONC_MAINTAIN.apps_initialize_for_mgr;
    exception
      when others then
       if ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
         fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                        c_log_head || l_api_name || '.init_failed',
            'A Failure occurred in FND_CONC_MAINTAIN.apps_initialize_for_mgr');
       end if;
       return 'E';
    end;
    --
    /* First check if the request is already about to be run */
    request_id := FND_CONC_MAINTAIN.get_pending_request_id('FND', 'FNDSCMPI');
    if ((FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.get_req_status',
                     'Checked request status. request_id:' || request_id);
    end if;
    /* If it is about to be run then there will be a request id. */
    if ((request_id is not NULL) and (request_id = 0)) then
      /* Submit the recompile request since it isn't about to be run */
      request_id := fnd_request.submit_request (application => 'FND',
                                                program     => 'FNDSCMPI',
                                                argument1   => 'N');
      if ((FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                       c_log_head || l_api_name || '.submit',
                   'to recompile, Submitted FNDSCMPI request id:'||request_id);
      end if;
      if (request_id = 0) then
        if ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
          fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                         c_log_head || l_api_name || '.submit_failed',
                      'Request ID zero means submission failed.  Msg on stack:'
                         || fnd_message.get);
        end if;
        return 'E';
      end if;
      return 'S';
    end if;
    return 'P';
  exception
    when others then /* If we can't submit the request.*/
      if ((FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)) then
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                       c_log_head || l_api_name || '.req_submit_fail',
            'Could not submit concurrent request FNDSCMPI to recompile menus');
      end if;
      return 'E';
  end SUBMIT_MENU_COMPILE;
--
  procedure SUBMIT_MENU_COMPILE is
    /* Submit a concurrent request to compile the marked menus. */
    l_api_name CONSTANT VARCHAR2(30) := 'SUBMIT_MENU_COMPILE';
    request_id number;
    phase varchar2(80);
    status varchar2(80);
    dev_phase varchar2(30);
    dev_status varchar2(30);
    message varchar2(255);
    result boolean;
  begin
    /* First check if the request is already about to be run */
    request_id := NULL;
    result := fnd_concurrent.get_request_status(request_id, 'FND', 'FNDSCMPI',
                                                phase, status, dev_phase,
                                                dev_status, message);
    /* Log result */
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                     c_log_head || l_api_name || '.get_req_status',
                     'Checked request status. dev_phase:'
                     || dev_phase ||' dev_status:'||dev_status);
    end if;
    /* If it is about to be run then phase will be 'PENDING'  */
    /* and status will be 'NORMAL' (not scheduled or standby) */
    if ((dev_phase <> 'PENDING') or
        (dev_status <> 'NORMAL') or
        (dev_status is null)) then
      /* Submit the recompile request since it isn't about to be run */
      request_id := fnd_request.submit_request(application => 'FND',
                                               program     => 'FNDSCMPI',
                                               argument1   => 'N');
      /* Log result */
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,
                       c_log_head || l_api_name || '.submit',
                   'to recompile, Submitted FNDSCMPI request id:'||request_id);
      end if;
    end if;
  exception
    when others then /* Don't error out if we can't submit the request.*/
      if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,
                       c_log_head || l_api_name || '.req_submit_fail',
            'Could not submit concurrent request FNDSCMPI to recompile menus');
        end if;
  end SUBMIT_MENU_COMPILE;
--
end FND_JOBS_PKG;

/
