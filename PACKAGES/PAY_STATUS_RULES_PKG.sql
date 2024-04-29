--------------------------------------------------------
--  DDL for Package PAY_STATUS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_STATUS_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pyspr.pkh 115.5 2003/08/28 02:17:04 tbattoo ship $ */
--
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Status_Processing_Rule_Id     IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                 DATE,
                     X_Effective_End_Date                   DATE,
                     X_Business_Group_Id                    NUMBER,
                     X_Legislation_Code                     VARCHAR2,
                     X_Element_Type_Id                      NUMBER,
                     X_Assignment_Status_Type_Id            NUMBER,
                     X_Formula_Id                           NUMBER,
                     X_Processing_Rule                      VARCHAR2,
                     X_Comment_Id                           NUMBER,
                     X_Legislation_Subgroup                 VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Created_By                           NUMBER,
                     X_Creation_Date                        DATE);

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Status_Processing_Rule_Id              NUMBER,
                   X_Effective_Start_Date                   DATE,
                   X_Effective_End_Date                     DATE,
                   X_Business_Group_Id                      NUMBER,
                   X_Legislation_Code                       VARCHAR2,
                   X_Element_Type_Id                        NUMBER,
                   X_Assignment_Status_Type_Id              NUMBER,
                   X_Formula_Id                             NUMBER,
                   X_Processing_Rule                        VARCHAR2,
                   X_Comment_Id                             NUMBER,
                   X_Legislation_Subgroup                   VARCHAR2);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Status_Processing_Rule_Id           NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Legislation_Code                    VARCHAR2,
                     X_Element_Type_Id                     NUMBER,
                     X_Assignment_Status_Type_Id           NUMBER,
                     X_Formula_Id                          NUMBER,
                     X_Processing_Rule                     VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Legislation_Subgroup                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER);

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
			p_session_date date,
			p_delete_mode varchar2,
			p_status_processing_rule_id number);

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
	-- The value of the foreign key for the deleted parent
	p_element_type_id	number,
					--
	-- The date of date-effective deletion
	p_session_date	date		default trunc (sysdate),
					--
	-- The type of deletion action being performed
	p_delete_mode	varchar2	default 'DELETE'	);
--------------------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (p_status_processing_rule_id number,
					p_rowid	varchar2) return boolean;
--------------------------------------------------------------------------------
function SPR_END_DATE (p_status_processing_rule_id	number,
                       p_formula_id                     number) return date;
--------------------------------------------------------------------------------
function NO_INPUT_VALUES_MATCH_FORMULA (p_element_type_id 	number,
					p_formula_id 		number)
return boolean;
--------------------------------------------------------------------------------
function RESULT_RULES_EXIST (p_status_processing_rule_id	number,
				p_start_date	date,
				p_end_date	date) return boolean;
--------------------------------------------------------------------------------
function STATUS_RULE_END_DATE (p_status_processing_rule_id    number,
                               p_element_type_id              number,
                               p_formula_id                   number,
                               p_assignment_status_type_id    number,
                               p_processing_rule              varchar2,
                               p_session_date                 date,
                               p_max_element_end_date         date,
                               p_validation_start_date        date,
                               p_business_group_id            number,
                               p_legislation_code             varchar2) return date;
--------------------------------------------------------------------------------
end PAY_STATUS_RULES_PKG;

 

/
