--------------------------------------------------------
--  DDL for Package Body ASP_ALERTS_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ALERTS_INVOICE" as
/* $Header: aspaodib.pls 120.3 2005/09/28 13:45 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_INVOICE
---------------------------------------------------------------------------
-- Description:
--  Alerts for overdue invoice is obtained by this
--  Concurrent Program, which periodically looks at the transaction tables
--  in Oracle Collections.
--
-- Procedures:
--   (see the specification for details)
--
-- History:
--   16-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             Private Constants
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ALERTS_INVOICE';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspaodib.pls';
G_MODULE    CONSTANT VARCHAR2(250) := 'asp.plsql.'||G_PKG_NAME||'.';


/*-------------------------------------------------------------------------*
 |                             Private Datatypes
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Private Variables
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Private Routines Specification
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Public Routines
 *-------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
--
--  Procedure: Alert_Overdue_Invoice
--  Finds all the overdue invoices.
--
--------------------------------------------------------------------------------

PROCEDURE Alert_Overdue_Invoice(
      errbuf     OUT NOCOPY    VARCHAR2,
      retcode    OUT NOCOPY    VARCHAR2)
IS

  l_api_name varchar2(100);
  l_program_ref_date date;
  l_current_run_ref_date date;

  l_event_key          number;
  l_item_key           varchar2(240);
  l_delinquency_id        number;


  l_PROGRAM_START_DATE date;
  l_REQUEST_ID number;
  l_PROGRAM_APPLICATION_ID number;
  l_PROGRAM_ID number;
  l_PROGRAM_LOGIN_ID number;
  l_CREATED_BY number;
  l_LAST_UPDATED_BY number;
  l_LAST_UPDATE_LOGIN number;
  save_threshold number;
  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

  CURSOR getLastRunDate is
    SELECT program_ref_date
    FROM  asp_program_run_dates
    WHERE  program_object_code = 'ASPODINV' --'INVOICE'
       and status_code = 'S'
       and rownum < 2;

  CURSOR getDelinquencyDeltaRun is
    Select d.delinquency_id
    from IEX_DEL_ALERTS_PUB_V d, AR_PAYMENT_SCHEDULES_ALL ps
    where trunc(d.last_update_date) between trunc(l_program_ref_date+1)
                          and trunc(l_current_run_ref_date)
      and ps.payment_schedule_id = d.payment_schedule_id
      and ps.class = 'INV' and ps.status = 'OP';



BEGIN
  l_api_name := 'Alert_Overdue_Invoice';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  save_threshold :=  wf_engine.threshold;
  l_PROGRAM_START_DATE := sysdate;
  l_REQUEST_ID := TO_NUMBER(fnd_profile.value('CONC_REQUEST_ID'));
  l_PROGRAM_APPLICATION_ID :=  FND_GLOBAL.PROG_APPL_ID;
  l_PROGRAM_ID :=  TO_NUMBER(fnd_profile.value('CONC_PROGRAM_ID'));
  l_PROGRAM_LOGIN_ID := TO_NUMBER(fnd_profile.value('USER_ID'));
  l_CREATED_BY := l_PROGRAM_LOGIN_ID;
  l_LAST_UPDATED_BY := l_PROGRAM_LOGIN_ID;
  l_LAST_UPDATE_LOGIN :=  TO_NUMBER(fnd_profile.value('CONC_LOGIN_ID'));

  open getLastRunDate;
  fetch getLastRunDate into l_program_ref_date;
  close getLastRunDate;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After opening cursor getLastRunDate');
  end if;

  l_current_run_ref_date := sysdate;

  IF(l_program_ref_date is null) THEN
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_program_ref_date is null');
    end if;
   delete asp_program_run_dates where PROGRAM_OBJECT_CODE = 'ASPODINV';
    insert into asp_program_run_dates(
     PROGRAM_RUN_ID,
     PROGRAM_OBJECT_CODE,
     STATUS_CODE,
     DESCRIPTION,
     PROGRAM_START_DATE,
     PROGRAM_END_DATE,
     PROGRAM_REF_DATE,
     RELATED_OBJECT_INFO,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_LOGIN_ID,
     OBJECT_VERSION_NUMBER,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
    )values(
     asp_program_run_dates_s.nextval,
     'ASPODINV', --'INVOICE'
     'S',
     null,
     l_PROGRAM_START_DATE,
     null,
     l_current_run_ref_date,
     null,
     l_REQUEST_ID,
     l_PROGRAM_APPLICATION_ID,
     l_PROGRAM_ID,
     l_PROGRAM_LOGIN_ID,
     1,
     sysdate,
     l_CREATED_BY,
     sysdate,
     l_LAST_UPDATED_BY,
     l_LAST_UPDATE_LOGIN
    );

    commit;
  ELSE
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_program_ref_date is not null');
    end if;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before opening getDelinquencyDeltaRun');
    end if;

    for del_rec in getDelinquencyDeltaRun
    loop
      wf_engine.threshold := -1;
      l_delinquency_id := del_rec.delinquency_id;
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_delinquency_id '||l_delinquency_id);
      end if;

      SELECT l_delinquency_id ||'-'|| to_char(asp_wf_alerts_s.nextval) INTO l_item_key FROM DUAL;
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key '||l_item_key);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before  wf_engine.CreateProcess ASP_ALERT_PROCESS');
      end if;
      -- Start the ASP Alert Manager Process (ASP_ALERT_PROCESS) with the following info:
      wf_engine.CreateProcess( itemtype => 'ASPALERT', itemkey => l_item_key, process => 'ASP_ALERT_PROCESS',user_key=>l_item_key);
      wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_NAME', 'INVOICE_OVERDUE_ALERT');
      wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_CODE', 'INVOICE');
      wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_ID', l_delinquency_id);
      wf_engine.StartProcess(itemtype => 'ASPALERT', itemkey => l_item_key);
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key '||l_item_key);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After  wf_engine.CreateProcess ASP_ALERT_PROCESS');
      end if;
      commit;
    end loop;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After opening getDelinquencyDeltaRun');
    end if;

    wf_engine.threshold := save_threshold;
    update asp_program_run_dates
    set program_ref_date = l_current_run_ref_date
    where program_object_code = 'ASPODINV' --'INVOICE'
        and status_code = 'S';
    commit;
  END IF;


EXCEPTION
  WHEN others THEN
      wf_engine.threshold := save_threshold;
      raise;

END Alert_Overdue_Invoice;


END ASP_ALERTS_INVOICE;


/
