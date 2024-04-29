--------------------------------------------------------
--  DDL for Package Body PJM_UNIT_EFF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_UNIT_EFF" AS
/* $Header: PJMUEFFB.pls 120.1.12010000.2 2008/09/17 10:32:53 ybabulal ship $ */
--  ---------------------------------------------------------------------
--  Global Variables
--  ---------------------------------------------------------------------
G_Unit_Number   PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE;
G_Enabled       VARCHAR2(1)  := NULL;
G_Org_ID        NUMBER       := NULL;
G_Item_ID       NUMBER       := NULL;
G_Unit_Eff_Item VARCHAR2(1)  := NULL;
G_WIP_Entity_ID NUMBER       := NULL;
G_WIP_Org_ID    NUMBER       := NULL;
G_WIP_Unit_Num  PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE := NULL;
G_RCV_Txn_ID    NUMBER       := NULL;
G_RCV_Unit_Num  PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE := NULL;
G_RMA_Txn_ID    NUMBER       := NULL;
G_RMA_Unit_Num  PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE := NULL;
G_OE_Line_ID    NUMBER       := NULL;
G_OE_Unit_Num   PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE := NULL;

--  ---------------------------------------------------------------------
--  Private Functions / Procedures
--  ---------------------------------------------------------------------

--
--  Name          : Item_Serial_Control
--  Pre-reqs      : None
--  Function      : This function checks the serial control for
--                  the item
--
--
--  Parameters    :
--  IN            : X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--
--  OUT           : None
--
--  Returns       : Serial Number Control Code
--                  1 - No serial number control
--                  2 - Predefined serial numbers
--                  5 - Dynamic entry at inventory receipt
--                  6 - Dynamic entry at sales order issue
--
FUNCTION Item_Serial_Control
( X_item_id                        IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN NUMBER IS
   L_ser_control   NUMBER;
BEGIN

   if ( X_item_id is NULL ) then
      return ( NULL );
   end if;

   SELECT serial_number_control_code
   INTO   L_ser_control
   FROM   mtl_system_items
   WHERE  inventory_item_id = X_item_id
   AND    organization_id = X_organization_id;

   return ( L_ser_control );

EXCEPTION
WHEN NO_DATA_FOUND THEN
   RETURN ( NULL );
WHEN OTHERS THEN
   RETURN ( NULL );

END Item_Serial_Control;


--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

--
--  Name          : Enabled
--  Pre-reqs      : None
--  Function      : This function returns a Y/N indicator whether
--                  Model/Unit effectivity has been enabled or not
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : Y/N
--
FUNCTION Enabled
  RETURN VARCHAR2 IS

BEGIN

   --
   -- The result is cached into global variable to speed up repeated
   -- Initially the cache is NULL.  Once the cache is populated, the
   -- cached result will be used instead of hitting the DB again.
   --
   if ( G_Enabled IS NULL ) then
     --
     -- A Law 06/07/2002
     --
     -- Check is now based on whether PJM is implemented (existence
     -- of rows in pjm_org_parameters), not whether PJM is installed
     --
     if ( PJM_INSTALL.Check_Implementation_Status ) then
       G_Enabled := 'Y';
     else
       G_Enabled := 'N';
     end if;
   end if;
   RETURN ( G_Enabled );

END Enabled;


--
--  Name          : Allow_Cross_UnitNum_Issues
--  Pre-reqs      : None
--  Function      : This function returns a Y/N indicator whether
--                  Cross-Unit Number WIP Issues are allowed
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : Y/N
--
FUNCTION Allow_Cross_UnitNum_Issues
( X_organization_id                IN     NUMBER
) RETURN VARCHAR2 IS
   L_allowed  VARCHAR2(1);
   L_org_id   number;
BEGIN

   if ( X_organization_id is null ) then
      L_org_id := Fnd_Profile.Value_WNPS('MFG_ORGANIZATION_ID');
   else
      L_org_id := X_organization_id;
   end if;

   SELECT nvl(allow_cross_unitnum_issues,'N')
   INTO   L_allowed
   FROM   pjm_org_parameters
   WHERE  organization_id = L_org_id;

   if (L_allowed = 'Y') then
      RETURN( 'Y' );
   else
      RETURN( 'N' );
   end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   RETURN( 'N' );
WHEN OTHERS THEN
   RETURN( 'N' );

END Allow_Cross_UnitNum_Issues;


--
--  Name          : Unit_Effective_Item
--  Pre-reqs      : None
--  Function      : This function checks the effectivity control for
--                  the item
--
--
--  Parameters    :
--  IN            : X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--
--  OUT           : None
--
--  Returns       : Y/N
--
FUNCTION Unit_Effective_Item
( X_item_id                        IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN VARCHAR2 IS

l_item number; -- add for R12 EAM request, bug#4521664
BEGIN

   if ( X_item_id is NULL ) then
      return ( NULL );
   end if;

   --
   -- The input and output are all cached into global variables to
   -- speed up repeated lookups.  If the input parameters of the
   -- current lookup matches the input parameters of the previous
   -- lookup, the cached result will be used instead of hitting the DB
   -- again.
   --
   if (  G_Unit_Eff_Item IS NULL
      OR G_Item_ID <> X_Item_ID
      OR G_Org_ID  <> X_organization_ID ) then
      --
      -- No cache output or input parameters have changed; recache
      --
      G_Org_ID := X_Organization_ID;
      G_Item_ID := X_Item_ID;

/* bug 4521664 for EAM - Ignore Unit effectivity Attribute for Asset Group
       Items (eam_item_type = 2 in MSI table) */

      select nvl(eam_item_type, -2)
      into l_item
      from mtl_system_items_b
      where inventory_item_id =X_ITEM_ID
      and organization_id = X_organization_id;

      if l_item = 1 then
            G_Unit_Eff_Item := 'N'; --Always return N for Asset Group Item
      else
        /* end of change for EAM, process  all other type of items */
         SELECT decode(effectivity_control , 2 , 'Y' , 'N')
         INTO   G_Unit_Eff_Item
         FROM   mtl_system_items
         WHERE  inventory_item_id = X_item_id
         AND    organization_id = X_organization_id;
      end if;
   end if;

   RETURN ( G_Unit_Eff_Item );

EXCEPTION
WHEN NO_DATA_FOUND THEN
   G_Unit_Eff_Item := 'N';
   RETURN ( G_Unit_Eff_Item );
WHEN OTHERS THEN
   RETURN ( NULL );

END Unit_Effective_Item;


--
--  Name          : Set_Unit_Number
--  Pre-reqs      : None
--  Function      : This procedure sets the global variable
--                  G_Unit_Number
--
--
--  Parameters    :
--  IN            : X_Unit_Number                   NUMBER
--
--  Returns       : None
--
PROCEDURE Set_Unit_Number
( X_Unit_Number                    IN     VARCHAR2
) IS
BEGIN

   G_Unit_Number := X_Unit_Number;

END Set_Unit_Number;


--
--  Name          : Current_Unit_Number
--  Pre-reqs      : None
--  Function      : This procedure gets the value in global variable
--                  G_Unit_Number
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : VARCHAR2
--
FUNCTION Current_Unit_Number
  RETURN VARCHAR2 IS
BEGIN

   return ( G_Unit_Number );

END Current_Unit_Number;


--
--  Name          : Prev_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the previous unit number in
--                  ascending order for the same end item
--
--
--  Parameters    :
--  IN            : X_Unit_Number                   NUMBER
--
--  Returns       : VARCHAR2
--
FUNCTION Prev_Unit_Number
( X_Unit_Number                    IN     VARCHAR2
) RETURN VARCHAR2 IS
  L_unit_number     VARCHAR2(30) := NULL;

  CURSOR c IS
  SELECT N2.unit_number
  FROM   pjm_unit_numbers N1
  ,      pjm_unit_numbers N2
  WHERE  N1.unit_number = X_unit_number
  AND    N2.end_item_id = N1.end_item_id
  AND    N2.master_organization_id = N1.master_organization_id
  AND    N2.unit_number < N1.unit_number
  ORDER BY N2.unit_number desc;

BEGIN

  OPEN c;
  FETCH c INTO L_unit_number;
  RETURN ( L_unit_number );

EXCEPTION
WHEN OTHERS THEN
  RAISE;
END Prev_Unit_Number;


--
--  Name          : Next_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the next unit number in
--                  ascending order for the same end item
--
--
--  Parameters    :
--  IN            : X_Unit_Number                   NUMBER
--
--  Returns       : VARCHAR2
--
FUNCTION Next_Unit_Number
( X_Unit_Number                    IN     VARCHAR2
) RETURN VARCHAR2 IS
  L_unit_number     VARCHAR2(30) := NULL;

  CURSOR c IS
  SELECT N2.unit_number
  FROM   pjm_unit_numbers N1
  ,      pjm_unit_numbers N2
  WHERE  N1.unit_number = X_unit_number
  AND    N2.end_item_id = N1.end_item_id
  AND    N2.master_organization_id = N1.master_organization_id
  AND    N2.unit_number > N1.unit_number
  ORDER BY N2.unit_number asc;

BEGIN

  OPEN c;
  FETCH c INTO L_unit_number;
  RETURN ( L_unit_number );

EXCEPTION
WHEN OTHERS THEN
  RAISE;
END Next_Unit_Number;


--
--  Name          : WIP_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a discrete
--                  job or flow schedule
--
--
--  Parameters    :
--  IN            : X_wip_entity_id                 NUMBER
--                  X_organization_id               NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION WIP_Unit_Number
( X_wip_entity_id                  IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN VARCHAR2 IS

BEGIN

   SELECT DECODE(e.entity_type, 1, dj.end_item_unit_number,
                                4, fs.end_item_unit_number)
   INTO   G_WIP_Unit_Num
   FROM   wip_flow_schedules fs
   ,      wip_discrete_jobs dj
   ,      wip_entities e
   WHERE  e.wip_entity_id = X_wip_entity_id
   AND    e.organization_id = X_organization_id
   AND    fs.organization_id (+) = e.organization_id
   AND    fs.wip_entity_id (+) = e.wip_entity_id
   AND    dj.organization_id (+) = e.organization_id
   AND    dj.wip_entity_id (+) = e.wip_entity_id;

   G_Wip_Entity_ID := X_wip_entity_id;
   G_WIP_Org_ID    := X_organization_id;

   RETURN ( G_WIP_Unit_Num );

EXCEPTION
WHEN OTHERS THEN
   RETURN ( NULL );

END WIP_Unit_Number;


FUNCTION WIP_Unit_Number_Cached
( X_wip_entity_id                  IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN VARCHAR2 IS

BEGIN

   IF (  G_WIP_Unit_Num IS NULL
      OR G_WIP_Entity_ID <> X_wip_entity_id
      OR G_WIP_Org_ID <> X_organization_id ) THEN

      SELECT DECODE(e.entity_type, 1, dj.end_item_unit_number,
                                   4, fs.end_item_unit_number)
      INTO   G_WIP_Unit_Num
      FROM   wip_flow_schedules fs
      ,      wip_discrete_jobs dj
      ,      wip_entities e
      WHERE  e.wip_entity_id = X_wip_entity_id
      AND    e.organization_id = X_organization_id
      AND    fs.organization_id (+) = e.organization_id
      AND    fs.wip_entity_id (+) = e.wip_entity_id
      AND    dj.organization_id (+) = e.organization_id
      AND    dj.wip_entity_id (+) = e.wip_entity_id;

     G_Wip_Entity_ID := X_wip_entity_id;
     G_WIP_Org_ID    := X_organization_id;

   END IF;

   RETURN ( G_WIP_Unit_Num );

EXCEPTION
WHEN OTHERS THEN
   RETURN ( NULL );

END WIP_Unit_Number_Cached;


--
--  Name          : RCV_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a PO
--                  distribution or Internal Req distribution based on the
--                  receiving transaction
--
--
--  Parameters    :
--  IN            : X_rcv_transaction_id            NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION RCV_Unit_Number
( X_rcv_transaction_id             IN     NUMBER
) RETURN VARCHAR2 IS

   L_po_distribution_id NUMBER;
   L_req_line_id        NUMBER;

BEGIN

   IF (  G_RCV_Unit_Num IS NULL
      OR G_RCV_Txn_ID <> X_rcv_transaction_id ) THEN

      SELECT po_distribution_id
      ,      requisition_line_id
      INTO   L_po_distribution_id
      ,      L_req_line_id
      FROM   rcv_transactions
      WHERE  transaction_id = X_rcv_transaction_id;

      IF L_po_distribution_id IS NOT NULL THEN

         SELECT end_item_unit_number
         INTO   G_RCV_Unit_Num
         FROM   po_distributions_all
         WHERE  po_distribution_id = L_po_distribution_id;

      ELSIF L_req_line_id IS NOT NULL THEN

         SELECT end_item_unit_number
         INTO   G_RCV_Unit_Num
         FROM   po_req_distributions_all
         WHERE  requisition_line_id = L_req_line_id;

      ELSE

         G_RCV_Unit_Num := null;

      END IF;

      G_RCV_Txn_ID := X_rcv_transaction_id;

   END IF;

   RETURN ( G_RCV_Unit_Num );

EXCEPTION
WHEN OTHERS THEN
   RETURN ( NULL );

END RCV_Unit_Number;


--
--  Name          : OE_Line_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a sales order
--                  line
--
--
--  Parameters    :
--  IN            : X_so_line_id                    NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION OE_Line_Unit_Number
( X_so_line_id                     IN     NUMBER
) RETURN VARCHAR2 IS

BEGIN

   SELECT end_item_unit_number
   INTO   G_OE_Unit_Num
   FROM   oe_order_lines_all
   WHERE  line_id = X_so_line_id;

   G_OE_Line_ID := X_so_line_id;

   RETURN( G_OE_Unit_Num );

EXCEPTION
WHEN OTHERS THEN
   RETURN ( NULL );

END OE_Line_Unit_Number;


FUNCTION OE_Line_Unit_Number_Cached
( X_so_line_id                     IN     NUMBER
) RETURN VARCHAR2 IS

BEGIN

   IF (  G_OE_Unit_Num IS NULL
      OR G_OE_Line_ID <> X_so_line_id ) THEN

      SELECT end_item_unit_number
      INTO   G_OE_Unit_Num
      FROM   oe_order_lines_all
      WHERE  line_id = X_so_line_id;

      G_OE_Line_ID := X_so_line_id;

   END IF;

   RETURN( G_OE_Unit_Num );

EXCEPTION
WHEN OTHERS THEN
   RETURN ( NULL );

END OE_Line_Unit_Number_Cached;


--
--  Name          : RMA_Rcpt_Unit_Number
--  Pre-reqs      : None
--  Function      : This function returns the unit number on a RMA
--                  order line based on the receiving transaction
--
--
--  Parameters    :
--  IN            : X_rcv_transaction_id            NUMBER
--
--  OUT           : None
--
--  Returns       : VARCHAR2
--
FUNCTION RMA_Rcpt_Unit_Number
( X_rcv_transaction_id             IN     NUMBER
) RETURN VARCHAR2 IS
   L_oe_order_line_id   NUMBER;
BEGIN

   IF (  G_RMA_Unit_Num IS NULL
      OR G_RMA_Txn_ID <> X_rcv_transaction_id ) THEN

      SELECT oe_order_line_id
      INTO   L_oe_order_line_id
      FROM   rcv_transactions
      WHERE  transaction_id = X_rcv_transaction_id;

      IF L_oe_order_line_id IS NOT NULL THEN
         G_RMA_Unit_Num := OE_Line_Unit_Number( L_oe_order_line_id );
      ELSE
         G_RMA_Unit_Num := NULL;
      END IF;

      G_RMA_Txn_ID := X_rcv_transaction_id;

   END IF;

   RETURN ( G_RMA_Unit_Num );

EXCEPTION
WHEN OTHERS THEN
   RETURN ( NULL );

END RMA_Rcpt_Unit_Number;


--
--  Name          : Validate_Serial
--  Pre-reqs      : None
--  Function      : This function validates the transaction serial numbers
--                  against the unit number on the transaction entity
--                  (e.g. WIP job)
--
--
--  Parameters    :
--  IN            : X_trx_source_type_id            NUMBER
--                  X_trx_action_id                 NUMBER
--                  X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--                  X_serial_number                 VARCHAR2
--                  X_unit_number                   VARCHAR2
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
--  Algorithm     :
--
--    If Model/Unit Effectivity is not enabled then
--       Return "TRUE"
--
--    If transaction type is not
--    "WIP Component Issue" or
--    "WIP Assembly Return" or
--    "RMA Receipt" or
--    "Direct Interorg transfer" or
--    "Sales order staging transfer" or
--    "Intransit shipment" then
--       Return "TRUE"
--
--    If transaction type is "RMA Receipt" and item serial control is
--    Dynamic Entry at Receipt
--       Return "TRUE"
--
--    Get Effectivity Control attribute from item
--
--    Fetch the Unit Number from the serial number
--
--    If item is date effective and serial has unit number link then
--       Get error message (UEFF-Item Not Unit Effective)
--       populate ERROR_CODE column
--       Return "FALSE"
--
--    If item is unit effective and upstream unit number is null then
--       Get error message (UEFF-Item Unit Effective)
--       populate ERROR_CODE column
--       Return "FALSE"
--
--    If the two Unit Numbers match then
--       Return "TRUE"
--    Else
--       If Cross-Unit Number Issue is enabled then
--          Get warning message (UEFF-Cross Unit Number Issue)
--          populate ERROR_CODE column
--          Return "TRUE"
--       Else
--          Get error message (UEFF-Unit Number Mismatch)
--          populate ERROR_CODE column
--          Return "FALSE"
--

FUNCTION Validate_Serial
( X_trx_source_type_id             IN            NUMBER
, X_trx_action_id                  IN            NUMBER
, X_item_id                        IN            NUMBER
, X_organization_id                IN            NUMBER
, X_serial_number                  IN            VARCHAR2
, X_unit_number                    IN            VARCHAR2
, X_error_code                     OUT NOCOPY    VARCHAR2
) RETURN BOOLEAN IS
  L_serial_unitnum        PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE;
  L_unit_eff_item         VARCHAR2(1);
BEGIN

   --
   -- If Model/Unit Effectivity is not enabled, there is no need for
   -- further processing
   --
   if ( enabled = 'N' ) then
      return ( TRUE );
   end if;

   --
   -- If transaction type is not "WIP Component Issue" or "WIP Assembly Return"
   -- or "Direct Interorg transfer" or "Intransit shipment"
   -- there is no need for further processing
   --
   -- 11.08.1999
   -- Added support for RMA receipts
   --
   -- 01.29.2003
   -- Added support for sales orders staging transfers
   --
   if not ( ( X_trx_source_type_id = 5    -- Job or Schedule
            AND (  X_trx_action_id = 1    -- Issue from stores
                OR X_trx_action_id = 32   -- Assembly return
                )
            ) OR
            ( X_trx_source_type_id = 12   -- RMA
            AND (  X_trx_action_id = 27   -- Receipt into stores
                )
            ) OR
            ( (  X_trx_source_type_id = 2 -- Sales order
              OR X_trx_source_type_id = 8 -- Internal sales order
              )
            AND (  X_trx_action_id = 28   -- Staging transfer
                )
            ) OR
            ( X_trx_source_type_id = 13   -- Inventory
            AND (  X_trx_action_id = 3    -- Direct organization transfer
                OR X_trx_action_id = 21   -- Intransit shipment
                )
            )
          ) then
      return ( TRUE );
   end if;

   --
   -- A Law  01/31/2003
   --
   -- If transaction type is sales order staging transfer and the
   -- input unit number is NULL, do not perform validation.
   --
   -- This is put in as a kludge but should be removed with a future fix
   -- in the transaction processor.
   --
   if ( ( (  X_trx_source_type_id = 2 -- Sales order
          OR X_trx_source_type_id = 8 -- Internal sales order
          )
        AND (  X_trx_action_id = 28   -- Staging transfer
            )
        ) AND
        X_unit_number is null
      ) then
      return ( TRUE );
   end if;

   --
   -- A Law  02/17/2000
   --
   -- Bug 1200761:
   --
   -- If transaction type is RMA Receipt and item serial control is
   -- Dynamic Entry at Receipt, there is no need for further
   -- processing
   --
   if ( ( X_trx_source_type_id = 12   -- RMA
        AND (  X_trx_action_id = 27   -- Receipt into stores
            )
        ) AND
        Item_Serial_Control( X_item_id
			   , X_organization_id ) = 5
      ) then
      return ( TRUE );
   end if;

   L_unit_eff_item := Unit_Effective_Item( X_item_id
					 , X_organization_id );

   SELECT end_item_unit_number
   INTO   L_serial_unitnum
   FROM   mtl_serial_numbers
   WHERE  serial_number = X_serial_number
   AND    inventory_item_id = X_item_id;

   --
   -- If item is not under Unit Effective control but serial is link to
   -- to a unit number, raise error
   --
   if ( L_unit_eff_item = 'N' ) then
      if ( L_serial_unitnum is null ) then

         return ( TRUE );

      else

         X_error_code := 'UEFF-Item Not Unit Effective';
         fnd_message.set_name('PJM','UEFF-Item Not Unit Effective');
         return ( FALSE );

      end if;
   end if;

   --
   -- If item is under Unit Effective control but upstream unit number
   -- is NULL, raise error
   --
   if ( X_unit_number is null ) then

      X_error_code := 'UEFF-Item Unit Effective';
      fnd_message.set_name('PJM','UEFF-Item Unit Effective');
      return ( FALSE );

   end if;

   --
   -- Now the validation logic
   --
   if ( X_unit_number = L_serial_unitnum ) then

      return ( TRUE );

   else
      if ( Allow_Cross_UnitNum_Issues(X_organization_id) = 'Y' ) then

         X_error_code := 'UEFF-Cross Unit Number Issue';
         fnd_message.set_name('PJM','UEFF-Cross Unit Number Issue');
         fnd_message.set_token('SERIAL', X_serial_number);
         return ( TRUE );

      else

         X_error_code := 'UEFF-Unit Number Mismatch';
         fnd_message.set_name('PJM','UEFF-Unit Number Mismatch');
         fnd_message.set_token('SERIAL', X_serial_number);
         fnd_message.set_token('UNIT1', L_serial_unitnum);
         fnd_message.set_token('UNIT2', X_unit_number);
         return ( FALSE );

      end if;
   end if;

END Validate_Serial;


--
--  Name          : Serial_UnitNum_Link
--  Pre-reqs      : None
--  Function      : This function links the transaction serial numbers
--                  to the unit number on the transaction entity
--                  (e.g. WIP job)
--
--
--  Parameters    :
--  IN            : X_transaction_id                NUMBER
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
FUNCTION Serial_UnitNum_Link
( X_transaction_id                 IN            NUMBER
, X_error_code                     OUT NOCOPY    VARCHAR2
) RETURN BOOLEAN IS
  L_organization_id NUMBER;
  L_item_id         NUMBER;
  L_src_type_id     NUMBER;
  L_trx_action_Id   NUMBER;
  L_trx_src_id      NUMBER;
  L_rcv_trx_id      NUMBER;
  L_direction       NUMBER;
  L_unit_number     PJM_UNIT_NUMBERS.UNIT_NUMBER%TYPE;
BEGIN

   --
   -- If Model/Unit Effectivity is not enabled, there is no need for
   -- further processing
   --
   if ( enabled = 'N' ) then
      return ( TRUE );
   end if;

   SELECT organization_id
   ,      inventory_item_id
   ,      transaction_source_type_id
   ,      transaction_action_id
   ,      transaction_source_id
   ,      rcv_transaction_id
   ,      SIGN(primary_quantity)
   INTO   L_organization_id
   ,      L_item_id
   ,      L_src_type_id
   ,      L_trx_action_id
   ,      L_trx_src_id
   ,      L_rcv_trx_id
   ,      L_direction
   FROM   mtl_material_transactions
   WHERE  transaction_id = X_transaction_id;

   --
   -- If item is not under Unit Effective control, there is no need for
   -- further processing
   --
   if ( Unit_Effective_Item( L_item_id, L_organization_id ) = 'N' ) then
      return ( TRUE );
   end if;

   --
   -- If transaction type is not any one of the following, there is no
   -- need for further processing
   --
   -- 11.08.1999
   -- Added support for RMA receipts
   --
   if not (
      ( L_src_type_id = 1          -- Purchase Order
       AND
        (  L_trx_action_id = 27    -- Receipt into stores
        OR L_trx_action_id = 1 )   -- Issue from stores
      )
   OR ( L_src_type_id = 5          -- Job or schedule
       AND
        (  L_trx_action_id = 31    -- Assembly completion
        OR L_trx_action_id = 32    -- Assembly return
        OR L_trx_action_id = 33    -- Negative component issue
        OR L_trx_action_id = 34 )  -- Negative component return
      )
   OR ( L_src_type_id = 12         -- RMA
       AND
        (  L_trx_action_id = 27    -- Receipt into stores
        OR L_trx_action_id = 1 )   -- Issue from stores
      )
   ) then
      return ( TRUE );
   end if;

   if ( L_src_type_id = 5 ) then
      L_unit_number := WIP_Unit_Number(L_trx_src_id, L_organization_id);
   elsif ( L_src_type_id = 1 ) then
      L_unit_number := RCV_Unit_Number(L_rcv_trx_id);
   else
      L_unit_number := RMA_Rcpt_Unit_Number(L_rcv_trx_id);
   end if;

   UPDATE mtl_serial_numbers
   SET    end_item_unit_number =
     DECODE(L_direction, 1, L_unit_number, NULL)
   WHERE  (inventory_item_id, serial_number) in (
     SELECT inventory_item_id, serial_number
     FROM   mtl_unit_transactions
     WHERE  transaction_id = X_transaction_id
    UNION ALL   /*Bug 7207502 (FP of 6391634): Added union part to select serial when assembly is lot serial controlled.*/
     SELECT mut.inventory_item_id, mut.serial_number
     FROM   mtl_transaction_lot_numbers mtln,   mtl_unit_transactions mut
     WHERE  mtln.transaction_id = X_transaction_id
     AND   mtln.serial_transaction_id =   mut.transaction_id
   );

   return ( TRUE );

EXCEPTION
when others then
   X_error_code := sqlerrm;
   return ( FALSE );
END Serial_UnitNum_Link;


--
--  Name          : Unit_Serial_History
--  Pre-reqs      : None
--  Function      : This function creates audit trail information for
--                  unit number changes to serial numbers
--
--
--  Parameters    :
--  IN            : X_serial_number                 VARCHAR2
--                  X_item_id                       NUMBER
--                  X_old_unit_number               VARCHAR2
--                  X_new_unit_number               VARCHAR2
--                  X_start_num                     NUMBER
--                  X_counts                        NUMBER
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
FUNCTION Unit_Serial_History
( X_serial_number                  IN            VARCHAR2
, X_item_id                        IN            NUMBER
, X_organization_id                IN            NUMBER
, X_old_unit_number                IN            VARCHAR2
, X_new_unit_number                IN            VARCHAR2
, X_error_code                     OUT NOCOPY    VARCHAR2
) return BOOLEAN IS
  L_user_id              NUMBER;
  L_login_id             NUMBER;
BEGIN

   L_user_id := fnd_global.user_id;
   L_login_id := fnd_global.conc_login_id;

   INSERT INTO pjm_unit_serial_history
   ( serial_number
   , inventory_item_id
   , organization_id
   , old_unit_number
   , new_unit_number
   , creation_date
   , created_by
   , last_update_date
   , last_updated_by
   , last_update_login )
   SELECT X_serial_number
   ,      X_item_id
   ,      X_organization_id
   ,      X_old_unit_number
   ,      X_new_unit_number
   ,      sysdate
   ,      L_user_id
   ,      sysdate
   ,      L_user_id
   ,      L_login_id
   FROM   dual;

   return ( TRUE );

EXCEPTION
when others then
   X_error_code := sqlerrm;
   return ( FALSE );

END Unit_Serial_History;


--
--  Name          : OE_Attribute
--  Pre-reqs      : None
--  Function      : This function returns the attribute column in the
--                  SO_LINES descriptive flexfield that stores the unit
--                  number value.  The column name is captured in the
--                  profile PJM_UEFF_OE_ATTRIBUTE.
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : Boolean
--
FUNCTION OE_Attribute
  RETURN VARCHAR2 IS
BEGIN

   RETURN( Fnd_Profile.Value_WNPS('PJM_UEFF_OE_ATTRIBUTE') );

END OE_Attribute;


END PJM_UNIT_EFF;

/
