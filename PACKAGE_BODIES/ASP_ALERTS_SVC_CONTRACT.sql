--------------------------------------------------------
--  DDL for Package Body ASP_ALERTS_SVC_CONTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ALERTS_SVC_CONTRACT" as
/* $Header: aspaescb.pls 120.3 2005/09/13 17:19 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_SVC_CONTRACT
---------------------------------------------------------------------------
-- Description:
--  Alerts for expiring service contract is obtained by this
--  Concurrent Program, which periodically looks at the transaction tables
--  in Oracle Service Contract.
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
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ALERTS_SVC_CONTRACT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspaescb.pls';
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
--  Procedure: Alert_Expiring_SvcContracts
--  Finds all the Active Service Contracts that are expiring in X days.
--
--------------------------------------------------------------------------------

PROCEDURE Alert_Expiring_SvcContracts(
      errbuf     OUT NOCOPY    VARCHAR2,
      retcode    OUT NOCOPY    VARCHAR2,
      p_num_days IN      VARCHAR2)
IS

  l_api_name varchar2(100);
  l_program_ref_date date;
  l_current_run_ref_date date;

  l_event_key          number;
  l_item_key           varchar2(240);
  l_contract_id        number;

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(4000);
  l_renewal_type VARCHAR2(1000);
  l_approval_type VARCHAR2(1000);
  l_threshold_used VARCHAR2(1000);

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
  p_number_of_days number;

  CURSOR getLastRunDate is
    SELECT program_ref_date
    FROM  asp_program_run_dates
    WHERE  program_object_code = 'ASPEXPSC' --'SERVICE_CONTRACT'
       and status_code = 'S'
       and rownum < 2;

  CURSOR getServiceContractsFreshRun IS
    select
      a.id as contract_id
    from
    okc_k_headers_all_b a, okc_statuses_b b
    where application_id = 515
    and a.sts_code = b.code
    and b.ste_code in ('ACTIVE', 'EXPIRED', 'SIGNED')
    and trunc(a.end_date)  between trunc(l_current_run_ref_date) and
                           trunc(l_current_run_ref_date + p_number_of_days);
                           --and rownum < 2;

  CURSOR getServiceContractsDeltaRun is
    select
      a.id as contract_id
    from
    okc_k_headers_all_b a, okc_statuses_b b
    where application_id = 515
    and a.sts_code = b.code
    and b.ste_code in ('ACTIVE', 'EXPIRED', 'SIGNED')
    and trunc(a.end_date) between trunc(l_program_ref_date+1)
                          and trunc(l_current_run_ref_date + p_number_of_days);



BEGIN
  l_api_name := 'Alert_Expiring_SvcContracts';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  p_number_of_days := p_num_days;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'user entered num of days '||to_char(p_number_of_days));
  end if;
  --if 1=1 then   return;   end if;
  if (p_number_of_days is null) then
    p_number_of_days := 10;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'system assigned num of days '||to_char(p_number_of_days));
    end if;
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
    mo_global.set_policy_context('A',null);--authoring_ord_id
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before opening getServiceContractsFreshRun');
    end if;

    for svccontract_rec in getServiceContractsFreshRun
    loop
      l_contract_id := svccontract_rec.contract_id;
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_contract_id '||l_contract_id);
      end if;

      oks_renew_util_pub.GET_RENEWAL_TYPE(
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_TRUE,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_chr_id => l_contract_id,
        x_renewal_type => l_renewal_type,--EVN (Evergreen), DNR (Do not Renew), ERN (Online), NSR (Manual)
        x_approval_type => l_approval_type,
        x_threshold_used => l_threshold_used
      );
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After Calling oks_renew_util_pub.GET_RENEWAL_TYPE - x_return_status:'||l_return_status);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_renewal_type '||l_renewal_type);
      end if;

      if(nvl(l_renewal_type,'X') <> 'EVN') then
        SELECT l_contract_id ||'-'|| to_char(asp_wf_alerts_s.nextval) INTO l_item_key FROM DUAL;
        if(l_debug_procedure >= l_debug_runtime) then
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key '||l_item_key);
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before  wf_engine.CreateProcess ASP_ALERT_PROCESS');
        end if;
        -- Start the ASP Alert Manager Process (ASP_ALERT_PROCESS) with the following info:
        wf_engine.threshold := -1;
        wf_engine.CreateProcess( itemtype => 'ASPALERT', itemkey => l_item_key, process => 'ASP_ALERT_PROCESS',user_key=>l_item_key);
        wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_NAME', 'SVCCONTRACT_PRE_EXPIRE_ALERT');
        wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_CODE', 'SERVICE_CONTRACT');
        wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_ID', l_contract_id);
        wf_engine.StartProcess(itemtype => 'ASPALERT', itemkey => l_item_key);
        if(l_debug_procedure >= l_debug_runtime) then
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key '||l_item_key);
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After  wf_engine.CreateProcess ASP_ALERT_PROCESS');
        end if;
        commit;
      end if;
    end loop;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After opening getServiceContractsFreshRun');
    end if;

    --program_ref_date = current_run_ref_date of this run + X of this run
    delete asp_program_run_dates where PROGRAM_OBJECT_CODE = 'ASPEXPSC';
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
     'ASPEXPSC', --'SERVICE_CONTRACT'
     'S',
     null,
     l_PROGRAM_START_DATE,
     null,
     l_current_run_ref_date + p_number_of_days,
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
    mo_global.set_policy_context('A',null);--authoring_ord_id
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before opening getServiceContractsDeltaRun');
    end if;

    for svccontract_rec in getServiceContractsDeltaRun
    loop
      l_contract_id := svccontract_rec.contract_id;
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_contract_id '||l_contract_id);
      end if;

      oks_renew_util_pub.GET_RENEWAL_TYPE(
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_TRUE,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_chr_id => l_contract_id,
        x_renewal_type => l_renewal_type,--EVN (Evergreen), DNR (Do not Renew), ERN (Online), NSR (Manual)
        x_approval_type => l_approval_type,
        x_threshold_used => l_threshold_used
      );
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After Calling oks_renew_util_pub.GET_RENEWAL_TYPE - x_return_status:'||l_return_status);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_renewal_type '||l_renewal_type);
      end if;

      if(nvl(l_renewal_type,'X') <> 'EVN') then
        SELECT l_contract_id ||'-'|| to_char(asp_wf_alerts_s.nextval) INTO l_item_key FROM DUAL;
        if(l_debug_procedure >= l_debug_runtime) then
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key '||l_item_key);
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before  wf_engine.CreateProcess ASP_ALERT_PROCESS');
        end if;

        -- Start the ASP Alert Manager Process (ASP_ALERT_PROCESS) with the following info:
        wf_engine.threshold := -1;
        wf_engine.CreateProcess( itemtype => 'ASPALERT', itemkey => l_item_key, process => 'ASP_ALERT_PROCESS',user_key=>l_item_key);
        wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_NAME', 'SVCCONTRACT_PRE_EXPIRE_ALERT');
        wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_CODE', 'SERVICE_CONTRACT');
        wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_ID', l_contract_id);
        wf_engine.StartProcess(itemtype => 'ASPALERT', itemkey => l_item_key);
        if(l_debug_procedure >= l_debug_runtime) then
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key '||l_item_key);
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After  wf_engine.CreateProcess ASP_ALERT_PROCESS');
        end if;

        commit;
      end if;
    end loop;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After opening getServiceContractsDeltaRun');
    end if;

    --program_ref_date = current_run_ref_date of this run + X of this run
    update asp_program_run_dates
    set program_ref_date = (l_current_run_ref_date + p_number_of_days)
    where program_object_code = 'ASPEXPSC' --'SERVICE_CONTRACT'
        and status_code = 'S';
    commit;
  END IF;
  wf_engine.threshold := save_threshold;

EXCEPTION
  WHEN others THEN
      wf_engine.threshold := save_threshold;
      raise;

END Alert_Expiring_SvcContracts;


END ASP_ALERTS_SVC_CONTRACT;


/
