--------------------------------------------------------
--  DDL for Package Body XNP_NUMBER_SPLITS$NUMBER_SPLIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_NUMBER_SPLITS$NUMBER_SPLIT" as
/* $Header: XNPNUM2B.pls 120.1 2005/06/21 04:10:54 appldev ship $ */


   procedure FormView(Z_FORM_STATUS in number);
   function BuildSQL(
            P_L_NRE_OBJECT_REFERENCE in varchar2 default null,
            P_L_NRE2_OBJECT_REFERENCE in varchar2 default null,
            P_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
            U_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
            P_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
            U_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
            P_L_NRE_STARTING_NUMBER in varchar2 default null,
            P_L_NRE_ENDING_NUMBER in varchar2 default null,
            P_L_NRE2_STARTING_NUMBER in varchar2 default null,
            P_L_NRE2_ENDING_NUMBER in varchar2 default null) return boolean;
   function PreQuery(
            P_L_NRE_OBJECT_REFERENCE in varchar2 default null,
            P_L_NRE2_OBJECT_REFERENCE in varchar2 default null,
            P_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
            U_PERMISSIVE_DIAL_START_DATE in varchar2 default null,
            P_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
            U_PERMISSIVE_DIAL_END_DATE in varchar2 default null,
            P_L_NRE_STARTING_NUMBER in varchar2 default null,
            P_L_NRE_ENDING_NUMBER in varchar2 default null,
            P_L_NRE2_STARTING_NUMBER in varchar2 default null,
            P_L_NRE2_ENDING_NUMBER in varchar2 default null) return boolean;
   function PostQuery(Z_POST_DML in boolean) return boolean;
   procedure CreateQueryJavaScript;
   procedure CreateListJavaScript;
   function NEW_NUMBER_RANGE_ID_TranslateF(
            P_L_NRE2_OBJECT_REFERENCE in varchar2 default null,
            P_L_NRE2_STARTING_NUMBER in varchar2 default null,
            P_L_NRE2_ENDING_NUMBER in varchar2 default null,
            Z_MODE in varchar2 default 'D') return boolean;
   function OLD_NUMBER_RANGE_ID_TranslateF(
            P_L_NRE_OBJECT_REFERENCE in varchar2 default null,
            P_L_NRE_STARTING_NUMBER in varchar2 default null,
            P_L_NRE_ENDING_NUMBER in varchar2 default null,
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

   CURR_VAL XNP_NUMBER_SPLITS%ROWTYPE;

   TYPE FORM_REC IS RECORD
        (NUMBER_SPLIT_ID     VARCHAR2(8)
        ,NEW_NUMBER_RANGE_ID VARCHAR2(8)
        ,OLD_NUMBER_RANGE_ID VARCHAR2(8)
        ,L_NRE_OBJECT_REFERENCE VARCHAR2(80)
        ,L_NRE2_OBJECT_REFERENCE VARCHAR2(80)
        ,PERMISSIVE_DIAL_START_DATE VARCHAR2(20)
        ,PERMISSIVE_DIAL_END_DATE VARCHAR2(20)
        ,L_NRE_STARTING_NUMBER VARCHAR2(20)
        ,L_NRE_ENDING_NUMBER VARCHAR2(20)
        ,L_NRE2_STARTING_NUMBER VARCHAR2(20)
        ,L_NRE2_ENDING_NUMBER VARCHAR2(20)
        ,CONVERSION_PROCEDURE VARCHAR2(2000)
        );
   FORM_VAL   FORM_REC;

   TYPE NBT_REC IS RECORD
        (L_NRE_OBJECT_REFERENCE XNP_NUMBER_RANGES.OBJECT_REFERENCE%TYPE
        ,L_NRE2_OBJECT_REFERENCE XNP_NUMBER_RANGES.OBJECT_REFERENCE%TYPE
        ,L_NRE_STARTING_NUMBER XNP_NUMBER_RANGES.STARTING_NUMBER%TYPE
        ,L_NRE_ENDING_NUMBER XNP_NUMBER_RANGES.ENDING_NUMBER%TYPE
        ,L_NRE2_STARTING_NUMBER XNP_NUMBER_RANGES.STARTING_NUMBER%TYPE
        ,L_NRE2_ENDING_NUMBER XNP_NUMBER_RANGES.ENDING_NUMBER%TYPE
        );
   NBT_VAL    NBT_REC;

   ZONE_SQL   VARCHAR2(3300) := null;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.NEW_NUMBER_RANGE_ID_TranslateF
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function NEW_NUMBER_RANGE_ID_TranslateF(
            P_L_NRE2_OBJECT_REFERENCE in varchar2,
            P_L_NRE2_STARTING_NUMBER in varchar2,
            P_L_NRE2_ENDING_NUMBER in varchar2,
            Z_MODE in varchar2) return boolean is
   begin
      select L_NRE2.NUMBER_RANGE_ID
      into   CURR_VAL.NEW_NUMBER_RANGE_ID
      from   XNP_NUMBER_RANGES L_NRE2
      where  rownum = 1
      and   ( L_NRE2.OBJECT_REFERENCE = P_L_NRE2_OBJECT_REFERENCE )
      and   ( L_NRE2.STARTING_NUMBER = P_L_NRE2_STARTING_NUMBER )
      and   ( L_NRE2.ENDING_NUMBER = P_L_NRE2_ENDING_NUMBER );
      return TRUE;
   exception
         when no_data_found then
            XNP_cg$errors.push('New Range, New Range Starting Number, New Range Ending Number: '||
                           XNP_WSGL.MsgGetText(226,XNP_WSGLM.MSG226_INVALID_FK),
                           'E', 'WSG', SQLCODE, 'xnp_number_splits$number_split.NEW_NUMBER_RANGE_ID_TranslateF');
            return FALSE;
         when too_many_rows then
            XNP_cg$errors.push('New Range, New Range Starting Number, New Range Ending Number: '||
                           XNP_WSGL.MsgGetText(227,XNP_WSGLM.MSG227_TOO_MANY_FKS),
                           'E', 'WSG', SQLCODE, 'xnp_number_splits$number_split.NEW_NUMBER_RANGE_ID_TranslateF');
            return FALSE;
         when others then
            XNP_cg$errors.push('New Range, New Range Starting Number, New Range Ending Number: '||SQLERRM,
                           'E', 'WSG', SQLCODE, 'xnp_number_splits$number_split.NEW_NUMBER_RANGE_ID_TranslateF');
            return FALSE;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.OLD_NUMBER_RANGE_ID_TranslateF
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function OLD_NUMBER_RANGE_ID_TranslateF(
            P_L_NRE_OBJECT_REFERENCE in varchar2,
            P_L_NRE_STARTING_NUMBER in varchar2,
            P_L_NRE_ENDING_NUMBER in varchar2,
            Z_MODE in varchar2) return boolean is
   begin
      select L_NRE.NUMBER_RANGE_ID
      into   CURR_VAL.OLD_NUMBER_RANGE_ID
      from   XNP_NUMBER_RANGES L_NRE
      where  rownum = 1
      and   ( L_NRE.OBJECT_REFERENCE = P_L_NRE_OBJECT_REFERENCE )
      and   ( L_NRE.STARTING_NUMBER = P_L_NRE_STARTING_NUMBER )
      and   ( L_NRE.ENDING_NUMBER = P_L_NRE_ENDING_NUMBER );
      return TRUE;
   exception
         when no_data_found then
            XNP_cg$errors.push('Initial Range, Initial Range Starting Number, Initial Range Ending Number: '||
                           XNP_WSGL.MsgGetText(226,XNP_WSGLM.MSG226_INVALID_FK),
                           'E', 'WSG', SQLCODE, 'xnp_number_splits$number_split.OLD_NUMBER_RANGE_ID_TranslateF');
            return FALSE;
         when too_many_rows then
            XNP_cg$errors.push('Initial Range, Initial Range Starting Number, Initial Range Ending Number: '||
                           XNP_WSGL.MsgGetText(227,XNP_WSGLM.MSG227_TOO_MANY_FKS),
                           'E', 'WSG', SQLCODE, 'xnp_number_splits$number_split.OLD_NUMBER_RANGE_ID_TranslateF');
            return FALSE;
         when others then
            XNP_cg$errors.push('Initial Range, Initial Range Starting Number, Initial Range Ending Number: '||SQLERRM,
                           'E', 'WSG', SQLCODE, 'xnp_number_splits$number_split.OLD_NUMBER_RANGE_ID_TranslateF');
            return FALSE;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.l_nre2_object_reference_listof
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure l_nre2_object_reference_listof(
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

      XNP_WSGL.RegisterURL('xnp_number_splits$number_split.l_nre2_object_reference_listof');
      XNP_WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      XNP_WSGL.AddURLParam('Z_MODE', Z_MODE);
      XNP_WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      if XNP_WSGL.NotLowerCase then
         return;
      end if;


      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,
                        'New Range, New Range Starting Number, New Range Ending Number'));

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
function PassBack(P_L_NRE2_OBJECT_REFERENCE,P_L_NRE2_STARTING_NUMBER,P_L_NRE2_ENDING_NUMBER) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||XNP_WSGL.MsgGetText(228,XNP_WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   opener.document.forms[0].P_L_NRE2_OBJECT_REFERENCE.value = P_L_NRE2_OBJECT_REFERENCE;
   opener.document.forms[0].P_L_NRE2_STARTING_NUMBER.value = P_L_NRE2_STARTING_NUMBER;
   opener.document.forms[0].P_L_NRE2_ENDING_NUMBER.value = P_L_NRE2_ENDING_NUMBER;
   opener.document.forms[0].P_L_NRE2_OBJECT_REFERENCE.focus();
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

      xnp_number_splits$.TemplateHeader(TRUE,0);

      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);

      htp.header(2, htf.italic(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,'New Range, New Range Starting Number, New Range Ending Number')));

      if Z_ISSUE_WAIT is not null then
         htp.p(XNP_WSGL.MsgGetText(127,XNP_WSGLM.DSP127_LOV_PLEASE_WAIT));
         XNP_WSGL.ClosePageBody;
         return;
      else
         htp.formOpen('xnp_number_splits$number_split.l_nre2_object_reference_listof');
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
      htp.p(XNP_WSGL.MsgGetText(19,XNP_WSGLM.CAP019_LOV_FILTER_CAPTION,'New Range'));
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
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'New Range');
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'New Range Starting Number');
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'New Range Ending Number');
         XNP_WSGL.LayoutRowEnd;

         declare
            cursor c1(zmode varchar2,srch varchar2) is
               select L_NRE2.NUMBER_RANGE_ID NEW_NUMBER_RANGE_ID
               ,      L_NRE2.OBJECT_REFERENCE L_NRE2_OBJECT_REFERENCE
               ,      L_NRE2.STARTING_NUMBER L_NRE2_STARTING_NUMBER
               ,      L_NRE2.ENDING_NUMBER L_NRE2_ENDING_NUMBER
               from   XNP_NUMBER_RANGES L_NRE2
               where  L_NRE2.OBJECT_REFERENCE like upper(srch)
               order by L_NRE2.OBJECT_REFERENCE;
         begin
            for c1rec in c1(Z_MODE,L_SEARCH_STRING) loop
               NBT_VAL.L_NRE2_OBJECT_REFERENCE := c1rec.L_NRE2_OBJECT_REFERENCE;
               NBT_VAL.L_NRE2_STARTING_NUMBER := c1rec.L_NRE2_STARTING_NUMBER;
               NBT_VAL.L_NRE2_ENDING_NUMBER := c1rec.L_NRE2_ENDING_NUMBER;
               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData('<a href="javascript:PassBack('''||
                               replace(replace(c1rec.L_NRE2_OBJECT_REFERENCE,'"','&quot;'),'''','\''')||''','''||
                               replace(replace(c1rec.L_NRE2_STARTING_NUMBER,'"','&quot;'),'''','\''')||''','''||
                               replace(replace(c1rec.L_NRE2_ENDING_NUMBER,'"','&quot;'),'''','\''')||''')">'||NBT_VAL.L_NRE2_OBJECT_REFERENCE||'</a>');
               XNP_WSGL.LayoutData(replace(NBT_VAL.L_NRE2_STARTING_NUMBER,'"','&quot;'));
               XNP_WSGL.LayoutData(replace(NBT_VAL.L_NRE2_ENDING_NUMBER,'"','&quot;'));
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits',
                             LOV_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.l_nre2_object_reference_listof');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.l_nre_object_reference_listofv
--
-- Description:
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure l_nre_object_reference_listofv(
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

      XNP_WSGL.RegisterURL('xnp_number_splits$number_split.l_nre_object_reference_listofv');
      XNP_WSGL.AddURLParam('Z_FILTER', Z_FILTER);
      XNP_WSGL.AddURLParam('Z_MODE', Z_MODE);
      XNP_WSGL.AddURLParam('Z_CALLER_URL', Z_CALLER_URL);
      if XNP_WSGL.NotLowerCase then
         return;
      end if;


      XNP_WSGL.OpenPageHead(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,
                        'Initial Range, Initial Range Starting Number, Initial Range Ending Number'));

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
function PassBack(P_L_NRE_OBJECT_REFERENCE,P_L_NRE_STARTING_NUMBER,P_L_NRE_ENDING_NUMBER) {
   if (opener.location.href != document.forms[0].Z_CALLER_URL.value) {
      alert("'||XNP_WSGL.MsgGetText(228,XNP_WSGLM.MSG228_LOV_NOT_IN_CONTEXT)||'");
      return;
   }
   opener.document.forms[0].P_L_NRE_OBJECT_REFERENCE.value = P_L_NRE_OBJECT_REFERENCE;
   opener.document.forms[0].P_L_NRE_STARTING_NUMBER.value = P_L_NRE_STARTING_NUMBER;
   opener.document.forms[0].P_L_NRE_ENDING_NUMBER.value = P_L_NRE_ENDING_NUMBER;
   opener.document.forms[0].P_L_NRE_OBJECT_REFERENCE.focus();
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

      xnp_number_splits$.TemplateHeader(TRUE,0);

      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>L_BODY_ATTRIBUTES);

      htp.header(2, htf.italic(XNP_WSGL.MsgGetText(123,XNP_WSGLM.DSP123_LOV_CAPTION,'Initial Range, Initial Range Starting Number, Initial Range Ending Number')));

      if Z_ISSUE_WAIT is not null then
         htp.p(XNP_WSGL.MsgGetText(127,XNP_WSGLM.DSP127_LOV_PLEASE_WAIT));
         XNP_WSGL.ClosePageBody;
         return;
      else
         htp.formOpen('xnp_number_splits$number_split.l_nre_object_reference_listofv');
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
      htp.p(XNP_WSGL.MsgGetText(19,XNP_WSGLM.CAP019_LOV_FILTER_CAPTION,'Initial Range'));
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
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Initial Range');
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Initial Range Starting Number');
         XNP_WSGL.LayoutHeader(1, 'LEFT', 'Initial Range Ending Number');
         XNP_WSGL.LayoutRowEnd;

         declare
            cursor c1(zmode varchar2,srch varchar2) is
               select L_NRE.NUMBER_RANGE_ID OLD_NUMBER_RANGE_ID
               ,      L_NRE.OBJECT_REFERENCE L_NRE_OBJECT_REFERENCE
               ,      L_NRE.STARTING_NUMBER L_NRE_STARTING_NUMBER
               ,      L_NRE.ENDING_NUMBER L_NRE_ENDING_NUMBER
               from   XNP_NUMBER_RANGES L_NRE
               where  L_NRE.OBJECT_REFERENCE like upper(srch)
               order by L_NRE.OBJECT_REFERENCE;
         begin
            for c1rec in c1(Z_MODE,L_SEARCH_STRING) loop
               NBT_VAL.L_NRE_OBJECT_REFERENCE := c1rec.L_NRE_OBJECT_REFERENCE;
               NBT_VAL.L_NRE_STARTING_NUMBER := c1rec.L_NRE_STARTING_NUMBER;
               NBT_VAL.L_NRE_ENDING_NUMBER := c1rec.L_NRE_ENDING_NUMBER;
               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData('<a href="javascript:PassBack('''||
                               replace(replace(c1rec.L_NRE_OBJECT_REFERENCE,'"','&quot;'),'''','\''')||''','''||
                               replace(replace(c1rec.L_NRE_STARTING_NUMBER,'"','&quot;'),'''','\''')||''','''||
                               replace(replace(c1rec.L_NRE_ENDING_NUMBER,'"','&quot;'),'''','\''')||''')">'||NBT_VAL.L_NRE_OBJECT_REFERENCE||'</a>');
               XNP_WSGL.LayoutData(replace(NBT_VAL.L_NRE_STARTING_NUMBER,'"','&quot;'));
               XNP_WSGL.LayoutData(replace(NBT_VAL.L_NRE_ENDING_NUMBER,'"','&quot;'));
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits',
                             LOV_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.l_nre_object_reference_listofv');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.Startup
--
-- Description: Entry point for the 'NUMBER_SPLITS' module
--              component  (Number Split Details).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_number_splits$number_split.startup');
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.StoreURLLink(1, 'Number Split Details');


      FormQuery(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.ActionQuery
--
-- Description: Called when a Query form is subitted to action the query request.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure ActionQuery(
             P_L_NRE_OBJECT_REFERENCE in varchar2,
             P_L_NRE2_OBJECT_REFERENCE in varchar2,
             P_PERMISSIVE_DIAL_START_DATE in varchar2,
             U_PERMISSIVE_DIAL_START_DATE in varchar2,
             P_PERMISSIVE_DIAL_END_DATE in varchar2,
             U_PERMISSIVE_DIAL_END_DATE in varchar2,
             P_L_NRE_STARTING_NUMBER in varchar2,
             P_L_NRE_ENDING_NUMBER in varchar2,
             P_L_NRE2_STARTING_NUMBER in varchar2,
             P_L_NRE2_ENDING_NUMBER in varchar2,
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

      if P_L_NRE_OBJECT_REFERENCE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_L_NRE_OBJECT_REFERENCE=' || XNP_WSGL.EscapeURLParam(P_L_NRE_OBJECT_REFERENCE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_L_NRE2_OBJECT_REFERENCE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_L_NRE2_OBJECT_REFERENCE=' || XNP_WSGL.EscapeURLParam(P_L_NRE2_OBJECT_REFERENCE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_PERMISSIVE_DIAL_START_DATE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_PERMISSIVE_DIAL_START_DATE=' || XNP_WSGL.EscapeURLParam(P_PERMISSIVE_DIAL_START_DATE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if U_PERMISSIVE_DIAL_START_DATE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'U_PERMISSIVE_DIAL_START_DATE=' || XNP_WSGL.EscapeURLParam(U_PERMISSIVE_DIAL_START_DATE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_PERMISSIVE_DIAL_END_DATE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_PERMISSIVE_DIAL_END_DATE=' || XNP_WSGL.EscapeURLParam(P_PERMISSIVE_DIAL_END_DATE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if U_PERMISSIVE_DIAL_END_DATE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'U_PERMISSIVE_DIAL_END_DATE=' || XNP_WSGL.EscapeURLParam(U_PERMISSIVE_DIAL_END_DATE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_L_NRE_STARTING_NUMBER is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_L_NRE_STARTING_NUMBER=' || XNP_WSGL.EscapeURLParam(P_L_NRE_STARTING_NUMBER) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_L_NRE_ENDING_NUMBER is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_L_NRE_ENDING_NUMBER=' || XNP_WSGL.EscapeURLParam(P_L_NRE_ENDING_NUMBER) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_L_NRE2_STARTING_NUMBER is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_L_NRE2_STARTING_NUMBER=' || XNP_WSGL.EscapeURLParam(P_L_NRE2_STARTING_NUMBER) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_L_NRE2_ENDING_NUMBER is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_L_NRE2_ENDING_NUMBER=' || XNP_WSGL.EscapeURLParam(P_L_NRE2_ENDING_NUMBER) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      I_PARAM_LIST := I_PARAM_LIST || 'Z_CHK=' || XNP_WSGL.EscapeURLParam(L_CHK) || '&';
      I_PARAM_LIST := I_PARAM_LIST||'Z_ACTION=';

      htp.p('<HTML>
<TITLE>View Number Splits : Number Split Details</TITLE>
<FRAMESET ROWS="100,*,50">
');
      htp.noframesOpen;
      XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_INFORMATION, XNP_WSGL.MsgGetText(229,XNP_WSGLM.MSG229_NO_FRAME_SUPPORT),
                          'View Number Splits'||' : '||'Number Split Details', DEF_BODY_ATTRIBUTES);
      htp.noframesClose;
      htp.p('<FRAME NAME="fraTOP" SRC="xnp_number_splits$number_split.textframe?Z_HEADER=Y&Z_TEXT=Y">
<FRAMESET COLS="40%,60%">
<FRAME NAME="fraRL" SRC="xnp_number_splits$number_split.querylist'||I_PARAM_LIST||L_QRY_LIST_ACTION||'">
<FRAME NAME="fraVF" SRC="xnp_number_splits$number_split.queryfirst'||I_PARAM_LIST||L_QRY_FIRST_ACTION||'">
</FRAMESET>
<FRAME NAME="fraBOTTOM" SRC="xnp_number_splits$number_split.textframe?Z_FOOTER=Y">
</FRAMESET>
</HTML>
');
--if on the query form and insert is allowed

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.ActionQuery');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.TextFrame
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

      XNP_WSGL.OpenPageHead('View Number Splits'||' : '||'Number Split Details',
                        L_ONLY_THING_IN_FRAME);
      xnp_number_splits$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>TF_BODY_ATTRIBUTES);

      if Z_HEADER is not null then
         htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      end if;

      if Z_FIRST is not null then
         xnp_number_splits$.FirstPage(TRUE);
      end if;

      if Z_TEXT is not null then
         htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPNUMSP_DETAILS_TITLE')));
      end if;

      if Z_FOOTER is not null then
         htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));
      end if;

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             TF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.TextFrame');
         XNP_WSGL.ClosePageBody;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.QueryHits
--
-- Description: Returns the number or rows which matches the given search
--              criteria (if any).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function QueryHits(
            P_L_NRE_OBJECT_REFERENCE in varchar2,
            P_L_NRE2_OBJECT_REFERENCE in varchar2,
            P_PERMISSIVE_DIAL_START_DATE in varchar2,
            U_PERMISSIVE_DIAL_START_DATE in varchar2,
            P_PERMISSIVE_DIAL_END_DATE in varchar2,
            U_PERMISSIVE_DIAL_END_DATE in varchar2,
            P_L_NRE_STARTING_NUMBER in varchar2,
            P_L_NRE_ENDING_NUMBER in varchar2,
            P_L_NRE2_STARTING_NUMBER in varchar2,
            P_L_NRE2_ENDING_NUMBER in varchar2) return number is
      I_QUERY     varchar2(2000) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_L_NRE_OBJECT_REFERENCE,
                      P_L_NRE2_OBJECT_REFERENCE,
                      P_PERMISSIVE_DIAL_START_DATE,
                      U_PERMISSIVE_DIAL_START_DATE,
                      P_PERMISSIVE_DIAL_END_DATE,
                      U_PERMISSIVE_DIAL_END_DATE,
                      P_L_NRE_STARTING_NUMBER,
                      P_L_NRE_ENDING_NUMBER,
                      P_L_NRE2_STARTING_NUMBER,
                      P_L_NRE2_ENDING_NUMBER) then
         return -1;
      end if;

      if not PreQuery(P_L_NRE_OBJECT_REFERENCE,
                      P_L_NRE2_OBJECT_REFERENCE,
                      P_PERMISSIVE_DIAL_START_DATE,
                      U_PERMISSIVE_DIAL_START_DATE,
                      P_PERMISSIVE_DIAL_END_DATE,
                      U_PERMISSIVE_DIAL_END_DATE,
                      P_L_NRE_STARTING_NUMBER,
                      P_L_NRE_ENDING_NUMBER,
                      P_L_NRE2_STARTING_NUMBER,
                      P_L_NRE2_ENDING_NUMBER) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'View Number Splits'||' : '||'Number Split Details', DEF_BODY_ATTRIBUTES);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.QueryHits');
         return -1;
   end;--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.BuildSQL
--
-- Description: Builds the SQL for the 'NUMBER_SPLITS' module component (Number Split Details).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_L_NRE_OBJECT_REFERENCE in varchar2,
            P_L_NRE2_OBJECT_REFERENCE in varchar2,
            P_PERMISSIVE_DIAL_START_DATE in varchar2,
            U_PERMISSIVE_DIAL_START_DATE in varchar2,
            P_PERMISSIVE_DIAL_END_DATE in varchar2,
            U_PERMISSIVE_DIAL_END_DATE in varchar2,
            P_L_NRE_STARTING_NUMBER in varchar2,
            P_L_NRE_ENDING_NUMBER in varchar2,
            P_L_NRE2_STARTING_NUMBER in varchar2,
            P_L_NRE2_ENDING_NUMBER in varchar2) return boolean is

      I_WHERE varchar2(2000);
   begin


      -- Build up the Where clause
      I_WHERE := I_WHERE || ' where L_NRE.NUMBER_RANGE_ID = NST.OLD_NUMBER_RANGE_ID';
      I_WHERE := I_WHERE || ' and L_NRE2.NUMBER_RANGE_ID = NST.NEW_NUMBER_RANGE_ID';

      XNP_WSGL.BuildWhere(P_L_NRE_OBJECT_REFERENCE, 'L_NRE.OBJECT_REFERENCE', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(P_L_NRE2_OBJECT_REFERENCE, 'L_NRE2.OBJECT_REFERENCE', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      begin
         XNP_WSGL.BuildWhere(P_PERMISSIVE_DIAL_START_DATE, U_PERMISSIVE_DIAL_START_DATE, 'NST.PERMISSIVE_DIAL_START_DATE', XNP_WSGL.TYPE_DATE, I_WHERE, 'DD-MON-RRRR');
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'View Number Splits'||' : '||'Number Split Details', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Permissive Dialing Start Date'),
                                XNP_WSGL.MsgGetText(211,XNP_WSGLM.MSG211_EXAMPLE_TODAY,to_char(sysdate, 'DD-MON-RRRR')));
            return false;
      end;
      begin
         XNP_WSGL.BuildWhere(P_PERMISSIVE_DIAL_END_DATE, U_PERMISSIVE_DIAL_END_DATE, 'NST.PERMISSIVE_DIAL_END_DATE', XNP_WSGL.TYPE_DATE, I_WHERE, 'DD-MON-RRRR');
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'View Number Splits'||' : '||'Number Split Details', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Permissive Dialing End Date'),
                                XNP_WSGL.MsgGetText(211,XNP_WSGLM.MSG211_EXAMPLE_TODAY,to_char(sysdate, 'DD-MON-RRRR')));
            return false;
      end;
      XNP_WSGL.BuildWhere(P_L_NRE_STARTING_NUMBER, 'L_NRE.STARTING_NUMBER', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(P_L_NRE_ENDING_NUMBER, 'L_NRE.ENDING_NUMBER', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(P_L_NRE2_STARTING_NUMBER, 'L_NRE2.STARTING_NUMBER', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);
      XNP_WSGL.BuildWhere(P_L_NRE2_ENDING_NUMBER, 'L_NRE2.ENDING_NUMBER', XNP_WSGL.TYPE_CHAR_UPPER, I_WHERE);

      ZONE_SQL := 'SELECT NST.NUMBER_SPLIT_ID,
                         L_NRE.OBJECT_REFERENCE,
                         L_NRE2.OBJECT_REFERENCE,
                         NST.PERMISSIVE_DIAL_START_DATE,
                         NST.PERMISSIVE_DIAL_END_DATE
                  FROM   XNP_NUMBER_SPLITS NST,
                         XNP_NUMBER_RANGES L_NRE,
                         XNP_NUMBER_RANGES L_NRE2';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY NST.OLD_NUMBER_RANGE_ID,
                                       L_NRE.OBJECT_REFERENCE,
                                       L_NRE2.OBJECT_REFERENCE,
                                       NST.PERMISSIVE_DIAL_START_DATE Desc ,
                                       NST.PERMISSIVE_DIAL_END_DATE Desc ,
                                       L_NRE.STARTING_NUMBER,
                                       NST.NEW_NUMBER_RANGE_ID,
                                       L_NRE2.STARTING_NUMBER,
                                       L_NRE2.ENDING_NUMBER,
                                       L_NRE.ENDING_NUMBER';
      return true;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.BuildSQL');
         return false;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.FormQuery
--
-- Description: This procedure builds an HTML form for entry of query criteria.
--              The criteria entered are to restrict the query of the 'NUMBER_SPLITS'
--              module component (Number Split Details).
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

      XNP_WSGL.OpenPageHead('View Number Splits'||' : '||'Number Split Details');
      CreateQueryJavaScript;
	  -- Added for iHelp
	  htp.p('<SCRIPT> ');
	  icx_admin_sig.help_win_script('xnpDiag_config', null, 'XNP');
	  htp.p('</SCRIPT>');
	  -- <<
      xnp_number_splits$.TemplateHeader(TRUE,0);
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
      xnp_number_splits$.FirstPage(TRUE);
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPNUMSP_DETAILS_TITLE')));
      htp.para;
      htp.p(XNP_WSGL.MsgGetText(116,XNP_WSGLM.DSP116_ENTER_QRY_CAPTION,'Number Split Details'));
      htp.para;

      htp.formOpen(curl => 'xnp_number_splits$number_split.actionquery', cattributes => 'NAME="frmZero"');

      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..QF_NUMBER_OF_COLUMNS loop
	  XNP_WSGL.LayoutHeader(30, 'LEFT', NULL);
	  XNP_WSGL.LayoutHeader(20, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Initial Range:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('L_NRE_OBJECT_REFERENCE', '20', FALSE) || ' ' ||
                      XNP_WSGJSL.LOVButton('L_NRE_OBJECT_REFERENCE',LOV_BUTTON_TEXT));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('New Range:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('L_NRE2_OBJECT_REFERENCE', '20', FALSE) || ' ' ||
                      XNP_WSGJSL.LOVButton('L_NRE2_OBJECT_REFERENCE',LOV_BUTTON_TEXT));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Permissive Dialing Start Date:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('PERMISSIVE_DIAL_START_DATE', '20', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Permissive Dialing End Date:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('PERMISSIVE_DIAL_END_DATE', '20', TRUE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Initial Range Starting Number:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('L_NRE_STARTING_NUMBER', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Initial Range Ending Number:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('L_NRE_ENDING_NUMBER', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('New Range Starting Number:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('L_NRE2_STARTING_NUMBER', '20', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('New Range Ending Number:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('L_NRE2_ENDING_NUMBER', '20', FALSE));
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             QF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.FormQuery');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.FormView
--
-- Description: This procedure builds an HTML form for view/update of fields in
--              the 'NUMBER_SPLITS' module component (Number Split Details).
--
-- Parameters:  Z_FORM_STATUS  Status of the form
--
--------------------------------------------------------------------------------
   procedure FormView(Z_FORM_STATUS in number) is


    begin

      XNP_WSGL.OpenPageHead('View Number Splits'||' : '||'Number Split Details');
      xnp_number_splits$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>VF_BODY_ATTRIBUTES);




      FORM_VAL.NUMBER_SPLIT_ID := CURR_VAL.NUMBER_SPLIT_ID;
      FORM_VAL.NEW_NUMBER_RANGE_ID := CURR_VAL.NEW_NUMBER_RANGE_ID;
      FORM_VAL.OLD_NUMBER_RANGE_ID := CURR_VAL.OLD_NUMBER_RANGE_ID;
      FORM_VAL.L_NRE_OBJECT_REFERENCE := NBT_VAL.L_NRE_OBJECT_REFERENCE;
      FORM_VAL.L_NRE2_OBJECT_REFERENCE := NBT_VAL.L_NRE2_OBJECT_REFERENCE;
      FORM_VAL.PERMISSIVE_DIAL_START_DATE := ltrim(to_char(CURR_VAL.PERMISSIVE_DIAL_START_DATE, 'DD-MON-RRRR'));
      FORM_VAL.PERMISSIVE_DIAL_END_DATE := ltrim(to_char(CURR_VAL.PERMISSIVE_DIAL_END_DATE, 'DD-MON-RRRR'));
      FORM_VAL.L_NRE_STARTING_NUMBER := NBT_VAL.L_NRE_STARTING_NUMBER;
      FORM_VAL.L_NRE_ENDING_NUMBER := NBT_VAL.L_NRE_ENDING_NUMBER;
      FORM_VAL.L_NRE2_STARTING_NUMBER := NBT_VAL.L_NRE2_STARTING_NUMBER;
      FORM_VAL.L_NRE2_ENDING_NUMBER := NBT_VAL.L_NRE2_ENDING_NUMBER;
      FORM_VAL.CONVERSION_PROCEDURE := CURR_VAL.CONVERSION_PROCEDURE;

      if Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_ERROR then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'View Number Splits'||' : '||'Number Split Details', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_UPD then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(207, XNP_WSGLM.MSG207_ROW_UPDATED),
                             'View Number Splits'||' : '||'Number Split Details', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_INS then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(208, XNP_WSGLM.MSG208_ROW_INSERTED),
                             'View Number Splits'||' : '||'Number Split Details', VF_BODY_ATTRIBUTES);
      end if;


      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE, P_BORDER=>TRUE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..VF_NUMBER_OF_COLUMNS loop
         XNP_WSGL.LayoutHeader(30, 'LEFT', NULL);
         XNP_WSGL.LayoutHeader(40, 'LEFT', NULL);
      end loop;
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Initial Range:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.L_NRE_OBJECT_REFERENCE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('New Range:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.L_NRE2_OBJECT_REFERENCE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Permissive Dialing Start Date:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.PERMISSIVE_DIAL_START_DATE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Permissive Dialing End Date:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.PERMISSIVE_DIAL_END_DATE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Initial Range Starting Number:'));
      XNP_WSGL.LayoutData(FORM_VAL.L_NRE_STARTING_NUMBER);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Initial Range Ending Number:'));
      XNP_WSGL.LayoutData(FORM_VAL.L_NRE_ENDING_NUMBER);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('New Range Starting Number:'));
      XNP_WSGL.LayoutData(FORM_VAL.L_NRE2_STARTING_NUMBER);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('New Range Ending Number:'));
      XNP_WSGL.LayoutData(FORM_VAL.L_NRE2_ENDING_NUMBER);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Conversion Procedure:'));
      XNP_WSGL.LayoutData(replace(FORM_VAL.CONVERSION_PROCEDURE, '
', '<BR>
'));
      XNP_WSGL.LayoutRowEnd;

      XNP_WSGL.LayoutClose;








      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             VF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.FormView');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.QueryView
--
-- Description: Queries the details of a single row in preparation for display.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryView(
             P_NUMBER_SPLIT_ID in varchar2,
             Z_POST_DML in boolean,
             Z_FORM_STATUS in number,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_number_splits$number_split.queryview');
      XNP_WSGL.AddURLParam('P_NUMBER_SPLIT_ID', P_NUMBER_SPLIT_ID);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('' ||
                                      P_NUMBER_SPLIT_ID, Z_CHK) then
            return;
         end if;
      end if;


      if P_NUMBER_SPLIT_ID is not null then
         CURR_VAL.NUMBER_SPLIT_ID := P_NUMBER_SPLIT_ID;
      end if;
      if Z_POST_DML then

         SELECT L_NRE.OBJECT_REFERENCE,
                L_NRE2.OBJECT_REFERENCE,
                L_NRE.STARTING_NUMBER,
                L_NRE.ENDING_NUMBER,
                L_NRE2.STARTING_NUMBER,
                L_NRE2.ENDING_NUMBER
         INTO   NBT_VAL.L_NRE_OBJECT_REFERENCE,
                NBT_VAL.L_NRE2_OBJECT_REFERENCE,
                NBT_VAL.L_NRE_STARTING_NUMBER,
                NBT_VAL.L_NRE_ENDING_NUMBER,
                NBT_VAL.L_NRE2_STARTING_NUMBER,
                NBT_VAL.L_NRE2_ENDING_NUMBER
         FROM   XNP_NUMBER_SPLITS NST,
                XNP_NUMBER_RANGES L_NRE,
                XNP_NUMBER_RANGES L_NRE2
         WHERE  NST.NUMBER_SPLIT_ID = CURR_VAL.NUMBER_SPLIT_ID
         AND    L_NRE.NUMBER_RANGE_ID = NST.OLD_NUMBER_RANGE_ID
         AND    L_NRE2.NUMBER_RANGE_ID = NST.NEW_NUMBER_RANGE_ID
         ;

      else

         SELECT NST.NUMBER_SPLIT_ID,
                NST.NEW_NUMBER_RANGE_ID,
                NST.OLD_NUMBER_RANGE_ID,
                L_NRE.OBJECT_REFERENCE,
                L_NRE2.OBJECT_REFERENCE,
                NST.PERMISSIVE_DIAL_START_DATE,
                NST.PERMISSIVE_DIAL_END_DATE,
                L_NRE.STARTING_NUMBER,
                L_NRE.ENDING_NUMBER,
                L_NRE2.STARTING_NUMBER,
                L_NRE2.ENDING_NUMBER,
                NST.CONVERSION_PROCEDURE
         INTO   CURR_VAL.NUMBER_SPLIT_ID,
                CURR_VAL.NEW_NUMBER_RANGE_ID,
                CURR_VAL.OLD_NUMBER_RANGE_ID,
                NBT_VAL.L_NRE_OBJECT_REFERENCE,
                NBT_VAL.L_NRE2_OBJECT_REFERENCE,
                CURR_VAL.PERMISSIVE_DIAL_START_DATE,
                CURR_VAL.PERMISSIVE_DIAL_END_DATE,
                NBT_VAL.L_NRE_STARTING_NUMBER,
                NBT_VAL.L_NRE_ENDING_NUMBER,
                NBT_VAL.L_NRE2_STARTING_NUMBER,
                NBT_VAL.L_NRE2_ENDING_NUMBER,
                CURR_VAL.CONVERSION_PROCEDURE
         FROM   XNP_NUMBER_SPLITS NST,
                XNP_NUMBER_RANGES L_NRE,
                XNP_NUMBER_RANGES L_NRE2
         WHERE  NST.NUMBER_SPLIT_ID = CURR_VAL.NUMBER_SPLIT_ID
         AND    L_NRE.NUMBER_RANGE_ID = NST.OLD_NUMBER_RANGE_ID
         AND    L_NRE2.NUMBER_RANGE_ID = NST.NEW_NUMBER_RANGE_ID
         ;

      end if;

      if not PostQuery(Z_POST_DML) then
         FormView(XNP_WSGL.FORM_STATUS_ERROR);
      else
         FormView(Z_FORM_STATUS);
      end if;

   exception
      when NO_DATA_FOUND then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_WSGL.MsgGetText(204, XNP_WSGLM.MSG204_ROW_DELETED),
                             'View Number Splits'||' : '||'Number Split Details', VF_BODY_ATTRIBUTES);
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             VF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.QueryView');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.QueryList
--
-- Description: This procedure builds the Record list for the 'NUMBER_SPLITS'
--              module component (Number Split Details).
--
--              The Record List displays context information for records which
--              match the specified query criteria.
--              Sets of records are displayed (10 records at a time)
--              with Next/Previous buttons to get other record sets.
--
--              The first context column will be created as a link to the
--              xnp_number_splits$number_split.FormView procedure for display of more details
--              of that particular row.
--
-- Parameters:  P_L_NRE_OBJECT_REFERENCE - Initial Range
--              P_L_NRE2_OBJECT_REFERENCE - New Range
--              P_PERMISSIVE_DIAL_START_DATE - Permissive Dialing Start Date
--              U_PERMISSIVE_DIAL_START_DATE - Permissive Dialing Start Date (upper bound)
--              P_PERMISSIVE_DIAL_END_DATE - Permissive Dialing End Date
--              U_PERMISSIVE_DIAL_END_DATE - Permissive Dialing End Date (upper bound)
--              P_L_NRE_STARTING_NUMBER - Initial Range Starting Number
--              P_L_NRE_ENDING_NUMBER - Initial Range Ending Number
--              P_L_NRE2_STARTING_NUMBER - New Range Starting Number
--              P_L_NRE2_ENDING_NUMBER - New Range Ending Number
--              Z_START - First record to display
--              Z_ACTION - Next or Previous set
--
--------------------------------------------------------------------------------
   procedure QueryList(
             P_L_NRE_OBJECT_REFERENCE in varchar2,
             P_L_NRE2_OBJECT_REFERENCE in varchar2,
             P_PERMISSIVE_DIAL_START_DATE in varchar2,
             U_PERMISSIVE_DIAL_START_DATE in varchar2,
             P_PERMISSIVE_DIAL_END_DATE in varchar2,
             U_PERMISSIVE_DIAL_END_DATE in varchar2,
             P_L_NRE_STARTING_NUMBER in varchar2,
             P_L_NRE_ENDING_NUMBER in varchar2,
             P_L_NRE2_STARTING_NUMBER in varchar2,
             P_L_NRE2_ENDING_NUMBER in varchar2,
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
      L_CHECKSUM          varchar2(10);

   begin

      XNP_WSGL.RegisterURL('xnp_number_splits$number_split.querylist');
      XNP_WSGL.AddURLParam('P_L_NRE_OBJECT_REFERENCE', P_L_NRE_OBJECT_REFERENCE);
      XNP_WSGL.AddURLParam('P_L_NRE2_OBJECT_REFERENCE', P_L_NRE2_OBJECT_REFERENCE);
      XNP_WSGL.AddURLParam('P_PERMISSIVE_DIAL_START_DATE', P_PERMISSIVE_DIAL_START_DATE);
      XNP_WSGL.AddURLParam('U_PERMISSIVE_DIAL_START_DATE', U_PERMISSIVE_DIAL_START_DATE);
      XNP_WSGL.AddURLParam('P_PERMISSIVE_DIAL_END_DATE', P_PERMISSIVE_DIAL_END_DATE);
      XNP_WSGL.AddURLParam('U_PERMISSIVE_DIAL_END_DATE', U_PERMISSIVE_DIAL_END_DATE);
      XNP_WSGL.AddURLParam('P_L_NRE_STARTING_NUMBER', P_L_NRE_STARTING_NUMBER);
      XNP_WSGL.AddURLParam('P_L_NRE_ENDING_NUMBER', P_L_NRE_ENDING_NUMBER);
      XNP_WSGL.AddURLParam('P_L_NRE2_STARTING_NUMBER', P_L_NRE2_STARTING_NUMBER);
      XNP_WSGL.AddURLParam('P_L_NRE2_ENDING_NUMBER', P_L_NRE2_ENDING_NUMBER);
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

      XNP_WSGL.OpenPageHead('View Number Splits'||' : '||'Number Split Details');
      CreateListJavaScript;
      xnp_number_splits$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>RL_BODY_ATTRIBUTES);

      if (Z_ACTION = RL_LAST_BUT_ACTION) or (Z_ACTION = RL_LAST_BUT_CAPTION) or
         (Z_ACTION = RL_COUNT_BUT_ACTION) or (Z_ACTION = RL_COUNT_BUT_CAPTION) or
         (RL_TOTAL_COUNT_REQD)
      then

         I_COUNT := QueryHits(
                    P_L_NRE_OBJECT_REFERENCE,
                    P_L_NRE2_OBJECT_REFERENCE,
                    P_PERMISSIVE_DIAL_START_DATE,
                    U_PERMISSIVE_DIAL_START_DATE,
                    P_PERMISSIVE_DIAL_END_DATE,
                    U_PERMISSIVE_DIAL_END_DATE,
                    P_L_NRE_STARTING_NUMBER,
                    P_L_NRE_ENDING_NUMBER,
                    P_L_NRE2_STARTING_NUMBER,
                    P_L_NRE2_ENDING_NUMBER);
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
                             'View Number Splits'||' : '||'Number Split Details', RL_BODY_ATTRIBUTES);
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
                       P_L_NRE_OBJECT_REFERENCE,
                       P_L_NRE2_OBJECT_REFERENCE,
                       P_PERMISSIVE_DIAL_START_DATE,
                       U_PERMISSIVE_DIAL_START_DATE,
                       P_PERMISSIVE_DIAL_END_DATE,
                       U_PERMISSIVE_DIAL_END_DATE,
                       P_L_NRE_STARTING_NUMBER,
                       P_L_NRE_ENDING_NUMBER,
                       P_L_NRE2_STARTING_NUMBER,
                       P_L_NRE2_ENDING_NUMBER) then
               XNP_WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if not PreQuery(
                       P_L_NRE_OBJECT_REFERENCE,
                       P_L_NRE2_OBJECT_REFERENCE,
                       P_PERMISSIVE_DIAL_START_DATE,
                       U_PERMISSIVE_DIAL_START_DATE,
                       P_PERMISSIVE_DIAL_END_DATE,
                       U_PERMISSIVE_DIAL_END_DATE,
                       P_L_NRE_STARTING_NUMBER,
                       P_L_NRE_ENDING_NUMBER,
                       P_L_NRE2_STARTING_NUMBER,
                       P_L_NRE2_ENDING_NUMBER) then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                                'View Number Splits'||' : '||'Number Split Details', RL_BODY_ATTRIBUTES);
         return;
         end if;



         I_CURSOR := dbms_sql.open_cursor;
         dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
         dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.NUMBER_SPLIT_ID);
         dbms_sql.define_column(I_CURSOR, 2, NBT_VAL.L_NRE_OBJECT_REFERENCE, 80);
         dbms_sql.define_column(I_CURSOR, 3, NBT_VAL.L_NRE2_OBJECT_REFERENCE, 80);
         dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.PERMISSIVE_DIAL_START_DATE);
         dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.PERMISSIVE_DIAL_END_DATE);

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
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Initial Range');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'New Range');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Permissive Dialing Start Date');
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Permissive Dialing End Date');
         end loop;
         XNP_WSGL.LayoutRowEnd;

         while I_ROWS_FETCHED <> 0 loop

            if I_TOTAL_ROWS >= I_START then
               dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.NUMBER_SPLIT_ID);
               dbms_sql.column_value(I_CURSOR, 2, NBT_VAL.L_NRE_OBJECT_REFERENCE);
               dbms_sql.column_value(I_CURSOR, 3, NBT_VAL.L_NRE2_OBJECT_REFERENCE);
               dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.PERMISSIVE_DIAL_START_DATE);
               dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.PERMISSIVE_DIAL_END_DATE);
               L_CHECKSUM := to_char(XNP_WSGL.Checksum(''||CURR_VAL.NUMBER_SPLIT_ID));


               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData(htf.anchor2('xnp_number_splits$number_split.queryview?P_NUMBER_SPLIT_ID='||CURR_VAL.NUMBER_SPLIT_ID||'&Z_CHK='||L_CHECKSUM, NBT_VAL.L_NRE_OBJECT_REFERENCE, ctarget=>L_VF_FRAME));
               XNP_WSGL.LayoutData(NBT_VAL.L_NRE2_OBJECT_REFERENCE);
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.PERMISSIVE_DIAL_START_DATE, 'DD-MON-RRRR')));
               XNP_WSGL.LayoutData(ltrim(to_char(CURR_VAL.PERMISSIVE_DIAL_END_DATE, 'DD-MON-RRRR')));
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

      htp.formOpen(curl => 'xnp_number_splits$number_split.querylist', cattributes => 'NAME="frmZero"');
      XNP_WSGL.HiddenField('P_L_NRE_OBJECT_REFERENCE', P_L_NRE_OBJECT_REFERENCE);
      XNP_WSGL.HiddenField('P_L_NRE2_OBJECT_REFERENCE', P_L_NRE2_OBJECT_REFERENCE);
      XNP_WSGL.HiddenField('P_PERMISSIVE_DIAL_START_DATE', P_PERMISSIVE_DIAL_START_DATE);
      XNP_WSGL.HiddenField('U_PERMISSIVE_DIAL_START_DATE', U_PERMISSIVE_DIAL_START_DATE);
      XNP_WSGL.HiddenField('P_PERMISSIVE_DIAL_END_DATE', P_PERMISSIVE_DIAL_END_DATE);
      XNP_WSGL.HiddenField('U_PERMISSIVE_DIAL_END_DATE', U_PERMISSIVE_DIAL_END_DATE);
      XNP_WSGL.HiddenField('P_L_NRE_STARTING_NUMBER', P_L_NRE_STARTING_NUMBER);
      XNP_WSGL.HiddenField('P_L_NRE_ENDING_NUMBER', P_L_NRE_ENDING_NUMBER);
      XNP_WSGL.HiddenField('P_L_NRE2_STARTING_NUMBER', P_L_NRE2_STARTING_NUMBER);
      XNP_WSGL.HiddenField('P_L_NRE2_ENDING_NUMBER', P_L_NRE2_ENDING_NUMBER);
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

      htp.formOpen(curl => 'xnp_number_splits$number_split.querylist', ctarget=>'_top', cattributes => 'NAME="frmOne"');
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             RL_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.QueryList');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.QueryFirst
--
-- Description: Finds the first row which matches the given search criteria
--              (if any), and calls QueryView for that row
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryFirst(
             P_L_NRE_OBJECT_REFERENCE in varchar2,
             P_L_NRE2_OBJECT_REFERENCE in varchar2,
             P_PERMISSIVE_DIAL_START_DATE in varchar2,
             U_PERMISSIVE_DIAL_START_DATE in varchar2,
             P_PERMISSIVE_DIAL_END_DATE in varchar2,
             U_PERMISSIVE_DIAL_END_DATE in varchar2,
             P_L_NRE_STARTING_NUMBER in varchar2,
             P_L_NRE_ENDING_NUMBER in varchar2,
             P_L_NRE2_STARTING_NUMBER in varchar2,
             P_L_NRE2_ENDING_NUMBER in varchar2,
             Z_ACTION in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is

      I_CURSOR            integer;
      I_VOID              integer;
      I_ROWS_FETCHED      integer := 0;

   begin

      XNP_WSGL.RegisterURL('xnp_number_splits$number_split.queryfirst');
      XNP_WSGL.AddURLParam('P_L_NRE_OBJECT_REFERENCE', P_L_NRE_OBJECT_REFERENCE);
      XNP_WSGL.AddURLParam('P_L_NRE2_OBJECT_REFERENCE', P_L_NRE2_OBJECT_REFERENCE);
      XNP_WSGL.AddURLParam('P_PERMISSIVE_DIAL_START_DATE', P_PERMISSIVE_DIAL_START_DATE);
      XNP_WSGL.AddURLParam('U_PERMISSIVE_DIAL_START_DATE', U_PERMISSIVE_DIAL_START_DATE);
      XNP_WSGL.AddURLParam('P_PERMISSIVE_DIAL_END_DATE', P_PERMISSIVE_DIAL_END_DATE);
      XNP_WSGL.AddURLParam('U_PERMISSIVE_DIAL_END_DATE', U_PERMISSIVE_DIAL_END_DATE);
      XNP_WSGL.AddURLParam('P_L_NRE_STARTING_NUMBER', P_L_NRE_STARTING_NUMBER);
      XNP_WSGL.AddURLParam('P_L_NRE_ENDING_NUMBER', P_L_NRE_ENDING_NUMBER);
      XNP_WSGL.AddURLParam('P_L_NRE2_STARTING_NUMBER', P_L_NRE2_STARTING_NUMBER);
      XNP_WSGL.AddURLParam('P_L_NRE2_ENDING_NUMBER', P_L_NRE2_ENDING_NUMBER);
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
                    P_L_NRE_OBJECT_REFERENCE,
                    P_L_NRE2_OBJECT_REFERENCE,
                    P_PERMISSIVE_DIAL_START_DATE,
                    U_PERMISSIVE_DIAL_START_DATE,
                    P_PERMISSIVE_DIAL_END_DATE,
                    U_PERMISSIVE_DIAL_END_DATE,
                    P_L_NRE_STARTING_NUMBER,
                    P_L_NRE_ENDING_NUMBER,
                    P_L_NRE2_STARTING_NUMBER,
                    P_L_NRE2_ENDING_NUMBER) then
         return;
      end if;

      if not PreQuery(
                    P_L_NRE_OBJECT_REFERENCE,
                    P_L_NRE2_OBJECT_REFERENCE,
                    P_PERMISSIVE_DIAL_START_DATE,
                    U_PERMISSIVE_DIAL_START_DATE,
                    P_PERMISSIVE_DIAL_END_DATE,
                    U_PERMISSIVE_DIAL_END_DATE,
                    P_L_NRE_STARTING_NUMBER,
                    P_L_NRE_ENDING_NUMBER,
                    P_L_NRE2_STARTING_NUMBER,
                    P_L_NRE2_ENDING_NUMBER) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'View Number Splits'||' : '||'Number Split Details', VF_BODY_ATTRIBUTES);
         return;
      end if;

      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.NUMBER_SPLIT_ID);
      dbms_sql.define_column(I_CURSOR, 2, NBT_VAL.L_NRE_OBJECT_REFERENCE, 80);
      dbms_sql.define_column(I_CURSOR, 3, NBT_VAL.L_NRE2_OBJECT_REFERENCE, 80);
      dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.PERMISSIVE_DIAL_START_DATE);
      dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.PERMISSIVE_DIAL_END_DATE);

      I_VOID := dbms_sql.execute(I_CURSOR);

      I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);

      if I_ROWS_FETCHED = 0 then
         XNP_WSGL.EmptyPage(VF_BODY_ATTRIBUTES);
      else
         dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.NUMBER_SPLIT_ID);
         dbms_sql.column_value(I_CURSOR, 2, NBT_VAL.L_NRE_OBJECT_REFERENCE);
         dbms_sql.column_value(I_CURSOR, 3, NBT_VAL.L_NRE2_OBJECT_REFERENCE);
         dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.PERMISSIVE_DIAL_START_DATE);
         dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.PERMISSIVE_DIAL_END_DATE);
         xnp_number_splits$number_split.QueryView(Z_DIRECT_CALL=>TRUE);
      end if;

      dbms_sql.close_cursor(I_CURSOR);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             VF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.QueryFirst');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'NUMBER_SPLITS' module component  (Number Split Details).
--
-- Parameters:  None
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PreQuery(
            P_L_NRE_OBJECT_REFERENCE in varchar2,
            P_L_NRE2_OBJECT_REFERENCE in varchar2,
            P_PERMISSIVE_DIAL_START_DATE in varchar2,
            U_PERMISSIVE_DIAL_START_DATE in varchar2,
            P_PERMISSIVE_DIAL_END_DATE in varchar2,
            U_PERMISSIVE_DIAL_END_DATE in varchar2,
            P_L_NRE_STARTING_NUMBER in varchar2,
            P_L_NRE_ENDING_NUMBER in varchar2,
            P_L_NRE2_STARTING_NUMBER in varchar2,
            P_L_NRE2_ENDING_NUMBER in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'NUMBER_SPLITS' module component  (Number Split Details).
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             DEF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.PostQuery');
          return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.CreateQueryJavaScript
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
'function L_NRE_OBJECT_REFERENCE_LOV() {
   var filter = "";
   var the_pathname = location.pathname;
   var i            = the_pathname.indexOf (''/:'');
   var j            = the_pathname.indexOf (''/'', ++i);

   if (i != -1)
   {

     // Syntactically incorrect url so it needs to be corrected

     the_pathname = the_pathname.substring (j, the_pathname.length);

   }; // (i != -1)

   frmLOV = open("xnp_number_splits$number_split.l_nre_object_reference_listofv" +
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
'function L_NRE2_OBJECT_REFERENCE_LOV() {
   var filter = "";
   var the_pathname = location.pathname;
   var i            = the_pathname.indexOf (''/:'');
   var j            = the_pathname.indexOf (''/'', ++i);

   if (i != -1)
   {

     // Syntactically incorrect url so it needs to be corrected

     the_pathname = the_pathname.substring (j, the_pathname.length);

   }; // (i != -1)

   frmLOV = open("xnp_number_splits$number_split.l_nre2_object_reference_listof" +
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             QF_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.CreateQueryJavaScript');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_number_splits$number_split.CreateListJavaScript
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'View Number Splits'||' : '||'Number Split Details',
                             RL_BODY_ATTRIBUTES, 'xnp_number_splits$number_split.CreateListJavaScript');
   end;
end;

/
