--------------------------------------------------------
--  DDL for Package Body ISC_EDW_BACKLOGS_F_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_EDW_BACKLOGS_F_P" AS
/* $Header: ISCF01PB.pls 115.5 2004/02/26 00:18:48 scheung ship $*/

g_dummy         VARCHAR2(30);
g_dummy_int     NUMBER;
cid             NUMBER;
g_errbuf 	VARCHAR2(200) := NULL;
g_retcode 	NUMBER := 0;
l_exception_msg	VARCHAR2(2000)	:=NULL;

CURSOR snap_c IS
SELECT backlog.backlogs_pk		c_pk,
       nvl(time.cday_calendar_date,sysdate+1)	c_date
FROM   ISC_EDW_BACKLOGS_F		backlog,
       EDW_TIME_M			time
WHERE  backlog.date_balance_fk_key = time.cday_cal_day_pk_key
ORDER BY 2 DESC ;


-- we wish to purge the _F table:
-- #1. for a date range (day level) : from_date to to_date (higher priority than #2)
-- #2. if any of the dates from #1 are null, any snapshot taken prior n days from sysdate

PROCEDURE INSERT_FSTG( PK	IN VARCHAR2) IS
BEGIN
	cid := DBMS_SQL.Open_Cursor;
	DBMS_SQL.Parse( cid,
			'INSERT INTO ISC_EDW_BACKLOGS_FSTG (
				BASE_UOM_FK,
				BILL_TO_LOCATION_FK,
				BILL_TO_CUST_FK,
				CUSTOMER_FK,
				DATE_BALANCE_FK,
				DEMAND_CLASS_FK,
				GL_BOOK_FK,
				INSTANCE_FK,
				INV_ORG_FK,
				ORDER_CATEGORY_FK,
				OPERATING_UNIT_FK,
				ORDER_SOURCE_FK,
				ITEM_ORG_FK,
				TOP_MODEL_ITEM_FK,
				TASK_FK,
				SALES_CHANNEL_FK,
				ORDER_TYPE_FK,
				SALES_PERSON_FK,
				SHIP_TO_LOCATION_FK,
				SHIP_TO_CUST_FK,
				TRX_CURRENCY_FK,
				USER_FK1,
				USER_FK2,
				USER_FK3,
				USER_FK4,
				USER_FK5,
				BACKLOGS_PK,
				COLLECTION_STATUS,
				OPERATION_CODE)
			VALUES (
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				''NA_EDW'',
				'''||pk||''' ,
				''READY'',
				''DELETE'')',
	DBMS_SQL.Native);
	g_dummy_int:=DBMS_SQL.Execute(cid);
	DBMS_SQL.Close_Cursor(cid);

EXCEPTION WHEN OTHERS THEN
	DBMS_SQL.Close_Cursor(cid);
	g_errbuf := sqlerrm;
        g_retcode := -1;
	l_exception_msg  := g_retcode || ':' || g_errbuf;
	ROLLBACK;
	EDW_LOG.Put_Line('Other errors in Insert_Fstg : '|| l_exception_msg);
	RAISE;

END INSERT_FSTG;


PROCEDURE DELETE_FACT(	Errbuf 		IN OUT NOCOPY	VARCHAR2,
			Retcode 	IN OUT NOCOPY	VARCHAR2,
			p_nb_days	IN	NUMBER,
			p_from_date	IN	VARCHAR2,
			p_to_date	IN	VARCHAR2) IS

l_from_date	DATE	:= NULL;
l_to_date	DATE	:= NULL;
l_count		NUMBER	:= 0;

BEGIN
Errbuf		:= NULL;
Retcode		:= '0';
	IF (p_from_date IS NOT NULL AND p_to_date IS NOT NULL)
	THEN
		BEGIN
			l_from_date := to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
			l_to_date   := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

			FOR snap_rec IN snap_c
			LOOP
				IF snap_rec.c_date BETWEEN l_from_date AND l_to_date
				THEN
					BEGIN
					      INSERT_FSTG(snap_rec.c_pk);
					      l_count := l_count + 1;
					END;
				END IF;
			END LOOP;
			EDW_LOG.Put_Line('Marking '||l_count||' rows to be deleted from the Backlog Fact during next load');
			EDW_LOG.Put_Line('All snapshots taken between '||l_from_date||' and '||l_to_date||' will be deleted.');			COMMIT;
		END;
	ELSE
	BEGIN
		IF p_nb_days < 0
		THEN EDW_LOG.Put_Line('Please enter a positive number for the Number of Days');
		ELSE
		BEGIN
			IF p_nb_days IS NULL
			THEN EDW_LOG.Put_Line('All parameters are NULL,
please enter the following parameters :

- both "FROM DATE" and "TO DATE", corresponding to the periode you want to PURGE,
or
- the "NUMBER OF DAYS" from today, corresponding to the period that you want to KEEP');
			ELSE
				BEGIN
					FOR snap_rec IN snap_c
					LOOP
						IF snap_rec.c_date < (sysdate - p_nb_days)
						THEN
							INSERT_FSTG(snap_rec.c_pk);
							l_count := l_count + 1;
						END IF;
					END LOOP;
				EDW_LOG.Put_Line('Marking '||l_count||' rows to be deleted from the Backlog Fact during next load.');
				EDW_LOG.Put_Line('All snapshots taken prior to '||(sysdate - p_nb_days)||' will be deleted.');
				END;
				COMMIT;
			END IF;
		END;
		END IF;
	END;
	END IF;

EXCEPTION WHEN OTHERS THEN
	DBMS_SQL.Close_Cursor(cid);
	g_errbuf := sqlerrm;
        g_retcode := -1;
	l_exception_msg  := g_retcode || ':' || g_errbuf;
	ROLLBACK;
	EDW_LOG.Put_Line('Other errors in Delete_Fact : '|| l_exception_msg);
	RAISE;

END DELETE_FACT;


END ISC_EDW_BACKLOGS_F_P;

/
