--------------------------------------------------------
--  DDL for Package Body PJM_BORROW_PAYBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_BORROW_PAYBACK" AS
/* $Header: PJMBWPYB.pls 115.25 2004/01/07 22:35:52 alaw ship $ */
--  ---------------------------------------------------------------------
--  Global Variables
--  ---------------------------------------------------------------------
G_Bucket_Size    NUMBER := 30;

--  ---------------------------------------------------------------------
--  Private Functions / Procedures
--  ---------------------------------------------------------------------


--  ---------------------------------------------------------------------
--  Public Functions / Procedures
--  ---------------------------------------------------------------------

--
--  Name          : Set_Bucket_Size
--  Pre-reqs      : None
--  Function      : This procedure sets the global variable
--                  G_Bucket_Size
--
--
--  Parameters    :
--  IN            : X_Bucket_Size                   NUMBER
--
--  Returns       : None
--
PROCEDURE Set_Bucket_Size
( X_Bucket_Size                    IN     NUMBER
) IS
BEGIN

   G_Bucket_Size := X_Bucket_Size;

END Set_Bucket_Size;


--
--  Name          : Bucket_Size
--  Pre-reqs      : None
--  Function      : This procedure gets the value in global variable
--                  G_Bucket_Size
--
--
--  Parameters    :
--  IN            : None
--
--  Returns       : VARCHAR2
--
FUNCTION Bucket_Size
  RETURN NUMBER IS
BEGIN

   return ( G_Bucket_Size );

END Bucket_Size;


--
--  Name          : Trx_Callback
--  Pre-reqs      : Non
--  Function      : This function performs the following tasks:
--                  1) for a borrow transaction, it inserts a record
--                     into PJM_BORROW_TRANSACTIONS
--
--                  2) for a payback transaction, it allocates the
--                     payback quantity to borrow transactions and
--                     insert the results in PJM_BORROW_PAYBACKS
--
--
--  Parameters    :
--  IN            : X_transaction_id                NUMBER
--                  X_transaction_temp_id           NUMBER
--
--  OUT           : X_error_code                    VARCHAR2
--
--  Returns       : Boolean
--
FUNCTION Trx_Callback
( X_transaction_id                 IN           NUMBER
, X_transaction_temp_id            IN           NUMBER
, X_error_code                     OUT NOCOPY   VARCHAR2
) RETURN BOOLEAN IS

  L_trx_type_id     NUMBER;
  L_trx_quantity    NUMBER;
  L_proj_id         NUMBER;
  L_task_id         NUMBER;
  L_to_proj_id      NUMBER;
  L_to_task_id      NUMBER;
  L_item_id         NUMBER;
  L_revision        VARCHAR2(3);
  L_organization_id NUMBER;
  L_proj_ctrl_level NUMBER;

  L_borrow_trx_id   NUMBER;
  L_outstanding_qty NUMBER;
  L_payback_qty     NUMBER;
  L_payback_date    DATE;

  CURSOR c
  ( C_borrow_proj_id  NUMBER
  , C_borrow_task_id  NUMBER
  , C_lending_proj_id NUMBER
  , C_lending_task_id NUMBER
  , C_item_id         NUMBER
  , C_revision        VARCHAR2
  , C_organization_id NUMBER
  , C_proj_ctrl_level NUMBER ) IS
  SELECT borrow_transaction_id
  ,      outstanding_quantity
  FROM   pjm_borrow_transactions
  WHERE  decode(C_proj_ctrl_level, 1, borrow_project_id, borrow_task_id) =
         decode(C_proj_ctrl_level, 1, C_borrow_proj_id, C_borrow_task_id)
  AND    decode(C_proj_ctrl_level, 1, lending_project_id, lending_task_id) =
         decode(C_proj_ctrl_level, 1, C_lending_proj_id, C_lending_task_id)
  AND    inventory_item_id = C_item_id
  AND    organization_id = C_organization_id
  AND    outstanding_quantity > 0
  ORDER BY loan_date ASC, borrow_transaction_id ASC
  FOR UPDATE OF outstanding_quantity;

BEGIN

   --
   -- Fetch transaction details from MTL_MATERIAL_TRANSACTIONS
   --
   SELECT transaction_type_id
   ,      primary_quantity * (-1)
   ,      project_id
   ,      task_id
   ,      to_project_id
   ,      to_task_id
   ,      inventory_item_id
   ,      revision
   ,      organization_id
   INTO   L_trx_type_id
   ,      L_trx_quantity
   ,      L_proj_id
   ,      L_task_id
   ,      L_to_proj_id
   ,      L_to_task_id
   ,      L_item_id
   ,      L_revision
   ,      L_organization_id
   FROM   mtl_material_transactions
   WHERE  transaction_id = X_transaction_id;

   --
   -- Make sure this is a borrow or payback transaction
   --
   if ( L_trx_type_id not in (66, 68) ) then
      return ( TRUE );
   end if;

   --
   -- Make sure this is a "transfer from" transaction
   --
   if ( L_trx_quantity < 0 ) then
      return ( TRUE );
   end if;

   --
   -- Get project_control_level parameter for the organization.
   --
   select project_control_level
   into   L_proj_ctrl_level
   from   mtl_parameters
   where  organization_id = L_organization_id;

   if ( L_trx_type_id = 66 ) then

      SELECT scheduled_payback_date
      INTO   L_payback_date
      FROM   mtl_material_transactions_temp
      WHERE  transaction_temp_id = X_transaction_temp_id;

      INSERT INTO pjm_borrow_transactions
      (      borrow_transaction_id
      ,      creation_date
      ,      created_by
      ,      last_update_date
      ,      last_updated_by
      ,      last_update_login
      ,      request_id
      ,      program_application_id
      ,      program_id
      ,      program_update_date
      ,      borrow_project_id
      ,      borrow_task_id
      ,      lending_project_id
      ,      lending_task_id
      ,      organization_id
      ,      inventory_item_id
      ,      revision
      ,      loan_quantity
      ,      outstanding_quantity
      ,      loan_date
      ,      scheduled_payback_date )
      SELECT transaction_id
      ,      sysdate
      ,      created_by
      ,      sysdate
      ,      last_updated_by
      ,      last_update_login
      ,      request_id
      ,      program_application_id
      ,      program_id
      ,      sysdate
      ,      to_project_id
      ,      decode(L_proj_ctrl_level, 2, to_task_id, NULL)
      ,      project_id
      ,      decode(L_proj_ctrl_level, 2, task_id, NULL)
      ,      organization_id
      ,      inventory_item_id
      ,      revision
      ,      (-1) * primary_quantity
      ,      (-1) * primary_quantity
      ,      transaction_date
      ,      L_payback_date
      FROM   mtl_material_transactions
      WHERE  transaction_id = X_transaction_id;

   else

      SELECT sum(outstanding_quantity)
      INTO   L_outstanding_qty
      FROM   pjm_borrow_transactions
      WHERE  decode(L_proj_ctrl_level, 1, borrow_project_id, borrow_task_id) =
             decode(L_proj_ctrl_level, 1, L_proj_id, L_task_id)
      AND    decode(L_proj_ctrl_level, 1, lending_project_id, lending_task_id) =
             decode(L_proj_ctrl_level, 1, L_to_proj_id, L_to_task_id)
      AND    inventory_item_id  = L_item_id
      AND    organization_id    = L_organization_id
      AND    outstanding_quantity > 0;

      if ( L_outstanding_qty < L_trx_quantity ) then
         X_error_code := 'BWPY-Payback Quantity Exceeded';
	 fnd_message.set_name('PJM', X_Error_Code);
         return ( FALSE );
      end if;

      OPEN c ( L_proj_id
             , L_task_id
             , L_to_proj_id
             , L_to_task_id
             , L_item_id
             , L_revision
             , L_organization_id
             , L_proj_ctrl_level);

      WHILE ( L_trx_quantity > 0 ) LOOP

         FETCH c INTO L_borrow_trx_id, L_outstanding_qty;

         if ( L_outstanding_qty > L_trx_quantity ) then
            L_payback_qty := L_trx_quantity;
         else
            L_payback_qty := L_outstanding_qty;
         end if;

         INSERT INTO pjm_borrow_paybacks
	 (      payback_transaction_id
	 ,      borrow_transaction_id
	 ,      creation_date
	 ,      created_by
	 ,      last_update_date
	 ,      last_updated_by
	 ,      last_update_login
	 ,      request_id
	 ,      program_application_id
	 ,      program_id
	 ,      program_update_date
	 ,      payback_quantity
	 ,      borrow_project_id
	 ,      borrow_task_id
	 ,      lending_project_id
	 ,      lending_task_id )
	 SELECT transaction_id
	 ,      L_borrow_trx_id
	 ,      sysdate
	 ,      created_by
	 ,      sysdate
	 ,      last_updated_by
	 ,      last_update_login
	 ,      request_id
	 ,      program_application_id
	 ,      program_id
	 ,      sysdate
	 ,      L_payback_qty
	 ,      project_id
	 ,      decode(L_proj_ctrl_level, 2, task_id, NULL)
	 ,      to_project_id
	 ,      decode(L_proj_ctrl_level, 2, to_task_id, NULL)
         FROM   mtl_material_transactions
         WHERE  transaction_id = X_transaction_id;

         UPDATE pjm_borrow_transactions
         SET    outstanding_quantity = outstanding_quantity - L_payback_qty
         ,      last_update_date = sysdate
         WHERE  borrow_transaction_id = L_borrow_trx_id;

         L_trx_quantity := L_trx_quantity - L_payback_qty;

      END LOOP;

      if L_trx_quantity > 0 then
         X_error_code := 'BWPY-Payback Quantity Exceeded';
	 fnd_message.set_name('PJM', X_Error_Code);
         return ( FALSE );
      end if;

   end if;

   return ( TRUE );

END Trx_Callback;

------------------------------------------------------------------------
--  PURPOSE :
--      This function will be called from Inventory Transaction form.
--      When user issue a project borrow/payback transaction, the form
--      will call this function to validate the transaction.
--
--  PARAMETERS IN:
--      X_Transaction_Type_Id
--      X_Transaction_Action_Id
--      X_Organization_ID
--      X_From_Subinventory
--      X_From_Locator_Id
--      X_To_Subinventory
--      X_To_Locator_Id
--      X_Inventory_Item_Id
--      X_Revision
--      X_Primary_Quantity
--      X_Transaction_Date
--      X_Payback_Date
--
--  PARAMETERS OUT:
--      X_Error_Code
--
--  RETURN :
--      NUMBER
--         0 -- SUCCESS
--         1 -- FAILURE
--         2 -- WARNING
--
----------------------------------------------------------------------

FUNCTION VALIDATE_TRX
( X_Transaction_Type_Id     IN         NUMBER
, X_Transaction_Action_Id   IN         NUMBER
, X_Organization_Id         IN         NUMBER
, X_From_SubInventory       IN         VARCHAR2
, X_From_Locator_Id         IN         NUMBER
, X_To_Subinventory         IN         VARCHAR2
, X_To_Locator_Id           IN         NUMBER
, X_Inventory_Item_Id       IN         NUMBER
, X_Revision                IN         VARCHAR2
, X_Primary_Quantity        IN         NUMBER
, X_Transaction_Date        IN         DATE
, X_Payback_Date            IN         DATE
, X_Error_Code              OUT NOCOPY VARCHAR2
) RETURN NUMBER IS

l_success  	      number := 0;
l_failure	      number := 1;
l_warning	      number := 2;

l_from_project_id     NUMBER;
l_from_task_id        NUMBER;
l_to_project_id	      NUMBER;
l_to_task_id          NUMBER;
l_outstanding_qty     NUMBER := 0;
l_onhand_qty          NUMBER := 0;
l_project_control_lev NUMBER;
l_from_physical_loc   NUMBER;
l_to_physical_loc     NUMBER;
l_asset_item_flag     VARCHAR2(1);
l_asset_inventory     VARCHAR2(1);

CURSOR c(C_Project_Control_Lev    NUMBER,
         C_From_Project_Id        NUMBER,
         C_From_Task_Id           NUMBER,
         C_To_Project_Id          NUMBER,
         C_To_Task_Id             NUMBER,
         C_Organization_Id        NUMBER,
         C_Inventory_Item_Id      NUMBER,
         C_Revision               VARCHAR2) IS
 select  outstanding_quantity
   from  pjm_borrow_transactions
  where  decode(c_project_control_lev, 1, lending_project_id,
                lending_task_id) =
         decode(c_project_control_lev, 1, c_to_project_id, c_to_task_id)
    and  decode(c_project_control_lev, 1, borrow_project_id,
                borrow_task_id)  =
         decode(c_project_control_lev, 1, c_from_project_id, c_from_task_id)
    and  organization_id = C_Organization_Id
    and  inventory_item_id = C_Inventory_Item_Id
  order by loan_date DESC;

BEGIN

  ------------------------------------------------------------
  -- if this is not an Inventory Transfer transaction, we don't
  -- need to do anything.
  ------------------------------------------------------------
  if (X_Transaction_Action_Id <> 2) then
      return(l_success);
  end if;


  -----------------------------------------------------------
  -- Verify if the item is not a Asset Item.
  -----------------------------------------------------------
  if ( X_Transaction_Type_Id in (66, 68) ) then

    select nvl(inventory_asset_flag, 'N')
    into   l_asset_item_flag
    from   mtl_system_items
    where  organization_id = X_Organization_ID
    and    inventory_item_id = X_Inventory_Item_Id;

    if (l_asset_item_flag = 'N') then
         X_Error_Code := 'BWPY-Non Asset Item Transfer';
         fnd_message.set_name('PJM', X_Error_Code);
         return(l_failure);
    end if;


    ------------------------------------------------------------
    -- Verify if the from/to subinventory is not Asset Inventory
    ------------------------------------------------------------
    begin
      select 'N'
      into   l_asset_inventory
      from   mtl_secondary_inventories
      where  organization_id = X_Organization_Id
      and   (secondary_inventory_name = X_From_Subinventory
         or  secondary_inventory_name = X_To_Subinventory)
      and    asset_inventory = 2;

      if SQL%FOUND then
         X_Error_Code := 'BWPY-Non Asset Inventory Trans';
         fnd_message.set_name('PJM', X_Error_Code);
         return(l_failure);
      end if;

      exception
      when NO_DATA_FOUND then
           null;
      when TOO_MANY_ROWS then
         X_Error_Code := 'BWPY-Non Asset Inventory Trans';
         fnd_message.set_name('PJM', X_Error_Code);
         return(l_failure);
    end;

  end if;

  -----------------------------------------------------------
  -- Derive project_id, task_id from locator_id
  -----------------------------------------------------------
  if ( X_From_Locator_Id is not null ) then

    select  project_id, task_id,
            physical_location_id
    into    l_from_project_id, l_from_task_id,
            l_from_physical_loc
    from    mtl_item_locations
    where   organization_id = X_Organization_Id
      and   inventory_location_id = X_From_Locator_Id ;

  else

    l_from_project_id := NULL;
    l_from_task_id := NULL;
    l_from_physical_loc := NULL;

  end if;

  if ( X_To_Locator_Id is not null ) then

    select  project_id, task_id,
            physical_location_id
      into  l_to_project_id, l_to_task_id,
            l_to_physical_loc
      from  mtl_item_locations
     where  organization_id = X_Organization_Id
       and  inventory_location_id = X_To_Locator_Id;


  else

    l_to_project_id := NULL;
    l_to_task_id := NULL;
    l_to_physical_loc := NULL;

  end if;

  ------------------------------------------------------------
  -- Get project_control_level parameter for the organization.
  ------------------------------------------------------------
  BEGIN
    select project_control_level
      into l_project_control_lev
      from pjm_org_parameters
     where organization_id = X_Organization_Id;
  EXCEPTION
    WHEN no_data_found THEN
      l_project_control_lev := 0;
  END;

  -------------------------------------------------------------
  -- If transaction_type is not Project Borrow, Project Payback
  -- or Project Transfer, the from_project_id should always
  -- equal to to_project_id.
  -------------------------------------------------------------
  if (X_Transaction_Type_Id not in (66, 68, 67)) then
    if( ( nvl(l_from_project_id,0) <> nvl(l_to_project_id,0) ) OR
        ( nvl(l_from_task_id,0)    <> nvl(l_to_task_id,0)    ) ) then
       X_Error_Code := 'BWPY-Project Transfer';
       fnd_message.set_name('PJM', X_Error_Code);
       return(l_failure);
    else
       return(l_success);
    end if;

  else
    -----------------------------------------------------------
    --  Verify that both sides are not common
    -----------------------------------------------------------
    if (   l_from_project_id is null
       and l_to_project_id is null ) then
       X_Error_Code := 'BWPY-Common Transfer';
       fnd_message.set_name('PJM', X_Error_Code);
       return(l_failure);
    end if;

    -----------------------------------------------------------
    --  Verify that both sides are not the same
    -----------------------------------------------------------
    -----------------------------------------------------------
    --  Bug 1284273:
    --  The following check is only applicable for Borrow and
    --  Payback transactions
    -----------------------------------------------------------
    if (X_Transaction_Type_Id in (66, 68)) then
      if (l_project_control_lev = 1) then
        if (nvl(l_from_project_id,0) = nvl(l_to_project_id,0)) then
           X_Error_Code := 'BWPY-Same Project';
           fnd_message.set_name('PJM', X_Error_Code);
           return(l_failure);
        end if;
      elsif (l_project_control_lev = 2) then
        if (nvl(l_from_task_id,0) = nvl(l_to_task_id,0)) then
           X_Error_Code := 'BWPY-Same Task';
           fnd_message.set_name('PJM', X_Error_Code);
           return(l_failure);
        end if;
      end if;
    end if;

  end if;


  -----------------------------------------------------------
  --  If Transaction Type is 'Project Borrow'
  -----------------------------------------------------------
  if ( X_Transaction_Type_Id = 66 ) then

     --------------------------------------------------------------
     -- Verify that the from locator and to locator is not common
     -- locator
     --------------------------------------------------------------

     if (l_from_project_id is null or l_to_project_id is null)  then
         X_Error_Code := 'BWPY-Borrow Against Common';
         fnd_message.set_name('PJM', X_Error_Code);
         return (l_failure);
     end if;

     BEGIN

       OPEN c(l_project_control_lev,
              l_from_project_id,
              l_from_task_id,
              l_to_project_id,
              l_to_task_id,
              X_organization_id,
              X_Inventory_Item_Id,
              X_Revision);

       FETCH c INTO l_outstanding_qty;
       CLOSE C;

       --------------------------------------------------------------------
       -- Verify that the lending project does not have an outstanding loan
       -- from the borrow project for the same item.
       --------------------------------------------------------------------

       if (l_outstanding_qty > 0) then
           X_Error_Code := 'BWPY-Loan Loop Detected';
           fnd_message.set_name('PJM', X_Error_Code);
           return( l_failure);
       end if;

       EXCEPTION
       when NO_DATA_FOUND then
           null;
     END;

     BEGIN
       select  sum(moq.transaction_quantity)
         into  l_onhand_qty
         from  mtl_onhand_quantities_detail moq,
               mtl_item_locations mil
        where  mil.project_id = l_from_project_id
          and  mil.task_id = l_from_task_id
          and  mil.subinventory_code = X_From_Subinventory
          and  mil.organization_id = X_Organization_Id
          and  mil.inventory_location_id = moq.locator_id
          and  mil.organization_id = moq.organization_id
          and  mil.subinventory_code = moq.subinventory_code
          and  moq.inventory_item_id = X_Inventory_Item_Id;

       ------------------------------------------------------------------
       -- Verify the lending project has sufficient available on-hand
       ------------------------------------------------------------------

       if (l_onhand_qty < X_Primary_Quantity) then
           X_Error_Code := 'BWPY-Insufficient Onhand';
           fnd_message.set_name('PJM', X_Error_Code);
           return (l_failure);
       end if;

       EXCEPTION
       when NO_DATA_FOUND then
           X_Error_Code := 'BWPY-Insufficient Onhand';
           fnd_message.set_name('PJM', X_Error_Code);
           return (l_failure);
     END;

     --------------------------------------------------------------
     -- Verify that scheduled_payback_date is valid
     --------------------------------------------------------------

     if ( X_payback_date is null ) then
         X_Error_Code := 'BWPY-Payback Date Required';
         fnd_message.set_name('PJM', X_Error_Code);
         return (l_failure);
     end if;

     if ( X_payback_date < sysdate OR
	  X_payback_date < X_transaction_date ) then
         X_Error_Code := 'BWPY-Payback Date Invalid';
         fnd_message.set_name('PJM', X_Error_Code);
         return (l_failure);
     end if;

  --------------------------------------------------
  -- If Transaction Type is 'Project Payback'
  --------------------------------------------------
  elsif ( X_Transaction_Type_Id = 68) then

     --------------------------------------------------------------------
     -- Verify the desination locator is not a common locator
     --------------------------------------------------------------------

     if (l_from_project_id is null or l_to_project_id is null)  then
         X_Error_Code := 'BWPY-Payback to Common';
         fnd_message.set_name('PJM', X_Error_Code);
         return (l_failure);
     end if;

     BEGIN
       select  nvl(sum(outstanding_quantity),0)
         into  l_outstanding_qty
         from  pjm_borrow_transactions
        where  decode(l_project_control_lev, 1, lending_project_id,
                      lending_task_id) =
               decode(l_project_control_lev, 1, l_to_project_id, l_to_task_id)
          and  decode(l_project_control_lev, 1, borrow_project_id,
                      borrow_task_id)  =
               decode(l_project_control_lev, 1, l_from_project_id, l_from_task_id)
          and  organization_id = X_Organization_Id
          and  Inventory_item_id = X_Inventory_Item_Id;

        --------------------------------------------------------------------
        -- Verify there is an outstanding loan balance for the item
        -- against the lendinf project
        --------------------------------------------------------------------

        if (l_outstanding_qty = 0) then
            X_Error_Code := 'BWPY-No Loan Balance';
            fnd_message.set_name('PJM', X_Error_Code);
            return(l_failure);
        end if;

        ---------------------------------------------------------------------
        -- Verify the payback quantity is not greater than the total
        -- outstanding balance
        ---------------------------------------------------------------------

        if (l_outstanding_qty < X_Primary_Quantity) then
            X_Error_Code := 'BWPY-Payback Quantity Exceeded';
            fnd_message.set_name('PJM', X_Error_Code);
            return(l_failure);
        end if;

        EXCEPTION
        when NO_DATA_FOUND then
            X_Error_Code := 'BWPY-Payback Quantity Exceeded';
            fnd_message.set_name('PJM', X_Error_Code);
            return(l_failure);
      END;

  end if;

  ------------------------------------------------------------------
  -- Verify the physical movement required
  ------------------------------------------------------------------

  if ((X_From_Subinventory <> X_To_Subinventory)  OR
       (l_From_physical_loc <> l_To_physical_loc))     then

        X_Error_Code := 'BWPY-Physical Transfer';
        fnd_message.set_name('PJM', X_Error_Code);
        return(l_warning);
  end if;

  return(l_success);

END VALIDATE_TRX;

END PJM_BORROW_PAYBACK;

/
