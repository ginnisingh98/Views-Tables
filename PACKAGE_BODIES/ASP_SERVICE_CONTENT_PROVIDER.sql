--------------------------------------------------------
--  DDL for Package Body ASP_SERVICE_CONTENT_PROVIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_SERVICE_CONTENT_PROVIDER" as
/* $Header: aspasvcb.pls 120.1 2005/09/06 14:45 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_SERVICE_CONTENT_PROVIDER
---------------------------------------------------------------------------
-- Description:
--   Provides content for the Service Alert.
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
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_SERVICE_CONTENT_PROVIDER';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspasvcb.pls';
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
-- Procedure: Create_Content
--   Provides content for the Service Alert.
--
--------------------------------------------------------------------------------

PROCEDURE Create_Content(
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
  l_alert_code varchar2(30);
  l_sms_text varchar2(32767);
  l_email_sub varchar2(32767);
  l_incident_id number;
  l_task_id number;

  l_incident_number varchar2(240);
  l_customer_id number;
  l_customer_name varchar2(360);
  l_sr_owner varchar2(360);
  l_sr_status varchar2(30);
  l_esc_level varchar2(30);
  l_email_content varchar2(240);

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;


  CURSOR get_sr_details(c_incident_id in number, c_task_id in number) is
    SELECT sr.incident_number,
           p.party_id as customer_id,
           decode(sr.caller_type, 'PERSON', p.person_pre_name_adjunct || p.party_name,
           p.party_name) as customer_name,
           rs.resource_name as sr_owner,
           sr_sts.name as sr_status,
           lk_esc.meaning as esc_level
    FROM cs_incidents_all_b sr,
         hz_parties p,
         jtf_rs_resource_extns_vl rs,
         cs_incident_statuses_vl sr_sts,
         jtf_tasks_vl t, jtf_task_references_vl r,fnd_lookups lk_esc
    WHERE sr.incident_id = c_incident_id
      and sr.customer_id = p.party_id
      and sr.incident_owner_id = rs.resource_id (+)
      and sr.incident_status_id = sr_sts.incident_status_id
      and sr_sts.incident_subtype = 'INC'
      and t.task_id = r.task_id
      and r.reference_code = 'ESC'
      and r.object_type_code = 'SR'
      and r.object_id = sr.incident_id
      and lk_esc.lookup_type = 'JTF_TASK_ESC_LEVEL'
      and lk_esc.lookup_code = t.escalation_level
      and t.task_id = c_task_id
      and rownum < 2;

BEGIN
  l_api_name := 'Create_Content';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  If(funcmode = 'RUN') Then
    l_event_entity := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_CODE');

    l_alert_code := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_NAME');--SVCREQUEST_ESCALATED_ALERT

    l_incident_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_ID');

    l_task_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_TASK_ID');

    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_entity '||l_event_entity);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_alert_code '||l_alert_code);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_incident_id '||l_incident_id);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_task_id '||l_task_id);
    end if;

    If l_event_entity = 'SERVICE_REQUEST' Then
      ----------
      l_sms_text := '';
      l_email_sub := '';
      --ASP_WF_SERVICE_MSG_RN ASP_SERVICE_WFRN
      l_email_content := 'JSP:/OA_HTML/OA.jsp?OAFunc=ASP_WF_SERVICE_MSG_RN' ||
                         '&' || 'IncidentId=-'||'&'|| 'MSG_INCIDENTID-'||'&'||'TaskId=-'||'&'||'MSG_TASKID-';

      --***SMS Content
      BEGIN
        OPEN get_sr_details(l_incident_id,l_task_id);
        FETCH get_sr_details
            INTO l_incident_number,
                 l_customer_id,
                 l_customer_name,
                 l_sr_owner,
                 l_sr_status,
                 l_esc_level;
        IF (get_sr_details%NOTFOUND) THEN
          l_sms_text := 'INVALID SERVICE REQUEST!';
          l_email_sub := 'INVALID SERVICE REQUEST!';
        END IF;
        CLOSE get_sr_details;

      EXCEPTION
      WHEN OTHERS THEN
        l_sms_text := 'INVALID SERVICE REQUEST!';
        l_email_sub := 'INVALID SERVICE REQUEST!';
      END;

      --Message ASP_SERVICE_SMS_TEXT - Service Request - # <SRNUM> for customer '<CUSTNAME>' has been escalated. Currently assigned to '<REPNAME>' with status '<STATUS>' and escalation level: '<ESCLEVEL>'.
      fnd_message.set_name('ASP', 'ASP_SERVICE_SMS_TEXT');
      fnd_message.set_token('SRNUM', l_incident_number);
      fnd_message.set_token('CUSTNAME', l_customer_name);
      fnd_message.set_token('REPNAME', l_sr_owner);
      fnd_message.set_token('STATUS', l_sr_status);
      fnd_message.set_token('ESCLEVEL', l_esc_level);
      --fnd_message.set_token('CUSTID', to_char(l_customer_id));
      l_sms_text := fnd_message.get;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_TEXT', l_sms_text);

      --***Done SMS Content

    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'SMS_TEXT '||l_sms_text);
    end if;

      --***EMAIL Content
      --Message ASP_SERVICE_EMAIL_SUB - Service Request #<SRNUM> for customer '<CUSTNAME>' escalated.

      fnd_message.set_name('ASP', 'ASP_SERVICE_EMAIL_SUB');
      fnd_message.set_token('SRNUM', l_incident_number);
      fnd_message.set_token('CUSTNAME', l_customer_name);
      l_email_sub := fnd_message.get;



      wf_engine.SetItemAttrText(itemtype, itemkey, 'INCIDENTID', l_incident_id);
      --WF_Attr INCIDENTID => Msg_Attr MSG_INCIDENTID
      wf_engine.SetItemAttrText(itemtype, itemkey, 'TASKID', l_task_id);
      --WF_Attr TASKID => Msg_Attr MSG_TASKID

      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_SUB_TEXT', l_email_sub);
      --WF_Attr EMAIL_SUB_TEXT => Msg_Attr MSG_SUBJECT_EMAIL
      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_CONTENT', l_email_content);
      --WF_Attr EMAIL_CONTENT => Msg_Attr MSG_BODY_EMAIL
      --***Done EMAIL Content
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'INCIDENTID '||l_incident_id);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'TASKID '||l_task_id);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'EMAIL_SUB_TEXT '||l_email_sub);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'EMAIL_CONTENT '||l_email_content);
    end if;

      ----------
      resultout := 'COMPLETE:SUCCESS';
      return;
    Else
      resultout := 'COMPLETE:NULL';
      return;
    End If;
  End If;
  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := '';
  return;


EXCEPTION
  When no_data_found Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':NO_DATA_FOUND:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

  When others Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':OTHERS:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

END Create_Content;

End ASP_SERVICE_CONTENT_PROVIDER;

/
