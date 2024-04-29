--------------------------------------------------------
--  DDL for Package Body CST_COST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_COST_API" AS
/* $Header: CSTCAPIB.pls 120.2 2007/11/07 00:13:51 ipineda ship $ */

-------------------------------------------------------------------------
-- get_item_cost()
--
-- Synopsis:
--
--   This function returns the item cost for a given item and organization.
--   This function accepts only IN parameters, and returns a single value.
--   This makes the API simple to call as part of SQL statements.
--
--   You may also pass either the cost group ID or the cost type ID,
--   if you desire more specific cost information.  Do not pass both the
--   cost group and the cost type at the same time.
--
--   For now, pass p_api_version = 1.
--
--   This API currently does not support the retrieval of specific layer
--   costs within a FIFO/LIFO organization.
--
--
-- Code Details:
--
--   The output of this function is dependent on the primary cost method
--   of the organization, and which of the parameters were specified.
--   Note that you should never specify both the cost_type_id and
--   the cost_group_id together; to not pass a parameter, use NULL.
--
--   For FIFO/LIFO, the cost group average from CQL is returned.
--
--   Parameters             | Standard              | Average/FIFO/LIFO
--   -----------------------+-----------------------+----------------------
--   item, org              | Frozen from CIC       | Default CG from CQL
--   item, org, cost_group  | Frozen from CIC       | Specified CG from CQL
--   item, org, cost_type   | Specified CT from CIC | Specified CT from CIC
--
--   The precision parameter is used to determinate what type of rounding
--   should be applied to the item cost value that is returned. The number
--   specified for this parameter represents the number of decimal digits
--   that the output will be rounded to and its defaulted as NULL.
--
-- Error Conditions:
--
--   For all errors, the returned value is NULL.
--
--   The possible error conditions are:
--     Invalid item/organization combination.
--     Item is not cost enabled.
--     Item has no cost in the specified cost group or cost type.
----------------------------------------------------------------------

function get_item_cost (
        p_api_version         in number,
        p_inventory_item_id   in number,
        p_organization_id     in number,
        p_cost_group_id       in number default NULL,
        p_cost_type_id        in number default NULL,
        p_precision           in number default NULL
)
return number
is

        l_stmt_num                number := 0;
        l_item_cost               number := NULL;
        l_cost_method_id          number := NULL;
        l_default_cost_group_id   number := NULL;

begin


        if p_cost_group_id is not NULL AND p_cost_type_id is not NULL then
                return NULL;
        end if;


        l_stmt_num := 10;
        select MP.primary_cost_method,
               MP.default_cost_group_id
        into   l_cost_method_id,
               l_default_cost_group_id
        from   mtl_parameters MP
        where  MP.organization_id = p_organization_id;

-- Changes introduced in if statement to select the item cost from the
-- Cost Organization please refer to bug 6431253 for further
-- information.         09/19/2007
        if p_cost_type_id is not NULL OR l_cost_method_id = 1 then

                l_stmt_num := 20;
                select CIC.item_cost
                into   l_item_cost
                from   cst_item_costs CIC,
                       mtl_parameters mp
                where  CIC.inventory_item_id = p_inventory_item_id     AND
                       CIC.organization_id   = mp.cost_organization_id  AND
                       CIC.cost_type_id      = NVL( p_cost_type_id, 1 ) AND
                       mp.organization_id    = p_organization_id ;

        else

                l_stmt_num := 30;
                select CQL.item_cost
                into   l_item_cost
                from   cst_quantity_layers CQL,
                       mtl_parameters mp
                where  CQL.inventory_item_id = p_inventory_item_id    AND
                       CQL.organization_id   = mp.cost_organization_id       AND
                       CQL.cost_group_id     = NVL( p_cost_group_id,
                                                   l_default_cost_group_id ) AND
                       mp.organization_id    = p_organization_id ;

        end if;

        /*Bug6514166: Added rounding functionality to the returned value*/
        if p_precision is NULL then
        	return l_item_cost;
	else
		return round(l_item_cost,p_precision);
        end if;


exception
        when others then
                return NULL;

end get_item_cost;


END CST_COST_API;

/
