--------------------------------------------------------
--  DDL for Package ICX_PO_REQS_CANCEL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PO_REQS_CANCEL_SV" AUTHID CURRENT_USER AS
/* $Header: ICXRQCNS.pls 115.1 99/07/17 03:22:59 porting ship $*/
/*===========================================================================
  PACKAGE NAME:		icx_po_reqs_cancel_sv

  DESCRIPTION:          Contains the server side requisition control APIs
			this is will be replaced by PO functions in
			version 2.0

  CLIENT/SERVER:	Server

  LIBRARY NAME          NONE

  OWNER:                WLAU

  PROCEDURES/FUNCTIONS:	val_reqs_action()
			update_reqs_status()

===========================================================================*/


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
			X_encumbrance_flag        IN     VARCHAR2,
			X_oe_installed_flag       IN     VARCHAR2,
			X_req_control_error_rc    IN OUT VARCHAR2

  DESIGN REFERENCES:	../POXDOCON.dd

  ALGORITHM:            This driver invokes the following APIs:
                        - po_reqs_sv.get_reqs_auth_status
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
  PROCEDURE update_web_reqs_status
                       (X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_agent_id                IN     NUMBER,
                        X_req_doc_type            IN     VARCHAR2,
                        X_req_doc_subtype         IN     VARCHAR2,
                        X_req_control_action      IN     VARCHAR2,
                        X_req_control_reason      IN     VARCHAR2,
			x_req_control_date	  IN 	 date,
                        X_encumbrance_flag        IN     VARCHAR2,
                        X_oe_installed_flag       IN     VARCHAR2,
                        X_req_control_error_rc    IN OUT VARCHAR2);




  PROCEDURE icx_maintain_supply
			(X_supply_action 	IN	VARCHAR2,
			 X_supply_id		IN	NUMBER,
                         X_req_control_error_rc IN OUT  VARCHAR2);


END icx_po_reqs_cancel_sv;

 

/
