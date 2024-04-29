--------------------------------------------------------
--  DDL for Package BSC_DIM_TPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIM_TPLATE" AUTHID CURRENT_USER AS
/* $Header: BSCUDIMS.pls 115.4 2003/01/14 23:44:36 meastmon ship $ */

--
-- Global Variables
--

Type Acct_Type_Rec_Type Is Record (
	Code   		Number,
	Name		Varchar2(15)
);

TYPE Acct_Type_Tbl_Type IS TABLE OF Acct_Type_Rec_Type
 INDEX BY BINARY_INTEGER;

Type Acct_Rec_Type Is Record (
	Code   		Number,
	Name		Varchar2(15),
	Acct_Type	Number(5),
	Position	Number(2)
);

TYPE Acct_Tbl_Type IS TABLE OF Acct_Rec_Type
 INDEX BY BINARY_INTEGER;

BSC_DIM_ERROR		Exception;

/*===========================================================================+
|
|   Name:          Create_Dimensions
|
|   Description:   To create dimensions for Tab and Crosss templates
|                  Dimension for Tab template:
|			Account Type 	(P/L KPI)
|			Account		(P/L KPI)
|			Sub-Account	(P/L KPI)
|
|		   Dimensoion for Cross template:
|			Account Type	(P/L KPI)
|			Account		(P/L KPI)
|			Sub-Account	(P/L KPI)
|			Project		(Type 4 KPI)
|
|   History:
|     	02-APR-1999   Alex Yang             Created.
|    12/21/1999	  Henry Camacho	Modified to Model 4.0
+============================================================================*/

Function Create_Dimensions  Return Boolean;



/*===========================================================================+
|
|   Name:          Define_Dim_Relations
|
|   Description:   To configue dimension family and relation.
|                  The following tables store dimension metadata,
|
|                  * Dimension tables:
|
|	    		MPROJ_ENTITIES
|			MPROJ_ENTITIES_LANGUAGE
|    			MPROJ_ENTITIES_RELATIONS
|
|                  * Dimension family tables:
|
|			MPROJ_DRILLS_FAMILIES
|			MPROJ_DRILLS_FAMILIES_LANG
|			MPROJ_DRILLS_FAMILIES_ENT
|
|   Parameters:
|	x_num_of_levels		number of dimension levels
|	x_num_of_family		number of dimension families
|
|   History:
|     	02-APR-1999   Alex Yang             Created.
|    12/21/1999	  Henry Camacho	Modified to Model 4.0
+============================================================================*/
Function Define_Dim_Relations(
		x_num_of_levels		IN	Number,
		x_num_of_family		IN	Number
) Return Boolean;


END BSC_DIM_TPLATE;

 

/
