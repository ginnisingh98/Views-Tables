--------------------------------------------------------
--  DDL for Package Body GMP_FORECAST_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_FORECAST_MIGRATION" AS
/* $Header: GMPFCMIB.pls 120.4 2006/04/12 04:19:35 sowsubra noship $ */

TYPE organization_id IS TABLE OF mrp_forecast_designators.organization_id%TYPE
INDEX BY BINARY_INTEGER;
f_organization_id  organization_id;
f_int_organization_id  organization_id;
i_organization_id  organization_id;

TYPE inventory_item_id IS TABLE OF mrp_forecast_items.inventory_item_id%TYPE
INDEX BY BINARY_INTEGER;
f_inventory_item_id inventory_item_id ;
f_int_inventory_item_id inventory_item_id ;

TYPE forecast_designator IS TABLE OF mrp_forecast_designators.forecast_designator%TYPE INDEX BY BINARY_INTEGER;
i_designator forecast_designator ;
f_forecast_designator forecast_designator ;
f_int_forecast_designator forecast_designator ;

TYPE forecast_set IS TABLE OF mrp_forecast_designators.forecast_set%TYPE INDEX BY BINARY_INTEGER;
i_forecast_set forecast_set;

TYPE description IS TABLE OF mrp_forecast_designators.description%TYPE INDEX BY BINARY_INTEGER;
i_description description ;

TYPE disable_date IS TABLE OF mrp_forecast_designators.disable_date%TYPE INDEX BY BINARY_INTEGER;
i_disable_date disable_date ;

TYPE tconsume_forecast IS TABLE OF mrp_forecast_designators.consume_forecast%TYPE
INDEX BY BINARY_INTEGER;
i_consume_forecast tconsume_forecast ;

TYPE backward_update_time_fence IS TABLE OF mrp_forecast_designators.backward_update_time_fence%TYPE
INDEX BY BINARY_INTEGER;
i_backward_update_time_fence backward_update_time_fence ;

TYPE forward_update_time_fence IS TABLE OF mrp_forecast_designators.foreward_update_time_fence%TYPE
INDEX BY BINARY_INTEGER;
i_forward_update_time_fence forward_update_time_fence ;

TYPE quantity IS TABLE OF mrp_forecast_interface.quantity%TYPE
INDEX BY BINARY_INTEGER;
f_int_quantity quantity ;

TYPE forecast_date IS TABLE OF mrp_forecast_interface.forecast_date%TYPE
INDEX BY BINARY_INTEGER;
f_int_forecast_date forecast_date ;

TYPE fcst_hdr_rec IS RECORD (
fcst_id 		NUMBER,
orig_forecast 		VARCHAR2(16),
fcst_name 		VARCHAR2(10),
fcst_set  		VARCHAR2(10),
desgn_ind 		NUMBER,
consumption_ind		NUMBER,
backward_time_fence	NUMBER,
forward_time_fence	NUMBER
);
TYPE fcst_dtl_tbl_rec IS RECORD
   (
    inventory_item_id   NUMBER,
    organization_id     NUMBER,
    forecast_id         NUMBER,
    line_id             NUMBER,
    forecast            VARCHAR2(16),
    forecast_set        VARCHAR2(10),
    trans_date          DATE,
    orgn_code           VARCHAR2(4),
    trans_qty           NUMBER,
    write_row_flag     NUMBER(1)
  );
TYPE fcst_dtl_tbl_typ IS TABLE OF fcst_dtl_tbl_rec
INDEX BY BINARY_INTEGER ;

fcst_dtl_tbl fcst_dtl_tbl_typ ;

TYPE fcst_valid_rec IS RECORD
   (
    forecast_designator VARCHAR2(10),
    forecast_set        VARCHAR2(10)
   );
TYPE fcst_valid_typ IS TABLE OF fcst_valid_rec
INDEX BY BINARY_INTEGER ;

fcst_valid_tbl fcst_valid_typ;

TYPE fcst_hdr_tab_typ IS TABLE OF fcst_hdr_rec
INDEX BY BINARY_INTEGER ;

fcst_hdr_tbl fcst_hdr_tab_typ ;

PROCEDURE Exec_forecast_Migration
(     P_migration_run_id   IN NUMBER,
      P_commit             IN VARCHAR2,
      X_failure_count      OUT NOCOPY NUMBER
)
IS

TYPE gmp_cursor_typ IS REF CURSOR;
fcst_hdr   	gmp_cursor_typ;
cur_fcst_dtl   	gmp_cursor_typ;
cur_fcst_valid  gmp_cursor_typ;

cnt                  NUMBER ;
l_cnt                NUMBER ;
curr_cnt             NUMBER ;
temp_name            VARCHAR2(10);
i                    NUMBER ;
j                    NUMBER ;
k                    NUMBER ;
x 		     NUMBER ;
duplicate_found      BOOLEAN ;
prev_org_id  	     NUMBER ;
prev_fcst_id	     NUMBER ;
prev_forecast_set    VARCHAR2(10);
--prev_fcst_set	     VARCHAR2(10);
prev_fcst    	     VARCHAR2(10);
prev_fcst_item       NUMBER  ;
write_fcst	     BOOLEAN ;
write_fcst_set	     BOOLEAN ;
write_fcst_item      BOOLEAN ;
fcst_locn	     NUMBER ;
l_exist_flag         NUMBER ;

l_design_stmt        VARCHAR2(5000) ;
l_fcst_stmt   	     VARCHAR2(5000) ;
l_validation_stmt    VARCHAR2(5000) ;
fi_index             NUMBER ;
f_int_index          NUMBER ;
i_index              NUMBER ;
null_value           VARCHAR2(2) ;
fcst_counter         NUMBER ;
fcst_itm_counter     NUMBER ;
fcst_itrf_counter    NUMBER ;
l_location	     VARCHAR2(500);
l_conc_id            NUMBER ;
request_id           NUMBER;
status               VARCHAR2(80);
phase                VARCHAR2(80);
dev_status           VARCHAR2(80);
dev_phase            VARCHAR2(80);
return_message       VARCHAR2(80);
return_flag          BOOLEAN;

BEGIN

   /* Intialize the variables */
   l_location := NULL;
   prev_fcst_item := 0 ;
   temp_name := NULL ;
   cnt       := 0 ;
   l_cnt     := 1 ;
   curr_cnt  := 0 ;
   duplicate_found := FALSE ;

   i := 1 ;
   j := 10 ;
   k := 0 ;
   x := 1;

   prev_org_id  := 0 ;
   prev_fcst_id	:= 0 ;

   fi_index  := 0 ;
   f_int_index := 0 ;
   i_index  := 0 ;

   null_value := null ;
   fcst_counter         := 0;
   fcst_itm_counter     := 0;
   fcst_itrf_counter    := 0;
   l_conc_id            := 0;

   --prev_fcst_set := '-1' ;
   prev_fcst := '-1';
   l_exist_flag := 0;

   l_fcst_stmt := 'SELECT '
             || ' msi.inventory_item_id, '
             || ' nvl(sy.organization_id,msi.organization_id), ' /*B4931593*/
             /*B4931593 - The forecast data is moved to the migrated organization.*/
             || ' h.forecast_id, '
             || ' d.line_id, '
             || ' h.forecast, '
             || ' h.forecast_set  FSET , '
             || ' d.trans_date, '
             || ' d.orgn_code, '
             || ' (d.trans_qty * -1)  trans_qty, '
             || ' 1 write_row_flag '
             || ' FROM '
             || ' mtl_system_items msi, '
             || ' ic_item_mst iim, '
             || ' ic_whse_mst wm, '
             || ' fc_fcst_hdr h, '
             || ' sy_orgn_mst sy, '/*B4931593*/
             || ' fc_fcst_dtl d '
             || ' WHERE '
             || '     msi.organization_id = wm.organization_id '
             || ' and sy.orgn_code = d.orgn_code '/*B4931593*/
             || ' and sy.migrated_ind = 1 '/*B4931593*/
             || ' and msi.segment1 = iim.item_no '
             || ' and wm.delete_mark = 0 '
             || ' and h.forecast_id = d.forecast_id '
             || ' and d.forecast_id > 0  '
             || ' and d.item_id = iim.item_id '
             || ' and d.whse_code = wm.whse_code '
             || ' and d.orgn_code = wm.orgn_code '
             || ' and h.forecast_set is NOT NULL '
             || ' and h.delete_mark = 0 '
             || ' and d.delete_mark = 0 '
             || ' and d.trans_qty <> 0 '
             || ' ORDER BY FSET, wm.organization_id ,h.forecast_id, msi.inventory_item_id ' ;

   -- ===+++++++====++++ build designator++++=======++++=======
   l_design_stmt := 'SELECT '||
   ' forecast_id, '||
   ' forecast, '||
   ' substr(forecast,1,10) DESGN, '||
   ' nvl(forecast_set ,substr(forecast,1,10)) FSET,  '||
   ' 1 DESGN_IND ,' ||
   ' nvl(consumption_ind, 2), '||
   ' backward_time_fence, '||
   ' forward_time_fence '||
   ' FROM fc_fcst_hdr'||
   ' WHERE delete_mark = 0 '||
   ' UNION ALL '||
   -- Add forecast_sets to the list
   ' SELECT '||
   ' -1 , '||
   ' min(forecast), '||
   ' forecast_set DESGN , '||
   ' to_char(NULL) FSET,  '||
   ' 3 DESGN_IND, ' ||
   ' to_number(NULL), '||
   ' to_number(NULL), '||
   ' to_number(NULL) '||
   ' FROM fc_fcst_hdr'||
   ' WHERE delete_mark = 0 '||
   ' AND forecast_set is NOT NULL '||
   ' GROUP BY forecast_set '  ||
   ' ORDER BY FSET, 1 DESC , DESGN_IND ' ;

   OPEN  fcst_hdr FOR l_design_stmt ;
   LOOP
      FETCH fcst_hdr INTO fcst_hdr_tbl(l_cnt);
      EXIT WHEN fcst_hdr%NOTFOUND ;
      l_cnt := l_cnt + 1 ;
   END LOOP ;
   CLOSE fcst_hdr ;
   -- ===================== Logic ==============================
   LOOP
      EXIT  WHEN cnt + 1 > fcst_hdr_tbl.COUNT ;

      IF duplicate_found THEN
         cnt := cnt ;
         duplicate_found := FALSE ;
      ELSE
         IF temp_name IS NOT NULL THEN
            IF (fcst_hdr_tbl(cnt).desgn_ind =  1
                   AND fcst_hdr_tbl(cnt).fcst_name <> temp_name )THEN
            --  	fcst_hdr_tbl(cnt).fcst_set := temp_name ;
               NULL ;
            ELSIF (fcst_hdr_tbl(cnt).desgn_ind =  3
                   AND fcst_hdr_tbl(cnt).fcst_name <> temp_name )THEN
             -- This means we changed a set name
             -- Now change the name in all resords of fcst that used this as set
               FOR y IN 1..fcst_hdr_tbl.COUNT
               LOOP
                IF (fcst_hdr_tbl(y).fcst_set = fcst_hdr_tbl(cnt).fcst_name
                     AND fcst_hdr_tbl(y).desgn_ind =  1 ) THEN
                     fcst_hdr_tbl(y).fcst_set := temp_name  ;
                END IF ;
               END LOOP;
   /* nsinghi : Commented the following elsif clause as we will not generate set names. */
   /*         ELSIF (fcst_hdr_tbl(cnt).desgn_ind = 2
                       AND fcst_hdr_tbl(cnt).fcst_name <> temp_name )THEN
             -- This means we changed a set name that was "generated"
             -- Now change the name in the resord of fcst that used itself as set
               FOR y in 1..fcst_hdr_tbl.COUNT
               LOOP
                 IF (fcst_hdr_tbl(y).orig_forecast = fcst_hdr_tbl(cnt).orig_forecast
                      AND fcst_hdr_tbl(y).desgn_ind  = 1 )THEN
                      fcst_hdr_tbl(y).fcst_set := temp_name  ;
                 END IF ;
               END LOOP;
   */
            END IF ; -- desgn_ind check
            fcst_hdr_tbl(cnt).fcst_name := temp_name ;
         END IF ;
         cnt := cnt  + 1 ;
         j := 10 ;
         k := 0 ;
      END IF ;

      IF j < 10 THEN
         temp_name := substr(fcst_hdr_tbl(cnt).fcst_name,1,j)||to_char(k) ;
      ELSE
         temp_name := fcst_hdr_tbl(cnt).fcst_name ;
      END IF ;

      curr_cnt := cnt ;
      i := 1 ;

      LOOP
         EXIT WHEN i > fcst_hdr_tbl.COUNT ;
         IF i <> curr_cnt THEN
         -- so that record is not compared to itself
            IF temp_name  = fcst_hdr_tbl(i).fcst_name THEN
               duplicate_found := TRUE ;
               k := k + 1 ;
               IF k < 10 THEN
                  j := 9 ;
               ELSIF k < 100 THEN
                  j := 8 ;
               ELSIF k < 1000 THEN
                  j := 7 ;
               ELSIF k < 10000 THEN
                  j := 6 ;
               ELSIF k < 100000 THEN
                  j := 5 ;
               END IF ;
               EXIT ;
            END IF ;
         END IF ; -- i <> curr_cnt
         i := i + 1 ;
      END LOOP ;

   END LOOP ; -- Outer loop

/*
FOR x in 1..fcst_hdr_tbl.COUNT
LOOP
dbms_output.put_line(fcst_hdr_tbl(x).fcst_id||
		'='||fcst_hdr_tbl(x).orig_forecast ||
		'='||fcst_hdr_tbl(x).desgn_ind ||
		'='||fcst_hdr_tbl(x).fcst_name ||
		'='||fcst_hdr_tbl(x).fcst_set ) ;
END LOOP;
*/
-- ===+++++++====++++ build designator++++=======++++=======

/* nsinghi: Till this point the code ensures that all the forecast_designator
names are not duplicated. */

   cnt := 0;
   OPEN cur_fcst_dtl FOR l_fcst_stmt;
   LOOP
      FETCH cur_fcst_dtl INTO fcst_dtl_tbl(cnt);
      EXIT WHEN cur_fcst_dtl%NOTFOUND;
      cnt := cnt + 1;
   END LOOP;
   CLOSE cur_fcst_dtl;
   cnt := cnt - 1;

   IF fcst_dtl_tbl.COUNT > 0 THEN
      FOR lp_cnt IN fcst_dtl_tbl.FIRST..fcst_dtl_tbl.LAST
      LOOP
         write_fcst     := FALSE ;
         write_fcst_set := FALSE ;
         write_fcst_item := FALSE;

          IF fcst_dtl_tbl(lp_cnt).forecast_set <> prev_forecast_set THEN
             fcst_counter := 0;
             fcst_itm_counter := 0;
             fcst_itrf_counter := 0;
          END IF;

          IF fcst_dtl_tbl(lp_cnt).forecast_id <> prev_fcst_id THEN
             FOR i IN fcst_hdr_tbl.FIRST..fcst_hdr_tbl.LAST
             LOOP
                IF fcst_dtl_tbl(lp_cnt).forecast_id = fcst_hdr_tbl(i).fcst_id THEN
                   fcst_locn := i  ;
                   EXIT ;
                END IF ;
             END LOOP ;

   /* Everytime the forecast changes, check if the new forecast or forecast_set name
   already exist in Oracle Forecasting.
   If the forecast or forecast set already exist in the discrete mrp_forecast_designator
   table, then do not migrate that forecast. That forecast will need to be manually
   inserted to the discrete forecasting module. */

   --        BEGIN

             l_validation_stmt := ' SELECT forecast_designator, forecast_set '||
                        ' FROM mrp_forecast_designators  '||
                        ' WHERE (forecast_designator = '|| '''' || fcst_hdr_tbl(fcst_locn).fcst_set || '''' ||
                        '     OR forecast_designator = '|| '''' || fcst_hdr_tbl(fcst_locn).fcst_name|| '''' || ' ) '||
                        ' AND organization_id = '||fcst_dtl_tbl(lp_cnt).organization_id ;

             IF fcst_valid_tbl.COUNT > 0 THEN
                fcst_valid_tbl.DELETE;
             END IF;

             i := 0;
             OPEN cur_fcst_valid FOR l_validation_stmt;
             LOOP
                 FETCH cur_fcst_valid INTO fcst_valid_tbl(i);
                 EXIT WHEN cur_fcst_valid%NOTFOUND;
                 i := i + 1;
             END LOOP ;
             i := i - 1;

             IF fcst_valid_tbl.COUNT > 0 THEN
                IF fcst_valid_tbl.COUNT > 1 OR
                   (fcst_valid_tbl.COUNT = 1 AND
                      fcst_valid_tbl(0).forecast_designator = fcst_hdr_tbl(fcst_locn).fcst_name) THEN
                /* As the forecast name is present in Discrete Oracle Forecasting,
                so the current forecast and any forecast having the same set as current
                forecast's set should not be migrated. */
                   /* 1. Dont write this forecast and forecast_set.
                      2. Dont write any forecast having fcst_set as set
                      3. Decrease the index to overwrite the already written row.*/
                   fcst_dtl_tbl(lp_cnt).write_row_flag := 0;
                   x_failure_count := x_failure_count + 1;
                   FOR i IN lp_cnt..fcst_dtl_tbl.LAST
                   LOOP
                      IF fcst_dtl_tbl(lp_cnt).forecast_set = fcst_dtl_tbl(i).forecast_set THEN
                         fcst_dtl_tbl(i).write_row_flag := 0;
                         x_failure_count := x_failure_count + 1;
                      ELSIF fcst_dtl_tbl(i).forecast_set > fcst_dtl_tbl(lp_cnt).forecast_set THEN
                         EXIT;
                      END IF;
                   END LOOP;

                   IF fcst_counter > 0 THEN
                   /* Atleast 1 or more forecast belonging to this forecast_set has already
                   been written and needs to be overridden. */
                      x_failure_count := x_failure_count + fcst_counter;
                      i_index := i_index - fcst_counter ;
                      fi_index := fi_index - fcst_itm_counter ;
                      f_int_index := f_int_index - fcst_itrf_counter ;
                   /* Resetting the counter values. If the same forecast name appears for
                   different org, the index will not get decremented by counters again. */
                      fcst_counter := 0;
                      fcst_itm_counter := 0;
                      fcst_itrf_counter := 0;
                   END IF;

                   /* Log Messages */
                   IF (fcst_valid_tbl.COUNT = 1 AND
                      fcst_valid_tbl(0).forecast_designator = fcst_hdr_tbl(fcst_locn).fcst_name) THEN

/*                         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Oracle Process Manufacturing Forecast : '
                         || fcst_hdr_tbl(fcst_locn).fcst_name ||' is defined in Oracle Forecasting ' );
                         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Any Forecast belonging to Forecast Set : '
                         || fcst_hdr_tbl(fcst_locn).fcst_set ||' will NOT be migrated to Oracle Forecasting ' );
*/
                         GMA_COMMON_LOGGING.gma_migration_central_log (
                           p_run_id          => P_migration_run_id,
                           p_log_level       => FND_LOG.LEVEL_ERROR,
                           p_message_token   => 'GMA_MIGRATION_FAIL',
                           p_table_name      => 'FC_FCST_HDR',
                           p_context         => 'DUPLICATE_FORECAST',
                           p_app_short_name  => 'GMP',
                           P_Param1          => ' Forecast '||fcst_hdr_tbl(fcst_locn).fcst_name||' is already defined in Oracle Forecasting ',
                           P_Param2          => 'Any forecast belonging to Forecast Set '||fcst_hdr_tbl(fcst_locn).fcst_set||' will not be migrated. ');
                   END IF;
                   IF (fcst_valid_tbl.COUNT > 1) THEN
/*
                         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Both, Oracle Process Manufacturing Forecast : '
                         || fcst_hdr_tbl(fcst_locn).fcst_name ||' and Forecast Set : '||fcst_hdr_tbl(fcst_locn).fcst_set
                         ||' are defined in Oracle Forecasting ' );
                         FND_FILE.PUT_LINE( FND_FILE.LOG, 'Any Forecast belonging to Forecast Set : '
                         || fcst_hdr_tbl(fcst_locn).fcst_set ||' will NOT be migrated to Oracle Forecasting ' );
*/
                         GMA_COMMON_LOGGING.gma_migration_central_log (
                           p_run_id          => P_migration_run_id,
                           p_log_level       => FND_LOG.LEVEL_ERROR,
                           p_message_token   => 'GMA_MIGRATION_FAIL',
                           p_table_name      => 'FC_FCST_HDR',
                           p_context         => 'DUPLICATE_FORECAST',
                           p_app_short_name  => 'GMP',
                           P_Param1          => 'Both forecast '||fcst_hdr_tbl(fcst_locn).fcst_name||' and forecast set '||fcst_hdr_tbl(fcst_locn).fcst_set||' are already defined in Oracle Forecasting ',
                           P_Param2          => 'Any forecast belonging to Forecast Set '||fcst_hdr_tbl(fcst_locn).fcst_set||' will not be migrated. ');
                   END IF;

                ELSIF fcst_valid_tbl.COUNT = 1 AND
                   fcst_valid_tbl(0).forecast_designator = fcst_hdr_tbl(fcst_locn).fcst_set THEN
                   /* As the order by clause is on forecast set and as forecast set is defined in
                   Discrete Oracle Forecasting, hence do not send any forecast associated to this
                   forecast set.
                      1. Dont write this forecast and forecast_set.
                      2. Loop forward through the fcst_dtl_tbl(lp_cnt) and set the write_row_flag to 0 for
                         all rows having this forecast_set as set. */
                   fcst_dtl_tbl(lp_cnt).write_row_flag := 0;
                   FOR i IN lp_cnt..fcst_dtl_tbl.LAST
                   LOOP
                      IF fcst_dtl_tbl(lp_cnt).forecast_set = fcst_dtl_tbl(i).forecast_set THEN
                         fcst_dtl_tbl(i).write_row_flag := 0;
                         x_failure_count := x_failure_count + 1;
                      END IF;
                   END LOOP;
/*
                   FND_FILE.PUT_LINE( FND_FILE.LOG, 'Oracle Process Manufacturing Forecast Set : '
                   || fcst_hdr_tbl(fcst_locn).fcst_set ||' is defined in Oracle Forecasting ' );
                   FND_FILE.PUT_LINE( FND_FILE.LOG, 'Forecast : '|| fcst_hdr_tbl(fcst_locn).fcst_name
                   ||' belonging to above Forecast Set will NOT be migrated to Oracle Forecasting ' );
*/
                   GMA_COMMON_LOGGING.gma_migration_central_log (
                     p_run_id          => P_migration_run_id,
                     p_log_level       => FND_LOG.LEVEL_ERROR,
                     p_message_token   => 'GMA_MIGRATION_FAIL',
                     p_table_name      => 'FC_FCST_HDR',
                     p_context         => 'DUPLICATE_FORECAST',
                     p_app_short_name  => 'GMP',
                     P_Param1          => ' Forecast set '||fcst_hdr_tbl(fcst_locn).fcst_set||' is already defined in Oracle Forecasting ',
                     P_Param2          => 'Forecast : '|| fcst_hdr_tbl(fcst_locn).fcst_name ||' belonging to above Forecast Set will NOT be migrated to Oracle Forecasting ');

                END IF; /* fcst_valid_tbl.COUNT > 1 */
             END IF; /* fcst_valid_tbl.COUNT > 0 */
          END IF; /* fcst_dtl_tbl(lp_cnt).forecast_id <> prev_fcst_id */



       IF fcst_dtl_tbl(lp_cnt).forecast_set <> prev_forecast_set THEN
          write_fcst_set := TRUE ;
          write_fcst     := TRUE ;
          write_fcst_item := TRUE;

       ELSIF fcst_dtl_tbl(lp_cnt).organization_id <> prev_org_id THEN
          write_fcst_set := TRUE ;
          write_fcst     := TRUE ;
          write_fcst_item := TRUE;

       ELSIF fcst_dtl_tbl(lp_cnt).forecast_id <> prev_fcst_id THEN
          write_fcst     := TRUE ;
          write_fcst_item := TRUE;

       ELSIF fcst_dtl_tbl(lp_cnt).inventory_item_id <> prev_fcst_item THEN
          write_fcst_item := TRUE;

       END IF;

          prev_forecast_set := fcst_dtl_tbl(lp_cnt).forecast_set;
          prev_org_id := fcst_dtl_tbl(lp_cnt).organization_id;
          prev_fcst_id := fcst_dtl_tbl(lp_cnt).forecast_id;
          prev_fcst_item := fcst_dtl_tbl(lp_cnt).inventory_item_id;

      IF write_fcst_set AND fcst_dtl_tbl(lp_cnt).write_row_flag = 1 THEN

              -- Write the Forecast Set Details to MRP_FORECAST_DESIGNATORS.
              i_index := i_index + 1 ;
              i_designator(i_index) :=  fcst_hdr_tbl(fcst_locn).fcst_set ;
              i_forecast_set(i_index) :=  to_char(NULL) ;
              i_organization_id(i_index) :=  fcst_dtl_tbl(lp_cnt).organization_id ;
              i_description(i_index) :=  fcst_hdr_tbl(fcst_locn).fcst_set ;
              i_disable_date(i_index) := TO_DATE(NULL);  /* disable date */
              i_consume_forecast(i_index) := NVL(fcst_hdr_tbl(fcst_locn).consumption_ind,2) ;
              i_backward_update_time_fence(i_index) :=  fcst_hdr_tbl(fcst_locn).backward_time_fence ;
              i_forward_update_time_fence(i_index) := fcst_hdr_tbl(fcst_locn).forward_time_fence ;

   --           prev_fcst_set := fcst_hdr_tbl(fcst_locn).fcst_set ;
              fcst_counter := fcst_counter + 1;

      END IF ;

      IF write_fcst AND fcst_dtl_tbl(lp_cnt).write_row_flag = 1 THEN

              -- Write the Forecast Details to MRP_FORECAST_DESIGNATORS.
              i_index := i_index + 1 ;
              i_designator(i_index) := fcst_hdr_tbl(fcst_locn).fcst_name ;
              i_forecast_set(i_index) := fcst_hdr_tbl(fcst_locn).fcst_set ;
              i_organization_id(i_index) := fcst_dtl_tbl(lp_cnt).organization_id ;
              i_description(i_index) :=  fcst_hdr_tbl(fcst_locn).fcst_name ;
              i_disable_date(i_index) := TO_DATE(NULL);  /* disable date */
              i_consume_forecast(i_index) := NVL(fcst_hdr_tbl(fcst_locn).consumption_ind,2) ;
              i_backward_update_time_fence(i_index) :=  fcst_hdr_tbl(fcst_locn).backward_time_fence ;
              i_forward_update_time_fence(i_index) := fcst_hdr_tbl(fcst_locn).forward_time_fence ;
              fcst_counter := fcst_counter + 1;

      END IF ;

      IF write_fcst_item AND fcst_dtl_tbl(lp_cnt).write_row_flag = 1 THEN

              fcst_itm_counter := fcst_itm_counter + 1;

               -- Write the Forecast Items Details to MRP_FORECAST_ITEMS.
              /* Demands Bulk inserts */
              fi_index := fi_index + 1 ;
              f_organization_id(fi_index) := fcst_dtl_tbl(lp_cnt).organization_id ;
              f_inventory_item_id(fi_index) := fcst_dtl_tbl(lp_cnt).inventory_item_id ;
              f_forecast_designator(fi_index) := fcst_hdr_tbl(fcst_locn).fcst_name ; /* forecast designator */

           END IF;

           IF fcst_dtl_tbl(lp_cnt).write_row_flag = 1 THEN
              fcst_itrf_counter := fcst_itrf_counter + 1;

                -- Write Forecast Dates and Qty Details to Interface Table MRP_FORECAST_INTERFACE.
              f_int_index := f_int_index + 1 ;
              f_int_organization_id(f_int_index) := fcst_dtl_tbl(lp_cnt).organization_id ;
              f_int_inventory_item_id(f_int_index) := fcst_dtl_tbl(lp_cnt).inventory_item_id ;
              f_int_forecast_date(f_int_index) := fcst_dtl_tbl(lp_cnt).trans_date ;
              f_int_quantity(f_int_index) :=  fcst_dtl_tbl(lp_cnt).trans_qty ;
              f_int_forecast_designator(f_int_index) := fcst_hdr_tbl(fcst_locn).fcst_name ; /* forecast designator */
           END IF;

        END LOOP ;
     END IF;

/* ----------------------- Designator Insert --------------------- */

      i := 1 ;
--      fnd_file.put_line( FND_FILE.LOG, i_organization_id.FIRST || ' *Designator*' || i_index );
      IF i_organization_id.FIRST > 0 THEN

         GMA_COMMON_LOGGING.gma_migration_central_log (
           p_run_id          => P_migration_run_id,
           p_log_level       => FND_LOG.LEVEL_PROCEDURE,
           p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
           p_table_name      => 'MRP_FORECAST_DESIGNATORS',
           p_context         => 'FORECAST',
           p_app_short_name  => 'GMP');

         FOR i IN i_organization_id.FIRST..i_index
         LOOP
             INSERT INTO mrp_forecast_designators (
             forecast_designator,
             forecast_set,
             organization_id,
             description,
             disable_date,
             consume_forecast,
             update_type,
             backward_update_time_fence,
             foreward_update_time_fence,
             bucket_type,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by
             )
             VALUES (
             i_designator(i)     ,
             i_forecast_set(i)   ,
             i_organization_id(i),
             i_description(i)    ,
             i_disable_date(i)    ,
             i_consume_forecast(i),
             6,           /* Update Type,For Process value will be 6 */
             i_backward_update_time_fence(i),
             i_forward_update_time_fence(i) ,
             1,           /* bucket_type */
             SYSDATE,
             0,
             SYSDATE,
             0
             ) ;
         END LOOP;

      END IF ;

/* ----------------------- Forecast Item Insert --------------------- */
      i := 1 ;
--      fnd_file.put_line( FND_FILE.LOG, f_organization_id.FIRST || ' *Forecast Item*' || fi_index );
      IF f_organization_id.FIRST > 0 THEN

         GMA_COMMON_LOGGING.gma_migration_central_log (
           p_run_id          => P_migration_run_id,
           p_log_level       => FND_LOG.LEVEL_PROCEDURE,
           p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
           p_table_name      => 'MRP_FORECAST_ITEMS',
           p_context         => 'FORECAST',
           p_app_short_name  => 'GMP');

         FOR i IN f_organization_id.FIRST..fi_index
         LOOP
           INSERT INTO mrp_forecast_items (
           organization_id,
           inventory_item_id,
           forecast_designator,
           last_update_date, /* Confirm WHO Column values*/
           last_updated_by,
           creation_date,
           created_by
           )
           VALUES (
           f_organization_id(i),
           f_inventory_item_id(i),
           f_forecast_designator(i),
           SYSDATE,
           0,
           SYSDATE,
           0
           ) ;
         END LOOP;
      END IF ;

      IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
      END IF;

      IF i_organization_id.FIRST > 0 THEN

         GMA_COMMON_LOGGING.gma_migration_central_log (
           p_run_id          => P_migration_run_id,
           p_log_level       => FND_LOG.LEVEL_PROCEDURE,
           p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
           p_table_name      => 'MRP_FORECAST_DESIGNATORS',
           p_context         => 'FORECAST',
           p_app_short_name  => 'GMP');

      END IF;

      IF f_organization_id.FIRST > 0 THEN

         GMA_COMMON_LOGGING.gma_migration_central_log (
           p_run_id          => P_migration_run_id,
           p_log_level       => FND_LOG.LEVEL_PROCEDURE,
           p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
           p_table_name      => 'MRP_FORECAST_ITEMS',
           p_context         => 'FORECAST',
           p_app_short_name  => 'GMP');

      END IF;

/* ----------------------- Forecast Interface Insert --------------------- */
      i := 1 ;
--      fnd_file.put_line( FND_FILE.LOG, f_organization_id.FIRST || ' *Forecast Interface*' || f_int_index );
      IF f_int_organization_id.FIRST > 0 THEN

         GMA_COMMON_LOGGING.gma_migration_central_log (
           p_run_id          => P_migration_run_id,
           p_log_level       => FND_LOG.LEVEL_PROCEDURE,
           p_message_token   => 'GMA_MIGRATION_TABLE_STARTED',
           p_table_name      => 'MRP_FORECAST_INTERFACE',
           p_context         => 'FORECAST',
           p_app_short_name  => 'GMP');

         FOR i IN f_int_organization_id.FIRST..f_int_index
         LOOP
           INSERT INTO mrp_forecast_interface (
           organization_id,
           inventory_item_id,
           forecast_date,
           quantity,
           bucket_type,
           forecast_designator,
           process_status,
           confidence_percentage,
           workday_control,
           last_update_date, /* Confirm WHO Column values*/
           last_updated_by,
           creation_date,
           created_by
            )
           VALUES (
           f_int_organization_id(i),
           f_int_inventory_item_id(i),
           f_int_forecast_date(i),
           f_int_quantity(i),
           1,                /* bucket_type  */
           f_int_forecast_designator(i),
           2, /* process_status */
           100, /* Need to confirm the value */
           3, /* workday_control */
           SYSDATE,
           0,
           SYSDATE,
           0
           ) ;
         END LOOP;
      END IF ;

      IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
      END IF;

      IF f_int_organization_id.FIRST > 0 THEN
         GMA_COMMON_LOGGING.gma_migration_central_log (
           p_run_id          => P_migration_run_id,
           p_log_level       => FND_LOG.LEVEL_PROCEDURE,
           p_message_token   => 'GMA_MIGRATION_TABLE_SUCCESS',
           p_table_name      => 'MRP_FORECAST_INTERFACE',
           p_context         => 'FORECAST',
           p_app_short_name  => 'GMP');
        END IF;

      IF f_organization_id.FIRST > 0 THEN

         return_flag := fnd_concurrent.get_request_status
         (
				request_id,
				'MRP',
				'MRCRLF',
				phase,
				status,
            dev_phase,
            dev_status,
            return_message
         );

         IF ((dev_phase <> 'RUNNING') AND (dev_phase <> 'PENDING')) THEN

            l_conc_id := Fnd_Request.Submit_Request('MRP', 'MRCRLF', '', '', FALSE,
            30, chr(0), '', '',
            '','','','','','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','','','','','',
            '','','','','','','','','','','','','','','','');
         END IF;
      END IF;
EXCEPTION

	WHEN OTHERS THEN

      GMA_COMMON_LOGGING.gma_migration_central_log (
        p_run_id          => P_migration_run_id,
        p_log_level       => FND_LOG.LEVEL_UNEXPECTED,
        p_message_token   => 'GMA_MIGRATION_DB_ERROR',
        p_table_name      => 'FC_FCST_HDR',
        p_context         => 'FORECAST',
        p_db_error        => SQLERRM,
        p_app_short_name  => 'GMP');

        ROLLBACK;

/*
      fnd_file.put_line( FND_FILE.LOG, 'Failure occured during the Migrate_Forecast');
      fnd_file.put_line( FND_FILE.LOG,SQLERRM);
      ROLLBACK;
*/

END Exec_forecast_Migration ;

END GMP_forecast_migration;

/
