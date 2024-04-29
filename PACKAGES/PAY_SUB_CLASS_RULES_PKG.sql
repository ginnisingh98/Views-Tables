--------------------------------------------------------
--  DDL for Package PAY_SUB_CLASS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SUB_CLASS_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pysbr.pkh 115.1 2003/06/27 12:17:25 scchakra ship $ */
--------------------------------------------------------------------------------
--Start of auto-generated code
--------------------------------------------------------------------------------
PROCEDURE Insert_Row(

		p_Rowid                         IN OUT NOCOPY VARCHAR2,
                p_Sub_Classification_Rule_Id    IN OUT NOCOPY NUMBER,
                p_Effective_Start_Date                 DATE,
                p_Effective_End_Date                   DATE,
                p_Element_Type_Id                      NUMBER,
                p_Classification_Id                    NUMBER,
                p_Business_Group_Id                    NUMBER,
                p_Legislation_Code                     VARCHAR2,
                p_Last_Update_Date                     DATE,
                p_Last_Updated_By                      NUMBER,
                p_Last_Update_Login                    NUMBER,
                p_Created_By                           NUMBER,
                p_Creation_Date                        DATE);

--------------------------------------------------------------------------------
PROCEDURE Lock_Row(p_Rowid                                  VARCHAR2,
                   p_Sub_Classification_Rule_Id             NUMBER,
                   p_Effective_Start_Date                   DATE,
                   p_Effective_End_Date                     DATE,
                   p_Element_Type_Id                        NUMBER,
                   p_Classification_Id                      NUMBER,
                   p_Business_Group_Id                      NUMBER,
                   p_Legislation_Code                       VARCHAR2);

--------------------------------------------------------------------------------
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Sub_Classification_Rule_Id          NUMBER,
                     p_Effective_Start_Date                DATE,
                     p_Effective_End_Date                  DATE,
                     p_Element_Type_Id                     NUMBER,
                     p_Classification_Id                   NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Legislation_Code                    VARCHAR2,
                     p_Last_Update_Date                    DATE,
                     p_Last_Updated_By                     NUMBER,
                     p_Last_Update_Login                   NUMBER);
--------------------------------------------------------------------------------
-- End of auto-generated code
--------------------------------------------------------------------------------
function next_rule_id return number;
--------------------------------------------------------------------------------
procedure INSERT_DEFAULTS (
--
p_element_type_id	number,
p_classification_id	number,
p_effective_start_date	date,
p_effective_end_date	date,
p_business_group_id	number,
p_legislation_code	varchar2	);
--------------------------------------------------------------------------------
procedure DELETE_ROW (
--
p_rowid                         varchar2,
p_sub_classification_rule_id    number,
p_delete_mode                   varchar2,
p_validation_start_date         date,
p_validation_end_date           date            );
--------------------------------------------------------------------------------
procedure PARENT_DELETED (
--
p_parent_id	number,
p_session_date	date		default trunc (sysdate),
p_validation_start_date date,
p_validation_end_date   date,
p_delete_mode	varchar2	default 'DELETE',
p_parent_name	varchar2	default 'PAY_ELEMENT_TYPES_F');
--------------------------------------------------------------------------------
function MAX_ALLOWABLE_END_DATE (
--
p_element_type_id		number,
p_classification_id		number,
p_session_date			date,
p_error_if_true			boolean	default FALSE	)
--
return date;
--------------------------------------------------------------------------------
end PAY_SUB_CLASS_RULES_PKG;

 

/
