--------------------------------------------------------
--  DDL for Package PAY_NET_CALCULATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NET_CALCULATION_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pyapncr.pkh 115.0 99/07/17 05:42:10 porting ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT VARCHAR2,

                     X_Net_Calculation_Rule_Id              IN OUT NUMBER,
                     X_Accrual_Plan_Id                      NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Input_Value_Id                       NUMBER,
                     X_Add_Or_Subtract                      VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Net_Calculation_Rule_Id                NUMBER,
                   X_Accrual_Plan_Id                        NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Input_Value_Id                         NUMBER,
                   X_Add_Or_Subtract                        VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Net_Calculation_Rule_Id             NUMBER,
                     X_Accrual_Plan_Id                     NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Add_Or_Subtract                     VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE DUP_INPUT_VALUE(p_accrual_plan_id         IN number,
                          p_input_value_id          IN number,
                          p_net_calculation_rule_id IN number);

END PAY_NET_CALCULATION_RULES_PKG;

 

/
