--------------------------------------------------------
--  DDL for Package GMD_PROCESS_INSTR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_PROCESS_INSTR_UTILS" AUTHID CURRENT_USER AS
/* $Header: GMDPIUTS.pls 120.4 2006/07/12 18:07:28 txdaniel noship $ */

/*-------------------------------------------------------------------
-- NAME
--    Build_Array
--
-- SYNOPSIS
--    Procedure Build_Array
--
-- DESCRIPTION
--     This procedure is used to build the array to pass to GMO
--
-- HISTORY
--
--------------------------------------------------------------------*/

PROCEDURE Build_Array  (
				p_entity_name		 IN            VARCHAR2	,
				p_entity_id	         IN            NUMBER		,
                                x_name_array             OUT    NOCOPY GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                x_key_array              OUT    NOCOPY GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
			        x_return_status          OUT    NOCOPY VARCHAR2);

/*-------------------------------------------------------------------
-- NAME
--    Copy_Process_Instructions
--
-- SYNOPSIS
--    Procedure Copy_Process_Instructions
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions from
-- one entity to another
--
-- HISTORY
--------------------------------------------------------------------*/

PROCEDURE Copy_Process_Instructions  (
                                p_source_name_array      IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                p_source_key_array       IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                p_target_name_array      IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
                                p_target_key_array       IN     GMO_DATATYPES_GRP.GMO_TABLE_OF_VARCHAR2_255,
			        x_return_status          OUT	NOCOPY VARCHAR2);


/*-------------------------------------------------------------------
-- NAME
--    COPY_PROCESS_INSTR
--
-- SYNOPSIS
--    Procedure COPY_PROCESS_INSTR
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions from
-- one entity to another
--
-- HISTORY
--    Sriram    7/20/2005    Created for GMD-GMO Integration Build
--------------------------------------------------------------------*/

PROCEDURE COPY_PROCESS_INSTR  (
				p_entity_name		 IN	VARCHAR2	,
				p_from_entity_id	 IN	NUMBER		,
			        p_to_entity_id		 IN	NUMBER		,
			        x_return_status          OUT	NOCOPY VARCHAR2	,
			        x_msg_count              OUT	NOCOPY NUMBER	,
				x_msg_data               OUT	NOCOPY VARCHAR2	);


/*-------------------------------------------------------------------
-- NAME
--    COPY_PROCESS_INSTR
--
-- SYNOPSIS
--    Procedure COPY_PROCESS_INSTR
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions from
-- child entities to parent entity
--
-- E.g When a reciipe is created, copy the PI's defined at routing and
--     formula level to  recipe-routing and recipe-formula level
--
--     When a routing is created, copy the PI's defined at operation level to the
--     routing-operation level
--
-- HISTORY
--    Sriram    7/20/2005     Created for GMD-GMO Integration Build
--------------------------------------------------------------------*/

PROCEDURE COPY_PROCESS_INSTR  (
				p_entity_name		 IN	VARCHAR2	,
				p_entity_id		 IN	NUMBER		,
			        x_return_status          OUT	NOCOPY VARCHAR2	,
			        x_msg_count              OUT	NOCOPY NUMBER	,
				x_msg_data               OUT	NOCOPY VARCHAR2	);

/*-----------------------------------------------------------------------------
-- NAME
--    COPY_PROCESS_INSTR_ROW
--
-- SYNOPSIS
--    Procedure COPY_PROCESS_INSTR_ROW
--
-- DESCRIPTION
--     This procedure is called to copy the process instructions of a single from
--     child entity to a parent entity
--
--     When a routing is updated by adding an operation, copy the PI's defined at
--     operation level to the routing-operation level
--
-- HISTORY
--    Kapil M    18-MAY-2006    Bug# 5173039
--------------------------------------------------------------------------------*/


PROCEDURE COPY_PROCESS_INSTR_ROW 	(
                                p_entity_name		 IN	VARCHAR2	,
				p_entity_id		 IN	NUMBER		,
			        x_return_status          OUT	NOCOPY VARCHAR2	,
			        x_msg_count              OUT	NOCOPY NUMBER	,
				x_msg_data               OUT	NOCOPY VARCHAR2	);


/*-------------------------------------------------------------------
-- NAME
--    SEND_PI_ACKN
--
-- SYNOPSIS
--    Procedure SEND_PI_ACKN
--
-- DESCRIPTION
--     This procedure is called to send acknowledgment to the PI framework
-- if version contrl is ON. The source and entity names and keys needs to
-- passed to copy the pending (current) changes from old entity to new entity.
--
--
-- HISTORY
--    Sriram    7/20/2005     Created for GMD-GMO Integration Build
--------------------------------------------------------------------*/

PROCEDURE SEND_PI_ACKN(
				p_entity_name		 IN	VARCHAR2	,
				p_INSTRUCTION_PROCESS_ID IN	NUMBER		,
				p_old_entity_id		 IN	NUMBER		,
				p_new_entity_id		 IN	NUMBER		,
			        X_RETURN_STATUS          OUT	NOCOPY VARCHAR2	,
			        X_MSG_COUNT              OUT	NOCOPY NUMBER	,
				X_MSG_DATA               OUT	NOCOPY VARCHAR2	);

--API related Designer.
p_recipe_instr_process_id     NUMBER;
p_formula_instr_process_id    NUMBER;
p_routing_instr_process_id    NUMBER;
p_setp_instr_process_id       NUMBER;
PROCEDURE DESG_SEND_PI_ACKN(p_return_status OUT NOCOPY VARCHAR2);
FUNCTION  GET_DESG_INVOKE_PI_ID(p_entity_type VARCHAR2)
RETURN NUMBER;
PROCEDURE  SET_DESG_INVOKE_PI_ID(p_entity_type  VARCHAR2,
                                p_pi_entity_id NUMBER);
PROCEDURE DESG_SEND_VER_PI_ACKN(p_from_recipe_id         IN  VARCHAR2,
                                p_from_formula_id        IN  VARCHAR2,
                                p_from_routing_id        IN  VARCHAR2,
                                p_to_recipe_id           IN  VARCHAR2,
                                p_return_status          OUT NOCOPY VARCHAR2);

END GMD_PROCESS_INSTR_UTILS;


 

/
