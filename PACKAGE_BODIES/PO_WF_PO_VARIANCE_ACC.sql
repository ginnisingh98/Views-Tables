--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_VARIANCE_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_VARIANCE_ACC" AS
/* $Header: POXWPVAB.pls 120.0 2005/06/01 19:17:58 appldev noship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWPVAB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_WF_PO_VARIANCE_ACC
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

  x_progress := 'PO_WF_PO_VARIANCE_ACC.destination_type: 01';
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
    wf_core.context('PO_WF_PO_VARIANCE_ACC','destination_type',x_progress);
        raise;
end destination_type;

-- * ****************************************************************************** *

--
-- VA_from_org
--
procedure VA_from_org      ( itemtype        in  varchar2,
                             itemkey         in  varchar2,
                    	     actid           in number,
                             funcmode        in  varchar2,
                             result          out NOCOPY varchar2    )
is
	x_progress              varchar2(100);
	x_account		number;
	x_dest_org_id		number;

        x_destination_type	varchar2(25); -- Bug 4008665

     --Bug# 1902716 togeorge 07/25/2001
     --EAM: if item id is null get the accrual account from po_system_parameters
     --     (one time items can be delivered to shopfloor with eam)
	x_item_id     		number;
begin

  x_progress := 'PO_WF_PO_VARIANCE_ACC.VA_from_org : 01';
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
     --Bug# 1902716 togeorge 07/25/2001
     --EAM: if item id is null get the accrual account from po_system_parameters
     --     (one time items can be delivered to shopfloor with eam)
  x_item_id      := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                   	              itemkey  => itemkey,
                            	 	              aname    => 'ITEM_ID');

  -- Bug 4008665: Get the destination type code.
  x_destination_type := wf_engine.GetItemAttrText ( itemtype => itemtype, itemkey  => itemkey, aname    => 'DESTINATION_TYPE_CODE');

  begin
     --Bug# 1902716 togeorge 07/25/2001
     --EAM: if item id is null get the accrual account from po_system_parameters
     --     (one time items can be delivered to shopfloor with eam)

     -- Bug 4008665 START
     -- In the case of one time expense items that are shipped to
     -- Shop Floor, the Variance Account in Distributions should come from
     -- mtl_paramters.
      IF ( (x_item_id is not null) OR
           ((x_item_id is null) and (x_destination_type='SHOP FLOOR')) -- condition for EAM
         ) then
     -- Bug 4008665 END
	  select invoice_price_var_account into x_account
	  from mtl_parameters
	  where organization_id     = x_dest_org_id;
      ELSE --treat like an expense item, directly copy the charge account here.
          x_account:=po_wf_util_pkg.GetItemAttrNumber (
				   itemtype => itemtype,
                                   itemkey  => itemkey,
                            	   aname    => 'CODE_COMBINATION_ID');
      END IF;
      --
	  po_wf_util_pkg.SetItemAttrNumber ( itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>x_account );

  exception
	when no_data_found then
	null;
  end;

  if (x_account IS NOT NULL) then
	result := 'COMPLETE:SUCCESS';
  else
	result := 'COMPLETE:FAILURE';
  end if;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_VARIANCE_ACC','VA_from_org',x_progress);
        raise;
end VA_from_org;

--

-- * ****************************************************************************** *

--
-- is_po_project_related
--
-- This is a dummy function that should be replaced by the customized function
-- activity in the workflow that return TRUE or FALSE based on whether you want to
-- use the default PO expense variance account generation rules or use "CUSTOMIZED"
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

procedure   get_charge_account       (  itemtype        in  varchar2,
                             	        itemkey         in  varchar2,
	                     		actid           in number,
                             		funcmode        in  varchar2,
                             		result          out NOCOPY varchar2    )
is
	x_ccid		NUMBER;
	x_progress      varchar2(100);
begin

  -- get code_combination_id from item attribute

  x_ccid      := po_wf_util_pkg.GetItemAttrNumber ( itemtype => itemtype,
                                   	       itemkey  => itemkey,
                            	 	       aname    => 'CODE_COMBINATION_ID');

  if (x_ccid IS NOT NULL) then

  	po_wf_util_pkg.SetItemAttrNumber ( itemtype=>itemtype,
        	                      itemkey=>itemkey,
                	              aname=>'TEMP_ACCOUNT_ID',
                        	      avalue=>x_ccid );
	result := 'COMPLETE:SUCCESS';
  else
	result := 'COMPLETE:FAILURE';
  end if;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_VARIANCE_ACC','get_charge_account',x_progress);
        raise;
end get_charge_account;


--

--< Shared Proc FPJ Start >

---------------------------------------------------------------------------
--Start of Comments
--Name: is_dest_variance_acc_null
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: TEMP_ACCOUNT_ID
--Locks:
--  None.
--Function:
--  Checks if the attribute DEST_VARIANCE_ACCOUNT_ID is NULL or not.
--  If it is NULL, it returns 'N'.
--  If it is not NULL, it copies the value in DEST_VARIANCE_ACCOUNT_ID to
--  TEMP_ACCOUNT_ID and returns 'Y'.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE is_dest_variance_acc_null
                           (itemtype IN VARCHAR2,
                            itemkey  IN VARCHAR2,
                            actid    IN NUMBER,
                            funcmode IN VARCHAR2,
                            result   OUT NOCOPY VARCHAR2)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_dest_variance_account_id GL_CODE_COMBINATIONS.code_combination_id%TYPE;
BEGIN
  l_progress := '010';

  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_progress := '020';
  l_dest_variance_account_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'DEST_VARIANCE_ACCOUNT_ID');

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_VARIANCE_ACC.is_dest_variance_acc_null '||
         'l_dest_variance_account_id='||l_dest_variance_account_id);
  END IF;


  l_progress := '030';
  IF l_dest_variance_account_id IS NULL OR
     l_dest_variance_account_id = 0 OR
     l_dest_variance_account_id = -1 THEN
    result := WF_ENGINE.eng_completed || ':Y';
  ELSE
    -- If the Dest Variance Account is not null (only one case -- autocreate),
    -- then copy it into the TEMP_ACCOUNT_ID.
    l_progress := '040';
    PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'TEMP_ACCOUNT_ID',
                                avalue   => l_dest_variance_account_id);
    l_progress := '050';
    result := WF_ENGINE.eng_completed || ':N';
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_VARIANCE_ACC.is_dest_variance_acc_null result= '||
         result);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_VARIANCE_ACC.is_dest_variance_acc_null EXCEPTION at '||
         l_progress);
    END IF;
    WF_CORE.context('PO_WF_PO_VARIANCE_ACC', 'is_dest_variance_acc_null',
                    l_progress);
    RAISE;
END is_dest_variance_acc_null;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_destination_charge_account
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: TEMP_ACCOUNT_ID
--Locks:
--  None.
--Function:
--  Copies the values in the attribute DEST_VARIANCE_ACCOUNT_ID to
--  the attribute TEMP_ACCOUNT_ID.
--  If the value in DEST_VARIANCE_ACCOUNT_ID is NULL, then it retruns a
--  FAILURE, else it returns a SUCCESS.
--
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE get_destination_charge_account
                           (itemtype IN VARCHAR2,
                            itemkey  IN VARCHAR2,
                            actid    IN NUMBER,
                            funcmode IN VARCHAR2,
                            result   OUT NOCOPY VARCHAR2)
IS
  l_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_dest_charge_account_id NUMBER;
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

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_VARIANCE_ACC.get_destination_charge_account '||
         'l_dest_charge_account_id='||l_dest_charge_account_id);
  END IF;

  l_progress := '030';
  IF l_dest_charge_account_id IS NULL OR
     l_dest_charge_account_id = 0 OR
     l_dest_charge_account_id = -1 THEN
    result := WF_ENGINE.eng_completed || ':FAILURE';
  ELSE
    l_progress := '040';
    PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'TEMP_ACCOUNT_ID',
                              avalue   => l_dest_charge_account_id);
    l_progress := '050';
    result := WF_ENGINE.eng_completed || ':SUCCESS';
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_VARIANCE_ACC.get_destination_charge_account '||
         'result='||result);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey,
         'PO_WF_PO_VARIANCE_ACC.get_destination_charge_account EXCEPTION at '||
         l_progress);
    END IF;
    WF_CORE.context('PO_WF_PO_VARIANCE_ACC', 'get_destination_charge_account',
                    l_progress);
    RAISE;
END get_destination_charge_account;

---------------------------------------------------------------------------
--Start of Comments
--Name: dest_VA_from_org
--Pre-reqs:
--  None
--Modifies:
--  Item Attribute: TEMP_ACCOUNT_ID
--Locks:
--  None
--Function:
--  Retrieves the Destination Variance Account from the Organization level
--  if the item is not a one-time item; otherwise, treat the item as an Expense
--  item and copy the Destination Charge Account
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE dest_VA_from_org ( itemtype        IN  VARCHAR2,
                             itemkey         IN  VARCHAR2,
                    	     actid           IN  NUMBER,
                             funcmode        IN  VARCHAR2,
                             result          OUT NOCOPY VARCHAR2)
IS
  x_progress            VARCHAR2(100);
  x_account		NUMBER;
  x_dest_org_id		NUMBER;
  x_item_id     	NUMBER;

BEGIN

  x_progress := 'PO_WF_PO_VARIANCE_ACC.dest_VA_from_org : 01';

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  IF (funcmode <> wf_engine.eng_run) THEN
     result := wf_engine.eng_null;
     RETURN;
  END IF;

  x_dest_org_id := po_wf_util_pkg.GetItemAttrNumber(itemtype => itemtype,
                                   	            itemkey  => itemkey,
                            	 	            aname    => 'DESTINATION_ORGANIZATION_ID');

  --EAM: if item id is null get the accrual account from po_system_parameters
  --     (one time items can be delivered to shopfloor with eam)
  x_item_id := po_wf_util_pkg.GetItemAttrNumber(itemtype => itemtype,
                                   	        itemkey  => itemkey,
                            	 	        aname    => 'ITEM_ID');

  IF x_item_id IS NOT NULL THEN
     BEGIN
       select invoice_price_var_account into x_account
       from mtl_parameters
       where organization_id = x_dest_org_id;
     EXCEPTION
       WHEN no_data_found THEN
	 NULL;
     END;
  ELSE --treat like an expense item, directly copy the dest charge account here
     x_account := po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                                    itemkey  => itemkey,
                            	                    aname    => 'DEST_CHARGE_ACCOUNT_ID');

     x_progress := 'PO_WF_PO_VARIANCE_ACC.dest_VA_from_org : 02';

     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;
  END IF;

  po_wf_util_pkg.SetItemAttrNumber(itemtype => itemtype,
        	                   itemkey  => itemkey,
                	           aname    => 'TEMP_ACCOUNT_ID',
                        	   avalue   => x_account);

  IF (x_account IS NOT NULL) THEN
     result := 'COMPLETE:SUCCESS';
  ELSE
     result := 'COMPLETE:FAILURE';
  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_VARIANCE_ACC','dest_VA_from_org',x_progress);
       raise;
END dest_VA_from_org;

--< Shared Proc FPJ End >

end  PO_WF_PO_VARIANCE_ACC;

/
