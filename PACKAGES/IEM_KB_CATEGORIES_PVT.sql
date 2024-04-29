--------------------------------------------------------
--  DDL for Package IEM_KB_CATEGORIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_KB_CATEGORIES_PVT" AUTHID CURRENT_USER as
/* $Header: iemvkbcs.pls 115.3 2002/12/02 23:52:32 sboorela shipped $ */

-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_KB_CATEGORIES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_kb_category_id	NUMBER:=FND_API.G_MISS_NUM,
-- p_kb_parent_category_id IN   VARCHAR2,
--  p_display_name		IN VARCHAR2,
-- p_category_code IN   VARCHAR2,
--  p_is_repos IN   VARCHAR2,
--  p_category_order IN   NUMBER,
--  p_category_desc IN   varchar2:=FND_API.G_MISS_CHAR,
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
				 p_kb_category_id	NUMBER,
  				 p_kb_parent_category_id IN   NUMBER,
				 p_display_name		IN VARCHAR2,
  				 p_category_code IN   VARCHAR2,
  				 p_is_repos IN   VARCHAR2,
  				 p_category_order IN   NUMBER,
  				 p_category_desc IN   varchar2,
			p_CREATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
          	p_CREATION_DATE    DATE:=SYSDATE,
         		p_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ,
          	p_LAST_UPDATE_DATE    DATE:=SYSDATE,
          	p_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ,
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

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_KB_CATEGORIES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_kb_category_id	in NUMBER:=FND_API.G_MISS_NUM,
--  p_kb_parent_category_id IN   NUMBER:=FND_API.G_MISS_NUM,
--  p_display_name IN   VARCHAR2 :=FND_API.G_MISS_CHAR,
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
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_kb_category_id	in NUMBER,
				 p_kb_parent_category_id IN   NUMBER,
				 p_display_name IN   VARCHAR2 ,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );
-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure update a record in the table IEM_KB_CATEGORIES
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_kb_category_id IN	NUMBER:=FND_API.G_MISS_NUM,
--  p_kb_parent_category_id	 IN	number:=FND_API.G_MISS_NUM,
--  p_display_name	 IN	varchar2:=FND_API.G_MISS_CHAR,
--  p_category_code IN 	varchar2:=FND_API.G_MISS_CHAR,
--  p_is_repos IN   VARCHAR2:=FND_API.G_MISS_CHAR,
--  p_category_order IN 	number:=FND_API.G_MISS_CHAR,
--  p_category_desc varchar2:=FND_API.G_MISS_CHAR,
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
 		  	      p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    IN   VARCHAR2 := FND_API.G_FALSE,
				 p_kb_category_id IN	NUMBER,
				 p_kb_parent_category_id	 IN	number,
				 p_display_name	 IN	varchar2,
				 p_category_code IN 	varchar2,
				 p_is_repos IN   VARCHAR2,
				 p_category_order IN 	number,
				 p_category_desc varchar2,
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
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2
			 );
END IEM_KB_CATEGORIES_PVT;

 

/
