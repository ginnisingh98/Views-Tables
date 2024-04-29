--------------------------------------------------------
--  DDL for Package INV_UI_RCV_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_UI_RCV_LOVS" AUTHID CURRENT_USER AS
/* $Header: INVRCVLS.pls 120.7.12010000.2 2011/01/10 10:39:45 schiluve ship $ */

TYPE t_genref IS REF CURSOR;

--      Name: GET_PO_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_po_number   which restricts LOV SQL to the user input text
--                                e.g.  FG%
--       p_manual_po_num_type  NUMERIC or ALPHANUMERIC
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_po_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns PO number for a given org
--

/* R12 MOAC
   Removed parameter p_manual_po_num_type from procedures -
    GET_PO_LOV
    GET_RECEIPT_NUMBER_LOV
    GET_RECEIPT_NUMBER_INSPECT_LOV
    GET_DOC_LOV
*/

PROCEDURE GET_PO_LOV(x_po_num_lov OUT NOCOPY t_genref,
		     p_organization_id IN NUMBER,
		     p_po_number IN VARCHAR2,
		     p_mobile_form IN VARCHAR2,
		     p_shipment_header_id IN VARCHAR2);


--      Name: GET_PO_LINE_NUM_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_po_header_id      which restricts LOV SQL to the PO
--       p_po_line_num which restricts the LOV to the user input text.
--
--      Output parameters:
--       x_po_line_num_lov returns LOV rows as reference cursor
--
--      Functions: This API returns PO Line numbers for a given PO
--
PROCEDURE GET_PO_LINE_NUM_LOV(x_po_line_num_lov OUT NOCOPY t_genref,
			      p_organization_id IN NUMBER,
			      p_po_header_id IN NUMBER,
			      p_mobile_form IN VARCHAR2,
			      p_po_line_num IN VARCHAR2);


--      Name: GET_PO_RELEASE_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_po_header_id      which restricts LOV SQL to the PO
--       p_po_release_num which restricts the LOV to the user input text.
--
--      Output parameters:
--       x_po_release_num_lov returns LOV rows as reference cursor
--
--      Functions: This API returns PO Release numbers for a given PO
--
PROCEDURE GET_PO_RELEASE_LOV(x_po_release_num_lov OUT NOCOPY t_genref,
			     p_organization_id IN NUMBER,
			     p_po_header_id IN NUMBER,
			     p_mobile_form IN VARCHAR2,
			     p_po_release_num IN VARCHAR2);




--      Name: GET_LOCATION_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_location_code   which restricts LOV SQL to the user input text
--                                e.g.  1-1%
--
--      Output parameters:
--       x_location      returns LOV rows as reference cursor
--
--      Functions: This API is to returns location for given org


PROCEDURE get_location_lov (x_location OUT NOCOPY t_genref,
			    p_organization_id IN NUMBER,
			    p_location_code IN VARCHAR2);



--      Name: get_freight_carrier_lov
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_freight_carrier  which restricts LOV SQL to the user input text
--
--
--      Output parameters:
--        x_freight_carrier    returns LOV rows as reference cursor
--
--      Functions: This API returns freight carrier for given org


PROCEDURE get_freight_carrier_lov (x_freight_carrier OUT NOCOPY t_genref,
				   p_organization_id IN NUMBER,
				   p_freight_carrier IN VARCHAR2);



--      Name: GET_SHIPMENT_NUM_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_shipment_num   which restricts LOV SQL to the user input text
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_shipment_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns Shipment number for a given org
--


PROCEDURE GET_SHIPMENT_NUM_LOV(x_shipment_num_lov OUT NOCOPY t_genref,
			       p_organization_id IN NUMBER,
			       p_shipment_num IN VARCHAR2,
			       p_mobile_form IN VARCHAR2,
			       p_po_header_id IN VARCHAR2);


--      Name: GET_REQ_NUM_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_requisition_num   which restricts LOV SQL to the user input text
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_requisition_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns Shipment number for a given org
--                 Also it returns an ASN numner for ASN receipt


PROCEDURE GET_REQ_NUM_LOV(x_requisition_num_lov OUT NOCOPY t_genref,
			  p_organization_id IN NUMBER,
			  p_requisition_num IN VARCHAR2,
			  p_mobile_form IN VARCHAR2
			  );

--  Almost same as GET_SHIPMENT_NUM_LOV
--  but for getting pack slip number

PROCEDURE  GET_PACK_SLIP_NUM_LOV(x_pack_slip_num_lov OUT NOCOPY t_genref,
				 p_organization_id IN NUMBER,
				 p_pack_slip_num IN VARCHAR2,
				 p_po_header_id IN VARCHAR2);


PROCEDURE GET_CARRIER(x_getcarrierLOV OUT NOCOPY t_genref,
		      p_FromOrganization_Id IN NUMBER,
		      p_ToOrganization_Id IN NUMBER,
		      p_carrier IN VARCHAR2);


-- LOV for the possible receipt numbers that can be used.
PROCEDURE GET_RECEIPT_NUMBER_LOV(x_getRcptNumLOV OUT NOCOPY t_genref,
				 p_organization_id IN NUMBER,
				 p_receipt_number IN VARCHAR2);

-- LOV for the possible quality codes for mobile inspection form
PROCEDURE GET_QUALITY_CODES_LOV(
 x_getQltyCodesLOV 	OUT NOCOPY t_genref
,p_quality_code         IN  VARCHAR2);

-- LOV for the possible reason codes for mobile inspection form
PROCEDURE GET_REASON_CODES_LOV(
 x_getReasonCodesLOV 	OUT NOCOPY t_genref
,p_reason_code         IN  VARCHAR2);

-- LOV for the possible reason codes for mobile inspection form
-- Procedure overloaded for Transaction Reason Security build. 4505091, nsrivast
PROCEDURE GET_REASON_CODES_LOV(
 x_getReasonCodesLOV 	OUT NOCOPY t_genref
,p_reason_code         IN  VARCHAR2
,p_txn_type_id IN VARCHAR2 );

-- LOV for the possible receipt numbers for inspection
PROCEDURE get_receipt_number_inspect_lov
  (x_getRcptNumLOV      OUT NOCOPY t_genref
   , p_organization_id    IN  NUMBER
   , p_receipt_number     IN  VARCHAR2);

-- LOV for RMA
PROCEDURE get_rma_lov
  (x_getRMALOV	OUT NOCOPY t_genref,
   p_organization_id 	IN  NUMBER,
   p_rma_number IN VARCHAR,
   p_mobile_form IN VARCHAR2);

--
-- Bug 2192815
-- Uom LOV for Expense Items
--

PROCEDURE get_uom_lov_expense(x_uoms OUT NOCOPY t_genref,
                          p_organization_id IN NUMBER,
                          p_item_id IN NUMBER,
                          p_uom_type IN NUMBER,
                          p_uom_code IN VARCHAR2,
                          p_primary_uom_code IN VARCHAR2);

/* Direct Shipping */
-- LOV for the Location Code
PROCEDURE get_locationcode_lov (
	   x_locationcode OUT NOCOPY t_genref
   ,  p_location_code IN VARCHAR2);

-- LOV for the Location
PROCEDURE get_directship_location_lov (
	   x_location OUT NOCOPY t_genref
  	,  p_organization_id IN NUMBER
	,  p_location_code IN VARCHAR2);

/* Direct Shipping */
-- Bug 2008025
-- Lov for Docs

--      Name: GET_DOC_LOV
--
--      Input parameters:
--       p_Organization_Id   which restricts LOV SQL to current org
--       p_doc_number   which restricts LOV SQL to the user input text
--                                e.g.  FG%
--       p_manual_po_num_type  NUMERIC or ALPHANUMERIC
--       p_mobile_form   which mobile form this LOV is for (RECEIPT or DELIVER)
--                       SQL query will be different for these forms
--
--      Output parameters:
--       x_doc_num_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns PO number for a given org
--

PROCEDURE GET_DOC_LOV(x_doc_num_lov OUT NOCOPY t_genref,
		      p_organization_id IN NUMBER,
		      p_doc_number IN VARCHAR2,
		      p_mobile_form IN VARCHAR2,
		      p_shipment_header_id IN VARCHAR2,
		      p_inventory_item_id  IN VARCHAR2,
		      p_item_description   IN VARCHAR2,
		      p_doc_type           IN VARCHAR2,
		      p_vendor_prod_num    IN  VARCHAR2);


PROCEDURE GET_PO_LINE_ITEM_NUM_LOV(x_po_line_num_lov OUT NOCOPY t_genref,
			      p_organization_id IN NUMBER,
			      p_po_header_id IN NUMBER,
			      p_mobile_form IN VARCHAR2,
			      p_po_line_num IN VARCHAR2,
                              p_inventory_item_id IN VARCHAR2);

PROCEDURE get_job_lov (x_job_lov OUT NOCOPY t_genref,
		       p_organization_id IN NUMBER,
		       p_po_header_id IN NUMBER,
		       p_po_line_id IN NUMBER,
		       p_item_id IN NUMBER,
		       p_Job IN VARCHAR2,
                       p_po_release_id IN NUMBER DEFAULT NULL,  --Bug #3883926
		       p_shipment_header_id IN NUMBER DEFAULT NULL );  -- Added for bug 9360553


PROCEDURE GET_PO_RELEASE_ITEM_LOV(x_po_release_num_lov OUT NOCOPY t_genref,
				  p_organization_id IN NUMBER,
				  p_po_header_id IN NUMBER,
				  p_mobile_form IN VARCHAR2,
				  p_po_release_num IN VARCHAR2,
				  p_item_id IN NUMBER);

PROCEDURE GET_ITEM_LOV_RECEIVING (
x_Items                               OUT NOCOPY t_genref,
p_Organization_Id                     IN NUMBER,
p_Concatenated_Segments               IN VARCHAR2,
p_poHeaderID                          IN VARCHAR2,
p_poReleaseID                         IN VARCHAR2,
p_poLineID                            IN VARCHAR2,
p_shipmentHeaderID                    IN VARCHAR2,
p_oeOrderHeaderID                     IN VARCHAR2,
p_reqHeaderID                         IN VARCHAR2,
p_projectId                           IN VARCHAR2,
p_taskId                              IN VARCHAR2,
p_pjmorg                              IN VARCHAR2,
p_crossreftype                        IN VARCHAR2,
p_from_lpn_id                         IN VARCHAR2 default NULL
)
;

PROCEDURE GET_ITEM_LOV_INVTXN (
x_Items                               OUT NOCOPY t_genref,
p_Organization_Id                     IN NUMBER   default null ,
p_Concatenated_Segments               IN VARCHAR2 default null )
;

PROCEDURE GET_LPN_LOV_INSPECT
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_orgid    IN   NUMBER ,
   p_projid   IN   NUMBER ,
   p_taskid   IN   NUMBER )
;

PROCEDURE GET_LPN_LOV_INVTXN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_orgid    IN   NUMBER )
;

PROCEDURE GET_LPN_LOV_PJM
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_orgid    IN   NUMBER )
;

PROCEDURE GET_COUNTRY_LOV
  (x_country_lov OUT NOCOPY t_genref,
    p_country IN VARCHAR2 )
;

FUNCTION get_conversion_rate_expense(p_from_uom_code    varchar2,
                                     p_organization_id  NUMBER,
                                     p_item_id          NUMBER,
                                     p_primary_uom_code varchar2)
RETURN VARCHAR2;

-- get_hr_hz_locations_lov procedure will return all HR and HZ Active Locations.
-- Added as part of eIB Build; Bug# 4348541
PROCEDURE get_hr_hz_locations_lov(
  x_location_codes OUT NOCOPY t_genref,
  p_location_code IN VARCHAR2);

-- Added for BUG 4309432
PROCEDURE GET_ACTRJTQTY_LOV
  (x_actrjtqty_lov OUT NOCOPY t_genref,
   p_deliver_type IN VARCHAR2);

--Added for Bug 4498173
PROCEDURE GET_INV_ITEM_LOV_RECEIVING
(
	x_Items				OUT NOCOPY t_genref,
	p_Organization_Id		IN NUMBER,
	p_Concatenated_Segments		IN VARCHAR2,
	p_receiptNum			IN VARCHAR2,
	p_poHeaderID			IN VARCHAR2,
	p_poReleaseID			IN VARCHAR2,
	p_poLineID			IN VARCHAR2,
	p_shipmentHeaderID		IN VARCHAR2,
	p_oeOrderHeaderID		IN VARCHAR2,
	p_reqHeaderID			IN VARCHAR2,
	p_shipmentHeaderReceipt		IN VARCHAR2
);

--Added for bug 5246626
PROCEDURE GET_RCV_SHP_FLEX_DETAILS
     ( p_shipment_num IN VARCHAR2
     , p_orgid    IN   NUMBER
     , x_attribute1           OUT    NOCOPY VARCHAR2
     , x_attribute2           OUT    NOCOPY VARCHAR2
     , x_attribute3           OUT    NOCOPY VARCHAR2
     , x_attribute4           OUT    NOCOPY VARCHAR2
     , x_attribute5           OUT    NOCOPY VARCHAR2
     , x_attribute6           OUT    NOCOPY VARCHAR2
     , x_attribute7           OUT    NOCOPY VARCHAR2
     , x_attribute8           OUT    NOCOPY VARCHAR2
     , x_attribute9           OUT    NOCOPY VARCHAR2
     , x_attribute10          OUT    NOCOPY VARCHAR2
     , x_attribute11          OUT    NOCOPY VARCHAR2
     , x_attribute12          OUT    NOCOPY VARCHAR2
     , x_attribute13          OUT    NOCOPY VARCHAR2
     , x_attribute14          OUT    NOCOPY VARCHAR2
     , x_attribute15          OUT    NOCOPY VARCHAR2
     , x_val_attribute1       OUT    NOCOPY VARCHAR2
     , x_val_attribute2       OUT    NOCOPY VARCHAR2
     , x_val_attribute3       OUT    NOCOPY VARCHAR2
     , x_val_attribute4       OUT    NOCOPY VARCHAR2
     , x_val_attribute5       OUT    NOCOPY VARCHAR2
     , x_val_attribute6       OUT    NOCOPY VARCHAR2
     , x_val_attribute7       OUT    NOCOPY VARCHAR2
     , x_val_attribute8       OUT    NOCOPY VARCHAR2
     , x_val_attribute9       OUT    NOCOPY VARCHAR2
     , x_val_attribute10      OUT    NOCOPY VARCHAR2
     , x_val_attribute11      OUT    NOCOPY VARCHAR2
     , x_val_attribute12      OUT    NOCOPY VARCHAR2
     , x_val_attribute13      OUT    NOCOPY VARCHAR2
     , x_val_attribute14      OUT    NOCOPY VARCHAR2
     , x_val_attribute15      OUT    NOCOPY VARCHAR2
     , x_attribute_category   OUT    NOCOPY VARCHAR2
     , x_concatenated_val     OUT    NOCOPY VARCHAR2
      )
   ;

END INV_UI_RCV_LOVS;

/
