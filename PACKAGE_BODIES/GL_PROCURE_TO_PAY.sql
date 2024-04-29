--------------------------------------------------------
--  DDL for Package Body GL_PROCURE_TO_PAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PROCURE_TO_PAY" AS
/* $Header: gluprocb.pls 120.2 2006/03/22 05:50:05 adesu ship $ */

  --
  -- PUBLIC FUNCTIONS
  --

  --
  -- Procedure
  --   export_from_gl_interface
  -- Purpose
  --   Export all data from GL_INTERFACE into a flat file and purge GL_INTERFACE.
  --   (details in the package specifications).
  -- History
  --   04-18-01   O Monnier		Created
  -- Arguments
  --   x_filename		        The file name
  --   x_dir		            The directory
  --   x_output_type            The output type (TEXT or XML)
  PROCEDURE export_from_gl_interface( x_filename             VARCHAR2,
                                      x_dir                  VARCHAR2,
                                      x_output_type          VARCHAR2)
  IS
    CURSOR c_gl_interface IS
      SELECT TRANSLATE(i.status,',',' ') AS status,
             LTRIM(TO_CHAR(i.set_of_books_id,'999999999999999')) AS set_of_books_id,
             TO_CHAR(i.accounting_date,'YYYY/MM/DD') AS accounting_date,
             TRANSLATE(i.currency_code,',',' ') AS currency_code,
             TO_CHAR(i.date_created,'YYYY/MM/DD') AS date_created,
             LTRIM(TO_CHAR(i.created_by,'999999999999999')) AS created_by,
             i.actual_flag AS actual_flag,
             TRANSLATE(i.user_je_category_name,',',' ') AS user_je_category_name,
             TRANSLATE(i.user_je_source_name,',',' ') AS user_je_source_name,
             TO_CHAR(i.currency_conversion_date,'YYYY/MM/DD') AS currency_conversion_date,
             LTRIM(TO_CHAR(i.encumbrance_type_id,'999999999999999')) AS encumbrance_type_id,
             LTRIM(TO_CHAR(i.budget_version_id,'999999999999999')) AS budget_version_id,
             TRANSLATE(i.user_currency_conversion_type,',',' ') AS user_currency_conversion_type,
             LTRIM(TO_CHAR(i.currency_conversion_rate,'999999999999999999999.999999999999')) AS currency_conversion_rate,
             TRANSLATE(i.originating_bal_seg_value,',',' ') AS originating_bal_seg_value,
             TRANSLATE(cc.segment1,',',' ') AS segment1,
             TRANSLATE(cc.segment2,',',' ') AS segment2,
             TRANSLATE(cc.segment3,',',' ') AS segment3,
             TRANSLATE(cc.segment4,',',' ') AS segment4,
             TRANSLATE(cc.segment5,',',' ') AS segment5,
             LTRIM(TO_CHAR(i.entered_dr,'999999999999999999999.999999999999')) AS entered_dr,
             LTRIM(TO_CHAR(i.entered_cr,'999999999999999999999.999999999999')) AS entered_cr,
             LTRIM(TO_CHAR(i.accounted_dr,'999999999999999999999.999999999999')) AS accounted_dr,
             LTRIM(TO_CHAR(i.accounted_cr,'999999999999999999999.999999999999')) AS accounted_cr,
             TRANSLATE(i.reference1,',',' ') AS batch_name,
             TRANSLATE(i.reference2,',',' ') AS batch_description,
             TRANSLATE(i.reference3,',',' ') AS dual_currency_rate,
             TRANSLATE(i.reference4,',',' ') AS journal_name,
             TRANSLATE(i.reference5,',',' ') AS journal_description,
             TRANSLATE(i.reference6,',',' ') AS journal_reference,
             TRANSLATE(i.reference7,',',' ') AS journal_reversal_flag,
             TRANSLATE(i.reference8,',',' ') AS journal_reversal_period,
             TRANSLATE(i.reference9,',',' ') AS journal_reversal_method,
             TRANSLATE(i.reference10,',',' ') AS line_description,
             TRANSLATE(i.reference21,',',' ') AS line_reference1,
             TRANSLATE(i.reference22,',',' ') AS line_reference2,
             TRANSLATE(i.reference23,',',' ') AS line_reference3,
             TRANSLATE(i.reference24,',',' ') AS line_reference4,
             TRANSLATE(i.reference25,',',' ') AS line_reference5,
             TRANSLATE(i.reference26,',',' ') AS line_reference6,
             TRANSLATE(i.reference27,',',' ') AS line_reference7,
             TRANSLATE(i.reference28,',',' ') AS line_reference8,
             TRANSLATE(i.reference29,',',' ') AS line_reference9,
             TRANSLATE(i.reference30,',',' ') AS line_reference10,
             LTRIM(TO_CHAR(i.stat_amount,'999999999999999999999.999999999999')) AS stat_amount,
             LTRIM(TO_CHAR(i.group_id,'999999999999999')) AS group_id,
             LTRIM(TO_CHAR(i.subledger_doc_sequence_id,'999999999999999')) AS subledger_doc_sequence_id,
             LTRIM(TO_CHAR(i.subledger_doc_sequence_value,'999999999999999999999.999999999999')) AS subledger_doc_sequence_value,
             TRANSLATE(i.ussgl_transaction_code,',',' ') AS ussgl_transaction_code,
             TRANSLATE(i.jgzz_recon_ref,',',' ') AS jgzz_recon_ref,
             LTRIM(TO_CHAR(i.gl_sl_link_id,'999999999999999')) AS gl_sl_link_id,
             TRANSLATE(i.gl_sl_link_table,',',' ') AS gl_sl_link_table,
             TRANSLATE(s.name,',',' ') AS set_of_books_name,
             TRANSLATE(f.id_flex_structure_code,',',' ') AS id_flex_structure_code,
             LTRIM(TO_CHAR(i.code_combination_id,'999999999999999')) AS code_combination_id,
             cc.account_type AS account_type,
             cc.enabled_flag AS enabled_flag,
             cc.summary_flag AS summary_flag,
             TRANSLATE(s.period_set_name,',',' ') AS period_set_name,
             TRANSLATE(d.period_name,',',' ') AS period_name,
             LTRIM(TO_CHAR(p.period_year,'999999999999999')) AS period_year,
             LTRIM(TO_CHAR(p.period_num,'999999999999999')) AS period_num,
             LTRIM(TO_CHAR(p.quarter_num,'999999999999999')) AS quarter_num,
             LTRIM(TO_CHAR(i.ledger_id,'999999999999999')) AS ledger_id
      FROM GL_INTERFACE i,
           GL_SETS_OF_BOOKS s,
           FND_ID_FLEX_STRUCTURES f,
           GL_DATE_PERIOD_MAP d,
           GL_PERIODS p,
           GL_CODE_COMBINATIONS cc
      WHERE f.id_flex_num = s.chart_of_accounts_id
      AND   f.id_flex_code = 'GL#'
      AND   f.application_id = 101
      AND   p.period_name = d.period_name
      AND   p.period_set_name = d.period_set_name
      AND   d.accounting_date = trunc(i.accounting_date)
      AND   d.period_type     = s.accounted_period_type
      AND   d.period_set_name = s.period_set_name
      AND   s.set_of_books_id = decode(i.ledger_id, -1, i.set_of_books_id, i.ledger_id)
      AND   cc.code_combination_id (+) = i.code_combination_id
      AND   i.request_id + 0 = -2;

    p_gl_interface           c_gl_interface%ROWTYPE;
    OUT_FNAME	             VARCHAR2(255);             -- file name
    TEMP_DIR                 VARCHAR2(255);             -- directory
    F_OUT                    UTL_FILE.FILE_TYPE;        -- file handle
    MAX_LINESIZE             BINARY_INTEGER := 32767;   -- maximum size for each line in bytes
    v_num_line_exported      NUMBER := 0;               -- number of lines exported to the file
    v_num_line_in_table      NUMBER := 0;               -- number of lines in the table
    v_num_line_deleted       NUMBER := 0;               -- number of lines deleted
    user_error               VARCHAR2(255);             -- to store translated file_error
    FOREIGN_KEY_ERROR        EXCEPTION;
    DELETE_ERROR             EXCEPTION;

  BEGIN
    --
    -- Default the parameters
    --
    OUT_FNAME := x_filename;
    TEMP_DIR := x_dir;

    IF (OUT_FNAME IS NULL) THEN
      IF (UPPER(x_output_type) = 'XML') THEN
        OUT_FNAME := 'default.xml';
      ELSE
        OUT_FNAME := 'default.out';
      END IF;
    END IF;

    IF (TEMP_DIR IS NULL) THEN
      -- Use first entry of the 'utl_file_dir' parameter as the TEMP_DIR
      SELECT SUBSTRB(TRANSLATE(LTRIM(value),',',' '),
                     1,
                     INSTR( TRANSLATE(LTRIM(value),',',' ')||' ' ,' ') - 1)
      INTO TEMP_DIR
      FROM v$parameter
      WHERE name = 'utl_file_dir';

      -- Default the directory to the current directory if any directory is accessible.
      IF (TEMP_DIR = '*') THEN
        TEMP_DIR := '.';
      END IF;

      -- Raise an exception if no directory is specified in 'utl_file_dir'.
      IF ( TEMP_DIR IS NULL ) THEN
        RAISE UTL_FILE.INVALID_PATH;
      END IF;
    END IF;

    --
    -- Open and close file to use the workaround for bug
    --
    F_OUT := UTL_FILE.FOPEN(TEMP_DIR, OUT_FNAME, 'a');
    BEGIN
      UTL_FILE.FCLOSE(F_OUT);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    --
    -- Opening the file handle in APPEND mode
    --
    F_OUT := UTL_FILE.FOPEN(TEMP_DIR, OUT_FNAME, 'a', MAX_LINESIZE);

    -- Mark all the data in the GL_INTERFACE table
    UPDATE GL_INTERFACE
    SET request_id = -2;

    -- Count the number of rows in the table
    v_num_line_in_table := SQL%ROWCOUNT;

    --
    -- Insert all data into GL_INTERFACE_HISTORY as a back-up.
    --
    -- Bug Fix 5056457. Replaced the i.set_of_books_id with
    -- decode(i.ledger_id, -1, i.set_of_books_id, i.ledger_id)
    -- in the where clause, as either column could be used to
    -- store ledger id.

    INSERT INTO GL_INTERFACE_HISTORY(status,
                                     set_of_books_id,
                                     accounting_date,
                                     currency_code,
                                     date_created,
                                     created_by,
                                     actual_flag,
                                     user_je_category_name,
                                     user_je_source_name,
                                     encumbrance_type_id,
                                     budget_version_id,
                                     currency_conversion_date,
                                     user_currency_conversion_type,
                                     currency_conversion_rate,
                                     average_journal_flag,
                                     originating_bal_seg_value,
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
                                     segment30,
                                     entered_dr,
                                     entered_cr,
                                     accounted_dr,
                                     accounted_cr,
                                     transaction_date,
                                     reference1,
                                     reference2,
                                     reference3,
                                     reference4,
                                     reference5,
                                     reference6,
                                     reference7,
                                     reference8,
                                     reference9,
                                     reference10,
                                     reference11,
                                     reference12,
                                     reference13,
                                     reference14,
                                     reference15,
                                     reference16,
                                     reference17,
                                     reference18,
                                     reference19,
                                     reference20,
                                     reference21,
                                     reference22,
                                     reference23,
                                     reference24,
                                     reference25,
                                     reference26,
                                     reference27,
                                     reference28,
                                     reference29,
                                     reference30,
                                     je_batch_id,
                                     period_name,
                                     je_header_id,
                                     je_line_num,
                                     chart_of_accounts_id,
                                     functional_currency_code,
                                     code_combination_id,
                                     date_created_in_gl,
                                     warning_code,
                                     status_description,
                                     stat_amount,
                                     group_id,
                                     request_id,
                                     subledger_doc_sequence_id,
                                     subledger_doc_sequence_value,
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
                                     attribute16,
                                     attribute17,
                                     attribute18,
                                     attribute19,
                                     attribute20,
                                     context,
                                     context2,
                                     invoice_date,
                                     tax_code,
                                     invoice_identifier,
                                     invoice_amount,
                                     context3,
                                     ussgl_transaction_code,
                                     descr_flex_error_message,
                                     ledger_id)
    SELECT i.status,
           i.set_of_books_id,
           i.accounting_date,
           i.currency_code,
           i.date_created,
           i.created_by,
           i.actual_flag,
           i.user_je_category_name,
           i.user_je_source_name,
           i.encumbrance_type_id,
           i.budget_version_id,
           i.currency_conversion_date,
           i.user_currency_conversion_type,
           i.currency_conversion_rate,
           i.average_journal_flag,
           i.originating_bal_seg_value,
           i.segment1,
           i.segment2,
           i.segment3,
           i.segment4,
           i.segment5,
           i.segment6,
           i.segment7,
           i.segment8,
           i.segment9,
           i.segment10,
           i.segment11,
           i.segment12,
           i.segment13,
           i.segment14,
           i.segment15,
           i.segment16,
           i.segment17,
           i.segment18,
           i.segment19,
           i.segment20,
           i.segment21,
           i.segment22,
           i.segment23,
           i.segment24,
           i.segment25,
           i.segment26,
           i.segment27,
           i.segment28,
           i.segment29,
           i.segment30,
           i.entered_dr,
           i.entered_cr,
           i.accounted_dr,
           i.accounted_cr,
           i.transaction_date,
           i.reference1,
           i.reference2,
           i.reference3,
           i.reference4,
           i.reference5,
           i.reference6,
           i.reference7,
           i.reference8,
           i.reference9,
           i.reference10,
           i.reference11,
           i.reference12,
           i.reference13,
           i.reference14,
           i.reference15,
           i.reference16,
           i.reference17,
           i.reference18,
           i.reference19,
           i.reference20,
           i.reference21,
           i.reference22,
           i.reference23,
           i.reference24,
           i.reference25,
           i.reference26,
           i.reference27,
           i.reference28,
           i.reference29,
           i.reference30,
           i.je_batch_id,
           i.period_name,
           i.je_header_id,
           i.je_line_num,
           i.chart_of_accounts_id,
           i.functional_currency_code,
           i.code_combination_id,
           i.date_created_in_gl,
           i.warning_code,
           i.status_description,
           i.stat_amount,
           i.group_id,
           i.request_id,
           i.subledger_doc_sequence_id,
           i.subledger_doc_sequence_value,
           i.attribute1,
           i.attribute2,
           i.attribute3,
           i.attribute4,
           i.attribute5,
           i.attribute6,
           i.attribute7,
           i.attribute8,
           i.attribute9,
           i.attribute10,
           i.attribute11,
           i.attribute12,
           i.attribute13,
           i.attribute14,
           i.attribute15,
           i.attribute16,
           i.attribute17,
           i.attribute18,
           i.attribute19,
           i.attribute20,
           i.context,
           i.context2,
           i.invoice_date,
           i.tax_code,
           i.invoice_identifier,
           i.invoice_amount,
           i.context3,
           i.ussgl_transaction_code,
           i.descr_flex_error_message,
           i.ledger_id
    FROM GL_INTERFACE i,
         GL_SETS_OF_BOOKS s,
         FND_ID_FLEX_STRUCTURES f,
         GL_DATE_PERIOD_MAP d,
         GL_PERIODS p
    WHERE f.id_flex_num = s.chart_of_accounts_id
    AND   f.id_flex_code = 'GL#'
    AND   f.application_id = 101
    AND   p.period_name = d.period_name
    AND   p.period_set_name = d.period_set_name
    AND   d.accounting_date = trunc(i.accounting_date)
    AND   d.period_type     = s.accounted_period_type
    AND   d.period_set_name = s.period_set_name
    AND   s.set_of_books_id = decode(i.ledger_id, -1, i.set_of_books_id, i.ledger_id)
    AND   i.request_id + 0 = -2;

    -- Count the number of rows that would be retrieved by the cursor
    -- We need to count this number before writing to the file, because
    -- we cannot delete any data from the file afterwards.
    v_num_line_exported := SQL%ROWCOUNT;

    --
    -- Abort if some lines would not be processed because some foreign
    -- key information is missing.
    --
    IF (v_num_line_exported <> v_num_line_in_table) THEN
      RAISE FOREIGN_KEY_ERROR;
    END IF;

    --
    -- Write Data to the file
    --
    IF (UPPER(x_output_type) = 'XML') THEN

      --
      -- XML format
      --
      -- Bug Fix 5056457. Added code to insert ledger_id field in the xml/text file.

      UTL_FILE.PUT_LINE (F_OUT,'<?xml version="1.0"?>');
      UTL_FILE.FFLUSH(F_OUT);
      UTL_FILE.PUT_LINE (F_OUT,'<GlInterfaceExport>');
      UTL_FILE.FFLUSH(F_OUT);

      FOR p_gl_interface IN c_gl_interface LOOP
        UTL_FILE.PUT_LINE (F_OUT,'  <GlInterface>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <Status>'||p_gl_interface.status||'</Status>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <SetOfBooksId>'||p_gl_interface.set_of_books_id||'</SetOfBooksId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <AccountingDate>'||p_gl_interface.accounting_date||'</AccountingDate>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <CurrencyCode>'||p_gl_interface.currency_code||'</CurrencyCode>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <DateCreated>'||p_gl_interface.date_created||'</DateCreated>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <CreatedBy>'||p_gl_interface.created_by||'</CreatedBy>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <ActualFlag>'||p_gl_interface.actual_flag||'</ActualFlag>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <UserJeCategoryName>'||p_gl_interface.user_je_category_name||'</UserJeCategoryName>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <UserJeSourceName>'||p_gl_interface.user_je_source_name||'</UserJeSourceName>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <CurrencyConversionDate>'||p_gl_interface.currency_conversion_date||'</CurrencyConversionDate>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <EncumbranceTypeId>'||p_gl_interface.encumbrance_type_id||'</EncumbranceTypeId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <BudgetVersionId>'||p_gl_interface.budget_version_id||'</BudgetVersionId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <UserCurrencyConversionType>'||p_gl_interface.user_currency_conversion_type||'</UserCurrencyConversionType>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <CurrencyConversionRate>'||p_gl_interface.currency_conversion_rate||'</CurrencyConversionRate>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <OriginatingBalSegValue>'||p_gl_interface.originating_bal_seg_value||'</OriginatingBalSegValue>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <Segment1>'||p_gl_interface.segment1||'</Segment1>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <Segment2>'||p_gl_interface.segment2||'</Segment2>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <Segment3>'||p_gl_interface.segment3||'</Segment3>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <Segment4>'||p_gl_interface.segment4||'</Segment4>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <Segment5>'||p_gl_interface.segment5||'</Segment5>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <EnteredDr>'||p_gl_interface.entered_dr||'</EnteredDr>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <EnteredCr>'||p_gl_interface.entered_cr||'</EnteredCr>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <AccountedDr>'||p_gl_interface.accounted_dr||'</AccountedDr>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <AccountedCr>'||p_gl_interface.accounted_cr||'</AccountedCr>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <BatchName>'||p_gl_interface.batch_name||'</BatchName>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <BatchDescription>'||p_gl_interface.batch_description||'</BatchDescription>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <DualCurrencyRate>'||p_gl_interface.dual_currency_rate||'</DualCurrencyRate>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <JournalName>'||p_gl_interface.journal_name||'</JournalName>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <JournalDescription>'||p_gl_interface.journal_description||'</JournalDescription>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <JournalReference>'||p_gl_interface.journal_reference||'</JournalReference>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <JournalReversalFlag>'||p_gl_interface.journal_reversal_flag||'</JournalReversalFlag>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <JournalReversalPeriod>'||p_gl_interface.journal_reversal_period||'</JournalReversalPeriod>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <JournalReversalMethod>'||p_gl_interface.journal_reversal_method||'</JournalReversalMethod>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineDescription>'||p_gl_interface.line_description||'</LineDescription>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference1>'||p_gl_interface.line_reference1||'</LineReference1>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference2>'||p_gl_interface.line_reference2||'</LineReference2>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference3>'||p_gl_interface.line_reference3||'</LineReference3>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference4>'||p_gl_interface.line_reference4||'</LineReference4>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference5>'||p_gl_interface.line_reference5||'</LineReference5>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference6>'||p_gl_interface.line_reference6||'</LineReference6>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference7>'||p_gl_interface.line_reference7||'</LineReference7>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference8>'||p_gl_interface.line_reference8||'</LineReference8>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference9>'||p_gl_interface.line_reference9||'</LineReference9>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LineReference10>'||p_gl_interface.line_reference10||'</LineReference10>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <StatAmount>'||p_gl_interface.stat_amount||'</StatAmount>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <GroupId>'||p_gl_interface.group_id||'</GroupId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <SubledgerDocSequenceId>'||p_gl_interface.subledger_doc_sequence_id||'</SubledgerDocSequenceId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <SubledgerDocSequenceValue>'||p_gl_interface.subledger_doc_sequence_value||'</SubledgerDocSequenceValue>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <UssglTransactionCode>'||p_gl_interface.ussgl_transaction_code||'</UssglTransactionCode>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <JgzzReconRef>'||p_gl_interface.jgzz_recon_ref||'</JgzzReconRef>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <GlSlLinkId>'||p_gl_interface.gl_sl_link_id||'</GlSlLinkId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <GlSlLinkTable>'||p_gl_interface.gl_sl_link_table||'</GlSlLinkTable>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <SetOfBooksName>'||p_gl_interface.set_of_books_name||'</SetOfBooksName>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <IdFlexStructureCode>'||p_gl_interface.id_flex_structure_code||'</IdFlexStructureCode>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <CodeCombinationId>'||p_gl_interface.code_combination_id||'</CodeCombinationId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <AccountType>'||p_gl_interface.account_type||'</AccountType>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <EnabledFlag>'||p_gl_interface.enabled_flag||'</EnabledFlag>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <SummaryFlag>'||p_gl_interface.summary_flag||'</SummaryFlag>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <PeriodSetName>'||p_gl_interface.period_set_name||'</PeriodSetName>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <PeriodName>'||p_gl_interface.period_name||'</PeriodName>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <PeriodYear>'||p_gl_interface.period_year||'</PeriodYear>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <PeriodNum>'||p_gl_interface.period_num||'</PeriodNum>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <QuarterNum>'||p_gl_interface.quarter_num||'</QuarterNum>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'    <LedgerId>'||p_gl_interface.ledger_id||'</LedgerId>');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,'  </GlInterface>');
      END LOOP;

      UTL_FILE.PUT_LINE (F_OUT,'</GlInterfaceExport>');
      UTL_FILE.FFLUSH(F_OUT);

    ELSE

      --
      -- Text format
      --
      FOR p_gl_interface IN c_gl_interface LOOP
        UTL_FILE.PUT (F_OUT,p_gl_interface.status||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.set_of_books_id||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.accounting_date||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.currency_code||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.date_created||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.created_by||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.actual_flag||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.user_je_category_name||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.user_je_source_name||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.currency_conversion_date||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.encumbrance_type_id||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.budget_version_id||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.user_currency_conversion_type||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.currency_conversion_rate||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.originating_bal_seg_value||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.segment1||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.segment2||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.segment3||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.segment4||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.segment5||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.entered_dr||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.entered_cr||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.accounted_dr||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.accounted_cr||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.batch_name||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.batch_description||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.dual_currency_rate||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.journal_name||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.journal_description||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.journal_reference||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.journal_reversal_flag||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.journal_reversal_period||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.journal_reversal_method||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_description||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference1||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference2||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference3||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference4||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference5||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference6||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference7||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference8||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference9||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.line_reference10||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.stat_amount||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.group_id||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.subledger_doc_sequence_id||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.subledger_doc_sequence_value||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.ussgl_transaction_code||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.jgzz_recon_ref||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.gl_sl_link_id||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.gl_sl_link_table||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.set_of_books_name||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.id_flex_structure_code||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.code_combination_id||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.account_type||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.enabled_flag||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.summary_flag||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.period_set_name||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.period_name||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.period_year||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.period_num||',');
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT (F_OUT,p_gl_interface.quarter_num);
        UTL_FILE.FFLUSH(F_OUT);
        UTL_FILE.PUT_LINE (F_OUT,p_gl_interface.ledger_id);
        UTL_FILE.FFLUSH(F_OUT);
      END LOOP;

    END IF;

    --
    -- Closing the File Handle
    --
    BEGIN
      UTL_FILE.FCLOSE(F_OUT);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    --
    -- Clean up rows from GL_INTERFACE
    --
    DELETE FROM GL_INTERFACE
    WHERE request_id + 0 = -2;

    -- Check the number of rows deleted from the table
    v_num_line_deleted := SQL%ROWCOUNT;

    IF (v_num_line_exported <> v_num_line_deleted) THEN
      RAISE DELETE_ERROR;
    END IF;

    --
    -- Print the directory and file name in the log file
    --
    BEGIN
      FND_FILE.put_line(FND_FILE.LOG,TEMP_DIR||OUT_FNAME);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

  EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
       fnd_message.set_name('FND', 'CONC-FILE_ERROR');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       user_error := substrb(fnd_message.get, 1, 255);

       fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_PATH');
       fnd_message.set_token('FILE_DIR', TEMP_DIR, FALSE);

       raise_application_error(-20100, user_error);

    WHEN UTL_FILE.INVALID_MODE THEN
       fnd_message.set_name('FND', 'CONC-FILE_ERROR');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       user_error := substrb(fnd_message.get, 1, 255);

       fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_MODE');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       fnd_message.set_token('FILE_MODE', 'w', FALSE);

       raise_application_error(-20100, user_error);

    WHEN UTL_FILE.INVALID_OPERATION THEN
       fnd_message.set_name('FND', 'CONC-FILE_ERROR');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       user_error := substrb(fnd_message.get, 1, 255);

       fnd_message.set_name('FND','CONC-TEMPFILE_INVALID_OPERATN');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       fnd_message.set_token('TEMP_DIR', TEMP_DIR, FALSE);

       raise_application_error(-20100, user_error);

    WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
       fnd_message.set_name('FND', 'CONC-FILE_ERROR');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       user_error := substrb(fnd_message.get, 1, 255);

       fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_MAXLINESIZE');
	     fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       fnd_message.set_token('MAXLINE', MAX_LINESIZE, FALSE);

       raise_application_error(-20100, user_error);

    WHEN UTL_FILE.WRITE_ERROR THEN
       fnd_message.set_name('FND', 'CONC-FILE_ERROR');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       user_error := substrb(fnd_message.get, 1, 255);

       fnd_message.set_name('FND', 'CONC-TEMPFILE_WRITE_ERROR');
       fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       fnd_message.set_token('TEMP_DIR', TEMP_DIR, FALSE);

       raise_application_error(-20100, user_error);

    WHEN DELETE_ERROR THEN
       fnd_message.set_name('FND', 'DELETE_ERROR');
       raise_application_error(-20100, 'DELETE_ERROR');

    WHEN FOREIGN_KEY_ERROR THEN
       fnd_message.set_name('FND', 'FOREIGN_KEY_ERROR');
       raise_application_error(-20100, 'FOREIGN_KEY_ERROR');

    WHEN OTHERS THEN
       app_exception.raise_exception;

  END export_from_gl_interface;

  --
  -- Procedure
  --   export_from_gl_interface
  -- Purpose
  --   Concurrent job version of export_from_gl_interface.
  -- History
  --   04-18-01   O Monnier		Created
  -- Arguments
  --   errbuf		            Standard error buffer
  --   retcode		            Standard return code
  --   x_filename		        The file name
  --   x_dir		            The directory
  --   x_output_type            The output type (TEXT or XML)
  PROCEDURE export_from_gl_interface( errbuf            OUT NOCOPY VARCHAR2,
                                      retcode           OUT NOCOPY VARCHAR2,
                                      x_filename        IN VARCHAR2,
                                      x_dir             IN VARCHAR2,
                                      x_output_type     IN VARCHAR2 ) IS
  BEGIN
    DECLARE
      l_message VARCHAR2(1000);
    BEGIN
      GL_PROCURE_TO_PAY.export_from_gl_interface(x_filename    => x_filename,
                                                 x_dir         => x_dir,
                                                 x_output_type => x_output_type);
    EXCEPTION
      WHEN OTHERS THEN
        errbuf := SQLERRM ;
        retcode := '2';
        l_message := errbuf;
        FND_FILE.put_line(FND_FILE.LOG,l_message);
        app_exception.raise_exception;
    END;
  END export_from_gl_interface;

END GL_PROCURE_TO_PAY;

/
