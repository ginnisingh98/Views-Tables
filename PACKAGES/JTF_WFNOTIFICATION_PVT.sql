--------------------------------------------------------
--  DDL for Package JTF_WFNOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_WFNOTIFICATION_PVT" AUTHID CURRENT_USER AS
/* $Header: JTFVWNTS.pls 120.2 2005/10/25 05:08:18 psanyal ship $ */

     VERSION         CONSTANT NUMBER := 1.0;

	PROCEDURE Send_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit		IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list		IN	VARCHAR2 := FND_API.g_false,
                     	email_list 		IN   	VARCHAR2,
                     	subject 		IN   	VARCHAR2,
	        	body 			IN   	VARCHAR2,
                     	return_status       OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
                	x_msg_count	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
                	x_msg_data	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
			);
END JTF_WFNOTIFICATION_PVT ;

 

/
