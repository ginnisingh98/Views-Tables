--------------------------------------------------------
--  DDL for Package PO_COMMUNICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_COMMUNICATION_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVCOMS.pls 120.13.12010000.13 2014/02/17 02:01:27 zhijfeng ship $ */

 /*=======================================================================+
 | FILENAME
 |   POXVCOMS.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package:  PO_COMMUNICATION_PVT
 |
 | NOTES
 *=====================================================================*/

/* FPJ PO COMMUNICATION PROJECT */
/*******************************************************************
  PROCEDURE NAME: PO_NEW_COMMUNICATION()

 DESCRIPTION   :This function will be called from the workflow process to Verify
 whether the user is using the PO New Communication Method or not

 Referenced by :
 parameters    :

  CHANGE History: Created    VSANJAY
*******************************************************************/

 procedure PO_NEW_COMMUNICATION(itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2 );

/*******************************************************************
  PROCEDURE NAME: GENERATE_PDF()

  Description : This function will be called from the workflow process to genera
te the pdf document. It launches the concurrent program "Dispatch Purchase Order
".

 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

procedure GENERATE_PDF(itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2 );

/*******************************************************************
  PROCEDURE NAME: Delete_PDF_Attachments()

  Description : This function will be called from the workflow process to delete
 the pdf's from the fnd_attachment tables.

 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

PROCEDURE Delete_PDF_Attachments (itemtype IN VARCHAR2,
                                           itemkey  IN VARCHAR2,
                                           actid    IN NUMBER,
                                           funcmode IN VARCHAR2,
                                           resultout   OUT NOCOPY VARCHAR2);

/*******************************************************************
  PROCEDURE NAME: PO_PDF_EXISTS()

  Description : This function will be called from the workflow process to Verify
  whether PDF exists for the Current Document

 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

 procedure PO_PDF_EXISTS(itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2 );

/*******************************************************************
  PROCEDURE NAME: Start_Email_WF_Process()

 DESCRIPTION   : This function will be called from the workflow process to the
email to the supplier with PDF as an attachment
 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

procedure Start_Email_WF_Process(p_document_id           NUMBER,
                                 p_revision_num          NUMBER,
                                 p_document_type         VARCHAR2,
                                 p_document_subtype      VARCHAR2,
                                 p_email_address         VARCHAR2,
                                 p_language_code         VARCHAR2,
                                 p_store_flag            VARCHAR2,
                                 p_with_terms            VARCHAR2 );


/*******************************************************************
  PROCEDURE NAME: GENERATE_PDF_BUYER()

  Description : This function will be called from the workflow process to genera
te the pdf document without T's and C's in buyers language . It launches the concurrent program "Dispatch Purchase Order".

 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

procedure GENERATE_PDF_BUYER(itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2 );

/*******************************************************************
  PROCEDURE NAME: GENERATE_PDF_SUPP()

  Description : This function will be called from the workflow process to genera
te the pdf document without T's and C's in suppliers  language . It launches the concurrent program "Dispatch Purchase Order".

 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

procedure GENERATE_PDF_SUPP(itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2 );

/*******************************************************************
  PROCEDURE NAME: GENERATE_PDF_EMAIL_PROCESS()

  Description : This function will be called from the email po pdf workflow process to generate the pdf document . It launches the concurrent program "Dispatch Purchase Order".

 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

procedure GENERATE_PDF_EMAIL_PROCESS(itemtype        in varchar2,
                                     itemkey         in varchar2,
                                     actid           in number,
                                     funcmode        in varchar2,
                                     resultout       out NOCOPY varchar2 );

/*******************************************************************
  PROCEDURE NAME: LAUNCH_COMMUNICATE()

  Description : This function will launch the concurrent request which is requested
  from the communicate window


 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/


procedure  launch_communicate(p_mode in varchar2,
			     p_document_id in number ,
			     p_revision_number in number,
                             p_document_type in varchar2,
                             p_authorization_status in varchar2,
                             p_language_code in varchar2,
                             p_fax_enable in varchar2,
                             p_fax_num in varchar2,
                             p_with_terms in varchar2,
                             p_print_flag in  varchar2,
                             p_store_flag in varchar2,
                             p_request_id out NOCOPY number);

/*******************************************************************
  PROCEDURE NAME:  COMMUNICATE()

  Description : This function will launch the concurrent request which is requested
  from the communicate window


 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/


procedure   Communicate(p_authorization_status in varchar2,
 	                p_with_terms in varchar2,
			p_language_code in varchar2,
			p_mode     in varchar2,
			p_document_id in number ,
			p_revision_number in number,
		        p_document_type in varchar2,
		        p_fax_number in varchar2,
                        p_email_address in varchar2,
                        p_request_id out NOCOPY number);

function  po_communication_profile RETURN VARCHAR2;
function IS_PON_PRINTING_ENABLED RETURN VARCHAR2;
function USER_HAS_ACCESS_TC RETURN VARCHAR2;
/*******************************************************************
  <PO Attachment Support 11i.11> Changed the name of the procedure
      to Store_Blob because it will now be used for creating Blob
      locator for Zip file also, not just PDF
  PROCEDURE NAME:  Store_Blob()

  Description : This method will store the generated Blob in the repository
                PO_HEAD or PO_REL

 Referenced by :
 parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/
procedure Store_Blob(p_document_id number ,
                    p_revision_number number ,
                    p_document_type varchar2,
                    p_file_name varchar2,
                    p_blob_type varchar2, --<PO Attachment Support 11i.11>
                    x_media_id  out nocopy number);

/*******************************************************************
  PROCEDURE NAME:  pdf_attach_app

  Description : This function will retrieve the pdf document
  from the fnd attachments table

  Referenced by :
  parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/


procedure pdf_attach_app(document_id   in varchar2,
                          content_type  in varchar2,
                          document      in out nocopy blob,
                          document_type in out nocopy varchar2);

/*******************************************************************
  PROCEDURE NAME:  pdf_attach_supp

  Description : This function will retrieve the pdf document
  from the fnd attachments table

  Referenced by :
  parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/


procedure pdf_attach_supp(document_id   in varchar2,
                          content_type  in varchar2,
                          document      in out nocopy blob,
                          document_type in out nocopy varchar2);

/*******************************************************************
  PROCEDURE NAME:  pdf_attach

  Description : This function will retrieve the pdf document
  from the fnd attachments table

  Referenced by :
  parameters    :

  CHANGE History: Created     VSANJAY
*******************************************************************/

procedure pdf_attach(document_id   in varchar2,
                          content_type  in varchar2,
                          document      in out nocopy blob,
                          document_type in out nocopy varchar2);


-- <Start Word Integration 11.5.10+>
/*******************************************************************
  PROCEDURE NAME:  okc_doc_attach

  Description : This function will retrieve the attached contract
  document from the contracts repository (fnd_attachments table)

  Referenced by :
  parameters    :

  CHANGE History: Created     SPANGULU
*******************************************************************/

PROCEDURE okc_doc_attach(document_id    in     varchar2,
                         content_type   in     varchar2,
                         document       in out nocopy blob,
                         document_type  in out nocopy varchar2);

-- <End Word Integration 11.5.10+>



-------------------------------------------------------------------------------
--Start of Comments
--Name: zip_attach
--Pre-reqs:
--  Zip file should be generated correctly and stored in the database
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Queries the Zip Blob for specified document and returns it as a blob
--  to attach to the workflow notification
--Parameters:
--  Follows workflow standatd API specification for documents
--IN:
--document_id
--  A string the uniquely identifies the document to be attached
--content_type
--  For PL/SQL Blob documents, the values is ''
--IN OUT:
--document
--  Outbound Lob locator for the Blob to be attached
--document_type
--  String buffer that contains the content type of outbound Blob
--Notes:
--  Added as a part of <PO Attachment Support 11i.11>
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE zip_attach(document_id      in     varchar2,
                     content_type     in     varchar2,
                     document         in out nocopy blob,
                     document_type    in out nocopy varchar2);

-------------------------------------------------------------------------------
--Start of Comments
--Name: set_zip_error_code
--Pre-reqs:
--  None.
--Modifies:
--  Workflow Attribute zip_error_code
--Locks:
--  None.
--Function:
--  Sets the workflow attribute zip_error_code to the value passed in
--Parameters:
--IN:
--p_itemtype
--  String that identifies the workflow process
--p_itemkey
--  Uniquely identifies the current instance of the workflow process
--p_zip_error_code
--  Value to which the workflow attribute zip_error_code should be
--  set to. Possible values can be OVERSIZED, DUPLICATE_FILENAME
--  and UNEXPECTED (values of lookup type POAPPRV_ZIP_ERROR_CODE)
--Notes:
--  Added as a part of <PO Attachment Support 11i.11>
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_zip_error_code (p_itemtype       IN VARCHAR2,
                              p_itemkey        IN VARCHAR2,
                              p_zip_error_code IN VARCHAR2);

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_zip_error_code
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the value of workflow attribute ZIP_ERROR_CODE
--Parameters:
--  Follows standard workflow API specification
--IN:
--itemtype
--  String that identifies the workflow process
--itemkey
--  Uniquely identifies the current instance of the workflow process
--actid
--  The ID number of the activity from which this procedure is callled
--funcmode
--  The execution mode of the activity
--OUT:
--resultout
--  Holds the value of the workflow attribute zip_error_code. Possible
--  values can be OVERSIZED, DUPLICATE_FILENAME and UNEXPECTED
--  (values of lookup type POAPPRV_ZIP_ERROR_CODE)
--Notes:
--  Added as a part of <PO Attachment Support 11i.11>
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_zip_error_code (itemtype IN VARCHAR2,
                              itemkey  IN VARCHAR2,
                              actid    IN NUMBER,
                              funcmode IN VARCHAR2,
                              resultout   OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_max_zip_size
--Pre-reqs:
--  Column max_attachment_size should exist in table po_system_parameters_all
--  Org context should be set correctly to enable querying from org striped
--  view po_system_parameters
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Queries the value of 'Maximum Attachment Size' which is the maximum
--  allowed size of the Zip file.
--Parameters:
--IN:
--itemtype
--  String that identifies the workflow process
--itemkey
--  Uniquely identifies the current instance of the workflow process
--Returns:
--  For functions:
--    Returns the values of 'Maximum Attachment Size' in Purchasing Options
--    Setup form. This is the maximum allowed size of the Zip file.
--Notes:
--  Added as a part of <PO Attachment Support 11i.11>
--  A value of 0 means Zip Attachments are not supported
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_max_zip_size (p_itemtype IN VARCHAR2,
                           p_itemkey  IN VARCHAR2) RETURN NUMBER;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_for_attachments
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Checks if any attachments of category 'To Supplier' and type 'File'
--  exist for the current PO/Release
--Parameters:
--IN:
--p_document_type
--  Document Type, can be PO, PA or RELEASE
--p_document_id
--  po_header_id for PO, PA and po_release_id for RELEASE
--Returns:
--  For functions:
--    Returns 'Y' if any attachments of category 'To Supplier' and type 'File'
--    exist for the current PO/Release
--Notes:
--  Added as a part of <PO Attachment Support 11i.11>
--  Exception handling for this light weight function is left to the calling
--  code. This is because the exception handling will be different in
--  different calls
--End of Comments
-------------------------------------------------------------------------------
FUNCTION check_for_attachments(p_document_type IN VARCHAR2,
                               p_document_id      IN NUMBER) RETURN VARCHAR2;


/*******************************************************************
  FUNCTION NAME:  POXMLGEN

  Description : This function will generate the XML for a Document

  Referenced by :
  parameters    :

  CHANGE History: Created    MANRAM
*******************************************************************/

function POXMLGEN(      p_api_version           in      NUMBER,
                        p_document_id           in      NUMBER,
                        p_revision_num          in      NUMBER,
                        p_document_type         in      VARCHAR2,
                        p_document_subtype      in      VARCHAR2,
                        p_test_flag             in      VARCHAR2,
                        p_which_tables          in      VARCHAR2,
                        p_with_terms            in      VARCHAR2, --Bug#3583910
                        -- Bug 3690810. Removed file.encoding parameter
                        p_with_canceled_lines   in      VARCHAR2 default 'Y', --Bug#6138794
                        p_with_closed_lines     in      VARCHAR2 default 'Y'  --Bug#17848722
) return clob ;

/**************************************************************************************
  FUNCTION NAME :  GET_DROP_SHIP_DETAILS

  Description   : This function retreives drop ship details for given line location id
  by calling OE_DROP_SHIP_GRP.GET_ORDER_LINE_INFO procedure.

  Referenced by :

  parameters    : p_location_id of type number as IN parameter

  CHANGE History: Created    MANRAM
*************************************************************************************/

function GET_DROP_SHIP_DETAILS(p_location_id in number) return number ;


/*******************************************************************
  The following functions returns the global variables that are
  populated by GET_DROP_SHIP_DETAILS function
*******************************************************************/
function getShipContPhone return VARCHAR2;
--bug#3438608 added three function getTownOrCity
--getPostalCode and getStateOrProvince
--to return the values in global variables
--po_communication_pvt.g_town_or_city
--po_communication_pvt.g_postal_code
--and po_communication_pvt.g_state_or_province.

function getTownOrCity return Varchar2;
function getStateOrProvince return Varchar2;
function getPostalCode return Varchar2;
--bug#3438608
function getShipContEmail return VARCHAR2;
function getDeliverContPhone return VARCHAR2;
function getDeliverContEmail return VARCHAR2;
function getShipContName return VARCHAR2;
function getDeliverContName return VARCHAR2;
function getShipCustName return VARCHAR2;
function getShipCustLocation return VARCHAR2;
function getDeliverCustName return VARCHAR2;
function getDeliverCustLocation return VARCHAR2 ;
function getShipContactfax	return VARCHAR2;
function getDeliverContactName	return VARCHAR2;
function getDeliverContactFax	return VARCHAR2;
function getShippingMethod	return VARCHAR2;
function getShippingInstructions return VARCHAR2;
function getPackingInstructions	return VARCHAR2;
function getCustomerProductDesc	return VARCHAR2;
function getCustomerPoNumber	return VARCHAR2;
function getCustomerPoLineNum	return VARCHAR2;
function getCustomerPoShipmentNum	return VARCHAR2;
/*******************************************************************
	End of functions that returns drop ship details
********************************************************************/


function getDocumentId RETURN NUMBER ;

function getRevisionNum RETURN NUMBER;

function getVendorId RETURN NUMBER;

function getVendorSiteId RETURN NUMBER; --bug 18090016

function getCoverMessage RETURN VARCHAR2;

function getAmendmentMessage RETURN VARCHAR2;

function getTimezone RETURN VARCHAR2;

function getTestFlag RETURN VARCHAR2;
function getReleaseHeaderId RETURN VARCHAR2 ;
 --ADD TO bug 16076162
 function getReleaseId RETURN VARCHAR2;

/*******************************************************************************
  FUNCTION NAME :  GETLOCATIONINFO

  Description   : This function retreives address details(like ship to, bill to)
  for a given location id  by calling PO_HR_LOCATION.GET_ADDRESS procedure and
  populates the retrieved values into global variables

  Referenced by :
  parameters    : p_location_id of type number as IN parameter

  CHANGE History: Created    MANRAM
********************************************************************************/
function getLocationInfo(p_location_id in number) return NUMBER;


/*******************************************************************
  The following functions returns the global variables that are
  populated by GETLOCATIONINFO function
*******************************************************************/

function getAddressLine1 return varchar2;
function getAddressLine2 return varchar2;
function getAddressLine3 return varchar2;
--Bug 4504228 function getPhone return varchar2;
/*Bug 4504228 Buyer contact phone and buyer email were not shown
 in PDF Output. Adding procedure getEmail() and
 changing the specification of getPhone()*/
function getPhone(p_agent_id in number) return varchar2;
function getEmail  return varchar2;
function getFax return varchar2;
function getLocationName return varchar2;
function getTerritoryShortName return varchar2;
function getAddressInfo return varchar2;
/*******************************************************************
	End of functions that returns address details
********************************************************************/



/*******************************************************************************
  FUNCTION NAME :  GETOPERATIONINFO

  Description   : This function retreives Operation Unit address details
  for  given  organization id  and  populates the retrieved values into
  global variables

  Referenced by :
  parameters    : p_org_id of type number as IN parameter

  CHANGE History: Created    MANRAM
********************************************************************************/
function getOperationInfo(p_org_id in NUMBER) return varchar2;


/*******************************************************************
  The following functions returns the Operation Unint address
  variables that are   populated by GETOPERATIONINFO function
*******************************************************************/
function getOUAddressLine1 return varchar2;
function getOUAddressLine2 return varchar2;
function getOUAddressLine3 return varchar2;
function getOUTownCity return varchar2;
function getOURegion2 return varchar2;
function getOUPostalCode return varchar2;
/*******************************************************************
	End of functions that returns operation unit address details
********************************************************************/

function getSegmentNum(p_header_id in NUMBER) return VARCHAR2;
function getAgreementLineNumber return VARCHAR2;
function getQuoteNumber	return VARCHAR2;
function getAgreementFlag return VARCHAR2;

function getAgreementLineNumber(p_line_id in NUMBER) return NUMBER;

function getArcBuyerAgentID(p_header_id in NUMBER) return NUMBER;
function getArcBuyerFName return VARCHAR2;
function getArcBuyerLName return VARCHAR2;
function getArcBuyerTitle return VARCHAR2;

function getRelArcBuyerAgentID(p_release_id in NUMBER) return NUMBER;

function getVendorAddressLine1(p_vendor_site_id in NUMBER) return VARCHAR2;
function getVendorAddressLine2 return VARCHAR2;
function getVendorAddressLine3 return VARCHAR2;
function getVendorCityStateZipInfo return VARCHAR2;
function getVendorCountry return VARCHAR2;

function getJob(p_job_id in NUMBER) return VARCHAR2;

function getDocumentType return VARCHAR2;

function getFormatMask return VARCHAR2;

function getLegalEntityName return VARCHAR2;

function IsDocumentSigned(p_header_id number) return  varchar2;

function getPDFFileName(p_document_type varchar2,
			p_terms varchar2,
			p_orgid number,
			p_document_id varchar2,
			p_revision_num number,
			p_language_code varchar2) return varchar2;

-- <Start Word Integration 11.5.10+>

function getRTFFileName(p_document_type varchar2,
			p_terms varchar2,
			p_orgid number,
			p_document_id varchar2,
			p_revision_num number,
			p_language_code varchar2) return varchar2;

-- <End Word Integration 11.5.10+>


-------------------------------------------------------------------------------
--Start of Comments
--Name: getZipFileName
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the name of the Zip file for current PO
--Parameters:
--  p_org_id of type number as IN parameter
--Returns:
--  For functions:
--    Returns the name of the Zip file for the PO
--Notes:
--  Added as a part of <PO Attachment Support 11i.11>
--  History
--    Bug# 5240634 Changed the signature to take in a org_id
--
--    The function used to construct the zip file name using
--    document type, orgid, document id and revision num as
--    p_document_type||'_'||p_orgid||'_'||l_document_number||'_'||p_revision_num||'.zip';
--    This was changed as per ECO Bug #43877577
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getZIPFileName(p_org_id in number) RETURN varchar2 ;

/* Function to retru Address line 4 value*/
--bug:346361
function getAddressLine4 return varchar2;

/* Function to retrun vendor Address line 4 value*/
--bug:346361
function getVendorAddressLine4 return VARCHAR2;


/*******************************************************************************
  FUNCTION NAME :  getLegalEntityDetails

  Description   : This function retreives Legal Entity address details
  for  given  inventory organization id  and  populates the retrieved values into
  global variables

  Referenced by :
  parameters    : p_org_id of type number as IN parameter

  CHANGE History: Created    MANRAM
********************************************************************************/
function getLegalEntityDetails(p_org_id in NUMBER) return varchar2;

/*******************************************************************
  The following functions returns Legal Entity address
  variables that are   populated by getLegalEntityDetails function
*******************************************************************/

function getLEAddressLine1 return varchar2;
function getLEAddressLine2 return varchar2;
function getLEAddressLine3 return varchar2;
function getLECountry return varchar2;
function getLETownOrCity return varchar2;
function getLEPostalCode return varchar2;
function getLEStateOrProvince return varchar2;
/*******************************************************************
	End of functions that returns operation unit address details
********************************************************************/

-- <Complex Work R12 Start>
-- Begin Functions Related To Complex Work Procurement

FUNCTION getIsComplexWorkPO RETURN VARCHAR2;

-- End Functions Related To Complex Work Procurement
-- <Complex Work R12 End>

/*
	Function returns distinct count of shipment level ship to from header level ship to. This count is
	used in XSL to identify what to display in ship to address at header and shipment level
*/
function getDistinctShipmentCount return number;

/*
	Function to retrieve cancel date for Standard, Blanket and Contract PO's
*/
function getPOCancelDate(p_po_header_id in NUMBER) return date;


/*	Function retuns the Operation Unit country value that
	retreived in getOperationInfo function.
*/
function getOUCountry return varchar2 ;


/*******************************************************************************
  FUNCTION NAME :  getCanceledAmount

  Description   : This function retreives Canceled Line amount and Total
  line amount for given line id. Returns canceled_amount and populates
  g_line_org_amount global variable with original line amount

  Referenced by :
  parameters    : p_po_line_id of type number as IN parameter
		  p_po_revision_num of type number as IN parameter
		  p_po_header_id of type number as IN parameter

  CHANGE History: Created    MANRAM
********************************************************************************/
function getCanceledAmount(p_po_line_id IN NUMBER,
			   p_po_revision_num IN NUMBER,
			   p_po_header_id IN NUMBER) return varchar2 ;


function getLineOriginalAmount return number;

/*Bug#3583910 return the global variable g_with_terms */
function getWithTerms return varchar2;


/*******************************************************************************
  bug#3630737.
  PROCEDURE NAME : getOUDocumentDetails

  Description   :  This procedure is called from the PoGenerateDocument.java
  file. This procedure retrieves and returns OperatingUnitName, Draft message
  from and document name.

  Referenced by : PoGenerateDocument.java
   CHANGE History: Created    MANRAM
********************************************************************************/

PROCEDURE getOUDocumentDetails(p_documentID IN NUMBER,
                               x_pendingSignatureFlag OUT NOCOPY VARCHAR2,
			       x_documentName OUT NOCOPY VARCHAR2,
			       x_organizationName OUT NOCOPY VARCHAR2,
			       x_draft OUT NOCOPY VARCHAR2) ;

/*********************************************************************************
bug#3630737.
Returns concatinated message of DocumentType, po number and revision number
**********************************************************************************/
function getDocumentName return VARCHAR2;

/*********************************************************************************
bug#3771735.
Returns the DocumentTypeCode stored in the global variable g_documentTypeCode
**********************************************************************************/
function getDocumentTypeCode return VARCHAR2;

/**************************************************************************
Bug 4026592
Returns whether contract source is attached document.
Stored in the global variable g_is_contract_attached_doc
***************************************************************************/
FUNCTION getIsContractAttachedDoc return VARCHAR2;

/*********************************************************************************
11i10+ Contract ER TC Sup Lang
Procedure to generate pdf with terms in suppliers language
**********************************************************************************/
PROCEDURE GENERATE_PDF_SUPP_TC (itemtype IN VARCHAR2,
                                itemkey  IN VARCHAR2,
                                actid    IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout   OUT NOCOPY VARCHAR2);

/*********************************************************************************
bug#AMIT.
Returns the Inventory Org Id stored in FINANCIALS_SYSTEM_PARAMETERS
**********************************************************************************/
FUNCTION getInventoryOrgId return NUMBER;
-- Added for bug 6692126
FUNCTION get_preparer_profile (p_document_id    NUMBER,
                               p_document_type  VARCHAR2,
                               p_profile_option VARCHAR2) RETURN VARCHAR2;


/********************************************************************************
 Bug5213932 Converts long text into clob and returns clob.
********************************************************************************/
FUNCTION get_clob(p_row_id IN ROWID) RETURN CLOB;

/*Bug4568471/6829381 Introduced two new functions*/
FUNCTION get_oneTime_loc(p_location_id NUMBER) RETURN  VARCHAR2;
FUNCTION get_oneTime_address(p_line_location_id NUMBER) RETURN CLOB;
/*Bug4568471/6829381*/

FUNCTION get_item_num(p_item_id NUMBER,p_org_id NUMBER) RETURN VARCHAR2;
/*Above function for bug8982745*/

FUNCTION getWithCanceledLines RETURN VARCHAR2;
/* Above function for Bug#1638794*/

FUNCTION getWithClosedLines RETURN VARCHAR2;
/* Above function for Bug#17848722*/

end  PO_COMMUNICATION_PVT;

/
