--------------------------------------------------------
--  DDL for Package Body EDW_OPI_ACTV_MOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OPI_ACTV_MOPM_SZ" AS
/* $Header: OPIPACZB.pls 120.1 2005/06/16 03:53:03 appldev  $*/

-- procedure to count Lot Dimension rows.

  PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                          p_to_date   IN  DATE,
                          p_num_rows  OUT NOCOPY NUMBER) IS
  BEGIN
    SELECT count(*) into p_num_rows
    FROM FM_ACTV_MST FA
    WHERE FA.last_update_date between p_from_date and p_to_date;
  --  dbms_output.put_line ('Number of rows : '||p_num_rows);
  EXCEPTION
    WHEN OTHERS THEN
      p_num_rows := 0;
  END cnt_rows;

-- procedure to get average row length Lot Dimension rows.

  PROCEDURE  est_row_len (p_from_date    IN  DATE,
                          p_to_date      IN  DATE,
                          p_avg_row_len  OUT NOCOPY NUMBER) IS
    x_date                 number := 7;
    x_total                number := 0;
    x_constant             number := 6;
    x_INSTANCE             NUMBER := 0;
    x_ACT_DP               NUMBER := 0;
    x_ACT_PK               NUMBER := 0;
    x_COST_ANALYSIS_CODE   NUMBER := 0;
    x_ACTIVITY             NUMBER := 0;
    x_ACTIVITY_DESC        NUMBER := 0;
    x_last_update_date     NUMBER := x_date;
    x_creation_date        NUMBER := x_date;
    cursor CUR_INSTANCE_SIZE is
      select avg(nvl(vsize(instance_code),0))
      from edw_local_instance;

    CURSOR CUR_OPM_ACTIVITY_SIZES IS
      SELECT avg(nvl(vsize(ACTIVITY),0)),
             avg(nvl(vsize(ACTIVITY_DESC),0)),
             avg(nvl(vsize(COST_ANALYSIS_CODE),0)),
             avg(nvl(vsize(ACTIVITY||'-'||'OPM'||'-'),0)) ACT_PK,
             avg(vsize('ACTV'))
      FROM FM_ACTV_MST
      WHERE LAST_UPDATE_DATE BETWEEN P_FROM_DATE AND P_TO_DATE;
  BEGIN
     OPEN CUR_INSTANCE_SIZE;
     FETCH CUR_INSTANCE_SIZE INTO x_INSTANCE;
     CLOSE CUR_INSTANCE_SIZE;
     OPEN CUR_OPM_ACTIVITY_SIZES;
     FETCH CUR_OPM_ACTIVITY_SIZES INTO x_ACTIVITY,x_ACTIVITY_DESC,x_COST_ANALYSIS_CODE,x_ACT_PK,x_ACT_DP;
     CLOSE CUR_OPM_ACTIVITY_SIZES;
     x_total := NVL(ceil(x_INSTANCE + 1), 0) +
                3 * NVL(ceil(x_ACTIVITY + 1), 0) +
                NVL(ceil(x_ACTIVITY_DESC + 1), 0) +
                NVL(ceil(x_COST_ANALYSIS_CODE+ 1), 0) +
                NVL(ceil(x_ACT_PK + 1), 0) +
                NVL(ceil(x_creation_date + 1), 0) +
                NVL(ceil(x_creation_date + 1), 0) +
                NVL(ceil(x_ACT_DP + 1), 0);
    p_avg_row_len := x_total;
--    dbms_output.put_line ('Average Row Length IS : '||p_avg_row_len);
  EXCEPTION
    WHEN OTHERS THEN
      p_avg_row_len := 0;
  END est_row_len;
END EDW_OPI_ACTV_MOPM_SZ;

/
