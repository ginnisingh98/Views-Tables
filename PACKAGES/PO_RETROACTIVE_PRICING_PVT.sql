--------------------------------------------------------
--  DDL for Package PO_RETROACTIVE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RETROACTIVE_PRICING_PVT" AUTHID CURRENT_USER AS
/*$Header: POXRPRIS.pls 120.3 2005/09/14 05:03:52 pchintal noship $*/

/*===========================================================================
  PACKAGE NAME:         PO_RETROACTIVE_PRICING_PVT

  DESCRIPTION:          This package contains server side procedures to
			update the releases/Std PO against BA/GA when
			there is a retroactive price update to BA/GA.

  CLIENT/SERVER:        Server

  OWNER:                pparthas

  FUNCTION/PROCEDURE:   MassUpdate_Releases()
===========================================================================*/

--------------------------------------------------------------------------------
--Start of Comments
--Name: MassUpdate_Releases
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This API is called from the Approval Window or by the
--  Concurrent Program. This procedure will update all
--  the releases against Blanket Agreeements or Standard
--  POs against Global Agreements that have lines that
--  are retroactively changed.
--Parameters:
--IN:
--p_api_version
--  Version number of API that caller expects. It
--  should match the l_api_version defined in the
--  procedure (expected value : 1.0)
--p_validation_level
--  validation level api uses
--p_vendor_id
--  Site_id of the Supplier site selected by the user.
--p_po_header_id
--  Header_id of the Blanket/Global Agreement selected by user.
--p_category_struct_id
--  Purchasing Category structure Id
--p_category_from / p_category_to
--  Category Range that user selects to process retroactive changes
--p_item_num_from / p_item_num_to
--  Item Range that user selects to process retroactive changes
--p_date
--  All releases or Std PO created on or after this date must be changed.
--p_communicate_update
--  Communicate Price Updates to Supplier
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--Testing:
--
--End of Comments
--------------------------------------------------------------------------------

Procedure MassUpdate_Releases ( p_api_version		IN  NUMBER,
                                p_validation_level	IN  NUMBER,
				p_vendor_id 		IN  Number,
				p_vendor_site_id 	IN  Number,
				p_po_header_id		IN  Number,
				p_category_struct_id	IN  Number,
				p_category_from		IN  Varchar2,
				p_category_to		IN  Varchar2,
				p_item_from		IN  Varchar2,
				p_item_to		IN  Varchar2,
				p_date			IN  Date,
				-- <FPJ Retroactive Price>
				p_communicate_update	IN  VARCHAR2 DEFAULT NULL,
				x_return_status		OUT NOCOPY VARCHAR2);



/*******************************************************************
  PROCEDURE NAME: Build_Item_Cursor

  DESCRIPTION   : This procedure builds the item cursor statement.
		  This statement needs to be built at run time
		  (dynamic SQL) because of the dynamic nature of the
		  System Item and Category flexfields.
  Referenced by :
  parameters    : p_cat_structure_id IN Number
		  p_cat_from         IN VARCHAR2
		  p_cat_to           IN VARCHAR2
		  p_item_from        IN Varchar2
		  p_item_to          IN Varchar2
		  x_item_cursor      IN Varchar2

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
PROCEDURE Build_Item_Cursor
( p_cat_structure_id IN            NUMBER
, p_cat_from         IN            VARCHAR2
, p_cat_to           IN            VARCHAR2
, p_item_from        IN            VARCHAR2
, p_item_to          IN            VARCHAR2
, x_item_cursor      IN OUT NOCOPY VARCHAR2
);


/*******************************************************************
  PROCEDURE NAME: WrapUp_Releases

  DESCRIPTION   : This API is called from the main procedure
		  MassUpdate_Releases to wrap up the releases
		  If the Release had any shipment price updated,
		  then document revision had to incremented and
		  approval had to initiated if necessary.
  Referenced by :
  parameters    : p_old_po_release_id IN Number
		  p_po_release_id IN Number
		  p_po_line_location_id IN Number
		  p_last_release_shipment IN  Varchar2(1)
		  x_retroactive_change IN Varchar2(1)

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
PROCEDURE WrapUp_Releases;


/*******************************************************************
  PROCEDURE NAME: WrapUp_Standard_PO

  DESCRIPTION   : This API is called from the main procedure
		  MassUpdate_Releases to process the Standard PO that
		  are created against the Global agreement lines that
		  have been retroactively changed. If the shipments are
		  updated with the new price document revision had to
		  incremented and approval had to initiated if necessary.
  Referenced by :
  parameters    : p_old_po_header_id IN Number
		  p_po_header_id IN Number
		  p_po_line_location_id IN Number
		  p_last_standard_shipment IN  Varchar2(1)
		  x_retroactive_change IN Varchar2(1)

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
PROCEDURE WrapUp_Standard_PO;


/*******************************************************************
  PROCEDURE NAME: Process_Price_Change

  DESCRIPTION   : This API is called from the  procedure
		  Process_Releases to update the release with the
		  new price as a result of a retroactive change in
		  the blanket line.
  Referenced by :
  parameters    : p_po_line_location_id IN Number
		  x_retroactive_change IN Varchar2(1)

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
PROCEDURE Process_Price_Change
 (p_row_id                              IN VARCHAR2,
  p_document_id                         IN NUMBER,
  p_po_line_location_id	                IN NUMBER,
  p_retroactive_date                    IN DATE,
  p_quantity                            IN NUMBER,
  p_ship_to_organization_id             IN NUMBER,
  p_ship_to_location_id                 IN NUMBER,
  p_po_line_id            		IN NUMBER,
  p_old_price_override                  IN NUMBER,
  p_need_by_date                        IN DATE,
  p_global_agreement_flag               IN VARCHAR2,
  p_authorization_status                IN VARCHAR2,
  p_rev_num                             IN Number,
  p_archived_rev_num                    IN Number,
  p_contract_id                         IN NUMBER   --<R12 GBPA Adv Pricing >
);


/*******************************************************************
  PROCEDURE NAME: Launch_PO_Approval

  DESCRIPTION   : This API calls the Pl/sql API for submission check for
		  PO and if they are are successful calls the
		  procedure   PO_RETROACTIVE_PRICING_PVT.
		  Retroactive_Launch_Approval which initiates the
		  Approval Workflow.
  Referenced by :
  parameters    :

  CHANGE History: Created      18-Oct-2002    pparthas
*******************************************************************/

PROCEDURE Launch_PO_Approval;

/*******************************************************************
  PROCEDURE NAME: Launch_REL_Approval

  DESCRIPTION   : This API calls the Pl/sql API for submission check for
		  Releases and if they are are successful calls the
		  procedure   PO_RETROACTIVE_PRICING_PVT.
		  Retroactive_Launch_Approval which initiates the
		  Approval Workflow.
  Referenced by :
  parameters    :

  CHANGE History: Created      18-Oct-2002    pparthas
*******************************************************************/

PROCEDURE Launch_REL_Approval;

/*******************************************************************
  PROCEDURE NAME: Retroactive_Launch_Approval

  DESCRIPTION   : This API is called from the  procedure
		  WrapUp_Releases and WrapUp_Standard_PO.
		  This procedure calls the po_reqapproval_init1.
		  start_wf_process after setting the common
		  parameters.
  Referenced by :
  parameters    : p_po_line_location_id IN Number
		  x_retroactive_change IN Varchar2(1)

  CHANGE History: Created      30-Sep-2002    pparthas
*******************************************************************/
Procedure Retroactive_Launch_Approval(
p_doc_id                IN      Number,
p_doc_type              IN      Varchar2,
p_doc_subtype           IN      Varchar2);


/*******************************************************************
  FUNCTION NAME : getDatabaseVersion

  DESCRIPTION   : This API is called from the procedure
                  MassUpdate_Releases.
                  It returns the database version number.
  Referenced by :

  Parameters    : l_version NUMBER

  CHANGE History: Created      21-Mar-2003    davidng
                  Deleted      02-Jul-2005    scolvenk
*******************************************************************/



-- <FPJ Retroactive START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Retro_mode
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns retroactive pricing mode.
--Parameters:
--IN:
--  None.
--RETURN:
--  'NEVER': 		Not Supported
--  'OPEN_RELEASES':  	Retroactive Pricing Update on Open Releases
--  'ALL_RELEASES':  	Retroactive Pricing Update on All Releases
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Get_Retro_Mode RETURN VARCHAR2;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Is_Retro_Update
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns retroactive pricing status.
--Parameters:
--IN:
--p_document_id
--  The id of the document (po_header_id or po_release_id)
--p_document_type
--  The type of the document
--    PO :      Standard PO
--    RELEASE : Release
--RETURN:
--  'Y': 	Retroactive Pricing Update
--  'N':  	Not a Retroactive Pricing Update
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Is_Retro_Update(p_document_id		IN         NUMBER,
                     	 p_document_type	IN         VARCHAR2)
  RETURN VARCHAR2;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Reset_Retro_Update
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function resets retroactive_date.
--Parameters:
--IN:
--p_document_id
--  The id of the document (po_header_id or po_release_id)
--p_document_type
--  The type of the document
--    PO :      Standard PO
--    RELEASE : Release
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Reset_Retro_Update(p_document_id	IN         NUMBER,
                     	     p_document_type	IN         VARCHAR2);

--------------------------------------------------------------------------------
--Start of Comments
--Name: Retro_Invoice_Release
--Pre-reqs:
--  None.
--Modifies:
--  PO_DISTRIBUTIONS_ALL.invoice_adjustment_flag.
--Locks:
--  None.
--Function:
--  This procedure updates invoice adjustment flag, and calls Costing
--  and Inventory APIs.
--Parameters:
--IN:
--p_api_version
--  Version number of API that caller expects. It
--  should match the l_api_version defined in the
--  procedure (expected value : 1.0)
--p_document_id
--  The id of the document (po_header_id or po_release_id)
--p_document_type
--  The type of the document
--    PO :      Standard PO
--    RELEASE : Release
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_count
--  Number of Error messages
--x_msg_data
--  Contains error msg in case x_return_status returned
--  FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Retro_Invoice_Release(p_api_version	IN         NUMBER,
                                p_document_id	IN         NUMBER,
                     		p_document_type	IN         VARCHAR2,
                     		x_return_status	OUT NOCOPY VARCHAR2,
                     		x_msg_count	OUT NOCOPY NUMBER,
                     		x_msg_data	OUT NOCOPY VARCHAR2);

-- <FPJ Retroactive END>

--------------------------------------------------------------------------------
--Start of Comments :Bug 3231062
--Name: Is_Retro_Project_Allowed
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns true if retroactive pricing update allow on line with
--  project reference.
--Note:
--  Removed after 11iX
--Parameters:
--IN:
--p_std_po_price_change
--p_po_line_id
--p_po_line_loc_id
--RETURN:
--  'Y': 	Retroactive pricing update is allowed
--  'N':  	Retroactive pricing update is not allowed
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Is_Retro_Project_Allowed(p_std_po_price_change IN VARCHAR2,
                                  p_po_line_id          IN NUMBER,
                                  p_po_line_loc_id      IN NUMBER
                                 )
RETURN VARCHAR2;

--------------------------------------------------------------------------------
--Start of Comments :Bug 3339149
--Name: Is_Adjustment_Account_Valid
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns true if the adjustment account exists and is valid
--Parameters:
--IN:
--p_std_po_price_change
--p_po_line_id
--p_ship_to_organization_id
--RETURN:
--  'Y': 	Adjustment account is valid
--  'N':  	Adjustment Account does not exist or is not valid
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Is_Adjustment_Account_Valid(p_std_po_price_change IN VARCHAR2,
                                     p_po_line_id          IN NUMBER,
                                     p_po_line_loc_id      IN NUMBER
                                     )
RETURN VARCHAR2;

END PO_RETROACTIVE_PRICING_PVT;

 

/
