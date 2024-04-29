--------------------------------------------------------
--  DDL for Package CSL_CSP_SEC_INV_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CSP_SEC_INV_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslciacs.pls 120.0 2005/05/24 17:35:06 appldev noship $ */

FUNCTION Insert_CSP_Sec_Inventory
         (
           p_resource_id        IN  NUMBER,
           p_subinventory_code  IN  VARCHAR2,
           p_organization_id    IN  NUMBER
         )
RETURN BOOLEAN;

PROCEDURE Update_CSP_Sec_Inventory
         (
           p_resource_id        IN  NUMBER,
           p_subinventory_code  IN  VARCHAR2,
           p_organization_id    IN  NUMBER
         );

FUNCTION Delete_CSP_Sec_Inventory
         (
           p_resource_id        IN  NUMBER,
           p_subinventory_code  IN  VARCHAR2,
           p_organization_id    IN  NUMBER
         )
RETURN BOOLEAN;

END CSL_CSP_SEC_INV_ACC_PKG;

 

/
