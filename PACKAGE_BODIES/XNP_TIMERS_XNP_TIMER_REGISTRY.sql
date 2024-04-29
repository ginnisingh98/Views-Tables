--------------------------------------------------------
--  DDL for Package Body XNP_TIMERS$XNP_TIMER_REGISTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_TIMERS$XNP_TIMER_REGISTRY" as
/* $Header: XNPWE2TB.pls 120.1 2005/06/21 04:12:58 appldev ship $ */


   procedure FormView(Z_FORM_STATUS in number);
   function BuildSQL(
            P_ORDER_ID in varchar2 default null,
            U_ORDER_ID in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_TIMER_MESSAGE_CODE in varchar2 default null,
            P_STATUS in varchar2 default null,
            P_START_TIME in varchar2 default null,
            U_START_TIME in varchar2 default null,
            P_END_TIME in varchar2 default null,
            U_END_TIME in varchar2 default null,
            P_NEXT_TIMER in varchar2 default null) return boolean;
   function PreQuery(
            P_ORDER_ID in varchar2 default null,
            U_ORDER_ID in varchar2 default null,
            P_REFERENCE_ID in varchar2 default null,
            P_TIMER_MESSAGE_CODE in varchar2 default null,
            P_STATUS in varchar2 default null,
            P_START_TIME in varchar2 default null,
            U_START_TIME in varchar2 default null,
            P_END_TIME in varchar2 default null,
            U_END_TIME in varchar2 default null,
            P_NEXT_TIMER in varchar2 default null) return boolean;
   function PostQuery(Z_POST_DML in boolean) return boolean;
   procedure CreateQueryJavaScript;
   procedure CreateListJavaScript;
   procedure InitialiseDomain(P_ALIAS in varchar2);
   function TIMER_MESSAGE_CODE_TranslateFK(
            P_TIMER_MESSAGE_CODE in varchar2 default null,
            Z_MODE in varchar2 default 'D') return boolean;
   function NEXT_TIMER_TranslateFK(
            P_NEXT_TIMER in varchar2 default null,
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

   CURR_VAL XNP_TIMER_REGISTRY%ROWTYPE;

   TYPE FORM_REC IS RECORD
        (TIMER_ID            VARCHAR2(8)
        ,ORDER_ID            VARCHAR2(8)
        ,REFERENCE_ID        VARCHAR2(80)
        ,XML_PAYLOAD_LINK    VARCHAR2(2000)
        ,WI_INSTANCE_ID      VARCHAR2(8)
        ,FA_INSTANCE_ID      VARCHAR2(8)
        ,TIMER_MESSAGE_CODE  VARCHAR2(20)
        ,STATUS              VARCHAR2(20)
        ,START_TIME          VARCHAR2(20)
        ,END_TIME            VARCHAR2(20)
        ,NEXT_TIMER          VARCHAR2(20)
        );
   FORM_VAL   FORM_REC;

   TYPE NBT_REC IS RECORD
        (XML_PAYLOAD_LINK    VARCHAR2(2000)
        );
   NBT_VAL    NBT_REC;

   ZONE_SQL   VARCHAR2(2236) := null;

   D_STATUS              XNP_WSGL.typDVRecord;
--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.InitialiseDomain
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
         D_STATUS.ControlType := XNP_WSGL.DV_TEXT;
         D_STATUS.DispWidth := 20;
         D_STATUS.DispHeight := 1;
         D_STATUS.MaxWidth := 20;
         D_STATUS.UseMeanings := False;
         D_STATUS.ColOptional := False;
         D_STATUS.Vals(1) := 'ACTIVE';
         D_STATUS.Meanings(1) := 'ACTIVE';
         D_STATUS.Abbreviations(1) := '';
         D_STATUS.Vals(2) := 'EXPIRED';
         D_STATUS.Meanings(2) := 'EXPIRED';
         D_STATUS.Abbreviations(2) := '';
         D_STATUS.Vals(3) := 'CLOSED';
         D_STATUS.Meanings(3) := 'CLOSED';
         D_STATUS.Abbreviations(3) := '';
         D_STATUS.Vals(4) := 'REMOVED';
         D_STATUS.Meanings(4) := 'REMOVED';
         D_STATUS.Abbreviations(4) := '';
         D_STATUS.Vals(5) := 'WAITING';
         D_STATUS.Meanings(5) := 'WAITING';
         D_STATUS.Abbreviations(5) := '';
         D_STATUS.NumOfVV := 5;
         D_STATUS.Initialised := True;
      end if;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             DEF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.InitialseDomain');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.TIMER_MESSAGE_CODE_TranslateFK
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function TIMER_MESSAGE_CODE_TranslateFK(
            P_TIMER_MESSAGE_CODE in varchar2,
            Z_MODE in varchar2) return boolean is
   begin
      select MESSAGE_TYPES_2.MSG_CODE
      into   CURR_VAL.TIMER_MESSAGE_CODE
      from   XNP_MSG_TYPES_B MESSAGE_TYPES_2
      where  rownum = 1
      and   ( MESSAGE_TYPES_2.MSG_CODE = P_TIMER_MESSAGE_CODE )
      and    MSG_TYPE = 'TIMER';
      return TRUE;
   exception
         when no_data_found then
            XNP_cg$errors.push('Timer: '||
                           XNP_WSGL.MsgGetText(226,XNP_WSGLM.MSG226_INVALID_FK),
                           'E', 'WSG', SQLCODE, 'xnp_timers$xnp_timer_registry.TIMER_MESSAGE_CODE_TranslateFK');
            return FALSE;
         when too_many_rows then
            XNP_cg$errors.push('Timer: '||
                           XNP_WSGL.MsgGetText(227,XNP_WSGLM.MSG227_TOO_MANY_FKS),
                           'E', 'WSG', SQLCODE, 'xnp_timers$xnp_timer_registry.TIMER_MESSAGE_CODE_TranslateFK');
            return FALSE;
         when others then
            XNP_cg$errors.push('Timer: '||SQLERRM,
                           'E', 'WSG', SQLCODE, 'xnp_timers$xnp_timer_registry.TIMER_MESSAGE_CODE_TranslateFK');
            return FALSE;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.NEXT_TIMER_TranslateFK
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function NEXT_TIMER_TranslateFK(
            P_NEXT_TIMER in varchar2,
            Z_MODE in varchar2) return boolean is
   begin
      select MSG_CODE
      into   CURR_VAL.NEXT_TIMER
      from   XNP_MSG_TYPES_B
      where  rownum = 1
      and    MSG_TYPE = 'TIMER'
      and   ( MSG_CODE = P_NEXT_TIMER
      or     (MSG_CODE is null and P_NEXT_TIMER is null) );
      return TRUE;
   exception
         when no_data_found then
            XNP_cg$errors.push('Next Timer: '||
                           XNP_WSGL.MsgGetText(226,XNP_WSGLM.MSG226_INVALID_FK),
                           'E', 'WSG', SQLCODE, 'xnp_timers$xnp_timer_registry.NEXT_TIMER_TranslateFK');
            return FALSE;
         when too_many_rows then
            XNP_cg$errors.push('Next Timer: '||
                           XNP_WSGL.MsgGetText(227,XNP_WSGLM.MSG227_TOO_MANY_FKS),
                           'E', 'WSG', SQLCODE, 'xnp_timers$xnp_timer_registry.NEXT_TIMER_TranslateFK');
            return FALSE;
         when others then
            XNP_cg$errors.push('Next Timer: '||SQLERRM,
                           'E', 'WSG', SQLCODE, 'xnp_timers$xnp_timer_registry.NEXT_TIMER_TranslateFK');
            return FALSE;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.timer_message_code_listofvalue
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure timer_message_code_listofvalue(
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

      XNP_WSGL.RegisterURL('xnp_timers$xnp_timer_registry.timer_message_code_listofvalue');
      XNP_WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      XNP_WSGL.AddURLParam('Z_MODE', Z_MODE);
      XNP_WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      if XNP_WSGL.NotLowerCase then
         return;
      end if;


      XNP_WSGL.OpenPageHead('Timers');

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
function PassBack(P_TIMER_MESSAGE_CODE) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||XNP_WSGL.MsgGetText(228,XNP_WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   opener.document.forms[0].P_TIMER_MESSAGE_CODE.value = P_TIMER_MESSAGE_CODE;
   opener.document.forms[0].P_TIMER_MESSAGE_CODE.focus();
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

      xnp_timers$.TemplateHeader(TRUE,0);

      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);

      htp.header(2, htf.italic('Timers'));

      if Z_ISSUE_WAIT is not null then
         htp.p(XNP_WSGL.MsgGetText(127,XNP_WSGLM.DSP127_LOV_PLEASE_WAIT));
         XNP_WSGL.ClosePageBody;
         return;
      else
         htp.formOpen('xnp_timers$xnp_timer_registry.timer_message_code_listofvalue');
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
      htp.p(XNP_WSGL.MsgGetText(19,XNP_WSGLM.CAP019_LOV_FILTER_CAPTION,'Timer'));
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
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Timer');
         XNP_WSGL.LayoutRowEnd;

         declare
            l_uu varchar2(100);
            l_ul varchar2(100);
            l_lu varchar2(100);
            l_ll varchar2(100);
            l_retval number;
            cursor c1(zmode varchar2,srch varchar2,uu varchar2,ul varchar2,lu varchar2,ll varchar2) is
               select MESSAGE_TYPES_2.MSG_CODE TIMER_MESSAGE_CODE
               from   XNP_MSG_TYPES_B MESSAGE_TYPES_2
               where  ((MESSAGE_TYPES_2.MSG_CODE like uu||'%' or
                        MESSAGE_TYPES_2.MSG_CODE like ul||'%' or
                        MESSAGE_TYPES_2.MSG_CODE like lu||'%' or
                        MESSAGE_TYPES_2.MSG_CODE like ll||'%') and
                        upper(MESSAGE_TYPES_2.MSG_CODE) like upper(srch))
               and    MSG_TYPE = 'TIMER'
               order by MESSAGE_TYPES_2.MSG_CODE;
         begin
            l_retval := XNP_WSGL.SearchComponents(L_SEARCH_STRING,l_uu,l_ul,l_lu,l_ll);
            for c1rec in c1(Z_MODE, L_SEARCH_STRING,l_uu,l_ul,l_lu,l_ll) loop
               CURR_VAL.TIMER_MESSAGE_CODE := c1rec.TIMER_MESSAGE_CODE;
               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData('<a href="javascript:PassBack('''||
                               replace(replace(c1rec.TIMER_MESSAGE_CODE,'"','&quot;'),'''','\''')||''')">'||CURR_VAL.TIMER_MESSAGE_CODE||'</a>');
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry',
                             LOV_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.timer_message_code_listofvalue');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.next_timer_listofvalues
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure next_timer_listofvalues(
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

      XNP_WSGL.RegisterURL('xnp_timers$xnp_timer_registry.next_timer_listofvalues');
      XNP_WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      XNP_WSGL.AddURLParam('Z_MODE', Z_MODE);
      XNP_WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      if XNP_WSGL.NotLowerCase then
         return;
      end if;


      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,
                        'Next Timer'));

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
function PassBack(P_NEXT_TIMER) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||XNP_WSGL.MsgGetText(228,XNP_WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   opener.document.forms[0].P_NEXT_TIMER.value = P_NEXT_TIMER;
   opener.document.forms[0].P_NEXT_TIMER.focus();
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

      xnp_timers$.TemplateHeader(TRUE,0);

      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);

      htp.header(2, htf.italic(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,'Next Timer')));

      if Z_ISSUE_WAIT is not null then
         htp.p(XNP_WSGL.MsgGetText(127,XNP_WSGLM.DSP127_LOV_PLEASE_WAIT));
         XNP_WSGL.ClosePageBody;
         return;
      else
         htp.formOpen('xnp_timers$xnp_timer_registry.next_timer_listofvalues');
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
      htp.p(XNP_WSGL.MsgGetText(19,XNP_WSGLM.CAP019_LOV_FILTER_CAPTION,'Next Timer'));
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
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Next Timer');
         XNP_WSGL.LayoutRowEnd;

         declare
            l_uu varchar2(100);
            l_ul varchar2(100);
            l_lu varchar2(100);
            l_ll varchar2(100);
            l_retval number;
            cursor c1(zmode varchar2,srch varchar2,uu varchar2,ul varchar2,lu varchar2,ll varchar2) is
               select MSG_CODE NEXT_TIMER
               from   XNP_MSG_TYPES_B
               where  ((MSG_CODE like uu||'%' or
                        MSG_CODE like ul||'%' or
                        MSG_CODE like lu||'%' or
                        MSG_CODE like ll||'%') and
                        upper(MSG_CODE) like upper(srch))
               and    MSG_TYPE = 'TIMER'
               order by MSG_CODE;
         begin
            l_retval := XNP_WSGL.SearchComponents(L_SEARCH_STRING,l_uu,l_ul,l_lu,l_ll);
            for c1rec in c1(Z_MODE, L_SEARCH_STRING,l_uu,l_ul,l_lu,l_ll) loop
               CURR_VAL.NEXT_TIMER := c1rec.NEXT_TIMER;
               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData('<a href="javascript:PassBack('''||
                               replace(replace(c1rec.NEXT_TIMER,'"','&quot;'),'''','\''')||''')">'||CURR_VAL.NEXT_TIMER||'</a>');
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry',
                             LOV_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.next_timer_listofvalues');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.Startup
--
-- Description: Entry point for the 'XNP_TIMER_REGISTRY' module
--              component  (Timers).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_timers$xnp_timer_registry.startup');
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.StoreURLLink(1, 'Timers');


      FormQuery(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             DEF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.ActionQuery
--
-- Description: Called when a Query form is subitted to action the query request.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure ActionQuery(
             P_ORDER_ID in varchar2,
             U_ORDER_ID in varchar2,
             P_REFERENCE_ID in varchar2,
             P_TIMER_MESSAGE_CODE in varchar2,
             P_STATUS in varchar2,
             P_START_TIME in varchar2,
             U_START_TIME in varchar2,
             P_END_TIME in varchar2,
             U_END_TIME in varchar2,
             P_NEXT_TIMER in varchar2,
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
                P_REFERENCE_ID,
                P_TIMER_MESSAGE_CODE,
                P_STATUS,
                P_START_TIME,
                U_START_TIME,
                P_END_TIME,
                U_END_TIME,
                P_NEXT_TIMER,
                null, L_BUTCHK, Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             DEF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.ActionQuery');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.QueryHits
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
            P_REFERENCE_ID in varchar2,
            P_TIMER_MESSAGE_CODE in varchar2,
            P_STATUS in varchar2,
            P_START_TIME in varchar2,
            U_START_TIME in varchar2,
            P_END_TIME in varchar2,
            U_END_TIME in varchar2,
            P_NEXT_TIMER in varchar2) return number is
      I_QUERY     varchar2(2000) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_ORDER_ID,
                      U_ORDER_ID,
                      P_REFERENCE_ID,
                      P_TIMER_MESSAGE_CODE,
                      P_STATUS,
                      P_START_TIME,
                      U_START_TIME,
                      P_END_TIME,
                      U_END_TIME,
                      P_NEXT_TIMER) then
         return -1;
      end if;

      if not PreQuery(P_ORDER_ID,
                      U_ORDER_ID,
                      P_REFERENCE_ID,
                      P_TIMER_MESSAGE_CODE,
                      P_STATUS,
                      P_START_TIME,
                      U_START_TIME,
                      P_END_TIME,
                      U_END_TIME,
                      P_NEXT_TIMER) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Timer Registry'||' : '||'Timers', DEF_BODY_ATTRIBUTES);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             DEF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.QueryHits');
         return -1;
   end;--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.BuildSQL
--
-- Description: Builds the SQL for the 'XNP_TIMER_REGISTRY' module component (Timers).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_ORDER_ID in varchar2,
            U_ORDER_ID in varchar2,
            P_REFERENCE_ID in varchar2,
            P_TIMER_MESSAGE_CODE in varchar2,
            P_STATUS in varchar2,
            P_START_TIME in varchar2,
            U_START_TIME in varchar2,
            P_END_TIME in varchar2,
            U_END_TIME in varchar2,
            P_NEXT_TIMER in varchar2) return boolean is

      I_WHERE varchar2(2000);
   begin

      InitialiseDomain('STATUS');

      -- Build up the Where clause
      I_WHERE := I_WHERE || ' where MESSAGE_TYPES_2.MSG_CODE = TIMER_REGISTRY.TIMER_MESSAGE_CODE';
      I_WHERE := I_WHERE || ' and ' || 'MESSAGE_TYPES_2.MSG_TYPE = ''TIMER''';

      begin
         XNP_WSGL.BuildWhere(P_ORDER_ID, U_ORDER_ID, 'TIMER_REGISTRY.ORDER_ID', XNP_WSGL.TYPE_NUMBER, I_WHERE);
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Timer Registry'||' : '||'Timers', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Order Id'));
            return false;
      end;
      XNP_WSGL.BuildWhere(P_REFERENCE_ID, 'TIMER_REGISTRY.REFERENCE_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_TIMER_MESSAGE_CODE, 'TIMER_REGISTRY.TIMER_MESSAGE_CODE', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(XNP_WSGL.DomainValue(D_STATUS, P_STATUS), 'TIMER_REGISTRY.STATUS', XNP_WSGL.TYPE_CHAR, I_WHERE);
      begin
         XNP_WSGL.BuildWhere(P_START_TIME, U_START_TIME, 'TIMER_REGISTRY.START_TIME', XNP_WSGL.TYPE_DATE, I_WHERE, 'DD-MON-RRRR HH24:MI:SS');
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Timer Registry'||' : '||'Timers', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Start Time'),
                                XNP_WSGL.MsgGetText(211,XNP_WSGLM.MSG211_EXAMPLE_TODAY,to_char(sysdate, 'DD-MON-RRRR HH24:MI:SS')));
            return false;
      end;
      begin
         XNP_WSGL.BuildWhere(P_END_TIME, U_END_TIME, 'TIMER_REGISTRY.END_TIME', XNP_WSGL.TYPE_DATE, I_WHERE, 'DD-MON-RRRR HH24:MI:SS');
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Timer Registry'||' : '||'Timers', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'End Time'),
                                XNP_WSGL.MsgGetText(211,XNP_WSGLM.MSG211_EXAMPLE_TODAY,to_char(sysdate, 'DD-MON-RRRR HH24:MI:SS')));
            return false;
      end;
      XNP_WSGL.BuildWhere(P_NEXT_TIMER, 'TIMER_REGISTRY.NEXT_TIMER', XNP_WSGL.TYPE_CHAR, I_WHERE);

      ZONE_SQL := 'SELECT TIMER_REGISTRY.TIMER_ID,
                         TIMER_REGISTRY.ORDER_ID,
                         TIMER_REGISTRY.REFERENCE_ID,
                         ''xnp_web_utils.show_msg_body?p_msg_id=''||TIMER_REGISTRY.TIMER_ID,
                         TIMER_REGISTRY.TIMER_MESSAGE_CODE,
                         TIMER_REGISTRY.STATUS,
                         TIMER_REGISTRY.START_TIME,
                         TIMER_REGISTRY.END_TIME,
                         TIMER_REGISTRY.NEXT_TIMER
                  FROM   XNP_TIMER_REGISTRY TIMER_REGISTRY,
                         XNP_MSG_TYPES_B MESSAGE_TYPES_2';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY TIMER_REGISTRY.TIMER_ID Desc ,
                                       TIMER_REGISTRY.TIMER_MESSAGE_CODE';
      return true;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             DEF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.BuildSQL');
         return false;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.FormQuery
--
-- Description: This procedure builds an HTML form for entry of query criteria.
--              The criteria entered are to restrict the query of the 'XNP_TIMER_REGISTRY'
--              module component (Timers).
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

      XNP_WSGL.OpenPageHead('Timer Registry'||' : '||'Timers');
      CreateQueryJavaScript;
	  -- Added for iHelp
	  htp.p('<SCRIPT> ');
	  icx_admin_sig.help_win_script('xnpDiag_timer', null, 'XNP');
	  htp.p('</SCRIPT>');
	  -- <<
      xnp_timers$.TemplateHeader(TRUE,0);
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
      xnp_timers$.FirstPage(TRUE);
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPTIMER_DETAILS_TITLE')));
      htp.para;
      htp.p(XNP_WSGL.MsgGetText(116,XNP_WSGLM.DSP116_ENTER_QRY_CAPTION,'Timers'));
      htp.para;

      htp.formOpen(curl => 'xnp_timers$xnp_timer_registry.actionquery', cattributes => 'NAME="frmZero"');

      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..QF_NUMBER_OF_COLUMNS loop
	  XNP_WSGL.LayoutHeader(13, 'LEFT', NULL);
	  XNP_WSGL.LayoutHeader(20, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Order Id:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('ORDER_ID', '8', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Reference Id:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('REFERENCE_ID', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Timer:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('TIMER_MESSAGE_CODE', '20', FALSE) || ' ' ||
                      XNP_WSGJSL.LOVButton('TIMER_MESSAGE_CODE',LOV_BUTTON_TEXT));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Status:'));
      InitialiseDomain('STATUS');
      XNP_WSGL.LayoutData(XNP_WSGL.BuildDVControl(D_STATUS, XNP_WSGL.CTL_QUERY));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Start Time:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('START_TIME', '18', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('End Time:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('END_TIME', '18', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Next Timer:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('NEXT_TIMER', '20', FALSE) || ' ' ||
                      XNP_WSGJSL.LOVButton('NEXT_TIMER',LOV_BUTTON_TEXT));
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             QF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.FormQuery');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.FormView
--
-- Description: This procedure builds an HTML form for view/update of fields in
--              the 'XNP_TIMER_REGISTRY' module component (Timers).
--
-- Parameters:  Z_FORM_STATUS  Status of the form
--
--------------------------------------------------------------------------------
   procedure FormView(Z_FORM_STATUS in number) is


    begin

      XNP_WSGL.OpenPageHead('Timer Registry'||' : '||'Timers');
      xnp_timers$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>VF_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPTIMER_DETAILS_TITLE')));
      InitialiseDomain('STATUS');



      FORM_VAL.TIMER_ID := CURR_VAL.TIMER_ID;
      FORM_VAL.ORDER_ID := CURR_VAL.ORDER_ID;
      FORM_VAL.REFERENCE_ID := CURR_VAL.REFERENCE_ID;
      FORM_VAL.XML_PAYLOAD_LINK := NBT_VAL.XML_PAYLOAD_LINK;
      FORM_VAL.WI_INSTANCE_ID := CURR_VAL.WI_INSTANCE_ID;
      FORM_VAL.FA_INSTANCE_ID := CURR_VAL.FA_INSTANCE_ID;
      FORM_VAL.TIMER_MESSAGE_CODE := CURR_VAL.TIMER_MESSAGE_CODE;
      FORM_VAL.STATUS := XNP_WSGL.DomainMeaning(D_STATUS, CURR_VAL.STATUS);
      FORM_VAL.START_TIME := ltrim(to_char(CURR_VAL.START_TIME, 'DD-MON-RRRR HH24:MI:SS'));
      FORM_VAL.END_TIME := ltrim(to_char(CURR_VAL.END_TIME, 'DD-MON-RRRR HH24:MI:SS'));
      FORM_VAL.NEXT_TIMER := CURR_VAL.NEXT_TIMER;

      if Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_ERROR then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Timer Registry'||' : '||'Timers', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_UPD then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(207, XNP_WSGLM.MSG207_ROW_UPDATED),
                             'Timer Registry'||' : '||'Timers', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_INS then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(208, XNP_WSGLM.MSG208_ROW_INSERTED),
                             'Timer Registry'||' : '||'Timers', VF_BODY_ATTRIBUTES);
      end if;


      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE, P_BORDER=>TRUE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..VF_NUMBER_OF_COLUMNS loop
         XNP_WSGL.LayoutHeader(31, 'LEFT', NULL);
         XNP_WSGL.LayoutHeader(30, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Order Id:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.ORDER_ID));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Reference Id:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.REFERENCE_ID));
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.XML_PAYLOAD_LINK is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.anchor2(FORM_VAL.XML_PAYLOAD_LINK, 'XML'));
         XNP_WSGL.LayoutData('');
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Workitem Instance Id:'));
      XNP_WSGL.LayoutData(FORM_VAL.WI_INSTANCE_ID);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Fulfillment Action Instance Id:'));
      XNP_WSGL.LayoutData(FORM_VAL.FA_INSTANCE_ID);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Timer:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.TIMER_MESSAGE_CODE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Status:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.STATUS));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Start Time:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.START_TIME));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('End Time:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.END_TIME));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Next Timer:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.NEXT_TIMER));
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutClose;






      XNP_WSGL.ReturnLinks('0.1', XNP_WSGL.MENU_LONG);
      XNP_WSGL.NavLinks;


      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             VF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.FormView');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.QueryView
--
-- Description: Queries the details of a single row in preparation for display.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryView(
             P_TIMER_ID in varchar2,
             Z_POST_DML in boolean,
             Z_FORM_STATUS in number,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_timers$xnp_timer_registry.queryview');
      XNP_WSGL.AddURLParam('P_TIMER_ID', P_TIMER_ID);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('' ||
                                      P_TIMER_ID, Z_CHK) then
            return;
         end if;
      end if;


      if P_TIMER_ID is not null then
         CURR_VAL.TIMER_ID := P_TIMER_ID;
      end if;
      if Z_POST_DML then

         null;

      else

         SELECT TIMER_REGISTRY.TIMER_ID,
                TIMER_REGISTRY.ORDER_ID,
                TIMER_REGISTRY.REFERENCE_ID,
                TIMER_REGISTRY.WI_INSTANCE_ID,
                TIMER_REGISTRY.FA_INSTANCE_ID,
                TIMER_REGISTRY.TIMER_MESSAGE_CODE,
                TIMER_REGISTRY.STATUS,
                TIMER_REGISTRY.START_TIME,
                TIMER_REGISTRY.END_TIME,
                TIMER_REGISTRY.NEXT_TIMER
         INTO   CURR_VAL.TIMER_ID,
                CURR_VAL.ORDER_ID,
                CURR_VAL.REFERENCE_ID,
                CURR_VAL.WI_INSTANCE_ID,
                CURR_VAL.FA_INSTANCE_ID,
                CURR_VAL.TIMER_MESSAGE_CODE,
                CURR_VAL.STATUS,
                CURR_VAL.START_TIME,
                CURR_VAL.END_TIME,
                CURR_VAL.NEXT_TIMER
         FROM   XNP_TIMER_REGISTRY TIMER_REGISTRY,
                XNP_MSG_TYPES_B MESSAGE_TYPES_2
         WHERE  TIMER_REGISTRY.TIMER_ID = CURR_VAL.TIMER_ID
         AND    MESSAGE_TYPES_2.MSG_CODE = TIMER_REGISTRY.TIMER_MESSAGE_CODE
         ;

      end if;

      NBT_VAL.XML_PAYLOAD_LINK := 'xnp_web_utils.show_msg_body?p_msg_id='||CURR_VAL.TIMER_ID;

      if not PostQuery(Z_POST_DML) then
         FormView(XNP_WSGL.FORM_STATUS_ERROR);
      else
         FormView(Z_FORM_STATUS);
      end if;

   exception
      when NO_DATA_FOUND then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_WSGL.MsgGetText(204, XNP_WSGLM.MSG204_ROW_DELETED),
                             'Timer Registry'||' : '||'Timers', VF_BODY_ATTRIBUTES);
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             VF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.QueryView');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.QueryList
--
-- Description: This procedure builds the Record list for the 'XNP_TIMER_REGISTRY'
--              module component (Timers).
--
--              The Record List displays context information for records which
--              match the specified query criteria.
--              Sets of records are displayed (12 records at a time)
--              with Next/Previous buttons to get other record sets.
--
--              The first context column will be created as a link to the
--              xnp_timers$xnp_timer_registry.FormView procedure for display of more details
--              of that particular row.
--
-- Parameters:  P_ORDER_ID - Order Id
--              U_ORDER_ID - Order Id (upper bound)
--              P_REFERENCE_ID - Reference Id
--              P_TIMER_MESSAGE_CODE - Timer
--              P_STATUS - Status
--              P_START_TIME - Start Time
--              U_START_TIME - Start Time (upper bound)
--              P_END_TIME - End Time
--              U_END_TIME - End Time (upper bound)
--              P_NEXT_TIMER - Next Timer
--              Z_START - First record to display
--              Z_ACTION - Next or Previous set
--
--------------------------------------------------------------------------------
   procedure QueryList(
             P_ORDER_ID in varchar2,
             U_ORDER_ID in varchar2,
             P_REFERENCE_ID in varchar2,
             P_TIMER_MESSAGE_CODE in varchar2,
             P_STATUS in varchar2,
             P_START_TIME in varchar2,
             U_START_TIME in varchar2,
             P_END_TIME in varchar2,
             U_END_TIME in varchar2,
             P_NEXT_TIMER in varchar2,
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

      XNP_WSGL.RegisterURL('xnp_timers$xnp_timer_registry.querylist');
      XNP_WSGL.AddURLParam('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.AddURLParam('U_ORDER_ID', U_ORDER_ID);
      XNP_WSGL.AddURLParam('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.AddURLParam('P_TIMER_MESSAGE_CODE', P_TIMER_MESSAGE_CODE);
      XNP_WSGL.AddURLParam('P_STATUS', P_STATUS);
      XNP_WSGL.AddURLParam('P_START_TIME', P_START_TIME);
      XNP_WSGL.AddURLParam('U_START_TIME', U_START_TIME);
      XNP_WSGL.AddURLParam('P_END_TIME', P_END_TIME);
      XNP_WSGL.AddURLParam('U_END_TIME', U_END_TIME);
      XNP_WSGL.AddURLParam('P_NEXT_TIMER', P_NEXT_TIMER);
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

      XNP_WSGL.OpenPageHead('Timer Registry'||' : '||'Timers');
      CreateListJavaScript;
      xnp_timers$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>RL_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPTIMER_DETAILS_TITLE')));
      if (Z_ACTION = RL_LAST_BUT_ACTION) or (Z_ACTION = RL_LAST_BUT_CAPTION) or
         (Z_ACTION = RL_COUNT_BUT_ACTION) or (Z_ACTION = RL_COUNT_BUT_CAPTION) or
         (RL_TOTAL_COUNT_REQD)
      then

         I_COUNT := QueryHits(
                    P_ORDER_ID,
                    U_ORDER_ID,
                    P_REFERENCE_ID,
                    P_TIMER_MESSAGE_CODE,
                    P_STATUS,
                    P_START_TIME,
                    U_START_TIME,
                    P_END_TIME,
                    U_END_TIME,
                    P_NEXT_TIMER);
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
                             'Timer Registry'||' : '||'Timers', RL_BODY_ATTRIBUTES);
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
                       P_REFERENCE_ID,
                       P_TIMER_MESSAGE_CODE,
                       P_STATUS,
                       P_START_TIME,
                       U_START_TIME,
                       P_END_TIME,
                       U_END_TIME,
                       P_NEXT_TIMER) then
               XNP_WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if not PreQuery(
                       P_ORDER_ID,
                       U_ORDER_ID,
                       P_REFERENCE_ID,
                       P_TIMER_MESSAGE_CODE,
                       P_STATUS,
                       P_START_TIME,
                       U_START_TIME,
                       P_END_TIME,
                       U_END_TIME,
                       P_NEXT_TIMER) then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                                'Timer Registry'||' : '||'Timers', RL_BODY_ATTRIBUTES);
         return;
         end if;

         InitialiseDomain('STATUS');


         I_CURSOR := dbms_sql.open_cursor;
         dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
         dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.TIMER_ID);
         dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.ORDER_ID);
         dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.REFERENCE_ID, 80);
         dbms_sql.define_column(I_CURSOR, 4, NBT_VAL.XML_PAYLOAD_LINK, 2000);
         dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.TIMER_MESSAGE_CODE, 20);
         dbms_sql.define_column(I_CURSOR, 6, CURR_VAL.STATUS, 20);
         dbms_sql.define_column(I_CURSOR, 7, CURR_VAL.START_TIME);
         dbms_sql.define_column(I_CURSOR, 8, CURR_VAL.END_TIME);
         dbms_sql.define_column(I_CURSOR, 9, CURR_VAL.NEXT_TIMER, 20);

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
      	    XNP_WSGL.LayoutHeader(8, 'RIGHT', 'Order Id');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Reference Id');
      	    XNP_WSGL.LayoutHeader(30, 'LEFT', 'XML');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Timer');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Status');
      	    XNP_WSGL.LayoutHeader(18, 'LEFT', 'Start Time');
      	    XNP_WSGL.LayoutHeader(18, 'LEFT', 'End Time');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Next Timer');
         end loop;
         XNP_WSGL.LayoutRowEnd;

         while I_ROWS_FETCHED <> 0 loop

            if I_TOTAL_ROWS >= I_START then
               dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.TIMER_ID);
               dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.ORDER_ID);
               dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.REFERENCE_ID);
               dbms_sql.column_value(I_CURSOR, 4, NBT_VAL.XML_PAYLOAD_LINK);
               dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.TIMER_MESSAGE_CODE);
               dbms_sql.column_value(I_CURSOR, 6, CURR_VAL.STATUS);
               dbms_sql.column_value(I_CURSOR, 7, CURR_VAL.START_TIME);
               dbms_sql.column_value(I_CURSOR, 8, CURR_VAL.END_TIME);
               dbms_sql.column_value(I_CURSOR, 9, CURR_VAL.NEXT_TIMER);
               L_CHECKSUM := to_char(XNP_WSGL.Checksum(''||CURR_VAL.TIMER_ID));


               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData(htf.anchor2('xnp_timers$xnp_timer_registry.queryview?P_TIMER_ID='||CURR_VAL.TIMER_ID||'&Z_CHK='||L_CHECKSUM, CURR_VAL.ORDER_ID, ctarget=>L_VF_FRAME));
               XNP_WSGL.LayoutData(CURR_VAL.REFERENCE_ID);
               XNP_WSGL.LayoutData(htf.anchor2(NBT_VAL.XML_PAYLOAD_LINK, 'XML'));
               XNP_WSGL.LayoutData(CURR_VAL.TIMER_MESSAGE_CODE);
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_STATUS, CURR_VAL.STATUS));
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.START_TIME, 'DD-MON-RRRR HH24:MI:SS')));
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.END_TIME, 'DD-MON-RRRR HH24:MI:SS')));
               XNP_WSGL.LayoutData(CURR_VAL.NEXT_TIMER);
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

      htp.formOpen(curl => 'xnp_timers$xnp_timer_registry.querylist', cattributes => 'NAME="frmZero"');
      XNP_WSGL.HiddenField('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.HiddenField('U_ORDER_ID', U_ORDER_ID);
      XNP_WSGL.HiddenField('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.HiddenField('P_TIMER_MESSAGE_CODE', P_TIMER_MESSAGE_CODE);
      XNP_WSGL.HiddenField('P_STATUS', P_STATUS);
      XNP_WSGL.HiddenField('P_START_TIME', P_START_TIME);
      XNP_WSGL.HiddenField('U_START_TIME', U_START_TIME);
      XNP_WSGL.HiddenField('P_END_TIME', P_END_TIME);
      XNP_WSGL.HiddenField('U_END_TIME', U_END_TIME);
      XNP_WSGL.HiddenField('P_NEXT_TIMER', P_NEXT_TIMER);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             RL_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.QueryList');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.QueryFirst
--
-- Description: Finds the first row which matches the given search criteria
--              (if any), and calls QueryView for that row
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryFirst(
             P_ORDER_ID in varchar2,
             U_ORDER_ID in varchar2,
             P_REFERENCE_ID in varchar2,
             P_TIMER_MESSAGE_CODE in varchar2,
             P_STATUS in varchar2,
             P_START_TIME in varchar2,
             U_START_TIME in varchar2,
             P_END_TIME in varchar2,
             U_END_TIME in varchar2,
             P_NEXT_TIMER in varchar2,
             Z_ACTION in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is

      I_CURSOR            integer;
      I_VOID              integer;
      I_ROWS_FETCHED      integer := 0;

   begin

      XNP_WSGL.RegisterURL('xnp_timers$xnp_timer_registry.queryfirst');
      XNP_WSGL.AddURLParam('P_ORDER_ID', P_ORDER_ID);
      XNP_WSGL.AddURLParam('U_ORDER_ID', U_ORDER_ID);
      XNP_WSGL.AddURLParam('P_REFERENCE_ID', P_REFERENCE_ID);
      XNP_WSGL.AddURLParam('P_TIMER_MESSAGE_CODE', P_TIMER_MESSAGE_CODE);
      XNP_WSGL.AddURLParam('P_STATUS', P_STATUS);
      XNP_WSGL.AddURLParam('P_START_TIME', P_START_TIME);
      XNP_WSGL.AddURLParam('U_START_TIME', U_START_TIME);
      XNP_WSGL.AddURLParam('P_END_TIME', P_END_TIME);
      XNP_WSGL.AddURLParam('U_END_TIME', U_END_TIME);
      XNP_WSGL.AddURLParam('P_NEXT_TIMER', P_NEXT_TIMER);
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
                    P_ORDER_ID,
                    U_ORDER_ID,
                    P_REFERENCE_ID,
                    P_TIMER_MESSAGE_CODE,
                    P_STATUS,
                    P_START_TIME,
                    U_START_TIME,
                    P_END_TIME,
                    U_END_TIME,
                    P_NEXT_TIMER) then
         return;
      end if;

      if not PreQuery(
                    P_ORDER_ID,
                    U_ORDER_ID,
                    P_REFERENCE_ID,
                    P_TIMER_MESSAGE_CODE,
                    P_STATUS,
                    P_START_TIME,
                    U_START_TIME,
                    P_END_TIME,
                    U_END_TIME,
                    P_NEXT_TIMER) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Timer Registry'||' : '||'Timers', VF_BODY_ATTRIBUTES);
         return;
      end if;

      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.TIMER_ID);
      dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.ORDER_ID);
      dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.REFERENCE_ID, 80);
      dbms_sql.define_column(I_CURSOR, 4, NBT_VAL.XML_PAYLOAD_LINK, 2000);
      dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.TIMER_MESSAGE_CODE, 20);
      dbms_sql.define_column(I_CURSOR, 6, CURR_VAL.STATUS, 20);
      dbms_sql.define_column(I_CURSOR, 7, CURR_VAL.START_TIME);
      dbms_sql.define_column(I_CURSOR, 8, CURR_VAL.END_TIME);
      dbms_sql.define_column(I_CURSOR, 9, CURR_VAL.NEXT_TIMER, 20);

      I_VOID := dbms_sql.execute(I_CURSOR);

      I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);

      if I_ROWS_FETCHED = 0 then
         XNP_WSGL.EmptyPage(VF_BODY_ATTRIBUTES);
      else
         dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.TIMER_ID);
         dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.ORDER_ID);
         dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.REFERENCE_ID);
         dbms_sql.column_value(I_CURSOR, 4, NBT_VAL.XML_PAYLOAD_LINK);
         dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.TIMER_MESSAGE_CODE);
         dbms_sql.column_value(I_CURSOR, 6, CURR_VAL.STATUS);
         dbms_sql.column_value(I_CURSOR, 7, CURR_VAL.START_TIME);
         dbms_sql.column_value(I_CURSOR, 8, CURR_VAL.END_TIME);
         dbms_sql.column_value(I_CURSOR, 9, CURR_VAL.NEXT_TIMER);
         xnp_timers$xnp_timer_registry.QueryView(Z_DIRECT_CALL=>TRUE);
      end if;

      dbms_sql.close_cursor(I_CURSOR);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             VF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.QueryFirst');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'XNP_TIMER_REGISTRY' module component  (Timers).
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
            P_REFERENCE_ID in varchar2,
            P_TIMER_MESSAGE_CODE in varchar2,
            P_STATUS in varchar2,
            P_START_TIME in varchar2,
            U_START_TIME in varchar2,
            P_END_TIME in varchar2,
            U_END_TIME in varchar2,
            P_NEXT_TIMER in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             DEF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'XNP_TIMER_REGISTRY' module component  (Timers).
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             DEF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.PostQuery');
          return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.CreateQueryJavaScript
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
'function TIMER_MESSAGE_CODE_LOV() {
   var filter = "";
   var the_pathname = location.pathname;
   var i            = the_pathname.indexOf (''/:'');
   var j            = the_pathname.indexOf (''/'', ++i);

   if (i != -1)
   {

     // Syntactically incorrect url so it needs to be corrected

     the_pathname = the_pathname.substring (j, the_pathname.length);

   }; // (i != -1)

   frmLOV = open("xnp_timers$xnp_timer_registry.timer_message_code_listofvalue" +
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

      htp.p(
'function NEXT_TIMER_LOV() {
   var filter = "";
   var the_pathname = location.pathname;
   var i            = the_pathname.indexOf (''/:'');
   var j            = the_pathname.indexOf (''/'', ++i);

   if (i != -1)
   {

     // Syntactically incorrect url so it needs to be corrected

     the_pathname = the_pathname.substring (j, the_pathname.length);

   }; // (i != -1)

   frmLOV = open("xnp_timers$xnp_timer_registry.next_timer_listofvalues" +
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             QF_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.CreateQueryJavaScript');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_timers$xnp_timer_registry.CreateListJavaScript
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Timer Registry'||' : '||'Timers',
                             RL_BODY_ATTRIBUTES, 'xnp_timers$xnp_timer_registry.CreateListJavaScript');
   end;
end;

/
