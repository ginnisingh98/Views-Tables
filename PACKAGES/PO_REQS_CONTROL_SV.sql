--------------------------------------------------------
--  DDL for Package PO_REQS_CONTROL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQS_CONTROL_SV" AUTHID CURRENT_USER AS
/* $Header: POXRQCNS.pls 120.0.12010000.2 2012/11/14 08:59:54 ssindhe ship $*/
/*===========================================================================
  PACKAGE NAME:		po_reqs_control_sv

  DESCRIPTION:          Contains the server side requisition control APIs

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                WLAU

  PROCEDURES/FUNCTIONS:	val_reqs_action()
			update_reqs_status()

===========================================================================*/


/*===========================================================================
  FUNCTION NAME:	val_doc_security()

  DESCRIPTION:          This function checks for the document security check.
                        It returns TRUE if the document security is passed
                        otherwise it returns FALSE;

  PARAMETERS:           X_doc_agent_id            IN     NUMBER,
                        X_agent_id                IN     NUMBER
                        X_doc_type                IN     VARCHAR2,
                        X_doc_subtype             IN     VARCHAR2

  RETURN:               TRUE/FALSE

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:

   1. Document security check is passed if the following is true:

     Security Level    Access level    Document Owner     Purchasing Agent
    --------------    -------------   ---------------    -----------------
      PUBLIC            Full
      PRIVATE           all levels          YES
      HIERARCHY         Full            in hierarchy
      PURCHASING        Full                YES               YES

   2. Document security check is failed if the following is true:

    Security Level    Access level    Document Owner     Purchasing Agent
    --------------    -------------   ---------------    -----------------
      PUBLIC            View Only           NO
      PRIVATE           all levels          NO
      HIERARCHY         View Only     NO or Not in hierarchy
      PURCHASING        View Only           NO                 NO


  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       6/5     Created
===========================================================================*/
  FUNCTION val_doc_security
                       (X_doc_agent_id            IN     NUMBER,
                        X_agent_id                IN     NUMBER,
                        X_doc_type                IN     VARCHAR2,
                        X_doc_subtype             IN     VARCHAR2) RETURN BOOLEAN;


/*===========================================================================
  FUNCTION NAME:	val_reqs_action()

  DESCRIPTION:          Requisition control action validation driver.
                        This driver validates the requisition document
                        and ensures that the document is in proper
                        state for 'CANCEL' or 'FINALLY CLOSE' before
                        performing the update process.

                        If error condition is found, it retuns to the client
                        side.  The form will display error message to
                        the user.

                        If encumbrance flag is OFF, it is not needed
                        to return to the client side to call the
                        unencumbrance user exit.  This driver continue to
                        perform the requisition status update process.



  PARAMETERS:           X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_agent_id                IN     NUMBER,
                        X_req_doc_type            IN     VARCHAR2,
                        X_req_doc_subtype         IN     VARCHAR2,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
                        X_req_action_date         IN     DATE,
                        X_encumbrance_flag        IN     VARCHAR2,
                        X_oe_installed_flag       IN     VARCHAR2

  RETURN:               TRUE/FALSE

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            This driver invokes the following APIS:

                        - po_shipments_sv.val_reqs_po_shipment
                        - po_sales_order_sv.val_reqs_oe_shipments
                        - po_req_lines_sv.val_qty_delivered
                        - po_req_lines_sv.update_reqs_lines_incomplete
                        - po_reqs_control_sv.update_reqs_status

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
                        WLAU       3/20/96  bug 327628 added X_agent_id parm.
===========================================================================*/
  FUNCTION val_reqs_action
                       (X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_agent_id                IN     NUMBER,
                        X_req_doc_type            IN     VARCHAR2,
                        X_req_doc_subtype         IN     VARCHAR2,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
                        X_req_action_date         IN     DATE,
                        X_encumbrance_flag        IN     VARCHAR2,
                        X_oe_installed_flag       IN     VARCHAR2) RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	update_reqs_status()

  DESCRIPTION:          Requisition control action update driver.
                        This driver performs the requisiton document
                        status update functions after validation process
                        is completed.

  PARAMETERS:           X_req_header_id           IN     NUMBER,
			X_req_line_id             IN     NUMBER,
                        X_agent_id                IN     NUMBER,
                        X_req_doc_type            IN     VARCHAR2,
                        X_req_doc_subtype         IN     VARCHAR2,
			X_req_control_action      IN     VARCHAR2,
			X_req_control_reason      IN     VARCHAR2,
                        X_req_action_date         IN     DATE,
			X_encumbrance_flag        IN     VARCHAR2,
			X_oe_installed_flag       IN     VARCHAR2,
			X_req_control_error_rc    IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            This driver invokes the following APIs:
                        - po_reqs_sv2.get_reqs_auth_status
                        - po_req_distributions_sv.update_reqs_distributions
                        - rcv_supply_sv.maintain_supply
                        - po_reqs_sv.update_reqs_header_status
                        - po_req_lines_sv.udpate_reqs_lines_status
                        - po_notifications_sv.delete_notifications
                        - po_approve_sv.update_po_action_history

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
                        WLAU       3/20/96  bug 327628 added X_agent_id parm.
===========================================================================*/
  PROCEDURE update_reqs_status
                       (X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_agent_id                IN     NUMBER,
                        X_req_doc_type            IN     VARCHAR2,
                        X_req_doc_subtype         IN     VARCHAR2,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
 			X_req_action_date         IN     DATE,
                        X_encumbrance_flag        IN     VARCHAR2,
                        X_oe_installed_flag       IN     VARCHAR2,
                        X_req_control_error_rc    IN OUT NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	commit_changes;

  DESCRIPTION:          Perform a database commit.

  PARAMETERS:           None

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            Database commit

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       8/1/95   Created
===========================================================================*/
  PROCEDURE commit_changes;


/*===========================================================================
  PROCEDURE NAME:	rollback_changes

  DESCRIPTION:          Perform a database rollback

  PARAMETERS:           None

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            Database rollback

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       8/1/95   Created
===========================================================================*/
  PROCEDURE rollback_changes;


/*===========================================================================
  PROCEDURE NAME:	maintain_supply

  DESCRIPTION:          This procedure performs maintain_supply then function
                        when cancelling/finally close a requisition.
                        If the supply action is:

                        1. requistion header:
                           Sets the req quantity in mtl_supply to 0
                           for a given req header.
                        2. requisition line:
			   Sets the req quantity in mtl_supply to 0
                           for a given req line.

  PARAMETERS:           X_supply_action 	IN	VARCHAR2,
		        X_supply_id		IN	NUMBER,
                        X_req_control_error_rc  IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       9/28/95   Created
===========================================================================*/
  PROCEDURE maintain_supply
			(X_supply_action 	IN	VARCHAR2,
			 X_supply_id		IN	NUMBER,
                         X_req_control_error_rc IN OUT NOCOPY  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	rollback_savepoint_changes

  DESCRIPTION:          Perform a database rollback after the savepoint.

  PARAMETERS:           None

  DESIGN REFERENCES:

  ALGORITHM:            Database rollback

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:        Bug 14845281

  CHANGE HISTORY:       SSINDHE       14/11/12   Created
===========================================================================*/

  PROCEDURE rollback_savepoint_changes;


END po_reqs_control_sv;

/
