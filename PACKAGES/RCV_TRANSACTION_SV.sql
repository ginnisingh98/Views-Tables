--------------------------------------------------------
--  DDL for Package RCV_TRANSACTION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_TRANSACTION_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTXPQS.pls 115.6 2002/11/23 00:54:16 sbull ship $*/

/*===========================================================================
  PROCEDURE NAME:	POST_QUERY

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
--Bug#2109106. This function has been overloaded.
PROCEDURE POST_QUERY ( x_transaction_id                IN NUMBER,
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
                       x_vendor_id                     IN NUMBER,
                       x_item_id                       IN NUMBER,
                       x_item_revision                 IN VARCHAR2,
                       x_transaction_date              IN DATE,
                       x_creation_date                 IN DATE,
                       x_location_id                   IN NUMBER,
                       x_subinventory                  IN VARCHAR2,
                       x_destination_type_code         IN VARCHAR2,
                       x_destination_type_dsp          IN VARCHAR2,
                       x_primary_uom                   IN VARCHAR2,
                       x_routing_id                    IN NUMBER,
                       x_po_distribution_id           IN OUT NOCOPY NUMBER,
                       x_final_dest_type_code         IN OUT NOCOPY VARCHAR2,
                       x_final_dest_type_dsp          IN OUT NOCOPY VARCHAR2,
                       x_final_location_id            IN OUT NOCOPY NUMBER,
                       x_final_subinventory           IN OUT NOCOPY VARCHAR2,
                       x_destination_context          IN OUT NOCOPY VARCHAR2,
                       x_wip_entity_id                IN OUT NOCOPY NUMBER,
                       x_wip_line_id                  IN OUT NOCOPY NUMBER,
                       x_wip_repetitive_schedule_id   IN OUT NOCOPY NUMBER,
                       x_outside_processing           IN OUT NOCOPY VARCHAR2,
                       x_job_schedule_dsp             IN OUT NOCOPY VARCHAR2,
                       x_op_seq_num_dsp               IN OUT NOCOPY VARCHAR2,
                       x_department_code              IN OUT NOCOPY VARCHAR2 ,
                       x_production_line_dsp          IN OUT NOCOPY VARCHAR2,
                       x_bom_resource_id              IN OUT NOCOPY NUMBER,
                       x_final_deliver_to_person_id   IN OUT NOCOPY NUMBER,
                       x_final_deliver_to_location_id IN OUT NOCOPY NUMBER,
                       x_person                       IN OUT NOCOPY VARCHAR2,
                       x_location                     IN OUT NOCOPY VARCHAR2,
                       x_hazard_class                 IN OUT NOCOPY VARCHAR2,
                       x_un_number                    IN OUT NOCOPY VARCHAR2,
                       x_sub_locator_control          IN OUT NOCOPY VARCHAR2 ,
                       x_count                        IN OUT NOCOPY NUMBER ,
                       x_locator_id                   IN OUT NOCOPY NUMBER ,
                       x_available_qty                IN OUT NOCOPY NUMBER,
                       x_primary_available_qty        IN OUT NOCOPY NUMBER,
                       x_tolerable_qty                IN OUT NOCOPY NUMBER ,
                       x_uom                          IN OUT NOCOPY VARCHAR2,
                       x_count_po_distribution        IN OUT NOCOPY NUMBER,
                       x_receiving_dsp_value          IN OUT NOCOPY VARCHAR2,
 	               x_po_operation_seq_num         IN OUT NOCOPY NUMBER,
		       x_po_resource_seq_num          IN OUT NOCOPY NUMBER,
                       x_currency_conv_rate           IN OUT NOCOPY NUMBER,
                       x_currency_conv_date           IN OUT NOCOPY DATE,
                       x_oe_order_line_id             IN NUMBER,
                       /* Bug# 1548597 */
                       x_secondary_available_qty      IN OUT NOCOPY NUMBER,
-- <RCV ENH FPI START>
                       p_req_line_id               IN NUMBER,
                       p_req_distribution_id       IN NUMBER,
                       x_kanban_card_number        OUT NOCOPY VARCHAR2,
                       x_project_number            OUT NOCOPY VARCHAR2,
                       x_task_number               OUT NOCOPY VARCHAR2,
                       x_charge_account            OUT NOCOPY VARCHAR2
-- <RCV ENH FPI END>
                       )
;
                       -- End 1548597
-- Bug#2109106. This function has been overloaded.This has been done because
--  the change done for OPM to include the parameter x_secondary_available_qty
--  breaks the inventory api call to this procedure.x_secondary_available_qty
--  has been removed from the parameters.
--  This has been done for WMS only.

PROCEDURE POST_QUERY ( x_transaction_id                IN NUMBER,
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
                       x_vendor_id                     IN NUMBER,
                       x_item_id                       IN NUMBER,
                       x_item_revision                 IN VARCHAR2,
                       x_transaction_date              IN DATE,
                       x_creation_date                 IN DATE,
                       x_location_id                   IN NUMBER,
                       x_subinventory                  IN VARCHAR2,
                       x_destination_type_code         IN VARCHAR2,
                       x_destination_type_dsp          IN VARCHAR2,
                       x_primary_uom                   IN VARCHAR2,
                       x_routing_id                    IN NUMBER,
                       x_po_distribution_id           IN OUT NOCOPY NUMBER,
                       x_final_dest_type_code         IN OUT NOCOPY VARCHAR2,
                       x_final_dest_type_dsp          IN OUT NOCOPY VARCHAR2,
                       x_final_location_id            IN OUT NOCOPY NUMBER,
                       x_final_subinventory           IN OUT NOCOPY VARCHAR2,
                       x_destination_context          IN OUT NOCOPY VARCHAR2,
                       x_wip_entity_id                IN OUT NOCOPY NUMBER,
                       x_wip_line_id                  IN OUT NOCOPY NUMBER,
                       x_wip_repetitive_schedule_id   IN OUT NOCOPY NUMBER,
                       x_outside_processing           IN OUT NOCOPY VARCHAR2,
                       x_job_schedule_dsp             IN OUT NOCOPY VARCHAR2,
                       x_op_seq_num_dsp               IN OUT NOCOPY VARCHAR2,
                       x_department_code              IN OUT NOCOPY VARCHAR2 ,
                       x_production_line_dsp          IN OUT NOCOPY VARCHAR2,
                       x_bom_resource_id              IN OUT NOCOPY NUMBER,
                       x_final_deliver_to_person_id   IN OUT NOCOPY NUMBER,
                       x_final_deliver_to_location_id IN OUT NOCOPY NUMBER,
                       x_person                       IN OUT NOCOPY VARCHAR2,
                       x_location                     IN OUT NOCOPY VARCHAR2,
                       x_hazard_class                 IN OUT NOCOPY VARCHAR2,
                       x_un_number                    IN OUT NOCOPY VARCHAR2,
                       x_sub_locator_control          IN OUT NOCOPY VARCHAR2 ,
                       x_count                        IN OUT NOCOPY NUMBER ,
                       x_locator_id                   IN OUT NOCOPY NUMBER ,
                       x_available_qty                IN OUT NOCOPY NUMBER,
                       x_primary_available_qty        IN OUT NOCOPY NUMBER,
                       x_tolerable_qty                IN OUT NOCOPY NUMBER ,
                       x_uom                          IN OUT NOCOPY VARCHAR2,
                       x_count_po_distribution        IN OUT NOCOPY NUMBER,
                       x_receiving_dsp_value          IN OUT NOCOPY VARCHAR2,
 	               x_po_operation_seq_num         IN OUT NOCOPY NUMBER,
		       x_po_resource_seq_num          IN OUT NOCOPY NUMBER,
                       x_currency_conv_rate           IN OUT NOCOPY NUMBER,
                       x_currency_conv_date           IN OUT NOCOPY DATE,
                       x_oe_order_line_id             IN NUMBER);

END RCV_TRANSACTION_SV;

 

/
