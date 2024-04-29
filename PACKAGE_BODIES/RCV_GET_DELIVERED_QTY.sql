--------------------------------------------------------
--  DDL for Package Body RCV_GET_DELIVERED_QTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_GET_DELIVERED_QTY" AS
/* $Header: RCVDELQB.pls 115.6 2004/05/26 01:35:53 wkunz ship $*/

PROCEDURE GET_TRANSACTION_DETAILS ( x_vendor_id         in      number,
                                    x_vendor_site_id    in      number,
                                    x_item_id           in      number,
                                    x_start_date        in      date,
                                    x_end_date          in      date,
                                    x_delivered_qty     out NOCOPY     number ) IS

          x_progress   VARCHAR2(3) := '000';

          cursor transaction_details_c is

                 /*
                 SELECT rct.transaction_type      trans_type,
                        rct.transaction_id        trans_id,
                        rct.parent_transaction_id parent_trans_id,
                        rct.primary_quantity      trans_qty
                 FROM   rcv_shipment_lines rsl,
                        po_headers_all poh,
                        rcv_transactions rct
                 WHERE  rct.source_document_code = 'PO'
                 AND    rsl.item_id = x_item_id
                 AND    rsl.po_header_id = poh.po_header_id
                 AND    poh.vendor_id = x_vendor_id
                 AND    NVL(poh.vendor_site_id,-99) = NVL(x_vendor_site_id,-99)
                 AND    rct.shipment_line_id = rsl.shipment_line_id
                 AND    rct.transaction_type = 'DELIVER'
                 AND    rct.transaction_date between x_start_date and x_end_date;
                 */

                 /* Bug# 2449044 */

                 SELECT rct.transaction_type      trans_type,
                        rct.transaction_id        trans_id,
		        rct.parent_transaction_id parent_trans_id,
                        rct.primary_quantity      trans_qty
	         FROM   rcv_shipment_lines rsl,
                        rcv_transactions rct
		 WHERE  rct.source_document_code = 'PO'
		 AND    rsl.item_id = x_item_id
   		 AND    rct.shipment_line_id = rsl.shipment_line_id
   		 AND    rct.transaction_type = 'DELIVER'
   		 AND    rct.transaction_date between x_start_date and x_end_date
		 AND    exists
      		        (SELECT 1 FROM po_headers_all poh
        		 WHERE  rsl.po_header_id = poh.po_header_id
          		 AND    NVL(poh.vendor_site_id,-99) = NVL(x_vendor_site_id,-99)
          		 AND    poh.vendor_id = x_vendor_id
          		 AND    rownum = 1);

          std_rec transaction_details_c%rowtype;

          cursor child_details_c is
                 SELECT rct.transaction_type      trans_type,
                        rct.transaction_id        trans_id,
                        rct.parent_transaction_id parent_trans_id,
                        rct.primary_quantity      trans_qty
                 FROM   rcv_transactions rct
                 WHERE  rct.parent_transaction_id = std_rec.trans_id;

          child_rec child_details_c%rowtype;

begin

          x_delivered_qty := 0;

          open transaction_details_c;

          x_progress := '001';

          loop
               fetch transaction_details_c into std_rec;
               exit when transaction_details_c%notfound;

               x_delivered_qty := x_delivered_qty + std_rec.trans_qty;

               open child_details_c;

               x_progress := '002';

               loop
                    fetch child_details_c into child_rec;
                    exit when child_details_c%notfound;

                    if (child_rec.trans_type = 'CORRECT') then
                       x_delivered_qty := x_delivered_qty + child_rec.trans_qty;
                    elsif (child_rec.trans_type = 'RETURN TO VENDOR' or
                           child_rec.trans_type = 'RETURN TO RECEIVING') then
                       x_delivered_qty := x_delivered_qty - child_rec.trans_qty;
                    end if;
               end loop;

               close child_details_c;

          end loop;

          close transaction_details_c;
exception
          when others then
          po_message_s.sql_error('GET_TRANSACTION_DETAILS',x_progress,sqlcode);
          raise;
end GET_TRANSACTION_DETAILS;

PROCEDURE GET_INTERNAL_DETAILS ( x_from_org_id       in      number,
                                 x_to_org_id         in      number,
                                 x_item_id           in      number,
                                 x_start_date        in      date,
                                 x_end_date          in      date,
                                 x_delivered_qty     out NOCOPY     number ) IS

          x_progress   VARCHAR2(3) := '000';

          cursor internal_details_c is
                 SELECT rct.transaction_type      trans_type,
                        rct.transaction_id        trans_id,
                        rct.parent_transaction_id parent_trans_id,
                        rct.primary_quantity      trans_qty
                 FROM   rcv_shipment_lines rsl,
                        rcv_transactions rct
                 WHERE  rct.shipment_line_id = rsl.shipment_line_id
                 AND    rsl.item_id = x_item_id
                 AND    rsl.from_organization_id = x_from_org_id
                 AND    rsl.to_organization_id = x_to_org_id
                 AND    rct.transaction_type = 'DELIVER'
                 AND    rct.transaction_date between x_start_date and x_end_date;

          int_rec internal_details_c%rowtype;

          cursor child_details_c is
                 SELECT rct.transaction_type      trans_type,
                        rct.transaction_id        trans_id,
                        rct.parent_transaction_id parent_trans_id,
                        rct.primary_quantity      trans_qty
                 FROM   rcv_transactions rct
                 WHERE  rct.parent_transaction_id = int_rec.trans_id;

          child_rec child_details_c%rowtype;

begin

          x_delivered_qty := 0;

          open internal_details_c;

          x_progress := '001';

          loop
               fetch internal_details_c into int_rec;
               exit when internal_details_c%notfound;

               x_delivered_qty := x_delivered_qty + int_rec.trans_qty;

               open child_details_c;

               x_progress := '002';

               loop
                    fetch child_details_c into child_rec;
                    exit when child_details_c%notfound;

                    if (child_rec.trans_type = 'CORRECT') then
                       x_delivered_qty := x_delivered_qty + child_rec.trans_qty;
                    end if;
               end loop;

               close child_details_c;

          end loop;

          close internal_details_c;

exception
          when others then
          po_message_s.sql_error('GET_INTERNAL_DETAILS',x_progress,sqlcode);
          raise;
end GET_INTERNAL_DETAILS;

PROCEDURE GET_INTRANSIT_DETAILS ( x_from_org_id       in      number,
                                  x_to_org_id         in      number,
                                  x_rec_not_del_qty   out NOCOPY     number ) IS

          x_progress   VARCHAR2(3) := '000';
begin

          SELECT count(*)
          INTO   x_rec_not_del_qty
          FROM   rcv_shipment_lines rsl
                 , mtl_supply ms
          WHERE  rsl.SHIPMENT_LINE_ID     = ms.SHIPMENT_LINE_ID
          AND    rsl.SHIPMENT_HEADER_ID   = ms.SHIPMENT_HEADER_ID
          AND    rsl.FROM_ORGANIZATION_ID = x_from_org_id
          AND    rsl.TO_ORGANIZATION_ID   = x_to_org_id
          AND    ms.FROM_ORGANIZATION_ID  = x_from_org_id
          AND    ms.TO_ORGANIZATION_ID    = x_to_org_id
          AND    ms.SUPPLY_TYPE_CODE in ('RECEIVING', 'SHIPMENT');

exception
          when others then
          po_message_s.sql_error('GET_INTRANSIT_DETAILS',x_progress,sqlcode);
          raise;
end GET_INTRANSIT_DETAILS;


END RCV_GET_DELIVERED_QTY;

/
