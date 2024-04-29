--------------------------------------------------------
--  DDL for Package Body MSC_EXP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_EXP_WF" AS
/*$Header: MSCEXWFB.pls 120.5 2007/12/14 21:41:33 eychen ship $ */

  CURSOR PLANNER_C( p_plan_id in number, p_inventory_item_id in number,
		p_organization_id in number, p_instance_id in number) IS
    SELECT  distinct pl.user_name
    FROM    msc_planners pl,
            msc_system_items sys
    WHERE   sys.plan_id = p_plan_id
    AND     sys.organization_id = p_organization_id
    AND     sys.sr_instance_id = p_instance_id
    AND     sys.inventory_item_id = p_inventory_item_id
    AND     pl.organization_id = sys.organization_id
    AND     pl.sr_instance_id = sys.sr_instance_id
    AND     pl.planner_code = sys.planner_code;

PROCEDURE launch_workflow(errbuf             OUT NOCOPY VARCHAR2,
		          retcode            OUT NOCOPY NUMBER,
                          p_plan_id 	     IN  NUMBER,
                          p_exception_id     IN  NUMBER DEFAULT NULL,
                          p_query_id         IN  NUMBER DEFAULT NULL) IS


  CURSOR EXCEPTION_DETAILS_C1 (p_plan_id in NUMBER,
                              p_exception_id in NUMBER) IS
    SELECT exp.exception_detail_id,
           exp.organization_id,
	   exp.sr_instance_id,
	   exp.inventory_item_id,
           exp.exception_type,
	   mtp.organization_code,
	   mi.item_name,mi.description,
           ml.meaning,
           nvl(decode(exp.exception_type,
                  17, msc_get_name.project(
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  18, msc_get_name.project(
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  msc_get_name.project(
                       sup.project_id,
                       sup.organization_id,
                       sup.plan_id,
                       sup.sr_instance_id)), 'N/A'),
           nvl(decode(exp.exception_type,
                  19, msc_get_name.project(
                       md2.project_id,
                       md2.organization_id,
                       md2.plan_id,
                       md2.sr_instance_id), null), 'N/A'),
           nvl(decode(exp.exception_type,
                  17, msc_get_name.task(
                       exp.number2,
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  18, msc_get_name.task(
                       exp.number2,
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  msc_get_name.task(
                       sup.task_id,
                       sup.project_id,
                       sup.organization_id,
                       sup.plan_id,
                       sup.sr_instance_id)), 'N/A'),
           nvl(decode(exp.exception_type,
                  19, msc_get_name.task(
                       md2.task_id,
                       md2.project_id,
                       md2.organization_id,
                       md2.plan_id,
                       md2.sr_instance_id), null), 'N/A'),
           decode(exp.exception_type, 17, char1, 18, char1,
                       sup.planning_group),
           DECODE(exp.EXCEPTION_TYPE, 2,NULL, 3, NULL, 6, NULL, 7, NULL,
                10, sup.new_schedule_date, 18, NULL, 20, NULL,
                27, md.using_assembly_demand_date,28, NULL,37, NULL,
                24, md.using_assembly_demand_date,
                25, md.using_assembly_demand_date,
                26, md.using_assembly_demand_date,
		49,msc_exp_wf.substitute_supply_date(exp.plan_id,exp.sr_instance_id,exp.supplier_id),
                exp.DATE1),
          DECODE(EXP.EXCEPTION_TYPE,1,EXP.DATE1, 2, EXP.DATE1, 3, EXP.DATE1,
                 6, EXP.DATE1, 7,EXP.DATE1, 17, EXP.DATE1, 18, EXP.DATE1,
                 20, EXP.DATE1, 28, EXP.DATE1, 37, EXP.DATE1,15, md2.using_assembly_demand_date,16, md2.using_assembly_demand_date,49,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.supplier_id),
                 NULL),
           DECODE(exp.EXCEPTION_TYPE, 15, msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.demand_id),16,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.demand_id),exp.date2),
           DECODE(exp.EXCEPTION_TYPE, 9, sup.SCHEDULE_COMPRESS_DAYS,NULL),
	   decode(exp.exception_type,
             37,nvl(exp.number4,0)-nvl(exp.quantity,0),
             28,MSC_EXP_WF.SupplierCapacity(p_plan_id,exp.exception_detail_id),
             49,msc_get_name.demand_quantity(exp.plan_id,exp.sr_instance_id,
                   exp.supplier_id),
             exp.quantity),
	   decode(exp.exception_type, 12, sup.lot_number),
           decode(exp.exception_type, 1, NULL, 2, NULL, 3, NULL,
                   9, NVL(sup.order_number,exp.number1),12, NULL,
                  13, md.order_number,
                  14, NVL(md.order_number,msc_get_name.designator(
                            md.schedule_designator_id)),
                  16, nvl(sup.order_number,sup.transaction_id),
                  17, NULL, 18, NULL , 20, NULL,
                  24, md.order_number, 25, md.order_number,
                  26, msc_get_name.designator(md.schedule_designator_id),
                  27, msc_get_name.designator(md.schedule_designator_id),
                  28, NULL, 37, NULL, 70,md.order_number,
                  sup.order_number),
	   sup_ml.meaning,
           msc_get_name.item_name(
                 decode(exp.exception_type,
                   15, md2.inventory_item_id, 16, md2.inventory_item_id,
                   19, md2.inventory_item_id, 24, md.inventory_item_id,
                   25, md.inventory_item_id,  26, md.inventory_item_id,
                   27, md.inventory_item_id,  49, exp.number1,null),
                   null,null,null),
           msc_get_name.item_desc(
                 decode(exp.exception_type,
                   15, md2.inventory_item_id, 16, md2.inventory_item_id,
                   19, md2.inventory_item_id, 24, md.inventory_item_id,
                   25, md.inventory_item_id,  26, md.inventory_item_id,
                   27, md.inventory_item_id,  49, exp.number1,null),
                   exp.organization_id,p_plan_id,exp.sr_instance_id),
           decode(exp.exception_type,
                    15,md2.order_number, 19,md2.order_number,
                    24,md.order_number,25,md.order_number,
                    26,msc_get_name.designator(md.schedule_designator_id),
                    27,msc_get_name.designator(md.schedule_designator_id),
                    49,msc_get_name.demand_order_number(exp.plan_id,
                       exp.sr_instance_id, exp.supplier_id),
                    NULL) ,
           null,
           decode(exp.exception_type, 49,
               msc_get_name.org_code(exp.number2, exp.sr_instance_id),
               15,msc_get_name.org_code(md2.organization_id, md2.sr_instance_id),
               16,msc_get_name.org_code(md2.organization_id, md2.sr_instance_id),null),
           decode(exp.exception_type, 28, exp.quantity, 37, exp.quantity,
                    49, exp.quantity,
                    15, md.using_requirement_quantity,
                    16, md.using_requirement_quantity,
                    17, md.using_requirement_quantity,
                    18, md.using_requirement_quantity,
                    2, md.using_requirement_quantity,
                    3, msc_get_name.demand_quantity(exp.plan_id,exp.sr_instance_id,md2.demand_id),null),
           decode(exp.exception_type, 12, null, 13, null, 14, null,
                   17, null, 18, null, 24, null, 25, null, 26, null,
                   27, null, 28, null, 37, exp.number2, exp.number1),
           decode(exp.exception_type, 49, msc_exp_wf.demand_order_type(exp.plan_id,exp.sr_instance_id,exp.supplier_id),sup.order_type),
           decode(exp.exception_type, 37, exp.number4,null),
	   exp.number1,
           exp.number2
    FROM   msc_supplies sup,
           msc_full_pegging mfp,
           msc_demands md2,
           msc_demands md,
	   msc_exception_details exp,
           msc_system_items mi,
           msc_trading_partners mtp,
           mfg_lookups ml,
           mfg_lookups sup_ml
    WHERE  exp.exception_type in
             (1,2,3,6,7,8,9,10,12,13,14,15,16,17,18,19,20,24,25,26,27,28,37,49,70)
    AND    exp.plan_id = p_plan_id
    AND    exp.exception_detail_id = p_exception_id
    AND    sup.plan_id (+) = exp.plan_id
    AND    sup.transaction_id (+) = exp.number1
    and    sup.sr_instance_id(+) = exp.sr_instance_id
    AND    mfp.plan_id (+) = exp.plan_id
    AND    mfp.pegging_id (+) = exp.number2
    and    mfp.sr_instance_id(+) = exp.sr_instance_id
    AND    md2.plan_id (+) = mfp.plan_id
    AND    md2.demand_id (+) = mfp.demand_id
    and    md2.sr_instance_id(+) = mfp.sr_instance_id
    AND    md.plan_id (+) = exp.plan_id
    AND    md.demand_id (+) = exp.number1
    and    md.sr_instance_id(+) = exp.sr_instance_id
    AND    mi.inventory_item_id = exp.inventory_item_id
    AND    mi.organization_id = exp.organization_id
    AND    mi.plan_id = exp.plan_id
    AND    mi.sr_instance_id = exp.sr_instance_id
    AND    mtp.sr_tp_id = exp.organization_id
    AND    mtp.sr_instance_id = exp.sr_instance_id
    AND    mtp.partner_type = 3
    and    ml.lookup_type = 'MRP_EXCEPTION_CODE_TYPE'
    and    ml.lookup_code = exp.exception_type
    and    sup_ml.lookup_type(+) = 'MRP_ORDER_TYPE'
    and    sup_ml.lookup_code(+) = sup.order_type;

 CURSOR EXCEPTION_DETAILS_C2 (p_plan_id in NUMBER,
                              p_query_id in NUMBER) IS
    SELECT exp.exception_detail_id,
           exp.organization_id,
	   exp.sr_instance_id,
	   exp.inventory_item_id,
           exp.exception_type,
	   mtp.organization_code,
	   mi.item_name,mi.description,
           ml.meaning,
           nvl(decode(exp.exception_type,
                  17, msc_get_name.project(
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  18, msc_get_name.project(
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  msc_get_name.project(
                       sup.project_id,
                       sup.organization_id,
                       sup.plan_id,
                       sup.sr_instance_id)), 'N/A'),
           nvl(decode(exp.exception_type,
                  19, msc_get_name.project(
                       md2.project_id,
                       md2.organization_id,
                       md2.plan_id,
                       md2.sr_instance_id), null), 'N/A'),
           nvl(decode(exp.exception_type,
                  17, msc_get_name.task(
                       exp.number2,
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  18, msc_get_name.task(
                       exp.number2,
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  msc_get_name.task(
                       sup.task_id,
                       sup.project_id,
                       sup.organization_id,
                       sup.plan_id,
                       sup.sr_instance_id)), 'N/A'),
           nvl(decode(exp.exception_type,
                  19, msc_get_name.task(
                       md2.task_id,
                       md2.project_id,
                       md2.organization_id,
                       md2.plan_id,
                       md2.sr_instance_id), null), 'N/A'),
           decode(exp.exception_type, 17, char1, 18, char1,
                       sup.planning_group),
           DECODE(exp.EXCEPTION_TYPE, 2,NULL, 3, NULL, 6, NULL, 7, NULL,
                10, sup.new_schedule_date, 18, NULL, 20, NULL,
                27, md.using_assembly_demand_date,28, NULL,37, NULL,
                24, md.using_assembly_demand_date,
                25, md.using_assembly_demand_date,
                26, md.using_assembly_demand_date,
		49,msc_exp_wf.substitute_supply_date(exp.plan_id,exp.sr_instance_id,exp.supplier_id),
                exp.DATE1),
          DECODE(EXP.EXCEPTION_TYPE,1,EXP.DATE1, 2, EXP.DATE1, 3, EXP.DATE1,
                 6, EXP.DATE1, 7,EXP.DATE1, 17, EXP.DATE1, 18, EXP.DATE1,
                 20, EXP.DATE1, 28, EXP.DATE1, 37, EXP.DATE1,
                 15, md2.using_assembly_demand_date,16, md2.using_assembly_demand_date,49,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.supplier_id),
                 NULL),
              DECODE(EXP.EXCEPTION_TYPE,15,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.demand_id),16,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.demand_id),exp.date2),
           DECODE(exp.EXCEPTION_TYPE, 9, sup.SCHEDULE_COMPRESS_DAYS,NULL),
	   decode(exp.exception_type,
             37,nvl(exp.number4,0)-nvl(exp.quantity,0),
             28,MSC_EXP_WF.SupplierCapacity(p_plan_id,exp.exception_detail_id),
             49,msc_get_name.demand_quantity(exp.plan_id,exp.sr_instance_id,
                   exp.supplier_id),
             exp.quantity),
	   decode(exp.exception_type, 12, sup.lot_number),
           decode(exp.exception_type, 1, NULL, 2, NULL, 3, NULL,
                   9, NVL(sup.order_number,exp.number1),12, NULL,
                  13, md.order_number,
                  14, NVL(md.order_number,msc_get_name.designator(
                            md.schedule_designator_id)),
                  16, nvl(sup.order_number,sup.transaction_id),
                  17, NULL, 18, NULL , 20, NULL,
                  24, md.order_number, 25, md.order_number,
                  26, msc_get_name.designator(md.schedule_designator_id),
                  27, msc_get_name.designator(md.schedule_designator_id),
                  28, NULL, 37, NULL, 70,md.order_number, sup.order_number),
	   sup_ml.meaning,
           msc_get_name.item_name(
                 decode(exp.exception_type,
                   15, md2.inventory_item_id, 16, md2.inventory_item_id,
                   19, md2.inventory_item_id, 24, md.inventory_item_id,
                   25, md.inventory_item_id,  26, md.inventory_item_id,
                   27, md.inventory_item_id, 49, exp.number1, null),
                   null,null,null),
            msc_get_name.item_desc(
                 decode(exp.exception_type,
                   15, md2.inventory_item_id, 16, md2.inventory_item_id,
                   19, md2.inventory_item_id, 24, md.inventory_item_id,
                   25, md.inventory_item_id,  26, md.inventory_item_id,
                   27, md.inventory_item_id, 49, exp.number1, null),
                   exp.organization_id,p_plan_id,exp.sr_instance_id),
           decode(exp.exception_type,
                    15,md2.order_number, 19,md2.order_number,
                    24,md.order_number,25,md.order_number,
                    26,msc_get_name.designator(md.schedule_designator_id),
                    27,msc_get_name.designator(md.schedule_designator_id),
                    49,msc_get_name.demand_order_number(exp.plan_id,
                       exp.sr_instance_id, exp.supplier_id),
                    NULL) ,
           null,
           decode(exp.exception_type, 49,
               msc_get_name.org_code(exp.number2, exp.sr_instance_id),
               15,msc_get_name.org_code(md2.organization_id, md2.sr_instance_id),
               16,msc_get_name.org_code(md2.organization_id, md2.sr_instance_id),null),
           decode(exp.exception_type, 28, exp.quantity, 37, exp.quantity,
                    49, exp.quantity,
                    15, md.using_requirement_quantity,
                    16, md.using_requirement_quantity,
                    17, md.using_requirement_quantity,
                    18, md.using_requirement_quantity,
                    2, md.using_requirement_quantity,
                    3, msc_get_name.demand_quantity(exp.plan_id,exp.sr_instance_id,md2.demand_id),null),
           decode(exp.exception_type, 12, null, 13, null, 14, null,
                   17, null, 18, null, 24, null, 25, null, 26, null,
                   27, null, 28, null, 37, exp.number2, exp.number1),
           decode(exp.exception_type, 49, msc_exp_wf.demand_order_type(exp.plan_id,exp.sr_instance_id,exp.supplier_id),sup.order_type),
           decode(exp.exception_type, 37, exp.number4,null),
	   exp.number1,
           exp.number2
    FROM   msc_supplies sup,
           msc_full_pegging mfp,
           msc_demands md2,
           msc_demands md,
	   msc_exception_details exp,
           msc_system_items mi,
           msc_trading_partners mtp,
           mfg_lookups ml,
           mfg_lookups sup_ml
    WHERE  exp.exception_type in
             (1,2,3,6,7,8,9,10,12,13,14,15,16,17,18,19,20,24,25,26,27,28,37,49,70)
    AND    exp.plan_id = p_plan_id
    AND    exp.exception_detail_id in (SELECT number1
                                      FROM   msc_form_query
                                      WHERE  query_id = p_query_id)
    AND    sup.plan_id (+) = exp.plan_id
    AND    sup.transaction_id (+) = exp.number1
    and    sup.sr_instance_id(+) = exp.sr_instance_id
    AND    mfp.plan_id (+) = exp.plan_id
    AND    mfp.pegging_id (+) = exp.number2
    and    mfp.sr_instance_id(+) = exp.sr_instance_id
    AND    md2.plan_id (+) = mfp.plan_id
    AND    md2.demand_id (+) = mfp.demand_id
    and    md2.sr_instance_id(+) = mfp.sr_instance_id
    AND    md.plan_id (+) = exp.plan_id
    AND    md.demand_id (+) = exp.number1
    and    md.sr_instance_id(+) = exp.sr_instance_id
    AND    mi.inventory_item_id = exp.inventory_item_id
    AND    mi.organization_id = exp.organization_id
    AND    mi.plan_id = exp.plan_id
    AND    mi.sr_instance_id = exp.sr_instance_id
    AND    mtp.sr_tp_id = exp.organization_id
    AND    mtp.sr_instance_id = exp.sr_instance_id
    AND    mtp.partner_type = 3
    and    ml.lookup_type = 'MRP_EXCEPTION_CODE_TYPE'
    and    ml.lookup_code = exp.exception_type
    and    sup_ml.lookup_type(+) = 'MRP_ORDER_TYPE'
    and    sup_ml.lookup_code(+) = sup.order_type;


 CURSOR EXCEPTION_DETAILS_C3 (p_plan_id in NUMBER) IS
    SELECT exp.exception_detail_id,
           exp.organization_id,
	   exp.sr_instance_id,
	   exp.inventory_item_id,
           exp.exception_type,
	   mtp.organization_code,
	   mi.item_name,mi.description,
           ml.meaning,
           nvl(decode(exp.exception_type,
                  17, msc_get_name.project(
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  18, msc_get_name.project(
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  msc_get_name.project(
                       sup.project_id,
                       sup.organization_id,
                       sup.plan_id,
                       sup.sr_instance_id)), 'N/A'),
           nvl(decode(exp.exception_type,
                  19, msc_get_name.project(
                       md2.project_id,
                       md2.organization_id,
                       md2.plan_id,
                       md2.sr_instance_id), null), 'N/A'),
           nvl(decode(exp.exception_type,
                  17, msc_get_name.task(
                       exp.number2,
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  18, msc_get_name.task(
                       exp.number2,
                       exp.number1,
                       exp.organization_id,
                       exp.plan_id,
                       exp.sr_instance_id),
                  msc_get_name.task(
                       sup.task_id,
                       sup.project_id,
                       sup.organization_id,
                       sup.plan_id,
                       sup.sr_instance_id)), 'N/A'),
           nvl(decode(exp.exception_type,
                  19, msc_get_name.task(
                       md2.task_id,
                       md2.project_id,
                       md2.organization_id,
                       md2.plan_id,
                       md2.sr_instance_id), null), 'N/A'),
           decode(exp.exception_type, 17, char1, 18, char1,
                       sup.planning_group),
           DECODE(exp.EXCEPTION_TYPE, 2,NULL, 3, NULL, 6, NULL, 7, NULL,
                10, sup.new_schedule_date, 18, NULL, 20, NULL,
                27, md.using_assembly_demand_date,28, NULL,37, NULL,
                24, md.using_assembly_demand_date,
                25, md.using_assembly_demand_date,
                26, md.using_assembly_demand_date,
		49,msc_exp_wf.substitute_supply_date(exp.plan_id,exp.sr_instance_id,exp.supplier_id),
                exp.DATE1),
          DECODE(EXP.EXCEPTION_TYPE,1,EXP.DATE1, 2, EXP.DATE1, 3, EXP.DATE1,
                 6, EXP.DATE1, 7,EXP.DATE1, 17, EXP.DATE1, 18, EXP.DATE1,
                 20, EXP.DATE1, 28, EXP.DATE1, 37, EXP.DATE1,
                 15, md2.using_assembly_demand_date,16, md2.using_assembly_demand_date,49,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.supplier_id),
                 NULL),
              DECODE(EXP.EXCEPTION_TYPE,15,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.demand_id),16,msc_exp_wf.demand_order_date(exp.plan_id,exp.sr_instance_id,exp.demand_id),exp.date2),
           DECODE(exp.EXCEPTION_TYPE, 9, sup.SCHEDULE_COMPRESS_DAYS,NULL),
	   decode(exp.exception_type,
             37,nvl(exp.number4,0)-nvl(exp.quantity,0),
             28,MSC_EXP_WF.SupplierCapacity(p_plan_id,exp.exception_detail_id),
             49,msc_get_name.demand_quantity(exp.plan_id,exp.sr_instance_id,
                   exp.supplier_id),
             exp.quantity),
	   decode(exp.exception_type, 12, sup.lot_number),
           decode(exp.exception_type, 1, NULL, 2, NULL, 3, NULL,
                   9, NVL(sup.order_number,exp.number1),12, NULL,
                  13, md.order_number,
                  14, NVL(md.order_number,msc_get_name.designator(
                            md.schedule_designator_id)),
                  16, nvl(sup.order_number,sup.transaction_id),
                  17, NULL, 18, NULL , 20, NULL,
                  24, md.order_number, 25, md.order_number,
                  26, msc_get_name.designator(md.schedule_designator_id),
                  27, msc_get_name.designator(md.schedule_designator_id),
                  28, NULL, 37, NULL, 70,md.order_number, sup.order_number),
	   sup_ml.meaning,
           msc_get_name.item_name(
                 decode(exp.exception_type,
                   15, md2.inventory_item_id, 16, md2.inventory_item_id,
                   19, md2.inventory_item_id, 24, md.inventory_item_id,
                   25, md.inventory_item_id,  26, md.inventory_item_id,
                   27, md.inventory_item_id,  49, exp.number1,null),
                   null,null,null),
           msc_get_name.item_desc(
                 decode(exp.exception_type,
                   15, md2.inventory_item_id, 16, md2.inventory_item_id,
                   19, md2.inventory_item_id, 24, md.inventory_item_id,
                   25, md.inventory_item_id,  26, md.inventory_item_id,
                   27, md.inventory_item_id,  49, exp.number1,null),
                   exp.organization_id,p_plan_id,exp.sr_instance_id),
           decode(exp.exception_type,
                    15,md2.order_number, 19,md2.order_number,
                    24,md.order_number,25,md.order_number,
                    26,msc_get_name.designator(md.schedule_designator_id),
                    27,msc_get_name.designator(md.schedule_designator_id),
                    49,msc_get_name.demand_order_number(exp.plan_id,
                       exp.sr_instance_id, exp.supplier_id),
                    NULL) ,
           null,
           decode(exp.exception_type, 49,
               msc_get_name.org_code(exp.number2, exp.sr_instance_id),
               15,msc_get_name.org_code(md2.organization_id, md2.sr_instance_id),
               16,msc_get_name.org_code(md2.organization_id, md2.sr_instance_id),null),
           decode(exp.exception_type, 28, exp.quantity, 37, exp.quantity,
                    49, exp.quantity,
                    15, md.using_requirement_quantity,
                    16, md.using_requirement_quantity,
                    17, md.using_requirement_quantity,
                    18, md.using_requirement_quantity,
                    2, md.using_requirement_quantity,
                    3, msc_get_name.demand_quantity(exp.plan_id,exp.sr_instance_id,md2.demand_id),null),
           decode(exp.exception_type, 12, null, 13, null, 14, null,
                   17, null, 18, null, 24, null, 25, null, 26, null,
                   27, null, 28, null, 37, exp.number2, exp.number1),
           decode(exp.exception_type, 49, msc_exp_wf.demand_order_type(exp.plan_id,exp.sr_instance_id,exp.supplier_id),sup.order_type),
           decode(exp.exception_type, 37, exp.number4,null),
	   exp.number1,
           exp.number2
    FROM   msc_supplies sup,
           msc_full_pegging mfp,
           msc_demands md2,
           msc_demands md,
	   msc_exception_details exp,
           msc_system_items mi,
           msc_trading_partners mtp,
           mfg_lookups ml,
           mfg_lookups sup_ml
    WHERE  exp.exception_type in
             (1,2,3,6,7,8,9,10,12,13,14,15,16,17,18,19,20,24,25,26,27,28,37,49,70)
    AND    exp.plan_id = p_plan_id
    AND    sup.plan_id (+) = exp.plan_id
    AND    sup.transaction_id (+) = exp.number1
    and    sup.sr_instance_id(+) = exp.sr_instance_id
    AND    mfp.plan_id (+) = exp.plan_id
    AND    mfp.pegging_id (+) = exp.number2
    and    mfp.sr_instance_id(+) = exp.sr_instance_id
    AND    md2.plan_id (+) = mfp.plan_id
    AND    md2.demand_id (+) = mfp.demand_id
    and    md2.sr_instance_id(+) = mfp.sr_instance_id
    AND    md.plan_id (+) = exp.plan_id
    AND    md.demand_id (+) = exp.number1
    and    md.sr_instance_id(+) = exp.sr_instance_id
    AND    mi.inventory_item_id = exp.inventory_item_id
    AND    mi.organization_id = exp.organization_id
    AND    mi.plan_id = exp.plan_id
    AND    mi.sr_instance_id = exp.sr_instance_id
    AND    mtp.sr_tp_id = exp.organization_id
    AND    mtp.sr_instance_id = exp.sr_instance_id
    AND    mtp.partner_type = 3
    and    ml.lookup_type = 'MRP_EXCEPTION_CODE_TYPE'
    and    ml.lookup_code = exp.exception_type
    and    sup_ml.lookup_type(+) = 'MRP_ORDER_TYPE'
    and    sup_ml.lookup_code(+) = sup.order_type;

  CURSOR SUPPLIER_C(p_exception_id in number,
                    p_plan_id      in number) IS
    SELECT vend.partner_id,
	   vend.partner_name
    FROM   msc_trading_partners vend,
	   msc_exception_details exp,
           msc_supplies ms
    WHERE  vend.partner_id = nvl(exp.supplier_id, ms.supplier_id)
    AND    vend.partner_type = 1
    AND    ms.plan_id (+) = exp.plan_id
    AND    ms.transaction_id (+) = exp.number1
    AND    exp.exception_detail_id = p_exception_id
    AND    exp.plan_id = p_plan_id;

  CURSOR SUPPLIER_SITE_C(p_exception_id in number,
                         p_plan_id      in number) IS
    SELECT vend.partner_id,
	   vend.partner_name,
	   site.partner_site_id,
	   site.tp_site_code
    FROM   msc_trading_partners vend,
	   msc_trading_partner_sites site,
	   msc_exception_details exp,
           msc_supplies ms
    WHERE  site.partner_site_id = nvl(exp.supplier_site_id,ms.supplier_site_id)
    AND    vend.partner_id = nvl(exp.supplier_id, ms.supplier_id)
    AND    vend.partner_type = 1
    AND    ms.plan_id (+) = exp.plan_id
    AND    ms.transaction_id (+) = exp.number1
    AND    exp.exception_detail_id = p_exception_id
    AND    exp.plan_id = p_plan_id;

  CURSOR CUSTOMER_C(p_exception_id in number,
                    p_plan_id      in number) IS
    SELECT vend.partner_id,
	   vend.partner_name
    FROM   msc_trading_partners vend,
	   msc_demands rec,
	   msc_exception_details exp
    WHERE  vend.sr_tp_id = rec.customer_id
    AND    vend.sr_instance_id = rec.sr_instance_id
    AND    vend.partner_type = 2
    AND    rec.demand_id = exp.number1
    AND    rec.plan_id = exp.plan_id
    AND    exp.exception_detail_id = p_exception_id
    AND    exp.plan_id = p_plan_id;

  CURSOR DB_LINK_C(sr_instance_id in number) IS
    SELECT  decode(M2A_dblink,null,' ','@'||M2A_dblink),
            decode(A2M_dblink,null,' ','@'||A2M_dblink)
    FROM    msc_apps_instances
    WHERE   instance_id = sr_instance_id;

  l_cursor			varchar2(30);

  l_exception_id 		number;
  l_organization_id		number;
  l_inventory_item_id		number;
  l_exception_type		number;
  l_organization_code		varchar2(7);
  l_item_segments		varchar2(40);
  l_item_description            varchar2(240);
  l_exception_type_text		varchar2(1000);
  l_project_number		varchar2(1000);
  l_to_project_number		varchar2(1000);
  l_task_number			varchar2(1000);
  l_to_task_number		varchar2(1000);
  l_planning_group		varchar2(80);
  l_due_date			date;
  l_from_date			date;
  l_to_date			date;
  l_days_compressed		number;
  l_quantity			varchar2(40);
  l_lot_number			varchar2(80);
  l_order_number		varchar2(1000);
  l_order_type_code		number		:= to_number(NULL);
  l_supply_type			varchar2(80);
  l_end_item_segments		varchar2(40);
  l_end_item_description        varchar2(240);
  l_end_order_number		varchar2(1000);
  l_department_line_code	varchar2(10);
  l_resource_code		varchar2(30);
  l_utilization_rate		number;
  l_vendor_id			number		:= to_number(NULL);
  l_vendor_name			varchar2(80)	:= 'N/A';
  l_vendor_site_id		number		:= to_number(NULL);
  l_vendor_site_code		varchar2(15)	:= 'N/A';
  l_customer_id			number		:= to_number(NULL);
  l_customer_name		varchar2(80)	:= 'N/A';
  l_workflow_process		varchar2(40);
  l_plan_type			number;
  l_org_selection		number;
  l_workbench_function		varchar2(30);
  l_counter			number := 1;
  l_planner_code 		varchar2(20);
  l_sr_instance_id		number;
  l_db_link			varchar2(40);
  l_a2m_db_link                 varchar2(40);
  l_transaction_id		number;
  l_prev_excep_id	        number := -1;
  junk                          number;
  sql_stmt                      varchar2(1000);
  var_debug                     varchar2(2);
  l_sr_vers                     number;
  l_qty_related_values          number;
  l_sup_project_id		number;--stores number1
  l_sup_task_id			number;--stores number2

BEGIN
  -- Cancel notifications from previous plan run and force completion of
  -- workflows.
  msc_util.msc_debug('****** Start of Program MSC_EXP_WF******');
  msc_util.msc_debug('PlanId: ' || to_char(p_plan_id));
  msc_util.msc_debug('ExceptionId: ' || to_char(p_exception_id));

  DeleteActivities(p_plan_id);
  msc_util.msc_debug('deleted entries');

  l_cursor := 'EXCEPTION_DETAILS_C';
  msc_util.msc_debug('before the exception open');
if p_exception_id is null and p_query_id is null then

  OPEN EXCEPTION_DETAILS_C3(p_plan_id);

elsif p_exception_id is not null then
  OPEN EXCEPTION_DETAILS_C1(p_plan_id,p_exception_id);

elsif p_query_id is not null then
  OPEN EXCEPTION_DETAILS_C2(p_plan_id,p_query_id);
end if;

  LOOP
    msc_util.msc_debug('before the exception fetch');
if p_exception_id is null and p_query_id is null then
    FETCH EXCEPTION_DETAILS_C3 INTO
      l_exception_id,
      l_organization_id,
      l_sr_instance_id,
      l_inventory_item_id,
      l_exception_type,
      l_organization_code,
      l_item_segments,
      l_item_description,
      l_exception_type_text,
      l_project_number,
      l_to_project_number,
      l_task_number,
      l_to_task_number,
      l_planning_group,
      l_due_date,
      l_from_date,
      l_to_date,
      l_days_compressed,
      l_quantity,
      l_lot_number,
      l_order_number,
      l_supply_type,
      l_end_item_segments,
      l_end_item_description,
      l_end_order_number,
      l_department_line_code,
      l_resource_code,
      l_utilization_rate,
      l_transaction_id,
      l_order_type_code,
      l_qty_related_values,
      l_sup_project_id	,
      l_sup_task_id	;
    EXIT WHEN EXCEPTION_DETAILS_C3%NOTFOUND;

elsif p_exception_id is not null then

    FETCH EXCEPTION_DETAILS_C1 INTO
      l_exception_id,
      l_organization_id,
      l_sr_instance_id,
      l_inventory_item_id,
      l_exception_type,
      l_organization_code,
      l_item_segments,
      l_item_description,
      l_exception_type_text,
      l_project_number,
      l_to_project_number,
      l_task_number,
      l_to_task_number,
      l_planning_group,
      l_due_date,
      l_from_date,
      l_to_date,
      l_days_compressed,
      l_quantity,
      l_lot_number,
      l_order_number,
      l_supply_type,
      l_end_item_segments,
      l_end_item_description,
      l_end_order_number,
      l_department_line_code,
      l_resource_code,
      l_utilization_rate,
      l_transaction_id,
      l_order_type_code,
      l_qty_related_values,
      l_sup_project_id	,
      l_sup_task_id	;
    EXIT WHEN EXCEPTION_DETAILS_C1%NOTFOUND;

elsif p_query_id is not null then

    FETCH EXCEPTION_DETAILS_C2 INTO
      l_exception_id,
      l_organization_id,
      l_sr_instance_id,
      l_inventory_item_id,
      l_exception_type,
      l_organization_code,
      l_item_segments,
      l_item_description,
      l_exception_type_text,
      l_project_number,
      l_to_project_number,
      l_task_number,
      l_to_task_number,
      l_planning_group,
      l_due_date,
      l_from_date,
      l_to_date,
      l_days_compressed,
      l_quantity,
      l_lot_number,
      l_order_number,
      l_supply_type,
      l_end_item_segments,
      l_end_item_description,
      l_end_order_number,
      l_department_line_code,
      l_resource_code,
      l_utilization_rate,
      l_transaction_id,
      l_order_type_code,
      l_qty_related_values,
      l_sup_project_id	,
      l_sup_task_id	;
    EXIT WHEN EXCEPTION_DETAILS_C2%NOTFOUND;
end if;

     -- Determine the database link
     OPEN DB_LINK_C(l_sr_instance_id);
     FETCH DB_LINK_C INTO l_db_link, l_a2m_db_link;
     CLOSE DB_LINK_C;

     l_vendor_id := NULL;
     l_vendor_name := NULL;
     l_vendor_site_id := NULL;
     l_vendor_site_code := NULL;
     l_customer_id := NULL;
     l_customer_name := NULL;

      if (l_exception_type in (1, 2, 3, 12, 14, 16, 20, 26, 27)) then
         l_workflow_process := 'EXCEPTION_PROCESS1';
      elsif (l_exception_type in (28, 37)) then
         msc_util.msc_debug('Within the 37 logic');
         l_workflow_process := 'EXCEPTION_PROCESS5';
         l_cursor := 'SUPPLIER_SITE_C';
         OPEN SUPPLIER_SITE_C(l_exception_id,p_plan_id);
         LOOP
           FETCH SUPPLIER_SITE_C INTO
	        l_vendor_id,
	        l_vendor_name,
  	        l_vendor_site_id,
	        l_vendor_site_code;
	   EXIT WHEN SUPPLIER_SITE_C%NOTFOUND;
	 END LOOP;
	 CLOSE SUPPLIER_SITE_C;

      elsif (l_exception_type in (6, 7, 8, 9, 10)) then
         l_workflow_process := 'EXCEPTION_PROCESS2';

         -- Purchase Order
         if (l_order_type_code = 1) then
           l_cursor := 'SUPPLIER_SITE_C';
           OPEN SUPPLIER_SITE_C(l_exception_id,p_plan_id);
           LOOP
             FETCH SUPPLIER_SITE_C INTO
	          l_vendor_id,
	          l_vendor_name,
	          l_vendor_site_id,
	          l_vendor_site_code;
	     EXIT WHEN SUPPLIER_SITE_C%NOTFOUND;
	   END LOOP;
	   CLOSE SUPPLIER_SITE_C;

         -- Purchase Requisition
         elsif (l_order_type_code = 2) then
           l_cursor := 'SUPPLIER_C';
	   OPEN SUPPLIER_C(l_exception_id,p_plan_id);
           LOOP
	     FETCH SUPPLIER_C INTO
	       l_vendor_id,
 	       l_vendor_name;
	     EXIT WHEN SUPPLIER_C%NOTFOUND;
           END LOOP;
	   CLOSE SUPPLIER_C;
         end if;

      elsif (l_exception_type in (13, 15, 24, 25, 49, 70)) then
         l_workflow_process := 'EXCEPTION_PROCESS3';
         l_cursor := 'CUSTOMER_C';
         OPEN CUSTOMER_C(l_exception_id,p_plan_id);
         LOOP
           FETCH CUSTOMER_C INTO
             l_customer_id,
	     l_customer_name;
	   EXIT WHEN CUSTOMER_C%NOTFOUND;
         END LOOP;
         CLOSE CUSTOMER_C;

      elsif (l_exception_type in (17, 18, 19)) then
         l_workflow_process := 'EXCEPTION_PROCESS4';
      end if;

      l_workbench_function := 'MSCFNSCW-SCP';

      l_cursor := 'StartWFProcess';

      StartWFProcess( 'MSCEXPWF',
                    to_char(p_plan_id) || '-' ||to_char(l_exception_id),
                    l_exception_id,
		    l_organization_id,
		    l_sr_instance_id,
		    l_inventory_item_id,
		    l_exception_type,
		    l_organization_code,
		    l_item_segments,
                    l_item_description,
		    l_exception_type_text,
	            l_project_number,
		    l_to_project_number,
		    l_task_number,
		    l_to_task_number,
		    l_planning_group,
		    l_due_date,
		    l_from_date,
		    l_to_date,
		    l_days_compressed,
		    l_quantity,
		    l_lot_number,
		    l_order_number,
		    l_order_type_code,
		    l_supply_type,
		    l_end_item_segments,
                    l_end_item_description,
	 	    l_end_order_number,
		    l_department_line_code,
		    l_resource_code,
		    l_utilization_rate,
		    l_vendor_id,
		    l_vendor_name,
		    l_vendor_site_id,
		    l_vendor_site_code,
		    l_customer_id,
		    l_customer_name,
                    l_workbench_function,
		    l_workflow_process,
 		    l_planner_code,
		    p_plan_id,
		    l_db_link,
                    l_a2m_db_link,
                    l_transaction_id,
                    l_qty_related_values,
		    l_sup_project_id,
		    l_sup_task_id	);

      msc_util.msc_debug('After the start process');

      if l_counter >1000 then
         commit;
         msc_util.msc_debug('commit now');
         l_counter :=1;
      else
         l_counter := l_counter+1;
      end if;

  END LOOP;
  msc_util.msc_debug('After loop');

if p_exception_id is null and p_query_id is null then
  CLOSE EXCEPTION_DETAILS_C3;
elsif p_exception_id is not null then
  CLOSE EXCEPTION_DETAILS_C1;
elsif p_query_id is not null then
  CLOSE EXCEPTION_DETAILS_C2;
end if;

  msc_util.msc_debug('Completed:'|| to_char(l_counter -1));
  retcode := 0;

  l_cursor := 'End of launch_workflow';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;

    WHEN OTHERS THEN
        msc_util.msc_debug('Error in launch wkflow:'|| sqlerrm);
	errbuf := 'Error in msc_exp_wf.launch_workflow function' ||
				' Cursor: ' || l_cursor || ' Exception ID: '
                                || l_exception_id ||
				' SQL error: ' || sqlerrm;
	retcode := 2;

END launch_workflow;

-- PROCEDURE
--   StartWFProcess
--
-- DESCRIPTION
--   Initiate workflow for exception message handling
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - Name of workflow process to run
--

PROCEDURE StartWFProcess ( item_type            in varchar2 default null,
		           item_key	        in varchar2,
                           l_exception_id       in number,
			   organization_id      in number,
			   instance_id          in number,
			   inventory_item_id    in number,
			   exception_type	in number,
			   organization_code    in varchar2,
			   item_segments        in varchar2,
                           item_description     in varchar2,
			   exception_type_text  in varchar2,
			   project_number       in varchar2,
			   to_project_number    in varchar2,
			   task_number	        in varchar2,
			   to_task_number       in varchar2,
			   planning_group       in varchar2,
		  	   due_date		in date,
			   from_date	        in date,
			   p_to_date	        in date,
			   days_compressed      in number,
			   quantity	        in varchar2,
			   lot_number	        in varchar2,
			   order_number	        in varchar2,
			   order_type_code	in number,
			   supply_type	        in varchar2,
			   end_item_segments	in varchar2,
                           end_item_description in varchar2,
			   end_order_number	in varchar2,
			   department_line_code in varchar2,
			   resource_code        in varchar2,
			   utilization_rate     in number,
			   supplier_id		in number,
			   supplier_name	in varchar2,
			   supplier_site_id     in number,
			   supplier_site_code   in varchar2,
			   customer_id		in number,
			   customer_name	in varchar2,
                           workbench_function   in varchar2,
			   workflow_process     in varchar2 default null,
			   planner_code	        in varchar2,
			   p_plan_id            in number,
			   db_link		in varchar2,
                           l_a2m_db_link        in varchar2,
                           transaction_id       in number,
                           qty_related_values   in number,
			   sup_project_id	in number,
			   sup_task_id	        in number) is
  compile_designator varchar(15) := null;
  pre_prsng_lead_time number := 0;
  prsng_lead_time number := 0;
  post_prsng_lead_time number := 0;
  l_url varchar2(200);
  lv_organization_id    NUMBER;
  lv_inventory_item_id  NUMBER;
  lv_exception_type     NUMBER;
  lv_cap_req NUMBER := 0;-- required capacity
  lv_req_quantity NUMBER := 0;--required quantity
  lv_ava_quantity NUMBER := 0;--available quantity
  lv_ava_quantity_temp NUMBER := 0;--temp variable
  lv_pab NUMBER := 0;--Projected available balance

CURSOR LEADTIME_C IS
  select nvl(PREPROCESSING_LEAD_TIME,0),nvl(FIXED_LEAD_TIME,0),nvl(POSTPROCESSING_LEAD_TIME,0)
  from msc_system_items msi
  where msi.sr_instance_id = instance_id
  and msi.plan_id = p_plan_id
  and msi.organization_id = lv_organization_id
  and msi.inventory_item_id = lv_inventory_item_id;

CURSOR SO_C is
  select md.schedule_ship_date old_ship_date,
         md.schedule_arrival_date old_arrival_date,
         md.dmd_satisfied_date new_ship_date,
         md.planned_arrival_date new_arrival_date,
         md.request_date request_arrival_date,
         md.request_ship_date,
         md.promise_date promise_arrival_date,
         md.promise_ship_date,
         md.shipping_method_code new_ship_method,
         md.orig_shipping_method_code old_ship_method,
         md.orig_intransit_lead_time old_lead_time,
         md.intransit_lead_time new_lead_time,
         msc_get_name.customer_site(md.customer_site_id) customer_site,
         msc_get_name.org_code(md.original_org_id,
                               md.original_inst_id) org_code,
         msc_get_name.org_code(md.organization_id,md.sr_instance_id) to_org,
         md.demand_id,
         md.latest_acceptable_date,
         msc_get_name.lookup_meaning('SYS_YES_NO',md.atp_override_flag) atp_override_flag
     from msc_demands md,
          msc_exception_details med
    where med.plan_id = md.plan_id
      and med.number1 = md.demand_id
      and med.sr_instance_id = md.sr_instance_id
      and med.plan_id = p_plan_id
      and med.exception_detail_id = l_exception_id;

    so_rec so_c%ROWTYPE;
BEGIN

  lv_organization_id := organization_id;
  lv_inventory_item_id :=inventory_item_id;
  lv_exception_type := exception_type;
  msc_util.msc_debug('Inside the start process');
  -- Note that with MSC the unique key is plan_id || exception_id
  --wf_engine.threshold := -1;
  wf_engine.CreateProcess( itemtype => item_type,
			   itemkey  => item_key,
   			   process  => workflow_process);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'EXCEPTION_ID',
			       avalue   => l_exception_id);

  if l_exception_id in (37, 28) then
    wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'URL1',
                             avalue   => l_url);
  end if;

  select compile_designator
  into compile_designator
  from msc_plans
  where plan_id = p_plan_id;


if (lv_exception_type = 9) then
OPEN LEADTIME_C ;
FETCH LEADTIME_C into pre_prsng_lead_time,prsng_lead_time,post_prsng_lead_time;
CLOSE LEADTIME_C;

end if;


--included to find Required/available quantity/PAB.

if(lv_exception_type = 2 or lv_exception_type = 3 or lv_exception_type=20 ) then

	--Available quantity
    select
	nvl(sum(new_order_quantity),0)
    into
	lv_ava_quantity
    from
	msc_supplies
    where
	organization_id=lv_organization_id
	and inventory_item_id=lv_inventory_item_id
	and plan_id=p_plan_id
	and sr_instance_id=instance_id
	and nvl(disposition_status_type,-99)<>2
	and new_order_quantity > 0
	and to_date(new_schedule_date,'DD-MM-YY') <= to_date(to_char(from_date),'DD-MM-YY');



    select
	nvl(sum(new_order_quantity*(-1)),0)
    into
	lv_ava_quantity_temp
    from
	msc_supplies
    where
	organization_id=lv_organization_id
	and inventory_item_id=lv_inventory_item_id
	and plan_id=p_plan_id
	and sr_instance_id=instance_id
	and nvl(disposition_status_type,-99)<>2
	and new_order_quantity < 0
	and to_date(new_schedule_date,'DD-MM-YY') <= to_date(to_char(from_date),'DD-MM-YY');


	--Required quantity
    select
	nvl(sum(using_requirement_quantity),0)
    into
	lv_req_quantity
    from
	msc_demands
    where
	organization_id=lv_organization_id
	and inventory_item_id=lv_inventory_item_id
	and plan_id=p_plan_id
	and sr_instance_id=instance_id
	and to_date(using_assembly_demand_date,'DD-MM-YY') <= to_date(to_char(from_date),'DD-MM-YY');

    lv_req_quantity:=lv_req_quantity+lv_ava_quantity_temp;

    lv_pab:=lv_ava_quantity-lv_req_quantity;


end if;


--included to find Required/available quantity/PAB for Projects
if(lv_exception_type = 17 or lv_exception_type = 18) then

	--Available quantity
    select
	nvl(sum(new_order_quantity),0)
    into
	lv_ava_quantity
    from
	msc_supplies
    where
	organization_id=lv_organization_id
	and inventory_item_id=lv_inventory_item_id
	and plan_id=p_plan_id
	and sr_instance_id=instance_id
	and project_id=sup_project_id
	and nvl(task_id,-99)=nvl(sup_task_id,-99)
	and nvl(disposition_status_type,-99)<>2
	and new_order_quantity > 0
	and to_date(new_schedule_date,'DD-MM-YY') <= to_date(to_char(from_date),'DD-MM-YY');


    select
	nvl(sum(new_order_quantity*(-1)),0)
    into
	lv_ava_quantity_temp
    from
	msc_supplies
    where
	organization_id=lv_organization_id
	and inventory_item_id=lv_inventory_item_id
	and plan_id=p_plan_id
	and sr_instance_id=instance_id
	and project_id=sup_project_id
	and nvl(task_id,-99)=nvl(sup_task_id,-99)
	and nvl(disposition_status_type,-99)<>2
	and new_order_quantity < 0
	and to_date(new_schedule_date,'DD-MM-YY') <= to_date(to_char(from_date),'DD-MM-YY');

	--Required quantity
    select
	nvl(sum(using_requirement_quantity),0)
    into
	lv_req_quantity
    from
	msc_demands
    where
	organization_id=lv_organization_id
	and inventory_item_id=lv_inventory_item_id
	and plan_id=p_plan_id
	and sr_instance_id=instance_id
	and project_id=sup_project_id
	and nvl(task_id,-99)=nvl(sup_task_id,-99)
	and to_date(using_assembly_demand_date,'DD-MM-YY') <= to_date(to_char(from_date),'DD-MM-YY');

	lv_req_quantity:=lv_req_quantity+lv_ava_quantity_temp;


end if;


  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
  			     aname    => 'PLAN_NAME',
 			     avalue   => compile_designator);

 wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'PRE_PRSNG_LEAD_TIME',
                             avalue   => pre_prsng_lead_time);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'PRSNG_LEAD_TIME',
                             avalue   => prsng_lead_time);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'POST_PRSNG_LEAD_TIME',
                             avalue   => post_prsng_lead_time);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'ORGANIZATION_ID',
			       avalue   => organization_id);
  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'INSTANCE_ID',
			       avalue   => instance_id);
  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'INVENTORY_ITEM_ID',
			       avalue   => inventory_item_id);
  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'EXCEPTION_TYPE_ID',
			       avalue   => exception_type);
  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'TRANSACTION_ID',
			       avalue   => transaction_id);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORGANIZATION_CODE',
			     avalue   => organization_code);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ITEM_DISPLAY_NAME',
			     avalue   => item_segments);
  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'ITEM_DESCRIPTION',
                             avalue   => item_description);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'EXCEPTION_DESCRIPTION',
			     avalue   => exception_type_text);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'PROJECT_NUMBER',
		             avalue   => project_number);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_PROJECT_NUMBER',
			     avalue   => to_project_number);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TASK_NUMBER',
			     avalue   => task_number);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_TASK_NUMBER',
			     avalue   => to_task_number);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'PLANNING_GROUP',
			     avalue   => planning_group);
  wf_engine.SetItemAttrNumber( itemtype => item_type,
                               itemkey  => item_key,
                               aname    => 'QTY_RELATED_VALUES',
                               avalue   => qty_related_values);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DUE_DATE',
			     avalue   => due_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'FROM_DATE',
			     avalue   => from_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_DATE',
			     avalue   => p_to_date);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'DAYS_COMPRESSED',
			       avalue   => days_compressed);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'QUANTITY',
			     avalue   => quantity);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'LOT_NUMBER',
			     avalue   => lot_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORDER_NUMBER',
			     avalue   => order_number);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'ORDER_TYPE_CODE',
			       avalue   => order_type_code);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLY_TYPE',
			     avalue   => supply_type);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ITEM_DISPLAY_NAME',
			     avalue   => end_item_segments);

  wf_engine.SetItemAttrText( itemtype => item_type,
                             itemkey  => item_key,
                             aname    => 'END_ITEM_DESCRIPTION',
                             avalue   => end_item_description);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ORDER_NUMBER',
			     avalue   => end_order_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DEPARTMENT_LINE_CODE',
			     avalue   => department_line_code);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'RESOURCE_CODE',
			     avalue   => resource_code);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'UTILIZATION_RATE',
			       avalue   => utilization_rate);

--Calculation of Required Capacity

	if(quantity >0) then
		lv_cap_req:=(quantity*utilization_rate)/100;
	else
		lv_cap_req:=utilization_rate/100;
	end if;


   wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'CAPACITY_REQUIREMENT',
			       avalue   => lv_cap_req);


   wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'REQUIRED_QUANTITY',
			       avalue   => lv_req_quantity);


   wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'AVAILABLE_QUANTITY',
			       avalue   => lv_ava_quantity);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'PROJECTED_AVAILABLE_BALANCE',
			       avalue   => lv_pab);


  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'SUPPLIER_ID',
			       avalue   => supplier_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_NAME',
			     avalue   => supplier_name);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'SUPPLIER_SITE_ID',
			       avalue   => supplier_site_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_SITE_CODE',
			     avalue   => supplier_site_code);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'CUSTOMER_ID',
			       avalue   => customer_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'CUSTOMER_NAME',
			     avalue   => customer_name);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
                             aname    => 'PLANNER_WORKBENCH',
                             avalue   => (workbench_function||
                                         ': instance_id=' || instance_id ||
                                         ' org_id=' ||
                                          to_char(organization_id)) );

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'PLAN_ID',
			       avalue   => p_plan_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DB_LINK',
			     avalue   => db_link);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'APPS_PS_DBLINK',
			     avalue   => l_a2m_db_link);

  if (lv_exception_type = 70) then
   OPEN SO_C;
   FETCH SO_C INTO so_rec;
   CLOSE SO_C;

   wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'TRANSACTION_ID',
			       avalue   => so_rec.demand_id);
  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'PRE_PRSNG_LEAD_TIME',
			       avalue   => so_rec.old_lead_time);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'POST_PRSNG_LEAD_TIME',
			       avalue   => so_rec.new_lead_time);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORGANIZATION_CODE',
			     avalue   => so_rec.org_code);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DEPARTMENT_LINE_CODE',
			     avalue   => so_rec.to_org);
  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'FROM_DATE',
			     avalue   => so_rec.old_ship_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_DATE',
			     avalue   => so_rec.new_ship_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE1',
			     avalue   => so_rec.old_arrival_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE2',
			     avalue   => so_rec.new_arrival_date);


  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE3',
			     avalue   => so_rec.promise_arrival_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE4',
			     avalue   => so_rec.promise_ship_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE5',
			     avalue   => so_rec.request_arrival_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DATE6',
			     avalue   => so_rec.request_ship_date);


  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DUE_DATE',
			     avalue   => so_rec.latest_acceptable_date);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'RESOURCE_CODE',
			     avalue   => so_rec.customer_site);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_NAME',
			     avalue   => so_rec.old_ship_method);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_SITE_CODE',
			     avalue   => so_rec.new_ship_method);

 wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'PLANNING_GROUP',
			     avalue   => so_rec.atp_override_flag);

  end if; -- end of if (lv_exception_type = 70)
  msc_util.msc_debug('Before start process:'|| item_type || ':' || item_key);

  wf_engine.StartProcess( itemtype => item_type,
			  itemkey  => item_key);


EXCEPTION

  when others then
    wf_core.context('MSC_EXP_WF', 'StartWFProcess', item_key, to_char(p_plan_id),
     organization_code, item_segments, to_char(exception_type));
    raise;

END StartWFProcess;



PROCEDURE SelectPlanner( itemtype  in varchar2,
			 itemkey   in varchar2,
			 actid     in number,
			 funcmode  in varchar2,
			 resultout out NOCOPY varchar2 ) is

  l_sr_status	varchar2(10) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'SR_RESULT');

  l_organization_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'ORGANIZATION_ID');

  l_inventory_item_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'INVENTORY_ITEM_ID');

  l_plan_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'PLAN_ID');

  l_instance_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'INSTANCE_ID');

  l_exception_type	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_TYPE_ID');

  l_order_type		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'ORDER_TYPE_CODE');

  l_stage               number :=
    wf_engine.GetActivityAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 actid    => actid,
                                 aname    => 'STAGE');

  sql_stmt   		varchar2(1000);
  l_planner             varchar2(100);
  l_msg                 varchar2(100);
BEGIN

  msc_util.msc_debug('In the planner select logic');

  if (funcmode = 'RUN') then

    if (l_stage = 1) then
       OPEN PLANNER_C(l_plan_id,l_inventory_item_id,l_organization_id,
                   l_instance_id);
       FETCH PLANNER_C INTO l_planner;
       CLOSE PLANNER_C;
--   l_planner := 'MFG';
       if l_planner is null then
           l_planner := FND_GLOBAL.USER_NAME;
 FND_FILE.PUT_LINE(FND_FILE.LOG,'no planner defined for this item, sent notification to '||l_planner);
       end if;

       wf_engine.SetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'PLANNER',
                               avalue   => l_planner);
    else
       l_planner   :=
          wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'PLANNER');
    end if;
    msc_util.msc_debug('planner:'||l_planner);

    if l_planner is not null THEN
       l_msg := GetPlannerMsgName(l_exception_type,
                            l_order_type,
                            l_stage,
                            l_sr_status);
       wf_engine.SetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'MESSAGE_NAME',
		 	       avalue   => l_msg);
       msc_util.msc_debug('msg name:'||l_msg);

       resultout := 'COMPLETE:FOUND';
    else
      resultout := 'COMPLETE:NOT_FOUND';
    end if;
    return;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;

EXCEPTION

  when others then
    wf_core.context('MSC_EXP_WF', 'SelectPlanner', itemtype, itemkey, actid, funcmode);
    raise;

END SelectPlanner;


FUNCTION GetPlannerMsgName(p_exception_type in number,
                        p_order_type     in number,
                        p_stage          in number,
                        p_result         in varchar2) RETURN varchar2 IS
BEGIN

  if (p_stage = 1) then -- first msg to planner
    if (p_exception_type = 1) then
      return 'MSG_1';
    elsif (p_exception_type = 2) then
      return 'MSG_2';
    elsif (p_exception_type = 3) then
      return 'MSG_3';
    elsif (p_exception_type = 20) then
      return 'MSG_20';
    elsif (p_exception_type = 6) then
      if (p_order_type = 1) then
        return 'MSG_6_PO';
      elsif (p_order_type = 2) then
        return 'MSG_6_REQ';
      elsif (p_order_type in (3, 5, 7, 18)) then  -- work order
        return 'MSG_6_WORK';
      end if;
    elsif (p_exception_type = 7) then
      if (p_order_type = 1) then
        return 'MSG_7_PO';
      elsif (p_order_type = 2) then
        return 'MSG_7_REQ';
      elsif (p_order_type in (3, 5, 7, 18)) then -- work order
        return 'MSG_7_WORK';
      end if;
    elsif (p_exception_type = 8 ) then
      if (p_order_type = 1) then
        return 'MSG_8_PO';
      elsif (p_order_type = 2) then
        return  'MSG_8_REQ';
      elsif (p_order_type in (3, 5, 7, 18)) then -- work order
        return 'MSG_8_WORK';
      end if;
   elsif (p_exception_type = 10 ) then
      if (p_order_type IN (1,2,5)) then --buy planned order,purchase requisition,PO
        return 'MSG_10';
      else -- others
        return 'MSG_10_OTHER';
      end if;
    elsif (p_exception_type = 9) then
      if (p_order_type = 1) then
        return 'MSG_9_PO';
      elsif (p_order_type = 2) then
        return 'MSG_9_REQ';
      elsif (p_order_type in (3, 5, 7, 18)) then -- work order
        return 'MSG_9_WORK';
      end if;
    elsif (p_exception_type = 12) then
      return 'MSG_12';
    elsif (p_exception_type = 13) then
      return 'MSG_13';
    elsif (p_exception_type = 14) then
      return 'MSG_14';
    elsif (p_exception_type in (15,24,25)) then
      return 'MSG_15';
    elsif (p_exception_type in (16,26,27)) then
      return 'MSG_16';
    elsif (p_exception_type = 17) then
      return 'MSG_17';
    elsif (p_exception_type = 18) then
      return 'MSG_18';
    elsif (p_exception_type = 19) then
      return 'MSG_19';
    elsif (p_exception_type = 28) then
      return 'MSG_28';
    elsif (p_exception_type = 37) then
      return 'MSG_37';
    elsif (p_exception_type = 49) then
      if(p_order_type=30) then
        return 'MSG_49_SO';
      elsif (p_order_type=29) then
      return 'MSG_49_FORECAST';
      end if;
    elsif (p_exception_type = 70) then
      if(p_order_type=-30) then -- from release sales order
         return 'MSG_RL_SO';
      else
         return 'MSG_70';
      end if;
   end if;
  else --stage =2 2nd mesg to planner
    if (p_exception_type in (37, 28)) then
       if (p_result = 'SUCCEED') then
          return 'MSG_37_COMP';
       else
          return 'MSG_37_DECLINE';
       end if;
    elsif p_exception_type = 6 then -- 6-7
      if (p_order_type = 1) then
        return 'MSG_6_PO_COMP';
      elsif (p_order_type = 2) then
        return 'MSG_6_REQ_COMP';
      elsif (p_order_type in (3, 5, 7, 18)) then -- work order
        return 'MSG_6_WORK_COMP';
      end if;
   elsif p_exception_type = 7 then -- 6-7
      if (p_order_type = 1) then
        return 'MSG_7_PO_COMP';
      elsif (p_order_type = 2) then
        return 'MSG_7_REQ_COMP';
      elsif (p_order_type in (3, 5, 7, 18)) then -- work order
        return 'MSG_7_WORK_COMP';
      end if;
    elsif p_exception_type = 8 then
      if (p_order_type = 1) then
        return 'MSG_8_PO_COMP';
      elsif (p_order_type = 2) then
        return 'MSG_8_REQ_COMP';
      elsif (p_order_type in (3, 5, 7, 18)) then -- work order
        return 'MSG_8_WORK_COMP';
      end if;
    elsif p_exception_type = 10 then
      if (p_order_type IN (1,2,5)) then --buy planned order,purchase requisition,PO
        return 'MSG_10_COMP';
  else -- others
        return 'MSG_10_OTHER_COMP';
      end if;
    elsif p_exception_type = 9 then
      if (p_order_type = 1) then
        return 'MSG_7_PO_COMP';
      elsif (p_order_type = 2) then
        return 'MSG_7_REQ_COMP';
      elsif (p_order_type in (3, 5, 7, 18)) then -- work order
        return 'MSG_7_WORK_COMP';
      end if;
    end if;
  end if;

EXCEPTION

  when others then
    wf_core.context('MSC_EXP_WF', 'GetPlannerMsgName', to_char(p_exception_type), to_char(p_order_type));
    raise;

END GetPlannerMsgName;

PROCEDURE DetermineOrderType( itemtype  in varchar2,
		              itemkey   in varchar2,
		              actid     in number,
		              funcmode  in varchar2,
		              resultout out NOCOPY varchar2) is

  l_exception_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_ID');

  l_order_type 		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'ORDER_TYPE_CODE');


BEGIN

  msc_util.msc_debug('In determineordertype:'|| l_order_type);

  if (funcmode = 'RUN') then

    -- Purchase Order
    if (l_order_type = 1) then

      resultout := 'COMPLETE:PURCHASE_ORDER';

    -- Purchase Requisition
    elsif (l_order_type = 2) then

      resultout := 'COMPLETE:PURCHASE_REQUISITION';

    -- Discrete Job, Planned Order, Non-standard Job, Flow Schedule
    elsif (l_order_type in  (3, 5, 7, 18)) then

      resultout := 'COMPLETE:WORK_ORDER';

    else

      resultout := 'COMPLETE:OTEHR_ORDER_TYPES';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MSC_EXP_WF', 'DetermineOrderType', itemtype, itemkey, actid, funcmode);
    raise;

END DetermineOrderType;

PROCEDURE Reschedule( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2) is

  l_plan_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
				 aname    => 'PLAN_ID');

  l_transaction_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
				 aname    => 'TRANSACTION_ID');
  l_exception_type      number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'EXCEPTION_TYPE_ID');

  l_order_type          number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORDER_TYPE_CODE');
  l_planner varchar2(200)  :=
          wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'PLANNER');
  p_request_id number;
begin

  if (funcmode = 'RUN') then
    -- This is the new call to the reschedule procedure
    if (l_order_type in (1, 2, 3)) then   -- po, req, discrete
       begin
           msc_rel_wf.init_db(l_planner);
           p_request_id := fnd_request.submit_request(
                         'MSC',
                         'MSCWFRES',
                         null,
                         null,
                         false,
                         l_plan_id,
                         l_transaction_id,
                         l_exception_type);
           commit;
       exception when others then
           p_request_id :=0;
       end;
       wf_engine.SetItemAttrNumber( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'SR_REQUEST_ID',
			       avalue   => p_request_id);

    end if;
    if p_request_id is not null and p_request_id <> 0 then
       resultout := 'COMPLETE:1';
    else
       resultout := 'COMPLETE:0';
    end if;
    return;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;

EXCEPTION
  when others then
    wf_core.context('MSC_EXP_WF', 'Reschedule', itemtype, itemkey, actid, funcmode);
    resultout := 'COMPLETE:0';
    raise;

end Reschedule;

PROCEDURE Reschedule_program(
                      errbuf OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY NUMBER,
                      l_plan_id in number,
                      l_transaction_id in number,
                      l_exception_type in number) is

  l_plan_name           varchar2(30) := 'dummy';
  l_order_type		number;
  l_sr_instance_id	number;
  l_org_id	number;
  l_user_id		number := fnd_global.user_id;
  l_po_group_by		number := fnd_profile.value('MSC_LOAD_REQ_GROUP_BY');
  l_po_batch_number	number;
  l_wip_group_id	number;

  l_po_header_id        number;
  l_po_line_id          number;
  l_po_number           number;
  l_return_code         boolean;
  l_new_need_by_date    date;
  l_old_need_by_date    date;
  l_reschedule_result	boolean;
  l_load_type           number;

  var_loaded_jobs   MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_reqs   MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_scheds MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_jobs  MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_reqs  MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_wip_req_id    MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_req_load_id   MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_req_reschd_id MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_released_inst MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_int_reqs   MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_int_reqs  MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_int_req_load_id   MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_int_req_reschd_id MSC_Rel_Plan_PUB.NumTblTyp:= MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_lot_jobs   MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_lot_jobs   MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_osfm_req_id   MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_resched_eam_jobs   MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_eam_req_id   MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_int_repair_orders MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_int_repair_orders_id MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_loaded_ext_repair_orders MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  var_ext_repair_orders_id MSC_Rel_Plan_PUB.NumTblTyp:=
                            MSC_Rel_Plan_PUB.NumTblTyp(0);
  p_po_res_id msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
  p_po_res_count msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
  p_po_pwb_count msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
  p_released_inst msc_rel_wf.numTblTyp:=msc_rel_wf.numTblTyp(0);
  p_res_po_count number :=0;
  p_request_id number;
BEGIN

      UPDATE MSC_SUPPLIES
      SET    old_order_quantity       = new_order_quantity,
             quantity_in_process      = new_order_quantity,
             implement_date           = new_schedule_date,
             implement_dock_date      = new_dock_date,
             implement_quantity        =
                decode(l_exception_type, 8, 0, new_order_quantity),
             implement_status_code =
                decode(order_type, 3,
                  decode(l_exception_type, 8, 7, implement_status_code),
                                              implement_status_code),
             implement_source_org_id  = NULL,
             implement_supplier_id      = NULL,
             implement_supplier_site_id = NULL,
             implement_project_id     = project_id,
             implement_task_id        = task_id,
             implement_demand_class   = demand_class,
             load_type                =
                 decode(order_type, 3,
                           decode(nvl(cfm_routing_flag,0), 3, 6, 4),
                                    2, 16, 1, 20, NULL),
             last_update_date         = sysdate,
             last_updated_by          = l_user_id
      WHERE transaction_id = l_transaction_id
      AND   plan_id = l_plan_id
      returning organization_id, sr_instance_id, order_type into
                l_org_id, l_sr_instance_id, l_order_type;

      if l_order_type = 1 then -- po
         FND_FILE.PUT_LINE(FND_FILE.LOG,
             'start to launch PO Reschedule for '||l_transaction_id);
            msc_rel_wf.reschedule_purchase_orders(
             l_plan_id,
             l_org_id,
             l_sr_instance_id,
             l_org_id,
             l_sr_instance_id,
             p_res_po_count,
             p_released_inst,
             p_po_res_id,
             p_po_res_count,
             p_po_pwb_count);
        p_request_id := p_po_res_id(1);
      else
         FND_FILE.PUT_LINE(FND_FILE.LOG,
             'start msc_rel_plan_pub.msc_release_plan_sc for '||l_transaction_id);
        msc_rel_plan_pub.msc_release_plan_sc
          (  arg_plan_id	  => l_plan_id
          ,  arg_log_org_id	  => l_org_id
          ,  arg_log_sr_instance  => l_sr_instance_id
          ,  arg_org_id 	  => l_org_id
          ,  arg_sr_instance      => l_sr_instance_id
          ,  arg_compile_desig	  => l_plan_name
          ,  arg_user_id 	  => l_user_id
          ,  arg_po_group_by 	  => l_po_group_by
          ,  arg_po_batch_number  => l_po_batch_number
          ,  arg_wip_group_id 	  => l_wip_group_id -- 111
          ,  arg_loaded_jobs 	  => var_loaded_jobs
          ,  arg_loaded_reqs 	  => var_loaded_reqs
          ,  arg_loaded_scheds 	  => var_loaded_scheds
          ,  arg_resched_jobs 	  => var_resched_jobs
          ,  arg_resched_reqs 	  => var_resched_reqs
          ,  arg_wip_req_id  	  => var_wip_req_id
          ,  arg_req_load_id 	  => var_req_load_id
          ,  arg_req_resched_id   => var_req_reschd_id
          ,  arg_released_instance => var_released_inst
          ,  arg_mode              => 'WF'
          ,  arg_transaction_id    => l_transaction_id
          ,  arg_loaded_lot_jobs 	  => var_loaded_lot_jobs
          ,  arg_resched_lot_jobs 	  => var_resched_lot_jobs
          ,  arg_osfm_req_id 	  => var_osfm_req_id
          ,  arg_resched_eam_jobs => var_resched_eam_jobs
          ,  arg_eam_req_id       => var_eam_req_id
          ,  arg_loaded_int_reqs 	  => var_loaded_int_reqs
          ,  arg_resched_int_reqs	  => var_resched_int_reqs
          ,  arg_int_req_load_id 	  => var_int_req_load_id
          ,  arg_int_req_resched_id   => var_int_req_reschd_id
          , arg_loaded_int_repair_orders => var_loaded_int_repair_orders
          , arg_int_repair_orders_id     => var_int_repair_orders_id
          , arg_loaded_ext_repair_orders => var_loaded_ext_repair_orders
          , arg_ext_repair_orders_id     => var_ext_repair_orders_id
);
        p_request_id := nvl(var_wip_req_id(1),
                         nvl(var_osfm_req_id(1),
                          nvl(var_req_reschd_id(1),var_int_req_reschd_id(1))));
     end if;
         FND_FILE.PUT_LINE(FND_FILE.LOG,
             'request id is '||p_request_id);

END Reschedule_program;


PROCEDURE DeleteActivities( arg_plan_id in number) IS

  TYPE DelExpType is REF CURSOR;
  delete_activities_c DelExpType;
  -- Note that the null is important for this instance
  CURSOR instance_c(p_plan_id in varchar2) IS
    SELECT DEcode(m2a_dblink, null, ' ', '@' || m2a_dblink)
    FROM   msc_apps_instances
    WHERE  instance_id in (select sr_instance_id
                           from   msc_plan_organizations
                           where  plan_id = p_plan_id)
    UNION
    select ' '
    from dual;

  l_item_key		varchar2(240);
  l_db_link             varchar2(80);
  sql_stmt              varchar2(1000);
  l_item_type           varchar2(8);

BEGIN

  -- First loop for each instance and in the inner loop for each
  -- exception id

  OPEN instance_c(arg_plan_id);
  LOOP
    FETCH instance_c INTO l_db_link;
    EXIT WHEN instance_c%NOTFOUND;

    if l_db_link <> ' ' then  -- purge wf in the source

        sql_stmt :=
          'begin mrp_msc_exp_wf.deleteActivities'||l_db_link||
                '(:arg_plan_id); end;';

        EXECUTE IMMEDIATE sql_stmt USING arg_plan_id;

    else

     sql_stmt := ' SELECT item_key, item_type ' ||
                ' FROM wf_items' || l_db_link ||
                ' WHERE item_type in (''MSCEXPWF'',''MRPEXWFS'') '||
                ' AND   item_key like '''|| to_char(arg_plan_id) || '-%''';

    OPEN delete_activities_c for sql_stmt;
    LOOP

        FETCH DELETE_ACTIVITIES_C INTO l_item_key, l_item_type;
        EXIT WHEN DELETE_ACTIVITIES_C%NOTFOUND;

    msc_util.msc_debug('DELETING dblink:' || l_db_link || ':' || l_item_key ||','||l_item_type);
        update
                wf_notifications
         set    end_date = sysdate
         where  group_id in
          (select notification_id
          from wf_item_activity_statuses
          where item_type = l_item_type
          and item_key = l_item_key
          union
          select notification_id
          from wf_item_activity_statuses_h
          where item_type = l_item_type
          and item_key = l_item_key);

        update wf_items
         set end_date = sysdate
         where item_type = l_item_type
         and item_key = l_item_key;

        update wf_item_activity_statuses
         set end_date = sysdate
         where item_type = l_item_type
         and item_key = l_item_key;

        update wf_item_activity_statuses_h
         set end_date = sysdate
         where item_type = l_item_type
         and item_key = l_item_key;

        wf_purge.total(l_item_type,l_item_key,sysdate);


      END LOOP; -- for the itemkey loop
      CLOSE delete_activities_c;
   end if;
  END LOOP; -- for the instance loop
  CLOSE instance_c;
  commit work;
  return;

EXCEPTION
  when others then
    msc_util.msc_debug('Error in delete activities:'|| to_char(sqlcode) || ':'
    || substr(sqlerrm,1,100));

      return;
END DeleteActivities;

FUNCTION SupplierCapacity(arg_plan_id in number,
                          arg_exception_id in number)
return number
IS
  total_cap  number := 0;
  p_partner_id number;
  p_site_id    number;
  p_item_id    number;
  p_org_id     number;
  p_inst_id    number;
  p_cap        number;
  days_between number;
  l_from       date;
  l_to         date;
  p_from_date  date;
  p_to_date    date;
  p_percent    number;
  p_uom        varchar2(30);
  p_puom       varchar2(30);
  curr_date    date;
  temp_date    date;
  suptol       SupplierToleranceRecord;
/*
  CURSOR uom(partner_id in number,partner_site_id in number,
             item_id in number, org_id in number, inst_id in number) IS
  SELECT DISTINCT convd.conversion_rate/convs.conversion_rate
  FROM   msc_uom_conversions convs,msc_uom_conversions convd,
         msc_system_items msi, msc_item_suppliers sup
  WHERE  sup.supplier_id = partner_id
  AND    sup.supplier_site_id = partner_site_id
  AND    sup.inventory_item_id = item_id
  AND    sup.organization_id = org_id
  AND    sup.sr_instance_id = inst_id
  AND    sup.plan_id = arg_plan_id
  AND    sup.using_organization_id = -1
  AND    msi.plan_id = arg_plan_id
  AND    msi.inventory_item_id = item_id
  AND    msi.organization_id = org_id
  AND    msi.sr_instance_id = inst_id
  AND    convs.sr_instance_id = inst_id
  AND    convs.inventory_item_id = 0
  AND    convs.uom_code = msi.uom_code
  AND    convd.sr_instance_id = inst_id
  AND    convd.inventory_item_id = 0
  AND    convd.uom_code = sup.purchasing_unit_of_measure;
*/

  CURSOR sup_cap(partner_id in number,partner_site_id in number,
                 p_from_date in date,p_to_date in date, item_id in number,
                 p_org_id in number, inst_id in number) IS
  SELECT DISTINCT capacity,from_date,NVL(to_date,from_date)
  FROM   msc_supplier_capacities
  WHERE  plan_id = arg_plan_id
  AND    supplier_id = partner_id
  AND    supplier_site_id = partner_site_id
  AND    inventory_item_id = item_id
  AND    organization_id = p_org_id
  AND    sr_instance_id = inst_id
  AND    from_date <= NVL(p_to_date,p_from_date)
  AND    to_date > p_from_date;
BEGIN
  -- Get the reference data for future SQL
  --dbms_output.put_Line('In procedure');
  SELECT DISTINCT from_date,NVL(to_date,from_date),
         NVL(utilization_rate,quantity),supplier_id,
         supplier_site_id, inventory_item_id, organization_id, sr_instance_id
  INTO   p_from_date,p_to_date,p_percent,p_partner_id,p_site_id,p_item_id,
         p_org_id,p_inst_id
  FROM   msc_exception_details_v
  WHERE  plan_id = arg_plan_id
  AND    exception_id = arg_exception_id;

  -- Get the tolerance information
  --dbms_output.put_line('Before the tolerance information');
  SELECT DISTINCT fence_days, tolerance_percentage
  BULK COLLECT INTO suptol.fence,suptol.tolerance
  FROM   msc_supplier_flex_fences
  WHERE  plan_id = arg_plan_id
  AND    inventory_item_id = p_item_id
  AND    organization_id = p_org_id
  AND    sr_instance_id = p_inst_id
  AND    supplier_id = p_partner_id
  AND    supplier_site_id = p_site_id
  ORDER BY fence_days;

  -- This obtains the capacity rows
  -- For each of them we need to apply the tolerances, to find the actual
  -- capacity promised
  curr_date := MSC_CALENDAR.NEXT_WORK_DAY(
                       p_org_id,p_inst_id,MSC_CALENDAR.TYPE_DAILY_BUCKET,
                       sysdate);
  --dbms_output.put_line('p_to_date:'|| to_char(p_to_date,'DD-MON-YYYY'));
  --dbms_output.put_line('p_from_date:'|| to_char(p_from_date,'DD-MON-YYYY'));
  --dbms_output.put_line('Curr date:' || to_char(curr_date,'DD-MON-YYYY'));
  --dbms_output.put_line('p_percent:' || to_char(p_percent));
  OPEN sup_cap(p_partner_id,p_site_id,p_from_date,p_to_date,p_item_id,
               p_org_id,p_inst_id);
  LOOP
     FETCH sup_cap INTO p_cap,l_from,l_to;
     EXIT WHEN sup_cap%NOTFOUND;
     -- Now for each record, calculate the net capacity

     --dbms_output.put_line('l_from:' || to_char(l_from,'DD-MON-YYYY'));
     --dbms_output.put_line('l_to:' || to_char(l_to,'DD-MON-YYYY'));
     --dbms_output.put_line('p_cap:' || to_char(p_cap));

     if (p_from_date >= l_from) then
       if ((p_from_date - l_to) > 0) then
          if ((curr_date - l_from) > 0) then
             days_between := l_to - curr_date +1;
          else
             if (trunc(p_to_date) = trunc(p_from_date)) then
               days_between := 1;
             else
               days_between := l_to - l_from +1;
             end if;
          end if;
       else
          if ((curr_date - l_from) > 0) then
            days_between := p_from_date - curr_date;
          else
            if (trunc(p_to_date) = trunc(p_from_date)) then
               days_between := 1;
            else
               days_between := p_from_date - l_from;
            end if;
          end if;
       end if;
       --dbms_output.put_line('days_between:' || to_char(days_between));
       if (days_between > 0) then
          total_cap := total_cap + p_cap * days_between;
       end if;
       -- Now the tolerance
       if (p_from_date > l_to) then
         temp_date := l_to +1;
       else
         temp_date := p_from_date;
       end if;
       --dbms_output.put_line('temp date:' || to_char(temp_date,'DD-MON-YYYY'));
       -- Check tolerances only if they exist
       IF (suptol.fence.COUNT > 0) THEN
       FOR i in suptol.fence.FIRST..suptol.fence.LAST LOOP
        if (l_from > (curr_date + suptol.fence(i))) then
          days_between := temp_date - l_from;
        else
          days_between := temp_date - curr_date - suptol.fence(i);
        end if;
        if (days_between > 0) then
          total_cap := total_cap + p_cap * (suptol.tolerance(i)/100) *
                                    days_between;
          temp_date := temp_date - days_between;
        end if;
       END LOOP;
       END IF;
     end if; -- (p_from_date > l_from)
     --total_cap := total_cap + p_cap;
  END LOOP;
  CLOSE sup_cap;
  -- Note that the capacity is already in the vendor UOM, so we are okay
  --dbms_output.put_line('Final total_cap:' || to_char(total_cap));

  return(total_cap * p_percent/100.0);
EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('Error:'|| to_char(sqlcode) || ':' ||
    --                         substr(sqlerrm,1,50));
    return(0);
END SupplierCapacity;


PROCEDURE IsCallback(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is
  l_is_callback     varchar2(3) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'IS_CALL_BACK');

BEGIN
  if (funcmode = 'RUN') then
    resultout := 'COMPLETE:' || l_is_callback;
    return;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;

EXCEPTION

  when others then
    wf_core.context('MSC_EXP_WF', 'IsCallback', itemtype, itemkey, actid, funcmode);
    raise;

END IsCallback;

PROCEDURE SelectSrUsers(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  CURSOR BUYER_C(p_inventory_item_id  in number,
                 p_plan_id            in number,
                 p_org_id             in number,
                 p_instance           in number) IS
    SELECT cont.name
    FROM   msc_partner_contacts cont, msc_system_items sys
    WHERE  sys.inventory_item_id = p_inventory_item_id
    AND    sys.organization_id = p_org_id
    AND    sys.sr_instance_id = p_instance
    AND    sys.plan_id = p_plan_id
    AND    cont.partner_id = sys.buyer_id
    AND    cont.sr_instance_id = sys.sr_instance_id
    AND    cont.partner_type = 4;

  CURSOR SUPCNT_C(p_exception_id in number,p_plan_id in number) IS
    SELECT name
    FROM   msc_partner_contacts cont,
           msc_exception_details exp,
           msc_supplies ms
    WHERE  exp.exception_detail_id = p_exception_id
    AND    exp.plan_id = p_plan_id
    AND    cont.partner_site_id = nvl(exp.supplier_site_id,ms.supplier_site_id)
    AND    cont.partner_type = 1
    AND    cont.sr_instance_id = nvl(exp.sr_instance_id,ms.sr_instance_id)
    AND    ms.plan_id(+) = exp.plan_id
    AND    ms.transaction_id(+) = exp.number1;

  CURSOR SALESREP_C(p_exception_id in number,
                    p_plan_id      in number) IS
    SELECT so.salesrep_id
    FROM   msc_sales_orders so,
           msc_demands mgr,
           msc_exception_details exp
    WHERE  so.sales_order_number = mgr.order_number
    AND    so.sr_instance_id = mgr.sr_instance_id
    AND    mgr.plan_id = exp.plan_id
    AND    mgr.demand_id = exp.number1
    AND    exp.exception_detail_id = p_exception_id
    AND    exp.plan_id = p_plan_id;

  CURSOR SALESREP_C2(p_demand_id in number,
                    p_plan_id      in number) IS
    SELECT so.salesrep_id
    FROM   msc_sales_orders so,
           msc_demands mgr
    WHERE  so.sales_order_number = mgr.order_number
    AND    so.sr_instance_id = mgr.sr_instance_id
    AND    mgr.plan_id = p_plan_id
    AND    mgr.demand_id = p_demand_id;

  CURSOR CUSTCNT_C(p_exception_id in number, p_plan_id in number) IS
    SELECT name
    FROM   msc_partner_contacts cont, msc_demands mgr,
         msc_exception_details exp
    WHERE  exp.exception_detail_id = p_exception_id
    AND    exp.plan_id = p_plan_id
    AND    cont.partner_id = mgr.customer_id
    AND    cont.partner_site_id = mgr.customer_site_id
    AND    cont.partner_type = 2
    and    cont.sr_instance_id = mgr.sr_instance_id
    AND    mgr.demand_id = exp.number1
    AND    mgr.plan_id = exp.plan_id;

  CURSOR CUSTCNT_C2(p_demand_id in number, p_plan_id in number) IS
    SELECT name
    FROM   msc_partner_contacts cont, msc_demands mgr
    where  cont.partner_id = mgr.customer_id
    AND    cont.partner_site_id = mgr.customer_site_id
    AND    cont.partner_type = 2
    and    cont.sr_instance_id = mgr.sr_instance_id
    AND    mgr.demand_id = p_demand_id
    AND    mgr.plan_id = p_plan_id;



  l_exception_type     number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'EXCEPTION_TYPE_ID');

  l_demand_id   number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TRANSACTION_ID');

  l_order_type   number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORDER_TYPE_CODE');

  l_inventory_item_id   number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'INVENTORY_ITEM_ID');

  l_plan_id     number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PLAN_ID');

  l_org_id      number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORGANIZATION_ID');

  l_instance_id number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'INSTANCE_ID');

  l_from_project_number      varchar2(100) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'PROJECT_NUMBER');

  l_to_project_number   varchar2(100) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'TO_PROJECT_NUMBER');

  l_from_task_number         varchar2(100) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'TASK_NUMBER');

  l_to_task_number      varchar2(100) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'TO_TASK_NUMBER');

  l_exception_id number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'EXCEPTION_ID');

  l_buyer varchar2(30);
  l_supcnt varchar2(30);
  l_salesrep varchar2(30);
  l_from_prj_mgr varchar2(100);
  l_to_prj_mgr varchar2(100);
  l_custcnt varchar2(30);

  CURSOR PRJ_MGR_C(p_project_number in varchar2) IS
    SELECT proj.manager_contact
    FROM   msc_projects proj
    where  proj.project_number = p_project_number
    and    proj.organization_id = l_org_id
    and    proj.sr_instance_id = l_instance_id
    AND    proj.plan_id = -1;

  CURSOR TSK_MGR_C(p_project_number in varchar2, p_task_number in varchar2) IS
    SELECT NVL(tasks.manager_contact,proj.manager_contact)
    FROM   msc_projects proj, msc_project_tasks tasks
    WHERE  tasks.task_number = p_task_number
    AND    proj.project_id = tasks.project_id
    AND    proj.project_number = p_project_number
    and    proj.organization_id = tasks.organization_id
    and    proj.sr_instance_id = tasks.sr_instance_id
    AND    proj.plan_id = tasks.plan_id
    and    proj.organization_id = l_org_id
    and    proj.sr_instance_id = l_instance_id
    AND    proj.plan_id = -1;

BEGIN
  if (funcmode = 'RUN') then
     if l_exception_type in (28, 37) OR
          (l_exception_type in (6, 7, 8, 9, 10) and l_order_type in (1,2)) then

        OPEN BUYER_C(l_inventory_item_id, l_plan_id, l_org_id,l_instance_id);
        FETCH BUYER_C INTO l_buyer;
        CLOSE BUYER_C;

  --l_buyer := 'MFG';

        if (l_buyer is not null) then
          wf_engine.setItemAttrText( itemtype => itemtype,
                                       itemkey => itemkey,
                                       aname => 'BUYER',
                                       avalue => l_buyer);
        END IF;
     END IF;

     if (l_exception_type in (6, 7, 8, 9, 10) and l_order_type = 1) or
          l_exception_type in (37, 28) then

        OPEN SUPCNT_C(l_exception_id,l_plan_id);
        FETCH SUPCNT_C INTO l_supcnt;
        CLOSE SUPCNT_C;

 -- l_supcnt := 'MFG';

        if (l_supcnt is not null) then
          wf_engine.setItemAttrText( itemtype => itemtype,
                                       itemkey => itemkey,
                                       aname => 'SUPCNT',
                                       avalue => l_supcnt);
        END IF;
     END IF;

     if (l_exception_type in (13, 15, 24, 25, 49, 70)) then
        if l_exception_type = 70 then
          OPEN SALESREP_C2(l_demand_id,l_plan_id);
          FETCH SALESREP_C2 INTO l_salesrep;
          CLOSE SALESREP_C2;
        else
          OPEN SALESREP_C(l_exception_id,l_plan_id);
          FETCH SALESREP_C INTO l_salesrep;
          CLOSE SALESREP_C;
        end if;

--  l_salesrep := '1208';
        if (l_salesrep is not null) then
          wf_engine.setItemAttrText( itemtype => itemtype,
                                       itemkey => itemkey,
                                       aname => 'SALESREP',
                                       avalue => l_salesrep);
        END IF;

        if l_exception_type = 70 then
          OPEN CUSTCNT_C2(l_demand_id,l_plan_id);
          FETCH CUSTCNT_C2 INTO l_custcnt;
          CLOSE CUSTCNT_C2;
         else
          OPEN CUSTCNT_C(l_exception_id,l_plan_id);
          FETCH CUSTCNT_C INTO l_custcnt;
          CLOSE CUSTCNT_C;
         end if;
  -- l_custcnt := 'MFG';

        if (l_custcnt is not null) then
          wf_engine.setItemAttrText( itemtype => itemtype,
                                       itemkey => itemkey,
                                       aname => 'CUSTCNT',
                                       avalue => l_custcnt);
        END IF;
    end if;

    if (l_exception_type in (17, 18, 19)) then
        if l_from_project_number is not null and
           l_from_task_number is not null then
          OPEN TSK_MGR_C(l_from_project_number,l_from_task_number);
          FETCH TSK_MGR_C INTO l_from_prj_mgr;
          CLOSE TSK_MGR_C;
        elsif l_from_project_number is not null then

          OPEN PRJ_MGR_C(l_from_project_number);
          FETCH PRJ_MGR_C INTO l_from_prj_mgr;
          CLOSE PRJ_MGR_C;
        end if;
 --l_from_prj_mgr := 'MFG';

        if (l_from_prj_mgr is not null) then
          wf_engine.setItemAttrText( itemtype => itemtype,
                                       itemkey => itemkey,
                                       aname => 'FROM_PRJ_MGR',
                                       avalue => l_from_prj_mgr);
        END IF;

        if l_to_project_number is not null and
           l_to_task_number is not null then
          OPEN TSK_MGR_C(l_to_project_number,l_to_task_number);
          FETCH TSK_MGR_C INTO l_to_prj_mgr;
          CLOSE TSK_MGR_C;
        elsif l_to_project_number is not null then

          OPEN PRJ_MGR_C(l_to_project_number);
          FETCH PRJ_MGR_C INTO l_to_prj_mgr;
          CLOSE PRJ_MGR_C;
        end if;

 --l_to_prj_mgr := 'MFG';
        if (l_to_prj_mgr is not null) then
          wf_engine.setItemAttrText( itemtype => itemtype,
                                       itemkey => itemkey,
                                       aname => 'TO_PRJ_MGR',
                                       avalue => l_to_prj_mgr);
        END IF;

     end if;

    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;

EXCEPTION

  when others then
    wf_core.context('MSC_EXP_WF', 'IsCallback', itemtype, itemkey, actid, funcmode);
    raise;

END SelectSrUsers;

PROCEDURE CheckBuyer(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout out NOCOPY varchar2) is

  l_planner     varchar2(20) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'PLANNER');
  l_buyer  varchar2(50) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'BUYER');
BEGIN
  if (funcmode = 'RUN') then
     if (l_buyer is null) then
        resultout := 'COMPLETE:NOT_FOUND';
        return;
/*
     elsif l_buyer = l_planner then
        resultout := 'COMPLETE:IS_PLANNER';
        return;
*/
     else
        resultout := 'COMPLETE:FOUND';
        return;
     end if;
  end if;
  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;
END CheckBuyer;

-- call back a wf process at destition instance for completion
PROCEDURE StartSrWF(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_db_link     varchar2(30) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'DB_LINK');

  l_exception_type    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
			         aname    => 'EXCEPTION_TYPE_ID');

  l_transaction_id    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
			         aname    => 'TRANSACTION_ID');

  l_order_type number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORDER_TYPE_CODE');

  l_sr_item_type varchar2(50) := 'MRPEXWFS';
  l_sr_item_key varchar2(100);
  l_text varchar2(100);
  l_numb number;
  l_date Date;
  l_sr_process varchar2(50);
  sql_stmt varchar2(2000);
  p_request_id number :=0;
  p_result boolean;
BEGIN
  if (funcmode = 'RUN') then
     -- now find out sr process, and start it.
     if (l_exception_type in (28, 37)) then
        l_sr_process := 'MSC_SUPCAP_SR_PROCESS';
     elsif (l_exception_type in (6, 7, 8, 9, 10)) then
        if (l_order_type = 1) then
           l_sr_process := 'MSC_PO_SR_PROCESS';
        else
           l_sr_process := 'MSC_REQ_SR_PROCESS';
        END IF;
     elsif (l_exception_type in (13, 15, 24, 25, 49, 70)) then
        l_sr_process := 'MSC_SO_SR_PROCESS';
     elsif (l_exception_type in (17, 18, 19)) then
        l_sr_process := 'MSC_PRJ_SR_PROCESS';
     end if;
     l_sr_item_key := itemkey || '-' || l_sr_process;

     sql_stmt := 'begin wf_engine.CreateProcess' || l_db_link ||
                  '( itemtype => :l_itemtype,' ||
                  'itemkey  => :l_itemkey, ' ||
                  'process   => :l_process);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type, l_sr_item_key,
                                       l_sr_process;

     -- now copy attributes to sr wf process
     -- we could only copy those insterested attributes,
     -- but we copy all for debug purpose.

     -- ORDER_TYPE_CODE
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORDER_TYPE_CODE'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_order_type;

     -- EXCEPTION_TYPE_ID.
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''EXCEPTION_TYPE_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_exception_type;


     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TRANSACTION_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_transaction_id;

     -- APPS_PS_DBLINK
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''APPS_PS_DBLINK'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_db_link;

     --BUYER. we don't need to set back BUYER, set it for debug
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'BUYER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''BUYER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SALESREP');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SALESREP'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- we don't need to set back CUSTCNT, for debug only
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CUSTCNT');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CUSTCNT'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- customer_name
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CUSTOMER_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CUSTOMER_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- customer_ID.
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CUSTOMER_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CUSTOMER_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;


     -- Days_compressed
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DAYS_COMPRESSED');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DAYS_COMPRESSED'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     -- APPS_PS_DBLINK. we may not need.
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'APPS_PS_DBLINK');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''APPS_PS_DBLINK'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- DEPARTMENT_LINE_CODE.
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DEPARTMENT_LINE_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DEPARTMENT_LINE_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- due_date.
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DUE_DATE');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DUE_DATE'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;

     -- end_item_display_name.
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'END_ITEM_DISPLAY_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''END_ITEM_DISPLAY_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

  -- end_item_description

     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'END_ITEM_DESCRIPTION');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''END_ITEM_DESCRIPTION'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;


     --END_ORDER_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'END_ORDER_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''END_ORDER_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- EXCEPTION_DESCRIPTION
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'EXCEPTION_DESCRIPTION');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''EXCEPTION_DESCRIPTION'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     --EXCEPTION_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'EXCEPTION_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''EXCEPTION_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     -- FROM_DATE
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'FROM_DATE');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''FROM_DATE'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;

     -- FROM_PRJ_MGR
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'FROM_PRJ_MGR');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''FROM_PRJ_MGR'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     --INSTANCE_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'INSTANCE_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''INSTANCE_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     --INVENTORY_ITEM_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'INVENTORY_ITEM_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''INVENTORY_ITEM_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     -- ITEM_DISPLAY_NAME
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ITEM_DISPLAY_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ITEM_DISPLAY_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

   -- ITEM DESCRIPTION

      l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ITEM_DESCRIPTION');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ITEM_DESCRIPTION'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;


     -- LOT_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'LOT_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''LOT_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- ORDER_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORDER_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORDER_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- ORGANIZATION_CODE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORGANIZATION_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORGANIZATION_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     --ORGANIZATION_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORGANIZATION_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORGANIZATION_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     --PLAN_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLAN_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLAN_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     -- PLAN_NAME
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLAN_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLAN_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- PLANNER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLANNER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLANNER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- PLANNING_GROUP
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLANNING_GROUP');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLANNING_GROUP'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- PROJECT_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PROJECT_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PROJECT_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

    --PRE_PROCESSING_LEAD_TIME
      l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PRE_PRSNG_LEAD_TIME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PRE_PRSNG_LEAD_TIME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

   --PROCESSING_LEAD_TIME
    l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PRSNG_LEAD_TIME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PRSNG_LEAD_TIME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

  --POST_PROCESSING_LEAD_TIME
   l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'POST_PRSNG_LEAD_TIME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''POST_PRSNG_LEAD_TIME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;



     -- QUANTITY
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'QUANTITY');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''QUANTITY'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- RESOURCE_CODE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'RESOURCE_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''RESOURCE_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- SUPCNT
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPCNT');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPCNT'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     --SUPPLIER_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     -- SUPPLIER_NAME
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- SUPPLIER_SITE_CODE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_SITE_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_SITE_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     --SUPPLIER_SITE_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_SITE_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_SITE_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

     -- SUPPLy_TYPE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLY_TYPE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLY_TYPE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- TASK_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TASK_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TASK_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- TO_DATE
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_DATE');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_DATE'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;

     -- TO_PRJ_MGR
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_PRJ_MGR');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_PRJ_MGR'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- TO_PROJECT_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_PROJECT_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_PROJECT_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- TO_TASK_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_TASK_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_TASK_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- URL1
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'URL1');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''URL1'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_text;

     -- UTILIZATION_RATE
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'UTILIZATION_RATE');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''UTILIZATION_RATE'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;


          -- CAPACITY_REQUIREMENT
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CAPACITY_REQUIREMENT');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CAPACITY_REQUIREMENT'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;


	--REQUIRED_QUANTITY
      l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'REQUIRED_QUANTITY');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''REQUIRED_QUANTITY'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;


	--PROJECTED_AVAILABLE_BALANCE
      l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PROJECTED_AVAILABLE_BALANCE');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PROJECTED_AVAILABLE_BALANCE'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

	--AVAILABLE_QUANTITY
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'AVAILABLE_QUANTITY');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''AVAILABLE_QUANTITY'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;

	--QTY_RELATED_VALUES
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'QTY_RELATED_VALUES');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''QTY_RELATED_VALUES'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_numb;



if (l_exception_type =70 ) then
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DATE1');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DATE1'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;

     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DATE2');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DATE2'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DATE3');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DATE3'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DATE4');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DATE4'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DATE5');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DATE5'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DATE6');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DATE6'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key,l_date;
end if; -- end of if (l_exception_type = 70)
     -- now start wf process at destination instance

     sql_stmt := 'begin wf_engine.StartProcess'|| l_db_link ||
                  '( itemtype => :itemtype,' ||
                  ' itemkey  => :itemkey);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_sr_item_type,l_sr_item_key;

   if l_db_link is not null and l_db_link <> ' ' then
     begin
        commit;
        execute immediate 'alter session close database link '||
                         ltrim(l_db_link,'@');
     exception
        when others then
          wf_engine.SetItemAttrNumber( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'SR_REQUEST_ID',
			       avalue   => -1);
     end;
  end if;
  wf_engine.SetItemAttrNumber( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'SR_REQUEST_ID',
			       avalue   => p_request_id);


     resultout := 'COMPLETE:';


     RETURN;
  END IF;

  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;
EXCEPTION
  when others then
    wf_core.context('MSC_EXP_WF', 'StartSrWF', itemtype, itemkey, actid, funcmode);
    raise;
END StartSrWF;

Procedure launch_background_program(p_planner in varchar2,
                                    p_item_type in varchar2,
                                    p_item_key in varchar2,
                                    p_request_id out NOCOPY number) IS
  p_result boolean;
Begin
    msc_rel_wf.init_db(p_planner);
    p_result := fnd_request.set_mode(true);

   -- this will call start_deferred_activity
    p_request_id := fnd_request.submit_request(
                         'MSC',
                         'MSCWFBG',
                         null,
                         null,
                         false,
                         p_item_type,
                         p_item_key);

exception when others then
 p_request_id :=0;
 raise;
End launch_background_program;

Procedure start_deferred_activity(
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_item_type varchar2,
                           p_item_key varchar2) IS
  CURSOR status_cur IS
   select 1
   from wf_item_activity_statuses
   where item_type = p_item_type
     and item_key =  p_item_key
     and activity_status = 'DEFERRED';
  v_dummy number;
  v_time_elapsed number := 0;
BEGIN
   while (v_dummy is null and v_time_elapsed < 120) loop
     OPEN status_cur;
     FETCH status_cur INTO v_dummy;
     CLOSE status_cur;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'check deferred for '||p_item_key);
     dbms_lock.sleep(10);
     v_time_elapsed := v_time_elapsed + 10;
   end loop;
   if v_dummy = 1 then
      FND_FILE.PUT_LINE(FND_FILE.LOG,
           'start backgroud process for'||p_item_type);
      wf_engine.background(p_item_type);
   end if;
END start_deferred_activity;

FUNCTION demand_order_type (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return number is
  CURSOR dmd_cur IS
  SELECT origination_type
  FROM msc_demands
  WHERE plan_id = p_plan_id
   and sr_instance_id = p_inst_id
   and demand_id = p_demand_id;
   p_order_type number;
  BEGIN
   if ( p_plan_id is null OR p_inst_id is null or p_demand_id is null ) then
    return to_number(null);
   end if;

    OPEN dmd_cur;
    FETCH dmd_cur INTO p_order_type;
    CLOSE dmd_cur;
    return p_order_type;
  END demand_order_type;

  FUNCTION demand_order_date (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return date is
  CURSOR dmd_cur IS
  SELECT using_assembly_demand_date
  FROM msc_demands
  WHERE plan_id = p_plan_id
   and sr_instance_id = p_inst_id
   and demand_id = p_demand_id;
   p_order_date date;
  BEGIN
   if ( p_plan_id is null OR p_inst_id is null or p_demand_id is null ) then
    return to_date(null);
   end if;

    OPEN dmd_cur;
    FETCH dmd_cur INTO p_order_date;
    CLOSE dmd_cur;
    return p_order_date;
  END demand_order_date;

/*Function to return the substitute_supply_date for exception 49.*/
FUNCTION substitute_supply_date (p_plan_id number,
                           p_inst_id number,
                           p_demand_id NUMBER) return date is
  CURSOR dmd_cur IS
  SELECT DMD_SATISFIED_DATE
  FROM msc_demands
  WHERE plan_id = p_plan_id
   and sr_instance_id = p_inst_id
   and demand_id = p_demand_id;
   p_supply_date date;
  BEGIN
   if ( p_plan_id is null OR p_inst_id is null or p_demand_id is null ) then
    return to_date(null);
   end if;

    OPEN dmd_cur;
    FETCH dmd_cur INTO p_supply_date;
    CLOSE dmd_cur;
    return p_supply_date;
  END substitute_supply_date;

END msc_exp_wf;

/
