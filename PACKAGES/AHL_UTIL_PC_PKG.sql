--------------------------------------------------------
--  DDL for Package AHL_UTIL_PC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UTIL_PC_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLUPCXS.pls 120.0 2005/05/26 10:59:48 appldev noship $ */

	G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_PC_UTIL_PKG';

	-----------------------
	-- Declare Functions --
	-----------------------
	--  Start of Comments  --
	--
	--  Procedure name    	: Get_fmp_pc_node
	--  Type        	:
	--  Function    	: Returns boolean based on availabilty of data.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_pc_node_id                   IN      NUMBER       Default  NULL
	--      p_inventory_id                 IN      VARCHAR2     Default  NULL
	--
	--  Standard Return value :
	--      BOOLEAN
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --

        FUNCTION get_fmp_pc_node
        (
                p_pc_node_id		IN	NUMBER	:= NULL,
                p_inventory_id      	IN	NUMBER 	:= NULL
        )
        RETURN BOOLEAN;

	-----------------------
	-- Declare Functions --
	-----------------------
	--  Start of Comments  --
	--
	--  Procedure name    	: get_uc_node
	--  Type        	:
	--  Function    	: Returns boolean based on availabilty of data.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_pc_node_id                   IN      NUMBER       Default  NULL
	--      p_Item_Instance_ID             IN      VARCHAR2     Default  NULL
	--
	--  Standard Return value :
	--	BOOLEAN
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --


        FUNCTION get_uc_node
        (
                p_pc_node_id		IN	NUMBER 	:= NULL,
                p_Item_Instance_ID  	IN	NUMBER 	:= NULL
        )
        RETURN BOOLEAN;

        -----------------------
	-- Declare Functions --
	-----------------------
	--  Start of Comments  --
	--
	--  Procedure name    	: is_pc_complete
	--  Type        	:
	--  Function    	: Returns 0/-1 based on availabilty of data.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_pc_header_id               IN      NUMBER       Default  NULL
	--
	--  Standard Return value :
	--  	NUMBER		: Returns 0 if no need for check completion, -1 otherwise
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --

	FUNCTION is_pc_complete
	(
		p_pc_header_id 		IN 	NUMBER 	:= NULL
	)
	RETURN NUMBER;

        PRAGMA RESTRICT_REFERENCES(get_fmp_pc_node,WNPS,RNPS,WNDS);

END AHL_UTIL_PC_PKG;

 

/
