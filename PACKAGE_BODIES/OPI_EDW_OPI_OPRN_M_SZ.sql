--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPI_OPRN_M_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPI_OPRN_M_SZ" as
/* $Header: OPIOONZB.pls 120.1 2005/06/07 02:32:38 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS
  CURSOR c_cnt_rows IS
     select sum(cnt)
       from (select count(*) cnt
	     FROM
	     BOM_OPERATION_SEQUENCES BOS,
	     BOM_OPERATIONAL_ROUTINGS BOR,
	     BOM_STANDARD_OPERATIONS bso
	     WHERE BOS.ROUTING_SEQUENCE_ID = BOR.ROUTING_SEQUENCE_ID
	     AND bos.STANDARD_OPERATION_ID =  BSO.STANDARD_OPERATION_ID (+)
	     AND Greatest( bos.last_update_date, bor.last_update_date,
			   bso.last_update_date) between p_from_date and p_to_date
          UNION ALL
	     SELECT count(*) cnt
	     FROM dual
	     );

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

  CURSOR c_org IS
     SELECT avg(nvl(Vsize(organization_id), 0)) org_id,
       avg(nvl(Vsize(organization_code), 0))    org_code
       FROM mtl_parameters;

  CURSOR c_instance IS
     SELECT
       avg(nvl(vsize(instance_code), 0))
       FROM	EDW_LOCAL_INSTANCE ;

  CURSOR c_bos IS
     SELECT   avg(nvl(vsize(operation_sequence_id), 0)) seq_id,
       avg(nvl(vsize(DEPARTMENT_ID), 0))      dept_id
       FROM bom_operation_sequences
       WHERE last_update_date between p_from_date  and  p_to_date;

  CURSOR c_bso IS
     SELECT  avg(nvl(vsize(OPERATION_CODE), 0)) code,
       avg(nvl(vsize(OPERATION_DESCRIPTION), 0)) des
       FROM   bom_standard_operations
       WHERE last_update_date between p_from_date  and  p_to_date;


   x_instance_fk NUMBER;
   l_org       c_org%ROWTYPE;
   l_bos       c_bos%ROWTYPE;
   l_bso       c_bso%ROWTYPE;


BEGIN

   OPEN c_instance;
   FETCH c_instance INTO  x_instance_fk;
   CLOSE c_instance;

   OPEN c_org;
   FETCH c_org INTO l_org;
   CLOSE c_org;

   OPEN c_bos;
   FETCH c_bos INTO l_bos;
   CLOSE c_bos;

   OPEN c_bso;
   FETCH c_bso INTO l_bso;
   CLOSE c_bso;

   x_total := x_total
     -- OPRN_PK
     + Ceil( Nvl(l_bos.seq_id,0) + l_org.org_id + x_instance_fk +5 + 1)
     -- OPRC_FK
     + 5
     -- OPRN_DP
     + 4
     --  NAME  OPRN_NAME
     + 2 * Ceil( Nvl(l_bso.code,0) + 1)
     -- DESCRIPTION
     + Ceil(Nvl(l_bso.des,0) + 1)
     -- ORGN_CODE
     + Ceil( l_org.org_code + 1)
     -- DEPARTMENT_ID
     + Ceil( Nvl(l_bos.dept_id,0) + 1)
     -- LAST_UPDATE_DATE  CREATION_DATE
     + 2 * x_date;

   p_est_row_len := x_total ;


   --dbms_output.put_line ('******************'||x_total||'******') ;


END ;

END OPI_EDW_OPI_OPRN_M_SZ ;  -- procedure est_row_len.

/
