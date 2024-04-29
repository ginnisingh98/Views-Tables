--------------------------------------------------------
--  DDL for Package Body ASP_ALERTS_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ALERTS_SUBS" as
/* $Header: aspasubb.pls 120.4 2005/11/22 16:11 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_SUBS
---------------------------------------------------------------------------
-- Description:
--      Generic Subscription Package for Sales Alerts Related Business Events.
--
-- Procedures:
--   (see the specification for details)
--
-- History:
--   08-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             Private Constants
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ALERTS_SUBS';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspasubb.pls';
G_MODULE    CONSTANT VARCHAR2(250) := 'asp.plsql.'||G_PKG_NAME||'.';

G_ESC_SERVICE_REQUEST_EVENT CONSTANT VARCHAR2(240) :=
      'oracle.apps.jtf.cac.escalation.createEscalation';


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
--  Procedure: Initiate_Alerts
--   Generic Subscription Function for Sales Alerts Related Business Events.
--   This function will be called by the BES if a Service Request is Escalated.
--   This could be used by the end-customer for extending the Alerting System.
--
--------------------------------------------------------------------------------

FUNCTION Initiate_Alerts(
  P_subscription_guid  in RAW,
  P_event              in out NOCOPY WF_EVENT_T) RETURN VARCHAR2
IS

  l_event_key          number;
  l_event_name         varchar2(240);
  l_item_key           varchar2(240);
  l_incident_id        number;
  l_api_name varchar2(100);

  myList  wf_parameter_list_t;
  pos     number := 1;
  pName   VARCHAR2(30);
  pValue  VARCHAR2(2000);

  save_threshold number;
  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

  CURSOR get_ref_sr(p_task_id in number) is
         SELECT r.object_id,
                t.escalation_level
           FROM jtf_tasks_vl t,
                jtf_task_references_vl r
          WHERE t.task_id = p_task_id
            and t.task_id = r.task_id
            and r.object_type_code = 'SR'
            and r.reference_code = 'ESC'
            and r.object_id IS NOT NULL;

BEGIN
  l_api_name := 'Initiate_Alerts';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  save_threshold :=  wf_engine.threshold;
  l_event_name := p_event.getEventName();
  -- Detect the event raised and determine necessary parameters depending on the event.

  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_name='||l_event_name);
  end if;

  If(l_event_name = G_ESC_SERVICE_REQUEST_EVENT) Then
    l_event_key := p_event.GetValueForParameter('TASK_ID');
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_key='||l_event_key);
    end if;
    FOR get_esc_details_rec IN get_ref_sr(l_event_key)
    LOOP
      l_incident_id := get_esc_details_rec.object_id ;
      -- Construct the unique item key
      SELECT l_incident_id ||'-'|| to_char(asp_wf_alerts_s.nextval) INTO l_item_key FROM DUAL;

      -- Start the ASP Alert Manager Process (ASP_ALERT_PROCESS) with the following info:
      wf_engine.threshold := -1;
      wf_engine.CreateProcess( itemtype => 'ASPALERT', itemkey => l_item_key, process => 'ASP_ALERT_PROCESS',user_key=>l_item_key);
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key='||l_item_key);
      end if;

      wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_NAME', 'SVCREQUEST_ESCALATED_ALERT');
      wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_CODE', 'SERVICE_REQUEST');
      wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_ID', l_incident_id);
      wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_TASK_ID', l_event_key);
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before wf_engine.StartProcess');
      end if;
      wf_engine.StartProcess(itemtype => 'ASPALERT', itemkey => l_item_key);
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After wf_engine.StartProcess');
      end if;
      commit;

    END LOOP;
  ELSE
    --Custom Events
    -- Construct the unique item key
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Subscription - CUSTOM Event');
  end if;
    SELECT to_char(asp_wf_alerts_s.nextval) INTO l_item_key FROM DUAL;

    -- Start the ASP Alert Manager Process (ASP_ALERT_PROCESS) with the following info:
    wf_engine.threshold := -1;
    wf_engine.CreateProcess( itemtype => 'ASPALERT', itemkey => l_item_key, process => 'ASP_ALERT_PROCESS',user_key=>l_item_key);
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_item_key='||l_item_key);
      end if;

    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_NAME', l_event_name);
    wf_engine.SetItemAttrText('ASPALERT', l_item_key, 'ALERT_SOURCE_OBJECT_CODE', 'CUSTOM');

    myList := P_event.getParameterList();
    if (myList is not null) then
      pos := myList.LAST;
      while(pos is not null) loop
       begin
        pName  := myList(pos).getName();
        pValue := myList(pos).getValue();
        pName  := upper(pName);
        pos := myList.PRIOR(pos);
        wf_engine.SetItemAttrText('ASPALERT', l_item_key, pName, pValue);
       exception when others then
        null;
       end;
      end loop;
    end if;

    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before wf_engine.StartProcess');
    end if;
    wf_engine.StartProcess(itemtype => 'ASPALERT', itemkey => l_item_key);
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After wf_engine.StartProcess');
    end if;
    commit;

  END IF;
  wf_engine.threshold := save_threshold;
  RETURN 'SUCCESS';

EXCEPTION
  WHEN others THEN
      WF_CORE.CONTEXT(G_PKG_NAME, l_api_name, l_event_name, p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'WARNING');
      wf_engine.threshold := save_threshold;
      if(l_debug_exception >= l_debug_runtime) then
        fnd_log.string(l_debug_exception, G_MODULE||l_api_name,
                       'Leaving '||G_PKG_NAME||'.'||l_api_name||'with exceptions' ||
                        to_char(SQLCODE)||':'||substr(SQLERRM,1,500));
      end if;
      return 'WARNING';

END Initiate_Alerts;

End ASP_ALERTS_SUBS;

/
