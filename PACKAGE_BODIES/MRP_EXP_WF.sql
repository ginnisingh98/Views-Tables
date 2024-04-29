--------------------------------------------------------
--  DDL for Package Body MRP_EXP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_EXP_WF" AS
/*$Header: MRPEXWFB.pls 120.1 2005/08/29 07:15:29 gmalhotr noship $ */

PROCEDURE launch_workflow(errbuf             OUT NOCOPY VARCHAR2,
		          retcode            OUT NOCOPY NUMBER,
                          p_owning_org_id    IN  NUMBER,
                          p_designator       IN  VARCHAR2) IS

  CURSOR EXCEPTION_DETAILS_C IS
    SELECT exp.exception_id,
           exp.organization_id,
	   exp.inventory_item_id,
           exp.exception_type,
	   exp.organization_code,
	   exp.item_segments,
	   exp.exception_type_text,
	   NVL(exp.project_number, 'N/A'),
	   NVL(exp.to_project_number, 'N/A'),
	   NVL(exp.task_number, 'N/A'),
	   NVL(exp.to_task_number, 'N/A'),
	   exp.planning_group,
	   exp.due_date,
	   exp.from_date,
	   exp.to_date,
	   exp.days_compressed,
	   exp.quantity,
	   exp.lot_number,
	   exp.order_number,
	   exp.supply_type,
	   exp.end_item_segments,
	   exp.end_order_number,
           exp.department_line_code,
	   exp.resource_code,
	   exp.utilization_rate
    FROM   mrp_exception_details_v exp, mrp_plan_organizations_v mpo
    WHERE  exp.exception_type in (1,2,3,6,7,8,9,10,12,13,14,15,16,17,18,19,20)
    AND    mpo.organization_id = p_owning_org_id
    AND    mpo.compile_designator = p_designator
    AND    exp.organization_id = mpo.planned_organization
    AND    exp.compile_designator = mpo.compile_designator
    ORDER BY exp.exception_id;

  CURSOR SUPPLIER_C(p_exception_id in number) IS
    SELECT vend.vendor_id,
	   vend.vendor_name
    FROM   po_vendors vend,
           mrp_recommendations rec,
	   mrp_exception_details_v exp
    WHERE  vend.vendor_id = rec.vendor_id
    AND    rec.transaction_id = exp.transaction_id
    AND    exp.exception_id = p_exception_id;

  CURSOR SUPPLIER_SITE_C(p_exception_id in number) IS
    SELECT vend.vendor_id,
	   vend.vendor_name,
	   site.vendor_site_id,
	   site.vendor_site_code
    FROM   po_vendor_sites_all site,
	   po_headers_all poh,
	   po_vendors vend,
	   mrp_item_purchase_orders ipo,
	   mrp_recommendations rec,
	   mrp_exception_details_v exp
    WHERE  site.vendor_site_id = poh.vendor_site_id
    AND    site.org_id = poh.org_id
    AND    poh.po_header_id = ipo.purchase_order_id
    AND    ipo.transaction_id = rec.disposition_id
    AND    vend.vendor_id = rec.vendor_id
    AND    rec.transaction_id = exp.transaction_id
    AND    exp.exception_id = p_exception_id;

 CURSOR CUSTOMER_C(p_exception_id in number) IS
    SELECT cust.cust_account_id,
	   part.party_name
    FROM   hz_cust_accounts cust,
	   hz_parties part,
	   oe_order_headers_all soh,
           oe_order_types_v sot,
	   mtl_sales_orders mso,
	   mrp_schedule_dates dates,
	   mrp_gross_requirements mgr,
	   mrp_exception_details_v exp
    WHERE  cust.cust_account_id = soh.sold_to_org_id
    AND    soh.order_number = to_number(mso.segment1)
    AND    soh.order_type_id = sot.order_type_id
    AND    sot.name = mso.segment2
    AND    mso.sales_order_id = dates.source_sales_order_id
    AND    dates.supply_demand_type = 1
    AND    dates.schedule_level = 3
    AND    dates.mps_transaction_id = mgr.disposition_id
    AND    mgr.origination_type = 6
    AND    mgr.demand_id = exp.demand_id
    AND    exp.exception_id = p_exception_id
    AND    cust.party_id = part.party_id;

  l_cursor			varchar2(30);

  l_exception_id 		number;
  l_organization_id		number;
  l_inventory_item_id		number;
  l_exception_type		number;
  l_organization_code		varchar2(3);
  l_item_segments		varchar2(40);
  l_exception_type_text		varchar2(80);
  l_project_number		varchar2(4000);
  l_to_project_number		varchar2(4000);
  l_task_number			varchar2(4000);
  l_to_task_number		varchar2(4000);
  l_planning_group		varchar2(80);
  l_due_date			date;
  l_from_date			date;
  l_to_date			date;
  l_days_compressed		number;
  l_quantity			varchar2(40);
  l_lot_number			varchar2(30);
  l_order_number		varchar2(4000);
  l_order_type_code		number		:= to_number(NULL);
  l_supply_type			varchar2(80);
  l_end_item_segments		varchar2(40);
  l_end_order_number		varchar2(4000);
  l_department_line_code	varchar2(10);
  l_resource_code		varchar2(10);
  l_utilization_rate		number;
  l_vendor_id			number		:= to_number(NULL);
  l_vendor_name			varchar2(240)	:= 'N/A';         -- UTF8 Change
  l_vendor_site_id		number		:= to_number(NULL);
  l_vendor_site_code		varchar2(15)	:= 'N/A';
  l_customer_id			number		:= to_number(NULL);
  l_customer_name		varchar2(80)	:= 'N/A';
  l_workflow_process		varchar2(40);
  l_plan_type			number;
  l_org_selection		number;
  l_workbench_function		varchar2(30);
  l_min_exception_id		number;
  l_max_exception_id		number;
  l_counter			number := 1;

BEGIN

  -- Cancel notifications from previous plan run and force completion of
  -- workflows.

  DeleteActivities(p_designator, p_owning_org_id);

  l_cursor := 'EXCEPTION_DETAILS_C';
  OPEN EXCEPTION_DETAILS_C;
  LOOP
    FETCH EXCEPTION_DETAILS_C INTO
      l_exception_id,
      l_organization_id,
      l_inventory_item_id,
      l_exception_type,
      l_organization_code,
      l_item_segments,
      l_exception_type_text,
      l_project_number,
      l_to_project_number,
      l_task_number,
      l_to_task_number,
      l_planning_group,
      l_due_date,
      l_from_date,
      l_to_date,
      l_days_compressed,
      l_quantity,
      l_lot_number,
      l_order_number,
      l_supply_type,
      l_end_item_segments,
      l_end_order_number,
      l_department_line_code,
      l_resource_code,
      l_utilization_rate;
    EXIT WHEN EXCEPTION_DETAILS_C%NOTFOUND OR EXCEPTION_DETAILS_C%NOTFOUND IS NULL;

/***** Bug 2410989 ****/
    l_vendor_id := NULL;
    l_vendor_name := NULL;
    l_vendor_site_id := NULL;
    l_vendor_site_code := NULL;
    l_customer_id := NULL;
    l_customer_name := NULL;
/**** Bug 2410989 ****/

    if (l_counter = 1) then

      l_min_exception_id := l_exception_id;

    end if;

    if (l_exception_type in (1, 2, 3, 12, 14, 16, 20)) then

      l_workflow_process := 'EXCEPTION_PROCESS1';

    elsif (l_exception_type in (6, 7, 8, 9, 10)) then

      l_workflow_process := 'EXCEPTION_PROCESS2';

      SELECT rec.order_type
      INTO   l_order_type_code
      FROM   mrp_recommendations rec,
             mrp_exception_details_v exp
      WHERE  rec.transaction_id = exp.transaction_id
      AND    exp.exception_id = l_exception_id;

      -- Purchase Order
      if (l_order_type_code = 1) then

        l_cursor := 'SUPPLIER_SITE_C';
	OPEN SUPPLIER_SITE_C(l_exception_id);
        LOOP
	  FETCH SUPPLIER_SITE_C INTO
	    l_vendor_id,
	    l_vendor_name,
	    l_vendor_site_id,
	    l_vendor_site_code;
	  EXIT WHEN SUPPLIER_SITE_C%NOTFOUND OR SUPPLIER_SITE_C%NOTFOUND IS NULL;
	END LOOP;
	CLOSE SUPPLIER_SITE_C;

      -- Purchase Requisition
      elsif (l_order_type_code = 2) then

        l_cursor := 'SUPPLIER_C';
	OPEN SUPPLIER_C(l_exception_id);
        LOOP
	  FETCH SUPPLIER_C INTO
	    l_vendor_id,
	    l_vendor_name;
	  EXIT WHEN SUPPLIER_C%NOTFOUND OR SUPPLIER_C%NOTFOUND IS NULL;
        END LOOP;
	CLOSE SUPPLIER_C;

      end if;

    elsif (l_exception_type in (13, 15)) then

      l_workflow_process := 'EXCEPTION_PROCESS3';

      l_cursor := 'CUSTOMER_C';
      OPEN CUSTOMER_C(l_exception_id);
      LOOP
        FETCH CUSTOMER_C INTO
          l_customer_id,
	  l_customer_name;
	EXIT WHEN CUSTOMER_C%NOTFOUND OR CUSTOMER_C%NOTFOUND IS NULL;
      END LOOP;
      CLOSE CUSTOMER_C;

    elsif (l_exception_type in (17, 18, 19)) then

      l_workflow_process := 'EXCEPTION_PROCESS4';

    end if;

    -- Determine planner workbench function to be launched from notifications

    l_cursor := 'WORKBENCH_C';
    SELECT NVL(plan_type, curr_plan_type),
           NVL(organization_selection, 1)
    INTO   l_plan_type,
           l_org_selection
    FROM   mrp_plans
    WHERE  organization_id = p_owning_org_id
    AND    compile_designator = p_designator;

    if (l_org_selection = 1) then       -- single org

      if (l_plan_type = 1) then     -- MRP plan
        l_workbench_function := 'MRPFPPWB-390';

      else                          -- MPS plan
        l_workbench_function := 'MRPFPPWB-392';

      end if;

    else                                -- multi org

      if (l_plan_type = 1) then     -- MRP plan
        l_workbench_function := 'MRPFPPWB-394';

      elsif (l_plan_type = 2) then  -- MPS plan
        l_workbench_function := 'MRPFPPWB-396';

      else                          -- DRP plan
        l_workbench_function := 'MRPFPPWB-398';

      end if;

    end if;


    l_cursor := 'StartWFProcess';

    StartWFProcess( 'MRPEXPWF',
	  	    to_char(l_exception_id),
		    p_designator,
		    l_organization_id,
		    l_inventory_item_id,
		    l_exception_type,
		    l_organization_code,
		    l_item_segments,
		    l_exception_type_text,
	            l_project_number,
		    l_to_project_number,
		    l_task_number,
		    l_to_task_number,
		    l_planning_group,
		    l_due_date,
		    l_from_date,
		    l_to_date,
		    l_days_compressed,
		    l_quantity,
		    l_lot_number,
		    l_order_number,
		    l_order_type_code,
		    l_supply_type,
		    l_end_item_segments,
	 	    l_end_order_number,
		    l_department_line_code,
		    l_resource_code,
		    l_utilization_rate,
		    l_vendor_id,
		    l_vendor_name,
		    l_vendor_site_id,
		    l_vendor_site_code,
		    l_customer_id,
		    l_customer_name,
                    l_workbench_function,
		    l_workflow_process);

  l_counter := l_counter + 1;

  END LOOP;

  l_max_exception_id := l_exception_id;

  CLOSE EXCEPTION_DETAILS_C;

  UPDATE mrp_plans
  SET    min_wf_except_id = l_min_exception_id,
         max_wf_except_id = l_max_exception_id
  WHERE  organization_id = p_owning_org_id
  AND    compile_designator = p_designator;

  COMMIT WORK;

  retcode := 0;

  l_cursor := 'End';

EXCEPTION

    WHEN NO_DATA_FOUND THEN
      null;

    WHEN OTHERS THEN
	errbuf := 'Error in mrp_exp_wf.launch_workflow function' ||
				' Cursor: ' || l_cursor || ' Exception ID: '
                                || l_exception_id ||
				' SQL error: ' || sqlerrm;
	retcode := 1;

END launch_workflow;



-- PROCEDURE
--   StartWFProcess
--
-- DESCRIPTION
--   Initiate workflow for exception message handling
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode. this is set by the engine
--               as either 'RUN', 'CANCEL', 'TIMEOUT'
-- OUT
--   result    - Name of workflow process to run
--

PROCEDURE StartWFProcess ( item_type            in varchar2 default null,
		           item_key	        in varchar2,
			   compile_designator   in varchar2,
			   organization_id      in number,
			   inventory_item_id    in number,
			   exception_type	in number,
			   organization_code    in varchar2,
			   item_segments        in varchar2,
			   exception_type_text  in varchar2,
			   project_number       in varchar2,
			   to_project_number    in varchar2,
			   task_number	        in varchar2,
			   to_task_number       in varchar2,
			   planning_group       in varchar2,
		  	   due_date		in date,
			   from_date	        in date,
			   to_date	        in date,
			   days_compressed      in number,
			   quantity	        in varchar2,
			   lot_number	        in varchar2,
			   order_number	        in varchar2,
			   order_type_code	in number,
			   supply_type	        in varchar2,
			   end_item_segments	in varchar2,
			   end_order_number	in varchar2,
			   department_line_code in varchar2,
			   resource_code        in varchar2,
			   utilization_rate     in number,
			   supplier_id		in number,
			   supplier_name	in varchar2,
			   supplier_site_id	in number,
			   supplier_site_code   in varchar2,
			   customer_id		in number,
			   customer_name	in varchar2,
                           workbench_function   in varchar2,
			   workflow_process     in varchar2 default null) is

BEGIN


  wf_engine.CreateProcess( itemtype => item_type,
			   itemkey  => item_key,
   			   process  => workflow_process);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'EXCEPTION_ID',
			       avalue   => to_number(item_key));

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
  			     aname    => 'PLAN_NAME',
 			     avalue   => compile_designator);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'ORGANIZATION_ID',
			       avalue   => organization_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'INVENTORY_ITEM_ID',
			       avalue   => inventory_item_id);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'EXCEPTION_TYPE_ID',
			       avalue   => exception_type);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORGANIZATION_CODE',
			     avalue   => organization_code);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ITEM_DISPLAY_NAME',
			     avalue   => item_segments);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'EXCEPTION_DESCRIPTION',
			     avalue   => exception_type_text);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'PROJECT_NUMBER',
		             avalue   => project_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_PROJECT_NUMBER',
			     avalue   => to_project_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TASK_NUMBER',
			     avalue   => task_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_TASK_NUMBER',
			     avalue   => to_task_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'PLANNING_GROUP',
			     avalue   => planning_group);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DUE_DATE',
			     avalue   => due_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'FROM_DATE',
			     avalue   => from_date);

  wf_engine.SetItemAttrDate( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'TO_DATE',
			     avalue   => to_date);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'DAYS_COMPRESSED',
			       avalue   => days_compressed);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'QUANTITY',
			     avalue   => quantity);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'LOT_NUMBER',
			     avalue   => lot_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORDER_NUMBER',
			     avalue   => order_number);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'ORDER_TYPE_CODE',
			       avalue   => order_type_code);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLY_TYPE',
			     avalue   => supply_type);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ITEM_DISPLAY_NAME',
			     avalue   => end_item_segments);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ORDER_NUMBER',
			     avalue   => end_order_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'DEPARTMENT_LINE_CODE',
			     avalue   => department_line_code);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'RESOURCE_CODE',
			     avalue   => resource_code);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'UTILIZATION_RATE',
			       avalue   => utilization_rate);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'SUPPLIER_ID',
			       avalue   => supplier_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_NAME',
			     avalue   => supplier_name);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'SUPPLIER_SITE_ID',
			       avalue   => supplier_site_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'SUPPLIER_SITE_CODE',
			     avalue   => supplier_site_code);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'CUSTOMER_ID',
			       avalue   => customer_id);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'CUSTOMER_NAME',
			     avalue   => customer_name);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
                             aname    => 'PLANNER_WORKBENCH',
                             avalue   => (workbench_function ||
                                          ': compile_designator_qf=' ||
                                          compile_designator || ' org_id=' ||
                                          to_char(organization_id)) );

  wf_engine.StartProcess( itemtype => item_type,
			  itemkey  => item_key);

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'StartWFProcess', item_key, compile_designator, organization_code, item_segments, to_char(exception_type));
    raise;

END StartWFProcess;



PROCEDURE DetermineProceed( itemtype  in varchar2,
			    itemkey   in varchar2,
			    actid     in number,
			    funcmode  in varchar2,
			    resultout out NOCOPY varchar2 ) is

  CURSOR CHK_PRODUCTION_C(p_compile_designator in varchar2,
                          p_organization_id    in number) IS
    SELECT production
    FROM   mrp_plans_sc_v
/** Bug 2286190 WHERE  organization_id = p_organization_id **/
    WHERE  planned_organization  =  p_organization_id
    AND    compile_designator = p_compile_designator;

  l_compile_designator	varchar2(10) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'PLAN_NAME');

  l_organization_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'ORGANIZATION_ID');

  l_production_flag	number := 2;

BEGIN

  if (funcmode = 'RUN') then

    OPEN CHK_PRODUCTION_C(l_compile_designator, l_organization_id);
    LOOP
      FETCH CHK_PRODUCTION_C INTO l_production_flag;
      EXIT WHEN CHK_PRODUCTION_C%NOTFOUND OR CHK_PRODUCTION_C%NOTFOUND IS NULL;
    END LOOP;
    CLOSE CHK_PRODUCTION_C;

    --l_production_flag := 1;

    if (l_production_flag = 1) then

      resultout := 'COMPLETE:Y';

    else

      resultout := 'COMPLETE:N';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'DetermineProceed', itemtype, itemkey, actid, funcmode);
    raise;

END DetermineProceed;



PROCEDURE SelectPlanner( itemtype  in varchar2,
			 itemkey   in varchar2,
			 actid     in number,
			 funcmode  in varchar2,
			 resultout out NOCOPY varchar2 ) is

  CURSOR PLANNER_C(p_compile_designator in varchar2,
		   p_organization_id	in number,
		   p_inventory_item_id  in number) IS
    SELECT mp.employee_id
    FROM   mtl_planners mp,
           mrp_system_items items
    WHERE  mp.organization_id = items.organization_id
    AND    mp.planner_code = items.planner_code
    AND    items.inventory_item_id = p_inventory_item_id
    AND    items.organization_id = p_organization_id
    AND    items.compile_designator = p_compile_designator;


  l_compile_designator	varchar2(10) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'PLAN_NAME');

  l_organization_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'ORGANIZATION_ID');

  l_inventory_item_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'INVENTORY_ITEM_ID');

  l_exception_type	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_TYPE_ID');

  l_order_type		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'ORDER_TYPE_CODE');

  l_person_id		number;
  l_forward_to_username	varchar2(100) := NULL;
  l_display_username	varchar2(240) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    OPEN PLANNER_C(l_compile_designator, l_organization_id, l_inventory_item_id);
    LOOP
      FETCH PLANNER_C INTO l_person_id;
      EXIT WHEN PLANNER_C%NOTFOUND OR PLANNER_C%NOTFOUND IS NULL;
    END LOOP;
    CLOSE PLANNER_C;

    wf_directory.GetRoleName('PER', to_char(l_person_id),
                             l_forward_to_username, l_display_username);

    wf_engine.SetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'MESSAGE_NAME',
		 	       avalue   => GetMessageName(l_exception_type,
							  l_order_type,
							  'PLANNER'));

    if (l_forward_to_username is not null) then

      wf_engine.SetItemAttrText( itemtype => itemtype,
		   	         itemkey  => itemkey,
			         aname    => 'FORWARD_TO_USERNAME',
			         avalue   => l_forward_to_username);

      resultout := 'COMPLETE:FOUND';

    else

      resultout := 'COMPLETE:NOT_FOUND';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'SelectPlanner', itemtype, itemkey, actid, funcmode);
    raise;

END SelectPlanner;



PROCEDURE SelectBuyer( itemtype  in varchar2,
		       itemkey   in varchar2,
		       actid     in number,
		       funcmode  in varchar2,
		       resultout out NOCOPY varchar2) is

  CURSOR BUYER_C(p_compile_designator in varchar2,
	 	 p_organization_id    in number,
		 p_inventory_item_id  in number) IS
    SELECT buyer_id
    FROM   mrp_system_items
    WHERE  inventory_item_id = p_inventory_item_id
    AND    organization_id = p_organization_id
    AND    compile_designator = p_compile_designator;

  l_compile_designator	varchar2(10) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'PLAN_NAME');

  l_organization_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'ORGANIZATION_ID');

  l_inventory_item_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'INVENTORY_ITEM_ID');

  l_exception_type	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_TYPE_ID');

  l_order_type		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'ORDER_TYPE_CODE');

  l_person_id		number;
  l_forward_to_username	varchar2(100) := NULL;
  l_display_username	varchar2(240) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    OPEN BUYER_C(l_compile_designator, l_organization_id, l_inventory_item_id);
    LOOP
      FETCH BUYER_C INTO l_person_id;
      EXIT WHEN BUYER_C%NOTFOUND OR BUYER_C%NOTFOUND IS NULL;
    END LOOP;
    CLOSE BUYER_C;

    wf_directory.GetRoleName('PER', to_char(l_person_id),
                             l_forward_to_username, l_display_username);

    wf_engine.SetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'MESSAGE_NAME',
			       avalue   => GetMessageName(l_exception_type,
						          l_order_type,
						          'BUYER'));

    if (l_forward_to_username is not null) then

      wf_engine.SetItemAttrText( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'FORWARD_TO_USERNAME',
			         avalue   => l_forward_to_username);

      resultout := 'COMPLETE:FOUND';

    else

      resultout := 'COMPLETE:NOT_FOUND';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'SelectBuyer', itemtype, itemkey, actid, funcmode);
    raise;

END SelectBuyer;



PROCEDURE SelectSupplierCnt( itemtype  in varchar2,
		             itemkey   in varchar2,
		             actid     in number,
		             funcmode  in varchar2,
		             resultout out NOCOPY varchar2) is

  l_supplier_id		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'SUPPLIER_ID');

  l_supplier_site_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'SUPPLIER_SITE_ID');

  CURSOR SUPPLIER_CONTACT_C(p_supplier_id in number,
			    p_supplier_site_id in number) IS
    SELECT DECODE(fu.employee_id, NULL, fu.user_id, fu.employee_id),
           DECODE(fu.employee_id, NULL, 'FND_USR', 'PER')
    FROM   fnd_user fu,
           po_vendor_contacts cont
    WHERE  fu.supplier_id = cont.vendor_contact_id
    AND    cont.vendor_site_id = p_supplier_site_id;

  l_exception_type 	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
			         aname    => 'EXCEPTION_TYPE_ID');

  l_person_id		number;
  l_orig_system         varchar2(48);
  l_forward_to_username	varchar2(100) := NULL;
  l_display_username	varchar2(240) := NULL;

BEGIN

  if (funcmode = 'RUN') then

      OPEN SUPPLIER_CONTACT_C(l_supplier_id, l_supplier_site_id);
      LOOP
        FETCH SUPPLIER_CONTACT_C INTO l_person_id, l_orig_system;
        if (l_person_id is not null) then
          exit;
        end if;
        EXIT WHEN SUPPLIER_CONTACT_C%NOTFOUND OR SUPPLIER_CONTACT_C%NOTFOUND IS NULL;
      END LOOP;
      CLOSE SUPPLIER_CONTACT_C;

    wf_directory.GetRoleName(l_orig_system, to_char(l_person_id),
                             l_forward_to_username, l_display_username);

    wf_engine.SetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'MESSAGE_NAME',
			       avalue   => GetMessageName(l_exception_type,
							  1, 'SUPPLIERCNT'));

    if (l_forward_to_username is not null) then

      wf_engine.SetItemAttrText( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'FORWARD_TO_USERNAME',
				 avalue   => l_forward_to_username);

      resultout := 'COMPLETE:FOUND';

    else

      resultout := 'COMPLETE:NOT_FOUND';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'SelectSupplierCnt', itemtype, itemkey, actid, funcmode);
    raise;

END SelectSupplierCnt;



PROCEDURE SelectSalesRep(  itemtype  in varchar2,
		           itemkey   in varchar2,
		           actid     in number,
		           funcmode  in varchar2,
		           resultout out NOCOPY varchar2) is

  CURSOR SALESREP_C(p_exception_id in number) IS
    SELECT  rep.person_id
    FROM
           ra_salesreps_all rep,
           oe_order_headers_all soh,
           oe_order_types_v sot,
           mtl_sales_orders mso,
           mrp_schedule_dates dates,
           mrp_gross_requirements mgr,
           mrp_exception_details_v exp
    WHERE
           rep.org_id = soh.org_id
    AND    rep.salesrep_id = soh.salesrep_id
    AND    soh.order_number = to_number(mso.segment1)
    AND    soh.order_type_id = sot.order_type_id
    AND    sot.name = mso.segment2
    AND    mso.sales_order_id = dates.source_sales_order_id
    AND    dates.supply_demand_type = 1
    AND    dates.schedule_level = 3
    AND    dates.mps_transaction_id = mgr.disposition_id
    AND    mgr.origination_type = 6
    AND    mgr.demand_id = exp.demand_id
    AND    exp.exception_id = p_exception_id;

  l_exception_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'EXCEPTION_ID');

  l_exception_type	number :=
    wf_engine.GetitemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
			         aname    => 'EXCEPTION_TYPE_ID');

  l_person_id		number;
  l_forward_to_username	varchar2(100) := NULL;
  l_display_username	varchar2(240) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    OPEN SALESREP_C(l_exception_id);
    LOOP
      FETCH SALESREP_C INTO l_person_id;
      EXIT WHEN SALESREP_C%NOTFOUND OR SALESREP_C%NOTFOUND IS NULL;
    END LOOP;
    CLOSE SALESREP_C;

    wf_directory.GetRoleName('PER', to_char(l_person_id),
                             l_forward_to_username, l_display_username);

    wf_engine.SetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'MESSAGE_NAME',
			       avalue   => GetMessageName(l_exception_type,
							  to_number(NULL),
                                                          'SALESREP'));

    if (l_forward_to_username is not null) then

      wf_engine.SetItemAttrText( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'FORWARD_TO_USERNAME',
				 avalue   => l_forward_to_username);

      resultout := 'COMPLETE:FOUND';

    else

      resultout := 'COMPLETE:NOT_FOUND';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'SelectSalesRep', itemtype, itemkey, actid, funcmode);
    raise;

END SelectSalesRep;



PROCEDURE SelectCustomerCnt( itemtype  in varchar2,
			     itemkey   in varchar2,
			     actid     in number,
			     funcmode  in varchar2,
			     resultout out NOCOPY varchar2) is

  l_customer_id		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'CUSTOMER_ID');

  CURSOR CUSTOMER_CONTACT_C1(p_customer_id in number) IS
    SELECT DECODE(fu.employee_id, NULL, fu.user_id, fu.employee_id),
           DECODE(fu.employee_id, NULL, 'FND_USR', 'PER')
    FROM   fnd_user fu,
           hz_cust_account_roles  cont
    WHERE  fu.customer_id = cont.cust_account_role_id
    AND    cont.cust_account_id = p_customer_id;

  CURSOR CUSTOMER_CONTACT_C2(p_customer_id in number) IS
    SELECT cust_account_role_id
    FROM hz_cust_account_roles
    WHERE cust_account_id = p_customer_id;

  l_person_id		number;
  l_orig_system         varchar2(48);
  l_forward_to_username	varchar2(100) := NULL;
  l_display_username	varchar2(240) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    OPEN CUSTOMER_CONTACT_C1(l_customer_id);
    LOOP
      FETCH CUSTOMER_CONTACT_C1 INTO l_person_id, l_orig_system;
      EXIT WHEN CUSTOMER_CONTACT_C1%NOTFOUND OR CUSTOMER_CONTACT_C1%NOTFOUND IS NULL;
    END LOOP;
    CLOSE CUSTOMER_CONTACT_C1;

    wf_directory.GetRoleName(l_orig_system, to_char(l_person_id),
                             l_forward_to_username, l_display_username);

    if (l_forward_to_username is null) then

      OPEN CUSTOMER_CONTACT_C2(l_customer_id);
      LOOP
        FETCH CUSTOMER_CONTACT_C2 INTO l_person_id;
        EXIT WHEN CUSTOMER_CONTACT_C2%NOTFOUND OR CUSTOMER_CONTACT_C2%NOTFOUND IS NULL;
      END LOOP;
      CLOSE CUSTOMER_CONTACT_C2;

      wf_directory.GetRoleName('CUST_CONT', to_char(l_person_id),
                               l_forward_to_username, l_display_username);

    end if;

    if (l_forward_to_username is not null) then

      wf_engine.SetItemAttrText( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'FORWARD_TO_USERNAME',
				 avalue   => l_forward_to_username);

      resultout := 'COMPLETE:FOUND';

    else

      resultout := 'COMPLETE:NOT_FOUND';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'SelectCustomerCnt', itemtype, itemkey, actid, funcmode);
    raise;

END SelectCustomerCnt;




PROCEDURE SelectTaskMgr( itemtype  in varchar2,
		         itemkey   in varchar2,
		         actid     in number,
		         funcmode  in varchar2,
		         resultout out NOCOPY varchar2) is

  CURSOR TASK_MANAGER_C(p_project_number in varchar2,
		        p_task_number    in varchar2) IS
    SELECT tasks.task_manager_person_id
    FROM   pa_tasks tasks,
	   pa_projects_all proj
    WHERE  tasks.task_number = p_task_number
    AND    tasks.project_id = proj.project_id
    AND    proj.segment1 = p_project_number;

  CURSOR PROJECT_MANAGER_C(p_project_number in varchar2) IS
    SELECT ppp.person_id
    FROM   pa_project_players ppp,
           pa_projects_all proj
    WHERE  ppp.project_role_type = 'PROJECT MANAGER'
    AND    ppp.project_id = proj.project_id
    AND    proj.segment1 = p_project_number;

  l_task_mgr_number	number :=
    wf_engine.GetActivityAttrNumber( itemtype => itemtype,
				     itemkey  => itemkey,
				     actid    => actid,
				     aname    => 'WHICH_TASK_MANAGER');

  l_project_number	varchar2(4000) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'PROJECT_NUMBER');

  l_to_project_number	varchar2(4000) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'TO_PROJECT_NUMBER');

  l_task_number 	varchar2(4000) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'TASK_NUMBER');

  l_to_task_number	varchar2(4000) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'TO_TASK_NUMBER');

  l_person_id		number;
  l_forward_to_username varchar2(100) := NULL;
  l_display_username	varchar2(240) := NULL;

BEGIN

  if (funcmode = 'RUN') then

    if (l_task_mgr_number = 2) then

      l_project_number := l_to_project_number;
      l_task_number := l_to_task_number;

    end if;

    OPEN TASK_MANAGER_C(l_project_number, l_task_number);
    LOOP
      FETCH TASK_MANAGER_C INTO l_person_id;
      EXIT WHEN TASK_MANAGER_C%NOTFOUND OR TASK_MANAGER_C%NOTFOUND IS NULL;
    END LOOP;
    CLOSE TASK_MANAGER_C;

    wf_directory.GetRoleName('PER', to_char(l_person_id),
                             l_forward_to_username, l_display_username);

    if (l_forward_to_username is null) then

      OPEN PROJECT_MANAGER_C(l_project_number);
      LOOP
        FETCH PROJECT_MANAGER_C INTO l_person_id;
        EXIT WHEN PROJECT_MANAGER_C%NOTFOUND OR PROJECT_MANAGER_C%NOTFOUND IS NULL;
      END LOOP;
      CLOSE PROJECT_MANAGER_C;

      wf_directory.GetRoleName('PER', to_char(l_person_id),
                               l_forward_to_username, l_display_username);

    end if;

    if (l_forward_to_username is not null) then

      wf_engine.SetItemAttrText( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'FORWARD_TO_USERNAME',
				 avalue   => l_forward_to_username);

      resultout := 'COMPLETE:FOUND';

    else

      resultout := 'COMPLETE:NOT_FOUND';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'SelectTaskMgr', itemtype, itemkey, actid, funcmode);
    raise;

END SelectTaskMgr;



FUNCTION GetMessageName(p_exception_type in number,
			p_order_type     in number,
		  	p_recipient	 in varchar2) RETURN varchar2 IS

  l_message_name 	varchar2(40);

BEGIN

  if (p_recipient = 'PLANNER') then

    if (p_exception_type = 1) then
      l_message_name := 'MSG_1';

    elsif (p_exception_type in (2, 3, 20)) then
      l_message_name := 'MSG_2_3_20';

    elsif (p_exception_type in (6, 7)) then

      if (p_order_type = 1) then
        l_message_name := 'MSG_6_7_PO';

      elsif (p_order_type = 2) then
        l_message_name := 'MSG_6_7_REQ';

      elsif (p_order_type in (3, 5, 7, 18)) then
        l_message_name := 'MSG_RESCHEDULE_6_7_WORK';

      end if;

    elsif (p_exception_type in (8, 10)) then

      if (p_order_type = 1) then
        l_message_name := 'MSG_8_10_PO';

      elsif (p_order_type = 2) then
        l_message_name := 'MSG_8_10_REQ';

      elsif (p_order_type in (3, 5, 7, 18)) then
        l_message_name := 'MSG_RESCHEDULE_8_10_WORK';

      end if;

    elsif (p_exception_type = 9) then

      if (p_order_type = 1) then
        l_message_name := 'MSG_9_PO';

      elsif (p_order_type = 2) then
        l_message_name := 'MSG_9_REQ';

      elsif (p_order_type in (3, 5, 7, 18)) then
        l_message_name := 'MSG_RESCHEDULE_9_WORK';

      end if;

    elsif (p_exception_type = 12) then
      l_message_name := 'MSG_12';

    elsif (p_exception_type = 13) then
      l_message_name := 'MSG_13';

    elsif (p_exception_type = 14) then
      l_message_name := 'MSG_14';

    elsif (p_exception_type = 15) then
      l_message_name := 'MSG_15';

    elsif (p_exception_type = 16) then
      l_message_name := 'MSG_16';

    elsif (p_exception_type in (17, 18)) then
      l_message_name := 'MSG_17_18';

    elsif (p_exception_type = 19) then
      l_message_name := 'MSG_19';

    end if;

  elsif (p_recipient = 'BUYER') then

    if (p_exception_type in (6, 7)) then

      if (p_order_type = 1) then
        l_message_name := 'MSG_6_7_PO';

      elsif (p_order_type = 2) then
        l_message_name := 'MSG_RESCHEDULE_6_7_REQ';

      end if;

    elsif (p_exception_type in (8, 10)) then

      if (p_order_type = 1) then
        l_message_name := 'MSG_8_10_PO';

      elsif (p_order_type = 2) then
        l_message_name := 'MSG_RESCHEDULE_8_10_REQ';

      end if;

    elsif (p_exception_type = 9) then

      if (p_order_type = 1) then
        l_message_name := 'MSG_9_PO';

      elsif (p_order_type = 2) then
        l_message_name := 'MSG_RESCHEDULE_9_REQ';

      end if;

    end if;

  elsif (p_recipient = 'SUPPLIERCNT') then

    if (p_exception_type in (6, 7)) then
      l_message_name := 'MSG_RESCHEDULE_6_7_PO';

    elsif (p_exception_type in (8, 10)) then
      l_message_name := 'MSG_RESCHEDULE_8_10_PO';

    elsif (p_exception_type = 9) then
      l_message_name := 'MSG_RESCHEDULE_9_PO';

    end if;

  elsif (p_recipient = 'SALESREP') then
    if (p_exception_type = 13) then
      l_message_name := 'MSG_13_FYI';

    elsif (p_exception_type = 15) then
      l_message_name := 'MSG_15_FYI';

    end if;

  end if;

  return l_message_name;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'GetMessageName', to_char(p_exception_type), to_char(p_order_type));
    raise;

END GetMessageName;



PROCEDURE DetermineExceptionType( itemtype  in varchar2,
				  itemkey   in varchar2,
				  actid     in number,
				  funcmode  in varchar2,
				  resultout out NOCOPY varchar2) is

  l_exception_type 	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_TYPE_ID');

BEGIN

  if (funcmode = 'RUN') then

    if (l_exception_type in (1, 2, 3, 20)) then

      resultout := 'COMPLETE:1_2_3_20';

    elsif (l_exception_type = 12) then

      resultout := 'COMPLETE:12';

    elsif (l_exception_type  in (14, 16)) then

      resultout := 'COMPLETE:14_16';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'DetermineExceptionType', itemtype, itemkey, actid, funcmode);
    raise;

END DetermineExceptionType;




PROCEDURE DetermineOrderType( itemtype  in varchar2,
		              itemkey   in varchar2,
		              actid     in number,
		              funcmode  in varchar2,
		              resultout out NOCOPY varchar2) is

  l_exception_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_ID');

  l_order_type 		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'ORDER_TYPE_CODE');


BEGIN

  if (funcmode = 'RUN') then

    -- Purchase Order
    if (l_order_type = 1) then

      resultout := 'COMPLETE:PURCHASE_ORDER';

    -- Purchase Requisition
    elsif (l_order_type = 2) then

      resultout := 'COMPLETE:PURCHASE_REQUISITION';

    -- Discrete Job, Planned Order, Non-standard Job, Flow Schedule
    elsif (l_order_type in  (3, 5, 7, 18)) then

      resultout := 'COMPLETE:WORK_ORDER';

    else

      resultout := 'COMPLETE:OTEHR_ORDER_TYPES';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'DetermineOrderType', itemtype, itemkey, actid, funcmode);
    raise;

END DetermineOrderType;



PROCEDURE Reschedule( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      resultout out NOCOPY varchar2) is

  l_exception_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_ID');

  l_compile_designator	varchar2(10) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'PLAN_NAME');

  l_organization_id	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
			         itemkey  => itemkey,
			         aname    => 'ORGANIZATION_ID');

  l_exception_type	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_TYPE_ID');

  l_order_type		number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'ORDER_TYPE_CODE');

  l_owning_org_id	number;
  l_user_id		number := fnd_global.user_id;
  l_po_group_by		number := fnd_profile.value('MRP_LOAD_REQ_GROUP_BY');
  l_po_batch_number	number;
  l_wip_group_id	number;
  l_loaded_jobs		number;
  l_loaded_reqs		number;
  l_loaded_scheds	number;
  l_resched_jobs	number;
  l_resched_reqs	number;
  l_wip_req_id		number;
  l_req_load_id		number;
  l_req_resched_id	number;
  l_transaction_id	number := to_number(NULL);
  l_location_id         number;

  l_reschedule_result	boolean;

  l_assigned_user      varchar2(320);
  l_application_id      number;
  l_responsibility_id  number;

BEGIN

  -- Based on whether it is a discrete job, repetitive_schedules,
  -- Flow schedules, Reqs or Purchase Orders we will call the appropriate
  -- APIs.
  --   DJ - wip_reschedule_interface
  --   RS - wip_reschedule_interface
  --   FS - FS api, however we do not do this currently
  --   Req - po_reschedule_interface
  --   PO  - po api
  -- You need to account for cancel here as well

  IF (funcmode = 'RUN') THEN

/** Bug 2226979 **/
    IF l_user_id < 1 THEN -- get a valid responsibility for this user
      l_assigned_user := wf_engine.GetItemAttrText( itemtype => itemtype,
           itemkey  => itemkey,
           aname    => 'FORWARD_TO_USERNAME');

      SELECT g.responsibility_id, g.user_id, g.responsibility_application_id
      INTO   l_responsibility_id, l_user_id, l_application_id
      FROM fnd_user u, fnd_user_resp_groups g
      WHERE u.user_name = l_assigned_user
      AND   g.start_date <= SYSDATE
      AND   NVL(g.end_date, SYSDATE + 1) >= SYSDATE
      AND   g.user_id = u.user_id
      AND   u.start_date <= SYSDATE
      AND   NVL(u.end_date, SYSDATE + 1) >= SYSDATE
      AND   ROWNUM = 1;

      FND_GLOBAL.Apps_Initialize(l_user_id, l_responsibility_id, l_application_id);

    END IF;

/** End Bug 2226979 **/

    if (l_order_type in (1, 2, 3, 13)) then   -- po, req, discrete, repetitve

      SELECT organization_id
      INTO   l_owning_org_id
      FROM   mrp_plan_organizations_v
      WHERE  planned_organization = l_organization_id
      AND    compile_designator = l_compile_designator;

      SELECT mrp_workbench_query_s.nextval,
             wip_job_schedule_interface_s.nextval
      INTO   l_po_batch_number,
             l_wip_group_id
      FROM   dual;

      SELECT transaction_id
      INTO   l_transaction_id
      FROM   mrp_exception_details_v
      WHERE  exception_id = l_exception_id;

      if (l_order_type in (3, 13)) then

        UPDATE mrp_recommendations
        SET    implement_date = new_schedule_date,
               implement_quantity = DECODE(l_exception_type, 8, 0,
                                      new_order_quantity),
               implement_demand_class = demand_class,
               implement_status_code = decode(l_order_type, 3,
                                                decode(l_exception_type, 8, 7, implement_status_code),
                                              implement_status_code), /* Bug 2226979 **/
               implement_project_id = project_id,
               implement_task_id = task_id,
               implement_job_name = FND_PROFILE.VALUE('WIP_JOB_PREFIX')||to_char(wip_job_number_s.nextval),
               implement_line_id = line_id,
               implement_alternate_bom = alternate_bom_designator,
               implement_alternate_routing = alternate_routing_designator,
               implement_end_item_unit_number = end_item_unit_number
        WHERE  transaction_id = l_transaction_id;

      else

        BEGIN
          SELECT loc.location_id
          INTO   l_location_id
          FROM   hr_locations           loc,
                 hr_organization_units  unit
          WHERE  unit.organization_id   = l_organization_id
          AND    unit.location_id       = loc.location_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_location_id := NULL;
        END;

        UPDATE mrp_recommendations supplies
        SET    old_order_quantity       = new_order_quantity,
               quantity_in_process      = new_order_quantity,
               implement_date           = new_schedule_date,
               implement_quantity       = decode(disposition_status_type,2,0,new_order_quantity), /** Bug 2226979 **/
               implement_firm           = firm_planned_type,
               implement_dock_date      = new_dock_date,
               implement_location_id    = l_location_id,
               implement_source_org_id  = source_organization_id,
               implement_vendor_id      = source_vendor_id,
               implement_vendor_site_id = source_vendor_site_id,
               implement_project_id     = project_id,
               implement_task_id        = task_id,
               implement_demand_class   = NULL,
 	       implement_employee_id =     ( SELECT
                    decode(msi.planner_code,NULL,mplm.employee_id,mpl.employee_id)
                FROM   	mtl_planners             mplm,
                   	mtl_planners             mpl,
               		mtl_parameters           mparam,
               		mtl_system_items         master_msi,
               		mtl_system_items         msi
        		WHERE  msi.organization_id      = supplies.organization_id
        		AND    msi.inventory_item_id    = supplies.inventory_item_id
        		AND    master_msi.organization_id = mparam.master_organization_id
        		AND    master_msi.inventory_item_id = msi.inventory_item_id
        		AND    mpl.organization_id   (+) = msi.organization_id
        		AND    mpl.planner_code      (+) = NVL(msi.planner_code, 'A')
        		AND    mplm.organization_id   (+)= master_msi.organization_id
        		AND    mplm.planner_code      (+)= NVL(master_msi.planner_code, 'A')
        		AND    mparam.organization_id   = msi.organization_id)
        WHERE  transaction_id = l_transaction_id;

      end if;

      mrp_rel_plan_pub.mrp_release_plan_sc
		     (l_organization_id, l_owning_org_id,
                      l_compile_designator, l_user_id,
                      l_po_group_by, l_po_batch_number, l_wip_group_id,
                      l_loaded_jobs, l_loaded_reqs, l_loaded_scheds,
                      l_resched_jobs, l_resched_reqs, l_wip_req_id,
                      l_req_load_id, l_req_resched_id,
                      'WF', l_transaction_id);

     if nvl(l_wip_req_id,0) > 0 then
        wf_engine.additemattr(itemtype,
                                itemkey,
                                'WIP_REQ_ID',
                                null,
                                l_wip_req_id,
                                null);
     end if;
     if nvl(l_req_load_id,0) > 0 then
      wf_engine.additemattr(itemtype,
                                itemkey,
                                'REQ_LOAD_REQ_ID',
                                null,
                                l_req_load_id,
                                null);
     end if;
     if nvl(l_req_resched_id,0) > 0 then
      wf_engine.additemattr(itemtype,
                                itemkey,
                                'REQ_RESCHED_REQ_ID',
                                null,
                                l_req_resched_id,
                                null);
     end if;

    end if;

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'Reschedule', itemtype, itemkey, actid, funcmode);
    raise;

END Reschedule;



PROCEDURE IsType19( itemtype  in varchar2,
		    itemkey   in varchar2,
		    actid     in number,
                    funcmode  in varchar2,
		    resultout out NOCOPY varchar2) is

  l_exception_type	number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
				 aname    => 'EXCEPTION_TYPE_ID');

BEGIN

  if (funcmode = 'RUN') then

    if (l_exception_type = 19) then

      resultout := 'COMPLETE:Y';

    else

      resultout := 'COMPLETE:N';

    end if;

    return;

  end if;

  if (funcmode = 'CANCEL') then

    resultout := 'COMPLETE:';
    return;

  end if;

  if (funcmode = 'TIMEOUT') then

    resultout := 'COMPLETE:';
    return;

  end if;

EXCEPTION

  when others then
    wf_core.context('MRP_EXP_WF', 'IsType19', itemtype, itemkey, actid, funcmode);
    raise;

END IsType19;

PROCEDURE PurgeActivities(l_item_type in varchar2,
                          l_item_key in varchar2)
IS
BEGIN

      UPDATE wf_notifications
       SET    end_date = SYSDATE - 450
       WHERE  group_id IN
        (SELECT notification_id
        FROM wf_item_activity_statuses
        WHERE item_type = l_item_type
        AND item_key = l_item_key
        UNION
        SELECT notification_id
        FROM wf_item_activity_statuses_h
        WHERE item_type = l_item_type
        AND item_key = l_item_key);

      UPDATE wf_items
      SET    end_date = SYSDATE - 450
      WHERE item_type = l_item_type
      AND item_key = l_item_key   ;

      UPDATE 	wf_item_activity_statuses
      SET   end_date = SYSDATE - 450
      WHERE item_type = l_item_type
      AND item_key = l_item_key;

      UPDATE 	wf_item_activity_statuses_h
      SET   end_date = SYSDATE - 450
      WHERE item_type = l_item_type
      AND item_key = l_item_key;

      wf_purge.items(l_item_type,l_item_key,sysdate - 450);

END PurgeActivities;



PROCEDURE DeleteActivities( arg_compile_desig   in varchar2,
			    arg_organization_id in number) IS

  CURSOR DELETE_ACTIVITIES_C(p_min_exception_id in number,
			     p_max_exception_id in number) IS
    SELECT item_key
    FROM   wf_items
    WHERE  item_type = 'MRPEXPWF'
    AND    to_number(item_key) >= p_min_exception_id
    AND    to_number(item_key) <= p_max_exception_id;

    -- SELECT wfi.item_key
    -- FROM   wf_items wfi,
    --        mrp_exception_details_v exp
    -- WHERE  wfi.item_key = to_char(exp.exception_id)
    -- AND    wfi.item_type = 'MRPEXPWF'
    -- AND    exp.exception_type in (1,2,3,6,7,8,9,10,12,13,14,15,16,17,18,19,20)
    -- AND    exp.compile_designator = p_compile_desig
    -- AND    exp.organization_id in
    --          (SELECT planned_organization
    --           FROM   mrp_last_plan_orgs_v
    --           WHERE  organization_id = p_owning_org_id
    --           AND    compile_designator = p_compile_desig);

  CURSOR CANCEL_NOTIFICATIONS_C( p_item_type in varchar2,
                                 p_item_key  in varchar2) IS
    SELECT wn.notification_id
    FROM   wf_notifications wn,
           wf_item_activity_statuses wias
    WHERE  wn.status = 'OPEN'
    AND    wn.notification_id = wias.notification_id
    AND    wias.item_key = p_item_key
    AND    wias.item_type = p_item_type;

  l_item_key		varchar2(240);
  l_activity_count	number;
  l_wf_status		varchar2(8);
  l_wf_result		varchar2(30);
  l_notification_id	number;
  l_min_exception_id	number;
  l_max_exception_id	number;

BEGIN

  SELECT min_wf_except_id,
         max_wf_except_id
  INTO   l_min_exception_id,
         l_max_exception_id
  FROM   mrp_plans
  WHERE  organization_id = arg_organization_id
  AND    compile_designator = arg_compile_desig;

  if (l_min_exception_id is not null and l_max_exception_id is not null) then

    OPEN DELETE_ACTIVITIES_C(l_min_exception_id, l_max_exception_id);
    LOOP
      FETCH DELETE_ACTIVITIES_C INTO l_item_key;
      EXIT WHEN DELETE_ACTIVITIES_C%NOTFOUND OR DELETE_ACTIVITIES_C%NOTFOUND IS NULL;

      -- It might happen that WF process is defined in WF_ITEMS table
      -- but not in WF_ITEM_ACTIVITY_STATUSES.  If so, error.

      -- SELECT count(*)
      -- INTO   l_activity_count
      -- FROM   wf_item_activity_statuses
      -- WHERE  item_type = 'MRPEXPWF'
      -- AND    item_key = l_item_key;

      -- if (l_activity_count > 0) then

        wf_engine.ItemStatus('MRPEXPWF', l_item_key, l_wf_status, l_wf_result);

        -- A process might be completed but there could be open notifications

        if (l_wf_status = wf_engine.eng_completed) then

          OPEN CANCEL_NOTIFICATIONS_C('MRPEXPWF', l_item_key);
          LOOP
            FETCH CANCEL_NOTIFICATIONS_C INTO l_notification_id;
            EXIT WHEN CANCEL_NOTIFICATIONS_C%NOTFOUND OR CANCEL_NOTIFICATIONS_C%NOTFOUND IS NULL;
            wf_notification.Cancel(l_notification_id);
          END LOOP;
          CLOSE CANCEL_NOTIFICATIONS_C;

        -- Cancel all notifications within process and process itself
        else
          wf_engine.AbortProcess('MRPEXPWF', l_item_key);

        end if;

        PurgeActivities('MRPEXPWF', l_item_key);

      -- end if;

    END LOOP;
    CLOSE DELETE_ACTIVITIES_C;

  end if;

EXCEPTION

  when NO_DATA_FOUND then
    null;

  when others then
    null;

END DeleteActivities;


END mrp_exp_wf;

/
