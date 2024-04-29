--------------------------------------------------------
--  DDL for Package Body RCV_RMA_RCPT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_RMA_RCPT_PURGE" AS
/* $Header: RCVPURGB.pls 120.3 2006/05/22 04:39:15 atiwari noship $*/
/*============================== RCV_RMA_RCPT_PURGE =========================*/

PROCEDURE Check_Open_Receipts(x_order_line_id  IN  NUMBER,
                              x_status   OUT NOCOPY  VARCHAR2,
                              x_message  OUT NOCOPY  VARCHAR2) IS

x_progress       varchar2(3) := '000';
x_interface_ct   number;

BEGIN
  x_progress := '010';

--Bugfix5216533: Rewritten the query for performance issues.
  select count(*) into x_interface_ct
  from rcv_transactions_interface
  where oe_order_line_id = x_order_line_id
  and processing_status_code in ('PENDING','ERROR');

  x_progress := '020';

  if x_interface_ct > 0  then
   x_status  := 'FALSE';
   x_message := fnd_message.get_string('PO','RCV_RMA_RCPT_IN_INTERFACE');
  end if;

  x_progress := '030';
  x_status := 'TRUE';

EXCEPTION

  when others then
    po_message_s.sql_error('Check_Open_Receipts', x_progress, sqlcode);
    x_message := fnd_message.get;
    x_status := 'FALSE';

END Check_Open_Receipts;

/*============================================================================*/

PROCEDURE Purge_Receipts (x_order_line_id  IN  NUMBER,
                          x_status   OUT NOCOPY  VARCHAR2,
                          x_message  OUT NOCOPY  VARCHAR2) IS

x_progress        varchar2(3) := '000';
x_ship_line_id    number;
x_ship_header_id  number;
x_line_count      number;

CURSOR c1(x_order_line_id  number) IS
select shipment_line_id,shipment_header_id
from rcv_shipment_lines
where oe_order_line_id = x_order_line_id;

BEGIN
  x_progress := '010';

 SAVEPOINT purge_receipts_savepoint;

 OPEN c1(x_order_line_id);

 LOOP
  FETCH c1 into x_ship_line_id,
                x_ship_header_id ;
  EXIT WHEN c1%NOTFOUND;

  /* get a list of transaction_id for this x_ship_line_id */

   x_progress := '010';
  /* delete from rcv_lots_supply */
 delete from rcv_lots_supply
 where shipment_line_id = x_ship_line_id;

   x_progress := '020';
 /* delete from rcv_serials_supply */
 delete from rcv_serials_supply
 where shipment_line_id = x_ship_line_id;

   x_progress := '030';
 /* delete from rcv_lot_transactions */
 delete from rcv_lot_transactions
 where shipment_line_id = x_ship_line_id;

   x_progress := '040';
 /* delete from rcv_lots_supply */
 delete from rcv_serial_transactions
 where shipment_line_id = x_ship_line_id;

   x_progress := '050';
 /* delete from rcv_shipment_lines */
 delete from rcv_shipment_lines
 where shipment_line_id = x_ship_line_id;

  /* if the shipment header for this line does not have any more  lines
   * then delete the header .
   */
  select count(*) into x_line_count
  from rcv_shipment_lines
  where shipment_header_id = x_ship_header_id;

  if x_line_count = 0 then
    delete from rcv_shipment_headers
    where shipment_header_id = x_ship_header_id;
  end if;

   x_progress := '060';

 /* delete from rcv_transactions */
 delete from rcv_transactions
 where shipment_line_id = x_ship_line_id;

 END LOOP;
 CLOSE c1;

         x_progress := '070';
         x_status := 'TRUE';

EXCEPTION

  when others then
    po_message_s.sql_error('Purge_Receipts', x_progress, sqlcode);
    x_message := fnd_message.get;
    x_status := 'FALSE';
    ROLLBACK TO SAVEPOINT purge_receipts_savepoint;
    raise;

END Purge_Receipts;

END RCV_RMA_RCPT_PURGE;

/
