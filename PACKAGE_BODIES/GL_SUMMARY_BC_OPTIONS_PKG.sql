--------------------------------------------------------
--  DDL for Package Body GL_SUMMARY_BC_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SUMMARY_BC_OPTIONS_PKG" AS
/* $Header: glistbcb.pls 120.4.12010000.1 2008/07/28 13:26:46 appldev ship $ */

--
-- PUBLIC FUNCTIONS
--

PROCEDURE Insert_Row(X_Rowid                  IN OUT NOCOPY       VARCHAR2,
                     X_Funds_Check_Level_Code              VARCHAR2,
                     X_Dr_Cr_Code                          VARCHAR2,
                     X_Amount_Type                         VARCHAR2,
                     X_Boundary_Code                       VARCHAR2,
                     X_Template_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_by                     NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Funding_Budget_Version_Id           NUMBER
                     ) IS

    CURSOR check_overlaps IS
    SELECT 'Overlap'
      FROM DUAL
     WHERE EXISTS
       (SELECT 'X'
          FROM gl_budgets b1,
               gl_budget_versions bv1,
               gl_summary_bc_options sa,
               gl_period_statuses pf1,
               gl_period_statuses pl1,
               gl_budgets b2,
               gl_budget_versions bv2,
               gl_period_statuses pf2,
               gl_period_statuses pl2
         WHERE b1.current_version_id = bv1.version_num
           AND b1.budget_name = bv1.budget_name
           AND bv1.budget_version_id = sa.funding_budget_version_id
           AND b1.first_valid_period_name = pf1.period_name
           AND b1.last_valid_period_name = pl1.period_name
           AND b2.current_version_id = bv2.version_num
           AND b2.budget_name = bv2.budget_name
           AND bv2.budget_version_id = x_funding_budget_version_id
           AND b2.first_valid_period_name = pf2.period_name
           AND b2.last_valid_period_name = pl2.period_name
           AND sa.template_id = X_Template_Id
           AND pf1.application_id = 101
           AND pf1.ledger_id = b1.ledger_id
           AND pl1.application_id = 101
           AND pl1.ledger_id = b1.ledger_id
           AND pf2.application_id = 101
           AND pf2.ledger_id = b2.ledger_id
           AND pl2.application_id = 101
           AND pl2.ledger_id = b2.ledger_id
           AND NOT (   (pl1.effective_period_num < pf2.effective_period_num)
                    OR (pf1.effective_period_num > pl2.effective_period_num)
                   )
       );



   CURSOR C IS
   SELECT rowid
     FROM gl_summary_bc_options
    WHERE template_id = X_Template_Id
      AND funding_budget_version_id = X_Funding_Budget_Version_Id;

    dummy VARCHAR2(100);
BEGIN

  OPEN check_overlaps;
  FETCH check_overlaps into dummy;
  IF check_overlaps%FOUND THEN
    CLOSE check_overlaps;
    fnd_message.set_name('SQLGL', 'GL_BC_BUDGET_OVERLAP');
    app_exception.raise_exception;
  ELSE
    CLOSE check_overlaps;
  END IF;

  INSERT INTO GL_SUMMARY_BC_OPTIONS(
        template_id,
        last_update_date,
        last_updated_by,
        funds_check_level_code,
        amount_type,
        boundary_code,
        created_by,
        creation_date,
        dr_cr_code,
        last_update_login,
        funding_budget_version_id)
   VALUES (
        X_Template_Id,
        X_Last_Update_Date,
        X_Last_Updated_By,
        X_Funds_Check_Level_Code,
        X_Amount_Type,
        X_Boundary_Code,
        X_Created_By,
        X_Creation_Date,
        X_Dr_Cr_Code,
        X_Last_Update_Login,
        X_Funding_Budget_Version_Id);

     OPEN C;
     FETCH C INTO X_Rowid;
     if (C%NOTFOUND) then
        CLOSE C;
        RAISE NO_DATA_FOUND;
     end if;
     CLOSE C;
END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                               VARCHAR2,
                   X_Funds_Check_Level_Code              VARCHAR2,
                   X_Dr_Cr_Code                          VARCHAR2,
                   X_Amount_Type                         VARCHAR2,
                   X_Boundary_Code                       VARCHAR2,
                   X_Template_Id                         NUMBER,
                   X_Last_Update_Date                    DATE,
                   X_Last_Updated_by                     NUMBER,
                   X_Created_By                          NUMBER,
                   X_Creation_Date                       DATE,
                   X_Last_Update_Login                   NUMBER,
                   X_Funding_Budget_Version_Id           NUMBER
                   ) IS
      CURSOR C IS
          SELECT *
          FROM GL_SUMMARY_BC_OPTIONS
          WHERE  rowid = X_Rowid
          FOR UPDATE of template_id NOWAIT;
      Recinfo  C%ROWTYPE;
BEGIN
      OPEN C;
      FETCH C INTO Recinfo;
      if (C%NOTFOUND) then
          CLOSE C;
          RAISE NO_DATA_FOUND;
      end if;
      CLOSE C;
      if(
             ( (Recinfo.template_id = X_Template_Id)
                OR (    (Recinfo.template_id IS NULL)
                    AND (X_Template_Id IS NULL)))
         AND ( (Recinfo.last_update_date = X_Last_Update_Date)
                OR (    (Recinfo.last_update_date IS NULL)
                    AND (X_Last_Update_Date IS NULL)))
         AND ( (Recinfo.last_updated_by = X_Last_Updated_By)
                OR (    (Recinfo.last_updated_by IS NULL)
                    AND (X_Last_Updated_By IS NULL)))
         AND ( (Recinfo.funds_check_level_code = X_Funds_Check_Level_Code)
                OR (    (Recinfo.funds_check_level_code IS NULL)
                    AND (X_Funds_Check_Level_Code IS NULL)))
         AND ( (Recinfo.amount_type = X_Amount_Type)
                OR (    (Recinfo.amount_type IS NULL)
                    AND (X_Amount_Type IS NULL)))
         AND ( (Recinfo.boundary_code = X_Boundary_Code)
                OR (    (Recinfo.boundary_code IS NULL)
                    AND (X_Boundary_Code IS NULL)))
         AND ( (Recinfo.created_by = X_Created_By)
                OR (    (Recinfo.created_by IS NULL)
                    AND (X_Created_By IS NULL)))
         AND ( (Recinfo.creation_date = X_Creation_Date)
                OR (    (Recinfo.creation_date IS NULL)
                    AND (X_Creation_Date IS NULL)))
         AND ( (Recinfo.dr_cr_code = X_Dr_Cr_Code)
                OR (    (Recinfo.dr_cr_code IS NULL)
                    AND (X_Dr_Cr_Code IS NULL)))
         AND ( (Recinfo.last_update_login = X_Last_Update_Login)
                OR (    (Recinfo.last_update_login IS NULL)
                    AND (X_Last_Update_Login IS NULL)))
         AND ( (Recinfo.funding_budget_version_id = X_Funding_Budget_Version_Id)
                OR (    (Recinfo.funding_budget_version_id IS NULL)
                    AND (X_Funding_Budget_Version_Id IS NULL)))
        ) then
         return;
    else
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
END Lock_Row;

PROCEDURE Insert_BC_Options(X_Rowid                  IN OUT NOCOPY       VARCHAR2,
                            X_Funds_Check_Level_Code              VARCHAR2,
                            X_Dr_Cr_Code                          VARCHAR2,
                            X_Amount_Type                         VARCHAR2,
                            X_Boundary_Code                       VARCHAR2,
                            X_Template_Id                         NUMBER,
                            X_Last_Update_Date                    DATE,
                            X_Last_Updated_by                     NUMBER,
                            X_Created_By                          NUMBER,
                            X_Creation_Date                       DATE,
                            X_Last_Update_Login                   NUMBER,
                            X_Funding_Budget_Version_Id           NUMBER
                           ) IS

 CURSOR check_funds_check_level IS
   SELECT 'X'
   FROM GL_LOOKUPS
   WHERE LOOKUP_TYPE = 'FUNDS_CHECK_LEVEL'
   AND lookup_code = X_Funds_Check_Level_Code;

 CURSOR check_amount_type IS
   SELECT 'X'
   FROM GL_LOOKUPS_AMOUNT_TYPES_V
   WHERE amount_type = X_Amount_Type;

 CURSOR check_boundary_code IS
   SELECT 'X'
   FROM GL_LOOKUPS_BOUNDARIES_V
   WHERE boundary_code = X_Boundary_Code;

 CURSOR check_budget_version IS
   SELECT 'X'
   FROM GL_BUDGET_VERSIONS
   WHERE budget_version_id = X_Funding_Budget_Version_Id;

 CURSOR check_dr_cr_code IS
   SELECT 'X'
   FROM GL_LOOKUPS
   WHERE LOOKUP_TYPE = 'DR_CR'
   AND lookup_code = X_Dr_Cr_Code;

 L_Budgetary_Control_Flag VARCHAR2(1);
 dummy VARCHAR2(80);

BEGIN


   -- Validate Funds Check Level
   IF (X_Funds_Check_Level_Code IN ('D', 'B')) THEN
     OPEN check_funds_check_level;
     FETCH check_funds_check_level INTO dummy;
     IF check_funds_check_level%NOTFOUND THEN
        CLOSE check_funds_check_level;
        fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
        fnd_message.set_token('VALUE', X_Funds_Check_Level_Code);
        fnd_message.set_token('ATTRIBUTE', 'FundsCheckLevelCode');
        app_exception.raise_exception;
     END IF;
     CLOSE check_funds_check_level;
   ELSIF (X_Funds_Check_Level_Code IS NULL) THEN
      fnd_message.set_name('SQLGL', 'GL_API_NULL_VALUE_ERROR');
      fnd_message.set_token('ATTRIBUTE', 'FundsCheckLevelCode');
      app_exception.raise_exception;
   ELSE
      fnd_message.set_name('SQLGL', 'GL_API_INVALID_VALUE');
      fnd_message.set_token('VALUE', X_Funds_Check_Level_Code);
      fnd_message.set_token('ATTRIBUTE', 'FundsCheckLevelCode');
      app_exception.raise_exception;
   END IF;

   -- Validate Amount Type
   IF (X_Amount_Type IS NOT NULL) THEN
     OPEN check_amount_type;
     FETCH check_amount_type INTO dummy;
     IF check_amount_type%NOTFOUND THEN
        CLOSE check_amount_type;
        fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
        fnd_message.set_token('VALUE', X_Amount_Type);
        fnd_message.set_token('ATTRIBUTE', 'AmountType');
        app_exception.raise_exception;
     END IF;
     CLOSE check_amount_type;
   ELSE
      fnd_message.set_name('SQLGL', 'GL_API_NULL_VALUE_ERROR');
      fnd_message.set_token('ATTRIBUTE', 'AmountType');
      app_exception.raise_exception;
   END IF;

   -- Validate Boundary Code
   IF (X_Boundary_Code IS NOT NULL) THEN
     OPEN check_boundary_code;
     FETCH check_boundary_code INTO dummy;
     IF check_boundary_code%NOTFOUND THEN
        CLOSE check_boundary_code;
        fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
        fnd_message.set_token('VALUE', X_Boundary_Code);
        fnd_message.set_token('ATTRIBUTE', 'BoundaryCode');
        app_exception.raise_exception;
     END IF;
     CLOSE check_boundary_code;
   ELSE
      fnd_message.set_name('SQLGL', 'GL_API_NULL_VALUE_ERROR');
      fnd_message.set_token('ATTRIBUTE', 'BoundaryCode');
      app_exception.raise_exception;
   END IF;

   -- Validate Budget Version
   IF (X_Funding_Budget_Version_Id IS NOT NULL) THEN
     OPEN check_budget_version;
     FETCH check_budget_version INTO dummy;
     IF check_budget_version%NOTFOUND THEN
        CLOSE check_budget_version;
        fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
        fnd_message.set_token('VALUE', X_Funding_Budget_Version_Id);
        fnd_message.set_token('ATTRIBUTE', 'FundingBudgetVersionId');
        app_exception.raise_exception;
     END IF;
     CLOSE check_budget_version;
   ELSE
      fnd_message.set_name('SQLGL', 'GL_API_NULL_VALUE_ERROR');
      fnd_message.set_token('ATTRIBUTE', 'FundingBudgetVersionId');
      app_exception.raise_exception;
   END IF;

   -- Validate Debit/Credit Code
   IF (X_Dr_Cr_Code IS NOT NULL) THEN
     OPEN check_dr_cr_code;
     FETCH check_dr_cr_code INTO dummy;
     IF check_dr_cr_code%NOTFOUND THEN
        CLOSE check_dr_cr_code;
        fnd_message.set_name('SQLGL', 'GL_API_VALUE_NOT_EXIST');
        fnd_message.set_token('VALUE', X_Dr_Cr_Code);
        fnd_message.set_token('ATTRIBUTE', 'DrCrCode');
        app_exception.raise_exception;
     END IF;
     CLOSE check_dr_cr_code;
   ELSE
      fnd_message.set_name('SQLGL', 'GL_API_NULL_VALUE_ERROR');
      fnd_message.set_token('ATTRIBUTE', 'DrCrCode');
      app_exception.raise_exception;
   END IF;

   SELECT gl1.enable_budgetary_control_flag
   INTO   L_Budgetary_Control_Flag
   FROM   gl_ledgers gl1, gl_summary_templates gl2
   WHERE  gl2.template_id = X_Template_Id
      AND gl1.ledger_id = gl2.ledger_id;


   -- Validate that funds check level code is D or B only if the set of
   -- books is budgetary control enabled.
   IF (X_Funds_Check_Level_Code = 'D' OR X_Funds_Check_Level_Code = 'B') THEN
      IF (L_Budgetary_Control_Flag = 'Y') THEN
         NULL;
      ELSE
         fnd_message.set_name('SQLGL', 'GL_API_SUMMTEMPL_FUNDS_LEVEL');
         app_exception.raise_exception;
      END IF;
   END IF;

   -- Validate that boundary code is a logical selection depending on the
   -- amount type
   IF (X_Amount_Type = 'PTD') THEN
      IF (X_Boundary_Code <> 'P') THEN
         fnd_message.set_name('SQLGL', 'GL_API_SUMMTEMPL_BOUNDARY_ERR');
         app_exception.raise_exception;
      END IF;
   ELSIF (X_Amount_Type = 'QTD') THEN
      IF (X_Boundary_Code NOT IN ('P', 'Q')) THEN
         fnd_message.set_name('SQLGL', 'GL_API_SUMMTEMPL_BOUNDARY_ERR');
         app_exception.raise_exception;
      END IF;
   ELSIF (X_Amount_Type = 'YTD') THEN
      IF (X_Boundary_Code NOT IN ('P', 'Q', 'Y')) THEN
         fnd_message.set_name('SQLGL', 'GL_API_SUMMTEMPL_BOUNDARY_ERR');
         app_exception.raise_exception;
      END IF;
   ELSIF (X_Amount_Type = 'PJTD') THEN
      -- Already checked boundary code is J, P, Q or Y
      NULL;
   END IF;

   Insert_Row(X_Rowid,
              X_Funds_Check_Level_Code,
              X_Dr_Cr_Code,
              X_Amount_Type,
              X_Boundary_Code,
              X_Template_Id,
              X_Last_Update_Date,
              X_Last_Updated_by,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
              X_Funding_Budget_Version_Id
             );


EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE',
                          'GL_SUMMARY_BC_OPTIONS_PKG.Insert_BC_Options');
    RAISE;

END Insert_BC_Options;

END gl_summary_bc_options_pkg;

/
