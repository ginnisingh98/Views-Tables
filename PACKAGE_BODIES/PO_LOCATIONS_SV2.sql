--------------------------------------------------------
--  DDL for Package Body PO_LOCATIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LOCATIONS_SV2" as
/* $Header: POXCOL1B.pls 120.2.12010000.2 2009/05/04 06:25:43 rohbansa ship $*/

/*=============================  PO_LOCATIONS_SV2 ===========================*/

/*===========================================================================

  FUNCTION NAME:	val_location()

===========================================================================*/
function val_location(x_location_id        in number,
		      x_destination_org_id in number,
		      x_ship_to       	   in varchar2,
		      x_receiving	   in varchar2,
		      x_val_internal	   in varchar2,
                      x_source_org_id      in number default null )
return boolean is

  x_progress       varchar2(3) := NULL;
  x_location_count number      := 0;

begin

  x_progress := '010';

  -- Bug 5028505, Added validation to check if customer location
  -- association exist in the source Organization Operating Unit
 if ( x_source_org_id      is not null) then
  SELECT count(1)
  INTO   x_location_count
  FROM   hr_locations_all hl
  WHERE  hl.location_id = x_location_id
  AND    sysdate < nvl(hl.inactive_date, sysdate + 1)
  AND    nvl(hl.ship_to_site_flag, 'N') = decode(x_ship_to, 'Y', x_ship_to,
					         nvl(hl.ship_to_site_flag, 'N'))
  AND	 nvl(hl.receiving_site_flag, 'N') = decode(x_receiving, 'Y', x_receiving,
						   nvl(hl.receiving_site_flag, 'N'))
  AND    nvl(hl.inventory_organization_id, x_destination_org_id) =
					   x_destination_org_id
  AND    (nvl(x_val_internal, 'N') = 'N'
          OR
          x_location_id in
  	  (SELECT pla.location_id
   	   FROM   po_location_associations_all pla,
                  org_organization_definitions org       -- Bug 5028505
	   WHERE  pla.location_id = x_location_id
           AND    org.organization_id= x_source_org_id   -- Bug 5028505
           AND    org.operating_unit = pla.org_id ));     -- Bug 5028505
else
 SELECT count(1)
 	   INTO   x_location_count
 	   FROM   hr_locations_all hl
 	   WHERE  hl.location_id = x_location_id
 	   AND    sysdate < nvl(hl.inactive_date, sysdate + 1)
 	   AND    nvl(hl.ship_to_site_flag, 'N') = decode(x_ship_to, 'Y', x_ship_to,
 	                                                  nvl(hl.ship_to_site_flag, 'N'))
 	   AND    nvl(hl.receiving_site_flag, 'N') = decode(x_receiving, 'Y', x_receiving,
 	                                                    nvl(hl.receiving_site_flag, 'N'))
 	   AND    nvl(hl.inventory_organization_id, x_destination_org_id) =
 	                                            x_destination_org_id
 	   AND    (nvl(x_val_internal, 'N') = 'N'
 	           OR
 	           x_location_id in
 	           (SELECT pla.location_id
 	            FROM   po_location_associations pla
 	            WHERE  pla.location_id = x_location_id));

 end if;

  x_progress := '020';
  -- bug 1942696 hr_location changes to reflect the new view
  if (x_location_count = 0) then
    SELECT count(1)
    INTO   x_location_count
    FROM   hz_locations hz
    WHERE  hz.location_id = x_location_id
    AND    sysdate < nvl(hz.address_expiration_date, sysdate + 1);
  end if;

  x_progress := '030';
  if (x_location_count = 1) then
    return (TRUE);
  else
    return (FALSE);
  end if;

exception

  when others then
    po_message_s.sql_error('val_location', x_progress, sqlcode);
    raise;

end val_location;

END PO_LOCATIONS_SV2;

/
