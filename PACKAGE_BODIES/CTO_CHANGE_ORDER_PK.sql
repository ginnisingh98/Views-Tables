--------------------------------------------------------
--  DDL for Package Body CTO_CHANGE_ORDER_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CHANGE_ORDER_PK" as
/*  $Header: CTOCHODB.pls 120.13.12010000.5 2010/07/21 07:42:22 abhissri ship $ */

/******************************************************************************************
|      Copyright  (C) 1993 Oracle Corporation Belmont, California, USA                    |
|				All rights reserved.                                      |
|                               Oracle Manufacturing                                      |
|                                                                                         |
|	FILE NAME	:	CTOCHODB.pls                                              |
|                                                                                         |
|	DESCRIPTION	:	Get the Change order information from the                 |
|                               Order Managemennt and start the workflow                  |z
|                               to send notification.                                     |
|                                                                                         |
|	HISTORY    	:       Created on 10-AUG-2000 by Renga Kannan                    |
|                                                                                         |
|                               Modiflied 12/29/200 by Renga Kannan                       |
|                               Renga Kannan 02/01/01 Added code to handle ATO item case  |
|                               Renga Kannan 02/10/01 Added code to handle ML/MO case     |
|                               Renga Kannan 02/17/01 Modified the Notification text      |
|                                                     Modifed the code for ATO item       |
|                                                     Cancellation case                   |
|                                                     Modified the code to get the        |
|                                                     default admin role from workflow    |
|                                                     attribute.                          |
|                                            02/21/01 Added code for PTO-ATO config       |
|                                                     change. Please look at the          |
|                                                     bug # 1650811                       |
|                                            02/27/01 Modified the code for PTO-ATO config|
|                                                     change esp for adding new lines     |
|                                                     Since the modification is more than |
|                                                     one place I will add coments then   |
|                                                     and there. For further dtls please  |
|                                                     refer to CTO Change order design    |
|                                                     document.                           |
|                                            03/13/01 Modified the Pl/sql Record ref      |
|                                                                                         |
|                                            05/08/01 Modified by Renga Kannan            |
|                                                     in the Is_item_ML_OR_MO procedure   |
|                                                     I am calling an API                 |
|                                                     Get_model_sourcing_org. The return  |
|                                                     value from this fucntion will be    |
|                                                     FND_API.G_TRUE/FND_API.G_FALSE      |
|                                                     But I am comapring with 'Y'/'N'.    |
|                                                     This issue is fixed during patch    |
|                                                     set certification                   |
|                                                                                         |
|                                                                                         |
|                                            05/18/01 Modified by Renga Kannan            |
|                                                     Worked on the bug # 1656334         |
|                                                     In the case of cancellation the     |
|                                                     notification message was not clear  |
|                                                     Added a new attribute in work flow  |
|                                                     Which will tell the exact action    |
|                                                     like it is modified or it is        |
|                                                     cancelled.                          |
|                                                                                         |
|                                                                                         |
|                                            06/18/01 Modified by Renga Kannan            |
|                                                     The get_model_sourcing_org API      |
|                                                     call is moved from                  |
|                                                     CTO_ATP_INTERFACE_PK to             |
|                                                     CTO_UTILITY_PK to avoid having      |
|                                                     dependency with CTOATPIB.pls        |
|                                                                                         |
|                                            08/17/01 Replicated Branch fix by Sushant 	  |
|							Sawant                      	  |
|                                                     fixed BUG#1874380 to account        |
|                                                     for ato items under PTO Models.     |
|                                                                                         |
|                                                                                         |
|                                            02/08/02 Modified by Ksarkar		  |
|						      Bugfix 2219495 : Base bug 2206035   |
|                                                     Config item is not delinked after   |
|                                                     adding an option item to a ATO Model|
|                                                     within a PTO model                  |
|                                                                                         |
|                                            06/17/02 Modified by Ksarkar                 |
|                                                     Bugfix 2420484 : Base bug 2418075   |
|                                                     Exception handling in Change_Notify |
|                                                     API when array is Null              |
|                                                                                         |
|                                            12/12/2002  Kiran Konada                     |
|						      Added code for ML Supply feature in |
|						patchset-I				  |
|					        added a new attribute in wworkflow
|						made a call to get_chil_configurations,which
|						adds a dependency on CTOSUBSB.pls
|					    01/13/2002   Kiran Konada
|						added prcoedure get_ato_item_or_config_item
|						to get the item_id
|                                           01/13/2002 Kiran Konada
|						added a default value of null as sub-assembly text
|						so that no value shows up for sub-assembly attribute
|						when 'Create-lower levels upply' parameter is turned
|						off or item processed is a BUY item
|					    01/21/2003 Kiran Konada
|						bugfix 2760786
|						1)mat changed to may in code
|						2) fix in workflow from notifiction to 'Notrtification
|					    02/04/2003 Kiran Konada
|						Added a new paramter to pass conifg/ato item id
|						to start_work_flow
|						removed procedure  get_ato_item_or_config_item
|						bugfix 2782394
|
|              Modified on 14-MAR-2003 By Sushant Sawant
|                                         Decimal-Qty Support for Option Items.
|                                         Changed Signature of CHANGE_NOTIFY
|                                         Added logic for detecting config change.
|
|              Modified on 21-JUN-2004 by kkonada
|                                         bugfix 3651068
|                                         When canceling we the chnage type as qty chnage and
|                                         SSD or SAD change
|                                         as the order is unssechduled the mesg shows
|                                         SSD chnaged from 14_jun-2004 to _____
|                                         As the TO side is emplty and this info is not required
|                                         for canceled order. Put the SSD and SAD as N/A in code
|                                         for cancelled orders
|
|            Modified on 02-09-2005       Renga Kannan
|                                         FP bug fix 4103806
|
|            Modified on 02-11-2005       Renga Kannan
|                                         FP bug fix 4103604
|                                         during Warehouse change and qty change the line
|                                         status should be recomputed and the workflow
|                                         should be moved to either ship line or create config eligible
|                                         based on the new sourcing chain.
|
|            Modified on 04-08-2005       Kiran Konada
|                                         bugfix 4293763
|                                         Moved the check for config line exists ahead of query which
|					  gets details of config line
|
|
|	     Modified  06-02-2005	  Kiran Konada
|                                         Modified for OPM project
|                                         search for string OPM
|
|                                         Added NOCOPY to all Out and inout variables
|
|             06-16-2005		Kiran Konada --OPM
|                                       get sec_qty information into 						l_req_change_details to pass into
|					change_order_ato_req_item
|
|                                       check_cto_can_create_supply changed for
|                                       new parameter
|
|					change_order_ato_req_item
|					this procedure has been modified for |						updating po_reqs_iface_all table with
|					sec qty
|
|                                       START_WORKFLOW
|                                       notification message for primary and						secondary QTY and UOM
|					will be in this fashion
|					12 Ea to 10 Ea ( qty change alone)
|                                       24 Ea to 2 Dz  (qty and uom change)
|					12 Ea to 12 DZ  (UOM change alone)
|
|		                        SoftDependencies
|					ctochord.wft --> new attribute
|					Hard dependecny
|					CTOWFAPB.pls-->Get_rsv_qty_and_code
|
|       Modified on 30-Aug-2005         Renga Kannan
|                                       RA_CUSTOMERS_VIEW is obsoleted in R12
|                                       and fin team is asking us to replace
|                                       HZ_PARTIES made sql change
|
|                   10-Oct-2005		Kiran Konada
|                                       bugfix#4666504
******************************************************************************************/


-- rkaza. ireq project. 05/10/2005. This record will be populated in
-- change_notify and passed to change_order_ato_req_item.
TYPE REQ_CHANGE_INFO IS RECORD(
cancel_line_flag boolean,
unschedule_action_flag boolean,
config_change_flag boolean,
date_change_flag boolean,
qty_change_flag boolean,
qty2_change_flag boolean,--OPM
new_ssd_date date,
new_order_qty number,
new_order_qty2 number );--OPM project


 -- Declaring local Procedures

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE Pto_Ato_Config_Wrapper(
                                  Pchgtype          IN   change_table_type,
                                  x_return_status   OUT NOCOPY  varchar2,
                                  X_Msg_count       OUT NOCOPY  Number,
                                  X_Msg_data        OUT NOCOPY  Varchar2);


-- rkaza. ireq project. 05/11/2005. Introduced this procedure for processing
-- req interface records (ext and int reqs) for change management.
-- Start of comments
-- API name : change_order_ato_req_item
-- Type	    : Private
-- Pre-reqs : None.
-- Function : Given config line id, config id, org id, source type and other
--            change order details, this procedure will update the req i/f
--            with the new qty and dates.
-- Parameters:
-- IN	    : p_config_line_id IN NUMBER Required
--	      p_config_id IN Number Required
--            p_org_id IN Number Required
--            p_source_type IN Number Required
--            p_req_change_details IN req_change_info
--               contains diferent types of change order flags and other info.
-- Version  :
--	      Initial version 	115.53
-- End of comments
PROCEDURE change_order_ato_req_item (
                p_config_line_id IN  Number,
                p_config_id IN  Number,
                p_org_id IN Number,
                p_source_type IN Number,
                p_req_change_details IN req_change_info,
                x_return_status OUT NOCOPY Varchar2 );



-- rkaza. 12/21/2005. bug 4674177.
-- Local procedure called from change_notify below. Moved the code to adjust
-- workflow node from change_notify to here. This happens in certain cases
-- like warehouse change or unschedule for a buy/xfer ato line.
Procedure Adjust_workflow_node(
            p_config_line_id in number,
            p_can_create_supply in varchar2,
	    p_shipping_xfaced_flag in varchar2,
            x_return_status out nocopy varchar2) is

l_ship_activity_status      Varchar2(30);
l_cce_activity_status       Varchar2(30);
l_changed_attributes        WSH_INTERFACE.ChangedAttributeTabType;
l_return                    Boolean;
lStmtNumber	            number;

Begin

lStmtNumber := 10;
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('Adjust_workflow_node: ' || 'Values passed in are as follows: ', 5);
   oe_debug_pub.add('Adjust_workflow_node: ' || 'p_config_line_id = ' || p_config_line_id, 5);
   oe_debug_pub.add('Adjust_workflow_node: ' || 'p_can_create_supply = ' || p_can_create_supply, 5);
END IF;

CTO_WORKFLOW_API_PK.query_wf_activity_status(
   p_itemtype       => 'OEOL',
   p_itemkey         => to_char(p_config_line_id),
   p_activity_label  => 'SHIP_LINE',
   p_activity_name   => 'SHIP_LINE',
   p_activity_status => l_ship_activity_status);

lStmtNumber := 20;

CTO_WORKFLOW_API_PK.query_wf_activity_status(
   p_itemtype       => 'OEOL',
   p_itemkey         => to_char(p_config_line_id),
   p_activity_label  => 'CREATE_SUPPLY_ORDER_ELIGIBLE',
   p_activity_name   => 'CREATE_SUPPLY_ORDER_ELIGIBLE',
   p_activity_status => l_CCE_activity_status);

If PG_DEBUG <> 0 then
   oe_debug_pub.add('Adjust_workflow_node : Create Supply Order Eligible node status =' || l_cce_activity_status, 1);
   oe_debug_pub.add('Adjust_workflow_node : Ship Line node status =' || l_ship_activity_status, 1);
End if;

If p_can_create_supply = 'N' and l_CCE_activity_status = 'NOTIFIED' Then

   lStmtNumber := 30;

   -- Move the workflow to ship line
   l_return := CTO_WORKFLOW_API_PK.complete_activity(
		  p_itemtype       => 'OEOL',
		  p_itemkey        => to_char(p_config_line_id),
		  p_activity_name   => 'CREATE_SUPPLY_ORDER_ELIGIBLE',
		  p_result_code     => 'RESERVED');

elsif p_can_create_supply = 'Y' and l_ship_activity_status = 'NOTIFIED' Then

   lStmtNumber := 40;

   -- Move the workflow to Create Supply Order Eligible
   if (WSH_CODE_CONTROL.Get_Code_Release_Level > '110508' and p_shipping_xfaced_flag = 'Y') then

      l_changed_attributes(1).source_line_id  :=  p_config_line_id;
      l_changed_attributes(1).released_status := 'N';
      l_changed_attributes(1).action_flag     := 'U';

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('Adjust_workflow_node: ' || 'Updating the shipping attributes..',1);
      End if;

      lStmtNumber := 50;

      WSH_INTERFACE.Update_Shipping_Attributes(
        p_source_code => 'OE',
        p_changed_attributes => l_changed_attributes,
        x_return_status => x_return_status);

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Adjust_workflow_node: ' || 'CTO:Failed in WSH_INTERFACE.update_shipping_attributes :', 1);
         END IF;
         OE_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
         IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('Adjust_workflow_node: ' || ' Success in update_shipping attributes..', 2);
         END IF;
      END IF ;

   end if; -- bugfix 3076061 Get_Code_Release_Level

   lStmtNumber := 60;

   l_return := CTO_WORKFLOW_API_PK.complete_activity(
		  p_itemtype       => 'OEOL',
		  p_itemkey        => p_config_line_id,
		  p_activity_name   => 'SHIP_LINE',
		  p_result_code     => 'UNRESERVE');

end if; -- if p_can_cto_create_supply


IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('Adjust_workflow_node: ' || 'Processing done. exiting...', 5);
END IF;

Exception

WHEN FND_API.G_EXC_ERROR THEN
   x_return_status :=  FND_API.G_RET_STS_ERROR;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('Adjust_workflow_node: ' || 'Expected error. Last stmt executed is ..'|| to_char(lStmtNumber), 1);
   END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('Adjust_workflow_node: ' || 'UnExpected error. Last stmt executed is ..' || to_char(lStmtNumber) || ' ' || sqlerrm, 1);
   END IF;

when others then
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('Adjust_workflow_node: ' || 'When others exception ..Last stmt executed is ..' || to_char(lStmtNumber) || ' ' || sqlerrm, 1);
   END IF;

End Adjust_workflow_node;




/******************************************************************************************
|      This is the Procedure that will be called by Order Management                      |
|      with the type of changes as parameters.                                            |
|      This procedure will evaluates the changes and decide to send  or                   |
|      not to send the notification 					                  |
|      This procedure will invoke the notification workflow                               |
|		                                                                          |
|      INPUT  : PLineid   - The model line in for which change order process is invoked   |
|               Pchgtype  - This is a pl/sql Record which will contains the changes       |
|                          happend for the model line                                     |
|                                                                                         |
******************************************************************************************/

     /* Added by Sushant for Decimal-Qty Support for Option Items */
  PROCEDURE Change_Notify(
            pLineid	    in  number, -- The default case is added by Renga Kannan
            Pchgtype        in  change_table_type,   -- on 02/27/01 for the PTO-ATO config change case


            x_return_status out	NOCOPY varchar2,
            X_Msg_Count	    out	NOCOPY number,
            X_MSg_Data	    out	NOCOPY varchar2,
            PoptionChgDtls  in  OPTION_CHG_TABLE_TYPE default v_option_chg_table,
            PsplitDtls      in  SPLIT_CHG_TABLE_TYPE default  v_split_chg_table
            ) as

    lconfig_change   boolean := FALSE;
    l_decimal_qty    boolean := TRUE ;
    lcancel_line     boolean := FALSE;
    lconfig_line_id  number;
    i                binary_integer;
    lconfig_id       oe_order_lines.configuration_id%type;
    lorder_no        oe_order_headers_all.order_number%type;
    lheader_id       oe_order_headers_all.header_id%type;
    lplanner_code    fnd_user.user_name%type; -- Modified by Renga on 11/24/04
--for bug 4026568
    lOrg_id          mtl_system_items.organization_id%type;
    lStmtNumber	     number;
    lResv_exists     boolean;
    lato_item_flag   varchar2(1) := 'N';

    -- rkaza. 05/10/2005. changed it to default 'Y' as we are currently
    -- setting it to 'Y' for all cases except buy cases. Distinguishes buy
    -- and non buy cases. The way this variable is used currently, mlmo is a
    -- misnomer.
    lmlmo_flag       varchar2(1) := 'Y';

    -- The followin variables are declared to act as an out parameter for
    -- delink operation

    x_source_type     Number;
    x_rule_exists     Varchar2(1);
    x_err_number      varchar2(100);
    x_err_name        varchar2(100);
    x_tbl_name        varchar2(100);

    lqty_change       Boolean := FALSE;
    return_value      NUMBER;
    notify_flag       Boolean := TRUE;



    l_source_type_code oe_order_lines_all.source_type_code%type;

    v_options_index number ;
    v_splits_index number ;
    l_unschedule_action boolean ;
    l_warehouse_change boolean ;

    -- FP Bug fix 4103806

    l_option_specific		Number;
    l_valid_ship_from_org	Varchar2(1);

    -- FP Bug Fix 4103604
    l_can_create_supply         Varchar2(1);

    -- rkaza. 05/10/2005. ireq project.
    l_req_change_details req_change_info;
    l_sourcing_org      Number;

    --kkonada OPM change
    lqty2_change       Boolean := FALSE;
    --opm and ireq
    l_message      varchar2(100);

    -- Bug fix 4863275
    l_shipping_xfaced_flag   varchar2(1);

 BEGIN

    X_return_status := FND_API.G_RET_STS_SUCCESS;
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('Change_Notify: ' || 'Inside  CTO_NOTIFICATION procedure change_notify.',1);

    	oe_debug_pub.add('Change_Notify: ' || 'Input Line id = '||to_char(pLineid),2);
    END IF;

    -- OM is not able to handle the Config change in case of PTO-ATO Hybrid.
    -- When the new option class or option item is added OM cannot identify
    -- these new line's parent. This is because by the time they are calling the
    -- CTO pkg they don't have information like link_to_line_id, ato_line_id
    -- Hence we decided to handle this issue in different way.
    -- When some new lines are added in the pto-ato case OM will call this
    -- Pkg with change type config_change and with the special token 'PTO_ATO_CREATE'
    -- in the new_value field.
    -- Apart from that OM will pass all the line ids of the newly added lines.
    -- CTO will loop thru all these line_id's and decide whethere this is a candidate
    -- For change order or not and take action based on that.
    -- OM will pass the new lines even if they are the option class or option item
    -- belongs to PTO. It is CTO's responsibility to identify and ignore the action.
    -- As per the desing When the  CTO pkg is called  CTO will look at the PL/sql record for this
    -- special scenario and call another procedure Pto_ato_config_wrapper. That procedure will scan
    -- all the reocrds and take actions.

    -- Bugfix 2420484 (Base bug 2418075 )
   lStmtNumber := 2;
   IF Pchgtype.COUNT = 0 THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Change_Notify: ' || 'PChgtype array is NULL',2);
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Bugfix 2420484 (Base bug 2418075 )


    lStmtNumber := 3;

    IF pLineid is NULL  AND
      pchgtype(pchgtype.first).change_type = CTO_CHANGE_ORDER_PK.CONFIG_CHANGE AND
      pchgtype(pchgtype.first).new_value   = 'PTO_ATO_CREATE'
    THEN

      -- If the above conditions are satisfied meand this call is for
      -- a PTO-ATO case where some new lines are added
      -- This case needs to be treated in a different way than the other ones.
      -- This is because OM is not capable of identifing the parent ato lines
      -- for those config lines added . So OM will pass the lines line_id in the
      -- the old value filed and we will figur it out in our code from the database
      -- call our change_notify procedure recursivly.
      -- This part of the code is added by Renga Kannan on 02/27/2001

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Change_Notify: ' || 'This is PTO-ATO-Create new lines case....',3);

      	oe_debug_pub.add('Change_Notify: ' || 'Calling Pto_Ato_Config_wrapper procedure...',3);
      END IF;
      lStmtNumber := 5;
      Pto_Ato_config_wrapper(
                              Pchgtype         => Pchgtype,
                              X_return_status  => X_return_status,
                              X_Msg_Count      => X_Msg_count,
                              X_Msg_Data       => X_Msg_data);

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Change_Notify: ' || 'Pto_Ato_Config_Wrapper Procedure returned with status '||X_return_status,1);
      END IF;

      if X_return_status = FND_API.G_RET_STS_ERROR then
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('Change_Notify: ' || 'Failed in Pto_Ato_config_wrapper with expected error.', 1);
     		END IF;
		raise FND_API.G_EXC_ERROR;

      elsif X_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('Change_Notify: ' || 'Failed in Pto_Ato_config_wrapper with unexpected error.', 1);
     		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      X_return_status := FND_API.G_RET_STS_SUCCESS;
      return;

    end if;


   /************************************************************************************************

     The following are some of the design decisions.
     1. This code will be called by OM for both ATO item, ATO model change order.
     2. This code is called when user is changing the order after config item is created in case
        of ATO model. In the case of ATO item this procedure will get called when a user is
        changing the order after it is scheduled.
     3. AT this time we are supporting the following changes.
        * Request date, Scheduled arrival date, Scheduled ship date and qty change
        * Configuration change and cancellation.
     4. Configuration change is applicable only for ATO model case. In the case of configuration
        change config item will be delinked and notification will be sent allways.
     5. If the ATO model/ATO item is either Multilevel/Multi org or if reservation exists for the
        item then notification will be sent.
     6. There is one special case for ATO item. If the action is cancel notification will be
        sent for all the cases. This decision is taken cuz while cancelling the line OM unreservs
        the item before calling our code. And hence there is no way of identifying the reservation
        at this time.
     7. In case of cancellation the config item is delinked allways.
     8. The delink is only for ATO model not for ATO item.


    *************************************************************************************************/

    -- The following select stmt will determine whether the line_id passed by Om
    -- is ATO item or ATO MODEL

    lStmtNumber := 10;

    -- added condition
    -- item_type_code = 'OPTION' to account for ATO ITEMs under PTO Models as per BUG#1874380

    BEGIN

      SELECT 'Y',
             inventory_item_id,
             header_id,
             ship_from_org_id,
	     source_type_code,
	     nvl(shipping_interfaced_flag,'N') -- Bug Fix: 4863275
      INTO   lato_item_flag,
             lConfig_id,
             lheader_id,
             lorg_id,
	     l_source_type_code,
	     l_shipping_xfaced_flag  -- Bug Fix: 4863275
      FROM   OE_ORDER_LINES_ALL
      WHERE  line_id = ato_line_id
      --Adding item_type_code = 'INCLUDED' for Sun ER#9793792.
      AND    ( item_type_code = 'STANDARD' OR item_type_code = 'OPTION' OR item_type_code = 'INCLUDED')
      AND    line_id = pLineid;

      lconfig_line_id := PLineid;  -- In case of ATO item both config id and model id are same

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Change_Notify: ' || 'This is ATO ITEM Case..',3);
      END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN

           lato_item_flag := 'N';
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('Change_Notify: ' || 'This is ATO MODEL Case..',3);
           END IF;
    END;

    lStmtNumber  := 20;

    -- Check for cancellation or configuration change in the parameter table
    -- Quantity changed to zero will  be treated as cancelation
    -- This is as per the discussion with Gayathri Pendse from OM
    -- bugfix 4293763
    IF     lato_item_flag = 'N'
       AND CTO_WORKFLOW.config_line_exists(pLineid) <> TRUE
    THEN

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('Change_Notify: ' || 'Config item does not exists , No action needed...',3);
       END IF;
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       return;

    END IF;

    IF lato_item_flag = 'N' THEN -- Get the config dtls only in the case of ATO model

       lStmtNumber := 21;
       SELECT line_id,
              inventory_item_id,
              ship_from_org_id,
              header_id,
	      source_type_code,
	      nvl(shipping_interfaced_flag,'N')  -- Bug Fix: 4863275
       INTO   Lconfig_line_id,
              lconfig_id,
              lorg_id,
              lheader_id,
              l_source_type_code,
              l_shipping_xfaced_flag    -- Bug Fix: 4863275
       FROM   oe_order_lines_all
       WHERE  ato_line_id = plineid
       AND    item_type_code = 'CONFIG';

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('Change_Notify: ' || 'Config item id = '||to_char(lconfig_id),3);

       	oe_debug_pub.add('Change_Notify: ' || 'Config line id = '||to_char(lconfig_line_id),3);
       END IF;

    ELSE
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('Change_Notify: ' || 'ATO item id = '||to_char(lconfig_id),3);

       	oe_debug_pub.add('Change_Notify: ' || 'ATO line id = '||to_char(lconfig_line_id),3);
       END IF;

    END IF;



    -- rkaza. 05/10/2005. ireq project.
    -- Populating l_req_change_details fields along the way i this loop.

    i := pchgtype.FIRST;

    LOOP
       IF (pchgtype.exists(i)) THEN

          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('Change_Notify: ' || 'Change type #'||to_char(pchgtype(i).change_type),3);

          	oe_debug_pub.add('Change_Notify: ' || 'Old value   = '||pchgtype(i).old_value,3);

          	oe_debug_pub.add('Change_Notify: ' || 'New Value   = '||pchgtype(i).new_value,3);
          END IF;

          IF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.SSD_CHANGE THEN

             if( pchgtype(i).new_value is null ) then
          	oe_debug_pub.add('Change_Notify: ' || 'Unschedule case ' ,3);
                l_unschedule_action := TRUE ;
	     	l_req_change_details.unschedule_action_flag := TRUE;
	       --l_req_change_details.new_ssd_date := 'NULL';
	     else
          	oe_debug_pub.add('Change_Notify: ' || 'Date change case ' ,3);

		l_req_change_details.date_change_flag := TRUE;
		-- rkaza. note that a varchar2 is directly assigned to a date.
		-- This assumes that the varchar2 string is in default date
		-- format and does an implict conversion.
		-- OM passes us a varchar2 even for a date. They just do a
		-- to_char(date_value) before passing. It will put the
		-- varchar2 string in default date format.
		l_req_change_details.new_ssd_date := pchgtype(i).new_value;
             end if;

          END IF ;


          IF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.WAREHOUSE_CHANGE THEN

             if( pchgtype(i).new_value is not null ) then

          	oe_debug_pub.add('Change_Notify: ' || 'Warehouse change  ' ,3);
		oe_debug_pub.add('Change_Notify: ' ||' Old ship from org = '||pchgtype(i).old_value,3);
		oe_debug_pub.add('Change_Notify: ' ||' New ship from org = '||pchgtype(i).new_value,3);

                l_warehouse_change := TRUE ;

                -- Fix for the FP bug 4103806
		-- If the config item is a OSS item, we should validate
		-- whether the new ship from org is one of the valid oss orgs
		-- In general, the invalid ship from org will be deducted during scheduling itself
		-- If the item is non atpable then scheduling will not catch. So we are validating here

		select option_specific_sourced
		into   l_option_specific
		from   mtl_system_items msi
       		where  msi.inventory_item_id = lconfig_id
		and    rownum = 1;

		If l_option_specific is not null Then

		   oe_debug_pub.add('Change_notify : Item is option specific.. Validating ship org',1);

		   begin

		      -- The following sql looks at the sourcing assignment for the item and
		      -- check if the new ship org is etiher part of receiving org / source org

		      select 'Y'
		      into   l_valid_ship_from_org
		      from   mrp_sr_assignments assg,
		             mrp_sr_receipt_org rcv,
			     mrp_sr_source_org  src
		      where  assg.inventory_item_id = lconfig_id
		      and    assg.sourcing_rule_id = rcv.sourcing_rule_id
		      and    rcv.effective_date <= sysdate
		      and    nvl(rcv.disable_date,sysdate+1)>sysdate
	              and    rcv.SR_RECEIPT_ID = src.sr_receipt_id
		      and    (   assg.organization_id = pchgtype(i).new_value
			      or src.source_organization_id = pchgtype(i).new_value)
		      and    rownum =1;

		      oe_debug_pub.add('Change_Notify : New ship from org '||pchgtype(i).new_value||' is valid..',1);

		   Exception When No_data_found then
	              oe_debug_pub.add('Change Notify: New Ship from org '||pchgtype(i).new_value||' is not valid',1);
		      l_valid_ship_from_org := 'N';
	              CTO_MSG_PUB.cto_message('BOM','CTO_OSS_INVALID_SHIP_ORG');
		      raise FND_API.G_EXC_ERROR;
		   End;
		Else
		   oe_debug_pub.add('Change_Notify : Item is not option Specific...',1);
		End if;
                -- End of Fix for the FP bug 4103806

             else

          	oe_debug_pub.add('Change_Notify: ' || 'Warehouse change  null ' ,3);

             end if;

          END IF ;




          IF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.CONFIG_CHANGE THEN
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('Change_Notify: ' || 'Configuration is changed..',3);
             	oe_debug_pub.add('Change_Notify: ' || 'Configuration is changed..'   || poptionchgdtls.count ,3);
             END IF;


             /* Added by Sushant for Decimal-Qty Support for Option Items */
             if( PoptionChgDtls.count > 0 ) then

                 l_decimal_qty := FALSE ;




                IF PG_DEBUG <> 0 THEN
             	   oe_debug_pub.add('Change_Notify: ' || 'Going to check old and new qty..',3);
             	   oe_debug_pub.add('Change_Notify: ' || 'first..' || poptionchgdtls.first
                                    || ' last ' || poptionchgdtls.last ,3);
                END IF;


                 v_options_index := poptionchgdtls.first ;

                 -- for v_options in 1..PoptionChgDtls.count

             	 oe_debug_pub.add('Change_Notify: ' || 'first..' || v_options_index , 1 );

                 while( v_options_index is not null )
                 loop

                    IF PG_DEBUG <> 0 THEN
             	       oe_debug_pub.add('Change_Notify: ' || 'old qty ' || PoptionChgDtls(v_options_index).old_qty ,3);
             	       oe_debug_pub.add('Change_Notify: ' || 'new qty ' || PoptionChgDtls(v_options_index).new_qty ,3);
                    END IF;

             	       oe_debug_pub.add('Change_Notify: actual new qty ' || Round( NVL(PoptionChgDtls(v_options_index).new_qty, 0 ) , 7 ),  1 ) ;

             	       oe_debug_pub.add('Change_Notify: actual old qty ' || Round( NVL(PoptionChgDtls(v_options_index).old_qty, 0 ) , 7 ),  1 ) ;

                    if ( Round( NVL( PoptionChgDtls(v_options_index).new_qty , 0 ) , 7 ) <>
                         Round( NVL( PoptionChgDtls(v_options_index).old_qty , 0 ) , 7 ) ) then
                        lconfig_change := TRUE ;
	     		l_req_change_details.config_change_flag := TRUE;
                        l_decimal_qty := TRUE ;
             	       oe_debug_pub.add('Change_Notify: actual Decimal Change ' , 1 ) ;

                        exit ;
                    end if;


                    v_options_index := poptionchgdtls.next(v_options_index);


             	   oe_debug_pub.add('Change_Notify: ' || 'next..' || v_options_index , 1 );



                 end loop;


             else   /* backward compatibility for pre-patchset J OM code */
                IF PG_DEBUG <> 0 THEN
             	   oe_debug_pub.add('Change_Notify: ' || 'PoptionChgDtls count is 0 ..',3);
                END IF;

                lconfig_change := TRUE;
	     	l_req_change_details.config_change_flag := TRUE;

             end if;
             /* Added by Sushant for Decimal-Qty Support for Option Items */




          ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_CHANGE and to_number(pchgtype(i).new_value) = 0 THEN
             lcancel_line   := TRUE;
	     l_req_change_details.cancel_line_flag := TRUE;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('Change_Notify: ' || 'Line is cancelled..',3);
             END IF;

          ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_CHANGE THEN
             lqty_change := TRUE;
	     l_req_change_details.qty_change_flag := TRUE;
	     l_req_change_details.new_order_qty := to_number(pchgtype(i).new_value);
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('Change_Notify: ' || 'Quantity is changed..',3);
             END IF;



             /*Bug 6069483: Added the check for ato item as bcol is not applicable for ato item cases */
             if( psplitdtls.count > 0 ) and lato_item_flag = 'N' then  -- 6069483
                 /* Check for Split Line */

                 v_splits_index := psplitdtls.first ;


                 oe_debug_pub.add('Change_Notify: ' || 'first..' || v_splits_index , 1 );

                 while( v_splits_index is not null )
                 loop

                     IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Change_Notify: split line id ' || 'line id ' ||
                                          PsplitDtls(v_splits_index).line_id ,3);
                     END IF;


                     oe_debug_pub.add('Change_Notify: ' || 'calling split line ' , 1 );

                     cto_utility_pk.split_line( psplitdtls(v_splits_index).line_id,
                                            x_return_status      => x_return_status,
                                            X_Msg_Count          => x_Msg_Count,
                                            x_Msg_data           => x_Msg_data);


                     oe_debug_pub.add('Change_Notify: ' || 'done split line ' , 1 );



                     v_splits_index := psplitdtls.next(v_splits_index);


                     oe_debug_pub.add('Change_Notify: ' || 'next..' || v_splits_index , 1 );



                 end loop;


                 oe_debug_pub.add('Change_Notify: ' || 'calling adjust_bcol..' || pLineId , 1 );

                 cto_utility_pk.adjust_bcol_for_split(  p_ato_line_id => pLineId,
                                            x_return_status      => x_return_status,
                                            X_Msg_Count          => x_Msg_Count,
                                            x_Msg_data           => x_Msg_data);



             end if ; /* check for split line info */

          --this elseif block is for OPM change
          ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY2_CHANGE THEN
              lqty2_change := TRUE;

	      l_req_change_details.qty2_change_flag := TRUE;
	      l_req_change_details.new_order_qty2 := to_number(pchgtype(i).new_value);

	      IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('Change_Notify: ' || 'Secondary Quantity is changed..',3);
              END IF;

          END IF;

       END IF;

       EXIT WHEN i = pchgtype.LAST;
       i := pchgtype.NEXT(i);
    END LOOP;


     if( lconfig_change ) then

             	oe_debug_pub.add('Change_Notify: ' || 'config change is true..',3);

     else

             	oe_debug_pub.add('Change_Notify: ' || 'config change is false..',3);

     end if ;



    --Get the Configuration Line id and Configuration Item id in case of ATO model

    lStmtNumber := 30;

    -- Get the Order Number

    SELECT order_number
    INTO   lorder_no
    FROM   oe_order_headers_all
    WHERE  header_id = lheader_id;


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('Change_Notify: ' || 'Checking started...order #'||to_char(lorder_no),3);
    END IF;


    --  rkaza. ireq project. 05/10/2005.
    --  Call check_cto_can_create_supply. We process interface
    --  records only for IR or buy cases. Also source type will be used to
    --  determine whether to send the notification to buyer or planner.

    CTO_UTILITY_PK.check_cto_can_create_supply(
	p_config_item_id    => LConfig_id,
	p_org_id            => lorg_id,
	x_can_create_supply => l_can_create_supply,
	p_source_type       => x_source_type,
	x_return_status     => x_return_status,
	x_msg_count         => x_msg_count,
	x_msg_data          => x_msg_data,
	x_sourcing_org      => l_sourcing_org,      --opm
	x_message	    => l_message);          --opm

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('Change_notify: ' || 'success from check_cto_can_create_supply', 5);
          oe_debug_pub.add('Change_notify: ' || 'source_type = ' || x_source_type, 5);
          oe_debug_pub.add('Change_notify: ' || 'sourcing_org = ' || l_sourcing_org, 5);
          oe_debug_pub.add('Change_notify: ' || 'l_can_create_supply = ' || l_can_create_supply, 5);
	END IF;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('Change_notify: ' || 'Expected error in check_cto_can_create_supply', 1);
        END IF;
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('Change_notify: ' || 'Unexpected error in check_cto_can_create_supply', 1);
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- rkaza. 05/10/2005. This flag will be used in start_work_flow. It decides
    -- whether to send the notification to buyer or planner. For buy cases,
    -- notify buyer, else notify planner.
    if x_source_type = 3 then
       lmlmo_flag := 'B';
    end if;

    -- rkaza. 05/10/2005. Process interface records for buy and IR cases.
    IF x_source_type in (1, 3) THEN

        change_order_ato_req_item (
                p_config_line_id => lconfig_line_id,
                p_config_id => lconfig_id,
                p_org_id => lorg_id,
                p_source_type => x_source_type,
                p_req_change_details => l_req_change_details,
                x_return_status => x_return_status ) ;

        if X_Return_Status = FND_API.G_RET_STS_ERROR then
            raise FND_API.G_EXC_ERROR;
        elsif X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR then
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

    END IF; -- IR and buys cases.


    -- Delink the configuration item in the case of "Configuration Change"
    -- Or in the case of "ATO model cancel"

     IF (lconfig_change)
        or (lcancel_line and lato_item_flag = 'N')
        or ( l_unschedule_action and lato_item_flag = 'N' )
     THEN
        -- Config change can happen only in the case of ATO MODEL

       lStmtNumber := 40;

       -- Delink the configuration item
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('Change_Notify: ' || 'Config change.. Calling delink function...',3);
       END IF;

       -- Added by Renga Kannan
       -- The Following Pkg varibale is sest to 1 to notify the delink pkg that the call is coming
       -- from change order pkg.

       CTO_CHANGE_ORDER_PK.CHANGE_ORDER_PK_STATE := 1;

       IF CTO_CONFIG_ITEM_PK.delink_item(
                                        pModelLineId    => plineid,
                                        pConfigId       => lconfig_id,
				 	xErrorMessage   => x_err_number,
					xMessageName    => x_err_name,
                                        xTableName      => x_tbl_name) = 0
       THEN
          -- Re-initialize the pkg variable

          CTO_CHANGE_ORDER_PK.CHANGE_ORDER_PK_STATE := 0;
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('Change_Notify: ' || 'Delink failed....',5);
          END IF;

          CTO_MSG_PUB.cto_message('BOM',x_err_name);
          raise FND_API.G_EXC_ERROR;

       END IF;

       -- Re-initialize the Pkg Variable
       CTO_CHANGE_ORDER_PK.CHANGE_ORDER_PK_STATE := 0;


     END IF;  /* For delink Action */


     lStmtNumber := 60;


     -- In the case of dropship we need not/Should not send
     -- Notification . But we will be taking all other actions
     -- Bug No : 2234858

     -- rkaza. 05/11/2005. ireq project. Send notification for all cases
     -- except if drop ship or if decimal qty change is beyond 7 digits.
     -- notify_flag is true by default.
     -- decimal_qty is true by default. And is set to false only
     -- if the option item qty change is beyond the 7 digits.

     if l_source_type_code = 'EXTERNAL' or l_decimal_qty = FALSE then
        notify_flag   := FALSE;
        oe_debug_pub.add('Change_Notify: ' || 'Not sending notification. Either drop ship or decimal qty beyond 7 digits',3);
     end if;

     lStmtNumber := 70;

     if notify_flag then

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('Change_Notify: ' || 'Calling the notification...',3);
         END IF;

         start_work_flow(porder_no       =>lorder_no,
                         pline_no        =>plineid,
                         pchgtype        =>pchgtype,
                         pmlmo_flag      =>lmlmo_flag,
			 pconfig_id      =>lconfig_id,
                         X_return_status =>X_return_status,
                         X_Msg_Count     =>X_Msg_Count,
                         X_Msg_Data      =>X_Msg_Data,
                         pSplitDtls      => pSplitDtls );

         if X_Return_Status = FND_API.G_RET_STS_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('Change_Notify: ' || 'Failed in start_work_flow with expected error.', 1);
                END IF;
                raise FND_API.G_EXC_ERROR;

         elsif X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('Change_Notify: ' || 'Failed in start_work_flow with unexpected error.', 1);
                END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

     end if;/* to send notification*/


     -- 4103604 : We should evaluate the workflow status again for warehouse
     -- change. We need to see if CTO can create supply with the new warehouse.
     -- If CTO can create supply and the workflow is in ship line, we should
     -- move it to create supply order eligible If cto cannot create supply
     -- then if workflow is in create supply order eligible we should move the
     -- workflow to ship line. This will be done only for warehouse change We
     -- don't need to look at any reservation data as the warehouse change is
     -- not allowed after the supply is created.

     -- rkaza. 12/21/2005. bug 4674177. Similarly need to adjust workflow for
     -- unschedule action. If it is a config line,it is already delinked above.
     -- So nothing to adjust. But for an ato line, if there were req interface
     -- recs that got deleted above, then it needs adjustment. That
     -- would need a workflow adjustment as soon as we deleted the req i/f recs
     -- in change_order_ato_req_item proc, if any. We prefer to deal with it
     -- here at the end as things may change or some error could occur after
     -- that and also workflow api's may have some autonomous commits. So we
     -- check for source type 1 or 3 (xfer or buy). Note that it could be
     -- redundant sometimes. Eg, if there were IR/ER/PO reservations alone
     -- without any req i/f recs, then it would have been taken care of in
     -- reservation update code path itself. We would be repeating it here but
     -- we decided that it is ok as unschedule itself is not that common.

     -- Created a new local procedure adjust_workflow_node and moved this code
     -- into that proc

     lStmtNumber := 80;

     If (l_warehouse_change) or
        (l_unschedule_action and lato_item_flag = 'Y' and
         x_source_type in (1, 3))
     Then

        Adjust_workflow_node(
           p_config_line_id => lconfig_line_id,
           p_can_create_supply => l_can_create_supply,
	   p_shipping_xfaced_flag => l_shipping_xfaced_flag,
           x_return_status => x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           raise FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     End if; -- if warehouse change


     -- The disply wf status should be called in the following cases
     -- when there is a qty change or ware house change or (unschedule for an
     -- ato buy or xfer line as explained above)

     lStmtNumber := 90;

     if lqty_change or l_warehouse_change or
        (l_unschedule_action and lato_item_flag = 'Y' and
         x_source_type in (1, 3))
     then
        return_value := CTO_WORKFLOW_API_PK.display_wf_status(Lconfig_line_id);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Change_Notify: ' || ' Return value from display_wf_status = '|| return_value,3);
        END IF;
     end if;

EXCEPTION
            WHEN FND_API.G_EXC_ERROR THEN
            	IF PG_DEBUG <> 0 THEN
            		oe_debug_pub.add('Change_Notify: ' || 'Expected error in CHANGE_NOTIFY. Last stmt executed is ..'|| to_char(lStmtNumber),1);
            	END IF;
            	CTO_MSG_PUB.count_and_get(p_msg_count  => X_Msg_Count,
                                          p_msg_data   => X_Msg_Data);
                x_return_status := FND_API.G_RET_STS_ERROR;


            WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            	IF PG_DEBUG <> 0 THEN
            		oe_debug_pub.add('Change_Notify: ' || 'UnExpected error in CHANGE_NOTIFY. Last stmt executed is ..'|| to_char(lStmtNumber),1);
            	END IF;
            	CTO_MSG_PUB.count_and_get(p_msg_count  => X_Msg_Count,
                                          p_msg_data   => X_Msg_Data);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


            WHEN OTHERS THEN
            	IF PG_DEBUG <> 0 THEN
            		oe_debug_pub.add('Change_Notify: ' || 'OTHERS excepn in CHANGE_NOTIFY. Last stmt executed is ..'|| to_char(lStmtNumber),1);

            		oe_debug_pub.add('Change_Notify: ' || 'The error message is ..'||sqlerrm,2);
            	END IF;
            	CTO_MSG_PUB.count_and_get(p_msg_count  => X_Msg_Count,
                                          p_msg_data   => X_Msg_Data);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 End CHANGE_NOTIFY;

  /********************************************************************************
  +			This function will look for any reservation available     +
  +                     for this order. If reservation exists then	          +
  +                	it will return TRUE or it will return FALSE	          +
  ********************************************************************************/



  PROCEDURE  Reservation_Exists(
                               Pconfiglineid	in	   number,
                               x_return_status	out NOCOPY varchar2,
                               x_result		out NOCOPY boolean,
                               X_Msg_Count	out NOCOPY number,
                               X_Msg_Data	out NOCOPY varchar2) as

    l_reservation_id mtl_reservations.reservation_id%type;

  BEGIN

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Reservation_Exists: ' || 'Entering into Reservation_exists procedure....',1);
   END IF;
   -- Check if flow schedule exists . If not check some inv/work order Reservation
   -- exists. If both of them does'nt exists then return false. Other wise return true.

   IF CTO_WORKFLOW.flow_sch_exists(pconfigLineId) <> TRUE  THEN

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Reservation_Exists: ' || 'flow Reservation not exists..',5);

      	oe_debug_pub.add('Reservation_Exists: ' || 'The line_id passed for reservation = '||to_char(pconfiglineid),5);
      END IF;

      SELECT   reservation_id
      INTO     l_reservation_id
      FROM
            mtl_reservations mr,
            oe_order_lines_all oel,
            oe_order_headers_all oeh,
            oe_transaction_types_all ota,
            oe_transaction_types_tl otl,
            mtl_sales_orders mso
      WHERE
               mr.demand_source_line_id = oel.line_id
      and      oel.line_id              = pconfigLineId    --- Configuration item line id
      and      oeh.header_id            = oel.header_id
      and      oeh.order_type_id        = ota.transaction_type_id
      and      ota.transaction_type_code=  'ORDER'
      and      ota.transaction_type_id   = otl.transaction_type_id
      and      oeh.order_number         = mso.segment1
      and      otl.name                 = mso.segment2
      and      otl.language             = (select language_code
                                           from  fnd_languages
                                           where installed_flag  ='B')
      and      mso.sales_order_id       = mr.demand_source_header_id
      --and      mr.demand_source_type_id = INV_RESERVATION_GLOBAL.g_source_type_oe
      and      mr.demand_source_type_id = decode(oeh.source_document_type_id, 10, INV_RESERVATION_GLOBAL.g_source_type_internal_ord,
                                             INV_RESERVATION_GLOBAL.g_source_type_oe)	--bugfix 1799874
      and      mr.reservation_quantity  > 0
      and      rownum                   = 1;
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Reservation_Exists: ' || 'Work order/Inv reservation Exists..',5);
      END IF;
    END IF;

    x_result := TRUE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
           WHEN no_data_found THEN
           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('Reservation_Exists: ' || 'Coming out of reservation_exists procedure with FALSE...',2);
           	END IF;
           	x_return_status := FND_API.G_RET_STS_SUCCESS;
	   	x_result :=  FALSE;

           WHEN others THEN
           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add('Reservation_Exists: ' || 'OTHERS excpn occured in Reservation_Exists procedure..',2);

           		oe_debug_pub.add('Reservation_Exists: ' || 'Error message is : '||sqlerrm,1);
           	END IF;
           	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           	x_result := FALSE;

 END Reservation_Exists;

 /**********************************************************************************
 +								                    +
 + 	This procedure will set the workflow attributes and call the workflow       +
 +								                    +
 ***********************************************************************************/

PROCEDURE start_work_flow (
                            porder_no		in	   number,
                            pline_no		in	   number,
                            pchgtype     	in	   change_table_type,
                            pmlmo_flag          in         varchar2,
			    pconfig_id          in         number,
                            x_return_status	out NOCOPY varchar2,
                            X_Msg_Count		out NOCOPY number,
                            X_Msg_Data		out NOCOPY varchar2,
                            PsplitDtls  in     SPLIT_CHG_TABLE_TYPE default  v_split_chg_table) is


   litem_key   			varchar2(100);
   luser_key   			varchar2(100);
   lcustomer_name 		varchar2(400);
   litem_name			mtl_system_items_kfv.concatenated_segments%type; --OPM
   lreq_date			date;
   lssd_date			date;
   lsad_date			date;
   lord_qty			number;

   lcust_line_no		varchar2(50);
   lnotify_person		varchar2(200);
   i				binary_integer;
   linv_item_id                 oe_order_lines_all.inventory_item_id%type;
   lplanner_code		fnd_user.user_name%type; -- Modified by Renga on
--11/24/04 for bug 4026568
   lship_org_id                 oe_order_lines_all.ship_from_org_id%type;
   ldummy                       varchar2(1);
   lstmt                        number;
--- Added by Renga Kannan on 03/23/2001 to implement the new bulk attribute setting calls for wf_engine
   l_aname                      wf_engine.nametabtyp;
   l_anumvalue                  wf_engine.numtabtyp;
   l_atxtvalue                  wf_engine.texttabtyp;
-- End of additions.

   l_cancel_flag                varchar2(1) := 'N';
   l_header_id                  oe_order_lines_all.header_id%type;

    l_mlsupply_items CTO_SUBASSEMBLY_SUP_PK.t_item_details;
    l_items VARCHAR2(4000);
    l_mlsupply_parameter number;
    j number;
     l_item_id number;
   l_organization_id number;

   l_return_status varchar2(1);
   l_error_message VARCHAR2(70);  /* 70 bytes to hold */
   l_message_name  VARCHAR2(30);/* 30 bytes to hold  name */


--- Added by ssawant for split
   l_aname_split                      wf_engine.nametabtyp;
   l_atxtvalue_split                  wf_engine.texttabtyp;

   v_split_line_id    number ;
   v_split_qty    number ;
   v_split_index   number ;

   v_model_line_num    varchar2(1000) ;

    l_new_line  varchar2(10) := fnd_global.local_chr(10);

   v_old_org varchar2(240);
   v_new_org varchar2(240);

   --for OPM project :kkonada
   lord_qty2		number; --ordered qty in secondary uom
   l_old_ord_qty2       number;
   l_ord_uom2		oe_order_lines_all.ORDERED_QUANTITY_UOM2%type;
   l_old_ord_uom2	oe_order_lines_all.ordered_quantity_uom2%type;
   l_old_ord_qty        number;
   l_ord_uom		oe_order_lines_all.order_quantity_uom%type;
   l_old_ord_uom	oe_order_lines_all.order_quantity_uom%type;
   l_qty_set		varchar2(1) := 'N';
   l_qty2_set		varchar2(1) := 'N';

   -- bug 7447357.pdube Mon Oct 20 04:03:59 PDT 2008
   -- Introdcued this to get a unique user name
   CURSOR get_buyer_user_name(inv_item_id NUMBER,ship_org_id NUMBER) IS
   SELECT FU.user_name
   FROM   MTL_SYSTEM_ITEMS MTI,
          PO_BUYERS_ALL_V PBAV,
          FND_USER FU
   WHERE MTI.inventory_item_id = inv_item_id
   AND   MTI.organization_id   = ship_org_id
   AND   MTI.buyer_id          = PBAV.employee_id
   AND   PBAV.employee_id      = FU.employee_id(+) --outer join b'cos employee need not be an fnd user.
   ORDER BY FU.user_name asc;

    -- bug 7447357.pdube Tue Oct 21 04:31:34 PDT 2008
   -- Introdcued this to get a unique user name
   CURSOR get_planner_user_name(inv_item_id NUMBER,ship_org_id NUMBER) IS
   SELECT  u.user_name
   FROM   mtl_system_items_vl item,
          mtl_planners p,
          fnd_user u
   WHERE item.inventory_item_id = inv_item_id
   and   item.organization_id   = ship_org_id
   and   p.organization_id = item.organization_id
   and   p.planner_code = item.planner_code
   and   p.employee_id = u.employee_id(+)
  ORDER BY u.user_name asc;

   -- bug 7447357.ntungare
   -- Introdcued this to get a unique user name
   -- based on the Buyer on the PO
   CURSOR get_buyer_from_po(config_line_id IN NUMBER) IS
   select u.user_name
   from mtl_reservations mr,
        po_headers_all poh,
        oe_order_lines_all oel,
        fnd_user u
   where oel.line_id =  config_line_id and
         mr.demand_source_type_id in (8,2) and
         mr.demand_source_line_id = oel.line_id and
         mr.supply_source_type_id =  1 and
         mr.supply_source_header_id = poh.po_header_id and
         poh.agent_id = u.employee_id
   ORDER BY u.user_name asc;

   -- bug 7447357.ntungare
   -- Introdcued this to get a unique user name
   -- based on the Buyer on the PO req line
   CURSOR get_buyer_from_po_req_line(config_line_id IN NUMBER) IS
   select u.user_name
    from mtl_reservations mr,
         po_requisition_headers_all porh,
         po_requisition_lines_all porl,
         oe_order_lines_all oel,
         fnd_user u
   where oel.line_id = config_line_id and
         mr.demand_source_type_id in (8,2) and
         mr.demand_source_line_id = oel.line_id and
         mr.supply_source_type_id = 17 and
         mr.supply_source_header_id = porh.requisition_header_id and
         porh.requisition_header_id = porl.requisition_header_id and
         mr.supply_source_line_id = porl.requisition_line_id and
         porl.suggested_buyer_id = u.employee_id
   ORDER BY u.user_name asc;

   -- bug 7447357.ntungare
   -- Cursor to get the Config Item line id
   CURSOR get_config_line_id(p_header_id IN NUMBER) IS
   select line_id
     from oe_order_lines_all
   where inventory_item_id = pconfig_id and
         header_id         = p_header_id;

   l_config_line_id NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  lstmt := 10;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('start_work_flow: ' || 'Inside procedure start_work_flow',5);
  END IF;

  --
  -- The Following Block of Statment will set the minimum attributes needed for the work flow
  --

  litem_key := to_char(pline_no)||to_char(sysdate,'mmddyyhhmiss');
  luser_key := litem_key;

  --
  -- Get the information from OE_ORDER_LINES_ALL table for the Model line
  --

  lstmt := 20;
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('start_work_flow: ' || 'Getting details from Oe_order_lines for line id '||to_char(pline_no),5);
  END IF;

  SELECT
           schedule_ship_date,
           schedule_arrival_date,
           ordered_quantity,
	   ordered_quantity2,--secondary qty for OPM 05/27/2004
           line_number||decode(shipment_number,NULL,'','.'||shipment_number)||
                        decode(option_number,NULL,'','.'||option_number),
           request_date,
           inventory_item_id,
           ship_from_org_id,
	   header_id,
	   ordered_quantity_uom2,   --secondary ordered UOM for OPM proj
           order_quantity_uom       --primary ordered UOM
  INTO
           lssd_date,
           lsad_date,
           lord_qty,
	   lord_qty2,		    --ordered_quantity2 for OPM proj
           lcust_line_no,
           lreq_date,
           linv_item_id,
           lship_org_id,
	   l_header_id,
	   l_ord_uom2,             --ORDERED_QUANTITY_UOM2 for OPM proj
	   l_ord_uom               --order_quantity_uom for OPM proj
  FROM
           oe_order_lines_all
  WHERE
           line_id = pline_no;

  --OPM. Defaulting the primary and secondry uom and qty
  --for cases where the call is for UOM change(then Default qty)
  --or QTY chnage (then default uom)alone
  l_old_ord_uom  := l_ord_uom;
  l_old_ord_uom2 := l_ord_uom2;
  l_old_ord_qty  := lord_qty;
  l_old_ord_qty2 := lord_qty2;

  lstmt  := 25; --OPM
  SELECT concatenated_segments
  INTO litem_name
  FROM mtl_system_items_kfv
  WHERE inventory_item_id = pconfig_id
  AND organization_id = lship_org_id;

  -- Get the customer name from ra_customers_view
  lstmt  := 30;
  -- Bug fix 4570911 by Renga Kannan on 30-Aug-2005
  -- Replaced RA_CUSTOMER_VIEW reference with HZ_PARTIES sql
  -- RA_CUSTOMER_VIEW is obsoleted in R12 by fin team

  SELECT
  substrb(PARTY.PARTY_NAME,1,50) CUSTOMER_NAME
  into lcustomer_name
  FROM HZ_PARTIES PARTY,
       HZ_CUST_ACCOUNTS CUST_ACCT,
       oe_order_headers_all oeh
  WHERE CUST_ACCT.CUST_ACCOUNT_ID = oeh.sold_to_org_id
  AND   CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
  AND   oeh.header_id = l_header_id;

  if PG_DEBUG <> 0 then
     oe_debug_pub.add('Start_workflow: Customer Name  = '||lcustomer_name,1);
  end if;

  -- rkaza. bug 4101723. 01/19/2005. Notification should be sent to the old
  -- org in case of warehouse change. So deriving the old org from pchgtype.

  lstmt  := 31;

  for j in pchgtype.first..pchgtype.last
  loop
     if pchgtype(j).change_type = WAREHOUSE_CHANGE then
        lship_org_id := pchgtype(j).old_value;
        exit;
     end if;
  end loop;


  -- In the case of Buy ATo item we need to send the notification to the
  -- Buyer . Get the buyer info from Mtl_system_items
  IF pmlmo_flag = 'B' THEN

       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('start_work_flow: ' || 'Getting buyer info..',1);
       END IF;

      -- bugfix 2203802: Instead of getting the full name directly from po_buyers_all_v
      --                 get the corresponding application user.

       BEGIN

          -- Bug 7447357.pdube Mon Oct 20 04:26:25 PDT 2008.
          -- getting the value for user_name in the variable.
          /*SELECT u.user_name
          INTO   lplanner_code
          FROM   MTL_SYSTEM_ITEMS A,
                 PO_BUYERS_ALL_V B,
                 FND_USER U
          WHERE a.inventory_item_id = linv_item_id
          AND   a.organization_id   = lship_org_id
          AND   a.buyer_id          = b.employee_id
          AND   b.employee_id       = u.employee_id(+);     --outer join b'cos employee need not be an fnd user.*/

          -- bug 7447357.ntungare
          -- Get the Config Item line id
          OPEN get_config_line_id(l_header_id);
          FETCH get_config_line_id INTO l_config_line_id;
          CLOSE get_config_line_id;

          -- bug 7447357.ntungare
          -- Get buyer info for PO
          OPEN get_buyer_from_po(l_config_line_id);
          FETCH get_buyer_from_po into lplanner_code;
          CLOSE get_buyer_from_po;

          IF lplanner_code IS NULL THEN
             -- bug 7447357.ntungare
             -- Get buyer info for PO Req Line
             OPEN get_buyer_from_po_req_line(l_config_line_id);
             FETCH get_buyer_from_po_req_line into lplanner_code;
             CLOSE get_buyer_from_po_req_line;
          END IF;

          IF lplanner_code IS NULL THEN
             -- bug 7447357.ntungare
             -- Get buyer info for Org Item
             OPEN get_buyer_user_name(linv_item_id,lship_org_id);
             FETCH get_buyer_user_name into lplanner_code;
             CLOSE get_buyer_user_name;
          END IF;

       EXCEPTION
	 WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('start_work_flow: ' || 'Buyer Not defined.. Defaulting to Sysadmin: ',2);

            	oe_debug_pub.add('start_work_flow: ' || 'Error Message : '||sqlerrm,2);
            END IF;
            lplanner_code :=  Null;

       END;
  ELSE
       -- Get the item name and planner code from mtl_system_item_vl
       lstmt := 40;
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('start_work_flow: ' || 'Getting the planner code ..',3);
       	oe_debug_pub.add('start_work_flow: ' || 'MLMO not B: lship_org_id = ' || lship_org_id,3);
       END IF;

       BEGIN
      	-- bugfix 2203802: Instead of getting the planner code directly from MSI,
      	--                 get the corresponding application user.

        -- Bug 7447357.pdube Tue Oct 21 04:31:34 PDT 2008.
        -- getting the value for user_name in the variable.
        /*SELECT  u.user_name
        INTO   lplanner_code
        FROM   mtl_system_items_vl item
              ,mtl_planners p
              ,fnd_user u
        WHERE item.inventory_item_id = linv_item_id
        and   item.organization_id   = lship_org_id
        and   p.organization_id = item.organization_id
        and   p.planner_code = item.planner_code
        and   p.employee_id = u.employee_id(+);         --outer join b'cos employee need not be an fnd user.*/
          OPEN get_planner_user_name(linv_item_id,lship_org_id);
          FETCH get_planner_user_name into lplanner_code;
          CLOSE get_planner_user_name;

       EXCEPTION

       WHEN OTHERS THEN
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('start_work_flow: ' || 'Error in getting the planner code data. Defaulting to SYSADMIN.',2);

          	oe_debug_pub.add('start_work_flow: ' || 'Error Message : '||sqlerrm,2);
          END IF;
          lplanner_code :=  Null; -- bug 4101723
       END;


  END IF;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('start_work_flow: ' || 'Planner code = '||lplanner_code,3);
  END IF;


  --       Loop through the change type pl/sql record and set the workflow attributes according to the
  --       changes from Order Management

  lstmt := 60;
  wf_engine.CreateProcess (ItemType=> 'CTOCHORD',ItemKey=>litem_key,Process=>'CHGNOTIFY');
  wf_engine.SetItemUserKey(ItemType=> 'CTOCHORD',ItemKey=>litem_key,UserKey=>luser_key);

  -- Check if the planner code is a valid workflow user. If not
  -- Assigne the adminstartor uesr to planner code

  lstmt := 65;
  -- Modified the code by Renga Kannan on 02/17/01.Istead of hardcoding the user name
  -- getting the adminstrator value from attributes.

  IF WF_DIRECTORY.USERACTIVE(lplanner_code) <>TRUE THEN
      -- Get the default adminstrator value from Workflow Attributes.
      lplanner_code := wf_engine.getItemAttrText(ItemType => 'CTOCHORD',
                                                 ItemKey  => litem_key,
                                                 aname    => 'WF_ADMINISTRATOR');
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('start_work_flow: ' || 'Planner code is not a valid workflow user...Defaulting to'||lplanner_code,5);
      END IF;
  END IF;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('start_work_flow: ' || 'Looping thru the change table...',1);
  END IF;

  --bugfix 3651068
  --check for cancel has been moved up from the below LOOP
  i := pchgtype.FIRST;
  LOOP
    IF (pchgtype.exists(i)) then
       IF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_CHANGE
          and
	  to_number(pchgtype(i).new_value) = 0  then

          l_aname(i)     := 'CANCEL_FLAG';
          l_atxtvalue(i) := ' YES';

          -- Added by Renga Kannan on 05/18/01 to set the action attribute of the workflow.
          -- By checking this flag later in the procedure the attribute ACTION_TEXT will be set.
          -- This is part of the bug fix # 1656334

	  --kkonada 06/22/2004, this flags is used to set SSD and SAD change to N/A
          l_cancel_flag  := 'Y';



	  exit;
	  --OPM project
        ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY2_UOM_CHANGE then
	   l_old_ord_uom2 := pchgtype(i).old_value;
	   l_ord_uom2     := pchgtype(i).new_value;


	  --opm
	ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_UOM_CHANGE then
           l_old_ord_uom := pchgtype(i).old_value;
	   l_ord_uom     := pchgtype(i).new_value;

	  --opm
	ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_CHANGE then
	   l_old_ord_qty := to_number(pchgtype(i).old_value);
	   lord_qty     := to_number (pchgtype(i).new_value);

          --opm
	ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY2_CHANGE then
	   l_old_ord_qty2 := to_number(pchgtype(i).old_value);
	   lord_qty2      := to_number(pchgtype(i).new_value);


	END IF;
    END IF;

    EXIT WHEN i = pchgtype.LAST;
    i := pchgtype.NEXT(i);
  END LOOP;


  --end bugfix 3651068

  i := pchgtype.FIRST;
  LOOP
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('start_work_flow: ' || 'Change type value...'||to_char(pchgtype(i).change_type),1);
      END IF;
      IF (pchgtype.exists(i)) then

        IF (pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_CHANGE  and to_number(pchgtype(i).new_value) <> 0)
	   OR
	   pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_UOM_CHANGE
	   then

	  --OPM
	  --this check is to make sure that we set the chnage order attribute
	  --ONLY ONCE,as this IF block can be executed second time due to the
	  --parent loop
          IF l_qty_set = 'N' THEN

            l_qty_set := 'Y';

	    l_aname(i)     := 'QTY';
            l_atxtvalue(i) := to_char(l_old_ord_qty) || ' ' || l_old_ord_uom || ' TO ' ||
	                      to_char(lord_qty) || ' ' || l_ord_uom;

          END IF; --l_qty_set

          --opm just the IF. Logic is carried over from earlier release

          IF  pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY_CHANGE THEN
            if( pSplitDtls.count > 0   ) then

      	      oe_debug_pub.add('start_work_flow: ' || 'Adding Split Data '  ,1);

              v_split_index := pSplitDtls.first ;

		l_aname_split(1)  := 'SPLIT_DTLS' ;

		/*
		l_atxtvalue_split(1) := 'The Order is split from ' || pchgtype(i).old_value || ' INTO '  || pchgtype(i).new_value ;
		*/

		l_atxtvalue_split(1) := 'The quantity change is due to a split line action  ' ;
		l_atxtvalue_split(1) := l_atxtvalue_split(1) ||  l_new_line  || 'The following are the new line(s) created ' ;

		while v_split_index is not null
		loop


			v_split_line_id := pSplitDtls(v_split_index).line_id ;


			select oel.line_number || '.' || oel.shipment_number || '.'  || nvl( oel.option_number , '' ) , ordered_quantity
			into v_model_line_num , v_split_qty
			from oe_order_lines_all oel
			where line_id = v_split_line_id ;

			/*
			select ordered_quantity into v_split_qty from bom_cto_order_lines
			where line_id = v_split_line_id ;
			*/

		        l_atxtvalue_split(1) := l_atxtvalue_split(1) || l_new_line || 'Line Number: ' || v_model_line_num || '      Quantity: ' || to_char( v_split_qty ) ;

      			oe_debug_pub.add('start_work_flow: ' || 'Adding Split Data '  || v_split_qty ,1);

		        v_split_index := pSplitDtls.next(v_split_index) ;


		 end loop ;


		end if;
	   END IF;--QTY_CHANGE

        --05/27/05following elsif is added for OPM project
        ELSIF pchgtype(i).change_type =CTO_CHANGE_ORDER_PK.QTY2_CHANGE
	      OR
	      pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.QTY2_UOM_CHANGE
	 then

	  --OPM
	  --this check is to make sure that we set the chnage order attribute
	  --ONLY ONCE,as this IF block can be executed second time due to the
	  --parent loop
           IF l_qty2_set = 'N' THEN

              l_qty2_set   :='Y';

              l_aname(i)     := 'QTY2'; --new CTOCHORD.wft token
              l_atxtvalue(i) := to_char(l_old_ord_qty2) || ' ' || l_old_ord_uom2 || ' TO ' ||
	                        to_char(lord_qty2) || ' ' || l_ord_uom2;
	   END IF;--l_qty2_set

        ELSIF pchgtype(i).change_type =CTO_CHANGE_ORDER_PK.RD_CHANGE  then
          l_aname(i)     := 'RD_DATE';
          l_atxtvalue(i) := pchgtype(i).old_value||' TO '||nvl(pchgtype(i).new_value,'NULL');

	  IF PG_DEBUG <> 0 THEN
	  oe_debug_pub.add('start_work_flow: ' || 'VALUE of i for RD change=>'||i,1);
	 END IF;


        ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.SSD_CHANGE  then

		l_aname(i)     := 'SSD_DATE';

		IF l_cancel_flag = 'Y' THEN      --3651068
		  l_atxtvalue(i) := 'N/A';--this is same as defalt value of attrbute in wrkflow
	        ELSE
		  l_atxtvalue(i) := pchgtype(i).old_value||' TO '||nvl(pchgtype(i).new_value,'NULL');
		END IF;





        ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.SAD_CHANGE  then

            l_aname(i)     := 'SAD_DATE';

	    IF l_cancel_flag = 'Y' THEN    --3651068
	    l_atxtvalue(i) := 'N/A';--this is same as defalt value of attrbute in wrkflow
	    ELSE
            l_atxtvalue(i) := pchgtype(i).old_value||' TO '||nvl(pchgtype(i).new_value,'NULL');
            END IF;





        ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.CONFIG_CHANGE  then
          l_aname(i)     := 'CONFIG_FLAG';
          l_atxtvalue(i) := ' YES';




        ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.DELINK_ACTION then
          l_aname(i)     := 'DLINK_FLAG';
          l_atxtvalue(i) := ' YES';



        ELSIF pchgtype(i).change_type = CTO_CHANGE_ORDER_PK.WAREHOUSE_CHANGE then
          l_aname(i)     := 'SHIP_ORG';
  	 oe_debug_pub.add('CHANGE WAREHOUSE INFO : ' ||  nvl( pchgtype(i).old_value , 'NULL' )
                           || ' new ' || nvl(pchgtype(i).new_value , 'NULL')  ) ;
          -- l_atxtvalue(i) := pchgtype(i).old_value||' TO '||pchgtype(i).new_value;

         begin
          -- rkaza. 3742393. 08/12/2004.
          -- Replaced org_organization_definitions with inv_organization_name_v

          select organization_name into v_old_org
          from inv_organization_name_v
          where organization_id  = pchgtype(i).old_value ;


         exception
         when others then

  	 oe_debug_pub.add('CHANGE WAREHOUSE INFO : ' ||  'exception while querying inv_organization_name_v for ' ||
                                       nvl( pchgtype(i).old_value , 'NULL' )  ) ;

           v_old_org := pchgtype(i).old_value ;
         end ;



         begin
          select organization_name into v_new_org
          from inv_organization_name_v
          where organization_id  = pchgtype(i).new_value ;

         exception
         when others then

         oe_debug_pub.add('CHANGE WAREHOUSE INFO : ' ||  'exception while querying inv_organization_name_v for ' ||
                                       nvl( pchgtype(i).new_value , 'NULL' ) ) ;

           v_new_org := pchgtype(i).new_value ;
         end ;


  	 oe_debug_pub.add('CHANGE WAREHOUSE INFO : ' ||  nvl( v_old_org , 'NULL' )
                           || ' new ' || nvl( v_new_org , 'NULL')  ) ;

          l_atxtvalue(i) := v_old_org ||' TO '|| v_new_org ;

        END IF;
      END IF;
      EXIT WHEN i = pchgtype.LAST;
      i := pchgtype.NEXT(i);
  END LOOP;




  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('start_work_flow: ' || 'customer line number is....'||lcust_line_no,5);
  END IF;

  lstmt := 70;

  wf_engine.SetItemAttrNumber(ItemType   =>'CTOCHORD',
                              itemkey    =>litem_key,
                              aname      =>'SO_NUMBER',
                              avalue     =>porder_no);

  -- Added by Renga Kannan on 05/18/01. If the action is cancel the action text needs to be set to 'cancelled'. If it is not
  -- cancell action, then attribute will take the default value 'modified'.

  i          := i + 1;
  l_aname(i) := 'ACTION_TEXT';

  IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add('start_work_flow: ' || 'VALUE of i for action_text=>'||i,1);
	 END IF;

  IF l_cancel_flag = 'Y' THEN
    l_atxtvalue(i)   := FND_MESSAGE.get_string ('BOM', 'CTO_ACTION_CANCELED');
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('start_work_flow: ' || 'Action is set to Canceled',5);
    END IF;

  ELSE
    l_atxtvalue(i)   := FND_MESSAGE.get_string ('BOM', 'CTO_ACTION_MODIFIED');
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('start_work_flow: ' || 'Action is set to Modified',5);
    END IF;
  END IF;


  i:= i + 1;
  l_aname(i)     := 'CUSTOMER_NAME';
  l_atxtvalue(i) := lcustomer_name;
  i:= i + 1;
  l_aname(i)     := 'LINE_NUMBER';
  l_atxtvalue(i) := lcust_line_no;
  i:= i + 1;
  l_aname(i)     := 'ITEM_NAME';
  l_atxtvalue(i) := litem_name;
  i:= i + 1;
  l_aname(i)     := 'NOTIFY_USER';
  l_atxtvalue(i) := lplanner_code;

  --added code for ml supply by kkonada
  i:= i + 1;
  l_aname(i)     := 'SUBASSEMBLY_TEXT';
  l_atxtvalue(i) := ' ';	 --default null value




  --added code for split by ssawant
  if( pSplitDtls.count > 0   ) then

      i:= i + 1;
      l_aname(i) := l_aname_split(1) ;
      l_atxtvalue(i) := l_atxtvalue_split(1) ;
     IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('start_work_flow: ' || 'added split line data to main txt '  ,1);
     END IF;
  end if;





  IF  pmlmo_flag <> 'B'	 THEN --as for buy item we need not show sub-assembly information
     lstmt := 78;
       BEGIN
	SELECT  bp.ENABLE_LOWER_LEVEL_SUPPLY
	INTO l_mlsupply_parameter
	FROM bom_parameters bp
	WHERE bp.organization_id = lship_org_id;
       EXCEPTION --bug#4666504 ,opm
        WHEN  no_data_found THEN
          IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('start_work_flow: ' || 'Enable Lower level supply parameter not set for org '|| lship_org_id,3);
	    oe_debug_pub.add('start_work_flow: ' || 'Defaulting parameter to 1 ',3);
          END IF;

          l_mlsupply_parameter := 1;

       END;

	IF (l_mlsupply_parameter in (2,3)) THEN

	       IF PG_DEBUG <> 0 THEN
      		oe_debug_pub.add('start_work_flow: ' || 'Before calling get_child_configurations with item_id '|| pconfig_id,5);
	       END IF;

		l_mlsupply_items(1).item_id := pconfig_id;

	        lstmt := 79;
		CTO_SUBASSEMBLY_SUP_PK.get_child_configurations
		(
			pParentItemId  => l_mlsupply_items(1).item_id,
			--pParentItemId  =>pconfig_id,
			pOrganization_id=>lship_org_id,
			pLower_Supplytype=> l_mlsupply_parameter,
			pParent_index=>1,
			pitems_table=> l_mlsupply_items,
			x_return_status=> l_return_status,
			x_error_message=>l_error_message,
			x_message_name=>l_message_name

		);

		IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			 oe_debug_pub.add('start_work_flow: ' || 'Unexcpected error in CTOSUBSB.gte_child_configurations',1);

		ELSIF   l_return_status = FND_API.G_RET_STS_ERROR THEN

		    oe_debug_pub.add('start_work_flow: ' || 'Expected  error in CTOSUBSB.gte_child_configurations',1);
		ELSE


		    oe_debug_pub.add('start_work_flow: ' || 'before entering teh loop to get the items',5);
		    IF ( l_mlsupply_items.count >1 ) THEN
			j := 1;
			LOOP
				IF(j = 1) THEN
					 l_items := 'Supply for following sub-assemblies may get affected by the change';
				ELSE
					 l_items := l_items || l_new_line || l_mlsupply_items(j).item_name;
				END IF;

					EXIT WHEN j = l_mlsupply_items.LAST;
				 j := l_mlsupply_items.NEXT(j);

			END LOOP;

			l_atxtvalue(i) := l_items ;

		     ELSE
			oe_debug_pub.add('start_work_flow: ' || 'No sub-assemblies found',5);

		     END IF;	   --mlsupply_item count
	        END IF; --  return status of get_child_configurations


	 END IF; --mlsupply parameter

 END IF; --ml_mo flag check

  --ENDED CODE FOR ML SUPPLY


  lstmt := 81;
  wf_engine.SetItemAttrTextArray(ItemType =>'CTOCHORD',ItemKey=>litem_key,aname=>l_aname,avalue=>l_atxtvalue);

  -- Added by Renga on 02/17/01
  -- Set the special text attribute to null in case of SL/SO. This special text needs to be
  -- Displayed only in the case of ML/MO. In the case of ML/MO we need not set this attribute . This
  -- Attribute is having default value that will be displayed.

  IF pmlmo_flag <> 'Y' THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('start_work_flow: ' || 'Single level single org model, Special text is set to Null',5);
      END IF;

      lstmt := 82;
      wf_engine.SetItemAttrText(ItemType=>'CTOCHORD',itemkey=>litem_key,aname=>'SPL_TEXT',avalue=>'');

  END IF;

  -- Calling the work flow
  lstmt := 80;
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('start_work_flow: ' || 'Starting the workflow...',2);
  END IF;
  wf_engine.SetItemOwner(Itemtype=>'CTOCHORD',itemkey=>litem_key,owner=>lplanner_code);
  wf_engine.StartProcess(itemtype=>'CTOCHORD',ItemKey=>litem_key);

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('start_work_flow: ' || 'success from ..... notification....',5);
  END IF;

EXCEPTION



  WHEN FND_API.G_EXC_ERROR THEN
    -- x_return_status :=  FND_API.G_RET_STS_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('start_work_flow: ' || 'Expected error in start_work_flow. Last stmt executed is ..'||to_char(lStmt),2);
     END IF;
     CTO_MSG_PUB.count_and_get(p_msg_count => x_msg_count,
                               p_msg_data  => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('start_work_flow: ' || 'UnExpected error in start_work_flow. Last stmt executed is ..'||to_char(lStmt),2);
     END IF;
     CTO_MSG_PUB.count_and_get(p_msg_count => x_msg_count,
                               p_msg_data  => x_msg_data);

  WHEN OTHERS THEN
     --x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('start_work_flow: ' || 'OTHERS excpn in start_work_flow. Last stmt executed is ..'||to_char(lStmt),2);

     	oe_debug_pub.add('start_work_flow: ' || 'Error Message is : '||Sqlerrm);
     END IF;
     CTO_MSG_PUB.count_and_get(p_msg_count => x_msg_count,
                               p_msg_data  => x_msg_data);


END start_work_flow;

/***********************************************************************************************************
*                                                                                                           *
*                                                                                                           *
*    Function Name : Is_item_ML_OR_MO                                                                       *
*                                                                                                           *
*    Input         : PInventory_item_id                                                                     *
*                    porg_id                                                                                *
*                                                                                                           *
*    Output        : X_result  --   TRUE/FALSE                                                              *
*                                                                                                           *
*    Description   : This procedure will check whether the given inventory_item in the given org is         *
*                    eithe Multi level or Multi org. If either of them is true it will return TRUE.         *
*                    If it is neither Multi level/Multi Org it will return FALSE                            *
*                                                                                                           *
*                                                                                                           *
************************************************************************************************************/



PROCEDURE  Is_item_ML_OR_MO(
                           pInventory_item_id    IN   mtl_system_items.inventory_item_id%type,
                           pOrg_id               IN   mtl_system_items.organization_id%type,
                           x_result              OUT NOCOPY Varchar2,
                           x_source_type         OUT NOCOPY Number,
                           x_return_status       OUT NOCOPY Varchar2,
                           x_msg_count           OUT NOCOPY Number,
                           x_msg_data            OUT NOCOPY Varchar2) IS

   x_src_org_id            Number;
   x_trans_lead_time       Number;
   l_stmt_no               Number;
   x_exp_error_code        Number;
BEGIN

   /* The following function tells whether this model is sourced or not */


   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('Is_item_ML_OR_MO: ' || 'Inside Procedure Is_item_ML_OR_MO', 3);
   END IF;

   l_stmt_no   :=  10;

   -- The following get_model_souring_org call is moved from CTO_ATP_INTERFACE_PK to CTO_UTILITY_PK
   -- To avoid dependency with Multi level functionality
   -- This is modified by Renga on 06/18/01.












    x_result := 'Y' ;


    return ;










   CTO_UTILITY_PK.get_model_sourcing_org(
                          p_inventory_item_id     => pInventory_item_id,
                          p_organization_id      => pOrg_id,
                          p_sourcing_rule_exists => x_result,
                          p_sourcing_org         => x_src_org_id,
                          p_source_type          => x_source_type,   --- Modified by renga for Procure
                          p_transit_lead_time    => x_trans_lead_time,
                          x_return_status        => x_return_status,
                          x_exp_error_code       => x_exp_error_code,
                          p_line_id              => NULL,
                          p_ship_set_name        => NULL
                          );

   if X_Return_Status = FND_API.G_RET_STS_ERROR then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('Is_item_ML_OR_MO: ' || 'Failed in get_model_sourcing_org with expected error.', 1);
	END IF;
        raise FND_API.G_EXC_ERROR;

   elsif X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('Is_item_ML_OR_MO: ' || 'Failed in get_model_sourcing_org with unexpected error.', 1);
        END IF;
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;


   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Is_item_ML_OR_MO: ' || 'The source flag returned from model sourcing..'||x_result,2);
   END IF;

   -- Modified by Renga Kannan on 05/09/2001
   -- The p_sourcing_rule_exists parameter is returned as FND_API.G_TRUE/FND_API.G_FLASE.
   -- I need to compare this with these pkg variables instead of 'Y'/'N' constants.

   IF x_result <> FND_API.G_TRUE  THEN   -- If it is not sourced then check for multi level


      /*
        The logic for the followin select is as follows. Scan the bill of material
        for the given item in the given org. If we find atleast one config item as its
        child then it is a Multi level configuration.
                                                                                        */
      l_stmt_no :=  20;
      BEGIN
         SELECT 'Y'
         INTO   x_result
         FROM   BOM_BILL_OF_MATERIALS     BOM,
                BOM_INVENTORY_COMPONENTS  BIC,
                MTL_SYSTEM_ITEMS          MTL
         WHERE  BOM.Assembly_item_id   =  pInventory_item_id
         AND    BOM.Organization_id    =  pOrg_id
         AND    BOM.Bill_sequence_id   =  BIC.Bill_sequence_id
         AND    BIC.Bom_item_type      =  4       ---   Standard item
         AND    BIC.WIP_SUPPLY_TYPE    <> 6       ---   Non Phantom
         AND    MTL.Inventory_item_id  =  BIC.Component_item_id
         AND    MTL.Organization_id    =  pOrg_id
         AND    MTL.Base_item_id       Is Not Null  -- This condition tells this is a config item.
         AND    rownum                 =  1;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Is_item_ML_OR_MO: ' || 'This config line is not multi level ...',3);
        END IF;
        X_result := 'N';
      END;
   ELSE  --- If the model is sourced

      x_result := 'Y';

   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Is_item_ML_OR_MO: ' || 'Expected error in Is_item_ML_OR_MO : Last statement executed is ...'||to_char(l_Stmt_no),1);
      END IF;
      CTO_MSG_PUB.count_and_get(p_msg_count  => X_Msg_Count,
				p_msg_Data   => X_Msg_Data);
      x_return_status := FND_API.G_RET_STS_ERROR;


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Is_item_ML_OR_MO: ' || 'UnExpected error in Is_item_ML_OR_MO : Last statement executed is ...'||to_char(l_Stmt_no),1);
      END IF;
      CTO_MSG_PUB.count_and_get(p_msg_count => X_Msg_Count,
                                p_msg_Data  => X_Msg_Data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


   WHEN OTHERS THEN

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Is_item_ML_OR_MO: ' || 'OTHER excpn in Is_item_ML_OR_MO : Last statement executed is ...'||to_char(l_Stmt_no),1);

      	oe_debug_pub.add('Is_item_ML_OR_MO: ' || 'The error message is ..'||sqlerrm,2);
      END IF;
      X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Is_item_ML_OR_MO;



/*******************************************************************************************************
*      The below is the local procedure
********************************************************************************************************/

PROCEDURE Pto_Ato_Config_Wrapper(
                                Pchgtype          IN   change_table_type,
                                x_return_status   OUT NOCOPY varchar2,
                                X_Msg_count       OUT NOCOPY Number,
                                X_Msg_data        OUT NOCOPY Varchar2) IS

   TYPE PROCESS_SET IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
   l_chgtype        CTO_CHANGE_ORDER_PK.change_table_type;
   l_ato_line_id    OE_ORDER_LINES_ALL.ATO_LINE_ID%TYPE;
   l_process_set    PROCESS_SET;
   l_Stmt_no        Number ;
   i                Number;
   l_item_type_code OE_ORDER_LINES_ALL.item_type_code%type ; /* BUG#1874380 */

BEGIN

   l_Stmt_no  := 10;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Entering Procedure Pto_Ato_Config_Wrapper....',1);
   END IF;

   i := pchgtype.FIRST;
   LOOP

      -- Select the ATO line id from Database to determine the TOP level ATO
      l_stmt_no := 20;

      SELECT Ato_line_id ,
             item_type_code /* BUG#1874380 */
      INTO   l_ato_line_iD,
             l_item_type_code /* BUG#1874380 */
      FROM   OE_ORDER_LINES_ALL
      WHERE  line_id = Pchgtype(i).old_value;

      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'The line_id = '||Pchgtype(i).old_value||' ATO line id ='||l_ato_line_id,3);
      END IF;


      IF l_ato_line_id is null THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'The line id ='||Pchgtype(i).old_value||' Belongs to PTO-- Ignore',5);
         END IF;

      -- Removed the condition for bug fix  1874380

      ELSIF (l_ato_line_id =  Pchgtype(i).old_value)
             and ((l_item_type_code = 'OPTION')
	     --Adding INCLUDED item type code for SUN ER#9793792
	           OR (l_item_type_code = 'INCLUDED')) then
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Ato_line_id = '|| to_char( l_ato_line_id) ||
                          ' item type code ' || l_item_type_code ||
                          ' Is an ATO ITEM under PTO Model, should be ignored..',5);
         END IF;

      ELSIF  l_process_set.exists(l_ato_line_id)  THEN
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Ato_line_id = '||l_ato_line_id||' Is already processed...',5);
         END IF;

      ELSIF CTO_WORKFLOW.config_line_exists(l_ato_line_id) = TRUE THEN

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Ato line_id = '||l_ato_line_id||' is having config item..',5);

         	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Calling main procedure Change_Notify...',5);
         END IF;

         l_chgtype(1).change_type := CTO_CHANGE_ORDER_PK.CONFIG_CHANGE;
         l_stmt_no := 30;
         CTO_CHANGE_ORDER_PK.change_notify(
                                            PLineid          => l_ato_line_id,
                                            Pchgtype         => l_chgtype,
                                            X_return_status  => X_return_status,
                                            X_Msg_count      => X_Msg_Count,
                                            X_Msg_Data       => X_Msg_Data);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Expected error in change_notify procedure....',3);
            END IF;
            raise FND_API.G_EXC_ERROR;

         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Unexpected error occurred in change_notify...',3);
            END IF;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_process_set(l_ato_line_id) := l_ato_line_id;
      ELSE

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'This lines top model ato does not have config line...ignore',3);
         END IF;
         l_process_set(l_ato_line_id) := l_ato_line_id;

      END IF;

      EXIT WHEN i = pchgtype.LAST;

      i := pchgtype.NEXT(i);
   END LOOP;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status :=  FND_API.G_RET_STS_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Expected error in Pto_Ato_Config_Wrapper. Last stmt executed is ..'||to_char(l_stmt_no),2);
     END IF;
     CTO_MSG_PUB.count_and_get(p_msg_count  => X_Msg_Count,
                               p_msg_Data   => X_Msg_Data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'UnExpected error in Pto_Ato_Config_Wrapper. Last stmt executed is ..'||to_char(l_stmt_no),2);
     END IF;
     CTO_MSG_PUB.count_and_get(p_msg_count  => X_Msg_Count,
                               p_msg_Data   => X_Msg_Data);

  WHEN OTHERS THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'OTHERS excpn in Pto_Ato_Config_Wrapper. Last stmt executed is ..'||to_char(l_stmt_no),2);

     	oe_debug_pub.add('Pto_Ato_Config_Wrapper: ' || 'Error Message is : '||sqlerrm);
     END IF;
     CTO_MSG_PUB.count_and_get(p_msg_count  => X_Msg_Count,
                               p_msg_Data   => X_Msg_Data);
END Pto_Ato_Config_Wrapper;



-- rkaza. ireq project. 05/11/2005. Helper function to do existence check on
-- req interface table.
Function req_interface_rec_exists(p_line_id IN Number,
                                  p_item_id IN Number,
			   	  x_return_status OUT NOCOPY varchar2)
return boolean is

l_req_exists    varchar2(1) := 'N';

Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

Select 'Y' into	l_req_exists
From po_requisitions_interface_all
Where interface_source_line_id = p_line_id
and item_id = p_item_id
and process_flag is null;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('req_interface_rec_exists: ' || 'interface record exists for the line', 5);
END IF;

return TRUE;

Exception

when no_data_found then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('req_interface_rec_exists: ' || 'interface record does not exist for the line', 1);
   END IF;
   return FALSE;

when others then
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('req_interface_rec_exists: ' || 'When others exception ..' || sqlerrm, 1);
   END IF;
   return FALSE;

End req_interface_rec_exists;



-- rkaza. ireq project. 05/11/2005. Helper procedure to do delete a record from
-- req interface table.
-- Start of comments
-- API name : delete_from_req_interface
-- Type	    : Public
-- Pre-reqs : None.
-- Function : Given orer line id, it deletes the corresponding req interface
--	      records.
-- Parameters:
-- IN	    : p_line_id           	IN NUMBER	Required
--	         order line id.
-- IN	    : p_item_id           	IN NUMBER	Required
-- Version  :
--	      Initial version 	115.20
-- End of comments
Procedure delete_from_req_interface(p_line_id IN Number,
				    p_item_id IN Number,
			   	    x_return_status OUT NOCOPY varchar2) is

Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

Delete from po_requisitions_interface_all
Where interface_source_line_id = p_line_id
and item_id = p_item_id;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('delete_from_req_interface: ' || 'Processed interface record deletion. exiting...', 5);
END IF;

Exception

when FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('delete_from_req_interface: ' || 'expected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;

when FND_API.G_EXC_UNEXPECTED_ERROR then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('delete_from_req_interface: ' || 'unexpected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

when others then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('delete_from_req_interface: ' || 'When others exception ..' || sqlerrm, 1);
   END IF;
   x_return_status := fnd_api.g_ret_sts_unexp_error;

End delete_from_req_interface;



-- rkaza. ireq project. 05/11/2005. Helper procedure to update a record in
-- req interface table. It can update qty and need by date. It will only update
-- these fields if they are being updated to a non null value. Otherwise, old
-- value in the table is retained for that field.
-- Also, it will simply return if both qty and date are null. Nothing to update

Procedure update_req_interface_rec(p_line_id IN Number,
				   p_item_id IN Number,
				   p_qty IN Number default null,
                                   p_qty2 IN Number default null,
				   p_need_by_date IN date default null,
			   	   x_return_status OUT NOCOPY varchar2) is

Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('update_req_interface_rec: ' || 'Values passed in are as follows: ', 5);
   oe_debug_pub.add('update_req_interface_rec: ' || 'p_line_id = ' || p_line_id, 5);
   oe_debug_pub.add('update_req_interface_rec: ' || 'p_qty = ' || p_qty, 5);
   oe_debug_pub.add('update_req_interface_rec: ' || 'p_need_by_date = ' || p_need_by_date, 5);
END IF;

if p_qty is null and p_qty2 is null and p_need_by_date is null  then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('update_req_interface_rec: ' || 'Both qty and date are null. Nothing to update. Simply returning ', 5);
   end if;
   return;
end if;

Update po_requisitions_interface_all
Set quantity = nvl(p_qty, quantity),
    secondary_quantity = nvl(p_qty2, secondary_quantity), --OPM
    need_by_date = nvl(p_need_by_date, need_by_date)
Where interface_source_line_id = p_line_id
and item_id = p_item_id;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('update_req_interface_rec: ' || 'Processed interface record update. Exiting...', 5);
END IF;

Exception

when others then
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('update_req_interface_rec: ' || 'When others exception ..' || sqlerrm, 1);
   END IF;

End update_req_interface_rec;



-- rkaza. ireq project. 05/12/2005. Returns open demand given line_id and
-- current order qty. Open demand = current order qty - (sum of all
-- reservations + flow qty). Reservations include int reqs too now.

Procedure get_open_demand(p_line_id IN Number,
			  p_order_qty IN Number,
			  p_order_qty2 IN Number,           --opm
			  x_open_demand OUT NOCOPY number,
			  x_open_demand2 OUT NOCOPY number, --opm
			  x_return_status OUT NOCOPY  varchar2) is

lStmtNumber number := 10;
l_source_doc_type_id number;
l_rsv_rec_tbl CTO_UTILITY_PK.resv_tbl_rec_type;
l_resv_code varchar2(10);
l_sum_rsv_qty number;
l_msg_count number;
l_msg_data varchar2(2000);
l_supply_qty number := 0;
i binary_integer;

--OPM
l_supply_qty2 number := 0;
k number;

l_prim_uom_code mtl_reservations.primary_uom_code%TYPE;


Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('get_open_demand: ' || 'Values passed in are as follows: ', 5);
   oe_debug_pub.add('get_open_demand: ' || 'p_line_id = ' || p_line_id, 5);
   oe_debug_pub.add('get_open_demand: ' || 'p_order_qty = ' || p_order_qty, 5);
   oe_debug_pub.add('get_open_demand: ' || 'p_order_qty2 = ' || p_order_qty2, 5);
END IF;



lStmtNumber := 20;
l_source_doc_type_id := CTO_UTILITY_PK.get_source_document_id (
			   pLineId => p_line_id );



lStmtNumber := 30;
-- This procedure returns the supply qty available for the line for each supply
-- type.
     CTO_UTILITY_PK.Get_Resv_Qty
               (
		 p_order_line_id     => p_line_id,
		 x_rsv_rec           => l_rsv_rec_tbl,
		 x_primary_uom_code  => l_prim_uom_code,
		 x_sum_rsv_qty	     => l_sum_rsv_qty,
                 x_return_status     => x_return_status,
		 x_msg_count	     => l_msg_count,
                 x_msg_data	     => l_msg_data
	        );

if x_return_status <> fnd_api.g_ret_sts_success then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_open_demand: ' || 'exception from get_resv_qty_and_code call', 1);
   END IF;
   raise fnd_api.g_exc_unexpected_error;
end if;



lStmtNumber := 40;

-- sum up the following supply quantities.
-- PO, WIP, INV, Ext Req, Int Req, Flow.

IF p_order_qty IS NOT NULL THEN

   IF l_rsv_rec_tbl.count<>0 THEN

       i := l_rsv_rec_tbl.first;
       LOOP
           if i not in
              (CTO_UTILITY_PK.g_source_type_ext_req_if,
               CTO_UTILITY_PK.g_source_type_int_req_if) then

               l_supply_qty := l_supply_qty +
	                    l_rsv_rec_tbl(i).primary_reservation_quantity;

            end if; --i not in g_source_type_ext_req_if, g_source_type_int_req_if,

            Exit When i= l_rsv_rec_tbl.last;

            i := l_rsv_rec_tbl.next(i);

        END LOOP;--LOOP

   END IF; /*l_rsv_rec_tbl.count<>0*/

   x_open_demand := p_order_qty - l_supply_qty;

   if x_open_demand <= 0 then
     x_open_demand := 0;
   end if; --x_open_demand

END IF; --p_order_qty

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('get_open_demand: ' || 'supply qty = ' || l_supply_qty, 1);
   oe_debug_pub.add('get_open_demand: ' || 'open_demand = ' || x_open_demand, 1);
END IF;

--OPM

IF p_order_qty2 IS NOT NULL THEN

  IF l_rsv_rec_tbl.count<>0 THEN

     k := l_rsv_rec_tbl.first;
     LOOP
        if k not in
         (CTO_UTILITY_PK.g_source_type_ext_req_if,
          CTO_UTILITY_PK.g_source_type_int_req_if) then

           l_supply_qty2 := l_supply_qty2 +
	                    l_rsv_rec_tbl(k).secondary_reservation_quantity;

        end if; --i not in g_source_type_ext_req_if, g_source_type_int_req_if,

        Exit When k= l_rsv_rec_tbl.last;

        k := l_rsv_rec_tbl.next(k);

     END LOOP;--LOOP

  END IF; /*l_rsv_rec_tbl.count<>0*/

  x_open_demand2 := p_order_qty2 - l_supply_qty2;

  if x_open_demand2 <= 0 then
     x_open_demand2 := 0;
  end if; --x_open_demand

END IF; --p_order_qty2


IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('get_open_demand: ' || 'supply qty2 = ' || l_supply_qty2, 1);
   oe_debug_pub.add('get_open_demand: ' || 'open_demand2 = ' || x_open_demand2, 1);
   oe_debug_pub.add('get_open_demand: ' || 'Processing done. exiting...', 5);
END IF;



Exception

WHEN FND_API.G_EXC_ERROR THEN
   x_return_status :=  FND_API.G_RET_STS_ERROR;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_open_demand: ' || 'Expected error. Last stmt executed is ..'|| to_char(lStmtNumber),1);
   END IF;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_open_demand: ' || 'UnExpected error. Last stmt executed is ..'|| to_char(lStmtNumber),1);
   END IF;

when others then
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_open_demand: ' || 'When others exception ..' || sqlerrm, 1);
   END IF;

End get_open_demand;



-- rkaza. ireq project. 05/11/2005. Introduced this procedure for processing
-- req interface records for buy and IR cases in change management.
-- this procedure is called from change_notify for buy or IR cases.

--modified the code for OPM project too to process Secondary quantity
--changes

PROCEDURE change_order_ato_req_item (
                p_config_line_id IN Number,
                p_config_id IN Number,
                p_org_id IN Number,
                p_source_type IN Number,
                p_req_change_details IN req_change_info,
                x_return_status OUT NOCOPY varchar2 ) is

l_inv_qty       NUMBER;
l_po_qty        NUMBER;
l_req_qty       NUMBER;
lStmtNumber     NUMBER;

l_req_exists boolean;
l_new_date date := null;
l_new_qty number := null;
l_new_qty2 number := null; --OPM

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('change_order_ato_req_item: ' || 'Inside procedure change_order_ato_req_item',5);
END IF;



-- interface record existence check.

lStmtNumber := 10;

l_req_exists := req_interface_rec_exists(p_line_id => p_config_line_id,
					 p_item_id => p_config_id,
			 		 x_return_status => x_return_status);

if x_return_status <> fnd_api.g_ret_sts_success then
   raise fnd_api.g_exc_unexpected_error;
end if;

if l_req_exists = FALSE then

   -- if no req record exists, no processing needed. just return.
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('change_order_ato_req_item: ' || 'Interface record does not exist. Nothing to update. Simply returning ', 5);
   end if;

   return;

end if;



-- for cancellation or config change or unschedule, delete interface record and
-- return.

lStmtNumber := 20;

if p_req_change_details.cancel_line_flag = TRUE or
   p_req_change_details.unschedule_action_flag = TRUE or
   p_req_change_details.config_change_flag = TRUE then

   delete_from_req_interface(p_line_id => p_config_line_id,
			     p_item_id => p_config_id,
			     x_return_status => x_return_status);

   if x_return_status <> fnd_api.g_ret_sts_success then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('change_order_ato_req_item: ' || 'Either cancel or unschedule or config change. Interface record deleted. Returning ', 5);
   end if;

   return;

end if;



-- for a date change get the new need by date depending on source type 1 or 3.

lStmtNumber := 30;

if p_req_change_details.date_change_flag = TRUE then

   cto_auto_procure_pk.get_need_by_date(
      p_source_type => p_source_type,
      p_item_id => p_config_id,
      p_org_id => p_org_id,
      p_schedule_ship_date => p_req_change_details.new_ssd_date,
      x_need_by_date => l_new_date,
      x_return_status => x_return_status);

   if x_return_status <> fnd_api.g_ret_sts_success then
      raise fnd_api.g_exc_unexpected_error;
   end if;

end if;



-- for a qty change get the new open demand. Open demand is new order qty -
-- sum of reservations - flow quanity.

--modified the code for secondary quantity change for OPM.
--decision was made to use same API inorder minimize the db hit
--on mtl_reservations table when the primary and sec qty change in
--a single session

lStmtNumber := 40;

if p_req_change_details.qty_change_flag = TRUE
    OR
   p_req_change_details.qty2_change_flag = TRUE --OPM
    then

   get_open_demand(
      p_line_id => p_config_line_id,
      p_order_qty => p_req_change_details.new_order_qty,
      p_order_qty2=> p_req_change_details.new_order_qty2,--for OPM
      x_open_demand => l_new_qty,
      x_open_demand2 => l_new_qty2,--for OPM
      x_return_status => x_return_status);

   if x_return_status <> fnd_api.g_ret_sts_success then
      raise fnd_api.g_exc_unexpected_error;
   end if;

   if l_new_qty = 0 then

      delete_from_req_interface(p_line_id => p_config_line_id,
				p_item_id => p_config_id,
			        x_return_status => x_return_status);

      if x_return_status <> fnd_api.g_ret_sts_success then
         raise fnd_api.g_exc_unexpected_error;
      end if;

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('change_order_ato_req_item: ' || 'No Open demand. Interface record deleted. Returning ', 5);
      end if;

      return;

   end if;

end if;



lStmtNumber := 50;
-- Update req interface if needed for new req qty and new need by date.
update_req_interface_rec(p_line_id => p_config_line_id,
			 p_item_id => p_config_id,
		         p_qty => l_new_qty,
			 p_qty2 => l_new_qty2,
		         p_need_by_date => l_new_date,
			 x_return_status => x_return_status);

if x_return_status <> fnd_api.g_ret_sts_success then
   raise fnd_api.g_exc_unexpected_error;
end if;



IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('change_order_ato_req_item: ' || 'Processing done. Exiting ', 5);
end if;



EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status :=  FND_API.G_RET_STS_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('change_order_ato_req_item: ' || 'Expected error. Last stmt executed is ..'|| to_char(lStmtNumber),1);
     END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('change_order_ato_req_item: ' || 'UnExpected error. Last stmt executed is ..'|| to_char(lStmtNumber),1);
     END IF;

  WHEN OTHERS THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('change_order_ato_req_item: ' || 'OTHERS excpn. Last stmt executed is ..'|| to_char(lStmtNumber),1);
     	oe_debug_pub.add('change_order_ato_req_item: ' || 'Error Message is : '|| sqlerrm, 1);
     END IF;

END CHANGE_ORDER_ATO_REQ_ITEM;




END CTO_CHANGE_ORDER_PK;

/
