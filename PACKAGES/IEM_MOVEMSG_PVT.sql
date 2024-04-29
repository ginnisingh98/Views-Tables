--------------------------------------------------------
--  DDL for Package IEM_MOVEMSG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MOVEMSG_PVT" AUTHID CURRENT_USER as
/* $Header: iemvmsgs.pls 115.3 2002/12/04 00:01:48 chtang noship $*/

-- Start of Comments
--  API name 	: moveMessage
--  Type	: 	Private
--  Function	: This procedure moves messages.
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2 	Optional Default = FND_API.G_FALSE
--  p_commit	IN VARCHAR2	Optional Default = FND_API.G_FALSE
--  p_msgid 	IN   NUMBER,
--  p_email_account_id	IN   NUMBER,
--  p_tofolder	IN   VARCHAR2,
--	OUT
--   x_status	OUT	NUMBER
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE moveMessage (	p_api_version_number    	IN   NUMBER,
 		  	        	p_init_msg_list  		IN   VARCHAR2,
		    	        	p_commit	    			IN   VARCHAR2,
  				  	p_msgid				IN   NUMBER,
  				  	p_email_account_id		IN   NUMBER,
  				  	p_tofolder			IN  VARCHAR2,
  				  	p_reverse				IN  VARCHAR2,
					x_status			 OUT NOCOPY NUMBER,
					x_return_status	 OUT NOCOPY VARCHAR2,
  		    			x_msg_count	       OUT NOCOPY NUMBER,
	  	    			x_msg_data		 OUT NOCOPY VARCHAR2
			 );

PROCEDURE moveOesMessage (p_api_version_number    IN   NUMBER,
 		  	         p_init_msg_list  IN   VARCHAR2,
		    	         p_commit	    IN   VARCHAR2,
  				 p_msgid	IN   NUMBER,
  			       	 p_email_account_id	IN   NUMBER,
  				 p_tofolder	IN  VARCHAR2,
  				 p_fromfolder	IN  VARCHAR2,
		  		x_return_status OUT NOCOPY VARCHAR2,
  		    		x_msg_count	      OUT NOCOPY NUMBER,
	  	    		x_msg_data OUT NOCOPY VARCHAR2
			 );


END IEM_MOVEMSG_PVT;

 

/
