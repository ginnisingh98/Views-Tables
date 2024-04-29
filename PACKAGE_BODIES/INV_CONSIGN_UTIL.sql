--------------------------------------------------------
--  DDL for Package Body INV_CONSIGN_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSIGN_UTIL" AS
/* $Header: invpconb.pls 115.0 2003/09/26 14:55:35 nesoni noship $ */
FUNCTION Get_Asl_Id (
		p_item_id		IN 	NUMBER,
		p_vendor_id		IN 	NUMBER,
	      p_vendor_site_id	IN	NUMBER,
		p_using_organization_id	IN      NUMBER
)
RETURN NUMBER
IS
l_asl_id                  NUMBER;
        CURSOR C is
    	  SELECT   pasl.asl_id
    	  FROM     po_approved_supplier_lis_val_v pasl,
		   po_asl_attributes paa,
                   po_asl_status_rules_v pasr
    	  WHERE    pasl.item_id = p_item_id
    	  AND	   pasl.vendor_id = p_vendor_id
    	  AND	   nvl(pasl.vendor_site_id, -1) = nvl(p_vendor_site_id, -1)
    	  AND	   pasl.using_organization_id IN (-1, p_using_organization_id)
	  AND	   pasl.asl_id = paa.asl_id
          AND      pasr.business_rule like '2_SOURCING'
          AND      pasr.allow_action_flag like 'Y'
          AND      pasr.status_id = pasl.asl_status_id
	  AND	   paa.using_organization_id =
			(SELECT  max(paa2.using_organization_id)
			 FROM	 po_asl_attributes paa2
			 WHERE   paa2.asl_id = pasl.asl_id
                         AND     paa2.using_organization_id IN (-1, p_using_organization_id))
	  ORDER BY pasl.using_organization_id DESC;
BEGIN
    OPEN C;
    FETCH C into l_asl_id;

    IF (C%NOTFOUND) THEN
         CLOSE C;
         RETURN NULL;
    END IF;
    CLOSE C;
    RETURN  l_asl_id;
END;


END INV_CONSIGN_UTIL;


/
