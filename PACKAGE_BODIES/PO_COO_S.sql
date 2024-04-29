--------------------------------------------------------
--  DDL for Package Body PO_COO_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COO_S" AS
/* $Header: POXRCOOB.pls 120.0.12000000.3 2007/09/28 10:56:23 vrecharl ship $*/

PROCEDURE get_default_country_of_origin(
	x_item_id		IN	NUMBER,
	x_ship_to_org_id	IN 	NUMBER,
	x_vendor_id		IN 	NUMBER,
	x_vendor_site_id 	IN 	NUMBER,
	x_country_of_origin	IN OUT	NOCOPY VARCHAR2) IS

  CURSOR C is
   SELECT   paa.country_of_origin_code
    	  FROM     po_approved_supplier_lis_val_v pasl,
		   po_asl_attributes paa
    	  WHERE    pasl.item_id = x_item_id
    	  AND	   pasl.vendor_id = x_vendor_id
    	  AND	   nvl(pasl.vendor_site_id, -1) = nvl(x_vendor_site_id, -1)
    	  AND	   pasl.using_organization_id IN (-1, x_ship_to_org_id)
	  AND	   paa.asl_id = pasl.asl_id
	  ORDER BY paa.using_organization_id DESC;

BEGIN

  if x_item_id is not null then
     begin

       open c;
       fetch c into x_country_of_origin;
       close c;

     end;

     if x_country_of_origin is null then
        begin
  	   select country_of_origin_code
	   into x_country_of_origin
	   from po_vendor_sites_all
	   where vendor_id = x_vendor_id
	   and   vendor_site_id = x_vendor_site_id
	   and   rownum = 1;

	   EXCEPTION
              WHEN NO_DATA_FOUND THEN x_country_of_origin := NULL;
              WHEN OTHERS THEN raise;
	end;
     end if;
  -- bug#5917646 added this elsif condition to default country of origin for one-time item
  -- based on vendor and vendor site.
  -- bug#5917646 <statrt>
  elsif x_item_id is null then
      begin
  	   select country_of_origin_code
	   into x_country_of_origin
	   from po_vendor_sites_all
	   where vendor_id = x_vendor_id
	   and   vendor_site_id = x_vendor_site_id
	   and   rownum = 1;

	   EXCEPTION
              WHEN NO_DATA_FOUND THEN x_country_of_origin := NULL;
              WHEN OTHERS THEN raise;
	  end;
  -- bug#5917646 <end>
  end if; --x_item_id not null

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	x_country_of_origin := NULL;
     WHEN OTHERS THEN
     RAISE;

end;

END PO_COO_S;

/
