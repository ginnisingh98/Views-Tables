--------------------------------------------------------
--  DDL for Package BOM_RTG_NETWORK_VALIDATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_NETWORK_VALIDATE_API" AUTHID CURRENT_USER AS
/* $Header: BOMRNWVS.pls 115.0 99/07/26 17:43:54 porting ship  $ */

TYPE Lnk_Record_Type IS RECORD
	(  from_op_seq_id	NUMBER,
	   to_op_seq_id		NUMBER,
	   flag			VARCHAR2(1));

TYPE Lnk_Tbl_Type IS TABLE OF Lnk_Record_Type
	INDEX BY BINARY_INTEGER;

TYPE Op_Record_Type IS RECORD
	(  operation_seq_id	NUMBER,
	   operation_seq_num	NUMBER);

TYPE Op_Tbl_Type IS TABLE OF Op_Record_Type
	INDEX BY BINARY_INTEGER;
/*-------------------------------------------------------------------------
      Name
	validate_routing_network

      Description
        This PROCEDURE validates the Routing Network. A check for loops
	is performed before checking for any broken links in the network.

      Returns
        x_status  - Status of the validation.
	x_message - If a loop/broken link exists, the nodes where it
		    exists is returned.
+--------------------------------------------------------------------------*/

PROCEDURE validate_routing_network(
    p_rtg_sequence_id   IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2 DEFAULT NULL,
    p_operation_type    IN  NUMBER,
    x_status            OUT VARCHAR2,
    x_message           OUT VARCHAR2);


END BOM_RTG_NETWORK_VALIDATE_API;

 

/
