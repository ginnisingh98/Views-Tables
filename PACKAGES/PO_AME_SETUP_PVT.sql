--------------------------------------------------------
--  DDL for Package PO_AME_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AME_SETUP_PVT" AUTHID CURRENT_USER as
/* $Header: POXAMESS.pls 120.0.12010000.4 2013/05/28 19:05:27 pravprak ship $ */

FUNCTION get_function_currency(reqHeaderId IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_rate_type(reqHeaderId IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_accounting_flex(segmentName IN VARCHAR2, distributionId IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_changed_req_total(ReqHeaderId IN NUMBER)
RETURN NUMBER;

function get_new_req_header_id (oldReqHeaderId IN  NUMBER) return number;

FUNCTION is_system_approver_mandatory(reqHeaderId IN NUMBER)
RETURN VARCHAR2;

FUNCTION can_preparer_approve(reqHeaderId IN NUMBER)
RETURN VARCHAR2;

/*AME Project Start*/
FUNCTION can_preparer_approve_po(ameApprovalId IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_system_app_mandatory_po(ameApprovalId IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_function_currency_po(ameApprovalId IN NUMBER)
RETURN VARCHAR2;

FUNCTION get_accounting_flex_po(segmentName IN VARCHAR2, distributionId IN NUMBER, draftId IN NUMBER )
RETURN VARCHAR2;

/*AME Project End*/

/*Bug 16775048*/
FUNCTION get_trans_req_person_id(ameApprovalId IN NUMBER)
RETURN NUMBER;
/*<end> Bug 16775048*/

END PO_AME_SETUP_PVT;

/
