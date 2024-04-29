--------------------------------------------------------
--  DDL for Package GMD_OPERATION_ACTIVITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPERATION_ACTIVITIES_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMDVOPAS.pls 115.4 2002/11/25 21:34:39 txdaniel noship $
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDVOPAS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions for  			   |
 |     creating, modifying, deleting operation activities                                            |
 |                                                                         |
 | HISTORY                                                                 |
 |     22-JUNE-2002  Sandra Dulyk    Created                               |
 +=========================================================================+
  API Name  : GMD_OPERATION_ACTIVITIES_PVT
  Type      : Private
  Function  : This package contains private procedures used to create, modify, and delete operation activties
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/


PROCEDURE insert_operation_activity
( p_oprn_id		IN	gmd_operations.oprn_id%TYPE	DEFAULT NULL
, p_oprn_activity		IN	gmd_operation_activities%ROWTYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);


PROCEDURE update_operation_activity
( p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
, p_update_table		IN	gmd_operation_activities_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);


PROCEDURE delete_operation_activity
( p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);


END GMD_OPERATION_ACTIVITIES_PVT;

 

/
