--------------------------------------------------------
--  DDL for Package CST_INVENTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_INVENTORY_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVIVTS.pls 120.4.12010000.1 2008/07/24 17:26:01 appldev ship $ */

  -- Start of comments
  -- API name        : Populate_ItemList
  -- Type            : Private
  -- Pre-reqs        : None
  -- Function        : Populates temporary table CST_ITEM_LIST_TEMP with the
  --                   items that match the given specifications
  -- Parameters      : p_api_version     IN         NUMBER   Required
  --                   p_organization_id IN         NUMBER   Required
  --                   p_cost_type_id    IN         NUMBER
  --                     This parameter indicates the cost type against which
  --                     the asset status of the item is verified.
  --                   p_item_from       IN         VARCHAR2
  --                   p_item_to         IN         VARCHAR2
  --                   p_category_set_id IN         NUMBER   Required
  --                   p_category_from   IN         VARCHAR2
  --                   p_category_to     IN         VARCHAR2
  --                   p_zero_cost_only  IN         NUMBER
  --                     This parameter restricts the range of items to
  --                     those with zero item costs.
  --                   p_expense_item    IN         NUMBER
  --                     This parameter indicates whether to include expense
  --                     items.
  --                   p_cost_enabled_only	 IN         NUMBER
  --                     This parameter restricts the items to include cost
  --                     enabled items only.  If 1, only cost enabled items
  --                     will be included.  Otherwise, all items including
  --                     non-cost enabled items will be included - in which case
  --                     all items in the range, regardless of whether they are
  --                     expense or have zero cost, will be included.
  --                   p_one_time_item     IN         NUMBER
  --                     If this parameter is 1, indicates that a row with null
  --                     item id should be included for one-time items.  When called from
  --                     the Receiving Value Report, the parameter should be 1 so as
  --                     to include one-time (description) items.  If any value other
  --                     than 1, one-time items will not be included.
  --                   x_return_status   OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Populate_ItemList(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_cost_type_id         IN         NUMBER   := NULL,
    p_item_from            IN         VARCHAR2 := NULL,
    p_item_to              IN         VARCHAR2 := NULL,
    p_category_set_id      IN         NUMBER,
    p_category_from        IN         VARCHAR2 := NULL,
    p_category_to          IN         VARCHAR2 := NULL,
    p_zero_cost_only       IN         NUMBER   := NULL,
    p_expense_item         IN         NUMBER   := NULL,
    p_cost_enabled_only    IN         NUMBER := NULL,
    p_one_time_item        IN         NUMBER := NULL,
    x_return_status        OUT NOCOPY VARCHAR2
   );

  -- Start of comments
  -- API name        : Populate_CostGroupList
  -- Type            : Private
  -- Pre-reqs        : None
  -- Function        : Populates temporary table CST_CG_LIST_TEMP with the cost
  --                   groups that match the given specifications.
  -- Parameters      : p_api_version        IN         NUMBER   Required
  --                   p_organization_id    IN         NUMBER   Required
  --                   p_cost_group_from    IN         VARCHAR2
  --                   p_cost_group_to      IN         VARCHAR2
  --                   p_own                IN         NUMBER
  --                     This identifier specifies if the cost group list
  --                     should include cost groups of all the organizations
  --                     that are in the current organization's shipping
  --                     network.
  --                   x_return_status      OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Populate_CostGroupList(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_cost_group_from      IN         VARCHAR2 := NULL,
    p_cost_group_to        IN         VARCHAR2 := NULL,
    p_own                  IN         NUMBER   := 1,
    x_return_status        OUT NOCOPY VARCHAR2
   );

  -- Start of comments
  -- API name        : Populate_SubinventoryList
  -- Type            : Private
  -- Pre-reqs        : None
  -- Function        : Populates temporary table CST_SUB_LIST_TEMP with the
  --                   subinventories that match the given specifications.
  -- Parameters      : p_api_version        IN         NUMBER   Required
  --                   p_organization_id    IN         NUMBER   Required
  --                   p_subinventory_from  IN         VARCHAR2
  --                   p_subinventory_to    IN         VARCHAR2
  --                   p_expense_sub        IN         NUMBER
  --                     This parameter indicates whether to include expense
  --                     subinventories.
  --                   x_return_status      OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Populate_SubinventoryList(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_subinventory_from    IN         VARCHAR2 := NULL,
    p_subinventory_to      IN         VARCHAR2 := NULL,
    p_expense_sub          IN         NUMBER   := NULL,
    x_return_status        OUT NOCOPY VARCHAR2
   );

  -- Start of comments
  -- API name        : Calculate_OnhandQty
  -- Type            : Private
  -- Pre-reqs        : Calls to Populate_ItemList, Populate_SubinventoryList,
  --                   and Populate_CostGroupList.
  -- Function        : Populates temporary table CST_INV_QTY_TEMP with the
  --                   quantity of items in the cost groups and subinventories
  --                   that match the given specifications.
  -- Parameters      : p_api_version        IN         NUMBER   Required
  --                   p_organization_id    IN         NUMBER   Required
  --                   p_valuation_date     IN         DATE
  --                     This paramater indicates the date at which the onhand
  --                     quantity needs to be calculated. If no date is
  --                     specified, the procedure will calculate the current
  --                     onhand quantity.
  --                   p_qty_by_revision    IN         NUMBER
  --                      This parameter indicates whether the item revision
  --                      information needs to be gathered.
  --                   p_zero_qty           IN         NUMBER
  --                      This parameter is valid only for current valuation
  --                      (p_valuation_date is NULL) to include items with zero
  --                      onhand quantity.
  --                   p_unvalued_txns      IN         NUMBER
  --                       This parameter indicates whether to include uncosted
  --                       transactions in the calculation for onhand quantity.
  --                   x_return_status      OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Calculate_OnhandQty(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_valuation_date       IN         DATE   := NULL,
    p_qty_by_revision      IN         NUMBER := NULL,
    p_zero_qty             IN         NUMBER := NULL,
    p_unvalued_txns        IN         NUMBER := NULL,
    x_return_status        OUT NOCOPY VARCHAR2
   );

  -- Start of comments
  -- API name        : Calculate_IntransitQty
  -- Type            : Private
  -- Pre-reqs        : Calls to Populate_ItemList and Populate_CostGroupList.
  -- Function        : Populates temporary table CST_INV_QTY_TEMP with the
  --                   quantity of intransit items in the cost groups that
  --                   match the given specifications.
  -- Parameters      : p_api_version        IN         NUMBER   Required
  --                   p_organization_id    IN         NUMBER   Required
  --                   p_valuation_date     IN         DATE
  --                     This parameter indicates the date at which the
  --                     intransit quantity needs to be calculated. If no date
  --                     is specified, the procedure will calculate the current
  --                     intransit quantity.
  --                   p_receipt            IN         NUMBER
  --                     This parameter indicates whether to calculate the
  --                     intransit quantity that is coming to the current
  --                     organization
  --                   p_shipment           IN         NUMBER
  --                     This parameter indicates whether to calculate the
  --                     intransit quantity that is coming from the current
  --                     organization
  --                   p_detail             IN         NUMBER
  --                     This parameter indicates whether to calculate the
  --                     intransit quantity at the shipment line level
  --                     granularity. The default is no.
  --                   p_unvalued_txns      IN         NUMBER
  --                       This parameter indicates whether to include uncosted
  --                       transactions in the calculation for intransit quantity.
  --                   x_return_status      OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Calculate_IntransitQty(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_valuation_date       IN         DATE   := NULL,
    p_receipt              IN         NUMBER := NULL,
    p_shipment             IN         NUMBER := NULL,
    p_detail               IN         NUMBER := NULL,
    p_own                  IN         NUMBER := NULL,
    p_unvalued_txns        IN         NUMBER := NULL,
    x_return_status        OUT NOCOPY VARCHAR2
   );

  -- Start of comments
  -- API name        : Calculate_ReceivingQty
  -- Type            : Private
  -- Pre-reqs        : Calls to Populate_ItemList and Populate_CostGroupList.
  -- Function        : Populates temporary table CST_INV_QTY_TEMP with the
  --                   quantity of items in receiving dock in the cost groups
  --                   that match the given specifications.
  -- Parameters      : p_api_version        IN         NUMBER   Required
  --                   p_organization_id    IN         NUMBER   Required
  --                   p_valuation_date     IN         DATE
  --                     This parameter indicates the date at which the
  --                     receiving quantity needs to be calculated. If no date
  --                     is specified, the procedure will calculate the current
  --                     receiving quantity.
  --                   p_qty_by_revision    IN         NUMBER
  --                      This parameter indicates whether the item revision
  --                      information needs to be gathered.
  --                   p_include_period_end    IN         NUMBER
  --                      This parameter indicates whether receiving quantity
  --                      for period-end accrual PO shipments needs to be gathered.
  --                      If not, only online accrual PO shipments will be included.
  --                   x_return_status      OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Calculate_ReceivingQty(
    p_api_version          IN         NUMBER,
    p_organization_id      IN         NUMBER,
    p_valuation_date       IN         DATE := NULL,
    p_qty_by_revision      IN         NUMBER := NULL,
    p_include_period_end   IN         NUMBER := NULL,
    x_return_status        OUT NOCOPY VARCHAR2
   );

  -- Start of comments
  -- API name        : Get_ParentReceiveTxn
  -- Type            : Private
  -- Pre-reqs        : None
  -- Function        : Given the transaction_id passed in, returns the
  --                   parent Receive or Match transaction id in RT.
  -- Parameters      : p_rcv_transaction_id    IN         NUMBER
  --                     This is the transaction_id in RCV_TRANSACTIONS
  --                     for which this function will find the parent
  --                     Receive or Match transaction in RCV_TRANSACTIONS.
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  FUNCTION Get_ParentReceiveTxn (
  	p_rcv_transaction_id IN NUMBER
  )
  RETURN NUMBER;

  -- Start of comments
  -- API name        : Calculate_InventoryCost
  -- Type            : Private
  -- Pre-reqs        : Calls to Calculate_OnhandQty, Calculate_IntransitQty or
  --                   Calculate_ReceivingQty
  -- Function        : Populates temporary table CST_INV_COST_TEMP with the
  --                   cost of items CST_INV_QTY_TEMP.
  -- Parameters      : p_api_version        IN         NUMBER   Required
  --                   p_valuation_date     IN         DATE
  --                   p_organization_id    IN         NUMBER
  --                   x_return_status      OUT NOCOPY VARCHAR2 Required
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Calculate_InventoryCost(
    p_api_version          IN         NUMBER,
    p_valuation_date       IN         DATE     := NULL,
    p_organization_id      IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2
   );

END CST_Inventory_PVT;

/
