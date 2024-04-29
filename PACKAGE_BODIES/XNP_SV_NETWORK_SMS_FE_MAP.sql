--------------------------------------------------------
--  DDL for Package Body XNP_SV_NETWORK$SMS_FE_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_SV_NETWORK$SMS_FE_MAP" as
/* $Header: XNPSVN3B.pls 120.0 2005/05/30 11:51:59 appldev noship $ */


   function BuildSQL(
            P_SV_SMS_ID in varchar2 default null) return boolean;
   function PreQuery(
            P_SV_SMS_ID in varchar2 default null) return boolean;
   function PostQuery(Z_POST_DML in boolean) return boolean;
   procedure CreateListJavaScript;
   procedure InitialiseDomain(P_ALIAS in varchar2);

   RL_BODY_ATTRIBUTES     constant varchar2(500) := 'BGCOLOR="CCCCCC"';
   RL_NEXT_BUT_CAPTION    constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_NEXT_BUTTON'));
   RL_PREV_BUT_CAPTION    constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_PREVIOUS_BUTTON'));
   RL_FIRST_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_FIRST_BUTTON'));
   RL_LAST_BUT_CAPTION    constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_LAST_BUTTON'));
   RL_COUNT_BUT_CAPTION   constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_COUNT_BUTTON'));
   RL_REQUERY_BUT_CAPTION constant varchar2(100) := htf.escape_sc(fnd_message.get_string('XNP','WEB_REFRESH_BUTTON'));
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

   CURR_VAL XNP_SV_SMS_FE_MAPS%ROWTYPE;

   TYPE FORM_REC IS RECORD
        (SMS_FE_MAP_ID       VARCHAR2(8)
        ,SV_SMS_ID           VARCHAR2(8)
        ,FE_ID               VARCHAR2(8)
        ,L_FET_FE_NAME       VARCHAR2(40)
        ,L_FEE_FE_TYPE       VARCHAR2(40)
        ,FEATURE_TYPE        VARCHAR2(40)
        ,PROVISION_STATUS    VARCHAR2(40)
        ,L_FET_FETYPE_ID     VARCHAR2(10)
        );
   FORM_VAL   FORM_REC;

   TYPE NBT_REC IS RECORD
        (L_FET_FE_NAME       XDP_FES.FULFILLMENT_ELEMENT_NAME%TYPE
        ,L_FEE_FE_TYPE       XDP_FE_TYPES.FULFILLMENT_ELEMENT_TYPE%TYPE
        ,L_FET_FETYPE_ID     XDP_FES.FETYPE_ID%TYPE
        );
   NBT_VAL    NBT_REC;

   ZONE_SQL   VARCHAR2(1300) := null;

   D_FEATURE_TYPE        XNP_WSGL.typDVRecord;
   D_PROVISION_STATUS    XNP_WSGL.typDVRecord;
--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.InitialiseDomain
--
-- Description: Initialises the Domain Record for the given Column Usage
--
-- Parameters:  P_ALIAS   The alias of the column usage
--
--------------------------------------------------------------------------------
   procedure InitialiseDomain(P_ALIAS in varchar2) is
   begin

      if P_ALIAS = 'FEATURE_TYPE' and not D_FEATURE_TYPE.Initialised then
         D_FEATURE_TYPE.ColAlias := 'FEATURE_TYPE';
         D_FEATURE_TYPE.ControlType := XNP_WSGL.DV_TEXT;
         D_FEATURE_TYPE.DispWidth := 40;
         D_FEATURE_TYPE.DispHeight := 1;
         D_FEATURE_TYPE.MaxWidth := 40;
         D_FEATURE_TYPE.UseMeanings := True;
         D_FEATURE_TYPE.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_FEATURE_TYPE', D_FEATURE_TYPE);
         D_FEATURE_TYPE.Initialised := True;
      end if;

      if P_ALIAS = 'PROVISION_STATUS' and not D_PROVISION_STATUS.Initialised then
         D_PROVISION_STATUS.ColAlias := 'PROVISION_STATUS';
         D_PROVISION_STATUS.ControlType := XNP_WSGL.DV_TEXT;
         D_PROVISION_STATUS.DispWidth := 40;
         D_PROVISION_STATUS.DispHeight := 1;
         D_PROVISION_STATUS.MaxWidth := 40;
         D_PROVISION_STATUS.UseMeanings := True;
         D_PROVISION_STATUS.ColOptional := False;
         XNP_WSGL.LoadDomainValues('CG_REF_CODES', 'XNP_PROV_STATUS', D_PROVISION_STATUS);
         D_PROVISION_STATUS.Initialised := True;
      end if;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.InitialseDomain');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.Startup
--
-- Description: Entry point for the 'SMS_FE_MAP' module
--              component  (Provisioning Status).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   procedure Startup(
             P_SV_SMS_ID in varchar2,
             Z_DIRECT_CALL in boolean,
             Z_CHK in varchar2) is
   begin

      XNP_WSGL.RegisterURL('xnp_sv_network$sms_fe_map.startup');
      XNP_WSGL.AddURLParam('P_SV_SMS_ID', P_SV_SMS_ID);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);

      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('' ||
                                      P_SV_SMS_ID, Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.StoreURLLink(2, 'Provisioning Status');


      QueryList(
      P_SV_SMS_ID=>P_SV_SMS_ID,
      Z_DIRECT_CALL=>TRUE);

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.Startup');
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.QueryHits
--
-- Description: Returns the number or rows which matches the given search
--              criteria (if any).
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function QueryHits(
            P_SV_SMS_ID in varchar2) return number is
      I_QUERY     varchar2(2000) := '';
      I_CURSOR    integer;
      I_VOID      integer;
      I_FROM_POS  integer := 0;
      I_COUNT     number(10);
   begin

      if not BuildSQL(P_SV_SMS_ID) then
         return -1;
      end if;

      if not PreQuery(P_SV_SMS_ID) then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                             'Monitor Network Subscriptions'||' : '||'Provisioning Status', DEF_BODY_ATTRIBUTES);
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.QueryHits');
         return -1;
   end;--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.BuildSQL
--
-- Description: Builds the SQL for the 'SMS_FE_MAP' module component (Provisioning Status).
--              This incorporates all query criteria and Foreign key columns.
--
-- Parameters:
--
--------------------------------------------------------------------------------
   function BuildSQL(
            P_SV_SMS_ID in varchar2) return boolean is

      I_WHERE varchar2(2000);
   begin


      -- Build up the Where clause
      I_WHERE := I_WHERE || ' where L_FET.FE_ID = SFP.FE_ID';
      I_WHERE := I_WHERE || ' and L_FEE.FETYPE_ID = L_FET.FETYPE_ID';

      begin
         XNP_WSGL.BuildWhere(P_SV_SMS_ID, 'SFP.SV_SMS_ID', XNP_WSGL.TYPE_NUMBER, I_WHERE);
      exception
         when others then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR_QRY, SQLERRM,
                                'Monitor Network Subscriptions'||' : '||'Provisioning Status', DEF_BODY_ATTRIBUTES, NULL,
                                XNP_WSGL.MsgGetText(210,XNP_WSGLM.MSG210_INVALID_QRY,'Number Range Id'));
            return false;
      end;

      ZONE_SQL := 'SELECT SFP.SMS_FE_MAP_ID,
                         L_FET.FULFILLMENT_ELEMENT_NAME,
                         L_FEE.FULFILLMENT_ELEMENT_TYPE,
                         SFP.FEATURE_TYPE,
                         SFP.PROVISION_STATUS
                  FROM   XNP_SV_SMS_FE_MAPS SFP,
                         XDP_FES L_FET,
                         XDP_FE_TYPES L_FEE';

      ZONE_SQL := ZONE_SQL || I_WHERE;
      ZONE_SQL := ZONE_SQL || ' ORDER BY SFP.SV_SMS_ID';
      return true;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.BuildSQL');
         return false;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.QueryList
--
-- Description: This procedure builds the Record list for the 'SMS_FE_MAP'
--              module component (Provisioning Status).
--
--              The Record List displays context information for records which
--              match the specified query criteria.
--              Sets of records are displayed (10 records at a time)
--              with Next/Previous buttons to get other record sets.
--
-- Parameters:  P_SV_SMS_ID - Number Range Id
--              Z_START - First record to display
--              Z_ACTION - Next or Previous set
--
--------------------------------------------------------------------------------
   procedure QueryList(
             P_SV_SMS_ID in varchar2,
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

      XNP_WSGL.RegisterURL('xnp_sv_network$sms_fe_map.querylist');
      XNP_WSGL.AddURLParam('P_SV_SMS_ID', P_SV_SMS_ID);
      XNP_WSGL.AddURLParam('Z_START', Z_START);
      XNP_WSGL.AddURLParam('Z_ACTION', Z_ACTION);
      XNP_WSGL.AddURLParam('Z_CHK', Z_CHK);
      if not Z_DIRECT_CALL then
         if not XNP_WSGL.ValidateChecksum('' ||
                                      P_SV_SMS_ID, Z_CHK) then
            return;
         end if;
      end if;

      XNP_WSGL.OpenPageHead('Monitor Network Subscriptions'||' : '||'Provisioning Status');
      CreateListJavaScript;
      xnp_sv_network$.TemplateHeader(TRUE,0);
      XNP_WSGL.ClosePageHead;

      XNP_WSGL.OpenPageBody(FALSE, p_attributes=>RL_BODY_ATTRIBUTES);

      htp.p(htf.bold(fnd_message.get_string('XNP','WEB_TITLE')));
      htp.p(htf.header(1,fnd_message.get_string('XNP','WEB_XNPSVNWK_PROV_TITLE')));
      if (Z_ACTION = RL_LAST_BUT_ACTION) or (Z_ACTION = RL_LAST_BUT_CAPTION) or
         (Z_ACTION = RL_COUNT_BUT_ACTION) or (Z_ACTION = RL_COUNT_BUT_CAPTION) or
         (RL_TOTAL_COUNT_REQD)
      then

         I_COUNT := QueryHits(
                    P_SV_SMS_ID);
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
                             'Monitor Network Subscriptions'||' : '||'Provisioning Status', RL_BODY_ATTRIBUTES);
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
                       P_SV_SMS_ID) then
               XNP_WSGL.ClosePageBody;
               return;
            end if;
         end if;

         if not PreQuery(
                       P_SV_SMS_ID) then
            XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_ERROR, XNP_cg$errors.GetErrors,
                                'Monitor Network Subscriptions'||' : '||'Provisioning Status', RL_BODY_ATTRIBUTES);
         return;
         end if;

         InitialiseDomain('FEATURE_TYPE');
         InitialiseDomain('PROVISION_STATUS');


         I_CURSOR := dbms_sql.open_cursor;
         dbms_sql.parse(I_CURSOR, ZONE_SQL, dbms_sql.v7);
         dbms_sql.define_column(I_CURSOR, 1, CURR_VAL.SMS_FE_MAP_ID);
         dbms_sql.define_column(I_CURSOR, 2, NBT_VAL.L_FET_FE_NAME, 40);
         dbms_sql.define_column(I_CURSOR, 3, NBT_VAL.L_FEE_FE_TYPE, 40);
         dbms_sql.define_column(I_CURSOR, 4, CURR_VAL.FEATURE_TYPE, 15);
         dbms_sql.define_column(I_CURSOR, 5, CURR_VAL.PROVISION_STATUS, 20);

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
      	    XNP_WSGL.LayoutHeader(40, 'LEFT', 'Network Element Name');
      	    XNP_WSGL.LayoutHeader(30, 'LEFT', 'Network Element Type');
      	    XNP_WSGL.LayoutHeader(40, 'LEFT', 'Feature Type');
      	    XNP_WSGL.LayoutHeader(40, 'LEFT', 'Provisioning Status');
         end loop;
         XNP_WSGL.LayoutRowEnd;

         while I_ROWS_FETCHED <> 0 loop

            if I_TOTAL_ROWS >= I_START then
               dbms_sql.column_value(I_CURSOR, 1, CURR_VAL.SMS_FE_MAP_ID);
               dbms_sql.column_value(I_CURSOR, 2, NBT_VAL.L_FET_FE_NAME);
               dbms_sql.column_value(I_CURSOR, 3, NBT_VAL.L_FEE_FE_TYPE);
               dbms_sql.column_value(I_CURSOR, 4, CURR_VAL.FEATURE_TYPE);
               dbms_sql.column_value(I_CURSOR, 5, CURR_VAL.PROVISION_STATUS);
               L_CHECKSUM := to_char(XNP_WSGL.Checksum(''||CURR_VAL.SMS_FE_MAP_ID));


               XNP_WSGL.LayoutRowStart('TOP');
               XNP_WSGL.LayoutData(NBT_VAL.L_FET_FE_NAME);
               XNP_WSGL.LayoutData(NBT_VAL.L_FEE_FE_TYPE);
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_FEATURE_TYPE, CURR_VAL.FEATURE_TYPE));
               XNP_WSGL.LayoutData(XNP_WSGL.DomainMeaning(D_PROVISION_STATUS, CURR_VAL.PROVISION_STATUS));
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

      htp.formOpen(curl => 'xnp_sv_network$sms_fe_map.querylist', cattributes => 'NAME="frmZero"');
      XNP_WSGL.HiddenField('P_SV_SMS_ID', P_SV_SMS_ID);
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
                     to_char(XNP_WSGL.Checksum(''||P_SV_SMS_ID)));
      htp.formClose;

      XNP_WSGL.ReturnLinks('0.1', XNP_WSGL.MENU_LONG);
      XNP_WSGL.NavLinks;

      htp.p(htf.img('/OA_MEDIA/FNDLOGOS.gif'));

      XNP_WSGL.ClosePageBody;

   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             RL_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.QueryList');
         XNP_WSGL.ClosePageBody;
   end;


--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.PreQuery
--
-- Description: Provides place holder for code to be run prior to a query
--              for the 'SMS_FE_MAP' module component  (Provisioning Status).
--
-- Parameters:  None
--
-- Returns:     True           If success
--              False          Otherwise
--
--------------------------------------------------------------------------------
   function PreQuery(
            P_SV_SMS_ID in varchar2) return boolean is
      L_RET_VAL boolean := TRUE;
   begin
      return L_RET_VAL;
   exception
      when others then
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.PreQuery');
         return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.PostQuery
--
-- Description: Provides place holder for code to be run after a query
--              for the 'SMS_FE_MAP' module component  (Provisioning Status).
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             DEF_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.PostQuery');
          return FALSE;
   end;

--------------------------------------------------------------------------------
-- Name:        xnp_sv_network$sms_fe_map.CreateListJavaScript
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
         XNP_WSGL.DisplayMessage(XNP_WSGL.MESS_EXCEPTION, SQLERRM, 'Monitor Network Subscriptions'||' : '||'Provisioning Status',
                             RL_BODY_ATTRIBUTES, 'xnp_sv_network$sms_fe_map.CreateListJavaScript');
   end;
end;

/
