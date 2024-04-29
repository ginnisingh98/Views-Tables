--------------------------------------------------------
--  DDL for Package PAY_DEFINED_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DEFINED_BALANCES_PKG" AUTHID CURRENT_USER as
/* $Header: pydfb01t.pkh 115.7 2004/01/06 07:06:06 rthirlby ship $ */
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_delete_defined_balance                                            --
 -- Purpose                                                                 --
 --   Check to see if it valid to remove a defined balance.                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure chk_delete_defined_balance
 (
  p_defined_balance_id number
 );
--
-----------------------------------------------------------------------------
-- function set_save_run_bals_flag
-- Description - sets the value of save_run_balance on pay_defined_balances,
-- the value is determined by the values of save_run_balance_enabled on
-- pay_balance_categories_f and pay_balance_dimensions.
-----------------------------------------------------------------------------
function set_save_run_bals_flag(p_balance_category_id  number
                               ,p_effective_date       date
                               ,p_balance_dimension_id number)
return varchar2;
-----------------------------------------------------------------------------
-- insert_default_attrib_wrapper
-- wrapper procedure insert_default_attributes used when not called directly
-- from forms.
-----------------------------------------------------------------------------
procedure insert_default_attrib_wrapper(p_balance_dimension_id number
                                       ,p_balance_category_id  number
                                       ,p_def_bal_bg_id        number
                                       ,p_def_bal_leg_code     varchar2
                                       ,p_defined_balance_id   number
                                       ,p_effective_date       date);
-----------------------------------------------------------------------------
-- procedure insert_default_attributes
-- Called directly when called from forms, or using the wrapper procedure
-- insert_default_attrib_wrapper when called from serverside code.
-----------------------------------------------------------------------------
procedure insert_default_attributes(p_balance_dimension_id number
                                   ,p_balance_category_id  number
                                   ,p_ctl_bg_id            number
                                   ,p_ctl_leg_code         varchar2
                                   ,p_ctl_sess_date        date
                                   ,p_defined_balance_id   number
                                   ,p_dfbl_bg_id           number
                                   ,p_dfbl_leg_code        varchar2);
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a defined         --
 --   balance via the Define Balance Type form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY VARCHAR2,
                      X_Defined_Balance_Id       IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id               NUMBER,
                      X_Legislation_Code                VARCHAR2,
                      X_Balance_Type_Id                 NUMBER,
                      X_Balance_Dimension_Id            NUMBER,
                      X_Force_Latest_Balance_Flag       VARCHAR2,
                      X_Legislation_Subgroup            VARCHAR2,
                      X_Grossup_Allowed_Flag            VARCHAR2 DEFAULT 'N',
                      x_balance_category_id             number default null,
                      x_effective_date                  date default null,
                      x_mode                            varchar2 default null);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a defined balance by applying a lock on a defined balance  in the  --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Defined_Balance_Id                    NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Balance_Dimension_Id                  NUMBER,
                    X_Force_Latest_Balance_Flag             VARCHAR2,
                    X_Legislation_Subgroup                  VARCHAR2,
                    X_Grossup_Allowed_Flag                  VARCHAR2 DEFAULT 'N');
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a defined         --
 --   balance via the Define Balance Type form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Defined_Balance_Id                  NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Balance_Dimension_Id                NUMBER,
                      X_Force_Latest_Balance_Flag           VARCHAR2,
                      X_Legislation_Subgroup                VARCHAR2,
                      X_Grossup_Allowed_Flag                VARCHAR2 DEFAULT 'N');
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a defined         --
 --   balance via the Define Balance Type form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid               VARCHAR2,
		      -- Extra Columns
		      X_Defined_Balance_Id  NUMBER);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   verify_save_run_bal_flag_upd                                          --
 -- Purpose                                                                 --
 --   Called from trigger pay_defined_balances_bru to prevent the update of --
 --   SAVE_RUN_BALANCE flag from 'Y' to 'N' or null, when valid run         --
 --   balances exist for the defined balance.
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 -----------------------------------------------------------------------------
 PROCEDURE verify_save_run_bal_flag_upd(p_defined_balance_id    number
                                       ,p_old_save_run_bal_flag varchar2
                                       ,p_new_save_run_bal_flag varchar2);
 --
 -----------------------------------------------------------------------------
END PAY_DEFINED_BALANCES_PKG;

 

/
