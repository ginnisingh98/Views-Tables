--------------------------------------------------------
--  DDL for Package IBE_WFNOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_WFNOTIFICATION_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVWNTS.pls 115.3 2002/12/10 11:30:00 suchandr ship $ */

     VERSION         CONSTANT NUMBER := 1.0;

	PROCEDURE Notify_User (
	                p_api_version		IN 	NUMBER,
	                p_commit			IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
                     user_name 		IN   VARCHAR2,
                     subject 			IN   VARCHAR2,
	        		 body 			IN   VARCHAR2,
                     return_status      OUT NOCOPY  VARCHAR2,
                	 x_msg_count		OUT NOCOPY	NUMBER,
                	 x_msg_data		OUT NOCOPY	VARCHAR2
			);

	PROCEDURE Send_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit			IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
                     email_list 		IN   VARCHAR2,
                     subject 			IN   VARCHAR2,
	        		 body 			IN   VARCHAR2,
                     return_status      OUT NOCOPY  VARCHAR2,
                	 x_msg_count		OUT NOCOPY	NUMBER,
                	 x_msg_data		OUT NOCOPY	VARCHAR2
			);
	PROCEDURE Send_Html_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit			IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
                     email_list 		IN   VARCHAR2,
                     subject 			IN   VARCHAR2,
	        		 body 			IN   VARCHAR2,
                     return_status      OUT NOCOPY  VARCHAR2,
                	 x_msg_count		OUT NOCOPY	NUMBER,
                	 x_msg_data		OUT NOCOPY	VARCHAR2
			);
END IBE_WFNOTIFICATION_PVT ;

 

/
