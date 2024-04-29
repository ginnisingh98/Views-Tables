--------------------------------------------------------
--  DDL for Package Body CSTPUPDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPUPDT" AS
/* $Header: CSTPUPDB.pls 120.1 2006/02/14 17:03:10 ssreddy noship $ */

FUNCTION cstulock (
table_name              in      varchar2,
l_cost_type_id          in      number,
l_organization_id       in      number,
l_list_id               in      number,
err_buf                 out NOCOPY     varchar2,
l_list_id1              in      number
)
return integer
IS
status          number;
L_NO_DATA_FOUND   number := 100;

/* Removed hint from follwing Insert stmt for POSCO issue: Bug #1665358.
    + ORDERED USE_NL(CIC CL) INDEX(CL CST_LISTS_U1) INDEX(CIC CST_ITEM_COSTS_U1)
*/
CURSOR cc is
        SELECT
        CIC.INVENTORY_ITEM_ID
        FROM
             CST_LISTS CL,
             CST_ITEM_COSTS CIC
        WHERE CIC.ORGANIZATION_ID = l_organization_id
        AND   CIC.COST_TYPE_ID = l_cost_type_id
        AND   CL.LIST_ID = l_list_id
        AND   CL.ENTITY_ID = CIC.INVENTORY_ITEM_ID
        FOR UPDATE OF CIC.LAST_UPDATED_BY NOWAIT;

/* Removed hint from follwing Insert stmt for POSCO issue: Bug #1665358.
    + ORDERED USE_NL(CICD CL) INDEX(CL CST_LISTS_U1) INDEX(CICD CST_ITEM_COST_DETAILS_N1)
*/
CURSOR cd is
        SELECT
        CICD.INVENTORY_ITEM_ID
        FROM
             CST_LISTS CL,
             CST_ITEM_COST_DETAILS CICD
        WHERE CICD.ORGANIZATION_ID = l_organization_id
        AND   CL.LIST_ID = l_list_id
        AND   CL.ENTITY_ID = CICD.INVENTORY_ITEM_ID
        AND   CICD.COST_TYPE_ID = l_cost_type_id
        FOR UPDATE OF CICD.LAST_UPDATED_BY NOWAIT;

CURSOR crc is
        SELECT
        CRC.RESOURCE_ID
        FROM
             CST_LISTS_TEMP CLT,
             CST_RESOURCE_COSTS CRC
        WHERE CRC.ORGANIZATION_ID = l_organization_id
        AND   CLT.LIST_ID = l_list_id
        AND   CLT.NUMBER_1 = CRC.RESOURCE_ID
        AND   CRC.COST_TYPE_ID = l_cost_type_id
FOR UPDATE OF CRC.LAST_UPDATED_BY NOWAIT;

CURSOR cdo is
        SELECT
        CDO.DEPARTMENT_ID
        FROM
             CST_LISTS_TEMP CLT,
             CST_DEPARTMENT_OVERHEADS CDO
        WHERE CDO.ORGANIZATION_ID = l_organization_id
        AND   CLT.LIST_ID = l_list_id
        AND   CLT.NUMBER_1 = CDO.OVERHEAD_ID
        AND   CDO.COST_TYPE_ID = l_cost_type_id
FOR UPDATE OF CDO.LAST_UPDATED_BY NOWAIT;

CURSOR cro is
        SELECT
        CRO.RESOURCE_ID
        FROM
             CST_LISTS_TEMP CLT1,
	         CST_LISTS_TEMP CLT2,
             CST_RESOURCE_OVERHEADS CRO
        WHERE CRO.ORGANIZATION_ID = l_organization_id
        AND   CLT1.LIST_ID = l_list_id
        AND   CLT1.NUMBER_1 = CRO.RESOURCE_ID
        AND   CLT2.LIST_ID = l_list_id1
        AND   CLT2.NUMBER_1 = CRO.OVERHEAD_ID
        AND   CRO.COST_TYPE_ID = l_cost_type_id
FOR UPDATE OF CRO.LAST_UPDATED_BY NOWAIT;

BEGIN
    if table_name = 'CST_ITEM_COSTS' then
        OPEN cc;
        status := SQLCODE;
    elsif table_name = 'CST_ITEM_COST_DETAILS' then
        OPEN cd;
        status := SQLCODE;
    elsif table_name = 'CST_RESOURCE_COSTS' then
        OPEN crc;
        status := SQLCODE;
    elsif table_name = 'CST_DEPARTMENT_OVERHEADS' then
        OPEN cdo;
        status := SQLCODE;
    elsif table_name = 'CST_RESOURCE_OVERHEADS' then
        OPEN cro;
        status := SQLCODE;
    else
        status := L_NO_DATA_FOUND;
    end if;
    return (status);
EXCEPTION
        when others then
                status := SQLCODE;
                err_buf := 'CSTULOCK:' || substrb(sqlerrm,1,60);
                return(status);
END cstulock;

function cstuwait_lock(
l_cost_type_id          in      number,
l_organization_id       in      number,
l_list_id               in      number,
err_buf                 out NOCOPY     varchar2,
l_res_list_id           in      number,
l_ovh_list_id           in      number
)
return integer
is
status  number := -54; /* Refers to the ORA-00054 error message:
                          resource busy and acquire with NOWAIT specified */
counter number := 0;
BEGIN
        /*
        ** Lock the table of CST_ITEM_COSTS
        */
        while (counter < NUM_TRIES and status = -54) LOOP
                status := CSTPUPDT.cstulock('CST_ITEM_COSTS',l_cost_type_id,
                        l_organization_id,
                        l_list_id,err_buf);
                if status = -54 then
                        DBMS_LOCK.SLEEP(SLEEP_TIME);
                end if;
                counter := counter + 1;
        end LOOP;
        if status <> 0 then
                if status = -54 then
                   err_buf := 'CST_LOCK_FAILED_CIC';
                   status := 9999;
                end if;
                return(status);
        end if;
        /*
        ** Lock the table of CST_ITEM_COST_DETAILS
        */
        status := -54;
        while (counter < NUM_TRIES and status = -54) LOOP
                status := cstpupdt.cstulock('CST_ITEM_COST_DETAILS',
                        l_cost_type_id,
                        l_organization_id,
                        l_list_id,err_buf);
                if status = -54 then
                         DBMS_LOCK.SLEEP(SLEEP_TIME);
                end if;
                counter := counter + 1;
        end LOOP;
        if status <> 0 then
            if status = -54 then
               err_buf := 'CST_LOCK_FAILED_CICD';
               status := 9999;
            end if;
            return(status);
        end if;
        if (l_res_list_id is not null and l_ovh_list_id is not null) then
        /*
        ** Lock the table of CST_RESOURCE_COSTS
        */
            status := -54;
            while (counter < NUM_TRIES and status = -54) LOOP
                status := cstpupdt.cstulock('CST_RESOURCE_COSTS',
                        l_cost_type_id,
                        l_organization_id,
                        l_res_list_id, err_buf);
                if status = -54 then
                        DBMS_LOCK.SLEEP(SLEEP_TIME);
                end if;
                counter := counter + 1;
            end LOOP;
            if status <> 0 then
                if status = -54 then
                     err_buf := 'CST_LOCK_FAILED_CRC';
                     status := 9999;
               	 end if;
	         return(status);
            end if;
            /*
            ** Lock the table of CST_DEPARTMENT_OVERHEADS
            */
            status := -54;
            while (counter < NUM_TRIES and status = -54) LOOP
                status := cstpupdt.cstulock('CST_DEPARTMENT_OVERHEADS',
                        l_cost_type_id,
                        l_organization_id,
                        l_ovh_list_id, err_buf);
                if status = -54 then
                    DBMS_LOCK.SLEEP(SLEEP_TIME);
                end if;
                counter := counter + 1;
            end LOOP;
            if status <> 0 then
                if status = -54 then
                    err_buf := 'CST_LOCK_FAILED_CDO';
                    status := 9999;
                end if;
                return(status);
            end if;
            /*
            ** Lock the table of CST_RESOURCE_OVERHEADS
            */
            status := -54;
            while (counter < NUM_TRIES and status = -54) LOOP
                status := cstpupdt.cstulock('CST_RESOURCE_OVERHEADS',
                        l_cost_type_id,
                        l_organization_id,
                        l_res_list_id, err_buf, l_ovh_list_id);
                if status = -54 then
                    DBMS_LOCK.SLEEP(SLEEP_TIME);
                end if;
                counter := counter + 1;
            end LOOP;
            if status <> 0 then
                if status = -54 then
                    err_buf := 'CST_LOCK_FAILED_CRO';
                    status := 9999;
                end if;
                return(status);
            end if;
        end if;
        return(status);
EXCEPTION
        when others then
                status := SQLCODE;
                err_buf := 'CSTUWAIT:' || substrb(sqlerrm,1,60);
                return(status);
END cstuwait_lock;

FUNCTION cstudlci(
l_cost_type_id          in      number,
l_organization_id       in      number,
err_buf                 out NOCOPY     varchar2
)
return integer
is

return_code             number;

CURSOR del_cur1 IS
       SELECT inventory_item_id
       FROM cst_item_costs cic
       WHERE cic.organization_id = l_organization_id
       AND   cic.cost_type_id = l_cost_type_id;

BEGIN
      FOR del_cic_cur IN del_cur1 loop
          DELETE CST_ITEM_COSTS cic
          WHERE organization_id = l_organization_id
          AND   cost_type_id = 1
          AND   inventory_item_id = del_cic_cur.inventory_item_id;
      END LOOP;

      return_code := 0;
      return(return_code);

EXCEPTION
     when others then
                return_code := SQLCODE;
                err_buf := 'CSTUDLCI: '|| substrb(sqlerrm,1,60);
                return(return_code);
END cstudlci;

FUNCTION cstudlcd(
l_cost_type_id          in      number,
l_organization_id       in      number,
err_buf                 out NOCOPY     varchar2
)
return integer
is

return_code             number;

CURSOR del_cur2 IS
       SELECT inventory_item_id
       FROM cst_item_costs_temp cict;

BEGIN
      FOR del_cicd_cur IN del_cur2 loop
          DELETE CST_ITEM_COST_DETAILS cicd
          WHERE organization_id = l_organization_id
          AND   cost_type_id = 1
          AND  inventory_item_id = del_cicd_cur.inventory_item_id;
        END LOOP;

      return_code := 0;
      return(return_code);

EXCEPTION
     when others then
                return_code := SQLCODE;
                err_buf := 'CSTUDLCD: '|| substrb(sqlerrm,1,60);
                return(return_code);
END cstudlcd;

FUNCTION cstudlcv(
l_cost_update_id        in      number,
err_buf                 out NOCOPY     varchar2
)
return integer
is

return_code             number;

BEGIN
    DELETE FROM cst_std_cost_adj_values V
    WHERE  v.cost_update_id   = l_cost_update_id
      AND  v.transaction_type = 7  -- resource overhead
      AND  (V.old_unit_cost = 0 OR V.new_unit_cost = 0)
      AND  EXISTS
          (SELECT  'X'
             FROM  CST_STD_COST_ADJ_VALUES v1
            WHERE  v1.cost_update_id      = l_cost_update_id
             AND   v1.transaction_type    = 7
             AND   v1.organization_id     = v.organization_id
             AND   v1.wip_entity_id       = v.wip_entity_id
             AND   v1.operation_seq_num   = v.operation_seq_num
             AND   v1.resource_id         = v.resource_id
             AND   v1.resource_seq_num    = v.resource_seq_num
             AND   v1.basis_type          = v.basis_type
             AND   v1.adjustment_quantity = v.adjustment_quantity
             AND   (
                     (    v.new_unit_cost  = 0
                      AND v1.old_unit_cost = 0
                      AND v.old_unit_cost  = v1.new_unit_cost
                     )
                     OR
                     (   v1.new_unit_cost  = 0
                      AND v.old_unit_cost  = 0
                      AND v1.old_unit_cost = v.new_unit_cost
                     )
                   )
             AND   v1.rowid <> v.rowid
           );
      return_code := 0;
      return(return_code);

EXCEPTION
     when others then
                return_code := SQLCODE;
                err_buf := 'CSTUDLCV: '|| substrb(sqlerrm,1,60);
                return(return_code);
END cstudlcv;

FUNCTION cstudlc2(
l_cost_update_id        in      number,
err_buf                 out NOCOPY     varchar2
)
return integer
is

return_code             number;

CURSOR del_cur4 IS
        SELECT organization_id,   wip_entity_id,
               operation_seq_num, resource_seq_num
        FROM CST_STD_COST_ADJ_VALUES
        WHERE cost_update_id = l_cost_update_id
        AND   transaction_type + 0 = 7;

BEGIN
        FOR del_c2_cur IN del_cur4 LOOP
          DELETE CST_STD_COST_ADJ_VALUES
          WHERE cost_update_id = l_cost_update_id
          AND   new_unit_cost = old_unit_cost
          AND   transaction_type = 6
          AND   organization_id + 0 = del_c2_cur.organization_id
          and   wip_entity_id = del_c2_cur.wip_entity_id
          AND   operation_seq_num = del_c2_cur.operation_seq_num
          AND   resource_seq_num = del_c2_cur.resource_seq_num;
      END LOOP;

      return_code := 0;
      return(return_code);

EXCEPTION
     when others then
                return_code := SQLCODE;
                err_buf := 'CSTUDLC2: '|| substrb(sqlerrm,1,60);
                return(return_code);
END cstudlc2;

FUNCTION cstudlc3(
l_cost_update_id        in      number,
err_buf                 out NOCOPY     varchar2
)
return integer
is

return_code             number;

BEGIN
DELETE  cst_std_cost_adj_values V
        WHERE V.rowid in
            (SELECT VV1.rowidtodel
             FROM   cst_std_cost_adj_tmp1_v  VV1, cst_std_cost_adj_tmp2_v VV2
             WHERE  VV1.transaction_id = VV2.transaction_id
             AND    VV1.cost_element_id = VV2.cost_element_id
             AND    VV1.level_type = VV2.level_type
             AND    VV1.unit_cost = VV2.unit_cost
             AND    VV1.new_unit_cost = VV2.old_unit_cost
             AND    VV1.cost_update_id = l_cost_update_id
             AND    VV2.cost_update_id = l_cost_update_id);

  return_code := 0;
  return(return_code);

EXCEPTION
     when others then
          return_code := SQLCODE;
          err_buf := 'CSTUDLC3: '|| substrb(sqlerrm,1,60);
  	  return(return_code);
END cstudlc3;


END CSTPUPDT;


/
