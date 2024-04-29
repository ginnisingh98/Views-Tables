--------------------------------------------------------
--  DDL for Package CZ_SESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_SESSION" AUTHID CURRENT_USER AS
/*	$Header: czsess.pls 115.8 2002/11/27 17:16:47 askhacha ship $		  */

/*
 *	CZ_SESSION - package contains variables for use within a DATABASE SESSION
 *	THIS PACKAGE IS NOT TO BE INVOKED FROM WEB APPS CONTEXTS.
 */

-- CONTEXT: SECURITY (all variables)

/* Optimization for populators in Configurator Developer		*/
	CURRENT_PROJECT INTEGER;
	CURRENT_POPULATOR INTEGER;

	FUNCTION PROJECT_ID RETURN INTEGER;
	PRAGMA RESTRICT_REFERENCES (PROJECT_ID, WNDS, WNPS);

	FUNCTION POPULATOR_ID RETURN INTEGER;
	PRAGMA RESTRICT_REFERENCES (POPULATOR_ID, WNDS, WNPS);

	PROCEDURE POP_VIEW_FILTER(PROJECT_ID IN INTEGER DEFAULT NULL,POPULATOR_ID IN INTEGER DEFAULT NULL);

/* Mechanisms for session-specific trigger disabling to optimize performance of
 * bulk project restructuring						*/
	PROJ_TIMESTAMP_TRIGGERS_ON boolean := TRUE;
	procedure ENABLE_PROJ_TIMESTAMP_TRIGS;
	procedure DISABLE_PROJ_TIMESTAMP_TRIGS;

	/* "manually" mark update fields on the project when triggers off */
	procedure STAMP_STRUCT_UPDATED (for_project_id in NUMBER);
	procedure STAMP_LOGIC_UPDATED (for_project_id in NUMBER);
	/* mark both struct and logic updated at once	*/
	procedure STAMP_PROJECT_UPDATED (for_project_id in NUMBER);

END CZ_SESSION;

 

/
