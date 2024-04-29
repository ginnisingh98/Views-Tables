--------------------------------------------------------
--  DDL for Package IEM_MDTSTARTPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MDTSTARTPROCESS_PUB" AUTHID CURRENT_USER as
/* $Header: iempcmss.pls 120.1 2005/09/19 13:38:43 appldev ship $*/
-- Global Variables
-- *****************************************************
-- Start of Comments
-- Package name     : IEM_MDTSTARTPROCESS_PUB
-- Purpose          : Public Package. Start the Workflow procss
-- History          : rtripath 02/04/00
-- NOTE             :

--	API name 	: 	CallWorkflow
--	Type		: 	Public
--	Function	: This API invoke the Workflow process for mail preprocessing
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN
-- 		p_api_version    	IN NUMBER	Required
--		p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--		p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
-- 		p_workflowProcess in varchar2 :=FND_API.G_MISS_CHAR,
-- 		p_Item_Type	 in varchar2 :=FND_API.G_MISS_CHAR,
--	OUT
--   	x_return_status	OUT	VARCHAR2
--		x_msg_count	OUT	NUMBER
--		x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE LaunchProcess(ERRBUF OUT NOCOPY VARCHAR2,
				    ERRRET    OUT NOCOPY VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  			p_workflowProcess in varchar2 ,
 			p_Item_Type	 in varchar2 ,
			p_qopt	in varchar2:='NO_WAIT',
			p_counter	in number
			 );

PROCEDURE ProcessRetry(ERRBUF OUT NOCOPY 	VARCHAR2,
		   ERRRET OUT NOCOPY 	VARCHAR2,
		   p_api_version_number in number,
 		   p_init_msg_list  IN   VARCHAR2 ,
	    	   p_commit	    IN   VARCHAR2 ,
  		p_workflowProcess in varchar2 ,
 		p_Item_Type	 in varchar2 );

PROCEDURE StopProcessing(ERRBUF OUT NOCOPY		VARCHAR2,
				   ERRRET OUT NOCOPY		VARCHAR2,
					p_api_version_number    IN   NUMBER,
 		    		 p_init_msg_list  IN   VARCHAR2 ,
		       	 p_commit	    IN   VARCHAR2
				 );
PROCEDURE PurgeWorkflow(ERRBUF OUT NOCOPY	varchar2,
			ERRRET OUT NOCOPY		varchar2,
			p_api_version_number    IN   NUMBER,
 		        p_init_msg_list  IN   VARCHAR2 ,
		         p_commit	    IN   VARCHAR2 ,
			 p_item_type	IN VARCHAR2:='IEM_MAIL',
			 p_end_date   IN varchar2
				 );
END IEM_MDTSTARTPROCESS_PUB;

 

/
