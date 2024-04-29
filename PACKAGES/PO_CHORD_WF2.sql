--------------------------------------------------------
--  DDL for Package PO_CHORD_WF2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHORD_WF2" AUTHID CURRENT_USER as
/* $Header: POXWCO2S.pls 120.3 2006/03/30 15:43:17 dreddy noship $ */

	TYPE t_lines_control_type IS RECORD (
	/* valid values : Y (modified) or N (not modified) */
	line_num			VARCHAR2(1),
	item_id				VARCHAR2(1),
	item_revision			VARCHAR2(1),
	category_id			VARCHAR2(1),
	item_description		VARCHAR2(1),
 	unit_meas_lookup_code		VARCHAR2(1),
	un_number_id			VARCHAR2(1),
	hazard_class_id			VARCHAR2(1),
	note_to_vendor			VARCHAR2(1),
	from_header_id			VARCHAR2(1),
	from_line_id			VARCHAR2(1),
	closed_code			VARCHAR2(1), --not in used
	vendor_product_num		VARCHAR2(1),
	contract_num			VARCHAR2(1),
	price_type_lookup_code		VARCHAR2(1),
	cancel_flag			VARCHAR2(1), --not in used
        retainage_rate                  VARCHAR2(1),     -- <Complex Work R12>
        max_retainage_amount            VARCHAR2(1),     -- <Complex Work R12>
        progress_payment_rate           VARCHAR2(1),     -- <Complex Work R12>
        recoupment_rate                 VARCHAR2(1),     -- <Complex Work R12>
        advance_amount                  VARCHAR2(1),     -- <Complex Work R12>
	end_date	         	VARCHAR2(1), --<R12 Requester Driven Procurement>
	/* valid values: percentage */
	quantity_change			NUMBER,
	unit_price_change		NUMBER,
	quantity_committed_change	NUMBER,
	committed_amount_change		NUMBER,
	not_to_exceed_price_change	NUMBER,
	amount_change			NUMBER,--<R12 Requester Driven Procurement>
	start_date_change		NUMBER,--<R12 Requester Driven Procurement>
	end_date_change			NUMBER --<R12 Requester Driven Procurement>
	);

	TYPE t_lines_parameters_type IS RECORD(
	po_header_id			NUMBER
	);

	PROCEDURE chord_lines(itemtype IN VARCHAR2,
			      itemkey  IN VARCHAR2,
			      actid    IN NUMBER,
			      FUNCMODE IN VARCHAR2,
			      RESULT   OUT NOCOPY VARCHAR2);


        PROCEDURE check_lines_change(
		  itemtype	IN VARCHAR2,
		  itemkey	IN VARCHAR2,
		  x_lines_parameters IN t_lines_parameters_type,
		  x_lines_control In OUT NOCOPY t_lines_control_type);

	PROCEDURE set_wf_lines_control( itemtype	IN VARCHAR2,
				        itemkey 	IN VARCHAR2,
					x_lines_control IN t_lines_control_type);


	PROCEDURE get_wf_lines_control( itemtype	IN VARCHAR2,
				        itemkey 	IN VARCHAR2,
					x_lines_control IN OUT NOCOPY t_lines_control_type);

	PROCEDURE get_wf_lines_parameters(itemtype	 IN VARCHAR2,
					  itemkey 	 IN VARCHAR2,
					  x_lines_parameters IN OUT NOCOPY t_lines_parameters_type);

	PROCEDURE debug_lines_control(
			  itemtype	IN VARCHAR2,
			  itemkey	IN VARCHAR2,
			  x_lines_control IN t_lines_control_type);


END PO_CHORD_WF2;

 

/
