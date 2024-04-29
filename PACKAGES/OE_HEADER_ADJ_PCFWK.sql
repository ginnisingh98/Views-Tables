--------------------------------------------------------
--  DDL for Package OE_HEADER_ADJ_PCFWK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_HEADER_ADJ_PCFWK" AUTHID CURRENT_USER AS
/* $Header: OEXKHADS.pls 120.0 2005/06/01 00:12:46 appldev noship $ */

g_record  OE_AK_HEADER_PRCADJS_V%ROWTYPE;
-------------------------------------------
--  Start of Comments
--  API name    Is_Op_Constrained
--  Type        Public
--  Function
--     You should use this function to check for constraints
--     against operations on HEADER_ADJ or its columns
--  Pre-reqs
--
--  Parameters
--
--  Return
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
FUNCTION Is_Op_Constrained
 (
   p_responsibility_id             in number
   ,p_operation                    in varchar2
   ,p_column_name                  in varchar2 default NULL
   ,p_record                       in OE_AK_HEADER_PRCADJS_V%ROWTYPE
   ,p_check_all_cols_constraint    in varchar2 default 'Y'
   ,p_is_caller_defaulting         in varchar2 default 'N'
,x_constraint_id out nocopy number

,x_constraining_conditions_grp out nocopy number

,x_on_operation_action out nocopy number

 )
 RETURN NUMBER;

-------------------------------------------
END OE_HEADER_ADJ_PCFWK;

 

/
