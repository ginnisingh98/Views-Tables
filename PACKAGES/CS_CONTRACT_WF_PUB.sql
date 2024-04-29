--------------------------------------------------------
--  DDL for Package CS_CONTRACT_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTRACT_WF_PUB" AUTHID CURRENT_USER as
/* $Header: csctpwfs.pls 115.0 99/07/16 08:53:46 porting ship  $ */
  	FUNCTION Is_Contract_Wf_Active (
		p_contract_id	  	IN NUMBER,
		p_wf_process_id   	IN NUMBER )
	RETURN VARCHAR2;

  	pragma RESTRICT_REFERENCES (Is_Contract_Wf_Active, WNDS);


 	PROCEDURE Launch_Contract_Wf (
		p_api_version		  	IN NUMBER,
		p_init_msg_list		  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		p_commit		  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		x_return_status		 	OUT VARCHAR2,
		x_msg_count		 	OUT NUMBER,
		x_msg_data		 	OUT VARCHAR2,
		p_contract_id		  	IN NUMBER,
		p_requestor_userid  		IN NUMBER,
		p_requestor_username		IN VARCHAR2,
		p_process_owner			IN VARCHAR2,
          	p_nowait                  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		x_itemkey	  	 	OUT VARCHAR2);


  	PROCEDURE Cancel_Contract_Wf (
                p_api_version             	IN NUMBER,
                p_init_msg_list           	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_commit                  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                x_return_status          	OUT VARCHAR2,
                x_msg_count              	OUT NUMBER,
                x_msg_data               	OUT VARCHAR2,
                p_contract_id	         	IN NUMBER,
                p_wf_process_id           	IN NUMBER,
                p_user_id                 	IN NUMBER );


  	PROCEDURE Decode_Contract_Wf_Itemkey(
		p_api_version		 	IN NUMBER,
		p_init_msg_list	  		IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		x_return_status	 		OUT VARCHAR2,
		x_msg_count		 	OUT NUMBER,
		x_msg_data		 	OUT VARCHAR2,
		p_itemkey		  	IN VARCHAR2,
		p_contract_id		 	OUT NUMBER,
		p_wf_process_id	 		OUT NUMBER );


  	PROCEDURE Encode_Contract_Wf_Itemkey(
		p_api_version		  	IN NUMBER,
		p_init_msg_list	  		IN VARCHAR2  DEFAULT FND_API.G_FALSE,
		x_return_status	 		OUT VARCHAR2,
		x_msg_count		 	OUT NUMBER,
		x_msg_data		 	OUT VARCHAR2,
		p_contract_id		  	IN NUMBER,
		p_wf_process_id	  		IN NUMBER,
		p_itemkey		 	OUT VARCHAR2 );

	PROCEDURE Create_Req_Document(
		document_id			IN	VARCHAR2,
		display_type			IN	VARCHAR2,
		document			IN OUT	VARCHAR2,
		document_type			IN OUT	VARCHAR2);

	PROCEDURE Reminder_Req_Document(
		document_id			IN	VARCHAR2,
		display_type			IN	varchar2,
		document			IN OUT	VARCHAR2,
		document_type			IN OUT	VARCHAR2);


	l_itemtype	CONSTANT VARCHAR2(30) := 'CSCTSTAT';
	l_return_status	VARCHAR2(1) := NULL;
	image_loc	VARCHAR2(80) := '/OA_JAVA/oracle/apps/fnd/wf/icons/';
	l_api_type	VARCHAR2(6) := '_PUB';


End CS_Contract_Wf_PUB;

 

/
