--------------------------------------------------------
--  DDL for Package Body PO_CUSTOMERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CUSTOMERS_SV" as
/* $Header: POXRQCUB.pls 120.1.12010000.3 2011/08/01 12:13:22 uchennam ship $ */
/*==========================  po_customers_sv  ============================*/
/*===========================================================================

  PROCEDURE NAME:	get_cust_details

===========================================================================*/

PROCEDURE get_cust_details(x_deliver_to_location_id	IN    	NUMBER,
			   x_customer_id		IN OUT	NOCOPY NUMBER,
			   x_address_id			IN OUT	NOCOPY NUMBER,
			   x_site_use_id		IN OUT NOCOPY  NUMBER,
                           x_source_org_id              IN NUMBER DEFAULT NULL) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';
   if (x_source_org_id   is not null ) then
   SELECT pola.customer_id,
	  pola.address_id,
	  pola.site_use_id
   INTO   x_customer_id,
	  x_address_id,
	  x_site_use_id
   FROM   po_location_associations_all pola,
          org_organization_definitions org
   WHERE  pola.location_id = x_deliver_to_location_id
   AND    org.organization_id= x_source_org_id  -- bug 5028505
   AND    org.operating_unit= pola.org_id;      -- bug 5028505

else
SELECT pola.customer_id,
 	           pola.address_id,
 	           pola.site_use_id
 	    INTO   x_customer_id,
 	           x_address_id,
 	           x_site_use_id
 	    FROM   po_location_associations pola
 	    WHERE  pola.location_id = x_deliver_to_location_id;
end if;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_customer_id := null;
      x_address_id  := null;
      x_site_use_id := null;
  --Bug 12801184 Added below exception
   WHEN TOO_MANY_ROWS THEN
      x_customer_id := null;
      x_address_id  := null;
      x_site_use_id := null;
   WHEN OTHERS THEN
      po_message_s.sql_error('get_cust_details', x_progress, sqlcode);
   RAISE;

END get_cust_details;

END po_customers_sv;

/
