--------------------------------------------------------
--  DDL for Package POS_CREATE_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_CREATE_ASN" AUTHID CURRENT_USER AS
/* $Header: POSASNTS.pls 120.2 2006/01/30 10:45:36 shgao noship $*/

PROCEDURE create_asn_iface(
		P_GROUP_ID			IN NUMBER,
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
		P_COMMENTS   	        	IN VARCHAR2,
		P_PACKAGING_CODE            IN VARCHAR2,
		P_CARRIER_METHOD            IN VARCHAR2,
		P_CARRIER_EQUIPMENT         IN VARCHAR2,
		P_SPECIAL_HANDLING_CODE     IN VARCHAR2,
       		P_INVOICE_NUM               IN VARCHAR2,
       		P_INVOICE_DATE              IN VARCHAR2,
       		P_TOTAL_INVOICE_AMOUNT      IN NUMBER,
		P_PAYMENT_TERMS_ID			IN NUMBER,
		P_HAZARD_CODE               IN VARCHAR2,
		P_FREIGHT_TERMS             IN VARCHAR2,
		P_FREIGHT_AMOUNT            IN NUMBER,
       		P_CURRENCY_CODE				IN VARCHAR2,
       		P_CURRENCY_CONVERSION_TYPE 	IN VARCHAR2,
       		P_CURRENCY_CONVERSION_RATE  IN NUMBER,
       		P_CURRENCY_CONVERSION_DATE  IN VARCHAR2,
        	p_gross_weight              IN NUMBER,
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
	p_error_code                IN OUT NOCOPY  VARCHAR2,
       	p_error_message             IN OUT NOCOPY  VARCHAR2,
        P_PAYMENT_TERMS_NAME IN VARCHAR2,
        P_OPERATING_UNIT_ID  IN NUMBER,
  P_PO_RELEASE_ID   IN NUMBER,
  p_tax_amount		IN VARCHAR2,
  p_license_plate_number in varchar2 default null,
  p_lpn_group_id in number);

FUNCTION getAvailableShipmentQuantity(p_lineLocationID IN NUMBER) RETURN NUMBER;
FUNCTION getTolerableShipmentQuantity(p_lineLocationID IN NUMBER) RETURN NUMBER;
PROCEDURE getShipmentQuantity (	p_line_location_id      IN  NUMBER,
                          	p_available_quantity IN OUT NOCOPY NUMBER,
                          	p_tolerable_quantity IN OUT NOCOPY NUMBER,
                          	p_unit_of_measure    IN OUT NOCOPY VARCHAR2);

PROCEDURE getConvertedQuantity ( p_line_location_id      IN  NUMBER,
                                 p_available_quantity    IN  NUMBER,
                                 p_new_unit_of_measure   IN  VARCHAR2,
                                 p_converted_quantity  OUT NOCOPY NUMBER );



PROCEDURE callPreProcessor(p_groupId in number);

PROCEDURE VALIDATE_FREIGHT_CARRIER (
        p_organization_id IN NUMBER,
        p_freight_code    IN VARCHAR2,
        p_count           OUT NOCOPY NUMBER
);

END POS_CREATE_ASN;


 

/
