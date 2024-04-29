--------------------------------------------------------
--  DDL for Package CSL_MTL_SYSTEM_ITEMS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_SYSTEM_ITEMS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslsiacs.pls 120.0 2005/05/25 11:07:33 appldev noship $ */

PROCEDURE Pre_Insert_Child
  ( p_inventory_item_id  IN NUMBER
  , p_organization_id    IN NUMBER
  , p_resource_id        IN NUMBER
  );

PROCEDURE Post_Delete_Child
  ( p_inventory_item_id  IN NUMBER
  , p_organization_id    IN NUMBER
  , p_resource_id        IN NUMBER
  );

PROCEDURE CON_REQUEST_MTL_SYSTEM_ITEMS;

PROCEDURE DELETE_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 );

PROCEDURE INSERT_ALL_ACC_RECORDS( p_resource_id IN NUMBER
                                , x_return_status OUT NOCOPY VARCHAR2 );

END CSL_MTL_SYSTEM_ITEMS_ACC_PKG;

 

/
