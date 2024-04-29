--------------------------------------------------------
--  DDL for Package INV_COST_GROUP_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COST_GROUP_UPDATE" AUTHID CURRENT_USER AS
/* $Header: INVCGUPS.pls 120.1.12010000.1 2008/07/24 01:27:28 appldev ship $ */
PROCEDURE proc_get_costgroup(p_organization_id       IN  NUMBER,
			     p_inventory_item_id     IN  NUMBER,
			     p_subinventory_code     IN  VARCHAR2,
			     p_locator_id            IN  NUMBER,
			     p_revision              IN  VARCHAR2,
			     p_lot_number            IN  VARCHAR2,
			     p_serial_number         IN  VARCHAR2,
			     p_containerized_flag    IN  NUMBER,
			     p_lpn_id                IN  NUMBER,
			     p_transaction_action_id IN  NUMBER,
			     x_cost_group_id         OUT NOCOPY NUMBER,
			     x_return_status         OUT NOCOPY VARCHAR2);

PROCEDURE  cost_group_update
           (p_transaction_rec            IN   mtl_material_transactions_temp%ROWTYPE,
            p_fob_point                  IN   mtl_interorg_parameters.fob_point%TYPE DEFAULT NULL,
	    p_transfer_wms_org           IN   BOOLEAN DEFAULT TRUE,
	    p_tfr_primary_cost_method    IN   NUMBER,
	    p_tfr_org_cost_group_id      IN   NUMBER,
	    p_from_project_id            IN   NUMBER DEFAULT NULL,
	    p_to_project_id              IN   NUMBER DEFAULT NULL,
	    x_return_status              OUT  NOCOPY VARCHAR2,
            x_msg_count                  OUT  NOCOPY NUMBER,
            x_msg_data                   OUT  NOCOPY VARCHAR2);

-- Gets the current cost group for the material given parameters
-- First checks the mtl_onhand_quantities for onhand inventory and then the
-- mtl_material_transactions_temp for any pending transactions. If no
-- entries are found there then it checks if negative onhand balances are
-- allowed. If negative balances are allowed then it assigns the default
-- cost group of the subinventory or the organization.

--Bug 4632519
--This procedure is opened up only for Pick Load Page to verify commingling
--Do not use for other purpose
PROCEDURE proc_determine_costgroup(p_organization_id       IN  NUMBER,
				   p_inventory_item_id     IN  NUMBER,
				   p_subinventory_code     IN  VARCHAR2,
				   p_locator_id            IN  NUMBER,
				   p_revision              IN  VARCHAR2,
				   p_lot_number            IN  VARCHAR2,
				   p_serial_number         IN  VARCHAR2,
				   p_containerized_flag    IN  NUMBER,
				   p_lpn_id                IN  NUMBER,
				   p_transaction_action_id IN  NUMBER,
				   p_is_backflush_txn      IN  BOOLEAN,
				   x_cost_group_id         OUT NOCOPY NUMBER,
				   x_return_status         OUT NOCOPY VARCHAR2);
END inv_cost_group_update;

/
