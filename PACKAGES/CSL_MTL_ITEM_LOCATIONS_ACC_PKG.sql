--------------------------------------------------------
--  DDL for Package CSL_MTL_ITEM_LOCATIONS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_ITEM_LOCATIONS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslmlacs.pls 120.0 2005/05/24 17:36:31 appldev noship $*/
PROCEDURE Insert_Item_Locs_By_Subinv
  ( p_subinventory_code      IN VARCHAR2
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE Delete_Item_Locs_By_Subinv
  ( p_subinventory_code      IN VARCHAR2
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE Insert_Item_Location
  ( p_inventory_location_id  IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE Update_Item_Location
  ( p_inventory_location_id  IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE Delete_Item_Location
  ( p_inventory_location_id  IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE POPULATE_ITEM_LOCATIONS_ACC;
PROCEDURE CON_REQUEST_ITEM_LOCATIONS;

END CSL_MTL_ITEM_LOCATIONS_ACC_PKG;

 

/
