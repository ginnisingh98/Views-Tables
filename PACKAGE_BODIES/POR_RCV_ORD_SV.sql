--------------------------------------------------------
--  DDL for Package Body POR_RCV_ORD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_RCV_ORD_SV" as
/* $Header: PORRCVOB.pls 120.5.12010000.7 2014/03/26 09:19:13 shindeng ship $ */

/*************************************************************
 **  Public Function :
 **    groupPoTransaction
 **  Description :
 **    grouping logic to group and split into transaction lines
 **    each transaction line is inserted to rcv transaction interface
 **    return true if grouping is successful
 **************************************************************/

function replaceNull(inValue in number)
return number
is
begin
if (inValue = -9999) then
  return null;
end if;

return inValue;

end;

function groupPoTransaction (X_po_header_id     	IN rcvNumberArray,
                            X_line_location_id 		IN rcvNumberArray,
                            X_receipt_qty      		IN rcvNumberArray,
                            X_receipt_uom      		IN rcvVarcharArray,
                            X_receipt_date     		IN date,
                            X_item_id          		IN rcvNumberArray,
                            X_uom_class        		IN rcvVarcharArray,
                            X_org_id           		IN rcvNumberArray,
                            X_po_distribution_id        IN rcvNumberArray,
                            X_group_id	 		IN number,
			    X_caller			IN varchar2,
                            X_Comments                  IN rcvVarcharArray,
                            X_PackingSlip               IN rcvVarcharArray,
                            X_WayBillNum		IN rcvVarcharArray)
 return number
is


cursor rcv_header(p_lineLocationId number) is
select rsl.shipment_line_id, rsl.quantity_shipped, nvl(rsl.quantity_received,0), rsl.unit_of_measure
from rcv_shipment_lines rsl, rcv_shipment_headers rsh
where rsl.po_line_location_id = p_lineLocationId
      and nvl(rsl.quantity_shipped, 0) > nvl(rsl.quantity_received, 0)
      and rsl.shipment_header_id = rsh.shipment_header_id
      and rsh.asn_type in ('ASN','ASBN');

l_lineLocationId number := 0;
l_qty number := 0;
l_toReceiveQty number := 0; -- remain to receive quantity
l_shippedQty number := 0;
l_receivedQty number := 0;

l_shippedRcvUomQty number := 0;
l_receivedRcvUomQty number := 0;
l_rcvUom  varchar2(40);
l_userReceiptUom  varchar2(40);
l_itemId number :=0;

l_receiptQty number := 0;
l_rcvLineId number := 0;
hasEntryForRcvLine boolean;
l_recorder rcvInfoTable;
l_index number;
x_progress varchar2(240);
x_user_org_id          NUMBER;
x_txn_org_id            NUMBER;

/* dev notes
   1. how to remember which receipts are created?
      do not have to, because we just need to scan for the rcv transaction table for this group id later
   2. quantity and its related uom
      the following quantities are first quaried from db as in a unit of rcv uom, but need to be converted according to user receiving uom X_receipt_uom
      l_shippedQty is converted from l_shippedRcvUomQty
      l_receivedQty is converted from l_receivedRcvUomQty
 */

begin

-- need to construct a recorder within for every associated rcv  line
-- so that we know how many is left for a shipment line
if (x_po_header_id is null) then
  return 1;
end if;

x_user_org_id := MO_GLOBAL.get_current_org_id;

for i in 1..x_po_header_id.count loop
  l_lineLocationId := x_line_location_id(i);
  l_qty := x_receipt_qty(i);
  l_toReceiveQty := l_qty;
  l_userReceiptUom := X_receipt_uom(i);

  x_progress := 'groupPoTransaction 000, lineLocationId=' || to_char(l_lineLocationId) || 'user entered receive; qty='|| to_char(l_toReceiveQty) ||'user entered uom=' || l_userReceiptUom;
  asn_debug.put_line(x_progress);

   /* Set OU to the the order OU */

   begin
     select org_id
       into x_txn_org_id
       from po_line_locations_all poll
      where line_location_id = l_lineLocationId;

    if (x_txn_org_id <> MO_GLOBAL.get_current_org_id) then
      mo_global.set_policy_context(p_access_mode => 'S',
                                   p_org_id      => x_txn_org_id);
    end if;
   exception
     WHEN OTHERS THEN
       po_message_s.sql_error('Error while obtaining the org ID: ', x_progress, sqlcode);
   end;

   x_progress := 'groupPoTransaction 001, x_user_org_id=' || to_char(x_user_org_id) || 'x_txn_org_id='|| to_char(x_txn_org_id);

   asn_debug.put_line(x_progress);

  open rcv_header(l_lineLocationId);
  <<outloop>>
  loop
    fetch rcv_header into
    l_rcvLineId, l_shippedRcvUomQty, l_receivedRcvUomQty, l_rcvUom;
    EXIT WHEN rcv_header%NOTFOUND;

    x_progress := 'groupPoTransaction 002, l_rcvLineId=' || to_char(l_rcvLineId) || 'shippedQty; qty='|| to_char(l_shippedRcvUomQty) || 'receivedQty; qty='|| to_char(l_receivedRcvUomQty) || '; rcvUom=' ||l_rcvUom;
    asn_debug.put_line(x_progress);

    l_itemId := replaceNull(x_item_id(i));
    if (l_userReceiptUom <> l_rcvUom) then
         PO_UOM_S.UOM_CONVERT  (l_shippedRcvUomQty,
				l_rcvUom,
				l_itemId,
		                l_userReceiptUom,
				l_shippedQty);
         PO_UOM_S.UOM_CONVERT  (l_receivedRcvUomQty,
				l_rcvUom,
				l_itemId,
		                l_userReceiptUom,
				l_receivedQty);
         x_progress := 'groupPoTransaction 002.a after uom conversion, shippedQty; qty='|| to_char(l_shippedQty) || 'receivedQty; qty='|| to_char(l_receivedQty);
         asn_debug.put_line(x_progress);

    else
         l_shippedQty := l_shippedRcvUomQty;
         l_receivedQty := l_receivedRcvUomQty;
         x_progress := 'groupPoTransaction 002.b same uom between rcv and po, shippedQty; qty='|| to_char(l_shippedQty) || 'receivedQty; qty='|| to_char(l_receivedQty);
         asn_debug.put_line(x_progress);
    end if;

    hasEntryForRcvLine := false;

    -- a rcv shipment line may have been debitted by another item
    -- with same llid and different distribution, within the same batch

    if (l_recorder.count > 0 ) then
      l_index := l_recorder.FIRST;
      x_progress := 'groupPoTransaction 003 '|| to_char(l_index);
      asn_debug.put_line(x_progress);


      WHILE (l_index IS NOT NULL) LOOP
      asn_debug.put_line('l_recorder(l_index).rcv_line_id' || l_recorder(l_index).rcv_line_id);

      if(l_recorder(l_index).rcv_line_id = l_rcvLineId) then
          --l_recorder(l_index).line_location_id = l_lineLocationId and
        hasEntryForRcvLine := true;
        x_progress := 'groupPoTransaction 012 l_receiptQty:' || l_receiptQty ||
			 ':l_shippedQty:' || l_shippedQty || ':l_receivedQty:'  || l_receivedQty ||
			 'l_recorder(l_index).used_quantity:' || l_recorder(l_index).used_quantity;
        asn_debug.put_line(x_progress);
        if(l_recorder(l_index).available and
           l_shippedQty-l_receivedQty-l_recorder(l_index).used_quantity >= l_toReceiveQty) then
           l_recorder(l_index).used_quantity := l_recorder(l_index).used_quantity + l_toReceiveQty;
           --TODO: test txn when existing receive qty and receive qty 2nt time
           l_receiptQty := l_toReceiveQty;
           l_toReceiveQty := 0;
           insert_rcv_txn_interface(x_source_type_code=>'ASN',
                                           x_rcv_shipment_line_id=>l_rcvLineId,
                                           x_po_header_id=>x_po_header_id(i),
                                           x_line_location_id=>x_line_location_id(i) ,
                      		           x_receipt_qty=>l_receiptQty,
                       		           x_receipt_uom=>x_receipt_uom(i),
                            		   x_receipt_date=>x_receipt_date,
                            		   x_item_id=>replaceNull(x_item_id(i)),
                            		   x_uom_class=>x_uom_class(i),
                            		   x_org_id=>replaceNull(x_org_id(i)),
                            		   x_po_distribution_id=>x_po_distribution_id(i),
                            		   x_group_id=>x_group_id,
			    		   x_caller=>x_caller,
                            		   x_Comments=>x_Comments(i),
                            		   x_PackingSlip=>x_PackingSlip(i),
                            		   x_WayBillNum=>x_WayBillNum(i));
	     x_progress := 'groupPoTransaction 015 after insertion, hasEntryForRcvLine = TRUE, asn matches receiving quantity, exiting';
             asn_debug.put_line(x_progress);
           exit outloop;
        else
           l_recorder(l_index).available := false;
           l_receiptQty := l_shippedQty-l_receivedQty-l_recorder(l_index).used_quantity;
           x_progress := 'groupPoTransaction 016 l_receiptQty:' || l_receiptQty ||
			 ':l_shippedQty:' || l_shippedQty || ':l_receivedQty:'  || l_receivedQty ||
			 'l_recorder(l_index).used_quantity:' || l_recorder(l_index).used_quantity;
           asn_debug.put_line(x_progress);
	   if l_receiptQty > 0 then
             l_toReceiveQty := l_toReceiveQty-l_receiptQty;
             l_recorder(l_index).used_quantity := l_recorder(l_index).used_quantity + l_receiptQty;
             insert_rcv_txn_interface(x_source_type_code=>'ASN',
                                           x_rcv_shipment_line_id=>l_rcvLineId,
                                           x_po_header_id=>x_po_header_id(i),
                                           x_line_location_id=>x_line_location_id(i) ,
                      		           x_receipt_qty=>l_receiptQty,
                       		           x_receipt_uom=>x_receipt_uom(i),
                            		   x_receipt_date=>x_receipt_date,
                            		   x_item_id=>replaceNull(x_item_id(i)),
                            		   x_uom_class=>x_uom_class(i),
                            		   x_org_id=>replaceNull(x_org_id(i)),
                            		   x_po_distribution_id=>x_po_distribution_id(i),
                            		   x_group_id=>x_group_id,
			    		   x_caller=>x_caller,
                            		   x_Comments=>x_Comments(i),
                            		   x_PackingSlip=>x_PackingSlip(i),
                            		   x_WayBillNum=>x_WayBillNum(i));
           --exit;
           end if;
        end if;
      end if;
      l_index := l_recorder.NEXT(l_index);
      end loop;
    end if; -- count>0


    if (not hasEntryForRcvLine) then
      x_progress := 'groupPoTransaction 010 first time receive this rcvLineId, l_shippedQty=' || to_char(l_shippedQty) || '; l_receivedQty='|| to_char(l_receivedQty);
      asn_debug.put_line(x_progress);

      if (l_shippedQty-l_receivedQty>0) then
        -- first time to receive this rcv line within this batch
        if(l_recorder.count=0) then
          l_index := 1;
        else
          l_index := l_recorder.last+1;
        end if;
	l_recorder(l_index).rcv_line_id := l_rcvLineId;
        l_recorder(l_index).used_quantity := 0;
        if(l_shippedQty-l_receivedQty >= l_toReceiveQty) then
          l_recorder(l_index).available := true;
          l_receiptQty := l_toReceiveQty;
          l_recorder(l_index).used_quantity := l_recorder(l_index).used_quantity + l_receiptQty;
          l_toReceiveQty := 0;
          x_progress := 'groupPoTransaction 014 before insertion';

          asn_debug.put_line(x_progress);

           insert_rcv_txn_interface(x_source_type_code=>'ASN',
                                           x_rcv_shipment_line_id=>l_rcvLineId,
                                           x_po_header_id=>x_po_header_id(i),
                                           x_line_location_id=>x_line_location_id(i) ,
                      		           x_receipt_qty=>l_receiptQty,
                       		           x_receipt_uom=>x_receipt_uom(i),
                            		   x_receipt_date=>x_receipt_date,
                            		   x_item_id=>replaceNull(x_item_id(i)),
                            		   x_uom_class=>x_uom_class(i),
                            		   x_org_id=>replaceNull(x_org_id(i)),
                            		   x_po_distribution_id=>x_po_distribution_id(i),
                            		   x_group_id=>x_group_id,
			    		   x_caller=>x_caller,
                            		   x_Comments=>x_Comments(i),
                            		   x_PackingSlip=>x_PackingSlip(i),
                            		   x_WayBillNum=>x_WayBillNum(i));
           x_progress := 'groupPoTransaction 015 after insertion, hasEntryForRcvLine = FALSE, asn matches receiving quantity, exiting';
    asn_debug.put_line(x_progress);

          exit;
        else
          l_recorder(l_index).available := false;
          l_receiptQty := l_shippedQty-l_receivedQty-l_recorder(l_index).used_quantity;
          x_progress := 'groupPoTransaction 017 l_receiptQty:' || l_receiptQty ||
			 ':l_shippedQty:' || l_shippedQty || ':l_receivedQty:'  || l_receivedQty ||
			 'l_recorder(l_index).used_quantity:' || l_recorder(l_index).used_quantity;
           asn_debug.put_line(x_progress);
	  if l_receiptQty > 0 then
            l_recorder(l_index).used_quantity := l_recorder(l_index).used_quantity + l_receiptQty;
            l_toReceiveQty := l_toReceiveQty-l_receiptQty;
            insert_rcv_txn_interface(x_source_type_code=>'ASN',
                                           x_rcv_shipment_line_id=>l_rcvLineId,
                                           x_po_header_id=>x_po_header_id(i),
                                           x_line_location_id=>x_line_location_id(i) ,
                      		           x_receipt_qty=>l_receiptQty,
                       		           x_receipt_uom=>x_receipt_uom(i),
                            		   x_receipt_date=>x_receipt_date,
                            		   x_item_id=>replaceNull(x_item_id(i)),
                            		   x_uom_class=>x_uom_class(i),
                            		   x_org_id=>replaceNull(x_org_id(i)),
                            		   x_po_distribution_id=>x_po_distribution_id(i),
                            		   x_group_id=>x_group_id,
			    		   x_caller=>x_caller,
                            		   x_Comments=>x_Comments(i),
                            		   x_PackingSlip=>x_PackingSlip(i),
                            		   x_WayBillNum=>x_WayBillNum(i));
             x_progress := 'groupPoTransaction 015 after insertion, asn matches less than receiving quantity';
             asn_debug.put_line(x_progress);
	  end if;
          --exit;
        end if;
      end if;
    end if;
  end loop;
  close rcv_header;

  if(l_toReceiveQty > 0) then
     x_progress := 'groupPoTransaction 020 toReceiveQty=' || to_char(l_toReceiveQty);

     asn_debug.put_line(x_progress);

     insert_rcv_txn_interface(x_po_header_id=>x_po_header_id(i),
                                           x_line_location_id=>x_line_location_id(i) ,
                      		           x_receipt_qty=>l_toReceiveQty,
                       		           x_receipt_uom=>x_receipt_uom(i),
                            		   x_receipt_date=>x_receipt_date,
                            		   x_item_id=>replaceNull(x_item_id(i)),
                            		   x_uom_class=>x_uom_class(i),
                            		   x_org_id=>replaceNull(x_org_id(i)),
                            		   x_po_distribution_id=>x_po_distribution_id(i),
                            		   x_group_id=>x_group_id,
			    		   x_caller=>x_caller,
                            		   x_Comments=>x_Comments(i),
                            		   x_PackingSlip=>x_PackingSlip(i),
                            		   x_WayBillNum=>x_WayBillNum(i));
  end if;
end loop;

x_progress := 'groupPoTransaction 030 returning successfully';

asn_debug.put_line(x_progress);
asn_debug.put_line('1 x_txn_org_id:' || x_txn_org_id || 'x_user_org_id:' ||  x_user_org_id);
   if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
      asn_debug.put_line('3 x_txn_org_id:' || x_txn_org_id || 'x_user_org_id:' ||  x_user_org_id);
      mo_global.set_policy_context(p_access_mode => 'S',
                                   p_org_id      => x_user_org_id);
      asn_debug.put_line('5 x_txn_org_id:' || x_txn_org_id || 'x_user_org_id:' ||  x_user_org_id);
   end if;
asn_debug.put_line('7 x_txn_org_id:' || x_txn_org_id || 'x_user_org_id:' ||  x_user_org_id);
return 0;

exception
   when others then
   -- should we just roll back?
     x_progress := 'groupPoTransaction 040 sql exception ' || substr(SQLERRM,12,200);

     asn_debug.put_line(x_progress);

     delete from rcv_transactions_interface
      where group_id = X_group_id;

     PO_REQS_CONTROL_SV.commit_changes;

     if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
       mo_global.set_policy_context(p_access_mode => 'S',
                                    p_org_id      => x_user_org_id);
     end if;

     ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512),'ICX');
     return 1;
end groupPoTransaction;



/*************************************************************
 **  Private Function :
 **    groupInternalTransaction
 **  Description :
 **    grouping logic to group and split into transaction lines
 **    return a new table of records of type internalReceivingRecord
 **    return true if grouping is successful
 **    called by insertTransactionInterface
 **************************************************************/


function groupInternalTransaction (x_req_line_id in rcvNumberArray,
                           x_receipt_qty in rcvNumberArray,
                           x_receipt_uom in rcvVarcharArray,
                           x_item_id in rcvNumberArray,
                           x_uom_class in rcvVarcharArray,
                           x_org_id in rcvNumberArray,
                           x_comments in rcvVarcharArray,
                           x_packingSlip in rcvVarcharArray,
                           x_waybillNum in rcvVarcharArray,
                           x_group_id in number,
                           x_receipt_date in date,
                           x_caller in varchar2)

return number

is

cursor rcv_header(p_reqLineId number) is
select shipment_line_id, quantity_shipped, nvl(quantity_received,0), unit_of_measure
from rcv_shipment_lines
where requisition_line_id = p_reqLineId
      and nvl(quantity_shipped, 0) > nvl(quantity_received, 0);

l_reqLineId number := 0;
l_qty number := 0;
l_toReceiveQty number := 0;
l_shippedQty number := 0;
l_receivedQty number := 0;
l_receiptQty number := 0;
l_rcvLineId number := 0;
x_progress varchar2(240);

l_shippedRcvUomQty number := 0;
l_receivedRcvUomQty number := 0;
l_rcvUom  varchar2(40);
l_userReceiptUom  varchar2(40);
l_itemId number :=0;
x_user_org_id NUMBER;
x_txn_org_id   NUMBER;

begin

if(x_req_line_id is null) then
  return 1;
end if;

x_user_org_id := MO_GLOBAL.get_current_org_id;

for i in 1..x_req_line_id.count loop

  l_reqLineId := x_req_line_id(i);
  l_qty := x_receipt_qty(i);
  l_toReceiveQty := l_qty;
  l_userReceiptUom := X_receipt_uom(i);

  x_progress := 'groupInternalTransaction 000, l_reqLineId=' || to_char(l_reqLineId) || 'user entered receive; qty='|| to_char(l_toReceiveQty) ||'user entered uom=' || l_userReceiptUom;
  asn_debug.put_line(x_progress);
/*
In case of internal requisition no po is created and internal requistion can be received by the same org id user.
 Thus it is not required to set org id context here. It has to be the same.
*/
  x_txn_org_id := x_user_org_id;

  /* if user tries to over receive
     then receive at max available
  */

  open rcv_header(l_reqLineId);
  loop
    fetch rcv_header into
    l_rcvLineId, l_shippedRcvUomQty, l_receivedRcvUomQty, l_rcvUom;
    EXIT WHEN rcv_header%NOTFOUND;

    x_progress := 'groupInternalTransaction 001, l_rcvLineId=' || to_char(l_rcvLineId)|| 'shippedQty; qty='|| to_char(l_shippedRcvUomQty) || 'receivedQty; qty='|| to_char(l_receivedRcvUomQty) || '; rcvUom=' ||l_rcvUom;
    asn_debug.put_line(x_progress);

    l_itemId := replaceNull(x_item_id(i));
    if (l_userReceiptUom <> l_rcvUom) then
         PO_UOM_S.UOM_CONVERT  (l_shippedRcvUomQty,
				l_rcvUom,
				l_itemId,
		                l_userReceiptUom,
				l_shippedQty);
         PO_UOM_S.UOM_CONVERT  (l_receivedRcvUomQty,
				l_rcvUom,
				l_itemId,
		                l_userReceiptUom,
				l_receivedQty);
         x_progress := 'groupInternalTransaction 001.a after uom conversion, shippedQty; qty='|| to_char(l_shippedQty) || 'receivedQty; qty='|| to_char(l_receivedQty);
         asn_debug.put_line(x_progress);

    else
         l_shippedQty := l_shippedRcvUomQty;
         l_receivedQty := l_receivedRcvUomQty;
         x_progress := 'groupInternalTransaction 001.b same uom between rcv and po, shippedQty; qty='|| to_char(l_shippedQty) || 'receivedQty; qty='|| to_char(l_receivedQty);
         asn_debug.put_line(x_progress);
    end if;


    if( (l_shippedQty-l_receivedQty) > l_toReceiveQty) then
      --TODO: test txn when existing receive qty and receive qty 2
      l_receiptQty := l_toReceiveQty;
     x_progress := 'groupInternalTransaction 002 toReceiveQty=' || to_char(l_toReceiveQty);

     asn_debug.put_line(x_progress);

      insert_rcv_txn_interface_ir (l_rcvLineId,
                                           x_req_line_id(i),
                      		           l_receiptQty,
                       		           x_receipt_uom(i),
                            		   x_receipt_date,
                            		   replaceNull(x_item_id(i)),
                            		   x_uom_class(i),
                            		   replaceNull(x_org_id(i)),
                            		   x_group_id,
			    		   x_caller,
                            		   x_Comments(i),
                            		   x_PackingSlip(i),
                            		   x_WayBillNum(i));

      l_toReceiveQty := 0;
       x_progress := 'groupInternalTransaction 025 after insertion, asn matches receiving quantity, exiting';
       asn_debug.put_line(x_progress);
      exit;
    else
      l_receiptQty := l_shippedQty-l_receivedQty;
      l_toReceiveQty := l_toReceiveQty-l_receiptQty;
    x_progress := 'groupInternalTransaction 010 toReceiveQty=' || to_char(l_toReceiveQty);

    asn_debug.put_line(x_progress);

      insert_rcv_txn_interface_ir (l_rcvLineId,
                                           x_req_line_id(i),
                      		           l_receiptQty,
                       		           x_receipt_uom(i),
                            		   x_receipt_date,
                            		   replaceNull(x_item_id(i)),
                            		   x_uom_class(i),
                            		   replaceNull(x_org_id(i)),
                            		   x_group_id,
			    		   x_caller,
                            		   x_Comments(i),
                            		   x_PackingSlip(i),
                            		   x_WayBillNum(i));


    end if;
  end loop;
  close rcv_header;
end loop;

  if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
    mo_global.set_policy_context(p_access_mode => 'S',
                                 p_org_id      => x_user_org_id);
  end if;

return 0;

exception
   when others then
   -- should we just roll back?
     x_progress := 'groupInternalTransaction 040 sql exception ' || substr(SQLERRM,12,200);

     asn_debug.put_line(x_progress);

     delete from rcv_transactions_interface
     where group_id = X_group_id;

     PO_REQS_CONTROL_SV.commit_changes;

     if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
       mo_global.set_policy_context(p_access_mode => 'S',
                                    p_org_id      => x_user_org_id);
     end if;

     ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512),'ICX');
     return 1;

end groupInternalTransaction;



procedure INSERT_RCV_TXN_INTERFACE_IR   (
                                      X_rcv_shipment_line_id     	IN number,
                                      x_req_line_id in number,
                                      X_receipt_qty      	IN number,
                                      X_receipt_uom      	IN varchar2,
                                      X_receipt_date     	IN date,
                                      X_item_id          	IN number,
                                      X_uom_class	      	IN varchar2,
                                      X_org_id           	IN number,
                                      X_group_id         	IN number,
				      X_caller			IN varchar2,
                                      X_Comments                IN varchar2 default null,
                                      X_PackingSlip             IN varchar2 default null,
                                      X_WayBillNum		IN varchar2 default null)
 as

 X_user_id		number :=0;
 x_count NUMBER := -1;
 X_web_user_id          varchar2(30);
 X_logon_id		number := 0;
 X_employee_id		number := 0;
 x_trx_proc_mode 	varchar2(40)  := 'ONLINE';
 X_primary_uom 		varchar2(25) := x_receipt_uom;
 X_primary_qty 		number := x_receipt_qty;
 l_err_message		varchar2(240) := null;
 x_progress  varchar2(240);
 l_shipped_date DATE;

begin
      x_user_id := fnd_global.user_id;

      begin
	     SELECT HR.PERSON_ID
	       INTO   x_employee_id
	       FROM   FND_USER FND, per_people_f HR
	       WHERE  FND.USER_ID = x_user_id
	       AND    FND.EMPLOYEE_ID = HR.PERSON_ID
               AND    sysdate between hr.effective_start_date AND hr.effective_end_date
	       AND    ROWNUM = 1;
      EXCEPTION
        WHEN others THEN
          x_employee_id := 0;
      END;
      IF (x_item_id IS NULL) THEN

		SELECT  unit_of_measure
		INTO    X_primary_uom
		FROM    mtl_units_of_measure
		WHERE   uom_class	= x_uom_class
		AND     base_uom_flag	= 'Y';
      ELSE
		SELECT  primary_unit_of_measure
		INTO    X_primary_uom
		FROM    mtl_system_items
		WHERE   inventory_item_id = x_item_id
		AND     organization_id   = x_org_id;

      END IF;

      if (X_receipt_uom <> X_primary_uom) then
         PO_UOM_S.UOM_CONVERT  (x_receipt_qty,
				x_receipt_uom,
				x_item_id,
		                x_primary_uom,
				X_primary_qty);
      else
         X_primary_qty 		:= X_receipt_qty;
      end if;

      x_progress :=  'insert internal transaction, item_id=' || to_char(x_item_id);
      asn_debug.put_line(x_progress);
      x_progress :=  'insert internal transaction, receipt_uom=' || x_receipt_uom || '; x_receipt_qty='|| to_char(x_receipt_qty);
      asn_debug.put_line(x_progress);
      x_progress := 'insert internal transaction, primary_uom= ' || X_primary_uom ||'; primary_qty=' || to_char(X_primary_qty);
      asn_debug.put_line(x_progress);

      INSERT INTO RCV_TRANSACTIONS_INTERFACE (
                      INTERFACE_TRANSACTION_ID,
                      GROUP_ID,
                      ORG_ID,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATE_LOGIN,
                      SOURCE_DOCUMENT_CODE,
                      DESTINATION_TYPE_CODE,
                      DESTINATION_CONTEXT,
                      RECEIPT_SOURCE_CODE,
                      TRANSACTION_DATE,
                      EXPECTED_RECEIPT_DATE,
                      QUANTITY,
                      UNIT_OF_MEASURE,
                      PRIMARY_QUANTITY,
                      PRIMARY_UNIT_OF_MEASURE,
                      SHIPMENT_HEADER_ID,
                      SHIPMENT_LINE_ID,
                      EMPLOYEE_ID,
                      PO_HEADER_ID,
                      PO_RELEASE_ID,
                      PO_LINE_ID,
                      PO_LINE_LOCATION_ID,
                      PO_DISTRIBUTION_ID,
                      PO_UNIT_PRICE,
                      CURRENCY_CODE,
                      CURRENCY_CONVERSION_RATE,
                      CURRENCY_CONVERSION_TYPE,
                      CURRENCY_CONVERSION_DATE,
                      ROUTING_HEADER_ID,
                      VENDOR_ID,
		      VENDOR_SITE_ID,
                      TRANSACTION_TYPE,
                      ITEM_ID,
                      ITEM_DESCRIPTION,
                      ITEM_REVISION,
                      CATEGORY_ID,
                      VENDOR_ITEM_NUM,
                      PACKING_SLIP,
                      LOCATION_ID,
                      SHIP_TO_LOCATION_ID,
                      DELIVER_TO_PERSON_ID,
                      DELIVER_TO_LOCATION_ID,
                      FROM_ORGANIZATION_ID,
                      TO_ORGANIZATION_ID,
                      SUBINVENTORY,
                      WIP_ENTITY_ID,
                      WIP_LINE_ID,
                      WIP_REPETITIVE_SCHEDULE_ID,
                      WIP_OPERATION_SEQ_NUM,
                      WIP_RESOURCE_SEQ_NUM,
                      BOM_RESOURCE_ID,
                      PROCESSING_STATUS_CODE,
                      PROCESSING_MODE_CODE,
                      TRANSACTION_STATUS_CODE,
                      PARENT_TRANSACTION_ID,
                      INSPECTION_STATUS_CODE,
                      USE_MTL_LOT,
                      USE_MTL_SERIAL,
		      LOCATOR_ID,
		      REQUISITION_LINE_ID,
                      COMMENTS,
                      WAYBILL_AIRBILL_NUM,
                      USSGL_TRANSACTION_CODE	)
           SELECT     RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL,
                      X_group_id,
                      MO_GLOBAL.get_current_org_id,
                      SYSDATE,
                      X_user_id,
                      X_user_id,
                      SYSDATE,
                      X_user_id,
                      'REQ',
                      RSL.DESTINATION_TYPE_CODE,
                      RSL.DESTINATION_TYPE_CODE,
                      'INTERNAL ORDER',
                      X_receipt_date,
                      RSH.EXPECTED_RECEIPT_DATE,
                      X_receipt_qty,
                      X_receipt_uom,
                      X_primary_qty,
                      X_primary_uom,
                      rsh.shipment_header_id,
 		      x_rcv_shipment_line_id,
                      X_employee_id,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      TO_NUMBER(NULL),
                      NULL,
                      TO_NUMBER(NULL),
                      NULL,
                      TO_DATE(NULL),
                      RSL.ROUTING_HEADER_ID,
                      TO_NUMBER(NULL),
		      TO_NUMBER(NULL),
                      decode(x_caller,
                             'WEB','CONFIRM RECEIPT',
                             'WF','CONFIRM RECEIPT(WF)',
                             'WP4','CONFIRM RECEIPT',
                             'WP4_CONFIRM','CONFIRM RECEIPT',
                             'AUTO_RECEIVE','CONFIRM RECEIPT(WF)'),
                      RSL.ITEM_ID,
                      RSL.ITEM_DESCRIPTION,
                      RSL.ITEM_REVISION,
                      RSL.CATEGORY_ID,
                      RSL.VENDOR_ITEM_NUM,
                      X_PackingSlip,
                      RSH.SHIP_TO_LOCATION_ID,
                      RSH.SHIP_TO_LOCATION_ID,
                      rsl.deliver_to_person_id,
                      rsl.DELIVER_TO_LOCATION_ID,
                      RSL.FROM_ORGANIZATION_ID,
	              RSL.TO_ORGANIZATION_ID,
	              RSL.TO_SUBINVENTORY,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      'CONFIRM RECEIPT',
                      X_trx_proc_mode,
                      'CONFIRM',
                      TO_NUMBER(NULL),
                      NULL,
                      MSI.LOT_CONTROL_CODE,
                      MSI.SERIAL_NUMBER_CONTROL_CODE,
		      to_number(NULL),
		      x_req_line_id,
                      X_Comments,
                      X_WayBillNum,
	              NULL
	FROM RCV_SHIPMENT_HEADERS RSH,
             RCV_SHIPMENT_LINES RSL,
             MTL_SYSTEM_ITEMS MSI
        WHERE  RSH.RECEIPT_SOURCE_CODE <> 'VENDOR' AND
           RSH.SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID AND
           MSI.ORGANIZATION_ID (+) = RSL.TO_ORGANIZATION_ID AND
           MSI.INVENTORY_ITEM_ID (+) = RSL.ITEM_ID and
           RSL.SHIPMENT_LINE_ID = x_rcv_shipment_line_id;

 exception
    when others THEN
         x_progress := 'insert internal req transaction exception' || substr(SQLERRM,12,512);

         asn_debug.put_line(x_progress);



	  if (x_caller = 'WP4' OR x_caller = 'WP4_CONFIRM') then
	     l_err_message   := substr(SQLERRM,12,512);
	     ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512),'ICX');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	  end if;

end INSERT_RCV_TXN_INTERFACE_IR;



procedure INSERT_RCV_TXN_INTERFACE   (X_source_type_code        IN varchar2 default 'VENDOR',
                                      X_rcv_shipment_line_id    IN number default 0,
                                      X_po_header_id     	IN number,
                                      X_line_location_id 	IN number,
                                      X_receipt_qty      	IN number,
                                      X_receipt_uom      	IN varchar2,
                                      X_receipt_date     	IN date,
                                      X_item_id          	IN number,
                                      X_uom_class        	IN varchar2,
                                      X_org_id           	IN number,
                                      X_po_distribution_id      IN number,
                                      X_group_id         	IN number,
				      X_caller			IN varchar2,
                                      X_Comments                IN varchar2 default null,
                                      X_PackingSlip             IN varchar2 default null,
                                      X_WayBillNum		IN varchar2 default null
) as

 X_user_id		number := 0;
 x_count NUMBER := -1;
 X_web_user_id          varchar2(30);
 X_logon_id		number := 0;
 X_employee_id		number := 0;
 x_trx_proc_mode 	varchar2(40)  := 'ONLINE';
 X_primary_uom 		varchar2(25);
 X_primary_qty 		number;
 X_receipt_amt          number;
 X_qty                  number;
 l_err_message		varchar2(240) := null;

 l_destination_type_code VARCHAR2(25) := NULL;
 l_order_type_code VARCHAR(2) := NULL;
 l_expected_receipt_date DATE;
 l_shipped_date DATE;
 l_rcv_shipment_header_id NUMBER := 0;

 l_po_header_id NUMBER := 0;
 l_po_release_id NUMBER := 0;
 l_po_line_id NUMBER := 0;
 l_po_line_location_id NUMBER := 0;
 l_po_distribution_id NUMBER := 0;
 l_unit_price NUMBER := 0;
 l_currency_code VARCHAR2(15) := NULL;
 l_currency_conversion_rate NUMBER := NULL;
 l_currency_conversion_type VARCHAR2(30) := NULL;
 l_currency_conversion_date DATE;
 l_routing_id NUMBER := 0;
 l_vendor_id NUMBER := 0;
 l_vendor_site_id NUMBER := 0;
 l_item_id NUMBER := 0;
 l_item_description VARCHAR2(240) := NULL;
 l_item_revision VARCHAR2(3) := NULL;
 l_item_category_id NUMBER := 0;
 l_vendor_item_number VARCHAR2(25) := NULL;
 l_ship_to_location_id NUMBER := 0;
 l_deliver_to_person_id NUMBER := 0;
 l_deliver_to_location_id NUMBER := 0;
 l_from_organization_id NUMBER := 0;
 l_to_organization_id NUMBER := 0;
 l_destination_subinventory VARCHAR2(10) := NULL;
 l_lot_control_code NUMBER := 0;
 l_serial_number_control_code NUMBER := 0;
 --l_req_line_id NUMBER := 0;
 l_wip_entity_id NUMBER:= 0;
 l_wip_line_id NUMBER:= 0;
 l_wip_repetitive_schedule_id NUMBER:= 0;
 l_wip_operation_seq_num NUMBER:= 0;
 l_wip_resource_seq_num NUMBER:= 0;
 l_bom_resource_id NUMBER:= 0;
 l_req_distribution_id NUMBER:= NULL;
 X_MATCHING_BASIS    PO_LINES_ALL.MATCHING_BASIS%TYPE;
 X_JOB_ID   PO_LINES_ALL.JOB_ID%TYPE;
--Bug 8893932  PO RECEIVED FROM IPROCUREMENT DOESNT POPULATE COUNTRY OF ORIGIN
 l_country_of_origin  PO_LINE_LOCATIONS_ALL.COUNTRY_OF_ORIGIN_CODE%TYPE;

--Bug 18396661: populate project and task into RTI
 x_project_id  NUMBER;
 x_task_id NUMBER;

-- l_receipt_num  varchar2(100);
-- l_asn_exist varchar2(8); -- probably to be renamed as sourceTypeFlag
-- l_receipt_source_code varchar2(100) := 'VENDOR';
-- x_shipment_line_id number :=0; -- to delete

 begin
        x_user_id := fnd_global.user_id;

      asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE x_source_type_code:' || x_source_type_code);

      if (x_source_type_code = 'ASN') then
        select shipment_header_id
        into l_rcv_shipment_header_id
        from rcv_shipment_lines
        where shipment_line_id = X_rcv_shipment_line_id;
      end if;

      asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE l_rcv_shipment_header_id:' || l_rcv_shipment_header_id);

      begin
	     SELECT HR.PERSON_ID
	       INTO   x_employee_id
	       FROM   FND_USER FND, per_people_f HR
	       WHERE  FND.USER_ID = x_user_id
	       AND    FND.EMPLOYEE_ID = HR.PERSON_ID
               AND    sysdate between hr.effective_start_date AND hr.effective_end_date
	       AND    ROWNUM = 1;
      EXCEPTION
        WHEN others THEN
          x_employee_id := 0;
      END;

      asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE x_employee_id :' || x_employee_id );

     SELECT  POL.MATCHING_BASIS, POL.JOB_ID
       INTO  X_MATCHING_BASIS, X_JOB_ID
       FROM  PO_LINES_ALL POL, PO_DISTRIBUTIONS_ALL POD
      WHERE  POL.PO_LINE_ID = POD.PO_LINE_ID
        AND  POD.PO_DISTRIBUTION_ID = X_PO_DISTRIBUTION_ID;

     asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE X_MATCHING_BASIS' || X_MATCHING_BASIS);

     If nvl(x_matching_basis, 'QUANTITY') = 'QUANTITY' then

       IF (x_item_id IS NULL) THEN
		SELECT  unit_of_measure
		INTO    X_primary_uom
		FROM    mtl_units_of_measure
		WHERE   uom_class	= x_uom_class
		AND     base_uom_flag	= 'Y';
       ELSE
		SELECT  primary_unit_of_measure
		INTO    X_primary_uom
		FROM    mtl_system_items
		WHERE   inventory_item_id = x_item_id
		AND     organization_id   = x_org_id;
       END IF;

       if (X_receipt_uom <> X_primary_uom) then
         PO_UOM_S.UOM_CONVERT  (x_receipt_qty,
				x_receipt_uom,
				x_item_id,
		                x_primary_uom,
				X_primary_qty);
       else
         X_primary_qty:= X_receipt_qty;
       end if;
       X_qty:= X_receipt_qty;
     else
       X_receipt_amt := X_receipt_qty;
       X_qty := null;
     end if;

     asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE  X_receipt_qty' || X_receipt_qty || ' X_receipt_amt ' || X_receipt_amt);

      /*   Insert the rows that were checked into RCV_TRANSACTIONS_INTERFACE   */

     SELECT POD.DESTINATION_TYPE_CODE,
        'PO',
        NVL(POLL.PROMISED_DATE, POLL.NEED_BY_DATE),
	POLL.PO_HEADER_ID,
	POLL.PO_RELEASE_ID,
	POLL.PO_LINE_ID,
	POLL.LINE_LOCATION_ID,
	POD.PO_DISTRIBUTION_ID ,
	NVL(POLL.PRICE_OVERRIDE,POL.UNIT_PRICE),
	POH.CURRENCY_CODE ,
	POH.RATE,
	POH.RATE_TYPE,
	POH.RATE_DATE,
	POLL.RECEIVING_ROUTING_ID,
	POH.VENDOR_ID,
	POH.VENDOR_SITE_ID,
	POL.ITEM_ID,
	SUBSTR( POL.ITEM_DESCRIPTION,1,240),
	POL.ITEM_REVISION,
	POL.CATEGORY_ID,
	POL.VENDOR_PRODUCT_NUM,
	POLL.SHIP_TO_LOCATION_ID,
	POD.DELIVER_TO_PERSON_ID ,
	POD.DELIVER_TO_LOCATION_ID ,
	POH.PO_HEADER_ID,
	POLL.SHIP_TO_ORGANIZATION_ID,
	POD.DESTINATION_SUBINVENTORY ,
	MSI.LOT_CONTROL_CODE,
	MSI.SERIAL_NUMBER_CONTROL_CODE,
        pod.wip_entity_id,
        pod.wip_line_id,
        pod.wip_repetitive_schedule_id,
        pod.wip_operation_seq_num,
        pod.wip_resource_seq_num,
        pod.bom_resource_id,
	--Bug 8893932  PO RECEIVED FROM IPROCUREMENT DOESNT POPULATE COUNTRY OF ORIGIN
	POLL.COUNTRY_OF_ORIGIN_CODE
   INTO
        l_destination_type_code,
	l_order_type_code,
	l_expected_receipt_date,
	l_po_header_id,
	l_po_release_id,
	l_po_line_id,
	l_po_line_location_id,
	l_po_distribution_id,
	l_unit_price,
	l_currency_code,
	l_currency_conversion_rate,
	l_currency_conversion_type,
	l_currency_conversion_date,
	l_routing_id,
	l_vendor_id,
	l_vendor_site_id,
	l_item_id,
	l_item_description,
	l_item_revision,
	l_item_category_id,
	l_vendor_item_number,
	l_ship_to_location_id,
	l_deliver_to_person_id,
	l_deliver_to_location_id,
	l_from_organization_id,
	l_to_organization_id,
	l_destination_subinventory,
	l_lot_control_code,
	l_serial_number_control_code,
        l_wip_entity_id,
        l_wip_line_id,
        l_wip_repetitive_schedule_id,
        l_wip_operation_seq_num,
        l_wip_resource_seq_num,
        l_bom_resource_id,
	--Bug 8893932  PO RECEIVED FROM IPROCUREMENT DOESNT POPULATE COUNTRY OF ORIGIN
	l_country_of_origin

     FROM	MTL_SYSTEM_ITEMS	MSI,
      		PO_LINES_ALL		POL,
      		PO_DISTRIBUTIONS_ALL	POD,
      		PO_HEADERS_ALL		POH,
      		PO_LINE_LOCATIONS_ALL	POLL
     WHERE
	NVL(POLL.APPROVED_FLAG,'N') = 'Y' AND
	NVL(POLL.CANCEL_FLAG, 'N') = 'N' AND
	NVL(POLL.CLOSED_CODE,'OPEN') NOT IN  ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING', 'CANCELLED') AND
	POLL.SHIPMENT_TYPE IN  ('STANDARD','BLANKET','SCHEDULED') AND
	POLL.RECEIVING_ROUTING_ID = 3 AND
	POH.PO_HEADER_ID = POLL.PO_HEADER_ID AND
	POL.PO_LINE_ID = POLL.PO_LINE_ID AND
	POD.PO_HEADER_ID = POLL.PO_HEADER_ID AND
	POD.PO_LINE_ID = POL.PO_LINE_ID AND
	POD.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID AND
	NVL(MSI.ORGANIZATION_ID,POLL.SHIP_TO_ORGANIZATION_ID) = POLL.SHIP_TO_ORGANIZATION_ID AND
	MSI.INVENTORY_ITEM_ID (+) = POL.ITEM_ID AND
	POH.PO_HEADER_ID =  x_po_header_id and
        POLL.LINE_LOCATION_ID =  x_line_location_id and
	POD.PO_DISTRIBUTION_ID =  X_po_distribution_id;


   --Bug 18396661  Used for deriving project to insert in the rti
   asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE: Getting the project details');
   asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE: X_po_distribution_id: ' || X_po_distribution_id);

   IF (x_po_distribution_id IS NOT NULL ) THEN

             SELECT project_id, task_id
             INTO   x_project_id, x_task_id
             FROM   po_distributions_all
             WHERE  po_distribution_id = x_po_distribution_id;
   END IF;

   asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE Project id: ' || x_project_id);
   asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE Task id: ' || x_task_id);
   --End bug 18396661

   asn_debug.put_line('POR_RCV_ORD_SV.INSERT_RCV_TXN_INTERFACE Inserting values in RCV_TRANSACTIONS_INTERFACE');

  INSERT INTO RCV_TRANSACTIONS_INTERFACE (
                      INTERFACE_TRANSACTION_ID,
                      GROUP_ID,
                      ORG_ID,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATE_LOGIN,
                      SOURCE_DOCUMENT_CODE,
                      DESTINATION_TYPE_CODE,
                      DESTINATION_CONTEXT,
                      RECEIPT_SOURCE_CODE,
                      TRANSACTION_DATE,
                      EXPECTED_RECEIPT_DATE,
                      QUANTITY,
                      UNIT_OF_MEASURE,
                      PRIMARY_QUANTITY,
                      PRIMARY_UNIT_OF_MEASURE,
		      AMOUNT,
                      SHIPMENT_HEADER_ID,
                      SHIPMENT_LINE_ID,
                      EMPLOYEE_ID,
                      PO_HEADER_ID,
                      PO_RELEASE_ID,
                      PO_LINE_ID,
                      PO_LINE_LOCATION_ID,
                      PO_DISTRIBUTION_ID,
                      PO_UNIT_PRICE,
                      CURRENCY_CODE,
                      CURRENCY_CONVERSION_RATE,
                      CURRENCY_CONVERSION_TYPE,
                      CURRENCY_CONVERSION_DATE,
                      ROUTING_HEADER_ID,
                      VENDOR_ID,
		      VENDOR_SITE_ID,
                      TRANSACTION_TYPE,
                      ITEM_ID,
                      ITEM_DESCRIPTION,
                      ITEM_REVISION,
                      CATEGORY_ID,
                      VENDOR_ITEM_NUM,
                      PACKING_SLIP,
                      LOCATION_ID,
                      SHIP_TO_LOCATION_ID,
                      DELIVER_TO_PERSON_ID,
                      DELIVER_TO_LOCATION_ID,
                      FROM_ORGANIZATION_ID,
                      TO_ORGANIZATION_ID,
                      SUBINVENTORY,
                      WIP_ENTITY_ID,
                      WIP_LINE_ID,
                      WIP_REPETITIVE_SCHEDULE_ID,
                      WIP_OPERATION_SEQ_NUM,
                      WIP_RESOURCE_SEQ_NUM,
                      BOM_RESOURCE_ID,
                      PROCESSING_STATUS_CODE,
                      PROCESSING_MODE_CODE,
                      TRANSACTION_STATUS_CODE,
                      PARENT_TRANSACTION_ID,
                      INSPECTION_STATUS_CODE,
                      USE_MTL_LOT,
                      USE_MTL_SERIAL,
		      LOCATOR_ID,
		      -- REQUISITION_LINE_ID,
                      COMMENTS,
                      WAYBILL_AIRBILL_NUM,
                      USSGL_TRANSACTION_CODE,
                      JOB_ID,
                      MATCHING_BASIS,
		      COUNTRY_OF_ORIGIN_CODE,
                      --Bug 18396661
                      PROJECT_ID,
                      TASK_ID)

           SELECT     RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL,
                      X_group_id,
                      MO_GLOBAL.get_current_org_id,
                      SYSDATE,
                      X_user_id,
                      X_user_id,
                      SYSDATE,
                      X_user_id,
                      l_order_type_code,  -- always PO for both standard and asn
                      l_DESTINATION_TYPE_CODE,
                      l_DESTINATION_TYPE_CODE,
                      'VENDOR', -- same for ASN and PO
                      X_receipt_date,
                      l_expected_receipt_date,
                      X_qty,
                      X_receipt_uom,
                      X_primary_qty,
                      X_primary_uom,
                      X_receipt_amt,
                      DECODE(x_source_type_code,'VENDOR', NULL, l_rcv_shipment_header_id),
                      DECODE(x_source_type_code,'VENDOR', NULL, x_rcv_shipment_line_id),
                      X_employee_id,
                      DECODE(l_order_type_code,'PO', l_po_header_id, NULL),
                      DECODE(l_order_type_code,'PO', l_po_release_id, NULL),
                      DECODE(l_order_type_code,'PO', l_po_line_id, NULL),
                      DECODE(l_order_type_code,'PO', l_po_line_location_id, NULL),
                      DECODE(l_order_type_code,'PO', l_po_distribution_id, NULL),
                      l_unit_price,
                      l_currency_code,
                      l_currency_conversion_rate,
                      l_currency_conversion_type,
                      l_currency_conversion_date,
                      l_routing_id,
                      l_vendor_id,
		      l_vendor_site_id,
                      decode(x_caller,
                             'WEB','CONFIRM RECEIPT',
                             'WF','CONFIRM RECEIPT(WF)',
                             'WP4','CONFIRM RECEIPT',
                             'WP4_CONFIRM','CONFIRM RECEIPT',
                             'AUTO_RECEIVE','CONFIRM RECEIPT(WF)'),  -- 'EXPRESS DIRECT' this is the transaction_type
                      l_item_id,
                      l_item_description,
                      l_item_revision,
                      l_item_category_id,
                      l_vendor_item_number,
                      X_PackingSlip,
                      l_ship_to_location_id,
                      l_ship_to_location_id,
                      DECODE(l_order_type_code,'PO',l_deliver_to_person_id, l_deliver_to_person_id),
                      DECODE(l_order_type_code,'PO', l_DELIVER_TO_LOCATION_ID, L_DELIVER_TO_LOCATION_ID),
                      DECODE(l_order_type_code,'PO', NULL, l_from_organization_id),
	              l_to_organization_id,
	              DECODE(l_order_type_code,'PO', l_DESTINATION_SUBINVENTORY, L_DESTINATION_SUBINVENTORY),
                      DECODE(l_order_type_code,'PO',l_WIP_ENTITY_ID, NULL),
                      DECODE(l_order_type_code,'PO',l_WIP_LINE_ID, NULL),
                      DECODE(l_order_type_code,'PO',l_WIP_REPETITIVE_SCHEDULE_ID, NULL),
                      DECODE(l_order_type_code,'PO',l_WIP_OPERATION_SEQ_NUM, NULL),
                      DECODE(l_order_type_code,'PO',l_WIP_RESOURCE_SEQ_NUM, NULL),
                      DECODE(l_order_type_code,'PO',l_BOM_RESOURCE_ID, NULL),
                      'CONFIRM RECEIPT',   -- 'EXPRESS'        this is the processing_status_code
                      X_trx_proc_mode,
                      'CONFIRM',           -- 'EXPRESS'        this is the transaction_status_code
                      TO_NUMBER(NULL),
                      NULL,
                      l_lot_control_code,
                      l_serial_number_control_code,
		      to_number(NULL),
		      -- to_number(NULL), -- Bug#2718763 We no longer populate the requisition line id
                      X_Comments,
                      X_WayBillNum,
	                  NULL,
                      X_JOB_ID,
                      nvl(x_matching_basis, 'QUANTITY'),
		      l_country_of_origin,
                      --Bug 18396661
                      x_project_id,
                      x_task_id
	FROM dual;


 exception
    when others THEN
	  if (x_caller = 'WP4' OR x_caller = 'WP4_CONFIRM') then
	     l_err_message   := substr(SQLERRM,12,512);
	     asn_debug.put_line(l_err_message);
	     ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512),'ICX');
	     APP_EXCEPTION.RAISE_EXCEPTION;
	  end if;


 end INSERT_RCV_TXN_INTERFACE;


/*************************************************************
 **  Function :
 **    processTransactions
 **  Description :
 **    validates the transactions
 **    create or update rcv shipment header
 **    call the txn processor
 **    API called from Java layer program
 **************************************************************/

function process_transactions		(X_group_id	IN number,
					 X_caller	IN varchar2,
                                         X_Comments      IN varchar2 default null,
                                         X_PackingSlip   IN varchar2 default null,
                                         X_WayBillNum	 IN varchar2 default null)
     return number is

 X_return_code			boolean		:= FALSE;
 X_return_code_number		number		:= 0;
 X_rows_succeeded		number		:= 0;
 X_rows_failed			number		:= 0;
 X_logonid			number		:= 0;
 l_err_message			varchar2(240)	:= null;
 x_column_name			po_interface_errors.column_name%type;
 x_output_message		varchar2(80)	:= null;
 x_message                      VARCHAR2(2000) := '';
 x_user_org_id  NUMBER;
 x_txn_org_id    NUMBER;
 begin

   x_user_org_id := MO_GLOBAL.get_current_org_id;

   begin
     select org_id
       into x_txn_org_id
       from rcv_transactions_interface rti
      where rti.group_id = x_group_id and rownum = 1;

    asn_debug.put_line('process_transactions x_txn_org_id:' || x_txn_org_id);

    if (x_txn_org_id <> MO_GLOBAL.get_current_org_id) then
      mo_global.set_policy_context(p_access_mode => 'S',
                                   p_org_id      => x_txn_org_id);
    end if;
   exception
     WHEN OTHERS THEN
       asn_debug.put_line('Error while obtaining the org ID');
   end;

    /**   Validate the Input fields    **/
        asn_debug.put_line('process_transactions Calling the val_express_transactions');
	rcv_express_sv.val_express_transactions(X_group_id,
				                X_rows_succeeded,
				                X_rows_failed);
	asn_debug.put_line('process_transactions 001 s=' || to_char(X_rows_succeeded));
        asn_debug.put_line('process_transactions 002 f=' ||  to_char(X_rows_failed));

        commit;

	if (X_rows_succeeded > 0) then


		X_return_code := create_rcv_shipment_headers(X_group_Id, X_caller,X_Comments, X_PackingSlip ,X_WayBillNum);


		if (X_return_code) then
		 	 /** Bug# 7030461 -- As part of bug 3560995, commit was commented out. It gives
		          	 *   issues in Receiving Transaction Processor. We are inserting records into
		 	  *  RTI and RSH and updating the RTI.shipment_header_id with RSH.Shipment_header_id
			  * and calling the transaction processor. Since the transaction processor runs in different
		 	  * transaction, commit is necessary here.
		 	  *  Reverting the changes done as part of bug 3560995.
		 	  **/
	       		commit;
                        asn_debug.put_line('process_transactions 003 calling processor');

 	        	X_return_code_number := call_txn_processor(X_group_id, X_caller);


		else

			X_return_code_number := 99;
		end if;


	else
		X_return_code_number	:= 98;
	end if;

        if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
          mo_global.set_policy_context(p_access_mode => 'S',
                                       p_org_id      => x_user_org_id);
        end if;

        return X_return_code_number;

 exception
    when others THEN -- there's a problem with val_express_transactions
                if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
                  mo_global.set_policy_context(p_access_mode => 'S',
                                               p_org_id      => x_user_org_id);
                end if;
		if  (x_caller = 'WP4' OR x_caller ='WP4_CONFIRM') then
                    x_message := fnd_message.get;
                    if (x_message = '') THEN
		      ERROR_STACK.PUSHMESSAGE(x_message,'ICX');
                      asn_debug.put_line(x_message);
		    ELSE
		      ERROR_STACK.PUSHMESSAGE(substr(SQLERRM,12,512),'ICX');
		      asn_debug.put_line(substr(SQLERRM,12,512));
		    END IF;
		end if;
	   return 97;
 end process_transactions;

/**************************************************************
 **  Private Function :
 **    processRcvShipment
 **  Description :
 **    update rcv shipment header for ASN and Internal Shipment
 **    creates a header for those txns that have the same vendor and to_org_id
 **    return true if function successful
 **************************************************************

function processRcvShipment (x_group_id in number,
                               x_caller in varchar2,
                               x_Comments in varchar2 default null,
                               x_PackingSlip in varchar2 default null,
                               x_WayBillNum in varchar2 default null,
                               x_Ussgl_Transaction_Code in varchar2 default null)
 return boolean;


*/


 /****************************************************
 **  Function    : Create_Rcv_Shipment_Header
 **  Description : This procedure creates a header
 **                for those txns that have the same vendor
 **                and to_org_id.
 *****************************************************/

 function create_rcv_shipment_headers   (X_group_id      IN NUMBER,
					 X_caller        IN varchar2,
					 X_Comments      IN varchar2 default null,
                                         X_PackingSlip   IN varchar2 default null,
                                         X_WayBillNum	 IN varchar2 default null)

 return boolean is

 cursor c0 is
         SELECT RTI.TO_ORGANIZATION_ID,
               RTI.VENDOR_ID, RTI.WAYBILL_AIRBILL_NUM, POD.ORG_ID
        FROM   RCV_TRANSACTIONS_INTERFACE RTI, PO_DISTRIBUTIONS_ALL POD
        WHERE  GROUP_ID = X_GROUP_ID AND
	       SHIPMENT_LINE_ID IS NULL  AND
	       RTI.PO_DISTRIBUTION_ID = POD.PO_DISTRIBUTION_ID
	GROUP BY RTI.TO_ORGANIZATION_ID, RTI.VENDOR_ID, RTI.WAYBILL_AIRBILL_NUM, POD.ORG_ID;

/*
 cursor c0 is
        select distinct to_organization_id,
                        vendor_id,waybill_airbill_num
        from   rcv_transactions_interface
        where  group_id = X_group_id and shipment_line_id is null;
 --       for    update of shipment_header_id;
*/

 cursor c1 is
        select to_organization_id, shipment_header_id, comments, packing_slip,waybill_airbill_num
        from   rcv_transactions_interface
        where  group_id = X_group_id and shipment_line_id is not null and
               shipment_header_id is not null;

 cursor c2 is
     select distinct shipment_header_id
     from  rcv_transactions_interface trans
     where group_id = X_group_id and shipment_line_id is not null and
           shipment_header_id is not null;


 X_sysdate		date	:= SYSDATE;
 X_userid		number	:= 0;
 X_vendor_id		rcv_transactions_interface.vendor_id%type;
 X_org_id               PO_DISTRIBUTIONS_ALL.ORG_ID%type;
 X_to_org_id		rcv_transactions_interface.to_organization_id%type;
 X_receipt_num		rcv_shipment_headers.receipt_num%type;
 X_created_by		rcv_shipment_headers.created_by%type;
 X_last_update_login	rcv_shipment_headers.last_update_login%type;
 X_count		number := 0;
 X_shipment_header_id	rcv_shipment_headers.shipment_header_id%type;
 X_employee_id		rcv_shipment_headers.employee_id%type		 := 0;
 X_request_id		rcv_shipment_headers.request_id%type		 := 0;

 X_pgm_app_id		rcv_shipment_headers.program_application_id%type := 0;
 X_pgm_id		rcv_shipment_headers.program_id%type		 := 0;
 l_err_message		varchar2(240) := null;
 x_rcpt_count           NUMBER := 1;
 x_organization_name    VARCHAR2(60);
 x_supplier_name        PO_VENDORS.VENDOR_NAME%TYPE;
 x_line_waybill_airbill_num VARCHAR2(20);
 x_wayairnum VARCHAR2(20);
 x_req_number VARCHAR2(25);
 x_new_comments VARCHAR2(240);
 x_new_packingSlip VARCHAR2(25);
 x_new_waybillNum VARCHAR2(20);
 x_asn_type VARCHAR2(25);
 X_vendor_site_id     rcv_transactions_interface.vendor_site_id%type;

 begin

        X_created_by        := fnd_global.user_id;
	x_last_update_login := fnd_global.user_id;

	BEGIN
	     SELECT HR.PERSON_ID
	       INTO   x_employee_id
	       FROM   FND_USER FND, per_people_f HR
	       WHERE  FND.USER_ID = X_created_by
	       AND    FND.EMPLOYEE_ID = HR.PERSON_ID
               AND    sysdate between hr.effective_start_date AND hr.effective_end_date
	       AND    ROWNUM = 1;
	EXCEPTION
	   WHEN others THEN
	   x_employee_id := 0;
	END;


      open c0;

      loop
         fetch c0 into X_to_org_id, x_vendor_id,x_line_waybill_airbill_num, X_org_id;
         exit when c0%notfound;

         /*  Get the Receipt Number  */


         SELECT to_char(next_receipt_num + 1)
         INTO X_receipt_num
         FROM rcv_parameters
         WHERE organization_id = X_to_org_id
         FOR UPDATE OF next_receipt_num;

	 LOOP

           SELECT count(*)
	   INTO   X_count
	   FROM   rcv_shipment_headers
	   WHERE  receipt_num = X_receipt_num and
                  ship_to_org_id = X_to_org_id;

           IF (X_count = 0) THEN
              update rcv_parameters
              set next_receipt_num = X_receipt_num
              where organization_id = X_to_org_id;

              EXIT;
           ELSE
              X_receipt_num := to_char(to_number(X_receipt_num) + 1);
           END IF;

         END LOOP;

         /* Get the shipment Header id */

         SELECT rcv_shipment_headers_s.nextval
         INTO   X_shipment_header_id
         FROM   sys.dual;


         /*   For every unique Org_id, Vendor_id combination,
         **   create a header    */

         INSERT INTO RCV_SHIPMENT_HEADERS (
                       SHIPMENT_HEADER_ID,
                       LAST_UPDATE_DATE,
                       LAST_UPDATED_BY,
                       CREATION_DATE,
                       CREATED_BY,
                       LAST_UPDATE_LOGIN,
                       RECEIPT_SOURCE_CODE,
                       VENDOR_ID,
                       ORGANIZATION_ID,
      	               SHIP_TO_ORG_ID,
                       RECEIPT_NUM,
                       EMPLOYEE_ID,
                       REQUEST_ID,
                       PROGRAM_APPLICATION_ID,
                       PROGRAM_ID,
                       PROGRAM_UPDATE_DATE,
                       COMMENTS,
                       PACKING_SLIP,
                       WAYBILL_AIRBILL_NUM,
                       USSGL_TRANSACTION_CODE )
         VALUES (
		     X_shipment_header_id,
                     SYSDATE,
                     X_created_by,
                     SYSDATE,
                     X_created_by,
                     X_last_update_login,
                     'VENDOR',
                     X_vendor_id,
                     X_to_org_id,
                     X_to_org_id,
                     X_receipt_num,
                     X_employee_id,
                     X_request_id,
                     X_pgm_app_id,
                     X_pgm_id,
                     SYSDATE,
                     X_Comments ,
                     X_PackingSlip,
                     x_line_waybill_airbill_num,
                     NULL);

         IF x_line_waybill_airbill_num IS NULL THEN
	      update rcv_transactions_interface
		set    shipment_header_id = x_shipment_header_id
		where  group_id = X_group_id
		and  to_organization_id = x_to_org_id
		and  vendor_id = x_vendor_id
                and  shipment_line_id is null
		AND waybill_airbill_num IS NULL;
	        x_req_number := NULL;
	    ELSE
	      update rcv_transactions_interface
		set    shipment_header_id = x_shipment_header_id
		where  group_id = X_group_id
		and  to_organization_id = x_to_org_id
		and  vendor_id = x_vendor_id
                and  shipment_line_id is null
		AND waybill_airbill_num = x_line_waybill_airbill_num;
		x_req_number := NULL;
	END IF;

	 BEGIN
	   SELECT distinct vendor_site_id
	   INTO X_vendor_site_id
	   FROM rcv_transactions_interface
	   WHERE group_id = X_group_id and
                 shipment_header_id = x_shipment_header_id;

           asn_debug.put_line('vendor_site='||to_char(X_vendor_site_id));
	 EXCEPTION
	   WHEN others THEN
	   X_vendor_site_id := null;
	 END;

         if(X_vendor_site_id is not null) then
           update rcv_shipment_headers
           set vendor_site_id =  X_vendor_site_id
           where shipment_header_id = x_shipment_header_id;
         end if;

         x_rcpt_count := x_rcpt_count +1;
     end loop;

     close c0;

     /* update intransit shipment header according to user entered info */

     asn_debug.put_line('number of PO receipt created is ' || to_char(x_rcpt_count-1));

      open c1;

      loop
         fetch c1 into X_to_org_id, X_shipment_header_id, X_new_comments, X_new_packingSlip, X_new_waybillNum;
         exit when c1%notfound;

         begin
           select receipt_num
           into X_receipt_num
           from rcv_shipment_headers
           where shipment_header_id = X_shipment_header_id and
               receipt_num is not null;
         exception
         when no_data_found then
                  /*  Get the Receipt Number  */
           SELECT to_char(next_receipt_num + 1)
           INTO X_receipt_num
           FROM rcv_parameters
           WHERE organization_id = X_to_org_id
           FOR UPDATE OF next_receipt_num;

	   LOOP

           SELECT count(*)
	   INTO   X_count
	   FROM   rcv_shipment_headers
	   WHERE  receipt_num = X_receipt_num and
                  ship_to_org_id = X_to_org_id;

           IF (X_count = 0) THEN
              update rcv_parameters
              set next_receipt_num = X_receipt_num
              where organization_id = X_to_org_id;

              EXIT;
           ELSE
              X_receipt_num := to_char(to_number(X_receipt_num) + 1);
           END IF;

           END LOOP;

           update rcv_shipment_headers
           set receipt_num=X_receipt_num
           where shipment_header_id = X_shipment_header_id;

         end; -- no receipt number

     end loop;

     close c1;

     return TRUE;

 exception
     when others then

	if (x_caller = 'WP4' OR x_caller ='WP4_CONFIRM') THEN
                  ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512),'ICX');
                  APP_EXCEPTION.RAISE_EXCEPTION;
	end if;
     return FALSE;

 end create_rcv_shipment_headers;


 /*************************************************************
 **  Function :     Call_Txn_Processor
 **  Description :  This function calls the transaction processor
 **                 in ONLINE mode.
 **************************************************************/

 function  call_txn_processor(X_group_id IN Number,
			      X_caller   IN varchar2)
   return number is

 x_trx_proc_mode	varchar2(40);
 rc			number;
 rc1                    number;
 delete_rows		boolean		:= FALSE;

 timeout		number		:= 300;
 outcome		varchar2(200)	:= NULL;
 message		varchar2(200)	:= NULL;
 l_err_message		varchar2(240)	:= null;

 X_user_id  number;
 X_resp_id  number;
 x_appl_id NUMBER;

 X_str     varchar2(2000) := NULL;
 X_output_message varchar2(2000) := NULL;
 x_progress VARCHAR2(1000) := '';
 r_val1 varchar2(200) := NULL;
  r_val2 varchar2(200) := NULL;
  r_val3 varchar2(200) := NULL;
  r_val4 varchar2(200) := NULL;
  r_val5 varchar2(200) := NULL;
  r_val6 varchar2(200) := NULL;
  r_val7 varchar2(200) := NULL;
  r_val8 varchar2(200) := NULL;
  r_val9 varchar2(200) := NULL;
  r_val10 varchar2(200) := NULL;
  r_val11 varchar2(200) := NULL;
  r_val12 varchar2(200) := NULL;
  r_val13 varchar2(200) := NULL;
  r_val14 varchar2(200) := NULL;
  r_val15 varchar2(200) := NULL;
  r_val16 varchar2(200) := NULL;
  r_val17 varchar2(200) := NULL;
  r_val18 varchar2(200) := NULL;
  r_val19 varchar2(200) := NULL;
  r_val20 varchar2(200) := NULL;
  x_user_org_id NUMBER;
  x_txn_org_id   NUMBER;
 begin

       x_progress := '001 calling txn_processor for group=' || to_char(X_group_id);
       asn_debug.put_line(x_progress);

	    x_user_id := fnd_global.user_id;
	    x_resp_id := fnd_global.resp_id;
	     x_appl_id := fnd_global.resp_appl_id;

       fnd_global.APPS_INITIALIZE (X_user_id, X_resp_id, x_appl_id);

   -- Code for setting the org context same as the org id from PO
   asn_debug.put_line('call_txn_processor x_group_id:' || x_group_id);

   x_user_org_id := MO_GLOBAL.get_current_org_id;

   begin
     select org_id
       into x_txn_org_id
       from rcv_transactions_interface rti
      where rti.group_id = x_group_id and rownum = 1;

    if (x_txn_org_id <> MO_GLOBAL.get_current_org_id) then
      mo_global.set_policy_context(p_access_mode => 'S',
                                   p_org_id      => x_txn_org_id);
    end if;
   exception
     WHEN OTHERS THEN
       asn_debug.put_line('Error while obtaining the org ID');
   end;

	  x_trx_proc_mode := 'ONLINE';

          if (X_trx_proc_mode = 'ONLINE') THEN
	     x_progress := '002';
             asn_debug.put_line(x_progress);

	     rc := fnd_transaction.synchronous (
                        timeout, outcome, message, 'PO', 'RCVTPO',
                        X_trx_proc_mode,  X_group_id,
                        x_txn_org_id, NULL, NULL, NULL, NULL, NULL,
                        NULL, NULL, NULL, NULL, NULL, NULL,
                        NULL, NULL, NULL, NULL, NULL, NULL);

	     x_progress := '003online call return=' || to_char(rc) || '; outcome='|| outcome;
             asn_debug.put_line(x_progress);

              if rc = 1 then
                if (por_rcv_ord_SV.check_group_id(X_group_id)) then
                   fnd_message.set_name('FND', 'TM-TIMEOUT');
                   x_str := fnd_message.get;
                   fnd_message.clear;

                   FND_MESSAGE.set_name('FND','CONC-Error running standalone');
                   fnd_message.set_token('PROGRAM', 'Receiving Transaction Manager - RCVOLTM');
                   fnd_message.set_token('REQUEST', X_group_id);
                   fnd_message.set_token('REASON', x_str);

                   htp.nl;
		   x_output_message := fnd_message.get;

                   if (X_caller <> 'WP4'OR x_caller <> 'WP4_CONFIRM') then
	             htp.teletype(x_output_message);
		     htp.nl;
		    ELSE
                      asn_debug.put_line('return 1, msg=' || x_output_message);
                      ERROR_STACK.PUSHMESSAGE( x_output_message, 'ICX');
                   end if;
                end if;
                 delete_rows := TRUE;
              elsif rc = 2 then
                 IF (por_rcv_ord_SV.check_group_id(X_group_id)) THEN


                    fnd_message.set_name('FND', 'TM-SVC LOCK HANDLE FAILED');
                    x_str := fnd_message.get;

                    FND_MESSAGE.set_name('FND','CONC-Error running standalone');

                    fnd_message.set_token('PROGRAM', 'Receiving Transaction Manager - RCVOLTM');
                    fnd_message.set_token('REQUEST', X_group_id);
                    fnd_message.set_token('REASON', x_str);


		   x_output_message := fnd_message.get;
		   ERROR_STACK.PUSHMESSAGE( x_output_message, 'ICX');
                   asn_debug.put_line('return 2, msg=' || x_output_message);
                end if;
                 delete_rows := TRUE;
            elsif (rc = 3 or (outcome IN ('WARNING', 'ERROR'))) then
               asn_debug.put_line('return 3 from txn processor, or outcome='|| outcome);
               IF (por_rcv_ord_SV.check_group_id(X_group_id)) THEN


                 rc1 := fnd_transaction.get_values (r_val1, r_val2, r_val3, r_val4, r_val5,
						    r_val6, r_val7, r_val8, r_val9, r_val10,
						    r_val11, r_val12, r_val13, r_val14, r_val15,
						    r_val16, r_val17, r_val18, r_val19, r_val20
						    );
                 x_output_message := r_val1;

                 IF (r_val2 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val2;  END IF;
                 IF (r_val3 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val3;  END IF;
                 IF (r_val4 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val4;  END IF;
                 IF (r_val5 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val5;  END IF;
                 IF (r_val6 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val6;  END IF;
                 IF (r_val7 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val7;  END IF;
                 IF (r_val8 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val8;  END IF;
                 IF (r_val9 IS NOT NULL)  THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val9;  END IF;
                 IF (r_val10 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val10; END IF;
                 IF (r_val11 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val11; END IF;
                 IF (r_val12 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val12; END IF;
                 IF (r_val13 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val13; END IF;
                 IF (r_val14 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val14; END IF;
                 IF (r_val15 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val15; END IF;
                 IF (r_val16 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val16; END IF;
                 IF (r_val17 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val17; END IF;
                 IF (r_val18 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val18; END IF;
                 IF (r_val19 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val19; END IF;
                 IF (r_val20 IS NOT NULL) THEN x_output_message := x_output_message || fnd_global.local_chr(10) || r_val20; END IF;

		 ERROR_STACK.PUSHMESSAGE( x_output_message, 'ICX');
                 asn_debug.put_line('return 3 or error, msg=' ||  x_output_message);
                 /* for this error case, we change the rc
                    so that the error case will properly passed to middle tier.
                    set to 4 to distinguish from 3
                  */
                 if (rc1 = 0 and outcome IN ('WARNING', 'ERROR')) then
                   rc := 4;
                 elsif rc=3 then
                   fnd_message.clear;
                   fnd_message.set_name('ICX','ICX_POR_RCV_TXN_MGR_DOWN_ERROR');
                   x_output_message := fnd_message.get;
                   ERROR_STACK.PUSHMESSAGE(x_output_message,'ICX');
                 end if;

	      END IF;

              asn_debug.put_line('After calling transaction processor, rc='|| to_char(rc));
               delete_rows := TRUE;

          elsif (rc = 0 and (outcome NOT IN ('WARNING', 'ERROR'))) then

                if (x_caller = 'WP4') then
                /** Since we have received over the web, we need to clean up any open
                    notifications for the rows that belong to this group_id **/

                   por_rcv_ord_SV.cancel_pending_notifs(x_group_id);

                end if;
                 x_progress := '004, return 0 from txn processor';
                 asn_debug.put_line(x_progress);
                delete_rows := FALSE;
                commit;
          end if;


          elsif (X_trx_proc_mode = 'IMMEDIATE') then


                rc := fnd_request.submit_request('PO',
		    'RVCTP',
		    null,
		    null,
		    false,
		    'IMMEDIATE',
		    X_group_id,
		    chr(0),
		    NULL, NULL, NULL, NULL, NULL, NULL,
		    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL, NULL);

                if (rc <= 0 or rc is NULL) then
		 --    htp.p('The rc is: ' || to_char(rc));  htp.nl;
                      delete_rows := TRUE;
		     null;    			-- for now
		else
		     commit;
		     rc := null;
                end if;

          end if;

        /*
        **   Since the insert has already occurred, make sure to set the
        **   transaction status to error;  otherwise the next query
        **   you do will make it look like the transactions were
        **   actually awaiting the transaction processor since the
        **   status will be 'PENDING'
        **   DEBUG:  We should log a message in the rcv interface errors
        **   so if the user reviews these records, they'll know why
        **   they were not processed.
        */

         if (delete_rows) then

             BEGIN

             	delete from rcv_transactions_interface
             	where group_id = X_group_id;


             	PO_REQS_CONTROL_SV.commit_changes;

             EXCEPTION
                  WHEN OTHERS THEN
		     if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
                       mo_global.set_policy_context(p_access_mode => 'S',
                                                    p_org_id      => x_user_org_id);
    		     end if;
       		     ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512), 'ICX');
		     return 95;
             END;

         END if;
	 if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
           mo_global.set_policy_context(p_access_mode => 'S',
                                        p_org_id      => x_user_org_id);
         end if;

	return rc;

 EXCEPTION
	when others then
	   if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
             mo_global.set_policy_context(p_access_mode => 'S',
                                          p_org_id      => x_user_org_id);
           end if;
           x_progress := 'call txn processor exception' || substr(SQLERRM,12,512);
           asn_debug.put_line(x_progress);
	   ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512), 'ICX');
	   return 94;

 end call_txn_processor;

 /*=============================================================

  FUNCTION NAME:     check_group_id

=============================================================*/
FUNCTION check_group_id (x_group_id IN NUMBER) RETURN BOOLEAN IS

x_rec_count NUMBER := 0;

BEGIN

    SELECT COUNT(1)
    INTO   x_rec_count
    FROM   RCV_TRANSACTIONS_INTERFACE
    WHERE  group_id = x_group_id;

    IF (x_rec_count = 0) THEN

        return (FALSE);

    ELSE

        return (TRUE);

    END IF;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN RETURN(FALSE);
       WHEN OTHERS THEN raise;

END check_group_id;

procedure cancel_pending_notifs (x_group_id IN NUMBER) is

    cursor C1 is
    select distinct nvl(pod.wf_item_key,wf.ITEM_KEY)
    from rcv_transactions  rcv,po_line_locations_all poll,
                       po_distributions_all pod,wf_items wf
                  where group_id = x_group_id and
			poll.line_location_id = rcv.po_line_location_id AND
                        pod.po_distribution_id = rcv.po_distribution_id
			   AND wf.item_type = 'PORCPT'  AND
                      (  wf.ITEM_KEY LIKE  (rcv.po_header_id ||';'||
                                            rcv.deliver_to_person_id || ';' ||'%')
                         );

     wf_item_key   varchar2(2000);
     wf_item_type  varchar2(6) := 'PORCPT';

begin

     open c1;
     loop
         fetch c1 into wf_item_key ;
         exit when c1%notfound;


         if (por_rcv_ord_SV.notif_is_active(wf_item_type,wf_item_key)) then
        	     WF_Engine.AbortProcess(wf_item_type,wf_item_key);
         end if;

     end loop;

end cancel_pending_notifs;

FUNCTION  notif_is_active (wf_item_type in varchar2,
                           wf_item_key  in varchar2) RETURN BOOLEAN is

x_act_status varchar2(8);
x_progress   varchar2(100) := '001';
/** this procedure is currently only called when the transaction is done
   via the menu on the web. Hence it is safe now to default it to WP4 **/
x_caller varchar2(3) := 'WP4';


BEGIN
     x_progress := 'POR_RCV_ORD_SV.is_active-001';

--Bug 4999072 Changed the query to reduce the memory usage
SELECT  WIAS.ACTIVITY_STATUS
INTO    x_act_status
FROM    WF_ITEM_ACTIVITY_STATUSES WIAS,
        WF_ITEMS WI,
        WF_PROCESS_ACTIVITIES PA
WHERE   WIAS.ITEM_TYPE  = wf_item_type
AND     WIAS.ITEM_KEY   = wf_item_key
AND     WIAS.ITEM_TYPE  = WI.ITEM_TYPE
AND     WIAS.ITEM_KEY   = WI.ITEM_KEY
AND     WI.ROOT_ACTIVITY=PA.ACTIVITY_NAME
AND     WIAS.PROCESS_ACTIVITY= PA.INSTANCE_ID;



		if x_act_status not in ('COMPLETE', 'ERROR') then
                   return TRUE;
                else return FALSE;
                end if;
exception
  when no_data_found then
     return false;
  when others then
      if (x_caller = 'WP4'OR x_caller ='WP4_CONFIRM') then
          error_stack.pushmessage( substr(SQLERRM,12,512),'ICX');
          app_exception.raise_exception;
      else
          return FALSE;
      end if;
end notif_is_active;

end;

/
