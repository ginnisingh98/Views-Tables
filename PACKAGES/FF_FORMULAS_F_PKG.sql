--------------------------------------------------------
--  DDL for Package FF_FORMULAS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FORMULAS_F_PKG" AUTHID CURRENT_USER as
/* $Header: fffra01t.pkh 120.1 2005/07/29 04:55:20 shisriva noship $ */


Type FormulaRec is Record  (	formula_name         ff_formulas_f.formula_name%type,
				formula_type_id      ff_formulas_f.formula_type_id%type,
				business_group_id    ff_formulas_f.business_group_id%type,
				legislation_code     ff_formulas_f.legislation_code%type,
				effective_start_date date,
				effective_end_date   date);
-- ----------------------------------------------------------------------------
-- |                     Package Header Variable                              |
-- ----------------------------------------------------------------------------
--
g_dml_status boolean := FALSE;  -- Global package variable

 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   payroll_del_validation                                                --
 -- Purpose                                                                 --
 --   Provides referential integrity chacks for payroll tables using        --
 --   formula when a formula is deleted.                                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- History								    --
 --   13-Sep-04							            --
 --   Added parameter p_formula_details. Bug No 3703492.		    --
 -----------------------------------------------------------------------------
--
 procedure payroll_del_validation
 (
  p_formula_id            number,
  p_dt_delete_mode        varchar2,
  p_validation_start_date date,
  p_validation_end_date   date,
  p_Formula_Details       FormulaRec
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   payroll_dnc_validation                                                --
 -- Purpose                                                                 --
 --   Provides check for conflicting records when selecting delete next     --
 --   change or future change operations.
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- History								    --
 --   13-Sep-04							            --
 --   Added parameter p_formula_details. Bug No 3703492.		    --
 -----------------------------------------------------------------------------
--
 procedure payroll_dnc_validation
 (
  p_formula_id            number,
  p_dt_delete_mode        varchar2,
  p_validation_start_date date,
  p_validation_end_date   date,
  p_formula_details       FormulaRec
 );
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a formula via the --
 --   Write Formula form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   A check is made to ensure the formula name is unique.                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Formula_Id                   IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Formula_Type_Id                     NUMBER,
                      X_Formula_Name                 IN OUT NOCOPY VARCHAR2,
                      X_Description                         VARCHAR2,
                      X_Formula_Text                        VARCHAR2,
                      X_Sticky_Flag                         VARCHAR2,
                      X_Last_Update_Date             IN OUT NOCOPY DATE);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row (OVERLOADED)                                                 --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a formula in the Write Formula     --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This version checks each column to see if the formula has changed.    --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Formula_Id                            NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Formula_Type_Id                       NUMBER,
                    X_Formula_Name                          VARCHAR2,
                    X_Description                           VARCHAR2,
                    X_Formula_Text                          VARCHAR2,
                    X_Sticky_Flag                           VARCHAR2,
                    X_Base_Formula_Name              VARCHAR2 default NULL,
		    X_Base_Description                    VARCHAR2 default NULL);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row (OVERLOADED)                                                 --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a formula in the Write Formula     --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This version tests the last_update_date to see if the formula has     --
 --   changed.                                                              --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(x_rowid                                 VARCHAR2,
                    x_last_update_date                      DATE);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a formula via the --
 --   Write Formula form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Formula_Id                          NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Formula_Type_Id                     NUMBER,
		      X_Formula_Name                        VARCHAR2,
                      X_Description                         VARCHAR2,
                      X_Formula_Text                        VARCHAR2,
                      X_Sticky_Flag                         VARCHAR2,
                      X_Last_Update_Date             IN OUT NOCOPY DATE,
		      X_Base_Formula_Name              VARCHAR2 default hr_api.g_varchar2,
		      X_Base_Description                    VARCHAR2 default hr_api.g_varchar2);
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a formula via the --
 --   Write Formula form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Referential integrity checks are done against any payroll tables that --
 --   make use of formula.                                                  --
  -- History								    --
 --   13-Sep-04							            --
 --   Added parameter X_Effective_Date. Bug No 3703492.		            --
 --   16-Sep-04                                                             --
 --   Defaulted X_Effective_date to sysdate and changed the order of        --
 --   arguments.                                                            --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                 VARCHAR2,
		      -- Extra Columns
                      X_Formula_Id            NUMBER,
                      X_Dt_Delete_Mode        VARCHAR2,
                      X_Validation_Start_Date DATE,
                      X_Validation_End_Date   DATE,
		      X_Effective_Date        DATE default trunc(sysdate) );
--
---For MLS----------------------------------------------------------------------
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (  X_B_FORMULA_NAME	VARCHAR2,
			   X_B_LEGISLATION_CODE VARCHAR2,
			   X_FORMULA_NAME	VARCHAR2,
			   X_DESCRIPTION	VARCHAR2,
			   X_OWNER		VARCHAR2);

PROCEDURE set_translation_globals(p_business_group_id NUMBER,
                                  p_legislation_code  VARCHAR2);

procedure validate_translation(formula_id	NUMBER,
			       language		VARCHAR2,
			       formula_name	VARCHAR2,
			       description	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL);

function return_dml_status return boolean;
---
END FF_FORMULAS_F_PKG;

 

/
