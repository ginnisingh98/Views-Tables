--------------------------------------------------------
--  DDL for Package PO_DISTRIBUTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DISTRIBUTIONS_SV" AUTHID CURRENT_USER as
/* $Header: POXPOD1S.pls 120.1 2005/08/17 02:20:25 arudas noship $ */
/*===========================================================================
  PACKAGE NAME:		PO_DISTRIBUTIONS_SV

  DESCRIPTION:		Contains all the server side procedures
			that access the entity, PO_DISTRIBUTIONS_SV

  CLIENT/SERVER:	Server

  LIBRARY NAME		None

  OWNER:		MCHIHAOU

  PROCEDURE NAMES:	check_unique
			check_max_dist_num
			select_summary
                        get_dest_type
===========================================================================*/


/*===========================================================================
  PROCEDURE NAME:	check_unique()

  DESCRIPTION:

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION check_unique(x_line_location_id NUMBER,
                      x_distribution_num NUMBER,
                      x_rowid            VARCHAR2) RETURN BOOLEAN;

-- bug3322899 START
/*===========================================================================

  FUNCTION NAME:       distribution_num_unique()

===========================================================================*/
FUNCTION distribution_num_unique
( p_line_location_id IN NUMBER,
  p_distribution_num IN NUMBER,
  p_rowid            IN VARCHAR2 DEFAULT NULL
) RETURN BOOLEAN;
-- bug3322899 END

/*===========================================================================
  PROCEDURE NAME:	get_max_dist_num

  DESCRIPTION:       get the maximum number for the distribution lines that
                     have been committed to the Database.

  PARAMETERS:


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
  FUNCTION get_max_dist_num( X_line_location_id   NUMBER)
  RETURN NUMBER;

/*===========================================================================
  PROCEDURE NAME:	select_summary

  DESCRIPTION:      Running total implementation for quantity_ordered
                    implemented according to standards.

  PARAMETERS:


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
  PROCEDURE select_summary( X_line_location_id      IN OUT NOCOPY NUMBER,
                            X_total                 IN OUT NOCOPY NUMBER);


/*===========================================================================
  FUNCTION NAME:       post_query

  DESCRIPTION:     Returns the deliver_to_location and the
                   deliver_to_person  when given the
                   deliver_to_person_id and deliver_to_location_id.

  PARAMETERS:


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE post_query(
                    x_deliver_to_location_id 			NUMBER,
                    x_deliver_to_person_id 			NUMBER,
                    x_ship_to_org_id 				NUMBER,
                    x_project_id     				NUMBER,
                    x_task_id        				NUMBER,
                    x_org_id         				NUMBER,
                    x_destination_type_code  			VARCHAR2,
                    x_deliver_to_location  		IN OUT NOCOPY  VARCHAR2,
                    x_deliver_to_person    		IN OUT NOCOPY  VARCHAR2,
                    x_project_num          		IN OUT NOCOPY  VARCHAR2,
                    x_task_num             		IN OUT NOCOPY  VARCHAR2,
                    x_org_code             		IN OUT NOCOPY  VARCHAR2,
		    --togeorge 10/03/2000
		    -- added to bring oke line info during post query.
		    x_oke_contract_header_id	   	IN	NUMBER default null,
		    x_oke_contract_line_id	   	IN	NUMBER default null,
		    x_oke_contract_line_num	   	IN OUT	NOCOPY VARCHAR2,
	            x_oke_contract_deliverable_id  	IN	NUMBER default null,
	            x_oke_contract_deliverable_num 	IN OUT	NOCOPY VARCHAR2
		    );

/*===========================================================================
  FUNCTION NAME:       get_dest_type

  DESCRIPTION:     Returns the destination_type when given the
                   destination_type_code.

  PARAMETERS:


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
FUNCTION get_dest_type( x_destination_type_code  VARCHAR2) return VARCHAR2;



/*===========================================================================
  FUNCTION NAME:   delete_distributions

  DESCRIPTION:     Delete distributions based on entity and id

  PARAMETERS:	   See below

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	KPOWELL	10/10 CREATED
===========================================================================*/
PROCEDURE delete_distributions(x_delete_id NUMBER,
			      x_delete_entity VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	get_total_dist_qty()
  DESCRIPTION:		Gets the remaining distribution quantity so
			it can be defaulted on to the distribution.
  PARAMETERS:		X_po_line_location_id	IN	NUMBER
			X_total_quantity	IN OUT  NUMBER
  DESIGN REFERENCES:
  ALGORITHM:		Get the total quantity for all distributions
			against the shipment.
  NOTES:
  OPEN ISSUES:
  CLOSED ISSUES:
  CHANGE HISTORY:	KPOWELL		4/20	Created
===========================================================================*/
  PROCEDURE test_get_total_dist_qty
		      (X_po_line_location_id	IN	NUMBER);
  PROCEDURE get_total_dist_qty
		      (X_po_line_location_id	IN	NUMBER,
		       X_total_quantity		IN OUT NOCOPY  NUMBER);
/*===========================================================================
  PROCEDURE NAME:	val_distribution_exists()
  DESCRIPTION:		Validates if a distribution exists for a
			shipment
  PARAMETERS:		X_po_line_location_id	IN	NUMBER
			RETURN BOOLEAN
  DESIGN REFERENCES:
  ALGORITHM:		Validate if a distribution exists for a
			shipment
  NOTES:
  OPEN ISSUES:
  CLOSED ISSUES:
  CHANGE HISTORY:	KPOWELL		4/20	Created
===========================================================================*/
  FUNCTION val_distribution_exists
		      (X_po_line_location_id    IN      NUMBER) RETURN BOOLEAN;
  PROCEDURE test_val_distribution_exists
		      (X_po_line_location_id    IN      NUMBER);
/*===================================================================

PROCEDURE NAME : performed_rcv_or_bill_activity (bug 4239813, 4239805)

=====================================================================*/
function performed_rcv_or_bill_activity(p_line_location_id IN NUMBER,
                                        p_distribution_id  IN NUMBER)
RETURN BOOLEAN;

--<HTML Agreements R12 Start>
PROCEDURE validate_delete_distribution(p_po_distribution_id IN NUMBER
                                      ,p_line_loc_id        IN NUMBER
                                      ,p_approved_date      IN VARCHAR2
                                      ,p_style_disp_name    IN VARCHAR2
                                      ,x_message_text      OUT NOCOPY VARCHAR2);
--<HTML Agreements R12 End>
END po_distributions_sv;
 

/
