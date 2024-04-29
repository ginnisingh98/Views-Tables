--------------------------------------------------------
--  DDL for Package Body EDW_MRP_DM_CLS_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MRP_DM_CLS_M_SIZE" AS
/* $Header: ISCSGD0B.pls 115.3 2002/12/19 00:44:59 scheung ship $ */

   /* ------------------------------------------
      PROCEDURE NAME   : cnt_rows
      INPUT PARAMETERS : p_from_date, p_to_date
      OUTPUT PARAMETERS: p_num_rows
      DESCRIPTION      : Count the number of rows
      ------------------------------------------- */

   PROCEDURE cnt_rows(p_from_date DATE,
                      p_to_date DATE,
                      p_num_rows OUT NOCOPY NUMBER) IS

   BEGIN

      SELECT count(*)
        INTO p_num_rows
        FROM fnd_lookup_values fnd
       WHERE fnd.lookup_type='DEMAND_CLASS'
         AND fnd.language = userenv('LANG')
         AND fnd.view_application_id = 3
         AND fnd.security_group_id = 0
         AND fnd.last_update_date BETWEEN p_from_date AND p_to_date;

   Exception When others then
      rollback;

   END;

   /* ------------------------------------------
      PROCEDURE NAME   : est_row_len
      INPUT PARAMETERS : p_from_date, p_to_date
      OUTPUT PARAMETERS: p_avg_row_len
      DESCRIPTION      : Estimate input_f
      ------------------------------------------ */

   PROCEDURE est_row_len(p_from_date DATE,
                         p_to_date DATE,
                         p_avg_row_len OUT NOCOPY NUMBER) IS

    x_total                number := 0;
    x_DEMAND_CLASS_PK		NUMBER;
    x_ALL_FK			NUMBER;
    x_DEMAND_CLASS		NUMBER;
    x_DESCRIPTION		NUMBER;
    x_DEMAND_CLASS_DP		NUMBER;
    x_NAME			NUMBER;

      CURSOR c_1 IS
         SELECT nvl(avg(nvl(vsize(lookup_code),0)),0),
   	        nvl(avg(nvl(vsize(description),0)),0),
	        nvl(avg(nvl(vsize(meaning),0)),0)
         FROM fnd_lookup_values
         WHERE last_update_date BETWEEN p_from_date AND p_to_date;

   BEGIN

      OPEN c_1;
         FETCH c_1 INTO x_DEMAND_CLASS_PK, x_DESCRIPTION, x_DEMAND_CLASS_DP;
      CLOSE c_1;

      x_DEMAND_CLASS := x_DEMAND_CLASS_PK;
      x_NAME := x_DEMAND_CLASS_DP;

      x_total := 3 + x_total + ceil(x_DEMAND_CLASS_PK + 1) + ceil( x_DEMAND_CLASS + 1) +
	         ceil(x_DESCRIPTION + 1) + ceil(x_DEMAND_CLASS_DP + 1) + ceil(x_NAME + 1);

      p_avg_row_len := x_total;

   Exception When others then
      rollback;

   END;

END EDW_MRP_DM_CLS_M_SIZE;

/
