--------------------------------------------------------
--  DDL for Package GMD_OPERATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OPERATIONS_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMDVOPSS.pls 120.0.12010000.1 2008/07/24 10:02:08 appldev ship $
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDVOPSS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions for  			   |
 |     creating, modifying, deleting opeations                                            |
 |                                                                          |
 | HISTORY                                                                 |
 |     27-AUG-2002  Sandra Dulyk    Created                               |
 |     25-NOV-2002  Thomas Daniel   Bug# 2679110                          |
 |                  Removed the parameters oprn_no and vers to update     |
 +=========================================================================+
  API Name  : GMD_OPERATIONS_PVT
  Type      : Private
  Function  : This package contains private procedures used to create, modify, and delete operations
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/


 PROCEDURE insert_operation
( p_api_version 		IN 	NUMBER 			DEFAULT 1
, p_init_msg_list 		IN 	BOOLEAN 		DEFAULT TRUE
, p_commit		IN 	BOOLEAN 		DEFAULT  FALSE
, p_operations 		IN 	gmd_operations%ROWTYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

PROCEDURE update_operation
( p_api_version 		IN 	NUMBER 			DEFAULT  1
, p_init_msg_list 		IN 	BOOLEAN 		DEFAULT TRUE
, p_commit		IN 	BOOLEAN 			DEFAULT FALSE
, p_oprn_id		IN	gmd_operations.oprn_id%TYPE
, p_update_table		IN	gmd_operations_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2
);

END GMD_OPERATIONS_PVT;

/
