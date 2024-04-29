--------------------------------------------------------
--  DDL for Package IEM_ARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ARCH_PVT" AUTHID CURRENT_USER as
/* $Header: iemarcps.pls 120.2 2005/10/11 13:31:15 rtripath ship $ */
-- Start of Comments
--  API name 	: submit_request
--  Type	: 	Private
--  Function	: This procedure allows to submit a request for archiving
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_folder     IN  VARCHAR2,
--  p_email_account_id in number,
--  p_search_criteria in varchar2,

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

PROCEDURE submit_request(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
      			p_message_id IN  jtf_varchar2_Table_100,
			p_folder	   IN  VARCHAR2,
			p_email_account_id in number,
			p_search_criteria in varchar2,
			p_request_type in varchar2,
			x_request_id	OUT NOCOPY NUMBER,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: process_request
--  Type	: 	Private
--  Function	: This procedure starts the archiving process
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_request_id in number,

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
PROCEDURE process_request(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_request_id	   IN  NUMBER,
			p_request_type in varchar2,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 );

-- Start of Comments
--  API name 	: cancel_request
--  Type	: 	Private
--  Function	: This procedure delete a archiving request
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_request_id in number,

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
PROCEDURE cancel_request(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_request_id	   IN  NUMBER,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 );

PROCEDURE get_folder_dtl(
			p_email_account_id	   IN  NUMBER,
			p_folder		IN VARCHAR2,
			p_date	IN varchar2,
			p_date_format	in varchar2,
			x_count	OUT NOCOPY NUMBER,
			x_msg_table	OUT NOCOPY jtf_number_table,
			x_arch_date		OUT NOCOPY  VARCHAR2,
			x_action_flg		OUT NOCOPY VARCHAR2,	--Y/N
			x_action_desc		OUT NOCOPY VARCHAR2,	--Y/N
  		 	x_ret_status	      OUT	NOCOPY VARCHAR2,
	  	  	x_out_text	OUT	NOCOPY VARCHAR2);

PROCEDURE PROC_REQUESTS(ERRBUF OUT NOCOPY		VARCHAR2,
		   ERRRET OUT NOCOPY		VARCHAR2,
		   p_api_version_number in number:= 1.0);
PROCEDURE CREATE_MLCS(p_request_id	in number,
				  p_milcs_type in number,
  		 		x_ret_status	      OUT	NOCOPY VARCHAR2,
	  	  		x_out_text	OUT	NOCOPY VARCHAR2);

END IEM_ARCH_PVT;

 

/
