--------------------------------------------------------
--  DDL for Package Body POS_CREATE_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_CREATE_ASN" AS
/* $Header: POSASNTB.pls 120.3 2006/01/30 10:46:08 shgao noship $*/

PROCEDURE create_asn_iface(
		P_GROUP_ID	        IN NUMBER,
		P_LAST_UPDATED_BY   	IN NUMBER,
		P_LAST_UPDATE_LOGIN     IN NUMBER,
		P_CREATED_BY            IN NUMBER,
		P_SHIPMENT_NUM          IN VARCHAR2,
		P_VENDOR_NAME           IN VARCHAR2,
                P_VENDOR_ID  		IN NUMBER,
		P_VENDOR_SITE_CODE      IN VARCHAR2,
		P_VENDOR_SITE_ID            IN NUMBER,
		P_BILL_OF_LADING            IN VARCHAR2,
		P_PACKING_SLIP              IN VARCHAR2,
		P_SHIPPED_DATE              IN VARCHAR2,
		P_FREIGHT_CARRIER_CODE      IN VARCHAR2,
		P_EXPECTED_RECEIPT_DATE     IN VARCHAR2,
		P_NUM_OF_CONTAINERS         IN NUMBER,
		P_WAYBILL_AIRBILL_NUM       IN VARCHAR2,
		P_COMMENTS   			IN VARCHAR2,
		P_PACKAGING_CODE            IN VARCHAR2,
		P_CARRIER_METHOD            IN VARCHAR2,
		P_CARRIER_EQUIPMENT         IN VARCHAR2,
		P_SPECIAL_HANDLING_CODE     IN VARCHAR2,
        	P_INVOICE_NUM               IN VARCHAR2,
        	P_INVOICE_DATE              IN VARCHAR2,
        	P_TOTAL_INVOICE_AMOUNT      IN NUMBER,
		P_PAYMENT_TERMS_ID		IN NUMBER,
		P_HAZARD_CODE               IN VARCHAR2,
		P_FREIGHT_TERMS             IN VARCHAR2,
		P_FREIGHT_AMOUNT            IN NUMBER,
        	P_CURRENCY_CODE			IN VARCHAR2,
        	P_CURRENCY_CONVERSION_TYPE 	IN VARCHAR2,
        	P_CURRENCY_CONVERSION_RATE  IN NUMBER,
        	P_CURRENCY_CONVERSION_DATE  IN VARCHAR2,
        	p_gross_weight				IN NUMBER,
        	p_gross_weight_uom          IN VARCHAR2 ,
        	p_net_weight                IN NUMBER ,
       	 	p_net_weight_uom            IN VARCHAR2 ,
        	p_tar_weight                IN NUMBER ,
        	p_tar_weight_uom            IN VARCHAR2 ,
        	p_freight_bill_num          IN VARCHAR2 ,

		/* rcv transaction interface parameters */
		P_QUANTITY_T                IN NUMBER,
		P_UNIT_OF_MEASURE_T         IN VARCHAR2,
		P_ITEM_ID_T                 IN NUMBER,
		P_ITEM_REVISION_T           IN VARCHAR2,
		P_SHIP_TO_LOCATION_CODE_T   IN VARCHAR2,
		P_SHIP_TO_ORG_ID_T     		IN NUMBER,
		P_PO_HEADER_ID_T            IN NUMBER,
		P_PO_REVISION_NUM_T         IN NUMBER,
		P_PO_LINE_ID_T              IN NUMBER,
		P_PO_LINE_LOCATION_ID_T     IN NUMBER,
		P_PO_UNIT_PRICE_T           IN NUMBER,
		P_PACKING_SLIP_T            IN VARCHAR2,
		P_SHIPPED_DATE_T            IN VARCHAR2,
		P_EXPECTED_RECEIPT_DATE_T   IN VARCHAR2,
		P_NUM_OF_CONTAINERS_T       IN NUMBER,
		P_VENDOR_ITEM_NUM_T         IN VARCHAR2,
		P_VENDOR_LOT_NUM_T          IN VARCHAR2,
		P_COMMENTS_T                IN VARCHAR2,
		P_TRUCK_NUM_T               IN VARCHAR2,
		P_CONTAINER_NUM_T           IN VARCHAR2,
		P_DELIVER_TO_LOCATION_CODE_T IN VARCHAR2,
		P_BARCODE_LABEL_T           IN VARCHAR2,
		P_COUNTRY_OF_ORIGIN_CODE_T  IN VARCHAR2,
                P_DOCUMENT_LINE_NUM_T             IN NUMBER,
                P_DOCUMENT_SHIPMENT_LINE_NUM_T    IN NUMBER,
        	p_error_code                IN OUT NOCOPY VARCHAR2,
        	p_error_message             IN OUT NOCOPY VARCHAR2,
        	P_PAYMENT_TERMS_NAME   	IN VARCHAR2,
        	P_OPERATING_UNIT_ID  	IN NUMBER,
        	P_PO_RELEASE_ID    	IN NUMBER,
		p_tax_amount		IN VARCHAR2,
		p_license_plate_number in varchar2,
		p_lpn_group_id in number) --mji
IS

 x_count        		number  := 0;
 h_count        		number  := 0;
 x_pla_count        		number  := 0;
 x_progress			varchar2(3) := '000';
 l_org_id			number;
 l_iface_txn_id 		number  := 0; /* RTI.INTERFACE_TRANSACTION_ID */
 l_header_id    		number  := 0; /* RHI.HEADER_INTERFACE_ID */
 l_transaction_type 		varchar2(15);
 l_auto_transact_code 		varchar2(15);
 l_quantity_invoiced		number := 0;
 l_buyer_id             number;
 l_ItemType   VARCHAR2(100) := 'POSASNIB';
 l_ItemKey    VARCHAR2(100);
 k            NUMBER        := 1;
 x_note_count        number  := 0;
 l_primary_unit_of_measure 	 varchar2(25);
 l_item_id                       NUMBER;
 l_item_revision		 PO_LINES_ALL.ITEM_REVISION%TYPE;
 l_converted_qty                 NUMBER;
 x_ship_to_location_id           NUMBER;
 l_supplier_username		 VARCHAR2(80);
 l_supplier_displayname          VARCHAR2(100);

 cursor dis_details_cur(linelocid in number) is
	select WIP_ENTITY_ID          ,
           WIP_LINE_ID            ,
           WIP_OPERATION_SEQ_NUM  ,
           PO_DISTRIBUTION_ID
	from   po_distributions
	where  line_location_id = linelocid;

 dis_details_rec 	dis_details_cur%rowtype;

BEGIN

  x_progress := '010' ;

  -- Get org context for the PO
  BEGIN
  select org_id
  into   l_org_id
  from   po_headers_all
  where  po_header_id = p_po_header_id_t;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  raise_application_error(-20001,'Org Id not found for ' || to_char(p_po_header_id_t));
  END;

  /* We need to set the org context because the user could
  ** create a single ASN out of multiple POs each belonging
  ** to different operating unit. We get some stuff from
  ** some striped tables later so we set the org context.
  */

  if l_org_id is not null then
  	fnd_client_info.set_org_context(to_char(l_org_id));
  end if;

  x_progress := '015' ;

  select ship_to_location_id
  into x_ship_to_location_id
  from po_line_locations_all
  where line_location_id = P_PO_LINE_LOCATION_ID_T;

  /* Insert into RHI only if a record for the same ship_to_org
  and ship_to_location is not already inserted for the group id  */
  /* Commented out ship_to_location */

  select count(*)
  into x_count
  from rcv_headers_interface
  where ship_to_organization_id = p_ship_to_org_id_t
  --and   location_id  = x_ship_to_location_id
  and vendor_id = P_VENDOR_ID
  and vendor_site_id = P_VENDOR_SITE_ID
  and   group_id    = p_group_id
  and shipment_num = p_shipment_num;


  if x_count < 1 then

    x_progress := '020' ;

	SELECT RCV_HEADERS_INTERFACE_S.NEXTVAL
	INTO   l_header_id
	from   dual;

    x_progress := '030' ;

     insert into rcv_headers_interface
       (HEADER_INTERFACE_ID             ,
        GROUP_ID                        ,
        PROCESSING_STATUS_CODE          ,
--        PROCESSING_REQUEST_ID           ,
        RECEIPT_SOURCE_CODE             ,
        TRANSACTION_TYPE                ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_LOGIN               ,
        CREATION_DATE                   ,
        CREATED_BY                      ,
--        LOCATION_CODE                   ,
--        LOCATION_ID                     ,
        SHIP_TO_ORGANIZATION_ID         ,
        VENDOR_ID                       ,
        VENDOR_SITE_ID                  ,
        SHIPPED_DATE                    ,
        ASN_TYPE                        ,
        SHIPMENT_NUM                    ,
        EXPECTED_RECEIPT_DATE           ,
        PACKING_SLIP                    ,
        WAYBILL_AIRBILL_NUM             ,
        BILL_OF_LADING                  ,
        FREIGHT_CARRIER_CODE            ,
        FREIGHT_TERMS                   ,
        NUM_OF_CONTAINERS               ,
        COMMENTS                        ,
        CARRIER_METHOD                  ,
        CARRIER_EQUIPMENT               ,
        PACKAGING_CODE                  ,
        SPECIAL_HANDLING_CODE           ,
        INVOICE_NUM                     ,
        INVOICE_DATE                    ,
        TOTAL_INVOICE_AMOUNT            ,
        FREIGHT_AMOUNT                  ,
        TAX_NAME                        ,
        TAX_AMOUNT                      ,
        CURRENCY_CODE                   ,
        CONVERSION_RATE_TYPE            ,
        CONVERSION_RATE                 ,
        CONVERSION_RATE_DATE            ,
        PAYMENT_TERMS_ID                ,
        PAYMENT_TERMS_NAME              ,
        VALIDATION_FLAG
       )
     VALUES
       (
        l_header_id                     ,
        P_GROUP_ID                      ,
        'PENDING'                       ,
--        P_GROUP_ID                      ,
        'VENDOR'                        ,
        'NEW'                           ,
        sysdate              ,
        P_LAST_UPDATED_BY               ,
        P_LAST_UPDATE_LOGIN             ,
        sysdate                 ,
        P_CREATED_BY                    ,
 --       P_SHIP_TO_LOCATION_CODE_T       ,
 --       x_ship_to_location_id           ,
        P_SHIP_TO_ORG_ID_T              ,
        P_VENDOR_ID                     ,
        P_VENDOR_SITE_ID                ,
        to_date(P_SHIPPED_DATE,'YYYY-MM-DD'),
        decode(P_INVOICE_NUM, NULL, 'ASN', 'ASBN'),
        P_SHIPMENT_NUM                 ,
        to_date(P_EXPECTED_RECEIPT_DATE,'YYYY-MM-DD'),
        P_PACKING_SLIP                 ,
        P_WAYBILL_AIRBILL_NUM          ,
        P_BILL_OF_LADING               ,
        P_FREIGHT_CARRIER_CODE         ,
        P_FREIGHT_TERMS                ,
        P_NUM_OF_CONTAINERS            ,
        P_COMMENTS                     ,
        P_CARRIER_METHOD               ,
        P_CARRIER_EQUIPMENT            ,
        P_PACKAGING_CODE               ,
        P_SPECIAL_HANDLING_CODE        ,
        P_INVOICE_NUM                  ,
        to_date(P_INVOICE_DATE,'YYYY-MM-DD'),
        P_TOTAL_INVOICE_AMOUNT         ,
        P_FREIGHT_AMOUNT               ,
        null                           , /* TAX_NAME */
        p_tax_amount                   , /* TAX_AMOUNT */
        P_CURRENCY_CODE                ,
        P_CURRENCY_CONVERSION_TYPE     ,
        P_CURRENCY_CONVERSION_RATE     ,
        to_date(P_CURRENCY_CONVERSION_DATE,'YYYY-MM-DD'),
        P_PAYMENT_TERMS_ID ,
        P_PAYMENT_TERMS_NAME ,
        'Y' );

   ELSE

     SELECT header_interface_id
       into l_header_id
       from rcv_headers_interface
       where ship_to_organization_id = p_ship_to_org_id_t
       --and   location_id  = x_ship_to_location_id
       and vendor_id = P_VENDOR_ID
       and vendor_site_id = P_VENDOR_SITE_ID
       and   group_id    = p_group_id
       and shipment_num = p_shipment_num;
 end if;

    x_progress := '040' ;


	/* Get the values of some of the columns which were not
    ** passed as parameters
    */

	-- Get transaction type
	/* We need to join with po_location_associations because
	** if the PO is for OSP and if the WIP job has two
	** OSP operations in sequence then we want the first OSP
	** vendor to actually ship the goods to the second OSA
	** vendor but the receipt and delivery should be recorded
	** in the buyer's system. In order for the receipt and
	** delivery to be done automatically for such cases we
	** need to have a transaction type of RECEIVE instead of
	** SHIP with a auto transact code of DELIVER.
	*/

	select count(*)
	into   x_pla_count
	from   po_location_associations PLA
	where  pla.location_id =
               (select location_id from hr_locations_all
               where location_code = P_SHIP_TO_LOCATION_CODE_T) and
               pla.vendor_id is not null and pla.vendor_site_id is not null;

    x_progress := '050' ;
	if x_pla_count > 0 then
		l_transaction_type   := 'RECEIVE';
		l_auto_transact_code := 'DELIVER';

		/* Since we are here we know that we are OSP type
		** of a PO. So we will have only one distribution
		** To be on the safe side lets get the wip details
		** through a cursor.
		*/

    	x_progress := '060' ;
		open dis_details_cur(p_po_line_location_id_t);
		fetch dis_details_cur into dis_details_rec;
		close dis_details_cur;

		/* We don't close the dis_details_cur cursor over here because
		** this procedure will be called for each shipment. Each shipment
		** could have multiple distributions.
		** For the purpose of setting the auto_transact_code and
		** transaction_type, one record is sufficient but we need to
		** start the WIP workflow for each distribution.
		*/

	else
    	x_progress := '070' ;
		l_transaction_type := 'SHIP';
		l_auto_transact_code := 'SHIP';
	end if;

	-- Get quantity invoiced
    x_progress := '080' ;
	l_quantity_invoiced := POS_QUANTITIES_S.get_invoice_qty
						(P_PO_LINE_LOCATION_ID_T,
                             P_UNIT_OF_MEASURE_T,
                             P_ITEM_ID_T,
                             P_QUANTITY_T);

    x_progress := '090' ;
    select RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL
	into l_iface_txn_id
	from dual;

    x_progress := '100' ;

    select unit_meas_lookup_code,
           item_id,
	   item_revision
    into l_primary_unit_of_measure,
         l_item_id,
	 l_item_revision
    from po_lines_all
    where po_line_id = P_PO_LINE_ID_T;

    po_uom_s.uom_convert(P_QUANTITY_T, P_UNIT_OF_MEASURE_T, l_item_id,
                          l_primary_unit_of_measure, l_converted_qty);



     insert into rcv_transactions_interface
         ( INTERFACE_TRANSACTION_ID     ,
           HEADER_INTERFACE_ID          ,
           GROUP_ID                     ,
           TRANSACTION_TYPE             ,
           TRANSACTION_DATE             ,
           PROCESSING_STATUS_CODE       ,
           PROCESSING_MODE_CODE         ,
           TRANSACTION_STATUS_CODE      ,
           AUTO_TRANSACT_CODE           ,
           RECEIPT_SOURCE_CODE          ,
           SOURCE_DOCUMENT_CODE         ,
           PO_HEADER_ID                 ,
           PO_LINE_ID                   ,
           PO_LINE_LOCATION_ID          ,
           QUANTITY                     ,
           PRIMARY_QUANTITY             ,
           UNIT_OF_MEASURE              ,
           PRIMARY_UNIT_OF_MEASURE      ,
           LAST_UPDATE_DATE             ,
           LAST_UPDATED_BY              ,
           LAST_UPDATE_LOGIN            ,
           CREATION_DATE                ,
           CREATED_BY                   ,
           ITEM_ID                      ,
	   ITEM_REVISION		,
           EXPECTED_RECEIPT_DATE        ,
           COMMENTS                     ,
           BARCODE_LABEL                ,
           CONTAINER_NUM                ,
           COUNTRY_OF_ORIGIN_CODE       ,
           VENDOR_ITEM_NUM              ,
           VENDOR_LOT_NUM               ,
           TRUCK_NUM                    ,
           NUM_OF_CONTAINERS            ,
           PACKING_SLIP                 ,
           VALIDATION_FLAG              ,
           WIP_ENTITY_ID                ,
           WIP_LINE_ID                  ,
           WIP_OPERATION_SEQ_NUM        ,
           PO_DISTRIBUTION_ID           ,
           DOCUMENT_LINE_NUM            ,
           DOCUMENT_SHIPMENT_LINE_NUM   ,
           VENDOR_ID                    ,
           VENDOR_SITE_ID               ,
           QUANTITY_INVOICED            ,
           SHIP_TO_LOCATION_CODE        ,
           SHIP_TO_LOCATION_ID          ,
           PO_RELEASE_ID,
           license_plate_number,
           lpn_group_id)
        values
         ( l_iface_txn_id           ,
           l_header_id              ,
           P_GROUP_ID               ,
           l_transaction_type       ,
           sysdate       ,
           'PENDING' ,
           'BATCH'   ,
           'RUNNING',
           l_auto_transact_code     ,
           'VENDOR'    ,
           'PO'   ,
           P_PO_HEADER_ID_T          ,
           P_PO_LINE_ID_T            ,
           P_PO_LINE_LOCATION_ID_T   ,
           P_QUANTITY_T              ,
           l_converted_qty           ,
           P_UNIT_OF_MEASURE_T       ,
           l_primary_unit_of_measure ,
           sysdate       ,
           P_LAST_UPDATED_BY        ,
           P_LAST_UPDATE_LOGIN      ,
           sysdate		    ,
           P_CREATED_BY             ,
           P_ITEM_ID_T              ,
	   l_item_revision	    ,
           to_date(P_EXPECTED_RECEIPT_DATE_T,'YYYY-MM-DD')  ,
           P_COMMENTS_T               ,
           P_BARCODE_LABEL_T          ,
           P_CONTAINER_NUM_T          ,
           P_COUNTRY_OF_ORIGIN_CODE_T ,
           P_VENDOR_ITEM_NUM_T        ,
           P_VENDOR_LOT_NUM_T         ,
           P_TRUCK_NUM_T              ,
           P_NUM_OF_CONTAINERS_T      ,
           P_PACKING_SLIP_T           ,
           'Y'                      ,
           dis_details_rec.WIP_ENTITY_ID          ,
           dis_details_rec.WIP_LINE_ID            ,
           dis_details_rec.WIP_OPERATION_SEQ_NUM  ,
           dis_details_rec.PO_DISTRIBUTION_ID     ,
          P_DOCUMENT_LINE_NUM_T                  ,
           P_DOCUMENT_SHIPMENT_LINE_NUM_T         ,
           P_VENDOR_ID                      ,
           P_VENDOR_SITE_ID                 ,
          l_quantity_invoiced               ,
          P_SHIP_TO_LOCATION_CODE_T         ,
          x_ship_to_location_id             ,
          P_PO_RELEASE_ID,
          p_license_plate_number,
          p_lpn_group_id);



  /* See comments above related to WIP jobs and auto_transact_code */
    x_progress := '110' ;
	OPEN dis_details_cur(p_po_line_location_id_t);
 	LOOP
    	x_progress := '120' ;
		fetch dis_details_cur into dis_details_rec;
		exit when dis_details_cur%notfound;

  		/* the wip workflow needs to be called only for wip jobs */
   		IF dis_details_rec.wip_entity_id is not null THEN
    		x_progress := '130' ;
    		wip_osp_shp_i_wf.StartWFProcToAnotherSupplier
       		( dis_details_rec.po_distribution_id         ,
         		P_QUANTITY_T                ,
         		P_UNIT_OF_MEASURE_T         ,
         		to_date(P_SHIPPED_DATE,'YYYY-MM-DD'),
         		to_date(P_EXPECTED_RECEIPT_DATE,'YYYY-MM-DD'),
         		P_PACKING_SLIP_T             ,
         		P_WAYBILL_AIRBILL_NUM		,
         		p_bill_of_lading             ,
         		p_packaging_code             ,
         		p_num_of_containers_t        ,
         		p_gross_weight               ,
         		p_gross_weight_uom           ,
         		p_net_weight                 ,
         		p_net_weight_uom             ,
         		p_tar_weight                 ,
         		p_tar_weight_uom             ,
         		null,                      /* p_hazard_class */
         		null,                      /* p_hazard_code  */
         		null,                      /* p_hazard_desc  */
         		p_special_handling_code      ,
         		p_freight_carrier_code      ,
         		p_freight_terms      		,
         		p_carrier_equipment         ,
         		p_carrier_method             ,
         		p_freight_bill_num           ,
         		null,                      /*p_receipt_num     */
         		null                       /* p_ussgl_txn_code */
       		);
   		END IF;
  	END LOOP;
    x_progress := '140' ;
	CLOSE dis_details_cur;

/* at this stage we have reached end of pos_create_asn procedure
 * if no error has happened till now then we should send the
 * asn creation notification to the buyer
*/

select agent_id
  into   l_buyer_id
  from   po_headers_all
  where  po_header_id = p_po_header_id_t;

     select count(*)
     into x_note_count
     from rcv_transactions_interface
     where header_interface_id = l_header_id;

     k := k + x_note_count;

    WF_DIRECTORY.GetUserName(  'FND_USR',
                           P_LAST_UPDATED_BY,
                           l_supplier_username,
                           l_supplier_displayname);

/*  Commenting out the Workflow Call since Create ASN will use POSASNNB
for sending notifications to Buyers

     l_ItemKey := 'POS_CREATE_ASN' || to_char(l_header_id) || '-' || to_char(k);

     wf_engine.createProcess(ItemType  => l_ItemType,
                             ItemKey   => l_ItemKey,
                             Process   => 'BUYER_NOTIFICATION');

     wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                 itemkey  => l_ItemKey,
                                 aname    => 'BUYER_USER_ID',
                                 avalue   => l_buyer_id);

     wf_engine.SetItemAttrText(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'SHIPMENT_NUM',
                               avalue   => P_SHIPMENT_NUM);

     wf_engine.SetItemAttrDate(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'SHIP_DATE',
                               avalue   => to_date(P_SHIPPED_DATE,'YYYY-MM-DD'));

     wf_engine.SetItemAttrDate(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'EXPECTED_RECEIPT_DATE',
                               avalue   => to_date(P_EXPECTED_RECEIPT_DATE,'YYYY-MM-DD'));

     wf_engine.SetItemAttrNumber(itemtype => l_ItemType,
                                 itemkey  => l_ItemKey,
                                 aname    => 'SUPPLIER_ID',
                                 avalue   => P_VENDOR_ID);

     wf_engine.SetItemAttrText(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'SUPPLIER',
                               avalue   => P_VENDOR_NAME);

     wf_engine.SetItemAttrText(itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'SUPPLIER_USER_NAME',
                               avalue   => l_supplier_username);

     wf_engine.StartProcess(ItemType   => l_ItemType,
                            ItemKey    => l_ItemKey );

  */

 EXCEPTION

  WHEN OTHERS THEN

    p_ERROR_CODE := 'Y';
    p_ERROR_MESSAGE := x_progress||':'||sqlcode ||':'||sqlerrm(sqlcode);

END create_asn_iface;

FUNCTION getAvailableShipmentQuantity (p_lineLocationID IN NUMBER)
RETURN NUMBER IS
    v_availableQuantity NUMBER;
    v_tolerableQuantity NUMBER;
    v_unitOfMeasure     VARCHAR2(25);
    x_progress          VARCHAR2(3);

BEGIN

    x_progress := '001';

    getShipmentQuantity( p_lineLocationID,
                         v_availableQuantity,
                         v_tolerableQuantity,
                         v_unitOfMeasure);

    RETURN v_availableQuantity;

EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('getAvailableShipmentQuantity', x_progress, sqlcode);
      RAISE;

END getAvailableShipmentQuantity;

FUNCTION getTolerableShipmentQuantity(p_lineLocationID IN NUMBER)
RETURN NUMBER IS
    v_availableQuantity NUMBER;
    v_tolerableQuantity NUMBER;
    v_unitOfMeasure     VARCHAR2(25);
    x_progress          VARCHAR2(3);

BEGIN

    x_progress := '001';

    getShipmentQuantity( p_lineLocationID,
                         v_availableQuantity,
                         v_tolerableQuantity,
                         v_unitOfMeasure);

    RETURN v_tolerableQuantity;

EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('getTolerableShipmentQuantity', x_progress, sqlcode);
      RAISE;

END getTolerableShipmentQuantity;

PROCEDURE getShipmentQuantity ( p_line_location_id      IN  NUMBER,
                                p_available_quantity IN OUT NOCOPY NUMBER,
                                p_tolerable_quantity IN OUT NOCOPY NUMBER,
                                p_unit_of_measure    IN OUT NOCOPY VARCHAR2) IS

x_progress                      VARCHAR2(3)     := NULL;
x_quantity_ordered              NUMBER          := 0;
x_quantity_received             NUMBER          := 0;
x_quantity_shipped              NUMBER          := 0;
x_interface_quantity            NUMBER          := 0; /* in primary_uom */
x_quantity_cancelled            NUMBER          := 0;
x_qty_rcv_tolerance             NUMBER          := 0;
x_qty_rcv_exception_code        VARCHAR2(26);
x_po_uom                        VARCHAR2(26);
x_item_id                       NUMBER;
x_primary_uom                   VARCHAR2(26);
x_interface_qty_in_po_uom       NUMBER          := 0;

BEGIN

   x_progress := '005';


   /*
   ** Get PO quantity information.
   */

   SELECT nvl(pll.quantity, 0),
          nvl(pll.quantity_received, 0),
          nvl(pll.quantity_shipped, 0),
          nvl(pll.quantity_cancelled,0),
          1 + (nvl(pll.qty_rcv_tolerance,0)/100),
          pll.qty_rcv_exception_code,
          pl.item_id,
          pl.unit_meas_lookup_code
   INTO   x_quantity_ordered,
          x_quantity_received,
          x_quantity_shipped,
          x_quantity_cancelled,
          x_qty_rcv_tolerance,
          x_qty_rcv_exception_code,
          x_item_id,
          x_po_uom
   FROM   po_line_locations_all pll,
          po_lines_all pl
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;


   x_progress := '010';

   /*
   ** Get any unprocessed receipt or match transaction against the
   ** PO shipment. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

   SELECT nvl(sum(primary_quantity),0),
          min(primary_unit_of_measure)
   INTO   x_interface_quantity,
          x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  processing_status_code = 'PENDING'
   AND    transaction_type IN ('RECEIVE', 'MATCH','CORRECT','SHIP')
   AND    po_line_location_id = p_line_location_id;

   IF (x_interface_quantity = 0) THEN

        /*
        ** There is no unprocessed quantity. Simply set the
        ** x_interface_qty_in_po_uom to 0. There is no need for uom
        ** conversion.
        */

        x_interface_qty_in_po_uom := 0;

   ELSE

        /*
        ** There is unprocessed quantity. Convert it to the PO uom
        ** so that the available quantity can be calculated in the PO uom
        */

        x_progress := '015';
        po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
                             x_po_uom, x_interface_qty_in_po_uom);

   END IF;

   /*
   ** Calculate the quantity available to be received.
   */

   p_available_quantity := x_quantity_ordered - x_quantity_received - x_quantity_shipped -
                           x_quantity_cancelled - x_interface_qty_in_po_uom;

   /*
   ** p_available_quantity can be negative if this shipment has been over
   ** received. In this case, the available quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_available_quantity < 0) THEN
        p_available_quantity := 0;
   END IF;

   /*
   ** Calculate the maximum quantity that can be received allowing for
   ** tolerance.
   */

   p_tolerable_quantity := (x_quantity_ordered * x_qty_rcv_tolerance) -
                            x_quantity_received - x_quantity_shipped - x_quantity_cancelled -
                            x_interface_qty_in_po_uom;

   /*
   ** p_tolerable_quantity can be negative if this shipment has been over
   ** received. In this case, the tolerable quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_tolerable_quantity < 0) THEN
        p_tolerable_quantity := 0;
   END IF;

   /*
   ** Return the PO unit of measure
   */
   p_unit_of_measure := x_po_uom;

EXCEPTION

   WHEN OTHERS THEN

        po_message_s.sql_error('getShipmentQuantity', x_progress, sqlcode);

        RAISE;

END getShipmentQuantity;



/* procedure added to get converted quantity based on new UOM */

PROCEDURE getConvertedQuantity ( p_line_location_id      IN  NUMBER,
                                 p_available_quantity    IN  NUMBER,
                                 p_new_unit_of_measure   IN  VARCHAR2,
                                 p_converted_quantity  OUT NOCOPY NUMBER ) IS

/* p_available_quantity  is in new UOM */

x_converted_quantity            NUMBER          := 0;
x_po_uom                        VARCHAR2(26);
x_item_id                       NUMBER;

BEGIN

SELECT    pl.item_id,
          pl.unit_meas_lookup_code
   INTO   x_item_id,
          x_po_uom
   FROM   po_line_locations_all pll,
          po_lines_all pl
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;


IF (x_po_uom = p_new_unit_of_measure)  THEN

   p_converted_quantity := p_available_quantity;

ELSE

   po_uom_s.uom_convert(p_available_quantity, p_new_unit_of_measure, x_item_id,
                             x_po_uom, x_converted_quantity);

   p_converted_quantity := x_converted_quantity;

END IF;


END getConvertedQuantity;

/* end of procedure added to get converted quantity based on new UOM */


PROCEDURE callPreProcessor(p_groupId in number) IS

l_org_id number;
l_po_header_id number;

begin

	-- All PO's for a particular group id should have the same org_id
	select max(po_header_id)
	into l_po_header_id
	from rcv_transactions_interface rti, rcv_headers_interface rhi
	where rhi.group_id = p_groupId
	and rhi.header_interface_id = rti.header_interface_id
	group by rti.header_interface_id;

	select org_id
	into l_org_id
	from po_headers_all
	where po_header_id = l_po_header_id;

	fnd_client_info.set_org_context(to_char(l_org_id));

	rcv_shipment_object_sv.create_object (p_groupId);


exception

	when others then
		raise;

end callPreProcessor;


PROCEDURE VALIDATE_FREIGHT_CARRIER (
        p_organization_id IN NUMBER,
        p_freight_code    IN VARCHAR2,
        p_count           OUT NOCOPY NUMBER
) IS

 l_count number;

begin

  select count(*)
  into l_count
  from ORG_FREIGHT
  where
  freight_code = p_freight_code and
  organization_id = p_organization_id;

  p_count := l_count;

end VALIDATE_FREIGHT_CARRIER;



END POS_CREATE_ASN;


/
