--------------------------------------------------------
--  DDL for Package PO_BUYER_WORKLOAD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_BUYER_WORKLOAD_SV" AUTHID CURRENT_USER AS
/* $Header: POXBWMWS.pls 120.0 2005/06/01 13:01:09 appldev noship $*/

/*===========================================================================
  PROCEDURE NAME:       get_num_unassigned()

  DESCRIPTION:          Determines the number of unassigned requistions that meet
		        search criteria.  Alse determines the number that
			are late, urgent and needed within a range of needby dates.

  PARAMETERS:           x_needby_date_low		IN	DATE,
			x_needby_date_high		IN	DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
			x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_num_reqs			IN OUT	NUMBER,
			x_num_urgent			IN OUT	NUMBER,
			x_num_late			IN OUT	NUMBER,
			x_num_needed			IN OUT	NUMBER

  DESIGN REFERENCES:    POXRQARQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       CMOK    6/21     Created
===========================================================================*/

  PROCEDURE get_num_unassigned (x_needby_date_low	IN	DATE,
			x_needby_date_high		IN	DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
			x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_unassigned_reqs		IN OUT	NOCOPY NUMBER,
			x_unassigned_urgent		IN OUT	NOCOPY NUMBER,
			x_unassigned_late		IN OUT	NOCOPY NUMBER,
			x_unassigned_needed		IN OUT	NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:       get_num_assigned()

  DESCRIPTION:          Determines the number of requistions assigned to a buyer
			that meet search criteria.  Also determines the number that
			are late, urgent and needed within a range of needby dates.

  PARAMETERS:           x_buyer_id			IN	NUMBER,
			x_needby_date_low		IN	DATE,
			x_needby_date_high		IN  	DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
			x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_num_reqs			IN OUT	NUMBER,
			x_num_urgent			IN OUT	NUMBER,
			x_num_late			IN OUT	NUMBER,
			x_num_needed			IN OUT	NUMBER

  DESIGN REFERENCES:    POXRQARQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       CMOK    6/21     Created
===========================================================================*/

  PROCEDURE get_num_assigned (
			x_buyer_id			IN	NUMBER,
			x_needby_date_low		IN	DATE,
			x_needby_date_high		IN      DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
	 		x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list 		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_num_reqs			IN OUT	NOCOPY NUMBER,
			x_num_urgent			IN OUT	NOCOPY NUMBER,
			x_num_late			IN OUT	NOCOPY NUMBER,
			x_num_needed			IN OUT	NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:       update_buyer_by_rowid()

  DESCRIPTION:          Updates requisition lines with the new suggested buyer.

  PARAMETERS:           x_new_buyer_id  IN NUMBER,
			x_rowid	 	IN ROWID,
			x_user_id	IN NUMBER,
			x_login_id 	IN NUMBER

  DESIGN REFERENCES:    POXRQARQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       CMOK    6/21     Created
===========================================================================*/

  PROCEDURE update_buyer_by_rowid(x_new_buyer_id  IN NUMBER,
				  x_rowid	  IN VARCHAR2,
				  x_user_id	  IN NUMBER,
				  x_login_id 	  IN NUMBER);

  PROCEDURE update_buyers(
			x_new_buyer_id			IN	NUMBER,
			x_old_buyer_id			IN	NUMBER,
			x_needby_date_low		IN	DATE,
			x_needby_date_high		IN	DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
			x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_assigned_list			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_user_id			IN	NUMBER,
			x_login_id			IN 	NUMBER);


  FUNCTION num_open_po (x_agent_id  IN NUMBER)
	return NUMBER;
--  pragma restrict_references (num_open_po, WNDS, RNPS, WNPS);

--<ACHTML R12 Start>
PROCEDURE REQ_REASSIGN_ACTION_BULK( p_api_version     IN NUMBER
                                   ,x_return_status   OUT NOCOPY VARCHAR2
                                   ,x_error_message   OUT NOCOPY VARCHAR2
                                   ,p_employee_id     IN NUMBER
                                   ,p_req_line_id_tbl IN PO_TBL_NUMBER
                                   ,p_new_buyer_id    IN NUMBER);
--<ACHTML R12 End>
END;

 

/
