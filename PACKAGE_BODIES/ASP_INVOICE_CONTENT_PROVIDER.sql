--------------------------------------------------------
--  DDL for Package Body ASP_INVOICE_CONTENT_PROVIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_INVOICE_CONTENT_PROVIDER" as
/* $Header: aspaincb.pls 120.4 2005/09/28 13:45 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_INVOICE_CONTENT_PROVIDER
---------------------------------------------------------------------------
-- Description:
--   Provides content for the past due invoices.
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
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_INVOICE_CONTENT_PROVIDER';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspaincb.pls';
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
--   Provides content for the past due invoices.
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
  l_delinquency_id number;

  l_customer_id number;
  l_customer_name varchar2(360);
  l_transaction_number varchar2(360);
  l_due_date date;

  l_email_content varchar2(240);

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;


  CURSOR get_invoice_details(c_delinquency_id in number) is
    SELECT
      PARTY.PARTY_ID as customer_id,
      PARTY.PARTY_NAME as customer_name,
      CT.TRX_NUMBER as transaction_number,
      PS.DUE_DATE
    FROM
       AR_PAYMENT_SCHEDULES_ALL PS
      ,HZ_CUST_ACCOUNTS_ALL CUST_ACCT
      ,HZ_PARTIES PARTY
      ,IEX_DEL_ALERTS_PUB_V DEL -- IEX_DELINQUENCIES.STATUS in ('DELINQUENT', 'PREDELINQUENT')
      ,RA_CUSTOMER_TRX_ALL CT
    WHERE
        PS.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
    AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
    AND PS.CUSTOMER_TRX_ID = DEL.TRANSACTION_ID
    AND PS.CUSTOMER_TRX_ID = CT.CUSTOMER_TRX_ID
    AND PS.PAYMENT_SCHEDULE_ID = DEL.PAYMENT_SCHEDULE_ID
    AND DEL.DELINQUENCY_ID = c_delinquency_id
    AND rownum < 2;

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
                                                aname =>'ALERT_NAME');--INVOICE_OVERDUE_ALERT

    l_delinquency_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_ID');

    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_entity '||l_event_entity);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_alert_code '||l_alert_code);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_delinquency_id '||l_delinquency_id);
    end if;


    If l_event_entity = 'INVOICE' Then
      ----------
      l_sms_text := '';
      l_email_sub := '';
      --ASP_WF_INVOICE_MSG_RN ASP_INVOICE_WFRN
      l_email_content := 'JSP:/OA_HTML/OA.jsp?OAFunc=ASP_WF_INVOICE_MSG_RN' ||
                         '&' || 'DelinquencyId=-'||'&'|| 'MSG_DELINQUENCYID-';

      --***SMS Content
      BEGIN
        OPEN get_invoice_details(l_delinquency_id);
        FETCH get_invoice_details
            INTO l_customer_id,
                 l_customer_name,
                 l_transaction_number,
                 l_due_date;
        IF (get_invoice_details%NOTFOUND) THEN
          l_sms_text := 'INVALID DELINQUENT INVOICE!';
          l_email_sub := 'INVALID DELINQUENT INVOICE!';
        END IF;
        CLOSE get_invoice_details;

      EXCEPTION
      WHEN OTHERS THEN
        l_sms_text := 'INVALID DELINQUENT INVOICE!';
        l_email_sub := 'INVALID DELINQUENT INVOICE!';
      END;

      --Message ASP_INVOICE_SMS_TEXT - Customer '<CUSTNAME>' has overdue invoice. Transaction <TXNNUM > is past due date <DUEDATE>
      fnd_message.set_name('ASP', 'ASP_INVOICE_SMS_TEXT');
      fnd_message.set_token('CUSTNAME', l_customer_name);
      fnd_message.set_token('TXNNUM', l_transaction_number);
      fnd_message.set_token('DUEDATE', to_char( l_due_date, 'DD-Mon-YYYY HH24:MI:SS'));
      l_sms_text := fnd_message.get;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_TEXT', l_sms_text);
      --***Done SMS Content
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'SMS_TEXT '||l_sms_text);
      end if;

      --***EMAIL Content
      --Message ASP_INVOICE_EMAIL_SUB - Overdue invoice #<TXNNUM> for <CUSTNAME>

      fnd_message.set_name('ASP', 'ASP_INVOICE_EMAIL_SUB');
      fnd_message.set_token('TXNNUM', l_transaction_number);
      fnd_message.set_token('CUSTNAME', l_customer_name);
      l_email_sub := fnd_message.get;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'DELINQUENCYID', l_delinquency_id);
      --WF_Attr DELINQUENCYID => Msg_Attr MSG_DELINQUENCYID

      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_SUB_TEXT', l_email_sub);
      --WF_Attr EMAIL_SUB_TEXT => Msg_Attr MSG_SUBJECT_EMAIL
      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_CONTENT', l_email_content);
      --WF_Attr EMAIL_CONTENT => Msg_Attr MSG_BODY_EMAIL
      --***Done EMAIL Content
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'DELINQUENCYID '||l_delinquency_id);
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

End ASP_INVOICE_CONTENT_PROVIDER;

/
