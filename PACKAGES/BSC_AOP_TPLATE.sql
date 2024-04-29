--------------------------------------------------------
--  DDL for Package BSC_AOP_TPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AOP_TPLATE" AUTHID CURRENT_USER AS
/* $Header: BSCUAOPS.pls 115.4 2003/01/14 23:41:40 meastmon ship $ */

--
-- Global Variables
--

BSC_AOP_ERROR		Exception;

/*===========================================================================+
|
|   Name:          Create_Analysis_Options
|
|   Description:   To create analysis options for P and L KPI
|
|   History:
|     	02-APR-1999   Alex Yang             Created.
|    12/21/1999	  Henry Camacho	Modified to Model 4.0
+============================================================================*/

Function Create_Analysis_Options  Return Boolean;


/*===========================================================================+
|
|   Name:          Create_Option_Relations
|
|   Description:   To configue analysis options
|                  The following tables store analysis option metadata,
|
|                  * analysis option tables:
|
|	    		MPROJ_FIELDS
|			MSYS_UNIQUE_LIST_OF_VARS
|
|                  * operation field tables:
|
|			MPROJ_DATA
|			MPROJ_DATA_LANGUAGE
|			MPROJ_MPROJ_DATA_CALC
|
|   Parameters:
|	x_num_of_options	number of analysis options
|	x_num_of_data		number of data fields
|
|   History:
|     	02-APR-1999   Alex Yang             Created.
|    12/21/1999	  Henry Camacho	Modified to Model 4.0
+============================================================================*/
Function Create_Option_Relations(
		x_num_of_options	IN	Number,
		x_num_of_data		IN	Number
) Return Boolean;


END BSC_AOP_TPLATE;

 

/
