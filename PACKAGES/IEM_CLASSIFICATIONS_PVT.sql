--------------------------------------------------------
--  DDL for Package IEM_CLASSIFICATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_CLASSIFICATIONS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvclas.pls 115.12 2002/12/06 19:17:11 sboorela shipped $*/
/***************************************************************/
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id IN   NUMBER,
--  p_classification	IN   VARCHAR2,
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
  				 p_classification	IN   VARCHAR2,
			p_CREATED_BY    NUMBER,
          	p_CREATION_DATE    DATE,
         		p_LAST_UPDATED_BY    NUMBER,
          	p_LAST_UPDATE_DATE    DATE,
          	p_LAST_UPDATE_LOGIN    NUMBER,
         		p_ATTRIBUTE1    VARCHAR2,
          	p_ATTRIBUTE2    VARCHAR2,
          	p_ATTRIBUTE3    VARCHAR2,
          	p_ATTRIBUTE4    VARCHAR2,
          	p_ATTRIBUTE5    VARCHAR2,
          	p_ATTRIBUTE6    VARCHAR2,
          	p_ATTRIBUTE7    VARCHAR2,
          	p_ATTRIBUTE8    VARCHAR2,
          	p_ATTRIBUTE9    VARCHAR2,
          	p_ATTRIBUTE10    VARCHAR2,
          	p_ATTRIBUTE11    VARCHAR2,
          	p_ATTRIBUTE12    VARCHAR2,
          	p_ATTRIBUTE13    VARCHAR2,
          	p_ATTRIBUTE14    VARCHAR2,
          	p_ATTRIBUTE15    VARCHAR2,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 );

PROCEDURE create_item_wrap (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
  		      p_email_account_id IN   NUMBER,
  		      p_classification	IN   VARCHAR2,
             p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
		 );

PROCEDURE create_item_wrap_sss (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
  		      p_email_account_id IN   NUMBER,
  		      p_classification	IN   VARCHAR2,
             p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
		 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_email_account_id	in number:=FND_API.G_MISS_NUM,
--  p_classification IN   VARCHAR2 :=FND_API.G_MISS_CHAR,
--  p_classification_id  in number:=FND_API.G_MISS_NUM,

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
			 p_email_account_id	in number,
			 p_classification IN   VARCHAR2 ,
			 p_classification_id  in number,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );
-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure update a record in the table IEM_CLASSIFICATIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_classification_id IN NUMBER:=FND_API.G_MISS_NUM,
--  p_email_account_id IN NUMBER:=FND_API.G_MISS_NUM,
--   p_classification IN   VARCHAR2:=FND_API.G_MISS_CHAR,
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

PROCEDURE update_item (p_api_version_number    IN   NUMBER,
 		     p_init_msg_list  IN   VARCHAR2 ,
		       p_commit	    IN   VARCHAR2 ,
			 p_classification_id IN NUMBER,
			 p_email_account_id IN NUMBER,
  			 p_classification IN   VARCHAR2,
         		p_ATTRIBUTE1    VARCHAR2,
          	p_ATTRIBUTE2    VARCHAR2,
          	p_ATTRIBUTE3    VARCHAR2,
          	p_ATTRIBUTE4    VARCHAR2,
          	p_ATTRIBUTE5    VARCHAR2,
          	p_ATTRIBUTE6    VARCHAR2,
          	p_ATTRIBUTE7    VARCHAR2,
          	p_ATTRIBUTE8    VARCHAR2,
          	p_ATTRIBUTE9    VARCHAR2,
          	p_ATTRIBUTE10    VARCHAR2,
          	p_ATTRIBUTE11    VARCHAR2,
          	p_ATTRIBUTE12    VARCHAR2,
          	p_ATTRIBUTE13    VARCHAR2,
          	p_ATTRIBUTE14    VARCHAR2,
          	p_ATTRIBUTE15    VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );

PROCEDURE delete_item_wrap
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_clas_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

PROCEDURE delete_item_wrap_sss
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_clas_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

PROCEDURE update_item_wrap (p_api_version_number    IN   NUMBER,
 		      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
			 p_classification_id IN NUMBER,
			 p_email_account_id IN NUMBER,
  			 p_classification IN   VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	 x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 );
PROCEDURE update_item_wrap_sss (p_api_version_number    IN   NUMBER,
 		      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
			 p_classification_id IN NUMBER,
			 p_email_account_id IN NUMBER,
  			 p_classification IN   VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	 x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 );
-- This API is only called by the POSTMEN Process to insert data
-- into IEM_CLASSIFICATIONS
PROCEDURE create_item_pm (p_api_version_number    IN   NUMBER,
  				 p_email_account_id IN   NUMBER,
  				 p_classification	IN   VARCHAR2,
				 p_query_response   IN VARCHAR2,
				 x_doc_seq_num	 OUT NOCOPY NUMBER,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
               p_LAST_UPDATED_BY    NUMBER ,
               p_LAST_UPDATE_DATE    DATE,
               p_LAST_UPDATE_LOGIN    NUMBER,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2);

/********************************************************************/
END IEM_CLASSIFICATIONS_PVT;

 

/
