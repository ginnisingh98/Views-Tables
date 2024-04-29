--------------------------------------------------------
--  DDL for Package ASO_WFNOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_WFNOTIFICATION_PVT" AUTHID CURRENT_USER AS
/* $Header: asovwnts.pls 120.1 2005/06/29 12:46:23 appldev ship $ */

VERSION         CONSTANT NUMBER := 1.0;

PROCEDURE Notify_User ( p_api_version		IN 	NUMBER,
	                p_commit		IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
                        p_user_name 		IN   	VARCHAR2,
                        p_subject 		IN   	VARCHAR2,
	                p_body 			IN   	VARCHAR2,
                        x_return_status       OUT NOCOPY /* file.sql.39 change */  	 VARCHAR2,
                        x_msg_count	 OUT NOCOPY /* file.sql.39 change */  NUMBER,
                        x_msg_data	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			);

PROCEDURE Send_Email ( p_api_version		IN 	NUMBER,
	               p_commit			IN	VARCHAR2 := FND_API.g_false,
	               p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
                       p_email_list 		IN   	VARCHAR2,
                       p_subject 		IN   	VARCHAR2,
	               p_body 			IN   	VARCHAR2,
                       x_return_status       OUT NOCOPY /* file.sql.39 change */  	 VARCHAR2,
                       x_msg_count	 OUT NOCOPY /* file.sql.39 change */  NUMBER,
                       x_msg_data	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
			);

END ASO_WFNOTIFICATION_PVT ;

 

/
