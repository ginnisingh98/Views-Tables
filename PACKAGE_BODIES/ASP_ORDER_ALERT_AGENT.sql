--------------------------------------------------------
--  DDL for Package Body ASP_ORDER_ALERT_AGENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ORDER_ALERT_AGENT" as
/* $Header: aspaorab.pls 120.5 2005/09/28 13:45 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ORDER_ALERT_AGENT
---------------------------------------------------------------------------
-- Description:
--      Package contains methods for evaluating the alert condition and
--      finds the subscribers for various alerts.
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
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ORDER_ALERT_AGENT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspaorab.pls';
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
-- Procedure: Evaluate_Alerts
--    Finds all the subscribers of this alert for SMS and EMAIL Channels.
--
--------------------------------------------------------------------------------

PROCEDURE Evaluate_Alerts(
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
  l_subscriber_list ASP_ALERTS_PUB.SUBSCRIBER_TBL_TYPE;
  l_return_status          VARCHAR2(30);
  l_msg_count              NUMBER ;
  l_msg_data               VARCHAR2(2000) ;
  l_sms_users varchar2(32767);
  l_email_users varchar2(32767);
  l_sms_fnd_users varchar2(32767);
  l_email_fnd_users varchar2(32767);
  l_sms_users_count  NUMBER ;
  l_email_users_count  NUMBER ;
  l_blanket_header_id number;
  l_customer_id number;

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

  CURSOR get_customer_id(c_blanket_header_id in number) is
    SELECT party.party_id as customer_id
    FROM oe_blanket_headers_all oobha,
         hz_parties party,
         hz_cust_accounts_all cust_acct
    WHERE oobha.header_id = c_blanket_header_id
      and oobha.sold_to_org_id = cust_acct.cust_account_id(+)
      and cust_acct.party_id = party.party_id(+)
      and oobha.sales_document_type_code = 'B'
      and rownum < 2;

BEGIN
  l_api_name := 'Evaluate_Alerts';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  l_sms_users_count := 0;
  l_email_users_count := 0;

  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  If(funcmode = 'RUN') Then
    l_event_entity := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_CODE');
    l_alert_code := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_NAME');
    l_blanket_header_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_ID');

    BEGIN
      OPEN get_customer_id(l_blanket_header_id);
      FETCH get_customer_id
          INTO l_customer_id;
      IF (get_customer_id%NOTFOUND) THEN
        l_customer_id := -1;
      END IF;
      CLOSE get_customer_id;

    EXCEPTION
    WHEN OTHERS THEN
      l_customer_id := -1;
    END;


    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_entity '||l_event_entity);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_alert_code '||l_alert_code);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_blanket_header_id '||l_blanket_header_id);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_customer_id '||l_customer_id);

      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Calling ASP_ALERTS_PUB.Get_Matching_Subscriptions');
    end if;


    If l_event_entity = 'ORDER' Then
      ASP_ALERTS_PUB.Get_Matching_Subscriptions(
        p_api_version_number  => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_alert_code          => l_alert_code,
        p_customer_id         => l_customer_id,
        x_subscriber_list     => l_subscriber_list,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data
      );
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_return_status '||l_return_status);
      end if;

      IF l_return_status <> 'S' THEN
         --Set debug messages
         wf_engine.SetItemAttrText(itemtype, itemkey, 'FOUND_SUBS', 'NO');
         resultout := 'COMPLETE:SUCCESS';
         return;
      END IF;

      IF l_subscriber_list.count > 0 THEN
      BEGIN
        For i in l_subscriber_list.first..l_subscriber_list.last
        loop
          if(l_subscriber_list(i).DELIVERY_CHANNEL = 'SMS') then
            l_sms_users_count := l_sms_users_count+1;
            if(l_sms_users_count = 1) then
              l_sms_users := l_sms_users || l_subscriber_list(i).SUBSCRIBER_NAME;
              l_sms_fnd_users := l_sms_fnd_users || l_subscriber_list(i).USER_ID;
            else
              l_sms_users := l_sms_users || ',' || l_subscriber_list(i).SUBSCRIBER_NAME;
              l_sms_fnd_users := l_sms_fnd_users || ',' || l_subscriber_list(i).USER_ID;
            end if;
          elsif(l_subscriber_list(i).DELIVERY_CHANNEL = 'EMAIL') then
            l_email_users_count := l_email_users_count+1;
            if(l_email_users_count = 1) then
              l_email_users := l_email_users || l_subscriber_list(i).SUBSCRIBER_NAME;
              l_email_fnd_users := l_email_fnd_users || l_subscriber_list(i).USER_ID;
            else
              l_email_users := l_email_users || ',' || l_subscriber_list(i).SUBSCRIBER_NAME;
              l_email_fnd_users := l_email_fnd_users || ',' || l_subscriber_list(i).USER_ID;
            end if;
          else
            null;
          end if;
        end loop;
      exception
        When Others then
        wf_engine.SetItemAttrText(itemtype, itemkey, 'FOUND_SUBS', 'NO');
      end;
      if(l_sms_users_count > 0) then
        wf_engine.SetItemAttrText(itemtype, itemkey, 'FOUND_SMS_SUBS', 'YES');
        if(l_debug_procedure >= l_debug_runtime) then
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'FOUND_SMS_SUBS '||'YES');
        end if;
      end if;
      if(l_email_users_count > 0) then
        wf_engine.SetItemAttrText(itemtype, itemkey, 'FOUND_EMAIL_SUBS', 'YES');
        if(l_debug_procedure >= l_debug_runtime) then
          fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'FOUND_EMAIL_SUBS '||'YES');
        end if;
      end if;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_USERS', l_sms_users);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_USERS', l_email_users);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_FND_USERS', l_sms_fnd_users);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_FND_USERS', l_email_fnd_users);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'FOUND_SUBS', 'YES');

      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_sms_users_count '||l_sms_users_count);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_email_users_count '||l_email_users_count);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'SMS_USERS '||l_sms_users);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'EMAIL_USERS '||l_email_users);
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'FOUND_SUBS '||'YES');
      end if;

      ELSE
         wf_engine.SetItemAttrText(itemtype, itemkey, 'FOUND_SUBS', 'NO');
      END IF;--l_subscriber_list.count > 0

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

END Evaluate_Alerts;

End ASP_ORDER_ALERT_AGENT;

/
