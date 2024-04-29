--------------------------------------------------------
--  DDL for Package INV_COST_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_COST_GROUP_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVDCGS.pls 115.13 2003/06/30 22:15:40 cjandhya ship $ */

-- Glbal constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_COST_GROUP_PVT';
G_INPUT_MMTT                  CONSTANT VARCHAR2(6) :=  'MMTT';
G_INPUT_MOLINE                CONSTANT VARCHAR2(6)  := 'MTRL';
G_MTL_SUPPLY_COST_GROUP_ID    cst_cost_groups.cost_group_id%TYPE := NULL;
G_COMINGLE_ERROR              CONSTANT VARCHAR2(6) :=  'C';

--Bug 3031884 Global constant identifying the transaction that has caused the
--failure. This value has significance only when a failure is returned from
--cost group api.
g_failure_txn_temp_id         NUMBER := NULL;

PROCEDURE Assign_Cost_Group
(
    p_api_version_number	    IN  NUMBER
,   p_init_msg_list	 	    IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit			    IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status		    OUT NOCOPY VARCHAR2
,   x_msg_count			    OUT NOCOPY NUMBER
,   x_msg_data			    OUT NOCOPY VARCHAR2
,   p_transaction_header_id         IN  NUMBER
);

PROCEDURE Assign_Cost_Group
(
    x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_organization_id		    IN  NUMBER
,   p_mmtt_rec   	            IN  mtl_material_transactions_temp%ROWTYPE  DEFAULT NULL
,   p_fob_point                     IN  mtl_interorg_parameters.fob_point%TYPE  DEFAULT NULL
,   p_line_id 		            IN  NUMBER
,   p_input_type		    IN  VARCHAR2
,   x_cost_group_id		    OUT NOCOPY NUMBER
,   x_transfer_cost_group_id        OUT NOCOPY NUMBER
);

-- added the average_cost_var_account as a parameter
PROCEDURE get_default_cost_group
  (x_return_status 		OUT NOCOPY VARCHAR2,
   x_msg_count 			OUT NOCOPY NUMBER,
   x_msg_data  			OUT NOCOPY VARCHAR2,
   x_cost_group_id 		OUT NOCOPY NUMBER,
   p_material_account 		IN NUMBER,
   p_material_overhead_account 	IN NUMBER,
   p_resource_account 		IN NUMBER,
   p_overhead_account 		IN NUMBER,
   p_outside_processing_account IN NUMBER,
   p_expense_account 		IN NUMBER,
   p_encumbrance_account 	IN NUMBER,
   p_average_cost_var_account 	IN NUMBER   DEFAULT NULL,
   p_organization_id 		IN NUMBER,
   p_cost_group      		IN VARCHAR2 DEFAULT NULL
   );

PROCEDURE get_cost_group(x_cost_group_id      OUT NOCOPY NUMBER,
			 x_cost_group         OUT NOCOPY VARCHAR2,
			 x_return_status      OUT NOCOPY VARCHAR2,
			 x_msg_count          OUT NOCOPY NUMBER,
			 x_msg_data           OUT NOCOPY VARCHAR2,
			 p_organization_id    IN  NUMBER,
			 p_lpn_id             IN  NUMBER,
			 p_inventory_item_id  IN  NUMBER,
			 p_revision           IN  VARCHAR2,
			 p_subinventory_code  IN  VARCHAR2,
			 p_locator_id         IN  NUMBER,
			 p_lot_number         IN  VARCHAR2,
			 p_serial_number      IN  VARCHAR2);


END INV_COST_GROUP_PVT;

 

/
