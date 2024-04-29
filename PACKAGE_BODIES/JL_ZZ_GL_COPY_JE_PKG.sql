--------------------------------------------------------
--  DDL for Package Body JL_ZZ_GL_COPY_JE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_GL_COPY_JE_PKG" AS
/* $Header: jlzzgcjb.pls 120.8 2005/04/08 20:59:01 vsidhart ship $ */
TYPE je_source_tab IS TABLE OF VARCHAR2(30)
  INDEX BY BINARY_INTEGER;

x_last_updated_by              NUMBER(15);
x_last_update_login            NUMBER(15);
x_request_id                   NUMBER(15);
x_program_application_id       NUMBER(15);
x_program_id                   NUMBER(15);
x_sysdate                      DATE;
x_debug                        BOOLEAN := FALSE;
x_statement                    VARCHAR2(20);

detail_group_id                NUMBER(15);
summary_group_id               NUMBER(15);
x_group_id                     NUMBER(15);
x_entered_dr                   NUMBER;
x_entered_cr                   NUMBER;
x_accounted_dr                 NUMBER;
x_accounted_cr                 NUMBER;
create_summary_journals        VARCHAR2(3);

PROCEDURE find_who_columns;
PROCEDURE get_import_group_id(p_summary IN OUT NOCOPY NUMBER,p_detail IN OUT NOCOPY NUMBER);
FUNCTION  run_import_journal(p_counter NUMBER,
                            p_sob     NUMBER,
                            p_je_source_tab je_source_tab,
                            p_group_id NUMBER,
                            p_summary VARCHAR2)
return boolean;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   copy                                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to copy journal entry from one                    --
--   sets of books and put them in gl_interface table to be imported      --
--   for another sets of books.                                           --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_from_book                                                 --
--            p_to_book                                                   --
--            p_period                                                    --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    12/10/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE copy( ERRBUF      OUT NOCOPY VARCHAR2,
                RETCODE     OUT NOCOPY VARCHAR2,
                p_from_ledger   NUMBER,
                p_to_ledger     NUMBER,
                p_period        VARCHAR2) IS

  p_import        VARCHAR2(2) := 'Y';
  CURSOR c_ledgers IS
  SELECT set_of_books_id,
         name,
         chart_of_accounts_id,
         currency_code,
         period_set_name
    FROM gl_sets_of_books
   WHERE set_of_books_id IN ( p_from_ledger , p_to_ledger );

   /*
   Bug 2564710 - Commented check on posted date since it is null for Move/Merge journals
   and there will exist no journals with posted date for any other status
   */

   CURSOR c_batch IS
   SELECT je_batch_id,
          name,
          description
     FROM gl_je_batches
    WHERE actual_flag = 'A'
      --AND set_of_books_id = p_sob_id
      --AND posted_date IS NOT NULL
      AND status = 'P'
      AND default_period_name = p_period;

   /*
   Bug 2564710 - Added one more check on global_attribute1 to confirm that they are not that
   of reversed journals since for reversed journals the global attribute1 is populated with
   the original journals header id as a result of which these journals are never selected
   to be posted
   */

   /*
   Bug 2606480 - accrual_rev_flag should be considered 'N' if accrual_rev_effective_date is null
  */
   CURSOR c_header(p_batch_id NUMBER,
                   p_ledger_id NUMBER) IS
     SELECT h.je_header_id,
            h.name header_name,
            h.default_effective_date,
            h.description header_description,
            h.currency_code,
            h.currency_conversion_rate,
            d.user_conversion_type,
            h.currency_conversion_date,
            --h.accrual_rev_flag,
            decode (h.accrual_rev_effective_date, null, 'N', 'Y') accrual_rev_flag,
            h.accrual_rev_effective_date,
            h.global_attribute1,
            h.reversed_je_header_id,
            s.user_je_source_name,
            s.je_source_name,
            s.journal_reference_flag,
            c.user_je_category_name,
            c.je_category_name
      FROM  gl_je_headers h,
            gl_je_sources s,
            gl_je_categories c,
            gl_daily_conversion_types d
     WHERE  h.je_source = s.je_source_name
       AND  c.je_category_name = h.je_category
       AND  je_batch_id = p_batch_id
       AND  (NVL(global_attribute1, 0) = 0
       OR   NVL(global_attribute1,0) <> h.je_header_id)
       AND  status = 'P'
       AND  actual_flag = 'A'
       AND  je_category <> 'Revaluation'
       AND  s.je_source_name <> 'Assets'
       AND  h.currency_conversion_type = d.conversion_type
       AND  h.ledger_id = p_ledger_id
       ORDER BY s.je_source_name
       FOR UPDATE OF h.global_attribute1;

   CURSOR c_line(p_header_id NUMBER) IS
     SELECT rownum,
            l.je_line_num,
            l.entered_dr,
            l.entered_cr,
            l.accounted_dr,
            l.accounted_cr,
            l.description line_description,
            l.reference_1,
            l.reference_2,
            l.reference_3,
            l.reference_4,
            l.reference_5,
            l.reference_6,
            l.reference_7,
            l.reference_8,
            l.reference_9,
            l.reference_10,
            l.code_combination_id,
            l.stat_amount,
            l.attribute1,
            l.attribute2,
            l.attribute3,
            l.attribute4,
            l.attribute5,
            l.attribute6,
            l.attribute7,
            l.attribute8,
            l.attribute9,
            l.attribute10,
            l.attribute11,
            l.attribute12,
            l.attribute13,
            l.attribute14,
            l.attribute15,
            l.attribute16,
            l.attribute17,
            l.attribute18,
            l.attribute19,
            l.attribute20,
            l.context,
            l.context2,
            l.context3,
            l.invoice_date,
            l.tax_code,
            l.invoice_identifier,
            l.invoice_amount,
            l.ussgl_transaction_code--,
            --l.jgzz_recon_ref
       FROM gl_je_lines l
      WHERE l.je_header_id = p_header_id;

   CURSOR c_ref( p_header_id NUMBER,
                 p_line_num  NUMBER) IS
   SELECT reference_1,
          reference_2,
          reference_3,
          reference_4,
          reference_5,
          reference_6,
          reference_7,
          reference_8,
          reference_9,
          reference_10
     FROM gl_import_references
    WHERE je_header_id = p_header_id
      AND je_line_num = p_line_num;

   x_je_source_tab_sum        je_source_tab;
   x_je_source_tab_det        je_source_tab;
   x_counter_sum              NUMBER := 0;
   x_counter_det              NUMBER := 0;
   x_je_source_name_sum       VARCHAR2(30);
   x_je_source_name_det       VARCHAR2(30);

   x_from_ledger              c_ledgers%ROWTYPE;
   x_to_ledger                c_ledgers%ROWTYPE;
   x_sequence_line            NUMBER;
   x_reference_1              VARCHAR2(240);
   x_reference_2              VARCHAR2(240);
   x_reference_3              VARCHAR2(240);
   x_reference_4              VARCHAR2(240);
   x_reference_5              VARCHAR2(240);
   x_reference_6              VARCHAR2(240);
   x_reference_7              VARCHAR2(240);
   x_reference_8              VARCHAR2(240);
   x_reference_9              VARCHAR2(240);
   x_reference_10             VARCHAR2(240);


   x_number                   NUMBER :=0;
   err_num                    NUMBER;
   x_result                   BOOLEAN;
   err_msg                    VARCHAR2(2000);
   DIFF_CHART_OF_ACCT_ID      EXCEPTION;
   DIFF_CURRENCY_CODE         EXCEPTION;
   DIFF_CALENDAR              EXCEPTION;
   UNABLE_TO_IMPORT           EXCEPTION;

   x_source_index                 BINARY_INTEGER;
   x_source_row                   VARCHAR2(2) :='Y';

  BEGIN

  fnd_message.set_name('JL', 'JL_CO_FA_PARAMETER');
  fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
  fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');
  fnd_message.set_name('JL', 'JL_ZZ_GL_SOB');
  fnd_message.set_token('SOB', p_to_ledger );
  fnd_file.put_line( 1, fnd_message.get);
  fnd_message.set_name('JL', 'JL_ZZ_FA_PERIOD_NAME');
  fnd_message.set_token('PERIOD_NAME', p_period);
  fnd_file.put_line( 1, fnd_message.get);
  fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');

              ---------------------------------------------------------
              --  Find who columns                                   --
              ---------------------------------------------------------
    find_who_columns;


              ---------------------------------------------------------
              --  Get set of books information                       --
              ---------------------------------------------------------


    x_statement := 'SOB_INFO';
    FOR rec_sob IN c_ledgers LOOP
      IF (rec_sob.set_of_books_id = p_from_ledger ) THEN
        x_from_ledger .chart_of_accounts_id := rec_sob.chart_of_accounts_id;
        x_from_ledger .currency_code := rec_sob.currency_code;
        x_from_ledger .period_set_name := rec_sob.period_set_name;
        x_from_ledger .set_of_books_id := rec_sob.set_of_books_id;
        x_from_ledger .name := rec_sob.name;

      ELSE
        x_to_ledger .chart_of_accounts_id := rec_sob.chart_of_accounts_id;
        x_to_ledger .currency_code := rec_sob.currency_code;
        x_to_ledger .period_set_name := rec_sob.period_set_name;
        x_to_ledger .set_of_books_id := rec_sob.set_of_books_id;
        x_to_ledger .name := rec_sob.name;
      END IF;
    END LOOP;
              ---------------------------------------------------------
              --  Finish the program with error incase of following  --
              --  conditions.                                        --
              --    a) Chart of account id is not same for both books--
              --    b) Currency code not same for both books         --
              --    c) calendar is not same for both books           --
              ---------------------------------------------------------
    IF  (x_from_ledger.chart_of_accounts_id <> x_to_ledger.chart_of_accounts_id) THEN
      RAISE DIFF_CHART_OF_ACCT_ID;
    END IF;

    IF  (x_from_ledger.currency_code <> x_to_ledger.currency_code) THEN
      RAISE DIFF_CURRENCY_CODE;
    END IF;

    IF  (x_from_ledger.period_set_name <> x_to_ledger.period_set_name) THEN
      RAISE DIFF_CALENDAR;
    END IF;

              -------------------------------------------------------------
              --Get Group Id's for GL_INTERFACE and GL_INTERFACE_CONTROL --
              -------------------------------------------------------------

              Get_Import_Group_Id(Summary_group_id,Detail_group_id);

              ---------------------------------------------------------
              --  Get information from gl_je_batches                 --
              ---------------------------------------------------------
    FOR rec_batch IN c_batch  LOOP

              ---------------------------------------------------------
              --  Get information from gl_je_headers                 --
              ---------------------------------------------------------
      FOR rec_header IN c_header (rec_batch.je_batch_id,x_from_ledger.set_of_books_id) LOOP

              ---------------------------------------------------------
              --  Get information from gl_je_lines                   --
              ---------------------------------------------------------
        FOR rec_line IN c_line( rec_header.je_header_id) LOOP
            ---------------------------------------------------------
            --  Assiging the Line References as default references --
            ---------------------------------------------------------

            x_reference_1 := rec_line.reference_1;
            x_reference_2 := rec_line.reference_2;
            x_reference_3 := rec_line.reference_3;
            x_reference_4 := rec_line.reference_4;
            x_reference_5 := rec_line.reference_5;
            x_reference_6 := rec_line.reference_6;
            x_reference_7 := rec_line.reference_7;
            x_reference_8 := rec_line.reference_8;
            x_reference_9 := rec_line.reference_9;
            x_reference_10 := rec_line.reference_10;

            ---------------------------------------------------------
            --  Assiging the Detail Group Id as default --
            ---------------------------------------------------------


            x_group_id := detail_group_id;

            ---------------------------------------------------------
            --  Check Journal's Source Import References Flag      --
            ---------------------------------------------------------


         IF (rec_header.journal_reference_flag = 'Y'
            AND rec_header.reversed_je_header_id IS NULL) THEN


                        x_entered_dr   :=  rec_line.entered_dr;
                        x_entered_cr   :=  rec_line.entered_cr;
                        x_accounted_dr :=  rec_line.accounted_dr;
                        x_accounted_cr :=  rec_line.accounted_cr;

            ---------------------------------------------------------
            --  Get information from table gl_import_references    --
            ---------------------------------------------------------

           ---------------------------------------------------------------------------
           -- Bug 2757223                                                           --
           -- Irrespective of whether records exist in gl_import_references         --
           -- we need to insert into gl_interface if the import journal reference   --
           -- for manual source is set. Moved the End Loop from after insert to     --
           -- Before insert insert into gl_interface                                --
           ---------------------------------------------------------------------------

          FOR rec_ref IN c_ref(rec_header.je_header_id, rec_line.je_line_num) LOOP


            IF nvl(rec_line.reference_1,'X') = nvl(rec_ref.reference_1,'X')   AND
               nvl(rec_line.reference_2,'X') = nvl(rec_ref.reference_2,'X')   AND
               nvl(rec_line.reference_3,'X') = nvl(rec_ref.reference_3,'X')   AND
               nvl(rec_line.reference_4,'X') = nvl(rec_ref.reference_4,'X')   AND
               nvl(rec_line.reference_5,'X') = nvl(rec_ref.reference_5,'X')   AND
               nvl(rec_line.reference_6,'X') = nvl(rec_ref.reference_6,'X')   AND
               nvl(rec_line.reference_7,'X') = nvl(rec_ref.reference_7,'X')   AND
               nvl(rec_line.reference_8,'X') = nvl(rec_ref.reference_8,'X')   AND
               nvl(rec_line.reference_9,'X') = nvl(rec_ref.reference_9,'X')   AND
               nvl(rec_line.reference_10,'X')= nvl(rec_ref.reference_10,'X') THEN

               -- Do Nothing --
               Null;
            ELSE
               x_group_id := Summary_group_id;
               x_reference_1 := rec_ref.reference_1;
               x_reference_2 := rec_ref.reference_2;
               x_reference_3 := rec_ref.reference_3;
               x_reference_4 := rec_ref.reference_4;
               x_reference_5 := rec_ref.reference_5;
               x_reference_6 := rec_ref.reference_6;
               x_reference_7 := rec_ref.reference_7;
               x_reference_8 := rec_ref.reference_8;
               x_reference_9 := rec_ref.reference_9;
               x_reference_10 := rec_ref.reference_10;
            END IF;

           END LOOP;
          x_number := x_number +1;
              ---------------------------------------------------------
              --  Insert row into gl_interface                       --
              ---------------------------------------------------------
          x_statement := 'INS_GLIF';

/*Bug 3934813 - if we have two journals with the firsts 50 positions same in reference1 and first 25 positions same in reference4 fields, these two
journals will copy in only one journal. This is the expected behavior for Journal Import.  Journal Import only looks at the first 50 characters
of reference1 and the first 25 characters of reference4 while grouping.  This logic has been changed in 11iX, but doing so in release 11i
would require a major rewrite of Journal Import, which is not feasible at this time.

Suggestion from GL team is to transfer the first 40 characters of the batch name into reference1, and  follow them with the je_batch_id.
Then, transfer the first 15 characters of the journal name into reference4, and follow them with the je_header_id */

          INSERT INTO gl_interface(
                         STATUS,
                         SET_OF_BOOKS_ID,
                         ACCOUNTING_DATE,
                         CURRENCY_CODE,
                         DATE_CREATED,
                         CREATED_BY,
                         ACTUAL_FLAG ,
                         USER_JE_CATEGORY_NAME,
                         USER_JE_SOURCE_NAME,
                         CURRENCY_CONVERSION_DATE,
                         USER_CURRENCY_CONVERSION_TYPE,
                         CURRENCY_CONVERSION_RATE,
                         ENTERED_DR,
                         ENTERED_CR ,
                         ACCOUNTED_DR,
                         ACCOUNTED_CR,
                         REFERENCE1,
                         REFERENCE2 ,
                         REFERENCE4,
                         REFERENCE5,
                         REFERENCE6,
                         REFERENCE7,
                         REFERENCE8,
                         REFERENCE10,
                         REFERENCE21,
                         REFERENCE22,
                         REFERENCE23,
                         REFERENCE24,
                         REFERENCE25,
                         REFERENCE26,
                         REFERENCE27,
                         REFERENCE28,
                         REFERENCE29,
                         REFERENCE30,
                         CODE_COMBINATION_ID,
                         STAT_AMOUNT,
                         GROUP_ID,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5 ,
                         ATTRIBUTE6,
                         ATTRIBUTE7 ,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         ATTRIBUTE16,
                         ATTRIBUTE17,
                         ATTRIBUTE18,
                         ATTRIBUTE19,
                         ATTRIBUTE20,
                         CONTEXT,
                         CONTEXT2,
                         INVOICE_DATE,
                         TAX_CODE,
                         INVOICE_IDENTIFIER,
                         INVOICE_AMOUNT,
                         CONTEXT3 ,
                         USSGL_TRANSACTION_CODE--,
                         --JGZZ_RECON_REF
                         )
                 VALUES( 'NEW',
                         x_to_ledger.set_of_books_id,
                         rec_header.default_effective_date,
                         rec_header.currency_code,
                         x_sysdate,
                         x_last_updated_by,
                         'A',
                         rec_header.user_je_category_name,
                         rec_header.user_je_source_name,
                         rec_header.currency_conversion_date,
                         rec_header.user_conversion_type,
                         rec_header.currency_conversion_rate,
                         x_entered_dr,
                         x_entered_cr,
                         x_accounted_dr,
                         x_accounted_cr,
                         substr(rec_batch.name,1,40)|| to_char(rec_header.je_header_id),
                         rec_batch.description,
                         substr(rec_header.header_name,1,15)||to_char(rec_header.je_header_id),
                         rec_header.header_description,
                         to_char(rec_header.je_header_id),
                         rec_header.accrual_rev_flag,
                         rec_header.accrual_rev_effective_date,
                         rec_line.line_description,
                         x_reference_1,
                         x_reference_2,
                         x_reference_3,
                         x_reference_4,
                         x_reference_5,
                         x_reference_6,
                         x_reference_7,
                         x_reference_8,
                         x_reference_9,
                         x_reference_10,
                         rec_line.code_combination_id,
                         rec_line.stat_amount,
                         x_group_id,
                         rec_line.attribute1,
                         rec_line.attribute2,
                         rec_line.attribute3,
                         rec_line.attribute4,
                         rec_line.attribute5,
                         rec_line.attribute6,
                         rec_line.attribute7,
                         rec_line.attribute8,
                         rec_line.attribute9,
                         rec_line.attribute10,
                         rec_line.attribute11,
                         rec_line.attribute12,
                         rec_line.attribute13,
                         rec_line.attribute14,
                         rec_line.attribute15,
                         rec_line.attribute16,
                         rec_line.attribute17,
                         rec_line.attribute18,
                         rec_line.attribute19,
                         rec_line.attribute20,
                         rec_line.context,
                         rec_line.context2,
                         rec_line.invoice_date,
                         rec_line.tax_code,
                         rec_line.invoice_identifier,
                         rec_line.invoice_amount,
                         rec_line.context3,
                         rec_line.ussgl_transaction_code--,
                         --rec_line.jgzz_recon_ref
                         );


                       If rec_line.entered_dr is Null Then
                        x_entered_dr   :=  Null;
                        x_accounted_dr :=  Null;
                        x_entered_cr   :=  0;
                        x_accounted_cr :=  0;
                       Else
                        x_entered_dr   :=  0;
                        x_accounted_dr :=  0;
                        x_entered_cr   :=  Null;
                        x_accounted_cr :=  Null;
                       End If;

           --END LOOP; --bug 2757223

          ELSE

                    x_number := x_number +1;
              ---------------------------------------------------------
              --  Insert row into gl_interface                       --
              ---------------------------------------------------------
          x_statement := 'INS_GLIF';
          INSERT INTO gl_interface(
                         STATUS,
                         SET_OF_BOOKS_ID,
                         ACCOUNTING_DATE,
                         CURRENCY_CODE,
                         DATE_CREATED,
                         CREATED_BY,
                         ACTUAL_FLAG ,
                         USER_JE_CATEGORY_NAME,
                         USER_JE_SOURCE_NAME,
                         CURRENCY_CONVERSION_DATE,
                         USER_CURRENCY_CONVERSION_TYPE,
                         CURRENCY_CONVERSION_RATE,
                         ENTERED_DR,
                         ENTERED_CR ,
                         ACCOUNTED_DR,
                         ACCOUNTED_CR,
                         REFERENCE1,
                         REFERENCE2 ,
                         REFERENCE4,
                         REFERENCE5,
                         REFERENCE6,
                         REFERENCE7,
                         REFERENCE8,
                         REFERENCE10,
                         REFERENCE21,
                         REFERENCE22,
                         REFERENCE23,
                         REFERENCE24,
                         REFERENCE25,
                         REFERENCE26,
                         REFERENCE27,
                         REFERENCE28,
                         REFERENCE29,
                         REFERENCE30,
                         CODE_COMBINATION_ID,
                         STAT_AMOUNT,
                         GROUP_ID,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5 ,
                         ATTRIBUTE6,
                         ATTRIBUTE7 ,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         ATTRIBUTE16,
                         ATTRIBUTE17,
                         ATTRIBUTE18,
                         ATTRIBUTE19,
                         ATTRIBUTE20,
                         CONTEXT,
                         CONTEXT2,
                         INVOICE_DATE,
                         TAX_CODE,
                         INVOICE_IDENTIFIER,
                         INVOICE_AMOUNT,
                         CONTEXT3 ,
                         USSGL_TRANSACTION_CODE--,
                         --JGZZ_RECON_REF
                         )
                 VALUES( 'NEW',
                         x_to_ledger.set_of_books_id,
                         rec_header.default_effective_date,
                         rec_header.currency_code,
                         x_sysdate,
                         x_last_updated_by,
                         'A',
                         rec_header.user_je_category_name,
                         rec_header.user_je_source_name,
                         rec_header.currency_conversion_date,
                         rec_header.user_conversion_type,
                         rec_header.currency_conversion_rate,
                         rec_line.entered_dr,
                         rec_line.entered_cr,
                         rec_line.accounted_dr,
                         rec_line.accounted_cr,
                         substr(rec_batch.name,1,40)|| to_char(rec_header.je_header_id),
                         rec_batch.description,
                         substr(rec_header.header_name,1,15)||to_char(rec_header.je_header_id),
                         rec_header.header_description,
                         to_char(rec_header.je_header_id),
                         rec_header.accrual_rev_flag,
                         rec_header.accrual_rev_effective_date,
                         rec_line.line_description,
                         x_reference_1,
                         x_reference_2,
                         x_reference_3,
                         x_reference_4,
                         x_reference_5,
                         x_reference_6,
                         x_reference_7,
                         x_reference_8,
                         x_reference_9,
                         x_reference_10,
                         rec_line.code_combination_id,
                         rec_line.stat_amount,
                         x_group_id,
                         rec_line.attribute1,
                         rec_line.attribute2,
                         rec_line.attribute3,
                         rec_line.attribute4,
                         rec_line.attribute5,
                         rec_line.attribute6,
                         rec_line.attribute7,
                         rec_line.attribute8,
                         rec_line.attribute9,
                         rec_line.attribute10,
                         rec_line.attribute11,
                         rec_line.attribute12,
                         rec_line.attribute13,
                         rec_line.attribute14,
                         rec_line.attribute15,
                         rec_line.attribute16,
                         rec_line.attribute17,
                         rec_line.attribute18,
                         rec_line.attribute19,
                         rec_line.attribute20,
                         rec_line.context,
                         rec_line.context2,
                         rec_line.invoice_date,
                         rec_line.tax_code,
                         rec_line.invoice_identifier,
                         rec_line.invoice_amount,
                         rec_line.context3,
                         rec_line.ussgl_transaction_code--,
                         --rec_line.jgzz_recon_ref
                         );
          END IF;

        END LOOP;


          IF     ((x_group_id = summary_group_id) AND (NVL(x_je_source_name_sum, '0') <> rec_header.je_source_name)) THEN

                  x_source_row :='Y';

                  IF x_counter_sum > 0 THEN
                     x_source_index := x_je_source_tab_sum.FIRST;
                     LOOP
                       IF x_je_source_tab_sum(x_source_index) = rec_header.je_source_name  THEN
                          x_source_row := 'N';
                          x_source_index := x_je_source_tab_sum.LAST;
                       END IF;
                     EXIT WHEN x_source_index = x_je_source_tab_sum.LAST;
                          x_source_index := x_je_source_tab_sum.NEXT(x_source_index);
                     END LOOP;
                   END IF;
                   IF x_source_row ='Y' THEN
                          x_je_source_name_sum := rec_header.je_source_name;
                          x_counter_sum := x_counter_sum +1;
                          x_je_source_tab_sum(x_counter_sum) := x_je_source_name_sum;
                   END IF;
          ElSIF  ((x_group_id = detail_group_id) AND (NVL(x_je_source_name_det, '0') <> rec_header.je_source_name)) THEN

                  x_source_row :='Y';

                  IF x_counter_det > 0 THEN
                     x_source_index := x_je_source_tab_det.FIRST;
                     LOOP
                       IF x_je_source_tab_det(x_source_index) = rec_header.je_source_name  THEN
                          x_source_row := 'N';
                          x_source_index := x_je_source_tab_det.LAST;
                       END IF;
                     EXIT WHEN x_source_index = x_je_source_tab_det.LAST;
                          x_source_index := x_je_source_tab_det.NEXT(x_source_index);
                     END LOOP;
                   END IF;

                   IF x_source_row ='Y' THEN
                      x_je_source_name_det := rec_header.je_source_name;
                      x_counter_det := x_counter_det +1;
                      x_je_source_tab_det(x_counter_det) := x_je_source_name_det;
                   END IF;

          END IF;
              ---------------------------------------------------------
              --  UPDATE gl_je_headers                               --
              ---------------------------------------------------------

        UPDATE gl_je_headers
           SET global_attribute1 = to_char(rec_header.je_header_id)
         WHERE CURRENT OF c_header;

      END LOOP;

    END LOOP;
  fnd_message.set_name('JL', 'JL_ZZ_GL_JE_PROCESSED');
  fnd_message.set_token('NUMBER', x_number);
  fnd_file.put_line( 1, fnd_message.get);

  fnd_message.set_name('JL', 'JL_ZZ_GL_JE_PROCESSED');
  fnd_message.set_token('NUMBER', x_number);
  fnd_file.put_line( FND_FILE.OUTPUT, fnd_message.get);

  COMMIT;

  IF (p_import = 'Y' AND x_counter_sum <> 0) THEN

    x_statement := 'IMPORT JE';
    create_summary_journals := 'Y';
    IF NOT(run_import_journal(x_counter_sum,
                              p_to_ledger,
                              x_je_source_tab_sum,
                              Summary_group_id,create_summary_journals)) THEN

       RAISE UNABLE_TO_IMPORT;
    END IF;
   END IF;

  IF (p_import = 'Y' AND x_counter_det <> 0) THEN
    create_summary_journals := 'N';
    IF NOT(run_import_journal(x_counter_det,
                              p_to_ledger,
                              x_je_source_tab_det,
                              Detail_group_id,create_summary_journals)) THEN

       RAISE UNABLE_TO_IMPORT;
    END IF;
  END IF;
  EXCEPTION
     WHEN  DIFF_CHART_OF_ACCT_ID THEN

      fnd_message.set_name('JL', 'JL_ZZ_GL_DIFF_CHAT_OF_ACCT_ID');
      fnd_message.set_token('TO_BOOK', x_to_ledger.name);
      fnd_message.set_token('FROM_BOOK', x_from_ledger.name);
      err_msg := fnd_message.get;
       app_exception.raise_exception (exception_type => 'APP',
         exception_code =>
         jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_GL_DIFF_CHAT_OF_ACCT_ID'),
         exception_text => err_msg);

    WHEN DIFF_CURRENCY_CODE THEN

      fnd_message.set_name('JL', 'JL_ZZ_GL_DIFF_CURRENCY_CODE');
      fnd_message.set_token('TO_BOOK', x_to_ledger.name);
      fnd_message.set_token('FROM_BOOK', x_from_ledger.name);
      err_msg := fnd_message.get;
       app_exception.raise_exception (exception_type => 'APP',
         exception_code =>
         jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_GL_DIFF_CURRENCY_CODE'),
         exception_text => err_msg);

    WHEN DIFF_CALENDAR THEN

      fnd_message.set_name('JL', 'JL_ZZ_GL_DIFF_CALENDAR');
      fnd_message.set_token('TO_BOOK', x_to_ledger.name);
      fnd_message.set_token('FROM_BOOK', x_from_ledger.name);
      err_msg := fnd_message.get;
       app_exception.raise_exception (exception_type => 'APP',
         exception_code =>
         jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_GL_DIFF_CALENDAR'),
         exception_text => err_msg);

    WHEN UNABLE_TO_IMPORT THEN

      ROLLBACK;
      fnd_message.set_name('JL', 'JL_ZZ_GL_CANNT_RUN_JOURNAL_IMP');
      fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
      x_result := fnd_concurrent.set_completion_status( status => 'WARNING',
                                          message => '');

    WHEN OTHERS THEN

        IF x_statement = 'SOB_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '1');
        err_msg := fnd_message.get;
        ROLLBACK;
        app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_FA_EXEC_FAILURE'),
        exception_text => err_msg);

      ELSIF x_statement = 'SEQ_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '2');
        err_msg := fnd_message.get;
        ROLLBACK;
        app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_FA_EXEC_FAILURE'),
        exception_text => err_msg);

      ELSIF x_statement = 'INS_GLIF' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '3');
        err_msg := fnd_message.get;
        ROLLBACK;
        app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_FA_EXEC_FAILURE'),
        exception_text => err_msg);

      ELSE
        fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
        fnd_file.put_line( fnd_file.log, fnd_message.get);
        err_num := SQLCODE;
        err_msg := substr(SQLERRM, 1, 200);
        ROLLBACK;
        RAISE_APPLICATION_ERROR( err_num, err_msg);
      END IF;

  END;
----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   find_who_columns                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to find the values for WHO columns.               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
-- HISTORY:                                                               --
--    08/12/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE find_who_columns IS

  BEGIN

    x_last_updated_by := fnd_global.user_id;
    x_last_update_login := fnd_global.login_id;
    x_request_id := fnd_global.conc_request_id;
    x_program_application_id := fnd_global.prog_appl_id;
    x_program_id  := fnd_global.conc_program_id;
    x_sysdate     := SYSDATE;

    IF x_debug THEN
      fnd_file.put_line( 1, 'last_update_login:'||to_char(x_last_update_login));
      fnd_file.put_line( 1, 'last_updated_by:'||to_char(x_last_updated_by));
      fnd_file.put_line( 1, 'last_request_id:'||to_char(x_request_id));
      fnd_file.put_line( 1, 'x_program_application_id :'||to_char(x_program_application_id ));
      fnd_file.put_line( 1, 'x_program_id :'||to_char(x_program_id ));
      fnd_file.put_line( 1, 'x_sysdate :'||to_char(x_sysdate ));

    END IF;

END find_who_columns;

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   run_import_journal                                                   --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function to import journal                                  --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- HISTORY:                                                               --
--    12/01/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

FUNCTION run_import_journal(p_counter NUMBER,
                            p_sob     NUMBER,
                            p_je_source_tab je_source_tab,
                            p_group_id NUMBER,
                            p_summary varchar2)
return boolean IS
   x_interface_run_id         NUMBER;
   x_request_id               NUMBER;
BEGIN
    SELECT gl_journal_import_s.nextval
      INTO x_interface_run_id
      FROM sys.DUAL;
    FOR i IN 1..p_counter LOOP

      INSERT INTO gl_interface_control( je_source_name,
                                        status,
                                        interface_run_id,
                                        group_id,
                                        set_of_books_id,
                                        packet_id)
                                VALUES( p_je_source_tab(i),
                                        'S',
                                        x_interface_run_id,
                                        p_group_id,
                                        p_sob,
                                        NULL);

    END LOOP;

     x_request_id := fnd_request.submit_request('SQLGL',
                                               'GLLEZL',
                                               '',
                                               '',
                                               FALSE,
                                               TO_CHAR(x_interface_run_id),
                                               TO_CHAR(p_sob),
                                               'N',
                                               '',
                                               '',
                                               p_summary,
                                               'Y',
                                               chr(0),
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '', '', '', '', '', '', '', '', '',
                                               '', '');

    IF x_request_id = 0  THEN
      ROLLBACK;
      RETURN (FALSE);
    ELSE
      COMMIT;
      RETURN (TRUE);
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN (FALSE);

END run_import_journal;


PROCEDURE get_import_group_id(p_summary IN OUT NOCOPY NUMBER,p_detail IN OUT NOCOPY NUMBER) IS
BEGIN
     -------------------------------------
     -- Get Summary Journals Group Id.  --
     -------------------------------------

     SELECT gl_interface_control_s.nextval
        INTO p_summary
        FROM sys.dual;

     -------------------------------------
     -- Get Detail Journals Group Id.  --
     -------------------------------------

      SELECT gl_interface_control_s.nextval
        INTO p_detail
        FROM sys.dual;

END get_import_group_id;

END jl_zz_gl_copy_je_pkg;

/
