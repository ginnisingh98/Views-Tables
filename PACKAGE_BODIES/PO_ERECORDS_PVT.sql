--------------------------------------------------------
--  DDL for Package Body PO_ERECORDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ERECORDS_PVT" AS
/* $Header: POXVEVRB.pls 115.5 2003/10/15 17:57:40 rbairraj noship $  */



-------------------------------------------------------------------------------
--Start of Comments
--Name: Capture_Signature
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calls the APIs given by eRecords product team to store the signature details
--Parameters:
--IN:
--p_api_version
--  Standard parameter according to apps API standards
--p_init_msg_list
--  Indicates if the message logging should be initialised
--p_commit
--  Indicates if the eRecord details should be committed in between processing
--p_psig_xml
--  Source XML
--p_psig_document
--  Source Document
--p_psig_docFormat
--  Source Document Format
--p_psig_requester
--  eSignature requester user name
--p_psig_source
--  eSignature source platform (DB, Form, sswa)
--p_event_name
--  eSignature event name
--p_event_key
--  eSignature event key
--p_wf_notif_id
--  workflow notification id
--p_doc_parameters_tbl
--  Parameter list to be passed as post document parameters
--p_user_name
--  User name of the person signing the notifiation
--p_original_recipient
--  Original recipient of the notification
--p_overriding_comment
--  Comments of the user if it is not signed by the original recipient
--p_evidenceStore_id
--  Evidence store Id of the eRecord
--p_user_response
--  Response of the user signing the notification
--p_sig_parameters_tbl
--  Parameter list to be passed as post signature parameters
--OUT:
--x_return_status
--  Standard parameter according to apps API standards
--x_msg_count
--  Standard parameter according to apps API standards
--x_msg_data
--  Standard parameter according to apps API standards
--x_document_id
--  Generated document id
--x_signature_id
--  Captured signature id
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE CAPTURE_SIGNATURE  (
	p_api_version		 IN 	NUMBER,
	p_init_msg_list		 IN 	VARCHAR2,
	p_commit		     IN 	VARCHAR2,
	p_psig_xml		     IN 	CLOB,
	p_psig_document		 IN 	CLOB,
	p_psig_docFormat	 IN 	VARCHAR2,
	p_psig_requester	 IN 	VARCHAR2,
	p_psig_source		 IN 	VARCHAR2,
	p_event_name		 IN 	VARCHAR2,
	p_event_key		     IN 	VARCHAR2,
	p_wf_notif_id		 IN 	NUMBER,
	p_doc_parameters_tbl IN	    Params_tbl_type,
	p_user_name		     IN	    VARCHAR2,
	p_original_recipient IN	    VARCHAR2,
	p_overriding_comment IN	    VARCHAR2,
	p_evidenceStore_id	 IN	    NUMBER,
	p_user_response		 IN	    VARCHAR2,
	p_sig_parameters_tbl IN	    Params_tbl_type,
	x_document_id		 OUT	NOCOPY NUMBER,
	x_signature_id		 OUT	NOCOPY NUMBER,
	x_return_status		 OUT    NOCOPY VARCHAR2,
	x_msg_count		     OUT	NOCOPY NUMBER,
	x_msg_data		     OUT	NOCOPY VARCHAR2)
IS
    l_edr_doc_params_tab        EDR_EVIDENCESTORE_PUB.params_tbl_type;
    l_edr_sig_params_tab        EDR_EVIDENCESTORE_PUB.params_tbl_type;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_document_id               NUMBER;
    l_signature_id              NUMBER;
BEGIN

    FOR i IN p_doc_parameters_tbl.FIRST..p_doc_parameters_tbl.LAST LOOP
    	l_edr_doc_params_tab(i).param_name := p_doc_parameters_tbl(i).param_name;
    	l_edr_doc_params_tab(i).param_value := p_doc_parameters_tbl(i).param_value;
    	l_edr_doc_params_tab(i).param_displayname := p_doc_parameters_tbl(i).param_displayname;
    END LOOP;

    FOR i IN p_sig_parameters_tbl.FIRST..p_sig_parameters_tbl.LAST LOOP
    	l_edr_sig_params_tab(i).param_name := p_sig_parameters_tbl(i).param_name;
    	l_edr_sig_params_tab(i).param_value := p_sig_parameters_tbl(i).param_value;
    	l_edr_sig_params_tab(i).param_displayname := p_sig_parameters_tbl(i).param_displayname;
    END LOOP;

    EDR_EVIDENCESTORE_PUB.Capture_Signature (
 	        p_api_version		 => p_api_version,
	        p_init_msg_list		 => p_init_msg_list,
	        p_commit		     => p_commit,
	        x_return_status		 => l_return_status,
	        x_msg_count		     => l_msg_count,
	        x_msg_data		     => l_msg_data,
	        p_psig_xml		     => p_psig_xml,
	        p_psig_document		 => p_psig_document,
	        p_psig_docFormat	 => p_psig_docFormat,
	        p_psig_requester	 => p_psig_requester,
	        p_psig_source		 => p_psig_source,
	        p_event_name		 => p_event_name,
	        p_event_key		     => p_event_key,
	        p_wf_notif_id		 => p_wf_notif_id,
	        x_document_id		 => l_document_id,
	        p_doc_parameters_tbl => l_edr_doc_params_tab,
	        p_user_name		     => p_user_name,
	        p_original_recipient => p_original_recipient,
	        p_overriding_comment => p_overriding_comment,
	        x_signature_id		 => l_signature_id,
	        p_evidenceStore_id	 => p_evidenceStore_id,
	        p_user_response		 => p_user_response,
	        p_sig_parameters_tbl => l_edr_sig_params_tab);

    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
    x_document_id   := l_document_id;
    x_signature_id  := l_signature_id;

END CAPTURE_SIGNATURE;

-------------------------------------------------------------------------------
--Start of Comments
--Name: Send_Ackn
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calls the APIs given by eRecords product team to Record
--  Transaction Acknowledgement
--Parameters:
--IN:
--p_api_version
--  Standard parameter according to apps API standards
--p_init_msg_list
--  Indicates if the message logging should be initialised
--p_event_name
--  The event name for which acknowledgement is sent
--p_event_key
--  The event key for which acknowledgement is sent
--p_erecord_id
--  he erecord id for which ackn is being sent
--p_trans_status
--  The status of the transaction for which ack is being created.
--  There is a limited set of possible values: SUCCESS, ERROR
--p_ackn_by
--  The source of the acknowledgement
--p_ackn_note
--  Additional information/comments about the ackn
--p_autonomous_commit
--  This tells the API to commit its changes autonomously or not
--OUT:
--x_return_status
--  Standard parameter according to apps API standards
--x_msg_count
--  Standard parameter according to apps API standards
--x_msg_data
--  Standard parameter according to apps API standards
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE SEND_ACKN
( p_api_version          IN     NUMBER,
  p_init_msg_list	     IN		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_event_name           IN    	VARCHAR2,
  p_event_key            IN    	VARCHAR2,
  p_erecord_id	         IN	    NUMBER,
  p_trans_status	     IN	    VARCHAR2,
  p_ackn_by              IN     VARCHAR2 DEFAULT NULL,
  p_ackn_note	         IN		VARCHAR2 DEFAULT NULL,
  p_autonomous_commit	 IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status	     OUT    NOCOPY	VARCHAR2,
  x_msg_count		     OUT    NOCOPY NUMBER,
  x_msg_data		     OUT    NOCOPY	VARCHAR2)
IS
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
BEGIN
    EDR_TRANS_ACKN_PUB.send_ackn
          ( p_api_version        => p_api_version,
            p_init_msg_list	     => p_init_msg_list,
            x_return_status	     => l_return_status,
            x_msg_count		     => l_msg_count,
            x_msg_data		     => l_msg_data,
            p_event_name         => p_event_name,
            p_event_key          => p_event_key,
            p_erecord_id	     => p_erecord_id,
            p_trans_status	     => p_trans_status,
            p_ackn_by            => p_ackn_by,
            p_ackn_note	         => p_ackn_note,
            p_autonomous_commit	 => p_autonomous_commit);

    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;

END SEND_ACKN;

-------------------------------------------------------------------------------
--Start of Comments
--Name: ERECORDS_ENABLED
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  If eRecords patch is applied and eRecords is enabled returns 'Y'
--  else returns 'N'
--Parameters:
--OUT:
--x_erecords_enabled
--  Returns 'Y' if eRecords patch is applied and eRecords is enabled.
--  Otherwise returns 'N'.
--Testing:
--  Testing to be done based on the test cases in Document Binding DLD
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE ERECORDS_ENABLED
( x_erecords_enabled   OUT  NOCOPY VARCHAR2)
IS
  l_eres_enabled VARCHAR2(1) := 'N';
BEGIN

    l_eres_enabled := NVL(FND_PROFILE.VALUE('EDR_ERES_ENABLED'),'N');
    IF l_eres_enabled = 'Y' THEN
        x_erecords_enabled := 'Y';
    ELSE
        x_erecords_enabled := 'N';
    END IF;

END ERECORDS_ENABLED;

END PO_ERECORDS_PVT;


/
