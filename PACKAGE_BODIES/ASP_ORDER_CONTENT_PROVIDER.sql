--------------------------------------------------------
--  DDL for Package Body ASP_ORDER_CONTENT_PROVIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ORDER_CONTENT_PROVIDER" as
/* $Header: aspaorcb.pls 120.2 2005/09/28 13:45 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ORDER_CONTENT_PROVIDER
---------------------------------------------------------------------------
-- Description:
--   Provides content for the Sales Agreement Alert
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
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ORDER_CONTENT_PROVIDER';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspaorcb.pls';
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
--   Provides content for the Sales Agreement Alert
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
  l_blanket_header_id number;

  l_customer_id number;
  l_customer_name varchar2(360);
  l_blanket_number number;
  l_expiration_date date;

  l_email_content varchar2(240);

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;


  CURSOR get_bsa_details(c_blanket_header_id in number) is
    SELECT party.party_id as customer_id,
           party.party_name as customer_name,
           oobha.order_number as blanket_number,
           oobhe.end_date_active as expiration_date
    FROM oe_blanket_headers_all oobha,
         oe_blanket_headers_ext oobhe,
         hz_parties party,
         hz_cust_accounts_all cust_acct
    WHERE oobha.order_number = oobhe.order_number
      and oobha.sold_to_org_id = cust_acct.cust_account_id(+)
      and cust_acct.party_id = party.party_id(+)
      and oobha.sales_document_type_code = 'B'
      --and oobha.order_number = c_blanket_number -- < Blanket number> <not needed>
      and oobha.header_id = c_blanket_header_id
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
                                                aname =>'ALERT_NAME');--BSA_PRE_EXPIRE_ALERT

    l_blanket_header_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_ID');

    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_entity '||l_event_entity);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_alert_code '||l_alert_code);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_blanket_header_id '||l_blanket_header_id);
    end if;

    /*
    Only Blanket Header Id is passed and Blanket Number is obtained from the query.
    l_blanket_number := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_BLANKET_NUMBER');
    */

    If l_event_entity = 'ORDER' Then
      ----------
      l_sms_text := '';
      l_email_sub := '';
      --ASP_WF_ORDER_MSG_RN ASP_BSA_WFRN
      l_email_content := 'JSP:/OA_HTML/OA.jsp?OAFunc=ASP_WF_ORDER_MSG_RN' ||
                         '&' || 'BlanketHeaderId=-'||'&'|| 'MSG_BLANKETHDRID-';

      --***SMS Content
      BEGIN
        OPEN get_bsa_details(l_blanket_header_id);
        FETCH get_bsa_details
            INTO l_customer_id,
                 l_customer_name,
                 l_blanket_number,
                 l_expiration_date;
        IF (get_bsa_details%NOTFOUND) THEN
          l_sms_text := 'INVALID BSA!';
          l_email_sub := 'INVALID BSA!';
        END IF;
        CLOSE get_bsa_details;

      EXCEPTION
      WHEN OTHERS THEN
        l_sms_text := 'INVALID BSA!';
        l_email_sub := 'INVALID BSA!';
      END;

      --Message ASP_ORDER_SMS_TEXT - Blanket Sales Agreement #<BSANUM> for customer '<CUSTNAME>' expires on <EXPDATE>.
      fnd_message.set_name('ASP', 'ASP_ORDER_SMS_TEXT');
      fnd_message.set_token('BSANUM', to_char(l_blanket_number));
      fnd_message.set_token('CUSTNAME', l_customer_name);
      fnd_message.set_token('EXPDATE', to_char( l_expiration_date, 'DD-Mon-YYYY HH24:MI:SS'));
      l_sms_text := fnd_message.get;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_TEXT', l_sms_text);
      --***Done SMS Content
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'SMS_TEXT '||l_sms_text);
      end if;

      --***EMAIL Content
      --Message ASP_ORDER_EMAIL_SUB - Blanket Sales Agreement #<BSANUM> for customer '<CUSTNAME>' expires shortly

      fnd_message.set_name('ASP', 'ASP_ORDER_EMAIL_SUB');
      fnd_message.set_token('BSANUM', l_blanket_number);
      fnd_message.set_token('CUSTNAME', l_customer_name);
      l_email_sub := fnd_message.get;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'BLANKETHDRID', l_blanket_header_id);
      --WF_Attr BLANKETHDRID => Msg_Attr MSG_BLANKETHDRID

      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_SUB_TEXT', l_email_sub);
      --WF_Attr EMAIL_SUB_TEXT => Msg_Attr MSG_SUBJECT_EMAIL
      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_CONTENT', l_email_content);
      --WF_Attr EMAIL_CONTENT => Msg_Attr MSG_BODY_EMAIL
      --***Done EMAIL Content
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'BLANKETHDRID '||l_blanket_header_id);
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

End ASP_ORDER_CONTENT_PROVIDER;

/
