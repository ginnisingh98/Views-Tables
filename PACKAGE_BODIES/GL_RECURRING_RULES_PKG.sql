--------------------------------------------------------
--  DDL for Package Body GL_RECURRING_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RECURRING_RULES_PKG" as
/* $Header: glirecrb.pls 120.6 2005/05/05 01:20:25 kvora ship $ */


  --
  -- PUBLIC FUNCTIONS
  --


  PROCEDURE check_unique( x_rowid VARCHAR2,
                          x_rule_num  NUMBER,
                          x_line_num  NUMBER,
                          x_header_id NUMBER ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_recurring_line_calc_rules r
      WHERE  r.rule_num = x_rule_num
      AND    r.recurring_line_num = x_line_num
      AND    r.recurring_header_id = x_header_id
      AND    ( x_rowid is NULL
               OR
               r.rowid <> x_rowid );

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_REC_RULE' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_RULES_PKG.check_unique');
      RAISE;

  END check_unique;

-- **********************************************************************

  PROCEDURE update_line_num( x_new_line_num  NUMBER,
                             x_old_line_num  NUMBER,
                             x_header_id     NUMBER ) IS
  BEGIN

    UPDATE  gl_recurring_line_calc_rules r
    SET     r.recurring_line_num = x_new_line_num
    WHERE   r.recurring_header_id = x_header_id
    AND     r.recurring_line_num = x_old_line_num;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_RULES_PKG.update_line_num');
      RAISE;

  END update_line_num;

-- *********************************************************************


  FUNCTION get_ccid(   x_ledger_id                      NUMBER,
                       x_coa_id		                NUMBER,
                       x_conc_seg                       VARCHAR2,
                       x_err_msg                    OUT NOCOPY VARCHAR2,
                       x_ccid                       OUT NOCOPY NUMBER,
                       x_templgrid                  OUT NOCOPY NUMBER,
                       x_acct_type                  OUT NOCOPY VARCHAR2,
                       X_Segment1                       VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Segment6                       VARCHAR2,
                       X_Segment7                       VARCHAR2,
                       X_Segment8                       VARCHAR2,
                       X_Segment9                       VARCHAR2,
                       X_Segment10                      VARCHAR2,
                       X_Segment11                      VARCHAR2,
                       X_Segment12                      VARCHAR2,
                       X_Segment13                      VARCHAR2,
                       X_Segment14                      VARCHAR2,
                       X_Segment15                      VARCHAR2,
                       X_Segment16                      VARCHAR2,
                       X_Segment17                      VARCHAR2,
                       X_Segment18                      VARCHAR2,
                       X_Segment19                      VARCHAR2,
                       X_Segment20                      VARCHAR2,
                       X_Segment21                      VARCHAR2,
                       X_Segment22                      VARCHAR2,
                       X_Segment23                      VARCHAR2,
                       X_Segment24                      VARCHAR2,
                       X_Segment25                      VARCHAR2,
                       X_Segment26                      VARCHAR2,
                       X_Segment27                      VARCHAR2,
                       X_Segment28                      VARCHAR2,
                       X_Segment29                      VARCHAR2,
                       X_Segment30                      VARCHAR2)
                       RETURN BOOLEAN IS
      ccid_cursor      NUMBER;
      ccid_select      VARCHAR2(4500);
      c_ccid           NUMBER;
      c_lgr_id         NUMBER;
      c_enabled_flag   VARCHAR2(1);
      c_acct_type      VARCHAR2(1);
      row_count        NUMBER;
    BEGIN

      ccid_cursor := dbms_sql.open_cursor;

      ccid_select := ' SELECT cc.code_combination_id,
                              gst.ledger_id,
                              cc.enabled_flag, cc.account_type'||
 		     ' FROM   gl_code_combinations cc, ' ||
                     ' gl_summary_templates gst ' ||
                     ' WHERE  cc.chart_of_accounts_id = :coa_id ';

      IF ( x_segment1 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment1 = :segment1 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment1 IS NULL ';
      END IF;

      IF ( x_segment2 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment2 = :segment2 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment2 IS NULL ';
      END IF;

      IF ( x_segment3 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment3 = :segment3 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment3 IS NULL ';
      END IF;

      IF ( x_segment4 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment4 = :segment4 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment4 IS NULL ';
      END IF;

      IF ( x_segment5 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment5 = :segment5 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment5 IS NULL ';
      END IF;

      IF ( x_segment6 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment6 = :segment6 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment6 IS NULL ';
      END IF;

      IF ( x_segment7 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment7 = :segment7 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment7 IS NULL ';
      END IF;

      IF ( x_segment8 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment8 = :segment8 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment8 IS NULL ';
      END IF;

      IF ( x_segment9 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment9 = :segment9 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment9 IS NULL ';
      END IF;

      IF ( x_segment10 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment10 = :segment10 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment10 IS NULL ';
      END IF;

      IF ( x_segment11 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment11 = :segment11 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment11 IS NULL ';
      END IF;

      IF ( x_segment12 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment12 = :segment12 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment12 IS NULL ';
      END IF;

      IF ( x_segment13 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment13 = :segment13 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment13 IS NULL ';
      END IF;

      IF ( x_segment14 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment14 = :segment14 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment14 IS NULL ';
      END IF;

      IF ( x_segment15 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment15 = :segment15 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment15 IS NULL ';
      END IF;

      IF ( x_segment16 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment16 = :segment16 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment16  IS NULL ';
      END IF;

      IF ( x_segment17 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment17 = :segment17 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment17 IS NULL ';
      END IF;

      IF ( x_segment18 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment18 = :segment18 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment18 IS NULL ';
      END IF;

      IF ( x_segment19 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment19 = :segment19 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment19 IS NULL ';
      END IF;

      IF ( x_segment20 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment20 = :segment20 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment20 IS NULL ';
      END IF;

      IF ( x_segment21 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment21 = :segment21 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment21 IS NULL ';
      END IF;

      IF ( x_segment22 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment22 = :segment22 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment22 IS NULL ';
      END IF;

      IF ( x_segment23 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment23 = :segment23 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment23 IS NULL ';
      END IF;

      IF ( x_segment24 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment24 = :segment24 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment24 IS NULL ';
      END IF;

      IF ( x_segment25 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment25 = :segment25 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment25 IS NULL ';
      END IF;

      IF ( x_segment26 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment26 = :segment26 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment26 IS NULL ';
      END IF;

      IF ( x_segment27 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment27 = :segment27 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment27 IS NULL ';
      END IF;

      IF ( x_segment28 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment28 = :segment28 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment28 IS NULL ';
      END IF;

      IF ( x_segment29 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment29 = :segment29 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment29 IS NULL ';
      END IF;

      IF ( x_segment30 IS NOT NULL) THEN
        ccid_select := ccid_select || ' AND cc.segment30 = :segment30 ';
      ELSE
        ccid_select := ccid_select || ' AND cc.segment30 IS NULL ';
      END IF;

      ccid_select := ccid_select ||
       ' AND    gst.template_id (+) = cc.template_id ' ||
       ' ORDER BY decode(gst.ledger_id,:lgr_id,0,1) ';

      dbms_sql.parse(ccid_cursor,ccid_select,dbms_sql.v7);

      dbms_sql.define_column(ccid_cursor, 1, c_ccid);
      dbms_sql.define_column(ccid_cursor, 2, c_lgr_id);
      dbms_sql.define_column(ccid_cursor, 3, c_enabled_flag, 1);
      dbms_sql.define_column(ccid_cursor, 4, c_acct_type, 1);

      dbms_sql.bind_variable(ccid_cursor, ':coa_id', x_coa_id);

      IF ( x_segment1 IS NOT NULL ) THEN
         dbms_sql.bind_variable(ccid_cursor, ':segment1', x_segment1);
      END IF;

      IF ( x_segment2 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment2', x_segment2);
      END IF;

      IF ( x_segment3 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment3', x_segment3);
      END IF;

      IF ( x_segment4 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment4', x_segment4);
      END IF;

      IF ( x_segment5 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment5', x_segment5);
      END IF;

      IF ( x_segment6 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment6', x_segment6);
      END IF;

      IF ( x_segment7 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment7', x_segment7);
      END IF;

      IF ( x_segment8 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment8', x_segment8);
      END IF;

      IF ( x_segment9 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment9', x_segment9);
      END IF;

      IF ( x_segment10 IS NOT NULL ) THEN
         dbms_sql.bind_variable(ccid_cursor, ':segment10', x_segment10);
      END IF;

      IF ( x_segment11 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment11', x_segment11);
      END IF;

      IF ( x_segment12 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment12', x_segment12);
      END IF;

      IF ( x_segment13 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment13', x_segment13);
      END IF;

      IF ( x_segment14 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment14', x_segment14);
      END IF;

      IF ( x_segment15 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment15', x_segment15);
      END IF;

      IF ( x_segment16 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment16', x_segment16);
      END IF;

      IF ( x_segment17 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment17', x_segment17);
      END IF;

      IF ( x_segment18 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment18', x_segment18);
      END IF;

      IF ( x_segment19 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment19', x_segment19);
      END IF;

      IF ( x_segment20 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment20', x_segment20);
      END IF;

      IF ( x_segment21 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment21', x_segment21);
      END IF;

      IF ( x_segment22 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment22', x_segment22);
      END IF;

      IF ( x_segment23 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment23', x_segment23);
      END IF;

      IF ( x_segment24 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment24', x_segment24);
      END IF;

      IF ( x_segment25 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment25', x_segment25);
      END IF;

      IF ( x_segment26 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment26', x_segment26);
      END IF;

      IF ( x_segment27 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment27', x_segment27);
      END IF;

      IF ( x_segment28 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment28', x_segment28);
      END IF;

      IF ( x_segment29 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment29', x_segment29);
      END IF;

      IF ( x_segment30 IS NOT NULL ) THEN
        dbms_sql.bind_variable(ccid_cursor, ':segment30', x_segment30);
      END IF;

      dbms_sql.bind_variable(ccid_cursor, ':lgr_id', x_ledger_id);
      row_count := dbms_sql.execute_and_fetch(ccid_cursor);

      IF (row_count = 0) THEN
        -- Create a detail account
        IF ( x_conc_seg IS NOT NULL) THEN
           IF(NOT fnd_flex_keyval.validate_segs(
                 operation	   => 'CREATE_COMBINATION',
	       	 appl_short_name   => 'SQLGL',
		 key_flex_code	   => 'GL#',
		 structure_number  => x_coa_id,
		 concat_segments   => x_conc_seg,
                 validation_date   => null,
                 vrule		=> '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;' ||
                                   'NAME=GL_RJE_NO_NEW_SUMMARY\nN'
 		 )) THEN
              x_templgrid := x_ledger_id;
              x_err_msg :=fnd_flex_keyval.error_message;
              dbms_sql.close_cursor(ccid_cursor);
              RETURN FALSE;
           ELSE
             x_ccid := fnd_flex_keyval.combination_id;
             x_templgrid := x_ledger_id;
             x_acct_type := fnd_flex_keyval.qualifier_value('GL_ACCOUNT_TYPE');
           END IF;
        END IF;
      ELSE
         dbms_sql.column_value(ccid_cursor, 1, c_ccid);
         dbms_sql.column_value(ccid_cursor, 2, c_lgr_id);
         dbms_sql.column_value(ccid_cursor, 3, c_enabled_flag);
         dbms_sql.column_value(ccid_cursor, 4, c_acct_type);

         IF (c_enabled_flag ='N')THEN
            x_ccid := c_ccid;
            x_templgrid := c_lgr_id;
            x_acct_type := c_acct_type;
            fnd_message.set_name( 'SQLGL', 'GL_RJE_RULE_INV_CCID' );
            x_err_msg := fnd_message.get;
            dbms_sql.close_cursor(ccid_cursor);
            RETURN FALSE;
         ELSE
           x_ccid := c_ccid;
           x_templgrid := c_lgr_id;
           x_acct_type := c_acct_type;
         END IF;
      END IF;
      dbms_sql.close_cursor(ccid_cursor);
      RETURN TRUE;
  END get_ccid;

-- *********************************************************************

  PROCEDURE delete_rows( x_header_id    NUMBER,
                         x_line_num     NUMBER ) IS

  BEGIN

      DELETE
      FROM   GL_RECURRING_LINE_CALC_RULES
      WHERE  RECURRING_HEADER_ID = x_header_id
      AND    RECURRING_LINE_NUM = x_line_num;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_RULES_PKG.delete_rows');
      RAISE;

  END delete_rows;

-- **********************************************************************


  PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,

                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Rule_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Operator                       VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Amount                         NUMBER,
                       X_Amount_Type                    VARCHAR2,
                       X_Actual_Flag                    VARCHAR2,
                       X_Ledger_Currency                VARCHAR2,
                       X_Currency_Type                  VARCHAR2,
                       X_Entered_Currency               VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Relative_Period_Code           VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Assigned_Code_Combination      NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Segment6                       VARCHAR2,
                       X_Segment7                       VARCHAR2,
                       X_Segment8                       VARCHAR2,
                       X_Segment9                       VARCHAR2,
                       X_Segment10                      VARCHAR2,
                       X_Segment11                      VARCHAR2,
                       X_Segment12                      VARCHAR2,
                       X_Segment13                      VARCHAR2,
                       X_Segment14                      VARCHAR2,
                       X_Segment15                      VARCHAR2,
                       X_Segment16                      VARCHAR2,
                       X_Segment17                      VARCHAR2,
                       X_Segment18                      VARCHAR2,
                       X_Segment19                      VARCHAR2,
                       X_Segment20                      VARCHAR2,
                       X_Segment21                      VARCHAR2,
                       X_Segment22                      VARCHAR2,
                       X_Segment23                      VARCHAR2,
                       X_Segment24                      VARCHAR2,
                       X_Segment25                      VARCHAR2,
                       X_Segment26                      VARCHAR2,
                       X_Segment27                      VARCHAR2,
                       X_Segment28                      VARCHAR2,
                       X_Segment29                      VARCHAR2,
                       X_Segment30                      VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM GL_RECURRING_LINE_CALC_RULES
                 WHERE recurring_header_id = X_Recurring_Header_Id
 		and recurring_line_num = X_Recurring_Line_Num
 		and rule_num = X_Rule_Num;

   BEGIN

-- Check line for Uniqueness
Check_Unique(X_Rowid, X_Rule_Num, X_Recurring_Line_Num, X_Recurring_Header_Id );


       INSERT INTO GL_RECURRING_LINE_CALC_RULES(

              recurring_header_id,
              recurring_line_num,
              rule_num,
              last_update_date,
              last_updated_by,
              operator,
              creation_date,
              created_by,
              last_update_login,
              amount,
              amount_type,
              actual_flag,
              ledger_currency,
              currency_type,
              entered_currency,
              ledger_id,
              relative_period_code,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              context,
              assigned_code_combination,
              template_id,
              segment1,
              segment2,
              segment3,
              segment4,
              segment5,
              segment6,
              segment7,
              segment8,
              segment9,
              segment10,
              segment11,
              segment12,
              segment13,
              segment14,
              segment15,
              segment16,
              segment17,
              segment18,
              segment19,
              segment20,
              segment21,
              segment22,
              segment23,
              segment24,
              segment25,
              segment26,
              segment27,
              segment28,
              segment29,
              segment30
             ) VALUES (

              X_Recurring_Header_Id,
              X_Recurring_Line_Num,
              X_Rule_Num,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Operator,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Amount,
              X_Amount_Type,
              X_Actual_Flag,
              X_Ledger_Currency,
              X_Currency_Type,
              X_Entered_Currency,
              X_Ledger_Id,
              X_Relative_Period_Code,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Context,
              X_Assigned_Code_Combination,
              X_Template_Id,
              X_Segment1,
              X_Segment2,
              X_Segment3,
              X_Segment4,
              X_Segment5,
              X_Segment6,
              X_Segment7,
              X_Segment8,
              X_Segment9,
              X_Segment10,
              X_Segment11,
              X_Segment12,
              X_Segment13,
              X_Segment14,
              X_Segment15,
              X_Segment16,
              X_Segment17,
              X_Segment18,
              X_Segment19,
              X_Segment20,
              X_Segment21,
              X_Segment22,
              X_Segment23,
              X_Segment24,
              X_Segment25,
              X_Segment26,
              X_Segment27,
              X_Segment28,
              X_Segment29,
              X_Segment30

             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;



  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Recurring_Header_Id              NUMBER,
                     X_Recurring_Line_Num               NUMBER,
                     X_Rule_Num                         NUMBER,
                     X_Operator                         VARCHAR2,
                     X_Amount                           NUMBER,
                     X_Amount_Type                      VARCHAR2,
                     X_Actual_Flag                      VARCHAR2,
                     X_Ledger_Currency                  VARCHAR2,
                     X_Currency_Type                    VARCHAR2,
                     X_Entered_Currency                 VARCHAR2,
                     X_Ledger_Id                        NUMBER,
                     X_Relative_Period_Code             VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Context                          VARCHAR2,
                     X_Assigned_Code_Combination        NUMBER,
                     X_Template_Id                      NUMBER,
                     X_Segment1                         VARCHAR2,
                     X_Segment2                         VARCHAR2,
                     X_Segment3                         VARCHAR2,
                     X_Segment4                         VARCHAR2,
                     X_Segment5                         VARCHAR2,
                     X_Segment6                         VARCHAR2,
                     X_Segment7                         VARCHAR2,
                     X_Segment8                         VARCHAR2,
                     X_Segment9                         VARCHAR2,
                     X_Segment10                        VARCHAR2,
                     X_Segment11                        VARCHAR2,
                     X_Segment12                        VARCHAR2,
                     X_Segment13                        VARCHAR2,
                     X_Segment14                        VARCHAR2,
                     X_Segment15                        VARCHAR2,
                     X_Segment16                        VARCHAR2,
                     X_Segment17                        VARCHAR2,
                     X_Segment18                        VARCHAR2,
                     X_Segment19                        VARCHAR2,
                     X_Segment20                        VARCHAR2,
                     X_Segment21                        VARCHAR2,
                     X_Segment22                        VARCHAR2,
                     X_Segment23                        VARCHAR2,
                     X_Segment24                        VARCHAR2,
                     X_Segment25                        VARCHAR2,
                     X_Segment26                        VARCHAR2,
                     X_Segment27                        VARCHAR2,
                     X_Segment28                        VARCHAR2,
                     X_Segment29                        VARCHAR2,
                     X_Segment30                        VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   GL_RECURRING_LINE_CALC_RULES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Recurring_Header_Id NOWAIT;
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

               (Recinfo.recurring_header_id =  X_Recurring_Header_Id)
           AND (Recinfo.recurring_line_num =  X_Recurring_Line_Num)
           AND (Recinfo.rule_num =  X_Rule_Num)
           AND (Recinfo.operator =  X_Operator)
           AND (   (Recinfo.amount =  X_Amount)
                OR (    (Recinfo.amount IS NULL)
                    AND (X_Amount IS NULL)))
           AND (   (Recinfo.amount_type =  X_Amount_Type)
                OR (    (Recinfo.amount_type IS NULL)
                    AND (X_Amount_Type IS NULL)))
           AND (   (Recinfo.actual_flag =  X_Actual_Flag)
                OR (    (Recinfo.actual_flag IS NULL)
                    AND (X_Actual_Flag IS NULL)))
           AND (   (Recinfo.ledger_currency =  X_Ledger_Currency)
                OR (    (Recinfo.ledger_currency IS NULL)
                    AND (X_Ledger_Currency IS NULL)))
           AND (   (Recinfo.currency_type =  X_Currency_Type)
                OR (    (Recinfo.currency_type IS NULL)
                    AND (X_Currency_Type IS NULL)))
           AND (   (Recinfo.entered_currency =  X_Entered_Currency)
                OR (    (Recinfo.entered_currency IS NULL)
                    AND (X_Entered_Currency IS NULL)))
           AND (   (Recinfo.ledger_id =  X_Ledger_Id)
                OR (    (Recinfo.ledger_id IS NULL)
                    AND (X_Ledger_Id IS NULL)))
           AND (   (Recinfo.relative_period_code =  X_Relative_Period_Code)
                OR (    (Recinfo.relative_period_code IS NULL)
                    AND (X_Relative_Period_Code IS NULL)))
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
           AND (   (Recinfo.context =  X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.assigned_code_combination =  X_Assigned_Code_Combination)
                OR (    (Recinfo.assigned_code_combination IS NULL)
                    AND (X_Assigned_Code_Combination IS NULL)))
           AND (   (Recinfo.template_id =  X_Template_Id)
                OR (    (Recinfo.template_id IS NULL)
                    AND (X_Template_Id IS NULL)))
           AND (   (Recinfo.segment1 =  X_Segment1)
                OR (    (Recinfo.segment1 IS NULL)
                    AND (X_Segment1 IS NULL)))
           AND (   (Recinfo.segment2 =  X_Segment2)
                OR (    (Recinfo.segment2 IS NULL)
                    AND (X_Segment2 IS NULL)))
           AND (   (Recinfo.segment3 =  X_Segment3)
                OR (    (Recinfo.segment3 IS NULL)
                    AND (X_Segment3 IS NULL)))
           AND (   (Recinfo.segment4 =  X_Segment4)
                OR (    (Recinfo.segment4 IS NULL)
                    AND (X_Segment4 IS NULL)))
           AND (   (Recinfo.segment5 =  X_Segment5)
                OR (    (Recinfo.segment5 IS NULL)
                    AND (X_Segment5 IS NULL)))
           AND (   (Recinfo.segment6 =  X_Segment6)
                OR (    (Recinfo.segment6 IS NULL)
                    AND (X_Segment6 IS NULL)))
           AND (   (Recinfo.segment7 =  X_Segment7)
                OR (    (Recinfo.segment7 IS NULL)
                    AND (X_Segment7 IS NULL)))
           AND (   (Recinfo.segment8 =  X_Segment8)
                OR (    (Recinfo.segment8 IS NULL)
                    AND (X_Segment8 IS NULL)))
           AND (   (Recinfo.segment9 =  X_Segment9)
                OR (    (Recinfo.segment9 IS NULL)
                    AND (X_Segment9 IS NULL)))
           AND (   (Recinfo.segment10 =  X_Segment10)
                OR (    (Recinfo.segment10 IS NULL)
                    AND (X_Segment10 IS NULL)))
           AND (   (Recinfo.segment11 =  X_Segment11)
                OR (    (Recinfo.segment11 IS NULL)
                    AND (X_Segment11 IS NULL)))
           AND (   (Recinfo.segment12 =  X_Segment12)
                OR (    (Recinfo.segment12 IS NULL)
                    AND (X_Segment12 IS NULL)))
           AND (   (Recinfo.segment13 =  X_Segment13)
                OR (    (Recinfo.segment13 IS NULL)
                    AND (X_Segment13 IS NULL)))
           AND (   (Recinfo.segment14 =  X_Segment14)
                OR (    (Recinfo.segment14 IS NULL)
                    AND (X_Segment14 IS NULL)))
           AND (   (Recinfo.segment15 =  X_Segment15)
                OR (    (Recinfo.segment15 IS NULL)
                    AND (X_Segment15 IS NULL)))
           AND (   (Recinfo.segment16 =  X_Segment16)
                OR (    (Recinfo.segment16 IS NULL)
                    AND (X_Segment16 IS NULL)))
           AND (   (Recinfo.segment17 =  X_Segment17)
                OR (    (Recinfo.segment17 IS NULL)
                    AND (X_Segment17 IS NULL)))
           AND (   (Recinfo.segment18 =  X_Segment18)
                OR (    (Recinfo.segment18 IS NULL)
                    AND (X_Segment18 IS NULL)))
           AND (   (Recinfo.segment19 =  X_Segment19)
                OR (    (Recinfo.segment19 IS NULL)
                    AND (X_Segment19 IS NULL)))
           AND (   (Recinfo.segment20 =  X_Segment20)
                OR (    (Recinfo.segment20 IS NULL)
                    AND (X_Segment20 IS NULL)))
           AND (   (Recinfo.segment21 =  X_Segment21)
                OR (    (Recinfo.segment21 IS NULL)
                    AND (X_Segment21 IS NULL)))
           AND (   (Recinfo.segment22 =  X_Segment22)
                OR (    (Recinfo.segment22 IS NULL)
                    AND (X_Segment22 IS NULL)))
           AND (   (Recinfo.segment23 =  X_Segment23)
                OR (    (Recinfo.segment23 IS NULL)
                    AND (X_Segment23 IS NULL)))
           AND (   (Recinfo.segment24 =  X_Segment24)
                OR (    (Recinfo.segment24 IS NULL)
                    AND (X_Segment24 IS NULL)))
           AND (   (Recinfo.segment25 =  X_Segment25)
                OR (    (Recinfo.segment25 IS NULL)
                    AND (X_Segment25 IS NULL)))
           AND (   (Recinfo.segment26 =  X_Segment26)
                OR (    (Recinfo.segment26 IS NULL)
                    AND (X_Segment26 IS NULL)))
           AND (   (Recinfo.segment27 =  X_Segment27)
                OR (    (Recinfo.segment27 IS NULL)
                    AND (X_Segment27 IS NULL)))
           AND (   (Recinfo.segment28 =  X_Segment28)
                OR (    (Recinfo.segment28 IS NULL)
                    AND (X_Segment28 IS NULL)))
           AND (   (Recinfo.segment29 =  X_Segment29)
                OR (    (Recinfo.segment29 IS NULL)
                    AND (X_Segment29 IS NULL)))
           AND (   (Recinfo.segment30 =  X_Segment30)
                OR (    (Recinfo.segment30 IS NULL)
                    AND (X_Segment30 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Rule_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Operator                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Amount                         NUMBER,
                       X_Amount_Type	                VARCHAR2,
                       X_Actual_Flag                    VARCHAR2,
                       X_Ledger_Currency                VARCHAR2,
                       X_Currency_Type                  VARCHAR2,
                       X_Entered_Currency               VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Relative_Period_Code           VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Assigned_Code_Combination      NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Segment6                       VARCHAR2,
                       X_Segment7                       VARCHAR2,
                       X_Segment8                       VARCHAR2,
                       X_Segment9                       VARCHAR2,
                       X_Segment10                      VARCHAR2,
                       X_Segment11                      VARCHAR2,
                       X_Segment12                      VARCHAR2,
                       X_Segment13                      VARCHAR2,
                       X_Segment14                      VARCHAR2,
                       X_Segment15                      VARCHAR2,
                       X_Segment16                      VARCHAR2,
                       X_Segment17                      VARCHAR2,
                       X_Segment18                      VARCHAR2,
                       X_Segment19                      VARCHAR2,
                       X_Segment20                      VARCHAR2,
                       X_Segment21                      VARCHAR2,
                       X_Segment22                      VARCHAR2,
                       X_Segment23                      VARCHAR2,
                       X_Segment24                      VARCHAR2,
                       X_Segment25                      VARCHAR2,
                       X_Segment26                      VARCHAR2,
                       X_Segment27                      VARCHAR2,
                       X_Segment28                      VARCHAR2,
                       X_Segment29                      VARCHAR2,
                       X_Segment30                      VARCHAR2

  ) IS

  BEGIN

-- Check line for Uniqueness
Check_Unique(X_Rowid, X_Rule_Num, X_Recurring_Line_Num, X_Recurring_Header_Id );


    UPDATE GL_RECURRING_LINE_CALC_RULES
    SET
       recurring_header_id             =     X_Recurring_Header_Id,
       recurring_line_num              =     X_Recurring_Line_Num,
       rule_num                        =     X_Rule_Num,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       operator                        =     X_Operator,
       last_update_login               =     X_Last_Update_Login,
       amount                          =     X_Amount,
       amount_type 	               =     X_Amount_Type,
       actual_flag                     =     X_Actual_Flag,
       ledger_currency                 =     X_Ledger_Currency,
       currency_type                   =     X_Currency_Type,
       entered_currency                =     X_Entered_Currency,
       ledger_id                       =     X_Ledger_Id,
       relative_period_code            =     X_Relative_Period_Code,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       context                         =     X_Context,
       assigned_code_combination       =     X_Assigned_Code_Combination,
       template_id                     =     X_Template_Id,
       segment1                        =     X_Segment1,
       segment2                        =     X_Segment2,
       segment3                        =     X_Segment3,
       segment4                        =     X_Segment4,
       segment5                        =     X_Segment5,
       segment6                        =     X_Segment6,
       segment7                        =     X_Segment7,
       segment8                        =     X_Segment8,
       segment9                        =     X_Segment9,
       segment10                       =     X_Segment10,
       segment11                       =     X_Segment11,
       segment12                       =     X_Segment12,
       segment13                       =     X_Segment13,
       segment14                       =     X_Segment14,
       segment15                       =     X_Segment15,
       segment16                       =     X_Segment16,
       segment17                       =     X_Segment17,
       segment18                       =     X_Segment18,
       segment19                       =     X_Segment19,
       segment20                       =     X_Segment20,
       segment21                       =     X_Segment21,
       segment22                       =     X_Segment22,
       segment23                       =     X_Segment23,
       segment24                       =     X_Segment24,
       segment25                       =     X_Segment25,
       segment26                       =     X_Segment26,
       segment27                       =     X_Segment27,
       segment28                       =     X_Segment28,
       segment29                       =     X_Segment29,
       segment30                       =     X_Segment30
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM GL_RECURRING_LINE_CALC_RULES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

-- **********************************************************************
  PROCEDURE get_account_type( x_coa_id             NUMBER,
                              x_conc_seg           VARCHAR2,
                              x_account_type   OUT NOCOPY VARCHAR2) IS
  BEGIN
    IF (x_conc_seg IS NOT NULL) THEN
       IF(fnd_flex_keyval.validate_segs(
                   operation	        => 'CHECK_COMBINATION',
                   appl_short_name	=> 'SQLGL',
                   key_flex_code	=> 'GL#',
	           structure_number     => x_coa_id,
	           concat_segments	=> x_conc_seg,
                   validation_date      => null)) THEN
          x_account_type := fnd_flex_keyval.qualifier_value('GL_ACCOUNT_TYPE');
        END IF;
     END IF;

  END get_account_type;


-- **********************************************************************

END GL_RECURRING_RULES_PKG;

/
