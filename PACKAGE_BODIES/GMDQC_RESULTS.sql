--------------------------------------------------------
--  DDL for Package Body GMDQC_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDQC_RESULTS" AS
/* $Header: GMDCOMB.pls 120.0 2005/05/25 19:54:45 appldev noship $ */
function QC_FIND_SPEC (
p_item_id       qc_spec_mst.item_id%type,
p_sample_date   qc_smpl_mst.sample_date%type,
P_orgn_code     qc_spec_mst.orgn_code%type,
P_CUST_ID       qc_spec_mst.CUST_ID%type    default NULL,
P_VENDOR_ID     qc_spec_mst.VENDOR_ID%type  default NULL,
P_LOT_ID        qc_spec_mst.LOT_ID%type     default NULL,
P_WHSE_CODE     qc_spec_mst.WHSE_CODE%type  default NULL,
P_LOCATION      qc_spec_mst.LOCATION%type   default NULL,
P_BATCH_ID      qc_spec_mst.BATCH_ID%type   default NULL,
P_FORMULA_ID    qc_spec_mst.FORMULA_ID%type default NULL,
P_ROUTING_ID    qc_spec_mst.ROUTING_ID%type default NULL,
P_OPRN_ID       qc_spec_mst.OPRN_ID%type    default NULL,
p_routingstep_id qc_spec_mst.routingstep_id%type  default NULL)

return varchar2  is
v_temp_string varchar2(2000);
V_count          number;
V_count1         number;
V_cust_id        number;
V_vendor_id      number;
V_LOT_ID         number;
V_BATCH_ID       number;
V_FORMULA_ID     number;
V_ROUTING_ID     number;
V_OPRN_ID        number;
V_routingstep_id number;
/* skarimis 07/18/2000 added V_add_string variable which hold the Null conditions for Item Specifications*/
v_add_string    varchar2(2000);

begin
  if p_cust_id is not NULL OR
     p_vendor_id is not NULL then
  /* Customer/Vender Specification */
     select nvl(p_cust_id,0) into v_cust_id from dual;
     select nvl(p_vendor_id,0) into v_vendor_id from dual;
         /* Local Customer/Vender */
         SELECT count(*) into v_count
         FROM   qc_spec_mst
         WHERE  item_id = p_item_id
         AND    p_sample_date BETWEEN from_date AND to_date
         AND    delete_mark = 0
         AND    orgn_code = p_orgn_code
         AND    NVL(cust_id,0) = v_cust_id
         AND    NVL(vendor_id,0) = v_vendor_id ;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id||
                     ' AND ' ||''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0
                     AND    orgn_code ='||''''||p_orgn_code||''''||' AND NVL(cust_id,0) = '||v_cust_id||
                    ' AND    NVL(vendor_id,0) = '||v_vendor_id into v_temp_string from dual;
              return v_temp_string;
         end if;

            /* Global Customer/Vender */
            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code is NULL
            AND    NVL(cust_id,0) = v_cust_id
            AND    NVL(vendor_id,0) = v_vendor_id;

            if v_count > 0 then
                 select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id||
                        ' AND ' || ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0
                        AND orgn_code is NULL  AND  NVL(cust_id,0) = '||v_cust_id||
                        ' AND    NVL(vendor_id,0) = '||v_vendor_id into v_temp_string from dual;
                 return v_temp_string;
             end if;
  elsif
     P_BATCH_ID is not NULL OR
     P_FORMULA_ID is not NULL OR
     P_ROUTING_ID is not NULL OR
     P_OPRN_ID is not NULL OR
     P_routingstep_id is not NULL then
  /* Production Specification */

     select nvl(p_batch_id,0) into v_batch_id from dual;
     select nvl(p_formula_id,0) into v_formula_id from dual;
     select nvl(p_routing_id,0) into v_routing_id from dual;
     select nvl(p_oprn_id,0) into v_oprn_id from dual;
     select nvl(p_routingstep_id,0) into v_routingstep_id from dual;

         /* ORG + Batch + Formula + Routing + Operation */
         SELECT count(*) into v_count
         FROM   qc_spec_mst
         WHERE  item_id = p_item_id
         AND    p_sample_date BETWEEN from_date AND to_date
         AND    delete_mark = 0
         AND    orgn_code = p_orgn_code
         AND    NVL(batch_id,0) = v_batch_id
         AND    NVL(formula_id,0) = v_formula_id
         AND    NVL(routing_id,0) = v_routing_id
         AND    NVL(routingstep_id,0) = v_routingstep_id
         AND    NVL(oprn_id,0) = v_oprn_id;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND
                      delete_mark = 0 AND    orgn_code ='||''''||p_orgn_code||''''||
                      ' AND NVL(batch_id,0) = '||v_batch_id||
            	    ' AND NVL(formula_id,0) = '||v_formula_id||
           		    ' AND NVL(routing_id,0) = '||v_routing_id||
                      ' AND NVL(routingstep_id,0) = '||v_routingstep_id||
                      ' AND NVL(oprn_id,0) = '||v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Batch + Formula + Routing + Operation */
         v_count  := 0;

         if v_batch_id > 0 or
            v_formula_id > 0 or
            v_routing_id > 0 or
            v_routingstep_id > 0 or
            v_oprn_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    NVL(batch_id,0) = v_batch_id
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(routing_id,0) = v_routing_id
           AND    NVL(routingstep_id,0) = v_routingstep_id
           AND    NVL(oprn_id,0) = v_oprn_id;
         end if;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                     ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                     orgn_code is NULL'||
             ' AND NVL(batch_id,0) = '||v_batch_id||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(routing_id,0) = '||v_routing_id||
             ' AND NVL(routingstep_id,0) = '||v_routingstep_id||
             ' AND NVL(oprn_id,0) = '||v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Orgn + Batch + Formula + Routing */
         v_count  := 0;

         if v_batch_id > 0 or
            v_formula_id > 0 or
            v_routing_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(batch_id,0) = v_batch_id
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(routing_id,0) = v_routing_id;
         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                     ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                     orgn_code ='||''''||p_orgn_code||''''||
             ' AND NVL(batch_id,0) = '||v_batch_id||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(routing_id,0) = '||v_routing_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;


         /* Batch + Formula + Routing */
         v_count  := 0;

         if v_batch_id > 0 or
            v_formula_id > 0 or
            v_routing_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    NVL(batch_id,0) = v_batch_id
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(routing_id,0) = v_routing_id;
         end if;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                     ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0
                          AND    orgn_code is NULL'||
             ' AND NVL(batch_id,0) = '||v_batch_id||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(routing_id,0) = '||v_routing_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Orgn + Batch + Formula*/
         v_count  := 0;

         if v_batch_id > 0 or
            v_formula_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(batch_id,0) = v_batch_id
           AND    NVL(formula_id,0) = v_formula_id;
         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND '
                      ||''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                      orgn_code ='||''''||p_orgn_code||''''||
             ' AND NVL(batch_id,0) = '||v_batch_id||
             ' AND NVL(formula_id,0) = '||v_formula_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Batch + Formula */
         v_count  := 0;

         if v_batch_id > 0 or
            v_formula_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    NVL(batch_id,0) = v_batch_id
           AND    NVL(formula_id,0) = v_formula_id;
         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND '
                      ||''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                       orgn_code is NULL'||
             ' AND NVL(batch_id,0) = '||v_batch_id||
             ' AND NVL(formula_id,0) = '||v_formula_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;


         /* Orgn + Formula + Routing + Operation*/
         v_count  := 0;

         if v_formula_id > 0 or
            v_routing_id > 0 or
            v_routingstep_id > 0 or
            v_oprn_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(routing_id,0) = v_routing_id
           AND    NVL(routingstep_id,0) = v_routingstep_id
           AND    NVL(oprn_id,0) = v_oprn_id;
         end if;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code ='||
                        ''''||p_orgn_code||''''||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(routing_id,0) = '||v_routing_id||
             ' AND NVL(routingstep_id,0) = '||v_routingstep_id||
             ' AND NVL(oprn_id,0) = '||v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Formula + Routing + Operation*/
         v_count  := 0;

         if v_formula_id > 0 or
            v_routing_id > 0 or
            v_routingstep_id > 0 or
            v_oprn_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(routing_id,0) = v_routing_id
           AND    NVL(routingstep_id,0) = v_routingstep_id
           AND    NVL(oprn_id,0) = v_oprn_id;
         end if;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                      orgn_code is NULL'||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(routing_id,0) = '||v_routing_id||
             ' AND NVL(routingstep_id,0) = '||v_routingstep_id||
             ' AND NVL(oprn_id,0) = '||v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Orgn + Formula + Routing */
         v_count  := 0;

         if v_formula_id > 0 or
            v_routing_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(routing_id,0) = v_routing_id;
         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code ='||
                      ''''||p_orgn_code||''''||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(routing_id,0) = '||v_routing_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Formula + Routing */
         v_count  := 0;

         if v_formula_id > 0 or
            v_routing_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(routing_id,0) = v_routing_id;
         end if;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                      p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code is NULL'||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(routing_id,0) = '||v_routing_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

       /* SKARIMIS Added this condition due to bug raised by Joan on vis database bug no 1347027 date 07/18/2000 */
       /* Orgn + Formula */
         v_count  := 0;

         if p_orgn_code is NOT NULL AND v_formula_id > 0 then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(formula_id,0) = v_formula_id;
         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code ='||
                      ''''||p_orgn_code||''''||
             ' AND NVL(formula_id,0) = '||v_formula_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;
       /* End of New Code addition */

         /* Orgn + Formula + Operation OR Orgn + Routing + Routing Step */
         v_count  := 0;
         v_count1 := 0;

         if v_formula_id > 0 or
            v_oprn_id > 0 then

           SELECT min(preference) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(formula_id,0) = v_formula_id
           AND    NVL(oprn_id,0) = v_oprn_id;
         end if;

         if v_routing_id > 0 or
            v_routingstep_id > 0 or
            v_oprn_id > 0 then

           SELECT min(preference) into v_count1
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(routing_id,0) = v_routing_id
           AND    NVL(routingstep_id,0) = v_routingstep_id
           AND    NVL(oprn_id,0) = v_oprn_id;
         end if;

         if v_count1 > 0 and v_count1 < v_count then

             select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                     p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code ='||
                     ''''||p_orgn_code||''''||
             ' AND NVL(routing_id,0) = '|| v_routing_id||
             ' AND NVL(routingstep_id,0) = '|| v_routingstep_id||
             ' AND NVL(oprn_id,0) = '|| v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         if v_count > 0 and v_count < v_count1 then

              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code ='||
                      ''''||p_orgn_code||''''||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(oprn_id,0) = '||v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Formula + Operation OR Routing + Routing step */
         v_count  := 0;
         v_count1 := 0;
         if v_formula_id > 0 or
            v_oprn_id > 0 then

            SELECT min(preference) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code is NULL
            AND    NVL(formula_id,0) = v_formula_id
            AND    NVL(oprn_id,0) = v_oprn_id;
         end if;

         if v_routing_id > 0 or
            v_routingstep_id > 0 or
            v_oprn_id > 0 then
           SELECT min(preference) into v_count1
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    NVL(routing_id,0) = v_routing_id
           AND    NVL(routingstep_id,0) = v_routingstep_id
           AND    NVL(oprn_id,0) = v_oprn_id;
         end if;

         if v_count1 > 0 and v_count1 < v_count then

             select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                             ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                             orgn_code is NULL'||
             ' AND NVL(routing_id,0) = '|| v_routing_id||
             ' AND NVL(routingstep_id,0) = '|| v_routingstep_id||
             ' AND NVL(oprn_id,0) = '|| v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         if v_count > 0 and v_count < v_count1 then

              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                      orgn_code is NULL '||
             ' AND NVL(formula_id,0) = '||v_formula_id||
             ' AND NVL(oprn_id,0) = '||v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Formula OR Routing */
         v_count  := 0;
         v_count1 := 0;
         if v_formula_id > 0 then
           SELECT min(preference) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    formula_id = v_formula_id;
         end if;

         if v_routing_id > 0 then
           SELECT min(preference) into v_count1
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    routing_id = v_routing_id;
         end if;

         if (v_count > 0 and v_count1 > 0 and v_count < v_count1) or
            (v_count > 0 and v_count1 = 0 ) then

              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                      p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                      orgn_code is NULL'||
             ' AND formula_id = '||v_formula_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         if (v_count > 0 and v_count1 > 0 and v_count1 < v_count) or
            (v_count1 > 0 and v_count = 0 ) then

              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                      p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code is NULL'||
                      ' AND routing_id = '||v_routing_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;

         /* Operation */
         V_count := 0;
         if v_oprn_id > 0 then
           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    oprn_id = v_oprn_id;
         end if;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                     p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code is NULL'||
             ' AND oprn_id = '||v_oprn_id
             into v_temp_string from dual;
             return v_temp_string;
         end if;
  else
  /* Item Specification */

     v_add_string:=' AND (FORMULA_ID IS NULL AND ROUTING_ID IS NULL AND OPRN_ID IS NULL AND CUST_ID IS NULL AND VENDOR_ID IS NULL)';

     select nvl(p_lot_id,0) into v_lot_id from dual;

         /* Orgn + Lot/Sublot + Warehouse + Location */
         v_count  := 0;

         if v_lot_id > 0 or
            p_whse_code is NOT NULL or
            p_location is NOT NULL then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(lot_id,0) = v_lot_id
           AND    NVL(whse_code,0) = NVL(p_whse_code,0)
           AND    NVL(location,0) = NVL(p_location,0)
           AND    FORMULA_ID IS NULL
           AND    ROUTING_ID IS NULL
           AND    OPRN_ID IS NULL
           AND    CUST_ID IS NULL
           AND    VENDOR_ID IS NULL;
         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                      p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND orgn_code ='||''''||
                      p_orgn_code||''''||
             ' AND NVL(lot_id,0) = '||v_lot_id||
             ' AND NVL(whse_code,0) = NVL('||''''||p_whse_code||''''||',0)'||
             ' AND NVL(location,0) = NVL('||''''||p_location||''''||',0)'
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Lot/Sublot + Warehouse + Location */
         v_count  := 0;

         if v_lot_id > 0 or
            p_whse_code is NOT NULL or
            p_location is NOT NULL then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code is NULL
           AND    NVL(lot_id,0) = v_lot_id
           AND    NVL(whse_code,0) = NVL(p_whse_code,0)
           AND    NVL(location,0) = NVL(location,0)
           AND    FORMULA_ID IS NULL
           AND    ROUTING_ID IS NULL
           AND    OPRN_ID IS NULL
           AND    CUST_ID IS NULL
           AND    VENDOR_ID IS NULL;

         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                      p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code is NULL'||
             ' AND NVL(lot_id,0) = '||v_lot_id||
             ' AND NVL(whse_code,0) = NVL('||''''||p_whse_code||''''||',0)'||
             ' AND NVL(location,0) = NVL('||''''||p_location||''''||',0)'
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Orgn + Lot/Sublot + Warehouse */
         v_count  := 0;

         if v_lot_id > 0 or
            p_whse_code is NOT NULL then

            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code = p_orgn_code
            AND    NVL(lot_id,0) = v_lot_id
            AND    NVL(whse_code,0) = NVL(p_whse_code,0)
            AND    FORMULA_ID IS NULL
            AND    ROUTING_ID IS NULL
            AND    OPRN_ID IS NULL
            AND    CUST_ID IS NULL
            AND    VENDOR_ID IS NULL;

         end if;

         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND '
                       ||''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                        orgn_code ='||''''||p_orgn_code||''''||
             ' AND NVL(lot_id,0) = '||v_lot_id||
             ' AND NVL(whse_code,0) = NVL('||''''||p_whse_code||''''||',0)'
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Lot/Sublot + Warehouse */
         v_count  := 0;

         if v_lot_id > 0 or
            p_whse_code is NOT NULL then

            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code is NULL
            AND    NVL(lot_id,0) = v_lot_id
            AND    NVL(whse_code,0) = NVL(p_whse_code,0)
            AND    FORMULA_ID IS NULL
            AND    ROUTING_ID IS NULL
            AND    OPRN_ID IS NULL
            AND    CUST_ID IS NULL
            AND    VENDOR_ID IS NULL;

         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND '
                      ||''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                      orgn_code is NULL'||
             ' AND NVL(lot_id,0) = '||v_lot_id||
             ' AND NVL(whse_code,0) = NVL('||''''||p_whse_code||''''||',0)'
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Orgn + Lot/Sublot */
         v_count  := 0;

         if v_lot_id > 0 then

            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code = p_orgn_code
            AND    lot_id = v_lot_id
            AND    FORMULA_ID IS NULL
            AND    ROUTING_ID IS NULL
            AND    OPRN_ID IS NULL
            AND    CUST_ID IS NULL
            AND    VENDOR_ID IS NULL;

         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND '
                      ||''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                      orgn_code ='||''''||p_orgn_code||''''||
             ' AND lot_id = '||v_lot_id
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Lot/Sublot */
         v_count  := 0;

         if v_lot_id > 0 then

            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code is NULL
            AND    lot_id = v_lot_id
            AND    FORMULA_ID IS NULL
            AND    ROUTING_ID IS NULL
            AND    OPRN_ID IS NULL
            AND    CUST_ID IS NULL
            AND    VENDOR_ID IS NULL;

         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                         orgn_code is NULL'||
             ' AND lot_id = '||v_lot_id
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Orgn Warehouse + Location */
         v_count  := 0;

         if p_whse_code is NOT NULL or
            p_location  is NOT NULL then

           SELECT count(*) into v_count
           FROM   qc_spec_mst
           WHERE  item_id = p_item_id
           AND    p_sample_date BETWEEN from_date AND to_date
           AND    delete_mark = 0
           AND    orgn_code = p_orgn_code
           AND    NVL(whse_code,0) = NVL(p_whse_code,0)
           AND    NVL(location,0) = NVL(location,0)
           AND    FORMULA_ID IS NULL
           AND    ROUTING_ID IS NULL
           AND    OPRN_ID IS NULL
           AND    CUST_ID IS NULL
           AND    VENDOR_ID IS NULL;

         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                             ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                            orgn_code ='||''''||p_orgn_code||''''||
             ' AND NVL(whse_code,0) = NVL('||''''||p_whse_code||''''||',0)'||
             ' AND NVL(location,0) = NVL('||''''||p_location||''''||',0)'
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Warehouse + Location */
         v_count  := 0;

         if p_whse_code is NOT NULL or
            p_location  is NOT NULL then

            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code is NULL
            AND    NVL(whse_code,0) = NVL(p_whse_code,0)
            AND    NVL(location,0) = NVL(location,0)
            AND    FORMULA_ID IS NULL
            AND    ROUTING_ID IS NULL
            AND    OPRN_ID IS NULL
            AND    CUST_ID IS NULL
            AND    VENDOR_ID IS NULL;

         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''||
                      p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code is NULL'||
             ' AND NVL(whse_code,0) = NVL('||''''||p_whse_code||''''||',0)'||
             ' AND NVL(location,0) = NVL('||''''||p_location||''''||',0)'
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Orgn Warehouse */
         v_count  := 0;

         if p_whse_code is not NULL then

            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code = p_orgn_code
            AND    whse_code = p_whse_code
            AND    FORMULA_ID IS NULL
            AND    ROUTING_ID IS NULL
            AND    OPRN_ID IS NULL
            AND    CUST_ID IS NULL
            AND    VENDOR_ID IS NULL;
         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||''''
                      ||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND    orgn_code ='||
                      ''''||p_orgn_code||''''||
             ' AND whse_code = '||''''||p_whse_code||''''
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;

         /* Warehouse */
         v_count  := 0;

         if p_whse_code is not NULL then

            SELECT count(*) into v_count
            FROM   qc_spec_mst
            WHERE  item_id = p_item_id
            AND    p_sample_date BETWEEN from_date AND to_date
            AND    delete_mark = 0
            AND    orgn_code is NULL
            AND    whse_code = p_whse_code
            AND    FORMULA_ID IS NULL
            AND    ROUTING_ID IS NULL
            AND    OPRN_ID IS NULL
            AND    CUST_ID IS NULL
            AND    VENDOR_ID IS NULL;

         end if;
         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                            orgn_code is NULL'||
             ' AND whse_code = '||''''||p_whse_code||''''
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;
  end if;
  /*  ORGN + ITEM */
         v_count  := 0;
         SELECT count(*) into v_count
         FROM   qc_spec_mst
         WHERE  item_id = p_item_id
         AND    p_sample_date BETWEEN from_date AND to_date
         AND    delete_mark = 0
         AND    orgn_code = p_orgn_code
         AND    FORMULA_ID IS NULL
         AND    ROUTING_ID IS NULL
         AND    OPRN_ID IS NULL
         AND    CUST_ID IS NULL
         AND    VENDOR_ID IS NULL;


         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND '
                          ||''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                          orgn_code ='||''''||p_orgn_code||''''
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;
  /* ITEM */
         v_count  := 0;
         SELECT count(*) into v_count
         FROM   qc_spec_mst
         WHERE  item_id = p_item_id
         AND    p_sample_date BETWEEN from_date AND to_date
         AND    delete_mark = 0
         AND    orgn_code is NULL
         AND    FORMULA_ID IS NULL
         AND    ROUTING_ID IS NULL
         AND    OPRN_ID IS NULL
         AND    CUST_ID IS NULL
         AND    VENDOR_ID IS NULL;


         if v_count > 0 then
              select 'SELECT qc_spec_id, assay_code FROM   qc_spec_mst WHERE item_id = ' ||p_item_id|| ' AND ' ||
                      ''''||p_sample_date||''''|| ' BETWEEN from_date AND to_date AND delete_mark = 0 AND
                      orgn_code is NULL'
             into v_temp_string from dual;
             return v_temp_string||v_add_string;
         end if;
    return '';
end qc_find_spec;

end gmdqc_results;

/
