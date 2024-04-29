--------------------------------------------------------
--  DDL for Package RCV_DISTRIBUTIONS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_DISTRIBUTIONS_S" AUTHID CURRENT_USER AS
/* $Header: RCVTXDIS.pls 115.2 2002/11/23 00:55:40 sbull ship $*/

/*===========================================================================
  PROCEDURE NAME:	get_distribution_info ()

  DESCRIPTION:		Go get the default destination information for either
			a po or an internal shipment along with any wip info
                        if necessary

  PARAMETERS:

    X_line_location_id 		 IN          NUMBER,
    X_shipment_line_id 		 IN          NUMBER,
    X_item_id 		         IN          NUMBER,
    X_num_of_distributions 	 IN OUT      NUMBER,
    X_po_distributions_id 	 OUT         NUMBER,
    X_destination_type_code 	 IN OUT      VARCHAR2,
    X_destination_type_dsp  	 OUT         VARCHAR2,
    X_deliver_to_location_id	 OUT         NUMBER,
    X_deliver_to_location	 OUT         VARCHAR2,
    X_deliver_to_person_id	 OUT         NUMBER,
    X_deliver_to_person		 OUT         VARCHAR2,
    X_deliver_to_sub		 OUT         VARCHAR2,
    X_deliver_to_locator_id	 OUT         NUMBER,
    X_deliver_to_locator	 OUT         VARCHAR2,
    X_wip_entity_id              IN OUT      NUMBER,
    X_wip_repetitive_schedule_id IN OUT      NUMBER,
    X_wip_line_id                IN OUT      NUMBER,
    X_wip_operation_seq_num      IN OUT      NUMBER,
    X_wip_resource_seq_num       IN OUT      NUMBER,
    X_bom_resource_id            IN OUT      NUMBER,
    X_to_organization_id         IN OUT      NUMBER,
    X_job                        IN OUT      VARCHAR2,
    X_line_num                   IN OUT      VARCHAR2,
    X_sequence                   IN OUT      NUMBER,
    X_department                 IN OUT      VARCHAR2
    X_rate                       IN OUT      NUMBER
    X_rate_date                  IN OUT      DATE
-- <RCV ENH FPI START>
    x_kanban_card_number         OUT NOCOPY  VARCHAR2,
    x_project_number             OUT NOCOPY  VARCHAR2,
    x_task_number                OUT NOCOPY  VARCHAR2,
    x_charge_account             OUT NOCOPY  VARCHAR2
-- <RCV ENH FPI END>

  DESIGN REFERENCES:	RCVRCERC.dd
			RCVTXERT.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/

PROCEDURE get_distributions_info
   (X_line_location_id 		 IN          NUMBER,
    X_shipment_line_id 		 IN          NUMBER,
    X_item_id      		 IN          NUMBER,
    X_num_of_distributions 	 IN OUT NOCOPY      NUMBER,
    X_po_distributions_id 	 OUT NOCOPY         NUMBER,
    X_destination_type_code 	 IN OUT NOCOPY      VARCHAR2,
    X_destination_type_dsp  	 OUT NOCOPY         VARCHAR2,
    X_deliver_to_location_id	 IN OUT NOCOPY      NUMBER,
    X_deliver_to_location	 OUT NOCOPY         VARCHAR2,
    X_deliver_to_person_id	 IN OUT NOCOPY      NUMBER,
    X_deliver_to_person		 OUT NOCOPY         VARCHAR2,
    X_deliver_to_sub		 IN OUT NOCOPY      VARCHAR2,
    X_deliver_to_locator_id	 OUT NOCOPY         NUMBER,
    X_deliver_to_locator	 OUT NOCOPY         VARCHAR2,
    X_wip_entity_id              IN OUT NOCOPY      NUMBER,
    X_wip_repetitive_schedule_id IN OUT NOCOPY      NUMBER,
    X_wip_line_id                IN OUT NOCOPY      NUMBER,
    X_wip_operation_seq_num      IN OUT NOCOPY      NUMBER,
    X_wip_resource_seq_num       IN OUT NOCOPY      NUMBER,
    X_bom_resource_id            IN OUT NOCOPY      NUMBER,
    X_to_organization_id         IN OUT NOCOPY      NUMBER,
    X_job                        IN OUT NOCOPY      VARCHAR2,
    X_line_num                   IN OUT NOCOPY      VARCHAR2,
    X_sequence                   IN OUT NOCOPY      NUMBER,
    X_department                 IN OUT NOCOPY      VARCHAR2,
    X_rate                       IN OUT NOCOPY      NUMBER,
    X_rate_date                  IN OUT NOCOPY      DATE,
-- <RCV ENH FPI START>
    x_kanban_card_number         OUT NOCOPY  VARCHAR2,
    x_project_number             OUT NOCOPY  VARCHAR2,
    x_task_number                OUT NOCOPY  VARCHAR2,
    x_charge_account             OUT NOCOPY  VARCHAR2
-- <RCV ENH FPI END>
   );

/*===========================================================================
  PROCEDURE NAME:	test_rcv_distributions_s ()

  DESCRIPTION:		Test all functions and procedures in the
			rcv_distributions_s

  PARAMETERS:		X_line_location_id 		IN NUMBER
			-- The line location you wish to look for
			X_shipment_line_id 		IN NUMBER
			-- The RCV shipment line id you wish to look for
			X_item_id 		IN NUMBER
			-- The item thats on the line

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/

PROCEDURE test_rcv_distributions_s
   (X_line_location_id 		IN NUMBER,
    X_shipment_line_id 		IN NUMBER,
    X_item_id       		IN NUMBER);

-- <RCV ENH FPI START>
PROCEDURE get_misc_distr_info
(x_return_status         OUT NOCOPY VARCHAR2,
 p_line_location_id      IN NUMBER,
 p_po_distribution_id    IN NUMBER,
 x_kanban_card_number    OUT NOCOPY VARCHAR2,
 x_project_number        OUT NOCOPY VARCHAR2,
 x_task_number           OUT NOCOPY VARCHAR2,
 x_charge_account        OUT NOCOPY VARCHAR2,
 x_deliver_to_person     OUT NOCOPY VARCHAR2,
 x_job                   OUT NOCOPY VARCHAR2,
 x_outside_line_num      OUT NOCOPY VARCHAR2,
 x_sequence              OUT NOCOPY NUMBER,
 x_department            OUT NOCOPY VARCHAR2,
 x_dest_subinv           OUT NOCOPY VARCHAR2,
 x_rate                  OUT NOCOPY NUMBER,
 x_rate_date             OUT NOCOPY DATE);

PROCEDURE get_misc_req_distr_info
(x_return_status         OUT NOCOPY VARCHAR2,
 p_requisition_line_id   IN NUMBER,
 p_req_distribution_id   IN NUMBER,
 x_kanban_card_number    OUT NOCOPY VARCHAR2,
 x_project_number        OUT NOCOPY VARCHAR2,
 x_task_number           OUT NOCOPY VARCHAR2,
 x_charge_account        OUT NOCOPY VARCHAR2,
 x_deliver_to_person     OUT NOCOPY VARCHAR2,
 x_dest_subinv           OUT NOCOPY VARCHAR2);

-- <RCV ENH FPI END>

END RCV_DISTRIBUTIONS_S;

 

/
