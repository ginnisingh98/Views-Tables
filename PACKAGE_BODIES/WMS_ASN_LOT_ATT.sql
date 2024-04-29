--------------------------------------------------------
--  DDL for Package Body WMS_ASN_LOT_ATT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ASN_LOT_ATT" AS
/* $Header: WMSINTLB.pls 120.4 2005/10/17 10:38:04 methomas noship $ */

PROCEDURE print_debug(p_err_msg VARCHAR2,
                      p_level NUMBER)
IS
     l_trace_on NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'WMS_ASN_LOT_ATT',
      p_level => p_level);


   SELECT fnd_profile.value('INV_DEBUG_TRACE')
     INTO l_trace_on
     FROM dual;

   IF l_trace_on = 1 THEN
      FND_FILE.put_line(FND_FILE.LOG, 'WMS_ASN_LOT_ATT : ' || p_err_msg);
   END IF;

--dbms_output.put_line('WMS_ASN_LOT_ATT -msg:  '|| p_err_msg);

END print_debug;


procedure populatelotattributescolumn IS
   l_column_idx BINARY_INTEGER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   g_lot_attributes_tbl(1).COLUMN_NAME := 'GRADE_CODE';
   g_lot_attributes_tbl(1).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(2).COLUMN_NAME := 'ORIGINATION_DATE';
   g_lot_attributes_tbl(2).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(3).COLUMN_NAME := 'DATE_CODE';
   g_lot_attributes_tbl(3).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(4).COLUMN_NAME := 'STATUS_ID';
   g_lot_attributes_tbl(4).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(5).COLUMN_NAME := 'CHANGE_DATE';
   g_lot_attributes_tbl(5).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(6).COLUMN_NAME := 'AGE';
   g_lot_attributes_tbl(6).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(7).COLUMN_NAME := 'RETEST_DATE';
   g_lot_attributes_tbl(7).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(8).COLUMN_NAME := 'MATURITY_DATE';
   g_lot_attributes_tbl(8).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(9).COLUMN_NAME := 'LOT_ATTRIBUTE_CATEGORY';
   g_lot_attributes_tbl(9).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(10).COLUMN_NAME := 'ITEM_SIZE';
   g_lot_attributes_tbl(10).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(11).COLUMN_NAME := 'COLOR';
   g_lot_attributes_tbl(11).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(12).COLUMN_NAME := 'VOLUME';
   g_lot_attributes_tbl(12).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(13).COLUMN_NAME := 'VOLUME_UOM';
   g_lot_attributes_tbl(13).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(14).COLUMN_NAME := 'PLACE_OF_ORIGIN';
   g_lot_attributes_tbl(14).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(15).COLUMN_NAME := 'BEST_BY_DATE';
   g_lot_attributes_tbl(15).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(16).COLUMN_NAME := 'LENGTH';
   g_lot_attributes_tbl(16).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(17).COLUMN_NAME := 'LENGTH_UOM';
   g_lot_attributes_tbl(17).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(18).COLUMN_NAME := 'RECYCLED_CONTENT';
   g_lot_attributes_tbl(18).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(19).COLUMN_NAME := 'THICKNESS';
   g_lot_attributes_tbl(19).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(20).COLUMN_NAME := 'THICKNESS_UOM';
   g_lot_attributes_tbl(20).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(21).COLUMN_NAME := 'WIDTH';
   g_lot_attributes_tbl(21).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(22).COLUMN_NAME := 'WIDTH_UOM';
   g_lot_attributes_tbl(22).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(23).COLUMN_NAME := 'CURL_WRINKLE_FOLD';
   g_lot_attributes_tbl(23).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(24).COLUMN_NAME := 'C_ATTRIBUTE1';
   g_lot_attributes_tbl(24).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(25).COLUMN_NAME := 'C_ATTRIBUTE2';
   g_lot_attributes_tbl(25).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(26).COLUMN_NAME := 'C_ATTRIBUTE3';
   g_lot_attributes_tbl(26).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(27).COLUMN_NAME := 'C_ATTRIBUTE4';
   g_lot_attributes_tbl(27).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(28).COLUMN_NAME := 'C_ATTRIBUTE5';
   g_lot_attributes_tbl(28).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(29).COLUMN_NAME := 'C_ATTRIBUTE6';
   g_lot_attributes_tbl(29).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(30).COLUMN_NAME := 'C_ATTRIBUTE7';
   g_lot_attributes_tbl(30).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(31).COLUMN_NAME := 'C_ATTRIBUTE8';
   g_lot_attributes_tbl(31).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(32).COLUMN_NAME := 'C_ATTRIBUTE9';
   g_lot_attributes_tbl(32).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(33).COLUMN_NAME := 'C_ATTRIBUTE10';
   g_lot_attributes_tbl(33).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(34).COLUMN_NAME := 'C_ATTRIBUTE11';
   g_lot_attributes_tbl(34).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(35).COLUMN_NAME := 'C_ATTRIBUTE12';
   g_lot_attributes_tbl(35).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(36).COLUMN_NAME := 'C_ATTRIBUTE13';
   g_lot_attributes_tbl(36).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(37).COLUMN_NAME := 'C_ATTRIBUTE14';
   g_lot_attributes_tbl(37).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(38).COLUMN_NAME := 'C_ATTRIBUTE15';
   g_lot_attributes_tbl(38).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(39).COLUMN_NAME := 'C_ATTRIBUTE16';
   g_lot_attributes_tbl(39).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(40).COLUMN_NAME := 'C_ATTRIBUTE17';
   g_lot_attributes_tbl(40).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(41).COLUMN_NAME := 'C_ATTRIBUTE18';
   g_lot_attributes_tbl(41).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(42).COLUMN_NAME := 'C_ATTRIBUTE19';
   g_lot_attributes_tbl(42).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(43).COLUMN_NAME := 'C_ATTRIBUTE20';
   g_lot_attributes_tbl(43).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(44).COLUMN_NAME := 'D_ATTRIBUTE1';
   g_lot_attributes_tbl(44).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(45).COLUMN_NAME := 'D_ATTRIBUTE2';
   g_lot_attributes_tbl(45).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(46).COLUMN_NAME := 'D_ATTRIBUTE3';
   g_lot_attributes_tbl(46).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(47).COLUMN_NAME := 'D_ATTRIBUTE4';
   g_lot_attributes_tbl(47).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(48).COLUMN_NAME := 'D_ATTRIBUTE5';
   g_lot_attributes_tbl(48).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(49).COLUMN_NAME := 'D_ATTRIBUTE6';
   g_lot_attributes_tbl(49).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(50).COLUMN_NAME := 'D_ATTRIBUTE7';
   g_lot_attributes_tbl(50).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(51).COLUMN_NAME := 'D_ATTRIBUTE8';
   g_lot_attributes_tbl(51).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(52).COLUMN_NAME := 'D_ATTRIBUTE9';
   g_lot_attributes_tbl(52).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(53).COLUMN_NAME := 'D_ATTRIBUTE10';
   g_lot_attributes_tbl(53).COLUMN_TYPE := 'DATE';

   g_lot_attributes_tbl(54).COLUMN_NAME := 'N_ATTRIBUTE1';
   g_lot_attributes_tbl(54).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(55).COLUMN_NAME := 'N_ATTRIBUTE2';
   g_lot_attributes_tbl(55).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(56).COLUMN_NAME := 'N_ATTRIBUTE3';
   g_lot_attributes_tbl(56).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(57).COLUMN_NAME := 'N_ATTRIBUTE4';
   g_lot_attributes_tbl(57).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(58).COLUMN_NAME := 'N_ATTRIBUTE5';
   g_lot_attributes_tbl(58).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(59).COLUMN_NAME := 'N_ATTRIBUTE6';
   g_lot_attributes_tbl(59).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(60).COLUMN_NAME := 'N_ATTRIBUTE7';
   g_lot_attributes_tbl(60).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(61).COLUMN_NAME := 'N_ATTRIBUTE8';
   g_lot_attributes_tbl(61).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(62).COLUMN_NAME := 'N_ATTRIBUTE10';
   g_lot_attributes_tbl(62).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(63).COLUMN_NAME := 'SUPPLIER_LOT_NUMBER';
   g_lot_attributes_tbl(63).COLUMN_TYPE := 'VARCHAR2';

   g_lot_attributes_tbl(64).COLUMN_NAME := 'N_ATTRIBUTE9';
   g_lot_attributes_tbl(64).COLUMN_TYPE := 'NUMBER';

   g_lot_attributes_tbl(65).COLUMN_NAME := 'TERRITORY_CODE';
   g_lot_attributes_tbl(65).COLUMN_TYPE := 'VARCHAR2';
END;


procedure validate_lot (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_interface_transaction_id    IN  NUMBER
) IS

CURSOR c_rcv_txn_interface_rec IS
        SELECT group_id,
               to_organization_id,
               item_id,
               item_revision,
               shipment_header_id,
               po_line_id,
               quantity,
               unit_of_measure,
               uom_code,
               header_interface_id
         FROM  rcv_transactions_interface
        WHERE  interface_transaction_id = p_interface_transaction_id;



CURSOR c_lot_cursor IS
           select GRADE_CODE
                  , fnd_date.date_to_canonical(ORIGINATION_DATE)
                  , DATE_CODE
                  , to_char(STATUS_ID)
                  , fnd_date.date_to_canonical(CHANGE_DATE)
                  , to_number(AGE)
                  , fnd_date.date_to_canonical(RETEST_DATE)
                  , fnd_date.date_to_canonical(MATURITY_DATE)
                  , LOT_ATTRIBUTE_CATEGORY
                  , to_char(ITEM_SIZE)
                  , COLOR
                  , to_char(VOLUME )
                  , VOLUME_UOM_CODE
                  , PLACE_OF_ORIGIN
                  , fnd_date.date_to_canonical(BEST_BY_DATE )
                  , to_char(LENGTH )
                  , LENGTH_UOM_CODE
                  , to_char(RECYCLED_CONTENT )
                  , to_char(THICKNESS )
                  , THICKNESS_UOM_CODE
                  , to_char(WIDTH )
                  , WIDTH_UOM_CODE
                  , CURL_WRINKLE_FOLD
                  , C_ATTRIBUTE1
                  , C_ATTRIBUTE2
                  , C_ATTRIBUTE3
                  , C_ATTRIBUTE4
                  , C_ATTRIBUTE5
                  , C_ATTRIBUTE6
                  , C_ATTRIBUTE7
                  , C_ATTRIBUTE8
                  , C_ATTRIBUTE9
                  , C_ATTRIBUTE10
                  , C_ATTRIBUTE11
                  , C_ATTRIBUTE12
                  , C_ATTRIBUTE13
                  , C_ATTRIBUTE14
                  , C_ATTRIBUTE15
                  , C_ATTRIBUTE16
                  , C_ATTRIBUTE17
                  , C_ATTRIBUTE18
                  , C_ATTRIBUTE19
                  , C_ATTRIBUTE20
                  , fnd_date.date_to_canonical(D_ATTRIBUTE1)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE2)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE3)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE4)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE5)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE6)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE7)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE8)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE9)
                  , fnd_date.date_to_canonical(D_ATTRIBUTE10)
                  , to_char(N_ATTRIBUTE1)
                  , to_char(N_ATTRIBUTE2)
                  , to_char(N_ATTRIBUTE3)
                  , to_char(N_ATTRIBUTE4)
                  , to_char(N_ATTRIBUTE5)
                  , to_char(N_ATTRIBUTE6)
                  , to_char(N_ATTRIBUTE7)
                  , to_char(N_ATTRIBUTE8)
                  , to_char(N_ATTRIBUTE10)
                  , SUPPLIER_LOT_NUMBER
                  , to_char(N_ATTRIBUTE9)
                  , territory_code
                  , STATUS_NAME
                  , EXPIRATION_DATE
                  , LOT_NUMBER
                  -- other columns
                  , ATTRIBUTE_CATEGORY
                  , ATTRIBUTE1
                  , ATTRIBUTE2
                  , ATTRIBUTE3
                  , ATTRIBUTE4
                  , ATTRIBUTE5
                  , ATTRIBUTE6
                  , ATTRIBUTE7
                  , ATTRIBUTE8
                  , ATTRIBUTE9
                  , ATTRIBUTE10
                  , ATTRIBUTE11
                  , ATTRIBUTE12
                  , ATTRIBUTE13
                  , ATTRIBUTE14
                  , ATTRIBUTE15
            from  wms_lpn_contents_interface
	   WHERE interface_transaction_id = p_interface_transaction_id
	    AND rownum = 1 ; --Bug#4437403.


l_rcv_txn_interface_rec c_rcv_txn_interface_rec%ROWTYPE;
l_organization_id NUMBER;
l_inventory_item_id NUMBER;
x_context_value mtl_flex_context.descriptive_flex_context_code%type;
l_attributes_name VARCHAR2(50) := 'Lot Attributes';
v_flexfield     fnd_dflex.dflex_r;
v_flexinfo      fnd_dflex.dflex_dr;
v_contexts      fnd_dflex.contexts_dr;
v_segments      fnd_dflex.segments_dr;
l_return_status VARCHAR2(1);
l_status        BOOLEAN;
l_progress      varchar2(100);
v_colname       varchar2(50);
l_status_name   varchar2(30);
l_expiration_date date;
l_object_id     number;

l_lot_control_code NUMBER;
l_lotunique      NUMBER;
l_lotcount       NUMBER;
l_userid         NUMBER;
l_loginid        NUMBER;
l_shelf_life_code NUMBER;
l_shelf_life_days NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
l_lot_number     varchar2(80);

l_attributes_default INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_TBL_TYPE;
l_attributes_default_count NUMBER;
l_attributes_in  INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_TBL_TYPE;


l_lot_status_enabled       VARCHAR2(1);
l_default_lot_status_id    NUMBER := NULL;
l_lot_status_id            NUMBER := NULL;
l_serial_status_enabled    VARCHAR2(1);
l_default_serial_status_id NUMBER;
l_status_rec               INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type;

l_input_idx BINARY_INTEGER;
l_msg_count  number;


 l_ATTRIBUTE_CATEGORY                       VARCHAR2(30)  ;
 l_ATTRIBUTE1                               VARCHAR2(150) ;
 l_ATTRIBUTE2                               VARCHAR2(150) ;
 l_ATTRIBUTE3                               VARCHAR2(150) ;
 l_ATTRIBUTE4                               VARCHAR2(150) ;
 l_ATTRIBUTE5                               VARCHAR2(150) ;
 l_ATTRIBUTE6                               VARCHAR2(150) ;
 l_ATTRIBUTE7                               VARCHAR2(150) ;
 l_ATTRIBUTE8                               VARCHAR2(150) ;
 l_ATTRIBUTE9                               VARCHAR2(150) ;
 l_ATTRIBUTE10                              VARCHAR2(150) ;
 l_ATTRIBUTE11                              VARCHAR2(150) ;
 l_ATTRIBUTE12                              VARCHAR2(150) ;
 l_ATTRIBUTE13                              VARCHAR2(150) ;
 l_ATTRIBUTE14                              VARCHAR2(150) ;
 l_ATTRIBUTE15                              VARCHAR2(150) ;




    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

l_progress := '10';

IF (l_debug = 1) THEN
   print_debug('Inside Validate Procedure at step '|| l_progress, 4);
END IF;

SAVEPOINT   InsertLot_sv;

--  Initialize return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

l_progress := '10';

OPEN c_rcv_txn_interface_rec;
FETCH c_rcv_txn_interface_rec INTO l_rcv_txn_interface_rec;

IF c_rcv_txn_interface_rec%NOTFOUND THEN
   CLOSE c_rcv_txn_interface_rec;
   IF (l_debug = 1) THEN
      print_debug('No record exists in RCV_TRANSACTIONS_INTERFACE for this interface_transaction_ID', 4);
   END IF;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

CLOSE c_rcv_txn_interface_rec;

--Get The Values from rti.

l_organization_id   := l_rcv_txn_interface_rec.to_organization_id;
l_inventory_item_id := l_rcv_txn_interface_rec.item_id;

l_progress := '20';
IF (l_debug = 1) THEN
   print_debug('Inside Validate Procedure at step '|| l_progress, 4);
END IF;

--Get The Values for Lot Related Attributes

select mtl_gen_object_id_s.nextval into l_object_id from dual;

populatelotattributescolumn;

l_progress := '30';
IF (l_debug = 1) THEN
   print_debug('Inside Validate Procedure After Calling populateattributecolumns ', 4);
END IF;


           open c_lot_cursor;
	   LOOP

l_progress := '40';
IF (l_debug = 1) THEN
   print_debug('Validate Procedure after opening Lot cursor ', 4);
END IF;

     fetch c_lot_cursor into g_lot_attributes_tbl(1).column_value, g_lot_attributes_tbl(2).column_value,
	       g_lot_attributes_tbl(3).column_value, g_lot_attributes_tbl(4).column_value,
	       g_lot_attributes_tbl(5).column_value, g_lot_attributes_tbl(6).column_value,
	       g_lot_attributes_tbl(7).column_value, g_lot_attributes_tbl(8).column_value,
               g_lot_attributes_tbl(9).column_value, g_lot_attributes_tbl(10).column_value,
               g_lot_attributes_tbl(11).column_value, g_lot_attributes_tbl(12).column_value,
               g_lot_attributes_tbl(13).column_value, g_lot_attributes_tbl(14).column_value,
               g_lot_attributes_tbl(15).column_value, g_lot_attributes_tbl(16).column_value,
               g_lot_attributes_tbl(17).column_value, g_lot_attributes_tbl(18).column_value,
               g_lot_attributes_tbl(19).column_value, g_lot_attributes_tbl(20).column_value,
               g_lot_attributes_tbl(21).column_value, g_lot_attributes_tbl(22).column_value,
               g_lot_attributes_tbl(23).column_value, g_lot_attributes_tbl(24).column_value,
               g_lot_attributes_tbl(25).column_value, g_lot_attributes_tbl(26).column_value,
               g_lot_attributes_tbl(27).column_value, g_lot_attributes_tbl(28).column_value,
               g_lot_attributes_tbl(29).column_value, g_lot_attributes_tbl(30).column_value,
               g_lot_attributes_tbl(31).column_value, g_lot_attributes_tbl(32).column_value,
               g_lot_attributes_tbl(33).column_value, g_lot_attributes_tbl(34).column_value,
               g_lot_attributes_tbl(35).column_value, g_lot_attributes_tbl(36).column_value,
               g_lot_attributes_tbl(37).column_value, g_lot_attributes_tbl(38).column_value,
               g_lot_attributes_tbl(39).column_value, g_lot_attributes_tbl(40).column_value,
               g_lot_attributes_tbl(41).column_value, g_lot_attributes_tbl(42).column_value,
               g_lot_attributes_tbl(43).column_value, g_lot_attributes_tbl(44).column_value,
               g_lot_attributes_tbl(45).column_value, g_lot_attributes_tbl(46).column_value,
               g_lot_attributes_tbl(47).column_value, g_lot_attributes_tbl(48).column_value,
               g_lot_attributes_tbl(49).column_value, g_lot_attributes_tbl(50).column_value,
               g_lot_attributes_tbl(51).column_value, g_lot_attributes_tbl(52).column_value,
               g_lot_attributes_tbl(53).column_value, g_lot_attributes_tbl(54).column_value,
               g_lot_attributes_tbl(55).column_value, g_lot_attributes_tbl(56).column_value,
               g_lot_attributes_tbl(57).column_value, g_lot_attributes_tbl(58).column_value,
               g_lot_attributes_tbl(59).column_value, g_lot_attributes_tbl(60).column_value,
               g_lot_attributes_tbl(61).column_value, g_lot_attributes_tbl(62).column_value,
               g_lot_attributes_tbl(63).column_value, g_lot_attributes_tbl(64).column_value,
               g_lot_attributes_tbl(65).column_value,
               l_status_name, l_expiration_date, l_lot_number
                  , l_ATTRIBUTE_CATEGORY
                  , l_ATTRIBUTE1
                  , l_ATTRIBUTE2
                  , l_ATTRIBUTE3
                  , l_ATTRIBUTE4
                  , l_ATTRIBUTE5
                  , l_ATTRIBUTE6
                  , l_ATTRIBUTE7
                  , l_ATTRIBUTE8
                  , l_ATTRIBUTE9
                  , l_ATTRIBUTE10
                  , l_ATTRIBUTE11
                  , l_ATTRIBUTE12
                  , l_ATTRIBUTE13
                  , l_ATTRIBUTE14
                  , l_ATTRIBUTE15
               ;
	       exit when c_lot_cursor%NOTFOUND;
	   end loop;
           close c_lot_cursor;

-- Check for Lot UniqueNess
    BEGIN
        SELECT LOT_CONTROL_CODE
          INTO l_lot_control_code
          FROM MTL_SYSTEM_ITEMS
         WHERE INVENTORY_ITEM_ID = l_inventory_item_id
        AND ORGANIZATION_ID = l_organization_id;

        if(l_lot_control_code = 1) then
           fnd_message.set_name('INV','INV_NO_LOT_CONTROL');
           fnd_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           fnd_message.set_name('INV','INV_INVALID_ITEM');
           fnd_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

l_progress := '40.1';

    SELECT LOT_NUMBER_UNIQUENESS
       INTO l_lotunique
       FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = l_organization_id;

     if(l_lotunique = 1) then
        SELECT count(1)
          INTO l_lotcount
          FROM MTL_LOT_NUMBERS
         WHERE inventory_item_id <> l_inventory_item_id
           AND lot_number = l_lot_number;

        if(l_lotcount > 0) then
           fnd_message.set_name('INV','INV_INT_LOTUNIQEXP');
           fnd_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
     end if;

    SELECT count(1)
       INTO l_lotcount
       FROM MTL_LOT_NUMBERS
      WHERE INVENTORY_ITEM_ID = l_inventory_item_id
        AND ORGANIZATION_ID = l_organization_id
        AND LOT_NUMBER = l_lot_number;

if(l_lotcount = 0) then
      l_userid := fnd_global.user_id;
      l_loginid := fnd_global.login_id;
else
      fnd_message.set_name('INV','INV_INT_LOTUNIQEXP');
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
-- Stop PRocessing HERE
end if;


l_progress := '40.2';

if(l_expiration_date IS NULL) then
     SELECT SHELF_LIFE_CODE,
            SHELF_LIFE_DAYS
      INTO l_shelf_life_code,
           l_shelf_life_days
      FROM MTL_SYSTEM_ITEMS
     WHERE INVENTORY_ITEM_ID = l_inventory_item_id
       AND ORGANIZATION_ID = l_organization_id;

       if(l_shelf_life_code = 2) then
          SELECT SYSDATE + l_shelf_life_days
            INTO l_expiration_date
            FROM DUAL;
       elsif(l_shelf_life_code = 4) then
           fnd_message.set_name('INV','INV_LOT_EXPREQD');
           fnd_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
end if;

--Get All The Not Null vAlues and put in a temp area
l_input_idx := 0;
for x in 1..65 LOOP
    if( g_lot_attributes_tbl(x).column_value is not null ) then
        l_input_idx := l_input_idx + 1;
        l_attributes_in(l_input_idx).column_name := g_lot_attributes_tbl(x).column_name;
        l_attributes_in(l_input_idx).column_value := g_lot_attributes_tbl(x).column_value;
        l_attributes_in(l_input_idx).column_type := g_lot_attributes_tbl(x).column_type;
    end if;
end loop;

if( inv_install.adv_inv_installed(null) = true )then
         inv_lot_sel_attr.get_default(
              x_attributes_default         => l_attributes_default,
              x_attributes_default_count   => l_attributes_default_count,
              x_return_status              => l_return_status,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => x_msg_data,
              p_table_name                 => 'MTL_LOT_NUMBERS',
              p_attributes_name            => 'Lot Attributes',
              p_inventory_item_id          => l_inventory_item_id,
              p_organization_id            => l_organization_id,
              p_lot_serial_number          => l_lot_number,
              p_attributes                 => l_attributes_in);

           if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
              x_return_status :=  l_return_status;
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

if( l_attributes_default_count > 0 ) then
for i in 1..l_attributes_default_count LOOP
  for j in 1..g_lot_attributes_tbl.count LOOP
    if( upper(l_attributes_default(i).COLUMN_NAME) = upper(g_lot_attributes_tbl(j).COLUMN_NAME) ) then
                    g_lot_attributes_tbl(j).COLUMN_VALUE := l_attributes_default(i).COLUMN_VALUE;
    end if;
    exit when (upper(l_attributes_default(i).COLUMN_NAME) = upper(g_lot_attributes_tbl(j).COLUMN_NAME));
  end loop;
end loop;
end if;
end if;


-- Get the default Status Id

           INV_MATERIAL_STATUS_GRP.get_lot_serial_status_control(
                p_organization_id               => l_organization_id
           ,    p_inventory_item_id             => l_inventory_item_id
           ,    x_return_status                 => l_return_status
           ,    x_msg_count                     => l_msg_count
           ,    x_msg_data                      => x_msg_data
           ,    x_lot_status_enabled            => l_lot_status_enabled
           ,    x_default_lot_status_id         => l_default_lot_status_id
           ,    x_serial_status_enabled         => l_serial_status_enabled
           ,    x_default_serial_status_id      => l_default_serial_status_id);


if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
              x_return_status :=  l_return_status;
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
end if;

if(NVL(l_lot_status_enabled, 'Y') = 'Y') then
      -- For consistency, fill after converting to 'char'
       g_lot_attributes_tbl(4).COLUMN_VALUE := to_char(l_default_lot_status_id);

-- This will be overwritten if something is specified in STATUS_NAME
Begin
    if l_status_name is not null then
    select status_id
      into l_lot_status_id
      from mtl_material_statuses_vl
     where status_code = l_status_name
     ;
     g_lot_attributes_tbl(4).COLUMN_VALUE := to_char(l_lot_status_id);
    end if;
Exception
    When others then null;
End;
End if;

l_progress := '50';
IF (l_debug = 1) THEN
   print_debug('Getting All the context Codes '||' Progress ='|| l_progress , 4);
END IF;

-- Get the Context Code for this Item First

-- Get flexfield
    fnd_dflex.get_flexfield('INV', l_attributes_name, v_flexfield, v_flexinfo);

-- Get Contexts
    fnd_dflex.get_contexts(v_flexfield, v_contexts);


l_progress := '60';
IF (l_debug = 1) THEN
   print_debug('Number of  contexts Found '||v_contexts.ncontexts , 4);
END IF;


l_progress := '70';

-- First Check whether context is present in the interface
-- row, if not then get the context code
---

if g_lot_attributes_tbl(9).column_value is null then
           inv_lot_sel_attr.get_context_code(x_context_value,
           l_organization_id,l_inventory_item_id,l_attributes_name);
   g_lot_attributes_tbl(9).column_value := x_context_value;

   IF (l_debug = 1) THEN
      print_debug('No context set in interface record Setting context to '||x_context_value, 4);
   END IF;
else
   x_context_value :=  g_lot_attributes_tbl(9).column_value;
   IF (l_debug = 1) THEN
      print_debug('Context set in interface record value =  '||x_context_value, 4);
   END IF;
end if;


-- Set the Context Code for validating the Lot Attributes.
l_progress := '80';


-- SKIP THE VALIDATION IF CONTEXT FOUND IS NULL

if x_context_value is not null
then

fnd_flex_descval.set_context_value(x_context_value);
fnd_flex_descval.clear_column_values;
fnd_flex_descval.set_column_value('LOT_ATTRIBUTE_CATEGORY',
            g_lot_attributes_tbl(9).column_value);

IF (l_debug = 1) THEN
   print_debug('After Setting the  context Code for validation '||' Progress ='|| l_progress , 4);
END IF;


-- Setting the Values for Validating

       FOR i IN 1..v_contexts.ncontexts LOOP

IF (l_debug = 1) THEN
   print_debug('cheking for context Code '||v_contexts.context_code(i) , 4);
END IF;

                IF(v_contexts.is_enabled(i) AND
                   ((UPPER(v_contexts.context_code(i)) = UPPER(x_context_value)) OR
                    v_contexts.is_global(i))
                  ) THEN
 			-- Get segments
                        fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield,
                                                        v_contexts.context_code(i)),
                                                        v_segments, TRUE);

                        <<segmentLoop>>
                        FOR j IN 1..v_segments.nsegments LOOP
                                IF v_segments.is_enabled(j) THEN
                                        v_colName := v_segments.application_column_name(j);
                                        <<columnLoop>>
                                        FOR k IN 1..g_lot_attributes_tbl.count() LOOP
                                                IF UPPER(v_colName) = UPPER(g_lot_attributes_tbl(k).column_name) THEN

                                       -- Sets the Values for Validation

                                       -- Setting the column data type for validation
                                      if g_lot_attributes_tbl(k).column_type = 'DATE' then
                                               IF (l_debug = 1) THEN
                                                  print_debug('Setting the  columns for validation -- Date' , 4);
                                               END IF;
                                        fnd_flex_descval.set_column_value(g_lot_attributes_tbl(k).column_name,
                                        fnd_date.canonical_to_date(g_lot_attributes_tbl(k).column_value));
                                      end if;

                                      if g_lot_attributes_tbl(k).column_type = 'NUMBER' then
                                               IF (l_debug = 1) THEN
                                                  print_debug('Setting the  columns for validation -- Number' , 4);
                                               END IF;
                                               fnd_flex_descval.set_column_value(g_lot_attributes_tbl(k).column_name,
                                               to_number(g_lot_attributes_tbl(k).column_value));
                                      end if;

                                      if g_lot_attributes_tbl(k).column_type = 'VARCHAR2' then
                                               IF (l_debug = 1) THEN
                                                  print_debug('Setting the  columns for validation -- Varchar2' , 4);
                                               END IF;
                                               fnd_flex_descval.set_column_value(g_lot_attributes_tbl(k).column_name,
                                               g_lot_attributes_tbl(k).column_value);
                                      end if;

                    IF (l_debug = 1) THEN
                       print_debug('Setting the  columns for validation ' , 4);
                       print_debug('column Name '|| g_lot_attributes_tbl(k).column_name , 4);
                       print_debug('column Value '||g_lot_attributes_tbl(k).column_value , 4);
                    END IF;

                    --print_debug('Calling the Validation API ' , 4);

                                        EXIT columnLoop; -- found column
                                                END IF;
                                        END LOOP columnLoop;

                                END IF;
                        END LOOP segmentLoop;
                END IF;
        END LOOP contextLoop;


-- Call the  validating routine for Lot Attributes.

l_progress := '90';
IF (l_debug = 1) THEN
   print_debug('Before Calling The API for validation ' , 4);
END IF;

l_status := fnd_flex_descval.validate_desccols(
           appl_short_name => 'INV',
           desc_flex_name => l_attributes_name);

if l_status = TRUE then
     IF (l_debug = 1) THEN
        print_debug('API for validation is successfull' , 4);
     END IF;
     null;
else
     IF (l_debug = 1) THEN
        print_debug('API for validation is failure' , 4);
        print_debug('Error Messages '|| fnd_flex_descval.error_message , 4);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     x_msg_data := fnd_flex_descval.error_message;
     raise FND_API.G_EXC_ERROR;
end if;

l_progress := '100';
--
-- Else Insert the Row into mtl_lot_number
--
--


end if;

--
-- END OF VALIDATION
--
--


l_progress := '110';
IF (l_debug = 1) THEN
   print_debug('Before Inserting into MTL_LOT_NUMBERS  ' , 4);
END IF;

           INSERT INTO MTL_LOT_NUMBERS
                (INVENTORY_ITEM_ID,
		 ORGANIZATION_ID,
		 LOT_NUMBER,
		 LAST_UPDATE_DATE,
		 LAST_UPDATED_BY,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 EXPIRATION_DATE,
		 DISABLE_FLAG,
		 ATTRIBUTE_CATEGORY,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 REQUEST_ID,
		 PROGRAM_APPLICATION_ID,
		 PROGRAM_ID,
		 PROGRAM_UPDATE_DATE,
		 GEN_OBJECT_ID,
		 DESCRIPTION,
		 VENDOR_ID,
		 GRADE_CODE,
		 ORIGINATION_DATE,
		 DATE_CODE,
		 STATUS_ID,
		 CHANGE_DATE,
		 AGE,
		 RETEST_DATE,
		 MATURITY_DATE,
		 LOT_ATTRIBUTE_CATEGORY,
		 ITEM_SIZE,
		 COLOR,
		 VOLUME,
		 VOLUME_UOM,
		 PLACE_OF_ORIGIN,
		 BEST_BY_DATE,
		 LENGTH,
		 LENGTH_UOM,
		 RECYCLED_CONTENT,
		 THICKNESS,
		 THICKNESS_UOM,
		 WIDTH,
		 WIDTH_UOM,
		 CURL_WRINKLE_FOLD,
		 C_ATTRIBUTE1,
		 C_ATTRIBUTE2,
		 C_ATTRIBUTE3,
		 C_ATTRIBUTE4,
		 C_ATTRIBUTE5,
		 C_ATTRIBUTE6,
		 C_ATTRIBUTE7,
		 C_ATTRIBUTE8,
		 C_ATTRIBUTE9,
		 C_ATTRIBUTE10,
		 C_ATTRIBUTE11,
		 C_ATTRIBUTE12,
		 C_ATTRIBUTE13,
		 C_ATTRIBUTE14,
		 C_ATTRIBUTE15,
		 C_ATTRIBUTE16,
		 C_ATTRIBUTE17,
		 C_ATTRIBUTE18,
		 C_ATTRIBUTE19,
		 C_ATTRIBUTE20,
		 D_ATTRIBUTE1,
		 D_ATTRIBUTE2,
		 D_ATTRIBUTE3,
		 D_ATTRIBUTE4,
		 D_ATTRIBUTE5,
		 D_ATTRIBUTE6,
		 D_ATTRIBUTE7,
		 D_ATTRIBUTE8,
		 D_ATTRIBUTE9,
		 D_ATTRIBUTE10,
		 N_ATTRIBUTE1,
		 N_ATTRIBUTE2,
		 N_ATTRIBUTE3,
		 N_ATTRIBUTE4,
		 N_ATTRIBUTE5,
		 N_ATTRIBUTE6,
		 N_ATTRIBUTE7,
		 N_ATTRIBUTE8,
		 N_ATTRIBUTE9,
		 SUPPLIER_LOT_NUMBER,
		 N_ATTRIBUTE10,
		 TERRITORY_CODE)
              VALUES
                (l_inventory_item_id,
		 l_organization_id,
		 l_lot_number,
		 SYSDATE,
		 l_userid,
		 SYSDATE,
		 l_userid,
		 l_loginid,
		 l_expiration_date,
		 null,
                 l_ATTRIBUTE_CATEGORY ,
                 l_ATTRIBUTE1   ,
                 l_ATTRIBUTE2   ,
                 l_ATTRIBUTE3   ,
                 l_ATTRIBUTE4  ,
                 l_ATTRIBUTE5   ,
                 l_ATTRIBUTE6  ,
                 l_ATTRIBUTE7   ,
                 l_ATTRIBUTE8,
                 l_ATTRIBUTE9  ,
                 l_ATTRIBUTE10  ,
                 l_ATTRIBUTE11,
                 l_ATTRIBUTE12 ,
                 l_ATTRIBUTE13  ,
                 l_ATTRIBUTE14 ,
                 l_ATTRIBUTE15  ,
		 null,
		 null,
		 null,
		 null,
		 l_object_id,
		 null,
		 to_number(null), -- Vendor ID currently Set as Null
		 g_lot_attributes_tbl(1).COLUMN_VALUE,
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(2).COLUMN_VALUE),
		 g_lot_attributes_tbl(3).COLUMN_VALUE,
		 to_number(g_lot_attributes_tbl(4).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(5).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(6).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(7).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(8).COLUMN_VALUE),
		 g_lot_attributes_tbl(9).COLUMN_VALUE,
		 to_number(g_lot_attributes_tbl(10).COLUMN_VALUE),
		 g_lot_attributes_tbl(11).COLUMN_VALUE,
		 to_number(g_lot_attributes_tbl(12).COLUMN_VALUE),
		 g_lot_attributes_tbl(13).COLUMN_VALUE,
		 g_lot_attributes_tbl(14).COLUMN_VALUE,
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(15).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(16).COLUMN_VALUE),
		 g_lot_attributes_tbl(17).COLUMN_VALUE,
		 to_number(g_lot_attributes_tbl(18).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(19).COLUMN_VALUE),
		 g_lot_attributes_tbl(20).COLUMN_VALUE,
		 to_number(g_lot_attributes_tbl(21).COLUMN_VALUE),
		 g_lot_attributes_tbl(22).COLUMN_VALUE,
		 g_lot_attributes_tbl(23).COLUMN_VALUE,
		 g_lot_attributes_tbl(24).COLUMN_VALUE,
		 g_lot_attributes_tbl(25).COLUMN_VALUE,
		 g_lot_attributes_tbl(26).COLUMN_VALUE,
		 g_lot_attributes_tbl(27).COLUMN_VALUE,
		 g_lot_attributes_tbl(28).COLUMN_VALUE,
		 g_lot_attributes_tbl(29).COLUMN_VALUE,
		 g_lot_attributes_tbl(30).COLUMN_VALUE,
		 g_lot_attributes_tbl(31).COLUMN_VALUE,
		 g_lot_attributes_tbl(32).COLUMN_VALUE,
		 g_lot_attributes_tbl(33).COLUMN_VALUE,
		 g_lot_attributes_tbl(34).COLUMN_VALUE,
		 g_lot_attributes_tbl(35).COLUMN_VALUE,
		 g_lot_attributes_tbl(36).COLUMN_VALUE,
		 g_lot_attributes_tbl(37).COLUMN_VALUE,
		 g_lot_attributes_tbl(38).COLUMN_VALUE,
		 g_lot_attributes_tbl(39).COLUMN_VALUE,
		 g_lot_attributes_tbl(40).COLUMN_VALUE,
		 g_lot_attributes_tbl(41).COLUMN_VALUE,
		 g_lot_attributes_tbl(42).COLUMN_VALUE,
		 g_lot_attributes_tbl(43).COLUMN_VALUE,
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(44).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(45).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(46).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(47).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(48).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(49).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(50).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(51).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(52).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_lot_attributes_tbl(53).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(54).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(55).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(56).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(57).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(58).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(59).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(60).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(61).COLUMN_VALUE),
		 to_number(g_lot_attributes_tbl(62).COLUMN_VALUE),
		 g_lot_attributes_tbl(63).COLUMN_VALUE,
		 to_number(g_lot_attributes_tbl(64).COLUMN_VALUE),
		 g_lot_attributes_tbl(65).COLUMN_VALUE);


l_progress := '120';
IF (l_debug = 1) THEN
   print_debug('After Inserting into MTL_LOT_NUMBERS  ' , 4);
END IF;


EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO InsertLot_sv;
      IF (l_debug = 1) THEN
         print_debug('Process - expected error happened - l_progress : '||l_progress, 1);
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
	(p_count	=>	x_msg_count,
	 p_data		=>	x_msg_data
	 );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO InsertLot_sv;
      IF (l_debug = 1) THEN
         print_debug('Process - unexpected error happened - l_progress : '||l_progress, 1);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
	(p_count	=>	x_msg_count,
	 p_data		=>	x_msg_data
	 );

   WHEN OTHERS THEN
      ROLLBACK TO InsertLot_sv;
      IF (l_debug = 1) THEN
         print_debug('Process - other error happened  - l_progress : '||l_progress, 1);
      END IF;
      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	 print_debug('SQL Error : '||SQLERRM(SQLCODE)||' SQL Error code : '||SQLCODE, 1);
	 END IF;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;


procedure populateSerAttributesColumn IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    g_serial_attributes_tbl(1).COLUMN_NAME := 'SERIAL_ATTRIBUTE_CATEGORY';
    g_serial_attributes_tbl(1).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(2).COLUMN_NAME := 'ORIGINATION_DATE';
    g_serial_attributes_tbl(2).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(3).COLUMN_NAME := 'C_ATTRIBUTE1';
    g_serial_attributes_tbl(3).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(4).COLUMN_NAME := 'C_ATTRIBUTE2';
    g_serial_attributes_tbl(4).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(5).COLUMN_NAME := 'C_ATTRIBUTE3';
    g_serial_attributes_tbl(5).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(6).COLUMN_NAME := 'C_ATTRIBUTE4';
    g_serial_attributes_tbl(6).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(7).COLUMN_NAME := 'C_ATTRIBUTE5';
    g_serial_attributes_tbl(7).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(8).COLUMN_NAME := 'C_ATTRIBUTE6';
    g_serial_attributes_tbl(8).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(9).COLUMN_NAME := 'C_ATTRIBUTE7';
    g_serial_attributes_tbl(9).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(10).COLUMN_NAME := 'C_ATTRIBUTE8';
    g_serial_attributes_tbl(10).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(11).COLUMN_NAME := 'C_ATTRIBUTE9';
    g_serial_attributes_tbl(11).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(12).COLUMN_NAME := 'C_ATTRIBUTE10';
    g_serial_attributes_tbl(12).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(13).COLUMN_NAME := 'C_ATTRIBUTE11';
    g_serial_attributes_tbl(13).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(14).COLUMN_NAME := 'C_ATTRIBUTE12';
    g_serial_attributes_tbl(14).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(15).COLUMN_NAME := 'C_ATTRIBUTE13';
    g_serial_attributes_tbl(15).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(16).COLUMN_NAME := 'C_ATTRIBUTE14';
    g_serial_attributes_tbl(16).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(17).COLUMN_NAME := 'C_ATTRIBUTE15';
    g_serial_attributes_tbl(17).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(18).COLUMN_NAME := 'C_ATTRIBUTE16';
    g_serial_attributes_tbl(18).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(19).COLUMN_NAME := 'C_ATTRIBUTE17';
    g_serial_attributes_tbl(19).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(20).COLUMN_NAME := 'C_ATTRIBUTE18';
    g_serial_attributes_tbl(20).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(21).COLUMN_NAME := 'C_ATTRIBUTE19';
    g_serial_attributes_tbl(21).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(22).COLUMN_NAME := 'C_ATTRIBUTE20';
    g_serial_attributes_tbl(22).COLUMN_TYPE := 'VARCHAR2';

    g_serial_attributes_tbl(23).COLUMN_NAME := 'D_ATTRIBUTE1';
    g_serial_attributes_tbl(23).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(24).COLUMN_NAME := 'D_ATTRIBUTE2';
    g_serial_attributes_tbl(24).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(25).COLUMN_NAME := 'D_ATTRIBUTE3';
    g_serial_attributes_tbl(25).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(26).COLUMN_NAME := 'D_ATTRIBUTE4';
    g_serial_attributes_tbl(26).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(27).COLUMN_NAME := 'D_ATTRIBUTE5';
    g_serial_attributes_tbl(27).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(28).COLUMN_NAME := 'D_ATTRIBUTE6';
    g_serial_attributes_tbl(28).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(29).COLUMN_NAME := 'D_ATTRIBUTE7';
    g_serial_attributes_tbl(29).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(30).COLUMN_NAME := 'D_ATTRIBUTE8';
    g_serial_attributes_tbl(30).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(31).COLUMN_NAME := 'D_ATTRIBUTE9';
    g_serial_attributes_tbl(31).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(32).COLUMN_NAME := 'D_ATTRIBUTE10';
    g_serial_attributes_tbl(32).COLUMN_TYPE := 'DATE';

    g_serial_attributes_tbl(33).COLUMN_NAME := 'N_ATTRIBUTE1';
    g_serial_attributes_tbl(33).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(34).COLUMN_NAME := 'N_ATTRIBUTE2';
    g_serial_attributes_tbl(34).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(35).COLUMN_NAME := 'N_ATTRIBUTE3';
    g_serial_attributes_tbl(35).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(36).COLUMN_NAME := 'N_ATTRIBUTE4';
    g_serial_attributes_tbl(36).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(37).COLUMN_NAME := 'N_ATTRIBUTE5';
    g_serial_attributes_tbl(37).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(38).COLUMN_NAME := 'N_ATTRIBUTE6';
    g_serial_attributes_tbl(38).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(39).COLUMN_NAME := 'N_ATTRIBUTE7';
    g_serial_attributes_tbl(39).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(40).COLUMN_NAME := 'N_ATTRIBUTE8';
    g_serial_attributes_tbl(40).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(41).COLUMN_NAME := 'N_ATTRIBUTE9';
    g_serial_attributes_tbl(41).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(42).COLUMN_NAME := 'N_ATTRIBUTE10';
    g_serial_attributes_tbl(42).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(43).COLUMN_NAME := 'STATUS_ID';
    g_serial_attributes_tbl(43).COLUMN_TYPE := 'NUMBER';

    g_serial_attributes_tbl(44).COLUMN_NAME := 'TERRITORY_CODE';
    g_serial_attributes_tbl(44).COLUMN_TYPE := 'VARCHAR2';

-- New Columns--
 g_serial_attributes_tbl(45).COLUMN_NAME := 'TIME_SINCE_NEW';
 g_serial_attributes_tbl(45).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(46).COLUMN_NAME := 'CYCLES_SINCE_NEW';
 g_serial_attributes_tbl(46).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(47).COLUMN_NAME := 'TIME_SINCE_OVERHAUL';
 g_serial_attributes_tbl(47).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(48).COLUMN_NAME := 'CYCLES_SINCE_OVERHAUL' ;
 g_serial_attributes_tbl(48).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(49).COLUMN_NAME := 'TIME_SINCE_REPAIR' ;
 g_serial_attributes_tbl(49).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(50).COLUMN_NAME := 'CYCLES_SINCE_REPAIR';
 g_serial_attributes_tbl(50).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(51).COLUMN_NAME := 'TIME_SINCE_VISIT'    ;
 g_serial_attributes_tbl(51).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(52).COLUMN_NAME := 'CYCLES_SINCE_VISIT'   ;
 g_serial_attributes_tbl(52).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(53).COLUMN_NAME := 'TIME_SINCE_MARK'       ;
 g_serial_attributes_tbl(53).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(54).COLUMN_NAME := 'CYCLES_SINCE_MARK'      ;
 g_serial_attributes_tbl(54).COLUMN_TYPE := 'NUMBER';

 g_serial_attributes_tbl(55).COLUMN_NAME := 'NUMBER_OF_REPAIRS'  ;
 g_serial_attributes_tbl(55).COLUMN_TYPE := 'NUMBER';


END;

PROCEDURE insertSerial(
                       p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
                       p_inventory_item_id  IN NUMBER,
                       p_organization_id    IN NUMBER,
                       p_serial_number      IN VARCHAR2,
                       p_initialization_date IN DATE,
                       p_completion_date    IN DATE,
                       p_ship_date          IN DATE,
                       p_revision           IN VARCHAR2,
                       p_lot_number         IN VARCHAR2,
                       p_current_locator_id IN NUMBER,
                       p_subinventory_code  IN VARCHAR2,
                       p_trx_src_id         IN NUMBER,
                       p_unit_vendor_id     IN NUMBER,
                       p_vendor_lot_number  IN VARCHAR2,
                       p_vendor_serial_number IN VARCHAR2,
                       p_receipt_issue_type IN NUMBER,
                       p_txn_src_id         IN NUMBER,
                       p_txn_src_name       IN VARCHAR2,
                       p_txn_src_type_id    IN NUMBER,
                       p_transaction_id     IN NUMBER,
                       p_current_status     IN NUMBER,
                       p_parent_item_id     IN NUMBER,
                       p_parent_serial_number IN VARCHAR2,
                       p_cost_group_id      IN NUMBER,
                       p_serial_transaction_intf_id  IN NUMBER,
                       p_status_id            IN NUMBER,
                       x_object_id          OUT NOCOPY NUMBER,
                       x_return_status      OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2)
IS
     l_api_version                 CONSTANT NUMBER := 1.0;
     l_api_name                    CONSTANT VARCHAR2(30):= 'insertSerial';
     l_userid         NUMBER;
     l_loginid        NUMBER;
     l_serial_control_code NUMBER;
     l_attributes_default INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_TBL_TYPE;
     l_attributes_default_count NUMBER;
     l_attributes_in  INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_TBL_TYPE;

     l_column_idx BINARY_INTEGER := 55;

     l_return_status VARCHAR2(1);
     l_msg_data VARCHAR2(2000);
     l_msg_count NUMBER;
     l_status_rec                  INV_MATERIAL_STATUS_PUB.mtl_status_update_rec_type;
     l_status_id   NUMBER := null;
     l_lot_status_enabled       VARCHAR2(1);
     l_default_lot_status_id    NUMBER := NULL;
     l_serial_status_enabled    VARCHAR2(1);
     l_default_serial_status_id NUMBER;
     l_attributes_name          varchar2(100) := 'Serial Attributes';

     l_status_name  varchar2(30);
     l_progress     varchar2(100);


     x_context_value mtl_flex_context.descriptive_flex_context_code%type;
     l_status        BOOLEAN;

     v_flexfield     fnd_dflex.dflex_r;
     v_flexinfo      fnd_dflex.dflex_dr;
     v_contexts      fnd_dflex.contexts_dr;
     v_segments      fnd_dflex.segments_dr;

     v_colname       varchar2(50);

 l_ATTRIBUTE_CATEGORY                       VARCHAR2(30)  ;
 l_ATTRIBUTE1                               VARCHAR2(150) ;
 l_ATTRIBUTE2                               VARCHAR2(150) ;
 l_ATTRIBUTE3                               VARCHAR2(150) ;
 l_ATTRIBUTE4                               VARCHAR2(150) ;
 l_ATTRIBUTE5                               VARCHAR2(150) ;
 l_ATTRIBUTE6                               VARCHAR2(150) ;
 l_ATTRIBUTE7                               VARCHAR2(150) ;
 l_ATTRIBUTE8                               VARCHAR2(150) ;
 l_ATTRIBUTE9                               VARCHAR2(150) ;
 l_ATTRIBUTE10                              VARCHAR2(150) ;
 l_ATTRIBUTE11                              VARCHAR2(150) ;
 l_ATTRIBUTE12                              VARCHAR2(150) ;
 l_ATTRIBUTE13                              VARCHAR2(150) ;
 l_ATTRIBUTE14                              VARCHAR2(150) ;
 l_ATTRIBUTE15                              VARCHAR2(150) ;



        cursor serial_intf_csr(P_SERIAL_TRANSACTION_INTF_ID NUMBER) is
            select SERIAL_ATTRIBUTE_CATEGORY
                   , fnd_date.date_to_canonical(ORIGINATION_DATE )
                   , C_ATTRIBUTE1
                   , C_ATTRIBUTE2
                   , C_ATTRIBUTE3
                   , C_ATTRIBUTE4
                   , C_ATTRIBUTE5
                   , C_ATTRIBUTE6
                   , C_ATTRIBUTE7
                   , C_ATTRIBUTE8
                   , C_ATTRIBUTE9
                   , C_ATTRIBUTE10
                   , C_ATTRIBUTE11
                   , C_ATTRIBUTE12
                   , C_ATTRIBUTE13
                   , C_ATTRIBUTE14
                   , C_ATTRIBUTE15
                   , C_ATTRIBUTE16
                   , C_ATTRIBUTE17
                   , C_ATTRIBUTE18
                   , C_ATTRIBUTE19
                   , C_ATTRIBUTE20
                   , fnd_date.date_to_canonical(D_ATTRIBUTE1 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE2 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE3 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE4 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE5 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE6 )
                   , fnd_date.date_to_canonical(D_ATTRIBUTE7)
                   , fnd_date.date_to_canonical(D_ATTRIBUTE8)
                   , fnd_date.date_to_canonical( D_ATTRIBUTE9)
                   , fnd_date.date_to_canonical(D_ATTRIBUTE10 )
                   , to_char(N_ATTRIBUTE1 )
                   , to_char(N_ATTRIBUTE2)
                   , to_char(N_ATTRIBUTE3)
                   , to_char(N_ATTRIBUTE4)
                   , to_char(N_ATTRIBUTE5)
                   , to_char(N_ATTRIBUTE6)
                   , to_char(N_ATTRIBUTE7)
                   , to_char(N_ATTRIBUTE8)
                   ,to_char( N_ATTRIBUTE9)
                   , to_char(N_ATTRIBUTE10)
                   , STATUS_ID
                   , TERRITORY_CODE
                   , TIME_SINCE_NEW
                   , CYCLES_SINCE_NEW
                   , TIME_SINCE_OVERHAUL
                   , CYCLES_SINCE_OVERHAUL
                   , TIME_SINCE_REPAIR
                   , CYCLES_SINCE_REPAIR
                   , TIME_SINCE_VISIT
                   , CYCLES_SINCE_VISIT
                   , TIME_SINCE_MARK
                   , CYCLES_SINCE_MARK
                   , NUMBER_OF_REPAIRS
                   , STATUS_NAME
                  -- other columns
                  , ATTRIBUTE_CATEGORY
                  , ATTRIBUTE1
                  , ATTRIBUTE2
                  , ATTRIBUTE3
                  , ATTRIBUTE4
                  , ATTRIBUTE5
                  , ATTRIBUTE6
                  , ATTRIBUTE7
                  , ATTRIBUTE8
                  , ATTRIBUTE9
                  , ATTRIBUTE10
                  , ATTRIBUTE11
                  , ATTRIBUTE12
                  , ATTRIBUTE13
                  , ATTRIBUTE14
                  , ATTRIBUTE15
            from mtl_serial_numbers_interface
            where TRANSACTION_INTERFACE_ID = P_SERIAL_TRANSACTION_INTF_ID;

    l_input_idx BINARY_INTEGER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

    IF (l_debug = 1) THEN
       print_debug('Inside Insert Serial ',4);
    END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard Start of API savepoint
    SAVEPOINT   insertSerial_sv;

    l_progress := '10';
    IF (l_debug = 1) THEN
       print_debug('At Step = '|| l_progress,4);
    END IF;

    BEGIN
            SELECT serial_number_control_code
              INTO l_serial_control_code
              FROM MTL_SYSTEM_ITEMS
             WHERE INVENTORY_ITEM_ID = p_inventory_item_id
               AND ORGANIZATION_ID   = p_organization_id;

            if(l_serial_control_code = 1) then
               fnd_message.set_name('INV','INV_NO_SERIAL_CONTROL');
               fnd_msg_pub.add;
               x_return_status := FND_API.G_RET_STS_ERROR;
               return;
            end if;
     EXCEPTION
            WHEN NO_DATA_FOUND THEN
               fnd_message.set_name('INV','INV_INVALID_ITEM');
               fnd_msg_pub.add;
               x_return_status := FND_API.G_RET_STS_ERROR;
               return;
     END;

    l_progress := '20';
    IF (l_debug = 1) THEN
       print_debug('At Step = '|| l_progress,4);
    END IF;

    select mtl_gen_object_id_s.nextval into x_object_id from dual;

    l_progress := '30';
    IF (l_debug = 1) THEN
       print_debug('At Step = '|| l_progress,4);
    END IF;

    populateSerAttributesColumn();

    l_progress := '40';
    IF (l_debug = 1) THEN
       print_debug('At Step = '|| l_progress,4);
    END IF;

    if( p_serial_transaction_intf_id is not null ) then
             open serial_intf_csr(p_serial_transaction_intf_id);
             LOOP
          fetch serial_intf_csr into g_serial_attributes_tbl(1).column_value, g_serial_attributes_tbl(2).column_value,
                        g_serial_attributes_tbl(3).column_value, g_serial_attributes_tbl(4).column_value,
                        g_serial_attributes_tbl(5).column_value, g_serial_attributes_tbl(6).column_value,
                        g_serial_attributes_tbl(7).column_value, g_serial_attributes_tbl(8).column_value,
                        g_serial_attributes_tbl(9).column_value, g_serial_attributes_tbl(10).column_value,
                        g_serial_attributes_tbl(11).column_value, g_serial_attributes_tbl(12).column_value,
                        g_serial_attributes_tbl(13).column_value, g_serial_attributes_tbl(14).column_value,
                        g_serial_attributes_tbl(15).column_value, g_serial_attributes_tbl(16).column_value,
                        g_serial_attributes_tbl(17).column_value, g_serial_attributes_tbl(18).column_value,
                        g_serial_attributes_tbl(19).column_value, g_serial_attributes_tbl(20).column_value,
                        g_serial_attributes_tbl(21).column_value, g_serial_attributes_tbl(22).column_value,
                        g_serial_attributes_tbl(23).column_value, g_serial_attributes_tbl(24).column_value,
                        g_serial_attributes_tbl(25).column_value, g_serial_attributes_tbl(26).column_value,
                        g_serial_attributes_tbl(27).column_value, g_serial_attributes_tbl(28).column_value,
                        g_serial_attributes_tbl(29).column_value, g_serial_attributes_tbl(30).column_value,
                        g_serial_attributes_tbl(31).column_value, g_serial_attributes_tbl(32).column_value,
                        g_serial_attributes_tbl(33).column_value, g_serial_attributes_tbl(34).column_value,
                        g_serial_attributes_tbl(35).column_value, g_serial_attributes_tbl(36).column_value,
                        g_serial_attributes_tbl(37).column_value, g_serial_attributes_tbl(38).column_value,
                        g_serial_attributes_tbl(39).column_value, g_serial_attributes_tbl(40).column_value,
                        g_serial_attributes_tbl(41).column_value, g_serial_attributes_tbl(42).column_value,
                        g_serial_attributes_tbl(43).column_value, g_serial_attributes_tbl(44).column_value,
                        g_serial_attributes_tbl(45).column_value, g_serial_attributes_tbl(46).column_value,
                        g_serial_attributes_tbl(47).column_value, g_serial_attributes_tbl(48).column_value,
                        g_serial_attributes_tbl(49).column_value, g_serial_attributes_tbl(50).column_value,
                        g_serial_attributes_tbl(51).column_value, g_serial_attributes_tbl(52).column_value,
                        g_serial_attributes_tbl(53).column_value, g_serial_attributes_tbl(54).column_value,
                        g_serial_attributes_tbl(55).column_value, l_status_name
                  , l_ATTRIBUTE_CATEGORY
                  , l_ATTRIBUTE1
                  , l_ATTRIBUTE2
                  , l_ATTRIBUTE3
                  , l_ATTRIBUTE4
                  , l_ATTRIBUTE5
                  , l_ATTRIBUTE6
                  , l_ATTRIBUTE7
                  , l_ATTRIBUTE8
                  , l_ATTRIBUTE9
                  , l_ATTRIBUTE10
                  , l_ATTRIBUTE11
                  , l_ATTRIBUTE12
                  , l_ATTRIBUTE13
                  , l_ATTRIBUTE14
                  , l_ATTRIBUTE15
                        ;
                  exit when serial_intf_csr%NOTFOUND;
             END LOOP;
             close serial_intf_csr;

             l_input_idx := 0;
             for x in 1..55 LOOP
                 if( g_serial_attributes_tbl(x).column_value is not null ) then
                    l_input_idx := l_input_idx + 1;
                    l_attributes_in(l_input_idx).column_name := g_serial_attributes_tbl(x).column_name;
                    l_attributes_in(l_input_idx).column_type := g_serial_attributes_tbl(x).column_type;
                    l_attributes_in(l_input_idx).column_value := g_serial_attributes_tbl(x).column_value;
                 end if;
             end loop;
         end if;
         ----------------------------------------------------------
         -- call inv_lot_sel_attr.get_default to get the default value
         -- of the lot attributes
         ---------------------------------------------------------

    l_progress := '50';
    IF (l_debug = 1) THEN
       print_debug('At Step = '|| l_progress,4);
    END IF;

         inv_lot_sel_attr.get_default(
            x_attributes_default           => l_attributes_default,
            x_attributes_default_count => l_attributes_default_count,
            x_return_status        => l_return_status,
            x_msg_count                    => l_msg_count,
            x_msg_data             => l_msg_data,
            p_table_name                   => 'MTL_SERIAL_NUMBERS',
            p_attributes_name          => 'Serial Attributes',
            p_inventory_item_id            => p_inventory_item_id,
            p_organization_id      => p_organization_id,
            p_lot_serial_number            => p_serial_number,
            p_attributes                   => l_attributes_in);

    l_progress := '60';
    IF (l_debug = 1) THEN
       print_debug('At Step = '|| l_progress,4);
    END IF;

         if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
            x_return_status :=  l_return_status;
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

         if( l_attributes_default_count > 0 ) then
            for i in 1..l_attributes_default_count LOOP
                for j in 1..g_serial_attributes_tbl.COUNT LOOP
                    if( l_attributes_default(i).COLUMN_NAME = g_serial_attributes_tbl(j).COLUMN_NAME ) then
                         g_serial_attributes_tbl(j).COLUMN_VALUE := l_attributes_default(i).COLUMN_VALUE;
                    end if;
                end loop;
            end loop;
         end if;
         l_userid := fnd_global.user_id;
         l_loginid := fnd_global.login_id;


    l_progress := '70';
    IF (l_debug = 1) THEN
       print_debug('At Step = '|| l_progress,4);
    END IF;

           --Get the default status Id
           --

               INV_MATERIAL_STATUS_GRP.get_lot_serial_status_control(
                    p_organization_id               => p_organization_id
               ,    p_inventory_item_id             => p_inventory_item_id
               ,    x_return_status                 => l_return_status
               ,    x_msg_count                     => l_msg_count
               ,    x_msg_data                      => l_msg_data
               ,    x_lot_status_enabled            => l_lot_status_enabled
               ,    x_default_lot_status_id         => l_default_lot_status_id
               ,    x_serial_status_enabled         => l_serial_status_enabled
               ,    x_default_serial_status_id      => l_default_serial_status_id);

               if( l_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                  x_return_status :=  l_return_status;
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;

if (NVL(l_serial_status_enabled, 'Y') = 'Y') then
      l_status_id := l_default_serial_status_id;
Begin
    if l_status_name is not null then
            select status_id
              into l_status_id
              from mtl_material_statuses_vl
             where status_code = l_status_name
             ;
    end if;
Exception
    When others then
        IF (l_debug = 1) THEN
           print_debug('Status = '|| l_status_name || ' is invalid , setting to default status' ,4);
        END IF;
        null;
End;
end if;

l_progress := '80';
IF (l_debug = 1) THEN
   print_debug('At Step = '|| l_progress,4);
END IF;

IF (l_debug = 1) THEN
   print_debug('Getting All the context Codes '||' Progress ='|| l_progress , 4);
END IF;

-- Get the Context Code for this Item First

-- Get flexfield
    fnd_dflex.get_flexfield('INV', l_attributes_name, v_flexfield, v_flexinfo);

l_progress := '80';
IF (l_debug = 1) THEN
   print_debug('At Step = '|| l_progress,4);
END IF;

-- Get Contexts
    fnd_dflex.get_contexts(v_flexfield, v_contexts);


IF (l_debug = 1) THEN
   print_debug('Number of  contexts Found '||v_contexts.ncontexts , 4);
END IF;
l_progress := '90';
IF (l_debug = 1) THEN
   print_debug('At Step = '|| l_progress,4);
END IF;

-- First Check whether context is present in the interface
-- row, if not then get the context code
---

if g_serial_attributes_tbl(1).column_value is null then
           l_progress := '90.1';
           IF (l_debug = 1) THEN
              print_debug('At Step = '|| l_progress,4);
           END IF;
           inv_lot_sel_attr.get_context_code(x_context_value,
           p_organization_id,p_inventory_item_id,l_attributes_name);

   g_serial_attributes_tbl(1).column_value := x_context_value;

   IF (l_debug = 1) THEN
      print_debug('No context set in interface record Setting context to '||x_context_value, 4);
   END IF;
else
   x_context_value :=  g_serial_attributes_tbl(1).column_value;
end if;


-- Set the Context Code for validating the Serial Attributes.
l_progress := '100';


-- IF CONTEXT FOUND NULL THEN SKIP THE VALIDATION

if x_context_value is not null
then

fnd_flex_descval.set_context_value(x_context_value);
fnd_flex_descval.clear_column_values;
fnd_flex_descval.set_column_value('SERIAL_ATTRIBUTE_CATEGORY',
            g_serial_attributes_tbl(1).column_value);

IF (l_debug = 1) THEN
   print_debug('After Setting the  context Code for validation '||' Progress ='|| l_progress , 4);
END IF;


-- Setting the Values for Validating

       FOR i IN 1..v_contexts.ncontexts LOOP

IF (l_debug = 1) THEN
   print_debug('cheking for context Code '||v_contexts.context_code(i) , 4);
END IF;

                IF(v_contexts.is_enabled(i) AND
                   ((UPPER(v_contexts.context_code(i)) = UPPER(x_context_value)) OR
                    v_contexts.is_global(i))
                  ) THEN
 			-- Get segments
                        fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield,
                                                        v_contexts.context_code(i)),
                                                        v_segments, TRUE);

                        <<segmentLoop>>
                        FOR j IN 1..v_segments.nsegments LOOP
                                IF v_segments.is_enabled(j) THEN
                                        v_colName := v_segments.application_column_name(j);
                                        <<columnLoop>>
                                        FOR k IN 1..g_serial_attributes_tbl.count() LOOP
                                                IF UPPER(v_colName) = UPPER(g_serial_attributes_tbl(k).column_name) THEN

                                       -- Sets the Values for Validation

                                       -- Setting the column data type for validation
                                   if g_serial_attributes_tbl(k).column_type = 'DATE' then
                                            IF (l_debug = 1) THEN
                                               print_debug('Setting the  columns for validation -- Date' , 4);
                                            END IF;
                                        fnd_flex_descval.set_column_value(g_serial_attributes_tbl(k).column_name,
                                        fnd_date.canonical_to_date(g_serial_attributes_tbl(k).column_value));
                                  end if;

                                      if g_serial_attributes_tbl(k).column_type = 'NUMBER' then
                                               IF (l_debug = 1) THEN
                                                  print_debug('Setting the  columns for validation -- Number' , 4);
                                               END IF;
                                             fnd_flex_descval.set_column_value(g_serial_attributes_tbl(k).column_name,
                                               to_number(g_serial_attributes_tbl(k).column_value));
                                      end if;

                                      if g_serial_attributes_tbl(k).column_type = 'VARCHAR2' then
                                               IF (l_debug = 1) THEN
                                                  print_debug('Setting the  columns for validation -- Varchar2' , 4);
                                               END IF;
                                             fnd_flex_descval.set_column_value(g_serial_attributes_tbl(k).column_name,
                                               g_serial_attributes_tbl(k).column_value);
                                      end if;

                    IF (l_debug = 1) THEN
                       print_debug('Setting the  columns for validation ' , 4);
                       print_debug('column Name '|| g_serial_attributes_tbl(k).column_name , 4);
                       print_debug('column Value '||g_serial_attributes_tbl(k).column_value , 4);
                    END IF;

                    --print_debug('Calling the Validation API ' , 4);

                                        EXIT columnLoop; -- found column
                                                END IF;
                                        END LOOP columnLoop;

                                END IF;
                        END LOOP segmentLoop;
                END IF;
        END LOOP contextLoop;


-- Call the  validating routine for Lot Attributes.

l_progress := '110';
IF (l_debug = 1) THEN
   print_debug('Before Calling The API for validation ' , 4);
END IF;

l_status := fnd_flex_descval.validate_desccols(
           appl_short_name => 'INV',
           desc_flex_name => l_attributes_name);

if l_status = TRUE then
     IF (l_debug = 1) THEN
        print_debug('API for validation is successfull' , 4);
     END IF;
     null;
else
     IF (l_debug = 1) THEN
        print_debug('API for validation is failure' , 4);
        print_debug('Error Messages '|| fnd_flex_descval.error_message , 4);
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     x_msg_data := fnd_flex_descval.error_message;
     raise FND_API.G_EXC_ERROR;
end if;

end if;


--
--
     l_progress := '120';
     IF (l_debug = 1) THEN
        print_debug('Before Inserting into MTL_SERIAL_NUMBER' , 4);
     END IF;


           INSERT INTO MTL_SERIAL_NUMBERS(
                        INVENTORY_ITEM_ID,
                        SERIAL_NUMBER,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        REQUEST_ID,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        INITIALIZATION_DATE,
                        COMPLETION_DATE,
                        SHIP_DATE,
                        CURRENT_STATUS,
                        REVISION,
                        LOT_NUMBER,
                        FIXED_ASSET_TAG,
                        RESERVED_ORDER_ID,
                        PARENT_ITEM_ID,
                        PARENT_SERIAL_NUMBER,
                        ORIGINAL_WIP_ENTITY_ID,
                        ORIGINAL_UNIT_VENDOR_ID,
                        VENDOR_SERIAL_NUMBER,
                        VENDOR_LOT_NUMBER,
                        LAST_TXN_SOURCE_TYPE_ID,
                        LAST_TRANSACTION_ID,
                        LAST_RECEIPT_ISSUE_TYPE,
                        LAST_TXN_SOURCE_NAME,
                        LAST_TXN_SOURCE_ID,
                        DESCRIPTIVE_TEXT,
                        CURRENT_SUBINVENTORY_CODE,
                        CURRENT_LOCATOR_ID,
                        CURRENT_ORGANIZATION_ID,
                        ATTRIBUTE_CATEGORY,
                        ATTRIBUTE1,
                        ATTRIBUTE2,
                        ATTRIBUTE3,
                        ATTRIBUTE4,
                        ATTRIBUTE5,
                        ATTRIBUTE6,
                        ATTRIBUTE7,
                        ATTRIBUTE8,
                        ATTRIBUTE9,
                        ATTRIBUTE10,
                        ATTRIBUTE11,
                        ATTRIBUTE12,
                        ATTRIBUTE13,
                        ATTRIBUTE14,
                        ATTRIBUTE15,
                        GROUP_MARK_ID,
                        LINE_MARK_ID,
                        LOT_LINE_MARK_ID,
                        END_ITEM_UNIT_NUMBER,
                        GEN_OBJECT_ID,
                        SERIAL_ATTRIBUTE_CATEGORY,
                        ORIGINATION_DATE,
                        C_ATTRIBUTE1,
                        C_ATTRIBUTE2,
                        C_ATTRIBUTE3,
                        C_ATTRIBUTE4,
                        C_ATTRIBUTE5,
                        C_ATTRIBUTE6,
                        C_ATTRIBUTE7,
                        C_ATTRIBUTE8,
                        C_ATTRIBUTE9,
                        C_ATTRIBUTE10,
                        C_ATTRIBUTE11,
                        C_ATTRIBUTE12,
                        C_ATTRIBUTE13,
                        C_ATTRIBUTE14,
                        C_ATTRIBUTE15,
                        C_ATTRIBUTE16,
                        C_ATTRIBUTE17,
                        C_ATTRIBUTE18,
                        C_ATTRIBUTE19,
                        C_ATTRIBUTE20,
                        D_ATTRIBUTE1,
                        D_ATTRIBUTE2,
                        D_ATTRIBUTE3,
                        D_ATTRIBUTE4,
                        D_ATTRIBUTE5,
                        D_ATTRIBUTE6,
                        D_ATTRIBUTE7,
                        D_ATTRIBUTE8,
                        D_ATTRIBUTE9,
                        D_ATTRIBUTE10,
                        N_ATTRIBUTE1,
                        N_ATTRIBUTE2,
                        N_ATTRIBUTE3,
                        N_ATTRIBUTE4,
                        N_ATTRIBUTE5,
                        N_ATTRIBUTE6,
                        N_ATTRIBUTE7,
                        N_ATTRIBUTE8,
                        N_ATTRIBUTE9,
                        N_ATTRIBUTE10,
                        STATUS_ID,
                        TERRITORY_CODE,
                        COST_GROUP_ID,
                        TIME_SINCE_NEW,
                        CYCLES_SINCE_NEW,
                        TIME_SINCE_OVERHAUL,
                        CYCLES_SINCE_OVERHAUL,
                        TIME_SINCE_REPAIR,
                        CYCLES_SINCE_REPAIR,
                        TIME_SINCE_VISIT,
                        CYCLES_SINCE_VISIT,
                        TIME_SINCE_MARK,
                        CYCLES_SINCE_MARK,
                        NUMBER_OF_REPAIRS
                        )
           VALUES
                (p_inventory_item_id,
		 p_serial_number,
		 SYSDATE,
		 l_userid,
		 SYSDATE,
		 l_userid,
		 l_loginid,
		 null,
		 null,
		 null,
		 null,
		 p_initialization_date,
		 p_completion_date,
		 p_ship_date,
		 p_current_status,
		 p_revision,
		 p_lot_number,
		 null,
		 null,
		 p_parent_item_id,
		 p_parent_serial_number,
		 p_trx_src_id,
		 p_unit_vendor_id,
		 p_vendor_serial_number,
		 p_vendor_lot_number,
		 p_txn_src_type_id,
		 p_transaction_id,
		 p_receipt_issue_type,
		 p_txn_src_name,
		 p_txn_src_id,
		 g_serial_attributes_tbl(31).COLUMN_VALUE,
		 p_subinventory_code,
		 p_current_locator_id,
		 p_organization_id,
                 l_ATTRIBUTE_CATEGORY ,
                 l_ATTRIBUTE1   ,
                 l_ATTRIBUTE2   ,
                 l_ATTRIBUTE3   ,
                 l_ATTRIBUTE4  ,
                 l_ATTRIBUTE5   ,
                 l_ATTRIBUTE6  ,
                 l_ATTRIBUTE7   ,
                 l_ATTRIBUTE8,
                 l_ATTRIBUTE9  ,
                 l_ATTRIBUTE10  ,
                 l_ATTRIBUTE11,
                 l_ATTRIBUTE12 ,
                 l_ATTRIBUTE13  ,
                 l_ATTRIBUTE14 ,
                 l_ATTRIBUTE15  ,
		 null,
		 null,
		 null,
		 null,
		 x_object_id,
		 g_serial_attributes_tbl(1).COLUMN_VALUE,
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(2).COLUMN_VALUE),
		 g_serial_attributes_tbl(3).COLUMN_VALUE,
		 g_serial_attributes_tbl(4).COLUMN_VALUE,
		 g_serial_attributes_tbl(5).COLUMN_VALUE,
		 g_serial_attributes_tbl(6).COLUMN_VALUE,
		 g_serial_attributes_tbl(7).COLUMN_VALUE,
		 g_serial_attributes_tbl(8).COLUMN_VALUE,
		 g_serial_attributes_tbl(9).COLUMN_VALUE,
		 g_serial_attributes_tbl(10).COLUMN_VALUE,
		 g_serial_attributes_tbl(11).COLUMN_VALUE,
		 g_serial_attributes_tbl(12).COLUMN_VALUE,
		 g_serial_attributes_tbl(13).COLUMN_VALUE,
		 g_serial_attributes_tbl(14).COLUMN_VALUE,
		 g_serial_attributes_tbl(15).COLUMN_VALUE,
		 g_serial_attributes_tbl(16).COLUMN_VALUE,
		 g_serial_attributes_tbl(17).COLUMN_VALUE,
		 g_serial_attributes_tbl(18).COLUMN_VALUE,
		 g_serial_attributes_tbl(19).COLUMN_VALUE,
		 g_serial_attributes_tbl(20).COLUMN_VALUE,
		 g_serial_attributes_tbl(21).COLUMN_VALUE,
		 g_serial_attributes_tbl(22).COLUMN_VALUE,
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(23).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(24).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(25).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(26).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(27).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(28).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(29).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(30).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(31).COLUMN_VALUE),
		 fnd_date.canonical_to_date(g_serial_attributes_tbl(32).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(33).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(34).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(35).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(36).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(37).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(38).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(39).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(40).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(41).COLUMN_VALUE),
		 to_number(g_serial_attributes_tbl(42).COLUMN_VALUE),
		 l_status_id,
		 g_serial_attributes_tbl(44).COLUMN_VALUE,
		 INV_COST_GROUP_PUB.G_COST_GROUP_ID,
                 to_number(g_serial_attributes_tbl(45).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(46).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(47).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(48).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(49).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(50).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(51).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(52).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(53).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(54).COLUMN_VALUE),
                 to_number(g_serial_attributes_tbl(55).COLUMN_VALUE) );

     l_progress := '120';

         if( l_status_id is not null ) then
                l_status_rec.update_method := INV_MATERIAL_STATUS_PUB.g_update_method_auto;
                l_status_rec.organization_id := p_organization_id;
                l_status_rec.inventory_item_id := p_inventory_item_id;
                l_status_rec.serial_number := p_serial_number;
                l_status_rec.status_id := l_status_id;
                l_status_rec.INITIAL_STATUS_FLAG := 'Y';
                INV_MATERIAL_STATUS_PKG.Insert_status_history(l_status_rec);
         end if;


     l_progress := '130';

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
            (   p_encoded           =>      FND_API.G_FALSE,
                p_count             =>      x_msg_count         ,
                p_data              =>      x_msg_data
            );


EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO insertSerial_sv;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF SQLCODE IS NOT NULL THEN
	 IF (l_debug = 1) THEN
   	 print_debug('SQL Error : '||SQLERRM(SQLCODE)||' SQL Error code : '||SQLCODE, 1);
	 END IF;
      END IF;

      FND_MSG_PUB.Count_And_Get
        ( p_encoded           =>      FND_API.G_FALSE,
          p_count             =>      x_msg_count         ,
          p_data              =>      x_msg_data
        );

END insertSerial;



PROCEDURE insert_range_serial
  (p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
   p_inventory_item_id  IN NUMBER,
   p_organization_id    IN NUMBER,
   p_from_serial_number IN VARCHAR2,
   p_to_serial_number   IN VARCHAR2,
   p_initialization_date IN DATE,
   p_completion_date    IN DATE,
   p_ship_date          IN DATE,
   p_revision           IN VARCHAR2,
   p_lot_number         IN VARCHAR2,
   p_current_locator_id IN NUMBER,
   p_subinventory_code  IN VARCHAR2,
   p_trx_src_id         IN NUMBER,
   p_unit_vendor_id     IN NUMBER,
   p_vendor_lot_number  IN VARCHAR2,
   p_vendor_serial_number IN VARCHAR2,
   p_receipt_issue_type IN NUMBER,
   p_txn_src_id         IN NUMBER,
   p_txn_src_name       IN VARCHAR2,
   p_txn_src_type_id    IN NUMBER,
   p_transaction_id         IN NUMBER,
   p_current_status     IN NUMBER,
   p_parent_item_id     IN NUMBER,
   p_parent_serial_number IN VARCHAR2,
   p_cost_group_id      IN NUMBER,
   p_serial_transaction_intf_id IN NUMBER,
   p_status_id         IN NUMBER,
   p_inspection_status IN NUMBER,
   x_object_id          OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2)
  IS
   l_from_ser_number NUMBER;
   l_to_ser_number NUMBER;
   l_range_numbers NUMBER;
   l_temp_prefix VARCHAR2(30);
   l_cur_serial_number VARCHAR2(30);
   l_cur_ser_number NUMBER;
   l_object_id NUMBER;
   l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count NUMBER;
   l_msg_data VARCHAR2(2000);
   l_current_status NUMBER;
   l_group_mark_id NUMBER;

   l_progress      varchar2(100);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_serial_profile NUMBER := NVL(FND_PROFILE.VALUE('INV_RESTRICT_RCPT_SER'),2); --Bug#4122161
BEGIN

   IF (l_debug = 1) THEN
      print_debug('Inside Range Serial  ',4);
   END IF;

   l_progress := '10';
   IF (l_debug = 1) THEN
      print_debug('At Step = '|| l_progress,4);
   END IF;

   SAVEPOINT   SP_insert_range_serial;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- get the number part of the from serial
   inv_validate.number_from_sequence(p_from_serial_number,
                                     l_temp_prefix,
                                     l_from_ser_number);

   l_progress := '20';
   IF (l_debug = 1) THEN
      print_debug('At Step = '|| l_progress,4);
   END IF;

   -- get the number part of the to serial
   inv_validate.number_from_sequence(p_to_serial_number,
                                     l_temp_prefix,
                                     l_to_ser_number);

   l_progress := '30';
   IF (l_debug = 1) THEN
      print_debug('At Step = '|| l_progress,4);
   END IF;

   -- total number of serials inserted into mtl_serial_numbers
   l_range_numbers := l_to_ser_number - l_from_ser_number + 1;

   l_progress := '40';
   IF (l_debug = 1) THEN
      print_debug('At Step = '|| l_progress,4);
   END IF;

   FOR i IN 1..l_range_numbers LOOP
      l_cur_ser_number := l_from_ser_number + i -1;

      -- concatenate the serial number to be inserted
      --Bug 4539454: If serial number ends in a letter, l_from_ser_number=l_to_ser_number=-1
        --So, assign it directly to l_cur_serial_number
        --Handles a single serial number ending in a letter  OR
	--range of serial numbers, each ending in a digit.
      IF ( (l_from_ser_number=-1) and (l_to_ser_number=-1) ) THEN
         l_cur_serial_number  := p_from_serial_number;
      ELSE
         l_cur_serial_number := Substr(p_from_serial_number, 1,
	                               Length(p_from_serial_number) - Length(l_cur_ser_number))
				|| l_cur_ser_number;
      END IF;

      -- check the status code and group_mark_id
      BEGIN
         SELECT current_status, group_mark_id
           INTO l_current_status, l_group_mark_id
           FROM mtl_serial_numbers
           WHERE serial_number = l_cur_serial_number
           AND inventory_item_id = p_inventory_item_id;

      EXCEPTION
         WHEN no_data_found THEN
            l_current_status := -1;
            l_group_mark_id := -1;
         WHEN OTHERS THEN
            NULL;
      END;

   l_progress := '50';
   IF (l_debug = 1) THEN
      print_debug('At Step = '|| l_progress,4);
      print_debug('serial profile : '||l_serial_profile || ',current_status :'||l_current_status,4);
   END IF;

      IF ( (l_current_status <> 5) OR (l_current_status = 5 AND l_group_mark_id > 0) )
          AND NOT (l_current_status = 4 AND l_serial_profile = 2 ) --Added bug#4122161.
      THEN

        IF inv_serial_number_pub.is_serial_unique
           -- Need to do uniqueness check here
           -- If any serial is in use, then
           -- discard the entire range insertion.
           (p_org_id => p_organization_id,
            p_item_id => p_inventory_item_id,
            p_serial => l_cur_serial_number,
            x_proc_msg => l_msg_data) = 1 THEN
            FND_MESSAGE.SET_NAME('INV', 'INV_SERIAL_USED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            -- uniqueness check passed
            -- and it is not a pre-defined serial

     IF (l_debug = 1) THEN
        print_debug('Calling Insert Serial for = '|| l_cur_serial_number ,4);
     END IF;

            insertserial
              (p_commit => p_commit,
               p_inventory_item_id => p_inventory_item_id,
               p_organization_id => p_organization_id,
               p_serial_number => l_cur_serial_number,
               p_initialization_date => p_initialization_date,
               p_completion_date => p_completion_date,
               p_ship_date => p_ship_date,
               p_revision => p_revision,
               p_lot_number => p_lot_number,
               p_current_locator_id => p_current_locator_id,
               p_subinventory_code => p_subinventory_code,
               p_trx_src_id => p_trx_src_id,
               p_unit_vendor_id => p_unit_vendor_id,
               p_vendor_lot_number => p_vendor_lot_number,
               p_vendor_serial_number => p_vendor_serial_number,
               p_receipt_issue_type => p_receipt_issue_type,
               p_txn_src_id => p_txn_src_id,
               p_txn_src_name => p_txn_src_name,
               p_txn_src_type_id => p_txn_src_type_id,
               p_transaction_id => p_transaction_id,
               p_current_status => p_current_status,
               p_parent_item_id => p_parent_item_id,
               p_parent_serial_number => p_parent_serial_number,
               p_cost_group_id => p_cost_group_id,
               p_serial_transaction_intf_id => p_serial_transaction_intf_id,
               p_status_id => p_status_id,
               x_object_id => l_object_id,
               x_return_status => l_return_status,
               x_msg_count => l_msg_count,
               x_msg_data => l_msg_data);

            IF( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               FND_MESSAGE.SET_NAME('INV', 'INV_SERIAL');
               FND_MSG_PUB.ADD;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END IF;
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- End of API body
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (  p_count         =>      x_msg_count,
        p_data          =>      x_msg_data
        );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SP_insert_range_serial;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        (p_count        =>      x_msg_count,
         p_data         =>      x_msg_data
         );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO SP_insert_range_serial;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.Count_And_Get
        (p_count        =>      x_msg_count,
         p_data         =>      x_msg_data
         );

   WHEN OTHERS THEN
      ROLLBACK TO SP_insert_range_serial;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.Count_And_Get
        (p_count        =>      x_msg_count,
         p_data         =>      x_msg_data
         );

END insert_range_serial;




END WMS_ASN_LOT_ATT;

/
