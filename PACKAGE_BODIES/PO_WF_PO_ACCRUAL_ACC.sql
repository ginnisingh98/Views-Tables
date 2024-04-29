--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_ACCRUAL_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_ACCRUAL_ACC" AS
/* $Header: POXWPAAB.pls 120.3.12010000.7 2010/07/09 09:43:40 vlalwani ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWPAAB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_WF_PO_ACCRUAL_ACC
 |
 | NOTES
 | MODIFIED    IMRAN ALI (09/08/97) - Created
 *=====================================================================*/


--
-- Check Destination Type
--
procedure destination_type ( itemtype        in  varchar2,
                             itemkey         in  varchar2,
	                     actid           in number,
                             funcmode        in  varchar2,
                             result          out NOCOPY varchar2    )
is
	x_progress              varchar2(100);
	x_destination_type	varchar2(25);
begin

  x_progress := 'PO_WF_PO_ACCRUAL_ACC.destination_type: 01';
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
    wf_core.context('PO_WF_PO_ACCRUAL_ACC','destination_type',x_progress);
        raise;
end destination_type;

-- * ****************************************************************************** *

--
-- AA_from_org
--
procedure AA_from_org      ( itemtype        in  varchar2,
                             itemkey         in  varchar2,
                    	     actid           in number,
                             funcmode        in  varchar2,
                             result          out NOCOPY varchar2    )
is
	x_progress              varchar2(100);
	x_account		number;
	x_dest_org_id		number;
     --Bug# 1902716 togeorge 07/25/2001
     --EAM: if item id is null get the accrual account from po_system_parameters
     --     (one time items can be delivered to shopfloor with eam)
	x_item_id		number;
     --
        --<INVCONV R12 START>
     	x_status		varchar2(1);
     	x_vendor_site_id	number;
	x_msg_data      varchar2(2000);
        x_msg_count     number;
        --<INVCONV R12 END>

	dummy   VARCHAR2(40);
	ret     BOOLEAN;
begin

  x_progress := 'PO_WF_PO_ACCRUAL_ACC.AA_from_org : 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_dest_org_id      := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                   	              itemkey  => itemkey,
                            	 	              aname    => 'DESTINATION_ORGANIZATION_ID');
  x_item_id      := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                   	          itemkey  => itemkey,
                            	 	          aname    => 'ITEM_ID');

  --Bug 7639037. Uday Phadtare. Commented call to GMF SLA API for process_org because currently
  --GMF_transaction_accounts_PUB.get_accounts is not getting the account as per SLA setup.
 /* --<INVCONV R12 START>
  --call SLA API instead of GML_ACCT_GENERATE
  if ( PO_GML_DB_COMMON.check_process_org(x_dest_org_id) = 'Y')
  then
	x_vendor_site_id :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'VENDOR_SITE_ID');
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).account_type_code := GMF_transaction_accounts_PUB.G_ACCRUAL_ACCT;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).item_type := '';
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).subinventory_type := '';
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).organization_id := x_dest_org_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).inventory_item_id := x_item_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).vendor_site_id := x_vendor_site_id;

	GMF_transaction_accounts_PUB.get_accounts(
                               p_api_version                     => 1.0,
				p_init_msg_list			 => dummy,
				p_source			 => 'PO',
				x_return_status                  => X_status,
				x_msg_data			 => x_msg_data,
				x_msg_count			 => x_msg_count);
	x_account := GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).target_ccid;

        --GML_ACCT_GENERATE.GENERATE_OPM_ACCT('ACCRUAL','', '', x_dest_org_id, x_item_id, x_vendor_site_id, x_account);
  	po_wf_util_pkg.SetItemAttrNumber  (  itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>x_account );
  ELSE
 */
  begin

     --Bug# 1902716 togeorge 07/25/2001
     --EAM: if item id is null get the accrual account from po_system_parameters
     --     (one time items can be delivered to shopfloor with eam)
     IF x_item_id is not null then
	select ap_accrual_account into x_account
	from mtl_parameters
	where organization_id     = x_dest_org_id;
     ELSE --treating it as an expense item.
	select accrued_code_combination_id into x_account
  	from po_system_parameters;
     END IF;
     --

  	po_wf_util_pkg.SetItemAttrNumber  (  itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>x_account );

  exception
	when no_data_found then
	null;
  end;
 --END IF; --Bug 7639037
 --<INVCONV END>

  if (x_account IS NOT NULL) then
	result := 'COMPLETE:SUCCESS';
  else
	result := 'COMPLETE:FAILURE';
  end if;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_ACCRUAL_ACC','AA_from_org',x_progress);
        raise;
end AA_from_org;

-- * ****************************************************************************** *

--
-- AA_for_expense_item
--
procedure AA_for_expense_item   ( itemtype        in  varchar2,
                          	  itemkey         in  varchar2,
                       	  	  actid           in number,
                          	  funcmode        in  varchar2,
                          	  result          out NOCOPY varchar2    )
is
	x_progress	varchar2(100);
	x_dest_org_id	number;
	x_item_id	number;
	x_account       number;
        --<INVCONV R12 START>
	x_status		varchar2(1);
	x_vendor_site_id	number;
	x_msg_data      varchar2(2000);
        --<INVCONV R12 END>
        x_msg_count     number;
	dummy   VARCHAR2(40);
	ret     BOOLEAN;

begin

  x_progress := 'PO_WF_PO_ACCRUAL_ACC.AA_for_expense_item: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;
  --<INVCONV START> -- call SLA API instead of GML_ACCT_GENERATE
 x_dest_org_id      := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                   	              itemkey  => itemkey,
                            	 	              aname    => 'DESTINATION_ORGANIZATION_ID');

--  ret := fnd_installation.get_app_info('GMI', X_status, dummy, dummy);

  --Bug 7639037. Uday Phadtare. Commented call to GMF SLA API for process_org because currently
  --GMF_transaction_accounts_PUB.get_accounts is not getting the account as per SLA setup.
 /*
  if ( PO_GML_DB_COMMON.check_process_org(x_dest_org_id) = 'Y')
  then
  	x_item_id     :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                   	       itemkey  => itemkey,
                            	 	       aname    => 'ITEM_ID');
	x_vendor_site_id :=  po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'VENDOR_SITE_ID');
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).account_type_code := GMF_transaction_accounts_PUB.G_ACCRUAL_ACCT;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).item_type := '';
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).subinventory_type := '';
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).organization_id := x_dest_org_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).inventory_item_id := x_item_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).vendor_site_id := x_vendor_site_id;

	GMF_transaction_accounts_PUB.get_accounts(
                               p_api_version                     => 1.0,
				p_init_msg_list			 => dummy,
				p_source			 => 'PO',
				x_return_status                  => X_status,
				x_msg_data			 => x_msg_data,
				x_msg_count			 => x_msg_count);
	x_account := GMF_transaction_accounts_PUB.g_gmf_accts_tab_PUR(1).target_ccid;

        --GML_ACCT_GENERATE.GENERATE_OPM_ACCT('ACCRUAL','', '', x_dest_org_id, x_item_id, x_vendor_site_id, x_account);
  	po_wf_util_pkg.SetItemAttrNumber  (  itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>x_account );
  ELSE
  --<INVCONV END>
 */
  begin
	select accrued_code_combination_id into x_account
  	from po_system_parameters;

  	po_wf_util_pkg.SetItemAttrNumber  (  itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>x_account );
  exception
	when no_data_found then
	null;
  end;
 --END IF;  --Bug 7639037

  if (x_account IS NOT NULL) then
	result := 'COMPLETE:SUCCESS';
  else
	result := 'COMPLETE:FAILURE';
  end if;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_ACCRUAL_ACC','AA_for_expense_item',x_progress);
        raise;

end AA_for_expense_item;

-- * ****************************************************************************** *
-- * ****************************************************************************** *

--
-- is_po_project_related
--
-- This is a dummy function that should be replaced by the customized function
-- activity in the workflow that return TRUE or FALSE based on whether you want to
-- use the default PO expense accrual account generation rules or use "CUSTOMIZED"
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

--

--< Shared Proc FPJ Start >

---------------------------------------------------------------------------
--Start of Comments
--Name: get_SPS_accrual_account
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: TEMP_ACCOUNT_ID
--Locks:
--  None.
--Function:
--  Gets the Accrual Account associated with a given Purchasing Operating Unit.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE get_SPS_accrual_account(itemtype IN VARCHAR2,
                                  itemkey  IN VARCHAR2,
                                  actid    IN NUMBER,
                                  funcmode IN VARCHAR2,
                                  result   OUT NOCOPY VARCHAR2)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_purchasing_ou_id HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE;
  l_account_id GL_CODE_COMBINATIONS.code_combination_id%TYPE;
BEGIN
  l_progress := '010';

  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_progress := '020';
  l_purchasing_ou_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'PURCHASING_OU_ID');

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'PO_WF_PO_ACCRUAL_ACC.get_SPS_accrual_account ' ||
           'l_purchasing_ou_id='||l_purchasing_ou_id);
  END IF;

  --SQL WHAT: Get the Accrual Account for associated with an OU
  --SQL WHY:  To potentially default this as the PO Accrual Account for SPS case
  BEGIN
    SELECT accrued_code_combination_id
    INTO l_account_id
    FROM PO_SYSTEM_PARAMETERS_ALL
    WHERE org_id = l_purchasing_ou_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_account_id := NULL;
  END;

  l_progress := '030';

  IF (l_account_id IS NULL ) THEN
    result := WF_ENGINE.eng_completed || ':FAILURE';
  ELSE
  	PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => itemtype,
        	                    itemkey  => itemkey,
                	            aname    => 'TEMP_ACCOUNT_ID',
                        	    avalue   => l_account_id );

    result := WF_ENGINE.eng_completed || ':SUCCESS';
  END IF;

  l_progress := '040';

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
           'PO_WF_PO_ACCRUAL_ACC.get_SPS_accrual_account result='||result);
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_ACCRUAL_ACC.get_SPS_accrual_account l_account_id='||
         l_account_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_ACCRUAL_ACC.get_SPS_accrual_account EXCEPTION at '||
         l_progress);
    END IF;
    WF_CORE.context('PO_WF_PO_ACCRUAL_ACC', 'get_SPS_accrual_account',
                    l_progress);
    RAISE;
END get_SPS_accrual_account;

--< Shared Proc FPJ End >


-- Bug 8498318 Added the below procedure to retrieve the FSIO
-- Accrual Account if applicable.

---------------------------------------------------------------------------
--Start of Comments
-- FSIO_AA_FOR_EXPENSE_ITEM
--   Get the Accrual Account for EXPENSE destination type from FSIO.
--   This holds good only in case FV is installed, else, existing accounts
--   will be retained. A call would be made to FV and it will be done using
--   dynamic sql. This is done because in case FV is not installed, the procedure
--   might not exist. In this case, dynamic call will silently die, does not throw
--   any error. We do not RAISE the error in the exception block.
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated by call to AOL's INITIALIZE routine.
--   actid     - ID no. of activity this process is called from.
--   funcmode  - Run/Cancel
-- OUT
--   Result
--     FAILURE - Account generation failed
--     SUCCESS - Account generation successful
--End of Comments
---------------------------------------------------------------------------
 PROCEDURE fsio_aa_for_expense_item
     (itemtype  IN VARCHAR2,
      itemkey   IN VARCHAR2,
      actid     IN NUMBER,
      funcmode  IN VARCHAR2,
      result    OUT NOCOPY VARCHAR2)
 IS
  x_progress              VARCHAR2(100);
  x_status                VARCHAR2(1);
  x_msg_data              VARCHAR2(2000);
  x_msg_count             NUMBER;
  x_fsio_accrual_account  NUMBER;

 BEGIN
  x_progress := 'PO_WF_PO_ACCRUAL_ACC.fsio_aa_for_expense_item: 01';
  IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

   -- Condition Added for Bug 9890810
   IF( fv_install.enabled) THEN

   /* Dynamic Call to FSIO Proc to get the Accrual Account */
     EXECUTE IMMEDIATE 'BEGIN fv_utility.GET_ACCRUAL_ACCOUNT(:itemtype,:itemkey,:x_fsio_accrual_account); END; '
     USING IN  itemtype, IN itemkey, OUT x_fsio_accrual_account;

  END IF;

  x_progress := 'PO_WF_PO_ACCRUAL_ACC.fsio_aa_for_expense_item: 02';
  IF (g_po_wf_debug = 'Y') THEN
       PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  IF (x_fsio_accrual_account IS NOT NULL) THEN
    po_wf_util_pkg.setitemattrnumber
           (itemtype => itemtype,
	    itemkey => itemkey,
	    aname => 'TEMP_ACCOUNT_ID',
            avalue => x_fsio_accrual_account);
  END IF;

  result := wf_engine.eng_completed || ':' || wf_engine.eng_null;
  RETURN;
 EXCEPTION
  WHEN OTHERS THEN
    wf_core.CONTEXT('PO_WF_PO_ACCRUAL_ACC','FSIO_AA_for_expense_item',
                    x_progress);
 END fsio_aa_for_expense_item;

end  PO_WF_PO_ACCRUAL_ACC;

/
