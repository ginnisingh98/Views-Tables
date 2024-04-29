--------------------------------------------------------
--  DDL for Package Body ALR_DBTRIGGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ALR_DBTRIGGER" as    -- package body
/* $Header: ALREDBTB.pls 120.5.12010000.7 2010/03/31 21:02:39 jwsmith ship $ */


   --
   --   PRAGMAS
   --

   NONEXISTENT_TABLE exception;
   pragma EXCEPTION_INIT(NONEXISTENT_TABLE, -942);

   NONEXISTENT_TRIGGER exception;
   pragma EXCEPTION_INIT(NONEXISTENT_TRIGGER, -4080);

   APPLICATION_ERROR exception;
   pragma EXCEPTION_INIT(APPLICATION_ERROR, -20001);

   PLSQL_UNCOMPILED exception;
   pragma EXCEPTION_INIT(PLSQL_UNCOMPILED, -6550);


   --
   --   GLOBALS
   --

   type CREATED_TRIGGERS_TYPE is table of varchar2(61)
     index by BINARY_INTEGER;
   type CREATED_TRIG_ONAME_TYPE is table of varchar2(30)
     index by BINARY_INTEGER;
   CREATED_TRIGGERS   CREATED_TRIGGERS_TYPE;
   CREATED_TRIG_ONAME CREATED_TRIG_ONAME_TYPE;
   NUMBER_OF_TRIGGERS integer;

   BAD_ORACLE_USERNAMES varchar2(320);

   APPLSYS_SCHEMA         varchar2(30) := NULL;
   TARGET_APPL_SHORT_NAME varchar2(50) := NULL;
   TARGET_APPL_ID         number(15)   := NULL;
   MULTI_ORG_FLAG         varchar2(1)  := NULL;
   DIAGNOSTICS            varchar2(1)  := NULL;
   DEBUG_SEQ              number(15)   := 0;

   -- ======================================================================
   --
   --   PRIVATE PROCEDURE/FUNCTIONS
   --
   -- ======================================================================

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure CREATE_EVENT_DB_TRIGGER$1( -- prototype
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,	-- null = all ORACLE IDs
		ONAME in varchar2,
		EVENT_MODE in varchar2,
		ENABLED_FLAG in varchar2);

   procedure ALTER_EVENT_DB_TRIGGER$1(  -- prototype
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		ONAME in varchar2,
		EVENT_MODE in varchar2,
		IS_ENABLE in varchar2);


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure ALR_DEBUG(TXT varchar2) is
	c               INTEGER;
	rows_processed  INTEGER;
        sqlstmt         VARCHAR2(32000);
   begin

     -- Only do debug logging if Diagnostics is enabled
     if alr_dbtrigger.DIAGNOSTICS = 'Y' then

       DEBUG_SEQ := DEBUG_SEQ + 1;

       sqlstmt := 'insert into alr_dbtrigger_debug'||
                  '(type,creation_date,stmt) values('''||
                  DEBUG_SEQ||''',sysdate,'''||TXT||''')';

       c := dbms_sql.open_cursor;

       begin
         dbms_sql.parse(c, sqlstmt, dbms_sql.native);
         rows_processed := dbms_sql.execute(c);
       exception
         when others then
           NULL; -- do nothing
       end;

       dbms_sql.close_cursor(c);
     end if;

   end ALR_DEBUG;

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure ALR_DEBUG_CLEAN is
	c               INTEGER;
	rows_processed  INTEGER;
   begin
       c := dbms_sql.open_cursor;

       begin
         dbms_sql.parse(c, 'delete alr_dbtrigger_debug', dbms_sql.native);
         rows_processed := dbms_sql.execute(c);
       exception
         when others then
           NULL; -- do nothing
       end;

       dbms_sql.close_cursor(c);

   end ALR_DEBUG_CLEAN;

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure INIT_GLOBALS (APPL_ID number) is

     t_schema   varchar2(30);
     call_ok    boolean;

   begin

     --
     -- Fetch the APPLSYS schema, only once.
     --
     if alr_dbtrigger.APPLSYS_SCHEMA is NULL then
       begin

         select fou.oracle_username
           into t_schema
           from FND_PRODUCT_INSTALLATIONS FPI,
                FND_ORACLE_USERID FOU
          where fpi.application_id = 0
          and   fpi.oracle_id = fou.oracle_id;

         -- Could use FND_INSTALLATION.GET_APP_INFO as well,
         -- but this code is shared with aluddt.sql, called by
         -- AutoInstall before FND_INSTALLATION gets recreated
         -- during upgrade.

         alr_dbtrigger.APPLSYS_SCHEMA := t_schema;

       exception
         when others then
         -- Need to provide an error message here.
	 APP_EXCEPTION.RAISE_EXCEPTION;

       end;
     end if;  -- APPLSYS_SCHEMA

     --
     -- Fetch the appl shortname for the passed appl ID
     --
     if (alr_dbtrigger.TARGET_APPL_ID is NULL) or
        (alr_dbtrigger.TARGET_APPL_ID <> APPL_ID) then
       begin

         select application_short_name
           into alr_dbtrigger.TARGET_APPL_SHORT_NAME
           from fnd_application
          where application_id = APPL_ID;

         alr_dbtrigger.TARGET_APPL_ID := APPL_ID;

       exception
         when others then
           -- Need to provide an error message here.
	   APP_EXCEPTION.RAISE_EXCEPTION;

       end;
     end if;  -- TARGET_APPL_ID

     --
     -- Fetch the multi-org flag
     --
     if alr_dbtrigger.MULTI_ORG_FLAG is NULL then
       begin

         select multi_org_flag
           into alr_dbtrigger.MULTI_ORG_FLAG
           from fnd_product_groups
          where rownum=1;   -- there should only be one row, but just in case

         if alr_dbtrigger.MULTI_ORG_FLAG is NULL then
            alr_dbtrigger.MULTI_ORG_FLAG := 'N';   -- default
         end if;

       exception
         when others then
           -- Need to provide an error message here.
	   APP_EXCEPTION.RAISE_EXCEPTION;

       end;
     end if;

     --
     -- Fetch the Diagnostics flag
     --
     if alr_dbtrigger.DIAGNOSTICS is NULL then
       begin
         alr_dbtrigger.DIAGNOSTICS := FND_PROFILE.VALUE('DIAGNOSTICS');

         if alr_dbtrigger.DIAGNOSTICS is NULL then
            alr_dbtrigger.DIAGNOSTICS := 'N';   -- default
         end if;

         -- Try to delete the old debug records
         ALR_DEBUG_CLEAN;

       exception
         when others then
           alr_dbtrigger.DIAGNOSTICS := 'N';

       end;
     end if;

   end INIT_GLOBALS;

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   function DISALLOWED_CONTEXT(
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		EVENT_MODE in varchar2)
     return varchar2 is
     OID_LIST varchar2(32000);
     prefix_list varchar2(20);
     oracle_id_str varchar2(100);  /* max: oracle_id(30)+org_code(15) */
     no_org_flag varchar2(1);

      cursor C is
      select DISTINCT ORACLE_USERNAME, DATA_GROUP_ID ORG_ID
        from alr_alerts a,
             alr_alert_installations i,
             fnd_oracle_userid o
       where a.alert_condition_type='E'
	 and 'Y'=decode(EVENT_MODE, 'I', a.insert_flag,
				    'U', a.update_flag,
				    'D', a.delete_flag)
         and a.enabled_flag = 'Y'
         and i.enabled_flag = 'Y'
	 and a.table_application_id = TBL_APPLID
	 and a.table_name = TBL_NAME
         and i.application_id = a.application_id
         and i.alert_id = a.alert_id
         and i.oracle_id = o.oracle_id;

   begin

      -- Create a list of enabled ORACLE_ID + ORG_ID combinations
      -- in the form of:
      --  a)   if USER||ORG_ID not in ('APPS123','APPS',...)
      --  b)   if USER not in ('APPS','APPS2',...)
      --
      -- The list will validate whether the database trigger was fired
      -- from within one of the allowable schema/org combinations.
      --
      -- Case (a) is applicable when site is multi-org *and* there are
      -- non-null org_id's associated with the oracle_id in the alert
      -- installations screen.
      --
      -- Case (b) is applicable for other cases. ie. for non-multi-org,
      -- as well as for multi-org but without associated org_id's.
      --
      -- First, we need to determine that if this is a multi-org site,
      -- whether there is any associated org_id for all event alerts
      -- on this table (since one db trigger services all event alerts
      -- based on the same table).

      prefix_list := 'USER not in (';

      if MULTI_ORG_FLAG = 'Y' then

        no_org_flag := 'Y';

        begin

          select 'N'
            into no_org_flag
            from dual
           where exists
            (select 1
               from alr_alerts a,
                    alr_alert_installations i
              where a.alert_condition_type='E'
                and 'Y'=decode(EVENT_MODE, 'I', a.insert_flag,
                                           'U', a.update_flag,
                                           'D', a.delete_flag)
                and a.enabled_flag = 'Y'
                and i.enabled_flag = 'Y'
                and a.table_application_id = TBL_APPLID
                and a.table_name = TBL_NAME
                and i.application_id = a.application_id
                and i.alert_id = a.alert_id
                and i.data_group_id is not null);

         exception
           when others then NULL;  -- Ignore all errors
         end;

         if no_org_flag <> 'Y' then
           prefix_list := 'USER||ORGID not in (';
         end if;
      end if;

      OID_LIST := NULL;

      for CREC in C loop  -- fetch all ORACLE IDs

        if crec.ORG_ID is not NULL and
           alr_dbtrigger.MULTI_ORG_FLAG = 'Y' then
          oracle_id_str := crec.ORACLE_USERNAME || crec.ORG_ID;
        else
          oracle_id_str := crec.ORACLE_USERNAME;
        end if;

        if OID_LIST is NOT NULL then
          OID_LIST := OID_LIST || ',''' || oracle_id_str || '''';
        else
          OID_LIST := '''' || oracle_id_str || '''';
        end if;
      end loop;

      if OID_LIST is NULL then
        OID_LIST := '''NONE''';
      end if;

      OID_LIST := prefix_list || OID_LIST || ')';
      return OID_LIST;

   exception
     when others then NULL;  -- Ignore all errors

   end DISALLOWED_CONTEXT;

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure RUN_SQL(ROOT_STMT     in varchar2,
                     TARGET_SCHEMA in varchar2,
                     SQLSTMT       in varchar2,
                     OBJECT_NAME   in varchar2) is

     stmt_type integer;

   begin

     if ROOT_STMT = 'create' then
       STMT_TYPE := ad_ddl.create_trigger;
     elsif ROOT_STMT = 'alter' then
       STMT_TYPE := ad_ddl.alter_trigger;
     elsif ROOT_STMT = 'drop' then
       STMT_TYPE := ad_ddl.drop_trigger;
     else
       -- Need to provide an error message here.
       APP_EXCEPTION.RAISE_EXCEPTION;
     end if;


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ORACLE WORLDWIDE SUPPORT:

   This portion can be used for debugging any errors during the
   creation or modification of alert database triggers in the Define
   Alert form (message "Event alert is inactive in ORACLE ID xxx").

   This procedure is called for every DDL stmt done in this package.
   The stmt can be stored in a debug table by the below INSERT so that
   you can re-execute it manually from sqlplus.

   1) Create the debug table under the APPLSYS account as follows:

          connect applsys/apps

          create table alr_dbtrigger_debug
             (creation_date date,
                    applsys varchar2(30),
                   appsname varchar2(30),
                     target varchar2(30),
                       type varchar2(10),
                       stmt varchar2(32000));

      Grant access to the APPS account and other APPS accounts
      to be debugged:

          grant all privileges on alr_dbtrigger_debug to APPS;

      Create a synonym under the APPS account and other APPS accounts
      to be debugged:

          connect apps/apps

          create synonym alr_dbtrigger_debug for APPLSYS.alr_dbtrigger_debug;

   2) Uncomment the below INSERT statement and save this file. */

/*
     insert into alr_dbtrigger_debug values
	(Sysdate,
        alr_dbtrigger.APPLSYS_SCHEMA,
	alr_dbtrigger.TARGET_APPL_SHORT_NAME,
	TARGET_SCHEMA,
	DEBUG_SEQ,
	SQLSTMT);
     commit;
 */

/* 3) Recreate ALR_DBTRIGGER package defined by this file:

          sqlplus apps/apps   @ALREDBTB.pls
                   : (and in any other APPS accounts)

   4) Re-define the alert in the Oracle Alert form, or 'touch' the
      problemed alert definition by simply disabling and then
      re-enabling it.  This will attempt to recreate the underlying
      database trigger(s).  If ORA-4068 occurs, try this step once
      more.  (This is not the original error and is caused by the
      regeneration of the ALR_DBTRIGGER package.)

   When the error is reproduced, there should be one or more records
   inserted in the ALR_DBTRIGGER_DEBUG table.  Select the records and
   examine the SQL stmt stored in ALR_DBTRIGGER_DEBUG.STMT.  Execute
   the statement directly in sqlplus while connected to the APPS
   account to determine the exact cause.

   Once the issue is resolved, please undo the debugging setup by
   reversing the "uncommenting" of the debug code above and repeat
   step 3 above.

   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

     if ROOT_STMT = 'create' then
       AD_DDL.create_trigger_in_schema(TARGET_SCHEMA, SQLSTMT);
     else
       AD_DDL.do_ddl       (alr_dbtrigger.APPLSYS_SCHEMA,
                            alr_dbtrigger.TARGET_APPL_SHORT_NAME,
                            STMT_TYPE,
                            SQLSTMT,
                            OBJECT_NAME);

     end if;

     -- when exception
     -- Allow caller procedure to handle exceptions.

   end RUN_SQL;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure GET_TRIGGER_NAME(
     TBL_NAME in varchar2,
     EVENT_MODE in varchar2,
     TBL_APPLID in number,
     TRIGGER_NAME out NOCOPY varchar2)
   is
      v_table_id number;
      v_trigger_name varchar2(100);
      v_table_name varchar2(100);
      v_trigger_name_orig varchar2(100);
   begin

     v_trigger_name_orig := 'ALR_' || substr(TBL_NAME, 1, 22) ||
              '_' || EVENT_MODE || 'AR';

     SELECT table_id
     INTO v_table_id
     FROM fnd_tables
     WHERE table_name = TBL_NAME
       AND application_id = TBL_APPLID;

     v_trigger_name := 'ALR_' || substr(TBL_NAME, 1, 22 - LENGTH(TO_CHAR(TBL_APPLID)) - LENGTH(TO_CHAR(v_table_id))- 2) ||
             '_' || TO_CHAR(TBL_APPLID) ||
             '_' || TO_CHAR(v_table_id) ||
             '_' || EVENT_MODE || 'AR';

     SELECT table_name
     INTO v_table_name
     FROM user_triggers
     WHERE trigger_name = v_trigger_name_orig;

     -- check whether a new trigger must be created or not
     if (v_table_name = TBL_NAME)  then
       TRIGGER_NAME := v_trigger_name_orig;
     else
       TRIGGER_NAME := v_trigger_name;
     end if;

     -- exception handling for select ... from user_triggers
     exception
       when no_data_found then  -- trigger does not exist
        TRIGGER_NAME := v_trigger_name;
    end GET_TRIGGER_NAME;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure DROP_EVENT_DB_TRIGGER (ONAME        in varchar2,
                                    TRIGGER_NAME in varchar2) is

   begin

 ALR_DEBUG('--->> Entering DROP_EVENT_DB_TRIGGER');

     /* JWSMITH  BUG 568664*/
     /* Added ONAME to drop trigger line to support MSOB */

     RUN_SQL('drop', ONAME,
             'drop trigger ' ||ONAME||'.'|| TRIGGER_NAME,
             TRIGGER_NAME);

 ALR_DEBUG('<<--- Leaving DROP_EVENT_DB_TRIGGER');

   exception
     when NONEXISTENT_TRIGGER then
       -- Ignore...
       NULL;

     when others then
       -- dbms_output.put_line( 'Error calling AD_DDL.do_ddl' );
       -- dbms_output.put_line( sqlerrm );
       raise;

   end DROP_EVENT_DB_TRIGGER;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure DELETE_EVENT_DB_TRIGGER$2(  -- prototype
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		ONAME in varchar2,
		EVENT_MODE in varchar2);


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure DELETE_EVENT_DB_TRIGGER$1(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		INSERT_FLAG in varchar2,
		UPDATE_FLAG in varchar2,
		DELETE_FLAG in varchar2) is

      cursor c1 is
	select DISTINCT
               ORACLE_USERNAME, O.ORACLE_ID
	  from FND_ORACLE_USERID O, ALR_ALERT_INSTALLATIONS I
	 where O.ORACLE_ID = NVL(OID, O.ORACLE_ID)
	   and O.ORACLE_ID = I.ORACLE_ID
           and I.APPLICATION_ID = APPL_ID
           and I.ALERT_ID = ALR_ID
      order by ORACLE_USERNAME;

   begin

 ALR_DEBUG('--->> Entering DELETE_EVENT_DB_TRIGGER$1');

      for CREC in c1 loop

	 if INSERT_FLAG = 'Y' then
-- 3933639 added if (OID is null) so triggers will be dropped for alerts
-- containing multiple installations when it should
           if (OID is null) then
               DELETE_EVENT_DB_TRIGGER$2(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,                null, crec.ORACLE_USERNAME, 'I');
-- end of 3933639, did this for the 2 following if statements as well
           else
	    DELETE_EVENT_DB_TRIGGER$2(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,
	    crec.ORACLE_ID, crec.ORACLE_USERNAME, 'I');
           end if;
	 end if;

	 if UPDATE_FLAG = 'Y' then
           if (OID is null) then
               DELETE_EVENT_DB_TRIGGER$2(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,                null, crec.ORACLE_USERNAME, 'U');
           else
	    DELETE_EVENT_DB_TRIGGER$2(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,
	    crec.ORACLE_ID, crec.ORACLE_USERNAME, 'U');
           end if;
	 end if;

	 if DELETE_FLAG = 'Y' then
           if (OID is null) then
               DELETE_EVENT_DB_TRIGGER$2(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,                null, crec.ORACLE_USERNAME, 'D');
           else
	    DELETE_EVENT_DB_TRIGGER$2(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,
	    crec.ORACLE_ID, crec.ORACLE_USERNAME, 'D');
           end if;
	 end if;

      end loop;

 ALR_DEBUG('<<--- Leaving DELETE_EVENT_DB_TRIGGER$1');

   exception
      when NONEXISTENT_TRIGGER then
	 -- Ignore...
	 NULL;

      when others then
	 FND_MESSAGE.SET_NAME('FND', 'SQL-Generic error');
	 FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE, FALSE);
	 FND_MESSAGE.SET_TOKEN('REASON', SQLERRM, FALSE);
	 FND_MESSAGE.SET_TOKEN(
		'ROUTINE', 'DROP_EVENT_DB_TRIGGER', FALSE);
	 APP_EXCEPTION.RAISE_EXCEPTION;

   end DELETE_EVENT_DB_TRIGGER$1;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure DELETE_EVENT_DB_TRIGGER$2(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,    -- never NULL here
		ONAME in varchar2,
		EVENT_MODE in varchar2) is

	TRIGGER_NAME varchar2(61);
	enabled_count number;

   begin

 ALR_DEBUG('--->> Entering DELETE_EVENT_DB_TRIGGER$2');

     -- Drop trigger if this is the only one alert;
     -- otherwise, simply attempt to disable.

      select count(*) into enabled_count
        from alr_alerts a, alr_alert_installations i
       where alert_condition_type='E'
	 and 'Y'=decode(EVENT_MODE, 'I', insert_flag,
				    'U', update_flag,
				    'D', delete_flag)
	 and table_application_id = TBL_APPLID
	 and table_name = TBL_NAME
         and i.application_id = a.application_id
         and i.alert_id = a.alert_id
         and i.oracle_id = OID;

 ALR_DEBUG('DELETE_EVENT_DB_TRIGGER$2: enabled_count='||enabled_count);

-- 3933639 added if (OID is null) so trigger will be dropped properly when
-- there are multiple installations for an alert
  if (OID is null) then
     -- Drop trigger
     GET_TRIGGER_NAME(TBL_NAME, EVENT_MODE, TBL_APPLID, TRIGGER_NAME);
     DROP_EVENT_DB_TRIGGER(ONAME, TRIGGER_NAME);
  else
     if enabled_count > 1  then
	-- One or more other alert defined: attempt to disable trigger
        -- (count includes the one record to be deleted)

        NULL;  -- to be done on POST-DELETE form trigger
        -- CREATE_EVENT_DB_TRIGGER$1(APPL_ID, ALR_ID, TBL_APPLID,
	--   TBL_NAME, OID, ONAME, EVENT_MODE, 'N');
     else
	-- Drop trigger
	GET_TRIGGER_NAME(TBL_NAME, EVENT_MODE, TBL_APPLID, TRIGGER_NAME);
	DROP_EVENT_DB_TRIGGER(ONAME, TRIGGER_NAME);
     end if;
  end if;

 ALR_DEBUG('<<--- Leaving DELETE_EVENT_DB_TRIGGER$2');

   end DELETE_EVENT_DB_TRIGGER$2;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure ALTER_EVENT_DB_TRIGGER$1(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		ONAME in varchar2,
		EVENT_MODE in varchar2,
		IS_ENABLE in varchar2) is

	TRG_NAME        varchar2(61);
	TRG_STATUS      varchar2(10);
	TRG_ACTION      varchar2(10);
	other_enabled_count	number;

   begin

 ALR_DEBUG('--->> Entering ALTER_EVENT_DB_TRIGGER$1');

      -- Default values
      TRG_STATUS := 'UNDEFINED';
      TRG_ACTION := NULL;

      -- Generate a unique trigger name
      GET_TRIGGER_NAME(TBL_NAME, EVENT_MODE, TBL_APPLID, TRG_NAME);

      -- Determine if need to ENABLE or DISABLE the trigger:
      --  enable if IS_ENABLE='Y' and trigger currently not enabled;
      --  disable if IS_ENABLE='N' and trigger currently not disabled and
      --    all other alerts are disabled.

      if IS_ENABLE = 'Y' and TRG_STATUS <> 'ENABLED' then
	 TRG_ACTION := 'ENABLE';

      elsif IS_ENABLE = 'N' and TRG_STATUS <> 'DISABLED' then

	 select count(*) into other_enabled_count
	   from alr_alerts a, alr_alert_installations i
	  where alert_condition_type='E'
	    and 'Y'=decode(EVENT_MODE, 'I', insert_flag,
				       'U', update_flag,
				       'D', delete_flag)
	    and a.enabled_flag = 'Y'
	    and i.enabled_flag = 'Y'
	    and table_application_id = TBL_APPLID
	    and table_name = TBL_NAME
            and a.application_id = i.application_id
            and a.alert_id = i.alert_id
            and i.oracle_id = OID;

 ALR_DEBUG('ALTER_EVENT_DB_TRIGGER$1: other_enabled_count='||other_enabled_count);

         if other_enabled_count=0 then
	    TRG_ACTION := 'DISABLE';
	 end if;

      end if;

      /* JWSMITH BUG 568664*/
      /* Added ONAME to alter trigger statement to support MSOB */

      if TRG_ACTION is NOT NULL then
	 RUN_SQL('alter', ONAME,
                 'alter trigger '||ONAME||'.'||TRG_NAME||' '||TRG_ACTION,
                 TRG_NAME);
      end if;

   -- no exception - let caller handle

 ALR_DEBUG('<<--- Leaving ALTER_EVENT_DB_TRIGGER$1');

   end ALTER_EVENT_DB_TRIGGER$1;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure CREATE_EVENT_DB_TRIGGER$2(
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		ONAME in varchar2,
		TBLNM in varchar2,
		EVENT_MODE in varchar2,
		TRGNAM in out NOCOPY varchar2) is

	SQLSTMT         VARCHAR2(32000);
	TRIGGER_TYPE	varchar2(30) := '';
	TRIGGER_NAME 	varchar2(61);
	TBLNM_I		varchar2(30);

   begin

 ALR_DEBUG('--->> Entering CREATE_EVENT_DB_TRIGGER$2');

       -- Default values
	TRGNAM := NULL;

       -- generate a unique trigger name
	GET_TRIGGER_NAME(TBLNM, EVENT_MODE, TBL_APPLID, TRIGGER_NAME);
	TRGNAM := TRIGGER_NAME;

       -- select trigger type
	if    EVENT_MODE = 'I' then TRIGGER_TYPE:='insert';
	elsif EVENT_MODE = 'U' then TRIGGER_TYPE:='update';
	elsif EVENT_MODE = 'D' then TRIGGER_TYPE:='delete';
        end if;

       -- submit ALECTC to the Concurrent Manager
	SQLSTMT :=
       /* JWSMITH - BUG 568664*/
       /* Added ONAME to create trigger statement to support MSOB */
         'create or replace trigger ' || ONAME || '.' || TRGNAM ||
         ' after ' || TRIGGER_TYPE || ' on ' || ONAME || '.' || TBLNM ||
         ' for each row ' ||

         'declare ' ||
             'MAILID varchar2(255):=null;' ||
             'REQID NUMBER; RETVAL boolean;' ||
             'ORGID varchar2(255);' ||
             'MORGID number;' ||
             'l_security_profile_id
fnd_profile_option_values.profile_option_value%TYPE;' ||
             'l_org_id fnd_profile_option_values.profile_option_value%TYPE;' ||
             'default_org_id fnd_profile_option_values.profile_option_value%TYPE;' ||

         'begin ' ||

          -- JWSMITH Bug 6996306 - no longer user client_infor for org_id
          -- Check if trigger is fired from enabled installations
          --'select rtrim(substr(userenv(''CLIENT_INFO''),1,10)) '||
          --  'into ORGID from dual;' ||

         -- bug 6996306
         'select nvl(mo_global.get_current_org_id, 0) into MORGID from dual;' ||
         'if (MORGID = 0) then ' ||
           ' fnd_profile.get(''XLA_MO_SECURITY_PROFILE_LEVEL'',
l_security_profile_id);' ||
             ' if (l_security_profile_id is NULL) then ' ||
                  'fnd_profile.get(''ORG_ID'', l_org_id);' ||
                  'ORGID := l_org_id;' ||
             ' else ' ||
                 'fnd_profile.get(''DEFAULT_ORG_ID'', default_org_id);' ||
                 'ORGID := default_org_id;' ||
             ' end if;' ||
         'else ' ||
           'ORGID := TO_CHAR(MORGID);' ||
         'end if;' ||

         'if ('|| DISALLOWED_CONTEXT(TBL_APPLID, TBL_NAME, OID, EVENT_MODE) ||
            ') then ' ||
            'return;' ||
          'end if;' ||

          -- Check if required profiles are present -- otherwise,
          -- assume that foreign system has fired trigger and
          -- exit quietly.

             'fnd_profile.get(''EMAIL_ADDRESS'',MAILID);' ||

             'if MAILID is null then ' ||

               'if alr_profile.value(''DEFAULT_USER_MAIL_ACCOUNT'')!=''O'' '||
               'then ' ||
                 'fnd_profile.get(''USERNAME'',MAILID);' ||
               'else ' ||
                 'fnd_profile.get(''SIGNONAUDIT:LOGIN_NAME'',MAILID);' ||
               'end if;' ||

               'if MAILID is null then ' ||
                 'MAILID:=''MAILID'';' ||
               'end if;' ||

             'end if;' ||

          -- Indicate that we're calling from a database trigger
	        'RETVAL:=FND_REQUEST.SET_MODE(DB_TRIGGER => TRUE);' ||

          -- Set IMPLICIT=ERROR.  Ignore error status code, if any.
	        'RETVAL:=FND_REQUEST.SET_OPTIONS(IMPLICIT => ''ERROR'');' ||

          -- Bug 9196056 - Submit from framework pages
         'if fnd_global.resp_id = -1 then ' ||
           'RETVAL := fnd_request.set_options(datagroup=>''Standard'');' ||
         'end if;' ||

          -- Finally submit the request
	        'REQID:=FND_REQUEST.SUBMIT_REQUEST(''ALR'',''ALECTC'',''' ||
		   TBLNM || ''',NULL,FALSE,USER,''' ||
                   TBLNM || ''',rowidtochar(:new.rowid)' ||
		   ',''' || event_mode || ''',mailid,ORGID);' ||

                'if REQID=0 then ' ||
		   'raise_application_error(-20160, FND_MESSAGE.GET);' ||
	        'end if;' ||

	  'end;';

 	RUN_SQL('create', ONAME, SQLSTMT, TRGNAM);

 ALR_DEBUG('<<--- Leaving CREATE_EVENT_DB_TRIGGER$2');

   end CREATE_EVENT_DB_TRIGGER$2;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure CREATE_EVENT_DB_TRIGGER$1(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,	-- null = all ORACLE IDs
		ONAME in varchar2,
		EVENT_MODE in varchar2,
		ENABLED_FLAG in varchar2) is

	TRGNAM varchar2(61);

   begin

 ALR_DEBUG('--->> Entering CREATE_EVENT_DB_TRIGGER$1');

      -- Create a database trigger regardless if other alerts based on
      -- this table already exist.

      CREATE_EVENT_DB_TRIGGER$2(TBL_APPLID, TBL_NAME,
                                OID, ONAME, TBL_NAME, EVENT_MODE, TRGNAM);

      if TRGNAM is not NULL then
         -- Trigger created successfully (enabled)
	 alr_dbtrigger.NUMBER_OF_TRIGGERS :=
	  alr_dbtrigger.NUMBER_OF_TRIGGERS + 1;
	 alr_dbtrigger.CREATED_TRIGGERS(alr_dbtrigger.NUMBER_OF_TRIGGERS) :=
	  TRGNAM;
	 alr_dbtrigger.CREATED_TRIG_ONAME(alr_dbtrigger.NUMBER_OF_TRIGGERS) :=
	  ONAME;
      end if;

      if ENABLED_FLAG = 'N' then
         -- May need to disable trigger

	 ALTER_EVENT_DB_TRIGGER$1(APPL_ID, ALR_ID, TBL_APPLID,
		TBL_NAME, OID, ONAME, EVENT_MODE, 'N');
      end if;

 ALR_DEBUG('<<--- Leaving CREATE_EVENT_DB_TRIGGER$1');

   end CREATE_EVENT_DB_TRIGGER$1;



   -- ======================================================================
   --
   --   PUBLIC PROCEDURE/FUNCTIONS (entry points)
   --
   -- ======================================================================

   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure CREATE_EVENT_DB_TRIGGER(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,	-- null = all ORACLE IDs
		INSERT_FLAG in varchar2,
		UPDATE_FLAG in varchar2,
		DELETE_FLAG in varchar2,
		IS_ENABLE in varchar2) is

      cursor C is
	select DISTINCT
               ORACLE_USERNAME, O.ORACLE_ID, I.ENABLED_FLAG ENABLED_INST
	  from FND_ORACLE_USERID O, ALR_ALERT_INSTALLATIONS I
	 where O.ORACLE_ID = NVL(OID, O.ORACLE_ID)
	   and O.ORACLE_ID = I.ORACLE_ID
           and I.APPLICATION_ID = NVL(APPL_ID, I.APPLICATION_ID)
           and I.ALERT_ID = NVL(ALR_ID, I.ALERT_ID)
           and ORACLE_USERNAME NOT LIKE '%_MRC'
	   and ORACLE_USERNAME NOT LIKE '%_CED'
           and ORACLE_USERNAME NOT LIKE '%OBT_AA'
      order by ORACLE_USERNAME;

      ENABLED_FINAL  varchar2(1);
      ERROR_ROLLBACK exception;

   begin

 ALR_DEBUG('--->> Entering CREATE_EVENT_DB_TRIGGER');

      INIT_GLOBALS (TBL_APPLID);

      alr_dbtrigger.NUMBER_OF_TRIGGERS:=0;
      alr_dbtrigger.BAD_ORACLE_USERNAMES:='';

      for CREC in C loop  -- process all ORACLE IDs

	 if IS_ENABLE = 'N' or crec.ENABLED_INST = 'N' then
	    ENABLED_FINAL := 'N';
	 else
	    ENABLED_FINAL := 'Y';
	 end if;

	 begin

	    if INSERT_FLAG = 'Y' then
	       CREATE_EVENT_DB_TRIGGER$1(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,
		crec.ORACLE_ID, crec.ORACLE_USERNAME, 'I', ENABLED_FINAL);
	    end if;

	    if UPDATE_FLAG = 'Y' then
	       CREATE_EVENT_DB_TRIGGER$1(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,
		crec.ORACLE_ID, crec.ORACLE_USERNAME, 'U', ENABLED_FINAL);
	    end if;

	    if DELETE_FLAG = 'Y' then
	       CREATE_EVENT_DB_TRIGGER$1(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME,
		crec.ORACLE_ID, crec.ORACLE_USERNAME, 'D', ENABLED_FINAL);
	    end if;

 ALR_DEBUG('<<--- Leaving CREATE_EVENT_DB_TRIGGER');

	 exception

	    when NONEXISTENT_TABLE or PLSQL_UNCOMPILED then

	       -- Save ORACLE ID to display to user
	       if alr_dbtrigger.BAD_ORACLE_USERNAMES is NOT NULL then
		  alr_dbtrigger.BAD_ORACLE_USERNAMES :=
		   alr_dbtrigger.BAD_ORACLE_USERNAMES||', ';
	       end if;
	       alr_dbtrigger.BAD_ORACLE_USERNAMES :=
		alr_dbtrigger.BAD_ORACLE_USERNAMES || crec.ORACLE_USERNAME;

	    when others then

	       raise ERROR_ROLLBACK;
	 end;

      end loop;

      if alr_dbtrigger.BAD_ORACLE_USERNAMES is NOT NULL then

	 raise NONEXISTENT_TABLE;
      end if;

      exception

	 when NONEXISTENT_TABLE then

	    FND_MESSAGE.SET_NAME('ALR', 'TRIGGER-NO TABLE IN ACCOUNT');
	    -- this message is uppercased in fnd_new_messages and fnd_messages
	    FND_MESSAGE.SET_TOKEN('TABLE_NAME', TBL_NAME);
	    FND_MESSAGE.SET_TOKEN('ORACLE_USERNAME',
		alr_dbtrigger.BAD_ORACLE_USERNAMES, FALSE);
	    APP_EXCEPTION.RAISE_EXCEPTION;

	 when ERROR_ROLLBACK then

	    -- Save the error code/msg first
	    FND_MESSAGE.SET_NAME('FND', 'SQL-Generic error');
	    FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE, FALSE);
	    FND_MESSAGE.SET_TOKEN('REASON', SQLERRM, FALSE);
	    FND_MESSAGE.SET_TOKEN(
		'ROUTINE', 'CREATE_EVENT_DB_TRIGGER', FALSE);

	    -- "Rollback"
	    for I in 1 .. alr_dbtrigger.NUMBER_OF_TRIGGERS loop
		DROP_EVENT_DB_TRIGGER
                  (alr_dbtrigger.CREATED_TRIG_ONAME(I),
		   alr_dbtrigger.CREATED_TRIGGERS(I));
                -- Note that table appl is the same even when
                -- dropping trigger off different accounts.
	    end loop;

	    APP_EXCEPTION.RAISE_EXCEPTION;

	 when others then

	    FND_MESSAGE.SET_NAME('FND', 'SQL-Generic error');
	    FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE, FALSE);
	    FND_MESSAGE.SET_TOKEN('REASON', SQLERRM, FALSE);
	    FND_MESSAGE.SET_TOKEN(
		'ROUTINE', 'CREATE_EVENT_DB_TRIGGER', FALSE);
	    APP_EXCEPTION.RAISE_EXCEPTION;

   end CREATE_EVENT_DB_TRIGGER;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure ALTER_EVENT_DB_TRIGGER(
		APPL_ID in number,
		ALR_ID in number,
		TBL_APPLID in number,
		TBL_NAME in varchar2,
		OID in number,
		INSERT_FLAG in varchar2,
		UPDATE_FLAG in varchar2,
		DELETE_FLAG in varchar2,
		IS_ENABLE in varchar2) is

   begin

 ALR_DEBUG('--->> Entering ALTER_EVENT_DB_TRIGGER');

     -- Any updates affecting an event alert's active ORACLE IDs or
     -- installations should cause a re-creation of the database trigger.
     -- Hence, always call CREATE_EVENT_DB_TRIGGER.

     CREATE_EVENT_DB_TRIGGER(APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME, OID,
       INSERT_FLAG, UPDATE_FLAG, DELETE_FLAG, IS_ENABLE);

 ALR_DEBUG('<<--- Leaving ALTER_EVENT_DB_TRIGGER');

   end ALTER_EVENT_DB_TRIGGER;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure DELETE_EVENT_DB_TRIGGER(
		APPL_ID in number,
		ALR_ID in number,
		OID in number) is

	TBL_APPLID      ALR_ALERTS.TABLE_APPLICATION_ID%type;
	TBL_NAME	ALR_ALERTS.TABLE_NAME%type;
	IS_INSERT	ALR_ALERTS.INSERT_FLAG%type;
	IS_UPDATE	ALR_ALERTS.UPDATE_FLAG%type;
	IS_DELETE	ALR_ALERTS.DELETE_FLAG%type;
	IS_ENABLED	ALR_ALERTS.ENABLED_FLAG%type;


   begin

 ALR_DEBUG('--->> Entering DELETE_EVENT_DB_TRIGGER');

	begin
	   select TABLE_APPLICATION_ID, TABLE_NAME, INSERT_FLAG,
	          UPDATE_FLAG, nvl(DELETE_FLAG, 'N'), ENABLED_FLAG
	     into TBL_APPLID, TBL_NAME, IS_INSERT,
	          IS_UPDATE, IS_DELETE, IS_ENABLED
             from ALR_ALERTS
            where ALERT_ID = ALR_ID AND APPLICATION_ID = APPL_ID
              and ALERT_CONDITION_TYPE = 'E';

	exception
	   when others then
	      if sql%found then
		FND_MESSAGE.SET_NAME('FND', 'SQL-Generic error');
		FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE, FALSE);
		FND_MESSAGE.SET_TOKEN('REASON', SQLERRM, FALSE);
		FND_MESSAGE.SET_TOKEN(
			'ROUTINE', 'DELETE_EVENT_DB_TRIGGER', FALSE);
	        APP_EXCEPTION.RAISE_EXCEPTION;
	      end if;
	end;

	if sql%found then

           INIT_GLOBALS (TBL_APPLID);

	   DELETE_EVENT_DB_TRIGGER$1(
	      APPL_ID, ALR_ID, TBL_APPLID, TBL_NAME, OID,
	      IS_INSERT, IS_UPDATE, IS_DELETE);

	end if;

 ALR_DEBUG('<<--- Leaving DELETE_EVENT_DB_TRIGGER');

   end DELETE_EVENT_DB_TRIGGER;


   -- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

   procedure PRE_UPDATE_EVENT_ALERT(
		APPL_ID in number,
		ALR_ID in number,
		NEW_TABLE_APPLID in number,
		NEW_TABLE_NAME in varchar2,
		NEW_INSERT_FLAG in varchar2,
		NEW_UPDATE_FLAG in varchar2,
		NEW_DELETE_FLAG in varchar2,
		NEW_IS_ENABLE in varchar2) is

      OLD_TBLAPPLID alr_alerts.table_application_id%type;
      OLD_TBLNM alr_alerts.TABLE_NAME%type;
      OLD_IFLAG char;
      OLD_UFLAG char;
      OLD_DFLAG char;
      OLD_TYPE  char;
      IS_NONEXISTENT_TABLE boolean := FALSE;

   begin

 ALR_DEBUG('--->> Entering PRE_UPDATE_EVENT_ALERT');

      begin
	 select TABLE_APPLICATION_ID, TABLE_NAME, INSERT_FLAG, UPDATE_FLAG,
	        nvl(DELETE_FLAG, 'N'), ALERT_CONDITION_TYPE
	   into OLD_TBLAPPLID, OLD_TBLNM, OLD_IFLAG, OLD_UFLAG,
	        OLD_DFLAG, OLD_TYPE
           from ALR_ALERTS
          where APPLICATION_ID=APPL_ID and ALERT_ID=ALR_ID;

      exception
	 when others then
	    if sql%found then
		FND_MESSAGE.SET_NAME('FND', 'SQL-Generic error');
		FND_MESSAGE.SET_TOKEN('ERRNO', SQLCODE, FALSE);
		FND_MESSAGE.SET_TOKEN('REASON', SQLERRM, FALSE);
		FND_MESSAGE.SET_TOKEN(
			'ROUTINE', 'PRE_UPDATE_EVENT_ALERT', FALSE);
	        APP_EXCEPTION.RAISE_EXCEPTION;
	    end if;
      end;

      begin

         -- No need to explicitly call INIT_GLOBALS;
         --   will be done in CREATE_EVENT_DB_TRIGGER().
         --   INIT_GLOBALS (TBL_APPLID);

         CREATE_EVENT_DB_TRIGGER(APPL_ID, ALR_ID,
	    NEW_TABLE_APPLID, NEW_TABLE_NAME,
	    null, NEW_INSERT_FLAG, NEW_UPDATE_FLAG, NEW_DELETE_FLAG,
	    NEW_IS_ENABLE);

      exception
	 when APPLICATION_ERROR then
	    -- catch exception to avoid aborting
	    IS_NONEXISTENT_TABLE := TRUE;
	 when others then
	    raise;
      end;

      if OLD_TYPE = 'E' then  -- :old.alert_condition_type = :new = 'Event'

	 if OLD_TBLNM = NEW_TABLE_NAME then  -- table name didn't change

	    if OLD_IFLAG = 'Y' and NEW_INSERT_FLAG = 'Y' then
	        OLD_IFLAG := 'N';
	    end if;
	    if OLD_UFLAG = 'Y' and NEW_UPDATE_FLAG = 'Y' then
	        OLD_UFLAG := 'N';
	    end if;
	    if OLD_DFLAG = 'Y' and NEW_DELETE_FLAG = 'Y' then
	        OLD_DFLAG := 'N';
	    end if;
	 end if;

	 -- Delete triggers for the old table

         -- Need to explicitly call INIT_GLOBALS since APPLID may be
         --   different than that in previous CREATE_EVENT_DB_TRIGGER().
         INIT_GLOBALS (OLD_TBLAPPLID);

         DELETE_EVENT_DB_TRIGGER$1(
	    APPL_ID, ALR_ID, OLD_TBLAPPLID, OLD_TBLNM, null,
            OLD_IFLAG, OLD_UFLAG, OLD_DFLAG);

      end if;

      if IS_NONEXISTENT_TABLE then
	 if NEW_TABLE_NAME = OLD_TBLNM then
            FND_MESSAGE.CLEAR;
         else
	    APP_EXCEPTION.RAISE_EXCEPTION;
	 end if;
      end if;

 ALR_DEBUG('<<--- Leaving PRE_UPDATE_EVENT_ALERT');

   end PRE_UPDATE_EVENT_ALERT;

begin

  ALR_DEBUG_CLEAN;

end ALR_DBTRIGGER;

/
