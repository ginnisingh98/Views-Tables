--------------------------------------------------------
--  DDL for Package RCV_TRANSACTIONS_INTERFACE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRANSACTIONS_INTERFACE_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTISVS.pls 120.0.12000000.1 2007/01/16 23:32:46 appldev ship $*/

/* ksareddy - Porting changes by bao in branch for caching sob */
 x_set_of_books_id NUMBER := NULL;


/*===========================================================================
  PACKAGE NAME:		rcv_transactions_interface_sv

  DESCRIPTION:          Contains the server side APIs high-level record types
			and record type variables.

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                DFong

  PROCEDURES/FUNCTIONS:	create()

===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	derive_shipment_line()

  DESCRIPTION:          Derives the rcv_transactions_interface row by first
			getting id values and then retrieving rows from po_line_locations
			until the quantity_shipped is consumed.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/
 PROCEDURE derive_shipment_line (X_cascaded_table		IN OUT	NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
				 n				IN OUT	NOCOPY binary_integer,
                                 temp_cascaded_table            IN OUT  NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
                                 X_header_record                IN      rcv_shipment_header_sv.headerrectype);

/*===========================================================================
  PROCEDURE NAME:	default_shipment_line()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/
 PROCEDURE default_shipment_line (X_cascaded_table		IN OUT	NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
				  n				IN 	binary_integer,
				  X_header_id			IN	rcv_headers_interface.header_interface_id%type,
                                  X_header_record               IN      rcv_shipment_header_sv.headerrectype);

/*===========================================================================
  PROCEDURE NAME:	validate_shipment_line()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_shipment_line (X_cascaded_table		IN OUT	NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
				   n				IN	binary_integer,
				   X_asn_type			IN	rcv_headers_interface.asn_type%type,
                                   X_header_record              IN      rcv_shipment_header_sv.headerrectype);

/*===========================================================================
  PROCEDURE NAME:	get_location_id()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE get_location_id (X_location_id_record		IN OUT	NOCOPY rcv_shipment_object_sv.location_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	get_locator_id()

  Bug 724495, add procedure get_locator_id to derive locator_id from locator

  CHANGE HISTORY:       NWang       09/3/98   Created
===========================================================================*/

 PROCEDURE get_locator_id (X_locator_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.locator_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	get_category_id()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

-- PROCEDURE get_category_id (X_category_id_record		IN	rcv_shipment_line_sv.category_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	get_routing_header_id()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE get_routing_header_id
                (X_routing_header_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.routing_header_id_rec_type);
/*===========================================================================
  PROCEDURE NAME:	get_routing_step_id()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE get_routing_step_id
                (X_routing_step_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.routing_step_id_rec_type);

/*===========================================================================
  PROCEDURE NAME:	get_reason_id()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE get_reason_id
                (X_reason_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.reason_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	default_item_revision()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE default_item_revision
              (x_item_revision_record		IN OUT	NOCOPY rcv_shipment_line_sv.item_id_record_type);

 PROCEDURE check_date_tolerance (expected_receipt_date in date,
                                 promised_date         in date,
                                 days_early_receipt_allowed in number,
                                 days_late_receipt_allowed in number,
                                 receipt_days_exception_code in out NOCOPY varchar2);

 PROCEDURE check_shipto_enforcement (po_ship_to_location_id in number,
                                     asn_ship_to_location_id in number,
                                     enforce_ship_to_location_code in out NOCOPY varchar2);

 PROCEDURE EXCHANGE_SUB_ITEM (V_cascaded_table IN OUT  NOCOPY rcv_shipment_object_sv.cascaded_trans_tab_type,
                              n                IN      binary_integer);

 FUNCTION convert_into_correct_qty(source_qty in number,
                                   source_uom in varchar2,
                                   item_id    in number,
                                   dest_uom   in varchar2)
          RETURN NUMBER;


/*===========================================================================
  PROCEDURE NAME:	get_po_header_id ()

  DESCRIPTION:   	This procedure obtains the po_header_id
			given the document number.

  PARAMETERS:		x_doc_num	IN OUT VARCHAR2
			x_header_id	IN     NUMBER

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG		 12/6/96  Created
===========================================================================*/
procedure get_po_header_id (X_po_header_id_record	IN OUT	NOCOPY rcv_shipment_line_sv.document_num_record_type);

/*===========================================================================
  PROCEDURE NAME:	get_item_id ()

  DESCRIPTION:

  PARAMETERS:		X_item_id_record


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG	 	12/6/96		Created
===========================================================================*/
 -- moved here from POXPOLIB.pls to avoid compatibility issues with REL 11

  PROCEDURE get_item_id(x_item_id_record    IN OUT NOCOPY  rcv_shipment_line_sv.item_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	get_sub_item_id ()

  DESCRIPTION:

  PARAMETERS:		X_sub_item_id_record


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG	 	12/6/96		Created
===========================================================================*/

 -- moved here from POXPOLIB.pls to avoid compatibility issues with REL 11

  PROCEDURE get_sub_item_id(x_sub_item_id_record    IN OUT NOCOPY  rcv_shipment_line_sv.sub_item_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	get_po_line_id ()

  DESCRIPTION:

  PARAMETERS:		X_po_line_id_record


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	DFONG	 	12/6/96		Created
===========================================================================*/

 -- moved here from POXPOLIB.pls to avoid compatibility issues with REL 11

  PROCEDURE get_po_line_id(x_po_line_id_record    IN OUT NOCOPY  rcv_shipment_line_sv.po_line_id_record_type);



-- API call done by EDI to obtain the org_id
 PROCEDURE get_org_id_from_hr_loc_id (p_hr_location_id IN NUMBER, x_organization_id OUT NOCOPY NUMBER);

 END RCV_TRANSACTIONS_INTERFACE_SV;

 

/
