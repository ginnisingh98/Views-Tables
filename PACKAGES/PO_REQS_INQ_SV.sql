--------------------------------------------------------
--  DDL for Package PO_REQS_INQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQS_INQ_SV" AUTHID CURRENT_USER as
/* $Header: POXRQVRS.pls 115.7 2003/07/23 17:33:23 dreddy ship $ */
/*===========================================================================
  PACKAGE NAME:		PO_REQS_INQ_SV

  DESCRIPTION:		This package contains the server side Requisition Inquiry
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Wilson Lau

  FUNCTION/PROCEDURE:
===========================================================================*/


/*===========================================================================
  FUNCTION  NAME:	get_po_number

  DESCRIPTION:		This procedure returns PO number

  PARAMETERS:		In : PO_header_id of PO_header

			Out: PO_number


  DESIGN REFERENCES:	../POXRQVRQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		25-AUG-95	WLAU
===========================================================================*/
FUNCTION  get_po_number (x_po_header_id IN NUMBER)
				RETURN VARCHAR2;

-- pragma restrict_references (get_po_number,WNDS,RNPS,WNPS);

/*===========================================================================
  FUNCTION  NAME:	get_reserved_flag

  DESCRIPTION:		This procedure returns funds reserved status flag
                        for the requisition

  PARAMETERS:		In : requisition_header_id of requisition_header

			Out: reserved_flag


  DESIGN REFERENCES:	../POXRQVRQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		25-AUG-95	WLAU
===========================================================================*/
FUNCTION  get_reserved_flag (x_requisition_header_id IN NUMBER)
							RETURN VARCHAR2;
-- pragma restrict_references (get_reserved_flag,WNDS);


/*===========================================================================
  FUNCTION  NAME:	get_shipped_quantity

  DESCRIPTION:		This procedure returns the shipped quantity
                        from sales order for the internal requisition.

  PARAMETERS:		In : requisition_number and line_number      --obsolete
                             of requisition_line

				requisition_header_id and requisition_line_id

			Out: Sales order shipped quantity


  DESIGN REFERENCES:	../POXRQVRQ.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		12-SEP-95	WLAU
===========================================================================*/
--Bug# 1392077
--Toju George 08/31/2000
--Modified the procedure to replace req_num and line_num with ids.
/*FUNCTION  get_shipped_quantity (x_requisition_num IN VARCHAR2,
                                x_line_num        IN VARCHAR2)
   				RETURN NUMBER;
*/
FUNCTION  get_shipped_quantity (x_requisition_header_id IN VARCHAR2,
                                x_requisition_line_id   IN VARCHAR2)
   				RETURN NUMBER;
/*===========================================================================*/

/*===========================================================================
  PROCEDURE  NAME:	po_req_header_inq_wrapper

  DESCRIPTION:		This procedure calls
			PO_CORE_S.GET_TOTAL
			PO_REQS_INQ_SV.GET_RESERVER_FLAG
			PO_INQ_SV.GET_PERSON_NAME.
			It is called during post-query for requisition summary
			headers.

  PARAMETERS:		In : 	requisition_number
			     	preparer_id

			Out: 	req_header_amount
				reserved_flag
				perparer_name


  DESIGN REFERENCES:	performance fix bug 414200

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		29-OCT-96	ecso
===========================================================================*/
PROCEDURE po_req_header_inq_wrapper (x_req_num IN NUMBER,
				     x_preparer IN NUMBER,
	  			     x_req_header_amount OUT NOCOPY NUMBER,
				     x_reserved_flag OUT NOCOPY VARCHAR2,
				     x_preparer_name OUT NOCOPY VARCHAR2);

/*===========================================================================*/
/*===========================================================================
  PROCEDURE  NAME:	po_req_line_inq_wrapper

  DESCRIPTION:		This procedure calls
			PO_INQ_SV.GET_PERSON_NAME
			PO_INQ_SV.GET_ASSEMBLY_QUANTITY
			PO_INQ_SV.GET_RESOURCE_QUANTITY
			PO_INQ_SV.GET_WIP_OPERATION_CODE
			PO_INQ_SV.GET_BOM_DEPARTMENT_CODE
			PO_REQS_INQ_SV.GET_PO_NUMBER
			PO_INQ_SV.GET_PO_NUMBER
			PO_INQ_SV.GET_SO_NUMBER
			PO_CORE_S.GET_TOTAL

			It is called during post-query for requisition summary
			lines.

  PARAMETERS:		In : 	x_to_person_id
				x_suggested_buyer_id
				x_item_id
				x_wip_entity_id
				x_wip_operation_seq_num
				x_wip_resource_seq_num
				x_destination_organization_id
				x_wip_repetitive_schedule_id
				x_quantity
				x_purchasing_agent_id
				x_preparer_id
				x_blanket_po_header_id
				x_source_type_code
				x_line_location_id
				x_segment1
				x_line_num
				x_requsition_line_id

			Out: 	v_requestor
				v_suggested_buyer
				v_assembly_quantity
				v_resource_quantity
				v_wip_operation_code
				v_bom_department_code
				v_purchasing_agent_name_dsp
				v_preparer_name
				v_blanket_po_num_dsp
				v_order_num
				v_req_line_amount


  DESIGN REFERENCES:	performance fix bug 414200

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		30-OCT-96	ecso
===========================================================================*/
PROCEDURE po_req_line_inq_wrapper (x_to_person_id 		IN NUMBER,
				x_suggested_buyer_id		IN NUMBER,
				x_item_id			IN NUMBER,
				x_wip_entity_id			IN NUMBER,
				x_wip_operation_seq_num		IN NUMBER,
				x_wip_resource_seq_num		IN NUMBER,
				x_destination_organization_id	IN NUMBER,
				x_wip_repetitive_schedule_id	IN NUMBER,
				x_quantity			IN NUMBER,
				x_purchasing_agent_id		IN NUMBER,
				x_preparer_id			IN NUMBER,
				x_blanket_po_header_id		IN NUMBER,
				x_source_type_code		IN VARCHAR2,
				x_line_location_id		IN NUMBER,
				x_segment1			IN VARCHAR2,
				x_line_num			IN NUMBER,
				x_requsition_line_id		IN NUMBER,
			 	v_requestor			OUT NOCOPY VARCHAR2,
				v_suggested_buyer		OUT NOCOPY VARCHAR2,
				v_assembly_quantity		OUT NOCOPY NUMBER,
				v_resource_quantity		OUT NOCOPY NUMBER,
				v_wip_operation_code		OUT NOCOPY VARCHAR2,
				v_bom_department_code		OUT NOCOPY VARCHAR2,
				v_purchasing_agent_name_dsp	OUT NOCOPY VARCHAR2,
				v_preparer_name			OUT NOCOPY VARCHAR2,
				v_blanket_po_num_dsp		OUT NOCOPY VARCHAR2,
				v_order_num			OUT NOCOPY VARCHAR2,
				v_req_line_amount		OUT NOCOPY NUMBER,
--Bug# 1392077
--Toju George 08/31/2000
--Modified the procedure to include the requisition header id.
			        x_requisition_header_id         IN  VARCHAR2
				);

/*===========================================================================*/
/*===========================================================================
  PROCEDURE  NAME:	po_req_dist_inq_wrapper

  DESCRIPTION:		This procedure calls
			PO_INQ_SV.GET_PERSON_NAME
			PO_CORE_S.GET_TOTAL

			It is called during post-query for requisition summary
			distributions.

  PARAMETERS:		In : 	x_to_person_id
				x_suggested_buyer_id
				x_preparer_id
				x_distribution_id

			Out: 	v_requestor
				v_suggested_buyer
				v_preparer_name
				v_req_distribution_amount


  DESIGN REFERENCES:	performance fix bug 414200

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		30-OCT-96	ecso
===========================================================================*/
PROCEDURE po_req_dist_inq_wrapper (x_to_person_id 		IN NUMBER,
				x_suggested_buyer_id		IN NUMBER,
				x_preparer_id			IN NUMBER,
				x_distribution_id		IN NUMBER,

			 	v_requestor			OUT NOCOPY VARCHAR2,
				v_suggested_buyer		OUT NOCOPY VARCHAR2,
				v_preparer_name			OUT NOCOPY VARCHAR2,
				v_req_distribution_amount	OUT NOCOPY NUMBER);

/*===========================================================================*/
/*===========================================================================

  PROCEDURE NAME:    get_reqln_pq_lookups
  Bug# 1934593
  This procedure fetches the lookup values removed from the view
  po_requisition_lines_inq_v as part of the performance fix

===========================================================================*/
PROCEDURE get_reqln_pq_lookups( x_auth_status_code           in   varchar2,
                                x_tran_reason_code           in   varchar2,
                                x_src_doc_type_code          in   varchar2,
                                x_dest_type_code             in   varchar2,
                                x_src_type_code              in   varchar2,
                                x_auth_status_dsp       in out NOCOPY  varchar2,
                                x_tran_reason_dsp       in out NOCOPY  varchar2,
                                x_src_doc_type_dsp      in out NOCOPY  varchar2,
                                x_dest_type_dsp         in out NOCOPY  varchar2,
                                x_src_type_dsp          in out NOCOPY  varchar2);

/*===========================================================================

  PROCEDURE NAME:	get_ga_info

===========================================================================*/
PROCEDURE  get_ga_info   (X_po_header_id	IN NUMBER,
                          X_ga_flag             IN OUT NOCOPY VARCHAR2,
                          X_owning_org_name     IN OUT NOCOPY VARCHAR2 ) ;

/*===========================================================================

  FUNCTION NAME:	get_req_amount
  DESCRIPTION  :        Gets the amounts on the req line/distribution
                        < SERVICES FPJ >

===========================================================================*/
FUNCTION   get_req_amount  (p_mode    	          IN  VARCHAR2,
                            p_req_entity_id       IN  NUMBER)
RETURN NUMBER;

END PO_REQS_INQ_SV;

 

/
