--------------------------------------------------------
--  DDL for Package Body CTO_WORKFLOW_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_WORKFLOW_API_PK" as
/* $Header: CTOWFAPB.pls 120.29.12010000.5 2010/07/21 08:39:42 abhissri ship $ */

/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOWFAPB.pls
|                                                                             |
| DESCRIPTION:                                                                |
|               Contain all CTO and WF related APIs.                          |
|               One API is used to check if a configured item (model)         |
|               is created. This API is applied by the Processing Constraints |
|               Framework provided by OE                                      |
|                                                                             |
|                                                                             |
| HISTORY     :                                                               |
|               Aug 16, 99   James Chiu   Initial version                     |
|               09-11-2000   Kiran Konada Added code for ATO ITEM Enhancement |
|               01-02-2001   Renga Kannan Added some debug messages           |
|               01-02-2001    ssheth added code chnage for bug#1494878        |
| 		07-18-2001   Ksarkar code change fix for bug# 1876997	      |
|                   	     Change query to refer base tables instead of     |
|		             the expensive view (wsh_delivery_line_status_v)  |
|               08-16-2001   Kiran Konada, fix for bug#1874380                |
|                             to support ATO item under a PTO.                |
|                            item_type_code for an ato item under PTO         |
|		     is 'OPTION' and top_model_line_id will NOT be            |
|                       null, UNLIKE an ato item order, where                 |
|			     item_type_code = 'Standard' and                  |
|			     top_model_lined_id is null                       |
|                            This fix has actually been provided in           |
|                         branched version 115.33.1155.3                      |
|               08-17-2001   Kiran Konada, fix for bug#1895563                |
|                            procedures changed:                              |
|			     display_wf_status()                              |
|			     wf_update_after_inv_reserv                       |
|			     wf_update_after_inv_unreserv                     |
|               09-20-2001   RaviKumar V Addepalli                            |
|                            Changed the following procedures                 |
|	                       1. display_wf_status()                         |
|                              2. wf_update_after_inv_reserv                  |
|		               3. wf_update_after_inv_unreserv                |
|                            For the the AutoCreate Purchase requisitions, For|
|                            a ATO Buy item the procedure will have to update |
|                            the line status and the workflow differently.    |
|
|
|
|               13-NOV-2001  Modified by Renga Kannan                         |
|                                                                             |
|                            Ato buy item workflow is modified                |
|                            Wait for PO RECEIPT activity is                  |
|                            removed and hence the corresponding code         |
|                            is modified in wf_update_inv_unreserve           |
|                            and wf_update_inv_reserve                        |
|                                                                             |
|                03/22/2002  bugfix#2234858                                   |
|                            added new functionality to support DROP SHIP     |
|
|                04/18/2002  bugfix#2312701
|                            added exception to disallow reservation for      |
|                            dropshipped orders before po approval            |
|                                                                             |
|                05/06/2002  bugfix#2358576                                   |
|                            restrict reservation for dropshippped orders     |
|                            only to config items and ato items               |
|
|                07/23/2002  bugfix#2466429
|                            Modified by Kiran Konada
|                            primary_reservation_quantity will have qty as per
|                            primary UoM
|                12/12/2002   KIran Konadad
|			      added a parametr in call to populate_req_interface
|			      for MLSUPPLY feture
|
|
|		08/13/ 2003  Kiran Konada
|			 for bug# 3063156
                           propagte bugfix 3042904 to main
|                              passed new paremeters project_id and task_id to
|                             populate_req_interface
|                              these are passed as NULL values as populate_req_interface
|                              calculates them for top_most buy items
|
                            Kiran Konada
|			    Muiple sources for DMF-J  enahncement in
|			    wf_update_after_inv_unresv
|			    added a call to procedure check_cto_can _create_supply
|			    If cto cannot create supply(planning supply), worlflow will
|			    remain at shipping
|			    If cto can create supply, workflow would be moved appropriately
|			    depending on amount of qty unreserved
|
|
|
|               08/28/2003  Kiran Konada
|			    chnaging the procedure wf_update_after_inv_unresv
|			    getting inventory_item_id and oship from org_id
|			    from oe_order_lines_all This is added during Unit test
|			    for support to handle mutiple sources situations during supply
|			    creation
|
|               09/25/2003   Shashi Bhaskaran
|                             Bugfix : 3077912
|                             Offset need_by_date with postprocessing lead time.
|                             Bugfix : 3076061
|                             When reservations are removed, CTO need to move the
| 			      order line status to 'Production Eligible' and WF status
| 			      to 'Create Supply Eligible' if the flow schedules are all
| 			      completed or no flow schedules exists.
| 			      Bugfix : 2972186
| 			      Split line status is showing "Production Complete" instead
| 			      of "Shipped".
|
|               10/23/2003   Kiran Konada
|                            changed dsiplay_wf-status for patchset J
|                            introduced a prpcedure  Get_Resv_Qty_and_Code
|
|               10/25/2003   Kiran Konada
|                            removed t_rsv_code.count and added
|                            t_rsv_code IS NOT NULL
|
|               11/03/2003  Kiran Konada
|                             Main propagation bug#3140641
|
|                             reverted changes made on   08/13/ 2003
|                             removed project_id and task_id as parameters to populate_req_interface
|                             revrting bufix 3042904 ude  to bug#3129117
|
|               11/04/2003  Kiran Konada
|                           Made a call to CTOUTILB.check_cto_can_create_supply
|                           from display_wf_status
|
|
|               11/19/2003  Kiran Konada
|                           There was a full table scan on fnd_concurrent_programs
|                           hece, added where clause
|                           and     application_id          = 702;BOM , bugfix 2885568
|
|                           original query
|                               select  concurrent_program_id
				 into    p_program_id
				 from    fnd_concurrent_programs a
				 where   concurrent_program_name = 'CTOACREQ'
|
|
|                           new query
|                               select  concurrent_program_id
|				 into    p_program_id
|				 from    fnd_concurrent_programs a
|				 where   concurrent_program_name = 'CTOACREQ'
|				 and     application_id          = 702
|
|
|
|               01/23/2004  Sushant Sawant
|                           Added condition config_orgs <> 3 to avoid warehouse change for items
|                           not based on  'Based on Model'.
|
|
|               02/06/2004  Sushant Sawant fixed bug 3424802
|                           split line should be allowed irrespective of CIB attribute.
|
|
|               02/23/2004  Sushant Sawant fixed Bug 3419221
|                           New LINE_FLOW_STATUS code 'SUPPLY_ELIGIBLE' was introduced.
|                           Config Lines with Internal and External source types will be assigned this status.
|
|
|               Modified   :    13-APR-2004     Sushant Sawant
|                                               Added check for booked orders to provide SUPPLY_ELIGIBLE/ENTERED
|                                               as status of config line.
|
|
|               Modified   :    14-APR-2004     Sushant Sawant
|                                               Fixed bug 3419221. following status for config item/ato item are available
|                                               as replacement for BOM_AND_RTG_CREATED
|                                               New Status: ENTERED/BOOKED/SUPPLY_ELIGIBLE
|
|
|               Modified  :  17-Nov-2004 Kiran Konada
|                            bugfix 3875420, as flow rsv is not visible in
		                   mtl_reservations, we check for rsv_code FO
|               Modified : 06-Jun-2005  Renga Kannan
|                          Bug Fix 4380768
|
|
|               16-Jun-2005	Kiran Konada
|			changes for OPM and Ireq project
|			comment string : OPM
|			get_resv_qty_and_code API
|				-cursor c-resv chnaged to include secondary
|				reservation qty
|				-sec rsv qty has been assigned to record
|				structure x_rsv_rec(l_index) and debug messages
|				-qyery on wip_flow_schedules has been removed
|				and existing FLM api get_flow_qty is used to
|				get flow qty in both cases of fresh order line
|				and split order line
|				-new query to get external and internal
|				req data from iface table and assigned to x_rsv_rec(l_index
|                24-Jun-2005    Renga Kannan
|                               Get_resv_qty_and_code API is not handling uom
conversion.
|                               Added code to pass the qty in primary uom
|
|                05-Jun-2005    Renga Kannan
|                               Modified function complete_activity for MOAC
|
|
|                09-Aug-2005	Kiran Konada
|                               4545070
|				 Replaced call to OE_ORDER_WF_UTIL.update_flow_status_code with
|				call to CTO_WORKFLOW_API_PK.display_wf_status
|
|
|                25-Sep-2005    Kiran Konada
|                               bugfix4637281
|			  	changing IF..ELSIF into multiple IF..ENDIF's
|
|               12-OCT-2005	Kiran Koanda
|                               r12 bugfix 4666778, changed query to look at models CIB attribute
|
|               15-NOV-2005	Kiran Konada
|                               bug#4739807,when rsv is only bcos of receiving
|
|		16-NOV-2005	Kiran Konada
|				bug# 4743430
|				For homogenous supply with receiving as one of
|				reservations types. L_toekn2 is null, So the status
|				would be just IN_RECEIVING
|
|
|		01-Dec-2005	Kiran Konada
|				FP of bugfix 4051282
|                               Main line bug#4350569
|
=============================================================================*/

G_PKG_NAME      	CONSTANT VARCHAR2(30):='CTO_WORKFLOW_API_PK';

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

TYPE rsv_code_tbl_type is TABLE OF VARCHAR2(1)  INDEX BY Binary_integer;

-- Added for Cross docking project.
Procedure  get_status_tokens(
                           p_order_line_id		Number,
			   p_config_item_id		Number,
			   p_ship_from_org_id		Number,
			   p_ordered_quantity		Number,
			   x_token1         OUT NOCOPY  Varchar2,
			   x_token2         OUT NOCOPY  varchar2,
			   x_return_status  OUT NOCOPY  varchar2,
			   x_msg_data       OUT NOCOPY  Varchar2,
			   x_msg_count      OUT NOCOPY  Number);



/**************************************************************************

   Procedure:   query_wf_activity_status
   Parameters:  p_itemtype                -
                p_itemkey                 -
                p_activity_label          -           "
                p_activity_name           -           "
                p_activity_status         -
   Description: this procedure is used to query a Workflow activity status

*****************************************************************************/



PROCEDURE query_wf_activity_status(
        p_itemtype        IN      VARCHAR2,
        p_itemkey         IN      VARCHAR2,
        p_activity_label  IN      VARCHAR2,
        p_activity_name   IN      VARCHAR2,
        p_activity_status OUT NOCOPY    VARCHAR2 )

IS


BEGIN

    select activity_status
    into   p_activity_status
    from   wf_item_activity_statuses was
    where  was.item_type      = p_itemtype
    and    was.item_key       = p_itemkey
    and    was.process_activity in
	(SELECT wpa.instance_id
	FROM  wf_process_activities wpa
	 WHERE wpa.activity_name = p_activity_name);


EXCEPTION

  when others then
    p_activity_status := 'NULL';
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('query_wf_activity_status: ' || 'exception in CTO_WORKFLOW_API_PK.query_wf_activity_status'||sqlerrm, 1);
    END IF;

END query_wf_activity_status;




/**************************************************************************

   Procedure:   get_activity_status
   Parameters:  itemtype                -
                itemkey                 -
                linetype                -           "
                activity_name           -           "
   Description: this procedure is used by Match and Reserve to check if an
                instance of WF process resides at a desired block activity.

*****************************************************************************/

PROCEDURE get_activity_status(
        itemtype        IN      VARCHAR2,
        itemkey         IN      VARCHAR2,
        linetype        IN      VARCHAR2,
        activity_name   OUT  NOCOPY   VARCHAR2 )

IS

  v_activity_status_code      VARCHAR2(8);

BEGIN

  if upper(linetype) = 'MODEL' then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('get_activity_status: ' || 'get_act_status::line is model', 4);
    END IF;
    query_wf_activity_status(itemtype, itemkey, 'CREATE_CONFIG_ITEM_ELIGIBLE',
                             'CREATE_CONFIG_ITEM_ELIGIBLE', v_activity_status_code);

    if  upper(v_activity_status_code) = 'NOTIFIED' then
      activity_name := 'CREATE_CONFIG_ITEM_ELIGIBLE';
    else
      activity_name := 'NULL';
    end if;

  elsif upper(linetype) = 'CONFIG' then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('get_activity_status: ' || 'get_act_status::line is config');
    END IF;
    query_wf_activity_status(itemtype, itemkey, 'CREATE_CONFIG_BOM_ELIGIBLE',
                             'CREATE_CONFIG_BOM_ELIGIBLE', v_activity_status_code);

    if  upper(v_activity_status_code) = 'NOTIFIED' then
      activity_name := 'CREATE_CONFIG_BOM_ELIGIBLE';
    else
      query_wf_activity_status(itemtype, itemkey, 'CREATE_SUPPLY_ORDER_ELIGIBLE',
                             'CREATE_SUPPLY_ORDER_ELIGIBLE', v_activity_status_code);

      if  upper(v_activity_status_code) = 'NOTIFIED' then
        activity_name := 'CREATE_SUPPLY_ORDER_ELIGIBLE';
      else
        activity_name := 'NULL';
      end if;
    end if;

  else
    activity_name := 'NULL';

  end if;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('get_activity_status: ' || 'get_act_status::returning activity_name '||activity_name, 4);
  END IF;

EXCEPTION

  when others then
    activity_name := 'NULL';
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('get_activity_status: ' || 'exception in CTO_WORKFLOW_API_PK.get_activity_status:'||sqlerrm, 1);
    END IF;

END get_activity_status;


/**************************************************************************

   Function:   complete_activity
   Parameters:  p_itemtype                -
                p_itemkey                 -
                p_activity_name           -           "
                p_result_code             -           "
   Description: this function is used to complete an WF activity

*****************************************************************************/

FUNCTION complete_activity(
        p_itemtype        IN      VARCHAR2,
        p_itemkey         IN      VARCHAR2,
        p_activity_name   IN      VARCHAR2,
        p_result_code     IN      VARCHAR2
        )
return BOOLEAN is

-- Added the variables for MOAC project
l_change_context_back     varchar2(1) := 'N';
l_current_mode            varchar2(1);
l_current_org             Number;
l_line_org_id             Number;

BEGIN

  -- Change for MOAC project
  -- Before completing the workflow activity
  -- if the current ou is not order line on then change the OU to order
  -- line ou and reset after the worklfow node is completed.

  Select org_id
  into   l_line_org_id
  from   oe_order_lines_all
  where  line_id = p_itemkey;

  -- Modified by Renga Kannan on 04/28/06
  -- CAlling Utility API to Switch to order line context
  CTO_MSUTIL_PUB.switch_to_oe_context(p_oe_org_id           => l_line_org_id,
                                      x_current_mode        => l_current_mode,
				      x_current_org         => l_current_org,
				      x_context_switch_flag => l_change_context_back);

  wf_engine.CompleteActivityInternalName(p_itemtype, p_itemkey,
                             p_activity_name,p_result_code);
  IF PG_DEBUG <> 0 Then
     oe_debug_pub.add('Complete_activity : l_change_context_back = '||l_change_context_back,5);
  End if;

  If l_change_context_back = 'Y' then
     CTO_MSUTIL_PUB.Switch_context_back(p_old_mode => l_current_mode,
                                        p_old_org  => l_current_org);
  End if; /*l_change_context_back = 'Y' */

  return (TRUE);


EXCEPTION

  when others then
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('complete_activity: ' || 'exception in CTO_WORKFLOW_API_PK.complete_activity:'||sqlerrm, 1);
    END IF;
    return (FALSE);

END complete_activity;

/*******************************************************************************
	Function:    	display_wf_status
	Parameters:  	p_order_line_id
	Description: 	This function is used to display a proper wf status from
		     	OM form.
	Fix for bug 1494878 :
			The operating unit can be set differently for
			OM and WIP reponsibilities. Hence, before calling OM's
			function to update the line status, we set the org
			context to the org_id on oe_order_lines_all. After
			returning from the OM function, we reset the org
			context to the WIP operating unit (profile MO:op unit)

	fix for bug 1895563 :
			Removed the top most if statement which was
	            	checking if order was booked and (scheduled or reserved)
*********************************************************************************/

FUNCTION display_wf_status(
		 p_order_line_id  IN      NUMBER
		 )
return INTEGER is

  v_ordered_quantity         NUMBER;
  v_header_id                NUMBER;
  l_oe_org_id                NUMBER;
  l_original_org_id          NUMBER;   -- rkaza. 11/10/2004. bug 3982767
  x_return_status            VARCHAR2(1);
  l_stmt_num                 number;
  v_inv_item_id              NUMBER;
  l_message                  NUMBER;
  l_ship_from_org_id         Oe_order_lines_all.ship_from_org_id%type;
  l_change_status            Varchar2(100);
  l_item_type_code           Varchar2(100);
  v_source_type_code	     Varchar2(100);
  --Bugfix 9826828
  --v_shipped_quantity        oe_order_lines_all.shipped_quantity%type;
  --v_shipped_qty	     	     number;		-- 2972186
  v_shipped_qty	     	     oe_order_lines_all.shipped_quantity%type;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(200);
  l_ato_line_id               NUMBER;
  l_top_model_line_id         NUMBER;
  l_booked_flag  varchar2(2) ;
  l_token1       varchar2(100);
  l_token2       varchar2(100);

    v_activity_status_code     varchar2(8);
    l_req_created              varchar2(1);

BEGIN

  IF PG_DEBUG <> 0 THEN
     oe_debug_pub.add('display_wf_status: ' || 'Entering display_wf_status', 1);
     cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'Entering Display_wf_status');
     cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'P_order_line_id ='||to_char(p_order_line_id));
  End if;

  v_ordered_quantity := 0;

  l_stmt_num := 10;

  select oel.header_id,
	 INV_CONVERT.inv_um_convert(	--bug 2317701
		oel.inventory_item_id,
		5,		-- pass precision of 5
		oel.ordered_quantity,
		oel.order_quantity_uom,
		msi.primary_uom_code,
		null,
		null
		),
         oel.org_id,
         oel.ship_from_org_id ,
         oel.inventory_item_id,
	 oel.item_type_code,
	 oel.source_type_code,
         nvl(oel.shipped_quantity,0),
	 oel.ato_line_id,            --added for patchset J
	 oel.top_model_line_id,       --added for patchset J
         oel.booked_flag
  into   v_header_id,
         v_ordered_quantity,
         l_oe_org_id,
         l_ship_from_org_id,
         v_inv_item_id,
	 l_item_type_code,
	 v_source_type_code,
         v_shipped_qty,
	 l_ato_line_id,
	 l_top_model_line_id,
         l_booked_flag
  from   oe_order_lines_all oel,
	 mtl_system_items msi
  where  line_id = p_order_line_id
  and 	 oel.inventory_item_id = msi.inventory_item_id
  and    oel.ship_from_org_id = msi.organization_id;

  If PG_DEBUG <> 0 Then
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'v_header_id  = '||to_char(v_header_id));
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'l_oe_org_id  = '||to_char(l_oe_org_id));
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'v_ordered_quantity  = '||to_char(v_ordered_quantity));
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'v_source_type_code  = '||v_source_type_code);
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'ato line id  = '||l_ato_line_id);
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'top model line id  = '||l_top_model_line_id);
    oe_debug_pub.add('display_wf_status: ' || 'v_header_id  = '||to_char(v_header_id) , 5);
    oe_debug_pub.add('display_wf_status: ' || 'l_oe_org_id  = '||to_char(l_oe_org_id) , 5);
    oe_debug_pub.add('display_wf_status: ' || 'v_ordered_quantity  = '||to_char(v_ordered_quantity) , 5);
    oe_debug_pub.add('display_wf_status: ' || 'v_source_type_code  = '||v_source_type_code , 5);
    oe_debug_pub.add('display_wf_status: ' || 'ato line id  = '||l_ato_line_id , 5);
    oe_debug_pub.add('display_wf_status: ' || 'top model line id  = '||l_top_model_line_id , 5);
    oe_debug_pub.add('display_wf_status: ' || 'shipped quantity  = '||v_shipped_qty , 5);
  END IF;

  l_stmt_num := 11;

  If l_booked_flag = 'N' Then
     IF PG_DEBUG <> 0 Then
        cto_wip_workflow_api_pk.cto_debug('Display_wf_status',' Line is not yet booked. No need to change status');
	oe_debug_pub.add('Display_wf_status: Line is not yet booked. No need to change status',1);
     End if;
  --Bugfix 9826828
  --elsif nvl(v_shipped_quantity,0) <> 0 then
  elsif nvl(v_shipped_qty,0) <> 0 then

     If PG_DEBUG <> 0 Then
       cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS',
                                         'Line is shipped no need to change the status..');
     End if;

  Elsif v_source_type_code = 'EXTERNAL' THEN




     If PG_DEBUG <> 0 Then
	cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'Drop ship line, will be  updating line status');
     End if;

      --bugfix 5461892


      Begin
        select 'Y'
	INTO  l_req_created
	from  oe_drop_ship_sources
	where line_id = p_order_line_id;
      Exception
        When others THEN
           l_req_created := 'N';
      End;


        IF  l_booked_flag = 'Y' and l_req_created = 'N'   THEN
             l_token1 := 'SUPPLY';
             l_token2 := 'ELIGIBLE';
	END IF;
     --end bugfix 5461892

  Else
     get_status_tokens(
                           p_order_line_id     => p_order_line_id,
			   p_config_item_id    => v_inv_item_id,
			   p_ship_from_org_id  => l_ship_from_org_id,
			   p_ordered_quantity  => v_ordered_quantity,
			   x_token1            => l_token1,
			   x_token2            => l_token2,
			   x_return_status     => x_return_status,
			   x_msg_data          => l_msg_data,
			   x_msg_count         => l_msg_count);
  END IF; /* nvl(v_shipped_quantity,0) <> 0 */

  l_stmt_num := 170;

  IF l_token2 is null THEN --bugfix 4743430
     l_change_status := L_token1;
  ELSE
     l_change_status := L_token1||'_'||l_token2;
  END IF;




  If PG_DEBUG <> 0 Then
     oe_debug_pub.add('Display_wf_status : New status code = '||l_change_status,1);
  End if;

  If l_change_status <> '_' Then

    SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
                              NULL,
                              SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
    INTO   l_original_org_id
    FROM DUAL;



    change_status_batch (
                p_header_id          =>   v_header_id,
                p_line_id            =>   p_order_line_id,
                p_change_status      =>   l_change_status,
                p_oe_org_id          =>   l_oe_org_id,
            	x_return_status      =>   x_return_status);

    if  x_return_status = FND_API.G_RET_STS_ERROR then
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('display_wf_status: ' || 'change_status_batch raised expected error.', 1);
          cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'change_status_batch raised expected error.');
       End if;
       raise FND_API.G_EXC_ERROR;
    elsif  x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('display_wf_status: ' || 'change_status_batch raised unexpected error.', 1);
   	  cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'change_status_batch raised unexpected error.');
       End if;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if; /* x_return_status = FND_API.G_RET_STS_ERROR */

    IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('display_wf_status: ' || 'Re-Setting the Org Context to '||l_original_org_id, 5);
    END IF;

  End if; /* l_change_status <> '_' */

  IF PG_DEBUG <> 0 THEN
    oe_debug_pub.add('display_wf_status: ' || 'Exiting disp_wf_status', 4);
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', 'Exiting display_wf_Status with return value 1');
  End if;
  return 1;

EXCEPTION
  when FND_API.G_EXC_ERROR then
 	IF PG_DEBUG <> 0 THEN
 		oe_debug_pub.add('display_wf_status: ' || 'CTO_WORKFLOW_API_PK.display_wf_status raised exp error::stmt number '||to_char(l_stmt_num), 1);
        cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS',
				'CTO_WORKFLOW_API_PK.display_wf_status raised exp error::stmt number '|| to_char(l_stmt_num));
        End if;
	return 0;--bugfix 4545070

  when FND_API.G_EXC_UNEXPECTED_ERROR then
 	IF PG_DEBUG <> 0 THEN
 		oe_debug_pub.add('display_wf_status: ' || 'CTO_WORKFLOW_API_PK.display_wf_status raised unexp error::stmt number '||
				to_char(l_stmt_num)||sqlerrm, 1);
        cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS',
				'CTO_WORKFLOW_API_PK.display_wf_status raised unexp error::stmt number '|| to_char(l_stmt_num));
        End if;
	return 0;
  when others then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('display_wf_status: ' || 'CTO_WORKFLOW_API_PK.display_wf_status::stmt number '||to_char(l_stmt_num), 1);
		oe_debug_pub.add('display_wf_status: ' || sqlerrm, 1);
        cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS',
                                          'CTO_WORKFLOW_API_PK.display_wf_status::stmt number '||
                                          to_char(l_stmt_num));
        cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', sqlerrm);
        End if;
	return 0;

END display_wf_status;





/*************************************************************************
   Procedure:	inventory_reservation_check
   Parameters:	p_order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "

   Description:	Check if an order line status is either
                "CREATE_CONFIG_BOM_ELIGIBLE" or
         		"CREATE_SUPPLY_ORDER_ELIGIBLE"
				"SHIP_LINE"
*****************************************************************************/
PROCEDURE inventory_reservation_check(
	p_order_line_id   IN      NUMBER,
        x_return_status OUT  NOCOPY   VARCHAR2,
        x_msg_count     OUT  NOCOPY   NUMBER,
        x_msg_data      OUT  NOCOPY   VARCHAR2
        )
IS

  l_api_name 		CONSTANT varchar2(40)   := 'inventory_reservation_check';
  v_item_type_code 		oe_order_lines_all.item_type_code%TYPE;
  v_ato_line_id 		oe_order_lines_all.ato_line_id%TYPE;
  v_activity_status_code      	varchar2(8);
  v_source_type_code            oe_order_lines.source_type_code%type ;

  l_stmt_num			number;

  v_header_id                   oe_order_lines_all.header_id%type ;
  v_po_header_id                po_headers_all.po_header_id%type ;
  v_authorization_status        po_headers_all.authorization_status%type ;


  DROPSHIP_EXCEPTION           EXCEPTION  ;

BEGIN
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('inventory_reservation_check: ' || 'Entering inventory_reservation_check', 2);
        cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check', 'In inventory_reservation_check');
    End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_stmt_num := 10;

    select upper(item_type_code)
         , ato_line_id
         , source_type_code
         , header_id
    into  v_item_type_code
        , v_ato_line_id
        , v_source_type_code
        , v_header_id
    from oe_order_lines_all
    where line_id = p_order_line_id;

    -- here, we pass the Standard item line,
    -- namely, it will return a success.    */

    -- removing code to allow reservation for ATOitem
    -- by kkonada :adding below code again for dummy assignment*/
    If PG_DEBUG <> 0 then
       cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check', 'ATO Line Id    = '||v_ato_line_id);
       cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check', 'Item Type Code = '||v_item_type_code);
       cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check', 'Source Type Code = '||v_source_type_code);
       oe_debug_pub.add('inventory_reservation_check: ATO Line Id:'|| v_ato_line_id);
       oe_debug_pub.add('inventory_reservation_check: Item Type Code: '|| v_item_type_code);
       oe_debug_pub.add('inventory_reservation_check: Source Type Code: '|| v_source_type_code);
    End if;
   /*
   **  BUG#2234858, BUG#2312701 AND BUG#2358576 Drop Ship changes to disallow reservation
   **  for config items and ato items of external source type
   **  ATO ITEMS will behave as strict ATO ITEMS when under a PTO or stand alone.
   **  ATO ITEMS lose their identity when they are put as options under ATO MODELS
   **  ATO ITEMS will have ato_line_id = line_id and item_type_code either STANDARD
   **  or OPTION when their identity is preserved.
   */

    l_stmt_num := 30;

    if( v_source_type_code = 'EXTERNAL' AND
        (  ( v_item_type_code = 'CONFIG' ) OR
          ( ( v_ato_line_id = p_order_line_id AND
              --Adding INCLUDED item type code for SUN ER#9793792
	      --( v_item_type_code = 'STANDARD' OR v_item_type_code = 'OPTION' )
	      ( v_item_type_code = 'STANDARD' OR v_item_type_code = 'OPTION' OR v_item_type_code = 'INCLUDED')
            )
          )
         )
       )then

    Begin
      begin
-- Fixed FP bug 4888964
-- For dropship orders, if the first time created PO is
-- cancelled and created another PO against the so req
-- OM will store two records in oe_drop_ship_sources table
-- till 11.5.10. Though, OM will store only one row from R12
-- if the  data was created before R12, it can still have
-- more than one row for a given line id
-- We have chaged the sql to look at only non-cancelled po
-- to avoid too many rows exception

	select poh.authorization_status
	into   v_authorization_status
	from   po_headers_all poh,
               po_lines_all pol,
	       oe_drop_ship_sources ods
         where    ods.header_id = v_header_id
         and      ods.line_id = p_order_line_id
         and      ods.po_header_id = poh.po_header_id
         and      pol.po_line_id = ods.po_line_id
         and      nvl(pol.cancel_flag, 'N') <> 'Y';
--End of bug fix 4888964
     exception
           when others then
               If PG_DEBUG <> 0 Then
               cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check',
                      'no data found in po_headers_all for  om header ' ||
                      to_char( v_header_id ) || ' line id ' ||
                      to_char( p_order_line_id )  || ' po header id ' ||
                      to_char( v_po_header_id ) ) ;
               End if;
               raise DROPSHIP_EXCEPTION ;
      end ;

     exception
     when DROPSHIP_EXCEPTION then
        cto_msg_pub.cto_message('BOM', 'CTO_RESERVATION_INELIGIBLE');

        raise FND_API.G_EXC_ERROR;

     when others then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;

     end;

    end if ;


    l_stmt_num := 40;

    if  upper(v_item_type_code) = 'CONFIG' then

       -- a config item line
       -- check the line status is either
       -- CREATE_SUPPLY_ORDER_ELIGIBLE or
       -- SHIP_LINE

       l_stmt_num := 50;
       query_wf_activity_status(G_ITEM_TYPE_NAME,
                                TO_CHAR(p_order_line_id),
	 		        'EXECUTECONCPROGAFAS',
				'EXECUTECONCPROGAFAS',
			        v_activity_status_code);

       if  upper(v_activity_status_code) <> 'NOTIFIED' then

	   l_stmt_num := 60;
           query_wf_activity_status(G_ITEM_TYPE_NAME,
                                    TO_CHAR(p_order_line_id),
                                    'CREATE_SUPPLY_ORDER_ELIGIBLE',
                                    'CREATE_SUPPLY_ORDER_ELIGIBLE',
                                    v_activity_status_code);
	   l_stmt_num := 70;
       	   if  upper(v_activity_status_code) <> 'NOTIFIED' then

	      query_wf_activity_status(G_ITEM_TYPE_NAME,
				       TO_CHAR(p_order_line_id),
				       'SHIP_LINE',
				       'SHIP_LINE',
                                       v_activity_status_code);

              if  upper(v_activity_status_code) <> 'NOTIFIED' then
                 If PG_DEBUG <> 0 then
                    cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check', 'v_activity_status_code <> NOTIFIED');
                    cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check', 'Raising CTO_INVALID_ACTIVITY_STATUS');
                    cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
                 End if;
            	 raise FND_API.G_EXC_ERROR;
              end if;
       	   end if;
       end if;

    end if;
    If PG_DEBUG <> 0 then
        cto_wip_workflow_api_pk.cto_debug('inventory_reservation_check', 'Exiting inventory_reservation_check');
    	oe_debug_pub.add('inventory_reservation_check: ' || 'Exiting inventory_reservation_check', 2);
    END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('inventory_reservation_check: ' || 'exp error in CTO_WORKFLOW_API_PK.inventory_reservation_check::stmt number '||to_char(l_stmt_num), 1);
        cto_wip_workflow_api_pk.cto_debug('Inventory_reservation_check','Stmt no :'|| to_char(l_stmt_num));
        End if;

	x_return_status := FND_API.G_RET_STS_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('inventory_reservation_check: ' || 'unexp error in CTO_WORKFLOW_API_PK.inventory_reservation_check::stmt number '||to_char(l_stmt_num), 1);
        cto_wip_workflow_api_pk.cto_debug('Inventory_reservation_check','Stmt no:'|| to_char(l_stmt_num));
        End if;
   	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);

  when others then
    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('inventory_reservation_check: ' || 'unexp error in CTO_WORKFLOW_API_PK.inventory_reservation_check::stmt number '||to_char(l_stmt_num), 1);

		oe_debug_pub.add('inventory_reservation_check: ' || sqlerrm);
        cto_wip_workflow_api_pk.cto_debug('Inventory_reservation_check','Stmt no:'||to_char(l_stmt_num) );
        cto_wip_workflow_api_pk.cto_debug('Inventory_reservation_check', sqlerrm);
        End if;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    	END IF;
    	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);


END inventory_reservation_check;


/*************************************************************************
   Procedure:   wf_update_after_inv_reserv
   Parameters:  p_order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "

   Description: update an order line status after inventory reservation

*****************************************************************************/
PROCEDURE wf_update_after_inv_reserv(
        p_order_line_id   IN      NUMBER,
        x_return_status OUT NOCOPY    VARCHAR2,
        x_msg_count     OUT NOCOPY    NUMBER,
        x_msg_data      OUT NOCOPY    VARCHAR2
        )
IS

   l_api_name                CONSTANT varchar2(40)   := 'wf_update_after_inv_reserv';
   v_item_type_code          oe_order_lines_all.item_type_code%TYPE;
   v_ato_line_id             oe_order_lines_all.ato_line_id%TYPE;
   v_activity_status_code    varchar2(8);
   return_value              integer :=1; 	--fix for bug#1895563
   /*******************************************************
      return value is intialized to 1 in the begining,
      in order to have only one if condition to check
      the status returned by display_wf_status called
      at various places (for an ato item)

      before this fix return_value was not intialized
   ********************************************************/
   l_stmt_num		     number;
   l_message                 varchar2(100);
   l_source_document_type_id number;
   l_inv_quantity            number;
   l_complete_activity       Boolean;


BEGIN
    If PG_DEBUG <> 0 Then
       cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Entering wf_update_after_inv_reserv');
    End if;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Entering wf_update_after_inv_reserv', 2);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_stmt_num := 10;

    If PG_DEBUG <> 0 Then
       cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV', 'Before selecting info from oe_order_lines_all');
    End if;


    select item_type_code,
           ato_line_id
    into   v_item_type_code,
           v_ato_line_id
    from   oe_order_lines_all
    where  line_id = p_order_line_id;
    If PG_DEBUG <> 0 Then
       cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV', 'ato_line_id = '||v_ato_line_id);
       cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV', 'v_item_type_code = '||v_item_type_code);
       oe_debug_pub.add('wf_update_after_inv_reserv: ato_line_id:' || v_ato_line_id);
       oe_debug_pub.add('wf_update_after_inv_reserv: v_item_type_code:' || v_item_type_code);
       oe_debug_pub.add('wf_update_after_inv_reserv: p_order_line_id:' || p_order_line_id);
    End if;


    IF (   (upper(v_item_type_code) = 'STANDARD')   -- Ato item line
        OR (upper(v_item_type_code) = 'OPTION')     --fix for bug#1874380
	--Adding INCLUDED item type code for SUN ER#9793792
	OR (upper(v_item_type_code) = 'INCLUDED')
       )
        AND (v_ato_line_id = p_order_line_id) then

       --  an ATO item line
       --  check if the line status is CREATE_SUPPLY_ORDER_ELIGIBLE or
       --  SHIP_LINE

       l_stmt_num := 20;

       IF PG_DEBUG <> 0 THEN
       	--SUN ER#9793792: Changed the debug message
	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'item_type_code is STANDARD/OPTION/INCLUDED => an ato item', 4);
       END IF;--fix for bug#1874380
       If PG_DEBUG <> 0 Then
          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Before querying wf_activity_status..');
       End if;

       -- Check if workflow is in Create supply order eligible activity

       query_wf_activity_status(G_ITEM_TYPE_NAME,
                                TO_CHAR(p_order_line_id),
			        'CREATE_SUPPLY_ORDER_ELIGIBLE',
			        'CREATE_SUPPLY_ORDER_ELIGIBLE',
                                v_activity_status_code);

       If PG_DEBUG <> 0 then
          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','v_activity_status_code = '||
                                           upper(v_activity_status_code));
       End if;
       -- If notified move the workflow to Ship line


       if  upper(v_activity_status_code) = 'NOTIFIED' then
         l_stmt_num := 30;
         If PG_DEBUG <> 0 Then
         cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Complete the workflow
                                                   stmt no : 30');
         End if;
	 -- Modified for MOAC project
	 -- Called complete_acitivity procedure instead of calling wf_engine api.

       	If (CTO_WORKFLOW_API_PK.complete_activity(
	                                       p_itemtype      => G_ITEM_TYPE_NAME,
					       p_itemkey       => to_char(p_order_line_id),
					       p_activity_name => 'CREATE_SUPPLY_ORDER_ELIGIBLE',
					       p_result_code   => 'RESERVED')) Then

           If PG_DEBUG <> 0 Then
              oe_debug_pub.add('WF_UPDATE_AFTER_INV_RESERV: Complete_activity is successful',5);
	   End if;

        Else
           if PG_DEBUG <> 0 Then
              oe_debug_pub.add('WF_UPDATE_AFTER_INV_RESERV: Complete_activity function returned error..',5);
	   end if;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End if;

        -- End of MOAC Change

         --start of fix for bug#1895563
         If PG_DEBUG <> 0 Then
         cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Before calling display_wf_status..'||
		                                   'from l_stmt_num=>'||l_stmt_num);
         	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Before calling display_wf_status.. from l_stmt_num=>'||l_stmt_num,2);
         END IF;

         return_value := display_wf_status(p_order_line_id);

         If PG_DEBUG <> 0 Then
         cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Return value after display_wf_status'
                                                     ||to_char(return_value));
	 	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Return value after display_wf_status at l_stmt_num=>'||l_stmt_num||'is'
		                   ||to_char(return_value),1);
	 END IF;
         --end of fix for bug#1895563


         -- follwoing else block was once removed but added again with some modifications to fix
	 -- bug#1895563
	 -- start of fix for bug#1895563

       else  -- not in supply order eligible

            l_stmt_num := 40;
            If PG_DEBUG <> 0 then
            cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Stmt no : 40, query
                                                   wf_activity status..');
            End if;

            query_wf_activity_status(G_ITEM_TYPE_NAME,
                                     TO_CHAR(p_order_line_id),
			       	     'EXECUTECONCPROGAFAS',
			             'EXECUTECONCPROGAFAS',
			             v_activity_status_code);

            If PG_DEBUG <> 0 then
            cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','v_activity_status_code = '||
                                                        v_activity_status_code);

           End if;
            IF  upper(v_activity_status_code) <> 'NOTIFIED' THEN

               l_stmt_num := 50;

               If PG_DEBUG <> 0 Then
               cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Stmt no : 50
                                                           querying wf_activity_status');
               End if;
	       query_wf_activity_status(G_ITEM_TYPE_NAME,
                                        TO_CHAR(p_order_line_id),
				        'SHIP_LINE',
                                        'SHIP_LINE',
                                        v_activity_status_code);

               If PG_DEBUG <> 0 Then
               cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV', 'v_actitivity_status_code ='||
                                                 v_activity_status_code);
               End if;
               IF  upper(v_activity_status_code) = 'NOTIFIED' then


                  If PG_DEBUG <> 0 Then
	          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',
                                                    'Before calling display_wf_status..'||
			                            'from l_stmt_num=>'||l_stmt_num);
                  	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Before calling display_wf_status.. from l_stmt_num=>'||l_stmt_num,2);
                  END IF;

	          return_value := display_wf_status(p_order_line_id);


                  If PG_DEBUG <> 0 Then
                  cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',
                                                    'Return value after display_wf_status'
                                                   ||to_char(return_value));
	          	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Return value after display_wf_status at l_stmt_num=>'||l_stmt_num||'is'
                                               ||to_char(return_value),1);
	          END IF;
	       END IF;

	    ELSE  -- Auto create fas Notified

                If PG_DEBUG <> 0 Then
                cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Before calling display_wf_status..'||
                                                           'from l_stmt_num=>'||l_stmt_num);
                	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Before calling display_wf_status.. from l_stmt_num=>'||l_stmt_num,2);
                END IF;

                return_value := display_wf_status(p_order_line_id);


                If PG_DEBUG <> 0  Then
                cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Return value after display_wf_status'
			                                   ||to_char(return_value));
	        	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Return value after display_wf_status at l_stmt_num=>'||l_stmt_num||'is'
			                     ||to_char(return_value),1);
	        END IF;
            END IF;
        --end of fix for bug#1895563

       end if;
       if return_value <> 1 then
                If PG_DEBUG <> 0 Then
                   cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Raising CTO_ERROR_FROM_DISPLAY_STATUS');
                End if;
    	 	cto_msg_pub.cto_message('BOM', 'CTO_ERROR_FROM_DISPLAY_STATUS');
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;


    elsif  upper(v_item_type_code) = 'CONFIG' then

       -- a config item line
       -- check the line status is either CREATE_CONFIG_BOM_ELIGIBLE - removed or
       -- CREATE_SUPPLY_ORDER_ELIGIBLE
       -- SHIP_LINE

       l_stmt_num := 60;

       If PG_DEBUG <> 0 Then
          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',
                                          ' Stmt no : 60 , querying activity_status');
       End if;

       query_wf_activity_status(G_ITEM_TYPE_NAME,
                                TO_CHAR(p_order_line_id),
                               'CREATE_SUPPLY_ORDER_ELIGIBLE',
                               'CREATE_SUPPLY_ORDER_ELIGIBLE',
                               v_activity_status_code);

       If PG_DEBUG <> 0 Then
          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',' v_actitivity_status_code = '||
                                                  v_activity_status_code);
       End if;

       IF  upper(v_activity_status_code) = 'NOTIFIED' then

          l_stmt_num := 70;

          If PG_DEBUG <> 0 Then
          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Stmt no : 70, Completing
                                                   workflow activity..');
          End if;

 	 -- Modified for MOAC project
	 -- Called complete_acitivity procedure instead of calling wf_engine api.

       	IF (CTO_WORKFLOW_API_PK.complete_activity(
	                                       p_itemtype      => G_ITEM_TYPE_NAME,
					       p_itemkey       => to_char(p_order_line_id),
					       p_activity_name => 'CREATE_SUPPLY_ORDER_ELIGIBLE',
					       p_result_code   => 'RESERVED')) Then
           If PG_DEBUG <> 0 Then
              oe_debug_pub.add('WF_UPDATE_AFTER_INV_RESERV: complete_activity is sucessful ',5);
	   End if;
	Else
           if PG_DEBUG <> 0 Then
              oe_debug_pub.add('WF_UPDATE_AFTER_INV_RESERV: Complete_activity function returned error..',5);
	   end if;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
	End if;

        -- End of MOAC Change


       ELSE

          l_stmt_num := 80;
          if pG_DEBUG <> 0 Then
          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',' Stmt no : 80 querying
                                                   wf_activity_status');
          end if;
          query_wf_activity_status(G_ITEM_TYPE_NAME,
                                   TO_CHAR(p_order_line_id),
			           'EXECUTECONCPROGAFAS',
			           'EXECUTECONCPROGAFAS',
			     	   v_activity_status_code);

          If PG_DEBUG <> 0 Then
          cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','v_activity_status_code = '||
                                                       v_activity_status_code);
          End if;

          IF  upper(v_activity_status_code) <> 'NOTIFIED' then

             l_stmt_num := 90;

             If PG_DEBUG <> 0 Then
             cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',' Stmt no : 90,
                                                          querying wf_activity_status');
             End if;
             query_wf_activity_status(G_ITEM_TYPE_NAME,
                                      TO_CHAR(p_order_line_id),
			              'SHIP_LINE',
                                      'SHIP_LINE',
                                      v_activity_status_code);

             If PG_DEBUG <> 0 Then
             cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV', ' v_activity_status_code = '||
                                                               v_activity_status_code);
             End if;

             if  upper(v_activity_status_code) <> 'NOTIFIED' then

                If PG_DEBUG <> 0 Then
                cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_reserv', 'v_activity_status_code <> NOTIFIED');
                cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_reserv', 'Raising CTO_INVALID_ACTIVITY_STATUS');
                End if;

    	        cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
                raise FND_API.G_EXC_ERROR;
             end if;

          END IF; /* end of v_activity_status_code check */

      END IF;

      -- 2350079 : moved the call display_wf_status from outside the IF clause to inside the clause.

      -- display proper status to OM form

      If PG_DEBUG <> 0 Then
      cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',' Before calling display_wf_status');
      End if;

      return_value := display_wf_status(p_order_line_id);

      If PG_DEBUG <> 0 Then
      cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',' Return_value from display_wf_status = '||
                                              to_char(return_value));
      End if;

      IF return_value <> 1 then
                IF PG_DEBUG <> 0 Then
                cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV','Raising CTO_ERROR_FROM_DISPLAY_STATUS');
                End if;
	     	cto_msg_pub.cto_message('BOM', 'CTO_ERROR_FROM_DISPLAY_STATUS');
	       	raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   end if; /* end of item_type_code check */
   If PG_DEBUG <> 0 then
   cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',' Exiting wf_update_after_inv_reserv');
   End if;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'Exiting wf_update_after_inv_reserv', 2);
   END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'exp error in CTO_WORKFLOW_API_PK.wf_update_after_inv_reserv::stmt number '||to_char(l_stmt_num), 1);
	END IF;

        If PG_DEBUG <> 0 Then
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',
                                          'Exp error in CTO_WORKFLOW_API_PK.wf_update_inv_reserv::
                                                stmt no : '||to_char(l_stmt_num)||'::'||sqlerrm);
        End if;

    	x_return_status := FND_API.G_RET_STS_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'unexp error in CTO_WORKFLOW_API_PK.wf_update_after_inv_reserv::stmt number '||to_char(l_stmt_num), 1);
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV',
                                          'UNExp error in CTO_WORKFLOW_API_PK.wf_update_inv_reserv::
                                                stmt no : '||to_char(l_stmt_num)||'::'||sqlerrm);
       End if;

    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);

  when others then
    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('wf_update_after_inv_reserv: ' || 'unexp error in CTO_WORKFLOW_API_PK.wf_update_after_inv_reserv::stmt number '||to_char(l_stmt_num), 1);

		oe_debug_pub.add('wf_update_after_inv_reserv: ' || sqlerrm, 1);
	END IF;
        If PG_DEBUG <> 0 Then
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV', 'OTHERS excpn: stmt no : '||to_char(l_stmt_num));
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_RESERV', sqlerrm);
        End if;

    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    	END IF;
    	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);


END wf_update_after_inv_reserv;



/*************************************************************************
   Procedure:	inventory_unreservation_check
   Parameters:	p_order_line_id
	        p_rsv_quantity          - Unreservation Quantity
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "

   Description:	Check if an order line status is
         		"SHIP_LINE"
*****************************************************************************/
PROCEDURE inventory_unreservation_check(
	p_order_line_id   IN      NUMBER,
	p_rsv_quantity	  IN      NUMBER,		--bugfix 2001824: Added parameter p_rsv_quantity
        x_return_status OUT NOCOPY    VARCHAR2,
        x_msg_count     OUT NOCOPY    NUMBER,
        x_msg_data      OUT NOCOPY    VARCHAR2
        )
IS

  l_api_name 			CONSTANT VARCHAR2(40)   := 'inventory_unreservation_check';
  v_item_type_code 		oe_order_lines_all.item_type_code%TYPE;
  v_ato_line_id 		oe_order_lines_all.ato_line_id%TYPE;
  v_activity_status_code      	VARCHAR2(8);
  l_stmt_num			number;

BEGIN
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('inventory_unreservation_check: ' || 'Entering inventory_unreservation_check', 2);
    cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check','Entering inventory_unreservation_check');
    End if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_stmt_num := 10;

    select item_type_code, ato_line_id
    into  v_item_type_code, v_ato_line_id
    from oe_order_lines_all
    where line_id = p_order_line_id;

    --
    -- For CONFIG items, unreservation is allowed only when the workflow has moved to SHIP LINE.
    -- You cannot un-reserve a CONFIG line (at present) before a work-order is created.
    -- If this API is called before or after SHIP_LINE, then, raise error.
    --

    if (upper(v_item_type_code) = 'CONFIG') then
	l_stmt_num := 20;
	query_wf_activity_status(G_ITEM_TYPE_NAME, TO_CHAR(p_order_line_id),
							   'SHIP_LINE',
							   'SHIP_LINE', v_activity_status_code);
      	if  upper(v_activity_status_code) <> 'NOTIFIED' then
                If PG_DEBUG <> 0 Then
                cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check', 'v_activity_status_code <> NOTIFIED');
                cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check', 'Raising CTO_INVALID_ACTIVITY_STATUS');
                End if;
		cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
		raise FND_API.G_EXC_ERROR;
      	end if;
    end if;

    --
    -- For ATO items and CONFIG items, we should check the qty being unreserved.
    --

    --Adding INCLUDED item type code for SUN ER#9793792
    --if (((upper(v_item_type_code) = 'STANDARD') OR (upper(v_item_type_code) = 'OPTION'))
									--fix for bug#1874380
    if ((   (upper(v_item_type_code) = 'STANDARD')
         OR (upper(v_item_type_code) = 'OPTION')
	 OR (upper(v_item_type_code) = 'INCLUDED')
	)
         AND (v_ato_line_id = p_order_line_id )
       )
         OR (upper(v_item_type_code) = 'CONFIG' )
    then

	--begin bugfix 2001824 : check if qty being unreserved is ok
        If PG_DEBUG <> 0 Then
           cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check', 'p_rsv_quantity'||p_rsv_quantity);
        End if;
	if (CTO_UTILITY_PK.check_rsv_quantity (p_order_line_id => p_order_line_id,
					       p_rsv_quantity  => p_rsv_quantity) = FALSE )
	then
	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add ('inventory_unreservation_check: ' || 'Unreservation of qty '||p_rsv_quantity ||
		' is NOT allowed since part of this has been either ship confirmed, intrasit or closed.', 2);
	    END IF;

            If PG_DEBUG <> 0 Then
            cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check', 'v_activity_status_code <> NOTIFIED');
            cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check', 'Raising CTO_INVALID_ACTIVITY_STATUS');
            End if;
            cto_msg_pub.cto_message('BOM', 'CTO_INVALID_ACTIVITY_STATUS');
            raise FND_API.G_EXC_ERROR;
	else
	    IF PG_DEBUG <> 0 THEN
	    	oe_debug_pub.add ('inventory_unreservation_check: ' || 'Quantity being unreserved ('||p_rsv_quantity||') is okay.',4);
	    END IF;
	end if;

    	--end bugfix 2001824
     end if;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('inventory_unreservation_check: ' || 'Exiting inventory_unreservation_check', 2);
        cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check', 'Exiting inventory_unreservation_check');
     End if;

EXCEPTION

  when FND_API.G_EXC_ERROR then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('inventory_unreservation_check: ' || 'exp error in CTO_WORKFLOW_API_PK.inventory_unreservation_check::stmt number '||to_char(l_stmt_num), 1);
        cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check',
					'Raised FND_API.G_EXC_ERROR, stmt'||l_stmt_num);
        End if;
    	x_return_status := FND_API.G_RET_STS_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);

  when FND_API.G_EXC_UNEXPECTED_ERROR then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('inventory_unreservation_check: ' || 'unexp error in CTO_WORKFLOW_API_PK.inventory_unreservation_check::stmt number '||to_char(l_stmt_num), 1);
        cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check',
					'Raised FND_API.G_EXC_UNEXPECTED_ERROR, stmt'||l_stmt_num);
        End if;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);

  when others then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('inventory_unreservation_check: ' || 'unexp error in CTO_WORKFLOW_API_PK.inventory_unreservation_check::stmt number '||to_char(l_stmt_num), 1);

		oe_debug_pub.add('inventory_unreservation_check: ' || sqlerrm, 1);
        cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check',
					'Raised OTHERS excepn, stmt: '||l_stmt_num);
        cto_wip_workflow_api_pk.cto_debug('inventory_unreservation_check', sqlerrm);
        End if;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    	END IF;
    	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);


END inventory_unreservation_check;


/*************************************************************************
   Procedure:   wf_update_after_inv_unreserv
   Parameters:  p_order_line_id
                x_return_status         - standard API output parameter
                x_msg_count             -           "
                x_msg_data              -           "

   Description: update an order line status after inventory unreservation


   The logic for this procedure is as follows:

  1. IF the Workflow is in Ship Notified  then check for the reservation (All kinds)
     for this line. If there is no reservation found, Move the workflow to Create
     Supply order eligible.

  2. IF the line is not in Ship notified  then, Check if it is a config line. If it is
     a config line error out.

  3. Call display_wf_status for all the scenarios.

  4. In the case ATO item, No action is taken if the line is not in Ship notified.

  5. This API is called for all types if items.

*****************************************************************************/


PROCEDURE wf_update_after_inv_unreserv(
        p_order_line_id   IN      NUMBER,
        x_return_status OUT  NOCOPY   VARCHAR2,
        x_msg_count     OUT  NOCOPY   NUMBER,
        x_msg_data      OUT  NOCOPY   VARCHAR2
        )
IS

    l_api_name          CONSTANT varchar2(40)   := 'wf_update_after_inv_unreserv';
    v_item_type_code             oe_order_lines_all.item_type_code%TYPE;
    v_ato_line_id                oe_order_lines_all.ato_line_id%TYPE;
    v_activity_status_code       varchar2(8);
    v_counter                    integer;
    v_counter2                   integer;
    return_value                 integer;
    l_stmt_num	                 number;
    l_source_document_type_id    number;	-- bugfix 1799874
    l_message                    varchar2(100);
    l_po_req_qty                 Number;
    l_split_from_line_id         oe_order_lines_all.split_from_line_id%TYPE;

    l_dummy                      number;


    -- added by Renga Kannan on 09/05/02 for ATO Back order changes

    l_changed_attributes    WSH_INTERFACE.ChangedAttributeTabType;

    -- Done Renga Kannan

 --added by Kiran
  l_inventory_item_id		number;
  l_ship_from_org_id            number;
  l_can_create_supply           varchar2(1);
  --l_source_type                 varchar2(1);
  l_source_type                 number;  --Bugfix 6470516
 --done added by kiran

-- Fix for performance bug 4897231
-- To avoid full table scan on po_requisitions_table
-- added another where condition for item_id
-- Po_req_interface table has index on item_id column

    cursor INT_REQ is
	SELECT interface_source_line_id
        FROM   po_requisitions_interface_alL
        WHERE  interface_source_line_id = l_split_from_line_id
        AND    process_flag  is NULL
	and    item_id   = l_inventory_item_id
        FOR UPDATE of interface_source_line_id NOWAIT;



  -- begin bugfix 2109503
  v_x_return_status		varchar2(1);
  v_x_msg_count			number;
  v_x_msg_data			varchar2(2000);



  -- for new shipping min max tolerance api
  l_in_attributes		WSH_INTEGRATION.MinMaxInRecType;
  l_out_attributes		WSH_INTEGRATION.MinMaxOutRecType;
  l_inout_attributes		WSH_INTEGRATION.MinMaxInOutRecType;

  --ireq and opm
  l_sourcing_org number;
  l_return_msg varchar2(100);

  -- Bug Fix 4863275
  l_ship_xfaced_flag   varchar2(1);
  v_open_flag          varchar2(1);            -- Bugfix 7214005

BEGIN
    If PG_DEBUG <> 0 Then
        cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'In wf_update_after_inv_unreserv');
    	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'Entering wf_update_after_inv_unreserv', 2);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_stmt_num := 10;


    -- Modified to get the split from line_id also
    -- Bug fix 4863275. Added shiping_interfaced_flag in the select list

    select item_type_code,
           ato_line_id,
           split_from_line_id,
	   inventory_item_id, --added by kiran
	   ship_from_org_id,   --added by kiran
	   nvl(shipping_interfaced_flag,'N'),   -- Bug fix 4863275
           open_flag                            -- Bugfix 7214005
    into

           v_item_type_code,
           v_ato_line_id,
           l_split_from_line_id,
	   l_inventory_item_id,
	   l_ship_from_org_id,
           l_ship_xfaced_flag,            -- Bug fix 4863275
           v_open_flag                    -- Bugfix 7214005
    from   oe_order_lines_all
    where  line_id = p_order_line_id;

    If PG_DEBUG <> 0 Then
        cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'ATO Line Id    = '||v_ato_line_id);
        cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'Item Type Code = '||v_item_type_code);
        cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'Open Flag = '||v_open_flag);
        oe_debug_pub.add('wf_update_after_inv_unreserv ' || 'ATO Line Id    ='||v_ato_line_id, 1);
        oe_debug_pub.add('wf_update_after_inv_unreserv ' || 'Item Type Code ='||v_item_type_code, 1);
        oe_debug_pub.add('wf_update_after_inv_unreserv ' || 'Open Flag ='||v_open_flag, 1);
    End if;

    if v_open_flag = 'Y' then           --Bugfix 7214005
    l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( pLineId => p_order_line_id );	--bugfix 1799874

    --Adding INCLUDED item type code for SUN ER#9793792
    --IF ((upper(v_item_type_code) = 'STANDARD'  OR upper(v_item_type_code) = 'OPTION' )		--fix for bug# 1874380
    IF ((   upper(v_item_type_code) = 'STANDARD'
         OR upper(v_item_type_code) = 'OPTION'
	 OR upper(v_item_type_code) = 'INCLUDED'
        )
         AND (v_ato_line_id = p_order_line_id)
       )
       OR  upper(v_item_type_code) = 'CONFIG'
    THEN

        --  an ATO item line or CONFIG line
        --  check if the line status is SHIP_LINE

        -- Unreserve Activity is allowed only if the ATO/Config line is
        -- In Ship line activity. Otherwise we cannot unreserve
        -- But due to ATO item enhancement and AUTO Create project
        -- There are some variations for this rule.
        -- Those variations are handled in the else clause .


	l_stmt_num := 20;

	query_wf_activity_status(G_ITEM_TYPE_NAME,
                                 TO_CHAR(p_order_line_id),
			         'SHIP_LINE',
			         'SHIP_LINE',
                                 v_activity_status_code);

      	IF  upper(v_activity_status_code) = 'NOTIFIED' THEN

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'Ship Line Notified...',1);
           END IF;

	   --to check if cto or planning has created the supply
	   CTO_UTILITY_PK.check_cto_can_create_supply (
				P_config_item_id    =>l_inventory_item_id,
				P_org_id            =>l_ship_from_org_id,
				x_can_create_supply =>l_can_create_supply,
				p_source_type       =>l_source_type,
				x_return_status     =>x_return_status,
				X_msg_count	    =>x_msg_count,
				X_msg_data	    =>x_msg_data,
				x_sourcing_org      =>l_sourcing_org, --R12 IREQ,OPM new parameter
		                x_message         =>l_return_msg --R12 IREQ,OPM new parameter
	  					 );


            IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add('wf_update_after_inv_unreserv: ' ||'check_cto_can_create_supply'
		                 ||'x_return_status=> ' || x_return_status);

           	oe_debug_pub.add('wf_update_after_inv_unreserv: ' ||
		                    'l_can_create_supply is=>'||l_can_create_supply,1);

            END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR  THEN
		RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS
	     and
             l_can_create_supply = 'Y' THEN

		v_counter  := 0;
		l_stmt_num := 30;


           -- Look at the Qty reserved in MTL_RESERVATION_TABLE

           -- This reservation looks for work order, purchase related and inv reservation

           select count(*)
           into   v_counter
	   from   mtl_reservations
  	   where  demand_source_type_id = decode (l_source_document_type_id, 10,
       						  inv_reservation_global.g_source_type_internal_ord,
					 	  inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
           and    demand_source_line_id = p_order_line_id
	   and    primary_reservation_quantity > 0;

           If PG_DEBUG <> 0 Then
           cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'v_counter =  '||v_counter);
           End if;

           v_counter2 := 0;
	   l_stmt_num := 40;

	   -- bugfix 1799874 : as per adrian suherman, we need not worry about internal SO for wip_flow_schedules.

           -- Look at the reservation qty in Flow schedule table

	   select count(*)
           into   v_counter2
	   from   wip_flow_schedules
	   where  demand_source_type = 2
	   and    demand_source_line = to_char(p_order_line_id)
	   and    status <> 2;		-- 3076061  Flow Schedule status : 1 = Open  2 = Closed/Completed


    	   -- begin bugfix 3174334
	   -- Since flow does not update the schedule with new line_id when the order line is split, we need
	   -- to call the following function which will determine the open quantity.
	   -- If open_qty exists, we should keep the workflow in SHIP_LINE.

	   if v_counter2 = 0 then
		v_counter2 :=
		MRP_FLOW_SCHEDULE_UTIL.GET_FLOW_QUANTITY( p_demand_source_line => to_char(p_order_line_id),
							  p_demand_source_type => inv_reservation_global.g_source_type_oe,
							  p_demand_source_delivery => NULL,
							  p_use_open_quantity => 'Y');
	   end if;
	   -- end bugfix 3174334

           If PG_DEBUG <> 0 Then
           cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'v_counter2 =  '||v_counter2);
           End if;
           ---Modified by Renga Kannan on 12/18/2000

           -- Modified by Renga Kannan on 14-NOV-2001

           -- In the case of BUY ATO, If the line is being split because of partial shipping
           -- There is a possibility that some records may still be in the interface table
           -- for the parent line. This API will get called for the new line. If this new line
           -- is because of split action, then we should try to update the interface table
           -- with this line id.

           -- We can find whether this line is split line by looking at the split_from_line_id column
           -- If this column is populated that means the line is a split line.

           IF l_split_from_line_id is not null THEN

              BEGIN
                FOR c1 IN INT_REQ
                LOOP

                   UPDATE PO_REQUISITIONS_INTERFACE_ALL
                   SET interface_source_line_id = p_order_line_id
                   WHERE CURRENT OF INT_REQ;

                END LOOP;
              EXCEPTION WHEN OTHERS THEN
                Null;
              END;

           END IF;--split line id

           -- For Buy models if the line has some interface records without error that
           -- Should be considered as reservation
-- Fix for performance bug 4897231
-- To avoid full table scan on po_requisitions_table
-- added another where condition for item_id
-- Po_req_interface table has index on item_id column

           SELECT Nvl(Sum(quantity),0)
           INTO   l_po_req_qty
           FROM   po_requisitions_interface_all
           WHERE  interface_source_line_id = p_order_line_id
	       and    item_id    = l_inventory_item_id
           AND    process_flag is null;

           If PG_DEBUG <> 0 Then
           cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'l_po_req_qty =  '||l_po_req_qty);
           End if;

           -- no reservation at all

           -- Begin bugfix 2109503

	   --
	   -- bugfix 2109503
	   --
	   -- We need to check from OM if its okay to update the workflow back to create supply order
	   -- eligible. We will call Get_Min_max_Tolerance_Quantity to see whether OM will fulfil this line.
	   -- If so, we will not update the w/f
	   -- Eg, OQ=10, ship tolerance belo=20%; WO Qty=10; Complete=8; Ship=8; Inv i/f;
	   -- This leaves reservation of qty=2 against wip.
	   -- Running OM i/f will result in closing this line since qty 8 is within undership tolerance
	   -- OM/Shipping will call Inv to delete any reservations existing and inv will unreserve qty=2
	   -- after validating against CTO. Now, wf_update_after_inv_unreserv will make the line back to
	   -- create supply order eligible !! and OM i/f will fail since it expect it to be in ship
	   -- notified.
	   --
	   -- Get_Min_Max_Tolerance_Quantity will return x_min_remaining_quantity=0 if fulfilled.
	   -- If this value is 0, then, we do not update the w/f status back to create supply eligible.
	   --

	   If l_ship_xfaced_flag = 'Y' Then
	   IF PG_DEBUG <> 0 THEN
	   	oe_debug_pub.add ('wf_update_after_inv_unreserv: ' || 'CTO: Calling OE_Shipping_Integration_Pub.Get_Min_Max_Tolerance_Quantity..', 4);
	   END IF;

  	   -- rkaza. 04/18/2005 bug 2985672
	   -- Calling shipping tolerance api as a replacement of OM's api.

	   l_in_attributes.api_version_number := 1.0;
	   l_in_attributes.source_code := 'OE';
	   l_in_attributes.line_id := p_order_line_id;

	   WSH_INTEGRATION.Get_Min_Max_Tolerance_Quantity
           (    p_in_attributes           => l_in_attributes,
                p_out_attributes          => l_out_attributes,
                p_inout_attributes        => l_inout_attributes,
                x_return_status           => v_x_return_status,
                x_msg_count               => v_x_msg_count,
                x_msg_data                => v_x_msg_data);

           IF (v_x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                   IF PG_DEBUG <> 0 THEN
                   cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv',
							'Failed in WSH_Integration_Pub.Get Tolerance');
                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'CTO:Failed in WSH_Integration_Pub.Get Tolerance :' || v_x_return_status, 1);
                   END IF;
                   OE_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   ELSE
		   IF PG_DEBUG <> 0 THEN
		   	oe_debug_pub.add ('wf_update_after_inv_unreserv: ' || 'CTO: Returned from WSH_Integration_Pub.Get_Min_Max_Tolerance_Quantity.', 4);

                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'v_counter = '|| v_counter, 4);

                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'v_counter2 = '|| v_counter2, 4);

                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'x_min_remaining_quantity = '|| l_out_attributes.min_remaining_quantity, 4);

                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'x_max_remaining_quantity = '|| l_out_attributes.max_remaining_quantity, 4);

                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'x_min_remaining_quantity2 = '|| l_out_attributes.min_remaining_quantity2, 4);

                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'x_max_remaining_quantity2 = '|| l_out_attributes.max_remaining_quantity2, 4);
                   END IF;
           END IF ;--get min max status if block
	   End If;
           -- End bugfix 2109503

	   -- With post-CMS (change mgmt from OM), unreservation will be triggered from shipping rather than OM.
	   -- OM.

           IF PG_DEBUG <> 0 THEN
           cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'v_x_min_remaining_quantity =  '|| l_out_attributes.min_remaining_quantity);
	   cto_wip_workflow_api_pk.cto_debug('Wf_update_after_inv_unreserve',' Shipping interfaced flag = '||l_ship_xfaced_flag);
  	   oe_debug_pub.add('Wf_update_after_inv_unreserve: Shipping interfaced flag = '||l_ship_xfaced_flag);
           end if;

	   -- bugfix 2118864
           -- If there is no reservation for this line  and if the line is not
	   -- fulfiled, then, Workflow will be moved to Create supply order
	   -- eligible.

       	   if v_counter = 0    and
              v_counter2 = 0   and
              l_po_req_qty = 0 and
              (l_ship_xfaced_flag = 'N' or nvl(l_out_attributes.min_remaining_quantity,0) > 0 )
           then

             IF PG_DEBUG <> 0 Then
                cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'No Reservations exists... Updating workflow.');
              	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'No Reservation Exists...',1);
              END IF;

              l_stmt_num := 50;

              -- bugfix 3076061
	      -- The following code should not be executed unless OM.I is installed.
	      -- need to make WSHCRCNS as prereq

               -- Bugfix 4863275: Added l_ship_xface_flag condition. Only if the line is interfaced to shipping.


              if (WSH_CODE_CONTROL.Get_Code_Release_Level > '110508' and l_ship_xfaced_flag = 'Y') then

                 -- The commented part for shipping change and will be tested  later.
                 -- Added by Renga Kannan on 09/05/02 to set the delivery details flag to 'N'

		 -- bugfix 3202736: changed the index from 0 to 1.

                 l_changed_attributes(1).source_line_id  :=  p_order_line_id;
                 l_changed_attributes(1).released_status := 'N';
                 l_changed_attributes(1).action_flag     := 'U';

                 IF PG_DEBUG <> 0 THEN
              	    oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'Renga: Updating the shipping attributes..',1);
                 cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv',
                                                        'Renga : CAlling Shipping update attribute api');
                 End if;
                 WSH_INTERFACE.Update_Shipping_Attributes
                 (       p_source_code                   =>      'OE'
                 ,       p_changed_attributes            =>      l_changed_attributes
                 ,       x_return_status                 =>      v_x_return_status
                 );


                 IF (v_x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

                   IF PG_DEBUG <> 0 THEN
                   cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv',
                                                        'WSH_INTERFACE.update_shipping_attributes');
                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'CTO:Failed in WSH_INTERFACE.update_shipping_attributes :', 1);
                   END IF;
                   OE_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSE
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || ' Renga: Success in update_shipping attributes..', 2);
                   cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserve',
						     ' Renga: Success in update_shipping attributes..');

                   END IF;
                END IF ;
	    end if; -- bugfix 3076061 Get_Code_Release_Level
	    -- Fix for bug 5357300
	    -- Replaces the direct workflow engine call wf_engine.CompleteActivityInternalName
	    -- To CTO wrapper api call. As the cto wrapper api will take care of org context switch

            If (CTO_WORKFLOW_API_PK.complete_activity(
	                                       p_itemtype      => G_ITEM_TYPE_NAME,
					       p_itemkey       => to_char(p_order_line_id),
					       p_activity_name => 'SHIP_LINE',
					       p_result_code   => 'UNRESERVE')) Then

              If PG_DEBUG <> 0 Then
                 oe_debug_pub.add('WF_UPDATE_AFTER_INV_RESERV: Complete_activity is successful',5);
	      End if;

           Else
              if PG_DEBUG <> 0 Then
                 oe_debug_pub.add('WF_UPDATE_AFTER_INV_RESERV: Complete_activity function returned error..',5);
	      end if;
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           End if;
           -- End of bug fix 5357300
           else
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'Reservation Exists. Will not update workflow status.',1);
              END IF;
           end if; --v_counter

    END IF; --status of check_cto_can_create_supply
           --start of fix for bug#1895563
           --this call was moved here from the end of procedure

           -- display proper status to OM form

           return_value := display_wf_status(p_order_line_id);

           if return_value <> 1 then

              if PG_DEBUG <> 0 Then
              cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'Raising CTO_ERROR_FROM_DISPLAY_STATUS');
              End if;
              cto_msg_pub.cto_message('BOM', 'CTO_ERROR_FROM_DISPLAY_STATUS');
              raise FND_API.G_EXC_UNEXPECTED_ERROR;

           end if;
           --end of fix for bug#1895563


      --- Modified by Renga Kannan on 0p9/25/02
      --- We should not error out when the line is not in Ship node.
      --- There are some cases where the line will not be in ship node and this
      --  API is still called. Shipping is one among the cases. And also, if
      --- Customer is having customization for a workflow this will happen.

       End if;

     END IF;
     end if;  --v_open_flag Bugfix 7214005

     IF PG_DEBUG <> 0 THEN
        cto_wip_workflow_api_pk.cto_debug('wf_update_after_inv_unreserv', 'Exiting wf_update_after_inv_unreserv');
     	oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'Exiting wf_update_after_inv_unreserv', 2);
     END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'exp error in CTO_WORKFLOW_API_PK.wf_update_after_inv_unreserv::stmt number '||to_char(l_stmt_num), 1);
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_UNRESERVE','exp erro  stmt no :'|| to_char(l_stmt_num));

	END IF;
    	x_return_status := FND_API.G_RET_STS_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);

  when FND_API.G_EXC_UNEXPECTED_ERROR then

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'unexp error in CTO_WORKFLOW_API_PK.wf_update_after_inv_unreserv::stmt number '||to_char(l_stmt_num));
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_UNRESERVE','Unexp err stmt no:'|| to_char(l_stmt_num));

	END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);

  when others then

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('wf_update_after_inv_unreserv: ' || 'unexp error in CTO_WORKFLOW_API_PK.wf_update_after_inv_unreserv::stmt number '||to_char(l_stmt_num), 1);
		oe_debug_pub.add('wf_update_after_inv_unreserv: ' || sqlerrm, 1);
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_UNRESERVE','Unexp errr stmt no :'|| to_char(l_stmt_num));
        cto_wip_workflow_api_pk.cto_debug('WF_UPDATE_AFTER_INV_UNRESERVE',sqlerrm);

	END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    	END IF;
    	cto_msg_pub.count_and_get(
      		p_msg_count => x_msg_count,
      		p_msg_data  => x_msg_data
    	);


END wf_update_after_inv_unreserv;




/**************************************************************************

   Procedure:   configuration_item_created
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is used to check is
                a configured item is created. This condition is applied to
                an option line.

*****************************************************************************/



PROCEDURE configuration_item_created (
	p_application_id		IN  NUMBER,
	p_entity_short_name		IN  VARCHAR2,
	p_validation_entity_short_name	IN  VARCHAR2,
	p_validation_tmplt_short_name	IN  VARCHAR2,
	p_record_set_short_name		IN  VARCHAR2,
	p_scope				IN  VARCHAR2,
	x_result			OUT NOCOPY NUMBER )
IS
  v_header_id			number;
  v_model_id 			number;
  v_count               	number;
  v_activity_status_code 	varchar2(8);
  l_stmt_num 			number;

  e_invalid_line_id             exception;

BEGIN

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('configuration_item_created: ' || 'Entering configuration_item_created', 4);
  END IF;
  --
  -- find the top_model_line_id when given an option line id
  --
  l_stmt_num := 10;

  v_model_id := oe_line_security.g_record.ato_line_id;  /* refer to a global record */
  v_header_id := oe_line_security.g_record.header_id;

  --
  -- if not an ATO model line, condition is false, return 0
  --
  if (v_model_id is not NULL) AND (v_model_id <> fnd_api.g_miss_num) then

	-- check if the config item is created
	-- adding join to header_id for performance

  	v_count := 0;
  	l_stmt_num := 20;
  	select count(*) into v_count
  	from oe_order_lines_all
  	where header_id = v_header_id
  	and   ato_line_id = v_model_id
  	and   item_type_code = 'CONFIG';


  	if v_count <> 0  then
	   	x_result := 1; /* the condition is true */
  	else
       		x_result := 0; /* the condition is false */
  	end if;
  end if;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('configuration_item_created: ' || 'Exiting configuration_item_created', 4);
  END IF;

EXCEPTION

 when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_item_created: ' || 'CTO_WORKFLOW_API_PK.configuration_item_created::stmt number '||
			to_char(l_stmt_num)||'top model line does not exist, constraint condition is false', 1);
	END IF;
    	x_result := 0;

  when OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_item_created: ' || 'CTO_WORKFLOW_API_PK.configuration_item_created::stmt number '||
			to_char(l_stmt_num)||'constraint condition is false', 1);
		oe_debug_pub.add('configuration_item_created: ' || sqlerrm, 1);
	END IF;
    	x_result := 0;


END configuration_item_created;


/**************************************************************************

   Procedure:   configuration_created
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is called from
                the security constraints to validate whether a change is
                allowed on an order line.
                This API gets called for every item type. It returns
                x_result = 0 if the item is not part of an ATO
                model or if it is part of an ATO model that does not
                have a config item has not created yet.
                Otherwise, it returns x_result = 1.

*****************************************************************************/
PROCEDURE configuration_created (
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER )
IS
  l_header_id		NUMBER;
  l_ato_line_id         NUMBER;
  l_config_exists       NUMBER;
  l_stmt_num 	        NUMBER;


BEGIN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'Entering configuration_created', 5);
   END IF;
   -- Check if the line is not an ATO model, option, option class, or
   -- config line

   l_stmt_num := 5;
   select ato_line_id, header_id
   into   l_ato_line_id, l_header_id
   from   oe_order_lines_all
   where  line_id = oe_line_security.g_record.line_id
   and    item_type_code <> 'STANDARD'
   and    ato_line_id is not null;

   -- check if the config item is created
   -- adding join to header_id for performance
   l_stmt_num := 10;
   select 1
   into   l_config_exists
   from oe_order_lines_all
   where header_id = l_header_id
   and   ato_line_id = l_ato_line_id
   and   item_type_code = 'CONFIG';


    oe_debug_pub.add( 'ACTION CODE: ' || oe_line_security.g_record.split_action_code , 1 ) ;
    oe_debug_pub.add( 'OPERATION: ' || oe_line_security.g_record.operation , 1 ) ;
    oe_debug_pub.add( 'ATTRIBUTE 1: ' || oe_line_security.g_record.attribute1 , 1 ) ;
    oe_debug_pub.add( 'SPLIT FROM LINE ID: ' || oe_line_security.g_record.split_from_line_id , 1 ) ;
    oe_debug_pub.add( 'LINE ID: ' || oe_line_security.g_record.line_id , 1 ) ;



   x_result := 1; /* the condition is true */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'Exiting configuration_created', 5);
   END IF;



  -- x_result := 0;
 /*  IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'Exiting configuration_created'||
	                  'Sushant made it return 0 or False purposely', 5);
   END IF;*/
EXCEPTION

 when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'CTO_WORKFLOW_API_PK.configuration_item_created::stmt number '||
			to_char(l_stmt_num)||'top model line does not exist, constraint condition is false', 1);
	END IF;
    	x_result := 0;

  when OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'CTO_WORKFLOW_API_PK.configuration_item_created::stmt number '||
		to_char(l_stmt_num)||'constraint condition is false', 1);
		oe_debug_pub.add('configuration_created: ' || sqlerrm, 1);
	END IF;
    	x_result := 0;


END configuration_created;

/**************************************************************************

   Function:    start_model_workflow
   Parameters:  p_model_line_id
   Return:      TRUE - if model workflow is started successfully;
                FALSE - if model workflow is not started.
   Description: This API is used to start the ATO model workflow.
                Specifically, it completes the Create Config Item Eligible
                block activity.  It is called after a Match is performed
                from the Sales Order Pad form.
*****************************************************************************/

function start_model_workflow(p_model_line_id IN NUMBER)
return boolean

is
  l_active_activity varchar2(30);
  l_stmt_num 	number;

  PROCESS_ERROR     exception;

begin
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'Entering start_model_workflow', 5);
   END IF;

   l_stmt_num := 10;
   get_activity_status('OEOL',
                       to_char(p_model_line_id),
                       'MODEL',
                       l_active_activity);

   IF (l_active_activity = 'CREATE_CONFIG_ITEM_ELIGIBLE') THEN
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('configuration_created: ' || 'Workflow Status is: '||l_active_activity, 5);
       END IF;
	l_stmt_num := 20;

       	IF (CTO_WORKFLOW_API_PK.complete_activity(
					p_itemtype	=> 'OEOL',
                                        p_itemkey	=> p_model_line_id,
                                        p_activity_name	=> l_active_activity,
                                        p_result_code	=> 'COMPLETE') <> TRUE)
       	THEN
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('configuration_created: ' || 'Failed in Complete activity.', 1);
          END IF;
          raise PROCESS_ERROR;
       	END IF;

       	IF PG_DEBUG <> 0 THEN
       		oe_debug_pub.add('configuration_created: ' || 'Success in Complete activity.', 5);
       	END IF;
   ELSE
      	IF PG_DEBUG <> 0 THEN
      		oe_debug_pub.add ('configuration_created: ' || 'Workflow Status is not at Create Config Item Eligible.', 5);
      	END IF;

   END IF;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'Exiting start_model_workflow', 5);
   END IF;
   return TRUE;

exception

   when PROCESS_ERROR then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'exp error in CTO_WORKFLOW_API_PK.start_model_workflow::stmt number '||to_char(l_stmt_num), 1);
	END IF;
     	return FALSE;

   when OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'unexp error in CTO_WORKFLOW_API_PK.start_model_workflow::stmt number '||to_char(l_stmt_num), 1);
		oe_debug_pub.add('configuration_created: ' || sqlerrm, 1);
	END IF;
     	return FALSE;

end start_model_workflow;


/**************************************************************************

   Procedure:   Update_Config_Line
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is called from
                the security constraints to validate whether a change is
                allowed on an order line.
                This API gets called for every item type. It returns
                x_result = 0 if the item is a config item and the line is
		being updated by a system action (like scheduling or
		cascading).
                Otherwise, it returns x_result = 1.

*****************************************************************************/
PROCEDURE Update_Config_Line(
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER )
IS

  l_config_item       NUMBER;
  l_stmt_num 	        NUMBER;


BEGIN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'Entering Update_Config_Line', 5);
   END IF;

   l_stmt_num := 5;

   select 1
   into   l_config_item
   from oe_order_lines_all
   where line_id = oe_line_security.g_record.line_id
   and   item_type_code = 'CONFIG';

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'This is a config item. Check if update is user or system', 5);
   END IF;

   IF (oe_config_util.cascade_changes_flag = 'Y'
	OR oe_order_sch_util.oesch_perform_scheduling = 'N') THEN

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'Cascading or scheduling change, allow update', 5);
	END IF;
	x_result := 0;
	return;
   ELSE
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'User change, update not allowed', 5);
	END IF;
   	x_result := 1; /* the condition is true */
   END IF;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created: ' || 'Exiting Update_Config_Line', 5);
   END IF;

EXCEPTION

 when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'CTO_WORKFLOW_API_PK.Update_Config_Line::stmt number '||to_char(l_stmt_num)||'not config item',1);
	END IF;
    	x_result := 0;

  when OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created: ' || 'CTO_WORKFLOW_API_PK.Update_Config_Line::stmt number '||to_char(l_stmt_num)||'others',1);

		oe_debug_pub.add('configuration_created: ' || sqlerrm);
	END IF;
    	x_result := 0;

END Update_Config_Line;


/**************************************************************************

   Procedure:   configuration_created_for_pto
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is called from
                the security constraints to validate whether a change is
                allowed on an order line.
                This API gets called for every item type. It returns
                x_result = 0 if the item is not a PTO item or if it is a
		PTO item but does not have a configuration item
		created under it.
                Otherwise, it returns x_result = 1.

*****************************************************************************/
PROCEDURE Configuration_Created_For_Pto (
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER )
IS
  l_pto_line		NUMBER;
  l_current_model_line	NUMBER;
  l_config_exists       NUMBER;
  l_stmt_num 	        NUMBER;

  CURSOR c_config_exists IS
  select ato_line_id
  from oe_order_lines_all
  where top_model_line_id = oe_line_security.g_record.top_model_line_id
  and   item_type_code = 'CONFIG';

BEGIN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created_for_pto: ' || 'Entering configuration_created_for_pto',5);
   END IF;

   -- Check if the line is not an ATO model, option, option class, or
   -- config line

   l_stmt_num := 10;
   IF oe_line_security.g_record.ato_line_id IS NOT NULL THEN
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created_for_pto: ' || 'This is not a PTO item, constraint condition is false', 5);
	END IF;
	x_result := 0;
	return;
   END IF;

   l_stmt_num := 20;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created_for_pto: ' || 'This is a PTO item', 5);
   END IF;
   l_pto_line := oe_line_security.g_record.line_id;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created_for_pto: ' || 'l_pto_line = '||to_char(l_pto_line), 5);
   END IF;

   l_stmt_num := 30;
   select 1
   into l_config_exists
   from oe_order_lines_all
   where top_model_line_id = oe_line_security.g_record.top_model_line_id
   and   item_type_code = 'CONFIG'
   and rownum = 1;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created_for_pto: ' || 'Config item exists somewhere in this configuration', 5);
   END IF;

   --
   -- For each config item, traverse the BOM starting from the ATO model
   -- till the top PTO model. If the current item is encountered in the
   -- patch traversed, constraint condition should be TRUE, else FALSE
   --
   FOR v_config_exists in c_config_exists LOOP
	l_stmt_num := 40;
	l_current_model_line := v_config_exists.ato_line_id;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created_for_pto: ' || 'ATO model being processed : '||to_char(l_current_model_line), 2);
	END IF;

	WHILE TRUE LOOP

		BEGIN

		l_stmt_num := 50;
		select link_to_line_id
		into l_current_model_line
		from oe_order_lines_all
		where line_id = l_current_model_line;

		IF l_current_model_line = l_pto_line THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('configuration_created_for_pto: ' || 'Config item exists under this PTO, constraint condition is true', 5);
			END IF;
			x_result := 1;
			return;
		END IF;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_stmt_num := 60;
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('configuration_created_for_pto: ' || 'No data found::top model', 5);
			END IF;
			exit; /* break from loop */

		END;

	END LOOP;
   END LOOP; /*cursor loop*/

   x_result := 0; /* the condition is false */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('configuration_created_for_pto: ' || 'Exiting configuration_created_for_pto',5);
   END IF;

EXCEPTION

 when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created_for_pto: ' || 'CTO_WORKFLOW_API_PK.configuration_created_for_pto::stmt number '||to_char(l_stmt_num),1);
		oe_debug_pub.add('configuration_created_for_pto: ' || 'config item does not exist, constraint condition is false', 1);
	END IF;
    	x_result := 0;

  when OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('configuration_created_for_pto: ' || 'CTO_WORKFLOW_API_PK.configuration_created_for_pto::stmt number '||to_char(l_stmt_num), 1);
		oe_debug_pub.add('configuration_created_for_pto: ' || 'constraint condition is false', 1);
		oe_debug_pub.add('configuration_created_for_pto: ' || sqlerrm, 1);
	END IF;
    	x_result := 0;

END Configuration_Created_For_Pto;


/**************************************************************************

   Procedure:   Top_Ato_Model
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is called from
                the security constraints to validate whether a change is
                allowed on an order line.
                This API gets called for every item type. It returns
                x_result = 1 if the item is a top level ATO Model.
                Otherwise, it returns x_result = 0.

*****************************************************************************/
PROCEDURE Top_Ato_Model(
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER )
IS

  l_top_ato_model       NUMBER;
  l_stmt_num 	        NUMBER;


BEGIN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Top_Ato_Model: ' || 'Entering top_ato_model', 5);
   END IF;

   l_stmt_num := 5;

   select 1
   into   l_top_ato_model
   from oe_order_lines_all
   where line_id = oe_line_security.g_record.line_id
   and   ato_line_id = line_id;

   x_result := 1; /* the condition is true */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Top_Ato_Model: ' || 'Exiting top_ato_model', 5);
   END IF;

EXCEPTION

 when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Top_Ato_Model: ' || 'CTO_WORKFLOW_API_PK.top_ato_model::stmt number '||to_char(l_stmt_num)||'not top ato model',1);
	END IF;
    	x_result := 0;

  when OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Top_Ato_Model: ' || 'CTO_WORKFLOW_API_PK.top_ato_model::stmt number '||to_char(l_stmt_num)||'others',1);

		oe_debug_pub.add('Top_Ato_Model: ' || sqlerrm);
	END IF;
    	x_result := 0;

END Top_Ato_Model;


/**************************************************************************

   Procedure:   Config_Line
   Parameters:  p_application_id              (standard signature format)
                p_entity_short_name
                p_validation_entity_short_name
                p_validation_tmplt_short_name
                p_record_set_short_name
                p_scope
                x_result
   Description: This API with standard signature format is called from
                the security constraints to validate whether a change is
                allowed on an order line.
                This API gets called for every item type. It returns
                x_result = 0 if the item is a config item and the line is
		being updated by a system action (like scheduling or
		cascading).
                Otherwise, it returns x_result = 1.

*****************************************************************************/
PROCEDURE Config_Line(
	p_application_id	IN	NUMBER,
	p_entity_short_name	IN	VARCHAR2,
	p_validation_entity_short_name	IN	VARCHAR2,
	p_validation_tmplt_short_name	IN	VARCHAR2,
	p_record_set_short_name	IN VARCHAR2,
	p_scope			IN VARCHAR2,
	x_result		OUT NOCOPY NUMBER )
IS

  l_config_item       NUMBER;
  l_stmt_num 	        NUMBER;


BEGIN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Config_Line: ' || 'Entering Config_Line', 5);
   END IF;

   l_stmt_num := 5;

   select 1
   into   l_config_item
   from oe_order_lines_all
   where line_id = oe_line_security.g_record.line_id
   and   item_type_code = 'CONFIG';

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Config_Line: ' || 'This is a config item.', 5);
   END IF;
   x_result := 1; /* the condition is true */
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Config_Line: ' || 'Exiting Config_Line', 5);
   END IF;

EXCEPTION

 when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Config_Line: ' || 'CTO_WORKFLOW_API_PK.Config_Line::stmt number '||to_char(l_stmt_num)||'not config item',1);
	END IF;
    	x_result := 0;

  when OTHERS then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Config_Line: ' || 'CTO_WORKFLOW_API_PK.Config_Line::stmt number '||to_char(l_stmt_num)||'others',1);
		oe_debug_pub.add('Config_Line: ' || sqlerrm, 1);
	END IF;
    	x_result := 0;

END Config_Line;


/**************************************************************************
   Procedure:   CHANGE_STATUS_BATCH
   Parameters:      p_header_id     --> is the header ID for the line
                    p_line_id       --> is the line ID for the line
                    p_change_status --> New status of the line
                    p_oe_org_id     --> is the ORganization ID for the line
                    x_return_status --> is the return status for the procedure.
   Description: This API updates the line status to the in parameter (p_change_status)
                based on the line_id provided(p_line_id).
*****************************************************************************/
PROCEDURE change_status_batch (
    p_header_id             NUMBER,
    p_line_id               NUMBER,
    p_change_status         VARCHAR2,
    p_oe_org_id             NUMBER,
    x_return_status OUT NOCOPY    VARCHAR2) is

    -- local parameters
    l_message        VARCHAR2(100);
    l_stmt_num       NUMBER;
    lFlowStatusCode  oe_order_lines_all.flow_status_code%type;		--bugfix 2825486
    l_current_mode    varchar2(100);
    l_current_org     Number;
    L_CHANGE_CONTEXT_BACK  Varchar2(100);
    l_cancelled_flag  varchar2(1);  --Bugfix 7292113

BEGIN

    l_stmt_num  := 10;
    l_message := 'line status is '||p_change_status||', (change_status_batch) at stmt number'||to_char(l_stmt_num);
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('Change_Status_Batch: ' || l_message, 5);
        cto_wip_workflow_api_pk.cto_debug('change_status_batch', l_message);

    END IF;
    -- bugfix 2825486: added select to get the current flow_status_code.
    l_stmt_num  := 20;
    select nvl(flow_status_code,'N'), cancelled_flag   --Bugfix 7292113
    into   lFlowStatusCode, l_cancelled_flag
    from   oe_order_lines_all
    where  header_id = p_header_id
    and    line_id = p_line_id;


    IF PG_DEBUG <> 0 THEN
        l_message := 'Current flow_status_code = '||lFlowStatusCode;
        oe_debug_pub.add('Change_Status_Batch: ' ||l_message,4);
	oe_debug_pub.add('Cancelled_flag: ' ||l_cancelled_flag,4);
	cto_wip_workflow_api_pk.cto_debug('change_status_batch', l_message);
    END IF;

    -- bugfix 2825486: Added IF. Only when flow_status is different, we'll call OM api to update the
    --                 flow_status_code.

    l_stmt_num  := 30;
    if lFlowStatusCode <> p_change_status and nvl(l_cancelled_flag, 'N') <> 'Y' then
    -- Added the cancelled_flag condition as part of Bugfix 7292113

  	-- bugfix 2825486: added dbg stmt
        IF PG_DEBUG <> 0 THEN
	   l_message := 'calling OE_ORDER_WF_UTIL.update_flow_status_code to update flow_status to '||p_change_status;
	   oe_debug_pub.add('Change_Status_Batch: ' ||l_message,5);
	   cto_wip_workflow_api_pk.cto_debug('change_status_batch', l_message);
        END IF;

        -- Fixed by Renga Kannan on 04/27/06
	-- Fixed for bug 5122923
	-- Setting the org context to order line org context before calling om API
	-- Please refer to the bug for more information.
	-- Start of bug fxi 5122923
	CTO_MSUTIL_PUb.Switch_to_oe_context(
	                                    p_oe_org_id           => p_oe_org_id,
					    x_current_mode        => l_current_mode,
					    x_current_org         => l_current_org,
					    x_context_switch_flag => l_change_context_back);


        -- End of Bugfix 5122923

        l_stmt_num  := 40;
    	OE_ORDER_WF_UTIL.update_flow_status_code(
				p_header_id		=> p_header_id,
				p_line_id		=> p_line_id,
				p_flow_status_code	=> p_change_status,
				x_return_status		=> x_return_status);

    	if x_return_status = FND_API.G_RET_STS_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_SUCCESS; -- 5151111
 	   IF PG_DEBUG <> 0 THEN
	        l_message:=  'Error occurred in updating line status to '||p_change_status||' - Stmt_num'||to_char(l_stmt_num);
    		oe_debug_pub.add('Change_Status_Batch: ' ||l_message,1);
	        cto_wip_workflow_api_pk.cto_debug('change_status_batch', l_message);

		--bug#4700053
		l_message:= 'Progressing ahead even though line status may be wrong';
		oe_debug_pub.add('Change_Status_Batch: ' ||l_message,1);
	        cto_wip_workflow_api_pk.cto_debug('change_status_batch', l_message);

	   END IF;
           --raise FND_API.G_EXC_ERROR;

    	elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_SUCCESS; --5151111
	   IF PG_DEBUG <> 0 THEN
                l_message:= 'UnExp Error occurred in updating line status to '||p_change_status||' - Stmt_num'||to_char(l_stmt_num);
    		oe_debug_pub.add('Change_Status_Batch: ' ||l_message,1);
	        cto_wip_workflow_api_pk.cto_debug('change_status_batch', l_message);

                --bug#4700053
		l_message:= 'Progressing ahead even though line status may be wrong';
		oe_debug_pub.add('Change_Status_Batch: ' ||l_message,1);
	        cto_wip_workflow_api_pk.cto_debug('change_status_batch', l_message);
	   END IF;
           --raise FND_API.G_EXC_UNEXPECTED_ERROR;

    	end if;
	  IF PG_DEBUG <> 0 Then
             oe_debug_pub.add('Complete_activity : l_change_context_back = '||l_change_context_back,5);
          End if;
	  End if;
	-- Start of bug fxi 5122923

  If l_change_context_back = 'Y' Then
     CTO_MSUTIL_PUB.Switch_context_back(p_old_mode => l_current_mode,
                                        p_old_org  => l_current_org);
  End if;

    l_message := 'after updating line status to '||p_change_status||', (change_status_batch) at stmt number'||to_char(l_stmt_num);
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('Change_Status_Batch: ' || l_message, 5);
    cto_wip_workflow_api_pk.cto_debug('DISPLAY_WF_STATUS', l_message);

    END IF;
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Change_Status_Batch: ' || 'exp error in CTO_WORKFLOW_API_PK.change_status_batch::'||l_stmt_num, 1);
      cto_wip_workflow_api_pk.cto_debug('CHANGE_STATUS_BATCH','exp erro change_status_batch :: '||l_stmt_num||sqlerrm);

      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Change_Status_Batch: ' || 'unexp error in CTO_WORKFLOW_API_PK.change_status_batch::'||l_stmt_num, 1);
      cto_wip_workflow_api_pk.cto_debug('CHANGE_STATUS_BATCH','Unexp err change_status_batch :: '||l_stmt_num||sqlerrm);
      End if;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Change_Status_Batch: ' || 'unexp error (others) in CTO_WORKFLOW_API_PK.change_status_batch::'||l_stmt_num, 1);
      	oe_debug_pub.add('Change_Status_Batch: ' || sqlerrm, 1);
      cto_wip_workflow_api_pk.cto_debug('CHANGE_STATUS_BATCH','Unexp err change_status_batch :: '||l_stmt_num||sqlerrm);

      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;



/**************************************************************************
   Procedure:  auto_create_pur_req
   Parameters: p_itemtype   -->internal name for item type
            p_itemkey       -->sales order line id
            p_actid         -->ID number of WF activity
            p_funcmode      -->execution mode of WF act
            x_result        -->result of activity
   Description: This Procedure will be called from the WorkFlow and will create
            records in the interface table for the eligible line in the
            Order management tables
*****************************************************************************/

PROCEDURE auto_create_pur_req(
            p_itemtype        IN      VARCHAR2, /* internal name for item type */
            p_itemkey         IN      VARCHAR2, /* sales order line id  */
            p_actid           IN      NUMBER,   /* ID number of WF activity  */
            p_funcmode        IN      VARCHAR2, /* execution mode of WF act  */
            x_result          OUT NOCOPY    VARCHAR2   /* result of activity */
            ) IS

    errbuf                    VARCHAR2(100);
    retcode                   VARCHAR2(100);
    p_sales_order             NUMBER;
    p_organization_id         VARCHAR2(100);
    p_offset_days             NUMBER;
    x_return_status           VARCHAR2(100);
    l_stmt_num                NUMBER;
    p_new_order_quantity      oe_order_lines_all.ordered_quantity%TYPE;
    v_x_error_msg_count       NUMBER;
    v_x_hold_result_out       VARCHAR2(1);
    v_x_hold_return_status    VARCHAR2(1);
    v_x_error_msg             VARCHAR2(150);
    so_line                   oe_order_lines_all%ROWTYPE;
    p_program_id              NUMBER;
    l_res                     BOOLEAN;
    p_order_number            VARCHAR2(100);

    l_source_document_type_id NUMBER;

    -- Bugfix 3077912: New variables
    l_need_by_date	DATE;
    -- End bugfix 3077912

    -- rkaza. ireq project.
    l_sourcing_rule_exists VARCHAR2(1);
    l_req_input_data       CTO_AUTO_PROCURE_PK.req_interface_input_data;
    l_transit_lead_time    NUMBER;
    l_exp_error_code       NUMBER;


    l_rets                    NUMBER; --bugfix 	4545070

BEGIN

  savepoint  before_process;

  OE_STANDARD_WF.Set_Msg_Context(p_actid);
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('auto_create_pur_req: ' || 'CTO WF Activity: auto_create_pur_req', 1);
  END IF;

  if (p_funcmode = 'RUN') then

      l_stmt_num := 1;

      --
      -- check if the line has/is beeing processed by the Concurrent Request.
      --
      select  concurrent_program_id
      into    p_program_id
      from    fnd_concurrent_programs a
      where   concurrent_program_name = 'CTOACREQ'
      and     application_id          = 702; --BOM , bugfix 2885568 for
                                             --full table scan


      l_stmt_num := 10;

      --
      -- Select all the records from the SO lines table for the line id passed in the procedure.
      -- this cursor will fetch only one record from the table as the  parameter passed in is the primary key.
      --
      SELECT  *
      INTO    so_line
      FROM    oe_order_lines_all
      WHERE   line_id = to_number(p_itemkey);

      SELECT  order_number
      INTO    p_order_number
      FROM    oe_order_lines_all a, oe_order_headers_all b
      WHERE   a.header_id = b.header_id
      AND     a.line_id = to_number(p_itemkey);

      -- get the line source document type ID
      l_source_document_type_id := cto_utility_pk.get_source_document_id ( pLineId => p_itemkey );

      IF so_line.program_id = p_program_id THEN

            -- log message that the line has been processed by the concurrent_program
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('auto_create_pur_req: ' || 'This line has already been selected to be processed by the concurrent request :'||to_char(so_line.request_id),1);
            END IF;

      ELSE

          l_stmt_num := 20;
	  -- Removed check hold API call from here as we are going to check for
	  -- hold in check_supply_type_wf workflow activity, which is just before this workflow
	  -- node
	  -- Removed as part of bug fix 5261330


          l_stmt_num := 21;
          -- check the quantity to be ordered.
          -- Fix for performance bug 4897231
          -- get_new_order_qty signature is changed
          -- to add a new P_item_id parameter
          -- Passing the new parameter


          begin
             p_new_order_quantity := CTO_AUTO_PROCURE_PK.get_new_order_qty (
                                  		p_interface_source_line_id	=> so_line.line_id,
                                  		p_order_qty		 	        => so_line.ordered_quantity,
                                  		p_cancelled_qty			    => nvl(so_line.cancelled_quantity, 0),
						                p_item_id                   => so_line.inventory_item_id);

             IF nvl(p_new_order_quantity, 0) = 0 THEN
              	IF PG_DEBUG <> 0 THEN
              		oe_debug_pub.add('auto_create_pur_req: ' || 'ERROR GET_NEW_ORDER_QTY:: The new order quantity is zero', 1);
              	END IF;
              	raise FND_API.G_EXC_ERROR;
             END IF;
          end;

	  -- rkaza. 05/02/2005. ireq project
          -- call query sourcing org to get src type and distinguish internal
          -- external req cases.
          l_stmt_num := 22;
          CTO_UTILITY_PK.query_sourcing_org(
                        p_inventory_item_id	=> so_line.inventory_item_id,
                        p_organization_id	=> so_line.ship_from_org_id,
                        p_sourcing_rule_exists	=> l_sourcing_rule_exists,
                        p_sourcing_org	=> l_req_input_data.sourcing_org,
                        p_source_type	=> l_req_input_data.source_type ,
                        p_transit_lead_time	=> l_transit_lead_time,
                        x_return_status		=> x_return_status,
                        x_exp_error_code	=> l_exp_error_code );

      	  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req: ' || 'success from query sourcing org', 5);
              oe_debug_pub.add('auto_create_pur_req: ' || 'source_type = ' || l_req_input_data.source_type, 5);
              oe_debug_pub.add('auto_create_pur_req: ' || 'sourcing_org = ' || l_req_input_data.sourcing_org, 5);
	    END IF;
     	  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req: ' || 'unexpected error query sourcing org', 5);
            END IF;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
     	  END IF;

	  l_stmt_num := 26;

          cto_auto_procure_pk.get_need_by_date(
			   p_source_type => l_req_input_data.source_type,
                           p_item_id => so_line.inventory_item_id,
                           p_org_id => so_line.ship_from_org_id,
                           p_schedule_ship_date => so_line.schedule_ship_date,
                           x_need_by_date => l_need_by_date,
                           x_return_status => x_return_status);

      	  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req: ' || 'success from get_need_by_date' || ' l_need_by_date=' || l_need_by_date, 5);
	    END IF;
     	  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req: ' || 'unexpected error in get_need_by_date', 5);
            END IF;
            raise fnd_api.g_exc_unexpected_error;
     	  END IF;

	  l_stmt_num := 25;
	  --pthese attributes are for orders taken in OPM organizations
	  --and for buy and internal req orders in other type of organizations
          l_req_input_data.secondary_qty :=  so_line.ORDERED_QUANTITY2;
	  l_req_input_data.secondary_uom :=  so_line.ORDERED_QUANTITY_UOM2;
	  l_req_input_data.grade         :=  so_line.PREFERRED_GRADE;

          l_stmt_num := 30;

          -- Insert record into the interface table.
          Begin

              -- Call the populate_req_interface.
              -- rkaza. Pass l_req_input_data also.

              CTO_AUTO_PROCURE_PK.populate_req_interface ( 'CTO',  -- pass CTO as a parameter , chaged for ML SUPPLY feature by kkonada
                     p_destination_org_id	=> so_line.ship_from_org_id,
                     p_org_id			=> so_line.org_id,
                     p_created_by		=> so_line.created_by,
                     p_need_by_date		=> l_need_by_date, 	-- 3077912 so_line.schedule_ship_date
                     p_order_quantity		=> p_new_order_quantity,
                     p_order_uom		=> so_line.order_quantity_uom,
                     p_item_id			=> so_line.inventory_item_id,
                     p_item_revision		=> so_line.item_revision,
                     p_interface_source_line_id	=> so_line.line_id,
                     p_unit_price		=> null, 	-- so_line.unit_selling_price,
                     p_batch_id			=> 1000,   	--l_batch_id
                     p_order_number		=> p_order_number,
		     p_req_interface_input_data => l_req_input_data,
		     x_return_status		=> x_return_status );

                   -- Log the error based on the x_return_status.
                   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                       RAISE FND_API.G_EXC_ERROR;

                   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                   ELSE
                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('auto_create_pur_req: ' || 'Insert successful.',5);
                       END IF;

		       l_stmt_num := 40;    --bugfix4545070
	               l_rets := display_wf_status( p_order_line_id=>so_line.line_id);


                       IF l_rets = 0 THEN
                              IF PG_DEBUG <> 0 THEN
                              	oe_debug_pub.add('auto_create_pur_req: ' || 'UNExp Error occurred in call to display_wf_status at - Stmt_num'||to_char(l_stmt_num),1);
                              END IF;
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       ELSE
                              IF PG_DEBUG <> 0 THEN
                              	oe_debug_pub.add('auto_create_pur_req: ' ||  'Order updated to REQ_REQUESTED.', 5);
                              END IF;
                       END IF;

                   END IF;  	-- end of returnstatus check

          End; -- Insert record into the interface table.

      END IF; -- check if the record is already being processed by the concurrent request.

  end if; -- end of p_funcmode check

  OE_STANDARD_WF.Save_Messages;
  OE_STANDARD_WF.Clear_Msg_Context;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('auto_create_pur_req: ' || 'AUTO_CREATE_PUR_REQ::exp error::'||to_char(l_stmt_num),1);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            wf_core.context('CTO_WORKFLOW', 'auto_create_pur_req, stmt_num :'||to_char(l_stmt_num),p_itemtype, p_itemkey, to_char(p_actid),p_funcmode, 1);
	    x_result := 'CTO_INCOMPLETE';
	    rollback to before_process;
	    return;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('auto_create_pur_req: ' || 'AUTO_CREATE_PUR_REQ::unexp error::'||to_char(l_stmt_num),1);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            wf_core.context('CTO_WORKFLOW', 'auto_create_pur_req, stmt_num :'||to_char(l_stmt_num),
                           p_itemtype, p_itemkey, to_char(p_actid),
                           p_funcmode);
	    raise;

        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('auto_create_pur_req: ' || 'AUTO_CREATE_PUR_REQ::other error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            wf_core.context('CTO_WORKFLOW', 'auto_create_pur_req, stmt_num :'||to_char(l_stmt_num),
                           p_itemtype, p_itemkey, to_char(p_actid),
                           p_funcmode);
            raise;
END auto_create_pur_req;




PROCEDURE chk_Buy_Ato_Item(
        p_application_id        IN      NUMBER,
        p_entity_short_name     IN      VARCHAR2,
        p_validation_entity_short_name  IN      VARCHAR2,
        p_validation_tmplt_short_name   IN      VARCHAR2,
        p_record_set_short_name IN VARCHAR2,
        p_scope                 IN VARCHAR2,
        x_result                OUT NOCOPY NUMBER )
IS

  l_stmt_num             NUMBER;
  l_inv_item_id          Number;
  l_ship_org             Number;
  v_activity_status_code Varchar2(100);
  v_sourcing_rule_exists Varchar2(100);
  v_source_type          Number;
  v_sourcing_org         Number;
  v_transit_lead_time    Number;
  v_exp_error_code       Number;
  x_return_status        Varchar2(1);
  l_item_type_code       Varchar2(100);
  l_ato_line_id          Number;

BEGIN
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('chk_Buy_Ato_Item: ' || 'Entering Chk_buy_ato_item', 5);
   END IF;

   l_stmt_num := 5;

   SELECT item_type_code,
          ato_line_id,
          inventory_item_id,
          ship_from_org_id
   INTO   l_item_type_code,
          l_ato_line_id,
          l_inv_item_id,
          l_ship_org
   FROM   OE_ORDER_LINES_ALL
   WHERE  line_id = oe_line_security.g_record.line_id;


   --Adding INCLUDED item type code for SUN ER#9793792
   --IF l_item_type_code in ('STANDARD','OPTION') AND
   IF l_item_type_code in ('STANDARD','OPTION','INCLUDED') AND
      l_ato_line_id = oe_line_security.g_record.line_id THEN

          CTO_UTILITY_PK.query_sourcing_org(
                p_inventory_item_id	=> l_inv_item_id,
                p_organization_id	=> l_ship_org,
                p_sourcing_rule_exists	=> v_sourcing_rule_exists,
                p_source_type		=> v_source_type,
                p_sourcing_org		=> v_sourcing_org,
                p_transit_lead_time	=> v_transit_lead_time,
		x_exp_error_code	=> v_exp_error_code,
                x_return_status		=> x_return_status
                );

         IF nvl(v_source_type,2) = 3 THEN
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('chk_Buy_Ato_Item: ' || 'It is an buy ato item...',5);
          END IF;
           x_result := 1; /* This is correct condition */
         ELSE
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('chk_Buy_Ato_Item: ' || 'It is  a make ato item',5);
           END IF;
           x_result := 0;
         END IF;

   ELSE
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('chk_Buy_Ato_Item: ' || 'Not an ato item...',5);
      END IF;
      x_result := 0;
   END IF;

EXCEPTION

 when no_data_found then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('chk_Buy_Ato_Item: ' || 'CTO_WORKFLOW_API_PK.Config_Line::stmt number '||to_char(l_stmt_num)||'not config item',1);
        END IF;
        x_result := 0;

  when OTHERS then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('chk_Buy_Ato_Item: ' || 'CTO_WORKFLOW_API_PK.Config_Line::stmt number '||to_char(l_stmt_num)||'others',1);

        	oe_debug_pub.add('chk_Buy_Ato_Item: ' || sqlerrm);
        END IF;
        x_result := 0;

END chk_Buy_Ato_Item;





PROCEDURE Reservation_Exists(
        p_application_id        IN      NUMBER,
        p_entity_short_name     IN      VARCHAR2,
        p_validation_entity_short_name  IN      VARCHAR2,
        p_validation_tmplt_short_name   IN      VARCHAR2,
        p_record_set_short_name IN VARCHAR2,
        p_scope                 IN VARCHAR2,
        x_result                OUT NOCOPY NUMBER
        )
is

v_aps_version      number ;
l_ato_line_id      number ;
l_header_id        number ;
l_config_line_id   number ;



v_rsv_rec                 CTO_UTILITY_PK.resv_tbl_rec_type;
v_resv_code               varchar2(200) ;
v_sum_rxv_qty             number ;
v_return_status           varchar2(200) ;
v_msg_count               number ;
v_msg_data                varchar2(200) ;
l_stmt_num                number ;


l_config_orgs        mtl_system_items.config_orgs%type ;
l_cfg_item_id      mtl_system_items.inventory_item_id%type ;
x_primary_uom_code   varchar2(3);


begin

         l_stmt_num := 1;

        v_aps_version := msc_atp_global.get_aps_version  ;

        if( v_aps_version <> 10) then
                oe_debug_pub.add('reservation_exists: ' || 'APS version::'|| v_aps_version , 2);

                x_result := 1 ;

                return ;

        end if;


 IF PG_DEBUG <> 0 THEN
    oe_debug_pub.add( 'ACTION CODE: ' || oe_line_security.g_record.split_action_code , 1 ) ;
    oe_debug_pub.add( 'OPERATION: ' || oe_line_security.g_record.operation , 1 ) ;
    oe_debug_pub.add( 'ATTRIBUTE 1: ' || oe_line_security.g_record.attribute1 , 1 ) ;
    oe_debug_pub.add( 'SPLIT FROM LINE ID: ' || oe_line_security.g_record.split_from_line_id , 1 ) ;
    oe_debug_pub.add( ' LINE ID: ' || oe_line_security.g_record.line_id , 1 ) ;
 END IF;
         l_stmt_num := 5;
        select ato_line_id, header_id , inventory_item_id
         into   l_ato_line_id, l_header_id , l_cfg_item_id
          from   oe_order_lines_all
         where  line_id = oe_line_security.g_record.line_id
           and    item_type_code <> 'STANDARD'
           and    ato_line_id is not null;


         -- check if the config item is created
         -- adding join to header_id for performance
         l_stmt_num := 10;

         select line_id
           into l_config_line_id
           from oe_order_lines_all
          where header_id = l_header_id
          and   ato_line_id = l_ato_line_id
          and   item_type_code = 'CONFIG';




         if( oe_line_security.g_record.split_action_code = 'SPLIT' ) then  /* bug 3424802 */
           IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add( 'no need to check for CIB attribute for split scenario ' , 1) ;
           END IF;
         else
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add( 'need to check for CIB attribute as update warehouse is enabled only for CIB = 3 ' , 1) ;
	    END IF;
             -- R12 fp bug 4380768
             -- Modified by Renga on 06/06/05
             -- Added nvl clause for config_orgs
             -- null value for config_orgs should be treated as 1

             --r12 bugfix 4666778, changed query to look at models CIB attribute

	     --5051814 changed the query which looks at models CIB attribute
	     --this query catches the CIB contsraint when OM calls for model line
	     --instead of waiting for a call for config line
	     select nvl(msi.config_orgs,1)
	     into   l_config_orgs
	     from   oe_order_lines_all oel,
	            mtl_system_items msi
	     where  oel.line_id = l_ato_line_id
	     and    msi.inventory_item_id = oel.inventory_item_id
	     and    msi.organization_id  = oel.ship_from_org_id;


             if( l_config_orgs <> '3') then

               IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('reservation_exists: ' || 'l_config_orgs <> 3 ::'|| l_config_orgs , 2);
                 oe_debug_pub.add('reservation_exists: ' || 'l_config_orgs <> Based on Model ::'|| l_config_orgs , 2);
                 oe_debug_pub.add('reservation_exists: ' || 'l_cfg_item_id ::'|| to_char(l_cfg_item_id) , 2);
               END IF;
                 x_result := 1 ;

                 return ;

             end if ;


         end if ;  /* check CIB attribute for warehouse update */


         l_stmt_num := 30;

         CTO_UTILITY_PK.Get_Resv_Qty
               (
                 p_order_line_id               => l_config_line_id ,
                 x_rsv_rec                     => v_rsv_rec,
		 x_primary_uom_code            => x_primary_uom_code,
                 x_sum_rsv_qty                 => v_sum_rxv_qty ,
                 x_return_status               => v_return_status,
                 x_msg_count                   => v_msg_count ,
                 x_msg_data                    => v_msg_data
                ) ;

         l_stmt_num := 40;

         if( v_rsv_rec.count > 0 ) then


             x_result := 1 ;

         else

             x_result := 0 ;

         end if;


exception
 when no_data_found then
                 x_result := 0 ;
              IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('CTO_WORKFLOW_API_PK: ' || 'reservation exists::'|| ' NO DATA FOUND EXCEPTION ' || l_stmt_num , 2);
              END IF;
 when others then

                x_result := 0 ;
               IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('CTO_WORKFLOW_API_PK: ' || 'reservation exists::'|| ' OTHERS EXCEPTION ' || l_stmt_num , 2);
	       END IF;

end reservation_exists ;


--- Added for Cross docking project
/*******************************************************************************************
-- API name : get_status_tokens
-- Type     : Private
-- Pre-reqs : CTOUTILS.pls, CTOUTILB.pls
-- Function : Given config/ato item Order line id, item id, ship from org and ordered qty
              it returns Flow status code in two tokens. The calling module can combine these
	      two tokens with '-' to get the corresponding flow status code.
-- Parameters:

-- IN       : p_order_line_id     Expects the config/ato item order line       Required
--            p_config_item_id    Expects the config/ato item id               Required
--            p_ship_from_org_id  Expects the ship from org of the order line  Required
--            p_ordered_quantity  Expects the order lines ordered quantity     Required

-- OUT      : x_token1           The first part of flow status code.
	      x_token2           The second part of flow status code.
	      x_return_status     Standard error message status
	      x_msg_count         Std. error message count in the message stack
	      x_msg_data          Std. error message data in the message stack
-- Version  :
--
--
******************************************************************************************/
Procedure  get_status_tokens(
                           p_order_line_id		Number,
			   p_config_item_id		Number,
			   p_ship_from_org_id		Number,
			   p_ordered_quantity		Number,
			   x_token1         OUT NOCOPY  Varchar2,
			   x_token2         OUT NOCOPY  varchar2,
			   x_return_status  OUT NOCOPY  varchar2,
			   x_msg_data       OUT NOCOPY  Varchar2,
			   x_msg_count      OUT NOCOPY  Number) is

l_stmt_num			Number;
l_rsv_rec		        CTO_UTILITY_PK.resv_tbl_rec_type;
x_primary_uom_code		MTL_SYSTEM_ITEMS.primary_uom_code%type;
l_sum_rsv_qty			NUMBER;
l_can_create_supply		varchar2(1);
--l_source_type			VARCHAR2(5); -- bug 4552271. rkaza. 08/15/05.
l_source_type			number;  --Bug 6470516
l_sourcing_org			number;
l_return_msg			varchar2(100);
L_INV_SRC_ID		        NUMBER;
L_WIP_SRC_ID			NUMBER;
L_PO_SRC_ID			NUMBER;
L_REQ_SRC_ID			NUMBER;
l_int_req_src_id		number;
l_ext_req_src_id		number;
l_asn_src_id			number;
l_rcv_src_id			number;
l_flm_src_id			number;
l_int_req_if_src_id		number;
l_ext_req_if_src_id		number;
k				number;
   --spec changed to include these new variables for OPM
l_hetro				Number;

l_onhand_fg			Varchar2(1);
l_make_flag			varchar2(1);
l_buy_fg			varchar2(1);
l_xfer_fg			varchar2(1);
l_return_status                 Varchar2(1);
l_msg_data                      Varchar2(1000);
l_msg_count                     Number;



Begin

     --call API to get_reservation_code
     l_stmt_num := 10;
     CTO_UTILITY_PK.Get_Resv_Qty
               (
		 p_order_line_id            => p_order_line_id,
		 x_rsv_rec                  => l_rsv_rec,
		 x_primary_uom_code         => x_primary_uom_code,
		 x_sum_rsv_qty		    => l_sum_rsv_qty,
                 x_return_status   	    => l_return_status,
		 x_msg_count	  	    => l_msg_count,
                 x_msg_data	            => l_msg_data
	        );

     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          IF PG_DEBUG <> 0 THEN
	         oe_debug_pub.add('get_status_tokens: '||'SUCCESS after Get_Resv_Qty',1);
		 oe_debug_pub.add('get_status_tokens: '||'Sum of resv qty=>'||l_sum_rsv_qty,1);
                 oe_debug_pub.add('get_status_tokens: '||'resv record count=>'||l_rsv_rec.count,1);

          END IF;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	   IF PG_DEBUG <> 0 THEN
		   oe_debug_pub.add('get_status_tokens: '||'status after after Get_Resv_Qty_and_Code=>'
		                         || FND_API.G_RET_STS_ERROR,1);
	   END IF;
           RAISE fnd_api.g_exc_error;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN

           IF PG_DEBUG <> 0 THEN
	           oe_debug_pub.add('status after after Get_Resv_Qty_and_Code=>'
		                         || FND_API.G_RET_STS_UNEXP_ERROR,1 );

	   END IF;
           RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     -- If there is no supply tied to this line
     -- Then the status should be as follows.
     l_stmt_num :=20;
     If l_rsv_rec.count = 0 then

        l_stmt_num :=30;
        CTO_UTILITY_PK.check_cto_can_create_supply
			(
			P_config_item_id    =>	p_config_item_id,
			P_org_id 	    =>	p_ship_from_org_id,
			x_can_create_supply =>  l_can_create_supply,
			p_source_type       =>  l_source_type,
			x_return_status     =>  l_return_status,
			X_msg_count	    =>	l_msg_count,
			X_msg_data          =>	l_msg_data,
			x_sourcing_org      =>  l_sourcing_org,
	                x_message           =>  l_return_msg
			);
        IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
	   RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

        IF l_can_create_supply = 'N' THEN
	    x_token1 := 'AWAITING';
	    x_token2 := 'SUPPLY';
	ELSE
	    x_token1 := 'SUPPLY';
	    x_token2 := 'ELIGIBLE';
	End if;
     Else
        l_stmt_num := 40;
        l_inv_src_id := inv_reservation_global.g_source_type_inv;
        l_wip_src_id := inv_reservation_global.g_source_type_wip;
        l_po_src_id  := inv_reservation_global.g_source_type_po;
        l_req_src_id := inv_reservation_global.g_source_type_req;
        --cross_dock
	l_ext_req_src_id := inv_reservation_global.g_source_type_req;--bugfix 4652873
        l_int_req_src_id := inv_reservation_global.g_source_type_internal_req;
        l_asn_src_id     := inv_reservation_global.g_source_type_asn;
        l_rcv_src_id     := inv_reservation_global.g_source_type_rcv;
        l_flm_src_id     := cto_utility_pk.g_source_type_flow;
        l_ext_req_if_src_id := cto_utility_pk.g_source_type_ext_req_if;
        l_int_req_if_src_id := cto_utility_pk.g_source_type_int_req_if;
        --end cross_dock

        IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('get_status_tokens: '||'In IF BLOCK when l_rsv_rec count is > 0 ',5);
	END IF;

	IF PG_DEBUG = 5 THEN
            oe_debug_pub.add('get_status_tokens:'||'printing rsv source type and qty in loop', 5);
            oe_debug_pub.add('get_status_tokens:'||'RSV_SRC_TYP  '||'Quantity', 5);

	     l_stmt_num := 50;
            k := l_rsv_rec.first;

            WHILE (k is not null)
	    LOOP
	      oe_debug_pub.add('get_status_tokens:'||l_rsv_rec(k).supply_source_type_id
	                        ||' => '|| l_rsv_rec(k).primary_reservation_quantity, 5);

	      k := l_rsv_rec.next(k);
            END LOOP;
        END IF; /* PG_DEBUG = 5 */


        --bugfix4637281
	--changing IF..ELSIF into multiple IF..ENDIF's
	l_stmt_num :=60;
        If l_rsv_rec.exists(l_wip_src_id) or l_rsv_rec.exists(l_flm_src_id) Then
	   l_make_flag := 'Y';
	End if;
	If l_rsv_rec.exists(l_ext_req_src_id) or
	      l_rsv_rec.exists(l_po_src_id)      or
	      l_rsv_rec.exists(l_asn_src_id)   Then
	    l_buy_fg  := 'Y';
	End if;
	If l_rsv_rec.exists(l_int_req_src_id) then
	    l_xfer_fg := 'Y';
	End if;
	If l_rsv_rec.exists(l_inv_src_id) then
	    l_onhand_fg := 'Y';
	end if; /* l_rsv_rec.exists(l_wip_src_id) or l_rsv_rec.exists(l_flm_src_id) */

        l_stmt_num :=70;
        select decode(l_make_flag,'Y',1,0)+decode(l_buy_fg,'Y',1,0)+decode(l_xfer_fg,'Y',1,0)
        into   l_hetro
        from   dual;

        l_stmt_num:=80;
     	If l_onhand_fg = 'Y' and
	   l_rsv_rec(l_inv_src_id).primary_reservation_quantity >= p_ordered_quantity Then
           x_token1 := 'AWAITING';
	elsif l_hetro > 1 or (l_make_flag = 'Y' and l_rsv_rec.exists(l_rcv_src_id)) then
           x_token1 := 'SUPPLY';
	elsif l_make_flag = 'Y' then
	   x_token1 := 'PRODUCTION';
	elsif l_buy_fg = 'Y' then
	   if l_rsv_rec.exists(l_rcv_src_id) then
	      x_token1 :='IN_RECEIVING';
	   elsif l_rsv_rec.exists(l_asn_src_id) then
	      x_token1 := 'ASN';
	   elsif l_rsv_rec.exists(l_po_src_id) then
	      x_token1 := 'PO';
	   elsif l_rsv_rec.exists(l_ext_req_src_id) then
	      x_token1 := 'EXTERNAL_REQ';
	   end if; /* l_buy_fg = 'Y' */
	elsif l_xfer_fg = 'Y' then
	   if l_rsv_rec.exists(l_rcv_src_id) then
	      x_token1 := 'IN_RECEIVING';
	   elsif l_rsv_rec.exists(l_int_req_src_id) then
	      x_token1 := 'INTERNAL_REQ';
	   end if;
           --bugfix 4739807,when rsv is only bcos of receiving
	elsif l_rsv_rec.exists(l_rcv_src_id)then
	    x_token1 :='IN_RECEIVING';
	End if; /* l_onhand_fg = 'Y' */

        l_stmt_num := 90;
        If x_token1 is null and l_onhand_fg = 'Y' and
	   l_rsv_rec(l_inv_src_id).primary_reservation_quantity < p_ordered_quantity then
           x_token1 := 'SUPPLY';
	End if; /* l_token1 is null and l_onhand_fg = 'Y' */

        l_stmt_num := 100;
	If x_token1 is null then
	   if l_rsv_rec.exists(l_ext_req_if_src_id) then
	      x_token1 := 'EXTERNAL_REQ';

               IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add('get_status_tokens: '||'x_token1=> '||x_token1,5);
	       END IF;

	   elsif l_rsv_rec.exists(l_int_req_if_src_id) then
	      x_token1 := 'INTERNAL_REQ';
	   end if;
	end if; /* l_token1 is null */


        l_stmt_num := 110;
	If l_onhand_fg = 'Y' Then
	    If l_rsv_rec(l_inv_src_id).primary_reservation_quantity >= p_ordered_quantity then
	       x_token2 := 'SHIPPING';
	    else
	       x_token2 := 'PARTIAL';
	    end if;
	elsif l_make_flag = 'Y' or l_buy_fg = 'Y' or l_xfer_fg = 'Y' then
	    If x_token1 <> 'IN_RECEIVING' then
	       x_token2 := 'OPEN';
	    End if;
	elsif l_rsv_rec.exists(l_ext_req_if_src_id) or l_rsv_rec.exists(l_int_req_if_src_id) then
	    x_token2 := 'REQUESTED';
	end if; /* l_onhand_fg = 'Y' */
    End if; /* l_rsv_rec.count = 0 */

EXCEPTION--4752854,fixed as part of code review

WHEN fnd_api.g_exc_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_status_tokens: ' || 'Exception in stmt num: '
		                    || to_char(l_stmt_num), 1);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
WHEN fnd_api.g_exc_unexpected_error THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('get_status_tokens: '|| ' Unexpected Exception in stmt num: '
		                       || to_char(l_stmt_num), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );
WHEN OTHERS then


       IF PG_DEBUG <> 0 THEN
	        oe_debug_pub.add('get_status_tokens: '||'errmsg'||sqlerrm,1);
        	oe_debug_pub.add('get_status_tokens: ' || 'Others Exception in stmt num: '
		                    || to_char(l_stmt_num), 1);
       END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --  Get message count and data
         cto_msg_pub.count_and_get
          (  p_msg_count => x_msg_count
           , p_msg_data  => x_msg_data
           );

End get_status_tokens;



END CTO_WORKFLOW_API_PK;

/
