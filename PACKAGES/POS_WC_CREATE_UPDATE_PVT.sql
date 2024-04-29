--------------------------------------------------------
--  DDL for Package POS_WC_CREATE_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_WC_CREATE_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: POSVWCCS.pls 120.2.12010000.5 2014/01/29 10:11:03 nchundur ship $*/

FUNCTION DRAFT_EXISTS_FOR_PO ( p_po_header_id      IN  NUMBER)
RETURN VARCHAR2;


PROCEDURE GET_PO_INFO
(
	p_po_header_id 	IN  NUMBER,
	x_ordered	OUT nocopy NUMBER,
	x_approved	OUT nocopy NUMBER,
  	x_return_status OUT nocopy VARCHAR2,
  	x_return_msg    OUT nocopy VARCHAR2
);


FUNCTION GET_WC_TOTAL_REQUESTED
(
	p_wc_id		IN NUMBER,
	p_wc_stage	IN VARCHAR2
)
RETURN NUMBER;

PROCEDURE GET_PAY_ITEM_PROGRESS(
  p_wc_pay_item_id    IN  NUMBER,
  p_wc_stage          IN  VARCHAR2,
  x_progress          OUT NOCOPY NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_return_msg        OUT NOCOPY VARCHAR2);

PROCEDURE GET_PAY_ITEM_PREV_SUBMITTED(
	p_wc_pay_item_id		IN  NUMBER,
	p_po_pay_item_id		IN  NUMBER,
	p_wc_stage			IN  VARCHAR2,
	x_prev_submitted		OUT NOCOPY NUMBER);


PROCEDURE COMPLETE_WC_APPROVAL_WF_BLOCK
(
  p_wc_header_id      IN          NUMBER,
  x_return_status     OUT nocopy  VARCHAR2,
  x_return_msg        OUT nocopy  VARCHAR2
);

PROCEDURE START_APPROVAL_WORKFLOW
(
  p_wc_header_id      IN		NUMBER,
  x_return_status     OUT nocopy	VARCHAR2,
  x_return_msg        OUT nocopy	VARCHAR2
);

-- code added for work confirmation correction ER - 9414650

PROCEDURE insert_corrections_into_rti
(
  p_shipment_header_id IN NUMBER,
  p_line_location_id IN NUMBER,
  p_group_id IN NUMBER,
  p_amount_correction IN NUMBER,
  p_quantity_correction IN NUMBER,
  p_requested_amount_correction IN NUMBER,
  p_material_stored_correction IN NUMBER,
  p_comments IN VARCHAR2 );

procedure Launch_RTP_Immediate
			   (p_group_id IN NUMBER);

TYPE wc_correction_history_rec IS RECORD
(
 --last_updated_by NUMBER,
 correction_date DATE,
 corrected_by VARCHAR2(100),
 shipment_header_id NUMBER,
 po_header_id NUMBER,
 po_line_id NUMBER,
 po_line_location_id NUMBER,
 comments rcv_transactions.comments%TYPE,
 quantity_ordered NUMBER,
 amount_ordered NUMBER,
 price NUMBER,
 group_id NUMBER,
 document_line_num NUMBER,
 pay_item_num NUMBER,
 description po_line_locations_all.description%TYPE,
 matching_basis VARCHAR2(10),
 old_quantity NUMBER,
 new_quantity NUMBER,
 old_req_amount NUMBER,
 new_req_amount NUMBER,
 old_req_deliver NUMBER,
 new_req_deliver NUMBER,
 old_mat_stored NUMBER,
 new_mat_stored NUMBER,
 old_total_amount NUMBER,
 new_total_amount NUMBER,
 old_progress NUMBER,
 new_progress NUMBER
);
TYPE correction_history_tab IS TABLE OF wc_correction_history_rec;

PROCEDURE get_wc_history(p_shipment_header_id IN NUMBER,
                         p_correction_history_tab IN OUT NOCOPY correction_history_tab);

FUNCTION get_wc_correction_history(p_shipment_header_id IN NUMBER)
RETURN correction_history_tab PIPELINED;

-- end of code added for work confirmation correction ER - 9414650

END POS_WC_CREATE_UPDATE_PVT;


/
