--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_CHG_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_CHG_PRC" AS
/* $Header: IGFSL23B.pls 120.3 2006/08/25 07:20:21 veramach noship $ */
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 10 October 2004
--
--Purpose:
-- Invoked     : Through Table Handlers of Disbursement and Loans table
-- Function    : To create Change Records for CommonLine Release 4 version Loans.
--               Four routines defined in this package would be invoked for changes
--               IN award or loan information for CommonLine Release 4 version Loans
--               that are "Accepted"
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--
--tsailaja    25-Jul-2006     Bug #5337555 FA 163 Included 'GPLUSFL'
--                            Included 'GPLUSFL' fund code for validating change records
--                            AND excluded 'GPLUSFL' fund code from Stafford Loan limit validation
-------------------------------------------------------------------
-- procedure for enabling statement level logging
PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                       p_v_string IN VARCHAR2
                     );

FUNCTION validate_ssn ( p_n_person_id igf_ap_fa_base_rec_all.person_id%TYPE)
RETURN BOOLEAN;

PROCEDURE validate_chg  (p_n_clchgsnd_id   IN  igf_sl_clchsn_dtls.clchgsnd_id%TYPE,
                         p_b_return_status OUT NOCOPY BOOLEAN,
                         p_v_message_name  OUT NOCOPY VARCHAR2,
                         p_t_message_tokens  OUT NOCOPY token_tab%TYPE
                        ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 10 October 2004
--
-- Purpose:
-- Invoked     : From igf_sl_cl_create_chg process to validate change record
-- Function    : This process would be invoked automatically for each change record
--
-- Parameters  : p_n_clchgsnd_id   : IN parameter. Required.
--               p_b_return_status : OUT parmeter.
--               p_v_message_name  : OUT parameter
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_igf_sl_lor_loans (cp_n_loan_id igf_sl_loans_all.loan_id%TYPE) IS
SELECT  isl.anticip_compl_date anticipated_completion_date
        ,islv.loan_per_end_date loan_end_date
FROM    igf_sl_lor_v isl,
        igf_sl_loans_v islv
WHERE   isl.loan_id = islv.loan_id and
        isl.loan_id  = cp_n_loan_id;

CURSOR  c_igf_sl_clchsn_dtls (cp_n_clchgsnd_id igf_sl_clchsn_dtls.clchgsnd_id%TYPE) IS
SELECT   clchgsnd.award_id
        ,clchgsnd.loan_number_txt
FROM    igf_sl_clchsn_dtls clchgsnd
WHERE   clchgsnd.clchgsnd_id = cp_n_clchgsnd_id;

CURSOR  c_igf_sl_loans (cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
SELECT  lar.loan_id
FROM    igf_sl_loans_all lar
WHERE   lar.loan_number = cp_v_loan_number;

CURSOR  c_igf_sl_lor (cp_n_loan_id igf_sl_loans_all.loan_id%TYPE) IS
SELECT   lor.p_person_id        borrower_id
        ,lor.relationship_cd    relationship_cd
        ,lor.cl_seq_number   cl_seq_number
FROM    igf_sl_lor_all lor
WHERE   lor.loan_id = cp_n_loan_id;

CURSOR  c_igf_aw_award (cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
SELECT  awd.base_id
FROM    igf_aw_award_all awd
WHERE   awd.award_id = cp_n_award_id;

CURSOR  c_igf_ap_fa_base_rec (cp_n_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
SELECT  fabase.person_id
FROM    igf_ap_fa_base_rec_all fabase
WHERE   fabase.base_id = cp_n_base_id;

CURSOR   c_igf_sl_cl_recipient (cp_v_relationship_cd igf_sl_cl_recipient.relationship_cd%TYPE) IS
SELECT   rcpt.guarantor_id
        ,rcpt.lender_id
FROM     igf_sl_cl_recipient rcpt
WHERE    relationship_cd = cp_v_relationship_cd;

l_n_clchgsnd_id      igf_sl_clchsn_dtls.clchgsnd_id%TYPE;
l_n_award_id         igf_aw_award_all.award_id%TYPE;
l_v_loan_number      igf_sl_loans_all.loan_number%TYPE;
l_n_person_id        igf_ap_fa_base_rec_all.person_id%TYPE;
l_n_loan_id          igf_sl_loans_all.loan_id%TYPE;
l_v_school_id        igs_pe_alt_pers_id.person_id_type%TYPE;
l_n_base_id          igf_ap_fa_base_rec_all.base_id%TYPE;
l_v_relationship_cd  igf_sl_cl_recipient.relationship_cd%TYPE;
l_v_guarantor_id     igf_sl_guarantor.guarantor_id%TYPE;
l_v_lender_id        igf_sl_lender.lender_id%TYPE;
l_n_cl_seq_number    igf_sl_lor_all.cl_seq_number%TYPE;
l_v_fed_fund_code    igf_aw_fund_cat_all.fed_fund_code%TYPE;
l_v_message_name     fnd_new_messages.message_name%TYPE;
l_b_return_status    BOOLEAN;
l_loan_tab           igf_aw_packng_subfns.std_loan_tab ;
l_n_aid              NUMBER ;
l_d_ant_comp_dt      igf_sl_lor_v.anticip_compl_date%TYPE;
l_d_loan_end_dt      igf_sl_loans_v.loan_per_end_date%TYPE;
BEGIN

  -- This process would be invoked automatically for each change record created.
  -- While creating change record the validations would be performed. In case of
  -- validation failures change record would not be created and the transaction
  -- that initiated the change record creation would also be rolled back.
  -- Rollback is handled in calling routine

  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => ' Validating the input parameters. p_n_clchgsnd_id = '||p_n_clchgsnd_id
            );

  IF p_n_clchgsnd_id IS NULL THEN
    p_v_message_name  := 'IGS_GE_INVALID_VALUE';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  --Validation for common fields would be done only once. If the required information
  --is not available then the edit would be created. For each of the validation failures,
  --p_v_message_name would be set and p_b_return_status would be set to FALSE
  l_n_clchgsnd_id := p_n_clchgsnd_id;

  -- validating the loan type code
  OPEN  c_igf_sl_clchsn_dtls (cp_n_clchgsnd_id => l_n_clchgsnd_id);
  FETCH c_igf_sl_clchsn_dtls INTO l_n_award_id,l_v_loan_number;
  CLOSE c_igf_sl_clchsn_dtls;

  log_to_fnd(p_v_module => ' validate_chg',
             p_v_string => ' Validating the loan type code for award id = '||l_n_award_id
            );

  l_v_fed_fund_code := igf_sl_gen.get_fed_fund_code (p_n_award_id     => l_n_award_id,
                                                     p_v_message_name => l_v_message_name
                                                     );
  IF l_v_message_name IS NOT NULL THEN
    p_v_message_name  := l_v_message_name;
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  -- tsailaja -FA 163  -Bug 5337555
  IF l_v_fed_fund_code NOT IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_LOANT_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

   log_to_fnd(p_v_module => ' validate_chg ',
             p_v_string =>  ' validated loan type code. loan type code = '||l_v_fed_fund_code
            );

  OPEN  c_igf_sl_loans (cp_v_loan_number => l_v_loan_number);
  FETCH c_igf_sl_loans INTO l_n_loan_id;
  CLOSE c_igf_sl_loans ;

  OPEN  c_igf_sl_lor (cp_n_loan_id => l_n_loan_id);
  FETCH c_igf_sl_lor INTO l_n_person_id, l_v_relationship_cd,l_n_cl_seq_number;
  CLOSE c_igf_sl_lor ;

-- validating CommonLine Unique Identifier
  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => ' Validating the CommonLine Unique Identifier. loan number = '||l_v_loan_number
            );

  IF l_v_loan_number IS NULL THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_LNUMB_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  -- validating borrower SSn required field
  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validating the Borrower SSN for borrower id = '||l_n_person_id
            );

  l_b_return_status := validate_ssn(p_n_person_id => l_n_person_id);
  IF NOT (l_b_return_status)  THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_BSSN_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

--  Added anticipated Completeg date validation by upinjark : March 17th 2005.
--  Fix for Bug no. 4091086

-- validating Anticipated Completed date Vs Loan end date
  OPEN c_igf_sl_lor_loans (cp_n_loan_id => l_n_loan_id);
  FETCH c_igf_sl_lor_loans INTO l_d_ant_comp_dt, l_d_loan_end_dt;
  CLOSE c_igf_sl_lor_loans;

  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validating the Anticipated Completion Date = '|| l_d_ant_comp_dt || ', for person = ' ||l_n_person_id
            );

  IF (l_d_ant_comp_dt < l_d_loan_end_dt) THEN
	p_v_message_name := 'IGF_SL_CHECK_COMPLDATE';
	p_t_message_tokens(1).token_name  := 'VALUE' ;
	p_t_message_tokens(1).token_value := ' ' || to_char(l_d_ant_comp_dt, 'mm/dd/yyyy') ;
        p_b_return_status := FALSE;
	RETURN;
  END IF;

  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validating the End Date = '|| l_d_loan_end_dt || ', for person = ' ||l_n_person_id
            );

  -- validating school id required field
  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validating the School Id for loan Number = '||l_v_loan_number
            );
  l_v_school_id := SUBSTR(l_v_loan_number,1,6);
  IF ( l_v_school_id IS NULL ) THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_SCHID_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;
  IF (LENGTH(l_v_school_id) <> 6) THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_SCHID_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validated the School Id school id = '||l_v_school_id
            );

  -- validating Guarantor ID and Lender id required fields

  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validating the Guarantor ID and Lender id required fields for relatioship code = '||l_v_relationship_cd
            );

  OPEN   c_igf_sl_cl_recipient (cp_v_relationship_cd => l_v_relationship_cd);
  FETCH  c_igf_sl_cl_recipient INTO l_v_guarantor_id ,l_v_lender_id;
  CLOSE  c_igf_sl_cl_recipient ;

  IF l_v_guarantor_id IS NULL THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_GID_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  IF l_v_lender_id IS NULL THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_LID_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => ' Validated Guarantor ID and Lender id required fields '||
                           ' Guarantor ID = '||l_v_guarantor_id||
                           ' Lender id    = '|| l_v_lender_id
            );

  -- validating PLUS/Alternative Student SSN
  l_n_person_id := NULL;

  OPEN  c_igf_aw_award (cp_n_award_id => l_n_award_id);
  FETCH c_igf_aw_award INTO l_n_base_id;
  CLOSE c_igf_aw_award ;

  OPEN  c_igf_ap_fa_base_rec (cp_n_base_id => l_n_base_id);
  FETCH c_igf_ap_fa_base_rec INTO l_n_person_id;
  CLOSE c_igf_ap_fa_base_rec;

  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validating the PLUS/Alternative Student SSN for person id = '||l_n_person_id
            );
  l_b_return_status := TRUE;
  l_b_return_status := validate_ssn(p_n_person_id => l_n_person_id);
  IF NOT (l_b_return_status)  THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_SSSN_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;

  -- validating Loan Sequence Number
  IF l_n_cl_seq_number IS NULL THEN
    p_v_message_name  := 'IGF_SL_CL_CHG_GSEQ_REQD';
    p_b_return_status := FALSE;
    RETURN;
  END IF;
  log_to_fnd(p_v_module => 'validate_chg',
             p_v_string => 'Validated the Loan Sequence Number. cl_seq_number  = '||l_n_cl_seq_number
             );
  -- tsailaja -FA 163  -Bug 5337555
  -- validating loan amount limits
      -- Check the Loan Limts amounts for Loans other than DLP/FLP/ALT
  IF l_v_fed_fund_code NOT IN ('PRK','DLP','FLP','ALT','GPLUSFL') THEN
    -- re initializing the variables
    l_loan_tab := igf_aw_packng_subfns.std_loan_tab();
    l_n_aid    := 0;
    l_v_message_name := NULL;
    log_to_fnd(p_v_module => 'validate_chg',
               p_v_string => 'Validating the Loan Limts amount invoking  igf_aw_packng_subfns.check_loan_limits '
               );
    igf_aw_packng_subfns.check_loan_limits
    (
      l_base_id        => l_n_base_id,
      fund_type        => l_v_fed_fund_code,
      l_award_id       => l_n_award_id,
      l_adplans_id     => NULL,
      l_aid            => l_n_aid,
      l_std_loan_tab   => l_loan_tab,
      p_msg_name       => l_v_message_name
    );
    -- bvisvana - FA 161 - Bug 5006583 - Stafford Loan Limit validation is treated as warning and not as error. So just print the message
    -- bvisvana - Bug 5091652 - If no loan limit setup exists for class standing then it is treated as error.
    -- In this case the l_aid = 0. So returning with return status as FALSE.
    IF l_v_message_name IS NOT NULL THEN
      IF l_n_aid = 0 THEN
        p_v_message_name  := l_v_message_name;
        p_b_return_status := FALSE;
        RETURN ;
      ELSIF l_n_aid < 0 THEN
        p_v_message_name  := 'IGF_SL_CL_GRD_AMT_VAL';
        fnd_message.set_name(substr(p_v_message_name,1,3),p_v_message_name);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;
    END IF;
  END IF;
 log_to_fnd(p_v_module => 'validate_chg',
            p_v_string => 'Validation of the change record successful. setting return status to true and message is cleared '
            );
  p_v_message_name  := NULL;
  p_b_return_status := TRUE;

EXCEPTION
  WHEN OTHERS THEN
   log_to_fnd(p_v_module => 'when others exception handler',
              p_v_string => SQLERRM
              );

   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_cl_chg_prc.validate_chg');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END validate_chg;

PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                       p_v_string IN VARCHAR2 ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 18 October 2004
--
-- Purpose:
-- Invoked     : from within validate_chg procedure
-- Function    : Private procedure for logging all the statement level
--               messages
-- Parameters  : p_v_module   : IN parameter. Required.
--               p_v_string   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_sl_cl_chg_prc. '||p_v_module||' Debug', p_v_string);
  END IF;
END log_to_fnd;

FUNCTION validate_ssn ( p_n_person_id igf_ap_fa_base_rec_all.person_id%TYPE)
RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 18 October 2004
--
-- Purpose:
-- Invoked     : from within validate_chg procedure
-- Function    : Private procedure which would validate SSN
--               for the input person id
-- Parameters  : p_n_person_id   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
c_person_dtl_cur     igf_sl_gen.person_dtl_cur;
rec_c_person_dtl_cur igf_sl_gen.person_dtl_rec;
l_person_ssn         igs_pe_alt_pers_id.person_id_type%TYPE;
BEGIN

  log_to_fnd(p_v_module => 'validate_ssn ',
             p_v_string => 'Private function validate_ssn input parameter p_n_person_id = '||p_n_person_id
            );
  -- invoke igf_sl_gen.get_person_details
  igf_sl_gen.get_person_details
  (
    p_person_id       => p_n_person_id,
    p_person_dtl_rec  => c_person_dtl_cur
  );
  FETCH c_person_dtl_cur INTO rec_c_person_dtl_cur;
  CLOSE c_person_dtl_cur ;
  l_person_ssn := NVL(rec_c_person_dtl_cur.p_ssn,'NULL');
  log_to_fnd(p_v_module => 'validate_ssn ',
             p_v_string => 'party ssn = '||l_person_ssn
            );
  IF l_person_ssn IS NULL THEN
    log_to_fnd(p_v_module => 'validate_ssn ',
               p_v_string => 'ssn null ' ||
                             ' returning false'
              );
    RETURN FALSE;
  END IF;
  --if the SSN starts with 8, 9 or 0, it is deemed as invalid
  IF (SUBSTR(l_person_ssn,1,1) IN ('8','9') OR SUBSTR(l_person_ssn,1,3) =  '000') THEN
    log_to_fnd(p_v_module => 'validate_ssn ',
               p_v_string => 'SSN starts with 8, 9 or 0 ' ||
                             ' returning false'
              );
    RETURN FALSE;
  END IF;
    log_to_fnd(p_v_module => 'validate_ssn ',
               p_v_string => 'validations are successful ' ||
                             ' returning true'
              );
  RETURN TRUE;
END validate_ssn;

  PROCEDURE parse_tokens       ( p_t_message_tokens  IN  token_tab%TYPE) AS
  BEGIN
    IF (NVL(p_t_message_tokens.COUNT, 0) <> 0 AND p_t_message_tokens IS NOT NULL) THEN
      FOR token_counter IN NVL(p_t_message_tokens.FIRST, 0)..NVL(p_t_message_tokens.LAST, 0) LOOP
        fnd_message.set_token(p_t_message_tokens(token_counter).token_name, p_t_message_tokens(token_counter).token_value);
      END LOOP;
    END IF;
  END parse_tokens;

END igf_sl_cl_chg_prc;

/
