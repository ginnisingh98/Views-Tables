--------------------------------------------------------
--  DDL for Package Body OPI_EDW_JOB_RSRC_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_JOB_RSRC_FOPM_SZ" AS
/* $Header: OPIPJRZB.pls 120.1 2005/06/07 03:37:59 appldev  $*/

PROCEDURE CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

CURSOR c_cnt_rows IS
	select count(*)
	FROM
          PM_BTCH_HDR  BH,
          PM_MATL_DTL  BD,
          IC_ITEM_MST  IM,
          (SELECT
            POD.BATCH_ID,
            PBH.PLANT_CODE,
            POD.ACTIVITY,
            POD.RESOURCES,
            POD.OPRN_LINE_ID,
            POD.BATCHSTEP_NO,
            POD.BATCHSTEPLINE_ID,
            POD.USAGE_UM,
            POD.ACTUAL_CMPLT_DATE,
            POD.ACTUAL_RSRC_COUNT,
            POD.ACTUAL_RSRC_QTY,
            POD.ACTUAL_RSRC_USAGE,
            POD.ACTUAL_START_DATE,
            POD.PLAN_CMPLT_DATE,
            POD.PLAN_RSRC_COUNT,
            POD.PLAN_RSRC_QTY,
            POD.PLAN_RSRC_USAGE,
            POD.PLAN_START_DATE,
            POD.LAST_UPDATE_DATE
            FROM
             PM_OPRN_DTL POD,
             PM_BTCH_HDR PBH
            WHERE POD.BATCH_ID=PBH.BATCH_ID
          )  BR,
          CR_RSRC_DTL  CR,
          SY_ORGN_MST  OM,
          GL_PLCY_MST  PM,
          FM_OPRN_MST  OPRM,
          FM_OPRN_DTL  OPRD,
          MTL_SYSTEM_ITEMS ITEM_FK_V,
          IC_WHSE_MST IW,
          GL_SETS_OF_BOOKS SOB,
          EDW_LOCAL_INSTANCE inst,
          OPI_PMI_UOMS_MST UOM
     WHERE
          BH.BATCH_ID   = BR.BATCH_ID
      AND BH.BATCH_ID   = BD.BATCH_ID
      AND BH.PLANT_CODE = OM.ORGN_CODE
      AND BR.PLANT_CODE = CR.ORGN_CODE(+)
      AND BR.RESOURCES  = CR.RESOURCES(+)
      AND BR.OPRN_LINE_ID = OPRD.OPRN_LINE_ID
      AND OPRD.OPRN_ID    = OPRM.OPRN_ID
      AND OM.CO_CODE      = PM.co_code
      AND PM.SET_OF_BOOKS_NAME=SOB.name
      AND BD.ITEM_ID      = IM.ITEM_ID
      AND BH.BATCH_STATUS in (3,4)
      AND BD.LINE_TYPE=1 and BD.LINE_NO=1
      AND ITEM_FK_V.SEGMENT1= IM.ITEM_NO
      AND ITEM_FK_V.ORGANIZATION_ID = IW.MTL_ORGANIZATION_ID
      AND IW.WHSE_CODE = BH.WIP_WHSE_CODE
      AND UOM.UM_CODE = BR.USAGE_UM
      AND BR.LAST_UPDATE_DATE between p_from_date and p_to_date;
BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END CNT_ROWS;


PROCEDURE EST_ROW_LEN(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER) IS
 x_total                number := 0;
 x_constant             number := 6;

 x_JOB_RSRC_PK			NUMBER ;
 x_ACT_RSRC_COUNT		NUMBER ;
 x_PLN_RSRC_COUNT		NUMBER ;
 x_ACT_RSRC_QTY			NUMBER ;
 x_PLN_RSRC_QTY			NUMBER ;
 x_ACT_RSRC_USAGE		NUMBER ;
 x_PLN_RSRC_USAGE		NUMBER ;
 x_STND_RSRC_USAGE		NUMBER ;
 x_JOB_NO			NUMBER ;
 x_OPERATION_SEQ_NUM		NUMBER ;
 x_ACT_STRT_DATE		NUMBER ;
 x_ACT_CMPL_DATE		NUMBER ;
 x_PLN_STRT_DATE		NUMBER ;
 x_PLN_CMPL_DATE		NUMBER ;
 x_SOB_CURRENCY_FK		NUMBER ;
 x_UOM_FK			NUMBER ;
 x_INSTANCE_FK			NUMBER ;
 x_LOCATOR_FK			NUMBER ;
 x_ACTIVITY_FK			NUMBER ;
 x_TRX_DATE_FK			NUMBER ;
 x_OPRN_FK			NUMBER ;
 x_RSRC_FK			NUMBER ;
 x_ITEM_FK			NUMBER ;


  CURSOR JOB_RSRC IS
	SELECT 	        avg(nvl(vsize(POD.BATCH_ID||'-'||POD.Batchstep_no||'-'||
            POD.Resources||'-'||POD.Activity||'-'||POD.BATCHSTEPLINE_ID||'-OPM'),0))             JOB_RSRC_PK,
            avg(nvl(vsize(POD.ACTUAL_CMPLT_DATE),0))  ACT_CMPL_DATE,
            avg(nvl(vsize(POD.ACTUAL_RSRC_COUNT),0))  ACT_RSRC_COUNT,
            avg(nvl(vsize(POD.ACTUAL_RSRC_QTY),0))    ACT_RSRC_QTY,
            avg(nvl(vsize(POD.ACTUAL_RSRC_USAGE),0))  ACT_RSRC_USAGE,
            avg(nvl(vsize(POD.ACTUAL_START_DATE),0))  ACT_START_DATE,
            avg(nvl(vsize(POD.PLAN_CMPLT_DATE),0))    PLN_CMPLT_DATE,
            avg(nvl(vsize(POD.PLAN_RSRC_COUNT),0))    PLN_RSRC_COUNT,
            avg(nvl(vsize(POD.PLAN_RSRC_QTY),0))      PLN_RSRC_QTY,
            avg(nvl(vsize(POD.PLAN_RSRC_USAGE),0))    PLN_RSRC_USAGE,
            avg(nvl(vsize(POD.PLAN_START_DATE),0))    PLN_STRT_DATE,
            avg(nvl(vsize(POD.BATCHSTEP_NO),0))       OPERATION_SEQ_NO,
            avg(nvl(vsize(PBH.BATCH_NO),0))          JOB_NO,
            avg(nvl(vsize(((POD.PLAN_RSRC_USAGE
                               /POD.PLAN_RSRC_QTY)
                               *POD.ACTUAL_RSRC_QTY)),0)) STND_RSRC_USAGE
            FROM
             PM_OPRN_DTL POD,
             PM_BTCH_HDR PBH
            WHERE POD.BATCH_ID=PBH.BATCH_ID AND
            POD.last_update_date between
            p_from_date  and  p_to_date;

  CURSOR OPRN_PK IS
	SELECT
		/* OPRN_FK */
		avg(nvl(vsize(oprn_id),0))
	FROM	FM_OPRN_MST;


  CURSOR ITEM_PK IS
        /* ITEM_FK */
	SELECT
	avg(nvl(vsize(EDW_ITEMS_PKG.ITEM_ORG_FK(ITEM_FK_V.INVENTORY_ITEM_ID,
        IW.MTL_ORGANIZATION_ID,NULL,TO_NUMBER(NULL),NULL)), 0))
	FROM	MTL_SYSTEM_ITEMS ITEM_FK_V,
                IC_WHSE_MST IW,
                IC_ITEM_MST IM
        WHERE   ITEM_FK_V.SEGMENT1= IM.ITEM_NO
                AND ITEM_FK_V.ORGANIZATION_ID = IW.MTL_ORGANIZATION_ID;

  CURSOR INST_PK IS
	SELECT
		avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;


  CURSOR CURR_PK is
	SELECT  avg(nvl(vsize(BASE_CURRENCY_CODE), 0))
        FROM    gl_plcy_mst;

 CURSOR ACT_PK is
	SELECT  avg(nvl(vsize(ACTIVITY), 0))
        FROM    FM_ACTV_MST;

  CURSOR RSRC_PK is
	SELECT  avg(nvl(vsize(RESOURCES||'-OPM'), 0))
	FROM CR_RSRC_MST;

  CURSOR UOM_PK is
	SELECT  avg(nvl(vsize(UOM_CODE), 0))
	FROM OPI_PMI_UOMS_MST;
  CURSOR LOC_PK is
	SELECT  avg(nvl(vsize(ORGN_CODE), 0))
	FROM SY_ORGN_MST;

  CURSOR TRX_DATE_PK is
	SELECT          avg(nvl(vsize(substr(edw_time_pkg.cal_day_fk
           (POD.ACTUAL_CMPLT_DATE,SOB.SET_OF_BOOKS_ID),1,120)),0))
	FROM
          PM_OPRN_DTL  POD,
          PM_BTCH_HDR  BH,
          SY_ORGN_MST  OM,
          GL_PLCY_MST  PM,
          GL_SETS_OF_BOOKS SOB
          WHERE
          BH.BATCH_ID=POD.BATCH_ID
          AND BH.PLANT_CODE = OM.ORGN_CODE
          AND OM.CO_CODE      = PM.co_code
          AND PM.SET_OF_BOOKS_NAME=SOB.name;



  BEGIN

    OPEN JOB_RSRC;
      FETCH JOB_RSRC INTO
	    X_JOB_RSRC_PK,
            X_ACT_CMPL_DATE,
            X_ACT_RSRC_COUNT,
            X_ACT_RSRC_QTY,
            X_ACT_RSRC_USAGE,
            X_ACT_STRT_DATE,
            X_PLN_CMPL_DATE,
            X_PLN_RSRC_COUNT,
            X_PLN_RSRC_QTY,
            X_PLN_RSRC_USAGE,
            X_PLN_STRT_DATE,
            X_OPERATION_SEQ_NUM,
            X_JOB_NO,
            X_STND_RSRC_USAGE;
    CLOSE JOB_RSRC;

     x_total := 3 +
	    x_total +
                ceil(x_JOB_RSRC_PK + 1) +
		ceil(x_ACT_RSRC_COUNT + 1) +
		ceil(x_PLN_RSRC_COUNT + 1) +
		ceil(x_ACT_RSRC_USAGE + 1) +
		ceil(x_PLN_RSRC_USAGE + 1) +
		ceil(x_STND_RSRC_USAGE + 1) +
		ceil(x_OPERATION_SEQ_NUM + 1) +
		ceil(x_ACT_STRT_DATE + 1) +
		ceil(x_ACT_CMPL_DATE + 1) +
		ceil(x_PLN_STRT_DATE + 1) +
		ceil(x_PLN_CMPL_DATE + 1) +
                ceil(x_job_NO+1) +
                ceil(x_ACT_RSRC_QTY+1)+
                6*ceil(x_ACT_RSRC_QTY+2);


    OPEN OPRN_PK;
      FETCH OPRN_PK INTO  x_OPRN_FK;
    CLOSE OPRN_PK;
    x_total := x_total + ceil(x_OPRN_FK + 1);

    OPEN ITEM_PK;
      FETCH ITEM_PK INTO  x_ITEM_FK ;
    CLOSE ITEM_PK;
    x_total := x_total + ceil(x_ITEM_FK + 1) ;

     OPEN TRX_DATE_PK;
      FETCH TRX_DATE_PK INTO x_TRX_DATE_FK;
    CLOSE TRX_DATE_PK;
    x_total := x_total + ceil(x_TRX_DATE_FK + 1);

    OPEN INST_PK;
      FETCH INST_PK INTO x_INSTANCE_FK;
    CLOSE INST_PK;
    x_total := x_total + ceil(x_INSTANCE_FK + 1);

    OPEN CURR_PK ;
      FETCH CURR_PK INTO x_SOB_CURRENCY_FK;
    CLOSE CURR_PK ;
    x_total := x_total + ceil(x_SOB_CURRENCY_FK + 1);

    OPEN UOM_PK ;
      FETCH UOM_PK INTO x_UOM_FK;
    CLOSE UOM_PK ;
    x_total := x_total + ceil(x_UOM_FK + 1);

    OPEN RSRC_PK ;
      FETCH RSRC_PK INTO x_RSRC_FK;
    CLOSE RSRC_PK ;
    x_total := x_total + ceil(x_RSRC_FK + 1);
   OPEN ACT_PK ;
      FETCH ACT_PK INTO x_ACTIVITY_FK;
    CLOSE ACT_PK ;
    x_total := x_total + ceil(x_ACTIVITY_FK + 1);

 OPEN LOC_PK ;
      FETCH LOC_PK INTO x_LOCATOR_FK;
    CLOSE LOC_PK ;
    x_total := x_total + ceil(x_LOCATOR_FK + 1);

   -- Miscellaneous
    x_total := x_total + 5 * ceil(x_INSTANCE_FK + 1);

    p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END OPI_EDW_JOB_RSRC_FOPM_SZ;

/
