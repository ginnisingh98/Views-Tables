--------------------------------------------------------
--  DDL for Package Body XNP_SV_ORDERS$SOA_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_SV_ORDERS$SOA_SV" as
/* $Header: XNPSVO2B.pls 120.0 2005/05/30 11:52:54 appldev noship $ */


   procedure FormView(Z_FORM_STATUS in number);
   function BuildSQL(
            P_PORTING_ID in varchar2 default null,
            P_SUBSCRIPTION_TYPE in varchar2 default null,
            P_SUBSCRIPTION_TN in varchar2 default null,
            P_STATUS_DISPLAY_NAME in varchar2 default null,
            P_CUSTOMER_ID in varchar2 default null,
            P_CUSTOMER_NAME in varchar2 default null,
            P_REC_CODE in varchar2 default null,
            P_DON_CODE in varchar2 default null,
            P_NRC_CODE in varchar2 default null) return boolean;
   function PreQuery(
            P_PORTING_ID in varchar2 default null,
            P_SUBSCRIPTION_TYPE in varchar2 default null,
            P_SUBSCRIPTION_TN in varchar2 default null,
            P_STATUS_DISPLAY_NAME in varchar2 default null,
            P_CUSTOMER_ID in varchar2 default null,
            P_CUSTOMER_NAME in varchar2 default null,
            P_REC_CODE in varchar2 default null,
            P_DON_CODE in varchar2 default null,
            P_NRC_CODE in varchar2 default null) return boolean;
   function PostQuery(Z_POST_DML in boolean) return boolean;
   procedure CreateQueryJavaScript;
   procedure CreateListJavaScript;
   procedure InitialiseDomain(P_ALIAS in varchar2);

   QF_BODY_ATTRIBUTES     constant varchar2(500) := 'BGCOLOR="CCCCCC"';
   QF_QUERY_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_FIND_BUTTON'));
   QF_CLEAR_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_CLEAR_BUTTON'));
   QF_QUERY_BUT_ACTION    constant varchar2(10)  := 'QUERY';
   QF_CLEAR_BUT_ACTION    constant varchar2(10)  := 'CLEAR';
   QF_NUMBER_OF_COLUMNS   constant number(4)	 := 2;
   VF_BODY_ATTRIBUTES     constant varchar2(500) := 'BGCOLOR="CCCCCC"';
   VF_UPDATE_BUT_CAPTION  constant varchar2(100) := XNP_WSGL.MsgGetText(6,XNP_WSGLM.CAP006_VF_UPDATE);
   VF_CLEAR_BUT_CAPTION   constant varchar2(100) := XNP_WSGL.MsgGetText(8,XNP_WSGLM.CAP008_VF_REVERT);
   VF_DELETE_BUT_CAPTION  constant varchar2(100) := XNP_WSGL.MsgGetText(7,XNP_WSGLM.CAP007_VF_DELETE);
   VF_UPDATE_BUT_ACTION   constant varchar2(10)  := 'UPDATE';
   VF_CLEAR_BUT_ACTION    constant varchar2(10)  := 'CLEAR';
   VF_DELETE_BUT_ACTION   constant varchar2(10)  := 'DELETE';
   VF_VERIFIED_DELETE     constant varchar2(100) := 'VerifiedDelete';
   VF_NUMBER_OF_COLUMNS   constant number(4)	 := 2;
   RL_BODY_ATTRIBUTES     constant varchar2(500) := 'BGCOLOR="CCCCCC"';
   RL_NEXT_BUT_CAPTION    constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_NEXT_BUTTON'));
   RL_PREV_BUT_CAPTION    constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_PREVIOUS_BUTTON'));
   RL_FIRST_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_FIRST_BUTTON'));
   RL_LAST_BUT_CAPTION    constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_LAST_BUTTON'));
   RL_COUNT_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_COUNT_BUTTON'));
   RL_REQUERY_BUT_CAPTION constant varchar2(100) := 'Refresh';
   RL_QUERY_BUT_CAPTION  constant varchar2(100)  := 'New Search';
   RL_QUERY_BUT_ACTION    constant varchar2(10)  := 'QUERY';
   RL_NEXT_BUT_ACTION     constant varchar2(10)  := 'NEXT';
   RL_PREV_BUT_ACTION     constant varchar2(10)  := 'PREV';
   RL_FIRST_BUT_ACTION    constant varchar2(10)  := 'FIRST';
   RL_LAST_BUT_ACTION     constant varchar2(10)  := 'LAST';
   RL_COUNT_BUT_ACTION    constant varchar2(10)  := 'COUNT';
   RL_REQUERY_BUT_ACTION  constant varchar2(10)  := 'REQUERY';
   RL_RECORD_SET_SIZE     constant number(4)     := 10;
   RL_TOTAL_COUNT_REQD    constant boolean       := TRUE;
   RL_NUMBER_OF_COLUMNS   constant number(4)     := 1;
   LOV_BODY_ATTRIBUTES    constant varchar2(500) := 'BGCOLOR="CCCCCC"';
   LOV_FIND_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_FIND_BUTTON'));
   LOV_CLOSE_BUT_CAPTION  constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_CLOSE_BUTTON'));
   LOV_FIND_BUT_ACTION    constant  varchar2(10) := 'FIND';
   LOV_CLOSE_BUT_ACTION   constant varchar2(10)  := 'CLOSE';
   LOV_BUTTON_TEXT        constant varchar2(100) := htf.italic(fnd_message.get_string('XNP','LIST_OF_VALUES'));
   LOV_FRAME              constant varchar2(20)  := null;
   TF_BODY_ATTRIBUTES     constant varchar2(500) := 'BGCOLOR="CCCCCC"';
   DEF_BODY_ATTRIBUTES    constant varchar2(500) := 'BGCOLOR="CCCCCC"';

   CURR_VAL XNP_SV_SOA_VL%ROWTYPE;

   TYPE FORM_REC IS RECORD
        (PORTING_ID          VARCHAR2(80)
        ,SUBSCRIPTION_TYPE   VARCHAR2(30)
        ,SUBSCRIPTION_TN     VARCHAR2(20)
        ,PRE_SPLIT_SUBSCRIPTION_TN VARCHAR2(20)
        ,ROUTING_NUMBER      VARCHAR2(20)
        ,STATUS_PHASE        VARCHAR2(20)
        ,STATUS_DISPLAY_NAME VARCHAR2(40)
        ,DSP_STATUS          VARCHAR2(2000)
        ,STATUS_CHANGE_DATE  VARCHAR2(12)
        ,STATUS_CHANGE_CAUSE_CODE VARCHAR2(20)
        ,DSP_CUSTOMER        VARCHAR2(2000)
        ,DSP_CONTACT         VARCHAR2(2000)
        ,CUSTOMER_ID         VARCHAR2(80)
        ,CUSTOMER_NAME       VARCHAR2(80)
        ,CONTACT_NAME        VARCHAR2(80)
        ,PHONE               VARCHAR2(20)
        ,EMAIL               VARCHAR2(80)
        ,ACTIVATION_DUE_DATE VARCHAR2(12)
        ,ORDER_PRIORITY      VARCHAR2(10)
        ,PREORDER_AUTHORIZATION_CODE VARCHAR2(20)
        ,DSP_REC             VARCHAR2(2000)
        ,REC_CODE            VARCHAR2(20)
        ,REC_NAME            VARCHAR2(80)
        ,REC_EMAIL           VARCHAR2(80)
        ,DSP_DON             VARCHAR2(2000)
        ,DON_CODE            VARCHAR2(20)
        ,DON_NAME            VARCHAR2(80)
        ,DON_EMAIL           VARCHAR2(80)
        ,DSP_NRC             VARCHAR2(2000)
        ,NRC_CODE            VARCHAR2(20)
        ,NRC_NAME            VARCHAR2(80)
        ,NRC_EMAIL           VARCHAR2(80)
        ,NEW_SP_AUTHORIZATION_FLAG VARCHAR2(5)
        ,NEW_SP_DUE_DATE     VARCHAR2(12)
        ,OLD_SP_AUTHORIZATION_FLAG VARCHAR2(5)
        ,OLD_SP_DUE_DATE     VARCHAR2(12)
        ,OLD_SP_CUTOFF_DUE_DATE VARCHAR2(12)
        ,INVOICE_DUE_DATE    VARCHAR2(12)
        ,RETAIN_DIR_INFO_FLAG VARCHAR2(5)
        ,LOCKED_FLAG         VARCHAR2(5)
        ,CONCURRENCE_FLAG    VARCHAR2(1)
        ,PTO_FLAG            VARCHAR2(5)
        ,DISCONNECT_DUE_DATE VARCHAR2(12)
        ,EFFECTIVE_RELEASE_DUE_DATE VARCHAR2(12)
        ,RETAIN_TN_FLAG VARCHAR2(5)
        ,BLOCKED_FLAG        VARCHAR2(5)
        ,NUMBER_RETURNED_DUE_DATE VARCHAR2(12)
        ,DSP_CNAM            VARCHAR2(2000)
        ,DSP_CLASS           VARCHAR2(2000)
        ,DSP_ISVM            VARCHAR2(2000)
        ,DSP_LIDB            VARCHAR2(2000)
        ,DSP_WSMSC           VARCHAR2(2000)
        ,DSP_RN              VARCHAR2(2000)
        ,CLASS_ADDRESS       VARCHAR2(80)
        ,CLASS_SUBSYSTEM     VARCHAR2(80)
        ,CNAM_ADDRESS        VARCHAR2(80)
        ,CNAM_SUBSYSTEM      VARCHAR2(80)
        ,ISVM_ADDRESS        VARCHAR2(80)
        ,ISVM_SUBSYSTEM      VARCHAR2(80)
        ,LIDB_ADDRESS        VARCHAR2(80)
        ,LIDB_SUBSYSTEM      VARCHAR2(80)
        ,WSMSC_ADDRESS       VARCHAR2(80)
        ,WSMSC_SUBSYSTEM     VARCHAR2(80)
        ,RN_ADDRESS          VARCHAR2(80)
        ,RN_SUBSYSTEM        VARCHAR2(80)
        ,SV_SOA_ID           VARCHAR2(8)
        );
   FORM_VAL   FORM_REC;

   TYPE NBT_REC IS RECORD
        (DSP_STATUS          VARCHAR2(2000)
        ,DSP_CUSTOMER        VARCHAR2(2000)
        ,DSP_CONTACT         VARCHAR2(2000)
        ,DSP_REC             VARCHAR2(2000)
        ,DSP_DON             VARCHAR2(2000)
        ,DSP_NRC             VARCHAR2(2000)
        ,DSP_CNAM            VARCHAR2(2000)
        ,DSP_CLASS           VARCHAR2(2000)
        ,DSP_ISVM            VARCHAR2(2000)
        ,DSP_LIDB            VARCHAR2(2000)
        ,DSP_WSMSC           VARCHAR2(2000)
        ,DSP_RN              VARCHAR2(2000)
        );
   NBT_VAL    NBT_REC;

   ZONE_SQL   VARCHAR2(7600) := null;

   D_SUBSCRIPTION_TYPE   XNP_WSGL.typDVRecord;
   D_STATUS_PHASE        XNP_WSGL.typDVRecord;
   D_ORDER_PRIORITY      XNP_WSGL.typDVRecord;
   D_NEW_SP_AUTHORIZATION_FLAG XNP_WSGL.typDVRecord;
   D_OLD_SP_AUTHORIZATION_FLAG XNP_WSGL.typDVRecord;
   D_RETAIN_DIR_INFO_FLAG XNP_WSGL.typDVRecord;
   D_LOCKED_FLAG         XNP_WSGL.typDVRecord;
   D_CONCURRENCE_FLAG    XNP_WSGL.typDVRecord;
   D_PTO_FLAG            XNP_WSGL.typDVRecord;
   D_RETAIN_TN_FLAG XNP_WSGL.typDVRecord;
   D_BLOCKED_FLAG        XNP_WSGL.typDVRecord;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.InitialiseDomain
--
-- Description: Initialises the Domain Record for the given Column Usage
--
-- Parameters:  P_ALIAS   The alias of the column usage
--
--------------------------------------------------------------------------------
   procedure InitialiseDomain(P_ALIAS in varchar2) is
   begin

      if P_ALIAS = 'SUBSCRIPTION_TYPE' and not D_SUBSCRIPTION_TYPE.Initialised then
         D_SUBSCRIPTION_TYPE.ColAlias := 'SUBSCRIPTION_TYPE';
         D_SUBSCRIPTION_TYPE.ControlType := XNP_WSGL.DV_TEXT;
         D_SUBSCRIPTION_TYPE.DispWidth := 30;
         D_SUBSCRIPTION_TYPE.DispHeight := 1;
         D_SUBSCRIPTION_TYPE.MaxWidth := 30;
         D_SUBSCRIPTION_TYPE.UseMeanings := True;
         D_SUBSCRIPTION_TYPE.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_SUBSCRIPTION_TYPE', D_SUBSCRIPTION_TYPE);
         D_SUBSCRIPTION_TYPE.Initialised := True;
      end if;

      if P_ALIAS = 'STATUS_PHASE' and not D_STATUS_PHASE.Initialised then
         D_STATUS_PHASE.ColAlias := 'STATUS_PHASE';
         D_STATUS_PHASE.ControlType := XNP_WSGL.DV_TEXT;
         D_STATUS_PHASE.DispWidth := 10;
         D_STATUS_PHASE.DispHeight := 1;
         D_STATUS_PHASE.MaxWidth := 20;
         D_STATUS_PHASE.UseMeanings := False;
         D_STATUS_PHASE.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_PHASE_INDICATOR', D_STATUS_PHASE);
         D_STATUS_PHASE.Initialised := True;
      end if;

      if P_ALIAS = 'ORDER_PRIORITY' and not D_ORDER_PRIORITY.Initialised then
         D_ORDER_PRIORITY.ColAlias := 'ORDER_PRIORITY';
         D_ORDER_PRIORITY.ControlType := XNP_WSGL.DV_TEXT;
         D_ORDER_PRIORITY.DispWidth := 10;
         D_ORDER_PRIORITY.DispHeight := 1;
         D_ORDER_PRIORITY.MaxWidth := 10;
         D_ORDER_PRIORITY.UseMeanings := True;
         D_ORDER_PRIORITY.ColOptional := True;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_ORDER_PRIORITY', D_ORDER_PRIORITY);
         D_ORDER_PRIORITY.Initialised := True;
      end if;

      if P_ALIAS = 'NEW_SP_AUTHORIZATION_FLAG' and not D_NEW_SP_AUTHORIZATION_FLAG.Initialised then
         D_NEW_SP_AUTHORIZATION_FLAG.ColAlias := 'NEW_SP_AUTHORIZATION_FLAG';
         D_NEW_SP_AUTHORIZATION_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_NEW_SP_AUTHORIZATION_FLAG.DispWidth := 5;
         D_NEW_SP_AUTHORIZATION_FLAG.DispHeight := 1;
         D_NEW_SP_AUTHORIZATION_FLAG.MaxWidth := 5;
         D_NEW_SP_AUTHORIZATION_FLAG.UseMeanings := True;
         D_NEW_SP_AUTHORIZATION_FLAG.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_NEW_SP_AUTHORIZATION_FLAG);
         D_NEW_SP_AUTHORIZATION_FLAG.Initialised := True;
      end if;

      if P_ALIAS = 'OLD_SP_AUTHORIZATION_FLAG' and not D_OLD_SP_AUTHORIZATION_FLAG.Initialised then
         D_OLD_SP_AUTHORIZATION_FLAG.ColAlias := 'OLD_SP_AUTHORIZATION_FLAG';
         D_OLD_SP_AUTHORIZATION_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_OLD_SP_AUTHORIZATION_FLAG.DispWidth := 5;
         D_OLD_SP_AUTHORIZATION_FLAG.DispHeight := 1;
         D_OLD_SP_AUTHORIZATION_FLAG.MaxWidth := 5;
         D_OLD_SP_AUTHORIZATION_FLAG.UseMeanings := True;
         D_OLD_SP_AUTHORIZATION_FLAG.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_OLD_SP_AUTHORIZATION_FLAG);
         D_OLD_SP_AUTHORIZATION_FLAG.Initialised := True;
      end if;

      if P_ALIAS = 'RETAIN_DIR_INFO_FLAG' and not D_RETAIN_DIR_INFO_FLAG.Initialised then
         D_RETAIN_DIR_INFO_FLAG.ColAlias := 'RETAIN_DIR_INFO_FLAG';
         D_RETAIN_DIR_INFO_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_RETAIN_DIR_INFO_FLAG.DispWidth := 5;
         D_RETAIN_DIR_INFO_FLAG.DispHeight := 1;
         D_RETAIN_DIR_INFO_FLAG.MaxWidth := 5;
         D_RETAIN_DIR_INFO_FLAG.UseMeanings := True;
         D_RETAIN_DIR_INFO_FLAG.ColOptional := True;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_RETAIN_DIR_INFO_FLAG);
         D_RETAIN_DIR_INFO_FLAG.Initialised := True;
      end if;

      if P_ALIAS = 'LOCKED_FLAG' and not D_LOCKED_FLAG.Initialised then
         D_LOCKED_FLAG.ColAlias := 'LOCKED_FLAG';
         D_LOCKED_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_LOCKED_FLAG.DispWidth := 5;
         D_LOCKED_FLAG.DispHeight := 1;
         D_LOCKED_FLAG.MaxWidth := 5;
         D_LOCKED_FLAG.UseMeanings := True;
         D_LOCKED_FLAG.ColOptional := True;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_LOCKED_FLAG);
         D_LOCKED_FLAG.Initialised := True;
      end if;

      if P_ALIAS = 'CONCURRENCE_FLAG' and not D_CONCURRENCE_FLAG.Initialised then
         D_CONCURRENCE_FLAG.ColAlias := 'CONCURRENCE_FLAG';
         D_CONCURRENCE_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_CONCURRENCE_FLAG.DispWidth := 1;
         D_CONCURRENCE_FLAG.DispHeight := 1;
         D_CONCURRENCE_FLAG.MaxWidth := 1;
         D_CONCURRENCE_FLAG.UseMeanings := False;
         D_CONCURRENCE_FLAG.ColOptional := True;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_CONCURRENCE_FLAG);
         D_CONCURRENCE_FLAG.Initialised := True;
      end if;

      if P_ALIAS = 'PTO_FLAG' and not D_PTO_FLAG.Initialised then
         D_PTO_FLAG.ColAlias := 'PTO_FLAG';
         D_PTO_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_PTO_FLAG.DispWidth := 5;
         D_PTO_FLAG.DispHeight := 1;
         D_PTO_FLAG.MaxWidth := 5;
         D_PTO_FLAG.UseMeanings := True;
         D_PTO_FLAG.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_NO', D_PTO_FLAG);
         D_PTO_FLAG.Initialised := True;
      end if;

      if P_ALIAS = 'RETAIN_TN_FLAG' and not D_RETAIN_TN_FLAG.Initialised then
         D_RETAIN_TN_FLAG.ColAlias := 'RETAIN_TN_FLAG';
         D_RETAIN_TN_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_RETAIN_TN_FLAG.DispWidth := 5;
         D_RETAIN_TN_FLAG.DispHeight := 1;
         D_RETAIN_TN_FLAG.MaxWidth := 5;
         D_RETAIN_TN_FLAG.UseMeanings := True;
         D_RETAIN_TN_FLAG.ColOptional := True;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_RETAIN_TN_FLAG);
         D_RETAIN_TN_FLAG.Initialised := True;
      end if;

      if P_ALIAS = 'BLOCKED_FLAG' and not D_BLOCKED_FLAG.Initialised then
         D_BLOCKED_FLAG.ColAlias := 'BLOCKED_FLAG';
         D_BLOCKED_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_BLOCKED_FLAG.DispWidth := 5;
         D_BLOCKED_FLAG.DispHeight := 1;
         D_BLOCKED_FLAG.MaxWidth := 5;
         D_BLOCKED_FLAG.UseMeanings := True;
         D_BLOCKED_FLAG.ColOptional := True;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_BLOCKED_FLAG);
         D_BLOCKED_FLAG.Initialised := True;
      end if;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.InitialseDomain');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.Startup
--
-- Description: Entry point for the 'SOA_SV' module
--              component  (Porting Ordering Subscriptions).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_sv_orders$soa_sv.startup');
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.StoreURLLink(1, 'Porting Ordering Subscriptions');


      FormQuery(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.ActionQuery
--
-- Description: Called when a Query form is subitted to action the query request.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure ActionQuery(
             P_PORTING_ID in varchar2,
             P_SUBSCRIPTION_TYPE in varchar2,
             P_SUBSCRIPTION_TN in varchar2,
             P_STATUS_DISPLAY_NAME in varchar2,
             P_CUSTOMER_ID in varchar2,
             P_CUSTOMER_NAME in varchar2,
             P_REC_CODE in varchar2,
             P_DON_CODE in varchar2,
             P_NRC_CODE in varchar2,
       	     Z_DIRECT_CALL in boolean default false,
             Z_ACTION in varchar2,
             Z_CHK in varchar2) is

     I_PARAM_LIST varchar2(2000) := '?';
     L_QRY_FIRST_ACTION varchar2(12) := 'INSERTIFNONE';
     L_QRY_LIST_ACTION varchar2(10) := null;
     L_CHK varchar2(10) := Z_CHK;
     L_BUTCHK varchar2(100):= null;
   begin

    if Z_DIRECT_CALL then
      L_CHK := to_char(XNP_WSGL.Checksum(''));
    else
      if not XNP_WSGL.ValidateChecksum('', L_CHK) then
         return;
      end if;
    end if;

      if P_PORTING_ID is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_PORTING_ID=' || XNP_WSGL.EscapeURLParam(P_PORTING_ID) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_SUBSCRIPTION_TYPE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_SUBSCRIPTION_TYPE=' || XNP_WSGL.EscapeURLParam(P_SUBSCRIPTION_TYPE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_SUBSCRIPTION_TN is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_SUBSCRIPTION_TN=' || XNP_WSGL.EscapeURLParam(P_SUBSCRIPTION_TN) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_STATUS_DISPLAY_NAME is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_STATUS_DISPLAY_NAME=' || XNP_WSGL.EscapeURLParam(P_STATUS_DISPLAY_NAME) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_CUSTOMER_ID is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_CUSTOMER_ID=' || XNP_WSGL.EscapeURLParam(P_CUSTOMER_ID) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_CUSTOMER_NAME is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_CUSTOMER_NAME=' || XNP_WSGL.EscapeURLParam(P_CUSTOMER_NAME) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_REC_CODE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_REC_CODE=' || XNP_WSGL.EscapeURLParam(P_REC_CODE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_DON_CODE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_DON_CODE=' || XNP_WSGL.EscapeURLParam(P_DON_CODE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_NRC_CODE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_NRC_CODE=' || XNP_WSGL.EscapeURLParam(P_NRC_CODE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      I_PARAM_LIST := I_PARAM_LIST || 'Z_CHK=' || XNP_WSGL.EscapeURLParam(L_CHK) || '&';
      I_PARAM_LIST := I_PARAM_LIST||'Z_ACTION=';

      htp.p('<HTML>
<TITLE>Monitor Ordering Subscriptions : Porting Ordering Subscriptions</TITLE>
<FRAMESET ROWS="100,*,50">
');
      htp.noframesOpen;
      XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_INFORMATION, XNP_WSGL.MsgGetText(229,XNP_WSGLM.MSG229_NO_FRAME_SUPPORT),
                          'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', DEF_BODY_ATTRIBUTES);
      htp.noframesClose;
      htp.p('<FRAME NAME="fraTOP" SRC="xnp_sv_orders$soa_sv.textframe?Z_HEADER=Y&Z_TEXT=Y">
<FRAMESET COLS="30%,70%">
<FRAME NAME="fraRL" SRC="xnp_sv_orders$soa_sv.querylist'||I_PARAM_LIST||L_QRY_LIST_ACTION||'">
<FRAME NAME="fraVF" SRC="xnp_sv_orders$soa_sv.queryfirst'||I_PARAM_LIST||L_QRY_FIRST_ACTION||'">
</FRAMESET>
<FRAME NAME="fraBOTTOM" SRC="xnp_sv_orders$soa_sv.textframe?Z_FOOTER=Y">
</FRAMESET>
</HTML>
');
--if on the query form and insert is allowed

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.ActionQuery');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.TextFrame
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure TextFrame(Z_HEADER in varchar2,
                       Z_FIRST  in varchar2,
                       Z_TEXT   in varchar2,
                       Z_FOOTER in varchar2) is
      L_TEXT_TYPES number := 0;
      L_ONLY_THING_IN_FRAME boolean := FALSE;
   begin

      if Z_HEADER is not null then
         L_TEXT_TYPES := L_TEXT_TYPES + 1;
      end if;
      if Z_FIRST is not null then
         L_TEXT_TYPES := L_TEXT_TYPES + 1;
      end if;
      if Z_TEXT is not null then
         L_TEXT_TYPES := L_TEXT_TYPES + 1;
      end if;
      if Z_FOOTER is not null then
         L_TEXT_TYPES := L_TEXT_TYPES + 1;
      end if;

      L_ONLY_THING_IN_FRAME := (L_TEXT_TYPES = 1);

      XNP_WSGL.OpenPageHead('Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                        L_ONLY_THING_IN_FRAME);
      xnp_sv_orders$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>TF_BODY_ATTRIBUTES);

      if Z_HEADER is not null then
         htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      end if;

      if Z_FIRST is not null then
         xnp_sv_orders$.FirstPage(TRUE);
      end if;

      if Z_TEXT is not null then
         htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPSVORD_DETAILS_TITLE')));
      end if;

      if Z_FOOTER is not null then
         htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));
      end if;

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             TF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.TextFrame');
         XNP_WSGL.ClosePageBody;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.QueryHits
--
-- Description: Returns the number or rows which matches the given search
--              criteria (if any).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function QueryHits(
            P_PORTING_ID in varchar2,
            P_SUBSCRIPTION_TYPE in varchar2,
            P_SUBSCRIPTION_TN in varchar2,
            P_STATUS_DISPLAY_NAME in varchar2,
            P_CUSTOMER_ID in varchar2,
            P_CUSTOMER_NAME in varchar2,
            P_REC_CODE in varchar2,
            P_DON_CODE in varchar2,
            P_NRC_CODE in varchar2) return number is
      I_QUERY     varchar2(2000) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_PORTING_ID,
                      P_SUBSCRIPTION_TYPE,
                      P_SUBSCRIPTION_TN,
                      P_STATUS_DISPLAY_NAME,
                      P_CUSTOMER_ID,
                      P_CUSTOMER_NAME,
                      P_REC_CODE,
                      P_DON_CODE,
                      P_NRC_CODE) then
         return -1;
      end if;

      if not PreQuery(P_PORTING_ID,
                      P_SUBSCRIPTION_TYPE,
                      P_SUBSCRIPTION_TN,
                      P_STATUS_DISPLAY_NAME,
                      P_CUSTOMER_ID,
                      P_CUSTOMER_NAME,
                      P_REC_CODE,
                      P_DON_CODE,
                      P_NRC_CODE) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', DEF_BODY_ATTRIBUTES);
         return -1;
      end if;

      I_FROM_POS := instr(upper(ZONE_SQL), ' FROM ');

      if I_FROM_POS = 0 then
         return -1;
      end if;

      I_QUERY := 'SELECT count(*)' ||
                 substr(ZONE_SQL, I_FROM_POS);

      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, I_QUERY, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, I_COUNT);
      I_VOID := dbms_sql.execute(I_CURSOR);
      I_VOID := dbms_sql.fetch_rows(I_CURSOR);
      dbms_sql.column_value(I_CURSOR, 1, I_COUNT);
      dbms_sql.close_cursor(I_CURSOR);

      return I_COUNT;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.QueryHits');
         return -1;
   end;--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.BuildSQL
--
-- Description: Builds the SQL for the 'SOA_SV' module component (Porting Ordering Subscriptions).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_PORTING_ID in varchar2,
            P_SUBSCRIPTION_TYPE in varchar2,
            P_SUBSCRIPTION_TN in varchar2,
            P_STATUS_DISPLAY_NAME in varchar2,
            P_CUSTOMER_ID in varchar2,
            P_CUSTOMER_NAME in varchar2,
            P_REC_CODE in varchar2,
            P_DON_CODE in varchar2,
            P_NRC_CODE in varchar2) return boolean is

      I_WHERE varchar2(2000);
   begin

      InitialiseDomain('SUBSCRIPTION_TYPE');

      -- Build up the Where clause

      XNP_WSGL.BuildWhere(P_PORTING_ID, 'XNP_SV_SOA_VL.PORTING_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(XNP_WSGL.DomainValue(D_SUBSCRIPTION_TYPE, P_SUBSCRIPTION_TYPE), 'XNP_SV_SOA_VL.SUBSCRIPTION_TYPE', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_SUBSCRIPTION_TN, 'XNP_SV_SOA_VL.SUBSCRIPTION_TN', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_STATUS_DISPLAY_NAME, 'XNP_SV_SOA_VL.STATUS_DISPLAY_NAME', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_CUSTOMER_ID, 'XNP_SV_SOA_VL.CUSTOMER_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_CUSTOMER_NAME, 'XNP_SV_SOA_VL.CUSTOMER_NAME', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_REC_CODE, 'XNP_SV_SOA_VL.REC_CODE', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_DON_CODE, 'XNP_SV_SOA_VL.DON_CODE', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_NRC_CODE, 'XNP_SV_SOA_VL.NRC_CODE', XNP_WSGL.TYPE_CHAR, I_WHERE);

      ZONE_SQL := 'SELECT XNP_SV_SOA_VL.PORTING_ID,
                         XNP_SV_SOA_VL.SUBSCRIPTION_TN,
                         XNP_SV_SOA_VL.STATUS_DISPLAY_NAME,
                         XNP_SV_SOA_VL.SV_SOA_ID
                  FROM   XNP_SV_SOA_VL XNP_SV_SOA_VL';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY 1';

      return true;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.BuildSQL');
         return false;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.FormQuery
--
-- Description: This procedure builds an HTML form for entry of query criteria.
--              The criteria entered are to restrict the query of the 'SOA_SV'
--              module component (Porting Ordering Subscriptions).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure FormQuery(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.OpenPageHead('Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions');
      CreateQueryJavaScript;
      xnp_sv_orders$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>QF_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      xnp_sv_orders$.FirstPage(TRUE);
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPSVORD_DETAILS_TITLE')));
      htp.para;
      htp.p(XNP_WSGL.MsgGetText(116,XNP_WSGLM.DSP116_ENTER_QRY_CAPTION,'Porting Ordering Subscriptions'));
      htp.para;

      htp.formOpen(curl => 'xnp_sv_orders$soa_sv.actionquery', cattributes => 'NAME="frmZero"');

      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..QF_NUMBER_OF_COLUMNS loop
	  XNP_WSGL.LayoutHeader(18, 'LEFT', NULL);
	  XNP_WSGL.LayoutHeader(40, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Porting ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('PORTING_ID', '10', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Subscription Type:'));
      InitialiseDomain('SUBSCRIPTION_TYPE');
      XNP_WSGL.LayoutData(XNP_WSGL.BuildDVControl(D_SUBSCRIPTION_TYPE, XNP_WSGL.CTL_QUERY));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Telephone:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('SUBSCRIPTION_TN', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Status:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('STATUS_DISPLAY_NAME', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Customer ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('CUSTOMER_ID', '10', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Customer Name:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('CUSTOMER_NAME', '40', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Rec. Code:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('REC_CODE', '10', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Don. Code:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('DON_CODE', '10', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('NRC Code:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('NRC_CODE', '10', FALSE));
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutClose;

      htp.p ('<SCRIPT><!--');
      htp.p ('document.write (''<input type=hidden name="Z_ACTION">'')');
      htp.p ('//-->');
      htp.p ('</SCRIPT>');
      htp.p ('<SCRIPT><!--');
      htp.p ('document.write (''' || htf.formSubmit('', htf.escape_sc(QF_QUERY_BUT_CAPTION), 'onClick="this.form.Z_ACTION.value=\''' || QF_QUERY_BUT_ACTION || '\''"') || ''')');
      htp.p ('//-->');
      htp.p ('</SCRIPT>');

      if XNP_WSGL.IsSupported ('NOSCRIPT')
      then

        htp.p ('<NOSCRIPT>');
        htp.formSubmit('Z_ACTION', htf.escape_sc(QF_QUERY_BUT_CAPTION));
        htp.p ('</NOSCRIPT>');

      end if;
      htp.formReset(htf.escape_sc(QF_CLEAR_BUT_CAPTION));

      XNP_WSGL.HiddenField('Z_CHK',
                     to_char(XNP_WSGL.Checksum('')));
      htp.formClose;

      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             QF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.FormQuery');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.FormView
--
-- Description: This procedure builds an HTML form for view/update of fields in
--              the 'SOA_SV' module component (Porting Ordering Subscriptions).
--
-- Parameters:  Z_FORM_STATUS  Status of the form
--
--------------------------------------------------------------------------------
   procedure FormView(Z_FORM_STATUS in number) is

      SOA_EVENTS_CHCK varchar2(10);
      SOA_ORDERS_CHCK varchar2(10);

    begin

      XNP_WSGL.OpenPageHead('Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions');
      xnp_sv_orders$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>VF_BODY_ATTRIBUTES);

      InitialiseDomain('SUBSCRIPTION_TYPE');
      InitialiseDomain('STATUS_PHASE');
      InitialiseDomain('ORDER_PRIORITY');
      InitialiseDomain('NEW_SP_AUTHORIZATION_FLAG');
      InitialiseDomain('OLD_SP_AUTHORIZATION_FLAG');
      InitialiseDomain('RETAIN_DIR_INFO_FLAG');
      InitialiseDomain('LOCKED_FLAG');
      InitialiseDomain('CONCURRENCE_FLAG');
      InitialiseDomain('PTO_FLAG');
      InitialiseDomain('RETAIN_TN_FLAG');
      InitialiseDomain('BLOCKED_FLAG');



      FORM_VAL.PORTING_ID := CURR_VAL.PORTING_ID;
      FORM_VAL.SUBSCRIPTION_TYPE := XNP_WSGL.DomainMeaning(D_SUBSCRIPTION_TYPE, CURR_VAL.SUBSCRIPTION_TYPE);
      FORM_VAL.SUBSCRIPTION_TN := CURR_VAL.SUBSCRIPTION_TN;
      FORM_VAL.PRE_SPLIT_SUBSCRIPTION_TN := CURR_VAL.PRE_SPLIT_SUBSCRIPTION_TN;
      FORM_VAL.ROUTING_NUMBER := CURR_VAL.ROUTING_NUMBER;
      FORM_VAL.STATUS_PHASE := XNP_WSGL.DomainMeaning(D_STATUS_PHASE, CURR_VAL.STATUS_PHASE);
      FORM_VAL.STATUS_DISPLAY_NAME := CURR_VAL.STATUS_DISPLAY_NAME;
      FORM_VAL.DSP_STATUS := NBT_VAL.DSP_STATUS;
      FORM_VAL.STATUS_CHANGE_DATE := ltrim(to_char(CURR_VAL.STATUS_CHANGE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.STATUS_CHANGE_CAUSE_CODE := CURR_VAL.STATUS_CHANGE_CAUSE_CODE;
      FORM_VAL.DSP_CUSTOMER := NBT_VAL.DSP_CUSTOMER;
      FORM_VAL.DSP_CONTACT := NBT_VAL.DSP_CONTACT;
      FORM_VAL.CUSTOMER_ID := CURR_VAL.CUSTOMER_ID;
      FORM_VAL.CUSTOMER_NAME := CURR_VAL.CUSTOMER_NAME;
      FORM_VAL.CONTACT_NAME := CURR_VAL.CONTACT_NAME;
      FORM_VAL.PHONE := CURR_VAL.PHONE;
      FORM_VAL.EMAIL := CURR_VAL.EMAIL;
      FORM_VAL.ACTIVATION_DUE_DATE := ltrim(to_char(CURR_VAL.ACTIVATION_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.ORDER_PRIORITY := XNP_WSGL.DomainMeaning(D_ORDER_PRIORITY, CURR_VAL.ORDER_PRIORITY);
      FORM_VAL.PREORDER_AUTHORIZATION_CODE := CURR_VAL.PREORDER_AUTHORIZATION_CODE;
      FORM_VAL.DSP_REC := NBT_VAL.DSP_REC;
      FORM_VAL.REC_CODE := CURR_VAL.REC_CODE;
      FORM_VAL.REC_NAME := CURR_VAL.REC_NAME;
      FORM_VAL.REC_EMAIL := CURR_VAL.REC_EMAIL;
      FORM_VAL.DSP_DON := NBT_VAL.DSP_DON;
      FORM_VAL.DON_CODE := CURR_VAL.DON_CODE;
      FORM_VAL.DON_NAME := CURR_VAL.DON_NAME;
      FORM_VAL.DON_EMAIL := CURR_VAL.DON_EMAIL;
      FORM_VAL.DSP_NRC := NBT_VAL.DSP_NRC;
      FORM_VAL.NRC_CODE := CURR_VAL.NRC_CODE;
      FORM_VAL.NRC_NAME := CURR_VAL.NRC_NAME;
      FORM_VAL.NRC_EMAIL := CURR_VAL.NRC_EMAIL;
      FORM_VAL.NEW_SP_AUTHORIZATION_FLAG := XNP_WSGL.DomainMeaning(D_NEW_SP_AUTHORIZATION_FLAG, CURR_VAL.NEW_SP_AUTHORIZATION_FLAG);
      FORM_VAL.NEW_SP_DUE_DATE := ltrim(to_char(CURR_VAL.NEW_SP_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.OLD_SP_AUTHORIZATION_FLAG := XNP_WSGL.DomainMeaning(D_OLD_SP_AUTHORIZATION_FLAG, CURR_VAL.OLD_SP_AUTHORIZATION_FLAG);
      FORM_VAL.OLD_SP_DUE_DATE := ltrim(to_char(CURR_VAL.OLD_SP_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.OLD_SP_CUTOFF_DUE_DATE := ltrim(to_char(CURR_VAL.OLD_SP_CUTOFF_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.INVOICE_DUE_DATE := ltrim(to_char(CURR_VAL.INVOICE_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.RETAIN_DIR_INFO_FLAG := XNP_WSGL.DomainMeaning(D_RETAIN_DIR_INFO_FLAG, CURR_VAL.RETAIN_DIR_INFO_FLAG);
      FORM_VAL.LOCKED_FLAG := XNP_WSGL.DomainMeaning(D_LOCKED_FLAG, CURR_VAL.LOCKED_FLAG);
      FORM_VAL.CONCURRENCE_FLAG := XNP_WSGL.DomainMeaning(D_CONCURRENCE_FLAG, CURR_VAL.CONCURRENCE_FLAG);
      FORM_VAL.PTO_FLAG := XNP_WSGL.DomainMeaning(D_PTO_FLAG, CURR_VAL.PTO_FLAG);
      FORM_VAL.DISCONNECT_DUE_DATE := ltrim(to_char(CURR_VAL.DISCONNECT_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.EFFECTIVE_RELEASE_DUE_DATE := ltrim(to_char(CURR_VAL.EFFECTIVE_RELEASE_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.RETAIN_TN_FLAG := XNP_WSGL.DomainMeaning(D_RETAIN_TN_FLAG, CURR_VAL.RETAIN_TN_FLAG);
      FORM_VAL.BLOCKED_FLAG := XNP_WSGL.DomainMeaning(D_BLOCKED_FLAG, CURR_VAL.BLOCKED_FLAG);
      FORM_VAL.NUMBER_RETURNED_DUE_DATE := ltrim(to_char(CURR_VAL.NUMBER_RETURNED_DUE_DATE, 'DD-MON-RRRR'));
      FORM_VAL.DSP_CNAM := NBT_VAL.DSP_CNAM;
      FORM_VAL.DSP_CLASS := NBT_VAL.DSP_CLASS;
      FORM_VAL.DSP_ISVM := NBT_VAL.DSP_ISVM;
      FORM_VAL.DSP_LIDB := NBT_VAL.DSP_LIDB;
      FORM_VAL.DSP_WSMSC := NBT_VAL.DSP_WSMSC;
      FORM_VAL.DSP_RN := NBT_VAL.DSP_RN;
      FORM_VAL.CLASS_ADDRESS := CURR_VAL.CLASS_ADDRESS;
      FORM_VAL.CLASS_SUBSYSTEM := CURR_VAL.CLASS_SUBSYSTEM;
      FORM_VAL.CNAM_ADDRESS := CURR_VAL.CNAM_ADDRESS;
      FORM_VAL.CNAM_SUBSYSTEM := CURR_VAL.CNAM_SUBSYSTEM;
      FORM_VAL.ISVM_ADDRESS := CURR_VAL.ISVM_ADDRESS;
      FORM_VAL.ISVM_SUBSYSTEM := CURR_VAL.ISVM_SUBSYSTEM;
      FORM_VAL.LIDB_ADDRESS := CURR_VAL.LIDB_ADDRESS;
      FORM_VAL.LIDB_SUBSYSTEM := CURR_VAL.LIDB_SUBSYSTEM;
      FORM_VAL.WSMSC_ADDRESS := CURR_VAL.WSMSC_ADDRESS;
      FORM_VAL.WSMSC_SUBSYSTEM := CURR_VAL.WSMSC_SUBSYSTEM;
      FORM_VAL.RN_ADDRESS := CURR_VAL.RN_ADDRESS;
      FORM_VAL.RN_SUBSYSTEM := CURR_VAL.RN_SUBSYSTEM;
      FORM_VAL.SV_SOA_ID := CURR_VAL.SV_SOA_ID;

      if Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_ERROR then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_UPD then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(207, XNP_WSGLM.MSG207_ROW_UPDATED),
                             'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_INS then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(208, XNP_WSGLM.MSG208_ROW_INSERTED),
                             'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', VF_BODY_ATTRIBUTES);
      end if;


      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE, P_BORDER=>TRUE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..VF_NUMBER_OF_COLUMNS loop
         XNP_WSGL.LayoutHeader(23, 'LEFT', NULL);
         XNP_WSGL.LayoutHeader(40, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Porting ID:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.PORTING_ID));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Subscription Type:'));
      XNP_WSGL.LayoutData(FORM_VAL.SUBSCRIPTION_TYPE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Telephone:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.SUBSCRIPTION_TN));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Pre-Split Number:'));
      XNP_WSGL.LayoutData(FORM_VAL.PRE_SPLIT_SUBSCRIPTION_TN);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Routing Number:'));
      XNP_WSGL.LayoutData(FORM_VAL.ROUTING_NUMBER);
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.DSP_STATUS is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('Status:'));
         XNP_WSGL.LayoutData(htf.bold(FORM_VAL.DSP_STATUS));
         XNP_WSGL.LayoutRowEnd;
      end if;
      if NBT_VAL.DSP_CUSTOMER is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('Customer:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_CUSTOMER);
         XNP_WSGL.LayoutRowEnd;
      end if;
      if NBT_VAL.DSP_CONTACT is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('Contact:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_CONTACT);
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Contact Email:'));
      XNP_WSGL.LayoutData(htf.mailto(FORM_VAL.EMAIL, FORM_VAL.EMAIL));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Activation Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.ACTIVATION_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Priority:'));
      XNP_WSGL.LayoutData(FORM_VAL.ORDER_PRIORITY);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Auth Code:'));
      XNP_WSGL.LayoutData(FORM_VAL.PREORDER_AUTHORIZATION_CODE);
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.DSP_REC is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('Recipient:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_REC);
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Rec Email:'));
      XNP_WSGL.LayoutData(htf.mailto(FORM_VAL.REC_EMAIL, FORM_VAL.REC_EMAIL));
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.DSP_DON is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('Donor:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_DON);
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Don Email:'));
      XNP_WSGL.LayoutData(htf.mailto(FORM_VAL.DON_EMAIL, FORM_VAL.DON_EMAIL));
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.DSP_NRC is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('Mediator:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_NRC);
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('NRC Email:'));
      XNP_WSGL.LayoutData(htf.mailto(FORM_VAL.NRC_EMAIL, FORM_VAL.NRC_EMAIL));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Rec. Authorized?:'));
      XNP_WSGL.LayoutData(FORM_VAL.NEW_SP_AUTHORIZATION_FLAG);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Rec. Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.NEW_SP_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Don. Authorized?:'));
      XNP_WSGL.LayoutData(FORM_VAL.OLD_SP_AUTHORIZATION_FLAG);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Don. Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.OLD_SP_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Don. Cutoff Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.OLD_SP_CUTOFF_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Invoice Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.INVOICE_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Retain Dir Info?:'));
      XNP_WSGL.LayoutData(FORM_VAL.RETAIN_DIR_INFO_FLAG);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Update Allowed?:'));
      XNP_WSGL.LayoutData(FORM_VAL.LOCKED_FLAG);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Porting To Original?:'));
      XNP_WSGL.LayoutData(FORM_VAL.PTO_FLAG);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Disconnect Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.DISCONNECT_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Eff. Release Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.EFFECTIVE_RELEASE_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Retain Number?:'));
      XNP_WSGL.LayoutData(FORM_VAL.RETAIN_TN_FLAG);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Number Blocked?:'));
      XNP_WSGL.LayoutData(FORM_VAL.BLOCKED_FLAG);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Number Return Due Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.NUMBER_RETURNED_DUE_DATE);
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.DSP_CNAM is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('CNAM Details:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_CNAM);
         XNP_WSGL.LayoutRowEnd;
      end if;
      if NBT_VAL.DSP_CLASS is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('CLASS Details:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_CLASS);
         XNP_WSGL.LayoutRowEnd;
      end if;
      if NBT_VAL.DSP_ISVM is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('ISVM Details:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_ISVM);
         XNP_WSGL.LayoutRowEnd;
      end if;
      if NBT_VAL.DSP_LIDB is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('LIDB Details:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_LIDB);
         XNP_WSGL.LayoutRowEnd;
      end if;
      if NBT_VAL.DSP_WSMSC is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('WSMSC Details:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_WSMSC);
         XNP_WSGL.LayoutRowEnd;
      end if;
      if NBT_VAL.DSP_RN is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('RN Details:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_RN);
         XNP_WSGL.LayoutRowEnd;
      end if;

      XNP_WSGL.LayoutClose;




      SOA_EVENTS_CHCK :=
         to_char(XNP_WSGL.Checksum(CURR_VAL.SV_SOA_ID));
      SOA_ORDERS_CHCK :=
         to_char(XNP_WSGL.Checksum(CURR_VAL.SV_SOA_ID));


      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'Event History',
                    0, 'xnp_sv_orders$soa_events.startup?P_SV_SOA_ID='||XNP_WSGL.EscapeURLParam(CURR_VAL.SV_SOA_ID)||'&Z_CHK='||SOA_EVENTS_CHCK);
      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'Order Workitems',
                    0, 'xnp_sv_orders$soa_orders.startup?P_SV_SOA_ID='||XNP_WSGL.EscapeURLParam(CURR_VAL.SV_SOA_ID)||'&Z_CHK='||SOA_ORDERS_CHCK);
      XNP_WSGL.NavLinks;


      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             VF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.FormView');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.QueryView
--
-- Description: Queries the details of a single row in preparation for display.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryView(
             P_SV_SOA_ID in varchar2,
             Z_POST_DML in boolean,
             Z_FORM_STATUS in number,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_sv_orders$soa_sv.queryview');
      XNP_WSGL.AddURLParam('P_SV_SOA_ID', P_SV_SOA_ID);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('' ||
                                      P_SV_SOA_ID, Z_CHK) then
            return;
         end if;
      end if;


      if P_SV_SOA_ID is not null then
         CURR_VAL.SV_SOA_ID := P_SV_SOA_ID;
      end if;
      if Z_POST_DML then

         null;

      else

         SELECT XNP_SV_SOA_VL.PORTING_ID,
                XNP_SV_SOA_VL.SUBSCRIPTION_TYPE,
                XNP_SV_SOA_VL.SUBSCRIPTION_TN,
                XNP_SV_SOA_VL.PRE_SPLIT_SUBSCRIPTION_TN,
                XNP_SV_SOA_VL.ROUTING_NUMBER,
                XNP_SV_SOA_VL.STATUS_PHASE,
                XNP_SV_SOA_VL.STATUS_DISPLAY_NAME,
                XNP_SV_SOA_VL.STATUS_CHANGE_DATE,
                XNP_SV_SOA_VL.STATUS_CHANGE_CAUSE_CODE,
                XNP_SV_SOA_VL.CUSTOMER_ID,
                XNP_SV_SOA_VL.CUSTOMER_NAME,
                XNP_SV_SOA_VL.CONTACT_NAME,
                XNP_SV_SOA_VL.PHONE,
                XNP_SV_SOA_VL.EMAIL,
                XNP_SV_SOA_VL.ACTIVATION_DUE_DATE,
                XNP_SV_SOA_VL.ORDER_PRIORITY,
                XNP_SV_SOA_VL.PREORDER_AUTHORIZATION_CODE,
                XNP_SV_SOA_VL.REC_CODE,
                XNP_SV_SOA_VL.REC_NAME,
                XNP_SV_SOA_VL.REC_EMAIL,
                XNP_SV_SOA_VL.DON_CODE,
                XNP_SV_SOA_VL.DON_NAME,
                XNP_SV_SOA_VL.DON_EMAIL,
                XNP_SV_SOA_VL.NRC_CODE,
                XNP_SV_SOA_VL.NRC_NAME,
                XNP_SV_SOA_VL.NRC_EMAIL,
                XNP_SV_SOA_VL.NEW_SP_AUTHORIZATION_FLAG,
                XNP_SV_SOA_VL.NEW_SP_DUE_DATE,
                XNP_SV_SOA_VL.OLD_SP_AUTHORIZATION_FLAG,
                XNP_SV_SOA_VL.OLD_SP_DUE_DATE,
                XNP_SV_SOA_VL.OLD_SP_CUTOFF_DUE_DATE,
                XNP_SV_SOA_VL.INVOICE_DUE_DATE,
                XNP_SV_SOA_VL.RETAIN_DIR_INFO_FLAG,
                XNP_SV_SOA_VL.LOCKED_FLAG,
                XNP_SV_SOA_VL.CONCURRENCE_FLAG,
                XNP_SV_SOA_VL.PTO_FLAG,
                XNP_SV_SOA_VL.DISCONNECT_DUE_DATE,
                XNP_SV_SOA_VL.EFFECTIVE_RELEASE_DUE_DATE,
                XNP_SV_SOA_VL.RETAIN_TN_FLAG,
                XNP_SV_SOA_VL.BLOCKED_FLAG,
                XNP_SV_SOA_VL.NUMBER_RETURNED_DUE_DATE,
                XNP_SV_SOA_VL.CLASS_ADDRESS,
                XNP_SV_SOA_VL.CLASS_SUBSYSTEM,
                XNP_SV_SOA_VL.CNAM_ADDRESS,
                XNP_SV_SOA_VL.CNAM_SUBSYSTEM,
                XNP_SV_SOA_VL.ISVM_ADDRESS,
                XNP_SV_SOA_VL.ISVM_SUBSYSTEM,
                XNP_SV_SOA_VL.LIDB_ADDRESS,
                XNP_SV_SOA_VL.LIDB_SUBSYSTEM,
                XNP_SV_SOA_VL.WSMSC_ADDRESS,
                XNP_SV_SOA_VL.WSMSC_SUBSYSTEM,
                XNP_SV_SOA_VL.RN_ADDRESS,
                XNP_SV_SOA_VL.RN_SUBSYSTEM,
                XNP_SV_SOA_VL.SV_SOA_ID
         INTO   CURR_VAL.PORTING_ID,
                CURR_VAL.SUBSCRIPTION_TYPE,
                CURR_VAL.SUBSCRIPTION_TN,
                CURR_VAL.PRE_SPLIT_SUBSCRIPTION_TN,
                CURR_VAL.ROUTING_NUMBER,
                CURR_VAL.STATUS_PHASE,
                CURR_VAL.STATUS_DISPLAY_NAME,
                CURR_VAL.STATUS_CHANGE_DATE,
                CURR_VAL.STATUS_CHANGE_CAUSE_CODE,
                CURR_VAL.CUSTOMER_ID,
                CURR_VAL.CUSTOMER_NAME,
                CURR_VAL.CONTACT_NAME,
                CURR_VAL.PHONE,
                CURR_VAL.EMAIL,
                CURR_VAL.ACTIVATION_DUE_DATE,
                CURR_VAL.ORDER_PRIORITY,
                CURR_VAL.PREORDER_AUTHORIZATION_CODE,
                CURR_VAL.REC_CODE,
                CURR_VAL.REC_NAME,
                CURR_VAL.REC_EMAIL,
                CURR_VAL.DON_CODE,
                CURR_VAL.DON_NAME,
                CURR_VAL.DON_EMAIL,
                CURR_VAL.NRC_CODE,
                CURR_VAL.NRC_NAME,
                CURR_VAL.NRC_EMAIL,
                CURR_VAL.NEW_SP_AUTHORIZATION_FLAG,
                CURR_VAL.NEW_SP_DUE_DATE,
                CURR_VAL.OLD_SP_AUTHORIZATION_FLAG,
                CURR_VAL.OLD_SP_DUE_DATE,
                CURR_VAL.OLD_SP_CUTOFF_DUE_DATE,
                CURR_VAL.INVOICE_DUE_DATE,
                CURR_VAL.RETAIN_DIR_INFO_FLAG,
                CURR_VAL.LOCKED_FLAG,
                CURR_VAL.CONCURRENCE_FLAG,
                CURR_VAL.PTO_FLAG,
                CURR_VAL.DISCONNECT_DUE_DATE,
                CURR_VAL.EFFECTIVE_RELEASE_DUE_DATE,
                CURR_VAL.RETAIN_TN_FLAG,
                CURR_VAL.BLOCKED_FLAG,
                CURR_VAL.NUMBER_RETURNED_DUE_DATE,
                CURR_VAL.CLASS_ADDRESS,
                CURR_VAL.CLASS_SUBSYSTEM,
                CURR_VAL.CNAM_ADDRESS,
                CURR_VAL.CNAM_SUBSYSTEM,
                CURR_VAL.ISVM_ADDRESS,
                CURR_VAL.ISVM_SUBSYSTEM,
                CURR_VAL.LIDB_ADDRESS,
                CURR_VAL.LIDB_SUBSYSTEM,
                CURR_VAL.WSMSC_ADDRESS,
                CURR_VAL.WSMSC_SUBSYSTEM,
                CURR_VAL.RN_ADDRESS,
                CURR_VAL.RN_SUBSYSTEM,
                CURR_VAL.SV_SOA_ID
         FROM   XNP_SV_SOA_VL XNP_SV_SOA_VL
         WHERE  XNP_SV_SOA_VL.SV_SOA_ID = CURR_VAL.SV_SOA_ID
         ;

      end if;

      NBT_VAL.DSP_STATUS := CURR_VAL.STATUS_DISPLAY_NAME || '  (' || CURR_VAL.STATUS_PHASE || ') on ' || to_char(CURR_VAL.STATUS_CHANGE_DATE,'DD-MON-YYYY') || '   ' || CURR_VAL.STATUS_CHANGE_CAUSE_CODE;
      NBT_VAL.DSP_CUSTOMER := (CURR_VAL.CUSTOMER_ID || ' - ' || CURR_VAL.CUSTOMER_NAME );
      NBT_VAL.DSP_CONTACT := ( CURR_VAL.CONTACT_NAME || ' - ' || CURR_VAL.PHONE );
      NBT_VAL.DSP_REC := ( CURR_VAL.REC_CODE || ' - ' || CURR_VAL.REC_NAME );
      NBT_VAL.DSP_DON := ( CURR_VAL.DON_CODE || ' - ' || CURR_VAL.DON_NAME );
      NBT_VAL.DSP_NRC := ( CURR_VAL.NRC_CODE || ' - ' || CURR_VAL.NRC_NAME );
      NBT_VAL.DSP_CNAM := ('Address : ' || CURR_VAL.CNAM_ADDRESS ||  ' - Subsystem : ' || CURR_VAL.CNAM_SUBSYSTEM);
      NBT_VAL.DSP_CLASS := ('Address : ' || CURR_VAL.CLASS_ADDRESS ||  ' - Subsystem : ' || CURR_VAL.CLASS_SUBSYSTEM);
      NBT_VAL.DSP_ISVM := ('Address : ' || CURR_VAL.ISVM_ADDRESS ||  ' - Subsystem : ' || CURR_VAL.ISVM_SUBSYSTEM);
      NBT_VAL.DSP_LIDB := ('Address : ' || CURR_VAL.LIDB_ADDRESS ||  ' - Subsystem : ' || CURR_VAL.LIDB_SUBSYSTEM);
      NBT_VAL.DSP_WSMSC := ('Address : ' || CURR_VAL.WSMSC_ADDRESS ||  ' - Subsystem : ' || CURR_VAL.WSMSC_SUBSYSTEM);
      NBT_VAL.DSP_RN := ('Address : ' || CURR_VAL.RN_ADDRESS ||  ' - Subsystem : ' || CURR_VAL.RN_SUBSYSTEM);

      if not PostQuery(Z_POST_DML) then
         FormView(XNP_WSGL.FORM_STATUS_ERROR);
      else
         FormView(Z_FORM_STATUS);
      end if;

   exception
      when NO_DATA_FOUND then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_WSGL.MsgGetText(204, XNP_WSGLM.MSG204_ROW_DELETED),
                             'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', VF_BODY_ATTRIBUTES);
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             VF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.QueryView');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.QueryList
--
-- Description: This procedure builds the Record list for the 'SOA_SV'
--              module component (Porting Ordering Subscriptions).
--
--              The Record List displays context information for records which
--              match the specified query criteria.
--              Sets of records are displayed (10 records at a time)
--              with Next/Previous buttons to get other record sets.
--
--              The first context column will be created as a link to the
--              xnp_sv_orders$soa_sv.FormView procedure for display of more details
--              of that particular row.
--
-- Parameters:  P_PORTING_ID - Porting ID
--              P_SUBSCRIPTION_TYPE - Subscription Type
--              P_SUBSCRIPTION_TN - Telephone
--              P_STATUS_DISPLAY_NAME - Status
--              P_CUSTOMER_ID - Customer ID
--              P_CUSTOMER_NAME - Customer Name
--              P_REC_CODE - Rec. Code
--              P_DON_CODE - Don. Code
--              P_NRC_CODE - NRC Code
--              Z_START - First record to display
--              Z_ACTION - Next or Previous set
--
--------------------------------------------------------------------------------
   procedure QueryList(
             P_PORTING_ID in varchar2,
             P_SUBSCRIPTION_TYPE in varchar2,
             P_SUBSCRIPTION_TN in varchar2,
             P_STATUS_DISPLAY_NAME in varchar2,
             P_CUSTOMER_ID in varchar2,
             P_CUSTOMER_NAME in varchar2,
             P_REC_CODE in varchar2,
             P_DON_CODE in varchar2,
             P_NRC_CODE in varchar2,
             Z_START in varchar2,
             Z_ACTION in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is

      L_VF_FRAME          varchar2(20) := 'fraVF';
      I_WHERE             varchar2(2000) := '';
      I_CURSOR            integer;
      I_VOID              integer;
      I_ROWS_FETCHED      integer := 0;
      I_TOTAL_ROWS        integer := 0;
      I_START             number(6) := to_number(Z_START);
      I_COUNT             number(10) := 0;
      I_OF_TOTAL_TEXT     varchar2(200) := '';
      I_NEXT_BUT          boolean;
      I_PREV_BUT          boolean;
      SOA_EVENTS_CHCK  varchar2(10);
      SOA_ORDERS_CHCK  varchar2(10);
      L_CHECKSUM          varchar2(10);

   begin

      XNP_WSGL.RegisterURL('xnp_sv_orders$soa_sv.querylist');
      XNP_WSGL.AddURLParam('P_PORTING_ID', P_PORTING_ID);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TYPE', P_SUBSCRIPTION_TYPE);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TN', P_SUBSCRIPTION_TN);
      XNP_WSGL.AddURLParam('P_STATUS_DISPLAY_NAME', P_STATUS_DISPLAY_NAME);
      XNP_WSGL.AddURLParam('P_CUSTOMER_ID', P_CUSTOMER_ID);
      XNP_WSGL.AddURLParam('P_CUSTOMER_NAME', P_CUSTOMER_NAME);
      XNP_WSGL.AddURLParam('P_REC_CODE', P_REC_CODE);
      XNP_WSGL.AddURLParam('P_DON_CODE', P_DON_CODE);
      XNP_WSGL.AddURLParam('P_NRC_CODE', P_NRC_CODE);
      XNP_WSGL.AddURLParam('Z_START', Z_START);
      XNP_WSGL.AddURLParam('Z_ACTION', Z_ACTION);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      if (Z_ACTION = RL_QUERY_BUT_ACTION) or (Z_ACTION = RL_QUERY_BUT_CAPTION) then
         FormQuery(
         Z_DIRECT_CALL=>TRUE);
         return;
      end if;

      XNP_WSGL.OpenPageHead('Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions');
      CreateListJavaScript;
      xnp_sv_orders$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>RL_BODY_ATTRIBUTES);

      if (Z_ACTION = RL_LAST_BUT_ACTION) or (Z_ACTION = RL_LAST_BUT_CAPTION) or
         (Z_ACTION = RL_COUNT_BUT_ACTION) or (Z_ACTION = RL_COUNT_BUT_CAPTION) or
         (RL_TOTAL_COUNT_REQD)
      then

         I_COUNT := QueryHits(
                    P_PORTING_ID,
                    P_SUBSCRIPTION_TYPE,
                    P_SUBSCRIPTION_TN,
                    P_STATUS_DISPLAY_NAME,
                    P_CUSTOMER_ID,
                    P_CUSTOMER_NAME,
                    P_REC_CODE,
                    P_DON_CODE,
                    P_NRC_CODE);
         if I_COUNT = -1 then
            XNP_WSGL.ClosePageBody;
            return;
         end if;
      end if;

      if (Z_ACTION = RL_COUNT_BUT_ACTION) or (Z_ACTION = RL_COUNT_BUT_CAPTION) or
         RL_TOTAL_COUNT_REQD then
         I_OF_TOTAL_TEXT := ' '||XNP_WSGL.MsgGetText(111,XNP_WSGLM.DSP111_OF_TOTAL, to_char(I_COUNT));
      end if;

      if Z_START IS NULL or (Z_ACTION = RL_FIRST_BUT_ACTION) or (Z_ACTION = RL_FIRST_BUT_CAPTION) then
         I_START := 1;
      elsif (Z_ACTION = RL_NEXT_BUT_ACTION) or (Z_ACTION = RL_NEXT_BUT_CAPTION) then
         I_START := I_START + RL_RECORD_SET_SIZE;
      elsif (Z_ACTION = RL_PREV_BUT_ACTION) or (Z_ACTION = RL_PREV_BUT_CAPTION) then
         I_START := I_START - RL_RECORD_SET_SIZE;
      elsif (Z_ACTION = RL_LAST_BUT_ACTION) or (Z_ACTION = RL_LAST_BUT_CAPTION) then
         I_START := 1 + (floor((I_COUNT-1)/RL_RECORD_SET_SIZE)*RL_RECORD_SET_SIZE);
      elsif Z_ACTION is null and I_START = 1 then
	 null;
      elsif Z_ACTION IS NULL then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_WSGL.MsgGetText(215,XNP_WSGLM.MSG215_NO_MULTIPLE_SUBMITS),
                             'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', RL_BODY_ATTRIBUTES);
         XNP_WSGL.ClosePageBody;
         return;
      end if;

      if I_START < 1 then
          I_START := 1;
      end if;

      I_PREV_BUT := TRUE;
      I_NEXT_BUT := FALSE;
      if I_START = 1 or Z_ACTION IS NULL then
         I_PREV_BUT := FALSE;
      end if;

      if nvl(Z_ACTION, 'X') <> 'DONTQUERY' then

         if ZONE_SQL IS NULL then
            if not BuildSQL(
                       P_PORTING_ID,
                       P_SUBSCRIPTION_TYPE,
                       P_SUBSCRIPTION_TN,
                       P_STATUS_DISPLAY_NAME,
                       P_CUSTOMER_ID,
                       P_CUSTOMER_NAME,
                       P_REC_CODE,
                       P_DON_CODE,
                       P_NRC_CODE) then
               XNP_WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if not PreQuery(
                       P_PORTING_ID,
                       P_SUBSCRIPTION_TYPE,
                       P_SUBSCRIPTION_TN,
                       P_STATUS_DISPLAY_NAME,
                       P_CUSTOMER_ID,
                       P_CUSTOMER_NAME,
                       P_REC_CODE,
                       P_DON_CODE,
                       P_NRC_CODE) then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                                'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', RL_BODY_ATTRIBUTES);
         return;
         end if;



         I_CURSOR := dbms_sql.open_cursor;
         dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
         dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.PORTING_ID, 80);
         dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.SUBSCRIPTION_TN, 20);
         dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.STATUS_DISPLAY_NAME, 40);
         dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.SV_SOA_ID);

         I_VOID := dbms_sql.execute(I_CURSOR);
         I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);
      else
         I_ROWS_FETCHED := 0;
      end if;
      I_TOTAL_ROWS := I_ROWS_FETCHED;

      if I_ROWS_FETCHED <> 0 then

         XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE, P_BORDER=>TRUE);

         XNP_WSGL.LayoutRowStart;
         for i in 1..RL_NUMBER_OF_COLUMNS loop
      	    XNP_WSGL.LayoutHeader(10, 'LEFT', 'Porting ID');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Telephone');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Status');
         end loop;
         XNP_WSGL.LayoutRowEnd;

         while I_ROWS_FETCHED <> 0 loop

            if I_TOTAL_ROWS >= I_START then
               dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.PORTING_ID);
               dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.SUBSCRIPTION_TN);
               dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.STATUS_DISPLAY_NAME);
               dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.SV_SOA_ID);
               L_CHECKSUM := to_char(XNP_WSGL.Checksum(''||CURR_VAL.SV_SOA_ID));


               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData(htf.anchor2('xnp_sv_orders$soa_sv.queryview?P_SV_SOA_ID='||CURR_VAL.SV_SOA_ID||'&Z_CHK='||L_CHECKSUM, CURR_VAL.PORTING_ID, ctarget=>L_VF_FRAME));
               XNP_WSGL.LayoutData(CURR_VAL.SUBSCRIPTION_TN);
               XNP_WSGL.LayoutData(CURR_VAL.STATUS_DISPLAY_NAME);
               XNP_WSGL.LayoutRowEnd;

               I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);
               if I_TOTAL_ROWS = I_START + RL_RECORD_SET_SIZE - 1 then
                  if I_ROWS_FETCHED <> 0 then
                     I_NEXT_BUT := TRUE;
                  end if;
                  exit;
               end if;
            else
               I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);
            end if;

            I_TOTAL_ROWS := I_TOTAL_ROWS + I_ROWS_FETCHED;

         end loop;

         XNP_WSGL.LayoutClose;

         if I_START = I_TOTAL_ROWS then
            htp.p(XNP_WSGL.MsgGetText(109,XNP_WSGLM.DSP109_RECORD, to_char(I_TOTAL_ROWS))||I_OF_TOTAL_TEXT);
         else
            htp.p(XNP_WSGL.MsgGetText(110,XNP_WSGLM.DSP110_RECORDS_N_M,
                                  to_char(I_START), to_char(I_TOTAL_ROWS))||
                  I_OF_TOTAL_TEXT);
         end if;
         htp.para;
      else
         htp.p(XNP_WSGL.MsgGetText(112,XNP_WSGLM.DSP112_NO_RECORDS));
      end if;

      if nvl(Z_ACTION, 'X') <> 'DONTQUERY' then
         dbms_sql.close_cursor(I_CURSOR);
      end if;

      htp.formOpen(curl => 'xnp_sv_orders$soa_sv.querylist', cattributes => 'NAME="frmZero"');
      XNP_WSGL.HiddenField('P_PORTING_ID', P_PORTING_ID);
      XNP_WSGL.HiddenField('P_SUBSCRIPTION_TYPE', P_SUBSCRIPTION_TYPE);
      XNP_WSGL.HiddenField('P_SUBSCRIPTION_TN', P_SUBSCRIPTION_TN);
      XNP_WSGL.HiddenField('P_STATUS_DISPLAY_NAME', P_STATUS_DISPLAY_NAME);
      XNP_WSGL.HiddenField('P_CUSTOMER_ID', P_CUSTOMER_ID);
      XNP_WSGL.HiddenField('P_CUSTOMER_NAME', P_CUSTOMER_NAME);
      XNP_WSGL.HiddenField('P_REC_CODE', P_REC_CODE);
      XNP_WSGL.HiddenField('P_DON_CODE', P_DON_CODE);
      XNP_WSGL.HiddenField('P_NRC_CODE', P_NRC_CODE);
      XNP_WSGL.HiddenField('Z_START', to_char(I_START));
      htp.p ('<SCRIPT><!--');
      htp.p ('document.write (''<input type=hidden name="Z_ACTION">'')');
      htp.p ('//-->');
      htp.p ('</SCRIPT>');

      XNP_WSGL.RecordListButton(I_PREV_BUT, 'Z_ACTION', htf.escape_sc(RL_FIRST_BUT_CAPTION),                            XNP_WSGL.MsgGetText(213,XNP_WSGLM.MSG213_AT_FIRST),			    FALSE,
                            'onClick="this.form.Z_ACTION.value=\''' || RL_FIRST_BUT_ACTION || '\''"');
      XNP_WSGL.RecordListButton(I_PREV_BUT, 'Z_ACTION', htf.escape_sc(RL_PREV_BUT_CAPTION),                            XNP_WSGL.MsgGetText(213,XNP_WSGLM.MSG213_AT_FIRST),			    FALSE,
                            'onClick="this.form.Z_ACTION.value=\''' || RL_PREV_BUT_ACTION || '\''"');
      XNP_WSGL.RecordListButton(I_NEXT_BUT,'Z_ACTION', htf.escape_sc(RL_NEXT_BUT_CAPTION),                            XNP_WSGL.MsgGetText(214,XNP_WSGLM.MSG214_AT_LAST),			    FALSE,
                            'onClick="this.form.Z_ACTION.value=\''' || RL_NEXT_BUT_ACTION || '\''"');
      XNP_WSGL.RecordListButton(I_NEXT_BUT,'Z_ACTION', htf.escape_sc(RL_LAST_BUT_CAPTION),                            XNP_WSGL.MsgGetText(214,XNP_WSGLM.MSG214_AT_LAST),			    FALSE,
                            'onClick="this.form.Z_ACTION.value=\''' || RL_LAST_BUT_ACTION || '\''"');

      XNP_WSGL.RecordListButton(TRUE, 'Z_ACTION', htf.escape_sc(RL_REQUERY_BUT_CAPTION),p_dojs=>FALSE,
                            buttonJS => 'onClick="this.form.Z_ACTION.value=\''' || RL_REQUERY_BUT_ACTION || '\''"');
      XNP_WSGL.HiddenField('Z_CHK',
                     to_char(XNP_WSGL.Checksum('')));
      htp.formClose;

      htp.formOpen(curl => 'xnp_sv_orders$soa_sv.querylist', ctarget=>'_top', cattributes => 'NAME="frmOne"');
      htp.p ('<SCRIPT><!--');
      htp.p ('document.write (''<input type=hidden name="Z_ACTION">'')');
      htp.p ('//-->');
      htp.p ('</SCRIPT>');
      htp.p ('<SCRIPT><!--');
      htp.p ('document.write (''' || htf.formSubmit('', htf.escape_sc(RL_QUERY_BUT_CAPTION), 'onClick="this.form.Z_ACTION.value=\''' || RL_QUERY_BUT_ACTION || '\''"') || ''')');
      htp.p ('//-->');
      htp.p ('</SCRIPT>');

      if XNP_WSGL.IsSupported ('NOSCRIPT')
      then

        htp.p ('<NOSCRIPT>');
        htp.formSubmit('Z_ACTION', htf.escape_sc(RL_QUERY_BUT_CAPTION));
        htp.p ('</NOSCRIPT>');

      end if;
      XNP_WSGL.HiddenField('Z_CHK',
                     to_char(XNP_WSGL.Checksum('')));
      htp.formClose;

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             RL_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.QueryList');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.QueryFirst
--
-- Description: Finds the first row which matches the given search criteria
--              (if any), and calls QueryView for that row
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryFirst(
             P_PORTING_ID in varchar2,
             P_SUBSCRIPTION_TYPE in varchar2,
             P_SUBSCRIPTION_TN in varchar2,
             P_STATUS_DISPLAY_NAME in varchar2,
             P_CUSTOMER_ID in varchar2,
             P_CUSTOMER_NAME in varchar2,
             P_REC_CODE in varchar2,
             P_DON_CODE in varchar2,
             P_NRC_CODE in varchar2,
             Z_ACTION in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is

      I_CURSOR            integer;
      I_VOID              integer;
      I_ROWS_FETCHED      integer := 0;

   begin

      XNP_WSGL.RegisterURL('xnp_sv_orders$soa_sv.queryfirst');
      XNP_WSGL.AddURLParam('P_PORTING_ID', P_PORTING_ID);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TYPE', P_SUBSCRIPTION_TYPE);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TN', P_SUBSCRIPTION_TN);
      XNP_WSGL.AddURLParam('P_STATUS_DISPLAY_NAME', P_STATUS_DISPLAY_NAME);
      XNP_WSGL.AddURLParam('P_CUSTOMER_ID', P_CUSTOMER_ID);
      XNP_WSGL.AddURLParam('P_CUSTOMER_NAME', P_CUSTOMER_NAME);
      XNP_WSGL.AddURLParam('P_REC_CODE', P_REC_CODE);
      XNP_WSGL.AddURLParam('P_DON_CODE', P_DON_CODE);
      XNP_WSGL.AddURLParam('P_NRC_CODE', P_NRC_CODE);
      XNP_WSGL.AddURLParam('Z_ACTION', Z_ACTION);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      if Z_ACTION = 'BLANK' then
         XNP_WSGL.EmptyPage(VF_BODY_ATTRIBUTES);
         return;
      end if;


      if not BuildSQL(
                    P_PORTING_ID,
                    P_SUBSCRIPTION_TYPE,
                    P_SUBSCRIPTION_TN,
                    P_STATUS_DISPLAY_NAME,
                    P_CUSTOMER_ID,
                    P_CUSTOMER_NAME,
                    P_REC_CODE,
                    P_DON_CODE,
                    P_NRC_CODE) then
         return;
      end if;

      if not PreQuery(
                    P_PORTING_ID,
                    P_SUBSCRIPTION_TYPE,
                    P_SUBSCRIPTION_TN,
                    P_STATUS_DISPLAY_NAME,
                    P_CUSTOMER_ID,
                    P_CUSTOMER_NAME,
                    P_REC_CODE,
                    P_DON_CODE,
                    P_NRC_CODE) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions', VF_BODY_ATTRIBUTES);
         return;
      end if;

      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.PORTING_ID, 80);
      dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.SUBSCRIPTION_TN, 20);
      dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.STATUS_DISPLAY_NAME, 40);
      dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.SV_SOA_ID);

      I_VOID := dbms_sql.execute(I_CURSOR);

      I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);

      if I_ROWS_FETCHED = 0 then
         XNP_WSGL.EmptyPage(VF_BODY_ATTRIBUTES);
      else
         dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.PORTING_ID);
         dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.SUBSCRIPTION_TN);
         dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.STATUS_DISPLAY_NAME);
         dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.SV_SOA_ID);
         xnp_sv_orders$soa_sv.QueryView(Z_DIRECT_CALL=>TRUE);
      end if;

      dbms_sql.close_cursor(I_CURSOR);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             VF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.QueryFirst');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'SOA_SV' module component  (Porting Ordering Subscriptions).
--
-- Parameters:  None
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PreQuery(
            P_PORTING_ID in varchar2,
            P_SUBSCRIPTION_TYPE in varchar2,
            P_SUBSCRIPTION_TN in varchar2,
            P_STATUS_DISPLAY_NAME in varchar2,
            P_CUSTOMER_ID in varchar2,
            P_CUSTOMER_NAME in varchar2,
            P_REC_CODE in varchar2,
            P_DON_CODE in varchar2,
            P_NRC_CODE in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'SOA_SV' module component  (Porting Ordering Subscriptions).
--
-- Parameters:  Z_POST_DML  Flag indicating if Query after insert or update
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PostQuery(Z_POST_DML in boolean) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
       return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.PostQuery');
          return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.CreateQueryJavaScript
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure CreateQueryJavaScript is
   begin
      htp.p(XNP_WSGJSL.OpenScript);
      htp.p('var FormType = "Query";');
      htp.p(XNP_WSGJSL.CloseScript);
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             QF_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.CreateQueryJavaScript');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_orders$soa_sv.CreateListJavaScript
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure CreateListJavaScript is
   begin
      htp.p(XNP_WSGJSL.OpenScript);
      htp.p('var FormType = "List";');
      htp.p(XNP_WSGJSL.CloseScript);
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Ordering Subscriptions'||' : '||'Porting Ordering Subscriptions',
                             RL_BODY_ATTRIBUTES, 'xnp_sv_orders$soa_sv.CreateListJavaScript');
   end;
end;

/
