--------------------------------------------------------
--  DDL for Package IEM_ARCH_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ARCH_REQUESTS_PVT" AUTHID CURRENT_USER as
/* $Header: iemarqvs.pls 115.0 2003/08/20 21:37:27 sboorela noship $ */
-- Start of Comments
--  API name 	: create_item
--  Type	: 	Private
--  Function	: This procedure create a record in the table IEM_ARCH_REQUESTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
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
			p_request_id	in number,
			p_arch_criteria	   IN  VARCHAR2,
			p_email_account_id          IN  NUMBER,
			p_folder_name               IN  VARCHAR2,
			p_request			IN VARCHAR2,
			p_arch_folder_id	IN NUMBER,
			p_arch_count		IN NUMBER,
			p_CREATED_BY  IN  NUMBER,
          	p_CREATION_DATE  IN  DATE,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: update_item
--  Type	: 	Private
--  Function	: This procedure updates a record in the table IEM_ARCH_REQUESTS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_request_id  in number,
-- p_arch_folder_id   in number,
-- p_arch_count  in number,
-- p_arch_size   in number,
-- p_status      in varchar2,
-- p_comment     in varchar2,

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

PROCEDURE update_item(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_request_id	in number,
				 p_arch_folder_id	in number,
				 p_arch_count	in number,
				 p_arch_size	in number,
				 p_status		in varchar2,
				 p_comment	in varchar2,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2
			 );

END IEM_ARCH_REQUESTS_PVT;

 

/
