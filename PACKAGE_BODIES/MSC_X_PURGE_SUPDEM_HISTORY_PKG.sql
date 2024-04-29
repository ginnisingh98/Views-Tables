--------------------------------------------------------
--  DDL for Package Body MSC_X_PURGE_SUPDEM_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_PURGE_SUPDEM_HISTORY_PKG" AS
/* $Header: MSCXPHSB.pls 120.1 2005/09/22 03:46:42 vdeshmuk noship $ */

PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
IS
BEGIN
	IF fnd_global.conc_request_id > 0  THEN
		 FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
	ELSE
		 null;
		 --DBMS_OUTPUT.PUT_LINE( pBUFF);
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		RETURN;
END LOG_MESSAGE;

PROCEDURE purge_sup_dem_history (
  p_errbuf              out nocopy varchar2,
  p_retcode             out nocopy varchar2,
  p_from_date           in varchar2     , /*bug 4504227 */
  p_to_date             in varchar2     , /*bug 4504227 */
  p_order_type		In Number
) IS



lv_sql_stmt         VARCHAR2(2048);
lv_sql_stmt1         VARCHAR2(2048);
lv_task_start_time  DATE;
lv_retval           boolean;
lv_dummy1           varchar2(32);
lv_dummy2           varchar2(32);
lv_msc_schema       varchar2(32);
----------------------------------------------------------------
-- begin
-----------------------------------------------------------------

lv_from_date_offset      number;
lv_to_date_offset        number;

BEGIN

    if (p_from_date is not null) then
        log_message('p_from_date  '||p_from_date) ;
	 lv_from_date_offset := sysdate-fnd_date.canonical_to_date(p_from_date);  /* Bug  4504227 */
        log_message('lv_from_date_offset  '||lv_from_date_offset) ;
    end if;

    if (p_to_date is not null) then
        log_message('p_to_date  '||p_to_date) ;
	 lv_to_date_offset := sysdate-fnd_date.canonical_to_date(p_to_date); /* Bug 4504227 */
         log_message('lv_to_date_offset  '||lv_to_date_offset) ;

    end if;

    lv_task_start_time:= SYSDATE;

    lv_retval := FND_INSTALLATION.GET_APP_INFO (
			   'MSC', lv_dummy1, lv_dummy2, lv_msc_schema);

     IF (p_from_date is null)
       and (p_to_date is null)
       and (p_order_type is null) then

          /* IF no parameters provided, then truncate the table */
	   lv_sql_stmt:= 'TRUNCATE TABLE '||lv_msc_schema||'.MSC_SUP_DEM_HISTORY';

	   EXECUTE IMMEDIATE lv_sql_stmt;
	   COMMIT;
		 LOG_MESSAGE('Table MSC_SUP_DEM_HISTORY truncated.');

		 FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
		 FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
			     TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
		 LOG_MESSAGE('   '||FND_MESSAGE.GET);

     ELSE
                /* create the basic delete sql for Deletes in batches of 100K */
	        lv_sql_stmt := ' DELETE /*+ PARALLEL(msdh) */ '
		             ||' MSC_SUP_DEM_HISTORY msdh '
			     ||' WHERE plan_id = -1 '
			     ||' AND ROWNUM < 100001 ';

		    /* If Order type is given , include order type in the sql   */
                if (p_order_type is not null) then
		    lv_sql_stmt := lv_sql_stmt || ' AND publisher_order_type = '|| p_order_type;
		end if;

		    /* IF to_date is provided use TO_DATE  */
	        if (p_to_date is not null) and (p_from_date is null) then
		    lv_sql_stmt1 := lv_sql_stmt;

		    lv_sql_stmt := lv_sql_stmt
		                 ||' AND  key_date_new <= sysdate-('||lv_to_date_offset||')';

		    lv_sql_stmt1 := lv_sql_stmt1
		                 ||' AND  key_date_old <= sysdate-('||lv_to_date_offset||')';

		    /* IF from_date is provided use from_date  */
	        elsif (p_to_date is null) and (p_from_date is not null) then
		    lv_sql_stmt1 := lv_sql_stmt;

		    lv_sql_stmt := lv_sql_stmt
		                 ||' AND key_date_new >= sysdate-('||lv_from_date_offset||')';

		    lv_sql_stmt1 := lv_sql_stmt1
		                 ||' AND key_date_old >= sysdate-('||lv_from_date_offset||')';

		    /* IF from and to date are provided, use both */
	        elsif (p_to_date is not null) and (p_from_date is not null) then
		    lv_sql_stmt1 := lv_sql_stmt;

		    lv_sql_stmt := lv_sql_stmt
			        ||' AND key_date_new >= sysdate-('||lv_from_date_offset||')'
				||' AND key_date_new <= sysdate-('||lv_to_date_offset ||') ';

		    lv_sql_stmt1 := lv_sql_stmt1
				||' AND key_date_old >= sysdate-('||lv_from_date_offset||')'
				||' AND key_date_old <= sysdate-('||lv_to_date_offset ||') ';
		end if;

	       LOG_MESSAGE(' SQL#1 executed : ' || lv_sql_stmt );
	       LOG_MESSAGE(' SQL#2 executed : ' || lv_sql_stmt1 );

	 LOOP
               EXECUTE IMMEDIATE lv_sql_stmt;
	       LOG_MESSAGE('Number of records deleted in SQL#1 :  ' || SQL%ROWCOUNT);

	       FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
	       FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
			     TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
	       LOG_MESSAGE('   '||FND_MESSAGE.GET);

	       lv_task_start_time := SYSDATE;

     	       EXIT WHEN SQL%ROWCOUNT= 0;
	       COMMIT;

	 END LOOP;

         IF (lv_sql_stmt1 is not null) then
	     LOOP
		   EXECUTE IMMEDIATE lv_sql_stmt1;
		   LOG_MESSAGE('Number of records deleted in SQL#2 :  ' || SQL%ROWCOUNT);

		   FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
		   FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
				 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
		   LOG_MESSAGE('   '||FND_MESSAGE.GET);

		   lv_task_start_time := SYSDATE;

     	           EXIT WHEN SQL%ROWCOUNT= 0;
		   COMMIT;

	     END LOOP;
	 END IF;

    END IF;

commit;

END purge_sup_dem_history;

END msc_x_purge_supdem_history_pkg;

/
