--------------------------------------------------------
--  DDL for Package PO_REQ_LINES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_LINES_SV1" AUTHID CURRENT_USER as
/* $Header: POXRQL2S.pls 120.0.12010000.2 2010/05/25 08:45:24 debrchak ship $ */
/*===========================================================================
  PACKAGE NAME:		po_req_lines_sv1

  DESCRIPTION:		Contains all server side procedures that access
			requisition lines entity.

  CLIENT/SERVER:	Server

  LIBRARY NAME		None

  OWNER:		RMULPURY

  PROCEDURE NAMES:	get_vendor_sourcing_info
			val_src_details
			get_max_line_num
			update_modified_by_agent_flag
			get_cost_price
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_cost_price

  DESCRIPTION:		Obtain the cost price in the
			unit of measure passed in to this
			procedure.

  PARAMETERS:		x_item_id		IN  	NUMBER
			x_organization_id  	IN  	NUMBER
			x_unit_of_measure	IN  	NUMBER
			x_cost_price		OUT  	NUMBER


  DESIGN REFERENCES:	../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	16-APR-96	RMULPURY
===========================================================================*/

PROCEDURE get_cost_price (x_item_id		 IN  	NUMBER,
			  x_organization_id  	 IN  	NUMBER,
			  x_unit_of_measure	 IN  	VARCHAR2,
			  x_cost_price		 IN OUT	NOCOPY NUMBER);



/*===========================================================================
  PROCEDURE NAME:	get_vendor_sourcing_info

  DESCRIPTION:		Obtain the corresponding information
			for the values returned by the
			auto source user-exit when it is called
			in 'VENDOR' mode. Source document information
			is obtained as well.

  PARAMETERS:		x_vendor_id		IN  	NUMBER
			x_vendor_site_id  	IN  	NUMBER
			x_vendor_contact_id	IN  	NUMBER
			x_po_header_id		IN  	NUMBER
			x_document_type_code	IN  	VARCHAR2
		        x_buyer_id		IN  	NUMBER
			x_vendor_name		IN OUT	VARCHAR2
			x_vendor_location	IN OUT	VARCHAR2
			x_vendor_contact	IN OUT	VARCHAR2
			x_vendor_phone		IN OUT 	VARCHAR2
			x_po_num		IN OUT	VARCHAR2
			x_doc_type_disp		IN OUT	VARCHAR2
			x_buyer			IN OUT  VARCHAR2

  DESIGN REFERENCES:	../POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE get_vendor_sourcing_info (x_vendor_id		 IN  	NUMBER,
				    x_vendor_site_id  	 IN  	NUMBER,
				    x_vendor_contact_id	 IN  	NUMBER,
				    x_po_header_id	 IN  	NUMBER,
				    x_document_type_code IN  	VARCHAR2,
		        	    x_buyer_id		 IN  	NUMBER,
				    x_vendor_name	 IN OUT	NOCOPY VARCHAR2,
				    x_vendor_location	 IN OUT	NOCOPY VARCHAR2,
				    x_vendor_contact	 IN OUT	NOCOPY VARCHAR2,
				    x_vendor_phone	 IN OUT NOCOPY VARCHAR2,
				    x_po_num		 IN OUT	NOCOPY VARCHAR2,
				    x_doc_type_disp	 IN OUT	NOCOPY VARCHAR2,
				    x_buyer		 IN OUT NOCOPY VARCHAR2);




/*===========================================================================
  PROCEDURE NAME:	val_src_details

  DESCRIPTION:		Cover for the validation of the following
			destination fields:

			- Source type
			- Source Organization Id
			- Source Organization
			- Source Organization Code
			- Source Subinventory


			This procedure copies null
			values into the invalid columns.

  PARAMETERS:		x_src_org_id		IN OUT NUMBER
			x_src_org		IN OUT VARCHAR2
			x_src_org_code		IN OUT VARCHAR2
			x_item_id		IN NUMBER
			x_item_rev		IN VARCHAR2
			x_inv_org_id		IN NUMBER
			x_outside_op_line_type  IN VARCHAR2
			x_mrp_planned_item	IN VARCHAR2
			x_src_sub		IN VARCHAR2
			x_src_type		IN VARCHAR2
			x_dest_type		IN VARCHAR2
			x_dest_org_id		IN NUMBER
			x_dest_sub		IN VARCHAR2
			x_deliver_to_loc_id	IN NUMBER
			x_val_code		IN VARCHAR2
			x_sob_id		IN OUT NUMBER

			Valid codes: 'ALL' - Validate source type and details
				     'ORG' - Validate source org and sub.
				     'SUB' - Validate source sub.


  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/

PROCEDURE val_src_details ( x_src_org_id		IN OUT NOCOPY NUMBER,
			    x_src_org			IN OUT NOCOPY VARCHAR2,
			    x_src_org_code		IN OUT NOCOPY VARCHAR2,
			    x_item_id			IN NUMBER,
			    x_item_rev			IN VARCHAR2,
			    x_inv_org_id		IN NUMBER,
			    x_outside_op_line_type	IN VARCHAR2,
			    x_mrp_planned_item		IN VARCHAR2,
			    x_src_sub			IN OUT NOCOPY VARCHAR2,
			    x_src_type			IN OUT NOCOPY VARCHAR2,
			    x_dest_type			IN VARCHAR2,
			    x_dest_org_id		IN VARCHAR2,
			    x_dest_sub			IN VARCHAR2,
			    x_deliver_to_loc_id		IN NUMBER,
			    x_val_code			IN VARCHAR2,
			    x_sob_id			IN OUT NOCOPY NUMBER);




/*===========================================================================
  FUNCTION NAME:	get_max_line_num

  DESCRIPTION:		This function gets the maximum value of
			of the line number for a requisition.

  PARAMETERS:		X_header_id	NUMBER


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	06/06	Created
===========================================================================*/

FUNCTION get_max_line_num (x_header_id   IN NUMBER)
	 return number;

-- pragma restrict_references (get_max_line_num,WNDS);



/*===========================================================================
  PROCEDURE NAME:	update_modified_by_agent_flag

  DESCRIPTION:		This routine updates the modified_by_agent_flag
			for requisition lines which have been
		        modified.

  PARAMETERS:		x_req_line_id
			x_agent_id


  DESIGN REFERENCES:	MODIFY_REQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	RMULPURY	10/14	Created
===========================================================================*/

PROCEDURE update_modified_by_agent_flag(x_req_line_id   IN  NUMBER,
					x_agent_id	IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME:	update_transfer_price

  DESCRIPTION:		fetches and Updates into po_requisitions_interface.
  			Takes request_id and fecth required information
  			from po_requisitions_interface table.
  			Internally it uses API
  			GMF_get_transfer_price_PUB.get_transfer_price.

  PARAMETERS:		x_request_id		IN  	NUMBER


===========================================================================*/

PROCEDURE update_transfer_price (p_request_id	IN  	NUMBER);

END po_req_lines_sv1;


/
