--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_CHARGE_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_CHARGE_ACC" AS
/* $Header: POXWPCAB.pls 120.9.12010000.6 2011/09/16 11:12:44 mzhussai ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWPCAB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_WF_PO_CHARGE_ACC
 |
 | NOTES
 | MODIFIED    IMRAN ALI (09/02/97) - Created
 |             Imran Ali (01/23/98)
 *=====================================================================*/


/*
    * A Global variable to set the debug mode
*/
debug_acc_generator_wf BOOLEAN := FALSE;


--
-- Check Destination Type
--
procedure check_destination_type ( itemtype        in  varchar2,
                                   itemkey         in  varchar2,
                             actid           in number,
                                   funcmode        in  varchar2,
                                   result          out NOCOPY varchar2    )
is
  x_progress              varchar2(100);
  x_destination_type  varchar2(25);
begin

  x_progress := 'PO_WF_PO_CHARGE_ACC.check_destination_type: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_destination_type := po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                              aname    => 'DESTINATION_TYPE_CODE');

  /* Start DEBUG
  If (debug_acc_generator_wf) then
  dbms_output.put_line ('Procedure PO_WF_PO_CHARGE_ACC.check_destination_type');
  dbms_output.put_line ('DESTINATION_TYPE_CODE: ' || x_destination_type);
  end if;
  End DEBUG */

  if x_destination_type = 'EXPENSE' then
  result := 'COMPLETE:EXPENSE';
  elsif x_destination_type = 'INVENTORY' then
  result := 'COMPLETE:INVENTORY';
  elsif x_destination_type = 'SHOP FLOOR' then
  result := 'COMPLETE:SHOP_FLOOR';
  end if;

  return;

EXCEPTION
  WHEN OTHERS THEN
      wf_core.context('PO_WF_PO_CHARGE_ACC','check_destination_type',x_progress);

  /* Start DEBUG
      If (debug_acc_generator_wf) then
    dbms_output.put_line (' --> EXCEPTION <-- in PO_WF_PO_CHARGE_ACC.check_destination_type');
      end if;
  End DEBUG */

      raise;
end check_destination_type;

-- * ****************************************************************************** *
-- * ****************************************************************************** *

--
-- Private functions specifications for Inventory destination type.
--

function check_inv_item_type (itemtype varchar2, itemkey varchar2, x_dest_org_id number, x_item_id number)
return varchar2;

function check_sub_inv_type (itemtype varchar2, itemkey varchar2, x_dest_sub_inv varchar2, x_dest_org_id number) return varchar2;


--
-- Inventory
--
procedure inventory  ( itemtype        in  varchar2,
                       itemkey         in  varchar2,
                       actid           in number,
                       funcmode        in  varchar2,
                       result          out NOCOPY varchar2    )
is
  x_progress  varchar2(100) := '000';
  x_debug_stmt  varchar2(100) := NULL;
  x_dest_sub_inv  varchar2(25);
  x_subinv_type varchar2(25);
  x_account       number := NULL;
  x_inv_item_type varchar2(25);
  x_dest_org_id   number;
  x_item_id number;
        --<INVCONV R12 START>
  x_status  varchar2(1);
  x_vendor_site_id number;
  x_msg_data      varchar2(2000);
        x_msg_count number;
        --<INVCONV R12 END>
  success   varchar2(2) := 'Y';
  dummy   VARCHAR2(40);
  ret     BOOLEAN;
begin

  x_debug_stmt := 'PO_WF_PO_CHARGE_ACC.inventory: 01' || x_progress;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_debug_stmt);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_dest_org_id := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                           itemkey  => itemkey,
                                       aname    => 'DESTINATION_ORGANIZATION_ID');

  x_item_id     :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                           itemkey  => itemkey,
                                       aname    => 'ITEM_ID');

  x_dest_sub_inv := po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                        aname    => 'DESTINATION_SUBINVENTORY');

  /* Start DEBUG
  If (debug_acc_generator_wf) then
    dbms_output.put_line ('Procedure PO_WF_PO_CHARGE_ACC.inventory');
    dbms_output.put_line ('DESTINATION_ORGANIZATION_ID: ' || to_char(x_dest_org_id));
    dbms_output.put_line ('ITEM_ID: ' || to_char(x_item_id));
    dbms_output.put_line ('DESTINATION_SUBINVENTORY: ' || x_dest_sub_inv);
  end if;
  End DEBUG */

  x_debug_stmt := 'PO_WF_PO_CHARGE_ACC.inventory: dest sub inv :' || x_dest_sub_inv;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_debug_stmt);
  END IF;

  /* Start DEBUG
  If (debug_acc_generator_wf) then
    dbms_output.put_line ('X_INV_ITEM_TYPE:' || x_inv_item_type);
  end if;
  End DEBUG */

  x_debug_stmt := 'PO_WF_PO_CHARGE_ACC.inventory: inv item type :' || x_inv_item_type;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_debug_stmt);
  END IF;

  x_inv_item_type := check_inv_item_type (itemtype, itemkey, x_dest_org_id, x_item_id);

  --Bug 7639037. Uday Phadtare. Commented call to GMF SLA API for process_org because currently
  --GMF_transaction_accounts_PUB.get_accounts is not getting the account as per SLA setup.
 /*
  --<INVCONV R12 START> call the SLA API instead of GML_ACT_ENERATE
  IF ( PO_GML_DB_COMMON.check_process_org(x_dest_org_id) = 'Y')   THEN
   x_vendor_site_id :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'VENDOR_SITE_ID');

       if (x_dest_sub_inv is not null) then
               x_subinv_type := check_sub_inv_type(itemtype, itemkey, x_dest_sub_inv,
                                                   x_dest_org_id);
       end if;
       GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).account_type_code := GMF_transaction_accounts_PUB.G_CHARGE_INV_ACCT;
       GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).item_type := x_inv_item_type;
       GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).subinventory_type := x_subinv_type;
       GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).organization_id := x_dest_org_id;
       GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).inventory_item_id := x_item_id;
       GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).vendor_site_id := x_vendor_site_id;

       GMF_transaction_accounts_PUB.get_accounts(
                               p_api_version                     => 1.0,
        p_init_msg_list      => dummy,
        p_source       => 'PO',
        x_return_status                  => X_status,
        x_msg_data       => x_msg_data,
        x_msg_count      => x_msg_count);
      x_account := GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).target_ccid;
  --<INVCONV R12 END>
  ELSE
  */

  If x_inv_item_type = 'EXPENSE' then

  if (x_dest_sub_inv IS NOT NULL) then   -- Subinventory is provided
    begin

/* 949595 kbenjami 8/25/99.  Proprogated fix from R11.
Bug # 943948
Adding the organization_id condition to the select below.
*/
    select expense_account into x_account
    from mtl_secondary_inventories
    where secondary_inventory_name = x_dest_sub_inv
    and organization_id = x_dest_org_id;
    exception
    when others then
      x_account := NULL;
    end;
  end if;

  if (x_account is NULL) then    -- Get expense account from Item Master
    begin
      select EXPENSE_ACCOUNT into x_account
      from MTL_SYSTEM_ITEMS
      where organization_id = x_dest_org_id
      and inventory_item_id = x_item_id;

    exception
    when others then
      x_account := NULL;
    end;
  end if;

  if (x_account is NULL) then    -- Get account from Org
    begin
    select expense_account into x_account
    from mtl_parameters
    where organization_id = x_dest_org_id;

    exception
    when no_data_found then
      x_account  := NULL;
    when others then
      x_progress := '001';
      raise;
    end;
  end if;

  else            -- item type is ASSET

  -- Test subinventory for Asset or Expense tracking.

  if (x_dest_sub_inv is not null) then
         x_subinv_type := check_sub_inv_type(itemtype, itemkey, x_dest_sub_inv, x_dest_org_id);
  end if;

  IF  (x_dest_sub_inv is null) then

    -- Get the default account from the Organization
    begin
      select material_account into x_account
      from mtl_parameters
      where organization_id = x_dest_org_id;
    exception
        when no_data_found then
        x_account := NULL;
      when others then
        x_progress := '002';
        raise;
    end;

  ELSIF x_subinv_type = 'EXPENSE' then

    begin
      select expense_account into x_account
      from mtl_secondary_inventories
      where secondary_inventory_name = x_dest_sub_inv
      and   organization_id        = x_dest_org_id;
    exception
      when others then
        x_account := NULL;
    end;

    if (x_account is NULL) then

      -- Get the default account from the Organization
      begin
        select expense_account into x_account
        from mtl_parameters
        where organization_id = x_dest_org_id;
      exception
          when no_data_found then
          x_account := NULL;
        when others then
          x_progress := '003';
          raise;
      end;
    end if;

  ELSE  -- destination sub inv type is ASSET

    begin
      select material_account into x_account
      from mtl_secondary_inventories
      where secondary_inventory_name = x_dest_sub_inv
      and   organization_id        = x_dest_org_id;
    exception
      when others then
        x_account := NULL;
    end;

    if (x_account IS NULL) then
      begin
        select material_account into x_account
        from mtl_parameters
        where organization_id = x_dest_org_id;
      exception
          when no_data_found then
              x_account := NULL;
        when others then
          x_progress := '004';
              raise;
      end;
    end if;
  END IF;
  end if;
  --END IF;  --Bug 7639037

  if (x_account IS NULL) then

    /* Start DEBUG
      If (debug_acc_generator_wf) then
    dbms_output.put_line ('RESULT = COMPLETE:FAILURE');
      end if;
  End DEBUG */

  result := 'COMPLETE:FAILURE';
  return;
  end if;

  po_wf_util_pkg.SetItemAttrNumber  (  itemtype=>itemtype,
                                  itemkey=>itemkey,
                                  aname=>'TEMP_ACCOUNT_ID',
                                  avalue=>x_account );
  /* Start DEBUG
  If (debug_acc_generator_wf) then
  dbms_output.put_line ('RESULT = COMPLETE:SUCCESS, x_account = ' || to_char(x_account));
  end if;
  End DEBUG */

  result := 'COMPLETE:SUCCESS';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
  wf_core.context('PO_WF_PO_CHARGE_ACC','inventory',x_progress);

        /* Start DEBUG
      If (debug_acc_generator_wf) then
    dbms_output.put_line (' --> EXCEPTION <-- in PO_WF_PO_CHARGE_ACC.inventory');
      end if;
        End DEBUG */

        raise;

end inventory;


--
-- Private functions body for Inventory destination type.
--

function check_inv_item_type (  itemtype  varchar2,
        itemkey   varchar2,
        x_dest_org_id number,
        x_item_id   number)
return varchar2
is
  x_asset_item_flag varchar2(4);
  x_progress varchar2(200);
begin
    x_progress := 'PO_WF_PO_CHARGE_ACC.check_inv_item_type: 01';

  select inventory_asset_flag into x_asset_item_flag
  from mtl_system_items
  where organization_id = x_dest_org_id
  and inventory_item_id = x_item_id;

        /* Start DEBUG
    If (debug_acc_generator_wf) then
    dbms_output.put_line ('Procedure PO_WF_PO_CHARGE_ACC.check_inv_item_type');
    dbms_output.put_line ('X_ASSET_ITEM_FLAG: ' || x_asset_item_flag);
    end if;
  End DEBUG */

  if x_asset_item_flag = 'Y' then
    return 'ASSET';
  else
    return 'EXPENSE';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    -- Bug 3433867: Enhanced exception handling for this function
    IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_CHARGE_ACC.check_inv_item_type EXCEPTION at '||x_progress
          ||': '||SQLERRM);
    END IF;
    wf_core.context('PO_WF_PO_CHARGE_ACC','check_inv_item_type',x_progress);
    raise;
end;

--

function check_sub_inv_type (   itemtype  varchar2,
        itemkey   varchar2,
        x_dest_sub_inv  varchar2,
        x_dest_org_id   number )
return varchar2
is
  x_asset_inventory number;
  x_progress  varchar2(100);
begin

    x_progress := 'PO_WF_PO_CHARGE_ACC.check_sub_inv_type: 01';

  select asset_inventory into x_asset_inventory
  from mtl_secondary_inventories
  where secondary_inventory_name = x_dest_sub_inv
  and   organization_id        = x_dest_org_id;

  if (x_asset_inventory = 1) then
    return 'ASSET';
  elsif (x_asset_inventory = 2) then
    return 'EXPENSE';
  else
    return '';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_CHARGE_ACC','check_sub_inv_type',x_progress);
        raise;
end;

-- * ****************************************************************************** *
-- * ****************************************************************************** *

--
-- Expense
--
procedure expense  ( itemtype        in  varchar2,
                     itemkey         in  varchar2,
                     actid           in  number,
                     funcmode        in  varchar2,
                     result          out NOCOPY varchar2    )
is
  x_progress  varchar2(100);
  success   varchar2(2);
  x_dest_org_id number;
  x_item_id number;
  x_expense_acc   number;
        --<INVCONV R12 START>
  x_status  varchar2(1);
  x_vendor_site_id number;
  x_msg_data      varchar2(2000);
        x_msg_count number;
        --<INVCONV R12 END>

  dummy   VARCHAR2(40);
  ret     BOOLEAN;
begin

  x_progress := 'PO_WF_PO_CHARGE_ACC.expense: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_dest_org_id := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                             itemkey  => itemkey,
                                         aname    => 'DESTINATION_ORGANIZATION_ID');

  x_item_id     :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                              itemkey  => itemkey,
                                          aname    => 'ITEM_ID');

  /* Start DEBUG
  If (debug_acc_generator_wf) then
    dbms_output.put_line ('Procedure PO_WF_PO_CHARGE_ACC.expense');
    dbms_output.put_line ('DESTINATION_ORGANIZATION_ID: ' || to_char(x_dest_org_id));
    dbms_output.put_line ('ITEM_ID: ' || to_char(x_item_id));
  end if;
  End DEBUG */

  --Bug 7639037. Uday Phadtare. Commented call to GMF SLA API for process_org because currently
  --GMF_transaction_accounts_PUB.get_accounts is not getting the account as per SLA setup.
 /*
  --<INVCONV R12 START>
  if ( PO_GML_DB_COMMON.check_process_org(x_dest_org_id) = 'Y')
  then
   x_vendor_site_id :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'VENDOR_SITE_ID');
  GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).account_type_code := GMF_transaction_accounts_PUB.G_CHARGE_EXP_ACCT;
  GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).item_type := '';
  GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).subinventory_type := '';
  GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).organization_id := x_dest_org_id;
  GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).inventory_item_id := x_item_id;
  GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).vendor_site_id := x_vendor_site_id;

  GMF_transaction_accounts_PUB.get_accounts(
                               p_api_version                     => 1.0,
        p_init_msg_list      => dummy,
        p_source       => 'PO',
        x_return_status                  => X_status,
        x_msg_data       => x_msg_data,
        x_msg_count      => x_msg_count);
  x_expense_acc := GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).target_ccid;

  --GML_ACCT_GENERATE.GENERATE_OPM_ACCT('EXPENSE','', '', x_dest_org_id, x_item_id, x_vendor_site_id, x_expense_acc);
  If (x_expense_acc is null) then
    success := 'N';
  end if;
  ELSE
 */
  begin

    select EXPENSE_ACCOUNT into x_expense_acc
    from MTL_SYSTEM_ITEMS
    where organization_id = x_dest_org_id
    and inventory_item_id = x_item_id;

/*Bug 1319679
         If the default expense account for the item is null
         we should be returning 'N' for Success ie the result
         of the workflow process should be COMPLETE:FAILURE
*/

         if (x_expense_acc is null) then
            success := 'N';
         end if;

  exception
    WHEN NO_DATA_FOUND THEN
      success := 'N';
  end;
 --END IF; --Bug 7639037
--<INVCONV R12 END>

  if (success = 'N') then
  result := 'COMPLETE:FAILURE';

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
             'PO_WF_PO_CHARGE_ACC.expense result='||result);
    END IF;

  return;
  end if;

  po_wf_util_pkg.SetItemAttrNumber  (  itemtype=>itemtype,
                                  itemkey=>itemkey,
                                  aname=>'TEMP_ACCOUNT_ID',
                                  avalue=>x_expense_acc );

  result := 'COMPLETE:SUCCESS';
  -- Bug 3703469: Clear any previous messages in the stack if
  -- account is generated successfully
  fnd_message.clear;
  RETURN;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
             'PO_WF_PO_CHARGE_ACC.expense x_expense_acc='||x_expense_acc);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      wf_core.context('PO_WF_PO_CHARGE_ACC','expense',x_progress);

        /* Start DEBUG
      If (debug_acc_generator_wf) then
    dbms_output.put_line (' --> EXCEPTION <-- in PO_WF_PO_CHARGE_ACC.expense');
      end if;
  End DEBUG */

        raise;

end expense;

-- * ****************************************************************************** *
-- * ****************************************************************************** *
--
-- Check type of WIP
--
procedure check_type_of_wip ( itemtype        in  varchar2,
                            itemkey         in  varchar2,
                        actid           in number,
                            funcmode        in  varchar2,
                            result          out NOCOPY varchar2    )
is
  wip_entity_type   varchar2(80);
  x_progress              varchar2(100);
begin

  x_progress := 'PO_WF_PO_CHARGE_ACC.check_type_of_wip: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  wip_entity_type   :=  po_wf_util_pkg.GetItemAttrText (  itemtype => itemtype,
                                           itemkey  => itemkey,
                                       aname    => 'WIP_ENTITY_TYPE');
  /* Start DEBUG
  If (debug_acc_generator_wf) then
    dbms_output.put_line ('Procedure PO_WF_PO_CHARGE_ACC.check_type_of_wip');
    dbms_output.put_line ('WIP_ENTITY_TYPE: ' || wip_entity_type);
  end if;
  End DEBUG */

  if (wip_entity_type = '2') then
  result := 'COMPLETE:SCHEDULE';
  else
  result := 'COMPLETE:JOB_WIP';
  end if;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_CHARGE_ACC','check_type_of_wip',x_progress);
        raise;

end check_type_of_wip;

-- * ****************************************************************************** *

--
-- JOB_WIP
--
procedure job_wip ( itemtype        in  varchar2,
              itemkey         in  varchar2,
              actid           in number,
                    funcmode        in  varchar2,
                    result          out NOCOPY varchar2    )
is
  x_wip_entity_type       varchar2(80);
  x_wip_job_account       NUMBER := NULL;
  x_wip_entity_id         NUMBER;
  x_bom_cost_element_id       NUMBER;
  x_destination_organization_id   NUMBER;
  x_progress                    varchar2(200);
        --Bug# 1902716 togeorge 07/25/2001
        --EAM:
  x_return_status                 varchar2(1);
  x_msg_count                 number;
  x_msg_data                      varchar2(8000);

        -- <FPJ Costing CST_EAM API START>
  l_category_id         NUMBER;
        -- <FPJ Costing CST_EAM API END>

begin

  x_progress := 'PO_WF_PO_CHARGE_ACC.job_wip: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_destination_organization_id := po_wf_util_pkg.GetItemAttrNumber (  itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                aname    => 'DESTINATION_ORGANIZATION_ID');

  x_bom_cost_element_id := po_wf_util_pkg.GetItemAttrNumber (  itemtype => itemtype,
                                                  itemkey  => itemkey,
                                              aname    => 'BOM_COST_ELEMENT_ID');

  x_wip_entity_id     :=  po_wf_util_pkg.GetItemAttrNumber (    itemtype => itemtype,
                                            itemkey  => itemkey,
                                        aname    => 'WIP_ENTITY_ID');

  x_wip_entity_type   :=  po_wf_util_pkg.GetItemAttrText (  itemtype => itemtype,
                                            itemkey  => itemkey,
                                        aname    => 'WIP_ENTITY_TYPE');

  -- <FPJ Costing CST_EAM API START>
  l_category_id     :=  po_wf_util_pkg.GetItemAttrNumber (    itemtype => itemtype,
                                            itemkey  => itemkey,
                                        aname    => 'CATEGORY_ID');
  -- <FPJ Costing CST_EAM API END>

  /* Start DEBUG
  If (debug_acc_generator_wf) then
    dbms_output.put_line ('Procedure PO_WF_PO_CHARGE_ACC.job_wip');
    dbms_output.put_line ('DESTINATION_ORGANIZATION_ID: ' || to_char(x_destination_organization_id));
    dbms_output.put_line ('BOM_COST_ELEMENT_ID: ' || to_char(x_bom_cost_element_id));
    dbms_output.put_line ('WIP_ENTITY_ID: ' || to_char(x_wip_entity_id));
    dbms_output.put_line ('WIP_ENTITY_TYPE: ' || x_wip_entity_type);
  end if;
  End DEBUG */

  x_progress := 'org_id:' || to_char(x_destination_organization_id) || 'bom_cost_element_id:' ||
    to_char(x_bom_cost_element_id) || 'wip_entity_id' || to_char(x_wip_entity_id) ||
    'wip_entity_type' || x_wip_entity_type ||
  -- <FPJ Costing CST_EAM API START>
    'l_category_id' || to_char(l_category_id);
  -- <FPJ Costing CST_EAM API END>

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

         --Bug# 1902716 togeorge 07/25/2001
         --EAM: if entity type in(6,7) get the eam account. This call is
   --     made from job_wip to avoid the impact on workflow.
   --On failure the API returns -1. So it is nullified for the check
   --at the end of this procedure.

         IF (x_wip_entity_type in (6,7)) THEN
            IF (x_wip_job_account IS NULL) THEN

-- bug 556021 : if the cost element is OSP then pick the OSP account.
               IF  (x_bom_cost_element_id LIKE '4') THEN

                    BEGIN
                        SELECT outside_processing_account
                        INTO x_wip_job_account
                        FROM WIP_DISCRETE_JOBS
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
                        AND   OUTSIDE_PROCESSING_ACCOUNT <> -1;
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                    END;

               ELSE
               -- <FPJ Costing CST_EAM API START>
                   IF (CST_VersionCtrl_GRP.Get_Current_Release_Level <
                       CST_Release_GRP.Get_J_Release_Level) THEN
                     -- Lower the J Release
                     CST_eamCost_PUB.get_Direct_Item_Charge_Acct(
                              p_api_version   => 1.0,
                              p_init_msg_list   => null,
                              p_commit    => null,
                              p_validation_level  => null,
                              p_wip_entity_id   => x_wip_entity_id,
                              x_material_acct   => x_wip_job_account,
                              x_return_status   => x_return_status,
                              x_msg_count   => x_msg_count,
                              x_msg_data    => x_msg_data);
                   ELSE
               -- J Release or higher
                     CST_Utility_PUB.get_Direct_Item_Charge_Acct(
                              p_api_version   => 1.0,
                              p_init_msg_list   => null,
                              p_commit    => null,
                              p_validation_level  => null,
                              p_wip_entity_id   => x_wip_entity_id,
                              x_material_acct   => x_wip_job_account,
                              x_return_status   => x_return_status,
                              x_msg_count   => x_msg_count,
                              x_msg_data    => x_msg_data,
                              p_category_id     => l_category_id);
                   END IF; /* IF (CST_VersionCtrl_GRP.Get_Current_Release_Level < */
               -- <FPJ Costing CST_EAM API END>
               END IF;  -- bug 556021

               IF (x_wip_job_account = -1) THEN
            x_wip_job_account := null;
         END IF;
            END IF;
   ELSE

         /* Bug - 2204214 - WIP has added more WIP ENTITY types for JOBS and hence
         checking for just 1 for a JOB is not valid and does not build the account.
         Changed all the where clauses in the below sqls to check for 1, 3, 4 , 5  */

            IF (x_wip_job_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '5') THEN
                    BEGIN
                        SELECT OVERHEAD_ACCOUNT INTO x_wip_job_account
                        FROM WIP_DISCRETE_JOBS
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   OVERHEAD_ACCOUNT <> -1
      AND   NVL(x_wip_entity_type,'2') in ('1', '3', '4', '5'));
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;
            IF (x_wip_job_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '4') THEN
                    BEGIN
                        SELECT outside_processing_account INTO x_wip_job_account
                        FROM WIP_DISCRETE_JOBS
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   OUTSIDE_PROCESSING_ACCOUNT <> -1
      AND   NVL(x_wip_entity_type,'2') in ('1', '3', '4', '5'));
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;
            IF (x_wip_job_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '3') THEN
                    BEGIN
                        SELECT RESOURCE_ACCOUNT INTO x_wip_job_account
                        FROM WIP_DISCRETE_JOBS
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID     = NVL(x_wip_entity_id,-99)
      AND   RESOURCE_ACCOUNT <> -1
      AND   NVL(x_wip_entity_type,'2') in ('1', '3', '4', '5'));
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;
            IF (x_wip_job_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '2') THEN
                    BEGIN
                        SELECT MATERIAL_OVERHEAD_ACCOUNT INTO x_wip_job_account
                        FROM WIP_DISCRETE_JOBS
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   MATERIAL_OVERHEAD_ACCOUNT <> -1
      AND   NVL(x_wip_entity_type,'2') in ('1', '3', '4', '5'));
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;
            IF (x_wip_job_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '1') THEN
                    BEGIN
                        SELECT MATERIAL_ACCOUNT INTO x_wip_job_account
                        FROM WIP_DISCRETE_JOBS
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   MATERIAL_ACCOUNT <> -1
      AND   NVL(x_wip_entity_type,'2') in ('1', '3', '4', '5'));
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;
            IF (x_wip_job_account IS NULL) THEN
                BEGIN
                    SELECT FLEX_VALUE INTO x_wip_job_account
                    FROM FND_FLEX_VALUES_VL
                    WHERE FLEX_VALUE = x_destination_organization_id
                    AND (FLEX_VALUE_SET_ID = 102256);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
            END IF;
         END IF;

   x_progress := 'WIP_JOB_ACCOUNT is :' || to_char(x_wip_job_account);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if (x_wip_job_account IS NOT NULL) then

  po_wf_util_pkg.SetItemAttrText  (  itemtype=>itemtype,
                                itemkey=>itemkey,
                                aname=>'TEMP_ACCOUNT_ID',
                                avalue=>x_wip_job_account );
  result := 'COMPLETE:SUCCESS';
  else
  result := 'COMPLETE:FAILURE';
  end if;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_CHARGE_ACC','job_wip',x_progress);
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, 'EXCEPTION IN PO_WF_PO_CHARGE_ACC.JOB_WIP');
    END IF;
        raise;

end job_wip;

-- * ****************************************************************************** *

--
-- Schedule
--
procedure schedule ( itemtype        in  varchar2,
               itemkey         in  varchar2,
               actid           in number,
                     funcmode        in  varchar2,
                     result          out NOCOPY varchar2    )
is
  x_wip_entity_type   varchar2(80);
  x_wip_schedule_account        NUMBER := NULL;
  x_wip_entity_id         NUMBER;
  x_bom_cost_element_id       NUMBER;
  x_destination_organization_id   NUMBER;
  x_wip_repetitive_schedule_id    NUMBER;
  x_progress                    varchar2(200);
begin

  x_progress := 'PO_WF_PO_CHARGE_ACC.schedule: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_destination_organization_id := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                   aname    => 'DESTINATION_ORGANIZATION_ID');

  x_bom_cost_element_id := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                              aname    => 'BOM_COST_ELEMENT_ID');

  x_wip_entity_id     :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                        aname    => 'WIP_ENTITY_ID');

  x_wip_entity_type   :=  po_wf_util_pkg.GetItemAttrText (    itemtype => itemtype,
                                            itemkey  => itemkey,
                                        aname    => 'WIP_ENTITY_TYPE');

  x_wip_repetitive_schedule_id   :=  po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                                itemkey  => itemkey,
                                            aname    => 'WIP_REPETITIVE_SCHEDULE_ID');

  /* Start DEBUG
  If (debug_acc_generator_wf) then
    dbms_output.put_line ('Procedure PO_WF_PO_CHARGE_ACC.Schedule');
    dbms_output.put_line ('DESTINATION_ORGANIZATION_ID: ' || to_char(x_destination_organization_id));
    dbms_output.put_line ('BOM_COST_ELEMENT_ID: ' || to_char(x_bom_cost_element_id));
    dbms_output.put_line ('WIP_ENTITY_ID: ' || to_char(x_wip_entity_id));
    dbms_output.put_line ('WIP_ENTITY_TYPE: ' || x_wip_entity_type);
    dbms_output.put_line ('WIP_REPETITIVE_SCHEDULE_ID: ' || to_char(x_wip_repetitive_schedule_id));
  end if;
  End DEBUG */

  x_progress := 'org_id:' || to_char(x_destination_organization_id) || 'bom_cost_element_id:' ||
    to_char(x_bom_cost_element_id) || 'wip_entity_id' || to_char(x_wip_entity_id) ||
    'wip_entity_type' || x_wip_entity_type || 'wip_repetitive_schedule_id' ||
    to_char(x_wip_repetitive_schedule_id);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


            IF (x_wip_schedule_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '5') THEN
                    BEGIN
                        SELECT OVERHEAD_ACCOUNT INTO x_wip_schedule_account
                        FROM WIP_REPETITIVE_SCHEDULES
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   '2' = NVL(x_wip_entity_type,'1')
      AND   REPETITIVE_SCHEDULE_ID = NVL(x_wip_repetitive_schedule_id,-99)
      AND   OVERHEAD_ACCOUNT <> -1);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;

            IF (x_wip_schedule_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '4') THEN
                    BEGIN
                        SELECT OUTSIDE_PROCESSING_ACCOUNT INTO x_wip_schedule_account
                        FROM WIP_REPETITIVE_SCHEDULES
                        WHERE ORGANIZATION_ID = TO_NUMBER(x_destination_organization_id)
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   '2' = NVL(x_wip_entity_type,'1')
      AND   REPETITIVE_SCHEDULE_ID = NVL(x_wip_repetitive_schedule_id,-99)
      AND   OUTSIDE_PROCESSING_ACCOUNT <> -1);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;
            IF (x_wip_schedule_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '3') THEN
                    BEGIN
                        SELECT RESOURCE_ACCOUNT INTO x_wip_schedule_account
                        FROM WIP_REPETITIVE_SCHEDULES
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   '2'           = NVL(x_wip_entity_type,'1')
      AND   REPETITIVE_SCHEDULE_ID = NVL(x_wip_repetitive_schedule_id,-99)
      AND  RESOURCE_ACCOUNT <> -1) ;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;

            IF (x_wip_schedule_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '2') THEN
                    BEGIN
                        SELECT MATERIAL_OVERHEAD_ACCOUNT INTO x_wip_schedule_account
                        FROM WIP_REPETITIVE_SCHEDULES
                        WHERE ORGANIZATION_ID = TO_NUMBER(x_destination_organization_id)
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   '2'           = NVL(x_wip_entity_type,'1')
      AND   REPETITIVE_SCHEDULE_ID = NVL(x_wip_repetitive_schedule_id,-99)
      AND   MATERIAL_OVERHEAD_ACCOUNT <> -1);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;

            IF (x_wip_schedule_account IS NULL) THEN
                IF (x_bom_cost_element_id LIKE '1') THEN
                    BEGIN
                        SELECT MATERIAL_ACCOUNT INTO x_wip_schedule_account
                        FROM WIP_REPETITIVE_SCHEDULES
                        WHERE ORGANIZATION_ID = x_destination_organization_id
                        AND  (WIP_ENTITY_ID = NVL(x_wip_entity_id,-99)
      AND   '2'           = NVL(x_wip_entity_type,'2')
      AND   REPETITIVE_SCHEDULE_ID = NVL(x_wip_repetitive_schedule_id,-99)
      AND   MATERIAL_ACCOUNT <> -1);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            NULL;
                    END;
                END IF;
            END IF;
            IF (X_WIP_SCHEDULE_ACCOUNT IS NULL) THEN
                BEGIN
                    SELECT FLEX_VALUE INTO x_wip_schedule_account
                    FROM FND_FLEX_VALUES_VL
                    WHERE FLEX_VALUE = x_destination_organization_id
                    AND (FLEX_VALUE_SET_ID = 102256);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
            END IF;

   x_progress := 'WIP_JOB_ACCOUNT is :' || to_char(x_wip_schedule_account);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if (x_wip_schedule_account IS NOT NULL) then

  po_wf_util_pkg.SetItemAttrText  (   itemtype=>itemtype,
                                  itemkey=>itemkey,
                                  aname=>'TEMP_ACCOUNT_ID',
                                  avalue=>x_wip_schedule_account );
  result := 'COMPLETE:SUCCESS';
  else
  result := 'COMPLETE:FAILURE';
  end if;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_CHARGE_ACC','schedule',x_progress);
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey, 'EXCEPTION IN PO_WF_PO_CHARGE_ACC.SCHEDULE');
    END IF;
        raise;

end schedule;

--

--
-- is_encumbrance_on
--

procedure is_encumbrance_on   (  itemtype        in  varchar2,
                              itemkey         in  varchar2,
                        actid           in number,
                              funcmode        in  varchar2,
                              result          out NOCOPY varchar2    )
is
  po_encumbrance_flag varchar2(4);
  x_destination_type  varchar2(25);
  l_is_financing_flag varchar2(4); --<Complex Work R12>
  l_is_advance_flag varchar2(4); --<Complex Work R12>
  x_progress              varchar2(200);

  l_purch_encumbrance_flag VARCHAR2(10);
  l_req_encumbrance_flag VARCHAR2(10);
  x_wip_entity_type NUMBER;

begin

  x_progress := 'PO_WF_PO_CHARGE_ACC.is_encumbrance_on: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  po_encumbrance_flag   :=  po_wf_util_pkg.GetItemAttrText (  itemtype => itemtype,
                                               itemkey  => itemkey,
                                           aname    => 'PO_ENCUMBRANCE_FLAG');

  x_destination_type := po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                            aname    => 'DESTINATION_TYPE_CODE');

  --<Complex Work R12>: added check for financing_flag and advance_flag in the
  --setting of result below.  if either flag is set to 'Y', then this is a PREPAYMENT
  --type distribution and we do not encumber it.
  l_is_financing_flag := po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                            aname    => 'IS_FINANCING_DISTRIBUTION');

  l_is_advance_flag := po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                          itemkey  => itemkey,
                                            aname    => 'IS_ADVANCE_DISTRIBUTION');

  -- Bug 5058123 Start: This code is shared between Req and PO Account Generators.
  -- The new R12 Complex Work attributes are not defined in Req AG WF. So we would
  -- get NULL for these attribute values for requisition case. Set them to 'N'.
  -- We do not want to compare the item_type to 'POWFRQAG' (i.e. seeded Req AG WF)
  -- because the item_types are not hard-coded and customers may change them.
  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'po_encumbrance_flag='||po_encumbrance_flag||', x_destination_type='||x_destination_type||', l_is_financing_flag='||l_is_financing_flag||', l_is_advance_flag='||l_is_advance_flag);

    -- DEBUG QUERIES: Start
    -- As part of bug 5058123, there was another issue related to MOAC setup
    -- of MO: Security Profile. The value of PO_ENCUMBRANCE_FLAG was NULL.
    -- Bug 4932685 had similar symptoms. In both cases, the bug stopped
    -- getting reproduced after couple of days, and we could not get to the
    -- root cause. The following queries are put in to record some debug values
    -- that will help get to the root cause if the issue appears again.
    --   I suspect that the values loaded in PO_STARTUP_VALUES are NULL in
    -- PO_CORE_S.get_po_parameters() [POXCOC1B.pls]. The following queries should
    -- get us moe information.
    --   Remove this DEBUG QUERIES block, once the MOAC issue is completely fixed.
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'org_id from PO_MOAC='||PO_MOAC_UTILS_PVT.get_current_org_id||', org_id from PO_GA_PVT='||PO_GA_PVT.get_current_org );
    -- Query from: PO_CORE_S.get_po_parameters() [POXCOC1B.pls].
    SELECT  nvl(fsp.purch_encumbrance_flag,'N'),
            nvl(fsp.req_encumbrance_flag,'N')
    INTO    l_purch_encumbrance_flag,
            l_req_encumbrance_flag
    FROM    financials_system_parameters fsp,
            gl_sets_of_books sob,
            po_system_parameters psp,
	  rcv_parameters  rcv
    WHERE   fsp.set_of_books_id = sob.set_of_books_id
    AND     rcv.organization_id (+) = fsp.inventory_organization_id;

    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'PO_CORE_S: l_purch_encumbrance_flag='||l_purch_encumbrance_flag||', l_req_encumbrance_flag='||l_req_encumbrance_flag);

    SELECT purch_encumbrance_flag,
           req_encumbrance_flag
    INTO l_purch_encumbrance_flag,
         l_req_encumbrance_flag
    FROM FINANCIALS_SYSTEM_PARAMETERS; -- view

    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'View: l_purch_encumbrance_flag='||l_purch_encumbrance_flag||', l_req_encumbrance_flag='||l_req_encumbrance_flag);

    SELECT purch_encumbrance_flag,
           req_encumbrance_flag
    INTO l_purch_encumbrance_flag,
         l_req_encumbrance_flag
    FROM FINANCIALS_SYSTEM_PARAMS_ALL -- table
    WHERE org_id = PO_MOAC_UTILS_PVT.get_current_org_id;

    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'Table: MOAC: l_purch_encumbrance_flag='||l_purch_encumbrance_flag||', l_req_encumbrance_flag='||l_req_encumbrance_flag);

    SELECT purch_encumbrance_flag,
           req_encumbrance_flag
    INTO l_purch_encumbrance_flag,
         l_req_encumbrance_flag
    FROM FINANCIALS_SYSTEM_PARAMS_ALL -- table
    WHERE org_id = PO_GA_PVT.get_current_org;

    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'Table: PO_GA_PVT: l_purch_encumbrance_flag='||l_purch_encumbrance_flag||', l_req_encumbrance_flag='||l_req_encumbrance_flag);
    -- DEBUG QUERIES: End
  END IF;

  IF (l_is_financing_flag IS NULL) THEN
    l_is_financing_flag := 'N';
  END IF;

  IF (l_is_advance_flag IS NULL) THEN
    l_is_advance_flag := 'N';
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'After: l_is_financing_flag='||l_is_financing_flag||', l_is_advance_flag='||l_is_advance_flag);
  END IF;
  -- Bug 5058123: End


 /* For Encumbrance Project - To enable Encumbrance for Destination type Shop Floor and WIP entity type EAM   */

	x_wip_entity_type := po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                                              itemkey  => itemkey,
                                                               aname    => 'WIP_ENTITY_TYPE');


  if (po_encumbrance_flag = 'Y' and (x_destination_type <> 'SHOP FLOOR' OR (x_destination_type = 'SHOP FLOOR' AND x_wip_entity_type = 6 ))
         /* Condition added for Encumbrance Project */
      AND l_is_financing_flag <> 'Y' AND l_is_advance_flag <> 'Y') then
  result := 'COMPLETE:TRUE';
  else
  result := 'COMPLETE:FALSE';
  end if;

  x_progress := 'PO_WF_PO_CHARGE_ACC.is_encumbrance_on: result = ' || result;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_CHARGE_ACC','is_encumbrace_on',x_progress);
        raise;

end is_encumbrance_on;

--

-- * ****************************************************************************** *
-- * ****************************************************************************** *

--
-- is_po_project_related
--
-- This is a dummy function that should be replaced by the customized function
-- activity in the workflow that return TRUE or FALSE based on whether you want to
-- use the default PO expense charge account generation rules or use "CUSTOMIZED"
-- project accounting rules.

procedure is_po_project_related      (  itemtype        in  varchar2,
                                      itemkey         in  varchar2,
                          actid           in number,
                                funcmode        in  varchar2,
                                result          out NOCOPY varchar2    )
is
begin

  result := 'COMPLETE:F';
  return;

end is_po_project_related;


/*
    * Set the debug mode on
*/

PROCEDURE debug_on IS
BEGIN
        debug_acc_generator_wf := TRUE;

END debug_on;

/*
    * Set the debug mode off
*/

PROCEDURE debug_off IS
BEGIN
        debug_acc_generator_wf := FALSE;

END debug_off;

--< Shared Proc FPJ Start >

---------------------------------------------------------------------------
--Start of Comments
--Name: is_dest_accounts_flow_type
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  The PO Account Generator could be run 2 times -- first to generate the
--  PO Accounts and second time to generate the DESTINATION accounts. The
--  calling program specifies the flow type in the WF item attribute
--  called ACCOUNT_GENERATION_FLOW_TYPE.
--  The flow could take either of the following 2 values:
--    1. PO_WF_BUILD_ACCOUNT_INIT.g_po_accounts          (PO_ACCOUNTS)
--    2. PO_WF_BUILD_ACCOUNT_INIT.g_destination_accounts (DESTINATION_ACCOUNTS)
--  This function determines if the flow type specified by the calling
--  program is for the Destination Accounts or not.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter of type 'Yes/No'.
--Testing:
--
--Notes:
--  We could have used the standard WF activity COMPARE_TEXT for this
--  purpose, but it is not as readable because on the workflow diagram
--  we would see just 'Compare Text' written beneath the activity. To find
--  out what it is exactly being compared, we would have to go to the 'Node
--  Attribute' tab of that activity and inspect the item attributes. Also,
--  we would have had to hard-code the value being compared there. In this
--  function, we can use the global variable
--  'PO_WF_BUILD_ACCOUNT_INIT.g_po_accounts' instead of the hard coded value.
--End of Comments
---------------------------------------------------------------------------
PROCEDURE is_dest_accounts_flow_type
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result   OUT NOCOPY VARCHAR2
)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_account_gen_flow_type VARCHAR2(25);
BEGIN
  l_progress := '010';

  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_progress := '020';

  l_account_gen_flow_type := PO_WF_UTIL_PKG.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'ACCOUNT_GENERATION_FLOW_TYPE');

  l_progress := '030';

  IF (l_account_gen_flow_type IS NULL OR
    l_account_gen_flow_type = PO_WF_BUILD_ACCOUNT_INIT.g_po_accounts)
  THEN
    result := WF_ENGINE.eng_completed || ':N';
  ELSE
    result := WF_ENGINE.eng_completed || ':Y';
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
             'PO_WF_PO_CHARGE_ACC.is_dest_accounts_flow_type result='||result);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_CHARGE_ACC', 'is_dest_accounts_flow_type',
                    l_progress);
    RAISE;
END is_dest_accounts_flow_type;

---------------------------------------------------------------------------
--Start of Comments
--Name: is_SPS_distribution
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Determines if it is a Shared Procurement Services (SPS) distribution.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter of type 'Yes/No'.
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE is_SPS_distribution
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result   OUT NOCOPY VARCHAR2
)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_is_SPS_distribution VARCHAR2(1);
BEGIN
  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_progress := '010';
  l_is_SPS_distribution := PO_WF_UTIL_PKG.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'IS_SPS_DISTRIBUTION');

  l_progress := '020';
  IF (l_is_SPS_distribution IS NULL) THEN
    result := WF_ENGINE.eng_completed || ':N';
  ELSE
    result := WF_ENGINE.eng_completed || ':' || l_is_SPS_distribution;
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'PO_WF_PO_CHARGE_ACC.is_SPS_distribution result='||result);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_CHARGE_ACC', 'is_SPS_distribution', l_progress);
    RAISE;
END is_SPS_distribution;

---------------------------------------------------------------------------
--Start of Comments
--Name: is_shopfloor_enabled_item
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Determines if a given item is enabled for shopfloor (outside processing)
--  in the given Inventory Org
--Parameters:
--IN:
--  p_item_id
--   : The given item's ID
--  p_inv_org_id
--   : The org ID of the Inventory Org where the item's attribute need to be
--     tested.
--OUT:
--  None.
--RETURN
--  BOOLEAN: TRUE if the item is shopfloor enables, FALSE otherwise.
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION is_shopfloor_enabled_item(p_item_id IN NUMBER,
                                   p_inv_org_id IN NUMBER) RETURN BOOLEAN
IS
  is_shopfloor_enabled_item MTL_SYSTEM_ITEMS.outside_operation_flag%TYPE;
BEGIN
  --SQL WHAT: Get the outside_operation_flag for a given item
  --SQL WHY:  To find out if the item is Shopfloor enabled.
  SELECT outside_operation_flag  -- it is a NOT NULL column
  INTO is_shopfloor_enabled_item
  FROM MTL_SYSTEM_ITEMS
  WHERE inventory_item_id = p_item_id AND
        organization_id = p_inv_org_id;

  IF (is_shopfloor_enabled_item = 'Y') THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    RAISE;
END is_shopfloor_enabled_item;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_COGS_account
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Gets the Cost of Goods Sold (COGS) account associated with the intermediate
--  Logical Inventory Org for the POU.
--Parameters:
--IN:
--  p_inv_org_id IN NUMBER
--    : The Org ID of the Logical Inv Org associated with a Transaction Flow
--OUT:
--  None
--RETURN
--  NUMBER
--    : The Cost of Goods Sold Account for the LINV.
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_COGS_account(p_inv_org_id IN NUMBER) RETURN NUMBER
IS
  l_COGS_account_id GL_CODE_COMBINATIONS.code_combination_id%TYPE := NULL;
BEGIN
  --SQL WHAT: Get the Get the COGS account for the Logical Inventory Org
  --          associated with an OU for a given Transaction Flow.
  --SQL WHY:  Default as the PO Charge Account for SPS case
  SELECT cost_of_sales_account
  INTO l_COGS_account_id
  FROM MTL_PARAMETERS
  WHERE ORGANIZATION_ID = p_inv_org_id;

  RETURN l_COGS_account_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END get_COGS_account;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_item_expense_account
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Gets the Expense Account associated with a given inventory item.
--Parameters:
--IN:
--  p_item_id IN NUMBER
--   : The given item id
--  p_inv_org_id IN NUMBER
--   : The inventory org id to which the item belongs
--OUT:
--  None
--RETURN
--  NUMBER
--   : The Expense Account associated with the given inventory item.
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_item_expense_account(p_item_id IN NUMBER,
                                  p_inv_org_id IN NUMBER)
RETURN NUMBER
IS
  l_item_expense_account_id GL_CODE_COMBINATIONS.code_combination_id%TYPE;
BEGIN
  --SQL WHAT: Get the Expense Account associated with an item in the Logical
  --          Inventory Org for a Start OU for a given Transaction Flow.
  --SQL WHY:  To default this as the PO Expense Account for SPS case
  SELECT expense_account
  INTO l_item_expense_account_id
  FROM MTL_SYSTEM_ITEMS
  WHERE organization_id = p_inv_org_id AND
        inventory_item_id = p_item_id;

  RETURN l_item_expense_account_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END get_item_expense_account;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_org_expense_account
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Gets the Expense Account associated with a given inventory org.
--Parameters:
--IN:
--  p_inv_org_id IN NUMBER
--   : The given inventory org id
--OUT:
--  None
--RETURN
--  NUMBER
--   : The Expense Account associated with the given inventory org.
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_org_expense_account(p_inv_org_id IN NUMBER)
RETURN NUMBER
IS
  l_org_expense_account_id GL_CODE_COMBINATIONS.code_combination_id%TYPE;
BEGIN
  --SQL WHAT: Get the Expense Account associated with the Logical
  --          Inventory Org for a Start OU for a given Transaction Flow.
  --SQL WHY:  To default this as the PO Expense Account for SPS case
  SELECT expense_account
  INTO l_org_expense_account_id
  FROM MTL_PARAMETERS
  WHERE organization_id = p_inv_org_id;

  RETURN l_org_expense_account_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END get_org_expense_account;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_org_material_account
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Gets the Material Account associated with a given inventory org.
--Parameters:
--IN:
--  p_inv_org_id IN NUMBER
--   : The given inventory org id
--OUT:
--  None
--RETURN
--  NUMBER
--   : The Material Account associated with the given inventory org.
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_org_material_account(p_inv_org_id IN NUMBER)
RETURN NUMBER
IS
  l_org_material_account_id GL_CODE_COMBINATIONS.code_combination_id%TYPE;
BEGIN
  --SQL WHAT: Get the Material Account associated with the Logical
  --          Inventory Org for a Start OU for a given Transaction Flow.
  --SQL WHY:  To default this as the PO Expense Account for SPS case
  SELECT material_account
  INTO l_org_material_account_id
  FROM MTL_PARAMETERS
  WHERE organization_id = p_inv_org_id;

  RETURN l_org_material_account_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END get_org_material_account;

---------------------------------------------------------------------------
--Start of Comments
--Name: sanity_check_logical_inv_org
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This function gets executed in DEBUG MODE ONLY.
--  The purpose of this function is to perform a sanity check on the Logical
--  Inventory Org that is derived from the MTL_TRANSATION_FLOW_LINES table.
--  Since this a new table with a brand new functionality of Transaction Flows,
--  and since this table belongs to a group outside of Procurement Family, we
--  should make sure that the Logical Inventory Org (LINV) derived from this
--  table is correct.
--     Here we check if the LINV actually belong to the POU, as it should.
--  This function merely inserts debug comments in PO debug tables.
--
--Parameters:
--IN:
--  p_logical_inv_org_id IN NUMBER
--   : The logical inventory org id, derived from MTL table.
--  p_itemtype IN VARCHAR2
--   : The item type of the current AG workflow
--  p_itemkey IN VARCHAR2
--   : The item key of the current AG workflow
--
--OUT:
--  None
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE sanity_check_logical_inv_org(p_logical_inv_org_id IN NUMBER,
                                       p_itemtype IN VARCHAR2,
                                       p_itemkey IN VARCHAR2)
IS
  l_temp_ou_id NUMBER;
  l_purchasing_ou_id NUMBER;
BEGIN
  IF (g_po_wf_debug = 'Y') THEN
    BEGIN
      SELECT operating_unit
      INTO l_temp_ou_id
      FROM org_organization_definitions
      WHERE organization_id = p_logical_inv_org_id;

      l_purchasing_ou_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                      itemtype => p_itemtype,
                                      itemkey  => p_itemkey,
                                      aname    => 'PURCHASING_OU_ID');

      IF (l_temp_ou_id <> l_purchasing_ou_id) THEN
        PO_WF_DEBUG_PKG.insert_debug(p_itemtype, p_itemkey,
                                     'LINV does not belong to POU');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- record and ignore the exception, this is just debug code.
        PO_WF_DEBUG_PKG.insert_debug(p_itemtype, p_itemkey,
                                     'Exception while sanity checking LINV');
    END;
  END IF; -- IF (g_po_wf_debug = 'Y'), sanity check for LINV
END sanity_check_logical_inv_org;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_SPS_charge_account
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: TEMP_ACCOUNT_ID
--Locks:
--  None.
--Function:
--  Gets the PO Charge Account for SPS case.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE get_SPS_charge_account
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result   OUT NOCOPY VARCHAR2
)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_item_id NUMBER;
  l_transaction_flow_header_id NUMBER;
  l_logical_inv_org_id NUMBER;
  l_SPS_charge_account_id NUMBER := NULL;
  l_item_inventory_type VARCHAR2(10);
BEGIN
  l_progress := '010';

  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_progress := '020';
  l_item_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'ITEM_ID');

  l_progress := '030';
  l_transaction_flow_header_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'TRANSACTION_FLOW_HEADER_ID');

  l_progress := '040';

  -- Get the org id for the Logical Inventory Org associated with
  -- the given Transaction Flow. This LINV would belong to the POU.
  l_logical_inv_org_id := PO_SHARED_PROC_PVT.get_logical_inv_org_id(l_transaction_flow_header_id);

  l_progress := '050';
  IF (l_logical_inv_org_id IS NULL) THEN
    l_progress := 'Logical Inventory Org Not Found';
    APP_EXCEPTION.raise_exception(exception_type => 'GET_LOGICAL_INV_ORG_ID',
                                  exception_code => 0,
                                  exception_text => l_progress);
  END IF;

  l_progress := '060';
  -- Sanity check. Does LINV belong to POU?
  -- Check this in debug mode only.
  sanity_check_logical_inv_org(l_logical_inv_org_id,
                               itemtype,
                               itemkey);

  l_progress := '070';
  -- 1. If one-time item or shopfloor enabled item, get COGS account
  IF ( (l_item_id IS NULL) OR
       (is_shopfloor_enabled_item(l_item_id,
                                  l_logical_inv_org_id)) ) THEN
    l_SPS_charge_account_id := get_COGS_account(l_logical_inv_org_id);

  ELSE -- else if NOT a one-time or shopfloor enabled item --(

    l_progress := '080';
    -- Get the Inventory Item Type of the given item in the given LINV.
    IF (check_inv_item_type(itemtype,
                            itemkey,
                            l_logical_inv_org_id,
                            l_item_id) = 'EXPENSE') THEN
      l_item_inventory_type := 'EXPENSE';
    ELSE
      l_item_inventory_type := 'ASSET';
    END IF;

    l_progress := '090';
    -- 2a. If Expense Item, get Item Expense Account
    IF ( (l_SPS_charge_account_id IS NULL) AND
         (l_item_inventory_type = 'EXPENSE') ) THEN
      l_progress := '100';
      l_SPS_charge_account_id := get_item_expense_account(l_item_id,
                                                          l_logical_inv_org_id);

      l_progress := '110';
      -- 2b. If Expense Item, get Org Expense Account
      IF (l_SPS_charge_account_id IS NULL) THEN
        l_SPS_charge_account_id := get_org_expense_account(l_logical_inv_org_id);
      END IF;
    END IF;

    l_progress := '120';
    -- 3. If Asset Item, get Org Material Account
    IF ( (l_SPS_charge_account_id IS NULL) AND
         (l_item_inventory_type = 'ASSET') ) THEN
      l_SPS_charge_account_id := get_org_material_account(l_logical_inv_org_id);
    END IF;

    l_progress := '130';
    IF (l_SPS_charge_account_id IS NULL) THEN
      result := WF_ENGINE.eng_completed || ':FAILURE';
      RETURN;
    END IF;
  END IF; -- IF (l_item_id IS NULL) OR
          --    (is_shopfloor_enabled_item(l_item_id, l_logical_inv_org_id)) --)

  l_progress := '140';
  PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TEMP_ACCOUNT_ID',
                              avalue   => l_SPS_charge_account_id);

  l_progress := '150';
  result := WF_ENGINE.eng_completed || ':SUCCESS';

  l_progress := '160';

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'PO_WF_PO_CHARGE_ACC.get_SPS_charge_account result='||result);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_CHARGE_ACC.get_SPS_charge_account l_SPS_charge_account_id='||
         l_SPS_charge_account_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
        'PO_WF_PO_CHARGE_ACC.get_SPS_charge_account EXCEPTION at '|| l_progress);
    END IF;
    WF_CORE.context('PO_WF_PO_CHARGE_ACC', 'get_SPS_charge_account', l_progress);
    RAISE;
END get_SPS_charge_account;

---------------------------------------------------------------------------
--Start of Comments
--Name: is_dest_charge_acc_null
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: TEMP_ACCOUNT_ID
--Locks:
--  None.
--Function:
--  Checks if the attribute DEST_CHARGE_ACCOUNT_ID is NULL or not.
--  If it is NULL, it returns 'N'.
--  If it is not NULL, it copies the value in DEST_CHARGE_ACCOUNT_ID to
--  TEMP_ACCOUNT_ID and returns 'Y'.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE is_dest_charge_acc_null
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result   OUT NOCOPY VARCHAR2
)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_dest_charge_account_id GL_CODE_COMBINATIONS.code_combination_id%TYPE;
  l_temp_acc_id GL_CODE_COMBINATIONS.code_combination_id%TYPE;
BEGIN
  l_progress := '010';

  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_progress := '020';
  l_dest_charge_account_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'DEST_CHARGE_ACCOUNT_ID');

  l_progress := '030';
  IF l_dest_charge_account_id IS NULL OR
     l_dest_charge_account_id = 0 OR
     l_dest_charge_account_id = -1 THEN
    result := WF_ENGINE.eng_completed || ':Y';
  ELSE
    IF (g_po_wf_debug = 'Y') THEN
      l_temp_acc_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'TEMP_ACCOUNT_ID');

      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
        'PO_WF_PO_CHARGE_ACC.is_dest_charge_acc_null '||
        'Copying DestChargeAccId to TEMP_ACCOUNT_ID '||
        '(current val = ' || l_temp_acc_id || ') ' ||
        'dest_charge_account_id='||l_dest_charge_account_id);
    END IF;

    -- If the Dest Charge Account is not null (autocreate, or through
    -- Forms/PDOI), then copy it into the TEMP_ACCOUNT_ID.
    l_progress := '040';
    PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TEMP_ACCOUNT_ID',
                                avalue   => l_dest_charge_account_id);
    l_progress := '050';
    result := WF_ENGINE.eng_completed || ':N';
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
        'PO_WF_PO_CHARGE_ACC.is_dest_charge_acc_null result='||result||
        ' l_dest_charge_account_id='||l_dest_charge_account_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_CHARGE_ACC', 'is_dest_charge_acc_null',
                    l_progress);
    RAISE;
END is_dest_charge_acc_null;


---------------------------------------------------------------------------
--Start of Comments
--Name: are_COAs_same
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Determines if the Chart of Accounts (COA's) of the POU and the DOU are
--  the same or not.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE are_COAs_same
(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result   OUT NOCOPY VARCHAR2
)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_pou_coa_id GL_CODE_COMBINATIONS.chart_of_accounts_id%TYPE;
  l_ship_to_ou_coa_id GL_CODE_COMBINATIONS.chart_of_accounts_id%TYPE;
  l_is_sps_distribution VARCHAR2(10);  --<BUG 4882220>
BEGIN
  l_progress := '010';

  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  --<BUG 4882220 START>
  -- Return immediately if this is not an SPS distribution.
  --
  l_progress := '015';
  l_is_sps_distribution := PO_WF_UTIL_PKG.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'IS_SPS_DISTRIBUTION' );

  IF nvl( l_is_sps_distribution, 'N' ) = 'N' THEN
    result := WF_ENGINE.eng_completed || ':N';
    RETURN;
  END IF;
  --<BUG 4882220 END>

  l_progress := '020';
  l_pou_coa_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'CHART_OF_ACCOUNTS_ID');

  l_progress := '030';
  -- Use the wrapper because it is a new attribute
  l_ship_to_ou_coa_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'SHIP_TO_OU_COA_ID');

  l_progress := '040';
  IF (l_ship_to_ou_coa_id IS NULL) OR
     (l_ship_to_ou_coa_id <> l_pou_coa_id) THEN
    result := WF_ENGINE.eng_completed || ':N';
  ELSE
    result := WF_ENGINE.eng_completed || ':Y';
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'PO_WF_PO_CHARGE_ACC.are_COAs_same result='||result);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_CHARGE_ACC', 'are_COAs_same',
                    l_progress);
    RAISE;
END are_COAs_same;

--< Shared Proc FPJ End >

--Bug4033391 Start
--In the account generator, all the accounts are validated using the activity
--FND_FLEX_VALIDATE_COMBINATION, which applies the security rule irrespective
--of whether the account is entered by the user or derived.
--Security rules should be only be applied for the user entered accounts.
--This is fixed by setting the responsibility_id of the context to null
--before calling validation and resetting the same after validation.
-------------------------------------------------------------------------------
--Start of Comments
--Name: set_null_resp_id
--Pre-reqs:
-- None.
--Modifies:
-- None
--Locks:
-- None.
--Function:
-- Sets the responsibility ID to NULL
 --End of Comments
-----------------------------------------------------------------------------
PROCEDURE set_null_resp_id(itemtype IN  VARCHAR2,
                     itemkey  IN  VARCHAR2,
                       actid    IN  NUMBER,
                           funcmode IN  VARCHAR2,
                     result   OUT NOCOPY VARCHAR2)
IS
l_progress varchar2(3);
BEGIN
  l_progress := '010';
  wf_engine.SetItemAttrNumber( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    =>'RESPONSIBILITY_ID',
                               avalue   => fnd_global.resp_id);
  l_progress := '020';
  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                  itemkey,
                                 'PO_WF_PO_CHARGE_ACC.set_null_resp_id: Setting the Responsibility to NULL ');
  END IF;
  FND_GLOBAL.apps_initialize( user_id      => fnd_global.user_id,
                              resp_id      => NULL,
                              resp_appl_id => fnd_global.resp_appl_id);
  l_progress := '030';
  result := WF_ENGINE.eng_completed || ':Y';
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_CHARGE_ACC','SET_NULL_RESP_ID',l_progress);
    raise;

END set_null_resp_id;

-------------------------------------------------------------------------------
--Start of Comments
--Name: reset_resp_id
--Pre-reqs:
--  None.
--Modifies:
-- None
--Locks:
--  None.
--Function:
-- Sets the responsibility ID back to original value
 --End of Comments
-----------------------------------------------------------------------------
PROCEDURE reset_resp_id(itemtype IN  VARCHAR2,
                    itemkey  IN  VARCHAR2,
                  actid    IN  NUMBER,
                  funcmode IN  VARCHAR2,
                  result   OUT NOCOPY VARCHAR2)
IS
l_progress varchar2(3);
l_resp_id FND_RESPONSIBILITY.responsibility_id%type;
BEGIN
  l_resp_id :=NULL;
  l_progress := '010';
  l_resp_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'RESPONSIBILITY_ID');
  l_progress := '020';
  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                  itemkey,
                                 'PO_WF_PO_CHARGE_ACC.reset_resp_id: Setting the Responsibility back to:' || l_resp_id);
  END IF;
  FND_GLOBAL.apps_initialize( user_id      => fnd_global.user_id,
                              resp_id      => l_resp_id,
                              resp_appl_id => fnd_global.resp_appl_id);
  l_progress := '030';
  result := WF_ENGINE.eng_completed || ':Y';
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_CHARGE_ACC','RESET_RESP_ID',l_progress);
    RAISE;
END reset_resp_id;
--Bug4033391 End

---------------------------------------------------------------------------
--Start of Comments
--Bug 7260456: Added this procedure.
--Name: validate_combination
--Pre-reqs:
--  FND_FLEX_WORKFLOW_APIS.VALIDATE_COMBINATION should be called to validate
--  standard validations. Workflow attributes FND_FLEX_STATUS,
--  CHART_OF_ACCOUNTS_ID, FND_FLEX_SEGMENTS, ENCUMBRANCE_DATE must be set.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This procedure checks for validations apart from
--  FND_FLEX_WORKFLOW_APIS.VALIDATE_COMBINATION and should be called just
--  after calling VALIDATE_COMBINATION.
--  This procedure has been created to validate for parent account and the
--  posting allowed flag.
--  The procedure is called from the account generator workflow, for
--  validating the accounts.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter.
--Testing:
--
--Notes:
--  This procedure has been created because the standard workflow API
--  FND_FLEX_WORKFLOW_APIS.VALIDATE_COMBINATION does not support VRULE.
--  Bug 7168777 has been logged for same.
--End of Comments
---------------------------------------------------------------------------
PROCEDURE validate_combination(
      itemtype  IN VARCHAR2,
      itemkey   IN VARCHAR2,
      actid     IN NUMBER,
      funcmode  IN VARCHAR2,
      result    OUT NOCOPY VARCHAR2)
IS
  l_progress              wf_item_activity_statuses.error_stack%TYPE;
  l_flex_status           VARCHAR2(100);
  l_concat_segments       VARCHAR2(2000);
  l_validation_date       DATE;
  l_coa_id                gl_code_combinations.chart_of_accounts_id%TYPE;
  l_is_combination_valid  BOOLEAN;

  --Bug9289679 (FP : 9541800 )
  l_account_gen_flow_type VARCHAR2(25);

BEGIN

  l_progress := '010';
  -- Do nothing in cancel or timeout mode
  IF (funcmode <> wf_engine.eng_run) THEN
    result := wf_engine.eng_null;
    RETURN;
  END IF;

  l_progress := '020';
  l_flex_status := po_wf_util_pkg.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'FND_FLEX_STATUS');

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
        'PO_WF_PO_CHARGE_ACC.validate_combination: l_flex_status='
        ||l_flex_status);
  END IF;

  -- Do nothing if FND_FLEX_STATUS is INVALID
  IF (l_flex_status = 'INVALID') THEN
    result := wf_engine.eng_null;
    RETURN;
  END IF;


  --Begin Bug9289679
  l_account_gen_flow_type := PO_WF_UTIL_PKG.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'ACCOUNT_GENERATION_FLOW_TYPE');


  IF (l_account_gen_flow_type IS NULL OR l_account_gen_flow_type = PO_WF_BUILD_ACCOUNT_INIT.g_po_accounts) THEN

    l_coa_id := po_wf_util_pkg.getitemattrtext(
                      itemtype => itemtype,
                      itemkey => itemkey,
                      aname => 'CHART_OF_ACCOUNTS_ID');

  ELSE

    l_coa_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                      itemtype => itemtype,
                      itemkey => itemkey,
                      aname => 'SHIP_TO_OU_COA_ID');

  END IF;
  --End Bug9289679

  l_concat_segments := po_wf_util_pkg.getitemattrtext(
        itemtype => itemtype,
        itemkey => itemkey,
        aname => 'FND_FLEX_SEGMENTS');

  l_validation_date := nvl(po_wf_util_pkg.getitemattrtext(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'ENCUMBRANCE_DATE'),
                           SYSDATE);
  gl_global.set_aff_validation('XX',null);
  l_progress := '030';
  -- Validate VRULE for the combination
  l_is_combination_valid := fnd_flex_keyval.validate_segs(
        operation => 'CHECK_COMBINATION',
        appl_short_name => 'SQLGL',
        key_flex_code => 'GL#',
        structure_number => l_coa_id,
        concat_segments => l_concat_segments,
        validation_date => l_validation_date,
        vrule => '\nSUMMARY_FLAG\nI' ||
                 '\nAPPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0' ||
                 'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nNAME=PO_ALL_POSTING_NA\nY');

  IF (NOT l_is_combination_valid) THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
          'PO_WF_PO_CHARGE_ACC.validate_combination: l_is_combination_valid is false');
    END IF;

    wf_engine.setitemattrtext(itemtype,itemkey,'FND_FLEX_STATUS','INVALID');
    wf_engine.setitemattrtext(itemtype,itemkey,'FND_FLEX_MESSAGE',
        fnd_flex_keyval.encoded_error_message);
    wf_engine.setitemattrtext(itemtype,itemkey,'FND_FLEX_CCID','0');
    wf_engine.setitemattrtext(itemtype,itemkey,'FND_FLEX_DATA','');
    wf_engine.setitemattrtext(itemtype,itemkey,'FND_FLEX_DESCRIPTIONS','');
    wf_engine.setitemattrtext(itemtype,itemkey,'FND_FLEX_NEW','N');
  END IF;

  result := wf_engine.eng_completed || ':' || wf_engine.eng_null;
END validate_combination;

END  PO_WF_PO_CHARGE_ACC;

/
