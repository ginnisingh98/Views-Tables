--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_CHECKS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_CHECKS_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGDCKS.pls 120.5 2006/10/11 18:52:05 pxiao noship $*/

-----------------------------------------------------------------------------
-- Public variables
-----------------------------------------------------------------------------

-- Actions:
g_action_DOC_SUBMISSION_CHECK    CONSTANT
   VARCHAR2(30)
   := PO_DOCUMENT_CHECKS_PVT.g_action_DOC_SUBMISSION_CHECK
   ;
g_action_UNRESERVE               CONSTANT
   VARCHAR2(30)
   := PO_DOCUMENT_CHECKS_PVT.g_action_UNRESERVE
   ;
-- <Doc Manager Rewrite 11.5.11 Start>
g_action_FINAL_CLOSE_CHECK               CONSTANT
   VARCHAR2(30)
   := PO_DOCUMENT_CHECKS_PVT.g_action_FINAL_CLOSE_CHECK
   ;
-- <Doc Manager Rewrite 11.5.11 End>

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
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  p_origin_doc_id                  IN           NUMBER := NULL -- Bug#5462677
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_has_warnings                   OUT NOCOPY   VARCHAR2  -- bug3574165
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
);


-- bug3574165
-- Overloaded procedure. This procedure does not have x_has_warnings as
-- parameter.
PROCEDURE po_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_level                 IN           VARCHAR2
,  p_document_level_id              IN           NUMBER
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_origin_doc_id                  IN           NUMBER := NULL -- Bug#5462677
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
);

PROCEDURE po_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_id                    IN           NUMBER
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
      := TRUE
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
);


-- This procedure is called from POXAPAPC.pld, POXWPA4B.pls
--Overloaded procedure without following parameter:
-- IN: p_requested_changes
-- IN: p_org_id
-- OUT : x_doc_check_error_record
PROCEDURE po_submission_check(p_api_version  IN  NUMBER,
                p_action_requested          IN  VARCHAR2,
                p_document_type             IN  VARCHAR2,
                p_document_subtype          IN  VARCHAR2,
                p_document_id               IN  NUMBER,
			    x_return_status 	        OUT NOCOPY  VARCHAR2,
			    x_sub_check_status          OUT	NOCOPY  VARCHAR2,
                x_msg_data                  OUT NOCOPY  VARCHAR2,
			    x_online_report_id          OUT NOCOPY  NUMBER);

-- bug3574165 START
-- Overloaded procedure to include x_has_warnings parameter
-- This parameter is used to indicate whether there are warnings coming
-- out from po submission check
PROCEDURE po_submission_check
(
    p_api_version               IN          NUMBER,
    p_action_requested          IN          VARCHAR2,
    p_document_type             IN          VARCHAR2,
    p_document_subtype          IN          VARCHAR2,
    p_document_id               IN          NUMBER,
    p_check_asl                 IN          BOOLEAN,
    x_return_status 	        OUT NOCOPY  VARCHAR2,
    x_sub_check_status          OUT NOCOPY  VARCHAR2,
    x_has_warnings              OUT NOCOPY  VARCHAR2,
    x_msg_data                  OUT NOCOPY  VARCHAR2,
    x_online_report_id          OUT NOCOPY  NUMBER
);
-- bug3574165 END

-- <2757450 START>: Overloaded procedure to include 'p_check_asl' parameter.
-- This parameter is used to indicate whether or not to perform the
-- PO_SUB_ITEM_NOT_APPROVED and PO_SUB_ITEM_ASL_DEBARRED checks.
--
PROCEDURE po_submission_check
(
                p_api_version               IN          NUMBER,
                p_action_requested          IN          VARCHAR2,
                p_document_type             IN          VARCHAR2,
                p_document_subtype          IN          VARCHAR2,
                p_document_id               IN          NUMBER,
                p_check_asl                 IN          BOOLEAN,
			    x_return_status 	        OUT NOCOPY  VARCHAR2,
			    x_sub_check_status          OUT	NOCOPY  VARCHAR2,
                x_msg_data                  OUT NOCOPY  VARCHAR2,
			    x_online_report_id          OUT NOCOPY  NUMBER
);
-- <2757450 END>

-- <FPJ Refactor Security API START>

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
*                             Valid Document types and Document subtypes
*                             Document Type      Document Subtype
*                             RFQ          --->  STANDARD
*                             QUOTATION    --->  STANDARD
*                             REQUISITION  --->  PURCHASE/INTERNAL
*                             RELEASE      --->  SCHEDULED/BLANKET
*                             PO           --->  PLANNED/STANDARD
*                             PA           --->  CONTRACT/BLANKET
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
                             p_employee_id          IN VARCHAR2,
                             p_org_id               IN Number,
                             p_minimum_access_level IN Varchar2,
                             p_document_type        IN Varchar2,
                             p_document_subtype     IN Varchar2,
                             p_type_clause          IN Varchar2,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_data             OUT NOCOPY VARCHAR2,
                             x_where_clause         OUT NOCOPY VARCHAR2);

-- <FPJ Refactor Security API END>

-- The new overloaded procedures po_status_check added in DropShip FPJ project

-- Detailed comments are in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
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

-- Detailed comments are in PVT Package Body PO_DOCUMENT_CHECKS_PVT.po_status_check
PROCEDURE po_status_check (
    p_api_version           IN NUMBER,
    p_header_id             IN NUMBER := NULL,
    p_release_id            IN NUMBER := NULL,
    p_document_type         IN VARCHAR2 := NULL,
    p_document_subtype      IN VARCHAR2 := NULL,
    p_document_num          IN VARCHAR2 := NULL,
    p_vendor_order_num      IN VARCHAR2 := NULL,
    p_line_id               IN NUMBER := NULL,
    p_line_location_id      IN NUMBER := NULL,
    p_distribution_id       IN NUMBER := NULL,
    p_mode                  IN VARCHAR2,
    p_lock_flag             IN VARCHAR2 := 'N',
    p_calling_module        IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_role                  IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    p_skip_cat_upload_chk   IN VARCHAR2 := NULL,  -- PDOI Rewrite R12
    x_po_status_rec         OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status         OUT NOCOPY VARCHAR2
);

-- Bug 3312906 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_std_po_price_updateable
--Function:
--  Checks whether price updates are allowed on this Standard PO line.
--  See the package body for detailed comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_std_po_price_updateable (
  p_api_version               IN NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  p_po_line_id                IN PO_LINES_ALL.po_line_id%TYPE,
  p_from_price_break          IN VARCHAR2,
  p_add_reasons_to_msg_list   IN VARCHAR2,
  x_price_updateable          OUT NOCOPY VARCHAR2,
  x_retroactive_price_change  OUT NOCOPY VARCHAR2
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_rel_price_updateable
--Function:
--  Checks whether price updates are allowed on this release shipment.
--  See the package body for detailed comments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_rel_price_updateable (
  p_api_version               IN NUMBER,
  x_return_status             OUT NOCOPY VARCHAR2,
  p_line_location_id          IN PO_LINE_LOCATIONS_ALL.line_location_id%TYPE,
  p_from_price_break          IN VARCHAR2,
  p_add_reasons_to_msg_list   IN VARCHAR2,
  x_price_updateable          OUT NOCOPY VARCHAR2,
  x_retroactive_price_change  OUT NOCOPY VARCHAR2
);
-- Bug 3312906 END

-- <Complex Work R12 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_payitem_price_updateable
--Function:
--  Checks whether price updates are allowed on this Complex Work PO Pay Item.
--  Note: NO validation is done to verify that p_line_location_id
--  corresponds to a Complex Work pay item!
--Parameters:
--IN:
--p_api_version
--  API version expected by the caller
--p_line_location_id
--  ID of a Complex Work pay item.
--p_add_reasons_to_msg_list
--  (Only applies if x_price_updateable = PO_CORE_S.G_PARAMETER_NO.)
--  If PO_CORE_S.G_PARAMETER_NO, the API will add the reasons why price updates
--  are not allowed to the standard API message list. Otherwise, the API
--  will not add the reasons to the message list.
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the API completed successfully.
--  FND_API.G_RET_STS_ERROR if there was an error.
--  FND_API.G_RET_STS_UNEXP_ERROR if there was an unexpected error.
--x_price_updateable
--  PO_CORE_S.G_PARAMETER_YES if price updates are allowed on this shipment,
--  PO_CORE_S.G_PARAMETER_NO otherwise
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_payitem_price_updateable (
  p_api_version               IN NUMBER
, p_line_location_id          IN NUMBER
, p_add_reasons_to_msg_list   IN VARCHAR2
, x_return_status             OUT NOCOPY VARCHAR2
, x_price_updateable          OUT NOCOPY VARCHAR2
);
-- <Complex Work R12 END>

-- Bug 5560980 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: po_combined_submission_check
--Function:
--  Call both Copy_Doc submission check and regular po submission check,
--  then combine the two online reports to one and return the single report id
--  See the package body for detailed comments.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE po_combined_submission_check(
   p_api_version                    IN           NUMBER
,  p_action_requested               IN           VARCHAR2
,  p_document_type                  IN           VARCHAR2
,  p_document_subtype               IN           VARCHAR2
,  p_document_level                 IN           VARCHAR2
,  p_document_level_id              IN           NUMBER
,  p_org_id                         IN           NUMBER
,  p_requested_changes              IN           PO_CHANGES_REC_TYPE
,  p_check_asl                      IN           BOOLEAN
,  p_req_chg_initiator              IN           VARCHAR2 := NULL -- bug4957243
,  p_origin_doc_id                  IN           NUMBER := NULL -- Bug#5462677
-- parameters for combination
,  p_from_header_id	                IN           NUMBER
,  p_from_type_lookup_code	        IN           VARCHAR2
,  p_po_header_id                   IN           NUMBER
,  p_online_report_id               IN           NUMBER
,  p_sob_id                         IN           NUMBER
,  x_return_status                  OUT NOCOPY   VARCHAR2
,  x_sub_check_status               OUT NOCOPY   VARCHAR2
,  x_has_warnings                   OUT NOCOPY   VARCHAR2  -- bug3574165
,  x_msg_data                       OUT NOCOPY   VARCHAR2
,  x_online_report_id               OUT NOCOPY   NUMBER
,  x_doc_check_error_record         OUT NOCOPY   doc_check_Return_Type
);
-- Bug 5560980 END

END PO_DOCUMENT_CHECKS_GRP;

 

/
