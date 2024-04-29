--------------------------------------------------------
--  DDL for Package PAY_LINK_INPUT_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LINK_INPUT_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: pyliv.pkh 115.0 99/07/17 06:15:50 porting ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
        Link Input Values Table Handler
Purpose
To interface with the entity while maintaining its data integrity
History

        27 Jan 94       N Simpson       Created				*/
--------------------------------------------------------------------------------
procedure DELETE_ROW (x_rowid	varchar2);
--------------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Link_Input_Value_Id                    NUMBER,
                   X_Effective_Start_Date                   DATE,
                   X_Effective_End_Date                     DATE,
                   X_Element_Link_Id                        NUMBER,
                   X_Input_Value_Id                         NUMBER,
                   X_Costed_Flag                            VARCHAR2,
                   X_Default_Value                          VARCHAR2,
                   X_Max_Value                              VARCHAR2,
                   X_Min_Value                              VARCHAR2,
                   X_Warning_Or_Error                       VARCHAR2);
--------------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Link_Input_Value_Id                 NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Element_Link_Id                     NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Costed_Flag                         VARCHAR2,
                     X_Default_Value                       VARCHAR2,
                     X_Max_Value                           VARCHAR2,
                     X_Min_Value                           VARCHAR2,
                     X_Warning_Or_Error                    VARCHAR2);
--------------------------------------------------------------------------------
procedure CREATE_LINK_INPUT_VALUE(
--
--******************************************************************************
--* Creates link input values for a new link.
--******************************************************************************
--
	p_element_link_id       number,
	p_costable_type	   	varchar2,
	p_effective_start_date 	date,
	p_effective_end_date   	date,
	p_element_type_id       number);
--------------------------------------------------------------------------------
procedure CREATE_LINK_INPUT_VALUE (
--
--******************************************************************************
--* Creates link input values for existing links when a new input value is     *
--* created at the type level.						       *
--******************************************************************************
--
	p_input_value_id	number,
	p_element_type_id	number,
	p_effective_start_date	date,
	p_effective_end_date	date,
	p_name			varchar2,
	p_hot_default_flag	varchar2,
	p_default_value		varchar2,
	p_min_value		varchar2,
	p_max_value		varchar2,
	p_warning_or_error	varchar2);
--------------------------------------------------------------------------------
procedure CHECK_REQUIRED_DEFAULTS (
--
p_element_link_id	number,
p_session_date		date);
--------------------------------------------------------------------------------
function NO_DEFAULT_AT_TYPE (
--
--******************************************************************************
--* Returns TRUE if there is no default value specified at the element type    *
--******************************************************************************
--
-- Parameters are:
--
	p_input_value_id	number,
	p_effective_start_date	date,
	p_effective_end_date	date,
	p_error_if_true		boolean default FALSE	) return boolean;
--------------------------------------------------------------------------------
procedure PARENT_DELETED (
--
--******************************************************************************
--* Handles the case when any row referenced by a foreign key of the base      *
--* is deleted (in whatever Date Track mode). ie If a parent record is zapped  *
--* then the deletion is cascaded; if it is date-effectively deleted, then the *
--* rows referencing it are updated to have the same end-date.		       *
--******************************************************************************
--
-- Parameters to be passed in are:
--
p_parent_id		number,-- The foreign key for the deleted parent
p_session_date		date		default trunc (sysdate),
p_validation_start_date	date,
p_validation_end_date	date,
p_delete_mode		varchar2,
p_parent_name		varchar2 );
--------------------------------------------------------------------------------
function LINK_END_DATE (p_link_id number) return date;
--
--******************************************************************************
--* Returns the end date of the Link.
--******************************************************************************
--------------------------------------------------------------------------------
end PAY_LINK_INPUT_VALUES_PKG;

 

/
