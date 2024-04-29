--------------------------------------------------------
--  DDL for Package CST_COST_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_COST_API" AUTHID CURRENT_USER AS
/* $Header: CSTCAPIS.pls 120.1 2007/11/07 00:11:22 ipineda ship $ */
/*#
 * This package contains Item Cost APIs.
 * @rep:scope public
 * @rep:product BOM
 * @rep:lifecycle active
 * @rep:displayname Item Cost API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CST_ITEM_COST
 */

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

/*#
 * This function returns the item cost for a given item and organization.
 * @param p_api_version API version
 * @param p_inventory_item_id inventory item id
 * @param p_organization_id organization id
 * @param p_cost_group_id cost group id
 * @param p_cost_type_id cost type id
 * @param p_precision precision
 * @return Item Cost
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Item Cost
 * @rep:compatibility S
 */
function get_item_cost (
        p_api_version         in number,
        p_inventory_item_id   in number,
        p_organization_id     in number,
        p_cost_group_id       in number default NULL,
        p_cost_type_id        in number default NULL,
        p_precision	      in number default NULL
)
return number;


END CST_COST_API;

/
