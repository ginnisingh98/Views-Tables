--------------------------------------------------------
--  DDL for Package RCV_TRANSACTIONS_INTERFACE_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRANSACTIONS_INTERFACE_SV1" AUTHID CURRENT_USER AS
/* $Header: RCVTIS2S.pls 120.0.12010000.3 2012/11/18 03:19:19 liayang ship $*/


 /* INVCONV, Punit Kumar, ROI convergence */
 /* Defining global variables */
   g_ret_sts_success     CONSTANT VARCHAR2(1)           := 'S';
   g_ret_sts_error       CONSTANT VARCHAR2(1)           := 'E';
   g_ret_sts_unexp_error CONSTANT VARCHAR2(1)           := 'U';

/*Exception definitions */
   g_exc_error                    EXCEPTION;
   g_exc_unexpected_error         EXCEPTION;

/*INVCONV , Introduced the following record type*/
  TYPE attributes_record_type IS RECORD (
      inventory_item_id           RCV_TRANSACTIONS_INTERFACE.item_id%Type,
      transaction_quantity	  RCV_TRANSACTIONS_INTERFACE.quantity%Type,
      transaction_unit_of_measure RCV_TRANSACTIONS_INTERFACE.unit_of_measure%Type,
      secondary_quantity	  RCV_TRANSACTIONS_INTERFACE.Secondary_quantity%Type,
      secondary_unit_of_measure	  RCV_TRANSACTIONS_INTERFACE.Secondary_UNIT_OF_MEASURE%Type,
      secondary_uom_code	  RCV_TRANSACTIONS_INTERFACE.secondary_uom_code%TYPE,
      to_organization_id	  RCV_TRANSACTIONS_INTERFACE.to_organization_id%Type,
      error_record		  RCV_SHIPMENT_OBJECT_SV.ErrorRecType) ;


/*===========================================================================
  PROCEDURE NAME:	validate_quantity_shipped()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_quantity_shipped
              (X_quantity_shipped_record		IN OUT	NOCOPY rcv_shipment_line_sv.quantity_shipped_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_quantity_invoiced()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_quantity_invoiced
              (x_quantity_invoiced_record		IN OUT	NOCOPY rcv_shipment_line_sv.quantity_invoiced_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_uom()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_uom
              (x_uom_record		IN OUT	NOCOPY rcv_shipment_line_sv.quantity_shipped_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_item()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_item
              (x_item_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.item_id_record_type,
	       x_auto_transact_code     IN      rcv_transactions_interface.auto_transact_code%type);
/*===========================================================================
  PROCEDURE NAME:	validate_item_description()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_item_description
              (x_item_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.item_id_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_substitute_item()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_substitute_item
              (x_sub_item_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.sub_item_id_record_type);

/*===========================================================================
  PROCEDURE NAME:	validate_item_revision()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_item_revision
              (x_item_revision_record		IN OUT	NOCOPY rcv_shipment_line_sv.item_id_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_freight_carrier()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_freight_carrier
              (x_freight_carrier_record		IN OUT	NOCOPY rcv_shipment_line_sv.freight_carrier_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_subinventory()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       gkellner       03/25/97   Created
===========================================================================*/

 PROCEDURE validate_subinventory
             (x_subinventory_record		IN OUT	NOCOPY rcv_shipment_line_sv.subinventory_record_type);

/*===========================================================================
  PROCEDURE NAME:	validate_po_lookup_code()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       gkellner       03/25/97   Created
===========================================================================*/

 PROCEDURE validate_po_lookup_code
             (x_po_lookup_code_record IN OUT	NOCOPY
				rcv_shipment_line_sv.po_lookup_code_record_type);

/*===========================================================================
  PROCEDURE NAME:	validate_person()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       gkellner       03/25/97   Created
===========================================================================*/

 PROCEDURE validate_employee
             (x_employee_record		IN OUT	NOCOPY rcv_shipment_line_sv.employee_record_type);

/*===========================================================================
  PROCEDURE NAME:	validate_location()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       gkellner       03/25/97   Created
===========================================================================*/

 PROCEDURE validate_location
             (x_location_record		IN OUT	NOCOPY rcv_shipment_line_sv.location_record_type);

/*===========================================================================
  PROCEDURE NAME:	validate_locator()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       gkellner       03/25/97   Created
===========================================================================*/

 PROCEDURE validate_locator
             (x_locator_record		IN OUT	NOCOPY rcv_shipment_line_sv.locator_record_type);

 /*===========================================================================
  PROCEDURE NAME:	validate_project_locator()

  DESCRIPTION:   This procedure is used to validate project enabled locator for bug 13844195

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Liang Yang       11/16/12   Created
===========================================================================*/

 PROCEDURE validate_project_locator
             (x_locator_record   IN OUT NOCOPY rcv_shipment_line_sv.locator_record_type);

/*===========================================================================
  PROCEDURE NAME:	validate_tax_code()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_tax_code
              (x_tax_name_record			IN OUT	NOCOPY rcv_shipment_line_sv.tax_name_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_asl()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_asl
              (x_asl_record		IN OUT	NOCOPY rcv_shipment_line_sv.ref_integrity_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_cum_quantity_shipped()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_cum_quantity_shipped
              (x_cum_quantity_record		IN OUT	NOCOPY rcv_shipment_line_sv.cum_quantity_record_type);
/*===========================================================================
  PROCEDURE NAME:	validate_ref_integ()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       DFong       09/24/96   Created
===========================================================================*/

 PROCEDURE validate_ref_integ
              (x_ref_integrity_rec		IN OUT	NOCOPY rcv_shipment_line_sv.ref_integrity_record_type,
               V_header_record                  IN      rcv_shipment_header_sv.headerrectype);

/*===========================================================================
  PROCEDURE NAME:	validate_country_of_origin()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       FRKHAN       12/18/98   Created
===========================================================================*/

 PROCEDURE validate_country_of_origin
	(x_country_of_origin_record IN OUT NOCOPY rcv_shipment_line_sv.country_of_origin_record_type);

/* <Consigned Inventory Pre-Processor FPI START> */
/*==================================================================

  PROCEDURE NAME:	validate_consigned_po

  DESCRIPTION: 		Reject ASBN transaction if it's a shipment against
			Consigned PO by checking CONSIGNED_FLAG in
			PO_LINE_LOCATIONS

  PARAMETERS:		x_consigned_po_rec IN OUT NOCOPY
			rcv_shipment_line_sv.po_line_location_id_rtype

  DESIGN
  REFERENCES:

  CHANGE
  HISTORY:	 	Created		27-SEPTEMBER-02	DXIE

=======================================================================*/
 PROCEDURE validate_consigned_po
	(x_consigned_po_rec	IN OUT NOCOPY	rcv_shipment_line_sv.po_line_location_id_rtype);

/*==================================================================

  PROCEDURE NAME:	validate_consumption_po

  DESCRIPTION: 		Reject ASN, ASBN or Receipt transactions against
			Consumption PO by checking CONSIGNED_CONSUMPTION_FLAG
			in PO_HEADERS

  PARAMETERS:		x_consumption_po_rec	IN OUT NOCOPY
			rcv_shipment_line_sv.document_num_record_type

  DESIGN
  REFERENCES:

  CHANGE
  HISTORY:	 	Created		27-SEPTEMBER-02	DXIE

=======================================================================*/
 PROCEDURE validate_consumption_po
	(x_consumption_po_rec	IN OUT NOCOPY	rcv_shipment_line_sv.document_num_record_type);

/*==================================================================

  PROCEDURE NAME:	validate_consumption_release

  DESCRIPTION: 		Reject ASN, ASBN or Receipt transactions against
			Consumption Release by checking CONSIGNED_CONSUMPTION_FLAG
			in PO_RELEASES

  PARAMETERS:		x_consumption_release_rec	IN OUT NOCOPY
			rcv_shipment_line_sv.release_id_record_type

  DESIGN
  REFERENCES:

  CHANGE
  HISTORY:	 	Created		27-SEPTEMBER-02	DXIE

=======================================================================*/
 PROCEDURE validate_consumption_release
	(x_consumption_release_rec	IN OUT NOCOPY	rcv_shipment_line_sv.release_id_record_type);
/*<Consigned Inventory Pre-Processor FPI END>*/

/*===========================================================================

    PROCEDURE
     VALIDATE_SECONDARY_PARAMETERS

    DESCRIPTION

        For Dual UOM controlled items validate the secondary UOM code and
        Secondary UOM. Derive them if either/both are not specified.
  	   For  Receipt if secondary quantity is there then it will validate it
        (will do the deviation check for it )else it will derive it.

     DESIGN REFERENCES:
     http://files.oraclecorp.com/content/AllPublic/Workspaces/
     Inventory%20Convergence-Public/Design/Oracle%20Purchasing/TDD/PO_ROI_TDD.zip

   MODIFICATION HISTORY
   10-AUG-2004  Punit Kumar 	Created

=======================================================================*/

Procedure VALIDATE_SECONDARY_PARAMETERS(
   p_api_version	         IN  	NUMBER,
   p_init_msg_lst	         IN  	VARCHAR2,
   x_att_rec               IN OUT NOCOPY RCV_TRANSACTIONS_INTERFACE_SV1.attributes_record_type,
   x_return_status         OUT 	 NOCOPY	VARCHAR2,
   x_msg_count             OUT 	 NOCOPY	NUMBER,
   x_msg_data        	   OUT 	 NOCOPY	VARCHAR2,
   p_transaction_id        IN        NUMBER);        /*BUG#10380635 */
/*END INVCONV*/

END RCV_TRANSACTIONS_INTERFACE_SV1;




/
