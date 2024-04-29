--------------------------------------------------------
--  DDL for Package PO_REQ_LINES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_LINES_SV" AUTHID CURRENT_USER as
/* $Header: POXRQL1S.pls 120.0.12010000.2 2014/07/23 06:02:54 rkandima ship $ */
/*===========================================================================
  PACKAGE NAME:		po_req_lines_sv

  DESCRIPTION:		Contains all server side procedures that access
			requisition lines entity.

  CLIENT/SERVER:	Server

  LIBRARY NAME		None

  OWNER:		RMULPURY

  PROCEDURE NAMES:	val_create_dist
			create_distribution
			check_funds
			delete_line
			delete_children
                        val_reqs_po_shipment
                        val_reqs_oe_shipment
                        val_reqs_qty_delivered
			update_reqs_lines_incomplete
                        update_reqs_lines_status
			remove_req_from_po
			get_destination_info
			get_default_destination_info
			get_default_source_type_info
			get_vendor_sourcing_info
			get_dest_type
			val_dest_details
			val_destination_type


===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	lock_row_for_buyer_update

  DESCRIPTION:		Locks row in table for updating suggested_buyer_id

  PARAMETERS:		X_rowid		IN VARCHAR2

  DESIGN REFERENCES:	POXBWMBW.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	CMOK		8/8	Created
===========================================================================*/

  PROCEDURE lock_row_for_buyer_update (x_rowid  IN  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	delete_line

  DESCRIPTION:		Cover to delete  the children and the
			requisition line.

  PARAMETERS:		X_line_id 	IN NUMBER
			X_mode		IN VARCHAR2

  DESIGN REFERENCES:	MODIFY_REQS.dd
			POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE delete_line(X_line_id			IN  NUMBER,
		      X_mode    		IN  VARCHAR2,
		      X_transferred_to_oe_flag	OUT NOCOPY VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	delete_children

  DESCRIPTION:		Deletes all the children associated
			with a requisition line which includes:

			- distributions.
			- remove req line supply (for 'MODIFY')
			- attachments.

  PARAMETERS:		X_line_id	IN NUMBER
			X_mode		IN VARCHAR2

  DESIGN REFERENCES:	MODIFY_REQS.dd
			POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE delete_children(X_line_id  IN NUMBER,
			  X_mode     IN VARCHAR2);



/*===========================================================================
  FUNCTION NAME:	val_reqs_po_shipment

  DESCRIPTION:          Verify if requisition lines has any open PO shipments.

                        If it is, display a message to the user.

  PARAMETERS:           X_req_header_id           IN     NUMBER,
			X_req_line_id             IN     NUMBER

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            Header:  verify if requisition header has requisition
                                 lines that are associated with any open PO
                                 shipments which are not cancelled or
                                 finally closed.
                        Line:    verify if requisiton line associated with
                                 PO shipment which is not cancelled or
                                 finally closed.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
===========================================================================*/
  FUNCTION val_reqs_po_shipment
                       (X_req_header_id      IN     NUMBER,
                        X_req_line_id        IN     NUMBER) RETURN BOOLEAN;



/*===========================================================================
  FUNCTION NAME:	val_reqs_oe_shipment

  DESCRIPTION:          If Order Entry is installed, verify if internal
                        requisition has open sales order lines.

                        If it is, display a message to the user.

  PARAMETERS:           X_req_header_id           IN     NUMBER,
			X_req_line_id             IN     NUMBER

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            Header: the requisition header has requisition lines
                                associated with open internal sales
                                order lines.

                        Line:   the line that is on an open internal
                                sales order line.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
===========================================================================*/
 FUNCTION val_reqs_oe_shipment
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER) RETURN BOOLEAN;



/*===========================================================================
  FUNCTION NAME:	val_reqs_qty_delivered

  DESCRIPTION:          If encumbrance is ON, this procedure is called to
                        verify those requisition lines which are sourced from
                        inventory,  must be received and delivered.

                        If it is not, display a message to the user.

  PARAMETERS:           X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            Header:  Verify if any lines that are sourced from
                                 inventory, the quantity must be received
                                 and delivered.
                        Line:    Verify if a requisition line that is sourced
                                 from inventory, the quantity must be
                                 received and delivered.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
===========================================================================*/
  FUNCTION val_reqs_qty_delivered
                       (X_req_header_id       IN     NUMBER,
                        X_req_line_id         IN     NUMBER) RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	update_reqs_lines_incomplete

  DESCRIPTION:          If control action is 'CANCEL' and encumbrance is ON,
                        invoke this procedure to udpate req. lines cancel
                        flag to incomplete 'I'.  This is to indicate that
                        cancel process is partially completed before
                        the unencumbrance user exit is called.

                        This update is needed because the unencumbrance user
                        exit will call the GL procedure which commits the
                        update before returning to the caller.
      bug 1265026 : added oe_install_flaf as a parameter

  PARAMETERS:           X_req_header_id           IN     NUMBER,
			X_req_line_id             IN     NUMBER,
			X_req_control_error_rc    IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            Header:  Update the requisition lines cancel flag to 'I'.
                        Line:    Update the line cancel falg to 'I'.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
===========================================================================*/
  PROCEDURE update_reqs_lines_incomplete
                       (X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_req_control_error_rc    IN OUT NOCOPY VARCHAR2,
                        X_oe_installed_flag       IN     VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:	update_reqs_lines_status

  DESCRIPTION:          Updates requisition line status fields.


  PARAMETERS:           X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
 			X_req_action_date         IN     DATE,
                        X_oe_installed_flag       IN     VARCHAR2,
                        X_req_control_error_rc    IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            1. If control action is 'CANCEL',
                           update requisition line's cancel_flag, cancel_date,
                           and cancel_reason.

                        2. If control action is 'FINALLY CLOSE',
                           update requisition line's closed_code, closed_date,
                           and closed_reason.
  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
===========================================================================*/
   PROCEDURE update_reqs_lines_status
                       (X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
			X_req_action_date         IN     DATE,
                        X_oe_installed_flag       IN     VARCHAR2,
                        X_req_control_error_rc    IN OUT NOCOPY VARCHAR2);





/*===========================================================================
  PROCEDURE NAME:	remove_req_from_po

  DESCRIPTION:		Routine to update the requisition lines
			entity that are associated with a Purchase
			Order or Release to have a null line_location_id
			for the requisition lines which were placed on
			a Purchase Order or Release.

  PARAMETERS:		X_entity_id	IN NUMBER
			X_entity	IN VARCHAR2

  DESIGN REFERENCES:	POXPOMPO.doc
			POXPOREL.doc

  ALGORITHM:

  NOTES:		X_entity values may be:

			- 'PURCHASE ORDER'
			- 'RELEASE'

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

 PROCEDURE remove_req_from_po(X_entity_id	IN NUMBER,
			      X_entity	IN VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:	val_dest_details

  DESCRIPTION:		Cover for the validation of the following
			destination fields:

			- Deliver To Organization
			- Deliver To Location
			- Destination Subinventory

			This procedure copies null
			values into the invalid columns.

  PARAMETERS:		x_dest_org_id	IN OUT NUMBER
			x_item_id	IN NUMBER
			x_item_rev	IN VARCHAR2
			x_location_id	IN OUT NUMBER
			x_dest_sub	IN OUT VARCHAR2
			x_dest_type	IN VARCHAR2
			x_code		IN VARCHAR2
			x_sob_id	IN NUMBER

			Valid codes: 'ORG' - Validate org,loc,sub
				     'LOC' - Validate loc,sub
				     'SUB' - Validate sub.


  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE val_dest_details (x_dest_org_id	IN OUT NOCOPY NUMBER,
			    x_item_id		IN NUMBER,
			    x_item_rev		IN VARCHAR,
			    x_location_id	IN OUT NOCOPY NUMBER,
			    x_dest_sub		IN OUT NOCOPY VARCHAR2,
			    x_dest_type		IN VARCHAR2,
			    x_val_code		IN VARCHAR2,
			    x_sob_id		IN NUMBER);



/*===========================================================================
  FUNCTION NAME:	val_src_type

  DESCRIPTION:		Validate the source type.

			This function returns FALSE
			when the specified source type
			is INVALID.

  PARAMETERS:		x_src_type		IN      VARCHAR2
			x_item_id		IN	NUMBER
			x_internal_orderable	IN	VARCHAR2
			x_stock_enabled_flag	IN	VARCHAR2
			x_purchasable		IN	VARCHAR2
			x_customer_id		IN	NUMBER
			x_outside_op_line_type  IN	VARCHAR2


  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:		DEBUG: This can actually be moved
			to the client since we obtain all the
			input values to this function on the
			w-v-i of the item and destination org
			fields.

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

FUNCTION  val_src_type ( x_src_type		IN VARCHAR2,
			 x_item_id		IN NUMBER,
			 x_internal_orderable	IN VARCHAR2,
			 x_stock_enabled_flag   IN VARCHAR2,
			 x_purchasable		IN VARCHAR2,
			 x_customer_id		IN NUMBER,
			 x_outside_op_line_type IN VARCHAR2,
                         x_dest_loc_id          IN NUMBER)
RETURN BOOLEAN;



/*===========================================================================
  PROCEDURE NAME:	update_transferred_to_oe_flag

  DESCRIPTION:		Check if there is a line with
			a source type of 'INVENTORY' and
		        modify the  transferred_to_oe_flag
			on the requisition headers table
			based on the following rules.

			- If there are no 'INVENTORY' sourced
			  lines then set the transferred_to_oe_flag
			  to NULL
			- If there is at least one 'INVENTORY'
			  sourced line then set the transferred_to_oe_flag
			  to 'N'.

  PARAMETERS:		X_req_hdr_id		  IN  NUMBER
			X_transferred_to_oe_flag  OUT VARCHAR2

  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	05/11	Created
===========================================================================*/

PROCEDURE update_transferred_to_oe_flag(X_req_hdr_id   		 IN  NUMBER,
		           		X_transferred_to_oe_flag OUT NOCOPY VARCHAR2);



/*===========================================================================
  FUNCTION NAME:        val_oe_shipment_in_proc

  DESCRIPTION:          If Order Entry is installed, verify if internal
                        requisition has open sales order lines and the shipped
                        sales order lines are not in process

                        If it is, display a message to the user.

  PARAMETERS:           X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER

  DESIGN REFERENCES:

  ALGORITHM:            Header: the requisition header has requisition lines
                                associated with open internal sales
                                order lines.

                        Line:   the line that is on an open internal
                                sales order line.

  NOTES:

  OPEN ISSUES:
  CLOSED ISSUES:

  CHANGE HISTORY:       kagarwal       8/2002     Created
===========================================================================*/
 FUNCTION val_oe_shipment_in_proc
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER) RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:        val_reqs_qty_received

  DESCRIPTION:          If Order Entry is installed, verify if internal
                        requisition lines which are sourced from inventory,
                        have been received or not. For this we will check if
                        the 'SHIPMENT' supply exists for the requisition lines.

                        If 'SHIPMENT' supply exists return FALSE else TRUE

  PARAMETERS:           X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER

  DESIGN REFERENCES:    ../POXDOCON.dd

  ALGORITHM:            Header:  Verify if any lines that are sourced from
                                 inventory, that the 'SHIPMENT' supply exist.
                        Line:    Verify if a requisition line that is sourced
                                 from inventory, that the 'SHIPMENT' supply
                                 exist.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Bug#2607180 (kagarwal)    10/2002     Created
===========================================================================*/
  FUNCTION val_reqs_qty_received
                       (X_req_header_id       IN     NUMBER,
                        X_req_line_id         IN     NUMBER) RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:       update_reqs_in_pool_flag

  DESCRIPTION:          Checks all the properties that determine a
                        requisition line's in-pool status and updates
                        that line's REQS_IN_POOL_FLAG status
                        accordingly.

  PARAMETERS:           x_req_line_id       IN         NUMBER,
                        x_req_header_id     IN         NUMBER,
			x_return_status     OUT NOCOPY VARCHAR2

  DESIGN REFERENCES:    ReqsInPoolTD.doc

  ALGORITHM:            For all applicable requisition lines,
                        set the requisition line's in-pool status to
                        in-pool ('Y') if the requisition line has not
                        been cancelled, not finally closed, not
                        attached to a PO or release, not modified since
                        approval, is vendor-sourced (not part of an
                        internal req), not part of an active sourcing
                        negotiation, and is on an approved requisition.

  NOTES:                If both x_req_line_id and x_req_header_id
                        are NULL, no updates are made and the procedure
			returns with success. If a sql error is encountered,
			calls po_message_s.sql_error to notify user and
			returns with status FND_API.G_RET_STS_UNEXP_ERROR.
  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       Bug#4075357  12/22/2004  created
==========================================================================*/
PROCEDURE update_reqs_in_pool_flag
(   x_req_line_id                 IN          NUMBER            ,
    x_req_header_id               IN          NUMBER            ,
    x_return_status               OUT NOCOPY  VARCHAR2
);

END po_req_lines_sv;

/
