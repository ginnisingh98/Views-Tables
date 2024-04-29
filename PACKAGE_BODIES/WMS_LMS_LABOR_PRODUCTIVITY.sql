--------------------------------------------------------
--  DDL for Package Body WMS_LMS_LABOR_PRODUCTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LMS_LABOR_PRODUCTIVITY" AS
/* $Header: WMSLMLPB.pls 120.5 2006/06/06 09:04:56 viberry noship $ */

g_version_printed BOOLEAN := FALSE;
g_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);



PROCEDURE DEBUG(p_message IN VARCHAR2,
                 p_module   IN VARCHAR2 default 'abc',
                 p_level   IN VARCHAR2 DEFAULT 9) IS
BEGIN

 IF NOT g_version_printed THEN
   INV_TRX_UTIL_PUB.TRACE('$Header: WMSLMLPB.pls 120.5 2006/06/06 09:04:56 viberry noship $',g_pkg_name, 9);
   g_version_printed := TRUE;
 END IF;

 INV_TRX_UTIL_PUB.TRACE( P_MESG =>P_MESSAGE
                        ,P_MOD => p_module
                        ,p_level => p_level
                        );
END DEBUG;




-- This procedure will match all the transaction records in wms_els_trx_src
-- table with the setup rows in wms_els_individual_tasks_b and wms_els_grouped_tasks_b
--It will DO the following

-- 1) do the matching of transaction data with els data. Start with the setup row
--    with least sequnce.Update the els_data_id column of WMS_ELS_TRX_SRC table
--    with the eld_data_id of the setup line with which the matching was found
--    update the zone and item category columns with zone_id's and item_category_id of the
--    els data row with which the match was found.
-- 2). Update the travel and the idle time in the for the transaction row by
--     considering the threshold value.
--  3) update the ratings and the score
--  4) Do the matching for groups based on grouped task identifier.

PROCEDURE MATCH_RATE_TRX_RECORDS(
                                   errbuf   OUT    NOCOPY VARCHAR2
                                 , retcode  OUT    NOCOPY NUMBER
                                 , p_org_id IN            NUMBER
                                 )

 IS
CURSOR c_els_data(l_org_id NUMBER) IS
  SELECT els_data_id,
          organization_id,
          activity_id,
          activity_detail_id,
          operation_id,
          equipment_id,
          source_zone_id,
          source_subinventory,
          destination_zone_id,
          destination_subinventory,
          labor_txn_source_id,
          transaction_uom,
          from_quantity,
          to_quantity,
          item_category_id,
          operation_plan_id,
          group_id,
          task_type_id,
          task_method_id,
          expected_travel_time,
          expected_txn_time,
          expected_idle_time,
          travel_time_threshold,
          num_trx_matched
   FROM wms_els_individual_tasks_b
   WHERE organization_id = l_org_id
   AND history_flag IS NULL
   AND analysis_id IN( 2,3)
   ORDER BY sequence_number,group_id;


CURSOR c_els_grouped_data(l_org_id NUMBER) IS
SELECT els_group_id,
       organization_id,
	   activity_id,
	   activity_detail_id,
	   operation_id,
	   labor_txn_source_id,
       source_zone_id,
       source_subinventory,
       destination_zone_id,
	   destination_subinventory,
       task_method_id,
       task_range_from,
       task_range_to,
       group_size,
       expected_travel_time
FROM wms_els_grouped_tasks_b
WHERE organization_id = l_org_id
ORDER BY sequence_number;

CURSOR c_els_grouped_data_id(l_org_id NUMBER) IS
SELECT els_group_id
FROM wms_els_grouped_tasks_b
WHERE organization_id = l_org_id;



l_els_data c_els_data%ROWTYPE;

l_group_data c_els_grouped_data%ROWTYPE;

l_group_data_id c_els_grouped_data_id%ROWTYPE;

l_update_count NUMBER;

l_total NUMBER;

l_sql VARCHAR2(30000);

l_sql1 VARCHAR2(30000);

l_where_clause VARCHAR2(20000);

c NUMBER;

l_ret BOOLEAN;

l_message VARCHAR2(250);

l_num_execution_failed_tasks NUMBER;

l_num_execution_failed_group NUMBER;

l_max_id NUMBER;

l_avg_travel_time NUMBER;


BEGIN


IF g_debug=1 THEN
 debug('The value of p_org_id '|| p_org_id,'MATCH_RATE_TRX_RECORDS');
END IF;

l_num_execution_failed_tasks := 0;
l_num_execution_failed_group := 0;
l_update_count               := 0;
l_total                      := 0;
l_max_id                     := 0;

IF g_debug=1 THEN
 debug('The value of p_org_id '|| p_org_id,'MATCH_RATE_TRX_RECORDS');
END IF;

IF WMS_LMS_UTILS.ORG_LABOR_MGMT_ENABLED(p_org_id) THEN

IF g_debug=1 THEN
 debug('Org is Labor Enabled','MATCH_RATE_TRX_RECORDS');
END IF;


-- select the maximum els_trx_src_id from wms_els_trx_src_id
-- before this processing begins so that we dont update
-- the newly added rows which may be added during the
-- execution of this program as non-attributed without
-- even picking them for processing
-- also this will be used so that the newly added rows should not be
-- bucketed against a wrong setup row eith higher sequence number
-- as the newly added rows may be added after the first few passes
-- of the setup rows have already been done

select max(els_trx_src_id) into l_max_id from wms_els_trx_src
where organization_id = p_org_id;

IF g_debug=1 THEN
 debug('Value of the l_max_id at time of the beginning of the process'||l_max_id,'MATCH_RATE_TRX_RECORDS');
END IF;

--start doing the matching

OPEN c_els_data(p_org_id);
LOOP
FETCH c_els_data INTO l_els_data;
EXIT WHEN c_els_data%NOTFOUND;

-- flush out v_sql and v_where_clause so that it does not hold any old values

BEGIN

l_where_clause := NULL;

l_sql:=NULL;

-- This fuction will return TRUE  if more rows are left non matched after a certain pass of the
--  setup data. It will return FALSE when no more rows are left to process. This fucntion will be
-- used to exit the processing once all rows in wms_els_trx_src are exhaused even before
--  all the rows in setup are exhausted.

IF g_debug=1 THEN
 debug('Check if we have some more rows to process if no exit','MATCH_RATE_TRX_RECORDS');
END IF;

IF WMS_LMS_UTILS.UNPROCESSED_ROWS_REMAINING (p_org_id,l_max_id) =2  THEN
EXIT;
END IF;

IF g_debug=1 THEN
 debug('Got some more rows to process so continue with the next setup row','MATCH_RATE_TRX_RECORDS');
END IF;

IF l_els_data.organization_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND organization_id = :organization_id ';
END IF;

IF l_els_data.activity_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND activity_id = :activity_id ';
END IF;

IF l_els_data.activity_detail_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND activity_detail_id = :activity_detail_id ';
END IF;

IF l_els_data.operation_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND operation_id = :operation_id ';
END IF;


IF l_els_data.equipment_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND equipment_id = :equipment_id ';
END IF;


IF l_els_data.source_zone_id IS NOT NULL
THEN
   -- here not only match the zone_id but also if the loactor lies in that zone.
l_where_clause := l_where_clause || ' AND ((source_zone_id = :source_zone_id) '
                                 ||  ' OR ( '
                                 ||         'from_locator_id'
                                 ||  '      IN (select inventory_location_id'
                                 ||  '      from WMS_ZONE_LOCATORS'
                                 ||  '      where zone_id= :source_zone_id AND organization_id = :org_id'
                                 || ' AND '
                                 ||  ' WMS_LMS_UTILS. ZONE_LABOR_MGMT_ENABLED(:org_id,:source_zone_id)=''Y'''
                                 ||     ')'
                                 ||  ' )) ';
END IF;


IF l_els_data.source_subinventory IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND source_subinventory = :source_subinventory ';
END IF;


IF l_els_data.destination_zone_id IS NOT NULL
THEN
   -- here not only match the zone_id but also if the loactor lies in that zone.
l_where_clause := l_where_clause || ' AND ((destination_zone_id = :destination_zone_id) '
                                 ||  ' OR ( '
                                 ||  ' to_locator_id '
                                 ||  ' IN (select inventory_location_id '
                                 ||  ' from WMS_ZONE_LOCATORS '
                                 ||  ' where zone_id= :destination_zone_id AND organization_id = :org_id'
                                 || ' AND '
                                 || ' WMS_LMS_UTILS. ZONE_LABOR_MGMT_ENABLED(:org_id,:destination_zone_id)=''Y'''
                                 ||     ')'
                                 ||  ')) ';
END IF;

IF l_els_data.destination_subinventory IS NOT NULL
THEN
   l_where_clause := l_where_clause ||' AND destination_subinventory = :destination_subinventory ';
END IF;

IF l_els_data.labor_txn_source_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND labor_txn_source_id = :labor_txn_source_id ';
END IF;

IF l_els_data.transaction_uom IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND transaction_uom = :transaction_uom ';
END IF;

IF l_els_data.from_quantity IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND quantity >= :from_quantity ';
END IF;

IF l_els_data.to_quantity IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND quantity <= :to_quantity ';
END IF;

IF l_els_data.item_category_id IS NOT NULL
THEN
-- here not only match the category_id but also if the item is assigned to that category.
   l_where_clause :=l_where_clause || ' AND (( item_category_id = :item_category_id)'
                                    || 'OR ('
                                    ||  ' inventory_item_id'
                                    ||  ' IN (select inventory_item_id'
                                    ||  ' from MTL_ITEM_CATEGORIES'
                                    ||  ' where category_id= :item_category_id AND organization_id =:org_id'
                                    ||     ')'
                                    ||  ')) ';

END IF;

IF l_els_data.operation_plan_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND operation_plan_id = :operation_plan_id ';
END IF;

IF l_els_data.group_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND group_id = :group_id ';
END IF;

IF l_els_data.task_type_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND task_type_id = :task_type_id ' ;
END IF;

IF l_els_data.task_method_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND task_method_id = :task_method_id ';
END IF;

IF g_debug=1 THEN
 debug('The value of l_where_clause is '|| l_where_clause,'MATCH_RATE_TRX_RECORDS');
END IF;

l_sql :=' UPDATE wms_els_trx_src '
||      ' SET '
||      ' els_data_id = :els_data_id'
||      ' , source_zone_id = :source_zone'
||      ' , destination_zone_id = :destination_zone'
||      ' , item_category_id = :item_category'
||      ' , match_group = 1'
||      ' , unattributed_flag = NULL'
||      ' , travel_time = (CASE when (travel_and_idle_time > NVL(:travel_time_threshold,0))'
||                           '  then NVL(:travel_time_threshold,travel_and_idle_time) '
||                           '  else travel_and_idle_time '
||                           '  end )'
||      ' ,  idle_time  =  (CASE when ( travel_and_idle_time > NVL(:travel_time_threshold,0)) '
||                                      'then (travel_and_idle_time - NVL(:travel_time_threshold,travel_and_idle_time)) '
||                                      ' else 0  '
||                                      ' end )'
||      ' ,  employee_rating_travel = (select labor_rating from WMS_ELS_RATINGS_SETUP WERS, WMS_ELS_PARAMETERS WEP '
||                                             ' where  WEP.ELS_PARAMETER_ID = WERS.ELS_PARAMETER_ID'
||                                             ' AND   WEP.ORGANIZATION_ID = :org_id '
||                                             ' AND   WERS.RATING_TYPE     = ''TRA'' '
||                                             ' AND  ( '
||                                             ' (CASE when ( travel_and_idle_time > NVL(:travel_time_threshold,0)) '
||                                             '  then  NVL(:travel_time_threshold,travel_and_idle_time) '
||                                             '  else  travel_and_idle_time '
||                                             '  end ) '
||                                                   '/:expected_travel_time '
||                                             ' )*100 >= wers.Per_Expected_Time_From '
||                                             ' AND  ( '
||                                             ' (CASE when ( travel_and_idle_time > NVL(:travel_time_threshold,0)) '
||                                             '  then  NVL(:travel_time_threshold,travel_and_idle_time) '
||                                             '  else  travel_and_idle_time '
||                                             '  end ) '
||                                                   '/:expected_travel_time '
||                                             ' )*100 < NVL(wers.Per_Expected_Time_To,100000) '
||                                    ' )'
||      ' , travel_score  =  (select per_score from WMS_ELS_RATINGS_SETUP WERS, WMS_ELS_PARAMETERS WEP '
||                                             ' where  WEP.ELS_PARAMETER_ID = WERS.ELS_PARAMETER_ID'
||                                             ' AND   WEP.ORGANIZATION_ID = :org_id '
||                                             ' AND   WERS.RATING_TYPE     = ''TRA'' '
||                                             ' AND  ( '
||                                             ' (CASE when ( travel_and_idle_time > NVL(:travel_time_threshold,0)) '
||                                             '  then  NVL(:travel_time_threshold,travel_and_idle_time) '
||                                             '  else  travel_and_idle_time '
||                                             '  end ) '
||                                                   '/:expected_travel_time '
||                                             ' )*100 >= wers.Per_Expected_Time_From '
||                                             ' AND  ( '
||                                             ' (CASE when ( travel_and_idle_time > NVL(:travel_time_threshold,0)) '
||                                             '  then  NVL(:travel_time_threshold,travel_and_idle_time) '
||                                             '  else  travel_and_idle_time '
||                                             '  end ) '
||                                                   '/:expected_travel_time '
||                                             ' )*100 < NVL(wers.Per_Expected_Time_To,100000) '
||                                    ' )'
||      ' , employee_rating_txn = (  select labor_rating from WMS_ELS_RATINGS_SETUP WERS, WMS_ELS_PARAMETERS WEP '
||                                 ' where WEP.ELS_PARAMETER_ID = WERS.ELS_PARAMETER_ID '
||                                 ' AND   WEP.ORGANIZATION_ID = :org_id '
||                                 ' AND   WERS.RATING_TYPE     = ''TXN'' '
||                                 ' AND   (transaction_time/:expected_trx_time)*100 >= wers.Per_Expected_Time_From'
||                                 ' AND   (transaction_time/:expected_trx_time)*100 < NVL( wers.Per_Expected_Time_To,100000) '
||                              ' ) '
||      ' , txn_score  =        (  select per_score from WMS_ELS_RATINGS_SETUP WERS, WMS_ELS_PARAMETERS WEP '
||                                 ' where WEP.ELS_PARAMETER_ID = WERS.ELS_PARAMETER_ID '
||                                 ' AND   WEP.ORGANIZATION_ID = :org_id '
||                                 ' AND   WERS.RATING_TYPE     = ''TXN'' '
||                                 ' AND   (transaction_time/:expected_trx_time)*100 >= wers.Per_Expected_Time_From'
||                                 ' AND   (transaction_time/:expected_trx_time)*100 < NVL( wers.Per_Expected_Time_To,100000) '
||                              ' ) '
||      ' ,employee_rating_Idle = (  select labor_rating from WMS_ELS_RATINGS_SETUP WERS, WMS_ELS_PARAMETERS WEP  '
||                                 ' where WEP.ELS_PARAMETER_ID = WERS.ELS_PARAMETER_ID  '
||                                 ' AND   WEP.ORGANIZATION_ID = :org_id '
||                                 ' AND   WERS.RATING_TYPE     = ''IDL'' '
||                                 ' AND   ((CASE   when  (travel_and_idle_time > NVL(:travel_time_threshold,0) )'
||                                                 'then (travel_and_idle_time - NVL(:travel_time_threshold,travel_and_idle_time)) '
||                                                 'else 0 '
||                                          'end )'
||                                 ' /:expected_idle_time '
||                                         ')*100 >= wers.Per_Expected_Time_From '
||                                 'AND   ((CASE   when  (travel_and_idle_time > NVL(:travel_time_threshold,0) )'
||                                                 'then (travel_and_idle_time - NVL(:travel_time_threshold,travel_and_idle_time)) '
||                                                 'else 0 '
||                                         'end )'
||                                 ' /:expected_idle_time '
||                                         ')*100 < NVL(wers.Per_Expected_Time_To,10000) '
||                               ' )'
||        ' ,idle_score  =       (  select per_score from WMS_ELS_RATINGS_SETUP WERS, WMS_ELS_PARAMETERS WEP  '
||                                 ' where WEP.ELS_PARAMETER_ID = WERS.ELS_PARAMETER_ID  '
||                                 ' AND   WEP.ORGANIZATION_ID = :org_id '
||                                 ' AND   WERS.RATING_TYPE     = ''IDL'' '
||                                 ' AND   ((CASE   when  (travel_and_idle_time > NVL(:travel_time_threshold,0) )'
||                                                 'then (travel_and_idle_time - NVL(:travel_time_threshold,travel_and_idle_time)) '
||                                                 'else 0 '
||                                          'end )'
||                                 ' /:expected_idle_time '
||                                         ')*100 >= wers.Per_Expected_Time_From '
||                                 'AND   ((CASE   when  (travel_and_idle_time > NVL(:travel_time_threshold,0) )'
||                                                 'then (travel_and_idle_time - NVL(:travel_time_threshold,travel_and_idle_time)) '
||                                                 'else 0 '
||                                         'end )'
||                                 ' /:expected_idle_time '
||                                         ')*100 < NVL(wers.Per_Expected_Time_To,100000) '
||                               ' )'  ;

l_sql := l_sql ||' where els_data_id IS NULL AND transaction_date IS NOT NULL AND els_trx_src_id <= :l_max_id';


IF g_debug=1 THEN
 debug('The sql clause constructed','MATCH_RATE_TRX_RECORDS');
END IF;

l_sql := l_sql||l_where_clause;

IF g_debug=1 THEN
 debug('The  l_sql finally constructed  ','MATCH_RATE_TRX_RECORDS');
END IF;

c:= dbms_sql.open_cursor;

IF g_debug=1 THEN
 debug('Opened the cursor for Binding ','MATCH_RATE_TRX_RECORDS');
END IF;

DBMS_SQL.parse(c, l_sql, DBMS_SQL.native);


IF g_debug=1 THEN
 debug('Starting Binding the variables ','MATCH_RATE_TRX_RECORDS');
END IF;

DBMS_SQL.bind_variable(c, 'l_max_id', l_max_id);

DBMS_SQL.bind_variable(c, 'els_data_id', l_els_data.els_data_id);

DBMS_SQL.bind_variable(c, 'source_zone', l_els_data.source_zone_id);

DBMS_SQL.bind_variable(c, 'destination_zone', l_els_data.destination_zone_id);

DBMS_SQL.bind_variable(c, 'item_category', l_els_data.item_category_id);

DBMS_SQL.bind_variable(c, 'travel_time_threshold', l_els_data.travel_time_threshold);

DBMS_SQL.bind_variable(c, 'org_id', p_org_id);

DBMS_SQL.bind_variable(c, 'expected_trx_time', l_els_data.expected_txn_time);

DBMS_SQL.bind_variable(c, 'expected_travel_time', l_els_data.expected_travel_time);

DBMS_SQL.bind_variable(c, 'expected_idle_time', l_els_data.expected_idle_time);

IF l_els_data.organization_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'organization_id', l_els_data.organization_id);
END IF;

IF l_els_data.activity_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'activity_id', l_els_data.activity_id);
END IF;

IF l_els_data.activity_detail_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'activity_detail_id', l_els_data.activity_detail_id);
END IF;

IF l_els_data.operation_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'operation_id', l_els_data.operation_id);
END IF;

IF l_els_data.equipment_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'equipment_id', l_els_data.equipment_id);
END IF;

IF l_els_data.source_zone_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'source_zone_id', l_els_data.source_zone_id);
END IF;

IF l_els_data.source_subinventory IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'source_subinventory', l_els_data.source_subinventory);
END IF;

IF l_els_data.destination_zone_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'destination_zone_id', l_els_data.destination_zone_id);
END IF;

IF l_els_data.destination_subinventory IS NOT NULL
THEN
    DBMS_SQL.bind_variable(c, 'destination_subinventory', l_els_data.destination_subinventory);
END IF;

IF l_els_data.labor_txn_source_id IS NOT NULL
THEN
    DBMS_SQL.bind_variable(c, 'labor_txn_source_id', l_els_data.labor_txn_source_id);
END IF;

IF l_els_data.transaction_uom IS NOT NULL
THEN
    DBMS_SQL.bind_variable(c, 'transaction_uom', l_els_data.transaction_uom);
END IF;

IF l_els_data.from_quantity IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'from_quantity', l_els_data.from_quantity);
END IF;

IF l_els_data.to_quantity IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'to_quantity', l_els_data.to_quantity);
END IF;

IF l_els_data.item_category_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'item_category_id', l_els_data.item_category_id);
END IF;

IF l_els_data.operation_plan_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'operation_plan_id', l_els_data.operation_plan_id);
END IF;

IF l_els_data.group_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'group_id', l_els_data.group_id);
END IF;

IF l_els_data.task_type_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'task_type_id', l_els_data.task_type_id);
END IF;

IF l_els_data.task_method_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'task_method_id', l_els_data.task_method_id);
END IF;

IF g_debug=1 THEN
 debug('All variables bound '|| l_sql,'MATCH_RATE_TRX_RECORDS');
END IF;

l_update_count  := DBMS_SQL.EXECUTE(c);

IF g_debug=1 THEN
 debug('SQL executed Number of rows updated '|| l_update_count,'MATCH_RATE_TRX_RECORDS');
END IF;

l_total := l_update_count + NVL(l_els_data.num_trx_matched,0);

DBMS_SQL.close_cursor(c);

--update the count with newly matched transactions

UPDATE wms_els_individual_tasks_b
SET
num_trx_matched = l_total
WHERE els_data_id = l_els_data.els_data_id;

EXCEPTION
WHEN OTHERS THEN

l_num_execution_failed_tasks := l_num_execution_failed_tasks +1;
IF g_debug=1 THEN
 debug('Execution failed for the els_data_id  '|| l_els_data.els_data_id,'MATCH_RATE_EXP_RESOURCE');
 debug('Exception occured '|| sqlerrm,'MATCH_RATE_TRX_RECORDS');
END IF;

END;

END LOOP; -- all els_rows exhausted

CLOSE c_els_data;

-- Now do the matching for groups

-- populate a pl/sql table type with the trx table records grouped by
-- the grouped_task_identifier.

--Populate the global temporary table

IF g_debug=1 THEN
 debug('Execution finished for Individual tasks','MATCH_RATE_TRX_RECORDS');
 debug('Starting Execution for matching  Grouped tasks','MATCH_RATE_TRX_RECORDS');
 debug('Populating Global temporary table ','MATCH_RATE_TRX_RECORDS');
END IF;



INSERT INTO WMS_ELS_GROUPED_TASKS_GTMP
(
els_grouped_task_id,
organization_id,
activity_id,
activity_detail_id,
operation_id,
labor_txn_source_id,
source_zone_id,
source_subinventory,
destination_zone_id,
destination_subinventory,
num_transactions,
task_method,
group_size,
sum_travel_time
)
SELECT   WMS_ELS_GROUPED_TASKS_S.NEXTVAL,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         labor_txn_source_id,
         source_zone_id,
         source_subinventory,
	     destination_zone_id,
	     destination_subinventory,
         num_tasks,
         task_method_id,
         group_size,
         total_travel_time
FROM
(
SELECT
       organization_id,
       activity_id,
       activity_detail_id,
       operation_id,
       labor_txn_source_id,
       source_zone_id,
       source_subinventory,
	   destination_zone_id,
	   destination_subinventory,
       count(*) num_tasks,
       task_method_id,
       group_size,
       SUM(travel_time) total_travel_time
FROM   wms_els_trx_src
WHERE  organization_id = p_org_id
AND    match_group = 1
AND    transaction_date IS NOT NULL
AND    grouped_task_identifier IS NOT NULL
GROUP BY grouped_task_identifier,organization_id,activity_id,
         activity_detail_id,operation_id,labor_txn_source_id,
         source_zone_id,source_subinventory,destination_zone_id,destination_subinventory,
		   task_method_id,group_size
);

IF g_debug=1 THEN
 debug('Finished Populating Global temporary table ','MATCH_RATE_TRX_RECORDS');
END IF;


-- open the cursor for the passed org_id
IF g_debug=1 THEN
 debug('Opening cursor for wms_els_grouped_tasks_b ','MATCH_RATE_TRX_RECORDS');
END IF;

OPEN c_els_grouped_data(p_org_id);

LOOP
FETCH c_els_grouped_data INTO l_group_data;
EXIT WHEN c_els_grouped_data%NOTFOUND;

-- open the cursor for the passed org_id
BEGIN

IF g_debug=1 THEN
 debug('Start building the where clause for wms_els_grouped_tasks_b ','MATCH_RATE_TRX_RECORDS');
END IF;

l_where_clause := NULL;
l_update_count := 0;

IF l_group_data.organization_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND organization_id = :organization_id ';
END IF;

IF l_group_data.activity_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND activity_id = :activity_id ';
END IF;

IF l_group_data.activity_detail_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND activity_detail_id = :activity_detail_id ';
END IF;

IF l_group_data.operation_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND operation_id = :operation_id ';
END IF;

IF l_group_data.source_zone_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND source_zone_id = :source_zone_id ';
END IF;

IF l_group_data.source_subinventory IS NOT NULL
THEN
   l_where_clause := l_where_clause ||' AND source_subinventory = :source_subinventory ';
END IF;

IF l_group_data.destination_zone_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND destination_zone_id = :destination_zone_id ';
END IF;

IF l_group_data.destination_subinventory IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND destination_subinventory = :destination_subinventory ';
END IF;

IF l_group_data.task_range_from IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND num_transactions > :task_range_from ' ;
END IF;

IF l_group_data.task_range_to IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND num_transactions < :task_range_to ' ;
END IF;

IF l_group_data.task_method_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND task_method =:task_method_id ' ;
END IF;


IF g_debug=1 THEN
 debug('Where clause built successfully '||  l_where_clause ,'MATCH_RATE_TRX_RECORDS');
END IF;

-- flush out l_sql so that it does not hold any old values
l_sql:= NULL;

l_sql:= ' UPDATE WMS_ELS_GROUPED_TASKS_GTMP '
||      ' SET els_group_id = :els_group_id '
||      ' where els_group_id IS NULL '
||        l_where_clause ;

IF g_debug=1 THEN
 debug('SQL  clause built successfully '||  l_sql ,'MATCH_RATE_TRX_RECORDS');
END IF;

c:= dbms_sql.open_cursor;

DBMS_SQL.parse(c, l_sql, DBMS_SQL.native);

IF g_debug=1 THEN
 debug('Start bining the variables '||  l_where_clause ,'MATCH_RATE_TRX_RECORDS');
END IF;

DBMS_SQL.bind_variable(c, 'els_group_id', l_group_data.els_group_id);

IF l_group_data.organization_id IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'organization_id', l_group_data.organization_id);
END IF;

IF l_group_data.activity_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'activity_id', l_group_data.activity_id);
END IF;

IF l_group_data.activity_detail_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'activity_detail_id', l_group_data.activity_detail_id);
END IF;

IF l_group_data.operation_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'operation_id', l_group_data.operation_id);
END IF;

IF l_group_data.source_zone_id IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'source_zone_id', l_group_data.source_zone_id);
END IF;

IF l_group_data.source_subinventory IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'source_subinventory', l_group_data.source_subinventory);
END IF;

IF l_group_data.destination_zone_id IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'destination_zone_id', l_group_data.destination_zone_id);
END IF;

IF l_group_data.destination_subinventory IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'destination_subinventory', l_group_data.destination_subinventory);
END IF;

IF l_group_data.task_range_from IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'task_range_from', l_group_data.task_range_from);
END IF;

IF l_group_data.task_range_to IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'task_range_to', l_group_data.task_range_to);
END IF;

IF l_group_data.task_method_id IS NOT NULL
THEN
  DBMS_SQL.bind_variable(c, 'task_method_id', l_group_data.task_method_id);
END IF;

IF g_debug=1 THEN
 debug('All variables bound successfully','MATCH_RATE_TRX_RECORDS');
END IF;

l_update_count  := DBMS_SQL.EXECUTE(c);

IF g_debug=1 THEN
 debug('SQL executed. Number of rows updated  '||  l_update_count ,'MATCH_RATE_TRX_RECORDS');
END IF;

DBMS_SQL.close_cursor(c);

EXCEPTION
WHEN OTHERS THEN

l_num_execution_failed_group := l_num_execution_failed_group +1;
IF g_debug=1 THEN
 debug('Execution failed for the els_group_id  '|| l_group_data.els_group_id,'MATCH_RATE_TRX_RECORDS');
 debug('Exception occured '|| sqlerrm,'MATCH_RATE_TRX_RECORDS');
END IF;

END;

END LOOP; -- matching for groups is done

CLOSE c_els_grouped_data;

-- start updating the catual timings in the wms_els_grouped_tasks_b table
OPEN c_els_grouped_data_id(p_org_id);
LOOP
FETCH c_els_grouped_data_id INTO l_group_data_id;
EXIT WHEN c_els_grouped_data_id%NOTFOUND;

SELECT avg(sum_travel_time) into l_avg_travel_time from WMS_ELS_GROUPED_TASKS_GTMP
WHERE els_group_id = l_group_data_id.els_group_id;


IF( l_avg_travel_time IS NOT NULL) THEN

UPDATE WMS_ELS_GROUPED_TASKS_B SET actual_travel_time = (NVL(actual_travel_time,0) + l_avg_travel_time)/2
where els_group_id = l_group_data_id.els_group_id;

END IF;

END LOOP;

CLOSE c_els_grouped_data_id;

l_update_count := NULL;

-- now update all txns having els_data_id as NULL with processed flag as 1
-- also update the match_group flag to 2(done)

UPDATE wms_els_trx_src SET unattributed_flag = 1 , match_group = 2
WHERE  els_data_id IS NULL and els_trx_src_id <= l_max_id AND organization_id = p_org_id;

l_update_count := SQL%ROWCOUNT;

IF g_debug=1 THEN
 debug('Number of rows updated as non-standardized '|| l_update_count,'MATCH_RATE_TRX_RECORDS');
 debug('Value of  l_num_execution_failed_tasks '|| l_num_execution_failed_tasks,'MATCH_RATE_TRX_RECORDS');
 debug('Value of  l_num_execution_failed_group'|| l_num_execution_failed_group,'MATCH_RATE_TRX_RECORDS');
END IF;


IF ( l_num_execution_failed_tasks = 0 AND l_num_execution_failed_group = 0 )THEN
-- every thing is done so the concurrent program has finished normal
COMMIT;
retcode := 1;
fnd_message.set_name('WMS', 'WMS_LMS_LP_SUCCESS');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);

ELSE
COMMIT;
retcode := 3;
fnd_message.set_name('WMS', 'WMS_LMS_LP_WARN');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);

END IF;

ELSE -- org is not labor enabled

IF g_debug=1 THEN
 debug('Org is not labor enabled '|| sqlerrm,'MATCH_RATE_TRX_RECORDS');
END IF;

retcode := 3;
fnd_message.set_name('WMS', 'WMS_ORG_NOT_LMS_ENABLED');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);

END IF; -- If org is labor enabled


EXCEPTION

-- handle exception
WHEN OTHERS THEN

IF g_debug=1 THEN
 debug('Exception occured . Close all open cursors'|| sqlerrm,'MATCH_RATE_TRX_RECORDS');
END IF;

IF  c_els_grouped_data_id%ISOPEN THEN
CLOSE c_els_grouped_data_id;
END IF;

IF  c_els_grouped_data%ISOPEN THEN
CLOSE c_els_grouped_data;
END IF;

IF  c_els_data%ISOPEN THEN
CLOSE c_els_data;
END IF;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_MATCH_LP_ERR');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);


END MATCH_RATE_TRX_RECORDS;

END WMS_LMS_LABOR_PRODUCTIVITY;



/
