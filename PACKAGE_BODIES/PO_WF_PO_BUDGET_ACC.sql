--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_BUDGET_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_BUDGET_ACC" AS
/* $Header: POXWPBAB.pls 120.0.12010000.3 2011/08/17 13:40:38 vlalwani ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWPBAB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_WF_PO_BUDGET_ACC
 |
 | NOTES
 | MODIFIED    IMRAN ALI (09/03/97) - Created
 *=====================================================================*/

/*
    * A Global variable to set the debug mode
*/
debug_acc_generator_wf BOOLEAN := FALSE;

--
-- BA_from_item_sub
--
procedure BA_from_item_sub ( itemtype        in  varchar2,
                             itemkey         in  varchar2,
                    	     actid           in number,
                             funcmode        in  varchar2,
                             result          out NOCOPY varchar2    )
is
	x_progress              varchar2(100);
	x_destination_type      varchar2(25);
	x_dest_sub_inv		varchar2(25);
	x_account		number;
	x_item_id		number;
	x_dest_org_id		number;
begin

  x_progress := 'PO_WF_PO_BUDGET_ACC.BA_from_item_sub: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_destination_type := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		    itemkey  => itemkey,
                            	 	            aname    => 'DESTINATION_TYPE_CODE');

  x_dest_org_id      := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	              itemkey  => itemkey,
                            	 	              aname    => 'DESTINATION_ORGANIZATION_ID');

  x_dest_sub_inv     := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                   		    itemkey  => itemkey,
                            	 	            aname    => 'DESTINATION_SUBINVENTORY');

  x_item_id          := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                          	      itemkey  => itemkey,
                            	 	              aname    => 'ITEM_ID');
/*
  If (debug_acc_generator_wf) then
		dbms_output.put_line ('Procedure PO_WF_PO_BUDGET_ACC.BA_from_item_sub');
		dbms_output.put_line ('DESTINATION_TYPE_CODE: ' || x_destination_type);
 		dbms_output.put_line ('DESTINATION_ORGANIZATION_ID: ' || to_char(x_dest_org_id));
		dbms_output.put_line ('ITEM_ID: ' || to_char(x_item_id));
		dbms_output.put_line ('DESTINATION_SUBINVENTORY: ' || x_dest_sub_inv);
  end if;
*/
  if (x_destination_type = 'INVENTORY') and (x_dest_sub_inv IS NOT NULL) then

     Begin
	select encumbrance_account into x_account
	from mtl_secondary_inventories
	where secondary_inventory_name = x_dest_sub_inv
	and   organization_id     = x_dest_org_id;

    Exception
	when no_data_found then
	null;
    End;

    if (x_account IS NOT NULL) then

	  wf_engine.SetItemAttrNumber  (  itemtype=>itemtype,
        	                          itemkey=>itemkey,
                	                  aname=>'TEMP_ACCOUNT_ID',
                        	          avalue=>x_account );

	  result := 'COMPLETE:SUCCESS';

    else
	result := 'COMPLETE:FAILURE';
    end if;

  else
	result := 'COMPLETE:FAILURE';
  end if;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_BUDGET_ACC','BA_from_item_sub',x_progress);
        raise;
end BA_from_item_sub;

-- * ****************************************************************************** *

--
-- pre_defined_item
--
procedure pre_defined_item  ( itemtype        in  varchar2,
                       	      itemkey         in  varchar2,
             	              actid           in number,
                              funcmode        in  varchar2,
                              result          out NOCOPY varchar2    )
is
	x_progress	varchar2(100);
	x_item_id	number;
begin

  x_progress := 'PO_WF_PO_BUDGET_ACC.pre_defined_item: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_item_id :=  wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                              itemkey  => itemkey,
                            	 	      aname    => 'ITEM_ID');

  if (x_item_id is NULL) then
	result := 'COMPLETE:FALSE';
  else
	result := 'COMPLETE:TRUE';
  end if;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_BUDGET_ACC','pre_defined_item',x_progress);
        raise;

end pre_defined_item;

-- * ****************************************************************************** *

--
-- get_item_BA
--
procedure get_item_BA   ( itemtype        in  varchar2,
                          itemkey         in  varchar2,
                       	  actid           in number,
                          funcmode        in  varchar2,
                          result          out NOCOPY varchar2    )
is
	x_progress	varchar2(100);
	x_dest_org_id	number;
	x_item_id	number;
	x_account       number;
begin

  x_progress := 'PO_WF_PO_BUDGET_ACC.get_item_BA: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_dest_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	         itemkey  => itemkey,
                            	 	         aname    => 'DESTINATION_ORGANIZATION_ID');

  x_item_id     :=  wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	          itemkey  => itemkey,
                            	 	          aname    => 'ITEM_ID');
 /*
  If (debug_acc_generator_wf) then
		dbms_output.put_line ('Procedure PO_WF_PO_BUDGET_ACC.get_item_BA');
 		dbms_output.put_line ('DESTINATION_ORGANIZATION_ID: ' || to_char(x_dest_org_id));
		dbms_output.put_line ('ITEM_ID: ' || to_char(x_item_id));
  end if;
 */
  begin

	  select encumbrance_account into x_account
	  from MTL_SYSTEM_ITEMS
	  where organization_id = x_dest_org_id
	  and   inventory_item_id = x_item_id;

	  wf_engine.SetItemAttrNumber  (  itemtype=>itemtype,
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

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_BUDGET_ACC','get_item_BA',x_progress);
        raise;

end get_item_BA;

-- * ****************************************************************************** *

--
-- get_org_BA
--
procedure get_org_BA ( itemtype        in  varchar2,
                       itemkey         in  varchar2,
                       actid           in number,
                       funcmode        in  varchar2,
                       result          out NOCOPY varchar2    )
is
	x_progress      varchar2(100);
	x_dest_org_id	number;
	x_account	number;
begin

  x_progress := 'PO_WF_PO_BUDGET_ACC.get_org_BA: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_dest_org_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	         itemkey  => itemkey,
                            	 	         aname    => 'DESTINATION_ORGANIZATION_ID');
/*
  If (debug_acc_generator_wf) then
		dbms_output.put_line ('Procedure PO_WF_PO_BUDGET_ACC.get_org_BA');
 		dbms_output.put_line ('DESTINATION_ORGANIZATION_ID: ' || to_char(x_dest_org_id));
  end if;
*/
  begin
	  select encumbrance_account into x_account
	  from mtl_parameters
	  where organization_id = x_dest_org_id;

  exception
	when no_data_found then
	null;
  end;

  if (x_account IS NOT NULL) then

	  wf_engine.SetItemAttrNumber ( itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>x_account );

  	result := 'COMPLETE:SUCCESS';
  else
	result := 'COMPLETE:FAILURE';
  end if;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_BUDGET_ACC','get_org_BA',x_progress);
        raise;

end get_org_BA;

-- * ****************************************************************************** *

--
-- get_charge_account
--
procedure get_charge_account ( itemtype        in  varchar2,
         	    	       itemkey         in  varchar2,
                       	       actid           in number,
                    	       funcmode        in  varchar2,
                    	       result          out NOCOPY varchar2    )
is
	x_progress      varchar2(100);
	x_account	number;
begin

  x_progress := 'PO_WF_PO_BUDGET_ACC.get_charge_account: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_account := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                   	     itemkey  => itemkey,
                            	 	     aname    => 'CODE_COMBINATION_ID');
/*
  If (debug_acc_generator_wf) then
		dbms_output.put_line ('Procedure PO_WF_PO_BUDGET_ACC.get_charge_account');
 		dbms_output.put_line ('CODE_COMBINATION_ID: ' || to_char(x_account));
  end if;
*/
  if (x_account IS NOT NULL) then

	  wf_engine.SetItemAttrNumber ( itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>x_account );

 	  result := 'COMPLETE:SUCCESS';
  	  return;
  else
 	  result := 'COMPLETE:FAILURE';
  	  return;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_BUDGET_ACC','get_charge_account',x_progress);
        raise;

end get_charge_account;

--

--
-- is_po_project_related
--
-- This is a dummy function that should be replaced by the customized function
-- activity in the workflow that return TRUE or FALSE based on whether you want to
-- use the default PO budget account generation rules or use "CUSTOMIZED"
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

/* Proc IS_EAM_JOB added for Encumbrance Project    */

PROCEDURE IS_EAM_JOB ( itemtype        in  varchar2,
                       itemkey         in  varchar2,
                       actid           in  NUMBER,
			                 funcmode		     in		varchar2,
                       result          out NOCOPY VARCHAR2 )

IS
x_wip_entity_type   NUMBER;
x_progress          varchar2(100);

 BEGIN

  x_progress := 'PO_WF_PO_BUDGET_ACC.Is_eam_job: 01';

    IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  x_wip_entity_type := po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                                        itemkey  => itemkey,
                                                        aname    => 'WIP_ENTITY_TYPE');

  if  x_wip_entity_type = 6 then
  result := 'COMPLETE:Y';
  ELSE
  result := 'COMPLETE:N';
  end if;

  return;

  EXCEPTION
  WHEN OTHERS THEN
      wf_core.context('PO_WF_PO_BUDGET_ACC','Is_eam_job',x_progress);
       raise;
  END IS_EAM_JOB;


/* Proc GET_BA_FOR_SHOP_FLOOR added for Encumbrance  project    */
 -- GET_BA_FOR_SHOP_FLOOR
--   Get the Budget Account based on Costing API
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated by call to AOL's INITIALIZE routine.
--   actid     - ID no. of activity this process is called from.
--   funcmode  - Run/Cancel
--     OUT
--     Result
--     FAILURE - Account generation failed
--     SUCCESS - Account generation successful




PROCEDURE GET_BA_FOR_SHOP_FLOOR ( itemtype        in  varchar2,
                                  itemkey         in  varchar2,
                                  actid           in  NUMBER,
			                            funcmode		    in		varchar2,
                                  result          out NOCOPY VARCHAR2 )

IS
x_wip_entity_id   NUMBER;
x_progress        varchar2(100);
x_api_version     NUMBER  DEFAULT 1;
x_item_id         NUMBER;
l_acct            NUMBER;
l_return_status   VARCHAR2(100);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(500);
l_stmt            VARCHAR2(1000);

BEGIN

x_progress := 'PO_WF_PO_BUDGET_ACC.get_BA_for_shop_floor: 01';
   IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

 x_wip_entity_id :=  po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'WIP_ENTITY_ID');


 x_item_id :=  po_wf_util_pkg.GetItemAttrText ( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'ITEM_ID');

 -- Calling Costing API
-- BLOCK modified, to remove the dependency on Costing Changes made for EAM that are available in 12.1.3 , starts
 BEGIN

  l_stmt:=
      'declare
       p_wip_entity_id  NUMBER;
       p_item_id NUMBER;
       p_account_name varchar2(400);
       p_api_version NUMBER;
       p_acct NUMBER;
       p_return_status varchar2(100);
       p_msg_count NUMBER;
       p_msg_data VARCHAR2(500);
       BEGIN
       CST_EAMCOST_PUB.get_account(:p_wip_entity_id,:p_item_id,:p_account_name,:p_api_version,:p_acct,:p_return_status,:p_msg_count,:p_msg_data) ;
       END;'  ;

       EXECUTE IMMEDIATE l_stmt using x_wip_entity_id,x_item_id,'ENCUMBRANCE',x_api_version, OUT l_acct , OUT l_return_status , OUT l_msg_count  , OUT l_msg_data;

 -- Not handling the exception, assuming the control will come here only if it is an EAM Work Order, so the
 -- CST_EAMCOST_PUB.get_account procedure not exists case will not occur and the rest other possible exceptions will be thrown to the caller

  END;
   -- BLOCK modified, to remove the dependency on Costing Changes made for EAM that are available in 12.1.3 , ends

 if (l_acct IS NOT NULL) then

	  wf_engine.SetItemAttrNumber ( itemtype=>itemtype,
        	                        itemkey=>itemkey,
                	                aname=>'TEMP_ACCOUNT_ID',
                        	        avalue=>l_acct );

    result := 'COMPLETE:SUCCESS';
  else
  	result := 'COMPLETE:FAILURE';
  end if;


 RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_BUDGET_ACC','get_BA_for_shop_floor',x_progress);
        raise;

END GET_BA_FOR_SHOP_FLOOR;



--

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


end  PO_WF_PO_BUDGET_ACC;

/
