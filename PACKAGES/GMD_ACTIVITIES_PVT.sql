--------------------------------------------------------
--  DDL for Package GMD_ACTIVITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ACTIVITIES_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMDVACTS.pls 115.3 2002/11/27 16:07:49 txdaniel noship $
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDVACTS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions for  			   |
 |     creating, modifying Activities                                      |
 |                                                                         |
 | HISTORY                                                                 |
 |     06-JUN-2002  Sandra Dulyk    Created                                |
 |     25-NOV-2002  Thomas Daniel   Bug# 2679110                           |
 |                                  Added further validations and rewrote  |
 |                                  the update procedure.                  |
 +=========================================================================+
  API Name  : GMD_ACTIVITIES_PVT
  Type      : Private
  Function  : This package contains private procedures used to create, modify, and delete Activities
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

PROCEDURE insert_activity
(
  p_api_version 		IN 	NUMBER	DEFAULT	   1
, p_init_msg_list 		IN 	BOOLEAN	DEFAULT	  TRUE
, p_commit			IN 	BOOLEAN	DEFAULT   FALSE
, p_activity_tbl		IN 	gmd_activities_pub.gmd_activities_tbl_type
, x_message_count	 	OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

PROCEDURE update_activity
(
  p_api_version 		IN 	NUMBER		DEFAULT 1
, p_init_msg_list 		IN 	BOOLEAN	DEFAULT TRUE
, p_commit			IN 	BOOLEAN	DEFAULT FALSE
, p_activity			IN 	gmd_activities.activity%TYPE
, p_update_table		IN	gmd_activities_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

END GMD_ACTIVITIES_PVT;

 

/
