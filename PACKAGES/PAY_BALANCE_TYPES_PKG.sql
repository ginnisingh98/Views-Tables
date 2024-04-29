--------------------------------------------------------
--  DDL for Package PAY_BALANCE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: pyblt01t.pkh 120.0 2005/05/29 03:20:26 appldev noship $ */
--------------------------------------------------------------------------------
procedure validate_translation (balance_type_id IN    number,
				language IN             varchar2,
                                balance_name IN  varchar2,
				reporting_name IN varchar2);
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
				  p_legislation_code IN VARCHAR2);
-----------------------------------------------------------------------------
-- Name
--   chk_balance_category_rule
--
-- Purpose
--   Checks whether column balance_category_id is mandatory for the current
--   legislation. It will only be mandatory when the legislation delivers
--   the legislation rule row and an upgrade script for populating all balances
--   with a balance category.
-----------------------------------------------------------------------------
function chk_balance_category_rule
(p_legislation_code  varchar2
,p_business_group_id number default null
)
return boolean;
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_balance_type                                                      --
 -- Purpose                                                                 --
 --   Validates the balance type ie. unique name, only one remuneration     --
 --   balance etc ...                                                       --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure chk_balance_type
 (
  p_row_id                       varchar2,
  p_business_group_id            number,
  p_legislation_code             varchar2,
  p_balance_name                 varchar2,
  p_reporting_name               varchar2,
  p_assignment_remuneration_flag varchar2
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a balance via the --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Balance_Type_Id              IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Currency_Code                       VARCHAR2,
                      X_Assignment_Remuneration_Flag        VARCHAR2,
                      X_Balance_Name                        VARCHAR2,
-- --
                      X_Base_Balance_Name                   VARCHAR2,
-- --
                      X_Balance_Uom                         VARCHAR2,
                      X_Comments                            VARCHAR2,
                      X_Legislation_Subgroup                VARCHAR2,
                      X_Reporting_Name                      VARCHAR2,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      x_balance_category_id                 number default null,
                      x_base_balance_type_id                number default null,
                      x_input_value_id                      number default null);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a balance by applying a lock on a balance in the Define Balance    --
 --   Type form.                                                            --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Currency_Code                         VARCHAR2,
                    X_Assignment_Remuneration_Flag          VARCHAR2,
                    --X_Balance_Name                          VARCHAR2,
-- --
                    X_Base_Balance_Name                     VARCHAR2,
-- --
                    X_Balance_Uom                           VARCHAR2,
                    X_Comments                              VARCHAR2,
                    X_Legislation_Subgroup                  VARCHAR2,
                    X_Reporting_Name                        VARCHAR2,
                    X_Attribute_Category                    VARCHAR2,
                    X_Attribute1                            VARCHAR2,
                    X_Attribute2                            VARCHAR2,
                    X_Attribute3                            VARCHAR2,
                    X_Attribute4                            VARCHAR2,
                    X_Attribute5                            VARCHAR2,
                    X_Attribute6                            VARCHAR2,
                    X_Attribute7                            VARCHAR2,
                    X_Attribute8                            VARCHAR2,
                    X_Attribute9                            VARCHAR2,
                    X_Attribute10                           VARCHAR2,
                    X_Attribute11                           VARCHAR2,
                    X_Attribute12                           VARCHAR2,
                    X_Attribute13                           VARCHAR2,
                    X_Attribute14                           VARCHAR2,
                    X_Attribute15                           VARCHAR2,
                    X_Attribute16                           VARCHAR2,
                    X_Attribute17                           VARCHAR2,
                    X_Attribute18                           VARCHAR2,
                    X_Attribute19                           VARCHAR2,
                    X_Attribute20                           VARCHAR2,
                    x_balance_category_id                   number default null,
                    x_base_balance_type_id                  number default null,
                    x_input_value_id                        number default null);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a balance via the --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Currency_Code                       VARCHAR2,
                      X_Assignment_Remuneration_Flag        VARCHAR2,
                      X_Balance_Name                        VARCHAR2,
		      X_Base_Balance_Name                   VARCHAR2,
                      X_Balance_Uom                         VARCHAR2,
                      X_Comments                            VARCHAR2,
                      X_Legislation_Subgroup                VARCHAR2,
                      X_Reporting_Name                      VARCHAR2,
                      X_Attribute_Category                  VARCHAR2,
                      X_Attribute1                          VARCHAR2,
                      X_Attribute2                          VARCHAR2,
                      X_Attribute3                          VARCHAR2,
                      X_Attribute4                          VARCHAR2,
                      X_Attribute5                          VARCHAR2,
                      X_Attribute6                          VARCHAR2,
                      X_Attribute7                          VARCHAR2,
                      X_Attribute8                          VARCHAR2,
                      X_Attribute9                          VARCHAR2,
                      X_Attribute10                         VARCHAR2,
                      X_Attribute11                         VARCHAR2,
                      X_Attribute12                         VARCHAR2,
                      X_Attribute13                         VARCHAR2,
                      X_Attribute14                         VARCHAR2,
                      X_Attribute15                         VARCHAR2,
                      X_Attribute16                         VARCHAR2,
                      X_Attribute17                         VARCHAR2,
                      X_Attribute18                         VARCHAR2,
                      X_Attribute19                         VARCHAR2,
                      X_Attribute20                         VARCHAR2,
                      x_balance_category_id                 number default null,
                      x_base_balance_type_id                number default null,
                      x_input_value_id                      number default null);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a balance via the --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid            VARCHAR2,
		      -- Extra Columns
		      X_Balance_Type_Id  NUMBER);
--
------------------------------------------------------------------------------
 -- Name                                                                    --
 --   BALANACE_TYPE_CASCADE_DELETE                                                           --
 -- Purpose                                                                 --
 --   procedure that supports the cascade delete of a balance feed,
 --   balance classifications and defined balances.                         --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
 --
 procedure balance_type_cascade_delete
 (
    p_balance_type_id number
 );

--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   ADD_LANGUAGE                                                          --
 -- Purpose                                                                 --
 --   Table handler procedure for release 11.5 MLS (Multi-Lingual Support)  --
 -- Arguments                                                               --
 --   None.  								    --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
procedure ADD_LANGUAGE;
------------------------------------------------------------------------------
procedure TRANSLATE_ROW (
   X_B_BALANCE_NAME in VARCHAR2,
   X_B_LEGISLATION_CODE in VARCHAR2,
   X_BALANCE_NAME in VARCHAR2,
   X_REPORTING_NAME in VARCHAR2,
   X_OWNER in VARCHAR2
);
------------------------------------------------------------------------------
END PAY_BALANCE_TYPES_PKG;

 

/
