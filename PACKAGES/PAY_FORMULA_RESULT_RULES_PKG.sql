--------------------------------------------------------
--  DDL for Package PAY_FORMULA_RESULT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FORMULA_RESULT_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pyfrr.pkh 115.2 2002/12/10 18:44:49 dsaxby ship $ */
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function TARGET_PAY_VALUE (     p_element_type_id number,
                                p_result_data_type varchar2) return number;
--------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                         IN OUT NOCOPY VARCHAR2,
                     p_Formula_Result_Rule_Id        IN OUT NOCOPY NUMBER,
                     p_Effective_Start_Date                 DATE,
                     p_Effective_End_Date                   DATE,
                     p_Business_Group_Id                    NUMBER,
                     p_Legislation_Code                     VARCHAR2,
                     p_Element_Type_Id                      NUMBER,
                     p_Status_Processing_Rule_Id            NUMBER,
                     p_Result_Name                          VARCHAR2,
                     p_Result_Rule_Type                     VARCHAR2,
                     p_Legislation_Subgroup                 VARCHAR2,
                     p_Severity_Level                       VARCHAR2,
                     p_Input_Value_Id                       NUMBER,
                     p_Created_By                           NUMBER,
                     p_session_date                         DATE
                     );

--------------------------------------------------------------------------------
PROCEDURE Lock_Row(p_Rowid                                  VARCHAR2,
                   p_Formula_Result_Rule_Id                 NUMBER,
                   p_Effective_Start_Date                   DATE,
                   p_Effective_End_Date                     DATE,
                   p_Business_Group_Id                      NUMBER,
                   p_Legislation_Code                       VARCHAR2,
                   p_Element_Type_Id                        NUMBER,
                   p_Status_Processing_Rule_Id              NUMBER,
                   p_Result_Name                            VARCHAR2,
                   p_Result_Rule_Type                       VARCHAR2,
                   p_Legislation_Subgroup                   VARCHAR2,
                   p_Severity_Level                         VARCHAR2,
                   p_Input_Value_Id                         NUMBER);

--------------------------------------------------------------------------------
PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Formula_Result_Rule_Id              NUMBER,
                     p_Effective_Start_Date                DATE,
                     p_Effective_End_Date                  DATE,
                     p_Business_Group_Id                   NUMBER,
                     p_Legislation_Code                    VARCHAR2,
                     p_Element_Type_Id                     NUMBER,
                     p_Status_Processing_Rule_Id           NUMBER,
                     p_Result_Name                         VARCHAR2,
                     p_Result_Rule_Type                    VARCHAR2,
                     p_Legislation_Subgroup                VARCHAR2,
                     p_Severity_Level                      VARCHAR2,
                     p_Input_Value_Id                      NUMBER,
                     p_Last_Update_Date                    DATE,
                     p_Last_Updated_By                     NUMBER,
                     p_Last_Update_Login                   NUMBER);

--------------------------------------------------------------------------------
PROCEDURE Delete_Row(p_Rowid VARCHAR2);


--------------------------------------------------------------------------------
procedure PARENT_DELETED (
p_parent_name           varchar2,
p_parent_id             number,
p_session_date          date,
p_delete_mode           varchar2
);
--------------------------------------------------------------------------------
FUNCTION result_rule_end_date(p_formula_result_rule_id       number,
                              p_result_rule_type             varchar2,
                              p_result_name                  varchar2,
                              p_status_processing_rule_id    number,
                              p_element_type_id              number,
                              p_input_value_id               number,
                              p_session_date                 date,
                              p_max_spr_end_date             date) return date;
--------------------------------------------------------------------------------
FUNCTION formula_results_changed(p_formula_id                number,
                                 p_result_name               varchar2,
                                 p_result_rule_type          varchar2,
                                 p_effective_start_date      date,
                                 p_effective_end_date        date) return boolean;
--------------------------------------------------------------------------------
end PAY_FORMULA_RESULT_RULES_PKG;

 

/
