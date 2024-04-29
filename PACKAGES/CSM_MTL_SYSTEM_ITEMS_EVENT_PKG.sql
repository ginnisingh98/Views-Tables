--------------------------------------------------------
--  DDL for Package CSM_MTL_SYSTEM_ITEMS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MTL_SYSTEM_ITEMS_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmesis.pls 120.1 2005/07/25 00:21:08 trajasek noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE Refresh_mtl_system_items_acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);
PROCEDURE get_new_user_mtl_system_items(p_user_id IN NUMBER, p_organization_id IN NUMBER,
                                        p_category_set_id IN NUMBER, p_category_id IN NUMBER);

PROCEDURE MTL_SYSTEM_ITEMS_ACC_I(p_inventory_item_id IN NUMBER,
	    	                     p_organization_id IN NUMBER,
		                         p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE MTL_SYSTEM_ITEMS_ACC_D(p_inventory_item_id IN NUMBER,
	    	                     p_organization_id IN NUMBER,
		                         p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2);

END; -- Package spec

 

/
