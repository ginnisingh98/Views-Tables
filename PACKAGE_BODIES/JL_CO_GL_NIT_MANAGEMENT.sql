--------------------------------------------------------
--  DDL for Package Body JL_CO_GL_NIT_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_GL_NIT_MANAGEMENT" AS
/* $Header: jlcoglbb.pls 120.23.12010000.23 2010/03/03 12:27:45 mbarrett ship $ */

  g_period_set_name      gl_periods.period_set_name%TYPE;
  g_account_segment      fnd_segment_attribute_values.application_column_name%TYPE;
  g_chart_of_accounts_id fnd_segment_attribute_values.id_flex_num%TYPE;
  g_period_num           gl_periods.period_num%TYPE;
  g_period_year          gl_periods.period_year%TYPE;
  g_func_currency        gl_sets_of_books.currency_code%TYPE;
  g_default_nit_id       jl_co_gl_nits.nit_id%TYPE;
  g_login_id             jl_co_gl_trx.last_update_login%TYPE;

   PROCEDURE Create_Balances(
                  p_period      IN VARCHAR2,
                  p_period_year IN NUMBER,
                  p_period_num  IN NUMBER,
                  p_sobid       IN NUMBER
   );

-- R12 Changes: Changed gljl.global_attribute1 to gjjl.co_third_party


  CURSOR journals (x_period VARCHAR2, x_sobid NUMBER, x_batchid NUMBER) IS
    SELECT gljh.je_source source,
           gljh.je_batch_id,
           gljl.je_header_id,
           gljl.je_line_num ,
           gljh.je_category category,
           gljh.reversed_je_header_id,
           gljl.code_combination_id,
           gljl.period_name,
           gljl.effective_date accounting_date,
           gljl.reference_1 ext_doc_num,
           0 extgl_nit_id,
           NVL(NVL(gljl.reference_2,NVL(gljl.CO_THIRD_PARTY,gljl.global_attribute1)),'0') ext_nit,
           SUBSTR(gljl.reference_4,1,30) ext_nit_type,
           gljl.reference_5 ext_nit_name,
           gljl.reference_3 ext_nit_v_digit,
           gljl.subledger_doc_sequence_value subl_doc_num,
           gljh.currency_code currency,
           gljl.entered_dr,
           gljl.entered_cr,
           gljl.accounted_cr,
           gljl.accounted_dr,
           gljl.reference_1 ref_1,
           gljl.reference_2 ref_2,
           gljl.reference_3 ref_3,
           gljl.reference_4 ref_4,
           gljl.reference_5 ref_5,
           gljl.reference_6 ref_6,
           gljl.reference_7 ref_7,
           gljl.reference_8 ref_8,
           gljl.reference_9 ref_9,
           gljl.reference_10 ref_10,
           DECODE(g_account_segment,
                  'SEGMENT1', glcc.segment1,  'SEGMENT2', glcc.segment2,
                  'SEGMENT3', glcc.segment3,  'SEGMENT4', glcc.segment4,
                  'SEGMENT5', glcc.segment5,  'SEGMENT6', glcc.segment6,
                  'SEGMENT7', glcc.segment7,  'SEGMENT8', glcc.segment8,
                  'SEGMENT9', glcc.segment9,  'SEGMENT10',glcc.segment10,
                  'SEGMENT11',glcc.segment11, 'SEGMENT12',glcc.segment12,
                  'SEGMENT13',glcc.segment13, 'SEGMENT14',glcc.segment14,
                  'SEGMENT15',glcc.segment15, 'SEGMENT16',glcc.segment16,
                  'SEGMENT17',glcc.segment17, 'SEGMENT18',glcc.segment18,
                  'SEGMENT19',glcc.segment19, 'SEGMENT20',glcc.segment20,
                  'SEGMENT21',glcc.segment21, 'SEGMENT22',glcc.segment22,
                  'SEGMENT23',glcc.segment23, 'SEGMENT24',glcc.segment24,
                  'SEGMENT25',glcc.segment25, 'SEGMENT26',glcc.segment26,
                  'SEGMENT27',glcc.segment27, 'SEGMENT28',glcc.segment28,
                  'SEGMENT28',glcc.segment28, 'SEGMENT29',glcc.segment29,
                  'SEGMENT30',glcc.segment30, NULL) account_code
    FROM   gl_je_headers gljh,
           gl_code_combinations glcc,
           gl_je_lines gljl
    WHERE  gljl.status = 'P'
    AND  gljl.period_name = x_period
    AND  gljl.ledger_id = x_sobid
    AND  gljh.je_batch_id = NVL(x_batchid,gljh.je_batch_id)
    AND  gljl.code_combination_id = glcc.code_combination_id
    AND  EXISTS (SELECT '1'
                 FROM   jl_co_gl_nit_accts jlcgna
                 WHERE  DECODE(g_account_segment,
                        'SEGMENT1', glcc.segment1,  'SEGMENT2', glcc.segment2,
                        'SEGMENT3', glcc.segment3,  'SEGMENT4', glcc.segment4,
                        'SEGMENT5', glcc.segment5,  'SEGMENT6', glcc.segment6,
                        'SEGMENT7', glcc.segment7,  'SEGMENT8', glcc.segment8,
                        'SEGMENT9', glcc.segment9,  'SEGMENT10',glcc.segment10,
                        'SEGMENT11',glcc.segment11, 'SEGMENT12',glcc.segment12,
                        'SEGMENT13',glcc.segment13, 'SEGMENT14',glcc.segment14,
                        'SEGMENT15',glcc.segment15, 'SEGMENT16',glcc.segment16,
                        'SEGMENT17',glcc.segment17, 'SEGMENT18',glcc.segment18,
                        'SEGMENT19',glcc.segment19, 'SEGMENT20',glcc.segment20,
                        'SEGMENT21',glcc.segment21, 'SEGMENT22',glcc.segment22,
                        'SEGMENT23',glcc.segment23, 'SEGMENT24',glcc.segment24,
                        'SEGMENT25',glcc.segment25, 'SEGMENT26',glcc.segment26,
                        'SEGMENT27',glcc.segment27, 'SEGMENT28',glcc.segment28,
                        'SEGMENT28',glcc.segment28, 'SEGMENT29',glcc.segment29,
                        'SEGMENT30',glcc.segment30, NULL) = jlcgna.account_code
                   AND  jlcgna.nit_required = 'Y'
                   AND  jlcgna.chart_of_accounts_id = g_chart_of_accounts_id)
    AND  gljl.je_header_id = gljh.je_header_id
    AND  nvl(gljl.co_processed_flag, 'N') <> 'Y'
    AND  gljh.actual_flag = 'A'
    AND gljh.currency_code <> 'STAT'
   ORDER BY gljh.je_header_id, nvl(gljh.reversed_je_header_id,0); --bug 8391172

  TYPE t_parameters IS RECORD (
                       cid jl_co_gl_conc_ctrl.process_id%type,
                       set_of_books_id jl_co_gl_conc_ctrl.set_of_books_id%type,
                       user_id jl_co_gl_conc_ctrl.created_by%type,
                       rev_cid jl_co_gl_conc_ctrl.reversed_process_id%type);

  TYPE t_nits IS RECORD (nit_id          jl_co_gl_nits.nit_id%type,
                         nit             jl_co_gl_nits.nit%type,
                         nit_name        jl_co_gl_nits.name%type,
                         nit_type        jl_co_gl_nits.type%type,
                         verifying_digit jl_co_gl_nits.verifying_digit%type);

  TYPE t_gl_je IS RECORD (je_header_id jl_co_gl_trx.je_header_id%type,
                          je_line_num  jl_co_gl_trx.je_line_num%type,
                          identifier   jl_co_gl_conc_errs.identifier%type);

  g_jl_trx            jl_co_gl_trx%ROWTYPE;
  g_journal_rec       journals%ROWTYPE;
  g_parameter_rec     t_parameters;
  g_nit_rec           t_nits;
  g_gl_je_rec         t_gl_je;
  g_error_exists      VARCHAR2(5);
  g_error_code        NUMBER;
  g_error_text        VARCHAR2(240);


  PROCEDURE Insert_Error_Rec
       (p_message_text IN VARCHAR2 )  IS

  BEGIN

    INSERT INTO jl_co_gl_conc_errs (message_text,
                                    process_id,
                                    je_header_id,
                                    je_line_num,
                                    identifier,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login)
                            VALUES (p_message_text,
                                    g_parameter_rec.cid,
                                    g_gl_je_rec.je_header_id,
                                    g_gl_je_rec.je_line_num,
                                    g_gl_je_rec.identifier,
                                    sysdate,
                                    NVL(g_parameter_rec.user_id,-1),
                                    sysdate,
                                    NVL(g_parameter_rec.user_id,-1),
                                    g_login_id );

  EXCEPTION
    WHEN others THEN
      g_error_code := SQLCODE;
      g_error_text := SUBSTR(SQLERRM,1,240);
      FND_FILE.PUT_LINE(FND_FILE.log,'Insert_Error_Rec:'|| g_error_text);
      RAISE;

  END Insert_Error_Rec;


  FUNCTION Validate_NIT
       (p_nit_rec         IN OUT NOCOPY t_nits,
        p_identifier_type IN     VARCHAR2 ) RETURN BOOLEAN IS

    -- Validate nit information against jl_co_gl_nits.
    -- If a corresponding record does not exist in jl_co_gl_nits,
    --    insert a new nit record

    l_master_nit_rec    t_nits;
    l_nit_valid     BOOLEAN := TRUE;
    l_message_text      jl_co_gl_conc_errs.message_text%TYPE := NULL;
    l_add_text     VARCHAR2(30):= NULL;

  BEGIN
     FND_FILE.PUT_LINE(FND_FILE.log,'Inside Validate NIT');
    -- add_text is populated only for external sources

    IF p_identifier_type = 'JL_CO_GL_NIT' THEN
      l_add_text := 'JL_CO_GL_0_NIT_TRX_CREATED';
    END IF;

    BEGIN  -- check if nit exists by nit number
         FND_FILE.PUT_LINE(FND_FILE.log,'p_nit_rec.nit : '||p_nit_rec.nit);

      SELECT nit_id,
             nit,
             name,
             type,
             verifying_digit
      INTO   l_master_nit_rec
      FROM   jl_co_gl_nits
      WHERE  nit = p_nit_rec.nit;


    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    BEGIN  -- check if nit exists by name
      IF l_master_nit_rec.nit IS NULL THEN

        SELECT nit_id,
               nit,name,
               type,
               verifying_digit
        INTO   l_master_nit_rec
        FROM   jl_co_gl_nits
        WHERE  name = p_nit_rec.nit_name; -- Bug 8589204 Removed the UPPER fn

    FND_FILE.PUT_LINE(FND_FILE.log,'p_nit_rec.nit_name : '||p_nit_rec.nit_name);

        FND_MESSAGE.SET_NAME('JL','JL_CO_GL_NIT_NAME_EXISTS');
        FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
        FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
        FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
        l_message_text := FND_MESSAGE.GET;
        Insert_Error_Rec(l_message_text);
        l_nit_valid := FALSE;

      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    IF l_master_nit_rec.nit IS NULL THEN
FND_FILE.PUT_LINE(FND_FILE.log,'master : p_nit_rec.nit : '||p_nit_rec.nit);

      -- master NIT does not exist
      -- validate NIT and insert new NIT record
      IF jg_taxid_val_pkg.check_length('CO',14,p_nit_rec.nit) = 'FALSE' THEN
        FND_MESSAGE.SET_NAME('JL','JL_CO_GL_NIT_MAX_DIGITS');
        FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
        FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
        FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
        l_message_text := FND_MESSAGE.GET;
        Insert_Error_Rec(l_message_text);
        l_nit_valid := FALSE;
      END IF; /*check_length*/

      IF p_nit_rec.nit IS NULL THEN
FND_FILE.PUT_LINE(FND_FILE.log,'NIT Null Check  : p_nit_rec.nit : '||p_nit_rec.nit);

        FND_MESSAGE.SET_NAME('JL','JL_CO_GL_NIT_REQUIRED');
        FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
        FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
        FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
        l_message_text := FND_MESSAGE.GET;
        Insert_Error_Rec(l_message_text);
        l_nit_valid := FALSE;

      ELSE
        IF jg_taxid_val_pkg.check_numeric(p_nit_rec.nit) = 'FALSE' THEN
          FND_MESSAGE.SET_NAME('JL','JL_CO_GL_INVALID_NIT');
          FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
          FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
          FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
          l_message_text := FND_MESSAGE.GET;

          Insert_Error_Rec(l_message_text);
          l_nit_valid := FALSE;

        ELSE  /* nit is numeric */
          IF (p_nit_rec.verifying_digit IS NOT NULL) THEN
            IF jg_taxid_val_pkg.check_algorithm(p_nit_rec.nit,'CO',
               p_nit_rec.verifying_digit) = 'FALSE' THEN
              FND_MESSAGE.SET_NAME('JL','JL_CO_GL_VER_DIGIT_INVALID');
              FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',
                                          p_identifier_type,TRUE);
              FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
              FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
              l_message_text := FND_MESSAGE.GET;
              Insert_Error_Rec(l_message_text);
              l_nit_valid := FALSE;
            END IF; /* validate_algorithm for verifying digit*/
          END IF;  /* v_digit not NULL */
        END IF;   /* check numeric */
      END IF;    /* nit is NULL */

      IF (p_nit_rec.nit_type = 'LEGAL_ENTITY' AND
          p_nit_rec.verifying_digit IS NULL) THEN
        FND_MESSAGE.SET_NAME('JL','JL_CO_GL_VER_DIGIT_REQUIRED');
        FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
        FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
        FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
        l_message_text := FND_MESSAGE.GET;
        Insert_Error_Rec(l_message_text);
        l_nit_valid := FALSE;
      END IF;

      IF (p_nit_rec.nit_type IS NULL) OR (p_nit_rec.nit_type NOT IN
         ('LEGAL_ENTITY','INDIVIDUAL','FOREIGN_ENTITY')) THEN
        FND_MESSAGE.SET_NAME('JL','JL_CO_GL_NIT_TYPE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
        FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
        FND_MESSAGE.SET_TOKEN('TAXID_TYPE', 'LEGAL_ENTITY, INDIVIDUAL and FOREIGN_ENTITY');
        FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
        l_message_text := FND_MESSAGE.GET;
        Insert_Error_Rec(l_message_text);
        l_nit_valid := FALSE;
      END IF;

      IF p_nit_rec.nit_name IS NULL THEN
        FND_MESSAGE.SET_NAME('JL','JL_CO_GL_NIT_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
        FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
        FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
        l_message_text := FND_MESSAGE.GET;
        Insert_Error_Rec(l_message_text);
        l_nit_valid := FALSE;
      END IF;

         -- insert validated NIT record
      IF l_nit_valid THEN

        INSERT INTO jl_co_gl_nits (nit_id,
                                   nit,
                                   type,
                                   verifying_digit,
                                   name,
                                   creation_date,
                                   created_by,
                                   last_update_date,
                                   last_updated_by,
                                   last_update_login)
                           VALUES (jl_co_gl_nits_s.nextval,
                                   p_nit_rec.nit,
                                   p_nit_rec.nit_type,
                                   p_nit_rec.verifying_digit,
                                   p_nit_rec.nit_name,
                                   sysdate,
                                   NVL(g_parameter_rec.user_id,-1),
                                   sysdate,
                                   NVL(g_parameter_rec.user_id,-1),
                                   g_login_id);

        SELECT jl_co_gl_nits_s.currval
        INTO   p_nit_rec.nit_id
        FROM   DUAL ;

      END IF;

    ELSIF l_nit_valid THEN
         -- nit exists verify if the info matches master nit

      IF (p_nit_rec.nit <> l_master_nit_rec.nit) OR
         (UPPER(p_nit_rec.nit_name) <> UPPER(l_master_nit_rec.nit_name)) OR
         (UPPER(p_nit_rec.nit_type) <> UPPER(l_master_nit_rec.nit_type)) OR
         (p_nit_rec.verifying_digit <> l_master_nit_rec.verifying_digit) THEN

        FND_MESSAGE.SET_NAME('JL','JL_CO_GL_MASTER_NIT_MISMATCH');
        FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',p_identifier_type,TRUE);
        FND_MESSAGE.SET_TOKEN('IDENTIFIER',g_gl_je_rec.identifier);
        FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
        l_message_text := FND_MESSAGE.GET;
        Insert_Error_Rec(l_message_text);
        l_nit_valid := FALSE;
      END IF;
    END IF;

    RETURN(l_nit_valid);
  FND_FILE.PUT_LINE(FND_FILE.log,'Returning from Validate NIT');
  EXCEPTION
    WHEN no_data_found THEN
      NULL;

    WHEN others THEN
      g_error_code := SQLCODE;
      g_error_text := SUBSTR(SQLERRM,1,240);
      FND_FILE.PUT_LINE(FND_FILE.log,'Validate_NIT:'|| g_error_text);
      RAISE;

  END Validate_NIT;


  PROCEDURE Generate_GL_trx
       (p_journal_rec IN journals%ROWTYPE ) IS

    l_add_text         VARCHAR2(30):= NULL;
    l_message_text     jl_co_gl_conc_errs.message_text%TYPE := NULL;

  BEGIN

    BEGIN
      SELECT nit_id
      INTO   g_nit_rec.nit_id
      FROM   jl_co_gl_nits jlcgn
      WHERE  nit = DECODE(p_journal_rec.source,
                          'Payables','0',
                          'Purchasing','0',
                          'Receivables','0',
                          p_journal_rec.ext_nit);

    EXCEPTION
       WHEN no_data_found THEN
         g_nit_rec.nit_id := NULL; --Fwd port of 11i bug 6155086
    END;

    SELECT p_journal_rec.je_header_id,
           p_journal_rec.je_line_num,
           null
    INTO   g_gl_je_rec
    FROM   DUAL;

    IF p_journal_rec.source in ('Payables','Purchasing','Receivables') THEN
      -- Its here probably because import references dont exist or is in
      -- summary because of which the AR, AP or PO routine couldn't process
      -- it and passed the record on to the GL routine

      l_add_text := 'JL_CO_GL_0_NIT_TRX_CREATED';
      FND_MESSAGE.SET_NAME('JL','JL_CO_GL_NO_IMPORT_REF');
      FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
      l_message_text := FND_MESSAGE.GET;
      Insert_Error_Rec(l_message_text);

    ELSIF g_nit_rec.nit_id IS NULL THEN /* Third party # is not valid */

      l_add_text := 'JL_CO_GL_0_NIT_TRX_CREATED';
      FND_MESSAGE.SET_NAME('JL','JL_CO_GL_INVALID_NIT');
      FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',NULL);
      FND_MESSAGE.SET_TOKEN('IDENTIFIER',NULL);
      FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
      l_message_text := FND_MESSAGE.GET;
      Insert_Error_Rec(l_message_text);

    ELSIF p_journal_rec.ext_nit = '0' THEN
      -- Not calling NIT_VALIDATION function because the only nit info
      -- entered by the user in Enter Journals form is NIT# hence it
      -- isn't necessary to do exhaustive NIT validation

      l_add_text := 'JL_CO_GL_0_NIT_TRX_CREATED';
      FND_MESSAGE.SET_NAME('JL','JL_CO_GL_NIT_REQUIRED');
      FND_MESSAGE.SET_TOKEN('IDENTIFIER_TYPE',NULL);
      FND_MESSAGE.SET_TOKEN('IDENTIFIER',NULL);
      FND_MESSAGE.SET_TOKEN('ADD_TEXT',l_add_text,TRUE);
      l_message_text := FND_MESSAGE.GET;
      Insert_Error_Rec(l_message_text);

    END IF;

    INSERT INTO jl_co_gl_trx (transaction_id,
                              process_id,
                              set_of_books_id,
                              code_combination_id,
                              account_code,
                              nit_id,
                              period_name,
                              period_year,
                              period_num,
                              je_batch_id,
                              je_header_id,
                              category,
                              subledger_doc_number,
                              je_line_num,
                              document_number,
                              accounting_date,
                              currency_code,
                              creation_date,
                              created_by,
                              last_update_date,
                              last_updated_by,
                              last_update_login,
                              accounted_dr,
                              accounted_cr,
                              entered_dr,
                              entered_cr)
                      VALUES (jl_co_gl_trx_s.nextval,
                              g_parameter_rec.cid,
                              g_parameter_rec.set_of_books_id,
                              p_journal_rec.code_combination_id,
                              p_journal_rec.account_code,
                              NVL(g_nit_rec.nit_id,g_default_nit_id),
                              p_journal_rec.period_name,
                              g_period_year,
                              g_period_num,
                              p_journal_rec.je_batch_id,
                              p_journal_rec.je_header_id,
                              p_journal_rec.category,
                              p_journal_rec.subl_doc_num,
                              p_journal_rec.je_line_num,
                              NULL,
                              p_journal_rec.accounting_date,
                              p_journal_rec.currency,
                              sysdate,
                              NVL(g_parameter_rec.user_id,-1),
                              sysdate,
                              NVL(g_parameter_rec.user_id,-1),
                              g_login_id,
                              DECODE(sign(p_journal_rec.accounted_cr), -1,
                                     (abs(p_journal_rec.accounted_cr) +
                                       NVL(DECODE(sign(p_journal_rec.accounted_dr),1,
                                                  p_journal_rec.accounted_dr,NULL),0)),
                                     DECODE(sign(p_journal_rec.accounted_dr),-1,
                                            NULL,p_journal_rec.accounted_dr)),
                              DECODE(sign(p_journal_rec.accounted_dr),-1,
                                     (abs(p_journal_rec.accounted_dr) +
                                       NVL(DECODE(sign(p_journal_rec.accounted_cr),1,
                                                  p_journal_rec.accounted_cr,NULL),0)),
                                     DECODE(sign(p_journal_rec.accounted_cr),-1,
                                            NULL,p_journal_rec.accounted_cr)),
                              DECODE(sign(p_journal_rec.entered_cr),-1,
                                     (abs(p_journal_rec.entered_cr) +
                                       NVL(DECODE(sign(p_journal_rec.entered_dr),1,
                                                  p_journal_rec.entered_dr,NULL),0)),
                                     DECODE(sign(p_journal_rec.entered_dr),-1,
                                            NULL,p_journal_rec.entered_dr)),
                              DECODE(sign(p_journal_rec.entered_dr),-1,
                                     (abs(p_journal_rec.entered_dr) +
                                      NVL(DECODE(sign(p_journal_rec.entered_cr),1,
                                                 p_journal_rec.entered_cr,NULL),0)),
                                     DECODE(sign(p_journal_rec.entered_cr),-1,
                                            NULL,p_journal_rec.entered_cr)) );
/* bug 7045429
    BEGIN
      SELECT 'TRUE'
      INTO g_error_exists
      FROM DUAL
      WHERE EXISTS (SELECT '1'
                    FROM jl_co_gl_conc_errs jlcgce
                    WHERE jlcgce.je_header_id = p_journal_rec.je_header_id
                    AND jlcgce.je_line_num = p_journal_rec.je_line_num);

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    IF NVL(g_error_exists,'FALSE') = 'TRUE' THEN
      DELETE FROM jl_co_gl_trx jlcgt
        WHERE jlcgt.je_header_id =  p_journal_rec.je_header_id
        AND jlcgt.je_line_num =  p_journal_rec.je_line_num;
    ELSE */									  -- Bug 8215616
      UPDATE gl_je_lines gljl
        SET co_processed_flag = 'Y'
        WHERE gljl.je_header_id =  p_journal_rec.je_header_id
        AND gljl.je_line_num =  p_journal_rec.je_line_num
        AND EXISTS (SELECT 'Y'
                    FROM jl_co_gl_trx jlcgt
                    WHERE jlcgt.je_header_id = gljl.je_header_id
                   AND jlcgt.je_line_num = gljl.je_line_num); /*
    END IF;
*/

    COMMIT;

  EXCEPTION
     WHEN others THEN
       g_error_code := SQLCODE;
       g_error_text := SUBSTR(SQLERRM,1,240);
       FND_FILE.PUT_LINE(FND_FILE.log,'Generate_GL_trx:'|| g_error_text);
       RAISE;

  END Generate_GL_trx;


  PROCEDURE Generate_AP_trx
       (p_journal_rec IN journals%ROWTYPE) IS

 -- R12 changes: replaced 11i sla tables with R12 xla tables and removed
 -- the third sql in 11i for Payment history. This is handled via the 2nd sql here

    CURSOR ap_detail_lines IS
      (SELECT DECODE(SIGN(lnk.unrounded_accounted_cr),-1,
                    DECODE(SIGN(lnk.unrounded_accounted_dr),-1,ABS(lnk.unrounded_accounted_dr),null),
                    lnk.unrounded_accounted_cr)    ACCOUNTED_CR,
             DECODE(SIGN(lnk.unrounded_accounted_dr),-1,
                    DECODE(SIGN(lnk.unrounded_accounted_cr),-1,ABS(lnk.unrounded_accounted_cr),null),
                    lnk.unrounded_accounted_dr)    ACCOUNTED_DR,
             DECODE(SIGN(lnk.unrounded_entered_dr),-1,
                    DECODE(SIGN(lnk.unrounded_entered_cr),-1, ABS(lnk.unrounded_entered_cr), null),
                    lnk.unrounded_entered_dr)      ENTERED_DR,
             DECODE(SIGN(lnk.unrounded_entered_cr),-1,
                    DECODE(SIGN(lnk.unrounded_entered_dr),-1, ABS(lnk.unrounded_entered_dr), null),
                    lnk.unrounded_entered_cr)      ENTERED_CR,
             lnk.source_distribution_type  SOURCE_TABLE,
             ael.party_id                PARTY_ID,
             ent.transaction_number        TRX_NUMBER_C ,
             I.invoice_id                TRX_HDR_ID,
             'INV'                       TRX_CLASS,
             ael.accounting_class_code   ACCT_LINE_TYPE,
             D.invoice_distribution_id   TRX_DIST_ID
	 FROM
	     ap_invoices_all               I,
	     xla_transaction_entities      ent,
	     xla_ae_headers                AEH,
             xla_ae_lines                  AEL,
             ap_invoice_distributions_all  D,
	     xla_distribution_links        LNK,
             gl_import_references          R
      WHERE
	      ent.application_id = 200
          AND ent.application_id =aeh.application_id
          AND aeh.application_id = ael.application_id
	  --bug8680825
	  /*and (ent.ledger_id      = g_parameter_rec.set_of_books_id
          or   ent.ledger_id in (SELECT from_ledger_id
                                 FROM gl_consolidation
                                 WHERE to_ledger_id = g_parameter_rec.set_of_books_id))*/
	  AND ent.entity_code = 'AP_INVOICES'
	  AND i.invoice_id = ent.source_id_int_1
	  AND ent.entity_id = aeh.entity_id
	  --AND AEH.ledger_id = ent.ledger_id  --bug8680825
	  AND (aeh.ledger_id     = g_parameter_rec.set_of_books_id
             OR
            aeh.ledger_id IN (SELECT from_ledger_id
                                 FROM gl_consolidation
                                 WHERE to_ledger_id = g_parameter_rec.set_of_books_id)
            )
	  AND aeh.ae_header_id = ael.ae_header_id
	  AND ael.ae_header_id = lnk.ae_header_id
	  AND ael.ae_line_num = lnk.ae_line_num
	  AND lnk.source_distribution_type <> 'AP_PREPAY'    --- bug 7428486
	  AND ael.application_id = 200
	  AND lnk.application_id = 200
	  --AND D.invoice_distribution_id(+) = DECODE(lnk.source_distribution_type,
      --'AP_INVOICE_DISTRIBUTIONS', lnk.source_distribution_id_num_1,null)
	  AND D.invoice_distribution_id = lnk.source_distribution_id_num_1
      AND R.gl_sl_link_id              = AEL.gl_sl_link_id
      AND R.je_header_id               = p_journal_rec.je_header_id
      AND R.je_line_num                = p_journal_rec.je_line_num
      UNION ALL
      SELECT DECODE(SIGN(AEL.unrounded_accounted_cr),-1,
                    DECODE(SIGN(AEL.unrounded_accounted_dr),-1,ABS(AEL.unrounded_accounted_dr),null),
                    AEL.unrounded_accounted_cr)    ACCOUNTED_CR,
             DECODE(SIGN(AEL.unrounded_accounted_dr),-1,
                    DECODE(SIGN(AEL.unrounded_accounted_cr),-1,ABS(AEL.unrounded_accounted_cr),null),
                    AEL.unrounded_accounted_dr)    ACCOUNTED_DR,
             DECODE(SIGN(AEL.unrounded_entered_dr),-1,
                    DECODE(SIGN(AEL.unrounded_entered_cr),-1, ABS(AEL.unrounded_entered_cr), null),
                    AEL.unrounded_entered_dr)      ENTERED_DR,
             DECODE(SIGN(AEL.unrounded_entered_cr),-1,
                    DECODE(SIGN(AEL.unrounded_entered_dr),-1, ABS(AEL.unrounded_entered_dr), null),
                    AEL.unrounded_entered_cr)      ENTERED_CR,
            ent.entity_code             SOURCE_TABLE,
            ael.party_id                PARTY_ID,
            TO_CHAR(C.CHECK_NUMBER)     TRX_NUMBER_C ,
            C.CHECK_ID                  TRX_HDR_ID,
            'PAY'                       TRX_CLASS,
            ael.accounting_class_code   ACCT_LINE_TYPE,
            NULL   TRX_DIST_ID
     FROM
            ap_checks_all                 C,
            xla_transaction_entities      ent,
            xla_ae_headers                AEH,
            xla_ae_lines                  AEL,
            ap_payment_history_all        D,  -- bug 8673098
            gl_import_references          R
     WHERE
	  ent.application_id = 200
	  --bug8680825
	  /*and (ent.ledger_id      = g_parameter_rec.set_of_books_id
          or   ent.ledger_id in (SELECT from_ledger_id
                                 FROM gl_consolidation
                                 WHERE to_ledger_id = g_parameter_rec.set_of_books_id))*/

	  AND ent.entity_code = 'AP_PAYMENTS'
	  AND c.check_id = ent.source_id_int_1
	  AND c.check_id = D.check_id
	  AND ent.entity_id = aeh.entity_id
	  --AND AEH.ledger_id = ent.ledger_id  --bug8680825
	  AND (aeh.ledger_id     = g_parameter_rec.set_of_books_id
             OR
            aeh.ledger_id IN (SELECT from_ledger_id
                                 FROM gl_consolidation
                                 WHERE to_ledger_id = g_parameter_rec.set_of_books_id)
            )
	  and aeh.ae_header_id = ael.ae_header_id
	  and ael.application_id = 200
	  AND D.accounting_event_id = aeh.event_id
	  AND R.gl_sl_link_id  = AEL.gl_sl_link_id
	  AND R.je_header_id  = p_journal_rec.je_header_id
      	  AND R.je_line_num   = p_journal_rec.je_line_num)
      UNION
       SELECT DECODE(SIGN(lnk.unrounded_accounted_cr),-1,
                    DECODE(SIGN(lnk.unrounded_accounted_dr),-1,ABS(lnk.unrounded_accounted_dr),null),
                    lnk.unrounded_accounted_cr)    ACCOUNTED_CR,
             DECODE(SIGN(lnk.unrounded_accounted_dr),-1,
                    DECODE(SIGN(lnk.unrounded_accounted_cr),-1,ABS(lnk.unrounded_accounted_cr),null),
                    lnk.unrounded_accounted_dr)    ACCOUNTED_DR,
             DECODE(SIGN(lnk.unrounded_entered_dr),-1,
                    DECODE(SIGN(lnk.unrounded_entered_cr),-1, ABS(lnk.unrounded_entered_cr), null),
                    lnk.unrounded_entered_dr)      ENTERED_DR,
             DECODE(SIGN(lnk.unrounded_entered_cr),-1,
                    DECODE(SIGN(lnk.unrounded_entered_dr),-1, ABS(lnk.unrounded_entered_dr), null),
                    lnk.unrounded_entered_cr)      ENTERED_CR,
             lnk.source_distribution_type  SOURCE_TABLE,
             ael.party_id                PARTY_ID,
             ent.transaction_number        TRX_NUMBER_C ,
             I.invoice_id                TRX_HDR_ID,
             'INV'                       TRX_CLASS,
             ael.accounting_class_code   ACCT_LINE_TYPE,
             D.invoice_distribution_id   TRX_DIST_ID
	 FROM
	     ap_invoices_all               I,
	     xla_transaction_entities      ent,
	     xla_ae_headers                AEH,
         xla_ae_lines                  AEL,
         ap_prepay_app_dists           D,
	     xla_distribution_links        LNK,
         gl_import_references          R
     WHERE
	      ent.application_id = 200
      AND ent.application_id =aeh.application_id
      AND aeh.application_id = ael.application_id
	  --bug8680825
	  /*and (ent.ledger_id      = g_parameter_rec.set_of_books_id
	  ---AND lnk.source_distribution_type = 'AP_PREPAY'    ---bug 7428486
          or   ent.ledger_id in (SELECT from_ledger_id
                                 FROM gl_consolidation
                                 WHERE to_ledger_id = g_parameter_rec.set_of_books_id))*/
	  AND ent.entity_code = 'AP_INVOICES'
	  AND i.invoice_id = ent.source_id_int_1
	  AND ent.entity_id = aeh.entity_id
	  --AND AEH.ledger_id  = ent.ledger_id  --bug8680825
	  AND (aeh.ledger_id     = g_parameter_rec.set_of_books_id
             OR
           aeh.ledger_id IN (SELECT from_ledger_id
                                 FROM gl_consolidation
                                 WHERE to_ledger_id = g_parameter_rec.set_of_books_id)
           )
	  AND aeh.ae_header_id = ael.ae_header_id
	  AND ael.ae_header_id = lnk.ae_header_id
	  AND ael.ae_line_num = lnk.ae_line_num
	  AND ael.application_id = 200
	  AND lnk.application_id = 200
      AND lnk.source_distribution_type = 'AP_PREPAY'
	  --AND D.invoice_distribution_id(+) = DECODE(lnk.source_distribution_type,
           --         'AP_INVOICE_DISTRIBUTIONS', lnk.source_distribution_id_num_1,null)
	  AND D.prepay_app_dist_id  = lnk.source_distribution_id_num_1
      AND R.gl_sl_link_id              = AEL.gl_sl_link_id
      AND R.je_header_id               = p_journal_rec.je_header_id
      AND R.je_line_num                = p_journal_rec.je_line_num;

     l_supplier_num po_vendors.segment1%TYPE;
     l_err_flag NUMBER;

  BEGIN

    g_error_exists := 'FALSE';
    l_err_flag := 0;


    SELECT p_journal_rec.je_header_id,
           p_journal_rec.je_line_num,
           p_journal_rec.ext_nit
    INTO g_gl_je_rec
    FROM DUAL;

   FND_FILE.PUT_LINE(FND_FILE.log,'Generate_ap_trx : Begin ');

  FOR ap_trx IN ap_detail_lines LOOP
   l_err_flag := l_err_flag + 1;
   FND_FILE.PUT_LINE(FND_FILE.log,'Generate_ap_trx : After ap_trx cursor call : ' ||ap_trx.source_table);
   FND_FILE.PUT_LINE(FND_FILE.log,'Generate_ap_trx :Dist ID' ||to_char(ap_trx.trx_dist_id));
   FND_FILE.PUT_LINE(FND_FILE.log,'Generate_ap_trx :i Trx ID' ||to_char(ap_trx.trx_hdr_id));
      g_nit_rec := NULL;
      l_supplier_num := NULL;

	  FND_FILE.PUT_LINE(FND_FILE.log,'Invoice Distribution ID '||ap_trx.trx_dist_id);
	  FND_FILE.PUT_LINE(FND_FILE.log,'Invoice ID '||ap_trx.trx_hdr_id);

	  IF (ap_trx.source_table = 'AP_INV_DIST') THEN
           FND_FILE.PUT_LINE(FND_FILE.log,'Source table is AP_INV_DIST');
        BEGIN
		   SELECT DECODE(ap_trx.acct_line_type,'LIABILITY',NULL,NVL(global_attribute2,NULL))
                 INTO l_supplier_num
                  FROM ap_invoice_distributions_all apida
                       WHERE apida.invoice_id = ap_trx.trx_hdr_id
                          AND apida.invoice_distribution_id = ap_trx.trx_dist_id;
	             --bug8680825
				 /*AND (apida.set_of_books_id  = g_parameter_rec.set_of_books_id
                   OR   apida.set_of_books_id in (SELECT from_ledger_id
                                                     FROM gl_consolidation
                                                  WHERE to_ledger_id = g_parameter_rec.set_of_books_id));*/
        EXCEPTION
		    WHEN OTHERS THEN
			    --l_supplier_num  := NULL;
				FND_FILE.PUT_LINE(FND_FILE.log,'INSIDE EXCEPTION '||SQLERRM);
		END;
      END IF;

   FND_FILE.PUT_LINE(FND_FILE.log,'Generate_ap_trx : After ap_trx cursor call : ' ||l_supplier_num);
   /* Commented out for Bug3840010
      SELECT jlcgn.nit_id,
             REPLACE(pov.num_1099,'-'),
             pov.vendor_name,
             SUBSTR(pov.global_attribute10,1,30),
             pov.global_attribute12,
             NVL(l_supplier_num,pov.segment1)
      INTO g_nit_rec.nit_id,
           g_nit_rec.nit,
           g_nit_rec.nit_name,
           g_nit_rec.nit_type,
           g_nit_rec.verifying_digit,
           l_supplier_num
      FROM jl_co_gl_nits jlcgn, po_vendors pov
      WHERE NVL(l_supplier_num,TO_CHAR(ap_trx.party_id)) =
            DECODE(l_supplier_num, NULL,TO_CHAR(pov.vendor_id),pov.segment1)
      AND jlcgn.nit(+) = REPLACE(pov.num_1099,'-') ;  */

      -- Replaced the above logic with 2 different statements executed conditionally
      IF l_supplier_num IS  NULL THEN
   FND_FILE.PUT_LINE(FND_FILE.log,'Generate_ap_trx : l_supplier_num IS NULL ');
	 SELECT jlcgn.nit_id,
	        REPLACE(povapf.num_1099,'-'),
	        povapf.vendor_name,
	        SUBSTR(povapf.global_attribute10,1,30),
	        povapf.global_attribute12,
	        NVL(l_supplier_num,povapf.segment1)
	 INTO  g_nit_rec.nit_id,
	       g_nit_rec.nit,
	       g_nit_rec.nit_name,
	       g_nit_rec.nit_type,
	       g_nit_rec.verifying_digit,
	       l_supplier_num
	 FROM  jl_co_gl_nits jlcgn, (SELECT nvl(papf.national_identifier,nvl(aps.individual_1099,aps.num_1099)) num_1099,
		         aps.vendor_name,
		         aps.global_attribute10,
			 aps.global_attribute12,
			 aps.segment1,
			 aps.vendor_id
		  FROM  ap_suppliers aps,
			(select distinct person_id ,national_identifier from per_all_people_f
			        WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
		  WHERE nvl(aps.employee_id, -99) = papf.person_id (+)) povapf
	 WHERE 	 ap_trx.party_id = povapf.vendor_id
	 AND   jlcgn.nit(+) = REPLACE(povapf.num_1099,'-') ;

      ELSE

   FND_FILE.PUT_LINE(FND_FILE.log,'Generate_ap_trx : l_supplier_num IS NOT NULL ');
	 SELECT jlcgn.nit_id,
	        REPLACE(povapf.num_1099,'-'),
	        povapf.vendor_name,
	        SUBSTR(povapf.global_attribute10,1,30),
	        povapf.global_attribute12,
	        NVL(l_supplier_num,povapf.segment1)
	 INTO  g_nit_rec.nit_id,
	       g_nit_rec.nit,
	       g_nit_rec.nit_name,
	       g_nit_rec.nit_type,
               g_nit_rec.verifying_digit,
	       l_supplier_num
	 FROM  jl_co_gl_nits jlcgn, (SELECT nvl(papf.national_identifier,nvl(aps.individual_1099,aps.num_1099)) num_1099,
		         aps.vendor_name,
		         aps.global_attribute10,
			 aps.global_attribute12,
			 aps.segment1,
			 aps.vendor_id
		  FROM  ap_suppliers aps,
			(select distinct person_id ,national_identifier from per_all_people_f
			WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
		  WHERE nvl(aps.employee_id, -99) = papf.person_id (+)) povapf
	 WHERE l_supplier_num = povapf.segment1
	 AND   jlcgn.nit(+) = REPLACE(povapf.num_1099,'-') ;

      END IF;

      g_gl_je_rec.identifier := l_supplier_num;

FND_FILE.PUT_LINE(FND_FILE.log,'Before Validate Call for AP : JE Line NUM, Header_id : '||to_char(p_journal_rec.je_line_num)||'-'||to_char(p_journal_rec.je_header_id));
      IF Validate_NIT(g_nit_rec, 'JL_CO_GL_SUPPLIER') THEN
FND_FILE.PUT_LINE(FND_FILE.log,'After AP NIT Validate : JE Line NUM, Header_id : '||to_char(p_journal_rec.je_line_num)||'-'||to_char(p_journal_rec.je_header_id));
FND_FILE.PUT_LINE(FND_FILE.log,'CCID, account code : '||to_char(p_journal_rec.code_combination_id)
        ||'-'||p_journal_rec.account_code);
FND_FILE.PUT_LINE(FND_FILE.log,' : '||g_nit_rec.nit||'-'||g_nit_rec.nit_name);
FND_FILE.PUT_LINE(FND_FILE.log,'AP : acc_dr, acc_cr,ent_dr, ent_dr : '
     ||to_char(ap_trx.accounted_dr)||'-'||to_char(ap_trx.accounted_cr)
     ||'-'||to_char(ap_trx.entered_dr)||'-'||to_char(ap_trx.entered_cr));

        INSERT INTO jl_co_gl_trx (transaction_id,
                                  process_id,
                                  set_of_books_id,
                                  code_combination_id,
                                  account_code,
                                  nit_id,
                                  period_name,
                                  period_year,
                                  period_num,
                                  je_batch_id,
                                  je_header_id,
                                  category,
                                  subledger_doc_number,
                                  je_line_num,
                                  document_number,
                                  accounting_date,
                                  currency_code,
                                  creation_date,
                                  created_by,
                                  last_update_date,
                                  last_updated_by,
                                  last_update_login,
                                  accounted_dr,
                                  accounted_cr,
                                  entered_dr,
                                  entered_cr)
                          VALUES (jl_co_gl_trx_s.nextval,
                                  g_parameter_rec.cid,
                                  g_parameter_rec.set_of_books_id,
                                  p_journal_rec.code_combination_id,
                                  p_journal_rec.account_code,
                                  g_nit_rec.nit_id,
                                  p_journal_rec.period_name,
                                  g_period_year,
                                  g_period_num,
                                  p_journal_rec.je_batch_id,
                                  p_journal_rec.je_header_id,
                                  p_journal_rec.category,
                                  p_journal_rec.subl_doc_num,
                                  p_journal_rec.je_line_num,
                                  ap_trx.trx_number_c,
                                  p_journal_rec.accounting_date,
                                  p_journal_rec.currency,
                                  sysdate,
                                  NVL(g_parameter_rec.user_id,-1),
                                  sysdate,
                                  NVL(g_parameter_rec.user_id,-1),
                                  g_login_id,
                                  ap_trx.accounted_dr,
                                  ap_trx.accounted_cr,
                                  ap_trx.entered_dr,
                                  ap_trx.entered_cr );

        BEGIN

  /* Commented for bug3840010

          SELECT 'TRUE'
          INTO g_error_exists
          FROM DUAL
          WHERE EXISTS (SELECT '1'
                        FROM jl_co_gl_conc_errs jlcgce
                        WHERE jlcgce.je_header_id = p_journal_rec.je_header_id
                        AND jlcgce.je_line_num = p_journal_rec.je_line_num); */

-- New statement for bug 3840010
      SELECT 'TRUE'
	  INTO   g_error_exists
	  FROM  jl_co_gl_conc_errs jlcgce
	  WHERE  jlcgce.je_header_id = p_journal_rec.je_header_id
	  AND    jlcgce.je_line_num  = p_journal_rec.je_line_num and rownum = 1;

        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;

        IF NVL(g_error_exists,'FALSE') = 'TRUE' THEN

	UPDATE gl_je_lines gljl
            SET co_processed_flag = 'N'
            WHERE gljl.je_header_id =  p_journal_rec.je_header_id
            AND gljl.je_line_num =  p_journal_rec.je_line_num
            AND EXISTS (SELECT 'Y'
                        FROM jl_co_gl_trx jlcgt
                        WHERE jlcgt.je_header_id = gljl.je_header_id
                        AND jlcgt.je_line_num = gljl.je_line_num);
          DELETE FROM jl_co_gl_trx jlcgt
            WHERE jlcgt.je_header_id =  p_journal_rec.je_header_id
            AND jlcgt.je_line_num =  p_journal_rec.je_line_num;

	ELSE
          UPDATE gl_je_lines gljl
            SET co_processed_flag = 'Y'
            WHERE gljl.je_header_id =  p_journal_rec.je_header_id
            AND gljl.je_line_num =  p_journal_rec.je_line_num
            AND EXISTS (SELECT 'Y'
                        FROM jl_co_gl_trx jlcgt
                        WHERE jlcgt.je_header_id = gljl.je_header_id
                        AND jlcgt.je_line_num = gljl.je_line_num);

        END IF;

      END IF;

    END LOOP;

    BEGIN

      SELECT 'TRUE'
      INTO   g_error_exists
      FROM   DUAL
      WHERE  EXISTS (SELECT '1'
                     FROM   jl_co_gl_conc_errs jlcgce
                     WHERE  jlcgce.je_header_id = p_journal_rec.je_header_id
                     AND    jlcgce.je_line_num  = p_journal_rec.je_line_num);
    EXCEPTION
      WHEN no_data_found THEN
	      FND_FILE.PUT_LINE(FND_FILE.log,'no_data_found exception');
        NULL;
    END;

    IF NVL(g_error_exists,'FALSE') = 'TRUE' THEN
      UPDATE gl_je_lines gljl
            SET co_processed_flag = 'N'
            WHERE gljl.je_header_id =  p_journal_rec.je_header_id
            AND gljl.je_line_num =  p_journal_rec.je_line_num
            AND EXISTS (SELECT 'Y'
                        FROM jl_co_gl_trx jlcgt
                        WHERE jlcgt.je_header_id = gljl.je_header_id
                        AND jlcgt.je_line_num = gljl.je_line_num);
       FND_FILE.PUT_LINE(FND_FILE.log,'Delete jl_co_gl_trx');
      DELETE FROM jl_co_gl_trx jlcgt
        WHERE  jlcgt.je_header_id =  p_journal_rec.je_header_id
        AND    jlcgt.je_line_num  =  p_journal_rec.je_line_num;
    END IF;

    COMMIT;
    --bug8499774
    IF l_err_flag = 0 THEN
	         FND_FILE.PUT_LINE(FND_FILE.log,'Call Generate_GL_trx');
       Generate_GL_trx(g_journal_rec);
    END IF;

  EXCEPTION
    WHEN no_data_found THEN
      -- import references don't exist or are summarized for journal
	  FND_FILE.PUT_LINE(FND_FILE.log,'No data Call Generate_GL_trx');
      Generate_GL_trx(g_journal_rec);     -- Create with NIT 0

    WHEN others THEN
      g_error_code := SQLCODE;
      g_error_text := SUBSTR(SQLERRM,1,240);
      FND_FILE.PUT_LINE(FND_FILE.log,'Generate_AP_trx:'|| g_error_text);
      RAISE;

  END Generate_AP_trx;


PROCEDURE Generate_PO_trx
       (p_journal_rec IN journals%ROWTYPE ) IS

	   /*BUG 9078068 : Cursor added to accomodate Cost Mgmt Trxs of type CST_WRITE_OFFS and
	                   RCV_RECEIVING_SUB_LEDGER*/
	   CURSOR po_detail_lines IS
			SELECT jlcgn.nit_id,
				REPLACE(povapf.num_1099,'-'),
				povapf.vendor_name,
				SUBSTR(povapf.global_attribute10,1,30),
				povapf.global_attribute12,
				povapf.segment1,
				p_journal_rec.je_header_id,
				p_journal_rec.je_line_num
			FROM 	jl_co_gl_nits jlcgn,
					po_headers_all poha,
					PO_DISTRIBUTIONS_ALL podis,
					(SELECT nvl(papf.national_identifier,nvl(aps.individual_1099,aps.num_1099)) num_1099,
								aps.vendor_name,aps.global_attribute10,aps.global_attribute12,aps.segment1,
								aps.vendor_id
						FROM  ap_suppliers aps,(select distinct person_id ,national_identifier from per_all_people_f
													WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
						WHERE nvl(aps.employee_id, -99) = papf.person_id (+)) povapf,
					xla_ae_lines                  AEL,
					gl_import_references          R,
					RCV_RECEIVING_SUB_LEDGER      RCVSD,
					xla_distribution_links        LNK
			WHERE povapf.vendor_id = poha.vendor_id
			AND REPLACE(povapf.num_1099,'-') = jlcgn.nit(+)
			AND R.je_header_id     = p_journal_rec.je_header_id
			AND R.je_line_num      = p_journal_rec.je_line_num
			AND R.gl_sl_link_id    = AEL.gl_sl_link_id
			AND AEL.application_id = 707
			AND AEL.ae_header_id   = LNK.ae_header_id
			AND AEL.ae_line_num    = LNK.ae_line_num
			AND LNK.application_id = 707
			AND LNK.SOURCE_DISTRIBUTION_TYPE     = 'RCV_RECEIVING_SUB_LEDGER'
			AND LNK.SOURCE_DISTRIBUTION_ID_NUM_1 = RCVSD.RCV_SUB_LEDGER_ID
			AND RCVSD.reference3    = podis.PO_DISTRIBUTION_ID
			AND podis.po_header_id   = poha.po_header_id

			UNION

			SELECT jlcgn.nit_id,
					REPLACE(povapf.num_1099,'-'),
					povapf.vendor_name,
					SUBSTR(povapf.global_attribute10,1,30),
					povapf.global_attribute12,
					povapf.segment1,
					p_journal_rec.je_header_id,
					p_journal_rec.je_line_num
				FROM 	jl_co_gl_nits jlcgn,
						po_headers_all poha,
						PO_DISTRIBUTIONS_ALL podis,
						cst_write_offs cwo,
						xla_ae_lines AEL, gl_import_references gir,
						xla_distribution_links LNK,(SELECT nvl(papf.national_identifier,nvl(aps.individual_1099,aps.num_1099)) num_1099, aps.vendor_name,
															aps.global_attribute10, aps.global_attribute12, aps.segment1, aps.vendor_id
														FROM ap_suppliers aps,(select distinct person_id , national_identifier
																					from per_all_people_f
																					WHERE trunc(sysdate) BETWEEN effective_start_date AND effective_end_date) papf
														WHERE nvl(aps.employee_id, -99) = papf.person_id (+)) povapf
				WHERE povapf.vendor_id = poha.vendor_id
					AND REPLACE(povapf.num_1099,'-') = jlcgn.nit(+)
					AND gir.je_header_id = p_journal_rec.je_header_id
					AND gir.je_line_num =  p_journal_rec.je_line_num
					AND gir.gl_sl_link_id = AEL.gl_sl_link_id
					AND AEL.application_id = 707
					AND AEL.ae_header_id = LNK.ae_header_id
					AND AEL.ae_line_num = LNK.ae_line_num
					AND LNK.application_id = 707
					AND LNK.SOURCE_DISTRIBUTION_TYPE = 'CST_WRITE_OFFS'
					AND LNK.SOURCE_DISTRIBUTION_ID_NUM_1 = cwo.write_off_id
					AND cwo.po_distribution_id = podis.PO_DISTRIBUTION_ID
					AND podis.po_header_id = poha.po_header_id;

BEGIN
    FND_FILE.PUT_LINE(FND_FILE.log,'Inside Generate PO transaction');
    g_error_exists := 'FALSE';
    g_nit_rec := NULL;
    g_gl_je_rec := NULL;

IF p_journal_rec.category in ('Accrual','Receiving') THEN
    FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO - 001');

    --BUG 9078068
    --Begin
	OPEN po_detail_lines;
	FND_FILE.PUT_LINE(FND_FILE.log,'Opened PO Cursor');
	FETCH po_detail_lines
	   INTO g_nit_rec.nit_id,
            g_nit_rec.nit,
            g_nit_rec.nit_name,
            g_nit_rec.nit_type,
            g_nit_rec.verifying_digit,
            g_gl_je_rec.identifier,
            g_gl_je_rec.je_header_id,
            g_gl_je_rec.je_line_num;
    FND_FILE.PUT_LINE(FND_FILE.log,'Fetched PO Cursor');
	CLOSE  po_detail_lines;
	--End

    FND_FILE.PUT_LINE(FND_FILE.log,'Closed PO Cursor');
    FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO Before Validate - 002');

    IF Validate_NIT(g_nit_rec, 'JL_CO_GL_SUPPLIER') THEN
        FND_FILE.PUT_LINE(FND_FILE.log,'Inside Validate');
        INSERT INTO jl_co_gl_trx (transaction_id,
                                  process_id,
                                  set_of_books_id,
                                  code_combination_id,
                                  account_code,
                                  nit_id,
                                  period_name,
                                  period_year,
                                  period_num,
                                  je_batch_id,
                                  je_header_id,
                                  category,
                                  subledger_doc_number,
                                  je_line_num,
                                  document_number,
                                  accounting_date,
                                  currency_code,
                                  creation_date,
                                  created_by,
                                  last_update_date,
                                  last_updated_by,
                                  last_update_login,
                                  accounted_dr,
                                  accounted_cr,
                                  entered_dr,
                                  entered_cr )
                          VALUES (jl_co_gl_trx_s.nextval,
                                  g_parameter_rec.cid,
                                  g_parameter_rec.set_of_books_id,
                                  p_journal_rec.code_combination_id,
                                  p_journal_rec.account_code,
                                  g_nit_rec.nit_id,
                                  p_journal_rec.period_name,
                                  g_period_year,
                                  g_period_num,
                                  p_journal_rec.je_batch_id,
                                  p_journal_rec.je_header_id,
                                  p_journal_rec.category,
                                  p_journal_rec.subl_doc_num,
                                  p_journal_rec.je_line_num,
                                  p_journal_rec.ref_4,
                                  p_journal_rec.accounting_date,
                                  p_journal_rec.currency,
                                  sysdate,
                                  NVL(g_parameter_rec.user_id,-1),
                                  sysdate,
                                  NVL(g_parameter_rec.user_id,-1),
                                  g_login_id,
                                  DECODE(sign(p_journal_rec.accounted_cr),-1,
                                         (abs(p_journal_rec.accounted_cr) +
                                                  NVL(DECODE(sign(p_journal_rec.accounted_dr),
                                            1,p_journal_rec.accounted_dr,NULL),0)),
                                         DECODE(sign(p_journal_rec.accounted_dr),-1,
                                                 NULL,p_journal_rec.accounted_dr)),
                                  DECODE(sign(p_journal_rec.accounted_dr),-1,
                                         (abs(p_journal_rec.accounted_dr) +
                                           NVL(DECODE(sign(p_journal_rec.accounted_cr),
                                            1,p_journal_rec.accounted_cr,NULL),0)),
                                         DECODE(sign(p_journal_rec.accounted_cr),-1,
                                                NULL,p_journal_rec.accounted_cr)),
                                  DECODE(sign(p_journal_rec.entered_cr),-1,
                                         (abs(p_journal_rec.entered_cr) +
                                           NVL(DECODE(sign(p_journal_rec.entered_dr),
                                            1,p_journal_rec.entered_dr,NULL),0)),
                                         DECODE(sign(p_journal_rec.entered_dr),-1,
                                                NULL,p_journal_rec.entered_dr)),
                                  DECODE(sign(p_journal_rec.entered_dr),-1,
                                         (abs(p_journal_rec.entered_dr) +
                                           NVL(DECODE(sign(p_journal_rec.entered_cr),
                                            1,p_journal_rec.entered_cr,NULL),0)),
                                         DECODE(sign(p_journal_rec.entered_cr),-1,
                                                NULL,p_journal_rec.entered_cr)) );

        BEGIN
          FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO - 003');
          SELECT 'TRUE'
          INTO g_error_exists
          FROM DUAL
          WHERE EXISTS (SELECT '1'
                        FROM jl_co_gl_conc_errs jlcgce
                        WHERE jlcgce.je_header_id = p_journal_rec.je_header_id
                        AND jlcgce.je_line_num = p_journal_rec.je_line_num);

        EXCEPTION
          WHEN no_data_found THEN
            NULL;
        END;

        IF NVL(g_error_exists,'FALSE') = 'TRUE' THEN
            FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO - 004.1');
	        UPDATE gl_je_lines gljl
				SET co_processed_flag = 'N'
				WHERE gljl.je_header_id =  p_journal_rec.je_header_id
					AND gljl.je_line_num =  p_journal_rec.je_line_num
					AND EXISTS (SELECT 'Y'
									FROM jl_co_gl_trx jlcgt
									WHERE jlcgt.je_header_id = gljl.je_header_id
									AND jlcgt.je_line_num = gljl.je_line_num);

			DELETE FROM jl_co_gl_trx jlcgt
				WHERE jlcgt.je_header_id =  p_journal_rec.je_header_id
					AND jlcgt.je_line_num =  p_journal_rec.je_line_num;

        ELSE
		    FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO - 004.2');
			UPDATE gl_je_lines gljl
				SET co_processed_flag = 'Y'
				WHERE gljl.je_header_id =  p_journal_rec.je_header_id
					AND gljl.je_line_num =  p_journal_rec.je_line_num
					AND EXISTS (SELECT 'Y'
									FROM jl_co_gl_trx jlcgt
									WHERE jlcgt.je_header_id = gljl.je_header_id
									AND jlcgt.je_line_num = gljl.je_line_num);

        END IF;
	END IF;
END IF;

COMMIT;
FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO - 005');

EXCEPTION
    WHEN no_data_found THEN
	  FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO - EXCEPTION no data found');
      -- import references don't exist or are summarized for journal
      Generate_GL_trx(g_journal_rec);    -- Create with NIT 0

    WHEN others THEN
	  FND_FILE.PUT_LINE(FND_FILE.log,'Inside PO - EXCEPTION others');
      g_error_code := SQLCODE;
      g_error_text := SUBSTR(SQLERRM,1,240);
      FND_FILE.PUT_LINE(FND_FILE.log,'Generate_PO_trx:'|| g_error_text);
      RAISE;

END Generate_PO_trx;


PROCEDURE Generate_AR_trx
       (p_journal_rec IN journals%ROWTYPE ) IS

    CURSOR ar_detail_lines IS
		SELECT  DECODE(SIGN(AEL.unrounded_accounted_cr),-1,
                DECODE(SIGN(AEL.unrounded_accounted_dr),-1,ABS(AEL.unrounded_accounted_dr),null),
                AEL.unrounded_accounted_cr)    ACCOUNTED_CR,
				DECODE(SIGN(AEL.unrounded_accounted_dr),-1,
                DECODE(SIGN(AEL.unrounded_accounted_cr),-1,ABS(AEL.unrounded_accounted_cr),null),
                AEL.unrounded_accounted_dr)    ACCOUNTED_DR,
				DECODE(SIGN(AEL.unrounded_entered_dr),-1,
                DECODE(SIGN(AEL.unrounded_entered_cr),-1, ABS(AEL.unrounded_entered_cr), null),
                AEL.unrounded_entered_dr)      ENTERED_DR,
				DECODE(SIGN(AEL.unrounded_entered_cr),-1,
                DECODE(SIGN(AEL.unrounded_entered_dr),-1, ABS(AEL.unrounded_entered_dr), null),
                AEL.unrounded_entered_cr)      ENTERED_CR,
				ent.source_id_int_1,
				ent.transaction_number,
				ent.entity_code,
				ael.party_id,
				et.event_class_code
		FROM    xla_transaction_entities      ent,
				xla_ae_headers                AEH,
				xla_ae_lines                  AEL,
				gl_import_references          R,
				xla_event_types_b             et
		WHERE
			ent.application_id = 222
			--bug8680825
			/*and (ent.ledger_id      = g_parameter_rec.set_of_books_id
				or   ent.ledger_id in (SELECT from_ledger_id
                                 FROM gl_consolidation
                                 WHERE to_ledger_id = g_parameter_rec.set_of_books_id))*/

			-- and ent.entity_code = 'TRANSACTIONS'
			--and i.invoice_id = ent.source_id_int_1
			AND ent.entity_id      = aeh.entity_id
			--AND AEH.ledger_id    = ent.ledger_id  --bug8680825
			AND aeh.ae_header_id   = ael.ae_header_id
			AND (aeh.ledger_id     = g_parameter_rec.set_of_books_id --bug8680825
				OR
				aeh.ledger_id IN (SELECT from_ledger_id
									FROM gl_consolidation
										WHERE to_ledger_id = g_parameter_rec.set_of_books_id)
				)
			AND ael.application_id = 222
			AND R.gl_sl_link_id    = AEL.gl_sl_link_id
			AND R.je_header_id     = p_journal_rec.je_header_id
			AND R.je_line_num      = p_journal_rec.je_line_num
			AND et.event_type_code = aeh.event_type_code;


		l_acc_dr          gl_je_lines.accounted_dr%TYPE;
		l_acc_cr          gl_je_lines.accounted_cr%TYPE;
		l_ent_dr          gl_je_lines.entered_dr%TYPE;
		l_ent_cr          gl_je_lines.entered_cr%TYPE;
		l_customer_num    po_vendors.segment1%TYPE;
		l_identifier_type VARCHAR2(30);
		l_country_code    varchar2(30);
		l_branch_country_code    varchar2(60);
		l_party_id number;
		l_receipt_id number;
		l_err_flag number;

BEGIN


	g_error_exists := 'FALSE';
    l_err_flag := 0;

    FND_FILE.PUT_LINE(FND_FILE.log,'Generate_AR_trx(+)');

    SELECT p_journal_rec.je_header_id,
           p_journal_rec.je_line_num,
           p_journal_rec.ext_nit
    INTO   g_gl_je_rec
    FROM   DUAL;
    FND_FILE.PUT_LINE(FND_FILE.log,'je_header_id, je_line_num : '||to_char(p_journal_rec.je_header_id)
                                    ||'-'||to_char(p_journal_rec.je_line_num));

    FND_FILE.PUT_LINE(FND_FILE.log,'Opening AR Cursor');

    FOR ar_trx IN ar_detail_lines LOOP
	    FND_FILE.PUT_LINE(FND_FILE.log,'Inside AR Cursor');
		l_err_flag := l_err_flag + 1;
		g_nit_rec := NULL;
		l_customer_num := NULL;
		l_identifier_type := 'JL_CO_GL_CUSTOMER';

        IF ar_trx.entity_code IN ('TRANSACTIONS',
                                  'RECEIPTS',
                                  'ADJUSTMENTS') THEN
			l_ent_dr := ar_trx.entered_dr;   --bug 7169346
			l_ent_cr := ar_trx.entered_cr;   --bug 7169346
			l_acc_dr := ar_trx.accounted_dr;   --bug 7169346
			l_acc_cr := ar_trx.accounted_cr;   --bug 7169346
		END IF;

		IF ( ar_trx.event_class_code = 'MISC_RECEIPT' ) THEN
		    FND_FILE.PUT_LINE(FND_FILE.log,'Event Class Code IS Misc Receipts');
			FND_FILE.PUT_LINE(FND_FILE.log,'Misc Receipts Query(+)');
            SELECT 	nit.nit_id,
	     		substr(jgzz_fiscal_code,1,decode(instr(jgzz_fiscal_code,'-'),0,length(jgzz_fiscal_code)-1,instr(jgzz_fiscal_code,'-')-1)),  --bug9078068
			br.bank_name,
			party.country, -- nit type
			substr(jgzz_fiscal_code,decode(instr(jgzz_fiscal_code,'-'),0,length(jgzz_fiscal_code),instr(jgzz_fiscal_code,'-')+1),1),  --bug9078068
			br.bank_name
	            INTO g_nit_rec.nit_id,
					g_nit_rec.nit,
					g_nit_rec.nit_name,
					l_branch_country_code, --g_nit_rec.nit_type,
					g_nit_rec.verifying_digit,
					g_gl_je_rec.identifier
	        FROM 	jl_co_gl_nits nit,
					hz_parties party,
					ce_bank_branches_v br,
					ce_bank_accounts ce_accts,
					ce_bank_acct_uses_all acctuse,
					ar_cash_receipts_all arcash
	        WHERE 	arcash.cash_receipt_id = ar_trx.source_id_int_1
				--AND arcash.set_of_books_id = g_parameter_rec.set_of_books_id  --BUG 9078068
			AND acctuse.bank_acct_use_id = arcash.remit_bank_acct_use_id
			AND acctuse.bank_account_id = ce_accts.bank_account_id
			AND ce_accts.bank_branch_id = br.branch_party_id
			AND br.bank_party_id = party.party_id
                        AND nit.nit = substr(jgzz_fiscal_code,1,decode(instr(jgzz_fiscal_code,'-'),0,length(jgzz_fiscal_code)-1,instr(jgzz_fiscal_code,'-')-1)); --bug9078068

			FND_FILE.PUT_LINE(FND_FILE.log,'Misc Receipts Query(-)');

            l_country_code := fnd_profile.value ('JGZZ_COUNTRY_CODE');

            FND_FILE.PUT_LINE(FND_FILE.log,'l_country_code - l_branch_country_code : '
                                 ||l_country_code||'--'||l_branch_country_code);

			IF l_country_code = l_branch_country_code THEN
				g_nit_rec.nit_type := 'LEGAL_ENTITY';
			ELSE
				g_nit_rec.nit_type := 'FOREIGN_ENTITY';
			END IF;

			FND_FILE.PUT_LINE(FND_FILE.log,'g_nit_rec.nit_type : '||g_nit_rec.nit_type);
			l_identifier_type := 'JL_CO_GL_BANK';

		ELSIF (( l_customer_num IS NULL ) AND
             ( nvl(ar_trx.event_class_code,'$') <> 'MISC_RECEIPT' )) THEN
            FND_FILE.PUT_LINE(FND_FILE.log,'Event Class Code IS NOT Misc Receipts');
			BEGIN
                FND_FILE.PUT_LINE(FND_FILE.log,'Query(+)');
				SELECT jlcgn.nit_id,
					substr(jgzz_fiscal_code,1,decode(instr(jgzz_fiscal_code,'-'),0,14,instr(jgzz_fiscal_code,'-')-1)),  --bug8685975
					rac.party_name,
					SUBSTR(custacct.global_attribute10,1,30),
					custacct.global_attribute12,
					rac.party_number
				INTO g_nit_rec.nit_id,
					g_nit_rec.nit,
					g_nit_rec.nit_name,
					g_nit_rec.nit_type,
					g_nit_rec.verifying_digit,
					l_customer_num
				FROM jl_co_gl_nits jlcgn,
					hz_parties rac,
					hz_cust_accounts custacct
				WHERE custacct.cust_account_id = ar_trx.party_id
					AND substr(jgzz_fiscal_code,1,decode(instr(jgzz_fiscal_code,'-'),0,14,instr(jgzz_fiscal_code,'-')-1)) = jlcgn.nit(+)  --bug8685975
					AND custacct.party_id=rac.party_id;
                FND_FILE.PUT_LINE(FND_FILE.log,'Query(-)');
				FND_FILE.PUT_LINE(FND_FILE.log,'Non Misc : g_nit_rec : '||g_nit_rec.nit||'-'||g_nit_rec.nit_name);
			EXCEPTION
				WHEN no_data_found THEN
                    FND_FILE.PUT_LINE(FND_FILE.log,'Exception no data found in NOT Misc receipts');
					SELECT nit_id,
						nit,
						name,
						type,
						verifying_digit
					INTO g_nit_rec.nit_id,
						g_nit_rec.nit,
						g_nit_rec.nit_name,
						g_nit_rec.nit_type,
						g_nit_rec.verifying_digit
					FROM jl_co_gl_nits
					WHERE nit_id = g_default_nit_id;
				    FND_FILE.PUT_LINE(FND_FILE.log,'Exception Non Misc : g_nit_rec : '||g_nit_rec.nit||'-'||g_nit_rec.nit_name);

			END;

        g_gl_je_rec.identifier := l_customer_num;
		END IF;

		FND_FILE.PUT_LINE(FND_FILE.log,'Call To Validate_NIT in Generate_AR :'||g_gl_je_rec.identifier);

    IF Validate_NIT(g_nit_rec,l_identifier_type) THEN
		FND_FILE.PUT_LINE(FND_FILE.log,'After Validate :'||g_gl_je_rec.identifier);

        INSERT INTO jl_co_gl_trx (transaction_id,
                                  process_id,
                                  set_of_books_id,
                                  code_combination_id,
                                  account_code,
                                  nit_id,
                                  period_name,
                                  period_year,
                                  period_num,
                                  je_batch_id,
                                  je_header_id,
                                  category,
                                  subledger_doc_number,
                                  je_line_num,
                                  document_number,
                                  accounting_date,
                                  currency_code,
                                  creation_date,
                                  created_by,
                                  last_update_date,
                                  last_updated_by,
                                  last_update_login,
                                  accounted_dr,
                                  accounted_cr,
                                  entered_dr,
                                  entered_cr)
                          VALUES (jl_co_gl_trx_s.nextval,
                                  g_parameter_rec.cid,
                                  g_parameter_rec.set_of_books_id,
                                  p_journal_rec.code_combination_id,
                                  p_journal_rec.account_code,
                                  g_nit_rec.nit_id,
                                  p_journal_rec.period_name,
                                  g_period_year,
                                  g_period_num,
                                  p_journal_rec.je_batch_id,
                                  p_journal_rec.je_header_id,
                                  p_journal_rec.category,
                                  p_journal_rec.subl_doc_num,
                                  p_journal_rec.je_line_num,
                                --  DECODE(ar_trx.reference_8,'ADJ',
                                --         ar_trx.reference_5,ar_trx.reference_4),
                                  ar_trx.transaction_number,
                                  p_journal_rec.accounting_date,
                                  p_journal_rec.currency,
                                  sysdate,
                                  NVL(g_parameter_rec.user_id,-1),
                                  sysdate,
                                  NVL(g_parameter_rec.user_id,-1),
                                  g_login_id,
                                  l_acc_dr,
                                  l_acc_cr,
                                  l_ent_dr,
                                  l_ent_cr );

        BEGIN
        FND_FILE.PUT_LINE(FND_FILE.log,'Stage 1');
          SELECT 'TRUE'
          INTO g_error_exists
          FROM DUAL
          WHERE EXISTS (SELECT '1'
                        FROM jl_co_gl_conc_errs jlcgce
                        WHERE jlcgce.je_header_id = p_journal_rec.je_header_id
                        AND jlcgce.je_line_num = p_journal_rec.je_line_num);

        EXCEPTION
			WHEN no_data_found THEN
			FND_FILE.PUT_LINE(FND_FILE.log,'Exception in Stage 1');
            NULL;
        END;

        IF NVL(g_error_exists,'FALSE') = 'TRUE' THEN
		    FND_FILE.PUT_LINE(FND_FILE.log,'Stage 2.1');
			UPDATE gl_je_lines gljl
				SET co_processed_flag = 'N'
				WHERE gljl.je_header_id =  p_journal_rec.je_header_id
				AND gljl.je_line_num =  p_journal_rec.je_line_num
				AND EXISTS (SELECT 'Y'
							FROM jl_co_gl_trx jlcgt
							WHERE jlcgt.je_header_id = gljl.je_header_id
							AND jlcgt.je_line_num = gljl.je_line_num);

			DELETE FROM jl_co_gl_trx jlcgt
				WHERE jlcgt.je_header_id =  p_journal_rec.je_header_id
					AND jlcgt.je_line_num =  p_journal_rec.je_line_num;
        ELSE
		    FND_FILE.PUT_LINE(FND_FILE.log,'Stage2.2');
			UPDATE gl_je_lines gljl
				SET co_processed_flag = 'Y'
				WHERE gljl.je_header_id =  p_journal_rec.je_header_id
				AND gljl.je_line_num =  p_journal_rec.je_line_num
				AND EXISTS (SELECT 'Y'
							FROM jl_co_gl_trx jlcgt
							WHERE jlcgt.je_header_id = gljl.je_header_id
							AND jlcgt.je_line_num = gljl.je_line_num);

        END IF;

    END IF;

    END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.log,'After MAIN LOOP');
    -- since these are summary JE lines that are being processed,
    -- if any detail trx associated with the JE line fails then
    -- none of the trx should be processed

    BEGIN
	    FND_FILE.PUT_LINE(FND_FILE.log,'Stage 3');
		SELECT 'TRUE'
			INTO   g_error_exists
			FROM   DUAL
			WHERE  EXISTS (SELECT '1'
                     FROM   jl_co_gl_conc_errs jlcgce
                     WHERE  jlcgce.je_header_id = p_journal_rec.je_header_id
                     AND    jlcgce.je_line_num = p_journal_rec.je_line_num);

    EXCEPTION
		WHEN no_data_found THEN
		FND_FILE.PUT_LINE(FND_FILE.log,'Exception in Stage 3');
        NULL;
    END;

    IF NVL(g_error_exists,'FALSE') = 'TRUE' THEN
	    FND_FILE.PUT_LINE(FND_FILE.log,'Stage 4');
		UPDATE gl_je_lines gljl
            SET co_processed_flag = 'N'
            WHERE gljl.je_header_id =  p_journal_rec.je_header_id
            AND gljl.je_line_num =  p_journal_rec.je_line_num
            AND EXISTS (SELECT 'Y'
                        FROM jl_co_gl_trx jlcgt
                        WHERE jlcgt.je_header_id = gljl.je_header_id
                        AND jlcgt.je_line_num = gljl.je_line_num);

		DELETE FROM jl_co_gl_trx jlcgt
			WHERE  jlcgt.je_header_id =  p_journal_rec.je_header_id
			AND    jlcgt.je_line_num  =  p_journal_rec.je_line_num;
	END IF;

COMMIT;
--bug8499774
IF l_err_flag = 0 THEN
		Generate_GL_trx(g_journal_rec);
END IF;

EXCEPTION
    WHEN no_data_found THEN
	    FND_FILE.PUT_LINE(FND_FILE.log,'EXCEPTION no data found in Generate AR Transactions');
      -- import references don't exist or are summarized for journal
		Generate_GL_trx(g_journal_rec);   -- Create with NIT 0

    WHEN others THEN
	    FND_FILE.PUT_LINE(FND_FILE.log,'EXCEPTION others in Generate AR Transactions');
		g_error_code := SQLCODE;
		g_error_text := SUBSTR(SQLERRM,1,240);
		FND_FILE.PUT_LINE(FND_FILE.log,'Generate_AR_trx:'|| g_error_text);
		RAISE;
END Generate_AR_trx;


PROCEDURE Generate_Non_Oracle_trx(p_journal_rec IN journals%ROWTYPE) IS

BEGIN

    SELECT p_journal_rec.extgl_nit_id,
           p_journal_rec.ext_nit,
           p_journal_rec.ext_nit_name,
           p_journal_rec.ext_nit_type,
           p_journal_rec.ext_nit_v_digit
    INTO   g_nit_rec
    FROM   DUAL;

    BEGIN
      SELECT nit_id
      INTO   g_nit_rec.nit_id
      FROM   jl_co_gl_nits jlcgn
      WHERE  nit = p_journal_rec.ext_nit;

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    SELECT p_journal_rec.je_header_id,
           p_journal_rec.je_line_num,
           p_journal_rec.ext_nit
    INTO   g_gl_je_rec FROM DUAL;

    IF Validate_NIT(g_nit_rec,'JL_CO_GL_NIT') THEN
      NULL;
    ELSE
      -- if NIT is not valid we are creating transactions with
      -- NIT 0 for Non Oracle source since the users are unable to
      -- correct the nit information via the JE form. But we call this
      -- function so that users can see the kind of errors associated
      -- with the interfaced records */
      g_nit_rec.nit_id := g_default_nit_id;
    END IF;

    INSERT INTO jl_co_gl_trx (transaction_id,
                              process_id,
                              set_of_books_id,
                              code_combination_id,
                              account_code,
                              nit_id,
                              period_name,
                              period_year,
                              period_num,
                              je_batch_id,
                              je_header_id,
                              category,
                              subledger_doc_number,
                              je_line_num,
                              document_number,
                              accounting_date,
                              currency_code,
                              creation_date,
                              created_by,
                              last_update_date,
                              last_updated_by,
                              last_update_login,
                              accounted_dr,
                              accounted_cr,
                              entered_dr,
                              entered_cr)
                      VALUES (jl_co_gl_trx_s.nextval,
                              g_parameter_rec.cid,
                              g_parameter_rec.set_of_books_id,
                              p_journal_rec.code_combination_id,
                              p_journal_rec.account_code,
                              NVL(g_nit_rec.nit_id,g_default_nit_id),
                              p_journal_rec.period_name,
                              g_period_year,
                              g_period_num,
                              p_journal_rec.je_batch_id,
                              p_journal_rec.je_header_id,
                              p_journal_rec.category,
                              p_journal_rec.subl_doc_num,
                              p_journal_rec.je_line_num,
                              p_journal_rec.ext_doc_num,
                              p_journal_rec.accounting_date,
                              p_journal_rec.currency,
                              sysdate,
                              NVL(g_parameter_rec.user_id,-1),
                              sysdate,
                              NVL(g_parameter_rec.user_id,-1),
                              g_login_id,
                              DECODE(sign(p_journal_rec.accounted_cr),-1,
                                     (abs(p_journal_rec.accounted_cr) +
                                      NVL(DECODE(sign(p_journal_rec.accounted_dr),1,
                                         p_journal_rec.accounted_dr,NULL),0)),
                              DECODE(sign(p_journal_rec.accounted_dr),-1,
                                           NULL,p_journal_rec.accounted_dr)),
                              DECODE(sign(p_journal_rec.accounted_dr),-1,
                                    (abs(p_journal_rec.accounted_dr) +
                                     NVL(DECODE(sign(p_journal_rec.accounted_cr),1,
                                        p_journal_rec.accounted_cr,NULL),0)),
                                      DECODE(sign(p_journal_rec.accounted_cr),-1,
                                   NULL,p_journal_rec.accounted_cr)),
                              DECODE(sign(p_journal_rec.entered_cr),-1,
                                    (abs(p_journal_rec.entered_cr) +
                                     NVL(DECODE(sign(p_journal_rec.entered_dr),1,
                                                p_journal_rec.entered_dr,NULL),0)),
                                    DECODE(sign(p_journal_rec.entered_dr),-1,
                                           NULL,p_journal_rec.entered_dr)),
                              DECODE(sign(p_journal_rec.entered_dr),-1,
                                    (abs(p_journal_rec.entered_dr) +
                                     NVL(DECODE(sign(p_journal_rec.entered_cr),1,
                                                p_journal_rec.entered_cr,NULL),0)),
                                    DECODE(sign(p_journal_rec.entered_cr),-1,
                                           NULL,p_journal_rec.entered_cr)) );

/* bug 7045429

    BEGIN

      SELECT 'TRUE'
      INTO g_error_exists
      FROM DUAL
      WHERE EXISTS (SELECT '1'
                    FROM jl_co_gl_conc_errs jlcgce
                    WHERE jlcgce.je_header_id = p_journal_rec.je_header_id
                    AND jlcgce.je_line_num = p_journal_rec.je_line_num);

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    IF NVL(g_error_exists,'FALSE') = 'TRUE' THEN
      DELETE FROM jl_co_gl_trx jlcgt
        WHERE jlcgt.je_header_id =  p_journal_rec.je_header_id
        AND jlcgt.je_line_num =  p_journal_rec.je_line_num;
    ELSE */								  -- Bug 8215616
    UPDATE gl_je_lines gljl
        SET co_processed_flag = 'Y'
        WHERE gljl.je_header_id =  p_journal_rec.je_header_id
        AND gljl.je_line_num =  p_journal_rec.je_line_num
        AND EXISTS (SELECT 'Y'
                    FROM jl_co_gl_trx jlcgt
                    WHERE jlcgt.je_header_id = gljl.je_header_id
                    AND jlcgt.je_line_num = gljl.je_line_num); /*

    END IF;
*/

    COMMIT;

EXCEPTION
    WHEN others THEN
      BEGIN
        g_error_code := SQLCODE;
        g_error_text := SUBSTR(SQLERRM,1,240);
        FND_FILE.PUT_LINE(FND_FILE.log,'Generate_Non_Oracle_trx:'
                                                 || g_error_text);
        RAISE;
      END;

END Generate_Non_Oracle_trx;



PROCEDURE create_balances(
                    p_period        IN  VARCHAR2,
                    p_period_year   IN  NUMBER,
                    p_period_num    IN  NUMBER,
                    p_sobid         IN  NUMBER
    ) IS
    l_period_year       number(15);
    l_pre_period_num    number(15);
    l_pre_period        varchar2(15);
    l_bal_count         number;

BEGIN


    SELECT count(*)
        INTO l_bal_count
        FROM jl_co_gl_balances bal
        WHERE bal.period_name = p_period
        AND bal.period_year = p_period_year
        AND bal.set_of_books_id = p_sobid
        AND rownum = 1;

    IF l_bal_count = 0 THEN
        BEGIN
            SELECT max((bal.period_year * 100 + bal.period_num))
            INTO l_pre_period_num
            FROM jl_co_gl_balances bal
            WHERE (bal.period_year * 100 + bal.period_num) < p_period_year * 100 + p_period_num
            AND bal.set_of_books_id = p_sobid;

            INSERT INTO jl_co_gl_balances (
                              balance_id,
                              set_of_books_id,
                              code_combination_id,
                              account_code,
                              nit_id,
                              period_name,
                              period_num,
                              period_year,
                              currency_code,
                              begin_balance_cr,
                              begin_balance_dr,
                              period_net_cr,
                              period_net_dr,
                              creation_date,
                              created_by,
                              last_update_date,
                              last_updated_by,
                              last_update_login)
                       (select jl_co_gl_balances_s.nextval,
                              bal.set_of_books_id,
                              bal.code_combination_id,
                              bal.account_code,
                              bal.nit_id,
                              p_period,
                              p_period_num,
                              p_period_year,
                              bal.currency_code,
                              NVL(bal.begin_balance_cr,0)+NVL(bal.period_net_cr,0),
                              NVL(bal.begin_balance_dr,0)+NVL(bal.period_net_dr,0),
                              0,
                              0,
                              sysdate,
                              bal.created_by,
                              sysdate,
                              bal.last_updated_by,
                              bal.last_update_login
                        FROM jl_co_gl_balances bal
                        WHERE (bal.period_year * 100 + bal.period_num) = l_pre_period_num
                        AND bal.set_of_books_id = p_sobid);

        FND_FILE.PUT_LINE(FND_FILE.log,'p_sobid :'||to_char(p_sobid)||'-'||to_char(l_pre_period_num));


        EXCEPTION
            WHEN others THEN
            BEGIN
               g_error_code := SQLCODE;
               g_error_text := SUBSTR(SQLERRM,1,240);
               FND_FILE.PUT_LINE(FND_FILE.log,'create_balances:'
                                                   || g_error_text);
            RAISE;
            END;
        END;
    END IF;

END create_balances;


PROCEDURE Calculate_Balance(p_cid IN NUMBER,
                                p_sobid IN NUMBER,
                                p_userid IN NUMBER) IS

        l_balance_id  			jl_co_gl_balances.balance_id%TYPE;
        l_begin_bal_dr_prior_period	jl_co_gl_balances.begin_balance_dr%TYPE;
        l_begin_bal_cr_prior_period   	jl_co_gl_balances.begin_balance_cr%TYPE;
        l_period_net_dr_prior_period  	jl_co_gl_balances.period_net_dr%TYPE;
        l_period_net_cr_prior_period  	jl_co_gl_balances.period_net_cr%TYPE;
        l_begin_bal_dr 	 		jl_co_gl_balances.begin_balance_dr%TYPE;
        l_begin_bal_cr  			jl_co_gl_balances.begin_balance_cr%TYPE;
        l_period_set_name    		gl_periods.period_set_name%TYPE;
        l_max_period_num			gl_periods.period_num%TYPE;

        -- right now the currency field in jl_co_gl_balances only holds
        -- functional_currency_code. But in the future if the functionality
        -- is changed to hold balances for multiple currencies then curreny_code
        -- should be added to the BALANCE_TRX cursor and in other sql joins also

        CURSOR balance_trx IS
        SELECT jlcgt.set_of_books_id sobid,
               jlcgt.nit_id nitid,
    	     jlcgt.period_name period_name,
   	     jlcgt.code_combination_id ccid,
               jlcgt.account_code acccode,
  	     jlcgt.period_year peryear,
               jlcgt.period_num   pernum,
  	     glcc.account_type  acctype,
               NVL(sum(jlcgt.accounted_dr),0) acc_dr,
  	     NVL(sum(jlcgt.accounted_cr),0)  acc_cr
        FROM   gl_code_combinations glcc,  jl_co_gl_trx  jlcgt
        WHERE  jlcgt.process_id IN ( SELECT process_id
                                     FROM   jl_co_gl_conc_ctrl
  		                   WHERE  NVL(balance_calculated,'N') <> 'Y'
  	                           AND    set_of_books_id
                                               = g_parameter_rec.set_of_books_id)
        AND    jlcgt.code_combination_id =  glcc.code_combination_id
        GROUP BY jlcgt.set_of_books_id,
                 jlcgt.nit_id,
                 jlcgt.period_name,
                 jlcgt.code_combination_id,
                 jlcgt.account_code,
                 jlcgt.period_year,
                 jlcgt.period_num,
                 glcc.account_type ;

BEGIN  -- Calculate balances


FOR trx IN balance_trx  LOOP

      l_balance_id := 0;
  	  l_begin_bal_dr_prior_period   := 0;
  	  l_begin_bal_cr_prior_period   := 0;
   	  l_period_net_dr_prior_period := 0;
   	  l_period_net_cr_prior_period := 0;
  	  l_begin_bal_dr  := 0;
  	  l_begin_bal_cr  := 0;

		SELECT period_set_name,
				currency_code
		INTO   g_period_set_name,g_func_currency
		FROM   gl_sets_of_books glsob
		WHERE  glsob.set_of_books_id = trx.sobid;

        BEGIN

       	    SELECT balance_id
				INTO   l_balance_id
                FROM   jl_co_gl_balances  jlcgb
                WHERE  jlcgb.set_of_books_id = trx.sobid
				AND    jlcgb.nit_id = trx.nitid
				AND    jlcgb.code_combination_id = trx.ccid
				AND    jlcgb.period_name = trx.period_name;

  	    EXCEPTION
                WHEN no_data_found THEN
				NULL;

        END;

        IF l_balance_id = 0 THEN
               -- No balance record exists - insert new record

               -- calculate the begin_bal for new record by adding the
               -- begin_bal AND period_net_activity FROM the prior period which
               -- could even be more than a year behind cause we dont create
               -- balance records IN a specific period unless there is activity
               -- IN that period. This decision was made to avoid creating
               -- too many records IN jl_co_balances (unlike gl_balances)

                FND_FILE.PUT_LINE(FND_FILE.log,
                                     'If l_balance_id is 0 then insert ');
             BEGIN

                SELECT begin_balance_dr,
                       begin_balance_cr,
                       period_net_dr,
                       period_net_cr
                INTO   l_begin_bal_dr_prior_period,
                       l_begin_bal_cr_prior_period,
  	                   l_period_net_dr_prior_period,
                       l_period_net_cr_prior_period
                FROM   jl_co_gl_balances jlcgb
                WHERE  jlcgb.nit_id = trx.nitid
                AND    jlcgb.set_of_books_id = trx.sobid
                AND    jlcgb.code_combination_id = trx.ccid
                AND    (jlcgb.period_year * 100 + jlcgb.period_num) =
  	       	           (SELECT max(jlcgb1.period_year * 100 +
                                   jlcgb1.period_num)
                	         FROM   jl_co_gl_balances jlcgb1
  	    	                 WHERE  jlcgb1.nit_id = trx.nitid
       		                 AND    jlcgb1.set_of_books_id = trx.sobid
       		                 AND    jlcgb1.code_combination_id = trx.ccid
  		                     AND   (jlcgb1.period_year * 100 + jlcgb1.period_num) <
  		                           (trx.peryear * 100 + trx.pernum)
        	                 AND    jlcgb1.period_year BETWEEN
        			                 DECODE(trx.acctype,
                                     'R',trx.peryear, 'E',trx.peryear,
     			                     trx.peryear - 200)
                             AND    trx.peryear  );

              -- if acctype IS O,A or L then prior period could be
              -- FROM prior year but if R or E then it would have to be
              -- FROM same fiscal year as the period being considered

             EXCEPTION
                  WHEN no_data_found THEN
                    NULL;
  	          -- if this IS the 1st period for which balance record is
                    -- being inserted then there wont be a prior period AND
                    -- the previous sql statements will return 0 rows
                    -- but you still want the following statements to be executed
              END;

              l_begin_bal_dr := l_begin_bal_dr_prior_period  +
                                l_period_net_dr_prior_period ;
              l_begin_bal_cr := l_begin_bal_cr_prior_period  +
                                l_period_net_cr_prior_period ;

              INSERT INTO jl_co_gl_balances (
                                balance_id,
                                set_of_books_id,
                                code_combination_id,
  		                        account_code,
                                nit_id,
                                period_name,
                                period_num,
                                period_year,
  		                        currency_code,
                                begin_balance_dr,
                                begin_balance_cr,
                                period_net_dr,
                                period_net_cr,
                 	            creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by,
                                last_update_login)
                   VALUES ( jl_co_gl_balances_s.nextval,
                            trx.sobid,
                            trx.ccid,
                            trx.acccode,
                            trx.nitid,
  	           	            trx.period_name,
                            trx.pernum,
                            trx.peryear,
                            g_func_currency,
  		                    l_begin_bal_dr,
                            l_begin_bal_cr,
                            trx.acc_dr,
                            trx.acc_cr,
                            sysdate,
                            NVL(p_userid,-1),
                            sysdate,
  		                    NVL(p_userid,-1),
                            g_login_id);

           ELSE
              -- Balance record exists - Update period_net of current record
                FND_FILE.PUT_LINE(FND_FILE.log,
                                     'If l_balance_id is non 0 then update :' ||to_char(trx.acc_dr));
              UPDATE jl_co_gl_balances jlcgb
               SET    period_net_dr =  (period_net_dr + trx.acc_dr)  ,
       	              period_net_cr = (period_net_cr + trx.acc_cr),
  		              last_update_date = sysdate,
                      last_updated_by = p_userid,
                      last_update_login = g_login_id
  	           WHERE  jlcgb.set_of_books_id = trx.sobid
       	         AND    jlcgb.nit_id = trx.nitid
     	         AND    jlcgb.code_combination_id = trx.ccid
       	         AND    jlcgb.period_name = trx.period_name;

           END IF;

   	  -- Update begin balances of all future balance records for
      -- each balance_trx.
      -- For income statement accounts only the records in the same year
      -- as the transaction needs to be updated

  	  UPDATE jl_co_gl_balances jlcgb
  	  SET    begin_balance_dr = (begin_balance_dr + trx.acc_dr),
     	  	 begin_balance_cr = (begin_balance_cr + trx.acc_cr),
     		 last_update_date = sysdate,
             last_updated_by = p_userid,
             last_update_login = g_login_id
  	  WHERE  jlcgb.nit_id = trx.nitid
              AND  jlcgb.set_of_books_id = trx.sobid
              AND  jlcgb.code_combination_id = trx.ccid
              AND  (jlcgb.period_year * 100 + jlcgb.period_num) >
                                   (trx.peryear * 100 + trx.pernum)
              AND  period_year  BETWEEN trx.peryear AND
                         DECODE(trx.acctype, 'R',trx.peryear,
                                             'E',trx.peryear,
                                             trx.peryear * 100);

END LOOP;

          UPDATE jl_co_gl_conc_ctrl
          SET    status = DECODE(process_id,p_cid,'P',status),
                 balance_calculated = 'Y',
                 last_update_date = sysdate,
                 last_updated_by = p_userid,
                 last_update_login = g_login_id
          WHERE  NVL(balance_calculated,'N') <> 'Y'
  	        AND  set_of_books_id = g_parameter_rec.set_of_books_id;

          COMMIT;

EXCEPTION
    WHEN others THEN
         g_error_code := SQLCODE;
         g_error_text := SUBSTR(SQLERRM,1,240);
         FND_FILE.PUT_LINE(FND_FILE.log,'Calculate_Balance:'
                                                       || g_error_text);
    RAISE;

END Calculate_Balance;


PROCEDURE Reverse_Balance(p_rcid IN NUMBER, p_cid IN NUMBER,p_sobid IN NUMBER,
                       	  p_userid IN NUMBER) IS

       CURSOR reversal_trx IS
       SELECT jlcgt.set_of_books_id sobid,
              jlcgt.nit_id nitid,
              jlcgt.period_name period_name,
              jlcgt.code_combination_id ccid,
       	      jlcgt.account_code acccode,
              jlcgt.period_year peryear,
              jlcgt.period_num pernum,
  	          glcc.account_type  acctype,
              NVL(sum(jlcgt.accounted_dr),0) acc_dr,
  	          NVL(sum(jlcgt.accounted_cr),0) acc_cr
       FROM   gl_code_combinations glcc,
              jl_co_gl_trx  jlcgt
       WHERE  process_id = p_rcid
       AND    jlcgt.code_combination_id =  glcc.code_combination_id
       GROUP BY jlcgt.set_of_books_id,
                jlcgt.nit_id,
                jlcgt.period_name,
                jlcgt.code_combination_id,
                jlcgt.account_code,
                jlcgt.period_year,
                jlcgt.period_num,
                glcc.account_type;

BEGIN

         -- UPDATE balances

FOR trx IN reversal_trx
LOOP

     UPDATE jl_co_gl_balances  jlcgb
  	        -- period_net should be updated only for the purge period
      	 SET    period_net_dr =
               (period_net_dr - DECODE(jlcgb.period_name, trx.period_name,
                trx.acc_dr,0)),
       	        period_net_cr =
               (period_net_cr  - DECODE(jlcgb.period_name, trx.period_name,
                trx.acc_cr,0)),
         	      -- begin_balance for all future periods in the current year
                  -- only needs to be corrected for Income Statement accounts,
                  -- and all future periods for  balance sheet accounts
       	        begin_balance_dr =
                    (begin_balance_dr - DECODE(jlcgb.period_name, trx.period_name,
                                                               0,trx.acc_dr)) ,
                begin_balance_cr =
                    (begin_balance_cr - DECODE(jlcgb.period_name, trx.period_name,
                                                               0,trx.acc_cr)),
                last_update_date = sysdate,
                last_updated_by = p_userid ,
                last_update_login = g_login_id
  	 WHERE      jlcgb.set_of_books_id = trx.sobid
      	 AND    jlcgb.nit_id = trx.nitid
       	 AND    jlcgb.code_combination_id = trx.ccid
     	 AND    jlcgb.period_name IN (SELECT period_name
  		                              FROM gl_periods
  		                              WHERE period_set_name = g_period_set_name
  		                              AND  (period_year * 100 + period_num) >=
                                             (trx.peryear * 100 + trx.pernum)
  		                              AND  period_year BETWEEN trx.peryear AND
  		                                   DECODE(trx.acctype,
                                               'R',trx.peryear,'E',trx.peryear,
                                                      trx.peryear * 100));

           -- After the update if the period_net_dr and cr amounts are 0
           -- delete the balance record so that one would be able to delete
           -- an invalid NIT via the Define Third Party form.
           -- The form does not let you delete a NIT if there are records
           -- in jl_co_gl_trx and jl_co_gl_balances for that NIT

/* Bug 8339893:  Irrespective of balances being ZERO or not, if there are
 * NO records in table JL_CO_GL_TRX for same SOB, NIT, CCID and PERIOD NEITHER
 * for OTHER PROCESS_ID, then we can safely delete balances for SAME SOB,
 * NIT, CCID and PERIOD since this cursor already grouped this info for
 * current PROCESS_ID, meaning there are NO other TRXs using such balance */

     DELETE FROM jl_co_gl_balances jlcgb
     	 WHERE jlcgb.set_of_books_id = trx.sobid
              AND jlcgb.nit_id = trx.nitid
              AND jlcgb.code_combination_id = trx.ccid
  	          AND jlcgb.period_name = trx.period_name
-- bug 8339893   AND jlcgb.period_net_dr = 0 AND jlcgb.period_net_cr = 0
  	          AND NOT EXISTS (SELECT 1 FROM jl_co_gl_trx jlcgt
  			                  WHERE jlcgt.nit_id = trx.nitid
  			                  AND jlcgt.code_combination_id = trx.ccid
  			                  AND jlcgt.period_name = trx.period_name
  			                  AND jlcgt.set_of_books_id = trx.sobid
                              AND jlcgt.process_id <> p_rcid); --bug 8339893

END LOOP;  -- UPDATE balances

         -- delete transactions

		  UPDATE gl_je_lines gljl
		       SET co_processed_flag = 'N'
		       WHERE co_processed_flag = 'Y'
		       AND status = 'P'
		       AND EXISTS (SELECT 1
		                   FROM jl_co_gl_trx jlcgt
		                   WHERE jlcgt.process_id = p_rcid
		                   AND jlcgt.je_header_id = gljl.je_header_id
                           AND jlcgt.je_line_num = gljl.je_line_num );

         DELETE FROM jl_co_gl_trx
             WHERE  process_id = p_rcid ;

         UPDATE jl_co_gl_conc_ctrl
              SET    status = 'P',
                     reversed_process_id  = p_rcid,
  	                 last_update_date = sysdate,
                     last_updated_by = p_userid,
                     last_update_login = g_login_id
              WHERE  process_id = p_cid;

         UPDATE jl_co_gl_conc_ctrl
               SET    status = 'R',
  	                  last_update_date = sysdate,
                      last_updated_by = p_userid,
                      last_update_login = g_login_id
               WHERE  process_id = p_rcid;

         COMMIT;    -- Reversal is complete

EXCEPTION
    WHEN others THEN
             g_error_code := SQLCODE;
             g_error_text := SUBSTR(SQLERRM,1,240);
             FND_FILE.PUT_LINE(FND_FILE.log,'Reverse_Balance:'|| g_error_text);
             RAISE;

END Reverse_Balance;


PROCEDURE Create_Trx_Balance(errbuf         OUT NOCOPY VARCHAR2,
                             retcode        OUT NOCOPY NUMBER,
                             p_proc_type IN VARCHAR2,
                             p_sobid     IN NUMBER,
                             p_period    IN VARCHAR2,
      		                 p_rcid      IN NUMBER,
                             p_batchid   IN NUMBER) IS

    l_request_id 	NUMBER := 0;
    i               NUMBER := 1;
    l_rows          NUMBER := 0;
  	l_message_text  jl_co_gl_conc_errs.message_text%TYPE := NULL;

BEGIN

 FND_FILE.PUT_LINE(FND_FILE.log,'Create_Trx_Balance: Start');
 FND_FILE.PUT_LINE(FND_FILE.log,'Ledger ID: '||p_sobid);

 -- Bug 9078068, to access all sources data from xla_transaction_entities.

 xla_security_pkg.set_security_context(602);


DELETE FROM jl_co_gl_conc_errs;

    -- Find out which segment IS the natural account segment
  	SELECT application_column_name,
           id_flex_num
  	INTO   g_account_segment,
           g_chart_of_accounts_id
  	FROM   fnd_segment_attribute_values fndsav
   	WHERE  fndsav.id_flex_code = 'GL#'
    AND    fndsav.segment_attribute_type = 'GL_ACCOUNT'
  	AND    fndsav.attribute_value = 'Y'
    AND    application_id = 101
  	AND    fndsav.id_flex_num = (SELECT chart_of_accounts_id
                                       FROM   gl_sets_of_books
                                       WHERE  set_of_books_id = p_sobid);

  	-- Generate Process record


     SELECT TO_NUMBER(NVL(fnd_profile.value('LOGIN_ID'),-1))
     INTO   g_login_id
     FROM   DUAL;

     SELECT jl_co_gl_conc_ctrl_s.nextval,
            p_sobid,
            TO_NUMBER(NVL(fnd_profile.value('USER_ID') ,-1)),
            p_rcid
     INTO   g_parameter_rec
     FROM   dual;

     INSERT INTO jl_co_gl_conc_ctrl (
                 process_id,
                 set_of_books_id,
                 period_name,
                 reversed_process_id,
                 status,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 last_update_login,
                 balance_calculated)
  	  VALUES ( jl_co_gl_conc_ctrl_s.currval,
  	           p_sobid,
               DECODE(p_rcid,NULL,p_period,NULL),
               p_rcid,
               'E',
               sysdate,
  	           nvl(g_parameter_rec.user_id,-1),
               sysdate,
               nvl(g_parameter_rec.user_id,-1),
               g_login_id,
  	           NULL);

       COMMIT;

       BEGIN
         SELECT nit_id
         INTO   g_default_nit_id
   	     FROM   jl_co_gl_nits
         WHERE  nit = '0';

       EXCEPTION
  	      WHEN no_data_found THEN
  	      BEGIN
  		    INSERT INTO jl_co_gl_nits (
                        nit_id,
                        nit,
                        type,
                        verifying_digit,
                        name,
                        creation_date,
    		            created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login)
  		     VALUES ( jl_co_gl_nits_s.nextval,
                       0,
                      'LEGAL_ENTITY',
                       '0',
                       'Default',
                        sysdate,
                        1,
                        sysdate,
                        1,
                        null);

     		SELECT nit_id
            INTO   g_default_nit_id
  		    FROM   jl_co_gl_nits
            WHERE  nit = '0';
        END;
  	END;

  	SELECT period_set_name
    INTO   g_period_set_name
  	FROM   gl_sets_of_books glsob
  	WHERE  glsob.set_of_books_id = p_sobid;

    IF p_period is not null THEN
     	  SELECT period_num,
                 period_year
          INTO   g_period_num,
                   g_period_year
      	  FROM   gl_periods
  	      WHERE  period_set_name = g_period_set_name
  	      AND    period_name = p_period;
  	END IF;

IF p_proc_type = 'GENERATE' THEN

       -- Generate Transactions AND calculate balance
       FND_FILE.PUT_LINE(FND_FILE.log,'Create_Trx_Balance: Entering FOR LOOP');

    FOR j_line IN journals(p_period,p_sobid,p_batchid) LOOP
        FND_FILE.PUT_LINE(FND_FILE.log,'p_period :'||p_period||'-'||to_char(p_sobid)||'-'||to_char(p_batchid)||j_line.source);

        g_journal_rec := j_line;

        IF (j_line.source IN ('Payables') AND
             --Commented for bug8499774
             /*(j_line.ref_10 IS NOT NULL OR
               (j_line.ref_2 IS NULL AND
                j_line.ref_3 IS NULL AND
                j_line.ref_4 IS NULL AND
                j_line.ref_5 IS NULL )) AND*/
             j_line.reversed_je_header_id IS NULL) THEN
             FND_FILE.PUT_LINE(FND_FILE.log, 'Call to Generate_AP_trx :');
             Generate_AP_trx(g_journal_rec);
         ELSIF (j_line.source IN ('Cost Management') AND
             --(j_line.ref_1 = 'PO') AND
               (j_line.reversed_je_header_id IS NULL)) THEN
              Generate_PO_trx(g_journal_rec);
         ELSIF (j_line.source IN ('Receivables') AND
             --Commented for bug8499774
              /*(j_line.ref_10 IS NOT NULL OR
                (j_line.ref_2 IS NULL AND
                 j_line.ref_3 IS NULL AND
                 j_line.ref_4 IS NULL AND
                 j_line.ref_5 IS NULL )) AND*/
                 j_line.reversed_je_header_id IS NULL) THEN
              FND_FILE.PUT_LINE(FND_FILE.log, 'Call to Generate_AR_trx :');
              Generate_AR_trx(g_journal_rec);
         ELSIF (j_line.ref_10 IS NULL AND
               (j_line.ext_nit_type IS NOT NULL AND
                j_line.ext_nit_name IS NOT NULL AND
                j_line.ext_nit IS NOT NULL) AND
                (j_line.reversed_je_header_id IS NULL)) THEN

              Generate_Non_Oracle_trx(g_journal_rec);
         ELSIF (j_line.reversed_je_header_id IS NOT NULL) THEN
               reverse_rec_tbl(i).code_combination_id :=
               g_journal_rec.code_combination_id;
               reverse_rec_tbl(i).account_code :=
               g_journal_rec.account_code;
               reverse_rec_tbl(i).period_name :=
               g_journal_rec.period_name;
  			   reverse_rec_tbl(i).je_batch_id :=
  			   g_journal_rec.je_batch_id;
  	           reverse_rec_tbl(i).je_header_id :=
  	           g_journal_rec.je_header_id;
               reverse_rec_tbl(i).category :=
               g_journal_rec.category;
  			   reverse_rec_tbl(i).subl_doc_num :=
  			   g_journal_rec.subl_doc_num;
  	   		   reverse_rec_tbl(i).je_line_num :=
               g_journal_rec.je_line_num;
  			   reverse_rec_tbl(i).accounting_date :=
               g_journal_rec.accounting_date;
  	   	       reverse_rec_tbl(i).currency :=
      	       g_journal_rec.currency;
  			   reverse_rec_tbl(i).reversed_je_header_id :=
               g_journal_rec.reversed_je_header_id;
  			   reverse_rec_tbl(i).je_line_num :=
               g_journal_rec.je_line_num;
               -- Bug 9441034 Start
  	       reverse_rec_tbl(i).entered_dr := g_journal_rec.entered_dr;
  	       reverse_rec_tbl(i).entered_cr := g_journal_rec.entered_cr;
  	       reverse_rec_tbl(i).accounted_dr := g_journal_rec.accounted_dr;
  	       reverse_rec_tbl(i).accounted_cr := g_journal_rec.accounted_cr;
               -- Bug 9441034 End
               i := i + 1;
  		   ELSE
  		        Generate_GL_trx(g_journal_rec);
  		   END IF;
           g_journal_rec := NULL;

      END LOOP;    -- journal CURSOR

      -- Insert Reversed Journals
      l_rows := nvl(reverse_rec_tbl.last,0);
      FOR j_line IN 1..l_rows
         LOOP
            INSERT INTO jl_co_gl_trx(
                       	transaction_id,
                       	process_id,
                       	set_of_books_id,
  	            		code_combination_id,
            	    	account_code,
                        nit_id,
  			            period_name,
            			period_year,
  		            	period_num,
            			je_batch_id,
            			je_header_id,
                		category,
            			subledger_doc_number,
  		            	je_line_num,
            			document_number,
  		            	accounting_date,
            		    currency_code,
            			creation_date,
            			created_by,
  		            	last_update_date,
            			last_updated_by,
                 		last_update_login,
            			accounted_dr,
            			accounted_cr,
            			entered_dr,
            			entered_cr)
                       (SELECT jl_co_gl_trx_s.nextval,
                    			 g_parameter_rec.cid,
                      			 g_parameter_rec.set_of_books_id,
              	                 reverse_rec_tbl(j_line).code_combination_id,
                                 reverse_rec_tbl(j_line).account_code,
  	                             jlcgt.nit_id,
                                 reverse_rec_tbl(j_line).period_name,
              	                 g_period_year,
                      		 	 g_period_num,
                      			 reverse_rec_tbl(j_line).je_batch_id,
               	                 reverse_rec_tbl(j_line).je_header_id,
                                 reverse_rec_tbl(j_line).category,
                      			 reverse_rec_tbl(j_line).subl_doc_num,
                      	   		 reverse_rec_tbl(j_line).je_line_num,
                      			 jlcgt.document_number,
                      			 reverse_rec_tbl(j_line).accounting_date,
                  	   	         reverse_rec_tbl(j_line).currency,
                      			 sysdate,
                      			 NVL(g_parameter_rec.user_id,-1),
                      			 sysdate,
                      	  		 NVL(g_parameter_rec.user_id,-1),
                      			 g_login_id,
                                         -- Bug 9441034 Start
                      			 reverse_rec_tbl(j_line).accounted_dr,
                      			 reverse_rec_tbl(j_line).accounted_cr,
                      			 reverse_rec_tbl(j_line).entered_dr,
                      			 reverse_rec_tbl(j_line).entered_cr
                                         -- Bug 9441034 Start
                 		 FROM  jl_co_gl_trx jlcgt
                 		 WHERE jlcgt.je_header_id
                  				= reverse_rec_tbl(j_line).reversed_je_header_id
                  	  	   AND jlcgt.je_line_num
                  				= reverse_rec_tbl(j_line).je_line_num );

--bug 8845393 Starts: Updating CO_PROCESSED_FLAG for Reversal Lines so that
--                    same record is NOT picked again if reversal process
--                    is run more than once for same period.

          UPDATE gl_je_lines gljl
            SET co_processed_flag = 'Y'
            WHERE gljl.je_header_id = reverse_rec_tbl(j_line).je_header_id
            AND gljl.je_line_num = reverse_rec_tbl(j_line).je_line_num
            AND EXISTS (SELECT 'Y'
                        FROM jl_co_gl_trx jlcgt
                        WHERE jlcgt.je_header_id = gljl.je_header_id
                        AND jlcgt.je_line_num = gljl.je_line_num);
--bug 8845393 Ends

           END LOOP;

           COMMIT;  --bug 8845393: Since all other kinds of trxs are
--                         committed after they are created, committing
--                         also Reversed trxs to be in synch.

                -- Now that all the transactions are created - calculate balance
           FND_FILE.PUT_LINE(FND_FILE.log,
                                'Create_Trx_Balance: Calling Calculate Balance');


           Create_Balances( p_period,
                            g_period_year,
                            g_period_num ,
                            p_sobid);

           Calculate_Balance(g_parameter_rec.cid,
                             p_sobid,
                             g_parameter_rec.user_id);

               -- Submit the Third Party Balances Error Report

           l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                 'JL',
                                 'JLCOGLNE',
           		                 'Third Party Balances Error Report',
                                 '',
                                 FALSE,
                                 p_sobid,
                                 g_parameter_rec.cid);
           IF l_request_id = 0 THEN
  	           FND_FILE.PUT_LINE(FND_FILE.log,
                                         'CONC-REQUEST SUBMISSION FAILED');
           ELSE
               FND_MESSAGE.SET_NAME('SQLGL','GL_REQUEST_SUBMITTED');
               FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id,FALSE);
               l_message_text := FND_MESSAGE.GET;
               FND_FILE.PUT_LINE(FND_FILE.log,
                        'Submitted Third Party Balances Error Report. '
  		               || l_message_text);
           END IF;

ELSIF p_proc_type = 'REVERSE' THEN

    -- call Reverse Balances routine with the RCID
    FND_FILE.PUT_LINE(FND_FILE.log,'Create_Trx_Balance: Calling Reverse Balance');

     Reverse_Balance(p_rcid,
                     g_parameter_rec.cid,
                     p_sobid,
                     g_parameter_rec.user_id);
END IF;    -- if p_proc_type

FND_FILE.PUT_LINE(FND_FILE.log,'Create_Trx_Balance: Process completed successfully');

EXCEPTION
    WHEN others THEN
         g_error_code := SQLCODE;
         g_error_text := SUBSTR(SQLERRM,1,240);
         FND_FILE.PUT_LINE(FND_FILE.log,'Create_Trx_Balance:'|| g_error_text);
         RAISE;

END create_trx_balance;

END jl_co_gl_nit_management;


/
