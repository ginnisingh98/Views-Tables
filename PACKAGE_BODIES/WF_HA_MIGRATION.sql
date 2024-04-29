--------------------------------------------------------
--  DDL for Package Body WF_HA_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_HA_MIGRATION" AS
/* $Header: WFHAMIGB.pls 120.2 2005/10/18 12:45:52 mfisher ship $ */

-- Cached value
   P_ha_maint_mode	varchar2(30)	:= Null;

--
-- Procedure
--   RESET_HA_FLAGS
--
-- Purpose
--   Resets the Migration Flags on WF_ITEMS.  Performs Commit.
--
-- Arguments: None
--
Procedure RESET_HA_FLAGS(errbuf out nocopy varchar2, retcode out nocopy number)

is

Begin
        errbuf := '';
        retcode := 0;

        Update WF_ITEMS
        Set HA_MIGRATION_FLAG = NULL
        where HA_MIGRATION_FLAG is not null;

        Commit;

exception
        when others then
           errbuf := sqlerrm;
           retcode := '2';
           FND_FILE.put_line(FND_FILE.log, errbuf);
end;


--
-- Procedure
--   SET_HA_FLAG
--
-- Purpose
--   Sets the Migration Flag on WF_ITEMS for a particular item.
--
-- Arguments:
--   Item_Type, Item_Key
--
Procedure SET_HA_FLAG(x_item_type in varchar2, x_item_key in varchar2)

is

Begin
        Update WF_ITEMS
        Set HA_MIGRATION_FLAG = 'Y'
        where HA_MIGRATION_FLAG is null
        and ITEM_TYPE = x_ITEM_TYPE
        and ITEM_KEY  = x_ITEM_KEY;
exception
        when others then
           Wf_Core.Context('Wf_Ha_Migration', 'Set_Ha_Flag',
				x_item_type, x_item_key);
	   raise;
end;

--
-- Function
--   GET_HA_MAINT_MODE
--
-- Purpose
--   Returns the Current High Availability Maintenance Mode.
--
-- Arguments: None
--
FUNCTION GET_HA_MAINT_MODE return Varchar2 is

Begin
  P_ha_maint_mode := nvl(FND_PROFILE.VALUE_SPECIFIC('APPS_MAINTENANCE_MODE'),
                         'NORMAL');
  return P_ha_maint_mode;
end;

--
-- Function
--   GET_CACHED_HA_MAINT_MODE
--
-- Purpose
--   Returns the Cacched High Availability Maintenance Mode if available,
--   other wise the current one.
--
-- Arguments: None
--
FUNCTION GET_CACHED_HA_MAINT_MODE return Varchar2 is

Begin
   if (P_ha_maint_mode is null) then return GET_HA_MAINT_MODE;
       else return P_ha_maint_mode;
   end if;
end;


--
-- Procedure
--   Export Items
--
-- Purpose
--   Shipped updated items from WF_ITEMS and associated tables to the
--   maintanence system...continues until no more txns being processed on old
--   system, and no more backlog to process.
--
-- Arguments: None
--
PROCEDURE EXPORT_ITEMS(errbuf out nocopy varchar2, retcode out nocopy number) is
   Done 	BOOLEAN 	:= FALSE;
   My_Mode      Varchar2(30)    := Null;
   itype        Varchar2(8);
   ikey		Varchar2(240);
   kount	number		:= 0;
   ekount	number		:= 0;
   myparams     wf_parameter_list_t;

Begin

   errbuf := '';
   retcode := '0';

   -- Notice that these loops are constructed so that in order to fall through
   -- the following MUST OCCUR IN ORDER: 1) use get_ha_maint mode to discover
   -- that we are in fuzzy phase; 2) re-open intem cursor; 3) find no rows.
   -- This is to ensure that we don't miss a last moment txn.

   While (Done = FALSE) LOOP
        My_Mode := get_ha_maint_mode;


        -- rumor has it that there is a new db feature to only grab rows
	-- that are not locked....we may want to use two seperate selects
	-- here: one using the feature for pre-fuzzy fast processing and then
        -- the one we currently use for completeness during fuzzy time.

        -- We aren't using a cursor fetch loop here as we are more
        -- worried about not holding locks than about local efficiency
        begin
              select ITEM_TYPE, ITEM_KEY
                into itype, ikey
                from WF_ITEMS
               where HA_MIGRATION_FLAG = 'Y'
                 and rownum <2
                 for update of HA_MIGRATION_FLAG;

               kount := 1;

	exception
               when no_data_found then kount := 0;
        end;

        if (kount = 1) then
           /* clear the flag */
           update WF_ITEMS
               Set HA_MIGRATION_FLAG = NULL
               where ITEM_TYPE = itype
               and ITEM_KEY = ikey;

           /* See if we are going to truncate a business event */
           select count(*)
           into ekount
           from wf_item_attribute_values
	   where ITEM_TYPE = itype
             and ITEM_KEY = ikey
             and EVENT_VALUE is not null;

           /* push the data */
           myparams := wf_parameter_list_t();
           wf_event.AddParameterToList(p_name =>'ECX_PARAMETER1',
				       p_value => itype,
				       p_parameterlist => myparams);

           wf_event.AddParameterToList(p_name =>'ECX_PARAMETER2',
                                       p_value => ikey,
                                       p_parameterlist => myparams);

           WF_Event.Raise(p_event_name => 'oracle.apps.wf.replay.wf.item',
			  p_event_key => SUBSTRB(itype || ':' || ikey, 1, 240),
			  p_parameters => myparams);

           myparams.DELETE;
        end if;

	-- unlock the rows
	commit;

        -- Print error if necessary
        if (ekount > 0) then
	    FND_FILE.put_line(FND_FILE.log,
		'Warning: This version of HA doesn''t support migration of business events');
	    FND_FILE.put_line(FND_FILE.log,
		'         WF_ITEM [' || itype  || ':' || ikey || '] has been truncated.');
        end if;

        if ((kount = 0) and (My_Mode = 'DISABLED')) then
               Done := TRUE;
        end if;

   end LOOP outer;

exception
        when others then
           errbuf := sqlerrm;
           retcode := '2';
           FND_FILE.put_line(FND_FILE.log, errbuf);

end;

--
-- Procedure
--   FixSubscriptions
--
-- Purpose
--   Shipped updated items from WF_ITEMS and associated tables to the
--   maintanence system...continues until no more txns being processed on old
--   system, and no more backlog to process.
--
-- Arguments:
--      WF_Schema in varchar2 - Schema for FND.
--      Clone_DBLink in varchar2 - DBLink for cloned DB.
--
PROCEDURE FixSubscriptions(WF_Schema    in varchar2 default 'APPLSYS',
			   Clone_DBLink in varchar2) is

   myagent	 	sys.aq$_agent;
   address_string 	varchar2(1024) 	:= 'WF_REPLAY_IN';
   kount		number;
   WF_Schema2		varchar2(1024);

   sql_stmt varchar2(2000);

   pragma AUTONOMOUS_TRANSACTION;

begin
   /* prevent (unlikely) possibility of sql injection */
   select count(*)
     into kount
     from sys.user$ t
    where t.name = WF_Schema;

   if (kount < 1) then
	WF_Schema2 := 'INVALID_SCHEMA_THROW_ERROR';
   else
	WF_Schema2 := WF_Schema;
   end if;

   /* insert dummy subscriber to make sure view works */
   myagent := sys.aq$_agent('MyDummyAgent',NULL, NULL);

   DBMS_AQADM.ADD_SUBSCRIBER(queue_name =>WF_Schema2 || '.WF_REPLAY_OUT',
                	     subscriber=>myagent);

   /* Remove all subscribers */
   sql_stmt := 'declare ';

   sql_stmt := sql_stmt || 'CURSOR C1 is select NAME, ADDRESS, PROTOCOL ';
   sql_stmt := sql_stmt || ' from '||WF_Schema2||'.aq$WF_REPLAY_OUT_S ';
   sql_stmt := sql_stmt || ' where QUEUE=''WF_REPLAY_OUT'';';

   sql_stmt := sql_stmt || ' begin ';
   sql_stmt := sql_stmt || '   for c1rec in c1 loop ';

   sql_stmt := sql_stmt || 'DBMS_AQADM.REMOVE_SUBSCRIBER(queue_name => ''';
   sql_stmt := sql_stmt || WF_Schema2 || '.WF_REPLAY_OUT'', ';
   sql_stmt := sql_stmt || 'subscriber=>sys.aq$_agent(';
   sql_stmt := sql_stmt || 'c1rec.NAME, c1rec.ADDRESS, c1rec.PROTOCOL));';

   /* turn off propogation for old subscriber if active */
   sql_stmt := sql_stmt || '   begin ';
   sql_stmt := sql_stmt || '   if instr(c1rec.ADDRESS,''@'') > 0 then ';
   sql_stmt := sql_stmt || '     dbms_aqadm.unschedule_propagation (';
   sql_stmt := sql_stmt || '        queue_name => ''' ||
					WF_Schema2||'.WF_REPLAY_OUT'', ';
   sql_stmt := sql_stmt || '        destination => ' ||
         'substr(c1rec.ADDRESS, instr(c1rec.ADDRESS,''@'') + 1) ); ';
   sql_stmt := sql_stmt || '   end if; ';
   sql_stmt := sql_stmt || '   exception when others then null; ';
   sql_stmt := sql_stmt || ' end; ';


   sql_stmt := sql_stmt || ' end loop; ';
   sql_stmt := sql_stmt || ' end;';

   EXECUTE IMMEDIATE sql_stmt ;

   /* just to be safe turn off local prop */
   begin
    dbms_aqadm.unschedule_propagation (
        queue_name => WF_Schema2||'.WF_REPLAY_OUT',
        destination =>null
       );
   exception
    when others then
      null;
   end;

   /* just to be safe turn off prop to new destination */
   begin
    if (Clone_DBLink is not null) then
      dbms_aqadm.unschedule_propagation (
        queue_name => WF_Schema2||'.WF_REPLAY_OUT',
        destination =>Clone_DBLink
       );
    end if;
   exception
    when others then
      null;
   end;

   /* turn on prop to new clone */
   dbms_aqadm.schedule_propagation (
      queue_name => WF_Schema2||'.WF_REPLAY_OUT',
	destination => 'Clone_DBLink', duration => 60,
        next_time => 'SYSDATE + 1/24/60/6');

   address_string := WF_Schema2 || '.' || address_string;

   if (Clone_DBLink is not null) then
      address_string := address_string || '@' || Clone_DBLink;
   end if;

   myagent := sys.aq$_agent('WF_REPLAY_IN', address_string, 0);
   dbms_aqadm.add_subscriber(queue_name =>WF_Schema2||'.WF_REPLAY_OUT',
                          subscriber=>myagent);

commit;
end;


END WF_HA_MIGRATION;

/
