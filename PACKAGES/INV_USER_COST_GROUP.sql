--------------------------------------------------------
--  DDL for Package INV_USER_COST_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_USER_COST_GROUP" AUTHID CURRENT_USER AS
/* $Header: INVCGSTS.pls 120.0 2005/05/25 07:00:10 appldev noship $ */
PROCEDURE GET_CG_FOR_NEG_ONHAND(x_return_status         OUT NOCOPY VARCHAR2,
				x_msg_count             OUT NOCOPY NUMBER,
				x_msg_data              OUT NOCOPY VARCHAR2,
				x_cost_group_id         OUT NOCOPY NUMBER,
				p_organization_id       IN  NUMBER,
				p_inventory_item_id     IN  NUMBER,
				p_subinventory_code     IN  VARCHAR2,
				p_locator_id            IN  NUMBER,
				p_revision              IN  VARCHAR2,
				p_lot_number            IN  VARCHAR2,
				p_serial_number         IN  VARCHAR2,
				p_transaction_action_id IN  NUMBER);
END inv_user_cost_group;

 

/
