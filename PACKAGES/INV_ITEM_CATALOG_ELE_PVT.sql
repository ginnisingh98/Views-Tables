--------------------------------------------------------
--  DDL for Package INV_ITEM_CATALOG_ELE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_CATALOG_ELE_PVT" AUTHID CURRENT_USER AS
/* $Header: INVCEAPS.pls 115.0 2003/12/08 10:14:20 rvuppala noship $ */

----------------------- Global variables and constants -----------------------

g_YES          CONSTANT  VARCHAR2(1)  :=  'Y';
g_NO           CONSTANT  VARCHAR2(1)  :=  'N';


------------------------- Catalog_Grp_Element_Values_Assignment---------------

PROCEDURE Catalog_Grp_Ele_Val_Assignment
(
   p_api_version        IN   NUMBER
,  p_init_msg_list      IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_commit             IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_validation_level   IN   NUMBER    DEFAULT  INV_ITEM_CATALOG_ELEM_PUB.g_VALIDATE_ALL
,  p_inventory_item_id  IN   NUMBER
,  p_item_number        IN   VARCHAR2
,  p_element_name       IN   VARCHAR2
,  p_element_value      IN   VARCHAR2
,  p_default_element_flag IN VARCHAR2
,  x_return_status      OUT  NOCOPY VARCHAR2
,  x_msg_count          OUT  NOCOPY NUMBER
,  x_msg_data           OUT  NOCOPY VARCHAR2
);

END INV_ITEM_CATALOG_ELE_PVT;

 

/
