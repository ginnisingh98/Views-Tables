--------------------------------------------------------
--  DDL for Package EDR_PSIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_PSIG" AUTHID CURRENT_USER AS
/* $Header: EDRPSIGS.pls 120.2.12000000.1 2007/01/18 05:54:46 appldev ship $ */

/* Record Type Decleration */

TYPE params_rec IS RECORD (Param_Name VARCHAR2(80),
                           Param_Value VARCHAR2(4000),Param_displayname varchar2(240));
TYPE params_table is TABLE of params_rec INDEX by Binary_INTEGER;

TYPE Document is Record (
      DOCUMENT_ID                 EDR_PSIG_DOCUMENTS.DOCUMENT_ID%TYPE,
      PSIG_XML                  EDR_PSIG_DOCUMENTS.PSIG_XML%TYPE,
      PSIG_DOCUMENT             EDR_PSIG_DOCUMENTS.PSIG_DOCUMENT%TYPE,
      PSIG_DOCUMENTFORMAT   EDR_PSIG_DOCUMENTS.PSIG_DOCUMENTFORMAT%TYPE,
      PSIG_TIMESTAMP            EDR_PSIG_DOCUMENTS.PSIG_TIMESTAMP%TYPE,
      PSIG_TIMEZONE             EDR_PSIG_DOCUMENTS.PSIG_TIMEZONE%TYPE,
      DOCUMENT_REQUESTER        EDR_PSIG_DOCUMENTS.DOCUMENT_REQUESTER%TYPE,
      PSIG_STATUS               EDR_PSIG_DOCUMENTS.PSIG_STATUS%TYPE,
      PSIG_SOURCE               EDR_PSIG_DOCUMENTS.PSIG_SOURCE%TYPE,
      EVENT_NAME                EDR_PSIG_DOCUMENTS.EVENT_NAME%TYPE,
      EVENT_KEY                 EDR_PSIG_DOCUMENTS.EVENT_KEY%TYPE,
      PRINT_COUNT               EDR_PSIG_DOCUMENTS.PRINT_COUNT%TYPE,
      CREATION_DATE             EDR_PSIG_DOCUMENTS.CREATION_DATE%TYPE,
      CREATED_BY                EDR_PSIG_DOCUMENTS.CREATED_BY%TYPE,
      LAST_UPDATE_DATE          EDR_PSIG_DOCUMENTS.LAST_UPDATE_DATE%TYPE,
      LAST_UPDATED_BY           EDR_PSIG_DOCUMENTS.LAST_UPDATED_BY%TYPE,
      LAST_UPDATE_LOGIN     EDR_PSIG_DOCUMENTS.LAST_UPDATE_LOGIN%TYPE
                       );

TYPE DocumentTable is TABLE of Document INDEX by Binary_INTEGER;

TYPE Signature is Record (
                        SIGNATURE_ID                    EDR_PSIG_DETAILS.SIGNATURE_ID%TYPE,
      DOCUMENT_ID                 EDR_PSIG_DETAILS.DOCUMENT_ID%TYPE,
      EVIDENCE_STORE_ID         EDR_PSIG_DETAILS.EVIDENCE_STORE_ID%TYPE,
      USER_NAME             EDR_PSIG_DETAILS.USER_NAME%TYPE,
      USER_RESPONSE       EDR_PSIG_DETAILS.USER_RESPONSE%TYPE,
      SIGNATURE_TIMESTAMP           EDR_PSIG_DETAILS.SIGNATURE_TIMESTAMP%TYPE,
      SIGNATURE_TIMEZONE            EDR_PSIG_DETAILS.SIGNATURE_TIMEZONE%TYPE,
      SIGNATURE_STATUS          EDR_PSIG_DETAILS.SIGNATURE_STATUS%TYPE,
      CREATION_DATE             EDR_PSIG_DETAILS.CREATION_DATE%TYPE,
      CREATED_BY                EDR_PSIG_DETAILS.CREATED_BY%TYPE,
      LAST_UPDATE_DATE          EDR_PSIG_DETAILS.LAST_UPDATE_DATE%TYPE,
      LAST_UPDATED_BY           EDR_PSIG_DETAILS.LAST_UPDATED_BY%TYPE,
      LAST_UPDATE_LOGIN     EDR_PSIG_DETAILS.LAST_UPDATE_LOGIN%TYPE,
      --Bug 3101047 : Start
      USER_DISPLAY_NAME   EDR_PSIG_DETAILS.USER_DISPLAY_NAME%TYPE
      --Bug 3101047 : End
                       );

TYPE SignatureTable is TABLE of Signature INDEX by Binary_INTEGER;

--Bug 3212117: Start
Type XMLTYPE_TBL is table of XMLType INDEX BY BINARY_INTEGER;
Type NUMBER_TBL is table of NUMBER INDEX BY BINARY_INTEGER;
--Bug 3212117: End

/* Document Creation Procedure
   IN:
    PSIG_XML
    PSIG_DOCUMENT
    PSIG_DOCUMENTFORMAT
    PSIG_REQUESTER
    PSIG_SOURCE
    EVENT_NAME
    EVENT_KEY

*/

PROCEDURE openDocument
  (
         P_PSIG_XML             IN CLOB DEFAULT NULL,
         P_PSIG_DOCUMENT        IN CLOB DEFAULT NULL,
         P_PSIG_DOCUMENTFORMAT  IN VARCHAR2 DEFAULT NULL,
         P_PSIG_REQUESTER       IN VARCHAR2,
         P_PSIG_SOURCE          IN VARCHAR2 DEFAULT NULL,
         P_EVENT_NAME           IN VARCHAR2 DEFAULT NULL,
         P_EVENT_KEY            IN VARCHAR2 DEFAULT NULL,
         p_WF_NID               IN NUMBER   DEFAULT NULL,
         P_DOCUMENT_ID          OUT NOCOPY NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  );



/* Document Creation Procedure

   Over Loaded Procedure if you just want to create a document and later update the columns you can use this
   procedure */

PROCEDURE openDocument
  (      P_DOCUMENT_ID          OUT NOCOPY NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  );


/* Close Document
   IN:
    P_DOCUMENT_ID

*/

PROCEDURE closeDocument
  (
         P_DOCUMENT_ID          IN  NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  );

/* Update Document
   IN:
    PSIG_XML
    PSIG_DOCUMENT
    PSIG_DOCUMENTFORMAT
    PSIG_REQUESTER
    PSIG_SOURCE
    EVENT_NAME
    EVENT_KEY

*/

PROCEDURE updateDocument
  (
         P_DOCUMENT_ID          IN NUMBER,
         P_PSIG_XML             IN CLOB DEFAULT NULL,
         P_PSIG_DOCUMENT        IN CLOB DEFAULT NULL,
         P_PSIG_DOCUMENTFORMAT  IN VARCHAR2 DEFAULT NULL,
         P_PSIG_REQUESTER       IN VARCHAR2,
         P_PSIG_SOURCE          IN VARCHAR2 DEFAULT NULL,
         P_EVENT_NAME           IN VARCHAR2 DEFAULT NULL,
         P_EVENT_KEY            IN VARCHAR2 DEFAULT NULL,
         p_WF_NID               IN NUMBER   DEFAULT NULL,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  );

/* Change document Statues */


PROCEDURE changeDocumentStatus
  (
         P_DOCUMENT_ID          IN  NUMBER,
         P_STATUS               IN  VARCHAR2,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  );




/* Cancel Document
   IN:
    P_DOCUMENT_ID


*/

PROCEDURE cancelDocument
  (
         P_DOCUMENT_ID          IN  NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  );

/* this Procedure is used to requrest a signature for a given document .
   this procedure will allow a new signature row to be create in the signature table for the
   given document and user. This should have a follow up with postsignature api with more details */

--Bug 3330240 : start
--Added two new IN parameters P_SIGNATURE_SEQUENCE, P_ADHOC_STATUS

PROCEDURE requestSignature
         (
          P_DOCUMENT_ID            IN NUMBER,
          P_USER_NAME              IN VARCHAR2,
          P_ORIGINAL_RECIPIENT     IN VARCHAR2 DEFAULT NULL,
          P_OVERRIDING_COMMENTS    IN VARCHAR2 DEFAULT NULL,
          P_SIGNATURE_SEQUENCE     IN NUMBER DEFAULT NULL,
          P_ADHOC_STATUS           IN VARCHAR2 DEFAULT NULL,
          P_SIGNATURE_ID          OUT NOCOPY NUMBER,
          P_ERROR                 OUT NOCOPY NUMBER,
          P_ERROR_MSG             OUT NOCOPY VARCHAR2
          );



/* Post Signatures
   IN:
    P_DOCUMENT_ID
    P_EVIDENCE_STORE_ID
    P_USER_NAME
    P_USER_RESPONSE

*/


PROCEDURE postSignature
         (
          P_DOCUMENT_ID            IN NUMBER,
          P_EVIDENCE_STORE_ID      IN VARCHAR2,
          P_USER_NAME              IN VARCHAR2,
          P_USER_RESPONSE          IN VARCHAR2,
          P_ORIGINAL_RECIPIENT     IN VARCHAR2 DEFAULT NULL,
          P_OVERRIDING_COMMENTS    IN VARCHAR2 DEFAULT NULL,
          P_SIGNATURE_ID          OUT NOCOPY NUMBER,
          P_ERROR                 OUT NOCOPY NUMBER,
          P_ERROR_MSG             OUT NOCOPY VARCHAR2
          );

/* Cancel Signature
   IN:
    P_SIGNATURE_ID


*/

PROCEDURE cancelSignature
  (
         P_SIGNATURE_ID          IN  NUMBER,
         P_ERROR                OUT NOCOPY NUMBER,
         P_ERROR_MSG            OUT NOCOPY VARCHAR2
  );


/* Post Document Parameters */

PROCEDURE postDocumentParameter
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_PARAMETERS           IN  EDR_PSIG.params_table,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        );

/* Delete Document Parameters */

PROCEDURE deleteDocumentParameter
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_PARAMETER_NAME       IN  VARCHAR,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        );


/* Delete All Document Parameters */

PROCEDURE deleteAllDocumentParams
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        );

/* Post Signature Parameters */


PROCEDURE postSignatureParameter
          (
           P_SIGNATURE_ID         IN  NUMBER,
           P_PARAMETERS           IN  EDR_PSIG.params_table,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        );

/* Delete Signature Parameters */

PROCEDURE deleteSignatureParameter
          (
           P_SIGNATURE_ID          IN  NUMBER,
           P_PARAMETER_NAME        IN  VARCHAR,
           P_ERROR                OUT  NOCOPY NUMBER,
           P_ERROR_MSG            OUT  NOCOPY VARCHAR2
        );


/* Delete All Signature Parameters */

PROCEDURE deleteAllSignatureParams
          (
           P_SIGNATURE_ID          IN  NUMBER,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        );

/* Get Document Details */

PROCEDURE getDocumentDetails
          (
           P_DOCUMENT_ID          IN  NUMBER,
           P_DOCUMENT             OUT NOCOPY EDR_PSIG.DOCUMENT,
           P_DOCPARAMS            OUT NOCOPY EDR_PSIG.params_table,
           P_SIGNATURES           OUT NOCOPY EDR_PSIG.SignatureTable,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        );

/* Get Document Details */

PROCEDURE getSignatureDetails
          (
           P_SIGNATURE_ID         IN  NUMBER DEFAULT NULL,
           P_SIGNATUREDETAILS     OUT NOCOPY EDR_PSIG.Signature,
           P_SIGNATUREPARAMS      OUT NOCOPY EDR_PSIG.params_table,
           P_ERROR                OUT NOCOPY NUMBER,
           P_ERROR_MSG            OUT NOCOPY VARCHAR2
        );


PROCEDURE updatePrintCount (
  P_DOC_ID    IN  edr_psig_documents.document_id%TYPE,
  P_NEW_COUNT OUT NOCOPY  NUMBER
  );

--Bug 3330240 : start
--This procedure would get the signatureid for the
--for the documentid, originalrecipient, username, signaturestatus

-- Start of comments
-- API name             : getSignatureId
-- Type                 : Private Utility.
-- Function             : Gets Signatureid for the documentid,
--                        originalrecipeint, username, signaturestatus
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_DOCUMENT_ID in number
--                        P_ORIGINAL_RECIPIENT in varchar2
--                        P_USER_NAME in varchar2
--                        P_SIGNATURE_STATUS in varchar2
-- OUT                  : X_SIGNATURE_ID out NOCOPY number
--                        X_ERROR out NOCOPY number
--                        X_ERROR_MSG out NOCOPY varchar2
--
-- End of comments

procedure getSignatureId (P_DOCUMENT_ID in number,
                          P_ORIGINAL_RECIPIENT in varchar2,
                          P_USER_NAME in varchar2,
                          P_SIGNATURE_STATUS in varchar2,
                          X_SIGNATURE_ID out NOCOPY number,
                          X_ERROR out NOCOPY number,
                          X_ERROR_MSG out NOCOPY varchar2);

--This procedure would get the adhoc status for the signatureid

-- Start of comments
-- API name             : GET_ADHOC_STATUS
-- Type                 : Private Utility.
-- Function             : Gets Adhoc status for Signatureid ,
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_SIGNATURE_ID in number
-- OUT                  : X_STATUS out NOCOPY varchar2
--                        X_ERROR out NOCOPY number
--                        X_ERROR_MSG out NOCOPY varchar2
--
-- End of comments

procedure GET_ADHOC_STATUS (  P_SIGNATURE_ID IN NUMBER,
                              X_STATUS OUT NOCOPY VARCHAR2,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2);

--This procedure would delete the signer row if the signer is adhoc for the signatureid

-- Start of comments
-- API name             : DELETE_ADHOC_USER
-- Type                 : Private Utility.
-- Function             : Delete the signer row is thts adhos user
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_SIGNATURE_ID in number
-- OUT                  : X_ERROR out NOCOPY number
--                        X_ERROR_MSG out NOCOPY varchar2
--
-- End of comments

procedure DELETE_ADHOC_USER ( P_SIGNATURE_ID IN NUMBER,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2);


--This procedure would update the signature sequence for the signatureid

-- Start of comments
-- API name             : UPDATE_SIGNATURE_SEQUENCE
-- Type                 : Private Utility.
-- Function             : Update the signatire sequence for the signature id
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_SIGNATURE_ID in number
--                        P_SIGNATURE_SEQUENCE in number
-- OUT                  : X_ERROR out NOCOPY number
--                        X_ERROR_MSG out NOCOPY varchar2
--
-- End of comments
procedure UPDATE_SIGNATURE_SEQUENCE ( P_SIGNATURE_ID in number,
                                      P_SIGNATURE_SEQUENCE in number,
                                      X_ERROR OUT NOCOPY number,
                                      X_ERROR_MSG OUT NOCOPY varchar2);


--This procedure would update the adhoc status for the signatureid

-- Start of comments
-- API name             : UPDATE_ADHOC_STATUS
-- Type                 : Private Utility.
-- Function             : Update the adhoc status for the signature id
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_SIGNATURE_ID in number
--                        P_ADHOC_STATUS in varchar2
-- OUT                  : X_ERROR out NOCOPY number
--                        X_ERROR_MSG out NOCOPY varchar2
--
-- End of comments


procedure UPDATE_ADHOC_STATUS ( P_SIGNATURE_ID in number,
                                P_ADHOC_STATUS in varchar2,
                                X_ERROR OUT NOCOPY number,
                                X_ERROR_MSG OUT NOCOPY varchar2);

--Bug 3330240 : end

-- Bug 3170251 - Start
-- Added a getter to get PSIG_XML (eRecord XML ) in CLOB.
--This procedure gets the PSIG_XML from EDR_PSIG_DOCUMENTS table
--for the given p_document_id i.e. eRecordId

-- Start of comments
-- API name             : getERecordXML
-- Type                 : Public Utility
-- Function             : Get the XML Document Contents for given eRecordId
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_DOCUMENT_ID in number
-- OUT                  : X_PSIG_XML OUT NOCOPY CLOB
--                      : X_ERROR_CODE out NOCOPY number
--                      : X_ERROR_MSG out NOCOPY varchar2
-- End of comments

procedure getERecordXML( P_DOCUMENT_ID number,
                         X_PSIG_XML    OUT NOCOPY CLOB,
                         X_ERROR_CODE  OUT NOCOPY NUMBER,
                         X_ERROR_MSG   OUT NOCOPY VARCHAR2 );


-- Bug 3170251 - End


--Bug 3101047: Start

-- Start of comments
-- API name             : UPDATE_PSIG_USER_DETAILS
-- Type                 : Private Utility
-- Function             : Update the user details of those users in EDR_PSIG_DETAILS table
--                      : for the specified document_id and whose signature status is pending.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_DOCUMENT_ID IN NUMBER
-- OUT                  : NONE
-- End of comments

PROCEDURE UPDATE_PSIG_USER_DETAILS (P_DOCUMENT_ID IN NUMBER);

--Bug 3101047: End


--Bug 3212117: Start
-- Start of comments
-- API name             : GET_EVENT_XML
-- Type                 : Private Utility
-- Function             : Obtains the event xml for the specified event name,event key and e-record ID combination.
--                      : This API can also be used in conjunction with an event name/event key combination or just the e-record ID value.
--                      : In this scenario, the details of all the e-records identified by this combination would be
--                      : fetched in XML format.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_EVENT_NAME               IN VARCHAR2  - The event name
--                      : P_EVENT_KEY                IN VARCHAR2  - The event key
--                      : P_ERECORD_ID               IN NUMBER    - The e-record ID
--                      : P_GET_ERECORD_XML          IN VARCHAR2  - Flag indicating if the psig xml data is to be fetched.
--                      : P_GET_PSIG_DETAILS         IN VARCHAR2  - Flag indicating if the signature details are to be fetched.
--                      : P_GET_ACKN_DETAILS         IN VARCHAR2  - Flag indicating if the acknowledgement details are to be fetched.
--                      : P_GET_PRINT_DETAILS        IN VARCHAR2  - Flag indicating if the print history details are to be fetched.
--                      : P_GET_RELATED_EREC_DETAILS IN VARCHAR2  - Flag indicating if the related e-record details are to be fetched.
--
-- OUT                  : X_FINAL_XML                OUT CLOB    - The event data in XML format.
-- End of comments
PROCEDURE GET_EVENT_XML(P_EVENT_NAME               IN VARCHAR2,
                        P_EVENT_KEY                IN VARCHAR2,
                        P_ERECORD_ID               IN NUMBER,
                        P_GET_ERECORD_XML          IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        P_GET_PSIG_DETAILS         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        P_GET_ACKN_DETAILS         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        P_GET_PRINT_DETAILS        IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        P_GET_RELATED_EREC_DETAILS IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                        X_FINAL_XML                OUT NOCOPY CLOB);
--Bug 3212117: End

-- Bug 4558923 :start


/* Get_DOCUMENT_STATUS. This procedure will return the current document status for a given document_id
   if document is not availalbe the procedure will raise a not data found exception
*/

PROCEDURE GET_DOCUMENT_STATUS(P_DOCUMENT_ID IN NUMBER,
                              X_STATUS OUT NOCOPY VARCHAR2,
                              X_ERROR OUT  NOCOPY NUMBER,
                              X_ERROR_MSG OUT NOCOPY VARCHAR2);

-- Bug 4558923 :end

--Bug 4577122 : start
--This procedure take an erecord id and make the signature status null
--for all the pending signers. the signature row itself would not be removed
--only status would be made null

-- Start of comments
-- API name             : clear_pending_signatures
-- Type                 : Private Utility.
-- Function             : nullifies the signature status of pending signers
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_DOCUMENT_ID in number
-- OUT                  : none
--
-- End of comments
procedure clear_pending_signatures
(p_document_id in number);

--Bug 4577122: End

END EDR_PSIG;

 

/
