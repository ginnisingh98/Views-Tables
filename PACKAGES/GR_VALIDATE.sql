--------------------------------------------------------
--  DDL for Package GR_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: GRVALIDS.pls 120.0 2005/06/24 11:07:49 mgrosser noship $ */

G_TRUE BOOLEAN  := TRUE;
G_FALSE BOOLEAN := FALSE;

-- M. Grosser 23-May-2005  Modified code for Inventory Convergence.
-- Added IN parameter p_organization_id and OUT parameter x_inventory_item_id
--
--Validate the Regulatory item.
FUNCTION validate_item
(      p_organization_id             IN          NUMBER,
       p_item                        IN          VARCHAR2,
       x_inventory_item_id           OUT NOCOPY  NUMBER

) RETURN BOOLEAN;

-- M. Grosser 23-May-2005  Modified code for Inventory Convergence.
-- Added IN parameter p_organization_id and OUT parameter x_inventory_item_id
--
--Validate the CAS Number and Item relation.
FUNCTION validate_cas_number
(       p_organization_id            IN          NUMBER,
        p_cas_number                 IN          VARCHAR2,
        x_item                       OUT NOCOPY  VARCHAR2,
        x_inventory_item_id          OUT NOCOPY  NUMBER
) RETURN BOOLEAN;

--Validate the document code.
FUNCTION validate_document_code
(       p_document_code                 IN          VARCHAR2
) RETURN BOOLEAN;

--Validate the disclosure code.
FUNCTION validate_disclosure_code
(       p_disclosure_code                IN          VARCHAR2
) RETURN BOOLEAN;

--Validate the dispatch method.
FUNCTION validate_dispatch_method_code
(       p_dispatch_method_code          IN          VARCHAR2
) RETURN BOOLEAN;

--Validate the recipient id.
FUNCTION validate_recipient_id
(       p_recipient_id	           	IN 	NUMBER
) RETURN BOOLEAN;

--Validate the recipient site id.
FUNCTION validate_recipient_site_id
(       p_recipient_id	           	IN 	NUMBER,
        p_recipient_site_id	        IN 	NUMBER
) RETURN BOOLEAN;

END GR_VALIDATE;

 

/
