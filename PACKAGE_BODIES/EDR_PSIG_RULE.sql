--------------------------------------------------------
--  DDL for Package Body EDR_PSIG_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_PSIG_RULE" AS
/* $Header: EDRRULEB.pls 120.22.12010000.2 2008/12/09 20:18:51 srpuri ship $ */

/* Global varaibles */

G_ENTITY_NAME constant varchar2(10) := 'ERECORD';
G_TEMP_ENTITY_NAME constant varchar2(15) := 'TEMPERECORD';
G_PUBLISH_FLAG_N constant varchar2(1) := 'N';
G_PUBLISH_FLAG_Y constant varchar2(1) := 'Y';
G_SECURITY_OFF constant NUMBER := 4;
G_SECURITY_ON constant NUMBER := 1;

L_EVENT_NAME VARCHAR2(240);
L_EVENT_KEY VARCHAR2(240);

------------------------------------------------------------------------------
--Bug 4577122: Start

procedure validate_voting_regime
(p_approver_list IN EDR_UTILITIES.approvers_Table,
 x_valid_regime OUT NOCOPY VARCHAR2,
 x_voting_regime OUT NOCOPY VARCHAR2)
as
 G_UNVIABLE_NUMBER constant number := -1984;

 l_group_id number;
 l_action_type_id number;
 l_action_type_voting_regime varchar2(1);

 l_group_id_prev number := G_UNVIABLE_NUMBER;
 l_action_type_id_prev number := G_UNVIABLE_NUMBER;
 l_firstvoter_found varchar2(1) := 'N';

 l_multiple_group_id varchar2(1) := 'N';
 l_multiple_action_type_id varchar2(1) := 'N';
 l_multiple_voting_regime varchar2(1) := 'N';

 i number;
begin
  for i in 1..p_approver_list.count loop
    --get the voting regime of the action id
     l_action_type_voting_regime :=
       ame_engine.GETACTIONTYPEVOTINGREGIME
       (ACTIONTYPEIDIN => p_approver_list(i).action_type_id);

    l_group_id := p_approver_list(i).group_or_chain_id;
    l_action_type_id := p_approver_list(i).action_type_id;
    l_action_type_voting_regime := ame_engine.GETACTIONTYPEVOTINGREGIME
                                   (ACTIONTYPEIDIN => l_action_type_id);

    if (l_group_id_prev <>  G_UNVIABLE_NUMBER and
        l_group_id_prev <> l_group_id and
        l_multiple_group_id <> 'Y') then
      l_multiple_group_id := 'Y';
    else
      l_group_id_prev := l_group_id;
    end if;

    if (l_action_type_id_prev <>  G_UNVIABLE_NUMBER and
        l_action_type_id_prev <> l_action_type_id and
        l_multiple_action_type_id <> 'Y') then
      l_multiple_action_type_id := 'Y';
    else
      l_action_type_id_prev := l_action_type_id;
    end if;

    if (l_action_type_voting_regime = ame_util.firstApproverVoting) then
      l_firstvoter_found := 'Y';
      x_voting_regime := ame_util.firstApproverVoting;
    end if;

    if (l_firstvoter_found = 'Y' and
        (l_multiple_group_id = 'Y' or l_multiple_action_type_id = 'Y')) then
      x_valid_regime := 'N';
      return;
    end if;
  end loop;

  x_valid_regime := 'Y';
end validate_voting_regime;
--Bug 4577122: End
------------------------------------------------------------------------------

-- Bug 3761813 : start
------------------------------------------------------------------------------
/* PRE_TX_SNAPSHOT IN:
            p_event_id             Unique eREcord ID,
          p_map_code             Map Code passed as Subscription parameter,
            p_document             EVENT KEY
*/

--Bug 4306292: Start
--Commenting changes made for red lining.

function PRE_TX_SNAPSHOT
  ( p_event_id             in number,
        p_MAPCODE              in varchar2,
        p_document             in varchar2
  ) return boolean IS PRAGMA AUTONOMOUS_TRANSACTION;
L_XML_DOCUMENT CLOB;
retcode     pls_integer;
errmsg      varchar2(2000);
logfile     varchar2(200);
begin
INSERT into edr_erecord_id_temp (document_id) values (p_Event_id);
ecx_outbound.getXML
      (
                    i_map_code    => p_MAPCODE,
                    i_document_id   => P_DOCUMENT,
                    i_debug_level => 6,
                    i_xmldoc    => L_XML_DOCUMENT,
                    i_ret_code    => retcode,
                    i_errbuf    => errmsg,
                    i_log_file    => logfile
      );
insert into EDR_REDLINE_TRANS_DATA (EVENT_ID,PRE_XML_DATA,POST_XML_DATA,ERR_CODE,ERR_MSG,DIFF_XML,APPENDIX_GEN_XML) values (p_event_id,L_XML_DOCUMENT,empty_clob(), retcode, errmsg, empty_clob(),empty_clob());
      commit;
     return true;
exception
    when others then
      rollback;
      return false;
end;

--Bug 4306292: End

-- Bug 3761813 :  end

----------------------------------------------------------------------------------

/* CREATE Pageflow IN:
            p_event_id             Unique eREcord ID,
          p_map_code             Map Code passed as Subscription parameter,
            p_ame_transaction_type AME Transaction Type passed as Subscription parameter,
            p_audit_group          AOL Audit Group passed as Subscription parameter,
            p_eventP               Event to be processes
          p_approverlist         AME approver Table
*/

function CREATE_PAGEFLOW
  ( p_event_id           in        number,
        p_map_code             in        varchar2,
        p_ame_transaction_type in        varchar2,
        p_audit_group          in        varchar2,
        p_eventP         in  out NOCOPY wf_event_t,
        p_subscription_guid    in    raw,
        P_approverlist         in        EDR_UTILITIES.approvers_Table,
        P_ERR_CODE             out NOCOPY    varchar2,
        P_ERR_MSG              out NOCOPY    varchar2

  ) return varchar2 IS PRAGMA AUTONOMOUS_TRANSACTION;

  l_event_user_key_label VARCHAR2(240);
  l_event_user_key_VALUE VARCHAR2(240);
  l_transaction_audit_id NUMBER;
  i integer;
  l_edr_signature_id number;
  l_fnd_user varchar2(100);
  l_temp_clob  CLOB;
  l_itemtype varchar2(240);
  l_itemkey varchar2(240);
  aname varchar2(240);
  avalue varchar2(4000);
  lparam wf_parameter_list_t;
  l_event wf_event_t;
  l_return_status varchar2(240);
  l_document_id number;
  l_error number;
  l_error_msg varchar2(4000);
  l_error_stack varchar2(4000);
  l_signature_id number;
  l_requester varchar2(240);
  l_doc_params      EDR_PSIG.params_table;

  /*Save Current Workflow Threshold */
  l_cur_threshold   WF_ENGINE.THRESHOLD%TYPE;
  l_overriding_approver varchar2(80);
  l_overriding_comments varchar2(4000);
  BAD_RULE Exception;
  DEFAULT_RULE_ERROR Exception;

BEGIN
  --Bug 4074173 : start
  l_cur_threshold := WF_ENGINE.THRESHOLD;
  --Bug 4074173 : end

  /* Update workflow threshold to default threshold */
  WF_ENGINE.THRESHOLD := 50;

  /* Get Payload Attributes required by Rule function */
  l_event_user_key_label  := wf_event.getValueForParameter('PSIG_USER_KEY_LABEL',p_eventP.Parameter_List);
  l_event_user_key_value  := wf_event.getValueForParameter('PSIG_USER_KEY_VALUE',p_eventP.Parameter_List);
  l_transaction_audit_id  := wf_event.getValueForParameter('PSIG_TRANSACTION_AUDIT_ID',p_eventP.Parameter_List);
  l_requester                   := wf_event.getValueForParameter('#WF_SIGN_REQUESTER',p_eventP.Parameter_List);
  wf_event.AddParameterToList('#FROM_ROLE', l_requester,p_eventP.Parameter_List); /* From Role */

  /* Temp Table Insertion */
  l_event_name:=P_eventP.getEventName( );
  l_event_key:=P_eventP.getEventKey( );
  l_temp_clob:=P_eventP.getEventData( );

  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PAGEFLOW_PROC_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                    FALSE
                   );
  end if;
  --Diagnostics End

  /* Insert into Temp tables for Further Processing */
  wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','Event Name Assigned');
  wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','CLOB Assignment Complete and insert being executed');

  INSERT INTO EDR_ERECORDS(EVENT_ID,
                           EVENT_NAME,
                           EVENT_KEY,
                           EVENT_USER_KEY_LABEL,
                           EVENT_USER_KEY_VALUE,
                           EVENT_TIMESTAMP,
                           EVENT_TIMEZONE,
                           ERECORD_XML,
                           ERECORD_SIGNATURE_STATUS,
                           XML_MAP_NAME,
                           AME_TRANSACTION_TYPE,
                           AUDIT_GROUP,
                           TRANSACTION_AUDIT_ID)
                    Values(p_event_id,
                           l_event_name,
                           l_event_key,
                           l_event_user_key_label,
                           l_event_user_key_value,
                           SYSDATE,
                           NULL, -- Still figuring out how to populate this
                           l_temp_clob,
                           'PENDING',
                           P_map_code,
                           p_ame_transaction_type,
                           p_audit_group,
                           l_transaction_audit_id);


  wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','Insertion Complete in EDR_ERECORDS');
  -- Bug Fix 3143107
  -- Removed Open Docement
  -- Post document parameters
  -- Change status
  -- Now this part will be handeled in PSIG_RULE for Both eRecord Only
  -- and eSignature Required scenarios
  --
  l_document_id := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.g_erecord_id_attr,p_eventP.Parameter_List);
  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PAGEFLOW_EREC_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                    FALSE
                   );
  end if;
  --Diagnostics End


  wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','Set the Document ID '||l_document_ID ||' as Event Parameter');
  wf_event.AddParameterToList('PSIG_DOCUMENT_ID', l_document_id,p_eventP.Parameter_List); /* Document_ID*/
  wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','Document ID added to event parameters ' );

  /* 24-FEB-2003: CJ : add the attachment item attribute to the workflow so that the attachments
                       of the eRecord show up in the workflow notification sent out to the signer*/


  /* Attachments_ID*/
  wf_event.AddParameterToList('#ATTACHMENTS', 'FND:entity=ERECORD'||'&'||'pk1name=DOCUMENT_ID'||'&'||'pk1value='||l_document_id,p_eventP.Parameter_List);
  wf_log_pkg.string(3, 'EDR_PSIG_rule.create_pageflow','Attachments added to event parameters ' );
  /* 24-FEB-2003: CJ: end */

  for i in 1 .. P_approverlist.count loop

    --Bug 2674799: start
    --New AME approvers table has the WF Directory name of user.
    l_fnd_user := P_approverList(i).name;
    wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','AME Approver '||P_approverlist(i).occurrence||'-'||l_fnd_user);
    wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','Figuring out overriding approver for '||l_fnd_user);
    --Bug 4160412: Start
    --Find the overriding details only if a user name is provided.
    if length(l_fnd_user) > 0 and instr(l_fnd_user,'#') = 0 then
      EDR_STANDARD.FIND_WF_NTF_RECIPIENT(l_fnd_user,'EDRPSIGF','PSIG_EREC_MESSAGE_BLAF',
                                         l_overriding_approver,l_overriding_comments,
                                         l_error,l_error_msg);

      IF l_error > 0 THEN
        RAISE BAD_RULE;
      END IF;

    else

      l_overriding_approver := l_fnd_user;

    end if;

    --Bug 4160412: End

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PAGEFLOW_APPR_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_MESSAGE.SET_TOKEN('APPROVER_NO',i);
      FND_MESSAGE.SET_TOKEN('APPROVER_COUNT',p_approverlist.count);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                      FALSE
                     );
    end if;
    --Diagnostics End

    wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','Figured out overriding approver for '||l_fnd_user||' as '||l_overriding_approver);

    /* Insert into Temp tables for Further Processing */
    SELECT EDR_ESIGNATURES_S.NEXTVAL into l_edr_signature_id from DUAL;
    wf_log_pkg.string(3, 'EDR_PSIG_rule.create_pageflow','Signature Sequence Fetched '||l_edr_signature_id);

    INSERT into EDR_ESIGNATURES(SIGNATURE_ID,
                                EVENT_ID,
                                EVENT_NAME,
                                USER_NAME,
                                SIGNATURE_SEQUENCE,
                                SIGNATURE_STATUS,
                                ORIGINAL_RECIPIENT,
                                SIGNATURE_OVERRIDING_COMMENTS)

                         values(l_edr_signature_id,
                                p_event_id,
                                l_event_name,
                                l_OVERRIDING_APPROVER,
                                P_approverList(i).approver_order_number,
                                'PENDING',
                                L_FND_USER,
                                L_OVERRIDING_COMMENTS);
    --Bug 2674799 : end

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PAGEFLOW_ESIG_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_MESSAGE.SET_TOKEN('APPROVER',l_overriding_approver);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                      FALSE
                     );
    end if;
    --Diagnostics End


    wf_log_pkg.string(3, 'EDR_PSIG_rule.create_pageflow','Insert Complete into EDR_ESIGNATURES');
    wf_log_pkg.string(3, 'EDR_PSIG_rule.create_pageflow','Requesting Signatures in PSIG evidance Store');

    --Bug 2674799: start
    --Store the approver order number in EDR_PSIG_DETAILS
    --Bug 4160412: Start
    --Request for signature only if a user name is provided.
    if length(l_fnd_user) > 0  and instr(l_fnd_user,'#') = 0 then
      EDR_PSIG.REQUESTSIGNATURE(P_DOCUMENT_ID=>l_document_id,
                                P_USER_NAME=>l_overriding_approver,
                                P_ORIGINAL_RECIPIENT=>l_fnd_user,
                                P_OVERRIDING_COMMENTS=>l_overriding_comments,
                                P_SIGNATURE_ID=>l_signature_id,
                                P_ERROR=>L_ERROR,
                                P_ERROR_MSG=>l_error_msg,
                                P_SIGNATURE_SEQUENCE => P_APPROVERLIST(I).APPROVER_ORDER_NUMBER);
      --Bug 2674799: end

      --Bug 3416357: start
      --Trap the error after requestSignature.
      IF (nvl(l_error,0) > 0) THEN
        RAISE BAD_RULE;
      END IF;
    end if;
    --Bug 3416357: end
    --Bug 4160412: End

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PAGEFLOW_PSIG_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_MESSAGE.SET_TOKEN('APPROVER',l_overriding_approver);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                      FALSE
                     );
    end if;
    --Diagnostics End

    wf_log_pkg.string(1, 'EDR_PSIG_rule.create_pageflow','PSIG id for' ||l_fnd_user||' is '||l_signature_id);

    /* Clear the entries */
    l_overriding_comments:=NULL;
    l_overriding_approver:=NULL;
    l_fnd_user:=NULL;

  end loop;

  /* END Approver List */

  wf_log_pkg.string(3, 'EDR_PSIG_RULE.create_pageflow','AME Approver list inserted into temp table');
  /*call Workflow dEfault Rule funciton */

  l_return_status:=WF_RULE.DEFAULT_RULE(p_subscription_guid=>p_subscription_guid,p_event=>p_eventP);


  if l_return_status = EDR_CONSTANTS_GRP.g_error_status THEN
    ROLLBACK;
    -- Bug Fix :3154362
    -- Added following two lines first one retrieves error message populated by
    -- Rule function
    -- second line will push error message it UI as cascading exception handling
    --
    l_error_msg := p_eventP.GETERRORMESSAGE;
    RAISE DEFAULT_RULE_ERROR;
  ELSE
    COMMIT;
    wf_log_pkg.string(3, 'EDR_PSIG_RULE.create_pageflow','COMMIT Completed in Create pageflow');

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_PAGEFLOW_SUCCESS_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                      FALSE
                     );
    end if;
    --Diagnostics End

  END IF;

  /* Udate workflow threshold to saved value */
  WF_ENGINE.THRESHOLD := l_cur_threshold;
  RETURN l_return_status;

exception
  when BAD_RULE then

    /* Update workflow threshold to saved value */
    WF_ENGINE.THRESHOLD := l_cur_threshold;
    Wf_Core.Context('EDR_PSIG_RULE', 'CREATE_PAGEFLOW', p_eventP.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_eventP,'ERROR');
    ROLLBACK;
    p_err_code:=l_error;
    p_err_msg:=l_error_msg;

    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','CREATE_PAGEFLOW');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                      FALSE
                     );
    end if;
    --Diagnostics End

    return 'ERROR';

  when DEFAULT_RULE_ERROR then
    /* Update workflow threshold to saved value */
    WF_ENGINE.THRESHOLD := l_cur_threshold;
    Wf_Core.Context('EDR_PSIG_RULE', 'CREATE_PAGEFLOW', p_eventP.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_eventP,'ERROR');
    ROLLBACK;
    p_err_code:=l_error;
    p_err_msg:= l_error_msg;

    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','CREATE_PAGEFLOW');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                      FALSE
                     );
    end if;
    --Diagnostics End

    return 'ERROR';

  when others then
    /* Udate workflow threshold to saved value */
    Wf_Core.get_ERROR(l_error,l_error_msg,l_error_stack);
    wf_log_pkg.string(6,'in when others of create_pageflow'||l_error,l_error_msg||substr(l_error_stack,1,100));
    WF_ENGINE.THRESHOLD := l_cur_threshold;
    Wf_Core.Context('EDR_PSIG_RULE', 'CREATE_PAGEFLOW', p_eventP.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_eventP,'ERROR');
    ROLLBACK;
    p_err_code:=l_error;
    p_err_msg:=l_error_msg;
    --Diagnostics Start
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','CREATE_PAGEFLOW');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                     'edr.plsql.EDR_PSIG_RULE.CREATE_PAGEFLOW',
                     FALSE
                    );
    end if;
    --Diagnostics End
    return 'ERROR';
END CREATE_PAGEFLOW;

-------------------------------------------------------------------------------------------------------------------------------------

--
-- Start of comments
-- API name             : STORE_ERECORD
-- Type                 : Private.
-- Function             : Generates and stores eRecord into Evidence Store
--                        autonomously.
-- Pre-reqs             : None.
-- Parameters           :
--                       p_XML_DOCUMENT -- XML Generated in calling procedure
--                       p_style_shee_repository  -- Style Sheet repository which will be responsibile for providing the API
--                                                   to be called to provide the stylesheet in blob
--                       p_style_sheet  -- Style Sheet to be applied
--                       p_style_sheet_ver -- Version of the stlye sheet to be applied
--                       p_approved_style_sheet_required  -- Whether appoved Style Sheet is required for current transaction
--                       p_edr_event_id -- Event Id this is used to associate with attachments
--                       p_esign_required -- Siganture Required flag it will be either 'Y' or 'N'
--                       p_subscription_guid -- Subscription Id
--                       x_event  -- This is in OUT using this calling code can access
--                                   updated event parameters

PROCEDURE STORE_ERECORD(p_XML_DOCUMENT CLOB,
                        p_style_sheet_repository VARCHAR2,
                        p_style_sheet VARCHAR2,
                        p_style_sheet_ver VARCHAR2,
                        p_application_code VARCHAR2,
                        p_edr_event_id NUMBER,
                        p_esign_required   VARCHAR2,
                        p_subscription_guid RAW,
                        x_event  in out NOCOPY wf_event_t
                        ) IS PRAGMA AUTONOMOUS_TRANSACTION;
  l_XML_DOCUMENT CLOB ;
  l_EREC_OUTPUT  CLOB;
  l_EREC_OUTPUT_CH VARCHAR2(512);
  l_erec_output_ln number;
  L_EVENT_NAME varchar2(240);
  L_EVENT_KEY  varchar2(240);
  l_document_id number;
  l_error number;
  l_error_msg varchar2(4000);
  l_event_user_key_label VARCHAR2(240);
  l_event_user_key_VALUE VARCHAR2(240);
  l_params EDR_PSIG.params_table;
  l_source_application varchar2(240);
  l_requester varchar2(240);
  l_user_id NUMBER;
  l_login_id NUMBER;

  l_approved BOOLEAN ;
  l_style_sheet_type VARCHAR2(240);
  l_output_format   VARCHAR2(25);
  ERECORD_GENERATION_ERROR EXCEPTION;
  ERECORD_CREATION_ERROR EXCEPTION;
  ERECORD_PARAM_ERROR    EXCEPTION;

  ERECORD_GEN_XSLFOMISS_ERR EXCEPTION;
  ERECORD_GEN_FATALERR EXCEPTION;
  ERECORD_GEN_XDOERR EXCEPTION;
  ERECORD_GEN_UNKNWN_ERR EXCEPTION;
  ERECORD_GEN_JSPMSNG_ERR EXCEPTION;
  ERECORD_GEN_JSPRQFAIL_ERR EXCEPTION;
  ERECORD_UNKWN_TMPL_TYPE EXCEPTION;

  ERECORD_GEN_XSLT_ERR EXCEPTION;

  --Bug 2637353: Start
  l_source_application_type VARCHAR2(10);
  MSCA_TMPL_ERROR EXCEPTION;
  --Bug 2637353: End
   -- Bug 3761813 : start
   l_redline_required varchar2(30);
   X_DIFF_XML   CLOB ;
   x_output  CLOB ;
   l_amount   BINARY_INTEGER ;
   l_pos      PLS_INTEGER ;
   l_clob_len PLS_INTEGER;
   vBuffer    VARCHAR2 (32767);
 -- Bug 3761813 : END

 --Bug 4150616: Start
 l_force_erecord VARCHAR2(10);
 l_force_erecord_used VARCHAR2(10);
 --Bug 4150616: End
BEGIN

  --Bug 4150616: Start
  --Fetch the value of FORCE_ERECORD from the event payload.
  l_force_erecord := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.G_FORCE_ERECORD,x_event.Parameter_List);

  --Fetch the value of FORCE_ERECORD_USED from the event payload.
  l_force_erecord_used := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.G_FORCE_ERECORD_USED,x_event.Parameter_List);
  --Bug 4150616: End

  --Bug 4074173 : start
  l_approved  := false;
  l_XML_DOCUMENT := p_XML_DOCUMENT;
  l_user_id := fnd_global.user_id;
  l_login_id := fnd_global.login_id;
  l_style_sheet_type := 'XSL';
  l_output_format   := null;
  --Bug 4074173 : end

  l_event_name:=x_event.getEventName( );
  l_event_key:=x_event.getEventKey( );

  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_PROC_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                    FALSE
                   );
  end if;
  --Diagnostics End

  /* Only eRecord Required. Generate the eRecord output Output and post it in temp tables */
  L_EREC_OUTPUT:=P_XML_DOCUMENT;
  wf_log_pkg.string(3, 'EDR_PSIG_RULE.STORE_ERECORD','Start of store erecord');
  l_requester := wf_event.getValueForParameter('#WF_SIGN_REQUESTER',x_event.Parameter_List);

  --Bug 3170251 : Start- EREC_TEMPLATE TYPE from Workflow
  /* Find the Style Sheet Type from Workflow Parameter  EREC_TEMPLATE_TYPE */
  l_style_sheet_type := wf_event.getValueForParameter('EREC_TEMPLATE_TYPE',x_event.Parameter_List);
  -- Bug 3170251 : End

  -- Bug 3170251 : Start- Open the PSIG document, to get the l_document_id value for use in XDOC
  EDR_PSIG.openDocument(P_PSIG_XML        => p_xml_document,
                        P_PSIG_REQUESTER  => l_requester,
                        P_DOCUMENT_ID     => l_document_id,
                        P_ERROR           => l_error,
                        P_ERROR_MSG       => l_error_msg);
  -- Bug 3170251 : End

  IF l_error is NOT NULL THEN
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','open document errored out with code '||l_error);
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','open document Error Msg '||l_error_msg);
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Opened Document in eRecords Repository with Document ID '||l_document_id);
    RAISE ERECORD_CREATION_ERROR;
  END IF;

  wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','committing the transaction in store erecord');
  commit;

  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_EREC_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                    FALSE
                   );
  end if;
  --Diagnostics End

  -- Bug 3761813 : start
  l_redline_required := wf_event.getValueForParameter('REDLINE_REQUIRED',x_event.Parameter_List);
  wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','REDLINE_REQUIRED'||l_redline_required);
  -- Bug 3761813 :  end


  -- Bug 3170251 : Start- if EREC_TEMPLATE TYPE isRTF then call EDR_XDOC_UTIL_PKG.GENERATE_ERECORD procedure.
  -- call xdoc utility package to geneate the pdf document if style sheet is RTF
  IF (UPPER(l_style_sheet_type) = 'RTF') THEN

    --Bug 2637353: Start
    --Check if source application type is "MSCA".
    l_source_application_type := wf_event.getValueForParameter('#WF_SOURCE_APPLICATION_TYPE',x_event.Parameter_List);
    if(l_source_application_type = 'MSCA') then
      raise MSCA_TMPL_ERROR;
    END IF;
    --Bug 2637353: End

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_RTF_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_MESSAGE.SET_TOKEN('TEMPLATE_NAME',p_style_sheet);
      FND_MESSAGE.SET_TOKEN('TEMPLATE_VER',p_style_sheet_ver);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                    );
    end if;
    --Diagnostics End

    /*    EDR_XDOC_UTIL_PKG.generate_ERecord(p_edr_event_id =>p_edr_event_id,
                                             p_erecord_id => l_document_id,
                                             p_style_sheet_repository => p_style_sheet_repository,
                                             p_style_sheet => p_style_sheet,
                                             p_style_sheet_ver => p_style_sheet_ver,
                                             x_output_format => l_output_format,
                                             x_error_code => l_error,
                                             x_error_msg => l_error_msg);*/
    --Bug 3761813 : start
    -- new parameter p_redline_mode is added

    EDR_XDOC_UTIL_PKG.generate_ERecord(p_edr_event_id           => p_edr_event_id,
                                       p_erecord_id             => l_document_id,
                                       p_style_sheet_repository => p_style_sheet_repository,
                                       p_style_sheet            => p_style_sheet,
                                       p_style_sheet_ver        => p_style_sheet_ver,
                                       p_redline_mode         => l_redline_required,
                                       --Bug 4306292: End
                                       -- Bug 3170251 : start
                                       p_application_code       => p_application_code,
                                       -- Bug 3170251 : end
                                       x_output_format          => l_output_format,
                                       x_error_code             => l_error,
                                       x_error_msg              => l_error_msg);
    --Bug 3761813 : end

    --Bug 3474765 : Start
    -- Changing to MIME Format
    l_output_format := 'application/pdf';
    --Bug 3474765 : End

    --Raise exception if there is any error in e-Record Generation

    -- Important Error Handling done to make sure UTL_HTTP based eRecord PDF generation
    -- was successful, otherwise throw appropriate error to the user,

    IF l_error = 10 THEN
      -- This error means either the XSLFO for given template is missing i.e. due to
      -- approval process missing or converision error OR Template is not uploaded
      -- in the respective repository.
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code from PDF e-record generation process: '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg from PDF e-record generation process: '||l_error_msg);
      RAISE ERECORD_GEN_XSLFOMISS_ERR;
    END IF;

    IF l_error = 20 THEN
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code from PDF e-record generation process: '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg from PDF e-record generation process: '||l_error_msg);
      RAISE ERECORD_CREATION_ERROR;
    END IF;

    IF l_error = 30 THEN
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code from PDF e-record generation process: '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg from PDF e-record generation process: '||l_error_msg);
      RAISE ERECORD_GEN_FATALERR;
    END IF;

    IF l_error = 40 THEN
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code from PDF e-record generation process: '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg from PDF e-record generation process: '||l_error_msg);
      RAISE ERECORD_GEN_XDOERR;
    END IF;

    IF l_error = 100 THEN
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code from PDF e-record generation process: '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg from PDF e-record generation process: '||l_error_msg);
      RAISE ERECORD_GEN_UNKNWN_ERR;
    END IF;

    IF l_error = 505 THEN
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code from PDF e-record generation process: '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg from PDF e-record generation process: '||l_error_msg);
      RAISE ERECORD_GEN_JSPMSNG_ERR;
    END IF;

    IF l_error = 500 THEN
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code from PDF e-record generation process: '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg from PDF e-record generation process: '||l_error_msg);
      RAISE ERECORD_GEN_JSPRQFAIL_ERR;
    END IF;

    /* Set the E-Record Notification Details to Message for PDF E-Records */
    fnd_message.set_name('EDR','EDR_EREC_ATT_NTF_BODY');
    fnd_message.set_token('ERECORD_ID',l_document_id);

    l_erec_output_ch := fnd_message.get;
    l_erec_output_ln := DBMS_LOB.GETLENGTH(L_EREC_OUTPUT);
    DBMS_LOB.ERASE(L_EREC_OUTPUT,l_erec_output_ln ,  1);
    DBMS_LOB.WRITE(L_EREC_OUTPUT, LENGTH(L_EREC_OUTPUT_CH), 1, l_erec_output_ch);
    DBMS_LOB.TRIM(L_EREC_OUTPUT, length(l_erec_output_ch));

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_PDF_SUC_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

  END IF;
  --Bug: 3170251 - End

  -- For normal XSL stylsheet generate HTML eRecord using ECX Transformations
  IF(UPPER(l_style_sheet_type) = 'XSL') THEN

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_XSL_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_MESSAGE.SET_TOKEN('TEMPLATE_NAME',p_style_sheet);
      FND_MESSAGE.SET_TOKEN('TEMPLATE_VER',p_style_sheet_ver);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                    );
    end if;
    --Diagnostics End

    -- Bug 3761813 : start
    --Bug 4306292: Start
    --Commenting the changes made for red lining.

    --get the DIFF XML  and transform the same.
    if (nvl(l_redline_required,'N') = 'Y' ) then

      X_DIFF_XML := EMPTY_CLOB;
      x_output   := EMPTY_CLOB;
      l_amount   := 32767;
      l_pos      := 1;

    EDR_XDOC_UTIL_PKG.generate_ERecord(p_edr_event_id           => p_edr_event_id,
                                       p_erecord_id             => l_document_id,
                                       p_style_sheet_repository => p_style_sheet_repository,
                                       p_style_sheet            => p_style_sheet,
                                       p_style_sheet_ver        => p_style_sheet_ver,
                                       p_redline_mode         => l_redline_required,
                                       p_application_code       => p_application_code,
                                       x_output_format          => l_output_format,
                                       x_error_code             => l_error,
                                       x_error_msg              => l_error_msg);

      wf_log_pkg.string(1, 'EDR_PSIG_RULE.store_erecord',' generate_ERecord for redline. Error  '||l_error );

      wf_log_pkg.string(1, 'EDR_PSIG_RULE.store_erecord',' generate_ERecord for redline. l_error_msg  '||l_error_msg );

      dbms_lob.createtemporary(X_DIFF_XML,TRUE);
      dbms_lob.open( X_DIFF_XML, dbms_lob.lob_readwrite );

      select DIFF_XML into x_output  from EDR_REDLINE_TRANS_DATA  where EVENT_ID  = p_edr_event_id ;

      l_clob_len := dbms_lob.getlength(x_output);
      WHILE l_pos < l_clob_len LOOP
        dbms_lob.read(x_output, l_amount, l_pos, vBuffer);
        dbms_lob.writeappend(X_DIFF_XML, LENGTH(vBuffer), vBuffer);
        l_pos := l_pos + l_amount;
      END LOOP;

      L_EREC_OUTPUT := X_DIFF_XML;
      dbms_lob.close(X_DIFF_XML);
      dbms_lob.freeTemporary(X_DIFF_XML );

      IF nvl(l_error,0) <> 0 THEN
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Template Type : text ');
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code '||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','eRecord generated');
        RAISE ERECORD_GEN_XSLT_ERR;
      END IF;

      IF l_error = 10 THEN
        -- This error means either the XSLFO for given template is missing i.e. due to
        -- approval process missing or converision error OR Template is not uploaded
        -- in the respective repository.
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code XSL '||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        RAISE ERECORD_GEN_XSLFOMISS_ERR;
      END IF;

      IF l_error = 20 THEN
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code XSL'||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','eRecord generated');
        RAISE ERECORD_CREATION_ERROR;
      END IF;

      IF l_error = 30 THEN
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code XSL'||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        RAISE ERECORD_GEN_FATALERR;
      END IF;

      IF l_error = 40 THEN
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error CodeXSL '||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        RAISE ERECORD_GEN_XDOERR;
      END IF;

      IF l_error = 100 THEN
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code XSL'||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        RAISE ERECORD_GEN_UNKNWN_ERR;
      END IF;

      IF l_error = 505 THEN
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code XSL'||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        RAISE ERECORD_GEN_JSPMSNG_ERR;
      END IF;

      IF l_error = 500 THEN
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code XSL'||l_error);
        wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg '||l_error_msg);
        RAISE ERECORD_GEN_JSPRQFAIL_ERR;
      END IF;
    END IF;
    --Bug 4306292: End
    --Bug 3761813 : END

    ECX_STANDARD.perform_xslt_transformation (i_xml_file              => L_EREC_OUTPUT,
                                              i_xslt_file_name        => p_style_sheet,
                                              i_XSLT_FILE_VER         => p_style_sheet_ver,
                                              i_XSLT_APPLICATION_CODE => lower(p_application_code),
                                              i_retcode               => l_error,
                                              i_retmsg                => l_error_msg);
    -- Bug 4862464: Start
    -- l_output_format :=TEXT;
    -- Changing the harcoded document format from TEXT to
    -- text/plain
    -- The edr_psig.openDocument api converts the document format from TEXT
    -- to text/plain but the updatedocument api retains the document format
    -- so for consistency we pass the text/plain document format.
    l_output_format := WF_NOTIFICATION.doc_text;
    -- Bug 4862464: End
    IF nvl(l_error,0) <> 0 THEN
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','XSL Transformation Error Code '||l_error);
      wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','XSL Transformation Error Msg '||l_error_msg);
      RAISE ERECORD_GEN_XSLT_ERR;
    END IF;

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_XSL_SUC_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
      FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

  END IF;



  -- Check if template type is one of the valid types.
  IF ((UPPER(l_style_sheet_type) <>  'XSL')  AND (UPPER(l_style_sheet_type) <> 'RTF')) THEN
    wf_log_pkg.string(5, 'EDR_PSIG_RULE.store_erecord','Wrong Stylesheet Type ' || l_style_sheet_type );
    RAISE ERECORD_UNKWN_TMPL_TYPE;
  END IF;

  /* Get Payload Attributes required by Rule function */
  l_event_user_key_label := wf_event.getValueForParameter('PSIG_USER_KEY_LABEL',x_event.Parameter_List);
  l_event_user_key_value := wf_event.getValueForParameter('PSIG_USER_KEY_VALUE',x_event.Parameter_List);
  l_source_application   := wf_event.getValueForParameter('#WF_SOURCE_APPLICATION_TYPE',x_event.Parameter_List);
  l_requester            := wf_event.getValueForParameter('#WF_SIGN_REQUESTER',x_event.Parameter_List);

  /* Call Repository  API's */
  wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','Posting Document in eRecords Repository');

  EDR_PSIG.updateDocument(P_DOCUMENT_ID         => l_document_id,
                          P_PSIG_XML            => L_XML_DOCUMENT,
                          P_PSIG_DOCUMENT       => L_EREC_OUTPUT,
                          P_PSIG_DOCUMENTFORMAT => l_output_format,
                          P_PSIG_REQUESTER      => l_requester,
                          P_PSIG_SOURCE         => l_source_application,
                          P_EVENT_NAME          => l_event_name,
                          P_EVENT_KEY           => l_event_key,
                          P_WF_NID              => NULL,
                          P_ERROR               => l_error,
                          P_ERROR_MSG           => l_error_msg);
  IF l_error is NOT NULL THEN
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code during update document '||l_error);
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg during update document '||l_error_msg);
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Updated Document in eRecords Repository with Document ID '||l_document_id);
    RAISE ERECORD_CREATION_ERROR;
  END IF;

  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_REC_UPD_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                    FALSE
                   );
  end if;
  --Diagnostics End


  /* 20-OCT-2003: SRPURI : Modified attachment code to resolve the bug 3058816 */

  /*
  -- Commented and added Copy Attachments and delete attachments
     update fnd_attached_documents
     set pk1_value = l_document_id
     where entity_name = EDR_CONSTANTS_GRP.g_erecord_entity_name
     and pk1_value = p_edr_event_id; */
  wf_log_pkg.string(1, 'EDR_PSIG_RULE.store_erecord','Before Moving attachments from Temp entity to eRecord '
                        ||'from '||p_edr_event_id||' to '||l_document_id);

                        --Bug 4381237: Start
                        --Change the call to EDR attachment API
      --fnd_attached_documents2_pkg.copy_attachments(
      edr_attachments_grp.copy_attachments
      --Bug 4381237: End
                        (X_from_entity_name         => G_TEMP_ENTITY_NAME,
                         X_from_pk1_value           => p_edr_event_id,
                         X_from_pk2_value           => null,
                         X_from_pk3_value           => null,
                         X_from_pk4_value           => null,
                         X_from_pk5_value           => null,
                         X_to_entity_name           => G_ENTITY_NAME,
                         X_to_pk1_value             => l_document_id,
                         X_to_pk2_value             => null,
                         X_to_pk3_value             => null,
                         X_to_pk4_value             => null,
                         X_to_pk5_value             => null,
                         X_created_by               => l_user_id,
                         X_last_update_login        => l_login_id,
                         X_program_application_id   => null,
                         X_program_id               => null,
                         X_request_id               => null,
                         X_automatically_added_flag => 'N',
                         X_from_category_id         => null,
                         X_to_category_id           => null);

  wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','After Moving attachments from Temp entity to eRecord '
                        ||'from '||p_edr_event_id||' to '||l_document_id);

  wf_log_pkg.string(1, 'EDR_PSIG_RULE.store_erecord','Before Deleting attachments from Temp entity '
                       ||'from '||p_edr_event_id);


  -- Bug 3863541 : Start
  -- Modified call to delete_attachments to support
  -- URL / Web page attachments

  fnd_attached_documents2_pkg.delete_attachments
  (X_entity_name              => G_TEMP_ENTITY_NAME,
   X_pk1_value                => to_char(p_edr_event_id),
   X_pk2_value                => null,
   X_pk3_value                => null,
   X_pk4_value                => null,
   X_pk5_value                => null,
   --Bug 4381237: Start
   --pass this flag as Y so that the attachments to TEMPERECORD
   --are deleted. this is ok NOW because we are using our
   --own attachment api above. That would not bring the base
   --entities attachment into picture
   --X_delete_document_flag         => 'N',
   X_delete_document_flag           => 'Y',
   --Bug 4381237: End
   X_automatically_added_flag => 'N');
  --Bug 3863541 : End

  wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','After Deleting attachments from Temp entity '
                       ||'from '||p_edr_event_id);


  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_ATCH_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
    FND_MESSAGE.SET_TOKEN('ATTACHMENT_ID',p_edr_event_id);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                    FALSE
                   );
  end if;
  --Diagnostics End


  /* 20-OCT-2003: srpuri : end */
  --ER # 2966866 start
  wf_event.AddParameterToList('#ERECORD_ID',
                              l_document_id,
                              x_event.Parameter_List);
  wf_log_pkg.string(1, 'EDR_PSIG_RULE.store_erecord','eRecord Id added to payload: '||l_document_id);

  --ER # 2966866 end
  /* Add Document Parameters */
  l_params(1).param_name:='PSIG_USER_KEY_LABEL';
  l_params(1).param_value:=l_event_user_key_label;
  l_params(1).param_displayname:='Identifier label';
  l_params(2).param_name:='PSIG_USER_KEY_VALUE';
  l_params(2).param_value:=l_event_user_key_value;
  l_params(2).param_displayname:='Identifier value';

  /* Style Sheet information */
  l_params(3).param_name:='TEXT_XSLNAME';
  l_params(3).param_value:=p_style_sheet;
  l_params(3).param_displayname:='Stylesheet';
  l_params(4).param_name:='TEXT_XSLVERSION';
  l_params(4).param_value:=p_style_sheet_ver;
  l_params(4).param_displayname:='Stylesheet Version';

  --Bug 4150616: Start
  --Set the value of FORCE_ERECORD if it exists in the
  --doc params.
  if upper(l_force_erecord) in('Y','N') then
    l_params(5).param_name        := EDR_CONSTANTS_GRP.G_FORCE_ERECORD;
    l_params(5).param_value       := l_force_erecord;
    l_params(5).param_displayname := 'Force E-record';

    --If FORCE_ERECORD_USED is set then set that parameter and its value
    --in the doc params.
    if l_force_erecord_used = 'Y' then
      l_params(6).param_name        := EDR_CONSTANTS_GRP.G_FORCE_ERECORD_USED;
      l_params(6).param_value       := l_force_erecord_used;
      l_params(6).param_displayname := 'E-record Creation Forced';
    end if;
  end if;
  --Bug 4150616: End

  --Bug 4755255: Start
  l_params(5).param_name := '#ATTACHMENTS';
  l_params(5).param_value := 'FND:entity=ERECORD'||'&'||'pk1name=DOCUMENT_ID'||'&'||'pk1value='||l_document_id;

  --Bug 4755255: End

  wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Posting Document Parameters');

  EDR_PSIG.POSTDOCUMENTPARAMETER(P_DOCUMENT_ID => l_document_id,
                                 P_PARAMETERS  => l_params,
                                 P_ERROR       => l_error,
                                 P_ERROR_MSG   => l_error_msg);

  IF l_error is NOT NULL THEN
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Code during posting doc params '||l_error);
    wf_log_pkg.string(4, 'EDR_PSIG_RULE.store_erecord','Error Msg during posting doc params '||l_error_msg);
    RAISE ERECORD_PARAM_ERROR;
  END IF;

  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_POST_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                    FALSE
                   );
  end if;
  --Diagnostics End

  -- Bug Fix 3143107
  -- Modified unconditional Close document to Conditional Close
  -- and added Conditional Status Change Call where eSignature is Required
  --Bug 4150616: Start
  --If either ESIG_REQUIRED is set to 'N' or FORCE_ERECORD_USED has been set to 'Y' then close the document.
  IF p_esign_required = 'N' OR l_force_erecord_used = 'Y' THEN
    --Bug 4150616: End
    EDR_PSIG.closeDocument(P_DOCUMENT_ID => l_document_id,
                           P_ERROR       => l_error,
                           P_ERROR_MSG   => l_error_msg);
    wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','Document Closed');

  ELSIF p_esign_required = 'Y' THEN
    EDR_PSIG.CHANGEDOCUMENTSTATUS(P_DOCUMENT_ID => l_document_id,
                                  P_STATUS      => 'ERROR',
                                  P_ERROR       => L_ERROR,
                                  P_ERROR_MSG   => l_error_msg);
    wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','Changed Document Status to an Intermediate Status');
  END IF;
  -- END Bug Fix 3143107

  -- If everything went fine, commiting the ERECORD Contents by commiting this autonomous transaction
  COMMIT;

  --Diagnostics Start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_ST_ERECORD_STATUS_EVT');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',l_event_name);
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',l_event_key);
    FND_MESSAGE.SET_TOKEN('ERECORD_ID',l_document_id);
    FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                    'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                    FALSE
                   );
  end if;
  --Diagnostics End

  wf_log_pkg.string(3, 'EDR_PSIG_RULE.store_erecord','Store_erecord completed successfully');

EXCEPTION
  when ERECORD_GENERATION_ERROR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'STORE_ERECORD', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR');
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','PSIG_RULE');

    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
  when ERECORD_CREATION_ERROR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'STORE_ERECORD', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR');
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','STORE_ERECORD');

    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
  when ERECORD_PARAM_ERROR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'STORE_ERECORD', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR');
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','STORE_ERECORD');
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;

  -- Bug 3170251 : Start - Added following new exceptions for error handling
  when ERECORD_GEN_XSLFOMISS_ERR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    Wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR XSLFO MISSING');
    FND_MESSAGE.SET_NAME('EDR','EDR_EREC_XSLFO_MISSING_ERR');
    fnd_message.set_token( 'TEMPLATE_NAME',p_style_sheet);
    fnd_message.set_token( 'TEMPLATE_VER',p_style_sheet_ver);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;

  when ERECORD_GEN_FATALERR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR');

    wf_log_pkg.string(5, 'EDR_PSIG_RULE.store_erecord','There is a fatal error during e-record creation using XDO API');

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','STORE_ERECORD');

    --Diagnostics Start
    if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

     APP_EXCEPTION.RAISE_EXCEPTION;
  when ERECORD_GEN_UNKNWN_ERR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR');
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','STORE_ERECORD');

    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
  when ERECORD_GEN_XDOERR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR IN XDO');
    FND_MESSAGE.SET_NAME('EDR','EDR_EREC_XDO_ERR');
    fnd_message.set_token( 'TEMPLATE_NAME',p_style_sheet);
    fnd_message.set_token( 'TEMPLATE_VER',p_style_sheet_ver);

    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
  when ERECORD_UNKWN_TMPL_TYPE then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'Unknown Template Type'|| l_style_sheet_type);
    FND_MESSAGE.SET_NAME('EDR','EDR_EREC_TMPL_TYPE_ERR');
    fnd_message.set_token( 'TEMPLATE_NAME',p_style_sheet);
    fnd_message.set_token( 'TEMPLATE_VER',p_style_sheet_ver);

    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;

  when ERECORD_GEN_JSPMSNG_ERR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    Wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR JSP MISSING');
    FND_MESSAGE.SET_NAME('EDR','EDR_EREC_JSP_MISSING_ERR');

    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
  when ERECORD_GEN_JSPRQFAIL_ERR then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    Wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR JSP UTL_HTTP REQUEST FAILED');
    FND_MESSAGE.SET_NAME('EDR','EDR_EREC_JSPREQFAIL_ERR');

    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                       FALSE
                      );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
    -- Bug 3170251 : End

  -- Bug 3390571 : Start
  when ERECORD_GEN_XSLT_ERR then
    ROLLBACK;
    wf_core.context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    Wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR : XSLT Transformation error');
    FND_MESSAGE.SET_NAME('EDR','EDR_EREC_XSLTTRANS_ERR');
    fnd_message.set_token( 'TEMPLATE_NAME',p_style_sheet);
    fnd_message.set_token( 'TEMPLATE_VER',p_style_sheet_ver);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;

  --Bug 3390571: End

  --Bug 2637353: Start
  WHEN MSCA_TMPL_ERROR THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_MSCA_TMPL_ERR');
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    APP_EXCEPTION.RAISE_EXCEPTION;
    --Diagnostics End
  --Bug 2637353: End


  when OTHERS then
    ROLLBACK;
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', x_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(x_event,SQLERRM || 'ERROR');
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','STORE_ERECORD');
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.STORE_ERECORD',
                      FALSE
                     );
    end if;
    --Diagnostics End


    APP_EXCEPTION.RAISE_EXCEPTION;
END STORE_ERECORD;

-------------------------------------------------------------------------------------------------------------------------------------

/* Signature Rule function
   IN:
   p_subscription_guid  GUID of Subscription to be processed
   p_event              Event to be processes
*/


function psig_rule(p_subscription_guid in            raw,
                   p_event             in out NOCOPY wf_event_t)

return varchar2

is

  L_EVENT_NAME varchar2(240);
  L_EVENT_KEY  varchar2(240);
  --sswa addition
  L_EVENT_DATA CLOB;
  l_erecord_data CLOB;
  l_application_id NUMBER;
  l_application_code varchar2(32);

  -- using EDR approvers table
  approverList EDR_UTILITIES.approvers_Table;

  upperLimit integer;
  i integer;
  l_esign_required varchar2(1);
  l_eRecord_required varchar2(1);
  l_rule_esign_required varchar2(1);
  l_rule_eRecord_required  varchar2(1);
  l_XML_DOCUMENT CLOB;
  l_EREC_OUTPUT CLOB;
  lparamlist wf_parameter_list_t;
  l_STYLE_SHEET varchar2(240);
  l_STYLE_SHEET_VER  varchar2(240);
  l_STYLE_SHEET_repository varchar2(240);
  l_STYLE_SHEET_type varchar2(240);
  l_temp_style_sheet varchar2(240);
  l_temp_style_sheet_ver varchar2(240);

  l_POS number;

  l_return_status varchar2(10);
  l_xml_map_code varchar2(240);
  l_audit_group varchar2(240);
  l_ame_transaction_type varchar2(240);
  l_edr_Event_id number;
  l_event_user_key_label VARCHAR2(240);
  l_event_user_key_VALUE VARCHAR2(240);
  l_transaction_audit_id NUMBER;
  l_document_id number;
  l_error number;
  l_error_msg varchar2(4000);
  l_params EDR_PSIG.params_table;
  l_source_application varchar2(240);
  l_requester varchar2(240);
  l_transaction_name varchar2(240);

  --Using EDR idList and stringList types
  l_ruleids   edr_utilities.id_List;
  l_rulenames edr_utilities.string_List;

  l_application_name varchar2(240);

  l_rulevalues EDR_STANDARD.ameruleinputvalues;
  l_wftype varchar2(240);
  l_wfprocess varchar2(240);
  l_no_enabled_eres_sub NUMBER;
  l_error_event varchar2(240);

  user_data varchar2(2000);
  user_data_placeholder varchar2(40);
  placeholder_position integer;

  MULTIPLE_ERES_SUBSCRIPTIONS EXCEPTION;
  NO_ENABLED_ERES_SUBSCRIPTION  EXCEPTION;
  NO_ERES_SUBSCRIPTION  EXCEPTION;
  --Bug 5724159:Start
  --Define a new Exception to be raised when the signature mode
  -- is set to SHORT ,adhoc signer capability is set to ALL or ADHOC
  --and the number of approvers is 0.
   NO_SIGNERS_DEF_FOR_LITE_MODE EXCEPTION;
  -- Bug 5724159 :End

  --parameters for inter event
  l_parent_event varchar2(240) ;
  l_parent_key varchar2(2000)  ;
  l_parent_erecord_id number   ;

  l_inter_event_mode varchar2(1);
  l_relationship varchar2(200);
  l_trans_value_only varchar2(1);
  l_parent_sub_guid raw(16);
  l_rule_id number;

  --Bug 3161859 : start
  l_change_signer varchar2(32);
  l_change_signer_defined varchar2(1);
  --Bug 3161859 : end

  -- Bug 4197656 : Start
  l_change_signer_evaluate varchar2(1);
  -- Bug 4197656 : End


  l_debug_level number;
  l_ret_code pls_integer;
  l_log_file varchar2(2000);
  l_errbuf varchar2(2000);

  -- Exceptions
  PAGE_FLOW_FAILED    EXCEPTION;
  BAD_RELATIONSHIP_ERROR  EXCEPTION;
  NO_STYLE_SHEET_FOUND EXCEPTION;
  ECX_XML_TO_XML_ERROR EXCEPTION;

  --Bug 3893101: Start
  l_transform_xml varchar2(1);
  TRANSFORM_XML_VAR_ERROR EXCEPTION;
  --Bug 3893101: End

  l_attachment_string_details VARCHAR2(2000);

-- Bug 3567868 Start
   l_source_application_type VARCHAR2(10);
-- Bug 3567868 End
-- Bug 3567868 End
  --   Bug 3761813 : start
   l_redline_required varchar2(30);
   l_snapstatus boolean;
  --  -- Bug 3761813 : end

  --Bug 4122622: Start
  --This variable would hold the comma separated string of child e-record IDs
  --set on the event parameters.
  l_child_erecord_ids VARCHAR2(4000);

  --These variables would indicate whether the parent e-record Id and child e-record
  --Id have been set.
  l_parent_erecord_id_set boolean;
  l_child_erecord_id_set boolean;
  l_child_erecord_ids_set boolean;
  l_url VARCHAR2(500);
  --Bug 4122622: End

  --Bug 4150616: Start
  --This variable would be used to hold the value of the FORCE_ERECORD subscription parameter.
  L_FORCE_ERECORD VARCHAR2(10);
  --The ERES profile option value will be stored in this variable.
  L_ERES_PROFILE_VALUE VARCHAR2(1);
  --Bug 4150616: End

  --Bug 4160412: Start
  L_TEMP_SIGNATURE_MODE      VARCHAR2(10);
  L_SIGNATURE_MODE           VARCHAR2(10);
  L_APPROVER_COUNT           VARCHAR2(128);
  L_APPROVER_LIST           VARCHAR2(4000);
  L_ARE_APPROVERS_VALID      VARCHAR2(1);
  L_INVALID_APPROVERS        VARCHAR2(4000);
  L_CUSTOM_APPROVER_LIST     EDR_UTILITIES.APPROVERS_TABLE;
  L_APPROVER_COUNT_VALUE     NUMBER;
  L_LIST_COUNT               NUMBER;
  L_TEMP_COUNT               NUMBER;
  L_LITE_MODE                BOOLEAN;
  L_REPEATING_APPROVERS      BOOLEAN;
  L_EINITIALS_DEFER_MODE     VARCHAR2(1);
  L_ERES_DEFER_MODE          VARCHAR2(1);
  APPROVING_USERS_PARAMS_ERR EXCEPTION;
  INVALID_APPROVING_USERS    EXCEPTION;
  REPEATING_APPROVERS_ERR    EXCEPTION;
  INVALID_APPR_COUNT_ERR       EXCEPTION;
  INVALID_APPR_COUNT_VALUE_ERR EXCEPTION;
  --Bug 4160412: End

  --Bug 3960236: Start
  --This variable would be used to hold the value of the
  --call back API passed by product teams in XML_GENERATION_API parameter to generate XML
    L_XML_GENERATION_API VARCHAR2(240);
    L_SQL_STR varchar2(4000);
    EMPTY_XML_DOCUMENT EXCEPTION;
    API_EXECUTION_ERROR EXCEPTION;
  --Bug 3960236: End

  --Bug 4577122: Start

  l_valid_regime varchar2(1);
  l_voting_regime varchar2(1);
  l_temp_value VARCHAR2(4000);

  INVALID_FIRST_VOTER_WINS_SETUP EXCEPTION;
  --Bug 4577122: End

BEGIN

  --Bug 4122622: Start
  l_parent_erecord_id_set := false;
  l_child_erecord_id_set := false;
  l_child_erecord_ids_set := false;
  --Bug 4122622: End


  --Bug 4074173 : start
  l_esign_required :='N';
  l_eRecord_required :='N';

  l_STYLE_SHEET_repository := 'ISIGN';
  user_data_placeholder := 'EDR_USER_DATA_xxYG%7#@(765';

  l_parent_event := EDR_CONSTANTS_GRP.g_default_char_param_value;
  l_parent_key := EDR_CONSTANTS_GRP.g_default_char_param_value;
  l_parent_erecord_id := EDR_CONSTANTS_GRP.g_default_num_param_value;

  l_change_signer :='ALL';
  l_change_signer_defined :='N';

  -- Bug 4197656 : Start
  l_change_signer_evaluate := 'N';
  -- Bug 4197656 : End

  l_debug_level :=6;

  --Bug 4074173 : end

  --Bug 4150616: Start
  --We need to fetch the subscrpition parameters irrespective of whether profile option
  --is switched on.
  -- Bug 5639849: Starts
  -- Instead of loading all subscription parameters, just load the following
  -- variables. 1. EDR_AME_TRANSACTION_TYPE 2. EDR_XML_MAP_CODE 3. FORCE_ERECORD
  -- All others either are custom variables or interevent speficand those are
  -- not required to load at this point.
  -- srpuri: We still need to copy parameters whatever workflow can copy.
   l_return_status := wf_rule.setParametersIntoParameterList(p_subscription_guid,p_event);
    l_temp_value := EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_AME_TRANSACTION_TYPE',p_subscription_guid);
    if(l_temp_value is not null) then
       wf_event.AddParameterToList('EDR_AME_TRANSACTION_TYPE',
                                   l_temp_value,
                                   p_event.Parameter_List);
    end if;
    l_temp_value := EDR_INDEXED_XML_UTIL.GET_WF_PARAMS('EDR_XML_MAP_CODE',p_subscription_guid);
    if(l_temp_value is not null) then
      wf_event.AddParameterToList('EDR_XML_MAP_CODE',
                                  l_temp_value,
                                  p_event.Parameter_List);
    end if;
    l_temp_value := EDR_INDEXED_XML_UTIL.GET_WF_PARAMS(EDR_CONSTANTS_GRP.G_FORCE_ERECORD,p_subscription_guid);

    if(l_temp_value is not null) then
      wf_event.AddParameterToList(EDR_CONSTANTS_GRP.G_FORCE_ERECORD,
                                  l_temp_value,
                                  p_event.Parameter_List);
    end if;
    -- Bug 5639849: Ends

  --Fetch the value of the ERES profile option.
  l_eres_profile_value := fnd_profile.value('EDR_ERES_ENABLED');

  --Fetch the value of FORCE_ERECORD.
  l_force_erecord := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.G_FORCE_ERECORD,p_event.Parameter_List);

  --Convert it to upper case for ease in verification later in the code.
  l_force_erecord := upper(l_force_erecord);
  --Bug 4150616: End
  --Bug 5891879: Start
  --Read the source application type
   l_source_application_type := wf_event.getValueForParameter('#WF_SOURCE_APPLICATION_TYPE',p_event.Parameter_List);
  --Bug 5891879 : End
  wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','Start of the rule function');

  --Bug 4150616: Start
  IF l_eres_profile_value = 'Y' OR l_force_erecord = 'Y' THEN
  --Bug 4150616: End

    --Bug 4160412: Start
    L_LITE_MODE := false;
    --Bug 4160412: End

    --IF l_return_status='SUCCESS' THEN
      /* Check for User Defined Parameters. We only require AME parameter for now */
      l_ame_transaction_type := NVL(wf_event.getValueForParameter('EDR_AME_TRANSACTION_TYPE',p_event.Parameter_List),
                                    P_EVENT.getEventName());
   -- END IF;

    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','AME transaction Type :'||l_ame_transaction_type );

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_START_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
      FND_MESSAGE.SET_TOKEN('AME_TYPE',l_ame_transaction_type);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End

    --ER # 2966866 start

    --get the PARENT_EVENT_NAME parameter
    l_parent_event := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.g_parent_event_name ,p_event.Parameter_List);
    wf_log_pkg.string(1, 'EDR_PSIG_rule.psig_rule','Parent Event Name:'||l_parent_event);

    --get the PARENT_EVENT_KEY parameter
    l_parent_key := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.g_parent_event_key,p_event.Parameter_List);

    wf_log_pkg.string(1, 'EDR_PSIG_rule.psig_rule','Parent Event Key:'||l_parent_key);

    --get the PARENT_ERECORD_ID parameter
    l_parent_erecord_id := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.g_parent_erecord_id,p_event.Parameter_List);

    wf_log_pkg.string(1, 'EDR_PSIG_rule.psig_rule','Parent eRecord ID:'||l_parent_erecord_id);

    --find out if the requisite parameters are passed in the payload so as
    --to make it an inter event. either the parent event name AND parent event
    --key have to be passed in the payload OR all three, to make this an inter
     --event context

    IF (l_parent_event <> EDR_CONSTANTS_GRP.g_default_char_param_value
    AND l_parent_key <> EDR_CONSTANTS_GRP.g_default_char_param_value )THEN

      l_inter_event_mode := 'Y';

    ELSIF (l_parent_erecord_id <> EDR_CONSTANTS_GRP.g_default_num_param_value) THEN

      l_inter_event_mode := 'Y';

    ELSE

      l_inter_event_mode := 'N';

    END IF;

    wf_log_pkg.string(1, 'EDR_PSIG_rule.psig_rule','Inter Event Mode: '||l_inter_event_mode);

    if (l_inter_event_mode = 'Y') then
      --Diagnostics Start
      if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_INTER_EVENT_EVT');
        FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
        FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
        FND_MESSAGE.SET_TOKEN('PARENT_NAME',nvl(l_parent_event,'NULL'));
        FND_MESSAGE.SET_TOKEN('PARENT_KEY',nvl(l_parent_key,'NULL'));
        FND_MESSAGE.SET_TOKEN('PARENT_EREC_ID',l_parent_erecord_id);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                        'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                        FALSE
                       );
      end if;
      --Diagnostics End


      --
      -- Start Bug Fix 3355468
      -- to resolve this issue we need to modify following code
      -- to do following
      --   1. Verify how many ERES subscriptions are available at parent event level
      --   2. If only one subscription is available then do nothing.
      --   3. If more than one ERES subscriptions are enabled then raise error.
      --   4. If more than one ERES subscription is present at parent level and all are disabled raise ERROR
      --   5. if more than one ERES subscription is present at parent level but only one ERES subscription is
      --      enabled then do nothing.
      -- find out how many ERES subscriptions are
      -- present for the parent event
      --

      select count(*)  INTO l_no_enabled_eres_sub
      from wf_events a, wf_event_subscriptions b
      where a.GUID = b.EVENT_FILTER_GUID
      and a.name = l_parent_event
      and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
	--Bug No 4912782- Start
	and b.source_type = 'LOCAL'
	and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	--Bug No 4912782- End

      IF l_no_enabled_eres_sub > 1 then

        --
        -- Start Bug Fix 3078516
        -- Verify is more than one active ERES subscriptions are present
        -- for parent event. if more than one ERES subscription is ENABLED
        -- Raise Multiple ERES Subscriptions error
        --
        select count(*)  INTO l_no_enabled_eres_sub
          from wf_events a, wf_event_subscriptions b
          where a.GUID = b.EVENT_FILTER_GUID
          and a.name = l_parent_event
          and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
          and b.STATUS = 'ENABLED'
	    --Bug No 4912782- Start
	    and b.source_type = 'LOCAL'
	    and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	    --Bug No 4912782- End

        IF l_no_enabled_eres_sub > 1 THEN
          l_error_event := l_parent_event;
          RAISE MULTIPLE_ERES_SUBSCRIPTIONS;
        ELSIF l_no_enabled_eres_sub = 0 THEN
          l_error_event := l_parent_event;
          RAISE NO_ENABLED_ERES_SUBSCRIPTION;
        END IF;

      ELSIF l_no_enabled_eres_sub = 0 THEN
        l_error_event := l_parent_event;
        RAISE NO_ERES_SUBSCRIPTION;
      END IF;
      --
      -- end of bug fix 3355468
      --

      --get the guid of the parent event
      l_parent_sub_guid := EDR_ERES_EVENT_PVT.GET_SUBSCRIPTION_GUID(p_event_name  => l_parent_event);

      l_relationship := upper(EDR_INDEXED_XML_UTIL.GET_WF_PARAMS(p_event.event_name,l_parent_sub_guid));

      --Diagnostics Start
      if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_INTEREVENT_REL_EVT');
        FND_MESSAGE.SET_TOKEN('CHILD_NAME',p_event.getEventName());
        FND_MESSAGE.SET_TOKEN('PARENT_EVENT',l_parent_event);
        FND_MESSAGE.SET_TOKEN('RELATION',l_relationship);
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                        'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                        FALSE
                       );
      end if;
      --Diagnostics End

      wf_log_pkg.string(1, 'EDR_PSIG_rule.psig_rule','Relationship between parent and child:'||l_relationship);

      --l_relationship can have three possible values
      --EVALUATE_NORMAL, IGNORE_SIGNATURE, ERECORD_ONLY
    end if;
    --ER # 2966866 end

    --
    -- Verify is more than one active ERES subscriptions are present
    -- for current event. if more than one ERES subscription is ENABLED
    -- Raise Multiple ERES Subscriptions error
    --
    select count(*)  INTO l_no_enabled_eres_sub
      from wf_events a, wf_event_subscriptions b
      where a.GUID = b.EVENT_FILTER_GUID
      and a.name = p_event.event_name
      and b.RULE_FUNCTION='EDR_PSIG_RULE.PSIG_RULE'
      and b.STATUS = 'ENABLED'
	--Bug No 4912782- Start
	and b.source_type = 'LOCAL'
	and b.system_guid = hextoraw(wf_core.translate('WF_SYSTEM_GUID')) ;
	--Bug No 4912782- End

    IF l_no_enabled_eres_sub > 1 THEN
      l_error_event := p_event.event_name;
      RAISE MULTIPLE_ERES_SUBSCRIPTIONS;
    END IF;

    /* AME Processing */
    /* Select APPLICATION_ID of the Event. This is required by AME. Assumption made here
       is OWNER_TAG will always be set to application Short Name */

    SELECT application_id,APPLICATION_SHORT_NAME into l_application_id,l_application_code
      FROM FND_APPLICATION A, WF_EVENTS B
      WHERE A.APPLICATION_SHORT_NAME = B.OWNER_TAG
      AND B.NAME=P_EVENT.getEventName( );

    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Application_id :'||l_application_id );
    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','event key :'||P_EVENT.getEventKey( ));
    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Trans Type :'||NVL(l_ame_transaction_type,P_EVENT.getEventName( )) );

    /* AME Enhancement Code. Determine if singature is need or not and also get approvers  */
    -- if the inter event mode is on and the relationship is ERECORD_ONLY then
    -- also we need to go to AME to get the transaction type
    -- the transaction type would help in determining the stylesheet to be applied
    -- to create the erecord

    --ER # 2966866 start

    --Bug 3667036 : Start

    --Obtain event details
    l_event_data:=p_event.getEventData();
    l_event_name:=p_event.getEventName();
    l_event_key:=p_event.getEventKey();
    l_xml_map_code := NVL(wf_event.getValueForParameter('EDR_XML_MAP_CODE',p_event.Parameter_List),
                          P_EVENT.getEventName( ));


    --Insert into temp table. This is done because a handle to a CLOB created through JDBC
    --can be obtained only if it stored in a table and the table queried.
    insert into EDR_FINAL_XML_GT(event_name,event_key,event_xml)
      values(l_event_name,l_event_key,l_event_data);

    select event_xml
    into l_event_data
    from EDR_FINAL_XML_GT;

    if dbms_lob.getlength(l_event_data)>0 then
      --Diagnostics Start
      if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_DATA_SOURCE_EVT');
        FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
        FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
        FND_MESSAGE.SET_TOKEN('DATA_SOURCE','VIEW OBJECT');
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                        'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                        FALSE
                       );
      end if;
      --Diagnostics End

      --insert the erecord id into the temp table
      --This would be picked up by the procedures called by the XML Map for attacments
      --Delete the global temp table before inserting a row
      delete edr_erecord_id_temp;

      SELECT EDR_ERECORDS_S.NEXTVAL into l_edr_Event_id from DUAL;
      INSERT into edr_erecord_id_temp (document_id) values (l_edr_Event_id);
      wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','eRecord id: '||l_edr_Event_id||' will be sent to ECX');

      --Bug 3893101: Start
      --Obtain the value of transform xml parameter.
      l_transform_xml := NVL(wf_event.getValueForParameter('TRANSFORM_XML',p_event.Parameter_List),
                                                           'Y');
      --If it is set to 'Y' then generate the XML as required.
      if l_transform_xml = 'Y' then
        --Generate the customised Erecord using XML Gateway
        ecx_inbound_trig.processXML
        (i_map_code    => l_xml_map_code,
         i_payload     => l_event_data,
         i_debug_level => l_debug_level,
         i_ret_code    => l_ret_code,
         i_errbuf      => l_errbuf,
         i_log_file    => l_log_file,
         o_payload     => l_erecord_data
        );

        wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','ecx inbound trig called');

      --If it is set to 'N' then do not perform the XML to XML transformation.
      --Take the source XML as the target itself.
      elsif l_transform_xml = 'N' then
        --We need to recreate the event CLOB in another XML CLOB as
        --the CLOB obtained from the event definition cannot be modified.
        DBMS_LOB.CREATETEMPORARY(l_erecord_data, TRUE, DBMS_LOB.SESSION);
        DBMS_LOB.COPY(l_erecord_data,l_event_data,DBMS_LOB.GETLENGTH(l_event_data));
        l_attachment_string_details := wf_event.getValueForParameter('EDR_PSIG_ATTACHMENT',p_event.Parameter_List);
        if l_attachment_string_details is not null then
          EDR_ATTACHMENTS_GRP.ADD_ERP_ATTACH(p_attachment_string => l_attachment_string_details);
        end if;

        wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','no ecx transformation required');
      else
        raise TRANSFORM_XML_VAR_ERROR;
      end if;
      --Bug 3893101: End

      --If the return code from ECX is a value other than 0 then
      --an error has occurred
      if(l_transform_xml = 'Y' and l_ret_code <> 0) then
        raise ECX_XML_TO_XML_ERROR;
      end if;

      --Bug 3893101: Start
      --Check for transform xml parameter before writing into diagnostics.
      if l_transform_xml = 'Y' then

        --Ensure that the ECX error handling is put here.
        --Diagnostics Start
        if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_ECX_GEN_EVT');
          FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
          FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
          FND_MESSAGE.SET_TOKEN('XML_MAP_CODE',l_xml_map_code);
          FND_MESSAGE.SET_TOKEN('TRANS','XML TO XML');
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                          'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                          FALSE
                         );
        end if;
        --Diagnostics End
      else
        --Diagnostics Start
        if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_NO_XML_TRANS_EVT');
           FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
           FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
           FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                           'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                           FALSE
                          );
        end if;
        --Diagnostics End

      end if;
      --Bug 3893101: End

      --update the global temp table with the final xml obtained from ECX
      --this would be the xml payload of the e-record
      update EDR_FINAL_XML_GT
      set event_xml = l_erecord_data
      where event_name = l_event_name
      and event_key = l_event_key;

      wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','updated edr_final_xml_gt with the final xml');
    else
      --Diagnostics Start
      if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_DATA_SOURCE_EVT');
        FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
        FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
        FND_MESSAGE.SET_TOKEN('DATA_SOURCE','DATABASE');
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                        'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                        FALSE
                       );
      end if;
      --Diagnostics End

    end if;
    --Bug 3667036 : End


    -- Bug 4126932 : Start
    -- No need to call AME API in case of Inter Event and relationship is E-Record

    -- Bug 2674799 : start
    if (l_inter_event_mode = 'Y' and l_relationship = EDR_CONSTANTS_GRP.g_erecord_only) then
      l_trans_value_only := 'Y';
      wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','no need to find out approvers form ame as interevent relationship forces erecord_only');
    else
      EDR_UTILITIES.GET_APPROVERS(P_APPLICATION_ID    => l_application_id,
                                  P_TRANSACTION_ID    => p_event.getEventKey(),
                                  P_TRANSACTION_TYPE  => NVL(l_ame_transaction_type,p_event.getEventName()),
                                  X_approvers         => approverList,
                                  X_rule_Ids          => l_ruleids,
                                  X_rule_Descriptions => l_rulenames);
      wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','called ame to get the approvers');
    END IF ;
    -- Bug 2674799: end

    -- Bug 4126932 : END

    --clean up temp table
    delete from EDR_FINAL_XML_GT where event_name = l_event_name and event_key=l_event_key;

    wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','AME API Called. Total Approver '||approverlist.count);

    -- get the Application Name
    select ltrim(rtrim(application_name)) into l_application_name
    from ame_Calling_Apps
    where FND_APPLICATION_ID=l_application_id and
    TRANSACTION_TYPE_ID=NVL(l_ame_transaction_type,P_EVENT.getEventName( ))
    --Bug 4652277: Start
    --and end_Date is null;
    and sysdate between START_DATE AND NVL(END_DATE, SYSDATE);
    --Bug 4652277: End

    --Bug fix 3168963 when eRecord_Only is subscription parameter we should not
    --look for number of approvers
    -- Bug 3567868 :Start
     --Bug 5724159 :Start
        --Added an extra 'AND' condtion to ensure that no processing takes place if no rules are defined.
    IF ((approverlist.count = 0)
    and (nvl(l_relationship,'EDR') <> EDR_CONSTANTS_GRP.g_erecord_only) and l_ruleids.count >0 )then

      --Bug 5724159 :End
      --Diagnostics Start
      if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_NO_APPROVERS_EVT');
        FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
        FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                        'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                        FALSE
                       );
      end if;
      --Diagnostics End
      l_source_application_type := wf_event.getValueForParameter('#WF_SOURCE_APPLICATION_TYPE',p_event.Parameter_List);
      -- Bug 3214495 : Start

      EDR_STANDARD.GET_AMERULE_INPUT_VARIABLES
      (transactiontypeid  => NVL(l_ame_transaction_type,P_EVENT.getEventName()),
       ameruleid          => -1,
       amerulename        => null,
       ameruleinputvalues => l_rulevalues);

      --Bug 3214495 : End

      --Bug 4197656 : Start

      for i in 1..l_rulevalues.count loop
        if l_rulevalues(i).input_name = 'ESIG_REQUIRED' then

          l_esign_required:= upper(l_rulevalues(i).input_value);

        elsif l_rulevalues(i).input_name = 'EREC_REQUIRED' then

          l_erecord_required:= upper(l_rulevalues(i).input_value);

        elsif l_rulevalues(i).input_name = 'EREC_STYLE_SHEET' then

          l_STYLE_SHEET := l_rulevalues(i).input_value;

        elsif l_rulevalues(i).input_name = 'EREC_STYLE_SHEET_VER' then

          l_STYLE_SHEET_VER := l_rulevalues(i).input_value;

        elsif l_rulevalues(i).input_name = 'CHANGE_SIGNERS' then

          l_change_signer:= upper(l_rulevalues(i).input_value);
          l_change_signer_evaluate := 'Y';

        --Bug 3761813 : start

        elsif l_rulevalues(i).input_name = 'REDLINE_REQUIRED' then

          l_redline_required := upper(l_rulevalues(i).input_value);
        --Bug 3761813: End

        --Bug 4160412: Start
        --Set the signature mode parameter if it is set.
        elsif l_rulevalues(i).input_name = EDR_CONSTANTS_GRP.G_SIGNATURE_MODE then

          l_signature_mode := upper(l_rulevalues(i).input_value);

        --Bug 4160412: End



        end if;
      end loop;
      -- If E- Signature is required and CHANGE_SIGNER is ALL or ADHOC
      -- and source application is  not 'DB'' the set l_change_signer_defined
      -- else return the process .

      --Bug 4150616: Start
      --This "IF" condition needs to modified to check if the profile option is switched on.
      --If the profile option has been switched off, then the force e-record option has been used.
      --Hence in that scenario, the if condition should fail.
      IF (l_esign_required ='Y' AND l_change_signer_evaluate = 'Y'
      AND (l_change_signer = 'ALL' OR  l_change_signer = EDR_CONSTANTS_GRP.g_change_signer_adhoc)
      AND l_source_application_type not in (EDR_CONSTANTS_GRP.g_db_mode , EDR_CONSTANTS_GRP.g_msca_mode)
      AND l_eres_profile_value = 'Y') THEN
        l_change_signer_defined := 'Y';
      --Bug 4150616: End

      --Bug 4150616: Start
      --If force_erecord is set to 'Y', then add the "FORCE_ERECORD_USED" parameter into the event list.
      --Otherwise exit the rule function with a return status of "SUCCESS". (as before).

      --Bug 4543216: Start
      ELSIF (l_esign_required = 'Y' and l_signature_mode = EDR_CONSTANTS_GRP.G_ERES_LITE
             AND l_source_application_type not in (EDR_CONSTANTS_GRP.g_db_mode,EDR_CONSTANTS_GRP.g_msca_mode) AND l_eres_profile_value = 'Y') then
      --Bug 4543216: End
        l_lite_mode := true;
      ELSIF l_force_erecord  = 'Y' then
        --Add the parameter into the event list.
        wf_event.AddParameterToList(EDR_CONSTANTS_GRP.G_FORCE_ERECORD_USED, 'Y',p_event.Parameter_List);
        --Bug 4150616: End
      --Bug 5724159  : Start
      --The Control should not return back without generating E-Record
        /* ELSE*/
        /* Terminate the process . Nothing has to be done */
       /*  return 'SUCCESS';*/
       --Bug 5724159   : End

      END IF;
    END IF;

    -- Bug 4197656 : End
    -- Bug 3567868 :END
    -- bug 7154935
    -- Added OR condition to fix eRecord Generation issue when Force ERecord
    -- is used but no rule is defined.
    --ER # 2966866 start
    if (l_inter_event_mode = 'Y' and l_relationship = EDR_CONSTANTS_GRP.g_erecord_only)
       OR (l_force_erecord = 'Y' and l_ruleids.count = 0)
    then
      l_trans_value_only := 'Y';
      -- SRPURI : Bug fix 3168963 Added following code
      -- Deletes data in Rule Id and rulename arrays as these are not used if relationship between
      -- events is 'ERECORD_ONLY' and initialize array with dummay values assumin -1 never be a valid
      -- row in EDR_AMERULE_INPUT_VAR and null for rule name since we need to pass rulename to
      -- get AME input variable values call
      -- following statements are valid only when relationship between events is 'ERECORD_ONLY'
      -- if you are planning to use this if you are planning to overload this if condition for
      -- some other purpose make sure it is not breaking ERECORD_ONLY Functionality
      l_ruleids.delete;
      l_rulenames.delete;
      l_ruleids(1) := -1;
      l_rulenames(1) := Null;
      --
      -- when event 2 is raised in the context of event 1 and subscription parameter is
      -- event1=ERECORD_ONLY then we need to capture eRecord unconditionaly
      -- by setting l_erecord_required = 'Y' we will achieve this.
      --
      l_erecord_required := 'Y';
      wf_log_pkg.string(3, 'EDR_PSIG_rule.psig_rule','Get Only the input variables at txn level');
    end if;
    --ER # 2966866 end

    for i in 1..l_ruleids.count loop

      --ER # 2966866 start
      if (l_trans_value_only = 'Y') then
        l_rule_id := -1;
      else
        l_rule_id := l_ruleids(i);
      end if;

      wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Rule_id: '||l_ruleids(i)||' Rule '||l_rulenames(i));

      -- Bug 3214495 : Start

      EDR_STANDARD.GET_AMERULE_INPUT_VARIABLES( transactiontypeid =>NVL(l_ame_transaction_type,P_EVENT.getEventName( )),
                                                ameruleid =>l_ruleids(i),
                                                amerulename=>l_rulenames(i),
                                                ameruleinputvalues=>l_rulevalues);

      -- Bug 3214495 : End

      wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','Total Input Values '||l_rulevalues.count );
      if l_rulevalues.count > 0 then
        for i in 1..l_rulevalues.count loop
          if l_rulevalues(i).input_name = 'ESIG_REQUIRED' then
            l_rule_esign_required:=upper(l_rulevalues(i).input_value);
            if ( upper(l_esign_required)='N' and l_rule_esign_required ='Y') then
              l_esign_required:= l_rule_esign_required;
            end if;
          elsif l_rulevalues(i).input_name = 'EREC_REQUIRED' then
            l_rule_erecord_required:=upper(l_rulevalues(i).input_value);
            if ( upper(l_erecord_required)='N' and l_rule_erecord_required ='Y') then
              l_erecord_required:= l_rule_erecord_required;
            end if;
          elsif l_rulevalues(i).input_name = 'EREC_STYLE_SHEET' then
            l_temp_style_sheet:= l_rulevalues(i).input_value;
            -- Bug 3761813 : start
          elsif l_rulevalues(i).input_name = 'REDLINE_REQUIRED' then
            l_redline_required := upper(l_rulevalues(i).input_value);
            -- Bug 3761813 : end
          elsif l_rulevalues(i).input_name = 'EREC_STYLE_SHEET_VER' then
            l_temp_style_sheet_ver:= l_rulevalues(i).input_value;
          -- Bug 3161859 : Start
          elsif l_rulevalues(i).input_name = 'CHANGE_SIGNERS' then
            l_change_signer_defined := 'Y';
            if ( upper(l_change_signer)='ADHOC' and upper(l_rulevalues(i).input_value) ='NONE') then
              l_change_signer:= l_rulevalues(i).input_value;
            elsif ( upper(l_change_signer)='ALL' and upper(l_rulevalues(i).input_value) ='NONE') then
              l_change_signer:= l_rulevalues(i).input_value;
            elsif ( upper(l_change_signer)='ALL' and upper(l_rulevalues(i).input_value) ='ADHOC') then
              l_change_signer:= l_rulevalues(i).input_value;
            end if;
          -- Bug 3161859 : End

          --Bug 4160412: Start
          --Get the signature mode parameter if found.
          elsif l_rulevalues(i).input_name = EDR_CONSTANTS_GRP.G_SIGNATURE_MODE then
            l_temp_signature_mode := l_rulevalues(i).input_value;
          --Bug 4160412: End
          end if;
        end loop;
      end if;
      -- Begin Bug 3334148
      -- Determine if sytlesheet belongs to most deterministic Rule
      -- Bug 3456530 : Start
      if (l_rule_erecord_required ='Y' and l_esign_required ='N') then
      -- Bug 3456530 : End
        l_style_sheet:=l_temp_style_sheet;
        l_style_sheet_ver:=l_temp_style_sheet_ver;
      end if;
      if l_rule_esign_required ='Y' then
        l_style_sheet:=l_temp_style_sheet;
        l_style_sheet_ver:=l_temp_style_sheet_ver;

        --Bug 4160412: Start
        l_signature_mode := l_temp_signature_mode;
        --Bug 4160412: End
      end if;
      --End Bug 3334148
      --Start Bug 5158772
      IF l_force_erecord  = 'Y' then
       l_style_sheet := l_temp_style_sheet;
       l_style_sheet_ver := l_temp_style_sheet_ver;
       wf_log_pkg.string(3, 'EDR_PSIG_rule.psig_rule','Force Ereocrd setting style sheet and version');
     end if;
      --End Bug 5158772
    end loop;

    -- Bug 3161859 : Start
    if (l_change_signer_defined = 'N') then
      l_change_signer:= 'NONE';
    end if;
    -- Bug 3161859 : End

    --ER # 2966866 start
    if (l_inter_event_mode = 'Y' and(l_relationship = EDR_CONSTANTS_GRP.g_erecord_only OR
        l_relationship = EDR_CONSTANTS_GRP.g_ignore_signature )) then

      l_esign_required := 'N';
      -- Bug : 3499326 - start
      l_style_sheet := l_temp_style_sheet;
      l_style_sheet_ver := l_temp_style_sheet_ver;
      -- Bug : 3499326 - end

      wf_log_pkg.string(3, 'EDR_PSIG_rule.psig_rule','Inter Event Mode and No eSignature');
    end if;
    --ER # 2966866 end


    -- Bug 3170251 : Start Get the File Extension of Template Associated with this event
    -- Bug 3456399 : Start - get the last three characters from file name
    L_STYLE_SHEET_TYPE := UPPER(SUBSTR(L_STYLE_SHEET,LENGTH(L_STYLE_SHEET)-2,LENGTH(L_STYLE_SHEET)));
    -- Bug 3456399 : End
    --Bug: 3170251 : End

    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Signature Required :'||l_esign_required);
    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','eRecord Required   :'||l_erecord_required);
    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Style Sheet :'||l_style_sheet);
    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','StyleSheet Version :'||l_style_sheet_ver);
    wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','StyleSheet repository :'||l_style_sheet_repository);

    --Diagnostics Start
    if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_PARAM_LIST_EVT');
      FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
      FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
      FND_MESSAGE.SET_TOKEN('ESIG_VALUE',l_esign_required);
      FND_MESSAGE.SET_TOKEN('EREC_VALUE',l_erecord_required);
      FND_MESSAGE.SET_TOKEN('STYLE_SHEET',l_style_sheet);
      FND_MESSAGE.SET_TOKEN('STYLE_VER',l_style_sheet_ver);
      FND_MESSAGE.SET_TOKEN('STYLE_REP',l_style_sheet_repository);
      FND_MESSAGE.SET_TOKEN('XML_MAP_CODE',l_xml_map_code);
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End


    --Bug 4150616: Start
    --We want to create the e-record for any the following conditions being true.
    --1. ESIG_REQUIRED = Y
    --2. EREC_REQUIRED = Y
    --3. Subscription parameter FORCE_ERECORD = Y
    IF (upper(l_esign_required)='Y' OR upper(l_erecord_required)='Y' or l_force_erecord = 'Y') THEN
      /* Read  the Require Parameter */

      --If this condition is true then it means that the e-record is being created
      --because FORCE_ERECORD is set to Y and either the profile option is switched off
      --or (ESIG_REQUIRED=N and EREC_REQUIRED = N).
      --Hence we would add an addittional  parameter to the event payload which in
      --turn is added to the doc params which indicates that the e-record is being
      --created because FORCE_ERECORD is set to Y.
      --This parameter is named "FORCE_ERECORD_USED".
      if l_eres_profile_value = 'N' OR (upper(l_esign_required) = 'N' and upper(l_erecord_required) = 'N') then
        wf_event.AddParameterToList(EDR_CONSTANTS_GRP.G_FORCE_ERECORD_USED,'Y',p_event.Parameter_List);
      end if;
      --Bug 4150616: End

      l_audit_group  := NVL(wf_event.getValueForParameter('EDR_AUDIT_GROUP',p_event.Parameter_List),
                            P_EVENT.getEventName( ));

      wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','XML Map Code :'||l_xml_map_code );
      wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Audit Group  :'||l_audit_group );
      wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','Setting ECX parameter');

      /* Set Additional Parameters required by Esignature */
      /* wf_event.AddParameterToList('SUB_GUID', p_subscription_guid,p_event.Parameter_List);  Subscription ID */
      wf_event.AddParameterToList('ECX_MAP_CODE', l_xml_map_code,p_event.Parameter_List); /* XML Map Code*/
      wf_event.AddParameterToList('ECX_DOCUMENT_ID', P_EVENT.getEventKey( ),p_event.Parameter_List); /* XML Document ID*/
      wf_event.AddParameterToList('TEXT_XSLNAME', l_style_sheet,p_event.Parameter_List); /* Style Sheet*/
      wf_event.AddParameterToList('TEXT_XSLVERSION', l_style_sheet_ver,p_event.Parameter_List); /* Style Sheet*/
      wf_event.AddParameterToList('HTML_XSLNAME', NULL,p_event.Parameter_List); /* Style Sheet*/
      wf_event.AddParameterToList('HTML_XSLVERSION', NULL,p_event.Parameter_List); /* Style Sheet*/
      wf_event.AddParameterToList('APPLICATION_CODE', lower(l_application_code),p_event.Parameter_List); /* Style Sheet*/
      wf_event.AddParameterToList('EDR_SIGN_REQUIRED', l_esign_required,p_event.Parameter_List); /* Signature Required*/
      wf_event.AddParameterToList('EDR_EREC_REQUIRED', l_erecord_required,p_event.Parameter_List); /* eRecord Required*/
      --Bug 3761813 : start
      wf_event.AddParameterToList('REDLINE_REQUIRED',  nvl(l_redline_required,'N'),p_event.Parameter_List); /* redline Required*/
      --Bug 3761813 : END

      -- Bug 3161859 : Start
      -- this parameter would be used to show whether or not to display
      -- the Update Signer button wouuld be enabled or disabled
      wf_event.AddParameterToList('EDR_CHANGE_SIGNERS', l_change_signer,p_event.Parameter_List); /* Change Signer Required*/
      -- Bug 3161859 : End

      -- Bug 3170251 : Start - Store EREC_TEMPLATE_TYPE in the event parameter list so that its available throughout
      --               the rule function and pageflow till the workflow is alive for this event
      wf_event.AddParameterToList('EREC_TEMPLATE_TYPE', l_style_sheet_type,p_event.Parameter_List); /* Template Type */
      -- Bug 3170251 : End

       -- Bug 5158510 :start
       wf_event.AddParameterToList(EDR_CONSTANTS_GRP.G_SIGNATURE_MODE, l_signature_mode,p_event.Parameter_List);
       -- Bug 5158510 :end
      wf_log_pkg.string(1, 'EDR_PSIG_RULE.psig_rule','ECX  Parameter set have been set' );

      /* Generate XML Document */
      wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','Calling ECX Standard package to generate XML' );
      -- Bug 3960236 : Start
      -- Fetch the payload parameter
         L_XML_GENERATION_API := wf_event.getValueForParameter('XML_GENERATION_API',p_event.Parameter_List);

      -- Bug 3960236 : end
      --Bug 3667036 : Start
      --if event data is not null then don't call XML gateway again
      if dbms_lob.getlength(l_event_data) > 0 then
        L_XML_DOCUMENT := l_erecord_data;
      -- Bug 3960236 : Start
      elsif L_XML_GENERATION_API is NOT NULL then
        -- Check if call back function has been passed to generate XML document by product team
        begin
            --bug 4730592: start
            --changed the way the callback api is called dynamically
            --L_SQL_STR:= 'select '|| l_xml_generation_api || ' from dual';
            --execute immediate L_SQL_STR into L_XML_DOCUMENT;
            execute immediate 'begin :1:= '||l_xml_generation_api ||'; end;'
            using out l_xml_document;
            --bug 4730592: end
            if  l_XML_DOCUMENT is NULL then
                raise EMPTY_XML_DOCUMENT;
            end if;
        exception
        when others then
          raise API_EXECUTION_ERROR;
        end;

        --Bug 4529417: Start
        --We need to obtain the next sequence value from EDR_ERECORDS_S.

        --insert the erecord id into the temp table
        --This would be picked up by the procedures called by the XML Map for attacments
        --Delete the global temp table before inserting a row
        delete edr_erecord_id_temp;

        --select Unique event Id to be posted in temp tables
        SELECT EDR_ERECORDS_S.NEXTVAL into l_edr_Event_id from DUAL;

        INSERT into edr_erecord_id_temp (document_id) values (l_edr_Event_id);

        --Obtain the attachment string parameter.
        l_attachment_string_details := wf_event.getValueForParameter('EDR_PSIG_ATTACHMENT',p_event.Parameter_List);

        --If the attachment string exists then call the attachment API to create the attachments.
        if l_attachment_string_details is not null then
          EDR_ATTACHMENTS_GRP.ADD_ERP_ATTACH(p_attachment_string => l_attachment_string_details);
        end if;
        --Bug 4529417: End




       -- Bug 3960236 : end
      else
        --otherwise call XML gateway
        --insert the erecord id into the temp table
        --This would be picked up by the procedures called by the XML Map for attacments
        --Delete the global temp table before inserting a row
        delete edr_erecord_id_temp;

        --select Unique event Id to be posted in temp tables
        SELECT EDR_ERECORDS_S.NEXTVAL into l_edr_Event_id from DUAL;


        --Bug 3761813 : start
        --Bug 4306292: Start
        --Commenting changes made for red lining.

          if ( nvl(l_redline_required,'N') = 'Y') then
            l_snapstatus:= PRE_TX_SNAPSHOT(l_edr_Event_id,l_xml_map_code,P_EVENT.getEventKey());
            wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','After Calling Snapshot to generate XML'||P_EVENT.getEventKey( ));
          END IF;
        --Bug 4306292: End
        --   Bug 3761813 : end

        INSERT into edr_erecord_id_temp (document_id) values (l_edr_Event_id);
        wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','eRecord id: '||l_edr_Event_id||' has been sent to ECX');

        L_XML_DOCUMENT:=ECX_STANDARD.GENERATE(p_event_name     => P_EVENT.getEventName(),
                                              p_event_key      => P_EVENT.getEventKey(),
                                              p_parameter_list => p_event.Parameter_List);

        --Diagnostics Start
        if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_ECX_GEN_EVT');
          FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
          FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
          FND_MESSAGE.SET_TOKEN('XML_MAP_CODE',l_xml_map_code);
          FND_MESSAGE.SET_TOKEN('TRANS','DB TO XML');
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                          'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                          FALSE
                         );
        end if;
        --Diagnostics End

      end if;
      --Bug 3667036 : End

      wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','XML Document Generated' );

      --Bug 5724159  :Start
	    --When the number of approvers is 0,Adhoc signer capability is ALL or ADHOC and the
	    --Signature mode is SHORT,Error message needs to displayed. E-Record will not be captured in this scenario.
      IF(approverlist.count=0 and l_change_signer_defined ='Y' AND  l_change_signer <>'NONE' and l_signature_mode='SHORT') THEN
          RAISE NO_SIGNERS_DEF_FOR_LITE_MODE;
      END IF;
     --Bug 5724159  :End

      --Bug 3437422: Start
      --call an api that would find out of the xml contains the user_data
      --placeholder and replace it with the actual contents of the user_data
      --node.
      edr_utilities.replace_user_data_token(l_xml_document);
      --Bug 3437422: End
      --To make eRecord generation storing autonomous
      --Moved all of the following code in this IF clause
      --to STROE_ERECORD Local Procedure
      --
      -- Bug Fix 3143107
      -- Removed elsif l_erecord_required = Y clause as we already know that
      -- we need to generate eRecord irrespective of l_erecord_required value
      -- we will use l_esign_required required in STORE_ERECORD to move the eRecord
      -- status to 'COMPLETE'(l_esign_required = 'N') or 'ERROR' (l_esign_required ='Y')

      STORE_ERECORD(p_XML_DOCUMENT            => l_XML_DOCUMENT,
                    p_style_sheet_repository  => l_style_sheet_repository,
                    p_style_sheet             => l_style_sheet,
                    p_style_sheet_ver         => l_style_sheet_ver,
                    p_application_code        => l_application_code,
                    p_edr_event_id            => l_edr_event_id ,
                    p_esign_required          => l_esign_required,
                    p_subscription_guid       => p_subscription_guid,
                    x_event                   => p_event);
      --Bug 4590037
      --Set the XML document to CLOB datatype of the event
      P_EVENT.setEventData(L_XML_DOCUMENT);
      --Bug 4590037

      --Bug 4150616: Start
      --Start the workflow process only if the profile option is switched on.
      IF upper(l_esign_required)='Y' and l_eres_profile_value = 'Y' THEN
      --Bug 4150616: End

        --Bug 3761813 : start
        --Bug 4306292: Start
        --Commenting changes made for red lining.
         if (l_style_sheet_type = 'XSL' and nvl(l_redline_required,'N') = 'Y' ) then
            select DIFF_XML into L_XML_DOCUMENT  from EDR_REDLINE_TRANS_DATA  where EVENT_ID  = l_edr_event_id ;
            -- Bug 5167207  : start
            --Set the XML document to CLOB datatype of the event
            P_EVENT.setEventData(L_XML_DOCUMENT);
            -- Bug 5167207  : end
         end if;
        --Bug 4306292: End
        --Bug 3761813 : end

        wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','XML Document Set to event Data' );

        /* GET Approver List.
        ame_api.getAllApprovers(applicationIdIn=>l_application_Id,
                                transactionIdIn=>P_EVENT.getEventKey( ),
                                transactionTypeIn=>NVL(l_ame_transaction_type,P_EVENT.getEventName( )),
                                approversOut=>approverList); */

        --Diagnostics Start
        if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_APPROVER_COUNT_EVT');
          FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
          FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
          FND_MESSAGE.SET_TOKEN('COUNT',approverList.count);
          FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                          'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                          FALSE
                         );
        end if;
        --Diagnostics End
        --Bug 5724159  : Start
          /*check whether number of approvers is zero,Change signer property is defined and its value is
            NONE, List Of signers should not be launched in this scenario, return success*/

	IF (approverList.count=0 AND l_change_signer_defined ='Y' AND  l_change_signer ='NONE') THEN
	     return 'SUCCESS' ;
	 END IF;
       --Bug 5724159  : End

        -- BUG 3567868 Start
        -- IF No Approver but Change Signer is 'ADHOC' or 'ALL'
        IF ( (approverList.count > 0)  OR (upper(l_change_signer_defined) = 'Y') or l_lite_mode) THEN
          -- BUG  3567868 END


          --Bug 4577122: Start
          --validate the voting regime and then proceed
          validate_voting_regime
          (
                 p_approver_list => approverList,
                 x_valid_regime  => l_valid_regime,
                 x_voting_regime => l_voting_regime
          );

          if (l_valid_regime = 'N') then
              raise INVALID_FIRST_VOTER_WINS_SETUP;
          else
             if (l_voting_regime <> ame_util.firstApproverVoting ) then
                    l_voting_regime := 'X';
             end if;

             --set the voting regime on the workflow attribute
             wf_event.AddParameterToList
                  ('AME_VOTING_REGIME', l_voting_regime,p_event.Parameter_List);

          end if;
          --Bug 4577122: End

          --Bug 4160412: Start
          --Check the value of signature mode.
          --If it is set to lite then, fetch the value of the attributes APPROVING_USERS,
          --APPROVER_COUNT and APPROVING RESPONSIBILITY.
          --Bug 5891879 :Start
	  --Defaults Signature mode to SHORT when the src application type is KIOSK
            IF l_source_application_type = EDR_CONSTANTS_PUB.g_kiosk_mode then
             l_signature_mode := EDR_CONSTANTS_GRP.G_ERES_LITE;
            end if;
	  --Bug 5891879 :End

          --Bug 4543216: Start
          if l_signature_mode = EDR_CONSTANTS_GRP.G_ERES_LITE then
          --Bug 4543216: Start

            --Diagnostics Start
            if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_SIGN_MODE_EVT');
              FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
              FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
              FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                              'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                              FALSE
                             );
            end if;
            --Diagnostics End

            l_einitials_defer_mode := 'Y';
            wf_event.AddParameterToList(EDR_CONSTANTS_GRP.G_SIGNATURE_MODE, l_signature_mode,p_event.Parameter_List);
            l_approver_count := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.G_APPROVER_COUNT,p_event.Parameter_List);
            l_approver_list := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.G_APPROVER_LIST,p_event.Parameter_List);

            --If approver_count and approving users are set, then raise an exception.
            if l_approver_count is not null and l_approver_list is not null then
              RAISE APPROVING_USERS_PARAMS_ERR;
            end if;

            --If approving users are set, then fetch the approver list from the comma separated string.
            if l_approver_list is not null then

              --Diagnostics Start
              if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_APPR_LIST_EVT');
                FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
                FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
                FND_MESSAGE.SET_TOKEN('APPROVER_LIST',l_approver_list);
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                                'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                                FALSE
                               );
              end if;
              --Diagnostics End

              EDR_UTILITIES.GET_APPROVER_LIST(P_APPROVING_USERS     => L_APPROVER_LIST,
                                              X_APPROVER_LIST       => L_CUSTOM_APPROVER_LIST,
                                              X_ARE_APPROVERS_VALID => L_ARE_APPROVERS_VALID,
                                              X_INVALID_APPROVERS   => L_INVALID_APPROVERS);

              l_repeating_approvers := EDR_UTILITIES.ARE_APPROVERS_REPEATING(P_APPROVER_LIST => L_CUSTOM_APPROVER_LIST);

              --If there are repeating approvers then raise an exception
              if l_repeating_approvers then
                raise REPEATING_APPROVERS_ERR;
              end if;

              --If the approvers are invalid then raise an exception.
              if l_are_approvers_valid = 'N' then
                RAISE INVALID_APPROVING_USERS;
              end if;
              approverlist := L_CUSTOM_APPROVER_LIST;

              for l_list_count in 1..approverlist.count loop
                if instr(approverlist(l_list_count).name,'#') = 1 then
                  wf_event.addParameterToList(EDR_CONSTANTS_GRP.G_DO_RESPS_EXIST,'Y',p_event.Parameter_List);
                  l_einitials_defer_mode := 'N';
                  exit;
                end if;
              end loop;
            end if;

            if l_approver_count is not null then

              --Diagnostics Start
              if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_APPR_COUNT_EVT');
                FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
                FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
                FND_MESSAGE.SET_TOKEN('APPROVER_COUNT',l_approver_count);
                FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                                'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                                FALSE
                               );
              end if;
              --Diagnostics End

              --Approver Count has been specified
              --Convert it into a number type.
              BEGIN
                 l_approver_count_value := to_number(l_approver_count,'999999999999');
                 --If approver count is less then 0 then raise an error.
                 if l_approver_count_value < 0 then
                   raise INVALID_APPR_COUNT_VALUE_ERR;
                 end if;
                 EXCEPTION
                 --Approver Count attribute was a not a valid number. Hence raise an exception.
                 WHEN VALUE_ERROR THEN
                   RAISE INVALID_APPR_COUNT_ERR;
              END;


              --Make null entries in the approver list table type.
              for l_list_count in 1..l_approver_count_value loop
                L_CUSTOM_APPROVER_LIST(l_list_count).name := null;
                L_CUSTOM_APPROVER_LIST(l_list_count).approver_order_number := l_list_count;
                approverList := L_CUSTOM_APPROVER_LIST;
              end loop;

              l_einitials_defer_mode := 'N';

            end if;

            --If approver count is zero, then do not start the pageflow process.
            --This is because adhoc functionality is not supported in EINITIALS.
            if approverList.count = 0 then
              return 'SUCCESS';
            end if;

            --Evaluate the einitials deferred mode variable.
            if l_einitials_defer_mode = 'Y' then
              l_eres_defer_mode := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.G_DEFERRED_PARAM,p_event.Parameter_List);
              if l_eres_defer_mode is null or l_eres_defer_mode <> 'Y' then
                l_einitials_defer_mode := 'N';
              end if;
            END IF;

            --Diagnostics Start
            if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
              FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_DEFER_MODE_EVT');
              FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
              FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
              FND_MESSAGE.SET_TOKEN('DEFER_MODE',l_einitials_defer_mode);
              FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                              'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                              FALSE
                             );
            end if;
            --Diagnostics End

            --Add the e-initials deferred mode variable to the event.
            wf_event.AddParameterToList(EDR_CONSTANTS_GRP.G_EINITIALS_DEFER_MODE,l_einitials_defer_mode,p_event.Parameter_List);
          END IF;
          --Bug 4160412: End


          /* select Unique event Id to be posted in temp tables */
          /* 24-FEB-2003: CJ: commented one line below as the erecord id is already available
          in the local variable and added a line to delete the erecord id from temp
          table */
          /* SELECT EDR_ERECORDS_S.NEXTVAL into l_edr_Event_id from DUAL; */
          /* 24-FEB-2003: CJ : end */
          /* Set this value to correlation_id to be used by WF_RULE.DEFAULT_RULE funciton */
          P_EVENT.SETCORRELATIONID(l_edr_event_id);
          /* Select the workflow process for the subscription */
          select wf_process_type,wf_process_name
            into   l_wftype, l_wfprocess
            from   wf_event_subscriptions
            where  guid = p_subscription_guid;

          wf_event.AddParameterToList('#WF_PAGEFLOW_ITEMTYPE', l_wftype,p_event.Parameter_List); /* Page Flow Workflow type*/
          wf_event.AddParameterToList('#WF_PAGEFLOW_ITEMPROCESS', l_wfprocess,p_event.Parameter_List); /* Page Flow Workflow process*/
          wf_event.AddParameterToList('#WF_PAGEFLOW_ITEMKEY', l_edr_event_id,p_event.Parameter_List); /* Item Key*/

          /* CAll Page Flow Creation API */
          wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','Calling Page Flow Creation Procedure');

          --Diagnostics Start
          if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
            FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_WF_PARAMS_EVT');
            FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
            FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
            FND_MESSAGE.SET_TOKEN('ITEM_TYPE',l_wftype);
            FND_MESSAGE.SET_TOKEN('ITEM_KEY',l_edr_event_id);
            FND_MESSAGE.SET_TOKEN('PROCESS',l_wfprocess);
            FND_LOG.MESSAGE(FND_LOG.LEVEL_EVENT,
                            'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                            FALSE
                           );
          end if;
          --Diagnostics End

          --Bug 4122622: Start
          --Obtain the value of the comma separated child e-record ID string.
          l_child_erecord_ids := wf_event.getValueForParameter(EDR_CONSTANTS_GRP.G_CHILD_ERECORD_IDS,p_event.Parameter_List);

          --Set the approriate flags based on this value.
          if l_child_erecord_ids is not null then
            if instr(l_child_erecord_ids,',') > 0 then
              l_child_erecord_ids_set := true;
            else
              l_child_erecord_id_set := true;
            end if;
          end if;

          --Set the approriate flags based on the parent e-record id.
          if(l_parent_erecord_id is not null and l_parent_erecord_id <> EDR_CONSTANTS_GRP.g_default_num_param_value) then
            l_parent_erecord_id_set := true;
          end if;

          --Set the related e-record IDs URLs based on the flags.
          if l_parent_erecord_id_set then
            if l_child_erecord_id_set then

              l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=EDR_RELATED_ERECORDS_VIEW&retainAM=Y&parentERecordId='||
                       l_parent_erecord_id||'&childERecordIds='||l_child_erecord_ids||'&addBreadCrumb=Y';

            elsif l_child_erecord_ids_set then
              l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=EDR_RELATED_ERECORDS_VIEW&edrNotifId=-&#NID-&retainAM=Y'||
                       '&parentERecordId='||l_parent_erecord_id||'&addBreadCrumb=Y';
            else

              l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=EDR_ERECORD_DETAILS_VIEW&retainAM=Y' ||
                       '&relatedERecordType=PARENT&fromNotifPG=Y&eRecordId='||l_parent_erecord_id;
            end if;

          elsif l_child_erecord_ids_set then

            l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=EDR_RELATED_ERECORDS_VIEW&edrNotifId=-&#NID-&retainAM=Y&addBreadCrumb=Y';

          elsif l_child_erecord_id_set then

            l_url := 'JSP:/OA_HTML/OA.jsp?OAFunc=EDR_ERECORD_DETAILS_VIEW&retainAM=Y' ||
                     '&relatedERecordType=CHILD&fromNotifPG=Y&eRecordId='||l_child_erecord_ids;

          end if;

          wf_event.AddParameterToList('RELATED_ERECORDS',l_url,p_event.Parameter_List);

          --Bug 4122622: End;

          l_return_status:= CREATE_PAGEFLOW(p_event_id             => l_edr_event_id,
                                            p_map_code             => l_xml_map_code,
                                            p_ame_transaction_type => l_ame_transaction_type,
                                            p_audit_group          => l_audit_group,
                                            p_eventP               => p_event,
                                            p_subscription_guid    => p_subscription_guid,
                                            P_approverlist         => approverList,
                                            P_ERR_CODE             => l_error,
                                            P_ERR_MSG              => l_error_msg);
          wf_log_pkg.string(3, 'EDR_PSIG_RULE.psig_rule','Page Flow Returned '||l_return_status);

          IF l_return_status = 'ERROR' OR L_ERROR is not null then
            raise PAGE_FLOW_FAILED;
          ELSE
            RETURN l_return_status;
          END IF;

        ELSE
          /* No approver Required, Signature Not REquired */
          RETURN 'SUCCESS';
        END IF;
      END IF;
    end if;
  end if;

  RETURN 'SUCCESS';

exception
  --Bug 4577122: Start
  when INVALID_FIRST_VOTER_WINS_SETUP then
     FND_MESSAGE.SET_NAME('EDR','EDR_BAD_FRST_VOTER_SETUP');
     fnd_message.set_token( 'EVENT', l_error_event);
     APP_EXCEPTION.RAISE_EXCEPTION;
     return EDR_CONSTANTS_GRP.g_error_status;
  --Bug 4577122: End

  when NO_ENABLED_ERES_SUBSCRIPTION THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_ERES_SUBSCRIPTION_DISABLED');
    fnd_message.set_token( 'EVENT', l_error_event);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  when NO_ERES_SUBSCRIPTION THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_NO_ERES_SUBSCRIPTION');
    fnd_message.set_token( 'EVENT', l_error_event);

    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  WHEN MULTIPLE_ERES_SUBSCRIPTIONS THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_MULTI_ERES_SUBSCRIPTIONS');
    fnd_message.set_token( 'EVENT',l_error_event);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  when PAGE_FLOW_FAILED then
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', p_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_event,SQLERRM || 'ERROR');
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','PSIG_RULE');
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  --Bug 3667036: Start
  --Catch the XML to XML transformation error.
  when ECX_XML_TO_XML_ERROR then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWKRULE_XML_TO_XML_ERR');
    FND_MESSAGE.SET_TOKEN('EXCEPTION_MESSAGE',l_errbuf);
    FND_MESSAGE.SET_TOKEN('LOG',l_log_file);
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;
  --Bug 3667036: End

  --Bug 3893101: Start
  WHEN TRANSFORM_XML_VAR_ERROR then
    FND_MESSAGE.SET_NAME('EDR','EDR_FWK_TRANSFORM_XML_VAR_ERR');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                       FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;
  --Bug 3893101: End

  --Bug 4160412: Start
  WHEN APPROVING_USERS_PARAMS_ERR THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_USERS_PARAMS_ERR');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                       FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  WHEN INVALID_APPROVING_USERS THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_INVALID_USERS');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
    FND_MESSAGE.SET_TOKEN('APPROVER_NAMES',l_invalid_approvers);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                       FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  WHEN REPEATING_APPROVERS_ERR THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_REPEATING_APPRS');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
    FND_MESSAGE.SET_TOKEN('STRING',l_approver_list);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                       FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  WHEN INVALID_APPR_COUNT_ERR THEN
     FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_INVALID_APPR_CNT');
     FND_MESSAGE.SET_TOKEN('APPROVER_COUNT',l_approver_count);
     FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
     FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());

    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

  WHEN INVALID_APPR_COUNT_VALUE_ERR THEN
     FND_MESSAGE.SET_NAME('EDR','EDR_EINITIALS_APPR_CNT_ERR');
     FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
     FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());

    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;
  --Bug 4160412: End

  --Bug 3960236: Start
  WHEN API_EXECUTION_ERROR THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_XMLCALLBACK_API_ERR');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
    FND_MESSAGE.SET_TOKEN('APINAME',SQLERRM||': '||l_xml_generation_api);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                       FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;
    -- Bug 3960236 : end


  WHEN EMPTY_XML_DOCUMENT THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_XMLCALLBACK_EMPTY_ERR');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
    FND_MESSAGE.SET_TOKEN('APINAME',SQLERRM);
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                       FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;
   -- Bug 3960236 : end

  --Bug 5724159  :start
  --define a new exception to throw error message when there are no approvers, Signature mode is SHORT
  --and the Adhoc Signer capability is ALL or ADHOC.
  WHEN NO_SIGNERS_DEF_FOR_LITE_MODE THEN
    FND_MESSAGE.SET_NAME('EDR','EDR_NO_SIGNER_DEF_ERR');
    FND_MESSAGE.SET_TOKEN('EVENT_NAME',p_event.getEventName());
    FND_MESSAGE.SET_TOKEN('EVENT_KEY',p_event.getEventKey());
    --Diagnostics Start
    if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                       FALSE
                     );
    end if;
    --Diagnostics End
    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;
   --Bug 5724159  :End

  when others then
    Wf_Core.Context('EDR_PSIG_RULE', 'PSIG_RULE', p_event.getEventName(), p_subscription_guid);
    wf_event.setErrorInfo(p_event,SQLERRM || 'ERROR');
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',nvl(l_error_msg,SQLERRM));
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_PSIG_RULE');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','PSIG_RULE');
    --Diagnostics Start
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_PSIG_RULE.PSIG_RULE',
                      FALSE
                     );
    end if;
    --Diagnostics End

    APP_EXCEPTION.RAISE_EXCEPTION;
    return EDR_CONSTANTS_GRP.g_error_status;

end PSIG_RULE;

end EDR_PSIG_RULE;

/
