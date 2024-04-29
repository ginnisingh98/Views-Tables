--------------------------------------------------------
--  DDL for Package CSM_SYSTEM_ITEM_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_SYSTEM_ITEM_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: csmemsis.pls 120.2 2008/02/06 12:39:43 anaraman ship $ */

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

PROCEDURE Refresh_mtl_onhand_quantity(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2);

PROCEDURE get_new_user_system_items(p_user_id IN number);

PROCEDURE SYSTEM_ITEM_MDIRTY_I(p_inventory_item_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_user_id IN NUMBER);

PROCEDURE SYSTEM_ITEM_MDIRTY_D(p_inventory_item_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_user_id IN NUMBER);

-- below procedure is called from csm_mtl_system_items where there is an org change
PROCEDURE delete_system_items(p_user_id IN NUMBER,
                              p_organization_id IN NUMBER);

END CSM_SYSTEM_ITEM_EVENT_PKG; -- Package spec


/
