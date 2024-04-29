--------------------------------------------------------
--  DDL for Package EAM_ASSET_MOVE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_MOVE_PUB" AUTHID CURRENT_USER AS
  /* $Header: EAMPAMTS.pls 120.2.12010000.3 2008/10/23 08:04:13 vchidura ship $ */


/* Prepare*/

-- Get all the assets in the Hierarchy
-- Validate whether an Asset needs to be processed or not for Asset Move (All Hierarchy Assets)
-- Populate Temporary Table with Valid/Invalid Move Status & Error Message for Asset Not moving

/* Move */

-- Get all the GTT entries which are to be processed
-- Add the to be processed Transaction Records to MTL_TRANSACTIONS_INTERFACE and MTL_SERIAL_NUMBERS_INTERFACE
-- Invoke the Transaction Processor
-- Capture Transaction Status for each record in the MTL_TRANSACTIONS_INTERFACE and MTL_SERIAL_NUMBERS_INTERFACE


TYPE asset_move_hierarchy_REC_TYPE IS RECORD
      (instance_id		 NUMBER,
      serial_number		 VARCHAR2(30),
      gen_object_id		 NUMBER,
      inventory_item_id		 NUMBER,
      current_org_id		 NUMBER,
      current_subinventory_code  VARCHAR2(30),
      maintainable_flag          VARCHAR2(1),
      eam_item_type              NUMBER,
      maint_org_id               NUMBER,
      prepare_status	         VARCHAR2(30),
      prepare_msg	         VARCHAR2(30)
    );

TYPE asset_move_hierarchy_tbl_type is TABLE OF asset_move_hierarchy_REC_TYPE INDEX BY BINARY_INTEGER;

-- p_context determines whether its a prepare move/ actual asset move


PROCEDURE prepareMoveAsset(
	     x_return_status       OUT NOCOPY VARCHAR2,
  	     x_return_message	   OUT NOCOPY VARCHAR2,
             p_parent_instance_id  IN   NUMBER,
             p_dest_org_id	   IN	NUMBER,
             p_includeChild	   IN	VARCHAR2,
             p_move_type	   IN	NUMBER,
             p_curr_org_id	   IN	NUMBER,
             p_curr_subinv_code	   IN	VARCHAR2,
             p_shipment_no	   IN	VARCHAR2,
             p_dest_subinv_code	   IN	VARCHAR2,
             p_context		   IN   VARCHAR2,
             p_dest_locator_id     IN   NUMBER  :=NULL
  );

PROCEDURE getAssetHierarchy(
	     p_parent_instance_id  IN   NUMBER,
	     p_includeChild	   IN	VARCHAR2 ,
	     x_asset_move_hierarchy_tbl OUT NOCOPY asset_move_hierarchy_tbl_type,
	     p_curr_org_id         IN   NUMBER
	);

PROCEDURE populateTemp(
	     p_header_id	   IN NUMBER,
	     p_asset_move_hierarchy_tbl asset_move_hierarchy_tbl_type,
	     p_parent_instance_id  IN NUMBER
	);

PROCEDURE addAssetsToInterface(
	     p_header_id	          IN NUMBER,
	     p_inventory_item_id          IN     NUMBER,
	     p_CURRENT_ORGANIZATION_ID    IN     NUMBER,
	     p_current_subinventory_code  IN	VARCHAR2,
	     p_transfer_organization_id	  IN NUMBER,
	     p_transfer_subinventory_code IN VARCHAR2,
	     p_transaction_type_id	      IN NUMBER,
	     p_shipment_number	          IN VARCHAR2 := NULL,
	     p_transfer_locator_id        IN NUMBER   := NULL,
	     x_locator_error_flag  OUT NOCOPY NUMBER,
             x_locator_error_mssg  OUT NOCOPY VARCHAR2

	     );


PROCEDURE processAssetMoveTxn(
	     p_txn_header_id		  IN	NUMBER,
	     x_return_status		  OUT NOCOPY VARCHAR2,
	     x_return_message		  OUT NOCOPY VARCHAR2
	);

Procedure Get_LocatorControl_Code(
                          p_org      IN NUMBER,
                          p_subinv   IN VARCHAR2,
                          p_item_id  IN NUMBER,
                          p_action   IN NUMBER,
                          x_locator_ctrl     OUT NOCOPY NUMBER,
                          x_error_flag       OUT NOCOPY NUMBER, -- returns 0 if no error ,1 if any error .
                          x_error_mssg       OUT NOCOPY VARCHAR2
)     ;

Function Dynamic_Entry_Not_Allowed(
                          p_restrict_flag IN NUMBER,
                          p_neg_flag      IN NUMBER,
                          p_action        IN NUMBER)  return Boolean;
--Added for 7370638-AMWB-MR
PROCEDURE addAssetsForMiscReceipt(p_header_id IN NUMBER,
				  p_batch_transaction_id IN NUMBER,
				  p_serial_number IN VARCHAR2,
				  p_CURRENT_ORGANIZATION_ID IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_current_subinventory_code IN VARCHAR2,
				  p_intermediate_locator_id IN NUMBER
				  ) ;


END eam_asset_move_pub;

/
