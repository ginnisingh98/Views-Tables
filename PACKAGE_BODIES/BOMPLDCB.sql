--------------------------------------------------------
--  DDL for Package Body BOMPLDCB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPLDCB" as
/* $Header: BOMLDCBB.pls 120.1 2005/06/21 00:06:01 appldev ship $ */
function bmlggpn_get_group_name
(       group_id        number,
        group_name      in out nocopy /* file.sql.39 change */ varchar2,
        err_buf         in out nocopy /* file.sql.39 change */ varchar2
)
return integer
is
max_seg         number;
stmt_num	number;
type segvalueType is table of varchar2(30)
        index by binary_integer;
seg_value       segvalueType;
segvalue_tmp    varchar2(30);
segnum_tmp      number;
catseg_value    varchar2(240);
delimiter       varchar2(10);
profile_setting varchar2(30);
CURSOR profile_check IS
	select nvl(substr(profile_option_value,1,30),'N')
	from fnd_profile_option_values val,fnd_profile_options op
	where op.application_id = 401
	and   op.profile_option_name = 'USE_NAME_ICG_DESC'
	and   val.level_id = 10001  /* This is for site level  */
        and   val.application_id = op.application_id
	and   val.profile_option_id = op.profile_option_id;
begin
	/* First lets get the value for profile option USE_NAME_ICG_DESC
	** If this is 'N' we need to use the description
	** If this is 'Y' then we need to use the group name
	** We are going to stick with group name if the customer is
	** not on R10.5, which means they do not have the profile
	** If they have R10.5 then we are going to use description
	** because that is what inventory is going to do.
	** Remember at the earliest we should get rid of this function
	** and call INV API. Remember we at ATO are not in the business
	** of duplicating code of other teams
	*/

	profile_setting := 'Y';

	OPEN profile_check;
	FETCH profile_check INTO profile_setting;
	IF profile_check%NOTFOUND THEN
	profile_setting := 'Y';
	END IF;


   if profile_setting = 'Y' then

	/* Let us select the catalog group name from mtl_catalog_groups
	** At some point in time we need to call the inventory function
	** to do this, so we can centralize this stuff
	*/
	stmt_num :=100;

	SELECT MICGK.concatenated_segments
	INTO group_name
        FROM mtl_item_catalog_groups_kfv MICGK
        WHERE MICGK.item_catalog_group_id = group_id;

   else
	/* This is to get the description of the catalog */
        SELECT MICG.description
	INTO group_name
        FROM mtl_item_catalog_groups MICG
        WHERE MICG.item_catalog_group_id = group_id;

   end if;
        return(0);
exception
        when others then
                err_buf := 'BMLGGPN: ' || substrb(SQLERRM,1,150);
                return(SQLCODE);
end bmlggpn_get_group_name;


function bmlupid_update_item_desc
(
        item_id                 NUMBER,
        org_id                  NUMBER,
        err_buf         in out nocopy /* file.sql.39 change */   VARCHAR2
)
return integer
is
        /*
        ** Create cursor to retrieve all descriptive element values for the item
        */
        CURSOR cc is
                select element_value
                from mtl_desc_elem_val_interface
                where inventory_item_id = item_id
                and element_value is not NULL
		and default_element_flag = 'Y'
                order by element_sequence;
        delimiter       varchar2(10);
        e_value         varchar2(30);
        cat_value       varchar2(240);
        idx             number;
        group_id        number;
        group_name      varchar2(30);
        status          number;
        INV_GRP_ERROR   exception;
begin

        select concatenated_segment_delimiter into delimiter
        from fnd_id_flex_structures
        where id_flex_code = 'MICG'
	and   application_id = 401;

        select item_catalog_group_id into group_id
        from mtl_system_items_interface
        where inventory_item_id = item_id
        and organization_id = org_id;

        idx := 0;
        cat_value := '';
        open cc;
        loop
                fetch cc into e_value;
                exit when (cc%notfound);

                if idx = 0 then
                        status := bmlggpn_get_group_name(group_id,group_name,
							  err_buf);
                        if status <> 0 then
                        raise INV_GRP_ERROR;
                        end if;
                        cat_value := group_name || delimiter || e_value;
                else
		  cat_value := cat_value || SUBSTRB(delimiter || e_value,1,
			240-LENGTHB(cat_value));
                end if;
                idx := idx + 1;
        end loop;
	close cc;

        if idx <> 0 then
                update mtl_system_items_interface
                set description = cat_value
                where inventory_item_id = item_id
                and organization_id = org_id;
        end if;

        return(0);
exception
        when INV_GRP_ERROR then
                err_buf := 'BMLUPID: Invalid catalog group for the item ' || item_id || ' status:' || status;
                return(status);
        when OTHERS then
                err_buf := 'BMLUPID: ' || substrb(SQLERRM,1,150);
                return(SQLCODE);

END  bmlupid_update_item_desc;

function bmldbrt_load_bom_rtg (
	inherit_check  in       number,
        error_message  in out nocopy /* file.sql.39 change */      VARCHAR2,
        message_name   in out nocopy /* file.sql.39 change */      VARCHAR2,
        table_name     in out nocopy /* file.sql.39 change */      VARCHAR2)
return integer
is
        /*
        ** declare cursor for fetching all the duplicated rows
        */
        CURSOR cc IS
	        select  distinct
                        b1.bill_sequence_id,
                        b1.operation_seq_num,
                        b1.component_sequence_id,
                        b1.component_item_id,
                        b1.component_quantity
                from
                        BOM_INVENTORY_COMPS_INTERFACE b1,
                        BOM_INVENTORY_COMPS_INTERFACE b2,
                        BOM_BILL_OF_MTLS_INTERFACE b3
                where
                        b1.bill_sequence_id = b2.bill_sequence_id
                        and b1.component_sequence_id <> b2.component_sequence_id
                        and     b1.operation_seq_num = b2.operation_seq_num
                        and     b1.component_item_id = b2.component_item_id
                        and     b1.bill_sequence_id = b3.bill_sequence_id
                        and     b3.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                order by b1.bill_sequence_id,
                        b1.component_item_id,
                        b1.operation_seq_num,
                        b1.component_quantity,
                        b1.component_sequence_id;

         /*
         ** declare cursor to handle duplicated op sequences
         ** Operation type is being fetched since same operation sequences
         ** can exist in different operation types. (event, line Op, process etc)
         ** Item type is being fetched because we need to distinguish between
         ** Operations inherited from a model vs operations inherited from a class
         ** Important: Item type is stored in the last_update_login column
         */
         CURSOR dd IS
                select  distinct
                        b1.operation_sequence_id,
                        b1.operation_seq_num,
                        b1.operation_type,
                        b1.routing_sequence_id,
                        b1.last_update_login
                from    BOM_OP_SEQUENCES_INTERFACE b1,
                        BOM_OP_SEQUENCES_INTERFACE b2,
			BOM_OP_ROUTINGS_INTERFACE r2
                where   r2.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
		and     b2.routing_sequence_id = r2.routing_sequence_id
		and     b1.routing_sequence_id = b2.routing_sequence_id
                and     b1.operation_sequence_id <> b2.operation_sequence_id
                and     b1.operation_seq_num = b2.operation_seq_num
                and     b1.operation_type    = b2.operation_type
                        order by b1.routing_sequence_id,b1.operation_seq_num,b1.operation_type,b1.last_update_login;

	/*
	** declare cursor to retrieve config items
	*/
	CURSOR ee IS
		select inventory_item_id, organization_id
		from mtl_system_items_interface
		where set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

                routing_id                      NUMBER;
                bill_id                         NUMBER;
                item_type                       NUMBER;
                op_seq_num                      NUMBER;
		op_seq_id                       NUMBER;
                op_type                         NUMBER;
                item_id                         NUMBER;
                comp_seq_id                     NUMBER;
                qty                             NUMBER;
                save_bill_id                    NUMBER;
                save_op_seq_num                 NUMBER;
		save_routing_id                 NUMBER;
		save_op_seq_id                  NUMBER;
                save_op_type                    NUMBER;
                save_item_id                    NUMBER;
                save_comp_seq_id                NUMBER;
                total_qty                       NUMBER;
		org_id				NUMBER;
		status				NUMBER;
		bom_level_indicator             NUMBER;
		rowcount			NUMBER;
		stmt_num			NUMBER;
		UP_DESC_ERR			exception;



BEGIN
		/*
		** load bom header interface table
		*/
		table_name := 'BOM_BILL_OF_MTLS_INTERFACE ';
		stmt_num := 10;
                insert into BOM_BILL_OF_MTLS_INTERFACE(
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
                        bill_sequence_id,
                        common_bill_sequence_id,
                        request_id,
                        program_application_id,
                        program_id,
                        program_update_date,
                        demand_source_line  ,
			demand_source_type,
			demand_source_header_id,
                        set_id
                        )
                        select
                        m.inventory_item_id,    /* assembly_item_id */
                        m.organization_id,      /* organization_id */
                        NULL,                   /* alternate_bom_designator */
                        SYSDATE,                /* last_update_date */
                        1,                      /* last_update_by */
                        SYSDATE,                /* creation date */
                        1,                      /* created by */
                        1,                      /* last_update_login */
                        NULL,                   /* specific assembly comment */
                        NULL,                   /* pending from ecn */
                        NULL,                   /* attribute category */
                        NULL,                   /* attribute1 */
                        NULL,                   /* attribute2 */
                        NULL,                   /* attribute3 */
                        NULL,                   /* attribute4 */
                        NULL,                   /* attribute5 */
                        NULL,                   /* attribute6 */
                        NULL,                   /* attribute7 */
                        NULL,                   /* attribute8 */
                        NULL,                   /* attribute9 */
                        NULL,                   /* attribute10 */
                        NULL,                   /* attribute11 */
                        NULL,                   /* attribute12 */
                        NULL,                   /* attribute13 */
                        NULL,                   /* attribute14 */
                        NULL,                   /* attribute15 */
                        b.assembly_type,        /* assembly_ type */
                        BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
                        BOM_INVENTORY_COMPONENTS_S.CURRVAL,
                        NULL,                   /* request id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program id */
                        NULL,                   /* program date */
                        m.demand_source_line,   /* this is the additional column
                                                   to save the source_line */
			m.demand_source_type,
			m.demand_source_header_id,
                        m.set_id
                        from
			        BOM_BILL_OF_MATERIALS b,
				MTL_SYSTEM_ITEMS_INTERFACE m
                    where  m.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
			and	m.copy_item_id = b.assembly_item_id
			and     m.organization_id = b.organization_id
			and     b.alternate_bom_designator is NULL;


                	/*
			** Update the common bill sequence id equal to the
                   	** bill sequence id in the BOM_BILL_OF_MTLS_INTERFACE
			*/

                 /*
                 ** This is not required since it is being taken care in
                 ** the insert statement itself using the currval of the
                 ** sequence.
                 **
                 **	stmt_num := 20;
                 ** update BOM_BILL_OF_MTLS_INTERFACE b
                 ** set     common_bill_sequence_id = bill_sequence_id
                 ** where   (b.common_bill_sequence_id =1 or
                 **        	b.common_bill_sequence_id is NULL )
                 **  and     b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));
                 */

                /*
                ** Update MTL_DEMAND for the children to inherit the
                ** operation_seq_num of their parents.This works
                ** for all levels. This is executed only if the
                ** BOM:CONFIG_INHERIT_OP_SEQ profile option is set to YES
                */

        IF inherit_check = 1 THEN

                table_name := 'MTL_DEMAND';

		/* Initialize the bom_level columns to NULL   */

		stmt_num := 30;
		update mtl_demand
		set bom_level = NULL
		where config_group_id = USERENV('SESSIONID');

		/* Here we are identifying the base model row and
		** setting the bom_level to zero.
		*/

		stmt_num := 40;
		update mtl_demand
		set bom_level = 0
		where config_group_id = USERENV('SESSIONID')
		and demand_type = 1
		and rto_model_source_line = demand_source_line
		and primary_uom_quantity <>0
		and parent_demand_id is NULL;

	   bom_level_indicator := 0;
	   rowcount := 1;

		/* Now loop till you find no more rows to process
		** and update the bom_level of the children rows
		*/

	  WHILE rowcount <> 0 LOOP

 stmt_num := 50;
 		update mtl_demand d0
                set bom_level = bom_level_indicator + 1,
                    config_group_id = USERENV('SESSIONID'),
                    operation_seq_num =
                        (select distinct
                  decode(NVL(bic1.operation_seq_num,1),
                         1,NVL(d2.operation_seq_num,bic2.operation_seq_num),
                         bic1.operation_seq_num)
                        from bom_inventory_components bic1, /*child */
                             bom_inventory_components bic2,  /*parent */
                             mtl_demand d2
                where bic1.component_sequence_id=d0.component_sequence_id
                and bic2.component_sequence_id=d0.parent_component_seq_id
                and d0.parent_component_seq_id=d2.component_sequence_id
                and d0.rto_model_source_line = d2.rto_model_source_line
		and d2.primary_uom_quantity <>0
                and d2.bom_level = bom_level_indicator)
                where (d0.parent_component_seq_id, d0.rto_model_source_line)in
                    (select d1.component_sequence_id, d1.rto_model_source_line
                       from mtl_demand d1
		       where d1.config_group_id = USERENV('SESSIONID')
		       and d1.primary_uom_quantity <>0
                       and d1.bom_level = bom_level_indicator)
		and d0.primary_uom_quantity <>0;

	      rowcount := SQL%ROWCOUNT;
	      bom_level_indicator := bom_level_indicator + 1;

	  END LOOP;

        END IF;

		/*
		** Load inventory components interface table
		*/

		/*
		** First:
           	** All the chosen option items  associated
           	** with the new configuration items will be loaded into the
                ** BOM_INVENTORY_COMPS_INTERFACE table.
		*/
		table_name := 'BOM_INVENTORY_COMPS_INTERFACE';
		stmt_num := 60;
                insert into BOM_INVENTORY_COMPS_INTERFACE
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
                        PICK_COMPONENTS,
                        MODEL_COMP_SEQ_ID,
			SUPPLY_SUBINVENTORY,
			SUPPLY_LOCATOR_ID
                        )
                select
                        decode(NVL(ic1.operation_seq_num,1),1,
			NVL(d1.operation_seq_num,1),ic1.operation_seq_num),
                        ic1.component_item_id,
                        SYSDATE,                /* last_updated_date */
                        1,                      /* last_updated_by */
                        SYSDATE,                /* creation_date */
                        1,                      /* created_by   */
                        1,                      /* last_update_login */
                        ic1.item_num,
                        d1.primary_uom_quantity /
                           NVL(d2.primary_uom_quantity,1),
                                              /* qty = comp_qty / model_qty */
                        ic1.component_yield_factor,
                        NULL,                   /*ic1.component_remark*/
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change notice */
                        SYSDATE,                /* implementation_date */
                        NULL,                   /* disable date */
                        ic1.attribute_category,
                        ic1.attribute1,
                        ic1.attribute2,
                        ic1.attribute3,
                        ic1.attribute4,
                        ic1.attribute5,
                        ic1.attribute6,
                        ic1.attribute7,
                        ic1.attribute8,
                        ic1.attribute9,
                        ic1.attribute10,
                        ic1.attribute11,
                        ic1.attribute12,
                        ic1.attribute13,
                        ic1.attribute14,
                        ic1.attribute15,
                        100,                      /* planning_factor */
                        2,                      /* quantity_related */
                        ic1.so_basis,
                        2,                      /* optional */
                        2,                    /* mutually_exclusive_options */
                        ic1.include_in_cost_rollup,
                        ic1.check_atp,
                        2,                      /* shipping_allowed = NO */
                        2,                      /* required_to_ship = NO */
                        ic1.required_for_revenue,
                        ic1.include_on_ship_docs,
                        ic1.include_on_bill_docs,
                        NULL,                   /* low_quantity */
                        NULL,                   /* high_quantity */
                        NULL,                   /* acd_type */
                        NULL,                 /*old_component_sequence_id */
                        BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
                                                /* component sequence id */
                        b.bill_sequence_id,     /* bill sequence id */
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        ic1.wip_supply_type,
                        2,                      /* pick_components = NO */
                        ic1.component_sequence_id,
                                                /* This is an addition column
                                                   to save the model component
                                                   seq id for later use */
			ic1.supply_subinventory,
			ic1.supply_locator_id
                	from
                        bom_inventory_components ic1,
                        mtl_demand d1, /*Option */
                        mtl_demand d2, /* Parent-Model */
                        mtl_demand d3, /* parent-Component */
                        bom_bill_of_mtls_interface b
               	where   ic1.component_sequence_id =(          /* Refer bug 625484. component_sequence_id      */
                        select component_sequence_id          /* in d1 points to components in validation     */
                        from   bom_inventory_components bic   /* so,we need to map these  to Mfg org. For     */
                        where  bill_sequence_id = (           /* this we find the assembly  to which          */
                          select common_bill_sequence_id      /* d1.component_seq_id belongs and then find    */
                          from   bom_bill_of_materials bbm    /* bill for it in Mfg org.We find equivalent    */
                          where  organization_id = d1.organization_id  /* compnent in this bill by joining    */
                          and    alternate_bom_designator is null      /* on component_item_id. Each component*/
                          and    assembly_item_id =(            /*is assumed to be used at one operation only */
                            select distinct assembly_item_id    /* Operation_Seq_num must be same in bills in */
                            from   bom_bill_of_materials bbm1,  /* all organizations for that assembly        */
                                   bom_inventory_components bic1
                            where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
                                   and    component_sequence_id = d1.component_sequence_id
                                   and    bbm1.assembly_item_id = d3.inventory_item_id))
                        and bic.component_item_id = d1.inventory_item_id
                        and trunc(bic.effectivity_date) <= d1.requirement_date
                        and NVL(bic.disable_date, d1.requirement_date ) + 1 > d1.requirement_date )
               	and     ic1.optional = 1   /* optional = yes */
               	and     ic1.bom_item_type = 4        /* standard */
		and     d1.config_status = 20
		and	d2.config_status = 20
               	and     d1.primary_uom_quantity <> 0
               	and     d1.rto_model_source_line = d2.demand_source_line
               	and     d2.demand_source_line = b.demand_source_line
		and     d2.demand_source_type = b.demand_source_type
		and     d2.demand_source_header_id = b.demand_source_header_id
		and     d2.demand_type = 1	/* model */
		and     d2.organization_id = d1.organization_id
		and     d2.primary_uom_quantity <> 0
                and     d3.rto_model_source_line = d1.rto_model_source_line
                and     d3.component_sequence_id = d1.parent_component_seq_id
               	and     b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));



	        /*
		** Second:
       		** All the standard component items  associated
           	** with the new configuration items will be loaded into the
           	** BOM_INVENTORY_COMPS_INTERFACE table.
		*/

		stmt_num := 70;
                insert into BOM_INVENTORY_COMPS_INTERFACE
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
                        PICK_COMPONENTS,
                        MODEL_COMP_SEQ_ID,
                        SUPPLY_SUBINVENTORY,
			SUPPLY_LOCATOR_ID
			)
                	select /*+ ORDERED */
                        decode(NVL(ic1.operation_seq_num,1),1,
			NVL(d1.operation_seq_num,1),ic1.operation_seq_num),
                        ic1.component_item_id,
                        SYSDATE,                /* last_updated_date */
                        1,                      /* last_updated_by */
                        SYSDATE,                /* creation_date */
                        1,                      /* created_by   */
                        1,                      /* last_update_login */
                        ic1.item_num,
			ic1.component_quantity *  (d1.primary_uom_quantity/d2.primary_uom_quantity),
                        ic1.component_yield_factor,
                        NULL,                   /*ic1.component_remark*/
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change notice */
                        SYSDATE,                /* implementation_date */
                        NULL,                   /* disable date */
                        ic1.attribute_category,
                        ic1.attribute1,
                        ic1.attribute2,
                        ic1.attribute3,
                        ic1.attribute4,
                        ic1.attribute5,
                        ic1.attribute6,
                        ic1.attribute7,
                        ic1.attribute8,
                        ic1.attribute9,
                        ic1.attribute10,
                        ic1.attribute11,
                        ic1.attribute12,
                        ic1.attribute13,
                        ic1.attribute14,
                        ic1.attribute15,
                        100,                      /* planning_factor */
                        2,                      /* quantity_related */
                        ic1.so_basis,
                        2,                      /* optional */
                        2,                   /* mutually_exclusive_options */
                        ic1.include_in_cost_rollup,
                        ic1.check_atp,
                        2,                      /* shipping_allowed = NO */
                        2,                      /* required_to_ship = NO */
                        ic1.required_for_revenue,
                        ic1.include_on_ship_docs,
                        ic1.include_on_bill_docs,
                        NULL,                   /* low_quantity */
                        NULL,                   /* high_quantity */
                        NULL,                   /* acd_type */
                        NULL,                /* old_component_sequence_id */
                        BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
                                                /* component sequence id */
                        b1.bill_sequence_id,     /* bill sequence id */
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        ic1.wip_supply_type,
                        2,                      /* pick_components = NO */
                        ic1.component_sequence_id,
                                                /* This is an addition column
                                                   to save the model component
                                                   seq id for later use */
			ic1.supply_subinventory,
			ic1.supply_locator_id
                        from
                                bom_bill_of_mtls_interface b1,
				mtl_demand d2, /* Model-Parent */
				mtl_demand d1, /* Standard Mandatory comp */
				mtl_system_items si1,
				bom_bill_of_materials b,
				bom_inventory_components ic1
                  where   d1.organization_id = si1.organization_id
                  and     d1.inventory_item_id = si1.inventory_item_id
		  and     d1.config_status = 20
                  and     si1.bom_item_type in (1,2)
						/* model, option class */
                  and     d1.primary_uom_quantity <> 0
                  and     d1.rto_model_source_line = d2.demand_source_line
                  and     b1.set_id =  TO_CHAR(to_number(USERENV('SESSIONID')))
		  and     d2.demand_source_type = 2
	  	  and     d2.demand_source_header_id =
					b1.demand_source_header_id
		  and     d2.demand_type = 1
		  and     d2.demand_source_line = b1.demand_source_line
		  and     d2.primary_uom_quantity <> 0
                  and     d1.organization_id = b.organization_id
                  and     d1.inventory_item_id = b.assembly_item_id
		  and     d1.parent_demand_id is NULL
                  and     b.alternate_bom_designator is NULL
                  and     b.common_bill_sequence_id = ic1.bill_sequence_id
                  and     ic1.optional = 2        /* optional = no */
		  and     ic1.effectivity_date <=
		     GREATEST(NVL(d2.estimated_release_date,SYSDATE),SYSDATE)
		  and     ic1.implementation_date is not null
                  and     NVL(ic1.disable_date,NVL(d2.estimated_release_date,
			  SYSDATE)+1) > NVL(d2.estimated_release_date,SYSDATE)
                  and     ic1.bom_item_type = 4;        /* standard */

		/*
		** Third:
           	** All the chosen option classes  associated
           	** with the new configuration items will be loaded into the
                ** BOM_INVENTORY_COMPS_INTERFACE table.
		*/
		table_name := 'BOM_INVENTORY_COMPS_INTERFACE';
		stmt_num := 80;
                insert into BOM_INVENTORY_COMPS_INTERFACE
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
                        PICK_COMPONENTS,
                        MODEL_COMP_SEQ_ID,
			SUPPLY_SUBINVENTORY,
			SUPPLY_LOCATOR_ID
                        )
                select
                        decode(NVL(ic1.operation_seq_num,1),1,
                        NVL(d1.operation_seq_num,1),ic1.operation_seq_num),
                        ic1.component_item_id,
                        SYSDATE,                /* last_updated_date */
                        1,                      /* last_updated_by */
                        SYSDATE,                /* creation_date */
                        1,                      /* created_by   */
                        1,                      /* last_update_login */
                        ic1.item_num,
                        d1.primary_uom_quantity /
                           NVL(d2.primary_uom_quantity,1),
                                                /* qty = comp_qty / model_qty */
                        ic1.component_yield_factor,
                        NULL,                   /*ic1.component_remark*/
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change notice */
                        SYSDATE,                /* implementation_date */
                        NULL,                   /* disable date */
                        ic1.attribute_category,
                        ic1.attribute1,
                        ic1.attribute2,
                        ic1.attribute3,
                        ic1.attribute4,
                        ic1.attribute5,
                        ic1.attribute6,
                        ic1.attribute7,
                        ic1.attribute8,
                        ic1.attribute9,
                        ic1.attribute10,
                        ic1.attribute11,
                        ic1.attribute12,
                        ic1.attribute13,
                        ic1.attribute14,
                        ic1.attribute15,
                        100,                      /* planning_factor */
                        2,                      /* quantity_related */
                        2,			/* so_basis */
                        2,                      /* optional */
                        2,                      /* mutually_exclusive_options */
                        2,			/* include_in_cost_rollup */
                        2,			/* check_atp */
                        2,                      /* shipping_allowed = NO */
                        2,                      /* required_to_ship = NO */
                        ic1.required_for_revenue,
                        ic1.include_on_ship_docs,
                        ic1.include_on_bill_docs,
                        NULL,                   /* low_quantity */
                        NULL,                   /* high_quantity */
                        NULL,                   /* acd_type */
                        NULL,           /* old_component_sequence_id */
                        BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
                                                /* component sequence id */
                        b.bill_sequence_id,     /* bill sequence id */
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        ic1.wip_supply_type,
                        2,                      /* pick_components = NO */
                        ic1.component_sequence_id,
                                                /* This is an addition column
                                                   to save the model component
                                                   seq id for later use */
			ic1.supply_subinventory,
			ic1.supply_locator_id
                	from
			bom_bill_of_mtls_interface b,
			mtl_demand d2, /* Model */
                        mtl_demand d1, /* Option Classes */
                        mtl_demand d3, /* parent component */
			bom_inventory_components ic1
                where   ic1.component_sequence_id =(  /* See 625484 releated comments in stmt 60 */
                        select component_sequence_id
                        from   bom_inventory_components bic
                        where  bill_sequence_id = (
                                   select common_bill_sequence_id
                                   from   bom_bill_of_materials bbm
                                   where  organization_id = d1.organization_id
                                   and    alternate_bom_designator is null
                                   and    assembly_item_id =(
                                          select distinct assembly_item_id
                                          from   bom_bill_of_materials bbm1,
                                                 bom_inventory_components bic1
                                          where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
                                          and    component_sequence_id = d1.component_sequence_id
                                          and    (bbm1.assembly_item_id = d3.inventory_item_id
                                                  OR bbm1.assembly_item_id = d2.inventory_item_id)))
                        and bic.component_item_id = d1.inventory_item_id
                        and trunc(bic.effectivity_date) <= d1.requirement_date
                        and NVL(bic.disable_date, d1.requirement_date ) + 1 > d1.requirement_date )
               	and     (ic1.bom_item_type = 2      /* option class */
			     or  ic1.bom_item_type = 1)     /* model */
		and     d1.config_status = 20
		and	d2.config_status = 20
               	and     d1.primary_uom_quantity <> 0
		and     d1.demand_id <> d2.demand_id /* not base model */
               	and     d1.rto_model_source_line = d2.demand_source_line
               	and     d2.demand_source_line = b.demand_source_line
		and     d2.demand_source_type = b.demand_source_type
		and     d2.demand_source_header_id = b.demand_source_header_id
		and     d2.demand_type = 1	/* model */
		and     d2.primary_uom_quantity <> 0
		and     d1.organization_id = d2.organization_id
                and     d3.rto_model_source_line = d1.rto_model_source_line
                and     d3.component_sequence_id = d1.parent_component_seq_id
               	and     b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

		/*
		** Fourth:
		** Get the base model row into BOM_INVENTORY_COMPS_INTERFACE
		*/
		table_name := 'BOM_INVENTORY_COMPS_INTERFACE';
		stmt_num := 90;
                insert into BOM_INVENTORY_COMPS_INTERFACE
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
                        PICK_COMPONENTS,
                        MODEL_COMP_SEQ_ID
			)
                select
                        1,			/* operation_seq_num */
                        d2.inventory_item_id,
                        SYSDATE,                /* last_updated_date */
                        1,                      /* last_updated_by */
                        SYSDATE,                /* creation_date */
                        1,                      /* created_by   */
                        1,                      /* last_update_login */
                        10,			/* item_num */
                        1,	                /* comp_qty */
                        1,			/* yield_factor */
                        NULL,                   /*ic1.component_remark*/
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change notice */
                        SYSDATE,                /* implementation_date */
                        NULL,                   /* disable date */
                        NULL,			/* attribute_category */
                        NULL,			/* attribute1 */
                        NULL,                   /* attribute2 */
                        NULL,                   /* attribute3 */
                        NULL,                   /* attribute4 */
                        NULL,                   /* attribute5 */
                        NULL,                   /* attribute6 */
                        NULL,                   /* attribute7 */
                        NULL,                   /* attribute8 */
                        NULL,                   /* attribute9 */
                        NULL,                   /* attribute10 */
                        NULL,                   /* attribute11 */
                        NULL,                   /* attribute12 */
                        NULL,                   /* attribute13 */
                        NULL,                   /* attribute14 */
                        NULL,                   /* attribute15 */
                        100,                      /* planning_factor */
                        2,                      /* quantity_related */
                        2,			/* so_basis */
                        2,                      /* optional */
                        2,                      /* mutually_exclusive_options */
                        2,			/* include_in_cost_rollup */
                        2,			/* check_atp */
                        2,                      /* shipping_allowed = NO */
                        2,                      /* required_to_ship = NO */
                        2,			/* required_for_revenue */
                        2,			/* include_on_ship_docs */
                        2,			/* include_on_bill_docs */
                        NULL,                   /* low_quantity */
                        NULL,                   /* high_quantity */
                        NULL,                   /* acd_type */
                        NULL,           /* old_component_sequence_id */
                        BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
                                                /* component sequence id */
                        b.bill_sequence_id,     /* bill sequence id */
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        6,			/* wip_supply_type  */
                        2,                      /* pick_components = NO */
 			0                      /* This is an addition column
                                                   to save the model component
                                                   seq id for later use */
                	from
                        mtl_demand d2,
                        bom_bill_of_mtls_interface b
                	where 	d2.config_status = 20
                	and     d2.demand_source_line = b.demand_source_line
			and     d2.demand_source_type = b.demand_source_type
			and     d2.demand_source_header_id = b.demand_source_header_id
			and     d2.demand_type = 1	/* model */
			and     d2.primary_uom_quantity <> 0
                	and     b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));


        	/*
		** Load routing header interface table
		*/
		table_name := 'BOM_OP_ROUTINGS_INTERFACE';
		stmt_num := 110;
                insert into BOM_OP_ROUTINGS_INTERFACE
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
                         SET_ID,
                         DEMAND_SOURCE_LINE,
			 DEMAND_SOURCE_TYPE,
			 DEMAND_SOURCE_HEADER_ID,
			 PROCESS_REVISION,
                         LINE_ID,
                         MIXED_MODEL_MAP_FLAG,
                         PRIORITY,
                         CFM_ROUTING_FLAG,
                         TOTAL_PRODUCT_CYCLE_TIME,
                         CTP_FLAG
                         )
                 	select
                        BOM_OPERATIONAL_ROUTINGS_S.NEXTVAL,
                        m.inventory_item_id,
                        m.organization_id,
                        NULL,
                        SYSDATE,
                        1,
                        SYSDATE,
                        1,	/* CREATED_BY */
                        1, 	/* LAST_UPDATE_LOGIN */
                        b.routing_type,	/* ROUTING_TYPE */
                        1, 	/* COMMON_ROUTING_SEQUENCE_ID */
			NULL,   /* COMMON_ASSEMBLY_ITEM_ID */
                        b.routing_comment,
                        b.completion_subinventory,
                        b.completion_locator_id,
                        NULL,
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
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        m.set_id,
                        m.demand_source_line,
			m.demand_source_type,
			m.demand_source_header_id,
			mp.starting_revision,
                        b.line_id,
                        b.mixed_model_map_flag,
                        b.priority,
                        b.cfm_routing_flag,
                        b.total_product_cycle_time,
                        b.ctp_flag
                	from
                        BOM_OPERATIONAL_ROUTINGS b,
			MTL_DEMAND d,
			MTL_PARAMETERS mp,
			MTL_SYSTEM_ITEMS_INTERFACE m
                where   m.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
			and     d.demand_source_line = m.demand_source_line
			and     d.demand_source_type = m.demand_source_type
			and     d.demand_source_header_id = m.demand_source_header_id
                        and     d.inventory_item_id = m.copy_item_id
			and     d.config_status = 20
			and     d.primary_uom_quantity <> 0
			and     b.assembly_item_id = d.inventory_item_id
			and     b.organization_id = d.organization_id
                	and     b.alternate_routing_designator is NULL
			and     mp.organization_id = m.organization_id;

                        /*
			** Update the common_routing_sequence_id equal to the
                        ** routing_sequence_id in BOM_OP_ROUTINGS_INTERFACE
			*/

		stmt_num := 120;
                 update  BOM_OP_ROUTINGS_INTERFACE b
                        set     common_routing_sequence_id = routing_sequence_id
                        where   (b.common_routing_sequence_id =1 or
                                b.common_routing_sequence_id is NULL )
                        and     b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

                       /*
                       ** Udpate the mixed_model_map_flag. If the cfm_routing_flag
                       ** is 1, then mixed_model_flag should be 1 if any flow_routing
                       ** (primary or alternate) for the model has the mixed_model_flag
                       ** equal to 1. */

               stmt_num := 125;

                 Update BOM_OP_ROUTINGS_INTERFACE b
                        set mixed_model_map_flag =
                        ( select 1
                          from   bom_operational_routings b1,
                                 mtl_system_items_interface m
                          where b.assembly_item_id      = m.inventory_item_id
                          and   b.organization_id       = m.organization_id
                          and   m.set_id                = to_char(to_number(USERENV('SESSIONID')))
                          and   b1.assembly_item_id     = m.copy_item_id
                          and   b1.organization_id      = m.organization_id
                          and   b1.cfm_routing_flag     = 1
                          and   b1.mixed_model_map_flag = 1
                          and   b1.alternate_routing_designator is not NULL )
                   where  b.set_id = to_char(to_number(USERENV('SESSIONID')))
                   and    b.mixed_model_map_flag <> 1
                   and    b.cfm_routing_flag =1;



        	/*
		** Load the operation sequence interface table
		*/
        	/*
		** Zero:
           	** ALL Processes and Line operations ,
		** associated with the model/option classes will
		** be inserted into the BOM_OP_SEQUENCES_INTERFACE
		*/
		table_name := 'BOM_OP_SEQUENCES_INTERFACE';
		stmt_num := 130;
                insert into BOM_OP_SEQUENCES_INTERFACE
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
                         CHANGE_NOTICE  ,
                         IMPLEMENTATION_DATE,
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
                         MODEL_OP_SEQ_ID,
                         REFERENCE_FLAG,
                         OPERATION_TYPE,
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
                        BOM_OPERATION_SEQUENCES_S.NEXTVAL,
                        b1.routing_sequence_id, /* routing_sequence_id */
                        os1.operation_seq_num,
                        SYSDATE,                /* last update date */
                        1,                      /* last updated by */
                        SYSDATE,                /* creation date */
                        1,                      /* created by */
                        si1.bom_item_type,    /* last update login col stores item type temporarily */
                        os1.standard_operation_id,
                        os1.department_id,
                        os1.operation_lead_time_percent,
                        os1.minimum_transfer_quantity,
                        os1.count_point_type,
                        os1.operation_description,
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change_notice */
                        TRUNC(SYSDATE),         /* implementation date */
                        NULL,                   /* disable date */
                        os1.backflush_flag,
                        2,              /* option_dependent_flag */
                        os1.attribute_category,
                        os1.attribute1,
                        os1.attribute2,
                        os1.attribute3,
                        os1.attribute4,
                        os1.attribute5,
                        os1.attribute6,
                        os1.attribute7,
                        os1.attribute8,
                        os1.attribute9,
                        os1.attribute10,
                        os1.attribute11,
                        os1.attribute12,
                        os1.attribute13,
                        os1.attribute14,
                        os1.attribute15,
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        os1.operation_sequence_id,
                        reference_flag,
                        operation_type,
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
                        Net_planning_percent
                        from
                                bom_op_routings_interface b1,
				mtl_demand d2,/* Model for est. release date */
                                mtl_demand d1,
                                mtl_system_items si1,
                                bom_operational_routings or1,
                                bom_operation_sequences os1
                        where   b1.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                        and     d1.rto_model_source_line = b1.demand_source_line
			and	d1.config_status = 20
			and     d1.primary_uom_quantity <> 0
			and     d1.parent_demand_id is NULL
			and     d2.demand_source_line = b1.demand_source_line
			and     d2.demand_source_header_id = d1.demand_source_header_id
			and     d2.demand_source_type = 2
			and     d2.demand_type = 1
			and     d2.primary_uom_quantity <> 0
                        and     si1.organization_id = d1.organization_id
                        and     si1.inventory_item_id = d1.inventory_item_id
                        and     si1.bom_item_type in (1,2)
						/* model and option classes */
                        and     or1.assembly_item_id = si1.inventory_item_id
                        and     or1.organization_id = si1.organization_id
                        and     or1.alternate_routing_designator is NULL
                        and     nvl(or1.cfm_routing_flag,2) = nvl(b1.cfm_routing_flag,2) /*ensure correct OC rtgs*/
                        and     os1.routing_sequence_id = or1.common_routing_sequence_id
                        and     os1.effectivity_date <= GREATEST(NVL(d2.estimated_release_date,
						SYSDATE),SYSDATE)
                        and     NVL(os1.disable_date,NVL(d2.estimated_release_date,
			             SYSDATE)+ 1) > NVL(d2.estimated_release_date,SYSDATE)
                        and     NVL(os1.eco_for_production,2) = 2
                        and     os1.operation_type in (2,3);

        	/*
		** First:
           	** All operations/events with NO in option_dependent_flag,
		** associated with the model/option classes will
		** be inserted into the BOM_OP_SEQUENCES_INTERFACE
		*/
		table_name := 'BOM_OP_SEQUENCES_INTERFACE';
		stmt_num := 130;
                insert into BOM_OP_SEQUENCES_INTERFACE
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
                         CHANGE_NOTICE  ,
                         IMPLEMENTATION_DATE,
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
                         MODEL_OP_SEQ_ID,
                         REFERENCE_FLAG,
                         OPERATION_TYPE,
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
                        BOM_OPERATION_SEQUENCES_S.NEXTVAL,
                        b1.routing_sequence_id, /* routing_sequence_id */
                        os1.operation_seq_num,
                        SYSDATE,                /* last update date */
                        1,                      /* last updated by */
                        SYSDATE,                /* creation date */
                        1,                      /* created by */
                        si1.bom_item_type,    /* last update login col stores item type temporarily */
                        os1.standard_operation_id,
                        os1.department_id,
                        os1.operation_lead_time_percent,
                        os1.minimum_transfer_quantity,
                        os1.count_point_type,
                        os1.operation_description,
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change_notice */
                        TRUNC(SYSDATE),         /* implementation date */
                        NULL,                   /* disable date */
                        os1.backflush_flag,
                        2,              /* option_dependent_flag */
                        os1.attribute_category,
                        os1.attribute1,
                        os1.attribute2,
                        os1.attribute3,
                        os1.attribute4,
                        os1.attribute5,
                        os1.attribute6,
                        os1.attribute7,
                        os1.attribute8,
                        os1.attribute9,
                        os1.attribute10,
                        os1.attribute11,
                        os1.attribute12,
                        os1.attribute13,
                        os1.attribute14,
                        os1.attribute15,
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        os1.operation_sequence_id,
                        reference_flag,
                        operation_type,
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
                        Net_planning_percent
                        from
                                bom_op_routings_interface b1,
				mtl_demand d2,/* Model for est. release date */
                                mtl_demand d1,
                                mtl_system_items si1,
                                bom_operational_routings or1,
                                bom_operation_sequences os1
                        where   b1.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                        and     d1.rto_model_source_line = b1.demand_source_line
			and	d1.config_status = 20
			and     d1.primary_uom_quantity <> 0
			and     d1.parent_demand_id is NULL
			and     d2.demand_source_line = b1.demand_source_line
			and     d2.demand_source_header_id = d1.demand_source_header_id
			and     d2.demand_source_type = 2
			and     d2.demand_type = 1
			and     d2.primary_uom_quantity <> 0
                        and     si1.organization_id = d1.organization_id
                        and     si1.inventory_item_id = d1.inventory_item_id
                        and     si1.bom_item_type in (1,2)
						/* model and option classes */
                        and     or1.assembly_item_id = si1.inventory_item_id
                        and     or1.organization_id = si1.organization_id
                        and     or1.alternate_routing_designator is NULL
                        and     nvl(or1.cfm_routing_flag,2) = nvl(b1.cfm_routing_flag,2) /*ensure correct OC rtgs*/
                        and     os1.routing_sequence_id = or1.common_routing_sequence_id
                        and     os1.effectivity_date <= GREATEST(NVL(d2.estimated_release_date,
						SYSDATE),SYSDATE)
                        and     NVL(os1.disable_date,NVL(d2.estimated_release_date,
			             SYSDATE)+ 1) > NVL(d2.estimated_release_date,SYSDATE)
                        and     os1.option_dependent_flag = 2
                        and     NVL(os1.eco_for_production,2) = 2
                        and    ( os1.operation_type =1 OR os1.operation_type is NULL);


	        /*
		** Second:
           	** All operations/events with YES in option_dependent_flag,
           	** associated with the chosen option items/option classes
	 	** will be inserted into BOM_OP_SEQUENCES_INTERFACE.
		*/
		stmt_num := 140;
                insert into BOM_OP_SEQUENCES_INTERFACE
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
                         CHANGE_NOTICE  ,
                         IMPLEMENTATION_DATE,
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
                         MODEL_OP_SEQ_ID,
                         REFERENCE_FLAG,
                         OPERATION_TYPE,
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
                select  /*+ ORDERED */
                        BOM_OPERATION_SEQUENCES_S.NEXTVAL,
                        b.routing_sequence_id, /* routing_sequence_id */
                        os1.operation_seq_num,
                        SYSDATE,                /* last update date */
                        1,                      /* last updated by */
                        SYSDATE,                /* creation date */
                        1,                      /* created by */
                        d2.demand_type,       /* Last update login stores demand_type temporarily */
                        os1.standard_operation_id,
                        os1.department_id,
                        os1.operation_lead_time_percent,
                        os1.minimum_transfer_quantity,
                        os1.count_point_type,
                        os1.operation_description,
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change_notice */
                        TRUNC(SYSDATE),         /* implementation date */
                        NULL,                   /* disable date */
                        os1.backflush_flag,
                        2,             /* option_dependent_flag */
                        os1.attribute_category,
                        os1.attribute1,
                        os1.attribute2,
                        os1.attribute3,
                        os1.attribute4,
                        os1.attribute5,
                        os1.attribute6,
                        os1.attribute7,
                        os1.attribute8,
                        os1.attribute9,
                        os1.attribute10,
                        os1.attribute11,
                        os1.attribute12,
                        os1.attribute13,
                        os1.attribute14,
                        os1.attribute15,
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        os1.operation_sequence_id,
                        reference_flag,
                        operation_type,
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
                        Net_planning_percent
                 from
			bom_op_routings_interface b,
			mtl_demand d1,		/* components */
			mtl_demand d2, 		/* parents    */
			mtl_demand d3,		/* Model estd release date */
			bom_inventory_components ic1,
			bom_bill_of_materials b1,
			bom_operational_routings or1,
                        bom_operation_sequences os1
                 where  b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                 and    d1.rto_model_source_line = b.demand_source_line
		 and    d1.demand_type in (2,3) /* option class,option item */
		 and    d1.config_status = 20
                 and    d2.rto_model_source_line = b.demand_source_line
		 and    d2.config_status = 20
                 and    d2.demand_type in (1,2) /* model, option class */
		 and    d2.primary_uom_quantity <> 0
		 and    d1.organization_id = d2.organization_id
                 and    d2.component_sequence_id = d1.parent_component_seq_id
                 and    d3.demand_type = 1
		 and    d3.demand_source_type = 2
		 and    d3.demand_source_header_id = d1.demand_source_header_id
		 and    d3.demand_source_line = d1.rto_model_source_line
		 and    d3.primary_uom_quantity <> 0
                 and    ic1.component_sequence_id = (  /* See 625484 releated comments in stmt 60 */
                        select component_sequence_id
                        from   bom_inventory_components bic
                        where  bill_sequence_id = (
                                   select common_bill_sequence_id
                                   from   bom_bill_of_materials bbm
                                   where  organization_id = d1.organization_id
                                   and    alternate_bom_designator is null
                                   and    assembly_item_id =(
                                          select distinct assembly_item_id
                                          from   bom_bill_of_materials bbm1,
                                                 bom_inventory_components bic1
                                          where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
                                          and    component_sequence_id = d1.component_sequence_id
                                          and    bbm1.assembly_item_id = d2.inventory_item_id))
                        and bic.component_item_id = d1.inventory_item_id
                        and trunc(bic.effectivity_date) <= d1.requirement_date
                        and NVL(bic.disable_date, d1.requirement_date ) + 1 > d1.requirement_date )
                 and    b1.common_bill_sequence_id  = ic1.bill_sequence_id
                 and    b1.alternate_bom_designator is NULL
                 and    or1.assembly_item_id = b1.assembly_item_id
                 and    or1.organization_id = b1.organization_id
                 and    or1.alternate_routing_designator is null
                 and    nvl(or1.cfm_routing_flag,2) = nvl(b.cfm_routing_flag,2) /*ensure correct OC rtgs*/
                 and    os1.effectivity_date <= GREATEST(NVL(d3.estimated_release_date,
						SYSDATE),SYSDATE)
                 and     NVL(os1.disable_date,NVL(d3.estimated_release_date,
			  SYSDATE)+ 1) > NVL(d3.estimated_release_date,SYSDATE)
                 and    os1.routing_sequence_id =or1.common_routing_sequence_id
                 and    os1.operation_seq_num = ic1.operation_seq_num
                 and    os1.option_dependent_flag = 1
                 and    NVL(os1.eco_for_production,2) = 2
                 and    ( os1.operation_type =1 OR os1.operation_type is NULL);

        	/*
		** Third:
                ** man: This SQL statement gets all the operations/events that
                        are option dependent and have a standard mandatory
                        component at that operation
		*/
		stmt_num := 150;
                insert into BOM_OP_SEQUENCES_INTERFACE
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
                         CHANGE_NOTICE  ,
                         IMPLEMENTATION_DATE,
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
                         MODEL_OP_SEQ_ID,
                         REFERENCE_FLAG,
                         OPERATION_TYPE,
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
                        BOM_OPERATION_SEQUENCES_S.NEXTVAL,
                                                /* operation_sequence_id */
                        b.routing_sequence_id, /* routing_sequence_id */
                        os1.operation_seq_num,
                        SYSDATE,                /* last update date */
                        1,                      /* last updated by */
                        SYSDATE,                /* creation date */
                        1,                      /* created by */
                        si1.bom_item_type,    /* last update login col stores item type temporarily */
                        os1.standard_operation_id,
                        os1.department_id,
                        os1.operation_lead_time_percent,
                        os1.minimum_transfer_quantity,
                        os1.count_point_type,
                        os1.operation_description,
                        TRUNC(SYSDATE),         /* effective date */
                        NULL,                   /* change_notice */
                        TRUNC(SYSDATE),         /* implementation date */
                        NULL,                   /* disable date */
                        os1.backflush_flag,
                        2,               /* option_dependent_flag */
                        os1.attribute_category,
                        os1.attribute1,
                        os1.attribute2,
                        os1.attribute3,
                        os1.attribute4,
                        os1.attribute5,
                        os1.attribute6,
                        os1.attribute7,
                        os1.attribute8,
                        os1.attribute9,
                        os1.attribute10,
                        os1.attribute11,
                        os1.attribute12,
                        os1.attribute13,
                        os1.attribute14,
                        os1.attribute15,
                        NULL,                   /* request_id */
                        NULL,                   /* program_application_id */
                        NULL,                   /* program_id */
                        NULL,                   /* program_update_date */
                        os1.operation_sequence_id ,
                        reference_flag,
                        operation_type,
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
                        Net_planning_percent
                 from
			bom_operation_sequences os1,
			bom_operational_routings or1,
			mtl_system_items si2,
			bom_inventory_components ic1,
			bom_bill_of_materials b1,
			mtl_system_items si1,
			mtl_demand d2, /* Model if option class */
			mtl_demand d1, /* Model or option class */
			bom_op_routings_interface b
                where   b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                and     d1.rto_model_source_line = b.demand_source_line
		and     d1.config_status = 20
                and     d1.component_sequence_id is not NULL
                and     d1.primary_uom_quantity <> 0
		and     d2.config_group_id = USERENV('SESSIONID')
		and     d2.demand_type = 1
		and     d2.demand_source_type = 2
		and     d2.demand_source_header_id = d1.demand_source_header_id
		and     d2.demand_source_line = d1.rto_model_source_line
		and     d2.primary_uom_quantity <> 0
                and     si1.organization_id = d1.organization_id
                and     si1.inventory_item_id = d1.inventory_item_id
                and     si1.bom_item_type in (1,2) /* model or option class */
                and     b1.organization_id = d1.organization_id
                and     b1.assembly_item_id = d1.inventory_item_id
                and     b1.alternate_bom_designator is NULL
                and     ic1.bill_sequence_id = b1.common_bill_sequence_id
                and     ic1.optional = 2
                and     ic1.effectivity_date <= GREATEST(NVL(d2.estimated_release_date,
						SYSDATE),SYSDATE)
                and     ic1.implementation_date is not null
                and     NVL(ic1.disable_date,NVL(d2.estimated_release_date,
			  SYSDATE)+ 1) > NVL(d2.estimated_release_date,SYSDATE)
                and     si2.inventory_item_id = ic1.component_item_id
                and     si2.organization_id = b1.organization_id
                and     si2.bom_item_type = 4        /* standard */
                and     or1.assembly_item_id = b1.assembly_item_id
                and     or1.organization_id = b1.organization_id
                and     or1.alternate_routing_designator is NULL
                and    nvl(or1.cfm_routing_flag,2) = nvl(b.cfm_routing_flag,2) /*ensure correct OC rtgs*/
                and     os1.effectivity_date <= GREATEST(NVL(d2.estimated_release_date,
						SYSDATE),SYSDATE)
                and     NVL(os1.disable_date,NVL(d2.estimated_release_date,
			  SYSDATE)+ 1) > NVL(d2.estimated_release_date,SYSDATE)
                and     os1.routing_sequence_id = or1.common_routing_sequence_id
                and     os1.option_dependent_flag = 1
                and     os1.operation_seq_num = ic1.operation_seq_num
                and    NVL(os1.eco_for_production,2) = 2
                and    ( os1.operation_type =1 OR os1.operation_type is NULL);




        	/*
		** Check for duplicated operation sequence number with
        	** the same routing in the BOM_OP_SEQUENCE_INTERFACE.
        	** For the rows with the same operation sequence num, operation
           	** type and routing sequence id, the Model row will be kept and
           	** the option class's row will be deleted. If the duplicates
                ** are from with in the option classes themseleves, the first row
                ** will be kept and the rest will be deleted.
                */

		stmt_num := 155;

                save_routing_id := 0;
                save_op_seq_num := 0;
                save_op_seq_id := 0;
                save_op_type   := 0;
                open    dd;

                loop
                           fetch dd into op_seq_id,op_seq_num,op_type,routing_id,item_type;
                           exit when (dd%notfound);

                           if save_routing_id = routing_id and
                              save_op_seq_num = op_seq_num and
                              save_op_type    = op_type  then
                                   delete from BOM_OP_SEQUENCES_INTERFACE
                                   where operation_sequence_id = op_seq_id;
                           else
                                   save_routing_id := routing_id;
                                   save_op_seq_num := op_seq_num;
                                   save_op_type    := op_type;
                           end if;
                end loop;

                close dd;

                /* Now update the process_op_seq_id  and line_seq_id of
                ** all events to new operations sequence Ids (map).
                ** Old operation_sequence_ids are available in model_op_seq_id
                */

		stmt_num := 160;
                update bom_op_sequences_interface bos1
                set    process_op_seq_id = (
                       select  operation_sequence_id
                       from   bom_op_sequences_interface bos2,
                              bom_op_routings_interface b
                       where  bos1.process_op_seq_id = bos2.model_op_seq_id
                       and    bos1.routing_sequence_id = b.routing_sequence_id
                       and    bos1.routing_sequence_id = bos2.routing_sequence_id
                       and    b.set_id = to_char(to_number(USERENV('SESSIONID'))))
                 where bos1.operation_type = 1;

                update bom_op_sequences_interface bos1
                set    line_op_seq_id = (
                       select  operation_sequence_id
                       from   bom_op_sequences_interface bos2,
                              bom_op_routings_interface b
                       where  bos1.line_op_seq_id = bos2.model_op_seq_id
                       and    bos1.routing_sequence_id = b.routing_sequence_id
                       and    bos1.routing_sequence_id = bos2.routing_sequence_id
                       and    b.set_id = to_char(to_number(USERENV('SESSIONID'))))
                 where bos1.operation_type = 1;

        	/*
		** Delete routing from routing header interface if
           	** there is no operation associated with the routing
		*/

		stmt_num := 170;
		table_name := 'BOM_OP_ROUTINGS_INTERFACE';

        	delete from BOM_OP_ROUTINGS_INTERFACE b1
        	where  b1.routing_sequence_id not in
              		(select b2.routing_sequence_id
               		from BOM_OP_SEQUENCES_INTERFACE b2
	                where  b2.routing_sequence_id = b1.routing_sequence_id)
       and    b1.set_id = TO_CHAR(to_number(USERENV('SESSIONID')));

	        /*
		** Handle the selected operations that do not belong
		** to the routing of the model/option class.
                   man: This delete is not required.

                delete BOM_OP_SEQUENCES_INTERFACE si
                where   operation_seq_num not in
                        (select /o+ ORDERED o/
                             s.operation_seq_num
                        from
                             mtl_demand md,
                             mtl_system_items ms,
                             bom_operational_routings r,
                             bom_operation_sequences s,
			     bom_op_routings_interface ri
                        where ri.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
			and   ri.routing_sequence_id = si.routing_sequence_id
                        and   md.rto_model_source_line = ri.demand_source_line
                        and   md.config_status = 20
			and   md.primary_uom_quantity <> 0
                        and   ms.inventory_item_id = md.inventory_item_id
                        and   ms.bom_item_type in (1,2)
                        and   ms.organization_id = md.organization_id
                        and   r.assembly_item_id = md.inventory_item_id
                        and   r.organization_id = md.organization_id
                        and   r.alternate_routing_designator is NULL
                        and   s.routing_sequence_id = r.common_routing_sequence_id
                        and   s.effectivity_date <= SYSDATE
                        and   NVL(s.disable_date, SYSDATE+1) > SYSDATE);
                */


                /*
		** If the operation_seq_num that associated with
		** the config component and not belong to the
		** config routing, the operation_seq_num will be
		** set to 1.
		*/
		stmt_num := 175;

                update BOM_INVENTORY_COMPS_INTERFACE ci
                set ci.operation_seq_num = 1
		where not exists
               (select 'op seq exists in config routing'
               from
		       BOM_OP_SEQUENCES_INTERFACE oi,
                       BOM_OP_ROUTINGS_INTERFACE ri,
                       BOM_BILL_OF_MTLS_INTERFACE bi
               where ci.bill_sequence_id = bi.bill_sequence_id
               and   oi.operation_seq_num = ci.operation_seq_num
               and   oi.routing_sequence_id = ri.routing_sequence_id
               and   ri.assembly_item_id = bi.assembly_item_id
               and   ri.organization_id = bi.organization_id
               and   ri.alternate_routing_designator is NULL
               and   ri.set_id || '' = TO_CHAR(to_number(USERENV('SESSIONID')))
               and   bi.alternate_bom_designator is NULL
               and   bi.set_id ||''= TO_CHAR(to_number(USERENV('SESSIONID'))))
                and ci.bill_sequence_id in
                ( select bi2.bill_sequence_id
                  from bom_bill_of_mtls_interface bi2
                  where bi2.set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));


        	/*
		** If more than one row in the BOM_INVENTORY_COMPS_INTERFACE
           	** that contain the same     bill_sequence_id,
                **                           operation_seq_num and
                **                           component_item_id,
           	** those rows will be combined into a single row and the
		** accumulated COMPONENT_QUANTITY will be used in the row.
		*/

                        save_bill_id := 0;
                        save_op_seq_num := 0;
                        save_item_id := 0;
                        save_comp_seq_id := 0;
                        total_qty := 0;

		stmt_num := 0;
                        open cc;
                        loop
                           fetch cc into bill_id,op_seq_num,
			         comp_seq_id,item_id,qty;
                           exit when (cc%notfound);
                           if save_bill_id <> bill_id then
                                   /*
				   ** different bill and
				   ** not begining of the loop
				   */
                                   if total_qty <> 0 then
                                        update BOM_INVENTORY_COMPS_INTERFACE
                                        set component_quantity = total_qty
                                        where component_sequence_id =
					      save_comp_seq_id;
                                   end if;

                                   total_qty := qty;
                                   save_bill_id := bill_id;
                                   save_op_seq_num := op_seq_num;
                                   save_item_id := item_id;
                                   save_comp_seq_id := comp_seq_id;
                           else
                                   /*
				   ** same bill but different item
				   */
                                   if save_item_id <> item_id then
                                        update BOM_INVENTORY_COMPS_INTERFACE
                                        set component_quantity = total_qty
                                        where component_sequence_id
                                              = save_comp_seq_id;
                                        total_qty := qty;
                                   /*
				   ** same bill and item but different seq_num
				   */
                                   else
                                      if save_op_seq_num <> op_seq_num then
                                        update BOM_INVENTORY_COMPS_INTERFACE
                                        set component_quantity = total_qty
                                        where component_sequence_id
                                              = save_comp_seq_id;

                                        total_qty := qty;
                                      /*
				      ** duplicated one
				      */
                                      else
                                        delete BOM_INVENTORY_COMPS_INTERFACE
                                        where component_sequence_id
                                              = save_comp_seq_id;

                                        total_qty := total_qty + qty;
                                      end if;
                                   end if;
                                   save_bill_id := bill_id;
                                   save_op_seq_num := op_seq_num;
                                   save_item_id := item_id;
                                   save_comp_seq_id := comp_seq_id;
                            end if;
                        end loop;
                        /*
			** handle the last row here
			*/
			stmt_num := 180;
                        update BOM_INVENTORY_COMPS_INTERFACE
                        set component_quantity = total_qty
                        where component_sequence_id = save_comp_seq_id;
                        close cc;

		/*
		** Load operation resources interface table
		*/
		table_name := 'BOM_OP_RESOURCES_INTERFACE';
		stmt_num := 190;
                insert into BOM_OP_RESOURCES_INTERFACE
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
                        osi.operation_sequence_id, /* operation sequence id */
                        bor.resource_seq_num,
                        bor.resource_id,
                                                        /* resource id */
                        bor.activity_id,
                        bor.standard_rate_flag,
                        bor.assigned_units,
                        bor.usage_rate_or_amount,
                        bor.usage_rate_or_amount_inverse,
                        bor.basis_type,
                        bor.schedule_flag,
                        SYSDATE,                        /* last update date */
                        1,                              /* last updated by */
                        SYSDATE,                        /* creation date */
                        1,                              /* created by */
                        1,                              /* last update login */
                        bor.resource_offset_percent,
			bor.autocharge_type,
                        bor.attribute_category,
                        bor.attribute1,
                        bor.attribute2,
                        bor.attribute3,
                        bor.attribute4,
                        bor.attribute5,
                        bor.attribute6,
                        bor.attribute7,
                        bor.attribute8,
                        bor.attribute9,
                        bor.attribute10,
                        bor.attribute11,
                        bor.attribute12,
                        bor.attribute13,
                        bor.attribute14,
                        bor.attribute15,
                        NULL,                           /* request_id */
                        NULL,               /* program_application_id */
                        NULL,                           /* program_id */
                        NULL                   /* program_update_date */
                from
                        bom_op_sequences_interface osi,
                        bom_operation_resources bor,
                        bom_op_routings_interface b
                where
                        osi.routing_sequence_id = b.routing_sequence_id
                and     b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                and     osi.model_op_seq_id = bor.operation_sequence_id;



		/*
		** Insert into BOM_REF_DESGS_INTERFACE table
	 	*/
		stmt_num := 205;
		insert into BOM_REF_DESGS_INTERFACE
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
                         ATTRIBUTE15,
			 BILL_SEQUENCE_ID,
			 ASSEMBLY_ITEM_ID,
			 ALTERNATE_BOM_DESIGNATOR,
			 ORGANIZATION_ID,
			 COMPONENT_ITEM_ID,
			 OPERATION_SEQ_NUM
		)
		select
			 r.component_reference_designator,
			 SYSDATE,
		         1,
			 SYSDATE,
			 1,
			 1,
			 r.REF_DESIGNATOR_COMMENT,
			 NULL,
			 ic.COMPONENT_SEQUENCE_ID,
		 	 r.ACD_TYPE,
			 NULL,
			 NULL,
			 NULL,
			 NULL,
			 r.ATTRIBUTE_CATEGORY,
			 r.ATTRIBUTE1,
			 r.ATTRIBUTE2,
			 r.ATTRIBUTE3,
			 r.ATTRIBUTE4,
			 r.ATTRIBUTE5,
			 r.ATTRIBUTE6,
			 r.ATTRIBUTE7,
			 r.ATTRIBUTE8,
			 r.ATTRIBUTE9,
			 r.ATTRIBUTE10,
			 r.ATTRIBUTE11,
			 r.ATTRIBUTE12,
			 r.ATTRIBUTE13,
			 r.ATTRIBUTE14,
			 r.ATTRIBUTE15,
			 ic.BILL_SEQUENCE_ID,
			 ic.ASSEMBLY_ITEM_ID,
			 ic.ALTERNATE_BOM_DESIGNATOR,
			 ic.ORGANIZATION_ID,
			 ic.COMPONENT_ITEM_ID,
			 ic.operation_seq_num
		 from
			 bom_inventory_comps_interface ic,
			 bom_reference_designators r,
			 bom_bill_of_mtls_interface b
		 where  b.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
		 and    ic.bill_sequence_id = b.bill_sequence_id
		 and    r.component_sequence_id = ic.model_comp_seq_id
 		 and    nvl(r.acd_type,0) <> 3;

		/*
		** Update MTL_DESC_ELEM_VAL_INTERFACE table
		*/
		table_name := 'MTL_DESC_ELEM_VAL_INTERFACE';
		stmt_num := 210;
		update MTL_DESC_ELEM_VAL_INTERFACE i
                   set i.element_value =
                       ( select /*+ ORDERED */
			  NVL(max(v.element_value),i.element_value)
          		  from
               		     bom_bill_of_mtls_interface bi,
               		     bom_inventory_comps_interface bci,
                	     bom_inventory_components bc,
               		     bom_dependent_desc_elements be,
                             mtl_descr_element_values v
          		  where bi.set_id = TO_CHAR(to_number(USERENV('SESSIONID')))
                          and   bi.assembly_item_id = i.inventory_item_id
          		  and   bci.bill_sequence_id = bi.bill_sequence_id
          		  and   bc.component_sequence_id = bci.model_comp_seq_id
          		  and   be.bill_sequence_id = bc.bill_sequence_id
          		  and   be.element_name = i.element_name
          		  and   v.inventory_item_id = bci.component_item_id
          		  and   v.element_name = i.element_name)
                 where i.inventory_item_id =
                       (select inventory_item_id
          		from    mtl_system_items_interface m
                        where inventory_item_id = i.inventory_item_id
       		and   set_id = TO_CHAR(to_number(USERENV('SESSIONID'))));

	/*
	** Update descriptions of the config items in
	** the MTL_SYSTEM_ITEMS_INTERFACE
	*/
	stmt_num := 220;
        open    ee;

        loop
               	fetch ee into item_id,org_id;
               	exit when (ee%notfound);
		status := bmlupid_update_item_desc(item_id,org_id,error_message);
		if status <> 0 then
			raise UP_DESC_ERR;
		end if;
	end loop;
	close ee;
	return(1);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                return(1);
	WHEN UP_DESC_ERR then
	message_name := 'BOM_ATO_LOAD_ERROR';
	return(0);
        WHEN OTHERS THEN
        error_message := 'BOMPLDCB:'||to_char(stmt_num)||':'||substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_LOAD_ERROR';
        return(0);

    END bmldbrt_load_bom_rtg;
END BOMPLDCB;

/
