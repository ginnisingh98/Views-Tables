--------------------------------------------------------
--  DDL for Package XNB_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNB_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: XNBVUTYS.pls 120.3 2006/06/25 13:38:24 pselvam noship $ */

-- Name
--   update_cln
-- Purpose
--   Private procedure that raises the CLN event to update collaboration.
-- Arguments
--   p_doc_status - Document Status for this update
--   p_app_ref_id - Application Reference ID for the collaboration
--   p_orig_ref   - Originator Reference ID
--   p_intl_ctrl_no - Internal Control Number
--   p_msg_data   - Message data.
-- Returns
--   None
-- Notes
--   None
    PROCEDURE update_cln (
			p_doc_status	IN	VARCHAR2,
			p_app_ref_id	IN	VARCHAR2,
			p_orig_ref	IN	VARCHAR2,
			p_intl_ctrl_no	IN	NUMBER,
			p_msg_data	IN	VARCHAR2
			);

-- Name
--   check_collaboration_doc_status
-- Purpose
--   Private procedure to check the status of a document publish in collaboration history
--   of Supply Chain Trading Connector (CLN).
-- Arguments
--   p_doc_no             - Document Number for the collaboration
--   p_int_txn_type       - XML Gateway Internal Transaction Type
--   p_int_txn_sub_type   - XML Gateway Internal Transaction Subtype
-- Returns
--   Collaboration Status.
--      1 - EVERY billing Application has sent ATLEAST ONE Confirm BOD with status SUCCESS for the doc.
--      2 - Atleast one of the hub users is yet to confirm success of a publish of the doc
--          OR There is no collaboration for the given document number
--     -1 - If there was an error during the check.
-- Notes
--   This procedure will be called by the TCA Account and Sales Order Publish processes
--   and will be later replaced by the procedure 'check_doc_collaboration_status'.
--   Note that the names of these procedures are very similiar.
    FUNCTION check_collaboration_doc_status (
			p_doc_no NUMBER,
			p_collab_type VARCHAR2
            ) RETURN NUMBER;

-- Name
--   check_doc_collaboration_status
-- Purpose
--   Private procedure to check the status of a document publish in collaboration history
--   of Supply Chain Trading Connector (CLN).
-- Arguments
--   p_doc_no             - Document Number for the collaboration
--   p_int_txn_type       - XML Gateway Internal Transaction Type
--   p_int_txn_sub_type   - XML Gateway Internal Transaction Subtype
-- Returns
--   Collaboration Status.
--      1 - EVERY billing Application has sent ATLEAST ONE Confirm BOD with status SUCCESS for the doc.
--      2 - Atleast one of the hub users is yet to confirm success of a publish of the doc
--          OR There is no collaboration for the given document number
--     -1 - If there was an error during the check.
-- Notes
--   This procedure will be called by the Inventory Item Update and IB Ownership Change
--   flows to check the collaboration document status.
--   This will eventually replace the procedure 'check_doc_collaboration_status'
    FUNCTION check_doc_collaboration_status (
            p_doc_no NUMBER,
            p_collab_type VARCHAR2
            ) RETURN NUMBER;

-- Name
--   check_doc_collaboration_status
-- Purpose
--   Private procedure to check the status of a document publish in collaboration history
--   of Supply Chain Trading Connector (CLN).
-- Arguments
--   p_doc_no             - Document Number for the collaboration
--   p_int_txn_type       - XML Gateway Internal Transaction Type
--   p_int_txn_sub_type   - XML Gateway Internal Transaction Subtype
--   p_tp_loc_code        - Billing Application identification code. Source Trading Partner Location Code
-- Returns
--   Collaboration Status.
--      0  - The given billing application is yet to confirm the document with SUCCESS
--      1  - The given billing application has already confirmed the document with SUCCESS
--     -1  - There was an error during the check
-- Notes
--   None
   FUNCTION check_cln_billapp_doc_status (
            p_doc_no NUMBER,
            p_collab_type VARCHAR2,
            p_tp_loc_code VARCHAR2
            ) RETURN NUMBER;


------------------------------------------------------------------------------------
/* Program to return the Flag for the qualifier 				*/
/* Account Update Functionality							*/

PROCEDURE return_qualifier
(
	p_event_name		IN VARCHAR2,
	p_event_param		IN VARCHAR2,
	p_transaction_id	IN VARCHAR2,
	x_qualifier		OUT NOCOPY VARCHAR2
);


------------------------------------------------------------------------------------
/* Program to return the ship_to_contact details of an OrderLine				*/
/* R12 : Enhanced Salesorder Functionality							*/

/* ST Bug Fix: 5165987 : Ship To Contact Point Issue
PROCEDURE return_ship_to_contact
(
	p_ship_to_contact_id		IN NUMBER,
	x_person_identifier		OUT NOCOPY VARCHAR2,
	x_person_title			OUT NOCOPY VARCHAR2,
	x_person_pre_name_adjunct	OUT NOCOPY VARCHAR2,
	x_person_first_name		OUT NOCOPY VARCHAR2,
	x_person_middle_name		OUT NOCOPY VARCHAR2,
	x_person_last_name		OUT NOCOPY VARCHAR2,
	x_person_name_suffix		OUT NOCOPY VARCHAR2,
	x_salutation			OUT NOCOPY VARCHAR2,
	x_email_address			OUT NOCOPY VARCHAR2,
	x_phone_line_type		OUT NOCOPY VARCHAR2,
	x_phone_country_code		OUT NOCOPY VARCHAR2,
	x_phone_area_code		OUT NOCOPY VARCHAR2,
	x_phone_number			OUT NOCOPY VARCHAR2

);
*/
------------------------------------------------------------------------------------
/* Program to return Address details from site_use_id				*/
/* R12 : Enhanced Salesorder Functionality							*/


PROCEDURE return_address_from_usageid
(
	    p_site_use_id 		IN  NUMBER,
	    x_address_line		OUT NOCOPY VARCHAR2,
	    x_country		        OUT NOCOPY VARCHAR2,
	    x_state		        OUT NOCOPY VARCHAR2,
	    x_county			OUT NOCOPY VARCHAR2,
	    x_city		 	OUT NOCOPY VARCHAR2,
	    x_postal_code	 	OUT NOCOPY VARCHAR2

);


END xnb_util_pvt;

 

/
