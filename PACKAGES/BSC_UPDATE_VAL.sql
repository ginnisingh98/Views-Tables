--------------------------------------------------------
--  DDL for Package BSC_UPDATE_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_VAL" AUTHID CURRENT_USER AS
/* $Header: BSCDVALS.pls 120.0 2005/06/01 15:36:12 appldev noship $ */


/*===========================================================================+
|
|   Name:          Delete_Invalid_Zero_Codes
|
|   Description:   This function delete zero codes from base tables
|                  that are not used for precalculated indicators.

+============================================================================*/
FUNCTION Delete_Invalid_Zero_Codes(
	x_error_msg OUT NOCOPY VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Is_Table_For_PreCalc_Kpi
|
|   Description:   This function returns TRUE if the given table
|                  (input or base table) affects a precalculated indicator.
|
+============================================================================*/
FUNCTION Is_Table_For_PreCalc_Kpi(
	x_table IN VARCHAR2
	) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Validate_Codes
|
|   Description:   This function validates the user codes that come in the
|                  input table.
|                  If there are invalid codes then insert them into
|                  bsc_db_validation table.
|
|   Parameters:	   x_input_table   - input table name
|
|   Returns: 	   TRUE 	- input table doesn't have invalid codes
|                  FALSE	- input table has invalid codes
|		   NULL		- there was some error in the function. In
|                                 this case this function add the error
|                                 message in the error stack.
|   Notes:
|
+============================================================================*/
FUNCTION Validate_Codes(
	x_input_table IN VARCHAR2
	) RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Validate_Codes_AT(
	x_input_table IN VARCHAR2
	) RETURN BOOLEAN;


END BSC_UPDATE_VAL;

 

/
