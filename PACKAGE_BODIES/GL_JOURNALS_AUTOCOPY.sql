--------------------------------------------------------
--  DDL for Package Body GL_JOURNALS_AUTOCOPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JOURNALS_AUTOCOPY" AS
/* $Header: glujecpb.pls 120.6.12010000.7 2009/05/05 12:38:08 skotakar ship $ */

-- ********************************************************************

  PROCEDURE do_autocopy(Jeb_id			NUMBER,
			New_Name		VARCHAR2,
			New_Period_Name		VARCHAR2,
                        New_Eff_Date            DATE,
			X_Debug			VARCHAR2 DEFAULT NULL) IS

    GLUJECPB_FATAL_ERR 	EXCEPTION;
    usr_id 		NUMBER;
    log_id 		NUMBER;
    dmode_profile     	fnd_profile_option_values.profile_option_value%TYPE;
    dmode  		BOOLEAN;
    new_jeb_id		NUMBER;
    bc_flag             VARCHAR2(1);
    approval_flag       VARCHAR2(1);
    tmp                 NUMBER;
    x_org_id            fnd_profile_option_values.profile_option_value%TYPE;
    seq_num             fnd_profile_option_values.profile_option_value%TYPE;
    act_flag            VARCHAR2(1);
    org_id              NUMBER;
    temp		NUMBER;
  BEGIN

    GL_MESSAGE.Func_Ent(func_name => 'GL_JOURNALS_AUTOCOPY.do_autocopy');

    -- Obtain user ID and login ID
    usr_id 	:= FND_GLOBAL.User_Id;
    log_id	:= FND_GLOBAL.Login_Id;

    -- Get profile option values
    FND_PROFILE.GET('GL_DEBUG_MODE', dmode_profile);
    FND_PROFILE.GET('ORG_ID', x_org_id);
    FND_PROFILE.GET('UNIQUE:SEQ_NUMBERS', seq_num);

    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                         token_num => 3 ,
                         t1        =>'ROUTINE',
                         v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                         t2        =>'VARIABLE',
                         v2        =>'Debug Mode',
                         t3        =>'VALUE',
                         v3        => dmode_profile);

    -- Determine if process will be run in debug mode
    IF (NVL(X_Debug, 'N') <> 'N') OR (dmode_profile = 'Y') THEN
      dmode := TRUE;

      -- If debug mode, print out what we have so far
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'JEB_ID',
                           t3        =>'VALUE',
                           v3        => to_char(Jeb_id));
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'NEW_NAME',
                           t3        =>'VALUE',
                           v3        => New_Name);
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'NEW_PERIOD_NAME',
                           t3        =>'VALUE',
                           v3        => New_Period_Name);
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'NEW_EFF_DATE',
                           t3        =>'VALUE',
                           v3        => to_char(New_Eff_Date,'DD-MON-RR'));
       GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'ORG_ID',
                           t3        =>'VALUE',
                           v3        => Org_id);
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'SEQ_NUM',
                           t3        =>'VALUE',
                           v3        => Seq_Num);
    ELSE
      dmode := FALSE;
    END IF;

    -- Make sure the batch exists and get the actual_flag for use later on.
    BEGIN
      SELECT actual_flag
      INTO act_flag
      FROM gl_je_batches
      WHERE je_batch_id = jeb_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        GL_MESSAGE.Write_Log(msg_name  =>'JECP0000',
                             token_num => 1,
                             t1        =>'JEB_ID',
                             v1        =>to_char(jeb_id));
        Raise GLUJECPB_FATAL_ERR;
    END;

    -- Get the new je_batch_id
    SELECT gl_je_batches_s.nextval
    INTO new_jeb_id
    FROM dual;

    IF (SQL%ROWCOUNT <> 1) THEN
      Raise GLUJECPB_FATAL_ERR;
    END IF;

    IF (dmode) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'NEW_JEB_ID',
                           t3        =>'VALUE',
                           v3        => to_char(new_jeb_id));
    END IF;

    -- Determine the appropriate approval and budgetary control settings
    SELECT nvl(max(decode(enable_budgetary_control_flag, 'Y', 'Y', null)),'N'),
           nvl(max(decode(enable_je_approval_flag, 'Y', 'Y', null)), 'N')
    INTO bc_flag, approval_flag
    FROM gl_je_headers jeh, gl_ledgers lgr
    WHERE jeh.je_batch_id = jeb_id
    AND   lgr.ledger_id = jeh.ledger_id;

    IF (SQL%ROWCOUNT <> 1) THEN
      Raise GLUJECPB_FATAL_ERR;
    END IF;

    -- If approval is on, verify that AutoCopy journals require approval
    IF (approval_flag = 'Y') THEN
      SELECT journal_approval_flag
      INTO approval_flag
      FROM gl_je_sources
      WHERE je_source_name = 'AutoCopy';--Modified the source from Manual to Autocopy as part of bug7373688
    END IF;

    IF (dmode) THEN
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'BC_FLAG',
                           t3        =>'VALUE',
                           v3        => bc_flag);
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                           token_num => 3 ,
                           t1        =>'ROUTINE',
                           v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                           t2        =>'VARIABLE',
                           v2        =>'APPROVAL_FLAG',
                           t3        =>'VALUE',
                           v3        => approval_flag);
   END IF;

   -- Insert new batch here
   INSERT INTO gl_je_batches
      (je_batch_id,
       chart_of_accounts_id, period_set_name, accounted_period_type,
       name, status, status_verified, budgetary_control_status,
       actual_flag, average_journal_flag,
       default_effective_date, default_period_name,
       date_created, description, control_total,
       attribute1, attribute2, attribute3, attribute4, attribute5,
       attribute6, attribute7, attribute8, attribute9, attribute10, context,
       ussgl_transaction_code, org_id, approval_status_code,
       creation_date, created_by,
       last_update_date, last_updated_by, last_update_login)
    SELECT
       new_jeb_id,
       chart_of_accounts_id, period_set_name, accounted_period_type,
       New_Name, 'U', 'N', decode(bc_flag, 'Y', 'R', 'N'),
       actual_flag, average_journal_flag,
       New_eff_date, New_period_name,
       sysdate, description, control_total,
       attribute1, attribute2, attribute3, attribute4, attribute5,
       attribute6, attribute7, attribute8, attribute9, attribute10, context,
       ussgl_transaction_code, to_number(x_org_id),
       decode(approval_flag, 'Y', 'R', 'Z'),
       sysdate, usr_id, sysdate, usr_id, log_id
    FROM gl_je_batches
    WHERE je_batch_id = jeb_id;

    IF (SQL%ROWCOUNT <> 1) THEN
      Raise GLUJECPB_FATAL_ERR;
    END IF;

    temp := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                         token_num => 2 ,
                         t1        =>'NUM',
                         v1        =>to_char(temp),
                         t2        =>'TABLE',
                         v2        =>'GL_JE_BATCHES');

    DECLARE

       CURSOR select_journals IS
         SELECT jeh.je_header_id, jeh.ledger_id, jeh.je_category,
                jeh.currency_code, jeh.currency_conversion_type,
                jeh.currency_conversion_date, jeh.currency_conversion_rate,
                lgr.currency_code
         FROM gl_je_headers jeh, gl_ledgers lgr
         WHERE jeh.je_batch_id = jeb_id
         AND   lgr.ledger_id = jeh.ledger_id
         --Commented this as part of bug 7581299.
         --AND   jeh.parent_je_header_id IS NULL; /* See comments above */--Uncommented this as part of bug 7373688.
         AND   nvl(jeh.parent_je_header_id,0) = decode(lgr.ledger_category_code,'SECONDARY',nvl(jeh.parent_je_header_id,0),
                                                                                'PRIMARY',0,
                                                                                 'ALC',-999999,0);


       jeh_id				NUMBER;
       ledger_id                        NUMBER;
       je_category                      VARCHAR2(25);
       currency_code 			VARCHAR2(15);
       conversion_date                  DATE;
       conversion_type			VARCHAR2(25);
       conversion_rate			NUMBER;
       rev_method                       VARCHAR2(1);
       rev_period                       VARCHAR2(15);
       rev_date                         DATE;
       funct_curr                       VARCHAR2(15);
    BEGIN
      temp := 0;

      OPEN select_journals;
      LOOP
        FETCH select_journals
          INTO jeh_id, ledger_id, je_category,
               currency_code, conversion_type, conversion_date,
               conversion_rate, funct_curr;
        EXIT WHEN select_journals%NOTFOUND;

        -- Clear out reversal fields
        rev_method := null;
        rev_period := null;
        rev_date := null;

        -- Get new default reversal information
        gl_autoreverse_date_pkg.get_reversal_period_date(
            X_Ledger_Id => ledger_id,
            X_Je_Category => je_category,
            X_Je_Source => 'AutoCopy',---Modified the source from Manual to Autocopy as part of bug7373688
            X_Je_Period_Name => New_period_name,
            X_Je_Date => New_eff_date,
            X_Reversal_Method => rev_method,
            X_Reversal_Period => rev_period,
            X_Reversal_Date => rev_date);

        -- Get default reversal method, if provided
        IF (rev_method IS NULL) THEN
      	  gl_autoreverse_date_pkg.get_default_reversal_method(
  	    X_Ledger_Id     	=> ledger_id,
	    X_Category_Name 	=> je_category,
            X_Reversal_Method_Code => rev_method);
        END IF;

        -- If the conversion type wasn't user, than try to get the
        -- new conversion rate as of the new effective date.  If you
        -- can't get one, than leave the conversion information alone.
        IF (conversion_type <> 'User') THEN
          BEGIN
            conversion_rate := gl_currency_api.get_rate(
                                 currency_code,
	                         funct_curr,
                                 New_eff_date,
                                 conversion_type);
            conversion_date := New_eff_date;
          EXCEPTION
            WHEN gl_currency_api.no_rate THEN
              null;
          END;
        ELSE
          conversion_date := New_eff_date;
        END IF;

        IF (dmode) THEN
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'REV_METHOD',
                                t3        =>'VALUE',
                                v3        => rev_method);
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'REV_PERIOD',
                                t3        =>'VALUE',
                                v3        => rev_period);
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'REV_DATE',
                                t3        =>'VALUE',
                                v3        => to_char(rev_date,'DD-MON-RR'));
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'CONVERSION_RATE',
                                t3        =>'VALUE',
                                v3        => to_char(conversion_rate,
                                               '999999999999.99999999999999'));
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'CONV_DATE',
                                t3        =>'VALUE',
                                v3        => to_char(conversion_date,
                                               'DD-MON-RR'));
        END IF;

        INSERT INTO gl_je_headers
          (je_batch_id, je_header_id, ledger_id,
           je_category, je_source, default_effective_date, period_name,
           name, currency_code, status, date_created,
           multi_bal_seg_flag, actual_flag,
           conversion_flag, encumbrance_type_id, budget_version_id,
           accrual_rev_flag, accrual_rev_effective_date,
           accrual_rev_period_name, accrual_rev_change_sign_flag,
           description, control_total,
           currency_conversion_type, currency_conversion_date,
           currency_conversion_rate, external_reference,
           attribute1, attribute2, attribute3, attribute4, attribute5,
           attribute6, attribute7, attribute8, attribute9, attribute10,context,
           ussgl_transaction_code, jgzz_recon_context, jgzz_recon_ref,
           tax_status_code, reference_date, originating_bal_seg_value,
           creation_date, created_by,
           last_update_date, last_updated_by, last_update_login)
         SELECT
           new_jeb_id, gl_je_headers_s.nextval, ledger_id,
           je_category, 'AutoCopy', New_eff_date, New_period_name,---Modified the source from Manual to Autocopy as part of bug7373688
           decode(parent_je_header_id, NULL, name,
                  substrb(name, 1, (100 - (lengthb(to_char(je_header_id))+1)))
                  || ' ' || to_char(je_header_id)),
           currency_code, 'U', sysdate,
           'N', actual_flag,
           conversion_flag, encumbrance_type_id, budget_version_id,
           decode(rev_period, NULL, 'N', 'Y'), rev_date,
           rev_period, rev_method,
           description, control_total,
           conversion_type, conversion_date,
           conversion_rate, external_reference,
           attribute1, attribute2, attribute3, attribute4, attribute5,
           attribute6, attribute7, attribute8, attribute9, attribute10,context,
           ussgl_transaction_code, jgzz_recon_context, jgzz_recon_ref,
           'N', reference_date, originating_bal_seg_value,
           sysdate, usr_id, sysdate, usr_id, log_id
         FROM gl_je_headers
         WHERE je_header_id = jeh_id;

        IF (SQL%ROWCOUNT <> 1) THEN
          Raise GLUJECPB_FATAL_ERR;
        END IF;

        temp := temp + 1;
      END LOOP;
    END;

    temp := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                         token_num => 2 ,
                         t1        =>'NUM',
                         v1        =>to_char(temp),
                         t2        =>'TABLE',
                         v2        =>'GL_JE_HEADERS');

    -- Insert the new journal lines
    INSERT INTO gl_je_lines
      (je_header_id, je_line_num, ledger_id,
       code_combination_id, period_name, effective_date,
       status, entered_dr, entered_cr, accounted_dr, accounted_cr,
       description, stat_amount, ignore_rate_flag,
       attribute1, attribute2, attribute3, attribute4, attribute5,
       attribute6, attribute7, attribute8, attribute9, attribute10, context,
       attribute11, attribute12, attribute13, attribute14, attribute15,
       attribute16, attribute17, attribute18, attribute19,attribute20,context2,
       no1,--Added this as part of bug6521457
       ussgl_transaction_code,
       co_third_party, creation_date, created_by,
       last_update_date, last_updated_by, last_update_login)
    SELECT
       jeh2.je_header_id, jel.je_line_num, jel.ledger_id,
       jel.code_combination_id, jeh2.period_name,
       jeh2.default_effective_date,
       'U', jel.entered_dr, jel.entered_cr,
       decode(jel.ignore_rate_flag, 'Y', jel.accounted_dr,
              decode(curr.minimum_accountable_unit,
                NULL, round(jeh2.currency_conversion_rate * jel.entered_dr,
                            precision),
                round(jeh2.currency_conversion_rate * jel.entered_dr
                      / curr.minimum_accountable_unit)
                * curr.minimum_accountable_unit)),
       decode(jel.ignore_rate_flag, 'Y', jel.accounted_cr,
              decode(curr.minimum_accountable_unit,
                NULL, round(jeh2.currency_conversion_rate * jel.entered_cr,
                            precision),
                round(jeh2.currency_conversion_rate * jel.entered_cr
                      / curr.minimum_accountable_unit)
                * curr.minimum_accountable_unit)),
       jel.description, jel.stat_amount, jel.ignore_rate_flag,
       jel.attribute1, jel.attribute2, jel.attribute3, jel.attribute4,
       jel.attribute5, jel.attribute6, jel.attribute7, jel.attribute8,
       jel.attribute9, jel.attribute10, jel.context,
       jel.attribute11, jel.attribute12, jel.attribute13, jel.attribute14,
       jel.attribute15, jel.attribute16, jel.attribute17, jel.attribute18,
       jel.attribute19, jel.attribute20, jel.context2,
       jel.no1,--Added this as part of bug6521457
       jel.ussgl_transaction_code,
       jel.co_third_party,
       sysdate, usr_id, sysdate, usr_id, log_id
    FROM gl_je_headers jeh1, gl_je_headers jeh2, gl_ledgers lgr,
         fnd_currencies curr, gl_je_lines jel
    WHERE jeh1.je_batch_id = jeb_id
    AND   jeh2.je_batch_id = new_jeb_id
    AND   jeh2.name IN (jeh1.name,
                        substrb(jeh1.name,
                          1,(100-(lengthb(to_char(jeh1.je_header_id))+1)))
                        || ' ' || to_char(jeh1.je_header_id))
    AND   lgr.ledger_id = jeh2.ledger_id
    AND   curr.currency_code = lgr.currency_code
    AND   jel.je_header_id = jeh1.je_header_id
    AND   nvl(jel.tax_line_flag,'N') = 'N';

    temp := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                         token_num => 2 ,
                         t1        =>'NUM',
                         v1        =>to_char(temp),
                         t2        =>'TABLE',
                         v2        =>'GL_JE_LINES');

    -- Insert the new journal segment values
    INSERT INTO gl_je_segment_values
      (je_header_id, segment_type_code, segment_value,
       creation_date, created_by,
       last_update_date, last_updated_by, last_update_login)
    SELECT
       jeh2.je_header_id, sv.segment_type_code, sv.segment_value,
       sysdate, usr_id, sysdate, usr_id, log_id
    FROM gl_je_headers jeh1, gl_je_headers jeh2, gl_je_segment_values sv
    WHERE jeh1.je_batch_id = jeb_id
    AND   jeh2.je_batch_id = new_jeb_id
    AND   jeh2.name IN (jeh1.name,
                        substrb(jeh1.name,
                          1,(100-(lengthb(to_char(jeh1.je_header_id))+1)))
                        || ' ' || to_char(jeh1.je_header_id))
    AND   sv.je_header_id = jeh1.je_header_id;

    temp := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                         token_num => 2 ,
                         t1        =>'NUM',
                         v1        =>to_char(temp),
                         t2        =>'TABLE',
                         v2        =>'GL_JE_SEGMENT_VALUES');

    -- Insert reconciliation data
    INSERT INTO gl_je_lines_recon
                (je_header_id, je_line_num, ledger_id,
                 jgzz_recon_ref,
                 creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login)
    SELECT jeh2.je_header_id, jel.je_line_num, jel.ledger_id,
           rec.jgzz_recon_ref,
           sysdate, usr_id, sysdate,
           usr_id, log_id
    FROM gl_je_batches jeb, gl_je_headers jeh1, gl_je_headers jeh2,
         gl_ledgers lgr, gl_je_lines jel,
         gl_code_combinations cc, gl_je_lines_recon rec
    WHERE jeb.je_batch_id = jeb_id
    AND   jeb.average_journal_flag = 'N'
    AND   jeh1.je_batch_id = jeb_id
    AND   jeh1.actual_flag = 'A'
    AND   jeh1.je_source NOT IN ('Move/Merge', 'Move/Merge Reversal')
    AND   lgr.ledger_id = jeh1.ledger_id
    AND   lgr.enable_reconciliation_flag = 'Y'
    AND   jeh2.je_batch_id = new_jeb_id
    AND   jeh2.name IN (jeh1.name,
                        substrb(jeh1.name,
                          1,(100-(lengthb(to_char(jeh1.je_header_id))+1)))
                        || ' ' || to_char(jeh1.je_header_id))
    AND   jel.je_header_id = jeh1.je_header_id
    AND   nvl(jel.tax_line_flag,'N') = 'N'
    AND   cc.code_combination_id = jel.code_combination_id
    AND   cc.jgzz_recon_flag = 'Y'
    AND   rec.je_header_id(+) = jel.je_header_id
    AND   rec.je_line_num(+) = jel.je_line_num;

    temp := SQL%ROWCOUNT;
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0117',
                         token_num => 2 ,
                         t1        =>'NUM',
                         v1        =>to_char(temp),
                         t2        =>'TABLE',
                         v2        =>'GL_JE_LINES_RECON');

    -- Fix the running totals for the journals
    UPDATE gl_je_headers jeh
    SET (running_total_dr, running_total_cr,
         running_total_accounted_dr, running_total_accounted_cr)
      = (SELECT sum(nvl(entered_dr,0)), sum(nvl(entered_cr,0)),
                sum(nvl(accounted_dr,0)), sum(nvl(accounted_cr,0))
         FROM gl_je_lines jel
         WHERE jel.je_header_id = jeh.je_header_id)
    WHERE jeh.je_batch_id = new_jeb_id;

    -- Fix the batch running totals
    UPDATE gl_je_batches jeb
    SET (running_total_dr, running_total_cr,
         running_total_accounted_dr, running_total_accounted_cr)
      = (SELECT sum(running_total_dr),
                sum(running_total_cr),
                sum(running_total_accounted_dr),
                sum(running_total_accounted_cr)
         FROM gl_je_headers jeh
         WHERE jeh.je_batch_id = jeb.je_batch_id)
    WHERE jeb.je_batch_id = new_jeb_id;

    -- If sequential numbering is on and this is an
    -- actual batch, than try to get sequential numbering
    -- information
    IF ( (seq_num <> 'N') AND (act_flag = 'A')) THEN
    DECLARE
       je_category gl_je_headers.je_category%TYPE; /*Bug 6665535*/
       lgr_id      gl_je_headers.ledger_id%TYPE; /*Bug 6665535*/
       effdate     DATE;
       seq_id      NUMBER;
       seq_val     NUMBER;
       row_id      ROWID;
       seq_result  NUMBER;
       je_name     gl_je_headers.name%TYPE; /*Bug 6665535*/
       CURSOR new_journals IS
          SELECT rowid, ledger_id, je_category,
                 substrb(name, 25)
          FROM gl_je_headers
          WHERE je_batch_id = new_jeb_id;
    BEGIN

       OPEN new_journals;
       LOOP
         seq_val := NULL;
         seq_id := NULL;
         FETCH new_journals INTO row_id, lgr_id, je_category, je_name;
         EXIT WHEN new_journals%NOTFOUND;

         IF (dmode) THEN
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'JE_CATEGORY',
                                t3        =>'VALUE',
                                v3        => je_category);
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'LGR_ID',
                                t3        =>'VALUE',
                                v3        => to_char(lgr_id));
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'EFFDATE',
                                t3        =>'VALUE',
                                v3        => to_char(New_eff_date,
                                                     'DD-MON-RR'));
         END IF;

         seq_result := FND_SEQNUM.get_seq_val(
	      		   app_id => 101,
	 		   cat_code => je_category,
         		   sob_id => lgr_id,
         		   met_code => 'A',
         		   trx_date => New_eff_date,
		           seq_val => seq_val,
         		   docseq_id => seq_id,
                           suppress_warn => 'Y');

         IF (dmode) THEN
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'SEQ_RESULT',
                                t3        =>'VALUE',
                                v3        => to_char(seq_result));
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'SEQ_VAL',
                                t3        =>'VALUE',
                                v3        => to_char(seq_val));
           GL_MESSAGE.Write_Log(msg_name  =>'SHRD0181',
                                token_num => 3 ,
                                t1        =>'ROUTINE',
                                v1        =>'GL_JOURNALS_AUTOCOPY.do_autocopy',
                                t2        =>'VARIABLE',
                                v2        =>'SEQ_ID',
                                t3        =>'VALUE',
                                v3        => to_char(seq_id));
         END IF;

         IF ((seq_result = 0) AND (seq_val IS NOT NULL)) THEN
           UPDATE gl_je_headers
           SET doc_sequence_id = seq_id,
               doc_sequence_value = seq_val
           WHERE rowid = row_id;
         ELSIF (seq_num = 'A') THEN
           GL_MESSAGE.Write_Log(msg_name  =>'JECP0001',
                                token_num => 2 ,
                                t1        =>'NAME',
                                v1        => je_name);
           Raise GLUJECPB_FATAL_ERR;
         END IF;
       END LOOP;
       CLOSE new_journals;
    END;
    END IF;

    -- Commit all work
    FND_CONCURRENT.Af_Commit;

    GL_MESSAGE.Func_Succ(func_name => 'GL_JOURNALS_AUTOCOPY.do_autocopy');

  EXCEPTION
    WHEN OTHERS THEN
      Rollback;
      GL_MESSAGE.Func_Fail(func_name => 'GL_JOURNALS_AUTOCOPY.do_autocopy');
      RAISE;
  END do_autocopy;

-- ********************************************************************

  PROCEDURE do_autocopy(errbuf	OUT NOCOPY	VARCHAR2,
		 	retcode	OUT NOCOPY	VARCHAR2,
			Jeb_id			NUMBER,
			New_Name		VARCHAR2,
			New_Period_Name		VARCHAR2,
                        New_Eff_Date            VARCHAR2,
			X_Debug			VARCHAR2 DEFAULT NULL) IS
  BEGIN
    GL_MESSAGE.Func_Ent(func_name => 'GL_JOURNALS_AUTOCOPY.do_autocopy');
    GL_JOURNALS_AUTOCOPY.do_autocopy(
	Jeb_id		=> Jeb_id,
	New_Name	=> New_Name,
	New_Period_Name	=> New_Period_Name,
	New_Eff_Date	=> to_date(New_Eff_Date, 'YYYY/MM/DD'),
	X_Debug		=> X_Debug);
    GL_MESSAGE.Func_Succ(func_name => 'GL_JOURNALS_AUTOCOPY.do_autocopy');

  EXCEPTION
    WHEN OTHERS THEN
      GL_MESSAGE.Func_Fail(func_name => 'GL_JOURNALS_AUTOCOPY.do_autocopy');
      errbuf := SQLERRM ;
      retcode := '2';
      ROLLBACK;
      app_exception.raise_exception;
  END do_autocopy;

END GL_JOURNALS_AUTOCOPY;

/
