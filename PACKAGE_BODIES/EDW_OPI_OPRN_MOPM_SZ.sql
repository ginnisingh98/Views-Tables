--------------------------------------------------------
--  DDL for Package Body EDW_OPI_OPRN_MOPM_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OPI_OPRN_MOPM_SZ" AS
/* $Header: OPIPOPZB.pls 120.1 2005/06/09 16:01:11 appldev  $*/

-- procedure to count Operation Dimension rows.

  PROCEDURE  cnt_rows    (p_from_date IN  DATE,
                          p_to_date   IN  DATE,
                          p_num_rows  OUT NOCOPY NUMBER) IS
  BEGIN
    SELECT sum(cnt) into p_num_rows
    FROM  (SELECT count(*) cnt
           FROM FM_OPRN_CLS
           WHERE last_update_date between p_from_date and p_to_date
           UNION ALL
           SELECT count(*) cnt
           FROM FM_OPRN_MST
           WHERE last_update_date between p_from_date and p_to_date);
--    dbms_output.put_line ('Number of rows : '||p_num_rows);
  EXCEPTION
    WHEN OTHERS THEN
      p_num_rows := 0;
  END cnt_rows;

-- procedure to get average row length Operation Dimension rows.

  PROCEDURE  est_row_len (p_from_date    IN  DATE,
                          p_to_date      IN  DATE,
                          p_avg_row_len  OUT NOCOPY NUMBER) IS
    x_date                 number := 7;
    x_total                number := 0;
    x_constant             number := 6;
    x_INSTANCE             NUMBER := 0;
    x_last_update_date     NUMBER := x_date;
    x_creation_date        NUMBER := x_date;

    --  Operation Class Level Attributes

    x_OPRC_PK              NUMBER := 0;
    x_OPRC_DP              NUMBER := 0;
    x_OPRC_NAME            NUMBER := 0;
    x_OPRC_DESCRIPTION     NUMBER := 0;
    x_total_op_calss       NUMBER := 0;


    --  Operation Level Attributes

    x_OPRN_PK              NUMBER := 0;
    x_OPRC_FK              NUMBER := 0;
    x_OPRN_DP              NUMBER := 0;
    x_NAME                 NUMBER := 0;
    x_OPRN_NAME            NUMBER := 0;
    x_DESCRIPTION          NUMBER := 0;
    x_ORGN_CODE            NUMBER := 0;
    x_DEPARTMENT           NUMBER := 0;
    x_PROCESS_QTY_UOM      NUMBER := 0;
    x_total_operations     NUMBER := 0;

    -- Cursor to get instance code size

    cursor CUR_INSTANCE_SIZE is
      select avg(nvl(vsize(instance_code),0))
      from edw_local_instance;

    -- Cursor to Operation Class Level Attribute Sizes

    CURSOR CUR_OPM_OPRN_CLS_SIZES IS
      SELECT
        avg(nvl(vsize(OPRN_CLASS||'-'||'-OPM'),0)),
        avg(nvl(vsize('OPRC'),0)),
        avg(nvl(vsize(OPRN_CLASS_DESC||'('||OPRN_CLASS||')'),0)),
        avg(nvl(vsize(OPRN_CLASS_DESC),0))
      FROM FM_OPRN_CLS
      WHERE LAST_UPDATE_DATE BETWEEN P_FROM_DATE AND P_TO_DATE;

    -- Cursor to get Operation Level Attribute sizes

    CURSOR CUR_OPM_OPRN_SIZES IS
      SELECT avg(nvl(vsize(OPRN_ID||'-'||'-OPM'),0)),
        avg(nvl(vsize('OPRN'),0)),
        avg(nvl(vsize(OPRN_NO),0)),
        avg(nvl(vsize(OPRN_DESC),0)),
        avg(nvl(vsize(PROCESS_QTY_UM),0))
      FROM FM_OPRN_MST
      WHERE LAST_UPDATE_DATE BETWEEN P_FROM_DATE AND P_TO_DATE;


  BEGIN
     OPEN CUR_INSTANCE_SIZE;
     FETCH CUR_INSTANCE_SIZE INTO x_INSTANCE;
     CLOSE CUR_INSTANCE_SIZE;
     OPEN CUR_OPM_OPRN_CLS_SIZES;
     FETCH CUR_OPM_OPRN_CLS_SIZES INTO x_OPRC_PK,x_OPRC_DP,x_OPRC_NAME,x_OPRC_DESCRIPTION;
     CLOSE CUR_OPM_OPRN_CLS_SIZES;
     x_total_op_calss := NVL(ceil(x_INSTANCE + 1), 0) +
                NVL(ceil(x_OPRC_PK + 1), 0) +
                NVL(ceil(x_OPRC_DP + 1), 0) +
                NVL(ceil(x_OPRC_NAME+ 1), 0) +
                NVL(ceil(x_OPRC_DESCRIPTION + 1), 0) +
                NVL(ceil(x_creation_date + 1), 0) +
                NVL(ceil(x_creation_date + 1), 0);
--     dbms_output.put_line ('Average Row Length for Operation Class IS : '||x_total_op_calss);

     OPEN CUR_OPM_OPRN_SIZES;
     FETCH CUR_OPM_OPRN_SIZES INTO x_OPRN_PK,x_OPRN_DP,x_NAME,x_DESCRIPTION,x_PROCESS_QTY_UOM;
     CLOSE CUR_OPM_OPRN_SIZES;
     x_OPRC_FK   := x_OPRC_PK;
     x_total_operations  := 2 * NVL(ceil(x_INSTANCE + 1), 0) +
                            NVL(ceil(x_OPRC_FK + 1), 0) +
                            NVL(ceil(x_OPRN_PK + 1), 0) +
                            NVL(ceil(x_OPRN_DP + 1), 0) +
                            2 * NVL(ceil(x_NAME + 1), 0) +
                            NVL(ceil(x_DESCRIPTION + 1), 0) +
                            NVL(ceil(x_PROCESS_QTY_UOM + 1), 0) +
                            NVL(ceil(x_creation_date + 1), 0) +
                            NVL(ceil(x_creation_date + 1), 0);

     p_avg_row_len := x_total_op_calss + x_total_operations;
--     dbms_output.put_line ('Average Row Length for Operation IS : '||x_total_operations);
--     dbms_output.put_line ('Average Row Length for Operation Dimension IS : '||p_avg_row_len);

  EXCEPTION
    WHEN OTHERS THEN
      p_avg_row_len := 0;
  END est_row_len;
END EDW_OPI_OPRN_MOPM_SZ;


/
