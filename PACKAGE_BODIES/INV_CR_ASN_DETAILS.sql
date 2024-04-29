--------------------------------------------------------
--  DDL for Package Body INV_CR_ASN_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CR_ASN_DETAILS" AS
/* $Header: INVCRDIB.pls 120.3 2005/10/10 12:55:32 methomas noship $*/

--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_CR_ASN_DETAILS';

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (l_debug = 1) THEN
      inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'INV_CR_ASN_DETAILS',
      p_level => p_level);
   END IF;

--   dbms_output.put_line(p_err_msg);
END print_debug;

PROCEDURE insertrows(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )
IS
 l_userid         NUMBER;
 l_loginid        NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
l_userid := fnd_global.user_id;
l_loginid := fnd_global.login_id;

insert into WMS_ASN_DETAILS (
                GROUP_ID            ,
		SHIPMENT_NUM        ,
		ORGANIZATION_ID     ,
                DISCREPANCY_REPORTING_CONTEXT ,
		ITEM_ID                       ,
		QUANTITY_EXPECTED             ,
		QUANTITY_ACTUAL               ,
		UNIT_OF_MEASURE_EXPECTED      ,
		UNIT_OF_MEASURE_ACTUAL        ,
		LPN_EXPECTED                  ,
		LPN_ACTUAL                    ,
		ITEM_REVISION_EXPECTED        ,
		ITEM_REVISION_ACTUAL          ,
		LOT_NUMBER_EXPECTED           ,
		LOT_NUMBER_ACTUAL             ,
		SERIAL_NUMBER_EXPECTED        ,
		SERIAL_NUMBER_ACTUAL          ,
                VENDOR_ID                     ,
                VENDOR_SITE_ID                ,
                TRANSACTION_DATE              ,
                LAST_UPDATE_DATE              ,
                LAST_UPDATED_BY               ,
                CREATION_DATE                 ,
                CREATED_BY                    ,
                LAST_UPDATE_LOGIN
) values
(
                p_create_asn_details_rec.GROUP_ID            ,
		p_create_asn_details_rec.SHIPMENT_NUM        ,
		p_create_asn_details_rec.ORGANIZATION_ID     ,
                p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT ,
		p_create_asn_details_rec.ITEM_ID                       ,
		p_create_asn_details_rec.QUANTITY_EXPECTED             ,
		p_create_asn_details_rec.QUANTITY_ACTUAL               ,
		p_create_asn_details_rec.UNIT_OF_MEASURE_EXPECTED      ,
		p_create_asn_details_rec.UNIT_OF_MEASURE_ACTUAL        ,
		p_create_asn_details_rec.LPN_EXPECTED                  ,
		p_create_asn_details_rec.LPN_ACTUAL                    ,
		p_create_asn_details_rec.ITEM_REVISION_EXPECTED        ,
		p_create_asn_details_rec.ITEM_REVISION_ACTUAL          ,
		p_create_asn_details_rec.LOT_NUMBER_EXPECTED           ,
		p_create_asn_details_rec.LOT_NUMBER_ACTUAL             ,
		p_create_asn_details_rec.SERIAL_NUMBER_EXPECTED        ,
		p_create_asn_details_rec.SERIAL_NUMBER_ACTUAL          ,
		p_create_asn_details_rec.VENDOR_ID                     ,
		p_create_asn_details_rec.VENDOR_SITE_ID                ,
		p_create_asn_details_rec.TRANSACTION_DATE              ,
                sysdate,
                l_userid,
                sysdate,
                l_userid,
                l_loginid
);

END insertrows;

PROCEDURE insert_asn_item_details(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp
  		      )
IS

l_exists varchar2(10);
l_userid         NUMBER;
l_loginid        NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

l_userid := fnd_global.user_id;
l_loginid := fnd_global.login_id;

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
;

update WMS_ASN_DETAILS set quantity_actual = (nvl(quantity_actual,0) + p_create_asn_details_rec.QUANTITY_ACTUAL) ,
                       unit_of_measure_actual = p_create_asn_details_rec.unit_of_measure_actual,
                       item_revision_actual = p_create_asn_details_rec.item_revision_actual,
                       transaction_date = sysdate,
                       last_update_date = sysdate,
                       last_updated_by  = l_userid,
                       last_update_login = l_loginid
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
;

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END insert_asn_item_details;

PROCEDURE insert_asn_item_details_intf(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp
                      )
IS

l_exists varchar2(10);
l_userid         NUMBER;
l_loginid        NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

l_userid := fnd_global.user_id;
l_loginid := fnd_global.login_id;

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
;

update WMS_ASN_DETAILS set quantity_expected = ( quantity_expected + p_create_asn_details_rec.QUANTITY_EXPECTED) ,
                        transaction_date = sysdate,
                        last_update_date = sysdate,
                        last_updated_by  = l_userid,
                        last_update_login = l_loginid
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
;

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END insert_asn_item_details_intf;


PROCEDURE initialize_details(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
                -- p_create_asn_details_rec.GROUP_ID := to_number(null);
		-- p_create_asn_details_rec.SHIPMENT_NUM := null;
		-- p_create_asn_details_rec.ORGANIZATION_ID := to_number(null);
		-- p_create_asn_details_rec.ITEM_ID := to_number(null);

                p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := null;
		p_create_asn_details_rec.QUANTITY_EXPECTED := to_number(null);
		p_create_asn_details_rec.QUANTITY_ACTUAL:= to_number(null);
		p_create_asn_details_rec.UNIT_OF_MEASURE_EXPECTED := null;
		p_create_asn_details_rec.UNIT_OF_MEASURE_ACTUAL  := null;
		p_create_asn_details_rec.LPN_EXPECTED           := null;
		p_create_asn_details_rec.LPN_ACTUAL             := null;
		p_create_asn_details_rec.ITEM_REVISION_EXPECTED := null;
		p_create_asn_details_rec.ITEM_REVISION_ACTUAL  := null;
		p_create_asn_details_rec.LOT_NUMBER_EXPECTED  := null;
		p_create_asn_details_rec.LOT_NUMBER_ACTUAL   := null;
		p_create_asn_details_rec.SERIAL_NUMBER_EXPECTED    := null;
		p_create_asn_details_rec.SERIAL_NUMBER_ACTUAL          := null;
		p_create_asn_details_rec.VENDOR_ID          := to_number(null);
		p_create_asn_details_rec.VENDOR_SITE_ID     := to_number(null);
		p_create_asn_details_rec.TRANSACTION_DATE   := to_date(null);
End;



PROCEDURE insert_asn_lot_details(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )
IS

l_exists varchar2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and lpn_expected = p_create_asn_details_rec.lpn_expected
 and lot_number_expected =  p_create_asn_details_rec.lot_number_expected
 and rownum < 2
;

-- Lot  is already there nothing to insert

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END insert_asn_lot_details;



PROCEDURE insert_asn_lpn_details(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )

IS

l_exists varchar2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and lpn_expected = p_create_asn_details_rec.lpn_expected
 and rownum < 2
;

-- LPN is already there nothing to insert

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END insert_asn_lpn_details;


PROCEDURE update_asn_lpn_details(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )

IS

l_exists varchar2(10);
l_userid         NUMBER;
l_loginid        NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and ( lpn_expected = p_create_asn_details_rec.lpn_actual
      or lpn_actual = p_create_asn_details_rec.lpn_actual )
 and rownum < 2
;

-- LPN is already there update the quantity
update WMS_ASN_DETAILS set
  quantity_actual = nvl(quantity_actual, 0) + p_create_asn_details_rec.QUANTITY_ACTUAL,
  lpn_actual      = p_create_asn_details_rec.LPN_ACTUAL ,
  last_update_date = sysdate,
  last_updated_by  = l_userid,
  last_update_login = l_loginid
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and ( lpn_expected = p_create_asn_details_rec.lpn_actual
      or lpn_actual = p_create_asn_details_rec.lpn_actual )
;

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END update_asn_lpn_details;


PROCEDURE update_asn_lot_details(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )
IS

l_exists varchar2(10);
l_userid         NUMBER;
l_loginid        NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

-- LOT is already there update the quantity
-- Bug 2096130
-- If Same Lot is received for same LPN we need to update the
-- quantity of Lot  added to the prev quantity.

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and ( (lot_number_expected = p_create_asn_details_rec.lot_number_actual and lpn_expected = p_create_asn_details_rec.lpn_actual)
       or
       (lot_number_actual = p_create_asn_details_rec.lot_number_actual and lpn_actual = p_create_asn_details_rec.lpn_actual)
     )
 and rownum < 2
;

update WMS_ASN_DETAILS set
  quantity_actual = nvl(quantity_actual,0) + p_create_asn_details_rec.QUANTITY_ACTUAL ,
  lot_number_actual = p_create_asn_details_rec.LOT_NUMBER_ACTUAL,
  lpn_actual        = p_create_asn_details_rec.LPN_ACTUAL,
  last_update_date = sysdate,
  last_updated_by  = l_userid,
  last_update_login = l_loginid
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and ( (lot_number_expected = p_create_asn_details_rec.lot_number_actual and lpn_expected = p_create_asn_details_rec.lpn_actual)
       or
       (lot_number_actual = p_create_asn_details_rec.lot_number_actual and lpn_actual = p_create_asn_details_rec.lpn_actual)
     )
;

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END update_asn_lot_details;


PROCEDURE insert_asn_ser_details_exp(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )
IS
l_exists varchar2(10);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and lpn_expected = p_create_asn_details_rec.lpn_expected
 and serial_number_expected =  p_create_asn_details_rec.serial_number_expected
 and rownum < 2
;

-- Serial  is already there nothing to insert

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END insert_asn_ser_details_exp;



PROCEDURE insert_asn_ser_details_act(p_create_asn_details_rec IN OUT nocopy asn_details_rec_tp )
IS
l_exists varchar2(10);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

Begin
select 1 into l_exists
  from WMS_ASN_DETAILS
 where shipment_num = p_create_asn_details_rec.SHIPMENT_NUM
 and organization_id = p_create_asn_details_rec.ORGANIZATION_ID
 and discrepancy_reporting_context = p_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT
 and ITEM_ID = p_create_asn_details_rec.ITEM_ID
 and lpn_actual = p_create_asn_details_rec.lpn_actual
 and serial_number_actual =  p_create_asn_details_rec.serial_number_actual
 and rownum < 2
;

-- Serial  is already there nothing to insert

Exception
When No_data_found then
insertrows(p_create_asn_details_rec);
End;
END insert_asn_ser_details_act;


Function  Check_discrepancy
   ( p_shipment_num      IN varchar2,
     p_organization_id   IN number
   )
return boolean
IS
l_exists number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     For c_item_details in ( select * from WMS_ASN_DETAILS
                              where shipment_num = p_shipment_num
                                and organization_id = p_organization_id
                              order by discrepancy_reporting_context
                           )
     Loop

          -- Check Item
          if c_item_details.discrepancy_reporting_context = 'I'
          then
             if (
                    (c_item_details.QUANTITY_EXPECTED <> c_item_details.QUANTITY_ACTUAL)
                or
                    (c_item_details.UNIT_OF_MEASURE_EXPECTED <> c_item_details.UNIT_OF_MEASURE_ACTUAL)
                or
                    (c_item_details.ITEM_REVISION_EXPECTED <> c_item_details.ITEM_REVISION_ACTUAL)
                )
             then
               return FALSE;
             end if;
          end if;

          -- Check LPN
          if c_item_details.discrepancy_reporting_context = 'L'
          then
             if (
                    (c_item_details.LPN_EXPECTED <> c_item_details.LPN_ACTUAL)
                or
                    (c_item_details.QUANTITY_EXPECTED <> c_item_details.QUANTITY_ACTUAL)
                )
             then
               return FALSE;
             end if;
          end if;

          -- Check LOT
          if c_item_details.discrepancy_reporting_context = 'O'
          then
             if (
                    (c_item_details.LPN_EXPECTED <> c_item_details.LPN_ACTUAL)
                or
                    (c_item_details.LOT_NUMBER_EXPECTED <> c_item_details.LOT_NUMBER_ACTUAL)
                or
                    (c_item_details.QUANTITY_EXPECTED <> c_item_details.QUANTITY_ACTUAL)

                )
             then
               return FALSE;
             end if;
          end if;

          -- Check Serial
          if c_item_details.discrepancy_reporting_context = 'S'
          then
              if c_item_details.serial_number_expected is not null
              then
              Begin
                   select 1
                     into l_exists
                     from WMS_ASN_DETAILS
                    where shipment_num=p_shipment_num
                      and organization_id = p_organization_id
                      and serial_number_actual = c_item_details.serial_number_expected
                      and lpn_actual           = c_item_details.lpn_expected
                    ;
              Exception
                   when others then return FALSE;
              End;
              end if;

              if c_item_details.serial_number_actual is not null
              then
              Begin
                   select 1
                     into l_exists
                     from WMS_ASN_DETAILS
                    where shipment_num=p_shipment_num
                      and organization_id = p_organization_id
                      and serial_number_expected = c_item_details.serial_number_actual
                      and lpn_expected           = c_item_details.lpn_actual
                    ;
              Exception
                   when others then return FALSE;
              End;
              end if;


          end if;

     End Loop;

return TRUE;
End Check_discrepancy;



Procedure  CREATE_ASN_DETAILS
   (p_organization_id    IN number,
    p_group_id           IN NUMBER,
    p_rcv_rcpt_rec        IN OUT nocopy  inv_rcv_std_rcpt_apis.rcv_enter_receipts_rec_tp,
    p_rcv_transaction_rec IN OUT nocopy  inv_rcv_std_rcpt_apis.rcv_transaction_rec_tp,
    p_rcpt_lot_qty_rec_tb IN OUT nocopy  inv_rcv_std_rcpt_apis.rcpt_lot_qty_rec_tb_tp,
    p_interface_transaction_id IN number,
    x_status             OUT nocopy varchar2,
    x_message            OUT nocopy varchar2)
   IS

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);
     l_create_asn_details_rec asn_details_rec_tp ;
     l_shipped_quantity  number;
     l_received_quantity  number;
     l_lpn_quantity_expected      number;
     l_license_plate_number       varchar2(30);
     l_lpn_quantity_actual      number;
     l_license_plate_actual     varchar2(30);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number_expected      varchar2(80);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number_actual        varchar2(80);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     p_lot_number               varchar2(80);
     p_num_lots                 number;
     p_lot_quantity             number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

   SAVEPOINT crt_asn_details;
   x_status := FND_API.G_RET_STS_SUCCESS;


l_progress := '10';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

   IF (l_debug = 1) THEN
      print_debug('ASN Details ', 1);
      print_debug('Group Id =  '|| p_group_id, 1);
      print_debug('Organization Id =  '|| p_organization_id, 1);
      print_debug('Shipment Number =  '|| p_rcv_rcpt_rec.rcv_shipment_number, 1);
      print_debug('Item Id =  '|| p_rcv_rcpt_rec.item_id, 1);
      print_debug('UOM  =  '|| p_rcv_rcpt_rec.primary_uom, 1);
      print_debug('Revision  =  '|| p_rcv_rcpt_rec.item_revision, 1);
   END IF;

   select quantity_received,
          quantity_shipped
     into l_received_quantity ,
          l_shipped_quantity
     FROM RCV_SHIPMENT_LINES RSL
    WHERE RSL.SHIPMENT_LINE_ID = p_rcv_rcpt_rec.rcv_shipment_line_id
   ;

IF (l_debug = 1) THEN
   print_debug('Shipped Quantity =  '|| l_shipped_quantity, 1);
   print_debug('Receivd Quantity =  '|| l_received_quantity, 1);
END IF;


-- Creating Expected ASN Item Details For Reporting
-- Should be called for each item

l_create_asn_details_rec.group_id        := p_group_id;
l_create_asn_details_rec.organization_id := p_organization_id;
l_create_asn_details_rec.shipment_num    := p_rcv_rcpt_rec.rcv_shipment_number;
l_create_asn_details_rec.ITEM_ID                       :=  p_rcv_rcpt_rec.item_id ;
l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'I' ;
l_create_asn_details_rec.QUANTITY_EXPECTED             :=  l_shipped_quantity ;
l_create_asn_details_rec.UNIT_OF_MEASURE_EXPECTED      :=  p_rcv_rcpt_rec.primary_uom;
l_create_asn_details_rec.ITEM_REVISION_EXPECTED        :=  p_rcv_rcpt_rec.item_revision ;

-- Creating Expected ASN Item Details For Reporting
--l_create_asn_details_rec.QUANTITY_ACTUAL :=  l_received_quantity +
--                                            p_rcv_transaction_rec.transaction_qty;

l_create_asn_details_rec.QUANTITY_ACTUAL := p_rcv_transaction_rec.transaction_qty;

IF (l_debug = 1) THEN
   print_debug('Actual Quantity =  '|| l_create_asn_details_rec.QUANTITY_ACTUAL, 1);
END IF;

l_create_asn_details_rec.UNIT_OF_MEASURE_ACTUAL :=  p_rcv_transaction_rec.transaction_uom;
l_create_asn_details_rec.ITEM_REVISION_ACTUAL   :=  p_rcv_transaction_rec.item_revision ;

-- DAte when the ASN is actually Transacted
l_create_asn_details_rec.TRANSACTION_DATE   :=  sysdate;


/* Bug 4551595- Commenting the call to this procedure. Calling it from the header level
                for all the records in rti for a group id. */

/*-- Call the API for creating rows.
insert_asn_item_details(l_create_asn_details_rec); */

/* End of fix for Bug 4551595 */

l_progress := '20';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

-- May be Needed to Call Only Once..
-- Creating The Expectd ASN LPN Details For Reporting
-- Need to make a cursor for the following for multiple LPNS..
-- and multiple lots
-- and call the insert in a loop

Begin
--Update The Actual LPN Quantity and populate the rows.

IF (l_debug = 1) THEN
   print_debug('LPN ID'||p_rcv_transaction_rec.lpn_id, 1);
END IF;

l_progress := '30';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

For c_lpn_actual
in (
select wlpn.license_plate_number,
       wlpn.lpn_id
  from wms_license_plate_numbers wlpn
 where wlpn.lpn_id = p_rcv_transaction_rec.lpn_id
)
Loop

initialize_details(l_create_asn_details_rec);
l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'L' ;
l_create_asn_details_rec.LPN_ACTUAL       := c_lpn_actual.license_plate_number;

-- Should Insert Transaction Quantity Here
l_create_asn_details_rec.QUANTITY_ACTUAL  := p_rcv_transaction_rec.transaction_qty ;

-- Need to do only once
 update_asn_lpn_details(l_create_asn_details_rec);

-- Insert The Lot Related Rows..
-- New code to get the LOT INFO
--
p_num_lots := p_rcpt_lot_qty_rec_tb.COUNT ;

-- if p_num_lots is 0 then just process serial
-- Otherwise process Lots and then serials
--


-- if No Lots so just process serial
if p_num_lots > 0 then
   FOR i IN 1..p_rcpt_lot_qty_rec_tb.COUNT  LOOP

   p_lot_quantity := 0;
   initialize_details(l_create_asn_details_rec);
   l_create_asn_details_rec.LPN_ACTUAL           := c_lpn_actual.license_plate_number;
   l_create_asn_details_rec.LOT_NUMBER_ACTUAL    := p_rcpt_lot_qty_rec_tb(i).lot_number;

   -- Should Insert Transaction Quantity Here
   IF (l_debug = 1) THEN
      print_debug('Lot Number =  '  || p_rcpt_lot_qty_rec_tb(i).lot_number, 1);
      print_debug('Lot Quantity =  '|| p_rcpt_lot_qty_rec_tb(i).txn_quantity, 1);
   END IF;

   -- For Standard Receipt take the transaction quantity from MO lines.
   Begin
       if nvl(p_rcpt_lot_qty_rec_tb(i).txn_quantity,0) = 0 then
       -- Case for Receipt Transaction Because Lot_REC has 0 quantity , SO NEED TO GET IT FROM mo ORDER LINES.

        IF (l_debug = 1) THEN
           print_debug('inv_cr_asn_details: organization_id '||l_create_asn_details_rec.organization_id , 1);
           print_debug('inv_cr_asn_details: inventory_item_id '|| l_create_asn_details_rec.ITEM_ID, 1);
           print_debug('inv_cr_asn_details: lot_number '|| l_create_asn_details_rec.LOT_NUMBER_ACTUAL, 1);
           print_debug('inv_cr_asn_details: reference_type_code '|| '8', 1);
           print_debug('inv_cr_asn_details: reference_id '|| 'SHIPMENT_LINE_ID' , 1);
           print_debug('inv_cr_asn_details: interface_transaction_id ' || p_interface_transaction_id, 1);
           print_debug('inv_cr_asn_details: lpn_id '|| c_lpn_actual.lpn_id , 1);
        END IF;

        IF (l_debug = 1) THEN
           print_debug('Inside MO Qty Fetch ', 1);
        END IF;

       select quantity
         into p_lot_quantity
         from mtl_txn_request_lines
        where organization_id = l_create_asn_details_rec.organization_id
          and inventory_item_id = l_create_asn_details_rec.ITEM_ID
          and lot_number = l_create_asn_details_rec.LOT_NUMBER_ACTUAL
          and reference = 'SHIPMENT_LINE_ID'
          and reference_type_code = 8
          and reference_id = p_rcv_rcpt_rec.rcv_shipment_line_id
          and txn_source_id = p_interface_transaction_id
          and lpn_id = c_lpn_actual.lpn_id
        ;
       End if;
   Exception when no_data_found then
          IF (l_debug = 1) THEN
             print_debug('Lot Number =  '  || p_rcpt_lot_qty_rec_tb(i).lot_number || ' for MO order Qty Fetch ', 1);
          END IF;
          p_lot_quantity := 0;
   End;

   if nvl(p_rcpt_lot_qty_rec_tb(i).txn_quantity,0) = 0 then
      l_create_asn_details_rec.QUANTITY_ACTUAL := p_lot_quantity;
   else
      l_create_asn_details_rec.QUANTITY_ACTUAL        := p_rcpt_lot_qty_rec_tb(i).txn_quantity ;
   end if;

   l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'O' ;

   -- If NO LOT SPECIFIED NOTHING TO INSERT/UPDATE

   if l_create_asn_details_rec.LOT_NUMBER_ACTUAL is not null
   then
      update_asn_lot_details(l_create_asn_details_rec);
   end if;

   l_progress := '40';
   IF (l_debug = 1) THEN
      print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;

   -- Insert The Related Serial Rows

   For c_Serial in
   (select msn.serial_number serial_number
      from mtl_serial_numbers msn
     where msn.inventory_item_id = p_rcv_rcpt_rec.item_id
       and ( l_create_asn_details_rec.lot_number_actual is not null
       and msn.lot_number = l_create_asn_details_rec.lot_number_actual)
       and msn.lpn_id = c_lpn_actual.lpn_id
   )
   loop

   initialize_details(l_create_asn_details_rec);
   l_create_asn_details_rec.LPN_ACTUAL         :=  c_lpn_actual.license_plate_number ;
   l_create_asn_details_rec.LOT_NUMBER_ACTUAL  :=  p_rcpt_lot_qty_rec_tb(i).lot_number ;
   l_create_asn_details_rec.serial_number_actual :=  c_Serial.serial_number;
   l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'S' ;
   insert_asn_ser_details_act(l_create_asn_details_rec);

   l_progress := '50';
   IF (l_debug = 1) THEN
      print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;

   End loop; -- Serial
   End Loop; -- Lot
-- Just Process Serial
else
-- Insert The Related Serial Rows
   For c_Serial in
   (select msn.serial_number serial_number
      from mtl_serial_numbers msn
     where msn.inventory_item_id = p_rcv_rcpt_rec.item_id
       and msn.lpn_id = c_lpn_actual.lpn_id
   )
   loop
   initialize_details(l_create_asn_details_rec);
   l_create_asn_details_rec.LPN_ACTUAL         :=  c_lpn_actual.license_plate_number ;
   l_create_asn_details_rec.LOT_NUMBER_ACTUAL  :=  null ;
   l_create_asn_details_rec.serial_number_actual :=  c_Serial.serial_number;
   l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'S' ;
   insert_asn_ser_details_act(l_create_asn_details_rec);

   l_progress := '50.1';
   IF (l_debug = 1) THEN
      print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;

   End loop; -- Serial
end if;
End loop; -- LPN

l_progress := '60';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

Exception
When No_data_found then
-- Case for NO ACTUAL LPN in ASN
IF (l_debug = 1) THEN
   print_debug('Asn has no actual LPN ', 1);
END IF;
null;
End;


/* 4551595-Commenting out the check for discrepancy from here */
-- Update the Status
/*
if (Check_discrepancy(l_create_asn_details_rec.shipment_num,
                       l_create_asn_details_rec.organization_id))
then
update WMS_ASN_DETAILS set discrepancy_status = 'S'
 where shipment_num = l_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = l_create_asn_details_rec.organization_id
   and discrepancy_reporting_context = 'I'
   and item_id = l_create_asn_details_rec.item_id
;
else
update WMS_ASN_DETAILS set discrepancy_status = 'F'
 where shipment_num = l_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = l_create_asn_details_rec.organization_id
   and discrepancy_reporting_context = 'I'
   and item_id = l_create_asn_details_rec.item_id
;
End if;
*/
/* End of fix for Bug 4551595 */

l_progress := '70';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details: '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;




EXCEPTION

    WHEN fnd_api.g_exc_error THEN
       ROLLBACK TO crt_asn_details;
       x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );
    WHEN fnd_api.g_exc_unexpected_error THEN
       ROLLBACK TO crt_asn_details;
       x_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          print_debug('Other Problem Occured progress = '||l_progress||'sqlcode ='||SQLCODE, 1);
       END IF;
       ROLLBACK TO crt_asn_details;
       x_status := fnd_api.g_ret_sts_unexp_error ;
       IF SQLCODE IS NOT NULL THEN
	  inv_mobile_helper_functions.sql_error('INV_CR_ASN_DETAILS.create_asn_details', l_progress, SQLCODE);
       END IF;

       fnd_msg_pub.count_and_get
	 (p_encoded   => FND_API.g_false,
	  p_count     => l_msg_count,
	  p_data      => x_message
	  );
END create_asn_details;


Procedure  CREATE_ASN_DETAILS_FROM_INTF
   ( p_interface_transaction_rec         IN OUT nocopy rcv_intf_rec_tp ,
    x_status             OUT nocopy varchar2,
    x_message            OUT nocopy varchar2)
   IS

     l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_msg_count NUMBER;
     l_msg_data VARCHAR2(4000);
     l_progress VARCHAR2(10);
     l_create_asn_details_rec asn_details_rec_tp ;
     l_shipped_quantity  number;
     l_received_quantity  number;
     l_lpn_quantity_expected      number;
     l_license_plate_number       varchar2(30);
     l_lpn_quantity_actual      number;
     l_license_plate_actual     varchar2(30);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number_expected      varchar2(80);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
     l_lot_number_actual        varchar2(80);
     l_shipment_num             varchar2(30);

     l_vendor_id                number;
     l_vendor_site_id           number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN

   SAVEPOINT crt_asn_details_interface;
   x_status := FND_API.G_RET_STS_SUCCESS;
   l_progress := '10';

   IF (l_debug = 1) THEN
      print_debug('Create ASN Details from interface : 10 '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   END IF;

Begin
   select shipment_num,
          vendor_id,
          vendor_site_id
     into l_shipment_num,
          l_vendor_id,
          l_vendor_site_id
     FROM RCV_SHIPMENT_HEADERS RSH
    WHERE RSH.shipment_header_id = p_interface_transaction_rec.shipment_header_id ;
Exception
when others then raise fnd_api.g_exc_error ;
End;

l_progress := '20';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

-- Creating Expected ASN Item Details For Reporting
-- Should be called for each item

l_create_asn_details_rec.organization_id               := p_interface_transaction_rec.to_organization_id;
l_create_asn_details_rec.shipment_num                  := l_shipment_num;
l_create_asn_details_rec.ITEM_ID                       :=  p_interface_transaction_rec.item_id ;
l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'I' ;
l_create_asn_details_rec.QUANTITY_EXPECTED             :=  p_interface_transaction_rec.quantity ;
l_create_asn_details_rec.UNIT_OF_MEASURE_EXPECTED      :=  p_interface_transaction_rec.unit_of_measure;
l_create_asn_details_rec.ITEM_REVISION_EXPECTED        :=  p_interface_transaction_rec.item_revision ;

l_create_asn_details_rec.VENDOR_ID        :=  l_vendor_id;
l_create_asn_details_rec.VENDOR_SITE_ID   :=  l_vendor_site_id;

-- Call the API for creating rows.
l_progress := '30';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

insert_asn_item_details_intf(l_create_asn_details_rec);


l_progress := '40';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

Begin

l_license_plate_number :='';
l_lpn_quantity_expected := 0;


l_progress := '50';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

For c_lpn in
(select wlpn.license_plate_number,
       wlpc.quantity,
       wlpc.lot_number,
       wlpn.lpn_id
  from wms_lpn_contents wlpc,
       wms_license_plate_numbers wlpn
 where wlpc.parent_lpn_id = wlpn.lpn_id
   and wlpn.source_header_id  = p_interface_transaction_rec.shipment_header_id
   and wlpc.inventory_item_id = p_interface_transaction_rec.item_id
   order by wlpn.license_plate_number, wlpc.lot_number
)
Loop

-- Find The Expected LPN Quantity and populate the rows.
initialize_details(l_create_asn_details_rec);
l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'L' ;
l_create_asn_details_rec.LPN_EXPECTED      :=  c_lpn.license_plate_number ;
l_create_asn_details_rec.QUANTITY_EXPECTED :=  c_lpn.quantity ;

insert_asn_lpn_details(l_create_asn_details_rec);

l_progress := '60';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

-- Insert The Lot Related Rows..
initialize_details(l_create_asn_details_rec);
l_create_asn_details_rec.LPN_EXPECTED         :=  c_lpn.license_plate_number ;
l_create_asn_details_rec.LOT_NUMBER_EXPECTED  :=  c_lpn.lot_number ;
l_create_asn_details_rec.QUANTITY_EXPECTED    :=  c_lpn.quantity ;
l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'O' ;

-- If LOT NUMBER IS NULL THEN NO NEED to insert LOT

if l_create_asn_details_rec.LOT_NUMBER_EXPECTED is not null
then
    insert_asn_lot_details(l_create_asn_details_rec);
end if;

l_progress := '70';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;


-- Insert The Related Serial Rows

For c_Serial in
(select serial_number,
        lot_number
   from mtl_serial_numbers
  where inventory_item_id = p_interface_transaction_rec.item_id
    and lpn_id = c_lpn.lpn_id
)
loop

initialize_details(l_create_asn_details_rec);
l_create_asn_details_rec.LPN_EXPECTED         :=  c_lpn.license_plate_number ;
l_create_asn_details_rec.LOT_NUMBER_EXPECTED  :=  c_Serial.lot_number ;
l_create_asn_details_rec.serial_number_expected :=  c_Serial.serial_number;
l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'S' ;
insert_asn_ser_details_exp(l_create_asn_details_rec);

l_progress := '80';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

End loop;


End Loop;

l_progress := '80';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

Exception
When No_data_found then
-- Case for NO LPN in ASN
IF (l_debug = 1) THEN
   print_debug('Asn has no LPN ', 1);
END IF;
null;
End;

l_progress := '90';
IF (l_debug = 1) THEN
   print_debug('Create ASN Details from interface : '|| l_progress ||' '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
END IF;

-- Update the Status
update WMS_ASN_DETAILS set discrepancy_status = 'E'
 where shipment_num = l_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = l_create_asn_details_rec.organization_id
   and discrepancy_reporting_context = 'I'
   and item_id = l_create_asn_details_rec.item_id
;



EXCEPTION
    WHEN fnd_api.g_exc_error THEN
       ROLLBACK TO crt_asn_details_interface;
       x_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );
    WHEN fnd_api.g_exc_unexpected_error THEN
       ROLLBACK TO crt_asn_details_interface;
       x_status := fnd_api.g_ret_sts_unexp_error ;
       fnd_msg_pub.count_and_get
	(p_encoded  => FND_API.g_false,
	 p_count    => l_msg_count,
	 p_data     => x_message
	 );
    WHEN OTHERS THEN
       IF (l_debug = 1) THEN
          print_debug('Other Problem Occured progress = '||l_progress||'sqlcode ='||SQLCODE, 1);
       END IF;
       ROLLBACK TO crt_asn_details_interface;
       x_status := fnd_api.g_ret_sts_unexp_error ;
       IF SQLCODE IS NOT NULL THEN
	  inv_mobile_helper_functions.sql_error('INV_CR_ASN_DETAILS.create_asn_details_from_intf', l_progress, SQLCODE);
       END IF;

       fnd_msg_pub.count_and_get
	 (p_encoded   => FND_API.g_false,
	  p_count     => l_msg_count,
	  p_data      => x_message
	  );

END create_asn_details_from_intf;

/* Bug 4551595-Added the procedure to be called from INV_STD_RCPT_APIS
               at the header level for all rti records with the same
	       group id */

PROCEDURE update_asn_item_details
( p_group_id IN NUMBER )
IS

CURSOR  rti_record
IS
SELECT * FROM rcv_transactions_interface
WHERE group_id = p_group_id ;

l_rti_record  rcv_transactions_interface%ROWTYPE;
l_create_asn_details_rec asn_details_rec_tp ;
l_shipment_num varchar2(30);
l_shipped_quantity  number;
l_item_id  number;
l_unit_of_measure varchar2(30);
l_item_revision  varchar2(3);


BEGIN

print_debug('In the procedure update_asn_item_details', 1);

OPEN rti_record;

LOOP

FETCH rti_record INTO  l_rti_record ;

EXIT WHEN rti_record%NOTFOUND ;

initialize_details(l_create_asn_details_rec);

SELECT shipment_num
INTO l_shipment_num
FROM rcv_shipment_headers
WHERE shipment_header_id= l_rti_record.shipment_header_id ;

SELECT quantity_shipped,
       item_id,
       unit_of_measure,
       item_revision
INTO l_shipped_quantity, l_item_id, l_unit_of_measure, l_item_revision
FROM RCV_SHIPMENT_LINES RSL
WHERE RSL.SHIPMENT_LINE_ID = l_rti_record.shipment_line_id ;

print_debug('Values from the rti record :',1);
print_debug('group_id:' || l_rti_record.group_id,1);
print_debug('organization_id:' || l_rti_record.to_organization_id,1);
print_debug('shipment_num:' || l_shipment_num,1);
print_debug('ITEM_ID:' || l_item_id,1);
print_debug('QUANTITY_EXPECTED:' || l_shipped_quantity,1);
print_debug('UNIT_OF_MEASURE_EXPECTED:' || l_unit_of_measure,1);
print_debug('ITEM_REVISION_EXPECTED:' || l_item_revision,1);
print_debug('QUANTITY_ACTUAL:' || l_rti_record.quantity,1);
print_debug('UNIT_OF_MEASURE_ACTUAL:' || l_rti_record.unit_of_measure,1);
print_debug('ITEM_REVISION_ACTUAL:' || l_rti_record.item_revision,1);

l_create_asn_details_rec.group_id        := l_rti_record.group_id;
l_create_asn_details_rec.organization_id := l_rti_record.to_organization_id;
l_create_asn_details_rec.shipment_num    := l_shipment_num ;
l_create_asn_details_rec.ITEM_ID                       :=  l_item_id ;
l_create_asn_details_rec.DISCREPANCY_REPORTING_CONTEXT := 'I' ;
l_create_asn_details_rec.QUANTITY_EXPECTED             :=  l_shipped_quantity;
l_create_asn_details_rec.UNIT_OF_MEASURE_EXPECTED      :=  l_unit_of_measure;
l_create_asn_details_rec.ITEM_REVISION_EXPECTED        :=  l_item_revision ;

l_create_asn_details_rec.QUANTITY_ACTUAL := l_rti_record.quantity;
l_create_asn_details_rec.UNIT_OF_MEASURE_ACTUAL :=  l_rti_record.unit_of_measure;
l_create_asn_details_rec.ITEM_REVISION_ACTUAL   :=  l_rti_record.item_revision ;
l_create_asn_details_rec.TRANSACTION_DATE   :=  sysdate;

-- Call the API for creating rows.

insert_asn_item_details(l_create_asn_details_rec);

if (Check_discrepancy(l_create_asn_details_rec.shipment_num,
                       l_create_asn_details_rec.organization_id))
then

update WMS_ASN_DETAILS set discrepancy_status = 'S'
 where shipment_num = l_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = l_create_asn_details_rec.organization_id
   and discrepancy_reporting_context = 'I'
   and item_id = l_create_asn_details_rec.item_id
;
else

update WMS_ASN_DETAILS set discrepancy_status = 'F'
 where shipment_num = l_create_asn_details_rec.SHIPMENT_NUM
   and organization_id = l_create_asn_details_rec.organization_id
   and discrepancy_reporting_context = 'I'
   and item_id = l_create_asn_details_rec.item_id
;

End if;

END LOOP;

END update_asn_item_details;

/* End of fix for Bug 4551595*/

END INV_CR_ASN_DETAILS;


/
