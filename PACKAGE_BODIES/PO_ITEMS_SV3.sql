--------------------------------------------------------
--  DDL for Package Body PO_ITEMS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ITEMS_SV3" as
/* $Header: POXCOI3B.pls 115.5 2002/11/23 03:31:36 sbull ship $ */
/*=============================  PO_ITEMS_SV2  ===============================*/

/*===========================================================================

  PROCEDURE NAME:	get_taxable_flag

===========================================================================*/

PROCEDURE get_taxable_flag(x_item_id   			IN  	NUMBER,
		           x_item_org_id		IN  	NUMBER,
                           x_ship_to_org_id	  	IN  	NUMBER,
                           x_user_pref_taxable_flag     IN  	VARCHAR2,
                           x_ship_to_org_taxable_flag   IN OUT NOCOPY 	VARCHAR2,
                           x_item_org_taxable_flag     	IN OUT NOCOPY 	VARCHAR2,
                           x_po_default_taxable_flag	IN 	VARCHAR2,
                           x_return_taxable_flag        IN OUT NOCOPY 	VARCHAR2)
IS

x_progress  			VARCHAR2(3) := NULL;

BEGIN

   -- dbms_output.put_line ('Begin get_taxable_flag ');

   -- dbms_output.put_line ('Input user preference taxable_flag ' || x_user_pref_taxable_flag);
   -- dbms_output.put_line ('Input item organization_taxable_flag ' || x_item_org_taxable_flag);
   -- dbms_output.put_line ('Input ship_to organization_taxable_flag ' || x_ship_to_org_taxable_flag);
   -- dbms_output.put_line ('Input PO default taxable_flag ' || x_po_default_taxable_flag);

   -- Set the return taxable flag in the following priority
   --     1. User preference
   --     2. Ship_to organization
   --     3. Item organization
   --     4. PO default
   --

  IF x_user_pref_taxable_flag is NOT NULL THEN

      -- Always use the user preference if exists

      x_return_taxable_flag := x_user_pref_taxable_flag;

  ELSE
      -- Get item and ship_to organization taxable_flag from MTL_SYSTEM_ITEMS

      IF x_item_id is not NULL THEN

	 IF x_item_org_id is not NULL AND
	    x_item_org_taxable_flag is NULL THEN

	  BEGIN

	    -- Get item organization taxable_flag

	    x_progress := '010';
	    SELECT  msi.taxable_flag
	      INTO  x_item_org_taxable_flag
	      FROM  MTL_SYSTEM_ITEMS msi
	     WHERE  msi.inventory_item_id = x_item_id
	       AND  msi.organization_id = x_item_org_id;

	 -- dbms_output.put_line ('Get item organization_taxable_flag ' ||
	-- bug 1555260	  x_item_org_taxable_flag);

	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		 x_item_org_taxable_flag := NULL;

	    WHEN OTHERS THEN
		 -- dbms_output.put_line('In exception ');
		 po_message_s.sql_error('get_taxable_flag',
				 x_progress, sqlcode);
	     raise;
	  END;

	 END IF;

	 IF x_ship_to_org_id is not NULL AND
	    x_ship_to_org_taxable_flag is NULL THEN

	  BEGIN

	    -- Get ship_to organization taxable_flag

	    x_progress := '015';
	    SELECT  msi.taxable_flag
	      INTO  x_ship_to_org_taxable_flag
	      FROM  MTL_SYSTEM_ITEMS msi
	     WHERE  msi.inventory_item_id = x_item_id
	       AND  msi.organization_id = x_ship_to_org_id;

	   -- dbms_output.put_line ('Get ship_to organization_taxable_flag ' ||
--bug 1555260 		 x_ship_to_org_taxable_flag);


	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		 x_ship_to_org_taxable_flag := NULL;

	    WHEN OTHERS THEN
		 -- dbms_output.put_line('In exception ');
		 po_message_s.sql_error('get_taxable_flag',
				 x_progress, sqlcode);
	     raise;

	  END;

	 END IF;

      ELSE

         -- No item id is passed.
         -- Default item/ship_to organization taxable flag to NULL.

	 x_item_org_taxable_flag := NULL;
	 x_ship_to_org_taxable_flag := NULL;

     END IF;

     -- Decide the return_taxable_flag based on the following priority:
     --  1. Ship_to organization
     --  2. Item organization
     --  3. PO default

     IF    x_ship_to_org_taxable_flag is not NULL THEN
      	   x_return_taxable_flag := x_ship_to_org_taxable_flag;
     ELSIF x_item_org_taxable_flag is not NULL THEN
           x_return_taxable_flag := x_item_org_taxable_flag;
     ELSE
           x_return_taxable_flag := x_po_default_taxable_flag;
     END IF;

  END IF;

 -- dbms_output.put_line ('Return taxable_flag ' || x_return_taxable_flag);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
      x_return_taxable_flag := x_po_default_taxable_flag;

 WHEN OTHERS THEN
      -- dbms_output.put_line('In exception sqlcode ');
      po_message_s.sql_error('get_taxable_flag',
			      x_progress, sqlcode);
      raise;

END get_taxable_flag;



END PO_ITEMS_SV3;

/
