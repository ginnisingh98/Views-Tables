--------------------------------------------------------
--  DDL for Package Body POS_ASN_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASN_XML" AS
/* $Header: POSASNXB.pls 120.1.12010000.3 2011/08/09 09:08:26 kcthirum ship $*/

 Procedure validate_shipment_num
  (p_shipment_num  IN  VARCHAR,
   p_vendor_id IN NUMBER,
   p_vendor_site_id IN NUMBER,
   p_ship_to_org_id IN NUMBER,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR) is

  v_temp   NUMBER;
  p_count   NUMBER;

 BEGIN

 /* the conditions which need to applied are:
    no ASN for the same vendor and the same vendor site
    must have the same ASN
 */

 p_error_code := 0;

 select count(*)
 into v_temp
 from rcv_headers_interface
 where
   shipment_num = p_shipment_num  and
   vendor_id = p_vendor_id and
   nvl(vendor_site_id, -9999) = nvl(p_vendor_site_id, -9999);
   /* and shipped_date >= add_months(sysdate,-12) */



 select count(*)
 into  p_count
 from  rcv_shipment_headers
 where
     shipment_num = p_shipment_num and
     vendor_id = p_vendor_id and
     nvl(vendor_site_id, -9999) = nvl(p_vendor_site_id, -9999);
     /* and shipped_date >= add_months(sysdate,-12) */



 /* here we will check to see whether the v_temp is >1
    because due to parameter requirements this procedure
    can be called only at post_insert stage in the root-post level
 */

 if (p_count > 0  OR  v_temp > 1)  then
   p_error_code := 1;
   p_error_message := 'Another ASN exists for same Vendor and Vendor Site with the same Shipment Number: ' || p_shipment_num;
 end if;

    EXCEPTION
    WHEN OTHERS THEN
       p_error_code := 2;
       p_error_message := 'Exception in validate_shipment_num procedure for shipment_num: ' || p_shipment_num;


 END validate_shipment_num;



 Procedure validate_shipment_date
  (p_shipment_date    IN  DATE,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR) is

 BEGIN

   p_error_code := 0;

   if  (trunc(p_shipment_date) > trunc(sysdate))    then
      p_error_code := 1;
      p_error_message := 'Shipment date ' || p_shipment_date || ' cannot be greater than current date';
   end if;

   EXCEPTION
    WHEN OTHERS THEN
       p_error_code := 2;
       p_error_message := 'Exception in validate_shipment_date for shipment_date: ' || p_shipment_date;

 END validate_shipment_date;



 Procedure validate_receipt_date
   (p_shipment_date    IN  DATE,
    p_expected_receipt_date IN DATE,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR) is

 BEGIN

    p_error_code := 0;

    if  (trunc(p_shipment_date) > trunc(p_expected_receipt_date))   then
      p_error_code := 1;
      p_error_message := 'Shipment date ' || p_shipment_date || ' cannot be greater than Expected Receipt date' || p_expected_receipt_date;
    end if;

    EXCEPTION
      WHEN OTHERS THEN
       p_error_code := 2;
       p_error_message :=  'Exception in validate_receipt_date for shipment_date: ' || p_shipment_date ;
       p_error_message :=  p_error_message || ', Receipt date: ' || p_expected_receipt_date;

 END validate_receipt_date;



 Procedure validate_quantity
  (p_line_location_id  IN  NUMBER,
   p_quantity IN  NUMBER,
   p_unit_of_measure  IN  VARCHAR,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR) is

   l_converted_quantity NUMBER;
   l_tolerable_quantity NUMBER;

 BEGIN

  p_error_code := 0;

--test
  if (p_quantity is null or p_quantity <= 0) then
    p_error_code := 1;
    p_error_message := 'Quantity shipped ' || p_quantity || ' is null or <= 0';
    p_error_message := p_error_message || ', for unit_of_measure ' || p_unit_of_measure;
    p_error_message := p_error_message || ', line_location_id ' || p_line_location_id;
  end if;
--end of test
if(	p_error_code = 0) then

  POS_CREATE_ASN.getConvertedQuantity ( p_line_location_id,
                                        p_quantity ,
                                        p_unit_of_measure,
                                        l_converted_quantity);

  l_tolerable_quantity := POS_CREATE_ASN.getTolerableShipmentQuantity(p_line_location_id);

  if (l_tolerable_quantity < l_converted_quantity) then

   p_error_code := 1;
   p_error_message := 'Quantity shipped ' || p_quantity || ' is greater than remaining quantity for this PO Shipment line ';
   p_error_message := p_error_message || ', for unit_of_measure ' || p_unit_of_measure;
   p_error_message := p_error_message || ', line_location_id ' || p_line_location_id;

  end if;
end if;

   EXCEPTION
    WHEN OTHERS THEN
       p_error_code := 2;
       p_error_message := 'Exception in validate_quantity ';
       p_error_message := p_error_message || ' for quantity ' || p_quantity;
       p_error_message := p_error_message || ', unit_of_measure ' || p_unit_of_measure;
       p_error_message := p_error_message || ', line_location_id ' || p_line_location_id;

 END validate_quantity;



 Procedure validate_freight_carrier_code
  (p_freight_code    IN  VARCHAR,
   p_error_code OUT NOCOPY NUMBER) is

   l_count NUMBER;

 BEGIN

  select count(*)
  into l_count
  from ORG_FREIGHT
  where
    freight_code = p_freight_code;

 if (l_count =  0) then
    p_error_code := 1;
 else
    p_error_code := 0;
 end if;

 END validate_freight_carrier_code;




 Procedure validate_freight_terms
  (p_freight_terms    IN  VARCHAR,
   p_error_code OUT NOCOPY NUMBER) is

   l_count NUMBER;

 BEGIN

  select count(*)
  into l_count
  from po_lookup_codes
  where lookup_type = 'FREIGHT TERMS'
  and lookup_code = p_freight_terms
  and sysdate < nvl(inactive_date, sysdate + 1);

  if (l_count = 1) then
    p_error_code := 1;
  else
    p_error_code := 0;
  end if;

  END validate_freight_terms;



 Procedure use_preProcessor
  (p_group_id IN  NUMBER,
   p_org_id IN  NUMBER,
   p_error_message OUT NOCOPY VARCHAR,
   p_error_code OUT NOCOPY NUMBER,
   p_po_num OUT NOCOPY VARCHAR,
   p_line_num OUT NOCOPY NUMBER,
   p_po_shipment_line_num OUT NOCOPY NUMBER) is

   l_count NUMBER;

 BEGIN
  p_error_code := 0;

  /*
  POS_CREATE_ASN.callPreProcessor(p_group_id);
  */

  fnd_client_info.set_org_context(to_char(p_org_id));

  rcv_shipment_object_sv.create_object(p_group_id);


  /*
  select
    poh.segment1,
    pol.line_num,
    poll.shipment_num,
    pie.error_message
  into
   p_po_num,
   p_line_num,
   p_po_shipment_line_num,
   p_error_message
  from
     rcv_transactions_interface rti, po_interface_errors pie, po_headers_all poh, po_lines_all pol,
     po_line_locations_all poll
  where
    pie.interface_header_id = rti.header_interface_id and
    pie.interface_type in ('RECEIVING','RCV-856')  and
    rti.po_header_id = poh.po_header_id  and
    rti.po_line_id = pol.po_line_id   and
    rti.po_line_location_id = poll.line_location_id and
    rti.group_id = p_group_id;
*/

select count(*)
into l_count
from
  rcv_transactions_interface rti, po_interface_errors pie
where
  pie.interface_header_id = rti.header_interface_id and
 -- pie.interface_type in ('RECEIVING','RCV-856')  and
  rti.group_id = p_group_id;


if (l_count <> 0) then

     p_error_code := 1;

     select
       min(pie.error_message)
     into
       p_error_message
     from
       rcv_transactions_interface rti, po_interface_errors pie
     where
       pie.interface_header_id = rti.header_interface_id and
       -- pie.interface_type in ('RECEIVING','RCV-856')  and
       rti.group_id = p_group_id;

end if;

   EXCEPTION
    WHEN OTHERS THEN
       p_error_code := 2;
       p_error_message := 'Exception in use_preProcessor for group_id: ' || p_group_id || ', and org_id: ' || p_org_id;

  END use_preProcessor;



  Procedure  derive_location_id
    (p_ship_to_partner_id  IN  VARCHAR,
     p_org_id IN NUMBER,
     p_address1  IN  VARCHAR,
     p_address2  IN  VARCHAR,
     p_city  IN VARCHAR,
     p_postal_code IN VARCHAR,
     p_country  IN VARCHAR,
     p_po_line_location_id IN NUMBER,
     p_ship_to_location_id OUT NOCOPY NUMBER,
     p_auto_transact_code OUT NOCOPY VARCHAR,
     p_transaction_type OUT NOCOPY VARCHAR,
     p_error_code OUT NOCOPY NUMBER,
     p_error_message OUT NOCOPY VARCHAR) is

    l_count_num NUMBER;
    l_loc_count NUMBER;
    x_pla_count NUMBER;
    l_location_id NUMBER;

 BEGIN

   p_error_code := 0;

 IF ((p_ship_to_partner_id  is null) OR (p_ship_to_partner_id  = '')) THEN

 /* use address */

    p_auto_transact_code := 'SHIP';
    p_transaction_type := 'SHIP';

    select pll.ship_to_location_id
    into l_location_id
    from po_line_locations_all pll
    where pll.line_location_id = p_po_line_location_id;

    SELECT count(*)
    INTO l_loc_count
    FROM hz_locations
    WHERE
      address1 = p_address1 and
      nvl(address2, 99) = nvl(p_address2, 99) and
      city = p_city and
      postal_code = p_postal_code and
      country = p_country and
      location_id = l_location_id;

  if (l_loc_count = 1) then

     /*
     SELECT min(location_id)
     INTO  p_ship_to_location_id
     FROM hz_locations
     WHERE
      address1 = p_address1 and
      nvl(address2, 99) = nvl(p_address2, 99) and
      city = p_city  and
      postal_code = p_postal_code and
      country = p_country;
      */
      p_ship_to_location_id := l_location_id;

      select count(*)
	  into   x_pla_count
	  from   po_location_associations_all pla
	  where pla.org_id = p_org_id
               and pla.location_id = p_ship_to_location_id
               and pla.vendor_id is not null
               and pla.vendor_site_id is not null;

        if (x_pla_count = 0) then

          p_auto_transact_code := 'SHIP';
          p_transaction_type := 'SHIP';

        else

          p_auto_transact_code := 'DELIVER';
          p_transaction_type := 'RECEIVE';

        end if;


  elsif (l_loc_count > 1) then

   p_ship_to_location_id := 0;
   p_error_code := 1;
   p_error_message := 'Multiple matching locations found ';
   p_error_message := p_error_message || ' for address1 ' || p_address1;
   p_error_message := p_error_message || ' , address2 ' || p_address2;
   p_error_message := p_error_message || ' , city ' || p_city;
   p_error_message := p_error_message || ' , postal_code ' || p_postal_code;
   p_error_message := p_error_message || ' , country ' || p_country;


   else

     p_ship_to_location_id := 0;
     p_error_code := 1;
     p_error_message := 'No matching location found ';
     p_error_message := p_error_message || ' for address1 ' || p_address1;
     p_error_message := p_error_message || ' , address2 ' || p_address2;
     p_error_message := p_error_message || ' , city ' || p_city;
     p_error_message := p_error_message || ' , postal_code ' || p_postal_code;
     p_error_message := p_error_message || ' , country ' || p_country;

   end if;


 ELSE    /* use edi_code */

   SELECT count(*)
   INTO l_count_num
   FROM hr_locations_all
   WHERE ece_tp_location_code = p_ship_to_partner_id;

   if (l_count_num = 0) then

       p_ship_to_location_id := 0;
       p_auto_transact_code := 'SHIP';
       p_transaction_type := 'SHIP';

   else

       SELECT min(location_id)
       INTO  p_ship_to_location_id
       FROM hr_locations_all
       WHERE ece_tp_location_code = p_ship_to_partner_id;


        select count(*)
	  into   x_pla_count
	  from   po_location_associations_all pla
	  where pla.org_id = p_org_id
               and pla.location_id = p_ship_to_location_id
               and pla.vendor_id is not null
               and pla.vendor_site_id is not null;

        IF (x_pla_count = 0) THEN

          p_auto_transact_code := 'SHIP';
          p_transaction_type := 'SHIP';

        ELSE

          p_auto_transact_code := 'DELIVER';
          p_transaction_type := 'RECEIVE';

        END IF;

  end if;

  IF ((p_ship_to_location_id = null) OR (p_ship_to_location_id <= 0)) THEN

    SELECT count(*)
    INTO l_loc_count
    FROM
     hz_locations loc,
     hz_party_sites party,
     hz_cust_acct_sites_all cust
    WHERE
      cust.ece_tp_location_code = p_ship_to_partner_id
      and cust.org_id = p_org_id
      and cust.party_site_id = party.party_site_id
      and party.location_id = loc.location_id;



  if (l_loc_count = 1) then


     SELECT min(loc.location_id)
     INTO  p_ship_to_location_id
     FROM
       hz_locations loc,
       hz_party_sites party,
       hz_cust_acct_sites_all cust
     WHERE
      cust.ece_tp_location_code = p_ship_to_partner_id
      and cust.org_id = p_org_id
      and cust.party_site_id = party.party_site_id
      and party.location_id = loc.location_id;



  elsif (l_loc_count > 1) then

   p_ship_to_location_id := 0;
   p_error_code := 1;
   p_error_message := 'Multiple matching locations found for Ship To Partner Id (PARTNRIDX)  ' || p_ship_to_partner_id;

   else
     p_ship_to_location_id := 0;
     p_error_code := 1;
     p_error_message := 'No matching location found for Ship To Partner Id (PARTNRIDX)  ' || p_ship_to_partner_id;

   end if;

   END IF;

END IF;  /* end of if-else use address */


EXCEPTION
    WHEN OTHERS THEN

    p_ship_to_location_id := 0;
    p_error_code := 2;
    p_error_message := 'Exception in derive_location_id for ship_to_partner_id: ' || p_ship_to_partner_id;
    p_error_message := p_error_message || ', and org_id ' || p_org_id;


END derive_location_id;



 Procedure  derive_org_id
   (p_document_line_num IN NUMBER,
    p_document_shipment_line_num IN NUMBER,
    p_release_num IN NUMBER,
    p_po_number IN VARCHAR,
    p_supplier_code IN VARCHAR,
    p_item_num IN VARCHAR,
    p_supplier_item_num IN VARCHAR,
    p_org_id  OUT NOCOPY NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_po_header_id OUT NOCOPY NUMBER,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR) is

    l_count_num  NUMBER;
    x_ship_org_num NUMBER;

  BEGIN

   p_error_code := 0;

   if ((p_release_num is null) OR (p_release_num = 0)) then

    SELECT count(*)
    INTO l_count_num
    FROM
     po_headers_all poh,
     po_lines_all pol,
     po_line_locations_all pll,
     Mtl_system_items_kfv msi
    WHERE
     poh.SEGMENT1 = p_po_number AND
     poh.Vendor_Site_ID IN
       (SELECT Vendor_Site_ID
        FROM PO_Vendor_Sites_All
        WHERE  ECE_TP_LOCATION_CODE = p_supplier_code)    AND
     nvl(msi.concatenated_segments, -99) = nvl(NVL(p_item_num, msi.concatenated_segments), -99) AND
     nvl(pol.VENDOR_PRODUCT_NUM, -99) = nvl(NVL(p_supplier_item_num, pol.VENDOR_PRODUCT_NUM), -99) AND
     pol.po_header_id =  poh.po_header_id AND
     pol.line_num = p_document_line_num AND
     pol.po_line_id = pll.po_line_id AND
     pll.shipment_num = p_document_shipment_line_num AND
     pll.ship_to_organization_id = nvl(msi.organization_id, pll.ship_to_organization_id) AND
     pol.item_id = msi.inventory_item_id (+);

   else

    SELECT count(*)
    INTO l_count_num
    FROM
     po_headers_all poh,
     po_lines_all pol,
     po_line_locations_all pll,
     po_releases_all prl,
     Mtl_system_items_kfv msi
    WHERE
     poh.SEGMENT1 = p_po_number AND
     poh.Vendor_Site_ID IN
       (SELECT Vendor_Site_ID
        FROM PO_Vendor_Sites_All
        WHERE  ECE_TP_LOCATION_CODE = p_supplier_code)    AND
     nvl(msi.concatenated_segments, -99) = nvl(NVL(p_item_num, msi.concatenated_segments), -99) AND
     nvl(pol.VENDOR_PRODUCT_NUM, -99) = nvl(NVL(p_supplier_item_num, pol.VENDOR_PRODUCT_NUM), -99) AND
     pol.po_header_id =  poh.po_header_id AND
     pol.line_num = p_document_line_num AND
     pol.po_line_id = pll.po_line_id AND
     pll.shipment_num = p_document_shipment_line_num AND
     pll.PO_RELEASE_ID = prl.PO_RELEASE_ID AND
     prl.release_num = p_release_num AND
     pll.ship_to_organization_id = nvl(msi.organization_id, pll.ship_to_organization_id) AND
     pol.item_id = msi.inventory_item_id (+);


   end if;


     if  (l_count_num = 0)  then
       p_error_code := 1;
       p_error_message := 'No matching record found for Ship From Partner Id (PARTNRIDX)  : ' || p_supplier_code;
       p_error_message := p_error_message || ', PO Number :' || p_po_number;
       p_error_message := p_error_message || ', Line Number ' || p_document_line_num;
       p_error_message := p_error_message || ', Shipment Number ' || p_document_shipment_line_num;
       p_error_message := p_error_message || ', Release Number ' || p_release_num;
       p_error_message := p_error_message || ', Item Number ' || p_item_num;
       p_error_message := p_error_message || ', Supplier Item Number ' || p_supplier_item_num;
     end if;


     if  (l_count_num > 1)  then
       p_error_code := 4;
       p_error_message := 'Multiple matching records found for Ship From Partner Id (PARTNRIDX)  : ' || p_supplier_code;
       p_error_message := p_error_message || ', PO Number :' || p_po_number;
       p_error_message := p_error_message || ', Line Number ' || p_document_line_num;
       p_error_message := p_error_message || ', Shipment Number ' || p_document_shipment_line_num;
       p_error_message := p_error_message || ', Release Number ' || p_release_num;
       p_error_message := p_error_message || ', Item Number ' || p_item_num;
       p_error_message := p_error_message || ', Supplier Item Number ' || p_supplier_item_num;
     end if;


   if (p_error_code = 0) then     /* get the org_id */

    if ((p_release_num is null) OR (p_release_num = 0)) then

     SELECT min(poh.ORG_ID)
     INTO p_org_id
     FROM
     po_headers_all poh,
     po_lines_all pol,
     po_line_locations_all pll,
     Mtl_system_items_kfv msi
    WHERE
     poh.SEGMENT1 = p_po_number AND
     poh.Vendor_Site_ID IN
       (SELECT Vendor_Site_ID
        FROM PO_Vendor_Sites_All
        WHERE  ECE_TP_LOCATION_CODE = p_supplier_code)    AND
     nvl(msi.concatenated_segments, -99) = nvl(NVL(p_item_num, msi.concatenated_segments), -99) AND
     nvl(pol.VENDOR_PRODUCT_NUM, -99) = nvl(NVL(p_supplier_item_num, pol.VENDOR_PRODUCT_NUM), -99) AND
     pol.po_header_id =  poh.po_header_id AND
     pol.line_num = p_document_line_num AND
     pol.po_line_id = pll.po_line_id AND
     pll.shipment_num = p_document_shipment_line_num AND
     pll.ship_to_organization_id = nvl(msi.organization_id, pll.ship_to_organization_id) AND
     pol.item_id = msi.inventory_item_id (+);

    else

     SELECT min(poh.ORG_ID)
     INTO p_org_id
     FROM
     po_headers_all poh,
     po_lines_all pol,
     po_line_locations_all pll,
     po_releases_all prl,
     Mtl_system_items_kfv msi
    WHERE
     poh.SEGMENT1 = p_po_number AND
     poh.Vendor_Site_ID IN
       (SELECT Vendor_Site_ID
        FROM PO_Vendor_Sites_All
        WHERE  ECE_TP_LOCATION_CODE = p_supplier_code)    AND
     nvl(msi.concatenated_segments, -99) = nvl(NVL(p_item_num, msi.concatenated_segments), -99) AND
     nvl(pol.VENDOR_PRODUCT_NUM, -99) = nvl(NVL(p_supplier_item_num, pol.VENDOR_PRODUCT_NUM), -99) AND
     pol.po_header_id =  poh.po_header_id AND
     pol.line_num = p_document_line_num AND
     pol.po_line_id = pll.po_line_id AND
     pll.shipment_num = p_document_shipment_line_num AND
     pll.PO_RELEASE_ID = prl.PO_RELEASE_ID AND
     prl.release_num = p_release_num AND
     pll.ship_to_organization_id = nvl(msi.organization_id, pll.ship_to_organization_id) AND
     pol.item_id = msi.inventory_item_id (+);


    end if;


     select min(po_header_id)
     into p_po_header_id
     from po_headers_all
     where segment1 = p_po_number
     and org_id = p_org_id;


     if ((p_release_num is null) OR (p_release_num = 0)) then

          select
            count(*)
          into
            x_ship_org_num
          from
            po_headers_all poh,
            po_lines_all pol,
            po_line_locations_all pll
          where
            poh.po_header_id = p_po_header_id and
            poh.po_header_id = pol.po_header_id and
            pol.line_num = p_document_line_num and
            pol.po_line_id = pll.po_line_id and
            pll.shipment_num = p_document_shipment_line_num;

     else

           select
            count(*)
          into
            x_ship_org_num
          from
            po_headers_all poh,
            po_lines_all pol,
            po_line_locations_all pll,
            po_releases_all prl
          where
            poh.po_header_id = p_po_header_id and
            poh.po_header_id = pol.po_header_id and
            pol.line_num = p_document_line_num and
            pol.po_line_id = pll.po_line_id and
            pll.shipment_num = p_document_shipment_line_num and
            pll.PO_RELEASE_ID = prl.PO_RELEASE_ID AND
            prl.release_num = p_release_num;


     end if;


        if (x_ship_org_num > 0) then

         if ((p_release_num is null) OR (p_release_num = 0)) then

          select
            min(pll.ship_to_organization_id)
          into
            p_ship_to_org_id
          from
            po_headers_all poh,
            po_lines_all pol,
            po_line_locations_all pll
          where
            poh.po_header_id = p_po_header_id and
            poh.po_header_id = pol.po_header_id and
            pol.line_num = p_document_line_num and
            pol.po_line_id = pll.po_line_id and
            pll.shipment_num = p_document_shipment_line_num;

         else

          select
            min(pll.ship_to_organization_id)
          into
            p_ship_to_org_id
          from
            po_headers_all poh,
            po_lines_all pol,
            po_line_locations_all pll,
            po_releases_all prl
          where
            poh.po_header_id = p_po_header_id and
            poh.po_header_id = pol.po_header_id and
            pol.line_num = p_document_line_num and
            pol.po_line_id = pll.po_line_id and
            pll.shipment_num = p_document_shipment_line_num and
            pll.PO_RELEASE_ID = prl.PO_RELEASE_ID AND
            prl.release_num = p_release_num;

         end if;

        else                   /* x_ship_org_num is 0 */
          p_error_code := 2;
          p_error_message := 'No matching record found for Ship From Partner Id (PARTNRIDX)  : ' || p_supplier_code;
          p_error_message := p_error_message || ', PO Number :' || p_po_number;
          p_error_message := p_error_message || ', Line Number ' || p_document_line_num;
          p_error_message := p_error_message || ', Shipment Number ' || p_document_shipment_line_num;
          p_error_message := p_error_message || ', Release Number ' || p_release_num;
          p_error_message := p_error_message || ', Item Number ' || p_item_num;
          p_error_message := p_error_message || ', Supplier Item Number ' || p_supplier_item_num;

        end if;


     end if;  /* error_code is 0 */


   EXCEPTION
    WHEN OTHERS THEN
        p_error_code := 3;
        p_error_message := 'Exception in derive_org_id';
        p_error_message := p_error_message || ' for PO Number ' || p_po_number;
        p_error_message := p_error_message || ', and supplier_code: ' || p_supplier_code;
        p_error_message := p_error_message || ', po_header_id ' || p_po_header_id;
        p_error_message := p_error_message || ', document_line_num ' || p_document_line_num;
        p_error_message := p_error_message || ', document_shipment_line_num ' || p_document_shipment_line_num;
        p_error_message := p_error_message || ', item_num ' || p_item_num;
        p_error_message := p_error_message || ', supplier_item_num ' || p_supplier_item_num;
        p_error_message := p_error_message || ', release_num ' || p_release_num;

   END derive_org_id;



   Procedure derive_vendor_id
    (p_org_id IN NUMBER,
     p_supplier_code IN VARCHAR,
     p_vendor_id  OUT NOCOPY  NUMBER,
     p_vendor_site_id  OUT NOCOPY  NUMBER,
     p_error_code  OUT NOCOPY NUMBER,
     p_error_message OUT NOCOPY VARCHAR)  is

   BEGIN
      p_error_code := 0;

      /*Need to put error message here */

      SELECT
       vendor_site_id,
       vendor_id
      INTO
        p_vendor_site_id,
        p_vendor_id
      FROM   po_vendor_sites_all
      WHERE  ece_tp_location_code = p_supplier_code
      AND   org_id = p_org_id;

   EXCEPTION
    WHEN OTHERS THEN
     p_error_code := 1;
     p_vendor_id := 0;
     p_vendor_site_id := 0;
     p_error_message := 'No matching vendor_id, vendor_site_id found in derive_vendor_id';
     p_error_message :=  p_error_message || ' for supplier code ' || p_supplier_code;

  END  derive_vendor_id;


  Procedure store_line_vendor_error
   (p_error_code IN NUMBER,
    p_error_message IN VARCHAR,
    line_vendor_error_code OUT NOCOPY NUMBER,
    line_vendor_error_message OUT NOCOPY VARCHAR) is

    BEGIN

    if (p_error_code > 0) then

     line_vendor_error_code := p_error_code;
     line_vendor_error_message := p_error_message;

    end if;

    END store_line_vendor_error;



   Procedure store_line_org_error
   (p_error_code IN NUMBER,
    p_error_message IN VARCHAR,
    line_org_error_code OUT NOCOPY NUMBER,
    line_org_error_message OUT NOCOPY VARCHAR) is

    BEGIN

    if (p_error_code > 0) then

     line_org_error_code := p_error_code;
     line_org_error_message := p_error_message;

    end if;

    END store_line_org_error;



   Procedure store_line_location_error
   (p_error_code IN NUMBER,
    p_error_message IN VARCHAR,
    line_location_error_code OUT NOCOPY NUMBER,
    line_location_error_message OUT NOCOPY VARCHAR) is

    BEGIN

    if (p_error_code > 0) then

     line_location_error_code := p_error_code;
     line_location_error_message := p_error_message;

    end if;

    END store_line_location_error;



   Procedure get_user_id
   (p_user_name IN VARCHAR,
    p_user_id OUT NOCOPY NUMBER,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR) is

   l_count NUMBER;

   BEGIN

   p_error_code := 0;

   select count(*)
   into l_count
   from fnd_user
   where user_name = upper(p_user_name);


  if (l_count = 0) then
     -- Bug fix 7295891
     -- Username can be null if the inbound ASN XML comes
     -- via JMS, a new feature introduced in 11.5.10.2
     -- XML gateway does not check for auth if the profile
     -- ECX: Enable User Check for Trading Partner is set to NO
     -- If the username is null, we can hardcode the user_id = -1
     -- User_id is used in created_by,updated_by columns and for notification
     -- Created by, updated by will be -1 - No Impact
     -- For notification, if the user_name is null, we send the error notification
     -- to the Admin email id, that is defined at the trading partner setup.
     --p_error_code := 1;
     p_user_id := -1;
     --p_error_message := 'Invalid User Name ' || p_user_name;

  else

   select user_id
   into p_user_id
   from fnd_user
   where user_name = upper(p_user_name);

  end if;

 END get_user_id;



  Procedure pre_validate
   (p_header_interface_id IN NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_vendor_id OUT NOCOPY NUMBER,
    p_vendor_site_id OUT NOCOPY NUMBER,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR) is

    x_ship_org_count NUMBER;

   BEGIN

   select count(*)
   into x_ship_org_count
   from (select distinct to_organization_id
         from rcv_transactions_interface
         where header_interface_id = p_header_interface_id);


   if (x_ship_org_count = 1) then

    p_error_code := 0;

    select
     min(to_organization_id),
     min(vendor_id),
     min(vendor_site_id)
   into
     p_ship_to_org_id,
     p_vendor_id,
     p_vendor_site_id
   from
    rcv_transactions_interface
   where
     header_interface_id = p_header_interface_id;

   update rcv_headers_interface
   set vendor_id = p_vendor_id,
       vendor_site_id = p_vendor_site_id,
       ship_to_organization_id = p_ship_to_org_id
   where header_interface_id = p_header_interface_id;

   elsif (x_ship_org_count > 1) then

     p_error_code := 1;
     p_error_message := 'ASN contains lines from Multiple Ship To Organizations';

   else

     p_error_code := 2;
     p_error_message := 'No matching Ship To Organization found';

   end if;


   EXCEPTION
     WHEN OTHERS THEN

     p_error_code := 3;
     p_error_message := 'Error in pre_validate procedure for header_interface_id: ' || p_header_interface_id;

   END pre_validate;



 Procedure derive_line_cols
  (p_po_header_id IN NUMBER,
   p_line_num IN NUMBER,
   p_document_shipment_line_num IN NUMBER,
   p_release_num IN NUMBER,
   p_item_id OUT NOCOPY NUMBER,
   p_item_num OUT NOCOPY VARCHAR,
   p_item_revision OUT NOCOPY VARCHAR,
   p_supplier_item_num OUT NOCOPY VARCHAR,
   --p_ship_to_location_id IN OUT NOCOPY NUMBER,
   p_ship_to_location_id OUT NOCOPY NUMBER,
   p_po_line_id OUT NOCOPY NUMBER,
   p_line_location_id OUT NOCOPY NUMBER,
   p_ship_to_org_id OUT NOCOPY NUMBER,
   p_po_release_id OUT NOCOPY NUMBER,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR) is

   x_po_num VARCHAR2(100);
   l_count NUMBER;

   --x_ship_to_location_id NUMBER;


 BEGIN

  p_error_code := 0;

  /* save the inbound value for ship_to_location_id for matching */

  --x_ship_to_location_id := p_ship_to_location_id;

  select segment1 into x_po_num from po_headers_all where po_header_id=p_po_header_id;

if ((p_release_num is null) OR (p_release_num = 0)) then

 SELECT
   count(*)
 INTO
   l_count
 FROM
  po_headers_all poh,
  po_lines_all pol,
  po_line_locations_all pll,
  MTL_SYSTEM_ITEMS_KFV MSI
 WHERE
  POH.PO_HEADER_ID = POL.PO_HEADER_ID
  and POL.PO_LINE_ID = PLL.PO_LINE_ID
  and pol.item_id = msi.inventory_item_id (+)
  and nvl(msi.ORGANIZATION_ID, pll.SHIP_TO_ORGANIZATION_ID) = pll.SHIP_TO_ORGANIZATION_ID
  and poh.PO_HEADER_ID = p_po_header_id
  and pol.LINE_NUM = p_line_num
  and pll.shipment_num = p_document_shipment_line_num;


else

 SELECT
   count(*)
INTO
   l_count
FROM
  po_headers_all poh,
  po_lines_all pol,
  po_line_locations_all pll,
  po_releases_all prl,
  MTL_SYSTEM_ITEMS_KFV MSI
WHERE
  POH.PO_HEADER_ID = POL.PO_HEADER_ID
  and POL.PO_LINE_ID = PLL.PO_LINE_ID
  and pll.PO_RELEASE_ID = prl.PO_RELEASE_ID
  and pol.item_id = msi.inventory_item_id (+)
  and nvl(msi.ORGANIZATION_ID, pll.SHIP_TO_ORGANIZATION_ID) = pll.SHIP_TO_ORGANIZATION_ID
  and poh.PO_HEADER_ID = p_po_header_id
  and pol.LINE_NUM = p_line_num
  and pll.shipment_num = p_document_shipment_line_num
  and prl.release_num = p_release_num;

end if;

IF (l_count = 1) THEN

 if ((p_release_num is null) OR (p_release_num = 0)) then

 SELECT
   pol.ITEM_ID,
   msi.CONCATENATED_SEGMENTS ITEM_NUM,
   pol.ITEM_REVISION,
   pol.VENDOR_PRODUCT_NUM SUPPLIER_ITEM_NUMBER,
   pll.ship_to_location_id,
   pol.PO_LINE_ID,
   pll.LINE_LOCATION_ID,
   pll.SHIP_TO_ORGANIZATION_ID SHIP_TO_ORG_ID
 INTO
   p_item_id,
   p_item_num,
   p_item_revision,
   p_supplier_item_num,
   p_ship_to_location_id,
   p_po_line_id,
   p_line_location_id,
   p_ship_to_org_id
 FROM
  po_headers_all poh,
  po_lines_all pol,
  po_line_locations_all pll,
  MTL_SYSTEM_ITEMS_KFV MSI
 WHERE
  POH.PO_HEADER_ID = POL.PO_HEADER_ID
  and POL.PO_LINE_ID = PLL.PO_LINE_ID
  and pol.item_id = msi.inventory_item_id (+)
  and nvl(msi.ORGANIZATION_ID, pll.SHIP_TO_ORGANIZATION_ID) = pll.SHIP_TO_ORGANIZATION_ID
  and poh.PO_HEADER_ID = p_po_header_id
  and pol.LINE_NUM = p_line_num
  and pll.shipment_num = p_document_shipment_line_num;


else

 SELECT
   pol.ITEM_ID,
   msi.CONCATENATED_SEGMENTS ITEM_NUM,
   pol.ITEM_REVISION,
   pol.VENDOR_PRODUCT_NUM SUPPLIER_ITEM_NUMBER,
   pll.ship_to_location_id,
   pol.PO_LINE_ID,
   pll.LINE_LOCATION_ID,
   pll.SHIP_TO_ORGANIZATION_ID SHIP_TO_ORG_ID,
   prl.PO_RELEASE_ID
INTO
   p_item_id,
   p_item_num,
   p_item_revision,
   p_supplier_item_num,
   p_ship_to_location_id,
   p_po_line_id,
   p_line_location_id,
   p_ship_to_org_id,
   p_po_release_id
FROM
  po_headers_all poh,
  po_lines_all pol,
  po_line_locations_all pll,
  po_releases_all prl,
  MTL_SYSTEM_ITEMS_KFV MSI
WHERE
  POH.PO_HEADER_ID = POL.PO_HEADER_ID
  and POL.PO_LINE_ID = PLL.PO_LINE_ID
  and pll.PO_RELEASE_ID = prl.PO_RELEASE_ID
  and pol.item_id = msi.inventory_item_id (+)
  and nvl(msi.ORGANIZATION_ID, pll.SHIP_TO_ORGANIZATION_ID) = pll.SHIP_TO_ORGANIZATION_ID
  and poh.PO_HEADER_ID = p_po_header_id
  and pol.LINE_NUM = p_line_num
  and pll.shipment_num = p_document_shipment_line_num
  and prl.release_num = p_release_num;


 end if;

  /* now validate whether the ship_to_location_id derived from derive_location method
     is the same as the ship_to_location_id obtained from the PO Shipment */
/*
   if (x_ship_to_location_id <> p_ship_to_location_id) then

      p_error_code := 1;
      p_error_message := 'Ship-to-location derived from EDI Location Code is different from';
      p_error_message := p_error_message || ' the Ship-to_location on PO Shipment';
      p_error_message := p_error_message || ' for PO Number ' || x_po_num;
      p_error_message := p_error_message || ', Line Number  ' || p_line_num;
      p_error_message := p_error_message || ', Shipment Number  ' || p_document_shipment_line_num;

   end if;
*/

END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := 2;
      p_error_message := 'Exception in derive_line_cols in deriving fields for ASN line with ';
      p_error_message := p_error_message || ' PO Number ' || x_po_num;
      p_error_message := p_error_message || ', po_header_id ' || p_po_header_id;
      p_error_message := p_error_message || ', document_line_num ' || p_line_num;
      p_error_message := p_error_message || ', document_shipment_line_num ' || p_document_shipment_line_num;
      p_error_message := p_error_message || ', release_num ' || p_release_num;

  END derive_line_cols;


Procedure populate_doc_id
  (p_header_interface_id IN NUMBER,
   p_location_id IN NUMBER,
   p_bill_of_lading IN VARCHAR,
   p_packing_slip IN VARCHAR,
   p_waybill_airbill_num IN VARCHAR) is

x_err_code NUMBER;

BEGIN

update rcv_headers_interface
   set bill_of_lading = p_bill_of_lading,
       packing_slip = p_packing_slip,
       waybill_airbill_num = p_waybill_airbill_num,
       location_id = p_location_id
   where header_interface_id = p_header_interface_id;


EXCEPTION
    WHEN OTHERS THEN
      x_err_code := 2;

END populate_doc_id;


Procedure derive_unit_of_measure
  (p_uom_code IN VARCHAR,
   p_unit_of_measure OUT NOCOPY VARCHAR,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR) is

   l_count NUMBER;

  BEGIN

  p_error_code := 0;

  select count(*)
  into l_count
  from mtl_units_of_measure_tl
  where uom_code = p_uom_code
  and language = USERENV('LANG');

  if (l_count = 0) then

    p_error_code := 1;
    p_error_message := 'No matching Unit Of Measure for UOM Code ' || p_uom_code;
    p_error_message := p_error_message || ' , and language ' || USERENV('LANG');

  elsif (l_count > 1) then

     p_error_code := 1;
     p_error_message := 'Multiple matching records of Unit Of Measure for UOM Code ' || p_uom_code;
     p_error_message := p_error_message || ' , and language ' || USERENV('LANG');

  else          /* l_count = 1 */

   select unit_of_measure
   into p_unit_of_measure
   from mtl_units_of_measure_tl
   where uom_code = p_uom_code
   and language = USERENV('LANG');

  end if;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_code := 2;
      p_error_message := 'Error in deriving Unit Of Measure for UOM Code ' || p_uom_code;
      p_error_message := p_error_message || ' , and language ' || USERENV('LANG');

  END derive_unit_of_measure;

  Procedure derive_interface_id_for_wms
  (header_intf_id IN number,
   item IN VARCHAR,
   item_rev IN VARCHAR2,
   doc_num  in varchar2,
   doc_rev_num in number,
   doc_line_num in number,
   doc_shipment_line_num in number,
   doc_release_num in number,
   wms_interface_transaction_id OUT NOCOPY number,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR) IS
   l_count NUMBER := 0;
   h_count NUMBER :=0;
   BEGIN
  p_error_code := 0;
  SELECT Count(*) INTO l_count FROM  rcv_transactions_interface;
  SELECT Count(*) INTO h_count FROM rcv_headers_interface hdr WHERE creation_date >= SYSDATE -1;
select interface_transaction_id
  into wms_interface_transaction_id
  from rcv_transactions_interface
  where item_num = item
  AND Nvl(item_revision,'-1') = Nvl(item_rev,'-1')
  AND Nvl(DOCUMENT_NUM,'-1') = Nvl(doc_num, '-1')
  AND Nvl(PO_REVISION_NUM,'-1') = Nvl(doc_rev_num, '-1')
  AND Nvl(DOCUMENT_LINE_NUM, -1) = Nvl(doc_line_num, -1)
  AND Nvl(DOCUMENT_SHIPMENT_LINE_NUM,-1) = Nvl(doc_shipment_line_num,-1)
  AND Nvl(RELEASE_NUM,-1) = Nvl(doc_release_num,-1)
  AND header_interface_id =  header_intf_id;
  EXCEPTION
    WHEN No_Data_Found THEN
       p_error_code := 1;
       p_error_message := 'Cannot derive wms_interface_transaction_id (No Data found) with params ';
       p_error_message :=  p_error_message || ' header_interface_id: ' || header_intf_id || ' item: ' || item || 'item_revision: ' || item_rev;
    WHEN OTHERS THEN
      p_error_code := 2;
      p_error_message := 'Error in deriving wms_interface_transaction_id  with params ';
      p_error_message :=  p_error_message || ' header_interface_id: ' || header_intf_id || ' item: ' || item || 'item_revision: ' || item_rev;
      p_error_message :=  p_error_message || ' doc_num: ' || doc_num || ' doc_rev_num: ' || doc_rev_num || 'doc_line_num: ' || doc_line_num;
      p_error_message :=  p_error_message || ' doc_shipment_line_num: ' || doc_shipment_line_num || ' doc_release_num: ' || doc_release_num;
END derive_interface_id_for_wms;
  END POS_ASN_XML;


/
