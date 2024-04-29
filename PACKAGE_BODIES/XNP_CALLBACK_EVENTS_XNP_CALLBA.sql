--------------------------------------------------------
--  DDL for Package Body XNP_CALLBACK_EVENTS$XNP_CALLBA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_CALLBACK_EVENTS$XNP_CALLBA" as
/* $Header: XNPWE2CB.pls 120.1 2005/06/21 04:11:54 appldev ship $ */


   function BuildSQL(
            P_ORDER_ID in varchar2 default null,
            U_ORDER_ID in varchar2 default null,
            P_STATUS in varchar2 default null,
            P_MSG_CODE in varchar2 default null,
            P_CALLBACK_PROC_NAME in varchar2 default null,
            P_CALLBACK_TYPE in varchar2 default null,
            P_PROCESS_REFERENCE in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_CALLBACK_TIMESTAMP in varchar2 default null,
            U_CALLBACK_TIMESTAMP in varchar2 default null,
            P_REGISTERED_TIMESTAMP in varchar2 default null,
            U_REGISTERED_TIMESTAMP in varchar2 default null,
            P_WI_INSTANCE_ID in varchar2 default null,
            U_WI_INSTANCE_ID in varchar2 default null,
            P_FA_INSTANCE_ID in varchar2 default null,
            U_FA_INSTANCE_ID in varchar2 default null) return boolean;
   function PreQuery(
            P_ORDER_ID in varchar2 default null,
            U_ORDER_ID in varchar2 default null,
            P_STATUS in varchar2 default null,
            P_MSG_CODE in varchar2 default null,
            P_CALLBACK_PROC_NAME in varchar2 default null,
            P_CALLBACK_TYPE in varchar2 default null,
            P_PROCESS_REFERENCE in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_CALLBACK_TIMESTAMP in varchar2 default null,
            U_CALLBACK_TIMESTAMP in varchar2 default null,
            P_REGISTERED_TIMESTAMP in varchar2 default null,
            U_REGISTERED_TIMESTAMP in varchar2 default null,
            P_WI_INSTANCE_ID in varchar2 default null,
            U_WI_INSTANCE_ID in varchar2 default null,
            P_FA_INSTANCE_ID in varchar2 default null,
            U_FA_INSTANCE_ID in varchar2 default null) return boolean;
   function PostQuery(Z_POST_DML in boolean) return boolean;
   procedure CreateQueryJavaScript;
   procedure CreateListJavaScript;
   procedure InitialiseDomain(P_ALIAS in varchar2);
   function MSG_CODE_TranslateFK(
            P_MSG_CODE in varchar2 default null,
            Z_MODE in varchar2 default 'D') return boolean;

   QF_BODY_ATTRIBUTES     constant varchar2(500) := 'BGCOLOR="CCCCCC"';
   QF_QUERY_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_FIND_BUTTON'));
   QF_CLEAR_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_CLEAR_BUTTON'));
   QF_QUERY_BUT_ACTION    constant varchar2(10)  := 'QUERY';
   QF_CLEAR_BUT_ACTION    constant varchar2(10)  := 'CLEAR';
   QF_NUMBER_OF_COLUMNS   constant number(4)	 := 2;
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
   RL_RECORD_SET_SIZE     constant number(4)     := 12;
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

   CURR_VAL XNP_CALLBACK_EVENTS%ROWTYPE;

   TYPE FORM_REC IS RECORD
        (ORDER_ID            VARCHAR2(10)
        ,STATUS              VARCHAR2(10)
        ,MSG_CODE            VARCHAR2(20)
        ,CALLBACK_PROC_NAME  VARCHAR2(80)
        ,CALLBACK_TYPE       VARCHAR2(20)
        ,PROCESS_REFERENCE   VARCHAR2(512)
        ,REFERENCE_ID        VARCHAR2(80)
        ,CLOSE_REQD_FLAG     VARCHAR2(1)
        ,CALLBACK_EVENT_ID   VARCHAR2(8)
        ,CALLBACK_TIMESTAMP  VARCHAR2(25)
        ,REGISTERED_TIMESTAMP VARCHAR2(25)
        ,WI_INSTANCE_ID      VARCHAR2(25)
        ,FA_INSTANCE_ID      VARCHAR2(25)
        );
   FORM_VAL   FORM_REC;


   ZONE_SQL   VARCHAR2(3000) := null;

   D_STATUS              XNP_WSGL.typDVRecord;
   D_CALLBACK_TYPE       XNP_WSGL.typDVRecord;
   D_CLOSE_REQD_FLAG     XNP_WSGL.typDVRecord;
--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.InitialiseDomain
--
-- Description: Initialises the Domain Record for the given Column Usage
--
-- Parameters:  P_ALIAS   The alias of the column usage
--
--------------------------------------------------------------------------------
   procedure InitialiseDomain(P_ALIAS in varchar2) is
   begin

      if P_ALIAS = 'STATUS' and not D_STATUS.Initialised then
         D_STATUS.ColAlias := 'STATUS';
         D_STATUS.ControlType := XNP_WSGL.DV_LIST;
         D_STATUS.DispWidth := 10;
         D_STATUS.DispHeight := 1;
         D_STATUS.MaxWidth := 10;
         D_STATUS.UseMeanings := False;
         D_STATUS.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_CALLBACK_STATUS', D_STATUS);
         D_STATUS.Initialised := True;
      end if;

      if P_ALIAS = 'CALLBACK_TYPE' and not D_CALLBACK_TYPE.Initialised then
         D_CALLBACK_TYPE.ColAlias := 'CALLBACK_TYPE';
         D_CALLBACK_TYPE.ControlType := XNP_WSGL.DV_TEXT;
         D_CALLBACK_TYPE.DispWidth := 10;
         D_CALLBACK_TYPE.DispHeight := 1;
         D_CALLBACK_TYPE.MaxWidth := 20;
         D_CALLBACK_TYPE.UseMeanings := False;
         D_CALLBACK_TYPE.ColOptional := False;
         D_CALLBACK_TYPE.Vals(1) := 'JAVA';
         D_CALLBACK_TYPE.Meanings(1) := 'JAVA';
         D_CALLBACK_TYPE.Abbreviations(1) := '';
         D_CALLBACK_TYPE.Vals(2) := 'PL/SQL';
         D_CALLBACK_TYPE.Meanings(2) := 'PL/SQL';
         D_CALLBACK_TYPE.Abbreviations(2) := '';
         D_CALLBACK_TYPE.NumOfVV := 2;
         D_CALLBACK_TYPE.Initialised := True;
      end if;

      if P_ALIAS = 'CLOSE_REQD_FLAG' and not D_CLOSE_REQD_FLAG.Initialised then
         D_CLOSE_REQD_FLAG.ColAlias := 'CLOSE_REQD_FLAG';
         D_CLOSE_REQD_FLAG.ControlType := XNP_WSGL.DV_TEXT;
         D_CLOSE_REQD_FLAG.DispWidth := 1;
         D_CLOSE_REQD_FLAG.DispHeight := 1;
         D_CLOSE_REQD_FLAG.MaxWidth := 1;
         D_CLOSE_REQD_FLAG.UseMeanings := False;
         D_CLOSE_REQD_FLAG.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_YES_NO_FLAG_DEFAULT_YES', D_CLOSE_REQD_FLAG);
         D_CLOSE_REQD_FLAG.Initialised := True;
      end if;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             DEF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.InitialseDomain');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.MSG_CODE_TranslateFK
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function MSG_CODE_TranslateFK(
            P_MSG_CODE in varchar2,
            Z_MODE in varchar2) return boolean is
   begin
      select L_MTE.MSG_CODE
      into   CURR_VAL.MSG_CODE
      from   XNP_MSG_TYPES_B L_MTE
      where  rownum = 1
      and   ( L_MTE.MSG_CODE = P_MSG_CODE );
      return TRUE;
   exception
         when no_data_found then
            XNP_cg$errors.push('Message: '||
                           XNP_WSGL.MsgGetText(226,XNP_WSGLM.MSG226_INVALID_FK),
                           'E', 'WSG', SQLCODE, 'xnp_callback_events$xnp_callba.MSG_CODE_TranslateFK');
            return FALSE;
         when too_many_rows then
            XNP_cg$errors.push('Message: '||
                           XNP_WSGL.MsgGetText(227,XNP_WSGLM.MSG227_TOO_MANY_FKS),
                           'E', 'WSG', SQLCODE, 'xnp_callback_events$xnp_callba.MSG_CODE_TranslateFK');
            return FALSE;
         when others then
            XNP_cg$errors.push('Message: '||SQLERRM,
                           'E', 'WSG', SQLCODE, 'xnp_callback_events$xnp_callba.MSG_CODE_TranslateFK');
            return FALSE;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.msg_code_listofvalues
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

      XNP_WSGL.RegisterURL('xnp_callback_events$xnp_callba.msg_code_listofvalues');
      XNP_WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      XNP_WSGL.AddURLParam('Z_MODE', Z_MODE);
      XNP_WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      if XNP_WSGL.NotLowerCase then
         return;
      end if;


      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,
                        'Message'));

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
function PassBack(P_MSG_CODE) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||XNP_WSGL.MsgGetText(228,XNP_WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   opener.document.forms[0].P_MSG_CODE.value = P_MSG_CODE;
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

      xnp_callback_events$.TemplateHeader(TRUE,0);

      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);

      htp.header(2, htf.italic(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,'Message')));

      if Z_ISSUE_WAIT is not null then
         htp.p(XNP_WSGL.MsgGetText(127,XNP_WSGLM.DSP127_LOV_PLEASE_WAIT));
         XNP_WSGL.ClosePageBody;
         return;
      else
         htp.formOpen('xnp_callback_events$xnp_callba.msg_code_listofvalues');
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
      htp.p(XNP_WSGL.MsgGetText(19,XNP_WSGLM.CAP019_LOV_FILTER_CAPTION,'Message'));
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
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Message');
         XNP_WSGL.LayoutRowEnd;

         declare
            cursor c1(zmode varchar2,srch varchar2) is
               select L_MTE.MSG_CODE MSG_CODE
               from   XNP_MSG_TYPES_B L_MTE
               where  L_MTE.MSG_CODE like upper(srch)
               order by L_MTE.MSG_CODE;
         begin
            for c1rec in c1(Z_MODE,L_SEARCH_STRING) loop
               CURR_VAL.MSG_CODE := c1rec.MSG_CODE;
               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData('<a href="javascript:PassBack('''||
                               replace(replace(c1rec.MSG_CODE,'"','&quot;'),'''','\''')||''')">'||CURR_VAL.MSG_CODE||'</a>');
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events',
                             LOV_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.msg_code_listofvalues');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.Startup
--
-- Description: Entry point for the 'XNP_CALLBACK_EVENTS' module
--              component  (Callback Events).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_callback_events$xnp_callba.startup');
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.StoreURLLink(1, 'Callback Events');


      FormQuery(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             DEF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.ActionQuery
--
-- Description: Called when a Query form is subitted to action the query request.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure ActionQuery(
             P_ORDER_ID in varchar2,
             U_ORDER_ID in varchar2,
             P_STATUS in varchar2,
             P_MSG_CODE in varchar2,
             P_CALLBACK_PROC_NAME in varchar2,
             P_CALLBACK_TYPE in varchar2,
             P_PROCESS_REFERENCE in varchar2,
             P_REFERENCE_ID in varchar2,
             P_CALLBACK_TIMESTAMP in varchar2,
             U_CALLBACK_TIMESTAMP in varchar2,
             P_REGISTERED_TIMESTAMP in varchar2,
             U_REGISTERED_TIMESTAMP in varchar2,
             P_WI_INSTANCE_ID in varchar2,
             U_WI_INSTANCE_ID in varchar2,
             P_FA_INSTANCE_ID in varchar2,
             U_FA_INSTANCE_ID in varchar2,
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
                P_ORDER_ID,
                U_ORDER_ID,
                P_STATUS,
                P_MSG_CODE,
                P_CALLBACK_PROC_NAME,
                P_CALLBACK_TYPE,
                P_PROCESS_REFERENCE,
                P_REFERENCE_ID,
                P_CALLBACK_TIMESTAMP,
                U_CALLBACK_TIMESTAMP,
                P_REGISTERED_TIMESTAMP,
                U_REGISTERED_TIMESTAMP,
                P_WI_INSTANCE_ID,
                U_WI_INSTANCE_ID,
                P_FA_INSTANCE_ID,
                U_FA_INSTANCE_ID,
                null, L_BUTCHK, Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             DEF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.ActionQuery');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.QueryHits
--
-- Description: Returns the number or rows which matches the given search
--              criteria (if any).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function QueryHits(
            P_ORDER_ID in varchar2,
            U_ORDER_ID in varchar2,
            P_STATUS in varchar2,
            P_MSG_CODE in varchar2,
            P_CALLBACK_PROC_NAME in varchar2,
            P_CALLBACK_TYPE in varchar2,
            P_PROCESS_REFERENCE in varchar2,
            P_REFERENCE_ID in varchar2,
            P_CALLBACK_TIMESTAMP in varchar2,
            U_CALLBACK_TIMESTAMP in varchar2,
            P_REGISTERED_TIMESTAMP in varchar2,
            U_REGISTERED_TIMESTAMP in varchar2,
            P_WI_INSTANCE_ID in varchar2,
            U_WI_INSTANCE_ID in varchar2,
            P_FA_INSTANCE_ID in varchar2,
            U_FA_INSTANCE_ID in varchar2) return number is
      I_QUERY     varchar2(2000) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_ORDER_ID,
                      U_ORDER_ID,
                      P_STATUS,
                      P_MSG_CODE,
                      P_CALLBACK_PROC_NAME,
                      P_CALLBACK_TYPE,
                      P_PROCESS_REFERENCE,
                      P_REFERENCE_ID,
                      P_CALLBACK_TIMESTAMP,
                      U_CALLBACK_TIMESTAMP,
                      P_REGISTERED_TIMESTAMP,
                      U_REGISTERED_TIMESTAMP,
                      P_WI_INSTANCE_ID,
                      U_WI_INSTANCE_ID,
                      P_FA_INSTANCE_ID,
                      U_FA_INSTANCE_ID) then
         return -1;
      end if;

      if not PreQuery(P_ORDER_ID,
                      U_ORDER_ID,
                      P_STATUS,
                      P_MSG_CODE,
                      P_CALLBACK_PROC_NAME,
                      P_CALLBACK_TYPE,
                      P_PROCESS_REFERENCE,
                      P_REFERENCE_ID,
                      P_CALLBACK_TIMESTAMP,
                      U_CALLBACK_TIMESTAMP,
                      P_REGISTERED_TIMESTAMP,
                      U_REGISTERED_TIMESTAMP,
                      P_WI_INSTANCE_ID,
                      U_WI_INSTANCE_ID,
                      P_FA_INSTANCE_ID,
                      U_FA_INSTANCE_ID) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Callback Events'||' : '||'Callback Events', DEF_BODY_ATTRIBUTES);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             DEF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.QueryHits');
         return -1;
   end;--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.BuildSQL
--
-- Description: Builds the SQL for the 'XNP_CALLBACK_EVENTS' module component (Callback Events).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_ORDER_ID in varchar2,
            U_ORDER_ID in varchar2,
            P_STATUS in varchar2,
            P_MSG_CODE in varchar2,
            P_CALLBACK_PROC_NAME in varchar2,
            P_CALLBACK_TYPE in varchar2,
            P_PROCESS_REFERENCE in varchar2,
            P_REFERENCE_ID in varchar2,
            P_CALLBACK_TIMESTAMP in varchar2,
            U_CALLBACK_TIMESTAMP in varchar2,
            P_REGISTERED_TIMESTAMP in varchar2,
            U_REGISTERED_TIMESTAMP in varchar2,
            P_WI_INSTANCE_ID in varchar2,
            U_WI_INSTANCE_ID in varchar2,
            P_FA_INSTANCE_ID in varchar2,
            U_FA_INSTANCE_ID in varchar2) return boolean is

      I_WHERE varchar2(2000);
   begin

      InitialiseDomain('STATUS');
      InitialiseDomain('CALLBACK_TYPE');

      -- Build up the Where clause
      I_WHERE := I_WHERE || ' where L_MTE.MSG_CODE = CET.MSG_CODE';

      begin
         XNP_WSGL.BuildWhere(P_ORDER_ID, U_ORDER_ID, 'CET.ORDER_ID', XNP_WSGL.TYPE_NUMBER, I_WHERE);
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Callback Events'||' : '||'Callback Events', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Order ID'));
            return false;
      end;
      XNP_WSGL.BuildWhere(XNP_WSGL.DomainValue(D_STATUS, P_STATUS), 'CET.STATUS', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_MSG_CODE, 'CET.MSG_CODE', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(P_CALLBACK_PROC_NAME, 'CET.CALLBACK_PROC_NAME', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(XNP_WSGL.DomainValue(D_CALLBACK_TYPE, P_CALLBACK_TYPE), 'CET.CALLBACK_TYPE', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_PROCESS_REFERENCE, 'CET.PROCESS_REFERENCE', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(P_REFERENCE_ID, 'CET.REFERENCE_ID', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      begin
         XNP_WSGL.BuildWhere(P_CALLBACK_TIMESTAMP, U_CALLBACK_TIMESTAMP, 'CET.CALLBACK_TIMESTAMP', XNP_WSGL.TYPE_DATE, I_WHERE, 'DD-MON-RRRR HH24:MI:SS');
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Callback Events'||' : '||'Callback Events', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Callback Timestamp'),
                                XNP_WSGL.MsgGetText(211,XNP_WSGLM.MSG211_EXAMPLE_TODAY,to_char(sysdate, 'DD-MON-RRRR HH24:MI:SS')));
            return false;
      end;
      begin
         XNP_WSGL.BuildWhere(P_REGISTERED_TIMESTAMP, U_REGISTERED_TIMESTAMP, 'CET.REGISTERED_TIMESTAMP', XNP_WSGL.TYPE_DATE, I_WHERE, 'DD-MON-RRRR HH24:MI:SS');
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Callback Events'||' : '||'Callback Events', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Registered Timestamp'),
                                XNP_WSGL.MsgGetText(211,XNP_WSGLM.MSG211_EXAMPLE_TODAY,to_char(sysdate, 'DD-MON-RRRR HH24:MI:SS')));
            return false;
      end;
      begin
         XNP_WSGL.BuildWhere(P_WI_INSTANCE_ID, U_WI_INSTANCE_ID, 'CET.WI_INSTANCE_ID', XNP_WSGL.TYPE_NUMBER, I_WHERE);
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Callback Events'||' : '||'Callback Events', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'WI Instance ID'));
            return false;
      end;
      begin
         XNP_WSGL.BuildWhere(P_FA_INSTANCE_ID, U_FA_INSTANCE_ID, 'CET.FA_INSTANCE_ID', XNP_WSGL.TYPE_NUMBER, I_WHERE);
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Callback Events'||' : '||'Callback Events', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'FA Instance ID'));
            return false;
      end;

      ZONE_SQL := 'SELECT CET.ORDER_ID,
                         CET.STATUS,
                         CET.MSG_CODE,
                         CET.CALLBACK_PROC_NAME,
                         CET.CALLBACK_TYPE,
                         CET.PROCESS_REFERENCE,
                         CET.REFERENCE_ID,
                         CET.CLOSE_REQD_FLAG,
                         CET.CALLBACK_EVENT_ID,
                         CET.CALLBACK_TIMESTAMP,
                         CET.REGISTERED_TIMESTAMP,
                         CET.WI_INSTANCE_ID,
                         CET.FA_INSTANCE_ID
                  FROM   XNP_CALLBACK_EVENTS CET,
                         XNP_MSG_TYPES_B L_MTE';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY CET.CALLBACK_EVENT_ID Desc,
                                       CET.REFERENCE_ID,
                                       CET.CALLBACK_TIMESTAMP Desc ,
                                       CET.MSG_CODE,
                                       CET.REGISTERED_TIMESTAMP Desc ';
      return true;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             DEF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.BuildSQL');
         return false;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.FormQuery
--
-- Description: This procedure builds an HTML form for entry of query criteria.
--              The criteria entered are to restrict the query of the 'XNP_CALLBACK_EVENTS'
--              module component (Callback Events).
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

      XNP_WSGL.OpenPageHead('Callback Events'||' : '||'Callback Events');
      CreateQueryJavaScript;
	  -- Added for iHelp
	  htp.p('<SCRIPT> ');
	  icx_admin_sig.help_win_script('xnpDiag_events', null, 'XNP');
	  htp.p('</SCRIPT>');
	  -- <<
      xnp_callback_events$.TemplateHeader(TRUE,0);
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
      xnp_callback_events$.FirstPage(TRUE);
      --htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPCALLBACK_EVENTS_DETAILS_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','Callback Event Diagnostics')));
      htp.para;
      htp.p(XNP_WSGL.MsgGetText(116,XNP_WSGLM.DSP116_ENTER_QRY_CAPTION,'Callback Events'));
      htp.para;

      htp.formOpen(curl => 'xnp_callback_events$xnp_callba.actionquery', cattributes => 'NAME="frmZero"');

      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..QF_NUMBER_OF_COLUMNS loop
	  XNP_WSGL.LayoutHeader(21, 'LEFT', NULL);
	  XNP_WSGL.LayoutHeader(30, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Order ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('ORDER_ID', '10', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Status:'));
      InitialiseDomain('STATUS');
      XNP_WSGL.LayoutData(XNP_WSGL.BuildDVControl(D_STATUS, XNP_WSGL.CTL_QUERY));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Message:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('MSG_CODE', '10', FALSE) || ' ' ||
                      XNP_WSGJSL.LOVButton('MSG_CODE',LOV_BUTTON_TEXT));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Callback Procedure:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('CALLBACK_PROC_NAME', '30', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Callback Type:'));
      InitialiseDomain('CALLBACK_TYPE');
      XNP_WSGL.LayoutData(XNP_WSGL.BuildDVControl(D_CALLBACK_TYPE, XNP_WSGL.CTL_QUERY));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Process Reference:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('PROCESS_REFERENCE', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Reference Id:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('REFERENCE_ID', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Callback Timestamp:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('CALLBACK_TIMESTAMP', '25', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Registered Timestamp:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('REGISTERED_TIMESTAMP', '25', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('WI Instance ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('WI_INSTANCE_ID', '25', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('FA Instance ID:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('FA_INSTANCE_ID', '25', TRUE));
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             QF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.FormQuery');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.QueryList
--
-- Description: This procedure builds the Record list for the 'XNP_CALLBACK_EVENTS'
--              module component (Callback Events).
--
--              The Record List displays context information for records which
--              match the specified query criteria.
--              Sets of records are displayed (12 records at a time)
--              with Next/Previous buttons to get other record sets.
--
-- Parameters:  P_ORDER_ID - Order ID
--              U_ORDER_ID - Order ID (upper bound)
--              P_STATUS - Status
--              P_MSG_CODE - Message
--              P_CALLBACK_PROC_NAME - Callback Procedure
--              P_CALLBACK_TYPE - Callback Type
--              P_PROCESS_REFERENCE - Process Reference
--              P_REFERENCE_ID - Reference Id
--              P_CALLBACK_TIMESTAMP - Callback Timestamp
--              U_CALLBACK_TIMESTAMP - Callback Timestamp (upper bound)
--              P_REGISTERED_TIMESTAMP - Registered Timestamp
--              U_REGISTERED_TIMESTAMP - Registered Timestamp (upper bound)
--              P_WI_INSTANCE_ID - WI Instance ID
--              U_WI_INSTANCE_ID - WI Instance ID (upper bound)
--              P_FA_INSTANCE_ID - FA Instance ID
--              U_FA_INSTANCE_ID - FA Instance ID (upper bound)
--              Z_START - First record to display
--              Z_ACTION - Next or Previous set
--
--------------------------------------------------------------------------------
   procedure QueryList(
             P_ORDER_ID in varchar2,
             U_ORDER_ID in varchar2,
             P_STATUS in varchar2,
             P_MSG_CODE in varchar2,
             P_CALLBACK_PROC_NAME in varchar2,
             P_CALLBACK_TYPE in varchar2,
             P_PROCESS_REFERENCE in varchar2,
             P_REFERENCE_ID in varchar2,
             P_CALLBACK_TIMESTAMP in varchar2,
             U_CALLBACK_TIMESTAMP in varchar2,
             P_REGISTERED_TIMESTAMP in varchar2,
             U_REGISTERED_TIMESTAMP in varchar2,
             P_WI_INSTANCE_ID in varchar2,
             U_WI_INSTANCE_ID in varchar2,
             P_FA_INSTANCE_ID in varchar2,
             U_FA_INSTANCE_ID in varchar2,
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

      XNP_WSGL.RegisterURL('xnp_callback_events$xnp_callba.querylist');
      XNP_WSGL.AddURLParam('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.AddURLParam('U_ORDER_ID', U_ORDER_ID);
      XNP_WSGL.AddURLParam('P_STATUS', P_STATUS);
      XNP_WSGL.AddURLParam('P_MSG_CODE', P_MSG_CODE);
      XNP_WSGL.AddURLParam('P_CALLBACK_PROC_NAME', P_CALLBACK_PROC_NAME);
      XNP_WSGL.AddURLParam('P_CALLBACK_TYPE', P_CALLBACK_TYPE);
      XNP_WSGL.AddURLParam('P_PROCESS_REFERENCE', P_PROCESS_REFERENCE);
      XNP_WSGL.AddURLParam('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.AddURLParam('P_CALLBACK_TIMESTAMP', P_CALLBACK_TIMESTAMP);
      XNP_WSGL.AddURLParam('U_CALLBACK_TIMESTAMP', U_CALLBACK_TIMESTAMP);
      XNP_WSGL.AddURLParam('P_REGISTERED_TIMESTAMP', P_REGISTERED_TIMESTAMP);
      XNP_WSGL.AddURLParam('U_REGISTERED_TIMESTAMP', U_REGISTERED_TIMESTAMP);
      XNP_WSGL.AddURLParam('P_WI_INSTANCE_ID', P_WI_INSTANCE_ID);
      XNP_WSGL.AddURLParam('U_WI_INSTANCE_ID', U_WI_INSTANCE_ID);
      XNP_WSGL.AddURLParam('P_FA_INSTANCE_ID', P_FA_INSTANCE_ID);
      XNP_WSGL.AddURLParam('U_FA_INSTANCE_ID', U_FA_INSTANCE_ID);
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

      XNP_WSGL.OpenPageHead('Callback Events'||' : '||'Callback Events');
      CreateListJavaScript;
      xnp_callback_events$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>RL_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      --htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPCALLBACK_EVENTS_DETAILS_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','Callback Event Diagnostics')));
      if (Z_ACTION = RL_LAST_BUT_ACTION) or (Z_ACTION = RL_LAST_BUT_CAPTION) or
         (Z_ACTION = RL_COUNT_BUT_ACTION) or (Z_ACTION = RL_COUNT_BUT_CAPTION) or
         (RL_TOTAL_COUNT_REQD)
      then

         I_COUNT := QueryHits(
                    P_ORDER_ID,
                    U_ORDER_ID,
                    P_STATUS,
                    P_MSG_CODE,
                    P_CALLBACK_PROC_NAME,
                    P_CALLBACK_TYPE,
                    P_PROCESS_REFERENCE,
                    P_REFERENCE_ID,
                    P_CALLBACK_TIMESTAMP,
                    U_CALLBACK_TIMESTAMP,
                    P_REGISTERED_TIMESTAMP,
                    U_REGISTERED_TIMESTAMP,
                    P_WI_INSTANCE_ID,
                    U_WI_INSTANCE_ID,
                    P_FA_INSTANCE_ID,
                    U_FA_INSTANCE_ID);
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
                             'Callback Events'||' : '||'Callback Events', RL_BODY_ATTRIBUTES);
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
                       P_ORDER_ID,
                       U_ORDER_ID,
                       P_STATUS,
                       P_MSG_CODE,
                       P_CALLBACK_PROC_NAME,
                       P_CALLBACK_TYPE,
                       P_PROCESS_REFERENCE,
                       P_REFERENCE_ID,
                       P_CALLBACK_TIMESTAMP,
                       U_CALLBACK_TIMESTAMP,
                       P_REGISTERED_TIMESTAMP,
                       U_REGISTERED_TIMESTAMP,
                       P_WI_INSTANCE_ID,
                       U_WI_INSTANCE_ID,
                       P_FA_INSTANCE_ID,
                       U_FA_INSTANCE_ID) then
               XNP_WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if not PreQuery(
                       P_ORDER_ID,
                       U_ORDER_ID,
                       P_STATUS,
                       P_MSG_CODE,
                       P_CALLBACK_PROC_NAME,
                       P_CALLBACK_TYPE,
                       P_PROCESS_REFERENCE,
                       P_REFERENCE_ID,
                       P_CALLBACK_TIMESTAMP,
                       U_CALLBACK_TIMESTAMP,
                       P_REGISTERED_TIMESTAMP,
                       U_REGISTERED_TIMESTAMP,
                       P_WI_INSTANCE_ID,
                       U_WI_INSTANCE_ID,
                       P_FA_INSTANCE_ID,
                       U_FA_INSTANCE_ID) then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                                'Callback Events'||' : '||'Callback Events', RL_BODY_ATTRIBUTES);
         return;
         end if;

         InitialiseDomain('STATUS');
         InitialiseDomain('CALLBACK_TYPE');
         InitialiseDomain('CLOSE_REQD_FLAG');


         I_CURSOR := dbms_sql.open_cursor;
         dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
         dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.ORDER_ID);
         dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.STATUS, 10);
         dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.MSG_CODE, 20);
         dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.CALLBACK_PROC_NAME, 80);
         dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.CALLBACK_TYPE, 20);
         dbms_sql.define_column(I_CURSOR, 6, CURR_VAL.PROCESS_REFERENCE, 512);
         dbms_sql.define_column(I_CURSOR, 7, CURR_VAL.REFERENCE_ID, 80);
         dbms_sql.define_column(I_CURSOR, 8, CURR_VAL.CLOSE_REQD_FLAG, 1);
         dbms_sql.define_column(I_CURSOR, 9, CURR_VAL.CALLBACK_EVENT_ID);
         dbms_sql.define_column(I_CURSOR, 10, CURR_VAL.CALLBACK_TIMESTAMP);
         dbms_sql.define_column(I_CURSOR, 11, CURR_VAL.REGISTERED_TIMESTAMP);
         dbms_sql.define_column(I_CURSOR, 12, CURR_VAL.WI_INSTANCE_ID);
         dbms_sql.define_column(I_CURSOR, 13, CURR_VAL.FA_INSTANCE_ID);

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
      	    XNP_WSGL.LayoutHeader(10, 'RIGHT', 'Order ID');
      	    XNP_WSGL.LayoutHeader(10, 'LEFT', 'Status');
      	    XNP_WSGL.LayoutHeader(10, 'LEFT', 'Message');
      	    XNP_WSGL.LayoutHeader(30, 'LEFT', 'Callback Procedure');
      	    XNP_WSGL.LayoutHeader(10, 'LEFT', 'Callback Type');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Process Reference');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Reference Id');
      	    XNP_WSGL.LayoutHeader(1, 'LEFT', 'Close Reqd Flag');
      	    XNP_WSGL.LayoutHeader(25, 'LEFT', 'Callback Timestamp');
      	    XNP_WSGL.LayoutHeader(25, 'LEFT', 'Registered Timestamp');
      	    XNP_WSGL.LayoutHeader(25, 'RIGHT', 'WI Instance ID');
      	    XNP_WSGL.LayoutHeader(25, 'RIGHT', 'FA Instance ID');
         end loop;
         XNP_WSGL.LayoutRowEnd;

         while I_ROWS_FETCHED <> 0 loop

            if I_TOTAL_ROWS >= I_START then
               dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.ORDER_ID);
               dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.STATUS);
               dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.MSG_CODE);
               dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.CALLBACK_PROC_NAME);
               dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.CALLBACK_TYPE);
               dbms_sql.column_value(I_CURSOR, 6, CURR_VAL.PROCESS_REFERENCE);
               dbms_sql.column_value(I_CURSOR, 7, CURR_VAL.REFERENCE_ID);
               dbms_sql.column_value(I_CURSOR, 8, CURR_VAL.CLOSE_REQD_FLAG);
               dbms_sql.column_value(I_CURSOR, 9, CURR_VAL.CALLBACK_EVENT_ID);
               dbms_sql.column_value(I_CURSOR, 10, CURR_VAL.CALLBACK_TIMESTAMP);
               dbms_sql.column_value(I_CURSOR, 11, CURR_VAL.REGISTERED_TIMESTAMP);
               dbms_sql.column_value(I_CURSOR, 12, CURR_VAL.WI_INSTANCE_ID);
               dbms_sql.column_value(I_CURSOR, 13, CURR_VAL.FA_INSTANCE_ID);
               L_CHECKSUM := to_char(XNP_WSGL.Checksum(''||CURR_VAL.CALLBACK_EVENT_ID));


               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData(CURR_VAL.ORDER_ID);
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_STATUS, CURR_VAL.STATUS));
               XNP_WSGL.LayoutData(CURR_VAL.MSG_CODE);
               XNP_WSGL.LayoutData(CURR_VAL.CALLBACK_PROC_NAME);
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_CALLBACK_TYPE, CURR_VAL.CALLBACK_TYPE));
               XNP_WSGL.LayoutData(CURR_VAL.PROCESS_REFERENCE);
               XNP_WSGL.LayoutData(CURR_VAL.REFERENCE_ID);
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_CLOSE_REQD_FLAG, CURR_VAL.CLOSE_REQD_FLAG));
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.CALLBACK_TIMESTAMP, 'DD-MON-RRRR HH24:MI:SS')));
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.REGISTERED_TIMESTAMP, 'DD-MON-RRRR HH24:MI:SS')));
               XNP_WSGL.LayoutData(CURR_VAL.WI_INSTANCE_ID);
               XNP_WSGL.LayoutData(CURR_VAL.FA_INSTANCE_ID);
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

      htp.formOpen(curl => 'xnp_callback_events$xnp_callba.querylist', cattributes => 'NAME="frmZero"');
      XNP_WSGL.HiddenField('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.HiddenField('U_ORDER_ID', U_ORDER_ID);
      XNP_WSGL.HiddenField('P_STATUS', P_STATUS);
      XNP_WSGL.HiddenField('P_MSG_CODE', P_MSG_CODE);
      XNP_WSGL.HiddenField('P_CALLBACK_PROC_NAME', P_CALLBACK_PROC_NAME);
      XNP_WSGL.HiddenField('P_CALLBACK_TYPE', P_CALLBACK_TYPE);
      XNP_WSGL.HiddenField('P_PROCESS_REFERENCE', P_PROCESS_REFERENCE);
      XNP_WSGL.HiddenField('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.HiddenField('P_CALLBACK_TIMESTAMP', P_CALLBACK_TIMESTAMP);
      XNP_WSGL.HiddenField('U_CALLBACK_TIMESTAMP', U_CALLBACK_TIMESTAMP);
      XNP_WSGL.HiddenField('P_REGISTERED_TIMESTAMP', P_REGISTERED_TIMESTAMP);
      XNP_WSGL.HiddenField('U_REGISTERED_TIMESTAMP', U_REGISTERED_TIMESTAMP);
      XNP_WSGL.HiddenField('P_WI_INSTANCE_ID', P_WI_INSTANCE_ID);
      XNP_WSGL.HiddenField('U_WI_INSTANCE_ID', U_WI_INSTANCE_ID);
      XNP_WSGL.HiddenField('P_FA_INSTANCE_ID', P_FA_INSTANCE_ID);
      XNP_WSGL.HiddenField('U_FA_INSTANCE_ID', U_FA_INSTANCE_ID);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             RL_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.QueryList');
         XNP_WSGL.ClosePageBody;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'XNP_CALLBACK_EVENTS' module component  (Callback Events).
--
-- Parameters:  None
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PreQuery(
            P_ORDER_ID in varchar2,
            U_ORDER_ID in varchar2,
            P_STATUS in varchar2,
            P_MSG_CODE in varchar2,
            P_CALLBACK_PROC_NAME in varchar2,
            P_CALLBACK_TYPE in varchar2,
            P_PROCESS_REFERENCE in varchar2,
            P_REFERENCE_ID in varchar2,
            P_CALLBACK_TIMESTAMP in varchar2,
            U_CALLBACK_TIMESTAMP in varchar2,
            P_REGISTERED_TIMESTAMP in varchar2,
            U_REGISTERED_TIMESTAMP in varchar2,
            P_WI_INSTANCE_ID in varchar2,
            U_WI_INSTANCE_ID in varchar2,
            P_FA_INSTANCE_ID in varchar2,
            U_FA_INSTANCE_ID in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             DEF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'XNP_CALLBACK_EVENTS' module component  (Callback Events).
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             DEF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.PostQuery');
          return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.CreateQueryJavaScript
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

   frmLOV = open("xnp_callback_events$xnp_callba.msg_code_listofvalues" +
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             QF_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.CreateQueryJavaScript');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_callback_events$xnp_callba.CreateListJavaScript
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Callback Events'||' : '||'Callback Events',
                             RL_BODY_ATTRIBUTES, 'xnp_callback_events$xnp_callba.CreateListJavaScript');
   end;
end;

/
