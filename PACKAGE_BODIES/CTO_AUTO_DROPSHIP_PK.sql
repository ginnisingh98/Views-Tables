--------------------------------------------------------
--  DDL for Package Body CTO_AUTO_DROPSHIP_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_AUTO_DROPSHIP_PK" AS
/*$Header: CTODROPB.pls 120.3.12010000.2 2010/07/21 07:48:23 abhissri ship $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTODROPB.pls                                                  |
| DESCRIPTION:                                                                |
|               Contain all CTO and WF related APIs for AutoCreate Purchase   |
|               Requisitions. This Package creates the following              |
|               Procedures                                                    |
|               1. AUTO_CREATE_DROPSHIP                                       |
|               Functions                                                     |
| HISTORY     :                                                               |
| 22-FEB-2002 : Created By Sushant Sawant                                     |
|                                                                             |
|              Modified on 14-MAY-2002 by Sushant Sawant                      |
|                                         Fixed Bug 2367220                   |
| 17-DEC-2003 : Bugfix 3319313                                                |
|               - fixed source code issue                                     |
|               - fixed OQ-CQ issue in the cursor                             |
|               - Replaced fnd_file with oe_debug_pub for consistency         |
| 01-Jun-2005 : Renga Kannan   Added NOCOPY HINT for all out parameters.

| 05-Jul-2005 : Renga Kannan   Modified code for MOAC project
|                                                                             |
|                                                                             |
=============================================================================*/

   g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_AUTO_DROPSHIP_PK';
   gMrpAssignmentSet        NUMBER ;


/**************************************************************************
   Procedure:   AUTO_CREATE_DROPSHIP
   Parameters:  p_sales_order             NUMBER    -- Sales Order number.
                p_dummy_field             VARCHAR2  -- Dummy field for the Concurrent Request.
                p_sales_order_line_id     NUMBER    -- Sales Order Line number.
                p_organization_id         VARCHAR2  -- Ship From Organization ID.
                current_organization_id   NUMBER    -- Current Org ID
                p_offset_days             NUMBER    -- Offset days.

   Description: This procedure is called from the concurrent progran to run the
                AutoCreate DropShip Requisitions.
*****************************************************************************/
PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

PROCEDURE auto_create_dropship (
           errbuf              OUT NOCOPY   VARCHAR2,
           retcode             OUT NOCOPY   VARCHAR2,
           p_sales_order             NUMBER,
           p_dummy_field             VARCHAR2,
           p_sales_order_line_id     NUMBER,
           p_organization_id         VARCHAR2,
           current_organization_id   NUMBER, -- VARCHAR2,
           p_offset_days             NUMBER ) AS


-- following cursor will select the sales order lines to be processed.
-- it will pick all the Booked and scheduled Orders for ATO items.
-- with WF status at
-- for the parameters   Organization_id, Sales Order Number, Sales Order line id
-- with in the specified number of Offset days

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Bug 4574073: Performance issue: Removed the cursor and changed to dyanamic
sql which would join only the required tables to improve performance. Also, we
will drive from Oe table to workflow tables if lineid or order number are passed.
Other wise drive from workflow table to oe table. This is to enable effective use
of the index on item_type, item_key on wf_item_activity_statuses.
Locking issue: This happens when this program is run in parallel with AutoCreate
Purchase requisition. To reduce record_locked exceptions to bare minimum, we will
process from a array and commit after each record.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
   -- local variables
    p_po_quantity             NUMBER := NULL;
    l_stmt_num                NUMBER;
    p_dummy                   VARCHAR2(2000);
    lSourceCode               VARCHAR2(100);
    v_rsv_quantity            NUMBER(8,2);
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
    p_new_order_quantity      NUMBER(8,2);
    l_res                     BOOLEAN;
    l_batch_id                NUMBER;
    v_activity_status_code    VARCHAR2(10);
    l_inv_quantity            NUMBER;

    l_request_id         NUMBER;
    l_program_id         NUMBER;
    l_source_document_type_id    NUMBER;
    l_wip_org_id         NUMBER ;

    l_active_activity   VARCHAR2(8);
    l_current_org_id    Number;   -- MOAC change

    xuserid             Number;
    xrespid             number;
    xrespapplid         Number;
    x_msg_count         Number;
    x_msg_data          Varchar2(1000);
    -- bug4574073 : new variables.
    sql_stmt            VARCHAR2(5000);
    drive_mark          NUMBER := 0;
    i                   NUMBER;
    dummy               NUMBER;
    indx                NUMBER;

    record_locked       EXCEPTION;
    pragma exception_init (record_locked, -54);
    /*invalid_cursor      EXCEPTION;
    pragma exception_init (invalid_cursor, -1001);

    Type lines_rec_type is record
    (
    line_id number,
    org_id number,
    ship_from_org_id number,
    schedule_ship_date date
    );
    eligible_lines_rec lines_rec_type;
    TYPE eligibleCurTyp is REF CURSOR ;
    eligible_lines      eligibleCurTyp;*/

    TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE date_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    line_id_arr           num_tab;
    org_id_arr            num_tab;
    ship_from_org_id_arr  num_tab;
    schedule_ship_date_arr date_tab;
BEGIN

    -- initialize the program_id and the request_id from the concurrent request.
    l_request_id  := FND_GLOBAL.CONC_REQUEST_ID;
    l_program_id  := FND_GLOBAL.CONC_PROGRAM_ID;

    -- set the return status.
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- Set the return code to success

    RETCODE := 0;

    lSourceCode := FND_PROFILE.VALUE('ONT_SOURCE_CODE');		--bugfix 3319313
    IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('l_source_code = '||lsourcecode);
    END IF;

    -- set the batch_id to the request_id
    l_batch_id    := FND_GLOBAL.CONC_REQUEST_ID;

    -- Log all the input parameters
    l_stmt_num := 1;

    -- for all the sales order lines (entered, booked )
    -- Given parameters.
    IF PG_DEBUG <> 0 THEN
      oe_debug_pub.add('+---------------------------------------------------------------------------+');
      oe_debug_pub.add('+------------------  Parameters passed into the procedure ------------------+');
      oe_debug_pub.add('Sales order                : '||p_sales_order );
      oe_debug_pub.add('Sales Order Line ID[Model] : '||to_char(p_sales_order_line_id));
      oe_debug_pub.add('Organization_id            : '||p_organization_id);
      oe_debug_pub.add('Offset Days                : '||to_char(p_offset_days));
      oe_debug_pub.add('+---------------------------------------------------------------------------+');
    END IF;

    l_organization_id := p_organization_id;

    -- Open loop for selecting all the eligible lines.
    -- Opening the cursor. This cursor selects the eligible oe lines based on the

       l_organization_id := p_organization_id;

/******************Begin Bugfix 4384668 ***************************************/
/*
NOTE: We are doing a insert into bom_cto_order_lines_temp select .... using dyanamic sql
followed by a select ...bulk collect... from bom_cto_order_lines_temp. A more efficient
approach would be to do a direct select..bulk collect.. from oe_order_lines...
in the dyanamic sql instead of going via the GTT. However bulk collect with dyanamic sql
is supported 9i onwards. For 11.5.9, we need to make it compatible with 8i database as well.
This restriction may not be there in R12. Please keep this in mind while front porting.
*/

     delete from bom_cto_order_lines_temp;

     drive_mark := 0;
     sql_stmt := 'INSERT INTO bom_cto_order_lines_temp (line_id, org_id, ship_from_org_id, schedule_ship_date, inventory_item_id) '||
                 'SELECT  oel.line_id, oel.org_id, oel.ship_from_org_id, oel.schedule_ship_date, 1 '||
                 'from    oe_order_lines_all oel, '||
                 '        mtl_system_items msi, '||
                 '        wf_item_activity_statuses was, '||
                 '        wf_process_activities WPA '||
                 'where   oel.inventory_item_id = msi.inventory_item_id '||
                 'and     oel.ship_from_org_id = msi.organization_id '||
                 'and     oel.source_type_code = ''EXTERNAL'' '||
                 'and     msi.bom_item_type = 4 '||
                 'and     oel.open_flag = ''Y'' '||
                 'and    (oel.cancelled_flag is null '||
                 '        or oel.cancelled_flag = ''N'') '||
                 'and    oel.booked_flag = ''Y'' '||
                 'and    oel.ordered_quantity > 0 '||
                 'and    msi.replenish_to_order_flag = ''Y'' '||
                 'and    msi.pick_components_flag = ''N'' '||
                 'and    was.item_type = ''OEOL'' '||
                 'and    was.activity_status = ''NOTIFIED'' '||
                 'and    was.item_type = wpa.activity_item_type  '||
                 'and    was.process_activity = wpa.instance_id '||
                 'and    wpa.activity_name in '||
                 '(''EXECUTECONCPROGAFAS'', ''CREATE_SUPPLY_ORDER_ELIGIBLE'', ''PURCHASE RELEASE ELIGIBLE'') ';

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
                                  '                                 from fnd_languages'||
                                  '                                 where installed_flag = ''B'')' ||
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
        sql_stmt := sql_stmt ||' and (SYSDATE + nvl(:p_offset_days, 0)) >=  '||
                            '(select CAL.CALENDAR_DATE '||
                            ' from   bom_calendar_dates cal, '||
                            '        mtl_parameters     mp '||
                            ' where  mp.organization_id = oel.ship_from_org_id '||
                            ' and    cal.calendar_code  = mp.calendar_code '||
                            ' and    cal.exception_set_id =  mp.calendar_exception_set_id '||
                            ' and    cal.seq_num = '||
                            '          (select cal2.prior_seq_num - '||
                            '                 (ceil(nvl(msi.fixed_lead_time,0) + '||
                            '                       nvl(msi.variable_lead_time,0) * '||
                            '                       INV_CONVERT.inv_um_convert '||
                            '                          (oel.inventory_item_id, '||
                            '                           null, '||
                            '                           oel.ordered_quantity , '||
                            '                           oel.order_quantity_uom, '||
                            '                           msi.primary_uom_code, '||
                            '                           null, '||
                            '                           null) '||
                            '                  )) '||
                            '           from   bom_calendar_dates cal2 '||
                            '           where  cal2.calendar_code = mp.calendar_code '||
                            '           and    cal2.exception_set_id = mp.calendar_exception_set_id '||
                            '          and    cal2.calendar_date =trunc(oel.schedule_ship_date) '||
                            '          )) ';

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
	   EXECUTE IMMEDIATE sql_stmt;

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

     select line_id, org_id, ship_from_org_id, schedule_ship_date
     BULK COLLECT INTO line_id_arr, org_id_arr, ship_from_org_id_arr, schedule_ship_date_arr
     from bom_cto_order_lines_temp;
 i := line_id_arr.first;
     WHILE i is not null
     /*
       -- Open loop for selecting all the eligible lines.
       -- Opening the cursor. This cursor selects the eligible oe lines based on the
       FOR so_line IN oe_lines_cur (
                        p_sales_order,
                        p_sales_order_line_id,
                        l_organization_id,
                        p_offset_days)   */
      Loop
          -- count of the records selected by the cursor
          v_rec_count := v_rec_count + 1;

          -- Log all the record being processed.
          IF PG_DEBUG <> 0 THEN
             oe_debug_pub.add('+-------- Processing for --------------------------------------------------+');
             oe_debug_pub.add('Sales order                 : '||p_sales_order );
             oe_debug_pub.add('Sales Order Line ID[Config] : '||to_char(line_id_arr(i)));
             oe_debug_pub.add('Ship from Org               : '||to_char(ship_from_org_id_arr(i)));
	  END IF;

          l_stmt_num := 10;

         --  bug 4384668: First check if the line is locked by another process. If locked then
          --  continue processing for the next line
          savepoint begin_line;
          begin
             select line_id into dummy
             from   oe_order_lines_all
             where  line_id = line_id_arr(i)
             and    source_type_code = 'EXTERNAL'
             and    open_flag = 'Y'
             and    booked_flag = 'Y'
             and    ordered_quantity > 0
             and    (cancelled_flag is null
                     or cancelled_flag = 'N')
             and    ship_from_org_id = ship_from_org_id_arr(i)
             and    schedule_ship_date = schedule_ship_date_arr(i)
             FOR UPDATE NOWAIT;
          exception
             when record_locked then
             IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('This line is locked by another process ');
             END IF;
             goto EndOfLoop;

             when no_data_found then
             IF PG_DEBUG <> 0 THEN
                  oe_debug_pub.add('This line is no longer eligible for processing ');
             END IF;
             goto EndOfLoop;

          end;
          --  end bug 4384668

          --  bugfix 3319313: update all lines with the program ID and request_id here.
          update  oe_order_lines_all
          set     program_id = l_program_id,
                  request_id = l_request_id
          where   line_id = line_id_arr(i);

          l_stmt_num := 50;
          -- Added by Renga Kannan for MOAC project
          -- switch the org context if the context is different

          l_current_org_id := nvl(MO_GLOBAL.get_current_org_id,-99);

          If l_current_org_id <> org_id_arr(i) then

             OE_ORDER_CONTEXT_GRP.set_created_by_context(
                                     p_header_id   => null,
                                     p_line_id     => line_id_arr(i),
                                     x_orig_user_id => xUserId,
                                     x_orig_resp_id => xRespId,
                                     x_orig_resp_appl_id => xrespapplid,
                                     x_return_status      => x_return_status,
                                     x_msg_count         => x_msg_count,
                                     x_msg_data          => x_msg_data);
            If x_return_status = FND_API.G_RET_STS_ERROR then
               if PG_DEBUG <> 0 then
                  oe_debug_pub.add('Set_created_by_context API ended with expected error',1);
               end if;
               raise  FND_API.G_EXC_ERROR;
            elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               if PG_DEBUG <> 0 then
                  oe_debug_pub.add('Set_created_by_context API ended with unexpected error',1);
               end if;
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
            end if; /*x_return_staus = FND_API.G_EXC_ERROR */
            l_current_org_id := org_id_arr(i);
          End if; /* l_current_org_id <> so_lines.org_id */

	  -- We just need to push the workflow further. Workflow will take care of rest.

          -- We need to update the workflow status only if the
          -- status is in CREATE_SUPPLY_ORDER_ELIGIBLE

          CTO_WORKFLOW_API_PK.query_wf_activity_status( 'OEOL' ,
                                                          line_id_arr(i) ,
                                                          'CREATE_SUPPLY_ORDER_ELIGIBLE',
                                                          'CREATE_SUPPLY_ORDER_ELIGIBLE',
                                                          l_active_activity );

          IF l_active_activity = 'NOTIFIED' THEN

                l_stmt_num := 60;
                l_res := cto_workflow_api_pk.complete_activity(
                                                     p_itemtype=>'OEOL',
                                                     p_itemkey =>line_id_arr(i),
                                                     p_activity_name=>'CREATE_SUPPLY_ORDER_ELIGIBLE',
                                                     p_result_code=>'COMPLETE');
                IF NOT l_res THEN
                 oe_debug_pub.add('auto_create_dropship: ' || 'Error occurred in updating the workflow status - Stmt_num'||to_char(l_stmt_num),1);
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

          ELSE

                l_stmt_num := 70;

                -- We need to update the workflow status only if the
                -- status is in PURCHASE RELEASE ELIGIBLE

                CTO_WORKFLOW_API_PK.query_wf_activity_status( 'OEOL' ,
                                                          line_id_arr(i) ,
                                                          'PURCHASE RELEASE ELIGIBLE',
                                                          'PURCHASE RELEASE ELIGIBLE',
                                                          l_active_activity );
                IF l_active_activity = 'NOTIFIED' THEN

                   l_res := cto_workflow_api_pk.complete_activity(
                                                     p_itemtype=>'OEOL',
                                                     p_itemkey =>line_id_arr(i),
                                                     p_activity_name=>'PURCHASE RELEASE ELIGIBLE',
                                                     p_result_code=>'COMPLETE');

                  IF NOT l_res THEN
                    oe_debug_pub.add('auto_create_dropship: ' || 'Error occurred in updating the workflow status - Stmt_num'||to_char(l_stmt_num),1);
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                END IF;
          END IF;

       --bug 4384668: Added the commit
          commit;   -- This shall release the lock. Since we are processing from array, snapshot errors will not occur.
          <<EndOfLoop>>
          i := line_id_arr.next(i);  --4384668

    END LOOP; -- Sales Order Lines.

    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add('+---------------------------------------------------------------------------+');
       oe_debug_pub.add('The Batch ID for this run was : '||to_char(l_batch_id));
       oe_debug_pub.add('+---------------------------------------------------------------------------+');
       oe_debug_pub.add('Number of records Processed  : '||to_char(v_rec_count));
    END IF;

    -- The following part of the code
    -- is modified by Renga Kannan on 11/12/01
    -- In the case of RETCODE = 1 it should complete the batch program with Warning

    IF RETCODE = 1 THEN

       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',Current_Error_Code);

    ELSE

       RETCODE := 0 ;
       conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',Current_Error_Code);

    END IF;

    COMMIT ;


EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            oe_debug_pub.add('auto_create_dropship: ' || ':exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETCODE := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            oe_debug_pub.add('auto_create_dropship: ' || ':exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            RETCODE := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

        WHEN OTHERS THEN
            oe_debug_pub.add('auto_create_dropship: ' || ':exp error::'||to_char(l_stmt_num)||'::'||sqlerrm,1);
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            RETCODE := 2;
            conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',Current_Error_Code);

END auto_create_dropship;

END cto_auto_dropship_pk;

/
