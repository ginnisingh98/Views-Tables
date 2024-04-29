--------------------------------------------------------
--  DDL for Package Body XNB_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNB_UTIL_PVT" AS
/* $Header: XNBVUTYB.pls 120.6 2006/06/25 13:39:46 pselvam noship $ */


 PROCEDURE update_cln
    (
	    p_doc_status VARCHAR2,
    	p_app_ref_id VARCHAR2,
    	p_orig_ref VARCHAR2,
    	p_intl_ctrl_no NUMBER,
    	p_msg_data VARCHAR2
    )
    AS

    	l_key VARCHAR2(250);
    	l_parameter_list WF_PARAMETER_LIST_T := WF_PARAMETER_LIST_T();
    	l_doc_status VARCHAR2(20);
    	l_msg_txt  VARCHAR2(250);

    BEGIN

        ---------------------------------------------------------------------------------------
        -- Assigns the Lookup values for the Document Status returned	in the CBOD map
        --
        -----------------------------------------------------------------------------------------

	    IF p_doc_status = '00' THEN
		    l_doc_status := 'SUCCESS';
		    l_msg_txt := 'XNB_CLN_MSG_ACCEPTED';
	    ELSE
		    l_doc_status := 'ERROR';
		    l_msg_txt := 'XNB_CLN_MSG_REJECTED';
	    END IF;

        -----------------------------------------------------------------------------------------
        --Assign the values for the collaboration parameters and raise the event
        --
        -----------------------------------------------------------------------------------------

	    wf_event.addparametertolist (
					p_name =>'DOCUMENT_STATUS',
					p_value => l_doc_status,
					p_parameterlist => l_parameter_list
				    );

	    wf_event.addparametertolist (
					p_name =>'MESSAGE_TEXT',
					p_value =>l_msg_txt,
					p_parameterlist => l_parameter_list
				     );

	    wf_event.addparametertolist (
					p_name =>'REFERENCE_ID',
					p_value => p_app_ref_id,
					p_parameterlist => l_parameter_list
				    );

	    wf_event.addparametertolist (
					p_name =>'ORIGINATOR_REFERENCE',
					p_value => p_orig_ref,
					p_parameterlist => l_parameter_list
				    );

        wf_event.addparametertolist (
					p_name =>'XMLG_INTERNAL_CONTROL_NUMBER',
					p_value =>p_intl_ctrl_no,
					p_parameterlist => l_parameter_list
				    );

        wf_event.addparametertolist (
					p_name =>'MSG_DATA',
					p_value =>p_msg_data,
					p_parameterlist => l_parameter_list
				     );


	    -----------------------------------------------------------------------------------------
	    -- Generate the key value and raise the event to update the collaboration
	    --
	    -----------------------------------------------------------------------------------------

        l_key := 'XNB'||'COLL_UPDATE'|| p_orig_ref||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS');
	    wf_event.raise (
			  p_event_name => 'oracle.apps.cln.ch.collaboration.update',
			  p_event_key => l_key,
			  p_parameters => l_parameter_list
		       );
    --End of the Function
    END update_cln;

    /***** Private API which checks whether collaboration exists for the given document */
    /*     number and a given trading partner					                        */

    Function check_collaboration_doc_status (
                                                p_doc_no NUMBER,
                                                p_collab_type VARCHAR2
                                             )
                                                RETURN NUMBER
    AS

	-----------------------------------------------------------------------------------------
	-- Cursor to retrieve the trading partner codes
	--
	 -----------------------------------------------------------------------------------------
	cursor l_tp_codes is
	SELECT	SOURCE_TP_LOCATION_CODE
	FROM	ECX_TP_DETAILS_V
	WHERE	TRANSACTION_TYPE = 'XNB' AND TRANSACTION_SUBTYPE = 'CBODI';

	l_tp_code ecx_tp_details.source_tp_location_code%TYPE;
	l_num NUMBER;

	begin

	open l_tp_codes;
	fetch l_tp_codes into l_tp_code ;

	while (l_tp_codes%FOUND) LOOP

	   select		COUNT(clndtl.collaboration_dtl_id)
	   into         l_num
	   from		    cln_coll_hist_hdr clnhdr,
			        cln_coll_hist_dtl clndtl
	   where
			clnhdr.application_id = 881
			and  clnhdr.collaboration_type = p_collab_type
			and clnhdr.document_no = p_doc_no
			and clnhdr.collaboration_id = clndtl.collaboration_id
			and clndtl.collaboration_document_type = 'CONFIRM_BOD'
			and clndtl.originator_reference = l_tp_code
			and clndtl.document_status = 'SUCCESS';

	   If (l_num = 0) then
	       RETURN 2;
	   end if;

	   fetch l_tp_codes into l_tp_code;
	END LOOP;

	return 1;

	EXCEPTION

	    WHEN NO_DATA_FOUND THEN
		RETURN 2;

	    WHEN OTHERS THEN
	        RETURN -1;

    END check_collaboration_doc_status;



    /* Function: Check Document Collaboration Status */
    FUNCTION check_doc_collaboration_status (
                                                p_doc_no NUMBER,
                                                p_collab_type VARCHAR2
                                             )
                                                RETURN NUMBER
    /*----------------------------------------------------------------------------------------------**
    Note: This procedure will be used by the Item Batch Export Conc Pgm and the IB Ownership Change **
            publish. In turn calls check_cln_billapp_doc_status to complete the logic of cln check. **
    /*----------------------------------------------------------------------------------------------**
    This procedure checks the confirmation status of a given document (Sales Order, Account etc)    **
        in the respective collaborations, as confirmed by ALL billing applications (XMLG Source TPs)**
        A document is identified by the XMLG Internal and External Txn types and the Doc Number     **
        A Document publish status is assumed successful if EVERY Hub user set in XMLG setup has sent**
            ATLEAST ONE ConfirmBOD with status SUCCESS for the doc                                  **
        Arguments:  p_doc_no - Document Number                                                      **
                    p_int_txn_type - XMLG Internal Transaction Type for the document publish        **
                    p_int_txn_sub_type - XMLG Internal Transaction Subtype for the document publish **
        Returns :   Number, with value                                                              **
            1  - if EVERY XMLG TP has sent ATLEAST ONE Confirm BOD with status SUCCESS for the doc  **
            2  - if atleast one of the TPs is yet to confirm success of a publish of the doc        **
                 OR if there is no collaboration for the given document number                      **
           -1  - If there was an error during the check.                                            **
     -----------------------------------------------------------------------------------------------*/
    AS

        CURSOR  l_tp_codes IS
	SELECT		SOURCE_TP_LOCATION_CODE
	FROM		ECX_TP_DETAILS_V
	WHERE		TRANSACTION_TYPE = 'XNB' AND TRANSACTION_SUBTYPE = 'CBODI';

	l_tp_code ecx_tp_details.source_tp_location_code%TYPE;
        l_success_stat NUMBER;      --Success status from each trading partner
	BEGIN

        ---------------------------------------------------------------
	    -- Retrieve all hub users from the XMLG Hub User setup for XNB,
        -- excluding the hub user representing XNB.
	    ---------------------------------------------------------------
	    OPEN    l_tp_codes;
	    FETCH   l_tp_codes INTO l_tp_code ;

	    WHILE (l_tp_codes%FOUND) LOOP
            l_success_stat := check_cln_billapp_doc_status(
                            p_doc_no => p_doc_no,
                            p_collab_type => p_collab_type,
                            p_tp_loc_code => l_tp_code
                            );

	        IF (l_success_stat = 0) THEN    -- This hub user is yet to confirm success
	            RETURN 2;                   -- Exit with return status 2.
            ELSIF ( l_success_stat = -1 ) THEN
                RETURN -1;                  -- There was an error during the check
	        END IF;

	        FETCH l_tp_codes INTO l_tp_code;
	    END LOOP;

	    RETURN 1;   --All billing applications have confirmed success for the doc.
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
            RETURN 2;   -- This status should ideally be an error.
                        -- There are no hub users setup on the XML Gateway.
                        -- An application error message should be thrown here.
	    WHEN OTHERS THEN
	        RETURN -1;
        --End of procedure.
    END check_doc_collaboration_status;


    /* Function: Check Collaboration for Billing Application Document Status*/
    FUNCTION check_cln_billapp_doc_status (
                                                p_doc_no NUMBER,
                                                p_collab_type VARCHAR2,
                                                p_tp_loc_code VARCHAR2
                                             )
                                             RETURN NUMBER
    /*----------------------------------------------------------------------------------------------**
    This procedure checks the confirmation status of a given document (Sales Order, Account etc)    **
        in the respective collaborations, as confirmed by a given billing application.              **
        A Billing Application is identified by the Source Trading Partner Location code set for the **
            for the inbound transaction in XML Gateway.                                             **
        A document is identified by the XMLG Internal and External Txn types and the Doc Number     **
        A Document publish status is assumed successful if EVERY Hub user set in XMLG setup has sent**
            ATLEAST ONE ConfirmBOD with status SUCCESS for the doc                                  **
        Arguments:  p_doc_no - Document Number                                                      **
                    p_int_txn_type - XMLG Internal Transaction Type for the document publish        **
                    p_int_txn_sub_type - XMLG Internal Transaction Subtype for the document publish **
                    p_tp_loc_code - TP Location Code representing the given billing application     **
        Returns :   Number, with value                                                              **
          0  - If the given billing application is yet to confirm the document with SUCCESS         **
          1  - If the given billing application has already confirmed the document with SUCCESS     **
          -1 - If there was an error during the check                                               **
     -----------------------------------------------------------------------------------------------*/
    AS
         l_num  NUMBER;
         l_ret_stat NUMBER ;     --return status.
    BEGIN

        l_ret_stat := -1;

        --Check the number of Successful ConfirmBODs sent by the given billing app.
        SELECT	COUNT(clndtl.collaboration_dtl_id)
	        INTO    l_num
	        FROM	cln_coll_hist_hdr clnhdr,
		        cln_coll_hist_dtl clndtl
	        WHERE
		        clnhdr.application_id  = 881
		    AND     clnhdr.collaboration_type = p_collab_type
			AND     clnhdr.document_no = p_doc_no
			AND     clnhdr.collaboration_id = clndtl.collaboration_id
			AND     clndtl.collaboration_document_type = 'CONFIRM_BOD'
			AND     clndtl.originator_reference = p_tp_loc_code
			AND     clndtl.document_status = 'SUCCESS';

        IF (l_num = 0) THEN
            l_ret_stat := 0;    --Zero Success ConfirmBODs
        ELSE
            l_ret_stat := 1;    --There was atleast one Success ConfirmBOD received
        END IF;

        RETURN l_ret_stat;
    EXCEPTION
        WHEN OTHERS THEN       --There was an error. Return -1.
            RETURN l_ret_stat;
        --End of procedure
    END check_cln_billapp_doc_status;


------------------------------------------------------------------------------------
/* Program to return the Flag for the qualifier 				*/
/* Account Update Functionality							*/


    PROCEDURE return_qualifier
(
	p_event_name		IN VARCHAR2,
	p_event_param		IN VARCHAR2,
	p_transaction_id	IN VARCHAR2,
	x_qualifier		OUT NOCOPY VARCHAR2
)
AS
BEGIN
/*C547_XNB - Obsolete Billing Preference information*/
/*
	IF p_event_name = 'oracle.apps.ar.hz.BillingPreference.create' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'I';
		return;

	ELSIF  p_event_name = 'oracle.apps.ar.hz.BillingPreference.update' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'U';
		xnb_debug.log('return_qualifier','Flag'||x_qualifier||'Value');
		return;
*/
	IF  p_event_name = 'oracle.apps.ar.hz.CustAcctRelate.create' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'I';
		return;

	ELSIF  p_event_name = 'oracle.apps.ar.hz.CustAcctRelate.update' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'U';
		return;

	ELSIF p_event_name = 'oracle.apps.ar.hz.ContactPoint.update' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'U';
		return;

	ELSIF p_event_name = 'oracle.apps.ar.hz.CustomerProfile.update' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'U';
		return;

	ELSIF  p_event_name = 'oracle.apps.ar.hz.CustProfileAmt.create' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'I';
		return;

	ELSIF  p_event_name = 'oracle.apps.ar.hz.CustProfileAmt.update' AND p_event_param = p_transaction_id THEN
		x_qualifier := 'U';
		return;

	END IF;

	return;

END return_qualifier;

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
)
AS

BEGIN
	SELECT
			      C.person_identifier,
			      C.person_title,
			      C.person_pre_name_adjunct,
			      C.person_first_name,
			      C.person_middle_name,
			      C.person_last_name,
			      C.person_name_suffix,
			      C.salutation,
			      D.email_address,
			      D.phone_line_type,
			      D.phone_country_code,
			      D.phone_area_code,
			      D.phone_number
	INTO
			      x_person_identifier,
			      x_person_title,
			      x_person_pre_name_adjunct,
			      x_person_first_name,
			      x_person_middle_name,
			      x_person_last_name,
			      x_person_name_suffix,
			      x_salutation,
			      x_email_address,
			      x_phone_line_type,
			      x_phone_country_code,
			      x_phone_area_code,
			      x_phone_number
	FROM
			      hz_cust_account_roles A,
			      hz_relationships B,
			      hz_parties C,
			      hz_contact_points D
	WHERE
			      A.cust_account_role_id = p_ship_to_contact_id
			      and A.party_id = B.party_id
			      and B.directional_flag = 'F'
			      and B.subject_id = C.party_id
			      and B.party_id = D.owner_table_id(+)
			      and D.owner_table_name(+) = 'HZ_PARTIES';

	RETURN;

	EXCEPTION
	    WHEN OTHERS THEN
	    RETURN;


END return_ship_to_contact;
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

)
AS

BEGIN
	SELECT 		locations.address1||DECODE(locations.address2
			    , NULL
			    , NULL
			    , ';'||locations.address2|| DECODE(locations.address3
			    , NULL
			    , NULL
			    , ';'||locations.address3|| DECODE(locations.address4
			    , NULL
			    , NULL
			    , ';'||locations.address4))) address_line,
			locations.country,
          		locations.state,
			locations.county,
		        locations.city,
		        locations.postal_code
	   INTO
			x_address_line,
			x_country,
			x_state,
			x_county,
			x_city,
			x_postal_code

	    FROM
		    hz_cust_site_uses_all site_uses,
		    hz_cust_acct_sites_all acct_sites,
		    hz_party_sites party_sites,
		    hz_locations locations
	    WHERE
		    site_uses.site_use_id = p_site_use_id
		    and acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id
		    and acct_sites.party_site_id = party_sites.party_site_id
		    and party_sites.location_id = locations.location_id;


	RETURN;

	EXCEPTION
	    WHEN OTHERS THEN
	    RETURN;

END return_address_from_usageid;


    --End of the Package
END xnb_util_pvt;

/
