--------------------------------------------------------
--  DDL for Package Body RMA_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RMA_UPDATE" AS
/* $Header: INVRMAUB.pls 120.2 2005/10/05 06:19:07 amohamme noship $ */
Procedure update_rma_receipts(header_id_value number, trx_rma_id number, success OUT NOCOPY /* file.sql.39 change */ boolean) IS
	sql_done	boolean:= TRUE;


BEGIN

DELETE FROM mtl_material_transactions_temp
WHERE transaction_header_id = header_id_value AND process_flag = 'N' ;


INSERT INTO mtl_so_rma_receipts(
RMA_RECEIPT_ID,RMA_INTERFACE_ID,ORGANIZATION_ID,INVENTORY_ITEM_ID,RECEIVED_QUANTITY,ACCEPTED_QUANTITY,UNIT_CODE,
RECEIPT_DATE,RETURN_SUBINVENTORY_NAME,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY)
SELECT
mt.transaction_temp_id,mt.trx_source_delivery_id,mt.organization_id,
mt.inventory_item_id,
decode(sign(mt.department_id + msri.delivered_quantity -
        	msri.received_quantity),-1,
        	0, 1, mt.department_id +
        	msri.delivered_quantity - msri.received_quantity, 0),
mt.department_id,msri.unit_code,mt.transaction_date,mt.subinventory_code,
mt.last_update_date,mt.last_updated_by,mt.creation_date,mt.created_by
FROM mtl_so_rma_interface msri, mtl_material_transactions_temp mt
WHERE mt.transaction_header_id  = header_id_value
AND mt.trx_source_delivery_id = msri.rma_interface_id ;


UPDATE mtl_so_rma_interface msri
        SET msri.received_quantity =  (SELECT
	     decode(sign(sum(mt.department_id) + msri.delivered_quantity -
             msri.received_quantity),-1,
             msri.received_quantity, 1, sum(mt.department_id) +
             msri.delivered_quantity,
             msri.received_quantity)
             FROM mtl_material_transactions_temp mt
             WHERE mt.transaction_header_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),
        msri.delivered_quantity = (SELECT sum(mt.department_id) +
        msri.delivered_quantity
             FROM mtl_material_transactions_temp mt
             WHERE mt.transaction_header_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),

	msri.last_update_date = (SELECT mt.last_update_date FROM
        mtl_material_transactions_temp mt
				WHERE mt.transaction_header_id  = header_id_value AND rownum = 1),
	msri.last_updated_by =  (SELECT mt.last_updated_by from mtl_material_transactions_temp mt
				WHERE mt.transaction_header_id  = header_id_value AND rownum = 1)
	WHERE msri.rma_interface_id IN (SELECT mmtt.trx_source_delivery_id FROM
				mtl_material_transactions_temp mmtt
				WHERE mmtt.transaction_header_id = header_id_value) ;

success := TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND then
    success := FALSE;
  WHEN OTHERS then
    success := FALSE;
end update_rma_receipts;

Procedure update_rma_receipts_rpc(header_id_value number, trx_rma_id number, success OUT NOCOPY /* file.sql.39 change */ boolean) IS
	sql_done	boolean := TRUE;

BEGIN

DELETE FROM mtl_material_transactions_temp
WHERE transaction_header_id = header_id_value AND process_flag = 'N' ;

INSERT INTO mtl_so_rma_receipts(
RMA_RECEIPT_ID,RMA_INTERFACE_ID,ORGANIZATION_ID,INVENTORY_ITEM_ID,RECEIVED_QUANTITY,ACCEPTED_QUANTITY,UNIT_CODE,
RECEIPT_DATE,RETURN_SUBINVENTORY_NAME,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY)
SELECT
mt.transaction_id,mt.trx_source_delivery_id,mt.organization_id,mt.inventory_item_id,
decode(sign(mt.department_id + msri.delivered_quantity -
        	msri.received_quantity),-1,
        	0, 1, mt.department_id +
        	msri.delivered_quantity - msri.received_quantity, 0),
mt.department_id,msri.unit_code,mt.transaction_date,mt.subinventory_code,mt.last_update_date,mt.last_updated_by,
mt.creation_date,mt.created_by
FROM mtl_so_rma_interface msri, mtl_material_transactions mt
WHERE mt.transaction_set_id  = header_id_value
AND mt.trx_source_delivery_id = msri.rma_interface_id ;

UPDATE mtl_so_rma_interface msri
        SET msri.received_quantity =  (SELECT
	     decode(sign(sum(mt.department_id) + msri.delivered_quantity -
             msri.received_quantity),-1,
             msri.received_quantity, 1, sum(mt.department_id) +
             msri.delivered_quantity,
             msri.received_quantity)
             FROM mtl_material_transactions mt
             WHERE mt.transaction_set_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),
        msri.delivered_quantity = (SELECT sum(mt.department_id) + msri.delivered_quantity
             FROM mtl_material_transactions mt
             WHERE mt.transaction_set_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),
	msri.last_update_date = (SELECT mt.last_update_date FROM mtl_material_transactions mt
				WHERE mt.transaction_set_id  = header_id_value AND rownum = 1),
	msri.last_updated_by =  (SELECT mt.last_updated_by from mtl_material_transactions mt
				WHERE mt.transaction_set_id  = header_id_value AND rownum = 1)
	WHERE msri.rma_interface_id IN (SELECT mmt.trx_source_delivery_id FROM
				mtl_material_transactions mmt
				WHERE mmt.transaction_set_id = header_id_value) ;

UPDATE mtl_material_transactions
	SET department_id = NULL
	WHERE transaction_set_id = header_id_value ;

COMMIT;
success := TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND then
    success := FALSE;
  WHEN OTHERS then
    success := FALSE;


end update_rma_receipts_rpc;


Procedure update_rma_returns(header_id_value number, trx_rma_id number, success OUT NOCOPY /* file.sql.39 change */ boolean) IS
	sql_done	boolean := TRUE ;
BEGIN

DELETE FROM mtl_material_transactions_temp
WHERE transaction_header_id = header_id_value AND process_flag = 'N' ;


INSERT INTO mtl_so_rma_receipts(
RMA_RECEIPT_ID,RMA_INTERFACE_ID,ORGANIZATION_ID,INVENTORY_ITEM_ID,RECEIVED_QUANTITY,ACCEPTED_QUANTITY,UNIT_CODE,
RECEIPT_DATE,RETURN_SUBINVENTORY_NAME,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY)
SELECT
mt.transaction_temp_id,mt.trx_source_delivery_id,mt.organization_id,mt.inventory_item_id, mt.department_id * -1,
mt.department_id * -1, msri.unit_code,mt.transaction_date,mt.subinventory_code,mt.last_update_date,
mt.last_updated_by,mt.creation_date,mt.created_by
FROM mtl_so_rma_interface msri, mtl_material_transactions_temp mt
WHERE mt.transaction_header_id  = header_id_value
AND mt.trx_source_delivery_id = msri.rma_interface_id ;


UPDATE mtl_so_rma_interface msri
        SET msri.received_quantity = (SELECT msri.received_quantity - sum(mt.department_id)
             FROM  mtl_material_transactions_temp mt
             WHERE mt.transaction_header_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),
        msri.delivered_quantity = (select msri.delivered_quantity - sum(mt.department_id)
             FROM mtl_material_transactions_temp mt
             WHERE mt.transaction_header_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),
	msri.last_update_date = (SELECT mt.last_update_date FROM mtl_material_transactions_temp mt
				WHERE mt.transaction_header_id  = header_id_value AND rownum = 1),
	msri.last_updated_by =  (SELECT mt.last_updated_by from mtl_material_transactions_temp mt
				WHERE mt.transaction_header_id  = header_id_value AND rownum = 1)
	WHERE msri.rma_interface_id IN (SELECT mmtt.trx_source_delivery_id
	FROM mtl_material_transactions_temp mmtt
	WHERE mmtt.transaction_header_id = header_id_value) ;

success := TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND then
    success := FALSE;
  WHEN OTHERS then
    success := FALSE;

end update_rma_returns;

Procedure update_rma_returns_rpc(header_id_value number, trx_rma_id number, success OUT NOCOPY /* file.sql.39 change */ boolean) IS
	sql_done	boolean := TRUE ;
BEGIN

DELETE FROM mtl_material_transactions_temp
WHERE transaction_header_id = header_id_value AND process_flag = 'N' ;


INSERT INTO mtl_so_rma_receipts(
RMA_RECEIPT_ID,RMA_INTERFACE_ID,ORGANIZATION_ID,INVENTORY_ITEM_ID,RECEIVED_QUANTITY,ACCEPTED_QUANTITY,UNIT_CODE,
RECEIPT_DATE,RETURN_SUBINVENTORY_NAME,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY)
SELECT
mt.transaction_id,mt.trx_source_delivery_id,mt.organization_id,mt.inventory_item_id, mt.department_id * -1,
mt.department_id * -1, msri.unit_code,mt.transaction_date,mt.subinventory_code,mt.last_update_date,
mt.last_updated_by,mt.creation_date,mt.created_by
FROM mtl_so_rma_interface msri, mtl_material_transactions mt
WHERE mt.transaction_set_id  = header_id_value
AND mt.trx_source_delivery_id = msri.rma_interface_id ;

UPDATE mtl_so_rma_interface msri
        SET msri.received_quantity =   (SELECT msri.received_quantity - sum(mt.department_id)
             FROM  mtl_material_transactions mt
             WHERE mt.transaction_set_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),
        msri.delivered_quantity = (select  msri.delivered_quantity - sum(mt.department_id)
             FROM mtl_material_transactions mt
             WHERE mt.transaction_set_id  = header_id_value
	     AND mt.trx_source_delivery_id = msri.rma_interface_id ),
	msri.last_update_date = (SELECT mt.last_update_date FROM mtl_material_transactions mt
				WHERE mt.transaction_set_id  = header_id_value AND rownum = 1),
	msri.last_updated_by =  (SELECT mt.last_updated_by from mtl_material_transactions mt
				WHERE mt.transaction_set_id  = header_id_value AND rownum = 1)
	WHERE msri.rma_interface_id IN (SELECT mmt.trx_source_delivery_id
	FROM mtl_material_transactions mmt
	WHERE mmt.transaction_set_id = header_id_value) ;


UPDATE mtl_material_transactions
	SET department_id = NULL
	WHERE transaction_set_id = header_id_value ;

COMMIT;
success := TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND then
    success := FALSE;
  WHEN OTHERS then
    success := FALSE;


end update_rma_returns_rpc;

Procedure gen_sales_order_id(r_number varchar2, r_type varchar2,
r_source_code varchar2, r_id OUT NOCOPY /* file.sql.39 change */ number) IS
	success	boolean := TRUE ;
	xchar_formatted_date  varchar2(200);
	segs  FND_FLEX_EXT.SegmentArray;
BEGIN

/*
package is fnd_flex_ext
FUNCTION get_combination_id(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           n_segments           IN  NUMBER,
                           segments             IN  SegmentArray,
                           combination_id       OUT NOCOPY NUMBER)  RETURN BOOLEAN;
*/
segs(1) := r_number ;
segs(2) := r_type ;
segs(3) := r_source_code ;
xchar_formatted_date := to_char(Sysdate, 'YYYY/MM/DD');
success := fnd_flex_ext.get_combination_id('INV', 'MKTS', 101,
		TO_DATE(xchar_formatted_date,'YYYY/MM/DD'), 3, segs, r_id) ;
if not success then
  r_id := -9999 ;
end if;

end gen_sales_order_id ;


END rma_update;

/
