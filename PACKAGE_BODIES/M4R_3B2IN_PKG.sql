--------------------------------------------------------
--  DDL for Package Body M4R_3B2IN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."M4R_3B2IN_PKG" AS
/* $Header: M4R3B2IB.pls 120.1 2005/11/03 05:36:28 amchaudh noship $ */

l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

-- Start of comments
--        API name         : RCV_TXN_INPROCESS
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Used in the inprocessing of the XGM for populating the RCV_TXN tables.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : None.
-- End of comments


 PROCEDURE RCV_TXN_INPROCESS
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
     p_vendor_id  OUT NOCOPY  NUMBER,
     p_vendor_site_id  OUT NOCOPY  NUMBER,
     p_ship_to_edi_location_code IN VARCHAR,
     p_ship_to_location_id OUT NOCOPY VARCHAR,
     p_error_code  OUT NOCOPY NUMBER,
     p_error_message OUT NOCOPY VARCHAR) IS
	l_count_num  NUMBER;
    x_ship_org_num NUMBER;
  BEGIN
    IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('------ Entering M4R_3B2IN_PKG.RCV_TXN_INPROCESS ------');
           cln_debug_pub.Add('Value of in Variables:');
           cln_debug_pub.Add('p_document_line_num:' ||p_document_line_num, 1);
           cln_debug_pub.Add('p_document_shipment_line_num:' ||p_document_shipment_line_num, 1);
	   cln_debug_pub.Add('p_release_num:' ||p_release_num, 1);
	   cln_debug_pub.Add('p_po_number:' ||p_po_number, 1);
	   cln_debug_pub.Add('p_supplier_code:' ||p_supplier_code, 1);
	   cln_debug_pub.Add('p_item_num:' ||p_item_num, 1);
	   cln_debug_pub.Add('p_supplier_item_num:' ||p_supplier_item_num, 1);
	   cln_debug_pub.Add('p_ship_to_edi_location_code:' ||p_ship_to_edi_location_code, 1);
    END IF;
   p_error_code := 0;
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
     nvl(msi.concatenated_segments, -99) = nvl(NVL(p_item_num, msi.concatenated_segments), -99) AND
     nvl(pol.VENDOR_PRODUCT_NUM, -99) = nvl(NVL(p_supplier_item_num, pol.VENDOR_PRODUCT_NUM), -99) AND
     pol.po_header_id =  poh.po_header_id AND
     pol.line_num = p_document_line_num AND
     pol.po_line_id = pll.po_line_id AND
     pll.shipment_num = p_document_shipment_line_num AND
     pll.ship_to_organization_id = msi.organization_id AND
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
     nvl(msi.concatenated_segments, -99) = nvl(NVL(p_item_num, msi.concatenated_segments), -99) AND
     nvl(pol.VENDOR_PRODUCT_NUM, -99) = nvl(NVL(p_supplier_item_num, pol.VENDOR_PRODUCT_NUM), -99) AND
     pol.po_header_id =  poh.po_header_id AND
     pol.line_num = p_document_line_num AND
     pol.po_line_id = pll.po_line_id AND
     pll.shipment_num = p_document_shipment_line_num AND
     pll.PO_RELEASE_ID = prl.PO_RELEASE_ID AND
     prl.release_num = p_release_num AND
     pll.ship_to_organization_id = msi.organization_id AND
     pol.item_id = msi.inventory_item_id (+);
    end if;
	   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add(' p_org_id:' ||  p_org_id, 1);
       END IF;
     select min(po_header_id)
     into p_po_header_id
     from po_headers_all
     where segment1 = p_po_number
     and org_id = p_org_id;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add(' p_po_header_id' || p_po_header_id, 1);
     END IF;
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
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add(' p_ship_to_org_id:' || p_ship_to_org_id, 1);
     END IF;
	 --- POS_ASN_XML.DERIVE_vendor_ID	 begins here
	 select
	 	poh.vendor_site_id,poh.vendor_id
	 into 	p_vendor_site_id, p_vendor_id
	 from
	 	po_headers_all poh
	 where
	    poh.po_header_id = p_po_header_id and
	    poh.segment1 =p_po_number;
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add(' p_vendor_site_id:' ||p_vendor_site_id, 1);
           cln_debug_pub.Add(' p_vendor_id:' ||p_vendor_id, 1);
     END IF;
	----ship to organisaction id

	 BEGIN
	      SELECT location_id
     	  INTO  p_ship_to_location_id
     	  FROM hr_locations
     	  WHERE ECE_TP_LOCATION_CODE = p_ship_to_edi_location_code;
	 EXCEPTION
	      WHEN no_data_found then
		  IF (l_Debug_Level <= 1) THEN
        	    	  cln_debug_pub.Add('No Data Found in the hr_locations table for p_ship_to_edi_location_code :'||p_ship_to_location_id, 1);
     		  END IF;
	 END;

	 IF (l_Debug_Level <= 1) THEN
        	  cln_debug_pub.Add('p_ship_to_location_id:' ||p_ship_to_location_id, 1);
         END IF;

     IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('------ Exiting M4R_3B2IN_PKG.RCV_TXN_INPROCESS ------');
     END IF;
   EXCEPTION
    WHEN OTHERS THEN
     p_error_code := 1;
     p_vendor_id := 0;
     p_vendor_site_id := 0;
     p_error_message := 'Exception in M4R_3B2IN_PKG.RCV_TXN_INPROCESS ';
end RCV_TXN_INPROCESS;



-- Start of comments
--        API name         : RCV_TXN_INPROCESS2
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Used in the inprocessing of the XGM for populating the RCV_TXN tables.
--        Version          : Current version         1.1
--                           Initial version         1.0
--        Notes            : None.
-- End of comments



PROCEDURE  RCV_TXN_INPROCESS2
   (p_po_header_id IN NUMBER,
   p_line_num IN NUMBER,
   p_document_shipment_line_num IN NUMBER,
   p_release_num IN NUMBER,
   p_item_id OUT NOCOPY NUMBER,
   p_item_num OUT NOCOPY VARCHAR,
   p_item_revision OUT NOCOPY VARCHAR,
   p_supplier_item_num OUT NOCOPY VARCHAR,
   p_ship_to_location_id IN OUT NOCOPY NUMBER,
   p_po_line_id OUT NOCOPY NUMBER,
   p_line_location_id OUT NOCOPY NUMBER,
   p_ship_to_org_id OUT NOCOPY NUMBER,
   p_po_release_id OUT NOCOPY NUMBER,
   p_uom_code IN VARCHAR,
   p_unit_of_measure OUT NOCOPY VARCHAR,
   p_error_code OUT NOCOPY NUMBER,
   p_error_message OUT NOCOPY VARCHAR) is
   x_po_num VARCHAR2(100);
   l_count NUMBER;
   x_ship_to_location_id NUMBER;
BEGIN
     IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('----- Entering M4R_3B2IN_PKG.RCV_TXN_INPROCESS2-----');
           cln_debug_pub.Add('Value of in Variables:');
           cln_debug_pub.Add('p_po_header_id:' ||p_po_header_id, 1);
           cln_debug_pub.Add('p_line_num:' ||p_line_num, 1);
           cln_debug_pub.Add('p_document_shipment_line_num:' ||p_document_shipment_line_num, 1);
           cln_debug_pub.Add('p_release_num :' || p_release_num , 1);
           cln_debug_pub.Add('p_ship_to_location_id:' ||p_ship_to_location_id, 1);
           cln_debug_pub.Add('p_uom_code:' ||p_uom_code, 1);
     END IF;

  p_error_code := 0;
  /* save the inbound value for ship_to_location_id for matching */
  x_ship_to_location_id := p_ship_to_location_id;

  select segment1 into x_po_num from po_headers_all where po_header_id=p_po_header_id;

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

  IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('p_item_id:' ||p_item_id, 1);
           cln_debug_pub.Add('p_item_num:' ||p_item_num, 1);
           cln_debug_pub.Add('p_item_revision:' ||p_item_revision, 1);
           cln_debug_pub.Add('p_supplier_item_num :' || p_supplier_item_num, 1);
           cln_debug_pub.Add('p_ship_to_location_id:' ||p_ship_to_location_id, 1);
           cln_debug_pub.Add('p_po_line_id:' ||p_po_line_id, 1);
           cln_debug_pub.Add('p_line_location_id :' || p_line_location_id, 1);
           cln_debug_pub.Add('p_ship_to_location_id:' ||p_ship_to_location_id, 1);
           cln_debug_pub.Add('p_po_release_id:' ||p_po_release_id, 1);
   END IF;


  /* now validate whether the ship_to_location_id derived from derive_location method
     is the same as the ship_to_location_id obtained from the PO Shipment */

   if (x_ship_to_location_id <> p_ship_to_location_id) then
      p_error_code := 1;
      p_error_message := 'Ship-to-location derived from EDI Location Code is different from';
      p_error_message := p_error_message || ' the Ship-to_location on PO Shipment';
      p_error_message := p_error_message || ' for PO Number ' || x_po_num;
      p_error_message := p_error_message || ', Line Number  ' || p_line_num;
      p_error_message := p_error_message || ', Shipment Number  ' || p_document_shipment_line_num;
   end if;


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

  else          /* l_count = 1*/

   select unit_of_measure
   into p_unit_of_measure
   from mtl_units_of_measure_tl
   where uom_code = p_uom_code
   and language = USERENV('LANG');

  end if;

  IF (l_Debug_Level <= 1) THEN
       cln_debug_pub.Add('----- Exiting M4R_3B2IN_PKG.RCV_TXN_INPROCESS2-----');
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
      p_error_message := p_error_message || ', UOM Code ' || p_uom_code;
      p_error_message := p_error_message || ' , and language ' || USERENV('LANG');
END RCV_TXN_INPROCESS2 ;



-- Start of comments
--        API name         : GET_VALUES_HEADER
--        Type             : Private
--        Pre-reqs         : None.
--        Function         : Used in the getting the values at the header level of the XGM.
--        Version          : Current version         1.0
--                           Initial version         1.0
--        Notes            : None.
-- End of comments

PROCEDURE GET_VALUES_HEADER
(p_header_interface_id IN NUMBER,
    p_ship_to_org_id OUT NOCOPY NUMBER,
    p_vendor_id OUT NOCOPY NUMBER,
    p_vendor_site_id OUT NOCOPY NUMBER,
    p_bill_of_lading OUT NOCOPY VARCHAR,
    p_waybill_airbill_num OUT NOCOPY VARCHAR,
	p_packing_slip OUT NOCOPY VARCHAR,
    p_error_code OUT NOCOPY NUMBER,
    p_error_message OUT NOCOPY VARCHAR
	) is
    x_ship_org_count NUMBER;
BEGIN

   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('----- Entering M4R_3B2IN_PKG.GET_VALUES_HEADER -----');
           cln_debug_pub.Add('Value of in Variables:');
           cln_debug_pub.Add('p_header_interface_id:' ||p_header_interface_id, 1);
   END IF;

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
     min(vendor_site_id),
	 max(bill_of_lading),
	 max(waybill_airbill_num),
	 max(packing_slip)
   into
     p_ship_to_org_id,
     p_vendor_id,
     p_vendor_site_id,
     p_bill_of_lading,
	 p_waybill_airbill_num,
	 p_packing_slip
   from
    rcv_transactions_interface
   where
     header_interface_id = p_header_interface_id;

   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('p_ship_to_org_id:' ||p_ship_to_org_id, 1);
           cln_debug_pub.Add('p_vendor_id:' ||p_vendor_id, 1);
           cln_debug_pub.Add('p_vendor_site_id:' ||p_vendor_site_id, 1);
   END IF;

   update rcv_headers_interface
   set vendor_id = p_vendor_id,
       vendor_site_id = p_vendor_site_id,
       ship_to_organization_id = p_ship_to_org_id,
	   bill_of_lading = p_bill_of_lading,
       waybill_airbill_num =p_waybill_airbill_num,
       packing_slip = p_packing_slip
   where header_interface_id = p_header_interface_id;

   update rcv_transactions_interface
   set bill_of_lading = p_bill_of_lading,
       waybill_airbill_num =p_waybill_airbill_num,
       packing_slip = p_packing_slip
   where header_interface_id = p_header_interface_id;

   elsif (x_ship_org_count > 1) then
     p_error_code := 1;
     p_error_message := 'ASN contains lines from Multiple Ship To Organizations';
   else
     p_error_code := 2;
     p_error_message := 'No matching Ship To Organization found';
   end if;

   IF (l_Debug_Level <= 1) THEN
           cln_debug_pub.Add('----- Exiting M4R_3B2IN_PKG.GET_VALUES_HEADER -----');
   END IF;
EXCEPTION
     WHEN OTHERS THEN
     p_error_code := 3;
     p_error_message := 'Error in GET_VALUES_HEADER procedure for header_interface_id: ' || p_header_interface_id;
END GET_VALUES_HEADER;


END M4R_3B2IN_PKG;

/
