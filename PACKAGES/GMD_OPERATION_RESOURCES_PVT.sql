--------------------------------------------------------
--  DDL for Package GMD_OPERATION_RESOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPERATION_RESOURCES_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMDVOPRS.pls 115.3 2002/11/25 19:52:13 txdaniel noship $
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDVOPRS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions for  			   |
 |     creating, modifying, deleting opeation resources                                            |
 |                                                                         |
 | HISTORY                                                                 |
 |     27-SEPT-2002  Sandra Dulyk    Created                               |
 +=========================================================================+
  API Name  : GMD_OPERATION_RESOURCES_PVT
  Type      : Private
  Function  : This package contains private procedures used to create, modify, and delete operation resources
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

 PROCEDURE insert_operation_resources
(p_oprn_line_id		IN 	gmd_operation_activities.oprn_line_id%TYPE
, p_oprn_rsrc_tbl		IN 	gmd_operation_resources_pub.gmd_oprn_resources_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);


PROCEDURE update_operation_resources
( p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
, p_resources		IN	gmd_operation_resources.resources%TYPE
, p_update_table		IN	gmd_operation_resources_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);


PROCEDURE delete_operation_resource
( p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
, p_resources		IN 	gmd_operation_resources.resources%TYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

END GMD_OPERATION_RESOURCES_PVT;

 

/
