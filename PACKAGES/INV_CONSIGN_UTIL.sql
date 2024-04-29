--------------------------------------------------------
--  DDL for Package INV_CONSIGN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSIGN_UTIL" AUTHID CURRENT_USER AS
/* $Header: invpcons.pls 115.0 2003/09/26 14:54:34 nesoni noship $ */
-- Start of comments
--	API name 	: Get_Asl_Id
--	Type		: Public
--	Pre-reqs	: None.
--	Function	: This function retrieves asl_id based on item, organization, vendor, vendorsite. Local ASL is given preference to global ASL. This ASL is not disabled and ASL status should allow action.
--	Parameters	:
--	IN		:	p_item_id           	IN NUMBER	Required
--			 	p_vendor_id		      IN NUMBER 	Required
--			 	p_vendor_site_id		IN NUMBER 	Required
--			 	p_using_organization_id	IN NUMBER 	Required
-- End of comments
-- RETURN Parameters:
--   NUMBER

FUNCTION Get_Asl_Id (
		p_item_id		IN 	NUMBER,
		p_vendor_id		IN 	NUMBER,
	      p_vendor_site_id	IN	NUMBER,
		p_using_organization_id	IN      NUMBER
)
RETURN NUMBER;


END INV_CONSIGN_UTIL;


 

/
