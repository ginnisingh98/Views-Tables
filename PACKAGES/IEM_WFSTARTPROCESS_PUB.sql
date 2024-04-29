--------------------------------------------------------
--  DDL for Package IEM_WFSTARTPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_WFSTARTPROCESS_PUB" AUTHID CURRENT_USER as
/* $Header: iempwfss.pls 120.1 2005/09/19 13:52:04 appldev ship $*/
-- Global Variables

TYPE t_queuerecord is record(
	msg_id	number,
	user_name	varchar2(60)
	);
TYPE t_queue_table is TABLE OF t_queuerecord
INDEX BY BINARY_INTEGER;
-- *****************************************************
-- Start of Comments
-- Package name     : IEM_WFSTARTPROCESS_PUB
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
PROCEDURE CallWorkflow(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  				p_workflowProcess in varchar2 ,
 				p_Item_Type	 in varchar2 ,
				itemkey in number,
				p_itemuserkey in varchar2,
				p_queue_opt	in varchar2:='FOREVER',
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );
PROCEDURE LaunchProcess(ERRBUF OUT NOCOPY VARCHAR2,
				    ERRRET    OUT NOCOPY VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				p_workflowProcess in varchar2 :=null,
 				p_Item_Type	 in varchar2 :=null,
				p_qopt	in varchar2:='FOREVER',
				p_counter	in number
			 );
PROCEDURE ProcessRetry(ERRBUF OUT NOCOPY 	VARCHAR2,
				   ERRRET OUT NOCOPY 	VARCHAR2,
				   p_api_version_number in number,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_TRUE,
  				p_workflowProcess in varchar2 :=null,
 				p_Item_Type	 in varchar2 :=null);

PROCEDURE StopWorkflow(ERRBUF	 OUT NOCOPY	VARCHAR2,
				   ERRRET	 OUT NOCOPY	VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_TRUE
				 );
PROCEDURE PurgeWorkflow(ERRBUF	 OUT NOCOPY VARCHAR2,
					ERRRET OUT NOCOPY	VARCHAR2,
				p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_TRUE,
				 p_item_type	IN VARCHAR2:='IEM_MAIL',
				 p_end_date   IN varchar2
				 );
END IEM_WFSTARTPROCESS_PUB;

 

/
