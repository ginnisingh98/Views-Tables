--------------------------------------------------------
--  DDL for Package CS_CONTRACT_TPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONTRACT_TPL_PUB" AUTHID CURRENT_USER as
/* $Header: csctptps.pls 115.0 99/07/16 08:53:36 porting ship  $ */
	PROCEDURE Contract_to_Template
	(
	p_api_version             	IN NUMBER,
	p_init_msg_list           	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit                  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status          	OUT VARCHAR2,
	x_msg_count              	OUT NUMBER,
	x_msg_data               	OUT VARCHAR2,
	p_contract_id	         	IN NUMBER,
	p_template_name			IN VARCHAR2,
	x_template_id			OUT NUMBER
	);

	PROCEDURE Template_to_Contract
	(
	p_api_version		  	IN NUMBER,
	p_init_msg_list	  		IN VARCHAR2  DEFAULT FND_API.G_FALSE,
       	p_commit                  	IN VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status	 		OUT VARCHAR2,
	x_msg_count		 	OUT NUMBER,
	x_msg_data		 	OUT VARCHAR2,
	p_template_id		  	IN NUMBER,
	p_customer_id		 	IN NUMBER,
	p_contract_number	 	IN NUMBER,
	p_bill_to_site_use_id	 	IN NUMBER,
	p_ship_to_site_use_id	 	IN NUMBER,
	p_start_date			IN DATE,
	p_end_date			IN DATE,
	x_contract_id			OUT NUMBER
	);


	G_PKG_NAME CONSTANT 	VARCHAR2(30) := 'CS_Contract_Tpl_Pub';
	l_object_version_number NUMBER;
	l_msg_count		NUMBER;
	l_msg_data		VARCHAR2(2000);
	l_return_status		VARCHAR2(1) := NULL;
	l_api_type		VARCHAR2(6) := '_PUB';


End CS_Contract_Tpl_Pub;

 

/
