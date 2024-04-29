--------------------------------------------------------
--  DDL for Package IEM_REROUTING_HISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_REROUTING_HISTS_PVT" AUTHID CURRENT_USER as
/* $Header: iemvrehs.pls 115.1 2002/12/06 00:20:15 sboorela shipped $*/
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_REROUTING_HISTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
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
			p_message_id		IN   NUMBER,
			p_agent_id   IN  NUMBER,
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
		      x_return_status	OUT NOCOPY VARCHAR2,
  		 	 x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	 x_msg_data	OUT	NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: delete_item
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_REROUTING_HISTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_message_id	in number,

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
				 p_message_id	in number,
			     x_return_status	OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2
			 );

END IEM_REROUTING_HISTS_PVT;

 

/
