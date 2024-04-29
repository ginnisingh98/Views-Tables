--------------------------------------------------------
--  DDL for Package Body EDW_MRP_PLAN_M_SIZE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MRP_PLAN_M_SIZE" AS
/* $Header: ISCSGD2B.pls 115.2 2002/12/19 00:45:50 scheung ship $ */

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
        FROM mfg_lookups ml1,
 	     mtl_parameters mp,
 	     mrp_plans mpl
       WHERE ml1.lookup_type = 'MRP_PLAN_TYPE'
	 AND ml1.lookup_code = mpl.plan_type
	 AND mp.organization_id=mpl.organization_id
	 AND mpl.plan_completion_date IS NOT NULL
         AND mpl.last_update_date BETWEEN p_from_date AND p_to_date;

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
    x_compile_designator   number := 0;
    x_org_id		   number := 0;
    x_PLAN_NAME_PK		NUMBER;
    x_PLAN_TYPE			NUMBER;
    x_PLAN_NAME			NUMBER;
    x_DESCRIPTION		NUMBER;
    x_INCLUDE_PO_FLAG		NUMBER;
    x_INCLUDE_WIP_FLAG		NUMBER;
    x_COMPLETION_DATE		NUMBER;
    x_PLAN_RESERVE_FLAG		NUMBER;
    x_PLAN_SAFETY_STOCK		NUMBER;
    x_PLAN_CUTOFF_DATE		NUMBER;
    x_PLAN_NAME_DP		NUMBER;
    x_NAME			NUMBER;
    x_CREATION_DATE		NUMBER;
    x_LAST_UPDATE_DATE		NUMBER;

      CURSOR c_1 IS
         SELECT nvl(avg(nvl(vsize(meaning),0)),0)
         FROM mfg_lookups
	 WHERE lookup_type = 'MRP_PLAN_TYPE';

      CURSOR c_2 IS
         SELECT nvl(avg(nvl(vsize(organization_code),0)),0)
         FROM mtl_parameters;

      CURSOR c_3 IS
         SELECT nvl(avg(nvl(vsize(compile_designator),0)),0),
		nvl(avg(nvl(vsize(organization_id),0)),0),
		nvl(avg(nvl(vsize(description),0)),0),
		nvl(avg(nvl(vsize(consider_po),0)),0),
		nvl(avg(nvl(vsize(consider_wip),0)),0),
		nvl(avg(nvl(vsize(plan_completion_date),0)),0),
		nvl(avg(nvl(vsize(consider_reservations),0)),0),
		nvl(avg(nvl(vsize(plan_safety_stock),0)),0),
		nvl(avg(nvl(vsize(cutoff_date),0)),0),
		nvl(avg(nvl(vsize(creation_date),0)),0),
		nvl(avg(nvl(vsize(last_update_date),0)),0)
         FROM mrp_plans
         WHERE last_update_date BETWEEN p_from_date AND p_to_date;

   BEGIN

      OPEN c_1;
         FETCH c_1 INTO x_PLAN_TYPE;
      CLOSE c_1;

      x_total := 3 + x_total + ceil(x_PLAN_TYPE + 1);

      OPEN c_2;
         FETCH c_2 INTO x_org_code;
      CLOSE c_2;

      OPEN c_3;
         FETCH c_3 INTO x_compile_designator, x_org_id, x_DESCRIPTION,
			x_INCLUDE_PO_FLAG, x_INCLUDE_WIP_FLAG, x_COMPLETION_DATE,
			x_PLAN_RESERVE_FLAG, x_PLAN_SAFETY_STOCK, x_PLAN_CUTOFF_DATE,
			x_CREATION_DATE, x_LAST_UPDATE_DATE;
      CLOSE c_3;

      x_PLAN_NAME_PK := x_compile_designator + x_org_id;
      x_PLAN_NAME := x_compile_designator + x_org_code;
      x_PLAN_NAME_DP := x_PLAN_NAME;
      x_NAME := x_PLAN_NAME;

      x_total := x_total + ceil(x_PLAN_NAME_PK + 1) + ceil(x_PLAN_NAME + 1) +
		 ceil(x_DESCRIPTION + 1) + ceil(x_INCLUDE_PO_FLAG + 1) +
		 ceil(x_INCLUDE_WIP_FLAG + 1) + ceil(x_COMPLETION_DATE + 1) +
		 ceil(x_PLAN_RESERVE_FLAG + 1) + ceil(x_PLAN_SAFETY_STOCK + 1) +
		 ceil(x_PLAN_CUTOFF_DATE + 1) + ceil(x_PLAN_NAME_DP + 1) +
		 ceil(x_NAME + 1) + ceil(x_CREATION_DATE + 1) +
		 ceil(x_LAST_UPDATE_DATE + 1);

      p_avg_row_len := x_total;

   Exception When others then
      rollback;

   END;

END EDW_MRP_PLAN_M_SIZE;

/
