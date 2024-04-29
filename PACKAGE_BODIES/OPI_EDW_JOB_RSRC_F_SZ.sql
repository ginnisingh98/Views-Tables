--------------------------------------------------------
--  DDL for Package Body OPI_EDW_JOB_RSRC_F_SZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_JOB_RSRC_F_SZ" AS
/* $Header: OPIOJRZB.pls 120.1 2005/06/07 02:15:15 appldev  $*/

PROCEDURE cnt_rows(p_from_date DATE,
                   p_to_date DATE,
                   p_num_rows OUT NOCOPY NUMBER) IS

CURSOR c_cnt_rows IS
	select count(*) from
	(
		select to_char(wor.organization_id)||inst.instance_code
		FROM
		WIP_OPERATION_RESOURCES wor,
		WIP_OPERATIONS wo,
		WIP_ENTITIES we,
		BOM_DEPARTMENTS bd,
		HR_ORGANIZATION_INFORMATION hoi,
		GL_SETS_OF_BOOKS gsob,
		WIP_DISCRETE_JOBS wdj,
		WIP_REPETITIVE_SCHEDULES wrs,
		EDW_LOCAL_INSTANCE inst,
		MTL_SYSTEM_ITEMS msi
		WHERE
    		wor.organization_id = wo.organization_id
		and wor.wip_entity_id = wo.wip_entity_id
		and wor.operation_seq_num = wo.operation_seq_num
		and nvl(wor.repetitive_schedule_id,-99) = nvl(wo.repetitive_schedule_id,-99)
		and wo.organization_id = bd.organization_id
		and wo.department_id = bd.department_id
		and wo.organization_id = we.organization_id
		and wo.wip_entity_id = we.wip_entity_id
		and hoi.organization_id = wor.organization_id
		and gsob.set_of_books_id =  hoi.ORG_INFORMATION1
		and hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
		and wdj.wip_entity_id (+) = wor.wip_entity_id
		and wdj.organization_id (+) = wor.organization_id
		and wrs.repetitive_schedule_id (+)= nvl(wor.repetitive_schedule_id,-99)
		and wrs.organization_id (+) = wor.organization_id
		and (wrs.status_type in (4,5,7,12) or wdj.status_type in (4,5,7,12))
		and msi.organization_id = wor.organization_id
		and msi.inventory_item_id = we.primary_item_id
		and wor.last_update_date between
        	p_from_date and p_to_date
		group by wor.organization_id,wor.wip_entity_id,
		wor.operation_seq_num,wor.resource_id,
		wor.repetitive_schedule_id,wor.activity_id,
		wor.uom_code,wor.basis_type,we.wip_entity_name,
		bd.department_code,
		wo.first_unit_start_date,wo.first_unit_completion_date,
		wo.operation_sequence_id,wo.department_id,
		gsob.set_of_books_id, msi.primary_uom_code,
		we.primary_item_id ,inst.instance_code
UNION ALL
        select
	to_char(wt.organization_id)||inst.instance_code
		FROM
		WIP_ENTITIES we,
		WIP_TRANSACTIONS wt,
		WIP_TRANSACTION_ACCOUNTS wta,
		BOM_DEPARTMENTS bd,
		HR_ORGANIZATION_INFORMATION hoi,
		GL_SETS_OF_BOOKS gsob,
		WIP_FLOW_SCHEDULES wfs,
		BOM_OPERATIONAL_ROUTINGS bor,
		BOM_OPERATION_SEQUENCES bos,
		EDW_LOCAL_INSTANCE inst,
		MTL_SYSTEM_ITEMS msi
		WHERE
    		wt.transaction_type in (1,3)
		and wfs.status = 2
		and wt.wip_entity_id = wfs.wip_entity_id
		and wt.organization_id = wfs.organization_id
		and wt.organization_id = wta.organization_id
		and wt.wip_entity_id = wta.wip_entity_id
		and wt.transaction_id = wta.transaction_id
		and wta.accounting_line_type = 7
		and wt.wip_entity_id = we.wip_entity_id
		and wt.organization_id = we.organization_id
		and wt.organization_id = bd.organization_id
		and wt.department_id = bd.department_id
		and hoi.organization_id = wt.organization_id
		and hoi.ORG_INFORMATION_CONTEXT = 'Accounting Information'
		and gsob.set_of_books_id =  hoi.ORG_INFORMATION1
		and msi.organization_id = wt.organization_id
		and msi.inventory_item_id = we.primary_item_id
		and wfs.organization_id = bor.organization_id
		and nvl(wfs.alternate_routing_designator,-99) = nvl(bor.alternate_routing_designator,-99)
		and wfs.primary_item_id = bor.assembly_item_id
		and bor.routing_sequence_id = bos.routing_sequence_id
		and wt.operation_seq_num = bos.operation_seq_num
		and bos.operation_type = 1
        	and wt.last_update_date between
        	p_from_date and p_to_date
		group by wt.organization_id, wt.wip_entity_id,
		wt.operation_seq_num, wt.resource_id, wt.activity_id,
		wfs.quantity_completed, wfs.date_closed,
		wfs.scheduled_start_date, wfs.scheduled_completion_date,
		wt.basis_type, wt.transaction_uom,wt.primary_uom,
		wt.department_id,we.wip_entity_name,bd.department_code,
		gsob.set_of_books_id,bos.operation_sequence_id,
		msi.primary_uom_code , we.primary_item_id,inst.instance_code  ) ;

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

 x_JOB_RSRC_PK			NUMBER ;
 x_ACT_RSRC_COUNT		NUMBER ;
 x_PLN_RSRC_COUNT		NUMBER ;
 x_ACT_RSRC_QTY			NUMBER ;
 x_ACT_RSRC_VAL_B		NUMBER ;
 x_ACT_RSRC_VAL_G		NUMBER ;
 x_PLN_RSRC_QTY			NUMBER ;
 x_PLN_RSRC_VAL_B		NUMBER ;
 x_PLN_RSRC_VAL_G		NUMBER ;
 x_ACT_RSRC_USAGE		NUMBER ;
 x_PLN_RSRC_USAGE		NUMBER ;
 x_STND_RSRC_USAGE		NUMBER ;
 x_ACT_RSRC_USAGE_VAL_B		NUMBER ;
 x_ACT_RSRC_USAGE_VAL_G		NUMBER ;
 x_PLN_RSRC_USAGE_VAL_B		NUMBER ;
 x_PLN_RSRC_USAGE_VAL_G		NUMBER ;
 x_EXTD_RSRC_COST		NUMBER ;
 x_JOB_NO			NUMBER ;
 x_OPERATION_SEQ_NUM		NUMBER ;
 x_DEPARTMENT			NUMBER ;
 x_ACT_STRT_DATE		NUMBER ;
 x_ACT_CMPL_DATE		NUMBER ;
 x_PLN_STRT_DATE		NUMBER ;
 x_PLN_CMPL_DATE		NUMBER ;
 x_SOB_CURRENCY_FK		NUMBER ;
 x_QTY_UOM_FK			NUMBER ;
 x_INSTANCE_FK			NUMBER ;
 x_LOCATOR_FK			NUMBER ;
 x_ACTIVITY_FK			NUMBER ;
 x_TRX_DATE_FK			NUMBER ;
 x_OPRN_FK			NUMBER ;
 x_RSRC_FK			NUMBER ;
 x_ITEM_FK			NUMBER ;
 x_USAGE_UOM_FK			NUMBER ;
 x_USER_ATTRIBUTE1                          NUMBER;
 x_USER_ATTRIBUTE2                          NUMBER;
 x_USER_ATTRIBUTE3                          NUMBER;
 x_USER_ATTRIBUTE4                          NUMBER;
 x_USER_ATTRIBUTE5                          NUMBER;
 x_USER_ATTRIBUTE6                          NUMBER;
 x_USER_ATTRIBUTE7                          NUMBER;
 x_USER_ATTRIBUTE8                          NUMBER;
 x_USER_ATTRIBUTE9                          NUMBER;
 x_USER_ATTRIBUTE10                         NUMBER;
 x_USER_ATTRIBUTE11                         NUMBER;
 x_USER_ATTRIBUTE12                         NUMBER;
 x_USER_ATTRIBUTE13                         NUMBER;
 x_USER_ATTRIBUTE14                         NUMBER;
 x_USER_ATTRIBUTE15                         NUMBER;
 x_USER_FK1                                 NUMBER;
 x_USER_FK2                                 NUMBER;
 x_USER_FK3                                 NUMBER;
 x_USER_FK4                                 NUMBER;
 x_USER_FK5                                 NUMBER;
 x_USER_MEASURE1                            NUMBER;
 x_USER_MEASURE2                            NUMBER;
 x_USER_MEASURE3                            NUMBER;
 x_USER_MEASURE4                            NUMBER;
 x_USER_MEASURE5                            NUMBER;

--------
  CURSOR c_1 IS
	SELECT
		-- JOB_RSRC_PK (need to add inst.instance_code)
		avg(nvl(vsize(organization_id||wip_entity_id||repetitive_schedule_id||operation_seq_num||resource_id),0)),
		-- ACT_RSRC_COUNT (dummy)
		avg(nvl(vsize(applied_resource_units), 0)),
		-- PLN_RSRC_COUNT (dummy)
		avg(nvl(vsize(applied_resource_units), 0)),
		-- ACT_RSRC_QTY (dummy)
		avg(nvl(vsize(applied_resource_units), 0)),
		-- PLN_RSRC_QTY (dummy)
		avg(nvl(vsize(applied_resource_units), 0)),
		-- ACT_RSRC_VAL_B (dummy)
		avg(nvl(vsize(usage_rate_or_amount), 0)),
		-- PLN_RSRC_VAL_B (dummy)
		avg(nvl(vsize(usage_rate_or_amount), 0)),
		-- ACT_RSRC_VAL_G (dummy)
		avg(nvl(vsize(usage_rate_or_amount), 0)),
		-- PLN_RSRC_VAL_G (dummy)
		avg(nvl(vsize(usage_rate_or_amount), 0)),
		-- ACT_RSRC_USAGE
		avg(nvl(vsize(applied_resource_units), 0)),
		-- PLN_RSRC_USAGE
		avg(nvl(vsize(usage_rate_or_amount), 0)),
		-- STND_RSRC_USAGE
		avg(nvl(vsize(usage_rate_or_amount), 0)),
		-- ACT_RSRC_USAGE_VAL_B
		avg(nvl(vsize(applied_resource_value), 0)),
		-- PLN_RSRC_USAGE_VAL_B
		avg(nvl(vsize(applied_resource_value), 0)),
		-- ACT_RSRC_USAGE_VAL_G
		avg(nvl(vsize(applied_resource_value), 0)),
		-- PLN_RSRC_USAGE_VAL_G
		avg(nvl(vsize(applied_resource_value), 0)),
		-- EXTD_RSRC_COST  (dummy)
		avg(nvl(vsize(applied_resource_units), 0)),
		-- OPERATION_SEQ_NUM
		avg(nvl(vsize(operation_seq_num), 0)),
		-- JOB_NO we.wip_entity_name
		-- DEPARTMENT bd.department_code
		-- ACT_STRT_DATE
		-- ACT_CMPL_DATE
		-- PLN_STRT_DATE
		-- PLN_CMPL_DATE
		-- SOB_CURRENCY_FK
		-- QTY_UOM_FK same as USAGE_UOM_FK
		-- INSTANCE_FK from inst
		-- LOCATOR_FK need to add inst.instance_code
		-- ACTIVITY_FK Need to take add inst.instance_code
		avg(nvl(vsize(activity_id), 0)),
		-- TRX_DATE_FK wmt.transaction_date
		-- OPRN_FK wo.operation_seq_id
		-- RSRC_FK
		avg(nvl(vsize(resource_id), 0)),
		-- ITEM_FK we.primary_item_id, add instance_code
		-- USAGE_UOM_FK
		avg(nvl(vsize(uom_code), 0))
	FROM	WIP_OPERATION_RESOURCES
        WHERE last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_2 IS
	SELECT
		-- OPRN_FK wo.operation_seq_id (Need to add inst.instance_code)
		avg(nvl(vsize(operation_sequence_id||organization_id),0))
	FROM	WIP_OPERATIONS
        WHERE last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_3 IS
	SELECT
		avg(nvl(vsize(wip_entity_name), 0)),
		avg(nvl(vsize(primary_item_id), 0))
	FROM	WIP_ENTITIES
        WHERE last_update_date between
        p_from_date  and  p_to_date;


  CURSOR c_4 IS
	SELECT
		avg(nvl(vsize(department_code), 0))
	FROM	BOM_DEPARTMENTS
        WHERE last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_5 IS
	SELECT
		avg(nvl(vsize(transaction_date), 0))
	FROM	WIP_MOVE_TRANSACTIONS
        WHERE last_update_date between
        p_from_date  and  p_to_date;

  CURSOR c_6 IS
	SELECT
		avg(nvl(vsize(instance_code), 0))
	FROM	EDW_LOCAL_INSTANCE ;
        -- WHERE last_update_date between
       --  p_from_date  and  p_to_date;

  CURSOR c_7 is
	SELECT  avg(nvl(vsize(gsob.currency_code), 0))
        FROM    hr_all_organization_units hou,
                hr_organization_information hoi,
                gl_sets_of_books gsob
        WHERE   hou.organization_id  = hoi.organization_id
          AND ( hoi.org_information_context || '') ='Accounting Information'
          AND hoi.org_information1    = to_char(gsob.set_of_books_id)  ;
        --WHERE hou.last_update_date between
        --p_from_date  and  p_to_date;

  CURSOR c_8 is
	SELECT  avg(nvl(vsize(organization_code), 0))
	FROM mtl_parameters  ;
        -- WHERE last_update_date between
        -- p_from_date  and  p_to_date;

  BEGIN

    OPEN c_1;
      FETCH c_1 INTO
		x_JOB_RSRC_PK ,
		x_ACT_RSRC_COUNT,
		x_PLN_RSRC_COUNT,
		x_ACT_RSRC_QTY,
		x_PLN_RSRC_QTY,
		x_ACT_RSRC_VAL_B,
		x_PLN_RSRC_VAL_B,
		x_ACT_RSRC_VAL_G,
		x_PLN_RSRC_VAL_G,
		x_ACT_RSRC_USAGE,
		x_PLN_RSRC_USAGE,
		x_STND_RSRC_USAGE,
		x_ACT_RSRC_USAGE_VAL_B,
		x_PLN_RSRC_USAGE_VAL_B,
		x_ACT_RSRC_USAGE_VAL_G,
		x_PLN_RSRC_USAGE_VAL_G,
		x_OPERATION_SEQ_NUM,
		x_EXTD_RSRC_COST,
		x_ACTIVITY_FK ,
		x_RSRC_FK,
		x_USAGE_UOM_FK ;
    CLOSE c_1;

    x_ACT_STRT_DATE := x_date ;
    x_ACT_CMPL_DATE := x_date ;
    x_PLN_STRT_DATE := x_date ;
    x_PLN_CMPL_DATE := x_date ;
    -- x_LAST_UPDATE_DATE := x_date;
    x_QTY_UOM_FK := x_USAGE_UOM_FK;

    x_total := 3 +
	    x_total +
            ceil(x_JOB_RSRC_PK + 1) +
		ceil(x_ACT_RSRC_COUNT + 1) +
		ceil(x_PLN_RSRC_COUNT + 1) +
		ceil(x_ACT_RSRC_VAL_B + 1) +
		ceil(x_PLN_RSRC_VAL_B + 1) +
		ceil(x_ACT_RSRC_VAL_G + 1) +
		ceil(x_PLN_RSRC_VAL_G + 1) +
		ceil(x_ACT_RSRC_USAGE + 1) +
		ceil(x_PLN_RSRC_USAGE + 1) +
		ceil(x_STND_RSRC_USAGE + 1) +
		ceil(x_ACT_RSRC_USAGE_VAL_B + 1) +
		ceil(x_PLN_RSRC_USAGE_VAL_B + 1) +
		ceil(x_ACT_RSRC_USAGE_VAL_G + 1) +
		ceil(x_PLN_RSRC_USAGE_VAL_G + 1) +
		ceil(x_OPERATION_SEQ_NUM + 1) +
		ceil(x_ACTIVITY_FK  + 1) +
		ceil(x_RSRC_FK + 1) +
		ceil(x_USAGE_UOM_FK + 1) +
		ceil(x_ACT_STRT_DATE + 1) +
		ceil(x_ACT_CMPL_DATE + 1) +
		ceil(x_PLN_STRT_DATE + 1) +
		ceil(x_PLN_CMPL_DATE + 1) +
		ceil(x_QTY_UOM_FK + 1)  ;

    OPEN c_2;
      FETCH c_2 INTO  x_OPRN_FK;
    CLOSE c_2;
    x_total := x_total + ceil(x_OPRN_FK + 1);

    OPEN c_3;
      FETCH c_3 INTO  x_JOB_NO,
		      x_ITEM_FK ;
    CLOSE c_3;
    x_total := x_total + ceil(x_JOB_NO + 1) + ceil(x_ITEM_FK + 1) ;

    OPEN c_4;
      FETCH c_4 INTO x_DEPARTMENT;
    CLOSE c_4;
    x_total := x_total + ceil(x_DEPARTMENT + 1);

    OPEN c_5;
      FETCH c_5 INTO x_TRX_DATE_FK;
    CLOSE c_5;
    x_total := x_total + ceil(x_TRX_DATE_FK + 1);

    OPEN c_6;
      FETCH c_6 INTO x_INSTANCE_FK;
    CLOSE c_6;
    x_total := x_total + ceil(x_INSTANCE_FK + 1);

    OPEN c_7 ;
      FETCH c_7 INTO x_SOB_CURRENCY_FK;
    CLOSE c_7 ;
    x_total := x_total + ceil(x_SOB_CURRENCY_FK + 1);


    -- Miscellaneous
    x_total := x_total + 4 * ceil(x_INSTANCE_FK + 1);

    p_avg_row_len := x_total;

  END;  -- procedure est_row_len.

END;  -- package body OPI_EDW_JOB_RSRC_F_SZ

/
