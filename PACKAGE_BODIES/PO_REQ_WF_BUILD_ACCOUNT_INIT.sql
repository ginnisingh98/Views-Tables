--------------------------------------------------------
--  DDL for Package Body PO_REQ_WF_BUILD_ACCOUNT_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_WF_BUILD_ACCOUNT_INIT" AS
/* $Header: POXWRQSB.pls 120.1.12010000.3 2010/04/09 06:40:14 nitagarw ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWRQSB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_REQ_WF_BUILD_ACCOUNT_INIT
 |
 | NOTES        Imran Ali Created 9/9/97
 | MODIFIED    (MM/DD/YY)	  03/31/98
 |              David Chan        05/29/98 Modify for bug 669011
 *=======================================================================*/

/*
    * A Global variable to set the debug mode
*/
debug_acc_generator_wf BOOLEAN := FALSE;

/*****************************************************************************
* The following are local/Private procedure that support the workflow APIs:  *
*****************************************************************************/

PROCEDURE Call_WF_API_to_set_Att (ItemType varchar2, ItemKey varchar2,
				  aname varchar2, avalue varchar2);
PROCEDURE Call_WF_API_to_set_no_Att (ItemType varchar2, ItemKey varchar2,
				  aname varchar2, avalue number);
PROCEDURE Call_WF_API_to_set_date_Att (ItemType varchar2, ItemKey varchar2,
				  aname varchar2, avalue date);


/**************************************************************************************
* The following are the global APIs.						      *
**************************************************************************************/

--
--  Start_Workflow
--  Generates the itemkey, sets up the Item Attributes,
--  then starts the workflow process.
--
FUNCTION Start_Workflow (
   x_charge_success       IN OUT NOCOPY  BOOLEAN,  x_budget_success        IN OUT NOCOPY   BOOLEAN,
   x_accrual_success      IN OUT NOCOPY  BOOLEAN,  x_variance_success      IN OUT NOCOPY   BOOLEAN,
   x_code_combination_id  IN OUT NOCOPY  NUMBER,   x_budget_account_id     IN OUT NOCOPY   NUMBER,
   x_accrual_account_id   IN OUT NOCOPY  NUMBER,   x_variance_account_id   IN OUT NOCOPY   NUMBER,
   x_charge_account_flex  IN OUT NOCOPY  VARCHAR2, x_budget_account_flex   IN OUT NOCOPY   VARCHAR2,
   x_accrual_account_flex IN OUT NOCOPY  VARCHAR2, x_variance_account_flex IN OUT NOCOPY   VARCHAR2,
   x_charge_account_desc  IN OUT NOCOPY  VARCHAR2, x_budget_account_desc   IN OUT NOCOPY   VARCHAR2,
   x_accrual_account_desc IN OUT NOCOPY  VARCHAR2, x_variance_account_desc IN OUT NOCOPY   VARCHAR2,
   x_coa_id                       NUMBER,   x_bom_resource_id                NUMBER,
   x_bom_cost_element_id          NUMBER,   x_category_id                    NUMBER,
   x_destination_type_code        VARCHAR2, x_deliver_to_location_id         NUMBER,
   x_destination_organization_id  NUMBER,   x_destination_subinventory       VARCHAR2,
   x_expenditure_type             VARCHAR2,
   x_expenditure_organization_id  NUMBER,   x_expenditure_item_date          DATE,
   x_item_id                      NUMBER,   x_line_type_id                   NUMBER,
   x_result_billable_flag         VARCHAR2, x_preparer_id                    NUMBER,
   x_project_id                   NUMBER,
   x_document_type_code		  VARCHAR2,
   x_blanket_po_header_id	  NUMBER,
   x_source_type_code		  VARCHAR2,
   x_source_organization_id	  NUMBER,
   x_source_subinventory	  VARCHAR2,
   x_task_id                      NUMBER,   x_deliver_to_person_id           NUMBER,
   x_type_lookup_code             VARCHAR2, x_suggested_vendor_id            NUMBER,
   x_wip_entity_id                NUMBER,   x_wip_entity_type                VARCHAR2,
   x_wip_line_id                  NUMBER,   x_wip_repetitive_schedule_id     NUMBER,
   x_wip_operation_seq_num        NUMBER,   x_wip_resource_seq_num           NUMBER,
   x_po_encumberance_flag         VARCHAR2, x_gl_encumbered_date             DATE,
   WF_itemkey		  IN OUT NOCOPY  VARCHAR2, -- because of changes due to WF synch mode this input parameter is not used.
   x_new_combination	  IN OUT NOCOPY  BOOLEAN,

   header_att1  VARCHAR2, header_att2   VARCHAR2, header_att3  VARCHAR2, header_att4  VARCHAR2,
   header_att5  VARCHAR2, header_att6   VARCHAR2, header_att7  VARCHAR2, header_att8  VARCHAR2,
   header_att9   VARCHAR2, header_att10  VARCHAR2, header_att11  VARCHAR2,
   header_att12  VARCHAR2, header_att13  VARCHAR2, header_att14  VARCHAR2,header_att15  VARCHAR2,

   line_att1   VARCHAR2, line_att2   VARCHAR2, line_att3   VARCHAR2, line_att4   VARCHAR2,
   line_att5   VARCHAR2, line_att6   VARCHAR2, line_att7   VARCHAR2, line_att8   VARCHAR2,
   line_att9   VARCHAR2, line_att10  VARCHAR2, line_att11  VARCHAR2, line_att12  VARCHAR2,
   line_att13  VARCHAR2, line_att14  VARCHAR2, line_att15  VARCHAR2,

   distribution_att1   VARCHAR2, distribution_att2   VARCHAR2, distribution_att3   VARCHAR2,
   distribution_att4   VARCHAR2, distribution_att5   VARCHAR2, distribution_att6   VARCHAR2,
   distribution_att7   VARCHAR2, distribution_att8   VARCHAR2, distribution_att9   VARCHAR2,
   distribution_att10  VARCHAR2, distribution_att11  VARCHAR2, distribution_att12  VARCHAR2,
   distribution_att13  VARCHAR2, distribution_att14  VARCHAR2, distribution_att15  VARCHAR2,

   FB_ERROR_MSG               IN OUT NOCOPY VARCHAR2,
   x_award_id	              NUMBER default NULL, -- OGM_0.0 changes...
   x_suggested_vendor_site_id NUMBER default NULL, -- B1548597 Common Receiving RVK
   p_unit_price               IN NUMBER DEFAULT NULL,  --<BUG 3407630>
   p_blanket_po_line_num      IN NUMBER DEFAULT NULL   --<BUG 3611341>
) RETURN Boolean IS

ItemType                varchar2(8);
ccid			NUMBER;

-- Bug 752384: Increase the size of flexfield to 2000

concat_segs		varchar2(2000);
concat_ids		varchar2(240);
concat_descrs		varchar2(2000);

x_block_activity_label  varchar2(60);
x_insert_if_new		BOOLEAN := TRUE;
x_new_ccid_generated	BOOLEAN := FALSE;
x_success		BOOLEAN;
x_progress              varchar2(5000);
x_appl_short_name       varchar2(40);
x_flex_field_code       varchar2(150);
x_flex_field_struc_num  number;                        -- x_coa_id

was_ccid_passed_in_from_form     BOOLEAN := FALSE;

-- PA project accounting parameters to the WF

  l_class_code			pa_class_codes.class_code%TYPE;
  l_direct_flag			pa_project_types_all.direct_flag%TYPE;
  l_expenditure_category	pa_expenditure_categories.expenditure_category%TYPE;
  l_expenditure_org_name	hr_organization_units.name%TYPE;
  l_project_number		pa_projects_all.segment1%TYPE;
  l_project_organization_name	hr_organization_units.name%TYPE;
  l_project_organization_id	hr_organization_units.organization_id %TYPE;
  l_project_type		pa_project_types_all.project_type%TYPE;

  l_public_sector_flag		pa_projects_all.public_sector_flag%TYPE;
  l_revenue_category		pa_expenditure_types.revenue_category_code%TYPE;
  l_task_number			pa_tasks.task_number%TYPE;
  l_task_organization_name	hr_organization_units.name%TYPE;
  l_task_organization_id	hr_organization_units.organization_id %TYPE;
  l_task_service_type		pa_tasks.service_type_code%TYPE;
  l_top_task_id			pa_tasks.task_id%TYPE;
  l_top_task_number		pa_tasks.task_number%TYPE;
  l_vendor_employee_id		per_people_f.person_id%TYPE;
  l_vendor_employee_number	per_people_f.employee_number%TYPE;
  l_vendor_type			po_vendors.vendor_type_lookup_code%TYPE;

BEGIN
/*
  If (debug_acc_generator_wf) then
 	dbms_output.put_line ('Beginning  Account Generation');
  end if;
*/
/* Bug 2249061. Added the following code to clear the temporary cache
                before calling the workflow so that there will be no
                errors in the account generator workflow.
*/


  -- Note from bug5075361: We probably don't need to keep the clearcache
  -- at the beginning of the procedure since they're called at the end
  -- but it doesn't hurt to keep them anyway
  WF_ENGINE_UTIL.CLEARCACHE;
  WF_ACTIVITY.CLEARCACHE;
  WF_ITEM_ACTIVITY_STATUS.CLEARCACHE;
  WF_ITEM.CLEARCACHE;
  WF_PROCESS_ACTIVITY.CLEARCACHE;


-- Bug 2249061. Changes End.


  ItemType := 'POWFRQAG';            -- PO Requisition Account Generator Workflow
  x_appl_short_name      := 'SQLGL';
  x_flex_field_code      := 'GL#';
  x_flex_field_struc_num := x_coa_id;

  WF_ItemKey := FND_FLEX_WORKFLOW.INITIALIZE (x_appl_short_name, x_flex_field_code, x_flex_field_struc_num, ItemType);

/*  If (debug_acc_generator_wf) then dbms_output.put_line ('WF Itemkey is : ' || WF_ItemKey);  end if;
*/

  x_progress :=  'ITEM KEY FOR REQ ACCOUNT:' || WF_ItemKey;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,WF_ItemKey,x_progress);
  END IF;

  IF  ( ItemType is not NULL ) AND ( WF_ItemKey is not NULL)  THEN
        	-- Initialize workflow item attributes
        	--
	IF (x_project_id IS NOT NULL) THEN

        	-- Calling AP routine to get raw and derived parameters for project accounting accounts.

		BEGIN

	   	x_progress :=  'Calling pa_acc_gen_wf_pkg.wf_acc_derive_params with project_id:' ||
			   to_char(x_project_id);
	   	IF (g_po_wf_debug = 'Y') THEN
   	   	/* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,WF_ItemKey,x_progress);
	   	END IF;

           	pa_acc_gen_wf_pkg.wf_acc_derive_params (p_project_id => x_project_id,
                				p_task_id  => x_task_id,
                				p_expenditure_type  => x_expenditure_type,
                				p_vendor_id  => x_suggested_vendor_id,
                       				p_expenditure_organization_id => x_expenditure_organization_id,
                				p_expenditure_item_date => x_expenditure_item_date,
                     				x_class_code  => l_class_code,
                				x_direct_flag => l_direct_flag,
                				x_expenditure_category  => l_expenditure_category,
                      				x_expenditure_org_name  => l_expenditure_org_name,
                				x_project_number  => l_project_number,
                				x_project_organization_name => l_project_organization_name,
                				x_project_organization_id => l_project_organization_id,
                				x_project_type => l_project_type,
                				x_public_sector_flag => l_public_sector_flag,
                				x_revenue_category => l_revenue_category,
                				x_task_number => l_task_number,
                				x_task_organization_name => l_task_organization_name,
                				x_task_organization_id => l_task_organization_id,
                				x_task_service_type => l_task_service_type,
                				x_top_task_id => l_top_task_id,
                				x_top_task_number => l_top_task_number,
                				x_vendor_employee_id => l_vendor_employee_id,
                				x_vendor_employee_number => l_vendor_employee_number,
                				x_vendor_type => l_vendor_type);
		EXCEPTION
			when others then
			NULL;
		END;

	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'CLASS_CODE', l_class_code);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DIRECT_FLAG', l_direct_flag);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'EXPENDITURE_CATEGORY', l_expenditure_category);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'EXPENDITURE_ORG_NAME', l_expenditure_org_name);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'PROJECT_NUMBER', l_project_number);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'PROJECT_ORGANIZATION_NAME', l_project_organization_name);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'PROJECT_ORGANIZATION_ID', l_project_organization_id);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'PROJECT_TYPE', l_project_type);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'PUBLIC_SECTOR_FLAG', l_public_sector_flag);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'REVENUE_CATEGORY', l_revenue_category);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'TASK_NUMBER', l_task_number);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'TASK_ORGANIZATION_NAME', l_task_organization_name);
	   	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'TASK_ORGANIZATION_ID', l_task_organization_id);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'TASK_SERVICE_TYPE', l_task_service_type);
	   	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'TOP_TASK_ID', l_top_task_id);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'TOP_TASK_NUMBER', l_top_task_number);
	   	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'VENDOR_EMPLOYEE_ID', l_vendor_employee_id);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'VENDOR_EMPLOYEE_NUMBER', l_vendor_employee_number);
	   	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'VENDOR_TYPE', l_vendor_type);

                -- -----------------------------------------------------------------------
		-- OGM_0.0 changes . Set award_id into award_set_id item attribute..
		-- OGM stores award_set_id into award_id and award_id is derived from
		-- award_distribution table.
		-- ------------------------------------------------------------------------
		IF x_award_id is not NULL then
	   		Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'AWARD_SET_ID', x_award_id); -- OGM_0.0 changes...
		END IF ;

	END IF;

	-- done setting AP project accounting attributes.

	IF (ItemType IN ('POWFRQBA', 'POWFRQAA', 'POWFRQVA')) THEN
	   Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'CODE_COMBINATION_ID', x_code_combination_id);
     	END IF;

    	IF (ItemType IN ('POWFRQAA', 'POWFRQVA')) THEN
	   Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'BUDGET_ACCOUNT_ID', x_budget_account_id);
    	END IF;

    	IF (ItemType IN ('POWFRQVA')) THEN
	   Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'ACCRUAL_ACCOUNT_ID', x_accrual_account_id);
    	END IF;

	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'CHART_OF_ACCOUNTS_ID', x_coa_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'BOM_COST_ELEMENT_ID', x_bom_cost_element_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'BOM_RESOURCE_ID', x_bom_resource_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'CATEGORY_ID', x_category_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'DELIVER_TO_LOCATION_ID', x_deliver_to_location_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'DESTINATION_ORGANIZATION_ID',
							x_destination_organization_id);
	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DESTINATION_SUBINVENTORY',
							x_destination_subinventory);

	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DESTINATION_TYPE_CODE', x_destination_type_code);

	wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                       itemkey    =>  WF_ItemKey,
                	               aname      =>  'PO_ENCUMBRANCE_FLAG',
                        	       avalue     =>  x_po_encumberance_flag );

-- Header

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT1',  header_att1);
	If header_att1 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT1',
                        	               avalue     =>  header_att1 );
	   exception when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT2',  header_att2);
	If header_att2 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT2',
                        	               avalue     =>  header_att2 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT3',  header_att3);
	If header_att3 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT3',
                        	               avalue     =>  header_att3 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT4',  header_att4);
	If header_att4 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT4',
                        	               avalue     =>  header_att4 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, ItemKey, 'HEADER_ATT5',  header_att5);
	If header_att5 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT5',
                        	               avalue     =>  header_att5 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT6',  header_att6);
	If header_att6 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT6',
                        	               avalue     =>  header_att6 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT7',  header_att7);
	If header_att7 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT7',
                        	               avalue     =>  header_att7 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT8',  header_att8);
	If header_att8 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT8',
                        	               avalue     =>  header_att8 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT9',  header_att9);
	If header_att9 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT9',
                        	               avalue     =>  header_att9 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT10', header_att10);
	If header_att10 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT10',
                        	               avalue     =>  header_att10 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT11', header_att11);
	If header_att11 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT11',
                        	               avalue     =>  header_att11 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT12', header_att12);
	If header_att12 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT12',
                        	               avalue     =>  header_att12 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT13', header_att13);
	If header_att13 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT13',
                        	               avalue     =>  header_att13 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT14', header_att14);
	If header_att14 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT14',
                        	               avalue     =>  header_att14 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'HEADER_ATT15', header_att15);
	If header_att15 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'HEADER_ATT15',
                        	               avalue     =>  header_att15 );
	   exception  when others then
		null;
	   end;
	end if;

-- Line

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT1',  line_att1);
	If line_att1 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT1',
                        	               avalue     =>  line_att1 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT2',  line_att2);
	If line_att2 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT2',
                        	               avalue     =>  line_att2 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT3',  line_att3);
	If line_att3 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT3',
                        	               avalue     =>  line_att3 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT4',  line_att4);
	If line_att4 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT4',
                        	               avalue     =>  line_att4 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT5',  line_att5);
	If line_att5 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT5',
                        	               avalue     =>  line_att5 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT6',  line_att6);
	If line_att6 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT6',
                        	               avalue     =>  line_att6 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT7',  line_att7);
	If line_att7 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT7',
                        	               avalue     =>  line_att7 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT8',  line_att8);
	If line_att8 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT8',
                        	               avalue     =>  line_att8 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT9',  line_att9);
	If line_att9 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT9',
                        	               avalue     =>  line_att9 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT10', line_att10);
	If line_att10 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT10',
                        	               avalue     =>  line_att10 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT11', line_att11);
	If line_att11 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT11',
                        	               avalue     =>  line_att11 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT12', line_att12);
	If line_att12 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT12',
                        	               avalue     =>  line_att12 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT13', line_att13);
	If line_att13 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT13',
                        	               avalue     =>  line_att13 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT14', line_att14);
	If line_att14 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT14',
                        	               avalue     =>  line_att14 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'LINE_ATT15', line_att15);
	If line_att15 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'LINE_ATT15',
                        	               avalue     =>  line_att15 );
	   exception  when others then
		null;
	   end;
	end if;

-- Distribution

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT1',  distribution_att1);
	If distribution_att1 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT1',
                        	               avalue     =>  distribution_att1 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT2',  distribution_att2);
	If distribution_att2 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT2',
                        	               avalue     =>  distribution_att2 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT3',  distribution_att3);
	If distribution_att3 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT3',
                        	               avalue     =>  distribution_att3 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT4',  distribution_att4);
	If distribution_att4 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT4',
                        	               avalue     =>  distribution_att4 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT5',  distribution_att5);
	If distribution_att5 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT5',
                        	               avalue     =>  distribution_att5 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT6',  distribution_att6);
	If distribution_att6 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT6',
                        	               avalue     =>  distribution_att6 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT7',  distribution_att7);
	If distribution_att7 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT7',
                        	               avalue     =>  distribution_att7 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT8',  distribution_att8);
	If distribution_att8 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT8',
                        	               avalue     =>  distribution_att8 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT9',  distribution_att9);
	If distribution_att9 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT9',
                        	               avalue     =>  distribution_att9 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT10', distribution_att10);
	If distribution_att10 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT10',
                        	               avalue     =>  distribution_att10 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT11', distribution_att11);
	If distribution_att11 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT11',
                        	               avalue     =>  distribution_att11 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT12', distribution_att12);
	If distribution_att12 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT12',
                        	               avalue     =>  distribution_att12 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT13', distribution_att13);
	If distribution_att13 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT13',
                        	               avalue     =>  distribution_att13 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT14', distribution_att14);
	If distribution_att14 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT14',
                        	               avalue     =>  distribution_att14 );
	   exception  when others then
		null;
	   end;
	end if;

	-- Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DISTRIBUTION_ATT15', distribution_att15);
	If distribution_att15 is not null then
	   begin
		wf_engine.SetItemAttrText   (  itemtype   =>  itemtype,
        	                               itemkey    =>  WF_ItemKey,
                	                       aname      =>  'DISTRIBUTION_ATT15',
                        	               avalue     =>  distribution_att15 );
	   exception  when others then
		null;
	   end;
	end if;


	Call_WF_API_to_set_date_Att (ItemType, WF_ItemKey, 'EXPENDITURE_ITEM_DATE', x_expenditure_item_date);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'EXPENDITURE_ORGANIZATION_ID',
							x_expenditure_organization_id);
	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'EXPENDITURE_TYPE', x_expenditure_type);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'ITEM_ID', x_item_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'LINE_TYPE_ID', x_line_type_id);
	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'PA_BILLABLE_FLAG', x_result_billable_flag);

	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'PREPARER_ID', x_preparer_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'PROJECT_ID', x_project_id);

	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'DOCUMENT_TYPE_CODE', x_document_type_code);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'BLANKET_PO_HEADER_ID', x_blanket_po_header_id);
	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'SOURCE_TYPE_CODE', x_source_type_code);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'SOURCE_ORGANIZATION_ID',
							x_source_organization_id);
	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'SOURCE_SUBINVENTORY', x_source_subinventory);

	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'TASK_ID', x_task_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'TO_PERSON_ID', x_deliver_to_person_id);
	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'TYPE_LOOKUP_CODE', x_type_lookup_code);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'SUGGESTED_VENDOR_ID', x_suggested_vendor_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'VENDOR_SITE_ID', x_suggested_vendor_site_id); /* B1548597 Common Receiving RVK */
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'WIP_ENTITY_ID', x_wip_entity_id);


	Call_WF_API_to_set_Att (ItemType, WF_ItemKey, 'WIP_ENTITY_TYPE', x_wip_entity_type);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'WIP_LINE_ID', x_wip_line_id );
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'WIP_OPERATION_SEQ_NUM', x_wip_operation_seq_num);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'WIP_REPETITIVE_SCHEDULE_ID',
							x_wip_repetitive_schedule_id);
	Call_WF_API_to_set_no_Att (ItemType, WF_ItemKey, 'WIP_RESOURCE_SEQ_NUM', x_wip_resource_seq_num);

        --<BUG 3407630 START>
        --Call WF API to set unit_price attribute.
        --unit_price will be taken into consideration when generating accounts.

        PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype   =>  itemtype,
        	                          itemkey    =>  wf_itemkey,
                	                  aname      =>  'UNIT_PRICE',
                        	          avalue     =>  p_unit_price);

   	IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype,
                                       wf_itemkey,
                                       'Set WF item UNIT_PRICE to ' ||
                                        PO_WF_UTIL_PKG.GetItemAttrNumber (
                                                  itemtype   =>  itemtype,
        	                                  itemkey    =>  wf_itemkey,
                	                          aname      =>  'UNIT_PRICE'));
	END IF;
        --<BUG 3407630 END>

        --<BUG 3611341 START>
        -- Call WF API to set blanket_po_line_num attribute.
        -- blanket_po_line_num will be taken into consideration when generating accounts.
        PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype => itemtype,
                                         itemkey  => wf_itemkey,
                                         aname    => 'BLANKET_PO_LINE_NUM',
                                         avalue   => p_blanket_po_line_num);

        IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype, wf_itemkey,
                                       'Set WF item BLANKET_PO_LINE_NUM to ' ||
                                       PO_WF_UTIL_PKG.GetItemAttrNumber(
                                       itemtype => itemtype,
                                       itemkey  => wf_itemkey,
                                       aname    => 'BLANKET_PO_LINE_NUM'));
        END IF;
        --<BUG 3611341 END>


	-- Done setting WF item attributes

	if x_code_combination_id is null then

           x_progress :=  'FND_FLEX_WORKFLOW.GENERATE: Before call';
           IF (g_po_wf_debug = 'Y') THEN
              /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,WF_ItemKey,x_progress);
           END IF;

/*	   If (debug_acc_generator_wf) then  dbms_output.put_line ('Calling generate to build Charge Account'); end if;
*/

	   x_block_activity_label := NULL;

           -- Bug 1497909 : Set the encumbrance date for validation
           po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

	   x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL ( ItemType,
						  	  WF_ItemKey,
							  'DEFAULT_CHARGE_ACC_GENERATION',
							  x_block_activity_label,
							  x_insert_if_new,
						  	  ccid,
						  	  concat_segs,
						  	  concat_ids,
						  	  concat_descrs,
						  	  FB_ERROR_MSG,
							  x_new_combination );

	   if (x_success  and ( ccid is null or ccid = 0 or ccid = -1 )) then

		-- Complete the blocked workflow as it may be running in synch mode and cause problems for consequent
		-- account generation runs for this session.
		begin
			wf_engine.CompleteActivity(itemtype, wf_itemkey, 'BLOCK_BUDGET_ACC_GENERATION', 'FAILURE');
		exception
			when others then
			IF (g_po_wf_debug = 'Y') THEN
   			PO_WF_DEBUG_PKG.insert_debug(itemtype,wf_itemkey,'Exception when completing WF' ||  Wf_Itemkey);
			END IF;
--			DBMS_OUTPUT.put_line ('Exception completing blocked WF');
		end;
	   end if;

	   x_charge_success := x_success;

	   if x_new_combination then
		x_new_ccid_generated	:= TRUE;
		-- commit; Need this commit else the entire GL_CODE_COMBINATIONS table will be locked. commit in form.
	   end if;

	   -- Copy the returned value into appropriate function parameters to pass them
	   -- back to the form.

           x_progress :=  'ccid:' || to_char(ccid) || ' concat_segs:' || concat_segs || ' concat_ids:' || concat_ids ||
			' concat_descrs:' || concat_descrs || ' FB_ERROR_MSG:' || FB_ERROR_MSG;
           IF (g_po_wf_debug = 'Y') THEN
              /* DEBUG */ PO_WF_DEBUG_PKG.insert_debug(itemtype,WF_ItemKey,x_progress);
           END IF;

	   x_code_combination_id := ccid;
           x_charge_account_flex := concat_segs;
           x_charge_account_desc := concat_descrs;

	   was_ccid_passed_in_from_form := false;

	else

	   x_charge_success := TRUE;
	   x_success := TRUE;
	   was_ccid_passed_in_from_form := true;

	end if;


     	If (x_success and (x_code_combination_id IS NOT NULL) and (x_code_combination_id <> 0) and
		(x_code_combination_id <> -1))   then

		wf_engine.SetItemAttrNumber (  itemtype   =>  itemtype,
        	        	               itemkey    =>  WF_ItemKey,
                	        	       aname      =>  'CODE_COMBINATION_ID',
                        	               avalue     =>  x_code_combination_id );

		x_charge_success := x_success;

		-- Generate Budget Account if encumbrance is on

		if ((x_po_encumberance_flag = 'Y')  and (x_destination_type_code <> 'SHOP FLOOR'
                                                         OR (x_destination_type_code = 'SHOP FLOOR' AND x_wip_entity_type = 6))) then
         /* Condition added for Encumbrance Project - To enable Encumbrance for Destination type Shop Floor and WIP entity type EAM   */
/*		    If (debug_acc_generator_wf) then dbms_output.put_line ('Calling generate to build Budget Account'); end if;
*/
		    if was_ccid_passed_in_from_form = false then
		       x_block_activity_label := 'BLOCK_BUDGET_ACC_GENERATION';
                    else
                       x_block_activity_label := NULL;
                    end if;

                    -- Bug 1497909 : Set the encumbrance date for validation
                    po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

		    x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL ( 	ItemType,
						  	  	      	WF_ItemKey,
									'DEFAULT_BUDGET_ACC_GENERATION',
							  		x_block_activity_label,
									x_insert_if_new,
						  	  		ccid,
						  	  		concat_segs,
						  	  		concat_ids,
						  	  		concat_descrs,
						  	  		FB_ERROR_MSG,
									x_new_combination);
		    x_budget_success := x_success;

	   	    if x_new_combination then
			x_new_ccid_generated	:= TRUE;
	   	    end if;

		    x_budget_account_id := ccid;
		    x_budget_account_flex := concat_segs;
		    x_budget_account_desc := concat_descrs;


        	    x_progress :=  'ccid:' || to_char(ccid) || ' concat_segs:' || concat_segs || ' concat_ids:' ||
				    concat_ids || ' concat_descrs:' || concat_descrs || ' FB_ERROR_MSG:' ||
				    FB_ERROR_MSG;

	        else
			x_success := TRUE;
		        x_budget_success := x_success;
		end if;

		if x_success then

		    wf_engine.SetItemAttrNumber (  itemtype   =>  itemtype,
        	        	                   itemkey    =>  WF_ItemKey,
                	        	           aname      =>  'BUDGET_ACCOUNT_ID',
                        	        	   avalue     =>  x_budget_account_id );

		    -- Generate Accrual Account

/*		    If (debug_acc_generator_wf) then dbms_output.put_line ('Calling generate to build Accrual Account'); end if;
*/
                    if was_ccid_passed_in_from_form = false then
                       if ((x_po_encumberance_flag = 'Y')  and (x_destination_type_code <> 'SHOP FLOOR'
                                                           OR (x_destination_type_code = 'SHOP FLOOR' AND x_wip_entity_type = 6))) then
 /* Condition added for Encumbrance Project - To enable Encumbrance for Destination type Shop Floor and WIP entity type EAM   */

		    	   x_block_activity_label := 'BLOCK_ACCRUAL_ACC_GENERATION';
		       else
		    	   x_block_activity_label := 'BLOCK_BUDGET_ACC_GENERATION';
		       end if;
                    else
                       if ((x_po_encumberance_flag = 'Y')  and (x_destination_type_code <> 'SHOP FLOOR'
                                                            OR (x_destination_type_code = 'SHOP FLOOR' AND x_wip_entity_type = 6)))  then
/* Condition added for Encumbrance Project - To enable Encumbrance for Destination type Shop Floor and WIP entity type EAM   */		    	                      x_block_activity_label := 'BLOCK_ACCRUAL_ACC_GENERATION';
		       else
		    	   x_block_activity_label := NULL;
		       end if;
                    end if;

                    -- Bug 1497909 : Set the encumbrance date for validation
                    po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

		    x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL ( 	ItemType,
						  	  	      	WF_ItemKey,
							  		'DEFAULT_ACCRUAL_ACC_GENERATION',
							  		x_block_activity_label,
									x_insert_if_new,
						  	  		ccid,
						  	  		concat_segs,
						  	  		concat_ids,
						  	  		concat_descrs,
						  	  		FB_ERROR_MSG,
									x_new_combination );
		    x_accrual_success := x_success;

	   	    if x_new_combination then
			x_new_ccid_generated	:= TRUE;
	   	    end if;

		    x_accrual_account_id := ccid;
		    x_accrual_account_flex := concat_segs;
		    x_accrual_account_desc := concat_descrs;


        	    x_progress :=  'ccid:' || to_char(ccid) || ' concat_segs:' || concat_segs || ' concat_ids:' ||
				    concat_ids || ' concat_descrs:' || concat_descrs || ' FB_ERROR_MSG:' ||
				    FB_ERROR_MSG;

		    If x_success then

		        wf_engine.SetItemAttrNumber (  itemtype   =>  itemtype,
        	        	                       itemkey    =>  WF_ItemKey,
                	        	               aname      =>  'ACCRUAL_ACCOUNT_ID',
                        	        	       avalue     =>  x_accrual_account_id );

			-- Generate Variance Account
                        -- Bug 1497909 : Set the encumbrance date for validation
                        po_wf_util_pkg.SetItemAttrDate(itemtype   =>  itemtype,
                                        itemkey    =>  wf_itemkey,
                                        aname      =>  'ENCUMBRANCE_DATE',
                                        avalue     =>  x_gl_encumbered_date);

		    	x_success := FND_FLEX_WORKFLOW.GENERATE_PARTIAL ( ItemType,
						  	  	      	  WF_ItemKey,
							  		  'DEFAULT_VARIANCE_ACC_GENERATION',
							  		  'BLOCK_VARIANCE_ACC_GENERATION',
									  x_insert_if_new,
						  	  		  ccid,
						  	  		  concat_segs,
						  	  		  concat_ids,
						  	  		  concat_descrs,
						  	  		  FB_ERROR_MSG,
									  x_new_combination );

		    	x_variance_success := x_success;

	   	    	if x_new_combination then
				x_new_ccid_generated	:= TRUE;
	   	    	end if;

			x_variance_account_id := ccid;
			x_variance_account_flex := concat_segs;
			x_variance_account_desc := concat_descrs;


        		x_progress :=  'ccid:' || to_char(ccid) || ' concat_segs:' || concat_segs || ' concat_ids:'
					|| concat_ids || ' concat_descrs:' || concat_descrs || ' FB_ERROR_MSG:' ||
					FB_ERROR_MSG;

/*			If (debug_acc_generator_wf) then
				if (not x_success) then
					dbms_output.put_line (' va failed');
				end if;
			end if;
*/

			x_new_combination := x_new_ccid_generated;

                        PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361

			return (x_success);

		    else		-- accrual acc failed.

/*			If (debug_acc_generator_wf) then
				dbms_output.put_line (' aa failed');
			end if;   */

                        PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361

			return (x_success);

		    end if;

		else			-- budget acc failed.

/*			If (debug_acc_generator_wf) then
				dbms_output.put_line (' ba failed');
			end if;    */

                        PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361

			return (x_success);
		end if;


	else		-- charge acc failed.

/*		If (debug_acc_generator_wf) then  dbms_output.put_line (' ca failed');  end if;
*/

                PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361

		return (x_success);

     	end if;

        PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361

     	return x_success;
  ELSE

	FB_ERROR_MSG := 'Invalid Item Type OR Item Key';

        PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361

	return FALSE;
  END IF;

EXCEPTION
 WHEN OTHERS THEN

   PO_WF_UTIL_PKG.clear_wf_cache; -- bug5075361

   po_message_s.sql_error('PO_REQ_WF_BUILD_ACCOUNT_INIT.Start_Workflow', x_progress, sqlcode);
   RAISE;

END Start_Workflow;


/*
    * Set the debug mode on
*/

PROCEDURE debug_on IS
BEGIN
        debug_acc_generator_wf := TRUE;

        PO_WF_PO_CHARGE_ACC.debug_on;
        PO_WF_PO_BUDGET_ACC.debug_on;
--        PO_WF_PO_ACCRUAL_ACC.debug_on;
--        PO_WF_PO_VARIANCE_ACC.debug_on;

END debug_on;

/*
    * Set the debug mode off
*/

PROCEDURE debug_off IS
BEGIN
        debug_acc_generator_wf := FALSE;

        PO_WF_PO_CHARGE_ACC.debug_off;
        PO_WF_PO_BUDGET_ACC.debug_off;
--        PO_WF_PO_ACCRUAL_ACC.debug_off;
--        PO_WF_PO_VARIANCE_ACC.debug_off;

END debug_off;


-- ************************************************************************************ --
/*
	PRIVATE PROCEDURES / FUNCTIONS
*/
-- ************************************************************************************ --


PROCEDURE Call_WF_API_to_set_Att (ItemType varchar2, ItemKey varchar2, aname varchar2,
				  avalue varchar2)
IS
BEGIN

	wf_engine.SetItemAttrText (    itemtype   =>  itemtype,
                                       itemkey    =>  itemkey,
                                       aname      =>  aname,
                                       avalue     =>  avalue );
END Call_WF_API_to_set_Att;

PROCEDURE Call_WF_API_to_set_no_Att (ItemType varchar2, ItemKey varchar2, aname varchar2,
				  avalue number)
IS
BEGIN

	wf_engine.SetItemAttrNumber (  itemtype   =>  itemtype,
                                       itemkey    =>  itemkey,
                                       aname      =>  aname,
                                       avalue     =>  avalue );
END Call_WF_API_to_set_no_Att;

PROCEDURE Call_WF_API_to_set_date_Att (ItemType varchar2, ItemKey varchar2, aname varchar2,
				  avalue date)
IS
BEGIN

	wf_engine.SetItemAttrDate (    itemtype   =>  itemtype,
                                       itemkey    =>  itemkey,
                                       aname      =>  aname,
                                       avalue     =>  avalue );
END Call_WF_API_to_set_date_Att;

end  PO_REQ_WF_BUILD_ACCOUNT_INIT;

/
