--------------------------------------------------------
--  DDL for Package PO_NEGOTIATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NEGOTIATIONS_SV1" AUTHID CURRENT_USER AS
/* $Header: POXNEG1S.pls 120.7 2007/12/19 14:14:11 vdurbhak ship $*/

/*============================================================================
 PLSQL table defined to pass the requisition information form the autocreate
 frontend to the backend sourcing wrapper
==============================================================================*/

/* Bug 6631173 The below declaration was introduced in the bug 5841426,
   the fix was working in Forms but not in the OA poages as the OA was not able to identify the
   construct declared in a pls.
   Using the standard db table type PO_TBL_NUMBER will fix the issue.
   Commented the local object  po_tble
 TYPE po_tbl_number IS TABLE OF NUMBER; */  --bug5841426

/*TYPE req_lines_table_type IS TABLE OF po_requisition_lines%rowtype
index by binary_integer;*/  --Bug5841426


PROCEDURE create_negotiation_bulk
(
   -- standard API params
   p_api_version                IN            NUMBER,
   x_result                     IN OUT NOCOPY NUMBER,
   x_error_message              IN OUT NOCOPY VARCHAR2,
   -- input params
   p_negotiation_type           IN            varchar2,
   p_grouping_method            IN            varchar2,
   -- table params in
   p_req_line_id_tbl            IN            PO_TBL_NUMBER,
   p_line_type_id_tbl           IN            PO_TBL_NUMBER,
   p_item_id_tbl                IN            PO_TBL_NUMBER,
   p_item_revision_tbl          IN            PO_TBL_VARCHAR5, -- <ACHTML R12>
   p_category_id_tbl            IN            PO_TBL_NUMBER,
   p_quantity_tbl               IN            PO_TBL_NUMBER,
   p_unit_meas_lookup_code_tbl  IN            PO_TBL_VARCHAR30,-- <ACHTML R12>
   p_job_id_tbl                 IN            PO_TBL_NUMBER,
   -- some more input params
   p_neg_outcome                IN            varchar2,
   p_document_org_id            IN            number,
   p_neg_style_id               IN            NUMBER,          -- <ACHTML R12>
   p_outcome_style_id           IN            NUMBER,          -- <ACHTML R12>
   -- output params
   x_negotiation_id             IN OUT NOCOPY number,
   x_doc_url_params             IN OUT NOCOPY varchar2
);
-- <HTMLAC END>

/*============================================================================
     Name: CREATE_NEGOTIATION
     DESC: Create  document from requisition data in the autocreate
     input parameters :
       x_negotiation_type : type of the negotiation to be autocreated
       x_grouping_method  : grouping method selected in the autocreate form
       t_req_lines : plsql table containing the requisition details
     output parameters :
       x_negotiation_number : negotiation number returned by the sourcing api
       x_doc_url_params  : params to be passed to the funcion call to open
       negotiation page url, returned by the sourcing api
       x_error_code, x_error_message : errors if any returned by the api
       p_neg_outcome: negotiation outcome expected

	<RENEG BLANKET FPI>
       Added p_neg_outcome input parameter which tells Sourcing what is the
       outcome of negotiation.
==============================================================================*/

PROCEDURE create_negotiation(x_negotiation_type      IN   varchar2 ,
                             x_grouping_method       IN   varchar2 ,
                             t_req_lines             IN   PO_TBL_NUMBER,  /* Changed the po_tbl_number to upper case for uniformity - bug 6631173 */  --bug5841426
                             p_neg_style_id          IN   NUMBER, -- <ACHTML R12>
                             p_outcome_style_id      IN   NUMBER, -- <ACHTML R12>
                             x_negotiation_id        IN OUT NOCOPY  number,
                             x_doc_url_params        IN OUT NOCOPY  varchar2,
                             x_result                IN OUT NOCOPY  number,
                             x_error_code            IN OUT NOCOPY  varchar2,
                             x_error_message         IN OUT NOCOPY  varchar2,
			     --<RENEG BLANKET FPI>
			     p_neg_outcome	     IN	   varchar2,
              --<HTMLAC>
              p_document_org_id    IN     number DEFAULT null);

/*============================================================================
     Name: DELETE_NEGOTIATION_REF
     DESC: Delete negotiation reference from the backing requisition
     input parameters :
       x_negotiation_id : negotiation whose reference has to be deleted
       x_negotiation_line_num : negotiation line  whose reference has to be deleted
     output parameters :
       x_error_code  : errors if any returned by the api
==============================================================================*/

PROCEDURE  DELETE_NEGOTIATION_REF (x_negotiation_id   in  number,
                                   x_negotiation_line_num  in  number,
                                   x_error_code  out NOCOPY varchar2) ;



/*============================================================================
     Name: UPDATE_NEGOTIATION_REF
     DESC: Update negotiation reference in the backing requisition
     input parameters :
       x_old_negotiation_id : negotiation whose reference has to be replaced
       x_new_negotiation_num/id : new negotiation reference
     output parameters :
       x_error_code  : errors if any returned by the api
==============================================================================*/

PROCEDURE UPDATE_NEGOTIATION_REF (x_old_negotiation_id     in   number ,
                                            x_new_negotiation_id  in   number ,
                                            x_new_negotiation_num  in varchar2 ,
                                            x_error_code  out NOCOPY varchar2);

--<Bug 2440254 mbhargav START>
/*============================================================================
     Name: UPDATE_NEGOTIATION_LINE_REF
     DESC: Update negotiation reference in the backing requisition line to
           point to another negotiation line.
==============================================================================*/
PROCEDURE UPDATE_NEGOTIATION_LINE_REF (
                                  p_api_version		     IN		NUMBER,
                                  p_old_negotiation_id       IN         NUMBER,
                                  p_old_negotiation_line_num IN         NUMBER,
                                  p_new_negotiation_id       IN         NUMBER,
                                  p_new_negotiation_line_num IN         NUMBER,
                                  p_new_negotiation_num      IN         varchar2,
                                  x_return_status            OUT NOCOPY varchar2,
				  x_error_message            OUT NOCOPY	varchar2);

--<Bug 2440254 mbhargav END>

/*============================================================================
     Name: UPDATE_NEGOTIATION_REF REQ_POOL
     DESC: Update requisition pool flag in the backing requisition
     input parameters :
       x_negotiation_id : req line with this negotiation has to be updated
                          with the req pool
       x_negotiation_line_num : req line with this negotiation line has to be
                                updated with the req pool
       x_flag_value : req pool flag value
     output parameters :
       x_error_code  : errors if any returned by the api
==============================================================================*/

PROCEDURE UPDATE_REQ_POOL (x_negotiation_id   in  number,
                           x_negotiation_line_num  in  number,
                           x_flag_value  in varchar2,
                           x_error_code  out NOCOPY varchar2);

/*============================================================================
     Name: check_negotiation_ref
     DESC: checks if a req line/header has negotiation reference
     input params:
        x_doc_level - the doc level req line or header
        x_doc_id -  req line id or header id
     output params:
        x_negotiation_ref_flag - 'Y' or 'N'
==============================================================================*/

PROCEDURE check_negotiation_ref(x_doc_level IN VARCHAR2,
                                x_doc_id    IN NUMBER,
                                x_negotiation_ref_flag IN OUT NOCOPY varchar2);



--<RENEG BLANKET FPI START>
/*============================================================================
Name      :     RENEGOTIATE_BLANKET
Type      :     Private
Function  :     This procedure
                a. populates the Sourcing Interface tables
                b. Calls Sourcing APIs for creating draft_negotiation and purging interface tables
Version   :     Current Version         1.0
                     Changed:   Initial design 10/1/2002
                Previous Version        1.0
==============================================================================*/
PROCEDURE renegotiate_blanket(  p_api_version		IN		NUMBER,
				p_commit		IN		varchar2,
				p_po_header_id  	IN 		NUMBER,
				p_negotiation_type	IN 		varchar2,
				x_negotiation_id	OUT NOCOPY 	NUMBER,
				x_doc_url_params	OUT NOCOPY	varchar2,
				x_return_status		OUT NOCOPY	varchar2,
				x_error_code		OUT NOCOPY	varchar2,
                                x_error_message         OUT NOCOPY      varchar2,
                                x_large_negotiation     OUT NOCOPY      varchar2,
                                x_large_neg_request_id  OUT NOCOPY      NUMBER);
--<RENEG BLANKET FPI END>

PROCEDURE renegotiate_blanket(  p_api_version		IN		NUMBER,
				p_commit		IN		varchar2,
				p_po_header_id  	IN 		NUMBER,
				p_negotiation_type	IN 		varchar2,
				x_negotiation_id	OUT NOCOPY 	NUMBER,
				x_doc_url_params	OUT NOCOPY	varchar2,
				x_return_status		OUT NOCOPY	varchar2,
				x_error_code		OUT NOCOPY	varchar2,
                                x_error_message         OUT NOCOPY      varchar2
                              );
--<RENEG BLANKET FPI END>
-- Bug 3780359
PROCEDURE get_auction_display_line_num(
                p_auction_header_id        IN NUMBER,
                p_auction_line_number      IN NUMBER,
                x_auction_display_line_num OUT NOCOPY VARCHAR2);

END po_negotiations_sv1;

/
