--------------------------------------------------------
--  DDL for Package IEM_EML_CLASSIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EML_CLASSIFICATIONS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvecls.pls 115.8 2003/07/31 01:20:50 sboorela shipped $*/

TYPE EMCLASS_rec_typ IS RECORD (
          CLASSIFICATION_ID   NUMBER(15,0) ,
          CLASSIFICATION      VARCHAR2(50) ,
          SCORE          NUMBER);

 TYPE EMCLASS_tbl_type IS TABLE OF EMCLASS_rec_typ INDEX BY BINARY_INTEGER;

-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_EMAIL_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id IN   NUMBER,
--  p_classification_id	IN   NUMBER,
--  p_score IN NUMBER,
--  p_message_id  IN NUMBER,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  				 p_email_account_id IN   NUMBER,
  				 p_classification_id	IN   NUMBER,
		           p_score IN NUMBER,
		           p_message_id  IN NUMBER,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
         p_LAST_UPDATED_BY    NUMBER,
         p_LAST_UPDATE_DATE    DATE,
     p_LAST_UPDATE_LOGIN    NUMBER ,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_EMAIL_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id IN   NUMBER:=FND_API.G_MISS_NUM ,
--   p_classification_id	IN   NUMBER:=FND_API.G_MISS_NUM,
--   p_message_id  IN NUMBER:=FND_API.G_MISS_NUM,

--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			 p_email_account_id IN   NUMBER,
  			 p_classification_id	IN   NUMBER,
		      p_message_id  IN NUMBER,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: getclassification
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_EMAIL_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id IN   NUMBER:=FND_API.G_MISS_NUM ,
--   p_message_id  IN NUMBER:=FND_API.G_MISS_NUM,

--	OUT
--   x_Email_Classn_tbl  OUT EMCLASS_tbl_type
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE getClassification (p_api_version_number    IN   NUMBER,
                     p_init_msg_list  IN   VARCHAR2 ,
                     p_commit     IN   VARCHAR2 ,
                     p_email_account_id IN   NUMBER,
                     p_message_id IN   NUMBER,
                     x_Email_Classn_tbl  OUT NOCOPY EMCLASS_tbl_type,
		  		x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	      OUT NOCOPY NUMBER,
	  	    		x_msg_data OUT NOCOPY VARCHAR2
                 );
-- This is the new api for 11.5.10 /MP-R. This Api will return the category id in case MES category based
-- mapping
PROCEDURE getClassification (p_api_version_number    IN   NUMBER,
                     p_init_msg_list  IN   VARCHAR2 ,
                     p_commit     IN   VARCHAR2 ,
                     p_email_account_id IN   NUMBER,
                     p_message_id IN   NUMBER,
				 x_category_id OUT NOCOPY NUMBER,
                     x_Email_Classn_tbl  OUT NOCOPY EMCLASS_tbl_type,
		  		x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	      OUT NOCOPY NUMBER,
	  	    		x_msg_data OUT NOCOPY VARCHAR2
                 );
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_EMAIL_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id IN   NUMBER,
--  p_classification_id	IN   NUMBER,
--  p_score IN NUMBER,
--  p_message_id  IN NUMBER,
--  p_class_string  IN varchar2,
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
  				 p_email_account_id IN   NUMBER,
  				 p_classification_id	IN   NUMBER,
		           p_score IN NUMBER,
		           p_message_id  IN NUMBER,
		           p_class_string  IN varchar2,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
         p_LAST_UPDATED_BY    NUMBER ,
         p_LAST_UPDATE_DATE    DATE,
     p_LAST_UPDATE_LOGIN    NUMBER ,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2);
END IEM_EML_CLASSIFICATIONS_PVT;

 

/
