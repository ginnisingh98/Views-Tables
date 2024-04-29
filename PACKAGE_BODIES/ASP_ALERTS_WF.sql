--------------------------------------------------------
--  DDL for Package Body ASP_ALERTS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ALERTS_WF" as
/* $Header: aspalrtb.pls 120.5 2005/09/09 17:45 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_WF
---------------------------------------------------------------------------
-- Description:
--    This package contains functions associated with the Workflow Activity
--     node that interfaces with BSA Workflow and used in the Sales Alerts System.
--
-- Procedures:
--   (see the specification for details)
--
-- History:
--   10-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             Private Constants
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ALERTS_WF';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspalrtb.pls';
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
-- Procedure: Initiate_Bsa_Alerts
--   This function is associated with the BSA activity node  and will launch the
--   ASP ALERTS workflow Process.
--
--------------------------------------------------------------------------------

PROCEDURE Initiate_Bsa_Alerts(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2)
IS
  l_event_entity varchar2(100);
  l_api_name varchar2(100);
  l_qualified_api_name varchar2(200);
  l_debug_msg varchar2(1000);
  l_blanketHeaderId number;
  l_item_key           varchar2(240);
  l_pre_expire_time_percent varchar2(100);
  save_threshold number;

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

BEGIN
  l_api_name := 'Initiate_Bsa_Alerts';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  save_threshold :=  wf_engine.threshold;
  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  If(funcmode = 'RUN') Then
--    l_pre_expire_time_percent := wf_engine.GetItemAttrText( itemtype =>itemtype,
--                                                itemkey =>itemkey,
--                                                aname =>'PRE_EXPIRE_TIME_PERCENT');
    l_pre_expire_time_percent := wf_engine.GetActivityAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                actid => actid,
                                                aname =>'ALERT_PRE_EXPIRE_TIME_PERCENT');
    -- Construct the unique item key
    l_blanketHeaderId := To_number(itemkey);

--======================================================
    SELECT l_blanketHeaderId ||'-'|| to_char(asp_wf_alerts_s.nextval) INTO l_item_key FROM DUAL;
    -- Start the ASP Alert Manager Process (ASP_ALERT_PROCESS) with the following info:
    wf_engine.threshold := -1;
    wf_engine.CreateProcess( itemtype => 'ASPALERT', itemkey => l_item_key, process => 'ASP_ALERT_PROCESS',user_key=>l_item_key);
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_NAME', 'BSA_PRE_EXPIRE_ALERT');
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_CODE', 'ORDER');
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_ID', l_blanketHeaderId);
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_PRE_EXPIRE_TIME_PERCENT', l_pre_expire_time_percent);
    wf_engine.StartProcess(itemtype => 'ASPALERT', itemkey => l_item_key);
    commit;
    resultout := 'COMPLETE:SUCCESS';
    wf_engine.threshold := save_threshold;
    return;
--======================================================

--May be needed latter
--======================================================
/*******************************************************
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_NAME', 'BSA_PRE_EXPIRE_ALERT');
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_CODE', 'ORDER');
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_ID', l_blanketHeaderId);
    --wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_PRE_EXPIRE_TIME_PERCENT', l_pre_expire_time_percent);
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'ALERT_NAME '||'BSA_PRE_EXPIRE_ALERT');
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'ALERT_SOURCE_OBJECT_CODE '||'ORDER');
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_blanketHeaderId '||l_blanketHeaderId);
      --fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_pre_expire_time_percent '||l_pre_expire_time_percent);
    end if;

    resultout := 'COMPLETE:SUCCESS';
    return;
********************************************************/
--======================================================

  End If;
  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := '';
  wf_engine.threshold := save_threshold;
  return;

EXCEPTION
  When no_data_found Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':NO_DATA_FOUND:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_engine.threshold := save_threshold;
    wf_core.raise('WF_ORA');

  When others Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':OTHERS:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_engine.threshold := save_threshold;
    wf_core.raise('WF_ORA');

END Initiate_Bsa_Alerts;


End ASP_ALERTS_WF;

/
