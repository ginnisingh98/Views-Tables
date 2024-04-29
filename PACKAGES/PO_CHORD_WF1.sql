--------------------------------------------------------
--  DDL for Package PO_CHORD_WF1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHORD_WF1" AUTHID CURRENT_USER as
/* $Header: POXWCO1S.pls 120.1 2006/03/08 14:38:23 dreddy noship $ */

/* These two record types define all data exchange
 * between WF system and PL/SQL procedures
 * t_header_control_type: determined by database values
 * t_header_parameters_type  :values stored in WF system
 */

/* For controlled information tracking percentage change,
 * <X>_change is defined
 */
 	TYPE t_header_control_type IS RECORD (
	/* change control data */
	/* TABLE: po_headers vs po_headers_archive */
	agent_id			VARCHAR2(1),
	vendor_site_id			VARCHAR2(1),
	vendor_contact_id		VARCHAR2(1),
	ship_to_location_id		VARCHAR2(1),
	bill_to_location_id 		VARCHAR2(1),
	terms_id			VARCHAR2(1),
	ship_via_lookup_code		VARCHAR2(1),
	fob_lookup_code			VARCHAR2(1),
	freight_terms_lookup_code	VARCHAR2(1),
	blanket_total_amount		VARCHAR2(1), --%chg, not set
	note_to_vendor			VARCHAR2(1),
	confirming_order_flag		VARCHAR2(1),
	acceptance_required_flag 	VARCHAR2(1),
	acceptance_due_date 		VARCHAR2(1),
	amount_limit			VARCHAR2(1), --%chg, not set
	start_date			VARCHAR2(1),
	end_date			VARCHAR2(1),
	cancel_flag			VARCHAR2(1),
	blanket_total_change		NUMBER,
	amount_limit_change		NUMBER,
	po_total_change			NUMBER,
	/* TABLE: po_acceptances */
	po_acknowledged			VARCHAR2(1),
	po_accepted			VARCHAR2(1)
	);

	TYPE t_header_parameters_type IS RECORD (
	po_header_id			NUMBER,
	type_lookup_code		VARCHAR(25)
	);


	PROCEDURE chord_hd(itemtype IN VARCHAR2,
			   itemkey  IN VARCHAR2,
			   actid    IN NUMBER,
			   FUNCMODE IN VARCHAR2,
			   RESULT   OUT NOCOPY VARCHAR2);

        PROCEDURE check_header_change(
		   itemtype 		IN	VARCHAR2,
		   itemkey 		IN	VARCHAR2,
		   x_header_parameters 	IN 	t_header_parameters_type,
		   x_header_control 	IN OUT NOCOPY 	t_header_control_type);

	FUNCTION  po_total_change(
		   x_po_header_id 	IN 	NUMBER)
		   RETURN NUMBER;

	PROCEDURE set_wf_header_control(
		   itemtype		IN VARCHAR2,
		   itemkey		IN VARCHAR2,
		   x_header_control 	IN t_header_control_type);

	PROCEDURE get_wf_header_control(
		   itemtype	 IN VARCHAR2,
		   itemkey 	 IN VARCHAR2,
		   x_header_control IN OUT NOCOPY t_header_control_type);

	PROCEDURE get_wf_header_parameters(
		   itemtype	 IN VARCHAR2,
		   itemkey 	 IN VARCHAR2,
		   x_header_parameters IN OUT NOCOPY t_header_parameters_type);

	PROCEDURE debug_header_control(
		   itemtype		IN VARCHAR2,
		   itemkey		IN VARCHAR2,
		   x_header_control IN t_header_control_type);

END PO_CHORD_WF1;

 

/
