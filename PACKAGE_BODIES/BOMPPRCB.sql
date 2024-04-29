--------------------------------------------------------
--  DDL for Package Body BOMPPRCB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPPRCB" as
/* $Header: BOMPRCBB.pls 115.6 2002/10/31 07:33:35 djebar ship $ */
function bmprobm_process_bom
(       ato_flag   in   NUMBER,
	prg_appid  in   NUMBER,
        prg_id     in   NUMBER,
        req_id     in   NUMBER,
        user_id    in   NUMBER,
        login_id   in   NUMBER,
        error_message  out      VARCHAR2,
        message_name   out      VARCHAR2,
        table_name     out      VARCHAR2)
return integer
is
	stmt_num    number;
BEGIN

	/*
	** process bom interface table
	*/
	stmt_num := 10;
	table_name := 'BOM_BILL_OF_MATERIALS';
        insert into BOM_BILL_OF_MATERIALS(
                        assembly_item_id,
                        organization_id,
                        alternate_bom_designator,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        specific_assembly_comment,
                        pending_from_ecn,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        assembly_type,
                        common_bill_sequence_id,
                        bill_sequence_id,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date
                        )
                select
                        b.assembly_item_id,
                        b.organization_id,
                        b.alternate_bom_designator,
                        b.last_update_date,
                        user_id,	/* last_updated_by */
                        b.creation_date,
                        user_id,	/* created_by */
                        login_id,	/* last_update_login */
                        b.specific_assembly_comment,
                        b.pending_from_ecn,
                        b.attribute_category,
                        b.attribute1,
                        b.attribute2,
                        b.attribute3,
                        b.attribute4,
                        b.attribute5,
                        b.attribute6,
                        b.attribute7,
                        b.attribute8,
                        b.attribute9,
                        b.attribute10,
                        b.attribute11,
                        b.attribute12,
                        b.attribute13,
                        b.attribute14,
                        b.attribute15,
                        b.assembly_type,
                        b.common_bill_sequence_id,
                        b.bill_sequence_id,
                        req_id,	/* request_id */
                        prg_appid,	/* program_application_id */
                        prg_id,	/* program_id */
                        SYSDATE		/* program_update_date */
                from   BOM_BILL_OF_MTLS_INTERFACE b
                where  b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

		/*
		** Process inventory components interface table
		*/

		stmt_num := 20;
		table_name := 'BOM_INVENTORY_COMPONENTS';
                insert into BOM_INVENTORY_COMPONENTS
                        (
                        OPERATION_SEQ_NUM,
                        COMPONENT_ITEM_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        ITEM_NUM,
                        COMPONENT_QUANTITY,
                        COMPONENT_YIELD_FACTOR,
                        COMPONENT_REMARKS,
                        EFFECTIVITY_DATE,
                        CHANGE_NOTICE,
                        IMPLEMENTATION_DATE,
                        DISABLE_DATE,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        PLANNING_FACTOR,
                        QUANTITY_RELATED,
                        SO_BASIS,
                        OPTIONAL,
                        MUTUALLY_EXCLUSIVE_OPTIONS,
                        INCLUDE_IN_COST_ROLLUP,
                        CHECK_ATP,
                        SHIPPING_ALLOWED,
                        REQUIRED_TO_SHIP,
                        REQUIRED_FOR_REVENUE,
                        INCLUDE_ON_SHIP_DOCS,
                        INCLUDE_ON_BILL_DOCS,
                        LOW_QUANTITY,
                        HIGH_QUANTITY,
                        ACD_TYPE,
                        OLD_COMPONENT_SEQUENCE_ID,
                        COMPONENT_SEQUENCE_ID,
                        BILL_SEQUENCE_ID,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        WIP_SUPPLY_TYPE,
                        OPERATION_LEAD_TIME_PERCENT,
                        REVISED_ITEM_SEQUENCE_ID,
                        SUPPLY_LOCATOR_ID,
                        SUPPLY_SUBINVENTORY,
                        PICK_COMPONENTS,
			BOM_ITEM_TYPE
                        )
                        select
                        b.OPERATION_SEQ_NUM,
                        b.COMPONENT_ITEM_ID,
                        b.LAST_UPDATE_DATE,
                        user_id,	/* LAST_UPDATED_BY */
                        b.CREATION_DATE,
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                        b.ITEM_NUM,
                        b.COMPONENT_QUANTITY,
                        b.COMPONENT_YIELD_FACTOR,
                        b.COMPONENT_REMARKS,
                        b.EFFECTIVITY_DATE,
                        b.CHANGE_NOTICE,
                        b.IMPLEMENTATION_DATE,
                        b.DISABLE_DATE,
                        b.ATTRIBUTE_CATEGORY,
                        b.ATTRIBUTE1,
                        b.ATTRIBUTE2,
                        b.ATTRIBUTE3,
                        b.ATTRIBUTE4,
                        b.ATTRIBUTE5,
                        b.ATTRIBUTE6,
                        b.ATTRIBUTE7,
                        b.ATTRIBUTE8,
                        b.ATTRIBUTE9,
                        b.ATTRIBUTE10,
                        b.ATTRIBUTE11,
                        b.ATTRIBUTE12,
                        b.ATTRIBUTE13,
                        b.ATTRIBUTE14,
                        b.ATTRIBUTE15,
                        b.PLANNING_FACTOR,
                        b.QUANTITY_RELATED,
                        b.SO_BASIS,
                        b.OPTIONAL,
                        b.MUTUALLY_EXCLUSIVE_OPTIONS,
                        b.INCLUDE_IN_COST_ROLLUP,
                        b.CHECK_ATP,
                        b.SHIPPING_ALLOWED,
                        b.REQUIRED_TO_SHIP,
                        b.REQUIRED_FOR_REVENUE,
                        b.INCLUDE_ON_SHIP_DOCS,
                        b.INCLUDE_ON_BILL_DOCS,
                        b.LOW_QUANTITY,
                        b.HIGH_QUANTITY,
                        b.ACD_TYPE,
                        b.OLD_COMPONENT_SEQUENCE_ID,
                        b.COMPONENT_SEQUENCE_ID,
                        b.BILL_SEQUENCE_ID,
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE,         /* program_update_date */
                        b.WIP_SUPPLY_TYPE,
                        b.OPERATION_LEAD_TIME_PERCENT,
                        b.REVISED_ITEM_SEQUENCE_ID,
                        b.SUPPLY_LOCATOR_ID,
                        b.SUPPLY_SUBINVENTORY,
                        b.PICK_COMPONENTS,
			i.BOM_ITEM_TYPE
			from   MTL_SYSTEM_ITEMS i,
                               BOM_INVENTORY_COMPS_INTERFACE b,
                               BOM_BILL_OF_MTLS_INTERFACE b1
                        where  b.bill_sequence_id = b1.bill_sequence_id
			and    b1.organization_id = i.organization_id
			and    b.component_item_id = i.inventory_item_id
                        and    b1.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));


		/*
		** Process reference designators interface table
		*/
		stmt_num := 40;
		table_name := 'BOM_REFERENCE_DESIGNATORS';
                insert into BOM_REFERENCE_DESIGNATORS
                        (
                         COMPONENT_REFERENCE_DESIGNATOR,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         REF_DESIGNATOR_COMMENT,
                         CHANGE_NOTICE  ,
                         COMPONENT_SEQUENCE_ID,
                         ACD_TYPE,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1     ,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15
                        )
                        select
                         b1.COMPONENT_REFERENCE_DESIGNATOR,
                         b1.LAST_UPDATE_DATE,
                         user_id,	/* LAST_UPDATED_BY */
                         b1.CREATION_DATE,
                         user_id,       /* created_by */
                         login_id,      /* last_update_login */
                         b1.REF_DESIGNATOR_COMMENT,
                         b1.CHANGE_NOTICE  ,
                         b1.COMPONENT_SEQUENCE_ID,
                         b1.ACD_TYPE,
                         req_id,        /* request_id */
                         prg_appid,     /* program_application_id */
                         prg_id,        /* program_id */
                         SYSDATE,         /* program_update_date */
                         b1.ATTRIBUTE_CATEGORY,
                         b1.ATTRIBUTE1     ,
                         b1.ATTRIBUTE2,
                         b1.ATTRIBUTE3,
                         b1.ATTRIBUTE4,
                         b1.ATTRIBUTE5,
                         b1.ATTRIBUTE6,
                         b1.ATTRIBUTE7,
                         b1.ATTRIBUTE8,
                         b1.ATTRIBUTE9,
                         b1.ATTRIBUTE10,
                         b1.ATTRIBUTE11,
                         b1.ATTRIBUTE12,
                         b1.ATTRIBUTE13,
                         b1.ATTRIBUTE14,
                         b1.ATTRIBUTE15
                        from    BOM_REF_DESGS_INTERFACE b1,
                                BOM_INVENTORY_COMPS_INTERFACE b2,
                                BOM_BILL_OF_MTLS_INTERFACE b3
                        where   b1.component_sequence_id = b2.component_sequence_id
                        and     b2.bill_sequence_id = b3.bill_sequence_id
                        and     b3.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

		/*
		** Process substitute components interface table
		*/
		stmt_num := 50;
		table_name := 'BOM_SUBSTITUTE_COMPONENTS';
                insert into BOM_SUBSTITUTE_COMPONENTS
                        (
                         SUBSTITUTE_COMPONENT_ID,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         SUBSTITUTE_ITEM_QUANTITY,
                         ACD_TYPE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2     ,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         CHANGE_NOTICE  ,
                         COMPONENT_SEQUENCE_ID,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE
                        )
                        select
                         b1.SUBSTITUTE_COMPONENT_ID,
                         b1.LAST_UPDATE_DATE,
                         user_id,	/* LAST_UPDATED_BY */
                         b1.CREATION_DATE,
                         user_id,       /* created_by */
                         login_id,      /* last_update_login */
                         b1.SUBSTITUTE_ITEM_QUANTITY,
                         b1.ACD_TYPE,
                         b1.ATTRIBUTE_CATEGORY,
                         b1.ATTRIBUTE1,
                         b1.ATTRIBUTE2     ,
                         b1.ATTRIBUTE3,
                         b1.ATTRIBUTE4,
                         b1.ATTRIBUTE5,
                         b1.ATTRIBUTE6,
                         b1.ATTRIBUTE7,
                         b1.ATTRIBUTE8,
                         b1.ATTRIBUTE9,
                         b1.ATTRIBUTE10,
                         b1.ATTRIBUTE11,
                         b1.ATTRIBUTE12,
                         b1.ATTRIBUTE13,
                         b1.ATTRIBUTE14,
                         b1.ATTRIBUTE15,
                         b1.CHANGE_NOTICE,
                         b1.COMPONENT_SEQUENCE_ID,
                         req_id,        /* request_id */
                         prg_appid,     /* program_application_id */
                         prg_id,        /* program_id */
                         SYSDATE         /* program_update_date */
                        from    BOM_SUB_COMPS_INTERFACE b1,
                                BOM_INVENTORY_COMPS_INTERFACE b2,
                                BOM_BILL_OF_MTLS_INTERFACE b3
                        where   b1.component_sequence_id = b2.component_sequence_id
                        and     b2.bill_sequence_id = b3.bill_sequence_id
                        and     b3.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

        return(1);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return(1);
        WHEN OTHERS THEN
                error_message := 'BOMPPRCB:'||to_char(stmt_num)||':'|| substrb(sqlerrm,1,150);
                message_name := 'BOM_ATO_PROCESS_ERROR';
                return(0);

    END bmprobm_process_bom;


function bmprort_process_rtg
(       ato_flag   in   NUMBER,
        perform_fc in   NUMBER,
	prg_appid  in   NUMBER,
        prg_id     in   NUMBER,
        req_id     in   NUMBER,
        user_id    in   NUMBER,
        login_id   in   NUMBER,
        error_message  out      VARCHAR2,
        message_name   out      VARCHAR2,
        table_name     out      VARCHAR2)
return integer
is
	      stmt_num        number;
              x_install_cfm   BOOLEAN;
              x_status        VARCHAR2(1);
              x_industry      VARCHAR2(1);
              x_schema        VARCHAR2(30);
              l_routing       number;

             cursor allRoutings is
             select organization_id, routing_sequence_id,cfm_routing_flag
             from   bom_op_routings_interface b
             where  b.set_id           =  to_char(to_number(USERENV('SESSIONID')));

             cursor allops is
             select operation_sequence_id, model_op_seq_id
             from bom_op_sequences_interface
             where routing_sequence_id = l_routing;

BEGIN

		/*
		** Process routing header interface table
		*/
		stmt_num := 60;
		table_name := 'BOM_OPERATIONAL_ROUTINGS';
                insert into BOM_OPERATIONAL_ROUTINGS
                         (
                         ROUTING_SEQUENCE_ID,
                         ASSEMBLY_ITEM_ID,
                         ORGANIZATION_ID,
                         ALTERNATE_ROUTING_DESIGNATOR,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         ROUTING_TYPE,
                         COMMON_ROUTING_SEQUENCE_ID,
			 COMMON_ASSEMBLY_ITEM_ID,
                         ROUTING_COMMENT,
                         COMPLETION_SUBINVENTORY,
                         COMPLETION_LOCATOR_ID,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE,
                         LINE_ID,
                         CFM_ROUTING_FLAG,
                         MIXED_MODEL_MAP_FLAG,
                         PRIORITY,
                         TOTAL_PRODUCT_CYCLE_TIME,
                         CTP_FLAG
                         )
                        select
                         b.ROUTING_SEQUENCE_ID,
                         b.ASSEMBLY_ITEM_ID,
                         b.ORGANIZATION_ID,
                         b.ALTERNATE_ROUTING_DESIGNATOR,
                         b.LAST_UPDATE_DATE,
                         user_id,	/* LAST_UPDATED_BY */
                         b.CREATION_DATE,
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                         b.ROUTING_TYPE,
                         b.COMMON_ROUTING_SEQUENCE_ID,
			 b.COMMON_ASSEMBLY_ITEM_ID,
                         b.ROUTING_COMMENT,
                         b.COMPLETION_SUBINVENTORY,
                         b.COMPLETION_LOCATOR_ID,
                         b.ATTRIBUTE_CATEGORY,
                         b.ATTRIBUTE1,
                         b.ATTRIBUTE2,
                         b.ATTRIBUTE3,
                         b.ATTRIBUTE4,
                         b.ATTRIBUTE5,
                         b.ATTRIBUTE6,
                         b.ATTRIBUTE7,
                         b.ATTRIBUTE8,
                         b.ATTRIBUTE9,
                         b.ATTRIBUTE10,
                         b.ATTRIBUTE11,
                         b.ATTRIBUTE12,
                         b.ATTRIBUTE13,
                         b.ATTRIBUTE14,
                         b.ATTRIBUTE15,
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE,         /* program_update_date */
                         line_id,
                         cfm_routing_flag,
                         mixed_model_map_flag,
                         priority,
                         total_product_cycle_time,
                         ctp_flag
                        from   BOM_OP_ROUTINGS_INTERFACE b
                        where  b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

             /*
             ** Process routing revision interface table
             */
		stmt_num := 70;
	    table_name := 'MTL_RTG_ITEM_REVISIONS';
            insert into MTL_RTG_ITEM_REVISIONS
			(
                         INVENTORY_ITEM_ID,
                         ORGANIZATION_ID,
                         PROCESS_REVISION,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         CHANGE_NOTICE  ,
                         ECN_INITIATION_DATE,
                         IMPLEMENTATION_DATE,
                         IMPLEMENTED_SERIAL_NUMBER,
                         EFFECTIVITY_DATE       ,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1     ,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13 ,
                         ATTRIBUTE14,
                         ATTRIBUTE15
			)
			select
                         ASSEMBLY_ITEM_ID,
                         ORGANIZATION_ID,
                         PROCESS_REVISION,
                         SYSDATE,	/* LAST_UPDATE_DATE */
                         user_id,	/* LAST_UPDATED_BY */
                         SYSDATE,	/* CREATION_DATE */
                        user_id,       /* created_by */
                        login_id,      /* last_update_login */
                         NULL,		/* CHANGE_NOTICE  */
                         NULL,		/* ECN_INITIATION_DATE */
                         TRUNC(SYSDATE), /* IMPLEMENTATION_DATE */
                         NULL,		/* IMPLEMENTED_SERIAL_NUMBER */
                         TRUNC(SYSDATE), /* EFFECTIVITY_DATE  */
                         NULL,		/* ATTRIBUTE_CATEGORY */
                         NULL,          /* ATTRIBUTE1  */
                         NULL,          /* ATTRIBUTE2 */
                         NULL,          /* ATTRIBUTE3 */
                         NULL,          /* ATTRIBUTE4 */
                         NULL,          /* ATTRIBUTE5 */
                         NULL,          /* ATTRIBUTE6 */
                         NULL,          /* ATTRIBUTE7 */
                         NULL,          /* ATTRIBUTE8 */
                         NULL,          /* ATTRIBUTE9 */
                         NULL,          /* ATTRIBUTE10 */
                         NULL,          /* ATTRIBUTE11 */
                         NULL,          /* ATTRIBUTE12 */
                         NULL,          /* ATTRIBUTE13 */
                         NULL,          /* ATTRIBUTE14 */
                         NULL          /* ATTRIBUTE15 */
			from bom_op_routings_interface
			where set_id =  TO_CHAR(to_number(USERENV('SESSIONID')));

		/*
		** Process operation sequences interface table
		*/
		stmt_num := 80;
		table_name := 'BOM_OPERATION_SEQUENCES';
                insert into BOM_OPERATION_SEQUENCES
                        (
                         OPERATION_SEQUENCE_ID,
                         ROUTING_SEQUENCE_ID,
                         OPERATION_SEQ_NUM,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         STANDARD_OPERATION_ID,
                         DEPARTMENT_ID  ,
                         OPERATION_LEAD_TIME_PERCENT,
                         MINIMUM_TRANSFER_QUANTITY,
                         COUNT_POINT_TYPE       ,
                         OPERATION_DESCRIPTION,
                         EFFECTIVITY_DATE,
                         DISABLE_DATE   ,
                         BACKFLUSH_FLAG,
                         OPTION_DEPENDENT_FLAG,
                         ATTRIBUTE_CATEGORY     ,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE,
                         OPERATION_TYPE,
                         REFERENCE_FLAG,
                         PROCESS_OP_SEQ_ID,
                         LINE_OP_SEQ_ID,
                         YIELD,
                         CUMULATIVE_YIELD,
                         REVERSE_CUMULATIVE_YIELD,
                         LABOR_TIME_CALC,
                         MACHINE_TIME_CALC,
                         TOTAL_TIME_CALC,
                         LABOR_TIME_USER,
                         MACHINE_TIME_USER,
                         TOTAL_TIME_USER,
                         NET_PLANNING_PERCENT
                        )
                        select
                         b.OPERATION_SEQUENCE_ID,
                         b.ROUTING_SEQUENCE_ID,
                         b.OPERATION_SEQ_NUM,
                         b.LAST_UPDATE_DATE,
                         user_id,	/* LAST_UPDATED_BY */
                         b.CREATION_DATE,
                         user_id,       /* created_by */
                         login_id,      /* last_update_login */
                         b.STANDARD_OPERATION_ID,
                         b.DEPARTMENT_ID  ,
                         b.OPERATION_LEAD_TIME_PERCENT,
                         b.MINIMUM_TRANSFER_QUANTITY,
                         b.COUNT_POINT_TYPE       ,
                         b.OPERATION_DESCRIPTION,
                         b.EFFECTIVITY_DATE,
                         b.DISABLE_DATE   ,
			 b.BACKFLUSH_FLAG,
                         b.OPTION_DEPENDENT_FLAG,
                         b.ATTRIBUTE_CATEGORY     ,
                         b.ATTRIBUTE1,
                         b.ATTRIBUTE2,
                         b.ATTRIBUTE3,
                         b.ATTRIBUTE4,
                         b.ATTRIBUTE5,
                         b.ATTRIBUTE6,
                         b.ATTRIBUTE7,
                         b.ATTRIBUTE8,
                         b.ATTRIBUTE9,
                         b.ATTRIBUTE10,
                         b.ATTRIBUTE11,
                         b.ATTRIBUTE12,
                         b.ATTRIBUTE13,
                         b.ATTRIBUTE14,
                         b.ATTRIBUTE15,
                         req_id,        /* request_id */
                         prg_appid,     /* program_application_id */
                         prg_id,        /* program_id */
                         SYSDATE,         /* program_update_date */
                         operation_type,
                         reference_flag,
                         process_op_seq_id,
                         line_op_seq_id,
                         yield,
                         cumulative_yield,
                         reverse_cumulative_yield,
                         labor_time_calc,
                         machine_time_calc,
                         total_time_calc,
                         labor_time_user,
                         machine_time_user,
                         total_time_user,
                         net_planning_percent
                        from   BOM_OP_SEQUENCES_INTERFACE b,
                               BOM_OP_ROUTINGS_INTERFACE b1
                        where  b.routing_sequence_id = b1.routing_sequence_id
                        and    b1.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

		/*
		** Process operation resources interface table
		*/
		stmt_num := 90;
		table_name := 'BOM_OPERATION_RESOURCES';
                insert into BOM_OPERATION_RESOURCES
                        (
                         OPERATION_SEQUENCE_ID,
                         RESOURCE_SEQ_NUM,
                         RESOURCE_ID    ,
                         ACTIVITY_ID,
                         STANDARD_RATE_FLAG,
                         ASSIGNED_UNITS ,
                         USAGE_RATE_OR_AMOUNT,
                         USAGE_RATE_OR_AMOUNT_INVERSE,
                         BASIS_TYPE,
                         SCHEDULE_FLAG,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         RESOURCE_OFFSET_PERCENT,
                         AUTOCHARGE_TYPE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE
                        )
                        select
                         b1.OPERATION_SEQUENCE_ID,
                         b1.RESOURCE_SEQ_NUM,
                         b1.RESOURCE_ID    ,
                         b1.ACTIVITY_ID,
                         b1.STANDARD_RATE_FLAG,
                         b1.ASSIGNED_UNITS ,
                         b1.USAGE_RATE_OR_AMOUNT,
                         b1.USAGE_RATE_OR_AMOUNT_INVERSE,
                         b1.BASIS_TYPE,
                         b1.SCHEDULE_FLAG,
                         b1.LAST_UPDATE_DATE,
                         user_id,	/* LAST_UPDATED_BY */
                         b1.CREATION_DATE,
                         user_id,       /* created_by */
                         login_id,      /* last_update_login */
                         b1.RESOURCE_OFFSET_PERCENT,
			 b1.AUTOCHARGE_TYPE,
                         b1.ATTRIBUTE_CATEGORY,
                         b1.ATTRIBUTE1,
                         b1.ATTRIBUTE2,
                         b1.ATTRIBUTE3,
                         b1.ATTRIBUTE4,
                         b1.ATTRIBUTE5,
                         b1.ATTRIBUTE6,
                         b1.ATTRIBUTE7,
                         b1.ATTRIBUTE8,
                         b1.ATTRIBUTE9,
                         b1.ATTRIBUTE10,
                         b1.ATTRIBUTE11,
                         b1.ATTRIBUTE12,
                         b1.ATTRIBUTE13,
                         b1.ATTRIBUTE14,
                         b1.ATTRIBUTE15,
                         req_id,        /* request_id */
                         prg_appid,     /* program_application_id */
                         prg_id,        /* program_id */
                         SYSDATE         /* program_update_date */
                        from    BOM_OP_RESOURCES_INTERFACE b1,
                                BOM_OP_SEQUENCES_INTERFACE b2,
                                BOM_OP_ROUTINGS_INTERFACE b3
                        where   b2.operation_sequence_id = b1.operation_sequence_id
                        and     b2.routing_sequence_id = b3.routing_sequence_id
                        and     b3.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

		/*
		** Process operation Networks table
		*/
		stmt_num := 95;
		table_name := 'BOM_OPERATION_NETWORKS';

                       INSERT INTO bom_operation_networks
                       ( FROM_OP_SEQ_ID,
                         TO_OP_SEQ_ID,
                         TRANSITION_TYPE,
                         PLANNING_PCT,
                         EFFECTIVITY_DATE,
                         DISABLE_DATE,
                         CREATED_BY,
                         CREATION_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATE_LOGIN,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1  ,
                         ATTRIBUTE2  ,
                         ATTRIBUTE3  ,
                         ATTRIBUTE4  ,
                         ATTRIBUTE5  ,
                         ATTRIBUTE6  ,
                         ATTRIBUTE7  ,
                         ATTRIBUTE8  ,
                         ATTRIBUTE9  ,
                         ATTRIBUTE10 ,
                         ATTRIBUTE11 ,
                         ATTRIBUTE12 ,
                         ATTRIBUTE13 ,
                         ATTRIBUTE14 ,
                         ATTRIBUTE15
                       )
                       SELECT
	                bos3.operation_sequence_id,
	                bos4.operation_sequence_id,
                        bon.TRANSITION_TYPE,
                        bon.PLANNING_PCT,
                        bon.EFFECTIVITY_DATE,
                        bon.DISABLE_DATE,
                        bon.CREATED_BY,
                        bon.CREATION_DATE,
                        bon.LAST_UPDATED_BY,
                        bon.LAST_UPDATE_DATE,
                        bon.LAST_UPDATE_LOGIN,
                        bon.ATTRIBUTE_CATEGORY,
                        bon.ATTRIBUTE1,
                        bon.ATTRIBUTE2,
                        bon.ATTRIBUTE3,
                        bon.ATTRIBUTE4,
                        bon.ATTRIBUTE5,
                        bon.ATTRIBUTE6,
                        bon.ATTRIBUTE7,
                        bon.ATTRIBUTE8,
                        bon.ATTRIBUTE9,
                        bon.ATTRIBUTE10,
                        bon.ATTRIBUTE11,
                        bon.ATTRIBUTE12,
                        bon.ATTRIBUTE13,
                        bon.ATTRIBUTE14,
                        bon.ATTRIBUTE15
	               FROM  bom_operation_networks    bon,
	                     bom_operation_sequences   bos1, /* 'from'  Ops of model  */
	                     bom_operation_sequences   bos2, /* 'to'    Ops of model  */
	                     bom_operation_sequences   bos3, /* 'from'  Ops of config */
	                     bom_operation_sequences   bos4, /* 'to'    Ops of config */
                             bom_op_routings_interface  brif
	             WHERE   bon.from_op_seq_id         = bos1.operation_sequence_id
	             AND     bon.to_op_seq_id           = bos2.operation_sequence_id
	             AND     bos1.routing_sequence_id   = bos2.routing_sequence_id
	             AND     bos3.routing_sequence_id   = brif.routing_sequence_id
                     AND     brif.cfm_routing_flag      = 1
                     AND     brif.set_id                = to_char(to_number(USERENV('SESSIONID')))
	             AND     bos3.operation_seq_num     = bos1.operation_seq_num
                     AND     NVL(bos3.operation_type,1) = NVL(bos1.operation_type, 1)
	             AND     bos4.routing_sequence_id   = bos3.routing_sequence_id
	             AND     bos4.operation_seq_num     = bos2.operation_seq_num
	             AND     NVL(bos4.operation_type,1) = NVL(bos2.operation_type, 1)
	             AND     bos1.routing_sequence_id   = (     /* find the model routing */
                             select routing_sequence_id
                             from   bom_operational_routings   bor,
                                    mtl_system_items_interface msi
                             where  brif.assembly_item_id = msi.inventory_item_id
                             and    brif.organization_id  = msi.organization_id
                             and    bor.assembly_item_id  = msi.copy_item_id
                             and    bor.organization_id   = msi.organization_id
                             and    bor.cfm_routing_flag  = 1
                             and    bor.alternate_routing_designator is null );



    	    stmt_num := 95;

           /** Check if flow_manufacturing is installed **/

            x_install_cfm := Fnd_Installation.Get_App_Info(application_short_name => 'FLM',
                                                            status      => x_status,
                                                            industry    => x_industry,
                                                            oracle_schema => x_schema);

             for nextrec in allRoutings loop
                 l_routing := nextrec.routing_sequence_id;

                 /*  For each operation in each routing, copy attachments of operations
                 **  copied from model/option class to operations on the config item
                 */

                 for nextop in allops loop

                     FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
                        X_from_entity_name              =>'BOM_OPERATION_SEQUENCES',
                        X_from_pk1_value                =>nextop.model_op_seq_id,
                        X_from_pk2_value                =>'',
                        X_from_pk3_value                =>'',
                        X_from_pk4_value                =>'',
                        X_from_pk5_value                =>'',
                        X_to_entity_name                =>'BOM_OPERATION_SEQUENCES',
                        X_to_pk1_value                  =>nextop.operation_sequence_id,
                        X_to_pk2_value                  =>'',
                        X_to_pk3_value                  =>'',
                        X_to_pk4_value                  =>'',
                        X_to_pk5_value                  =>'',
                        X_created_by                    =>user_id,
                        X_last_update_login             =>'',
                        X_program_application_id        =>'',
                        X_program_id                    =>'',
                        X_request_id                    =>''
                        );
                     end loop;

                /** if flow manufacturing is installed and the 'Perform Flow Calulations'
                * parameter is set to 2 or 3 (perform calculations based on processes or perform
                * calulations based on Line operations) the routing is 'flow routing' then
                * calculate operation times, yields, net planning percent  and total
                * product cycle time for config routing
                **/

                      if ( x_status = 'I' and perform_fc >1 and nextrec.cfm_routing_flag = 1 ) then

                          /* Calculate Operation times */

                          BOM_CALC_OP_TIMES_PK.calculate_operation_times(
                              arg_org_id              => nextrec.organization_id,
                              arg_routing_sequence_id => nextrec.routing_sequence_id );

                          /* Calculate cumu yield, rev cumu yield and net plannning percent */

                          BOM_CALC_CYNP.calc_cynp(
                              p_routing_sequence_id => nextrec.routing_sequence_id,
                              p_operation_type      => perform_fc,      /* operation_type = process */
                              p_update_events       => 1 );     /* update events */

                         /* Calculate total_product_cycle_time */

                          BOM_CALC_TPCT.calculate_tpct(
                              p_routing_sequence_id => nextrec.routing_sequence_id,
                              p_operation_type      => perform_fc);      /* Operation_type = Process */
                    end if;
                end loop;
  return(1);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return(1);
        WHEN OTHERS THEN
        error_message:='BOMPPRCB:'||to_char(stmt_num)||':'||substrb(sqlerrm,1,150);
                message_name := 'BOM_ATO_PROCESS_ERROR';
                return(0);

    END bmprort_process_rtg;


function bmproec_process_eco
(	ato_flag   in   NUMBER,
        prg_appid  in   NUMBER,
        prg_id     in   NUMBER,
        req_id     in   NUMBER,
        user_id    in   NUMBER,
        login_id   in   NUMBER,
        error_message  out      VARCHAR2,
        message_name   out      VARCHAR2,
        table_name     out      VARCHAR2)
return integer
is
		stmt_num    number;
BEGIN
		/*
		** Process engineering changes interface table
		*/
		stmt_num := 110;
		table_name := 'ENG_ENGINEERING_CHANGES';
                insert into ENG_ENGINEERING_CHANGES
                        (
                         CHANGE_NOTICE,
                         ORGANIZATION_ID,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         DESCRIPTION    ,
                         STATUS_TYPE,
                         INITIATION_DATE,
                         IMPLEMENTATION_DATE,
                         CANCELLATION_DATE,
                         CANCELLATION_COMMENTS,
                         PRIORITY_CODE  ,
                         REASON_CODE,
                         ESTIMATED_ENG_COST,
                         ESTIMATED_MFG_COST,
                         REQUESTOR_ID   ,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE,
                         APPROVAL_DATE,
                         APPROVAL_STATUS_TYPE,
                         APPROVAL_LIST_ID,
			 CHANGE_ORDER_TYPE_ID,
			 RESPONSIBLE_ORGANIZATION_ID,
			 APPROVAL_REQUEST_DATE,
			 DDF_CONTEXT
                        )
                        select
                         CHANGE_NOTICE,
                         ORGANIZATION_ID,
                         LAST_UPDATE_DATE,
                         user_id,	/* LAST_UPDATED_BY */
                         CREATION_DATE,
                         user_id,       /* created_by */
                         login_id ,      /* last_update_login */
                         DESCRIPTION    ,
                         STATUS_TYPE,
                         INITIATION_DATE,
                         IMPLEMENTATION_DATE,
                         CANCELLATION_DATE,
                         CANCELLATION_COMMENTS,
                         PRIORITY_CODE  ,
                         REASON_CODE,
                         ESTIMATED_ENG_COST,
                         ESTIMATED_MFG_COST,
                         REQUESTOR_ID   ,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                        req_id,        /* request_id */
                        prg_appid,     /* program_application_id */
                        prg_id,        /* program_id */
                        SYSDATE,         /* program_update_date */
                         APPROVAL_DATE,
                         APPROVAL_STATUS_TYPE,
                         APPROVAL_LIST_ID,
                         CHANGE_ORDER_TYPE_ID,
                         RESPONSIBLE_ORGANIZATION_ID,
                         APPROVAL_REQUEST_DATE,
			 DDF_CONTEXT
                        from    ENG_ENG_CHANGES_INTERFACE
                        where   set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

		/*
		** Process revised items interface table
		*/
		stmt_num := 120;
		table_name := 'ENG_REVISED_ITEMS';
                insert into ENG_REVISED_ITEMS
                        (
                         CHANGE_NOTICE,
                         ORGANIZATION_ID,
                         REVISED_ITEM_ID,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         IMPLEMENTATION_DATE,
                         DESCRIPTIVE_TEXT,
                         CANCELLATION_DATE,
                         CANCEL_COMMENTS,
                         DISPOSITION_TYPE,
                         NEW_ITEM_REVISION,
                         AUTO_IMPLEMENT_DATE,
                         EARLY_SCHEDULE_DATE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4 ,
                         ATTRIBUTE5,
                         ATTRIBUTE6     ,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         STATUS_TYPE,
                         SCHEDULED_DATE,
                         BILL_SEQUENCE_ID,
                         MRP_ACTIVE     ,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE    ,
                         UPDATE_WIP     ,
                         USE_UP ,
                         USE_UP_ITEM_ID ,
                         REVISED_ITEM_SEQUENCE_ID,
			 USE_UP_PLAN_NAME
                        )
                        select
                         e.CHANGE_NOTICE,
                         e.ORGANIZATION_ID,
                         e.REVISED_ITEM_ID,
                         e.LAST_UPDATE_DATE,
                         user_id,	/* LAST_UPDATED_BY */
                         e.CREATION_DATE,
                         user_id,	/* CREATED_BY */
                         login_id,	/* LAST_UPDATE_LOGIN */
                         e.IMPLEMENTATION_DATE,
                         e.DESCRIPTIVE_TEXT,
                         e.CANCELLATION_DATE,
                         e.CANCEL_COMMENTS,
                         e.DISPOSITION_TYPE,
                         e.NEW_ITEM_REVISION,
                         e.AUTO_IMPLEMENT_DATE,
                         e.EARLY_SCHEDULE_DATE,
                         e.ATTRIBUTE_CATEGORY,
                         e.ATTRIBUTE1,
                         e.ATTRIBUTE2,
                         e.ATTRIBUTE3,
                         e.ATTRIBUTE4 ,
                         e.ATTRIBUTE5,
                         e.ATTRIBUTE6     ,
                         e.ATTRIBUTE7,
                         e.ATTRIBUTE8,
                         e.ATTRIBUTE9,
                         e.ATTRIBUTE10,
                         e.ATTRIBUTE11,
                         e.ATTRIBUTE12,
                         e.ATTRIBUTE13,
                         e.ATTRIBUTE14,
                         e.ATTRIBUTE15,
                         e.STATUS_TYPE,
                         e.SCHEDULED_DATE,
                         e.BILL_SEQUENCE_ID,
                         e.MRP_ACTIVE     ,
                         req_id,        /* request_id */
                         prg_appid,     /* program_application_id */
                         prg_id,        /* program_id */
                         SYSDATE,         /* program_update_date */
                         e.UPDATE_WIP     ,
                         e.USE_UP ,
                         e.USE_UP_ITEM_ID ,
                         e.REVISED_ITEM_SEQUENCE_ID,
			 e.USE_UP_PLAN_NAME
                        from    ENG_REVISED_ITEMS_INTERFACE e,
                                ENG_ENG_CHANGES_INTERFACE e1
                        where   e1.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                        and     e.change_notice = e1.change_notice
                        and     e.organization_id = e1.organization_id;

        return(1);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return(1);
        WHEN OTHERS THEN
        error_message:='BOMPPRCB:'||to_char(stmt_num)||':'|| substrb(sqlerrm,1,150);
                message_name := 'BOM_ATO_PROCESS_ERROR';
                return(0);

    END bmproec_process_eco;

function bmprobr_process_bom_rtg (
ato_flag   in out  NUMBER,
perform_fc in      NUMBER,
prg_appid  in out  NUMBER,
prg_id     in out  NUMBER,
req_id     in out  NUMBER,
user_id    in out  NUMBER,
login_id   in out  NUMBER,
error_message  out      VARCHAR2,
message_name   out      VARCHAR2,
table_name     out      VARCHAR2)
return integer
is
	status		number;
	stmt_num        number;
	PROCESS_ERROR   exception;
        x_from_sequence_id number;
        x_to_sequence_id   number;

        cursor allconfigs is
        select inventory_item_id, organization_id,copy_item_id
        from mtl_system_items_interface m
        where  m.set_id  =  to_char(to_number(USERENV('SESSIONID')));
BEGIN
	status := 1;	/* init status */

	stmt_num := 130;
	status := bmprobm_process_bom(
		ato_flag,
		prg_appid,
		prg_id,
		req_id,
		user_id,
		login_id,
		error_message,
		message_name,
		table_name );

    for nextconfig in allconfigs
    loop

    select  common_bill_sequence_id
    into    x_from_sequence_id
    from    bom_bill_of_materials
    where   assembly_item_id = nextconfig.copy_item_id
    and     organization_id  = nextconfig.organization_id
    and     alternate_bom_designator is NULL;


    select common_bill_sequence_id
    into   x_to_sequence_id
    from   bom_bill_of_materials
    where  assembly_item_id = nextconfig.inventory_item_id
    and    organization_id  = nextconfig.organization_id
    and    alternate_bom_designator is NULL;

    fnd_attached_documents2_pkg.copy_attachments(
                        X_from_entity_name      =>  'BOM_BILL_OF_MATERIALS',
                        X_from_pk1_value        =>  x_from_sequence_id,
                        X_from_pk2_value        =>  '',
                        X_from_pk3_value        =>  '',
                        X_from_pk4_value        =>  '',
                        X_from_pk5_value        =>  '',
                        X_to_entity_name        =>  'BOM_BILL_OF_MATERIALS',
                        X_to_pk1_value          =>  x_to_sequence_id,
                        X_to_pk2_value          =>  '',
                        X_to_pk3_value          =>  '',
                        X_to_pk4_value          =>  '',
                        X_to_pk5_value          =>  '',
                        X_created_by            =>  user_id,
                        X_last_update_login     =>  '',
                        X_program_application_id=>  '',
                        X_program_id            =>  '',
                        X_request_id            =>  ''
                    );
     end loop;

	if (status = 1) then
	   stmt_num := 140;
	   status := bmprort_process_rtg(
		ato_flag,
                perform_fc,
                prg_appid,
                prg_id,
                req_id,
                user_id,
                login_id,
                error_message,
                message_name,
                table_name );
	end if;

/*
As per discussion with Shreyas it is not known why we needed this stuff here
Probably it was coded as part of the open interface project
        if (status = 1) then
	   stmt_num := 150;
           status := bmproec_process_eco(
		ato_flag,
                prg_appid,
                prg_id,
                req_id,
                user_id,
                login_id,
                error_message,
                message_name,
                table_name );
        end if;
*/
	if (status = 1) then
                /*
		** Remove rows from BOM_INVENTORY_COMPS_INTERFACE
		*/
		stmt_num := 160;
		table_name := 'BOM_INVENTORY_COMPS_INTERFACE';
                delete from BOM_INVENTORY_COMPS_INTERFACE i
                        where   i.rowid in
                         ( select b1.rowid
                           from bom_inventory_comps_interface b1,
				BOM_BILL_OF_MTLS_INTERFACE b2
                           where b2.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
			   and   b1.bill_sequence_id = b2.bill_sequence_id);

                /*
		** Remove rows from BOM_BILL_OF_MTLS_INTERFACE
		*/
		stmt_num := 180;
		table_name := 'BOM_BILL_OF_MTLS_INTERFACE';
                delete from BOM_BILL_OF_MTLS_INTERFACE b
                        where   b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

                /*
		** Remove rows from BOM_OP_RESOURCES_INTERFACE
		*/
		stmt_num := 190;
		table_name := 'BOM_OP_RESOURCES_INTERFACE';
                delete from BOM_OP_RESOURCES_INTERFACE i
                        where   i.rowid in
                                 ( select b1.rowid from
				   bom_op_resources_interface b1,
                                   BOM_OP_SEQUENCES_INTERFACE b2,
                                   BOM_OP_ROUTINGS_INTERFACE b3
                                   where b3.routing_sequence_id = b2.routing_sequence_id
                                   and   b3.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
				   and   b1.operation_sequence_id = b2.operation_sequence_id);


                /*
		** Remove from BOM_OP_SEQUENCES_INTERFACE
                */
		stmt_num := 210;
		table_name := 'BOM_OP_SEQUENCES_INTERFACE';
                delete from BOM_OP_SEQUENCES_INTERFACE i
                        where   i.rowid in
                         ( select b1.rowid from
			     bom_op_sequences_interface b1,
                             BOM_OP_ROUTINGS_INTERFACE b2
                             where b2.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
			     and   b1.routing_sequence_id = b2.routing_sequence_id);


                /*
		** Remove the moved rows from BOM_OP_ROUTINGS_INTERFACE
                */

		stmt_num := 220;
		table_name := 'BOM_OP_ROUTINGS_INTERFACE';
                delete from BOM_OP_ROUTINGS_INTERFACE b
                        where  b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

		stmt_num := 230;
		table_name := 'BOM_REF_DESGS_INTERFACE';
                delete from BOM_REF_DESGS_INTERFACE b1
                        where b1.rowid in ( select b.rowid
                              from BOM_REF_DESGS_INTERFACE b,
			      BOM_INVENTORY_COMPS_INTERFACE b2,
                              BOM_BILL_OF_MTLS_INTERFACE b3,
                              MTL_SYSTEM_ITEMS_INTERFACE m
                              where   b.component_sequence_id = b2.component_sequence_id
                              and     b2.bill_sequence_id = b3.bill_sequence_id
                              and     b3.demand_source_line = m.demand_source_line
			      and     b3.demand_source_type = m.demand_source_type
			      and     b3.demand_source_header_id = m.demand_source_header_id
                              and     b3.assembly_item_id = m.inventory_item_id
                              and     b3.organization_id = m.organization_id
                              and    m.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

		stmt_num := 240;
		table_name := 'BOM_SUB_COMPS_INTERFACE';
                delete from BOM_SUB_COMPS_INTERFACE b1
                        where b1.rowid in ( select b.rowid
                              from BOM_SUB_COMPS_INTERFACE b,
			      BOM_INVENTORY_COMPS_INTERFACE b2,
                              BOM_BILL_OF_MTLS_INTERFACE b3,
                              MTL_SYSTEM_ITEMS_INTERFACE m
                              where   b.component_sequence_id = b2.component_sequence_id
                              and     b2.bill_sequence_id = b3.bill_sequence_id
                              and     b3.demand_source_line = m.demand_source_line
			      and     b3.demand_source_type = m.demand_source_type
			      and     b3.demand_source_header_id = m.demand_source_header_id
                              and     b3.assembly_item_id = m.inventory_item_id
                              and     b3.organization_id = m.organization_id
                             and     m.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

/*
This is commented out since we do not insert into these tables anyway
        	stmt_num := 250;
		table_name := 'ENG_REVISED_ITEMS_INTERFACE';
               delete from ENG_REVISED_ITEMS_INTERFACE
                        where exists ( select 1
                                from ENG_ENG_CHANGES_INTERFACE e,
                                     ENG_REVISED_ITEMS_INTERFACE e1
                                where e.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                                and   e.organization_id = e1.organization_id
                                and   e.change_notice = e1.change_notice);

		stmt_num := 260;
		table_name := 'ENG_ENG_CHANGES_INTERFACE';
                delete from ENG_ENG_CHANGES_INTERFACE
                        where set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

*/
	end if;
	return(status);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return(1);
	WHEN PROCESS_ERROR THEN
	error_message :='BOMPPRCB:'||to_char(stmt_num)||':'||substrb(sqlerrm,1,150);
                message_name := 'BOM_ATO_PROCESS_ERROR';
	        return(status);
        WHEN OTHERS THEN
        error_message:='BOMPPRCB:'||to_char(stmt_num)||':'|| substrb(sqlerrm,1,150);
                message_name := 'BOM_ATO_PROCESS_ERROR';
                return(status);

END bmprobr_process_bom_rtg;

function bmprbill_process_bill_data
(       prog_appid      	NUMBER,
        prog_id         	NUMBER,
        request_id       	NUMBER,
        user_id         	NUMBER,
        login_id        	NUMBER,
        error_message  OUT      VARCHAR2,
        message_name   OUT      VARCHAR2,
        table_name     OUT      VARCHAR2)
return integer
is
        stmt_num    number;
        commit_cnt  NUMBER;
BEGIN

/*
** process bill interface table
*/
        stmt_num := 10;
        table_name := 'BOM_BILL_OF_MATERIALS';
        commit_cnt := 0;
        loop
        insert into BOM_BILL_OF_MATERIALS(
                        assembly_item_id,
                        organization_id,
                        alternate_bom_designator,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
			common_assembly_item_id,
                        specific_assembly_comment,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        assembly_type,
                        common_bill_sequence_id,
                        bill_sequence_id,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
			common_organization_id,
			next_explode_date
                        )
                select
                        assembly_item_id,
                        organization_id,
                        alternate_bom_designator,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
			common_assembly_item_id,
                        specific_assembly_comment,
                        attribute_category,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15,
                        assembly_type,
                        common_bill_sequence_id,
                        bill_sequence_id,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
			common_organization_id,
			next_explode_date
                from   BOM_BILL_OF_MTLS_INTERFACE
                where  process_flag = 4
 		  and  rownum < 500;

 	     EXIT when SQL%NOTFOUND;

             update bom_bill_of_mtls_interface bi
                set process_flag = 7
              where process_flag = 4
 	        and exists (select NULL
			      from bom_bill_of_materials bom
			     where bom.bill_sequence_id = bi.bill_sequence_id);
             commit;

       end loop;
/*
** Process inventory components interface table
*/
        stmt_num := 20;
        table_name := 'BOM_INVENTORY_COMPONENTS';
        commit_cnt := 0;
        loop
                insert into BOM_INVENTORY_COMPONENTS
                        (
                        OPERATION_SEQ_NUM,
                        COMPONENT_ITEM_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        ITEM_NUM,
                        COMPONENT_QUANTITY,
                        COMPONENT_YIELD_FACTOR,
                        COMPONENT_REMARKS,
                        EFFECTIVITY_DATE,
			CHANGE_NOTICE,
                        IMPLEMENTATION_DATE,
                        DISABLE_DATE,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        PLANNING_FACTOR,
                        QUANTITY_RELATED,
                        SO_BASIS,
                        OPTIONAL,
                        MUTUALLY_EXCLUSIVE_OPTIONS,
                        INCLUDE_IN_COST_ROLLUP,
                        CHECK_ATP,
                        SHIPPING_ALLOWED,
                        REQUIRED_TO_SHIP,
                        REQUIRED_FOR_REVENUE,
                        INCLUDE_ON_SHIP_DOCS,
                        LOW_QUANTITY,
                        HIGH_QUANTITY,
                        COMPONENT_SEQUENCE_ID,
                        BILL_SEQUENCE_ID,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        WIP_SUPPLY_TYPE,
                        SUPPLY_LOCATOR_ID,
                        SUPPLY_SUBINVENTORY,
                        BOM_ITEM_TYPE
                        )
                        select
                        OPERATION_SEQ_NUM,
                        COMPONENT_ITEM_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        created_by,
                        last_update_login,
                        ITEM_NUM,
                        COMPONENT_QUANTITY,
                        COMPONENT_YIELD_FACTOR,
                        COMPONENT_REMARKS,
                        EFFECTIVITY_DATE,
			CHANGE_NOTICE,
                        IMPLEMENTATION_DATE,
                        DISABLE_DATE,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        PLANNING_FACTOR,
                        QUANTITY_RELATED,
                        SO_BASIS,
                        OPTIONAL,
                        MUTUALLY_EXCLUSIVE_OPTIONS,
                        INCLUDE_IN_COST_ROLLUP,
                        CHECK_ATP,
                        SHIPPING_ALLOWED,
                        REQUIRED_TO_SHIP,
                        REQUIRED_FOR_REVENUE,
                        INCLUDE_ON_SHIP_DOCS,
                        LOW_QUANTITY,
                        HIGH_QUANTITY,
                        COMPONENT_SEQUENCE_ID,
                        BILL_SEQUENCE_ID,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        WIP_SUPPLY_TYPE,
                        SUPPLY_LOCATOR_ID,
                        SUPPLY_SUBINVENTORY,
                        BOM_ITEM_TYPE
                        from   BOM_INVENTORY_COMPS_INTERFACE
                        where process_flag = 4
                          and  rownum < 500;

             EXIT when SQL%NOTFOUND;

             update bom_inventory_comps_interface bci
                set process_flag = 7
              where process_flag = 4
                and exists (select NULL
			      from bom_inventory_components bic
                 where  bic.component_sequence_id = bci.component_sequence_id);

             commit;

          end loop;

/*
** Process reference designators interface table
*/
                stmt_num := 40;
                table_name := 'BOM_REFERENCE_DESIGNATORS';
                commit_cnt := 0;
                loop
                insert into BOM_REFERENCE_DESIGNATORS
                        (
                         COMPONENT_REFERENCE_DESIGNATOR,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         REF_DESIGNATOR_COMMENT,
			 CHANGE_NOTICE,
                         COMPONENT_SEQUENCE_ID,
			 ACD_TYPE,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15
                        )
                        select
                         COMPONENT_REFERENCE_DESIGNATOR,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         created_by,
                         last_update_login,
                         REF_DESIGNATOR_COMMENT,
			 CHANGE_NOTICE,
                         COMPONENT_SEQUENCE_ID,
			 ACD_TYPE,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15
                        from    BOM_REF_DESGS_INTERFACE
                        where   process_flag = 4
                          and  rownum < 500;

                EXIT when SQL%NOTFOUND;

                update bom_ref_desgs_interface bdi
                   set process_flag = 7
                 where process_flag = 4
		   and exists (select NULL from bom_reference_designators brd
                  where brd.component_sequence_id = bdi.component_sequence_id
                    and brd.component_reference_designator = bdi.component_reference_designator
                    and nvl(brd.acd_type,999) =nvl(bdi.acd_type,999));
                commit;
          end loop;

/*
** Process substitute components interface table
*/
                stmt_num := 50;
                table_name := 'BOM_SUBSTITUTE_COMPONENTS';
		commit_cnt := 0;
		loop
                insert into BOM_SUBSTITUTE_COMPONENTS
                        (
                         SUBSTITUTE_COMPONENT_ID,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATE_LOGIN,
                         SUBSTITUTE_ITEM_QUANTITY,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         COMPONENT_SEQUENCE_ID,
			 CHANGE_NOTICE,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE
                        )
                        select
                         SUBSTITUTE_COMPONENT_ID,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         CREATION_DATE,
                         created_by,
                         last_update_login,
                         SUBSTITUTE_ITEM_QUANTITY,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         COMPONENT_SEQUENCE_ID,
			 CHANGE_NOTICE,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID     ,
                         PROGRAM_UPDATE_DATE
                        from    BOM_SUB_COMPS_INTERFACE
			where process_flag = 4
			  and  rownum < 500;

                EXIT when SQL%NOTFOUND;

                update bom_sub_comps_interface bsi
                   set process_flag = 7
                 where process_flag = 4
                   and exists (select NULL from bom_substitute_components bsc
		   where bsc.component_sequence_id = bsi.component_sequence_id
                  and bsc.substitute_component_id = bsi.substitute_component_id
                  and nvl(bsc.acd_type,999) = nvl(bsi.acd_type,999));
                commit;
            end loop;

/*
** Process item revisions interface table
*/
                stmt_num := 60;
                table_name := 'MTL_ITEM_REVISIONS';
                commit_cnt := 0;
                loop
                insert into MTL_ITEM_REVISIONS
                        (
			INVENTORY_ITEM_ID,
			ORGANIZATION_ID,
			REVISION,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			CHANGE_NOTICE,
			IMPLEMENTATION_DATE,
			EFFECTIVITY_DATE,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
			PROGRAM_APPLICATION_ID,
			PROGRAM_ID,
			PROGRAM_UPDATE_DATE,
			REQUEST_ID,
			DESCRIPTION)
			select
			INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        REVISION,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
			CHANGE_NOTICE,
                        IMPLEMENTATION_DATE,
                        EFFECTIVITY_DATE,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        REQUEST_ID,
                        DESCRIPTION
			from mtl_item_revisions_interface
                        where process_flag = 4
                          and  rownum < 500;

                EXIT when SQL%NOTFOUND;

                update mtl_item_revisions_interface mri
                   set process_flag = 7
                 where process_flag = 4
                   and exists (select NULL from mtl_item_revisions mir
                   where mir.inventory_item_id = mri.inventory_item_id
                  and mir.organization_id = mri.organization_id
                  and mir.revision = mri.revision);
                commit;
            end loop;

        return(1);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return(1);
        WHEN OTHERS THEN
                rollback;
  error_message := 'BOMPPRCB:'||to_char(stmt_num)||':'|| substrb(sqlerrm,1,150);
                message_name := 'BOM_BILL_PROCESS_ERROR';
                return(SQLCODE);

    END bmprbill_process_bill_data;

function bmprrtg_process_rtg_data
(       prog_appid              NUMBER,
        prog_id                 NUMBER,
        request_id              NUMBER,
        user_id                 NUMBER,
        login_id                NUMBER,
        error_message  OUT      VARCHAR2,
        message_name   OUT      VARCHAR2,
        table_name     OUT      VARCHAR2)
return integer
is
        stmt_num    number;
BEGIN

/*
** process routing interface table
*/
        stmt_num := 10;
        table_name := 'BOM_OPERATIONAL_ROUTINGS';
        loop
        insert into BOM_OPERATIONAL_ROUTINGS(
		ROUTING_SEQUENCE_ID,
		ASSEMBLY_ITEM_ID,
		ORGANIZATION_ID,
		ALTERNATE_ROUTING_DESIGNATOR,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		ROUTING_TYPE,
		COMMON_ASSEMBLY_ITEM_ID,
		COMMON_ROUTING_SEQUENCE_ID,
		ROUTING_COMMENT,
		COMPLETION_SUBINVENTORY,
		COMPLETION_LOCATOR_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE
		)
                select
                ROUTING_SEQUENCE_ID,
                ASSEMBLY_ITEM_ID,
                ORGANIZATION_ID,
                ALTERNATE_ROUTING_DESIGNATOR,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                ROUTING_TYPE,
                COMMON_ASSEMBLY_ITEM_ID,
                COMMON_ROUTING_SEQUENCE_ID,
                ROUTING_COMMENT,
                COMPLETION_SUBINVENTORY,
                COMPLETION_LOCATOR_ID,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE
                from   BOM_OP_ROUTINGS_INTERFACE
                where  process_flag = 4
		  and  rownum < 500;

             EXIT when SQL%NOTFOUND;

                update bom_op_routings_interface bri
                   set process_flag = 7
                 where process_flag = 4
                   and exists (select NULL from bom_operational_routings bor
  				where bor.routing_sequence_id =
						bri.routing_sequence_id);
                commit;
         end loop;
/*
** Process operation sequences interface tables
*/

                stmt_num := 20;
                table_name := 'BOM_OPERATION_SEQUENCES';
		loop
                insert into BOM_OPERATION_SEQUENCES
                        (
			OPERATION_SEQUENCE_ID,
			ROUTING_SEQUENCE_ID,
			OPERATION_SEQ_NUM,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			STANDARD_OPERATION_ID,
			DEPARTMENT_ID,
			OPERATION_LEAD_TIME_PERCENT,
			MINIMUM_TRANSFER_QUANTITY,
			COUNT_POINT_TYPE,
			OPERATION_DESCRIPTION,
			EFFECTIVITY_DATE,
			DISABLE_DATE,
			BACKFLUSH_FLAG,
			OPTION_DEPENDENT_FLAG,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
			REQUEST_ID,
			PROGRAM_APPLICATION_ID,
			PROGRAM_ID,
			PROGRAM_UPDATE_DATE
			)
		select
                        OPERATION_SEQUENCE_ID,
                        ROUTING_SEQUENCE_ID,
                        OPERATION_SEQ_NUM,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        STANDARD_OPERATION_ID,
                        DEPARTMENT_ID,
                        OPERATION_LEAD_TIME_PERCENT,
                        MINIMUM_TRANSFER_QUANTITY,
                        COUNT_POINT_TYPE,
                        OPERATION_DESCRIPTION,
--			trunc(EFFECTIVITY_DATE),  -- Changed for bug 2647027
--			trunc(DISABLE_DATE),
                        EFFECTIVITY_DATE,
                        DISABLE_DATE,
                        BACKFLUSH_FLAG,
                        OPTION_DEPENDENT_FLAG,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE
                from   BOM_OP_SEQUENCES_INTERFACE
                where  process_flag = 4
		  and  rownum < 500;

             EXIT when SQL%NOTFOUND;

                update bom_op_sequences_interface bsi
                   set process_flag = 7
                 where process_flag = 4
		   and exists (select NULL from bom_operation_sequences bos
				where bos.operation_sequence_id =
				      bsi.operation_sequence_id);
                commit;
          end loop;


/*
** Process operation resources interface table
*/
                stmt_num := 40;
                table_name := 'BOM_OPERATION_RESOURCES';
		loop
                insert into BOM_OPERATION_RESOURCES
                        (
			OPERATION_SEQUENCE_ID,
			RESOURCE_SEQ_NUM,
			RESOURCE_ID,
			ACTIVITY_ID,
			STANDARD_RATE_FLAG,
			ASSIGNED_UNITS,
			USAGE_RATE_OR_AMOUNT,
			USAGE_RATE_OR_AMOUNT_INVERSE,
			BASIS_TYPE,
			SCHEDULE_FLAG,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			RESOURCE_OFFSET_PERCENT,
			AUTOCHARGE_TYPE,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
			REQUEST_ID,
			PROGRAM_APPLICATION_ID,
			PROGRAM_ID,
			PROGRAM_UPDATE_DATE
                        )
                select
                        OPERATION_SEQUENCE_ID,
                        RESOURCE_SEQ_NUM,
                        RESOURCE_ID,
                        ACTIVITY_ID,
                        STANDARD_RATE_FLAG,
                        ASSIGNED_UNITS,
                        USAGE_RATE_OR_AMOUNT,
                        USAGE_RATE_OR_AMOUNT_INVERSE,
                        BASIS_TYPE,
                        SCHEDULE_FLAG,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        RESOURCE_OFFSET_PERCENT,
                        AUTOCHARGE_TYPE,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE
                from   BOM_OP_RESOURCES_INTERFACE
                where  process_flag = 4
		  and  rownum < 500;

             EXIT when SQL%NOTFOUND;

                update bom_op_resources_interface bri
                   set process_flag = 7
                 where process_flag = 4
		   and exists (select NULL from bom_operation_resources bor
				where bor.operation_sequence_id =
				      bri.operation_sequence_id
				  and bor.resource_seq_num =
				      bri.resource_seq_num);
                commit;
       end loop;
/*
** process routing revision interface table
*/
        stmt_num := 50;
        table_name := 'MTL_RTG_ITEM_REVISIONS';
	loop
        insert into MTL_RTG_ITEM_REVISIONS(
			INVENTORY_ITEM_ID,
			ORGANIZATION_ID,
			PROCESS_REVISION,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			IMPLEMENTATION_DATE,
			EFFECTIVITY_DATE,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			REQUEST_ID,
			PROGRAM_APPLICATION_ID,
			PROGRAM_ID,
			PROGRAM_UPDATE_DATE
			)
			select
			INVENTORY_ITEM_ID,
                        ORGANIZATION_ID,
                        PROCESS_REVISION,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        trunc(IMPLEMENTATION_DATE),
                        trunc(EFFECTIVITY_DATE),
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE
	                from  MTL_RTG_ITEM_REVS_INTERFACE
			where process_flag = 4
			  and rownum < 500;

                EXIT when SQL%NOTFOUND;

		update mtl_rtg_item_revs_interface mri
		   set process_flag = 7
		 where process_flag = 4
	 	   and exists (select NULL from mtl_rtg_item_revisions mrr
			   where mrr.inventory_item_id = mri.inventory_item_id
		              and mrr.organization_id = mri.organization_id
			      and mrr.process_revision = mri.process_revision);
                commit;
		end loop;
       return(1);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return(1);
        WHEN OTHERS THEN
                rollback;
  error_message := 'BOMPPRCB:'||to_char(stmt_num)||':'|| substrb(sqlerrm,1,150);
                message_name := 'BOM_RTG_PROCESS_ERROR';
                return(SQLCODE);

    END bmprrtg_process_rtg_data;


END BOMPPRCB;

/
