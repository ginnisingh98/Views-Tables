--------------------------------------------------------
--  DDL for Package Body CST_INVENTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_INVENTORY_PUB" AS
/* $Header: CSTPIVTB.pls 120.3.12010000.2 2010/01/08 19:05:58 fayang ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'CST_Inventory_PUB';

  PROCEDURE Calculate_InventoryValue(
    p_api_version          IN         NUMBER,
    p_init_msg_list        IN         VARCHAR2,
    p_commit               IN         VARCHAR2,
    p_organization_id      IN         NUMBER,
    p_onhand_value         IN         NUMBER,
    p_intransit_value      IN         NUMBER,
    p_receiving_value      IN         NUMBER,
    p_valuation_date       IN         DATE,
    p_cost_type_id         IN         NUMBER,
    p_item_from            IN         VARCHAR2,
    p_item_to              IN         VARCHAR2,
    p_category_set_id      IN         NUMBER,
    p_category_from        IN         VARCHAR2,
    p_category_to          IN         VARCHAR2,
    p_cost_group_from      IN         VARCHAR2,
    p_cost_group_to        IN         VARCHAR2,
    p_subinventory_from    IN         VARCHAR2,
    p_subinventory_to      IN         VARCHAR2,
    p_qty_by_revision      IN         NUMBER,
    p_zero_cost_only       IN         NUMBER,
    p_zero_qty             IN         NUMBER,
    p_expense_item         IN         NUMBER,
    p_expense_sub          IN         NUMBER,
    p_unvalued_txns        IN         NUMBER,
    p_receipt              IN         NUMBER,
    p_shipment             IN         NUMBER,
    p_detail               IN         NUMBER,
    p_own                  IN         NUMBER,
    p_cost_enabled_only    IN         NUMBER,
    p_one_time_item        IN         NUMBER,
	p_include_period_end   IN         NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2
  )
  IS
    l_api_name CONSTANT VARCHAR2(30) := 'Calculate_InventoryValue';
    l_api_version CONSTANT NUMBER := 1.0;
    l_msg_level_threshold NUMBER;
    l_stmt_num NUMBER := 0;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Calculate_InventoryValue_PUB;

    -- Check for call compatibility
    IF NOT FND_API.Compatible_API_Call
           ( p_current_version_number => l_api_version,
             p_caller_version_number => p_api_version,
             p_api_name => l_api_name,
             p_pkg_name => G_PKG_NAME
           )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API message list if necessary
    IF FND_API.To_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Check for message level threshold
    l_msg_level_threshold := FND_PROFILE.Value('FND_AS_MSG_LEVEL_THRESHOLD');
    x_msg_count := l_msg_level_threshold;

    -- Check for the value of p_commit
    IF NOT FND_API.To_Boolean(p_commit)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => 'This API should not be called with p_commit set to false'
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => SUBSTR(
                          l_stmt_num||':'||
                          p_organization_id||','||
                          p_onhand_value||','||
                          p_intransit_value||','||
                          p_receiving_value||','||
                          p_valuation_date||','||
                          p_cost_type_id||','||
                          p_item_from||','||
                          p_item_to||','||
                          p_category_set_id||','||
                          p_category_from||','||
                          p_category_to||','||
                          p_cost_group_from||','||
                          p_cost_group_to||','||
                          p_subinventory_from||','||
                          p_subinventory_to||','||
                          p_qty_by_revision||','||
                          p_zero_cost_only||','||
                          p_zero_qty||','||
                          p_expense_item||','||
                          p_expense_sub||','||
                          p_unvalued_txns||','||
                          p_receipt||','||
                          p_shipment||','||
                          p_cost_enabled_only||','||
						  p_one_time_item||','||
						  p_include_period_end,
                          1,
                          240
                        )
      );
    END IF;

    -- Find the items that match the specifications
    l_stmt_num := 10;
    CST_Inventory_PVT.Populate_ItemList(
      p_api_version     => 1.0,
      p_organization_id => p_organization_id,
      p_cost_type_id    => p_cost_type_id,
      p_item_from       => p_item_from,
      p_item_to         => p_item_to,
      p_category_set_id => p_category_set_id,
      p_category_from   => p_category_from,
      p_category_to     => p_category_to,
      p_zero_cost_only  => p_zero_cost_only,
      p_expense_item    => p_expense_item,
      p_cost_enabled_only => p_cost_enabled_only,
      p_one_time_item => p_one_time_item,
      x_return_status   => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Find the cost groups that match the specifications
    l_stmt_num := 20;
    CST_Inventory_PVT.Populate_CostGroupList(
      p_api_version     => 1.0,
      p_organization_id => p_organization_id,
      p_cost_group_from => p_cost_group_from,
      p_cost_group_to   => p_cost_group_to,
      p_own             => p_own,
      x_return_status   => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Find the subinventories that match the specifications
    l_stmt_num := 30;
    CST_Inventory_PVT.Populate_SubinventoryList(
      p_api_version       => 1.0,
      p_organization_id   => p_organization_id,
      p_subinventory_from => p_subinventory_from,
      p_subinventory_to   => p_subinventory_to,
      p_expense_sub       => p_expense_sub,
      x_return_status     => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Calculate the onhand quantity of matching items in the cost groups and subinventories
    IF p_onhand_value = 1
    THEN
      l_stmt_num := 40;
      CST_Inventory_PVT.Calculate_OnhandQty(
        p_api_version        => 1.0,
        p_organization_id    => p_organization_id,
        p_valuation_date     => p_valuation_date,
        p_qty_by_revision    => p_qty_by_revision,
        p_zero_qty           => p_zero_qty,
        p_unvalued_txns      => p_unvalued_txns,
        x_return_status      => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    -- Calculate the intransit quantity of matching items in the cost groups
    IF p_intransit_value = 1
    THEN
      l_stmt_num := 50;
      CST_Inventory_PVT.Calculate_IntransitQty(
        p_api_version        => 1.0,
        p_organization_id    => p_organization_id,
        p_valuation_date     => p_valuation_date,
        p_receipt            => p_receipt,
        p_shipment           => p_shipment,
        p_detail             => p_detail,
        p_own                => p_own,
        p_unvalued_txns      => p_unvalued_txns,
        x_return_status      => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    -- Calculate the receiving quantity of matching items
    IF p_receiving_value = 1
    THEN
      l_stmt_num := 60;
      CST_Inventory_PVT.Calculate_ReceivingQty(
        p_api_version        => 1.0,
        p_organization_id    => p_organization_id,
        p_valuation_date     => p_valuation_date,
        p_qty_by_revision    => p_qty_by_revision,
        p_include_period_end => p_include_period_end,
        x_return_status      => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;


    -- Calculate the costs
    l_stmt_num := 70;
    CST_Inventory_PVT.Calculate_InventoryCost(
      p_api_version     => 1.0,
      p_valuation_date  => p_valuation_date,
      p_organization_id => p_organization_id,
      x_return_status   => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    l_stmt_num := 80;
    IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_SUCCESS
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        p_pkg_name => G_PKG_NAME,
        p_procedure_name => l_api_name,
        p_error_text => l_stmt_num||': Finished calculating inventory value'
      );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Calculate_InventoryValue_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Calculate_InventoryValue_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      ROLLBACK TO Calculate_InventoryValue_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_msg_level_threshold <= FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
      THEN
        FND_MSG_PUB.Add_Exc_Msg(
          p_pkg_name => G_PKG_NAME,
          p_procedure_name => l_api_name,
          p_error_text => SUBSTR(l_stmt_num||SQLERRM,1,240)
        );
      END IF;

  END Calculate_InventoryValue;
END CST_Inventory_PUB;

/
