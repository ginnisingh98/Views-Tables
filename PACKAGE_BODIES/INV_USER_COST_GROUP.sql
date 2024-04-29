--------------------------------------------------------
--  DDL for Package Body INV_USER_COST_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_USER_COST_GROUP" AS
/* $Header: INVCGSTB.pls 120.0 2005/05/25 05:19:17 appldev noship $*/
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
				p_transaction_action_id IN  NUMBER)
  IS
BEGIN
   --Fill in the user logic here
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_cost_group_id := NULL;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_cost_group_id := NULL;
      IF fnd_msg_pub.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg ('inv_user_cost_group','determine_costgroup');
      END IF;
END GET_CG_FOR_NEG_ONHAND;
END inv_user_cost_group;

/
