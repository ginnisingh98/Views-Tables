--------------------------------------------------------
--  DDL for Package PO_ERECORDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ERECORDS_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVEVRS.pls 115.1 2003/10/07 01:54:18 rbairraj noship $

/* -- Public Record Type Declaration */

TYPE params_rec IS RECORD (Param_Name VARCHAR2(80),
                           Param_Value VARCHAR2(4000),Param_displayname varchar2(240));

TYPE Params_tbl_type IS TABLE of PO_ERECORDS_PVT.params_rec INDEX by Binary_INTEGER;

--  Calls the APIs given by eRecords product team to store the signature details
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
	x_msg_data		     OUT	NOCOPY VARCHAR2);


-- Creates an acknowledgement for an erecord in the
-- evidence store. This acknowledgement would say whether
-- the business transaction for which the erecord was
-- created, completed successfully or not.

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
  x_msg_data		     OUT    NOCOPY	VARCHAR2);

-- If eRecords patch is applied and Erecords is enabled
-- returns 'Y' else returns 'N'

PROCEDURE ERECORDS_ENABLED
(x_erecords_enabled   OUT  NOCOPY VARCHAR2);

END PO_ERECORDS_PVT;

 

/
