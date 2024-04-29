--------------------------------------------------------
--  DDL for Package Body CTO_TRANSFER_PRICE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_TRANSFER_PRICE_PK" as
/* $Header: CTOTPRCB.pls 120.2 2005/10/28 15:20:16 rekannan noship $*/

/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOTPRCB.pls
|DESCRIPTION : Contains modules to :
|		1. Get the optional components of a configuration item from either the sales order or the BOM
|		2. Calculate Transfer Price for a configuration item
|
|HISTORY     : Created on 29-AUG-2003  by Sajani Sheth
|              Modifed on 28-JAN-2004  by Renga  Kannan
|                                         The bom qty was not cosidered during rollup ,
|                                         Also UOM conversion was not considered. Fixed this issue
|
+-----------------------------------------------------------------------------*/

 G_PKG_NAME CONSTANT VARCHAR2(30) := 'CTO_TRANSFER_PRICE_PK';
 PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);
 g_configs_only varchar2(1);
 g_item_id number;

/***********************************************************************
This procedure returns the optional components of a configuration item
and its child configuration items, based on either a sales order or the
configuration BOM.
If the parameter p_configs_only is 'Y', only child configuration items
are returned.
Config BOMs created before Patchset-I do not have optional_on_model flag
populated. For these configs, all components will be treated as mandatory
and so, no components will be returned.
The optional components are populated in table bom_explosion_temp with
a unique group_id. The group_id is passed back to the calling application.
***********************************************************************/
PROCEDURE get_config_details
(
p_item_id IN number,
p_org_id IN number default NULL,
p_mode_id IN number default 3,
p_configs_only IN varchar2 default 'N',
p_line_id      IN Number default null,
x_group_id OUT NOCOPY number,
x_msg_count OUT NOCOPY number,
x_msg_data OUT NOCOPY varchar2,
x_return_status OUT NOCOPY varchar)

IS

x_grp_id	number;
p_ato_line_id	number;
p_organization_id 	number;
lStmtNumber	number;
l_line_id	number;

BEGIN

	lStmtNumber := 10;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('get_config_details:entering');
		oe_debug_pub.add('get_config_details:ItemId::'||to_char(p_item_id));
		oe_debug_pub.add('get_config_details:ModeId::'||to_char(p_mode_id));
		oe_debug_pub.add('get_config_details:ConfigsOnly::'||p_configs_only);
	END IF;

	g_configs_only := p_configs_only;
	g_item_id := p_item_id;

	IF p_mode_id = 1 THEN
		lStmtNumber := 20;
		-- mode is OM
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:Mode is OM');
		END IF;

		BEGIN
		/*select ato_line_id
		into p_ato_line_id
		from bom_cto_order_lines
		where config_item_id = p_item_id
		and rownum = 1;*/

                If p_line_id is  null then
		   select line_id
		   into l_line_id
		   from bom_cto_order_lines bcol
		   where config_item_id = p_item_id
		   and  exists (select 'x'
		                from oe_order_lines_all oel
				where oel.header_id = bcol.header_id
				and   oel.ato_line_id = bcol.ato_line_id
				and   oel.item_type_code = 'CONFIG')
		   and rownum = 1;
		Else
		   l_line_id := p_line_id;
		End if;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:l_line_id::'||to_char(l_line_id));
		END IF;

		EXCEPTION
		WHEN no_data_found THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:NDF:Mode is OM and no order line for this item.', 1);
			END IF;
			raise FND_API.G_EXC_ERROR;
		END;

		lStmtNumber := 30;
		select bom_explosion_temp_s.nextval
    		into   x_grp_id
    		from dual;

		x_group_id := x_grp_id;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:Grp Id::'||to_char(x_group_id));
		END IF;

		lStmtNumber := 40;

		get_config_details_bcol
			(l_line_id,
			 x_grp_id,
			 x_msg_count,
			 x_msg_data,
			 x_return_status);

		IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:get_config_details_bcol returned with unexp error',1);
			END IF;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:get_config_details_bcol returned with exp error',1);
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

	ELSIF p_mode_id = 2 THEN

		lStmtNumber := 50;
		-- mode is BOM
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:Mode is BOM');
		END IF;

		BEGIN
		select organization_id
		into p_organization_id
		from bom_bill_of_materials
		where assembly_item_id = p_item_id
		and rownum = 1;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:p_organization_id::'||to_char(p_organization_id));
		END IF;

		EXCEPTION
		WHEN no_data_found THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:NDF:Mode is BOM and no BOM exists for this item.', 1);
			END IF;
			raise FND_API.G_EXC_ERROR;
		END;

		lStmtNumber := 60;
		select bom_explosion_temp_s.nextval
    		into   x_grp_id
    		from dual;

		x_group_id := x_grp_id;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:xsGrp Id::'||to_char(x_group_id));
		END IF;

		lStmtNumber := 70;
		get_config_details_bom
			(p_item_id,
			 p_organization_id,
			 x_grp_id,
			 x_msg_count,
			 x_msg_data,
			 x_return_status);

		IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:get_config_details_bom returned with unexp error',1);
			END IF;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:get_config_details_bom returned with exp error',1);
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

	ELSE

		-- mode is BOTH, check in OM first and then BOM
		lStmtNumber := 80;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:Mode is BOTH');
			oe_debug_pub.add(' P_line_id = '||to_char(p_line_id),1);
		END IF;

		BEGIN
		If p_line_id is  null Then
		   select line_id
		   into l_line_id
		   from bom_cto_order_lines bcol
		   where config_item_id = p_item_id
		   and exists (select 'x'
		               from oe_order_lines_all oel
			       where oel.header_id = bcol.header_id
			       and   oel.ato_line_id = bcol.ato_line_id
			       and   oel.item_type_code = 'CONFIG')
		   and rownum = 1;
		 Else
                    l_line_id := p_line_id;
		 End if;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:Config found in bcol, getting details from bcol');
			oe_debug_pub.add('get_config_details:l_line_id::'||to_char(l_line_id));
		END IF;

		lStmtNumber := 90;
		select bom_explosion_temp_s.nextval
    		into   x_grp_id
    		from dual;

		x_group_id := x_grp_id;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:Grp Id::'||to_char(x_group_id));
		END IF;

		lStmtNumber := 100;
		get_config_details_bcol
			(l_line_id,
			 x_grp_id,
			 x_msg_count,
			 x_msg_data,
			 x_return_status);

		IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:get_config_details_bcol returned with unexp error',1);
			END IF;
			raise FND_API.G_EXC_UNEXPECTED_ERROR;

		ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:get_config_details_bcol returned with exp error',1);
			END IF;
			raise FND_API.G_EXC_ERROR;
		END IF;

		EXCEPTION
		  WHEN NO_DATA_FOUND THEN
			-- config does not exist in bcol, check in BOM

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:Mode is BOM');
			END IF;

			lStmtNumber := 110;
			BEGIN
			select organization_id
			into p_organization_id
			from bom_bill_of_materials
			where assembly_item_id = p_item_id
			and rownum = 1;

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:p_organization_id::'||to_char(p_organization_id));
			END IF;

			EXCEPTION
			WHEN no_data_found THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_config_details:NDF:Mode is BOTH, but no order line and no BOM exists for this item.', 1);
				END IF;
				raise FND_API.G_EXC_ERROR;
			END;

			lStmtNumber := 120;
			select bom_explosion_temp_s.nextval
    			into   x_grp_id
    			from dual;

			x_group_id := x_grp_id;

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('get_config_details:Grp Id::'||to_char(x_group_id));
			END IF;

			lStmtNumber := 130;
			get_config_details_bom
				(p_item_id,
				 p_organization_id,
				 x_grp_id,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);

			IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_config_details:get_config_details_bom returned with unexp error',1);
				END IF;
				raise FND_API.G_EXC_UNEXPECTED_ERROR;

			ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add('get_config_details:get_config_details_bom returned with exp error',1);
				END IF;
				raise FND_API.G_EXC_ERROR;
			END IF;

		END; -- sub block

	END IF; -- mode

IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add('get_config_details:returning with status',1);
END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:unexp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:unexp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:exp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
			(p_msg_count => x_msg_count
			,p_msg_data  => x_msg_data);

	WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details:others::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			, 'get_config_details'
            			);
        	END IF;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

END; /* get_config_details */


/***********************************************************************
This procedure returns the optional components of a configuration item
and its child configuration items, based on a sales order. The optional
components are populated in table bom_explosion_temp for input parameter
group_id. If p_configs_only = 'Y', only child configuration items are
returned.
***********************************************************************/
PROCEDURE get_config_details_bcol
(p_line_id IN NUMBER,
p_grp_id IN NUMBER,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2)

IS

lStmtNumber	number;
l_sort		number := 0;
rowcount	number;

-- rkaza. 04/28/2005.
-- In the case of populating bet from an order, we used to populate
-- organization_id as 1 for all the lines. Now we will be populating the oe
-- validation org id of the lines OU. Populating a valid organization_id here
-- will be later useful in improving performance when making any joins with
-- bet (especially join with msi in cost rollup to get cib attribute of the
-- config's model. In this case model definitely exists in the
-- oe_validation_org of the order lines OU)
-- Also, there might be some single org ct's who may not set oe validation org
-- for the OU. In which case, we will populate ship_from_org_id.

l_oeval_org_id number;
cursor get_oeval_org_id is
   select to_number( nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , org_id) , ship_from_org_id))
   from oe_order_lines_all
   where line_id = p_line_id;

BEGIN

	lStmtNumber := 10;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        open get_oeval_org_id;
        fetch get_oeval_org_id into l_oeval_org_id;
        close get_oeval_org_id;

        If PG_DEBUG <> 0 Then
	   cto_wip_workflow_api_pk.cto_debug('get_config_details_bcol:', 'entering');
	   cto_wip_workflow_api_pk.cto_debug('get_config_details_bcol:', 'p_grp_id::'||to_char(p_grp_id));
	   cto_wip_workflow_api_pk.cto_debug('get_config_details_bcol:', 'p_line_id::'||to_char(p_line_id));
        End if;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('get_config_details_bcol:entering');
		oe_debug_pub.add('get_config_details_bcol:p_grp_id::'||to_char(p_grp_id));
		oe_debug_pub.add('get_config_details_bcol:p_line_id::'||to_char(p_line_id));
		oe_debug_pub.add('get_config_details_bcol:l_oeval_org_id::'||to_char(l_oeval_org_id));
	END IF;

	IF (g_configs_only = 'N') THEN
		-- insert details from order lines
		lStmtNumber := 20;
    		insert into bom_explosion_temp(
			top_bill_sequence_id,	-- not null
        		bill_sequence_id, 	-- not null
        		organization_id, 	-- not null
        		sort_order, 		-- not null
			assembly_item_id,
        		component_item_id,
			optional,
        		plan_level, 		-- not null
			component_quantity,
			configurator_flag,
			line_id,
			primary_uom_code,
        		group_id)
		select
			1, 			-- top_bill_sequence_id
			1,			-- bill_sequence_id
			l_oeval_org_id, 	-- organization_id
			l_sort,			-- sort
			bcol2.config_item_id,	-- assembly_item_id
			decode(bcol1.config_item_id, null, bcol1.inventory_item_id, bcol1.config_item_id),			-- component_item_id
			1,			-- optional
			bcol1.plan_level - bcol2.plan_level,	-- plan_level
			bcol1.ordered_quantity/bcol2.ordered_quantity, -- comp qty
			decode(bcol1.config_item_id, null, 'N', 'Y'), 	-- config flag
			bcol1.line_id,		-- line_id
			bcol1.order_quantity_uom,	--primary_uom_code
			p_grp_id
		from
			bom_cto_order_lines bcol1	-- component
			,bom_cto_order_lines bcol2	-- parent model
		where 	bcol1.parent_ato_line_id = p_line_id
		and 	bcol1.parent_ato_line_id <> bcol1.line_id
		and	bcol2.line_id = p_line_id
		UNION
		select
			1, 			-- top_bill_sequence_id
			1,			-- bill_sequence_id
			l_oeval_org_id, 	-- organization_id
			l_sort,			-- sort
			bcol1.config_item_id,	-- assembly_item_id
			bcol1.inventory_item_id,-- component_item_id
			1,			-- optional
			bcol1.plan_level - bcol1.plan_level,
			bcol1.ordered_quantity/bcol1.ordered_quantity,	-- comp qty
			'N',			-- config flag
			bcol1.line_id,		-- line_id
			bcol1.order_quantity_uom,	--primary_uom_code
			p_grp_id
		from
			bom_cto_order_lines bcol1
		where 	bcol1.line_id = p_line_id
		;

		lStmtNumber := 30;
	        rowcount := 1 ;
	        WHILE rowcount > 0 LOOP

			l_sort := l_sort + 1;

			insert into bom_explosion_temp(
				top_bill_sequence_id,	-- not null
        			bill_sequence_id, 	-- not null
        			organization_id, 	-- not null
        			sort_order, 		-- not null
				assembly_item_id,
        			component_item_id,
				optional,
        			plan_level, 		-- not null
				component_quantity,
				configurator_flag,
				line_id,
				primary_uom_code,
        			group_id)
			select
				1, 			-- top_bill_sequence_id
				1,			-- bill_sequence_id
				l_oeval_org_id, 	-- organization_id
				l_sort,			-- sort
				bcol2.config_item_id,	-- assembly_item_id
				decode(bcol1.config_item_id, null, bcol1.inventory_item_id, bcol1.config_item_id),			-- component_item_id
				1,			-- optional
				bcol1.plan_level - bcol2.plan_level + bet.plan_level,	-- plan_level
				bcol1.ordered_quantity/bcol2.ordered_quantity, -- comp qty
				decode(bcol1.config_item_id, null, 'N', 'Y'), 	-- config flag
				bcol1.line_id,		-- line_id
				bcol1.order_quantity_uom,	--primary_uom_code
				p_grp_id
			from
				bom_cto_order_lines bcol1	-- component
				,bom_cto_order_lines bcol2	-- parent model
				,bom_explosion_temp bet
			where 	bcol1.parent_ato_line_id = bet.line_id
			and	bcol2.line_id = bet.line_id
			and 	bet.group_id = p_grp_id
			and 	bet.sort_order = to_char(l_sort - 1)
			and 	nvl(bet.configurator_flag, 'N') = 'Y'
			UNION
			select
				1, 			-- top_bill_sequence_id
				1,			-- bill_sequence_id
				l_oeval_org_id, 	-- organization_id
				l_sort,			-- sort
				bcol1.config_item_id,	-- assembly_item_id
				bcol1.inventory_item_id,-- component_item_id
				1,			-- optional
				bcol1.plan_level - bcol1.plan_level + bet.plan_level,
				bcol1.ordered_quantity/bcol1.ordered_quantity,	-- comp qty
				'N',			-- config flag
				bcol1.line_id,		-- line_id
				bcol1.order_quantity_uom,	--primary_uom_code
				p_grp_id
			from
				bom_cto_order_lines bcol1
				,bom_explosion_temp bet
			where 	bcol1.line_id = bet.line_id
			and 	bet.group_id = p_grp_id
			and 	bet.sort_order = to_char(l_sort - 1)
			and 	nvl(bet.configurator_flag, 'N') = 'Y'
			;

			rowcount := SQL%ROWCOUNT;

			IF PG_DEBUG <> 0 THEN
	           		oe_debug_pub.add ('get_config_details_bcol:Row Count : '   || rowcount, 2);
			        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:', 'Row Count:'||rowcount);

			END IF;

	        END LOOP;

	ELSE /* configs_only = Y */
		lStmtNumber := 40;
    		insert into bom_explosion_temp(
			top_bill_sequence_id,	-- not null
        		bill_sequence_id, 	-- not null
        		organization_id, 	-- not null
        		sort_order, 		-- not null
			assembly_item_id,
        		component_item_id,
			optional,
        		plan_level, 		-- not null
			component_quantity,
			configurator_flag,
			line_id,
			primary_uom_code,
        		group_id)
		select
			1, 			-- top_bill_sequence_id
			1,			-- bill_sequence_id
			l_oeval_org_id, 	-- organization_id
			l_sort,			-- sort
			bcol2.config_item_id,	-- assembly_item_id
			decode(bcol1.config_item_id, null, bcol1.inventory_item_id, bcol1.config_item_id),			-- component_item_id
			1,			-- optional
			bcol1.plan_level - bcol2.plan_level,	-- plan_level
			bcol1.ordered_quantity/bcol2.ordered_quantity, -- comp qty
			decode(bcol1.config_item_id, null, 'N', 'Y'), 	-- config flag
			bcol1.line_id,		-- line_id
			bcol1.order_quantity_uom,	--primary_uom_code
			p_grp_id
		from
			bom_cto_order_lines bcol1	-- component
			,bom_cto_order_lines bcol2	-- parent model
		where 	bcol1.parent_ato_line_id = p_line_id
		and 	bcol1.parent_ato_line_id <> bcol1.line_id
		and 	bcol1.config_item_id is not null
		and	bcol2.line_id = p_line_id
		;

		lStmtNumber := 30;
	        rowcount := 1 ;
	        WHILE rowcount > 0 LOOP

			l_sort := l_sort + 1;

			insert into bom_explosion_temp(
				top_bill_sequence_id,	-- not null
        			bill_sequence_id, 	-- not null
        			organization_id, 	-- not null
        			sort_order, 		-- not null
				assembly_item_id,
        			component_item_id,
				optional,
        			plan_level, 		-- not null
				component_quantity,
				configurator_flag,
				line_id,
				primary_uom_code,
        			group_id)
			select
				1, 			-- top_bill_sequence_id
				1,			-- bill_sequence_id
				l_oeval_org_id,         -- organization_id
				l_sort,			-- sort
				bcol2.config_item_id,	-- assembly_item_id
				decode(bcol1.config_item_id, null, bcol1.inventory_item_id, bcol1.config_item_id),			-- component_item_id
				1,			-- optional
				bcol1.plan_level - bcol2.plan_level + bet.plan_level,	-- plan_level
				bcol1.ordered_quantity/bcol2.ordered_quantity, -- comp qty
				decode(bcol1.config_item_id, null, 'N', 'Y'), 	-- config flag
				bcol1.line_id,		-- line_id
				bcol1.order_quantity_uom,	--primary_uom_code
				p_grp_id
			from
				bom_cto_order_lines bcol1	-- component
				,bom_cto_order_lines bcol2	-- parent model
				,bom_explosion_temp bet
			where 	bcol1.parent_ato_line_id = bet.line_id
			and	bcol1.config_item_id is not null
			and	bcol2.line_id = bet.line_id
			and 	bet.group_id = p_grp_id
			and 	bet.sort_order = to_char(l_sort - 1)
			and 	nvl(bet.configurator_flag, 'N') = 'Y'
			;

			rowcount := SQL%ROWCOUNT;

			IF PG_DEBUG <> 0 THEN
	           		oe_debug_pub.add ('get_config_details_bom:Row Count : '   || rowcount, 2);
			        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:', 'Row Count:'||rowcount);

			END IF;

	        END LOOP;

	END IF; /* configs only */

	lStmtNumber := 40;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('get_config_details_bcol:rows inserted into bom_expl_temp::'||to_char(sql%rowcount));
	        cto_wip_workflow_api_pk.cto_debug('get_config_details_bcol:', '
rows inserted into bom_expl_temp::'||to_char(sql%rowcount));

	END IF;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bcol:unexp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bcol:exp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
			(p_msg_count => x_msg_count
			,p_msg_data  => x_msg_data);

	WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bcol:others::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'get_config_details_bcol'
            			);
        	END IF;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

END; /* get_config_details_bcol */



/***********************************************************************
This procedure returns the optional components of a configuration item
and its child configuration items, based on the configuration BOM. The
optional components are populated in table bom_explosion_temp for
input parameter group_id.
***********************************************************************/
PROCEDURE get_config_details_bom
(p_item_id IN NUMBER,
p_organization_id IN NUMBER,
p_grp_id IN NUMBER,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2)

IS

l_sort	number := 0;
lStmtNumber number;
rowcount number;

BEGIN

	lStmtNumber := 10;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF PG_DEBUG <> 0 THEN
	        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:','entering');
	        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:','p_grp_id::'||to_char(p_grp_id));
	        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:','p_item_id::'||to_char(p_item_id));

		oe_debug_pub.add('get_config_details_bom:entering');
		oe_debug_pub.add('get_config_details_bom:p_grp_id::'||to_char(p_grp_id));
		oe_debug_pub.add('get_config_details_bom:p_item_id::'||to_char(p_item_id));
	END IF;

	IF (g_configs_only = 'N') THEN

		lStmtNumber := 20;

		-- insert top level config BOM
   		insert into bom_explosion_temp(
			top_bill_sequence_id,	-- not null
        		bill_sequence_id, 	-- not null
        		organization_id, 	-- not null
        		sort_order, 		-- not null
			assembly_item_id,
        		component_item_id,
			optional,
        		plan_level, 		-- not null
			component_quantity,
			configurator_flag,
			primary_uom_code,
        		group_id,
                        basis_type )   /* LBM Project change */
   		select  distinct
			bic.bill_sequence_id,
			bic.bill_sequence_id,
			p_organization_id,
			to_char(l_sort),	-- sort
			p_item_id,
        		bic.component_item_id,
			bic.optional_on_model,	-- optional
			nvl(bic.plan_level, 0),
			bic.component_quantity,
			decode(msi.base_item_id, NULL, 'N', decode(nvl(bic.model_comp_seq_id, bic.last_update_login), 0, 'N', NULL, 'N', abs(nvl(bic.model_comp_seq_id, bic.last_update_login)), 'Y', 'N')),		-- config_flag
			msi.primary_uom_code,	-- primary_uom_code
			p_grp_id,
                        bic.basis_type                       /* LBM Project change */
   		from
			bom_inventory_components bic,
			bom_bill_of_materials bbom,
			mtl_system_items msi
        	where 	bbom.assembly_item_id = p_item_id
		and	bbom.organization_id = p_organization_id
		and 	bbom.alternate_bom_designator is null
		and 	bbom.common_bill_sequence_id = bic.bill_sequence_id
		and 	nvl(bic.optional_on_model,2) = 1
		and 	msi.inventory_item_id = bic.component_item_id
		and	msi.organization_id = p_organization_id;


		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bom:rowcount::'||sql%rowcount);
		        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:', 'rowcount::'||sql%rowcount);

		END IF;

		lStmtNumber := 30;
	        rowcount := 1 ;
	        WHILE rowcount > 0 LOOP

		l_sort := l_sort + 1;

	    	insert into bom_explosion_temp(
			top_bill_sequence_id,	-- not null
	        	bill_sequence_id, 	-- not null
       		 	organization_id, 	-- not null
       		 	sort_order, 		-- not null
			assembly_item_id,
        		component_item_id,
			optional,
        		plan_level, 		-- not null
			component_quantity,
			configurator_flag,
			primary_uom_code,
        		group_id,
                        basis_type)             /* LBM Project change */
   		select  distinct
			bic.bill_sequence_id,
			bic.bill_sequence_id,
			bbom.organization_id,
			to_char(l_sort),	-- sort
			bet.component_item_id,
        		bic.component_item_id,
			bic.optional_on_model,	-- optional
			decode(bic.plan_level,null,(bet.plan_level+1),(bic.plan_level+bet.plan_level)),
			bic.component_quantity,
			decode(msi2.base_item_id, NULL, 'N', decode(nvl(bic.model_comp_seq_id, bic.last_update_login), 0, 'N', NULL, 'N', abs(nvl(bic.model_comp_seq_id, bic.last_update_login)), 'Y', 'N')),					-- config_flag
			msi2.primary_uom_code,	-- primary_uom_code
        		p_grp_id,
                        bic.basis_type       /* LBM Project change */
		from
        	        bom_inventory_components bic,
			bom_bill_of_materials bbom,
			bom_explosion_temp bet,
			mtl_system_items msi,	-- bet component join
			mtl_system_items msi2	-- bic component join
		where
			bbom.assembly_item_id = bet.component_item_id
		and	bbom.organization_id =
			(select bbom1.organization_id
			from bom_bill_of_materials bbom1
			where bbom1.assembly_item_id = bet.component_item_id
		   	and bbom1.alternate_bom_designator is null
			and rownum = 1)
		and 	bbom.common_bill_sequence_id = bic.bill_sequence_id
		and 	nvl(bic.optional_on_model,1) = 1
		and 	bet.group_id = p_grp_id
		and 	bet.sort_order = to_char(l_sort - 1)
		and 	bet.component_item_id = msi.inventory_item_id
		and	bbom.organization_id = msi.organization_id
		and  	nvl(bet.configurator_flag, 'N') = 'Y'
		and	msi.base_item_id is not null
		and 	msi.replenish_to_order_flag = 'Y'
		and 	msi2.inventory_item_id = bic.component_item_id
		and 	msi2.organization_id = bbom.organization_id;


		rowcount := SQL%ROWCOUNT;

		IF PG_DEBUG <> 0 THEN
	           	oe_debug_pub.add ('get_config_details_bom:Row Count : '   || rowcount, 2);
		        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:', 'Row Count:'||rowcount);

		END IF;

	        END LOOP;

	ELSE /* g_configs_only = Y */

		lStmtNumber := 40;

		-- insert configs from top level config BOM
   		insert into bom_explosion_temp(
			top_bill_sequence_id,	-- not null
        		bill_sequence_id, 	-- not null
        		organization_id, 	-- not null
        		sort_order, 		-- not null
			assembly_item_id,
        		component_item_id,
			optional,
        		plan_level, 		-- not null
			component_quantity,
			configurator_flag,
			primary_uom_code,
        		group_id,
                        basis_type)                     /* LBM Project change */
   		select  distinct
			bic.bill_sequence_id,
			bic.bill_sequence_id,
			p_organization_id,
			to_char(l_sort),	-- sort
			p_item_id,
        		bic.component_item_id,
			bic.optional_on_model,	-- optional
			nvl(bic.plan_level, 0),
			bic.component_quantity,
			'Y',			-- config flag
			msi.primary_uom_code,	-- primary_uom_code
			p_grp_id,
                        bic.basis_type                /* LBM Project change */
   		from
			bom_inventory_components bic,
			bom_bill_of_materials bbom,
			mtl_system_items msi
        	where 	bbom.assembly_item_id = p_item_id
		and	bbom.organization_id = p_organization_id
		and 	bbom.alternate_bom_designator is null
		and 	bbom.common_bill_sequence_id = bic.bill_sequence_id
		and	nvl(bic.model_comp_seq_id, bic.last_update_login) = abs(nvl(bic.model_comp_seq_id, bic.last_update_login))
		and 	msi.inventory_item_id = bic.component_item_id
		and	msi.organization_id = p_organization_id
		and 	msi.base_item_id is not null;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bom:rowcount::'||sql%rowcount);
		        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:', 'rowcount::'||sql%rowcount);

		END IF;

		lStmtNumber := 50;
	        rowcount := 1 ;
	        WHILE rowcount > 0 LOOP

		l_sort := l_sort + 1;

	    	insert into bom_explosion_temp(
			top_bill_sequence_id,	-- not null
	        	bill_sequence_id, 	-- not null
       		 	organization_id, 	-- not null
       		 	sort_order, 		-- not null
			assembly_item_id,
        		component_item_id,
			optional,
        		plan_level, 		-- not null
			component_quantity,
			configurator_flag,
			primary_uom_code,
        		group_id,
                        basis_type )        /* LBM Project change */
   		select  distinct
			bic.bill_sequence_id,
			bic.bill_sequence_id,
			bbom.organization_id,
			to_char(l_sort),	-- sort
			bet.component_item_id,
        		bic.component_item_id,
			bic.optional_on_model,	-- optional
			decode(bic.plan_level,null,(bet.plan_level+1),(bic.plan_level+bet.plan_level)),
			bic.component_quantity,
			'Y',			-- config flag
			msi.primary_uom_code,	-- primary_uom_code
        		p_grp_id,
                        bic.basis_type                 /* LBM Project change */
		from
        	        bom_inventory_components bic,
			bom_bill_of_materials bbom,
			bom_explosion_temp bet,
			mtl_system_items msi
		where
			bbom.assembly_item_id = bet.component_item_id
		and	bbom.organization_id =
			(select bbom1.organization_id
			from bom_bill_of_materials bbom1
			where bbom1.assembly_item_id = bet.component_item_id
		   	and bbom1.alternate_bom_designator is null
			and rownum = 1)
		and 	bbom.common_bill_sequence_id = bic.bill_sequence_id
		and	nvl(bic.model_comp_seq_id, bic.last_update_login) = abs(nvl(bic.model_comp_seq_id, bic.last_update_login))
		and 	bet.group_id = p_grp_id
		and 	bet.sort_order = to_char(l_sort - 1)
		and 	bic.component_item_id = msi.inventory_item_id
		and	bbom.organization_id = msi.organization_id
		and	msi.base_item_id is not null
		and 	msi.replenish_to_order_flag = 'Y';

		rowcount := SQL%ROWCOUNT;

		IF PG_DEBUG <> 0 THEN
	           	oe_debug_pub.add ('get_config_details_bom:Row Count : '   || rowcount, 2);
		        cto_wip_workflow_api_pk.cto_debug('get_config_details_bom:', 'Row Count:'||rowcount);

		END IF;

	        END LOOP;

	END IF; /* g_configs_only = N */

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bom:unexp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bom:exp error::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
			(p_msg_count => x_msg_count
			,p_msg_data  => x_msg_data);

	WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('get_config_details_bom:others::'||lStmtNumber||sqlerrm,1);
		END IF;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'get_config_details_bom'
            			);
        	END IF;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

END; /* get_config_details_bom */


/**************************************************************************
   Procedure:   Cto_Transfer_Price
   Parameters:  P_config_item_id
		P_selling_oper_unit
		P_shipping_oper_unit
		P_transaction_uom
		P_transaction_id
		P_price_list_id
		P_global_procurement_flag
		P_from_organization_id
		P_currency_code
		X_transfer_price
		X_return_status
		X_msg_count
		X_msg_data
   Description: This API calculates the transfer price for a
		configuration item by rolling up the transfer
		prices of its optional components.

*****************************************************************************/
Procedure Cto_Transfer_Price (
	p_config_item_id IN NUMBER,
	p_selling_oper_unit IN NUMBER,
	p_shipping_oper_unit IN NUMBER,
	p_transaction_uom IN VARCHAR2,
	p_transaction_id IN NUMBER,
	p_price_list_id IN NUMBER,
	p_global_procurement_flag IN VARCHAR2,
	p_from_organization_id IN NUMBER DEFAULT NULL,
	p_currency_code IN VARCHAR2 DEFAULT NULL,
	x_transfer_price OUT NOCOPY NUMBER,
	x_currency_code  out nocopy varchar2,
	x_return_status OUT NOCOPY VARCHAR2,
	x_msg_count OUT NOCOPY NUMBER,
	x_msg_data OUT NOCOPY VARCHAR2)

IS

x_group_id number;
--x_currency_code varchar2(30);
l_transfer_price number := 0;
lStmtNumber number;
l_base_item_id number;
l_build_in_wip varchar2(1);
l_current_item_id number := p_config_item_id;
l_prim_uom     Varchar2(3);

CURSOR c_options (l_item_id number) IS
select component_item_id
     , configurator_flag
     , component_quantity
     , primary_uom_code
from bom_explosion_temp
where group_id = x_group_id
and nvl(optional, 1) = 1
and assembly_item_id = l_item_id;

BEGIN
        If PG_DEBUG <> 0 Then
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Entering');
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'p_config_item_id::'||to_char(p_config_item_id));
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'l_current_item_id::'||to_char(l_current_item_id));
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'p_selling_oper_unit::'||to_char(p_selling_oper_unit));
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'p_shipping_oper_unit::'||to_char(p_shipping_oper_unit));
           cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'p_from_organization_id::'||to_char(p_from_organization_id));
        End if;

	--
	-- validate config
	--

        -- Modified by Renga Kannan
        -- on 01/21/04. We should not check the
        -- item from shipping operating unit. Shippin operating unit need not be an inventory organization.
        -- But, there is an inventory org associate with each operating unit in the transaction flow. we shoule
        -- use this that inventory org now. The inventory org is passed in parameter p_from_organization_id.

	select base_item_id,
	       build_in_wip_flag,
	       Primary_uom_code
	into   l_base_item_id,
	       l_build_in_wip,
	       l_prim_uom
	from mtl_system_items
	where inventory_item_id = p_config_item_id
	and organization_id = p_from_organization_id; -- org to create the AR
        If PG_DEBUG <> 0 Then
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'base_item_id::'||l_base_item_id);
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'build_in_wip_flag::'||l_build_in_wip);
        End if;

	IF ((l_base_item_id IS NULL) OR (l_build_in_wip <> 'Y')) THEN
		x_transfer_price := null;
                If PG_DEBUG <> 0 Then
		   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'ERROR::Config item passed by INV is not valid');
                End if;

		raise FND_API.G_EXC_ERROR;
	END IF;

	x_transfer_price := 0;

	-- Call API to get optional components
	CTO_TRANSFER_PRICE_PK.get_config_details
		(
		p_item_id       => p_config_item_id,
		p_org_id        => NULL,
		p_mode_id       => 3,
		x_group_id      => x_group_id,
		x_msg_count     => x_msg_count,
		x_msg_data      => x_msg_data,
		x_return_status => x_return_status);

        If  PG_DEBUG <> 0 Then
	   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'x_group_id::'||to_char(x_group_id));
        End if;

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                If PG_DEBUG <> 0 Then
		   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Exp error in get_config_details:'||sqlerrm);
                End if;
     		raise FND_API.G_EXC_ERROR;
  	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                If PG_DEBUG <> 0 Then
		   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Unexp error in get_config_details:'||sqlerrm);
                End if;
     		raise FND_API.G_EXC_UNEXPECTED_ERROR;
  	END IF;

	--<< Get_Options >>
	FOR v_options IN c_options(l_current_item_id) LOOP
		--
		-- If option is lower level config, use config item's
		-- price instead of rolling up its components
		--
                If PG_DEBUG <> 0 Then
		   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'comp being processed::'||to_char(v_options.component_item_id));
                End if;

		IF v_options.configurator_flag = 'Y' THEN

                        If PG_DEBUG <> 0 Then
			   cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'comp being processed is a config item');
                        End if;

			INV_TRANSACTION_FLOW_PUB.get_transfer_price_for_item
				(
				  x_return_status           => x_return_status
				, x_msg_data                => x_msg_data
				, x_msg_count               => x_msg_count
				, x_transfer_price          => l_transfer_price
				, x_currency_code           => x_currency_code
				, p_api_version             => 1
				, p_from_org_id             => p_shipping_oper_unit
				, p_to_org_id               => p_selling_oper_unit
				, p_transaction_uom         => v_options.primary_uom_code
				, p_inventory_item_id       => v_options.component_item_id
				, p_transaction_id          => p_transaction_id
				, p_price_list_id           => p_price_list_id
				, p_global_procurement_flag => p_global_procurement_flag
				, p_from_organization_id    => p_from_organization_id
				, p_cto_item_flag           => 'Y'
				);

			IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                If PG_DEBUG <> 0 Then
				cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Exp error in get_transfer_price_for_item:'||sqlerrm);
                                End if;
     				raise FND_API.G_EXC_ERROR;
  			ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                If PG_DEBUG <> 0 Then
				cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Unexp error in get_transfer_price_for_item:'||sqlerrm);
                                End if;
     				raise FND_API.G_EXC_UNEXPECTED_ERROR;
  			END IF;
                        If PG_DEBUG <> 0 Then
			cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Transfer price of comp '||to_char(v_options.component_item_id)||' is '||to_char(l_transfer_price));
                        End if;

			IF l_transfer_price <> 0 THEN
				x_transfer_price := x_transfer_price + l_transfer_price * v_options.component_quantity;
			ELSE
				cto_transfer_price(
					p_config_item_id          => v_options.component_item_id,
					p_selling_oper_unit       => p_selling_oper_unit,
					p_shipping_oper_unit      => p_shipping_oper_unit,
					p_transaction_uom         => v_options.primary_uom_code,
					p_transaction_id          => p_transaction_id,
					p_price_list_id           => p_price_list_id,
					p_global_procurement_flag => p_global_procurement_flag,
					p_from_organization_id    => p_from_organization_id,
					p_currency_code           => p_currency_code,
					x_transfer_price          => l_transfer_price,
					x_currency_code           => x_currency_code,
					x_return_status           => x_return_status,
					x_msg_count               => x_msg_count,
					x_msg_data                => x_msg_data);

				x_transfer_price := x_transfer_price + l_transfer_price * v_options.component_quantity;
			END IF;

		ELSE	/* if not config item */

			INV_TRANSACTION_FLOW_PUB.get_transfer_price_for_item
				(
				  x_return_status           => x_return_status
				, x_msg_data                => x_msg_data
				, x_msg_count               => x_msg_count
				, x_transfer_price          => l_transfer_price
				, x_currency_code           => x_currency_code
				, p_api_version             => 1
				, p_from_org_id             => p_shipping_oper_unit
				, p_to_org_id               => p_selling_oper_unit
				, p_transaction_uom         => v_options.primary_uom_code
				, p_inventory_item_id       => v_options.component_item_id
				, p_transaction_id          => p_transaction_id
				, p_price_list_id           => p_price_list_id
				, p_global_procurement_flag => p_global_procurement_flag
				, p_from_organization_id    => p_from_organization_id
				, p_cto_item_flag           => 'Y'
				);

			IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                                If PG_DEBUG <> 0 Then
				cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Exp error in get_transfer_price_for_item:'||sqlerrm);
                                End if;
     				raise FND_API.G_EXC_ERROR;
  			ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                If PG_DEBUG <> 0 Then
				cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Unexp error in get_transfer_price_for_item:'||sqlerrm);
                                End if;
     				raise FND_API.G_EXC_UNEXPECTED_ERROR;
  			END IF;

                        If PG_DEBUG <> 0 Then
			cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Transfer price of comp '||to_char(v_options.component_item_id)||' is '||to_char(l_transfer_price));
                        End if;
			x_transfer_price := x_transfer_price + l_transfer_price * v_options.component_quantity;

		END IF; /* if config item */

	END LOOP; /* cursor loop */

	x_transfer_price := x_transfer_price/CTO_UTILITY_PK.convert_uom(from_uom  => l_prim_uom,
	                                                                to_uom    => p_transaction_uom,
			                 			        quantity  => 1,
			 			                        item_id   => p_config_item_id);

        If PG_DEBUG <> 0 Then
	cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Total Transfer price of item is '||to_char(x_transfer_price));
        End if;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                If PG_DEBUG <> 0 Then
		cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Unexpected error:'||lStmtNumber||sqlerrm);
                End if;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

	WHEN FND_API.G_EXC_ERROR THEN
                If PG_DEBUG <> 0 Then
		cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Expected error:'||lStmtNumber||sqlerrm);
                End if;
		x_return_status := FND_API.G_RET_STS_ERROR;
		CTO_MSG_PUB.Count_And_Get
			(p_msg_count => x_msg_count
			,p_msg_data  => x_msg_data);

	WHEN OTHERS THEN
                If PG_DEBUG <> 0 Then
		cto_wip_workflow_api_pk.cto_debug('cto_transfer_price:', 'Others error:'||lStmtNumber||sqlerrm);
                End if;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            		FND_MSG_PUB.Add_Exc_Msg
            			(G_PKG_NAME
            			,'cto_transfer_price'
            			);
        	END IF;
		CTO_MSG_PUB.Count_And_Get
        		(p_msg_count => x_msg_count
        		,p_msg_data  => x_msg_data
        		);

END;	/* cto_transfer_price */

END CTO_TRANSFER_PRICE_PK;

/
