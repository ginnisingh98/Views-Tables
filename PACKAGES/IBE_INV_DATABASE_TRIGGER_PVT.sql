--------------------------------------------------------
--  DDL for Package IBE_INV_DATABASE_TRIGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_INV_DATABASE_TRIGGER_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVIDTS.pls 120.0 2005/05/30 02:25:15 appldev noship $ */

PROCEDURE MTL_Categories_B_Deleted(
   p_old_category_id IN NUMBER
);


PROCEDURE MTL_Item_Categories_Inserted(
   p_new_inventory_item_id IN NUMBER,
   p_new_organization_id   IN NUMBER,
   p_new_category_set_id   IN NUMBER,
   p_new_category_id       IN NUMBER
);


PROCEDURE MTL_Item_Categories_Deleted(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER,
   p_old_category_set_id   IN NUMBER,
   p_old_category_id       IN NUMBER
);


PROCEDURE MTL_Item_Categories_Updated(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER,
   p_old_category_set_id   IN NUMBER,
   p_old_category_id       IN NUMBER,
   p_new_inventory_item_id IN NUMBER,
   p_new_organization_id   IN NUMBER,
   p_new_category_set_id   IN NUMBER,
   p_new_category_id       IN NUMBER
);


PROCEDURE MTL_System_Items_B_Deleted(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER
);


PROCEDURE MTL_System_Items_B_Updated(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER,
   p_old_web_status        IN VARCHAR2,
   p_new_web_status        IN VARCHAR2
 );

PROCEDURE MTL_System_Items_TL_Inserted(
   p_new_inventory_item_id IN NUMBER  ,
   p_new_organization_id   IN NUMBER  ,
   p_new_language          IN VARCHAR2,
   p_new_description       IN VARCHAR2,
   p_new_long_description  IN VARCHAR2
);


PROCEDURE MTL_System_Items_TL_Deleted(
   p_old_inventory_item_id IN NUMBER  ,
   p_old_organization_id   IN NUMBER  ,
   p_old_language          IN VARCHAR2
);


PROCEDURE MTL_System_Items_TL_Updated(
   p_old_inventory_item_id IN NUMBER  ,
   p_old_organization_id   IN NUMBER  ,
   p_old_language          IN VARCHAR2,
   p_old_description       IN VARCHAR2,
   p_old_long_description  IN VARCHAR2,
   p_new_language          IN VARCHAR2,
   p_new_description       IN VARCHAR2,
   p_new_long_description  IN VARCHAR2
);

END IBE_INV_Database_Trigger_PVT;

 

/
