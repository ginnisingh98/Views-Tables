--------------------------------------------------------
--  DDL for Package CST_INVENTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_INVENTORY_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTPIVTS.pls 120.1 2005/10/06 22:35:51 rajagraw noship $ */
  -- Start of comments
  -- API name        : Calculate_InventoryValue
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : Populates temporary tables CST_INV_QTY_TEMP and
  --                   CST_INV_COST_TEMP with the relevant quantities and
  --                   costs based on the specifications
  -- Parameters      : p_api_version        IN         NUMBER   Required
  --                   p_init_msg_list      IN         NUMBER
  --                   p_commit             IN         VARCHAR2
  --                     Default value is true because this procedure includes
  --                     an fnd call to gather statistics that does an implicit
  --                     commit. Since non-existence of this parameter implies
  --                     that the API does not commit, this is being added to
  --                     ensure that users of this API realize the implicit commit.
  --                     The API will return an error if it is called with this
  --                     value set to false.
  --                   p_organization_id    IN         NUMBER   Required
  --                   p_onhand_value       IN         NUMBER
  --                     This parameter indicates whether onhand quantities
  --                     and costs  needs to be calculated
  --                   p_intransit_value    IN         NUMBER
  --                     This parameter indicates whether intransit quantities
  --                     and costs needs to be calculated
  --                   p_receiving_value    IN         NUMBER
  --                     This parameter indicates whether receiving quantities
  --                     and costs needs to be calculated
  --                   p_valuation_date     IN         DATE
  --                     This paramater indicates the date at which the
  --                     quantities and costs need to be calculated. It is not
  --                     valid for receiving value calculations. If no date is
  --                     specified, the procedure will calculate the current
  --                     values.
  --.                  p_cost_type_id       IN         NUMBER
  --                     This parameter indicates the cost type against which
  --                     the asset status of the item is verified.
  --                   p_item_from          IN         VARCHAR2
  --                   p_item_to            IN         VARCHAR2
  --                   p_category_set_id    IN         NUMBER    Required
  --                   p_category_from      IN         VARCHAR2
  --                   p_category_to        IN         VARCHAR2
  --                   p_cost_group_from    IN         VARCHAR2
  --                   p_cost_group_to      IN         VARCHAR2
  --                   p_subinventory_from  IN         VARCHAR2
  --                   p_subinventory_to    IN         VARCHAR2
  --                   p_qty_by_revision    IN         NUMBER
  --                     This parameter indicates whether the item revision
  --                     information needs to be gathered.
  --                   p_zero_cost_only     IN         NUMBER
  --                     This parameter restricts the range of items to
  --                     those with zero item costs.
  --                   p_zero_qty           IN         NUMBER
  --                      This parameter is valid only for current valuation
  --                      (p_valuation_date is NULL) to include items with zero
  --                      onhand quantity.
  --                   p_expense_item       IN         NUMBER
  --                     This parameter indicates whether to include expense
  --                     items.
  --                   p_expense_sub        IN         NUMBER
  --                     This parameter indicates whether to include expense
  --                     subinventories for onhand quantity calculations.
  --                   p_unvalued_txns      IN         NUMBER
  --                       This parameter indicates whether to include uncosted
  --                       transactions in the calculation for onhand quantity.
  --                   p_receipt            IN         NUMBER
  --                     This paramter indicates whether to calculate the
  --                     intransit quantity that is coming to the current
  --                     organization
  --                   p_shipment           IN         NUMBER
  --                     This parameter indicates whether to calculate the
  --                     intransit quantity that is coming from the current
  --                     organization
  --                   p_detail           IN         NUMBER
  --                     This parameter indicates whether to calculate the
  --                     the intransit quantity in shipment line level
  --                   p_own           IN         NUMBER
  --                     This parameter indicates whether to calculate the
  --                     intransit quantity that belongs to other
  --                     organizations
  --                   p_cost_enabled_only    IN       NUMBER
  --                     If 1, this parameter indicates to calculate qty and value
  --                     for cost enabled items only.
  --                   p_one_time_item   IN         NUMBER
  --                     This parameter indicates whether to calculate the
  --                     receiving quantity for null items, as in the case
  --                     of one-time items.  If 1, include null items.
  --                   p_include_period_end     IN         NUMBER
  --                     This parameter indicates whether to include receiving
  --                     quantity for period-end accrual PO shipments.  If 1,
  --                     include period-end PO shipments; otherwise only include
  --                     online accrual PO shipments.
  --                   x_return_status      OUT NOCOPY VARCHAR2 REQUIRED
  --                   x_msg_count          OUT NOCOPY NUMBER   REQUIRED
  --                   x_msg_data           OUT NOCOPY VARCHAR2 REQUIRED
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Calculate_InventoryValue (
    p_api_version          IN         NUMBER,
    p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN         VARCHAR2 := CST_Utility_PUB.get_true,
    p_organization_id      IN         NUMBER,
    p_onhand_value         IN         NUMBER   := NULL,
    p_intransit_value      IN         NUMBER   := NULL,
    p_receiving_value      IN         NUMBER   := NULL,
    p_valuation_date       IN         DATE     := NULL,
    p_cost_type_id         IN         NUMBER   := NULL,
    p_item_from            IN         VARCHAR2 := NULL,
    p_item_to              IN         VARCHAR2 := NULL,
    p_category_set_id      IN         NUMBER,
    p_category_from        IN         VARCHAR2 := NULL,
    p_category_to          IN         VARCHAR2 := NULL,
    p_cost_group_from      IN         VARCHAR2 := NULL,
    p_cost_group_to        IN         VARCHAR2 := NULL,
    p_subinventory_from    IN         VARCHAR2 := NULL,
    p_subinventory_to      IN         VARCHAR2 := NULL,
    p_qty_by_revision      IN         NUMBER   := NULL,
    p_zero_cost_only       IN         NUMBER   := NULL,
    p_zero_qty             IN         NUMBER   := NULL,
    p_expense_item         IN         NUMBER   := NULL,
    p_expense_sub          IN         NUMBER   := NULL,
    p_unvalued_txns        IN         NUMBER   := NULL,
    p_receipt              IN         NUMBER   := NULL,
    p_shipment             IN         NUMBER   := NULL,
    p_detail               IN         NUMBER   := NULL,
    p_own                  IN         NUMBER   := 1,
    p_cost_enabled_only    IN         NUMBER   := 1,
    p_one_time_item        IN         NUMBER   := NULL,
    p_include_period_end   IN         NUMBER   := NULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2
   );

END CST_Inventory_PUB;

 

/
