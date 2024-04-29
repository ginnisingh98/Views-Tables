--------------------------------------------------------
--  DDL for Package RCV_CORRECTION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_CORRECTION_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTXCOS.pls 115.4 2004/03/19 03:03:05 wkunz ship $*/

/*===========================================================================
  PROCEDURE NAME: post_query()

  DESCRIPTION:
	This is the wrapper procedure for the Enter Corrections post query
	logic.

  USAGE:
	POST_QUERY ( x_transaction_id                IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_organization_id               IN NUMBER,
                         x_hazard_class_id               IN NUMBER,
                         x_un_number_id                  IN NUMBER,
                         x_shipment_header_id            IN NUMBER,
                         x_shipment_line_id              IN NUMBER,
                         x_po_line_location_id           IN NUMBER,
                         x_po_line_id                    IN NUMBER,
                         x_po_header_id                  IN NUMBER,
                         x_po_release_id                 IN NUMBER,
                         x_item_id                       IN NUMBER,
                         x_transaction_date              IN DATE,
                         x_creation_date                 IN DATE,
                         x_location_id                   IN NUMBER,
                         x_subinventory                  IN VARCHAR2,
                         x_destination_type_code         IN VARCHAR2,
                         x_destination_type_dsp          IN VARCHAR2,
                         x_final_dest_type_code         OUT VARCHAR2,
                         x_final_dest_type_dsp          OUT VARCHAR2,
                         x_final_location_id            OUT NUMBER,
                         x_final_subinventory           OUT VARCHAR2,
                         x_destination_context          OUT VARCHAR2,
                         x_job_schedule_dsp             OUT VARCHAR2,
                         x_op_seq_num_dsp               OUT VARCHAR2,
                         x_department_code              OUT VARCHAR2 ,
                         x_production_line_dsp          OUT VARCHAR2,
                         x_bom_resource_id              OUT NUMBER,
                         x_final_deliver_to_person_id   OUT NUMBER,
                         x_final_deliver_to_location_id OUT NUMBER,
                         x_person                       OUT VARCHAR2,
                         x_location                     OUT VARCHAR2,
                         x_hazard_class                 OUT VARCHAR2,
                         x_un_number                    OUT VARCHAR2,
                         x_locator_type                 OUT VARCHAR2 ,
                         x_count                        OUT NUMBER ,
                         x_locator_id                   OUT NUMBER ,
                         x_available_qty                OUT NUMBER,
                         x_tolerable_qty                OUT NUMBER ,
                         x_uom                          OUT VARCHAR2,
                         x_count_po_distribution        OUT NUMBER );

  PARAMETERS:

  DESIGN REFERENCES: Generic

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
	24-MAY-95	Sanjay Kothary	Created
===========================================================================*/

        /*
         * BUG NO 782779.
         * We select the packing_slip for the block rcv_transaction
         * in the Enter Corrections form from the rcv_shipment_lines.
        */

PROCEDURE  POST_QUERY (  x_transaction_id                IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_organization_id               IN NUMBER,
                         x_hazard_class_id               IN NUMBER,
                         x_un_number_id                  IN NUMBER,
                         x_shipment_line_id              IN NUMBER,
                         x_po_line_location_id           IN NUMBER,
                         x_rma_line_id 		         IN NUMBER,
			 x_parent_transaction_type	 IN VARCHAR2,
			 x_grand_parent_id		 IN NUMBER,

                         x_source_document_code          IN VARCHAR2,
			 x_destination_type_code         IN VARCHAR2,
                         x_lpn_id                        IN VARCHAR2,
                         x_transfer_lpn_id               IN VARCHAR2,
                         x_po_type                       IN VARCHAR2,

                         x_hazard_class                 OUT NOCOPY VARCHAR2,
                         x_un_number                    OUT NOCOPY VARCHAR2,
                         x_max_positive_qty          IN OUT NOCOPY NUMBER,
                         x_max_negative_qty          IN OUT NOCOPY NUMBER ,
			 x_max_tolerable_qty	     IN OUT NOCOPY NUMBER,
                         x_packing_slip                 OUT NOCOPY VARCHAR2,
                         x_max_supply_qty               OUT NOCOPY NUMBER,

			 x_parent_transaction_type_dsp  OUT NOCOPY VARCHAR2,
			 x_destination_type_dsp         OUT NOCOPY VARCHAR2,
                         x_license_plate_number         OUT NOCOPY VARCHAR2,
                         x_transfer_license_plate_num   OUT NOCOPY VARCHAR2,

                         x_ordered_uom               IN OUT NOCOPY VARCHAR2,
                         x_secondary_ordered_uom     IN OUT NOCOPY VARCHAR2,
                         x_order_type                IN OUT NOCOPY VARCHAR2
                         );

END RCV_CORRECTION_SV;

 

/
