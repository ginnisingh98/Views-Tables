--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_REVISION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_REVISION_GRP" AUTHID CURRENT_USER AS
/* $Header: POXDOCRS.pls 120.0.12010000.3 2012/06/29 07:21:19 vlalwani ship $ */

/*===========================================================================
  PACKAGE NAME:         PO_DOCUMENT_REVISION_GRP

  DESCRIPTION:          This package contains the server side Line level
                        Application Program Interfaces (APIs).

  CLIENT/SERVER:        Server

  OWNER:               pparthas

  FUNCTION/PROCEDURE:   MassUpdate_Releases()
===========================================================================*/

/*******************************************************************
  PROCEDURE NAME: Check_New_Revision

  DESCRIPTION   : Returns the new revsion number of the document if there
          a need to increment.

  Algr: Check if the the document revision_num is the same as the
        revision_num of the latest archived version.

        If this is not the case exit the routine since the revision
        number is already incremented or the document was never
        archived before.

        For the different document types and subtypes the following
        tables will be compared with the archived versions.  The latest
        archived version is recognizable by having the column
        LATEST_EXTERNAL_FLAG = 'Y'.  When 'table' is specified only
        this table (when applicable) will be checked.  The others are
        assumed equal (this to improve performance).

        Comparison regime:

        For PO/PA             STANDARD   PLANNED   BLANKET   CONTRACT
        =====================================================================
        PO_HEADERS               X          X         X         X
        PO_LINES                 X          X         X
        PO_LINE_LOCATIONS        X          X         X(PriceBreaks)
        PO_DISTRIBUTIONS         X          X

        For RELEASES          SCHEDULED  BLANKET
        =====================================================================
        PO_RELEASES              X          X
        PO_LINE_LOCATIONS        X          X
        PO_DISTRIBUTIONS         X          X

  Note: This routine checks the same columns as the archiving routine
        /src/xit/porar.lpc.  Whenever you make changes to this routine
        check if you have to do the same in the archiving routine.


  Referenced by :
  parameters    :  p_doc_type     IN  VARCHAR2 - PO,PA, RELEASE
           p_doc_subtype  IN  VARCHAR2 - Document Sub-type Lookup Code.
            PO - STANDARD / BLANKET etc.,
            for RELEASE - SCHEDULED, BLANKET.
           p_doc_id       IN  NUMBER - Document Header id or Release id.
           p_table_name   IN  VARCHAR2 - Table you want to check.
           p_doc_revision_num IN OUT NOCOPY NUMBER - The revision_number field.

Valid options for TABLE are:

           ALL            Checks all tables in the document type/subtype.
           HEADER         Checks only the PO_HEADER or RELEASE_HEADER.
           LINES          Checks only the PO_LINES.
           SHIPMENTS      Checks only the PO_LINE_LOCATIONS.
           DISTRIBUTIONS  Checks only the PO_DISTRIBUTIONS.


  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
Procedure Check_New_Revision (p_api_version          IN  NUMBER,
                  p_doc_type IN Varchar2,
                  p_doc_subtype IN Varchar2,
                  p_doc_id IN Number,
                  p_table_name IN  Varchar2,
                  x_return_status        OUT NOCOPY VARCHAR2,
                  x_doc_revision_num IN OUT NOCOPY Number,
                  x_message IN OUT NOCOPY VARCHAR2);



/*******************************************************************
  FUNCTION NAME: Check_PO_PA_Revision

  DESCRIPTION   : This procedure builds the item cursor statement.
          This statement needs to be built at run time
          (dynamic SQL) because of the dynamic nature of the
          System Item and Category flexfields.
  Referenced by :
  parameters    :  p_doc_type     IN  VARCHAR2 - Document Type Code.
           p_doc_subtype  IN  VARCHAR2 - Document Sub-type Lookup Code.
           p_doc_id       IN  NUMBER - Document Header id or Release id.
           p_table_name   IN  VARCHAR2 - Table you want to check.
           p_doc_revision_num IN OUT NOCOPY NUMBER - The revision_number field.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/

FUNCTION Check_PO_PA_Revision (
    p_doc_type         IN Varchar2,
    p_doc_subtype      IN Varchar2,
    p_doc_id           IN Number,
    p_table_name       IN  Varchar2,
    p_line_id          IN NUMBER,           --<CancelPO FPJ>
    p_line_location_id IN NUMBER,           --<CancelPO FPJ>
    p_chk_cancel_flag  IN VARCHAR2,         --<CancelPO FPJ>
    x_different        OUT NOCOPY Varchar2) --<CancelPO FPJ>
RETURN BOOLEAN;

/*******************************************************************
  FUNCTION NAME: Check_Release_Revision

  DESCRIPTION   : This API is called from the main procedure
          MassUpdate_Releases to wrap up the releases
          If the Release had any shipment price updated,
          then document revision had to incremented and
          approval had to initiated if necessary.
  Referenced by :
  parameters    :  p_doc_type     IN  VARCHAR2 - Document Type Code.
           p_doc_subtype  IN  VARCHAR2 - Document Sub-type Lookup Code.
           p_doc_id       IN  NUMBER - Document Header id or Release id.
           p_table_name   IN  VARCHAR2 - Table you want to check.
           p_doc_revision_num IN OUT NOCOPY NUMBER - The revision_number field.

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
FUNCTION Check_Release_Revision (
    p_doc_type         IN Varchar2,
    p_doc_subtype      IN Varchar2,
    p_doc_id           IN Number,
    p_table_name       IN  Varchar2,
    p_line_location_id IN NUMBER,           --<CancelPO FPJ>
    p_chk_cancel_flag  IN VARCHAR2,         --<CancelPO FPJ>
    x_different        OUT NOCOPY Varchar2) --<CancelPO FPJ>
RETURN BOOLEAN;


--<CancelPO FPJ Start>
-- Detailed Comments maintained in Package Body PO_DOCUMENT_REVISION_GRP
PROCEDURE Compare(
    p_api_version        IN NUMBER,
    p_doc_id             IN NUMBER,
    p_doc_type           IN VARCHAR2,
    p_doc_subtype        IN VARCHAR2,
    p_line_id            IN NUMBER,
    p_line_location_id   IN NUMBER,
    x_different          OUT NOCOPY Varchar2,
    x_return_status      OUT NOCOPY VARCHAR2
);
--<CancelPO FPJ End>
-------------------------------------------------------------------------------
--<Bug 14207546 :Cancel Refactoring Project >
--Start of Comments
--Name: CHECK_REV_DIFF
--Function:
--   Checks if there are any non-approved changes in the base tables
--  The below columns of base tables are compared against archive :
--  Need_By_Data /Promised Date
--  Quantity
--  Price
--  Amount
--Notes:
--  See the package body for more comments.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE CHECK_REV_DIFF(
    p_api_version        IN NUMBER,
    p_doc_id             IN NUMBER,
    p_doc_type           IN VARCHAR2,
    p_doc_subtype        IN VARCHAR2,
    p_line_id            IN NUMBER,
    p_line_location_id   IN NUMBER,
    p_action_level       IN VARCHAR2,
    x_msg_name           OUT NOCOPY Varchar2,
    x_msg_type           OUT NOCOPY VARCHAR2,
    x_token_name_tbl     OUT NOCOPY PO_TBL_VARCHAR30,
    x_token_value_tbl    OUT NOCOPY PO_TBL_VARCHAR2000,
    x_return_status      OUT NOCOPY VARCHAR2
);



END PO_DOCUMENT_REVISION_GRP;

/
