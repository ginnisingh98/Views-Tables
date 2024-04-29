--------------------------------------------------------
--  DDL for Package CSL_CSI_ITEM_INSTANCES_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CSI_ITEM_INSTANCES_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: csliiacs.pls 120.0 2005/05/24 18:39:56 appldev noship $ */

FUNCTION Replicate_Record
  ( p_instance_id NUMBER
  , p_resource_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if item instance record should be replicated. Returns TRUE if it should ***/

FUNCTION Pre_Insert_Child
  ( p_instance_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
-- ER 3168446
   ,p_party_site_id IN NUMBER
  )
RETURN BOOLEAN;

/***
  Public function that gets called when an item instance needs to be inserted into ACC table.
  Returns TRUE when record already was or has been inserted into ACC table.
***/

PROCEDURE Post_Delete_Child
  ( p_instance_id IN NUMBER
   ,p_resource_id IN NUMBER
   ,p_flow_type   IN NUMBER DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL
-- ER 3168446
   ,p_party_site_id IN NUMBER
  );
/***
  Public procedure that gets called when an item instance needs to be deleted from ACC table.
***/

PROCEDURE Pre_Insert_Item
  ( p_inventory_item_id IN NUMBER
  , p_organization_id   IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_resource_id       IN NUMBER
  );

PROCEDURE Post_Delete_Item
  ( p_inventory_item_id IN NUMBER
  , p_organization_id   IN NUMBER
  , p_subinventory_code IN VARCHAR2
  , p_resource_id       IN NUMBER
  );

/*Procedure that gets called from mtl_onhand quantities for trackable items*/

PROCEDURE PRE_INSERT_ITEM_INSTANCE ( x_return_status OUT NOCOPY varchar2);
/* Called before item instance Insert */

PROCEDURE POST_INSERT_ITEM_INSTANCE ( p_api_version      IN  NUMBER
                                    , P_Init_Msg_List    IN  VARCHAR2
                                    , P_Commit           IN  VARCHAR2
                                    , p_validation_level IN  NUMBER
                                    , p_instance_id      IN  NUMBER
                                    , X_Return_Status    OUT NOCOPY VARCHAR2
                                    , X_Msg_Count        OUT NOCOPY NUMBER
                                    , X_Msg_Data         OUT NOCOPY VARCHAR2);

/* Called after item instance Insert */

PROCEDURE PRE_UPDATE_ITEM_INSTANCE ( x_return_status OUT NOCOPY varchar2);
/* Called before item instance Update */

PROCEDURE POST_UPDATE_ITEM_INSTANCE ( x_return_status OUT NOCOPY varchar2);
/* Called after item instance Update */

PROCEDURE PRE_DELETE_ITEM_INSTANCE ( x_return_status OUT NOCOPY varchar2);
/* Called before item instance Delete */

PROCEDURE POST_DELETE_ITEM_INSTANCE ( x_return_status OUT NOCOPY varchar2);
/* Called after item instance Delete */

PROCEDURE CONC_ITEM_INSTANCES (p_last_run_date IN DATE);
/* Concurrent program to update all Item instances */

--Conc prog to bring down the extended item attributes. ER 3724152
PROCEDURE Con_Item_Attr( p_status OUT NOCOPY VARCHAR2,
                           p_message OUT NOCOPY VARCHAR2);

END CSL_CSI_ITEM_INSTANCES_ACC_PKG;

 

/
