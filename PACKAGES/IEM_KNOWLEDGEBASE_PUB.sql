--------------------------------------------------------
--  DDL for Package IEM_KNOWLEDGEBASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_KNOWLEDGEBASE_PUB" AUTHID CURRENT_USER as
/* $Header: iemvknbs.pls 115.8 2003/07/31 01:21:18 sboorela shipped $ */
-- *****************************************************
-- Start of Comments
-- Package name     : IEM_KnowledgeBase_PUB
-- Purpose          : Public Package. PL/SQL KB apis. The eMC client has access
--				  to various Java query and retrieval APIs provided direclty
--				 by the SMS and MES teams. These are to be used to query and
--				  retrieve documents from these KBS.
-- History          : mpawar 12/19/99
--				: rtripath 12/25/99 Developed The Body of The Package
-- NOTE             :
-- End of Comments
-- *****************************************************

TYPE EMSGRESP_rec_type IS RECORD (
		DOCUMENT_ID	VARCHAR2(50) ,
		SCORE		VARCHAR2(30)  ,
		KB_REPOSITORY_NAME	  VARCHAR2(100) ,
		KB_CATEGORY_NAME	  VARCHAR2(100) ,
		DOCUMENT_TITLE	VARCHAR2(100) ,
		URL      VARCHAR2(256) ,
		DOCUMENT_LAST_MODIFIED_DATE  DATE );


TYPE KBCAT_rec_type IS RECORD (
		DISPLAY_NAME       VARCHAR2(50) ,
		IS_REPOSITORY      VARCHAR2(1)  ,
		CATEGORY_ID	 number(15) ,
		PARENT_CAT_ID  number(15) ,
		CATEGORY_ORDER   NUMBER(5)
);
TYPE EMSGRESP_tbl_type IS TABLE OF EMSGRESP_rec_type
		 INDEX BY BINARY_INTEGER;

TYPE KBCAT_tbl_type IS TABLE OF KBCAT_rec_type
		 INDEX BY BINARY_INTEGER;

-- *******************************************************
--  Start of comments
--	API name 	: 	Get_SuggResponse
--	Type		: 	Public
--	Function	: This API returns a list of suggested responses for an
--			  email. The document URL can be displayed on the GUI. The
--			  URL should directly download a document to the client.
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN
-- 		p_api_version    	IN NUMBER	Required
--		p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--		p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--	     p_EMAIL_ACCOUNT_ID  IN NUMBER,
--        p_MESSAGE_ID  IN VARCHAR2,
--	OUT
--   	x_return_status	OUT	VARCHAR2
--		x_msg_count	OUT	NUMBER
--		x_msg_data	OUT	VARCHAR2
--        x_Email_SuggResp_tbl  OUT EMSGRESP_tbl_type
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE Get_SuggResponse (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
                     p_CLASSIFICATION_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type
			 );

-- *******************************************************
--  Start of comments
--	API name 	: 	Get_KBCategories
--	Type		: 	Public
--	Purpose		: This API is used to display a KB query screen to the agent
--			  Each email account is mapped to relevant KBS and categories
-- 				 within a KBS. This information is retrieved and displayed
--				 on the GUI. It allows the agent to choose from a list of
--				 available KBS and categories to search for documents
--				 that can help him answer the email. This list of KBS and
--				 categories different for each email account. The query is
--				 invoked by calling a Java API.
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN
-- 		p_api_version    	IN NUMBER	Required
--		p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--		p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--	     p_EMAIL_ACCOUNT_ID  IN NUMBER,
--        p_LEVEL  IN NUMBER := 1,
--
--	OUT
--   	x_return_status	OUT	VARCHAR2
--		x_msg_count	OUT	NUMBER
--		x_msg_data	OUT	VARCHAR2
--        x_KB_Cat_tbl  OUT KBCAT_tbl_type
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE Get_KBCategories (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_LEVEL  IN NUMBER := 1,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_KB_Cat_tbl  OUT NOCOPY KBCAT_tbl_type
			 );
-- *******************************************************
--  Start of comments
--	API name 	: 	Delete_ResultsCache
--	Type		: 	Public
--	Purpose	: This API should be called when an email has been successfully
--			  dealt with. It deleted the suggested responses to the named
--				  email. It will also release any additional routing storage
--				  associated with this email.
--	Pre-reqs	: 	None.
--	Parameters	:
--	IN
-- 		p_api_version    	IN NUMBER	Required
--		p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--		p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--        p_EMAIL_ACCOUNT_ID  IN NUMBER,
--        p_MESSAGE_ID  IN VARCHAR2,
--
--	OUT
--  		x_return_status	OUT	VARCHAR2
--		x_msg_count	OUT	NUMBER
--		x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************
PROCEDURE Delete_ResultsCache ( p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
 			 );

-- THIS API IS NOT BEING CALLED NOW, MAY BE USEFUL LATER Currently
--get_suggresponse api is serving the purpose

PROCEDURE Get_KB_SuggResponse (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
				 p_CLASSIFICATION_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type);

PROCEDURE Get_SuggResponse_dtl(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
                     p_CLASSIFICATION_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type
			 );
-- This API is introduced in 11.5.0/MP-R. This will be called for showing alternate suggested response
-- Documents.
PROCEDURE Get_SuggResponse_dtl(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type
			 );
END IEM_KnowledgeBase_PUB;

 

/
