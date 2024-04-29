--------------------------------------------------------
--  DDL for Package Body MSC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_UTIL" AS
/* $Header: MSCUTILB.pls 120.24.12010000.30 2016/07/28 09:38:34 yangu ship $  */

-- GLOBAL VARIABLES IN BODY
APPS_SCHEMA VARCHAR2(30);
G_CAT_SET_ID   NUMBER := NULL ;
--
v_chr34  VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(34);
v_deprecatedMVList TblNmTblTyp:=
                 TblNmTblTyp( 'BOM_CTO_ORDER_DMD_SN');
v_deprecatedMVSchemaList TblNmTblTyp:=
                 TblNmTblTyp( msc_util.G_BOM_SCHEMA );

FUNCTION Check_MSG_Level(pType IN  NUMBER) RETURN BOOLEAN
IS
BEGIN
     IF (bitand(G_CL_DEBUG, pType) > 0) THEN RETURN TRUE;  END IF;
     RETURN FALSE;
END Check_MSG_Level;

PROCEDURE Print_Msg (buf IN  VARCHAR2)
IS
BEGIN
     FND_FILE.PUT_LINE(FND_FILE.LOG, buf);  -- add a line of text to the log file and
EXCEPTION
  WHEN OTHERS THEN
    NULL; --suppressing the exceptions
END Print_Msg;

/*-----------------------------------------------------------------------------
Procedure	: LOG_MSG

Parameters	: p_Type (IN) - number which holds the bebug type
		  of the message to be printed

		  buf (IN) - string which consists of the message to be printed

Description	: this procedure will print the message to the log file after
   checking the current debug status of collections (G_CL_DEBUG)
-----------------------------------------------------------------------------*/
PROCEDURE LOG_MSG(
pType             IN         NUMBER,
buf               IN         VARCHAR2
)
IS
BEGIN
  IF Check_MSG_Level(pType) THEN
     Print_Msg (TO_CHAR(sysdate,'DD-MON HH24:MI:SS') || ' : ' || buf);
  END IF;
END LOG_MSG;

Procedure print_query( p_query        in varchar2,
                       p_display_type in number default 1 )
is
    l_theCursor     integer default dbms_sql.open_cursor;
    l_columnValue   varchar2(4000);
    l_status        integer;
    l_descTbl       dbms_sql.desc_tab;
    l_colCnt        number;
    buff            varchar2(4000);
begin

    dbms_sql.parse(  l_theCursor,  p_query, dbms_sql.native );
    dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );

    for i in 1 .. l_colCnt loop
        dbms_sql.define_column
        (l_theCursor, i, l_columnValue, 4000);
    end loop;

    l_status := dbms_sql.execute(l_theCursor);
    IF p_display_type = 1 THEN
        --Print one row per line
        buff := '';
        for i in 1 .. l_colCnt loop
             buff := buff ||  rpad( l_descTbl(i).col_name, 30 ) ;
        end loop;
        Print_Msg( buff );Print_Msg(' ');
        while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        buff := '';
            for i in 1 .. l_colCnt loop
                dbms_sql.column_value
                ( l_theCursor, i, l_columnValue );
                buff := buff ||( rpad( l_columnValue, 30 ) );
            end loop;
            Print_Msg( buff );
            --dbms_output.put_line( '-----------------' );
        end loop;
    ELSE
        --Print one column per line
        while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
            for i in 1 .. l_colCnt loop
                dbms_sql.column_value( l_theCursor, i, l_columnValue );
                Print_Msg( rpad( l_descTbl(i).col_name, 30 ) || ': ' ||  l_columnValue );
            end loop;
            Print_Msg( '-----------------' );
        end loop;
    END IF;
end;

PROCEDURE print_top_wait(pElaTime  NUMBER DEFAULT 0) IS
BEGIN
    IF ( Check_MSG_Level(G_LVL_PERFDBG_2) OR  (Check_MSG_Level(G_LVL_PERFDBG_1) AND pElaTime > G_PERF_STAT_TRSHLD_TIME) )THEN
        Print_Msg('************************************************************');
        Print_Msg('Top WAIT events');
        Print_Msg('------------------------------------------------------------');
        print_query('SELECT SID, EVENT,seconds_waited FROM
                        (SELECT SID, EVENT, TIME_WAITED/100 seconds_waited
                         FROM v$session_event
                         WHERE SID=' || G_CURRENT_SESSION_ID || '
                         ORDER BY sid, TIME_WAITED DESC )
                     WHERE ROWNUM < 10');
        Print_Msg('************************************************************');
    END IF;
END print_top_wait;

PROCEDURE print_cum_stat(pElaTime  NUMBER DEFAULT 0) IS
BEGIN
    IF ( Check_MSG_Level(G_LVL_PERFDBG_2) OR  (Check_MSG_Level(G_LVL_PERFDBG_1) AND pElaTime > G_PERF_STAT_TRSHLD_TIME) )THEN
        Print_Msg('************************************************************');
        Print_Msg('Cummilative stats for this session');
        Print_Msg('------------------------------------------------------------');
        print_query( 'SELECT A.SID, A.STATISTIC#, B.NAME, A.VALUE
                        FROM V$SESSTAT A, V$STATNAME B  --V$MYSTAT
                        WHERE A.SID=' || G_CURRENT_SESSION_ID || '
                        AND A.STATISTIC# = B.STATISTIC#
                        AND B.NAME IN (''recursive calls'', ''recursive cpu usage'',
                                       ''session logical reads'',''CPU used when call started'',
                                       ''CPU used by this session'', ''DB time'',
                                       ''session uga memory'',''IPC CPU used by this session'',
                                       ''db block gets'', ''consistent gets'',''physical reads'')');
        Print_Msg('************************************************************');
    END IF;
END print_cum_stat;

PROCEDURE print_bad_sqls(pElaTime  NUMBER DEFAULT 0) IS
BEGIN
    Print_Msg('************************************************************');
    Print_Msg('Bad sqls for this session');
    Print_Msg('------------------------------------------------------------');

    Print_Msg('************************************************************');
END print_bad_sqls;
 -- Added Legacy for Omron, forecase, mds, mps --
PROCEDURE print_pull_params(pINSTANCE_ID IN NUMBER) IS
BEGIN
  IF Check_MSG_Level(G_LVL_STATUS) THEN
       Print_Msg('************************************************************');
       Print_Msg('Parameters selected for planning data pull:');
       Print_Msg('------------------------------------------------------------');
        print_query( Q'[
            SELECT
      decode(delete_ods_data          ,1,'YES','NO') "Purge collected data",
      org_group                                      "Org Group",
      threshold                                      "Time out",
       decode(supplier_capacity        ,2,'NO'
                                      ,3,'YES, But retain CP data'
                                      ,1,'YES, Replace all values') "Approved supplier lists",
      decode(atp_rules                ,1,'YES','NO') "Atp Rules",
      decode(bom                      ,1,'YES','NO') "BOM/Routings/Resources",
      decode(bor                      ,1,'YES','NO') "Bill of Resources",
      decode(calendar_check           ,1,'YES','NO') "Calendars",
      decode(demand_class             ,1,'YES','NO') "Demand Classes",
      decode(ITEM_SUBSTITUTES         ,1,'YES','NO') "End Item Substitutions",
      decode(forecast                 ,1,'YES'
                                      ,2,'NO'
                                      ,3,'LEGACY_FLAT_FILE'
                                      ,4,'LEGACY_PRE_STAGED') "Forecast",
      decode(item                     ,1,'YES','NO') "Item",
      decode(kpi_targets_bis          ,1,'YES','NO') "KPI Targets BIS",
      decode(mds                      ,1,'YES'
                                      ,2,'NO'
                                      ,3,'LEGACY_FLAT_FILE'
                                      ,4,'LEGACY_PRE_STAGED') "Master Demand Schedule",
      decode(mps                      ,1,'YES'
                                      ,2,'NO'
                                      ,3,'LEGACY_FLAT_FILE'
                                      ,4,'LEGACY_PRE_STAGED') "Master Production Schedule",
      decode(oh                       ,1,'YES','NO') "OnHand",
      decode(parameter                ,1,'YES','NO') "Planning Parameters",
      decode(planners                 ,1,'YES','NO') "Planners",
      decode(po_receipts              ,1,'YES','NO') "po receipts",
      decode(projects                 ,1,'YES','NO') "Projects / Tasks",
      decode(po                       ,1,'YES','NO') "PO/PR",
      decode(reservations             ,1,'YES','NO') "Reservations",
      decode(nra                      ,1,'Collect Existing Data'
                                      ,2,'Do not Collect Data'
                                      ,3,'Regenerate and Collect Data') "Resource Availability",
      decode(safety_stock             ,1,'YES','NO') "Safety Stock",
      decode(sales_order              ,1,'YES','NO') "Sales Order",
      decode(sourcing_history         ,1,'YES','NO') "Sourcing History",
      decode(sourcing                 ,1,'YES','NO') "Sourcing Rules",
      decode(sub_inventories          ,1,'YES','NO') "Sub Inventories",
      decode(supplier_response        ,1,'YES','NO') "Supplier Response",
      decode(customer                 ,1,'YES','NO') "Customer",
      decode(supplier                 ,1,'YES','NO') "Supplier",
      decode(trip                     ,1,'YES','NO') "Transportation details",
      decode(unit_numbers             ,1,'YES','NO') "Unit Numbers",
      decode(uom                      ,1,'YES','NO') "Units of Measure",
      decode(user_comp_association    ,3,'Crete Users and Enable Company Association'
                                      ,2,'Enable User Company Association'
                                      ,1,'NO') "User Comp Association",
      decode(user_supply_demand       ,1,'YES','NO') "User Supplies and Demand",
      decode(wip                      ,1,'YES','NO') "Work in Process",
      decode(sales_channel            ,1,'YES','NO') "sales channel",
      decode(fiscal_calendar          ,1,'YES','NO') "fiscal calendar",
      decode(INTERNAL_REPAIR          ,1,'YES','NO') "Internal Repair Orders",
      decode(EXTERNAL_REPAIR          ,1,'YES','NO') "External Repair Orders",
      decode(payback_demand_supply    ,1,'YES','NO') "Payback demand/supply",
      decode(currency_conversion      ,1,'YES','NO') "Currency conversion",
      decode(delivery_Details         ,1,'YES','NO') "Delivery Details",
      decode(ibuc_history             ,1,'YES','NO') "Install Base under Contracts" ,
      decode(notes_attach            ,1,'YES','NO') "Notes (Attachments)",
      decode(eAM_info            ,1,'YES','NO') "eAM Info" ,                   /* USAF*/
      decode(eAM_forecasts            ,1,'YES','NO') "eAM Forecasts",
      decode(cmro_forecasts           ,1,'YES','NO') "CMRO Forecasts",
      decode(cmro           ,1,'YES','NO') "CMRO Data" ,
      eam_fc_st_date " eAm Forecasts Start date",
      eam_fc_end_date " eAm Forecasts end date" ,
      cmro_fc_st_date " CMRO Forecasts Start date",
      cmro_fc_end_date " CMRO Forecasts end date" ,
      decode(osp_supply ,1,'YES','NO') "CMRO OSP Supply",
      decode(cmro_closed_wo ,1,'YES','NO') "Closed Visit Workorders"
     FROM msc_coll_parameters
     WHERE instance_id = ]' || pINSTANCE_ID , 2);
     Print_Msg('************************************************************');
 END IF;
END print_pull_params;

PROCEDURE print_ods_params(pRECALC_SH IN NUMBER, pPURGE_SH  IN NUMBER) IS
BEGIN
   IF Check_MSG_Level(G_LVL_STATUS) THEN
       Print_Msg('************************************************************');
       Print_Msg('Parameters selected for planning data pull:');
       Print_Msg('------------------------------------------------------------');
       IF pRECALC_SH = MSC_UTIL.SYS_YES THEN
          Print_Msg('Recalculate Sourcing History: YES ' );
       ELSE
          Print_Msg('Recalculate Sourcing History: NO ' );
       END IF;
       IF pPURGE_SH = MSC_UTIL.SYS_YES THEN
          Print_Msg('Purge Sourcing History      : YES ' );
       ELSE
          Print_Msg('Purge Sourcing History      : NO ' );
       END IF;
       Print_Msg('************************************************************');
   END IF;
END;

PROCEDURE print_trace_file_name(pReqID  NUMBER) IS
BEGIN
    IF  Check_MSG_Level(G_LVL_PERFDBG_2)THEN
        Print_Msg('************************************************************');
        Print_Msg('Possible Trace file names and location');
        Print_Msg('------------------------------------------------------------');
        Begin  --Bug 23759253
        print_query(  'SELECT request_id           ,
                              oracle_Process_id Trace_id ,
                              req.enable_trace Trace_Flag,
                              dest.value||''/''||lower (dbnm.value) ||''_ora_''||oracle_process_id||''.trc'' Trace_File_Name
                               FROM fnd_concurrent_requests req,
                              v$session ses                    ,
                              v$process PROC                   ,
                              v$parameter dest                 ,
                              (select sys_context(''USERENV'',''DB_NAME'') value from dual) dbnm                 ,
                              fnd_concurrent_programs_vl prog  ,
                              fnd_executables execname
                              WHERE req.oracle_process_id    = proc.spid(+)
                              AND proc.addr                  = ses.paddr(+)
                              AND dest.name                  = ''user_dump_dest''
                              AND req.concurrent_program_id  = prog.concurrent_program_id
                              AND req.program_application_id = prog.application_id
                              AND prog.application_id        = execname.application_id
                              AND prog.executable_id         = execname.executable_id
                              AND request_id                IN ( select request_id from fnd_concurrent_requests req where request_id = '||  pReqID || ' or req.parent_request_id = '|| pReqID  ||' )' );
      Exception when others then
         Print_Msg('Unable to get the trace file names for request IDs: '|| pReqID);
         Print_Msg(SQLERRM);
      end;
      Print_Msg('************************************************************');
    END IF;
END print_trace_file_name;

/*-----------------------------------------------------------------------------
Procedure	: MSC_SET_DEBUG_LEVEL

Parameters	: pType (IN) - new debug status that needs to be set.

Description	: This procedure adds the debug mode 'pType', if it is not already set.
-----------------------------------------------------------------------------*/

PROCEDURE MSC_SET_DEBUG_LEVEL(pType  IN   NUMBER)
IS
BEGIN
  IF (bitand(G_CL_DEBUG, pType) = 0) THEN
      G_CL_DEBUG := G_CL_DEBUG + pType;
      LOG_MSG(G_LVL_STATUS, 'Debug level added :' || pType );
  END  IF;
END MSC_SET_DEBUG_LEVEL;



-- log messaging if debug is turned on
PROCEDURE MSC_DEBUG( buf  IN  VARCHAR2)
IS
BEGIN
  -- if MSC:Debug profile is not set return
  IF (G_MSC_DEBUG <> 'Y') THEN
    return;
  END IF;
  -- add a line of text to the log file and

  FND_FILE.PUT_LINE(FND_FILE.LOG, buf);

  return;

EXCEPTION
  WHEN OTHERS THEN
    return;
END MSC_DEBUG;

-- log messaging irrespective of whether debug is turned on or off
PROCEDURE MSC_LOG( buf  IN  VARCHAR2)
IS
BEGIN

  -- log the message
  FND_FILE.PUT_LINE(FND_FILE.LOG, buf);

  return;

EXCEPTION
  WHEN OTHERS THEN
    return;
END MSC_LOG;

-- out messaging
PROCEDURE MSC_OUT(buf IN VARCHAR2)
IS
BEGIN
    -- add a line of text to the output file and
	-- add the line terminator
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, buf);
	FND_FILE.NEW_LINE(FND_FILE.OUTPUT,1);

    return;

EXCEPTION
  WHEN OTHERS THEN
	return;
END MSC_OUT;


PROCEDURE compare_index(
p_table_name		IN		VARCHAR2,
p_index_name		IN		VARCHAR2,
p_column_list		IN		MSC_UTIL.char30_arr,
x_create_index		OUT   NOCOPY    BOOLEAN,
x_partitioned		OUT   NOCOPY 	BOOLEAN
)
IS

l_column_name		VARCHAR2(30);
l_partitioned		VARCHAR2(30);

v_msc_schema     VARCHAR2(32);
lv_retval        boolean;
lv_dummy1        varchar2(32);
lv_dummy2        varchar2(32);


CURSOR c_ind_columns(p_owner varchar2)
IS
SELECT	column_name
FROM	all_ind_columns
WHERE	index_owner=p_owner
AND     table_name = p_table_name
AND	index_name = p_index_name
ORDER BY column_position;


BEGIN

    lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2,v_msc_schema);
    x_create_index := FALSE;
    x_partitioned := FALSE;

    BEGIN
	SELECT	partitioned
	INTO	l_partitioned
	FROM	all_indexes
	WHERE   owner=v_msc_schema
        AND     table_name = p_table_name
	AND     index_name = p_index_name;

        --dbms_output.put_line('l_partitioned : ' || l_partitioned);
	IF l_partitioned = 'YES' THEN
	   x_partitioned := TRUE;
	ELSIF l_partitioned = 'NO' THEN
	   x_partitioned := FALSE;
	END IF;
    EXCEPTION
	WHEN no_data_found THEN
	     x_partitioned := FALSE;
    END;

    OPEN c_ind_columns(v_msc_schema);

    FOR i IN p_column_list.FIRST..p_column_list.COUNT LOOP
	FETCH c_ind_columns INTO l_column_name;
	EXIT WHEN c_ind_columns%NOTFOUND;

        --dbms_output.put_line('l_column_name : ' || l_column_name);
	IF l_column_name <> UPPER(p_column_list(i)) THEN
	   x_create_index := TRUE;
	   EXIT;
	END IF;
    END LOOP;

    --dbms_output.put_line('ROWCOUNT : ' || c_ind_columns%ROWCOUNT);
    IF c_ind_columns%ROWCOUNT = 0 THEN
       x_create_index := TRUE;
       --dbms_output.put_line('x_drop_index is FALSE');
    END IF;
    CLOSE c_ind_columns;

EXCEPTION
    WHEN others THEN
	IF c_ind_columns%ISOPEN THEN
	   CLOSE c_ind_columns;
	END IF;
        ---- bug 2234098 change error code from 21001 to 20001
	RAISE_APPLICATION_ERROR(-20001, 'MSC_UTIL.COMPARE_INDEX: Error while checking the index attributes: ' || SQLERRM);
END compare_index;



/* ======== Create Snap Log========== */
PROCEDURE CREATE_SNAP_LOG( p_schema         in VARCHAR2,
                           p_table          in VARCHAR2,
		           p_applsys_schema IN VARCHAR2)
IS
   v_sql_stmt        VARCHAR2(6000);
BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Creating Snapshot Log for ' ||p_table||' ...');

v_sql_stmt:=
' CREATE SNAPSHOT LOG ON '||p_schema ||'.'||p_table||'  WITH ROWID ' ;

  ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => p_schema,
                 statement_type => AD_DDL.CREATE_TABLE,
                 statement => v_sql_stmt,
                 object_name => p_table);

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Snapshot Log for  ' ||p_table||' successfully created...');

EXCEPTION
     WHEN OTHERS THEN

        IF SQLCODE IN (-12000) THEN
			    /*Snapshot Log already EXISTS*/
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Snapshot Log on  ' ||p_table||' already exists...');

        ELSIF SQLCODE IN (-00942) THEN
			    /*Base Table does not exist*/
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Table '||p_table||' does not exist...');
        ELSE
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
          RAISE_APPLICATION_ERROR(-20001, 'Snapshot Log Creation on '|| p_table||' failed : ' || sqlerrm);
       END IF;
END CREATE_SNAP_LOG; --create_snap Log
/* ======== Create Snap Log========== */

/* ======== Overloading Create Snap Log========== */
PROCEDURE CREATE_SNAP_LOG( p_schema         in VARCHAR2,
                           p_table          in VARCHAR2,
		           p_applsys_schema IN VARCHAR2,
               p_appl_id in number)
IS
   v_sql_stmt        VARCHAR2(6000);
   lappshortname     VARCHAR2(30);
BEGIN

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Creating Snapshot Log for ' ||p_table||' ...');

 SELECT application_short_name
  into lappshortname
  FROM   fnd_application
  WHERE  application_id = p_appl_id;

v_sql_stmt:=
' CREATE SNAPSHOT LOG ON '||p_schema ||'.'||p_table||'  WITH ROWID ' ;

  ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => lappshortname,
                 statement_type => AD_DDL.CREATE_TABLE,
                 statement => v_sql_stmt,
                 object_name => p_table);

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Snapshot Log for  ' ||p_table||' successfully created...');

EXCEPTION
     WHEN OTHERS THEN

        IF SQLCODE IN (-12000) THEN
			    /*Snapshot Log already EXISTS*/
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Snapshot Log on  ' ||p_table||' already exists...');

        ELSIF SQLCODE IN (-00942) THEN
			    /*Base Table does not exist*/
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Table '||p_table||' does not exist...');
        ELSE
          MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
          RAISE_APPLICATION_ERROR(-20001, 'Snapshot Log Creation on '|| p_table||' failed : ' || sqlerrm);
       END IF;
END CREATE_SNAP_LOG; --create_snap Log
/* ======== Overloading Create Snap Log========== */

PROCEDURE GET_STORAGE_PARAMETERS( p_table_name       IN          VARCHAR2,
				  p_schema           IN          VARCHAR2,
				  v_table_space      OUT NOCOPY  VARCHAR2,
				  v_index_space      OUT NOCOPY  VARCHAR2,
				  v_storage_clause   OUT NOCOPY  VARCHAR2)
IS
  lv_initial_extent     NUMBER;
  lv_next_extent        NUMBER;
  lv_extent_management  VARCHAR2(10);
  lv_is_object_registered VARCHAR2(10);
  lv_ts_exists VARCHAR2(10);
  lv_is_new_ts_mode VARCHAR2(10);
BEGIN
   ad_tspace_util.is_new_ts_mode(lv_is_new_ts_mode);
   IF(upper(lv_is_new_ts_mode) = 'N') THEN-- code for old tabel space structure

   	SELECT alt.tablespace_name,
       	       alt.initial_extent,
               alt.next_extent ,
               dt.extent_management
         INTO  v_table_space,
               lv_initial_extent,
               lv_next_extent ,
               lv_extent_management
         FROM  ALL_TABLES  alt,
               DBA_TABLESPACES dt
         WHERE  alt.table_name = upper(p_table_name)
               AND    alt.owner = upper(p_schema)
                AND    alt.tablespace_name = dt.tablespace_name ;
        BEGIN
         SELECT TABLESPACE_NAME
         INTO   v_index_space
         FROM   ALL_INDEXES
         WHERE  table_name = upper(p_table_name)
                and    owner = upper(p_schema)
                 and    rownum = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_index_space := v_table_space;
        END;

 ELSE --- start of code for new tablespace structure

   	 ad_tspace_util.get_object_tablespace(
                         x_product_short_name   => p_schema,
                         x_object_name          => p_table_name,
                         x_object_type          => 'TABLE',
                         x_index_lookup_flag    => 'N',
                         x_validate_ts_exists   => 'Y',
                         x_is_object_registered => lv_is_object_registered,
                         x_ts_exists            => lv_ts_exists,
                         x_tablespace           => v_table_space);
     	ad_tspace_util.get_object_tablespace(
                         x_product_short_name   => p_schema,
                         x_object_name          => p_table_name,
                         x_object_type          => 'TABLE',
                         x_index_lookup_flag    => 'Y',
                         x_validate_ts_exists   => 'Y',
                         x_is_object_registered => lv_is_object_registered,
                         x_ts_exists            => lv_ts_exists,
                         x_tablespace           => v_index_space);

   	SELECT alt.initial_extent,
               alt.next_extent ,
               dt.extent_management
   	INTO   lv_initial_extent,
               lv_next_extent ,
               lv_extent_management
   	FROM   ALL_TABLES  alt,
               DBA_TABLESPACES dt
   	WHERE  alt.table_name = upper(p_table_name)
   	       AND    alt.owner = upper(p_schema)
               AND    alt.tablespace_name = dt.tablespace_name ;
	IF v_index_space is NULL THEN
     		v_index_space := v_table_space;
  	END IF;

  END IF;

 IF (lv_extent_management = 'DICTIONARY')  THEN
    v_storage_clause := ' STORAGE (INITIAL '||lv_initial_extent||' NEXT '||lv_next_extent
		      || ' PCTINCREASE 0 ) '||' USING INDEX TABLESPACE '||v_index_space;

 ELSE       ---locally managed tablespace
    v_storage_clause := '  ';
 END IF;

EXCEPTION
   WHEN OTHERS THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
        raise_application_error(-20001, 'Error in Getting Storage Parameters : ' || sqlerrm);
END GET_STORAGE_PARAMETERS;


/* ======== Create Snapshot ========== */
FUNCTION CREATE_SNAP (p_schema         IN VARCHAR2,
                      p_table          IN VARCHAR2,
                      p_object         IN VARCHAR2,
                      p_sql_stmt       IN VARCHAR2,
		      p_applsys_schema IN VARCHAR2,
		      p_logging        IN VARCHAR2 DEFAULT 'NOLOGGING',
  		      p_parallel_degree IN NUMBER DEFAULT 1,
            p_error IN VARCHAR2 DEFAULT NULL )
RETURN BOOLEAN IS
   v_sql_stmt        VARCHAR2(6000);
   lv_pctg           NUMBER:= 10;
   lv_deg            NUMBER:= 4;
   v_logging_stmt    VARCHAR2(6000);
   lv_appl_short_nm  VARCHAR2(30);

BEGIN -- Snapshot

  v_logging_stmt := 'ALTER MATERIALIZED VIEW '||p_schema||'.'||p_object
                       ||' '||p_logging ||' PARALLEL '|| p_parallel_degree;

  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Creating Snapshot for '||p_table||' ...');

        SELECT application_short_name
        INTO lv_appl_short_nm
        FROM fnd_application
       WHERE application_id=724;

  	IF p_schema = MSC_UTIL.G_APPS_SCHEMA THEN

	    EXECUTE IMMEDIATE p_sql_stmt;

	  ELSE

      ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => lv_appl_short_nm,
                 statement_type => AD_DDL.CREATE_TABLE,
                 statement => p_sql_stmt,
                 object_name => p_object);
    END IF;


  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Snapshot for '||p_table||' succesfully created...');

  FND_STATS.gather_table_stats(p_schema,p_object,lv_pctg, lv_deg);

  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Gathered Statistics for the Snapshot '||p_object||' succesfully ...');

  EXECUTE IMMEDIATE v_logging_stmt;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Altering Snapshot : '||p_object);


RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
   IF SQLCODE IN (-12006) THEN
		   /*Snapshot already EXISTS*/
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Snapshot on '||p_table||' already exists...');
       EXECUTE IMMEDIATE v_logging_stmt;
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Altering Snapshot : '||p_object);
       RETURN TRUE;
   ELSIF SQLCODE IN (-01749) THEN
		   /*you may not GRANT/REVOKE privileges to/from yourself*/
		   /* snapshot created in apps schema*/
		   RETURN TRUE;
   ELSIF instr(p_error,','||trim(SQLCODE)||',')>0 THEN /*6501625*/
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, sqlerrm);
        RETURN FALSE;
   ELSE
       -- no need to log the error message twice, hence commenting.
       -- The following error will be logged in the place from where create_snap is called.
       --MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
       RAISE_APPLICATION_ERROR(-20001, 'Snapshot Creation on '|| p_table||' failed : ' || sqlerrm);
   END IF;

END CREATE_SNAP ; --Snapshot
/* ======== Snapshot ========== */

/* INDEX */
/* p_schema refers to the schema containing the index*/
PROCEDURE CREATE_INDEX (p_schema         IN VARCHAR2,
                        p_sql_stmt       IN VARCHAR2,
                        p_object         IN VARCHAR2,
		        p_applsys_schema IN VARCHAR2)
IS
   v_sql_stmt        VARCHAR2(6000);
   lv_schema    VARCHAR2(30);
   lv_appl_short_nm  VARCHAR2(30);
BEGIN -- Index

      SELECT application_short_name
        INTO lv_appl_short_nm
        FROM fnd_application
       WHERE application_id=724;

  	IF p_schema = MSC_UTIL.G_APPS_SCHEMA THEN

	    EXECUTE IMMEDIATE p_sql_stmt;

	  ELSE

      ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => lv_appl_short_nm,
                 statement_type => AD_DDL.CREATE_INDEX,
                 statement => p_sql_stmt,
                 object_name => p_object);

    END IF;

  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Index '||p_object||'  succesfully created...');

EXCEPTION
   WHEN OTHERS THEN
        IF SQLCODE IN (-01408) THEN
		      /*Index on same column already exists*/
            NULL;
        ELSIF
          SQLCODE IN (-00955) THEN
		      /*Index already exists*/
            NULL;
        ELSE
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
            raise_application_error(-20001, 'Index Creation failed: ' || sqlerrm);
        END IF;

END CREATE_INDEX; --Index


/* ======== Drop index ========== */
/* p_schema refers to the schema containing the index*/
PROCEDURE DROP_INDEX (p_schema         IN VARCHAR2,
                      p_sql_stmt       IN VARCHAR2,
                      p_index          IN VARCHAR2,
                      p_table          IN VARCHAR2,
		      p_applsys_schema IN VARCHAR2)
IS
   v_sql_stmt        VARCHAR2(6000);
   lv_appl_short_nm  VARCHAR2(30);
BEGIN -- Index

      SELECT application_short_name
        INTO lv_appl_short_nm
        FROM fnd_application
       WHERE application_id=724;

	IF p_schema = MSC_UTIL.G_APPS_SCHEMA THEN

	   EXECUTE IMMEDIATE p_sql_stmt;

	ELSE

     ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => lv_appl_short_nm,
                 statement_type => AD_DDL.DROP_INDEX,
                 statement => p_sql_stmt,
                 object_name => p_table);

  END IF;


  MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS, 'Index '||p_index||'  succesfully dropped...');

EXCEPTION
  WHEN OTHERS THEN
     IF SQLCODE IN (-01418) THEN
		   /*Index does not exist */
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR, 'Index  ' ||p_index||' does not exist...');
     ELSE
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
        raise_application_error(-20001, 'Dropping Index failed: ' || sqlerrm);
     END IF;
END DROP_INDEX; --Index

FUNCTION  GET_SCHEMA_NAME( p_apps_id IN  NUMBER)
RETURN VARCHAR2 IS
 lv_schema            VARCHAR2(30);
 lv_prod_short_name   VARCHAR2(30);
 lv_retval            boolean;
 lv_dummy1            varchar2(32);
 lv_dummy2            varchar2(32);
  lv_is_new_ts_mode VARCHAR2(10);
BEGIN

    case p_apps_id
        WHEN  867 THEN lv_schema:= G_AHL_SCHEMA;
        WHEN  401 THEN lv_schema:= G_INV_SCHEMA;
        WHEN  702 THEN lv_schema:= G_BOM_SCHEMA;
        WHEN  201 THEN lv_schema:= G_PO_SCHEMA;
        WHEN  665 THEN lv_schema:= G_WSH_SCHEMA;
        WHEN  426 THEN lv_schema:= G_EAM_SCHEMA;
        WHEN  660 THEN lv_schema:= G_ONT_SCHEMA;
        WHEN  704 THEN lv_schema:= G_MRP_SCHEMA;
        WHEN  410 THEN lv_schema:= G_WSM_SCHEMA;
        WHEN  523 THEN lv_schema:= G_CSP_SCHEMA;
        WHEN  706 THEN lv_schema:= G_WIP_SCHEMA;
        WHEN  512 THEN lv_schema:= G_CSD_SCHEMA;
        WHEN  0   THEN lv_schema:= G_FND_SCHEMA;
        ELSE      lv_schema:= NULL ;
    end case;

    if lv_schema is not null then
        return lv_schema;
    end if;

   ad_tspace_util.is_new_ts_mode(lv_is_new_ts_mode);
   IF(upper(lv_is_new_ts_mode) = 'N') THEN
   	SELECT  a.oracle_username
     	INTO  lv_schema
     	FROM  FND_ORACLE_USERID a,
              FND_PRODUCT_INSTALLATIONS b
   	 WHERE  a.oracle_id = b.oracle_id
      	      AND  b.application_id = p_apps_id;

   ELSE
  	lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(p_apps_id);
        lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_schema);
  END IF;

 RETURN  lv_schema;

EXCEPTION
    WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
      raise_application_error(-20001, 'Error getting the Schema : ' || sqlerrm);
END GET_SCHEMA_NAME;


-- This function returns the VMI_FLAG in MSC_ITEM_SUPPLIERS as follows:
--  1. If for a (item,supplier) combination there exists both local and
--	global ASLs, then the local will take precedence.
--  2. If the supplier_site is null in msc_supplies but not null in
--	msc_item_suppliers, then this record's vmi_flag will not be considered.
--  3. If the supplier and supplier_site are both null in msc_supplies and supplier_site is
--	null in msc_item_suppliers, then this record's vmi_flag will be considered
--  4. If the supplier and supplier_site are not null, then supplier_site level
--      record's vmi_flag will be considered.

FUNCTION get_vmi_flag(var_plan_id IN NUMBER,
    			  var_sr_instance_id IN NUMBER,
    			  var_org_id IN NUMBER,
    			  var_inventory_item_id IN NUMBER,
    			  var_supplier_id IN NUMBER,
    			  var_supplier_site_id IN NUMBER) RETURN NUMBER IS

lv_vmi_flag NUMBER := 2;

CURSOR GET_VMI_FLAG_C1 is
	select vmi_flag	from msc_item_suppliers mis
	Where mis.supplier_id = var_supplier_id
	and nvl(mis.supplier_site_id,-1) = nvl(var_supplier_site_id,-1)
	and mis.using_organization_id = var_org_id
	--AND mis.plan_id = var_plan_id
	AND mis.plan_id = -1
	AND mis.sr_instance_id = var_sr_instance_id
	AND mis.sr_instance_id2 = var_sr_instance_id
	AND mis.organization_id = var_org_id
	AND mis.inventory_item_id = var_inventory_item_id
	AND ROWNUM = 1;

CURSOR GET_VMI_FLAG_C2 is
	select vmi_flag
	from msc_item_suppliers mis
	Where mis.supplier_id = var_supplier_id
	and mis.supplier_site_id is null
	and var_supplier_site_id is not null
	and mis.using_organization_id = var_org_id
	--AND mis.plan_id = var_plan_id
	AND mis.plan_id = -1
	AND mis.sr_instance_id = var_sr_instance_id
	AND mis.sr_instance_id2 = var_sr_instance_id
	AND mis.organization_id = var_org_id
	AND mis.inventory_item_id = var_inventory_item_id
	AND ROWNUM = 1;

CURSOR GET_VMI_FLAG_C3 is
	select vmi_flag
	from msc_item_suppliers mis
	Where mis.supplier_id = var_supplier_id
	and nvl(mis.supplier_site_id,-1) = nvl(var_supplier_site_id,-1)
	and mis.using_organization_id = -1
	--AND mis.plan_id = var_plan_id
	AND mis.plan_id = -1
	AND mis.sr_instance_id = var_sr_instance_id
	AND mis.sr_instance_id2 = var_sr_instance_id
	AND mis.organization_id = var_org_id
	AND mis.inventory_item_id = var_inventory_item_id
	AND ROWNUM = 1;

CURSOR GET_VMI_FLAG_C4 is
	select vmi_flag
	from msc_item_suppliers mis
	Where mis.supplier_id = var_supplier_id
	and mis.supplier_site_id is null
	and var_supplier_site_id is not null
	and mis.using_organization_id = -1
	--AND mis.plan_id = var_plan_id
	AND mis.plan_id = -1
	AND mis.sr_instance_id = var_sr_instance_id
	AND mis.sr_instance_id2 = var_sr_instance_id
	AND mis.organization_id = var_org_id
	AND mis.inventory_item_id = var_inventory_item_id
	AND ROWNUM = 1;

BEGIN

	/*
		We need to query from msc_item_suppliers based
		on it's unique index in 4 ways depending on the supplier_site_id
		is null/not null and org_id is -1 or not -1.
		Instead of having 4 unions, here we have declared 4 cursors
		with org_id as a parameter.
		We call the appropriate cursor based on the passed in supplier_site_id.
		The logic is that we open the next cursor, only if
		the current one fetches 0 rows.
	*/

	OPEN GET_VMI_FLAG_C1;
	FETCH GET_VMI_FLAG_C1 into lv_vmi_flag;
	if GET_VMI_FLAG_C1%ROWCOUNT = 0 then
		CLOSE GET_VMI_FLAG_C1;
		OPEN GET_VMI_FLAG_C2;
		FETCH GET_VMI_FLAG_C2 into lv_vmi_flag;
		if GET_VMI_FLAG_C2%ROWCOUNT = 0 then
					CLOSE GET_VMI_FLAG_C2;
					OPEN GET_VMI_FLAG_C3;
					FETCH GET_VMI_FLAG_C3 into lv_vmi_flag;
					if GET_VMI_FLAG_C3%ROWCOUNT = 0 then
						CLOSE GET_VMI_FLAG_C3;
						OPEN GET_VMI_FLAG_C4;
						FETCH GET_VMI_FLAG_C4 into lv_vmi_flag;
						CLOSE GET_VMI_FLAG_C4;
					else
						CLOSE GET_VMI_FLAG_C3;
					end if;
		else
					CLOSE GET_VMI_FLAG_C2;
		end if;
	else
		CLOSE GET_VMI_FLAG_C1;
	end if;

return nvl(lv_vmi_flag,2);

EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 2;
WHEN OTHERS THEN RAISE;

END get_vmi_flag;

Function Source_Instance_State(p_dblink varchar2)
return boolean
is
l_sql varchar2(2000);
l_state boolean := TRUE;
Begin
	begin
		l_sql := 'select 1 from dual@'||p_dblink;
		execute immediate(l_sql);
	exception
	        when too_many_rows then
			null;
                when no_data_found then
			null;
		when others then
			l_state := FALSE;
	end ;
 return l_state ;
End Source_Instance_State;

/*
PROCEDURE debug_message( P_line_no in number ,
		         P_Line_msg in varchar2 ,
		         P_Package_name in varchar2 default null ,
		         P_Program_unit in varchar2 default null ,
			 P_Table_Name in varchar2 default 'DEBUG_DB_MESSAGES' )
is
l_sql_stmt varchar2(32000);
PRAGMA AUTONOMOUS_TRANSACTION ;
begin
l_sql_stmt := 'insert into '||P_Table_Name||'  values(  :v_line_no '||
			                      ', :v_line_msg '||
			                      ', :v_package_name '||
			                      ', :v_program_unit )';
EXECUTE IMMEDIATE l_sql_stmt using
p_line_no , p_line_msg ,
P_package_name , p_program_unit ;
commit;

exception
when others then
  raise_application_error(-20001 , sqlerrm);
end debug_message;

PROCEDURE init_message(P_Table_Name in varchar2 default 'DEBUG_DB_MESSAGES')
is
l_sql_stmt varchar2(32000);
l_var number;

v_msc_schema     VARCHAR2(32);
lv_retval        boolean;
lv_dummy1        varchar2(32);
lv_dummy2        varchar2(32);

cursor c_obj(p_obj varchar2 , p_owner varchar2) is
select 1 from  all_objects
where object_name = p_obj
and owner = p_owner
and object_type = 'TABLE';

PRAGMA AUTONOMOUS_TRANSACTION ;

Begin
--bug #3777761 modified cursor c_obj and retrived owner value using function FND_INSTALLATION.GET_APP_INFO.
lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2,v_msc_schema);

open c_obj(P_Table_Name , v_msc_schema);
fetch c_obj into l_var;
close c_obj;

if nvl(l_var,-1) = 1 then
	l_sql_stmt  := 'drop table '||P_Table_Name ||' ';

	EXECUTE IMMEDIATE l_sql_stmt ;
	l_sql_stmt  := 'create table '||P_Table_Name || '( '||
			       ' line_no number , line_msg long ,  '||
			       ' package_name varchar2(50) ,Program_unit varchar2(50)) ' ;

        EXECUTE IMMEDIATE l_sql_stmt ;
elsif nvl(l_var,-1) = -1 then
	l_sql_stmt  := 'create table '||P_Table_Name || '( '||
			       ' line_no number , line_msg long ,  '||
			       ' package_name varchar2(50) ,Program_unit varchar2(50)) ' ;

        EXECUTE IMMEDIATE l_sql_stmt ;
end if;

commit;

End init_message;
*/

PROCEDURE init_dbmessage
is
l_count number;
begin
l_count := MSC_UTIL.g_dbmessage.count;
if nvl(l_count,0) > 0 then
	MSC_UTIL.g_dbmessage.delete;
end if;
End init_dbmessage;


PROCEDURE set_dbmessage(p_msg in varchar2 ,
		        p_Package_name in varchar2 default null ,
		        P_Program_unit in varchar2 default null  )
is
l_count number ;
begin
	l_count := MSC_UTIL.g_dbmessage.count;
	MSC_UTIL.g_dbmessage(nvl(l_count , 0) + 1).msg_no       := nvl(l_count , 0) + 1 ;
	MSC_UTIL.g_dbmessage(nvl(l_count , 0) + 1).msg_desc     := p_msg ;
	MSC_UTIL.g_dbmessage(nvl(l_count , 0) + 1).package_name := p_Package_name ;
	MSC_UTIL.g_dbmessage(nvl(l_count , 0) + 1).program_unit := P_Program_unit ;
End set_dbmessage;

FUNCTION get_dbmessage return
DbMessageTabType
is
begin
	return(MSC_UTIL.g_dbmessage);
end get_dbmessage;

/*-----------------------------------------------------------------------------
Function	: MSC_NUMVAL

Parameters	: p_input (IN) - string which needs to be converted in to numeric values

Description	: this function will return the numeric value of any valid string.
       If the input string is not in valid numeric format, it returns null.
       This function is implemented as there is no equivalent to IS_NUMERIC in Oracle.
-----------------------------------------------------------------------------*/
FUNCTION MSC_NUMVAL(p_input varchar2) return NUMBER IS
BEGIN
       BEGIN
         RETURN to_number(p_input);
       EXCEPTION
          WHEN OTHERS THEN
            IF SQLCODE IN (-01722, -06502) THEN RETURN null;
            ELSE raise;
            END IF;
       END;
END MSC_NUMVAL;

-- -------------------------------------
-- called from ASCP plan options screen
-- -------------------------------------

FUNCTION is_app_installed(p_product IN NUMBER) RETURN BOOLEAN IS
  l_status        VARCHAR2(30);
  l_industry      VARCHAR2(30);
  l_schema        VARCHAR2(30);
  l_prod_short_name VARCHAR2(30);
BEGIN
    l_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(p_product);
    IF fnd_installation.get_app_info(l_prod_short_name, l_status, l_industry, l_schema) <> TRUE THEN
        RETURN FALSE;
    ELSE
        IF l_status = 'I' THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END IF;
END is_app_installed;

-- ----------------------------
-- called from Instances screen
-- and ASCP plan options screen
-- ----------------------------

FUNCTION get_aps_config_level(p_sr_instance_id IN Number, p_dblink IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    l_profile CONSTANT VARCHAR2(80) := 'GMP_APS_CONFIG_LEVEL';

    CURSOR db_cur(pv_instance_id NUMBER) IS
    SELECT DECODE(M2A_dblink,null,' ','@'||M2A_dblink)
    FROM msc_apps_instances
    WHERE instance_id = pv_instance_id;

    l_level NUMBER;
    l_level_dest NUMBER;

    l_dblink VARCHAR2(100);
    l_sql_stmt VARCHAR2(500);
    INVALID_IDENTIFIER EXCEPTION;
    PRAGMA EXCEPTION_INIT(INVALID_IDENTIFIER, -6550);
BEGIN
    IF p_dblink IS NULL THEN
        OPEN db_cur(p_sr_instance_id);
        FETCH db_cur INTO l_dblink;
        IF db_cur%NOTFOUND THEN
            l_level := 3;
        END IF;
        CLOSE db_cur;
    ELSE
        l_dblink := '@'||P_dblink;
        l_sql_stmt := ' BEGIN'
                      ||' :v_level:= nvl(fnd_profile.value'||l_dblink||'(:p_profile),3);'
                      ||' END;';

        EXECUTE IMMEDIATE l_sql_stmt USING  OUT l_level,
                                        IN l_profile;
    END IF;
    l_level_dest := NVL(fnd_profile.value(l_profile),3);

    IF l_level < l_level_dest THEN
        RETURN l_level;
    ELSE
        RETURN l_level_dest;
    END IF;
EXCEPTION
    WHEN INVALID_IDENTIFIER THEN
        RETURN -23453;
    WHEN OTHERS THEN
        RETURN -23453;
END get_aps_config_level;

PROCEDURE initialize_common_globals(pINSTANCE_ID IN NUMBER)
IS
v_apps_ver NUMBER;
BEGIN


   BEGIN
    SELECT ITEM_TYPE_ID,  ITEM_TYPE_VALUE
      INTO G_PARTCONDN_ITEMTYPEID, G_PARTCONDN_GOOD
      FROM MSC_ITEM_TYPE_DEFINITIONS
     WHERE ITEM_TYPE_NAME           = 'PART_CONDITION'
       AND ITEM_TYPE_VALUE_MEANING  = 'USABLE';

    SELECT ITEM_TYPE_VALUE
      INTO G_PARTCONDN_BAD
      FROM MSC_ITEM_TYPE_DEFINITIONS
     WHERE ITEM_TYPE_NAME           = 'PART_CONDITION'
       AND ITEM_TYPE_VALUE_MEANING  = 'DEFECTIVE';

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      LOG_MSG(G_LVL_FATAL_ERR,'Seed Data not found for Item Part condition');
      RAISE;
    END;

     ------ set v_in_org_str and v_in_all_org_str----------

    MSC_UTIL.v_in_org_str        := msc_cl_pull.get_org_str(pinstance_id,2);
    MSC_UTIL.v_in_all_org_str    := msc_cl_pull.get_org_str(pinstance_id,3);

   IF MSC_UTIL.G_COLLECT_SRP_DATA = 'Y' THEN
     SELECT APPS_VER
       INTO  v_apps_ver
       FROM MSC_APPS_INSTANCES
      WHERE INSTANCE_ID= pINSTANCE_ID;

     IF (v_apps_ver<> -1 AND v_apps_ver < MSC_UTIL.G_APPS115) THEN  --bug#5684183 (bcaru)
        MSC_UTIL.G_COLLECT_SRP_DATA := 'N' ; --SRP not supported for version < 12.1
        LOG_MSG(G_LVL_FATAL_ERR,'v115 SRP data is not collected because of wrong source version...');
     ELSE
        MSC_CL_PULL.GET_DEPOT_ORG_STRINGS(pINSTANCE_ID);       -- For Bug 5909379
     END IF;
   END IF;



          BEGIN
             SELECT NVL(TO_NUMBER(FND_PROFILE.VALUE('MSC_COLLECTION_WINDOW_FOR_TP_CHANGES')),0)
             INTO   v_msc_tp_coll_window
             FROM   DUAL;
             EXCEPTION
             WHEN OTHERS THEN
                v_msc_tp_coll_window := 0;
          END ;
          BEGIN
             -- BUG 15915083
             SELECT NVL(TO_NUMBER(FND_PROFILE.VALUE('MSC_COLL_WINDOW_FOR_REGION_ZONE_CHANGES')),0)
             INTO   v_msc_reg_zon_coll_window
             FROM   DUAL;
             EXCEPTION
             WHEN OTHERS THEN
                v_msc_reg_zon_coll_window := 0;
          END ;


END initialize_common_globals;

FUNCTION mv_exists_in_schema(p_schema_name VARCHAR2, p_MV_name VARCHAR2)  RETURN BOOLEAN IS
lv_exists number;
begin
        EXECUTE IMMEDIATE
            '  select 1
                  from all_mviews
                  where mview_name =:p1
                    and owner = :p2 '
        into lv_exists using p_MV_name, p_schema_name;

     if lv_exists = 1 then
        return TRUE;
     else
        return FALSE;
     end if;
Exception
  WHEN NO_DATA_FOUND THEN
  return FALSE;
END mv_exists_in_schema;



FUNCTION GET_SERVICE_ITEMS_CATSET_ID  RETURN NUMBER  IS
	l_cat_set VARCHAR2(30) := NULL ;
	BEGIN
	  IF G_CAT_SET_ID  IS NULL THEN

         l_cat_set :=  FND_PROFILE.VALUE('MSC_SERVICE_ITEMS_CATSET') ;
		  SELECT  CATEGORY_SET_ID INTO  G_CAT_SET_ID
			FROM MSC_CATEGORY_SETS
			WHERE CATEGORY_SET_NAME = l_cat_set;
		END IF ;
	        RETURN G_CAT_SET_ID;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	  RETURN NULL;
END GET_SERVICE_ITEMS_CATSET_ID ;



-- Procedure to execute any API given as parameter Bug 6469713
PROCEDURE EXECUTE_API(ERRBUF                   OUT NOCOPY VARCHAR2,
                      RETCODE                  OUT NOCOPY NUMBER,
                      p_package_name IN VARCHAR2,
                      p_proc_name IN VARCHAR2 ,
                      comma_sep_para_list IN VARCHAR2) IS
 lv_exists number := 0;
 lv_str varchar2(2000);
 lv_sql_str varchar2(2000);

BEGIN
 /* To Check if the object is existing and VAlid;*/
    BEGIN
      lv_sql_str := ' select 1
        from all_objects
         where object_name = :p_package_name
         and owner = :p2
         and object_type = ''PACKAGE''
         and status =''VALID''
         ';
        Execute immediate lv_sql_str into lv_exists
        USING
        p_package_name,MSC_UTIL.G_APPS_SCHEMA;

      EXCEPTION WHEN no_data_found THEN
       RAISE_APPLICATION_ERROR(-20056,'Package name does not exists or is Invalid');
     END;

   IF lv_exists = 1 Then
    Begin
   /* If Package exists then submitting the block */
     lv_str := 'BEGIN  '||
               		p_package_name||'.'|| p_proc_name||
                    '(' || comma_sep_para_list || ');'  ||
              		'  END;';

     Execute immediate lv_str;

     EXCEPTION
     WHEN OTHERS THEN
     LOG_MSG(G_LVL_FATAL_ERR,'Error while trying to execute the API');
     LOG_MSG(G_LVL_FATAL_ERR,SQLERRM);
     RETCODE:= G_ERROR;
     RAISE;
    End;
     --ERRBUF := 'NO_USER_DEFINED';
   End if;
END;

PROCEDURE DROP_MVIEW_SYNONYMS(mview_owner  VARCHAR2, mview_name VARCHAR2) IS
lv_sql   varchar2(1000);
begin
/* droping only the synonym with the same name in APPS schema.
for i in (SELECT syn.owner SYNONYM_owner, syn.synonym_name
            FROM   --fnd_lookup_values a,
                   all_synonyms syn
           WHERE  syn.table_owner = mview_owner and
                  syn.table_name = mview_name
         )
loop
  BEGIN
      IF I.SYNONYM_owner ='PUBLIC' THEN
      lv_sql:='DROP PUBLIC SYNONYM '||i.synonym_name;
      ELSE
      lv_sql:='DROP SYNONYM '||I.SYNONYM_owner||'.'||i.synonym_name;
      END IF;
*/
      lv_sql:='DROP SYNONYM '||v_chr34|| mview_name||v_chr34;
      EXECUTE IMMEDIATE lv_sql;

  EXCEPTION
  WHEN OTHERS THEN
      IF instr(DBMS_UTILITY.FORMAT_ERROR_STACK ,'ORA-01434') > 0 OR
         instr(DBMS_UTILITY.FORMAT_ERROR_STACK ,'ORA-01432') > 0   THEN
        NULL; --private/public synonym to be dropped does not exist
      ELSE
        RAISE_APPLICATION_ERROR(-20001,'Error while executing:-'||lv_sql || ':  ' || SQLERRM);
      END IF;
/*  END;
end loop;*/
END DROP_MVIEW_SYNONYMS;

PROCEDURE DROP_MVIEW_TRIGGERS(mview_owner VARCHAR2, mview_name VARCHAR2) IS
lv_sql   varchar2(1000);
begin
for i in (SELECT trg.owner, trg.trigger_name
            FROM   all_TRIGGERS TRG
           WHERE  trg.table_owner = mview_owner and
                  trg.table_name = mview_name
          )
loop
    BEGIN
    lv_sql:= 'DROP TRIGGER '||I.owner||'.'||i.trigger_name;
        EXECUTE IMMEDIATE lv_sql;

    EXCEPTION
    WHEN OTHERS THEN
        IF instr(DBMS_UTILITY.FORMAT_ERROR_STACK ,'ORA-04080') > 0 THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(-20001,'Error while executing:-'||lv_sql || ':  ' || SQLERRM);
        END IF;
    END;
end loop;
END DROP_MVIEW_TRIGGERS;

PROCEDURE DROP_WRONGSCHEMA_MVIEWS IS
lv_sql   varchar2(1000);
lv_Nologging_tblsp varchar2(30);
begin
for i in (SELECT mview_name,msc_util.GET_SCHEMA_NAME(erp_product_code)  mview_owner
            FROM msc_coll_snapshots_v
           WHERE mview_name not in ('ALL SNAPSHOTS','MRP_COMPANY_USERS_SN') --11654050, SUN performance issue
           UNION            /*Old Mviews that need to be dropped*/
           Select 'BOM_CTO_ORDER_DMD_SN',msc_util.G_BOM_SCHEMA
           FROM Dual)
loop
    BEGIN
    lv_sql:='DROP MATERIALIZED VIEW '||I.mview_owner||'.'||v_chr34||i.mview_name||v_chr34;
        EXECUTE IMMEDIATE lv_sql;
    EXCEPTION
    WHEN OTHERS THEN
        IF instr(DBMS_UTILITY.FORMAT_ERROR_STACK ,'ORA-12003') > 0 THEN --materialized view does not exist
          NULL;--materialized view does not exist
        ELSE
          RAISE_APPLICATION_ERROR(-20001,'Error while executing:-'||lv_sql || ':  ' || SQLERRM);
        END IF;
    END;

    DROP_MVIEW_TRIGGERS(i.mview_owner, i.mview_name);
    DROP_MVIEW_SYNONYMS(i.mview_owner, i.mview_name);
end loop;

-- drop MVs which are not in NOLLOGING tblspc
select tablespace into lv_Nologging_tblsp from FND_TABLESPACES where tablespace_type = 'NOLOGGING';
FOR j IN(select a.mview_name,c.table_name,c.TABLESPACE_NAME
          from MSC_COLL_SNAPSHOTS_V a, ALL_MVIEWS b,ALL_TABLES    c
          where  a.mview_name = b.mview_name
		  AND a.mview_name <> 'MRP_COMPANY_USERS_SN'  --11654050, SUN performance issue
          AND b.OWNER = G_APPS_SCHEMA
          AND b.CONTAINER_NAME = c.table_name
          AND c.owner = G_APPS_SCHEMA
          AND c.TABLESPACE_NAME <> lv_Nologging_tblsp )
loop
lv_sql:='DROP MATERIALIZED VIEW '||G_APPS_SCHEMA||'.'||j.mview_name;

EXECUTE IMMEDIATE lv_sql;
DROP_MVIEW_TRIGGERS(G_APPS_SCHEMA, j.mview_name);
DROP_MVIEW_SYNONYMS(G_APPS_SCHEMA, j.mview_name);
end loop;

END;

/*Old Mviews that need to be dropped*/
PROCEDURE DROP_DEPRECATED_MVIEWS IS
lv_sql   varchar2(1000);
BEGIN
for i in 1..v_deprecatedMVList.COUNT
loop
    BEGIN
    lv_sql:='DROP MATERIALIZED VIEW '||v_deprecatedMVSchemaList(i)||'.'||v_deprecatedMVList(i);
        EXECUTE IMMEDIATE lv_sql;
    EXCEPTION
    WHEN OTHERS THEN
        IF instr(DBMS_UTILITY.FORMAT_ERROR_STACK ,'ORA-12003') > 0 THEN --materialized view does not exist
          NULL;--materialized view does not exist
        ELSE
          RAISE_APPLICATION_ERROR(-20001,'Error while executing:-'||lv_sql || ':  ' || SQLERRM);
        END IF;
    END;

    DROP_MVIEW_TRIGGERS(v_deprecatedMVSchemaList(i), v_deprecatedMVList(i));
    DROP_MVIEW_SYNONYMS(v_deprecatedMVSchemaList(i), v_deprecatedMVList(i));
end loop;

END;

PROCEDURE purge_dest_setup(p_instance_id IN NUMBER ) is
  p_entity_name varchar2(30);
  l_sql_stmt varchar2(2000);
Begin
   p_entity_name := 'MSC_DEPARTMENT_RESOURCES';
   if p_instance_id is null or p_entity_name is null then
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  'Invalid Input - '||'inst_id:'||p_instance_id||', entity:'||p_entity_name);
   end if;
   if p_entity_name = 'MSC_DEPARTMENT_RESOURCES' then
         l_sql_stmt:= 'Delete MSC_RESOURCE_PARAMETERS MRS '||
                      'WHERE mrs.sr_instance_id = '||P_INSTANCE_ID ||
                      'AND NOT EXISTS '||
                      '(SELECT mdr.resource_id '||
                      'FROM msc_department_resources mdr '||
                      'where mdr.plan_id=-1 '||
                      'AND  mdr.sr_instance_id = mrs.sr_instance_id '||
                      'AND mdr.organization_id = mrs.organization_id '||
                      'AND mdr.department_id = mrs.department_id '||
                      'AND mdr.resource_id = mrs.resource_id  ) ';
         EXECUTE IMMEDIATE l_sql_stmt;
         if sql%rowcount >1 then
             commit;
         end if;
         l_sql_stmt:= 'Delete MSC_SOL_GRP_RES MRS '||
                      'WHERE mrs.sr_instance_id = '||P_INSTANCE_ID ||
                      'AND NOT EXISTS '||
                      '(SELECT mdr.resource_id '||
                      'FROM msc_department_resources mdr '||
                      'where mdr.plan_id=-1 '||
                      'AND  mdr.sr_instance_id = mrs.sr_instance_id '||
                      'AND mdr.organization_id = mrs.organization_id '||
                      'AND mdr.department_id = mrs.department_id '||
                      'AND mdr.resource_id = mrs.resource_id  ) ';
         EXECUTE IMMEDIATE l_sql_stmt;
         if sql%rowcount >1 then
             commit;
         end if;
   end if;
Exception
   when others then
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_FATAL_ERR,  SQLERRM);
      raise_application_error(-20001, 'Error purging setup, Entity: '|| p_entity_name||' - '|| sqlerrm);
End Purge_dest_setup;

/*
 * Omron - bug 16390668
 * Returns true if Planning ODS Load (MSCPDC) and Memory-Based Snapshot are
 * compatible, i.e. there are no seeded incompatibilities in
 * FND_CONCURRENT_PROGRAM_SERIAL.  Otherwise it returns false.
 */
function mbs_ods_compatible return boolean is
  lv_count number;

begin
  select count(*)
  into lv_count
  from fnd_concurrent_program_serial fcps, fnd_concurrent_programs fcp,
  fnd_concurrent_programs fcp2
  where fcp.application_id = 724
  and fcp.concurrent_program_name = 'MSCPDC'
  and fcp.application_id = fcps.running_application_id
  and fcp.concurrent_program_id = fcps.running_concurrent_program_id
  and fcps.to_run_application_id = fcp2.application_id
  and fcps.to_run_concurrent_program_id = fcp2.concurrent_program_id
  and fcp2.application_id = 724
  and fcp2.concurrent_program_name in
  ('MSCNSP', 'MSCNSPWA64', 'MSCNSPWH64', 'MSCNSPWHPIA64', 'MSCNSPWL64',
   'MSCNSPWS64');

  if lv_count = 0 then
    return true;
  end if;

  return false;
end mbs_ods_compatible;

-----------------------------------------------------------------------------
-- Start of code added for omron bug 16561317

/*
 * Returns true if MSCPDX is self compatible, i.e. there are no seeded
 * incompatibilities in FND_CONCURRENT_PROGRAM_SERIAL.
 * Otherwise it returns false.
 */

function MSCPDX_compatible return boolean is
  lv_count number;

begin
  select count(*)
  into lv_count
  from fnd_concurrent_program_serial fcps, fnd_concurrent_programs fcp,
  fnd_concurrent_programs fcp2
  where fcp.application_id = 724
  and fcp.concurrent_program_name = 'MSCPDX'
  and fcp.application_id = fcps.running_application_id
  and fcp.concurrent_program_id = fcps.running_concurrent_program_id
  and fcps.to_run_application_id = fcp2.application_id
  and fcps.to_run_concurrent_program_id = fcp2.concurrent_program_id
  and fcp2.application_id = 724
  and fcp2.concurrent_program_name = 'MSCPDX' ;

  if lv_count = 0 then
    return true;  -- Compatible. Parallel collections can run.
  end if;

  return false;  -- Seeded incompatibility between MSCPDX and itself exists.
end MSCPDX_compatible;

/*
 * Returns a unique "handle" to a lock specified by the lockname parameter.
 * The handle can be used to safely identify locks in calls to other
 * DBMS_LOCK programs.
 */

PROCEDURE allocate_unique(lock_name IN VARCHAR2,
                          lock_handle IN OUT NOCOPY VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    dbms_lock.allocate_unique(lockname => lock_name,
                              lockhandle => lock_handle,
                              expiration_secs => 10);
END allocate_unique;

/*
 * Returns 0 if lock can be allocated, otherwise 1-5, depending on situation.
 * Refer to dbms_lock documentation for description of non-zero return codes.
 */
FUNCTION GET_LOCK(lock_handle IN OUT NOCOPY VARCHAR2) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    request_id NUMBER;
BEGIN
    request_id := dbms_lock.request(lockhandle => lock_handle,
                                    lockmode => dbms_lock.x_mode,
                                    timeout => 1,
                                    release_on_commit => false);

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, 'dbms_lock.request returned ' ||
                     request_id);

    RETURN request_id;
END GET_LOCK;

/*
 * Releases the lock obtained by the GET_LOCK function.
 */
FUNCTION RELEASE_LOCK(lock_handle IN OUT NOCOPY VARCHAR2) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    rel_status NUMBER;
BEGIN
    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, 'releasing lock ' || lock_handle);
    rel_status := dbms_lock.RELEASE(lock_handle);

    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEV, 'release status - ' || rel_status);
    RETURN rel_status;
END RELEASE_LOCK;

-- End of code added for omron bug 16561317
-----------------------------------------------------------------------------

BEGIN -- pkg initialization section
-- set globals for schema name
    select oracle_username
    into G_APPS_SCHEMA
    from fnd_oracle_userid
    where read_only_flag = 'U';
begin
  G_AHL_SCHEMA := GET_SCHEMA_NAME(867) ;
exception
  when others then
  G_AHL_SCHEMA:=null;
end;
G_INV_SCHEMA := GET_SCHEMA_NAME(401) ;
G_BOM_SCHEMA := GET_SCHEMA_NAME(702) ;
G_PO_SCHEMA := GET_SCHEMA_NAME(201) ;
G_WSH_SCHEMA := GET_SCHEMA_NAME(665) ;
G_EAM_SCHEMA := GET_SCHEMA_NAME(426) ;
G_ONT_SCHEMA := GET_SCHEMA_NAME(660) ;
G_MRP_SCHEMA := GET_SCHEMA_NAME(704) ;
G_WSM_SCHEMA := GET_SCHEMA_NAME(410) ;
G_CSP_SCHEMA := GET_SCHEMA_NAME(523) ;
G_WIP_SCHEMA := GET_SCHEMA_NAME(706) ;
G_CSD_SCHEMA := GET_SCHEMA_NAME(512) ;
G_MSC_SCHEMA := GET_SCHEMA_NAME(724) ;
G_FND_SCHEMA := GET_SCHEMA_NAME(0) ;
-- end set globals for schema name

    begin
        select sid
        into  G_CURRENT_SESSION_ID
        from v$session
        where audsid = SYS_CONTEXT('USERENV','SESSIONID');
    exception when others then
      G_CURRENT_SESSION_ID := 0;
    end ;

EXCEPTION
WHEN OTHERS THEN
RAISE_APPLICATION_ERROR(-20001,'MSC_UTIL:Error while initilizing Global Variables for Source Schema names:  ' || SQLERRM);

END MSC_UTIL;

/
