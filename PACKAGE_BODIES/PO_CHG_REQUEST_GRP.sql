--------------------------------------------------------
--  DDL for Package Body PO_CHG_REQUEST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHG_REQUEST_GRP" AS
/* $Header: POXGCHGB.pls 120.3.12010000.4 2012/04/18 23:15:30 pla ship $ */


 g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


/*
This PL/SQL table will store the supplier request.  A new row will be added
for each call of the store_supplier_request.

g_po_change_table pos_chg_rec_tbl;
*/
/*
  g_int_cont_num value will store the internal control number of each request.
  This will be set in the initialize call and reset on the windup call.
  Each time the API is called, it will be matched for the integrity purposes.

g_int_cont_num   varchar2(256);
*/


/*******************************  Private Procedures  ***********************/

procedure getNewShipmentNumber (p_line_id IN number,
                                x_new_shipment_number OUT NOCOPY number) is
i  number;
l_shipment_number  number := null;
l_api_name          CONSTANT VARCHAR2(30) := 'getNewShipmentNumber';
begin
  select max(shipment_num) + 1
  into l_shipment_number
  from po_line_locations_archive_all
  where po_line_id = p_line_id
        and latest_external_flag = 'Y';



   if (g_po_change_table.count() > 0) then
     FOR i in 1..g_po_change_table.count()
       LOOP
        if (g_po_change_table(i).Document_Line_Id =  p_line_id ) then
           if (l_shipment_number <= g_po_change_table(i).Document_Shipment_Number) then
             l_shipment_number := g_po_change_table(i).Document_Shipment_Number + 1;
           end if;
        end if;
       end loop;
    end if;
  x_new_shipment_number := l_shipment_number;
  exception when others then
   --There can be only unforeseen system errors.
   IF g_fnd_debug = 'Y' THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                     l_api_name || '.others_exception', sqlcode);
      END IF;
	    END IF;
    raise;
end;


procedure validateCancelRequest(
           p_api_version    IN     NUMBER,
           p_init_msg_list  IN     VARCHAR2 := FND_API.G_FALSE,
           x_return_status  OUT    NOCOPY VARCHAR2,
           p_po_header_id   IN     NUMBER,
           p_po_release_id  IN     NUMBER,
           p_po_line_location_id IN number default null) IS

    p_document_id       NUMBER;
    v_document_type     PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    v_document_subtype  PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    v_type_code         PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;
    l_api_name          CONSTANT VARCHAR2(30) := 'validateCancelRequest';
    l_api_version       CONSTANT NUMBER := 1.0;
    l_doc_line_id	number; -- added for bug# 5639722
    x_org_id            number;

  BEGIN
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.g_ret_sts_success;

    -- Call this when logging is enabled

   IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                   '.invoked', 'Type: ' ||
                   ', Header  ID: ' || NVL(TO_CHAR(p_po_header_id),'null') ||
                   ', Release ID: ' || NVL(TO_CHAR(p_po_release_id),'null'));
    END IF;
   END IF;
    if (p_po_release_id is not null) then
        p_document_id      := p_po_release_id;
        v_document_type    := 'RELEASE';
        v_document_subtype := 'BLANKET';

        select org_id
        into x_org_id
        from po_releases_all
        where po_release_id= p_po_release_id;

    else
        p_document_id := p_po_header_id;
        select type_lookup_code into v_type_code
        from po_headers_all
        where po_header_id= p_po_header_id;
        if (v_type_code in ('STANDARD','PLANNED')) then
            v_document_type    := 'PO';
            v_document_subtype := v_type_code;
        elsif (v_type_code in ('BLANKET','CONTRACT')) then
            v_document_type    := 'PA';
            v_document_subtype := v_type_code;
        end if;

        select org_id
        into x_org_id
        from po_headers_all
        where po_header_id= p_po_header_id;

    end if;
         -- Set the org context before calling the cancel api

	 PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ; -- <R12 MOAC>

	 -- added for bug# 5639722
	 select plla.PO_LINE_ID into l_doc_line_id
	 from po_line_locations_all plla
	 where plla.line_location_id = p_po_line_location_id;

         PO_Document_Control_GRP.check_control_action(
         p_api_version      => 1.0,
         p_init_msg_list    => FND_API.G_TRUE,
         x_return_status    => x_return_status,
         p_doc_type         => v_document_type,
         p_doc_subtype      => v_document_subtype,
         p_doc_id           => p_po_header_id,
         p_doc_num          => null,
         p_release_id       => p_po_release_id,
         p_release_num      => null,
         p_doc_line_id      => l_doc_line_id, -- bug# 5639722
         p_doc_line_num     => null,
         p_doc_line_loc_id  => p_po_line_location_id ,
         p_doc_shipment_num => null,
         p_action           => 'CANCEL');

        -- dbms_output.put_line ('The error is ' || x_return_status);


EXCEPTION

    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF g_fnd_debug = 'Y' THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
              FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                            l_api_name || '.others_exception', sqlcode);
            END IF;
            END IF;
        END IF;

END validateCancelRequest;



/********
  Note this procedure will not check if there is a change pending already in
       the change tables as if there is a change pending already it
       would have been validated in the validate header.
********/
-- Bug 7287009
/*Added vendor id and vendor site id in the signature of the procedure
Added l_org_id variable to capture org_id*/

procedure handle_header_level_requests
    (p_po_number IN  varchar2,  --PO # of the PO being modified or
                                --the Blanket's PO #
     p_release_number IN  number,   -- Release number if the PO Type
                                    -- is release or null
     p_po_type IN  varchar2,  --  RELEASE or STANDARD.
     p_revision_num IN  number,   -- Revision number of the PO or the release
     p_tp_id  IN  number,      --  vendor_id
     p_tp_site_id     IN  number,  --  vendor_site_id
     p_reason  IN  varchar2,
     p_ack_type   IN  varchar2,     -- 'ACCEPT' or 'REJECT' or 'MODIFICATION' or 'CANCELLATION'
     p_so_order_number IN varchar2,
     p_is_change  IN OUT NOCOPY number,
     x_error_id_out IN OUT NOCOPY number,   -- The error id will be 2;
                                            -- errors will go to the TP sysadmin
     x_error_status_out IN OUT NOCOPY varchar2 -- Error message in this call
                                               --concatenated with the old ones
)
is
l_release_id number;
l_po_header_id  number;
l_max_rev  number;
l_rec_cur_index number := 0;
l_ack_type varchar2 (30) := null;
l_old_so_order_number varchar2(25) := null;
l_new_so_order_number varchar2(25) := null;
l_req_status  varchar2(30);
l_po_type varchar2(25);
l_can_cancel_status varchar2 (3) := null;
l_org_id   number;

begin

   if (p_ack_type <> 'CANCELLATION') then
     l_release_id := null;
     if (p_po_type = 'RELEASE') then
       if (p_so_order_number is not null) then
         /*
           PO_CHG_API_REL_SO_CHG_INVLD  = Sales Order Number change is not
                                        supported for releases.
         */
          x_error_id_out := 2;
          x_error_status_out := x_error_status_out ||
       	                     fnd_message.get_string('PO',
       	                                  'PO_CHG_API_REL_SO_CHG_INVLD');
       end if;
       return;  -- p_so_order_number is null, simply return as there no change
     else
      -- Bug 7287009 - Start
      /*Used vendor id and vendor site id combination to fetch org_id.
      Org_id is used in the second query's where clause to restrict
      mutiple records fetch.*/

      SELECT org_id
      into   l_org_id
      FROM   po_vendor_sites_all
      WHERE  vendor_id = p_tp_id
             AND vendor_site_id  = p_tp_site_id;

      select po_header_id, VENDOR_ORDER_NUM
      into l_po_header_id, l_old_so_order_number
      from po_headers_all
      where segment1 = p_po_number
            AND org_id = l_org_id
            AND TYPE_LOOKUP_CODE NOT IN ('QUOTATION','RFQ');
      -- Bug 7287009 - End


     end if;  --if p_po_type = 'RELEASE'

     --Ack Type always should be modification.

      l_ack_type := 'MODIFICATION';


     if (p_so_order_number is not null and
         p_so_order_number <> l_old_so_order_number) then
         p_is_change := 1;
         l_new_so_order_number := p_so_order_number;
     else  --if there is no so_line_number change or if new is
           --same as old so_line_number
         p_is_change := 0;  --we don't allow any other changes at the header.
         l_new_so_order_number := null;
         l_old_so_order_number := null;

     end if;
   else -- if (p_ack_type <> 'CANCELLATION')
     l_ack_type := p_ack_type;

      -- Bug 7287009 - Start
      /*Used vendor id and vendor site id combination to fetch org_id.
      Org_id is used in the second query's where clause to restrict
      mutiple records fetch.*/

      SELECT org_id
      into   l_org_id
      FROM   po_vendor_sites_all
      WHERE  vendor_id = p_tp_id
             AND vendor_site_id  = p_tp_site_id;

     select po_header_id into l_po_header_id
     from po_headers_all
     where segment1 = p_po_number
           AND org_id = l_org_id
           AND TYPE_LOOKUP_CODE NOT IN ('QUOTATION','RFQ');
     -- Bug 7287009 - End

     if (upper(p_po_type) = 'RELEASE') then
       select po_release_id into l_release_id
       from po_releases_all
       where po_header_id = l_po_header_id and release_num = p_release_number;
     end if;

     if (p_ack_type = 'CANCELLATION') then
       validateCancelRequest(
           p_api_version => 1.0,
           p_init_msg_list  => FND_API.G_FALSE,
           x_return_status  => l_can_cancel_status,
           p_po_header_id   => l_po_header_id,
           p_po_release_id  => l_release_id
           );

           if (l_can_cancel_status <> FND_API.G_RET_STS_SUCCESS) then
                /*
	              PO_INVALID_CANCEL_REQ_REL = "The Release RELNUM for PO  PONUMBER
	                                            cannot be canelled due to error: ERRCODE. The error message is : ERRMSG"
	             */
	             fnd_message.set_name('PO', 'PO_INVALID_CANCEL_REQ_REL');
	             fnd_message.set_token('RELNUM', p_release_number, false);
	             fnd_message.set_token('PONUMBER', p_po_number, false);
                 fnd_message.set_token('ERRCODE', l_can_cancel_status, false);
                 fnd_message.set_token('ERRMSG', FND_MSG_PUB.Get(p_msg_index => 1,p_encoded   => 'F'));



                 x_error_status_out := x_error_status_out || fnd_message.get;

                 x_error_id_out := 2;
                 return;
           end if;
       end if;

   end if;


      /************** Store Request *********************/
      if (x_error_id_out <> 0) then
        return;  --there was an error.
      end if;

      if (p_is_change = 0 and l_ack_type <> 'CANCELLATION') then
        return;  --There is no change or there is error.
      end if;

      select max(REVISION_NUM)
      into l_max_rev
      from po_headers_archive_all
      where PO_HEADER_ID = l_po_header_id;

      if (upper(p_po_type) = 'STANDARD') then
          l_po_type := 'PO';
      else
          l_po_type := p_po_type;
      end if;

      l_req_status := 'PENDING';  -- 'PENDING' state, initially.
      g_po_change_table.extend(1);
      l_rec_cur_index := g_po_change_table.last;
            /*  Note N/U in the following comments stands for
                not used in case of supplier change
                N/A stands for not applicable in case of SHIPMENT level.
             */


      g_po_change_table(l_rec_cur_index) := PO_CHG_REQUEST_PVT.create_pos_change_rec(
            p_Action_Type => l_ack_type,
            p_Initiator => 'SUPPLIER',
            p_Document_Type => l_po_type,
            p_Request_Level => 'HEADER',
            p_Request_Status => l_req_status,
            p_Document_Header_Id => l_po_header_id,
            p_Request_Reason => p_reason,
            p_PO_Release_Id => l_release_id,
            p_Document_Num => p_po_number,
            p_Document_Revision_Num => l_max_rev,
            p_Old_Supplier_Order_Number => l_old_so_order_number,
            p_New_Supplier_Order_Number => l_new_so_order_number
      );

  exception
  when others then
    x_error_id_out := 2;
    x_error_status_out := x_error_status_out || SQLERRM;


end handle_header_level_requests;


/****
   Note:  This procedure is called only if the change is at the line level.
****/

-- Bug 7287009
/*Added vendor id and vendor site id in the signature of the procedure
Added l_org_id variable to capture org_id*/
procedure validate_line_change (
     p_po_number IN  varchar2,  --PO # of the PO being modified or the Blanket's PO #
     p_release_number IN  number, -- Release number if the PO Type
                                  -- is release or null
     p_po_type IN  varchar2,      --  RELEASE or STANDARD.
     p_revision_num IN  number,   -- Revision number of the PO or the release
     p_tp_id  IN  number,      --  vendor_id
     p_tp_site_id     IN  number,  --  vendor_site_id
     p_line_num IN  number,       -- Line number being modified
     p_quantity IN  number,       -- The new quantity (can be null)
     p_quantity_uom IN varchar2,  -- The UOM of the new quantity
     p_price IN  number,          -- The new price value (can be null)
     p_price_currency IN  varchar2, -- The currency code of the new price
                                    --(can be null)
     p_price_uom IN  varchar2,   -- The UOM code of the new price (can be null)
     p_supplier_part_num IN varchar2, --Can be null
     p_reason IN varchar2,
     p_is_change IN OUT NOCOPY number,
     x_error_id_out IN OUT NOCOPY number,
     x_error_status_out IN OUT NOCOPY varchar2
)
is
l_line_id  number;
l_po_header_id number;
l_max_rev  number;
l_rec_cur_index number := 0;
l_old_price_currency  varchar2(10);
l_old_price number;
l_new_price number;
l_closed_code varchar2(30);
l_closed_flag varchar2(1);
l_cancel_flag varchar2(1);
l_old_supplier_part_num  varchar2(25);
l_new_supplier_part_num  varchar2(25);
l_req_status  varchar2(30);
l_po_type varchar2(25);
l_stage  varchar2(10) := 'BEGIN';
l_po_curr  varchar2(10);
l_org_id   number;
begin

 --validate the the line number exists for the po specified and
 -- get some more information about the line.
 begin

   -- Bug 7287009 - Start
   /*Used vendor id and vendor site id combination to fetch org_id.
   Org_id is used in the second query's where clause to restrict
   mutiple records fetch.*/

   SELECT org_id
   into   l_org_id
   FROM   po_vendor_sites_all
   WHERE  vendor_id = p_tp_id
          AND vendor_site_id  = p_tp_site_id;

   select
     PLA.PO_LINE_ID, PHA.PO_HEADER_ID,
     FSPA.PAYMENT_CURRENCY_CODE BUYING_ORG_CURRENCY,
     PLA.UNIT_PRICE UNIT_PRICE,
     PLA.CLOSED_CODE,PLA.CLOSED_FLAG, PLA.CANCEL_FLAG, PLA.VENDOR_PRODUCT_NUM,
     POCR.REQUEST_STATUS, PHA.CURRENCY_CODE
    into l_line_id, l_po_header_id,
       l_old_price_currency, l_old_price,
       l_closed_code, l_closed_flag, l_cancel_flag, l_old_supplier_part_num,
       l_req_status, l_po_curr

    FROM
     PO_LINES_ALL PLA,
     FINANCIALS_SYSTEM_PARAMS_ALL FSPA,
     PO_HEADERS_ALL PHA,
     PO_CHANGE_REQUESTS POCR

    WHERE

     FSPA.ORG_ID = PLA.ORG_ID AND
     pha.po_header_id = PLA.PO_HEADER_ID and
     pha.segment1 = p_po_number and
     pha.org_id = l_org_id AND
     pha.TYPE_LOOKUP_CODE = 'STANDARD' and
     PLA.line_num = p_line_num and
     PLA.PO_HEADER_ID = POCR.DOCUMENT_HEADER_ID (+) AND
     PLA.PO_LINE_ID   = POCR.DOCUMENT_LINE_ID (+) AND
     POCR.REQUEST_LEVEL	(+)= 'LINE' AND
     POCR.CHANGE_ACTIVE_FLAG (+)= 'Y';

    -- Bug 7287009 - End

     exception
     when no_data_found then
       /*
       PO_LINE_NUM_INVALID = 'The Line number LINENUM for
                              PO PONUM does not exists'.
       */
        fnd_message.set_name('PO', 'PO_LINE_NUM_INVALID');
        fnd_message.set_token('LINENUM', p_line_num, false);
        fnd_message.set_token('PONUM', p_po_number, false);

        x_error_status_out := x_error_status_out || fnd_message.get;

        x_error_id_out := 2;
        return;

	when others then
	  x_error_status_out := x_error_status_out ||
	                        'Error at finding the line info.' || SQLERRM;
	  x_error_id_out := 2;
          return;
    end;


     --Validate if there is a quantity change
     if (p_quantity is not null) then
        /*
          PO_LN_QTY_INVALID = 'Changing the quantity at
                               the line level is invalid';
        */
       	  x_error_id_out := 2;
	  x_error_status_out := x_error_status_out ||
	             	        fnd_message.get_string('PO',
	             	                               'PO_LN_QTY_INVALID');
     	return;
     end if;

     --Validate there is no change in the currency
     if (p_price_currency is not null and
         l_po_curr <> p_price_currency) then
         /*
	    PO_CURRENCY_CHG_NOT_ALLOWED = 'Existing currency  OLD_CUR is not allowed to change to  NEW_CUR.  Changing currency is not allowed.'
	  */
	  x_error_id_out := 2;
	  fnd_message.set_name('PO', 'PO_CURRENCY_CHG_NOT_ALLOWED');
	  fnd_message.set_token('OLD_CUR', l_po_curr, false);
	  fnd_message.set_token('NEW_CUR', p_price_currency, false);
          x_error_status_out := x_error_status_out || fnd_message.get;
          return;
      end if;


     --Validate price change request
     --Price change is allowed at the line level only for standard po type
     if (p_po_type = 'RELEASE' and p_price is not null) then
       /*
         PO_REL_PRICE_CHANGE_INVALID = 'At line level price cannot be
                                        changed for PO Releases.'
       */
         x_error_id_out := 2;
         x_error_status_out := x_error_status_out ||
       	                      fnd_message.get_string('PO',
       	                                 'PO_REL_PRICE_CHANGE_INVALID');
      	return;

       end if;

     if (p_price is not null and p_price = 0) then
      /*
        PO_NEW_PRICE_ZERO_INVALID = 'Price cannot be changed to zero.'
      */
	x_error_id_out := 2;
	x_error_status_out := x_error_status_out ||
			       fnd_message.get_string('PO',
			                 'PO_NEW_PRICE_ZERO_INVALID');
	return;

      end if;

      if (p_price is not null and p_price < 0) then
	/*
         PO_PRICE_LT_ZERO = 'The new quantity PRICE is less than
                              zero and it is not allowed.';
        */
        fnd_message.set_name('PO', 'PO_PRICE_LT_ZERO');
        fnd_message.set_token('PRICE', p_price, false);
        x_error_status_out := x_error_status_out || fnd_message.get;

	x_error_id_out := 2;
	return;
       end if;

       --validate the status of the po_line.
       -- We cannot 'isLineChangable' proc as we need err msg.
       if (l_cancel_flag is not null and l_cancel_flag = 'Y') then
         /*
	  PO_CHN_API_LINE_CANCELED = 'The requested line LINENUM for PO
	                              PONUM is already cancelled.  No change
	                              is allowed at this stage.'
	 */
	 x_error_id_out := 2;
	 fnd_message.set_name('PO', 'PO_CHN_API_LINE_CANCELED');
 	 fnd_message.set_token('LINENUM', p_line_num, false);
	 fnd_message.set_token('PONUM',  p_po_number, false);


	 x_error_status_out := x_error_status_out || fnd_message.get;
	 return;

       end if;



       if (l_closed_flag is not null and
          (l_closed_code = 'CLOSED' or l_closed_code = 'FINALLY CLOSED' or
           l_closed_code = 'CLOSED FOR RECEIVING' or
           l_closed_code = 'CLOSED FOR INVOICE')) then
         /*
	  PO_CHN_API_LINE_CLOSED_CODE = 'The requested line LINENUM for PO
	                                 PONUM is in the status CLOSEDCODE.
	                                 No change is allowed at this stage.'
	 */
	 x_error_id_out := 2;
	 fnd_message.set_name('PO', 'PO_CHN_API_LINE_CLOSED_CODE');
	 fnd_message.set_token('LINENUM', p_line_num, false);
	 fnd_message.set_token('PONUM',  p_po_number, false);
	 fnd_message.set_token('CLOSEDCODE',  l_closed_code, false);
       end if;
       if (l_closed_flag is not null and l_closed_flag = 'Y') then
         /*
       	  PO_CHN_API_LINE_CLOSED_FLAG = 'The requested line
       	                                LINENUM for PO PONUM is already Closed.
       	                                No change is allowed at this stage.'
       	 */
       	 x_error_id_out := 2;
       	 fnd_message.set_name('PO', 'PO_CHN_API_LINE_CLOSED_FLAG');
        	 fnd_message.set_token('LINENUM', p_line_num, false);
       	 fnd_message.set_token('PONUM',  p_po_number, false);

       	 x_error_status_out := x_error_status_out || fnd_message.get;
       	 return;

       end if;

       /* commnt: If it is RELEASE do not allow changes to supplier_item_number  */
              if (p_po_type = 'RELEASE' and p_supplier_part_num is not null) then
               /*
       	          PO_CHNAPI_RLS_INVALID_PARTNUM = 'The supplier part number
       	                                           cannot be
       	                                           changed to SUPPPARTNUM
       	                                           for a release.';
       	        */
       	fnd_message.set_name('PO', 'PO_CHNAPI_RLS_INVALID_PARTNUM');
       	fnd_message.set_token('SUPPPARTNUM', p_supplier_part_num, false);
       	x_error_status_out := x_error_status_out || fnd_message.get;

       	x_error_id_out := 2;
       	return;
       end if;

       if (p_supplier_part_num is not null and
           l_old_supplier_part_num <> p_supplier_part_num) then
           p_is_change := 1;
           l_new_supplier_part_num := p_supplier_part_num;
       else
           l_new_supplier_part_num := null;
           l_old_supplier_part_num := null;
       end if;

       if (p_price is not null and l_old_price <> p_price) then
         p_is_change := 1;
         l_new_price := p_price;
       else
         l_new_price := null;
         l_old_price := null;
       end if;

       /*  Check if there is a change request pending for that line*/
       if (l_req_status = 'PENDING' or l_req_status = 'BUYER_APP' or
           l_req_status = 'WAIT_MGR_APP') then
          /*
       	  PO_CHN_API_LINE_CHN_PEN = 'A change request for line LINENUM for
       	                             PO PONUM is pending.  No change is
       	                             allowed at this stage.'
       	 */
       	 x_error_id_out := 2;
       	 fnd_message.set_name('PO', 'PO_CHN_API_LINE_CHN_PEN');
         fnd_message.set_token('LINENUM', p_line_num, false);
       	 fnd_message.set_token('PONUM',  p_po_number, false);

       	 x_error_status_out := x_error_status_out || fnd_message.get;
       	 return;

       end if;


       /************** Store Request *********************/

      if (p_is_change = 0 or x_error_id_out <> 0) then
        return;  --There is no change or there is error.
      end if;

      /*  Ignore the revision number sent as requested by CLN team.  */
      select max(REVISION_NUM)
      into l_max_rev
      from po_headers_archive_all
      where PO_HEADER_ID = l_po_header_id;

      if (upper(p_po_type) = 'STANDARD') then
        l_po_type := 'PO';
      else
        l_po_type := p_po_type;
      end if;

      l_req_status := 'PENDING';  --'PENDING' state, initially.
      l_stage := 'Store';
      g_po_change_table.extend(1);
      l_rec_cur_index := g_po_change_table.last;
      /*  Note N/U in the following comments stands for not
          used in case of supplier change
          N/A stands for not applicable in case of LINE level.
       */

      g_po_change_table(l_rec_cur_index) := PO_CHG_REQUEST_PVT.create_pos_change_rec(
      p_Action_Type => 'MODIFICATION',
      p_Initiator => 'SUPPLIER',
      p_Request_Reason => p_reason,
      p_Document_Type => l_po_type,
      p_Request_Level => 'LINE',
      p_Request_Status => l_req_status,
      p_Document_Header_Id => l_po_header_id,
      p_PO_Release_Id => null,
      p_Document_Num => p_po_number,
      p_Document_Revision_Num => l_max_rev,
      p_Document_Line_Id => l_line_id,
      p_Document_Line_Number => p_line_num,
      p_Old_Supplier_Part_Number => l_old_supplier_part_num,
      p_New_Supplier_Part_Number => l_new_supplier_part_num,
      p_Old_Price => l_Old_Price,
      p_New_Price => l_new_price
      );


       exception
         when others then
           x_error_id_out := 2;
           x_error_status_out := x_error_status_out ||
                                'in validating the line :' || l_stage ||
                                ': ' || SQLERRM;


end validate_line_change;



/********
  Note this procedure will not check if there is a change pending
       already in the change tables as if there is a change pending
       already it would have been validated in the validate header.
********/

-- Bug 7287009
/*Added vendor id and vendor site id in the signature of the procedure
Added l_org_id variable to capture org_id*/
procedure validate_shipment_change (
       p_po_number IN  varchar2,  --PO # of the PO being modified or the Blanket's PO #
       p_release_number IN  number,   -- Release number if the PO Type is release or null
       p_po_type IN  varchar2,  --  RELEASE or STANDARD.
       p_revision_num IN  number,   -- Revision number of the PO or the release
       p_tp_id  IN  number,      --  vendor_id
       p_tp_site_id     IN  number,  --  vendor_site_id
       p_line_num IN  number,    -- Line number being modified
       p_shipment_num IN  number,    -- Shipment number (can be null if the change is at the line)
       p_quantity IN  number,    -- The new quantity (can be null)
       p_quantity_uom IN  varchar2,  -- The UOM of the new quantity
       p_price IN  number,    -- The new price value (can be null)
       p_price_currency IN  varchar2,  -- The currency code of the new price (can be null)
       p_price_uom IN  varchar2,   -- The UOM code of the new price (can be null)
       p_promised_date IN  date,         -- The new promised date (can be null)
       p_reason  IN  varchar2,
       p_ack_type  IN  varchar2,     -- 'ACCEPT' or 'REJECT' or 'MODIFICATION'
       p_so_line_number IN varchar2,
       p_is_change IN OUT NOCOPY number,
       x_error_id_out IN OUT NOCOPY number,
       x_error_status_out IN OUT NOCOPY varchar2,
       p_parent_shipment_number  number default NULL,
       p_SUPPLIER_DOC_REF       varchar2 default NULL,
       p_SUPPLIER_LINE_REF      varchar2 default NULL,
       p_SUPPLIER_SHIPMENT_REF  varchar2 default NULL
)
is
l_old_quantity  number;
l_new_quantity  number;
l_old_promised_date  date;
l_new_promised_date  date;
l_old_price number;
l_new_price number;
l_old_uom  varchar2 (10);
l_old_price_currency varchar2(10);
l_line_price_ovrride varchar2(2);
l_line_id number;
l_release_id number;
l_line_location_id number;
l_po_header_id  number;
l_max_rev  number;
l_rec_cur_index number := 0;
l_qt_recieved number := 0;
l_qt_billed number := 0;
l_closed_code  varchar2 (30);
l_closed_flag varchar2(1);
l_ack_type varchar2 (30) := null;
l_old_so_line_number varchar2(25);
l_new_so_line_number varchar2(25);
l_req_status  varchar2(30);
l_po_type varchar2(25);
l_shipment_number  number;
l_parent_line_location_id number;
l_shipment_type  varchar2(25);
l_drop_ship_flag varchar2(1);
l_return_status  varchar2(1);
l_err_msg  varchar2(2000);
l_po_curr  varchar2(10);
l_org_id   number;

begin

     if (p_parent_shipment_number is null) then
       l_shipment_number := p_shipment_num;
     else
       l_shipment_number := p_parent_shipment_number;
     end if;

     if (p_po_type = 'RELEASE') then
      begin
      -- Bug 7287009 - Start
      /*Used vendor id and vendor site id combination to fetch org_id.
      Org_id is used in the second query's where clause to restrict
      mutiple records fetch.*/

      SELECT org_id
      into   l_org_id
      FROM   po_vendor_sites_all
      WHERE  vendor_id = p_tp_id
             AND vendor_site_id  = p_tp_site_id;
      select
            PLLA.po_release_id, PLLA.LINE_LOCATION_ID,
            PLLA.PO_LINE_ID, PHA.PO_HEADER_ID,
            (PLLA.QUANTITY - PLLA.QUANTITY_CANCELLED) ORDERED_QUANTITY,
            PLLA.QUANTITY_RECEIVED, PLLA.QUANTITY_BILLED,
            --MUOMTL.UOM_CODE UOM,
            FSPA.PAYMENT_CURRENCY_CODE BUYING_ORG_CURRENCY,
            NVL(PLLA.PROMISED_DATE, PLLA.NEED_BY_DATE) PROMISED_DATE,
            PLLA.PRICE_OVERRIDE PRICE_OVERRIDE,
            PLLA.CLOSED_CODE,PLLA.CLOSED_FLAG, PLLA.SUPPLIER_ORDER_LINE_NUMBER,
            POCR.REQUEST_STATUS, PLA.ALLOW_PRICE_OVERRIDE_FLAG,
            SHIPMENT_TYPE, DROP_SHIP_FLAG, PHA.CURRENCY_CODE
            into l_release_id, l_line_location_id, l_line_id, l_po_header_id,
            l_old_quantity, l_qt_recieved, l_qt_billed,
            --l_old_uom,
            l_old_price_currency,
            l_old_promised_date, l_old_price,
            l_closed_code, l_closed_flag, l_old_so_line_number,
            l_req_status, l_line_price_ovrride,
            l_shipment_type, l_drop_ship_flag, l_po_curr
         FROM
              PO_LINE_LOCATIONS_ALL PLLA,
              PO_LINES_ALL PLA,
              FINANCIALS_SYSTEM_PARAMS_ALL FSPA,
            --  MTL_UNITS_OF_MEASURE_TL MUOMTL,
              PO_RELEASES_ALL PRAA, PO_HEADERS_ALL PHA,
              PO_CHANGE_REQUESTS POCR
           WHERE
              PLA.PO_Line_id= PLLA.PO_Line_ID and
              (PLLA.QUANTITY - PLLA.QUANTITY_CANCELLED) > 0 AND
              FSPA.ORG_ID = PLLA.ORG_ID AND
              plla.po_release_id = praa.po_release_id and
              pha.po_header_id = praa.po_header_id and
              pha.segment1 = p_po_number and
              pha.org_id = l_org_id AND
              praa.release_num = p_release_number and
              plla.shipment_num = l_shipment_number and
              PLLA.PO_HEADER_ID        = POCR.DOCUMENT_HEADER_ID (+)  AND
	      PLLA.LINE_LOCATION_ID    = POCR.DOCUMENT_LINE_LOCATION_ID (+) AND
	      POCR.REQUEST_LEVEL	(+)= 'SHIPMENT' AND
              POCR.CHANGE_ACTIVE_FLAG (+)= 'Y';
      -- Bug 7287009 - End

          exception
            when no_data_found then
                -- Check if the line number/shipment number valid.
                /*
                  PO_RLS_SHIP_NUM_INVALID = 'The shipment number SHIPNUM for
                                             the release number RELNUM of the
                                             blanket PO PONUM does not exists'.
                */
                 fnd_message.set_name('PO', 'PO_RLS_SHIP_NUM_INVALID');
                 fnd_message.set_token('SHIPNUM', l_shipment_number, false);
   	         fnd_message.set_token('PONUM', p_po_number, false);
   	         fnd_message.set_token('RELNUM', p_release_number, false);

   	         x_error_status_out := x_error_status_out || fnd_message.get;

                 x_error_id_out := 2;
                 return;

            when others then
                x_error_status_out := x_error_status_out ||
                                    'Error at finding the release old info.' ||
                                    SQLERRM;
   	        x_error_id_out := 2;
              return;

           end;


     else -- (p_po_type = 'STANDARD')
       begin
         -- Bug 7287009 - Start
         /*Used vendor id and vendor site id combination to fetch org_id.
         Org_id is used in the second query's where clause to restrict
         mutiple records fetch.*/

         SELECT org_id
         into   l_org_id
         FROM   po_vendor_sites_all
         WHERE  vendor_id = p_tp_id
                AND vendor_site_id  = p_tp_site_id;

         select
                  null, PLLA.LINE_LOCATION_ID, PLLA.PO_LINE_ID,
                  PHA.PO_HEADER_ID,
                  (PLLA.QUANTITY - PLLA.QUANTITY_CANCELLED) ORDERED_QUANTITY,
                  PLLA.QUANTITY_RECEIVED, PLLA.QUANTITY_BILLED,
                  FSPA.PAYMENT_CURRENCY_CODE BUYING_ORG_CURRENCY,
                  NVL(PLLA.PROMISED_DATE, PLLA.NEED_BY_DATE) PROMISED_DATE,
                  PLLA.PRICE_OVERRIDE PRICE_OVERRIDE,
                  PLLA.CLOSED_CODE,PLLA.CLOSED_FLAG,
                  PLLA.SUPPLIER_ORDER_LINE_NUMBER,
                  POCR.REQUEST_STATUS,
                  SHIPMENT_TYPE, DROP_SHIP_FLAG, PHA.CURRENCY_CODE
                  into l_release_id, l_line_location_id, l_line_id,
                       l_po_header_id, l_old_quantity, l_qt_recieved,
                       l_qt_billed, l_old_price_currency,
                       l_old_promised_date, l_old_price,
                       l_closed_code, l_closed_flag, l_old_so_line_number,
                       l_req_status,
                       l_shipment_type, l_drop_ship_flag, l_po_curr
               FROM
                    PO_LINE_LOCATIONS_ALL PLLA,
                    PO_LINES_ALL PLA,
                    FINANCIALS_SYSTEM_PARAMS_ALL FSPA,
                    PO_HEADERS_ALL PHA,
                    PO_CHANGE_REQUESTS POCR
                 WHERE
                    PLA.PO_Line_id= PLLA.PO_Line_ID and
                    (PLLA.QUANTITY - PLLA.QUANTITY_CANCELLED) > 0 AND
                    FSPA.ORG_ID = PLLA.ORG_ID AND
                    pha.po_header_id = PLLA.PO_HEADER_ID and
                    pha.segment1 = p_po_number and
                    pha.org_id = l_org_id AND
                    pha.TYPE_LOOKUP_CODE NOT IN ('QUOTATION','RFQ') and
                    plla.shipment_num = l_shipment_number and
                    PLA.line_num = p_line_num and
                    PLLA.PO_HEADER_ID = POCR.DOCUMENT_HEADER_ID (+)  AND
		    PLLA.LINE_LOCATION_ID = POCR.DOCUMENT_LINE_LOCATION_ID (+) AND
		    POCR.REQUEST_LEVEL	(+)= 'SHIPMENT' AND
                    POCR.CHANGE_ACTIVE_FLAG (+)= 'Y';
         -- Bug 7287009 - End
         exception
                 when no_data_found then
                 -- Check if the line number/shipment number valid.
                 /*
                    PO_STN_SHIP_NUM_INVALID = 'The shipment number SHIPNUM for the
                                               PO PONUM and the line number
                                               LINENUM does not exists'.
                 */
                 fnd_message.set_name('PO', 'PO_STN_SHIP_NUM_INVALID');
                 fnd_message.set_token('SHIPNUM', l_shipment_number, false);
         	      fnd_message.set_token('PONUM', p_po_number, false);
         	      fnd_message.set_token('LINENUM', p_line_num, false);

         	      x_error_status_out := x_error_status_out || fnd_message.get;

                   x_error_id_out := 2;
                   return;

                 when others then
                   x_error_status_out := x_error_status_out ||
                                  'Error at finding the standard old info.' ||
                                  SQLERRM;
         	   x_error_id_out := 2;
                   return;

           end;
     end if;



     if (p_quantity is not null and p_quantity < 0) then
        /*
	   PO_QTY_LT_ZERO = 'The new quantity QUANTITY is less
	                     than zero and it is not allowed.';
	*/
	fnd_message.set_name('PO', 'PO_QTY_LT_ZERO');
	fnd_message.set_token('QUANTITY', p_quantity, false);

	x_error_status_out := x_error_status_out || fnd_message.get;

        x_error_id_out := 2;
        return;
     end if;

     if (p_quantity is not null and
         (p_quantity < l_qt_recieved or p_quantity < l_qt_billed)) then
       /*
	  PO_QTY_LT_RECVD_OR_BILLED = 'The new quantity QUANTITY is less
	                               than QTYRECIEVED or QTYBILLED and
	                               it is not allowed.';
       */
       fnd_message.set_name('PO', 'PO_QTY_LT_RECVD_OR_BILLED');
       fnd_message.set_token('QUANTITY', p_quantity, false);
       fnd_message.set_token('QTYRECIEVED', l_qt_recieved, false);
       fnd_message.set_token('QTYBILLED', l_qt_billed, false);
       x_error_status_out := x_error_status_out || fnd_message.get;

       x_error_id_out := 2;
       return;
     end if;

     /***
        If p_quantity is zero we need to treat this as cancel?
        no commitment fro cln.
        If the new quantity  of a shipment is zero then change the
        action_type to CANCELLATION?.  No not a good idea.-FPJ.
        Also at this point check if the request has any other changes,
        like date, price, etc. then reject.
     ***/

     if (p_quantity is not null and p_quantity <> l_old_quantity
                       and p_ack_type <> 'CANCELLATION') then  -- added last condition for Bug# 5574841
        p_is_change := 1;
        l_new_quantity := p_quantity;

     else -- if the quantities are same
         l_old_quantity := null;
         l_new_quantity := null;

     end if;  -- End of Quantity validations.

     -- Check if the price and currency is being changed.
     --Validate there is no change in the currency
          if (p_price_currency is not null and
              l_po_curr <> p_price_currency) then
              /*
     	    PO_CURRENCY_CHG_NOT_ALLOWED = 'Existing currency  OLD_CUR is not allowed to change to  NEW_CUR.  Changing currency is not allowed.'
     	  */
     	  x_error_id_out := 2;
     	  fnd_message.set_name('PO', 'PO_CURRENCY_CHG_NOT_ALLOWED');
     	  fnd_message.set_token('OLD_CUR', l_po_curr, false);
     	  fnd_message.set_token('NEW_CUR', p_price_currency, false);
               x_error_status_out := x_error_status_out || fnd_message.get;
           return;
      end if;

     if (p_price is not null and p_price <> l_old_price) then
       p_is_change := 1;


       /*
         check if the po type is STANDARD, raise error.
         Price at the shipment level can be changed only for releases.
       */
       if (p_po_type <> 'RELEASE') then
         /*
           PO_STN_PRICE_CHANGE_INVALID = 'At shipment level price cannot
                                          be changed for STANDARD POs.'
         */
         x_error_id_out := 2;
         x_error_status_out := x_error_status_out ||
         fnd_message.get_string('PO', 'PO_STN_PRICE_CHANGE_INVALID');
     	 return;

       end if;

       if (p_po_type = 'RELEASE' and l_line_price_ovrride = 'N' and
           p_price is not null and p_price <> l_old_price
           ) then
            /*
	      PO_RLS_PRICE_CHANGE_INVALID = 'At shipment level price cannot
	                                     be changed for RELEASES POs as price
	                                     override flag is set to no.'
	    */
	    x_error_id_out := 2;
	    x_error_status_out := x_error_status_out ||
   	           fnd_message.get_string('PO', 'PO_RLS_PRICE_CHANGE_INVALID');
	    return;

       end if;

       if (p_price is not null and p_price = 0) then
         /*
          PO_NEW_PRICE_ZERO_INVALID = 'Price cannot be changed to zero.'
         */
           x_error_id_out := 2;
           x_error_status_out := x_error_status_out ||
                      fnd_message.get_string('PO', 'PO_NEW_PRICE_ZERO_INVALID');
           return;

       end if;

       if (p_price is not null and p_price < 0) then
	  /*
	      PO_PRICE_LT_ZERO = 'The new quantity PRICE is less than
	                          zero and it is not allowed.';
	   */
	   fnd_message.set_name('PO', 'PO_PRICE_LT_ZERO');
	   fnd_message.set_token('PRICE', p_price, false);
           x_error_status_out := x_error_status_out || fnd_message.get;

	  x_error_id_out := 2;
          return;
       end if;
       l_new_price := p_price;
     else  -- if the price is same
       l_old_price := null;
       l_new_price := null;

  end if;

  -- Check if the promised date is valid; Doc Submission program will
  -- validates this against need-by.
  if (p_promised_date is not null) then
    p_is_change := 1;
    if (p_promised_date < sysdate) then
      /*
         PO_NEW_PROM_DATE_IS_PAST = 'The requested date NEWPROMDATE is past;
                                     Promised Date should be a future date'
       */
        x_error_id_out := 2;
        fnd_message.set_name('PO', 'PO_NEW_PROM_DATE_IS_PAST');
	fnd_message.set_token('NEWPROMDATE',
	                      to_char(p_promised_date, 'MM/DD/YY HH:MI:SS AM'),
	                      false);

        x_error_status_out := x_error_status_out || fnd_message.get;
        return;

    end if;
    l_new_promised_date := p_promised_date;
  end if;

  if (p_promised_date is null or p_promised_date = l_old_promised_date) then
    l_new_promised_date := null;
    l_old_promised_date := null;
  end if;

  --Validate if the ack type is accept or reject do not allow changes
  if (p_ack_type is null) then
    l_ack_type := 'MODIFICATION';
  else
    l_ack_type := p_ack_type;
  end if;


   --Validate the shipment status if changes are allowed
   if (l_closed_code = 'CLOSED FOR INVOICE' or
       l_closed_code = 'CLOSED FOR RECEIVING') then
      /*
       PO_SHIPMENT_CLOSED_CODE = 'Shipment SHIPMENT for line LINENUM PO PONUM
                                  is closed for invoicing or receiving; Changes
                                  are not allowed at this stage.'
      */
	x_error_id_out := 2;
	fnd_message.set_name('PO', 'PO_SHIPMENT_CLOSED_CODE');
	fnd_message.set_token('SHIPMENT', l_shipment_number, false);
	fnd_message.set_token('LINENUM', p_line_num, false);
	fnd_message.set_token('PONUM', p_po_number, false);
	x_error_status_out := x_error_status_out || fnd_message.get;

       return;
   end if;

   if (l_closed_flag is not null and  l_closed_flag = 'Y') then
      /*
       PO_SHIPMENT_CLOSED_FLAG = 'Shipment SHIPMENT for line LINENUM PO PONUM
                                  is closed; Changes are not allowed
                                  at this stage.'
      */
     	x_error_id_out := 2;
     	fnd_message.set_name('PO', 'PO_SHIPMENT_CLOSED_FLAG');
	    fnd_message.set_token('SHIPMENT', l_shipment_number, false);
	    fnd_message.set_token('LINENUM', p_line_num, false);
	    fnd_message.set_token('PONUM', p_po_number, false);
	    x_error_status_out := x_error_status_out || fnd_message.get;
       return;
   end if;

   if (p_so_line_number is not null and
       p_so_line_number <> l_old_so_line_number) then
       p_is_change := 1;
       l_new_so_line_number := p_so_line_number;
   else
       l_new_so_line_number := null;
       l_old_so_line_number := null;

   end if;

   /*  Check if there is a change request pending for that line*/
   if (l_req_status = 'PENDING' or l_req_status = 'BUYER_APP' or
        l_req_status = 'WAIT_MGR_APP') then
   /*
     PO_CHN_API_SHIP_CHN_PEN = 'A change request for shipment SHIPNUM line
                                LINENUM for PO PONUM is pending.  No change
                                is allowed at this stage.'
   */
      x_error_id_out := 2;
      fnd_message.set_name('PO', 'PO_CHN_API_SHIP_CHN_PEN');
      fnd_message.set_token('SHIPNUM', l_shipment_number, false);
      fnd_message.set_token('LINENUM', p_line_num, false);
      fnd_message.set_token('PONUM',  p_po_number, false);

      x_error_status_out := x_error_status_out || fnd_message.get;
      return;

   end if;

  if ((l_ack_type = 'ACCEPT' or l_ack_type = 'REJECT')
       and p_is_change = 1) then
       /*
          PO_ACK_N_CHN_INVALID = 'A Shipment cannot be both acknowledged
                                  and changed at the same time.'
       */
      	x_error_id_out := 2;
      	x_error_status_out := x_error_status_out ||
      	fnd_message.get_string('PO', 'PO_ACK_N_CHN_INVALID');
        return;
    elsif ((l_ack_type = 'ACCEPT' or l_ack_type = 'REJECT') and
            p_is_change = 0) then
            p_is_change := 2;
    end if;

    if(p_parent_shipment_number is not null and
       (l_shipment_type = 'PRICE BREAK' or l_drop_ship_flag = 'Y')) then
       /*
         PO_INVALID_SHIPMENT_TYPE = 'A split request is not allowed for shipment SHIPNUM line
                                LINENUM for PO PONUM as it is a drop ship or has price break.'
       */
       x_error_id_out := 2;
      fnd_message.set_name('PO', 'PO_INVALID_SHIPMENT_TYPE');
      fnd_message.set_token('SHIPNUM', l_shipment_number, false);
      fnd_message.set_token('LINENUM', p_line_num, false);
      fnd_message.set_token('PONUM',  p_po_number, false);

      x_error_status_out := x_error_status_out || fnd_message.get;
      return;

   end if;

   --Validate request for cancellation of a shipment
   if (l_ack_type = 'CANCELLATION' and p_is_change <> 0) then
      /*
        PO_CANCEL_N_CHANGE_ERR = 'Both change and cancel request for Shipment SHIPNUM, line LINENUM, PO PONUM is not allowed.'
      */
      x_error_id_out := 2;
      fnd_message.set_name('PO', 'PO_CANCEL_N_CHANGE_ERR ');
      fnd_message.set_token('SHIPNUM', l_shipment_number, false);
      fnd_message.set_token('LINENUM', p_line_num, false);
      fnd_message.set_token('PONUM',  p_po_number, false);

      x_error_status_out := x_error_status_out || fnd_message.get;
      return;
   end if;

   if (l_ack_type = 'CANCELLATION') then
       validateCancelRequest(    p_api_version => 1.0,
           p_init_msg_list  => FND_API.G_FALSE,
           x_return_status  => l_return_status,
           p_po_header_id   => l_po_header_id,
           p_po_release_id  => l_release_id
           , p_po_line_location_id => l_line_location_id
           );


           if (l_return_status <>  FND_API.g_ret_sts_success) then
           /*
            PO_CHECK_CANCEL_ERR = 'There was an error ERRCODE in validating the cancel request for
                                   shipment SHIPNUM, line LINENUM, PO PONUM. The error message is: ERRMSG'
           */

            x_error_id_out := 2;
            l_err_msg := FND_MSG_PUB.Get(p_msg_index => 1,p_encoded => 'F');
            fnd_message.set_name('PO', 'PO_CHECK_CANCEL_ERR');
            fnd_message.set_token('ERRCODE', l_return_status, false);
            fnd_message.set_token('SHIPNUM', l_shipment_number, false);
            fnd_message.set_token('LINENUM', p_line_num, false);
            fnd_message.set_token('PONUM',  p_po_number, false);
            fnd_message.set_token('ERRMSG', l_err_msg, false);

            x_error_status_out := x_error_status_out || fnd_message.get;

            return;

        end if;
   end if;



  /*
     Note:  1.  No need to check if line is canceled or closed, etc.
               If so, the shipments are also automatically canceled or closed.
            2.  No need to check if there is a change pending here.
                If so, validate header would have raised the error.
    */
      /************** Store Request *********************/
      if ( x_error_id_out <> 0) then
        return;
      end if;
      if (p_is_change = 0 and l_ack_type <> 'CANCELLATION') then
        return;  --There is no change or there is error.
        end if;

      select max(REVISION_NUM)
      into l_max_rev
      from po_headers_archive_all
      where PO_HEADER_ID = l_po_header_id;

      if (upper(p_po_type) = 'STANDARD') then
              l_po_type := 'PO';
            else
              l_po_type := p_po_type;
      end if;

      l_req_status := 'PENDING';  -- 'PENDING' state, initially.
      g_po_change_table.extend(1);
      l_rec_cur_index := g_po_change_table.last;
            /*  Note N/U in the following comments stands
                for not used in case of supplier change
                N/A stands for not applicable in case of SHIPMENT level.
             */

              /*  Added in FPJ for split
	           If p_parent_shipment_number is not null, then we are splitting.
	           so, l_document_line_location_id is the parent's line_location_id.
	           In that case we will pass the
	           l_document_line_location_id as l_parent_line_location_id.
	           l_document_line_location_id as null,
	           set the old values for qt, price, promised date to null
	           get new value for l_document_shipment_number
	        */
	        if (p_parent_shipment_number is not null) then
	          l_parent_line_location_id := l_line_location_id;
	          l_line_location_id := null;
	          --l_shipment_number := null;
	          getNewShipmentNumber (l_line_id, l_shipment_number);
	          l_old_price := null;
	          l_old_quantity := null;
	          l_old_promised_date := null;
	          l_old_so_line_number := null;
              end if;


      g_po_change_table(l_rec_cur_index) := PO_CHG_REQUEST_PVT.create_pos_change_rec(
            p_Action_Type => l_ack_type,
            p_Initiator => 'SUPPLIER',
            p_Request_Reason => p_reason,
            p_Document_Type => l_po_type,
            p_Request_Level => 'SHIPMENT',
            p_Request_Status => l_req_status,
            p_Document_Header_Id => l_po_header_id,
            p_PO_Release_Id => l_release_id,
            p_Document_Num => p_po_number,
            p_Document_Revision_Num => l_max_rev,
            p_Document_Line_Id => l_line_id,
            p_Document_Line_Number => p_line_num,
            p_Document_Line_Location_Id => l_line_location_id,
            p_Document_Shipment_Number => l_shipment_number ,
            p_Parent_Line_Location_Id => l_parent_line_location_id,
            p_Old_Quantity => l_old_quantity,
            p_New_Quantity => l_new_quantity,
            p_Old_Promised_Date => l_old_promised_date,
            p_New_Promised_Date => l_new_promised_date,
            p_Old_Price => l_Old_Price,
            p_New_Price => l_new_price,
            p_Old_Supplier_Order_Line_Num => l_old_so_line_number,
            p_New_Supplier_Order_Line_Num => l_new_so_line_number,
            p_SUPPLIER_DOC_REF => p_SUPPLIER_DOC_REF,
            p_SUPPLIER_LINE_REF => p_SUPPLIER_LINE_REF,
            p_SUPPLIER_SHIPMENT_REF => p_SUPPLIER_SHIPMENT_REF

      );


  exception
  when others then
    x_error_id_out := 2;
    x_error_status_out := x_error_status_out || SQLERRM;


end validate_shipment_change;


/***********************   PUBLIC APIs  ****************************/

/*
  This procedure needs to be called first to initialize an inbound transaction.
  This will initialize some global variables.  This should be called from the
  pre-process of the root node.  No errors should occur here lest there is any
  weird error, processing should not continue, as it has not been
  initialized properly.
*/
procedure  initialize_chn_ack_inbound (
   	p_requestor	IN  varchar2,
	p_int_cont_num	IN  varchar2,  -- ECX's ICN.
	p_request_origin	IN  varchar2,  -- '9iAS'
	p_tp_id	IN  number,    --  vendor_id
	p_tp_site_id	IN  number,    --  vendor_site_id
	x_error_id	OUT NOCOPY number,
	x_error_status	OUT NOCOPY VARCHAR2


) is
l_user_id   number;
begin
  x_error_id := 0;
  x_error_status := '';
  g_int_cont_num := p_int_cont_num;
  g_requestor := p_requestor;
  g_request_origin  := p_request_origin;

   --ideally we should check if the requestor belongs to the tp_id and tp_site_id provided.
   begin
        select user_id
        into l_user_id
        from fnd_user
        where user_name = p_requestor;  --ideally it should be 'XML_USER'
      exception when others then
        /*
          PO_CHN_XML_USER_INVALID = "The  USERNAME is not a valid user
                                     in the system.
                                     Please consult your system administrator."
        */
        fnd_message.set_name('PO', 'PO_CHN_XML_USER_INVALID ');
        fnd_message.set_token('USERNAME', p_requestor, false);
        x_error_status := x_error_status || fnd_message.get;
        x_error_id := 2;
        return;

      end;


  if (g_po_change_table is not null) then
      g_po_change_table.delete;
      g_po_change_table := null;
  end if;
  --reinitilize the global variable.
  g_po_change_table := pos_chg_rec_tbl();
  g_po_type := null;
  g_po_number := null;
  g_release_number := null;
  g_tp_id := null;
  g_tp_site_id := null;

  exception
  when others then
   x_error_id := 2;
  	x_error_status := x_error_status || SQLERRM;

end initialize_chn_ack_inbound;




/*
  This API should be called from the in process of the header level.
  This will validate the header, if the PO #/Release  mentioned belongs
  to the vendor and vendor site id,
*/
procedure validate_header (
   	p_requestor	IN  varchar2,
	p_int_cont_num	IN  varchar2,
	p_request_origin	IN  varchar2,  -- XML/OTA/9iAS/OPEN
	p_request_type	IN  varchar2,    -- 'CHANGE' or 'ACKNOWLEDGE' or CANCELLATION
	p_tp_id	IN  number,    --  vendor_id
	p_tp_site_id	IN  number,
	p_po_number	IN  varchar2,
	p_release_number	IN  number,
	p_po_type 	IN  varchar2,
	p_revision_num	IN  number,
	x_error_id_in	IN  number,
	x_error_status_in IN  VARCHAR2,
	x_error_id_out	OUT NOCOPY number,
	x_error_status_out OUT NOCOPY VARCHAR2 -- Error message

) is
l_count  number := 0;
l_po_status  varchar2(25);
l_rel_status varchar2(25);
l_po_header_id number;
l_release_id number := null;
l_org_id number;
--l_can_cancel_status varchar2 (2000) := null;
begin
  x_error_id_out := x_error_id_in;
  x_error_status_out := x_error_status_in;

  -- Bug 7287009 - Start
  /*Used vendor id and vendor site id combination to fetch org_id.
  Org_id is used in the second query's where clause to restrict
  mutiple records fetch.*/

  SELECT org_id
  into   l_org_id
  FROM   po_vendor_sites_all
  WHERE  vendor_id = p_tp_id
         AND vendor_site_id  = p_tp_site_id;

  -- Bug 7287009 - End


  --Check if the given release  exists and belongs to the given TP
  if ('RELEASE' = upper(p_po_type) ) then
    select count(1) into l_count
    from po_releases_all pra, po_headers_all pha
    where pra.po_header_id = pha.po_header_id
    and pra.release_num = p_release_number
    and pha.segment1 = p_po_number
    and pha.org_id = l_org_id
    and pha.TYPE_LOOKUP_CODE NOT IN ('QUOTATION','RFQ');

    if (l_count < 1) then
     /*
       PO_REL_NUM_NOT_FOUND = "The  RELNUMBER with the blanket  PONUMBER
                                does not belong to the given supplier."
     */
     --Check: Lets not worry about providing the supplier name.
     fnd_message.set_name('PO', 'PO_REL_NUM_NOT_FOUND');
     fnd_message.set_token('PONUMBER', p_po_number, false);
     fnd_message.set_token('RELNUMBER', p_release_number	, false);
     x_error_status_out := x_error_status_out || fnd_message.get;
     x_error_id_out := 2;
     return;
    end if;

  else -- assume that it is a STANDARD PO
  --Check if the given PO  exists and belongs to the given TP
    select count(1) into l_count
      from po_headers_all pha
      where pha.segment1 = p_po_number
      and pha.org_id = l_org_id
      AND pha.TYPE_LOOKUP_CODE NOT IN ('QUOTATION','RFQ');

    if (l_count < 1) then
    /*
      PO_PO_NUM_NOT_FOUND = "The PO number  PONUMBER does not belong to the given supplier."
    */
     fnd_message.set_name('PO', 'PO_PO_NUM_NOT_FOUND');
     fnd_message.set_token('PONUMBER', p_po_number, false);
     x_error_status_out := x_error_status_out || fnd_message.get;
     x_error_id_out := 2;
     return;
    end if;
 end if;

   -- There is a corner case where the same segment1 can
   -- belong to more than one org.  In that case return error.
   if (l_count > 1) then
   /*
         PO_PO_NUM_AMBIGUOUS = "The PO number  PONUMBER is ambiguous.
          Please contact system admin."?
    */
     fnd_message.set_name('PO', 'PO_PO_NUM_AMBIGUOUS');
     fnd_message.set_token('PONUMBER', p_po_number, false);
     x_error_status_out := x_error_status_out || fnd_message.get;
     x_error_id_out := 2;
     return;
   end if;

 --From here onwards PO is Valid

 --Check to see if the given PO or Release is in the right status
 --to recieve change or acknowledge.

 select authorization_status, po_header_id, last_update_date
   into l_po_status, l_po_header_id, g_last_upd_date
 from po_headers_all
 where segment1 = p_po_number
       and org_id = l_org_id
       and TYPE_LOOKUP_CODE NOT IN ('QUOTATION','RFQ');

 --Common validation for STANDARD and BLANKET PO for both CHANGE and ACKNOWLEDGE
 if (l_po_status in ('CANCELLED', 'CLOSED', 'FINALLY CLOSED',
                     'CLOSED FOR INVOICE', 'CLOSED FOR RECEIVING',
                     'SUPPLIER_CHANGE_PENDING', 'FROZEN',
                     'ON HOLD', 'PARTIALLY_ACKNOWLEDGED',
                     'INTERNAL CHANGE', 'REJECTED',
                     'IN PROCESS')) then
 --billOnlyFlag.equals("Y") ||^M
 --!(gaValid.equals("Y")) ||^M)
      /*
          PO_INVALID_STATUS_CODE = "The PO  PONUMBER is currently in
                                    POSTATUSCODE.  At this stage no
                                    modifictions to the PO is allowd."
      */
       fnd_message.set_name('PO', 'PO_INVALID_STATUS_CODE');
       fnd_message.set_token('PONUMBER', p_po_number, false);
       fnd_message.set_token('POSTATUSCODE', l_po_status, false);

       x_error_status_out := x_error_status_out || fnd_message.get;

       x_error_id_out := 2;
     return;
   end if;

 if (upper(p_request_type) = 'CHANGE') then
    if (l_po_status = 'ACK_REQUIRED') then
         /*
             PO_STD_INVALID_STATUS_CODE = "The PO  PONUMBER is currently in
                                           POSTATUSCODE.  At this stage no
                                           modifictions to the PO is allowed."
         */
          fnd_message.set_name('PO', 'PO_STD_INVALID_STATUS_CODE');
          fnd_message.set_token('PONUMBER', p_po_number, false);
          fnd_message.set_token('POSTATUSCODE', l_po_status, false);

          x_error_status_out := x_error_status_out || fnd_message.get;

          x_error_id_out := 2;
          return;
    end if;
 elsif (upper(p_request_type) = 'ACKNOWLEDGE') then
 null;  -- The common validations should be enough

 elsif (upper(p_request_type) = 'CANCELLATION') then
    --This will be handled as header level changes.
    null;
 else
   /*
       PO_INVALID_REQUEST_TYPE = "The request type REQUESTTYPE is not valid.
                                  It should be CHANGE or ACKNOWLEDGE"
   */
    fnd_message.set_name('PO', 'PO_INVALID_REQUEST_TYPE');
    fnd_message.set_token('REQUESTTYPE', p_request_type, false);
    x_error_status_out := x_error_status_out || fnd_message.get;
    x_error_id_out := 2;
    return;

 end if;

   /***  Validate the releases  ***/
   if ('RELEASE' = upper(p_po_type) ) then

      select authorization_status, po_release_id, last_update_date
      into l_rel_status, l_release_id, g_last_upd_date
      from po_releases_all
      where po_header_id = l_po_header_id and release_num = p_release_number;

       --Common validation for RELEASE for both CHANGE and ACKNOWLEDGE
      if (l_rel_status in ('CANCELLED', 'CLOSED', 'FINALLY CLOSED',
                           'CLOSED FOR INVOICE', 'CLOSED FOR RECEIVING',
                           'SUPPLIER_CHANGE_PENDING', 'FROZEN',
                           'ON HOLD',  'PARTIALLY_ACKNOWLEDGED',
                           'INTERNAL CHANGE', 'REJECTED',
                           'IN PROCESS')) then
    --billOnlyFlag.equals("Y") ||^M
    --!(gaValid.equals("Y")) ||^M)
         /*
             PO_INVALID_STATUS_CODE_REL = "The Release RELNUM for PO  PONUMBER
                                           is currently in  RELSTATUSCODE.
                                           At this stage no modifictions to
                                           the PO is allowed."
         */

          fnd_message.set_name('PO', 'PO_INVALID_STATUS_CODE_REL');
          fnd_message.set_token('RELNUM', p_release_number, false);
          fnd_message.set_token('PONUMBER', p_po_number, false);
          fnd_message.set_token('RELSTATUSCODE', l_rel_status, false);

          x_error_status_out := x_error_status_out || fnd_message.get;

          x_error_id_out := 2;
        return;
      end if;

    if (upper(p_request_type) = 'CHANGE') then
        if (l_po_status = 'ACK_REQUIRED') then
          /*
	    PO_INVALID_STATUS_CODE_REL = "The Release RELNUM for PO  PONUMBER
	                                  is currently in  RELSTATUSCODE.
	                                  At this stage no modifictions
	                                  to the PO is allowed."
	  */

	  fnd_message.set_name('PO', 'PO_INVALID_STATUS_CODE_REL');
	  fnd_message.set_token('RELNUM', p_release_number, false);
	  fnd_message.set_token('PONUMBER', p_po_number, false);
          fnd_message.set_token('RELSTATUSCODE', l_po_status, false);

          x_error_status_out := x_error_status_out || fnd_message.get;

          x_error_id_out := 2;
          return;
         end if;
     elsif (upper(p_request_type) = 'ACKNOWLEDGE') then
        null;  -- The common validations for release should be enough
     elsif (upper(p_request_type) = 'CANCELLATION') then
         --this will be handled as a header level change.
              null;

     else
      /*
          PO_INVALID_REQUEST_TYPE = "The request type REQUESTTYPE is not valid.
                                     It should be CHANGE or ACKNOWLEDGE"
      */
       fnd_message.set_name('PO', 'PO_INVALID_REQUEST_TYPE');
       fnd_message.set_token('REQUESTTYPE', p_request_type, false);
       x_error_status_out := x_error_status_out || fnd_message.get;
       x_error_id_out := 2;
       return;

      end if;


   end if; -- if p_po_type = 'RELEASE'


   --update the global variables
   g_po_type := p_po_type;
   g_po_number := p_po_number;
   g_release_number := p_release_number;
   g_tp_id := p_tp_id;
   g_tp_site_id := p_tp_site_id;

   /***  Handle Sales Order Change  ***/


  exception
  when others then
   x_error_id_out := 2;
   x_error_status_out := x_error_status_out || SQLERRM;


end;

/*
  This API should be called from the in process of the lines.
  This procedure needs to be called in the following scenarios:
1.	Modifications to a PO at the shipment level
2.	Modifications to a PO at the line level
3.	Acknowledgment at the shipment level
4.	Canceling at the shipment level
   Calls to this API will be stored in a pl/sql table and will
   not be processed immediately.
   Call process_supplier_request to process the request.
*/
procedure store_supplier_request (
	p_requestor	IN  varchar2,
	p_int_cont_num	IN  varchar2,
	p_request_type	IN  varchar2,
	p_tp_id	IN  number,
	p_tp_site_id	IN  number,
	p_level         IN varchar2,
        p_po_number	IN  varchar2,
        p_release_number IN  number,
	p_po_type 	IN  varchar2,
        p_revision_num	IN  number,
	p_line_num	IN  number,
	p_reason	IN  varchar2,
	p_shipment_num	IN  number,
	p_quantity	IN  number,
	p_quantity_uom	IN  varchar2,
	p_price	IN  number,
	p_price_currency IN  varchar2,
	p_price_uom	IN  varchar2,
        p_promised_date	IN  date,
	p_supplier_part_num IN  varchar2,
	p_so_number	IN  varchar2,
	p_so_line_number IN  varchar2,
	p_ack_type      IN  varchar2,
        x_error_id_in	IN     number,
  	x_error_status_in IN   varchar2,
        x_error_id_out	OUT NOCOPY number,
        x_error_status_out OUT NOCOPY varchar2,
        p_parent_shipment_number  number default NULL,
	p_SUPPLIER_DOC_REF       varchar2 default NULL,
	p_SUPPLIER_LINE_REF      varchar2 default NULL,
        p_SUPPLIER_SHIPMENT_REF  varchar2 default NULL
) is
l_is_change  number :=0;
l_reason varchar2(2000);
begin
  x_error_id_out := x_error_id_in;
  x_error_status_out := x_error_status_in;

  -- validate parameters with the global variables.

  if ( p_int_cont_num	<> g_int_cont_num OR
       p_po_number <> g_po_number OR
       p_po_type <> g_po_type OR
       p_tp_id <> g_tp_id OR
       p_tp_site_id <> g_tp_site_id) then
  	x_error_id_out := 2;
  	x_error_status_out := x_error_status_out ||
  	           fnd_message.get_string('PO', 'PO_CHG_API_CALL_NOT_SYNC');
  	return;
  end if;

  /************** Validations ***********************/
  --Check the length of the reason;
  --it should not be more than 2000 bytes; if so truncate it.
  if (p_reason is null) then

       if (p_level = 'SHIPMENT') then
          /*
               PO_CHG_API_SH_REASON_IS_NULL = Reason cannot be null for
                                              line LINENUM and shipment SHIPNUM
           */
            fnd_message.set_name('PO', 'PO_CHG_API_SH_REASON_IS_NULL');
            fnd_message.set_token('LINENUM', p_line_num, false);
            fnd_message.set_token('SHIPNUM', p_shipment_num, false);
        elsif (p_level = 'LINE') then
            /*
            PO_CHG_API_LN_REASON_IS_NULL = Reason cannot be null for
                                           line LINENUM
            */
            fnd_message.set_name('PO', 'PO_CHG_API_LN_REASON_IS_NULL');
            fnd_message.set_token('LINENUM', p_line_num, false);
         else --if p_level = HEADER
         /*
            PO_CHG_API_REASON_IS_NULL Reason cannot be null for PONUM
          */
            fnd_message.set_name('PO', 'PO_CHG_API_REASON_IS_NULL');
            fnd_message.set_token('PONUM', p_po_number, false);
        end if;

        x_error_status_out := x_error_status_out || fnd_message.get;
        x_error_id_out := 2;


        return;

  end if;


  if (p_reason is not null) then
    l_reason := substr(ltrim(rtrim(p_reason, ' , 	'), ' ,	'), 1, 2000);
  else
     l_reason := p_reason;
  end if;

  -- For shipment level validations
  -- Bug 7287009 - Start
  /*Added vendor id and vendor site id in the parameter list*/
  if (p_level = 'SHIPMENT') then
    validate_shipment_change (p_po_number, p_release_number,
                              p_po_type, p_revision_num,
                              p_tp_id, p_tp_site_id,
                              p_line_num, p_shipment_num, p_quantity,
                              p_quantity_uom, p_price, p_price_currency,
                              p_price_uom, p_promised_date, l_reason,
                              p_ack_type, p_so_line_number, l_is_change,
    			      x_error_id_out, x_error_status_out,
    			      p_parent_shipment_number,
			      p_SUPPLIER_DOC_REF, p_SUPPLIER_LINE_REF,
                              p_SUPPLIER_SHIPMENT_REF
    			     );
    -- Bug 7287009 - End
    if (x_error_id_out <> 0) then
      return;
    end if;
  end if;

  -- Bug 7287009 - Start
  /*Added vendor id and vendor site id in the parameter list*/
  if (p_level = 'LINE') then
    validate_line_change(p_po_number, p_release_number,
                         p_po_type, p_revision_num,
                         p_tp_id, p_tp_site_id,
    		         p_line_num, p_quantity,
    			 p_quantity_uom, p_price, p_price_currency, p_price_uom,
    			 p_supplier_part_num, l_reason,
    			 l_is_change, x_error_id_out, x_error_status_out
    				);
    -- Bug 7287009 - End

    if (x_error_id_out <> 0) then
      return;
    end if;
  end if;

  -- Bug 7287009 - Start
  /*Added vendor id and vendor site id in the parameter list*/

  if (p_level = 'HEADER') then
    handle_header_level_requests(p_po_number, p_release_number,
                               p_po_type, p_revision_num,
                               p_tp_id, p_tp_site_id,
    			       p_reason, p_ack_type, p_so_number,
    			       l_is_change, x_error_id_out, x_error_status_out
                               );
    -- Bug 7287009 - End

  end if;




  exception
  when others then
   x_error_id_out := 2;
  	x_error_status_out := x_error_status_out || SQLERRM;

end store_supplier_request;

/*
  Call this procedure from the post-process before calling the wind-up API
  only if the error_id from the earlier calls is 0.  This API should not
  be called if the request is for header level acknowledgment.
  This API will place the supplier request in the change request
  table and kicks-off the workflow for the approval of the change request.
*/
procedure process_supplier_request (
	p_int_cont_num	IN varchar2,
	x_error_id_in   IN number,
	x_error_status_in IN varchar2,
	x_error_id_out	OUT NOCOPY number,
	x_error_status_out OUT NOCOPY VARCHAR2
) is
l_pos_errors POS_ERR_TYPE;
l_po_header_id  number;
l_po_release_id  number;
l_revision_num number;
l_online_report_id number := 0;
i number;
l_po_tbl_varchar2000 po_tbl_varchar2000 := null;
l_err_count   number := 0;
l_user_id     number;

begin
  x_error_id_out := x_error_id_in;
  x_error_status_out := x_error_status_in;

 --dbms_output.put_line('x_error_status_out inside1 : ' || x_error_status_out);

 --validate the global information

 if ( p_int_cont_num	<> g_int_cont_num ) then
       x_error_id_out := 2;
       x_error_status_out := x_error_status_out ||
       fnd_message.get_string('PO', 'PO_CHG_API_CALL_NOT_SYNC');
       return;
  end if;


  if ( g_po_change_table is null OR g_po_change_table.count = 0) then
    x_error_id_out := 0;  --No change found.Do not error;but do not process.
    x_error_status_out := x_error_status_out ||
    fnd_message.get_string('PO', 'PO_CHG_API_NO_CHANGE_FOUND');
    return;
  end if;

  --dbms_output.put_line('x_error_status_out inside2 : ' || x_error_status_out);

 l_po_header_id := g_po_change_table(g_po_change_table.FIRST).Document_Header_Id;
 l_po_release_id := g_po_change_table(g_po_change_table.FIRST).PO_Release_Id;
 l_revision_num := g_po_change_table(g_po_change_table.FIRST).Document_Revision_Num;
 select user_id
        into l_user_id
        from fnd_user
        where user_name = g_requestor;

 --dbms_output.put_line('x_error_status_out inside3 : ' || x_error_status_out);
 PO_CHG_REQUEST_PVT.process_supplier_request (
             p_po_header_id  =>l_po_header_id,
             p_po_release_id  => l_po_release_id,
             p_revision_num   =>l_revision_num,
             p_po_change_requests => g_po_change_table,
             x_online_report_id  => l_online_report_id,
             x_pos_errors        => l_pos_errors,
             p_chn_int_cont_num  => g_int_cont_num,
             p_chn_source    => g_request_origin,
             p_chn_requestor_username  => g_requestor,
             p_user_id  =>  l_user_id,
             p_login_id  => l_user_id,
             p_last_upd_date => g_last_upd_date) ;



/*
 FOR i IN l_pos_errors.FIRST..l_pos_errors.LAST LOOP
    x_error_id_out := 2;
    x_error_status_out := x_error_status_out ||
                          l_pos_errors(i).text_line; --buffer overflow?
 end loop;
 */

 if (l_pos_errors is not null) then
   l_po_tbl_varchar2000 := l_pos_errors.text_line;

   --dbms_output.put_line('x_error_status_out inside5 : '
   --|| x_error_status_out);
   if (l_po_tbl_varchar2000 is not null ) then
   --dbms_output.put_line('x_error_status_out inside5^ : '
   --|| x_error_status_out);
     l_err_count := l_po_tbl_varchar2000.count;
   end if;

   if (l_err_count > 0) then
   --dbms_output.put_line('x_error_status_out inside5^^ : '
   --|| x_error_status_out);

   FOR i IN 1..l_err_count LOOP
       x_error_id_out := 2;
       --dbms_output.put_line('x_error_status_out inside6 : '
       --|| x_error_status_out);

       x_error_status_out := x_error_status_out || l_po_tbl_varchar2000(i);
       --dbms_output.put_line('x_error_status_out inside7 : '
       --|| x_error_status_out);
     end loop;
   end if;
end if;
 --dbms_output.put_line('x_error_status_out inside8 : '
 --|| x_error_status_out);
   exception
    when others then
     x_error_id_out := 2;


   begin
   --dbms_output.put_line('x_error_status_out inside9 : ' ||
   -- x_error_status_out);
     x_error_status_out := x_error_status_out || SQLERRM;
     --dbms_output.put_line('x_error_status_out inside10 : ' ||
     --x_error_status_out);
     exception  --may errorout due to bufferoverflow.
       when others then
       return;
   end;


end process_supplier_request;

/*
  This procedure needs to be called from Acknowledge PO inbound
  at in_process of the header, only when the PO is acknowledged
  at the header level.  In case of shipment level acknowledgement
  this procedure should not be called.  The acknowledge po request
  will be processed immediately and only once per transaction.
  So, no need for error_id_in and error_id_out etc.
*/
procedure acknowledge_po(
	p_requestor	IN  varchar2,
	p_int_cont_num	IN  varchar2,
	p_request_type	IN  varchar2,
	p_tp_id	IN  number,
	p_tp_site_id	IN  number,
        p_po_number	IN  varchar2,
        p_release_number	IN  number,
	p_po_type 	IN  varchar2,
        p_revision_num	IN  number,
	p_ack_code	IN  number,   -- 0 for accept 2 reject
	p_ack_reason	IN  varchar2,
	x_error_id	OUT NOCOPY number,
	x_error_status	OUT NOCOPY VARCHAR2

) is
 l_po_header_id     VARCHAR2(30);
 l_po_release_id     VARCHAR2(30) := null;
 l_po_buyer_id       VARCHAR2(30);
 l_po_accept_reject  VARCHAR2(30);
 l_po_acc_type_code  VARCHAR2(30);
 l_po_ack_comments   VARCHAR2(2000);
 l_user_id           VARCHAR2(30);
 l_org_id            number;

 --Bug 6850595
 /*Added the follwoing variables.
 l_last_update_date is added to check the concurrency when the same PO is modified in different places.
 x_error is added to check if there are any concurrency issues. If x_error is true then it will raise
 concurrency exception.
 l_concurrency_exception is added to raise the exception in case if there are any concurrency issues. */

 l_last_update_date po_headers_all.last_update_date%type;
 x_error VARCHAR2(30);
 l_concurrency_exception EXCEPTION;

begin

	/*
	  Note: The header is validated already at the validate_header stage.
	*/
        -- Bug 7287009 - Start
        /*Used vendor id and vendor site id combination to fetch org_id.
        Org_id is used in the second query's where clause to restrict
        mutiple records fetch.*/

        SELECT org_id
        into   l_org_id
        FROM   po_vendor_sites_all
        WHERE  vendor_id = p_tp_id
               AND vendor_site_id  = p_tp_site_id;

	select to_char(po_header_id), to_char(agent_id), LAST_UPDATE_DATE
	into l_po_header_id, l_po_buyer_id, l_last_update_date
	from po_headers_all
	where segment1 = p_po_number
              and org_id = l_org_id
              AND TYPE_LOOKUP_CODE NOT IN ('QUOTATION','RFQ');
        -- Bug 7287009 - End

	select to_char(user_id)
	into l_user_id
	from fnd_user
        where user_name = p_requestor;

	if (p_po_type = 'RELEASE') then
	  select to_char(po_release_id), to_char(agent_id), LAST_UPDATE_DATE
	  into l_po_release_id, l_po_buyer_id, l_last_update_date
	  from po_releases_all praa
	  where po_header_id = l_po_header_id
	        and RELEASE_NUM = p_release_number;
	end if;

	if (p_ack_code = 0) then
	  l_po_accept_reject := 'Y';
	elsif (p_ack_code = 2) then
	  l_po_accept_reject := 'N';
	elsif (p_ack_code = 1) then
	 /*
	  PO_CHN_API_ACK_CODE_1 = 'Accept with changes is not supported
	                           through this API; Context: PONUM'
	 */
	 x_error_id := 2;
	 fnd_message.set_name('PO', 'PO_CHN_API_ACK_CODE_1');
	 fnd_message.set_token('PONUM',  p_po_number, false);

	 x_error_status := x_error_status || fnd_message.get;
       	 return;
	else
	  /*
	  PO_CHN_API_ACK_CODE_INVALID = 'AckCode of ACKCODE is invalid.
	                                 It shoule either 0 for ACCEPT
	                                 or 2 for REJECT; Context: PONUM'
	 */
	 x_error_id := 2;
	 fnd_message.set_name('PO', 'PO_CHN_API_ACK_CODE_INVALID');
	 fnd_message.set_token('ACKCODE',  p_po_number, false);
	 fnd_message.set_token('PONUM',  p_po_number, false);

	 x_error_status := x_error_status || fnd_message.get;
       	 return;
	end if;

        --Bug 6850595
        /* l_last_update_date is passed as an input parameter to check the
        concurrency issue. x_error is an out variable, which captures errors
        if there are any exceptions. */

	POS_ACK_PO.ACKNOWLEDGE_PO (
	     l_po_header_id,
	     l_po_release_id,
	     l_po_buyer_id,
	     l_po_accept_reject,
	     l_po_acc_type_code,  --Should be always null from FPI.
	     p_ack_reason,
	     l_user_id,
             l_last_update_date,
             x_error);

        IF x_error = 'true' THEN
          RAISE l_concurrency_exception;
        END IF;

exception
  when others then
   x_error_id := 2;
  	x_error_status := x_error_status || SQLERRM;
end acknowledge_po;

/*
  	Call this procedure at the post process stage as the last action.
  	At this point the pl/sql table will be 'delete'd.  Call this
  	procedure even if there were errors in the earlier calls.
*/
procedure  windup_chn_ack_inbound (
   	p_requestor	IN  varchar2,
	p_int_cont_num	IN  varchar2,
	p_request_origin IN  varchar2,
	p_tp_id	IN  number,
	p_tp_site_id	IN  number,
       x_error_id_in	IN  number,
  	x_error_status_in IN   varchar2,
	x_error_id_out	OUT NOCOPY number,
	x_error_status_out OUT NOCOPY VARCHAR2
) is
begin
/*  We have no use of these global variables; so erase them;
*/

  x_error_id_out := x_error_id_in;
  x_error_status_out := x_error_status_in;

  g_int_cont_num := null;

  if (g_po_change_table is not null) then
      g_po_change_table.delete;
      g_po_change_table := null;
  end if;

  g_po_type := null;
  g_po_number := null;
  g_release_number := null;
  g_tp_id := null;
  g_tp_site_id := null;

exception
  when others then
   x_error_id_out := 2;
   x_error_status_out := x_error_status_out || SQLERRM;
end windup_chn_ack_inbound;

end PO_CHG_REQUEST_GRP;




/
