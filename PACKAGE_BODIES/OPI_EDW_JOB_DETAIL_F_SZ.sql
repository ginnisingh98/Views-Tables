--------------------------------------------------------
--  DDL for Package Body OPI_EDW_JOB_DETAIL_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_JOB_DETAIL_F_SZ" AS
/* $Header: OPIOJDZB.pls 120.2 2006/02/23 22:01:46 sberi noship $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
CURSOR c_cnt_rows IS
       Select sum(cnt)
       from
       (
	Select count(*) cnt
	FROM
	  WIP_ENTITIES EN, WIP_DISCRETE_JOBS DI
	WHERE
	  DI.STATUS_TYPE IN (4,5,7,12) AND '_SEC:di.organization_id' IS NOT NULL AND
	  DI.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND DI.ORGANIZATION_ID = EN.ORGANIZATION_ID
          and en.last_update_date between p_from_date and p_to_date
        union
	Select count(*) cnt
	FROM
	  WIP_ENTITIES EN, WIP_REPETITIVE_SCHEDULES RE
	WHERE
	  RE.STATUS_TYPE IN (4,5,7,12) AND '_SEC:re.organization_id' IS NOT NULL AND
	  RE.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND RE.ORGANIZATION_ID = EN.ORGANIZATION_ID
          and en.last_update_date between p_from_date and p_to_date
	union
	Select count(*) cnt
	FROM
	  WIP_ENTITIES EN, WIP_FLOW_SCHEDULES FL
	WHERE
	 FL.STATUS = 2  AND '_SEC:fl.organization_id' IS NOT NULL AND
	 FL.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND FL.ORGANIZATION_ID = EN.ORGANIZATION_ID
         and en.last_update_date between p_from_date and p_to_date
       );


BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_est_row_len OUT NOCOPY NUMBER) IS

	 x_JOB_NO NUMBER ;
	 x_JOB_ID_EN NUMBER ;
	 x_ORG_ID NUMBER ;
	 x_ITEM_ORG NUMBER ;
	 x_ENTITY_TYPE NUMBER ;
	 x_CREATION_DATE NUMBER ;
	 x_LAST_UPDATE_DATE NUMBER ;
         x_ROUTING NUMBER ;

	 x_ACT_OUT_QTY_DI NUMBER;
	 x_PLN_CMPL_DATE_DI NUMBER;
	 x_PLN_OUT_QTY_DI  NUMBER;
	 x_ACT_STRT_DATE_DI NUMBER;
	 x_PLN_STRT_DATE_DI NUMBER;
	 x_ACT_CMPL_DATE_DI NUMBER;
	 x_ACT_CNCL_DATE_DI NUMBER;
	 x_PRD_LINE_FK_DI NUMBER;
	 x_ROUTING_REVISION_DI NUMBER;

	 x_JOB_ID_RE NUMBER;
	 x_ACT_OUT_QTY_RE NUMBER;
	 x_PLN_CMPL_DATE_RE NUMBER;
	 x_PLN_OUT_QTY_RE  NUMBER;
	 x_ACT_STRT_DATE_RE NUMBER;
	 x_PLN_STRT_DATE_RE NUMBER;
	 x_ACT_CMPL_DATE_RE NUMBER;
	 x_ACT_CNCL_DATE_RE NUMBER;
	 x_PRD_LINE_FK_RE NUMBER;
	 x_ROUTING_REVISION_RE NUMBER;


	 x_ACT_OUT_QTY_FL NUMBER;
	 x_PLN_CMPL_DATE_FL NUMBER;
	 x_PLN_OUT_QTY_FL  NUMBER;
	 x_ACT_STRT_DATE_FL NUMBER;
	 x_PLN_STRT_DATE_FL NUMBER;
	 x_ACT_CMPL_DATE_FL NUMBER;
	 x_PRD_LINE_FK_FL NUMBER;
	 x_ROUTING_REVISION_FL NUMBER;

	 x_JOB_STATUS_MFG_MODE NUMBER;

 	 x_ACT_INP_VAL NUMBER;

	 x_ACT_PLN_VAL NUMBER;

	 x_ACT_PLN_JOB_TIME_DI NUMBER;
 	 x_ACT_PLN_JOB_TIME_RE NUMBER;
	 x_ACT_PLN_JOB_TIME_FL NUMBER;

	 x_INST NUMBER;
         x_MP_ORG NUMBER;

	 x_di_rows NUMBER;
         x_re_rows NUMBER;
         x_fl_rows NUMBER;

	 x_tot_jobs_rows NUMBER;

	 x_FULL_LEAD_TIME NUMBER;
	 x_trx_date NUMBER;
	 x_currency NUMBER;

 	 x_total NUMBER := 0 ;

CURSOR c_1  IS
	SELECT
	 avg(nvl(vsize(EN.WIP_ENTITY_NAME), 0)),  --    JOB_NO
	 avg(nvl(vsize(EN.WIP_ENTITY_ID || '-'), 0)), -- JOB_ID
	 3*avg(nvl(vsize(EN.ORGANIZATION_ID), 0)),  -- ORG_ID, Used three times in the stg table
	 2*avg(nvl(vsize(EN.PRIMARY_ITEM_ID), 0)),  -- ITEM_ORG, Used twice in the stg table
	 avg(nvl(vsize(EN.ENTITY_TYPE), 0)),      -- ENTITY_TYPE
	 avg(nvl(vsize(EN.CREATION_DATE), 0)),    -- CREATION_DATE
	 avg(nvl(vsize(EN.LAST_UPDATE_DATE), 0)) , -- LAST_UPDATE_DATE
         avg(nvl(vsize(TO_CHAR(EN.PRIMARY_ITEM_ID)), 0)) -- ROUTING
	FROM WIP_ENTITIES EN;

CURSOR c_2  IS
	SELECT
	 avg(nvl(vsize(DI.QUANTITY_COMPLETED), 0)),  -- ACT_OUT_QTY,
	 avg(nvl(vsize(DI.SCHEDULED_COMPLETION_DATE), 0)),   -- PLN_CMPL_DATE,
	 avg(nvl(vsize(DI.START_QUANTITY), 0)),   -- PLN_OUT_QTY ,
	 avg(nvl(vsize(DI.SCHEDULED_START_DATE), 0)),   -- ACT_STRT_DATE,
	 avg(nvl(vsize(DI.SCHEDULED_START_DATE), 0)),   -- PLN_STRT_DATE,
	 avg(nvl(vsize(DI.date_closed), 0)),   -- ACT_CMPL_DATE,
	 avg(nvl(vsize(DECODE(DI.STATUS_TYPE,7,DI.DATE_COMPLETED,NULL)), 0)),   -- ACT_CNCL_DATE,
	 avg(nvl(vsize(DI.LINE_ID), 0)),   -- PRD_LINE_FK,
	 avg(nvl(vsize(DI.ROUTING_REVISION), 0))   -- ROUTING_REVISION,
	FROM WIP_DISCRETE_JOBS DI
	WHERE
	  DI.STATUS_TYPE IN (4,5,7,12) AND '_SEC:di.organization_id' IS NOT NULL;

CURSOR c_3  IS
	SELECT
	 avg(nvl(vsize(RE.QUANTITY_COMPLETED), 0)),  -- ACT_OUT_QTY,
	 avg(nvl(vsize(RE.LAST_UNIT_COMPLETION_DATE), 0)),  -- PLN_CMPL_DATE,
	 avg(nvl(vsize('-' || RE.REPETITIVE_SCHEDULE_ID), 0)),   -- JOB_ID,
	 avg(nvl(vsize(RE.DAILY_PRODUCTION_RATE * RE.PROCESSING_WORK_DAYS), 0)),  -- PLN_OUT_QTY,
	 avg(nvl(vsize(RE.FIRST_UNIT_START_DATE), 0)),  -- ACT_STRT_DATE,
	 avg(nvl(vsize(RE.FIRST_UNIT_START_DATE), 0)),    -- PLN_STRT_DATE,
	 avg(nvl(vsize(NVL(RE.DATE_CLOSED,RE.last_unit_completion_date)), 0)),  -- ACT_CMPL_DATE,
	 avg(nvl(vsize(DECODE(RE.STATUS_TYPE,7,RE.DATE_CLOSED,NULL)), 0)),  -- ACT_CNCL_DATE,
	 avg(nvl(vsize(RE.LINE_ID), 0)),  -- PRD_LINE_FK,
	 avg(nvl(vsize(RE.ROUTING_REVISION), 0)) -- ROUTING_REVISION
	FROM
	  WIP_REPETITIVE_SCHEDULES RE
	WHERE
	  RE.STATUS_TYPE IN (4,5,7,12) AND '_SEC:re.organization_id' IS NOT NULL;

CURSOR c_4  IS
	SELECT
	 avg(nvl(vsize(FL.QUANTITY_COMPLETED), 0)),  -- ACT_OUT_QTY,
	 avg(nvl(vsize(FL.SCHEDULED_COMPLETION_DATE), 0)),  -- PLN_CMPL_DATE,
	 avg(nvl(vsize(FL.PLANNED_QUANTITY), 0)),  -- PLN_OUT_QTY ,
	 avg(nvl(vsize(FL.SCHEDULED_START_DATE), 0)), -- ACT_STRT_DATE,
	 avg(nvl(vsize(FL.SCHEDULED_START_DATE), 0)), -- PLN_STRT_DATE,
	 avg(nvl(vsize(NVL(FL.DATE_CLOSED,FL.scheduled_completion_date)), 0)), -- ACT_CMPL_DATE,
	 avg(nvl(vsize(FL.LINE_ID), 0)), -- PRD_LINE_FK,
	 avg(nvl(vsize(FL.ROUTING_REVISION), 0)) -- ROUTING_REVISION,
	FROM
	  WIP_FLOW_SCHEDULES FL
	WHERE
	 FL.STATUS = 2  AND '_SEC:fl.organization_id' IS NOT NULL;

CURSOR c_5  IS
	SELECT
	 avg(nvl(vsize(ML1.MEANING), 0)) -- JOB_STATUS_MFG_MODE
	FROM MFG_LOOKUPS ML1
	WHERE
	  ML1.LOOKUP_TYPE = 'WIP_JOB_STATUS' OR ML1.LOOKUP_TYPE = 'WIP_ENTITY' ;

CURSOR c_6  IS
	 SELECT
	  avg(nvl(vsize(NVL(WPB.TL_RESOURCE_IN,0) + NVL(WPB.TL_OVERHEAD_IN,0) + NVL(WPB.TL_OUTSIDE_PROCESSING_IN,0) +
	      NVL(WPB.PL_MATERIAL_IN,0) + NVL(WPB.PL_MATERIAL_OVERHEAD_IN,0) + NVL(WPB.PL_RESOURCE_IN,0) + NVL(WPB.PL_OVERHEAD_IN,0) +
	      NVL(WPB.PL_OUTSIDE_PROCESSING_IN,0) + NVL(WPB.TL_SCRAP_IN,0)), 0))  -- ACT_INP_VAL
	 FROM WIP_PERIOD_BALANCES WPB;

CURSOR c_7  IS
	SELECT
	  -- ACT_MTL_INP_VAL, PLN_MTL_INP_VAl, ACT_BPR_VAL, PLN_BPR_VAl, ACT_OUT_VAL, AVG_ACT_UNIT_CMPL_CST (used twice: STD_VAL_B, PLN_OUT_VAL_B), ACT_SCR_VAL
	  avg(nvl(vsize(MMT.PRIMARY_QUANTITY), 0))
	FROM
	  MTL_MATERIAL_TRANSACTIONS MMT;

CURSOR c_8  IS
	SELECT
	 avg(nvl(vsize((NVL(DI.DATE_COMPLETED,DI.date_closed) - DI.SCHEDULED_START_DATE)), 0))   -- ACT_JOB_TIME AND PLN_JOB_TIME
	FROM
	  WIP_DISCRETE_JOBS DI;

CURSOR c_9  IS
	SELECT
	 avg(nvl(vsize((NVL(RE.DATE_CLOSED,RE.last_unit_completion_date) - RE.FIRST_UNIT_START_DATE)), 0))   -- ACT_JOB_TIME AND PLN_JOB_TIME
	FROM
	  WIP_REPETITIVE_SCHEDULES RE;

CURSOR c_10  IS
	SELECT
	  avg(nvl(vsize((NVL(FL.DATE_CLOSED, FL.scheduled_completion_date)  - FL.SCHEDULED_START_DATE)), 0))   -- ACT_JOB_TIME AND PLN_JOB_TIME
	 FROM
	   WIP_FLOW_SCHEDULES FL;

CURSOR c_11 IS
	SELECT
   	   avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;

CURSOR c_12 IS
	SELECT
	   avg(nvl(vsize(mp.organization_code), 0))
	FROM mtl_parameters mp ;

CURSOR c_13 IS
        Select count(*) cnt
	FROM
	  WIP_ENTITIES EN, WIP_DISCRETE_JOBS DI
	WHERE
	  DI.STATUS_TYPE IN (4,5,7,12) AND '_SEC:di.organization_id' IS NOT NULL AND
	  DI.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND DI.ORGANIZATION_ID = EN.ORGANIZATION_ID	;

CURSOR c_14 IS
	Select count(*) cnt
	FROM
	  WIP_ENTITIES EN, WIP_REPETITIVE_SCHEDULES RE
	WHERE
	  RE.STATUS_TYPE IN (4,5,7,12) AND '_SEC:re.organization_id' IS NOT NULL AND
	  RE.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND RE.ORGANIZATION_ID = EN.ORGANIZATION_ID ;

CURSOR c_15 IS
	Select count(*) cnt
	FROM
	  WIP_ENTITIES EN, WIP_FLOW_SCHEDULES FL
	WHERE
	 FL.STATUS = 2  AND '_SEC:fl.organization_id' IS NOT NULL AND
	 FL.WIP_ENTITY_ID = EN.WIP_ENTITY_ID AND FL.ORGANIZATION_ID = EN.ORGANIZATION_ID;

CURSOR c_16 IS
	SELECT
	   avg(nvl(vsize(MSI.FULL_LEAD_TIME), 0))
        FROM
	   MTL_SYSTEM_ITEMS MSI;

CURSOR c_17 IS
        SELECT
                avg(nvl(vsize(transaction_date), 0))
        FROM    WIP_MOVE_TRANSACTIONS;


CURSOR c_18 is
        SELECT  avg(nvl(vsize(gsob.currency_code), 0))
        FROM    hr_all_organization_units hou,
                hr_organization_information hoi,
                gl_sets_of_books gsob
        WHERE   hou.organization_id  = hoi.organization_id
          AND ( hoi.org_information_context || '') ='Accounting Information'
          AND hoi.org_information1    = to_char(gsob.set_of_books_id)  ;

BEGIN

  OPEN c_13;
       FETCH c_13 INTO x_di_rows;
  CLOSE c_13;

  OPEN c_14;
       FETCH c_14 INTO x_re_rows;
  CLOSE c_14;

  OPEN c_15;
       FETCH c_15 INTO x_fl_rows;
  CLOSE c_15;

  x_tot_jobs_rows := x_di_rows + x_re_rows + x_fl_rows;

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_1;
       FETCH c_1 INTO
	 x_JOB_NO ,
	 x_JOB_ID_EN ,
	 x_ORG_ID ,
	 x_ITEM_ORG ,
	 x_ENTITY_TYPE ,
	 x_CREATION_DATE ,
	 x_LAST_UPDATE_DATE ,
         x_ROUTING;
  CLOSE c_1;

  x_total := 3 +
	    x_total +
	ceil(x_JOB_NO + 1) +
	ceil(x_JOB_ID_EN + 1) +
	2*ceil(x_ORG_ID + 1) +  -- ORG_ID is used twice in the job_detail stg record, once in Fact
	ceil(x_ITEM_ORG + 1) +
	ceil(x_ENTITY_TYPE + 1) +
	ceil(x_CREATION_DATE + 1) +
	ceil(x_LAST_UPDATE_DATE + 1) +
	ceil(x_LAST_UPDATE_DATE + 1) +
	ceil(x_ROUTING + 1)   ;

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_2;
       FETCH c_2 INTO
	 x_ACT_OUT_QTY_DI,
	 x_PLN_CMPL_DATE_DI,
	 x_PLN_OUT_QTY_DI ,
	 x_ACT_STRT_DATE_DI,
	 x_PLN_STRT_DATE_DI,
	 x_ACT_CMPL_DATE_DI,
	 x_ACT_CNCL_DATE_DI,
	 x_PRD_LINE_FK_DI,
	 x_ROUTING_REVISION_DI;
  CLOSE c_2;

  x_total := x_total +
	(ceil(x_ACT_OUT_QTY_DI + 1) +
	ceil(x_PLN_CMPL_DATE_DI + 1) +
	ceil(x_PLN_OUT_QTY_DI + 1) +
	ceil(x_ACT_STRT_DATE_DI + 1) +
	ceil(x_PLN_STRT_DATE_DI + 1) +
	ceil(x_ACT_CMPL_DATE_DI + 1) +
	ceil(x_ACT_CNCL_DATE_DI + 1) +
	ceil(x_PRD_LINE_FK_DI + 1) +
	ceil(x_ROUTING_REVISION_DI + 1))*(x_di_rows/x_tot_jobs_rows )   ;

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_3;
       FETCH c_3 INTO
	 x_JOB_ID_RE,
	 x_ACT_OUT_QTY_RE,
	 x_PLN_CMPL_DATE_RE,
	 x_PLN_OUT_QTY_RE,
	 x_ACT_STRT_DATE_RE,
	 x_PLN_STRT_DATE_RE,
	 x_ACT_CMPL_DATE_RE,
	 x_ACT_CNCL_DATE_RE,
	 x_PRD_LINE_FK_RE,
	 x_ROUTING_REVISION_RE ;
  CLOSE c_3;

  x_total := x_total +
	(ceil(x_JOB_ID_RE + 1) +
        ceil(x_ACT_OUT_QTY_RE + 1) +
	ceil(x_PLN_CMPL_DATE_RE + 1) +
	ceil(x_PLN_OUT_QTY_RE + 1) +
	ceil(x_ACT_STRT_DATE_RE + 1) +
	ceil(x_PLN_STRT_DATE_RE + 1) +
	ceil(x_ACT_CMPL_DATE_RE + 1) +
	ceil(x_ACT_CNCL_DATE_RE + 1) +
	ceil(x_PRD_LINE_FK_RE + 1) +
	ceil(x_ROUTING_REVISION_RE + 1))*(x_re_rows/x_tot_jobs_rows )   ;

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_4;
       FETCH c_4 INTO
	 x_ACT_OUT_QTY_FL,
	 x_PLN_CMPL_DATE_FL,
	 x_PLN_OUT_QTY_FL,
	 x_ACT_STRT_DATE_FL,
	 x_PLN_STRT_DATE_FL,
	 x_ACT_CMPL_DATE_FL,
	 x_PRD_LINE_FK_FL,
	 x_ROUTING_REVISION_FL;
  CLOSE c_4;

  x_total := x_total +
	(ceil(x_ACT_OUT_QTY_FL + 1) +
	ceil(x_PLN_CMPL_DATE_FL + 1) +
	ceil(x_PLN_OUT_QTY_FL + 1) +
	ceil(x_ACT_STRT_DATE_FL + 1) +
	ceil(x_PLN_STRT_DATE_FL + 1) +
	ceil(x_ACT_CMPL_DATE_FL + 1) +
	ceil(x_PRD_LINE_FK_FL + 1) +
	ceil(x_ROUTING_REVISION_FL + 1))*(x_fl_rows/x_tot_jobs_rows )   ;

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_5;
       FETCH c_5 INTO
	 x_JOB_STATUS_MFG_MODE ;
  CLOSE c_5;

  x_total := x_total + 2*ceil(x_JOB_STATUS_MFG_MODE  + 1);  -- Used twice in the job_detail record

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_6;
       FETCH c_6 INTO
	 x_ACT_INP_VAL ;
  CLOSE c_6;

  x_total := x_total + 2*ceil(x_ACT_INP_VAL  + 1);  -- VAL_B and VAL_G

  -- dbms_output.put_line ('******************'||x_total||'******') ;

  OPEN c_7;
       FETCH c_7 INTO
	 x_ACT_PLN_VAL ;
  CLOSE c_7;

  x_total := x_total + 16*ceil(x_ACT_PLN_VAL   + 1);  -- There are 8 different values that come from this column, that are also converted to warehouse currency

  -- dbms_output.put_line ('******************'||x_total||'******') ;

  OPEN c_8;
       FETCH c_8 INTO
	x_ACT_PLN_JOB_TIME_DI;
  CLOSE c_8;

  x_total := x_total + ceil(x_ACT_PLN_JOB_TIME_DI  + 1)*(x_di_rows/x_tot_jobs_rows ) ;

  -- dbms_output.put_line ('******************'||to_char(x_total)||'******') ;
  -- dbms_output.put_line ('*****just after this *************'||x_total||'******') ;
  OPEN c_9;
       FETCH c_9 INTO
	x_ACT_PLN_JOB_TIME_RE;
  CLOSE c_9;

  -- dbms_output.put_line ('******not here ************'||x_total||'******') ;
  x_total := x_total + ceil(x_ACT_PLN_JOB_TIME_RE  + 1)*(x_re_rows/x_tot_jobs_rows ) ;

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_10;
       FETCH c_10 INTO
	x_ACT_PLN_JOB_TIME_FL;
  CLOSE c_10;

  x_total := x_total + ceil(x_ACT_PLN_JOB_TIME_FL  + 1)*(x_fl_rows/x_tot_jobs_rows ) ;

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_11;
       FETCH c_11 INTO
	 x_INST;
  CLOSE c_11;

  x_total := x_total + 4*ceil(x_INST  + 1);  -- Instance is mentioned 4 times in the Job Detail stg Row but only once in Fact

  -- dbms_output.put_line ('******************'||x_total||'******') ;
--  This is used only in stg table
  OPEN c_12;
       FETCH c_12 INTO x_MP_ORG;
  CLOSE c_12;

  x_total := x_total + ceil(x_MP_ORG + 1);

  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_16;
       FETCH c_16 INTO x_FULL_LEAD_TIME;
  CLOSE c_16;

  x_total := x_total + ceil(x_FULL_LEAD_TIME + 1);
  -- dbms_output.put_line ('******************'||x_total||'******') ;

  OPEN c_17;
       FETCH c_17 INTO x_trx_date;
  CLOSE c_17;

  x_total := x_total + ceil(x_trx_date + 1);
  -- dbms_output.put_line ('******************'||x_total||'******') ;
  OPEN c_18;
       FETCH c_18 INTO x_currency;
  CLOSE c_18;

  x_total := x_total + ceil(x_currency + 1);
  -- dbms_output.put_line ('******************'||x_total||'******') ;


  -- * ITEM_FK, * BASE_UOM_FK, * TRX_DATE_FK, * SOB_CURRENCY_FK, * PRD_LINE_FK, * LOCATOR_FK, * INSTANCE_FK: 35 aprox (5 per fk_key)

  p_est_row_len := x_total + 3 ; -- (UOM_FK)

END ;

END OPI_EDW_JOB_DETAIL_F_SZ;  -- procedure est_row_len.

/
