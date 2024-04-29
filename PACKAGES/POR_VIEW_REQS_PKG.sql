--------------------------------------------------------
--  DDL for Package POR_VIEW_REQS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_VIEW_REQS_PKG" AUTHID CURRENT_USER as
/* $Header: PORVRQSS.pls 120.5 2006/04/27 06:02:35 mkohale noship $ */

  function get_requester(req_Header_Id IN NUMBER) RETURN VARCHAR2;
  function get_deliver_to(req_Header_Id IN NUMBER) RETURN VARCHAR2;
  function get_note_to_agent(req_Header_Id IN NUMBER) RETURN VARCHAR2;
  function get_req_total(req_Header_Id IN NUMBER) RETURN NUMBER;
  function get_account_number(req_line_id IN NUMBER) RETURN VARCHAR2;
  function get_project_number(req_line_id IN NUMBER) RETURN VARCHAR2;
  function get_task_name(req_line_id IN NUMBER) RETURN VARCHAR2;
  function get_expenditure_type(req_line_id IN NUMBER) RETURN VARCHAR2;
  function get_supplier_name(req_header_id IN NUMBER) return VARCHAR2;
  function is_placedOnPO(req_header_id IN NUMBER) return VARCHAR2;
  function is_placedOnSO(req_header_id IN NUMBER) return VARCHAR2;
  function is_placedOnNG(req_header_id IN NUMBER) return VARCHAR2;
  /** bgu, Apr. 09, 1999
   *  Used to retrieve approver name for view por_approval_status_lines_v
   */
  function get_approver_name(approver_id IN NUMBER) RETURN VARCHAR2;
  function get_approver_email(approver_id IN NUMBER) RETURN VARCHAR2;
  function get_business_group_name(approver_id IN NUMBER) RETURN VARCHAR2;
  function get_shipment_number(req_line_id IN NUMBER) RETURN VARCHAR2;
  --Added additional parameter p_prefix_so_number
  function get_so_number_status(req_line_id NUMBER,p_prefix_so_number VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2;
  --Overloaded method to handle the Case if cinvoked from Lifecycle Page
  function get_so_number_status(req_line_id NUMBER,p_prefix_so_number VARCHAR2 DEFAULT 'Y',p_line_id IN NUMBER) RETURN VARCHAR2;
  function get_so_number_status_code(p_status_code IN VARCHAR2, p_line_id IN NUMBER, p_so_number IN NUMBER,p_prefix_so_number VARCHAR2 DEFAULT 'Y')
  RETURN VARCHAR2;

  function get_so_status(req_line_id NUMBER) RETURN VARCHAR2;
  procedure getLineInfo( reqHeaderId IN NUMBER,
			 currencyFormat IN VARCHAR2,
                         reqTotal OUT NOCOPY varchar2,
	                 supplierName OUT NOCOPY VARCHAR2,
			 placedOnPoFlag OUT NOCOPY VARCHAR2 );

  procedure getUnformattedLineInfo( reqHeaderId IN NUMBER,
			 currencyFormat IN VARCHAR2,
                         reqTotal OUT NOCOPY NUMBER,
	                 supplierName OUT NOCOPY VARCHAR2,
			 placedOnPoFlag OUT NOCOPY VARCHAR2 );

  function get_urgent_flag(req_header_id IN NUMBER) RETURN VARCHAR2;

  procedure getDistributionInfo(req_line_id IN NUMBER,
                                date_format IN VARCHAR2,
			        account_number OUT NOCOPY VARCHAR2,
                                project_id OUT NOCOPY NUMBER,
                                project_number OUT NOCOPY VARCHAR2,
                                task_id OUT NOCOPY NUMBER,
                                task_number OUT NOCOPY VARCHAR2,
	                        expenditure_type OUT NOCOPY VARCHAR2,
			        expenditure_org_id OUT NOCOPY NUMBER,
                                expenditure_org OUT NOCOPY VARCHAR2,
                                expenditure_item_date OUT NOCOPY VARCHAR2);

  function get_line_total(req_line_id IN NUMBER, currency_code IN VARCHAR2) RETURN VARCHAR2;

  function is_req_modified_by_buyer(reqHeaderId IN NUMBER) return varchar2;

  FUNCTION get_line_nonrec_tax_total(ReqLineId IN NUMBER) RETURN NUMBER;
  FUNCTION get_nonrec_tax_total(ReqHeaderId  IN NUMBER) RETURN NUMBER;
  FUNCTION get_line_rec_tax_total(ReqLineId IN NUMBER) RETURN NUMBER;

  pragma restrict_references(get_approver_name, WNDS, WNPS);

  pragma restrict_references(get_requester, WNDS, WNPS);
  pragma restrict_references(get_req_total, WNDS, WNPS);
  pragma restrict_references(get_note_to_agent, WNDS, WNPS);
  pragma restrict_references(get_account_number, WNDS, WNPS);
  pragma restrict_references(get_project_number, WNDS, WNPS);
  pragma restrict_references(get_task_name, WNDS, WNPS);
  pragma restrict_references(get_expenditure_type, WNDS, WNPS);
  pragma restrict_references(is_placedOnPO, WNDS, WNPS);
  pragma restrict_references(get_urgent_flag, WNDS);
  pragma restrict_references(get_line_total, WNDS, WNPS);
  pragma restrict_references(is_req_modified_by_buyer, WNDS, WNPS);

  -- FPJ new functions
  --FUNCTION GET_ORDER_NUM(p_req_header_id in number) RETURN varchar2;
  --FUNCTION GET_ORDER_SOURCE_TYPE(p_req_header_id in number) RETURN varchar2;
  FUNCTION GET_PO_RELEASE_ID(p_req_header_id in number) RETURN number;
  FUNCTION GET_PO_HEADER_ID(p_req_header_id in number) RETURN number;
  FUNCTION GET_CANCEL_FLAG(p_req_header_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION GET_RETURN_FLAG(p_txn_id IN NUMBER) RETURN VARCHAR2;
  FUNCTION GET_PURCHASING_ORG(p_req_header_id in number) RETURN varchar2;
  FUNCTION GET_PURCH_ORG_FOR_LINE(p_req_line_id in number) RETURN varchar2;
  function get_labor_line_supplier_name(req_line_id IN number) return varchar2;

  PROCEDURE GET_PO_INFO(p_req_header_id in number,
			p_po_header_id out NOCOPY number,
			p_po_release_id out NOCOPY number);

  --PROCEDURE GET_ORDER_INFO(p_req_header_id in number,
--			   order_number out NOCOPY varchar2,
--			   order_source_type out NOCOPY varchar2);

  PROCEDURE GET_ORDER_RELATED_INFO(p_req_header_id in number,
			   order_number out NOCOPY varchar2,
			   order_source_type out NOCOPY varchar2,
			   header_id out NOCOPY number,
			   po_release_id out NOCOPY number,
			   purchasing_org out NOCOPY varchar2,
			   placed_on_po_flag out NOCOPY varchar2,
			   order_status out NOCOPY varchar2);

--  FUNCTION GET_ORDER_TYPE(p_req_header_id in number) RETURN varchar2;

  PROCEDURE getCurrentApproverInfo(req_header_id IN NUMBER,
                      		   full_name OUT NOCOPY VARCHAR2,
                      		   email_address OUT NOCOPY VARCHAR2,
                                   phone OUT NOCOPY VARCHAR2,
                                   date_notified OUT NOCOPY DATE);

END por_view_reqs_pkg;


 

/
