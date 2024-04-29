--------------------------------------------------------
--  DDL for Package IEM_NEXT_GEN_PROCESS_EMAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_NEXT_GEN_PROCESS_EMAIL_PVT" AUTHID CURRENT_USER as
/* $Header: iemngcws.pls 120.0 2005/06/02 13:41:05 appldev noship $*/
-- Global Variables
-- *****************************************************
-- Start of Comments
-- Package name     : IEM_NEXT_GEN_PROCESS_EMAIL_PVT
-- Purpose          : Private Package. Start the Workflow procss
-- History          : kbeagle 05/20/04
-- NOTE             :

--	API name 	: 	CallWorkflow
--	Type		: 	Public
--	Function	:       This API invokes the Workflow process for mail preprocessing
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN
-- 		p_api_version    	IN NUMBER	Required
--		p_init_msg_list	        IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--		p_commit	        IN VARCHAR2	Optional Default = FND_API.G_FALSE
-- 		p_workflowProcess       IN varchar2 :=FND_API.G_MISS_CHAR,
-- 		p_Item_Type	        IN varchar2 :=FND_API.G_MISS_CHAR,
--	OUT
--   	        x_return_status	        OUT	VARCHAR2
--		x_msg_count	        OUT	NUMBER
--		x_msg_data	        OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE LaunchProcess(ERRBUF			OUT NOCOPY VARCHAR2,
		        ERRRET    		OUT NOCOPY VARCHAR2,
			p_api_version_number    IN  NUMBER,
 		        p_init_msg_list  	IN  VARCHAR2 ,
		        p_commit	    	IN  VARCHAR2 ,
  			p_workflowProcess 	IN  VARCHAR2 ,
 			p_Item_Type	 	IN  VARCHAR2 ,
			p_qopt			IN  VARCHAR2:='NO_WAIT',
			p_counter		IN  NUMBER
			 );

PROCEDURE StopProcessing(ERRBUF 		OUT NOCOPY  VARCHAR2,
			 ERRRET 		OUT NOCOPY  VARCHAR2,
		 	 p_api_version_number   IN  NUMBER,
 		    	 p_init_msg_list        IN  VARCHAR2 ,
		       	 p_commit	        IN  VARCHAR2
				 );

PROCEDURE PurgeWorkflow(ERRBUF 			OUT NOCOPY  varchar2,
			ERRRET 			OUT NOCOPY		varchar2,
			p_api_version_number    IN  NUMBER,
 		        p_init_msg_list  	IN   VARCHAR2 ,
		        p_commit	    	IN   VARCHAR2 ,
			p_item_type		IN VARCHAR2:='IEM_MAIL',
			p_end_date   		IN DATE:=sysdate-3
				 );
END IEM_NEXT_GEN_PROCESS_EMAIL_PVT;

 

/
