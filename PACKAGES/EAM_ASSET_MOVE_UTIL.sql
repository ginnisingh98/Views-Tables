--------------------------------------------------------
--  DDL for Package EAM_ASSET_MOVE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_MOVE_UTIL" AUTHID CURRENT_USER AS
  /* $Header: EAMAMUTS.pls 120.4.12010000.2 2008/10/20 10:55:10 vchidura ship $ */

-- validate whether an asset under context can be moved or not (before Asset Move UI is thrown)
-- Also called by isValidAssetMove() which will be called for a list of asset records

Procedure isValidMove(
		p_instance_id	IN	NUMBER,
		p_transaction_date	IN DATE DEFAULT SYSDATE,
		p_inventory_item_id	IN NUMBER,
		p_curr_org_id	IN NUMBER,
		x_return_status IN OUT NOCOPY varchar2,
		x_return_message OUT NOCOPY varchar2
		);

Procedure isValidAssetMove(
		p_asset_hierarchy_REC	IN	eam_asset_move_pub.asset_move_hierarchy_REC_TYPE,
		p_dest_org_id IN NUMBER,
		p_counter     IN NUMBER,
		x_return_status OUT NOCOPY varchar2,
		x_return_message OUT NOCOPY varchar2
		);

-- isOpenPeriod(sysdate) as sysdate is passed as the transaction date
FUNCTION isOpenPeriod(
  p_organization_id	IN NUMBER,
	p_transaction_date      IN     DATE
	)
RETURN BOOLEAN;

-- isTransactable(inventory_item_id,org_id)
FUNCTION isTransactable(
	     p_inventory_item_id      IN     NUMBER
	     ,p_organization_id        IN     NUMBER
	     )
RETURN BOOLEAN;

-- hasSubInventory(instance_id)
FUNCTION hasSubInventory(
	    p_instance_id      IN     NUMBER
	     )
RETURN BOOLEAN;

-- isLocated(instance_id) --assets in location
FUNCTION isLocated(
	     p_instance_id      IN     NUMBER
	     )
RETURN BOOLEAN;

-- isInTransit(instance_id)
FUNCTION isInTransit(
	     p_instance_id      IN     NUMBER
	     )
RETURN BOOLEAN;

-- isAssetRoute(instance_id)
FUNCTION isAssetRoute(
	     p_instance_id      IN     NUMBER
	     )
RETURN BOOLEAN;

-- hasProdEquipLink(instance_id)
FUNCTION hasProdEquipLink(
	     p_instance_id      IN     NUMBER
	     )
RETURN BOOLEAN;

-- hasPropMngrLink(instance_id)
FUNCTION hasPropMngrLink(
	    p_instance_id      IN     NUMBER
	     )
RETURN BOOLEAN;

-- isInMaintOrg(instance_id,org_id)
	-- Assets in Diff Maint Org
	-- Assets in Diff Prod Org which are not maintained by the current parent maint_org_id
FUNCTION isInMaintOrg(
	     p_instance_id      IN     NUMBER
	     ,p_organization_id        IN     NUMBER
	     ,p_gen_object_id IN NUMBER
	     )
RETURN BOOLEAN;

-- for Inter Org Transfers

-- isItemAssigned(inventory_item_id, org_id);
FUNCTION isItemAssigned(
	     p_inventory_item_id      IN     NUMBER
	     ,p_organization_id        IN     NUMBER
	     )
RETURN BOOLEAN;

-- isUniqueShipmentNumber(shipment_number);
FUNCTION isUniqueShipmentNumber(
	     p_shipment_number IN VARCHAR2
	     )
RETURN boolean;

FUNCTION translate_message(
		prod IN VARCHAR2
		,msg IN VARCHAR2
		)
return VARCHAR2  ;



END eam_asset_move_util;

/
