--------------------------------------------------------
--  DDL for Package Body EDW_OE_SLCHNL_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_OE_SLCHNL_M_SIZE" AS
/* $Header: ISCSGD3B.pls 115.2 2002/12/19 00:46:07 scheung ship $ */

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
       WHERE fnd.lookup_type='SALES_CHANNEL'
	 AND fnd.language = userenv('LANG')
	 AND fnd.view_application_id = 660
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
    x_SALES_CHANNEL_PK		NUMBER;
    x_SALES_CHANNEL_CODE	NUMBER;
    x_SALES_CHANNEL_NAME	NUMBER;
    x_ENABLED_FLAG		NUMBER;
    x_ACTIVE_FROM_DATE		NUMBER;
    x_ACTIVE_TO_DATE		NUMBER;
    x_SALES_CHANNEL_DP		NUMBER;
    x_NAME			NUMBER;
    x_CREATION_DATE		NUMBER;
    x_LAST_UPDATE_DATE		NUMBER;

      CURSOR c_1 IS
         SELECT nvl(avg(nvl(vsize(lookup_code),0)),0),
   	        nvl(avg(nvl(vsize(description),0)),0),
		nvl(avg(nvl(vsize(enabled_flag),0)),0),
	        nvl(avg(nvl(vsize(meaning),0)),0),
		nvl(avg(nvl(vsize(start_date_active),0)),0),
		nvl(avg(nvl(vsize(end_date_active),0)),0),
		nvl(avg(nvl(vsize(creation_date),0)),0),
		nvl(avg(nvl(vsize(last_update_date),0)),0)
         FROM fnd_lookup_values
         WHERE last_update_date BETWEEN p_from_date AND p_to_date;

   BEGIN

      OPEN c_1;
         FETCH c_1 INTO x_SALES_CHANNEL_PK, x_SALES_CHANNEL_NAME, x_ENABLED_FLAG,
			x_SALES_CHANNEL_DP, x_ACTIVE_FROM_DATE, x_ACTIVE_TO_DATE,
			x_CREATION_DATE, x_LAST_UPDATE_DATE;
      CLOSE c_1;

      x_SALES_CHANNEL_CODE := x_SALES_CHANNEL_PK;
      x_NAME := x_SALES_CHANNEL_DP;

      x_total := 3 + x_total + ceil(x_SALES_CHANNEL_PK + 1) + ceil(x_SALES_CHANNEL_CODE + 1) +
	         ceil(x_SALES_CHANNEL_NAME + 1) + ceil(x_ENABLED_FLAG + 1) + ceil(x_ACTIVE_FROM_DATE + 1) +
		 ceil(x_ACTIVE_TO_DATE + 1) + ceil(x_SALES_CHANNEL_DP + 1) + ceil(x_NAME + 1) +
		 ceil(x_CREATION_DATE + 1) + ceil(x_LAST_UPDATE_DATE + 1);

      p_avg_row_len := x_total;

  Exception When others then
     rollback;

  END;

END EDW_OE_SLCHNL_M_SIZE;

/
