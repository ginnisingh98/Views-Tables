--------------------------------------------------------
--  DDL for Package PO_FV_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_FV_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVFVIS.pls 115.0 2004/08/14 00:34:14 axian noship $ */

-- Vendor site registration exists and is Active
-- Other possible values include: 'D'(Deleted), 'E'(Expired), 'N'(Unknown)
-- and 'U'(Unregistered)
G_SITE_REG_ACTIVE CONSTANT VARCHAR2(1) := 'A';
-- Vendor site registration does not exist, which means the vendor
-- is exempt from CCR
G_SITE_NOT_CCR_SITE CONSTANT NUMBER := 2;

FUNCTION val_vendor_site_ccr_regis(
  p_vendor_id       	IN NUMBER,
  p_vendor_site_id  	IN NUMBER
)RETURN BOOLEAN;
END PO_FV_INTEGRATION_PVT;

 

/
