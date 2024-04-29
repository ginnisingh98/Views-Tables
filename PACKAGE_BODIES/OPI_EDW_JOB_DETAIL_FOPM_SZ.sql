--------------------------------------------------------
--  DDL for Package Body OPI_EDW_JOB_DETAIL_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_JOB_DETAIL_FOPM_SZ" AS
/* $Header: OPIPJDZB.pls 120.1 2005/06/07 03:23:07 appldev  $*/

PROCEDURE CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

CURSOR c_cnt_rows IS
	select count(*)
	FROM
          (
            SELECT
                BH.BATCH_ID,
                BH.BATCH_NO,
                BH.batch_status,
                BH.WIP_WHSE_CODE,
	        BH.PLAN_START_DATE,
	        BH.ACTUAL_START_DATE,
	        BH.EXPCT_CMPLT_DATE,
	        BH.ACTUAL_CMPLT_DATE,
	        BH.PLANT_CODE,
                BH.FORMULA_ID,
                RT.ROUTING_NO,
                to_char(RT.ROUTING_VERS) ROUTING_VERS,
		BD.ITEM_ID,
                BD.PLAN_QTY,
                BD.ACTUAL_QTY,
                BD.ITEM_UM,
                BD.COST_ALLOC,
                BD.LINE_NO,
                BH.CREATION_DATE,
                GREATEST(BH.LAST_UPDATE_DATE, BD.LAST_UPDATE_DATE) LAST_UPDATE_DATE
		FROM  PM_BTCH_HDR  BH,
                  PM_MATL_DTL  BD,
                  FM_ROUT_HDR  RT
		WHERE BH.BATCH_ID   = BD.BATCH_ID
                  AND BH.ROUTING_ID=RT.ROUTING_ID(+)
      		AND BH.BATCH_STATUS in (-1,0,1,2,3,4)
      		AND BD.LINE_TYPE=1
                ) B,
          SY_ORGN_MST  OM,
          IC_ITEM_MST  IM,
          IC_PLNT_INV  PI,
          GL_SETS_OF_BOOKS SOB,
          GL_PLCY_MST  PM,
          MTL_SYSTEM_ITEMS ITEM_FK_V,
          IC_WHSE_MST IW,
          EDW_LOCAL_INSTANCE inst,
          OPI_PMI_UOMS_MST UOM,
          GEM_LOOKUPS LKUP
     WHERE
          B.PLANT_CODE = OM.ORGN_CODE
      AND B.PLANT_CODE = PI.ORGN_CODE(+)
      AND B.item_id    = PI.item_id(+)
      AND OM.co_CODE  = PM.co_code
      AND PM.set_of_books_name =SOB.name
      AND B.ITEM_ID    = IM.ITEM_ID
      AND ITEM_FK_V.SEGMENT1= IM.ITEM_NO
      AND ITEM_FK_V.ORGANIZATION_ID = IW.MTL_ORGANIZATION_ID
      AND IW.WHSE_CODE = B.WIP_WHSE_CODE
      AND UOM.UM_CODE = IM.ITEM_UM
      AND LKUP.LOOKUP_TYPE='BATCH_STATUS'
      AND LKUP.LOOKUP_CODE=B.BATCH_STATUS
      AND B.LAST_UPDATE_DATE between p_from_date and p_to_date;
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
 X_DATE                 number :=7;

X_JOB_DETAIL_PK	NUMBER;
X_LOCATOR_FK NUMBER;
X_ITEM_FK NUMBER;
X_PRD_LINE_FK NUMBER;
X_TRX_DATE_FK NUMBER;
X_SOB_CURRENCY_FK  NUMBER;
X_UOM_FK NUMBER;
X_INSTANCE_FK  NUMBER;
X_STS_LOOKUP_FK NUMBER;
X_ACT_JOB_TIME  NUMBER;
X_ACT_OUT_QTY NUMBER;
X_JOB_NO NUMBER;
X_JOB_STATUS  NUMBER;
X_MFG_MODE NUMBER;
X_PLN_JOB_TIME  NUMBER;
X_PLN_OUT_QTY  NUMBER;
X_ROUTING NUMBER;
X_ROUTING_REVISION NUMBER;
X_STD_QTY  NUMBER;
X_STD_TIME   NUMBER;
X_STND_HRS_EARNED  NUMBER;


  CURSOR JOB_DTL IS
	SELECT
        avg(nvl(vsize(BH.Plant_code||'-'||BH.Batch_id||
        '-'||BD.item_id||'-'||'OPM'),0))    JOB_DETAIL_PK,
        avg(nvl(vsize(BH.ACTUAL_CMPLT_DATE-BH.ACTUAL_START_DATE),0)) ACT_JOB_TIME,
        avg(nvl(vsize(BD.ACTUAL_QTY),0)),
        avg(nvl(vsize(BH.BATCH_NO),0)),
	avg(nvl(vsize(BH.BATCH_STATUS),0)),
	avg(nvl(vsize('PROCESSMFG'),0)),
	avg(nvl(vsize(BH.EXPCT_CMPLT_DATE-BH.PLAN_START_DATE),0)),
	avg(nvl(vsize(BD.PLAN_QTY),0)),
	avg(nvl(vsize(RT.ROUTING_NO),0)),
        avg(nvl(vsize(RT.ROUTING_VERS),0))
        FROM
                  PM_BTCH_HDR  BH,
                  PM_MATL_DTL  BD,
                  FM_ROUT_HDR  RT
               WHERE BH.BATCH_ID   = BD.BATCH_ID
                  AND BH.ROUTING_ID=RT.ROUTING_ID(+)
      		AND BH.BATCH_STATUS in (-1,0,1,2,3,4)
      		AND BD.LINE_TYPE=1;


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


  CURSOR UOM_PK is
	SELECT  avg(nvl(vsize(UOM_CODE), 0))
	FROM OPI_PMI_UOMS_MST;
  CURSOR LOC_PK is
	SELECT  avg(nvl(vsize(ORGN_CODE), 0))
	FROM SY_ORGN_MST;

  CURSOR TRX_DATE_PK is
	SELECT          avg(nvl(vsize(substr(edw_time_pkg.cal_day_fk
           (BH.ACTUAL_CMPLT_DATE,SOB.SET_OF_BOOKS_ID),1,120)),0))
	FROM
          PM_BTCH_HDR  BH,
          SY_ORGN_MST  OM,
          GL_PLCY_MST  PM,
          GL_SETS_OF_BOOKS SOB
          WHERE
          BH.PLANT_CODE = OM.ORGN_CODE
          AND OM.CO_CODE      = PM.co_code
          AND PM.SET_OF_BOOKS_NAME=SOB.name;



  BEGIN

    x_total:=5*ceil(x_date+1);

    OPEN JOB_DTL;
      FETCH JOB_DTL INTO
            X_JOB_DETAIL_PK,
	    X_ACT_JOB_TIME,
	    X_ACT_OUT_QTY,
	    X_JOB_NO,
	    X_JOB_STATUS,
	    X_MFG_MODE,
	    X_PLN_JOB_TIME,
	    X_PLN_OUT_QTY,
	    X_ROUTING,
	    X_ROUTING_REVISION;
    CLOSE JOB_DTL;

     x_total := x_total +
                ceil(X_JOB_DETAIL_PK + 1) +
		ceil(X_ACT_JOB_TIME + 1) +
		ceil(X_ACT_OUT_QTY + 1) +
		ceil(X_JOB_NO + 1) +
		ceil(X_JOB_STATUS + 1) +
		ceil(X_MFG_MODE + 1) +
		ceil(X_PLN_JOB_TIME + 1) +
		ceil(X_PLN_OUT_QTY + 1) +
		ceil(X_ROUTING + 1) +
		ceil(X_ROUTING_REVISION + 1) +
		2*ceil(X_PLN_OUT_QTY + 1) +
                8*ceil(x_ACT_OUT_QTY+2);


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


 OPEN LOC_PK ;
      FETCH LOC_PK INTO x_LOCATOR_FK;
    CLOSE LOC_PK ;
    x_total := x_total + ceil(x_LOCATOR_FK + 1);

   -- Miscellaneous
    x_total := x_total + 5 * ceil(x_INSTANCE_FK + 1);

    p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END OPI_EDW_JOB_DETAIL_FOPM_SZ;

/
