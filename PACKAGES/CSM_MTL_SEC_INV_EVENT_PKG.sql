--------------------------------------------------------
--  DDL for Package CSM_MTL_SEC_INV_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_MTL_SEC_INV_EVENT_PKG" 
/* $Header: csmemss.pls 120.1 2005/07/25 00:14:18 trajasek noship $*/
  AUTHID CURRENT_USER AS
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

PROCEDURE insert_mtl_sec_inventory( p_user_id       NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id   NUMBER);

PROCEDURE update_mtl_Sec_inventory( p_user_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER);

PROCEDURE delete_mtl_sec_inventory( p_user_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER);

-- concurrent program only to post updates to existing acc records
PROCEDURE refresh_acc(p_status OUT NOCOPY VARCHAR2,
                      p_message OUT NOCOPY VARCHAR2);

END CSM_MTL_SEC_INV_EVENT_PKG; -- Package spec

 

/
