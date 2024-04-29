--------------------------------------------------------
--  DDL for Package PO_CHANGE_RESPONSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHANGE_RESPONSE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXCHRES.pls 120.0.12010000.4 2014/05/01 12:53:30 pneralla ship $*/


PROCEDURE CheckPartialAck (p_api_version in number,
                           x_return_status out NOCOPY varchar2,
                           p_po_header_id in number,
		           p_po_release_id in number,
                           p_change_request_group_id in number,
                           x_partial_ack out NOCOPY varchar2);

PROCEDURE CheckChangePending (p_api_version in number,
                              x_return_status out NOCOPY varchar2,
                              p_po_header_id in number,
                              p_po_release_id in number,
                              x_change_pending out NOCOPY varchar2);

FUNCTION get_distribution_count(p_request_level IN VARCHAR,
                                p_document_line_location_id IN NUMBER,
                                p_parent_line_location_id IN NUMBER) RETURN NUMBER;

PROCEDURE MoveChangeToPO (p_api_version in number,
                          x_return_status out NOCOPY varchar2,
                          p_po_header_id  in number,
                          p_po_release_id in number,
                          p_change_request_group_id in number,
                          p_user_id  in number,
                          x_return_code out NOCOPY NUMBER,
                          x_err_msg out NOCOPY VARCHAR2,
                          x_doc_check_rec_type out NOCOPY POS_ERR_TYPE,
                          p_launch_approvals_flag IN VARCHAR2,
                          p_mass_update_releases   IN VARCHAR2 DEFAULT NULL, -- Bug 3373453
                          p_req_chg_initiator IN VARCHAR2 DEFAULT NULL --Bug 14549341
                         );


PROCEDURE update_change_response (p_request_status in VARCHAR2,
                                  p_responded_by in NUMBER,
                                  p_response_reason in VARCHAR2,
                                  p_change_request_id in NUMBER,
                                  p_request_level in VARCHAR2,
                                  p_change_request_group_id in NUMBER,
                                  p_line_location_id in NUMBER,
                                  p_splitFlag in VARCHAR2,
                                  p_cancel_backing_req in VARCHAR2);

PROCEDURE roll_back_acceptance (p_change_request_group_id in NUMBER);

/* For bug:18202450. to display cancel backing req field attributes*/

PROCEDURE  check_backinreq_flag(p_po_header_id IN NUMBER,
                           p_po_release_id IN NUMBER,
                           isCancelChkBoxReadonly OUT NOCOPY BOOLEAN,
                           cancelReqVal OUT  NOCOPY VARCHAR2,
                           x_ret_stat OUT NOCOPY  VARCHAR2 );

END PO_CHANGE_RESPONSE_PVT;


/
