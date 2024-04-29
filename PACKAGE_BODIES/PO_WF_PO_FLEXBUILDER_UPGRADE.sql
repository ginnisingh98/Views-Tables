--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_FLEXBUILDER_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_FLEXBUILDER_UPGRADE" AS
/* $Header: POXWPFUB.pls 115.9 2002/11/22 22:06:11 sbull ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWPFUB.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_WF_PO_FLEXBUILDER_UPGRADE
 |
 | NOTES
 | MODIFIED    IMRAN ALI (08/26/97) - Created
 *=====================================================================*/

-- Cursors

/*****************************************************************************
* The following are local/Private procedure that support the workflow APIs:  *
*****************************************************************************/

function po_build_account  (    itemtype        in     varchar2,
                                itemkey         in     varchar2,
				accountType     in     varchar2,
				FB_FLEX_SEG     in out NOCOPY VARCHAR2,
        			FB_ERROR_MSG    in out NOCOPY VARCHAR2  )
return boolean;

procedure Get_att (itemtype in varchar2, itemkey in varchar2, variable in out NOCOPY varchar2,
			 l_aname in varchar2);
procedure Get_number_att (itemtype in varchar2, itemkey in varchar2, variable in out NOCOPY number,
			 l_aname in varchar2);
procedure Get_date_att (itemtype in varchar2, itemkey in varchar2, variable in out NOCOPY date,
			 l_aname in varchar2);

--
-- charge_account
-- Build charge account for the specified structure
--
procedure charge_account  (     itemtype        in  varchar2,
                                itemkey         in  varchar2,
			        actid	     	in number,
                                funcmode        in  varchar2,
                                result          out NOCOPY varchar2    )
is
	l_result_flag		BOOLEAN;
	x_progress              varchar2(1000);
	FB_FLEX_SEG		varchar2(2000);
 	FB_ERROR_MSG		varchar2(2000);
	x_destination_type	varchar2(25);

BEGIN

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.charge_account: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  -- Get the required item attributes and then call the upgrade charge account
  -- routine PO_PO_CHARGE_ACCOUNT.BUILD ( );

  l_result_flag := po_build_account(     itemtype,
                                	 itemkey,
					 'CHARGE',
					 FB_FLEX_SEG,
        				 FB_ERROR_MSG  );

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.charge_account: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if l_result_flag then

	-- Load the concated segment values returned by the BUILD function on to WF item
	-- attributes.

	FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS ( itemtype, itemkey, FB_FLEX_SEG );

	x_progress := 'FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS:success:' ||  FB_FLEX_SEG;
	IF (g_po_wf_debug = 'Y') THEN
   	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	END IF;

	result := 'COMPLETE:SUCCESS';
	return;
  else
	--If the build_account call returns an error message then set the ERROR_MSG attrib.

	x_progress := 'FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS:failure:' ||  FB_ERROR_MSG;
	IF (g_po_wf_debug = 'Y') THEN
   	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	END IF;

	wf_engine.SetItemAttrText  (  itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>'ERROR_MESSAGE',
				      avalue=>FB_ERROR_MSG );

	-- result := 'COMPLETE:FAILURE';

	Get_att(itemtype, itemkey, x_destination_type, 'DESTINATION_TYPE_CODE');

	if x_destination_type = 'EXPENSE' then
		result := 'COMPLETE:SUCCESS'; 	 -- we will handle this in the libraray
	else
		result := 'COMPLETE:FAILURE';
	end if;

	RETURN;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_FLEXBUILDER_UPGRADE','charge_account',x_progress);
        raise;

END charge_account;

/* ********************************************************************************* */

--
-- budget_account
-- Build budget account for the specified structure
--
procedure budget_account  (     itemtype        in  varchar2,
                                itemkey         in  varchar2,
			        actid	     	in number,
                                funcmode        in  varchar2,
                                result          out NOCOPY varchar2    )
is
	l_result_flag		BOOLEAN;
	x_progress              varchar2(1000);
	FB_FLEX_SEG		varchar2(2000);
 	FB_ERROR_MSG		varchar2(2000);
BEGIN

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.budget_account: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  -- Get the required item attributes and then call the upgrade charge account
  -- routine PO_REQ_CHARGE_ACCOUNT.BUILD ( );

  l_result_flag := po_build_account (   itemtype,
                                	itemkey,
					'BUDGET',
					FB_FLEX_SEG,
        				FB_ERROR_MSG  );

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.budget_account: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if l_result_flag then

	-- Load the concated segment values returned by the BUILD function on to WF item
	-- attributes.

	FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS ( itemtype, itemkey, FB_FLEX_SEG );

	result := 'COMPLETE:SUCCESS';
	return;
  else
	--If the build_account call returns an error message then set the ERROR_MSG attrib.

	wf_engine.SetItemAttrText  (  itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>'ERROR_MESSAGE',
				      avalue=>FB_ERROR_MSG );

	result := 'COMPLETE:FAILURE';
	RETURN;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_FLEXBUILDER_UPGRADE','budget_account',x_progress);
        raise;

END budget_account;

/* ********************************************************************************* */

--
-- variance_account
-- Build variance account for the specified structure
--
procedure variance_account  (     itemtype        in  varchar2,
                                  itemkey         in  varchar2,
			          actid	 	  in number,
                                  funcmode        in  varchar2,
                                  result          out NOCOPY varchar2    )
is
	l_result_flag		BOOLEAN;
	x_progress              varchar2(1000);
	FB_FLEX_SEG		varchar2(2000);
 	FB_ERROR_MSG		varchar2(2000);
BEGIN

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.variance_account: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  -- Get the required item attributes and then call the upgrade charge account
  -- routine PO_REQ_CHARGE_ACCOUNT.BUILD ( );

  l_result_flag := po_build_account (   itemtype,
                                	itemkey,
					'VARIANCE',
					FB_FLEX_SEG,
        				FB_ERROR_MSG  );

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.variance_account: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if l_result_flag then

	-- Load the concated segment values returned by the BUILD function on to WF item
	-- attributes.

	FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS ( itemtype, itemkey, FB_FLEX_SEG );

	result := 'COMPLETE:SUCCESS';
	return;
  else
	--If the build_account call returns an error message then set the ERROR_MSG attrib.

	wf_engine.SetItemAttrText  (  itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>'ERROR_MESSAGE',
				      avalue=>FB_ERROR_MSG );

	result := 'COMPLETE:FAILURE';
	RETURN;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_FLEXBUILDER_UPGRADE','variance_account',x_progress);
        raise;

END variance_account;

/* ********************************************************************************* */

--
-- accrual_account
-- Build accrual account for the specified structure
--
procedure accrual_account  (  itemtype        in  varchar2,
                              itemkey         in  varchar2,
			      actid	      in number,
                              funcmode        in  varchar2,
                              result          out NOCOPY varchar2    )
is
	l_result_flag		BOOLEAN;
	x_progress              varchar2(1000);
	FB_FLEX_SEG		varchar2(2000);
 	FB_ERROR_MSG		varchar2(2000);
BEGIN

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.accrual_account: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;

  -- Get the required item attributes and then call the upgrade charge account
  -- routine PO_REQ_CHARGE_ACCOUNT.BUILD ( );

  l_result_flag := po_build_account (   itemtype,
                                	itemkey,
					'ACCRUAL',
					FB_FLEX_SEG,
        				FB_ERROR_MSG  );

  x_progress := 'PO_WF_PO_FLEXBUILDER_UPGRADE.accrual_account: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if l_result_flag then

	-- Load the concated segment values returned by the BUILD function on to WF item
	-- attributes.

	FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS ( itemtype, itemkey, FB_FLEX_SEG );

	result := 'COMPLETE:SUCCESS';
	return;
  else
	--If the build_account call returns an error message then set the ERROR_MSG attrib.

	wf_engine.SetItemAttrText  (  itemtype=>itemtype,
				      itemkey=>itemkey,
				      aname=>'ERROR_MESSAGE',
				      avalue=>FB_ERROR_MSG );

	result := 'COMPLETE:FAILURE';
	RETURN;

  end if;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_FLEXBUILDER_UPGRADE','accrual_account',x_progress);
        raise;

END accrual_account;

/*****************************************************************************
*       Local/Private procedure/functions that support the workflow APIs:    *
*****************************************************************************/

function po_build_account (     itemtype        in     varchar2,
                                itemkey         in     varchar2,
				accountType     in     varchar2,
				FB_FLEX_SEG     in out NOCOPY VARCHAR2,
        			FB_ERROR_MSG    in out NOCOPY VARCHAR2  )
return boolean
is
	x_result_flag	BOOLEAN;
	x_progress      varchar2(1000);

        chart_of_accounts_id  NUMBER;  -- gl_set_of_books.charge_of_account_id
        bom_cost_element_id  NUMBER;
        bom_resource_id  NUMBER;
        category_id  NUMBER;
        deliver_to_location_id  NUMBER;
        destination_organization_id  NUMBER;
        destination_subinventory  VARCHAR2(10);
        destination_type_code  VARCHAR2(25);
        expenditure_type  VARCHAR2(30);
        expenditure_item_date  DATE;
        expenditure_organization_id  NUMBER;

        line_type_id  NUMBER;
        pa_billable_flag  VARCHAR2(1);
        preparer_id  NUMBER;
        project_id  NUMBER;
        source_document_header_id  NUMBER;
        source_document_line_id  NUMBER;
        source_document_type_code  VARCHAR2(25);
        task_id  NUMBER;
        to_person_id  NUMBER;
        type_lookup_code  VARCHAR2(40);
        vendor_id  NUMBER;
        item_id  NUMBER;

        header_att1  VARCHAR2(2000);
        header_att2  VARCHAR2(2000);
        header_att3  VARCHAR2(2000);
        header_att4  VARCHAR2(2000);
        header_att5  VARCHAR2(2000);
        header_att6  VARCHAR2(2000);
        header_att7  VARCHAR2(2000);
        header_att8  VARCHAR2(2000);
        header_att9  VARCHAR2(2000);
        header_att10  VARCHAR2(2000);
        header_att11  VARCHAR2(2000);
        header_att12  VARCHAR2(2000);
        header_att13  VARCHAR2(2000);
        header_att14  VARCHAR2(2000);
        header_att15  VARCHAR2(2000);

        line_att1  VARCHAR2(2000);
        line_att2  VARCHAR2(2000);
        line_att3  VARCHAR2(2000);
        line_att4  VARCHAR2(2000);
        line_att5  VARCHAR2(2000);
        line_att6  VARCHAR2(2000);
        line_att7  VARCHAR2(2000);
        line_att8  VARCHAR2(2000);
        line_att9  VARCHAR2(2000);
        line_att10  VARCHAR2(2000);
        line_att11  VARCHAR2(2000);
        line_att12  VARCHAR2(2000);
        line_att13  VARCHAR2(2000);
        line_att14  VARCHAR2(2000);
        line_att15  VARCHAR2(2000);

        shipment_att1  VARCHAR2(2000);
        shipment_att2  VARCHAR2(2000);
        shipment_att3  VARCHAR2(2000);
        shipment_att4  VARCHAR2(2000);
        shipment_att5  VARCHAR2(2000);
        shipment_att6  VARCHAR2(2000);
        shipment_att7  VARCHAR2(2000);
        shipment_att8  VARCHAR2(2000);
        shipment_att9  VARCHAR2(2000);
        shipment_att10  VARCHAR2(2000);
        shipment_att11  VARCHAR2(2000);
        shipment_att12  VARCHAR2(2000);
        shipment_att13  VARCHAR2(2000);
        shipment_att14  VARCHAR2(2000);
        shipment_att15  VARCHAR2(2000);

        distribution_att1  VARCHAR2(2000);
        distribution_att2  VARCHAR2(2000);
        distribution_att3  VARCHAR2(2000);
        distribution_att4  VARCHAR2(2000);
        distribution_att5  VARCHAR2(2000);
        distribution_att6  VARCHAR2(2000);
        distribution_att7  VARCHAR2(2000);
        distribution_att8  VARCHAR2(2000);
        distribution_att9  VARCHAR2(2000);
        distribution_att10  VARCHAR2(2000);
        distribution_att11  VARCHAR2(2000);
        distribution_att12  VARCHAR2(2000);
        distribution_att13  VARCHAR2(2000);
        distribution_att14  VARCHAR2(2000);
        distribution_att15  VARCHAR2(2000);

        wip_entity_id  NUMBER;
        wip_entity_type  VARCHAR2(40);
        wip_line_id  NUMBER;
        wip_operation_seq_num  NUMBER;
        wip_repetitive_schedule_id  NUMBER;
        wip_resource_seq_num  NUMBER;

	ccid NUMBER;
	budget_account_id NUMBER;
	accrual_account_id NUMBER;

begin

   -- Get values for the arguments to the build call from the Workflow Item Attributes.

	IF (accountType IN  ('BUDGET', 'ACCRUAL', 'VARIANCE')) then
		Get_number_att(itemtype, itemkey, ccid, 'CODE_COMBINATION_ID');
	END IF;
	IF (accountType IN  ('ACCRUAL', 'VARIANCE')) then
		Get_number_att(itemtype, itemkey, budget_account_id, 'BUDGET_ACCOUNT_ID');
	END IF;
	IF (accountType IN  ('VARIANCE')) then
		Get_number_att(itemtype, itemkey, accrual_account_id, 'ACCRUAL_ACCOUNT_ID');
	END IF;
	Get_number_att(itemtype, itemkey, chart_of_accounts_id, 'CHART_OF_ACCOUNTS_ID');
	Get_number_att(itemtype, itemkey, bom_cost_element_id, 'BOM_COST_ELEMENT_ID');
	Get_number_att(itemtype, itemkey, bom_resource_id, 'BOM_RESOURCE_ID');
	Get_number_att(itemtype, itemkey, category_id, 'CATEGORY_ID');
	Get_number_att(itemtype, itemkey, deliver_to_location_id, 'DELIVER_TO_LOCATION_ID');
	Get_number_att(itemtype, itemkey, destination_organization_id, 'DESTINATION_ORGANIZATION_ID');
	Get_att(itemtype, itemkey, destination_subinventory, 'DESTINATION_SUBINVENTORY');
	Get_att(itemtype, itemkey, destination_type_code, 'DESTINATION_TYPE_CODE');
	Get_att(itemtype, itemkey, expenditure_type, 'EXPENDITURE_TYPE');
	Get_date_att(itemtype, itemkey, expenditure_item_date, 'EXPENDITURE_ITEM_DATE');
	Get_number_att(itemtype, itemkey, expenditure_organization_id, 'EXPENDITURE_ORGANIZATION_ID');
	Get_number_att(itemtype, itemkey, line_type_id, 'LINE_TYPE_ID');
	Get_att(itemtype, itemkey, pa_billable_flag, 'PA_BILLABLE_FLAG');
	Get_number_att(itemtype, itemkey, preparer_id, 'PREPARER_ID');
	Get_number_att(itemtype, itemkey, project_id, 'PROJECT_ID');
	Get_number_att(itemtype, itemkey, source_document_header_id, 'SOURCE_DOCUMENT_HEADER_ID');
	Get_number_att(itemtype, itemkey, source_document_line_id, 'SOURCE_DOCUMENT_LINE_ID');
	Get_att(itemtype, itemkey, source_document_type_code, 'SOURCE_DOCUMENT_TYPE_CODE');
	Get_number_att(itemtype, itemkey, task_id, 'TASK_ID');
	Get_number_att(itemtype, itemkey, to_person_id, 'TO_PERSON_ID');
	Get_att(itemtype, itemkey, type_lookup_code, 'TYPE_LOOKUP_CODE');
	Get_number_att(itemtype, itemkey, vendor_id, 'VENDOR_ID');
	Get_number_att(itemtype, itemkey, item_id, 'ITEM_ID');
	Get_number_att(itemtype, itemkey, wip_entity_id, 'WIP_ENTITY_ID');
	Get_att(itemtype, itemkey, wip_entity_type, 'WIP_ENTITY_TYPE');
	Get_number_att(itemtype, itemkey, wip_line_id, 'WIP_LINE_ID');
	Get_number_att(itemtype, itemkey, wip_operation_seq_num, 'WIP_OPERATION_SEQ_NUM');
	Get_number_att(itemtype, itemkey, wip_repetitive_schedule_id, 'WIP_REPETITIVE_SCHEDULE_ID');
	Get_number_att(itemtype, itemkey, wip_resource_seq_num, 'WIP_RESOURCE_SEQ_NUM');

	-- Get Header, line, shipment and distribution attributes.

	Get_att(itemtype, itemkey, header_att1, 'HEADER_ATT1');
	Get_att(itemtype, itemkey, header_att2, 'HEADER_ATT2');
	Get_att(itemtype, itemkey, header_att3, 'HEADER_ATT3');
	Get_att(itemtype, itemkey, header_att4, 'HEADER_ATT4');
	Get_att(itemtype, itemkey, header_att5, 'HEADER_ATT5');
	Get_att(itemtype, itemkey, header_att6, 'HEADER_ATT6');
	Get_att(itemtype, itemkey, header_att7, 'HEADER_ATT7');
	Get_att(itemtype, itemkey, header_att8, 'HEADER_ATT8');
	Get_att(itemtype, itemkey, header_att9, 'HEADER_ATT9');
	Get_att(itemtype, itemkey, header_att10, 'HEADER_ATT10');
	Get_att(itemtype, itemkey, header_att11, 'HEADER_ATT11');
	Get_att(itemtype, itemkey, header_att12, 'HEADER_ATT12');
	Get_att(itemtype, itemkey, header_att13, 'HEADER_ATT13');
	Get_att(itemtype, itemkey, header_att14, 'HEADER_ATT14');
	Get_att(itemtype, itemkey, header_att15, 'HEADER_ATT15');

	Get_att(itemtype, itemkey, line_att1, 'LINE_ATT1');
	Get_att(itemtype, itemkey, line_att2, 'LINE_ATT2');
	Get_att(itemtype, itemkey, line_att3, 'LINE_ATT3');
	Get_att(itemtype, itemkey, line_att4, 'LINE_ATT4');
	Get_att(itemtype, itemkey, line_att5, 'LINE_ATT5');
	Get_att(itemtype, itemkey, line_att6, 'LINE_ATT6');
	Get_att(itemtype, itemkey, line_att7, 'LINE_ATT7');
	Get_att(itemtype, itemkey, line_att8, 'LINE_ATT8');
	Get_att(itemtype, itemkey, line_att9, 'LINE_ATT9');
	Get_att(itemtype, itemkey, line_att10, 'LINE_ATT10');
	Get_att(itemtype, itemkey, line_att11, 'LINE_ATT11');
	Get_att(itemtype, itemkey, line_att12, 'LINE_ATT12');
	Get_att(itemtype, itemkey, line_att13, 'LINE_ATT13');
	Get_att(itemtype, itemkey, line_att14, 'LINE_ATT14');
	Get_att(itemtype, itemkey, line_att15, 'LINE_ATT15');

	Get_att(itemtype, itemkey, shipment_att1, 'SHIPMENT_ATT1');
	Get_att(itemtype, itemkey, shipment_att2, 'SHIPMENT_ATT2');
	Get_att(itemtype, itemkey, shipment_att3, 'SHIPMENT_ATT3');
	Get_att(itemtype, itemkey, shipment_att4, 'SHIPMENT_ATT4');
	Get_att(itemtype, itemkey, shipment_att5, 'SHIPMENT_ATT5');
	Get_att(itemtype, itemkey, shipment_att6, 'SHIPMENT_ATT6');
	Get_att(itemtype, itemkey, shipment_att7, 'SHIPMENT_ATT7');
	Get_att(itemtype, itemkey, shipment_att8, 'SHIPMENT_ATT8');
	Get_att(itemtype, itemkey, shipment_att9, 'SHIPMENT_ATT9');
	Get_att(itemtype, itemkey, shipment_att10, 'SHIPMENT_ATT10');
	Get_att(itemtype, itemkey, shipment_att11, 'SHIPMENT_ATT11');
	Get_att(itemtype, itemkey, shipment_att12, 'SHIPMENT_ATT12');
	Get_att(itemtype, itemkey, shipment_att13, 'SHIPMENT_ATT13');
	Get_att(itemtype, itemkey, shipment_att14, 'SHIPMENT_ATT14');
	Get_att(itemtype, itemkey, shipment_att15, 'SHIPMENT_ATT15');

	Get_att(itemtype, itemkey, distribution_att1, 'DISTRIBUTION_ATT1');
	Get_att(itemtype, itemkey, distribution_att2, 'DISTRIBUTION_ATT2');
	Get_att(itemtype, itemkey, distribution_att3, 'DISTRIBUTION_ATT3');
	Get_att(itemtype, itemkey, distribution_att4, 'DISTRIBUTION_ATT4');
	Get_att(itemtype, itemkey, distribution_att5, 'DISTRIBUTION_ATT5');
	Get_att(itemtype, itemkey, distribution_att6, 'DISTRIBUTION_ATT6');
	Get_att(itemtype, itemkey, distribution_att7, 'DISTRIBUTION_ATT7');
	Get_att(itemtype, itemkey, distribution_att8, 'DISTRIBUTION_ATT8');
	Get_att(itemtype, itemkey, distribution_att9, 'DISTRIBUTION_ATT9');
	Get_att(itemtype, itemkey, distribution_att10, 'DISTRIBUTION_ATT10');
	Get_att(itemtype, itemkey, distribution_att11, 'DISTRIBUTION_ATT11');
	Get_att(itemtype, itemkey, distribution_att12, 'DISTRIBUTION_ATT12');
	Get_att(itemtype, itemkey, distribution_att13, 'DISTRIBUTION_ATT13');
	Get_att(itemtype, itemkey, distribution_att14, 'DISTRIBUTION_ATT14');
	Get_att(itemtype, itemkey, distribution_att15, 'DISTRIBUTION_ATT15');

      -- chart_of_accounts_id =  gl_set_of_books.charge_of_account_id - structure id

	x_progress := 'calling PO_PO_CHARGE_ACCOUNT.BUILD';
	IF (g_po_wf_debug = 'Y') THEN
   	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	END IF;

	IF (accountType = 'CHARGE') then

           x_result_flag := PO_PO_CHARGE_ACCOUNT.BUILD (

		FB_FLEX_NUM  =>  chart_of_accounts_id,
        	BOM_COST_ELEMENT_ID  =>  to_char(bom_cost_element_id),
        	BOM_RESOURCE_ID  =>  to_char(bom_resource_id),
        	CATEGORY_ID  =>  to_char(category_id),
        	DELIVER_TO_LOCATION_ID  =>  to_char(deliver_to_location_id),
        	DESTINATION_ORGANIZATION_ID  =>  to_char(destination_organization_id),
        	DESTINATION_SUBINVENTORY  =>  destination_subinventory,
        	DESTINATION_TYPE_CODE  =>  destination_type_code,
        	EXPENDITURE_TYPE  =>  expenditure_type,
        	EXPENDITURE_ITEM_DATE  =>  to_char(expenditure_item_date),
        	EXPENDITURE_ORGANIZATION_ID  =>  to_char(expenditure_organization_id),
        	LINE_TYPE_ID  =>  to_char(line_type_id),
        	PA_BILLABLE_FLAG  =>  pa_billable_flag,
        	PREPARER_ID  =>  to_char(preparer_id),
        	PROJECT_ID  =>  to_char(project_id),
        	SOURCE_DOCUMENT_HEADER_ID  =>  to_char(source_document_header_id),
        	SOURCE_DOCUMENT_LINE_ID  =>  to_char(source_document_line_id),
        	SOURCE_DOCUMENT_TYPE_CODE  =>  source_document_type_code,
        	TASK_ID  =>  to_char(task_id),
        	TO_PERSON_ID  =>  to_char(to_person_id),
        	TYPE_LOOKUP_CODE  =>  type_lookup_code,
        	VENDOR_ID  =>  to_char(vendor_id),
        	ITEM_ID  =>  to_char(item_id),

        	HEADER_ATT1  =>  header_att1,
        	HEADER_ATT2  =>  header_att2,
        	HEADER_ATT3  =>  header_att3,
        	HEADER_ATT4  =>  header_att4,
        	HEADER_ATT5  =>  header_att5,
        	HEADER_ATT6  =>  header_att6,
        	HEADER_ATT7  =>  header_att7,
        	HEADER_ATT8  =>  header_att8,
        	HEADER_ATT9  =>  header_att9,
       		HEADER_ATT10  =>  header_att10,
        	HEADER_ATT11  =>  header_att11,
        	HEADER_ATT12  =>  header_att12,
        	HEADER_ATT13  =>  header_att13,
        	HEADER_ATT14  =>  header_att14,
        	HEADER_ATT15  =>  header_att15,

        	LINE_ATT1  =>  line_att1,
        	LINE_ATT2  =>  line_att2,
        	LINE_ATT3  =>  line_att3,
        	LINE_ATT4  =>  line_att4,
        	LINE_ATT5  =>  line_att5,
        	LINE_ATT6  =>  line_att6,
        	LINE_ATT7  =>  line_att7,
        	LINE_ATT8  =>  line_att8,
        	LINE_ATT9  =>  line_att9,
        	LINE_ATT10  =>  line_att10,
        	LINE_ATT11  =>  line_att11,
        	LINE_ATT12  =>  line_att12,
        	LINE_ATT13  =>  line_att13,
        	LINE_ATT14  =>  line_att14,
        	LINE_ATT15  =>  line_att15,

        	SHIPMENT_ATT1  =>  shipment_att1,
        	SHIPMENT_ATT2  =>  shipment_att2,
        	SHIPMENT_ATT3  =>  shipment_att3,
        	SHIPMENT_ATT4  =>  shipment_att4,
        	SHIPMENT_ATT5  =>  shipment_att5,
        	SHIPMENT_ATT6  =>  shipment_att6,
        	SHIPMENT_ATT7  =>  shipment_att7,
        	SHIPMENT_ATT8  =>  shipment_att8,
        	SHIPMENT_ATT9  =>  shipment_att9,
        	SHIPMENT_ATT10  =>  shipment_att10,
        	SHIPMENT_ATT11  =>  shipment_att11,
        	SHIPMENT_ATT12  =>  shipment_att12,
        	SHIPMENT_ATT13  =>  shipment_att13,
        	SHIPMENT_ATT14  =>  shipment_att14,
        	SHIPMENT_ATT15  =>  shipment_att15,

        	DISTRIBUTION_ATT1  =>  distribution_att1,
        	DISTRIBUTION_ATT2  =>  distribution_att2,
        	DISTRIBUTION_ATT3  =>  distribution_att3,
        	DISTRIBUTION_ATT4  =>  distribution_att4,
        	DISTRIBUTION_ATT5  =>  distribution_att5,
        	DISTRIBUTION_ATT6  =>  distribution_att6,
        	DISTRIBUTION_ATT7  =>  distribution_att7,
        	DISTRIBUTION_ATT8  =>  distribution_att8,
        	DISTRIBUTION_ATT9  =>  distribution_att9,
        	DISTRIBUTION_ATT10  =>  distribution_att10,
        	DISTRIBUTION_ATT11  =>  distribution_att11,
        	DISTRIBUTION_ATT12  =>  distribution_att12,
        	DISTRIBUTION_ATT13  =>  distribution_att13,
        	DISTRIBUTION_ATT14  =>  distribution_att14,
        	DISTRIBUTION_ATT15  =>  distribution_att15,

        	WIP_ENTITY_ID  =>  to_char(wip_entity_id),
        	WIP_ENTITY_TYPE  =>  wip_entity_type,
        	WIP_LINE_ID  =>  to_char(wip_line_id),
        	WIP_OPERATION_SEQ_NUM  =>  to_char(wip_operation_seq_num),
        	WIP_REPETITIVE_SCHEDULE_ID  =>  to_char(wip_repetitive_schedule_id),
        	WIP_RESOURCE_SEQ_NUM  =>  to_char(wip_resource_seq_num),

        	FB_FLEX_SEG   => fb_flex_seg,
        	FB_ERROR_MSG   => fb_error_msg );

	ELSIF (accountType = 'BUDGET') then

          x_result_flag := PO_PO_BUDGET_ACCOUNT.BUILD (

		FB_FLEX_NUM  =>  chart_of_accounts_id,
        	BOM_COST_ELEMENT_ID  =>  to_char(bom_cost_element_id),
        	BOM_RESOURCE_ID  =>  to_char(bom_resource_id),
        	CATEGORY_ID  =>  to_char(category_id),
		CODE_COMBINATION_ID => to_char(ccid),
        	DELIVER_TO_LOCATION_ID  =>  to_char(deliver_to_location_id),
        	DESTINATION_ORGANIZATION_ID  =>  to_char(destination_organization_id),
        	DESTINATION_SUBINVENTORY  =>  destination_subinventory,
        	DESTINATION_TYPE_CODE  =>  destination_type_code,
        	EXPENDITURE_TYPE  =>  expenditure_type,
        	EXPENDITURE_ITEM_DATE  =>  to_char(expenditure_item_date),
        	EXPENDITURE_ORGANIZATION_ID  =>  to_char(expenditure_organization_id),
        	LINE_TYPE_ID  =>  to_char(line_type_id),
        	PA_BILLABLE_FLAG  =>  pa_billable_flag,
        	PREPARER_ID  =>  to_char(preparer_id),
        	PROJECT_ID  =>  to_char(project_id),
        	SOURCE_DOCUMENT_HEADER_ID  =>  to_char(source_document_header_id),
        	SOURCE_DOCUMENT_LINE_ID  =>  to_char(source_document_line_id),
        	SOURCE_DOCUMENT_TYPE_CODE  =>  source_document_type_code,
        	TASK_ID  =>  to_char(task_id),
        	TO_PERSON_ID  =>  to_char(to_person_id),
        	TYPE_LOOKUP_CODE  =>  type_lookup_code,
        	VENDOR_ID  =>  to_char(vendor_id),
        	ITEM_ID  =>  to_char(item_id),

        	HEADER_ATT1  =>  header_att1,
        	HEADER_ATT2  =>  header_att2,
        	HEADER_ATT3  =>  header_att3,
        	HEADER_ATT4  =>  header_att4,
        	HEADER_ATT5  =>  header_att5,
        	HEADER_ATT6  =>  header_att6,
        	HEADER_ATT7  =>  header_att7,
        	HEADER_ATT8  =>  header_att8,
        	HEADER_ATT9  =>  header_att9,
       		HEADER_ATT10  =>  header_att10,
        	HEADER_ATT11  =>  header_att11,
        	HEADER_ATT12  =>  header_att12,
        	HEADER_ATT13  =>  header_att13,
        	HEADER_ATT14  =>  header_att14,
        	HEADER_ATT15  =>  header_att15,

        	LINE_ATT1  =>  line_att1,
        	LINE_ATT2  =>  line_att2,
        	LINE_ATT3  =>  line_att3,
        	LINE_ATT4  =>  line_att4,
        	LINE_ATT5  =>  line_att5,
        	LINE_ATT6  =>  line_att6,
        	LINE_ATT7  =>  line_att7,
        	LINE_ATT8  =>  line_att8,
        	LINE_ATT9  =>  line_att9,
        	LINE_ATT10  =>  line_att10,
        	LINE_ATT11  =>  line_att11,
        	LINE_ATT12  =>  line_att12,
        	LINE_ATT13  =>  line_att13,
        	LINE_ATT14  =>  line_att14,
        	LINE_ATT15  =>  line_att15,

        	SHIPMENT_ATT1  =>  shipment_att1,
        	SHIPMENT_ATT2  =>  shipment_att2,
        	SHIPMENT_ATT3  =>  shipment_att3,
        	SHIPMENT_ATT4  =>  shipment_att4,
        	SHIPMENT_ATT5  =>  shipment_att5,
        	SHIPMENT_ATT6  =>  shipment_att6,
        	SHIPMENT_ATT7  =>  shipment_att7,
        	SHIPMENT_ATT8  =>  shipment_att8,
        	SHIPMENT_ATT9  =>  shipment_att9,
        	SHIPMENT_ATT10  =>  shipment_att10,
        	SHIPMENT_ATT11  =>  shipment_att11,
        	SHIPMENT_ATT12  =>  shipment_att12,
        	SHIPMENT_ATT13  =>  shipment_att13,
        	SHIPMENT_ATT14  =>  shipment_att14,
        	SHIPMENT_ATT15  =>  shipment_att15,

        	DISTRIBUTION_ATT1  =>  distribution_att1,
        	DISTRIBUTION_ATT2  =>  distribution_att2,
        	DISTRIBUTION_ATT3  =>  distribution_att3,
        	DISTRIBUTION_ATT4  =>  distribution_att4,
        	DISTRIBUTION_ATT5  =>  distribution_att5,
        	DISTRIBUTION_ATT6  =>  distribution_att6,
        	DISTRIBUTION_ATT7  =>  distribution_att7,
        	DISTRIBUTION_ATT8  =>  distribution_att8,
        	DISTRIBUTION_ATT9  =>  distribution_att9,
        	DISTRIBUTION_ATT10  =>  distribution_att10,
        	DISTRIBUTION_ATT11  =>  distribution_att11,
        	DISTRIBUTION_ATT12  =>  distribution_att12,
        	DISTRIBUTION_ATT13  =>  distribution_att13,
        	DISTRIBUTION_ATT14  =>  distribution_att14,
        	DISTRIBUTION_ATT15  =>  distribution_att15,

        	WIP_ENTITY_ID  =>  to_char(wip_entity_id),
        	WIP_ENTITY_TYPE  =>  wip_entity_type,
        	WIP_LINE_ID  =>  to_char(wip_line_id),
        	WIP_OPERATION_SEQ_NUM  =>  to_char(wip_operation_seq_num),
        	WIP_REPETITIVE_SCHEDULE_ID  =>  to_char(wip_repetitive_schedule_id),
        	WIP_RESOURCE_SEQ_NUM  =>  to_char(wip_resource_seq_num),

        	FB_FLEX_SEG   => fb_flex_seg,
        	FB_ERROR_MSG   => fb_error_msg );

	ELSIF (accountType = 'ACCRUAL') then

           x_result_flag := PO_PO_ACCRUAL_ACCOUNT.BUILD (

		FB_FLEX_NUM  =>  chart_of_accounts_id,
        	BOM_COST_ELEMENT_ID  =>  to_char(bom_cost_element_id),
        	BOM_RESOURCE_ID  =>  to_char(bom_resource_id),
        	CATEGORY_ID  =>  to_char(category_id),
		CODE_COMBINATION_ID => to_char(ccid),
		BUDGET_ACCOUNT_ID => to_char(budget_account_id),
        	DELIVER_TO_LOCATION_ID  =>  to_char(deliver_to_location_id),
        	DESTINATION_ORGANIZATION_ID  =>  to_char(destination_organization_id),
        	DESTINATION_SUBINVENTORY  =>  destination_subinventory,
        	DESTINATION_TYPE_CODE  =>  destination_type_code,
        	EXPENDITURE_TYPE  =>  expenditure_type,
        	EXPENDITURE_ITEM_DATE  =>  to_char(expenditure_item_date),
        	EXPENDITURE_ORGANIZATION_ID  =>  to_char(expenditure_organization_id),
        	LINE_TYPE_ID  =>  to_char(line_type_id),
        	PA_BILLABLE_FLAG  =>  pa_billable_flag,
        	PREPARER_ID  =>  to_char(preparer_id),
        	PROJECT_ID  =>  to_char(project_id),
        	SOURCE_DOCUMENT_HEADER_ID  =>  to_char(source_document_header_id),
        	SOURCE_DOCUMENT_LINE_ID  =>  to_char(source_document_line_id),
        	SOURCE_DOCUMENT_TYPE_CODE  =>  source_document_type_code,
        	TASK_ID  =>  to_char(task_id),
        	TO_PERSON_ID  =>  to_char(to_person_id),
        	TYPE_LOOKUP_CODE  =>  type_lookup_code,
        	VENDOR_ID  =>  to_char(vendor_id),
        	ITEM_ID  =>  to_char(item_id),

        	HEADER_ATT1  =>  header_att1,
        	HEADER_ATT2  =>  header_att2,
        	HEADER_ATT3  =>  header_att3,
        	HEADER_ATT4  =>  header_att4,
        	HEADER_ATT5  =>  header_att5,
        	HEADER_ATT6  =>  header_att6,
        	HEADER_ATT7  =>  header_att7,
        	HEADER_ATT8  =>  header_att8,
        	HEADER_ATT9  =>  header_att9,
       		HEADER_ATT10  =>  header_att10,
        	HEADER_ATT11  =>  header_att11,
        	HEADER_ATT12  =>  header_att12,
        	HEADER_ATT13  =>  header_att13,
        	HEADER_ATT14  =>  header_att14,
        	HEADER_ATT15  =>  header_att15,

        	LINE_ATT1  =>  line_att1,
        	LINE_ATT2  =>  line_att2,
        	LINE_ATT3  =>  line_att3,
        	LINE_ATT4  =>  line_att4,
        	LINE_ATT5  =>  line_att5,
        	LINE_ATT6  =>  line_att6,
        	LINE_ATT7  =>  line_att7,
        	LINE_ATT8  =>  line_att8,
        	LINE_ATT9  =>  line_att9,
        	LINE_ATT10  =>  line_att10,
        	LINE_ATT11  =>  line_att11,
        	LINE_ATT12  =>  line_att12,
        	LINE_ATT13  =>  line_att13,
        	LINE_ATT14  =>  line_att14,
        	LINE_ATT15  =>  line_att15,

        	SHIPMENT_ATT1  =>  shipment_att1,
        	SHIPMENT_ATT2  =>  shipment_att2,
        	SHIPMENT_ATT3  =>  shipment_att3,
        	SHIPMENT_ATT4  =>  shipment_att4,
        	SHIPMENT_ATT5  =>  shipment_att5,
        	SHIPMENT_ATT6  =>  shipment_att6,
        	SHIPMENT_ATT7  =>  shipment_att7,
        	SHIPMENT_ATT8  =>  shipment_att8,
        	SHIPMENT_ATT9  =>  shipment_att9,
        	SHIPMENT_ATT10  =>  shipment_att10,
        	SHIPMENT_ATT11  =>  shipment_att11,
        	SHIPMENT_ATT12  =>  shipment_att12,
        	SHIPMENT_ATT13  =>  shipment_att13,
        	SHIPMENT_ATT14  =>  shipment_att14,
        	SHIPMENT_ATT15  =>  shipment_att15,

        	DISTRIBUTION_ATT1  =>  distribution_att1,
        	DISTRIBUTION_ATT2  =>  distribution_att2,
        	DISTRIBUTION_ATT3  =>  distribution_att3,
        	DISTRIBUTION_ATT4  =>  distribution_att4,
        	DISTRIBUTION_ATT5  =>  distribution_att5,
        	DISTRIBUTION_ATT6  =>  distribution_att6,
        	DISTRIBUTION_ATT7  =>  distribution_att7,
        	DISTRIBUTION_ATT8  =>  distribution_att8,
        	DISTRIBUTION_ATT9  =>  distribution_att9,
        	DISTRIBUTION_ATT10  =>  distribution_att10,
        	DISTRIBUTION_ATT11  =>  distribution_att11,
        	DISTRIBUTION_ATT12  =>  distribution_att12,
        	DISTRIBUTION_ATT13  =>  distribution_att13,
        	DISTRIBUTION_ATT14  =>  distribution_att14,
        	DISTRIBUTION_ATT15  =>  distribution_att15,

        	WIP_ENTITY_ID  =>  to_char(wip_entity_id),
        	WIP_ENTITY_TYPE  =>  wip_entity_type,
        	WIP_LINE_ID  =>  to_char(wip_line_id),
        	WIP_OPERATION_SEQ_NUM  =>  to_char(wip_operation_seq_num),
        	WIP_REPETITIVE_SCHEDULE_ID  =>  to_char(wip_repetitive_schedule_id),
        	WIP_RESOURCE_SEQ_NUM  =>  to_char(wip_resource_seq_num),

        	FB_FLEX_SEG   => fb_flex_seg,
        	FB_ERROR_MSG   => fb_error_msg );

	ELSE  -- accountType = VARIANCE

           x_result_flag := PO_PO_VARIANCE_ACCOUNT.BUILD (

		FB_FLEX_NUM  =>  chart_of_accounts_id,
        	BOM_COST_ELEMENT_ID  =>  to_char(bom_cost_element_id),
        	BOM_RESOURCE_ID  =>  to_char(bom_resource_id),
        	CATEGORY_ID  =>  to_char(category_id),
		CODE_COMBINATION_ID => to_char(ccid),
		BUDGET_ACCOUNT_ID => to_char(budget_account_id),
		ACCRUAL_ACCOUNT_ID => to_char(accrual_account_id),
        	DELIVER_TO_LOCATION_ID  =>  to_char(deliver_to_location_id),
        	DESTINATION_ORGANIZATION_ID  =>  to_char(destination_organization_id),
        	DESTINATION_SUBINVENTORY  =>  destination_subinventory,
        	DESTINATION_TYPE_CODE  =>  destination_type_code,
        	EXPENDITURE_TYPE  =>  expenditure_type,
        	EXPENDITURE_ITEM_DATE  =>  to_char(expenditure_item_date),
        	EXPENDITURE_ORGANIZATION_ID  =>  to_char(expenditure_organization_id),
        	LINE_TYPE_ID  =>  to_char(line_type_id),
        	PA_BILLABLE_FLAG  =>  pa_billable_flag,
        	PREPARER_ID  =>  to_char(preparer_id),
        	PROJECT_ID  =>  to_char(project_id),
        	SOURCE_DOCUMENT_HEADER_ID  =>  to_char(source_document_header_id),
        	SOURCE_DOCUMENT_LINE_ID  =>  to_char(source_document_line_id),
        	SOURCE_DOCUMENT_TYPE_CODE  =>  source_document_type_code,
        	TASK_ID  =>  to_char(task_id),
        	TO_PERSON_ID  =>  to_char(to_person_id),
        	TYPE_LOOKUP_CODE  =>  type_lookup_code,
        	VENDOR_ID  =>  to_char(vendor_id),
        	ITEM_ID  =>  to_char(item_id),

        	HEADER_ATT1  =>  header_att1,
        	HEADER_ATT2  =>  header_att2,
        	HEADER_ATT3  =>  header_att3,
        	HEADER_ATT4  =>  header_att4,
        	HEADER_ATT5  =>  header_att5,
        	HEADER_ATT6  =>  header_att6,
        	HEADER_ATT7  =>  header_att7,
        	HEADER_ATT8  =>  header_att8,
        	HEADER_ATT9  =>  header_att9,
       		HEADER_ATT10  =>  header_att10,
        	HEADER_ATT11  =>  header_att11,
        	HEADER_ATT12  =>  header_att12,
        	HEADER_ATT13  =>  header_att13,
        	HEADER_ATT14  =>  header_att14,
        	HEADER_ATT15  =>  header_att15,

        	LINE_ATT1  =>  line_att1,
        	LINE_ATT2  =>  line_att2,
        	LINE_ATT3  =>  line_att3,
        	LINE_ATT4  =>  line_att4,
        	LINE_ATT5  =>  line_att5,
        	LINE_ATT6  =>  line_att6,
        	LINE_ATT7  =>  line_att7,
        	LINE_ATT8  =>  line_att8,
        	LINE_ATT9  =>  line_att9,
        	LINE_ATT10  =>  line_att10,
        	LINE_ATT11  =>  line_att11,
        	LINE_ATT12  =>  line_att12,
        	LINE_ATT13  =>  line_att13,
        	LINE_ATT14  =>  line_att14,
        	LINE_ATT15  =>  line_att15,

        	SHIPMENT_ATT1  =>  shipment_att1,
        	SHIPMENT_ATT2  =>  shipment_att2,
        	SHIPMENT_ATT3  =>  shipment_att3,
        	SHIPMENT_ATT4  =>  shipment_att4,
        	SHIPMENT_ATT5  =>  shipment_att5,
        	SHIPMENT_ATT6  =>  shipment_att6,
        	SHIPMENT_ATT7  =>  shipment_att7,
        	SHIPMENT_ATT8  =>  shipment_att8,
        	SHIPMENT_ATT9  =>  shipment_att9,
        	SHIPMENT_ATT10  =>  shipment_att10,
        	SHIPMENT_ATT11  =>  shipment_att11,
        	SHIPMENT_ATT12  =>  shipment_att12,
        	SHIPMENT_ATT13  =>  shipment_att13,
        	SHIPMENT_ATT14  =>  shipment_att14,
        	SHIPMENT_ATT15  =>  shipment_att15,

        	DISTRIBUTION_ATT1  =>  distribution_att1,
        	DISTRIBUTION_ATT2  =>  distribution_att2,
        	DISTRIBUTION_ATT3  =>  distribution_att3,
        	DISTRIBUTION_ATT4  =>  distribution_att4,
        	DISTRIBUTION_ATT5  =>  distribution_att5,
        	DISTRIBUTION_ATT6  =>  distribution_att6,
        	DISTRIBUTION_ATT7  =>  distribution_att7,
        	DISTRIBUTION_ATT8  =>  distribution_att8,
        	DISTRIBUTION_ATT9  =>  distribution_att9,
        	DISTRIBUTION_ATT10  =>  distribution_att10,
        	DISTRIBUTION_ATT11  =>  distribution_att11,
        	DISTRIBUTION_ATT12  =>  distribution_att12,
        	DISTRIBUTION_ATT13  =>  distribution_att13,
        	DISTRIBUTION_ATT14  =>  distribution_att14,
        	DISTRIBUTION_ATT15  =>  distribution_att15,

        	WIP_ENTITY_ID  =>  to_char(wip_entity_id),
        	WIP_ENTITY_TYPE  =>  wip_entity_type,
        	WIP_LINE_ID  =>  to_char(wip_line_id),
        	WIP_OPERATION_SEQ_NUM  =>  to_char(wip_operation_seq_num),
        	WIP_REPETITIVE_SCHEDULE_ID  =>  to_char(wip_repetitive_schedule_id),
        	WIP_RESOURCE_SEQ_NUM  =>  to_char(wip_resource_seq_num),

        	FB_FLEX_SEG   => fb_flex_seg,
        	FB_ERROR_MSG   => fb_error_msg );

	END IF;

	x_progress := 'After calling PO_PO_' || accountType || '_ACCOUNT.BUILD:fb_flex_seg:' || fb_flex_seg || ' fb_error_msg:' || fb_error_msg;
	IF (g_po_wf_debug = 'Y') THEN
   	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	END IF;

	return x_result_flag;

exception
	when others then
        wf_core.context('PO_WF_PO_FLEXBUILDER_UPGRADE','po_build_account',x_progress);
	IF (g_po_wf_debug = 'Y') THEN
   	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'EXCEPTION raised in po_build_account procedure');
	END IF;
        raise;

end po_build_account;

/*****************************************************************************
* 	 Local/Private procedure that support the workflow APIs:             *
*****************************************************************************/

procedure Get_att(itemtype in varchar2, itemkey in varchar2, variable in out NOCOPY varchar2, l_aname in varchar2)
is
begin

	variable := wf_engine.GetItemAttrText (   itemtype => itemtype,
                	                          itemkey  => itemkey,
                            	 	          aname    => l_aname);

end;

procedure Get_number_att(itemtype in varchar2, itemkey in varchar2, variable in out NOCOPY number,
			 l_aname in varchar2)
is
begin

	variable := wf_engine.GetItemAttrNumber (   itemtype => itemtype,
                	                            itemkey  => itemkey,
                            	 	            aname    => l_aname);

end;

procedure Get_date_att(itemtype in varchar2, itemkey in varchar2, variable in out NOCOPY date,
			 l_aname in varchar2)
is
begin

	variable := wf_engine.GetItemAttrDate (   itemtype => itemtype,
                	                          itemkey  => itemkey,
                            	 	          aname    => l_aname);

end;


end  PO_WF_PO_FLEXBUILDER_UPGRADE;

/
