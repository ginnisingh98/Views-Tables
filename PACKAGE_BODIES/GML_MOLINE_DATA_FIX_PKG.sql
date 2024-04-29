--------------------------------------------------------
--  DDL for Package Body GML_MOLINE_DATA_FIX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_MOLINE_DATA_FIX_PKG" AS
/* $Header: GMLDFIXB.pls 120.0 2005/05/25 16:51:01 appldev noship $ */

PROCEDURE MO_LINE_FIX IS

l_count                 NUMBER;
fname                   VARCHAR2(4000);

--BEGIN BUG#2736088 V. Ajay Kumar
--Removed the reference to "apps".
Cursor get_mo_line IS
  SELECT mo.line_id      mo_line_id,
         h.order_number  ,
         d.line_id       order_line_id,
         mo.quantity_detailed,
         mo.quantity_delivered,
         NVL( (-1) * sum(itp.trans_qty), 0) trans_qty,
         NVL( (-1) * sum(itp.trans_qty2), 0) trans_qty2
  FROM ic_txn_request_lines mo,
       oe_order_headers_all h,
       oe_order_lines_all d,
       ic_tran_pnd itp
  WHERE itp.line_id(+) = mo.txn_source_line_id
    AND mo.txn_source_line_id = d.line_id
    AND d.header_id = h.header_id
    AND itp.doc_type(+) = 'OMSO'
    AND itp.staged_ind(+) = 1
    AND itp.delete_mark(+) = 0
    AND NVL(mo.quantity_delivered, 0) > NVL(mo.quantity_detailed, 0)
    AND mo.line_status IN (3, 7)
  GROUP BY mo.line_id, h.order_number, d.line_id, mo.quantity_detailed, mo.quantity_delivered
  ORDER by h.order_number;

Cursor get_mo_line_for_status IS
  SELECT mol.line_id      mo_line_id,
         soh.order_number ,
         sol.line_id       order_line_id,
         moh.request_number
  FROM ic_txn_request_lines mol,
       ic_txn_request_headers moh,
       oe_order_headers_all soh,
       oe_order_lines_all sol
  WHERE moh.header_id = mol.header_id
    AND soh.header_id = sol.header_id
    AND sol.line_id = mol.txn_source_line_id
    AND NVL(mol.quantity_delivered, 0) = NVL(mol.quantity_detailed, 0)
    AND NVL(mol.quantity_detailed, 0) = NVL(mol.quantity, 0)
    AND mol.line_status IN (3, 7)
  ORDER by moh.request_number;
--END BUG#2736088

BEGIN
--BEGIN BUG#2736088 V. Ajay Kumar
--Removed the reference to "apps".
   OE_DEBUG_PUB.SETDEBUGLEVEL(5);
   OE_DEBUG_PUB.DEBUG_ON;
   fname := OE_DEBUG_PUB.SET_DEBUG_MODE('FILE');
--   DBMS_OUTPUT.PUT_LINE('debug file : '||fname);
--END BUG#2736088

   --DBMS_OUTPut.disable;
   --DBMS_OUTPut.enable(1000000);

   l_count := 1;
   FOR mo_line IN get_mo_line LOOP

     --DBMS_OUTPUT.put_line(' ++ ' || l_count || ' ++++++++++++++++++++++++++++++++++++++++++ ');
     --DBMS_OUTPUT.put_line(' order number is  ' || mo_line.order_number );
     --DBMS_OUTPUT.put_line(' Move order line_id is  '  || mo_line.mo_line_id);
     --DBMS_OUTPUT.put_line(' order line_id is  ' || mo_line.order_line_id );

     --DBMS_OUTPUT.put_line(' updating mo line quantity_delivered as  ' || mo_line.trans_qty );

     --BEGIN BUG#2736088 V. Ajay Kumar
     --Removed the reference to "apps".
     UPDATE ic_txn_request_lines
     SET quantity_delivered = mo_line.trans_qty,
         secondary_quantity_delivered = mo_line.trans_qty2,
         quantity_detailed = mo_line.trans_qty,
         secondary_quantity_detailed = mo_line.trans_qty2
     WHERE line_id = mo_line.mo_line_id;
     --END BUG#2736088

     l_count := l_count + 1;
   END LOOP;
   --DBMS_OUTPUT.put_line(' ++++++++++++++++++++++++++++++++++++++++++++ ');
   --DBMS_OUTPUT.put_line(' total lines updated is  ' || (l_count -1) );

   l_count := 1;
   FOR mo_line_stat IN get_mo_line_for_status LOOP

     --DBMS_OUTPUT.put_line(' ++ ' || l_count || ' ++++++++++++++++++++++++++++++++++++++++++ ');
     --DBMS_OUTPUT.put_line(' request number =  ' || mo_line_stat.request_number );
     --DBMS_OUTPUT.put_line(' order number =  ' || mo_line_stat.order_number );
     --DBMS_OUTPUT.put_line(' Move order line_id =  '  || mo_line_stat.mo_line_id);
     --DBMS_OUTPUT.put_line(' order line_id is  ' || mo_line_stat.order_line_id );

     --DBMS_OUTPUT.put_line(' This Move Order has to be updated to status=CLOSED');

     --BEGIN BUG#2736088 V. Ajay Kumar
     --Removed the reference to "apps".
     UPDATE ic_txn_request_lines
     SET line_status = 5
     WHERE line_id = mo_line_stat.mo_line_id;
     --END BUG#2736088

     l_count := l_count + 1;
  END LOOP;

  --DBMS_OUTPUT.put_line(' ++++++++++++++++++++++++++++++++++++++++++++ ');
  --DBMS_OUTPUT.put_line(' total lines updated is  ' || (l_count -1) );
END MO_LINE_FIX;

END GML_MOLINE_DATA_FIX_PKG;

/
