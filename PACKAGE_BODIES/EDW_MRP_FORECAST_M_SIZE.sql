--------------------------------------------------------
--  DDL for Package Body EDW_MRP_FORECAST_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MRP_FORECAST_M_SIZE" AS
/* $Header: ISCSGD1B.pls 115.2 2002/12/19 00:45:28 scheung ship $ */

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
        FROM mrp_forecast_designators fd,
	     mtl_parameters mp
       WHERE fd.forecast_set IS NOT NULL
	 AND fd.organization_id = mp.organization_id
         AND fd.last_update_date BETWEEN p_from_date AND p_to_date;

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
    x_org_code		   number := 0;
    x_forecast_designator  number := 0;
    x_org_id		   number := 0;
    x_forecast_set	   number := 0;
    x_FORECAST_PK		NUMBER;
    x_FORECAST_SET_FK		NUMBER;
    x_FORECAST_NAME		NUMBER;
    x_DESCRIPTION		NUMBER;
    x_FORECAST_DP		NUMBER;
    x_NAME			NUMBER;
    x_DISABLE_DATE		NUMBER;
    x_FORECAST_SET_PK		NUMBER;
    x_FORECAST_SET_NAME		NUMBER;
    x_CONSUMPTION_LEVEL		NUMBER;
    x_SET_DESCRIPTION		NUMBER;
    x_FORECAST_SET_DP		NUMBER;
    x_SET_NAME			NUMBER;
    x_SET_DISABLE_DATE		NUMBER;

      CURSOR c_1 IS
         SELECT nvl(avg(nvl(vsize(organization_code),0)),0)
         FROM mtl_parameters;

      CURSOR c_2 IS
         SELECT nvl(avg(nvl(vsize(forecast_designator),0)),0),
   	        nvl(avg(nvl(vsize(organization_id),0)),0),
	        nvl(avg(nvl(vsize(forecast_set),0)),0),
	        nvl(avg(nvl(vsize(description),0)),0),
	        nvl(avg(nvl(vsize(disable_date),0)),0)
         FROM mrp_forecast_designators
         WHERE last_update_date BETWEEN p_from_date AND p_to_date;

      CURSOR c_3 IS
         SELECT nvl(avg(nvl(vsize(meaning),0)),0)
         FROM mfg_lookups;

   BEGIN

      OPEN c_1;
         FETCH c_1 INTO x_org_code;
      CLOSE c_1;

      OPEN c_2;
         FETCH c_2 INTO x_forecast_designator, x_org_id,
			x_forecast_set, x_DESCRIPTION, x_DISABLE_DATE;
      CLOSE c_2;

      x_FORECAST_PK := x_forecast_designator + x_org_id;
      x_FORECAST_SET_FK := x_forecast_set + x_org_id;
      x_FORECAST_NAME := x_forecast_designator + x_org_code;
      x_FORECAST_DP := x_FORECAST_NAME;
      x_NAME := x_FORECAST_NAME;

      x_FORECAST_SET_PK := x_FORECAST_PK;
      x_FORECAST_SET_NAME := x_FORECAST_NAME;
      x_FORECAST_SET_DP := x_FORECAST_NAME;

      x_total := 3 + x_total + ceil(x_FORECAST_PK + 1) + ceil(x_FORECAST_SET_FK + 1) +
	         ceil(x_FORECAST_NAME + 1) + ceil(x_DESCRIPTION + 1) + ceil(x_FORECAST_DP + 1) +
	         ceil(x_NAME + 1) + ceil(x_DISABLE_DATE + 1) + ceil(x_FORECAST_SET_PK + 1) +
	         ceil(x_FORECAST_SET_NAME + 1) +  ceil(x_DESCRIPTION + 1) +
	         ceil(x_FORECAST_SET_DP + 1) + ceil(x_NAME + 1) + ceil(x_DISABLE_DATE + 1);

      OPEN c_3;
         FETCH c_3 INTO x_CONSUMPTION_LEVEL;
      CLOSE c_3;

      x_total := x_total + ceil(x_CONSUMPTION_LEVEL + 1);

      p_avg_row_len := x_total;

   Exception When others then
      rollback;

   END;

END EDW_MRP_FORECAST_M_SIZE;

/
