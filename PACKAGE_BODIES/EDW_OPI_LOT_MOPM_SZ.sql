--------------------------------------------------------
--  DDL for Package Body EDW_OPI_LOT_MOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OPI_LOT_MOPM_SZ" AS
/* $Header: OPIPLTZB.pls 120.1 2005/06/07 03:54:45 appldev  $*/

-- procedure to count Lot Dimension rows.

  PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                          p_to_date   IN  DATE,
                          p_num_rows  OUT NOCOPY NUMBER) IS
  BEGIN
    SELECT count(*) into p_num_rows
    FROM IC_LOTS_MST LT
    WHERE lt.last_update_date between p_from_date and p_to_date;
    --dbms_output.put_line ('Number of rows : '||p_num_rows);
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
    x_LOT_DP               NUMBER := 0;
    x_EXPIRATION_DATE      NUMBER := x_date;
    x_LOT_PK               NUMBER := 0;
    x_NAME                 NUMBER := 0;
    x_LOT_NAME             NUMBER := 0;
    x_LOT                  NUMBER := 0;
    x_PARENT_LOT           NUMBER := 0;
    x_DESCRIPTION          NUMBER := 0;
    x_last_update_date     NUMBER := x_date;
    x_creation_date        NUMBER := x_date;
    cursor CUR_INSTANCE_SIZE is
      select avg(nvl(vsize(instance_code),0))
      from edw_local_instance;

    CURSOR CUR_OPM_LOT_SIZES IS
      SELECT avg(nvl(vsize(LT.LOT_NO),0)) LOT_NO,
             avg(nvl(vsize(LT.SUBLOT_NO),0)) SUBLOT_NO,
             avg(nvl(vsize(LT.LOT_DESC),0)) LOT_DESC,
             avg(nvl(vsize(LOT_NO||DECODE(SUBLOT_NO,NULL,NULL,'-'||SUBLOT_NO) ||'('|| IIM.ITEM_NO ||')'),0)) NAME,
             avg(nvl(vsize(LT.LOT_ID||'-'||LT.ITEM_ID||'-'||'OPM'||'-'),0)) LOT_PK,
             avg(vsize('LOTD'))
      FROM IC_LOTS_MST LT,
           IC_ITEM_MST IIM
      WHERE LT.ITEM_ID = IIM.ITEM_ID
        AND LT.LAST_UPDATE_DATE BETWEEN P_FROM_DATE AND P_TO_DATE;
  BEGIN
     OPEN CUR_INSTANCE_SIZE;
     FETCH CUR_INSTANCE_SIZE INTO x_INSTANCE;
     CLOSE CUR_INSTANCE_SIZE;
     OPEN CUR_OPM_LOT_SIZES;
     FETCH CUR_OPM_LOT_SIZES INTO x_PARENT_LOT,x_LOT,x_DESCRIPTION,x_NAME,x_LOT_PK,x_LOT_DP;
     CLOSE CUR_OPM_LOT_SIZES;
     x_total := NVL(ceil(x_INSTANCE + 1), 0) +
                NVL(ceil(x_PARENT_LOT + 1), 0) +
                NVL(ceil(x_LOT + 1), 0) +
                2 *NVL(ceil(x_DESCRIPTION+ 1), 0) +
                NVL(ceil(x_NAME + 1), 0) +
                NVL(ceil(x_LOT_PK + 1), 0) +
                NVL(ceil(x_creation_date + 1), 0) +
                NVL(ceil(x_creation_date + 1), 0) +
                NVL(ceil(x_EXPIRATION_DATE + 1), 0) +
                NVL(ceil(x_LOT_DP + 1), 0);
    p_avg_row_len := x_total;
    --dbms_output.put_line ('Average Row Length IS : '||p_avg_row_len);
  EXCEPTION
    WHEN OTHERS THEN
      p_avg_row_len := 0;
  END est_row_len;
END EDW_OPI_LOT_MOPM_SZ;


/
