--------------------------------------------------------
--  DDL for Package Body BOMPMCFG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPMCFG" as
/* $Header: BOMMCFGB.pls 115.5 99/07/26 17:43:30 porting ship  $ */
function atodupl_check (
        model_line_id           number,
	sch_sesion_id           number,
	sch_grp_id		number,
        error_message   out     VARCHAR2,
        message_name    out     VARCHAR2
        )
return integer
is
configuration_item_id	   number;
model_detail_id    number;
org_id		   number;
stmt_num	   number;
uom_code	   varchar2(3);
order_type	   varchar2(30);
order_number	   number;
line_qty	   number;
status 		   number;
dupl_count	   number;
NO_MODEL_FOUND        EXCEPTION;
INSERT_ERROR 	      EXCEPTION;
CURSOR dupl_rows IS
	  select BAC1.config_item_id,BAC1.organization_id,sol1.unit_code,
			(sol1.ordered_quantity-nvl(sol1.cancelled_quantity,0)),
		 soh.order_number,sot.name,sod.line_detail_id
	  from BOM_ATO_CONFIGURATIONS BAC1, /* the duplicate  */
	       so_lines_all solp, /* Parent of the Model of processing if any */
	       so_lines_all sol1, /* processing     */
	       so_headers_all soh, /* to get the header info */
	       so_order_types_all sot,
	       so_line_details sod,
	       mtl_system_items msi,
	       bom_parameters bp
	  where BAC1.base_model_id = sol1.inventory_item_id
	  and   soh.header_id = sol1.header_id
	  and   sot.order_type_id = soh.order_type_id
	  and   sod.line_id = sol1.line_id
	  and   solp.line_id = nvl(sol1.link_to_line_id,sol1.line_id)
	  and   BAC1.organization_id = sod.warehouse_id
	  and   BAC1.component_item_id = sol1.inventory_item_id
	  and   bp.organization_id = BAC1.organization_id
	  and   msi.organization_id = BAC1.organization_id
	  and   msi.inventory_item_id = BAC1.config_item_id
	  and   msi.inventory_item_status_code <> bp.bom_delete_status_code
	  and   not exists (select 'Extra options in Order'
		    from so_lines_all sol5 /* current */
		    where sol5.ato_line_id = sol1.line_id
		    and sol5.ordered_quantity > nvl(sol5.cancelled_quantity,0)
		    and   sol5.inventory_item_id not in
		   (select BAC2.component_item_id
		    from BOM_ATO_CONFIGURATIONS BAC2 /* duplicates */
		    where BAC2.config_item_id = BAC1.config_item_id
		    and   BAC2.component_item_id <> BAC1.component_item_id
		    and   BAC2.component_item_id = sol5.inventory_item_id
		    and   BAC2.component_code =
			decode(sol1.link_to_line_id,NULL,sol5.component_code,
			 substrb(sol5.component_code,
			     lengthb(solp.component_code)+2))
	            and   BAC2.COMPONENT_QUANTITY =
	             ((sol5.ordered_quantity-nvl(sol5.cancelled_quantity,0))/
		     (sol1.ordered_quantity-nvl(sol1.cancelled_quantity,0)))
		    )
			    )
          and not exists(select 'X'
                 from BOM_ATO_CONFIGURATIONS BAC3  /* duplicates */
                 where BAC3.config_item_id = BAC1.config_item_id
                 and   BAC3.component_item_id <> BAC1.component_item_id
                 having count(*) <> (select count (*)
                    from so_lines_all sol7  /* processing  */
                    where sol7.ato_line_id = sol1.line_id
                    and   sol7.ordered_quantity>nvl(sol7.cancelled_quantity,0)
	           )
			 )
          and    sol1.line_id = model_line_id;
begin
	dupl_count := 0;
	stmt_num := 10;
	open dupl_rows;
	LOOP
	stmt_num := 20;
	fetch dupl_rows into configuration_item_id,org_id,uom_code,line_qty,
	      order_number,order_type,model_detail_id;
	exit when (dupl_rows%notfound);
	dupl_count := dupl_count + 1;

	stmt_num := 30;
	update bom_ato_configurations
	set last_referenced_date = SYSDATE
	where config_item_id = configuration_item_id;

	status := BOMPMCFG.insert_mtl_dem_interface(configuration_item_id,org_id,
			sch_sesion_id,sch_grp_id,model_line_id,model_detail_id,
			uom_code,line_qty,order_number,order_type,
			error_message,message_name
			);

	if status <> 1 THEN
	RAISE INSERT_ERROR;
	end if;

	END LOOP;
	if dupl_count = 0 THEN
	raise NO_MODEL_FOUND;
	end if;

	return (1);
exception
	when NO_MODEL_FOUND THEN
	configuration_item_id := NULL;
	error_message := 'BOMPMCFG:' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
	return (100);

	when INSERT_ERROR THEN
	error_message := 'BOMPMCFG:insert_mtl_demand_interface';
	return (200);

	when NO_DATA_FOUND THEN
	configuration_item_id := NULL;
	return(1);
	when OTHERS THEN

	error_message := 'BOMPMCFG' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
	return(300);
end;

function insert_mtl_dem_interface(
	configuration_item_id	in	number,	    /* Item ID of Configuration */
	org_id		in      number,    /* Org id of the config item */
	sch_session_id  in      number,    /* Session id for insert */
	sch_grp_id	in      number,   /* Schedule group id */
	model_line_id	in      number,  /* Model line id */
	model_detail_id in	number, /* Model line detail id */
	uom_code	in	varchar2,
	line_qty	in	number,
	order_number    in 	number,
	order_type      in      varchar2,
        error_message   out     VARCHAR2,  /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2 /* 30 bytes to hold returned name */
	)
return integer
is
stmt_num 	number;
begin
	stmt_num := 100;
	insert into mtl_demand_interface(
					SCHEDULE_GROUP_ID
                                    ,   SESSION_ID
                                    ,   LOCK_FLAG
				    ,   ATP_CHECK
				    ,   CHECK_ATR
				    ,   DETAIL_RESERVE_FLAG
				    ,   C_COLUMN2
				    , 	C_COLUMN3
				    ,   VALIDATE_ROWS
                                    ,   ACTION_CODE
                                    ,   TRANSACTION_MODE
                                    ,   PROCESS_FLAG
                                    ,   LAST_UPDATE_DATE
                                    ,   CREATION_DATE
                                    ,   LAST_UPDATED_BY
                                    ,   CREATED_BY
                                    ,   LAST_UPDATE_LOGIN
                                    ,   LINE_ITEM_UOM
                                    ,   LINE_ITEM_QUANTITY
                                    ,   ORGANIZATION_ID
                                    ,   INVENTORY_ITEM_ID
				    ,   DEMAND_SOURCE_TYPE
				    ,   DEMAND_SOURCE_LINE
				    ,   DEMAND_SOURCE_DELIVERY
				    ,   REQUIREMENT_DATE
				    ,   DEMAND_HEADER_SEGMENT1
				    ,   DEMAND_HEADER_SEGMENT2
				    ,   DEMAND_HEADER_SEGMENT3
					)
	values(
					sch_grp_id, /* Sch group_id */
					sch_session_id, /* Session id */
					2, /* Lock flag */
					2, /* ATP check */
					1, /* Check ATR */
					2, /* Detail Reserve Flag */
					'Y', /*C column 2 */
					'Y', /* C column 3 */
					2, /* Validate rows */
					610, /* Action code */
					1, /* Transaction Mode */
					1, /* Process Flag */
					SYSDATE, /* Last_update_date */
					SYSDATE, /* creation date */
					1, /* last updated by */
					1, /* Created by */
					1, /* Last update login */
					uom_code, /* Line item UOM */
					line_qty, /* Line item quantity */
					org_id, /* Organization id */
					configuration_item_id, /* Inventory item id */
					2, /* Demand Source Type */
/* Demand src line */		        to_char(model_line_id),
/*demand src delivery*/			to_char(model_detail_id),
			                SYSDATE, /* Requirement Date */
					order_number,
					order_type,
					'ORDER ENTRY'
		);

return(1);
exception
	when OTHERS THEN
	error_message := 'BOMPMCFG' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
	return(400);
end;


function can_configurations(
	prg_appid in number,
	prg_id in number,
	req_id in number,
	user_id in number,
	login_id in number,
        error_message out  varchar2,
        message_name  out  varchar2,
        table_name    out  varchar2
        )
return integer
is
stmt_num     number;
begin
	stmt_num := 500;
	insert into BOM_ATO_CONFIGURATIONS(
		organization_id,
		base_model_id,
	 	config_item_id,
		component_item_id,
		component_quantity,
		component_code,
		last_referenced_date,
		creation_date,
		created_by,
		last_update_login,
		last_updated_by,
		last_update_date,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
                cfm_routing_flag)
	select
		m.organization_id,
		m.base_item_id,
		m.inventory_item_id,
		s2.inventory_item_id,
		(s2.ordered_quantity-nvl(s2.cancelled_quantity,0))/
		(s1.ordered_quantity-nvl(s1.cancelled_quantity,0)),
		decode(s1.link_to_line_id,NULL,s2.component_code,
		     substrb(s2.component_code,lengthb(s3.component_code)+2)),
		SYSDATE,
		SYSDATE,
		user_id,
		login_id,
		user_id,
		SYSDATE,
		req_id,
		prg_appid,
		prg_id,
		SYSDATE,
                bor.cfm_routing_flag
	from
	     so_lines_all s3, /* Parent of the ATO Model if any */
	     so_lines_all s2, /* Options or Option Classes */
	     so_lines_all s1, /* Model */
             bom_operational_routings bor,
             mtl_system_items_interface m
	where m.set_id             = USERENV('SESSIONID')
	and   m.base_item_id       = s1.inventory_item_id
	and   m.demand_source_line = s1.line_id
        and   m.base_item_id       = bor.assembly_item_id (+)
        and   m.organization_id    = bor.organization_id (+)
        and   bor.alternate_routing_designator (+) is NULL
	and   (s2.ato_line_id = s1.line_id
		or s2.line_id = s1.line_id)
	and   s2.ordered_quantity > NVL(s2.cancelled_quantity,0)
	and   s3.line_id = nvl(s1.link_to_line_id,s1.line_id);

return(1);
exception
	when OTHERS THEN
        error_message := 'BOMPMCFG' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        table_name := 'SO_LINES_ALL';
        return(0);
end;


function existing_dupl_match (
        error_message   out     VARCHAR2,
        message_name    out     VARCHAR2,
        table_name      out     VARCHAR2
        )
return integer
is
stmt_num	   number;
NO_MODEL_FOUND        EXCEPTION;
begin
	/*
	** This function searches
        ** for an existing configuration that meets the requirements
	** of orders being processed in this run of Create Configuration
	*/

	stmt_num :=600;
	update mtl_demand m
	set m.duplicated_config_item_id = (
	select BAC1.config_item_id
	  from BOM_ATO_CONFIGURATIONS BAC1, /* the duplicate  */
	       so_lines_all solp, /* Parent of ATO Model if any */
	       so_lines_all sol1, /* processing     */
	       mtl_system_items msi,
	       bom_parameters bp
	  where BAC1.base_model_id = sol1.inventory_item_id
	  and   BAC1.organization_id = sol1.warehouse_id
	  and   BAC1.component_item_id = sol1.inventory_item_id
	  and   bp.organization_id = BAC1.organization_id
	  and   solp.line_id = nvl(sol1.link_to_line_id,sol1.line_id)
	  and   msi.organization_id = BAC1.organization_id
	  and   msi.inventory_item_id = BAC1.config_item_id
	  and   msi.inventory_item_status_code <> bp.bom_delete_status_code
	  and   not exists (select 'X'
		    from so_lines_all sol5 /* current */
		    where sol5.ato_line_id = sol1.line_id
		    and sol5.ordered_quantity > nvl(sol5.cancelled_quantity,0)
		    and   sol5.inventory_item_id not in
		   (select BAC2.component_item_id
		    from BOM_ATO_CONFIGURATIONS BAC2 /* duplicates */
		    where BAC2.config_item_id = BAC1.config_item_id
		    and   BAC2.component_item_id <> BAC1.component_item_id
		    and   BAC2.component_item_id = sol5.inventory_item_id
		    and   BAC2.component_code =
			decode(sol1.link_to_line_id,NULL,sol5.component_code,
			  substrb(sol5.component_code,
				lengthb(solp.component_code)+2))
	      and   BAC2.COMPONENT_QUANTITY =
	             ((sol5.ordered_quantity-nvl(sol5.cancelled_quantity,0))/
		     (sol1.ordered_quantity-nvl(sol1.cancelled_quantity,0)))
		    )
			    )
         and not exists(select 'X'
                 from BOM_ATO_CONFIGURATIONS BAC3  /* duplicates */
                 where BAC3.config_item_id = BAC1.config_item_id
                 and   BAC3.component_item_id <> BAC1.component_item_id
                 having count(*) <> (select count (*)
                    from so_lines_all sol7  /* processing  */
                    where sol7.ato_line_id = sol1.line_id
                    and   sol7.ordered_quantity>nvl(sol7.cancelled_quantity,0)
                                     )
                   )
          and    sol1.line_id = m.demand_source_line
	  and    rownum = 1
			                        )
	  where m.config_group_id = USERENV('SESSIONID')
	  and   m.demand_type = 1
	  and   m.duplicated_config_item_id is NULL;

	stmt_num := 700;
	update bom_ato_configurations
	set last_referenced_date = SYSDATE
	where config_item_id in (select m.duplicated_config_item_id
				from mtl_demand m
			 	where m.config_group_id = USERENV('SESSIONID')
				and m.demand_type = 1
				and m.duplicated_config_item_id is not NULL);

	return (1);
exception
	when NO_MODEL_FOUND THEN
	error_message := 'BOMPMCFG:' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        table_name := 'MTL_DEMAND';
	return (0);

	when NO_DATA_FOUND THEN
	return(1);
	when OTHERS THEN

	error_message := 'BOMPMCFG' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        table_name := 'SO_LINES_ALL';
	return(0);
end;

end BOMPMCFG;

/
