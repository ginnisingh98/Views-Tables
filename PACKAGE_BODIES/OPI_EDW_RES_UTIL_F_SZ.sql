--------------------------------------------------------
--  DDL for Package Body OPI_EDW_RES_UTIL_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_RES_UTIL_F_SZ" AS
/* $Header: OPIORUZB.pls 120.1 2005/06/16 03:52:08 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

CURSOR c_cnt_rows IS
   select sum(cnt)
     from (
	       -- Third UNION: no wip actual, only availability, 24 hr available
	   SELECT  count(*) cnt
	   FROM
	   bom_resources                   br,
	   bom_departments                 bd,
	   bom_department_resources        bdr,
	   bom_calendar_dates              bcd,
	   mtl_parameters                  mp,
	   mtl_units_of_measure            m1,
	   mtl_units_of_measure            m2
	   WHERE bdr.available_24_hours_flag = 1  -- 24 hr available
	   AND bdr.share_from_dept_id IS NULL
	   AND br.resource_id = bdr.resource_id
	   AND m1.uom_code = fnd_profile.value('BOM:HOUR_UOM_CODE')
	   AND m2.uom_code = br.unit_of_measure
	   AND m2.uom_class = m1.uom_class
	   AND bd.department_id = bdr.department_id
	   AND bd.organization_id = mp.organization_id
	   AND bcd.calendar_code  = mp.calendar_code
	   AND bcd.exception_set_id = mp.calendar_exception_set_id
	   AND bcd.seq_num IS NOT NULL
	   AND ( bd.disable_date IS NULL OR bcd.calendar_date < bd.disable_date)
	   AND ( br.disable_date IS NULL OR bcd.calendar_date < br.disable_date)
	   AND bcd.calendar_date BETWEEN p_from_date AND p_to_date
	 UNION ALL
	     -- Fourth UNION: no wip actual, only availability, shift based
	     SELECT count(*) cnt
	     FROM
	     bom_resources                   br,
	     bom_departments                 bd,
	     bom_department_resources        bdr,
	     bom_resource_shifts             brs,
	     bom_shift_dates                 bsd,
	     bom_shift_times                 bst,
	     mtl_parameters                  mp,
	     mtl_units_of_measure            m1,
	     mtl_units_of_measure            m2
	     WHERE bdr.available_24_hours_flag = 2 -- shift based
	     AND bdr.share_from_dept_id IS NULL
	     AND br.resource_id = bdr.resource_id
	     AND m1.uom_code = fnd_profile.value('BOM:HOUR_UOM_CODE')
	     AND m2.uom_code = br.unit_of_measure
	     AND m2.uom_class = m1.uom_class
	     AND bd.department_id = bdr.department_id
	     AND bd.organization_id = mp.organization_id
	     AND brs.department_id = bd.department_id
	     AND brs.resource_id   = br.resource_id
	     AND bsd.calendar_code = mp.calendar_code
	     AND bsd.exception_set_id = mp.calendar_exception_set_id
	     AND bsd.shift_num     = brs.shift_num
	     AND bsd.seq_num IS NOT NULL
	     AND ( bd.disable_date IS NULL OR bsd.shift_date < bd.disable_date)
	     AND ( br.disable_date IS NULL OR bsd.shift_date < br.disable_date)
	     AND bst.calendar_code = mp.calendar_code
	     AND bst.shift_num     = brs.shift_num
	     AND bsd.shift_date BETWEEN p_from_date AND p_to_date
	     GROUP BY
	     mp.organization_id,
	     mp.organization_code,
	     bd.department_id, -- owning dept
	     bd.department_code,
	     br.resource_id,
	     br.unit_of_measure,
	     bsd.shift_date
	     ) ;
BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                      p_to_date DATE,
                      p_avg_row_len OUT NOCOPY NUMBER) IS
 x_date                 number := 7;
 x_total                number := 0;
 x_constant             number := 6;

 CURSOR c_res IS
    SELECT avg(nvl(vsize(resource_id), 0)) res_id,
      avg(nvl(vsize(unit_of_measure), 0))  uom,
      avg(nvl(vsize(resource_code), 0))    res_code
      FROM bom_resources;

 CURSOR c_instance IS
    SELECT
      avg(nvl(vsize(instance_code), 0))
      FROM	EDW_LOCAL_INSTANCE ;

 CURSOR c_dept IS
    SELECT avg(nvl(Vsize(department_code), 0))
      FROM bom_departments;

 CURSOR c_org IS
    SELECT avg(nvl(Vsize(organization_id), 0)) org_id,
      avg(nvl(Vsize(organization_code), 0))    org_code
      FROM mtl_parameters;

 CURSOR c_act_usage IS
    SELECT AVG(Nvl(Vsize(primary_quantity), 0))
      FROM wip_transactions
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_avail IS
    SELECT   AVG(Nvl(Vsize(24*capacity_units), 0))
      FROM bom_department_resources
      WHERE last_update_date between p_from_date  and  p_to_date;

 CURSOR c_trx_date_fk IS
    SELECT AVG(Nvl(Vsize(EDW_TIME_PKG.CAL_DAY_FK(Sysdate, set_of_books_id) ),0))
      FROM gl_sets_of_books;

 x_res_util_pk NUMBER;

 x_locator_fk  NUMBER;
 x_rsrc_fk     NUMBER;
 x_trx_date_fk NUMBER;
 x_uom_fk      NUMBER;
 x_instance_fk NUMBER;
 x_act_res_usage  NUMBER;
 x_avail_res      NUMBER;
 x_department     NUMBER;
 x_trx_date       NUMBER;

 l_res       c_res%ROWTYPE;
 l_org       c_org%ROWTYPE;


BEGIN
   OPEN c_instance;
   FETCH c_instance INTO  x_instance_fk;
   CLOSE c_instance;

   OPEN c_res ;
   FETCH c_res INTO l_res;
   CLOSE c_res;

   OPEN c_org;
   FETCH c_org INTO l_org;
   CLOSE c_org;

   OPEN c_trx_date_fk;
   FETCH c_trx_date_fk INTO x_trx_date_fk;
   CLOSE c_trx_date_fk;

   OPEN c_dept;
   FETCH c_dept INTO x_department;
   CLOSE c_dept;

   OPEN c_avail;
   FETCH c_avail INTO x_avail_res;
   CLOSE c_avail;

   OPEN c_act_usage;
   FETCH c_act_usage INTO x_act_res_usage;
   CLOSE c_act_usage;

   x_total := 3 + x_total
     --bcd.calendar_date ||'-'|| mp.organization_id ||'-'|| br.resource_id
     --    ||'-'|| inst.instance_code ||'-'|| 'OPI'        res_util_pk,
     + Ceil( x_date + l_org.org_id + l_res.res_id + x_instance_fk + 4 +4 + 1)
     --mp.organization_code ||'-'||inst.instance_code ||'-PLNT' locator_fk
     + Ceil( l_org.org_code + x_instance_fk + 5 +1 + 1)
     --res.resource_code||'-'||dept.department_code||'-'||
     --	mp.organization_code||'-'||inst.instance_code           RSRC_FK,
     + Ceil(l_res.res_code +x_department +l_org.org_code +x_instance_fk +3+1)
     -- EDW_TIME_PKG.CAL_DAY_FK(bcd.calendar_date,To_number(hoi.org_information1))
     -- trx_date_fk,
     + Ceil( x_trx_date_fk +1)
     -- br.unit_of_measure   uom_fk,
     + Ceil(l_res.uom + 1 )
     -- inst.instance_code    instance_fk,
     + Ceil(x_instance_fk +1)
     ;

   -- dbms_output.put_line('1 x_total is ' || x_total );

   x_total := x_total
     -- 5 user_fk with 'NA_EDW'
     + 5* x_constant
     -- act_res_usage,
     + Ceil( Nvl(x_act_res_usage,3) + 1 )
     -- 24* bdr.capacity_units      avail_res,
     + Ceil( Nvl(x_avail_res, 3) + 1)
     -- bd.department_code    department,
     + Ceil(x_department + 1)
     --    bcd.calendar_date    trx_date,
     + x_date
     -- bcd.calendar_date      last_update_date,
     + x_date;

   -- dbms_output.put_line('a2 x_total is ' || x_total );
   p_avg_row_len := x_total;


  END;  -- procedure est_row_len.

END;  -- package body OPI_EDW_RES_UTIL_F_SZ

/
