--------------------------------------------------------
--  DDL for Package Body PO_SOURCING_SV4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SOURCING_SV4" as
/* $Header: POXSCS4B.pls 120.1 2006/02/14 12:28:41 dreddy noship $ */

/*=============================  PO_SOURCING_SV4  ===========================*/

/*===========================================================================

  FUNCTION NAME:	get_disposition_message()

===========================================================================*/
function get_disposition_message(x_item_id        in     number,
				 x_org_id         in     number,
				 x_cross_ref_type in     varchar2,
				 x_message	  in out NOCOPY varchar2,
				 x_multiple_flag  in out NOCOPY varchar2) return boolean is

  x_progress varchar2(3) := NULL;

begin

  /* Select all cross references having the cross reference type
  ** identified in the PO: Item Cross Reference Type profile
  ** option (this is passed in to get_disposition_message as
  ** an argument.)  This SELECCT will look for messages either having an
  ** exact match with the specified organizaiton, or messages that
  ** are applicable to all organizations.  If > 1 message is
  ** selected, the when TOO_MANY_ROWS exception handler will
  ** set the x_multiple_flag to 'Y' and return TRUE.
  */

  x_progress := '010';

  SELECT mcr.cross_reference
  INTO   x_message
  FROM   mtl_cross_references mcr
  WHERE  mcr.inventory_item_id = x_item_id
  AND    mcr.cross_reference_type = x_cross_ref_type
  AND    (mcr.organization_id = x_org_id
         OR
	 mcr.org_independent_flag = 'Y');

  return (TRUE);

exception

  when no_data_found then
    return (FALSE);

  when too_many_rows then
    x_multiple_flag := 'Y';
    return (TRUE);

  when others then
    po_message_s.sql_error('get_disposition_message', x_progress, sqlcode);
    raise;

end get_disposition_message;

/*===========================================================================

  FUNCTION NAME:	val_src_dest()

===========================================================================*/
FUNCTION val_src_dest(x_val_level                in     varchar2,
		      x_sob_id		         in     number,
		      x_item_id		         in     number,
		      x_item_revision	         in     varchar2,
		      x_ship_to			 in     varchar2,
		      x_receiving		 in 	varchar2,
		      x_source_type	         in out NOCOPY varchar2,
		      x_destination_type	 in out NOCOPY varchar2,
		      x_destination_org_id       in out NOCOPY number,
		      x_destination_loc_id       in out NOCOPY number,
		      x_destination_subinventory in out NOCOPY varchar2,
		      x_source_org_id	         in out NOCOPY number,
		      x_source_subinventory      in out NOCOPY varchar2,
		      x_error_type		 in out NOCOPY varchar2) return boolean is

  x_progress        varchar2(3)  := NULL;
  x_val_internal    varchar2(1)  := NULL;
  x_validation_type varchar2(20) := NULL;
  x_sub_error_type  varchar2(50) := NULL;

  x_dest_sub_valid   BOOLEAN ;
  x_source_sub_valid BOOLEAN;

begin

  if (x_val_level = 'ORG') then

    x_progress := '010';

    if (po_orgs_sv2.val_dest_org(x_destination_org_id,
		                 x_item_id,
		                 x_item_revision,
		                 x_destination_type,
		                 x_sob_id,
		                 x_source_type) = FALSE) then

      x_destination_org_id := -1;
      return (FALSE);

    x_progress := '020';

    elsif ((x_source_type = 'INVENTORY') and
           (po_orgs_sv2.val_source_org(x_source_org_id,
			               x_destination_org_id,
			               x_destination_type,
			               x_item_id,
			               x_item_revision,
			               x_sob_id,
		 	               x_error_type) = FALSE)) then
--bug#3464868 if the item is not internally orderable when both
--the source organization and destination orgnaization are the same
--the error type is 'PO_RI_INT_ORD_NOT_ENABLED. In this case
--we assign -2 to the source_org_id so that an appropriate error may
--be displayed
       if (x_error_type = 'PO_RI_INT_ORD_NOT_ENABLED') then
           x_source_org_id := -2;
       else
           x_source_org_id := -1;
       end if;
--bug#3464868
       return (FALSE);

    end if;
  end if;


  if ((x_val_level = 'ORG') or
      (x_val_level = 'LOC')) then

    if (x_destination_loc_id is not null) then

      x_progress := '030';

      if (x_source_type = 'INVENTORY') then
        x_val_internal := 'Y';
      end if;

      -- Bug 5028505: Added source Org id param
      if (po_locations_sv2.val_location(x_destination_loc_id,
				        x_destination_org_id,
				        x_ship_to,
				        x_receiving,
				        x_val_internal,
                                        x_source_org_id ) = FALSE) then
        x_destination_loc_id := -1;
      end if;
    end if;
  end if;

  /* Even if the location validation fails, we want to proceed
  ** with the subinventory validation because they are independent.
  */

  if ((x_val_level = 'ORG') or
      (x_val_level = 'LOC') or
      (x_val_level = 'SUB')) then

    if (x_destination_subinventory is not null) then

      x_validation_type := 'DESTINATION';

      x_progress := '040';

      x_dest_sub_valid := po_subinventories_s2.val_subinventory(
                                      x_destination_subinventory,
			              x_destination_org_id,
				      x_source_type,
			              x_source_subinventory,
			              x_source_org_id,
			              trunc(sysdate),
			              x_item_id,
			              x_destination_type,
				      x_validation_type,
				      x_sub_error_type);
        IF x_dest_sub_valid = FALSE THEN

           x_destination_subinventory := to_char(-1);
           return(FALSE);

        END IF;

      end if; -- chek on x_destination_subinventory

      x_progress := '050';

      if (x_source_type = 'INVENTORY') and
          (x_source_subinventory is not null) then

          x_validation_type := 'SOURCE';

	  x_source_sub_valid := po_subinventories_s2.val_subinventory(
                                         x_destination_subinventory,
				         x_destination_org_id,
					 x_source_type,
					 x_source_subinventory,
				   	 x_source_org_id,
					 trunc(sysdate),
					 x_item_id,
					 x_destination_type,
					 x_validation_type,
					 x_sub_error_type);
        IF x_source_sub_valid = FALSE THEN

           x_source_subinventory := to_char(-1);
           return(FALSE);
        END IF;

      end if; -- check x_source_type

  end if; -- check x_val_level

  if ((x_destination_loc_id = -1) or
      (x_destination_subinventory = '-1') or
      (x_source_subinventory = '-1')) then
    return (FALSE);
  else
    return (TRUE);
  end if;

exception

  when others then
    po_message_s.sql_error('val_src_dest', x_progress, sqlcode);
    raise;

end val_src_dest;

END PO_SOURCING_SV4;

/
