--------------------------------------------------------
--  DDL for Package IEM_SERVER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SERVER_PUB" AUTHID CURRENT_USER as
/* $Header: iempsvrs.pls 120.0 2005/06/02 13:48:49 appldev noship $ */
-- *****************************************************
-- Start of Comments
-- Package name     : IEM_Server_PUB
-- Purpose          : Public Package. This package contains APIs that can be
--				  used to retrieve connection information to various email
--				  servers. The APIs are designed to be invoked during
--				  middle-tier initialization/startup so that the email
--				  server configuration information can be cached and
-- 				  supplied to email clients without making further database
--				  calls. Please refer to eMC Schema for details.
--
-- History          : mpawar 12/19/99
-- 				: rtripath 12/25/99 Developed The Package Body
-- 				: sboorela 5/24/01 Added GetOESList() and GetProtocolSrvList()
-- NOTE             :



TYPE EMAILSVR_rec_type IS RECORD (
	SERVER_NAME		VARCHAR2(50) ,
	PORT				NUMBER ,
	ACTIVE	VARCHAR2(1) );

TYPE EMAILSVR_tbl_type IS TABLE OF EMAILSVR_rec_type
		 INDEX BY BINARY_INTEGER;

--****************************************************************************
--	API name 		: 	Get_EmailServer_List
--	Type			: 	Public
--	Function		:	This API returns both IMAP and SMTP email servers,
--					identify each by the SERVER_TYPE field in the return
--					record. Email accounts of a certain SERVER_GROUP_ID
--					can be serviced only by servers of the same GROUP_ID.
--				     Use DNS name if provided, this allows load balancing
--					options (if they are available). IMAP or INBOUND Only
--					Or SMTP or OUTBOUND only servers can be retrieved by
--					passing appropriate arguments in the P_SERVER_TYPE
--					parameter.
--					'I' - INBOUND 'IS' - INBOUND SECURE SERVER
--					'O' - OUTBOUND 'OS' - OUTBOUND SECURE
--					These are options!, the secure server may not be
--					available.
--	Pre-reqs		: 	None.
--	Parameters	:
--	IN
-- 		p_api_version    	IN NUMBER	Required
--		p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--		p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--        p_SERVER_GROUP_ID  IN NUMBER	:= 0,
--        p_SERVER_TYPE	IN VARCHAR2 	:= 'ALL',
--
--	OUT
--  		x_return_status	OUT	VARCHAR2
--		x_msg_count	OUT	NUMBER
PROCEDURE Get_EmailServer_List (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_SERVER_ID  IN NUMBER	,
			      p_SERVER_TYPE	IN VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_Svr_tbl  OUT NOCOPY  EMAILSVR_tbl_type);
END IEM_SERVER_PUB;

 

/
