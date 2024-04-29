--------------------------------------------------------
--  DDL for Package Body CTO_AUTO_PROCURE_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_AUTO_PROCURE_PK" AS
/*$Header: CTOPROCB.pls 120.23.12010000.9 2010/10/27 12:08:28 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTOPROCB.pls                                                  |
| DESCRIPTION:                                                                |
|               Contain all CTO and WF related APIs for AutoCreate Purchase   |
|               Requisitions. This Package creates the following              |
|               Procedures                                                    |
|               1. AUTO_CREATE_PUR_REQ_CR                                     |
|               2. POPULATE_REQ_INTERFACE                                     |
|               Functions                                                     |
|               1. GET_RESERVED_QTY                                           |
|               2. GET_NEW_ORDER_QTY                                          |
| HISTORY     :                                                               |
| 20-Sep-2001 : RaviKumar V Addepalli Initial version                         |
|                                                                             |
| 28-Nov-2001 : Renga Kannan Modified the workflow status                     |
|                                                                             |
| 17-Jan-2001 : Renga Kannan Modified to get the  accouting info              |
|               from the correct organization
|                                                                             |
|                                                                             |
|                    							      |
| 23-Mar-2001 : Renga Kannan Added the whole code part for                    |
|                            Purchase Rollup
|
|
| 04-16-2002  : Renga Kannan Added Ship_to_location_id in interface table     i|
|
|
| 07/09/2002  : Renga Kannan Removed the error report launching code          |
|
| 05/17/2002  : Renga Kannan Added comments for Purchase Price rollup procedure|



|               Modified on 20-SEP-2002 Sushant Sawant
|                                       Fixed bug#2633259
|                                       Type error CREATE_AND_APPROVE
|
|                                                                             |
|                    							      |
| 27-Nov-2002 : Kundan Sarkar Fix 2503104 Passing user_item_description from  |
|               oe_order_lines_all to po_requisitions_interface    	      |
|									      |
|
| 12-DEC-2002  Kiran Konada added code for MLSUPPLY feature
|		added a new parameter to proc populate_req_interface
|
|               Modified on 02-JAN-2003 Sushant Sawant
|                                       Fixed bug#2726167
|                                       Global Agreements additional parameter
|
|                                                                             |
|                    							      |
| 23-Jan-2003 : Kundan Sarkar Fix 2503104 Revert earlier fix and introduce    |
|               dyanamic SQL to  avoid compile time dependency of OM fix      |
|		related to USER_ITEM_DESCRIPTION column in OE_ORDER_LINES_ALL |
|
| 31-JAN-2003	Kiran Konada  bugfix 2780392
|		Addded a IF condition to check for null value passed in
|		interface_source_line_id value passed to populate_req_interafce
|
| 12-FEB-2003   Kiran Konada
|		In populate_req_inetrface proc
|		moved the sql used to get project_id and task_id INTO a
|		If block whihc gets executed only when p_interface_source_line_id
|		is not null
|
|
| 03/06/03      Fixed the bug w.r.t Operating unit in Global Purchase agreement
|
| 21-May-2003 : Kundan Sarkar Fix 2971582 ( Customer bug 2931808 )
|               Offset schedule_ship_date by post processing lead time to calculate
|		need by date
|
| 30-May-2003  : Kundan Sarkar Fix 2985471 ( Customer bug 2978640 )
|		Set Org Context
|		Move Check_hold logic after checking sourcing type so that
|		Check hold will not be called for MAKE item
|
|
|13-AUG-2003	: Kiran Konada
                   for bug# 3063156
                   propagte fix 3042904 to main
|                 passed the project_id and task_id as parameter of
|		  of populate_req_interface for lower-level buy items
|		  fix related to
|		  correcting spelling mistakes for ONT_SOURCE_ODE
|                 and po_req_requested is fixed by shashi in main already
|
|
|24-SEP-2003   : Kiran Konada
|                Chnages for patchset-J
|                with mutiple sources enhancement ,
|                expected error from query sourcing org has been removed
|                source_type =66 refers to mutiple sourcing
|
|               statements after call to query org has been modified to look at
|               source type =66 instead of   expected error status
|
||03-NOV-2003    Kiran Konada
|
|                 Main propagation bug#3140641
|
|               revrting bufix 3042904 (main bug 3063156)with  bug#3129117
|               ie have reverted changes made on |13-AUG-2003
|               Removed project_id and task_id as parameters
|               Hence dependency mentioned in 3042904 has been REMOVED
|               ie following files are not dependent as on 13-AUG-2003
|                CTOWFAPB.pls
|                CTOPROCB.pls
|                CTOSUBSB.pls (only for I customers)
|
|Jul 29 2004     Kaza
|                Forward ported ct bugs 3590305 and 3599860.Significant changes
|                to auto_create_purchase_req_cr. Please refer to the bug texts
|                for details. In short, take a snapshot of eligible order lines
|                from oe_order_lines_all into bom_cto_order_lines_temp. Loop
|                thru the temp 1000 records at a time, lock each line
|                individually, process and commit.
|
|Oct 26,2004    Kkonada
|               bug fix 3871646
|               Need to remove hard coded schema names, refer to bug for more details
|
|Jan 28, 2005   Renga Kannan
|               Front Port Bug Fix : 4068164
|               Passed item revision information to Purchase req interface
|               for Non configured ATO items
|
|Apr 14, 2005   Renga Kannan
|               Fixed ST bug 4172156
|               Purchase price rollup batch program should honor load type and
|               do rollup for ato items in the order.
|               Also, we have removed the hold check in the batch program as this is not
|               required .
|
|
|June 16,2005	Kiran Konada
|                changes for OPM project.
|		 comment string : OPM
|		 --auto_create_pur_req_cr--
|		 oe_lines_cur changes to get sec_qty,sec_uom and grade
|		 call to pop_req_iface passes sec_qty,sec_uom and grade as part of
|		 record structure l_req_input_data
|		 replaced call to query_sourcing_org with check_cto_can_create_supply
|		 Concuurent program will not create supply if custom api check_supply returns
|		 N(going forward)
|		 --populate_req_iface--
|		 sec_qty,sec_uom and grade inserted into po_reqs_iface_all
|		 call INV api to check for porcess org
|		 HARD Dependecnies:
|                CTOUTILB.check_cto_can_create_supply
|                INV api INV_GMI_RSV_BRANCH.Process_Branch
|
|Aug 9th,2005   Kiran Konada
|	        4545070
|               Replaced call to OE_ORDER_WF_UTIL.update_flow_status_code with
|               call to CTO_WORKFLOW_API_PK.display_wf_status
|
|
|Aug 29th,2005  Kiran Konada
|               bugfix 4545559
|               changed the insert from po_requisitions_interface to
|               po_requisitions_interface_all table
|
|
|Sep 22nd,2005  Kiran Konada
|               Created new local procedure Get_opm_charge_account
|               calling SLA OPM api to get charge and accrual account id
|               Dependency: aru#4610085(pack spec and stubbed out pkg body)
|               GMF_transaction_accounts_PUB.get_accounts
|               Calling MRP_SOURCING_API_PK.mrp_sourcing  to get sourcing
|               vendor and vendor site id. This API has been there from 11.5.10
|               Talked to Usha, we dont require a dependent aru for this.
|
|
=============================================================================*/

-- CTO_AUTO_PROCURE_PK
-- following parameters are created for
   g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_AUTO_PROCURE_PK';
   gMrpAssignmentSet        NUMBER ;


--- Added by Renga for Purchaes price rollup


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

--    		Forward declaration for local procedures for Purchase price rollup
--              Module. All these procedures are private to this package and as of now used
--              only in Purchase price rollup module
--		To get more details look at the comments in the procedure body
--              Created by Renga Kannan on 03/23/01

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

g_pg_level  Number;
Function config_exists_in_blanket(
                        p_config_item_id   IN Number,
                        p_doc_header_id    IN Number) return boolean;

Procedure config_asl_exists(
                        p_vendor_id        IN  Number,
                        p_vendor_site_id   IN  Number,
                        p_vendor_list      IN  PO_AUTOSOURCE_SV.vendor_record_details,
			x_asl_found        OUT NOCOPY Boolean,
			x_index            OUT NOCOPY Number);

procedure Reduce_vendor_by_ou(
                        p_vendor_details    in  PO_AUTOSOURCE_SV.vendor_record_details,
			p_config_item_id    in  Number,
			p_line_id           in  Number,
			p_mode              in  Varchar2,
                        x_vendor_details    out NOCOPY PO_AUTOSOURCE_SV.vendor_record_details);



procedure  insert_blanket_line(
                    p_doc_line_id     IN  Number,
                    p_item_id         IN  Number,
                    p_item_rev        IN  Varchar2,
                    p_price           IN  Number,
		    p_int_header_id   IN  Number,
		    p_segment1        IN  mtl_system_items.segment1%type,
		    p_start_date      IN  date,
		    p_end_date        IN  date,
                    x_return_status   OUT NOCOPY Varchar2,
                    x_msg_count       OUT NOCOPY Number,
                    x_msg_data        OUT NOCOPY varchar2);

procedure insert_blanket_header(
                     p_doc_header_id   IN      Number,
                     p_batch_id        IN OUT  NOCOPY Number,
		     x_int_header_id   Out   NOCOPY  Number,
                     x_org_id          OUT   NOCOPY  po_headers_all.org_id%type,
                     x_return_status   OUT   NOCOPY  varchar2,
                     x_msg_count       OUT   NOCOPY  Number,
                     x_msg_data        OUT   NOCOPY  varchar2);

Procedure  Derive_start_end_date(
                                p_item_id         IN   bom_cto_order_lines.inventory_item_id%type,
                                p_vendor_id       IN   Number,
                                p_vendor_site_id  IN   Number,
                                p_assgn_set_id    IN   Number ,
                                x_start_date      OUT NOCOPY date ,
                                x_end_date        Out NOCOPY date);

Procedure empty_ou_global;

Procedure process_purchase_price(
                                  p_config_item_id       in      Number,
                                  p_batch_number         in out NOCOPY number,
				  p_group_id             in      number,
				  p_overwrite_list_price in      varchar2,
				  p_line_id              in      number,
				  p_mode                 in      Varchar2 default 'ORDER',
  				  x_oper_unit_list       IN OUT NOCOPY cto_auto_procure_pk.oper_unit_tbl,
				  x_return_status        out NOCOPY varchar2,
				  x_msg_data             out NOCOPY varchar2,
				  x_msg_count            out NOCOPY number);

-- bug fix 3590305/3599860. rkaza. 08/03/2004.
PROCEDURE load_lines_into_bcolt(p_sales_order_line_id NUMBER,
                               p_sales_order NUMBER,
			       p_organization_id VARCHAR2,
			       p_offset_days NUMBER,
			       x_return_status out NOCOPY VARCHAR2 );


PROCEDURE update_bcolt_line_status(p_line_id NUMBER,
                                   p_status NUMBER,
			           x_return_status out NOCOPY VARCHAR2 );


--OPM
--to get charge and accrual account id as per SLA architecture
PROCEDURE Get_opm_charge_account(p_interface_source_line_id  NUMBER
                                ,p_item_id        NUMBER
			        ,p_destination_org_id NUMBER
				,p_source_type_code   VARCHAR2
			        ,p_operating_unit     NUMBER
			        ,x_charge_account_id  OUT NOCOPY NUMBER
			        ,x_accrual_account_id OUT NOCOPY NUMBER
				,x_return_status      OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

--			End of Forward declarations

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------



-- rkaza. Added the procedure for ireq project. 05/02/2005.
-- Start of comments
-- API name : get_need_by_date
-- Type	    : Public
-- Pre-reqs : None.
-- Function : Given item id, org id, SSD and source type (1 or 3), it returns
--	      need by date for the item. Used for external and internal reqs
-- Parameters:
-- IN	    : p_source_type           	IN NUMBER	Required
--	         1 or 3 (external or internal req).
--	      p_item_id			IN NUMBER 	Required
--	      p_org_id			IN NUMBER 	Required
--		 ship from org id
-- Version  : Current version	115.20
--	         Added this description
--	      Initial version 	115.17
-- End of comments
PROCEDURE get_need_by_date(p_source_type IN NUMBER,
                          p_item_id IN NUMBER,
                          p_org_id  IN NUMBER,
                          p_schedule_ship_date IN DATE,
                          x_need_by_date OUT NOCOPY DATE,
                          x_return_status OUT NOCOPY VARCHAR2) IS

l_offset_days     NUMBER;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

if p_source_type = 3 then -- external req

   -- rkaza. Need to consider post process lead time only for
   -- external reqs.

   -- Bugfix 3077912: Offset Scheduled ship date by post-processing
   -- lead time to get need_by_date.

   select nvl(postprocessing_lead_time,0) into   l_offset_days
   from   mtl_system_items
   where  inventory_item_id = p_item_id
   and    organization_id = p_org_id;

   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_need_by_date: l_offset_days=' || l_offset_days, 1);
   END IF;

   -- rkaza. Need to consider the manufacturing calendar while
   -- determining need by date

   select CAL.CALENDAR_DATE into x_need_by_date
   from   bom_calendar_dates cal,  mtl_parameters mp
   where  mp.organization_id = p_org_id
   and cal.calendar_code  = mp.calendar_code
   and cal.exception_set_id =  mp.calendar_exception_set_id
   and cal.seq_num = (select cal2.prior_seq_num - nvl(l_offset_days, 0)
                      from bom_calendar_dates cal2
                      where cal2.calendar_code = mp.calendar_code
                      and cal2.exception_set_id = mp.calendar_exception_set_id
                      and cal2.calendar_date= trunc(p_schedule_ship_date)
                     );

elsif p_source_type = 1 then -- internal req.
   -- rkaza. For internal reqs, SSD itself is need by date. ISO will
   -- be created with this date as SAD and in transit time will be
   -- factored in when calculating ISO's SSD.

   x_need_by_date := p_schedule_ship_date;

end if;

IF PG_DEBUG <> 0 THEN
   oe_debug_pub.add('get_need_by_date: x_need_by_date = '|| x_need_by_date, 1);
END IF;

EXCEPTION

when FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_need_by_date: ' || 'expected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;

when FND_API.G_EXC_UNEXPECTED_ERROR then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_need_by_date: ' || 'unexpected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

when others then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_need_by_date: ' || 'exception others: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_need_by_date;



-- rkaza. ireq project. 05/06/2005.
-- Added new conc program parameter p_create_req_type that specifies whether
-- to create internal or external reqs or both.
-- This parameter will have a default null for backward compatibility in case
-- of prescheduled program runs without this parameter.

/**************************************************************************
   Procedure:   AUTO_CREATE_PUR_REQ_CR
   Parameters:  p_sales_order             NUMBER    -- Sales Order number.
                p_dummy_field             VARCHAR2  -- Dummy field for the Concurrent Request.
                p_sales_order_line_id     NUMBER    -- Sales Order Line number.
                p_organization_id         VARCHAR2  -- Ship From Organization ID.
                current_organization_id   NUMBER    -- Current Org ID
                p_offset_days             NUMBER    -- Offset days.
		p_create_req_type         NUMBER  -- specifies whether to create int or ext reqs or both.

   Description: This procedure is called from the concurrent progran to run the
                AutoCreate Purchase Requisitions.
*****************************************************************************/
PROCEDURE auto_create_pur_req_cr (
           errbuf        OUT NOCOPY  VARCHAR2,
           retcode       OUT NOCOPY  VARCHAR2,
           p_sales_order             NUMBER,
           p_dummy_field             VARCHAR2,
           p_sales_order_line_id     NUMBER,
           p_organization_id         VARCHAR2,
           current_organization_id   NUMBER, -- VARCHAR2,
           p_offset_days             NUMBER,
	   p_create_req_type         NUMBER default null) AS

lSourceCode               VARCHAR2(100);


/**** Begin Bugfix 3590305 / 3599860  ****/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Changed the architecture to enhance locking mechanism and
    to improve performance.

    With this fix, we will perform the following:
    i)   Identify the lines to be processed and insert into
         a global temp table with a PENDING status.
    ii)  Fetch it from this temp table in batch of 1000.
    iii) Lock the line being processed.
         At this time, get the line details once again to get the new
         picture. An order-line could have changed from the time it was
         populated in the temp table.
    iv)  Process the record.
    v)   COMMIT. Since we are processing this for a batch of 1000
         from an array, commiting after each record should not cause
         snapshot errors.
    vi)  Update the status to COMPLETE or ERROR once processing
         is done. If ERROR, rollback the changes for that record and
         continue with the next.
    vii) Before fetching the next batch, close and reopen the cursor
         from the temp table (only PENDING records will be fetched).
         This is done to avoid "fetch across commits" (snapshot) problems.

    Note:
    -----
    The whole idea of temp table was thought of because, we don't want
    new eligible records to be picked up everytime we reopened the cursor.
    Hence, we needed to have a mechanism to mark the records from the
    first fetch.

    Since the temp table is a global temp table, it will always get
    refreshed once the session is over.

   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

--
-- bug 7559710.FP to 7388304
-- Commented out this cursor for optimisation
-- pdube
--
/*
cursor eligible_lines_cur is
        select line_id
        from bom_cto_order_lines_temp
        where status = 1
        order by org_id;*/

cursor eligible_lines_cur is
        select bcolt.line_id line_id,
               bcolt.org_id org_id,
               Nvl(Sum(quantity),0) qty
        from bom_cto_order_lines_temp bcolt, po_requisitions_interface_all pria
        where bcolt.status = 1
          and pria.interface_source_line_id(+) = bcolt.line_id
          and pria.process_flag is null
        group by bcolt.org_id, bcolt.line_id
        order by bcolt.org_id;

cursor oe_lines_cur (p_cursor_line_id number) is
	SELECT  oeh.order_number
			,oel.line_id
			,oel.line_type_id
			,oel.org_id
			,oel.inventory_item_id
			,oel.item_revision
			,oel.ordered_quantity
			,oel.cancelled_quantity
			,oel.order_quantity_uom
			,oel.unit_selling_price
			,oel.created_by
			,oel.ship_from_org_id
			,oel.ship_to_org_id
			,oel.schedule_ship_date
			,oel.request_date
			,oel.ordered_quantity2         --opm
			,oel.ordered_quantity_uom2     --opm
			,oel.preferred_grade           --opm
	from    oe_order_lines_all oel,
			oe_order_headers_all oeh
	where	oel.header_id = oeh.header_id
	and		oel.line_id = p_cursor_line_id
	FOR UPDATE OF oel.line_id;

	so_line oe_lines_cur%rowtype;

	--
        -- bug 7559710.FP to 7388304
        -- Commented the code since we would be using the line_id_tab
        -- collection defined below
        -- pdube
        --
        TYPE eligible_lines_rec_tab_typ is table of eligible_lines_cur%rowtype index by binary_integer;
        line_id_tab eligible_lines_rec_tab_typ;
        --TYPE line_id_tab_type is table of oe_order_lines_all.line_id%type;
        --line_id_tab line_id_tab_type;
	c_batch_size			  number := 1000;
	tab_index				  number;

    -- local variables
    p_po_quantity             NUMBER := NULL;
    l_stmt_num                NUMBER;
    p_dummy                   VARCHAR2(2000);
    v_rsv_quantity            NUMBER; -- Bugfix 3652509: Removed precision
    v_sourcing_rule_exists    VARCHAR2(100);
    v_sourcing_org            NUMBER;
    v_source_type             NUMBER;
    v_transit_lead_time       NUMBER;
    v_exp_error_code          NUMBER;
    v_rec_count               NUMBER := 0;
    v_rec_count_noerr         NUMBER := 0;
    conc_status	              BOOLEAN ;
    current_error_code        VARCHAR2(20) := NULL;
    v_x_error_msg_count       NUMBER;
    v_x_hold_result_out       VARCHAR2(1);
    v_x_hold_return_status    VARCHAR2(1);
    v_x_error_msg             VARCHAR2(150);
    x_return_status           VARCHAR2(1);
    l_organization_id         NUMBER;
    p_new_order_quantity      NUMBER; -- Bugfix 3652509: Removed precision
    l_res                     BOOLEAN;
    l_batch_id                NUMBER;
    v_activity_status_code    VARCHAR2(10);
    l_inv_quantity            NUMBER;

    l_request_id         NUMBER;
    l_program_id         NUMBER;
    l_source_document_type_id    NUMBER;

    l_active_activity   VARCHAR2(8);

    -- Bugfix 2931808: New variables
    l_need_by_date	DATE;

     -- bugfix 2978640 : declare new variables
    lOperUnit                NUMBER := -1;
    xUserId                  Number;
    xRespId                  Number;
    xRespApplId              Number;
    x_msg_count              Number;
    x_msg_data               Varchar2(1000);

    -- rkaza. 05/06/2005. ireq project.
    l_req_input_data       req_interface_input_data;
    l_flow_status_code     varchar2(30) := 'EXTERNAL_REQ_REQUESTED';

    v_can_create_supply    varchar2(1);
    v_message              varchar2(100);

    l_rets                 number; --bugfix# 	4545070

-- begin the main procedure.
BEGIN

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('auto_create_pur_req_cr: entered ' ,1);
    END IF;

    -- initialize the program_id and the request_id from the concurrent req
    l_request_id  := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_id  := FND_GLOBAL.CONC_PROGRAM_ID;

    /* bug fix 3590305/3599860 */
    --
    -- load all eligible lines into global temp table. We need to load the
    -- line_id to identify the eligible lines, status is initially set to
    -- 'PENDING'. Org_id is needed for ordering purpose
    -- to preserve fix 2985475. Inventory_item_id is a not null column in this
    -- table but we do not need it in this fix. So setting this field to
    -- constant 0.
    -- status code for temp table
    --		1 - PENDING
    --		2 - COMPLETED
    --		3 - ERROR
    --		4 - INELIGIBLE
    --

    savepoint begin_line;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('auto_create_pur_req_cr: going to load eligible lines into bom_cto_order_lines_temp ' ,1);
    END IF;

    -- load eligible lines into bcolt
    load_lines_into_bcolt(p_sales_order_line_id,
			  p_sales_order,
			  p_organization_id,
			  p_offset_days,
			  x_return_status);

    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
	oe_debug_pub.add ('Failed to load the lines into GTT.');
	raise FND_API.G_EXC_ERROR;
    end if;

    -- set the return status.
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Set the return code to success
    RETCODE := 0;

    lSourceCode := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'l_source_code = '||lsourcecode,1);
    END IF;

    -- set the batch_id to the request_id
    l_batch_id    := FND_GLOBAL.CONC_REQUEST_ID;

    -- Log all the input parameters
    l_stmt_num := 1;

    -- for all the sales order lines (entered, booked )
    -- Given parameters.
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('auto_create_pur_req_cr: ' || '+---------------------------------------------------------------------------+',1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || '+------------------  Parameters passed into the procedure ------------------+',1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Sales order         : '||p_sales_order ,1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Sales Order Line ID : '||to_char(p_sales_order_line_id),1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Organization_id     : '||p_organization_id,1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Offset Days         : '||to_char(p_offset_days),1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Create Req Type         : '|| p_create_req_type,1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || '+---------------------------------------------------------------------------+',1);
    END IF;


    /* bug fix 3590305/3599860 */

    -- Fetch eligible line_id from temp table in batches of 1000 into a PL/SQL
    -- table using cursor eligible_lines
    -- For each line_id read the corresponding row of oeol with lock. Check if
    -- the row is still valid. Insert into the interface table

    LOOP
	open eligible_lines_cur;
	fetch eligible_lines_cur bulk collect into line_id_tab limit c_batch_size;

        IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req_cr: ' || 'records in line_id_tab ' ||to_char(line_id_tab.count),1);
        END IF;
	exit when (line_id_tab.count = 0);

        -- Open loop for processing each eligible line.
        -- Opening the cursor. It selects the eligible oe lines based on the
	tab_index := line_id_tab.first;


        IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req_cr: ' || 'starting tab index ' ||to_char(tab_index),1);
        END IF;

	while tab_index is not null
	LOOP
	  savepoint begin_line;

	  -- Added for bug 7559710.FP to 7388304.pdube
	  IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Details of records in line_id_tab collection',2);

          	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Line Id         : '||line_id_tab(tab_index).line_id,2);

          	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Org Id          : '||line_id_tab(tab_index).org_id,2);

          	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Interface Qty   : '||line_id_tab(tab_index).qty,2);
          END IF;

          OPEN oe_lines_cur (line_id_tab(tab_index).line_id);

	  FETCH oe_lines_cur into so_line;

	  if oe_lines_cur%found then

          -- count of the records selected by the cursor
          v_rec_count := v_rec_count + 1;

          -- Log all the record being processed.
          -- Processing for
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('auto_create_pur_req_cr: ' || '+-------- Processing for --------------------------------------------------+',2);

          	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Sales order         : '||p_sales_order ,2);

          	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Sales Order Line ID : '||to_char(so_line.line_id),2);

          	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Ship from Org       : '||to_char(so_line.ship_from_org_id),2);
          END IF;


          -- get the sourcing type of the item in the specified organization.
          l_stmt_num := 30;

          -- Call the procedure to return the sourcing rule.


	 --replaced query_socuring_org call (change done as part of OPM project)
	 --check_cto_can_creat_supply is a wrapper over query_socuring_org
	 --and custom api CTO_CUSTOM_SUPPLY_CHECK_PK.Check_Supply.
	 --Enhacement for R12 is, concurrent program should not create supply
	 --if custom api returns 'N'

	  CTO_UTILITY_PK.check_cto_can_create_supply (
			P_config_item_id    => so_line.inventory_item_id,
			P_org_id            => so_line.ship_from_org_id,
			x_can_create_supply => v_can_create_supply,--declare
			p_source_type       => v_source_type,
			x_sourcing_org      => v_sourcing_org,
			x_return_status     =>x_return_status,
			X_msg_count	    =>x_Msg_Count,
			X_msg_data          =>x_Msg_Data,

			X_message         =>v_message
			);


        /* begin bug fix 3590305 / 3599860 */

          IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

	     -- rkaza. 05/06/2005. Honoring create req type parameter.
	     -- All the ineligible lines will not be processed further.
             -- A line is ineligible if it is make or multiple sources
	     -- or (IR but parameter is external) or (ext but parameter is
             -- internal). Null value will be treated as ext for bwd cmptblty.
	     -- This parameter should have a null value only for prescheduled
	     -- runs. Otherwise, it is a mandatory program parameter.

	     IF v_can_create_supply = 'N' or
	        --Bugfix 9957935
		--v_source_type in (2, 66) or
		v_source_type = 66 or
		(p_create_req_type = 2 and v_source_type <> 1) or
		((p_create_req_type = 1 or p_create_req_type is null)
		   and v_source_type <> 3) THEN

                   IF PG_DEBUG <> 0 THEN
		     oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Ineligible line for processing.',1);
		     oe_debug_pub.add('auto_create_pur_req_cr: ' || 'v_message.',1);
		     oe_debug_pub.add('auto_create_pur_req_cr: ' || 'v_can_create_supply = ' || v_can_create_supply, 1);
		     oe_debug_pub.add('auto_create_pur_req_cr: ' || 'v_source_type = ' || v_source_type, 1);
		   END IF;

		   RETCODE := 1;
		   rollback to begin_line;
                   update_bcolt_line_status(line_id_tab(tab_index).line_id, 4, x_return_status); --7559710
		   goto loop1;
	     --Bugfix 9957935
	     ELSIF v_source_type = 2 THEN
	        IF PG_DEBUG <> 0 THEN
           	  oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Ineligible line for processing.',1);
		  oe_debug_pub.add('auto_create_pur_req_cr: ' || 'This is not a procured configuration...',1);
                END IF;
		goto loop1;
	     END IF;

	  ELSE
	     IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Error in the sourcing rule. Status = '|| x_return_status,1);
	     END IF;
             RETCODE := 1;
	     rollback to begin_line;
             update_bcolt_line_status(line_id_tab(tab_index).line_id, 3, x_return_status); --7559710
             goto loop1;
          END IF;


           -- Bugfix 3043284: Moved the following check (get_new_order_qty)
           -- here so that hold check is not performed on unnecessary lines
           -- check the quantity to be ordered.

          -- Fix for performance bug 4897231
          -- Passing the new parameter p_item_id

           --
           -- bug 7559710.FP to 7388304
           -- Added the interface qty paramater
           -- pdube
           --
           p_new_order_quantity := get_new_order_qty (
                                        so_line.line_id,
                                        so_line.ordered_quantity,
                                        nvl(so_line.cancelled_quantity, 0),
                                        line_id_tab(tab_index).qty,
					so_line.inventory_item_id);

          IF nvl(p_new_order_quantity, 0) = 0 THEN
              -- Should throw this into log even if debug is off.
              oe_debug_pub.add('auto_create_pur_req_cr: ' || 'The new order quantity is zero. Not eligible for req creation.',1);

              rollback to begin_line;
              update_bcolt_line_status(line_id_tab(tab_index).line_id, 4, x_return_status); --7559710
              goto loop1;

          END IF;


	  /* Start fix 2978640 Set Org context here */

	   /*
          if (lOperUnit <> so_line.org_id ) then
           	IF PG_DEBUG <> 0 THEN
		 oe_debug_pub.add('Setting the Org Context to '||so_line.org_id,1);
		END IF;

                OE_ORDER_CONTEXT_GRP.Set_Created_By_Context (
                                 p_header_id            => NULL
                                ,p_line_id              => so_line.line_id
                                ,x_orig_user_id         => xUserId
                                ,x_orig_resp_id         => xRespId
                                ,x_orig_resp_appl_id    => xRespApplId
                                ,x_return_status        => x_Return_Status
                                ,x_msg_count            => x_Msg_Count
                                ,x_msg_data             => x_Msg_Data );

               IF x_return_status <> FND_API.G_RET_STS_SUCCESS Then
           	  oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Error in the set_created_by_context',1);
                  RETCODE := 1;
	          rollback to begin_line;
	          update_bcolt_line_status(line_id_tab(tab_index), 3, x_return_status);
                  goto loop1;
               END IF;

          end if;
*/
         -- Commenting out the following statement for bug 7706788,FP to 7629806, because the code
         -- sets the same  context for all lines in an org.After commenting, code will call the
         -- context setting for each line and set the org and users correctly.pdube
         -- lOperUnit := so_line.org_id;


          /* Start fix 2978640 Check hold here */

          l_stmt_num := 10;

          -- check for hold on the line.

          /* bugfix 4051282: check for activity hold and generic hold */
          OE_HOLDS_PUB.Check_Holds(p_api_version   => 1.0,
                                   p_line_id       => to_number(so_line.line_id),
                                   p_wf_item       => 'OEOL',
                                   p_wf_activity   => 'CREATE_SUPPLY',
                                   x_result_out    => v_x_hold_result_out,
                                   x_return_status => v_x_hold_return_status,
                                   x_msg_count     => v_x_error_msg_count,
                                   x_msg_data      => v_x_error_msg);

          IF (v_x_hold_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Failed in Check Hold ' || v_x_hold_return_status, 1);
             RETCODE := 1;
	     rollback to begin_line;
             update_bcolt_line_status(line_id_tab(tab_index).line_id, 3, x_return_status); --7559710
             goto loop1;

          ELSE

             IF PG_DEBUG <> 0 THEN
             	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Success in Check Hold ' || v_x_hold_return_status, 1);
             END IF;

             IF (v_x_hold_result_out = FND_API.G_TRUE) THEN

               	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Order Line ID ' || to_char(so_line.line_id )|| 'is on HOLD. ' ||v_x_hold_result_out,1);
                fnd_message.set_name('BOM', 'CTO_ORDER_LINE_ON_HOLD');
                oe_msg_pub.add;

                RETCODE := 1;
                --  If the line is at hold we should not process that record
                --  We should move to the next record.
                --  Fixed by Renga Kannan on 07/09/2002
		rollback to begin_line;   --bug fix 3590305/3599860
                   update_bcolt_line_status(line_id_tab(tab_index).line_id, 4, x_return_status); --7559710
                goto loop1;

             END IF;

          END IF;

	  -- rkaza. 05/06/2005. Introduced this procedure to get need by date
          -- depending on whether the source type is 1 or 3.

          l_stmt_num := 35;

          get_need_by_date(p_source_type => v_source_type,
                           p_item_id => so_line.inventory_item_id,
                           p_org_id => so_line.ship_from_org_id,
                           p_schedule_ship_date => so_line.schedule_ship_date,
                           x_need_by_date => l_need_by_date,
                           x_return_status => x_return_status);

      	  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req_cr: ' || 'success from get_need_by_date' || ' l_need_by_date=' || l_need_by_date, 5);
	    END IF;
     	  elsif x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req_cr: ' || 'expected error in get_need_by_date', 5);
            END IF;
            raise fnd_api.g_exc_error;
     	  elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('auto_create_pur_req_cr: ' || 'unexpected error in get_need_by_date', 5);
            END IF;
            raise fnd_api.g_exc_unexpected_error;
     	  END IF;

	  IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('Need by date: '|| l_need_by_date, 1);
	  ENd IF;

          -- Insert record into the interface table.

          l_stmt_num := 40;

	  -- rkaza. 05/06/2005. Passing source information to populate_req
	  l_req_input_data.source_type := v_source_type;
	  l_req_input_data.sourcing_org := v_sourcing_org;

	  --opm
	  l_req_input_data.secondary_qty  := so_line.ordered_quantity2;
	  l_req_input_data.secondary_uom := so_line.ordered_quantity_uom2;
	  l_req_input_data.grade := so_line.preferred_grade;


          -- Call the insert_req;
          populate_req_interface (
	     'CTO', -- interface source code passed CTO as parameter, kkonada
             so_line.ship_from_org_id,    -- p_destination_org_id
             so_line.org_id,
             so_line.created_by,          -- created_by
             -- bugfix 2931808 change schedule_ship_date to l_need_by_date
             l_need_by_date,  		  -- p_need_by_date
             p_new_order_quantity,
             so_line.order_quantity_uom,  -- p_order_uom
             so_line.inventory_item_id,   -- p_item_id
             so_line.item_revision,
             so_line.line_id,             -- p_interface_source_line_id
             null, -- req-import decides price not so_line.unit_selling_price
             l_batch_id,                  -- batch_id,
             so_line.order_number,
	     l_req_input_data, -- req_interface_input_data
             x_return_status );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             oe_debug_pub.add('auto_create_pur_req_cr: ' || 'populate_req_interface failed with status '|| x_return_status,1);
             RETCODE := 1;
	     rollback to begin_line;
             update_bcolt_line_status(line_id_tab(tab_index).line_id, 3, x_return_status); --7559710
             goto loop1;
          ELSE
              v_rec_count_noerr := v_rec_count_noerr + 1;
              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Insert successful.',1);
              END IF;
          END IF;


          -- update the SO line status if the record is successfully inserted.
          l_stmt_num := 50;

          -- update the Sales Order Line Status for the line id passed into
          -- the procedure. if there is any reservation for this line
          -- Req/PO/Inv. The status will not be changed to PO_REQ_REQUESTED.
          l_inv_quantity := 0;

          -- get the line document_id
          l_source_document_type_id := cto_utility_pk.get_source_document_id ( pLineId => so_line.line_id );

          select sum(nvl(reservation_quantity, 0))
          into   l_inv_quantity
          from   mtl_reservations
          where  demand_source_type_id = decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord, inv_reservation_global.g_source_type_oe )	-- bugfix 1799874
          and    demand_source_line_id = so_line.line_id;

          -- if there is no reservation on the line that meens this line is
          -- created for the first time and the status should be
          -- PO_REQ_REQUESTED.
          IF nvl(l_inv_quantity,0) = 0 THEN


              --bugfix# 4545070
	      l_rets := CTO_WORKFLOW_API_PK.display_wf_status( p_order_line_id=>so_line.line_id);

              IF l_rets = 0 THEN

                 oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Error occurred in display_wf_status  - Stmt_num'||to_char(l_stmt_num),1);

                 RETCODE := 1;
	         rollback to begin_line;
                 update_bcolt_line_status(line_id_tab(tab_index).line_id, 3, x_return_status); --7559710
                 goto loop1;

              ELSE
                 IF PG_DEBUG <> 0 THEN
                 	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Order updated to REQ_REQUESTED.',1);
                 END IF;
              END IF;


              -- the line needs to be updated only if the line is processed
              -- for the first time and there is no reservation (workflow
              -- status is at 'CREATE_SUPPLY_ORDER_ELIGIBLE')
              l_stmt_num := 60;

              -- Added by Renga Kannan on 28-Nov-2001
              -- We need to update the workflow status only if the
              -- status is in CREATE_SUPPLY_ORDER_ELIGIBLE

              CTO_WORKFLOW_API_PK.query_wf_activity_status(
                  'OEOL' ,
                  so_line.line_id ,
                  'CREATE_SUPPLY_ORDER_ELIGIBLE',
                  'CREATE_SUPPLY_ORDER_ELIGIBLE',
                  l_active_activity );

              IF l_active_activity = 'NOTIFIED' THEN

                 l_res := cto_workflow_api_pk.complete_activity(
                              p_itemtype=>'OEOL',
                              p_itemkey =>so_line.line_id,
                              p_activity_name=>'CREATE_SUPPLY_ORDER_ELIGIBLE',
                              p_result_code=>'RESERVED');
               -- (FP 5633040) bugfix 5623360: call with RESERVED instead of COMPLETE.

                 IF NOT l_res THEN

                    oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Error occurred in updating the workflow status - Stmt_num'||to_char(l_stmt_num),1);

                    RETCODE := 1;
	            rollback to begin_line;
                    update_bcolt_line_status(line_id_tab(tab_index).line_id, 3, x_return_status); --7559710
                    goto loop1;

                 END IF;

              END IF;
          END IF; -- end if l_inv_quantity is 0


        <<loop1>>
        null;

	END IF; -- if oe_lines_cur%found

        close oe_lines_cur;	-- Done processing the line. We will reopen cursor with new line_id.

	begin
           update bom_cto_order_lines_temp
           set status = 2      -- set status to completed
           where line_id = line_id_tab(tab_index).line_id --7559710
	   and status = 1;
	   exception
	      when others then
		  null;
	end;

        commit;			-- Commit to release locks.

	tab_index := line_id_tab.next(tab_index);

	end LOOP; -- loop on oe_lines_cur
        -- end of array processing

	line_id_tab.delete;
        close eligible_lines_cur;	-- Close the cursor and reopen it to avoid fetch across commits.

    end loop; -- loop on eligible_lines_cur


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('auto_create_pur_req_cr: ' || '+---------------------------------------------------------------------------+',1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'The Batch ID for this run was : '||to_char(l_batch_id),1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || '+---------------------------------------------------------------------------+',1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Number of records Processed  : '||to_char(v_rec_count),1);

    	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Number of records inserted   : '||to_char(v_rec_count_noerr),1);
    END IF;

    --Bugfix 10235354
    IF PG_DEBUG <> 0 THEN
    declare
       err_line_id number;

       cursor error_lines_cur is
         select bcolt.line_id
	   from bom_cto_order_lines_temp bcolt, po_requisitions_interface_all pria
          where bcolt.status = 1
            and pria.interface_source_line_id(+) = bcolt.line_id
            and pria.process_flag = 'ERROR';
    begin
       open error_lines_cur;

        oe_debug_pub.add('auto_create_pur_req_cr: ' || '+---------------------------------------------------------------------------+',1);
	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'The following lines are stuck in requisition interface table.',1);
	oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Correct the errors, run Requisition Import Exception Report with Delete Exceptions parameter set to Yes and then run CTOACREQ program again to process them',1);


       loop
          fetch error_lines_cur into err_line_id;
	  exit when error_lines_cur%notfound;

	  oe_debug_pub.add('auto_create_pur_req_cr: ' || 'Line Id:' || err_line_id, 1);

       end loop;

       oe_debug_pub.add('auto_create_pur_req_cr: ' || '+---------------------------------------------------------------------------+',1);
    end;
    END IF;
    --Bugfix 10235354

    -- The following part of the code
    -- is modified by Renga Kannan on 11/12/01
    -- In the case of RETCODE = 1 it should complete the batch program with Warning

    IF RETCODE = 1 THEN

       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);

    ELSE

       RETCODE := 0 ;
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);

    END IF;


-- removed pg_debug check since messages need to be printed irrespective
-- of debug level.
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            oe_debug_pub.add('auto_create_pur_req_cr: ' || 'AUTO_CREATE_PUR_REQ_CR::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
	    rollback to begin_line;   --bug fix 3590305/3599860
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETCODE := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            oe_debug_pub.add('auto_create_pur_req_cr: ' || 'AUTO_CREATE_PUR_REQ_CR::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
	    rollback to begin_line;   --bug fix 3590305/3599860
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETCODE := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        WHEN OTHERS THEN
            oe_debug_pub.add('auto_create_pur_req_cr: ' || 'AUTO_CREATE_PUR_REQ_CR::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
	    rollback to begin_line;   --bug fix 3590305/3599860
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            RETCODE := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

END auto_create_pur_req_cr;



-- rkaza. 05/09/2005. Introduced this procedure for ireq project. Called from
-- populate_req_interface.
-- Start of comments
-- API name : get_deliver_to_location_id
-- Type	    : Private
-- Pre-reqs : None.
-- Function : Given org id and source type (1 or 3), it returns
--	      deliver to location id. Used for external and internal reqs
-- Parameters:
-- IN	    : p_org_id           	IN NUMBER	Required
--	      p_source_type		IN NUMBER 	Required
--		 1 or 3 (internal or external reqs)
-- Version  : Current version	115.87
--	         Added this description
--	      Initial version 	115.84
-- End of comments
PROCEDURE get_deliver_to_location_id(
            p_org_id		NUMBER,
            p_source_type       NUMBER,
            x_location_id       OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2  ) IS

    --Bugfix 7162037
    CURSOR delivery_location_cur (l_dest_org_id number) IS
       SELECT location_id
       FROM hr_locations_all loc
       WHERE inventory_organization_id = l_dest_org_id
       AND ship_to_site_flag = 'Y'
       AND EXISTS ( SELECT 1 FROM po_location_associations_all pla
                    WHERE loc.location_id = pla.location_id
                  );

Begin

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- get the location_id from hr_organization_units.

if p_source_type = 1 then

   -- for IR's need to validate against po_line_associations also.
   -- There is a user setup needed for IR. Refer to PO manuals.

   /* Commented as part of bugfix 7162037
   select org.location_id into x_location_id
   from hr_all_organization_units org,
        hr_locations_all loc
   where org.organization_id = p_org_id
   and org.location_id = loc.location_id
   and exists(select 1 from po_location_associations_all pla
           where pla.location_id = loc.location_id); */

   open delivery_location_cur (p_org_id);
   FETCH delivery_location_cur INTO x_location_id;
   CLOSE delivery_location_cur;

   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('populate_req_interface: ' || 'Location ID : '||to_Char(x_location_id),1);
   END IF;

   IF x_location_id IS NULL THEN
      RAISE No_Data_Found;
   END IF;
   --End Bugfix 7162037

elsif p_source_type = 3 then

   -- For ER's validating against hr_locations is enough
   select org.location_id into x_location_id
   from hr_all_organization_units org,
        hr_locations_all loc
   where org.organization_id = p_org_id
   and org.location_id = loc.location_id;

end if;

EXCEPTION

When no_data_found THEN
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_deliver_to_location_id: ' || 'exception No location_id found', 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

when FND_API.G_EXC_ERROR THEN
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_deliver_to_location_id: ' || 'expected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;

when FND_API.G_EXC_UNEXPECTED_ERROR then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_deliver_to_location_id: ' || 'unexpected error: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

when others then
   IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('get_deliver_to_location_id: ' || 'exception others: ' || sqlerrm, 1);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End get_deliver_to_location_id;



-- rkaza. ireq project. 05/06/2005.
-- Added a new parameter of type p_req_interface_input_data record.
-- This is for passing source_type and source_org.

/**************************************************************************
   Procedure:   POPULATE_REQ_INTERFACE
   Parameters:
		p_interface_source_code   VARCHAR2      --interafce source code
		p_destination_org_id		NUMBER   -- PO Destination Org ID
                p_org_id                    NUMBER   --
                p_created_by            	NUMBER   -- Created By for preparor ID
                p_need_by_date              DATE     -- Need by date
                p_order_quantity	        NUMBER   -- Order Quantity
                p_order_uom                 VARCHAR2 -- Order Unit Of Measure
                p_item_id                   NUMBER   -- Inventory Item Id on the SO line.
                p_item_revision             VARCHAR2 -- Item Revisionon the SO Line.
                p_interface_source_line_id	NUMBER   -- Interface Source Line ID
                p_unit_price                NUMBER   -- Unit Price on the SO Line.
                p_batch_id                  NUMBER   -- Batch ID for the Req-Import
                p_order_number              VARCHAR2 -- Sales Order Number.
		p_req_interface_input_data  req_interface_input_data -- a record structure for any other IN parameters
                x_return_status      OUT    VARCHAR2 -- Return Status.

   Description: This procedure is called from the concurrent program
                and the Workflow to create the records in the
                req-interface table based on the line ID passed in to these procedures.
*****************************************************************************/
PROCEDURE populate_req_interface(
	    p_interface_source_code  VARCHAR2,
            p_destination_org_id		NUMBER,
            p_org_id                    NUMBER,
            p_created_by            	NUMBER,
            p_need_by_date              DATE,
            p_order_quantity	        NUMBER,
            p_order_uom                 VARCHAR2,
            p_item_id                   NUMBER,
            p_item_revision             VARCHAR2,
            p_interface_source_line_id	NUMBER,
            p_unit_price                NUMBER,
            p_batch_id                  NUMBER,
            p_order_number              VARCHAR2,
            p_req_interface_input_data  req_interface_input_data,
            x_return_status      OUT NOCOPY   VARCHAR2  ) IS


-- Define global variables.
   l_user_id          NUMBER;
   l_login_id         NUMBER;
   l_request_id       NUMBER;
   l_application_id   NUMBER;
   l_program_id       NUMBER;
   l_resp_id          NUMBER;
   l_org_id           NUMBER;
   l_system_date 	  DATE := SYSDATE;

-- Initialize local variables
   l_intf_source_code      VARCHAR2(20) ;
   l_authorization_status  VARCHAR2(20) := 'APPROVED';
   l_source_type_code      VARCHAR2(20) := 'VENDOR';
   l_dest_type_code        VARCHAR2(10) := 'INVENTORY';

-- define local variables
   l_stmt_num                NUMBER;
   l_location_id             NUMBER;
   p_receiving_account_id    NUMBER;
   p_preparer_id             NUMBER;
   v_rsv_quantity            NUMBER; -- Bugfix 3652509: Removed precision
   v_note_to_buyer           VARCHAR2(240);
   v_note_to_receiver        VARCHAR2(240);

-- 2503104 : declare variable to store user_item_description
   l_user_item_desc	    varchar2(240);

 --dfeault value 'Y' for bugfix 3042904
 --and bugfix 3129117
   l_pegging_flag           VARCHAR2(1) := 'Y'; --bug 3042904

  -- rkaza. 07/16/2004. bug 3771585.
  -- Select material account from mtl_parameters instead of receiving account
  -- from rcv_paramters
  CURSOR charge_account_cur (i_org_id NUMBER ) IS
        SELECT material_account
        FROM   mtl_parameters
        WHERE  organization_id = i_org_id;

  CURSOR emp_id (i_created_by NUMBER) IS
       SELECT  employee_id
       FROM    fnd_user
       WHERE   user_id = i_created_by;

  l_operating_unit   Number;

  l_project_id       oe_order_lines_all.project_id%type;
  l_task_id          oe_order_lines_all.task_id%type;

  --bugfix 4068164
  l_item_revision          VARCHAR2(3) := null;
  l_ato_line_id            NUMBER;

  -- rkaza. 05/09/2005. ireq project.
  l_req_type varchar2(15) := null;
  l_sourcing_org number := null;
  l_auto_source_flag varchar2(2) := null;

  --opm
  l_accrual_account_id number;

BEGIN

   l_stmt_num := 10;

   -- Initialize all the standard variables.
   l_user_id            := FND_GLOBAL.USER_ID;
   l_login_id           := FND_GLOBAL.LOGIN_ID;
   l_request_id         := FND_GLOBAL.CONC_REQUEST_ID;
   l_application_id     := FND_GLOBAL.RESP_APPL_ID;
   l_program_id         := FND_GLOBAL.CONC_PROGRAM_ID;
   l_resp_id            := FND_GLOBAL.RESP_ID;

   l_intf_source_code := p_interface_source_code;

   l_stmt_num := 20;

   -- rkaza. 05/06/2005. Introduced new procedure to deliver_to_location_id
   -- depending on source type.
   get_deliver_to_location_id(p_destination_org_id,
			      p_req_interface_input_data.source_type,
			      l_location_id,
			      x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('populate_req_interface: ' || 'success from get_deliver_to_location_id' || ' l_location_id = ' || l_location_id, 1);
      END IF;
   elsif x_return_status = FND_API.G_RET_STS_ERROR THEN
      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('populate_req_interface: ' || 'expected error in get_deliver_to_location_id', 1);
      END IF;
      raise fnd_api.g_exc_error;
   elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('populate_req_interface: ' || 'unexpected error in get_deliver_to_location_id', 1);
      END IF;
      raise fnd_api.g_exc_unexpected_error;
   END IF;




       -- get the employee id of the preparer based on the created by.
       p_preparer_id := null;

       l_stmt_num := 30;
       FOR e_id in emp_id (p_created_by) LOOP
           p_preparer_id := e_id.employee_id;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_req_interface: ' || 'Preparer ID : '||to_char(p_preparer_id),1);
           END IF;
           exit;
       END LOOP;

       -- (FP 5633329)bugfix 5514977: If p_prepared_id is null, then get the value from profile ONT_EMP_ID_FOR_SS_ORDERS
       ---Profile is obsolete in R12 and it was moved to OE system parameters
       ---we are using the operating unit of order line in order to be consistent with OM dropship code
       IF p_preparer_id is null and p_interface_source_code in ('CTO','CTO-LOWER LEVEL') THEN
           p_preparer_id := oe_sys_parameters.value('ONT_EMP_ID_FOR_SS_ORDERS',p_org_id);

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_req_interface: ' || 'Preparer ID (empIdforSSOrders): '||to_char(p_preparer_id),1);
           END IF;
       END IF;


       -- get the note to buyer from the fnd_new_messages.
       -- bugfix 2701102 : call fnd_message.get_string

       v_note_to_buyer    := substrb (FND_MESSAGE.get_string ('PO', 'CTO_NOTE_TO_BUYER'), 1, 240);
       v_note_to_receiver := substrb (FND_MESSAGE.get_string ('PO', 'CTO_NOTE_TO_RECEIVER'), 1,240);

       /**** begin bugfix 2701102 : call fnd_message.get_string instead of the following

       v_note_to_buyer := null;

       l_stmt_num := 40;
       FOR n_buyer in get_message ('CTO_NOTE_TO_BUYER') LOOP
           v_note_to_buyer := n_buyer.message_text;
           exit;
       END LOOP;

       -- get the note to receiver from the fnd_new_messages.
       v_note_to_receiver := null;

       l_stmt_num := 50;
       FOR n_receiver in get_message ('CTO_NOTE_TO_RECEIVER') LOOP
           v_note_to_receiver := n_receiver.message_text;
           exit;
       END LOOP;

       ******* end bugfix 2701102 */

 -- New fix for 2503104
-- IF p_interface_source_line_id is not null THEN --bugfix 2780392
						--code need not be called for lower level buy config items as
						--no order line information exists and hence
						--interface_source_line_id passed is null

   --bugfix 3129117
   --using p_interface_source code to detremine
   --top most line_id
   IF p_interface_source_code = 'CTO' THEN
 	l_stmt_num := 60;
 	DECLARE
 	   sql_stmt		varchar2(2000);
 	   pflag		varchar2(1) :='Y';
 	   l_chk_col		number;

	   --start bugfix 3871646
           l_result		boolean;
	   l_status             varchar2(60);
           l_industry		varchar2(60);
	   l_customer_schema    varchar2(60);--db length is 30 fnd_oracle_userid.oracle_username
	   --end bugfix 3871646

 	BEGIN

          --start bugfix 3871646
	  --refer to bug for more details
	  l_stmt_num := 70;
	   l_result := FND_INSTALLATION.GET_APP_INFO
	              ( APPLICATION_SHORT_NAME=>'ONT',
		        STATUS =>l_status,
			INDUSTRY=>l_industry,
			ORACLE_SCHEMA =>l_customer_schema);

	 IF (l_result) THEN

	      IF PG_DEBUG <> 0 THEN
 		  oe_debug_pub.add('success after call to FND_INSTALLATION.GET_APP_INFO',1);
		  oe_debug_pub.add('returned custmer schema name for ONT =>'||l_customer_schema,1);
              END IF;
	 ELSE
	     null;
             IF PG_DEBUG <> 0 THEN
	         oe_debug_pub.add('FAILED IN call to FND_INSTALLATION.GET_APP_INFO',1);
	     END IF;

	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	  END IF;

	  --end bugfix 3871646

           l_stmt_num := 80;
 	   select count(*) into l_chk_col
 	   from   all_tab_columns
 	   where  owner 	= l_customer_schema --bugfix 3871646 --'ONT'
 	   and 	  table_name	= 'OE_ORDER_LINES_ALL'
 	   and	  column_name	= 'USER_ITEM_DESCRIPTION';

 	   If l_chk_col > 0 then
 		sql_stmt := 	  'SELECT substrb(oel.user_item_description,1,240)'
 			||' FROM   oe_order_lines_all  oel , mtl_system_items msi'
 			||' WHERE  oel.ship_from_org_id = msi.organization_id'
 			||' AND    oel.inventory_item_id = msi.inventory_item_id'
 			||' AND    oel.line_id = :p_interface_source_line_id'
 			||' AND    msi.organization_id = :p_destination_org_id'
 			||' AND     msi.allow_item_desc_update_flag = :pflag ';

           	IF PG_DEBUG <> 0 THEN
 		  oe_debug_pub.add(sql_stmt,1);
 		  oe_debug_pub.add(p_interface_source_line_id||'-'||p_destination_org_id||'-'||pflag||'-'||
				l_user_item_desc||'-BEFORE EXE IMM',1);
           	END IF;

		l_stmt_num := 90;

 		EXECUTE IMMEDIATE sql_stmt INTO l_user_item_desc
					   USING p_interface_source_line_id,p_destination_org_id,pflag;

           	IF PG_DEBUG <> 0 THEN
 		  oe_debug_pub.add(p_interface_source_line_id||'-'||p_destination_org_id||'-'||pflag||'-'||
				l_user_item_desc||'-AFTER EXE IMM',1);
 		  oe_debug_pub.add('User Item Description is : ' || l_user_item_desc ,1);
           	END IF;
 	else
 		l_user_item_desc := NULL;

           	IF PG_DEBUG <> 0 THEN
 		   oe_debug_pub.add('OE_ORDER_LINES_ALL does not have column USER_ITEM_DESCRIPTION , l_chk_col: ' ||
				to_char(l_chk_col),1);
           	END IF;

 	end if;
 	EXCEPTION
                when NO_DATA_FOUND then		--bugfix 3054055: added no_data_found excepn. Also added debug check above.
 		     l_user_item_desc := NULL;

                when OTHERS then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
 	END;



END IF; --bugfix 2780392

--bugfix 3129117
--moved follwoing slect for
--project_id and task_id out of above if block as the
--information is needed both for top-lvel and lower
--level child configurations
--interface source line id passed is always of top-level
--configuration
l_stmt_num := 100;
 Begin

     Select decode(project_id,-1,NULL,project_id),
            decode(task_id,-1,NULL,task_id)
     into  l_project_id,
            l_task_id
     from   oe_order_lines_all
     where  line_id = p_interface_source_line_id;
 Exception
         WHen no_data_found THEN
	    null;

 End;

 IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('Project _id and task_id are =>' ||l_project_id || 'and' || l_task_id);
 END IF;

--IF p_interface_source_line_id is null THEN --bugfix 3042904

--bugfix 3129117
--checking with interface source code as
--interface source line id passed is always of top-level
--configuration

IF p_interface_source_code = 'CTO-LOWER LEVEL' THEN

   --we insert the project_id and task_id
   --only when pegging_flag  is Y for lower level
   l_pegging_flag := 'N';

   l_stmt_num := 110;
   Begin
    SELECT 'Y'
    into  l_pegging_flag
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = p_item_id
    AND    organization_id = p_destination_org_id
    AND    end_assembly_pegging_flag IN ('I','X');
   Exception
     When no_data_found THEN
	null;

   END;


END IF;    --bugfix 3042904



       -- Added By Renga Kannan on 03/26/02
       -- The receiving org's operating unit is passed as org id
       -- This will restrict the po to be created in the receiving org ou

       Begin
          -- rkaza. 3742393. 08/12/2004.
          -- Repalcing org_organization_definitions with
          -- inv_organization_info_v
          l_stmt_num := 120;
          Select operating_unit
          into   l_operating_unit
          from   inv_organization_info_v
          where  organization_id = p_destination_org_id;
       Exception when others then
          l_operating_unit := null;
       End;

       -- Begin bugfix 4068164: Populate item revision for revision controlled items.
       -- we shall populate this only if the profile INV:Purchasing by Revision is set to Yes (value = 1)

       -- rkaza. 05/10/2005. No need to find item rev for int reqs.
       -- default valuye is null.
       if FND_PROFILE.value('INV_PURCHASING_BY_REVISION') = 1
	  and p_req_interface_input_data.source_type <> 1 then
           l_stmt_num := 130;
           select ato_line_id into l_ato_line_id
           from oe_order_lines_all
           where line_id = p_interface_source_line_id;

           if l_ato_line_id = p_interface_source_line_id then
               Begin

	       l_stmt_num := 140;
               select max(revision) into l_item_revision
                from   mtl_item_revisions mir,
                       mtl_system_items   msi
                where  msi.organization_id = p_destination_org_id
                and    msi.inventory_item_id = p_item_id
                and    mir.organization_id = msi.organization_id
                and    mir.inventory_item_id = msi.inventory_item_id
                and    mir.effectivity_date = (select max(mir1.effectivity_date)
                                               from   mtl_item_revisions mir1
                                               where  mir1.organization_id = msi.organization_id
                                               and    mir1.inventory_item_id = msi.inventory_item_id
                                               and    mir1.effectivity_date <= sysdate )
                and    msi.revision_qty_control_code = 2  --revision controlled items only
                and    msi.base_item_id is null  -- not preconfig or config
                and    msi.bom_item_type = 4; --standard item

               Exception when others then
                  IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Revision not populated because '||SQLERRM);
                  END IF;
               End;
           end if;

           IF PG_DEBUG <> 0 THEN
               oe_debug_pub.add('Item Revision is ' ||l_item_revision);
           END IF;
       else
           If PG_DEBUG <> 0 Then
	      oe_debug_pub.add('Popluate_req_interface: Inv Purchase by Revision is set to No or Source type is IR',1);
	   End if;
       end if;
       -- End bugfix 4068164


   -- rkaza. 05/10/2005. ireq project. source_type_code is VENDOR for ext reqs
   -- and INVENTORY for int reqs. by default it is VENDOR.
   -- Req type is null for ext reqs (default) and 'INTERNAL' for int reqs.
   -- default is null for auto source flag and sourcing org.

   if p_req_interface_input_data.source_type = 1 then
      l_source_type_code := 'INVENTORY';
      l_req_type := 'INTERNAL';
      l_sourcing_org := p_req_interface_input_data.sourcing_org;
      l_auto_source_flag := 'P';
   end if;



     -- get the receiving account ID for the given receiving Organization ID
       p_receiving_account_id := null;

    --For process org call OPM api to get charge_account_id and accrual_accountid as per SLA architecure
    --for organization other than process organization get charge_account_id as before; accrual info not reqd
    --OPM
  IF NOT INV_GMI_RSV_BRANCH.Process_Branch (p_organization_id => p_destination_org_id) THEN

       -- Modified the paramter to the cursor to pass the shipping org id instead of operatinng unit.
       -- this is fixed as part of the bug 2188205

       l_stmt_num := 150;
       FOR ch_act IN charge_account_cur (p_destination_org_id) LOOP
  	   -- rkaza. 07/16/2004. bug 3771585.
  	   -- Select material account from mtl_parameters instead of receiving
	   -- account from rcv_paramters
           -- p_receiving_account_id := ch_act.receiving_account_id;
           p_receiving_account_id := ch_act.material_account;
           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('populate_req_interface: ' || 'Charge Account ID : '||to_char(p_receiving_account_id),1);
           END IF;
           exit;
       END LOOP;


    ELSE
        --OPM
	l_stmt_num := 160;
        Get_opm_charge_account( p_interface_source_line_id       =>p_interface_source_line_id
	                       ,p_item_id            =>p_item_id
			       ,p_destination_org_id =>p_destination_org_id
			       ,p_source_type_code   =>l_source_type_code
			       ,p_operating_unit     =>l_operating_unit
			       ,x_charge_account_id  =>p_receiving_account_id
			       ,x_accrual_account_id =>l_accrual_account_id
			       ,x_return_status      =>x_return_status);
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

          IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('populate_req_interface: ' || 'OPMCharge Account ID : '||to_char(p_receiving_account_id),1);
            oe_debug_pub.add('populate_req_interface: ' || 'OPMCharge Account ID : '||to_char(l_accrual_account_id),1);
          END IF;
        ELSE
           IF PG_DEBUG <> 0 THEN
            oe_debug_pub.add('populate_req_interface: ' || 'Get_opm_charge_account RET STATUS : '||x_return_status,1);
	   END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;



    END IF;


-- insert into the interface table.
                  l_stmt_num := 20;
                  -- Insert the record in the interface table
                  BEGIN
		  -- rkaza. 05/10/2005. Inserting new parameters...
		  -- requisition_type, sourcing_org, auto_source_flag

		  --OPM project, inserting parameters secondary qty,
		  --secondary uom and grade

		  --bugfix 4545559 changed the insert from
		  --po_requisitions_interface to _all table
		  l_stmt_num := 210;
                  INSERT INTO po_requisitions_interface_all (
                         interface_source_code,
                         destination_organization_id,
                         deliver_to_location_id,
                         deliver_to_requestor_id,
                         need_by_date,
                         last_updated_by,
                         last_update_date,
                         last_update_login,
                         creation_date,
                         created_by,
                         destination_type_code,
                         quantity,
                         uom_code,
                         authorization_status,
                         preparer_id,
                         item_id,
                         item_revision,
                         batch_id,
                         charge_account_id,
                         interface_source_line_id,
                         source_type_code,
			 source_organization_id,
                         unit_price,
                         note_to_buyer,
                         note_to_receiver,
		         org_id,
		         item_Description, -- 2503104 : Insert user_item_description
                         project_id,
                         task_id,
                         project_accounting_context,
			 requisition_type,
			 autosource_flag,
			 secondary_quantity,          --opm case and also for buy in discrete orgs
                         secondary_uom_code,      --opm and also for buy in discrete orgs
			 preferred_grade,             --opm and also for buy in discrete orgs
			 accrual_account_id       --opm
			 )
                   VALUES (
                         l_intf_source_code,
                         p_destination_org_id, -- ship_from_org_id
                         l_location_id,
                         p_preparer_id, --p_deliver_to_requestor_id/employee_id
                         p_need_by_date,
                         l_user_id,
                         l_system_date,
                         l_login_id,
                         l_system_date,
                         p_created_by,
                         l_dest_type_code,
                         p_order_quantity,
                         p_order_uom,
                         l_authorization_status,
                         p_preparer_id,
                         p_item_id,
                         l_item_revision,
                         p_batch_id,
                         p_receiving_account_id,
			 decode(p_interface_source_code,'CTO',p_interface_source_line_id,null), -- bugfix 3129117
                         l_source_type_code,
			 l_sourcing_org,
                         p_unit_price,
                         'Supply for the Sales Order :'||p_order_number||', '||v_note_to_buyer,
                         'Supply for the Sales Order :'||p_order_number||', '||v_note_to_receiver,  --Bugfix 8742325
			 --v_note_to_receiver,
			 l_operating_unit,
			 l_user_item_desc, -- 2503104 : user_item_description
			 decode(l_pegging_flag,'Y',l_project_id,null), -- bug 3129117
                         decode(l_pegging_flag,'Y',l_task_id,null), -- bug 3129117
                         decode(l_project_id,-1,null,null,null,'Y'),
			 l_req_type,
			 l_auto_source_flag,
			 p_req_interface_input_data.secondary_qty,
			 p_req_interface_input_data.secondary_uom,
			 p_req_interface_input_data.grade,
			 l_accrual_account_id
			 );

                  EXCEPTION
                  WHEN OTHERS THEN
                       IF PG_DEBUG <> 0 THEN
                       	oe_debug_pub.add('populate_req_interface: ' ||
                              'insert into the req interface table failed interface_source_line_id'||
                                          to_char(p_interface_source_line_id),1);

                       	oe_debug_pub.add('populate_req_interface: ' || 'POPULATE_REQ_INTERFACE::exp error:: In the insert statment::'||
                                                    to_char(l_stmt_num)||'::'||sqlerrm,1);
                       END IF;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END;


EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('populate_req_interface: ' || 'POPULATE_REQ_INTERFACE::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('populate_req_interface: ' || 'POPULATE_REQ_INTERFACE::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        WHEN OTHERS THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('populate_req_interface: ' || 'POPULATE_REQ_INTERFACE::other error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            END IF;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END populate_req_interface;






/**************************************************************************
   Function     : GET_RESERVED_QTY
   Parameters   : p_line_id  NUMBER
   Return Value : Number
   Description  : This procedure is called from the concurrent program to
                  get the the reserved quantity on the sales Order line.
*****************************************************************************/
FUNCTION get_reserved_qty (
            p_line_id                 NUMBER) RETURN NUMBER IS

    -- Define local parameters
    v_rsv_quantity    NUMBER;
    l_stmt_num        NUMBER;

BEGIN
       l_stmt_num := 10;

       -- select the reservation quantities from the reservations tables.
       SELECT  nvl(SUM(reservation_quantity), 0)
       INTO	   v_rsv_quantity
       FROM    mtl_reservations
       WHERE   demand_source_line_id = p_line_id;

       Return (v_rsv_quantity);
EXCEPTION
  WHEN OTHERS THEN
      IF PG_DEBUG <> 0 THEN
      	oe_debug_pub.add('get_reserved_qty: ' || 'GET_RESERVED_QTY::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
      END IF;
      Return (0);
END;  -- get_reserved_qty








/**************************************************************************
   Function     : GET_NEW_ORDER_QTY
   Parameters   : p_interface_source_line_id   NUMBER -- Sales Order Linae ID.
                  p_order_qty                  NUMBER -- Sales Order Order_quantity.
                  p_cancelled_qty              NUMBER -- Sales Order Cancelled_quantity.
                  p_interface_qty              NUMBER DEFAULT NULL
                                                      -- PO Req Interface Qty
   Return Value : Number
   Description  : This procedure is called from the concurrent program to
                  get the the quantity to be reserved for the demand.
*****************************************************************************/
-- Fix for performance bug 4897231
-- To avoid full table scan on po_requisitions_table
-- we need add another where condition for item_id in po_requisitions_interface_all table
-- As most of the calling modules for this API already has item_id,
-- we add a new parameter p_item_id for this procedure
-- This parameter will be used in the where clause of po_requisition_intface table

FUNCTION get_new_order_qty (
                    p_interface_source_line_id   NUMBER,
                    p_order_qty                  NUMBER,
                    p_cancelled_qty              NUMBER,
                    p_interface_qty              NUMBER, --7559710
		    p_item_id                    NUMBER)
        RETURN NUMBER AS

    -- initialize all the local parameters.
    p_po_quantity    NUMBER; -- Bugfix 3652509: Removed precision
    l_stmt_num       NUMBER;
    v_rsv_quantity   number := 0; -- Bugfix 3652509: Removed precision

-- Fix for performance bug 4897231
-- To avoid full table scan on po_requisitions_table
-- added another where condition for item_id
-- Po_req_interface table has index on item_id column

   CURSOR c1(p_line_id NUMBER,p_inv_item_id number) IS
       SELECT Nvl(Sum(quantity),0) qty
       FROM   po_requisitions_interface_all
       WHERE  interface_source_line_id = p_line_id
       and    item_id    = p_inv_item_id
       AND    process_flag is null;

   CURSOR c2(p_line_id NUMBER) IS
       SELECT  nvl(SUM(reservation_quantity), 0) qty
       FROM    mtl_reservations
       WHERE   demand_source_line_id = p_interface_source_line_id;

   l_quantity_interface   po_requisitions_interface_all.quantity%TYPE;
   l_open_flow_qty        Number := 0;

BEGIN

-- get all the details of the quantity to be ordered.
      l_stmt_num := 20;

      v_rsv_quantity := 0;
      FOR a2 in c2 (p_interface_source_line_id) loop
         v_rsv_quantity := a2.qty;
         EXIT;
      END LOOP;

      l_quantity_interface := 0;

      --
      -- bug 7559710.FP to 7388304
      -- open the cursor only if the interface qty is not passed
      -- pdube
      --
      IF p_interface_qty IS NULL THEN
         FOR a1 in c1( p_interface_source_line_id,p_item_id) loop
           l_quantity_interface := a1.qty;
           EXIT;
         END LOOP;
      ELSE
         l_quantity_interface := p_interface_qty;
      END IF;

      l_open_flow_qty :=
		MRP_FLOW_SCHEDULE_UTIL.GET_FLOW_QUANTITY( p_demand_source_line     => to_char(p_interface_source_line_id),
							  p_demand_source_type     => inv_reservation_global.g_source_type_oe,
							  p_demand_source_delivery => NULL,
							  p_use_open_quantity      => 'Y');


       -- Caluculate the Actual Order Quantity from the
       -- sales order qty and the reservation qty.
       p_po_quantity := nvl(p_order_qty,0) - nvl(v_rsv_quantity,0) - nvl(l_quantity_interface,0)-nvl(l_open_flow_qty,0);

-- Log the quantities.
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add('get_new_order_qty: ' || 'The Order quantity             : '||to_char(nvl(p_order_qty,0)),1);

       	oe_debug_pub.add('get_new_order_qty: ' || 'The Cancelled quantity         : '||to_char(nvl(p_cancelled_qty,0)),1);

       	oe_debug_pub.add('get_new_order_qty: ' || 'The reservation quantity       : '||to_char(nvl(v_rsv_quantity,0)),1);

       	oe_debug_pub.add('get_new_order_qty: ' || 'The interfaced quantity        : '||to_char(nvl(l_quantity_interface,0)),1);

       	oe_debug_pub.add('get_new_order_qty: ' || 'The new Order quantity will be : '||to_char(nvl(p_po_quantity,0)),1);

        oe_debug_pub.add('get_new_order_qty:'||'flow open quantity =>' || to_char(nvl(l_open_flow_qty,0)), 1);
       END IF;

RETURN nvl(p_po_quantity, 0);

END get_new_order_qty;  -- get_new_order_qty





PROCEDURE check_order_line_status (
               p_line_id                   NUMBER,
               p_flow_status    OUT NOCOPY VARCHAR2,
               p_inv_qty        OUT NOCOPY NUMBER,
               p_po_qty         OUT NOCOPY NUMBER,
               p_req_qty        OUT NOCOPY NUMBER) as

    cursor get_so_line (
           p_line_id   NUMBER) is
    select line_id,
           ordered_quantity,
	   inventory_item_id
    from   oe_order_lines_all
    where  line_id = p_line_id;

    -- define the local parameters
    l_inv_qty                   NUMBER;
    l_po_qty                    NUMBER;
    l_req_qty                   NUMBER;
    l_source_document_type_id   NUMBER;

BEGIN
    -- get the document ID from
    l_source_document_type_id := CTO_UTILITY_PK.get_source_document_id ( p_line_id );

    -- get all the lines from the so_lines
    -- for the line_id passed into the cursor
    FOR so_line in get_so_line ( p_line_id ) LOOP

        l_inv_qty := 0;
        select nvl(sum(reservation_quantity), 0)
        into   l_inv_qty
        from   mtl_reservations
        where  demand_source_type_id = decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
      					 inv_reservation_global.g_source_type_oe )
        and    demand_source_line_id = so_line.line_id
        and    supply_source_type_id = inv_reservation_global.g_source_type_inv;

        l_po_qty := 0;
        select nvl(sum(reservation_quantity), 0)
        into   l_po_qty
        from   mtl_reservations
        where  demand_source_type_id = decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
      					 inv_reservation_global.g_source_type_oe )
        and    demand_source_line_id = so_line.line_id
        and    supply_source_type_id = inv_reservation_global.g_source_type_po;

        l_req_qty := 0;
        select nvl(sum(reservation_quantity), 0)
        into   l_req_qty
        from   mtl_reservations
        where  demand_source_type_id = decode (l_source_document_type_id, 10, inv_reservation_global.g_source_type_internal_ord,
      					 inv_reservation_global.g_source_type_oe )
        and    demand_source_line_id = so_line.line_id
        and    supply_source_type_id = inv_reservation_global.g_source_type_req;

    -- Check the order_quantity and the inv_rsv_qty to 'PO_RECEIVED'
    IF so_line.ordered_quantity = nvl(l_inv_qty,0)
      AND nvl(so_line.ordered_quantity, 0) > 0 THEN
        p_flow_status := 'PO_RECEIVED';
    elsif nvl(l_inv_qty, 0) > 0 THEN
        p_flow_status := 'PO_PARTIAL';
    elsif nvl(l_inv_qty, 0) = 0 THEN
        -- when there is no reservation on inv then
        IF nvl(l_po_qty, 0) > 0 THEN
            p_flow_status := 'PO_CREATED';
        elsif nvl(l_req_qty, 0) > 0 THEN
            p_flow_status := 'PO_REQ_CREATED';
        ELSE
        -- when there is no reservation at all then the order can be in Booked or req-erquested state
-- Fix for performance bug 4897231
-- To avoid full table scan on po_requisitions_table
-- added another where condition for item_id
-- Po_req_interface table has index on item_id column

           BEGIN
             select   'EXTERNAL_REQ_REQUESTED'
             into     p_flow_status
             from     po_requisitions_interface_all
             where    interface_source_line_id = so_line.line_id
	     and      item_id = so_line.inventory_item_id
             and      process_flag is null
	     and      rownum =1;
           EXCEPTION
             WHEN OTHERS THEN
                 p_flow_status := 'ERROR';
           END;
         END IF;
      END IF;

   END LOOP;

END check_order_line_status;




-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

--   Starting of Purchase price rollup and document creation moudle
--   Create by Renga Kannan on 03/23/01

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------



--  Modified the code to rollup the price based on po validation org
--  instead of receiving org
--  this is decided by Product management and Development team
/************************************************************************************************************************

            This is the main API which will get called by both online and batch program
	    This will rollup the list price for the Buy configurations, from the components selected in
	    the order. The list price will be taken from Po Validation org. If the component/Model is not
            Defined in the Po validation org, the price will be taken as 0. The rolled up price of the configuration
	    will be update in Mtl_system_items in po validation org. Apart from Rolling up list price, This procedure
            will also Rollup the blanket price from the model blanket and create a new blanket and ASL entries for
            configuration items.

            Parameter explanations

		P_top_model_line_id      --  Top ATO model's line id

	        P_overwrite_list_price   --  It can have 'Y'/'N' value. The default value is 'N'.
					     If this parameter is passed as 'N' the list price of the
					     configuration will not be overwritten in Po validation org.
					     Only if the list_price_per_unit is null in po validation org
			                     the rolled up price will be updated.
					     If this parameter is passed as 'Y', this API will update the
			                     mtl_system_items anyway

		P_Called_in_batch        --  When the purchase price rollup is done for more than one order
					     this parameter should be set to 'Y'. If this is done online for a
				             Single order then it should be 'N'. The default value for this is 'N'.
			                     If this paramter is 'N', the PDOI concurrent program will be
					     Launched by this API. If it is passed as 'Y' this API will not
					     Launch the PDOI concurrent program. The calling module will lauch in that
					     case. IN both cased the records are inserted to PDOI interface tables by
					     This api only.

		p_batch_number            -- The default value is null for this. If p_called_in_batch parameter is 'Y'
 					     then the calling application should pass this value. This batch number is
					     used to populate in PDOI interface tables. If the case on online this API
					     will generate the batch id thru sequence.

		X_oper_unit_list          -- This is a out parameter. This is a table of records. This contains all the
					     Operating units processed by this API. In the case of on line call this output
					     parameter will not be used by the calling application. The batch calling program
					     will get this out parameter and uses this to launch the PDOI interface concurrent
					     Program. The batch calling program will loop thru this table and launch the
					     concurrent program that many times. While lauching the concurrent program it will
					     also set the org context to the operating unit specified in this table



*************************************************************************************************************************/

Procedure  Create_Purchasing_Doc(
                                p_config_item_id       IN            Number,
				p_overwrite_list_price IN            Varchar2 default 'N',
				p_called_in_batch      IN            Varchar2 default 'N',
				p_batch_number         IN OUT NOCOPY Number,
				p_mode                 IN            Varchar2 Default 'ORDER',
				p_ato_line_id          IN            Number   default null,
				x_oper_unit_list       IN OUT NOCOPY cto_auto_procure_pk.oper_unit_tbl,
                                x_return_status        OUT    NOCOPY Varchar2,
                                x_msg_count            OUT    NOCOPY Number,
                                x_msg_data             OUT    NOCOPY Varchar)  is

	lStmtNumber	 Number;
        x_rolled_price   Number := 0;
	i		 Number;
	l_batch_id       Number;
	l_request_id     Number;
        l_model_item_id  Number;
	l_line_id        Number;

        Type orgs_list_type is table of number;
        l_orgs_list   orgs_list_type;
        /* Get the cursor to get the config items to be rolled up */
        x_group_id number;

        Cursor buy_configs is
        select component_item_id,
               line_id
        from   bom_explosion_temp
        where  group_id = x_group_id
        and    configurator_flag = 'Y'
        order by plan_level desc;	 /* Check With Sajani */

        l_comp_exists   Varchar2(1);

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	lStmtNumber     := 10;
        g_pg_level := 3;
        IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(lpad(' ',g_pg_level)||'                                                                  ',1);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'Create_Purchasing_Doc: '
                               || '******************************',1);

           oe_debug_pub.add('Create_Purchasing_Doc: '
                               || '      CREATING PURCHASING DOCUMENT  ',1);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_PURCHASING_DOC: START TIME '||to_char(sysdate,'hh:mi:ss'),1);

           oe_debug_pub.add(lpad(' ',g_pg_level)||'Create_Purchasing_Doc: '
                               || '******************************',1);
           oe_debug_pub.add(lpad(' ',g_pg_level)||' ',1);
        END IF;

        IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add(lpad(' ',g_pg_level)||'Create_Purchasing_Doc: ' || 'IN batch id = '||to_char(p_batch_number),1);
          oe_debug_pub.add(lpad(' ',g_pg_level)||'Create_Purchasing_Doc: '||'Mode = '||p_mode,1);
        END IF;
        lStmtNumber := 20;
        If Pg_Debug <> 0 Then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'Create Purchasing Doc: Before calling get_config_details',5);
        End if;


        l_Comp_exists := 'N';

        CTO_TRANSFER_PRICE_PK.Get_Config_details(p_item_id       => p_config_item_id,
                                                 p_mode_id       => 3,
						 p_line_id       => p_ato_line_id,
                                                 x_group_id      => x_group_id,
                                                 x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data);

        lStmtNumber := 30;
        For buy_configs_rec in buy_configs
        Loop

           l_comp_exists := 'Y';
           if PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_PURCHASING_DOC: Processing config item = '
                                                   ||buy_configs_rec.component_item_id,5);
           End if;
           lStmtNumber := 40;

           process_purchase_price(
	                          p_config_item_id       => buy_configs_rec.component_item_id,
				  p_group_id             => x_group_id,
				  p_batch_number         => p_batch_number,
				  p_overwrite_list_price => p_overwrite_list_price,
				  p_line_id              => buy_configs_rec.line_id,
				  p_mode                 => p_mode,
				  x_oper_unit_list       => x_oper_unit_list,
				  x_return_status        => x_return_status,
				  x_msg_count            => x_msg_count,
				  x_msg_data             => x_msg_data);

        End Loop;



	/* Make a call to to purchase process for the top configuration */

        lStmtNumber := 50;
        Begin
	   select line_id
	   into   l_line_id
	   from   bom_explosion_temp
	   where  group_id = x_group_id
	   and    assembly_item_id  = p_config_item_id
	   and    component_item_id = (select base_item_id
	                               from   mtl_system_items
	   			       where  inventory_item_id = p_config_item_id
				       and    rownum =1);
           l_comp_exists := 'Y';
        Exception When no_data_found then
           l_comp_exists := 'N';
        End;
        If PG_DEBUG <> 0 Then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_PURCHASING_DOC: Processing config item = '
                                                   ||p_config_item_id,5);
        End if;
        lStmtNumber := 60;

        If l_comp_exists = 'Y' then
        Process_Purchase_Price(
	                       p_config_item_id       => p_config_item_id,
			       p_group_id             => x_group_id,
			       p_batch_number         => p_batch_number,
			       p_overwrite_list_price => p_overwrite_list_price,
			       p_line_id              => l_line_id,
			       p_mode                 => p_mode,
			       x_oper_unit_list       => x_oper_unit_list,
			       x_return_status        => x_return_status,
			       x_msg_count            => x_msg_count,
			       x_msg_data             => x_msg_data);

	-- For each Buy/Drop ship model's  call the
        -- List price rollup API
	-- We will call purchae_price_roll up also for each buy Model

        lStmtNumber := 70;
	if p_called_in_batch = 'N' then

		-- Call this API to launch the concurrent program
		-- This API will lauch one PDOI concurrent program per operating unit
		-- This will lauch the error report concurrent program also

		lStmtNumber     := 80;

                If PG_DEBUG <> 0 Then
                   oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_PURCHASING_DOC: Before calling Submit Pdoi',5);
                End if;

		Submit_pdoi_conc_prog(
                                p_oper_unit_list     =>  x_oper_unit_list,
                                p_batch_id           =>  p_batch_number,
                                x_return_status      =>  x_return_status,
                                x_msg_count          =>  x_msg_count,
                                x_msg_data           =>  x_msg_data);


	end if;

        end if; /* l_comp_exits = 'Y' */

	IF PG_DEBUG <> 0 THEN
	oe_debug_pub.add(lpad(' ',g_pg_level)||'Create_Purchasing_Doc: '
                                             || '****************************',1);

	oe_debug_pub.add(lpad(' ',g_pg_level)||'Create_Purchasing_Doc: ' || '      END CREATE PURCHASING DOC                  ',1);
        oe_debug_pub.add(lpad(' ',g_pg_level)||'CREATE_PUCHASING_DOC: '||  '      END TIME : '||to_char(sysdate,'hh:mi:ss'),1);

        oe_debug_pub.add(lpad(' ',g_pg_level)||'Create_Purchasing_Doc: '
                                             || '****************************',1);
        END IF;
        g_pg_level := g_pg_level - 3;

exception

        when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Create_Purchasing_Doc: ' || 'Create_purchasing_doc::unexp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );

        when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Create_Purchasing_Doc: ' || 'Create_purchasing_doc::exp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data);

        when others then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Create_Purchasing_Doc: ' || 'Create_purchasing_doc::others::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );

end create_purchasing_doc;




/***********************************************************************************************************


	This API will rollup the list price for a given buy model from its components. If the component
	is not defined in the org the price will be defaulted to zero.


	Parameter Description:

		P_line_id		--  Buy Model's line id

		p_org_id                --  The organization to rollup the purchase price.

		x_rolled_price          --  The rolled pice will be returned to the calling api.

		x_buy_comps		--  This API also returns all the componenets processed for the buy model.
					    This will be returned as table of records. This out variable will
					    be used later for purchase price rollup for performance reason.



************************************************************************************************************/



Procedure  Rollup_list_price (
                p_config_item_id  in         Number,
                p_group_id        in         Number,
                p_org_id          in         Number,
                x_rolled_price    out NOCOPY Number,
                x_return_status   out NOCOPY varchar2,
                x_msg_count       out NOCOPY number,
                x_msg_data        out NOCOPY varchar2) is

	lStmtNumber	     Number;


	-- Cursor to get all the components of the buy model

        Cursor Purchase_comp is
        Select   exp.component_quantity comp_qty,
                 exp.primary_uom_code   uom_code,
                 exp.component_item_id  comp_item_id,
                 msi.primary_uom_code   prim_uom_code,
                 nvl(msi.list_price_per_unit,0) list_price_per_unit
        from     bom_explosion_temp exp,
                 mtl_system_items   msi
        where    exp.group_id   = p_group_id
        and      exp.assembly_item_id  = p_config_item_id
        and      exp.component_item_id = msi.inventory_item_id
        and      msi.organization_id   = p_org_id;

        Cursor child_configs_cur is
        Select exp.component_item_id comp_item_id,
               exp.component_quantity comp_qty
        from   bom_explosion_temp exp
        where  exp.group_id = p_group_id
        and    exp.assembly_item_id  = p_config_item_id
        and    exp.configurator_flag = 'Y'
        and    not exists (select 'X'
                           from   mtl_system_items msi
                           where msi.inventory_item_id = exp.component_item_id
                           and   msi.organization_id   = p_org_id);

        l_model_qty          Number;
	l_model_order_uom    Bom_cto_order_lines.order_quantity_uom%type;
        l_inventory_item_id  Bom_cto_order_lines.inventory_item_id%type;
        l_ato_line_id        bom_cto_order_lines.ato_line_id%type;
	l_prim_qty	     Number;
	l_price_per_unit     Number;
	l_model_prim_uom     Bom_cto_order_lines.order_quantity_uom%type;
        l_ratio              Number;
	l_price              Number;
        l_prim_uom_qty       Number;
	i	             Number := 0;
        l_rolled_price       Number;
begin

        g_pg_level := g_pg_level + 3;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	lStmtNumber := 10;

	x_rolled_price := 0;
        If PG_DEBUG <> 0 Then
          oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: Inside Rollup List price API',5);
          oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLIP_LIST_PRICE: Rollup for config item = '||p_config_item_id,5);
          oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: PO Validation Org id   = '||p_org_id,5);
        End if;

        lStmtNumber := 20;
  	For pur_comp in purchase_comp
   	Loop

	   IF PG_DEBUG <> 0 THEN
 	      oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: ' || 'Component item id  = '
                                                     ||to_char(pur_comp.comp_item_id),2);
              oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: List price per unit = '||pur_comp.list_price_per_unit,5);
	   END IF;

     	   lStmtNumber := 30;

           -- Added the price by converting the correct UOM

	   if nvl( pur_comp.list_price_per_unit,0) <> 0 then

              lStmtNumber := 40;
              l_prim_uom_qty  := CTO_UTILITY_PK.convert_uom(
                                        from_uom  => pur_comp.uom_code,
                                        to_uom    => pur_comp.prim_uom_code,
                                        quantity  => pur_comp.comp_qty,
                                        item_id   => pur_comp.comp_item_id);
              l_price          := l_prim_uom_qty * pur_comp.list_price_per_unit;
              If PG_DEBUG <> 0 Then
                 oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: Primary UOM quantity = '||l_prim_uom_qty,5);
                 oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: List price for order qty = '||l_price,5);
              End if;
              x_rolled_price   := x_rolled_price + l_price;
	   else
              IF PG_DEBUG <> 0 THEN
	         oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: List price is defined as 0',5);
              END IF;

           end if;

           lStmtNumber := 50;
           If PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)
                               ||'ROLLUP_LIST_PRICE : Get child configs rollup price, which are not enabled in this org',5);
           end if;

           For child_configs in child_configs_cur
           Loop
              If PG_DEBUG <> 0 Then
                 oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: Processing Child config = '
                                                      ||child_configs.comp_item_id,5);
              End if;
              lStmtNumber := 60;
              Rollup_list_price (
                               p_config_item_id => child_configs.comp_item_id,
                               p_group_id       => p_group_id,
                               p_org_id         => p_org_id,
                               x_rolled_price   => l_rolled_price,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data);

              lStmtNumber := 70;
              x_rolled_price := x_rolled_price + l_rolled_price*child_configs.comp_qty; /* Renga need to add qty */
              IF PG_DEBUG <> 0 Then
                oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: Configs rolled up price = '||l_rolled_price,5);
              End if;
           End Loop;
    	End Loop;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: ' ||' Rolled up organization = '||to_char(p_org_id),2);
		oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_LIST_PRICE: ' ||' Rolled up price        = '
                                                                             ||to_char(x_rolled_price),2);
	END IF;
        g_pg_level := g_pg_level - 3;
exception

        when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Rollup_list_price: ' || 'Rollup_list_price::unexp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );
                g_pg_level := g_pg_level - 3;

        when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Rollup_list_price: ' || 'Rollup_list_price::exp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data);
                g_pg_level := g_pg_level - 3;

        when others then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Rollup_list_price: ' || 'Rollup_list_price::others::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );
                g_pg_level := g_pg_level - 3;

END  Rollup_list_price;




--- This procedure will do the rollup based on purchasing documents
--- for all buy configurations

/*********************************************************************************************************************

 		This API will rollup the purchasing price based on model ASL. It will
		also insert records into PDOI tables to create necessary purchasing documents
		for configurations item.


***********************************************************************************************************************/


Procedure  Rollup_purchase_price (
		p_config_item_id in             Number,
		p_batch_id       in out NOCOPY  Number,
                p_group_id       in             Number,
		p_mode           IN             Varchar2 Default 'ORDER',
		p_line_id        in             number,
		x_oper_unit_list in out NOCOPY  cto_auto_procure_pk.oper_unit_tbl,
                x_return_status  out    NOCOPY  varchar2,
                x_msg_count      out    NOCOPY  number,
                x_msg_data       out    NOCOPY  varchar2) is

	lStmtNumber	     Number;
	x_model_vendors      PO_AUTOSOURCE_SV.vendor_record_details;
	x_config_vendors     PO_AUTOSOURCE_SV.vendor_record_details;
	l_model_vendors      PO_AUTOSOURCE_SV.vendor_record_details;
	l_doc_header_id      Number;
	l_doc_type_code	     Varchar2(20);
	l_doc_line_num       Number;
	l_doc_line_id        Number;
	l_vendor_contact_id  Number;
	-- 4283726 l_vendor_product_num Varchar2(50);
	l_vendor_product_num po_approved_supplier_list.primary_vendor_item%type;       -- 4283726
	l_buyer_id	     Number;
	-- 4283726 l_purchase_uom       Varchar2(10);
	l_purchase_uom       po_asl_attributes.purchasing_unit_of_measure%type;        -- 4283726
	x_rolled_price       Number;
	l_doc_return	     Varchar2(5);
	i		     Number;
	x_int_header_id      Number;
	x_segment1           mtl_system_items.segment1%type;
	l_assgn_set_id       Number;
	x_start_date	     Date;
	x_end_date	     Date;
        l_doc_exists         Boolean;
        x_index              Number;
        x_org_id             Po_headers_all.org_id%type;
        l_model_item_id      Number;
        l_config_exists      Varchar2(1);
        l_po_valid_org       Number;
	l_buy_found          Varchar(1);
	l_config_creation    Number;
begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_assgn_set_id := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
	lStmtNumber := 10;

        g_pg_level := g_pg_level + 3;
        If pg_debug <> 0 then
           oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Inside Rollup Purchase Price API',1);
        End if;
        select base_item_id,
	       config_orgs
        into   l_model_item_id,
	       l_config_creation
        from   mtl_system_items
        where  inventory_item_id = p_config_item_id
        and    rownum  =1;
	IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Calling get_all_item_asl...',5);
           oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: '||'Model item id = '||l_model_item_id,1);
	END IF;


	-- Get the vendor and vendor site information from
        -- PO. This PO API will return all the vendor,vendor site and
        -- Asl id for the model.
        lStmtNumber := 20;

        lStmtNumber := 30;
	PO_AUTOSOURCE_SV.get_all_item_asl(
			x_item_id               => l_model_item_id,
			X_using_organization_id => -1,
			x_vendor_details        => l_model_vendors,
			x_return_status         => x_return_status,
			x_msg_count	        => x_msg_count,
			x_msg_data		=> x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Expected Error in Get_all_item_asl.',1);
           END IF;
           raise FND_API.G_EXC_ERROR;

        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: UnExpected Error in Get_all_item_asl.',1);
           END IF;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;

        lStmtNumber := 40;
	if l_model_vendors.count = 0 then
	  IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: No ASL defined for model...',5);
    	  END IF;
          g_pg_level := g_pg_level - 3;
	  return;
	end if;

	IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add('ROLLUP_PURCHASE_PRICE: ' || 'Calling get_all_item_asl for config..',1);
	END IF;
        -- Get all the ASL's Defined for Config item (You may have some
        --                  in the case of matching)
        lstmtNumber := 50;

        PO_AUTOSOURCE_SV.get_all_item_asl(
                        x_item_id 		=> p_config_item_id,
                        x_using_organization_id => -1,
                        x_vendor_details 	=> x_config_vendors,
			x_return_status		=> x_return_status,
			x_msg_count		=> x_msg_count,
			x_msg_data		=> x_msg_data);


       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Expected Error in Get_all_item_asl.',1);
           END IF;
           raise FND_API.G_EXC_ERROR;

        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: UnExpected Error in Get_all_item_asl.',1);
           END IF;
           raise FND_API.G_EXC_UNEXPECTED_ERROR;

        END IF;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Started looping....',5);
	END IF;
        Reduce_vendor_by_ou(
                        p_vendor_details   => l_model_vendors,
			p_config_item_id   => p_config_item_id,
			p_line_id          => p_line_id,
			p_mode             => p_mode,
                        x_vendor_details   => x_model_vendors);
--        x_model_vendors := l_model_vendors;
	i := x_model_vendors.first;

        if PG_DEBUG <> 0 then
	   oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: BEGIN ROLLUP BLANKETS FOR ' || to_char(p_config_item_id),1);
	end if;

        -- Start processing each vendor and  vendor sites for th model ASL
        lStmtNumber := 60;
	while (i is not null)
	loop
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: ' || '****************************',1);
			oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Working for vendor ='
                                                             ||to_char(x_model_vendors(i).vendor_id),5);

			oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE:  vendor site id     ='
                                                             ||to_char(x_model_vendors(i).vendor_site_id),1);

                	oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE:  Asl id             ='
                                                             ||to_char(x_model_vendors(i).asl_id),1);

			oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE:  Index variable ='||to_char(i),1);
		END IF;
                -- CAll the custom API with Vendor and Vendor site information
                -- If the custom API returns TRUE we should not do anything, It is assumed
                -- That the custom API would have taken care of everything. IN this case we will skip this
                -- vendor and vendor site and go with the next one.

                -- If the custom API returns 'FALSE' we will process this record.
                lStmtNumber := 70;
                If CTO_CUSTOM_PURCHASE_PRICE_PK.Get_Purchase_price(
						p_item_id        => p_config_item_id,
					        p_vendor_id      => x_model_vendors(i).vendor_id,
						p_vendor_site_id => x_model_vendors(i).vendor_site_id) then
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Custom API returned value...',1);
			END IF;
		else

		  l_purchase_uom       := x_model_vendors(i).Purchasing_uom;
                  l_vendor_product_num := x_model_vendors(i).Vendor_product_num ;


		  --  Modified by Renga Kannan on 04/16/2002
                  --  Check if the config has valid asl and blanket for this
                  --  Vendor and vendor site. If it does not have then
                  --  We should do rollup for that
                  lStmtNumber := 80;

		  config_asl_exists(
				p_vendor_id      => x_model_vendors(i).vendor_id,
				p_vendor_site_id => x_model_vendors(i).vendor_site_id,
				p_vendor_list    => x_config_vendors,
				x_asl_found      => l_doc_exists,
				x_index          => x_index);

                  if l_doc_exists then
                   	IF PG_DEBUG <> 0 THEN
                   		oe_debug_pub.add(lpad(' ',g_pg_level)
                                                  ||'ROLLUP_PURCHASE_PRICE: ASL exists for blanket, checking to see the blanket..',5);
                   	END IF;

			l_doc_line_id   := null;
                        l_doc_header_id := null;

                        lStmtNumber := 90;

                        PO_AUTOSOURCE_SV.blanket_document_sourcing(
                                x_item_id              => p_config_item_id,
                                x_vendor_id            => x_config_vendors(x_index).vendor_id,
                                x_vendor_site_id       => x_config_vendors(x_index).vendor_site_id,
                                x_asl_id               => x_config_vendors(x_index).asl_id,
                                x_destination_doc_type => null,
                                x_organization_id     => -1,
                                x_currency_code        => null,
                                x_item_rev             => null,
                                x_autosource_date      => null,
                                x_document_header_id   => l_doc_header_id,
                                x_document_type_code   => l_doc_type_code,
                                x_document_line_num    => l_doc_line_num,
                                x_document_line_id     => l_doc_line_id,
                                x_vendor_contact_id    => l_vendor_contact_id,
                                x_vendor_product_num   => l_vendor_product_num,
                                x_buyer_id             => l_buyer_id,
                                x_purchasing_uom       => l_purchase_uom,
                                x_multi_org            => 'Y',
                                x_doc_return           => l_doc_return,
                                x_return_status        => x_return_status,
                                x_msg_count            => x_msg_count,
                                x_msg_data             => x_msg_data);

                        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add(lpad(' ',g_pg_level)
                                               ||'ROLLUP_PURCHASE_PRICE: Expected Error in Blanket_Document_sourcing.',1);
                           END IF;
                           raise FND_API.G_EXC_ERROR;

                        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                           IF PG_DEBUG <> 0 THEN
                              oe_debug_pub.add(lpad(' ',g_pg_level)
                                               ||'ROLLUP_PURCHASE_PRICE: UnExpected Error in blanket_document_sourcing.',1);
                           END IF;
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;

                        END IF;

                        lStmtNumber := 100;
                       	If l_doc_return  = 'Y' then
			   IF PG_DEBUG <> 0 THEN
			      oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Valid Blanket found for config ..',2);
			   END IF;
			   l_doc_exists := TRUE;
			else
			   IF PG_DEBUG <> 0 THEN
			      oe_debug_pub.add(lpad(' ',g_pg_level)
                                                  ||'ROLLUP_PURCHASE_PRICE: Valid Blanket not found for this config',2);
		    	   END IF;
			   l_doc_exists := FALSE;
			end if;

                  end if; /* If l_doc_exists */

                  lStmtNumber := 110;
                  if l_doc_exists then
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add(lpad(' ',g_pg_level)
                                           ||'ROLLUP_PURCHAE_PRICE: Valid Asl  blanket already exists for configuration....',2);

			END IF;
		  elsif x_model_vendors(i).vendor_site_id is null then
                        IF PG_DEBUG <> 0 THEN
                        	oe_debug_pub.add(lpad(' ',g_pg_level)
                                           ||'ROLLUP_PURCHASE_PRICE: Vendor site id is null need not process..',2);
                        END IF;
                  else
			l_doc_line_id   := null;
			l_doc_header_id := null;
                        lStmtNumber := 120;
			PO_AUTOSOURCE_SV.blanket_document_sourcing(
				x_item_id              => l_model_item_id,
				x_vendor_id            => x_model_vendors(i).vendor_id,
				x_vendor_site_id       => x_model_vendors(i).vendor_site_id,
				x_asl_id	       => x_model_vendors(i).asl_id,
				x_destination_doc_type => null,
				x_organization_id     => -1,
				x_currency_code        => null,
				x_item_rev	       => null,
				x_autosource_date      => null,
				x_document_header_id   => l_doc_header_id,
				x_document_type_code   => l_doc_type_code,
				x_document_line_num    => l_doc_line_num,
				x_document_line_id     => l_doc_line_id,
				x_vendor_contact_id    => l_vendor_contact_id,
				x_vendor_product_num   => l_vendor_product_num,
				x_buyer_id    	       => l_buyer_id,
				x_purchasing_uom       => l_purchase_uom,
				x_multi_org	       => 'Y',
				x_doc_return           => l_doc_return,
				x_return_status	       => x_return_status,
				x_msg_count	       => x_msg_count,
				x_msg_data	       => x_msg_data);


                       IF( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                       IF PG_DEBUG <> 0 THEN
	               oe_debug_pub.add(lpad(' ',g_pg_level)
                                         ||'success status false for po_autosource_sv.blanket_document_sourcing...',1);

                       END IF;

                       return ;

                       END IF;
                       lStmtNumber := 130;

			If l_doc_return = 'N' then
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHAES_PRICE: No blankets returned..',2);
				END IF;
			else
			  IF PG_DEBUG <> 0 THEN
			  	oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Blanket document line id ='
                                                                           ||to_char(l_doc_line_id),2);

			  	oe_debug_pub.add(lpad(' ',g_pg_level)
                                                         ||'ROLLUP_PURCHASE_PRICE: ROLLUP_PURCHASE_PRICE: Blanket doc header id    ='
                                                                           ||to_char(l_doc_header_id),2);
			  END IF;

			  if config_exists_in_blanket(
						p_config_item_id     => p_config_item_id,
						p_doc_header_id      => l_doc_header_id)
			  then

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE '
                                                         || 'Config line already exists in blanket..',2);
				END IF;
			  else
                                lStmtNumber := 140;
                                Begin

                                   select 'Y',organization_id
                                   into  l_config_exists,l_po_valid_org
                                   from mtl_system_items
                                   where inventory_item_id = p_config_item_id
                                   and   organization_id = (select fsp.inventory_organization_id
                                                         from   financials_system_params_all fsp,
                                                                po_headers_all poh
                                                         where  poh.po_header_id = l_doc_header_id
                                                         and    fsp.org_id    = poh.org_id);
                                Exception when no_data_found then
                                   l_config_exists := 'N';
                                   if pg_debug <> 0 Then
                                      oe_debug_pub.add(lpad(' ',g_pg_level)
                                           ||'ROLLUP_PURCHASE_PRICE: Config item does not exist in Po validation org. ',5);
                                   End if;
                                End;

                                If l_config_exists = 'Y' then
                                lStmtNumber := 150;
				rollup_blanket_price(
						p_config_item_id => p_config_item_id,
						p_doc_header_id => l_doc_header_id,
						p_doc_line_id   => l_doc_line_id,
                                                p_group_id      => p_group_id,
                                                p_po_valid_org  => l_po_valid_org,
						x_rolled_price  => x_rolled_price,
						x_return_status => x_return_status,
						x_msg_count     => x_msg_count,
						x_msg_data      => x_msg_data);

                                oe_debug_pub.add('Rolled up blanket price =
'||x_rolled_price);

                                lStmtNumber := 160;

				insert_blanket_header(
						p_doc_header_id   => l_doc_header_id,
						p_batch_id        => p_batch_id,
						x_int_header_id   => x_int_header_id,
                                                x_org_id          => x_org_id,
						x_return_status   => x_return_status,
						x_msg_count 	  => x_msg_count,
						x_msg_data        => x_msg_data);
                               lStmtNumber := 170;

				select segment1
				into   x_segment1
				from   Mtl_system_items
				where  inventory_item_id = p_config_item_id
				and    rownum = 1;

				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE:  Item Name ='||x_segment1,2);
				END IF;
                                lStmtNumber := 180;
				Derive_start_end_date(
						     p_item_id         => p_config_item_id,
						     p_vendor_id       => x_model_vendors(i).vendor_id,
						     p_vendor_site_id  => x_model_vendors(i).vendor_site_id,
						     p_assgn_set_id    => l_assgn_set_id ,
						     x_start_date      => x_start_date,
						     x_end_date        => x_end_date);
                                lStmtNumber := 190;
				insert_blanket_line(
						p_doc_line_id     => l_doc_line_id,
						p_item_id         => p_config_item_id,
						p_item_rev	  => null,
						p_price           => x_rolled_price,
						p_int_header_id   => x_int_header_id,
						p_segment1        => x_segment1,
						p_start_date      => x_start_date,
						p_end_date        => x_end_date,
						x_return_status   => x_return_status,
						x_msg_count	  => x_msg_count,
						x_msg_data        => x_msg_data);

				-- Record the operating unit in a table
				-- This tbale is used for launching the concurrent program

                                IF PG_DEBUG <> 0 THEN
                               	   oe_debug_pub.add(lpad(' ',g_pg_level)||'ROLLUP_PURCHASE_PRICE: Blanket Operating unit    = '
                                                                        ||to_char(x_org_id),2);
                                END IF;

                                -- We should take the OU from Blanket instead of rcv org OU.
                                lStmtNumber := 200;
				if(not x_oper_unit_list.exists(x_org_id)) then

					x_oper_unit_list(x_org_id).oper_unit := x_org_id;
					-- The following global assignment is added becase Pro*c
					-- Cannot pass/receive record of tables.
					Cto_auto_procure_pk.G_oper_unit_list(x_org_id).oper_unit := x_org_id;
				end if;
                              end if; /* If l_config_exists = 'Y' */

			  end if; /* if config_exists_in_blanket */
			end if; /* l_doc_return = 'N' */
	            end if; /* l_doc_exists */
		  end if;  /* CTO_CUSTOM_PURCHASE_PRICE_PK.Get_Purchase_price */
		  i := x_model_vendors.next(i);

	end loop;

        if PG_DEBUG <> 0 then
	   oe_debug_pub.add(lpad(' ',g_pg_level) || 'ROLLUP_PURCHASE_PRICE: ' || '****************************',1);
	   oe_debug_pub.add(lpad(' ',g_pg_level) || 'ROLLUP_PURCHASE_PRICE: END ROLLUP BLANKETS FOR ' || to_char(p_config_item_id),1);
	end if;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_pg_level := g_pg_level - 3;

exception

        when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Rollup_purchase_price: ' || 'Rollup_purchase_price::unexp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );

        when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Rollup_purchase_price: ' || 'Rollup_purchase_price::exp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data);

        when others then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Rollup_purchase_price: ' || 'Rollup_purchase_price::others::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );

end Rollup_purchase_price;




Procedure config_asl_exists(
			p_vendor_id        IN  Number,
			p_vendor_site_id   IN  Number,
			p_vendor_list      IN  PO_AUTOSOURCE_SV.vendor_record_details,
			x_asl_found        OUT NOCOPY Boolean,
			x_index            OUT NOCOPY Number)  is

	i 		Number;
begin
	x_asl_found := FALSE;
	i := p_vendor_list.first;
	while (i is not null)
	loop

		if p_vendor_list(i).vendor_id = p_vendor_id and
		   p_vendor_list(i).vendor_site_id = p_vendor_site_id
		then
			x_asl_found := TRUE;
			x_index := i;
			exit;
		end if;
		i := p_vendor_list.next(i);
	end loop;


end config_asl_exists;


Function config_exists_in_blanket(
			p_config_item_id   IN Number,
			p_doc_header_id    IN Number) return boolean is

	line_exists    varchar2(1) := 'N';
begin

	Select 'X'
	into	line_exists
        From po_lines_all pol,
             Po_headers_all poh
        Where
              poh.type_lookup_code = 'BLANKET'
        AND   poh.approved_flag    = 'Y'
        AND   nvl(poh.closed_code,'OPEN') NOT IN('FINALLY CLOSED','CLOSED')
        AND   nvl(pol.closed_code, 'OPEN') NOT IN('FINALLY CLOSED','CLOSED')
        AND   nvl(poh.cancel_flag,'N') = 'N'
        AND   nvl(poh.frozen_flag,'N') = 'N'
        AND   trunc(nvl(pol.expiration_date, sysdate + 1)) > trunc(sysdate)
        AND   nvl(pol.cancel_flag,'N') = 'N'
        AND   poh.po_header_id = p_doc_header_id
        AND   pol.po_header_id    = poh.po_header_id
        AND   pol.item_id      = p_config_item_id;

	return True;

exception
       when no_data_found then
	return False;
       when others then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('config_exists_in_blanket: ' || 'When others error occured in sql ..',1);
	END IF;

end config_exists_in_blanket;



Procedure rollup_blanket_price(
                      p_config_item_id in  number,
                      p_doc_header_id  in  number,
		      p_doc_line_id    in  number,
                      p_group_id       in  number,
                      p_po_valid_org   in  Number,
  	 	      p_mode           IN  Varchar2 Default 'ORDER',
                      x_rolled_price   out NOCOPY number,
                      x_return_status  out NOCOPY varchar2,
                      x_msg_count      out NOCOPY number,
                      x_msg_data       out NOCOPY varchar2) is

	l_unit_price		Number;
	l_switch        	Boolean := TRUE;
	l_model_qty     	Number := 0;
	l_ratio	        	Number;
	l_prim_uom_qty  	Number;
	l_prim_uom      	Bom_cto_order_lines.order_quantity_uom%type;
        l_po_uom_code   	po_lines_all.unit_meas_lookup_code%type;
	l_po_uom		Bom_cto_order_lines.order_quantity_uom%type;
	l_conv_qty      	Number;
	l_model_po_uom  	Bom_cto_order_lines.order_quantity_uom%type;
	l_model_order_uom       Bom_cto_order_lines.order_quantity_uom%type;
	l_po_uom_qty            Number;
	l_config_item_id        Mtl_system_items.inventory_item_id%type;
        i 			Number;
        Cursor buy_comps_cur is
        select exp.component_item_id   comp_item_id,
               exp.component_quantity  comp_qty,
               exp.primary_uom_code    uom_code,
               exp.configurator_flag   config_flag
        from   bom_explosion_temp exp
        where  group_id = p_group_id
        and    assembly_item_id = p_config_item_id;
        l_rollup_price  Number;

        l_base_model_id  number;

begin

   g_pg_level := g_pg_level + 3;

   x_rolled_price := 0;


   If p_doc_line_id is not null then

      select base_item_id
      into   l_base_model_id
      from   mtl_system_items
      where  inventory_item_id = p_config_item_id
      and    rownum = 1;

      oe_debug_pub.add(lpad(' ',g_pg_level) || 'Base model item id = '||l_base_model_id,5);
      oe_debug_pub.add(lpad(' ',g_pg_level) || 'Po doc line id     = '||p_doc_line_id,5);

   End if;

   For buy_comps in buy_comps_cur
   Loop

      Begin

      -- As per PO team and Val if more than  one record
      -- found for the same item in blanket we will be taking
      -- the first row. We are expecting the ct. not to have
      -- more than one row for the same item. This will be documented

         Select pol.unit_price,
                muom.uom_code
         into   l_unit_price,
                l_po_uom
         From po_lines_all pol,
               Po_headers_all poh,
               mtl_units_of_measure muom
         Where
                     poh.type_lookup_code = 'BLANKET'
                AND  poh.approved_flag    = 'Y'
                AND  nvl(poh.closed_code,'OPEN') NOT IN('FINALLY CLOSED','CLOSED')
                AND  nvl(pol.closed_code, 'OPEN') NOT IN('FINALLY CLOSED','CLOSED')
                AND  nvl(poh.cancel_flag,'N') = 'N'
                AND  nvl(poh.frozen_flag,'N') = 'N'
                AND  trunc(nvl(pol.expiration_date, sysdate + 1)) > trunc(sysdate)
                AND  nvl(pol.cancel_flag,'N') = 'N'
                AND  poh.po_header_id = p_doc_header_id
                AND  pol.po_header_id = poh.po_header_id
                AND  pol.item_id      = buy_comps.comp_item_id
                AND  (   (p_doc_line_id is null)
                      or (buy_comps.comp_item_id <> l_base_model_id)
                      or (pol.po_line_id = p_doc_line_id)
                     )
                AND  muom.unit_of_measure = unit_meas_lookup_code
                AND  rownum = 1; -- Added by renga Kannan on 04/15/02
          l_conv_qty := CTO_UTILITY_PK.convert_uom(
                                         from_uom   => buy_comps.uom_code,
                                         to_uom     => l_po_uom,
                                         quantity   => buy_comps.comp_qty,
                                         item_id    => buy_comps.comp_item_id);
          l_unit_price := l_unit_price*l_Conv_qty;
      Exception when no_data_found then
         If buy_comps.config_flag = 'N' then
           Begin
              select nvl(list_price_per_unit,0),
                     primary_uom_code
              into   l_unit_price,
                     l_po_uom
              from   mtl_system_items
              where  inventory_item_id = buy_comps.comp_item_id
              and    organization_id   = p_po_valid_org;
           Exception when no_data_found then
              l_unit_price := 0;
           End;
           If l_unit_price <> 0 then
                -- Comvert the UOM here
              l_conv_qty := CTO_UTILITY_PK.convert_uom(
                                                from_uom   => buy_Comps.uom_code,
                                                to_uom     => l_po_uom,
                                                quantity   => buy_comps.comp_qty,
                                                item_id    => buy_comps.comp_item_id);

           else
              l_conv_qty := 0;
           end if;
           l_unit_price := l_unit_price * l_conv_qty;
        elsif buy_comps.config_flag = 'Y' then
           rollup_blanket_price(
                      p_config_item_id => buy_comps.comp_item_id,
                      p_doc_header_id  => p_doc_header_id,
                      p_doc_line_id    => null,
                      p_group_id       => p_group_id,
                      p_po_valid_org   => p_po_valid_org,
                      x_rolled_price   => l_unit_price,
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data);
            l_unit_price := l_unit_price * buy_comps.comp_qty;
        end if; /* buy_comps.config_flag = 'N' */
      End;
      x_rolled_price := nvl(x_rolled_price,0) + l_unit_price;

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add(lpad(' ',g_pg_level) || 'rollup_blanket_price: ' || 'Item Id = '|| buy_comps.comp_item_id,1);

         oe_debug_pub.add(lpad(' ',g_pg_level) || 'rollup_blanket_price: ' || 'Blanket price ='|| to_char(l_unit_price),1);
      END IF;

   End loop; /* Buy_comps */

   g_pg_level := g_pg_level - 3;

end rollup_blanket_price;




procedure insert_blanket_header(
                     p_doc_header_id   IN            Number,
                     p_batch_id        IN OUT NOCOPY Number,
		     x_int_header_id   Out    NOCOPY Number,
                     x_org_id          OUT    NOCOPY po_headers_all.org_id%type,
                     x_return_status   OUT    NOCOPY varchar2,
                     x_msg_count       OUT    NOCOPY Number,
                     x_msg_data        OUT    NOCOPY varchar2) is
begin

   	g_pg_level := g_pg_level + 3;

	select po_headers_interface_s.nextval
	into   x_int_header_id
	from   dual;

        If nvl(p_batch_id,-1) = -1 Then
	   p_batch_id := x_int_header_id;
	end if;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_header: ' || 'Interface header id ='||to_char(x_int_header_id),1);
	END IF;


	Insert into Po_headers_interface(
        	interface_header_id,
		batch_id,
		process_code,
		action,
		org_id,
		document_type_code,
		document_num,
		po_header_id,
		currency_code,
		rate_type,
		rate_date,
		rate,
		agent_id,
		vendor_id,
		vendor_site_id,
		vendor_contact_id,
		ship_to_location_id,
		bill_to_location_id,
		terms_id,
		note_to_vendor,
		note_to_receiver,
		acceptance_required_flag,
		min_release_amount,
		frozen_flag,
		closed_code,
		reply_date,
		ussgl_transaction_code,
        	load_sourcing_rules_flag,
                global_agreement_flag ) /* BUG#2726167 populate global_agreement_flag */
	select
		x_int_header_id,
        	p_batch_id,
        	'PENDING',
        	'UPDATE',
		poh.org_id,
		poh.type_lookup_code,
		poh.segment1,
 		poh.po_header_id,
		poh.currency_code,
		poh.rate_type,
		poh.rate_date,
		poh.rate,
		poh.agent_id,
		poh.vendor_id,
		poh.vendor_site_id,
		poh.vendor_contact_id,
		poh.ship_to_location_id,
		poh.bill_to_location_id,
		poh.terms_id,
		poh.note_to_vendor,
		poh.note_to_receiver,
		poh.acceptance_required_flag,
		poh.min_release_amount,
		poh.frozen_flag,
		poh.closed_code,
		poh.reply_date,
		poh.ussgl_transaction_code,
        	'Y',
                global_agreement_flag  /* BUG#2726167 populate global_agreement_flag */
	From   Po_headers_all poh
	where  poh.po_header_id = p_doc_header_id;

        select org_id
        into   x_org_id
        from   po_headers_all
        where  po_header_id = p_doc_header_id;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_header: ' || 'No of records inserted in headers  = '||to_char(sql%rowcount),1);

        	oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_header: ' || 'Operating unit for the Blanket Doc = '||to_char(x_org_id),1);
        END IF;

        g_pg_level := g_pg_level - 3;

End insert_blanket_header;


procedure  insert_blanket_line(
                    p_doc_line_id     IN  Number,
                    p_item_id         IN  Number,
                    p_item_rev        IN  Varchar2,
                    p_price           IN  Number,
		    p_int_header_id   IN  Number,
	            p_segment1        IN  Mtl_system_items.segment1%type,
                    p_start_date      IN  Date,
	            p_end_date        IN  Date,
                    x_return_status   OUT NOCOPY Varchar2,
                    x_msg_count       OUT NOCOPY Number,
                    x_msg_data        OUT NOCOPY varchar2) is

     		l_interface_line_id   Number;
		l_segment1            Mtl_system_items.segment1%type;

begin

        g_pg_level := g_pg_level + 3;

	select segment1
	into   l_segment1
	from   mtl_system_items
	where  inventory_item_id = p_item_id
	and    rownum=1;



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_line: ' || 'Inerting into po_lines_interface',1);

        	oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_line: ' || 'Start date = '||to_char(p_start_date),2);

		oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_line: ' || 'End date   ='||to_char(p_end_date),2);
	END IF;

        -- Bug fix 3589150
        -- Done by Renga Kannan on 04/30/04
        -- Allow_price_override_flag and not_to_exceed_price should not be
        -- copied from model as it will not make any sense. And there
        -- no way to derive these fileds also.
	Insert into po_lines_interface(
		interface_line_id,
		interface_header_id,
     		Line_num,
        	line_type_id,
        	item_id,
		item,     ---- As per beth I am adding this
		item_revision,
		category_id,
        	unit_of_measure,
		quantity,
		--	commited_acount,
		min_order_quantity,
		max_order_quantity,
		unit_price,
		negotiated_by_preparer_flag,
		un_number_id,
		hazard_class_id,
		note_to_vendor,
		taxable_flag,
		tax_name,
		--type_1099,
		--	terms_id,
		price_type,
		min_release_amount,
		price_break_lookup_code,
		ussgl_transaction_code,
		closed_date,
		tax_code_id,
		effective_date,
		expiration_date)
	select
		po_lines_interface_s.nextval,
		p_int_header_id,
		null,
		pol.line_type_id,
		p_item_id,
		p_segment1,
		null,
		pol.category_id,
		pol.unit_meas_lookup_code,
		pol.quantity,
		--	pol.commited_amount,
 		pol.min_order_quantity,
		pol.max_order_quantity,
		p_price,
		decode(pol.negotiated_by_preparer_flag,'X',null,pol.negotiated_by_preparer_flag),
		pol.un_number_id,
		pol.hazard_class_id,
		pol.note_to_vendor,
		pol.taxable_flag,
		pol.tax_name,
		--pol.type_1099,
		--	pol.terms_id,
		pol.price_type_lookup_code,
		pol.min_release_amount,
		pol.price_break_lookup_code,
		pol.ussgl_transaction_code,
		pol.closed_date,
		pol.tax_code_id,
       		decode(poh.start_date,null,p_start_date,poh.start_date),
	        decode(poh.end_date,null,p_end_date,poh.end_date)
	from    po_lines_all pol,
	        po_headers_all poh
	where   pol.po_line_id =p_doc_line_id
	and     poh.po_header_id = pol.po_header_id;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_line: ' || 'No of records inserted in lines  = '||to_char(sql%rowcount),1);
	END IF;

	-- Insert the rows from po_line_locations_all

        -- Modified by Renga Kannan on 04/16/2002
        -- Added ship_to_location_id in the interface table.

	Insert into Po_lines_interface(
		interface_line_id,
		interface_header_id,
		line_num,
		shipment_num,
		shipment_type,
		line_type_id,
		source_shipment_id,
		item_id,
		item,
		item_revision,
		category_id,
		unit_of_measure,
		quantity,
		terms_id,
		days_early_receipt_allowed,
		days_late_receipt_allowed,
		ship_to_organization_id,
		ship_to_location_id,
		price_discount,
		unit_price,
		effective_date,
		expiration_date,
	        shipment_attribute_category,
		shipment_attribute1,
		shipment_attribute2,
		shipment_attribute3,
		shipment_attribute4,
		shipment_attribute5,
		shipment_attribute6,
		shipment_attribute7,
		shipment_attribute8,
		shipment_attribute9,
		shipment_attribute10,
		shipment_attribute11,
		shipment_attribute12,
		shipment_attribute13,
		shipment_attribute14,
		shipment_attribute15,
		last_update_date)
		--price_override) -- Check with Beth
	select
                po_lines_interface_s.nextval,
                p_int_header_id,
                null,
                poll.shipment_num,
                poll.shipment_type,
                pol.line_type_id,
                poll.source_shipment_id,
                p_item_id,
		p_segment1,
                null,
                pol.category_id,
                poll.unit_meas_lookup_code,
                poll.quantity,
                null,
                poll.days_early_receipt_allowed,
                poll.days_late_receipt_allowed,
                poll.ship_to_organization_id,
		poll.ship_to_location_id,
                poll.price_discount,
		p_price*(1-poll.price_discount/100),
                poll.start_date,
                poll.end_date,
		poll.attribute_category,
                poll.attribute1,
                poll.attribute2,
                poll.attribute3,
                poll.attribute4,
                poll.attribute5,
                poll.attribute6,
                poll.attribute7,
                poll.attribute8,
                poll.attribute9,
                poll.attribute10,
                poll.attribute11,
                poll.attribute12,
                poll.attribute13,
                poll.attribute14,
                poll.attribute15,
                sysdate
	--	p_price*poll.price_discount/100
               -- price_discount
	from   po_line_locations_all poll,
	       po_lines_all pol
	where  pol.po_line_id = p_doc_line_id
	and    pol.po_line_id = poll.po_line_id;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add(lpad(' ',g_pg_level) || 'insert_blanket_line: ' || 'No of records inserted in locations  = '||to_char(sql%rowcount),1);
	END IF;

        g_pg_level := g_pg_level - 3;

End insert_blanket_line;



procedure Reduce_vendor_by_ou(
                        p_vendor_details    in  PO_AUTOSOURCE_SV.vendor_record_details,
			p_config_item_id    in  Number,
			p_line_id           in  Number,
			p_mode              in  Varchar2,
                        x_vendor_details    out NOCOPY PO_AUTOSOURCE_SV.vendor_record_details) is

	j            Number := 0;
	l_oper_unit  Number;
	i	     Number;
        l_assg_set_id       Number;
	/* The following cursor will selec the vendors and vendor
	   sites defined in the sourcing rule for the config item
	*/
	Cursor oss_vendor_cur(p_assg_set_id number) is
	 select vendor_id,
	        vendor_site_id
	 from   mrp_sources_v
	 where  assignment_set_id = p_assg_set_id
	 and    inventory_item_id = p_config_item_id
	 and    assignment_type in (3,6)
	 and    source_type = 3
	 and    vendor_site_id is not null;


	/* The following cursor will get the operatin unit list
	   of the valid receiving orgs
	*/

	Cursor oper_unit_cur is
	 select distinct operating_unit organization_id
	 from   inv_organization_info_v
	 where  organization_id in (select organization_id
	                            from   bom_cto_src_orgs
				    where  line_id = p_line_id
				    and    organization_type = 3);

	 l_option_specific   varchar2(1);
	 l_config_creation   varchar2(1);


	 TYPE Num_table is table of number index by binary_integer;
	 l_oper_unit_list  Num_table;
	 l_vendor_list     Num_table;
	 l_vendor_site_list Num_table;


begin
   l_assg_set_id := to_number(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));
   /*
      This API will remove unwanted blankets from rolluping up.
      There is a seperate logic exists for this
   */

   -- The following select statement will get the
   -- oss attribute and config creation attribute
   -- from mtl system items. Both these attributes
   -- in master org level, hence u can get the attribute
   -- from any organization.

   oe_debug_pub.add('Reduce_vendor_by_ou: Option specific = '||p_config_item_id,1);

   Select option_specific_sourced
   into   l_option_specific
   from   mtl_system_items
   where  inventory_item_id = p_config_item_id
   and    rownum<2;

   If p_mode = 'ORDER' then
      select config_creation
      into   l_config_creation
      from   bom_cto_order_lines
      where  line_id = p_line_id;
   End if;

   oe_debug_pub.add('Reduce_vendor_by_ou: Option specific = '||l_option_specific,1);
   oe_debug_pub.add('Reduce_vendor_by_ou: Config Creation = '||l_config_creation,1);
   oe_debug_pub.add('Reduce_vendor_by_ou: Mode            = '||p_mode,1);

   If p_mode = 'ORDER' and nvl(l_config_creation,1)  in (1,2) then
      oe_debug_pub.add('Reduce_vendor_by_ou: Need to reduce vendors for this case based on sourcing chain',1);

      For oper_unit_rec in oper_unit_cur
      Loop
         l_oper_unit_list(oper_unit_rec.organization_id) := oper_unit_rec.organization_id;
      End Loop;
      i := p_vendor_details.first;

      While (i is not null)
      Loop
         If p_vendor_details(i).vendor_site_id is not null then

            Select Org_id
	    into   l_oper_unit
	    from   po_vendor_sites_all
	    where  vendor_site_id = p_vendor_details(i).vendor_site_id;

	 End if;

	 If l_oper_unit_list.exists(l_oper_unit) then
	   oe_debug_pub.add('Vendor site '||p_vendor_details(i).vendor_site_id||' is part of the sourcing chain',1);
	   x_vendor_details(j) := p_vendor_details(i);
	   j := j + 1;
	 else
 	   oe_debug_pub.add('Vendor site '||p_vendor_details(i).vendor_site_id||' is not part of the sourcing chain',1);
	 End if;
 	 i := p_vendor_details.next(i);
      End Loop;
   Else
      -- Added for MOAC
      -- Reducing records which are not having vendor site

      If PG_DEBUG <> 0 Then
         oe_debug_pub.add('Reduce_vendor_by_ou: cib based on model', 3);
      End if;

      i := p_vendor_details.first;

      while (i is not null)
      Loop
         if p_vendor_details(i).vendor_site_id is not null then
            x_vendor_details(j) := p_vendor_details(i);
            j := j + 1;
         else
            If PG_DEBUG <> 0 Then
               oe_debug_pub.add('Reduce_vendor_by_ou: Removing  vendor='
                                ||p_vendor_details(i).vendor_id||' as the vendor site is null',3);
            End if;
         end if;
         i := p_vendor_details.next(i);
      End loop;
      -- End of MOAC change
   End if;

   If nvl(l_option_specific,3) in (1,2) then
      oe_debug_pub.add('Reduce_vendor_by_ou: Need to reduce vendors by OSS vendors',1);

      For oss_vendor_rec in oss_vendor_cur(l_assg_set_id)
      Loop
         l_vendor_list(oss_vendor_rec.vendor_id) := oss_vendor_rec.vendor_id;
	 l_vendor_site_list(oss_vendor_rec.vendor_site_id) := oss_vendor_rec.vendor_site_id;
      End Loop;
      i := x_vendor_details.first;

      While (i is not null)
      Loop
         If l_vendor_list.exists(x_vendor_details(i).vendor_id)
	    and l_vendor_site_list.exists(x_vendor_details(i).vendor_site_id) then
	    oe_debug_pub.add('Reduce_vendor_by_ou: Vendor is valid ',1);
	 Else
	    oe_debug_pub.add('Reduce_vendor_by_ou: Removing vendor id = '||x_vendor_details(i).vendor_id,1);
	    oe_debug_pub.add('Reduce_vendor_by_ou: Removing Vendor site = '||x_vendor_details(i).vendor_site_id,1);
            x_vendor_details.delete(i);
	 End if;
	 i := x_vendor_details.next(i);
      End Loop;
   End if;

end reduce_vendor_by_ou;



Procedure  Derive_start_end_date(
			        p_item_id         IN   bom_cto_order_lines.inventory_item_id%type,
				p_vendor_id       IN   Number,
                                p_vendor_site_id  IN   Number,
                                p_assgn_set_id    IN   Number ,
                                x_start_date      OUT NOCOPY date ,
                                x_end_date        Out NOCOPY date) is

l_sourcing_rule_id	Number;

begin

   -- Added by Renga Kannan on 03/25/02. took the logic from PO code

     Begin

     	SELECT /*+ INDEX(MRP_SR_ASSIGNMENTS MRP_SR_ASSIGNMENTS_N3) */
       	        sourcing_rule_id
     	INTO    l_sourcing_rule_id
     	FROM    mrp_sr_assignments
     	WHERE   inventory_item_id = p_item_id
     	AND     assignment_set_id = p_assgn_set_id
     	AND     sourcing_rule_type = 1
     	AND     assignment_type = 3;

     Exception when no_data_found then
	l_sourcing_rule_id := null;
     end;


     -- We will take the sourcing rule effective for sysdate window
     -- Added by Renga Kannan on 04/08/02

     If l_sourcing_rule_id is not null then
	Begin
		select msro.effective_date,
	       	       msro.disable_date
                into  x_start_date,
	       	      x_end_date
		from    mrp_sourcing_rules msr,
	        	mrp_sr_receipt_org msro
		where   msr.sourcing_rule_id = msro.sourcing_rule_id
		and     msr.sourcing_rule_id = l_sourcing_rule_id
		and     trunc(sysdate) between trunc(nvl(msro.effective_date,sysdate)) and trunc(nvl(msro.disable_date,sysdate+1));

	Exception when no_data_found then
		x_start_date := null;
		x_end_date   := null;
	end;
     else
	x_start_date := null;
	x_end_date   := null;
     end if;

Exception when no_data_found then
	x_start_date := null;
	x_end_date   := null;
end Derive_start_end_date;


/* fp-J: Added several new parameters as part of optional processing project */

PROCEDURE Create_purchase_doc_batch (
           errbuf        OUT NOCOPY  VARCHAR2,
           retcode       OUT NOCOPY  varchar2,
           p_sales_order             NUMBER,
	   p_dummy_field             VARCHAR2,
           p_sales_order_line_id     NUMBER,
           p_organization_id         VARCHAR2,
	   p_dummy_field1            VARCHAR2,
           p_offset_days             NUMBER,
	   p_overwrite_list_price    varchar2,
	   p_config_id		     NUMBER   DEFAULT NULL,
	   p_dummy_field2	     VARCHAR2 DEFAULT NULL,
	   p_base_model_id	     NUMBER   DEFAULT NULL,
	   p_created_days_ago	     NUMBER   DEFAULT NULL,
	   p_load_type		     NUMBER   DEFAULT NULL,
	   p_upgrade		     NUMBER   DEFAULT 2,
	   p_perform_rollup	     NUMBER   DEFAULT 1
 ) AS




    TYPE PProllupCurTyp is REF CURSOR ;
    pprollup_cur    		PProllupCurTyp;

    TYPE PProllupOECurTyp is REF CURSOR ;
    pprollup_oe_cur    		PProllupOECurTyp;

    -- local variables
    lSourceCode               VARCHAR2(100);
    p_po_quantity             NUMBER := NULL;
    l_stmt_num                NUMBER;
    p_dummy                   VARCHAR2(2000);
    v_rsv_quantity            NUMBER; -- Bugfix 3652509: Removed precision
    v_sourcing_rule_exists    VARCHAR2(100);
    v_sourcing_org            NUMBER;
    v_source_type             NUMBER;
    v_transit_lead_time       NUMBER;
    v_exp_error_code          NUMBER;
    v_rec_count               NUMBER := 0;
    v_rec_count_noerr         NUMBER := 0;
    conc_status	              BOOLEAN ;
    current_error_code        VARCHAR2(20) := NULL;
    v_x_error_msg_count       NUMBER;
    v_x_hold_result_out       VARCHAR2(1);
    v_x_hold_return_status    VARCHAR2(1);
    v_x_error_msg             VARCHAR2(150);
    x_return_status           VARCHAR2(1);
    p_new_order_quantity      NUMBER; -- Bugfix 3652509: Removed precision
    l_res                     BOOLEAN;
    l_batch_id                NUMBER;
    v_activity_status_code    VARCHAR2(10);
    l_inv_quantity            NUMBER;

    l_request_id              NUMBER;
    l_program_id              NUMBER;
    l_source_document_type_id NUMBER;

    l_active_activity         VARCHAR2(8);

    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(100);
    x_oper_unit_list          CTO_AUTO_PROCURE_PK.oper_unit_tbl;
    xUserId                   NUMBER;
    xrespid		      NUMBER;
    xrespapplid               NUMBER;

    ll_line_id		      NUMBER;
    ll_inventory_item_id      NUMBER;
    l_ato_line_id             Number;

    err_counter		      NUMBER := 0;
    pass_counter	      NUMBER := 0;
    l_mode                    Varchar2(100);

    -- bug 3782079. rkaza. 08/06/2004
    -- Creating a new instance of the itemInfoTblType for loggin passed items
    TYPE itemInfo is RECORD (
	config_item_id	 number
    );

    TYPE itemInfoTblType is table of itemInfo INDEX BY BINARY_INTEGER ;

    erroredItems  itemInfoTblType;
    passedItems  itemInfoTblType;

    -- Added by Renga Kannan on 03/01/2006 to replace the cursor
    -- with dynamic sql


    sql_stmt            VARCHAR2(5000);
    drive_mark          NUMBER := 0;

    -- End of addition by Renga Kannan

BEGIN

    -- set the return status.
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Set the return code to success
    retcode := 0;

    -- Get the ONT source code
    lSourceCode := FND_PROFILE.VALUE('ONT_SOURCE_CODE');


    -- for all the sales order lines (entered, booked )
    -- Given parameters.
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('Create_purchase_doc_batch: '
                         || '+---------------------------------------------------------------------------+',1);

    	oe_debug_pub.add('Create_purchase_doc_batch: '
                          || '+------------------  Parameters passed into the procedure ------------------+',1);

    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Sales order         : '||p_sales_order ,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Sales Order Line ID : '||to_char(p_sales_order_line_id),1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Organization_id     : '||p_organization_id,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Offset Days         : '||to_char(p_offset_days),1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Overwrite flag      : '||p_overwrite_list_price,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Configuration ItemID: '||p_config_id,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Base Model Id       : '||p_base_model_id,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Created Days ago    : '||p_created_days_ago,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Load Type           : '||p_load_type,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Upgrade             : '||p_upgrade,1);
    	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Perform Rollup      : '||p_perform_rollup,1);

    	oe_debug_pub.add('Create_purchase_doc_batch: '
                          || '+---------------------------------------------------------------------------+',1);
    END IF;

    drive_mark := 0;
    IF (p_upgrade = 2 ) then /* For non-Upgrade */

      IF (p_sales_order is null AND p_sales_order_line_id is null AND p_offset_days is null) THEN

	/* sales order number or line id or offset is NOT passed */

        IF PG_DEBUG <> 0 THEN
    	   oe_debug_pub.add('Create_purchase_doc_batch: '||'Regular cursor.');
        END IF;
        sql_stmt :=  'select  distinct msi.inventory_item_id '||
	             'from    mtl_system_items msi '||
	             'where   msi.base_item_id is not null '||
                     'and     msi.bom_item_type = 4 '||
                     'and     msi.replenish_to_order_flag = ''Y'' '||
                     'and     msi.pick_components_flag = ''N'' ';

        If p_organization_id is not null Then
           drive_mark := drive_mark + 1;
	   sql_stmt := sql_stmt ||' and msi.organization_id = :p_organization_id';
	End if;
	If p_config_id is not null then
           drive_mark := drive_mark+2;
	   sql_stmt := sql_stmt ||' and msi.inventory_item_id = :p_config_id';
	End if;
	If p_base_model_id is not null then
	   drive_mark := drive_mark+4;
           sql_stmt := sql_stmt || ' and msi.base_item_id = :p_base_model_id';
	End if;

	If p_created_days_ago is not null then
           drive_mark := drive_mark + 8;
	   sql_stmt := sql_stmt || ' and msi.creation_date > trunc(sysdate) - :p_created_days_ago ';
	End if;

	If p_load_type = 1 then
	   sql_stmt := sql_stmt || ' and msi.base_item_id is not null '
	                        || ' and msi.auto_created_config_flag = ''Y''';
	elsif p_load_type = 2 then
           sql_stmt := sql_stmt || ' and msi.base_item_id is not null '
	                        || ' and msi.auto_created_config_flag <> ''Y''';
	else
	   sql_stmt := sql_stmt || ' and msi.base_item_id is not null ';
	End if;

        If PG_DEBUG <> 0 Then
           oe_debug_pub.add('Create_purchasing_doc_batch: Dynamic SqlStmt : '||sql_stmt,1);
	End if;
	If drive_mark = 1 Then
	   OPEN pprollup_cur FOR sql_stmt using p_organization_id;
	elsif drive_mark = 2 then
	   OPEN pprollup_cur FOR  sql_stmt using p_config_id;
	elsif drive_mark = 3 then
	   OPEN pprollup_cur FOR  sql_stmt using p_organization_id,p_config_id;
	elsif drive_mark = 4 then
	   OPEN pprollup_cur FOR  sql_stmt using p_base_model_id;
	elsif drive_mark = 5 then
	   OPEN pprollup_cur FOR  sql_stmt using p_organization_id,p_base_model_id;
	elsif drive_mark = 6 then
	   OPEN pprollup_cur FOR  sql_stmt using p_config_id,p_base_model_id;
	elsif drive_mark = 7 then
	   OPEN pprollup_cur FOR  sql_stmt using p_organization_id,p_config_id,p_base_model_id;
	elsif drive_mark = 8 then
	   OPEN pprollup_cur FOR  sql_stmt using p_created_days_ago;
	elsif drive_mark = 9 then
	   OPEN pprollup_cur FOR  sql_stmt using p_organization_id,p_created_days_ago;
	elsif drive_mark = 10 then
	   OPEN pprollup_cur FOR  sql_stmt using p_config_id,P_created_days_ago;
	elsif drive_mark = 11 then
	   OPEN pprollup_cur FOR  sql_stmt using p_organization_id,p_config_id,p_created_days_ago;
	elsif drive_mark = 12 then
	   OPEN pprollup_cur FOR  sql_stmt using p_base_model_id,p_created_days_ago;
	elsif drive_mark = 13 then
	   OPEN pprollup_cur FOR  sql_stmt using p_organization_id,p_base_model_id,p_created_days_ago;
	elsif drive_mark = 14 then
	   OPEN pprollup_cur FOR  sql_stmt using p_config_id,p_base_model_id,p_created_days_ago;
	elsif drive_mark = 15 then
	   OPEN pprollup_cur FOR  sql_stmt using p_organization_id,p_config_id,p_base_model_id,p_created_days_ago;
	else
	   OPEN pprollup_cur FOR  sql_stmt;
	end if;

      ELSE

	/* sales order number or line id or offset is passed */

        IF PG_DEBUG <> 0 THEN
    	   oe_debug_pub.add('Create_purchase_doc_batch: '||'OE cursor.');
        END IF;

	OPEN pprollup_oe_cur FOR
        SELECT  oel.line_id, oel.inventory_item_id,oel.ato_line_id
        from    oe_order_lines_all oel,
                oe_order_headers_all oeh,
                mtl_system_items msi
        where   oel.inventory_item_id = msi.inventory_item_id
        and     oel.ship_from_org_id = msi.organization_id
        and     oel.header_id = oeh.header_id
        and     oel.source_type_code = 'INTERNAL'   ---- For drop ship bug# 2234858
        and     msi.bom_item_type = 4
        and     oel.open_flag = 'Y'
        and     nvl(oel.cancelled_flag, 'N') = 'N'
        and     oel.schedule_status_code = 'SCHEDULED'
        and     oel.ordered_quantity > 0			-- bugfix 3043284: OQ > 0 is the correct condn instead of OQ-CQ
	and     msi.base_item_id is not null -- 4172156. Added to process only configured ATO items.
        --
        --  Given a Order Line ID
        --
        and   (p_sales_order_line_id is NULL
               or
               oel.ato_line_id = p_sales_order_line_id
	      )--- 4172156. Added condition to pick up ATO item line also.
        --
        --  Given an Order Number
        --
        and     ((p_sales_order is null)
                or
                (p_sales_order is not null
                 and oeh.order_number = p_sales_order))
        --
        --  Given an Organization
        --
        and     (   p_organization_id is null
                 or oel.ship_from_org_id = p_organization_id
                )
        --
        --  Given config
        --
	and   (p_config_id is null or
		msi.inventory_item_id = p_config_id)
        --
        --  Given base model
        --
	and   (p_base_model_id is null or
		msi.base_item_id = p_base_model_id)
        --
        --  Given created days ago
        --
	and   (p_created_days_ago is null or
		msi.creation_date > trunc(sysdate) - p_created_days_ago)
       --
        -- Given Offset days
        --
        and     ((p_offset_days is null)
	/* Bug 5520934 begin: We need to honour bom calendar in offset days calculation */
            -- or (oel.schedule_ship_date <= trunc( sysdate + p_offset_days)))
               or (sysdate >= (select cal.calendar_date
                              from   bom_calendar_dates cal,
                                     mtl_parameters mp
                              where  mp.organization_id = oel.ship_from_org_id
                              and    cal.calendar_code  = mp.calendar_code
                              and    cal.exception_set_id = mp.calendar_exception_set_id
                              and    cal.seq_num = (select cal2.prior_seq_num - nvl(p_offset_days, 0)
                                                    from   bom_calendar_dates cal2
                                                    where  cal2.calendar_code = mp.calendar_code
                                                    and    cal2.exception_set_id = mp.calendar_exception_set_id
                                                    and    cal2.calendar_date    = trunc(oel.schedule_ship_date)))))
        -- end bugfix 5520934
        --
        --  Given load type
        --
	and   (p_load_type is null or
	      (p_load_type = 1
	       and msi.base_item_id is not null
	       and msi.auto_created_config_flag = 'Y') or
	      (p_load_type = 2
	       and msi.base_item_id is not null
	       and msi.auto_created_config_flag <> 'Y') or
	      (p_load_type = 3
	       and msi.base_item_id is not null)
              )
        --
        -- for all the records with the status of REQ-CREATED
        --
        and    (oel.item_type_code = 'CONFIG'
	        or(oel.line_id=oel.ato_line_id
		   --Adding INCLUDED item type code for SUN ER#9793792
		   --and oel.item_type_code in ('STANDARD','OPTION')
		   and oel.item_type_code in ('STANDARD','OPTION','INCLUDED')
		  )
	       )-- 4172156. Added Condition to pickup ATO item Line also
        and    msi.replenish_to_order_flag = 'Y'
	and    oel.ato_line_id is not null			-- bugfix 3164399: although item_type_code will restrict
        and    msi.pick_components_flag = 'N';			-- the criteria, added the ato_line_id for consistency
      end if;

    elsif (p_upgrade = 1 ) then

        IF PG_DEBUG <> 0 THEN
    	   oe_debug_pub.add('Create_purchase_doc_batch: '||'Upgrade');
        END IF;

	if p_perform_rollup = 2 then
	   oe_debug_pub.add('Perform Rollup parameter is set to NO.');
           RETCODE := 0 ;
           conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);
           return;
	end if;

	OPEN pprollup_cur FOR
	select  distinct config_item_id
	from    bom_cto_order_lines_upg
	where   ato_line_id = line_id	-- get only the parent configs
	and     status = 'MRP_SRC';

    end if;


    -- initialize the program_id and the request_id from the concurrent request.
    l_request_id  := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_id  := FND_GLOBAL.CONC_PROGRAM_ID;

    -- update th program_id and requist_id for the lines fetched by the cursor..


    -- Log all the input parameters

    l_stmt_num := 1;
    l_ato_line_id := null;
    LOOP

      	  if (p_sales_order is null AND p_sales_order_line_id is null AND p_offset_days is null) then
		FETCH pprollup_cur INTO ll_inventory_item_id;
		EXIT when pprollup_cur%notfound;
	  else
		FETCH pprollup_oe_cur INTO ll_line_id, ll_inventory_item_id,l_ato_line_id;
		EXIT when pprollup_oe_cur%notfound;
	  end if;

          -- 4172156
          -- The mode will be set to ORDER for ATO model lines.
	  -- For ATO items this will be set to PRECONFIG
	  -- If there is not order specific parameter then this will be set to pre config.

          If ll_line_id = l_ato_line_id then
	     l_mode := 'PRECONFIG';
	     l_ato_line_id := null;  -- We need to have this as null for ATO item lines.
	  elsif ll_line_id is not null then
	     l_mode := 'ORDER';
	  else
	     l_mode := 'PRECONFIG';
	  end if;


          -- count of the records selected by the cursor
          v_rec_count := v_rec_count + 1;

          -- Log all the record being processed.
          IF PG_DEBUG <> 0 THEN
          	oe_debug_pub.add('Create_purchase_doc_batch: '
                                 || '+-------- Processing for --------------------------------------------------+',1);

          	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Sales order         : '||p_sales_order ,1);
          	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Sales Order Line ID : '||to_char(ll_line_id),1);
          	oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Item                : '||to_char(ll_inventory_item_id),1);
          	oe_debug_pub.add('Create_purchase_doc_batch: '
                                 || '+--------------------------------------------------------------------------+',1);
          END IF;

--- 4172156
--- Removed the check hold API call here. Based on the discussion with CTO team, it is decided not to have a
--- hold check in the purchase price rollup batch program. Today, we are not checking for hold for any rollup
--- during auto create config process as well as any of the other optional rollup process.


	  -- Set a savepoint so that we can rollback to this pt if something goes wrong.
	  SAVEPOINT pp_rollup;

	  -- call the purchase doc creation API.
	  CTO_AUTO_PROCURE_PK.Create_purchasing_doc(
						p_config_item_id       => ll_inventory_item_id,
						p_overwrite_list_price => p_overwrite_list_price,
						p_called_in_batch      => 'Y',
						p_batch_number         => l_batch_id,
						x_oper_unit_list       => x_oper_unit_list,
						p_mode                 => l_mode,
						p_ato_line_id          => l_ato_line_id,
						x_return_status        => x_return_status,
						x_msg_count	       => x_msg_count,
						x_msg_data  	       => x_msg_data);

  	      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RETCODE := 1;
    		IF PG_DEBUG <> 0 THEN
    			oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Expected Error in Create_purchasing_doc.',1);
    		END IF;
		err_counter := err_counter + 1;
		erroredItems(err_counter).config_item_id := ll_inventory_item_id;
		ROLLBACK TO pp_rollup;

  	      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add('Create_purchase_doc_batch: ' || 'UnExpected Error in Create_purchasing_doc.',1);
     		END IF;
		ROLLBACK TO pp_rollup;
     		raise FND_API.G_EXC_UNEXPECTED_ERROR;
  	      ELSE
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Successfully processed.',1);
     		END IF;
		pass_counter := pass_counter + 1;
		passedItems(pass_counter).config_item_id := ll_inventory_item_id;
  	      END IF;

       << end_loop >>
	  null;

       END LOOP;

       if pprollup_cur%ISOPEN then
     	  IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Fetched '|| pprollup_cur%ROWCOUNT ||' rows');
     	  END IF;

	  close pprollup_cur;
       end if;

       if pprollup_oe_cur%ISOPEN then
     	  IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Fetched '|| pprollup_oe_cur%ROWCOUNT ||' rows');
     	  END IF;
          close pprollup_oe_cur;
       end if;


       -- Print the successfully processed items..
       if (pass_counter > 0 AND PG_DEBUG <> 0) then
           oe_debug_pub.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ) ;
           oe_debug_pub.add(' Following items are processed successfully while performing Purchase Price Rollup.' ) ;
           oe_debug_pub.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ) ;

	   for j in 1 .. pass_counter
	   loop
	     if ( passedItems(j).config_item_id > 0 )  then

		 declare
		      l_pass_config_description  varchar2(50);
		 begin

	              SELECT substrb(kfv.concatenated_segments,1,35)
		      INTO   l_pass_config_description
		      FROM   mtl_system_items_kfv kfv
		      WHERE  kfv.inventory_item_id = passedItems(j).config_item_id
		      AND    rownum = 1;

		      oe_debug_pub.add (' '|| j ||'.'||'  '|| l_pass_config_description || '(item id '||passedItems(j).config_item_id ||')');

		 exception
		      when OTHERS then
			   oe_debug_pub.add ('**Failed to get description for item id '|| passedItems(j).config_item_id );
		 end;
	     end if;
	   end loop;
           oe_debug_pub.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ) ;
       end if;


       -- Print the errored records..
       if (err_counter > 0 AND PG_DEBUG <> 0) then
           oe_debug_pub.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ) ;
           oe_debug_pub.add(' Following items failed while performing Purchase Price Rollup.' ) ;
           oe_debug_pub.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ) ;

	   for j in 1 .. err_counter
	   loop
	     if ( erroredItems(j).config_item_id > 0 )  then

		 declare
		      l_err_config_description  varchar2(50);
		 begin

	              SELECT substrb(kfv.concatenated_segments,1,35)
		      INTO   l_err_config_description
		      FROM   mtl_system_items_kfv kfv
		      WHERE  kfv.inventory_item_id = erroredItems(j).config_item_id
		      AND    rownum = 1;

		      oe_debug_pub.add (' '|| j ||'.'||'  '|| l_err_config_description ||
					'(item id '||erroredItems(j).config_item_id ||')');

		exception
		      when OTHERS then
			   oe_debug_pub.add ('**Failed to get description for item id '|| erroredItems(j).config_item_id );
		end;
	     end if;
	   end loop;
           oe_debug_pub.add('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++' ) ;
       end if;


       -- Launch the concurrent program as needed

	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Calling Submit_pdoi_conc_prog.');
    	END IF;

      Submit_pdoi_conc_prog(
                                p_oper_unit_list     =>  x_oper_unit_list,
                                p_batch_id           =>  l_batch_id,
                                x_return_status      =>  x_return_status,
                                x_msg_count          =>  x_msg_count,
                                x_msg_data           =>  x_msg_data);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Expected Error in Submit_pdoi_conc_prog.',1);
    	END IF;
     	raise FND_API.G_EXC_ERROR;

      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     	IF PG_DEBUG <> 0 THEN
     		oe_debug_pub.add('Create_purchase_doc_batch: ' || 'UnExpected Error in Submit_pdoi_conc_prog.',1);
     	END IF;
     	raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF RETCODE = 1 THEN
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);

      ELSE
       RETCODE := 0 ;
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);

      END IF;

      IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('Create_purchase_doc_batch: ' || 'Search for the following string to look at the blanket price rollup process log for an item...');
    		oe_debug_pub.add('Create_purchase_doc_batch: ' || 'ROLLUP BLANKETS FOR <item id>');
      END IF;

      COMMIT;

EXCEPTION

      when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Create_purchase_doc_batch:: unexp error::'||l_stmt_num||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );
                RETCODE := 2 ;
                conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

     when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Create_purchase_doc_batch::exp error::'||l_stmt_num||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data);
                RETCODE := 2 ;
                conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

     when others then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Create_purchase_doc_batch::others::'||l_stmt_num||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );
                RETCODE := 2 ;
                conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

END Create_purchase_doc_batch;



Procedure Submit_pdoi_conc_prog(
                                p_oper_unit_list     In         cto_auto_procure_pk.oper_unit_tbl,
                                p_batch_id           In         Number,
                                x_return_status      Out NOCOPY Varchar2,
                                x_msg_count          Out NOCOPY Number,
                                x_msg_data           Out NOCOPY Varchar2) Is

	i		   Number;
	l_request_id       Number;
	xuserid            Number;
	xrespid            Number;
	xRespApplId        Number;
	x_org_id           Number;
        l_release_method   Number;
	l_rel_method_value Varchar2(30);
Begin

		i := p_oper_unit_list.first;

                while (i is not null)
                loop

                        --- Launch the concurrent program
                        oe_debug_pub.add('Submit_pdoi_conc_prog: '||'Launching program for oper unit ='||to_char(p_oper_unit_list(i).oper_unit));
                        oe_debug_pub.add('Submit_pdoi_conc_prog: '||'Batch id = '||to_char(p_batch_id),1);

                        l_release_method := FND_PROFILE.VALUE('CTO_PRICING_RELEASE_METHOD');
                        If l_release_method is null then
                           l_rel_method_value := null;
                           oe_debug_pub.add('Submit_pdoi_conc_prog: '||' Release method is null...',1);
                        elsif l_release_method = 2 then
	 		   l_rel_method_value := 'CREATE_AND_APPROVE'; /* bug#2633259 */
			   oe_debug_pub.add('Submit_pdoi_conc_prog: '||' Release method is Automatic Release ...',1);
                        elsif l_release_method = 1 then
		           l_rel_method_value := 'CREATE';
			   oe_debug_pub.add('Submit_pdoi_conc_prog: '||' Release method is Automatic Release/Review ...',1);
		        elsif l_release_method = 3 then
                           l_rel_method_value := 'MANUAL';
			   oe_debug_pub.add('Submit_pdoi_conc_prog: '||' Release method is Release Using AutoCreate ...',1);
		        end if;

 --                       fnd_client_info.set_org_context(p_oper_unit_list(i).oper_unit);


                        l_request_id := fnd_request.submit_request(
                                                application   => 'PO',
                                                program       => 'POXPDOI',
                                                description   => '',
                                                start_time    => '',
                                                sub_request   => false,
                                                argument1     => '',
                                                argument2     => 'Blanket',
                                                argument3     => '',
                                                argument4     => 'N',
                                                argument5     => 'Y',
                                                argument6     => 'Approved',
                                                argument7     => l_rel_method_value,
                                                argument8     => to_char(p_batch_id),
						argument9     => p_oper_unit_list(i).oper_unit,
                                                argument10    => 'N' ,
						argument11=>'',argument12=>'',argument13=>11,argument14=>'',argument15=>'',
						argument16=>'',argument17=>'',argument18=>'',argument19=>'',argument20=>'',
						argument21=>'',argument22=>'',argument23=>11,argument24=>'',argument25=>'',
						argument26=>'',argument27=>'',argument28=>'',argument29=>'',argument30=>'',
						argument31=>'',argument32=>'',argument33=>11,argument34=>'',argument35=>'',
						argument36=>'',argument37=>'',argument38=>'',argument39=>'',argument40=>'',
						argument41=>'',argument42=>'',argument43=>11,argument44=>'',argument45=>'',
						argument46=>'',argument47=>'',argument48=>'',argument49=>'',argument50=>'',
						argument51=>'',argument52=>'',argument53=>11,argument54=>'',argument55=>'',
						argument56=>'',argument57=>'',argument58=>'',argument59=>'',argument60=>'',
						argument61=>'',argument62=>'',argument63=>11,argument64=>'',argument65=>'',
						argument66=>'',argument67=>'',argument68=>'',argument69=>'',argument70=>'',
						argument71=>'',argument72=>'',argument73=>11,argument74=>'',argument75=>'',
						argument76=>'',argument77=>'',argument78=>'',argument79=>'',argument80=>'',
						argument81=>'',argument82=>'',argument83=>11,argument84=>'',argument85=>'',
						argument86=>'',argument87=>'',argument88=>'',argument89=>'',argument90=>'',
						argument91=>'',argument92=>'',argument93=>11,argument94=>'',argument95=>'',
						argument96=>'',argument97=>'',argument98=>'',argument99=>'',argument100=>''						); /* BUG# 2726167 pass additional parameter to PDOI concurrent program */




                        oe_debug_pub.add('Submit_pdoi_conc_prog: '||'pdoi concurrent request = '||to_char(l_request_id)||' is submitted',1);
                        i := p_oper_unit_list.next(i);

                end loop;

                /*-- Launching the error report
                If p_oper_unit_list.count <> 0 then
                        -- 07/09/2002 It is decided not to lauch the error report along
                        -- With PDOI request. I have removed the call to the error report.
                        -- For time being I am commenting this call. I will remove the call
                        -- Before the patchset.  Please refer to bug # 2365137 for further information


			if p_top_model_line_id is not null then

                        OE_ORDER_CONTEXT_GRP.Set_Created_By_Context (
                                 p_header_id            => NULL
                                ,p_line_id              => p_top_model_line_id
                                ,x_orig_user_id         => xUserId
                                ,x_orig_resp_id         => xRespId
                                ,x_orig_resp_appl_id    => xRespApplId
                                ,x_return_status        => x_Return_Status
                                ,x_msg_count            => x_Msg_Count
                                ,x_msg_data             => x_Msg_Data );
			end if;
                end if;
*/
		empty_ou_global;
End;

Procedure empty_ou_global is
i   Number;
begin

   i := CTO_AUTO_PROCURE_PK.G_oper_unit_list.first;
   while i is not null
   loop
      CTO_AUTO_PROCURE_PK.g_oper_unit_list.delete(i);
      i := g_oper_unit_list.next(i);
   end loop;

end Empty_ou_global;


Procedure process_purchase_price(
                                  p_config_item_id       in      Number,
                                  p_batch_number         in out NOCOPY  number,
				  p_group_id             in      number,
				  p_overwrite_list_price in      varchar2,
				  p_line_id              in      number,
				  p_mode                 in      Varchar2 default 'ORDER',
			          x_oper_unit_list       IN OUT NOCOPY cto_auto_procure_pk.oper_unit_tbl,
				  x_return_status        out NOCOPY    varchar2,
				  x_msg_data             out NOCOPY    varchar2,
				  x_msg_count            out NOCOPY    number) is
	lStmtNumber	 Number;
        x_rolled_price   Number := 0;
	i		 Number;
	l_batch_id       Number;
	l_request_id     Number;
        l_model_item_id  Number;

        Type orgs_list_type is table of number;
        l_orgs_list   orgs_list_type;
        l_list_price     Number;
	l_buy_found      Varchar2(1);
	l_config_creation number;
Begin

        g_pg_level := g_pg_level + 3;
        lstmtNumber := 10;
        if PG_DEBUG <> 0 Then
          oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: Inside Process Purchase Price',5);
        end if;

        lstmtNumber := 20;
           select distinct nvl(fsp.inventory_organization_id,0)
           bulk collect into l_orgs_list
           from   inv_organization_info_v org,
                  financials_system_params_all fsp,
		  mtl_system_items msi
           where  org.organization_id in (select organization_id
                                 from   mtl_system_items_b
                                 where  inventory_item_id = p_config_item_id)
           and    fsp.org_id = org.operating_unit
	   and    msi.inventory_item_id = p_config_item_id
	   and    msi.organization_id = fsp.inventory_organization_id;

           select base_item_id
           into l_model_item_id
           from   mtl_system_items
           where  inventory_item_id = p_config_item_id
           and    rownum = 1;

           If PG_DEBUG <> 0 Then
              oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: Number of Validation orgs = '||l_orgs_list.count,5);
           End if;
           lStmtNumber := 30;
           If l_orgs_list.count <> 0 Then
              for i in l_orgs_list.first..l_orgs_list.last
              Loop
                   oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: Validation org = '||l_orgs_list(i),5);
                   lStmtNumber := 40;
                    Select list_price_per_unit
                    into   l_list_price
                    from   mtl_system_items
                    where  inventory_item_id = p_config_item_id
                    and    organization_id   = l_orgs_list(i);

                    If pg_debug <> 0 Then
                       oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: List price in item master = '||l_list_price,5);
                    End if;
                    -- Renga Talk to val regarding the custom hook

                    x_rolled_price := CTO_CUSTOM_LIST_PRICE_PK.get_list_price(
                                                        p_line_id,
                                                        l_model_item_id,
                                                        l_orgs_list(i));
                    if x_rolled_price is null then

                        --- Call the list price API to rollup the list price of
                        --- this model based on its components selected in OE
                      If l_list_price is null or p_overwrite_list_price = 'Y' Then
                        lStmtNumber     := 30;
                        cto_auto_procure_pk.Rollup_list_price(
                                p_config_item_id => p_config_item_id,
                                p_group_id       => p_group_id,
                                p_org_id         => l_orgs_list(i),
                                x_rolled_price   => x_rolled_price,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data);

                        if x_return_status = FND_API.G_RET_STS_ERROR then
                                IF PG_DEBUG <> 0 THEN
                                   oe_debug_pub.add('Create_Purchasing_Doc: '
                                           || ' Expected error in Rollup_list_procedure',1);
                                END IF;
                                raise FND_API.G_EXC_ERROR;
                        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                                IF PG_DEBUG <> 0 THEN
                                        oe_debug_pub.add('Create_Purchasing_Doc: '
                                                        || ' Unexpected error in rollup_list_price ',1);
                                END IF;
                                raise  FND_API.G_EXC_UNEXPECTED_ERROR;
                        end if;
                      End if; /* l_list_price is null or p_overwrite_list_price = 'Y' */

                        -- added by Renga Kannan on 10/21/03
                        -- The list price comupted by the above API is for per qty for order uom
                        -- We need to get the list price for per qty primary uom

                 End if;
                 -- Update the Mtl_system_items with rolled price in po validation org
                 -- If the p_oerwrite_list_pirce is set to 'N' then only if the list_price is
                 -- null the rolled up price should be updated.

                 lStmtNumber     := 50;
                 If l_list_price is null or p_overwrite_list_price = 'Y' Then
                    If PG_DEBUG <> 0 Then
                       oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: Updating item master with list price ',5);
                    End if;

                    Update Mtl_system_items
                    set    list_price_per_unit = x_rolled_price
                    where  inventory_item_id   = p_config_item_id
                    and    organization_id     = l_orgs_list(i)
                    and    (P_overwrite_list_price = 'Y' or list_price_per_unit is null);
                    If pg_debug <> 0 Then
                       oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: Number of rows updated = '||sql%rowcount,1);
                    End if;
                 End if; /* l_list_price is null or p_overwrite_list_price = 'Y' */
              End Loop;
           End if;
           lStmtNumber     := 60;
	   select config_orgs
	   into   l_config_creation
	   from   mtl_system_items
	   where  inventory_item_id = l_model_item_id
	   and    rownum=1;

      	   If p_mode = 'ORDER' and  nvl(l_config_creation,1) in (1,2) then
	   Begin
              select 'x'
	      into   l_buy_found
	      from   bom_cto_src_orgs
	      where  line_id = p_line_id
	      and    organization_type = 3
	      and    rownum=1;
	   Exception when no_data_found then
	      l_buy_found := 'N';
	   End;
	   If l_buy_found = 'N' then
              oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: Config creation type is 1/2',1);
              oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: No Buy org found',1);
              oe_debug_pub.add(lpad(' ',g_pg_level)||'PROCESS_PURCHASE_PRICE: Config will not be rolled up',1);
	      return;
	   End if;
	End if;

           Rollup_purchase_price (
                                p_batch_id       =>  p_batch_number,
                                p_config_item_id =>  p_config_item_id,
                                p_group_id       =>  p_group_id,
				p_mode           =>  p_mode,
				p_line_id        =>  p_line_id,
                                x_oper_unit_list =>  x_oper_unit_list,
                                x_return_status  =>  x_return_status,
                                x_msg_count      =>  x_msg_count,
                                x_msg_data       =>  x_msg_data);

           if x_return_status = FND_API.G_RET_STS_ERROR then
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Create_Purchasing_Doc: '
		                  || ' Expected error in Rollup_purchase_price procedure',1);
              END IF;
              raise FND_API.G_EXC_ERROR;
           elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Create_Purchasing_Doc: '
                                  || ' Unexpected error in rollup_purchase_price procedure',1);
              EnD IF;
              raise  FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

          g_pg_level := g_pg_level - 3;

exception

        when FND_API.G_EXC_UNEXPECTED_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('PROCESS_PURCHASE_PRICE:: unexp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );
                g_pg_level := g_pg_level - 3;

        when FND_API.G_EXC_ERROR then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('PROCESS_PURCHASE_PRICE::exp error::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data);
                g_pg_level := g_pg_level - 3;

        when others then
                IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('PROCESS_PURCHASE_PRICE::others::'||lStmtNumber||sqlerrm,1);
                END IF;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );
                g_pg_level := g_pg_level - 3;
End Process_purchase_price;



PROCEDURE load_lines_into_bcolt(p_sales_order_line_id NUMBER,
                                p_sales_order NUMBER,
			        p_organization_id VARCHAR2,
			        p_offset_days NUMBER,
				x_return_status OUT NOCOPY VARCHAR2) IS
    sql_stmt            VARCHAR2(5000);
    drive_mark          NUMBER := 0;
    l_organization_id   Number;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_organization_id := p_organization_id;

    -- rkaza. ireq project. 05/06/2005.
    -- Do not select lines that are in INTERNAL_REQ_REQUESTED status.
    -- Added it to the where clause along with PO_REQ_REQUESTED clause
    drive_mark := 0;
    sql_stmt :=  'INSERT INTO bom_cto_order_lines_temp (line_id, org_id, status, inventory_item_id)'||
                 'select oel.line_id, oel.org_id, 1, 0 '||
                 'from    oe_order_lines_all oel,'||
                 '        mtl_system_items msi,'||
                 '        wf_item_activity_statuses was,'||
                 '        wf_process_activities WPA ';

     sql_stmt := sql_stmt || ' where   oel.inventory_item_id = msi.inventory_item_id ' ||
                             'and     oel.ship_from_org_id = msi.organization_id ' ||
                             'and     oel.source_type_code = ''INTERNAL'' '||
                             'and     msi.bom_item_type = 4 ' ||
                             'and     oel.open_flag = ''Y'' '||
                             'and    (oel.cancelled_flag is null ' ||
                             '           or oel.cancelled_flag = ''N'') '||
                             'and     oel.booked_flag = ''Y'' '||
                             'and     oel.schedule_status_code = ''SCHEDULED'' '||
                             'and     oel.ordered_quantity > 0 ' ||
 		             'and    cto_auto_procure_pk.get_reserved_qty(oel.line_id)- nvl(oel.shipped_quantity,0) < oel.ordered_quantity '||
                             'and    nvl (oel.shipped_quantity, 0) = 0 '||
                             --Bugfix 9689936
			     --'and    oel.flow_status_code not in ( ''EXTERNAL_REQ_REQUESTED'',''INTERNAL_REQ_REQUESTED'',''AWAITING_SHIPPING'',''SHIPPED'',''PICKED'') '||
			     --Bugfix 10235354
			     'and    oel.flow_status_code not in ( ''AWAITING_SHIPPING'',''SHIPPED'',''PICKED'') '||
                             'and    msi.replenish_to_order_flag = ''Y'' '||
                             'and    oel.ato_line_id is not null ' ||
                             'and    (oel.item_type_code = ''CONFIG'' '||
                             '        or (oel.ato_line_id=oel.line_id '||
                             --Adding INCLUDED item type code for SUN ER#9793792
			     --'             and oel.item_type_code in (''STANDARD'', ''OPTION''))) '||
			     '             and oel.item_type_code in (''STANDARD'', ''OPTION'', ''INCLUDED''))) '||
                             'and    msi.pick_components_flag = ''N'' '||
                             'and    was.item_type = ''OEOL'' '||
                             'and    was.activity_status = ''NOTIFIED'' '||
                             'and    was.item_type = wpa.activity_item_type  '||
                             'and    was.process_activity = wpa.instance_id '||
                             'and    wpa.activity_name in '||
                             ' (''EXECUTECONCPROGAFAS'', ''CREATE_SUPPLY_ORDER_ELIGIBLE'', ''SHIP_LINE'', ''WAIT_FOR_PO_RECEIPT'')  ';

     /*  We want to do an explicit to_char() when order_number or line_id
         *  parameter is passed because we are driving from OEL->WAS. If we are driving
         *  from WF tables into OE then to_char() should not be used.
         *
         *  Here, the problem was because of the implicit type conversion that was happening on the WAS side.
         *  That was preventing the item_key column of the WAS PK index from being used during index access.
         *  It was effectively using the index only on the item_type column and that is the reason why it was slow.
     */

     if p_sales_order is null and p_sales_order_line_id is null then
          sql_stmt := sql_stmt ||' and    was.item_key = oel.line_id ' ;
     else
          sql_stmt := sql_stmt ||' and    was.item_key = to_char(oel.line_id) ' ;
     end if;

     /*  Given an Order Number */
      -- Do we really need to validate against mtl_sales_orders and oe_transaction_types_tl ?
      -- Will there at all exist any order_number in oe_order_header which shall ever fail this validation ?
     if p_sales_order is not null then
          drive_mark := drive_mark + 1;
          sql_stmt := sql_stmt || ' and  oel.header_id  in' ||
                                  '         (select oeh.header_id '||
                                  '          from   oe_order_headers_all oeh, '||
                                  '                 oe_transaction_types_tl oet, '||
                                  '                 mtl_sales_orders mso '||
                                  '          where  oeh.order_number = to_char( :p_sales_order) '||
                                  '          and    oeh.order_type_id = oet.transaction_type_id '||
                                  '          and    mso.segment1 = to_char(oeh.order_number) '||
                                  '          and    mso.segment2 = oet.name '||
                                  '          and    oet.language = (select language_code '||
                                  '                                 from fnd_languages '||
                                  '                                 where installed_flag = ''B'') ' ||
                                  '          ) ' ;
      end if;

      /*  Given a Order Line ID */
      if p_sales_order_line_id is not null then
         drive_mark := drive_mark + 2;
         sql_stmt := sql_stmt ||' and  oel.line_id in (select oelc.line_id '||
                                                     'from   oe_order_lines_all oelc '||
                                                     'where  oelc.ato_line_id = :p_sales_order_line_id '||
                                                     'and    (oelc.item_type_code = ''CONFIG'' '||
                                                     --Adding INCLUDED item type code for SUN ER#9793792
						     --'        or     (oelc.item_type_code in (''STANDARD'',''OPTION'') '||
						     '        or     (oelc.item_type_code in (''STANDARD'',''OPTION'',''INCLUDED'') '||
                                                     '                and ato_line_id = line_id)) '||
                                                     ') ';
      end if;

      /*  Given an Organization */
      if p_organization_id is not null then
         drive_mark := drive_mark + 4;
         sql_stmt := sql_stmt ||' and  oel.ship_from_org_id = :l_organization_id ';
      end if;

      /* Given Offset days  */
      if p_offset_days is not null then
         drive_mark := drive_mark + 8;
         --sql_stmt := sql_stmt ||' and  oel.schedule_ship_date <= trunc( sysdate + :p_offset_days) ';
	/* Bug 5520934 : We need to honour bom_calendar in offset days calculation */
         sql_stmt := sql_stmt ||' and sysdate >= (select cal.calendar_date
                              from   bom_calendar_dates cal,
                                     mtl_parameters mp
                              where  mp.organization_id = oel.ship_from_org_id
                              and    cal.calendar_code  = mp.calendar_code
                              and    cal.exception_set_id = mp.calendar_exception_set_id
                              and    cal.seq_num = (select cal2.prior_seq_num - nvl(:p_offset_days, 0)
                                                    from   bom_calendar_dates cal2
                                                    where  cal2.calendar_code = mp.calendar_code
                                                    and    cal2.exception_set_id = mp.calendar_exception_set_id
                                                    and    cal2.calendar_date    = trunc(oel.schedule_ship_date))) ';
      end if;

      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add ('The dyanamic sql generated is');
         oe_debug_pub.add ('SQL: ' || substr(sql_stmt,1, 1500));
         oe_debug_pub.add (substr(sql_stmt,1501,3000));
         oe_debug_pub.add ('The drive_mark is '||drive_mark);
      END IF;

      /*
        Below, we execute the sql statement according to which parameters
        we have selected.  The drive_mark variable tells us which parameters
        we are using, so we are sure to send the right ones to SQL.
      */

      if (drive_mark = 0) then
	-- No (optional) parameter is passed
	  EXECUTE IMMEDIATE  sql_stmt;

      elsif (drive_mark = 1) then
        -- Only Order_Number is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order;

      elsif (drive_mark = 2) then
	-- Only Line_Id is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order_line_id;

      elsif (drive_mark = 3) then
	-- Order Number and Line_Id is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order, p_sales_order_line_id;

      elsif (drive_mark = 4) then
	-- Only Orgn_Id is passed
	  EXECUTE IMMEDIATE sql_stmt USING l_organization_id;

      elsif (drive_mark = 5) then
	-- Order_Number and Orgn_Id is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order, l_organization_id;

      elsif (drive_mark = 6) then
	-- Line_id and Orgn_Id is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order_line_id, l_organization_id;

      elsif (drive_mark = 7) then
	-- Order_number, Line_Id and Orgn_Id is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order, p_sales_order_line_id, l_organization_id;

      elsif (drive_mark = 8) then
	-- Offset_Days is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_offset_days;

      elsif (drive_mark = 9) then
	-- Order_Number and Offset_Days is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order, p_offset_days;

      elsif (drive_mark = 10) then
	-- Line_id and Offset_Days is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order_line_id, p_offset_days;

      elsif (drive_mark = 11) then
	-- Order_Number, Line_id and Offset_Days is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order, p_sales_order_line_id, p_offset_days;

      elsif (drive_mark = 12) then
	-- Organization_id and Offset_Days is passed
	  EXECUTE IMMEDIATE sql_stmt USING l_organization_id, p_offset_days;

      elsif (drive_mark = 13) then
	-- Order_Number, Organization_id and Offset_Days is passed
          EXECUTE IMMEDIATE sql_stmt USING p_sales_order, l_organization_id, p_offset_days;

      elsif (drive_mark = 14) then
	-- Line_id, Organization_id and Offset_Days is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order_line_id, l_organization_id, p_offset_days;

      elsif (drive_mark = 15) then
	-- Order_Number, Line_id, Organization_id and Offset_Days is passed
	  EXECUTE IMMEDIATE sql_stmt USING p_sales_order, p_sales_order_line_id, l_organization_id, p_offset_days;

      else
	  oe_debug_pub.add ('INCORRECT COMBINATION of parameters');

      end if;


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('load_lines_into_bcolt: ' || 'no. of records in temp table '||SQL%ROWCOUNT,1);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        oe_debug_pub.add('load_lines_into_bcolt: ' || 'others excpn::'||sqlerrm,1);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END load_lines_into_bcolt;


PROCEDURE update_bcolt_line_status(p_line_id NUMBER,
                                   p_status NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2) IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   update bom_cto_order_lines_temp
   set status = p_status
   where line_id = p_line_id;

EXCEPTION
    WHEN OTHERS THEN
        oe_debug_pub.add('update_bcolt_line_status: ' || 'others excpn::'||sqlerrm,1);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END update_bcolt_line_status;


--local procedure
--Get chage and accrual account information from OPM
--OPM
Procedure Get_opm_charge_account(p_interface_source_line_id   NUMBER
                                ,p_item_id         NUMBER
			        ,p_destination_org_id NUMBER
				,p_source_type_code   VARCHAR2
			        ,p_operating_unit     NUMBER
			        ,x_charge_account_id  OUT NOCOPY NUMBER
			        ,x_accrual_account_id OUT NOCOPY NUMBER
				,x_return_status      OUT NOCOPY VARCHAR2)
IS
  l_source_subinventory VARCHAR2(200) := null;
  l_vendor_id           NUMBER;
  l_vendor_site_id    NUMBER;
  l_sourcing_rule_id    NUMBER;
  l_sourcing_org        NUMBER;
  --Bugfix 8843940
  --l_error_message       VARCHAR2(200);
  l_error_message       VARCHAR2(500);
  l_return_code         BOOLEAN;
  l_category_id       NUMBER;
  l_cust_site_id      NUMBER;
  l_cust_id           NUMBER;
  l_return_status     Varchar2(1);
  l_msg_data          Varchar2(2000);
  l_msg_count         number;
  l_stmt_num          number;


BEGIN


        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_interface_source_line_id IS NOT NULL THEN
          --line id is available only for top level configurations


	   l_stmt_num := 10;
	   SELECT  end_customer_id,
	           end_customer_site_use_id
           INTO    l_cust_id,
	           l_cust_site_id
           FROM    oe_order_lines_all
	   WHERE    line_id = p_interface_source_line_id;

	    IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('Get_opm_charge_account: ' || 'Customer ID : '||to_char(l_cust_id),3);
	      oe_debug_pub.add('Get_opm_charge_account: ' || 'customer site ID : '||to_char(l_cust_site_id),3);
            END IF;




	END IF;



        l_stmt_num := 20;
	SELECT mic.category_id
	INTO   l_category_id
        FROM mtl_item_categories mic,
             mtl_default_sets_view mdsv
        WHERE mic.inventory_item_id = p_item_id
        AND mic.organization_id=p_destination_org_id
        AND mic.category_set_id = mdsv.category_set_id
        AND mdsv.functional_area_id = 2;

	IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('Get_opm_charge_account: ' || 'Category id: '||to_char(l_category_id),5);
        END IF;


	--added this api after taking to divya reddy(PO)
	--All the values being passed are verified by Indira Choudhuri of MRP team
	--Dependency: this MRP API exists since 11.5.10 MRP code
	--arg_commodity_id value is not used within api as per Indira but
	--inorder to be consistent will pass it as done by PO.

	l_stmt_num := 30;
	IF PG_DEBUG <> 0 THEN
              oe_debug_pub.add('Get_opm_charge_account: ' || 'Calling MRP_SOURCING_API_PK.mrp_sourcing',5);
        END IF;
	--call mrp_sourcing to get vendor and vendor_site_id
	l_return_code := MRP_SOURCING_API_PK.mrp_sourcing(
               arg_mode		            =>p_source_type_code,
               arg_item_id	            =>p_item_id,
               arg_commodity_id		    =>l_category_id,
               arg_dest_organization_id     =>p_destination_org_id,
               arg_dest_subinventory	    =>null,
               arg_autosource_date	    =>sysdate,
               arg_vendor_id		    =>l_vendor_id,
               arg_vendor_site_id	    =>l_vendor_site_id,
               arg_source_organization_id   =>l_sourcing_org,
               arg_source_subinventory 	    =>l_source_subinventory,
               arg_sourcing_rule_id 	    =>l_sourcing_rule_id,
               arg_error_message 	    =>l_error_message);

	IF l_return_code THEN
            IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add('Get_opm_charge_account: ' || 'success from MRP_SOURCING_API_PK.mrp_sourcing',3);
              oe_debug_pub.add('Get_opm_charge_account: ' || 'Vendor ID : '||to_char(l_vendor_id),3);
	      oe_debug_pub.add('Get_opm_charge_account: ' || 'Vendor site ID : '||to_char(l_vendor_site_id),3);
            END IF;


	ELSE
           IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('Get_opm_charge_account:'||'Failed in MRP_SOURCING_API_PK.mrp_sourcing' ,1);
             oe_debug_pub.add('Get_opm_charge_account:'||l_error_message,1);
	     --talked to usha arora. This error is not important enough to
	     --stop process
             oe_debug_pub.add('Get_opm_charge_account:'||'Ignoring above error and proceeding further',1);
           END IF;
	END IF;

        --updating the global record structure variable
        GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).organization_id   := p_destination_org_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).inventory_item_id := p_item_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).ato_flag          := 'Y';
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).operating_unit    := p_operating_unit;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).vendor_id         := l_vendor_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).vendor_site_id    := l_vendor_site_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).customer_id       := l_cust_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).customer_site_id  := l_cust_site_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).account_type_code := GMF_transaction_accounts_PUB.G_CHARGE_INV_ACCT;

	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).organization_id   := p_destination_org_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).inventory_item_id := p_item_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).ato_flag          := 'Y';
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).operating_unit    := p_operating_unit;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).vendor_id         := l_vendor_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).vendor_site_id    := l_vendor_site_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).customer_id       := l_cust_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).customer_site_id  := l_cust_site_id;
	GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).account_type_code := GMF_transaction_accounts_PUB.G_ACCRUAL_ACCT;



        l_stmt_num := 40;
	IF PG_DEBUG <> 0 THEN
	  oe_debug_pub.add('Get_opm_charge_account: ' || 'calling GMF_transaction_accounts_PUB.get_accounts',5);

        END IF;
        --SLA api to get charge and accrual account
	--Reference aru#4610085
        GMF_transaction_accounts_PUB.get_accounts
	(
           p_api_version   => 1.0
	 , p_init_msg_list => null
	 , p_source        => 'CTO'
	 , x_return_status => l_return_status
         , x_msg_data      => l_msg_data
         , x_msg_count     => l_msg_count

	);

	IF l_return_status = FND_API.G_RET_STS_SUCCESS then
	   --i.e.charge account id is
	   x_charge_account_id := GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(1).target_ccid;

           IF x_charge_account_id IS NULL THEN
              IF PG_DEBUG <> 0 THEN
           	      oe_debug_pub.add('Get_opm_charge_account: ' || 'charge account id is NULL in opm org',1);
	              oe_debug_pub.add('Get_opm_charge_account: ' || 'USER SHOULD CHECK THE SETUP',1);
              END IF;


	   END IF;

	   x_accrual_account_id := GMF_transaction_accounts_PUB.g_gmf_accts_tab_CTO(2).target_ccid;

           IF PG_DEBUG <> 0 THEN
	      oe_debug_pub.add('Get_opm_charge_account: ' || 'success from GMF_transaction_accounts_PUB.get_accounts',3);
              oe_debug_pub.add('Get_opm_charge_account: ' || 'opm sla charge acct  : '||to_char(x_charge_account_id),1);
	      oe_debug_pub.add('Get_opm_charge_account: ' || 'opm sla accrual acct : '||to_char(x_accrual_account_id),1);
           END IF;


	ELSE
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
     IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('Get_opm_charge_account: ' || 'Get_opm_charge_account::exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
     END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF PG_DEBUG <> 0 THEN
         oe_debug_pub.add('Get_opm_charge_account: ' || 'Get_opm_charge_account::unexp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 WHEN OTHERS THEN
      IF PG_DEBUG <> 0 THEN
          oe_debug_pub.add('Get_opm_charge_account: ' || 'Get_opm_charge_account::others error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Get_opm_charge_account;




END cto_auto_procure_pk;

/
