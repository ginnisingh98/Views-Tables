--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPI_PRDL_M_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPI_PRDL_M_SZ" as
/* $Header: OPIOPLZB.pls 120.1 2005/06/07 02:36:09 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
  CURSOR c_cnt_rows IS
	select count(*) cnt
	     FROM WIP_LINES WL,
		MTL_PARAMETERS MP
	     where WL.ORGANIZATION_ID = MP.ORGANIZATION_ID
		and wl.last_update_date between p_from_date and p_to_date;

BEGIN

  OPEN c_cnt_rows;
       FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;

END;  -- procedure cnt_rows.


PROCEDURE est_row_len(p_from_date DATE,
                   p_to_date DATE,
                   p_est_row_len OUT NOCOPY NUMBER) IS

  x_date                 number := 7;
  x_total                number := 0;
  x_constant             number := 6;

  cursor c_wl is
    select avg(nvl(vsize(wl.line_id),0)) line_id,
	avg(nvl(vsize(wl.line_code),0))  code,
	avg(nvl(vsize(wl.description),0)) des
	from wip_lines wl
	where wl.last_update_date between p_from_date and p_to_date;

  CURSOR c_org IS
     SELECT avg(nvl(Vsize(organization_id), 0)) org_id,
       avg(nvl(Vsize(organization_code), 0))    org_code
       FROM mtl_parameters;

  CURSOR c_instance IS
     SELECT
       avg(nvl(vsize(instance_code), 0))
       FROM	EDW_LOCAL_INSTANCE ;

   x_instance_fk NUMBER;
   l_org       c_org%ROWTYPE;
   l_wl        c_wl%rowtype;

BEGIN

   OPEN c_instance;
   FETCH c_instance INTO  x_instance_fk;
   CLOSE c_instance;

   OPEN c_org;
   FETCH c_org INTO l_org;
   CLOSE c_org;

   open c_wl;
   fetch c_wl into l_wl;
   close c_wl;

   x_total := x_total
     -- PRDL_PK
     + Ceil( l_wl.line_id +x_instance_fk +l_org.org_id +l_org.org_code +6 +1)
     -- PRDL_DP  NAME  PRDL_NAME
     + 3* ceil( l_wl.code + 1)
     -- ALL_FK
     + 3
     -- DESCRIPTION
     + ceil( l_wl.des + 1)
     -- ORGN_CODE
     + Ceil( l_org.org_code + 1)
     -- LAST_UPDATE_DATE  CREATION_DATE
     + 2 * x_date;

   p_est_row_len := x_total ;

END ;

END opi_edw_opi_prdl_m_sz;

/
