--------------------------------------------------------
--  DDL for Package Body MRP_CREATE_SCHEDULE_ISO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CREATE_SCHEDULE_ISO" AS
/* $Header: MRPCISOB.pls 120.12.12010000.6 2010/03/25 07:04:10 vsiyer ship $ */

l_debug     varchar2(30) := FND_PROFILE.Value('MRP_DEBUG');


/********************************************************
PROCEDURE : log_message
********************************************************/

PROCEDURE log_message( p_user_info IN VARCHAR2) IS
BEGIN
       FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_message;

PROCEDURE log_output( p_user_info IN VARCHAR2) IS
BEGIN
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_user_info);
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END log_output;

PROCEDURE debug_message( p_user_info IN VARCHAR2) IS
BEGIN
    IF l_debug = 'Y' THEN
       log_message(p_user_info);
    END IF;
EXCEPTION
   WHEN OTHERS THEN
   RAISE;
END debug_message;


/**********************************************************
Procedure:  MSC_RELEASE_ISO
***********************************************************/
PROCEDURE MSC_RELEASE_ISO( p_batch_id    IN       number,
                           p_load_type   IN       number,
                           arg_int_req_load_id            IN OUT  NOCOPY  Number,
                           arg_int_req_resched_id         IN OUT  NOCOPY  Number ) IS


l_request     number;
l_result      BOOLEAN;
BEGIN


         l_result := fnd_request.set_mode(TRUE);
         l_request := FND_REQUEST.SUBMIT_REQUEST
         ('MSC',
          'MSC_RELEASE_ISO',
          'MSC ISO release Program',
           null,
           FALSE,
           p_batch_id);

   IF nvl(l_request,0) = 0 THEN
      LOG_MESSAGE('Error in MSC_RELEASE_ISO');
   ELSE
      IF p_load_type = DRP_REQ_LOAD THEN
         arg_int_req_load_id := l_request;
         arg_int_req_resched_id := null;
         LOG_MESSAGE('Concurrent Request ID For ISO Load : ' || arg_int_req_load_id);
      ELSE
         arg_int_req_load_id := null;
         arg_int_req_resched_id := l_request;
         LOG_MESSAGE('Concurrent Request ID For ISO Re-Schedule: ' || arg_int_req_resched_id);
      END IF;

      LOG_MESSAGE('MSC_RELEASE_ISO completed successfully');
   END IF;

END MSC_RELEASE_ISO;

/**********************************************************
Procedure:  Create_IR_ISO  creates 1 IR + creates 1 ISO for the specific row in mrp_org_transfer_Release
***********************************************************/
PROCEDURE Create_IR_ISO(           errbuf                OUT NOCOPY VARCHAR2,
                                   retcode               OUT NOCOPY VARCHAR2,
                                   p_Ireq_header_id      OUT NOCOPY number,
                                   p_ISO_header_id       OUT NOCOPY number,
                                   p_Transaction_id      IN  number,
                                   p_batch_id            IN  number) IS

CURSOR c_trans_rel(l_transaction_id  number) IS
   SELECT
      batch_id,  item_id, src_organization_id,
      sr_instance_id, to_organization_id, to_sr_instance_id,
      src_operating_unit, to_operating_unit,
      sales_order_line_id, sales_order_number,
      quantity, need_by_date, ship_date,
      deliver_to_location_id, deliver_to_requestor_id, preparer_id,
      uom_code, charge_account_id, group_code, item_revision,
      project_id, task_id, end_item_number, load_type, firm_demand_flag,
      ship_method, earliest_ship_date,plan_type,part_condition
   FROM
      MRP_ORG_TRANSFER_RELEASE
   WHERE
      transaction_id  =  l_transaction_id
   ORDER BY src_operating_unit;

l_org_trans_rel_cur  c_trans_rel%ROWTYPE;

CURSOR c_security (l_org_id  number,
                   l_user_id number,
                   l_appl_id number) IS
   SELECT  level_id,   level_value
   FROM  fnd_profile_options opt,
         fnd_profile_option_values opt_vals,
         fnd_user_resp_groups user_resp
   WHERE opt.profile_option_name = 'ORG_ID'
         AND   opt.profile_option_id = opt_vals.profile_option_id
         AND   opt_vals.profile_option_value = to_char(l_org_id)
         AND   opt_vals.level_id = 10003  -- responsibility level
         AND   user_resp.user_id = l_user_id
         AND   user_resp.responsibility_id = opt_vals.level_value
         AND   user_resp.responsibility_application_id = l_appl_id
         AND   rownum = 1;

CURSOR c_order_type_id(p_org_id number) IS
   SELECT ORDER_TYPE_ID
   FROM  PO_SYSTEM_PARAMETERS_ALL
   WHERE nvl(ORG_ID,-1) = p_org_id;


CURSOR c_bill_to_location_id(p_customer_id number) IS
select org.organization_id
from oe_invoice_to_orgs_v org, hz_parties hp, hz_cust_accounts hca
where org.customer_id=hca.cust_account_id
and hp.party_id = hca.party_id
and hca.cust_account_id = p_customer_id
and rownum < 2;

CURSOR c_ship_to_location_id(p_customer_id number, p_site_use_id number) IS
select org.organization_id
from oe_ship_to_orgs_v org, hz_parties hp, hz_cust_accounts hca
where org.customer_id = hca.cust_account_id
and hp.party_id = hca.party_id
and hca.cust_account_id = p_customer_id
and org.site_use_id = p_site_use_id
and rownum < 2;

CURSOR c_header_id(p_order_number number) IS
select header_id from oe_order_headers_all
where order_number = p_order_number;



/* For security */
   l_user_id   NUMBER;
   l_appl_id   NUMBER;
   l_src_org_id    number := 0;
   l_prev_src_org_id number := -99999;
   l_level_id  number;
   l_level_value  number;

/* Variables for Process Requisition */
   l_int_req_Ret_sts            varchar2(30);
   l_req_header_rec             PO_CREATE_REQUISITION_SV.Header_rec_Type;
   l_req_line_tbl               PO_CREATE_REQUISITION_SV.Line_Tbl_Type;
   l_msg_count                  number;
   l_msg_data                   varchar2(2000);
   k                            number := 1;
   j                            number := 1;

/* Variables for Process Order */
   l_api_version_number         CONSTANT NUMBER := 1.0;
   lv_action_rec                OE_Order_PUB.Request_Rec_Type;
   lv_action_req_tbl            OE_Order_PUB.Request_Tbl_Type;
   l_oe_header_rec              oe_order_pub.header_rec_type := OE_ORDER_PUB.G_MISS_HEADER_REC;
   l_oe_line_tbl                oe_order_pub.line_tbl_type := OE_ORDER_PUB.G_MISS_LINE_TBL;
   l_oe_line_rec                oe_order_pub.line_rec_type := OE_ORDER_PUB.G_MISS_LINE_REC;

    -- OUT variables
    l_header_rec                    OE_Order_PUB.Header_Rec_Type;
    l_header_val_rec                OE_Order_PUB.Header_Val_Rec_Type;
    l_Header_Adj_tbl                OE_Order_PUB.Header_Adj_Tbl_Type;
    l_Header_Adj_val_tbl            OE_Order_PUB.Header_Adj_Val_Tbl_Type;
    l_Header_price_Att_tbl          OE_Order_PUB.Header_Price_Att_Tbl_Type;
    l_Header_Adj_Att_tbl            OE_Order_PUB.Header_Adj_Att_Tbl_Type;
    l_Header_Adj_Assoc_tbl          OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
    l_Header_Scredit_tbl            OE_Order_PUB.Header_Scredit_Tbl_Type;
    l_Header_Scredit_val_tbl        OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
    l_line_tbl                      OE_Order_PUB.Line_Tbl_Type;
    l_line_val_tbl                  OE_Order_PUB.Line_Val_Tbl_Type;
    l_Line_Adj_tbl                  OE_Order_PUB.Line_Adj_Tbl_Type;
    l_Line_Adj_val_tbl              OE_Order_PUB.Line_Adj_Val_Tbl_Type;
    l_Line_price_Att_tbl            OE_Order_PUB.Line_Price_Att_Tbl_Type;
    l_Line_Adj_Att_tbl              OE_Order_PUB.Line_Adj_Att_Tbl_Type;
    l_Line_Adj_Assoc_tbl            OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
    l_Line_Scredit_tbl              OE_Order_PUB.Line_Scredit_Tbl_Type;
    l_Line_Scredit_val_tbl          OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
    l_Lot_Serial_tbl                OE_Order_PUB.Lot_Serial_Tbl_Type;
    l_Lot_Serial_val_tbl            OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
    l_action_request_tbl            OE_Order_PUB.Request_Tbl_Type;


    l_order_number            number := 0;
    l_header_id               number;
    l_order_source_id         number := 10;
    l_price_list_id           NUMBER;
    l_currency_code          varchar2(30);
    l_order_line_type_id      number;
    l_line_price_list_id      number;
    l_order_line_category_code  varchar2(30);
    l_order_line_id           number;

    l_order_type_id           number;  /* DWK need to be modified */
    l_return_status           varchar2(30);
    l_deliver_to_org_id       number:=0;
    b_has_error               BOOLEAN := FALSE;

    l_customer_id              NUMBER;
    l_address_id               NUMBER;
    l_site_use_id              NUMBER;

    l_invoice_to_org_id        number;
    l_ship_to_org_id           number;

    -- For Loop Back API
    l_sch_rec                OE_SCHEDULE_GRP.sch_rec_type;
    l_sch_rec_tbl            OE_SCHEDULE_GRP.Sch_Tbl_Type;
    l_request_id             NUMBER:= 0;
    v_success		     NUMBER:= 0;
    v_failure		     NUMBER:= 0;
    v_load_type		     VARCHAR2(30);

    l_output_error           VARCHAR2(200);
    lv_sql_query             VARCHAR2(4000);
    lv_source_subinv         VARCHAR2(200);
    lv_Dest_subinv           VARCHAR2(200);

BEGIN

   l_user_id := fnd_global.user_id();
   l_appl_id := 724;  -- Application id for Advanced Supply Chain Planning
   retcode := 0;
   log_message('Transaction_id :'||p_transaction_id);


--   For l_org_trans_rel_cur in c_trans_rel(p_transaction_id ) LOOP
   Open c_trans_rel(p_transaction_id );
   Fetch  c_trans_rel into
                         l_org_trans_rel_cur.batch_id,  l_org_trans_rel_cur.item_id, l_org_trans_rel_cur.src_organization_id,
l_org_trans_rel_cur.sr_instance_id, l_org_trans_rel_cur.to_organization_id,
l_org_trans_rel_cur.to_sr_instance_id,l_org_trans_rel_cur.src_operating_unit,
l_org_trans_rel_cur.to_operating_unit,l_org_trans_rel_cur.sales_order_line_id, l_org_trans_rel_cur.sales_order_number,
l_org_trans_rel_cur.quantity, l_org_trans_rel_cur.need_by_date, l_org_trans_rel_cur.ship_date,
l_org_trans_rel_cur.deliver_to_location_id, l_org_trans_rel_cur.deliver_to_requestor_id, l_org_trans_rel_cur.preparer_id,
l_org_trans_rel_cur.uom_code, l_org_trans_rel_cur.charge_account_id, l_org_trans_rel_cur.group_code, l_org_trans_rel_cur.item_revision,
l_org_trans_rel_cur.project_id, l_org_trans_rel_cur.task_id, l_org_trans_rel_cur.end_item_number,
l_org_trans_rel_cur.load_type, l_org_trans_rel_cur.firm_demand_flag,l_org_trans_rel_cur.ship_method,
l_org_trans_rel_cur.earliest_ship_date,l_org_trans_rel_cur.plan_type,l_org_trans_rel_cur.part_condition
;


   log_message('Load_type :'||l_org_trans_rel_cur.load_type);

      DECLARE
         e_creating_iso_err EXCEPTION;
         e_update_rescheduling_err EXCEPTION;
      BEGIN

         Savepoint Before_Requisition ;

         l_int_req_ret_sts := FND_API.G_RET_STS_SUCCESS;

         -- Get responsibility id
         OPEN  c_security(l_org_trans_rel_cur.to_operating_unit, l_user_id, l_appl_id);
         FETCH c_security INTO l_level_id, l_level_value;  -- resp_id
         CLOSE c_security;

         fnd_global.apps_initialize(l_user_id, l_level_value, l_appl_id);


         IF (l_org_trans_rel_cur.load_type = DRP_REQ_LOAD) THEN
            --Pass the Internal Sales Order Header values to the internal req header record
            l_req_header_rec.preparer_id := l_org_trans_rel_cur.preparer_id;
            l_req_header_rec.summary_flag := 'N';
            l_req_header_rec.enabled_flag := 'Y';
            l_req_header_rec.authorization_status := 'APPROVED';
            l_req_header_rec.type_lookup_code     := 'INTERNAL';
            l_req_header_rec.transferred_to_oe_flag := 'Y';
            l_req_header_rec.org_id      := l_org_trans_rel_cur.to_operating_unit;


            --Pass the Internal Sales Order Line values to the internal req Line table
            /* DWK  Header and line willl be 1 to 1 relationship for creating ISO.
               There is no reason to make req_line to table.
               For the consistence, I will use it as a table, but only pass
               first index */
            j := 1;

            l_req_line_tbl(j).line_num               := j;
            l_req_line_tbl(j).uom_code  := l_org_trans_rel_cur.uom_code;
            l_req_line_tbl(j).quantity               := l_org_trans_rel_cur.quantity;
            l_req_line_tbl(j).deliver_to_location_id := l_org_trans_rel_cur.deliver_to_location_id;
            l_req_line_tbl(j).destination_type_code       := 'INVENTORY';
            l_req_line_tbl(j).destination_organization_id := l_org_trans_rel_cur.to_organization_id;
            l_req_line_tbl(j).to_person_id           := l_org_trans_rel_cur.preparer_id;
            l_req_line_tbl(j).source_type_code       := 'INVENTORY';
            l_req_line_tbl(j).item_id                := l_org_trans_rel_cur.item_id;
            l_req_line_tbl(j).need_by_date           := l_org_trans_rel_cur.need_by_date;
            l_req_line_tbl(j).source_organization_id := l_org_trans_rel_cur.src_organization_id;
            l_req_line_tbl(j).org_id                 := l_org_trans_rel_cur.to_operating_unit;

            If (l_org_trans_rel_cur.plan_type = 8) Then
                lv_sql_query := 'select  subinventory_code
                                    from CSP_RS_SUBINVENTORIES_V
                                			where organization_id = :l_organization_id
                                  			And  condition_type = nvl(:l_condition_type,''G'')
                                  			And nvl(effective_date_end,to_date(:l_need_by_date)+1) > to_date(:l_need_by_date)
                                        AND OWNER_RESOURCE_TYPE='||'''RS_EMPLOYEE'''||
                                        'AND OWNER_FLAG='||'''Y'''||
                                  			'And  rownum <2';
                    Begin

                        Execute Immediate  lv_sql_query
                          into lv_source_subinv
                          using  l_org_trans_rel_cur.src_organization_id,
                                 l_org_trans_rel_cur.part_condition,
                                  l_org_trans_rel_cur.need_by_date,l_org_trans_rel_cur.need_by_date ;

                        Execute Immediate  lv_sql_query
                          into lv_Dest_subinv
                          using  l_org_trans_rel_cur.to_organization_id,
                                 l_org_trans_rel_cur.part_condition,
                                 l_org_trans_rel_cur.need_by_date,l_org_trans_rel_cur.need_by_date;

                    Exception
                    When others then
                    LOG_MESSAGE('Unable to locate a good/bad subinventory in the organziation'||to_char(l_org_trans_rel_cur.src_organization_id));
                    RAISE FND_API.G_EXC_ERROR;
                    End;

                l_req_line_tbl(j).source_subinventory       :=   lv_source_subinv;
                l_req_line_tbl(j).destination_subinventory  :=   lv_Dest_subinv;


            End if; -- For Plan_Type = 8 SRP Plan

	    mo_global.init('PO');  -- MOAC Change
	    mo_global.set_policy_context('S',l_org_trans_rel_cur.to_operating_unit);  -- MOAC Change

            /* Call the PO API and pass the internal req header record
               and line tables to Create the Internal Req */
            PO_CREATE_REQUISITION_SV.process_requisition(px_header_rec   => l_req_header_rec
                                                      ,px_line_table   => l_req_line_tbl
                                                      ,x_return_status => l_int_req_Ret_sts
                                                      ,x_msg_count     => l_msg_count
                                                      ,x_msg_data      => l_msg_data );
            --Check return status of the Purchasing API
            IF l_int_req_Ret_sts = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  LOG_MESSAGE('Error in process_requisition : FND_API.G_RET_STS_UNEXP_ERROR');
                  oe_debug_pub.add(' PO API call returned unexpected error '||l_msg_data,2);
                  log_message('Item ID :'  || l_req_line_tbl(j).item_id );
                  log_message('Quantity :' || l_req_line_tbl(j).quantity);
                  log_message('Deliver To loc ID :' || l_req_line_tbl(j).deliver_to_location_id);
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_int_req_Ret_sts = FND_API.G_RET_STS_ERROR THEN
                  LOG_MESSAGE('Error in process_requisition : FND_API.G_RET_STS_ERROR');
                  oe_debug_pub.add(' PO API call returned error '||l_msg_data,2);
                  log_message('Error Msg from PO API: '  || l_msg_data );
                  log_message('Item ID :'  || l_req_line_tbl(j).item_id );
                  log_message('Quantity :' || l_req_line_tbl(j).quantity);
                  log_message('Deliver To loc ID :' || l_req_line_tbl(j).deliver_to_location_id);
                  RAISE FND_API.G_EXC_ERROR;
            ELSIF l_int_req_ret_sts = FND_API.G_RET_STS_SUCCESS THEN
                  p_Ireq_header_id:= l_req_header_rec.requisition_header_id;
                  log_message('Successful in Creating requisition.');
                  log_message('Requisition Header ID     :' ||l_req_header_rec.requisition_header_id);
                  log_message('Internal Requisition Number : ' || l_req_header_rec.segment1);
                  log_message('Requisition Line Num        : ' || l_req_line_tbl(j).line_num);
                  log_message('Requisition Line ID       : ' ||l_req_line_tbl(j).requisition_line_id);
                  log_message('Item ID                     : '  || l_req_line_tbl(j).item_id );
                  log_message('Quantity                    : ' || l_req_line_tbl(j).quantity);
                  log_message('Deliver To loc ID         :' || l_req_line_tbl(j).deliver_to_location_id);
            END IF;

         END IF; /* End of Creating new requisitions*/

         /* if it returns success Update the Internal Sales Order
            with the Req header id and Req line Ids */
         IF l_int_req_ret_sts = FND_API.G_RET_STS_SUCCESS THEN

            /* For Security */
            IF l_prev_src_org_id <>  l_org_trans_rel_cur.src_operating_unit THEN
               l_prev_src_org_id :=  l_org_trans_rel_cur.src_operating_unit;

               -- Get Source Operating Unit
               l_src_org_id := l_org_trans_rel_cur.src_operating_unit;

               -- Get order type id
               OPEN  c_order_type_id(l_src_org_id);
               FETCH c_order_type_id INTO l_order_type_id;
               CLOSE c_order_type_id;

               -- Get responsibility id
               OPEN  c_security(l_src_org_id, l_user_id, l_appl_id);
               FETCH c_security INTO l_level_id, l_level_value;  -- resp_id
               CLOSE c_security;

               fnd_global.apps_initialize(l_user_id, l_level_value, l_appl_id);

             END IF;

      mo_global.init('ONT');  -- MOAC Change
	    mo_global.set_policy_context('S',l_org_trans_rel_cur.src_operating_unit);  -- MOAC Change

            /********* Process Order ********************************/
            -- SETTING UP THE HEADER RECORD

	          l_oe_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
            l_oe_line_rec := OE_ORDER_PUB.G_MISS_LINE_REC;

            /* For Creating ISO */
            log_message('DRP_REQ_LOAD :'||DRP_REQ_LOAD);
            log_message('l_org_trans_rel_cur.load_type :'||l_org_trans_rel_cur.load_type);
            IF (l_org_trans_rel_cur.load_type = DRP_REQ_LOAD) THEN
               v_load_type := 'Release';

               l_oe_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
               l_oe_header_rec.org_id := l_org_trans_rel_cur.src_operating_unit;
               l_oe_header_rec.order_type_id := l_order_type_id;

               -- requisition number
               l_oe_header_rec.ORIG_SYS_DOCUMENT_REF := l_req_header_rec.segment1;
               l_oe_header_rec.SOURCE_DOCUMENT_ID := l_req_header_rec.requisition_header_id;
               l_oe_header_rec.source_document_type_id := l_order_source_id;
               l_oe_header_rec.order_source_id := l_order_source_id;
               l_oe_header_rec.open_flag := 'Y';
               l_oe_header_rec.booked_flag := 'N';
               l_oe_header_rec.ship_from_org_id := l_org_trans_rel_cur.src_organization_id;
               l_oe_header_rec.shipping_method_code := l_org_trans_rel_cur.ship_method;


               /* For the line */
               l_oe_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
               l_oe_line_rec.ORIG_SYS_DOCUMENT_REF := l_req_header_rec.segment1;
               l_oe_line_rec.SOURCE_DOCUMENT_ID := l_req_header_rec.requisition_header_id;
               l_oe_line_rec.source_document_type_id := l_order_source_id;
               l_oe_line_rec.order_source_id := l_order_source_id;
               l_oe_line_rec.ORIG_SYS_LINE_REF := l_req_line_tbl(j).line_num;
               l_oe_line_rec.source_document_line_id := l_req_line_tbl(j).requisition_line_id;
               l_oe_line_rec.ordered_quantity := l_org_trans_rel_cur.quantity;
               l_oe_line_rec.inventory_item_id := l_req_line_tbl(j).item_id;
               l_oe_line_rec.request_date := l_org_trans_rel_cur.ship_date; -- xxx dsting
               l_oe_line_rec.promise_date := l_org_trans_rel_cur.ship_date; -- Bug# 4227424
               l_oe_line_rec.schedule_arrival_date := l_org_trans_rel_cur.need_by_date;
               l_oe_line_rec.schedule_ship_date := l_org_trans_rel_cur.ship_date;
               l_oe_line_rec.open_flag := 'Y';
               l_oe_line_rec.booked_flag := 'N';
               l_oe_line_rec.ship_from_org_id := l_org_trans_rel_cur.src_organization_id; --l_oe_header_rec.org_id; xxx dsting
               l_oe_line_rec.firm_demand_flag :=
               l_org_trans_rel_cur.firm_demand_flag;
               l_oe_line_rec.Earliest_ship_date := l_org_trans_rel_cur.Earliest_ship_date; -- Bug# 4306515

               l_oe_line_rec.shipping_method_code := l_org_trans_rel_cur.ship_method;
               lv_action_rec.request_type := OE_GLOBALS.G_BOOK_ORDER;
               lv_action_rec.entity_code  := OE_GLOBALS.G_ENTITY_HEADER;

               If (l_org_trans_rel_cur.plan_type = 8) Then
               l_oe_line_rec.subinventory := lv_source_subinv; -- for bug 8407184
               END IF;
               -- Get Customer ID
         log_message('Source organization id => ' || l_org_trans_rel_cur.src_organization_id);
               po_customers_sv.get_cust_details(l_org_trans_rel_cur.deliver_to_location_id,
			                        l_customer_id,
                                                l_address_id,
                                                l_site_use_id,
						l_org_trans_rel_cur.src_organization_id);

               IF l_customer_id is not null THEN
                  l_oe_header_rec.sold_to_org_id := l_customer_id;
                  log_message('Customer ID               : ' || l_customer_id);
               ELSE
                   log_message('ERROR: OE Header Rec:Sold_To_Org_id(Customer_ID)is null for Deliver to location id:'
                                || l_org_trans_rel_cur.deliver_to_location_id);
                   l_output_error := 'Error in getting Customer ID for Deliver to location id.';
                   raise e_creating_iso_err;
               END IF;


               OPEN c_bill_to_location_id(l_customer_id);
               FETCH c_bill_to_location_id INTO l_invoice_to_org_id;
               CLOSE c_bill_to_location_id;

               IF l_invoice_to_org_id IS NOT NULL THEN
                  l_oe_header_rec.invoice_to_org_id := l_invoice_to_org_id;
               END IF;


               OPEN c_ship_to_location_id(l_customer_id, l_site_use_id);
               FETCH c_ship_to_location_id INTO l_ship_to_org_id;
               CLOSE c_ship_to_location_id;

               IF l_ship_to_org_id IS NOT NULL THEN
                  l_oe_header_rec.ship_to_org_id := l_ship_to_org_id;
               END IF;

               l_oe_line_tbl(j) := l_oe_line_rec;
               lv_action_req_Tbl(j) := lv_action_rec;
               --Add Process_order
	           OE_Order_PUB.Process_Order(
                              -- IN variables
		                p_api_version_number        => 1.0,
                        p_header_rec                => l_oe_header_rec,
                        p_line_tbl	                => l_oe_line_tbl,
                        p_action_request_tbl        => lv_action_req_Tbl,
                        p_org_id                    => l_src_org_id,
                             -- OUT variables
                        x_header_rec                => l_header_rec,
	                    x_header_val_rec            => l_header_val_rec,
                        x_Header_Adj_tbl            => l_Header_Adj_tbl,
                        x_Header_Adj_val_tbl        => l_Header_Adj_val_tbl,
                        x_Header_price_Att_tbl      => l_Header_price_Att_tbl,
                        x_Header_Adj_Att_tbl        => l_Header_Adj_Att_tbl,
                        x_Header_Adj_Assoc_tbl      => l_Header_Adj_Assoc_tbl,
                        x_Header_Scredit_tbl        => l_Header_Scredit_tbl,
                        x_Header_Scredit_val_tbl    => l_Header_Scredit_val_tbl,
                        x_line_tbl                  => l_Line_Tbl,
                        x_line_val_tbl              => l_line_val_tbl,
                        x_Line_Adj_tbl              => l_Line_Adj_tbl,
                        x_Line_Adj_val_tbl          => l_Line_Adj_val_tbl,
                        x_Line_price_Att_tbl        => l_Line_price_Att_tbl,
                        x_Line_Adj_Att_tbl          => l_Line_Adj_Att_tbl,
                        x_Line_Adj_Assoc_tbl        => l_Line_Adj_Assoc_tbl,
                        x_Line_Scredit_tbl          => l_Line_Scredit_tbl,
                        x_Line_Scredit_val_tbl      => l_Line_Scredit_val_tbl,
                        x_Lot_Serial_tbl            => l_Lot_Serial_tbl,
                        x_Lot_Serial_val_tbl        => l_Lot_Serial_val_tbl,
                        x_action_request_tbl        => l_action_request_tbl,
                        x_return_status             => l_return_status,
                        x_msg_count                 => l_msg_count,
                        x_msg_data                  => l_msg_data);

               if (l_msg_count > 0) then
                  for lv_index in 1..l_msg_count loop
                     l_msg_data := OE_MSG_PUB.get(p_msg_index => lv_index, p_encoded   => 'F');
                     log_message('Error :'||lv_index|| '  '|| l_msg_data);
                  end loop;
	           end if;


               if (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  p_ISO_header_id:= l_header_rec.header_id ;
		          log_message('Successful in loading Sales order.');
		          log_message('Header ID         : ' ||l_header_rec.header_id);
		          log_message('Internal Sales Order Number : ' ||
                               l_header_rec.order_number);
  		          log_message('Inventory Item ID         :' ||
                               l_line_tbl(1).inventory_item_id);
	 	          log_message('UOM                       :' ||
                               l_line_tbl(1).order_quantity_uom);
		          log_message('Item Identifier Type      :' ||
                               l_line_tbl(1).item_identifier_type);
		          log_message('Line ID                   :' ||
                               l_line_tbl(1).line_id);
		          log_message('Ship above                : '||
                               l_line_tbl(1).ship_tolerance_above);
		          log_message('Ordered quantity          : '||
                               l_line_tbl(1).ordered_quantity);
		          log_message('Request Date                : ' ||
                               to_char(l_line_tbl(1).request_date,
                                       'DD-MON-YYYY HH24:MI:SS'));
		          log_message('Schdeule Ship Date        :' ||
                               to_char(l_line_tbl(1).schedule_Ship_date,
                                       'DD-MON-YYYY HH24:MI:SS'));
		          log_message('Schdeule Arrival Date     :' ||
                               to_char(l_line_tbl(1).schedule_arrival_date,
                                        'DD-MON-YYYY HH24:MI:SS'));
               else
                  log_message('Error in loading sales order.');
                  l_output_error := ' Error while creating Internal Sales Order.';
                  RAISE e_creating_iso_err;
               end if;

             l_sch_rec.header_id := l_header_rec.header_id;
             l_sch_rec.line_id   := l_line_tbl(1).line_id;

            ELSE  /* For Re-Schedule ISO */
               v_load_type := 'Reschedule';
               l_oe_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

               OPEN c_header_id(l_org_trans_rel_cur.sales_order_number);
               FETCH c_header_id INTO l_header_id;
               CLOSE c_header_id;

               IF nvl(l_header_id,0) = 0 THEN
                  log_message('Error: Can not find Header_ID from given Order Number: ' || l_org_trans_rel_cur.sales_order_number);
                  l_output_error := 'Error while finding Header_ID from given Order Number.';
                  raise e_creating_iso_err;
               END IF;

               l_oe_header_rec.header_id := l_header_id;
               l_oe_header_rec.order_number := l_org_trans_rel_cur.sales_order_number;

               l_oe_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
               l_oe_line_rec.line_id := l_org_trans_rel_cur.sales_order_line_id;
               l_oe_line_rec.ordered_quantity :=  l_org_trans_rel_cur.quantity;
               l_oe_line_rec.schedule_ship_date := l_org_trans_rel_cur.ship_date;
               l_oe_line_rec.change_reason := 'SYSTEM';
               l_oe_line_rec.change_comments := 'Updating';
               l_oe_line_rec.Earliest_ship_date := l_org_trans_rel_cur.Earliest_ship_date; -- Bug# 4306515

               l_oe_line_tbl(j) := l_oe_line_rec;

               /* Pass Null action req table in case of rescheduling */
               lv_action_req_Tbl.delete;
             l_sch_rec.header_id := l_header_id;
             l_sch_rec.line_id   := l_org_trans_rel_cur.sales_order_line_id;
               l_oe_header_rec.shipping_method_code := l_org_trans_rel_cur.ship_method;

            END IF;
--IRISO Enhancement - No need to call process_order API to reschedule
/*

*/
-- IRISO Enhancement, Call only Update_Scheduling_Results for rescheduling.
             /* Call Loop Back API to re-schedule ship date and arrival date */

             l_sch_rec.org_id :=  l_org_trans_rel_cur.to_operating_unit; --l_oe_header_rec.org_id;
             l_sch_rec.Schedule_ship_date := l_org_trans_rel_cur.ship_date;
             l_sch_rec.Schedule_arrival_date := l_org_trans_rel_cur.need_by_date;
             l_sch_rec.shipping_method_code := l_org_trans_rel_cur.ship_method;
             l_sch_rec.ordered_quantity :=  l_org_trans_rel_cur.quantity; -- IRISO


             l_sch_rec_tbl(1) := l_sch_rec;

             OE_SCHEDULE_GRP.Update_Scheduling_Results(p_x_sch_tbl   => l_sch_rec_tbl,
                                                       p_request_id  => l_request_id,
                                                       x_return_status => l_return_status);

             IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 log_message('Successful in update_scheduling_results.');
                 log_message('Header ID                 : ' || l_sch_rec_tbl(1).header_id );
                 log_message('Line ID                    : ' || l_sch_rec_tbl(1).line_id );
                 log_message('Org ID                    : ' || l_sch_rec_tbl(1).org_id );
                 log_message('Schedule Ship Date          : ' || to_char(l_sch_rec_tbl(1).Schedule_ship_date,'DD-MON-YYYY HH24:MI:SS'));
                 log_message('Schedule Arrival Date       : '|| to_char(l_sch_rec_tbl(1).Schedule_arrival_date, 'DD-MON-YYYY HH24:MI:SS'));
		 log_message(' ');
		 log_message(' ');
                 log_message('---------------------------------------------------------------------');

	       	 IF (l_org_trans_rel_cur.load_type = DRP_REQ_LOAD) THEN
	       	    log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||
	       	                                rpad(v_load_type,14,' ')||
	       	                                rpad(to_char(l_header_rec.order_number),11,' ')||
	       	                                rpad(l_oe_line_rec.ordered_quantity,11,' ')||
	       	                                rpad(to_char(l_sch_rec_tbl(1).Schedule_ship_date,'DD-MON-YYYY HH24:MI:SS'),25,' ')||
	       	                                rpad(to_char(l_sch_rec_tbl(1).Schedule_arrival_date, 'DD-MON-YYYY HH24:MI:SS'),25,' ')||
	       	                                rpad(l_req_header_rec.segment1,11,' ')||
	       	  				rpad(to_char(l_req_line_tbl(j).need_by_date, 'DD-MON-YYYY HH24:MI:SS'),25,' ')
	       	                                );
		 ELSE
	       	    log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||
	       	                                rpad(v_load_type,14,' ')||
	       	                                rpad(to_char(l_oe_header_rec.order_number),11,' ')||
	       	                                rpad(l_oe_line_rec.ordered_quantity,11,' ')||
	       	                                rpad(to_char(l_sch_rec_tbl(1).Schedule_ship_date,'DD-MON-YYYY HH24:MI:SS'),25,' ')||
	       	                                rpad(to_char(l_sch_rec_tbl(1).Schedule_arrival_date, 'DD-MON-YYYY HH24:MI:SS'),25,' ')
	       	                                );	 /* Changed l_header_rec to l_oe_header_rec -- Bug 7715442*/
		 END IF;

                 v_success := v_success +1;

             ELSE

                 log_message('Error in update_scheduling_results: ' || l_return_status);
                 log_message('Header ID : ' || l_sch_rec_tbl(1).header_id );
                 log_message('Line ID : ' || l_sch_rec_tbl(1).line_id );
                 log_message('Org ID : ' || l_sch_rec_tbl(1).org_id );
                 log_message('Schedule Ship Date : ' || to_char(l_sch_rec_tbl(1).Schedule_ship_date,'DD-MON-YYYY HH24:MI:SS'));
                 log_message('Schedule Arrival Date : '|| to_char(l_sch_rec_tbl(1).Schedule_arrival_date, 'DD-MON-YYYY HH24:MI:SS'));

                 IF l_return_status =   FND_API.G_RET_STS_ERROR THEN
                    log_message('FND_API.G_RET_STS_ERROR ');
                 ELSIF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR THEN
                    log_message('FND_API.G_RET_STS_UNEXP_ERROR ');
                 END IF;
                 RAISE e_update_rescheduling_err;
             END IF;


         END IF;  /* End of  l_int_req_ret_sts = FND_API.G_RET_STS_SUCCESS */



         /* Set the req line and req table to null so that
            they are re-initialized after each loop.
            This prevent to have unique violation on requisition line id */
         l_req_header_rec := null;
         l_req_line_tbl(1) := null;
         l_sch_rec := NULL;
         l_sch_rec_tbl.delete;
         l_msg_count := 0;
         l_msg_data:= '';
         lv_action_req_tbl.delete;




       EXCEPTION
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : FND_API.G_EXC_UNEXPECTED_ERROR');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             b_has_error := TRUE;
             v_failure := v_failure + 1;
             log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||rpad(v_load_type,14,' ')||' - Unexpected Error while creating requisition.');
             rollback to Savepoint Before_Requisition ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

          WHEN FND_API.G_EXC_ERROR THEN
             LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : FND_API.G_EXC_ERROR');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             b_has_error := TRUE;
             v_failure := v_failure + 1;
             log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||rpad(v_load_type,14,' ')||' - Error while creating requisition.');
             rollback to Savepoint Before_Requisition ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

          WHEN NO_DATA_FOUND THEN
             LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : Err No Data Found');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             b_has_error := TRUE;
             v_failure := v_failure + 1;
             log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||rpad(v_load_type,14,' ')||' - Unexpected NO_DATA_FOUND Error');
             rollback to Savepoint Before_Requisition ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

          WHEN e_creating_iso_err THEN
             LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : e_creating_iso_err');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             b_has_error := TRUE;
             v_failure := v_failure + 1;
             log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||rpad(v_load_type,14,' ')||l_output_error);
             rollback to Savepoint Before_Requisition ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

          WHEN e_update_rescheduling_err THEN
             LOG_MESSAGE('Error in UPDATE_RESCHEUDLING_RESULTS : e_update_rescheduling_err');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             b_has_error := TRUE;
             v_failure := v_failure + 1;
             log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||rpad(v_load_type,14,' ')||' - Error while updating scheduling results.');
             rollback to Savepoint Before_Requisition ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

          WHEN OTHERS THEN
             LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : Err OTHERS');
             LOG_MESSAGE(SQLERRM);
             retcode := 1;
             b_has_error := TRUE;
             v_failure := v_failure + 1;
             log_output(rpad(l_org_trans_rel_cur.sales_order_number,14,' ')||rpad(v_load_type,14,' ')||' - Unexpected Error');
             rollback to Savepoint Before_Requisition ;
             log_message('Transaction rolled back');
             log_message('----------------------------------------------------------');

       END;
	     log_output('');

   log_output(' ');
   log_output(v_success||' out of '||(v_success + v_failure)||' Internal Req/ISO released successfully. ');

   log_message('p_ISO_header_id returned:'||p_ISO_header_id);
   log_message('p_Ireq_header_id returned:'||p_Ireq_header_id);


   Close c_trans_rel;


--Handle Exceptions
EXCEPTION

   WHEN NO_DATA_FOUND THEN
      LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : Err No Data Found');
      LOG_MESSAGE(SQLERRM);
      retcode := 1;

   WHEN OTHERS THEN
      LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : Err OTHERS');
      LOG_MESSAGE(SQLERRM);
      retcode := 1;

END CREATE_IR_ISO;
/**********************************************************
Procedure:  CREATE_AND_SCHEDULE_ISO
***********************************************************/
PROCEDURE CREATE_AND_SCHEDULE_ISO(
                                   errbuf        OUT NOCOPY VARCHAR2,
                                   retcode       OUT NOCOPY VARCHAR2,
                                   p_batch_id    IN  number) IS

-- Cursors
CURSOR c_org_trans_rel(l_batch_id  number) IS
   SELECT
      batch_id,  transaction_id
   FROM
      MRP_ORG_TRANSFER_RELEASE
   WHERE
      batch_id = l_batch_id
   ORDER BY src_operating_unit;

 l_req_header_id number ;
 l_iso_header_id number ;
 l_user_id   NUMBER;
 l_appl_id   NUMBER;


BEGIN


   l_user_id := fnd_global.user_id();
   l_appl_id := 724;  -- Application id for Advanced Supply Chain Planning
   retcode := 0;

   log_output('                                            Internal Requisition/ISO Release and Reschedule Report');
   log_output('                                            ------------------------------------------------------');
   log_output('');
   log_output('Order No      Load Type     ISO No     Quantity   Schedule Shipment Date   Schedule Arrival Date   Internal   Need By Date');
   log_output('in PWB                                                                                              Req No.                                                                                                             ');
   log_output('-----------   -----------   --------   --------   ----------------------   ----------------------   --------   ----------------------');


   FOR l_org_trans_rel_cur IN c_org_trans_rel(p_batch_id) LOOP
     	     Create_IR_ISO(errbuf,retcode ,l_req_header_id,l_iso_header_id, l_org_trans_rel_cur.transaction_id , l_org_trans_rel_cur.batch_id );

   log_message('p_ISO_header_id returned:'||l_iso_header_id);
   log_message('p_Ireq_header_id returned:'||l_req_header_id);
   commit;

   END LOOP;

   DELETE from MRP_ORG_TRANSFER_RELEASE
   WHERE batch_id = p_batch_id;
   COMMIT;


EXCEPTION

   WHEN NO_DATA_FOUND THEN
      LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : Err No Data Found');
      LOG_MESSAGE(SQLERRM);
      retcode := 1;

   WHEN OTHERS THEN
      LOG_MESSAGE('Error in CREATE_AND_SCHEDULE_ISO : Err OTHERS');
      LOG_MESSAGE(SQLERRM);
      retcode := 1;

END CREATE_AND_SCHEDULE_ISO;


END MRP_CREATE_SCHEDULE_ISO;

/
