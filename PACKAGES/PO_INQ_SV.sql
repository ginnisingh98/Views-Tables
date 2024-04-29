--------------------------------------------------------
--  DDL for Package PO_INQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INQ_SV" AUTHID CURRENT_USER as
/* $Header: POXPOVPS.pls 120.2.12010000.2 2012/05/03 11:12:53 vegajula ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_INQ_SV

  DESCRIPTION:		This package contains the server side PO Inquiry
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Gopi Tummala

  FUNCTION/PROCEDURE:
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	get_action_history_values ()

  DESCRIPTION:		This procedure will get the startup values for the
			action history form. Several sql stmnts are included
			in here to save network roundtrips.


   PARAMETERS:		Input paramters: document id
					 document type
					 document subtype -- comes in as null but
							     needed otherwise cannot
							     read its value in plsql.
                        Output parameters :  document subtype
					     document preparer
					     security level
					     security_hierarchy_id

  DESIGN REFERENCES:	../POXPOAH.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		19-JUL-95	GTUMMALA
===========================================================================*/
PROCEDURE get_action_history_values (x_object_id        	IN 	NUMBER,
				     x_object_type_code 	IN 	VARCHAR2,
				     x_subtype_code    	 	IN OUT NOCOPY 	VARCHAR2,
				     x_type_name		OUT	NOCOPY VARCHAR2,
				     x_document_number		OUT	NOCOPY VARCHAR2,
				     x_preparer_id		OUT NOCOPY 	NUMBER,
				     x_security_level   	OUT NOCOPY 	VARCHAR2,
				     x_security_hierarchy_id    OUT NOCOPY 	NUMBER);


/*===========================================================================
  PROCEDURE NAME:	get_po_doc_access_sec_level ()

  DESCRIPTION:		This procedure will get the access and secruity level
                        for each of the four types of Purchase Orders and two
			Release types in addition to the security hierarchy.


   PARAMETERS:		No input parameters.
                        Output parameters are the  security level
			for each type of PO and Release in addition to the
			security hierarchy.

  DESIGN REFERENCES:	../POXPOVPO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		16-JUN-95	GTUMMALA
===========================================================================*/
PROCEDURE get_po_doc_access_sec_level(x_standard_security      OUT NOCOPY  VARCHAR2,
         			      x_blanket_security       OUT NOCOPY  VARCHAR2,
         			      x_contract_security      OUT NOCOPY  VARCHAR2,
         			      x_planned_security       OUT NOCOPY  VARCHAR2,
         			      x_blanket_rel_security   OUT NOCOPY  VARCHAR2,
         			      x_scheduled_rel_security OUT NOCOPY  VARCHAR2,
				      x_security_hierarchy_id  OUT NOCOPY  NUMBER);


/*===========================================================================
  FUNCTION NAME:	get_active_enc_amount()

  DESCRIPTION:		This function returns the active encumbrance amount
			of the given po_distribtuion

  PARAMETERS:		In: rate of the dist.
			    ecumbered amount of dist.
			    shipment_type of the line.
			    po_distribution_id of dist.

			Out: active encumbrance amount for the dist.

  DESIGN REFERENCES:	../POXPOVPO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-JUL-95	GTUMMALA
===========================================================================*/
FUNCTION  get_active_enc_amount(x_rate 			IN NUMBER,
				x_enc_amount    	IN NUMBER,
				x_shipment_type		IN VARCHAR2,
				x_po_distribution_id	IN NUMBER )
							RETURN NUMBER;
--pragma restrict_references (get_active_enc_amount,WNDS,RNPS,WNPS);


/*===========================================================================
  FUNCTION NAME:	get_dist_amount()

  DESCRIPTION:		This function returns the distribution amount
			of the given po_distribtuion

  PARAMETERS:		In:
			    quantity ordered of dist.
			    unit price of the line.
			    po_distribution_id of dist.

			Out: amount for the dist.

  DESIGN REFERENCES:	../POXPOVPO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-JUL-95	GTUMMALA
===========================================================================*/
/* Changed due to bug 601388
  Removed IN parameter x_rate from the function as price is required in
  foreign currency and not functional currency
*/

FUNCTION get_dist_amount
(   p_quantity_ordered      IN      NUMBER                    -- <SERVICES FPJ>
,   p_price_override	    IN      NUMBER                    -- <SERVICES FPJ>
,   p_amount_ordered        IN      NUMBER                    -- <SERVICES FPJ>
,   p_po_line_loc_id         IN      NUMBER                    -- <Complex Work R12>
,   p_po_distribution_id    IN 		NUMBER					  --Bug 13440718
) RETURN NUMBER;
-- pragma restrict_references (get_dist_amount,WNDS,RNPS,WNPS);

/*===========================================================================
  PROCEDURE NAME:	get_func_currency_attributes()

  DESCRIPTION:		This procedure returns the several attributes of the
			functional currency from fnd_currencies.

  PARAMETERS:		In : None
			Out: min_accountable_unit of the currency
		             precision of the currecny

  DESIGN REFERENCES:	../POXPOVPO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-JUL-95	GTUMMALA
===========================================================================*/
PROCEDURE  get_func_currency_attributes(x_min_unit   OUT NOCOPY NUMBER,
  				        x_precision  OUT NOCOPY NUMBER);

-- pragma restrict_references (get_func_currency_attributes,WNDS,RNPS,WNPS);


/*===========================================================================
  FUNCTION  NAME:	get_person_name

  DESCRIPTION:		This procedure returns the full_name
			of the person based on the id.

  PARAMETERS:		In : Id of the person
			Out: Full name of the person


  DESIGN REFERENCES:	../POXPOVPO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-JUL-95	GTUMMALA
===========================================================================*/
FUNCTION  get_person_name (x_person_id 		IN  NUMBER)
							RETURN VARCHAR2;

-- pragma restrict_references (get_person_name,WNDS,WNPS);

/* GK - removed RNPS for the package to compile; still need to
   investigate the consequences */

/*===========================================================================
  FUNCTION  NAME:	get_wip_operation_code

  DESCRIPTION:		THIS PROCEDURE RETURNS WIP_OPERATION_CODE
			FOR THE PO DISTRIBUTION

  PARAMETERS:		IN : WIP_ENTITY_ID              OF PO DISTRIBUTION
                             WIP_OPERATION_SEQ_NUM      "  "  "
   			     DESTINATION_ORGANIZATION_ID"  "  "
			     WIP_REPETITIVE_SCHEDULE_ID "  "  "

			OUT: WIP_OPERATION_CODE


  DESIGN REFERENCES:	../POXPOVPO.DD

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	CREATED		11-JUL-95	GTUMMALA
===========================================================================*/
FUNCTION  GET_WIP_OPERATION_CODE(X_WIP_ENTITY_ID 	 IN  NUMBER,
				 X_WIP_OPERATION_SEQ_NUM IN  NUMBER,
				 X_DESTINATION_ORG_ID    IN  NUMBER,
				 X_WIP_REP_SCHEDULE_ID   IN  NUMBER)
							RETURN VARCHAR2;

-- PRAGMA RESTRICT_REFERENCES (GET_WIP_OPERATION_CODE,WNDS,RNPS,WNPS);

/*===========================================================================
  FUNCTION  NAME:	GET_BOM_DEPARTMENT_CODE

  DESCRIPTION:		THIS PROCEDURE RETURNS BOM_DEPARTMENT_CODE
			FOR THE PO DISTRIBUTION

  PARAMETERS:		IN : WIP_ENTITY_ID              OF PO DISTRIBUTION
                             WIP_OPERATION_SEQ_NUM      "  "  "
   			     DESTINATION_ORGANIZATION_ID"  "  "
			     WIP_REPETITIVE_SCHEDULE_ID "  "  "

			OUT: BOM_DEPARTMENT_CODE


  DESIGN REFERENCES:	../POXPOVPO.DD

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	CREATED		11-JUL-95	GTUMMALA
===========================================================================*/
FUNCTION  GET_BOM_DEPARTMENT_CODE(X_WIP_ENTITY_ID 	 IN  NUMBER,
				 X_WIP_OPERATION_SEQ_NUM IN  NUMBER,
				 X_DESTINATION_ORG_ID    IN  NUMBER,
				 X_WIP_REP_SCHEDULE_ID   IN  NUMBER)
							RETURN VARCHAR2;

-- PRAGMA RESTRICT_REFERENCES (GET_BOM_DEPARTMENT_CODE,WNDS,RNPS,WNPS);

/*===========================================================================
  FUNCTION  NAME:	get_assembly_quantity

  DESCRIPTION:		This function returns the bom_department_code for
			the distribution.

  PARAMETERS:		IN : item_id			of po line
			     wip_entity_id              of po distribution
                             wip_operation_seq_num      "  "  "
			     wip_resource_seq_num	"  "  "
   			     Destination_organization_id"  "  "
			     wip_repetitive_schedule_id "  "  "
			     quantity_ordered		"  "  "

			Out: assembly quantity for the distribution


  DESIGN REFERENCES:	../POXPOVPO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-JUL-95	GTUMMALA

===========================================================================*/
FUNCTION  get_assembly_quantity(x_item_id  		IN NUMBER,
				x_wip_entity_id 	IN NUMBER,
				x_wip_operation_seq_num IN NUMBER,
				x_wip_resource_seq_num  IN NUMBER,
				x_destination_org_id 	IN NUMBER,
				x_wip_rep_schedule_id   IN NUMBER,
				x_quantity_ordered	IN NUMBER,
                                p_item_organization_id  IN NUMBER DEFAULT NULL) -- <HTMLAC>
							RETURN NUMBER;

-- pragma restrict_references (get_assembly_quantity,WNDS,RNPS,WNPS);


/*===========================================================================
  FUNCTION  NAME:	get_resource_quantity

  DESCRIPTION:		This procedure returns bom_department_code
			for the po distribution

  PARAMETERS:		In : item_id 			of po line
			     wip_entity_id              of po distribution
                             wip_operation_seq_num      "  "  "
			     wip_resource_seq_num	"  "  "
   			     destination_organization_id"  "  "
			     wip_repetitive_schedule_id "  "  "
			     quantity_ordered		"  "  "

			Out: resource quantity for the distribution


  DESIGN REFERENCES:	../POXPOVPO.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		11-JUL-95	GTUMMALA
===========================================================================*/
FUNCTION  get_resource_quantity(x_item_id  		IN NUMBER,
				x_wip_entity_id 	IN NUMBER,
				x_wip_operation_seq_num IN NUMBER,
				x_wip_resource_seq_num  IN NUMBER,
				x_destination_org_id 	IN NUMBER,
				x_wip_rep_schedule_id   IN NUMBER,
				x_quantity_ordered	IN NUMBER,
                                p_item_organization_id  IN NUMBER DEFAULT NULL) -- <HTMLAC>
							RETURN NUMBER;

-- pragma restrict_references (get_resource_quantity,WNDS,RNPS,WNPS);


/*===========================================================================
  FUNCTION  NAME:	get_po_number

  DESCRIPTION:		This procedure returns the po number that a
			requisition line is on.

  PARAMETERS:		In : line_location_id

			Out: po_number


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		20-FEB-96	GTUMMALA
===========================================================================*/
FUNCTION  get_po_number (x_line_location_id  IN NUMBER) RETURN VARCHAR2;


-- pragma restrict_references (get_po_number,WNDS,RNPS,WNPS);


/*===========================================================================
  FUNCTION  NAME:	get_so_number

  DESCRIPTION:		This procedure returns the sales order number that a
			requisition line is on.

  PARAMETERS:		In : segment1(req_num), --obsolete
			     line_num                   --obsolete

                   po_requisition_header_id
				   po_requisition_line_id

			Out: so_number


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		20-FEB-96	GTUMMALA
===========================================================================*/

--Bug# 1392077
--Toju George 08/31/2000
--Modified the call to procedure to replace req_num and line_num with ids.

/*FUNCTION  get_so_number (x_segment1 IN VARCHAR2,
			 x_line_num IN NUMBER) RETURN VARCHAR2;*/

 FUNCTION  get_so_number (x_requisition_header_id IN VARCHAR2,
			 x_requisition_line_id IN NUMBER) RETURN VARCHAR2;

 /* pragma restrict_references (get_so_number,WNDS,RNPS,WNPS);*/

/*===========================================================================
  FUNCTION  NAME:	shipment_from_req

  DESCRIPTION:		This function check whether a shipment is associated
			with a requisition line.

  PARAMETERS:		In : line_location_id

			Returns: TRUE OR FALSE


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		28-FEB-96	CMOK
===========================================================================*/

FUNCTION shipment_from_req  (x_line_location_id	  IN  NUMBER)
	RETURN BOOLEAN ;

/*===========================================================================
  FUNCTION  NAME:	get_po_total

  DESCRIPTION:		This function returns the total on a PO or Release.
			It is called by the view PO_HEADERS_INQ_V

  PARAMETERS:		In : type_lookup_code
			     po_header_id
			     po_release_id

			Returns: PO total


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		28-FEB-96	CMOK
===========================================================================*/

FUNCTION get_po_total (x_type_lookup_code  IN  VARCHAR2,
		       x_po_header_id	   IN  NUMBER,
		       x_po_release_id     IN  NUMBER)
	return NUMBER;

-- pragma restrict_references (get_po_total,WNDS);

/*===========================================================================
  FUNCTION  NAME:	get_post_query_info

  DESCRIPTION:		This procedure is called in post-query for
			the headers, lines and shipments folders.  The purpose
			of this procedure is to reduce the round-trips to
			the server in the post-query.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		28-OCT-96	CMOK
===========================================================================*/

PROCEDURE get_post_query_info (
			x_cancelled_by	    	IN     NUMBER,
			x_closed_by	    	IN     NUMBER,
			x_agent_id		IN     NUMBER,
			x_type_lookup_code  	IN  VARCHAR2,
		        x_po_header_id	    	IN  NUMBER,
		        x_po_release_id     	IN  NUMBER,
			x_po_line_id		IN     NUMBER,
			x_line_location_id	IN     NUMBER,
			x_agent_name		IN OUT NOCOPY VARCHAR2,
			x_closed_by_name    	IN OUT NOCOPY VARCHAR2,
			x_cancelled_by_name 	IN OUT NOCOPY VARCHAR2,
			x_base_currency		IN OUT NOCOPY VARCHAR2,
			x_amount		IN OUT NOCOPY NUMBER);


/*===========================================================================
  FUNCTION  NAME:	get_distribution_info

  DESCRIPTION:		This procedure is called in post-query for
			the distribution folder.  The purpose
			of this procedure is to reduce the round-trips to
			the server in the post-query.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created		28-OCT-96	CMOK
===========================================================================*/

PROCEDURE get_distribution_info (
			x_deliver_to_person_id  IN     NUMBER,
			x_closed_by	    	IN     NUMBER,
			x_agent_id		IN     NUMBER,
			x_item_id		IN     NUMBER,
			x_wip_entity_id		IN     NUMBER,
			x_wip_operation_seq_num IN     NUMBER,
			x_wip_resource_seq_num  IN     NUMBER,
			x_destination_org_id    IN     NUMBER,
			x_wip_rep_schedule_id   IN     NUMBER,
			x_quantity_ordered	IN     NUMBER,
			x_rate			IN     NUMBER,
			x_price_override	IN     NUMBER,
            x_amount_ordered    IN     NUMBER,                -- <SERVICES FPJ>
            x_po_line_id        IN     NUMBER,                -- <SERVICES FPJ>
			x_line_location_id	IN     NUMBER,
			x_encumbered_amount	IN     NUMBER,
			x_shipment_type		IN     VARCHAR2,
			x_po_distribution_id    IN     NUMBER,
			x_deliver_to_person	IN OUT NOCOPY VARCHAR2,
			x_agent_name		IN OUT NOCOPY VARCHAR2,
			x_closed_by_name    	IN OUT NOCOPY VARCHAR2,
			x_base_currency		IN OUT NOCOPY VARCHAR2,
			x_assembly_quantity	IN OUT NOCOPY NUMBER,
		        x_resource_quantity	IN OUT NOCOPY NUMBER,
			x_wip_operation_code    IN OUT NOCOPY VARCHAR2,
			x_bom_department_code   IN OUT NOCOPY VARCHAR2,
			x_active_encumb_amount   IN OUT NOCOPY NUMBER,
			x_distribution_amount	IN OUT NOCOPY NUMBER);


/*===========================================================================
  FUNCTION  NAME:	get_org_info

  DESCRIPTION:		This procedure is called in get_dist_info_pq
			to get the organization names corresponding
                        to the ids
                        bug 1338674

  CHANGE HISTORY:	Created		19-JUL-00	dreddy
===========================================================================*/
 PROCEDURE get_org_info(x_destination_org_id  IN  number,
                        x_expenditure_org_id  IN  number,
                        x_ship_to_org_id      IN  number ,
                        x_dest_org_name       IN OUT NOCOPY  varchar2,
                        x_exp_org_name        IN OUT NOCOPY  varchar2,
                        x_ship_to_org_name    IN OUT NOCOPY  varchar2) ;


/*===========================================================================
  FUNCTION  NAME:	get_location_info

  DESCRIPTION:		This procedure is called in get_dist_info_pq
			to get the location names corresponding
                        to the ids -  bug 1338674

  CHANGE HISTORY:	Created		19-JUL-00	dreddy
===========================================================================*/
PROCEDURE get_location_info(x_deliver_to_loc_id   IN  number,
                           x_bill_to_loc_id      IN  number,
                           x_ship_to_loc_id      IN  number ,
                           x_dest_location_code  IN OUT NOCOPY  varchar2,
                           x_bill_to_loc_code    IN OUT NOCOPY  varchar2,
                           x_ship_to_loc_code    IN OUT NOCOPY  varchar2);


/*===========================================================================
  FUNCTION  NAME:	get_project_info

  DESCRIPTION:		This procedure is called in get_dist_info_pq
			to get the project/task numbers corresponding
                        to the ids  -  bug 1338674

  CHANGE HISTORY:	Created		19-JUL-00	dreddy
===========================================================================*/
PROCEDURE get_project_info(x_project_id   IN number,
                           x_task_id      IN number,
                           x_project_num  IN OUT NOCOPY varchar2,
                           x_task_num     IN OUT NOCOPY varchar2);


/*===========================================================================
  FUNCTION  NAME:	get_wip_bom_info

  DESCRIPTION:		This procedure is called in get_dist_info_pq
			to get the wip/bom information  -  bug 1338674

  CHANGE HISTORY:	Created		19-JUL-00	dreddy
===========================================================================*/
PROCEDURE get_wip_bom_info(x_wip_entity_id      IN  number,
                           x_wip_line_id        IN  number ,
                           x_bom_resource_id    IN  number ,
                           x_destination_org_id IN  number,
                           x_wip_entity_name    IN  OUT NOCOPY  varchar2,
                           x_wip_line_code      IN  OUT NOCOPY  varchar2,
                           x_bom_resource_code  IN  OUT NOCOPY  varchar2,
                           x_bom_uom            IN  OUT NOCOPY  varchar2);


/*===========================================================================
  FUNCTION  NAME:	get_vendor_info

  DESCRIPTION:		This procedure is called in get_dist_info_pq
			to get the vendor/vendor_site names corresponding
                        to the ids  -  bug 1338674

  CHANGE HISTORY:	Created		19-JUL-00	dreddy
===========================================================================*/
PROCEDURE  get_vendor_info(x_vendor_id        IN  number,
                           x_vendor_site_id   IN  number ,
                           x_vendor_name      IN OUT NOCOPY  varchar2,
                           x_vendor_site_code IN OUT NOCOPY  varchar2);


/*===========================================================================
  FUNCTION  NAME:	get_ap_terms

  DESCRIPTION:		This procedure is called in get_dist_info_pq
			to get the ap terms name corresponding
                        to the termsid  -  bug 1338674

  CHANGE HISTORY:	Created		19-JUL-00	dreddy
===========================================================================*/
PROCEDURE get_ap_terms(x_terms_id      IN  number,
                       x_ap_terms_name IN OUT NOCOPY  varchar2);


/*===========================================================================
  FUNCTION  NAME:	get_dist_info_pq

  DESCRIPTION:		This procedure is called in post-query for
			the distribution folder.  The purpose
			of this procedure is to reduce the round-trips to
			the server in the post-query and to get the info
                        removed from the view for performance reasons.
                        bug 1338674

  CHANGE HISTORY:	Created		19-JUL-00	dreddy
===========================================================================*/
PROCEDURE get_dist_info_pq (x_po_header_id        IN  number,
                            x_po_line_location_id IN  number,
                            x_deliver_to_loc_id   IN  number,
                            x_bill_to_loc_id      IN  number,
                            x_destination_org_id  IN  number,
                            x_expenditure_org_id  IN  number,
                            x_vendor_id           IN  number,
                            x_vendor_site_id      IN  number,
                            x_project_id          IN  number,
                            x_task_id             IN  number,
                            x_bom_resource_id     IN  number,
                            x_wip_entity_id       IN  number,
                            x_wip_line_id         IN  number,
                            x_dest_location_code  IN OUT NOCOPY  varchar2,
                            x_bill_to_loc_code    IN OUT NOCOPY  varchar2,
                            x_ship_to_loc_code    IN OUT NOCOPY  varchar2,
                            x_dest_org_name       IN OUT NOCOPY  varchar2,
                            x_exp_org_name        IN OUT NOCOPY  varchar2,
                            x_ship_to_org_name    IN OUT NOCOPY  varchar2,
                            x_project_num         IN OUT NOCOPY  varchar2,
                            x_task_num            IN OUT NOCOPY  varchar2,
                            x_wip_entity_name     IN OUT NOCOPY  varchar2,
                            x_wip_line_code       IN OUT NOCOPY  varchar2,
                            x_bom_resource_code   IN OUT NOCOPY  varchar2,
                            x_bom_uom             IN OUT NOCOPY  varchar2,
                            x_ap_terms_name       IN OUT NOCOPY  varchar2,
                            x_vendor_name         IN OUT NOCOPY  varchar2,
                            x_vendor_site_code    IN OUT NOCOPY  varchar2,
                            --< Shared Proc FPJ Start >
                            x_purchasing_ou_coa_id   OUT NOCOPY NUMBER,
                            x_ship_to_ou_coa_id      OUT NOCOPY NUMBER,
                            --< Shared Proc FPJ End >
                            --< Bug 3266689 Start >
                            x_type_lookup_code   IN varchar2
                            --< Bug 3266689 End >
                            ) ;

/*===========================================================================
  togeorge 06/14/2001
  Bug# 1733951
  This procedure fetches the lookup values removed from the view
  po_line_locations_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_shipments_pq_lookups

===========================================================================*/
PROCEDURE get_shipments_pq_lookups(x_enforce_ship_to_loc_code  IN  varchar2,
	  x_receipt_days_excpt_code  IN  	varchar2,
          x_qty_rcv_excpt_code	     IN  	varchar2,
          x_closed_code     	     IN  	varchar2,
          x_shipment_type    	     IN  	varchar2,
          x_authorization_status     IN  	varchar2,
          x_fob_code	 	     IN  	varchar2,
          x_freight_terms_code 	     IN  	varchar2,
          x_enforce_ship_to_loc_dsp  IN  OUT	NOCOPY varchar2,
          x_receipt_days_excpt_dsp   IN  OUT	NOCOPY varchar2,
          x_qty_rcv_excpt_dsp        IN  OUT	NOCOPY varchar2,
          x_closed_code_dsp          IN  OUT	NOCOPY varchar2,
          x_shipment_type_dsp        IN  OUT	NOCOPY varchar2,
          x_authorization_status_dsp IN  OUT	NOCOPY varchar2,
          x_fob_code_dsp	     IN  OUT	NOCOPY varchar2,
          x_freight_terms_code_dsp   IN  OUT	NOCOPY varchar2,
          p_match_option             IN                VARCHAR2,--Bug 2947251
          x_match_option_dsp             OUT    NOCOPY VARCHAR2 --Bug 2947251
);

/*===========================================================================
  togeorge 08/27/2001
  Bug# 1870283
  This procedure fetches the lookup values removed from the view
  po_distributions_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_dist_pq_lookups

===========================================================================*/
PROCEDURE get_dist_pq_lookups(
       x_destination_type_code	   IN  	    varchar2,
       x_authorization_status      IN  	    varchar2,
       x_shipment_type    	   IN  	    varchar2,
       x_closed_code     	   IN  	    varchar2,
       x_destination_type	   IN  OUT NOCOPY  varchar2,
       x_authorization_status_dsp  IN  OUT NOCOPY  varchar2,
       x_shipment_type_dsp    	   IN  OUT NOCOPY  varchar2,
       x_closed_code_dsp     	   IN  OUT NOCOPY  varchar2);

/*===========================================================================
  togeorge 08/31/2001
  Bug# 1870283
  This procedure fetches the lookup values removed from the view
  po_lines_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_lines_pq_lookups

===========================================================================*/
PROCEDURE get_lines_pq_lookups(
       x_price_type_lookup_code    IN  	    varchar2,
       x_transaction_reason_code   IN  	    varchar2,
       x_price_break_lookup_code   IN  	    varchar2,
       x_closed_code     	   IN  	    varchar2,
       x_authorization_status      IN  	    varchar2,
       x_fob_code	 	   IN  	    varchar2,
       x_freight_terms_code 	   IN  	    varchar2,
       x_price_type   		   IN  OUT NOCOPY  varchar2,
       x_transaction_reason    	   IN  OUT NOCOPY  varchar2,
       x_price_break		   IN  OUT NOCOPY  varchar2,
       x_closed_code_dsp     	   IN  OUT NOCOPY  varchar2,
       x_authorization_status_dsp  IN  OUT NOCOPY  varchar2,
       x_fob_code_dsp	 	   IN  OUT NOCOPY  varchar2,
       x_freight_terms_code_dsp    IN  OUT NOCOPY  varchar2);

/*===========================================================================
  togeorge 11/19/2001
  Bug# 2038811
  This procedure fetches the lookup values removed from the view
  po_headers_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_headers_pq_lookups

===========================================================================*/
PROCEDURE get_headers_pq_lookups(
       x_authorization_status      IN  	    varchar2,
       x_fob_code	 	   IN  	    varchar2,
       x_freight_terms_code 	   IN  	    varchar2,
       x_closed_code     	   IN  	    varchar2,
       x_authorization_status_dsp  IN  OUT NOCOPY  varchar2,
       x_fob_code_dsp	 	   IN  OUT NOCOPY  varchar2,
       x_freight_terms_code_dsp    IN  OUT NOCOPY  varchar2,
       x_closed_code_dsp     	   IN  OUT NOCOPY  varchar2,
       p_shipping_control          IN              VARCHAR2,    -- <INBOUND LOGISTICS FPJ>
       x_shipping_control_dsp      IN  OUT NOCOPY  VARCHAR2    -- <INBOUND LOGISTICS FPJ>
       );

/*===========================================================================

    PROCEDURE:   get_source_info                   <GA FPI>

    DESCRIPTION: Gets all source document-related information based on a
                 po_header_id.

===========================================================================*/
PROCEDURE get_source_info
(
    p_po_header_id              IN     PO_HEADERS_ALL.po_header_id%TYPE,
    x_segment1                  OUT NOCOPY    PO_HEADERS_ALL.segment1%TYPE,
    x_type_lookup_code          OUT NOCOPY    PO_HEADERS_ALL.type_lookup_code%TYPE,
    x_global_agreement_flag     OUT NOCOPY    PO_HEADERS_ALL.global_agreement_flag%TYPE,
    x_owning_org_id             OUT NOCOPY    PO_HEADERS_ALL.org_id%TYPE,
    x_quote_vendor_quote_number OUT NOCOPY    PO_HEADERS_ALL.quote_vendor_quote_number%TYPE
);

/*===========================================================================

    FUNCTION:    get_type_name                     <GA FPI>

    DESCRIPTION: Given the 'document_type_code' and 'document_subtype',
                 the function will return the 'document_type_name' from
                 PO_DOCUMENTS_TYPES_VL.

===========================================================================*/
FUNCTION get_type_name
(
	p_document_type_code 	PO_DOCUMENT_TYPES_VL.document_type_code%TYPE	,
	p_document_subtype	PO_DOCUMENT_TYPES_VL.document_subtype%TYPE
)
RETURN PO_DOCUMENT_TYPES_VL.type_name%TYPE;


/*===========================================================================

    PROCEDURE:    get_rate_type

    DESCRIPTION: Given the po_header_id this function will return user_conversion_rate


===========================================================================*/

PROCEDURE get_rate_type
(x_header_id  IN  NUMBER,
 x_rate_type  OUT NOCOPY varchar2);


/* Bug 2788683 start */
/*===========================================================================

    PROCEDURE:   get_vendor_name

    DESCRIPTION: Get vendor real name based on log in name

===========================================================================*/
PROCEDURE get_vendor_name
(  l_user_name   IN         fnd_user.user_name%TYPE,
   x_vendor_name OUT NOCOPY hz_parties.party_name%TYPE
);
/* Bug 2788683 end */

--<HTML Agreement R12 Start>
---------------------------------------------------------------------------
--Start of Comments
--Name: get_party_vendor_name
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Retrieves the party name + vendor name for acceptance entries entered
--  by suppliers. The result is in the form of "party name(vendor name)",
--  e.g. "Maxwell Olden(Office Supplies, Inc.)".
--  This function is refactored from POXPOEAC.pld
--Parameters:
--IN:
--  p_user_id: user_id of the supplier party
--Returns:
--  "party name(vendor name)" of the given user_id
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_party_vendor_name (p_user_id IN NUMBER)
RETURN VARCHAR2;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_vendor_eamil
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Retrieves the vendor party email address for acceptance entries entered
--  by suppliers.
--Parameters:
--IN:
--  p_user_id: user_id of the supplier party
--Returns:
--  email address stored in HZ_PARTIES; if that is not available, return
--  email address stored in FND_USER
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_vendor_email (p_user_id IN NUMBER)
RETURN VARCHAR2;
--<HTML Agreement R12 End>

END PO_INQ_SV;


/
