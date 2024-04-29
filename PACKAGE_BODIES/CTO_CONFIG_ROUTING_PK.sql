--------------------------------------------------------
--  DDL for Package Body CTO_CONFIG_ROUTING_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CONFIG_ROUTING_PK" as
/* $Header: CTOCRTGB.pls 120.6.12010000.2 2009/08/13 05:59:45 abhissri ship $ */

/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|
| FILE NAME   : CTOCRTGB.sql
| DESCRIPTION :
|               This file creates a packaged function that loads the
|               Routing tables for the config item. Converted from BOMLDCBB.pls
|               for CTO streamline for new OE
|
| HISTORY     : created   10-JUN-99
|		Added changes to support WIP's Simultaneous and Substitute
|		resources	19-JUN-2000	Sajani Sheth
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
|		ksarkar   19-JUL-01   Bugfix 1876999
|               Remove semicolon from comment to improve performance .
|		ksarkar   17-AUG-01   Bugfix 1906371
|               Unique constraint on bom_operation_sequences will be violated
|		when config item has selected options with same op seq number.
|		Refer bug for details
|
|		ksarkar   17-AUG-01   Bugfix 1935580
|               Unique constraint on bom_operation_sequences will be violated
|		hen config item has selected models with same op seq number.
|		Refer bug for details
|		Add  bom_bill_of_materials.organization_id = pOrgId condition
|		to select routing from correct organisation.
|
|		Combining 1935580 and 1906371 ; since option rows are inserted into
|		bom_operation_sequences after model rows , check needs to be there
|		while inserting option rows to see whether combination of
|		operation_seq_num - operation_type - routing_sequence_id - effectivity_date
|		is already present in the table for the model rows .
|
|              Modified on 24-AUG-2001 by Sushant Sawant: BUG #1957336
|                                         Added a new functionality for preconfigure bom.
|
|		Combining 1935580 and 1906371 ; check for null values of operation_type
|		in the cursor get_op_seq_num.
|
|		ksarkar   07-SEP-01   Bugfix 1974130 and Bug 1983384
|               Config item is created with improper routing
|
|		ksarkar   09-JAN-02   Bugfix 2177101 ( Bugfix 2143014 )
|               Create config item process is failed with unique constraint violation.
|
|		ksarkar   04-APR-02   Bugfix 2292468 ( Bugfix 1912376 )
|               Checking item effectivity till schedule_ship_date.
|
|               ssawant   28-MAY-02   Bugfix 2312199 (Refix for bug1912376 )
|               bug 1912376 could still fail in case of sourced lower level models
|
|		ksarkar   04-JUN-02   Bugfix 2382396 ( Bugfix 2402935 in main )
|		Multi level model not selecting option dependent routing steps
|		on non-phantom sub-model
|
|               kkonada   31-OCT-2002
|               Made changes for changes for  feature SERIAL TRACKING IN WIP
|
|
|		ksarkar   05-NOV-02   Bugfix 2652844 ( Customer bug 2650828 )
|		Time lag in copying routing information to configured item
|		routing.
|
|
|		kkonada   06-FEb-2003  Bugfix 2771065
|			  Disbled routing op was getting picked up when
|			  disabled date was greater than Est released date
|			  Est rel date is assumed to be begining of the day
|			  ie midnight of each day
|			  FIX
|			  added a where clasue
|			  nvl(disable_date,sysdate+1)>sysdate
|
|
|		ksarkar   14-MAY-03   Bugfix 2958044 ( Customer bug 2950774 )
|		Config item routing not copying set up type from its base model
|		routing.
|
|
|		ksarkar   26-SEP-03   Bugfix 3093686 ( Customer bug 3093686 )
|		Autocreate process adding extra routing steps to configuration
|		routing.
|
|               ksarkar   09-OCT-03   Bugfix 3180827 ( Customer bug 3144822 )
|               Autocreate process not picking up routing steps to configuration
|               routing.
|
|
|              Modified on 26-Mar-2004 By Sushant Sawant
|                                         Fixed Bug#3484511
|                                         all queries referencing oe_system_parameters_all
|                                         should be replaced with a function call to oe_sys_parameters.value
|
|             Renga Kannan 28-Jan-2004   Front Port bug fix 4049807
|                                        Descriptive Flexfield Attribute
|                                        category is not copied from model
|                                        Added this column while inserting
|                                        into bom_operational_routings
|
|             Kiran Konada 05-Jan-2006	bugfix1765149
|                                       get the x and Y coordinate on canvas for flow routing
*============================================================================*/

-- Bug 1912376 Declaring Global variable to hold the value of Schedule Ship Date
g_SchShpDate            Date;

-- Bug 3180827 Declaring Global variable to hold the value of Last update Date
glast_update_date       Date  := to_date('01/01/2099 00:00:00','MM/DD/YYYY HH24:MI:SS');

/*-------------------------------------------------+
   check_routing :
   Checks the existence of routing of an assembly
   in an org. If routing exists, returns 1 and
   otherwise returns 0
+-------------------------------------------------*/

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

function check_routing (
        pItemId        in      number,
        pOrgId         in      number,
        xRtgId         out NOCOPY    number,
        xRtgType       out NOCOPY     number)
return integer
is


begin

    xRtgId := 0;
    xRtgType := 0;

    select routing_sequence_id,
           NVL(cfm_routing_flag,2)
    into   xRtgId,
           xRtgType
    from   bom_operational_routings
    where  assembly_item_id = pItemId
    and    organization_id  = pOrgId
    and    alternate_routing_designator is null;

    return (1);

exception

    when no_data_found then
    	return (0) ;

    when others then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('check_routing: ' ||  'Others exception for Check RTG::item id '||to_char(pItemId),1);

		oe_debug_pub.add ('check_routing: ' ||  'Error message is : '||sqlerrm);
	END IF;
	return (0) ;

end check_routing;

/*-----------------------------------------------------+
   Create_routing_ml :
   Creates config routing and poplulates associated
   tables based on model item in mfg org. Needs config
   bill id as in parameter because the bill does not
   exists in production tables yet.

   returns 1 when succesful, 0 when failure.
+-----------------------------------------------------*/



FUNCTION create_routing_ml (
         pModelId        in       number,
         pConfigId       in       number,
         pCfgBillId      in       number,
         pOrgId	         in       number,
	 pLineId         in       number,
         pFlowCalc       in       number,
         xRtgId          out NOCOPY     number,
         xErrorMessage   out NOCOPY     varchar2,
         xMessageName    out NOCOPY     varchar2,
         xTableName      out NOCOPY     varchar2)
RETURN integer
is

    l_ser_start_op number;
    l_ser_code     number;
    l_row_count    number := 0;


    lStmtNum        number;
    lItmRtgId        number;
    lStatus	    number;
    lCfgRtgId       number;
    lCfmRtgflag     number;
    lEstRelDate     date;
    l_status        VARCHAR2(1);
    l_industry      VARCHAR2(1);
    l_schema        VARCHAR2(30);
    lLineId         number;
    lModelId        number;
    lParentAtoLineId number := pLineId;
    lOrderedQty     number;
    lLeadTime       number;
    lErrBuf         varchar2(80);
    lTotLeadTime    number := 0;
    lOEValidationOrg number;

     /*New variables added for bugfix 1906371 and 1935580*/
    lmodseqnum    	number;
    lmodtyp       	number;
    lmodrtgseqid    	number;
    lmodnewCfgRtgId    	number;
    lopseqnum	    	number;
    loptyp          	number;
    lrtgseqid       	number;
    lnewCfgRtgId    	number;

    l_test		number;

    /*End of variable addition*/

    l_install_cfm          BOOLEAN;

    UP_DESC_ERR    exception;

    /* ------------------------------------------------------+
       cursor to  be used to copy attachments for all
       operations fro model to operations on config
       requset id column contains model_op_seq_id.
    +--------------------------------------------------------*/

    cursor allops is
    select operation_sequence_id, request_id
    from bom_operation_sequences
    where routing_sequence_id = lCfgRtgId;

     /* ------------------------------------------------------+
       cursor added for bugfix 1906371 and 1935580  to  select
       distinct combinations of op_seq_num and op_type
    +--------------------------------------------------------*/

    cursor get_op_seq_num (pRtgId number) is
    select distinct operation_seq_num,nvl(operation_type,1)
    from bom_operation_sequences_temp -- 5336292
    where config_routing_id=pRtgId;		-- bugfix 3239267: replaced last_update_login

    -- 5336292
    cursor bos_temp (pRtgId number ) is
    select operation_sequence_id,routing_sequence_id,operation_seq_num,config_routing_id
    from bom_operation_sequences_temp
    where config_routing_id=pRtgId;

    d_op_seq_id		bom_operation_sequences_temp.operation_sequence_id%TYPE;
    d_rtg_seq_id	bom_operation_sequences_temp.routing_sequence_id%TYPE;
    d_op_seq_num	bom_operation_sequences_temp.operation_seq_num%TYPE;
    d_cfg_rtg_id	bom_operation_sequences_temp.config_routing_id%TYPE;


 v_program_id         bom_cto_order_lines.program_id%type;

 -- 3093686 : structure declaration

    TYPE mod_opclass_rtg_tab IS TABLE OF NUMBER	INDEX BY BINARY_INTEGER;


    tModOpClassRtg	mod_opclass_rtg_tab;
    tDistinctRtgSeq	mod_opclass_rtg_tab;
    lexists		varchar2(1);
    k			number;


 -- 3093686

    --4905857
    l_batch_id number;
BEGIN

    gUserId          := nvl(Fnd_Global.USER_ID, -1);
    gLoginId         := nvl(Fnd_Global.LOGIN_ID, -1);
    xRtgID           := 0;


    /*-----------------------------------------------------------+
      If the routing already exists for this config item then
      we do not need to create the routing. Return with success.
    +------------------------------------------------------------*/

    lStatus := check_routing (pConfigId,
                              pOrgId,
                              lItmRtgId,
                              lCfmRtgFlag );
    if lStatus = 1  then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add ('create_routing_ml: ' || 'Config Routing' || lCfgRtgId || '  Already Exists ',1);
       END IF;
       return (1) ;
    end if;

    /*-------------------------------------------------------------+
      Config does not have  routing. If  model also does not have
      routing, we do not need to do anything, return with success.
    +--------------------------------------------------------------*/

    lCfmRtgFlag := NULL;
    lStatus := check_routing (pModelId,
                              pOrgId,
                              lItmRtgId,
                              lCfmRtgFlag);
    if lStatus <> 1  then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add ('create_routing_ml: ' || 'Model Does not have a routing ',1);

       END IF;
       return (1);
    end if;

   /* --------------------------------------------------------------+
      Routing needs to be Created  for the config item.
   +---------------------------------------------------------------*/
   -- Start Bugfix 1912376

  /*-------------------------------------------+
    Selecting Schedule_ship_date of ATO Model and assigning
    this to a Global variable
  +--------------------------------------------*/
  lStmtNum   := 05;

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
  	oe_debug_pub.add('create_routing_ml: ' || 'Line Id ' || pLineId ||' has Schedule Ship Date of '||g_SchShpDate, 1);
	oe_debug_pub.add (' org id = '||to_char(porgid),1);
  END IF;

  -- End Bugfix 1912376



      /*--------------------------------------------------------------+
         Replacing Calculate Estimated Release date of the model
         with Multilevel version which will sum the lead time
         of all parent ATO models.
     +---------------------------------------------------------------*/

/**** comment begins --------------------------------------------------------+

   xTableName := 'OE_ORDER_LINES_ALL';
   lStmtNum   := 10;

   select CAL.CALENDAR_DATE
   into   lEstRelDate
   from   bom_calendar_dates cal,
          mtl_system_items   msi,
          bom_cto_order_lines bcol,
          mtl_parameters     mp
   where  msi.organization_id    = pOrgId
   and    msi.inventory_item_id  = pModelId
   and    bcol.line_id            = pLineId
   and    bcol.inventory_item_id  = msi.inventory_item_id
   and    mp.organization_id     = msi.organization_id
   and    cal.calendar_code      = mp.calendar_code
   and    cal.exception_set_id   = mp.calendar_exception_set_id
   and    cal.seq_num =
       (select cal2.prior_seq_num
               - (ceil(nvl(msi.fixed_lead_time,0)
               +  nvl(msi.variable_lead_time,0) * bcol.ordered_quantity))
        from   bom_calendar_dates cal2
        where  cal2.calendar_code    = mp.calendar_code
        and    cal2.exception_set_id = mp.calendar_exception_set_id
        and    cal2.calendar_date    = trunc(bcol.schedule_ship_date));

+- comment ends ----------------------------------------------------------*/




   -- New Estimated Release Date for Multilevel ATO
   -- get oevalidation org

   lStmtNum := 10;
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_routing_ml: ' ||  'Before getting validation org',2);
   END IF;

   -- BUG #1957336 Change for preconfigure bom by Sushant Sawant
   -- Sushant added this code to check bcol records populated by preconfigure bom module

   select program_id
     into v_program_id
     from bom_cto_order_lines
     where line_id = pLineId ;



   if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then

       lOEValidationOrg := CTO_UTILITY_PK.PC_BOM_VALIDATION_ORG ;

   else

       /*
       BUG:3484511
       -----------
       select nvl(master_organization_id,-99)		--bugfix 2646849: master_organization_id can be 0
       into   lOEValidationOrg
       from   oe_order_lines_all oel,
              oe_system_parameters_all ospa
       where  oel.line_id = pLineid
       and    nvl(oel.org_id, -1) = nvl(ospa.org_id, -1)  --bug 1531691
       and    oel.inventory_item_id = pModelId;
       */

           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('create_routing_ml: ' ||  'Going to fetch Validation Org ' ,2);
           END IF;


           select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
              into lOEValidationOrg from oe_order_lines_all oel
           where oel.line_id = pLineId ;


   end if ;


   if (lOEValidationOrg = -99) then			-- bugfix 2646849
        cto_msg_pub.cto_message('BOM','CTO_VALIDATION_ORG_NOT_SET');
	raise FND_API.G_EXC_ERROR;
   end if;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_routing_ml: ' ||  'Validation Org is :' ||  lOEValidationOrg,2);
   END IF;


   lStmtNum := 11;

   loop
     select bcol.line_id, bcol.inventory_item_id, bcol.parent_ato_line_id,
            bcol.ordered_quantity
     into   lLineId, lModelId, lParentAtoLineId, lOrderedQty
     from   bom_cto_order_lines bcol
     where  bcol.line_id = lParentAtoLineId;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add('create_routing_ml: ' || 'lLineId: ' || to_char(lLineId), 2);

     	oe_debug_pub.add('create_routing_ml: ' || 'lModelId: ' || to_char(lModelId), 2);

     	oe_debug_pub.add('create_routing_ml: ' || 'lParentAtoLineId: ' || to_char(lParentAtoLineId), 2);
     END IF;

     lStmtNum := 12;
     lStatus := CTO_CONFIG_BOM_PK.get_model_lead_time(
                          pModelId	=> lModelId,
                          pOrgId	=> lOEValidationOrg,
                          pQty		=> lOrderedQty,
                          pLeadTime	=> lLeadTime,
                          pErrBuf	=> lErrBuf);

     if (lStatus = 0) then
         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add('create_routing_ml: ' || 'Failed in get_model_lead_time.', 1);
         END IF;
         return 0;

     else
         lTotLeadTime := lLeadTime + lTotLeadTime;

     end if;

     exit when lLineId = lParentAtoLineId; -- when we reach the top model

   end loop;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('create_routing_ml: ' || 'Total lead time is: ' || to_char(lTotLeadTime), 2);
   END IF;

   xTableName := 'OE_ORDER_LINES ';
   lStmtNum   := 13;

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
--   and    bcol.ship_from_org_id   = msi.organization_id
   and    mp.organization_id     = msi.organization_id
   and    cal.calendar_code      = mp.calendar_code
   and    cal.exception_set_id   = mp.calendar_exception_set_id
   and    cal.seq_num =
       (select cal2.prior_seq_num - lTotLeadTime
        from   bom_calendar_dates cal2
        where  cal2.calendar_code    = mp.calendar_code
        and    cal2.exception_set_id = mp.calendar_exception_set_id
        and    cal2.calendar_date    = trunc(bcol.schedule_ship_date));

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('create_routing_ml: ' || 'Estimated Release Date is : ' || to_char(lEstRelDate,'dd-mon-yy::hh24:mi:ss'), 2);
   END IF;


   /*---------------------------------------------------------------+
     Get new routing_id and the type of routing to be created.
   +----------------------------------------------------------------*/

   select bom_operational_routings_s.nextval
   into   lCfgRtgId
   from   dual;


   /*---------------------------------------------------------------+
      Insert the routing header for the Config Item
   +----------------------------------------------------------------*/

   xTableName := 'BOM_OPERATIONAL_ROUTING';
   lStmtNum   := 30;


   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('create_routing_ml: ' || 'Inserting the routing header information into bom_operational_routings..',5);
   END IF;
   insert into bom_operational_routings
       (
       routing_sequence_id,
       assembly_item_id,
       organization_id,
       alternate_routing_designator,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       routing_type,
       common_routing_sequence_id,
       common_assembly_item_id,
       routing_comment,
       completion_subinventory,
       completion_locator_id,
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
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       line_id,
       mixed_model_map_flag,
       priority,
       cfm_routing_flag,
       total_product_cycle_time,
       ctp_flag,
       project_id,
       task_id
       )
   select
       lCfgRtgId,                    -- Routing Sequence Id
       pConfigId,                    -- assembly item Id
       pOrgId,                       -- Organization Id
       null,                         -- alternate routing designator
       sysdate,                      -- last update date
       gUserID,                      -- last updated by
       sysdate,
       gUserId,	                         /* created_by */
       gLoginId, 	                         /* last_update_login */
       bor.routing_type,	         /* routing_type */
       lCfgRtgId, 	                 /* common_routing_sequence_id */
       null,                             /* common_assembly_item_id */
       bor.routing_comment,
       bor.completion_subinventory,
       bor.completion_locator_id,
       bor.attribute_category,       -- Bug Fix 4049807 added Attribute category
       bor.attribute1,
       bor.attribute2,
       bor.attribute3,
       bor.attribute4,
       bor.attribute5,
       bor.attribute6,
       bor.attribute7,
       bor.attribute8,
       bor.attribute9,
       bor.attribute10,
       bor.attribute11,
       bor.attribute12,
       bor.attribute13,
       bor.attribute14,
       bor.attribute15,
       null,
       null,
       null,
       null,
       bor.line_id,
       bor.mixed_model_map_flag,
       bor.priority,
       bor.cfm_routing_flag,
       bor.total_product_cycle_time,
       bor.ctp_flag,
       bor.project_id,
       bor.task_id
   from
       bom_operational_routings  bor,
       mtl_parameters            mp
    where   bor.assembly_item_id     = pModelId
    and     bor.organization_id      = pOrgId
    and     bor.alternate_routing_designator is null
    and     mp.organization_id       = pOrgId;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || 'Inserted Routing Header :' || lCfgRtgId,2 );
    END IF;

   /*---------------------------------------------------------------+
      Udpate the mixed_model_map_flag. If the cfm_routing_flag
      is 1, then mixed_model_flag should be 1 if any flow_routing
      (primary or alternate) for the model has the mixed_model_flag
      equal to 1.
   +----------------------------------------------------------------*/

    lStmtNum := 40;

    update bom_operational_routings b
       set mixed_model_map_flag =
       ( select 1
             from  bom_operational_routings bor
             where bor.assembly_item_id     = pModelId
             and   bor.organization_id      = pOrgId
             and   bor.cfm_routing_flag     = 1
             and   bor.mixed_model_map_flag = 1
             and   bor.alternate_routing_designator is not NULL )
    where  b.routing_sequence_id = lCfgRtgID
    and    b.mixed_model_map_flag <> 1
    and    b.cfm_routing_flag =1;



   /*---------------------------------------------------------------+
	-- rtg2

        Identify all distinct operation steps to be picked up from
        Model routing and mark the config_routing_id field		-- bugfix 3239267: replaced last_update_login
        for those to lCfgRtgId.
        Ignore option dependednt flag on operations types 2 and 3
        Copy from Model Item's routing only.
        -- Mandatory steps  model
        -- option dependent steps associated with options/option Class
	-- "additional" option dependent steps associated with options/OC
        -- Option dependent steps associated with mandatory comps.
	-- "additional" Option dependent steps associated with mandatory comps.
	The "additional" operation steps are the steps stored in the new
	table bom_component_operations to support one-to-many BOM components
	to Routing steps.
   +----------------------------------------------------------------*/

 --perf bug#4905857 , sql id 16103149
 --Fixed Performance bug in the following sql. AS the following sql is huge one,
 --performance team asked us to divide the sql into pieces. We are planning to
 --insert a record from each sub query in the union class and then update it from
 --interface table

 /********************************************************************
   NEW GFSI CODE 5336292
   ********************************************************************/

   -- Insert eligible rows into bom_operation_sequences_temp
   -- Note : We are not selecting distinct of ( operation_seq_num,operation_type,routing_sequence_id )
   -- since bom_operation_sequences has operation_seq_num,operation_type,routing_sequence_id,eff_date
   -- as unique combination key and eff_date is used in the where clause of select



   lStmtNum := 50;
   l_batch_id := bom_import_pub.get_batchid;

   --1st insert
   lStmtNum := 51;
   insert into bom_operation_sequences_temp
            (
       operation_sequence_id,
        routing_sequence_id,
	config_routing_id,		-- 5336292
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,
	x_coordinate,
	y_coordinate
	    )
   SELECT distinct
	os1.operation_sequence_id,		-- 5336292
        os1.routing_sequence_id,                -- 5336292
	lCfgRtgId,				-- 5336292
        os1.operation_seq_num,
        glast_update_date,			-- 5336292
        gUserId,
        sysdate,
        gUserId,
        gLoginId,
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
        os1.effectivity_date,			-- 5336292
        os1.disable_date,			-- 5336292
        os1.backflush_flag,
        os1.option_dependent_flag,              -- 5336292
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
	os1.request_id,
        os1.program_application_id,
        os1.program_id     ,
        os1.program_update_date,
        os1.reference_flag,
        nvl(os1.operation_type,1),
        os1.process_op_seq_id,
        os1.line_op_seq_id,
        os1.yield,
        os1.cumulative_yield,
        os1.reverse_cumulative_yield,
        os1.labor_time_calc,
        os1.machine_time_calc,
        os1.total_time_calc,
        os1.labor_time_user,
        os1.machine_time_user,
        os1.total_time_user,
        os1.net_planning_percent,
	os1.implementation_date,
        x_coordinate,
	y_coordinate
   FROM bom_cto_order_lines bcol1,
        mtl_system_items si1,
        bom_operational_routings or1,
        bom_operation_sequences os1
    WHERE bcol1.line_id = pLineId
        AND bcol1.inventory_item_id = pModelId
        AND si1.organization_id = pOrgId -- this is the mfg org from src_orgs
        AND si1.inventory_item_id = bcol1.inventory_item_id
        AND si1.bom_item_type = 1
        AND or1.assembly_item_id = si1.inventory_item_id
        AND or1.organization_id = si1.organization_id
        AND or1.alternate_routing_designator is NULL
        AND nvl(or1.cfm_routing_flag,2) = lCfmRtgflag
        AND os1.routing_sequence_id = or1.common_routing_sequence_id
        AND
        (
            os1.operation_type in (2,3)
            OR
            (
                os1.option_dependent_flag = 2
                AND nvl(os1.operation_type,1 ) = 1
            )
        )
        AND
        (
            os1.disable_date is null
            OR
            (
                os1.disable_date is not null
                AND os1.disable_date >= sysdate
            )
        );

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Number of Model option independent operations selected  = '||sql%rowcount,1);
   End if;

   --2nd insert
   lStmtNum := 52;
   insert into  bom_operation_sequences_temp
            (
       operation_sequence_id,
        routing_sequence_id,
	config_routing_id,		-- 5336292
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,
	x_coordinate,
	y_coordinate


	    )
   SELECT DISTINCT
	os1.operation_sequence_id,		-- 5336292
        os1.routing_sequence_id,                -- 5336292
	lCfgRtgId,				-- 5336292
        os1.operation_seq_num,
        glast_update_date,			-- 5336292
        gUserId,
        sysdate,
        gUserId,
        gLoginId,
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
        os1.effectivity_date,			-- 5336292
        os1.disable_date,			-- 5336292
        os1.backflush_flag,
        os1.option_dependent_flag,              -- 5336292
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
	os1.request_id,
        os1.program_application_id,
        os1.program_id     ,
        os1.program_update_date,
        os1.reference_flag,
        nvl(os1.operation_type,1),
        os1.process_op_seq_id,
        os1.line_op_seq_id,
        os1.yield,
        os1.cumulative_yield,
        os1.reverse_cumulative_yield,
        os1.labor_time_calc,
        os1.machine_time_calc,
        os1.total_time_calc,
        os1.labor_time_user,
        os1.machine_time_user,
        os1.total_time_user,
        os1.net_planning_percent,
	os1.implementation_date,
	x_coordinate,
	y_coordinate

    FROM bom_cto_order_lines bcol1, -- components
        bom_cto_order_lines bcol2, -- parent models or option classes
        mtl_system_items msi,
        bom_inventory_components ic1,
        bom_bill_of_materials b1,
        bom_operational_routings or1,
        bom_operation_sequences os1
    WHERE bcol1.parent_ato_line_id = pLineId /*AP*/
        AND bcol1.item_type_code in ('CLASS','OPTION')
        AND bcol1.line_id <> bcol2.line_id
        -- bugfix 2382396 and    bcol2.parent_ato_line_id = bcol1.parent_ato_line_id    /*AP*/
        AND bcol2.inventory_item_id = msi.inventory_item_id
        AND msi.organization_id = pOrgId -- new from src_orgs
        AND msi.bom_item_type = 1
        AND bcol2.line_id = pLineId
        AND bcol2.ordered_quantity <> 0
        AND bcol2.line_id = bcol1.link_to_line_id
        -- begin  1653881
        AND ic1.bill_sequence_id =
        (
        SELECT
            common_bill_sequence_id
        FROM bom_bill_of_materials bbm
        WHERE organization_id = pOrgId
            AND alternate_bom_designator is null
            AND assembly_item_id =
            (
            SELECT DISTINCT
                assembly_item_id
            FROM bom_bill_of_materials bbm1,
                bom_inventory_components bic1
            WHERE bbm1.common_bill_sequence_id = bic1.bill_sequence_id
                AND component_sequence_id = bcol1.component_sequence_id
                AND bbm1.assembly_item_id = bcol2.inventory_item_id
            )
        )
        AND ic1.component_item_id = bcol1.inventory_item_id
        --end 1653881
        --  1912376
        AND
        (
            ic1.disable_date is null
            OR
            (
                ic1.disable_date is not null
                AND ic1.disable_date >= sysdate
            )
        )
        AND b1.common_bill_sequence_id = ic1.bill_sequence_id
        AND b1.assembly_item_id = bcol2.inventory_item_id --  1272142
        AND b1.alternate_bom_designator is NULL
        AND or1.assembly_item_id = b1.assembly_item_id
        AND or1.organization_id = b1.organization_id
        AND b1.organization_id = pOrgId --bug 1935580
        AND or1.alternate_routing_designator is null
        AND nvl(or1.cfm_routing_flag,2) = lCfmRtgFlag
        AND
        (
            os1.disable_date is null
            OR
            (
                os1.disable_date is not null
                AND os1.disable_date >= sysdate
            )
        )
        AND os1.routing_sequence_id = or1.common_routing_sequence_id
        --one-to-many BOM components to Rtg operations
        AND
        (
            (
                os1.operation_seq_num = ic1.operation_seq_num
            )
            OR
            (
                os1.operation_seq_num in
                (
                SELECT
                    bco.operation_seq_num
                FROM bom_component_operations bco
                WHERE bco.component_sequence_id = ic1.component_sequence_id
                )
            )
        )
        --one-to-many BOM components to Rtg operations
        AND os1.option_dependent_flag = 1
        AND nvl(os1.operation_type,1) = 1
	and operation_sequence_id not in(select operation_sequence_id
	                                 from bom_operation_sequences_temp);

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Number of Model option dependent operations selected  = '||sql%rowcount,1);
   End if;
    --3rdnd insert
   lStmtNum := 53;
   insert into bom_operation_sequences_temp
            (
       operation_sequence_id,
        routing_sequence_id,
	config_routing_id,		-- 5336292
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,
	x_coordinate,
	y_coordinate

	    )
    SELECT DISTINCT
  	os1.operation_sequence_id,		-- 5336292
        os1.routing_sequence_id,                -- 5336292
	lCfgRtgId,				-- 5336292
        os1.operation_seq_num,
        glast_update_date,			-- 5336292
        gUserId,
        sysdate,
        gUserId,
        gLoginId,
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
        os1.effectivity_date,			-- 5336292
        os1.disable_date,			-- 5336292
        os1.backflush_flag,
        os1.option_dependent_flag,              -- 5336292
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
	os1.request_id,
        os1.program_application_id,
        os1.program_id     ,
        os1.program_update_date,
        os1.reference_flag,
        nvl(os1.operation_type,1),
        os1.process_op_seq_id,
        os1.line_op_seq_id,
        os1.yield,
        os1.cumulative_yield,
        os1.reverse_cumulative_yield,
        os1.labor_time_calc,
        os1.machine_time_calc,
        os1.total_time_calc,
        os1.labor_time_user,
        os1.machine_time_user,
        os1.total_time_user,
        os1.net_planning_percent,
	os1.implementation_date,
	x_coordinate,
	y_coordinate
	-- 5336292
    FROM bom_operation_sequences os1,
        bom_operational_routings or1,
        mtl_system_items si2,
        bom_inventory_components ic1,
        bom_bill_of_materials b1,
        mtl_system_items si1
    WHERE si1.organization_id = pOrgId
        AND si1.inventory_item_id = pModelId
        AND si1.bom_item_type = 1 /* model */
        AND b1.organization_id = si1.organization_id
        AND b1.assembly_item_id = si1.inventory_item_id
        AND b1.alternate_bom_designator is null
        AND or1.assembly_item_id = b1.assembly_item_id
        AND or1.organization_id = b1.organization_id
        AND or1.alternate_routing_designator is null
        AND nvl(or1.cfm_routing_flag,2) = lCfmRtgFlag
        AND os1.routing_sequence_id = or1.common_routing_sequence_id
        AND
        (
            os1.disable_date is null
            OR
            (
                os1.disable_date is not null
                AND os1.disable_date >= sysdate
            )
        )
        AND ic1.bill_sequence_id = b1.common_bill_sequence_id
        AND ic1.optional = 2
        AND ic1.implementation_date is not null
        AND
        (
            ic1.disable_date is null
            OR
            (
                ic1.disable_date is not null
                AND ic1.disable_date >= sysdate
            )
        )
        AND si2.inventory_item_id = ic1.component_item_id
        AND si2.organization_id = b1.organization_id
        AND si2.bom_item_type = 4 -- standard
        AND os1.option_dependent_flag = 1
        /* one-to-many BOM components to Rtg operations */
        AND
        (
            (
                os1.operation_seq_num = ic1.operation_seq_num
            )
            OR
            (
                os1.operation_seq_num in
                (
                SELECT
                    bco.operation_seq_num
                FROM bom_component_operations bco
                WHERE bco.component_sequence_id = ic1.component_sequence_id
                )
            )
        )
        /* one-to-many BOM components to Rtg operations */
        AND nvl(os1.operation_type,1) = 1
	and operation_sequence_id not in(select operation_sequence_id
	                                 from bom_operation_sequences_temp);



     If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Number of Model mandatory independent operations selected  = '||sql%rowcount,1);
   End if;

     IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || ' Model Routing : Inserted ' || sql%rowcount || ' records in temp table',2 );
    END IF;

    IF PG_DEBUG <> 0 THEN
      open bos_temp(lCfgRtgId);

      loop
    	   fetch bos_temp into d_op_seq_id,d_rtg_seq_id,d_op_seq_num,d_cfg_rtg_id;
    	   exit when bos_temp%notfound;
        	oe_debug_pub.add ('create_routing_ml: ' || 'TempTable after insert :Op Seq Id: ' || d_op_seq_id
		                  || 'Rtg Seq Id: ' ||d_rtg_seq_id
				  || 'Op Seq #: ' || d_op_seq_num
				  || 'Cfg Rtg Id: ' ||d_cfg_rtg_id  ,2);
      end loop;
      close bos_temp;
    END IF;





    /*-------------------------------------------------------------------------------------+
       Bugfix - 1935580 Reselect to identify unique rows and update cfgrtgid to (-)cfgrtgid
       We are doing this here since we do not want to touch the main update above.
    +-------------------------------------------------------------------------------------*/
    lStmtNum := 51;
    lmodnewCfgRtgId := lCfgRtgId * (-1);
    lmodseqnum:=0;
    lmodtyp:=0;
    lmodrtgseqid :=0;


    open get_op_seq_num(lCfgRtgId);

    loop
    	fetch get_op_seq_num into lmodseqnum,lmodtyp;
    	exit when get_op_seq_num%notfound;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('create_routing_ml: ' || ' Op Seq # : ' || lmodseqnum || ' Op Type : ' || lmodtyp ,2);
		oe_debug_pub.add ('create_routing_ml: ' || 'Esitmated release date lEstRelDate '|| to_char(lEstRelDate,'mm-dd-yy:hh:mi:ss'),2 );
        END IF;

        select max(routing_sequence_id) into lmodrtgseqid
    	from   bom_operation_sequences_temp -- 5336292
        where  operation_seq_num = lmodseqnum
        and    nvl(operation_type,1)= lmodtyp
        and    config_routing_id = lCfgRtgId 			-- bugfix 3239267: replaced last_update_login
	and    last_update_date = glast_update_date;            -- 3180827

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('create_routing_ml: ' || ' Max. Routing Seq Id : ' || lmodrtgseqid,2);
        END IF;

        update bom_operation_sequences_temp -- 5336292
        set    config_routing_id = lmodnewCfgRtgId 		-- bugfix 3239267: replaced last_update_login
        where  operation_seq_num = lmodseqnum
        and    nvl(operation_type,1)= lmodtyp
        and    routing_sequence_id=lmodrtgseqid
        /* Bugfix 2177101/2143014 */
        /*
    	and    effectivity_date     <= greatest(nvl(lEstRelDate, sysdate),sysdate) -- 2650828
        removed due to changes in effectivity date logic
        */
    	and    implementation_date is not null
        /*
    	and    nvl(disable_date,nvl(lEstRelDate, sysdate)+ 1) > NVL(lEstRelDate,sysdate)
	and    nvl(disable_date,sysdate+1) > sysdate;--Bugfix 2771065
        changed due to new effectivity dates logic
        */
        and  ( disable_date is null or (disable_date is not null and disable_date >= sysdate ));
    	/* Bugfix 2177101/2143014 */

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('create_routing_ml: ' || 'Update login to ' || lmodnewCfgRtgId ||' where routing seq Id is '||lmodrtgseqid,2);
        END IF;

    end loop;

    close get_op_seq_num;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('create_routing_ml: ' || ' Model Routing : Marked Finally ' || sql%rowcount || ' rows for insertion' ,2);
     END IF;
        IF PG_DEBUG <> 0 THEN

       open bos_temp(lmodnewCfgRtgId);

       loop
    	fetch bos_temp into d_op_seq_id,d_rtg_seq_id,d_op_seq_num,d_cfg_rtg_id;
    	exit when bos_temp%notfound;
         oe_debug_pub.add ('create_routing_ml: ' || ' TempTable after update :Op Seq Id: ' || d_op_seq_id
	                                         || 'Rtg Seq Id: ' ||d_rtg_seq_id
						 || 'Op Seq# : ' || d_op_seq_num
						 || 'Cfg Rtg Id: ' ||d_cfg_rtg_id  ,2);
       end loop;
       close bos_temp;

     END IF;

    /*-------------------------+
       End Bugfix - 1935580
    +---------------------------*/

    /*-----------------------------------------------------------------+
         First Insert :
         Load  distinct operation steps from Model's routing
    +-------------------------------------------------------------------*/

    lStmtNum := 60;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || 'Inserting into bom_operation_sequences - 1st insert ..',5);
    END IF;

      insert into bom_operation_sequences
        (
        operation_sequence_id,
        routing_sequence_id,
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,             /* using this column to store model op seq id */
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,	-- new column for 11.5.4 BOM patchset
	x_coordinate,           --bugfix 1765149
        y_coordinate            --bugfix 1765149
        )
    select
        bom_operation_sequences_s.nextval,      /* operation_sequence_id */
        lcfgrtgid,                              /* routing_sequence_id */
        os1.operation_seq_num,
        sysdate,                                /* last update date */
        gUserId,                                /* last updated by */
        sysdate,                                /* creation date */
        gUserId,                                /* created by */
        gLoginId,                               /* last update login  */
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
        trunc(sysdate),         /* effective date */
        null,                   /* disable date */
        os1.backflush_flag,
        2,               /* option_dependent_flag */
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
        os1.operation_sequence_id,  /* using request_id  column to store model op seq id */
        1,                          /* program_application_id */
        1,                          /* program_id */
        sysdate,                    /* program_update_date */
        reference_flag,
        nvl(operation_type,1),
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	trunc(sysdate), 	-- new column for 11.5.4 BOM patchset
	os1.x_coordinate,           --bugfix 1765149
        os1.y_coordinate            --bugfix 1765149
    from
        bom_operation_sequences_temp    os1 -- 5336292
      where os1.config_routing_id = lmodnewcfgrtgid ; /*Bugfix 1935580 - change lCfgRtgId to  lmodnewCfgRtgId */
        						-- bugfix 3239267: replaced last_update_login



    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_routing_ml: ' ||  'Inserted ' || sql%rowcount || ' rows in BOS',2);
    END IF;


    /*--------------------------------------------------------------+
       Initialize config_routing_id column so that it can be used  -- bugfix 3239267: replaced last_update_login
       to identify steps from option class routings
    +---------------------------------------------------------------*/

    -- 5336292 : Instead of update we will delete rows
    lStmtNum := 70;
    delete from bom_operation_sequences_temp
    where config_routing_id in (lCfgRtgId, lmodnewcfgrtgid);

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('create_routing_ml: ' ||  'Deleted ' || sql%rowcount || ' rows from temp table',2);
    		-- bugfix 3239267: replaced last_update_login
    END IF;




    /*--------------------------------------------------------------+

	--rtg4

       Mark all steps that need to be picked up from option
       Class routings
        -- Mandatory steps of Class routing
        -- Option dependent steps  associated with options/option Class
	-- "Additional" option dependent steps  associated with options/option Class
        -- Option dependent steps associated with mandatory comps.
	-- "Additional" option dependent steps associated with mandatory comps.
	The "additional" operation steps are the steps stored in the new
	table bom_component_operations to support one-to-many BOM components
	to Routing steps.
    +-------------------------------------------------------------*/

 --perf bugfix 4905857 sql id 16103308
 --Fixed Performance bug in the following sql. AS the following sql is huge one,
 --performance team asked us to divide the sql into pieces. We are planning to
 --insert a record from each sub query in the union class and then update it from
 --interface table


   lStmtNum := 80;
   l_batch_id := bom_import_pub.get_batchid;

   --1st insert
   lStmtNum := 81;
   insert into bom_operation_sequences_temp
  (   operation_sequence_id,
        routing_sequence_id,
	config_routing_id,		-- 5336292
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,             /* using this column to store model op seq id */
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,
	x_coordinate,
	y_coordinate )
   SELECT distinct
        os1.operation_sequence_id, 	   	-- 5336292
        os1.routing_sequence_id,		-- 5336292
	lCfgRtgId,				-- 5336292
	os1.operation_seq_num,
        glast_update_date,			-- 5336292
        gUserId,
        sysdate,
        gUserID,
        gLoginId,
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
	os1.effectivity_date,			-- 5336292
        os1.disable_date,			-- 5336292
        os1.backflush_flag,
        os1.option_dependent_flag,
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
	os1.request_id,
        os1.program_application_id,
        os1.program_id     ,
        os1.program_update_date,
        os1.reference_flag,
        nvl(os1.operation_type,1),
        os1.process_op_seq_id,
        os1.line_op_seq_id,
        os1.yield,
        os1.cumulative_yield,
        os1.reverse_cumulative_yield,
        os1.labor_time_calc,
        os1.machine_time_calc,
        os1.total_time_calc,
        os1.labor_time_user,
        os1.machine_time_user,
        os1.total_time_user,
        os1.net_planning_percent,
	os1.implementation_date,
	x_coordinate,
	y_coordinate
    FROM mtl_system_items si1,
        bom_cto_order_lines bcol,
        bom_operational_routings or1,
        bom_operation_sequences os1
    WHERE bcol.parent_ato_line_id = pLineId
        AND si1.organization_id = pOrgId
        AND si1.inventory_item_id = bcol.inventory_item_id
        AND
        (
            (
                si1.bom_item_type = 1
                AND bcol.wip_supply_type = 6
            )
            OR
            (
                si1.bom_item_type = 2
            )
        ) /* Phantom Model ROUTING Should be included in parent model */
        AND bcol.line_id <> pLineId
        AND or1.assembly_item_id = si1.inventory_item_id
        AND or1.organization_id = si1.organization_id
        AND or1.alternate_routing_designator is NULL
        AND NVL(or1.cfm_routing_flag,2) = lCfmRtgflag
        AND os1.routing_sequence_id = or1.common_routing_sequence_id
        AND
        (
            os1.disable_date is null
            OR
            (
                os1.disable_date is not null
                AND os1.disable_date >= sysdate
            )
        )
        AND
        (
            os1.operation_type in (2,3)
            OR
            (
                os1.option_dependent_flag = 2
                AND NVL(os1.operation_type,1 ) = 1
            )
        );

   If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Number of option class option independent operations selected  = '||sql%rowcount,1);
   End if;
      --2nd insert
      lStmtNum := 82;

    insert into bom_operation_sequences_temp
 (   operation_sequence_id,
        routing_sequence_id,
	config_routing_id,		-- 5336292
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,             /* using this column to store model op seq id */
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,
	x_coordinate,
	y_coordinate
)
SELECT  distinct
        os1.operation_sequence_id, 	   	-- 5336292
        os1.routing_sequence_id,		-- 5336292
	lCfgRtgId,				-- 5336292
	os1.operation_seq_num,
        glast_update_date,			-- 5336292
        gUserId,
        sysdate,
        gUserID,
        gLoginId,
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
	os1.effectivity_date,			-- 5336292
        os1.disable_date,			-- 5336292
        os1.backflush_flag,
        os1.option_dependent_flag,
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
	os1.request_id,
        os1.program_application_id,
        os1.program_id     ,
        os1.program_update_date,
        os1.reference_flag,
        nvl(os1.operation_type,1),
        os1.process_op_seq_id,
        os1.line_op_seq_id,
        os1.yield,
        os1.cumulative_yield,
        os1.reverse_cumulative_yield,
        os1.labor_time_calc,
        os1.machine_time_calc,
        os1.total_time_calc,
        os1.labor_time_user,
        os1.machine_time_user,
        os1.total_time_user,
        os1.net_planning_percent,
	os1.implementation_date,
	x_coordinate,
	y_coordinate
    FROM bom_cto_order_lines bcol1, /* components */
        bom_cto_order_lines bcol2, /* parents  model   */
        bom_inventory_components ic1,
        bom_bill_of_materials b1,
        bom_operational_routings or1,
        bom_operation_sequences os1
    WHERE bcol1.parent_ato_line_id = pLineId
        AND bcol1.item_type_code in ('CLASS','OPTION')
        AND bcol2.parent_ato_line_id = pLineId
        AND bcol2.line_id <> pLineId /*AP*/
        AND bcol2.item_type_code = 'CLASS' /*  option classes */
        AND bcol2.ordered_quantity <> 0
        AND bcol2.line_id = bcol1.link_to_line_id /* check, replaced from parent_comp_seq_id */
        -- begin 1653881
        AND ic1.bill_sequence_id =
        (
        SELECT
            common_bill_sequence_id
        FROM bom_bill_of_materials bbm
        WHERE organization_id = pOrgId
            AND alternate_bom_designator is null
            AND assembly_item_id =
            (
            SELECT DISTINCT
                assembly_item_id
            FROM bom_bill_of_materials bbm1,
                bom_inventory_components bic1
            WHERE bbm1.common_bill_sequence_id = bic1.bill_sequence_id
                AND component_sequence_id = bcol1.component_sequence_id
                AND bbm1.assembly_item_id = bcol2.inventory_item_id
            )
        )
        AND ic1.component_item_id = bcol1.inventory_item_id
        -- end  1653881
        -- 1912376
        AND
        (
            ic1.disable_date is null
            OR
            (
                ic1.disable_date is not null
                AND ic1.disable_date >= sysdate
            )
        )
        AND b1.common_bill_sequence_id = ic1.bill_sequence_id
        AND b1.assembly_item_id = bcol2.inventory_item_id --1272142
        AND b1.alternate_bom_designator is NULL
        AND or1.assembly_item_id = b1.assembly_item_id
        AND or1.organization_id = b1.organization_id
        AND b1.organization_id = pOrgId --1210477
        AND or1.alternate_routing_designator is null
        AND nvl(or1.cfm_routing_flag,2) = lCfmRtgFlag
        AND
        (
            os1.disable_date is null
            OR
            (
                os1.disable_date is not null
                AND os1.disable_date >= sysdate
            )
        )
        AND os1.routing_sequence_id = or1.common_routing_sequence_id
        /* one-to-many BOM components to Rtg operations */
        AND
        (
            (
                os1.operation_seq_num = ic1.operation_seq_num
            )
            OR
            (
                os1.operation_seq_num in
                (
                SELECT
                    bco.operation_seq_num
                FROM bom_component_operations bco
                WHERE bco.component_sequence_id = ic1.component_sequence_id
                )
            )
        )
        /* one-to-many BOM components to Rtg operations */
        AND os1.option_dependent_flag = 1
        AND nvl(os1.operation_type,1) = 1
		and operation_sequence_id not in(select operation_sequence_id
	                                 from bom_operation_sequences_temp);


 If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Number of option class option dependent operations selected  = '||sql%rowcount,1);
   End if;
      --3rd insert
      lStmtNum := 83;

    insert into bom_operation_sequences_temp
 (   operation_sequence_id,
        routing_sequence_id,
	config_routing_id,		-- 5336292
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,             /* using this column to store model op seq id */
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,
	x_coordinate,
	y_coordinate
	)
    SELECT distinct
        os1.operation_sequence_id, 	   	-- 5336292
        os1.routing_sequence_id,		-- 5336292
	lCfgRtgId,				-- 5336292
	os1.operation_seq_num,
        glast_update_date,			-- 5336292
        gUserId,
        sysdate,
        gUserID,
        gLoginId,
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
	os1.effectivity_date,			-- 5336292
        os1.disable_date,			-- 5336292
        os1.backflush_flag,
        os1.option_dependent_flag,
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
	os1.request_id,
        os1.program_application_id,
        os1.program_id     ,
        os1.program_update_date,
        os1.reference_flag,
        nvl(os1.operation_type,1),
        os1.process_op_seq_id,
        os1.line_op_seq_id,
        os1.yield,
        os1.cumulative_yield,
        os1.reverse_cumulative_yield,
        os1.labor_time_calc,
        os1.machine_time_calc,
        os1.total_time_calc,
        os1.labor_time_user,
        os1.machine_time_user,
        os1.total_time_user,
        os1.net_planning_percent,
	os1.implementation_date,
	x_coordinate,
	y_coordinate

    FROM bom_operation_sequences os1,
        bom_operational_routings or1,
        mtl_system_items si2,
        bom_inventory_components ic1,
        bom_bill_of_materials b1,
        mtl_system_items si1,
        bom_cto_order_lines bcol /* Model or option class */
    WHERE bcol.parent_ato_line_id = pLineId
        AND bcol.component_sequence_id is not null
        AND bcol.ordered_quantity <> 0
        AND si1.organization_id = pOrgId
        AND si1.inventory_item_id = bcol.inventory_item_id
        AND si1.bom_item_type in (1,2) /* model or option class */
        AND b1.organization_id = pOrgId
        AND b1.assembly_item_id = bcol.inventory_item_id
        AND b1.alternate_bom_designator is null
        AND ic1.bill_sequence_id = b1.common_bill_sequence_id
        AND ic1.optional = 2
        AND ic1.implementation_date is not null
        AND
        (
            ic1.disable_date is null
            OR
            (
                ic1.disable_date is not null
                AND ic1.disable_date >= sysdate
            )
        )
        AND si2.inventory_item_id = ic1.component_item_id
        AND si2.organization_id = b1.organization_id
        AND si2.bom_item_type = 4 /* standard */
        AND or1.assembly_item_id = b1.assembly_item_id
        AND or1.organization_id = b1.organization_id
        AND or1.alternate_routing_designator is null
        AND nvl(or1.cfm_routing_flag,2) = lCfmRtgFlag /*ensure correct OC rtgs*/
        AND
        (
            os1.disable_date is null
            OR
            (
                os1.disable_date is not null
                AND os1.disable_date >= sysdate
            )
        )
        AND os1.routing_sequence_id = or1.common_routing_sequence_id
        AND os1.option_dependent_flag = 1
        /* one-to-many BOM components to Rtg operations */
        AND
        (
            (
                os1.operation_seq_num = ic1.operation_seq_num
            )
            OR
            (
                os1.operation_seq_num in
                (
                SELECT
                    bco.operation_seq_num
                FROM bom_component_operations bco
                WHERE bco.component_sequence_id = ic1.component_sequence_id
                )
            )
        )
        /* one-to-many BOM components to Rtg operations */
        AND nvl(os1.operation_type,1) = 1
		and operation_sequence_id not in(select operation_sequence_id
	                                 from bom_operation_sequences_temp);

 If PG_DEBUG <> 0 Then
      oe_debug_pub.add('Number of option class mandatory comps dependent operations selected  = '||sql%rowcount,1);
   End if;


      lStmtNum := 84;
IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || ' Option Class outing : Inserted ' || sql%rowcount || ' records in temp table',2 );
    END IF;

    open bos_temp(lCfgRtgId);

    loop
    	fetch bos_temp into d_op_seq_id,d_rtg_seq_id,d_op_seq_num,d_cfg_rtg_id;
    	exit when bos_temp%notfound;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('create_routing_ml: ' || ' Temp table after insert :Op Seq Id : ' || d_op_seq_id || ' Rtg Seq Id : ' ||d_rtg_seq_id  ,2);
		oe_debug_pub.add ('create_routing_ml: ' || ' Temp table after insert :Op Seq # : ' || d_op_seq_num || ' Cfg Rtg Id : ' ||d_cfg_rtg_id  ,2);
        END IF;
    end loop;
    close bos_temp;

    /*-------------------------------------------------------------------------------------+
       Bugfix - 1906371 Reselect to identify unique rows and update cfgrtgid to (-)cfgrtgid
        We are doing this here since we do not want to touch the main update above.
    +-------------------------------------------------------------------------------------*/
    lStmtNum := 81;
    lnewCfgRtgId := lCfgRtgId * (-1);
    lopseqnum:=0;
    loptyp:=0;
    lrtgseqid:=0;


    open get_op_seq_num(lCfgRtgId);

    loop
    	fetch get_op_seq_num into lopseqnum,loptyp;
    	exit when get_op_seq_num%notfound;

    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('create_routing_ml: ' || ' Op Seq # : ' || lopseqnum || ' Op Type : ' || loptyp ,2);
    	END IF;

        select max(routing_sequence_id) into lrtgseqid
    	from bom_operation_sequences_temp -- 5336292
        where operation_seq_num = lopseqnum
        and   nvl(operation_type,1)= loptyp
        and   config_routing_id=lCfgRtgId 			-- bugfix 3239267: replaced last_update_login
	and   last_update_date = glast_update_date;            -- 3180827


    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('create_routing_ml: ' || ' Max. Routing Seq Id : ' || lrtgseqid,2);
    	END IF;

        update bom_operation_sequences_temp -- 5336292
        set config_routing_id = lnewCfgRtgId 	-- bugfix 3239267: replaced last_update_login
        where operation_seq_num = lopseqnum
        and   nvl(operation_type,1)= loptyp
        and   routing_sequence_id=lrtgseqid
        /* Bugfix 2177101/2143014 */
        /*
    	and    effectivity_date     <= greatest(nvl(lEstRelDate, sysdate),sysdate) -- 2650828
        removed for new effectivity dates logic
        */
    	and    implementation_date is not null
        /*
    	and    nvl(disable_date,nvl(lEstRelDate, sysdate)+ 1) > NVL(lEstRelDate,sysdate)
	and    nvl(disable_date,sysdate+1) > sysdate;--Bugfix 2771065
        changed for new effectivity dates logic
        */
        and  ( disable_date is null or (disable_date is not null and disable_date >= sysdate ));
    	/* Bugfix 2177101/2143014 */

    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('create_routing_ml: ' || 'Update login to ' || lnewCfgRtgId ||' where routing seq Id is '||lrtgseqid,2);
    	END IF;

    end loop;

    close get_op_seq_num;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || ' Option Routing : Marked Finally ' || sql%rowcount || ' rows for insertion' ,2);
    END IF;

    open bos_temp(lnewCfgRtgId);

    loop
    	fetch bos_temp into d_op_seq_id,d_rtg_seq_id,d_op_seq_num,d_cfg_rtg_id;
    	exit when bos_temp%notfound;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('create_routing_ml: ' || ' Temp table after update :Op Seq Id : ' || d_op_seq_id || ' Rtg Seq Id : ' ||d_rtg_seq_id  ,2);
		oe_debug_pub.add ('create_routing_ml: ' || ' Temp table after update :Op Seq # : ' || d_op_seq_num || ' Cfg Rtg Id : ' ||d_cfg_rtg_id  ,2);
        END IF;
    end loop;
    close bos_temp;
    /*-------------------------+
       End Bugfix - 1906371
    +---------------------------*/

    /*-----------------------------------------------------------------+
       Second Insert :
       Load  distinct operation steps from Class(es) routing
       ( steps include Option independednt steps, option dependednt
       steps associated with selected components, option dependent
       steps associated with mandatory componets)
    +-------------------------------------------------------------------*/

    lStmtNum := 90;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || 'Inserting into bom_operation_sequences - 2nd insert ..',5);
    END IF;

      insert into bom_operation_sequences
        (
        operation_sequence_id,
        routing_sequence_id,
        operation_seq_num,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        standard_operation_id,
        department_id  ,
        operation_lead_time_percent,
        minimum_transfer_quantity,
        count_point_type       ,
        operation_description,
        effectivity_date,
        disable_date   ,
        backflush_flag,
        option_dependent_flag,
        attribute_category     ,
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
        request_id,             /* using this column to store model op seq id */
        program_application_id,
        program_id     ,
        program_update_date,
        reference_flag,
        operation_type,
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	implementation_date,	-- new column for 11.5.4 BOM patchset
	x_coordinate,           --bugfix 1765149
        y_coordinate            --bugfix 1765149
        )
    select
        bom_operation_sequences_s.nextval, /* operation_sequence_id */
        lcfgrtgid,                         /* routing_sequence_id */
        os1.operation_seq_num,
        sysdate,                           /* last update date */
        gUserId,                           /* last updated by */
        sysdate,                           /* creation date */
        gUserID,                           /* created by */
        gLoginId,                          /* last update login  */
        os1.standard_operation_id,
        os1.department_id,
        os1.operation_lead_time_percent,
        os1.minimum_transfer_quantity,
        os1.count_point_type,
        os1.operation_description,
        trunc(sysdate),                    /* effective date */
        null,                              /* disable date */
        os1.backflush_flag,
        2,                                 /* option_dependent_flag */
        os1.attribute_category,
        os1.attribute1,
        os1.attribute2,
        os1.attribute3,
        os1.attribute4,
        os1.attribute5,
        os1.attribute6,
        os1.attribute7,
        os1.attribute8,
        os1.attribute9,
        os1.attribute10,
        os1.attribute11,
        os1.attribute12,
        os1.attribute13,
        os1.attribute14,
        os1.attribute15,
        os1.operation_sequence_id,  /* using request_id ->  model op seq id */
        1,                          /* program_application_id */
        1,                          /* program_id */
        sysdate,                    /* program_update_date */
        reference_flag,
        nvl(operation_type,1),
        process_op_seq_id,
        line_op_seq_id,
        yield,
        cumulative_yield,
        reverse_cumulative_yield,
        labor_time_calc,
        machine_time_calc,
        total_time_calc,
        labor_time_user,
        machine_time_user,
        total_time_user,
        net_planning_percent,
	trunc(sysdate),	-- new column for 11.5.4 BOM patchset
	os1.x_coordinate,           --bugfix 1765149
        os1.y_coordinate            --bugfix 1765149
       from
	bom_operation_sequences_temp    os1
       where  os1.config_routing_id = lnewCfgRtgId  /*Bugfix 1906371 - change lCfgRtgId to  lnewCfgRtgId */
        				 -- bugfix 3239267: replaced last_update_login
       and    os1.operation_seq_num not in (
            select operation_seq_num
            from   bom_operation_sequences bos1
             where  bos1.routing_sequence_id   = lCfgRtgId
				/* Bugfix 1983384 where  bos1.last_update_login   = lnewCfgRtgId */
            and    nvl(bos1.operation_type,1) = nvl(os1.operation_type,1));

							-- 3093686
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || ' Inserted  ' || sql%rowcount || 'Records ',2 );
    END IF;


    -- New update of 3180827
    lStmtNum := 95;
   lStmtNum := 95;
    delete from bom_operation_sequences_temp
    where config_routing_id in (lCfgRtgId, lmodnewcfgrtgid);

     /*-------------------------------------------------------------------+
             Now update the process_op_seq_id  and line_seq_id of
             all events to new operations sequence Ids (map).
             Old operation_sequence_ids are available in request_id
     +-------------------------------------------------------------------*/

     lStmtNum := 100;
     xTableName := 'BOM_OPERATION_SEQUENCES';
     -- bug 6087687: Events from option class routing operations also need to
     -- be linked to operations on config routing.
     /***********************************************************************
     update bom_operation_sequences bos1
     set    process_op_seq_id = (
         select  operation_sequence_id
         from   bom_operation_sequences bos2
         where  bos1.process_op_seq_id   = bos2.request_id
         and    bos2.routing_sequence_id = lCfgRtgId)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;

     lStmtNum := 110;
     update bom_operation_sequences bos1
     set    line_op_seq_id = (
         select  operation_sequence_id
         from   bom_operation_sequences bos2
         where  bos1.line_op_seq_id = bos2.request_id
         and    bos2.routing_sequence_id = lCfgRtgId)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;
     ***************************************************************************/

     update bom_operation_sequences bos1
     set line_op_seq_id = (
        select bos2.operation_sequence_id
        from bom_operation_sequences bos2,
             bom_operation_sequences bos3
        where bos3.operation_sequence_id = bos1.line_op_seq_id
        and   bos2.routing_sequence_id = lCfgRtgId
        and   bos3.operation_seq_num = bos2.operation_seq_num
        and   bos2.operation_type = 3)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;

     lStmtNum := 110;
     update bom_operation_sequences bos1
     set process_op_seq_id = (
        select bos2.operation_sequence_id
        from bom_operation_sequences bos2,
             bom_operation_sequences bos3
        where bos3.operation_sequence_id = bos1.process_op_seq_id
        and   bos2.routing_sequence_id = lCfgRtgId
        and   bos3.operation_seq_num = bos2.operation_seq_num
        and   bos2.operation_type = 2)
     where bos1.operation_type = 1
     and   bos1.routing_sequence_id = lCfgRtgId;

     -- end bug 6087687


     /*-----------------------------------------------------------+
           Delete routing from routing header  if
           there is no operation associated with the routing
     +-----------------------------------------------------------*/

     lStmtNum := 120;
     xTableName := 'BOM_OPERATIONAL_ROUTINGS';

     delete from BOM_OPERATIONAL_ROUTINGS b1
     where  b1.routing_sequence_id not in
         (select routing_sequence_id
          from   bom_operation_sequences )
     and    b1.routing_sequence_id = lCfgRtgId;

     if sql%rowcount > 0 then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('create_routing_ml: ' ||  'No operations were copied, config routing deleted. ',2);
        END IF;
        return(1);
     end if;


     /*--------------------------------------------------------------+
        If there is a  operation_seq_num associated with
        the config component which  not belong to the
        config routing, the operation_seq_num will be
        set to 1.
     +--------------------------------------------------------------*/
     lStmtNum := 130;
     xTableName := 'BOM_INVENTORY_COMPS_INTERFACE';

     update bom_inventory_comps_interface ci
     set    ci.operation_seq_num = 1
     where not exists
          (select 'op seq exists in config routing'
           from
	       bom_operation_sequences bos,
               bom_operational_routings bor
           where bos.operation_seq_num = ci.operation_seq_num
           and   bos.routing_sequence_id = bor.routing_sequence_id
           and   bor.assembly_item_id = pConfigId
           and   bor.organization_id  = pOrgId
           and   bor.alternate_routing_designator is null)
     and   ci.bill_sequence_id = pCfgBillId;


    /*-----------------------------------------------------+
          Process routing revision table
    +-----------------------------------------------------*/
    lStmtNum   := 70;
    xTableName := 'MTL_RTG_ITEM_REVISIONS';

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('create_routing_ml: ' || 'Inserting into mtl_rtg_item_revisions..',5);
    END IF;
    insert into MTL_RTG_ITEM_REVISIONS
         (
          inventory_item_id,
          organization_id,
          process_revision,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          change_notice  ,
          ecn_initiation_date,
          implementation_date,
          implemented_serial_number,
          effectivity_date       ,
          attribute_category,
          attribute1     ,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          ATTRIBUTE11,
          ATTRIBUTE12,
          ATTRIBUTE13 ,
          ATTRIBUTE14,
          ATTRIBUTE15
         )
    select
          bor.assembly_item_id,
          bor.organization_id,
          mp.starting_revision,
          sysdate,       /* LAST_UPDATE_DATE */
          gUserId,       /* LAST_UPDATED_BY */
          sysdate,       /* CREATION_DATE */
          gUserId,       /* created_by */
          gLoginId,      /* last_update_login */
          NULL,          /* CHANGE_NOTICE  */
          NULL,          /* ECN_INITIATION_DATE */
          TRUNC(SYSDATE), /* IMPLEMENTATION_DATE */
          NULL,          /* IMPLEMENTED_SERIAL_NUMBER */
          TRUNC(SYSDATE), /* EFFECTIVITY_DATE  */
          NULL,          /* ATTRIBUTE_CATEGORY */
          NULL,          /* ATTRIBUTE1  */
          NULL,          /* ATTRIBUTE2 */
          NULL,          /* ATTRIBUTE3 */
          NULL,          /* ATTRIBUTE4 */
          NULL,          /* ATTRIBUTE5 */
          NULL,          /* ATTRIBUTE6 */
          NULL,          /* ATTRIBUTE7 */
          NULL,          /* ATTRIBUTE8 */
          NULL,          /* ATTRIBUTE9 */
          NULL,          /* ATTRIBUTE10 */
          NULL,          /* ATTRIBUTE11 */
          NULL,          /* ATTRIBUTE12 */
          NULL,          /* ATTRIBUTE13 */
          NULL,          /* ATTRIBUTE14 */
          NULL           /* ATTRIBUTE15 */
     from bom_operational_routings bor,
          mtl_parameters  mp
     where bor.routing_sequence_id = lCfgRtgId
     and   bor.organization_id     = mp.organization_id;

     /*------------------------------------------------+
        ** Load operation resources  table
	** 3 new columns added for WIP Simultaneous Resources
     +-------------------------------------------------*/

     xTableName := 'BOM_OPERATION_RESOURCES';
     lStmtNum := 150;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('create_routing_ml: ' || 'Inserting into bom_operation_resources..',5);
     END IF;
     insert into BOM_OPERATION_RESOURCES
         (
         operation_sequence_id,
         resource_seq_num,
         resource_id    ,
         activity_id,
         standard_rate_flag,
         assigned_units ,
         usage_rate_or_amount,
         usage_rate_or_amount_inverse,
         basis_type,
         schedule_flag,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         resource_offset_percent,
	 autocharge_type,
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
         request_id,
         program_application_id,
         program_id,
         program_update_date,
	 schedule_seq_num,
	 substitute_group_num,
	 setup_id,			/*bugfix2950774*/
	 principle_flag
         )
     select
         osi.operation_sequence_id, /* operation sequence id */
         bor.resource_seq_num,
         bor.resource_id,
                                         /* resource id */
         bor.activity_id,
         bor.standard_rate_flag,
         bor.assigned_units,
         bor.usage_rate_or_amount,
         bor.usage_rate_or_amount_inverse,
         bor.basis_type,
         bor.schedule_flag,
         SYSDATE,                        /* last update date */
         gUserId,                        /* last updated by */
         SYSDATE,                        /* creation date */
         gUserId,                        /* created by */
         1,                              /* last update login */
         bor.resource_offset_percent,
         bor.autocharge_type,
         bor.attribute_category,
         bor.attribute1,
         bor.attribute2,
         bor.attribute3,
         bor.attribute4,
         bor.attribute5,
         bor.attribute6,
         bor.attribute7,
         bor.attribute8,
         bor.attribute9,
         bor.attribute10,
         bor.attribute11,
         bor.attribute12,
         bor.attribute13,
         bor.attribute14,
         bor.attribute15,
         NULL,                           /* request_id */
         NULL,               /* program_application_id */
         NULL,                           /* program_id */
         NULL,                   /* program_update_date */
	 bor.schedule_seq_num,
	 bor.substitute_group_num,
	 bor.setup_id,			/* Bugfix2950774 */
	 bor.principle_flag
     from
         bom_operation_sequences osi,
         bom_operation_resources bor
     where osi.routing_sequence_id = lCfgRtgId
     and   osi.request_id  = bor.operation_sequence_id;
     /* request_id contains model op seq_id now */



     /*------------------------------------------------+
        ** Load sub operation resources  table
	** new table for WIP Simultaneous Resources
     +-------------------------------------------------*/
     xTableName := 'BOM_SUB_OPERATION_RESOURCES';
     lStmtNum := 155;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('create_routing_ml: ' || 'Inserting into bom_sub_operation_resources ..',5);
     END IF;
     insert into BOM_SUB_OPERATION_RESOURCES
		(operation_sequence_id,
 		substitute_group_num,
 		--resource_seq_num,
 		resource_id,
 		--scheduling_seq_num,
                schedule_seq_num,
 		replacement_group_num,
 		activity_id,
 		standard_rate_flag,
 		assigned_units,
 		usage_rate_or_amount,
 		usage_rate_or_amount_inverse,
 		basis_type,
 		schedule_flag,
 		last_update_date,
 		last_updated_by,
 		creation_date,
 		created_by,
 		last_update_login,
 		resource_offset_percent,
 		autocharge_type,
 		principle_flag,
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
		setup_id,			/* bugfix2950774 */
 		request_id,
 		program_application_id,
 		program_id,
 		program_update_date
		)
	select
		osi.operation_sequence_id,
 		bsor.substitute_group_num,
 		--bsor.resource_seq_num,
 		bsor.resource_id,
 		--bsor.scheduling_seq_num,
                bsor.schedule_seq_num,
 		bsor.replacement_group_num,
 		bsor.activity_id,
 		bsor.standard_rate_flag,
 		bsor.assigned_units,
 		bsor.usage_rate_or_amount,
 		bsor.usage_rate_or_amount_inverse,
 		bsor.basis_type,
 		bsor.schedule_flag,
 		SYSDATE,	/*last_update_date*/
 		gUserId,	/*last_updated_by*/
 		SYSDATE,	/*creation_date*/
 		gUserId,	/*created_by*/
 		1,		/*last_update_login*/
 		bsor.resource_offset_percent,
 		bsor.autocharge_type,
 		bsor.principle_flag,
 		bsor.attribute_category,
 		bsor.attribute1,
 		bsor.attribute2,
		bsor.attribute3,
		bsor.attribute4,
		bsor.attribute5,
		bsor.attribute6,
 		bsor.attribute7,
		bsor.attribute8,
		bsor.attribute9,
		bsor.attribute10,
		bsor.attribute11,
 		bsor.attribute12,
		bsor.attribute13,
		bsor.attribute14,
		bsor.attribute15,
		bsor.setup_id,			/* bugfix2950774 */
 		NULL,		/*request_id*/
 		NULL,		/*program_application_id*/
 		NULL,		/*program_id*/
 		NULL		/*program_update_date*/
	from
         	bom_operation_sequences osi,
         	bom_sub_operation_resources bsor
     	where osi.routing_sequence_id = lCfgRtgId
     	and   osi.request_id  = bsor.operation_sequence_id;
     	/* request_id contains model op seq_id now */


     /*---------------------------------------------------+
		** Process operation Networks table
     +---------------------------------------------------*/
     lStmtNum := 380;
     xTableName := 'BOM_OPERATION_NETWORKS';

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('create_routing_ml: ' || 'Inserting into bom_operation_networks ..',5);
     END IF;
     INSERT INTO bom_operation_networks
            ( FROM_OP_SEQ_ID,
            TO_OP_SEQ_ID,
            TRANSITION_TYPE,
            PLANNING_PCT,
            EFFECTIVITY_DATE,
            DISABLE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1  ,
            ATTRIBUTE2  ,
            ATTRIBUTE3  ,
            ATTRIBUTE4  ,
            ATTRIBUTE5  ,
            ATTRIBUTE6  ,
            ATTRIBUTE7  ,
            ATTRIBUTE8  ,
            ATTRIBUTE9  ,
            ATTRIBUTE10 ,
            ATTRIBUTE11 ,
            ATTRIBUTE12 ,
            ATTRIBUTE13 ,
            ATTRIBUTE14 ,
            ATTRIBUTE15
            )
    SELECT
           bos3.operation_sequence_id,
           bos4.operation_sequence_id,
           bon.TRANSITION_TYPE,
           bon.PLANNING_PCT,
           bon.EFFECTIVITY_DATE,
           bon.DISABLE_DATE,
           bon.CREATED_BY,
           bon.CREATION_DATE,
           bon.LAST_UPDATED_BY,
           bon.LAST_UPDATE_DATE,
           bon.LAST_UPDATE_LOGIN,
           bon.ATTRIBUTE_CATEGORY,
           bon.ATTRIBUTE1,
           bon.ATTRIBUTE2,
           bon.ATTRIBUTE3,
           bon.ATTRIBUTE4,
           bon.ATTRIBUTE5,
           bon.ATTRIBUTE6,
           bon.ATTRIBUTE7,
           bon.ATTRIBUTE8,
           bon.ATTRIBUTE9,
           bon.ATTRIBUTE10,
           bon.ATTRIBUTE11,
           bon.ATTRIBUTE12,
           bon.ATTRIBUTE13,
           bon.ATTRIBUTE14,
           bon.ATTRIBUTE15
    FROM   bom_operation_networks    bon,
           bom_operation_sequences   bos1, /* 'from'  Ops of model  */
           bom_operation_sequences   bos2, /* 'to'    Ops of model  */
           bom_operation_sequences   bos3, /* 'from'  Ops of config */
           bom_operation_sequences   bos4, /* 'to'    Ops of config */
           bom_operational_routings  brif
    WHERE  bon.from_op_seq_id         = bos1.operation_sequence_id
    AND     bon.to_op_seq_id           = bos2.operation_sequence_id
    AND     bos1.routing_sequence_id   = bos2.routing_sequence_id
    AND     bos3.routing_sequence_id   = brif.routing_sequence_id
    AND     brif.cfm_routing_flag      = 1
    AND     brif.routing_sequence_id   = lCfgrtgId
    AND     bos3.operation_seq_num     = bos1.operation_seq_num
    AND     NVL(bos3.operation_type,1) = NVL(bos1.operation_type, 1)
    AND     bos4.routing_sequence_id   = bos3.routing_sequence_id
    AND     bos4.operation_seq_num     = bos2.operation_seq_num
    AND     NVL(bos4.operation_type,1) = NVL(bos2.operation_type, 1)
    AND     bos1.routing_sequence_id   = (     /* find the model routing */
            select common_routing_sequence_id --5103316
            from   bom_operational_routings   bor,
                   mtl_system_items msi
            where  brif.assembly_item_id = msi.inventory_item_id
            and    brif.organization_id  = msi.organization_id
            and    bor.assembly_item_id  = msi.base_item_id
            and    bor.organization_id   = msi.organization_id
            and    bor.cfm_routing_flag  = 1
            and    bor.alternate_routing_designator is null );


     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('create_routing_ml: ' || xTableName || '-'|| lStmtNum || ': ' || sql%rowcount,2 );
     END IF;

     lstmtNum := 390;

     --
     -- Check if flow_manufacturing is installed
     --

     l_install_cfm := FND_INSTALLATION.Get_App_Info(application_short_name => 'FLM',
                                                    status      => l_status,
                                                    industry    => l_industry,
                                                    oracle_schema => l_schema);

     -- Begin Bugfix 8778162: Copy the attachment on routing header from model
     -- to config.
     lstmtNum := 395;
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('create_routing_ml: Copying the attachment on routing header.', 2);
	oe_debug_pub.add ('create_routing_ml: Model routing_sequence_id:' || lItmRtgId, 2);
     END IF;

     FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
           X_from_entity_name              =>'BOM_OPERATIONAL_ROUTINGS',
           X_from_pk1_value                =>lItmRtgId,
           X_from_pk2_value                =>'',
           X_from_pk3_value                =>'',
           X_from_pk4_value                =>'',
           X_from_pk5_value                =>'',
           X_to_entity_name                =>'BOM_OPERATIONAL_ROUTINGS',
           X_to_pk1_value                  =>lCfgRtgId,
           X_to_pk2_value                  =>'',
           X_to_pk3_value                  =>'',
           X_to_pk4_value                  =>'',
           X_to_pk5_value                  =>'',
           X_created_by                    =>gUserId,
           X_last_update_login             =>gLoginId,
           X_program_application_id        =>'',
           X_program_id                    =>'',
           X_request_id                    =>''
           );
     -- End Bugfix 8778162

     --
     -- For each operation in the routing, copy attachments of operations
     -- copied from model/option class to operations on the config item
     --

     for nextop in allops loop

       lstmtNum := 400;

       FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
           X_from_entity_name              =>'BOM_OPERATION_SEQUENCES',
           X_from_pk1_value                =>nextop.request_id,
           X_from_pk2_value                =>'',
           X_from_pk3_value                =>'',
           X_from_pk4_value                =>'',
           X_from_pk5_value                =>'',
           X_to_entity_name                =>'BOM_OPERATION_SEQUENCES',
           X_to_pk1_value                  =>nextop.operation_sequence_id,
           X_to_pk2_value                  =>'',
           X_to_pk3_value                  =>'',
           X_to_pk4_value                  =>'',
           X_to_pk5_value                  =>'',
           X_created_by                    =>1,
           X_last_update_login             =>'',
           X_program_application_id        =>'',
           X_program_id                    =>'',
           X_request_id                    =>''
           );
     end loop;

     lstmtNum := 410;
     select nvl(cfm_routing_flag,2)
     into   lCfmRtgFlag
     from   bom_operational_routings
     where  routing_sequence_id = lCfgrtgId;


	--
	-- if flow manufacturing is installed and the 'Perform Flow Calulations'
     	-- parameter is set to 2 or 3 (perform calculations based on processes or perform
     	-- calulations based on Line operations) the routing is 'flow routing' then
     	-- calculate operation times, yields, net planning percent  and total
     	-- product cycle time for config routing
	--


     lstmtNum := 410;
     if ( l_status = 'I' and pFlowCalc >1 and lCfmRtgflag = 1 ) then

        --
        -- Calculate Operation times
        --

        BOM_CALC_OP_TIMES_PK.calculate_operation_times(
                             arg_org_id              => pOrgId,
                             arg_routing_sequence_id => lcfgRtgId);

        --
        -- Calculate cumu yield, rev cumu yield and net plannning percent
        --

        BOM_CALC_CYNP.calc_cynp(
                      p_routing_sequence_id => lcfgRtgId,
                      p_operation_type      => pFlowCalc,      /* operation_type = process */
                      p_update_events       => 1 );     /* update events */

        --
        -- Calculate total_product_cycle_time
        --

        BOM_CALC_TPCT.calculate_tpct(
                      p_routing_sequence_id => lcfgRtgId,
                      p_operation_type      => pFlowCalc);      /* Operation_type = Process */
     end if;

       -- Feature :Serial tracking in wip
       -- LOgic : serial tracking is enabled only when serial control mode is 'pre-defined' (ie 2)
       -- If model serialization_start_op seq is not populated, we will copy the minimum 'seriallization_start_op'
       -- of OC's chosen
       --modified by kkonada


     if( lCfmRtgFlag = 1) then ---flow doesnot support serial tracking
       null;
     else
            lstmtNum := 411;
            Select serial_number_control_code
            into   l_ser_code
            from   mtl_System_items
            where  inventory_item_id = pModelId
            and organization_id =pOrgId;

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('create_routing_ml: ' || 'serial_number_control_code of model is  '||l_ser_code , 4);
             END IF;

       	    if ( l_ser_code = 2) then --serialized ,pre-defined

                 lstmtNum := 412;

		  IF PG_DEBUG <> 0 THEN
		  	oe_debug_pub.add('create_routing_ml: ' || 'select serial start op from model  ' , 4);
		  END IF;


		  BEGIN
		         --will select serial start op of model, only if effective on the day
			 --as routing generation takes care of eefectivity, we check if op seq is present in config routing
		  	 select serialization_start_op
			 into l_ser_start_op
			 from bom_operational_routings
			 where assembly_item_id = pModelId
			 and alternate_routing_designator is null
			 and organization_id = pOrgId
			 and serialization_start_op in
						(Select OPERATION_SEQ_NUM
  	 		  		   	from bom_operation_sequences
						where routing_sequence_id = lCfgRtgId
						 );
		 EXCEPTION
		   WHEN no_data_found THEN
			l_ser_start_op := NULL;
		  END;

		 IF PG_DEBUG <> 0 THEN
		 	oe_debug_pub.add('create_routing_ml: ' || 'l_ser_start_op ie serialization_start_op from model is  '|| l_ser_start_op, 4);
		 END IF;

		 if(l_ser_start_op is null)then

                   lstmtNum := 413;
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('create_routing_ml: ' || 'before updating config routing with serial start op of option class', 4);
                   END IF;

                   begin
                	update bom_operational_routings
                   	set serialization_start_op =
					( select min( serialization_start_op)
                                          from bom_operational_routings
                                          where organization_id = pOrgId
                                          and alternate_routing_designator is null
                                          and assembly_item_id in
                                                       ( select component_item_id
                                                         from  bom_inventory_comps_interface
                                                         where bom_item_type =2
                                                         and  bill_sequence_id = pCfgBillId
                                                        )
					  and serialization_start_op in
							(Select OPERATION_SEQ_NUM
  	 							   	from bom_operation_sequences
									where routing_sequence_id = lCfgRtgId
							 )--serial start op exists as a operation in routing(ie effective oper)
                                         )
                  	where assembly_item_id = pConfigId
                 	and alternate_routing_designator is null
                  	and organization_id = pOrgId;

                       l_row_count := sql%rowcount;
                   exception
                     when no_data_found then

                	   IF PG_DEBUG <> 0 THEN
                	   	oe_debug_pub.add('create_routing_ml: ' || 'No option classes chosen while creating coonfiguration ', 4);
                	   END IF;

		   end;

                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('create_routing_ml: ' || 'no# config rows rows updated with OC serial start opseq->'||l_row_count, 4);
                   END IF;

		  else --model has serial start op seq

			lstmtNum := 414;
			update bom_operational_routings
			set serialization_start_op = l_ser_start_op
			where routing_sequence_id =  lCfgRtgId ;

			 IF PG_DEBUG <> 0 THEN
			 	oe_debug_pub.add('create_routing_ml: ' || 'updated with serial start op of model, serial start op =>'||l_ser_start_op  , 4);
			 END IF;


                 end if;--l_ser_start_op


            end if;--l_ser_code


     end if;

     xRtgId := lCfgRtgId;

     return (1);

 EXCEPTION
        when no_data_found then

             xErrorMessage := 'CTOCRTGB:'||to_char(lStmtNum)||'raised NDF ';
	     xMessageName := 'CTO_CREATE_ROUTING_ERROR';
             xRtgId := 0;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('create_routing_ml: ' || xErrorMessage, 1);
             END IF;
             return(0);

        when FND_API.G_EXC_ERROR then

             xErrorMessage := 'CTOCRTGB:'||to_char(lStmtNum)||' raised expected error.';
	     xMessageName := 'CTO_CREATE_ROUTING_ERROR';
             xRtgId := 0;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('create_routing_ml: ' || xErrorMessage, 1);
             END IF;
             return(0);

        when FND_API.G_EXC_UNEXPECTED_ERROR then

             xErrorMessage := 'CTOCRTGB:'||to_char(lStmtNum)||' raised unexpected error.';
	     xMessageName := 'CTO_CREATE_ROUTING_ERROR';
             xRtgId := 0;
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('create_routing_ml: ' || xErrorMessage, 1);
             END IF;
             return(0);

        when others then
             xErrorMessage := 'CTOCRTGB:'||to_char(lStmtNum)||'raised OTHERS exception.';
	     xMessageName := 'CTO_CREATE_ROUTING_ERROR';
             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add ('create_routing_ml: ' || xErrorMessage, 1);

             	oe_debug_pub.add ('create_routing_ml: ' || 'Error Message : '||sqlerrm);
             END IF;
             return(0);

 END create_routing_ml;

END CTO_CONFIG_ROUTING_PK;

/
