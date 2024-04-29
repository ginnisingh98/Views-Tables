--------------------------------------------------------
--  DDL for Package EDR_EVIDENCESTORE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_EVIDENCESTORE_PUB" AUTHID CURRENT_USER AS
/* $Header: EDRPEVRS.pls 120.0.12000000.1 2007/01/18 05:54:28 appldev ship $ */
/*#
 * This is the public interface for the Evidence Store, and it retrieves the e-record details.
 * @rep:scope public
 * @rep:metalink 268669.1 Oracle E-Records API User's Guide
 * @rep:product EDR
 * @rep:displayname E-records Evidence Store APIs
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EDR_EVIDENCE_STORE
 */

/* -- Public Record Type Decleration */

TYPE Params_tbl_type IS TABLE of edr_psig.params_rec INDEX by Binary_INTEGER;

-- TYPE Signature_tbl_type IS TABLE of edr_psig_details%ROWTYPE INDEX by Binary_INTEGER;
TYPE Signature_tbl_type IS TABLE of edr_psig.Signature INDEX by Binary_INTEGER;




-- ----------------------------------------
-- API name 	: Open_Document
-- Type		: Public
-- Function	: create a document instance for signature
--		: and can associate signatures before closing the docuemnt
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE open_Document	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	P_PSIG_XML    		IN 	CLOB DEFAULT NULL,
    	P_PSIG_DOCUMENT  	IN 	CLOB DEFAULT NULL,
        P_PSIG_DOCUMENTFORMAT  	IN 	VARCHAR2 DEFAULT NULL,
        P_PSIG_REQUESTER	IN 	VARCHAR2,
        P_PSIG_SOURCE    	IN 	VARCHAR2 DEFAULT NULL,
        P_EVENT_NAME  		IN 	VARCHAR2 DEFAULT NULL,
        P_EVENT_KEY  		IN 	VARCHAR2 DEFAULT NULL,
        p_WF_Notif_ID           IN 	NUMBER   DEFAULT NULL,
        x_DOCUMENT_ID          	OUT 	NOCOPY NUMBER	);




-- ----------------------------------------
-- API name 	: Change_DocumentStatus
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Change_DocumentStatus	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_document_id          	IN  	NUMBER,
        p_document_status    	IN  	VARCHAR2	);


-- ----------------------------------------
-- API name 	: Update_Document
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE update_Document (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_DOCUMENT_ID          	IN 	NUMBER,
	P_PSIG_XML    		IN 	CLOB DEFAULT NULL,
    	P_PSIG_DOCUMENT  	IN 	CLOB DEFAULT NULL,
        P_PSIG_DOCUMENTFORMAT  	IN 	VARCHAR2 DEFAULT NULL,
        P_PSIG_REQUESTER	IN 	VARCHAR2,
        P_PSIG_SOURCE    	IN 	VARCHAR2 DEFAULT NULL,
        P_EVENT_NAME  		IN 	VARCHAR2 DEFAULT NULL,
        P_EVENT_KEY  		IN 	VARCHAR2 DEFAULT NULL,
        p_WF_Notif_ID      	IN 	NUMBER   DEFAULT NULL	);


-- ----------------------------------------
-- API name 	: Post_DocumentParameter
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_DocumentParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_document_id          	IN  	NUMBER,
        p_doc_parameters_tbl  	IN  	EDR_EvidenceStore_PUB.Params_tbl_type   );





-- ----------------------------------------
-- API name 	: Close_Document
-- Type		: Public
-- Function	: close a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Close_Document	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_DOCUMENT_ID          	IN  	NUMBER	);


-- ----------------------------------------
-- API name 	: Cancel_Document
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Cancel_Document (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_DOCUMENT_ID          	IN  	NUMBER    );



/* this Procedure is used to requrest a signature for a given document .
   this procedure will allow a new signature row to be create in the signature table for the
   given document and user. This should have a follow up with postsignature api with more details */
-- ----------------------------------------
-- API name 	: Request_Signature
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Request_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
      P_DOCUMENT_ID         	IN 	NUMBER,
	P_USER_NAME           	IN 	VARCHAR2,
      P_ORIGINAL_RECIPIENT  	IN 	VARCHAR2 DEFAULT NULL,
      P_OVERRIDING_COMMENT 	IN 	VARCHAR2 DEFAULT NULL,
      x_signature_id         	OUT 	NOCOPY NUMBER      );


-- ----------------------------------------
-- API name 	: Post_Signature
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_DOCUMENT_ID         	IN 	NUMBER,
	p_evidenceStore_id  	IN 	VARCHAR2,
	P_USER_NAME          	IN 	VARCHAR2,
	P_USER_RESPONSE      	IN 	VARCHAR2,
        P_ORIGINAL_RECIPIENT  	IN 	VARCHAR2 DEFAULT NULL,
        P_OVERRIDING_COMMENT 	IN 	VARCHAR2 DEFAULT NULL,
        x_signature_id         	OUT 	NOCOPY NUMBER        );



-- ----------------------------------------
-- API name 	: Post_SignatureParameter
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Post_SignatureParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_signature_id         	IN  	NUMBER,
        p_sig_parameters_tbl	IN  	EDR_EvidenceStore_PUB.Params_tbl_type   );


-- ----------------------------------------
-- API name 	: Get_DocumentDetails
-- Type		: Public
-- Function	: Update a document
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------
/*#
 * This API returns e-record details such as e-record XML, parameters associated with e-records and
 * approver information based on e-record ID input.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retrieve e-record details
 */
PROCEDURE Get_DocumentDetails  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_DOCUMENT_ID          	IN  	NUMBER,
        x_document_rec      	OUT 	NOCOPY edr_psig_documents%ROWTYPE,
        x_doc_parameters_tbl 	OUT 	NOCOPY EDR_EvidenceStore_PUB.Params_tbl_type,
	x_signatures_tbl     	OUT 	NOCOPY EDR_EvidenceStore_PUB.Signature_tbl_type   );


-- Bug 4135005 : Start

-- ----------------------------------------
-- API name 	: Get_SignatureDetails
-- Type		: Public
-- Function	: Returns Signature details
-- Versions	: 1.0	28-Feb-05	created
-- ---------------------------------------
/*#
 * This API returns Siganture details such as Siganture timestamp and Signature paramaters involving signature comments etc.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retrieve Signature details
 */


 PROCEDURE GET_SignatureDetails (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_SIGNATURE_ID          IN      NUMBER DEFAULT NULL,
        X_SIGNATUREDETAILS      OUT     NOCOPY EDR_PSIG_DETAILS%ROWTYPE,
        X_SIGNATUREPARAMS       OUT     NOCOPY EDR_EvidenceStore_PUB.params_tbl_type  );


-- Bug 4135005 : End

-- ----------------------------------------
-- API name 	: Capture_Signature
-- Type		: Public
-- Function	: capture the signature for single event and generate document id + signature id
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Capture_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	p_commit		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_psig_xml		IN 	CLOB default null,
	p_psig_document		IN 	CLOB default null,
	p_psig_docFormat	IN 	VARCHAR2,
	p_psig_requester	IN 	VARCHAR2,
	p_psig_source		IN 	VARCHAR2,
	p_event_name		IN 	VARCHAR2,
	p_event_key		IN 	VARCHAR2,
	p_wf_notif_id		IN 	NUMBER,
	x_document_id		OUT	NOCOPY NUMBER,
	p_doc_parameters_tbl	IN	EDR_EvidenceStore_PUB.Params_tbl_type,
	p_user_name		IN	VARCHAR2,
	p_original_recipient	IN	VARCHAR2 default null,
	p_overriding_comment	IN	VARCHAR2 default null,
	x_signature_id		OUT	NOCOPY NUMBER,
	p_evidenceStore_id	IN	NUMBER,
	p_user_response		IN	VARCHAR2,
	p_sig_parameters_tbl	IN	EDR_EvidenceStore_PUB.Params_tbl_type );


END EDR_EvidenceStore_PUB;

 

/
