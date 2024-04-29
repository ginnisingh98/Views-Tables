--------------------------------------------------------
--  DDL for Package Body XNP_SV_NETWORK$SMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_SV_NETWORK$SMS_SV" as
/* $Header: XNPSVN2B.pls 120.0 2005/05/30 11:52:10 appldev noship $ */


   procedure FormView(Z_FORM_STATUS in number);
   function BuildSQL(
            P_PORTING_ID in varchar2 default null,
            P_SUBSCRIPTION_TYPE in varchar2 default null,
            P_SUBSCRIPTION_TN in varchar2 default null,
            P_NRC_CODE in varchar2 default null,
            P_REC_CODE in varchar2 default null) return boolean;
   function PreQuery(
            P_PORTING_ID in varchar2 default null,
            P_SUBSCRIPTION_TYPE in varchar2 default null,
            P_SUBSCRIPTION_TN in varchar2 default null,
            P_NRC_CODE in varchar2 default null,
            P_REC_CODE in varchar2 default null) return boolean;
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

   CURR_VAL XNP_SV_SMS_V%ROWTYPE;

   TYPE FORM_REC IS RECORD
        (SV_SMS_ID           VARCHAR2(8)
        ,PORTING_ID          VARCHAR2(80)
        ,ROUTING_NUMBER_ID   VARCHAR2(8)
        ,SUBSCRIPTION_TYPE   VARCHAR2(30)
        ,SUBSCRIPTION_TN     VARCHAR2(20)
        ,MEDIATOR_SP_ID      VARCHAR2(8)
        ,ROUTING_NUMBER      VARCHAR2(20)
        ,PROVISION_SENT_DATE VARCHAR2(23)
        ,CNAM_ADDRESS        VARCHAR2(80)
        ,CNAM_SUBSYSTEM      VARCHAR2(80)
        ,ISVM_ADDRESS        VARCHAR2(80)
        ,ISVM_SUBSYSTEM      VARCHAR2(80)
        ,LIDB_ADDRESS        VARCHAR2(80)
        ,LIDB_SUBSYSTEM      VARCHAR2(80)
        ,CLASS_ADDRESS       VARCHAR2(80)
        ,CLASS_SUBSYSTEM     VARCHAR2(80)
        ,WSMSC_ADDRESS       VARCHAR2(80)
        ,WSMSC_SUBSYSTEM     VARCHAR2(80)
        ,RN_ADDRESS          VARCHAR2(80)
        ,RN_SUBSYSTEM        VARCHAR2(80)
        ,PROVISION_DONE_DATE VARCHAR2(23)
        ,NRC_CODE            VARCHAR2(20)
        ,NRC_NAME            VARCHAR2(80)
        ,NRC_INTERNET        VARCHAR2(40)
        ,ROUTING_REF         VARCHAR2(80)
        ,ROUTING_SP_ID       VARCHAR2(8)
        ,REC_SP_ID           VARCHAR2(80)
        ,REC_CODE            VARCHAR2(20)
        ,REC_NAME            VARCHAR2(80)
        ,REC_INTERNET        VARCHAR2(40)
        ,DSP_REC             VARCHAR2(2000)
        ,REC_EMAIL           VARCHAR2(80)
        ,DSP_NRC             VARCHAR2(2000)
        ,NRC_EMAIL           VARCHAR2(80)
        ,INTERCONNECT_TYPE   VARCHAR2(30)
        ,DSP_CNAM            VARCHAR2(2000)
        ,DSP_CLASS           VARCHAR2(2000)
        ,DSP_ISVM            VARCHAR2(2000)
        ,DSP_LIDB            VARCHAR2(2000)
        ,DSP_WSMSC           VARCHAR2(2000)
        ,DSP_RN              VARCHAR2(2000)
        );
   FORM_VAL   FORM_REC;

   TYPE NBT_REC IS RECORD
        (DSP_REC             VARCHAR2(2000)
        ,DSP_NRC             VARCHAR2(2000)
        ,DSP_CNAM            VARCHAR2(2000)
        ,DSP_CLASS           VARCHAR2(2000)
        ,DSP_ISVM            VARCHAR2(2000)
        ,DSP_LIDB            VARCHAR2(2000)
        ,DSP_WSMSC           VARCHAR2(2000)
        ,DSP_RN              VARCHAR2(2000)
        );
   NBT_VAL    NBT_REC;

   ZONE_SQL   VARCHAR2(4800) := null;

   D_SUBSCRIPTION_TYPE   XNP_WSGL.typDVRecord;
   D_INTERCONNECT_TYPE   XNP_WSGL.typDVRecord;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.InitialiseDomain
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

      if P_ALIAS = 'INTERCONNECT_TYPE' and not D_INTERCONNECT_TYPE.Initialised then
         D_INTERCONNECT_TYPE.ColAlias := 'INTERCONNECT_TYPE';
         D_INTERCONNECT_TYPE.ControlType := XNP_WSGL.DV_TEXT;
         D_INTERCONNECT_TYPE.DispWidth := 30;
         D_INTERCONNECT_TYPE.DispHeight := 1;
         D_INTERCONNECT_TYPE.MaxWidth := 30;
         D_INTERCONNECT_TYPE.UseMeanings := True;
         D_INTERCONNECT_TYPE.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_INTERCONNECT_TYPE', D_INTERCONNECT_TYPE);
         D_INTERCONNECT_TYPE.Initialised := True;
      end if;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.InitialseDomain');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.Startup
--
-- Description: Entry point for the 'SMS_SV' module
--              component  (Porting Network Subscriptions).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_sv_network$sms_sv.startup');
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('', Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.StoreURLLink(1, 'Porting Network Subscriptions');


      FormQuery(
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.ActionQuery
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
             P_NRC_CODE in varchar2,
             P_REC_CODE in varchar2,
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
      if P_NRC_CODE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_NRC_CODE=' || XNP_WSGL.EscapeURLParam(P_NRC_CODE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      if P_REC_CODE is not null then
         I_PARAM_LIST := I_PARAM_LIST || 'P_REC_CODE=' || XNP_WSGL.EscapeURLParam(P_REC_CODE) || '&';
         L_QRY_FIRST_ACTION := 'BLANKIFNONE';
      end if;
      I_PARAM_LIST := I_PARAM_LIST || 'Z_CHK=' || XNP_WSGL.EscapeURLParam(L_CHK) || '&';
      I_PARAM_LIST := I_PARAM_LIST||'Z_ACTION=';

      htp.p('<HTML>
<TITLE>Monitor Network Subscriptions : Porting Network Subscriptions</TITLE>
<FRAMESET ROWS="100,*,50">
');
      htp.noframesOpen;
      XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_INFORMATION, XNP_WSGL.MsgGetText(229,XNP_WSGLM.MSG229_NO_FRAME_SUPPORT),
                          'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', DEF_BODY_ATTRIBUTES);
      htp.noframesClose;
      htp.p('<FRAME NAME="fraTOP" SRC="xnp_sv_network$sms_sv.textframe?Z_HEADER=Y&Z_TEXT=Y">
<FRAMESET COLS="30%,70%">
<FRAME NAME="fraRL" SRC="xnp_sv_network$sms_sv.querylist'||I_PARAM_LIST||L_QRY_LIST_ACTION||'">
<FRAME NAME="fraVF" SRC="xnp_sv_network$sms_sv.queryfirst'||I_PARAM_LIST||L_QRY_FIRST_ACTION||'">
</FRAMESET>
<FRAME NAME="fraBOTTOM" SRC="xnp_sv_network$sms_sv.textframe?Z_FOOTER=Y">
</FRAMESET>
</HTML>
');
--if on the query form and insert is allowed

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.ActionQuery');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.TextFrame
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

      XNP_WSGL.OpenPageHead('Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                        L_ONLY_THING_IN_FRAME);
      xnp_sv_network$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>TF_BODY_ATTRIBUTES);

      if Z_HEADER is not null then
         htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      end if;

      if Z_FIRST is not null then
         xnp_sv_network$.FirstPage(TRUE);
      end if;

      if Z_TEXT is not null then
         htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPSVNWK_DETAILS_TITLE')));
      end if;

      if Z_FOOTER is not null then
         htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));
      end if;

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             TF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.TextFrame');
         XNP_WSGL.ClosePageBody;
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.QueryHits
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
            P_NRC_CODE in varchar2,
            P_REC_CODE in varchar2) return number is
      I_QUERY     varchar2(2000) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_PORTING_ID,
                      P_SUBSCRIPTION_TYPE,
                      P_SUBSCRIPTION_TN,
                      P_NRC_CODE,
                      P_REC_CODE) then
         return -1;
      end if;

      if not PreQuery(P_PORTING_ID,
                      P_SUBSCRIPTION_TYPE,
                      P_SUBSCRIPTION_TN,
                      P_NRC_CODE,
                      P_REC_CODE) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', DEF_BODY_ATTRIBUTES);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.QueryHits');
         return -1;
   end;--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.BuildSQL
--
-- Description: Builds the SQL for the 'SMS_SV' module component (Porting Network Subscriptions).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_PORTING_ID in varchar2,
            P_SUBSCRIPTION_TYPE in varchar2,
            P_SUBSCRIPTION_TN in varchar2,
            P_NRC_CODE in varchar2,
            P_REC_CODE in varchar2) return boolean is

      I_WHERE varchar2(2000);
   begin

      InitialiseDomain('SUBSCRIPTION_TYPE');

      -- Build up the Where clause

      XNP_WSGL.BuildWhere(P_PORTING_ID, 'XNP_SV_SMS_V.PORTING_ID', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(XNP_WSGL.DomainValue(D_SUBSCRIPTION_TYPE, P_SUBSCRIPTION_TYPE), 'XNP_SV_SMS_V.SUBSCRIPTION_TYPE', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_SUBSCRIPTION_TN, 'XNP_SV_SMS_V.SUBSCRIPTION_TN', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_NRC_CODE, 'XNP_SV_SMS_V.NRC_CODE', XNP_WSGL.TYPE_CHAR, I_WHERE);
      XNP_WSGL.BuildWhere(P_REC_CODE, 'XNP_SV_SMS_V.REC_CODE', XNP_WSGL.TYPE_CHAR, I_WHERE);

      ZONE_SQL := 'SELECT XNP_SV_SMS_V.SV_SMS_ID,
                         XNP_SV_SMS_V.PORTING_ID,
                         XNP_SV_SMS_V.SUBSCRIPTION_TN,
                         XNP_SV_SMS_V.ROUTING_NUMBER
                  FROM   XNP_SV_SMS_V XNP_SV_SMS_V';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY XNP_SV_SMS_V.PORTING_ID Desc ';
      return true;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.BuildSQL');
         return false;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.FormQuery
--
-- Description: This procedure builds an HTML form for entry of query criteria.
--              The criteria entered are to restrict the query of the 'SMS_SV'
--              module component (Porting Network Subscriptions).
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

      XNP_WSGL.OpenPageHead('Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions');
      CreateQueryJavaScript;
      xnp_sv_network$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>QF_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      xnp_sv_network$.FirstPage(TRUE);
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPSVNWK_DETAILS_TITLE')));
      htp.para;
      htp.p(XNP_WSGL.MsgGetText(116,XNP_WSGLM.DSP116_ENTER_QRY_CAPTION,'Porting Network Subscriptions'));
      htp.para;

      htp.formOpen(curl => 'xnp_sv_network$sms_sv.actionquery', cattributes => 'NAME="frmZero"');

      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..QF_NUMBER_OF_COLUMNS loop
	  XNP_WSGL.LayoutHeader(18, 'LEFT', NULL);
	  XNP_WSGL.LayoutHeader(30, 'LEFT', NULL);
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
      XNP_WSGL.LayoutData(htf.bold('NRC Code:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('NRC_CODE', '10', FALSE));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Rec Code:'));
      XNP_WSGL.LayoutData(XNP_WSGL.BuildQueryControl('REC_CODE', '20', FALSE));
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             QF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.FormQuery');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.FormView
--
-- Description: This procedure builds an HTML form for view/update of fields in
--              the 'SMS_SV' module component (Porting Network Subscriptions).
--
-- Parameters:  Z_FORM_STATUS  Status of the form
--
--------------------------------------------------------------------------------
   procedure FormView(Z_FORM_STATUS in number) is

      SMS_FE_MAP_CHCK varchar2(10);
      SMS_ORDER_CHCK varchar2(10);

    begin

      XNP_WSGL.OpenPageHead('Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions');
      xnp_sv_network$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>VF_BODY_ATTRIBUTES);

      InitialiseDomain('SUBSCRIPTION_TYPE');
      InitialiseDomain('INTERCONNECT_TYPE');



      FORM_VAL.SV_SMS_ID := CURR_VAL.SV_SMS_ID;
      FORM_VAL.PORTING_ID := CURR_VAL.PORTING_ID;
      FORM_VAL.ROUTING_NUMBER_ID := CURR_VAL.ROUTING_NUMBER_ID;
      FORM_VAL.SUBSCRIPTION_TYPE := XNP_WSGL.DomainMeaning(D_SUBSCRIPTION_TYPE, CURR_VAL.SUBSCRIPTION_TYPE);
      FORM_VAL.SUBSCRIPTION_TN := CURR_VAL.SUBSCRIPTION_TN;
      FORM_VAL.MEDIATOR_SP_ID := CURR_VAL.MEDIATOR_SP_ID;
      FORM_VAL.ROUTING_NUMBER := CURR_VAL.ROUTING_NUMBER;
      FORM_VAL.PROVISION_SENT_DATE := ltrim(to_char(CURR_VAL.PROVISION_SENT_DATE, 'DD-MON-YYYY HH:MI:SS AM'));
      FORM_VAL.CNAM_ADDRESS := CURR_VAL.CNAM_ADDRESS;
      FORM_VAL.CNAM_SUBSYSTEM := CURR_VAL.CNAM_SUBSYSTEM;
      FORM_VAL.ISVM_ADDRESS := CURR_VAL.ISVM_ADDRESS;
      FORM_VAL.ISVM_SUBSYSTEM := CURR_VAL.ISVM_SUBSYSTEM;
      FORM_VAL.LIDB_ADDRESS := CURR_VAL.LIDB_ADDRESS;
      FORM_VAL.LIDB_SUBSYSTEM := CURR_VAL.LIDB_SUBSYSTEM;
      FORM_VAL.CLASS_ADDRESS := CURR_VAL.CLASS_ADDRESS;
      FORM_VAL.CLASS_SUBSYSTEM := CURR_VAL.CLASS_SUBSYSTEM;
      FORM_VAL.WSMSC_ADDRESS := CURR_VAL.WSMSC_ADDRESS;
      FORM_VAL.WSMSC_SUBSYSTEM := CURR_VAL.WSMSC_SUBSYSTEM;
      FORM_VAL.RN_ADDRESS := CURR_VAL.RN_ADDRESS;
      FORM_VAL.RN_SUBSYSTEM := CURR_VAL.RN_SUBSYSTEM;
      FORM_VAL.PROVISION_DONE_DATE := ltrim(to_char(CURR_VAL.PROVISION_DONE_DATE, 'DD-MON-YYYY HH:MI:SS AM'));
      FORM_VAL.NRC_CODE := CURR_VAL.NRC_CODE;
      FORM_VAL.NRC_NAME := CURR_VAL.NRC_NAME;
      FORM_VAL.NRC_INTERNET := CURR_VAL.NRC_INTERNET;
      FORM_VAL.ROUTING_REF := CURR_VAL.ROUTING_REF;
      FORM_VAL.ROUTING_SP_ID := CURR_VAL.ROUTING_SP_ID;
      FORM_VAL.REC_SP_ID := CURR_VAL.REC_SP_ID;
      FORM_VAL.REC_CODE := CURR_VAL.REC_CODE;
      FORM_VAL.REC_NAME := CURR_VAL.REC_NAME;
      FORM_VAL.REC_INTERNET := CURR_VAL.REC_INTERNET;
      FORM_VAL.DSP_REC := NBT_VAL.DSP_REC;
      FORM_VAL.REC_EMAIL := CURR_VAL.REC_EMAIL;
      FORM_VAL.DSP_NRC := NBT_VAL.DSP_NRC;
      FORM_VAL.NRC_EMAIL := CURR_VAL.NRC_EMAIL;
      FORM_VAL.INTERCONNECT_TYPE := XNP_WSGL.DomainMeaning(D_INTERCONNECT_TYPE, CURR_VAL.INTERCONNECT_TYPE);
      FORM_VAL.DSP_CNAM := NBT_VAL.DSP_CNAM;
      FORM_VAL.DSP_CLASS := NBT_VAL.DSP_CLASS;
      FORM_VAL.DSP_ISVM := NBT_VAL.DSP_ISVM;
      FORM_VAL.DSP_LIDB := NBT_VAL.DSP_LIDB;
      FORM_VAL.DSP_WSMSC := NBT_VAL.DSP_WSMSC;
      FORM_VAL.DSP_RN := NBT_VAL.DSP_RN;

      if Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_ERROR then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_UPD then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(207, XNP_WSGLM.MSG207_ROW_UPDATED),
                             'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', VF_BODY_ATTRIBUTES);
      elsif Z_FORM_STATUS = XNP_WSGL.FORM_STATUS_INS then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_SUCCESS, XNP_WSGL.MsgGetText(208, XNP_WSGLM.MSG208_ROW_INSERTED),
                             'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', VF_BODY_ATTRIBUTES);
      end if;


      XNP_WSGL.LayoutOpen(XNP_WSGL.LAYOUT_TABLE, P_BORDER=>TRUE);

      XNP_WSGL.LayoutRowStart;
      for i in 1..VF_NUMBER_OF_COLUMNS loop
         XNP_WSGL.LayoutHeader(20, 'LEFT', NULL);
         XNP_WSGL.LayoutHeader(80, 'LEFT', NULL);
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
      XNP_WSGL.LayoutData(htf.bold('Routing Number:'));
      XNP_WSGL.LayoutData(htf.bold(FORM_VAL.ROUTING_NUMBER));
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Provision Sent Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.PROVISION_SENT_DATE);
      XNP_WSGL.LayoutRowEnd;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Provision Done Date:'));
      XNP_WSGL.LayoutData(FORM_VAL.PROVISION_DONE_DATE);
      XNP_WSGL.LayoutRowEnd;
      if NBT_VAL.DSP_REC is not null then
         XNP_WSGL.LayoutRowStart('TOP');
         XNP_WSGL.LayoutData(htf.bold('Recipient:'));
         XNP_WSGL.LayoutData(FORM_VAL.DSP_REC);
         XNP_WSGL.LayoutRowEnd;
      end if;
      XNP_WSGL.LayoutRowStart('TOP');
      XNP_WSGL.LayoutData(htf.bold('Rec. Email:'));
      XNP_WSGL.LayoutData(htf.mailto(FORM_VAL.REC_EMAIL, FORM_VAL.REC_EMAIL));
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
      XNP_WSGL.LayoutData(htf.bold('Interconnect Type:'));
      XNP_WSGL.LayoutData(FORM_VAL.INTERCONNECT_TYPE);
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




      SMS_FE_MAP_CHCK :=
         to_char(XNP_WSGL.Checksum(CURR_VAL.SV_SMS_ID));
      SMS_ORDER_CHCK :=
         to_char(XNP_WSGL.Checksum(CURR_VAL.SV_SMS_ID));


      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'Provisioning Status',
                    0, 'xnp_sv_network$sms_fe_map.startup?P_SV_SMS_ID='||XNP_WSGL.EscapeURLParam(CURR_VAL.SV_SMS_ID)||'&Z_CHK='||SMS_FE_MAP_CHCK);
      XNP_WSGL.NavLinks(XNP_WSGL.MENU_LONG, 'Order Workitems',
                    0, 'xnp_sv_network$sms_order.startup?P_SV_SMS_ID='||XNP_WSGL.EscapeURLParam(CURR_VAL.SV_SMS_ID)||'&Z_CHK='||SMS_ORDER_CHCK);
      XNP_WSGL.NavLinks;


      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             VF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.FormView');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.QueryView
--
-- Description: Queries the details of a single row in preparation for display.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure QueryView(
             P_SV_SMS_ID in varchar2,
             Z_POST_DML in boolean,
             Z_FORM_STATUS in number,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_sv_network$sms_sv.queryview');
      XNP_WSGL.AddURLParam('P_SV_SMS_ID', P_SV_SMS_ID);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('' ||
                                      P_SV_SMS_ID, Z_CHK) then
            return;
         end if;
      end if;


      if P_SV_SMS_ID is not null then
         CURR_VAL.SV_SMS_ID := P_SV_SMS_ID;
      end if;
      if Z_POST_DML then

         null;

      else

         SELECT XNP_SV_SMS_V.SV_SMS_ID,
                XNP_SV_SMS_V.PORTING_ID,
                XNP_SV_SMS_V.ROUTING_NUMBER_ID,
                XNP_SV_SMS_V.SUBSCRIPTION_TYPE,
                XNP_SV_SMS_V.SUBSCRIPTION_TN,
                XNP_SV_SMS_V.MEDIATOR_SP_ID,
                XNP_SV_SMS_V.ROUTING_NUMBER,
                XNP_SV_SMS_V.PROVISION_SENT_DATE,
                XNP_SV_SMS_V.CNAM_ADDRESS,
                XNP_SV_SMS_V.CNAM_SUBSYSTEM,
                XNP_SV_SMS_V.ISVM_ADDRESS,
                XNP_SV_SMS_V.ISVM_SUBSYSTEM,
                XNP_SV_SMS_V.LIDB_ADDRESS,
                XNP_SV_SMS_V.LIDB_SUBSYSTEM,
                XNP_SV_SMS_V.CLASS_ADDRESS,
                XNP_SV_SMS_V.CLASS_SUBSYSTEM,
                XNP_SV_SMS_V.WSMSC_ADDRESS,
                XNP_SV_SMS_V.WSMSC_SUBSYSTEM,
                XNP_SV_SMS_V.RN_ADDRESS,
                XNP_SV_SMS_V.RN_SUBSYSTEM,
                XNP_SV_SMS_V.PROVISION_DONE_DATE,
                XNP_SV_SMS_V.NRC_CODE,
                XNP_SV_SMS_V.NRC_NAME,
                XNP_SV_SMS_V.NRC_INTERNET,
                XNP_SV_SMS_V.ROUTING_REF,
                XNP_SV_SMS_V.ROUTING_SP_ID,
                XNP_SV_SMS_V.REC_SP_ID,
                XNP_SV_SMS_V.REC_CODE,
                XNP_SV_SMS_V.REC_NAME,
                XNP_SV_SMS_V.REC_INTERNET,
                XNP_SV_SMS_V.REC_EMAIL,
                XNP_SV_SMS_V.NRC_EMAIL,
                XNP_SV_SMS_V.INTERCONNECT_TYPE
         INTO   CURR_VAL.SV_SMS_ID,
                CURR_VAL.PORTING_ID,
                CURR_VAL.ROUTING_NUMBER_ID,
                CURR_VAL.SUBSCRIPTION_TYPE,
                CURR_VAL.SUBSCRIPTION_TN,
                CURR_VAL.MEDIATOR_SP_ID,
                CURR_VAL.ROUTING_NUMBER,
                CURR_VAL.PROVISION_SENT_DATE,
                CURR_VAL.CNAM_ADDRESS,
                CURR_VAL.CNAM_SUBSYSTEM,
                CURR_VAL.ISVM_ADDRESS,
                CURR_VAL.ISVM_SUBSYSTEM,
                CURR_VAL.LIDB_ADDRESS,
                CURR_VAL.LIDB_SUBSYSTEM,
                CURR_VAL.CLASS_ADDRESS,
                CURR_VAL.CLASS_SUBSYSTEM,
                CURR_VAL.WSMSC_ADDRESS,
                CURR_VAL.WSMSC_SUBSYSTEM,
                CURR_VAL.RN_ADDRESS,
                CURR_VAL.RN_SUBSYSTEM,
                CURR_VAL.PROVISION_DONE_DATE,
                CURR_VAL.NRC_CODE,
                CURR_VAL.NRC_NAME,
                CURR_VAL.NRC_INTERNET,
                CURR_VAL.ROUTING_REF,
                CURR_VAL.ROUTING_SP_ID,
                CURR_VAL.REC_SP_ID,
                CURR_VAL.REC_CODE,
                CURR_VAL.REC_NAME,
                CURR_VAL.REC_INTERNET,
                CURR_VAL.REC_EMAIL,
                CURR_VAL.NRC_EMAIL,
                CURR_VAL.INTERCONNECT_TYPE
         FROM   XNP_SV_SMS_V XNP_SV_SMS_V
         WHERE  XNP_SV_SMS_V.SV_SMS_ID = CURR_VAL.SV_SMS_ID
         ;

      end if;

      NBT_VAL.DSP_REC := ( CURR_VAL.REC_CODE || ' - ' || CURR_VAL.REC_NAME );
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
                             'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', VF_BODY_ATTRIBUTES);
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             VF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.QueryView');
   end;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.QueryList
--
-- Description: This procedure builds the Record list for the 'SMS_SV'
--              module component (Porting Network Subscriptions).
--
--              The Record List displays context information for records which
--              match the specified query criteria.
--              Sets of records are displayed (10 records at a time)
--              with Next/Previous buttons to get other record sets.
--
--              The first context column will be created as a link to the
--              xnp_sv_network$sms_sv.FormView procedure for display of more details
--              of that particular row.
--
-- Parameters:  P_PORTING_ID - Porting ID
--              P_SUBSCRIPTION_TYPE - Subscription Type
--              P_SUBSCRIPTION_TN - Telephone
--              P_NRC_CODE - NRC Code
--              P_REC_CODE - Rec Code
--              Z_START - First record to display
--              Z_ACTION - Next or Previous set
--
--------------------------------------------------------------------------------
   procedure QueryList(
             P_PORTING_ID in varchar2,
             P_SUBSCRIPTION_TYPE in varchar2,
             P_SUBSCRIPTION_TN in varchar2,
             P_NRC_CODE in varchar2,
             P_REC_CODE in varchar2,
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
      SMS_FE_MAP_CHCK  varchar2(10);
      SMS_ORDER_CHCK  varchar2(10);
      L_CHECKSUM          varchar2(10);

   begin

      XNP_WSGL.RegisterURL('xnp_sv_network$sms_sv.querylist');
      XNP_WSGL.AddURLParam('P_PORTING_ID', P_PORTING_ID);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TYPE', P_SUBSCRIPTION_TYPE);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TN', P_SUBSCRIPTION_TN);
      XNP_WSGL.AddURLParam('P_NRC_CODE', P_NRC_CODE);
      XNP_WSGL.AddURLParam('P_REC_CODE', P_REC_CODE);
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

      XNP_WSGL.OpenPageHead('Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions');
      CreateListJavaScript;
      xnp_sv_network$.TemplateHeader(TRUE,0);
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
                    P_NRC_CODE,
                    P_REC_CODE);
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
                             'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', RL_BODY_ATTRIBUTES);
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
                       P_NRC_CODE,
                       P_REC_CODE) then
               XNP_WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if not PreQuery(
                       P_PORTING_ID,
                       P_SUBSCRIPTION_TYPE,
                       P_SUBSCRIPTION_TN,
                       P_NRC_CODE,
                       P_REC_CODE) then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                                'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', RL_BODY_ATTRIBUTES);
         return;
         end if;



         I_CURSOR := dbms_sql.open_cursor;
         dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
         dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.SV_SMS_ID);
         dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.PORTING_ID, 80);
         dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.SUBSCRIPTION_TN, 20);
         dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.ROUTING_NUMBER, 20);

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
      	    XNP_WSGL.LayoutHeader(20, 'LEFT', 'Routing Number');
         end loop;
         XNP_WSGL.LayoutRowEnd;

         while I_ROWS_FETCHED <> 0 loop

            if I_TOTAL_ROWS >= I_START then
               dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.SV_SMS_ID);
               dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.PORTING_ID);
               dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.SUBSCRIPTION_TN);
               dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.ROUTING_NUMBER);
               L_CHECKSUM := to_char(XNP_WSGL.Checksum(''||CURR_VAL.SV_SMS_ID));


               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData(htf.anchor2('xnp_sv_network$sms_sv.queryview?P_SV_SMS_ID='||CURR_VAL.SV_SMS_ID||'&Z_CHK='||L_CHECKSUM, CURR_VAL.PORTING_ID, ctarget=>L_VF_FRAME));
               XNP_WSGL.LayoutData(CURR_VAL.SUBSCRIPTION_TN);
               XNP_WSGL.LayoutData(CURR_VAL.ROUTING_NUMBER);
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

      htp.formOpen(curl => 'xnp_sv_network$sms_sv.querylist', cattributes => 'NAME="frmZero"');
      XNP_WSGL.HiddenField('P_PORTING_ID', P_PORTING_ID);
      XNP_WSGL.HiddenField('P_SUBSCRIPTION_TYPE', P_SUBSCRIPTION_TYPE);
      XNP_WSGL.HiddenField('P_SUBSCRIPTION_TN', P_SUBSCRIPTION_TN);
      XNP_WSGL.HiddenField('P_NRC_CODE', P_NRC_CODE);
      XNP_WSGL.HiddenField('P_REC_CODE', P_REC_CODE);
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

      htp.formOpen(curl => 'xnp_sv_network$sms_sv.querylist', ctarget=>'_top', cattributes => 'NAME="frmOne"');
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             RL_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.QueryList');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.QueryFirst
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
             P_NRC_CODE in varchar2,
             P_REC_CODE in varchar2,
             Z_ACTION in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is

      I_CURSOR            integer;
      I_VOID              integer;
      I_ROWS_FETCHED      integer := 0;

   begin

      XNP_WSGL.RegisterURL('xnp_sv_network$sms_sv.queryfirst');
      XNP_WSGL.AddURLParam('P_PORTING_ID', P_PORTING_ID);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TYPE', P_SUBSCRIPTION_TYPE);
      XNP_WSGL.AddURLParam('P_SUBSCRIPTION_TN', P_SUBSCRIPTION_TN);
      XNP_WSGL.AddURLParam('P_NRC_CODE', P_NRC_CODE);
      XNP_WSGL.AddURLParam('P_REC_CODE', P_REC_CODE);
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
                    P_NRC_CODE,
                    P_REC_CODE) then
         return;
      end if;

      if not PreQuery(
                    P_PORTING_ID,
                    P_SUBSCRIPTION_TYPE,
                    P_SUBSCRIPTION_TN,
                    P_NRC_CODE,
                    P_REC_CODE) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions', VF_BODY_ATTRIBUTES);
         return;
      end if;

      I_CURSOR := dbms_sql.open_cursor;
      dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
      dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.SV_SMS_ID);
      dbms_sql.define_column(I_CURSOR, 2, CURR_VAL.PORTING_ID, 80);
      dbms_sql.define_column(I_CURSOR, 3, CURR_VAL.SUBSCRIPTION_TN, 20);
      dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.ROUTING_NUMBER, 20);

      I_VOID := dbms_sql.execute(I_CURSOR);

      I_ROWS_FETCHED := dbms_sql.fetch_rows(I_CURSOR);

      if I_ROWS_FETCHED = 0 then
         XNP_WSGL.EmptyPage(VF_BODY_ATTRIBUTES);
      else
         dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.SV_SMS_ID);
         dbms_sql.column_value(I_CURSOR, 2, CURR_VAL.PORTING_ID);
         dbms_sql.column_value(I_CURSOR, 3, CURR_VAL.SUBSCRIPTION_TN);
         dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.ROUTING_NUMBER);
         xnp_sv_network$sms_sv.QueryView(Z_DIRECT_CALL=>TRUE);
      end if;

      dbms_sql.close_cursor(I_CURSOR);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             VF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.QueryFirst');
         XNP_WSGL.ClosePageBody;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'SMS_SV' module component  (Porting Network Subscriptions).
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
            P_NRC_CODE in varchar2,
            P_REC_CODE in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'SMS_SV' module component  (Porting Network Subscriptions).
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.PostQuery');
          return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.CreateQueryJavaScript
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             QF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.CreateQueryJavaScript');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_sv.CreateListJavaScript
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Porting Network Subscriptions',
                             RL_BODY_ATTRIBUTES, 'xnp_sv_network$sms_sv.CreateListJavaScript');
   end;
end;

/
