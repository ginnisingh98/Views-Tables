--------------------------------------------------------
--  DDL for Package IEM_THEMES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_THEMES_PVT" AUTHID CURRENT_USER as
/* $Header: iempthes.pls 115.10 2003/08/26 23:41:53 sboorela shipped $*/
/*****************************************************************/
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_THEMES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_score IN   NUMBER,
--  p_classification_id	IN   NUMBER,
--  p_theme IN VARCHAR2,
--  p_query_response  IN VARCHAR2,
--  p_account_name IN   VARCHAR2,
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
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
  				 p_score IN   NUMBER,
  				 p_classification_id	IN   NUMBER,
		           p_theme IN VARCHAR2,
		           p_query_response  IN VARCHAR2,
			p_CREATED_BY  IN  NUMBER,
          	p_CREATION_DATE  IN  DATE,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
         		p_ATTRIBUTE1   IN VARCHAR2,
          	p_ATTRIBUTE2   IN VARCHAR2,
          	p_ATTRIBUTE3   IN VARCHAR2,
          	p_ATTRIBUTE4   IN VARCHAR2,
          	p_ATTRIBUTE5   IN VARCHAR2,
          	p_ATTRIBUTE6   IN VARCHAR2,
          	p_ATTRIBUTE7   IN VARCHAR2,
          	p_ATTRIBUTE8   IN VARCHAR2,
          	p_ATTRIBUTE9   IN VARCHAR2,
          	p_ATTRIBUTE10  IN  VARCHAR2,
          	p_ATTRIBUTE11  IN  VARCHAR2,
          	p_ATTRIBUTE12  IN  VARCHAR2,
          	p_ATTRIBUTE13  IN  VARCHAR2,
          	p_ATTRIBUTE14  IN  VARCHAR2,
          	p_ATTRIBUTE15  IN  VARCHAR2,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure deletes a record in the table IEM_THEMES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_theme_id IN VARCHAR2,
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

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_theme_id	IN   NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure updates a record in the table IEM_THEMES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_theme_id IN VARCHAR2,
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
				 p_theme_id IN NUMBER,
				 p_classification_id	IN   NUMBER,
		           p_theme IN VARCHAR2 ,
				 p_score IN NUMBER,
		           p_query_response  IN VARCHAR2,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
         		p_ATTRIBUTE1   IN VARCHAR2,
          	p_ATTRIBUTE2   IN VARCHAR2,
          	p_ATTRIBUTE3   IN VARCHAR2,
          	p_ATTRIBUTE4   IN VARCHAR2,
          	p_ATTRIBUTE5   IN VARCHAR2,
          	p_ATTRIBUTE6   IN VARCHAR2,
          	p_ATTRIBUTE7   IN VARCHAR2,
          	p_ATTRIBUTE8   IN VARCHAR2,
          	p_ATTRIBUTE9   IN VARCHAR2,
          	p_ATTRIBUTE10  IN  VARCHAR2,
          	p_ATTRIBUTE11  IN  VARCHAR2,
          	p_ATTRIBUTE12  IN  VARCHAR2,
          	p_ATTRIBUTE13  IN  VARCHAR2,
          	p_ATTRIBUTE14  IN  VARCHAR2,
          	p_ATTRIBUTE15  IN  VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );


PROCEDURE create_item_wrap (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
                p_score IN   NUMBER,
                p_classification_id     IN   NUMBER,
                p_theme IN VARCHAR2,
                p_query_response  IN VARCHAR2,
              p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
		 );

PROCEDURE create_item_wrap_sss (p_api_version_number    IN   NUMBER,
 	  	      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
                p_score IN   NUMBER,
                p_classification_id     IN   NUMBER,
                p_theme IN VARCHAR2,
                p_query_response  IN VARCHAR2,
              p_CREATED_BY    NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2,
  		      x_msg_count	      OUT NOCOPY NUMBER,
	  	      x_msg_data OUT NOCOPY VARCHAR2
		 );

PROCEDURE delete_item_wrap
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_thes_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

PROCEDURE delete_item_wrap_sss
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 ,
      p_commit          IN  VARCHAR2 ,
      p_thes_ids_tbl    IN  jtf_varchar2_Table_100,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2);

PROCEDURE update_item_wrap (p_api_version_number    IN   NUMBER,
 		      p_init_msg_list  IN   VARCHAR2 ,
		      p_commit	    IN   VARCHAR2 ,
                p_theme_id IN NUMBER,
                p_classification_id     IN   NUMBER,
                p_theme IN VARCHAR2 ,
                p_score IN NUMBER,
                p_query_response  IN VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2,
  		  	 x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	 x_msg_data OUT NOCOPY VARCHAR2
			 );

/****************************************************************/
-- this API is called by Postman rule processing for inserting
-- records into IEM_THEMES
PROCEDURE create_item_pm (p_score IN   NUMBER,
  				 p_classification_id	IN   NUMBER,
		           p_theme IN VARCHAR2,
		           p_query_response  IN VARCHAR2,
				 p_doc_seq_no   IN NUMBER,
               p_CREATED_BY    NUMBER,
               p_CREATION_DATE    DATE,
               p_LAST_UPDATED_BY    NUMBER,
               p_LAST_UPDATE_DATE    DATE,
               p_LAST_UPDATE_LOGIN    NUMBER,
		  x_return_status OUT NOCOPY VARCHAR2,
  		    x_msg_count	      OUT NOCOPY NUMBER,
	  	    x_msg_data OUT NOCOPY VARCHAR2
			 );
PROCEDURE calculate_weight (p_email_account_id	IN   NUMBER,
		           		p_query_response  IN VARCHAR2,
		  				x_return_status OUT NOCOPY VARCHAR2
			 );
END IEM_THEMES_PVT;

 

/
