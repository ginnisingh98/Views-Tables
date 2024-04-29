--------------------------------------------------------
--  DDL for Package Body CTO_CONFIG_BOM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CONFIG_BOM_PK" as
/* $Header: CTOCBOMB.pls 120.15.12010000.11 2012/02/22 14:41:22 ntungare ship $ */

/*============================================================================
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : CTOCBOMB.pls
| DESCRIPTION :
|               This file creates a packaged function that loads the
|               BOM tables for the config item. Converted from BOMLDCBB.pls
|               for CTO streamline for new OE
| HISTORY     : created   09-JUL-1999   by Usha Arora
|
|		ksarkar   12-JUN-01   Bugfix 1653881
|               single row subquery of ic1.component_sequence_id returns more than
|		one rows when same component is used more than once in a given
|		assembly.
|               We do not need to select component_sequence_id through a subquery.
|      		The bill_sequence_id of the option class and join condition
|		ic1.component_item_id  =  bcol1.inventory_item_id will select unique components
|		for the option class.
|
|               ksarkar   01-JUN-01   Bugfix 1812159
|               Date operations make a disabled item effective and increases the
|		component usage in configured item.
|
|		sbhaskar  16-JUN-01   Bugfix 1835357
|               Replaced fnd_file calls with oe_debug_pub
|
|               ksarkar   19-JUL-01   Bugfix 1845141
|               mtl_system_items_tl is not getting updated with correct description .
|		Added message in lines 1486-87 and 1669-70 for better understanding of
|		"WHEN OTHERS" exception .
|
|               ksarkar   19-JUL-01   Bugfix 1876998
|               Remove semicolon from comment to improve performance.
|
|               Modified on 24-AUG-2001 by Sushant Sawant: BUG #1957336
|                                         Added a new functionality for preconfigure bom.
|
|               ksarkar   13-NOV-01   Bugfix 2086234
|               Add condition "Implementation_date is not null" in Inherit_op_seq_ml
|
|               ksarkar   26-NOV-01   Bugfix 2115056
|               Copy base model attributes ( DFF's) to configured item.
|
|               ksarkar   04-JAN-02   Bugfix 2171807 ( Bugfix 2163311 in main )
|               Catalog description is not getting updated in Master Org.
|
|               sbhaskar  07-FEB-02   Bugfix 2215274  (bugfix 2221008 in main)
|               Performance : Replaced bind variables with column join.
|
|               ksarkar  21-FEB-02   Bugfix 2222518    (bugfix 2236844 in main )
|               Option Class operation seq not getting inherited to child
|		included items.
|
|               ksarkar  28-FEB-02   Bugfix 2244856    (bugfix 2246663 in main )
|               Unable to handle no_data_found error
|
|               ksarkar  09-APR-02   Bugfix 1912376    (bugfix 2292468 in main )
|               Checking item effectivity till schedule ship date
|
|               ksarkar  17-MAY-02   Bugfix 2307936    (bugfix 2379051 in main )
|               New logic of operation seq inheritence
|
|               ssawant   28-MAY-02   Bugfix 2312199 (Refix for bug1912376 )
|               bug 1912376 could still fail in case of sourced lower level models
|
|               ksarkar   04-JUN-02   Bugfix 2374246 (Bugfix 2402935 in main )
|               Config item created with no BOM
|
|               ksarkar   04-JUN-02   Bugfix 2389283  (Bugfix 2402935 in main )
|		Included Item under a non-phantom sub model gets attached to top
|		model in config item bill.
|
|               ksarkar   26-JUN-02   Bugfix 2433862  ( Bugfix 2435855 in main )
|               Failed to insert rows with null op seq num in bom_inventory_components
|		when ATO under PTO has no routing but inherit_op_seq profile is
|		set to YES.
|
|               ksarkar   10-OCT-02   Bugfix 2590966  ( Bugfix 2618752 in main )
|               Catalog descriptions not rolled up correctly for multi -level
|		configurations.
|
|               ksarkar   21-NOV-02   Bugfix 2524562  ( Bugfix 2652271 in main )
|               Inconsistent use of order dates in validating BOM effectivity.
|
|               ksarkar   18-FEB-03   Bugfix 2765635  ( Bugfix 2807548 in main )
|               New custom hook for catalog description of multi-level model .
|
|               ksarkar   23-FEB-03   Bugfix 2814257  ( Bugfix 2817041 in main )
|               Fix for 2524562 not working when opseq profile is turned ON.
|
|               ksarkar   02-JUL-03   Bugfix 2929861  ( Bugfix 2986192 in main )
|               Config item creation will now depend upon the  value of
|		profile BOM:CONFIG_EXCEPTION
|
|               Modified on 14-MAR-2003 By Sushant Sawant
|                                         Decimal-Qty Support for Option Items.
|
|               ksarkar   20-NOV-03   Bugfix 3222932
|               Inserting actual eff and disable dates for config components
|		New consolidation logic
|
|
|               ssawant   09-JAN-04   Bugfix 3358160
|               Error Message Added CTO_ZERO_BOM_COMP for option item with zero qty on config bom.
|
|
|               ssawant   15-JAN-04   Bugfix 3374548
|               Added bill_sequence_id to condition to avoid corrupt data from bom_inventory_comps_interface.
|
|
|               ssawant   29-JAN-04   Bugfix 3367823
|               Accounted for UOM conversion in bom_inventory_components.
|
|
|               ssawant   05-FEB-04   Bugfix 3389846
|               Accounted for disable date greater than EstRelDate, sysdate
|
|               ssawant   05-FEB-04   Bugfix 3389846
|               Accounted for disable date greater than EstRelDate, sysdate. Disable date clause has been changed to compare
|               only if it is not null. This improves the query as well.
|
|
|              Modified on 26-Mar-2004 By Sushant Sawant
|                                         Fixed Bug#3484511
|                                         all queries referencing oe_system_parameters_all
|                                         should be replaced with a function call to oe_sys_parameters.value
|
|               Modified   :  21-JUN-2004 Sushant Sawant
|                                         Fixed bug 3710032.
|                                         Substitute components were not copied correctly.
|
|
|               Modified   :  12-AUG-2004 Sushant Sawant
|                                         Fixed bug 3793286.
|                                         Front Ported bug 3674833
|
|
|               Modified   :  13-AUG-2004 Kiran Konada
|                                         bug fix 3759118,FP 3810243
|                                         Added implemenation_date to BOM_BOM
|                                         as sysdate
|
|               Modified   :  11-05-2004  Kiran Konada
|                                         Fixed issue with bug 3793286.(Front Ported bug 3674833)
|                                         added abs() in where clause as model_comp_seq in
|                                         pl/sql record was a -ve value
|
|
|
|               Modified   :  12-08-2004  Sushant Sawant
|                                         Fixed issue for bug 3793286
|                                         commented "IF prev_comp_item_id <> component_item_id_arr(x1) then"
|                                         This bug was not fixed properly for components with
|                                         multiple effectivity date windows.
|
|
|              Modified   :  02-02-2005   Kiran Konada
|                                         bug#4092184 FP:11.5.9 - 11.5.10 :I
|                                          customer bug#4081613
|                                         if custom package CTO_CUSTOM_CATALOG_DESC.catalog_desc_method is
|                                         set to 'C' to use custom api AND if model item is not assigned
|                                         to a catalog group. Create configuration process fails
|
|                                         Fix has been made not to honor the custom package if a ato model
|                                         is not assigned to a catalog gtroup or there are no descrptive elements
|                                         defined for a catalog group. In fumction create_bom_data_ml
|
|
|               Modified   :  01-APR-2005 Sushant Sawant
|                                         Fixed issue for bug4271269.
|                                         populate structure_type_id and effectivity_control columns in
|                                         bom_bill_of_materials view.
|
|               Modified by Renga Kannan on 09/01/06 for bug 4542461
|		Modified  : 09-02-2005    Renga Kannan
|                                         Fixed the following issues in LBM and effecitivity
|                                         part of code
|
|                                         1.) LBM code does not handle null value for basis type
|                                         Added nvl clause for all insert stmt from bom_inventory_components
|                                         to bom_inventory_components_interface
|
|                                          2.) for overlapping effectivity dates with components having
|                                              having different basis type the message is not raised
|                                              properly. fixd that code
|
|                                          3.) Clubbing component code is inserting null qty value into
|                                              bic interface. Fixed the code not to insert these rows.
|
|		Modified by Renga Kannan on 09/07/2005
|                           Bug Fix 4595162
|                           Modified the code that populates basis type to
|                           bom_inventory_components table. As per bom team
|                           basis_type should have null for 'ITEM' and 2 for 'LOT'
|
|
*============================================================================*/

-- Bug 1912376 Declaring Global variable to hold the value of Schedule Ship Date

g_SchShpDate            Date;

-- Bug 2222518 Declaring Global variable to hold the value of Estimated Release Date

g_EstRelDate		Date;

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

-- 3222932 setting global replacement of null disable dates

g_futuredate            DATE := to_date('01/01/2099 00:00:00','MM/DD/YYYY HH24:MI:SS');



-- 4271269 populate structure_type_id in bom.

g_structure_type_id    bom_bill_of_materials.structure_type_id%type ;


PROCEDURE update_item_num(
	p_parent_bill_seq_id IN NUMBER,
	p_item_num IN OUT NOCOPY NUMBER,  /* NOCOPY project */
	p_org_id IN NUMBER,
	p_seq_increment IN NUMBER);

function create_bom_ml (
    pModelId        in       number,
    pConfigId       in       number,
    pOrgId          in       number,
    pLineId         in       number,
    xBillId         out NOCOPY     number,
    xErrorMessage   out NOCOPY      varchar2,
    xMessageName    out NOCOPY      varchar2,
    xTableName      out NOCOPY     varchar2)
return integer
is

   lStmtNum  		number;
   lCnt            	number := 0;
   lConfigBillId   	number;
   lstatus	        number;
   lEstRelDate     	date;
   lOpseqProfile   	number;
   lItmBillID      	number;
   lLineId         	number;
   lModelId        	number;
   lParentAtoLineId 	number := pLineId;
   lOrderedQty     	number;
   lLeadTime       	number;
   lErrBuf         	varchar2(80);
   lTotLeadTime    	number := 0;
   lOEValidationOrg 	number;

   v_ato_line_id     	bom_cto_order_lines.ato_line_id%type ;
   v_program_id      	bom_cto_order_lines.program_id%type ;

   /* 2524562 Declaring variables */

   v_missed_line_id		number;
   v_missed_item		varchar2(50);
   v_config_item		varchar2(50);
   v_model			varchar2(50);
   v_missed_line_number		varchar2(50);
   v_order_number		number;
   l_token			CTO_MSG_PUB.token_tbl;
   lcreate_item			number;		-- 2986192
   lorg_code			varchar2(3);	-- 2986192

   /* Cursor to select dropped lines */
   cursor missed_lines ( 	xlineid		number,
   				xconfigbillid	number,
                                xEstRelDate     date ) is    /* Effectivity_date changes */
   select line_id
   from bom_cto_order_lines
   where parent_ato_line_id=xlineid
   and parent_ato_line_id <> line_id 	/* to avoid selecting top model */
   minus
   select revised_item_sequence_id 	/* new column used to store line_id */
   from bom_inventory_comps_interface
   where bill_sequence_id = xconfigbillid
   and greatest(sysdate, xEstRelDate ) >= effectivity_date
   and (( disable_date is null ) or ( disable_date is not null and  greatest(sysdate, xEstRelDate) <= disable_date )) ;

   /* 2524562 End declaration */


  v_zero_qty_count      number ;

  v_option_num          number := 0 ;

  l_new_line  varchar2(10) := fnd_global.local_chr(10);

   l_aname                      wf_engine.nametabtyp;
   l_anumvalue                  wf_engine.numtabtyp;
   l_atxtvalue                  wf_engine.texttabtyp;
   luser_key                    varchar2(100);
   litem_key                    varchar2(100);
   lplanner_code                mtl_system_items_vl.planner_code%type;

   v_problem_model     varchar2(1000) ;
   v_problem_config    varchar2(1000) ;
   v_error_org         varchar2(1000) ;
   v_problem_model_line_num  varchar2(1000) ;

   v_table_count       number ;

  v_dropped_item_string   varchar2(2000) ;
  v_sub_dropped_item_string   varchar2(2000) ;
  v_ac_message_string   varchar2(2000) ;

   -- 3222932 setting replacement of null disable dates

   g_futuredate         DATE := to_date('01/01/2099','MM/DD/YYYY');


  v_header_id           oe_order_lines_all.header_id%type ;


  l_return_status      varchar2(10) ;
  l_msg_count         number ;
  l_msg_data          varchar2(2000) ;


  v_recipient         varchar2(100) ;

  l_token1	      CTO_MSG_PUB.token_tbl;
  v_model_item_name   varchar2(2000) ;



  v_overlap_check  number := 0 ;

  TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  v_t_overlap_comp_item_id  num_tab;
  v_t_overlap_src_op_seq_num num_tab;
  v_t_overlap_src_eff_date   date_tab;
  v_t_overlap_src_disable_date date_tab;
  v_t_overlap_dest_op_seq_num  num_tab;
  v_t_overlap_dest_eff_date    date_tab;
  v_t_overlap_dest_disable_date date_tab;


--- Renga

    cursor Debug_cur is
           select assembly_item_id,component_item_id,operation_seq_num,max(disable_date) disable_date
	   from   bom_inventory_comps_interface
	   where  bill_sequence_id = lconfigbillid
	   group by assembly_item_id,component_item_id,operation_seq_num;

--- End Renga
/* END : New Effectivity date approach for  bug 4147224 */

     cursor debug_cur1 is
     select component_item_id,component_sequence_id,operation_seq_num,effectivity_date,disable_date
     from bom_inventory_comps_interface
     where bill_sequence_id = lConfigBillId  --Bugfix 6603382: So that components belonging to this bill only are picked up
     order by component_item_id,operation_seq_num,effectivity_Date,disable_date;
  l_token2	      CTO_MSG_PUB.token_tbl;
  l_model_name        varchar2(1000);

  test_var            number;  --Bug 7418622.FP for 7154767

BEGIN

   /*------------------------------------------+
     If the BOM exists, we do not need to do
     anything. return with success.
     This can happen because we allow delay
     between 'create Item' and 'Create BOM'
     workflow activities. A higher priority
     order with matching configuration may
     have created the BOM.
   +------------------------------------------*/
   xBillId    := 0;
   lStmtNum   := 10;

   lStatus := check_bom (pConfigId, pOrgId,lItmBillId);
   if lStatus = 1  then
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('create_bom_ml: ' ||  ' Config BOM ' || lItmBillId || ' Already exists ' ,1);
      END IF;
      return (1);
   end if;

  /*-------------------------------------------+
    BOM does not exist, so we need to create it
    get the bill_sequence_id to be used.
  +--------------------------------------------*/
   lStmtNum   := 20;


   /* BUG #1957336 Change for preconfigure bom */

   select ato_line_id, program_id , header_id
   into   v_ato_line_id, v_program_id , v_header_id
   from   bom_cto_order_lines
   where  line_id = pLineId ;


   /* BUG #1957336 Change for preconfigure bom */

   if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID AND
      v_ato_line_id = pLineId  and pOrgId = CTO_UTILITY_PK.PC_BOM_CURRENT_ORG ) then

      lConfigBillId := CTO_UTILITY_PK.PC_BOM_BILL_SEQUENCE_ID  ;

   	oe_debug_pub.add('create_bom_ml: ' || 'Setting Bill  ' || lConfigBillId || ' for org ' || pOrgId
                                            || ' for line id ' || pLineId , 1);
   else

        select bom_inventory_components_s.nextval
        into lConfigBillId
        from dual;

   end if ;

   xBillId := lConfigBillId;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_ml: ' || 'Creating Bill ' || lConfigBillId, 1);
   END IF;



   /* Added for avoiding bad data during preconfig bom scenario or any data that could interfere with bom creation */
   delete from bom_inventory_comps_interface where bill_sequence_id = lConfigBillId ;


   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_ml: ' || 'deleted from bici ' || to_char(sql%rowcount) , 1);
   END IF;






   -- Start Bugfix 1912376

  /*-------------------------------------------+
    Selecting Schedule_ship_date of ATO Model and assigning
    this to a Global variable
  +--------------------------------------------*/
  lStmtNum   := 21;

  select nvl(schedule_ship_date,sysdate)
  into g_SchShpDate
  from bom_cto_order_lines
  where line_id         =       pLineId ;
   -- and ship_from_org_id  =       pOrgId ** bugfix 2312199 **
  /* commented line as part of bugfix 2312199, the bug 1912376 was not fixed
  ** properly, the bugfix will not work in case of sourced lower level models
  ** and hence this line needs to be commented as part of bug 2312199
  */


  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('create_bom_ml: ' || 'Line Id ' || pLineId ||' has Schedule Ship Date of '||g_SchShpDate, 2);
  END IF;

  -- End Bugfix 1912376

  -- Bugfix 1912376 : Change the position of lead time calculation

  -- New Estimated Release Date for Multilevel ATO
   lStmtNum := 40;

   -- get oevalidation org
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_ml: ' ||  'Before getting validation org', 2);
   END IF;


   /* BUG #1957336 Change for preconfigure bom */

   if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
       lOEValidationOrg := CTO_UTILITY_PK.PC_BOM_VALIDATION_ORG ;
   else
       /*
       BUG:3484511
       -----------
       select   nvl(master_organization_id,-99)		--bugfix 2646849: master_organization_id can be 0
         into   lOEValidationOrg
         from   oe_order_lines_all oel,
                oe_system_parameters_all ospa
         where  oel.line_id = pLineid
           and  nvl(oel.org_id, -1) = nvl(ospa.org_id, -1) --bug 1531691
           and  oel.inventory_item_id = pModelId;
       */


           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_bom_ml: ' ||  'Going to fetch Validation Org ' ,2);
           END IF;


           select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
              into lOEValidationOrg from oe_order_lines_all oel
           where oel.line_id = pLineId ;


   end if ;

   if (lOEValidationOrg = -99) then			--bugfix 2646849
      cto_msg_pub.cto_message('BOM','CTO_VALIDATION_ORG_NOT_SET');
      raise FND_API.G_EXC_ERROR;
   end if;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_ml: ' ||  'Validation Org is :' ||  lOEValidationOrg,2);
   END IF;

   lStmtNum := 41;

   loop
     select bcol.line_id, bcol.inventory_item_id, bcol.parent_ato_line_id,
            bcol.ordered_quantity
     into   lLineId, lModelId, lParentAtoLineId, lOrderedQty
     from   bom_cto_order_lines bcol
     where  bcol.line_id = lParentAtoLineId;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('create_bom_ml: ' || 'lLineId: ' || to_char(lLineId), 2);
     	oe_debug_pub.add('create_bom_ml: ' || 'lModelId: ' || to_char(lModelId), 2);
     	oe_debug_pub.add('create_bom_ml: ' || 'lParentAtoLineId: ' || to_char(lParentAtoLineId), 2);
     END IF;

     lStmtNum := 42;
     lStatus := get_model_lead_time(
                          lModelId,
                          lOEValidationOrg,
                          lOrderedQty,
                          lLeadTime,
                          lErrBuf);

     if (lStatus = 0) then
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('create_bom_ml: ' || 'Failed in get_model_lead_time. Error Buffer : '||lERrBuf, 1);
         END IF;
         raise FND_API.G_EXC_ERROR;
     else
         lTotLeadTime := lLeadTime + lTotLeadTime;
     end if;

     exit when lLineId = lParentAtoLineId; -- when we reach the top model
   end loop;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_ml: ' || 'Total lead time is: ' || to_char(lTotLeadTime), 1);
   END IF;

   xTableName := 'OE_ORDER_LINES ';
   lStmtNum   := 43;

   begin		--Bugfix 2374246
   select CAL.CALENDAR_DATE
   into   lEstRelDate
   from   bom_calendar_dates cal,
          mtl_system_items   msi,
          bom_cto_order_lines   bcol,
          mtl_parameters     mp
   where  msi.organization_id    = pOrgId
   and    msi.inventory_item_id  = pModelId
   and    bcol.line_id            = pLineId
   and    bcol.inventory_item_id  = msi.inventory_item_id
   and    mp.organization_id     = msi.organization_id
   and    cal.calendar_code      = mp.calendar_code
   and    cal.exception_set_id   = mp.calendar_exception_set_id
   and    cal.seq_num =
       (select cal2.prior_seq_num - lTotLeadTime
        from   bom_calendar_dates cal2
        where  cal2.calendar_code    = mp.calendar_code
        and    cal2.exception_set_id = mp.calendar_exception_set_id
        and    cal2.calendar_date    = trunc(bcol.schedule_ship_date));
   -- Bugfix 2374246
   exception
   	when no_data_found then
             xErrorMessage := ' Error in calculating Estimated Release date ';
             xMessageName  := 'CTO_NO_CALENDAR';
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('create_bom_ml: ' || 'Error in stmt # ' || lStmtNum ||' : '|| xErrorMessage, 1);
             END IF;
             return(0);
    end;
-- Bugfix 2374246

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('create_bom_ml: ' || 'Estimated Release Date is : ' || lEstRelDate, 2);
   END IF;
   g_EstRelDate := lEstRelDate;		-- 2222518
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('create_bom_ml: ' || 'Global Estimated Release Date is : ' || g_EstRelDate, 2);
   END IF;		-- 2222518

   -- b2307936
  /*---------------------------------------------------------------------------+
  In new code , we will check op seq profile before insert into bic interface.
  If op seq = 1 , we will insert into bet and then to bic interface
  If op seq != 1 , we will do direct insert into bic interface
 +----------------------------------------------------------------------------*/
 /*-------------------------------------------------------------------------+
       Check profile option 'Inherit Operation_sequence_number'. If it is set
       to 'Yes', ensure that the childern default the operation sequence number
       from its parent, if not already assigned.
       Open : As in prev releases, this does not cover non-ATPable SMCs because
             they are not in oe_order_lines.  Do we need to ?
    +--------------------------------------------------------------------------*/

    lOpseqProfile := FND_PROFILE.Value('BOM:CONFIG_INHERIT_OP_SEQ');

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_bom_ml: ' || 'Config_inherit_op_seq is ' || lOpseqProfile, 2);
    END IF;

    lStmtNum := 80;
    if lOpseqProfile = 1 then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('create_bom_ml: ' || 'Calling inherit_op_seq_ml with line id ' ||
                        to_char(pLineId) || ' in org ' ||
                        to_char(pOrgId), 1);
       END IF;
       lStatus := inherit_op_seq_ml(pLineId, pOrgId,pModelId,lConfigBillId,xErrorMessage,xMessageName);
       if lStatus <> 1 then
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('create_bom_ml: ' || 'Failed in inherit_op_seq for line id: '|| to_char(pLineId), 1);
          END IF;
          return(0);
       end if;
    else
    -- e2307936

  /*-------------------------------------------+
     Load inventory components interface table
  +--------------------------------------------*/

  /*-----------------------------------------------------------+
     First:
     All the chosen option items/models/Classes  associated
     with the new configuration items will be loaded into the
     BOM_INVENTORY_COMPS_INTERFACE table.
  +-------------------------------------------------------------*/

  xTableName := 'BOM_INVENTORY_COMPS_INTERFACE';
  lStmtNum   := 30;

  -- rkaza. bug 4524248. bom structure import enhancements. Added batch_id

  insert into BOM_INVENTORY_COMPS_INTERFACE
      (
      operation_seq_num,
      component_item_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      item_num,
      component_quantity,
      component_yield_factor,
      component_remarks,
      effectivity_date,
      change_notice,
      implementation_date,
      disable_date,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      planning_factor,
      quantity_related,
      so_basis,
      optional,
      mutually_exclusive_options,
      include_in_cost_rollup,
      check_atp,
      shipping_allowed,
      required_to_ship,
      required_for_revenue,
      include_on_ship_docs,
      include_on_bill_docs,
      low_quantity,
      high_quantity,
      acd_type,
      old_component_sequence_id,
      component_sequence_id,
      bill_sequence_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      wip_supply_type,
      pick_components,
      model_comp_seq_id,
      supply_subinventory,
      supply_locator_id,
      bom_item_type,
      optional_on_model,	-- New columns for configuration
      parent_bill_seq_id,	-- BOM restructure project
      plan_level		-- Used by CTO only
      ,revised_item_sequence_id		/* 2524562 : New column added to store line_id */
      ,Assembly_item_id     /* Bug fix: 4147224 */
      , basis_type,           /* LBM project */
      batch_id
      )
  select
      nvl(ic1.operation_seq_num,1),
      decode(bcol1.config_item_id, NULL, ic1.component_item_id, -- new
                                              bcol1.config_item_id),
      SYSDATE,                            -- last_updated_date
      1,                                  -- last_updated_by
      SYSDATE,                            -- creation_date
      1,                                  -- created_by
      1,                                  -- last_update_login
      ic1.item_num,
      Round(
           CTO_UTILITY_PK.convert_uom( bcol1.order_quantity_uom, msi_child.primary_uom_code, bcol1.ordered_quantity , msi_child.inventory_item_id )
          / CTO_UTILITY_PK.convert_uom(bcol2.order_quantity_uom, msi_parent.primary_uom_code, NVL(bcol2.ordered_quantity,1) , msi_parent.inventory_item_id )
          , 7) ,  -- qty = comp_qty / model_qty /* Decimal-Qty Support for Option Items */
      ic1.component_yield_factor,
      ic1.component_remarks,                    --Bugfix 7188428
      --NULL,                               --ic1.component_remark
      -- 3222932 TRUNC(SYSDATE),          -- effective date
      -- 3222932 If eff_date > sysdate , insert eff_Date else insert sysdate
      decode(
       greatest(ic1.effectivity_date,sysdate),
       ic1.effectivity_date ,
       ic1.effectivity_date ,
       sysdate ),
      NULL,                               -- change notice
      SYSDATE,                            -- implementation_date
      -- 3222932 NULL,                    -- disable date
      nvl(ic1.disable_date,g_futuredate), -- 3222932
      ic1.attribute_category,
      ic1.attribute1,
      ic1.attribute2,
      ic1.attribute3,
      ic1.attribute4,
      ic1.attribute5,
      ic1.attribute6,
      ic1.attribute7,
      ic1.attribute8,
      ic1.attribute9,
      ic1.attribute10,
      ic1.attribute11,
      ic1.attribute12,
      ic1.attribute13,
      ic1.attribute14,
      ic1.attribute15,
      100,                                  -- planning_factor */
      2,                                    -- quantity_related */
      decode(bcol1.config_item_id, NULL,
                                        decode(ic1.bom_item_type,4,ic1.so_basis,2),
                                        2), -- so_basis */
      2,                                    -- optional */
      2,                                    -- mutually_exclusive_options */
      decode(bcol1.config_item_id, NULL,
                                        decode(ic1.bom_item_type,4, ic1.include_in_cost_rollup, 2),
                                        1), -- Cost_rollup */
      decode(bcol1.config_item_id, NULL, decode(ic1.bom_item_type,4, ic1.check_atp, 2),
                                        2), -- check_atp */
      2,                                    -- shipping_allowed = NO */
      2,                                    -- required_to_ship = NO */
      ic1.required_for_revenue,
      ic1.include_on_ship_docs,
      ic1.include_on_bill_docs,
      NULL,                                 -- low_quantity */
      NULL,                                 -- high_quantity */
      NULL,                                 -- acd_type */
      NULL,                                 --old_component_sequence_id */
      bom_inventory_components_s.nextval,   -- component sequence id */
      lConfigBillId,                        -- bill sequence id */
      NULL,                                 -- request_id */
      NULL,                                 -- program_application_id */
      NULL,                                 -- program_id */
      NULL,                                 -- program_update_date */
      ic1.wip_supply_type,
      2,                                    -- pick_components = NO */
      decode(bcol1.config_item_id, NULL, (-1)*ic1.component_sequence_id, ic1.component_sequence_id),           		-- saved model comp seq for later use. If config item, then saved model comp seq id as positive, otherwise negative.
      ic1.supply_subinventory,
      ic1.supply_locator_id,
      --ic1.bom_item_type
      decode(bcol1.config_item_id, NULL, ic1.bom_item_type, 4), -- new
      1,			--optional_on_model,
      ic1.bill_sequence_id,	--parent_bill_seq_id,
      (bcol1.plan_level-bcol2.plan_level)	--plan_level
      ,bcol1.line_id		/* 2524562 Storing line_id */
      ,bcol3.inventory_item_id  /* Bug fix: 4863055 */
      , nvl(ic1.basis_type,1),            /* LBM project */
      cto_msutil_pub.bom_batch_id
  from
    bom_inventory_components ic1,
    bom_cto_order_lines bcol1,                     --Option
    bom_cto_order_lines bcol2,                     -- Parent-Model
    bom_cto_order_lines bcol3,                     -- Parent-component
    mtl_system_items  msi_child ,
    mtl_system_items  msi_parent
    -- begin bugfix 1653881
  where  ic1.bill_sequence_id = (                 -- this we find the assembly  to which
        select common_bill_sequence_id           -- d1.component_seq_id belongs and then find
        from   bom_bill_of_materials bbm         -- bill for it in Mfg org.We find equivalent
        where  organization_id = pOrgId          -- compnent in this bill by joining
        and    alternate_bom_designator is null  -- on component_item_id. Each component
        and    assembly_item_id =(               --is assumed to be used at one operation only
            select distinct assembly_item_id     -- Operation_Seq_num must be same in bills in
            from   bom_bill_of_materials bbm1,   -- all organizations for that assembly
                   bom_inventory_components bic1
            where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
            and    component_sequence_id        = bcol1.component_sequence_id
            and    bbm1.assembly_item_id        = bcol3.inventory_item_id ))
  and ic1.component_item_id           = bcol1.inventory_item_id
  and msi_child.inventory_item_id = bcol1.inventory_item_id
  and msi_child.organization_id = pOrgId
  and msi_parent.inventory_item_id = bcol2.inventory_item_id
  and msi_parent.organization_id = pOrgId
  -- end bugfix 1653881
  -- begin bugfix 1912376
  -- and ic1.effectivity_date  <= g_SchShpDate  /* New Approach for Effectivity Dates  */
  and ic1.implementation_date is not null     --bug 4122212
  -- and NVL(ic1.disable_date, (lEstRelDate + 1)) >= greatest( nvl( lEstRelDate, sysdate ) , sysdate ) /* bug #3389846 */
  -- end bugfix 1912376
  and  ( ic1.disable_date is null or
         (ic1.disable_date is not null and  ic1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
  and      (( ic1.optional = 1 and ic1.bom_item_type = 4)
            or
	    ( ic1.bom_item_type in (1,2)))
  and     bcol1.ordered_quantity <> 0
  and     bcol1.line_id <> bcol2.line_id              -- not the top ato model
  and     bcol1.parent_ato_line_id = bcol2.line_id
  and     bcol1.parent_ato_line_id is not null
  and     bcol1.link_to_line_id is not null
  and     bcol2.line_id            = pLineId
  and     bcol2.ship_from_org_id   = bcol1.ship_from_org_id
  and     (bcol3.parent_ato_line_id  = bcol1.parent_ato_line_id
           or
           bcol3.line_id = bcol1.parent_ato_line_id)
					-- new condition to include parent model
                                              -- in a sub-assy since its
                                              -- ato_line_id is not equal
                                              -- to itself, unlike a top
                                              -- model.
  and     bcol3.line_id = bcol1.link_to_line_id;


    lCnt := sql%rowcount ;
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_bom_ml: ' || 'First -- Inserted ' || lCnt ||' rows into BOM_INVENTORY_COMPS_INTERFACE.',1);
    END IF;




   select count(*) into v_zero_qty_count from bom_inventory_comps_interface
    where bill_sequence_id = lConfigBillId  and component_quantity = 0 ;


   oe_debug_pub.add( 'MODELS: CHECK Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;

   if( v_zero_qty_count > 0 ) then

      oe_debug_pub.add( 'SHOULD Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;

        select concatenated_segments into v_model_item_name
          from mtl_system_items_kfv
        where inventory_item_id = pModelId
          and rownum = 1 ;


       l_token1(1).token_name  := 'MODEL_NAME';
       l_token1(1).token_value := v_model_item_name ;


      cto_msg_pub.cto_message('BOM','CTO_ZERO_BOM_COMP', l_token1 );

      raise fnd_api.g_exc_error;


     /* Please incorporate raising exception */


   end if ;

   --Bug 7418622.FP for 7154767.pdube
   UPDATE bom_inventory_comps_interface
   SET     disable_date = g_futuredate
   WHERE
       (
           component_item_id, NVL(assembly_item_id,-1),disable_date
       )
          IN
       (
          SELECT  component_item_id       ,
                  NVL(assembly_item_id,-1),
                  MAX(disable_date)
          FROM    bom_inventory_comps_interface
          WHERE   bill_sequence_id = lConfigBillId
          GROUP BY component_item_id,
                   assembly_item_id
       )
       AND bill_sequence_id = lConfigBillId
       AND disable_date    <> g_futuredate ;

   test_var := sql%rowcount;

   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('Create_bom_ml: Extending the disable dates to future date = '||test_var,1);
      oe_debug_pub.add('Create_bom_ml: lconfigBillId = '||to_char(lConfigBillid),1);
   END IF;
  --Bug 7418622.FP for 7154767


   -- Remove fix of 2524562 from here to fix 2814257

   /*---------------------------------------------------------------+
      Second:
      All the standard component items  associated
      with the new configuration items will be loaded into the
      BOM_INVENTORY_COMPS_INTERFACE table.
   +----------------------------------------------------------------*/

   lStmtNum := 50;
   xTableName := 'BOM_INVENTORY_COMPS_INTERFACE';
   insert into BOM_INVENTORY_COMPS_INTERFACE
     (
     operation_seq_num,
     component_item_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login,
     item_num,
     component_quantity,
     component_yield_factor,
     component_remarks,
     effectivity_date,
     change_notice,
     implementation_date,
     disable_date,
     attribute_category,
     attribute1,
     attribute2,
     attribute3,
     attribute4,
     attribute5,
     attribute6,
     attribute7,
     attribute8,
     attribute9,
     attribute10,
     attribute11,
     attribute12,
     attribute13,
     attribute14,
     attribute15,
     planning_factor,
     quantity_related,
     so_basis,
     optional,
     mutually_exclusive_options,
     include_in_cost_rollup,
     check_atp,
     shipping_allowed,
     required_to_ship,
     required_for_revenue,
     include_on_ship_docs,
     include_on_bill_docs,
     low_quantity,
     high_quantity,
     acd_type,
     old_component_sequence_id,
     component_sequence_id,
     bill_sequence_id,
     request_id,
     program_application_id,
     program_id,
     program_update_date,
     wip_supply_type,
     pick_components,
     model_comp_seq_id,
     supply_subinventory,
     supply_locator_id,
     bom_item_type,
     optional_on_model,		-- New columns for configuration
     parent_bill_seq_id,	-- BOM restructure project.
     plan_level			-- Used by CTO only.
     , basis_type,             /* LBM project */
     batch_id
	)
   select
     nvl(ic1.operation_seq_num,1),
     ic1.component_item_id,
     SYSDATE,                           -- last_updated_date
     1,                                 -- last_updated_by
     SYSDATE,                           -- creation_date
     1,                                 -- created_by
     1,                                 -- last_update_login
     ic1.item_num,
     decode( nvl(ic1.basis_type,1), 1 , Round( ( ic1.component_quantity * ( bcol1.ordered_quantity
          / bcol2.ordered_quantity)), 7 ) , Round(ic1.component_quantity , 7 ) ) ,  /* Decimal-Qty Support for Option Items, LBM project */
     ic1.component_yield_factor,
     ic1.component_remarks,             --Bugfix 7188428
     --NULL,                              -- ic1.component_remark
     -- 3222932 TRUNC(SYSDATE),         -- effective date
     decode(                            -- 3222932
       greatest(ic1.effectivity_date,sysdate),
       ic1.effectivity_date ,
       ic1.effectivity_date ,
       sysdate ),
     NULL,                              -- change notice
     SYSDATE,                           -- implementation_date
     -- 3222932 NULL,                   -- disable date
     nvl(ic1.disable_date,g_futuredate), -- 3222932
     ic1.attribute_category,
     ic1.attribute1,
     ic1.attribute2,
     ic1.attribute3,
     ic1.attribute4,
     ic1.attribute5,
     ic1.attribute6,
     ic1.attribute7,
     ic1.attribute8,
     ic1.attribute9,
     ic1.attribute10,
     ic1.attribute11,
     ic1.attribute12,
     ic1.attribute13,
     ic1.attribute14,
     ic1.attribute15,
     100,                                  -- planning_factor
     2,                                    -- quantity_related
     ic1.so_basis,
     2,                                    -- optional
     2,                                    -- mutually_exclusive_options
     ic1.include_in_cost_rollup,
     ic1.check_atp,
     2,                                    -- shipping_allowed = NO
     2,                                    -- required_to_ship = NO
     ic1.required_for_revenue,
     ic1.include_on_ship_docs,
     ic1.include_on_bill_docs,
     NULL,                                 -- low_quantity
     NULL,                                 -- high_quantity
     NULL,                                 -- acd_type
     NULL,                                 -- old_component_sequence_id
     bom_inventory_components_s.nextval,   -- component sequence id
     lConfigBillId,                        -- bill sequence id
     NULL,                                 -- request_id
     NULL,                                 -- program_application_id
     NULL,                                 -- program_id
     NULL,                                 -- program_update_date
     ic1.wip_supply_type,
     2,                                    -- pick_components = NO
     (-1)*ic1.component_sequence_id,       -- model comp seq for later use
     ic1.supply_subinventory,
     ic1.supply_locator_id,
     ic1.bom_item_type,
     2,				--optional_on_model,
     ic1.bill_sequence_id,	--parent_bill_seq_id,
     bcol1.plan_level+1-bcol2.plan_level	--plan_level
      , nvl(ic1.basis_type,1),           /* LBM project */
     cto_msutil_pub.bom_batch_id
   from
     bom_cto_order_lines bcol1,                 -- component
     bom_cto_order_lines bcol2,                 -- Model
     mtl_system_items si1,
     mtl_system_items si2,
     bom_bill_of_materials b,
     bom_inventory_components ic1
   where   si1.organization_id = pOrgId
   and     bcol1.inventory_item_id = si1.inventory_item_id
   and     si1.bom_item_type in (1,2)      -- model, option class
   and     si2.inventory_item_id = bcol2.inventory_item_id
   and     si2.organization_id = si1.organization_id
   and     si2.bom_item_type = 1
   and     ((bcol1.parent_ato_line_id  = bcol2.line_id
                        -- bugfix 2215274: replaced bind variable with column join to improve performance.
            and ( bcol1.bom_item_type <> 1
                  or
                 (bcol1.bom_item_type = 1 and nvl(bcol1.wip_supply_type, 0) = 6))
            )
            or bcol1.line_id = bcol2.line_id
           ) 		-- new condition to get the parent itself
                        -- bugfix 2215274: replaced bind variable with column join to improve performance.
   and     bcol2.line_id = pLineId
   and     si1.organization_id     = b.organization_id
   and     bcol1.inventory_item_id    = b.assembly_item_id
   and     b.alternate_bom_designator is NULL
   and     b.common_bill_sequence_id = ic1.bill_sequence_id
   and     ic1.optional = 2         -- optional = no
   -- inserted code for checking bugfix 1522647
   -- and     ic1.effectivity_date <= greatest( NVL(lEstRelDate,sysdate),sysdate)
   -- begin bugfix 1912376
   -- and     ic1.effectivity_date <= greatest( NVL(g_SchShpDate,sysdate),sysdate) /* New approach for effectivity dates */
   -- end bugfix 1912376
   and     ic1.implementation_date is not null
   -- and     NVL(ic1.disable_date,NVL(lEstRelDate, SYSDATE)+1) > NVL(lEstRelDate,SYSDATE) /* NEW approach for effectivity */
   -- and    NVL(ic1.disable_date,SYSDATE) >= SYSDATE  /* New approach for effectivity */
   and  ( ic1.disable_date is null or
         (ic1.disable_date is not null and  ic1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
   -- code of bugfix 1522647 ends here
   and     ic1.bom_item_type = 4;

   lCnt := sql%rowcount ;

   	IF PG_DEBUG <> 0 THEN
   		oe_debug_pub.add ('create_bom_ml: ' || 'Second -- Inserted ' || lCnt ||' rows',1);
  	 END IF;

   end if; 				/* end of check lOpseqProfile = 1 */


/* begin Extend Effectivity Dates for Option Items with disable date */

   oe_debug_pub.add('create_bom_ml:: Config bill id = '||lconfigbillid,1);

   For debug_rec in debug_cur
   Loop
      oe_debug_pub.add('create_bom_ml: : Assembly_item_id = '||debug_rec.assembly_item_id,1);
      oe_debug_pub.add('create_bom_ml: : Componenet_item_id = '||debug_rec.component_item_id,1);
      oe_debug_pub.add('create_bom_ml: : operation_sequence_num = '||debug_rec.operation_seq_num,1);
      oe_debug_pub.add('create_bom_ml: : MAxDisbale Date = '||debug_rec.disable_date,1);
      oe_debug_pub.add('==================================',1);
   End Loop;

     -- Modified by Renga Kannan on 01/10/06
   -- The logic to find the last window for option item and mandatory comps
   -- are little different.
   -- For option items, identify the last window under a parent(option class) accross
   -- all operating sequence
   -- For Mandatory items, identify the last window across all parents and across all
   -- operating sequence.
   -- Mandatory comps row will have assembly_item_id as null
   -- option items row will have assembly_item_id populated

   -- Commenting this update statement as part of Bug 7418622.FP for 7154767.pdube
   /*update bom_inventory_comps_interface
   set disable_date = g_futuredate
   where (component_item_id, nvl(assembly_item_id,-1),disable_date)
   in    ( select
              component_item_id,nvl(assembly_item_id,-1),max(disable_date)
           from bom_inventory_comps_interface
           where bill_sequence_id = lConfigBillId
           group by component_item_id, assembly_item_id
	 )
   and  bill_sequence_id = lConfigBillId
   and disable_date <> g_futuredate ;

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Create_bom_ml: Extending the disable dates to futuure date = '||sql%rowcount,1);
      oe_debug_pub.add('Create_bom_ml: lconfigBillId = '||to_char(lConfigBillid),1);
   End if;*/



   /* end Extend Effectivity Dates for Option Items with disable date */

 /* New approach for effectivity dates */
   /* begin Check for Overlapping Effectivity Dates */
   v_overlap_check := 0 ;

   begin
     select 1 into v_overlap_check
     from dual
     where exists
       ( select * from bom_inventory_comps_interface
          where bill_sequence_id = lConfigBillId
          group by component_item_id, assembly_item_id
          having count(distinct operation_seq_num) > 1
       );
   exception
   when others then
       v_overlap_check := 0 ;
   end;
  oe_debug_pub.add(' Overlap check  = '||v_overlap_check,1);

   if(v_overlap_check = 1) then

     for debug_cur2 in debug_cur1
     Loop
        oe_debug_pub.add(debug_cur2.component_item_id||'-'||debug_cur2.component_sequence_id||'-'||
	                 debug_cur2.operation_seq_num||'-'||to_char(debug_cur2.effectivity_date)
			 ||'-'||to_char(debug_cur2.disable_date),1);

     end loop;

     begin
        select s1.component_item_id,
               s1.operation_seq_num, s1.effectivity_date, s1.disable_date,
               s2.operation_Seq_num , s2.effectivity_date, s2.disable_date
        BULK COLLECT INTO
               v_t_overlap_comp_item_id,
               v_t_overlap_src_op_seq_num,  v_t_overlap_src_eff_date, v_t_overlap_src_disable_date ,
               v_t_overlap_dest_op_seq_num , v_t_overlap_dest_eff_date, v_t_overlap_dest_disable_date
        from bom_inventory_comps_interface s1 , bom_inventory_comps_interface s2
       where s1.component_item_id = s2.component_item_id and s1.assembly_item_id = s2.assembly_item_id
         --and s1.effectivity_date between s2.effectivity_date and s2.disable_date
         and s1.effectivity_date > s2.effectivity_date  --Bugfix 6603382
         and s1.effectivity_date < s2.disable_date      --Bugfix 6603382
         and s1.bill_sequence_id = lConfigBillId        --Bugfix 6603382
         and s2.bill_sequence_id = lConfigBillId        --Bugfix 6603382
         and s1.component_sequence_id <> s2.component_sequence_id ;


     exception
     when others then
        null ;
     end ;
     oe_debug_pub.add('Over lap record count = '||v_t_overlap_src_op_seq_num.count,1);

     if( v_t_overlap_src_op_seq_num.count > 0 ) then
         for i in v_t_overlap_src_op_seq_num.first..v_t_overlap_src_op_seq_num.last
         loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add (' The following components have overlapping dates ', 1);
                oe_debug_pub.add (' COMP ' || ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' || ' OVERLAPS ' ||
                                              ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' , 1);

                oe_debug_pub.add ( v_t_overlap_comp_item_id(i) ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) ||
                                  ' OVERLAPS ' ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) , 1);

             END IF;
	     select segment1
	     into
	     l_model_name
	     from   mtl_system_items
	     where  inventory_item_id=pModelId
	     and rownum=1;

             l_token2(1).token_name  :='MODEL';
	     l_token2(1).token_value :=l_model_name;
             cto_msg_pub.cto_message('BOM','CTO_OVERLAP_DATE_ERROR',l_token2);

         end loop ;

         raise fnd_api.g_exc_error;

     end if ;

   end if;



   /* end Check for Overlapping Effectivity Dates */





   -- Fix 2814257 : Move fix of 2524562 out of if..then..else to
   -- print dropped line info irrespective of opseq profile set up.

   /* 2524562 Print dropped line information
    in Forms and log files */

    -- start fix 2986192

    lStmtNum := 51;

    BEGIN

    lcreate_item := nvl(FND_PROFILE.VALUE('CTO_CONFIG_EXCEPTION'), 1);

    IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add ('Config exception profile '||lcreate_item, 1);
    END IF;

    open missed_lines(pLineId, lConfigBillId, lEstRelDate );  /* Effectivity dates change */
    loop
    	fetch missed_lines into v_missed_line_id;
    	exit when missed_lines%NOTFOUND;

        v_option_num := v_option_num + 1 ;


    	lStmtNum := 52;

        BEGIN

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('Select missed component details.. ' ,1);
        END IF;



        if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
                IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Pre configured Item .. ' ,1);
                END IF;

                select substrb(msi.concatenated_segments,1,50),
                       'Not Available' ,
                       -1
                  into v_missed_item,v_missed_line_number,v_order_number
                  from mtl_system_items_kfv msi, bom_cto_order_lines bcol
                 where msi.organization_id = bcol.ship_from_org_id
                   and msi.inventory_item_id = bcol.inventory_item_id
                   and bcol.line_id = v_missed_line_id;

        else
                IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('Auto configured Item .. ' ,1);
                END IF;

    	        select substrb(msi.concatenated_segments,1,50),
    	               to_char(oel.line_number)||'.'||to_char(oel.shipment_number) ||decode(oel.option_number,NULL,NULL,'.'
                       ||to_char(option_number)),
    		       oeh.order_number
    	          into v_missed_item,v_missed_line_number,v_order_number
    	          from mtl_system_items_kfv msi, oe_order_lines_all oel,oe_order_headers_all oeh
    	         where msi.organization_id = oel.ship_from_org_id
    	           and msi.inventory_item_id = oel.inventory_item_id
    	           and oel.header_id	= oeh.header_id
    	           and oel.line_id = v_missed_line_id;



        end if ;


    	lStmtNum := 53;

   	IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('Select model.. ' ,1);
        END IF;

    	select 	substrb(concatenated_segments,1,50)
    	into	v_model
    	from 	mtl_system_items_kfv
    	where 	organization_id = pOrgId
    	and 	inventory_item_id = pModelId ;

    	lStmtNum := 54;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('Select Org.. ' ,1);
        END IF;

        select	organization_code
        into 	lOrg_code
        from 	mtl_parameters
        where	organization_id =pOrgId ;



        if ( v_option_num = 1 ) then

               v_dropped_item_string := 'Option ' || v_option_num || ':  ' || v_missed_item || l_new_line ;

               v_ac_message_string := ' Line ' || v_missed_line_number || ' ' || v_dropped_item_string ;

        else

               v_sub_dropped_item_string := 'Option ' || v_option_num || ':  ' || v_missed_item || l_new_line ;
               v_dropped_item_string := v_dropped_item_string || v_sub_dropped_item_string ;

               v_ac_message_string :=  v_ac_message_string || ' Line ' || v_missed_line_number || ' ' || v_sub_dropped_item_string ;


        end if ;


    	if ( lcreate_item = 1 ) then

    	 IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add ('Warning: The component '||v_missed_item
                        	|| ' on Line Number '||v_missed_line_number
                        	|| ' in organization ' || lOrg_code
                        	|| ' was not included in the configured item''s bill. ',1);
       	  oe_debug_pub.add ('Model Name : '||v_model,1);
       	  oe_debug_pub.add ('Order Number : '||v_order_number,1);





         END IF;

          /*
    	  l_token(1).token_name  := 'OPTION_NAME';
          l_token(1).token_value := v_missed_item;
          l_token(2).token_name  := 'LINE_ID';
          l_token(2).token_value := v_missed_line_number;
          l_token(3).token_name  := 'ORG_CODE';
          l_token(3).token_value := lOrg_code ;
          l_token(4).token_name  := 'MODEL_NAME';
          l_token(4).token_value := v_model;
          l_token(5).token_name  := 'ORDER_NUMBER';
          l_token(5).token_value := v_order_number;

    	  cto_msg_pub.cto_message('BOM','CTO_DROP_ITEM_FROM_CONFIG',l_token);

          */


       else
    	  IF PG_DEBUG <> 0 THEN
    	   oe_debug_pub.add ('Warning: The configured item was not created because component '||v_missed_item
                        	|| ' on Line Number '||v_missed_line_number
                        	|| ' in organization ' || lOrg_code
                        	|| ' could not be included in the configured item''s bill. ',1);
       	   oe_debug_pub.add ('Model Name : '||v_model,1);
       	   oe_debug_pub.add ('Order Number : '||v_order_number,1);
          END IF;

          /*
    	  l_token(1).token_name  := 'OPTION_NAME';
          l_token(1).token_value := v_missed_item;
          l_token(2).token_name  := 'LINE_ID';
          l_token(2).token_value := v_missed_line_number;
          l_token(3).token_name  := 'ORG_CODE';
          l_token(3).token_value := lOrg_code ;
          l_token(4).token_name  := 'MODEL_NAME';
          l_token(4).token_value := v_model;
          l_token(5).token_name  := 'ORDER_NUMBER';
          l_token(5).token_value := v_order_number;

    	   cto_msg_pub.cto_message('BOM','CTO_DO_NOT_CREATE_ITEM',l_token);
          */

    	end if;

    	EXCEPTION			-- exception for stmt 52 ,53 and 54

     	        when others then
     	          IF PG_DEBUG <> 0 THEN
                    oe_debug_pub.add('Others excepn from stmt '||lStmtNum ||':'||sqlerrm);
            	  END IF;
            	  raise fnd_api.g_exc_error;
    	END ;
    end loop;

    /* gDropItem is set to 0 . Not resetting this to 1
       for next order in the batch since even when items are
       dropped for one order in the batch , the whole batch
       should end with warning */

    if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
          IF PG_DEBUG <> 0 THEN
    	     oe_debug_pub.add ('Will not go through Hold Logic and Notification as Preconfigured Bom' , 1 );
	  END IF;

          if missed_lines%ROWCOUNT > 0 then
    	     if ( lcreate_item = 1 ) then
                  IF PG_DEBUG <> 0 THEN
    	             oe_debug_pub.add ('Create Item profile set to Create and Link Item ' , 1 );
	          END IF;

		xMessageName  := 'CTO_DROP_ITEM_FROM_CONFIG';




                /*  DROPPED ITEM CAPTURE PROCESS */

                select segment1 into v_problem_model from mtl_system_items
                 where inventory_item_id = pModelId and rownum = 1 ;

                select segment1 into v_problem_config from mtl_system_items
                 where inventory_item_id = pConfigId and rownum = 1 ;

                -- rkaza. bug 3742393. 08/11/2004. Replaced org_organization
                -- _deinitions with inv_organization_name_v
                select organization_name into v_error_org from inv_organization_name_v
                 where organization_id = pOrgId ;


               v_problem_model_line_num := ' -1 ' ;



               v_table_count := g_t_dropped_item_type.count + 1 ;
               g_t_dropped_item_type(v_table_count).PROCESS := 'NOTIFY_OID_IC' ;  /* ITEM CREATED */
               g_t_dropped_item_type(v_table_count).LINE_ID               := pLineId ;
               g_t_dropped_item_type(v_table_count).SALES_ORDER_NUM       := null ;
               g_t_dropped_item_type(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
               g_t_dropped_item_type(v_table_count).TOP_MODEL_NAME        := null ;
               g_t_dropped_item_type(v_table_count).TOP_MODEL_LINE_NUM    := null ;
               g_t_dropped_item_type(v_table_count).TOP_CONFIG_NAME       := null ;
               g_t_dropped_item_type(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
               g_t_dropped_item_type(v_table_count).PROBLEM_MODEL         := v_problem_model ;
               g_t_dropped_item_type(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
               g_t_dropped_item_type(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
               g_t_dropped_item_type(v_table_count).ERROR_ORG              := v_error_org ;
               g_t_dropped_item_type(v_table_count).ERROR_ORG_ID           := pOrgId ;
               -- g_t_dropped_item_type(v_table_count).MFG_REL_DATE           := to_char( lEstRelDate , 'DD-MON-YYYY' ) ;
               g_t_dropped_item_type(v_table_count).MFG_REL_DATE           := lEstRelDate ;

               IF PG_DEBUG <> 0 THEN
    	             oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
	       END IF;

               g_t_dropped_item_type(v_table_count).REQUEST_ID             := to_char( fnd_global.conc_request_id ) ;

             else
                  IF PG_DEBUG <> 0 THEN
    	             oe_debug_pub.add ('Create Item profile set to Do Not Create Item ' , 1 );
	          END IF;

		xMessageName  := 'CTO_DO_NOT_CREATE_ITEM';



                /*  DROPPED ITEM CAPTURE PROCESS */

                select segment1 into v_problem_model from mtl_system_items
                 where inventory_item_id = pModelId and rownum = 1 ;

                select segment1 into v_problem_config from mtl_system_items
                 where inventory_item_id = pConfigId and rownum = 1 ;

                -- rkaza. bug 3742393. 08/11/2004. Replaced org_organization
                -- _deinitions with inv_organization_name_v

                select organization_name into v_error_org from inv_organization_name_v
                 where organization_id = pOrgId ;


                v_problem_model_line_num := ' -1 ' ;


                v_table_count := g_t_dropped_item_type.count + 1 ;
                g_t_dropped_item_type(v_table_count).PROCESS := 'NOTIFY_OID_INC' ;  /* ITEM NOT CREATED */
                g_t_dropped_item_type(v_table_count).LINE_ID               := pLineId ;
                g_t_dropped_item_type(v_table_count).SALES_ORDER_NUM       := null ;
                g_t_dropped_item_type(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
                g_t_dropped_item_type(v_table_count).TOP_MODEL_NAME        := null ;
                g_t_dropped_item_type(v_table_count).TOP_MODEL_LINE_NUM    := null ;
                g_t_dropped_item_type(v_table_count).TOP_CONFIG_NAME       := null ;
                g_t_dropped_item_type(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
                g_t_dropped_item_type(v_table_count).PROBLEM_MODEL         := v_problem_model ;
                g_t_dropped_item_type(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
                g_t_dropped_item_type(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
                g_t_dropped_item_type(v_table_count).ERROR_ORG              := v_error_org ;
                g_t_dropped_item_type(v_table_count).ERROR_ORG_ID           := pOrgId ;
                g_t_dropped_item_type(v_table_count).MFG_REL_DATE           := lEstRelDate  ;

               IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
               END IF;

               g_t_dropped_item_type(v_table_count).REQUEST_ID             := to_char( fnd_global.conc_request_id ) ;



     	        raise fnd_api.g_exc_error;

             end if;

          end if;

    else
    if missed_lines%ROWCOUNT > 0 then
    	CTO_CONFIG_BOM_PK.gDropItem := 0;






    	lStmtNum := 55;

    	if ( lcreate_item = 1 ) then


	-- bugfix 2840801 :
	-- Set the global variable gApplyHold to apply hold on config line.

          IF PG_DEBUG <> 0 THEN
    	     oe_debug_pub.add ('Setting the global var gApplyHold to Y');
	  END IF;

	  CTO_CONFIG_BOM_PK.gApplyHold := 'Y';






          /*  DROPPED ITEM CAPTURE PROCESS */

          select segment1 into v_problem_model from mtl_system_items
           where inventory_item_id = pModelId and rownum = 1 ;

          select segment1 into v_problem_config from mtl_system_items
           where inventory_item_id = pConfigId and rownum = 1 ;

          -- rkaza. bug 3742393. 08/11/2004. Replaced org_organization
          -- _deinitions with inv_organization_name_v

          select organization_name into v_error_org from inv_organization_name_v
           where organization_id = pOrgId ;




           if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
               v_problem_model_line_num := ' -1 ' ;

           else
             select oel.line_number || '.' || oel.shipment_number
             into v_problem_model_line_num
             from oe_order_lines_all oel
            where line_id = pLineId ;

           end if;

          oe_debug_pub.add( ' DROPPED ITEM INFO: ' ||
                            ' Problem Model ' || v_problem_model ||
                            ' Problem CONFIG ' || v_problem_config ||
                            ' ERROR ORG ' || v_error_org  ||
                            ' PROBLEM MODEL LINE NUM ' || v_problem_model_line_num
                            , 1 ) ;

          v_table_count := g_t_dropped_item_type.count + 1 ;
          g_t_dropped_item_type(v_table_count).PROCESS := 'NOTIFY_OID_IC' ;  /* ITEM CREATED */
          g_t_dropped_item_type(v_table_count).LINE_ID               := pLineId ;
          g_t_dropped_item_type(v_table_count).SALES_ORDER_NUM       := null ;
          g_t_dropped_item_type(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
          g_t_dropped_item_type(v_table_count).TOP_MODEL_NAME        := null ;
          g_t_dropped_item_type(v_table_count).TOP_MODEL_LINE_NUM    := null ;
          g_t_dropped_item_type(v_table_count).TOP_CONFIG_NAME       := null ;
          g_t_dropped_item_type(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
          g_t_dropped_item_type(v_table_count).PROBLEM_MODEL         := v_problem_model ;
          g_t_dropped_item_type(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
          g_t_dropped_item_type(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
          g_t_dropped_item_type(v_table_count).ERROR_ORG              := v_error_org ;
          g_t_dropped_item_type(v_table_count).ERROR_ORG_ID           := pOrgId ;
          g_t_dropped_item_type(v_table_count).MFG_REL_DATE           := lEstRelDate ;

          IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
          END IF;

          g_t_dropped_item_type(v_table_count).REQUEST_ID             := to_char(fnd_global.conc_request_id) ;




          /* IDENTIFY NOTIFY_USER for DROPPED COMPONENT NOTIFICATION */

          IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('create_bom_ml: ' || 'Getting Custom Recipient..',3);
          END IF;

          v_recipient := CTO_CUSTOM_NOTIFY_PK.get_recipient( p_error_type        => CTO_UTILITY_PK.OPT_DROP_AND_ITEM_CREATED
                                             ,p_inventory_item_id => pModelId
                                             ,p_organization_id   => pOrgId
                                             ,p_line_id           => pLineId   );




          if( v_recipient is not null ) then
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK..' || v_recipient ,3);
              END IF;

              g_t_dropped_item_type(v_table_count).NOTIFY_USER             := v_recipient ;  /* commented 'MFG' */

          else



              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK is null ..' , 3);
                 oe_debug_pub.add('create_bom_ml: ' || 'Getting the planner code ..',3);
              END IF;

              BEGIN
                 -- bugfix 2203802: Instead of getting the planner code directly from MSI,
                 --                 get the corresponding application user.

                 SELECT  u.user_name
                   INTO   lplanner_code
                   FROM   mtl_system_items_vl item
                         ,mtl_planners p
                         ,fnd_user u
                  WHERE item.inventory_item_id = pModelId
                  and   item.organization_id   = pOrgId
                  and   p.organization_id = item.organization_id
                  and   p.planner_code = item.planner_code
                  and   p.employee_id = u.employee_id(+);         --outer join b'cos employee need not be an fnd user.


                  oe_debug_pub.add('create_bom_ml: ' || '****PLANNER CODE DATA' || lplanner_code ,2);


              EXCEPTION
              WHEN OTHERS THEN
                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('create_bom_ml: ' || 'Error in getting the planner code data. Defaulting to SYSADMIN.',2);

                      oe_debug_pub.add('create_bom_ml: ' || 'Error Message : '||sqlerrm,2);


                   END IF;
              END;



              g_t_dropped_item_type(v_table_count).NOTIFY_USER             := lplanner_code ;  /* commented 'MFG' */

          end if; /* check custom recipient */




               l_token(1).token_name  := 'ORDER_NUM';
               l_token(1).token_value := v_order_number;
    	       l_token(2).token_name  := 'MODEL_NAME';
               l_token(2).token_value := v_problem_model;
               l_token(3).token_name  := 'ORG';
               l_token(3).token_value := v_error_org;
               l_token(4).token_name  := 'CONFIG_NAME';
               l_token(4).token_value := v_problem_config;
               l_token(5).token_name  := 'ERROR_MESSAGE';
               l_token(5).token_value := v_ac_message_string ;
    	       cto_msg_pub.cto_message('BOM','CTO_AC_DROP_ITEM_FROM_CONFIG',l_token);


	else

	  IF PG_DEBUG <> 0 THEN
	    oe_debug_pub.add ('Not creating Item...');
	  END IF;







          /*  DROPPED ITEM CAPTURE PROCESS */

          select segment1 into v_problem_model from mtl_system_items
           where inventory_item_id = pModelId and rownum = 1 ;

          select segment1 into v_problem_config from mtl_system_items
           where inventory_item_id = pConfigId and rownum = 1 ;

          -- rkaza. bug 3742393. 08/11/2004. Replaced org_organization
          -- _deinitions with inv_organization_name_v
          select organization_name into v_error_org from inv_organization_name_v
           where organization_id = pOrgId ;


           select oel.line_number || '.' || oel.shipment_number
             into v_problem_model_line_num
             from oe_order_lines_all oel
            where line_id = pLineId ;


          v_table_count := g_t_dropped_item_type.count + 1 ;
          g_t_dropped_item_type(v_table_count).PROCESS := 'NOTIFY_OID_INC' ;  /* ITEM NOT CREATED */
          g_t_dropped_item_type(v_table_count).LINE_ID               := pLineId ;
          g_t_dropped_item_type(v_table_count).SALES_ORDER_NUM       := null ;
          g_t_dropped_item_type(v_table_count).ERROR_MESSAGE         := v_dropped_item_string ;
          g_t_dropped_item_type(v_table_count).TOP_MODEL_NAME        := null ;
          g_t_dropped_item_type(v_table_count).TOP_MODEL_LINE_NUM    := null ;
          g_t_dropped_item_type(v_table_count).TOP_CONFIG_NAME       := null ;
          g_t_dropped_item_type(v_table_count).TOP_CONFIG_LINE_NUM   := null ;
          g_t_dropped_item_type(v_table_count).PROBLEM_MODEL         := v_problem_model ;
          g_t_dropped_item_type(v_table_count).PROBLEM_MODEL_LINE_NUM := v_problem_model_line_num ;
          g_t_dropped_item_type(v_table_count).PROBLEM_CONFIG         := v_problem_config ;
          g_t_dropped_item_type(v_table_count).ERROR_ORG              := v_error_org ;
          g_t_dropped_item_type(v_table_count).ERROR_ORG_ID           := pOrgId ;
          g_t_dropped_item_type(v_table_count).MFG_REL_DATE           := lEstRelDate ;

          IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add ('CTOCBOMB: REQUEST ID : ' || fnd_global.conc_request_id , 1 );
          END IF;

          g_t_dropped_item_type(v_table_count).REQUEST_ID             := to_char( fnd_global.conc_request_id ) ;



          /* IDENTIFY NOTIFY_USER for DROPPED COMPONENT NOTIFICATION */


          IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('create_bom_ml: ' || 'Getting Custom Recipient..',3);
          END IF;

          v_recipient := CTO_CUSTOM_NOTIFY_PK.get_recipient( p_error_type        => CTO_UTILITY_PK.OPT_DROP_AND_ITEM_NOT_CREATED
                                                            ,p_inventory_item_id => pModelId
                                                            ,p_organization_id   => pOrgId
                                                            ,p_line_id           => pLineId   );




          if( v_recipient is not null ) then
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK..' || v_recipient ,3);
              END IF;

              g_t_dropped_item_type(v_table_count).NOTIFY_USER             := v_recipient ;  /* commented 'MFG' */

          else





              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('create_bom_ml: ' || 'Recipient returned from CTO_CUSTOM_NOTIFY_PK is null ..' , 3);
                 oe_debug_pub.add('create_bom_ml: ' || 'Getting the planner code ..',3);
              END IF;

              BEGIN
                   -- bugfix 2203802: Instead of getting the planner code directly from MSI,
                   --                 get the corresponding application user.

                   SELECT  u.user_name
                     INTO  lplanner_code
                     FROM  mtl_system_items_vl item
                          ,mtl_planners p
                          ,fnd_user u
                    WHERE item.inventory_item_id = pModelId
                    and   item.organization_id   = pOrgId
                    and   p.organization_id = item.organization_id
                    and   p.planner_code = item.planner_code
                    and   p.employee_id = u.employee_id(+);         --outer join b'cos employee need not be an fnd user.


                   oe_debug_pub.add('create_bom_ml: ' || '****PLANNER CODE DATA' || lplanner_code ,2);


              EXCEPTION
              WHEN OTHERS THEN
                   IF PG_DEBUG <> 0 THEN
                      oe_debug_pub.add('create_bom_ml: ' || 'Error in getting the planner code data. Defaulting to SYSADMIN.',2);

                      oe_debug_pub.add('create_bom_ml: ' || 'Error Message : '||sqlerrm,2);


                   END IF;
              END;



              g_t_dropped_item_type(v_table_count).NOTIFY_USER             := lplanner_code ;  /* commented 'MFG' */

          end if; /* check custom recipient */



          -- rkaza. bug 4315973. 08/24/2005.
          -- Hold ato line for dropped items when profile is set to do not
          -- create item. Removed aps_version restriction.

          oe_debug_pub.add('create_bom_ml: ' || 'fetching information for apply hold on lineid '|| to_char(pLineId) ,2);
          oe_debug_pub.add('create_bom_ml: ' || 'going to apply hold on lineid '|| to_char(pLineId) ,2);

          cto_utility_pk.apply_create_config_hold( v_ato_line_id, v_header_id, l_return_status, l_msg_count, l_msg_data ) ;


               l_token(1).token_name  := 'ORDER_NUM';
               l_token(1).token_value := v_order_number;
               l_token(2).token_name  := 'MODEL_NAME';
               l_token(2).token_value := v_problem_model;
               l_token(3).token_name  := 'ORG';
               l_token(3).token_value := v_error_org;
               l_token(4).token_name  := 'ERROR_MESSAGE';
               l_token(4).token_value := v_ac_message_string ;

               cto_msg_pub.cto_message('BOM','CTO_AC_DO_NOT_CREATE_ITEM',l_token);

	       -- Bugfix 4084568: Adding message for model line on Hold.

               cto_msg_pub.cto_message('BOM','CTO_MODEL_LINE_EXCPN_HOLD');



     	  raise fnd_api.g_exc_error;

     	end if; /* create item profile condition */

    end if; /* missed lines cursor condition */

    end if; /* Preconfigure / Autoconfigure condition */



    close missed_lines;

    EXCEPTION                 -- exception for stmt 51 and 55

             when others then
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add ('Failed in stmt ' || lStmtNum || ' with error: '||sqlerrm);
                END IF;
                raise fnd_api.g_exc_error;
    END ;


    /* 2524562 End of bugfix */

   -- b2307936 : We will insert the base model row irrespective of the OpseqProfile value.


   /*---------------------------------------------------------------+
       Third : Get the base model row into BOM_INVENTORY_COMPONENTS
   +----------------------------------------------------------------*/

   lStmtNum := 60;
   insert into BOM_INVENTORY_COMPS_INTERFACE
       (
       operation_seq_num,
       component_item_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       item_num,
       component_quantity,
       component_yield_factor,
       component_remarks,
       effectivity_date,
       change_notice,
       implementation_date,
       disable_date,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       planning_factor,
       quantity_related,
       so_basis,
       optional,
       mutually_exclusive_options,
       include_in_cost_rollup,
       check_atp,
       shipping_allowed,
       required_to_ship,
       required_for_revenue,
       include_on_ship_docs,
       include_on_bill_docs,
       low_quantity,
       high_quantity,
       acd_type,
       old_component_sequence_id,
       component_sequence_id,
       bill_sequence_id,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       wip_supply_type,
       pick_components,
       model_comp_seq_id,
       bom_item_type,
       optional_on_model,	-- New columns for configuration
       parent_bill_seq_id,	-- BOM restructure project.
       plan_level		-- Used by CTO only.
      , basis_type,     /* LBM project */
       batch_id
       )
   select
       1,			-- operation_seq_num
       bcol.inventory_item_id,
       SYSDATE,                 -- last_updated_date
       1,                       -- last_updated_by
       SYSDATE,                 -- creation_date
       1,                       -- created_by
       1,                       -- last_update_login
       9,			-- item_num
       1,	                -- comp_qty
       1,			-- yield_factor
       NULL,                    --ic1.component_remark
       SYSDATE,                 -- effective date --bug4150255: Removed the trunc so that time is also populated.
       NULL,                    -- change notice
       SYSDATE,                 -- implementation_date
       NULL,                    -- disable date
       NULL,			-- attribute_category
       NULL,			-- attribute1
       NULL,                    -- attribute2
       NULL,                    -- attribute3
       NULL,                    -- attribute4
       NULL,                    -- attribute5
       NULL,                    -- attribute6
       NULL,                    -- attribute7
       NULL,                    -- attribute8
       NULL,                    -- attribute9
       NULL,                    -- attribute10
       NULL,                    -- attribute11
       NULL,                    -- attribute12
       NULL,                    -- attribute13
       NULL,                    -- attribute14
       NULL,                    -- attribute15
       100,                     -- planning_factor
       2,                       -- quantity_related
       2,			-- so_basis
       2,                       -- optional
       2,                       -- mutually_exclusive_options
       2,			-- include_in_cost_rollup
       2,			-- check_atp
       2,                       -- shipping_allowed = NO
       2,                       -- required_to_ship = NO
       2,			-- required_for_revenue
       2,			-- include_on_ship_docs
       2,			-- include_on_bill_docs
       NULL,                    -- low_quantity
       NULL,                    -- high_quantity
       NULL,                    -- acd_type
       NULL,                    -- old_component_sequence_id
       bom_inventory_components_s.nextval,  -- component sequence id
       lConfigBillId,           -- bill sequence id
       NULL,                    -- request_id
       NULL,                    -- program_application_id
       NULL,                    -- program_id
       NULL,                    -- program_update_date
       6,			-- wip_supply_type
       2,                        -- pick_components = NO
       NULL,                    -- model comp seq id for later use
       1,                        -- bom_item_type
       1,			--optional_on_model,
       0,			--parent_bill_seq_id,
       0			--plan_level
       , 1,                      -- basis_type  /* LBM project */
       cto_msutil_pub.bom_batch_id
    from
       bom_cto_order_lines bcol
    where   bcol.line_id = pLineId
    and     bcol.ordered_quantity <> 0
    and     bcol.inventory_item_id = pModelId;


    lCnt := sql%rowcount ;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_bom_ml: ' || 'Third -- Inserted ' || lCnt ||' rows',1);
    END IF;

    xBillId := lConfigBillId;

    return(1);

EXCEPTION

	WHEN NO_DATA_FOUND THEN		-- Bugfix 2374246 Instead of handling no_calendar_date exception here
          	xBillID := 0;		-- the exception is placed directly with stmt # 43.
             	return(-1);              -- 2986192

      	WHEN FND_API.G_EXC_ERROR THEN
        	xErrorMessage := 'CTOCBOMB:create_bom_ml failed with expected error in stmt '||to_char(lStmtNum);
		--xMessageName  := 'CTO_CREATE_BOM_ERROR';

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('create_bom_ml: ' || 'create_item::exp error::'||to_char(lStmtNum)||sqlerrm,1);
		END IF;



                delete from bom_inventory_comps_interface
                where bill_sequence_id = xBillId ;

		--Bugfix 11056452
		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
                END IF;

		delete from bom_bill_of_mtls_interface
		where bill_sequence_id = xBillId;

		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
                END IF;

                xBillId := null ;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('create_bom_ml: ' || 'deleted records from bici ::'||to_char(sql%rowcount) ,1);
		END IF;

                return(0);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        	xErrorMessage := 'CTOCBOMB:create_bom_ml failed with unexpected error in stmt '||to_char(lStmtNum);
		xMessageName  := 'CTO_CREATE_BOM_ERROR';
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('create_bom_ml: ' || 'create_item::unexp error::'||to_char(lStmtNum)||sqlerrm,1);
		END IF;
                return(-1);


	WHEN OTHERS THEN
        	xErrorMessage := 'CTOCBOMB:'||to_char(lStmtNum)||':'||substrb(sqlerrm,1,150);
		xMessageName  := 'CTO_CREATE_BOM_ERROR';
        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add('create_bom_ml: ' || 'Error: Others excpn in create_bom_ml: ' || sqlerrm);
        	END IF;
        	return(-1);

END create_bom_ml;






/*---------------------------------------------------------------
Modified   :  02-02-2005   Kiran Konada
|                        bug#4092184 FP:11.5.9 - 11.5.10 :I
|                            customer bug#4081613
---------------------------------------------------------------*/

function create_bom_data_ml (
    pModelId        in       number,
    pConfigId       in       number,
    pOrgId          in       number,
    pConfigBillId   in       number,
    xErrorMessage   out NOCOPY     VARCHAR2,
    xMessageName    out NOCOPY     VARCHAR2,
    xTableName      out NOCOPY     VARCHAR2)
return integer
is

    status	           number;
    lStmtNum               number;
    lCfmRtgFlag            number;
    l_from_sequence_id     number;
    lBomId                 number ;
    lSaveBomId             number ;
    lSaveOpSeqNum          number ;
    lSaveItemId            number ;
    lSaveCompSeqId         number ;
    lTotalQty              number ;
    lOpSeqNum              number ;
    lCompSeqId             number ;
    lItemId                number ;
    lqty                   number ;
    lSaveOptional	   number ;
    lOptional	           number ;

    UP_DESC_ERR        exception;


    p_item_num		number := 0;
    p_bill_seq_id 	number;
    p_seq_increment	number;

    v_bom_count               number ;
    v_bom_organization_id     number ;
    v_bom_assembly_item_id     number ;
    v_bom_creation_date       date ;

    -- 3222932 Variable declaration of new code

    -- Collection to store all eff and disable dates

    TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    asc_date_arr    date_tab;

    -- Collection to store clubbed quantity with new date window

    TYPE club_rec IS RECORD (
    eff_dt                  DATE,
    dis_dt                  DATE,
    qty                     NUMBER,
    row_id                  rowid
    );

    TYPE club_tab IS TABLE OF club_rec INDEX BY BINARY_INTEGER;

    club_tab_arr    club_tab;

    lrowid          ROWID;

    -- Get all components to be clubbed
    -- bug 4244576: It is possible that the same item is existing at op seq 15, 25, 30, 15. In
    -- this case the two records at 15 needs to be clubbed but not the once at 25 and 30. Going
    -- just by item_id will club all 4 records. We need to go by item_id and op_seq.
    cursor  club_comp is
        select  distinct b1.component_item_id   item_id, b1.operation_seq_num
        from    bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where   b1.bill_sequence_id = b2.bill_sequence_id
        and     b1.component_sequence_id <> b2.component_sequence_id
        and     b1.operation_seq_num = b2.operation_seq_num
        and     b1.component_item_id = b2.component_item_id
        and     b1.bill_sequence_id = pConfigBillId ; /* Sushant Made a change */
             /* LBM project */


    -- start 3674833
    -- Collection to store comp seq


        TYPE seq_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


    model_comp_seq_id_arr               seq_tab;
        component_item_id_arr           seq_tab;
    operation_seq_num_arr       seq_tab;  --4244576
        club_component_sequence_id  number;
        prev_comp_item_id                       number;

    -- end 3674833

    max_dis_date    DATE;
    null_dis_date   DATE;
    kounter         NUMBER;

    -- variables for debugging
   dbg_eff_date    Date;
   dbg_dis_date    Date;
   dbg_qty         Number;


   -- Cursor for debugging
   cursor c1_debug( xItemId        number, xOperation_seq_num number) is
        select effectivity_date eff_date,
               nvl (disable_date,g_SchShpDate) dis_date,
               component_quantity cmp_qty,
               basis_type
        from   bom_inventory_comps_interface
        where  bill_sequence_id = pConfigBillId
        and    component_item_id = xItemId
        and    operation_seq_num = xOperation_seq_num; --4244576
   -- bugfix 3985173
   -- new cursor for component sequence
   cursor club_comp_seq ( xComponentItemId      number, xOperation_seq_num number ) is
     select bic.component_sequence_id comp_seq_id
     from   bom_inventory_components bic,
            bom_bill_of_materials bom
     where  bom.assembly_item_id  = pConfigId
     and    bom.organization_id   = pOrgId
     and    bic.bill_sequence_id  = bom.bill_sequence_id
     and    bic.component_item_id = xComponentItemId
     and    bic.operation_seq_num = xOperation_seq_num; --4244576

    v_diff_basis_string  varchar2(2000);
    v_sub_diff_basis_string  varchar2(2000);

    l_new_line  varchar2(10) := fnd_global.local_chr(10);

   l_token			CTO_MSG_PUB.token_tbl;
    basis_model_comp_seq_id_arr               seq_tab;
        basis_component_item_id_arr           seq_tab;
    l_model_name    varchar2(1000);
    l_comp_name     varchar2(1000);
    l_org_name      varchar2(1000);

    --Bugfix 11056452
    lCnt number;
begin

     /*--------------------------------------------------------------+
	If more than one row in the BOM_INVENTORY_COMPS_INTERFACE
        that contain the same bill_sequence_id, operation_seq_num and
        component_item_id, those rows will be combined into a
        single row and  the accumulated COMPONENT_QUANTITY will be
        used in the row.
     +---------------------------------------------------------------*/

     -- start 3674833
     -- Populate seq_tab_arr with component sequence id information
     -- We need this info before inserting into bom_reference_designator
     -- 4244576 - Also need to get operstion_seq_num into an array.

        select  b1.model_comp_seq_id,  b1.component_item_id, b1.operation_seq_num
        BULK COLLECT INTO model_comp_seq_id_arr,  component_item_id_arr, operation_seq_num_arr
        from    bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where   b1.bill_sequence_id = b2.bill_sequence_id
        and     b1.component_sequence_id <> b2.component_sequence_id
        and     b1.operation_seq_num = b2.operation_seq_num
        and     b1.component_item_id = b2.component_item_id
        and     b1.bill_sequence_id = pConfigBillId
        UNION
        select  b2.model_comp_seq_id,  b2.component_item_id, b2.operation_seq_num
        from    bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where   b1.bill_sequence_id = b2.bill_sequence_id
        and     b1.component_sequence_id <> b2.component_sequence_id
        and     b1.operation_seq_num = b2.operation_seq_num
        and     b1.component_item_id = b2.component_item_id
        and     b2.bill_sequence_id = pConfigBillId
        ORDER by 2;


        if model_comp_seq_id_arr.count > 0 then
          for x1 in model_comp_seq_id_arr.FIRST..model_comp_seq_id_arr.LAST
            loop
            oe_debug_pub.add( ' Start Looping ',1);
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ( ' Model_Comp_seq (' ||x1|| ') = ' ||model_comp_seq_id_arr(x1)
                                                ||' Component_item_id (' ||x1|| ') = ' ||component_item_id_arr(x1)
                        ||' operation-seq_num (' ||x1|| ') = ' ||operation_seq_num_arr(x1),1); --4244576

             END IF;
            end loop;
        end if;
     -- end 3674833



     gUserId    := nvl(fnd_global.user_id, -1);
     gLoginId   := nvl(fnd_global.login_id, -1);

     -- Start new code 3222932

     -- Execute following code for each clubbed components
     for club_comp_rec in club_comp
     loop

        -- Get all eff and disable dates in asc order
        -- 4244576
        oe_debug_pub.add( ' Looping for item id : ' ||club_comp_rec.item_id ||' operation_seq : '||club_comp_rec.operation_seq_num,1);

        select  distinct effectivity_date
        BULK COLLECT INTO asc_date_arr
        from    bom_inventory_comps_interface
        where   bill_sequence_id = pConfigBillId
        and     component_item_id = club_comp_rec.item_id
        and     operation_seq_num = club_comp_rec.operation_seq_num --4244576
        UNION
        select  distinct disable_date
        from    bom_inventory_comps_interface
        where   bill_sequence_id = pConfigBillId
        and     component_item_id = club_comp_rec.item_id
        and     operation_seq_num = club_comp_rec.operation_seq_num --4244576
        order by 1;

        -- Printing dates

        if asc_date_arr.count > 0 then
          for x1 in asc_date_arr.FIRST..asc_date_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ('Date ('||x1||') = '||to_char(asc_date_arr(x1),'DD-MON-YY HH24:MI:SS'),1);
             END IF;
            end loop;
        end if;

	-- Creating clubbing windows


        if asc_date_arr.count > 0 then
          for x2 in 1..(asc_date_arr.count-1)
            loop
                club_tab_arr(x2).eff_dt         :=      asc_date_arr(x2);
                club_tab_arr(x2).dis_dt         :=      asc_date_arr(x2+1);
            end loop;
        end if;

        -- Printing dates of clubbing window

        if club_tab_arr.count > 0 then
          for x3 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ('ED ('||x3||') = ' ||to_char(club_tab_arr(x3).eff_dt,'DD-MON-YY HH24:MI:SS')||
                         ' ---- DD ('||x3||') = '|| to_char(club_tab_arr(x3).dis_dt,'DD-MON-YY HH24:MI:SS'),1);
             END IF;
            end loop;
        end if;

        -- Modifying eff dates of clubbing windows

	/*Commenting this as part of bugfix 11059122 (FP:9978623)
          Initially the disable_date was non-inclusive in BOM code. This implies that on the exact time of the
          disable_date, the component was not available to any manufacturing function. BOM team caused a regression
          via bug 2726385 and made the disable_date inclusive. Now, consider the following scenario:
          Item    Op Seq  Effectivity_date      Disable_date
          ====    ======  ================      ============
          I1      1       14-DEC-2010 12:00:00  30-DEC-2010 00:00:00
          I1      1       30-DEC-2010 00:00:00  <NULL>

          If the disable_date is inclusive, it means at 30-DEC-2010 00:00:00 both instances of I1 are active, which
          is incorrect. We believe that to get around this situation, CTO added one second to the effectivity_date
          in such scenarios. This change was made via bug 3059499.

          BOM team fixed the regression via bug 3128252 and made the disable_date non-inclusive again. So there is
          no need to add a one second differential by CTO.

        if club_tab_arr.count > 0 then
          for x21 in 2..(club_tab_arr.count)
            loop
                if ( club_tab_arr(x21 - 1).dis_dt =  club_tab_arr(x21).eff_dt ) then
                  club_tab_arr(x21).eff_dt      :=      club_tab_arr(x21).eff_dt + 1/86400;
                end if;
            end loop;
        end if;
        */

	-- Printing dates of clubbing window

        if club_tab_arr.count > 0 then
          for x22 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ('ED ('||x22||') = ' ||to_char(club_tab_arr(x22).eff_dt,'DD-MON-YY HH24:MI:SS')||
                   ' ---- DD ('||x22||') = '|| to_char(club_tab_arr(x22).dis_dt,'DD-MON-YY HH24:MI:SS'),1);
             END IF;
            end loop;
        end if;

        -- for debug
        for d1 in c1_debug (club_comp_rec.item_id, club_comp_rec.operation_seq_num) loop --4244576

                dbg_eff_date := d1.eff_date;
                dbg_dis_date := d1.dis_date;
                dbg_qty      := d1.cmp_qty;

          IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add( 'ED '||to_char(dbg_eff_date,'DD-MON-YY HH24:MI:SS')||' DD '||to_char(dbg_dis_date,'DD-MON-YY HH24:MI:SS')||' Qty '||dbg_qty||' Basis Type = '||d1.basis_type);
          END IF;

        end loop;

        -- Clubbing quantities

        if club_tab_arr.count > 0 then
          for x4 in club_tab_arr.FIRST.. club_tab_arr.LAST
            loop






             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ('checking for club comp error ', 1 ) ;
             END IF;



        /* begin LBM project */
        /* Check whether multiple occurences of the same component with the same inventory_item_id
           and operation_sequence have conflicting basis_type.
        */
        select  b1.model_comp_seq_id,  b1.component_item_id
        BULK COLLECT INTO
        basis_model_comp_seq_id_arr,  basis_component_item_id_arr
        from
        bom_inventory_comps_interface    b1,bom_inventory_comps_interface    b2
        where  b1.bill_sequence_id = b2.bill_sequence_id
        and    b1.component_sequence_id <> b2.component_sequence_id
        and    b1.operation_seq_num = b2.operation_seq_num
        and    b1.component_item_id = b2.component_item_id
        and    b1.bill_sequence_id = pConfigBillId
        and    b1.basis_type <> b2.basis_type
        and    b1.effectivity_date <= club_tab_arr(x4).eff_dt
        and    nvl(b1.disable_date,g_SchShpDate) >= club_tab_arr(x4).dis_dt
        and    b1.bill_sequence_id = pConfigBillId
        and    b1.component_item_id = club_comp_rec.item_id
        and    b1.operation_seq_num = club_comp_rec.operation_seq_num
        and    b2.effectivity_date <= club_tab_arr(x4).eff_dt
        and    nvl(b2.disable_date,g_schshpdate) >= club_tab_arr(x4).dis_dt;


        if( basis_model_comp_seq_id_arr.count > 0 ) then


            for i in 1..basis_model_comp_seq_id_arr.count
            loop
               if ( i = 1 ) then

                   v_diff_basis_string := 'component ' || basis_component_item_id_arr(i) ;

               else

                   v_sub_diff_basis_string := 'component ' || basis_component_item_id_arr(i) || l_new_line ;

                   v_diff_basis_string := v_diff_basis_string || v_sub_diff_basis_string ;

               end if ;


            end loop;


          IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add( 'Going to Raise CTO_CLUB_COMP_ERROR');
            oe_debug_pub.add( 'will not populated message CTO_CLUB_COMP_ERROR');
          END IF;

               select segment1 into
               l_model_name
               from mtl_system_items
               where inventory_item_id = pmodelid
               and   organization_id   = porgid;


               select segment1 into
               l_comp_name
               from mtl_system_items
               where inventory_item_id = club_comp_rec.item_id
               and   organization_id   = porgid;

               select organization_name
               into   l_org_name
               from   inv_organization_name_v
               where  organization_id = porgid;

               --l_token(1).token_name  := 'ERROR_COMPONENTS';
               --l_token(1).token_value := v_diff_basis_string ;
               l_token(1).token_name    := 'MODEL';
               l_token(1).token_value   := l_model_name;
               l_token(2).token_name    := 'ORGANIZATION';
               l_token(2).token_value    := l_org_name;
               l_token(3).token_name   := 'COMPONENT';
               l_token(3).token_value   := l_comp_name;
    	       --cto_msg_pub.cto_message('BOM','CTO_CLUB_COMP_ERROR',l_token);
    	       cto_msg_pub.cto_message('BOM','CTO_CLUB_COMP_ERROR',l_token);


               raise fnd_api.g_exc_error;


        end if;

        /* end LBM project */






                select max(rowid), sum(decode(nvl(basis_type,1), 1, component_quantity, 0))
                                 + max(decode(nvl(basis_type,1), 2, component_quantity, 0))  /* LBM Project */
                into   club_tab_arr(x4).row_id,club_tab_arr(x4).qty
                from   bom_inventory_comps_interface
                where  effectivity_date <= club_tab_arr(x4).eff_dt
                and    nvl(disable_date,g_SchShpDate) >= club_tab_arr(x4).dis_dt
                and    bill_sequence_id = pConfigBillId
                and    component_item_id = club_comp_rec.item_id
                and    operation_seq_num = club_comp_rec.operation_seq_num; --4244576
            end loop;
        end if;

	 -- Printing Clubbed quantity with window

        if club_tab_arr.count > 0 then
          for x5 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ('ED (' ||x5|| ') = ' ||to_char(club_tab_arr(x5).eff_dt,'DD-MON-YY HH24:MI:SS')||
                                  ' -- DD (' ||x5|| ') = ' ||to_char(club_tab_arr(x5).dis_dt,'DD-MON-YY HH24:MI:SS')||
                                  ' -- Qty (' ||x5|| ') = ' ||club_tab_arr(x5).qty,1);
             END IF;
            end loop;
        end if;

        -- Now insert into bom_inventory_comps_interface

        -- Modified by Renga Kannan on 09/01/06 for bug 4542461
        -- For the window where there is no qty the above select statement will
        -- return null qty. We should not insert this row into interface table.

        if club_tab_arr.count > 0 then

          for x6 in club_tab_arr.FIRST.. club_tab_arr.LAST
           loop
            If nvl(club_tab_arr(x6).qty,0) <> 0 then
            insert into bom_inventory_comps_interface
              (
                component_item_id,
                bill_sequence_id,
                effectivity_date,
                disable_date,
                component_quantity,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                operation_seq_num,
                last_update_login,
                item_num,
                component_yield_factor,
                component_remarks,
                change_notice,
                implementation_date,
                attribute_category,
                attribute1,
                attribute2,
		 attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                planning_factor,
                quantity_related,
                so_basis,
                optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                include_on_bill_docs,
                low_quantity,
                high_quantity,
                acd_type,
                old_component_sequence_id,
                component_sequence_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                pick_components,
                model_comp_seq_id,
                supply_subinventory,
                supply_locator_id,
                bom_item_type,
		optional_on_model,
                parent_bill_seq_id,
                plan_level,
                revised_item_sequence_id
                , basis_type,   /* LBM change */
                batch_id
                 )
              select
                club_comp_rec.item_id,
                pConfigBillId,
                club_tab_arr(x6).eff_dt,
                club_tab_arr(x6).dis_dt,
                round(club_tab_arr(x6).qty,7),          -- to maintain decimal qty support of option items
                SYSDATE,
                pConfigBillId,                          -- CREATED_BY is set to pConfigBillId to identify rows from clubbing
                SYSDATE,
                1,
                operation_seq_num,
                last_update_login,
                item_num,
                component_yield_factor,
                component_remarks,
                change_notice,
                implementation_date,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                planning_factor,
                quantity_related,
		so_basis,optional,
                mutually_exclusive_options,
                include_in_cost_rollup,
                check_atp,
                shipping_allowed,
                required_to_ship,
                required_for_revenue,
                include_on_ship_docs,
                include_on_bill_docs,
                low_quantity,
                high_quantity,
                acd_type,
                old_component_sequence_id,
                bom_inventory_components_s.nextval,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                wip_supply_type,
                pick_components,
                model_comp_seq_id,
                supply_subinventory,
                supply_locator_id,
                bom_item_type,
                optional_on_model,
                parent_bill_seq_id,
                plan_level,
                revised_item_sequence_id
                , nvl(basis_type,1),                 /* LBM project */
                cto_msutil_pub.bom_batch_id
              from      bom_inventory_comps_interface
              where     component_item_id = club_comp_rec.item_id
              and       operation_seq_num = club_comp_rec.operation_seq_num --4244576
              and       bill_sequence_id = pConfigBillId
              and       rowid   = club_tab_arr(x6).row_id;
              end if;
           end loop;
         end if;

	 -- Delete original option item rows from bici
         delete from     bom_inventory_comps_interface
         where           component_item_id = club_comp_rec.item_id
         and             operation_seq_num = club_comp_rec.operation_seq_num --4244576
         and             bill_sequence_id = pConfigBillId
         and             created_by <> pConfigBillId;

         -- Delete rows from bom_inventory_comps_interface where qty = 0
         delete from     bom_inventory_comps_interface
         where           component_item_id = club_comp_rec.item_id
         and             operation_seq_num = club_comp_rec.operation_seq_num --4244576
         and             bill_sequence_id = pConfigBillId
         and             created_by = pConfigBillId
         and             component_quantity = 0;

         -- Delete club_tab_arr and  asc_date_arr to process next item in club_comp_cur
         if club_tab_arr.count > 0 then
          for x7 in club_tab_arr.FIRST..club_tab_arr.LAST
            loop
                club_tab_arr.DELETE(x7);
            end loop;
         end if;

         if asc_date_arr.count > 0 then
          for x8 in asc_date_arr.FIRST..asc_date_arr.LAST
            loop
                asc_date_arr.DELETE(x8);
            end loop;
         end if;

      end loop;       -- End loop of club_comp_cur

-- end new code 3222932







    /*----------------------------------------------+
       Update item sequence id.
       To address configuration BOM restructure enhancements,
       item sequence is being updated such that there are no
       duplicate sequences, and in the logical order of components
       selection from the parent model BOM.
       The Item Sequence Increment is based on the profile
       "BOM:Item Sequence Increment".
     +----------------------------------------------*/

  --
  -- Get item sequence increment
  --
  p_seq_increment := fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT');
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Item Seq Increment::'||to_char(p_seq_increment), 1);
  END IF;

  --
  -- update item_num of top model
  --
  p_item_num := p_item_num + p_seq_increment;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('create_bom_data_ml: ' || 'p_item_num::'||to_char(p_item_num), 2);
  END IF;

  update bom_inventory_comps_interface
  set item_num = p_item_num
  where bill_sequence_id = pConfigBillId and parent_bill_seq_id = 0; -- Sushant Fixed bug #3374548

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Updated model row::'||sql%rowcount, 2);
  END IF;

  p_item_num := p_item_num + p_seq_increment;

  oe_debug_pub.add('create_bom_data_ml: ' || 'config bill id ::'|| pConfigBillId , 2);


  --
  -- get bill_sequence_id of top model
  --
  select common_bill_sequence_id
  into p_bill_seq_id
  from bom_bill_of_materials
  where assembly_item_id =
	(select component_item_id
	from bom_inventory_comps_interface
	where  bill_sequence_id = pConfigBillId and parent_bill_seq_id = 0)   -- Sushant Fixed bug #3374548
  and organization_id = pOrgId
  and alternate_bom_designator is null;

  oe_debug_pub.add('create_bom_data_ml: ' || 'common bill seq id ::'|| p_bill_seq_id , 2);
  --
  -- call update_item_num procedure with top model
  -- this will update item_num for the rest of the items
  --
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Calling update_item_num will p_bill_seq_id::'||to_char(p_bill_seq_id)||' and p_item_num::'||to_char(p_item_num), 2);
  END IF;

  update_item_num(
	p_bill_seq_id,
	p_item_num,
	pOrgId,
	p_seq_increment);




   begin
   select organization_id, assembly_item_id , creation_date
    into v_bom_organization_id, v_bom_assembly_item_id, v_bom_creation_date
    from bom_bill_of_materials where bill_sequence_id = pConfigBillId  ;

   exception
    when others then

  	oe_debug_pub.add('create_bom_data_ml: ' || SQLERRM ,2);
  	oe_debug_pub.add('create_bom_data_ml: ' || SQLCODE ,2);

    end ;



  	oe_debug_pub.add('create_bom_data_ml: ' || 'count ' || v_bom_count ,2);
  	oe_debug_pub.add('create_bom_data_ml: ' || 'org ' || v_bom_organization_id  ,2);
  	oe_debug_pub.add('create_bom_data_ml: ' || 'assid ' || v_bom_assembly_item_id ,2);
  	oe_debug_pub.add('create_bom_data_ml: ' || 'date ' || v_bom_creation_date ,2);
  /*-------------------------------------------+

    Load BOM_bill_of_materials
  +-------------------------------------------*/
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Before first insert into bill_of_materials.' ,2);
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Org: ' ||to_char(pOrgId), 2);
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Model: ' || to_char(pModelId), 2);
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Config: ' || to_char(pConfigId), 2);
  END IF;



  /* begin changes for bug 4271269 */

  if g_structure_type_id is null then

     begin

      select structure_type_id into g_structure_type_id from bom_alternate_designators
      where alternate_designator_code is null ;

     exception
     when others then
         IF PG_DEBUG <> 0 THEN
  	    oe_debug_pub.add('create_bom_data_ml: ' || 'others error while retrieving structure_type_id .' ,2);
  	    oe_debug_pub.add('create_bom_data_ml: ' || 'defaulting structure_type_id to 1 .' ,2);
            g_structure_type_id := 1;

         END IF;

     end ;



     IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('create_bom_data_ml: ' || 'structure_type_id is ' || g_structure_type_id  ,2);
     END IF;

  end if ;

  /* end changes for bug 4271269 */




  -- As per BOM team, they have added two new fileds
  -- PK1_value and PK2_VAlue in 11.5.10 and R12
  -- These fields are added for some PLM projects
  -- PK1_VALUE should be assembly_item_id
  -- PK2_VALUE should be organization id
  -- So far these two columns are populated thru database trigger
  -- bom is planning on droping this trigger in R12, hence we need
  lStmtNum := 145;
  xTableName := 'BOM_BILL_OF_MATERIALS';
  insert into BOM_BILL_OF_MATERIALS(
      assembly_item_id,
      organization_id,
      alternate_bom_designator,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      specific_assembly_comment,
      pending_from_ecn,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      assembly_type,
      bill_sequence_id,
      common_bill_sequence_id,
      source_bill_sequence_id,  /* COMMON BOM Project 12.0 */
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      implementation_date,               -- bug fix 3759118,FP 3810243
      structure_type_id,                -- bugfix 4271269
      effectivity_control,               -- bugfix 4271269
      pk1_value,
      pk2_value
      )
  select
      pConfigId,              		-- assembly_item_id
      pOrgId,                 		-- organization_id
      NULL,                   		-- alternate_bom_designator
      /* Begin Bugfix 8775615: Populate user id and login id.
      sysdate,                		-- last_update_date
      1,                      		-- last_update_by
      sysdate,                		-- creation date
      1,                      		-- created by
      1,                      		-- last_update_login
      */
      sysdate,                		-- last_update_date
      gUserId,                      	-- last_update_by
      sysdate,                		-- creation date
      gUserId,                      	-- created by
      gLoginId,                  	-- last_update_login
      -- End Bugfix 8775615
      b.specific_assembly_comment,	-- specific assembly comment /*Bugfix 2115056*/
      NULL,                   		-- pending from ecn
       -- Begin Bugfix 2115056
      b.attribute_category,             -- attribute category
      b.attribute1,                   	-- attribute1
      b.attribute2,                   	-- attribute2
      b.attribute3,                   	-- attribute3
      b.attribute4,                   	-- attribute4
      b.attribute5,                   	-- attribute5
      b.attribute6,                   	-- attribute6
      b.attribute7,                   	-- attribute7
      b.attribute8,                   	-- attribute8
      b.attribute9,                   	-- attribute9
      b.attribute10,                   	-- attribute10
      b.attribute11,                   	-- attribute11
      b.attribute12,                  	-- attribute12
      b.attribute13,                   	-- attribute13
      b.attribute14,                 	-- attribute14
      b.attribute15,                   	-- attribute15
      -- End Bugfix 2115056
      b.assembly_type,        		-- assembly_type
      pConfigBillId,
      pConfigBillId,
      pConfigBillId,                    -- source_bill_sequence_id  COMMON BOM Project 12.0
      NULL,                   		-- request id
      NULL,                   		-- program_application_id
      NULL,                   		-- program id
      NULL,                    		-- program date
      SYSDATE,                           --  implementation date bug fix 3759118,FP 3810243
      g_structure_type_id,               -- bugfix 4271269   structure_type_id
      1,                                  -- bugfix 4271269   effectivity_control
      pconfigid,
      porgid
  from    bom_bill_of_materials b
  where   b.assembly_item_id = pModelId
  and     b.organization_id  = pOrgId
  and     b.alternate_bom_designator is NULL;

  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add ('create_bom_data_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount, 1 );
  END IF;

  /*-----------------------------------------------+
    Load Bom_inventory_components
  +----------------------------------------------*/
  IF PG_DEBUG <> 0 THEN
  	oe_debug_pub.add('create_bom_data_ml: ' || 'Before second insert into bom_inventory_components. ', 2);
  END IF;
  lStmtNum := 310;
  xTableName := 'BOM_INVENTORY_COMPONENTS';
  insert into BOM_INVENTORY_COMPONENTS
      (
        operation_seq_num,
        component_item_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        item_num,
        component_quantity,
        component_yield_factor,
        component_remarks,
        effectivity_date,
        change_notice,
        implementation_date,
        disable_date,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        planning_factor,
        quantity_related,
        so_basis,
        optional,
        mutually_exclusive_options,
        include_in_cost_rollup,
        check_atp,
        shipping_allowed,
        required_to_ship,
        required_for_revenue,
        include_on_ship_docs,
        include_on_bill_docs,
        low_quantity,
        high_quantity,
        acd_type,
        old_component_sequence_id,
        component_sequence_id,
        common_component_sequence_id,             /* COMMON BOM Project 12.0 */
        bill_sequence_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        wip_supply_type,
        operation_lead_time_percent,
        revised_item_sequence_id,
        supply_locator_id,
        supply_subinventory,
        pick_components,
	bom_item_type,
	optional_on_model,	--isp bom
	parent_bill_seq_id,	--isp bom
	plan_level,		--isp bom
	model_comp_seq_id	--isp bom
        , basis_type            /* LBM change */
        )
   select
        b.operation_seq_num,
        b.component_item_id,
        /* Begin Bugfix 8775615: Populate user id and login id.
	b.last_update_date,
        1,	-- last_updated_by
        b.creation_date,
        1,      -- created_by
        b.last_update_login,
	*/
	b.last_update_date,
        gUserId,	-- last_updated_by
        b.creation_date,
        gUserId,        -- created_by
        gLoginId,       -- last_update_login
	-- End Bugfix 8775615
        b.item_num,
        b.component_quantity,
        b.component_yield_factor,
        b.component_remarks,
        b.effectivity_date,
        b.change_notice,
        b.implementation_date,
	-- 3222932 Chg g_futuredate back to NULL
        decode(b.disable_date,g_futuredate,to_date(NULL), b.disable_date),
        b.attribute_category,
        b.attribute1,
        b.attribute2,
        b.attribute3,
        b.attribute4,
        b.attribute5,
        b.attribute6,
        b.attribute7,
        b.attribute8,
        b.attribute9,
        b.attribute10,
        b.attribute11,
        b.attribute12,
        b.attribute13,
        b.attribute14,
        b.attribute15,
        b.planning_factor,
        b.quantity_related,
        b.so_basis,
        b.optional,
        b.mutually_exclusive_options,
        b.include_in_cost_rollup,
        decode( msi.bom_item_type , 1 , decode( msi.atp_flag , 'Y' , 1 , b.check_atp ) , b.check_atp ) ,  /* ATP changes for Model component */
        b.shipping_allowed,
        b.required_to_ship,
        b.required_for_revenue,
        b.include_on_ship_docs,
        b.include_on_bill_docs,
        b.low_quantity,
        b.high_quantity,
        b.acd_type,
        b.old_component_sequence_id,
        b.component_sequence_id,
        b.component_sequence_id,        -- common_component_sequence_id COMMON BOM Project 12.0
        b.bill_sequence_id,
        NULL,        /* request_id */
        NULL,     /* program_application_id */
        NULL,        /* program_id */
        sysdate,         /* program_update_date */
        b.wip_supply_type,
        b.operation_lead_time_percent,
        NULL,	-- 2524562
        b.supply_locator_id,
        b.supply_subinventory,
        b.pick_components,
	b.bom_item_type,
	b.optional_on_model,	--isp bom
	b.parent_bill_seq_id,	--isp bom
	b.plan_level,		--isp bom
	b.model_comp_seq_id	--isp bom
        , decode(b.basis_type,1,null,b.basis_type)          /* LBM Change */
    from   bom_inventory_comps_interface b , mtl_system_items msi
    where  b.bill_sequence_id = pConfigBillId
      and  b.component_item_id = msi.inventory_item_id
      and  msi.organization_id = pOrgId ;


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_bom_data_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount, 1);
    END IF;



        /*-----------------------------------------------+
              Populate Substitutes for Mandatory components
        +----------------------------------------------*/
        IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('create_bom_data_ml: ' || 'Before second insert into bom_inventory_components. ', 2);
        END IF;
        lStmtNum := 315;
        xTableName := 'BOM_SUBSTITUTE_COMPONENTS';




          insert into bom_substitute_components (
                   substitute_component_id
                  ,substitute_item_quantity
                  ,component_sequence_id
                  ,acd_type
                  ,change_notice
                  ,attribute_category
                  ,attribute1
                  ,attribute2
                  ,attribute3
                  ,attribute4
                  ,attribute5
                  ,attribute6
                  ,attribute7
                  ,attribute8
                  ,attribute9
                  ,attribute10
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,original_system_reference
                  ,enforce_int_requirements
                  ,request_id
                  ,program_application_id
                  ,program_id
                  ,program_update_date
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
               )
               select
                   s.substitute_component_id            -- substitute_component_id
                  ,s.substitute_item_quantity
                  ,b.component_sequence_id
                  ,s.acd_type
                  ,s.change_notice
                  ,s.attribute_category
                  ,s.attribute1
                  ,s.attribute2
                  ,s.attribute3
                  ,s.attribute4
                  ,s.attribute5
                  ,s.attribute6
                  ,s.attribute7
                  ,s.attribute8
                  ,s.attribute9
                  ,s.attribute10
                  ,s.attribute11
                  ,s.attribute12
                  ,s.attribute13
                  ,s.attribute14
                  ,s.attribute15
                  ,s.original_system_reference
                  ,s.enforce_int_requirements
                  ,FND_GLOBAL.CONC_REQUEST_ID /* REQUEST_ID */
                  ,FND_GLOBAL.PROG_APPL_ID /* PROGRAM_APPLICATION_ID */
                  ,FND_GLOBAL.CONC_PROGRAM_ID /* PROGRAM_ID */
                  ,sysdate /* PROGRAM_UPDATE_DATE */
                  ,sysdate /* LAST_UPDATE_DATE */
                  ,gUserId /* LAST_UPDATED_BY  */
                  ,sysdate /* CREATION_DATE */
                  ,gUserId /* CREATED_BY  */
                  ,gLoginId /* LAST_UPDATE_LOGIN */
                  /*
                  ,request_id
                  ,program_application_id
                  ,program_id
                  ,program_update_date
                  ,last_update_date
                  ,last_updated_by
                  ,creation_date
                  ,created_by
                  ,last_update_login
                  */

    from   bom_inventory_comps_interface b , bom_inventory_components bic, bom_substitute_components s
    where  b.bill_sequence_id = pConfigBillId
      and  ABS(b.model_comp_seq_id) = bic.component_sequence_id
      and  bic.optional = 2                                      /* only mandatory components */
      and  bic.component_sequence_id = s.component_sequence_id ;






    IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add ('create_bom_data_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount, 1);
    END IF;















   /* -------------------------------------------------------------------------+
         Insert into BOM_REFERENCE_DESIGNATORS table
   +--------------------------------------------------------------------------*/
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_data_ml: ' || 'Before third insert into bom_reference_designators. ', 2);
   END IF;
   lStmtNum := 320;
   xTableName := 'BOM_REFERENCE_DESIGNATORS';
   insert into BOM_REFERENCE_DESIGNATORS
       (
       component_reference_designator,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       ref_designator_comment,
       change_notice,
       component_sequence_id,
       acd_type,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15
       )
    select
       r.component_reference_designator,
       /* Begin Bugfix 8775615: Populate user id and login id.
       SYSDATE,
       1,
       SYSDATE,
       1,
       1,
       */
       SYSDATE,		-- last_update_date
       gUserId,		-- last_updated_by
       SYSDATE,		-- creation_date
       gUserId,		-- created_by
       gLoginId,	-- last_update_login
       -- End Bugfix 8775615
       r.REF_DESIGNATOR_COMMENT,
       NULL,
       ic.COMPONENT_SEQUENCE_ID,
       r.ACD_TYPE,
       NULL,
       NULL,
       NULL,
       NULL,
       r.ATTRIBUTE_CATEGORY,
       r.ATTRIBUTE1,
       r.ATTRIBUTE2,
       r.ATTRIBUTE3,
       r.ATTRIBUTE4,
       r.ATTRIBUTE5,
       r.ATTRIBUTE6,
       r.ATTRIBUTE7,
       r.ATTRIBUTE8,
       r.ATTRIBUTE9,
       r.ATTRIBUTE10,
       r.ATTRIBUTE11,
       r.ATTRIBUTE12,
       r.ATTRIBUTE13,
       r.ATTRIBUTE14,
       r.ATTRIBUTE15
    from
       bom_inventory_components ic,
       bom_reference_designators r,
       bom_bill_of_materials b
    where   b.assembly_item_id = pConfigId
       and     b.organization_id  = pOrgId
       and     ic.bill_sequence_id = b.bill_sequence_id
       and     r.component_sequence_id = abs(ic.model_comp_seq_id)	-- previously last_update_login
       and     nvl(r.acd_type,0) <> 3;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_bom_data_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount,1 );
    END IF;



    -- start 3674833
    -- need to insert reference designators of remaining components


    if model_comp_seq_id_arr.count > 0 then
                  prev_comp_item_id := 0;
          for x1 in model_comp_seq_id_arr.FIRST..model_comp_seq_id_arr.LAST
            loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add ( ' Model_Comp_seq (' ||x1|| ') = ' ||model_comp_seq_id_arr(x1)
                                                ||' Component_item_id (' ||x1|| ') = ' ||component_item_id_arr(x1),1);
             END IF;


                 -- commented if condition for bug 3793286 IF prev_comp_item_id <> component_item_id_arr(x1) then



		 /* bugfix 3985173 : Commented following code since there could be instances when same
                 component with same op seq number is appearing multiple times for a config bom. In
                 that scenario , following query will return ORA-01422 error.

                         -- Determine the component_sequence_id into which this item has been clubbed
                         select
                                bic.component_sequence_id into club_component_sequence_id
                         from
                                bom_inventory_components bic,
                                bom_bill_of_materials bom
                         where  bom.assembly_item_id = pConfigId
                         and    bom.organization_id  = pOrgId
                         and    bic.bill_sequence_id = bom.bill_sequence_id
                         and    bic.component_item_id = component_item_id_arr(x1);
                         prev_comp_item_id := component_item_id_arr(x1);
		 Comment of bugfix 3985173 ends here */

                -- bugfix 3985173 : New code will loop through component seq and insert
                -- into bom_reference_designator
                for a1 in club_comp_seq ( component_item_id_arr(x1), operation_seq_num_arr(x1) ) loop  --4244576

                 club_component_sequence_id := a1.comp_seq_id;


                 -- insert into BOM_REFERENCE_DESIGNATORS for the corresponding model_comp_seq_id
                 -- if it has not already been inserted.
                 IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add ('club_component_sequence_id is '||club_component_sequence_id, 1);
                 END if;
                 IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add ('Trying to insert into BOM_REFERENCE_DESIGNATORS', 1);
                 END if;
                 begin
                 insert into BOM_REFERENCE_DESIGNATORS
                                 (
                                  component_reference_designator,
                                  last_update_date,
                                  last_updated_by,
                                  creation_date,
                                  created_by,
                                  last_update_login,
                                  ref_designator_comment,
                                  change_notice,
                                  component_sequence_id,
                                  acd_type,
                                  request_id,
                                  program_application_id,
                                  program_id,
                                  program_update_date,
                                  attribute_category,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15
                                 )
                                 select
                                  r.component_reference_designator,
                                  /* Begin Bugfix 8775615: Populate user id and login id.
				  SYSDATE,
                                  1,
                                  SYSDATE,
                                  1,
                                  1,
				  */
				  SYSDATE,	-- last_update_date
                                  gUserId,	-- last_updated_by
                                  SYSDATE,	-- creation_date
                                  gUserId,	-- created_by
                                  gLoginId,	-- last_update_login
				  -- End Bugfix 8775615
                                  r.REF_DESIGNATOR_COMMENT,
                                  NULL,
                                  club_component_sequence_id,
                                  r.ACD_TYPE,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  r.ATTRIBUTE_CATEGORY,
                                  r.ATTRIBUTE1,
                                  r.ATTRIBUTE2,
                                  r.ATTRIBUTE3,
                                  r.ATTRIBUTE4,
                                  r.ATTRIBUTE5,
                                  r.ATTRIBUTE6,
                                  r.ATTRIBUTE7,
                                  r.ATTRIBUTE8,
                                  r.ATTRIBUTE9,
                                  r.ATTRIBUTE10,
                                  r.ATTRIBUTE11,
                                  r.ATTRIBUTE12,
                                  r.ATTRIBUTE13,
                                  r.ATTRIBUTE14,
                                  r.ATTRIBUTE15
                                 from
                                                 bom_reference_designators r
						  --added abs() was model_comp_seq would be -ve value
                                 where   r.component_sequence_id = abs(model_comp_seq_id_arr(x1))
                                 and     nvl(r.acd_type,0) <> 3;
                        exception
                                when others then
                                IF PG_DEBUG <> 0 THEN
                                        oe_debug_pub.add ('The record for this designator and component sequence already exists in BOM_REFERENCE_DESIGNATORS', 1);
                                END IF;
                        end;
                        IF PG_DEBUG <> 0 THEN
                                oe_debug_pub.add ('For this record '||sql%rowcount||' records are inserted in bom_reference_designators', 1);
                        END if;
	        end loop; -- 3985173 : end of club_comp_seq cursor loop
                prev_comp_item_id := component_item_id_arr(x1); -- 3985173


              -- commented end if for bug 3793286 end if; -- 3985173




            end loop;
        end if;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add ('create_bom_data_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount,1 );
        END IF;
    -- end 3674833


   /*-----------------------------------------------------------+
       Update MTL_DESCR_ELEMENT_VALUES  table
   +------------------------------------------------------------*/

    xTableName := 'MTL_DESCR_ELEMENT_VALUES';
    lStmtNum   := 330;

    -- bugfix 2765635: This is a round-about fix for this issue by calling a custom-hook.
    --                 Refer bug for details.
    -- begin bugfix

    if CTO_CUSTOM_CATALOG_DESC.catalog_desc_method  = 'C'  then
	-- Call Custom API with details..

	IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add ('Prepare data for calling custom hook...');
	END IF;

    	DECLARE
    		cursor ctg is
		select ELEMENT_NAME
		from   mtl_descr_element_values
		where  inventory_item_id = pConfigId;

 		l_catalog_dtls 	CTO_CUSTOM_CATALOG_DESC.CATALOG_DTLS_TBL_TYPE;
		l_params	CTO_CUSTOM_CATALOG_DESC.INPARAMS;
		i 		NUMBER;
		original_count 	NUMBER;
		l_return_status VARCHAR2(1);

    	BEGIN
        	i := 1;
		l_return_status := FND_API.G_RET_STS_SUCCESS;

		for rec in ctg
		loop
	    		l_catalog_dtls(i).cat_element_name  := rec.element_name;
	    		l_catalog_dtls(i).cat_element_value := NULL;
	    		IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('l_catalog_dtls('||i||').cat_element_name = '||
									rec.element_name);
			END IF;
	    		i := i+1;
		end loop;

		original_count := l_catalog_dtls.count;

             -- bugfix 4081613: Do not execute the rest of the code if cursor ctg did not fetch any rows.
             if original_count > 0 then
		l_params.p_item_id := pConfigId;
		l_params.p_org_id  := pOrgId;

		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('Parameter passed: l_params.p_item_id = '||l_params.p_item_id ||
     	                             	     '; l_params.p_org_id = '||l_params.p_org_id );
		END IF;

		CTO_CUSTOM_CATALOG_DESC.user_catalog_desc (
					p_params => l_params,
					p_catalog_dtls => l_catalog_dtls,
					x_return_status => l_return_status);

        	if( l_return_status = FND_API.G_RET_STS_ERROR ) then
        		IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('CTO_CUSTOM_CATALOG_DESC.user_catalog_desc returned exp error');
			END IF;
            		RAISE FND_API.G_EXC_ERROR ;

        	elsif( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
        		IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('CTO_CUSTOM_CATALOG_DESC.user_catalog_desc returned unexp error');
			END IF;
            		RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        	end if ;

		if l_catalog_dtls.count <> original_count then
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('Custom hook did not return same number of elements.'||
				 'Original_count='||original_count||
				 'New count = '||l_catalog_dtls.count);
			END IF;
			raise FND_API.G_EXC_ERROR;
		end if;

		for k in l_catalog_dtls.first..l_catalog_dtls.last
		loop
	   	   if l_catalog_dtls(k).cat_element_value is not null then
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('l_catalog_dtls('||k||').cat_element_name = '||
						l_catalog_dtls(k).cat_element_name||
		                  '; l_catalog_dtls('||k||').cat_element_value = '||
						l_catalog_dtls(k).cat_element_value);
			END IF;

    		       lStmtNum   := 331;

    		       update MTL_DESCR_ELEMENT_VALUES  i
    		       set    i.element_value = l_catalog_dtls(k).cat_element_value
   		       where  i.inventory_item_id = pConfigId
		       and    i.element_name = l_catalog_dtls(k).cat_element_name;
		       IF PG_DEBUG <> 0 THEN
   		       		oe_debug_pub.add (xTableName || '-'|| lStmtNum || ': ' || sql%rowcount,1 );
   		       END IF;

	   	   end if;
		end loop;

           end if; --bugfix 4081613

    	END;

    elsif CTO_CUSTOM_CATALOG_DESC.catalog_desc_method  = 'Y'  then
    	lStmtNum   := 332;
    	IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add ('Std feature : Rollup lower level model catalog desc to top level');
	END IF;
    	update MTL_DESCR_ELEMENT_VALUES  i
    	set    i.element_value =
       			( select /*+ ORDERED */
	     			NVL(max(v.element_value),i.element_value)
         		  from
            			bom_bill_of_materials         bi,
            			bom_inventory_components      bc1,
            			bom_inventory_components      bc2,
            			bom_dependent_desc_elements   be,
            			mtl_descr_element_values      v
         		  where    bi.assembly_item_id       = pConfigId
                          and   bi.organization_id        = pOrgId
                          and   bi.alternate_bom_Designator is null
                          and   bc1.bill_sequence_id      = bi.bill_sequence_id
                          and   bc2.component_sequence_id = abs(bc1.model_comp_seq_id)	-- previously last_update_login
                          and   be.bill_sequence_id       = bc2.bill_sequence_id
                          and   be.element_name           = i.element_name
                          and   v.inventory_item_id       = bc1.component_item_id
                          and   v.element_name            = i.element_name
   	                )
   	where i.inventory_item_id = pConfigId;
   	IF PG_DEBUG <> 0 THEN
   		oe_debug_pub.add (xTableName || '-'|| lStmtNum || ': ' || sql%rowcount,1 );
   	END IF;
    else

    	lStmtNum   := 333;
    	IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add ('Std feature : DO NOT Rollup lower level model catalog desc to top level');
	END IF;
    	update MTL_DESCR_ELEMENT_VALUES  i
    	set    i.element_value =
       			( select /*+ ORDERED */
	     			NVL(max(v.element_value),i.element_value)
         		  from
            			bom_bill_of_materials         bi,
            			bom_inventory_components      bc1,
            			bom_inventory_components      bc2,
            			bom_dependent_desc_elements   be,
            			mtl_descr_element_values      v
         		  where    bi.assembly_item_id       = pConfigId
                          and   bi.organization_id        = pOrgId
                          and   bi.alternate_bom_Designator is null
                          and   bc1.bill_sequence_id      = bi.bill_sequence_id
                          and   bc2.component_sequence_id = abs(bc1.model_comp_seq_id)	-- previously last_update_login
                          and   be.bill_sequence_id       = bc2.bill_sequence_id
                          and   be.element_name           = i.element_name
                          and   v.inventory_item_id       = bc1.component_item_id
                          and   v.element_name            = i.element_name
                          -- bugfix 2590966
                          -- Following code eliminates lower level configurations
			  -- FP Bug Fix 4761813
			  -- Tuned the query to user not exists for perfomance reason
			  and not exists
                          (
                          SELECT 'x' FROM MTL_SYSTEM_ITEMS
                          WHERE ORGANIZATION_ID = pOrgId
                          AND BC1.COMPONENT_ITEM_ID = INVENTORY_ITEM_ID
                          AND BASE_ITEM_ID IS NOT NULL
                          AND BOM_ITEM_TYPE = 4
                          AND REPLENISH_TO_ORDER_FLAG = 'Y'
                          )
   	                   -- end bugfix 2590966
   	                )
   	where i.inventory_item_id = pConfigId;
   	IF PG_DEBUG <> 0 THEN
   		oe_debug_pub.add (xTableName || '-'|| lStmtNum || ': ' || sql%rowcount,1 );
	END IF;
    end if;

    -- end bugfix 2765635

   /*---------------------------------------------------------------------+
         Update descriptions of the config items in
         the MTL_SYSTEM_ITEMS
   +----------------------------------------------------------------------*/

   lStmtNum   := 350;
   xTableName := 'MTL_SYSTEM_ITMES';
   status := bmlupid_update_item_desc(pConfigid,
                                      pOrgId,
                                      xErrorMessage);
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_data_ml: ' || 'bmlupid_update_item_desc returned ' || status,1 );
   END IF;

   if status <> 0 then
      raise FND_API.G_EXC_ERROR;
   end if;

   lStmtNum   := 360;
   --
   -- Bug 13728349
   -- Using the source bill sequence id
   --
   -- select  common_bill_sequence_id
   select  NVL(source_bill_sequence_id, common_bill_sequence_id)
   into    l_from_sequence_id
   from    bom_bill_of_materials
   where   assembly_item_id = pModelId
   and     organization_id  = pOrgId
   and     alternate_bom_designator is NULL;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_bom_data_ml: ' || 'before copying attachments l_from_sequence_id = ' || l_from_sequence_id,1 );
   END IF;

   lStmtNum   := 370;
   fnd_attached_documents2_pkg.copy_attachments(
                        X_from_entity_name      =>  'BOM_BILL_OF_MATERIALS',
                        X_from_pk1_value        =>  l_from_sequence_id,
                        X_from_pk2_value        =>  '',
                        X_from_pk3_value        =>  '',
                        X_from_pk4_value        =>  '',
                        X_from_pk5_value        =>  '',
                        X_to_entity_name        =>  'BOM_BILL_OF_MATERIALS',
                        X_to_pk1_value          =>  pConfigBillId,
                        X_to_pk2_value          =>  '',
                        X_to_pk3_value          =>  '',
                        X_to_pk4_value          =>  '',
                        X_to_pk5_value          =>  '',
                        X_created_by            =>  1,
                        X_last_update_login     =>  '',
                        X_program_application_id=>  '',
                        X_program_id            =>  '',
                        X_request_id            =>  ''
                        );

   lStmtNum   := 380;

  /* Clean up bom_inventory_comps_interface  */

  delete from bom_inventory_comps_interface
  where  bill_sequence_id = pConfigBillId;

  --Bugfix 11056452
  lCnt := sql%rowcount;
  IF PG_DEBUG <> 0 THEN
    oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
  END IF;

  delete from bom_bill_of_mtls_interface
  where bill_sequence_id = pConfigBillId;

  lCnt := sql%rowcount;
  IF PG_DEBUG <> 0 THEN
    oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
  END IF;

  return(1);

EXCEPTION
        WHEN NO_DATA_FOUND THEN
        	xErrorMessage:='CTOCBOMB:'||lStmtNum||':'||substrb(sqlerrm,1,150);

                -- Sushant Fixed bug #3374548
                /* Clean up bom_inventory_comps_interface  */
                delete from bom_inventory_comps_interface
                where  bill_sequence_id = pConfigBillId;

		--Bugfix 11056452
		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
		END IF;

                delete from bom_bill_of_mtls_interface
                where bill_sequence_id = pConfigBillId;

		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
		END IF;

        	return(0);

        when FND_API.G_EXC_ERROR then
        	xErrorMessage:='CTOCBOMB:'||lStmtNum||':'||substrb(sqlerrm,1,150);
		xMessageName := 'CTO_CREATE_BOM_ERROR';
        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add('create_bom_data_ml: ' || 'eXpected Error: ' || xErrorMessage, 1);
        		oe_debug_pub.add('create_bom_data_ml: ' || 'eXpected Error: ' || xMessageName , 1);
        	END IF;

                -- Sushant Fixed bug #3374548
                /* Clean up bom_inventory_comps_interface  */
                delete from bom_inventory_comps_interface
                where  bill_sequence_id = pConfigBillId;

		--Bugfix 11056452
		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
		END IF;

                delete from bom_bill_of_mtls_interface
                where bill_sequence_id = pConfigBillId;

		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
		END IF;


		return(0);

	when FND_API.G_EXC_UNEXPECTED_ERROR then	-- bugfix 2765635
        	xErrorMessage:='CTOCBOMB:'||lStmtNum||':'||substrb(sqlerrm,1,150);
        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add('Unexpected Error: ' || xErrorMessage);
		END IF;

                -- Sushant Fixed bug #3374548
                /* Clean up bom_inventory_comps_interface  */
                delete from bom_inventory_comps_interface
                where  bill_sequence_id = pConfigBillId;

		--Bugfix 11056452
		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
		END IF;

                delete from bom_bill_of_mtls_interface
                where bill_sequence_id = pConfigBillId;

		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
		END IF;

		return(0);

        WHEN OTHERS THEN
        	xErrorMessage:='CTOCBOMB:'||lStmtNum||':'||substrb(sqlerrm,1,150);
		xMessageName := 'CTO_CREATE_BOM_ERROR';
        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add('create_bom_data_ml: ' || 'other Error: ' || xErrorMessage, 1);
        	END IF;

                -- Sushant Fixed bug #3374548
                /* Clean up bom_inventory_comps_interface  */
                delete from bom_inventory_comps_interface
                where  bill_sequence_id = pConfigBillId;

		--Bugfix 11056452
		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bici, rows::'||lCnt);
		END IF;

                delete from bom_bill_of_mtls_interface
                where bill_sequence_id = pConfigBillId;

		lCnt := sql%rowcount;
                IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('Deleted from bmi, rows::'||lCnt);
		END IF;

        	return(0);

END create_bom_data_ml;

--b2307936

/*------------------------------------------------+
This procedure is called in a loop to update the
Item Sequence Number on the components of the configuration
BOM such that there are no duplicates, and the logical order
in which they are selected from the model BOM is maintained.
+------------------------------------------------*/
PROCEDURE update_item_num(
	p_parent_bill_seq_id IN NUMBER,
	p_item_num IN OUT NOCOPY NUMBER,  /* NOCOPY Project */
	p_org_id IN NUMBER,
	p_seq_increment	IN NUMBER)

IS

    CURSOR c_update_item_num(p_parent_bill_seq_id number) IS
	select component_sequence_id,
		component_item_id
	from bom_inventory_comps_interface
	where parent_bill_seq_id = p_parent_bill_seq_id
	FOR UPDATE OF item_num;

    p_bill_seq_id number;

BEGIN

  FOR v_update_item_num IN c_update_item_num(p_parent_bill_seq_id)
  LOOP

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('update_item_num: ' || 'In update loop for item '||to_char(v_update_item_num.component_item_id), 2);
	END IF;

  	--
  	-- update item_num of child of this model
  	--
  	update bom_inventory_comps_interface
  	set item_num = p_item_num
  	where current of c_update_item_num;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('update_item_num: ' || 'Updated item '||to_char(v_update_item_num.component_item_id)|| ' with item num '||to_char(p_item_num), 2);
	END IF;

  	p_item_num := p_item_num + p_seq_increment;

  	--
  	-- get bill_sequence_id of child
  	--
	BEGIN

  	select common_bill_sequence_id
  	into p_bill_seq_id
  	from bom_bill_of_materials
  	where assembly_item_id = v_update_item_num.component_item_id
	and organization_id = p_org_id
	and alternate_bom_designator is null;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('update_item_num: ' || 'Calling update_item_num will p_bill_seq_id::'||to_char(p_bill_seq_id)||' and p_item_num::'||to_char(p_item_num), 2);
	END IF;

	update_item_num(
		p_bill_seq_id,
		p_item_num,
		p_org_id,
		p_seq_increment);

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('update_item_num: ' || 'This component '||to_char(v_update_item_num.component_item_id)||' does not have a BOM', 2);
		END IF;

	END;

  END LOOP;

END update_item_num;


function inherit_op_seq_ml(
  		pLineId        in   oe_order_lines.line_id%TYPE := NULL,
  		pOrgId         in   oe_order_lines.ship_from_org_id%TYPE := NULL,
  		pModelId       in   bom_bill_of_materials.assembly_item_id%TYPE := NULL ,
  		pConfigBillId  in   bom_inventory_components.bill_sequence_id%TYPE := NULL,
  		xErrorMessage  out NOCOPY  VARCHAR2,
  		xMessageName   out NOCOPY  VARCHAR2)
return integer is

	CURSOR c_incl_items_all_level (	xOrgId  	mtl_system_items.organization_id%TYPE,
					xLineId 	bom_cto_order_lines.line_id%TYPE,
					xConfigBillId	bom_inventory_components.bill_sequence_id%TYPE ,
					xSchShpdt 	date,
					xEstReldt 	date ) IS
	select  bbm.organization_id,
		nvl(bic.operation_seq_num,1) operation_seq_num ,	-- 2433862
		nvl(bet.operation_seq_num,1) parent_op_seq_num, 	-- 2433862
     		bic.component_item_id,
     		bic.item_num,
     		decode(nvl(bic.basis_type,1),1,bic.component_quantity * (bcol1.ordered_quantity  / bcol2.ordered_quantity ),bic.component_quantity) component_qty,
          	bic.component_yield_factor,
                bic.component_remarks,                                  --Bugfix 7188428
     		bic.attribute_category,
     		bic.attribute1,
     		bic.attribute2,
     		bic.attribute3,
     		bic.attribute4,
     		bic.attribute5,
     		bic.attribute6,
     		bic.attribute7,
     		bic.attribute8,
     		bic.attribute9,
     		bic.attribute10,
     		bic.attribute11,
     		bic.attribute12,
     		bic.attribute13,
     		bic.attribute14,
     		bic.attribute15,
     		bic.so_basis,
     		bic.include_in_cost_rollup,
     		bic.check_atp,
     		bic.required_for_revenue,
     		bic.include_on_ship_docs,
     		bic.include_on_bill_docs,
     		bic.wip_supply_type,
     		bic.component_sequence_id,            		-- model comp seq for later use
     		bic.supply_subinventory,
     		bic.supply_locator_id,
     		bic.bom_item_type,
		bic.bill_sequence_id,				-- parent_bill_seq_id
		bcol1.plan_level+1 plan_level,
		decode(                                         -- 3222932
                  greatest(bic.effectivity_date,sysdate),
                  bic.effectivity_date ,
                  bic.effectivity_date ,
                  sysdate ) eff_date,
                nvl(bic.disable_date,g_futuredate) dis_date     -- 3222932
                 , nvl(bic.basis_type,1) basis_type                                   /* LBM project */
	from 	bom_cto_order_lines 		bcol1,		-- COMPONENT
		bom_cto_order_lines		bcol2,		-- MODEL
		mtl_system_items 		si1,
     		mtl_system_items 		si2,
		bom_bill_of_materials 		bbm,
		bom_inventory_components 	bic,		-- Components
		bom_inventory_components 	bic1,		-- Parent
		bom_explosion_temp		bet
/*-----------------------------------------------------------------------------------------------------+
	For a multilevel model , ato_line_id=xLineId will not fetch included items  of lower level
	non-phantom models so Parent_ATO_Line_id is used in the join condition.
	e.g. For a bill like this :
		MODEL1
		..OC1
		...MODEL2 ( Phantom Model )
		....OC3
		.....MAND2
		..OC2
		...MODEL3 ( Non Phantom Model )
		....OC4
		.....MAND2

		Line id data in BCOL is as under :

		ITEM	    	LINE_ID 	LNK_TO_LINE_ID 		PRNT_ATO_LINE_ID	ATO_LINE_ID
		---------- 	-------	 	--------------	 	----------------	-----------
		MODEL1          1                              		1			1
		..OC1           2           	1              		1			1
		...MODEL2       3           	2              		1			1
		....OC3         4           	3              		1			1
		..OC2           5           	1              		1			1
		...MODEL3       6           	5              		1			1
		....OC4         7           	6              		6			1

		FOR join condition ato_line_id = xLine_id , MAND2 under OC4 will not be picked up while
		configuring MODEL3. So parent_atoline_id = xLine_id is used.
+------------------------------------------------------------------------------------------------------------*/
	where 	bcol1.parent_ato_line_id = xLineId
	and	bcol1.component_code = bet.component_code
	and     si1.organization_id = xOrgId
   	and     bcol1.inventory_item_id = si1.inventory_item_id
   	and     si1.bom_item_type in (1,2)      		-- model, option class
   	and     si2.inventory_item_id = bcol2.inventory_item_id
   	and     si2.organization_id = si1.organization_id
   	and     si2.bom_item_type = 1
   	-- Bugfix 2389283 : Commented bcol1.line_id = bcol2.line_id condition
	and     (bcol1.parent_ato_line_id  = bcol2.line_id
                  	and ( bcol1.bom_item_type <> 1
                        	or  (	bcol1.bom_item_type = 1
                             		and 	nvl(bcol1.wip_supply_type, 0) = 6
                             	    )
                            )
                )
            	-- or bcol1.line_id = bcol2.line_id  )
        and	bet.bill_sequence_id = xConfigBillId
	and	bet.top_bill_sequence_id = xConfigBillId
	and	bic1.component_sequence_id = bcol1.component_sequence_id
	and	bic1.bom_item_type in (1,2)
	and	bbm.assembly_item_id	= bic1.component_item_id
	and	bbm.organization_id	= si1.organization_id
	and	bbm.alternate_bom_designator is NULL
	and	bic.bill_sequence_id = DECODE(bbm.common_bill_sequence_id,bbm.bill_sequence_id,bbm.bill_sequence_id,bbm.common_bill_sequence_id)
	and    	bic.optional = 2
	and    	bic.bom_item_type = 4
	-- and    	bic.effectivity_date <= greatest( NVL(xSchShpdt,sysdate),sysdate) /* New Approach for effectivity dates */
	and    	bic.implementation_date is not null
	-- and    	NVL(bic.disable_date,NVL(xEstReldt, SYSDATE)+1) > NVL(xEstReldt,SYSDATE) /* NEw Approach for effectivity dates*/
	-- and	NVL(bic.disable_date,SYSDATE) >= SYSDATE;   /* New approach for effectivity dates */
        and     ( bic.disable_date is null or
                (bic.disable_date is not null and  bic.disable_date >= sysdate )) ;/* New Approach for Effectivity Dates */

	CURSOR c_model_oc_oi_rows(xConfigBillId bom_inventory_components.bill_sequence_id%TYPE) IS
	SELECT 		/*+ INDEX ( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11)  */
                        nvl(operation_seq_num,1) operation_seq_num,	-- 2433862
		        component_code,
			rowid
	from 		bom_explosion_temp
	where		bill_sequence_id = xConfigBillId
	and		component_code IS NOT NULL
	ORDER BY component_code;

	lStmtNumber 	number;
	lCnt		number;

        v_zero_qty_count      number ;
        v_zero_qty_component      number ;


  l_token1	      CTO_MSG_PUB.token_tbl;
  v_model_item_name   varchar2(2000) ;


 v_overlap_check  number := 0 ;

  TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  v_t_overlap_comp_item_id  num_tab;
  v_t_overlap_src_op_seq_num num_tab;
  v_t_overlap_src_eff_date   date_tab;
  v_t_overlap_src_disable_date date_tab;
  v_t_overlap_dest_op_seq_num  num_tab;
  v_t_overlap_dest_eff_date    date_tab;
  v_t_overlap_dest_disable_date date_tab;
  l_token2 CTO_MSG_PUB.token_tbl;
  l_model_name  varchar2(1000);

  test_var       number;  --Bug 7418622.FP for 7154767
	BEGIN






	lStmtNumber := 520;

	--
	-- Insert Option Classes and Option Items
	-- Compare to last insert , here we have an addl column
	-- component_code to insert comp_code of classes /items
	-- from bcol
	--

	INSERT INTO BOM_EXPLOSION_TEMP
	(     	top_bill_sequence_id,
 		organization_id,
 		plan_level,
 		sort_order,
		operation_seq_num,
      		component_item_id,
      		item_num,
      		component_quantity,
      		component_yield_factor,
      		component_remarks,                              --Bugfix 7188428
                context,					-- mapped to attribute_category in bic interface
      		attribute1,
      		attribute2,
      		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
      		attribute9,
     	 	attribute10,
     	 	attribute11,
     	 	attribute12,
     	 	attribute13,
     	 	attribute14,
     	 	attribute15,
     	 	planning_factor,
     	 	select_quantity,				-- mapped to quantity_related of bic interface
      		so_basis,
      		optional,					-- mapped to optional_on_model of bic interface
      		mutually_exclusive_options,
      		include_in_rollup_flag,		-- mapped to include_in_cost rollup of bic interface
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
      		component_sequence_id,
      		bill_sequence_id,
      		wip_supply_type,
      		pick_components,
      		base_item_id,					-- mapped to model_comp_seq_id of bic_interface
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
		component_code,					-- Additional
		line_id, 		        -- 2814257
		top_item_id,
		effectivity_date,               -- 3222932
                disable_date                    -- 3222932-- mapped to parent_bill_seq_id of bic interface
                , basis_type                    /* LBM project */
                ,assembly_item_id      /* Bug Fix: 4147224 */
      	)
	select 	pConfigBillId,                        		-- top bill sequence id
		bcol2.ship_from_org_id,				-- Model's organization_id
		(bcol1.plan_level-bcol2.plan_level),		-- Plan Level
		'1',      					-- Sort Order
		nvl(ic1.operation_seq_num,1),
      		decode(bcol1.config_item_id, NULL, ic1.component_item_id,bcol1.config_item_id),
      		ic1.item_num,
      Round(
           CTO_UTILITY_PK.convert_uom( bcol1.order_quantity_uom, msi_child.primary_uom_code, bcol1.ordered_quantity , msi_child.inventory_item_id )
          / CTO_UTILITY_PK.convert_uom(bcol2.order_quantity_uom, msi_parent.primary_uom_code, NVL(bcol2.ordered_quantity,1) , msi_parent.inventory_item_id )
          , 7) ,  -- qty = comp_qty / model_qty /* Decimal-Qty Support for Option Items */
      		ic1.component_yield_factor,
                ic1.component_remarks,                          --Bugfix 7188428
      		ic1.attribute_category,
      		ic1.attribute1,
      		ic1.attribute2,
      		ic1.attribute3,
      		ic1.attribute4,
      		ic1.attribute5,
      		ic1.attribute6,
      		ic1.attribute7,
      		ic1.attribute8,
      		ic1.attribute9,
      		ic1.attribute10,
      		ic1.attribute11,
      		ic1.attribute12,
      		ic1.attribute13,
      		ic1.attribute14,
      		ic1.attribute15,
      		100,                                  			-- planning_factor
      		2,                                    			-- quantity_related
      		decode(bcol1.config_item_id, NULL,
		decode(ic1.bom_item_type,4,ic1.so_basis,2),2),  	-- so_basis
      		1,                                    			-- optional
      		2,                                   			-- mutually_exclusive_options
      		decode(bcol1.config_item_id, NULL,
         		decode(ic1.bom_item_type,4,
				ic1.include_in_cost_rollup, 2),1), 	-- Cost_rollup
      		decode(bcol1.config_item_id, NULL,
			decode(ic1.bom_item_type,4,
				ic1.check_atp, 2),2), 			-- check_atp
      		2,                                    			-- shipping_allowed = NO
      		2,                                    			-- required_to_ship = NO
      		ic1.required_for_revenue,
      		ic1.include_on_ship_docs,
      		ic1.include_on_bill_docs,
      		bom_inventory_components_s.nextval,   			-- component sequence id
      		pConfigBillId,                        			-- bill sequence id
      		ic1.wip_supply_type,
      		2,                                    			-- pick_components = NO
      		decode(bcol1.config_item_id, NULL, (-1)*ic1.component_sequence_id, ic1.component_sequence_id),             			-- saved model comp seq for later use. If config item, then save model comp seq id as positive, otherwise negative.
      		ic1.supply_subinventory,
      		ic1.supply_locator_id,
      		decode(bcol1.config_item_id, NULL, ic1.bom_item_type, 4),
		bcol1.component_code,
		bcol1.line_id,						-- 2814257
		ic1.bill_sequence_id,
		decode(                                                 -- 3222932
                  greatest(ic1.effectivity_date,sysdate),
                  ic1.effectivity_date ,
                  ic1.effectivity_date ,
                  sysdate ),
                nvl(ic1.disable_date,g_futuredate)                      -- 3222932
                , nvl(ic1.basis_type,1)                                        /* LBM project */
		,bcol3.inventory_item_id        /* Bug Fix : 4147224 */
 	from    bom_inventory_components ic1,
    		bom_cto_order_lines bcol1,                     		-- Option
    		bom_cto_order_lines bcol2,                     		-- Parent-Model
    		bom_cto_order_lines bcol3 ,                             -- Parent-component
                mtl_system_items msi_child,
                mtl_system_items msi_parent
	where  	ic1.bill_sequence_id = (
        	select common_bill_sequence_id
        	from   bom_bill_of_materials bbm
        	where  organization_id = pOrgId
        	and    alternate_bom_designator is null
        	and    assembly_item_id =(
            		select distinct assembly_item_id
            		from    bom_bill_of_materials bbm1,
                   		bom_inventory_components bic1
            		where  bbm1.common_bill_sequence_id = bic1.bill_sequence_id
            		and    component_sequence_id        = bcol1.component_sequence_id
            		and    bbm1.assembly_item_id        = bcol3.inventory_item_id ))
  	and 	ic1.component_item_id           = bcol1.inventory_item_id
        and     msi_child.inventory_item_id = bcol1.inventory_item_id
        and     msi_child.organization_id = pOrgId
        and     msi_parent.inventory_item_id = bcol2.inventory_item_id
        and     msi_parent.organization_id = pOrgId
  	-- and 	ic1.effectivity_date  <= g_SchShpDate /* New Approach for effectivity dates */
        and     ic1.implementation_date is not null  --bug 4244147
  	-- and 	NVL(ic1.disable_date, (g_EstRelDate + 1)) >= greatest( nvl(  g_EstRelDate, sysdate) , sysdate) /* bug 3389846 */
        /*
        and  ( ic1.disable_date is null or
              (ic1.disable_date is not null and  ic1.disable_date >= greatest( nvl( g_EstRelDate, sysdate ) , sysdate )) #3389846
             )
        */
        and  ( ic1.disable_date is null or
             (ic1.disable_date is not null and  ic1.disable_date >= sysdate )) /* New Approach for Effectivity Dates */
  	and      (( ic1.optional = 1 and ic1.bom_item_type = 4)
               		or
            	( ic1.bom_item_type in (1,2)))
  	and     bcol1.ordered_quantity <> 0
  	and     bcol1.line_id <> bcol2.line_id              		-- not the top ato model
  	and     bcol1.parent_ato_line_id = bcol2.line_id
  	and     bcol1.parent_ato_line_id is not null
  	and     bcol1.link_to_line_id is not null
  	and     bcol2.line_id            = pLineId
  	and     bcol2.ship_from_org_id   = bcol1.ship_from_org_id
  	and     (bcol3.parent_ato_line_id  = bcol1.parent_ato_line_id
           		or
	     	bcol3.line_id = bcol1.parent_ato_line_id)
  	and     bcol3.line_id = bcol1.link_to_line_id;

    	lCnt := sql%rowcount ;

    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('inherit_op_seq_ml: ' || 'Second  -- Inserted in BE Temp ' || lCnt ||' Option item/Option class rows with bill seq id as '|| pConfigBillId,1);
    	END IF;








   select /*+ INDEX ( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11)  */
     count(*) into v_zero_qty_count from bom_explosion_temp
    where bill_sequence_id = pConfigBillId  and component_quantity = 0 ;

   oe_debug_pub.add( 'MODELS: CHECK Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;

   if( v_zero_qty_count > 0 ) then

      oe_debug_pub.add( 'Inherit_op_seq_ml:: SHOULD Raise Exception for Zero QTY Count '  || v_zero_qty_count , 1 ) ;


        select concatenated_segments into v_model_item_name
          from mtl_system_items_kfv
        where inventory_item_id = pModelId
          and rownum = 1 ;


       l_token1(1).token_name  := 'MODEL_NAME';
       l_token1(1).token_value := v_model_item_name ;


      cto_msg_pub.cto_message('BOM','CTO_ZERO_BOM_COMP' , l_token1 );

      raise fnd_api.g_exc_error;




   end if ;








  /* begin Extend Effectivity Dates for Option Items with disable date */


   --Bug 7418622.FP for 7154767
   /*update bom_explosion_temp set disable_date = g_futuredate
   where ( component_item_id ,  operation_seq_num, nvl(assembly_item_id,-1) , disable_date) in
   ( select component_item_id, operation_seq_num, nvl(assembly_item_id,-1), max(disable_date)
   from bom_inventory_comps_interface
   where bill_sequence_id = pConfigBillId
   group by component_item_id, operation_seq_num, assembly_item_id)
   and disable_date <> g_futuredate ;*/

   UPDATE bom_explosion_temp
   SET     disable_date = g_futuredate
   WHERE
         (
                component_item_id, operation_seq_num, NVL(assembly_item_id,-1), disable_date
         )
         IN
         (
                SELECT  component_item_id       ,
                        operation_seq_num       ,
                        NVL(assembly_item_id,-1),
                        MAX(disable_date)
                FROM    bom_explosion_temp
                WHERE   bill_sequence_id = pConfigBillId
                GROUP BY component_item_id,
                        operation_seq_num ,
                        assembly_item_id
        )
    AND disable_date <> g_futuredate ;

    test_var := sql%rowcount;

    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('Create_bom_ml: Extending the disable dates to future date = '||test_var,1);
       oe_debug_pub.add('Create_bom_ml: pconfigBillId = '||to_char(pConfigBillid),1);
    END IF;
    --Bug 7418622.FP for 7154767


   /* end Extend Effectivity Dates for Option Items with disable date */







    /* Effectivity Dates changes */
    /* moved Mandatory comps code to insert components after ordered items */

	lStmtNumber := 510;

	/*Insert Incl. items under Base Model */

	INSERT INTO bom_explosion_temp
	(
 		top_bill_sequence_id,
 		organization_id,
 		plan_level,
 		sort_order,
 		operation_seq_num,
      		component_item_id,
      		item_num,
      		component_quantity,
      		component_yield_factor,
                component_remarks,                              --Bugfix 7188428
      		context,					-- mapped to attribute_category in bic interface
      		attribute1,
      		attribute2,
      		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
      		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		select_quantity,				-- mapped to quantity_related of bic interface
      		so_basis,
      		optional,					-- mapped to optional_on_model in bic interface
      		mutually_exclusive_options,
      		include_in_rollup_flag,				-- mapped to include_in_cost rollup of bic interface
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
      		component_sequence_id,
      		bill_sequence_id,
      		wip_supply_type,
      		pick_components,
      		base_item_id,					-- mapped to model_comp_seq_id of bic_interface
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
		top_item_id,
		effectivity_date,                               -- 3222932
                disable_date                          -- 3222932-- mapped to parent_bill_seq_id in bic interface
                , basis_type    /* LBM project */
      	)
	select 	pConfigBillId,                  		-- top bill sequence id
		bbm.organization_id,				-- Model's organization_id
		1,						-- Plan Level, should be 0+1 for model's smc's
		'1',      					-- Sort Order
		nvl(bic.operation_seq_num,1),
     		bic.component_item_id,
     		bic.item_num,
     		bic.component_quantity  component_qty,
/*
please check whether this change is rquired
     decode( nvl(bic.basis_type,1), 1 , Round( ( bic.component_quantity * ( bcol1.ordered_quantity
          / bcol2.ordered_quantity)), 7 ) , Round(bic.component_quantity , 7 ) ) ,  * Decimal-Qty Support for Option Items, LBM project
*/
     		bic.component_yield_factor,
                bic.component_remarks,                          --Bugfix 7188428
     		bic.attribute_category,
     		bic.attribute1,
     		bic.attribute2,
     		bic.attribute3,
     		bic.attribute4,
     		bic.attribute5,
     		bic.attribute6,
     		bic.attribute7,
     		bic.attribute8,
     		bic.attribute9,
     		bic.attribute10,
     		bic.attribute11,
     		bic.attribute12,
     		bic.attribute13,
     		bic.attribute14,
     		bic.attribute15,
     		100,                                  		-- planning_factor
     		2,                                    		-- quantity_related
     		bic.so_basis,
     		2,                                    		-- optional
     		2,                                    		-- mutually_exclusive_options
     		bic.include_in_cost_rollup,
     		bic.check_atp,
     		2,                                    		-- shipping_allowed = NO
     		2,                                    		-- required_to_ship = NO
     		bic.required_for_revenue,
     		bic.include_on_ship_docs,
     		bic.include_on_bill_docs,
     		bom_inventory_components_s.nextval,   		-- component sequence id
     		pConfigBillId,                        		-- bill sequence id
     		bic.wip_supply_type,
     		2,                                    		-- pick_components = NO
     		(-1)*bic.component_sequence_id,            		-- model comp seq for later use
     		bic.supply_subinventory,
     		bic.supply_locator_id,
     		bic.bom_item_type,
		bic.bill_sequence_id,
		decode(                                         -- 3222932
                  greatest(bic.effectivity_date,sysdate),
                  bic.effectivity_date ,
                  bic.effectivity_date ,
                  sysdate ),
                nvl(bic.disable_date,g_futuredate)              -- 3222932
                , nvl(bic.basis_type,1)                                /* LBM project */
	from 	bom_cto_order_lines 		bcol,
		bom_bill_of_materials 		bbm,
		bom_inventory_components 	bic
	where   bcol.line_id = pLineId
	and     bcol.ordered_quantity <> 0
	-- bugfix 2389283 and	instr(bcol.component_code,'-',1,1) = 0 /* To identify Top Model */
	and     bcol.inventory_item_id = pModelId
	and	bbm.organization_id = pOrgId
	and	bcol.inventory_item_id = bbm.assembly_item_id
	and     bbm.alternate_bom_designator is NULL
	and     bbm.common_bill_sequence_id = bic.bill_sequence_id
	and     bic.optional = 2
	and     bic.bom_item_type = 4
	-- and     bic.effectivity_date <= greatest( NVL(g_SchShpDate,sysdate),sysdate)  /* New Approach for effectivity dates */
	and     bic.implementation_date is not null
        /*
	and     NVL(bic.disable_date,NVL(g_EstRelDate, SYSDATE)+1) > NVL(g_EstRelDate,SYSDATE) NEW approach for effectivity dates
	and    	NVL(bic.disable_date,SYSDATE) >= SYSDATE; New approach for effectivity dates
        */
        and  ( bic.disable_date is null or
         (bic.disable_date is not null and  bic.disable_date >= sysdate )) ; /* New Approach for Effectivity Dates */

	lCnt := sql%rowcount ;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('inherit_op_seq_ml: ' || 'First -- Inserted in BE Temp ' || lCnt ||' Incl Item rows with bill seq id as '|| pConfigBillId,1);
	END IF;





	lStmtNumber := 530;

	/*+------------------------------------------------------------------------------------------------------------
	Open cursor c_model_oc_oi_rows(xConfigBillId) for rows inserted in bet
	This will update all Option Class and Option Item rows
	Mandatory items directly under model will already have op_seq_num. For these mandatory items we don't need to
	inherit the op_seq_num since they are directly under model.
	The component_code for these mand items are NULL as they are not in BCOL.
	so , mandatory item rows from bet will not be selected by c_model_oc_oi_rows cursor and will not be updated
	Explanation :
	For a Bill structure like this :
	55631 	1.1.0    KS-ATO-MODEL1*6389
   	55627 	1.1      KS-ATO-MODEL1
    	55628 	1.1.1    KS-ATO-MODEL3
    	55629 	1.1.2    KS-ATO-OC1
    	55630 	1.1.3    KS-ATO-OI1
   	BCOL.LINE_ID 	BCOL.COMP_SEQ_ID 	BCOL.COMPONENT_CODE
   	----------   	----------------	---------------
     	55627          	21053                	6280
     	55628          	21322                	6280-6376
     	55629          	21303                	6280-6376-6282
     	55630          	21035                	6280-6376-6282-6288
	Now , instr( bet.component_code,'-',1,2 ) will select line_id 55629 and 55630 as those rows are actual candidates for
	op_seq_num update. 55627 was not inserted in bet as it is the base model row and we are not selecting 55628 since this
	is directly under the top model and inheritence logic does not apply to this line.
	Inheritence starts from second level . First level components under top model will always have op_seq_num.

	+------------------------------------------------------------------------------------------------------------+*/

	FOR r1 in c_model_oc_oi_rows(pConfigBillId) LOOP
		IF r1.operation_seq_num = 1 AND instr(r1.component_code,'-',1,2)<>0 THEN
			 IF PG_DEBUG <> 0 THEN  -- 13079222
			       oe_debug_pub.add ('Component Code: ' || r1.component_code,1);
		         END IF;
			UPDATE bom_explosion_temp bet
			SET bet.operation_seq_num = (
				SELECT /*+ INDEX ( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11)  */
                                --Bugfix 10167279: Adding the distinct clause
				distinct nvl(operation_seq_num,1)	-- 2433862
				FROM   bom_explosion_temp
				WHERE  component_code = substr(bet.component_code,1,to_number(instr(bet.component_code,'-',-1,1))-1)
				AND    bill_sequence_id = pConfigBillId
 				AND    top_bill_sequence_id = pConfigBillId)
			WHERE component_code = r1.component_code
			AND   rowid = r1.rowid;
		END IF;
	END LOOP;

	lStmtNumber := 540;

	/* Open cursor c_incl_items_all_level */

	FOR r2 in c_incl_items_all_level (pOrgId ,pLineId ,pConfigBillId,g_SchShpDate,g_EstRelDate ) LOOP
	   INSERT INTO bom_explosion_temp
	   (	top_bill_sequence_id,
 		organization_id,
 		plan_level,
 		sort_order,
 		operation_seq_num,
      		component_item_id,
      		item_num,
      		component_quantity,
      		component_yield_factor,
                component_remarks,                              --Bugfix 7188428
     		context,					-- mapped to attribute_category in bic interface
     		attribute1,
     		attribute2,
     		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
     		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		select_quantity,				-- mapped to quantity_related of bic interface
      		so_basis,
      		optional,					-- mapped to optional_on_model of bic interface
      		mutually_exclusive_options,
      		include_in_rollup_flag,				-- mapped to include_in_cost rollup of bic interface
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
      		component_sequence_id,
      		bill_sequence_id,
      		wip_supply_type,
      		pick_components,
      		base_item_id,					-- mapped to model_comp_seq_id of bic_interface
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
		top_item_id,					-- mapped to parent_bill_seq_id of bic interface
		effectivity_date,                               -- 3222932
                disable_date                                    -- 3222932
                , basis_type                                    /* LBM project */
	   )
	   VALUES
	   (	pConfigBillId,                	  		-- top bill sequence id
		r2.organization_id,			  	-- Model's organization_id
		r2.plan_level, 					  -- Plan Level
		'1',      					  -- Sort Order
		DECODE(r2.operation_seq_num,1,r2.parent_op_seq_num,r2.operation_seq_num),
		r2.component_item_id,
		r2.item_num,
		r2.component_qty,
		r2.component_yield_factor,
                r2.component_remarks,                           --Bugfix 7188428
		r2.attribute_category,
     		r2.attribute1,
     		r2.attribute2,
     		r2.attribute3,
     		r2.attribute4,
     		r2.attribute5,
     		r2.attribute6,
     		r2.attribute7,
     		r2.attribute8,
     		r2.attribute9,
     		r2.attribute10,
     		r2.attribute11,
     		r2.attribute12,
     		r2.attribute13,
     		r2.attribute14,
     		r2.attribute15,
		100,                                  		-- planning_factor
     		2,                                    		-- quantity_related
		r2.so_basis,
		2,                                    		-- optional
     		2,                                    		-- mutually_exclusive_options
		r2.include_in_cost_rollup,
     		r2.check_atp,
     		2,                                    		-- shipping_allowed = NO
     		2,                                   		-- required_to_ship = NO
     		r2.required_for_revenue,
     		r2.include_on_ship_docs,
     		r2.include_on_bill_docs,
		bom_inventory_components_s.nextval,   		-- component sequence id
     		pConfigBillId,                        		-- bill sequence id
		r2.wip_supply_type,
     		2,                                    		-- pick_components = NO
     		(-1)*r2.component_sequence_id,            		-- model comp seq for later use
     		r2.supply_subinventory,
     		r2.supply_locator_id,
     		r2.bom_item_type,
		r2.bill_sequence_id,				-- parent_bill_seq_id
		r2.eff_date,                                    -- 3222932
                r2.dis_date                                     -- 3222932
               , r2.basis_type                                  /* LBM project */
	   );
	   lCnt := sql%rowcount ;
	   IF PG_DEBUG <> 0 THEN
	   	oe_debug_pub.add ('inherit_op_seq_ml: ' || 'INSIDE Loop : Inserted in BE Temp ' || lCnt ||' manadatory item rows with bill seq id as '|| pConfigBillId,1);
	   END IF;
	END LOOP;


	lStmtNumber := 550;

	/*Insert into bic interface*/
	insert into BOM_INVENTORY_COMPS_INTERFACE
	( 	operation_seq_num,
      		component_item_id,
      		last_update_date,
      		last_updated_by,
      		creation_date,
      		created_by,
      		last_update_login,
      		item_num,
      		component_quantity,
      		component_yield_factor,
      		component_remarks,
      		effectivity_date,
      		change_notice,
      		implementation_date,
      		disable_date,
      		attribute_category,
      		attribute1,
      		attribute2,
      		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
      		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		quantity_related,
      		so_basis,
      		optional,
      		mutually_exclusive_options,
      		include_in_cost_rollup,
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
      		low_quantity,
      		high_quantity,
      		acd_type,
      		old_component_sequence_id,
      		component_sequence_id,
      		bill_sequence_id,
      		request_id,
      		program_application_id,
      		program_id,
      		program_update_date,
      		wip_supply_type,
      		pick_components,
      		model_comp_seq_id,
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
      		revised_item_sequence_id,			-- 2814257
		optional_on_model,
		plan_level,
		parent_bill_seq_id,
		assembly_item_id  /* Bug Fix: 4147224 */
                , basis_type,                   /* LBM changes */
                batch_id
	)
	select 	/*+ INDEX ( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11)  */
                nvl(operation_seq_num,1),			-- 2433862
      		component_item_id,
		SYSDATE,                            		-- last_updated_date
      		1,                                  		-- last_updated_by
      		SYSDATE,                            		-- creation_date
      		1,                                  		-- created_by
      		1,                                  		-- last_update_login
      		item_num,
      		component_quantity,
      		component_yield_factor,
		component_remarks,                              --Bugfix 7188428
                --NULL,                               		-- component_remark
		-- 3222932 TRUNC(SYSDATE),                      -- effective date
                effectivity_date,
      		NULL,                               		-- change notice
      		SYSDATE,                            		-- implementation_date
		-- 3222932 NULL,                                -- disable date
                disable_date,
      		context,					-- mapped to attribute_category in bic interface
     		 attribute1,
      		attribute2,
      		attribute3,
      		attribute4,
      		attribute5,
      		attribute6,
      		attribute7,
      		attribute8,
      		attribute9,
      		attribute10,
      		attribute11,
      		attribute12,
      		attribute13,
      		attribute14,
      		attribute15,
      		planning_factor,
      		select_quantity,				-- mapped to quantity_related of bic interface
      		so_basis,
      		2,						-- optional
      		mutually_exclusive_options,
      		include_in_rollup_flag,				-- mapped to include_in_cost rollup of bic interface
      		check_atp,
      		shipping_allowed,
      		required_to_ship,
      		required_for_revenue,
      		include_on_ship_docs,
      		include_on_bill_docs,
		NULL,                                 		-- low_quantity
      		NULL,                                 		-- high_quantity
     		NULL,                                 		-- acd_type
      		NULL,                                 		-- old_component_sequence_id
      		component_sequence_id,
      		bill_sequence_id,
		NULL,                                 		-- request_id
      		NULL,                                 		-- program_application_id
      		NULL,                                 		-- program_id
      		NULL,                                 		-- program_update_date
      		wip_supply_type,
      		pick_components,
      		base_item_id,				  	-- mapped to model_comp_seq_id of bic_interface
      		supply_subinventory,
      		supply_locator_id,
      		bom_item_type,
      		line_id,					-- 2814257
		optional,
		plan_level,
		top_item_id,
		assembly_item_id  /* Bug Fix: 4147224 */
                , nvl(basis_type,1),  /* LBM project */
                cto_msutil_pub.bom_batch_id
	from 	bom_explosion_temp
	where 	bill_sequence_id = pConfigBillId;

	lCnt := sql%rowcount ;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('inherit_op_seq_ml: ' || 'Final - Inserted in BIC Interface ' || lCnt ||' rows from BET',1);
	END IF;









   /* begin Check for Overlapping Effectivity Dates */
   v_overlap_check := 0 ;

   begin
     select 1 into v_overlap_check
     from dual
     where exists
       ( select * from bom_inventory_comps_interface
          where bill_sequence_id = pConfigBillId
          group by component_item_id, assembly_item_id
          having count(distinct operation_seq_num) > 1
       );
   exception
   when others then
       v_overlap_check := 0 ;
   end;


   if(v_overlap_check = 1) then

     begin
        select s1.component_item_id,
               s1.operation_seq_num, s1.effectivity_date, s1.disable_date,
               s2.operation_Seq_num , s2.effectivity_date, s2.disable_date
        BULK COLLECT INTO
               v_t_overlap_comp_item_id,
               v_t_overlap_src_op_seq_num,  v_t_overlap_src_eff_date, v_t_overlap_src_disable_date ,
               v_t_overlap_dest_op_seq_num , v_t_overlap_dest_eff_date, v_t_overlap_dest_disable_date
        from bom_inventory_comps_interface s1 , bom_inventory_comps_interface s2
       where s1.component_item_id = s2.component_item_id and s1.assembly_item_id = s2.assembly_item_id
         --and s1.effectivity_date between s2.effectivity_date and s2.disable_date
         and s1.effectivity_date > s2.effectivity_date  --Bugfix 6603382
         and s1.effectivity_date < s2.disable_date      --Bugfix 6603382
         and s1.bill_sequence_id = pConfigBillId        --Bugfix 6603382
         and s2.bill_sequence_id = pConfigBillId        --Bugfix 6603382
         and s1.component_sequence_id <> s2.component_sequence_id ;


     exception
     when others then
        null ;
     end ;


     if( v_t_overlap_src_op_seq_num.count > 0 ) then
         for i in v_t_overlap_src_op_seq_num.first..v_t_overlap_src_op_seq_num.last
         loop
             IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add (' The following components have overlapping dates ', 1);
                oe_debug_pub.add (' COMP ' || ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' || ' OVERLAPS ' ||
                                              ' OP SEQ' || 'EFFECTIVITY DT ' || ' DISABLE DT ' , 1);
                /*
                oe_debug_pub.add ( v_t_overlap_comp_item_id(i) ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) ||
                                  ' OVERLAPS ' ||
                                  ' ' || v_t_overlap_src_op_seq_num(i) ||
                                  ' ' || v_t_overlap_src_eff_date(i) ||
                                  ' ' || v_t_overlap_src_disable_date(i) , 1);
                    */
             END IF;

	     select segment1
	     into
	     l_model_name
	     from   mtl_system_items
	     where  inventory_item_id=pModelId
	     and rownum=1;

             l_token2(1).token_name  :='MODEL';
	     l_token2(1).token_value :=l_model_name;
             cto_msg_pub.cto_message('BOM','CTO_OVERLAP_DATE_ERROR',l_token2);
         end loop ;

         raise fnd_api.g_exc_error;

     end if ;

   end if;



   /* end Check for Overlapping Effectivity Dates */













	lStmtNumber := 560;

	/*Flushing the temp table*/
	DELETE  /*+ INDEX ( BOM_EXPLOSION_TEMP BOM_EXPLOSION_TEMP_N11)  */
        from bom_explosion_temp
	WHERE 	bill_sequence_id = pConfigBillId;

	return(1);

EXCEPTION
      	when no_data_found then
        	xErrorMessage := 'CTOCBOMB:'||to_char(lStmtNumber);
        	xMessageName := 'CTO_INHERIT_OP_SEQ_ERROR';
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('inherit_op_seq_ml: ' || 'Error: No data found in inherit_op_seq_ml. Returning 0 ', 1);
		END IF;
        	return(0);

        when FND_API.G_EXC_ERROR then
                xErrorMessage:='CTOCBOMB:'||lStmtNumber||':'||substrb(sqlerrm,1,150);
        	xMessageName := 'CTO_INHERIT_OP_SEQ_ERROR';
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('create_bom_data_ml: ' || 'Error: ' || xErrorMessage, 1);
                END IF;
                return(0);

        when FND_API.G_EXC_UNEXPECTED_ERROR then        -- bugfix 2765635
                xErrorMessage:='CTOCBOMB:'||lStmtNumber||':'||substrb(sqlerrm,1,150);
        	xMessageName := 'CTO_INHERIT_OP_SEQ_ERROR';
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Error: ' || xErrorMessage);
                END IF;
                return(0);

      	when others then
        	xErrorMessage := 'CTOCBOMB:'||to_char(lStmtNumber)||':'||substrb(sqlerrm,1,150);
        	xMessageName := 'CTO_INHERIT_OP_SEQ_ERROR';
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('inherit_op_seq_ml: ' || 'Error: Others excpn : '||sqlerrm, 1);
		END IF;
        	return (0);
END inherit_op_seq_ml;

--e2307936

/*-----------------------------------------------------------------+
  Name : check_bom
         Check to see if the BOM exists for the item in the
         specified org.
+------------------------------------------------------------------*/
function check_bom(
        pItemId        in      number,
        pOrgId         in      number,
        xBillId        out NOCOPY    number)
return integer
is


begin

    xBillId := 0;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('check_bom: ' || 'before check_bom sql::xBillId:: '||to_char(xBillId ), 2);
    END IF;


    select bill_sequence_id
    into   xBillId
    from   bom_bill_of_materials
    where  assembly_item_id = pItemId
    and    organization_id  = pOrgId
    and    alternate_bom_designator is null;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('check_bom: ' || 'after check_bom sql::xBillId:: '||to_char(xBillId )||'returning 1', 2);
    END IF;

    return(1);

exception

    when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('check_bom: ' ||  'NDF exception for Check BOM::item id '||to_char(pItemId), 1);
	END IF;
    	return(0);

    when others then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('check_bom: ' ||  'Others exception for Check BOM::item id '||to_char(pItemId), 1);
	END IF;
        cto_msg_pub.cto_message('BOM', 'CTO_CREATE_BOM_ERROR');
	return(0);

end check_bom;


/*-----------------------------------------------------------------+
  Name : get_model_lead_time
+------------------------------------------------------------------*/

function get_model_lead_time
(       pModelId in number,
        pOrgId   in number,
        pQty     in number,
        pLeadTime out NOCOPY number,
        pErrBuf  out NOCOPY varchar2
)
return integer

is

   lStmtNum number;

begin

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_model_lead_time: ' || 'Getting Lead Time for Model: ' || to_char(pModelId), 2);
   END IF;
   lStmtNum := 100;

   select (ceil(nvl(msi.fixed_lead_time,0)
               +  nvl(msi.variable_lead_time,0) * pQty))
   into    pLeadTime
   from    mtl_system_items msi
   where   inventory_item_id = pModelId
   and     organization_id = pOrgId;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('get_model_lead_time: ' || 'Lead Time: ' || to_char(pLeadtime), 2);
   END IF;

   return 1;

exception

when others then
       pErrBuf := 'CTOCBOMB: ' || lStmtNum || substrb(SQLERRM,1,150);
       return 0;

end get_model_lead_time;

/*-----------------------------------------------------------------+
  Name : bmlggpn_get_group_name
+------------------------------------------------------------------*/

function bmlggpn_get_group_name
(       group_id        number,
        group_name      out NOCOPY varchar2,
        err_buf         out NOCOPY varchar2
)
return integer
is
max_seg         number;
lStmtNum	number;
type segvalueType is table of varchar2(30)
        index by binary_integer;
seg_value       segvalueType;
segvalue_tmp    varchar2(30);
segnum_tmp      number;
catseg_value    varchar2(240);
delimiter       varchar2(10);
profile_setting varchar2(30);
CURSOR profile_check IS
	select nvl(substr(profile_option_value,1,30),'N')
	from fnd_profile_option_values val,fnd_profile_options op
	where op.application_id = 401
	and   op.profile_option_name = 'USE_NAME_ICG_DESC'
	and   val.level_id = 10001  /* This is for site level  */
        and   val.application_id = op.application_id
	and   val.profile_option_id = op.profile_option_id;
begin
	/* First lets get the value for profile option USE_NAME_ICG_DESC
	** If this is 'N' we need to use the description
	** If this is 'Y' then we need to use the group name
	** We are going to stick with group name if the customer is
	** not on R10.5, which means they do not have the profile
	** If they have R10.5 then we are going to use description
	** because that is what inventory is going to do.
	** Remember at the earliest we should get rid of this function
	** and call INV API. Remember we at ATO are not in the business
	** of duplicating code of other teams
	*/

	profile_setting := 'Y';

	lStmtNum :=250;
	OPEN profile_check;
	FETCH profile_check INTO profile_setting;
	IF profile_check%NOTFOUND THEN
	profile_setting := 'Y';
	END IF;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('bmlggpn_get_group_name: ' || ' USE_NAME_ICG_DESC :'|| profile_setting, 2);
        END IF;

   if profile_setting = 'Y' then

	/* Let us select the catalog group name from mtl_catalog_groups
	** At some point in time we need to call the inventory function
	** to do this, so we can centralize this stuff
	*/
	lStmtNum :=260;

	SELECT MICGK.concatenated_segments
	INTO group_name
        FROM mtl_item_catalog_groups_kfv MICGK
        WHERE MICGK.item_catalog_group_id = group_id;

   else
	lStmtNum :=270;
	/* This is to get the description of the catalog */
        SELECT MICG.description
	INTO group_name
        FROM mtl_item_catalog_groups MICG
        WHERE MICG.item_catalog_group_id = group_id;

   end if;
        return(0);
exception
        when others then
                err_buf := 'CTOCBOMB: ' || lStmtNum || substrb(SQLERRM,1,150);
                return(SQLCODE);
end bmlggpn_get_group_name;


/*-----------------------------------------------------------------+
   Name :  bmlupid_update_item_desc
+------------------------------------------------------------------*/

function bmlupid_update_item_desc
(
        item_id                 NUMBER,
        org_id                  NUMBER,
        err_buf         out NOCOPY   VARCHAR2
)
return integer
is
        /*
        ** Create cursor to retrieve all descriptive element values for the item
        */
        CURSOR cc is
                select element_value
                from mtl_descr_element_values
                where inventory_item_id = item_id
                and element_value is not NULL
		and default_element_flag = 'Y'
                order by element_sequence;

        delimiter       varchar2(10);
        e_value         varchar2(30);
        cat_value       varchar2(240);
        idx             number;
        group_id        number;
        group_name      varchar2(240);		-- bugfix 2483982: increased the size from 30 to 240
        lStmtNum        number;
        status          number;
        INV_GRP_ERROR   exception;
begin
        lStmtNum := 280;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('bmlupid_update_item_desc: ' || '  In bmlupid_update_item_desc ',2);
        	oe_debug_pub.add('bmlupid_update_item_desc: ' || '  item id ' || item_id ,2);
        	oe_debug_pub.add('bmlupid_update_item_desc: ' || '  org id ' || org_id ,2);
        END IF;

        select concatenated_segment_delimiter into delimiter
        from fnd_id_flex_structures
        where id_flex_code = 'MICG'
	and   application_id = 401;

        lStmtNum := 285;
        select item_catalog_group_id into group_id
        from mtl_system_items
        where inventory_item_id = item_id
        and organization_id = org_id;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('bmlupid_update_item_desc: ' || ' item_catalog_group_id : ' || group_id,2);
        END IF;
        idx := 0;
        cat_value := '';
        open cc;
        loop
                fetch cc into e_value;
                exit when (cc%notfound);

                if idx = 0 then
                        lStmtNum := 290;
                        status := bmlggpn_get_group_name(group_id,group_name,
							  err_buf);
                        if status <> 0 then
                        	raise INV_GRP_ERROR;
                        end if;
                        cat_value := group_name || delimiter || e_value;
                else
                  lStmtNum := 295;
		  cat_value := cat_value || SUBSTRB(delimiter || e_value,1,
			240-LENGTHB(cat_value));
                end if;
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('bmlupid_update_item_desc: ' || 'cat_value :' || cat_value,1);
                END IF;
                idx := idx + 1;
        end loop;
	close cc;

        if idx <> 0 then
                update mtl_system_items
                set description = cat_value
                where inventory_item_id = item_id;
                /*and organization_id = org_id;		Bugfix 2163311 */
        /* start bugfix 1845141 */
                update mtl_system_items_tl
                set description = cat_value
                where inventory_item_id = item_id;
                /*and organization_id = org_id;		Bugfix 2163311 */
       /* end bugfix 1845141 */
        end if;

        return(0);
exception
        when INV_GRP_ERROR then
                err_buf := 'CTOCBOMB: Invalid catalog group for the item ' || item_id || ' status:' || status;
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('bmlupid_update_item_desc: ' || err_buf, 1);
                END IF;
                cto_msg_pub.cto_message ('BOM', 'CTO_INVALID_CATALOG_GRP');
                return(1);

        when OTHERS then
                err_buf := 'CTOCBOMB: ' || lStmtNum ||substrb(SQLERRM,1,150);
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('bmlupid_update_item_desc: ' || err_buf, 1);
                END IF;
                cto_msg_pub.cto_message ('BOM', 'CTO_CREATE_BOM_ERROR');
                return(1);

END  bmlupid_update_item_desc;






/*
   l_aname                      wf_engine.nametabtyp;
   l_anumvalue                  wf_engine.numtabtyp;
   l_atxtvalue                  wf_engine.texttabtyp;

 wf_engine.CreateProcess (ItemType=> 'CTOCHORD',ItemKey=>litem_key,Process=>'CHGNOTIFY');
  wf_engine.SetItemUserKey(ItemType=> 'CTOCHORD',ItemKey=>litem_key,UserKey=>luser_key);

 wf_engine.SetItemAttrTextArray(ItemType =>'CTOCHORD',ItemKey=>litem_key,aname=>l_aname,avalue=>l_atxtvalue);

  wf_engine.SetItemOwner(Itemtype=>'CTOCHORD',itemkey=>litem_key,owner=>lplanner_code);
  wf_engine.StartProcess(itemtype=>'CTOCHORD',ItemKey=>litem_key);
*/


procedure send_oid_notification(
                            P_LINE_ID                       in    number
                           ,P_SALES_ORDER_NUM               in    number
                           ,P_ERROR_MESSAGE                 in    varchar2
                           ,P_TOP_MODEL_NAME                in    varchar2
                           ,P_TOP_MODEL_LINE_NUM            in    varchar2
                           ,P_TOP_CONFIG_NAME               in    varchar2
                           ,P_TOP_CONFIG_LINE_NUM           in    varchar2
                           ,P_PROBLEM_MODEL                 in    varchar2
                           ,P_PROBLEM_MODEL_LINE_NUM        in    varchar2
                           ,P_PROBLEM_CONFIG                in    varchar2
                           ,P_ERROR_ORG                     in    varchar2
                           ,P_NOTIFY_USER                   in    varchar2
                           ,P_REQUEST_ID                    in    number
)
is
   l_aname                      wf_engine.nametabtyp;
   l_anumvalue                  wf_engine.numtabtyp;
   l_atxtvalue                  wf_engine.texttabtyp;
   luser_key                    varchar2(100);
   litem_key                    varchar2(100);
   lplanner_code                mtl_system_items_vl.planner_code%type;

  porder_no                     number := 2222 ;
  pline_no                      number := 1111 ;

  lstmt_num                     number ;

    l_new_line  varchar2(10) := fnd_global.local_chr(10);
begin
  lstmt_num := 10 ;


  litem_key := to_char(p_line_id)||to_char(sysdate,'mmddyyhhmiss');
  luser_key := litem_key;

 lplanner_code := P_NOTIFY_USER ;

  lstmt_num := 20 ;



  IF WF_DIRECTORY.USERACTIVE(lplanner_code) <>TRUE THEN
      -- Get the default adminstrator value from Workflow Attributes.
      lplanner_code := wf_engine.getItemAttrText(ItemType => 'CTOEXCP',
                                                 ItemKey  => litem_key,
                                                 aname    => 'WF_ADMINISTRATOR');
        oe_debug_pub.add('start_work_flow: ' || 'Planner code is not a valid workflow user...Defaulting to'||lplanner_code,5);

  else

        oe_debug_pub.add('start_work_flow: ' || 'Planner code is a valid workflow user...' ,5);

  END IF;

  lstmt_num := 30 ;


          l_aname(1)     := 'PROBLEM_MODEL';
          l_atxtvalue(1) := 'CN97444' ;

          l_aname(2) :=  'ERROR_MESSAGE' ;
          l_atxtvalue(2) :=  P_ERROR_MESSAGE ;

          l_aname(3) :=  'TOP_MODEL_NAME' ;
          l_atxtvalue(3) := P_TOP_MODEL_NAME ;

          l_aname(4) := 'TOP_MODEL_LINE_NUM' ;
          l_atxtvalue(3) := P_TOP_MODEL_LINE_NUM ;

          l_aname(5) := 'TOP_CONFIG_NAME' ;
          l_atxtvalue(5) := P_TOP_CONFIG_NAME  ;

          l_aname(6) := 'TOP_CONFIG_LINE_NUM' ;
          l_atxtvalue(6) := P_TOP_CONFIG_LINE_NUM ;

          l_aname(7) :=  'PROBLEM_MODEL' ;
          l_atxtvalue(7) := P_PROBLEM_MODEL   ;

          l_aname(8) := 'PROBLEM_MODEL_LINE_NUM' ;
          l_atxtvalue(8) :=  P_PROBLEM_MODEL_LINE_NUM ;

          l_aname(9) := 'PROBLEM_CONFIG' ;
          l_atxtvalue(8) := P_PROBLEM_CONFIG  ;

          l_aname(10) := 'ERROR_ORG' ;
          l_atxtvalue(10) := P_ERROR_ORG   ;

          l_aname(11) := 'REQUEST_ID' ;
          l_atxtvalue(11) := P_REQUEST_ID  ;

          lstmt_num := 35 ;

          l_aname(12)     := 'NOTIFY_USER';
          l_atxtvalue(12) := lplanner_code;

          lstmt_num := 50 ;
          wf_engine.CreateProcess (ItemType=> 'CTOEXCP',ItemKey=>litem_key,Process=>'NOTIFY_OID_INC');

          lstmt_num := 60 ;
          wf_engine.SetItemUserKey(ItemType=> 'CTOEXCP',ItemKey=>litem_key,UserKey=>luser_key);

          lstmt_num := 40 ;

          wf_engine.SetItemAttrNumber(ItemType   =>'CTOEXCP',
                              itemkey    =>litem_key,
                              aname      =>'ORDER_NUM',
                              avalue     => p_sales_order_num );

          lstmt_num := 70 ;
          wf_engine.SetItemAttrTextArray(ItemType =>'CTOEXCP',ItemKey=>litem_key,aname=>l_aname,avalue=>l_atxtvalue);

          lstmt_num := 80 ;
          wf_engine.SetItemOwner(Itemtype=>'CTOEXCP',itemkey=>litem_key,owner=>lplanner_code);


          lstmt_num := 90 ;
          wf_engine.StartProcess(itemtype=>'CTOEXCP',ItemKey=>litem_key);


          oe_debug_pub.add( ' done till stmt ' || lstmt_num ) ;



exception
when others then

 oe_debug_pub.add( ' exception in others at stmt ' || lstmt_num ) ;
 oe_debug_pub.add( ' exception in others ' || SQLCODE ) ;


end send_oid_notification ;


function get_dit_count
return number
is
begin
  if( g_t_dropped_item_type is not null ) then
      return g_t_dropped_item_type.count ;

  else
      return 0 ;
  end if ;


end ;


procedure get_dropped_components( x_t_dropped_items out NOCOPY t_dropped_item_type )
is
begin
  for i in 1..g_t_dropped_item_type.count
  loop
     x_t_dropped_items(i) := g_t_dropped_item_type(i) ;

  end loop ;


end get_dropped_components ;



procedure reset_dropped_components
is
begin
   g_t_dropped_item_type.delete ;

end reset_dropped_components ;


END CTO_CONFIG_BOM_PK;

/
