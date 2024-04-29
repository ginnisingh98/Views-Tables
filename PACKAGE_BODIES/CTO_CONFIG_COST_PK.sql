--------------------------------------------------------
--  DDL for Package Body CTO_CONFIG_COST_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CONFIG_COST_PK" as
/* $Header: CTOCSTRB.pls 120.5.12010000.2 2008/09/26 13:29:14 ntungare ship $ */
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

--Bugfix 6717614: Added this new function
function cost_update_required (p_config_item_id  number,
                               p_organization_id number,
                               p_cto_cost_type_id number
                               )
return varchar2
is

  CURSOR cost_details(c_config_item_id number, c_organization_id number, c_cost_type number) IS
  select cst.inventory_item_id, cst.organization_id, cst.cost_type_id,
         cst.item_cost , cst.material_cost, cst.material_overhead_cost,
         cst.resource_cost, cst.outside_processing_cost, cst.overhead_cost
         --cicd.cost_element_id ,cicd.item_cost cicd_item_cost
  from   cst_item_costs cst
  where  cst.inventory_item_id = c_config_item_id
  AND    cst.organization_id = c_organization_id
  AND    cst.cost_type_id = c_cost_type;

  v_cost_details_frozen cost_details%ROWTYPE;
  v_cost_details_cto cost_details%ROWTYPE;


begin
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add( 'Inside cost_update_required ' ,1 ) ;
                END IF;

                OPEN cost_details(p_config_item_id, p_organization_id, 1);
                FETCH cost_details INTO v_cost_details_frozen;

                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add( 'v_cost_details_frozen ' ,1 ) ;
                        oe_debug_pub.add(  ' iid ' || v_cost_details_frozen.inventory_item_id ||
                                ' org ' || to_char( v_cost_details_frozen.organization_id) ||
                                ' cstyp ' || to_char( v_cost_details_frozen.cost_type_id) ||
                                ' icst ' || to_char( v_cost_details_frozen.item_cost ) ||
                                ' mcst ' || to_char( v_cost_details_frozen.material_cost ) ||
                                ' mocst ' || to_char( v_cost_details_frozen.material_overhead_cost) ||
                                ' opcst ' || to_char( v_cost_details_frozen.outside_processing_cost ) ||
                                ' ocst ' || to_char( v_cost_details_frozen.overhead_cost ) ||
                                ' rcst ' || to_char( v_cost_details_frozen.resource_cost ) , 1 ) ;
                END IF;

                CLOSE cost_details;

                OPEN cost_details(p_config_item_id, p_organization_id, p_cto_cost_type_id);
                FETCH cost_details INTO v_cost_details_cto;

                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add( 'v_cost_details_cto ' ,1 ) ;
                        oe_debug_pub.add(  ' iid ' || v_cost_details_cto.inventory_item_id ||
                                ' org ' || to_char( v_cost_details_cto.organization_id) ||
                                ' cstyp ' || to_char( v_cost_details_cto.cost_type_id) ||
                                ' icst ' || to_char( v_cost_details_cto.item_cost ) ||
                                ' mcst ' || to_char( v_cost_details_cto.material_cost ) ||
                                ' mocst ' || to_char( v_cost_details_cto.material_overhead_cost) ||
                                ' opcst ' || to_char( v_cost_details_cto.outside_processing_cost ) ||
                                ' ocst ' || to_char( v_cost_details_cto.overhead_cost ) ||
                                ' rcst ' || to_char( v_cost_details_cto.resource_cost ) , 1 ) ;
                END IF;

                CLOSE cost_details;

                IF ( nvl(v_cost_details_frozen.item_cost,0) = nvl(v_cost_details_cto.item_cost,0) ) THEN

                        IF PG_DEBUG <> 0 THEN
                                oe_debug_pub.add('***Inside 1st if.. total cost is same..' , 1);
                        END IF; --item cost same.. check for cost components

                        IF  Nvl(v_cost_details_frozen.material_cost, -1)           = Nvl(v_cost_details_cto.material_cost, -1)           and
                            Nvl(v_cost_details_frozen.material_overhead_cost, -1)  = Nvl(v_cost_details_cto.material_overhead_cost, -1)  and
                            Nvl(v_cost_details_frozen.resource_cost, -1)           = Nvl(v_cost_details_cto.resource_cost, -1)           and
                            Nvl(v_cost_details_frozen.outside_processing_cost, -1) = Nvl(v_cost_details_cto.outside_processing_cost, -1) AND
                            Nvl(v_cost_details_frozen.overhead_cost, -1)           = Nvl(v_cost_details_cto.overhead_cost, -1)           THEN

                                IF PG_DEBUG <> 0 THEN
                                        oe_debug_pub.add('***Inside 2nd if.. component costs are same..no processing needed' , 1);
                                END IF;

                                return 'N';
                        else
                                return 'Y';
                        END if;
                else
                        return 'Y';
                END if;
END cost_update_required;

procedure populate_buy_cost( p_line_id number
                           , p_config_item_id number
                           , p_organization_id   number
                           , p_buy_cost_type_id   number
                           , p_buy_item_cost   number
)
is
lStmtNumber		number;
begin

        /*-------------------------------------------------------+
        Insert a row into the cst_item_costs_table
        +------------------------------------------------------- */

        lStmtNumber := 220;

        insert into CST_ITEM_COSTS
                (inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                inventory_asset_flag,
                lot_size,
                based_on_rollup_flag,
                shrinkage_rate,
                defaulted_flag,
                cost_update_id,
                pl_material,
                pl_material_overhead,
                pl_resource,
                pl_outside_processing,
                pl_overhead,
                tl_material,
                tl_material_overhead,
                tl_resource,
                tl_outside_processing,
                tl_overhead,
                material_cost,
                material_overhead_cost,
                resource_cost,
                outside_processing_cost ,
                overhead_cost,
                pl_item_cost,
                tl_item_cost,
                item_cost,
                unburdened_cost ,
                burden_cost,
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
                attribute15
                )
                values
                (
                p_config_item_id,                -- INVENTORY_ITEM_ID
                p_organization_id,
                p_buy_cost_type_id,
                sysdate,                  -- last_update_date
                -1,                       -- last_updated_by
                sysdate,                  -- creation_date
                -1,                       -- created_by
                -1,                       -- last_update_login
                1 , -- C.inventory_asset_flag,
                1 , -- C.lot_size,
                1 , -- C.based_on_rollup_flag,
                0 , -- C.shrinkage_rate,
                2 , -- C.defaulted_flag,
                NULL,                     -- cost_update_id
                0 , -- C.pl_material,
                0 , -- C.pl_material_overhead,
                0 , -- C.pl_resource,
                0 , -- C.pl_outside_processing,
                0 , -- C.pl_overhead,
                p_buy_item_cost  , -- C.tl_material,
                0 , -- C.tl_material_overhead,
                0 , -- C.tl_resource,
                0 , -- C.tl_outside_processing,
                0 , --C.tl_overhead,
                p_buy_item_cost , -- C.material_cost,
                0 , -- C.material_overhead_cost,
                0, -- C.resource_cost,
                0 , -- C.outside_processing_cost ,
                0 , -- C.overhead_cost,
                0 , -- C.pl_item_cost,
                p_buy_item_cost , -- C.tl_item_cost,
                p_buy_item_cost , -- C.item_cost,
                0 , -- C.unburdened_cost ,
                0 , -- C.burden_cost,
                0 , -- C.attribute_category,
                0 , -- C.attribute1,
                0 , -- C.attribute2,
                0 , -- C.attribute3,
                0 , -- C.attribute4,
                0 , -- C.attribute5,
                0 , -- C.attribute6,
                0 , -- C.attribute7,
                0 , -- C.attribute8,
                0 , -- C.attribute9,
                0 , -- C.attribute10,
                0 , -- C.attribute11,
                0 , -- C.ATTRIBUTE12,
                0 , -- C.attribute13,
                0 , -- C.attribute14,
                0   -- C.attribute15
                );

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_buy_cost: ' || 'after insert:CST_ITEM_COSTS',2);

        	oe_debug_pub.add('populate_buy_cost: ' || 'after insert:CST_ITEM_COSTS' || sql%rowcount ,2);
        END IF;

        /*------ ----------------------------------------------+
         Insert rows into the cst_item_cost_details table
        +-----------------------------------------------------*/

        lStmtNumber := 230;

        insert into cst_item_cost_details
                (inventory_item_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                organization_id,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
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
                attribute15
                )
               select
                p_config_item_id,                   -- inventory_item_id
                p_buy_cost_type_id,
                sysdate,                     -- last_update_date
                -1,                          -- last_updated_by
                sysdate,                     -- creation_date
                -1,                          -- created_by
                -1,                          -- last_update_login
                p_organization_id,
                null , -- c.operation_sequence_id,
                null , -- c.operation_seq_num,
                null , -- c.department_id,
                1 , --  c.level_type,
                null , -- c.activity_id,
                null , -- c.resource_seq_num,
                mp.default_material_cost_id,  -- c.resource_id[material sub element],
                1 , -- c.resource_rate,
                null , -- c.item_units,
                null , -- c.activity_units,
                p_buy_item_cost  , -- c.usage_rate_or_amount,
                1 , -- c.basis_type,
                null , -- c.basis_resource_id,
                1 , -- c.basis_factor,
                1 , -- c.net_yield_or_shrinkage_factor,
                p_buy_item_cost, --item_cost
                1 , -- c.cost_element_id,
                1 , -- C.rollup_source_type,
                null , -- C.activity_context,
                null , -- C.attribute_category,
                null , -- C.attribute1,
                null , -- C.attribute2,
                null , -- C.attribute3,
                null , -- C.attribute4,
                null , -- C.attribute5,
                null , -- C.attribute6,
                null , -- C.attribute7,
                null , -- C.attribute8,
                null , -- C.attribute9,
                null , -- C.attribute10,
                null , --C.attribute11,
                null , -- C.attribute12,
                null , -- C.attribute13,
                null , -- C.attribute14,
                null  -- C.attribute15
                from mtl_parameters mp
                where mp.organization_id = p_organization_id ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_buy_cost: ' || 'after insert:cst_item_cost_details',2);

        	oe_debug_pub.add('populate_buy_cost: ' || 'after insert:cst_item_cost_details' || sql%rowcount ,2);
        END IF;


  exception
    when NO_DATA_FOUND THEN

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_buy_cost: ' || 'populate_buy_cost no data found ',2);
        END IF;

    when OTHERS THEN

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_buy_cost: ' || 'populate_buy_cost others '||sqlerrm,2);
        END IF;





end populate_buy_cost;

-- FP J: populate_buy_cost_rollup is added since above API
-- populate_buy_cost can not be used as it requires line_id as IN param

procedure populate_buy_cost_rollup( p_config_item_id number
                           , p_organization_id   number
                           , p_buy_cost_type_id   number
                           , p_buy_item_cost   number
                           , x_return_status   OUT NOCOPY varchar2
)
is
lStmtNumber		number;
begin

        /*-------------------------------------------------------+
        Insert a row into the cst_item_costs_table
        +------------------------------------------------------- */

        lStmtNumber := 220;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        insert into CST_ITEM_COSTS
                (inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                inventory_asset_flag,
                lot_size,
                based_on_rollup_flag,
                shrinkage_rate,
                defaulted_flag,
                cost_update_id,
                pl_material,
                pl_material_overhead,
                pl_resource,
                pl_outside_processing,
                pl_overhead,
                tl_material,
                tl_material_overhead,
                tl_resource,
                tl_outside_processing,
                tl_overhead,
                material_cost,
                material_overhead_cost,
                resource_cost,
                outside_processing_cost ,
                overhead_cost,
                pl_item_cost,
                tl_item_cost,
                item_cost,
                unburdened_cost ,
                burden_cost,
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
                attribute15
                )
                values
                (
                p_config_item_id,                -- INVENTORY_ITEM_ID
                p_organization_id,
                p_buy_cost_type_id,
                sysdate,                  -- last_update_date
                -1,                       -- last_updated_by
                sysdate,                  -- creation_date
                -1,                       -- created_by
                -1,                       -- last_update_login
                1 , -- C.inventory_asset_flag,
                1 , -- C.lot_size,
                1 , -- C.based_on_rollup_flag,
                0 , -- C.shrinkage_rate,
                2 , -- C.defaulted_flag,
                NULL,                     -- cost_update_id
                0 , -- C.pl_material,
                0 , -- C.pl_material_overhead,
                0 , -- C.pl_resource,
                0 , -- C.pl_outside_processing,
                0 , -- C.pl_overhead,
                p_buy_item_cost  , -- C.tl_material,
                0 , -- C.tl_material_overhead,
                0 , -- C.tl_resource,
                0 , -- C.tl_outside_processing,
                0 , --C.tl_overhead,
                p_buy_item_cost , -- C.material_cost,
                0 , -- C.material_overhead_cost,
                0, -- C.resource_cost,
                0 , -- C.outside_processing_cost ,
                0 , -- C.overhead_cost,
                0 , -- C.pl_item_cost,
                p_buy_item_cost , -- C.tl_item_cost,
                p_buy_item_cost , -- C.item_cost,
                0 , -- C.unburdened_cost ,
                0 , -- C.burden_cost,
                0 , -- C.attribute_category,
                0 , -- C.attribute1,
                0 , -- C.attribute2,
                0 , -- C.attribute3,
                0 , -- C.attribute4,
                0 , -- C.attribute5,
                0 , -- C.attribute6,
                0 , -- C.attribute7,
                0 , -- C.attribute8,
                0 , -- C.attribute9,
                0 , -- C.attribute10,
                0 , -- C.attribute11,
                0 , -- C.ATTRIBUTE12,
                0 , -- C.attribute13,
                0 , -- C.attribute14,
                0   -- C.attribute15
                );

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_buy_cost_rollup: ' || 'after insert:CST_ITEM_COSTS',2);

        	oe_debug_pub.add('populate_buy_cost_rollup: ' || 'after insert:CST_ITEM_COSTS' || sql%rowcount ,2);
        END IF;

        /*------ ----------------------------------------------+
         Insert rows into the cst_item_cost_details table
        +-----------------------------------------------------*/

        lStmtNumber := 230;

        insert into cst_item_cost_details
                (inventory_item_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                organization_id,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
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
                attribute15
                )
               select
                p_config_item_id,                   -- inventory_item_id
                p_buy_cost_type_id,
                sysdate,                     -- last_update_date
                -1,                          -- last_updated_by
                sysdate,                     -- creation_date
                -1,                          -- created_by
                -1,                          -- last_update_login
                p_organization_id,
                null , -- c.operation_sequence_id,
                null , -- c.operation_seq_num,
                null , -- c.department_id,
                1 , --  c.level_type,
                null , -- c.activity_id,
                null , -- c.resource_seq_num,
                mp.default_material_cost_id,  -- c.resource_id[material sub element],
                1 , -- c.resource_rate,
                null , -- c.item_units,
                null , -- c.activity_units,
                p_buy_item_cost  , -- c.usage_rate_or_amount,
                1 , -- c.basis_type,
                null , -- c.basis_resource_id,
                1 , -- c.basis_factor,
                1 , -- c.net_yield_or_shrinkage_factor,
                p_buy_item_cost, --item_cost
                1 , -- c.cost_element_id,
                1 , -- C.rollup_source_type,
                null , -- C.activity_context,
                null , -- C.attribute_category,
                null , -- C.attribute1,
                null , -- C.attribute2,
                null , -- C.attribute3,
                null , -- C.attribute4,
                null , -- C.attribute5,
                null , -- C.attribute6,
                null , -- C.attribute7,
                null , -- C.attribute8,
                null , -- C.attribute9,
                null , -- C.attribute10,
                null , --C.attribute11,
                null , -- C.attribute12,
                null , -- C.attribute13,
                null , -- C.attribute14,
                null  -- C.attribute15
                from mtl_parameters mp
                where mp.organization_id = p_organization_id ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('populate_buy_cost_rollup: ' || 'after insert:cst_item_cost_details',2);

        	oe_debug_pub.add('populate_buy_cost_rollup: ' || 'after insert:cst_item_cost_details' || sql%rowcount ,2);
        END IF;


  exception

    when OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        oe_debug_pub.add('populate_buy_cost_rollup: ' || 'populate_buy_cost others '||sqlerrm,2);


end populate_buy_cost_rollup;


procedure copy_ctocost_to_frozen(
                             p_config_item_id number
                           , p_organization_id   number
                           , p_cto_cost_type_id   number
)
is
lStmtNumber		number;
l_cost_update           number;    --Bugfix 6363308
begin

        /*-------------------------------------------------------+
        Insert a row into the cst_item_costs_table
        +------------------------------------------------------- */

        lStmtNumber := 220;

        --Bugfix 6363308
        Select cst_lists_s.nextval
          INTO l_cost_update
            From DUAL;
        --Bugfix 6363308

        lStmtNumber := 230;

        insert into CST_ITEM_COSTS
                (inventory_item_id,
                organization_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                inventory_asset_flag,
                lot_size,
                based_on_rollup_flag,
                shrinkage_rate,
                defaulted_flag,
                cost_update_id,
                pl_material,
                pl_material_overhead,
                pl_resource,
                pl_outside_processing,
                pl_overhead,
                tl_material,
                tl_material_overhead,
                tl_resource,
                tl_outside_processing,
                tl_overhead,
                material_cost,
                material_overhead_cost,
                resource_cost,
                outside_processing_cost ,
                overhead_cost,
                pl_item_cost,
                tl_item_cost,
                item_cost,
                unburdened_cost ,
                burden_cost,
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
                attribute15
                )
        select distinct
                p_config_item_id,                -- INVENTORY_ITEM_ID
                p_organization_id,
                1,
                sysdate,                  -- last_update_date
                -1,                       -- last_updated_by
                sysdate,                  -- creation_date
                -1,                       -- created_by
                -1,                       -- last_update_login
                C.inventory_asset_flag,
                C.lot_size,
                C.based_on_rollup_flag,
                C.shrinkage_rate,
                C.defaulted_flag,
                --p_cto_cost_type_id,                     -- cost_update_id
                l_cost_update,            --Bugfix 6363308    -- cost_update_id now taken from sequence
                C.pl_material,
                C.pl_material_overhead,
                C.pl_resource,
                C.pl_outside_processing,
                C.pl_overhead,
                C.tl_material,
                C.tl_material_overhead,
                C.tl_resource,
                C.tl_outside_processing,
                C.tl_overhead,
                C.material_cost,
                C.material_overhead_cost,
                C.resource_cost,
                C.outside_processing_cost ,
                C.overhead_cost,
                C.pl_item_cost,
                C.tl_item_cost,
                C.item_cost,
                C.unburdened_cost ,
                C.burden_cost,
                C.attribute_category,
                C.attribute1,
                C.attribute2,
                C.attribute3,
                C.attribute4,
                C.attribute5,
                C.attribute6,
                C.attribute7,
                C.attribute8,
                C.attribute9,
                C.attribute10,
                C.attribute11,
                C.ATTRIBUTE12,
                C.attribute13,
                C.attribute14,
                C.attribute15
        from
                cst_item_costs C
        where  C.inventory_item_id = p_config_item_id
        and    C.organization_id   = p_organization_id
        and    C.cost_type_id  = p_cto_cost_type_id;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_ctocost_to_frozen: ' || 'after insert:CST_ITEM_COSTS' || sql%rowcount ,2);
        END IF;

        /*------ ----------------------------------------------+
         Insert rows into the cst_item_cost_details table
        +-----------------------------------------------------*/

        lStmtNumber := 230;

        insert into cst_item_cost_details
                (inventory_item_id,
                cost_type_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                organization_id,
                operation_sequence_id,
                operation_seq_num,
                department_id,
                level_type,
                activity_id,
                resource_seq_num,
                resource_id,
                resource_rate,
                item_units,
                activity_units,
                usage_rate_or_amount,
                basis_type,
                basis_resource_id,
                basis_factor,
                net_yield_or_shrinkage_factor,
                item_cost,
                cost_element_id,
                rollup_source_type,
                activity_context,
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
                attribute15
                )
        select distinct
                p_config_item_id,                   -- inventory_item_id
                1,
                sysdate,                     -- last_update_date
                -1,                          -- last_updated_by
                sysdate,                     -- creation_date
                -1,                          -- created_by
                -1,                          -- last_update_login
                p_organization_id,
                c.operation_sequence_id,
                c.operation_seq_num,
                c.department_id,
                c.level_type,
                c.activity_id,
                c.resource_seq_num,
                c.resource_id,
                c.resource_rate,
                c.item_units,
                c.activity_units,
                c.usage_rate_or_amount,
                c.basis_type,
                c.basis_resource_id,
                c.basis_factor,
                c.net_yield_or_shrinkage_factor,
                c.item_cost,
                c.cost_element_id,
                C.rollup_source_type,
                C.activity_context,
                C.attribute_category,
                C.attribute1,
                C.attribute2,
                C.attribute3,
                C.attribute4,
                C.attribute5,
                C.attribute6,
                C.attribute7,
                C.attribute8,
                C.attribute9,
                C.attribute10,
                C.attribute11,
                C.attribute12,
                C.attribute13,
                C.attribute14,
                C.attribute15
        from
                cst_item_cost_details C
        where  C.inventory_item_id = p_config_item_id
        and    C.organization_id   = p_organization_id
        and    C.cost_type_id  = p_cto_cost_type_id ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_ctocost_to_frozen: ' || 'after insert:cst_item_cost_details' || sql%rowcount ,2);
        END IF;

        --Begin Bugfix 6363308
        lStmtNumber := 250;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_ctocost_to_frozen: ' || 'Inserting records in csc and cec',2);
        END IF;

        INSERT INTO cst_standard_costs
                (cost_update_id,
                 organization_id,
                 inventory_item_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 standard_cost_revision_date,
                 standard_cost
                )
       SELECT
                 l_cost_update,
                 p_organization_id,
                 p_config_item_id,
                 SYSDATE,
                 -1,
                 SYSDATE,
                 -1,
                 -1,
                 SYSDATE,
                 NVL(SUM(item_cost),0)
       FROM
                 cst_item_cost_details
       WHERE     organization_id = p_organization_id
       AND       inventory_item_id = p_config_item_id
       AND       cost_type_id = 1;

       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_ctocost_to_frozen: ' || 'after insert:cst_standard_costs ' || sql%rowcount ,2);
       END IF;

       lStmtNumber := 260;

       INSERT INTO cst_elemental_costs
               (cost_update_id,
                organization_id,
                inventory_item_id,
                cost_element_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                standard_cost
               )
       SELECT
               l_cost_update,
               p_organization_id,
               p_config_item_id,
               cost_element_id,
               SYSDATE,
               -1,
               SYSDATE,
               -1,
               -1,
               NVL(SUM(item_cost),0)
       FROM
             cst_item_cost_details
       WHERE organization_id   = p_organization_id
       AND   inventory_item_id = p_config_item_id
       AND   cost_type_id = 1
       GROUP BY cost_element_id;

       IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_ctocost_to_frozen: ' || 'after insert:cst_elemental_costs ' || sql%rowcount ,2);
       END IF;
  --End Bugfix 6363308


  exception
    when NO_DATA_FOUND THEN
/*
      xErrorMessage := 'CTOCSTRB:' || to_char(lStmtNum) || ':' ||
                        substrb(sqlerrm,1,150);
        xMessageName  := 'CTO_CALC_COST_ROLLUP_ERROR';
*/

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_ctocost_to_frozen: ' || 'copy_ctocost_to_frozen no data found ',2);
        END IF;

    when OTHERS THEN
/*
      xErrorMessage := 'CTOCSTRB:' || to_char(lStmtNum) || ':' ||
                        substrb(sqlerrm,1,150);
      --xMessageName  := 'BOM_ATO_PROCESS_ERROR';
        xMessageName  := 'CTO_CALC_COST_ROLLUP_ERROR';
*/

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('copy_ctocost_to_frozen: ' || 'copy_ctocost_to_frozen others ',2);
        END IF;





end copy_ctocost_to_frozen;



FUNCTION check_ct_updateable(  p_inventory_item_id NUMBER
                             , p_organization_id NUMBER
                             , p_cost_type_id  NUMBER )
 Return BOOLEAN IS
  Updateable VARCHAR2(10) := null ;
  RetVal   BOOLEAN;
  intransit_count NUMBER;

  Cursor Check_Updateable is
    Select 'NO'
    From  MTL_MATERIAL_TRANSACTIONS t
    Where Inventory_Item_Id = p_inventory_item_id
    And Exists
    (Select 'all these org have the org as costing org'
     From  MTL_PARAMETERS
     Where Cost_Organization_Id = p_organization_id
     AND Organization_Id = t.Organization_Id);

  Cursor Check_Updateable_2 is
    Select 'NO'
    From  MTL_MATERIAL_TRANSACTIONS_TEMP t
    Where Inventory_Item_Id = p_inventory_item_id
    And Exists
    (Select 'all these org have the org as costing org'
     From  MTL_PARAMETERS
     Where Cost_Organization_Id = p_organization_id
     AND Organization_Id = t.Organization_Id);

  BEGIN
    -- If we are dealing with a frozon cost type, it is only updateable when
    -- there does not exist any transactions.

    IF ( p_cost_type_id  = 1) THEN
      IF (Updateable is NULL) THEN
        Open Check_Updateable;
        Fetch Check_Updateable into Updateable;
        Close Check_Updateable;

        IF (Updateable is Null) THEN

          Open Check_Updateable_2;
          Fetch Check_Updateable_2 into Updateable;
          Close Check_Updateable_2;
        END IF;

        IF (Updateable is NULL) THEN

           select count(*)
           into intransit_count
           from mtl_supply m
           where m.item_id = p_inventory_item_id
           and m.intransit_owning_org_id = p_organization_id
           and m.to_organization_id = p_organization_id ;
           IF (intransit_count > 0) THEN
             Updateable := 'NO';
           END IF;
        END IF;

      END IF;
      IF (Updateable = 'NO') THEN
        -- fnd_message.Set_Name('BOM', 'CST_ITEM_USED_IN_TXN');
        RetVal := FALSE;
      ELSE
           IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add( ' check_ct_updateable is null -> true ' ) ;
           END IF;

        RetVal := TRUE;
      END IF;

    ELSE
        IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add( ' cost type id not 1 ' ) ;
        END IF;

      RetVal := TRUE;
    END IF;

    IF PG_DEBUG <> 0 THEN

         if( RetVal = TRUE ) then
             oe_debug_pub.add( ' check_ct_updateable is true ' ) ;
         elsif( RetVal = False ) then
             oe_debug_pub.add( ' check_ct_updateable is false' ) ;
         elsif( RetVal is null ) then
             oe_debug_pub.add( ' check_ct_updateable is null ' ) ;
         end if ;
    END IF;



    Return RetVal;
  END Check_CT_Updateable;


/* fp-J : This procedure has been added for optional processing for cost rollup (ksarkar)
*/

FUNCTION Cost_Roll_Up_ML( p_cfg_itm_tbl   in     CTO_COST_ROLLUP_CONC_PK.t_cfg_item
                       , x_msg_count     out     NOCOPY number
                       , x_msg_data      out     NOCOPY varchar2
 			)
RETURN integer
IS

lMrpAssignmentSet	number;
lRollupId		number;
gUserId			number;
gLoginId		number;
lMsgCount		number;
lMsgData		varchar2(2000);
lStmtNumber		number;
lErrorCode		number;
lErrorMsg		varchar2(2000);
lCnt			number;
lConversionType		varchar2(30);
lBuyCostType		varchar2(30);

CTO_MRP_ASSIGNMENT_SET	exception;

v_cto_cost_type_id          cst_cost_types.cost_type_id%type ;
v_buy_cost_type_id          cst_cost_types.cost_type_id%type ;
v_buy_cost              number ;
c_line_id               bom_cto_src_orgs.line_id%type ;
c_model_item_id         bom_cto_src_orgs.model_item_id%type ;
c_config_item_id        bom_cto_src_orgs.model_item_id%type ;
c_match_config_item_id  bom_cto_src_orgs.model_item_id%type ;
c_org_id                bom_cto_src_orgs.rcv_org_id%type ;
c_organization_id       bom_cto_src_orgs.organization_id%type ;
c_po_valid_org          financials_system_params_all.inventory_organization_id%type ;
c_oper_unit             inv_organization_info_v.operating_unit%type ;

v_buy_item_cost         mtl_system_items.list_price_per_unit%type ;

-- rkaza. 3742393. 08/12/2004.
-- Repalcing org_organization_definitions with inv_organization_info_v


-- For Performance reason, We are removing the join with financial_system_params_all table
-- For some reason, this join is causing non mergable view or inv_organization_info_v.
-- We don't know the exact reason yet. But for now, we are planning to break the sql into two parts
-- to avoid this performance issue.
cursor c_buy_items(	xcfg_itm_id	number,
			xcfg_org_id	number
		  )
is
select
       msi.base_item_id
     , msi.inventory_item_id
     , mp1.cost_organization_id  -- 3116778
     , nvl(org.operating_unit,0) oper_unit
from   inv_organization_info_v org
     , mtl_system_items msi
     , cst_item_costs   cic
     , mtl_parameters   mp1
where org.organization_id = msi.organization_id
and   cic.inventory_item_id = msi.inventory_item_id
and   cic.organization_id = mp1.cost_organization_id  --3116778
and   cic.based_on_rollup_flag = 1
and   cic.cost_type_id  in ( mp1.primary_cost_method, mp1.avg_rates_cost_type_id)
and   msi.organization_id   = MP1.organization_id
and   msi.inventory_item_id = xcfg_itm_id
and   msi.organization_id = xcfg_org_id;


/*
 This cursor does not use bcol table to check for matched items
 as cost rollup may be called for items that do not have an entry in bcol.
 Instead we will check whether the item has a valuation cost with a rolled up
 component.
*/

cursor c_matched_items_cost_synchup (	xcfg_itm_id	number,
					xcfg_org_id	number
		  	 	    )
is
select msi.inventory_item_id
     , msi.organization_id
     , cic.cost_type_id
     , cic.item_cost
from mtl_system_items msi
   , cst_item_costs cic
   , mtl_parameters mp
where msi.organization_id = cic.organization_id
and msi.inventory_item_id = cic.inventory_item_id
and msi.organization_id = mp.organization_id
and mp.primary_cost_method = cic.cost_type_id
and EXISTS      /* check whether item has been rolled up */
      (     select NULL
              from cst_item_cost_details
             where rollup_source_type = 3
               and inventory_item_id = msi.inventory_item_id
               and cost_type_id = cic.cost_type_id
               and organization_id = msi.organization_id
       )
and   msi.inventory_item_id = xcfg_itm_id
and   msi.organization_id = xcfg_org_id;

cursor c_frozen_cost_update(	c_cto_cost_type_id number,
				xcfg_itm_id	number,
				xcfg_org_id	number
		           )
is
select  msi.inventory_item_id
      , mp.cost_organization_id rollup_org_id
from    mtl_system_items msi
      , mtl_parameters mp
      , cst_item_costs cic
where msi.organization_id = mp.organization_id
and   mp.primary_cost_method = 1
and   cic.inventory_item_id = msi.inventory_item_id
and   cic.organization_id = msi.organization_id
and   cic.cost_type_id = c_cto_cost_type_id
and   msi.inventory_item_id = xcfg_itm_id
and   msi.organization_id = xcfg_org_id;


v_item_cost                    cst_item_costs.item_cost%type ;
v_cto_cost                    cst_item_costs.item_cost%type ;
v_material_cost                cst_item_costs.material_cost%type ;
v_material_overhead_cost       cst_item_costs.material_overhead_cost%type ;
v_resource_cost                cst_item_costs.resource_cost%type ;
v_outside_processing_cost      cst_item_costs.outside_processing_cost%type ;
v_overhead_cost                cst_item_costs.overhead_cost%type ;

v_cost_updateable              BOOLEAN := false ;


v_group_id                     bom_explosion_temp.group_id%type ;
x_return_status                varchar2(200) ;


c_primary_cost_method         mtl_parameters.primary_cost_method%type ;
c_valuation_cost              number;


l_token                      CTO_MSG_PUB.token_tbl;



v_po_validation_org     varchar2(2000) ;
v_org                   varchar2(2000) ;
v_model_name            varchar2(2000) ;


v_cto_cost_type_name    cst_cost_types.cost_type%type;

l_cost_data_exists      Varchar2(1) := 'N';  -- Bug Fix 4867460
l_cost_update_required varchar2(1) := 'N';   --Bugfix 6717614

BEGIN
	lStmtNumber := 10;


	if p_cfg_itm_tbl.COUNT = 0 then
	   oe_debug_pub.add ('Cost_Roll_Up_ML: '|| 'Array p_cfg_itm_tbl does not contain any rows to process.');
	   return(1);
	else
	   oe_debug_pub.add ('Cost_Roll_Up_ML: '|| 'Going to process '||p_cfg_itm_tbl.COUNT|| ' rows... ');

	end if;

	gUserId := nvl(fnd_global.user_id, -1);
	gLoginId := nvl(fnd_global.login_id, -1);

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Roll_Up_ML ' || 'gUserId::'||to_char(gUserId)
                                 ||'::gLoginId::'||to_char(gLoginId), 2);

	END IF;

	-- changed sequence as per bugfix 3239456
	/*select bom_lists_s.nextval
	into lRollupId from dual;*/

	select cst_lists_s.nextval
        into lRollupId from dual;



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Roll_Up_ML ' || 'lRollupId::'||to_char(lRollupId), 2);
	END IF;

	lStmtNumber := 20;
	lMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

	IF lMrpAssignmentSet is null THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Cost_Roll_Up_ML '
                                 || 'Default assignment set is null', 1);
		END IF;


		--FND_MESSAGE.set_name('BOM','CTO_MRP_ASSIGNMENT_SET');
		--raise CTO_MRP_ASSIGNMENT_SET;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Cost_Roll_Up_ML ' || 'Default assignment set is '
                                        ||to_char(lMrpAssignmentSet), 2);
		END IF;
	END IF;

	--
	-- Getting the Currency Conversion Type from profile
	-- "INV:Inter-organization currency conversion"
	--
	lStmtNumber := 25;
	lConversionType := FND_PROFILE.VALUE('CURRENCY_CONVERSION_TYPE');


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Roll_Up_ML ' || 'Currency Conversion Type ::'
                                 ||lConversionType, 2);
	END IF;



        /* bug 4177423
           statement to retrieve CTO cost type id has been removed out from the loop.
           This will execute the statement only once.
        */


           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add ('Fetching CTO cost_type_id..');
           END IF;



           /* commented for bug 4057651
           begin

            select cost_type_id into v_cto_cost_type_id
            from cst_cost_types
            where cost_type = 'CTO' ;



           exception
            when no_data_found then
               -- rollback to CTOCST; bug 4177423
               cto_msg_pub.cto_message('BOM','CTO_COST_NOT_FOUND');
               --    goto endloop; bug 4177423
               raise  FND_API.G_EXC_ERROR;

            when others then
               oe_debug_pub.add('Unexpected error while getting the cost_type_id: ' ||sqlerrm);
               raise  FND_API.G_EXC_UNEXPECTED_ERROR;

           end;


           commented for bug 4057651  */



       /* begin bugfix 4057651, default CTO cost type id = 7 if it does not exist */
        begin

           select cost_type_id into v_cto_cost_type_id
             from cst_cost_types
            where cost_type = 'CTO' ;

        exception
        when no_data_found then

           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' || ' no_data_found error CTO cost type id does not exist',2);
                oe_debug_pub.add('Create_Item: ' || ' defaulting CTO cost type id = 7 ',2);
           END IF;

           v_cto_cost_type_id := 7 ;

           begin
                select cost_type into v_cto_cost_type_name
                  from cst_cost_types
                 where cost_type_id = v_cto_cost_type_id  ;

                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Create_Item: ' || ' cost type id =  ' || v_cto_cost_type_id ||
                                     '  has cost_type =  ' || v_cto_cost_type_name ,2);
                  END IF;
           exception
           when no_data_found then
                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Create_Item: ' || ' no_data_found error for cost type id = 7 ',2);
                  END IF;
                 cto_msg_pub.cto_message('BOM','CTO_COST_NOT_FOUND');
                 raise  FND_API.G_EXC_ERROR;
           when others then

              raise  FND_API.G_EXC_UNEXPECTED_ERROR;
           end ;

        when others then
           raise  FND_API.G_EXC_UNEXPECTED_ERROR;
        end ;
       /* end bugfix 4057651, default CTO cost type id = 7 if it does not exist */



        /* bug 4177423
           CTO BUY cost type id will be defaulted to CTO cost type if it is null.
        */

	lStmtNumber := 27;
	lBuyCostType := FND_PROFILE.VALUE('CTO_BUY_COST_TYPE');
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Roll_Up_ML ' || 'Buy Cost Type ::'|| lBuyCostType , 2);
	END IF;


	lStmtNumber := 28;

        if( lBuyCostType is not null ) then
           begin
              select cost_type_id into v_buy_cost_type_id
                from cst_cost_types
               where cost_type = lBuyCostType ;

	      IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Roll_Up_ML ' || 'Buy Cost Type id ::'
                                || v_buy_cost_type_id , 2);
	      END IF;

           exception
           when no_data_found then

              cto_msg_pub.cto_message('BOM','CTO_BUY_COST_NOT_FOUND');
              raise  FND_API.G_EXC_ERROR;

           when others then

              raise  FND_API.G_EXC_UNEXPECTED_ERROR;

           end;

        else  /* fix for bug 4177423 */

	     IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Roll_Up_ML ' || ' Defaulting Buy Cost Type to CTO cost id ' || v_cto_cost_type_id , 2);
	     END IF;

             v_buy_cost_type_id := v_cto_cost_type_id ;

        end if ;


	lStmtNumber := 29;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Roll_Up_ML ' || ' opening buy cost cursor for bcso ' , 2);
	END IF;



         for i in p_cfg_itm_tbl.FIRST..p_cfg_itm_tbl.LAST
	 LOOP		-- to loop thru all rows in p_cfg_itm_tbl

	   SAVEPOINT CTOCST;

	   -- Instead of doing a simple select, we are doing a cursor fetch
	   -- to  ensure that it doesnt fail with too_many_rows.


         /* bug 4341197 do not populate list price in buy cost type if the buy cost type profile is not set by the user */
         if( lBuyCostType is not null ) then





	   oe_debug_pub.add ('---------------------------------------------------------------------------');
	   oe_debug_pub.add ('Processing config_item_id '|| p_cfg_itm_tbl(i).cfg_item_id ||
				' in orgn '||p_cfg_itm_tbl(i).cfg_org_id);
	   oe_debug_pub.add ('---------------------------------------------------------------------------');

	   open c_buy_items(  p_cfg_itm_tbl(i).cfg_item_id,
			      p_cfg_itm_tbl(i).cfg_org_id) ;

           fetch c_buy_items into c_model_item_id
                                , c_config_item_id
                                , c_org_id
                                , c_oper_unit;


	   close c_buy_items ;

	   -- Added by Renga Kannan on 03/15/20067 to get the po validation org

	   Select nvl(inventory_organization_id,0)
	   into   c_po_valid_org
	   from   financials_system_params_All
	   where  org_id = c_oper_unit;


	   IF PG_DEBUG <> 0 THEN
	   	oe_debug_pub.add('Cost_Roll_Up_ML ' ||
                            ' model '         || c_model_item_id   ||
                            ' config '        || c_config_item_id  ||
                            ' org '           || c_org_id          ||
                            ' po val '        || c_po_valid_org    ||
                            ' oper '          || c_oper_unit, 2);
	   END IF;

	   lStmtNumber := 30;


           /* Check whether buy cost exists for the item */
           begin
               select item_cost into v_buy_cost
                 from cst_item_costs
                where cost_type_id = v_buy_cost_type_id
                  and organization_id = c_org_id
                  and inventory_item_id = c_config_item_id ;

           exception
               when no_data_found then
                    v_buy_cost := null ;

	            IF PG_DEBUG <> 0 THEN
		       oe_debug_pub.add('no buy cost exists for item ' || c_config_item_id
                                       || ' in org ' || c_org_id  , 2);
	            END IF;


               when others then
		    oe_debug_pub.add('Unexpected error while checking buy cost for item_id ' ||c_config_item_id|| ' in orgn '||c_org_id);
		    oe_debug_pub.add(sqlerrm);
                    raise  FND_API.G_EXC_UNEXPECTED_ERROR;

           end ;



           if( v_buy_cost is null ) then

	       lStmtNumber := 32;
               BEGIN
               select nvl(list_price_per_unit,0) into v_buy_item_cost
                 from mtl_system_items
                where organization_id = c_po_valid_org
	        and inventory_item_id = c_config_item_id ;

               EXCEPTION
               when no_data_found then


                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('create_config_item_wf: ' || 'Item Not Enabled in PO Validation Org ' || c_po_valid_org , 1);
                        oe_debug_pub.add('create_config_item_wf: ' || 'PO Validation Org for Org ' || c_org_id , 1);
                    END IF;


                    -- cto_msg_pub.cto_message('BOM', l_xmsgdata);

                    l_token(1).token_name  := 'POV_ORG';

                    -- rkaza. 3742393. 08/12/2004.
                    -- Repalcing org_organization_definitions with
                    -- inv_organization_name_v

                    select organization_name into v_po_validation_org
                    from inv_organization_name_v
                    where organization_id = c_po_valid_org ;


                    l_token(1).token_value := v_po_validation_org ;


                    l_token(2).token_name  := 'ORG';

                    select organization_name into v_org
                    from inv_organization_name_v
                    where organization_id = c_org_id ;


                    l_token(2).token_value := v_org ;



                    l_token(3).token_name  := 'MODEL_NAME';

                    select concatenated_segments into v_model_name
                    from mtl_system_items_kfv
                    where inventory_item_id = ( select base_item_id
                    from mtl_system_items where inventory_item_id = c_config_item_id and rownum = 1 )
                    and rownum = 1 ;

                    l_token(3).token_value := v_model_name ;


                    cto_msg_pub.cto_message('BOM', 'CTO_ITEM_NOT_ENABLED_IN_POV', l_token );

                    raise FND_API.G_EXC_ERROR;




               when others then


                raise ;

               END ;



	        lStmtNumber := 35;

	        IF PG_DEBUG <> 0 THEN
		       oe_debug_pub.add('going to populate buy cost for item ' || c_config_item_id
                                       || ' for $ ' || v_buy_item_cost , 2);
	        END IF;

                populate_buy_cost_rollup( c_config_item_id
                           , c_org_id
			   , v_buy_cost_type_id
                           , v_buy_item_cost
			   , x_return_status) ;

		if x_return_status = FND_API.G_RET_STS_ERROR then
			ROLLBACK to CTOCST;
			oe_debug_pub.add ('Expected error in populate_buy_cost_rollup.');
			goto endloop;

		elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
			oe_debug_pub.add ('UnExpected error in populate_buy_cost_rollup.');
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;


           else

	        IF PG_DEBUG <> 0 THEN
		       oe_debug_pub.add('buy cost exists for item ' || c_config_item_id
                                       || ' for $ ' || v_buy_cost , 2);
	        END IF;

           end if ;





            end if; /* check if buy cost is not null */
         /* bug 4341197 do not populate list price in buy cost type if the buy cost type profile is not set by the user */




	   lStmtNumber := 37;
	   IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add ('Fetching c_matched_items_cost_synchup cursor ..');
	   END IF;

           /* copy valuation cost to cto cost for matched items */

           open c_matched_items_cost_synchup ( p_cfg_itm_tbl(i).cfg_item_id,
			      		   p_cfg_itm_tbl(i).cfg_org_id) ;

           fetch c_matched_items_cost_synchup into  c_match_config_item_id
                                    , c_organization_id
                                    , c_primary_cost_method
                                    , c_valuation_cost ;

	   close c_matched_items_cost_synchup;

	   IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add ('c_match_config_item_id   = '|| c_match_config_item_id || ';' ||
	                        'c_organization_id  = '|| c_organization_id || ';' ||
	                        'c_primary_cost_method  = '|| c_primary_cost_method || ';' ||
	                        'c_valuation_cost  = '|| c_valuation_cost );
   	   END IF;

	   lStmtNumber := 38;
           begin

               select item_cost into v_cto_cost from cst_item_costs
                where inventory_item_id = c_match_config_item_id
                  and organization_id = c_organization_id
                  and cost_type_id = v_cto_cost_type_id ;


           exception
           when others then
              v_cto_cost := null ;

           end;

	   IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add ('v_cto_cost   = '|| v_cto_cost );
	   END IF;

	   lStmtNumber := 39;
           if( c_valuation_cost <> v_cto_cost  or v_cto_cost is null ) then

              CTO_UTILITY_PK.copy_cost(  c_primary_cost_method
                                       , v_cto_cost_type_id
                                       , c_match_config_item_id
                                       , c_organization_id
                                       )  ;

           end if;


	   IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('calling costing API', 2);
		oe_debug_pub.add(' Params assig set ' || lMrpAssignmentSet || '; cto cost id ' || v_cto_cost_type_id ||
                                 ' buy cost id ' || v_buy_cost_type_id  , 2);

	   END IF;



	   /* can't do bulk insert into cst_sc_lists for PLS-00436 */
	   /* insert item by item */

	   lStmtNumber := 39.1;


	   insert into cst_sc_lists(
		rollup_id,
		inventory_item_id,
		organization_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by
		)
	   select distinct
		lRollupId,
		p_cfg_itm_tbl(i).cfg_item_id,
                mp.cost_organization_id,     --3116778
		sysdate,
		gUserId,
		sysdate,
		gUserId
	   from mtl_system_items msi,
		mtl_parameters mp ,
                cst_item_costs cic
	   where msi.costing_enabled_flag = 'Y'
	   and mp.organization_id = msi.organization_id
	   and cic.inventory_item_id = msi.base_item_id
	   and cic.organization_id = mp.cost_organization_id
	   and cic.based_on_rollup_flag = 1
           and mp.primary_cost_method = cic.cost_type_id
           and cic.cost_type_id in ( 1, 2, 5, 6 )
	   and msi.inventory_item_id = p_cfg_itm_tbl(i).cfg_item_id
	   and msi.organization_id = p_cfg_itm_tbl(i).cfg_org_id
	   and NOT EXISTS
		(select NULL
		from cst_sc_lists
		where rollup_id = lRollupId
		and inventory_item_id = msi.inventory_item_id
		and organization_id = mp.cost_organization_id)  --3116778
           and NOT EXISTS      /* check whether item has been rolled up */
                (       select NULL
                        from cst_item_cost_details
                        where rollup_source_type = 3
                        and inventory_item_id = msi.inventory_item_id
                        and cost_type_id = cic.cost_type_id
                        and organization_id = mp.cost_organization_id) ;  --3116778

	   lCnt := sql%rowcount;
	   -- Bug Fix for 4867460
	   If lCnt > 0 Then
              l_cost_data_exists := 'Y';
	   End if;
	   IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_buy_cost: ' || 'rows inserted into bom_lists::'||to_char(lCnt), 2);
	   END IF;

	  << endloop>>
	    null;

          END LOOP; /* end of array loop */


            -- commented if condition





            --


	    -- bug 4177423 no need of end if as if stmt has been commented end if; /* end of p_cfg_itm_tbl.COUNT */

	--
	-- call SC Cost Rollup API
	--
	lStmtNumber := 60;
	-- Bug Fix 4867460
	If l_cost_data_exists = 'Y' Then

	If PG_DEBUG <> 0 Then
           oe_debug_pub.add('Populate_buy_cost: Calling Supply Chain Rollup program',5);
	End if;

	/* Commented as part of Bugfix 7246036
        CSTPSCEX.Supply_Chain_Rollup(
			lRollupId,	-- i_rollup_id
			1,		-- i_explosion_level
			NULL,		-- i_report_levels
			lMrpAssignmentSet,	-- i_assignment_set_id
			lConversionType,	-- i_conversion_type
			-- 1,			-- i_cost_type_id
			v_cto_cost_type_id ,    -- i_cost_type_id
			v_buy_cost_type_id,     -- i_buy_cost_type_id
			SYSDATE,		-- i_effective_date
			1, 	-- exclude unimplemented ECOs, implemented only
			1, 	-- BOM items only, exclude ENG items
			'',			-- i_alt_bom_desg
			'',			-- i_alt_rtg_desg
			2,			-- i_lock_flag
			gUserId,		-- i_user_id
  			gLoginId,		-- i_login_id
  			NULL,			-- i_request_id
  			NULL, 			-- i_prog_id??
  			702,			-- i_prog_appl_id
			lErrorCode,		-- o_error_code
			lErrorMsg);		-- o_error_msg
        */

        CSTPSCEX.Supply_Chain_Rollup(
			i_rollup_id          => lRollupId,
			i_explosion_levels   => 1,
			i_report_levels      => NULL,
			i_assignment_set_id  => lMrpAssignmentSet,
			i_conversion_type    => lConversionType,
			i_cost_type_id       => v_cto_cost_type_id,
			i_buy_cost_type_id   => v_buy_cost_type_id,
			i_effective_date     => SYSDATE,
			i_exclude_unimpl_eco => 1,
			i_exclude_eng        => 1,
			i_alt_bom_desg       => '',
			i_alt_rtg_desg       => '',
			i_lock_flag          => 2,
			i_user_id            => gUserId,
  			i_login_id           => gLoginId,
  			i_request_id         => NULL,
  			i_prog_id            => NULL,
  			i_prog_appl_id       => 702,
			o_error_code         => lErrorCode,
			o_error_msg          => lErrorMsg,
                        i_buy_cost_detail    => 1 );  --Bugfix 7246036: Passing preserve buy cost details parameter as Yes.

	IF lErrorCode <> 0 THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_buy_cost: ' || 'SC Rollup API returned with error::'||lErrorMsg, 1);
		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('populate_buy_cost: ' || 'SC Rollup API returned with success', 1);
		END IF;


	END IF;

	Else

           If PG_DEBUG <> 0 Then
              oe_debug_pub.add('Populate_buy_cost: No cost data exists. No need to call Supply chain Cost rollup API',5);
	   End if;

	End if;
/*
**
** Costs need to be copied from simulation cost to frozen cost in case of
** standard costing organization
**
*/




	lStmtNumber := 80;
        /* update Frozen cost with CTO Cost in case of standard costing organizations */


	for i in p_cfg_itm_tbl.FIRST..p_cfg_itm_tbl.LAST

	LOOP

	    open c_frozen_cost_update ( v_cto_cost_type_id,
	    			        p_cfg_itm_tbl(i).cfg_item_id,
			      		p_cfg_itm_tbl(i).cfg_org_id) ;

            fetch c_frozen_cost_update into c_config_item_id
                                         , c_organization_id ;


            --exit when c_frozen_cost_update%notfound ;  Bugfix 6038548
            IF c_frozen_cost_update%found THEN   --Bugfix 6038548

                lStmtNumber := 95;
                --Bugfix 6717614
                l_cost_update_required := cost_update_required(c_config_item_id,
                                                               c_organization_id,
                                                               v_cto_cost_type_id);

                IF (l_cost_update_required = 'Y') THEN

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('*****************  going to do frozen cost update for config ' || c_config_item_id
                                        || ' in org ' || c_organization_id , 1);
                    END IF;


                    delete from cst_item_cost_details
                    where inventory_item_id = c_config_item_id
                      and organization_id = c_organization_id
                      and cost_type_id =  1 ;

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('deleted details ' || SQL%ROWCOUNT , 1);
                    END IF;


                    delete from cst_item_costs
                     where inventory_item_id = c_config_item_id
                       and organization_id = c_organization_id
                       and cost_type_id =  1 ;


                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('deleted headers ' || SQL%ROWCOUNT , 1);
                    END IF;


                    copy_ctocost_to_frozen (  c_config_item_id
                                   , c_organization_id
                                   , v_cto_cost_type_id  ) ;

                END IF;
            END IF; --c_frozen_cost_update%found. Bugfix 6038548

	   close c_frozen_cost_update ;


        END LOOP;






	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('populate_buy_cost: ' || 'At end of cost rollup', 2);
	END IF;
	return(1);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		oe_debug_pub.add ('populate_buy_cost: ' || 'cost_rollup::ndf::'||to_char(lStmtNumber)||sqlerrm, 1);
                return(0);

	WHEN CTO_MRP_ASSIGNMENT_SET THEN
		oe_debug_pub.add ('populate_buy_cost: ' || 'cost_rollup::mrp assgn set is null'||to_char(lStmtNumber)||sqlerrm, 1);

                cto_msg_pub.count_and_get
                        ( p_msg_count => x_msg_count
                        , p_msg_data  => x_msg_data
                        );

                return(0);


        WHEN FND_API.G_EXC_ERROR THEN
                oe_debug_pub.add ('Cost_Roll_Up_ML ' || 'cost_rollup::exp error::'||to_char(lStmtNumber)||sqlerrm, 1);

                cto_msg_pub.count_and_get
                        ( p_msg_count => x_msg_count
                        , p_msg_data  => x_msg_data
                        );


                return(0);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		oe_debug_pub.add ('Cost_Roll_Up_ML ' || 'cost_rollup::unexp error::'||to_char(lStmtNumber)||sqlerrm, 1);

                cto_msg_pub.count_and_get
                        ( p_msg_count => x_msg_count
                        , p_msg_data  => x_msg_data
                        );


                return(-1);

	WHEN OTHERS THEN
		oe_debug_pub.add ('Cost_Roll_Up_ML ' || 'cost_rollup::other excpn ::'||to_char(lStmtNumber)||sqlerrm, 1);

                cto_msg_pub.count_and_get
                        ( p_msg_count => x_msg_count
                        , p_msg_data  => x_msg_data
                        );


                return(0);

END Cost_Roll_Up_ML;
/* This procedure has been maintained in patchset J to account for configuration item
** workflow references to patchset I
*/
FUNCTION Cost_Rollup_ML(pTopAtoLineId   in      number,
                        x_msg_count     out NOCOPY number,
                        x_msg_data      out NOCOPY varchar2)
RETURN integer
IS

lMrpAssignmentSet	number;
lRollupId		number;
gUserId			number;
gLoginId		number;
lMsgCount		number;
lMsgData		varchar2(2000);
lStmtNumber		number;
lErrorCode		number;
lErrorMsg		varchar2(2000);
lCnt			number;
lConversionType		varchar2(30);
lBuyCostType		varchar2(30);

CTO_MRP_ASSIGNMENT_SET	exception;

v_cto_cost_type_id          cst_cost_types.cost_type_id%type ;
v_buy_cost_type_id          cst_cost_types.cost_type_id%type ;
v_buy_cost              number ;
c_line_id               bom_cto_src_orgs.line_id%type ;
c_model_item_id         bom_cto_src_orgs.model_item_id%type ;
c_config_item_id        bom_cto_src_orgs.model_item_id%type ;
c_cost_org_id           mtl_parameters.cost_organization_id%type ;              -- 3116778
c_organization_id       bom_cto_src_orgs.organization_id%type ;
c_po_valid_org          financials_system_params_all.inventory_organization_id%type ;
c_oper_unit             inv_organization_info_v.operating_unit%type ;

v_buy_item_cost         mtl_system_items.list_price_per_unit%type ;



cursor c_buy_items
is
select bcso.line_id
     , bcso.model_item_id
     , bcso.config_item_id
     -- 3116778 , bcso.rcv_org_id
     , mp2.cost_organization_id -- 3116778
     , nvl(fsp.inventory_organization_id,0) po_valid_org
     , nvl(org.operating_unit,0) oper_unit
from bom_cto_src_orgs bcso
     , bom_cto_order_lines bcol
     , financials_system_params_all fsp
     , inv_organization_info_v org
     , cst_item_costs   cic
     , mtl_parameters   mp1 /* master organization */
     , mtl_parameters   mp2
where bcso.top_model_line_id = pTopAtoLineId
and   bcol.line_id = bcso.line_id
and   bcso.cost_rollup  = 'Y'
and   ( ( bcso.organization_type in (3,5) and bcol.config_creation in ( 1,2) )
         OR bcol.config_creation = 3 )
and   org.organization_id = bcso.organization_id
and   nvl(org.operating_unit,-1) = nvl(fsp.org_id,-1)
and   cic.inventory_item_id = bcso.config_item_id
and   cic.organization_id = mp2.cost_organization_id  -- 3116778
and   mp2.organization_id = bcso.organization_id      -- 3116778
and   mp2.cost_organization_id = mp1.organization_id  -- 3116778
and   cic.cost_type_id  in ( mp1.primary_cost_method, mp1.avg_rates_cost_type_id) ;

/* 3116778 */
/*
  BUG 3931290
  The original cursor c_frozen_cost_update was using a union (organization_id , rcv_org_id )
  to determine organizations where standard cost update needs to be performed.
  The organizations where standard cost update will be performed will now be determined using organization_id.
  This will eliminate the 2nd sql statement (rcv_org_id) in the union and there will be no need for a union.
  A distinct clause has been added to the statement.
*/
cursor c_frozen_cost_update(c_cto_cost_type_id number )
is
select  distinct                                                             -- bug 3931290
        bcso.config_item_id
      , mp1.cost_organization_id rollup_org_id
from    bom_cto_src_orgs bcso
      , mtl_parameters mp1
      , mtl_parameters mp2
      , cst_item_costs cic
where bcso.top_model_line_id = pTopAtoLineId
and   bcso.cost_rollup = 'Y'
and   bcso.organization_id = mp2.organization_id
and   mp2.cost_organization_id = mp1.organization_id
and   mp1.primary_cost_method = 1
and   cic.inventory_item_id = bcso.config_item_id
and   cic.organization_id = mp1.organization_id
and   cic.cost_type_id = c_cto_cost_type_id
and   ( cic.based_on_rollup_flag = 1 or bcso.organization_type = 3 ); /* bug 3931290 */



-- debug 3116778
cursor cst_cur (xRollupId  number) is
        select inventory_item_id,organization_id
        from cst_sc_lists
        where rollup_id =xRollupId;
d_item_id       number;
d_org_id        number;

cursor c1_cst (c_inventory_item_id number) is
        select cst.inventory_item_id, cst.organization_id, cst.cost_type_id,
               cst.item_cost , cst.material_cost, cst.material_overhead_cost,
               cicd.cost_element_id ,cicd.item_cost cicd_item_cost
        from   cst_item_costs cst, cst_item_cost_details cicd
        where  cst.inventory_item_id = cicd.inventory_item_id
        and    cst.organization_id = cicd.organization_id
        and    cst.cost_type_id = cicd.cost_type_id
        and    cst.inventory_item_id = c_inventory_item_id ;


c1_config_item_id  number ;

v_cur_c1_cst   c1_cst%rowtype ;

-- debug 3116778


v_item_cost                    cst_item_costs.item_cost%type ;
v_material_cost                cst_item_costs.material_cost%type ;
v_material_overhead_cost       cst_item_costs.material_overhead_cost%type ;
v_resource_cost                cst_item_costs.resource_cost%type ;
v_outside_processing_cost      cst_item_costs.outside_processing_cost%type ;
v_overhead_cost                cst_item_costs.overhead_cost%type ;

v_cost_updateable              BOOLEAN := false ;


v_group_id                     bom_explosion_temp.group_id%type ;
/*
x_msg_count                    number ;
x_msg_data                     varchar2(200) ;
*/
x_return_status                varchar2(200) ;


l_token                      CTO_MSG_PUB.token_tbl;

v_po_validation_org     varchar2(2000) ;
v_org                   varchar2(2000) ;
v_model_name            varchar2(2000) ;

v_cto_cost_type_name    cst_cost_types.cost_type%type;
cst_sc_list_count       number;   --bug 4867460

l_cost_update_required   varchar2(1) := 'N'; --bug 6717614

BEGIN
	lStmtNumber := 10;

	gUserId := nvl(fnd_global.user_id, -1);
	gLoginId := nvl(fnd_global.login_id, -1);
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'gUserId::'||to_char(gUserId)
                                 ||'::gLoginId::'||to_char(gLoginId), 2);

		oe_debug_pub.add('Cost_Rollup_ML: ' || 'top line ::'|| pTopAtoLineId , 2 );
	END IF;


	-- changed sequence as per bugfix 3239456
	/*select bom_lists_s.nextval
	into lRollupId from dual;*/

	select cst_lists_s.nextval
        into lRollupId from dual;



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'lRollupId::'||to_char(lRollupId), 2);
	END IF;

	lStmtNumber := 20;
	lMrpAssignmentSet := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

	IF lMrpAssignmentSet is null THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Cost_Rollup_ML: '
                                 || 'Default assignment set is null', 1);
		END IF;


		--FND_MESSAGE.set_name('BOM','CTO_MRP_ASSIGNMENT_SET');
		--raise CTO_MRP_ASSIGNMENT_SET;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Cost_Rollup_ML: ' || 'Default assignment set is '
                                        ||to_char(lMrpAssignmentSet), 2);
		END IF;
	END IF;

	--
	-- Getting the Currency Conversion Type from profile
	-- "INV:Inter-organization currency conversion"
	--
	lStmtNumber := 25;
	lConversionType := FND_PROFILE.VALUE('CURRENCY_CONVERSION_TYPE');


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'Currency Conversion Type ::'
                                 ||lConversionType, 2);
	END IF;

	lStmtNumber := 27;
	lBuyCostType := FND_PROFILE.VALUE('CTO_BUY_COST_TYPE');
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'Buy Cost Type ::'|| lBuyCostType , 2);
	END IF;


	lStmtNumber := 28;

        if( lBuyCostType is not null ) then
           begin
              select cost_type_id into v_buy_cost_type_id
                from cst_cost_types
               where cost_type = lBuyCostType ;

	      IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'Buy Cost Type id ::'
                                || v_buy_cost_type_id , 2);
	      END IF;

           exception
           when no_data_found then

              cto_msg_pub.cto_message('BOM','CTO_BUY_COST_NOT_FOUND');
              raise  FND_API.G_EXC_ERROR;

           when others then

              raise  FND_API.G_EXC_UNEXPECTED_ERROR;


           end;


        end if ;



	lStmtNumber := 29;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: '
                                || ' opening buy cost cursor for bcso ' , 2);
	END IF;

        if( lBuyCostType is not null ) then


        open c_buy_items ;
        loop
           fetch c_buy_items into c_line_id
                                , c_model_item_id
                                , c_config_item_id
                                , c_cost_org_id         -- 3116778
                                , c_po_valid_org
                                , c_oper_unit ;


           exit when c_buy_items%notfound ;

	   IF PG_DEBUG <> 0 THEN
	   	oe_debug_pub.add('Cost_Rollup_ML: ' ||
                            ' fetched line '  || c_line_id         ||
                            ' model '         || c_model_item_id   ||
                            ' config '        || c_config_item_id  ||
                            ' cost org '      || c_cost_org_id     ||           --3116778
                            ' po val '        || c_po_valid_org    ||
                            ' oper '          || c_oper_unit , 2);
	   END IF;

	   lStmtNumber := 30;

           /* Check whether buy cost exists for the item */
           begin
               select item_cost into v_buy_cost
                 from cst_item_costs
                where cost_type_id = v_buy_cost_type_id
                  and organization_id = c_cost_org_id           -- 3116778
                  and inventory_item_id = c_config_item_id ;

           exception
               when no_data_found then
                    v_buy_cost := null ;

	            IF PG_DEBUG <> 0 THEN
		       oe_debug_pub.add('no buy cost exists for item ' || c_config_item_id
                                       || ' in org ' || c_cost_org_id  , 2);            -- 3116778
	            END IF;


               when others then


                    raise  FND_API.G_EXC_UNEXPECTED_ERROR;

           end ;



           if( v_buy_cost is null ) then

	       lStmtNumber := 32;



               BEGIN


               select nvl(list_price_per_unit,0) into v_buy_item_cost
                 from mtl_system_items
                where organization_id = c_po_valid_org and inventory_item_id = c_config_item_id ;


               EXCEPTION
               when no_data_found then


                    IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('create_config_item_wf: ' || 'Item Not Enabled in PO Validation Org ' || c_po_valid_org , 1);
                        oe_debug_pub.add('create_config_item_wf: ' || 'PO Validation Org for Org ' || c_cost_org_id , 1);
                    END IF;


                    -- cto_msg_pub.cto_message('BOM', l_xmsgdata);

                    l_token(1).token_name  := 'POV_ORG';


                    select organization_name into v_po_validation_org
                    from inv_organization_name_v
                    where organization_id = c_po_valid_org ;


                    l_token(1).token_value := v_po_validation_org ;


                    l_token(2).token_name  := 'ORG';

                    select organization_name into v_org
                    from inv_organization_name_v
                    where organization_id = c_cost_org_id ;


                    l_token(2).token_value := v_org ;

                    l_token(3).token_name  := 'MODEL_NAME';

                    select concatenated_segments into v_model_name
                    from mtl_system_items_kfv
                    where inventory_item_id = ( select base_item_id
                    from mtl_system_items where inventory_item_id = c_config_item_id and rownum = 1 )
                    and rownum = 1 ;

                    l_token(3).token_value := v_model_name ;



                    cto_msg_pub.cto_message('BOM', 'CTO_ITEM_NOT_ENABLED_IN_POV', l_token );

                    raise FND_API.G_EXC_ERROR;




               when others then


                raise ;

               END ;




	        lStmtNumber := 35;

	        IF PG_DEBUG <> 0 THEN
		       oe_debug_pub.add('going to populate buy cost for item ' || c_config_item_id
                                       || ' for $ ' || v_buy_item_cost , 2);
	        END IF;

                populate_buy_cost( c_line_id
                           , c_config_item_id
                           , c_cost_org_id              -- 3116778
                           , v_buy_cost_type_id
                           , v_buy_item_cost ) ;


           else

	        IF PG_DEBUG <> 0 THEN
		       oe_debug_pub.add('buy cost exists for item ' || c_config_item_id
                           || ' for $ ' || v_buy_cost ||   'in org '   || c_cost_org_id, 2);  -- 3116778
	        END IF;

           end if ;


        end loop;


        close c_buy_items ;


        end if; /* check if buy cost is not null */







	--
	-- insert into CST_SC_LISTS rows for all config items in all possible
	-- src orgs, where ->
	-- 1. cost has not been calculated yet (cost_rollup = Y)
	-- 2. costing_enabled_flag = Y
	-- 3. primary_cost_method = 1 (standard)
	--
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'inserting into cst_sc_lists', 2);
	END IF;


/*
  BUG 3931290
  The statement insert into cst_sc_lists was using a union (organization_id,  rcv_org_id)
  to determine organizations where cost rollup needs to be performed.
  The organization where cost rollup will be performed will now be determined using organization_id.
  This will eliminate the 2nd sql statement (rcv_org_id) in the union and there will be no need for a union.
*/

	lStmtNumber := 38;
	insert into cst_sc_lists(
		rollup_id,
		inventory_item_id,
		organization_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by
		)
	select distinct
		lRollupId,
		bcso.config_item_id,
		mp.cost_organization_id,
		sysdate,
		gUserId,
		sysdate,
		gUserId
	from bom_cto_src_orgs bcso,
		mtl_system_items msi,
		mtl_parameters mp ,
                cst_item_costs cic
	where bcso.top_model_line_id = pTopAtoLineId
	and bcso.cost_rollup = 'Y'
	and bcso.config_item_id = msi.inventory_item_id
	and bcso.organization_id = msi.organization_id
	and msi.costing_enabled_flag = 'Y'
	and mp.organization_id = bcso.organization_id
	and cic.inventory_item_id = msi.inventory_item_id
        -- 3116778 and cic.organization_id = msi.organization_id
        and cic.organization_id = mp.cost_organization_id       -- 3116778
        -- 3116778 and cic.based_on_rollup_flag = 1
        and (cic.based_on_rollup_flag = 1 or bcso.organization_type = 3)        -- 3116778
	and (
            ( ( mp.primary_cost_method  = 1 )
	       and cic.cost_type_id = 1
            )
            OR
            ( ( mp.primary_cost_method  = 2 )
	       and cic.cost_type_id = 2
            )
            OR
            ( ( mp.primary_cost_method  = 6 )
	       and cic.cost_type_id = 6
            )
            OR
            ( ( mp.primary_cost_method  = 5 )
	       and cic.cost_type_id = 5
            )
            )
	and NOT EXISTS
		(select NULL
		from cst_sc_lists
		where rollup_id = lRollupId
		and inventory_item_id = bcso.config_item_id
		and organization_id = mp.cost_organization_id ) ;



-- debug 3116778
lCnt := sql%rowcount;
        IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Cost_Rollup_ML: ' || 'rows inserted into cst_sc_lists::'||to_char(lCnt), 2);
        END IF;
        cst_sc_list_count := lCnt;  -- Bug# 4867460
        open cst_cur ( lRollupId ) ;

            loop

                fetch cst_cur into d_item_id,d_org_id;

                exit when cst_cur%notfound ;

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Cst list has item : ' ||d_item_id|| ' in org ' || d_org_id,1);
                    END IF;

            end loop;
        close cst_cur;
-- debug 3116778



	lCnt := sql%rowcount;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'rows inserted into cst_sc_lists::'||to_char(lCnt), 2);
	END IF;

	--
	-- call SC Cost Rollup API
	--

	lStmtNumber := 40;


        /* commented for bug 4057651
        begin

            select cost_type_id into v_cto_cost_type_id
            from cst_cost_types
            where cost_type = 'CTO' ;


            if( lBuyCostType is null ) then
                v_buy_cost_type_id := v_cto_cost_type_id ;
            end if ;


        exception
        when no_data_found then

           cto_msg_pub.cto_message('BOM','CTO_COST_NOT_FOUND');
           raise  FND_API.G_EXC_ERROR;

        when others then

           raise  FND_API.G_EXC_UNEXPECTED_ERROR;


        end;


        commented for bug 4057651  */







       /* begin bugfix 4057651, default CTO cost type id = 7 if it does not exist */
        begin

           select cost_type_id into v_cto_cost_type_id
             from cst_cost_types
            where cost_type = 'CTO' ;


        exception
        when no_data_found then

           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' || ' no_data_found error CTO cost type id does not exist',2);
                oe_debug_pub.add('Create_Item: ' || ' defaulting CTO cost type id = 7 ',2);
           END IF;

           v_cto_cost_type_id := 7 ;

           begin
                select cost_type into v_cto_cost_type_name
                  from cst_cost_types
                 where cost_type_id = v_cto_cost_type_id  ;

                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Create_Item: ' || ' cost type id =  ' || v_cto_cost_type_id ||
                                     '  has cost_type =  ' || v_cto_cost_type_name ,2);
                  END IF;
           exception
           when no_data_found then
                 IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Create_Item: ' || ' no_data_found error for cost type id = 7 ',2);
                  END IF;
                 cto_msg_pub.cto_message('BOM','CTO_COST_NOT_FOUND');
                 raise  FND_API.G_EXC_ERROR;
           when others then

              raise  FND_API.G_EXC_UNEXPECTED_ERROR;
           end ;

        when others then
           raise  FND_API.G_EXC_UNEXPECTED_ERROR;
        end ;

        if( lBuyCostType is null ) then
                v_buy_cost_type_id := v_cto_cost_type_id ;
        end if ;

       /* end bugfix 4057651, default CTO cost type id = 7 if it does not exist */



-- debug 3116778

        select config_item_id
        into   c1_config_item_id
        from bom_cto_order_lines
        where line_id = pTopatolineid ;

        open c1_cst ( c1_config_item_id ) ;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add( 'printing sc rollup values ' ,1 ) ;
        END IF;

        loop

           fetch c1_cst into v_cur_c1_cst ;

           exit when c1_cst%notfound ;

           IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add( 'printing sc rollup values ' ,1 ) ;
            oe_debug_pub.add(   'iid ' || v_cur_c1_cst.inventory_item_id ||
                                ' org ' || to_char( v_cur_c1_cst.organization_id) ||
                                ' cstyp ' || to_char( v_cur_c1_cst.cost_type_id) ||
                                ' icst ' || to_char( v_cur_c1_cst.item_cost ) ||
                                ' mcst ' || to_char( v_cur_c1_cst.material_cost ) ||
                                ' mocst ' || to_char( v_cur_c1_cst.material_overhead_cost)||
                                ' ceid ' || to_char( v_cur_c1_cst.cost_element_id ) ||
                                ' cicst ' || to_char( v_cur_c1_cst.cicd_item_cost ) , 1 ) ;
           END IF;


        end loop ;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add( 'done printing sc rollup values ' ,1 ) ;
        END IF;

        close c1_cst ;

-- debug 3116778






	lStmtNumber := 60;
if cst_sc_list_count > 0 then    --bug4867460: call the costing api only if records are inserted
                                         -- in cst_sc_lists. This is to improve performance.
					 	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('******************** calling costing API ****************** ', 2);
		oe_debug_pub.add(' Params assig set ' || lMrpAssignmentSet ||
                                 ' cto cost id ' || v_cto_cost_type_id ||
                                 ' buy cost id ' || v_buy_cost_type_id  , 2);

	END IF;

	/* Commented as part of Bugfix 7246036
        CSTPSCEX.Supply_Chain_Rollup(
			lRollupId,	-- i_rollup_id
			1,		-- i_explosion_level
			NULL,		-- i_report_levels
			lMrpAssignmentSet,	-- i_assignment_set_id
			lConversionType,	-- i_conversion_type
			-- 1,			-- i_cost_type_id
			v_cto_cost_type_id ,    -- i_cost_type_id
			v_buy_cost_type_id,     -- i_buy_cost_type_id
			SYSDATE,		-- i_effective_date
			1, 	-- exclude unimplemented ECOs, implemented only
			1, 	-- BOM items only, exclude ENG items
			'',			-- i_alt_bom_desg
			'',			-- i_alt_rtg_desg
			2,			-- i_lock_flag
			gUserId,		-- i_user_id
  			gLoginId,		-- i_login_id
  			NULL,			-- i_request_id
  			NULL, 			-- i_prog_id??
  			702,			-- i_prog_appl_id
			lErrorCode,		-- o_error_code
			lErrorMsg);		-- o_error_msg
        */

        CSTPSCEX.Supply_Chain_Rollup(
			i_rollup_id          => lRollupId,
			i_explosion_levels   => 1,
			i_report_levels      => NULL,
			i_assignment_set_id  => lMrpAssignmentSet,
			i_conversion_type    => lConversionType,
			i_cost_type_id       => v_cto_cost_type_id,
			i_buy_cost_type_id   => v_buy_cost_type_id,
			i_effective_date     => SYSDATE,
			i_exclude_unimpl_eco => 1,
			i_exclude_eng        => 1,
			i_alt_bom_desg       => '',
			i_alt_rtg_desg       => '',
			i_lock_flag          => 2,
			i_user_id            => gUserId,
  			i_login_id           => gLoginId,
  			i_request_id         => NULL,
  			i_prog_id            => NULL,
  			i_prog_appl_id       => 702,
			o_error_code         => lErrorCode,
			o_error_msg          => lErrorMsg,
                        i_buy_cost_detail    => 1 );  --Bugfix 7246036: Passing preserve buy cost details parameter as Yes.

	IF lErrorCode <> 0 THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('**************  Cost_Rollup_ML: ' || 'SC Rollup API returned with error::'||lErrorMsg, 1);
		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('************** Cost_Rollup_ML: ' || 'SC Rollup API returned with success', 1);
		END IF;


	END IF;
Else
       IF PG_DEBUG <> 0 Then
          oe_debug_pub.add('No cost data Exists. No need to call supply Chain cost rollup API',5);
       End if;
End If; -- Bug fix 4867460


-- debug 3116778

        open c1_cst ( c1_config_item_id ) ;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add( 'printing sc rollup values ' ,1 ) ;
        END IF;

        loop

           fetch c1_cst into v_cur_c1_cst ;

           exit when c1_cst%notfound ;

           IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add( 'printing sc rollup values ' ,1 ) ;
             oe_debug_pub.add(  'iid ' || v_cur_c1_cst.inventory_item_id ||
                                ' org ' || to_char( v_cur_c1_cst.organization_id) ||
                                ' cstyp ' || to_char( v_cur_c1_cst.cost_type_id) ||
                                ' icst ' || to_char( v_cur_c1_cst.item_cost ) ||
                                ' mcst ' || to_char( v_cur_c1_cst.material_cost ) ||
                                ' mocst ' || to_char( v_cur_c1_cst.material_overhead_cost) ||
                                ' ceid ' || to_char( v_cur_c1_cst.cost_element_id ) ||
                                ' cicst ' || to_char( v_cur_c1_cst.cicd_item_cost ) , 1 ) ;
           END IF;

        end loop ;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add( 'done printing sc rollup values ' ,1 ) ;
        END IF;

        close c1_cst ;

-- debug 3116778


/*
**
** Costs need to be copied from simulation cost to frozen cost in case of
** standard costing organization
**
*/




	lStmtNumber := 80;
        --Bugfix 6717614
        if cst_sc_list_count = 0 then

           IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('***No need to do frozen cost update as no rollup has been done' , 1);
           END IF;

        else
        /*update Frozen cost with CTO Cost in case of standard costing organizations */
            lStmtNumber := 90;

            open c_frozen_cost_update ( v_cto_cost_type_id ) ;

            loop

                fetch c_frozen_cost_update into c_config_item_id
                                         , c_organization_id ;


                exit when c_frozen_cost_update%notfound ;

                --Bugfix 6717614
                lStmtNumber := 95;
                l_cost_update_required := cost_update_required(c_config_item_id,
                                                               c_organization_id,
                                                               v_cto_cost_type_id);

                IF (l_cost_update_required = 'Y') THEN


                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('********************** going to do frozen cost update for config ' || c_config_item_id
                                        || ' in org ' || c_organization_id , 1);
                    END IF;


                    delete from cst_item_cost_details
                    where inventory_item_id = c_config_item_id
                      and organization_id = c_organization_id
                      and cost_type_id =  1 ;

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('deleted details ' || SQL%ROWCOUNT , 1);
                    END IF;


                    delete from cst_item_costs
                     where inventory_item_id = c_config_item_id
                       and organization_id = c_organization_id
                       and cost_type_id =  1 ;


                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('deleted headers ' || SQL%ROWCOUNT , 1);
                    END IF;


                    copy_ctocost_to_frozen (  c_config_item_id
                                   , c_organization_id
                                   , v_cto_cost_type_id  ) ;

                END IF;  --l_cost_update_required    Bugfix 6717614
            end loop ;


            close c_frozen_cost_update ;
        end if;  --cst_sc_list_count = 0   Bugfix 6717614


-- debug 3116778

        open c1_cst ( c1_config_item_id ) ;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add( 'printing sc rollup values ' ,1 ) ;
        END IF;

        loop

           fetch c1_cst into v_cur_c1_cst ;

           exit when c1_cst%notfound ;

           IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add( 'printing sc rollup values ' ,1 ) ;
             oe_debug_pub.add(  ' iid ' || v_cur_c1_cst.inventory_item_id ||
                                ' org ' || to_char( v_cur_c1_cst.organization_id) ||
                                ' cstyp ' || to_char( v_cur_c1_cst.cost_type_id) ||
                                ' icst ' || to_char( v_cur_c1_cst.item_cost ) ||
                                ' mcst ' || to_char( v_cur_c1_cst.material_cost ) ||
                                ' mocst ' || to_char( v_cur_c1_cst.material_overhead_cost) ||
                                ' ceid ' || to_char( v_cur_c1_cst.cost_element_id ) ||
                                ' cicst ' || to_char( v_cur_c1_cst.cicd_item_cost ) , 1 ) ;
           END IF;

        end loop ;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add( 'done printing sc rollup values ' ,1 ) ;
        END IF;

        close c1_cst ;

-- debug 3116778



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Cost_Rollup_ML: ' || 'At end of cost rollup', 2);
	END IF;
	return(1);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		oe_debug_pub.add ('Cost_Rollup_ML: ' || 'cost_rollup::ndf::'||to_char(lStmtNumber)||sqlerrm, 1);
                return(0);

	WHEN CTO_MRP_ASSIGNMENT_SET THEN
		oe_debug_pub.add ('Cost_Rollup_ML: ' || 'cost_rollup::mrp assgn set is null'||to_char(lStmtNumber)||sqlerrm, 1);

                cto_msg_pub.count_and_get
                        ( p_msg_count => x_msg_count
                        , p_msg_data  => x_msg_data
                        );


                return(0);


        WHEN FND_API.G_EXC_ERROR THEN
                oe_debug_pub.add ('Cost_Rollup_ML: ' || 'cost_rollup::exp error::'||to_char(lStmtNumber)||sqlerrm, 1);

                cto_msg_pub.count_and_get
                        ( p_msg_count => x_msg_count
                        , p_msg_data  => x_msg_data
                        );


                return(0);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		oe_debug_pub.add ('Cost_Rollup_ML: ' || 'cost_rollup::unexp error::'||to_char(lStmtNumber)||sqlerrm, 1);

                cto_msg_pub.count_and_get
                        ( p_msg_count => x_msg_count
                        , p_msg_data  => x_msg_data
                        );

                return(-1);



END Cost_Rollup_ML;

end CTO_CONFIG_COST_PK;

/
