--------------------------------------------------------
--  DDL for Package OKC_AQ_WRITE_ERROR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_AQ_WRITE_ERROR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRAQWS.pls 120.0 2005/05/25 23:03:53 appldev noship $ */
	----------------------------------------------------------------------------------
	--Subtype Definitions
	subtype aqev_rec_type is okc_aqerrmsg_pub.aqev_rec_type;
 	subtype aqev_tbl_type is okc_aqerrmsg_pub.aqev_tbl_type;
 	subtype aqmv_rec_type is okc_aqerrmsg_pub.aqmv_rec_type;
 	subtype aqmv_tbl_type is okc_aqerrmsg_pub.aqmv_tbl_type;
	----------------------------------------------------------------------------------
	--Global Variables
	l_aqev_rec		aqev_rec_type;
	x_aqev_rec		aqev_rec_type;
	l_aqev_tbl		aqev_tbl_type;
	l_aqmv_rec		aqmv_rec_type;
	x_aqmv_rec		aqmv_rec_type;
	l_aqmv_tbl		aqmv_tbl_type;
	x_aqmv_tbl		aqmv_tbl_type;

	-- Global Variables
	G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_AQ_WRITE_ERROR_PVT';
 	G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 	G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
 	G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
 	G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

	--Global Exception
  	G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

	--Procedure to write errors and message details to the tables from the message stack
	PROCEDURE WRITE_MSGDATA(p_api_version	IN NUMBER,
				p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_TRUE,
				p_source_name	IN VARCHAR2,
				p_datetime	IN DATE,
				p_msg_tab	IN OKC_AQ_PVT.msg_tab_typ,
				p_q_name	IN VARCHAR2 DEFAULT NULL,
				p_corrid	IN VARCHAR2,
				p_msgid         IN RAW DEFAULT NULL,
			        p_message_name	IN VARCHAR2 DEFAULT NULL,
				p_msg_count	IN NUMBER,
				p_msg_data	IN VARCHAR2,
				p_commit	IN VARCHAR2 DEFAULT 'T');

	--Procedure to update errors and message details in the tables
	PROCEDURE UPDATE_ERROR(p_api_version	IN NUMBER,
				       p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
				       p_id		IN NUMBER,
				       p_aqe_id         IN NUMBER,
				       p_msg_seq_no     IN NUMBER,
				       p_source_name	IN VARCHAR2,
		      		       p_datetime	IN DATE,
				       p_q_name		IN VARCHAR2 DEFAULT NULL,
				       p_msgid          IN RAW DEFAULT NULL,
			               p_message_no	IN NUMBER,
				       p_message_name	IN VARCHAR2,
				       p_message_text   IN VARCHAR2,
				       x_msg_count	OUT NOCOPY NUMBER,
				       x_msg_data	OUT NOCOPY VARCHAR2,
				       x_return_status  OUT NOCOPY VARCHAR2);

	--Procedure to delete errors and message details from the tables
	PROCEDURE DELETE_ERROR(p_api_version	IN NUMBER,
				       p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
				       p_id 		IN NUMBER,
				       x_msg_count	OUT NOCOPY NUMBER,
				       x_msg_data	OUT NOCOPY VARCHAR2,
				       x_return_status  OUT NOCOPY VARCHAR2);
	PROCEDURE get_clob_msg(p_msg_tab       IN OKC_AQ_PVT.msg_tab_typ,
		          p_q_name        IN VARCHAR2,
			  p_corrid        IN VARCHAR2,
                          p_msg_clob      OUT NOCOPY CLOB,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY VARCHAR2,
			  x_msg_data      OUT NOCOPY VARCHAR2);
end OKC_AQ_WRITE_ERROR_PVT;

 

/
