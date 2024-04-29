--------------------------------------------------------
--  DDL for Package Body OPI_EDW_RES_UTIL_FOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_RES_UTIL_FOPM_SZ" AS
/* $Header: OPIPRUZB.pls 120.1 2005/06/09 16:21:49 appldev  $*/

PROCEDURE CNT_ROWS(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

CURSOR c_cnt_rows IS
	select count(*)
	FROM

      (
       select
       ORGN_CODE,
       trunc(trans_date) trans_date ,
       resources,sum(resource_usage) RSRC_USAGE
       FROM
       PC_TRAN_PND
       WHERE completed_ind=1
       GROUP BY
       ORGN_CODE,trunc(trans_date),resources
      ) PCPND,
      (
       select
       a.ORGN_CODE,
       a.resources,
       trunc(trans_date) trans_date,
       AVG(DAILY_AVAIL_USE) DAILY_AVAIL,
       MAX(a.USAGE_UM) USAGE_UM,
       MAX(GREATEST(a.LAST_UPDATE_DATE,TRANS_DATE)) LAST_UPDATE_DATE
       FROM
       (
        SELECT
             RS.ORGN_CODE,
             RS.RESOURCES,
             RD.DAILY_AVAIL_USE,
             decode(RD.USAGE_UM,NULL,RS.STD_USAGE_UM,RD.USAGE_UM) USAGE_UM,
             RS.LAST_UPDATE_DATE
         FROM
              (SELECT  ORG.ORGN_CODE,
                       RSRC.RESOURCES,
                       RSRC.STD_USAGE_UM,
                       GREATEST(ORG.LAST_UPDATE_DATE,RSRC.LAST_UPDATE_DATE) LAST_UPDATE_DATE
                  FROM SY_ORGN_MST ORG,
                       CR_RSRC_MST RSRC
              ) RS,
              CR_RSRC_DTL RD
              WHERE RS.RESOURCES = RD.RESOURCES(+)
              AND RS.ORGN_CODE = RD.ORGN_CODE(+)
         ) a,
       PC_TRAN_PND b
       WHERE b.completed_ind=1
       GROUP BY
       A.ORGN_CODE,a.resources,trunc(trans_date)
      ) RSRC,
      EDW_LOCAL_INSTANCE inst,
      SY_ORGN_MST SY,
      GL_PLCY_MST GPM,
      OPI_PMI_UOMS_MST UOM
WHERE PCPND.orgn_code(+)= RSRC.ORGN_CODE and
      PCPND.trans_date(+)=RSRC.trans_date and
      PCPND.resources(+) = RSRC.resources and
      RSRC.ORGN_CODE = SY.ORGN_CODE AND
      SY.CO_CODE = GPM.CO_CODE AND
      UOM.UM_CODE = RSRC.USAGE_UM
      AND RSRC.TRANS_DATE  between p_from_date and p_to_date;
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
 x_date                 number :=7;

  X_RES_UTIL_PK NUMBER;
  X_LOCATOR_FK  NUMBER;
  X_RSRC_FK     NUMBER;
  X_TRX_DATE_FK NUMBER;
  X_UOM_FK      NUMBER;
  X_INSTANCE_FK NUMBER;
  X_ACT_RES_USAGE NUMBER;
  X_AVAIL_RES NUMBER;



  CURSOR RES_UTIL IS
	SELECT
            avg(nvl(vsize(RSRC.TRANS_DATE||'-'||rsrc.ORGN_CODE||'-'||RSRC.RESOURCES||'-OPM'),0)) RES_UTIL_PK,
            avg(nvl(vsize(RESOURCE_USAGE),0))
            FROM
            PC_TRAN_PND RSRC
            WHERE
            last_update_date between
            p_from_date  and  p_to_date;


  CURSOR INST_PK IS
	SELECT
		avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;


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
           (BH.TRANS_DATE,SOB.SET_OF_BOOKS_ID),1,120)),0))
	FROM
          PC_TRAN_PND  BH,
          SY_ORGN_MST  OM,
          GL_PLCY_MST  PM,
          GL_SETS_OF_BOOKS SOB
          WHERE
          BH.ORGN_CODE = OM.ORGN_CODE
          AND OM.CO_CODE      = PM.co_code
          AND PM.SET_OF_BOOKS_NAME=SOB.name;



  BEGIN

    OPEN RES_UTIL;
      FETCH RES_UTIL INTO
	    X_RES_UTIL_PK,
            X_ACT_RES_USAGE;
    CLOSE RES_UTIL;

     x_total := x_date +
	        x_total +
                ceil(X_RES_UTIL_PK+1) +
		2*ceil(X_ACT_RES_USAGE+1);


     OPEN TRX_DATE_PK;
      FETCH TRX_DATE_PK INTO x_TRX_DATE_FK;
    CLOSE TRX_DATE_PK;
    x_total := x_total + ceil(x_TRX_DATE_FK + 1);

    OPEN INST_PK;
      FETCH INST_PK INTO x_INSTANCE_FK;
    CLOSE INST_PK;
    x_total := x_total + ceil(x_INSTANCE_FK + 1);

    OPEN UOM_PK ;
      FETCH UOM_PK INTO x_UOM_FK;
    CLOSE UOM_PK ;
    x_total := x_total + ceil(x_UOM_FK + 1);

    OPEN RSRC_PK ;
      FETCH RSRC_PK INTO x_RSRC_FK;
    CLOSE RSRC_PK ;
    x_total := x_total + ceil(x_RSRC_FK + 1);

 OPEN LOC_PK ;
      FETCH LOC_PK INTO x_LOCATOR_FK;
    CLOSE LOC_PK ;
    x_total := x_total + ceil(x_LOCATOR_FK + 1);

   -- Miscellaneous
    x_total := x_total + 3 * ceil(x_INSTANCE_FK + 1);

    p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END OPI_EDW_RES_UTIL_FOPM_SZ;

/
