--------------------------------------------------------
--  DDL for Package CSL_MTL_SEC_INV_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_MTL_SEC_INV_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslmiacs.pls 115.5 2002/08/21 08:27:16 rrademak ship $ */

PROCEDURE Insert_MTL_Sec_Inventory(
                                    p_resource_id       NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id   NUMBER
		    );

PROCEDURE Update_MTL_Sec_Inventory(
                                    p_resource_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER
		    );

PROCEDURE Delete_MTL_Sec_Inventory(
                                    p_resource_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER
		    );

END CSL_MTL_SEC_INV_ACC_PKG;

 

/
