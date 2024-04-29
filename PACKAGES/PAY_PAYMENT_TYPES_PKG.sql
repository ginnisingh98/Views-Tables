--------------------------------------------------------
--  DDL for Package PAY_PAYMENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYMENT_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: pypyt01t.pkh 120.0.12010000.2 2009/07/12 10:18:55 namgoyal ship $ */


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Payment_Type_Id               IN OUT NOCOPY NUMBER,
                     X_Territory_Code                              VARCHAR2,
                     X_Currency_Code                               VARCHAR2,
                     X_Category                                    VARCHAR2,
                     X_Payment_Type_Name                           VARCHAR2,
-- --
                     X_Base_Payment_Type_Name                      VARCHAR2,
-- --
                     X_Allow_As_Default                            VARCHAR2,
                     X_Description                                 VARCHAR2,
                     X_Pre_Validation_Required                     VARCHAR2,
                     X_Procedure_Name                              VARCHAR2,
                     X_Validation_Days                             NUMBER,
                     X_Validation_Value                            VARCHAR2
                     );

procedure validate_translation (payment_type_id IN    number,
				language IN             varchar2,
                                payment_type_name IN  varchar2,
				description IN varchar2);

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Payment_Type_Id                        NUMBER,
                   X_Territory_Code                         VARCHAR2,
                   X_Currency_Code                          VARCHAR2,
                   X_Category                               VARCHAR2,
                   --X_Payment_Type_Name                    VARCHAR2,
-- --
                   X_Base_Payment_Type_Name                 VARCHAR2,
-- --
                   X_Allow_As_Default                       VARCHAR2,
                   X_Description                            VARCHAR2,
                   X_Pre_Validation_Required                VARCHAR2,
                   X_Procedure_Name                         VARCHAR2,
                   X_Validation_Days                        NUMBER,
                   X_Validation_Value                       VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Payment_Type_Id                     NUMBER,
                     X_Territory_Code                      VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Category                            VARCHAR2,
                     X_Payment_Type_Name                   VARCHAR2,
                     X_Allow_As_Default                    VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Pre_Validation_Required             VARCHAR2,
                     X_Procedure_Name                      VARCHAR2,
                     X_Validation_Days                     NUMBER,
                     X_Validation_Value                    VARCHAR2,
                     X_Base_Payment_Type_Name              VARCHAR2
                     );

--
-- X_payment_type added for deleting records from TL table
--
PROCEDURE Delete_Row(X_payment_type_id NUMBER, X_Rowid VARCHAR2);

-----------------------------------------------------------------------------
procedure ADD_LANGUAGE;
-----------------------------------------------------------------------------
procedure TRANSLATE_ROW(x_b_payment_type_name in VARCHAR2,
                   x_territory_code    in VARCHAR2,
                   x_payment_type_name in VARCHAR2,
                   x_owner             in VARCHAR2,
                   x_description       in VARCHAR2);
-----------------------------------------------------------------------------
procedure LOAD_ROW(x_b_payment_type_name in VARCHAR2,
                   x_territory_code    in VARCHAR2,
                   x_currency_code     in VARCHAR2,
                   x_category          in VARCHAR2,
                   x_allow_as_default  in VARCHAR2,
                   x_pre_validation_required     in VARCHAR2,
                   x_procedure_name    in VARCHAR2,
                   x_validation_days   in NUMBER,
                   x_validation_value  in VARCHAR2,
                   x_payment_type_name in VARCHAR2,
                   x_owner             in VARCHAR2,
                   x_description       in VARCHAR2,
		   x_reconciliation_function in VARCHAR2 default NULL);
-----------------------------------------------------------------------------
END PAY_PAYMENT_TYPES_PKG;

/
