--------------------------------------------------------
--  DDL for Package GL_FLATTEN_SETUP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FLATTEN_SETUP_DATA" AUTHID CURRENT_USER AS
/* $Header: gluflsds.pls 120.6 2005/05/05 01:38:50 kvora noship $ */

-- *******************************************************************
-- Package level variables
-- *******************************************************************
GLSTFL_COA_ID		NUMBER		:= NULL;
GLSTFL_VS_ID		NUMBER		:= NULL;
GLSTFL_VS_TAB_NAME	VARCHAR2(240)	:= NULL;
GLSTFL_VS_COL_NAME      VARCHAR2(240)   := NULL;
GLSTFL_Op_Mode		VARCHAR2(2)	:= NULL;
GLSTFL_Debug		BOOLEAN		:= FALSE;
GLSTFL_User_Id		NUMBER		:= NULL;
GLSTFL_Login_Id		NUMBER		:= NULL;
GLSTFL_Req_Id		NUMBER		:= NULL;
GLSTFL_BAL_VS_ID	NUMBER		:= NULL;
GLSTFL_MGT_VS_ID	NUMBER		:= NULL;

-- ********************************************************************
-- Procedure
--   Main
-- Purpose
--   This is the main procedure of the flattening program.  It will take
--   in all parameters, initialize all necessary variables and start
--   calling the appropriate routines based on the mode of operation.
-- History
--   07-03-2001       	S Kung		Created
-- Arguments
--   X_Mode		Mode of operation, type VARCHAR2
--   X_Mode_Parameter	Depending on the mode of operation, this will
--			either be the chart of accounts ID or the flex
--			value set ID. It is of type NUMBER
--   X_Debug		Indicate if program is running in debug mode,
--			type VARCHAR2.  Default value is NULL.
-- Example
--   GL_FLATTEN_SETUP_DATA.Main('SH', 1002714, 'Y');
--

  PROCEDURE Main(X_Mode				VARCHAR2,
		 X_Mode_Parameter		VARCHAR2,
		 X_Debug			VARCHAR2 DEFAULT NULL);

-- ********************************************************************
-- Procedure
--   Main
-- Purpose
--   This is the concurrent job version of Main.  This will be used
--   when submitting the program through forms.
-- History
--   11-12-2001       	S Kung		Created
-- Arguments
--   errbuf		Standard error buffer
--   retcode 		Standard return code
--   X_Mode		Mode of operation, type VARCHAR2
--   X_Mode_Parameter	Depending on the mode of operation, this will
--			either be the chart of accounts ID or the flex
--			value set ID. It is of type NUMBER
--   X_Debug		Indicate if program is running in debug mode,
--			type VARCHAR2.  Default value is NULL.
-- Example
--   GL_FLATTEN_SETUP_DATA.Main(errbuf, retcode, 'SH', 1002714, 'Y');
--

  PROCEDURE Main(errbuf			OUT NOCOPY	VARCHAR2,
		 retcode		OUT NOCOPY	VARCHAR2,
		 X_Mode				VARCHAR2,
		 X_Mode_Parameter		VARCHAR2,
		 X_Debug			VARCHAR2 DEFAULT NULL);

-- ******************************************************************
-- Function
--   Clean_Up
-- Purpose
--   This is the main function for the final clean up phase.  This routine
--   will call the appropriate clean up routines depending on the mode of
--   operation.
-- History
--   07-09-2001		S Kung		Created
-- Arguments
--
-- Example
--   ret_status := GL_FLATTEN_SETUP_DATA.Clean_Up;
--

  FUNCTION  Clean_Up RETURN BOOLEAN;

-- *****************************************************************
-- Function
--   Get_Value_Set_Info
-- Purpose
--   This Function takes in the flex_value_set_id, then determine if
--   it is a table validated value set.  If that is the case, retrieve
--   the validation table and return it.
-- History
--   07-09-2001		S Kung		Created
-- Arguments
--   X_Vs_Id            	Flex_Value_set_id, type NUMBER
--   Table_Name			VARCHAR2 output paramter that contains the
--				table used for validating the value set.
-- Example
--   ret_status := GL_FLATTEN_SETUP_DATA.Get_Value_Set_Info
--		   (1002714, tab_validate, tab_name);
--

  FUNCTION  Get_Value_Set_Info(	X_Vs_Id			NUMBER,
				Table_Name	   OUT NOCOPY	VARCHAR2,
                                Column_Name	   OUT NOCOPY	VARCHAR2)
                                 RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Request_Lock
-- Purpose
--   This Function takes in a NUMBER type parameter, meaning of the parameter
--   (COA or VS) and the lock mode.  Then it construct a user named lock
--   and try to obtain a lock based on the lock mode.
-- History
--   07-10-2001		S Kung		Created
-- Arguments
--   X_Param_Type		Type VARCHAR2; C indicates it is a COA, while
--				V indicates it is a value set.
--   X_Param_Id			Type NUMBER; either the COA ID or value set ID.
--   X_Lock_Mode		Type INTEGER; lock mode for the lock
--   X_Keep_Looping		Type BOOLEAN; indicates if process should
-- 				keep looping when time out occurs
--   X_Max_Trys			Type NUMBER; maxium number of trials to
--				obtain the lock before aborting
-- Example
--   ret_status := GL_FLATTEN_SETUP_DATA.Request_Lock
--		   ('C', 101, 6, TRUE, 5);
--

  FUNCTION  Request_Lock(X_Param_Type		VARCHAR2,
			 X_Param_Id		NUMBER,
			 X_Lock_Mode		INTEGER,
			 X_Keep_Looping		BOOLEAN,
			 X_Max_Trys		NUMBER)
			RETURN BOOLEAN;

-- ******************************************************************
-- Function
--   Release_Lock
-- Purpose
--   This Function reconstruct the user named lock based on input
--   parameters, then release lock.
-- History
--   07-10-2001		S Kung		Created
-- Arguments
--   X_Param_Type		Type VARCHAR2.  C indicates it is a COA,
--				V indicates it is a value set.
--   X_Param_Id			Type NUMBER, either the COA ID or value set
-- 				ID.
-- Example
--   ret_status := GL_FLATTEN_SETUP_DATA.Release_Lock('C', 101);
--

  FUNCTION  Release_Lock(X_Param_Type		VARCHAR2,
			 X_Param_Id		NUMBER)
			RETURN BOOLEAN;

-- ******************************************************************


-- ******************************************************************
-- Function
--   GL_Flatten_Rule
-- Purpose
--   This Function will be used as a run function for the new
--   business event oracle.apps.fnd.flex.vst.hierarchy.compiled
-- History
--   10-Oct-2004       Srini pala		Created
-- Arguments
--   p_subscription_guid 	raw unique subscription id
--
--    p_event		        wf_event_t workflow business event
--
-- Example
--   ret_status := GL_FLATTEN_SETUP_DATA.GL_Flatten_Rule( );
--

  FUNCTION  GL_Flatten_Rule(
                         p_subscription_guid in     raw,
                         p_event             in out nocopy wf_event_t)
            RETURN VARCHAR2;


-- ******************************************************************

END GL_FLATTEN_SETUP_DATA;


 

/
