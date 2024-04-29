--------------------------------------------------------
--  DDL for Package Body ASP_SVCCONT_CONTENT_PROVIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_SVCCONT_CONTENT_PROVIDER" as
/* $Header: aspasccb.pls 120.2 2005/12/13 11:40 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_SVCCONT_CONTENT_PROVIDER
---------------------------------------------------------------------------
-- Description:
--   Provides content for the Service Contracts Alert.
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
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_SVCCONT_CONTENT_PROVIDER';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspasccb.pls';
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
--   Provides content for the Service Contracts Alert.
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
  l_contract_header_id number;

  l_customer_id number;
  l_customer_name varchar2(360);
  l_contract_number varchar2(360);
  l_expiration_date date;

  l_email_content varchar2(240);

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;


  CURSOR get_contract_details(c_contract_header_id in number) is
      SELECT HZP.party_id customer_id
            ,HZP.party_name customer_name
            ,CHRB.contract_number || DECODE(CHRB.contract_number_modifier, NULL,NULL,'-'|| CHRB.contract_number_modifier) contract_number
            ,CHRB.END_DATE expiration_date
      FROM  okc_k_headers_all_b CHRB
           ,oks_k_headers_b KHRB
           ,okc_subclasses_v SCSV
           ,okc_k_party_roles_b CPL
           ,hz_parties HZP
      WHERE CHRB.id = c_contract_header_id --<contract header id>
      AND   CHRB.id = CPL.dnz_chr_id
      AND   SCSV.code = CHRB.scs_code
      AND   SCSV.cls_code = 'SERVICE'
      AND   CHRB.id = KHRB.chr_id
      AND   CPL.cle_id IS NULL
      AND   CPL.rle_code in('CUSTOMER','SUBSCRIBER')
      AND   CPL.jtot_object1_code = 'OKX_PARTY'
      AND   CPL.object1_id1 = HZP.party_id
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
                                                aname =>'ALERT_NAME');--SVCCONTRACT_PRE_EXPIRE_ALERT

    l_contract_header_id := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_ID');

    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_entity '||l_event_entity);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_alert_code '||l_alert_code);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_contract_header_id '||l_contract_header_id);
    end if;

    If l_event_entity = 'SERVICE_CONTRACT' Then
      ----------
      l_sms_text := '';
      l_email_sub := '';
      --ASP_WF_SVCCON_MSG_RN ASP_CONTRACT_WFRN
      l_email_content := 'JSP:/OA_HTML/OA.jsp?OAFunc=ASP_WF_SVCCON_MSG_RN' ||
                         '&' || 'ContractId=-'||'&'|| 'MSG_CONTRACTID-';

      --***SMS Content
      BEGIN
        OPEN get_contract_details(l_contract_header_id);
        FETCH get_contract_details
            INTO l_customer_id,
                 l_customer_name,
                 l_contract_number,
                 l_expiration_date;
        IF (get_contract_details%NOTFOUND) THEN
          l_sms_text := 'INVALID SERVICE CONTRACT!';
          l_email_sub := 'INVALID SERVICE CONTRACT!';
        END IF;
        CLOSE get_contract_details;

      EXCEPTION
      WHEN OTHERS THEN
        l_sms_text := 'INVALID SERVICE CONTRACT!';
        l_email_sub := 'INVALID SERVICE CONTRACT!';
      END;

      --Message ASP_SVCCON_SMS_TEXT - Non-renewed contract #<CONTRACTNUM> for customer '<CUSTNAME >' expires on <EXPDATE>.
      fnd_message.set_name('ASP', 'ASP_SVCCON_SMS_TEXT');
      fnd_message.set_token('CONTRACTNUM', l_contract_number);
      fnd_message.set_token('CUSTNAME', l_customer_name);
      fnd_message.set_token('EXPDATE', to_char( l_expiration_date, 'DD-Mon-YYYY HH24:MI:SS'));
      l_sms_text := fnd_message.get;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'SMS_TEXT', l_sms_text);
      --***Done SMS Content
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'SMS_TEXT '||l_sms_text);
    end if;

      --***EMAIL Content
      --Message ASP_SVCCON_EMAIL_SUB - Contract #<CONTRACTNUM> for customer '<CUSTNAME>' expires shortly

      fnd_message.set_name('ASP', 'ASP_SVCCON_EMAIL_SUB');
      fnd_message.set_token('CONTRACTNUM', l_contract_number);
      fnd_message.set_token('CUSTNAME', l_customer_name);
      l_email_sub := fnd_message.get;

      wf_engine.SetItemAttrText(itemtype, itemkey, 'CONTRACTID', l_contract_header_id);
      --WF_Attr CONTRACTID => Msg_Attr MSG_CONTRACTID

      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_SUB_TEXT', l_email_sub);
      --WF_Attr EMAIL_SUB_TEXT => Msg_Attr MSG_SUBJECT_EMAIL
      wf_engine.SetItemAttrText(itemtype, itemkey, 'EMAIL_CONTENT', l_email_content);
      --WF_Attr EMAIL_CONTENT => Msg_Attr MSG_BODY_EMAIL
      --***Done EMAIL Content
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'CONTRACTID '||l_contract_header_id);
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

End ASP_SVCCONT_CONTENT_PROVIDER;

/
