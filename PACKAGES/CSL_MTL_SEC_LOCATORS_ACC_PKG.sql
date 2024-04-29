--------------------------------------------------------
--  DDL for Package CSL_MTL_SEC_LOCATORS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_SEC_LOCATORS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslslacs.pls 115.1 2003/10/24 23:36:21 yliao noship $ */

PROCEDURE Insert_Secondary_Locators
  ( p_inventory_item_id      IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE Update_Secondary_Locators
  ( p_inventory_item_id      IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE Delete_Secondary_Locators
  ( p_inventory_item_id      IN NUMBER
  , p_organization_id        IN NUMBER
  , p_resource_id            IN NUMBER
  );

PROCEDURE POPULATE_SEC_LOCATORS_ACC;
PROCEDURE CON_REQUEST_SECONDARY_LOCATORS;
END CSL_MTL_SEC_LOCATORS_ACC_PKG;

-- Package Specification CSL_MTL_SEC_LOCATORS_ACC_PKG

 

/
