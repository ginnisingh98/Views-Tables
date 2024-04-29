--------------------------------------------------------
--  DDL for Package Body PO_SUBINVENTORIES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SUBINVENTORIES_S" AS
/* $Header: POXCOS1B.pls 115.9 2002/11/25 23:38:39 sbull ship $*/

/* create client package body */
/*
PACKAGE BODY PO_SUBINVENTORIES_S IS
*/

/*===========================================================================

  FUNCTION NAME:	val_subinventory(...)

===========================================================================*/

FUNCTION val_subinventory
(
	x_subinventory   	IN VARCHAR2,
	x_organization_id	IN NUMBER,
	x_transaction_date	IN DATE,
	x_item_id		IN NUMBER,
	x_destination_type	IN VARCHAR2
)
RETURN	NUMBER IS
-- 0 for success, non 0 for failure

x_progress     VARCHAR2(3)  := '';
x_status       VARCHAR2(20) := '';
x_restrict_sub NUMBER      := 0;

BEGIN
   x_progress := '000';
/* Commented DBMS_OUTPUT.PUT_LINE for bug 1555260 */
   -- dbms_output.put_line ('val_subinventory : x_subinventory     : ' ||
   --   x_subinventory);
   -- dbms_output.put_line ('val_subinventory : x_organization_id  : ' ||
   --   TO_CHAR(x_organization_id));
   -- dbms_output.put_line ('val_subinventory : x_transaction_date : ' ||
   --   TO_CHAR(x_transaction_date));
   -- dbms_output.put_line ('val_subinventory : x_item_id          : ' ||
   --   TO_CHAR(x_item_id));
  -- dbms_output.put_line ('val_subinventory : x_destination_type : ' ||
  --    x_destination_type);

   /* no subinventory required, this function really should not be called.
   ** just one simple check anyway.
   */
   IF x_destination_type <> 'INVENTORY' THEN
      RETURN 3;
   END IF;

   /* destination type is inventory, but not subinventories is given. */
   IF x_subinventory IS NULL THEN
      RETURN 3;
   END IF;

   /* check sub's inactive date */
   BEGIN

   x_progress := '010';
   SELECT 'sub_valid'
   INTO   x_status
   FROM   MTL_SECONDARY_INVENTORIES
   WHERE  SECONDARY_INVENTORY_NAME = x_subinventory
   AND    ORGANIZATION_ID          = x_organization_id
   AND    NVL(DISABLE_DATE, x_transaction_date+1) > x_transaction_date;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN x_status := 'bad_sub';
   WHEN OTHERS THEN
     po_message_s.sql_error('val_subinventory', x_progress, sqlcode);
     RAISE;
   END;


   -- dbms_output.put_line ('val_subinventory : x_status           : ' ||
   --   x_status);

   IF x_status <> 'sub_valid' THEN
      RETURN 3;
   END IF;

   /* varify if the given item has restricted sub control */
   x_progress := '020';
   SELECT RESTRICT_SUBINVENTORIES_CODE
   INTO   x_restrict_sub
   FROM   MTL_SYSTEM_ITEMS
   WHERE  INVENTORY_ITEM_ID = x_item_id
   AND    ORGANIZATION_ID   = x_organization_id;

   -- dbms_output.put_line ('val_subinventory : x_restrict_sub     : ' ||
   --   x_restrict_sub);

   /* check mfg_lookups for lookup_type = 'RESTRICT_SUBINVENTORIES_CODE' */

   /* check the given sub is in the restricted list. */
   IF x_restrict_sub = 1 THEN
      x_progress := '030';

      BEGIN

      SELECT 'sub_ok'
      INTO   x_status
      FROM   MTL_ITEM_SUB_INVENTORIES
      WHERE  INVENTORY_ITEM_ID   = x_item_id
      AND    SECONDARY_INVENTORY = x_subinventory
      AND    ORGANIZATION_ID     = x_organization_id;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN x_status := 'bad_sub';
      WHEN OTHERS THEN
        po_message_s.sql_error('val_subinventory', x_progress, sqlcode);
	RAISE;
      END;

      IF x_status <> 'sub_ok' THEN
         RETURN 3;
      END IF;

   END IF;

   RETURN 0;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_subinventory', x_progress, sqlcode);
   RAISE;
END val_subinventory;

/*===========================================================================

  FUNCTION NAME:	val_locator(...)

===========================================================================*/

FUNCTION val_locator
(
	x_locator		IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory     	IN VARCHAR2,
	x_organization_id	IN NUMBER
)
RETURN	NUMBER IS

x_progress        VARCHAR2(3)  := NULL;
x_status          VARCHAR2(20) := NULL;
x_locator_control NUMBER      := 0;
x_restrict_loc    NUMBER      := 0;

BEGIN
   x_progress := '000';

   po_subinventories_s.get_locator_control (
      x_organization_id,
      x_subinventory,
      x_item_id,
      x_locator_control
   );

   /* if no locator control, simply return ok */
   IF x_locator_control = 1 THEN /* No locator control */
      RETURN 0;
   END IF;

   /* if use prespecified locators */
   IF x_locator_control = 2 THEN
      x_progress := '010';
      SELECT 'pre_loc_ok'
      INTO   x_status
      FROM   MTL_ITEM_LOCATIONS
      WHERE  INVENTORY_LOCATION_ID = x_locator
      AND    ORGANIZATION_ID = x_organization_id
      AND    NVL(DISABLE_DATE, SYSDATE+1) > SYSDATE;

      IF x_status <> 'pre_loc_ok' THEN
         RETURN 2;
      END IF;

      /* varify if the given item has restricted loc control */
      x_progress := '020';
      SELECT RESTRICT_LOCATORS_CODE
      INTO   x_restrict_loc
      FROM   MTL_SYSTEM_ITEMS
      WHERE  INVENTORY_ITEM_ID = x_item_id
      AND    ORGANIZATION_ID   = x_organization_id;
      /* check mfg_lookups for lookup_type = 'RESTRICT_LOCATORS_CODE' */

      /* if an item under restricted loc control, locator must be defined
      ** in mtl_secondary_locators.
      */
      IF x_restrict_loc = 1 THEN
         x_progress := '030';
         SELECT 'restrict_ok'
         INTO   x_status
         FROM   MTL_SECONDARY_LOCATORS
         WHERE  INVENTORY_ITEM_ID = x_item_id
         AND    ORGANIZATION_ID   = x_organization_id
         AND    SECONDARY_LOCATOR = x_locator;

         IF x_status <> 'restrict_ok' THEN
            RETURN 2;
         END IF;
      END IF;

      RETURN 0;
   END IF;

   /* Dynamic locator entry allowed */
   IF x_locator_control = 3 THEN
      RETURN 100; /* inv_locator.add_locator(x_locator); */
   END IF;

   RETURN 1;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_locator', x_progress, sqlcode);
   RAISE;
END val_locator;

/*===========================================================================

  PROCEDURE NAME:	get_locator_control(...)

                1 - No locator control
                2 - Prespecified locator control
                3 - Dynamic entry locator control
                4 - Locator control determined at subinventory level
                5 - Locator control determined at item level
  check mfg_lookups table with lookup_type = 'MTL_ITEM_LOCATOR_CONTROL' and
  'MTL_LOCATION_CONTROL'.

===========================================================================*/

PROCEDURE get_locator_control
(
	x_organization_id	IN NUMBER,
	x_subinventory    	IN VARCHAR2,
	x_item_id		IN NUMBER,
	x_locator		IN OUT NOCOPY NUMBER,
	x_restrict_locator	IN OUT NOCOPY NUMBER
) IS

x_progress VARCHAR2(3) := NULL;
x_status          VARCHAR2(20) := NULL;
x_locator_control NUMBER := 0;

BEGIN

   -- dbms_output.put_line ('get_locator_control : x_organization_id : ' ||
   --   to_char(x_organization_id));
   -- dbms_output.put_line ('get_locator_control : x_subinventory    : ' ||
   --   x_subinventory);
   -- dbms_output.put_line ('get_locator_control : x_item_id         : ' ||
   --   to_char(x_item_id));

   -- bug 520036
   -- This procedure with x_restrict_locator is not being called by
   -- any client/server procedures.

   x_progress := '000';
   /*
   ** Check inventory installation status... may use an inventory api func
   ** instead of selecing directly from inventory tables.
   */
   /* always check item restrict locator control */
   --SELECT restrict_locators_code, location_control_code
   --INTO   x_restrict_locator, x_item_locator_control
   --FROM   mtl_system_items
   --WHERE  organization_id   = x_organization_id
   --AND    inventory_item_id = x_item_id;

   /* if an item under restrict locator control, set control = 2 */
   --IF x_restrict_locator = 1 THEN
   --   x_locator := 2;
   --
   --   -- dbms_output.put_line ('get_locator_control : x_locator         : ' ||
   --      to_char(x_locator));
   --
   --   RETURN;
   --END IF;
   --

   /* check organization level locator control */
   SELECT stock_locator_control_code
   INTO   x_locator
   FROM   mtl_parameters
   WHERE  organization_id = x_organization_id;

   IF x_locator = 4 THEN

      x_progress := '010';
      SELECT locator_type
      INTO   x_locator
      FROM   mtl_secondary_inventories
      WHERE  organization_id          = x_organization_id
      AND    secondary_inventory_name = x_subinventory;

      /* debug- what if x_locator <>5, set error some how. talk to vasant */
   END IF;

   /*
   ** bug 724495, get the restrict_locators_code
   ** from mtl_system_items as well
   */

   IF x_locator = 5 THEN
      x_progress := '020';
      SELECT restrict_locators_code, location_control_code
      INTO   x_restrict_locator, x_locator
      FROM   mtl_system_items
      WHERE  organization_id   = x_organization_id
      AND    inventory_item_id = x_item_id;
   END IF;

   /* debug- set error some how. talk to vasant */
   -- dbms_output.put_line ('get_locator_control : x_locator         : ' ||
   --   to_char(x_locator));

   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_locator_control', x_progress, sqlcode);
   RAISE;

   RETURN;
END get_locator_control;

PROCEDURE get_locator_control
(
	x_organization_id	IN NUMBER,
	x_subinventory    	IN VARCHAR2,
	x_item_id		IN NUMBER,
	x_locator		IN OUT NOCOPY NUMBER
) IS

x_progress VARCHAR2(3) := NULL;
x_status          VARCHAR2(20) := NULL;
x_locator_control NUMBER      := 0;
x_restrict_loc    NUMBER      := 0;

BEGIN

   -- dbms_output.put_line ('get_locator_control : x_organization_id : ' ||
   --   to_char(x_organization_id));
   -- dbms_output.put_line ('get_locator_control : x_subinventory    : ' ||
   --   x_subinventory);
   -- dbms_output.put_line ('get_locator_control : x_item_id         : ' ||
   --   to_char(x_item_id));

   x_progress := '000';
   /*
   ** Check inventory installation status... may use an inventory api func
   ** instead of selecing directly from inventory tables.
   */

   -- bug 520036
   -- Default locator control from organization, subinventory and item level

   /* check organization level locator control */
   SELECT stock_locator_control_code
   INTO   x_locator
   FROM   mtl_parameters
   WHERE  organization_id = x_organization_id;

   IF x_locator = 4 THEN

      x_progress := '010';
      SELECT locator_type
      INTO   x_locator
      FROM   mtl_secondary_inventories
      WHERE  organization_id          = x_organization_id
      AND    secondary_inventory_name = x_subinventory;

      /* debug- what if x_locator <>5, set error some how. talk to vasant */
   END IF;

   IF x_locator = 5 THEN
      x_progress := '020';
      SELECT location_control_code
      INTO   x_locator
      FROM   mtl_system_items
      WHERE  organization_id   = x_organization_id
      AND    inventory_item_id = x_item_id;
   END IF;

   /* debug- set error some how. talk to vasant */
   -- dbms_output.put_line ('get_locator_control : x_locator         : ' ||
   --   to_char(x_locator));

   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_locator_control', x_progress, sqlcode);
   RAISE;

   RETURN;
END get_locator_control;

/*===========================================================================

  FUNCTION NAME:	get_default_subinventory

===========================================================================*/

PROCEDURE get_default_subinventory
(
	x_organization_id	IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory   	IN OUT NOCOPY VARCHAR2
) IS

X_progress VARCHAR2(3)    := '000';

BEGIN


  /* Bug 2519790 :  Copy initial x_subinventory into a local variable
     so that same value could be returned on exception. We should call
     the SELECT statement only when x_subinventory is NULL.
     The local variables are superfluous after adding the IF condition.
     Removed the local variables introduced as part of earlier fix as
     it is not required.
  */

   X_progress := '010';

  IF (x_subinventory is NULL ) THEN

    X_progress := '020';

    SELECT  mis.subinventory_code
    INTO    x_subinventory
    FROM    mtl_item_sub_defaults mis,
            mtl_secondary_inventories msi
    WHERE   mis.inventory_item_id = x_item_id
    AND     mis.organization_id = x_organization_id
    AND     mis.default_type = 2
    AND     mis.organization_id = msi.organization_id
    AND     mis.subinventory_code = msi.secondary_inventory_name
    AND     trunc(NVL(msi.disable_date, trunc(sysdate+1))) > trunc(sysdate);

  END IF ;

   RETURN;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        X_subinventory := NULL;
      RETURN;
   WHEN OTHERS THEN
      po_message_s.sql_error('get_default_subinventory', x_progress, sqlcode);
   RAISE;

END get_default_subinventory;

/*===========================================================================

  PROCEDURE NAME:	get_default_locator

===========================================================================*/

PROCEDURE get_default_locator
(
	x_organization_id	IN NUMBER,
	x_item_id		IN NUMBER,
	x_subinventory   	IN VARCHAR2,
        x_locator_id            IN OUT NOCOPY NUMBER
) IS

X_progress VARCHAR2(3)    := '000';

BEGIN

   X_progress := '010';
   SELECT mld.locator_id
   INTO   X_locator_id
   FROM   mtl_item_loc_defaults mld,
          mtl_item_locations mil
   WHERE  mld.inventory_item_id = X_item_id
   AND    mld.organization_id = X_organization_id
   AND    mld.subinventory_code = X_subinventory
   AND    mld.default_type = 2
   AND    mld.organization_id = mil.organization_id
   AND    mld.locator_id = mil.inventory_location_id
   AND    trunc(NVL(mil.disable_date, trunc(sysdate+1))) > trunc(sysdate);

   RETURN;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      X_locator_id := NULL;
      RETURN;
   WHEN OTHERS THEN
      po_message_s.sql_error('get_default_locator', x_progress, sqlcode);
      RAISE;

END get_default_locator;

/*===========================================================================

  PROCEDURE NAME:	check_sub_transfer()

===========================================================================*/

PROCEDURE check_sub_transfer (x_source_organization_id	     IN  NUMBER,
			      x_destination_organization_id  IN  NUMBER,
			      x_destination_subinventory     IN  NUMBER,
			      x_item_id			     IN  NUMBER,
			      x_allow_expense_source	     OUT NOCOPY VARCHAR2
			     ) IS

x_asset_flag      mtl_system_items.inventory_asset_flag%type;
x_intransit_type  mtl_interorg_parameters.intransit_type%type;
x_dest_sub_name   mtl_item_sub_defaults.subinventory_code%type;
x_sub_type 	  mtl_secondary_inventories.asset_inventory%type;
x_progress    VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';


  /* get the asset flag for the item in the destination org */

     SELECT inventory_asset_flag
     INTO   x_asset_flag
     FROM   mtl_system_items
     WHERE  organization_id    = x_destination_organization_id
     AND    inventory_item_id  = x_item_id;

   -- dbms_output.put_line('Asset flag = ' || x_asset_flag);


  /* If the  item is NOT an asset item, set allow_expense_source
  ** to 'Y' and return , else continue.
  */

   IF (x_asset_flag = 'N') THEN
     x_allow_expense_source := 'Y';
     return;

   END IF;

   /* At this point the asset_flag is either null or 'Y'. Get
   ** the in_transit type for the organizations involved in
   ** the transfer if they are different.
   */

    x_progress := '020';

     SELECT intransit_type
     INTO   x_intransit_type
     FROM   mtl_interorg_parameters
     WHERE  from_organization_id = x_source_organization_id
     AND    to_organization_id   = x_destination_organization_id
     AND    x_source_organization_id <> x_destination_organization_id;

   -- dbms_output.put_line('Intransit Type = ' || x_intransit_type);


   /* If in_transit, set allow_expense_source to 'N' */

   IF (x_intransit_type = 2) THEN
     x_allow_expense_source := 'N';
     return;

   END IF;


   /* Get the default destination subinventory  if not provided */

  IF (x_destination_subinventory is null) THEN

   x_progress := '030';

     SELECT subinventory_code
     INTO   x_dest_sub_name
     FROM   mtl_item_sub_defaults
     WHERE  inventory_item_id = x_item_id
     AND    organization_id   = x_destination_organization_id
     AND    default_type = 2;

   -- dbms_output.put_line('Default Dest Subinventory = ' || x_dest_sub_name);

  ELSE
     x_dest_sub_name := x_destination_subinventory;

  END IF;

  /* Get the subinventory type for the subinventory and
  ** and destination organization
  */

  x_progress := '040';

     SELECT asset_inventory
     INTO   x_sub_type
     FROM   mtl_secondary_inventories
     WHERE  organization_id = x_destination_organization_id
     AND    secondary_inventory_name = x_dest_sub_name;


   -- dbms_output.put_line('Asset Inventory = ' || x_sub_type);


  /* If the subinventory is an ASSET sub, set allow_expense_source
  ** to 'N' else set allow_expense_source to 'Y'
  */

  IF (x_sub_type = 1) THEN
    x_allow_expense_source := 'N';

  ELSE
    x_allow_expense_source := 'Y';

  END IF;



EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In exception');
    po_message_s.sql_error('po_subinventories_s.check_sub_transfer',
			    x_progress, sqlcode);
    raise;

END check_sub_transfer;


/*===========================================================================

  PROCEDURE NAME:	test_check_sub_transfer()

===========================================================================*/

PROCEDURE test_check_sub_transfer (x_source_organization_id  IN  NUMBER,
			      x_destination_organization_id  IN  NUMBER,
			      x_destination_subinventory     IN  NUMBER,
			      x_item_id			     IN  NUMBER) IS

x_allow_expense_source	     VARCHAR2(1);

BEGIN

  po_subinventories_s.check_sub_transfer (
				x_source_organization_id,
			        x_destination_organization_id,
			        x_destination_subinventory,
				x_item_id,
			        x_allow_expense_source);


-- dbms_output.put_line('Allow expense source = '|| x_allow_expense_source);

END test_check_sub_transfer;



/*===========================================================================

  FUNCTION NAME:	val_src_subinventory(...)

===========================================================================*/

FUNCTION val_src_subinventory (	x_src_sub	   	IN VARCHAR2,
				x_src_org_id		IN INTEGER,
				x_dest_type		IN VARCHAR2,
				x_dest_org_id		IN INTEGER,
				x_dest_sub		IN VARCHAR2,
				x_item_id		IN NUMBER
)
RETURN	BOOLEAN IS

x_progress     VARCHAR2(3)  := '';
x_count	       NUMBER	    := 0;
x_restrict_sub   mtl_system_items.restrict_subinventories_code%type;
x_intransit_type mtl_interorg_parameters.intransit_type%type;
x_allow_expense_source VARCHAR2(1) := '';

BEGIN


   /* Return false if there isn't a source
   ** organization specified. Note that this
   ** routine should not be called with a null
   ** source subinventory too. If the destination org
   ** is cleared then this routine  returns false.
   */

   IF ((x_src_org_id is null) OR
       (x_src_sub    is null) OR
       (x_item_id    is null) OR
       (x_dest_org_id is null)) THEN
     return (FALSE);

   END IF;


   x_progress := '010';


   /* Validate that the src sub is active
   ** for the source organization. Also validate
   ** that the value of  quantity tracked is 1.
   */

    SELECT count(1)
    INTO   x_count
    FROM   mtl_secondary_inventories  msub
    WHERE  msub.organization_id = x_src_org_id
    AND    msub.secondary_inventory_name = x_src_sub
    AND    trunc(sysdate) < nvl(disable_date, trunc(sysdate + 1))
    AND    msub.quantity_tracked = 1;

    IF (x_count = 0) THEN
      return (FALSE);

    END IF;


   /* Verify that the subinventory is not a restricted
   ** sub. If it is then verify that the item is valid
   ** for the subinventory.
   */

   x_progress := '020';

   SELECT msi.restrict_subinventories_code
   INTO   x_restrict_sub
   FROM   mtl_system_items msi
   WHERE  msi.inventory_item_id = x_item_id
   AND    organization_id   = x_src_org_id;


   IF x_restrict_sub = 1 THEN

      x_progress := '030';

      SELECT count(1)
      INTO   x_count
      FROM   mtl_item_sub_inventories mis
      WHERE  mis.inventory_item_id   = x_item_id
      AND    mis.secondary_inventory = x_src_sub
      AND    mis.organization_id     = x_src_org_id;

   END IF;

   IF (x_count = 0) THEN
      return (FALSE);

   END IF;

   /* Validate that we are not sourcing and delivering
   ** to the same subinventory. If we  are then display
   ** the message PO_RQ_SOURCE_SUB_EQS_DEST_SUB.
   */

   IF ((x_src_org_id = x_dest_org_id) AND
       (x_src_sub = x_dest_sub)) THEN
     po_message_s.app_error('PO_RQ_SOURCE_SUB_EQS_DEST_SUB');
     return (FALSE);

  END IF;


  /*
  ** Validate that if the intransit type is not 1 (not direct transfer)
  ** for the source and destination org combination
  ** then sourcing from an expense sub is not allowed.
  */

    x_progress := '040';

    SELECT mip.intransit_type
    INTO   x_intransit_type
    FROM   mtl_interorg_parameters mip
    WHERE  mip.from_organization_id = x_src_org_id
    AND    mip.to_organization_id  = x_dest_org_id;

   IF (x_intransit_type <> 1) THEN

     x_progress := '050';

     SELECT count(1)
     INTO   x_count
     FROM   mtl_secondary_inventories msi
     WHERE  msi.secondary_inventory_name = x_src_sub
     AND    msi.asset_inventory = 2;

    IF (x_count = 1) THEN
      return (FALSE);

    END IF;
  END IF;

  /* Do not allow transfer of an asset item
  ** from an expense subinventory to an asset
  ** subinventory for direct transfers.
  */

  x_progress := '060';

  po_subinventories_s.check_sub_transfer (
				x_src_org_id,
			        x_dest_org_id,
			        x_dest_sub,
				x_item_id,
			        x_allow_expense_source);

  IF (x_allow_expense_source <> 'Y') THEN

     x_progress := '070';

     SELECT count(1)
     INTO   x_count
     FROM   mtl_secondary_inventories msi
     WHERE  msi.secondary_inventory_name = x_src_sub
     AND    msi.asset_inventory = 2;

    IF (x_count = 1) THEN
      return (FALSE);

    END IF;
  END IF;

  return (TRUE);

   EXCEPTION
   when no_data_found then
    return (FALSE);
   when others then
      po_message_s.sql_error('val_src_subinventory', x_progress, sqlcode);
   raise;

END val_src_subinventory;




/*===========================================================================

 FUNCTION NAME:	val_locator_control

===========================================================================*/
FUNCTION val_locator_control(
X_to_organization_id     IN NUMBER,
X_item_id                IN NUMBER,
X_subinventory           IN VARCHAR2,
X_locator_id             IN NUMBER)
RETURN BOOLEAN IS

locator_control       INTEGER     := 0;
X_progress            VARCHAR2(4) := '000';

BEGIN

   /*
   ** See if org/sub/item is under locator control
   */
   X_progress := '1220';
   po_subinventories_s.get_locator_control
      (X_to_organization_id,
       X_subinventory,
       X_item_id,
       locator_control);

   /*
   ** If locator control is 2 which means it is under predefined
   ** locator contol or 3 which means it's under dynamic (any value)
   ** locator control then you need to go get the default locator id
   */
   IF (locator_control = 2 OR locator_control = 3) THEN

        IF (X_locator_id IS NULL) THEN
            RETURN FALSE;
        END IF;

   END IF; -- (locator_control = 2 OR locator_control = 3)

   RETURN TRUE;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_locator_control', X_progress, sqlcode);
   RAISE;

END val_locator_control;


/*===========================================================================

  PROCEDURE NAME:	get_subinventory_details

===========================================================================*/

PROCEDURE get_subinventory_details (x_subinventory	IN OUT NOCOPY  VARCHAR2,
				    x_organization_id	IN OUT NOCOPY  NUMBER,
				    x_asset_inventory	IN OUT NOCOPY  NUMBER
) IS

x_progress    VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

  /* get the asset inventory column for the subinventory */

     SELECT msi.asset_inventory
     INTO   x_asset_inventory
     FROM   mtl_secondary_inventories msi
     WHERE  msi.organization_id = x_organization_id
     AND    msi.secondary_inventory_name = x_subinventory;


   -- dbms_output.put_line('Asset Inventory = ' || x_asset_inventory);


EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In exception');
    po_message_s.sql_error('po_subinventories_s.get_subinventory_details',
			    x_progress, sqlcode);
    raise;

END get_subinventory_details;


END PO_SUBINVENTORIES_S;

/
