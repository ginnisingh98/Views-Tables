--------------------------------------------------------
--  DDL for Package Body ASP_DELIVERY_AGENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_DELIVERY_AGENT" as
/* $Header: aspdlvab.pls 120.1 2005/09/06 14:45 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_DELIVERY_AGENT
---------------------------------------------------------------------------
-- Description:
--   Responsible for the creation of adhoc role and Delivery.
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
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_DELIVERY_AGENT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspdlvab.pls';
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
-- Procedure: Deliver
--   Responsible for the creation of adhoc role and Delivery.
--
--------------------------------------------------------------------------------

PROCEDURE Deliver(
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
  l_sms_users varchar2(32767);
  l_email_users varchar2(32767);
  l_sms_adhocrole varchar2(320);
  l_email_adhocrole varchar2(320);

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

  l_event_entity varchar2(100);
  l_alert_code varchar2(30);
  l_incident_id number;
  l_task_id number;

BEGIN
  l_api_name := 'Deliver';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  If(funcmode = 'RUN') Then
    l_sms_users := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'SMS_USERS');

    l_email_users := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'EMAIL_USERS');

    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_sms_users '||l_sms_users);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_email_users '||l_email_users);
    end if;

    BEGIN
      l_sms_adhocrole := 'ASPSMS_' || itemkey;
      l_email_adhocrole := 'ASPEMAIL_' || itemkey;
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before wf_directory.CreateAdHocRole ');
      end if;

      wf_directory.CreateAdHocRole(role_name         => l_sms_adhocrole,
                                   role_display_name => l_sms_adhocrole,
                                   expiration_date   => sysdate+5,
                                   role_users        => l_sms_users);

      wf_directory.CreateAdHocRole(role_name         => l_email_adhocrole,
                                   role_display_name => l_email_adhocrole,
                                   expiration_date   => sysdate+5,
                                   role_users        => l_email_users);
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After wf_directory.CreateAdHocRole ');
      end if;

    EXCEPTION
    WHEN OTHERS THEN
      wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
      l_debug_msg := l_qualified_api_name||':OTHERS:CreateAdHocRole'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
      wf_core.token('ORA_ERROR',l_debug_msg);
      if(l_debug_exception >= l_debug_runtime) then
        fnd_log.string(l_debug_exception, G_MODULE||l_api_name, l_debug_msg);
      end if;
      wf_core.raise('WF_ORA');
    END;

--/*
    wf_engine.SetItemAttrText(itemtype, itemkey, 'NOTIF_FROM_ROLE', 'SYSADMIN');
    wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_SEND_TO', l_sms_adhocrole);
    wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_SEND_TO', l_email_adhocrole);
    wf_engine.SetItemAttrText(itemtype, itemkey, 'DELIVERY_CHANNEL', 'CHANNEL_SMS'); --Hardcoded
--*/
/*
    --Set all the attributes for the "Message Delivery Process"
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before wf_engine.CreateProcess ALERT_DELIVERY');
    end if;
    wf_engine.CreateProcess( itemtype => 'ASPALERT', itemkey => itemkey, process => 'ALERT_DELIVERY');



    l_event_entity := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_CODE');

    l_alert_code := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_NAME');

    l_incident_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_ID');

    begin
     l_task_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_TASK_ID');
    exception
    when others then
     l_task_id := -1;
    end;
    wf_engine.SetItemAttrText('ASPALERT', itemkey, 'ALERT_NAME', l_alert_code);
    wf_engine.SetItemAttrText('ASPALERT', itemkey, 'ALERT_SOURCE_OBJECT_CODE', l_event_entity);
    wf_engine.SetItemAttrText('ASPALERT', itemkey, 'ALERT_SOURCE_OBJECT_ID', l_incident_id);
    wf_engine.SetItemAttrText('ASPALERT', itemkey, 'ALERT_SOURCE_TASK_ID', l_task_id);

    wf_engine.SetItemAttrText(itemtype, itemkey, 'NOTIF_FROM_ROLE', 'SYSADMIN');
    wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_SEND_TO', l_sms_adhocrole);
    wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_SEND_TO', l_email_adhocrole);
    wf_engine.SetItemAttrText(itemtype, itemkey, 'DELIVERY_CHANNEL', 'CHANNEL_EMAIL');


    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Before wf_engine.StartProcess ALERT_DELIVERY');
    end if;
    wf_engine.StartProcess(itemtype => 'ASPALERT', itemkey => itemkey);
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'After wf_engine.StartProcess ALERT_DELIVERY');
    end if;
*/


    resultout := 'COMPLETE:SUCCESS';
    return;
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
      if(l_debug_exception >= l_debug_runtime) then
        fnd_log.string(l_debug_exception, G_MODULE||l_api_name, l_debug_msg);
      end if;
    wf_core.raise('WF_ORA');

  When others Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':OTHERS:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
      if(l_debug_exception >= l_debug_runtime) then
        fnd_log.string(l_debug_exception, G_MODULE||l_api_name, l_debug_msg);
      end if;
    wf_core.raise('WF_ORA');

END Deliver;

End ASP_DELIVERY_AGENT;

/
