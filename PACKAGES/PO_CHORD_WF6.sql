--------------------------------------------------------
--  DDL for Package PO_CHORD_WF6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHORD_WF6" AUTHID CURRENT_USER as
/* $Header: POXWCO6S.pls 120.8 2006/03/08 16:27:58 dreddy noship $ */

	SUBTYPE	t_header_control_type 	 IS
		PO_CHORD_WF1.t_header_control_type;

	SUBTYPE	t_lines_control_type 	 IS
		PO_CHORD_WF2.t_lines_control_type;

	SUBTYPE	t_shipments_control_type IS
		PO_CHORD_WF3.t_shipments_control_type;

	SUBTYPE	t_dist_control_type 	 IS
		PO_CHORD_WF4.t_dist_control_type;

	SUBTYPE	t_release_control_type 	 IS
		PO_CHORD_WF5.t_release_control_type;

	/* This record type holds tolerance percentages
	** defined by user in the workflow builder.
	** The prefix denotes the table which
	** the attribute is referring to :
	** h: po_headers_all
	** l: po_lines_all
	** s: po_line_locations_all
	** d: po_distributions_all
	*/

	TYPE	t_tolerance_control_type	IS RECORD(
	h_blanket_total_t	NUMBER,
	h_amount_limit_t	NUMBER,
	h_po_total_t            NUMBER,
	l_start_date_t		NUMBER, --<R12 Requester Driven Procurement>
	l_end_date_t		NUMBER, --<R12 Requester Driven Procurement>
	l_quantity_t		NUMBER,
	l_unit_price_t		NUMBER,
	l_quantity_committed_t	NUMBER,
	l_committed_amount_t	NUMBER,
	l_price_limit_t 	NUMBER,
	l_amount_t		NUMBER, --<R12 Requester Driven Procurement>
	s_quantity_t		NUMBER,
	s_price_override_t	NUMBER,
	s_amount_t		NUMBER, --<R12 Requester Driven Procurement>
	s_need_by_date_t	NUMBER, --<R12 Requester Driven Procurement>
	s_promised_date_t	NUMBER, --<R12 Requester Driven Procurement>
  p_quantity_t        NUMBER, -- <Complex Work R12>
  p_price_override_t  NUMBER, -- <Complex Work R12>
  p_amount_t          NUMBER, -- <Complex Work R12>
	d_quantity_ordered_t	NUMBER,
	d_amount_ordered_t	NUMBER --<R12 Requester Driven Procurement>
	);


	PROCEDURE standard_po_reapproval(itemtype IN VARCHAR2,
			   		itemkey  IN VARCHAR2,
			   		actid    IN NUMBER,
			   		FUNCMODE IN VARCHAR2,
			   		RESULT   OUT NOCOPY VARCHAR2);

	PROCEDURE planned_po_reapproval(itemtype IN VARCHAR2,
			   		itemkey  IN VARCHAR2,
			   		actid    IN NUMBER,
			   		FUNCMODE IN VARCHAR2,
			   		RESULT   OUT NOCOPY VARCHAR2);

	PROCEDURE blanket_po_reapproval(itemtype IN VARCHAR2,
			   		itemkey  IN VARCHAR2,
			   		actid    IN NUMBER,
			   		FUNCMODE IN VARCHAR2,
			   		RESULT   OUT NOCOPY VARCHAR2);

	PROCEDURE contract_po_reapproval(itemtype IN VARCHAR2,
			   		itemkey  IN VARCHAR2,
			   		actid    IN NUMBER,
			   		FUNCMODE IN VARCHAR2,
			   		RESULT   OUT NOCOPY VARCHAR2);

	PROCEDURE blanket_release_reapproval(itemtype IN VARCHAR2,
			   		itemkey  IN VARCHAR2,
			   		actid    IN NUMBER,
			   		FUNCMODE IN VARCHAR2,
			   		RESULT   OUT NOCOPY VARCHAR2);

	PROCEDURE scheduled_release_reapproval(itemtype IN VARCHAR2,
			   		itemkey  IN VARCHAR2,
			   		actid    IN NUMBER,
			   		FUNCMODE IN VARCHAR2,
			   		RESULT   OUT NOCOPY VARCHAR2);

	PROCEDURE get_default_tolerance(
			itemtype         IN VARCHAR2,
                        itemkey          IN VARCHAR2,
			x_tolerance_control IN OUT NOCOPY t_tolerance_control_type,
			chord_doc_type   IN VARCHAR2 default NULL);

	PROCEDURE debug_default_tolerance(
			itemtype         IN VARCHAR2,
                        itemkey          IN VARCHAR2,
			x_tolerance_control t_tolerance_control_type);

/**************************************************************************
 * The following procedures are procedures used to retrieve
 * the tolerances.
 **************************************************************************/
PROCEDURE Set_Wf_Order_Tol(
	itemtype         IN VARCHAR2,
        itemkey          IN VARCHAR2,
	order_type  IN VARCHAR2);

PROCEDURE Set_Wf_Agreement_Tol(
	itemtype         IN VARCHAR2,
        itemkey          IN VARCHAR2,
	agreement_type  IN VARCHAR2);

PROCEDURE Set_Wf_Release_Tol(
	itemtype         IN VARCHAR2,
        itemkey          IN VARCHAR2,
	release_type  IN VARCHAR2);


END PO_CHORD_WF6;

 

/
