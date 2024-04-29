--------------------------------------------------------
--  DDL for Package Body XNP_MSG_DIAGNOSTICS$XNP_MSGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_MSG_DIAGNOSTICS$XNP_MSGS" as
/* $Header: XNPMSG2B.pls 120.1.12010000.2 2008/09/25 05:19:13 mpathani ship $ */


   procedure FormView(Z_FORM_STATUS in number);
   function BuildSQL(
            P_MSG_ID in varchar2 default null,
            P_MSG_CODE in varchar2 default null,
            P_L_MTE_MSG_TYPE in varchar2 default null,
            P_MSG_STATUS in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_OPP_REFERENCE_ID in varchar2 default null,
            P_RECIPIENT_NAME in varchar2 default null,
            P_SENDER_NAME in varchar2 default null,
            P_ADAPTER_NAME in varchar2 default null,
            P_FE_NAME in varchar2 default null,
            P_ORDER_ID in varchar2 default null,
            P_WI_INSTANCE_ID in varchar2 default null,
            P_FA_INSTANCE_ID in varchar2 default null) return boolean;
   function PreQuery(
            P_MSG_ID in varchar2 default null,
            P_MSG_CODE in varchar2 default null,
            P_L_MTE_MSG_TYPE in varchar2 default null,
            P_MSG_STATUS in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_OPP_REFERENCE_ID in varchar2 default null,
            P_RECIPIENT_NAME in varchar2 default null,
            P_SENDER_NAME in varchar2 default null,
            P_ADAPTER_NAME in varchar2 default null,
            P_FE_NAME in varchar2 default null,
            P_ORDER_ID in varchar2 default null,
            P_WI_INSTANCE_ID in varchar2 default null,
            P_FA_INSTANCE_ID in varchar2 default null) return boolean;
   function PostQuery(Z_POST_DML in boolean) return boolean;
   procedure CreateQueryJavaScript;
   procedure CreateListJavaScript;
   procedure InitialiseDomain(P_ALIAS in varchar2);
   function MSG_CODE_TranslateFK(
            P_MSG_CODE in varchar2 default null,
            P_L_MTE_MSG_TYPE in varchar2 default null,
            Z_MODE in varchar2 default 'D') return boolean;

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
   RL_REQUERY_BUT_CAPTION constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_REFRESH_BUTTON'));
   RL_QUERY_BUT_CAPTION  constant varchar2(100)  := htf.escape_sc(fnd_message.get_string('XNP','WEB_SEARCH_BUTTON'));
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

   CURR_VAL XNP_MSGS%ROWTYPE;

   -- Accomodating CLOB changes

   CURR_VAL_BODY_TEXT	CLOB ;
   l_amount_to_read     INTEGER ;


   TYPE FORM_REC IS RECORD
        (MSG_ID              VARCHAR2(20)
        ,XML_PAYLOAD_LINK    VARCHAR2(2000)
        ,MSG_CODE            VARCHAR2(20)
        ,L_MTE_MSG_TYPE      VARCHAR2(10)
        ,MSG_STATUS          VARCHAR2(20)
        ,DIRECTION_INDICATOR VARCHAR2(10)
        ,REFERENCE_ID        VARCHAR2(2000)
        ,OPP_REFERENCE_ID    VARCHAR2(2000)
        ,VERSION             VARCHAR2(5)
        ,MSG_CREATION_DATE   VARCHAR2(20)
        ,SEND_RCV_DATE       VARCHAR2(12)
        ,RECIPIENT_NAME      VARCHAR2(40)
        ,SENDER_NAME         VARCHAR2(300) -- increased the size from 40 to 300 for the bug 6880763
        ,ADAPTER_NAME        VARCHAR2(40)
        ,FE_NAME             VARCHAR2(40)
        ,ORDER_ID            VARCHAR2(40)
        ,WI_INSTANCE_ID      VARCHAR2(40)
        ,FA_INSTANCE_ID      VARCHAR2(40)
        ,PRIORITY            VARCHAR2(10)
        ,LAST_COMPILED_DATE  VARCHAR2(12)
        ,DESCRIPTION         VARCHAR2(2000)
        ,RESEND_LINK         VARCHAR2(2000)
        ,BODY_TEXT           VARCHAR2(32767)
        ,L_MTE_DEFAULT_PROCESS_LOGIC VARCHAR2(4000)
        ,L_MTE_IN_PROCESS_LOGIC VARCHAR2(4000)
        ,L_MTE_VALIDATE_LOGIC VARCHAR2(4000)
        ,L_MTE_OUT_PROCESS_LOGIC VARCHAR2(4000)
        );
   FORM_VAL   FORM_REC;

   TYPE NBT_REC IS RECORD
        (XML_PAYLOAD_LINK    VARCHAR2(2000)
        ,L_MTE_MSG_TYPE      XNP_MSG_TYPES_B.MSG_TYPE%TYPE
        ,PRIORITY            XNP_MSG_TYPES_B.PRIORITY%TYPE
        ,LAST_COMPILED_DATE  XNP_MSG_TYPES_B.LAST_COMPILED_DATE%TYPE
        ,RESEND_LINK         VARCHAR2(2000)
        ,L_MTE_DEFAULT_PROCESS_LOGIC XNP_MSG_TYPES_B.DEFAULT_PROCESS_LOGIC%TYPE
        ,L_MTE_IN_PROCESS_LOGIC XNP_MSG_TYPES_B.IN_PROCESS_LOGIC%TYPE
        ,L_MTE_VALIDATE_LOGIC XNP_MSG_TYPES_B.VALIDATE_LOGIC%TYPE
        ,L_MTE_OUT_PROCESS_LOGIC XNP_MSG_TYPES_B.OUT_PROCESS_LOGIC%TYPE
        );
   NBT_VAL    NBT_REC;

   ZONE_SQL   VARCHAR2(4500) := null;

   D_L_MTE_MSG_TYPE      XNP_WSGL.typDVRecord;
   D_MSG_STATUS          XNP_WSGL.typDVRecord;
   D_DIRECTION_INDICATOR XNP_WSGL.typDVRecord;
   D_PRIORITY            XNP_WSGL.typDVRecord;
--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.InitialiseDomain
--
-- Description: Initialises the Domain Record for the given Column Usage
--
-- Parameters:  P_ALIAS   The alias of the column usage
--
--------------------------------------------------------------------------------
   procedure InitialiseDomain(P_ALIAS in varchar2) is
   begin

      if P_ALIAS = 'L_MTE_MSG_TYPE' and not D_L_MTE_MSG_TYPE.Initialised then
         D_L_MTE_MSG_TYPE.ColAlias := 'L_MTE_MSG_TYPE';
         D_L_MTE_MSG_TYPE.ControlType := XNP_WSGL.DV_TEXT;
         D_L_MTE_MSG_TYPE.DispWidth := 10;
         D_L_MTE_MSG_TYPE.DispHeight := 1;
         D_L_MTE_MSG_TYPE.MaxWidth := 10;
         D_L_MTE_MSG_TYPE.UseMeanings := True;
         D_L_MTE_MSG_TYPE.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_MSG_TYPE', D_L_MTE_MSG_TYPE);
         D_L_MTE_MSG_TYPE.Initialised := True;
      end if;

      if P_ALIAS = 'MSG_STATUS' and not D_MSG_STATUS.Initialised then
         D_MSG_STATUS.ColAlias := 'MSG_STATUS';
         D_MSG_STATUS.ControlType := XNP_WSGL.DV_TEXT;
         D_MSG_STATUS.DispWidth := 20;
         D_MSG_STATUS.DispHeight := 1;
         D_MSG_STATUS.MaxWidth := 20;
         D_MSG_STATUS.UseMeanings := True;
         D_MSG_STATUS.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_MSG_STATUS', D_MSG_STATUS);
         D_MSG_STATUS.Initialised := True;
      end if;

      if P_ALIAS = 'DIRECTION_INDICATOR' and not D_DIRECTION_INDICATOR.Initialised then
         D_DIRECTION_INDICATOR.ColAlias := 'DIRECTION_INDICATOR';
         D_DIRECTION_INDICATOR.ControlType := XNP_WSGL.DV_TEXT;
         D_DIRECTION_INDICATOR.DispWidth := 10;
         D_DIRECTION_INDICATOR.DispHeight := 1;
         D_DIRECTION_INDICATOR.MaxWidth := 10;
         D_DIRECTION_INDICATOR.UseMeanings := True;
         D_DIRECTION_INDICATOR.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_DIRECTION_INDICATOR', D_DIRECTION_INDICATOR);
         D_DIRECTION_INDICATOR.Initialised := True;
      end if;

      if P_ALIAS = 'PRIORITY' and not D_PRIORITY.Initialised then
         D_PRIORITY.ColAlias := 'PRIORITY';
         D_PRIORITY.ControlType := XNP_WSGL.DV_TEXT;
         D_PRIORITY.DispWidth := 10;
         D_PRIORITY.DispHeight := 1;
         D_PRIORITY.MaxWidth := 10;
         D_PRIORITY.UseMeanings := True;
         D_PRIORITY.ColOptional := True;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_MSG_PRIORITY', D_PRIORITY);
         D_PRIORITY.Initialised := True;
      end if;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.InitialseDomain');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.MSG_CODE_TranslateFK
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function MSG_CODE_TranslateFK(
            P_MSG_CODE in varchar2,
            P_L_MTE_MSG_TYPE in varchar2,
            Z_MODE in varchar2) return boolean is
   begin
      select L_MTE.MSG_CODE
      into   CURR_VAL.MSG_CODE
      from   XNP_MSG_TYPES_B L_MTE
      where  rownum = 1
      and   ( L_MTE.MSG_CODE = P_MSG_CODE )
      and   ( L_MTE.MSG_TYPE = P_L_MTE_MSG_TYPE );
      return TRUE;
   exception
         when no_data_found then
            XNP_cg$errors.push('Code, Event Indicator: '||
                           XNP_WSGL.MsgGetText(226,XNP_WSGLM.MSG226_INVALID_FK),
                           'E', 'XNP_WSG', SQLCODE, 'xnp_msg_diagnostics$xnp_msgs.MSG_CODE_TranslateFK');
            return FALSE;
         when too_many_rows then
            XNP_cg$errors.push('Code, Event Indicator: '||
                           XNP_WSGL.MsgGetText(227,XNP_WSGLM.MSG227_TOO_MANY_FKS),
                           'E', 'WSG', SQLCODE, 'xnp_msg_diagnostics$xnp_msgs.MSG_CODE_TranslateFK');
            return FALSE;
         when others then
            XNP_cg$errors.push('Code, Event Indicator: '||SQLERRM,
                           'E', 'WSG', SQLCODE, 'xnp_msg_diagnostics$xnp_msgs.MSG_CODE_TranslateFK');
            return FALSE;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.msg_code_listofvalues
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure msg_code_listofvalues(
             Z_FILTER in varchar2,
             Z_MODE in varchar2,
             Z_CALLER_URL in varchar2,
             Z_ISSUE_WAIT in varchar2) is
      L_SEARCH_STRING varchar2(1000);
      L_ABORT boolean := FALSE;
      L_INVALID_DEPEDANT boolean := FALSE;
      L_ANY boolean := FALSE;
      L_BODY_ATTRIBUTES VarChar2 (1000) := LOV_BODY_ATTRIBUTES;
   begin

      XNP_WSGL.RegisterURL('xnp_msg_diagnostics$xnp_msgs.msg_code_listofvalues');
      XNP_WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      XNP_WSGL.AddURLParam('Z_MODE', Z_MODE);
      XNP_WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      if XNP_WSGL.NotLowerCase then
         return;
      end if;

      InitialiseDomain('L_MTE_MSG_TYPE');
      InitialiseDomain('PRIORITY');

      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,
                        'Code, Event Indicator'));

      if Z_ISSUE_WAIT is not null then

         htp.p ('<SCRIPT>
function RefreshMe()
{
  location.href = location.href.substring (0, location.href.length - 1);
};
</SCRIPT>');

         L_BODY_ATTRIBUTES := L_BODY_ATTRIBUTES || ' OnLoad="RefreshMe()"';

      else
         htp.p('<SCRIPT>
function PassBack(P_MSG_CODE,P_L_MTE_MSG_TYPE) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||XNP_WSGL.MsgGetText(228,XNP_WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   opener.document.forms[0].P_MSG_CODE.value = P_MSG_CODE;
   opener.document.forms[0].P_L_MTE_MSG_TYPE.value = P_L_MTE_MSG_TYPE;
   opener.document.forms[0].P_MSG_CODE.focus();
   close();
}
function Find_OnClick() {
   document.forms[0].submit();
}');
         if LOV_FRAME is null then
            htp.p('function Close_OnClick() {
      close();
}');
         end if;
         htp.p('</SCRIPT>');
      end if;

      xnp_msg_diagnostics$.TemplateHeader(TRUE,0);

      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);

      htp.header(2, htf.italic(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,'Code, Event Indicator')));

      if Z_ISSUE_WAIT is not null then
         htp.p(XNP_WSGL.MsgGetText(127,XNP_WSGLM.DSP127_LOV_PLEASE_WAIT));
         XNP_WSGL.ClosePageBody;
         return;
      else
         htp.formOpen('xnp_msg_diagnostics$xnp_msgs.msg_code_listofvalues');
         XNP_WSGL.HiddenField('Z_CALLER_URL', Z_CALLER_URL);
         XNP_WSGL.HiddenField('Z_MODE', Z_MODE);
      end if;

      L_SEARCH_STRING := rtrim(Z_FILTER);
      if L_SEARCH_STRING is not null then
         if ((instr(Z_FILTER,'%') = 0) and (instr(Z_FILTER,'_') = 0)) then
            L_SEARCH_STRING := L_SEARCH_STRING || '%';
         end if;
      else
         L_SEARCH_STRING := '%';
      end if;

      htp.para;
      htp.p(XNP_WSGL.MsgGetText(19,XNP_WSGLM.CAP019_LOV_FILTER_CAPTION,'Code'));
      htp.para;
      htp.formText('Z_FILTER', cvalue=>L_SEARCH_STRING);
      htp.p('<input type="button" value="'||LOV_FIND_BUT_CAPTION||'" onclick="Find_OnClick()">');
      if LOV_FRAME is null then
         htp.p('<input type="button" value="'||LOV_CLOSE_BUT_CAPTION||'" onclick="Close_OnClick()">');
      end if;
      htp.formClose;


      if not L_ABORT then

         XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE, TRUE);

         XNP_WSGL.LayoutRowStart;
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Code');
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Event Indicator');
         XNP_WSGL.LayoutRowEnd;

         declare
            cursor c1(zmode varchar2,srch varchar2) is
               select L_MTE.MSG_CODE MSG_CODE
               ,      L_MTE.MSG_TYPE L_MTE_MSG_TYPE
               ,      L_MTE.PRIORITY PRIORITY
               ,      L_MTE.LAST_COMPILED_DATE LAST_COMPILED_DATE
               ,      L_MTE.DEFAULT_PROCESS_LOGIC L_MTE_DEFAULT_PROCESS_LOGIC
               ,      L_MTE.IN_PROCESS_LOGIC L_MTE_IN_PROCESS_LOGIC
               ,      L_MTE.VALIDATE_LOGIC L_MTE_VALIDATE_LOGIC
               ,      L_MTE.OUT_PROCESS_LOGIC L_MTE_OUT_PROCESS_LOGIC
               from   XNP_MSG_TYPES_B L_MTE
               where  L_MTE.MSG_CODE like upper(srch)
               order by L_MTE.MSG_CODE;
         begin
            for c1rec in c1(Z_MODE,L_SEARCH_STRING) loop
               CURR_VAL.MSG_CODE := c1rec.MSG_CODE;
               NBT_VAL.L_MTE_MSG_TYPE := c1rec.L_MTE_MSG_TYPE;
               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData('<a href="javascript:PassBack('''||
                               replace(replace(c1rec.MSG_CODE,'"','&quot;'),'''','\''')||''','''||
                               replace(replace(XNP_WSGL.DomainMeaning(D_L_MTE_MSG_TYPE, c1rec.L_MTE_MSG_TYPE),'"','&quot;'),'''','\''')||''')">'||CURR_VAL.MSG_CODE||'</a>');
               XNP_WSGL.LayoutData(replace(XNP_WSGL.DomainMeaning(D_L_MTE_MSG_TYPE, NBT_VAL.L_MTE_MSG_TYPE),'"','&quot;'));
               XNP_WSGL.LayoutRowEnd;
               l_any := true;
            end loop;
            XNP_WSGL.LayoutClose;
            if not l_any then
               htp.p(XNP_WSGL.MsgGetText(224,XNP_WSGLM.MSG224_LOV_NO_ROWS));
            end if;
         end;
      end if;

      htp.p('<SCRIPT>document.forms[0].Z_FILTER.focus()</SCRIPT>');

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics',
                             LOV_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.msg_code_listofvalues');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.Startup
--
-- Description: Entry point for the 'XNP_MSGS' module
--              component  (Message Details).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_msg_diagnostics$xnp_msgs.startup');
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.StoreURLLink(1, 'Message Details');


      FormQuery(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.ActionQuery
--
-- Description: Called when a Query form is subitted to action the query request.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure ActionQuery(
             P_MSG_ID in varchar2,
             P_MSG_CODE in varchar2,
             P_L_MTE_MSG_TYPE in varchar2,
             P_MSG_STATUS in varchar2,
             P_REFERENCE_ID in varchar2,
             P_OPP_REFERENCE_ID in varchar2,
             P_RECIPIENT_NAME in varchar2,
             P_SENDER_NAME in varchar2,
             P_ADAPTER_NAME in varchar2,
             P_FE_NAME in varchar2,
             P_ORDER_ID in varchar2,
             P_WI_INSTANCE_ID in varchar2,
             P_FA_INSTANCE_ID in varchar2,
       	     Z_DIRECT_CALL in boolean default false,
             Z_ACTION in varchar2,
             Z_CHK in varchar2) is

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

--if on the query form and insert is allowed
      QueryList(
                P_MSG_ID,
                P_MSG_CODE,
                P_L_MTE_MSG_TYPE,
                P_MSG_STATUS,
                P_REFERENCE_ID,
                P_OPP_REFERENCE_ID,
                P_RECIPIENT_NAME,
                P_SENDER_NAME,
                P_ADAPTER_NAME,
                P_FE_NAME,
                P_ORDER_ID,
                P_WI_INSTANCE_ID,
                P_FA_INSTANCE_ID,
                null, L_BUTCHK, Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.ActionQuery');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.QueryHits
--
-- Description: Returns the number or rows which matches the given search
--              criteria (if any).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function QueryHits(
            P_MSG_ID in varchar2,
            P_MSG_CODE in varchar2,
            P_L_MTE_MSG_TYPE in varchar2,
            P_MSG_STATUS in varchar2,
            P_REFERENCE_ID in varchar2,
            P_OPP_REFERENCE_ID in varchar2,
            P_RECIPIENT_NAME in varchar2,
            P_SENDER_NAME in varchar2,
            P_ADAPTER_NAME in varchar2,
            P_FE_NAME in varchar2,
            P_ORDER_ID in varchar2,
            P_WI_INSTANCE_ID in varchar2,
            P_FA_INSTANCE_ID in varchar2) return number is
      I_QUERY     varchar2(2000) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_MSG_ID,
                      P_MSG_CODE,
                      P_L_MTE_MSG_TYPE,
                      P_MSG_STATUS,
                      P_REFERENCE_ID,
                      P_OPP_REFERENCE_ID,
                      P_RECIPIENT_NAME,
                      P_SENDER_NAME,
                      P_ADAPTER_NAME,
                      P_FE_NAME,
                      P_ORDER_ID,
                      P_WI_INSTANCE_ID,
                      P_FA_INSTANCE_ID) then
         return -1;
      end if;

      if not PreQuery(P_MSG_ID,
                      P_MSG_CODE,
                      P_L_MTE_MSG_TYPE,
                      P_MSG_STATUS,
                      P_REFERENCE_ID,
                      P_OPP_REFERENCE_ID,
                      P_RECIPIENT_NAME,
                      P_SENDER_NAME,
                      P_ADAPTER_NAME,
                      P_FE_NAME,
                      P_ORDER_ID,
                      P_WI_INSTANCE_ID,
                      P_FA_INSTANCE_ID) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'SFM iMessage Diagnostics'||' : '||'Message Details', DEF_BODY_ATTRIBUTES);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.QueryHits');
         return -1;
   end;--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.BuildSQL
--
-- Description: Builds the SQL for the 'XNP_MSGS' module component (Message Details).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_MSG_ID in varchar2,
            P_MSG_CODE in varchar2,
            P_L_MTE_MSG_TYPE in varchar2,
            P_MSG_STATUS in varchar2,
            P_REFERENCE_ID in varchar2,
            P_OPP_REFERENCE_ID in varchar2,
            P_RECIPIENT_NAME in varchar2,
            P_SENDER_NAME in varchar2,
            P_ADAPTER_NAME in varchar2,
            P_FE_NAME in varchar2,
            P_ORDER_ID in varchar2,
            P_WI_INSTANCE_ID in varchar2,
            P_FA_INSTANCE_ID in varchar2) return boolean is

      I_WHERE varchar2(2000);
   begin

      InitialiseDomain('L_MTE_MSG_TYPE');
      InitialiseDomain('MSG_STATUS');

      -- Build up the Where clause
      I_WHERE := I_WHERE || ' where L_MTE.MSG_CODE = MSG.MSG_CODE';

      begin
         XNP_WSGL.BuildWhere(P_MSG_ID, 'MSG.MSG_ID', XNP_WSGL.TYPE_NUMBER, I_WHERE);
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'SFM iMessage Diagnostics'||' : '||'Message Details', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'ID'));
            return false;
      end;
      XNP_WSGL.BuildWhere(P_MSG_CODE, 'MSG.MSG_CODE', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(XNP_WSGL.DomainValue(D_L_MTE_MSG_TYPE, P_L_MTE_MSG_TYPE), 'L_MTE.MSG_TYPE', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(XNP_WSGL.DomainValue(D_MSG_STATUS, P_MSG_STATUS), 'MSG.MSG_STATUS', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_REFERENCE_ID, 'MSG.REFERENCE_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_OPP_REFERENCE_ID, 'MSG.OPP_REFERENCE_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_RECIPIENT_NAME, 'MSG.RECIPIENT_NAME', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_SENDER_NAME, 'MSG.SENDER_NAME', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_ADAPTER_NAME, 'MSG.ADAPTER_NAME', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_FE_NAME, 'MSG.FE_NAME', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_ORDER_ID, 'MSG.ORDER_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_WI_INSTANCE_ID, 'MSG.WI_INSTANCE_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_FA_INSTANCE_ID, 'MSG.FA_INSTANCE_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);

      ZONE_SQL := 'SELECT MSG.MSG_ID,
                         ''xnp_web_utils.show_msg_body?p_msg_id=''||MSG.MSG_ID,
                         MSG.MSG_CODE,
                         MSG.MSG_STATUS,
                         MSG.DIRECTION_INDICATOR,
                         MSG.REFERENCE_ID,
                         MSG.OPP_REFERENCE_ID,
                         MSG.MSG_VERSION,
                         MSG.MSG_CREATION_DATE,
                         MSG.SEND_RCV_DATE,
                         MSG.RECIPIENT_NAME,
                         MSG.SENDER_NAME,
                         MSG.ADAPTER_NAME,
                         MSG.FE_NAME
                  FROM   XNP_MSGS MSG,
                         XNP_MSG_TYPES_B L_MTE';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY MSG.MSG_ID Desc ';
      return true;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.BuildSQL');
         return false;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.FormQuery
--
-- Description: This procedure builds an HTML form for entry of query criteria.
--              The criteria entered are to restrict the query of the 'XNP_MSGS'
--              module component (Message Details).
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

      XNP_WSGL.OpenPageHead('SFM iMessage Diagnostics'||' : '||'Message Details');
      CreateQueryJavaScript;
	  -- Added for iHelp
	  htp.p('<SCRIPT> ');
	  icx_admin_sig.help_win_script('xnpDiag_msg', null, 'XNP');
	  htp.p('</SCRIPT>');
	  -- <<
      xnp_msg_diagnostics$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

	  -- Added for iHelp
	  htp.p('<A HREF="javascript:help_window()"');
	  htp.p('onMouseOver="window.status='||''''||'Help'||''''||';return true">');
	  htp.p(htf.img('/OA_MEDIA/afhelp.gif'));
	  htp.p('</A>');
	  htp.p(htf.nl);
	  -- <<

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>QF_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      xnp_msg_diagnostics$.FirstPage(TRUE);
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPMSGDG_DETAILS_TITLE')));
      htp.para;
      htp.p(XNP_WSGL.MsgGetText(116,XNP_WSGLM.DSP116_ENTER_QRY_CAPTION,'Message Details'));
      htp.para;

      htp.formOpen(curl => 'xnp_msg_diagnostics$xnp_msgs.actionquery', cattributes => 'NAME="frmZero"');

      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..QF_NUMBER_OF_COLUMNS loop
	  XNP_WSGL.LayoutHeader(22, 'LEFT', NULL);
	  XNP_WSGL.LayoutHeader(20, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('MSG_ID', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Code:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('MSG_CODE', '20', FALSE) || ' ' ||
                      XNP_WSGJSL.LOVButton('MSG_CODE',LOV_BUTTON_TEXT));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Event Indicator:'));
      InitialiseDomain('L_MTE_MSG_TYPE');
      XNP_WSGL.LayoutData(XNP_WSGL.BuildDVControl(D_L_MTE_MSG_TYPE, XNP_WSGL.CTL_QUERY));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Status:'));
      InitialiseDomain('MSG_STATUS');
      XNP_WSGL.LayoutData(XNP_WSGL.BuildDVControl(D_MSG_STATUS, XNP_WSGL.CTL_QUERY));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Ref ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('REFERENCE_ID', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Opp Ref ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('OPP_REFERENCE_ID', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Receiver:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('RECIPIENT_NAME', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Sender:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('SENDER_NAME', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Adapter (Consumer):'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('ADAPTER_NAME', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Consumer FE:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('FE_NAME', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Order ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('ORDER_ID', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Work Item Instance ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('WI_INSTANCE_ID', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('FA Instance ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('FA_INSTANCE_ID', '20', FALSE));
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             QF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.FormQuery');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.FormView
--
-- Description: This procedure builds an HTML form for view/update of fields in
--              the 'XNP_MSGS' module component (Message Details).
--
-- Parameters:  Z_FORM_STATUS  Status of the form
--
--------------------------------------------------------------------------------
   procedure FormView(Z_FORM_STATUS in number) is


    begin

      XNP_WSGL.OpenPageHead('SFM iMessage Diagnostics'||' : '||'Message Details');
      xnp_msg_diagnostics$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>VF_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPMSGDG_DETAILS_TITLE')));
      InitialiseDomain('L_MTE_MSG_TYPE');
      InitialiseDomain('MSG_STATUS');
      InitialiseDomain('DIRECTION_INDICATOR');
      InitialiseDomain('PRIORITY');



      FORM_VAL.MSG_ID := CURR_VAL.MSG_ID;
      FORM_VAL.XML_PAYLOAD_LINK := NBT_VAL.XML_PAYLOAD_LINK;
      FORM_VAL.MSG_CODE := CURR_VAL.MSG_CODE;
      FORM_VAL.L_MTE_MSG_TYPE := XNP_WSGL.DomainMeaning(D_L_MTE_MSG_TYPE, NBT_VAL.L_MTE_MSG_TYPE);
      FORM_VAL.MSG_STATUS := XNP_WSGL.DomainMeaning(D_MSG_STATUS, CURR_VAL.MSG_STATUS);
      FORM_VAL.DIRECTION_INDICATOR := XNP_WSGL.DomainMeaning(D_DIRECTION_INDICATOR, CURR_VAL.DIRECTION_INDICATOR);
      FORM_VAL.REFERENCE_ID := CURR_VAL.REFERENCE_ID;
      FORM_VAL.OPP_REFERENCE_ID := CURR_VAL.OPP_REFERENCE_ID;
      FORM_VAL.VERSION := CURR_VAL.MSG_VERSION;
      FORM_VAL.MSG_CREATION_DATE := ltrim(to_char(CURR_VAL.MSG_CREATION_DATE, 'DD-MON-RRRR HH24:MI:SS'));
      FORM_VAL.SEND_RCV_DATE := ltrim(to_char(CURR_VAL.SEND_RCV_DATE, 'DD-MON-RRRR'));
      FORM_VAL.RECIPIENT_NAME := CURR_VAL.RECIPIENT_NAME;
      FORM_VAL.SENDER_NAME := CURR_VAL.SENDER_NAME;
      FORM_VAL.ADAPTER_NAME := CURR_VAL.ADAPTER_NAME;
      FORM_VAL.FE_NAME := CURR_VAL.FE_NAME;
      FORM_VAL.ORDER_ID := CURR_VAL.ORDER_ID;
      FORM_VAL.WI_INSTANCE_ID := CURR_VAL.WI_INSTANCE_ID;
      FORM_VAL.FA_INSTANCE_ID := CURR_VAL.FA_INSTANCE_ID;
      FORM_VAL.PRIORITY := XNP_WSGL.DomainMeaning(D_PRIORITY, NBT_VAL.PRIORITY);
      FORM_VAL.LAST_COMPILED_DATE := ltrim(to_char(NBT_VAL.LAST_COMPILED_DATE, 'DD-MON-RRRR'));
      FORM_VAL.DESCRIPTION := CURR_VAL.DESCRIPTION;
      FORM_VAL.RESEND_LINK := NBT_VAL.RESEND_LINK;

      /*

	Fixed Bug# 1808775 Procedure fails due to message length > 2000
	Now this logic will never be executed since we only display the
	body text directly using text/xml using a browser capable of XML
	rendering - rraheja 05/31/2001

	l_amount_to_read := DBMS_LOB.GETLENGTH(CURR_VAL_BODY_TEXT) ;
        DBMS_LOB.READ(lob_loc => CURR_VAL_BODY_TEXT,
        amount => l_amount_to_read,
        offset => 1,
        buffer => FORM_VAL.BODY_TEXT ) ;
        FORM_VAL.BODY_TEXT := CURR_VAL.BODY_TEXT;

      */

      FORM_VAL.L_MTE_DEFAULT_PROCESS_LOGIC := NBT_VAL.L_MTE_DEFAULT_PROCESS_LOGIC;
      FORM_VAL.L_MTE_IN_PROCESS_LOGIC := NBT_VAL.L_MTE_IN_PROCESS_LOGIC;
      FORM_VAL.L_MTE_VALIDATE_LOGIC := NBT_VAL.L_MTE_VALIDATE_LOGIC;
      FORM_VAL.L_MTE_OUT_PROCESS_LOGIC := NBT_VAL.L_MTE_OUT_PROCESS_LOGIC;

      if Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_ERROR then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'SFM iMessage Diagnostics'||' : '||'Message Details', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_UPD then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(207, XNP_WSGLM.MSG207_ROW_UPDATED),
                             'SFM iMessage Diagnostics'||' : '||'Message Details', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_INS then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(208, XNP_WSGLM.MSG208_ROW_INSERTED),
                             'SFM iMessage Diagnostics'||' : '||'Message Details', VF_BODY_ATTRIBUTES);
      end if;


      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE, P_BORDER=>TRUE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..VF_NUMBER_OF_COLUMNS loop
         XNP_WSGL.LayoutHeader(36, 'LEFT', NULL);
         XNP_WSGL.LayoutHeader(240, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('ID:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.MSG_ID));
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.XML_PAYLOAD_LINK is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.anchor2(FORM_VAL.XML_PAYLOAD_LINK, 'XML'));
         XNP_WSGL.LayoutData('');
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Code:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.MSG_CODE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Event Indicator:'));
      XNP_WSGL.LayoutData(FORM_VAL.L_MTE_MSG_TYPE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Status:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.MSG_STATUS));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('In/Out:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.DIRECTION_INDICATOR));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Ref ID:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.REFERENCE_ID));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Opp Ref ID:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.OPP_REFERENCE_ID));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Version:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.VERSION));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Created On:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.MSG_CREATION_DATE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Processed On:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.SEND_RCV_DATE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Receiver:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.RECIPIENT_NAME));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Sender:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.SENDER_NAME));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Adapter (Consumer):'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.ADAPTER_NAME));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Consumer FE:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.FE_NAME));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Order ID:'));
      XNP_WSGL.LayoutData(FORM_VAL.ORDER_ID);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Work Item Instance ID:'));
      XNP_WSGL.LayoutData(FORM_VAL.WI_INSTANCE_ID);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('FA Instance ID:'));
      XNP_WSGL.LayoutData(FORM_VAL.FA_INSTANCE_ID);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Priority:'));
      XNP_WSGL.LayoutData(FORM_VAL.PRIORITY);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Message Definition Last Compiled On:'));
      XNP_WSGL.LayoutData(FORM_VAL.LAST_COMPILED_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Error Description:'));
      XNP_WSGL.LayoutData(replace(FORM_VAL.DESCRIPTION, '
', '<BR>
'));
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.RESEND_LINK is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.anchor2(FORM_VAL.RESEND_LINK, 'Retry Message'));
         XNP_WSGL.LayoutData('');
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Default Process Logic:'));
      XNP_WSGL.LayoutData(replace(FORM_VAL.L_MTE_DEFAULT_PROCESS_LOGIC, '
', '<BR>
'));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Process Inbound Logic:'));
      XNP_WSGL.LayoutData(replace(FORM_VAL.L_MTE_IN_PROCESS_LOGIC, '
', '<BR>
'));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Validate Logic:'));
      XNP_WSGL.LayoutData(replace(FORM_VAL.L_MTE_VALIDATE_LOGIC, '
', '<BR>
'));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Process Outbound Logic:'));
      XNP_WSGL.LayoutData(replace(FORM_VAL.L_MTE_OUT_PROCESS_LOGIC, '
', '<BR>
'));
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutClose;






      XNP_WSGL.ReturnLinks('0.1', XNP_WSGL.MENU_LONG);
      XNP_WSGL.NavLinks;


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             VF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.FormView');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
procedure retry_message
is
begin
	htp.htmlopen;
    htp.bodyopen;
    htp.p('Please use the notification for retrying this message.') ;
    htp.bodyclose;
    htp.htmlclose;
end;
--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.QueryView
--
-- Description: Queries the details of a single row in preparation for display.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryView(
             P_MSG_ID in varchar2,
             Z_POST_DML in boolean,
             Z_FORM_STATUS in number,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_msg_diagnostics$xnp_msgs.queryview');
      XNP_WSGL.AddURLParam('P_MSG_ID', P_MSG_ID);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('' ||
                                      P_MSG_ID, Z_CHK) then
            return;
         end if;
      end if;


      if P_MSG_ID is not null then
         CURR_VAL.MSG_ID := P_MSG_ID;
      end if;
      if Z_POST_DML then

         SELECT L_MTE.MSG_TYPE,
                L_MTE.PRIORITY,
                L_MTE.LAST_COMPILED_DATE,
--                decode (MSG.MSG_STATUS, 'FAILED',  'xnp_message.fix?p_msg_id='||MSG.MSG_ID, NULL),
                decode (MSG.MSG_STATUS, 'FAILED',  ' xnp_msg_diagnostics$xnp_msgs.retry_message', NULL),
                L_MTE.DEFAULT_PROCESS_LOGIC,
                L_MTE.IN_PROCESS_LOGIC,
                L_MTE.VALIDATE_LOGIC,
                L_MTE.OUT_PROCESS_LOGIC
         INTO   NBT_VAL.L_MTE_MSG_TYPE,
                NBT_VAL.PRIORITY,
                NBT_VAL.LAST_COMPILED_DATE,
                NBT_VAL.RESEND_LINK,
                NBT_VAL.L_MTE_DEFAULT_PROCESS_LOGIC,
                NBT_VAL.L_MTE_IN_PROCESS_LOGIC,
                NBT_VAL.L_MTE_VALIDATE_LOGIC,
                NBT_VAL.L_MTE_OUT_PROCESS_LOGIC
         FROM   XNP_MSGS MSG,
                XNP_MSG_TYPES_B L_MTE
         WHERE  MSG.MSG_ID = CURR_VAL.MSG_ID
         AND    L_MTE.MSG_CODE = MSG.MSG_CODE
         ;

      else

         SELECT MSG.MSG_ID,
                MSG.MSG_CODE,
                L_MTE.MSG_TYPE,
                MSG.MSG_STATUS,
                MSG.DIRECTION_INDICATOR,
                MSG.REFERENCE_ID,
                MSG.OPP_REFERENCE_ID,
                MSG.MSG_VERSION,
                MSG.MSG_CREATION_DATE,
                MSG.SEND_RCV_DATE,
                MSG.RECIPIENT_NAME,
                MSG.SENDER_NAME,
                MSG.ADAPTER_NAME,
                MSG.FE_NAME,
                MSG.ORDER_ID,
                MSG.WI_INSTANCE_ID,
                MSG.FA_INSTANCE_ID,
                L_MTE.PRIORITY,
                L_MTE.LAST_COMPILED_DATE,
                MSG.DESCRIPTION,
--                decode (MSG.MSG_STATUS, 'FAILED',  'xnp_message.fix?p_msg_id='||MSG.MSG_ID, NULL),
                decode (MSG.MSG_STATUS, 'FAILED',  ' xnp_msg_diagnostics$xnp_msgs.retry_message', NULL),
                MSG.BODY_TEXT,
                L_MTE.DEFAULT_PROCESS_LOGIC,
                L_MTE.IN_PROCESS_LOGIC,
                L_MTE.VALIDATE_LOGIC,
                L_MTE.OUT_PROCESS_LOGIC
         INTO   CURR_VAL.MSG_ID,
                CURR_VAL.MSG_CODE,
                NBT_VAL.L_MTE_MSG_TYPE,
                CURR_VAL.MSG_STATUS,
                CURR_VAL.DIRECTION_INDICATOR,
                CURR_VAL.REFERENCE_ID,
                CURR_VAL.OPP_REFERENCE_ID,
                CURR_VAL.MSG_VERSION,
                CURR_VAL.MSG_CREATION_DATE,
                CURR_VAL.SEND_RCV_DATE,
                CURR_VAL.RECIPIENT_NAME,
                CURR_VAL.SENDER_NAME,
                CURR_VAL.ADAPTER_NAME,
                CURR_VAL.FE_NAME,
                CURR_VAL.ORDER_ID,
                CURR_VAL.WI_INSTANCE_ID,
                CURR_VAL.FA_INSTANCE_ID,
                NBT_VAL.PRIORITY,
                NBT_VAL.LAST_COMPILED_DATE,
                CURR_VAL.DESCRIPTION,
                NBT_VAL.RESEND_LINK,
                CURR_VAL_BODY_TEXT, -- CLOB changes --
                NBT_VAL.L_MTE_DEFAULT_PROCESS_LOGIC,
                NBT_VAL.L_MTE_IN_PROCESS_LOGIC,
                NBT_VAL.L_MTE_VALIDATE_LOGIC,
                NBT_VAL.L_MTE_OUT_PROCESS_LOGIC
         FROM   XNP_MSGS MSG,
                XNP_MSG_TYPES_B L_MTE
         WHERE  MSG.MSG_ID = CURR_VAL.MSG_ID
         AND    L_MTE.MSG_CODE = MSG.MSG_CODE
         ;

      end if;

      NBT_VAL.XML_PAYLOAD_LINK := 'xnp_web_utils.show_msg_body?p_msg_id='||CURR_VAL.MSG_ID;

      if not PostQuery(Z_POST_DML) then
         FormView(XNP_WSGL.FORM_STATUS_ERROR);
      else
         FormView(Z_FORM_STATUS);
      end if;

   exception
      when NO_DATA_FOUND then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_WSGL.MsgGetText(204, XNP_WSGLM.MSG204_ROW_DELETED),
                             'SFM iMessage Diagnostics'||' : '||'Message Details', VF_BODY_ATTRIBUTES);
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             VF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.QueryView');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.QueryList
--
-- Description: This procedure builds the Record list for the 'XNP_MSGS'
--              module component (Message Details).
--
--              The Record List displays context information for records which
--              match the specified query criteria.
--              Sets of records are displayed (10 records at a time)
--              with Next/Previous buttons to get other record sets.
--
--              The first context column will be created as a link to the
--              xnp_msg_diagnostics$xnp_msgs.FormView procedure for display of more details
--              of that particular row.
--
-- Parameters:  P_MSG_ID - ID
--              P_MSG_CODE - Code
--              P_L_MTE_MSG_TYPE - Event Indicator
--              P_MSG_STATUS - Status
--              P_REFERENCE_ID - Ref ID
--              P_OPP_REFERENCE_ID - Opp Ref ID
--              P_RECIPIENT_NAME - Receiver
--              P_SENDER_NAME - Sender
--              P_ADAPTER_NAME - Adapter (Consumer)
--              P_FE_NAME - Consumer FE
--              P_ORDER_ID - Order ID
--              P_WI_INSTANCE_ID - Work Item Instance ID
--              P_FA_INSTANCE_ID - FA Instance ID
--              Z_START - First record to display
--              Z_ACTION - Next or Previous set
--
--------------------------------------------------------------------------------
   procedure QueryList(
             P_MSG_ID in varchar2,
             P_MSG_CODE in varchar2,
             P_L_MTE_MSG_TYPE in varchar2,
             P_MSG_STATUS in varchar2,
             P_REFERENCE_ID in varchar2,
             P_OPP_REFERENCE_ID in varchar2,
             P_RECIPIENT_NAME in varchar2,
             P_SENDER_NAME in varchar2,
             P_ADAPTER_NAME in varchar2,
             P_FE_NAME in varchar2,
             P_ORDER_ID in varchar2,
             P_WI_INSTANCE_ID in varchar2,
             P_FA_INSTANCE_ID in varchar2,
             Z_START in varchar2,
             Z_ACTION in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is

      L_VF_FRAME          varchar2(20) := null;
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
      L_CHECKSUM          varchar2(10);

   begin

      XNP_WSGL.RegisterURL('xnp_msg_diagnostics$xnp_msgs.querylist');
      XNP_WSGL.AddURLParam('P_MSG_ID', P_MSG_ID);
      XNP_WSGL.AddURLParam('P_MSG_CODE', P_MSG_CODE);
      XNP_WSGL.AddURLParam('P_L_MTE_MSG_TYPE', P_L_MTE_MSG_TYPE);
      XNP_WSGL.AddURLParam('P_MSG_STATUS', P_MSG_STATUS);
      XNP_WSGL.AddURLParam('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.AddURLParam('P_OPP_REFERENCE_ID', P_OPP_REFERENCE_ID);
      XNP_WSGL.AddURLParam('P_RECIPIENT_NAME', P_RECIPIENT_NAME);
      XNP_WSGL.AddURLParam('P_SENDER_NAME', P_SENDER_NAME);
      XNP_WSGL.AddURLParam('P_ADAPTER_NAME', P_ADAPTER_NAME);
      XNP_WSGL.AddURLParam('P_FE_NAME', P_FE_NAME);
      XNP_WSGL.AddURLParam('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.AddURLParam('P_WI_INSTANCE_ID', P_WI_INSTANCE_ID);
      XNP_WSGL.AddURLParam('P_FA_INSTANCE_ID', P_FA_INSTANCE_ID);
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

      XNP_WSGL.OpenPageHead('SFM iMessage Diagnostics'||' : '||'Message Details');
      CreateListJavaScript;
      xnp_msg_diagnostics$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>RL_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPMSGDG_DETAILS_TITLE')));
      if (Z_ACTION = RL_LAST_BUT_ACTION) or (Z_ACTION = RL_LAST_BUT_CAPTION) or
         (Z_ACTION = RL_COUNT_BUT_ACTION) or (Z_ACTION = RL_COUNT_BUT_CAPTION) or
         (RL_TOTAL_COUNT_REQD)
      then

         I_COUNT := QueryHits(
                    P_MSG_ID,
                    P_MSG_CODE,
                    P_L_MTE_MSG_TYPE,
                    P_MSG_STATUS,
                    P_REFERENCE_ID,
                    P_OPP_REFERENCE_ID,
                    P_RECIPIENT_NAME,
                    P_SENDER_NAME,
                    P_ADAPTER_NAME,
                    P_FE_NAME,
                    P_ORDER_ID,
                    P_WI_INSTANCE_ID,
                    P_FA_INSTANCE_ID);
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
                             'SFM iMessage Diagnostics'||' : '||'Message Details', RL_BODY_ATTRIBUTES);
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
                       P_MSG_ID,
                       P_MSG_CODE,
                       P_L_MTE_MSG_TYPE,
                       P_MSG_STATUS,
                       P_REFERENCE_ID,
                       P_OPP_REFERENCE_ID,
                       P_RECIPIENT_NAME,
                       P_SENDER_NAME,
                       P_ADAPTER_NAME,
                       P_FE_NAME,
                       P_ORDER_ID,
                       P_WI_INSTANCE_ID,
                       P_FA_INSTANCE_ID) then
               XNP_WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if not PreQuery(
                       P_MSG_ID,
                       P_MSG_CODE,
                       P_L_MTE_MSG_TYPE,
                       P_MSG_STATUS,
                       P_REFERENCE_ID,
                       P_OPP_REFERENCE_ID,
                       P_RECIPIENT_NAME,
                       P_SENDER_NAME,
                       P_ADAPTER_NAME,
                       P_FE_NAME,
                       P_ORDER_ID,
                       P_WI_INSTANCE_ID,
                       P_FA_INSTANCE_ID) then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                                'SFM iMessage Diagnostics'||' : '||'Message Details', RL_BODY_ATTRIBUTES);
         return;
         end if;

         InitialiseDomain('MSG_STATUS');
         InitialiseDomain('DIRECTION_INDICATOR');


         I_CURSOR := dbms_sql.open_cursor;
         dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
         dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.MSG_ID);
         dbms_sql.define_column(I_CURSOR, 2, NBT_VAL.XML_PAYLOAD_LINK, 2000);
         dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.MSG_CODE, 20);
         dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.MSG_STATUS, 10);
         dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.DIRECTION_INDICATOR, 1);
         dbms_sql.define_column(I_CURSOR, 6, CURR_VAL.REFERENCE_ID, 1024);
         dbms_sql.define_column(I_CURSOR, 7, CURR_VAL.OPP_REFERENCE_ID, 40);
         dbms_sql.define_column(I_CURSOR, 8, CURR_VAL.MSG_VERSION);
         dbms_sql.define_column(I_CURSOR, 9, CURR_VAL.MSG_CREATION_DATE);
         dbms_sql.define_column(I_CURSOR, 10, CURR_VAL.SEND_RCV_DATE);
         dbms_sql.define_column(I_CURSOR, 11, CURR_VAL.RECIPIENT_NAME, 40);
         -- dbms_sql.define_column(I_CURSOR, 12, CURR_VAL.SENDER_NAME, 40);
	 dbms_sql.define_column(I_CURSOR, 12, CURR_VAL.SENDER_NAME, 60); -- increased the size from 40 to 60 for 6880763
         dbms_sql.define_column(I_CURSOR, 13, CURR_VAL.ADAPTER_NAME, 40);
         dbms_sql.define_column(I_CURSOR, 14, CURR_VAL.FE_NAME, 40);

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
      	    XNP_WSGL.LayoutHeader(20, 'RIGHT', 'ID');
      	    XNP_WSGL.LayoutHeader(30, 'LEFT', 'XML');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Code');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Status');
      	    XNP_WSGL.LayoutHeader(10, 'LEFT', 'In/Out');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Ref ID');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Opp Ref ID');
      	    XNP_WSGL.LayoutHeader(5, 'RIGHT', 'Version');
      	    XNP_WSGL.LayoutHeader(12, 'LEFT', 'Created On');
      	    XNP_WSGL.LayoutHeader(12, 'LEFT', 'Processed On');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Receiver');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Sender');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Adapter (Consumer)');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Consumer FE');
         end loop;
         XNP_WSGL.LayoutRowEnd;

         while I_ROWS_FETCHED <> 0 loop

            if I_TOTAL_ROWS >= I_START then
               dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.MSG_ID);
               dbms_sql.column_value(I_CURSOR, 2, NBT_VAL.XML_PAYLOAD_LINK);
               dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.MSG_CODE);
               dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.MSG_STATUS);
               dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.DIRECTION_INDICATOR);
               dbms_sql.column_value(I_CURSOR, 6, CURR_VAL.REFERENCE_ID);
               dbms_sql.column_value(I_CURSOR, 7, CURR_VAL.OPP_REFERENCE_ID);
               dbms_sql.column_value(I_CURSOR, 8, CURR_VAL.MSG_VERSION);
               dbms_sql.column_value(I_CURSOR, 9, CURR_VAL.MSG_CREATION_DATE);
               dbms_sql.column_value(I_CURSOR, 10, CURR_VAL.SEND_RCV_DATE);
               dbms_sql.column_value(I_CURSOR, 11, CURR_VAL.RECIPIENT_NAME);
               dbms_sql.column_value(I_CURSOR, 12, CURR_VAL.SENDER_NAME);
               dbms_sql.column_value(I_CURSOR, 13, CURR_VAL.ADAPTER_NAME);
               dbms_sql.column_value(I_CURSOR, 14, CURR_VAL.FE_NAME);
               L_CHECKSUM := to_char(XNP_WSGL.Checksum(''||CURR_VAL.MSG_ID));


               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData(htf.anchor2('xnp_msg_diagnostics$xnp_msgs.queryview?P_MSG_ID='||CURR_VAL.MSG_ID||'&Z_CHK='||L_CHECKSUM, CURR_VAL.MSG_ID, ctarget=>L_VF_FRAME));
               XNP_WSGL.LayoutData(htf.anchor2(NBT_VAL.XML_PAYLOAD_LINK, 'XML'));
               XNP_WSGL.LayoutData(CURR_VAL.MSG_CODE);
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_MSG_STATUS, CURR_VAL.MSG_STATUS));
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_DIRECTION_INDICATOR, CURR_VAL.DIRECTION_INDICATOR));
               XNP_WSGL.LayoutData(CURR_VAL.REFERENCE_ID);
               XNP_WSGL.LayoutData(CURR_VAL.OPP_REFERENCE_ID);
               XNP_WSGL.LayoutData(CURR_VAL.MSG_VERSION);
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.MSG_CREATION_DATE, 'DD-MON-RRRR HH24:MI:SS')));
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.SEND_RCV_DATE, 'DD-MON-RRRR')));
               XNP_WSGL.LayoutData(CURR_VAL.RECIPIENT_NAME);
               XNP_WSGL.LayoutData(CURR_VAL.SENDER_NAME);
               XNP_WSGL.LayoutData(CURR_VAL.ADAPTER_NAME);
               XNP_WSGL.LayoutData(CURR_VAL.FE_NAME);
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

      htp.formOpen(curl => 'xnp_msg_diagnostics$xnp_msgs.querylist', cattributes => 'NAME="frmZero"');
      XNP_WSGL.HiddenField('P_MSG_ID', P_MSG_ID);
      XNP_WSGL.HiddenField('P_MSG_CODE', P_MSG_CODE);
      XNP_WSGL.HiddenField('P_L_MTE_MSG_TYPE', P_L_MTE_MSG_TYPE);
      XNP_WSGL.HiddenField('P_MSG_STATUS', P_MSG_STATUS);
      XNP_WSGL.HiddenField('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.HiddenField('P_OPP_REFERENCE_ID', P_OPP_REFERENCE_ID);
      XNP_WSGL.HiddenField('P_RECIPIENT_NAME', P_RECIPIENT_NAME);
      XNP_WSGL.HiddenField('P_SENDER_NAME', P_SENDER_NAME);
      XNP_WSGL.HiddenField('P_ADAPTER_NAME', P_ADAPTER_NAME);
      XNP_WSGL.HiddenField('P_FE_NAME', P_FE_NAME);
      XNP_WSGL.HiddenField('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.HiddenField('P_WI_INSTANCE_ID', P_WI_INSTANCE_ID);
      XNP_WSGL.HiddenField('P_FA_INSTANCE_ID', P_FA_INSTANCE_ID);
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
      htp.para;

      XNP_WSGL.RecordListButton(TRUE, 'Z_ACTION', htf.escape_sc(RL_QUERY_BUT_CAPTION),p_dojs=>FALSE,
                            buttonJS => 'onClick="this.form.Z_ACTION.value=\''' || RL_QUERY_BUT_ACTION || '\''"');
      XNP_WSGL.HiddenField('Z_CHK',
                     to_char(XNP_WSGL.Checksum('')));
      htp.formClose;

      XNP_WSGL.ReturnLinks('0', XNP_WSGL.MENU_LONG);
      XNP_WSGL.NavLinks;

      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             RL_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.QueryList');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.QueryFirst
--
-- Description: Finds the first row which matches the given search criteria
--              (if any), and calls QueryView for that row
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryFirst(
             P_MSG_ID in varchar2,
             P_MSG_CODE in varchar2,
             P_L_MTE_MSG_TYPE in varchar2,
             P_MSG_STATUS in varchar2,
             P_REFERENCE_ID in varchar2,
             P_OPP_REFERENCE_ID in varchar2,
             P_RECIPIENT_NAME in varchar2,
             P_SENDER_NAME in varchar2,
             P_ADAPTER_NAME in varchar2,
             P_FE_NAME in varchar2,
             P_ORDER_ID in varchar2,
             P_WI_INSTANCE_ID in varchar2,
             P_FA_INSTANCE_ID in varchar2,
             Z_ACTION in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is

      I_CURSOR            integer;
      I_VOID              integer;
      I_ROWS_FETCHED      integer := 0;

   begin

      XNP_WSGL.RegisterURL('xnp_msg_diagnostics$xnp_msgs.queryfirst');
      XNP_WSGL.AddURLParam('P_MSG_ID', P_MSG_ID);
      XNP_WSGL.AddURLParam('P_MSG_CODE', P_MSG_CODE);
      XNP_WSGL.AddURLParam('P_L_MTE_MSG_TYPE', P_L_MTE_MSG_TYPE);
      XNP_WSGL.AddURLParam('P_MSG_STATUS', P_MSG_STATUS);
      XNP_WSGL.AddURLParam('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.AddURLParam('P_OPP_REFERENCE_ID', P_OPP_REFERENCE_ID);
      XNP_WSGL.AddURLParam('P_RECIPIENT_NAME', P_RECIPIENT_NAME);
      XNP_WSGL.AddURLParam('P_SENDER_NAME', P_SENDER_NAME);
      XNP_WSGL.AddURLParam('P_ADAPTER_NAME', P_ADAPTER_NAME);
      XNP_WSGL.AddURLParam('P_FE_NAME', P_FE_NAME);
      XNP_WSGL.AddURLParam('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.AddURLParam('P_WI_INSTANCE_ID', P_WI_INSTANCE_ID);
      XNP_WSGL.AddURLParam('P_FA_INSTANCE_ID', P_FA_INSTANCE_ID);
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
                    P_MSG_ID,
                    P_MSG_CODE,
                    P_L_MTE_MSG_TYPE,
                    P_MSG_STATUS,
                    P_REFERENCE_ID,
                    P_OPP_REFERENCE_ID,
                    P_RECIPIENT_NAME,
                    P_SENDER_NAME,
                    P_ADAPTER_NAME,
                    P_FE_NAME,
                    P_ORDER_ID,
                    P_WI_INSTANCE_ID,
                    P_FA_INSTANCE_ID) then
         return;
      end if;

      if not PreQuery(
                    P_MSG_ID,
                    P_MSG_CODE,
                    P_L_MTE_MSG_TYPE,
                    P_MSG_STATUS,
                    P_REFERENCE_ID,
                    P_OPP_REFERENCE_ID,
                    P_RECIPIENT_NAME,
                    P_SENDER_NAME,
                    P_ADAPTER_NAME,
                    P_FE_NAME,
                    P_ORDER_ID,
                    P_WI_INSTANCE_ID,
                    P_FA_INSTANCE_ID) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'SFM iMessage Diagnostics'||' : '||'Message Details', VF_BODY_ATTRIBUTES);
         return;
      end if;

      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.MSG_ID);
      dbms_sql.define_column(I_CURSOR, 2, NBT_VAL.XML_PAYLOAD_LINK, 2000);
      dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.MSG_CODE, 20);
      dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.MSG_STATUS, 10);
      dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.DIRECTION_INDICATOR, 1);
      dbms_sql.define_column(I_CURSOR, 6, CURR_VAL.REFERENCE_ID, 1024);
      dbms_sql.define_column(I_CURSOR, 7, CURR_VAL.OPP_REFERENCE_ID, 40);
      dbms_sql.define_column(I_CURSOR, 8, CURR_VAL.MSG_VERSION);
      dbms_sql.define_column(I_CURSOR, 9, CURR_VAL.MSG_CREATION_DATE);
      dbms_sql.define_column(I_CURSOR, 10, CURR_VAL.SEND_RCV_DATE);
      dbms_sql.define_column(I_CURSOR, 11, CURR_VAL.RECIPIENT_NAME, 40);
      -- dbms_sql.define_column(I_CURSOR, 12, CURR_VAL.SENDER_NAME, 40);
      dbms_sql.define_column(I_CURSOR, 12, CURR_VAL.SENDER_NAME, 60);  -- increased the size from 40 to 60 for 6880763
      dbms_sql.define_column(I_CURSOR, 13, CURR_VAL.ADAPTER_NAME, 40);
      dbms_sql.define_column(I_CURSOR, 14, CURR_VAL.FE_NAME, 40);

      I_VOID := dbms_sql.execute(I_CURSOR);

      I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);

      if I_ROWS_FETCHED = 0 then
         XNP_WSGL.EmptyPage(VF_BODY_ATTRIBUTES);
      else
         dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.MSG_ID);
         dbms_sql.column_value(I_CURSOR, 2, NBT_VAL.XML_PAYLOAD_LINK);
         dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.MSG_CODE);
         dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.MSG_STATUS);
         dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.DIRECTION_INDICATOR);
         dbms_sql.column_value(I_CURSOR, 6, CURR_VAL.REFERENCE_ID);
         dbms_sql.column_value(I_CURSOR, 7, CURR_VAL.OPP_REFERENCE_ID);
         dbms_sql.column_value(I_CURSOR, 8, CURR_VAL.MSG_VERSION);
         dbms_sql.column_value(I_CURSOR, 9, CURR_VAL.MSG_CREATION_DATE);
         dbms_sql.column_value(I_CURSOR, 10, CURR_VAL.SEND_RCV_DATE);
         dbms_sql.column_value(I_CURSOR, 11, CURR_VAL.RECIPIENT_NAME);
         dbms_sql.column_value(I_CURSOR, 12, CURR_VAL.SENDER_NAME);
         dbms_sql.column_value(I_CURSOR, 13, CURR_VAL.ADAPTER_NAME);
         dbms_sql.column_value(I_CURSOR, 14, CURR_VAL.FE_NAME);
         xnp_msg_diagnostics$xnp_msgs.QueryView(Z_DIRECT_CALL=>TRUE);
      end if;

      dbms_sql.close_cursor(I_CURSOR);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             VF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.QueryFirst');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'XNP_MSGS' module component  (Message Details).
--
-- Parameters:  None
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PreQuery(
            P_MSG_ID in varchar2,
            P_MSG_CODE in varchar2,
            P_L_MTE_MSG_TYPE in varchar2,
            P_MSG_STATUS in varchar2,
            P_REFERENCE_ID in varchar2,
            P_OPP_REFERENCE_ID in varchar2,
            P_RECIPIENT_NAME in varchar2,
            P_SENDER_NAME in varchar2,
            P_ADAPTER_NAME in varchar2,
            P_FE_NAME in varchar2,
            P_ORDER_ID in varchar2,
            P_WI_INSTANCE_ID in varchar2,
            P_FA_INSTANCE_ID in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'XNP_MSGS' module component  (Message Details).
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.PostQuery');
          return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.CreateQueryJavaScript
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

      htp.p(
'function MSG_CODE_LOV() {
   var filter = "";
   var the_pathname = location.pathname;
   var i            = the_pathname.indexOf (''/:'');
   var j            = the_pathname.indexOf (''/'', ++i);

   if (i != -1)
   {

     // Syntactically incorrect url so it needs to be corrected

     the_pathname = the_pathname.substring (j, the_pathname.length);

   }; // (i != -1)

   frmLOV = open("xnp_msg_diagnostics$xnp_msgs.msg_code_listofvalues" +
                 "?Z_FILTER=" + escape(filter) + "&Z_MODE=Q" +
                 "&Z_CALLER_URL=" + escape(location.protocol + ''//'' + location.host + the_pathname + location.search) +
                 "&Z_ISSUE_WAIT=Y",');
      if LOV_FRAME is not null then
         htp.p('                 "'||LOV_FRAME||'");');
      else
         htp.p('                 "winLOV", "scrollbars=yes,resizable=yes,width=400,height=400");');
      end if;
      htp.p('   if (frmLOV.opener == null) {
      frmLOV.opener = self;
   }
}
');

      htp.p(XNP_WSGJSL.CloseScript);
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             QF_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.CreateQueryJavaScript');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_msg_diagnostics$xnp_msgs.CreateListJavaScript
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'SFM iMessage Diagnostics'||' : '||'Message Details',
                             RL_BODY_ATTRIBUTES, 'xnp_msg_diagnostics$xnp_msgs.CreateListJavaScript');
   end;
end;

/
