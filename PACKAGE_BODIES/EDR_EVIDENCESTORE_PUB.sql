--------------------------------------------------------
--  DDL for Package Body EDR_EVIDENCESTORE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_EVIDENCESTORE_PUB" AS
/* $Header: EDRPEVRB.pls 120.0.12000000.1 2007/01/18 05:54:25 appldev ship $  */

-- Global variables
G_PKG_NAME CONSTANT varchar2(100) := 'EDR_EvidenceStore_PUB';


-- --------------------------------------
-- IN Parameters common to all APIs
--	p_api_version	NUMBER		version num param compared with local version num
--	x_return_status	VARCHAR2	return status indicates the final state of API
--	x_msg_count	NUMBER		message count
--	x_msg_data	VARCHAR2	message stack
-- ----------------------------------------
-- API name 	: Open_Document
-- Type		: Public
-- Pre-reqs	: None
-- Function	: create a document instance for signature
--		: and can associate signatures before closing the docuemnt
-- Parameters
-- IN	: p_psig_xml		CLOB 		[null] source xml
--	: p_psig_document	CLOB 		[null] source document
--	: p_psig_documentFormat	VARCHAR2	[null] source document format
--	: p_psig_requester	VARCHAR2	eSig requester user name
--	: p_psig_source		VARCHAR2 	[null] eSig source platform (DB, Form, sswa)
--	: p_event_name		VARCHAR2 	[null] eSig event name
--	: p_event_key		VARCHAR2 	[null] eSig event key
--	: p_wf_notif_id		NUMBER 		[null] workflow notification id
-- OUT	: x_document_id		NUMBER		opened document id
-- Versions	: 1.0	17-Jul-03	created from edr_psig.openDocument
-- ---------------------------------------

PROCEDURE Open_Document	(
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_psig_xml    		IN 	CLOB,
       	p_psig_document  	IN 	CLOB,
        p_psig_documentFormat  	IN 	VARCHAR2,
        p_psig_REQUESTER	IN 	VARCHAR2,
        p_psig_SOURCE    	IN 	VARCHAR2,
        P_EVENT_NAME  		IN 	VARCHAR2,
        P_EVENT_KEY  		IN 	VARCHAR2,
        p_wf_notif_id           IN 	NUMBER,
        x_document_id          	OUT 	NOCOPY NUMBER )
IS
	l_api_version CONSTANT NUMBER := 1.0;
	l_api_name CONSTANT VARCHAR2(50) := 'Open_Document';
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
BEGIN
    -- Standard call to check for call compatibility
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    	edr_psig.openDocument( 	P_PSIG_XML 		=> p_psig_xml,
				P_PSIG_DOCUMENT		=> p_psig_document,
         			P_PSIG_DOCUMENTFORMAT	=> p_psig_documentFormat,
         			P_PSIG_REQUESTER	=> p_psig_REQUESTER,
         			P_PSIG_SOURCE 		=> p_psig_SOURCE,
         			P_EVENT_NAME 		=> P_EVENT_NAME,
         			P_EVENT_KEY  		=> P_EVENT_KEY,
         			p_WF_NID     		=> p_wf_notif_id,
         			P_DOCUMENT_ID  		=> x_document_id,
         			P_ERROR        		=> l_error_code,
         			P_ERROR_MSG  		=> l_error_mesg );
       IF l_error_code > 0  THEN		-- l_error_code = 21000 refers to TIMEZONE
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
       END IF;
    -- fetch the message off the dictionary stack and add to API message list
    -- would only add the last one message in the above api call
    -- need to do this in the above api after each fnd_message.set_name/set_token
    FND_MSG_PUB.Add;

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    -- Standard call to get message count, and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Open_Document;


-- --------------------------------------
-- API name 	: Change_Document_Status
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Manually change the status of a document
-- Parameters
-- IN	:	p_document_id   NUMBER		the document id
--		p_status	VARCHAR2	new document status
-- Versions	: 1.0	17-Jul-03	created from edr_psig.ChangeDocumentStatus
-- ---------------------------------------

PROCEDURE Change_DocumentStatus  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_document_id          	IN  	NUMBER,
        p_document_status  	IN 	VARCHAR2  )
IS
	l_count		NUMBER;
	l_api_name CONSTANT VARCHAR2(50) := 'Change_DocumentStatus';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    	edr_psig.changeDocumentStatus(
				P_DOCUMENT_ID  	=> p_document_id,
				p_status	=> p_document_status,
         			P_ERROR        	=> l_error_code,
         			P_ERROR_MSG  	=> l_error_mesg );

	   IF l_error_code > 0  THEN		-- l_error_code = 21001 document closed or not exist
	   	fnd_message.Set_Name('EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
            raise fnd_api.G_EXC_ERROR;
	   END IF;

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Change_DocumentStatus;


-- --------------------------------------
-- API name 	: Update_Document
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Update a document for its xml/docu/requester etc
-- Parameters
-- IN	: DOCUMENT_ID		NUMBER		id of the document to update
--	: PSIG_XML       	CLOB		the xml to set
--	: PSIG_DOCUMENT  	CLOB		the document to set
--	: PSIG_DOCUMENTFORMAT	VARCHAR2	the document parameter format
--	: PSIG_REQUESTER	VARCHAR2	the requester for the update
--	: PSIG_SOURCE    	VARCHAR2	[null] the source of the update (DB, FORM, SSWA)
--	: EVENT_NAME  		VARCHAR2	[null] the event name to update
--	: EVENT_KEY 		VARCHAR2	[null] the event key to update
--	: p_wf_notif_id		NUMBER		[null] the workflow notifcation id
-- Versions	: 1.0	17-Jul-03	created from edr_psig.UpdateDocument
-- ---------------------------------------

PROCEDURE Update_Document  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_DOCUMENT_ID           IN 	NUMBER,
 	P_PSIG_XML    		IN 	CLOB DEFAULT NULL,
       	P_PSIG_DOCUMENT  	IN 	CLOB DEFAULT NULL,
        P_PSIG_DOCUMENTFORMAT   IN 	VARCHAR2 DEFAULT NULL,
        P_PSIG_REQUESTER	IN 	VARCHAR2,
        P_PSIG_SOURCE    	IN 	VARCHAR2 DEFAULT NULL,
        P_EVENT_NAME  		IN 	VARCHAR2 DEFAULT NULL,
        P_EVENT_KEY  		IN 	VARCHAR2 DEFAULT NULL,
        p_wf_notif_ID           IN 	NUMBER   DEFAULT NULL  )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Update_Document';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    	edr_psig.updateDocument( P_DOCUMENT_ID  	=> p_document_id,
         			P_PSIG_XML 		=> p_psig_xml,
				P_PSIG_DOCUMENT		=> p_psig_document,
         			P_PSIG_DOCUMENTFORMAT	=> p_psig_documentFormat,
         			P_PSIG_REQUESTER	=> p_psig_REQUESTER,
         			P_PSIG_SOURCE 		=> p_psig_SOURCE,
         			P_EVENT_NAME 		=> P_EVENT_NAME,
         			P_EVENT_KEY  		=> P_EVENT_KEY,
         			p_WF_NID     		=> p_wf_notif_id,
         			P_ERROR        		=> l_error_code,
         			P_ERROR_MSG  		=> l_error_mesg );
	   IF l_error_code > 0  THEN		-- l_error_code = 21001 document closed or not exist
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
   	   END IF;
    FND_MSG_PUB.Add;

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Update_Document;


-- --------------------------------------
-- API name 	: Post_DocumentParameters
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Make a copy of eSignature notification
-- Parameters
-- IN	:	p_document_id   	NUMBER		source document id
--		p_parameters_tbl	params_table	a table of parameters to delete
-- Versions	: 1.0	17-Jul-03	created from edr_psig.PostDocumentParameters
-- ---------------------------------------

PROCEDURE Post_DocumentParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
   	p_document_id       	IN  	NUMBER,
  	p_doc_parameters_tbl  	IN  	EDR_EvidenceStore_PUB.Params_tbl_type    )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Post_DocumentParameters';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
	l_params_tbl	edr_psig.params_table;
	lth	NUMBER;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	FOR lth in 1..p_doc_parameters_tbl.COUNT  LOOP
	  l_params_tbl(lth) := p_doc_parameters_tbl(lth);
	END LOOP;
    	edr_psig.postDocumentParameter(
			P_DOCUMENT_ID  		=> p_document_id,
			P_PARAMETERS		=> l_params_tbl,
         		P_ERROR        		=> l_error_code,
         		P_ERROR_MSG  		=> l_error_mesg );
	   IF l_error_code > 0  THEN		-- l_error_code = 21001 document closed or not exist
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
   	   END IF;
    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Post_DocumentParameters;


-- --------------------------------------

-- --------------------------------------
-- API name 	: Close_Document
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Close a document
-- Parameters
-- IN	:	p_document_id   NUMBER		source document id
-- Versions	: 1.0	17-Jul-03	created from edr_psig.CloseDocument
-- ---------------------------------------

PROCEDURE Close_Document  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_document_id          	IN  	NUMBER )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Close_Document';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
        l_mesg_text  varchar2(4000);
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    	edr_psig.closeDocument( P_DOCUMENT_ID  		=> p_document_id,
         			P_ERROR        		=> l_error_code,
         			P_ERROR_MSG  		=> l_error_mesg );
         IF l_error_code > 0  THEN
                fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
	 END IF;

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Close_Document;


-- --------------------------------------
-- API name 	: Cancel_Document
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Make a copy of eSignature notification
-- Parameters
-- IN	:	p_document_id   NUMBER	source document id
-- Versions	: 1.0	17-Jul-03	created from edr_psig.cancelDocument
-- ---------------------------------------

PROCEDURE Cancel_Document  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_document_id          	IN  	NUMBER )

IS
	l_api_name CONSTANT VARCHAR2(50) := 'Cancel_Document';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    	edr_psig.cancelDocument( P_DOCUMENT_ID  	=> p_document_id,
         			P_ERROR        		=> l_error_code,
         			P_ERROR_MSG  		=> l_error_mesg );

	   IF l_error_code > 0  THEN		-- l_error_code = 21001 document closed or not exist
               	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
	   END IF;

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Cancel_Document;


-- --------------------------------------
-- API name 	: Request_Signature
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Request the signature with detail information
-- Parameters
-- IN	: P_DOCUMENT_ID		NUMBER		source document id
--	: P_USER_NAME		VARCHAR2	request user name
--	: P_original_recipient	VARCHAR2	[null] original recipient of notification if transferred
--	: P_overriding_comment	varchar2	[null] user overriding comment if it's transferred
-- OUT	: x_signature_id	NUMBER		generated signature id
-- Versions	: 1.0	17-Jul-03	created from edr_psig.RequestSignature
-- ---------------------------------------

PROCEDURE Request_Signature   (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
      p_document_id        	IN 	NUMBER,
	p_user_name         	IN 	VARCHAR2,
      p_original_recipient  	IN 	VARCHAR2,
      p_overriding_comment 	IN 	VARCHAR2,
	x_signature_id         	OUT 	NOCOPY NUMBER  )

IS
	l_api_name CONSTANT VARCHAR2(50) := 'Request_Signature';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    	edr_psig.requestSignature( P_DOCUMENT_ID  	   => p_document_id,
         			         P_USER_NAME  		   => p_user_name,
         			         P_ORIGINAL_RECIPIENT    => p_original_recipient,
         			         P_OVERRIDING_COMMENTS   => p_overriding_comment,
         			         P_SIGNATURE_ID  	   => x_signature_id,
         			         P_ERROR        	   => l_error_code,
         			         P_ERROR_MSG  		   => l_error_mesg );

	    IF l_error_code > 0  THEN
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
	    END IF;


    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
	x_return_status := FND_API.G_RET_STS_ERROR ;
      --FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Request_Signature;


-- --------------------------------------
-- API name 	: Post_Signature
-- Type		: Public
-- Pre-reqs	: None
-- Function	:
-- Parameters
-- IN	: P_DOCUMENT_ID		NUMBER		source document id
--	: P_EVIDENCESTORE_ID	NUMBER 		source evidence store id
--	: P_USER_NAME          	VARCHAR2	posting user name
--	: P_USER_RESPONSE     	VARCHAR2	user response/comment
--	: P_ORIGINAL_RECIPIENT 	VARCHAR2	[null] original recipient of notification if transferred
--	: P_OVERRIDING_COMMENT	VARCHAR2	[null] user overriding comment if it's transferred notif
-- OUT	: P_SIGNATURE_ID  	NUMBER		generated signature id
-- Versions	: 1.0	17-Jul-03	created from edr_psig.PostSignature
-- ---------------------------------------

PROCEDURE Post_Signature     (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        p_document_id         	IN 	NUMBER,
	p_evidenceStore_id  	IN 	VARCHAR2,
        p_user_name          	IN 	VARCHAR2,
   	p_user_response     	IN 	VARCHAR2,
        p_original_recipient 	IN 	VARCHAR2,
        p_overriding_comment	IN 	VARCHAR2,
	x_signature_id         	OUT 	NOCOPY NUMBER  )

IS
	l_api_name CONSTANT VARCHAR2(50) := 'Post_Signature';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    	edr_psig.postSignature( P_DOCUMENT_ID  		=> p_document_id,
         			P_EVIDENCE_STORE_ID  	=> p_evidenceStore_id,
         			P_USER_NAME  		=> p_user_name,
         			P_USER_RESPONSE  	=> p_user_response,
         			P_ORIGINAL_RECIPIENT  	=> p_original_recipient,
         			P_OVERRIDING_COMMENTS  	=> p_overriding_comment,
         			P_SIGNATURE_ID  	=> x_signature_id,
         			P_ERROR        		=> l_error_code,
         			P_ERROR_MSG  		=> l_error_mesg );

	   IF l_error_code > 0  THEN
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
   	   END IF;

    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Post_Signature;


-- --------------------------------------
-- API name 	: Post_SignatureParameters
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Make a copy of eSignature notification
-- Parameters
-- IN	:	p_signature_id   	NUMBER		source signature id
--		p_parameters_tbl	params_table	the parameters to post as a table
-- Versions	: 1.0	17-Jul-03	created from edr_psig.PostSignatureParameters
-- ---------------------------------------

PROCEDURE Post_SignatureParameters  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
      	p_signature_id         	IN  	NUMBER,
     	p_sig_parameters_tbl  	IN  	EDR_EvidenceStore_PUB.Params_tbl_type    )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Post_SignatureParameters';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
	l_params_tbl	edr_psig.Params_Table;
	lth	NUMBER;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


	FOR lth in 1..p_sig_parameters_tbl.COUNT  LOOP
	  l_params_tbl(lth) := p_sig_parameters_tbl(lth);
	END LOOP;
    	edr_psig.postSignatureParameter (
			P_SIGNATURE_ID  	=> p_signature_id,
         		P_PARAMETERS  		=> l_params_tbl,
         		P_ERROR        		=> l_error_code,
         		P_ERROR_MSG  		=> l_error_mesg );

	   IF l_error_code > 0  THEN		-- l_error_code = 21001 document closed or not exist
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
   	   END IF;
    IF  FND_API.To_Boolean( p_commit )  THEN
	COMMIT WORK;
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Post_SignatureParameters;



-- --------------------------------------
-- API name 	: Get_DocumentDetails
-- Type		: Public
-- Pre-reqs	: None
-- Function	: Make a copy of eSignature notification
-- Parameters
-- IN	:	p_document_id 		NUMBER		source document id
-- OUT	:	x_document_rec		Document_rec	document details as a record
--		x_document_params_tbl	params_table	document parameters as a table
--		x_signatures_tbl	Signature_tbl	all signatures as a table on this document
-- Versions	: 1.0	17-Jul-03	created from edr_psig.GetDocumentDetails
-- ---------------------------------------

PROCEDURE Get_DocumentDetails  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
     	p_document_id          	IN  	NUMBER,
     	x_document_rec      	OUT 	NOCOPY edr_psig_documents%ROWTYPE,
        x_doc_parameters_tbl 	OUT 	NOCOPY EDR_EvidenceStore_PUB.Params_tbl_type,
	x_signatures_tbl     	OUT 	NOCOPY EDR_EvidenceStore_PUB.Signature_tbl_type  )
IS
	l_api_name CONSTANT VARCHAR2(50) := 'Get_DocumentDetails';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
	l_docDetl_rec	edr_psig.Document;
	l_params_tbl	edr_psig.Params_Table;
	l_sig_tbl	edr_psig.SignatureTable;
	lth	NUMBER;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    	edr_psig.getDocumentDetails (
			P_DOCUMENT_ID  		=> p_document_id,
         		P_DOCUMENT  		=> l_docDetl_rec,
         		P_DOCPARAMS  		=> l_params_tbl,
         		P_SIGNATURES  		=> l_sig_tbl,
         		P_ERROR        		=> l_error_code,
         		P_ERROR_MSG  		=> l_error_mesg );
	FOR lth in 1..l_params_tbl.COUNT  LOOP
	  x_doc_parameters_tbl(lth) := l_params_tbl(lth);
	END LOOP;
	FOR lth in 1..l_sig_tbl.COUNT  LOOP
	  x_signatures_tbl(lth) := l_sig_tbl(lth);
	END LOOP;
	x_document_rec.DOCUMENT_ID 	:= l_docDetl_rec.DOCUMENT_ID;
	x_document_rec.PSIG_XML 	:= l_docDetl_rec.PSIG_XML;
	x_document_rec.PSIG_DOCUMENT 	:= l_docDetl_rec.PSIG_DOCUMENT;
	x_document_rec.PSIG_DOCUMENTFORMAT := l_docDetl_rec.PSIG_DOCUMENTFORMAT;
	x_document_rec.PSIG_TIMESTAMP 	:= l_docDetl_rec.PSIG_TIMESTAMP;
	x_document_rec.PSIG_TIMEZONE 	:= l_docDetl_rec.PSIG_TIMEZONE;
	x_document_rec.DOCUMENT_REQUESTER  := l_docDetl_rec.DOCUMENT_REQUESTER;
	x_document_rec.PSIG_STATUS 	:= l_docDetl_rec.PSIG_STATUS;
	x_document_rec.PSIG_SOURCE 	:= l_docDetl_rec.PSIG_SOURCE;
	x_document_rec.EVENT_NAME 	:= l_docDetl_rec.EVENT_NAME;
	x_document_rec.EVENT_KEY 	:= l_docDetl_rec.EVENT_KEY;
	x_document_rec.PRINT_COUNT 	:= l_docDetl_rec.PRINT_COUNT;
	x_document_rec.CREATION_DATE 	:= l_docDetl_rec.CREATION_DATE;
	x_document_rec.CREATED_BY 	:= l_docDetl_rec.CREATED_BY;
	x_document_rec.LAST_UPDATE_DATE := l_docDetl_rec.LAST_UPDATE_DATE;
	x_document_rec.LAST_UPDATED_BY 	:= l_docDetl_rec.LAST_UPDATED_BY;
	x_document_rec.LAST_UPDATE_LOGIN := l_docDetl_rec.LAST_UPDATE_LOGIN;
   IF l_error_code > 0  THEN		-- l_error_code = 21001 document closed or not exist
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
   END IF;
   FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Get_DocumentDetails;



-- Bug 4135005 : Start

-- --------------------------------------
-- API name 	: Get_SignatureDetails
-- Type		: Public
-- Pre-reqs	: None
-- Function	: To Return the Signature parameters
-- Parameters
-- IN	:	p_signature_id 		NUMBER		Signature id
-- OUT	:	x_signaturedetails	Signature	Signature details as a record
--		x_document_params_tbl	params_table	Signature parameters as a table
-- Versions	: 1.0	28-Jul-05	created from edr_psig.GetSignatureDetails
-- ---------------------------------------



 PROCEDURE GET_SignatureDetails (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2 default NULL,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
        P_SIGNATURE_ID          IN      NUMBER DEFAULT NULL,
        X_SIGNATUREDETAILS      OUT     NOCOPY EDR_PSIG_DETAILS%ROWTYPE,
        X_SIGNATUREPARAMS       OUT     NOCOPY EDR_EvidenceStore_PUB.params_tbl_type  )

	IS
	l_api_name CONSTANT VARCHAR2(50) := 'Get_SignatureDetails';
	l_api_version CONSTANT NUMBER := 1.0;
	l_error_code 	NUMBER;
	l_error_mesg	VARCHAR2(1000);
	l_signaturedetails  EDR_PSIG.Signature;
	l_signatureparams   EDR_PSIG.params_table;
	lth	NUMBER;

	BEGIN
	    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
	    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	    -- Initialize message list if the caller asks me to do so
	    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	    END IF;

	    --  Initialize API return status to success
	    x_return_status := FND_API.G_RET_STS_SUCCESS;

	  EDR_PSIG.getSignatureDetails
          (
           P_SIGNATURE_ID   => p_signature_id,
	   P_SIGNATUREDETAILS => l_signaturedetails,
           P_SIGNATUREPARAMS => l_signatureparams,
           P_ERROR => l_error_code,
           P_ERROR_MSG => l_error_mesg );

	   FOR lth in 1..l_signatureparams.COUNT  LOOP
	   X_SIGNATUREPARAMS(lth) := l_signatureparams(lth);
	   END LOOP;

           X_SIGNATUREDETAILS.SIGNATURE_ID := l_SIGNATUREDETAILS.SIGNATURE_ID;
 	   X_SIGNATUREDETAILS.DOCUMENT_ID  := l_SIGNATUREDETAILS.DOCUMENT_ID;
           X_SIGNATUREDETAILS.EVIDENCE_STORE_ID := l_SIGNATUREDETAILS.EVIDENCE_STORE_ID;
           X_SIGNATUREDETAILS.USER_NAME  := l_SIGNATUREDETAILS.USER_NAME;
           X_SIGNATUREDETAILS.USER_RESPONSE := l_SIGNATUREDETAILS.USER_RESPONSE;
           X_SIGNATUREDETAILS.SIGNATURE_TIMESTAMP := l_SIGNATUREDETAILS.SIGNATURE_TIMESTAMP;
           X_SIGNATUREDETAILS.SIGNATURE_TIMEZONE := l_SIGNATUREDETAILS.SIGNATURE_TIMEZONE;
           X_SIGNATUREDETAILS.SIGNATURE_STATUS := l_SIGNATUREDETAILS.SIGNATURE_STATUS;
           X_SIGNATUREDETAILS.CREATION_DATE := l_SIGNATUREDETAILS.CREATION_DATE;
           X_SIGNATUREDETAILS.CREATED_BY := l_SIGNATUREDETAILS.CREATED_BY;
           X_SIGNATUREDETAILS.LAST_UPDATE_DATE := l_SIGNATUREDETAILS.LAST_UPDATE_DATE;
           X_SIGNATUREDETAILS.LAST_UPDATE_LOGIN := l_SIGNATUREDETAILS.LAST_UPDATE_LOGIN;
           X_SIGNATUREDETAILS.LAST_UPDATED_BY := l_SIGNATUREDETAILS.LAST_UPDATED_BY;
           X_SIGNATUREDETAILS.USER_DISPLAY_NAME := l_SIGNATUREDETAILS.USER_DISPLAY_NAME;

     IF l_error_code > 0  THEN		-- l_error_code = 21001 document closed or not exist
	   	fnd_message.Set_Name( 'EDR', 'EDR_PLS_STDMSG_GENERATED' );
	   	fnd_message.Set_Token( 'ERR_CODE', l_error_code );
	   	fnd_message.Set_Token( 'ERR_MESG', l_error_mesg );
	   	fnd_msg_pub.Add;
	   	raise fnd_api.G_EXC_ERROR;
   END IF;
   FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
		FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END Get_SignatureDetails;


-- Bug 4135005 : End







-- ----------------------------------------
-- API name 	: Capture_Signature
-- Type		: Public
-- Function	: capture the signature for single event and generate document id + signature id
-- Parameters
-- IN	: p_psig_xml		CLOB 	[null] source xml
--	: p_psig_document	CLOB 	[null] source document
--	: p_psig_documentFormat	VARCHAR2	source document format
--	: p_psig_requester	VARCHAR2	eSig requester user name
--	: p_psig_source		VARCHAR2 	eSig source platform (DB, Form, sswa)
--	: p_event_name		VARCHAR2 	eSig event name
--	: p_event_key		VARCHAR2 	eSig event key
--	: p_wf_notif_id		NUMBER 		workflow notification id
--	: p_doc_parameters_tbl	EDR_EvidenceStore_PUB.Params_tbl_type
--	: p_user_name		VARCHAR2
--	: p_original_recipient	VARCHAR2 	[null]
--	: p_overriding_comment	VARCHAR2 	[null]
--	: p_evidenceStore_id	NUMBER,
--	: p_user_response	VARCHAR2,
--	: p_sig_parameters_tbl
-- OUT	: x_document_id		NUMBER		generated document id
--	: x_signature_id	NUMBER		captured signature id
-- Versions	: 1.0	17-Jul-03	created
-- ---------------------------------------

PROCEDURE Capture_Signature  (
	p_api_version		IN 	NUMBER,
	p_init_msg_list		IN 	VARCHAR2,
	p_commit		IN 	VARCHAR2,
	x_return_status		OUT 	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_psig_xml		IN 	CLOB,
	p_psig_document		IN 	CLOB,
	p_psig_docFormat	IN 	VARCHAR2,
	p_psig_requester	IN 	VARCHAR2,
	p_psig_source		IN 	VARCHAR2,
	p_event_name		IN 	VARCHAR2,
	p_event_key		IN 	VARCHAR2,
	p_wf_notif_id		IN 	NUMBER,
	x_document_id		OUT	NOCOPY NUMBER,
	p_doc_parameters_tbl	IN	EDR_EvidenceStore_PUB.Params_tbl_type,
	p_user_name		IN	VARCHAR2,
	p_original_recipient	IN	VARCHAR2,
	p_overriding_comment	IN	VARCHAR2,
	x_signature_id		OUT	NOCOPY NUMBER,
	p_evidenceStore_id	IN	NUMBER,
	p_user_response		IN	VARCHAR2,
	p_sig_parameters_tbl	IN	EDR_EvidenceStore_PUB.Params_tbl_type  )
IS
    	l_api_name CONSTANT VARCHAR2(50)	:= 'Capture_Signature';
    	l_api_version	CONSTANT NUMBER	:= 1.0;
    	l_document_id	NUMBER;
    	l_signature_id	NUMBER;
BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN	RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Open_Document ( 	p_api_version, p_init_msg_list, p_commit, x_return_status, x_msg_count,
			x_msg_data, p_psig_xml, p_psig_document, p_psig_docFormat,
			p_psig_requester, p_psig_source, p_event_name, p_event_key,
			p_wf_notif_id, x_document_id );
    l_document_id := x_document_id;

    Post_DocumentParameters ( 	p_api_version, p_init_msg_list, p_commit, x_return_status,
				x_msg_count, x_msg_data, l_document_id, p_doc_parameters_tbl );

    Request_Signature ( p_api_version, p_init_msg_list, p_commit, x_return_status, x_msg_count,
			x_msg_data, l_document_id, p_user_name, p_original_recipient,
			p_overriding_comment, x_signature_Id );
    l_signature_id := x_signature_Id;

    Post_Signature ( 	p_api_version, p_init_msg_list, p_commit, x_return_status, x_msg_count,
			x_msg_data, l_document_id, p_evidenceStore_id, p_user_name, p_user_response,
			p_original_recipient, p_overriding_comment, x_signature_Id );
    l_signature_id := x_signature_Id;

    Post_SignatureParameters ( p_api_version, p_init_msg_list, p_commit, x_return_status,
				x_msg_count, x_msg_data, l_signature_id, p_sig_parameters_tbl );

    Close_Document( 	p_api_version, p_init_msg_list, p_commit, x_return_status,
			x_msg_count, x_msg_data, l_document_id );

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	THEN    FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
	END IF;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END Capture_Signature;


END EDR_EvidenceStore_PUB;


/
