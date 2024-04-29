--------------------------------------------------------
--  DDL for Package Body GL_HISTORICAL_RATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_HISTORICAL_RATES_PKG" as
/* $Header: glirthtb.pls 120.5.12000000.2 2007/08/28 15:59:35 dthakker ship $ */

  PROCEDURE check_unique( x_rowid  VARCHAR2,
                          x_ledger_id   NUMBER,
                          x_code_combination_id   NUMBER,
                          x_period_name   VARCHAR2,
                          x_target_currency   VARCHAR2,
                          x_usage_code VARCHAR2) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_historical_rates hist
      WHERE  hist.ledger_id = x_ledger_id
      AND    hist.code_combination_id = x_code_combination_id
      AND    hist.period_name = x_period_name
      AND    hist.target_currency = x_target_currency
      AND    hist.usage_code = x_usage_code
      AND    ( x_rowid is NULL
               OR
               hist.rowid <> x_rowid );
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_HISTORICAL_RATE' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_HISTORICAL_RATES_PKG.check_unique');
      RAISE;

  END check_unique;

-- **********************************************************************

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Period_Name                         VARCHAR2,
                     X_Period_Num                          NUMBER,
                     X_Period_Year                         NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Target_Currency                     VARCHAR2,
                     X_Update_Flag                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Rate_Type                           VARCHAR2,
                     X_Translated_Rate                     NUMBER,
                     X_Translated_Amount                   NUMBER,
                     X_Account_Type                        VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Usage_Code                          VARCHAR2,
                     X_Chart_of_Accounts_Id                NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM gl_historical_rates
             WHERE ledger_id = X_Ledger_Id
             AND   code_combination_id = X_Code_Combination_Id
             AND   period_name = X_Period_Name
             AND   target_currency = X_Target_Currency
             AND   usage_code  = X_Usage_Code;
BEGIN
  INSERT INTO gl_historical_rates(
          ledger_id,
          period_name,
          period_num,
          period_year,
          code_combination_id,
          target_currency,
          update_flag,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          rate_type,
          translated_rate,
          translated_amount,
          account_type,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          context,
          usage_code
         ) VALUES (
          X_Ledger_Id,
          X_Period_Name,
          X_Period_Num,
          X_Period_Year,
          X_Code_Combination_Id,
          X_Target_Currency,
          X_Update_Flag,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Rate_Type,
          X_Translated_Rate,
          X_Translated_Amount,
          X_Account_Type,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Context,
          X_Usage_Code

  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  IF (X_Usage_Code = 'A') THEN
     GL_DAILY_BALANCES_PKG.set_translated_flag (
        X_Ledger_Id,
        X_Code_Combination_Id,
        X_Target_Currency,
        X_Period_Year,
        X_Period_Num,
        X_Last_Updated_By,
        X_Chart_of_Accounts_id,
        X_Period_Name,
        X_Usage_Code
     );
  ELSE
     GL_BALANCES_PKG.set_translated_flag(
        X_Ledger_Id,
        X_Code_Combination_Id,
        X_Target_Currency,
        X_Period_Year,
        X_Period_Num,
        X_Last_Updated_By,
        X_Chart_of_Accounts_Id,
        X_Period_Name,
        X_Usage_Code
     );
  END IF;

END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_Period_Name                           VARCHAR2,
                   X_Period_Num                            NUMBER,
                   X_Period_Year                           NUMBER,
                   X_Code_Combination_Id                   NUMBER,
                   X_Target_Currency                       VARCHAR2,
                   X_Update_Flag                           VARCHAR2,
                   X_Rate_Type                             VARCHAR2,
                   X_Translated_Rate                       NUMBER,
                   X_Translated_Amount                     NUMBER,
                   X_Account_Type                          VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Usage_Code                            VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_historical_rates
      WHERE  rowid = X_Rowid
      FOR UPDATE of Ledger_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.period_num = X_Period_Num)
           OR (    (Recinfo.period_num IS NULL)
               AND (X_Period_Num IS NULL)))
      AND (   (Recinfo.period_year = X_Period_Year)
           OR (    (Recinfo.period_year IS NULL)
               AND (X_Period_Year IS NULL)))
      AND (   (Recinfo.code_combination_id = X_Code_Combination_Id)
           OR (    (Recinfo.code_combination_id IS NULL)
               AND (X_Code_Combination_Id IS NULL)))
      AND (   (Recinfo.target_currency = X_Target_Currency)
           OR (    (Recinfo.target_currency IS NULL)
               AND (X_Target_Currency IS NULL)))
      AND (   (Recinfo.update_flag = X_Update_Flag)
           OR (    (Recinfo.update_flag IS NULL)
               AND (X_Update_Flag IS NULL)))
      AND (   (Recinfo.rate_type = X_Rate_Type)
           OR (    (Recinfo.rate_type IS NULL)
               AND (X_Rate_Type IS NULL)))
      AND (   (Recinfo.translated_rate = X_Translated_Rate)
           OR (    (Recinfo.translated_rate IS NULL)
               AND (X_Translated_Rate IS NULL)))
      AND (   (Recinfo.translated_amount = X_Translated_Amount)
           OR (    (Recinfo.translated_amount IS NULL)
               AND (X_Translated_Amount IS NULL)))
      AND (   (Recinfo.account_type = X_Account_Type)
           OR (    (Recinfo.account_type IS NULL)
               AND (X_Account_Type IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.usage_code = X_Usage_Code)
           OR (    (Recinfo.usage_code IS NULL)
               AND (X_Usage_Code IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;


PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Period_Name                         VARCHAR2,
                     X_Period_Num                          NUMBER,
                     X_Period_Year                         NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Target_Currency                     VARCHAR2,
                     X_Update_Flag                         VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Rate_Type                           VARCHAR2,
                     X_Translated_Rate                     NUMBER,
                     X_Translated_Amount                   NUMBER,
                     X_Account_Type                        VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Usage_Code                          VARCHAR2,
                     X_Chart_of_Accounts_Id                NUMBER
) IS
BEGIN
  UPDATE gl_historical_rates
  SET

    ledger_id                                 =    X_Ledger_Id,
    period_name                               =    X_Period_Name,
    period_num                                =    X_Period_Num,
    period_year                               =    X_Period_Year,
    code_combination_id                       =    X_Code_Combination_Id,
    target_currency                           =    X_Target_Currency,
    update_flag                               =    X_Update_Flag,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    rate_type                                 =    X_Rate_Type,
    translated_rate                           =    X_Translated_Rate,
    translated_amount                         =    X_Translated_Amount,
    account_type                              =    X_Account_Type,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    context                                   =    X_Context,
    usage_code                                =    X_Usage_Code
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  IF (X_Usage_Code = 'A') THEN
     GL_DAILY_BALANCES_PKG.set_translated_flag (
        X_Ledger_Id,
        X_Code_Combination_Id,
        X_Target_Currency,
        X_Period_Year,
        X_Period_Num,
        X_Last_Updated_By,
        X_Chart_of_Accounts_id,
        X_Period_Name,
        X_Usage_Code
     );
  ELSE
     GL_BALANCES_PKG.set_translated_flag(
        X_Ledger_Id,
        X_Code_Combination_Id,
        X_Target_Currency,
        X_Period_Year,
        X_Period_Num,
        X_Last_Updated_By,
        X_Chart_of_Accounts_id,
        X_Period_Name,
        X_Usage_Code
     );
  END IF;

END Update_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM gl_historical_rates
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Delete_Row;


   FUNCTION valdiate_seg_2(
      x_chart_of_accounts_id              NUMBER,
      x_concat_segments                   VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF fnd_flex_keyval.validate_segs('CHECK_SEGMENTS', 'SQLGL', 'GL#',
                                       x_chart_of_accounts_id,
                                       x_concat_segments, 'V', SYSDATE, NULL,
                                       NULL, NULL, NULL, NULL, TRUE, TRUE,
                                       fnd_global.resp_appl_id,
                                       fnd_global.resp_id,
                                       fnd_global.user_id, NULL, NULL, NULL) THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   END valdiate_seg_2;

-- **********************************************************************
   FUNCTION valdiate_seg(
      x_chart_of_accounts_id              NUMBER,
      x_combination_id                    NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF fnd_flex_keyval.validate_ccid('SQLGL', 'GL#',
                                       x_chart_of_accounts_id,
                                       x_combination_id, NULL, NULL, NULL,
                                       'ENFORCE', NULL,
                                       fnd_global.resp_appl_id,
                                       fnd_global.resp_id,
                                       fnd_global.user_id, NULL) THEN
         RETURN 0;
      ELSE
         RETURN 1;
      END IF;
   END valdiate_seg;

-- **********************************************************************
   FUNCTION get_bal_seg(
      x_chart_of_accounts_id              NUMBER)
      RETURN NUMBER IS
      CURSOR c_get_bal_seg_column_name IS
         SELECT s.application_column_name, s.segment_num
           FROM fnd_id_flex_segments s, fnd_segment_attribute_values v
          WHERE s.application_id = v.application_id
            AND s.id_flex_code = v.id_flex_code
            AND s.id_flex_num = v.id_flex_num
            AND s.application_column_name = v.application_column_name
            AND v.application_id = 101
            AND v.id_flex_code = 'GL#'
            AND v.id_flex_num = x_chart_of_accounts_id
            AND v.segment_attribute_type = 'GL_BALANCING'
            AND v.attribute_value = 'Y';

      v_bal_seg_column_name   VARCHAR2(30);
      v_bal_seg_number        NUMBER(3, 0);
   BEGIN
      OPEN c_get_bal_seg_column_name;

      FETCH c_get_bal_seg_column_name
       INTO v_bal_seg_column_name, v_bal_seg_number;

      IF c_get_bal_seg_column_name%FOUND THEN
         CLOSE c_get_bal_seg_column_name;

         RETURN v_bal_seg_number;
      ELSE
         CLOSE c_get_bal_seg_column_name;

         v_bal_seg_number := 0;
         RETURN v_bal_seg_number;
      END IF;
   EXCEPTION
      WHEN app_exceptions.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE',
                               'GL_HISTORICAL_RATES_PKG.get_bal_seg');
         RAISE;
   END get_bal_seg;

-- **********************************************************************
   PROCEDURE Insert_Row_WebADI_Wrapper(
      X_Ledger                   IN       VARCHAR2,
      X_Functional_Currency      IN       VARCHAR2,
      X_Target_Currency          IN       VARCHAR2,
      X_PERIOD_NAME              IN       VARCHAR2,
      X_Value_Type               IN       VARCHAR2,
      X_Value                    IN       NUMBER,
      X_Rate_Type                IN       VARCHAR2,
      X_Usage_Code               IN       VARCHAR2,
      X_Segment1                 IN       VARCHAR2,
      X_Segment2                 IN       VARCHAR2,
      X_Segment3                 IN       VARCHAR2,
      X_Segment4                 IN       VARCHAR2,
      X_Segment5                 IN       VARCHAR2,
      X_Segment6                 IN       VARCHAR2,
      X_Segment7                 IN       VARCHAR2,
      X_Segment8                 IN       VARCHAR2,
      X_Segment9                 IN       VARCHAR2,
      X_Segment10                IN       VARCHAR2,
      X_Segment11                IN       VARCHAR2,
      X_Segment12                IN       VARCHAR2,
      X_Segment13                IN       VARCHAR2,
      X_Segment14                IN       VARCHAR2,
      X_Segment15                IN       VARCHAR2,
      X_Segment16                IN       VARCHAR2,
      X_Segment17                IN       VARCHAR2,
      X_Segment18                IN       VARCHAR2,
      X_Segment19                IN       VARCHAR2,
      X_Segment20                IN       VARCHAR2,
      X_Segment21                IN       VARCHAR2,
      X_Segment22                IN       VARCHAR2,
      X_Segment23                IN       VARCHAR2,
      X_Segment24                IN       VARCHAR2,
      X_Segment25                IN       VARCHAR2,
      X_Segment26                IN       VARCHAR2,
      X_Segment27                IN       VARCHAR2,
      X_Segment28                IN       VARCHAR2,
      X_Segment29                IN       VARCHAR2,
      X_Segment30                IN       VARCHAR2) IS
      X_Rowid                  VARCHAR2(30);

      l_ledger_id              NUMBER;
      l_access_set_id          NUMBER;
      l_access_count           NUMBER;
      V_sysdate_str            VARCHAR2(30);
      X_Translated_Rate        NUMBER;
      X_Translated_Amount      NUMBER;
      V_Rate_Type              VARCHAR2(1);
      V_Usage_Code             VARCHAR2(1);
      X_Period_Num             NUMBER(15);
      X_Period_Year            NUMBER(15);
      X_Update_Flag            VARCHAR2(1);
      X_Account_Type           VARCHAR2(30);
      X_Last_Update_Date       DATE;
      X_Last_Updated_By        NUMBER;
      X_Creation_Date          DATE;
      X_Created_By             NUMBER;
      X_Last_Update_Login      NUMBER;
      X_Attribute1             VARCHAR2(150);
      X_Attribute2             VARCHAR2(150);
      X_Attribute3             VARCHAR2(150);
      X_Attribute4             VARCHAR2(150);
      X_Attribute5             VARCHAR2(150);
      X_Context                VARCHAR2(150);
      X_Chart_of_Accounts_Id   NUMBER;
      dummy                    NUMBER;
      v_delimiter              VARCHAR2(1);
      v_segments_array         SegmentArray;
      v_segments_num           NUMBER;
      v_conc_segmetns          VARCHAR2(2000);
      X_Code_Combination_Id    NUMBER;
      str                      FND_FLEX_SERVER1.StringArray;

      -- 6058949 Added below cursor to retrieve segment order for
      -- the structure
      Cursor seg_order(flex_num number) is
        select
                s.segment_name segment,
                s.application_column_name app_col,
                s.segment_num num
        from
              fnd_id_flex_segments_vl s
        where
              s.id_flex_num = flex_num
          and s.application_id = 101
          and s.id_flex_code = 'GL#'
          order by s.segment_num;

        j NUMBER  := 1;

   BEGIN
      SELECT ledger_id
        INTO l_ledger_id
        FROM gl_ledgers
       WHERE NAME = X_ledger;

      fnd_profile.get('GL_ACCESS_SET_ID', l_access_set_id);

      --
      -- Get count from access sets
      --
      select count(*)
      into l_access_count
      from gl_access_set_ledgers_v
      where access_set_id = l_access_set_id
      and object_type_code = 'L'
      and access_privilege_code = 'F';



      IF l_access_count = 0  THEN
         app_exception.raise_exception;
      END IF;

      SELECT TO_CHAR(SYSDATE, 'DD-Mon-YYYY')
        INTO V_sysdate_str
        FROM DUAL;

      IF (X_Value_Type = 'Rate') THEN
         X_Translated_Rate := X_Value;
      ELSE
         X_Translated_Amount :=
                     gl_mc_currency_pkg.CurrRound(X_Value, X_Target_Currency);
      END IF;

      /*IF X_Translated_Rate < 0 THEN
         app_exception.raise_exception;
      END IF;
      Per GL team, the rate could be negative now.
      */
      SELECT rate_type
        INTO V_Rate_Type
        FROM gl_lookups_rate_type_v
       WHERE X_Rate_Type = show_rate_type;

      SELECT DECODE(lookup_code, 'Average', 'A', 'S')
        INTO V_Usage_Code
        FROM gl_lookups
       WHERE lookup_type = 'GL_HIST_RATES_USAGE' AND meaning = X_Usage_Code;

      SELECT period_year, period_num
        INTO X_Period_Year, X_Period_Num
        FROM GL_PERIOD_STATUSES
       WHERE application_id = 101
         AND ledger_id = l_ledger_id
         AND period_name = X_PERIOD_NAME;

      X_Update_Flag := 'N';
      X_Last_Update_Date := SYSDATE;
      X_Last_Updated_By := fnd_global.user_id;
      X_Creation_Date := SYSDATE;
      X_Created_By := fnd_global.user_id;
      X_Last_Update_Login := fnd_global.login_id;
      X_Attribute1 := NULL;
      X_Attribute2 := NULL;
      X_Attribute3 := NULL;
      X_Attribute4 := NULL;
      X_Attribute5 := NULL;
      X_Context := NULL;

      SELECT chart_of_accounts_id
        INTO X_Chart_of_Accounts_Id
        FROM gl_ledgers
       WHERE ledger_id = l_ledger_id;

      -- get COA ID
      v_delimiter :=
            fnd_flex_ext.get_delimiter('SQLGL', 'GL#', X_Chart_of_Accounts_Id);
      -- get delimiter
      v_segments_array(1) := X_Segment1;
      v_segments_array(2) := X_Segment2;
      v_segments_array(3) := X_Segment3;
      v_segments_array(4) := X_Segment4;
      v_segments_array(5) := X_Segment5;
      v_segments_array(6) := X_Segment6;
      v_segments_array(7) := X_Segment7;
      v_segments_array(8) := X_Segment8;
      v_segments_array(9) := X_Segment9;
      v_segments_array(10) := X_Segment10;
      v_segments_array(11) := X_Segment11;
      v_segments_array(12) := X_Segment12;
      v_segments_array(13) := X_Segment13;
      v_segments_array(14) := X_Segment14;
      v_segments_array(15) := X_Segment15;
      v_segments_array(16) := X_Segment16;
      v_segments_array(17) := X_Segment17;
      v_segments_array(18) := X_Segment18;
      v_segments_array(19) := X_Segment19;
      v_segments_array(20) := X_Segment20;
      v_segments_array(21) := X_Segment21;
      v_segments_array(22) := X_Segment22;
      v_segments_array(23) := X_Segment23;
      v_segments_array(24) := X_Segment24;
      v_segments_array(25) := X_Segment25;
      v_segments_array(26) := X_Segment26;
      v_segments_array(27) := X_Segment27;
      v_segments_array(28) := X_Segment28;
      v_segments_array(29) := X_Segment29;
      v_segments_array(30) := X_Segment30;

      SELECT COUNT(segment_num)
        INTO v_segments_num
        FROM fnd_id_flex_segments
       WHERE application_id = 101
         AND id_flex_code = 'GL#'
         AND id_flex_num = X_Chart_of_Accounts_Id;

      IF (v_segments_num = 1) THEN
         v_conc_segmetns := v_segments_array(1);
      ELSE

         -- 6058949 added below logic to populate str array in
         -- segment array
         FOR seg_order_rec in seg_order(X_Chart_of_Accounts_Id)
         LOOP
            IF seg_order_rec.app_col = 'SEGMENT1' THEN
               str(j) := v_segments_array(1);
            ELSIF seg_order_rec.app_col = 'SEGMENT2' THEN
               str(j) := v_segments_array(2);
            ELSIF seg_order_rec.app_col = 'SEGMENT3' THEN
               str(j) := v_segments_array(3);
            ELSIF seg_order_rec.app_col = 'SEGMENT4' THEN
               str(j) := v_segments_array(4);
            ELSIF seg_order_rec.app_col = 'SEGMENT5' THEN
               str(j) := v_segments_array(5);
            ELSIF seg_order_rec.app_col = 'SEGMENT6' THEN
               str(j) := v_segments_array(6);
            ELSIF seg_order_rec.app_col = 'SEGMENT7' THEN
               str(j) := v_segments_array(7);
            ELSIF seg_order_rec.app_col = 'SEGMENT8' THEN
               str(j) := v_segments_array(8);
            ELSIF seg_order_rec.app_col = 'SEGMENT9' THEN
               str(j) := v_segments_array(9);
            ELSIF seg_order_rec.app_col = 'SEGMENT10' THEN
               str(j) := v_segments_array(10);
            ELSIF seg_order_rec.app_col = 'SEGMENT11' THEN
               str(j) := v_segments_array(11);
            ELSIF seg_order_rec.app_col = 'SEGMENT12' THEN
               str(j) := v_segments_array(12);
            ELSIF seg_order_rec.app_col = 'SEGMENT13' THEN
               str(j) := v_segments_array(13);
            ELSIF seg_order_rec.app_col = 'SEGMENT14' THEN
               str(j) := v_segments_array(14);
            ELSIF seg_order_rec.app_col = 'SEGMENT15' THEN
               str(j) := v_segments_array(15);
            ELSIF seg_order_rec.app_col = 'SEGMENT16' THEN
               str(j) := v_segments_array(16);
            ELSIF seg_order_rec.app_col = 'SEGMENT17' THEN
               str(j) := v_segments_array(17);
            ELSIF seg_order_rec.app_col = 'SEGMENT18' THEN
               str(j) := v_segments_array(18);
            ELSIF seg_order_rec.app_col = 'SEGMENT19' THEN
               str(j) := v_segments_array(19);
            ELSIF seg_order_rec.app_col = 'SEGMENT20' THEN
               str(j) := v_segments_array(20);
            ELSIF seg_order_rec.app_col = 'SEGMENT21' THEN
               str(j) := v_segments_array(21);
            ELSIF seg_order_rec.app_col = 'SEGMENT22' THEN
               str(j) := v_segments_array(22);
            ELSIF seg_order_rec.app_col = 'SEGMENT23' THEN
               str(j) := v_segments_array(23);
            ELSIF seg_order_rec.app_col = 'SEGMENT24' THEN
               str(j) := v_segments_array(24);
            ELSIF seg_order_rec.app_col = 'SEGMENT25' THEN
               str(j) := v_segments_array(25);
            ELSIF seg_order_rec.app_col = 'SEGMENT26' THEN
               str(j) := v_segments_array(26);
            ELSIF seg_order_rec.app_col = 'SEGMENT27' THEN
               str(j) := v_segments_array(27);
            ELSIF seg_order_rec.app_col = 'SEGMENT28' THEN
               str(j) := v_segments_array(28);
            ELSIF seg_order_rec.app_col = 'SEGMENT29' THEN
               str(j) := v_segments_array(29);
            ELSIF seg_order_rec.app_col = 'SEGMENT30' THEN
               str(j) := v_segments_array(30);
            ELSE
               app_exception.raise_exception;
            END IF;

            j := j + 1;

         END LOOP;

         -- Commented below logic which was creating the str
         -- array without considering the segment order
         /*
         FOR i IN 1 .. v_segments_num LOOP
            IF v_segments_array(i) IS NOT NULL THEN
               str(i) := v_segments_array(i);
            ELSE
               app_exception.raise_exception;
            END IF;
         END LOOP;
         */

         -- 6058949 end

         v_conc_segmetns :=
            FND_FLEX_SERVER1.from_stringarray(v_segments_num, str,
                                              v_delimiter);
      END IF;

      -- get CCID
      X_Code_Combination_Id :=
         fnd_flex_ext.get_ccid('SQLGL', 'GL#', X_Chart_of_Accounts_Id,
                               V_sysdate_str, v_conc_segmetns);
      GL_CODE_COMBINATIONS_PKG.select_columns(X_Code_Combination_Id,
                                              X_Account_Type, dummy);

      DELETE FROM gl_historical_rates
            WHERE ledger_id = l_ledger_id
              AND code_combination_id = X_Code_Combination_Id
              AND period_name = X_PERIOD_NAME
              AND target_currency = X_Target_Currency
              AND usage_code = V_Usage_Code;

      GL_HISTORICAL_RATES_PKG.Insert_Row(X_Rowid, l_ledger_id,
                                         X_PERIOD_NAME, X_Period_Num,
                                         X_Period_Year, X_Code_Combination_Id,
                                         X_Target_Currency, X_Update_Flag,
                                         X_Last_Update_Date,
                                         X_Last_Updated_By, X_Creation_Date,
                                         X_Created_By, X_Last_Update_Login,
                                         V_Rate_Type, X_Translated_Rate,
                                         X_Translated_Amount, X_Account_Type,
                                         X_Attribute1, X_Attribute2,
                                         X_Attribute3, X_Attribute4,
                                         X_Attribute5, X_Context,
                                         V_Usage_Code, X_Chart_of_Accounts_Id);
   END Insert_Row_WebADI_Wrapper;


END GL_HISTORICAL_RATES_PKG;

/
