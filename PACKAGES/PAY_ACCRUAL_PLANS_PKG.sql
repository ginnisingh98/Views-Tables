--------------------------------------------------------
--  DDL for Package PAY_ACCRUAL_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACCRUAL_PLANS_PKG" AUTHID CURRENT_USER as
/* $Header: pyappap.pkh 115.0 99/07/17 05:42:24 porting ship $ */
--
PROCEDURE Insert_Row(X_Rowid                         IN OUT VARCHAR2,
                     X_Accrual_Plan_Id                      IN OUT NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Accrual_Plan_Element_Type_Id         NUMBER,
                     X_Pto_Input_Value_Id                   NUMBER,
                     X_Co_Input_Value_Id                    NUMBER,
                     X_Residual_Input_Value_Id              NUMBER,
                     X_Accrual_Category                     VARCHAR2,
                     X_Accrual_Plan_Name                    VARCHAR2,
                     X_Accrual_Start                        VARCHAR2,
                     X_Accrual_Units_Of_Measure             VARCHAR2,
                     X_Ineligible_Period_Length             NUMBER,
                     X_Ineligible_Period_Type               VARCHAR2
                     );
--
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Accrual_Plan_Id                        NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Accrual_Plan_Element_Type_Id           NUMBER,
                   X_Pto_Input_Value_Id                     NUMBER,
                   X_Co_Input_Value_Id                      NUMBER,
                   X_Residual_Input_Value_Id                NUMBER,
                   X_Accrual_Category                       VARCHAR2,
                   X_Accrual_Plan_Name                      VARCHAR2,
                   X_Accrual_Start                          VARCHAR2,
                   X_Accrual_Units_Of_Measure               VARCHAR2,
                   X_Ineligible_Period_Length               NUMBER,
                   X_Ineligible_Period_Type                 VARCHAR2
                   );
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Accrual_Plan_Id                     NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Accrual_Plan_Element_Type_Id        NUMBER,
                     X_Pto_Input_Value_Id                  NUMBER,
                     X_Co_Input_Value_Id                   NUMBER,
                     X_Residual_Input_Value_Id             NUMBER,
                     X_Accrual_Category                    VARCHAR2,
                     X_Accrual_Plan_Name                   VARCHAR2,
                     X_Accrual_Start                       VARCHAR2,
                     X_Accrual_Units_Of_Measure            VARCHAR2,
                     X_Ineligible_Period_Length            NUMBER,
                     X_Ineligible_Period_Type              VARCHAR2
                     );
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2);
--
PROCEDURE chk_plan_name(p_plan_name       IN varchar2,
                        p_accrual_plan_id IN number);
--
PROCEDURE insert_validation(p_plan_name       IN varchar2,
                            p_accrual_plan_id IN number);
--
FUNCTION create_element(
   p_element_name          IN varchar2,
   p_element_description   IN varchar2,
   p_processing_type       IN varchar2,
   p_bg_name               IN varchar2,
   p_classification_name   IN varchar2,
   p_legislation_code      IN varchar2,
   p_currency_code         IN varchar2,
   p_post_termination_rule IN varchar2)
   RETURN number;
--
FUNCTION create_input_value(
   p_element_name              IN varchar2,
   p_input_value_name          IN varchar2,
   p_uom_code                  IN varchar2,
   p_bg_name                   IN varchar2,
   p_element_type_id           IN number,
   p_primary_classification_id IN number,
   p_business_group_id         IN number,
   p_recurring_flag            IN varchar2,
   p_legislation_code          IN varchar2,
   p_classification_type       IN varchar2)
   RETURN number;
--
PROCEDURE pre_insert_actions(
   p_plan_name                    IN varchar2,
   p_bg_name                      IN varchar2,
   p_plan_uom                     IN varchar2,
   p_business_group_id            IN number,
   p_accrual_plan_element_type_id OUT number,
   p_co_input_value_id            OUT number,
   p_co_element_type_id           OUT number,
   p_residual_input_value_id      OUT number,
   p_residual_element_type_id     OUT number);
--
PROCEDURE post_insert_actions(
   p_accrual_plan_id    IN number,
   p_business_group_id  IN number,
   p_pto_input_value_id IN number,
   p_co_input_value_id  IN number);
--
PROCEDURE update_validation(p_plan_name       IN varchar2,
                            p_old_plan_name   IN varchar2,
                            p_accrual_plan_id IN number);
--
PROCEDURE post_update_actions(
   p_accrual_plan_id        IN number,
   p_business_group_id      IN number,
   p_pto_input_value_id     IN number,
   p_old_pto_input_value_id IN number);
--
PROCEDURE pre_delete_actions(p_accrual_plan_id              IN number,
                             p_accrual_plan_element_type_id IN number,
                             p_co_element_type_id           IN number,
                             p_residual_element_type_id     IN number,
                             p_session_date                 IN date);
END PAY_ACCRUAL_PLANS_PKG;

 

/
