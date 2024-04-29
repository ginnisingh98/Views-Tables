--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_CHECKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_CHECKS_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVDCKS.pls 120.5.12010000.14 2014/09/25 03:53:50 linlilin ship $*/




-----------------------------------------------------------------------------
-- Public variables
-----------------------------------------------------------------------------

--<FPJ ENCUMBRANCE>

-- <Document Manger Rewrite 11.5.11>: Added FINAL_CLOSE_CHECK

-- Actions:
g_action_DOC_SUBMISSION_CHECK    CONSTANT
   VARCHAR2(30)
   := 'DOC_SUBMISSION_CHECK'
   ;
g_action_UNRESERVE               CONSTANT
   VARCHAR2(30)
   := 'UNRESERVE'
   ;
g_action_FINAL_CLOSE_CHECK       CONSTANT
   VARCHAR2(30)
   := 'FINAL CLOSE'
   ;

-- Document types:
g_document_type_REQUISITION      CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_REQUISITION
   ;
g_document_type_PO               CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_PO
   ;
g_document_type_PA               CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_PA
   ;
g_document_type_RELEASE          CONSTANT
   PO_DOCUMENT_TYPES.document_type_code%TYPE
   := PO_CORE_S.g_doc_type_RELEASE
   ;

-- Document levels:
g_document_level_HEADER          CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_HEADER
   ;
g_document_level_LINE            CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_LINE
   ;
g_document_level_SHIPMENT        CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_SHIPMENT
   ;
g_document_level_DISTRIBUTION    CONSTANT
   VARCHAR2(25)
   := PO_CORE_S.g_doc_level_DISTRIBUTION
   ;

--<DropShip FPJ Start>
--The following constants are possible values
--  for p_mode input parameter of po_status_check Procedure
G_CHECK_UPDATEABLE   CONSTANT VARCHAR2(30) := 'CHECK_UPDATEABLE';
G_GET_STATUS         CONSTANT VARCHAR2(30) := 'GET_STATUS';
G_CHECK_RESERVABLE   CONSTANT VARCHAR2(30) := 'CHECK_RESERVABLE';
G_CHECK_UNRESERVABLE CONSTANT VARCHAR2(30) := 'CHECK_UNRESERVABLE';
--<DropShip FPJ End>


-----------------------------------------------------------------------------
-- Public subprograms
-----------------------------------------------------------------------------




PROCEDURE po_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_level                 IN           VARCHAR2
,  p_document_level_id              IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  p_origin_doc_id                  IN           NUMBER := NULL --Bug#5462677
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_has_warnings                   OUT NOCOPY   VARCHAR2       -- bug3574165
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
);


 PROCEDURE post_submission_check                                   -- <2757450>
 (  p_api_version  	          IN            NUMBER
 ,  p_document_type           IN            VARCHAR2
 ,  p_document_subtype        IN            VARCHAR2
 ,  p_document_id             IN            NUMBER
 ,  x_return_status 	         OUT NOCOPY VARCHAR2
 ,  x_sub_check_status           OUT NOCOPY VARCHAR2
 ,  x_online_report_id           OUT NOCOPY NUMBER
 );

 --Bug 4943365 Removed the check_asl procedure because blankets
 --should not do the asl checks.
 --PROCEDURE check_asl

 --For REQUISTIONS
 PROCEDURE check_requisitions(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For RELEASES
 PROCEDURE check_releases(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For RELEASES, PO
 PROCEDURE check_po_rel_reqprice(p_document_type IN VARCHAR2,
                       p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For PO,PA: Header Checks
 PROCEDURE check_po_pa_header(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For PO
 PROCEDURE check_po(   p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

--For Planned POs and Blanket PAs
 PROCEDURE check_planned_po_blanket_pa(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For Standard PO
 --Includes Global Agreement Reference checks, Consigned Inventory checks
 PROCEDURE check_standard_po(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For Standard POs which reference Global Agreement called from
 --check_standard_po
 PROCEDURE check_std_global_ref(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For Standard POs which have consigned reference called from
 --check_standard_po
 PROCEDURE check_std_consigned_ref(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 -- <GC FPJ START>
 -- For Standard POs which have Global contract reference. Called from
 -- check_standard_po

 PROCEDURE check_std_gc_ref
 ( p_document_id IN NUMBER,
   p_online_report_id IN NUMBER,
   p_user_id IN NUMBER,
   p_login_id IN NUMBER,
   x_sequence IN OUT NOCOPY NUMBER,
   x_return_status OUT NOCOPY VARCHAR2
 );

 -- <GC FPJ END>

 --For Contract PA
 PROCEDURE check_contract_agreement(p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);

 --For POs, Reqs, Releases
 PROCEDURE do_cbc_related_validations(p_document_type IN VARCHAR2,
                       p_document_subtype IN VARCHAR2,
                       p_document_id IN NUMBER,
                       p_online_report_id IN NUMBER,
                       p_user_id IN NUMBER,
                       p_login_id IN NUMBER,
                       p_sequence IN OUT NOCOPY NUMBER,
                       x_return_status OUT NOCOPY VARCHAR2);


 --For populating global temp from po_headers
 PROCEDURE populate_po_headers_gt(p_document_id IN number,
                 x_return_status OUT NOCOPY VARCHAR2);


 --For populating global temp from po_requisition_headers
 PROCEDURE populate_req_headers_gt(p_document_id IN number,
                 x_return_status OUT NOCOPY VARCHAR2);

 --For populating global temp from po_requisition_lines
 PROCEDURE populate_req_lines_gt(p_document_id IN number,
                 x_return_status OUT NOCOPY VARCHAR2);

 --For populating global temp from po_releases
 PROCEDURE populate_releases_gt(p_document_id IN number,
                 x_return_status OUT NOCOPY VARCHAR2);


 --For updating the global temp tables with requested changes
 PROCEDURE update_global_temp_tables(p_document_type IN VARCHAR2,
                     p_document_subtype IN VARCHAR2,
                     p_document_id IN NUMBER,
                -- <PO_CHANGE_API FPJ> Renamed the type to PO_CHANGES_REC_TYPE:
                     p_requested_changes  IN PO_CHANGES_REC_TYPE,
                     x_return_status OUT NOCOPY VARCHAR2);

-- <FPJ, Refactor Security API START>

/**
* Public Procedure: PO_Security_Check
* Requires:
*   IN PARAMETERS:
*     p_api_version:          Version number of API that caller expects. It
*                             should match the l_api_version defined in the
*                             procedure
*     p_query_table:          Table you want to check
*     p_owner_id_column:      Owner id column of the table
*     p_employee_id:          User id to access the document
*     p_minimum_access_level: Minimum access level to the document
*     p_document_type:        The type of the document to perform
*                             the security check on
*     p_document_subtype:     The subtype of the document.
*     p_type_clause:          The document type clause to be used in
*                             constructing where clause
*
* Modifies: None
* Effects:  This procedure builds dynamic WHERE clause fragments based on
*           document security parameters.
* Returns:
*   x_return_status: FND_API.G_RET_STS_SUCCESS if API succeeds
*                    FND_API.G_RET_STS_ERROR if API fails
*                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
*   x_msg_data:      Contains error msg in case x_return_status returned
*                    FND_API.G_RET_STS_ERROR or
*                    FND_API.G_RET_STS_UNEXP_ERROR
*   x_where_clause:  The constructed where clause
*/

PROCEDURE PO_Security_Check (p_api_version          IN Number,
                             p_query_table          IN Varchar2,
                             p_owner_id_column      IN Varchar2,
                             p_employee_id          IN Varchar2,
                             p_minimum_access_level IN Varchar2,
                             p_document_type        IN Varchar2,
                             p_document_subtype     IN Varchar2,
                             p_type_clause          IN Varchar2,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_data             OUT NOCOPY VARCHAR2,
                             x_where_clause         OUT NOCOPY VARCHAR2);

-- <FPJ Refactor Security API END>

-- The new procedure po_status_check added in DropShip FPJ project

-- Detailed comments maintained in the Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
PROCEDURE po_status_check (
    p_api_version         IN NUMBER,
    p_header_id           IN PO_TBL_NUMBER,
    p_release_id          IN PO_TBL_NUMBER,
    p_document_type       IN PO_TBL_VARCHAR30,
    p_document_subtype    IN PO_TBL_VARCHAR30,
    p_document_num        IN PO_TBL_VARCHAR30,
    p_vendor_order_num    IN PO_TBL_VARCHAR30,
    p_line_id             IN PO_TBL_NUMBER,
    p_line_location_id    IN PO_TBL_NUMBER,
    p_distribution_id     IN PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    p_calling_module      IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_role                IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_skip_cat_upload_chk IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    x_po_status_rec       OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2
);

-- <CONTERMS FPJ>
-- new procedure to call contract terms validation during submission check
PROCEDURE check_terms(
   p_document_id          IN NUMBER,
   p_document_type        IN VARCHAR2,
   p_document_subtype     IN VARCHAR2,
   p_online_report_id     IN NUMBER,
   p_user_id              IN NUMBER,
   p_login_id             IN NUMBER,
   p_sequence             IN OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2);

-- <JFMIP Vendor Registration FPJ>
-- For Release, PO, PA: checks if vendor site registration is valid
PROCEDURE check_vendor_site_ccr_regis(
   p_document_id         IN NUMBER,
   p_online_report_id    IN NUMBER,
   p_user_id             IN NUMBER,
   p_login_id            IN NUMBER,
   p_sequence            IN OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2);

--<LCM project start>
-- Procedure to set the lcm flag in po shipments and distributions
PROCEDURE Set_LCM_Flag (p_line_location_id IN NUMBER,
			p_doc_check_status IN VARCHAR2,
			x_return_status    OUT nocopy VARCHAR2);
--<LCM project end>

--<BUG 4624736 START>
-- Checks if the pay item's price can be updated.
-- NOTE: does not verify that line location is in fact
-- a pay item.
FUNCTION is_pay_item_price_updateable (
  p_line_location_id          IN NUMBER
, p_add_reasons_to_msg_list   IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION chk_unv_invoices(p_invoice_type       IN VARCHAR2 DEFAULT 'BOTH',
                          p_po_header_id       IN NUMBER,
                          p_po_release_id      IN NUMBER DEFAULT NULL,
                          p_po_line_id         IN NUMBER DEFAULT NULL,
                          p_line_location_id   IN NUMBER DEFAULT NULL,
                          p_po_distribution_id IN NUMBER DEFAULT NULL,
                          p_invoice_id         IN NUMBER DEFAULT NULL,
                          p_calling_sequence   IN VARCHAR2) RETURN NUMBER;

--<BUG 4624736 END>

 --Added for Bug 9716385


 -- Added for  Bug 10214801


 -- Added for  Bug 10300018
  PROCEDURE  PO_UOM_CHECK(P_DOCUMENT_ID		IN NUMBER,
 		                P_DOCUMENT_TYPE		IN VARCHAR2,
                        P_ONLINE_REPORT_ID	IN NUMBER,
                        P_USER_ID		IN NUMBER,
                        P_LOGIN_ID		IN NUMBER,
                        P_SEQUENCE		IN OUT NOCOPY NUMBER,
                        X_RETURN_STATUS		OUT NOCOPY VARCHAR2
                        ,x_msg_data              OUT NOCOPY VARCHAR2);

-- Added for  Bug 12951645
  PROCEDURE  CHECK_CLOSE_WIP_JOB(p_document_id             IN NUMBER,
				 p_document_type	   IN VARCHAR2,
				 p_online_report_id	   IN NUMBER,
				 p_user_id		   IN NUMBER,
				 p_login_id		   IN NUMBER,
				 p_sequence		   IN OUT NOCOPY NUMBER,
				 x_return_status	     OUT NOCOPY VARCHAR2);





  ----for bug 13481176

 --<Bug 13019003>
 PROCEDURE  PO_VALIDATE_ACCOUNTS(P_DOCUMENT_ID		IN NUMBER,
		       P_DOCUMENT_TYPE		IN VARCHAR2,
                       P_ONLINE_REPORT_ID	IN NUMBER,
                       P_USER_ID		IN NUMBER,
                       P_LOGIN_ID		IN NUMBER,
                       P_SEQUENCE		IN OUT NOCOPY NUMBER,
                       X_RETURN_STATUS		OUT NOCOPY VARCHAR2
                       ,x_msg_data              OUT NOCOPY VARCHAR2);
  -----    bug 13481176

--<Bug 13019003>
--Modified this function to use an extra parameter p_val_date.
FUNCTION validate_account_wrapper(
				p_structure_number IN NUMBER,
				p_combination_id  IN NUMBER,
				p_val_date IN DATE)
RETURN VARCHAR2 ;

--Bug 15843328
PROCEDURE check_accrue_on_receipt(
                       P_DOCUMENT_ID		IN NUMBER,
		       P_DOCUMENT_TYPE		IN VARCHAR2,
                       P_ONLINE_REPORT_ID	IN NUMBER,
                       P_USER_ID		IN NUMBER,
                       P_LOGIN_ID		IN NUMBER,
                       P_SEQUENCE		IN OUT NOCOPY NUMBER,
                       X_RETURN_STATUS		OUT NOCOPY VARCHAR2,
                       x_msg_data               OUT NOCOPY VARCHAR2 );

-- Bug 15987200
PROCEDURE check_enc_amt(    p_document_level       IN VARCHAR2,
		            p_online_report_id     IN NUMBER,
		            p_user_id              IN NUMBER,
		            p_login_id             IN NUMBER,
		            p_sequence             IN OUT NOCOPY NUMBER,
		            x_return_status        OUT NOCOPY VARCHAR2);

-- Bug 19139821
FUNCTION is_uom_conversion_exist(from_unit IN VARCHAR2,
                                 to_unit   IN VARCHAR2,
                                 item_id   IN NUMBER) RETURN VARCHAR2;


END PO_DOCUMENT_CHECKS_PVT;


/
