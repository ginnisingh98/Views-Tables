--------------------------------------------------------
--  DDL for Package Body FA_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_METHODS_PKG" as
/* $Header: faximtb.pls 120.8.12010000.3 2010/03/26 14:32:32 deemitta ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Method_Id                      IN OUT NOCOPY NUMBER,
                       X_Method_Code                    VARCHAR2,
                       X_Life_In_Months                 NUMBER DEFAULT NULL,
                       X_Depreciate_Lastyear_Flag       VARCHAR2,
                       X_Stl_Method_Flag                VARCHAR2,
                       X_Rate_Source_Rule               VARCHAR2,
                       X_Deprn_Basis_Rule               VARCHAR2,
                       X_Prorate_Periods_Per_Year       NUMBER DEFAULT NULL,
                       X_Name                           VARCHAR2 DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Attribute1                     VARCHAR2 DEFAULT NULL,
                       X_Attribute2                     VARCHAR2 DEFAULT NULL,
                       X_Attribute3                     VARCHAR2 DEFAULT NULL,
                       X_Attribute4                     VARCHAR2 DEFAULT NULL,
                       X_Attribute5                     VARCHAR2 DEFAULT NULL,
                       X_Attribute6                     VARCHAR2 DEFAULT NULL,
                       X_Attribute7                     VARCHAR2 DEFAULT NULL,
                       X_Attribute8                     VARCHAR2 DEFAULT NULL,
                       X_Attribute9                     VARCHAR2 DEFAULT NULL,
                       X_Attribute10                    VARCHAR2 DEFAULT NULL,
                       X_Attribute11                    VARCHAR2 DEFAULT NULL,
                       X_Attribute12                    VARCHAR2 DEFAULT NULL,
                       X_Attribute13                    VARCHAR2 DEFAULT NULL,
                       X_Attribute14                    VARCHAR2 DEFAULT NULL,
                       X_Attribute15                    VARCHAR2 DEFAULT NULL,
                       X_Attribute_Category_Code        VARCHAR2 DEFAULT NULL,
                       X_Exclude_Salvage_Value_Flag     VARCHAR2 DEFAULT 'NO',
 -- alternative flat depreciation calculation.   added for 11.5.2
          	       X_Deprn_Basis_Formula            VARCHAR2 DEFAULT NULL,
                       X_Polish_Adj_Calc_Basis_Flag     VARCHAR2 DEFAULT NULL,
                       X_Guarantee_Rate_Method_Flag     VARCHAR2 DEFAULT NULL,
                       X_Calling_Fn			VARCHAR2,
 -- For Depreciable Basis Formula
		       X_Deprn_Basis_Rule_Id		NUMBER DEFAULT NULL,
		       x_jp_imp_calc_basis_flag         VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS SELECT rowid FROM fa_methods
                 WHERE method_id = X_Method_Id;
      CURSOR C2 IS SELECT fa_methods_s.nextval FROM sys.dual;

   BEGIN

      if (X_Method_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Method_Id;
        CLOSE C2;
      end if;

       INSERT INTO fa_methods(
              method_id,
              method_code,
              life_in_months,
              depreciate_lastyear_flag,
              stl_method_flag,
              rate_source_rule,
              deprn_basis_rule,
              prorate_periods_per_year,
              name,
              last_update_date,
              last_updated_by,
              created_by,
              creation_date,
              last_update_login,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              attribute_category_code,
              exclude_salvage_value_flag,
              deprn_basis_formula,
	      deprn_basis_rule_id,
              polish_adj_calc_basis_flag,
              guarantee_rate_method_flag,
	      jp_imp_calc_basis_flag
             ) VALUES (
              X_Method_Id,
              X_Method_Code,
              X_Life_In_Months,
              X_Depreciate_Lastyear_Flag,
              X_Stl_Method_Flag,
              X_Rate_Source_Rule,
              X_Deprn_Basis_Rule,
              X_Prorate_Periods_Per_Year,
              X_Name,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Created_By,
              X_Creation_Date,
              X_Last_Update_Login,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Attribute_Category_Code,
              X_Exclude_Salvage_Value_Flag,
              X_Deprn_Basis_Formula,
	      X_Deprn_Basis_Rule_Id,
              X_Polish_Adj_Calc_Basis_Flag,
              X_Guarantee_Rate_Method_Flag,
	      x_jp_imp_calc_basis_flag
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    -- Fix for Bug #3810332.  Need to be more specific when updating the
    -- basis rules to prevent deadlock.
    if ((X_Rate_Source_Rule = 'FLAT') and
        (X_Deprn_Basis_Rule = 'NBV') and
        (nvl(X_Deprn_Basis_Formula, 'STRICT_FLAT') = 'STRICT_FLAT') and
        (X_Deprn_Basis_Rule_Id is null)) then

       -- For Depreciable Basis Formula logic
       UPDATE fa_methods
       SET deprn_basis_rule_id =
          (SELECT deprn_basis_rule_id
           FROM   fa_deprn_basis_rules
           WHERE  RULE_NAME='TRANSACTION')
       WHERE rate_source_rule='FLAT'
       AND deprn_basis_rule='NBV'
       AND deprn_basis_formula IS NULL
       AND deprn_basis_rule_id IS NULL
       AND method_id = X_Method_Id;

       UPDATE fa_methods
       SET deprn_basis_rule_id =
          (SELECT deprn_basis_rule_id
           FROM   fa_deprn_basis_rules
           WHERE  RULE_NAME='FYBEGIN')
       WHERE rate_source_rule='FLAT'
       AND deprn_basis_rule='NBV'
       AND deprn_basis_formula ='STRICT_FLAT'
       AND deprn_basis_rule_id IS NULL
       AND method_id = X_Method_Id;

    end if;

  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_methods_pkg.insert_row', p_log_level_rec => p_log_level_rec);

      FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_methods_pkg.insert_row',
                CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Method_Id                        NUMBER,
                     X_Method_Code                      VARCHAR2,
                     X_Life_In_Months                   NUMBER DEFAULT NULL,
                     X_Depreciate_Lastyear_Flag         VARCHAR2,
                     X_Stl_Method_Flag                  VARCHAR2,
                     X_Rate_Source_Rule                 VARCHAR2,
                     X_Deprn_Basis_Rule                 VARCHAR2,
                     X_Prorate_Periods_Per_Year         NUMBER DEFAULT NULL,
                     X_Name                             VARCHAR2 DEFAULT NULL,
                     X_Attribute1                       VARCHAR2 DEFAULT NULL,
                     X_Attribute2                       VARCHAR2 DEFAULT NULL,
                     X_Attribute3                       VARCHAR2 DEFAULT NULL,
                     X_Attribute4                       VARCHAR2 DEFAULT NULL,
                     X_Attribute5                       VARCHAR2 DEFAULT NULL,
                     X_Attribute6                       VARCHAR2 DEFAULT NULL,
                     X_Attribute7                       VARCHAR2 DEFAULT NULL,
                     X_Attribute8                       VARCHAR2 DEFAULT NULL,
                     X_Attribute9                       VARCHAR2 DEFAULT NULL,
                     X_Attribute10                      VARCHAR2 DEFAULT NULL,
                     X_Attribute11                      VARCHAR2 DEFAULT NULL,
                     X_Attribute12                      VARCHAR2 DEFAULT NULL,
                     X_Attribute13                      VARCHAR2 DEFAULT NULL,
                     X_Attribute14                      VARCHAR2 DEFAULT NULL,
                     X_Attribute15                      VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category_Code          VARCHAR2 DEFAULT NULL,
                     X_Exclude_Salvage_Value_Flag       VARCHAR2 DEFAULT 'NO',
  -- added for alternative flat depreciation calcuation.   for 11.5.2
                     X_Deprn_Basis_Formula              VARCHAR2 DEFAULT NULL,
                     X_Polish_Adj_Calc_Basis_Flag       VARCHAR2 DEFAULT NULL,
                     X_Guarantee_Rate_Method_Flag       VARCHAR2 DEFAULT NULL,
		     X_Calling_Fn			VARCHAR2,
  -- added for Depreciable Basis Formula
	             X_Deprn_Basis_Rule_Id		NUMBER DEFAULT NULL,
                     x_jp_imp_calc_basis_flag           VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT	method_id,
		method_code,
		life_in_months,
		depreciate_lastyear_flag,
		stl_method_flag,
		rate_source_rule,
		deprn_basis_rule,
		prorate_periods_per_year,
		name,
		last_update_date,
		last_updated_by,
		created_by,
		creation_date,
		last_update_login,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
		attribute12,
		attribute13,
		attribute14,
		attribute15,
		attribute_category_code,
                deprn_basis_formula,
		exclude_salvage_value_flag,
	        deprn_basis_rule_id,
                polish_adj_calc_basis_flag,
                guarantee_rate_method_flag,
		jp_imp_calc_basis_flag
        FROM   fa_methods
        WHERE  method_code = X_Method_Code
        AND    ((life_in_months = X_Life_In_Months) or
                ((life_in_months is null) and (X_Life_In_Months is null)))
        FOR UPDATE of Method_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.method_id =  X_Method_Id)
           AND (Recinfo.method_code =  X_Method_Code)
           AND (   (Recinfo.life_in_months =  X_Life_In_Months)
                OR (    (Recinfo.life_in_months IS NULL)
                    AND (X_Life_In_Months IS NULL)))
           AND (Recinfo.depreciate_lastyear_flag =  X_Depreciate_Lastyear_Flag)
           AND (Recinfo.stl_method_flag =  X_Stl_Method_Flag)
           AND (Recinfo.rate_source_rule =  X_Rate_Source_Rule)
           AND (Recinfo.deprn_basis_rule =  X_Deprn_Basis_Rule)
           AND (   (Recinfo.prorate_periods_per_year =
	       X_Prorate_Periods_Per_Year)
                OR (    (Recinfo.prorate_periods_per_year IS NULL)
                    AND (X_Prorate_Periods_Per_Year IS NULL)))
           AND (   (Recinfo.name =  X_Name)
                OR (    (Recinfo.name IS NULL)
                    AND (X_Name IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.attribute_category_code =  X_Attribute_Category_Code
)
                OR (    (Recinfo.attribute_category_code IS NULL)
                    AND (X_Attribute_Category_Code IS NULL)))
           AND (   (Recinfo.exclude_salvage_value_flag =  X_Exclude_Salvage_Value_Flag)
                OR (    (Recinfo.exclude_salvage_value_flag IS NULL)
                    AND (X_Exclude_Salvage_Value_Flag IS NULL)))
           AND (   (Recinfo.deprn_basis_formula = X_Deprn_Basis_Formula)
                OR (    (Recinfo.deprn_basis_formula IS NULL)
                    AND (X_Deprn_Basis_Formula is NULL)))
           AND (   (Recinfo.deprn_basis_rule_id = X_Deprn_Basis_Rule_Id)
                OR (    (Recinfo.deprn_basis_rule_id IS NULL)
                    AND (X_Deprn_Basis_Rule_Id is NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Method_Id                      NUMBER,
                       X_Method_Code                    VARCHAR2,
                       X_Life_In_Months                 NUMBER,
                       X_Depreciate_Lastyear_Flag       VARCHAR2,
                       X_Stl_Method_Flag                VARCHAR2,
                       X_Rate_Source_Rule               VARCHAR2,
                       X_Deprn_Basis_Rule               VARCHAR2,
                       X_Prorate_Periods_Per_Year       NUMBER,
                       X_Name                           VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute_Category_Code        VARCHAR2,
                       X_Exclude_Salvage_Value_Flag	VARCHAR2,
 -- added for alternative flat rate depreciation calculation.   for 11.5.2
                       X_Deprn_Basis_Formula            VARCHAR2,
                       X_Polish_Adj_Calc_Basis_Flag     VARCHAR2,
                       X_Guarantee_Rate_Method_Flag     VARCHAR2,
		       X_Calling_Fn			VARCHAR2,
 -- added for Depreciable Basis Formula
		       X_Deprn_Basis_Rule_Id		NUMBER DEFAULT NULL,
		       x_jp_imp_calc_basis_flag         VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    -- Split into separate statements for performance reasons.
    if (X_Life_In_Months is not null) then

       UPDATE fa_methods
       SET
       depreciate_lastyear_flag        =     X_Depreciate_Lastyear_Flag,
       stl_method_flag                 =     X_Stl_Method_Flag,
       rate_source_rule                =     X_Rate_Source_Rule,
       deprn_basis_rule                =     X_Deprn_Basis_Rule,
       prorate_periods_per_year        =     X_Prorate_Periods_Per_Year,
       name                            =     X_Name,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       attribute_category_code         =     X_Attribute_Category_Code,
       exclude_salvage_value_flag      =     X_Exclude_Salvage_Value_Flag,
       deprn_basis_formula             =     X_Deprn_Basis_Formula,
       polish_adj_calc_basis_flag      =     X_Polish_Adj_Calc_Basis_Flag,
       guarantee_rate_method_flag      =     X_Guarantee_Rate_Method_Flag,
       deprn_basis_rule_id	       =     X_Deprn_Basis_Rule_Id,
       jp_imp_calc_basis_flag          =     x_jp_imp_calc_basis_flag
       WHERE method_code = X_Method_Code
       AND   life_in_months = X_Life_In_Months;

       if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
       end if;

       -- Fix for Bug #3810332.  Need to be more specific when updating the
       -- basis rules to prevent deadlock.
       if ((X_Rate_Source_Rule = 'FLAT') and
           (X_Deprn_Basis_Rule = 'NBV') and
           (nvl(X_Deprn_Basis_Formula, 'STRICT_FLAT') = 'STRICT_FLAT') and
           (X_Deprn_Basis_Rule_Id is null)) then

          -- For Depreciable Basis Formula logic
          UPDATE fa_methods
          SET deprn_basis_rule_id =
             (SELECT deprn_basis_rule_id
              FROM   fa_deprn_basis_rules
              WHERE  RULE_NAME='TRANSACTION')
          WHERE rate_source_rule='FLAT'
          AND deprn_basis_rule='NBV'
          AND deprn_basis_formula IS NULL
          AND deprn_basis_rule_id IS NULL
          AND method_code = X_Method_Code
          AND life_in_months = X_Life_In_Months;

          UPDATE fa_methods
          SET deprn_basis_rule_id =
             (SELECT deprn_basis_rule_id
              FROM   fa_deprn_basis_rules
              WHERE  RULE_NAME='FYBEGIN')
          WHERE rate_source_rule='FLAT'
          AND deprn_basis_rule='NBV'
          AND deprn_basis_formula ='STRICT_FLAT'
          AND deprn_basis_rule_id IS NULL
          AND method_code = X_Method_Code
          AND life_in_months = X_Life_In_Months;

       end if;
    else

       UPDATE fa_methods
       SET
       depreciate_lastyear_flag        =     X_Depreciate_Lastyear_Flag,
       stl_method_flag                 =     X_Stl_Method_Flag,
       rate_source_rule                =     X_Rate_Source_Rule,
       deprn_basis_rule                =     X_Deprn_Basis_Rule,
       prorate_periods_per_year        =     X_Prorate_Periods_Per_Year,
       name                            =     X_Name,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       attribute_category_code         =     X_Attribute_Category_Code,
       exclude_salvage_value_flag      =     X_Exclude_Salvage_Value_Flag,
       deprn_basis_formula             =     X_Deprn_Basis_Formula,
       polish_adj_calc_basis_flag      =     X_Polish_Adj_Calc_Basis_Flag,
       guarantee_rate_method_flag      =     X_Guarantee_Rate_Method_Flag,
       deprn_basis_rule_id	       =     X_Deprn_Basis_Rule_Id,
       jp_imp_calc_basis_flag          =     x_jp_imp_calc_basis_flag
       WHERE method_code = X_Method_Code
       AND   life_in_months is null;

       if (SQL%NOTFOUND) then
         Raise NO_DATA_FOUND;
       end if;

       -- Fix for Bug #3810332.  Need to be more specific when updating the
       -- basis rules to prevent deadlock.
       if ((X_Rate_Source_Rule = 'FLAT') and
           (X_Deprn_Basis_Rule = 'NBV') and
           (nvl(X_Deprn_Basis_Formula, 'STRICT_FLAT') = 'STRICT_FLAT') and
           (X_Deprn_Basis_Rule_Id is null)) then

          -- For Depreciable Basis Formula logic
          UPDATE fa_methods
          SET deprn_basis_rule_id =
             (SELECT deprn_basis_rule_id
              FROM   fa_deprn_basis_rules
              WHERE  RULE_NAME='TRANSACTION')
          WHERE rate_source_rule='FLAT'
          AND deprn_basis_rule='NBV'
          AND deprn_basis_formula IS NULL
          AND deprn_basis_rule_id IS NULL
          AND method_code = X_Method_Code
          AND life_in_months is null;

          UPDATE fa_methods
          SET deprn_basis_rule_id =
             (SELECT deprn_basis_rule_id
              FROM   fa_deprn_basis_rules
              WHERE  RULE_NAME='FYBEGIN')
          WHERE rate_source_rule='FLAT'
          AND deprn_basis_rule='NBV'
          AND deprn_basis_formula ='STRICT_FLAT'
          AND deprn_basis_rule_id IS NULL
          AND method_code = X_Method_Code
          AND life_in_months is null;

       end if;
    end if;

  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_methods_pkg.update_row', p_log_level_rec => p_log_level_rec);

      FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_methods_pkg.update_row',
                CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
		       X_Calling_Fn VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN
    DELETE FROM fa_methods
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_methods_pkg.delete_row', p_log_level_rec => p_log_level_rec);

      FA_STANDARD_PKG.RAISE_ERROR(
                CALLED_FN => 'fa_methods_pkg.delete_row',
                CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);

end DELETE_ROW;

procedure LOAD_ROW (
   X_METHOD_ID in NUMBER,
   X_OWNER in VARCHAR2,
   X_METHOD_CODE in VARCHAR2,
   X_LIFE_IN_MONTHS in NUMBER,
   X_DEPRECIATE_LASTYEAR_FLAG in VARCHAR2,
   X_STL_METHOD_FLAG in VARCHAR2,
   X_RATE_SOURCE_RULE in VARCHAR2,
   X_DEPRN_BASIS_RULE in VARCHAR2,
   X_PRORATE_PERIODS_PER_YEAR in NUMBER,
   X_NAME in VARCHAR2,
   X_ATTRIBUTE1 in VARCHAR2,
   X_ATTRIBUTE2 in VARCHAR2,
   X_ATTRIBUTE3 in VARCHAR2,
   X_ATTRIBUTE4 in VARCHAR2,
   X_ATTRIBUTE5 in VARCHAR2,
   X_ATTRIBUTE6 in VARCHAR2,
   X_ATTRIBUTE7 in VARCHAR2,
   X_ATTRIBUTE8 in VARCHAR2,
   X_ATTRIBUTE9 in VARCHAR2,
   X_ATTRIBUTE10 in VARCHAR2,
   X_ATTRIBUTE11 in VARCHAR2,
   X_ATTRIBUTE12 in VARCHAR2,
   X_ATTRIBUTE13 in VARCHAR2,
   X_ATTRIBUTE14 in VARCHAR2,
   X_ATTRIBUTE15 in VARCHAR2,
   X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
   X_EXCLUDE_SALVAGE_VALUE_FLAG in VARCHAR2,
-- added for alternative flat depreciatio calculation.   for 11.5.2
   X_DEPRN_BASIS_FORMULA in VARCHAR2,
   X_POLISH_ADJ_CALC_BASIS_FLAG in VARCHAR2,
   X_GUARANTEE_RATE_METHOD_FLAG in VARCHAR2,
-- added for Depreciable Basis Formula
   X_DEPRN_BASIS_RULE_ID in NUMBER DEFAULT NULL,
   X_JP_IMP_CALC_BASIS_FLAG IN VARCHAR2 DEFAULT NULL
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  h_record_exists	number(15);
  h_method_id		number(15);

  user_id       	number;
  row_id		varchar2(64);

begin

  h_method_id := X_Method_Id;

  if (X_Owner = 'SEED') then
     user_id := 1;
  else
     user_id := 0;
  end if;

  if (X_Life_In_Months is not null) then

     select count(*)
     into  h_record_exists
     from  fa_methods
     where method_code = X_Method_Code
     and   life_in_months = X_Life_In_Months;

  else

     select count(*)
     into  h_record_exists
     from  fa_methods
     where method_code = X_Method_Code
     and   life_in_months is null;

  end if;

if (h_record_exists > 0 ) then
  fa_methods_pkg.update_row (
    X_Rowid                             => row_id,
    X_Method_ID				=> h_method_id,
    X_Method_Code			=> X_Method_Code,
    X_Life_In_Months			=> X_Life_In_Months,
    X_Depreciate_Lastyear_Flag		=> X_Depreciate_Lastyear_Flag,
    X_Stl_Method_Flag			=> X_Stl_Method_Flag,
    X_Rate_Source_Rule			=> X_Rate_Source_Rule,
    X_Deprn_Basis_Rule			=> X_Deprn_Basis_Rule,
    X_Prorate_Periods_Per_Year		=> X_Prorate_Periods_Per_Year,
    X_Name				=> X_Name,
    X_Last_Update_Date			=> sysdate,
    X_Last_Updated_By			=> user_id,
    X_Last_Update_Login			=> 0,
    X_Attribute1			=> X_Attribute1,
    X_Attribute2			=> X_Attribute2,
    X_Attribute3			=> X_Attribute3,
    X_Attribute4			=> X_Attribute4,
    X_Attribute5			=> X_Attribute5,
    X_Attribute6			=> X_Attribute6,
    X_Attribute7			=> X_Attribute7,
    X_Attribute8			=> X_Attribute8,
    X_Attribute9			=> X_Attribute9,
    X_Attribute10			=> X_Attribute10,
    X_Attribute11			=> X_Attribute11,
    X_Attribute12			=> X_Attribute12,
    X_Attribute13			=> X_Attribute13,
    X_Attribute14			=> X_Attribute14,
    X_Attribute15			=> X_Attribute15,
    X_Attribute_Category_Code		=> X_Attribute_Category_Code,
    X_Exclude_Salvage_Value_Flag	=> X_Exclude_Salvage_Value_Flag,
    X_Deprn_Basis_Formula               => X_Deprn_Basis_Formula,
    X_Polish_Adj_Calc_Basis_Flag        => X_Polish_Adj_Calc_Basis_Flag,
    X_Guarantee_Rate_Method_Flag        => X_Guarantee_Rate_Method_Flag,
    X_Calling_Fn			=> 'fa_methods_pkg.load_row',
    X_Deprn_Basis_Rule_Id		=> X_Deprn_Basis_Rule_Id,
    x_jp_imp_calc_basis_flag            => x_jp_imp_calc_basis_flag
, p_log_level_rec => p_log_level_rec);
else

  h_method_id := null;

  fa_methods_pkg.insert_row (
    X_Rowid				=> row_id,
    X_Method_ID				=> h_method_id,
    X_Method_Code                       => X_Method_Code,
    X_Life_In_Months                    => X_Life_In_Months,
    X_Depreciate_Lastyear_Flag          => X_Depreciate_Lastyear_Flag,
    X_Stl_Method_Flag                   => X_Stl_Method_Flag,
    X_Rate_Source_Rule                  => X_Rate_Source_Rule,
    X_Deprn_Basis_Rule                  => X_Deprn_Basis_Rule,
    X_Prorate_Periods_Per_Year          => X_Prorate_Periods_Per_Year,
    X_Name                              => X_Name,
    X_Last_Update_Date                  => sysdate,
    X_Last_Updated_By                   => user_id,
    X_Created_By			=> user_id,
    X_Creation_Date			=> sysdate,
    X_Last_Update_Login                 => 0,
    X_Attribute1                        => X_Attribute1,
    X_Attribute2                        => X_Attribute2,
    X_Attribute3                        => X_Attribute3,
    X_Attribute4                        => X_Attribute4,
    X_Attribute5                        => X_Attribute5,
    X_Attribute6                        => X_Attribute6,
    X_Attribute7                        => X_Attribute7,
    X_Attribute8                        => X_Attribute8,
    X_Attribute9                        => X_Attribute9,
    X_Attribute10                       => X_Attribute10,
    X_Attribute11                       => X_Attribute11,
    X_Attribute12                       => X_Attribute12,
    X_Attribute13                       => X_Attribute13,
    X_Attribute14                       => X_Attribute14,
    X_Attribute15                       => X_Attribute15,
    X_Attribute_Category_Code           => X_Attribute_Category_Code,
    X_Exclude_Salvage_Value_Flag	=> X_Exclude_Salvage_Value_Flag,
    X_Deprn_Basis_Formula               => X_Deprn_Basis_Formula,
    X_Polish_Adj_Calc_Basis_Flag        => X_Polish_Adj_Calc_Basis_Flag,
    X_Guarantee_Rate_Method_Flag        => X_Guarantee_Rate_Method_Flag,
    X_Calling_Fn                        => 'fa_methods_pkg.load_row',
    X_Deprn_Basis_Rule_Id		=> X_Deprn_Basis_Rule_Id,
    x_jp_imp_calc_basis_flag            => x_jp_imp_calc_basis_flag
, p_log_level_rec => p_log_level_rec);
end if;

exception
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_methods_pkg.load_row', p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_methods_pkg.load_row',
                        CALLING_FN => 'upload fa_methods:' || SQLERRM, p_log_level_rec => p_log_level_rec);

end LOAD_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure LOAD_ROW (
   X_CUSTOM_MODE in VARCHAR2,
   X_METHOD_ID in NUMBER,
   X_DB_LAST_UPDATED_BY NUMBER,
   X_DB_LAST_UPDATE_DATE DATE,
   X_OWNER in VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_METHOD_CODE in VARCHAR2,
   X_LIFE_IN_MONTHS in NUMBER,
   X_DEPRECIATE_LASTYEAR_FLAG in VARCHAR2,
   X_STL_METHOD_FLAG in VARCHAR2,
   X_RATE_SOURCE_RULE in VARCHAR2,
   X_DEPRN_BASIS_RULE in VARCHAR2,
   X_PRORATE_PERIODS_PER_YEAR in NUMBER,
   X_NAME in VARCHAR2,
   X_ATTRIBUTE1 in VARCHAR2,
   X_ATTRIBUTE2 in VARCHAR2,
   X_ATTRIBUTE3 in VARCHAR2,
   X_ATTRIBUTE4 in VARCHAR2,
   X_ATTRIBUTE5 in VARCHAR2,
   X_ATTRIBUTE6 in VARCHAR2,
   X_ATTRIBUTE7 in VARCHAR2,
   X_ATTRIBUTE8 in VARCHAR2,
   X_ATTRIBUTE9 in VARCHAR2,
   X_ATTRIBUTE10 in VARCHAR2,
   X_ATTRIBUTE11 in VARCHAR2,
   X_ATTRIBUTE12 in VARCHAR2,
   X_ATTRIBUTE13 in VARCHAR2,
   X_ATTRIBUTE14 in VARCHAR2,
   X_ATTRIBUTE15 in VARCHAR2,
   X_ATTRIBUTE_CATEGORY_CODE in VARCHAR2,
   X_EXCLUDE_SALVAGE_VALUE_FLAG in VARCHAR2,
-- added for alternative flat depreciatio calculation.   for 11.5.2
   X_DEPRN_BASIS_FORMULA in VARCHAR2,
   X_POLISH_ADJ_CALC_BASIS_FLAG in VARCHAR2,
   X_GUARANTEE_RATE_METHOD_FLAG in VARCHAR2,
-- added for Depreciable Basis Formula
   X_DEPRN_BASIS_RULE_ID in NUMBER DEFAULT NULL,
   X_JP_IMP_CALC_BASIS_FLAG IN VARCHAR2 DEFAULT NULL,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  h_record_exists       number(15);
  h_method_id           number(15);

  user_id               number;
  row_id                varchar2(64);

begin

  user_id := fnd_load_util.owner_id (X_Owner);

  if (X_Method_Id is not null) then

     if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                   X_db_last_updated_by, X_db_last_update_date,
                                   X_CUSTOM_MODE)) then

        fa_methods_pkg.update_row (
           X_Rowid                             => row_id,
           X_Method_ID                         => h_method_id,
           X_Method_Code                       => X_Method_Code,
           X_Life_In_Months                    => X_Life_In_Months,
           X_Depreciate_Lastyear_Flag          => X_Depreciate_Lastyear_Flag,
           X_Stl_Method_Flag                   => X_Stl_Method_Flag,
           X_Rate_Source_Rule                  => X_Rate_Source_Rule,
           X_Deprn_Basis_Rule                  => X_Deprn_Basis_Rule,
           X_Prorate_Periods_Per_Year          => X_Prorate_Periods_Per_Year,
           X_Name                              => X_Name,
           X_Last_Update_Date                  => sysdate,
           X_Last_Updated_By                   => user_id,
           X_Last_Update_Login                 => 0,
           X_Attribute1                        => X_Attribute1,
           X_Attribute2                        => X_Attribute2,
           X_Attribute3                        => X_Attribute3,
           X_Attribute4                        => X_Attribute4,
           X_Attribute5                        => X_Attribute5,
           X_Attribute6                        => X_Attribute6,
           X_Attribute7                        => X_Attribute7,
           X_Attribute8                        => X_Attribute8,
           X_Attribute9                        => X_Attribute9,
           X_Attribute10                       => X_Attribute10,
           X_Attribute11                       => X_Attribute11,
           X_Attribute12                       => X_Attribute12,
           X_Attribute13                       => X_Attribute13,
           X_Attribute14                       => X_Attribute14,
           X_Attribute15                       => X_Attribute15,
           X_Attribute_Category_Code           => X_Attribute_Category_Code,
           X_Exclude_Salvage_Value_Flag        => X_Exclude_Salvage_Value_Flag,
           X_Deprn_Basis_Formula               => X_Deprn_Basis_Formula,
           X_Polish_Adj_Calc_Basis_Flag        => X_Polish_Adj_Calc_Basis_Flag,
           X_Guarantee_Rate_Method_Flag        => X_Guarantee_Rate_Method_Flag,
           X_Calling_Fn                        => 'fa_methods_pkg.load_row',
           X_Deprn_Basis_Rule_Id               => X_Deprn_Basis_Rule_Id,
	   x_jp_imp_calc_basis_flag            => x_jp_imp_calc_basis_flag
           ,p_log_level_rec => p_log_level_rec);
     end if;
else

  h_method_id := null;

  fa_methods_pkg.insert_row (
    X_Rowid                             => row_id,
    X_Method_ID                         => h_method_id,
    X_Method_Code                       => X_Method_Code,
    X_Life_In_Months                    => X_Life_In_Months,
    X_Depreciate_Lastyear_Flag          => X_Depreciate_Lastyear_Flag,
    X_Stl_Method_Flag                   => X_Stl_Method_Flag,
    X_Rate_Source_Rule                  => X_Rate_Source_Rule,
    X_Deprn_Basis_Rule                  => X_Deprn_Basis_Rule,
    X_Prorate_Periods_Per_Year          => X_Prorate_Periods_Per_Year,
    X_Name                              => X_Name,
    X_Last_Update_Date                  => sysdate,
    X_Last_Updated_By                   => user_id,
    X_Created_By                        => user_id,
    X_Creation_Date                     => sysdate,
    X_Last_Update_Login                 => 0,
    X_Attribute1                        => X_Attribute1,
    X_Attribute2                        => X_Attribute2,
    X_Attribute3                        => X_Attribute3,
    X_Attribute4                        => X_Attribute4,
    X_Attribute5                        => X_Attribute5,
    X_Attribute6                        => X_Attribute6,
    X_Attribute7                        => X_Attribute7,
    X_Attribute8                        => X_Attribute8,
    X_Attribute9                        => X_Attribute9,
    X_Attribute10                       => X_Attribute10,
    X_Attribute11                       => X_Attribute11,
    X_Attribute12                       => X_Attribute12,
    X_Attribute13                       => X_Attribute13,
    X_Attribute14                       => X_Attribute14,
    X_Attribute15                       => X_Attribute15,
    X_Attribute_Category_Code           => X_Attribute_Category_Code,
    X_Exclude_Salvage_Value_Flag        => X_Exclude_Salvage_Value_Flag,
    X_Deprn_Basis_Formula               => X_Deprn_Basis_Formula,
    X_Polish_Adj_Calc_Basis_Flag        => X_Polish_Adj_Calc_Basis_Flag,
    X_Guarantee_Rate_Method_Flag        => X_Guarantee_Rate_Method_Flag,
    X_Calling_Fn                        => 'fa_methods_pkg.load_row',
    X_Deprn_Basis_Rule_Id               => X_Deprn_Basis_Rule_Id,
    x_jp_imp_calc_basis_flag            => x_jp_imp_calc_basis_flag
    ,p_log_level_rec => p_log_level_rec);
end if;

exception
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_methods_pkg.load_row'
                ,p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_methods_pkg.load_row',
                        CALLING_FN => 'upload fa_methods:' || SQLERRM
                        ,p_log_level_rec => p_log_level_rec);

end LOAD_ROW;

/*Bugfix 6449856: Added x_method_code and x_life_in_months
 * parameters */
procedure TRANSLATE_ROW (
   X_METHOD_ID in NUMBER,
   X_METHOD_CODE in VARCHAR2,
   X_LIFE_IN_MONTHS in NUMBER,
   X_OWNER in VARCHAR2,
   X_NAME in VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

  user_id       number;

begin

  if (X_Owner = 'SEED') then
     user_id := 1;
  else
     user_id := 0;
  end if;

/*Bugfix 6449856: Use method_code and life_in_months to update
 * the appropriate row instead of method_id. This is because
 * for new methods, method_id will be different from what is being
 * passed from ldt file. fyi, LOAD_ROW procedure passes method_id
 * as null to INSERT_ROW. To translate the new row, we need to make use
 * of method_code and life_in_months.
 * */

  if (X_Life_In_Months is not null) then
      update FA_METHODS set
  	NAME = nvl(X_Name, Name),
  	LAST_UPDATE_DATE = sysdate,
  	LAST_UPDATED_BY = user_id,
  	LAST_UPDATE_LOGIN = 0
      --where METHOD_ID = X_Method_ID
      where method_code = X_Method_Code
      and   life_in_months = X_Life_In_Months
      and   userenv('LANG') =
      	(select language_code
       	from FND_LANGUAGES
        where installed_flag = 'B');
  else
      update FA_METHODS set
  	NAME = nvl(X_Name, Name),
  	LAST_UPDATE_DATE = sysdate,
  	LAST_UPDATED_BY = user_id,
  	LAST_UPDATE_LOGIN = 0
      --where METHOD_ID = X_Method_ID
      where method_code = X_Method_Code
      and   life_in_months is null
      and   userenv('LANG') =
      	(select language_code
       	from FND_LANGUAGES
        where installed_flag = 'B');
  end if;

exception
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_methods_pkg.translate_row', p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_methods_pkg.translate_row',
                        CALLING_FN => 'upload fa_methods', p_log_level_rec => p_log_level_rec);

end TRANSLATE_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure TRANSLATE_ROW (
   X_CUSTOM_MODE in VARCHAR2,
   X_METHOD_ID in NUMBER,
   X_METHOD_CODE in VARCHAR2,
   X_LIFE_IN_MONTHS in NUMBER,
   X_DB_LAST_UPDATED_BY NUMBER,
   X_DB_LAST_UPDATE_DATE DATE,
   X_OWNER in VARCHAR2,
   X_LAST_UPDATE_DATE DATE,
   X_NAME in VARCHAR2,
   p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) is

  user_id       number;

begin

   user_id := fnd_load_util.owner_id (X_Owner);

   if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                 x_db_last_updated_by, x_db_last_update_date,
                                 X_CUSTOM_MODE)) then
      /*Bugfix 6685881: Use method_code and life_in_months to update
      * the appropriate row instead of method_id. This is because
      * for new methods, method_id will be different from what is being
      * passed from ldt file. fyi, LOAD_ROW procedure passes method_id
      * as null to INSERT_ROW. To translate the new row, we need to make use
      * of method_code and life_in_months.
      * */

      if (X_Life_In_Months is not null) then

         update FA_METHODS
         set    NAME = nvl(X_Name, Name),
                LAST_UPDATE_DATE = sysdate,
                LAST_UPDATED_BY = user_id
         --where METHOD_ID = X_Method_ID
         where method_code = X_Method_Code
         and   life_in_months = X_Life_In_Months
         and    userenv('LANG') =
                (select language_code
                 from FND_LANGUAGES
                 where installed_flag = 'B');
      else

          update FA_METHODS set
                 NAME = nvl(X_Name, Name),
                 LAST_UPDATE_DATE = sysdate,
                 LAST_UPDATED_BY = user_id,
                 LAST_UPDATE_LOGIN = 0
               --where METHOD_ID = X_Method_ID
               where method_code = X_Method_Code
               and   life_in_months is null
               and   userenv('LANG') =
                 (select language_code
                 from FND_LANGUAGES
                 where installed_flag = 'B');
       end if;

   end if;

exception
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_methods_pkg.translate_row'
                ,p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_methods_pkg.translate_row',
                        CALLING_FN => 'upload fa_methods'
                        ,p_log_level_rec => p_log_level_rec);

end TRANSLATE_ROW;
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
             x_upload_mode                IN VARCHAR2,
             x_custom_mode                IN VARCHAR2,
             x_owner                      IN VARCHAR2,
             x_last_update_date           IN DATE,
             x_method_code                IN VARCHAR2,
             x_life_in_months             IN NUMBER,
             x_depreciate_lastyear_flag   IN VARCHAR2,
             x_stl_method_flag            IN VARCHAR2,
             x_rate_source_rule           IN VARCHAR2,
             x_deprn_basis_rule           IN VARCHAR2,
             x_prorate_periods_per_year   IN NUMBER,
             x_name                       IN VARCHAR2,
             x_attribute1                 IN VARCHAR2,
             x_attribute2                 IN VARCHAR2,
             x_attribute3                 IN VARCHAR2,
             x_attribute4                 IN VARCHAR2,
             x_attribute5                 IN VARCHAR2,
             x_attribute6                 IN VARCHAR2,
             x_attribute7                 IN VARCHAR2,
             x_attribute8                 IN VARCHAR2,
             x_attribute9                 IN VARCHAR2,
             x_attribute10                IN VARCHAR2,
             x_attribute11                IN VARCHAR2,
             x_attribute12                IN VARCHAR2,
             x_attribute13                IN VARCHAR2,
             x_attribute14                IN VARCHAR2,
             x_attribute15                IN VARCHAR2,
             x_attribute_category_code    IN VARCHAR2,
             x_exclude_salvage_value_flag IN VARCHAR2,
             x_deprn_basis_formula        IN VARCHAR2,
	     X_Polish_Adj_Calc_Basis_Flag IN VARCHAR2,
 	     X_Guarantee_Rate_Method_Flag IN VARCHAR2,
             x_deprn_basis_rule_id        IN NUMBER,
	     x_jp_imp_calc_basis_flag     IN VARCHAR2) IS


   h_method_id           number(15);
   h_last_update_date    date;
   h_last_updated_by     number;

BEGIN

      if not fa_cache_pkg.fazccmt (
         X_method                => x_method_code,
         X_life                  => x_life_in_months) then

         h_method_id := null;

      else

         h_method_id        := fa_cache_pkg.fazccmt_record.method_id;
         h_last_update_date := fa_cache_pkg.fazccmt_record.last_update_date;
         h_last_updated_by  := fa_cache_pkg.fazccmt_record.last_updated_by;

      end if;

      if (x_upload_mode = 'NLS') then
           fa_methods_pkg.TRANSLATE_ROW (
             x_custom_mode                => x_custom_mode,
             x_method_id                  => h_method_id,
	     x_method_code                => x_method_code,
             x_life_in_months             => x_life_in_months,
             x_db_last_update_date        => h_last_update_date,
             x_db_last_updated_by         => h_last_updated_by,
             x_owner                      => x_owner,
             x_last_update_date           => x_last_update_date,
             x_name                       => x_name);
      else
           fa_methods_pkg.LOAD_ROW (
             x_custom_mode                => x_custom_mode,
             x_method_id                  => h_method_id,
             x_db_last_update_date        => h_last_update_date,
             x_db_last_updated_by         => h_last_updated_by,
             x_owner                      => x_owner,
             x_last_update_date           => x_last_update_date,
             x_method_code                => x_method_code,
             x_life_in_months             => x_life_in_months,
             x_depreciate_lastyear_flag   => x_depreciate_lastyear_flag,
             x_stl_method_flag            => x_stl_method_flag,
             x_rate_source_rule           => x_rate_source_rule,
             x_deprn_basis_rule           => x_deprn_basis_rule,
             x_prorate_periods_per_year   => x_prorate_periods_per_year,
             x_name                       => x_name,
             x_attribute1                 => x_attribute1,
             x_attribute2                 => x_attribute2,
             x_attribute3                 => x_attribute3,
             x_attribute4                 => x_attribute4,
             x_attribute5                 => x_attribute5,
             x_attribute6                 => x_attribute6,
             x_attribute7                 => x_attribute7,
             x_attribute8                 => x_attribute8,
             x_attribute9                 => x_attribute9,
             x_attribute10                => x_attribute10,
             x_attribute11                => x_attribute11,
             x_attribute12                => x_attribute12,
             x_attribute13                => x_attribute13,
             x_attribute14                => x_attribute14,
             x_attribute15                => x_attribute14,
             x_attribute_category_code    => x_attribute_category_code,
             x_exclude_salvage_value_flag => x_exclude_salvage_value_flag,
             x_deprn_basis_formula        => x_deprn_basis_formula,
	     X_Polish_Adj_Calc_Basis_Flag => X_Polish_Adj_Calc_Basis_Flag,
             X_Guarantee_Rate_Method_Flag => X_Guarantee_Rate_Method_Flag,
             x_deprn_basis_rule_id        => x_deprn_basis_rule_id,
	     x_jp_imp_calc_basis_flag     => x_jp_imp_calc_basis_flag);

      end if;

END LOAD_SEED_ROW;
END FA_METHODS_PKG;

/
