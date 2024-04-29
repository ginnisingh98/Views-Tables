--------------------------------------------------------
--  DDL for Package RCV_RETURN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_RETURN_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTXRES.pls 120.0.12010000.1 2008/07/24 14:38:18 appldev ship $*/

PROCEDURE  POST_QUERY (  x_transaction_id                IN NUMBER,
			 x_parent_transaction_type	 IN VARCHAR2,
                         x_destination_type_code         IN VARCHAR2,
                         x_organization_id               IN NUMBER,
                         x_wip_entity_id                 IN NUMBER,
                         x_wip_repetitive_schd_id        IN NUMBER,
                         x_wip_operation_seq_num         IN NUMBER,
                         x_wip_resource_seq_num          IN NUMBER,
                         x_wip_line_id                   IN NUMBER,
                         x_hazard_class_id               IN NUMBER,
                         x_un_number_id                  IN NUMBER,
                         x_primary_uom                   IN VARCHAR2,
                         x_transaction_uom               IN VARCHAR2,
                         x_primary_transaction_qty       IN NUMBER,
                         x_item_id                       IN NUMBER,
                         x_final_location_id             IN NUMBER,
                         x_receiving_location_id         IN NUMBER,
                         x_deliver_to_person_id          IN NUMBER,
                         x_vendor_id                     IN NUMBER,
                         x_subinventory                  IN VARCHAR2,

                         x_source_document_code          IN VARCHAR2,
                         --x_inspection_status_code        IN VARCHAR2,
                         x_secondary_ordered_uom         IN VARCHAR2,
                         x_lpn_id                        IN VARCHAR2,
                         x_transfer_lpn_id               IN VARCHAR2,
                         x_po_type_code                  IN VARCHAR2,
                         x_ordered_uom                   IN VARCHAR2,
                         x_customer_id                   IN VARCHAR2,

                         x_subinv_locator_type          OUT NOCOPY VARCHAR2,
                         x_final_location               OUT NOCOPY VARCHAR2,
                         x_receiving_location           OUT NOCOPY VARCHAR2,
                         x_person                       OUT NOCOPY VARCHAR2,
                         x_supply_qty                   OUT NOCOPY NUMBER,
                         x_wip_entity_name              OUT NOCOPY VARCHAR2,
                         x_operation_seq_num            OUT NOCOPY VARCHAR2,
                         x_department_code              OUT NOCOPY VARCHAR2,
                         x_line_code                    OUT NOCOPY VARCHAR2,
                         x_hazard_class                 OUT NOCOPY VARCHAR2,
                         x_un_number                    OUT NOCOPY VARCHAR2,
                         x_vendor_name                  OUT NOCOPY VARCHAR2,

                         x_parent_transaction_type_dsp  OUT NOCOPY VARCHAR2,
                         --x_inspection_status_dsp        OUT NOCOPY VARCHAR2,
                         x_destination_type_dsp         OUT NOCOPY VARCHAR2,
                         --x_primary_uom_class            OUT NOCOPY VARCHAR2,
                         x_transaction_uom_class        OUT NOCOPY VARCHAR2,
                         x_secondary_ordered_uom_out    OUT NOCOPY VARCHAR2,
                         x_license_plate_number         OUT NOCOPY VARCHAR2,
                         x_transfer_license_plate_num   OUT NOCOPY VARCHAR2,
                         x_order_type                   OUT NOCOPY VARCHAR2,
                         x_ordered_uom_out              OUT NOCOPY VARCHAR2,
                         x_customer                     OUT NOCOPY VARCHAR2

                         );

END RCV_RETURN_SV;

/
