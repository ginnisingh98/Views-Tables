--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_CREATE_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_CREATE_CHG" AS
/* $Header: IGFSL22B.pls 120.1 2006/04/21 04:07:10 bvisvana noship $ */
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
-------------------------------------------------------------------

-- procedure for enabling statement level logging
PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                       p_v_string IN VARCHAR2
                     );
-- function to return the change send details
FUNCTION get_sl_clchsn_dtls ( p_rowid ROWID) RETURN igf_sl_clchsn_dtls%ROWTYPE;

PROCEDURE create_loan_chg_rec(p_new_loan_rec    IN igf_sl_loans_all%ROWTYPE,
                              p_b_return_status OUT NOCOPY BOOLEAN,
                              p_v_message_name  OUT NOCOPY VARCHAR2
                              ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 10 October 2004
--
-- Purpose:
-- Invoked     : From loans table handler after update row of loans table
-- Function    :
--
-- Parameters  : p_new_loan_rec    : IN parameter. Required.
--               p_b_return_status : OUT parmeter.
--               p_v_message_name  : OUT parameter
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------

CURSOR  c_igf_sl_lor (cp_n_loan_id igf_sl_loans_all.loan_id%TYPE) IS
SELECT  lor.prc_type_code
       ,lor.cl_rec_status
FROM    igf_sl_lor_all lor
WHERE   loan_id = cp_n_loan_id;

rec_c_igf_sl_lor c_igf_sl_lor%ROWTYPE;

CURSOR  c_igf_sl_cl_resp_r1(cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
SELECT  resp.loan_per_begin_date
       ,resp.loan_per_end_date
FROM    igf_sl_cl_resp_r1_all resp
WHERE   resp.loan_number = cp_v_loan_number
AND     resp.cl_rec_status IN ('B','G')
AND     resp.prc_type_code IN ('GO','GP')
AND     resp.cl_version_code = 'RELEASE-4'
ORDER BY clrp1_id DESC;

rec_c_igf_sl_cl_resp_r1 c_igf_sl_cl_resp_r1%ROWTYPE;

TYPE ref_CurclchsnTyp IS REF CURSOR;
c_igf_sl_clchsn_dtls ref_CurclchsnTyp;

rec_c_igf_sl_clchsn_dtls igf_sl_clchsn_dtls%ROWTYPE;

l_d_loan_per_begin_date   igf_sl_cl_resp_r1_all.loan_per_begin_date%TYPE;
l_d_loan_per_end_date     igf_sl_cl_resp_r1_all.loan_per_end_date%TYPE;
l_d_res_loan_per_begin_dt igf_sl_cl_resp_r1_all.loan_per_begin_date%TYPE;
l_d_res_loan_per_end_dt   igf_sl_cl_resp_r1_all.loan_per_end_date%TYPE;
l_n_cl_version            igf_sl_cl_setup_all.cl_version%TYPE;
l_v_loan_status           igf_sl_loans_all.loan_status%TYPE;
l_n_clchgsnd_id           igf_sl_clchsn_dtls.clchgsnd_id%TYPE;
l_n_award_id              igf_aw_award_all.award_id%TYPE;
l_v_loan_number           igf_sl_loans_all.loan_number%TYPE;
l_n_loan_id               igf_sl_loans_all.loan_id%TYPE;
l_c_cl_rec_status         igf_sl_lor_all.cl_rec_status%TYPE;
l_v_prc_type_code         igf_sl_lor_all.prc_type_code%TYPE;
l_v_sqlstmt               VARCHAR2(32767);
l_v_rowid                 ROWID;
l_v_message_name          fnd_new_messages.message_name%TYPE;
l_b_return_status         BOOLEAN;
l_d_message_tokens        igf_sl_cl_chg_prc.token_tab%TYPE;

e_valid_edits     EXCEPTION;
e_resource_busy   EXCEPTION;
PRAGMA EXCEPTION_INIT(e_resource_busy,-00054);

BEGIN

  SAVEPOINT igf_sl_cl_create_chg_sp;
  log_to_fnd(p_v_module => 'create_loan_chg_rec',
             p_v_string => ' Entered Procedure create_loan_chg_rec: The input parameters are '          ||
                           ' new reference of Award Id : '          ||p_new_loan_rec.award_id           ||
                           ' new reference of Loan Id : '           ||p_new_loan_rec.loan_id            ||
                           ' new reference of Loan Number : '       ||p_new_loan_rec.loan_number        ||
                           ' new reference of Loan per begin date: '||p_new_loan_rec.loan_per_begin_date||
                           ' new reference of Loan per end date: '  ||p_new_loan_rec.loan_per_end_date  ||
                           ' new reference of Loan status: '        ||p_new_loan_rec.loan_status
            );

  l_n_award_id            := p_new_loan_rec.award_id;
  l_n_loan_id             := p_new_loan_rec.loan_id;
  l_v_loan_number         := p_new_loan_rec.loan_number;
  l_v_loan_status         := p_new_loan_rec.loan_status;
  l_d_loan_per_begin_date := p_new_loan_rec.loan_per_begin_date;
  l_d_loan_per_end_date   := p_new_loan_rec.loan_per_end_date;

  -- get the loan version for the input award id
  l_n_cl_version  := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);
  -- get the processing type code and loan record status for the input loan id
  OPEN  c_igf_sl_lor(cp_n_loan_id => l_n_loan_id);
  FETCH c_igf_sl_lor INTO rec_c_igf_sl_lor;
  CLOSE c_igf_sl_lor;

  l_v_prc_type_code := rec_c_igf_sl_lor.prc_type_code;
  l_c_cl_rec_status := rec_c_igf_sl_lor.cl_rec_status;

  -- get the latest Guaranteed Response for Begin Date for the input loan number
  -- if no records are found change record would not be created. The control is returned back
  -- to the calling program.

  OPEN  c_igf_sl_cl_resp_r1 (cp_v_loan_number =>l_v_loan_number);
  FETCH c_igf_sl_cl_resp_r1 INTO l_d_res_loan_per_begin_dt,l_d_res_loan_per_end_dt;
  IF c_igf_sl_cl_resp_r1%NOTFOUND THEN
    CLOSE c_igf_sl_cl_resp_r1 ;
    log_to_fnd(p_v_module => 'create_loan_chg_rec.',
               p_v_string => ' No Response record found for loan number: ' ||l_v_loan_number
              );
    p_b_return_status := FALSE;
    p_v_message_name  := NULL;
    RETURN;
  END IF;
  CLOSE c_igf_sl_cl_resp_r1 ;
  log_to_fnd(p_v_module => 'create_loan_chg_rec',
             p_v_string => ' Response record found for loan number: ' ||l_v_loan_number           ||
                           ' response loan per begin dt           : ' ||l_d_res_loan_per_begin_dt ||
                           ' response loan per end dt             : ' ||l_d_res_loan_per_end_dt
            );
  -- Check if the change record should be created or not
  -- Change Record would be created only if
  -- The version = CommonLine Release 4 Version Loan,
  -- Loan Status = Accepted
  -- Loan Record Status is Guaranteed or Accepted
  -- Processing Type Code is GP or GO
  -- The information is different from the latest Guaranteed Response Received for the Loan
  IF (l_n_cl_version = 'RELEASE-4' AND
      l_v_loan_status = 'A' AND
      l_v_prc_type_code IN ('GO','GP') AND
      l_c_cl_rec_status IN ('B','G'))
  THEN
    -- verify if latest Guaranteed Response has a different value for Begin Date
    -- start of code logic for loan per begin date changes
    IF (l_d_res_loan_per_begin_dt <> l_d_loan_per_begin_date)
    THEN

        log_to_fnd(p_v_module => 'create_loan_chg_rec',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted ' ||
                                 ' Loan Number                : ' || l_v_loan_number                  ||
                                 ' cl version                 : ' || l_n_cl_version                   ||
                                 ' loan status                : ' || l_v_loan_status                  ||
                                 ' Processing Type            : ' || l_v_prc_type_code                ||
                                 ' Loan Record Status         : ' || l_c_cl_rec_status                ||
                                 ' response loan per begin dt : ' || l_d_res_loan_per_begin_dt        ||
                                 ' new loan per begin dt      : ' || l_d_loan_per_begin_date          ||
                                 ' change_field_code          : ' || 'LOAN_PER_BEGIN_DT'
                  );
        -- verify if the existing change record is to be updated or inserted
      l_v_sqlstmt := 'SELECT chdt.ROWID row_id '                             ||
                     'FROM   igf_sl_clchsn_dtls chdt '                       ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '      ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '       ||
                     'AND    chdt.old_date = :cp_d_resp_begin_dt '           ||
                     'AND    chdt.change_field_code = ''LOAN_PER_BEGIN_DT'' '||
                     'AND    chdt.change_code_txt = ''A'' '                  ||
                     'AND    chdt.change_record_type_txt = ''07'' ';

      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_d_res_loan_per_begin_dt;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
        CLOSE c_igf_sl_clchsn_dtls;
        l_v_rowid       := NULL;
        l_n_clchgsnd_id := NULL;
        log_to_fnd(p_v_module => 'create_loan_chg_rec',
                   p_v_string => ' New Change record is Created  '                                                           ||
                                 ' Change_field_code : ' ||'LOAN_PER_BEGIN_DT'                                               ||
                                 ' Change record type: ' ||'07 - Loan Period/Grade Level/Anticipated Completion Date Change' ||
                                 ' Change code       : ' ||'A - Loan Period Change '
                  );

        igf_sl_clchsn_dtls_pkg.insert_row
        (
          x_rowid                      => l_v_rowid,
          x_clchgsnd_id                => l_n_clchgsnd_id,
          x_award_id                   => l_n_award_id,
          x_loan_number_txt            => l_v_loan_number,
          x_cl_version_code            => l_n_cl_version,
          x_change_field_code          => 'LOAN_PER_BEGIN_DT',
          x_change_record_type_txt     => '07',
          x_change_code_txt            => 'A',
          x_status_code                => 'R',
          x_status_date                => TRUNC(SYSDATE),
          x_response_status_code       => NULL,
          x_old_value_txt              => NULL,
          x_new_value_txt              => NULL,
          x_old_date                   => l_d_res_loan_per_begin_dt,
          x_new_date                   => l_d_loan_per_begin_date,
          x_old_amt                    => NULL,
          x_new_amt                    => NULL,
          x_disbursement_number        => NULL,
          x_disbursement_date          => NULL,
          x_change_issue_code          => NULL,
          x_disbursement_cancel_date   => NULL,
          x_disbursement_cancel_amt    => NULL,
          x_disbursement_revised_amt   => NULL,
          x_disbursement_revised_date  => NULL,
          x_disbursement_reissue_code  => NULL,
          x_disbursement_reinst_code   => NULL,
          x_disbursement_return_amt    => NULL,
          x_disbursement_return_date   => NULL,
          x_disbursement_return_code   => NULL,
          x_post_with_disb_return_amt  => NULL,
          x_post_with_disb_return_date => NULL,
          x_post_with_disb_return_code => NULL,
          x_prev_with_disb_return_amt  => NULL,
          x_prev_with_disb_return_date => NULL,
          x_school_use_txt             => NULL,
          x_lender_use_txt             => NULL,
          x_guarantor_use_txt          => NULL,
          x_validation_edit_txt        => NULL,
          x_send_record_txt            => NULL
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => ' create_loan_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                       );

        IF NOT(l_b_return_status) THEN
          log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                    );
          RAISE e_valid_edits;
        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
        log_to_fnd(p_v_module => 'create_loan_chg_rec',
                   p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                  );
      ELSE
        CLOSE c_igf_sl_clchsn_dtls;
        rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
        log_to_fnd(p_v_module => 'create_loan_chg_rec',
                   p_v_string => ' Change record is updated  '                                                               ||
                                 ' Change_field_code : ' ||'LOAN_PER_BEGIN_DT'                                               ||
                                 ' Change record type: ' ||'07 - Loan Period/Grade Level/Anticipated Completion Date Change' ||
                                 ' Change code       : ' ||'A - Loan Period Change '
                  );
        igf_sl_clchsn_dtls_pkg.update_row
        (
          x_rowid                      => l_v_rowid                                           ,
          x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
          x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
          x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
          x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
          x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
          x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
          x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
          x_status_code                => 'R'                                                 ,
          x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
          x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
          x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
          x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
          x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
          x_new_date                   => l_d_loan_per_begin_date                             ,
          x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
          x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
          x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
          x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
          x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
          x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
          x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
          x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
          x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
          x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
          x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
          x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
          x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
          x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
          x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
          x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
          x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
          x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
          x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
          x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
          x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
          x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
          x_validation_edit_txt        => NULL                                                ,
          x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                        );

        IF NOT(l_b_return_status) THEN
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
          FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
             fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
          END LOOP;
*/
          log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                     );
          log_to_fnd(p_v_module => 'create_loan_chg_rec',
                     p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                     );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'N'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_loan_per_begin_date                             ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => fnd_message.get                                     ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          log_to_fnd(p_v_module => 'create_loan_chg_rec',
                     p_v_string => ' updated the status of change send record to Not Ready to Send'
                     );

        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;

      END IF;
    -- verify if changes have been reverted back
    ELSIF (l_d_res_loan_per_begin_dt = l_d_loan_per_begin_date)
    THEN
        log_to_fnd(p_v_module => 'create_loan_chg_rec',
                   p_v_string => ' Verifying if  change record is to be deleted or not '      ||
                                 ' cl version                 : ' ||l_n_cl_version            ||
                                 ' loan status                : ' ||l_v_loan_status           ||
                                 ' Processing Type            : ' ||l_v_prc_type_code         ||
                                 ' Loan Record Status         : ' ||l_c_cl_rec_status         ||
                                 ' response loan per begin dt : ' ||l_d_res_loan_per_begin_dt ||
                                 ' new loan per begin dt      : ' ||l_d_loan_per_begin_date   ||
                                 ' change_field_code          : ' ||'LOAN_PER_BEGIN_DT'
                  );
        -- verify if the existing change record is to be deleted
      l_v_sqlstmt := 'SELECT chdt.ROWID row_id '                             ||
                     'FROM   igf_sl_clchsn_dtls chdt '                       ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '      ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '       ||
                     'AND    chdt.old_date = :cp_d_new_begin_dt '            ||
                     'AND    chdt.change_field_code = ''LOAN_PER_BEGIN_DT'' '||
                     'AND    chdt.change_code_txt = ''A'' '                  ||
                     'AND    chdt.change_record_type_txt = ''07'' ';

      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_d_loan_per_begin_date;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%FOUND THEN
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' Change record to be deleted '     ||
                                 ' Award Id    : '    ||l_n_award_id ||
                                 ' loan number : '    ||l_v_loan_number
                  );
        igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' Change record deleted successfully' ||
                                 ' Award Id    : '    ||l_n_award_id   ||
                                 ' loan number : '    ||l_v_loan_number
                  );
      END IF;
      CLOSE c_igf_sl_clchsn_dtls;
      p_b_return_status := TRUE;
      p_v_message_name  := NULL;
    END IF;
    -- end of code logic for loan per begin date changes
    -- start of code logic for loan per end date changes
    -- verify if latest Guaranteed Response has a different value for End Date
    IF (l_d_res_loan_per_end_dt <> l_d_loan_per_end_date)
    THEN
      log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                 p_v_string => ' Verifying if existing change record is to be updated or inserted ' ||
                               ' cl version               : ' ||l_n_cl_version                      ||
                               ' loan status              : ' ||l_v_loan_status                     ||
                               ' Processing Type          : ' ||l_v_prc_type_code                   ||
                               ' Loan Record Status       : ' ||l_c_cl_rec_status                   ||
                               ' response loan per end dt : ' ||l_d_res_loan_per_end_dt             ||
                               ' new loan per end dt      : ' ||l_d_loan_per_end_date               ||
                               ' change_field_code        : ' ||'LOAN_PER_END_DT'
                  );
        -- verify if the existing change record is to be updated or inserted
      l_v_sqlstmt := 'SELECT chdt.ROWID row_id '                           ||
                     'FROM   igf_sl_clchsn_dtls chdt '                     ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '    ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                     'AND    chdt.old_date = :cp_d_resp_end_dt '           ||
                     'AND    chdt.change_field_code = ''LOAN_PER_END_DT'' '||
                     'AND    chdt.change_code_txt = ''A'' '                ||
                     'AND    chdt.change_record_type_txt = ''07'' ';
      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_d_res_loan_per_end_dt;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
        CLOSE c_igf_sl_clchsn_dtls;
        l_v_rowid       := NULL;
        l_n_clchgsnd_id := NULL;
        log_to_fnd(p_v_module => 'create_loan_chg_rec  ',
                   p_v_string => ' New Change record is Created'                                                             ||
                                 ' Change_field_code : ' ||'LOAN_PER_END_DT'                                                 ||
                                 ' Change record type: ' ||'07 - Loan Period/Grade Level/Anticipated Completion Date Change' ||
                                 ' Change code       : ' ||'A - Loan Period Change '
                  );
        igf_sl_clchsn_dtls_pkg.insert_row
        (
          x_rowid                      => l_v_rowid                    ,
          x_clchgsnd_id                => l_n_clchgsnd_id              ,
          x_award_id                   => p_new_loan_rec.award_id      ,
          x_loan_number_txt            => p_new_loan_rec.loan_number   ,
          x_cl_version_code            => l_n_cl_version               ,
          x_change_field_code          => 'LOAN_PER_END_DT'            ,
          x_change_record_type_txt     => '07'                         ,
          x_change_code_txt            => 'A'                          ,
          x_status_code                => 'R'                          ,
          x_status_date                => TRUNC(SYSDATE)               ,
          x_response_status_code       => NULL                         ,
          x_old_value_txt              => NULL                         ,
          x_new_value_txt              => NULL                         ,
          x_old_date                   => l_d_res_loan_per_end_dt      ,
          x_new_date                   => l_d_loan_per_end_date        ,
          x_old_amt                    => NULL                         ,
          x_new_amt                    => NULL                         ,
          x_disbursement_number        => NULL                         ,
          x_disbursement_date          => NULL                         ,
          x_change_issue_code          => NULL                         ,
          x_disbursement_cancel_date   => NULL                         ,
          x_disbursement_cancel_amt    => NULL                         ,
          x_disbursement_revised_amt   => NULL                         ,
          x_disbursement_revised_date  => NULL                         ,
          x_disbursement_reissue_code  => NULL                         ,
          x_disbursement_reinst_code   => NULL                         ,
          x_disbursement_return_amt    => NULL                         ,
          x_disbursement_return_date   => NULL                         ,
          x_disbursement_return_code   => NULL                         ,
          x_post_with_disb_return_amt  => NULL                         ,
          x_post_with_disb_return_date => NULL                         ,
          x_post_with_disb_return_code => NULL                         ,
          x_prev_with_disb_return_amt  => NULL                         ,
          x_prev_with_disb_return_date => NULL                         ,
          x_school_use_txt             => NULL                         ,
          x_lender_use_txt             => NULL                         ,
          x_guarantor_use_txt          => NULL                         ,
          x_validation_edit_txt        => NULL                         ,
          x_send_record_txt            => NULL
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                        );

        IF NOT(l_b_return_status) THEN
          log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                    );
          RAISE e_valid_edits;
        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                  );
      ELSE
        CLOSE c_igf_sl_clchsn_dtls;
        rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
        log_to_fnd(p_v_module => 'create_loan_chg_rec  ',
                   p_v_string => ' Change record is updated '                                                                 ||
                                 ' Change_field_code  : ' ||'LOAN_PER_END_DT'                                                 ||
                                 ' Change record type : ' ||'07 - Loan Period/Grade Level/Anticipated Completion Date Change' ||
                                 ' Change code        : ' ||'A - Loan Period Change '
                  );
        igf_sl_clchsn_dtls_pkg.update_row
        (
          x_rowid                      => l_v_rowid                                           ,
          x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
          x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
          x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
          x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
          x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
          x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
          x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
          x_status_code                => 'R'                                                 ,
          x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
          x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
          x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
          x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
          x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
          x_new_date                   => l_d_loan_per_end_date                               ,
          x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
          x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
          x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
          x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
          x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
          x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
          x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
          x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
          x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
          x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
          x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
          x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
          x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
          x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
          x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
          x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
          x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
          x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
          x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
          x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
          x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
          x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
          x_validation_edit_txt        => NULL                                                ,
          x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                        );

        IF NOT(l_b_return_status) THEN
          log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                    );
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
          igf_sl_cl_chg_prc.parse_tokens(
            p_t_message_tokens => l_d_message_tokens);
/*
          FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
             fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
          END LOOP;
*/
          log_to_fnd(p_v_module => 'create_loan_chg_rec',
                     p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                     );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'N'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_loan_per_end_date                               ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => fnd_message.get                                     ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          log_to_fnd(p_v_module => 'create_loan_chg_rec',
                     p_v_string => ' updated the status of change send record to Not Ready to Send'
                     );
        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
    ELSIF (l_d_res_loan_per_end_dt = l_d_loan_per_end_date) THEN
      log_to_fnd(p_v_module => 'create_loan_chg_rec',
                 p_v_string => ' Verifying if  change record is to be deleted or not '    ||
                               ' cl version               : ' ||l_n_cl_version            ||
                               ' loan status              : ' ||l_v_loan_status           ||
                               ' Processing Type          : ' ||l_v_prc_type_code         ||
                               ' Loan Record Status       : ' ||l_c_cl_rec_status         ||
                               ' response loan per end dt : ' ||l_d_res_loan_per_end_dt   ||
                               ' new loan per end dt      : ' ||l_d_loan_per_end_date     ||
                               ' change_field_code        : ' ||'LOAN_PER_END_DT'
                  );
      l_v_sqlstmt := 'SELECT  chdt.ROWID '                                 ||
                     'FROM   igf_sl_clchsn_dtls chdt '                     ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '    ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                     'AND    chdt.old_date = :cp_d_new_end_dt '            ||
                     'AND    chdt.change_field_code = ''LOAN_PER_END_DT'' '||
                     'AND    chdt.change_code_txt = ''A'' '                ||
                     'AND    chdt.change_record_type_txt = ''07'' ';
      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_d_loan_per_end_date;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%FOUND THEN
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' Change record to be deleted '    ||
                                 ' Award Id    : ' ||l_n_award_id   ||
                                 ' loan number : ' ||l_v_loan_number
                  );
        igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
        log_to_fnd(p_v_module => 'create_loan_chg_rec ',
                   p_v_string => ' Change record deleted successfully '  ||
                                 ' Award Id    : ' ||l_n_award_id        ||
                                 ' loan number : ' ||l_v_loan_number
                  );
      END IF;
      CLOSE c_igf_sl_clchsn_dtls;
      p_b_return_status := TRUE;
      p_v_message_name  := NULL;
    END IF;
  END IF;--end of if condition for checking if change record should be created or not

EXCEPTION
  WHEN e_resource_busy THEN
    ROLLBACK TO igf_sl_cl_create_chg_sp;
    log_to_fnd(p_v_module => 'create_loan_chg_rec',
               p_v_string => ' e resource busy exception ' || SQLERRM
               );
    p_b_return_status := FALSE;
    p_v_message_name  := 'IGS_GE_RECORD_LOCKED';
    RETURN;
  WHEN e_valid_edits THEN
    ROLLBACK TO igf_sl_cl_create_chg_sp;
    log_to_fnd(p_v_module => 'create_loan_chg_rec',
               p_v_string => ' e_valid_edits exception handler. change record validation raised errors '||l_v_message_name
              );
    p_b_return_status := FALSE;
    p_v_message_name  := l_v_message_name;
    igf_sl_cl_chg_prc.g_message_tokens := l_d_message_tokens;
    RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO igf_sl_cl_create_chg_sp;
    log_to_fnd(p_v_module => 'create_loan_chg_rec',
               p_v_string => ' when others exception handler' ||SQLERRM
              );
    fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_cl_create_chg.create_loan_chg_rec');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END create_loan_chg_rec;


PROCEDURE create_lor_chg_rec ( p_new_lor_rec IN igf_sl_lor_all%ROWTYPE,
                               p_b_return_status OUT NOCOPY BOOLEAN,
                               p_v_message_name  OUT NOCOPY VARCHAR2
                             ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 10 October 2004
--
-- Purpose:
-- Invoked     : From lor table handler after update row of lor table
-- Function    :
--
-- Parameters  : p_new_lor_rec     : IN parameter. Required.
--               p_b_return_status : OUT parmeter.
--               p_v_message_name  : OUT parameter
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------

CURSOR  c_igf_sl_loans (cp_n_loan_id igf_sl_loans_all.loan_id%TYPE) IS
SELECT  lar.loan_number
       ,lar.loan_status
       ,lar.award_id
FROM    igf_sl_loans_all lar
WHERE   loan_id = cp_n_loan_id;

rec_c_igf_sl_loans c_igf_sl_loans%ROWTYPE;

CURSOR c_igf_sl_cl_resp_r1(cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
SELECT  resp.anticip_compl_date
       ,resp.grade_level_code
FROM    igf_sl_cl_resp_r1_all resp
WHERE   resp.loan_number = cp_v_loan_number
AND     resp.cl_rec_status IN ('B','G')
AND     resp.prc_type_code IN ('GO','GP')
AND     resp.cl_version_code = 'RELEASE-4'
ORDER BY clrp1_id DESC;

TYPE ref_CurclchsnTyp IS REF CURSOR;
c_igf_sl_clchsn_dtls ref_CurclchsnTyp;

rec_c_igf_sl_clchsn_dtls igf_sl_clchsn_dtls%ROWTYPE;

l_d_resp_anticip_compl_dt    igf_sl_cl_resp_r1_all.anticip_compl_date%TYPE;
l_d_lor_anticip_compl_dt     igf_sl_lor_all.anticip_compl_date%TYPE;
l_v_resp_grade_level_cd      igf_sl_lor_all.override_grade_level_code%TYPE;
l_v_ovr_grade_level_cd       igf_sl_lor_all.override_grade_level_code%TYPE;
l_n_cl_version               igf_sl_cl_setup_all.cl_version%TYPE;
l_v_loan_status              igf_sl_loans_all.loan_status%TYPE;
l_n_clchgsnd_id              igf_sl_clchsn_dtls.clchgsnd_id%TYPE;
l_v_sqlstmt                  VARCHAR2(32767);
l_v_rowid                    ROWID;
l_v_message_name             fnd_new_messages.message_name%TYPE;
l_b_return_status            BOOLEAN;
l_c_cl_rec_status            igf_sl_lor_all.cl_rec_status%TYPE;
l_v_prc_type_code            igf_sl_lor_all.prc_type_code%TYPE;
l_n_award_id                 igf_aw_award_all.award_id%TYPE;
l_v_loan_number              igf_sl_loans_all.loan_number%TYPE;

e_valid_edits     EXCEPTION;
e_resource_busy   EXCEPTION;
l_d_message_tokens        igf_sl_cl_chg_prc.token_tab%TYPE;
PRAGMA EXCEPTION_INIT(e_resource_busy,-00054);

BEGIN
  SAVEPOINT igf_sl_cl_create_chg_lor_sp;

  log_to_fnd(p_v_module => 'create_lor_chg_rec',
             p_v_string => ' Entered Procedure create_lor_chg_rec: The input parameters are '                  ||
                           ' new reference of origination id     : ' ||p_new_lor_rec.origination_id            ||
                           ' new reference of Loan Id            : ' ||p_new_lor_rec.loan_id                   ||
                           ' new reference of anticip compl date : ' ||p_new_lor_rec.anticip_compl_date        ||
                           ' new reference of ovr grade level    : ' ||p_new_lor_rec.override_grade_level_code ||
                           ' new reference of Processing Type    : ' ||p_new_lor_rec.prc_type_code             ||
                           ' new reference of Loan Record Status : ' ||p_new_lor_rec.cl_rec_status
            );
  -- get the loan number , loan status and award id from sl loan table for the input loan id

  OPEN  c_igf_sl_loans(cp_n_loan_id => p_new_lor_rec.loan_id);
  FETCH c_igf_sl_loans INTO rec_c_igf_sl_loans;
  CLOSE c_igf_sl_loans;

  -- get the loan version for the input award id
  l_n_award_id             := rec_c_igf_sl_loans.award_id;
  l_v_loan_number          := rec_c_igf_sl_loans.loan_number;
  l_v_loan_status          := rec_c_igf_sl_loans.loan_status;
  l_n_cl_version           := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);
  l_v_prc_type_code        := p_new_lor_rec.prc_type_code;
  l_c_cl_rec_status        := p_new_lor_rec.cl_rec_status;
  l_d_lor_anticip_compl_dt := p_new_lor_rec.anticip_compl_date;
  --bvisvana #bug 5091388   if override grade level is null then take grade level ride
  l_v_ovr_grade_level_cd   := NVL(p_new_lor_rec.override_grade_level_code,p_new_lor_rec.grade_level_code);

  -- get the latest Guaranteed Response for anticipated completion date for the input loan number
  -- if no records are found change record would not be created. The control is returned back
  -- to the calling program.

  OPEN  c_igf_sl_cl_resp_r1 (cp_v_loan_number => l_v_loan_number);
  FETCH c_igf_sl_cl_resp_r1 INTO l_d_resp_anticip_compl_dt,l_v_resp_grade_level_cd;
  IF c_igf_sl_cl_resp_r1%NOTFOUND THEN
    CLOSE c_igf_sl_cl_resp_r1 ;
    log_to_fnd(p_v_module => 'create_lor_chg_rec',
               p_v_string => ' No Response record found for loan number: ' ||l_v_loan_number
              );
    p_b_return_status := FALSE;
    p_v_message_name  := NULL;
    RETURN;
  END IF;
  CLOSE c_igf_sl_cl_resp_r1 ;
  log_to_fnd(p_v_module => 'create_lor_chg_rec',
             p_v_string => ' Response record found for loan number: ' ||l_v_loan_number           ||
                           ' response anticip compl date          : ' ||l_d_resp_anticip_compl_dt ||
                           ' response grade level                 : ' ||l_v_resp_grade_level_cd
            );
  -- Check if the change record should be created or not
  -- Change Record would be created only if
  -- The version = CommonLine Release 4 Version Loan,
  -- Loan Status = Accepted
  -- Loan Record Status is Guaranteed or Accepted
  -- Processing Type Code is GP or GO
  -- The information is different from the latest Guaranteed Response Received for the Loan
  log_to_fnd(p_v_module => 'create_lor_chg_rec ',
             p_v_string => ' cl version                  : ' ||l_n_cl_version                   ||
                           ' loan status                 : ' ||l_v_loan_status                  ||
                           ' Processing Type             : ' ||l_v_prc_type_code                ||
                           ' Loan Record Status          : ' ||l_c_cl_rec_status
           );
  IF (l_n_cl_version = 'RELEASE-4' AND
      l_v_loan_status = 'A' AND
      l_v_prc_type_code IN ('GO','GP') AND
      l_c_cl_rec_status IN ('B','G'))
  THEN
        log_to_fnd(p_v_module => ' create_lor_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted ' ||
                                 ' cl version                  : ' ||l_n_cl_version                   ||
                                 ' loan status                 : ' ||l_v_loan_status                  ||
                                 ' Processing Type             : ' ||l_v_prc_type_code                ||
                                 ' Loan Record Status          : ' ||l_c_cl_rec_status                ||
                                 ' response anticip compl date : ' ||l_d_resp_anticip_compl_dt        ||
                                 ' new anticip compl date      : ' ||l_d_lor_anticip_compl_dt         ||
                                 ' change_field_code           : ' ||'ANTICIP_COML_DT'
                 );
     -- verify if latest Guaranteed Response has a different value for anticipated completion date
     --  start of code logic for anticip compl dt changes
    IF (l_d_resp_anticip_compl_dt <> l_d_lor_anticip_compl_dt)
    THEN

      l_v_sqlstmt := 'SELECT chdt.ROWID row_id '                             ||
                     'FROM   igf_sl_clchsn_dtls chdt '                       ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '      ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '       ||
                     'AND    chdt.old_date = :cp_d_resp_anticip_dt '         ||
                     'AND    chdt.change_field_code = ''ANTICIP_COML_DT'' '  ||
                     'AND    chdt.change_code_txt = ''C'' '                  ||
                     'AND    chdt.change_record_type_txt = ''07'' ';
      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_d_resp_anticip_compl_dt;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
        CLOSE c_igf_sl_clchsn_dtls;
        l_v_rowid       := NULL;
        l_n_clchgsnd_id := NULL;
        log_to_fnd(p_v_module => 'create_lor_chg_rec  ',
                   p_v_string => ' New Change record is Created '                                                             ||
                                 ' Change_field_code  : ' ||'ANTICIP_COML_DT'                                                 ||
                                 ' Change record type : ' ||'07 - Loan Period/Grade Level/Anticipated Completion Date Change' ||
                                 ' Change code        : ' ||'C - Anticipated Completion Date Change '
                  );
        igf_sl_clchsn_dtls_pkg.insert_row
        (
          x_rowid                      => l_v_rowid                    ,
          x_clchgsnd_id                => l_n_clchgsnd_id              ,
          x_award_id                   => l_n_award_id                 ,
          x_loan_number_txt            => l_v_loan_number              ,
          x_cl_version_code            => l_n_cl_version               ,
          x_change_field_code          => 'ANTICIP_COML_DT'            ,
          x_change_record_type_txt     => '07'                         ,
          x_change_code_txt            => 'C'                          ,
          x_status_code                => 'R'                          ,
          x_status_date                => TRUNC(SYSDATE)               ,
          x_response_status_code       => NULL                         ,
          x_old_value_txt              => NULL                         ,
          x_new_value_txt              => NULL                         ,
          x_old_date                   => l_d_resp_anticip_compl_dt    ,
          x_new_date                   => l_d_lor_anticip_compl_dt     ,
          x_old_amt                    => NULL                         ,
          x_new_amt                    => NULL                         ,
          x_disbursement_number        => NULL                         ,
          x_disbursement_date          => NULL                         ,
          x_change_issue_code          => NULL                         ,
          x_disbursement_cancel_date   => NULL                         ,
          x_disbursement_cancel_amt    => NULL                         ,
          x_disbursement_revised_amt   => NULL                         ,
          x_disbursement_revised_date  => NULL                         ,
          x_disbursement_reissue_code  => NULL                         ,
          x_disbursement_reinst_code   => NULL                         ,
          x_disbursement_return_amt    => NULL                         ,
          x_disbursement_return_date   => NULL                         ,
          x_disbursement_return_code   => NULL                         ,
          x_post_with_disb_return_amt  => NULL                         ,
          x_post_with_disb_return_date => NULL                         ,
          x_post_with_disb_return_code => NULL                         ,
          x_prev_with_disb_return_amt  => NULL                         ,
          x_prev_with_disb_return_date => NULL                         ,
          x_school_use_txt             => NULL                         ,
          x_lender_use_txt             => NULL                         ,
          x_guarantor_use_txt          => NULL                         ,
          x_validation_edit_txt        => NULL                         ,
          x_send_record_txt            => NULL
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                        );

        IF NOT(l_b_return_status) THEN
          log_to_fnd(p_v_module => ' create_lor_chg_rec ',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                    );
          RAISE e_valid_edits;
        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      ELSE
        CLOSE c_igf_sl_clchsn_dtls;
        rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
        igf_sl_clchsn_dtls_pkg.update_row
        (
          x_rowid                      => l_v_rowid                                           ,
          x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
          x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
          x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
          x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
          x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
          x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
          x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
          x_status_code                => 'R'                                                 ,
          x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
          x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
          x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
          x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
          x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
          x_new_date                   => l_d_lor_anticip_compl_dt                            ,
          x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
          x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
          x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
          x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
          x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
          x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
          x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
          x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
          x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
          x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
          x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
          x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
          x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
          x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
          x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
          x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
          x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
          x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
          x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
          x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
          x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
          x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
          x_validation_edit_txt        => NULL                                                ,
          x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                        );

        IF NOT(l_b_return_status) THEN
          log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                    );
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
          igf_sl_cl_chg_prc.parse_tokens(
            p_t_message_tokens => l_d_message_tokens);
/*
          FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
             fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
          END LOOP;
*/
          log_to_fnd(p_v_module => 'create_lor_chg_rec',
                     p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                     );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'N'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_lor_anticip_compl_dt                            ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => fnd_message.get                                     ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          log_to_fnd(p_v_module => 'create_lor_chg_rec',
                     p_v_string => ' updated the status of change send record to Not Ready to Send'
                     );
        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                  );
      END IF;
    -- Verify if the existing change record values have been reverted back
    ELSIF (l_d_resp_anticip_compl_dt = l_d_lor_anticip_compl_dt) THEN
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not '       ||
                                 ' cl version                  : ' ||l_n_cl_version            ||
                                 ' loan status                 : ' ||l_v_loan_status           ||
                                 ' Processing Type             : ' ||l_v_prc_type_code         ||
                                 ' Loan Record Status          : ' ||l_c_cl_rec_status         ||
                                 ' response anticip compl date : ' ||l_d_resp_anticip_compl_dt ||
                                 ' new anticip compl date      : ' ||l_d_lor_anticip_compl_dt  ||
                                 ' change_field_code           : ' ||'ANTICIP_COML_DT'
                 );
      l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                            ||
                     'FROM   igf_sl_clchsn_dtls chdt '                       ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '      ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '       ||
                     'AND    chdt.old_date = :cp_d_new_anticip_dt '          ||
                     'AND    chdt.change_field_code = ''ANTICIP_COML_DT'' '  ||
                     'AND    chdt.change_code_txt = ''C'' '                  ||
                     'AND    chdt.change_record_type_txt = ''07'' ';
      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_d_lor_anticip_compl_dt;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%FOUND THEN
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' Change record to be deleted '    ||
                                 ' Award Id    : ' || l_n_award_id  ||
                                 ' loan number : ' || l_v_loan_number
                  );
        igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' Change record deleted successfully ' ||
                                 ' Award Id    : ' || l_n_award_id      ||
                                 ' loan number : ' || l_v_loan_number
                  );
      END IF;
      CLOSE c_igf_sl_clchsn_dtls;
      p_b_return_status := TRUE;
      p_v_message_name  := NULL;
    END IF;
   --  end of code logic for anticip compl dt changes
   --  start of code logic for grade level changes
   -- Verify if grade level is different from the one in response record
   IF (l_v_resp_grade_level_cd <> l_v_ovr_grade_level_cd)
   THEN
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted ' ||
                                 ' cl version               : ' ||l_n_cl_version            ||
                                 ' loan status              : ' ||l_v_loan_status           ||
                                 ' Processing Type          : ' ||l_v_prc_type_code         ||
                                 ' Loan Record Status       : ' ||l_c_cl_rec_status         ||
                                 ' response grade level cd  : ' ||l_v_resp_grade_level_cd   ||
                                 ' new grade level cd       : ' ||l_v_ovr_grade_level_cd    ||
                                 ' change_field_code        : ' ||'GRADE_LEVEL_CODE'
                  );
      -- verify if the existing change record is to be updated or inserted
      l_v_sqlstmt := 'SELECT chdt.ROWID row_id '                             ||
                     'FROM   igf_sl_clchsn_dtls chdt '                       ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '      ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '       ||
                     'AND    chdt.old_value_txt = :cp_v_resp_grade_lvl_cd '  ||
                     'AND    chdt.change_field_code = ''GRADE_LEVEL_CODE'' ' ||
                     'AND    chdt.change_code_txt          = ''B'' '         ||
                     'AND    chdt.change_record_type_txt   = ''07'' ';

      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_v_resp_grade_level_cd;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
        CLOSE c_igf_sl_clchsn_dtls;
        l_v_rowid       := NULL;
        l_n_clchgsnd_id := NULL;
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' New Change record is Created '                                                             ||
                                 ' Change_field_code  : ' ||'GRADE_LEVEL_CODE'                                                ||
                                 ' Change record type : ' ||'07 - Loan Period/Grade Level/Anticipated Completion Date Change' ||
                                 ' Change code        : ' ||'B - Grade Level Change '
                  );
        igf_sl_clchsn_dtls_pkg.insert_row
        (
          x_rowid                      => l_v_rowid                  ,
          x_clchgsnd_id                => l_n_clchgsnd_id            ,
          x_award_id                   => l_n_award_id               ,
          x_loan_number_txt            => l_v_loan_number            ,
          x_cl_version_code            => l_n_cl_version             ,
          x_change_field_code          => 'GRADE_LEVEL_CODE'         ,
          x_change_record_type_txt     => '07'                       ,
          x_change_code_txt            => 'B'                        ,
          x_status_code                => 'R'                        ,
          x_status_date                => TRUNC(SYSDATE)             ,
          x_response_status_code       => NULL                       ,
          x_old_value_txt              => l_v_resp_grade_level_cd    ,
          x_new_value_txt              => l_v_ovr_grade_level_cd     ,
          x_old_date                   => NULL                       ,
          x_new_date                   => NULL                       ,
          x_old_amt                    => NULL                       ,
          x_new_amt                    => NULL                       ,
          x_disbursement_number        => NULL                       ,
          x_disbursement_date          => NULL                       ,
          x_change_issue_code          => NULL                       ,
          x_disbursement_cancel_date   => NULL                       ,
          x_disbursement_cancel_amt    => NULL                       ,
          x_disbursement_revised_amt   => NULL                       ,
          x_disbursement_revised_date  => NULL                       ,
          x_disbursement_reissue_code  => NULL                       ,
          x_disbursement_reinst_code   => NULL                       ,
          x_disbursement_return_amt    => NULL                       ,
          x_disbursement_return_date   => NULL                       ,
          x_disbursement_return_code   => NULL                       ,
          x_post_with_disb_return_amt  => NULL                       ,
          x_post_with_disb_return_date => NULL                       ,
          x_post_with_disb_return_code => NULL                       ,
          x_prev_with_disb_return_amt  => NULL                       ,
          x_prev_with_disb_return_date => NULL                       ,
          x_school_use_txt             => NULL                       ,
          x_lender_use_txt             => NULL                       ,
          x_guarantor_use_txt          => NULL                       ,
          x_validation_edit_txt        => NULL                       ,
          x_send_record_txt            => NULL
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                        );

        IF NOT(l_b_return_status) THEN
          log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                     p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                    );
          RAISE e_valid_edits;
        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                  );
      ELSE
        CLOSE c_igf_sl_clchsn_dtls;
        rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
        log_to_fnd(p_v_module => 'create_lor_chg_rec  ',
                   p_v_string => ' Change record is updated '                                                                ||
                                 ' Change_field_code  : ' ||'GRADE_LEVEL_CODE'                                               ||
                                 ' Change record type : ' ||'07 - Loan Period/Grade Level/Anticipated Completion Date Change'||
                                 ' Change code        : ' ||'B - Grade Level Change '
                  );
        igf_sl_clchsn_dtls_pkg.update_row
        (
          x_rowid                      => l_v_rowid                                           ,
          x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
          x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
          x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
          x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
          x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
          x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
          x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
          x_status_code                => 'R'                                                 ,
          x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
          x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
          x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
          x_new_value_txt              => l_v_ovr_grade_level_cd                              ,
          x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
          x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
          x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
          x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
          x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
          x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
          x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
          x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
          x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
          x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
          x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
          x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
          x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
          x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
          x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
          x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
          x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
          x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
          x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
          x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
          x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
          x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
          x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
          x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
          x_validation_edit_txt        => NULL                                                ,
          x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
        );
        -- invoke validation edits to validate the change record. The validation checks if
        -- all the required fields are populated or not for a change record
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                  );
        igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                        p_b_return_status => l_b_return_status,
                                        p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                        );

        IF NOT(l_b_return_status) THEN
           log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                      p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                     );
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
          igf_sl_cl_chg_prc.parse_tokens(
            p_t_message_tokens => l_d_message_tokens);
/*
          FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
             fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
          END LOOP;
*/
          log_to_fnd(p_v_module => 'create_lor_chg_rec',
                     p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                     );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'N'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => l_v_ovr_grade_level_cd                              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => fnd_message.get                                     ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          log_to_fnd(p_v_module => 'create_lor_chg_rec',
                     p_v_string => ' updated the status of change send record to Not Ready to Send'
                     );
        END IF;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;

   ELSIF (l_v_resp_grade_level_cd = l_v_ovr_grade_level_cd)
   THEN
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not '   ||
                                 ' cl version              : ' ||l_n_cl_version            ||
                                 ' loan status             : ' ||l_v_loan_status           ||
                                 ' Processing Type         : ' ||l_v_prc_type_code         ||
                                 ' Loan Record Status      : ' ||l_c_cl_rec_status         ||
                                 ' response grade level cd : ' ||l_v_resp_grade_level_cd   ||
                                 ' new grade level cd      : ' ||l_v_ovr_grade_level_cd    ||
                                 ' change_field_code       : ' ||'GRADE_LEVEL_CODE'
                  );
      l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                            ||
                     'FROM   igf_sl_clchsn_dtls chdt '                       ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '      ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '       ||
                     'AND    chdt.old_value_txt = :cp_v_new_grade_lvl_cd '   ||
                     'AND    chdt.change_field_code = ''GRADE_LEVEL_CODE'' ' ||
                     'AND    chdt.change_code_txt        = ''B'' '           ||
                     'AND    chdt.change_record_type_txt = ''07'' ';

      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_v_ovr_grade_level_cd;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%FOUND THEN
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' Change record to be deleted'     ||
                                 ' Award Id    : ' ||l_n_award_id   ||
                                 ' loan number : ' ||l_v_loan_number
                  );
        igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
        log_to_fnd(p_v_module => 'create_lor_chg_rec ',
                   p_v_string => ' Change record deleted successfully' ||
                                 ' Award Id    : ' ||l_n_award_id      ||
                                 ' loan number : ' ||l_v_loan_number
                  );
      END IF;
      CLOSE c_igf_sl_clchsn_dtls;
      p_b_return_status := TRUE;
      p_v_message_name  := NULL;
   END IF;
   --  end of code logic for grade level changes
  END IF; --end of if condition for checking if change record should be created or not

EXCEPTION
  WHEN e_resource_busy THEN
    ROLLBACK TO igf_sl_cl_create_chg_lor_sp;
    log_to_fnd(p_v_module => 'create_lor_chg_rec',
               p_v_string => ' e resource busy exception '||SQLERRM
               );
    p_b_return_status := FALSE;
    p_v_message_name  := 'IGS_GE_RECORD_LOCKED';
    RETURN;
  WHEN e_valid_edits THEN
    ROLLBACK TO igf_sl_cl_create_chg_lor_sp;
    log_to_fnd(p_v_module => 'create_lor_chg_rec',
               p_v_string => ' e_valid_edits exception handler. change record validation raised errors '||l_v_message_name
              );
    p_b_return_status := FALSE;
    p_v_message_name  := l_v_message_name;
    igf_sl_cl_chg_prc.g_message_tokens := l_d_message_tokens;
    RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO igf_sl_cl_create_chg_lor_sp;
    log_to_fnd(p_v_module => 'create_lor_chg_rec',
               p_v_string => ' when others exception handler'||SQLERRM
              );
    fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_cl_create_chg.create_lor_chg_rec');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END create_lor_chg_rec;

PROCEDURE create_awd_chg_rec ( p_n_award_id      IN igf_aw_award_all.award_id%TYPE,
                               p_n_old_amount    IN NUMBER,
                               p_n_new_amount    IN NUMBER,
                               p_v_chg_type      IN VARCHAR2,
                               p_b_return_status OUT NOCOPY BOOLEAN,
                               p_v_message_name  OUT NOCOPY VARCHAR2
                               ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 10 October 2004
--
-- Purpose:
-- Invoked     : From awards table handler after update row of awards table
-- Function    :
--
-- Parameters  : p_n_award_id      : IN parameter. Required.
--               p_n_old_amount    : IN parameter. Required.
--               p_n_new_amount    : IN parameter. Required.
--               p_v_chg_type      : IN parameter. Required.
--               p_b_return_status : OUT parmeter.
--               p_v_message_name  : OUT parameter
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------

CURSOR  c_igf_sl_lorlar(cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
SELECT  lar.loan_number
       ,lar.loan_status
       ,lor.prc_type_code
       ,lor.cl_rec_status
FROM    igf_sl_lor_all lor
       ,igf_sl_loans_all lar
WHERE  lor.loan_id  = lar.loan_id
AND    lar.award_id = cp_n_award_id;

rec_c_igf_sl_lorlar c_igf_sl_lorlar%ROWTYPE;

CURSOR  c_igf_aw_awd_disb (cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
SELECT  adisb.disb_num
FROM    igf_aw_awd_disb_all adisb
WHERE   adisb.award_id = cp_n_award_id
AND     NVL(adisb.fund_status,'N') = 'Y';

CURSOR c_igf_sl_cl_resp_r1(cp_v_loan_number igf_sl_loans_all.loan_number%TYPE) IS
SELECT resp.guarantee_amt
FROM   igf_sl_cl_resp_r1_all resp
WHERE  resp.loan_number = cp_v_loan_number
AND    resp.cl_rec_status IN ('B','G')
AND    resp.prc_type_code IN ('GO','GP')
AND    resp.cl_version_code = 'RELEASE-4'
ORDER BY clrp1_id DESC;

TYPE ref_CurclchsnTyp IS REF CURSOR;
c_igf_sl_clchsn_dtls ref_CurclchsnTyp;
c_sl_clchsn_dtls     ref_CurclchsnTyp;

rec_c_igf_sl_clchsn_dtls igf_sl_clchsn_dtls%ROWTYPE;

l_n_cl_version            igf_sl_cl_setup_all.cl_version%TYPE;
l_v_loan_status           igf_sl_loans_all.loan_status%TYPE;
l_n_clchgsnd_id           igf_sl_clchsn_dtls.clchgsnd_id%TYPE;
l_v_sqlstmt               VARCHAR2(32767);
l_v_rowid                 ROWID;
l_v_message_name          fnd_new_messages.message_name%TYPE;
l_b_return_status         BOOLEAN;
l_c_cl_rec_status         igf_sl_lor_all.cl_rec_status%TYPE;
l_v_prc_type_code         igf_sl_lor_all.prc_type_code%TYPE;
l_n_award_id              igf_aw_award_all.award_id%TYPE;
l_v_loan_number           igf_sl_loans_all.loan_number%TYPE;
l_n_disb_num              igf_aw_awd_disb_all.disb_num%TYPE;
l_n_resp_guarantee_amt    igf_sl_cl_resp_r1_all.guarantee_amt%TYPE;
l_v_response_status_code  igf_sl_clchsn_dtls.response_status_code%TYPE;
l_v_status_code           igf_sl_clchsn_dtls.status_code%TYPE;

e_valid_edits     EXCEPTION;
e_resource_busy   EXCEPTION;
l_d_message_tokens        igf_sl_cl_chg_prc.token_tab%TYPE;
PRAGMA EXCEPTION_INIT(e_resource_busy,-00054);

BEGIN

  SAVEPOINT igf_sl_cl_create_chg_awd_sp;

  log_to_fnd(p_v_module => 'create_awd_chg_rec',
             p_v_string => ' Entered Procedure. The input parameters are '        ||
                           ' new reference of Award Id : '   ||p_n_award_id       ||
                           ' old amount                : '   ||p_n_old_amount     ||
                           ' new amount                : '   ||p_n_new_amount     ||
                           ' chg_type                  : '   ||p_v_chg_type
            );

  l_n_award_id := p_n_award_id;

  -- get the processing type code, loan record status, loan status and loan number for the input award id
  OPEN   c_igf_sl_lorlar (cp_n_award_id => l_n_award_id);
  FETCH  c_igf_sl_lorlar INTO rec_c_igf_sl_lorlar;
  CLOSE  c_igf_sl_lorlar;

  l_v_loan_number   := rec_c_igf_sl_lorlar.loan_number;
  l_v_loan_status   := rec_c_igf_sl_lorlar.loan_status;
  l_v_prc_type_code := rec_c_igf_sl_lorlar.prc_type_code;
  l_c_cl_rec_status := rec_c_igf_sl_lorlar.cl_rec_status;

  -- get the loan version for the input award id
  l_n_cl_version  := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);


  -- if any of the disbursements pertaining to the award id is funded, then
  -- loan cancellation record would not be created.
  -- The control is returned back to the calling program.

  IF (p_v_chg_type = 'LC') THEN
      OPEN   c_igf_aw_awd_disb(cp_n_award_id => l_n_award_id);
      FETCH  c_igf_aw_awd_disb INTO l_n_disb_num;
      IF c_igf_aw_awd_disb%FOUND THEN
        log_to_fnd(p_v_module => 'create_awd_chg_rec',
                   p_v_string => ' Loan cancellation/reinstatement record would not be created. ' ||
                                 ' disbursements pertaining to the award id: '      ||l_n_award_id||
                                 ' is funded '
                  );
        CLOSE c_igf_aw_awd_disb ;
        p_b_return_status := FALSE;
        p_v_message_name  := NULL;
        RETURN;
      END IF;
      CLOSE  c_igf_aw_awd_disb;
      log_to_fnd(p_v_module => 'create_awd_chg_rec',
                 p_v_string => ' Loan cancellation/reinstatement record would be created ' ||
                               ' disbursements pertaining to the award id: ' ||l_n_award_id||
                               ' is not funded '
                );
  END IF;

  -- get the latest Guaranteed Response of guarantee amount for the input loan number
  -- if no records are found change record would not be created. The control is returned back
  -- to the calling program.
  OPEN  c_igf_sl_cl_resp_r1 (cp_v_loan_number => l_v_loan_number);
  FETCH c_igf_sl_cl_resp_r1 INTO l_n_resp_guarantee_amt;
  IF c_igf_sl_cl_resp_r1%NOTFOUND THEN
    CLOSE c_igf_sl_cl_resp_r1 ;
    log_to_fnd(p_v_module => ' create_awd_chg_rec',
               p_v_string => ' No Response record found for loan number: ' ||l_v_loan_number
              );
    p_b_return_status := FALSE;
    p_v_message_name  := NULL;
    RETURN;
  END IF;
  CLOSE c_igf_sl_cl_resp_r1 ;

  log_to_fnd(p_v_module => ' create_awd_chg_rec',
             p_v_string => ' Response record found for '  ||
                           ' loan number            : '   ||l_v_loan_number       ||
                           ' Response Guaranteed amt: '   ||l_n_resp_guarantee_amt
            );

  -- Check if the Loan Cancellation record should be created or not
  -- Change Record would be created only if
  -- The version = CommonLine Release 4 Version Loan,
  -- Loan Status = Accepted
  -- Loan Record Status is Guaranteed or Accepted
  -- Processing Type Code is GP or GO
  -- None of the disbursements are issued

  IF (l_n_cl_version = 'RELEASE-4' AND
      l_v_loan_status = 'A' AND
      l_v_prc_type_code IN ('GO','GP') AND
      l_c_cl_rec_status IN ('B','G'))
  THEN
    IF (p_v_chg_type = 'LC') THEN
      IF (l_n_resp_guarantee_amt <> p_n_new_amount AND p_n_new_amount = 0) THEN
        log_to_fnd(p_v_module => ' create_awd_chg_rec',
                   p_v_string => ' Verifying if change record is to be inserted or not '   ||
                                 ' cl version              : ' ||l_n_cl_version            ||
                                 ' loan status             : ' ||l_v_loan_status           ||
                                 ' Processing Type         : ' ||l_v_prc_type_code         ||
                                 ' Loan Record Status      : ' ||l_c_cl_rec_status         ||
                                 ' Response Guaranteed amt : ' ||l_n_resp_guarantee_amt    ||
                                 ' New Guaranteed amt      : ' ||p_n_new_amount            ||
                                 ' change_field_code       : ' ||'AWARD_AMOUNT'            ||
                                 ' chg_type                : ' ||p_v_chg_type              ||
                                 ' Change record type      : ' ||'08 - Loan Cancellation'  ||
                                 ' Change code             : ' ||'A - Full Loan Cancellation '
                  );
        -- verify if the existing change record is to be inserted or not
        l_v_sqlstmt := 'SELECT chdt.ROWID row_id '                             ||
                       'FROM   igf_sl_clchsn_dtls chdt '                       ||
                       'WHERE  chdt.loan_number_txt = :cp_v_loan_number '      ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '       ||
                       'AND    chdt.new_amt  = 0 '                             ||
                       'AND    chdt.old_amt  = :cp_n_old_amt '                 ||
                       'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '     ||
                       'AND    chdt.change_code_txt       = ''A'' '            ||
                       'AND    chdt.change_record_type_txt     = ''08'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          igf_sl_clchsn_dtls_pkg.insert_row
          (
            x_rowid                      => l_v_rowid                ,
            x_clchgsnd_id                => l_n_clchgsnd_id          ,
            x_award_id                   => l_n_award_id             ,
            x_loan_number_txt            => l_v_loan_number          ,
            x_cl_version_code            => l_n_cl_version           ,
            x_change_field_code          => 'AWARD_AMOUNT'           ,
            x_change_record_type_txt     => '08'                     ,
            x_change_code_txt            => 'A'                      ,
            x_status_code                => 'R'                      ,
            x_status_date                => TRUNC(SYSDATE)           ,
            x_response_status_code       => NULL                     ,
            x_old_value_txt              => NULL                     ,
            x_new_value_txt              => NULL                     ,
            x_old_date                   => NULL                     ,
            x_new_date                   => NULL                     ,
            x_old_amt                    => l_n_resp_guarantee_amt   ,
            x_new_amt                    => 0                        ,
            x_disbursement_number        => NULL                     ,
            x_disbursement_date          => NULL                     ,
            x_change_issue_code          => NULL                     ,
            x_disbursement_cancel_date   => NULL                     ,
            x_disbursement_cancel_amt    => NULL                     ,
            x_disbursement_revised_amt   => NULL                     ,
            x_disbursement_revised_date  => NULL                     ,
            x_disbursement_reissue_code  => NULL                     ,
            x_disbursement_reinst_code   => NULL                     ,
            x_disbursement_return_amt    => NULL                     ,
            x_disbursement_return_date   => NULL                     ,
            x_disbursement_return_code   => NULL                     ,
            x_post_with_disb_return_amt  => NULL                     ,
            x_post_with_disb_return_date => NULL                     ,
            x_post_with_disb_return_code => NULL                     ,
            x_prev_with_disb_return_amt  => NULL                     ,
            x_prev_with_disb_return_date => NULL                     ,
            x_school_use_txt             => NULL                     ,
            x_lender_use_txt             => NULL                     ,
            x_guarantor_use_txt          => NULL                     ,
            x_validation_edit_txt        => NULL                     ,
            x_send_record_txt            => NULL
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                    );
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                         );
          IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
            RAISE e_valid_edits;
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
      END IF;
      -- if changes have been reverted back (i.e. reverting back to LC after fully reinstated record
      -- is created before sending to external processor)

      -- verify if fullY reinstated record is to be deleted as award change is reverted back
      l_v_sqlstmt := 'SELECT  chdt.ROWID  '                                             ||
                     'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                     'AND    chdt.old_amt  = 0 '                                        ||
                     'AND    chdt.new_amt  = :cp_n_new_amt '                            ||
                     'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                     'AND    chdt.change_code_txt = ''B'' '                             ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '                  ||
                     'AND    chdt.change_record_type_txt = ''08'' ';
      l_v_rowid  := NULL;
      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%FOUND THEN
        log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                   p_v_string => ' fullY reinstated Change record to be deleted ' ||
                                 ' Award Id             : ' ||l_n_award_id        ||
                                 ' loan number          : ' ||l_v_loan_number
                  );
        igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
        log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                   p_v_string => ' Change record deleted successfully '       ||
                                 ' Award Id             : ' ||l_n_award_id    ||
                                 ' loan number          : ' ||l_v_loan_number
                  );
      END IF;
      CLOSE c_igf_sl_clchsn_dtls;
      p_b_return_status := TRUE;
      p_v_message_name  := NULL;

      -- verify if loan increase record is to be deleted as award change is reverted back
      l_v_sqlstmt := 'SELECT  chdt.ROWID  '                                             ||
                     'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                     'AND    chdt.old_amt  = :cp_n_old_amt '                            ||
                     'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                     'AND    chdt.change_code_txt = ''A'' '                             ||
                     'AND    chdt.status_code IN (''R'',''N'',''D'') '                  ||
                     'AND    chdt.change_record_type_txt = ''24'' ';
      l_v_rowid := NULL;
      OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
      IF c_igf_sl_clchsn_dtls%FOUND THEN
        log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                   p_v_string => ' Loan Increase Change record to be deleted '    ||
                                 ' Award Id             : ' ||l_n_award_id        ||
                                 ' loan number          : ' ||l_v_loan_number
                  );
        igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
        log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                   p_v_string => ' Change record deleted successfully '       ||
                                 ' Award Id             : ' ||l_n_award_id    ||
                                 ' loan number          : ' ||l_v_loan_number
                  );
      END IF;
      CLOSE c_igf_sl_clchsn_dtls;
      p_b_return_status := TRUE;
      p_v_message_name  := NULL;

    ELSIF (p_v_chg_type = 'RIDC') THEN

      log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                 p_v_string => ' Verifying if full loan cancellation record exists with'||
                               ' response status as Acknowledged  '                     ||
                               ' cl version             : ' ||l_n_cl_version            ||
                               ' loan status            : ' ||l_v_loan_status           ||
                               ' Processing Type        : ' ||l_v_prc_type_code         ||
                               ' Loan Record Status     : ' ||l_c_cl_rec_status         ||
                               ' Response Guaranteed amt: ' ||l_n_resp_guarantee_amt    ||
                               ' New Guaranteed amt     : ' ||p_n_new_amount            ||
                               ' change_field_code      : ' ||'AWARD_AMOUNT'            ||
                               ' chg_type               : ' ||p_v_chg_type
                  );
      l_v_sqlstmt := 'SELECT  chdt.ROWID, chdt.response_status_code '                   ||
                     'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                     'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                     'AND    chdt.old_amt  = :cp_n_old_amt '                            ||
                     'AND    chdt.new_amt  = 0 '                                        ||
                     'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                     'AND    chdt.change_code_txt = ''A'' '                             ||
                     'AND    chdt.change_record_type_txt = ''08'' ';
      l_v_rowid  := NULL;
      OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
      FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid, l_v_response_status_code;
      CLOSE c_igf_sl_clchsn_dtls;
      -- if record has been found
      log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                 p_v_string => ' response status code: ' ||l_v_response_status_code
                );
      IF l_v_response_status_code IS NOT NULL THEN
        -- if response status code is Accepted
        -- Loan increase or Reinstatement change record should be created or not
        IF (l_v_response_status_code = 'A') THEN
          -- if the new amount = response guarantee amount i.e. award amount is retained
          -- delete the loan increase record if exists
          -- create Full Loan Reinstatement change record
          -- The reinstated loan amount must not exceed the original guarantee amount.
          IF p_n_new_amount > 0 AND
             p_n_new_amount <= l_n_resp_guarantee_amt THEN
            log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                       p_v_string => ' Verifying if  Loan Increase change record is to be deleted or not '  ||
                                     ' cl version             : ' ||l_n_cl_version            ||
                                     ' loan status            : ' ||l_v_loan_status           ||
                                     ' Processing Type        : ' ||l_v_prc_type_code         ||
                                     ' Loan Record Status     : ' ||l_c_cl_rec_status         ||
                                     ' Response Guaranteed amt: ' ||l_n_resp_guarantee_amt    ||
                                     ' New Guaranteed amt     : ' ||p_n_new_amount            ||
                                     ' change_field_code      : ' ||'AWARD_AMOUNT'            ||
                                     ' chg_type               : ' ||p_v_chg_type              ||
                                     ' Change record type     : ' ||'24 - Loan Increase'      ||
                                     ' change_code            : ' ||'A - Loan Increase'
                       );
            -- verify if loan increase record is to be deleted as award change is reverted back
            l_v_sqlstmt := 'SELECT  chdt.ROWID  '                                             ||
                           'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                           'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                           'AND    chdt.old_amt  = :cp_n_old_amt '                            ||
                           'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                           'AND    chdt.change_code_txt = ''A'' '                             ||
                           'AND    chdt.status_code IN (''R'',''N'',''D'') '                  ||
                           'AND    chdt.change_record_type_txt = ''24'' ';
            l_v_rowid := NULL;
            OPEN  c_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
            FETCH c_sl_clchsn_dtls INTO l_v_rowid;
            IF c_sl_clchsn_dtls%FOUND THEN
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' Loan Increase Change record to be deleted '    ||
                                       ' Award Id             : ' ||l_n_award_id        ||
                                       ' loan number          : ' ||l_v_loan_number
                        );
              igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' Change record deleted successfully '       ||
                                       ' Award Id             : ' ||l_n_award_id    ||
                                       ' loan number          : ' ||l_v_loan_number
                        );
            END IF;
            CLOSE c_sl_clchsn_dtls;
            p_b_return_status := TRUE;
            p_v_message_name  := NULL;

            log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                       p_v_string => ' Verifying if Full Loan Reinstatement change record to be inserted or not'||
                                     ' cl version             : ' ||l_n_cl_version            ||
                                     ' loan status            : ' ||l_v_loan_status           ||
                                     ' Processing Type        : ' ||l_v_prc_type_code         ||
                                     ' Loan Record Status     : ' ||l_c_cl_rec_status         ||
                                     ' Response Guaranteed amt: ' ||l_n_resp_guarantee_amt    ||
                                     ' New Guaranteed amt     : ' ||p_n_new_amount            ||
                                     ' change_field_code      : ' ||'AWARD_AMOUNT'            ||
                                     ' chg_type               : ' ||p_v_chg_type              ||
                                     ' Change record type     : ' ||'08 - Loan Cancellation'  ||
                                     ' change_code            : ' ||'B - Full Loan Reinstatement'
                     );
            -- verify if the reinstatement change record is to be updated or inserted
            l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                                        ||
                           'FROM    igf_sl_clchsn_dtls chdt '                                  ||
                           'WHERE   chdt.loan_number_txt = :cp_v_loan_number '                 ||
                           'AND     chdt.old_amt  = 0 '                                        ||
                           'AND     chdt.change_field_code      = ''AWARD_AMOUNT'' '           ||
                           'AND     chdt.change_code_txt        = ''B'' '                      ||
                           'AND     chdt.status_code IN (''R'',''N'',''D'') '                  ||
                           'AND     chdt.change_record_type_txt = ''08'' ';
            l_v_rowid  := NULL;
            OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number;
            FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
            IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
              CLOSE c_igf_sl_clchsn_dtls;
              l_v_rowid       := NULL;
              l_n_clchgsnd_id := NULL;
              log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                         p_v_string => ' New Full Loan Reinstatement Change record is Created ' ||
                                       ' Change_field_code  : ' ||'AWARD_AMOUNT'                ||
                                       ' Change record type : ' ||'08 - Loan Cancellation'      ||
                                       ' change code        : ' ||'B - Full Loan Reinstatement'
                        );
              igf_sl_clchsn_dtls_pkg.insert_row
              (
                x_rowid                      => l_v_rowid         ,
                x_clchgsnd_id                => l_n_clchgsnd_id   ,
                x_award_id                   => l_n_award_id      ,
                x_loan_number_txt            => l_v_loan_number   ,
                x_cl_version_code            => l_n_cl_version    ,
                x_change_field_code          => 'AWARD_AMOUNT'    ,
                x_change_record_type_txt     => '08'              ,
                x_change_code_txt            => 'B'               ,
                x_status_code                => 'R'               ,
                x_status_date                => TRUNC(SYSDATE)    ,
                x_response_status_code       => NULL              ,
                x_old_value_txt              => NULL              ,
                x_new_value_txt              => NULL              ,
                x_old_date                   => NULL              ,
                x_new_date                   => NULL              ,
                x_old_amt                    => 0                 ,
                x_new_amt                    => p_n_new_amount    ,
                x_disbursement_number        => NULL              ,
                x_disbursement_date          => NULL              ,
                x_change_issue_code          => NULL              ,
                x_disbursement_cancel_date   => NULL              ,
                x_disbursement_cancel_amt    => NULL              ,
                x_disbursement_revised_amt   => NULL              ,
                x_disbursement_revised_date  => NULL              ,
                x_disbursement_reissue_code  => NULL              ,
                x_disbursement_reinst_code   => NULL              ,
                x_disbursement_return_amt    => NULL              ,
                x_disbursement_return_date   => NULL              ,
                x_disbursement_return_code   => NULL              ,
                x_post_with_disb_return_amt  => NULL              ,
                x_post_with_disb_return_date => NULL              ,
                x_post_with_disb_return_code => NULL              ,
                x_prev_with_disb_return_amt  => NULL              ,
                x_prev_with_disb_return_date => NULL              ,
                x_school_use_txt             => NULL              ,
                x_lender_use_txt             => NULL              ,
                x_guarantor_use_txt          => NULL              ,
                x_validation_edit_txt        => NULL              ,
                x_send_record_txt            => NULL
              );
              -- invoke validation edits to validate the change record. The validation checks if
              -- all the required fields are populated or not for a change record
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                        );
              igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                              p_b_return_status => l_b_return_status,
                                              p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                              );

              IF NOT(l_b_return_status) THEN
                log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                           p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                          );
                RAISE e_valid_edits;
              END IF;
              p_b_return_status := TRUE;
              p_v_message_name  := NULL;
            ELSE
              CLOSE c_igf_sl_clchsn_dtls;
              rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
              log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                         p_v_string => ' Change record is updated '                        ||
                                       ' Change_field_code  : ' ||'AWARD_AMOUNT'           ||
                                       ' Change record type : ' ||'08 - Loan Reinstatement'||
                                       ' Change code        : ' ||'B - Loan Reinstatement '
                        );
              igf_sl_clchsn_dtls_pkg.update_row
              (
                x_rowid                      => l_v_rowid                                           ,
                x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                x_status_code                => 'R'                                                 ,
                x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
                x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                x_new_amt                    => p_n_new_amount                                      ,
                x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                x_validation_edit_txt        => NULL                                                ,
                x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
              );
              -- invoke validation edits to validate the change record. The validation checks if
              -- all the required fields are populated or not for a change record
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                        );
              igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                              p_b_return_status => l_b_return_status,
                                              p_v_message_name  => l_v_message_name,
                                              p_t_message_tokens => l_d_message_tokens
                                             );
              IF NOT(l_b_return_status) THEN
                log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                           p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                          );
                -- substring of the out bound parameter l_v_message_name is carried
                -- out since it can expect either IGS OR IGF message
                fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
                igf_sl_cl_chg_prc.parse_tokens(
                  p_t_message_tokens => l_d_message_tokens);
/*
          FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
             fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
          END LOOP;
*/
                log_to_fnd(p_v_module => ' create_awd_chg_rec',
                           p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                           );
                igf_sl_clchsn_dtls_pkg.update_row
                (
                  x_rowid                      => l_v_rowid                                           ,
                  x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                  x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                  x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                  x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                  x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                  x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                  x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                  x_status_code                => 'N'                                                 ,
                  x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                  x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                  x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                  x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                  x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                  x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
                  x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                  x_new_amt                    => p_n_new_amount                                      ,
                  x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                  x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                  x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                  x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                  x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                  x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                  x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                  x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                  x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                  x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                  x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                  x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                  x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                  x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                  x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                  x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                  x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                  x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                  x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                  x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                  x_validation_edit_txt        => fnd_message.get                                     ,
                  x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
                );
                log_to_fnd(p_v_module => ' create_awd_chg_rec',
                           p_v_string => ' updated the status of change send record to Not Ready to Send'
                          );
              END IF;
              p_b_return_status := TRUE;
              p_v_message_name  := NULL;
            END IF;
          END IF;
          -- Loan re-instatement should be done till the Guarantee Amount.
          -- So if P_NEW_AMT > L_RESP_GUARNT_AMT THEN we should re-instate till the full loan cancellation
          -- change record's old amount. For the rest amount (P_NEW_AMT - OLD_AMT from full loan cancellation record)
          -- we should create Loan Increase Record
          IF p_n_new_amount > l_n_resp_guarantee_amt THEN
            -- verify if the reinstatement change record is to be updated or inserted
            l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                                        ||
                           'FROM    igf_sl_clchsn_dtls chdt '                                  ||
                           'WHERE   chdt.loan_number_txt = :cp_v_loan_number '                 ||
                           'AND     chdt.old_amt  = 0 '                                        ||
                           'AND     chdt.change_field_code      = ''AWARD_AMOUNT'' '           ||
                           'AND     chdt.change_code_txt        = ''B'' '                      ||
                           'AND     chdt.status_code IN (''R'',''N'',''D'') '                  ||
                           'AND     chdt.change_record_type_txt = ''08'' ';
            l_v_rowid  := NULL;
            OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number;
            FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
            IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
              CLOSE c_igf_sl_clchsn_dtls;
              l_v_rowid       := NULL;
              l_n_clchgsnd_id := NULL;
              log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                         p_v_string => ' New Full Loan Reinstatement Change record is Created ' ||
                                       ' Change_field_code  : ' ||'AWARD_AMOUNT'                ||
                                       ' Change record type : ' ||'08 - Loan Cancellation'      ||
                                       ' change code        : ' ||'B - Full Loan Reinstatement'
                        );
              igf_sl_clchsn_dtls_pkg.insert_row
              (
                x_rowid                      => l_v_rowid         ,
                x_clchgsnd_id                => l_n_clchgsnd_id   ,
                x_award_id                   => l_n_award_id      ,
                x_loan_number_txt            => l_v_loan_number   ,
                x_cl_version_code            => l_n_cl_version    ,
                x_change_field_code          => 'AWARD_AMOUNT'    ,
                x_change_record_type_txt     => '08'              ,
                x_change_code_txt            => 'B'               ,
                x_status_code                => 'R'               ,
                x_status_date                => TRUNC(SYSDATE)    ,
                x_response_status_code       => NULL              ,
                x_old_value_txt              => NULL              ,
                x_new_value_txt              => NULL              ,
                x_old_date                   => NULL              ,
                x_new_date                   => NULL              ,
                x_old_amt                    => 0                 ,
                x_new_amt                    => l_n_resp_guarantee_amt,
                x_disbursement_number        => NULL              ,
                x_disbursement_date          => NULL              ,
                x_change_issue_code          => NULL              ,
                x_disbursement_cancel_date   => NULL              ,
                x_disbursement_cancel_amt    => NULL              ,
                x_disbursement_revised_amt   => NULL              ,
                x_disbursement_revised_date  => NULL              ,
                x_disbursement_reissue_code  => NULL              ,
                x_disbursement_reinst_code   => NULL              ,
                x_disbursement_return_amt    => NULL              ,
                x_disbursement_return_date   => NULL              ,
                x_disbursement_return_code   => NULL              ,
                x_post_with_disb_return_amt  => NULL              ,
                x_post_with_disb_return_date => NULL              ,
                x_post_with_disb_return_code => NULL              ,
                x_prev_with_disb_return_amt  => NULL              ,
                x_prev_with_disb_return_date => NULL              ,
                x_school_use_txt             => NULL              ,
                x_lender_use_txt             => NULL              ,
                x_guarantor_use_txt          => NULL              ,
                x_validation_edit_txt        => NULL              ,
                x_send_record_txt            => NULL
              );
              -- invoke validation edits to validate the change record. The validation checks if
              -- all the required fields are populated or not for a change record
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                        );
              igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                              p_b_return_status => l_b_return_status,
                                              p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                              );

              IF NOT(l_b_return_status) THEN
                log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                           p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                          );
                RAISE e_valid_edits;
              END IF;
              p_b_return_status := TRUE;
              p_v_message_name  := NULL;
            ELSE
              CLOSE c_igf_sl_clchsn_dtls;
              rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
              log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                         p_v_string => ' Change record is updated '                        ||
                                       ' Change_field_code  : ' ||'AWARD_AMOUNT'           ||
                                       ' Change record type : ' ||'08 - Loan Reinstatement'||
                                       ' Change code        : ' ||'B - Loan Reinstatement '
                        );
              igf_sl_clchsn_dtls_pkg.update_row
              (
                x_rowid                      => l_v_rowid                                           ,
                x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                x_status_code                => 'R'                                                 ,
                x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
                x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                x_new_amt                    => l_n_resp_guarantee_amt                              ,
                x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                x_validation_edit_txt        => NULL                                                ,
                x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
              );
              -- invoke validation edits to validate the change record. The validation checks if
              -- all the required fields are populated or not for a change record
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                        );
              igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                              p_b_return_status => l_b_return_status,
                                              p_v_message_name  => l_v_message_name,
                                              p_t_message_tokens => l_d_message_tokens
                                             );
              IF NOT(l_b_return_status) THEN
                log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                           p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                          );
                -- substring of the out bound parameter l_v_message_name is carried
                -- out since it can expect either IGS OR IGF message
                fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
                igf_sl_cl_chg_prc.parse_tokens(
                  p_t_message_tokens => l_d_message_tokens);
/*
                FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
                   fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
                END LOOP;
*/
                log_to_fnd(p_v_module => ' create_awd_chg_rec',
                           p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                           );
                igf_sl_clchsn_dtls_pkg.update_row
                (
                  x_rowid                      => l_v_rowid                                           ,
                  x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                  x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                  x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                  x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                  x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                  x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                  x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                  x_status_code                => 'N'                                                 ,
                  x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                  x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                  x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                  x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                  x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                  x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
                  x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                  x_new_amt                    => l_n_resp_guarantee_amt                              ,
                  x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                  x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                  x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                  x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                  x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                  x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                  x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                  x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                  x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                  x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                  x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                  x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                  x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                  x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                  x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                  x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                  x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                  x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                  x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                  x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                  x_validation_edit_txt        => fnd_message.get                                     ,
                  x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
                );
                log_to_fnd(p_v_module => ' create_awd_chg_rec',
                           p_v_string => ' updated the status of change send record to Not Ready to Send'
                          );
              END IF;
              p_b_return_status := TRUE;
              p_v_message_name  := NULL;
            END IF;

            -- verify if loan increase record is to be created or updated
            l_v_sqlstmt := 'SELECT  chdt.ROWID  '                                             ||
                           'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                           'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                           'AND    chdt.old_amt  = :cp_n_old_amt '                            ||
                           'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                           'AND    chdt.change_code_txt = ''A'' '                             ||
                           'AND    chdt.status_code IN (''R'',''N'',''D'') '                  ||
                           'AND    chdt.change_record_type_txt = ''24'' ';
            l_v_rowid := NULL;
            OPEN  c_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
            FETCH c_sl_clchsn_dtls INTO l_v_rowid;
            IF c_sl_clchsn_dtls%NOTFOUND THEN
              CLOSE c_sl_clchsn_dtls;
              l_v_rowid       := NULL;
              l_n_clchgsnd_id := NULL;
              log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                         p_v_string => ' New Loan Increase Change record is Created '  ||
                                       ' Change_field_code  : ' ||'AWARD_AMOUNT'       ||
                                       ' Change record type : ' ||'24 - Loan Increase' ||
                                       ' change code        : ' ||'A - Loan Increase '
                        );
              igf_sl_clchsn_dtls_pkg.insert_row
              (
                x_rowid                      => l_v_rowid              ,
                x_clchgsnd_id                => l_n_clchgsnd_id        ,
                x_award_id                   => l_n_award_id           ,
                x_loan_number_txt            => l_v_loan_number        ,
                x_cl_version_code            => l_n_cl_version         ,
                x_change_field_code          => 'AWARD_AMOUNT'         ,
                x_change_record_type_txt     => '24'                   ,
                x_change_code_txt            => 'A'                    ,
                x_status_code                => 'R'                    ,
                x_status_date                => TRUNC(SYSDATE)         ,
                x_response_status_code       => NULL                   ,
                x_old_value_txt              => NULL                   ,
                x_new_value_txt              => NULL                   ,
                x_old_date                   => NULL                   ,
                x_new_date                   => NULL                   ,
                x_old_amt                    => l_n_resp_guarantee_amt ,
                x_new_amt                    => p_n_new_amount         ,
                x_disbursement_number        => NULL                   ,
                x_disbursement_date          => NULL                   ,
                x_change_issue_code          => NULL                   ,
                x_disbursement_cancel_date   => NULL                   ,
                x_disbursement_cancel_amt    => NULL                   ,
                x_disbursement_revised_amt   => NULL                   ,
                x_disbursement_revised_date  => NULL                   ,
                x_disbursement_reissue_code  => NULL                   ,
                x_disbursement_reinst_code   => NULL                   ,
                x_disbursement_return_amt    => NULL                   ,
                x_disbursement_return_date   => NULL                   ,
                x_disbursement_return_code   => NULL                   ,
                x_post_with_disb_return_amt  => NULL                   ,
                x_post_with_disb_return_date => NULL                   ,
                x_post_with_disb_return_code => NULL                   ,
                x_prev_with_disb_return_amt  => NULL                   ,
                x_prev_with_disb_return_date => NULL                   ,
                x_school_use_txt             => NULL                   ,
                x_lender_use_txt             => NULL                   ,
                x_guarantor_use_txt          => NULL                   ,
                x_validation_edit_txt        => NULL                   ,
                x_send_record_txt            => NULL
              );
              -- invoke validation edits to validate the change record. The validation checks if
              -- all the required fields are populated or not for a change record
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                        );
              igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                              p_b_return_status => l_b_return_status,
                                              p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                             );
              IF NOT(l_b_return_status) THEN
                log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                           p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                           );
                RAISE e_valid_edits;
              END IF;
              p_b_return_status := TRUE;
              p_v_message_name  := NULL;
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                         );
            ELSE
              CLOSE c_sl_clchsn_dtls;
              rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
              log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                         p_v_string => ' Change record is updated '                   ||
                                       ' Change_field_code  : ' ||'AWARD_AMOUNT'      ||
                                       ' Change record type : ' ||'24 - Loan Increase'||
                                       ' Change code        : ' ||'A - LOan Increase '
                        );
              igf_sl_clchsn_dtls_pkg.update_row
              (
                x_rowid                      => l_v_rowid                                           ,
                x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                x_status_code                => 'R'                                                 ,
                x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
                x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                x_new_amt                    => p_n_new_amount                                      ,
                x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                x_validation_edit_txt        => NULL                                                ,
                x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
              );
              -- invoke validation edits to validate the change record. The validation checks if
              -- all the required fields are populated or not for a change record
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                        );
              igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                              p_b_return_status => l_b_return_status,
                                              p_v_message_name  => l_v_message_name,
                                              p_t_message_tokens => l_d_message_tokens
                                             );

              IF NOT(l_b_return_status) THEN
                log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                           p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                          );
                -- substring of the out bound parameter l_v_message_name is carried
                -- out since it can expect either IGS OR IGF message
                fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
                igf_sl_cl_chg_prc.parse_tokens(
                  p_t_message_tokens => l_d_message_tokens);
/*
                FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
                   fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
                END LOOP;
*/
                log_to_fnd(p_v_module => ' create_awd_chg_rec',
                           p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                           );
                igf_sl_clchsn_dtls_pkg.update_row
                (
                  x_rowid                      => l_v_rowid                                           ,
                  x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                  x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                  x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                  x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                  x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                  x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                  x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                  x_status_code                => 'N'                                                 ,
                  x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                  x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                  x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                  x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                  x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                  x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
                  x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                  x_new_amt                    => p_n_new_amount                                      ,
                  x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                  x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                  x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                  x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                  x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                  x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                  x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                  x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                  x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                  x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                  x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                  x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                  x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                  x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                  x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                  x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                  x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                  x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                  x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                  x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                  x_validation_edit_txt        => fnd_message.get                                     ,
                  x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
                );
                log_to_fnd(p_v_module => ' create_awd_chg_rec',
                           p_v_string => ' updated the status of change send record to Not Ready to Send'
                          );
              END IF;
              p_b_return_status := TRUE;
              p_v_message_name  := NULL;
            END IF;
          END IF;
        END IF;
      -- no Loan cancellation record exists with response status code = 'A'
      -- hence just create loan increase record
      ELSIF l_v_response_status_code IS NULL THEN
          -- verify if full loan cancellation record to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID  '                                             ||
                       'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                       'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                       'AND    chdt.old_amt  = :cp_n_old_amt '                            ||
                       'AND    chdt.new_amt  = 0 '                                        ||
                       'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                       'AND    chdt.change_code_txt = ''A'' '                             ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '                  ||
                       'AND    chdt.change_record_type_txt = ''08'' ';
        l_v_rowid  := NULL;
        OPEN c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                     p_v_string => ' full loan cancellation Change record to be deleted ' ||
                                   ' Award Id             : ' ||l_n_award_id              ||
                                   ' loan number          : ' ||l_v_loan_number
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                     p_v_string => ' full loan cancellation Change record deleted successfully ' ||
                                   ' Award Id             : ' ||l_n_award_id                     ||
                                   ' loan number          : ' ||l_v_loan_number
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
        IF p_n_new_amount > l_n_resp_guarantee_amt  THEN
          -- verify if Loan Increase change record is to be inserted or not
          log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                     p_v_string => ' Verifying if Loan Increase change record is to be inserted or not'||
                                   ' cl version             : ' ||l_n_cl_version            ||
                                   ' loan status            : ' ||l_v_loan_status           ||
                                   ' Processing Type        : ' ||l_v_prc_type_code         ||
                                   ' Loan Record Status     : ' ||l_c_cl_rec_status         ||
                                   ' Response Guaranteed amt: ' ||l_n_resp_guarantee_amt    ||
                                   ' New Guaranteed amt     : ' ||p_n_new_amount            ||
                                   ' change_field_code      : ' ||'AWARD_AMOUNT'            ||
                                   ' chg_type               : ' ||p_v_chg_type              ||
                                   ' Change record type     : ' ||'24 - Loan Increase'      ||
                                   ' change_code            : ' ||'A - Loan Increase'
                     );
          l_v_sqlstmt := 'SELECT  chdt.ROWID  '                                             ||
                         'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                         'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                         'AND    chdt.old_amt  = :cp_n_old_amt '                            ||
                         'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                         'AND    chdt.change_code_txt = ''A'' '                             ||
                         'AND    chdt.status_code IN (''R'',''N'',''D'') '                  ||
                         'AND    chdt.change_record_type_txt = ''24'' ';
          l_v_rowid := NULL;
          OPEN  c_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,l_n_resp_guarantee_amt;
          FETCH c_sl_clchsn_dtls INTO l_v_rowid;
          IF c_sl_clchsn_dtls%NOTFOUND THEN
            CLOSE c_sl_clchsn_dtls;
            l_v_rowid       := NULL;
            l_n_clchgsnd_id := NULL;
            log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                       p_v_string => ' New Loan Increase Change record is Created '  ||
                                     ' Change_field_code  : ' ||'AWARD_AMOUNT'       ||
                                     ' Change record type : ' ||'24 - Loan Increase' ||
                                     ' change code        : ' ||'A - Loan Increase '
                      );
            igf_sl_clchsn_dtls_pkg.insert_row
            (
              x_rowid                      => l_v_rowid              ,
              x_clchgsnd_id                => l_n_clchgsnd_id        ,
              x_award_id                   => l_n_award_id           ,
              x_loan_number_txt            => l_v_loan_number        ,
              x_cl_version_code            => l_n_cl_version         ,
              x_change_field_code          => 'AWARD_AMOUNT'         ,
              x_change_record_type_txt     => '24'                   ,
              x_change_code_txt            => 'A'                    ,
              x_status_code                => 'R'                    ,
              x_status_date                => TRUNC(SYSDATE)         ,
              x_response_status_code       => NULL                   ,
              x_old_value_txt              => NULL                   ,
              x_new_value_txt              => NULL                   ,
              x_old_date                   => NULL                   ,
              x_new_date                   => NULL                   ,
              x_old_amt                    => l_n_resp_guarantee_amt ,
              x_new_amt                    => p_n_new_amount         ,
              x_disbursement_number        => NULL                   ,
              x_disbursement_date          => NULL                   ,
              x_change_issue_code          => NULL                   ,
              x_disbursement_cancel_date   => NULL                   ,
              x_disbursement_cancel_amt    => NULL                   ,
              x_disbursement_revised_amt   => NULL                   ,
              x_disbursement_revised_date  => NULL                   ,
              x_disbursement_reissue_code  => NULL                   ,
              x_disbursement_reinst_code   => NULL                   ,
              x_disbursement_return_amt    => NULL                   ,
              x_disbursement_return_date   => NULL                   ,
              x_disbursement_return_code   => NULL                   ,
              x_post_with_disb_return_amt  => NULL                   ,
              x_post_with_disb_return_date => NULL                   ,
              x_post_with_disb_return_code => NULL                   ,
              x_prev_with_disb_return_amt  => NULL                   ,
              x_prev_with_disb_return_date => NULL                   ,
              x_school_use_txt             => NULL                   ,
              x_lender_use_txt             => NULL                   ,
              x_guarantor_use_txt          => NULL                   ,
              x_validation_edit_txt        => NULL                   ,
              x_send_record_txt            => NULL
            );
            -- invoke validation edits to validate the change record. The validation checks if
            -- all the required fields are populated or not for a change record
            log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                       p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                      );
            igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                            p_b_return_status => l_b_return_status,
                                            p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
            IF NOT(l_b_return_status) THEN
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                        );
              RAISE e_valid_edits;
            END IF;
            p_b_return_status := TRUE;
            p_v_message_name  := NULL;
            log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                       p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                      );
          ELSE
            CLOSE c_sl_clchsn_dtls;
            rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
            log_to_fnd(p_v_module => ' create_awd_chg_rec  ',
                       p_v_string => ' Change record is updated '                   ||
                                     ' Change_field_code  : ' ||'AWARD_AMOUNT'      ||
                                     ' Change record type : ' ||'24 - Loan Increase'||
                                     ' Change code        : ' ||'A - LOan Increase '
                      );
            igf_sl_clchsn_dtls_pkg.update_row
            (
               x_rowid                      => l_v_rowid                                           ,
               x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
               x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
               x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
               x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
               x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
               x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
               x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
               x_status_code                => 'R'                                                 ,
               x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
               x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
               x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
               x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
               x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
               x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
               x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
               x_new_amt                    => p_n_new_amount                                      ,
               x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
               x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
               x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
               x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
               x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
               x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
               x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
               x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
               x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
               x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
               x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
               x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
               x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
               x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
               x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
               x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
               x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
               x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
               x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
               x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
               x_validation_edit_txt        => NULL                                                ,
               x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            -- invoke validation edits to validate the change record. The validation checks if
            -- all the required fields are populated or not for a change record
            log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                       p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                      );
            igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                            p_b_return_status => l_b_return_status,
                                            p_v_message_name  => l_v_message_name,
                                            p_t_message_tokens => l_d_message_tokens
                                           );
            IF NOT(l_b_return_status) THEN
              log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                         p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                        );
              -- substring of the out bound parameter l_v_message_name is carried
              -- out since it can expect either IGS OR IGF message
              fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
              igf_sl_cl_chg_prc.parse_tokens(
                p_t_message_tokens => l_d_message_tokens);
/*
              FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
                 fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
              END LOOP;
*/
              log_to_fnd(p_v_module => ' create_awd_chg_rec',
                         p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                        );
              igf_sl_clchsn_dtls_pkg.update_row
              (
                  x_rowid                      => l_v_rowid                                           ,
                  x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                  x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                  x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                  x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                  x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                  x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                  x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                  x_status_code                => 'N'                                                 ,
                  x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                  x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                  x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                  x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                  x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                  x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
                  x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                  x_new_amt                    => p_n_new_amount                                      ,
                  x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                  x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                  x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                  x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                  x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                  x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                  x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                  x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                  x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                  x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                  x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                  x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                  x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                  x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                  x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                  x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                  x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                  x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                  x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                  x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                  x_validation_edit_txt        => fnd_message.get                                     ,
                  x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
              );
              log_to_fnd(p_v_module => ' create_awd_chg_rec',
                         p_v_string => ' updated the status of change send record to Not Ready to Send'
                        );
            END IF;
            p_b_return_status := TRUE;
            p_v_message_name  := NULL;
          END IF;
        ELSIF l_n_resp_guarantee_amt = p_n_new_amount THEN
          log_to_fnd(p_v_module => ' create_awd_chg_rec ',
                     p_v_string => ' Verifying if  change record is to be deleted or not '  ||
                                   ' cl version             : ' ||l_n_cl_version            ||
                                   ' loan status            : ' ||l_v_loan_status           ||
                                   ' Processing Type        : ' ||l_v_prc_type_code         ||
                                   ' Loan Record Status     : ' ||l_c_cl_rec_status         ||
                                   ' Response Guaranteed amt: ' ||l_n_resp_guarantee_amt    ||
                                   ' New Guaranteed amt     : ' ||p_n_new_amount            ||
                                   ' change_field_code      : ' ||'AWARD_AMOUNT'            ||
                                   ' chg_type               : ' ||p_v_chg_type              ||
                                   ' Change record type     : ' ||'24 - Loan Increase'      ||
                                   ' change_code            : ' ||'A - Loan Increase'
                     );
        -- verify if the existing change record is to be deleted
          l_v_sqlstmt := 'SELECT  chdt.ROWID  '                                             ||
                         'FROM   igf_sl_clchsn_dtls chdt '                                  ||
                         'WHERE  chdt.loan_number_txt = :cp_v_loan_number '                 ||
                         'AND    chdt.old_amt  = :cp_n_old_amt '                            ||
                         'AND    chdt.change_field_code = ''AWARD_AMOUNT'' '                ||
                         'AND    chdt.change_code_txt = ''A'' '                             ||
                         'AND    chdt.status_code IN (''R'',''N'',''D'') '                  ||
                         'AND    chdt.change_record_type_txt = ''24'' ';
          l_v_rowid := NULL;
          OPEN  c_sl_clchsn_dtls FOR l_v_sqlstmt USING l_v_loan_number,p_n_new_amount;
          FETCH c_sl_clchsn_dtls INTO l_v_rowid;
          IF c_sl_clchsn_dtls%FOUND THEN
            log_to_fnd(p_v_module => 'create_awd_chg_rec',
                       p_v_string => ' @24 Change record to be deleted ' ||
                                     ' Award Id    : '    ||l_n_award_id ||
                                     ' loan number : '    ||l_v_loan_number
                  );
            igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
            log_to_fnd(p_v_module => 'create_awd_chg_rec',
                       p_v_string => ' @24 Change record deleted successfully' ||
                                     ' Award Id    : '    ||l_n_award_id       ||
                                     ' loan number : '    ||l_v_loan_number
                      );
          END IF;
          CLOSE c_sl_clchsn_dtls;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
        END IF;
      END IF;
    END IF;
  END IF;
EXCEPTION
  WHEN e_resource_busy THEN
    ROLLBACK TO igf_sl_cl_create_chg_awd_sp;
    log_to_fnd(p_v_module => 'create_awd_chg_rec',
               p_v_string => ' eresource busy exception handler ' ||SQLERRM
               );
    p_b_return_status := FALSE;
    p_v_message_name  := 'IGS_GE_RECORD_LOCKED';
    RETURN;
  WHEN e_valid_edits THEN
    ROLLBACK TO igf_sl_cl_create_chg_awd_sp;
    log_to_fnd(p_v_module => 'create_awd_chg_rec',
               p_v_string => ' e_valid_edits exception handler change record validation raised errors '||l_v_message_name
              );
    p_b_return_status := FALSE;
    p_v_message_name  := l_v_message_name;
    igf_sl_cl_chg_prc.g_message_tokens := l_d_message_tokens;
    RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO igf_sl_cl_create_chg_awd_sp;
    log_to_fnd(p_v_module => 'create_awd_chg_rec',
               p_v_string => ' when others exception handler ' ||SQLERRM
              );
    fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_cl_create_chg.create_awd_chg_rec');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END create_awd_chg_rec;


PROCEDURE create_disb_chg_rec ( p_new_disb_rec    IN igf_aw_awd_disb_all%ROWTYPE,
                                p_old_disb_rec    IN igf_aw_awd_disb_all%ROWTYPE,
                                p_b_return_status OUT NOCOPY BOOLEAN,
                                p_v_message_name  OUT NOCOPY VARCHAR2
                              ) AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 10 October 2004
--
-- Purpose:
-- Invoked     : From Award Disbursement table handler after update row
-- Function    :
--
-- Parameters  : p_new_disb_rec    : IN parameter. Required.
--               p_old_disb_rec    : IN parameter. Required.
--               p_b_return_status : OUT parmeter.
--               p_v_message_name  : OUT parameter
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_igf_sl_lorlar(cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
SELECT  lar.loan_number
       ,lar.loan_status
       ,lor.prc_type_code
       ,lor.cl_rec_status
FROM    igf_sl_lor_all lor
       ,igf_sl_loans_all lar
WHERE  lor.loan_id  = lar.loan_id
AND    lar.award_id = cp_n_award_id;

rec_c_igf_sl_lorlar c_igf_sl_lorlar%ROWTYPE;

CURSOR  c_resp_r1_r8 (cp_v_loan_number igf_sl_loans_all.loan_number%TYPE,
                      cp_n_disb_num    igf_aw_awd_disb_all.disb_num%TYPE
                      ) IS
SELECT   resp_r8.disb_date
        ,resp_r8.disb_gross_amt
        ,resp_r8.disb_hold_rel_ind
FROM     igf_sl_cl_resp_r1_all resp_r1
        ,igf_sl_cl_resp_r8_all resp_r8
WHERE    resp_r1.loan_number = cp_v_loan_number
AND      resp_r1.cl_rec_status IN ('B','G')
AND      resp_r1.prc_type_code IN ('GO','GP')
AND      resp_r1.cl_version_code = 'RELEASE-4'
AND      resp_r8.clrp1_id  = resp_r1.clrp1_id
AND      resp_r8.clrp8_id  = cp_n_disb_num
ORDER BY resp_r1.clrp1_id DESC;

TYPE ref_CurclchsnTyp IS REF CURSOR;
c_igf_sl_clchsn_dtls ref_CurclchsnTyp;

rec_c_igf_sl_clchsn_dtls igf_sl_clchsn_dtls%ROWTYPE;

l_n_cl_version            igf_sl_cl_setup_all.cl_version%TYPE;
l_v_loan_status           igf_sl_loans_all.loan_status%TYPE;
l_n_clchgsnd_id           igf_sl_clchsn_dtls.clchgsnd_id%TYPE;
l_v_sqlstmt               VARCHAR2(32767);
l_v_rowid                 ROWID;
l_v_message_name          fnd_new_messages.message_name%TYPE;
l_b_return_status         BOOLEAN;
l_c_cl_rec_status         igf_sl_lor_all.cl_rec_status%TYPE;
l_v_prc_type_code         igf_sl_lor_all.prc_type_code%TYPE;
l_n_award_id              igf_aw_award_all.award_id%TYPE;
l_v_loan_number           igf_sl_loans_all.loan_number%TYPE;
l_n_disb_num              igf_aw_awd_disb_all.disb_num%TYPE;
l_v_old_fund_status       igf_aw_awd_disb_all.fund_status%TYPE;
l_n_resp_disb_gross_amt   igf_aw_awd_disb_all.disb_gross_amt%TYPE;
l_d_resp_disb_date        igf_aw_awd_disb_all.disb_date%TYPE;
l_c_resp_hold_rel_ind     igf_aw_awd_disb_all.hold_rel_ind%TYPE;
l_n_new_disb_accepted_amt  igf_aw_awd_disb_all.disb_accepted_amt%TYPE;
l_d_new_disb_date         igf_aw_awd_disb_all.disb_date%TYPE;
l_c_new_hold_rel_ind      igf_aw_awd_disb_all.hold_rel_ind%TYPE;
l_v_new_change_type_code  igf_aw_awd_disb_all.change_type_code%TYPE;
l_v_change_code_txt       igf_sl_clchsn_dtls.change_code_txt%TYPE;
l_d_disb_cancel_dt        igf_aw_awd_disb_all.disb_DATE%TYPE;
l_n_disb_cancel_amt       igf_aw_awd_disb_all.disb_gross_amt%TYPE;
l_v_fund_return_mthd_code igf_aw_awd_disb_all.fund_return_mthd_code%TYPE;

e_valid_edits     EXCEPTION;
e_resource_busy   EXCEPTION;
l_d_message_tokens        igf_sl_cl_chg_prc.token_tab%TYPE;
PRAGMA EXCEPTION_INIT(e_resource_busy,-00054);

BEGIN
  SAVEPOINT igf_sl_cl_create_chg_disb_sp;
  log_to_fnd(p_v_module => 'create_disb_chg_rec',
             p_v_string => ' Entered Procedure create_disb_chg_rec: The input parameters are '         ||
                           ' new reference of Award Id         : ' ||p_new_disb_rec.award_id           ||
                           ' new reference of disb num         : ' ||p_new_disb_rec.disb_num           ||
                           ' new reference of disb date        : ' ||TO_CHAR(p_new_disb_rec.disb_date,'YYYY-MM-DD HH24:MI:SS')||
                           ' new reference of disb accepted amt: ' ||p_new_disb_rec.disb_accepted_amt  ||
                           ' new reference of hold rel ind     : ' ||p_new_disb_rec.hold_rel_ind       ||
                           ' new reference of trans type       : ' ||p_new_disb_rec.trans_type         ||
                           ' new reference of fund status      : ' ||p_new_disb_rec.fund_status        ||
                           ' old reference of fund status      : ' ||p_old_disb_rec.fund_status        ||
                           ' new reference of disb gross amt   : ' ||p_new_disb_rec.disb_gross_amt     ||
                           ' new reference of change type code : ' ||NVL(p_new_disb_rec.change_type_code,'NULL')
            );

  l_n_award_id             := p_new_disb_rec.award_id;
  l_n_disb_num             := p_new_disb_rec.disb_num;
  l_n_new_disb_accepted_amt:= p_new_disb_rec.disb_accepted_amt;
  l_d_new_disb_date        := TRUNC(p_new_disb_rec.disb_date);
  l_c_new_hold_rel_ind     := p_new_disb_rec.hold_rel_ind ;
  l_v_old_fund_status      := NVL(p_new_disb_rec.fund_status,'N');
  l_v_new_change_type_code := NVL(p_new_disb_rec.change_type_code,'NULL');
  l_v_fund_return_mthd_code:= p_new_disb_rec.fund_return_mthd_code;

  -- get the processing type code, loan record status, loan status and loan number for the input award id
  OPEN   c_igf_sl_lorlar (cp_n_award_id => l_n_award_id);
  FETCH  c_igf_sl_lorlar INTO rec_c_igf_sl_lorlar;
  CLOSE  c_igf_sl_lorlar;

  l_v_loan_number   := rec_c_igf_sl_lorlar.loan_number;
  l_v_loan_status   := rec_c_igf_sl_lorlar.loan_status;
  l_v_prc_type_code := rec_c_igf_sl_lorlar.prc_type_code;
  l_c_cl_rec_status := rec_c_igf_sl_lorlar.cl_rec_status;

  -- get the loan version for the input award id
  l_n_cl_version  := igf_sl_award.get_loan_cl_version(p_n_award_id => l_n_award_id);

  -- get the latest Guaranteed Response for the required fields
  -- if no records are found change record would not be created. The control is returned back
  -- to the calling program.

  OPEN  c_resp_r1_r8 ( cp_v_loan_number => l_v_loan_number,
                       cp_n_disb_num    => l_n_disb_num
                     );
  FETCH  c_resp_r1_r8 INTO l_d_resp_disb_date,l_n_resp_disb_gross_amt,l_c_resp_hold_rel_ind;
  IF c_resp_r1_r8%NOTFOUND THEN
    CLOSE  c_resp_r1_r8 ;
    log_to_fnd(p_v_module => ' create_disb_chg_rec ',
               p_v_string => ' No Response record found '          ||
                             ' for loan number: ' ||l_v_loan_number||
                             ' and for disb num: '||l_n_disb_num
              );
    p_b_return_status := FALSE;
    p_v_message_name  := NULL;
    RETURN;
  END IF;
  CLOSE  c_resp_r1_r8 ;
  log_to_fnd(p_v_module => ' create_disb_chg_rec ',
             p_v_string => ' Response record found '                              ||
                           ' for loan number: '        ||l_v_loan_number          ||
                           ' and for disb num: '       ||l_n_disb_num             ||
                           ' response disb date: '     ||TO_CHAR(l_d_resp_disb_date,'YYYY-MM-DD HH24:MI:SS')||
                           ' response disb gross amt: '||l_n_resp_disb_gross_amt  ||
                           ' response hold rel ind: '  ||l_c_resp_hold_rel_ind
            );
  -- Check if the Loan Cancellation record should be created or not
  -- Change Record would be created only if
  -- The version = CommonLine Release 4 Version Loan,
  -- Loan Status = Accepted
  -- Loan Record Status is Guaranteed or Accepted
  -- Processing Type Code is GP or GO
  -- information is different from the latest guaranteed response for the loan

  IF (l_n_cl_version = 'RELEASE-4' AND
      l_v_loan_status = 'A' AND
      l_v_prc_type_code IN ('GO','GP') AND
      l_c_cl_rec_status IN ('B','G'))
  THEN
    --  following code logic is for pre disbursement changes (@9)
    -- if fund status is 'N', changes are pre disbursement changes (@9)
    IF l_v_old_fund_status = 'N'  THEN
      -- start  of code logic for disbursement date change
      -- start of code logic for Change Type other than Reinstatement
      IF TRUNC(l_d_resp_disb_date) <> l_d_new_disb_date AND
         l_v_new_change_type_code <> 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version            ||
                                 ' loan status               : '||l_v_loan_status           ||
                                 ' Processing Type           : '||l_v_prc_type_code         ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status         ||
                                 ' response disb date        : '||l_d_resp_disb_date        ||
                                 ' new reference of disb date: '||l_d_new_disb_date         ||
                                 ' fund status               : '||'Pre Disbursement change' ||
                                 ' change type code          : '|| l_v_new_change_type_code ||
                                 ' change_field_code         : '|| 'DISB_DATE'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_resp_disb_dt '          ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''B'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,TRUNC(l_d_resp_disb_date);
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' New Change record is Created  '                                  ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                             ||
                                   ' Change record type : ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code        : ' ||'B - Disbursement Date Change '
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_DATE'              ,
             x_change_record_type_txt     => '09'                     ,
             x_change_code_txt            => 'B'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => TRUNC(l_d_resp_disb_date),
             x_new_date                   => l_d_new_disb_date        ,
             x_old_amt                    => NULL                     ,
             x_new_amt                    => NULL                     ,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => TRUNC(l_d_resp_disb_date),
             x_change_issue_code          => 'PRE_DISB'               ,
             x_disbursement_cancel_date   => NULL                     ,
             x_disbursement_cancel_amt    => NULL                     ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => NULL                     ,
             x_disbursement_reinst_code   => 'N'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => NULL                     ,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
           -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                      ||
                                   ' Change_field_code : ' ||'DISB_DATE'                             ||
                                   ' Change record type: ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code       : ' ||'B - Disbursement Date Change '         ||
                                   ' new disb date     : ' || l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_new_disb_date                                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => l_d_new_disb_date                                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
              x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes have been reverted back
      ELSIF l_d_resp_disb_date = l_d_new_disb_date AND
            l_v_new_change_type_code <> 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not  '   ||
                                 ' cl version                : ' ||l_n_cl_version            ||
                                 ' loan status               : ' ||l_v_loan_status           ||
                                 ' Processing Type           : ' ||l_v_prc_type_code         ||
                                 ' Loan Record Status        : ' ||l_c_cl_rec_status         ||
                                 ' response disb date        : ' ||l_d_resp_disb_date        ||
                                 ' new reference of disb date: ' ||l_d_new_disb_date         ||
                                 ' fund status               : ' ||'Pre Disbursement change' ||
                                 ' change type code          : ' || l_v_new_change_type_code ||
                                 ' change_field_code         : ' || 'DISB_DATE'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_new_disb_dt '           ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''B'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_new_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record deleted  Successfully'  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for Change Type other than Reinstatement
      -- end  of code logic for disbursement date change

      -- start of code logic for hold release indicator change
      IF l_c_resp_hold_rel_ind <> l_c_new_hold_rel_ind THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version               : '||l_n_cl_version            ||
                                 ' loan status              : '||l_v_loan_status           ||
                                 ' Processing Type          : '||l_v_prc_type_code         ||
                                 ' Loan Record Status       : '||l_c_cl_rec_status         ||
                                 ' response hold release ind: '||l_c_resp_hold_rel_ind     ||
                                 ' new hold release ind     : '||l_c_new_hold_rel_ind      ||
                                 ' fund status              : '||'Pre Disbursement change' ||
                                 ' change type code         : '||l_v_new_change_type_code ||
                                 ' change_field_code        : '||'DISB_HOLD_REL_IND'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                             ||
                       'FROM   igf_sl_clchsn_dtls chdt '                        ||
                       'WHERE  chdt.award_id = :cp_n_award_id '                 ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '       ||
                       'AND    chdt.old_value_txt = :cp_c_resp_hold_rel_ind '   ||
                       'AND    chdt.change_field_code = ''DISB_HOLD_REL_IND'' ' ||
                       'AND    chdt.change_code_txt = ''E'' '                   ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '        ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_c_resp_hold_rel_ind;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                  ||
                                   ' Change_field_code : ' ||'DISB_HOLD_REL_IND'                     ||
                                   ' Change record type: ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code       : ' ||'E - Disbursement Hold Release Change '
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_HOLD_REL_IND'      ,
             x_change_record_type_txt     => '09'                     ,
             x_change_code_txt            => 'E'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => l_c_resp_hold_rel_ind    ,
             x_new_value_txt              => l_c_new_hold_rel_ind     ,
             x_old_date                   => NULL                     ,
             x_new_date                   => NULL                     ,
             x_old_amt                    => NULL                     ,
             x_new_amt                    => NULL                     ,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'PRE_DISB'               ,
             x_disbursement_cancel_date   => NULL                     ,
             x_disbursement_cancel_amt    => NULL                     ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => NULL                     ,
             x_disbursement_reinst_code   => 'N'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => NULL                     ,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
            -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                        ||
                                   ' Change_field_code   : ' ||'DISB_HOLD_REL_IND'                     ||
                                   ' Change record type  : ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code         : ' ||'E - Disbursement Hold Release Change ' ||
                                   ' new hold release ind: ' || l_c_new_hold_rel_ind
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => l_c_new_hold_rel_ind                                ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec',
                     p_v_string => ' validating the Change record for  Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => l_c_new_hold_rel_ind                                ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
              x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                       );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes have been reverted back
      ELSIF l_c_resp_hold_rel_ind = l_c_new_hold_rel_ind THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not '    ||
                                 ' cl version               : '||l_n_cl_version            ||
                                 ' loan status              : '||l_v_loan_status           ||
                                 ' Processing Type          : '||l_v_prc_type_code         ||
                                 ' Loan Record Status       : '||l_c_cl_rec_status         ||
                                 ' response hold release ind: '||l_c_resp_hold_rel_ind     ||
                                 ' new hold release ind     : '||l_c_new_hold_rel_ind      ||
                                 ' fund status              : '||'Pre Disbursement change' ||
                                 ' change type code         : '|| l_v_new_change_type_code ||
                                 ' change_field_code        : '|| 'DISB_HOLD_REL_IND'
                   );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                             ||
                       'FROM   igf_sl_clchsn_dtls chdt '                        ||
                       'WHERE  chdt.award_id = :cp_n_award_id '                 ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '       ||
                       'AND    chdt.old_value_txt = :cp_c_new_hold_rel_ind '    ||
                       'AND    chdt.change_field_code = ''DISB_HOLD_REL_IND'' ' ||
                       'AND    chdt.change_code_txt = ''E'' '                   ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '        ||
                       'AND    chdt.change_record_type_txt = ''09'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_c_new_hold_rel_ind;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '         ||
                                   ' Award Id            : '||l_n_award_id ||
                                   ' Disb Num            : '||l_n_disb_num ||
                                   ' new hold release ind: '||l_c_new_hold_rel_ind
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted successfully'||
                                   ' Award Id            : '||l_n_award_id    ||
                                   ' Disb Num            : '||l_n_disb_num    ||
                                   ' new hold release ind: '||l_c_new_hold_rel_ind
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for hold release indicator change
      -- start of code logic for disbursement amount change
      -- start of code logic for Change Type othet than Reinstatement
      IF l_n_resp_disb_gross_amt <> l_n_new_disb_accepted_amt AND
         l_v_new_change_type_code <> 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version            ||
                                 ' loan status               : '||l_v_loan_status           ||
                                 ' Processing Type           : '||l_v_prc_type_code         ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status         ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt   ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt ||
                                 ' fund status               : '||'Pre Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code  ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );

        l_d_disb_cancel_dt  := NULL;
        l_n_disb_cancel_amt := NULL;
        IF l_n_resp_disb_gross_amt < l_n_new_disb_accepted_amt THEN
          -- change code = amount increase
          l_v_change_code_txt := 'AI';
        ELSIF l_n_resp_disb_gross_amt > l_n_new_disb_accepted_amt AND
              l_v_new_change_type_code = 'NULL' THEN
          -- change code = amount decrease
          l_v_change_code_txt := 'AD';
        ELSIF l_n_resp_disb_gross_amt > l_n_new_disb_accepted_amt AND
              l_v_new_change_type_code = 'CANCELLATION' THEN
          -- change code = amount decrease with cancellation
          l_v_change_code_txt := 'ADI';
          l_d_disb_cancel_dt  := TRUNC(SYSDATE);
          l_n_disb_cancel_amt := NVL((l_n_resp_disb_gross_amt - l_n_new_disb_accepted_amt),0);
        END IF;
        log_to_fnd(p_v_module => ' Derived tha change Code ',
                   p_v_string => ' Change Code: '   ||l_v_change_code_txt
                  );
        IF l_v_change_code_txt = 'ADI' THEN
          l_v_rowid := NULL;
          -- verify if the AI record is to be deleted
          l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                         'FROM   igf_sl_clchsn_dtls chdt '                     ||
                         'WHERE  chdt.award_id = :cp_n_award_id '              ||
                         'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                         'AND    chdt.old_amt = :cp_d_resp_disb_amt '          ||
                         'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                         'AND    chdt.change_code_txt = ''AI'' '               ||
                         'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                         'AND    chdt.change_record_type_txt = ''09'' ';
          OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_resp_disb_gross_amt;
          FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
          IF c_igf_sl_clchsn_dtls%FOUND THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' Change record to be deleted'        ||
                                     ' Award Id        : ' ||l_n_award_id   ||
                                     ' loan number     : ' ||l_v_loan_number||
                                     ' Disb Number     : ' ||l_n_disb_num   ||
                                     ' change_code_txt : ' ||'AI'
                  );
            igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' Change record deleted successfully ' ||
                                     ' Award Id        : ' ||l_n_award_id   ||
                                     ' loan number     : ' ||l_v_loan_number||
                                     ' Disb Number     : ' ||l_n_disb_num   ||
                                     ' change_code_txt : ' ||'AI'
                  );
          END IF;
          CLOSE c_igf_sl_clchsn_dtls;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
        END IF;
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_resp_disb_amt '          ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.change_code_txt = :cp_change_code '      ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''09'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_resp_disb_gross_amt,l_v_change_code_txt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                  ||
                                   ' Change_field_code : ' ||'DISB_AMOUNT'                           ||
                                   ' Change record type: ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code       : ' ||l_v_change_code_txt
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_AMOUNT'            ,
             x_change_record_type_txt     => '09'                     ,
             x_change_code_txt            => l_v_change_code_txt      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => NULL                     ,
             x_new_date                   => NULL                     ,
             x_old_amt                    => l_n_resp_disb_gross_amt  ,
             x_new_amt                    => l_n_new_disb_accepted_amt,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'PRE_DISB'               ,
             x_disbursement_cancel_date   => l_d_disb_cancel_dt       ,
             x_disbursement_cancel_amt    => l_n_disb_cancel_amt      ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => NULL                     ,
             x_disbursement_reinst_code   => 'N'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => NULL                     ,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
            -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                        ||
                                   ' Change_field_code  : ' ||'DISB_AMOUNT'                           ||
                                   ' Change record type : ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code        : ' ||l_v_change_code_txt                     ||
                                   ' new disb Amount    : ' ||l_n_new_disb_accepted_amt
                    );
            l_d_disb_cancel_dt  := rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date ;
            l_n_disb_cancel_amt := rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt  ;
          IF rec_c_igf_sl_clchsn_dtls.change_code_txt = 'ADI' THEN
            l_d_disb_cancel_dt  := TRUNC(SYSDATE);
            l_n_disb_cancel_amt := NVL((rec_c_igf_sl_clchsn_dtls.old_amt - l_n_new_disb_accepted_amt),0);
          END IF;
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => l_n_new_disb_accepted_amt                           ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => l_d_disb_cancel_dt                                  ,
            x_disbursement_cancel_amt    => l_n_disb_cancel_amt                                 ,
            x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                           ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                      );
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => l_n_new_disb_accepted_amt                           ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => l_d_disb_cancel_dt                                  ,
              x_disbursement_cancel_amt    => l_n_disb_cancel_amt                                 ,
              x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                           ,
              x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes are reverted back
      ELSIF l_n_resp_disb_gross_amt = l_n_new_disb_accepted_amt AND
            l_v_new_change_type_code <> 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be deleted '||
                                 ' cl version                : '||l_n_cl_version            ||
                                 ' loan status               : '||l_v_loan_status           ||
                                 ' Processing Type           : '||l_v_prc_type_code         ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status         ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt   ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt ||
                                 ' fund status               : '||'Pre Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code  ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_new_disb_amt '           ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_new_disb_accepted_amt;
        LOOP
          FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
          EXIT  WHEN c_igf_sl_clchsn_dtls%NOTFOUND;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '                                  ||
                                   ' Award Id      : '   ||l_n_award_id                             ||
                                   ' Disb Num      : '   ||l_n_disb_num                             ||
                                   ' Loan number   : '   ||rec_c_igf_sl_clchsn_dtls.loan_number_txt ||
                                   ' Change send id: '   ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id     ||
                                   ' Change Code   : '   ||rec_c_igf_sl_clchsn_dtls.change_code_txt
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec',
                     p_v_string => ' Change record deleted successfully '                           ||
                                   ' Award Id      : '   ||l_n_award_id                             ||
                                   ' Disb Num      : '   ||l_n_disb_num                             ||
                                   ' Loan number   : '   ||rec_c_igf_sl_clchsn_dtls.loan_number_txt ||
                                   ' Change send id: '   ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id     ||
                                   ' Change Code   : '   ||rec_c_igf_sl_clchsn_dtls.change_code_txt
                    );
        END LOOP;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for Change Type othet than Reinstatement
      -- start of code logic for Change Type = Reinstatement
      IF l_n_resp_disb_gross_amt <> l_n_new_disb_accepted_amt AND
         l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version            ||
                                 ' loan status               : '||l_v_loan_status           ||
                                 ' Processing Type           : '||l_v_prc_type_code         ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status         ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt   ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt ||
                                 ' fund status               : '||'Pre Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code  ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_resp_disb_amt '          ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_resp_disb_gross_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                  ||
                                   ' Change_field_code : ' ||'DISB_AMOUNT'                           ||
                                   ' Change record type: ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code       : ' ||'C - Disbursement Reinstatement '
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                   ,
             x_clchgsnd_id                => l_n_clchgsnd_id             ,
             x_award_id                   => l_n_award_id                ,
             x_loan_number_txt            => l_v_loan_number             ,
             x_cl_version_code            => l_n_cl_version              ,
             x_change_field_code          => 'DISB_AMOUNT'               ,
             x_change_record_type_txt     => '09'                        ,
             x_change_code_txt            => 'C'                         ,
             x_status_code                => 'R'                         ,
             x_status_date                => TRUNC(SYSDATE)              ,
             x_response_status_code       => NULL                        ,
             x_old_value_txt              => NULL                        ,
             x_new_value_txt              => NULL                        ,
             x_old_date                   => NULL                        ,
             x_new_date                   => NULL                        ,
             x_old_amt                    => l_n_resp_disb_gross_amt     ,
             x_new_amt                    => l_n_new_disb_accepted_amt   ,
             x_disbursement_number        => l_n_disb_num                ,
             x_disbursement_date          => l_d_resp_disb_date          ,
             x_change_issue_code          => 'PRE_DISB'                  ,
             x_disbursement_cancel_date   => NULL                        ,
             x_disbursement_cancel_amt    => NULL                        ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt   ,
             x_disbursement_revised_date  => l_d_new_disb_date           ,
             x_disbursement_reissue_code  => NULL                        ,
             x_disbursement_reinst_code   => 'Y'                         ,
             x_disbursement_return_amt    => NULL                        ,
             x_disbursement_return_date   => NULL                        ,
             x_disbursement_return_code   => NULL                        ,
             x_post_with_disb_return_amt  => NULL                        ,
             x_post_with_disb_return_date => NULL                        ,
             x_post_with_disb_return_code => NULL                        ,
             x_prev_with_disb_return_amt  => NULL                        ,
             x_prev_with_disb_return_date => NULL                        ,
             x_school_use_txt             => NULL                        ,
             x_lender_use_txt             => NULL                        ,
             x_guarantor_use_txt          => NULL                        ,
             x_validation_edit_txt        => NULL                        ,
             x_send_record_txt            => NULL
           );
            -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                       ||
                                   ' Change_field_code  : ' ||'DISB_AMOUNT'                           ||
                                   ' Change record type : ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code        : ' ||'C - Disbursement Reinstatement '       ||
                                   ' new disb Amount    : ' ||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => l_n_new_disb_accepted_amt                           ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                           ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                      );
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => l_n_new_disb_accepted_amt                           ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                           ,
              x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => NULL                                                ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes are reverted back
      ELSIF l_n_resp_disb_gross_amt = l_n_new_disb_accepted_amt AND
            l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not '    ||
                                 ' cl version                : '||l_n_cl_version            ||
                                 ' loan status               : '||l_v_loan_status           ||
                                 ' Processing Type           : '||l_v_prc_type_code         ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status         ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt   ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt ||
                                 ' fund status               : '||'Pre Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code  ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_new_disb_amt '           ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_new_disb_accepted_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '    ||
                                   ' Award Id       : '||l_n_award_id ||
                                   ' Disb Num       : '||l_n_disb_num ||
                                   ' New disb Amount: '||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted  successfully'    ||
                                   ' Award Id       : '||l_n_award_id              ||
                                   ' Disb Num       : '||l_n_disb_num              ||
                                   ' New disb Amount: '||l_n_new_disb_accepted_amt
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for Change Type = Reinstatement
      -- end of code logic for disbursement amount change

      -- start  of code logic for disbursement date change
      -- start of code logic for Change Type = Reinstatement
      IF l_d_resp_disb_date <> l_d_new_disb_date AND
         l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version            ||
                                 ' loan status               : '||l_v_loan_status           ||
                                 ' Processing Type           : '||l_v_prc_type_code         ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status         ||
                                 ' response disb date        : '||l_d_resp_disb_date        ||
                                 ' new reference of disb date: '||l_d_new_disb_date         ||
                                 ' fund status               : '||'Pre Disbursement change' ||
                                 ' change type code          : '|| l_v_new_change_type_code ||
                                 ' change_field_code         : '|| 'DISB_DATE'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_resp_disb_dt '          ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_resp_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' New Change record is Created  '                                  ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                             ||
                                   ' Change record type : ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code        : ' ||'C - Disbursement Reinstatement '
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_DATE'              ,
             x_change_record_type_txt     => '09'                     ,
             x_change_code_txt            => 'C'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => l_d_resp_disb_date       ,
             x_new_date                   => l_d_new_disb_date        ,
             x_old_amt                    => NULL                     ,
             x_new_amt                    => NULL                     ,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'PRE_DISB'               ,
             x_disbursement_cancel_date   => NULL                     ,
             x_disbursement_cancel_amt    => NULL                     ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => NULL                     ,
             x_disbursement_reinst_code   => 'Y'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => NULL                     ,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
           -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                      ||
                                   ' Change_field_code : ' ||'DISB_DATE'                             ||
                                   ' Change record type: ' ||'09 - Disbursement Cancellation/Change' ||
                                   ' Change code       : ' ||'B - Disbursement Date Change '         ||
                                   ' new disb date     : ' || l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_new_disb_date                                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => l_d_new_disb_date                                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
              x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes have been reverted back
      ELSIF l_d_resp_disb_date = l_d_new_disb_date AND
            l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not  '   ||
                                 ' cl version                : ' ||l_n_cl_version            ||
                                 ' loan status               : ' ||l_v_loan_status           ||
                                 ' Processing Type           : ' ||l_v_prc_type_code         ||
                                 ' Loan Record Status        : ' ||l_c_cl_rec_status         ||
                                 ' response disb date        : ' ||l_d_resp_disb_date        ||
                                 ' new reference of disb date: ' ||l_d_new_disb_date         ||
                                 ' fund status               : ' ||'Pre Disbursement change' ||
                                 ' change type code          : ' || l_v_new_change_type_code ||
                                 ' change_field_code         : ' || 'DISB_DATE'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_new_disb_dt '           ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''09'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_new_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record deleted  Successfully'  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for Change Type = Reinstatement
      -- end  of code logic for disbursement date change
    END IF;
    -- end of code logic for pre disbursement changes (@9)

    -- start of code logic for post disbursement changes (@10)
    -- if fund status is 'Y', changes are post disbursement changes (@10)
    IF l_v_old_fund_status = 'Y'  THEN
      -- start  of code logic for disbursement amount change
      -- Full or Partial Reinstatement
      IF l_n_resp_disb_gross_amt <> l_n_new_disb_accepted_amt AND
         l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt    ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt  ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code   ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_resp_disb_amt '          ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_resp_disb_gross_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                    ||
                                   ' Change_field_code : ' ||'DISB_AMOUNT'                             ||
                                   ' Change record type: ' ||'10 - Disbursement Notification / Change' ||
                                   ' Change code       : ' ||'C-Full or Partial Reinstatement'
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                     ,
             x_clchgsnd_id                => l_n_clchgsnd_id               ,
             x_award_id                   => l_n_award_id                  ,
             x_loan_number_txt            => l_v_loan_number               ,
             x_cl_version_code            => l_n_cl_version                ,
             x_change_field_code          => 'DISB_AMOUNT'                 ,
             x_change_record_type_txt     => '10'                          ,
             x_change_code_txt            => 'C'                           ,
             x_status_code                => 'R'                           ,
             x_status_date                => TRUNC(SYSDATE)                ,
             x_response_status_code       => NULL                          ,
             x_old_value_txt              => NULL                          ,
             x_new_value_txt              => NULL                          ,
             x_old_date                   => NULL                          ,
             x_new_date                   => NULL                          ,
             x_old_amt                    => l_n_resp_disb_gross_amt       ,
             x_new_amt                    => l_n_new_disb_accepted_amt     ,
             x_disbursement_number        => l_n_disb_num                  ,
             x_disbursement_date          => l_d_resp_disb_date            ,
             x_change_issue_code          => 'POST_DISB'                   ,
             x_disbursement_cancel_date   => NULL                          ,
             x_disbursement_cancel_amt    => NULL                          ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt     ,
             x_disbursement_revised_date  => l_d_new_disb_date             ,
             x_disbursement_reissue_code  => NULL                          ,
             x_disbursement_reinst_code   => 'Y'                           ,
             x_disbursement_return_amt    => NULL                          ,
             x_disbursement_return_date   => NULL                          ,
             x_disbursement_return_code   => NULL                          ,
             x_post_with_disb_return_amt  => NULL                          ,
             x_post_with_disb_return_date => NULL                          ,
             x_post_with_disb_return_code => NULL                          ,
             x_prev_with_disb_return_amt  => NULL                          ,
             x_prev_with_disb_return_date => NULL                          ,
             x_school_use_txt             => NULL                          ,
             x_lender_use_txt             => NULL                          ,
             x_guarantor_use_txt          => NULL                          ,
             x_validation_edit_txt        => NULL                          ,
             x_send_record_txt            => NULL
           );
            -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                          ||
                                   ' Change_field_code : '  ||'DISB_AMOUNT'                             ||
                                   ' Change record type: '  ||'10 - Disbursement Notification / Change' ||
                                   ' Change code       : '  ||'C-Full or Partial Reinstatement'         ||
                                   ' new disb Amount   : '  ||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => l_n_new_disb_accepted_amt                           ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                           ,
            x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                      );
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => rec_c_igf_sl_clchsn_dtls.new_date                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => l_n_new_disb_accepted_amt                           ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                           ,
              x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                       );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- changes are reverted back
      ELSIF l_n_resp_disb_gross_amt = l_n_new_disb_accepted_amt AND
         l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not '     ||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt    ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt  ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code   ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_new_disb_amt '           ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.change_record_type_txt = ''10'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_new_disb_accepted_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '         ||
                                   ' Award Id       : ' ||l_n_award_id ||
                                   ' Disb Num       : ' ||l_n_disb_num ||
                                   ' new disb Amount: ' ||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted  succesfully'         ||
                                   ' Award Id       : ' ||l_n_award_id ||
                                   ' Disb Num       : ' ||l_n_disb_num ||
                                   ' new disb Amount: ' ||l_n_new_disb_accepted_amt
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end  of code logic for disbursement amount change
      -- Full or Partial Reinstatement code logic ends here

      -- Full or Partial Reissue code logic starts here
      -- start  of code logic for disbursement amount change
      IF ((l_n_resp_disb_gross_amt <> l_n_new_disb_accepted_amt) AND
           l_v_new_change_type_code = 'REISSUE')
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '     ||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt    ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt  ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code   ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_resp_disb_amt '          ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.change_code_txt = ''B'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_resp_disb_gross_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN

          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                     ||
                                   ' Change_field_code : '  ||'DISB_AMOUNT'                             ||
                                   ' Change record type: '  ||'10 - Disbursement Notification / Change' ||
                                   ' Change code       : '  ||'B-Full or Partial Reissue'               ||
                                   ' new disb Amount   : '  ||l_n_new_disb_accepted_amt
                    );

          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_AMOUNT'            ,
             x_change_record_type_txt     => '10'                     ,
             x_change_code_txt            => 'B'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => l_d_resp_disb_date       ,
             x_new_date                   => l_d_new_disb_date        ,
             x_old_amt                    => l_n_resp_disb_gross_amt  ,
             x_new_amt                    => l_n_new_disb_accepted_amt,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'POST_DISB'              ,
             x_disbursement_cancel_date   => NULL                     ,
             x_disbursement_cancel_amt    => NULL                     ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => 'Y'                      ,
             x_disbursement_reinst_code   => 'N'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => l_v_fund_return_mthd_code,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
            -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                     ||
                                   ' Change_field_code : '  ||'DISB_AMOUNT'                             ||
                                   ' Change record type: '  ||'10 - Disbursement Notification / Change' ||
                                   ' Change code       : '  ||'B-Full or Partial Reissue'               ||
                                   ' new disb Amount   : '  ||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                             ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                  ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                     ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt              ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code              ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code            ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt       ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt              ,
            x_status_code                => 'R'                                                   ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                  ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code         ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt                ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt                ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                     ,
            x_new_date                   => l_d_new_disb_date                                     ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                      ,
            x_new_amt                    => l_n_new_disb_accepted_amt                             ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number          ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date            ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code            ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date     ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt      ,
            x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                             ,
            x_disbursement_revised_date  => l_d_new_disb_date                                     ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code    ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code     ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt      ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date     ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code     ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt    ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date   ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code   ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt    ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date   ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt               ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt               ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt            ,
            x_validation_edit_txt        => NULL                                                  ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                             ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                  ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                     ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt              ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code              ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code            ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt       ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt              ,
              x_status_code                => 'N'                                                   ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                  ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code         ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt                ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt                ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                     ,
              x_new_date                   => l_d_new_disb_date                                     ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                      ,
              x_new_amt                    => l_n_new_disb_accepted_amt                             ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number          ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date            ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code            ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date     ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt      ,
              x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                             ,
              x_disbursement_revised_date  => l_d_new_disb_date                                     ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code    ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code     ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt      ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date     ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code     ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt    ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date   ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code   ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt    ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date   ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt               ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt               ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt            ,
              x_validation_edit_txt        => fnd_message.get                                       ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes are reverted back
      ELSIF ((l_n_resp_disb_gross_amt = l_n_new_disb_accepted_amt) AND
             l_v_new_change_type_code = 'REISSUE')
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not '     ||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt    ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt  ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code   ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );

        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_new_disb_amt '           ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_code_txt = ''B'' '                ||
                       'AND    chdt.change_record_type_txt = ''10'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_new_disb_accepted_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '         ||
                                   ' Award Id       : ' ||l_n_award_id ||
                                   ' Disb Num       : ' ||l_n_disb_num ||
                                   ' new disb Amount: ' ||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted  succesfully'         ||
                                   ' Award Id       : ' ||l_n_award_id ||
                                   ' Disb Num       : ' ||l_n_disb_num ||
                                   ' new disb Amount: ' ||l_n_new_disb_accepted_amt
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- End  of code logic for disbursement amount change (Reissue)
      -- Full or Partial cancellation logic starts here
      -- start  of code logic for disbursement amount change
      IF ((l_n_resp_disb_gross_amt <> l_n_new_disb_accepted_amt) AND
           l_v_new_change_type_code = 'CANCELLATION')
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '     ||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt    ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt  ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code   ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_resp_disb_amt '          ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.change_code_txt = ''A'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_resp_disb_gross_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN

          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                     ||
                                   ' Change_field_code : '  ||'DISB_AMOUNT'                             ||
                                   ' Change record type: '  ||'10 - Disbursement Notification / Change' ||
                                   ' Change code       : '  ||'A-Full or Partial Cancellation'          ||
                                   ' new disb Amount   : '  ||l_n_new_disb_accepted_amt
                    );

          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_AMOUNT'            ,
             x_change_record_type_txt     => '10'                     ,
             x_change_code_txt            => 'A'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => l_d_resp_disb_date       ,
             x_new_date                   => l_d_new_disb_date        ,
             x_old_amt                    => l_n_resp_disb_gross_amt  ,
             x_new_amt                    => l_n_new_disb_accepted_amt,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'POST_DISB'              ,
             x_disbursement_cancel_date   => TRUNC(SYSDATE)           ,
             x_disbursement_cancel_amt    => (l_n_resp_disb_gross_amt -  l_n_new_disb_accepted_amt) ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => NULL                     ,
             x_disbursement_reinst_code   => 'N'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => l_v_fund_return_mthd_code,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
            -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' New Change record is Created '                                     ||
                                   ' Change_field_code : '  ||'DISB_AMOUNT'                             ||
                                   ' Change record type: '  ||'10 - Disbursement Notification / Change' ||
                                   ' Change code       : '  ||'A-Full or Partial Cancellation'          ||
                                   ' new disb Amount   : '  ||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                             ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                  ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                     ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt              ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code              ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code            ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt       ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt              ,
            x_status_code                => 'R'                                                   ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                  ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code         ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt                ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt                ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                     ,
            x_new_date                   => l_d_new_disb_date                                     ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                      ,
            x_new_amt                    => l_n_new_disb_accepted_amt                             ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number          ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date            ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code            ,
            x_disbursement_cancel_date   => TRUNC(SYSDATE)                                        ,
            x_disbursement_cancel_amt    => (rec_c_igf_sl_clchsn_dtls.old_amt - l_n_new_disb_accepted_amt) ,
            x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                             ,
            x_disbursement_revised_date  => l_d_new_disb_date                                     ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code    ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code     ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt      ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date     ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code     ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt    ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date   ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code   ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt    ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date   ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt               ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt               ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt            ,
            x_validation_edit_txt        => NULL                                                  ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                             ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                  ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                     ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt              ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code              ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code            ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt       ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt              ,
              x_status_code                => 'N'                                                   ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                  ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code         ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt                ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt                ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                     ,
              x_new_date                   => l_d_new_disb_date                                     ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                      ,
              x_new_amt                    => l_n_new_disb_accepted_amt                             ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number          ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date            ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code            ,
              x_disbursement_cancel_date   => TRUNC(SYSDATE)                                        ,
              x_disbursement_cancel_amt    => (rec_c_igf_sl_clchsn_dtls.old_amt - l_n_new_disb_accepted_amt),
              x_disbursement_revised_amt   => l_n_new_disb_accepted_amt                             ,
              x_disbursement_revised_date  => l_d_new_disb_date                                     ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code    ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code     ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt      ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date     ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code     ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt    ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date   ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code   ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt    ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date   ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt               ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt               ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt            ,
              x_validation_edit_txt        => fnd_message.get                                       ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes are reverted back
      ELSIF ((l_n_resp_disb_gross_amt = l_n_new_disb_accepted_amt) AND
             l_v_new_change_type_code = 'CANCELLATION')
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not '     ||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb gross amount: '||l_n_resp_disb_gross_amt    ||
                                 ' new disb accepted amount  : '||l_n_new_disb_accepted_amt  ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '||l_v_new_change_type_code   ||
                                 ' change_field_code         : '||'DISB_AMOUNT'
                  );

        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_amt = :cp_d_new_disb_amt '           ||
                       'AND    chdt.change_field_code = ''DISB_AMOUNT'' '    ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_code_txt = ''A'' '                ||
                       'AND    chdt.change_record_type_txt = ''10'' ';
        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_n_new_disb_accepted_amt;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '         ||
                                   ' Award Id       : ' ||l_n_award_id ||
                                   ' Disb Num       : ' ||l_n_disb_num ||
                                   ' new disb Amount: ' ||l_n_new_disb_accepted_amt
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted  succesfully'         ||
                                   ' Award Id       : ' ||l_n_award_id ||
                                   ' Disb Num       : ' ||l_n_disb_num ||
                                   ' new disb Amount: ' ||l_n_new_disb_accepted_amt
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- End  of code logic for disbursement amount change (Cancellation)
      -- start of code logic for Change Type = Reinstatement
      -- start  of code logic for disbursement date change
      IF l_d_resp_disb_date <> l_d_new_disb_date AND
         l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb date        : '||l_d_resp_disb_date         ||
                                 ' new reference of disb date: '||l_d_new_disb_date          ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '|| l_v_new_change_type_code  ||
                                 ' change_field_code         : '|| 'DISB_DATE'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_resp_disb_dt '          ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_resp_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' New Change record is Created  '                                    ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                               ||
                                   ' Change record type : ' ||'10 - Disbursement Notification / Change' ||
                                   ' Change code        : ' ||'C - Full or Partial Reinstatement '
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_DATE'              ,
             x_change_record_type_txt     => '10'                     ,
             x_change_code_txt            => 'C'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => l_d_resp_disb_date       ,
             x_new_date                   => l_d_new_disb_date        ,
             x_old_amt                    => NULL                     ,
             x_new_amt                    => NULL                     ,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'POST_DISB'              ,
             x_disbursement_cancel_date   => NULL                     ,
             x_disbursement_cancel_amt    => NULL                     ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => NULL                     ,
             x_disbursement_reinst_code   => 'Y'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => NULL                     ,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
           -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                         ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                               ||
                                   ' Change record type : ' ||'10 - Disbursement Notification / Change' ||
                                   ' Change code        : ' ||'C - Full or Partial Reinstatement '      ||
                                   ' new disb date      : ' || l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_new_disb_date                                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => l_d_new_disb_date                                   ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => l_d_new_disb_date                                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
              x_disbursement_revised_date  => l_d_new_disb_date                                   ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes have been reverted back
      ELSIF l_d_resp_disb_date = l_d_new_disb_date AND
            l_v_new_change_type_code = 'REINSTATEMENT'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not  '     ||
                                 ' cl version                : ' ||l_n_cl_version             ||
                                 ' loan status               : ' ||l_v_loan_status            ||
                                 ' Processing Type           : ' ||l_v_prc_type_code          ||
                                 ' Loan Record Status        : ' ||l_c_cl_rec_status          ||
                                 ' response disb date        : ' ||l_d_resp_disb_date         ||
                                 ' new reference of disb date: ' ||l_d_new_disb_date          ||
                                 ' fund status               : ' ||'Post Disbursement change' ||
                                 ' change type code          : ' || l_v_new_change_type_code  ||
                                 ' change_field_code         : ' || 'DISB_DATE'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_new_disb_dt '           ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''C'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_new_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record deleted  Successfully'  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for Change Type = Reinstatement
      -- end  of code logic for disbursement date change
      -- start of code logic for Change Type = Reissue
      -- start  of code logic for disbursement date change
      IF l_d_resp_disb_date <> l_d_new_disb_date AND
         l_v_new_change_type_code = 'REISSUE'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb date        : '||l_d_resp_disb_date         ||
                                 ' new reference of disb date: '||l_d_new_disb_date          ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '|| l_v_new_change_type_code  ||
                                 ' change_field_code         : '|| 'DISB_DATE'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_resp_disb_dt '          ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''B'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_resp_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' New Change record is Created  '                                    ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                               ||
                                   ' Change record type : ' ||'10 - Disbursement Notification / Change' ||
                                   ' Change code        : ' ||'B - Full or Partial Reissue '
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_DATE'              ,
             x_change_record_type_txt     => '10'                     ,
             x_change_code_txt            => 'B'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => l_d_resp_disb_date       ,
             x_new_date                   => l_d_new_disb_date        ,
             x_old_amt                    => NULL                     ,
             x_new_amt                    => NULL                     ,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'POST_DISB'              ,
             x_disbursement_cancel_date   => NULL                     ,
             x_disbursement_cancel_amt    => NULL                     ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => 'Y'                      ,
             x_disbursement_reinst_code   => 'N'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => l_v_fund_return_mthd_code,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
           -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                         ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                               ||
                                   ' Change record type : ' ||'10 - Disbursement Notification / Change' ||
                                   ' Change code        : ' ||'B - Full or Partial Reissue '            ||
                                   ' new disb date      : ' || l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_new_disb_date                                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => l_d_new_disb_date                                   ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => l_d_new_disb_date                                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
              x_disbursement_revised_date  => l_d_new_disb_date                                   ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes have been reverted back
      ELSIF l_d_resp_disb_date = l_d_new_disb_date AND
            l_v_new_change_type_code = 'REISSUE'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not  '     ||
                                 ' cl version                : ' ||l_n_cl_version             ||
                                 ' loan status               : ' ||l_v_loan_status            ||
                                 ' Processing Type           : ' ||l_v_prc_type_code          ||
                                 ' Loan Record Status        : ' ||l_c_cl_rec_status          ||
                                 ' response disb date        : ' ||l_d_resp_disb_date         ||
                                 ' new reference of disb date: ' ||l_d_new_disb_date          ||
                                 ' fund status               : ' ||'Post Disbursement change' ||
                                 ' change type code          : ' || l_v_new_change_type_code  ||
                                 ' change_field_code         : ' || 'DISB_DATE'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_new_disb_dt '           ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''B'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_new_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record deleted  Successfully'  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for Change Type = Reissue
      -- end  of code logic for disbursement date change
      -- start of code logic for Change Type = Cancellation
      -- start  of code logic for disbursement date change
      IF l_d_resp_disb_date <> l_d_new_disb_date AND
         l_v_new_change_type_code = 'CANCELLATION'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if existing change record is to be updated or inserted '||
                                 ' cl version                : '||l_n_cl_version             ||
                                 ' loan status               : '||l_v_loan_status            ||
                                 ' Processing Type           : '||l_v_prc_type_code          ||
                                 ' Loan Record Status        : '||l_c_cl_rec_status          ||
                                 ' response disb date        : '||l_d_resp_disb_date         ||
                                 ' new reference of disb date: '||l_d_new_disb_date          ||
                                 ' fund status               : '||'Post Disbursement change' ||
                                 ' change type code          : '|| l_v_new_change_type_code  ||
                                 ' change_field_code         : '|| 'DISB_DATE'
                  );
        -- verify if the existing change record is to be updated or inserted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_resp_disb_dt '          ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''A'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_resp_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%NOTFOUND THEN
          CLOSE c_igf_sl_clchsn_dtls;
          l_v_rowid       := NULL;
          l_n_clchgsnd_id := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' New Change record is Created  '                                    ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                               ||
                                   ' Change record type : ' ||'10 - Disbursement Notification / Change' ||
                                   ' Change code        : ' ||'A - Full or Partial Cancellation '
                    );
          igf_sl_clchsn_dtls_pkg.insert_row
          (
             x_rowid                      => l_v_rowid                ,
             x_clchgsnd_id                => l_n_clchgsnd_id          ,
             x_award_id                   => l_n_award_id             ,
             x_loan_number_txt            => l_v_loan_number          ,
             x_cl_version_code            => l_n_cl_version           ,
             x_change_field_code          => 'DISB_DATE'              ,
             x_change_record_type_txt     => '10'                     ,
             x_change_code_txt            => 'A'                      ,
             x_status_code                => 'R'                      ,
             x_status_date                => TRUNC(SYSDATE)           ,
             x_response_status_code       => NULL                     ,
             x_old_value_txt              => NULL                     ,
             x_new_value_txt              => NULL                     ,
             x_old_date                   => l_d_resp_disb_date       ,
             x_new_date                   => l_d_new_disb_date        ,
             x_old_amt                    => NULL                     ,
             x_new_amt                    => NULL                     ,
             x_disbursement_number        => l_n_disb_num             ,
             x_disbursement_date          => l_d_resp_disb_date       ,
             x_change_issue_code          => 'POST_DISB'              ,
             x_disbursement_cancel_date   => l_d_new_disb_date        ,
             x_disbursement_cancel_amt    => NULL                     ,
             x_disbursement_revised_amt   => l_n_new_disb_accepted_amt,
             x_disbursement_revised_date  => l_d_new_disb_date        ,
             x_disbursement_reissue_code  => NULL                     ,
             x_disbursement_reinst_code   => 'N'                      ,
             x_disbursement_return_amt    => NULL                     ,
             x_disbursement_return_date   => NULL                     ,
             x_disbursement_return_code   => l_v_fund_return_mthd_code,
             x_post_with_disb_return_amt  => NULL                     ,
             x_post_with_disb_return_date => NULL                     ,
             x_post_with_disb_return_code => NULL                     ,
             x_prev_with_disb_return_amt  => NULL                     ,
             x_prev_with_disb_return_date => NULL                     ,
             x_school_use_txt             => NULL                     ,
             x_lender_use_txt             => NULL                     ,
             x_guarantor_use_txt          => NULL                     ,
             x_validation_edit_txt        => NULL                     ,
             x_send_record_txt            => NULL
           );
           -- invoke validation edits to validate the change record. The validation checks if
           -- all the required fields are populated or not for a change record
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validating the Change record for Change send id: '  ||l_n_clchgsnd_id
                     );
           igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => l_n_clchgsnd_id,
                                           p_b_return_status => l_b_return_status,
                                           p_v_message_name  => l_v_message_name,
                                        p_t_message_tokens => l_d_message_tokens
                                           );
           IF NOT(l_b_return_status) THEN
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||l_n_clchgsnd_id
                      );
             RAISE e_valid_edits;
           END IF;
           p_b_return_status := TRUE;
           p_v_message_name  := NULL;
           log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                      p_v_string => ' validation of the Change record successful for Change send id: '  ||l_n_clchgsnd_id
                     );
        ELSE
          CLOSE c_igf_sl_clchsn_dtls;
          rec_c_igf_sl_clchsn_dtls := get_sl_clchsn_dtls ( p_rowid => l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec  ',
                     p_v_string => ' Change record is updated '                                         ||
                                   ' Change_field_code  : ' ||'DISB_DATE'                               ||
                                   ' Change record type : ' ||'10 - Disbursement Notification / Change' ||
                                   ' Change code        : ' ||'A - Full or Partial Cancellation '       ||
                                   ' new disb date      : ' || l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.update_row
          (
            x_rowid                      => l_v_rowid                                           ,
            x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
            x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
            x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
            x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
            x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
            x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
            x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
            x_status_code                => 'R'                                                 ,
            x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
            x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
            x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
            x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
            x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
            x_new_date                   => l_d_new_disb_date                                   ,
            x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
            x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
            x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
            x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
            x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
            x_disbursement_cancel_date   => TRUNC(SYSDATE)                                      ,
            x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
            x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
            x_disbursement_revised_date  => l_d_new_disb_date                                   ,
            x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
            x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
            x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
            x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
            x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
            x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
            x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
            x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
            x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
            x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
            x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
            x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
            x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
            x_validation_edit_txt        => NULL                                                ,
            x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
          );
          -- invoke validation edits to validate the change record. The validation checks if
          -- all the required fields are populated or not for a change record
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validating the Change record for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
          l_v_message_name  := NULL;
          l_b_return_status := TRUE;
          igf_sl_cl_chg_prc.validate_chg (p_n_clchgsnd_id   => rec_c_igf_sl_clchsn_dtls.clchgsnd_id,
                                          p_b_return_status => l_b_return_status,
                                          p_v_message_name  => l_v_message_name,
                                          p_t_message_tokens => l_d_message_tokens
                                          );

          IF NOT(l_b_return_status) THEN
            -- substring of the out bound parameter l_v_message_name is carried
            -- out since it can expect either IGS OR IGF message
            fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
            igf_sl_cl_chg_prc.parse_tokens(
              p_t_message_tokens => l_d_message_tokens);
/*
            FOR token_counter IN l_d_message_tokens.FIRST..l_d_message_tokens.LAST LOOP
               fnd_message.set_token(l_d_message_tokens(token_counter).token_name, l_d_message_tokens(token_counter).token_value);
            END LOOP;
*/
            log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                       p_v_string => ' validation of the Change record failed for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                       );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' Invoking igf_sl_clchsn_dtls_pkg.update_row to update the status to Not Ready to Send'
                       );
            igf_sl_clchsn_dtls_pkg.update_row
            (
              x_rowid                      => l_v_rowid                                           ,
              x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
              x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
              x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
              x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
              x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
              x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
              x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
              x_status_code                => 'N'                                                 ,
              x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
              x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
              x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
              x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
              x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
              x_new_date                   => l_d_new_disb_date                                   ,
              x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
              x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
              x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
              x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
              x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
              x_disbursement_cancel_date   => TRUNC(SYSDATE)                                      ,
              x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
              x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
              x_disbursement_revised_date  => l_d_new_disb_date                                   ,
              x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
              x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
              x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
              x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
              x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
              x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
              x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
              x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
              x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
              x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
              x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
              x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
              x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
              x_validation_edit_txt        => fnd_message.get                                     ,
              x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt
            );
            log_to_fnd(p_v_module => ' create_disb_chg_rec',
                       p_v_string => ' updated the status of change send record to Not Ready to Send'
                      );
          END IF;
          p_b_return_status := TRUE;
          p_v_message_name  := NULL;
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' validation of the Change record successful for Change send id: '  ||rec_c_igf_sl_clchsn_dtls.clchgsnd_id
                    );
        END IF;
      -- if changes have been reverted back
      ELSIF l_d_resp_disb_date = l_d_new_disb_date AND
            l_v_new_change_type_code = 'CANCELLATION'
      THEN
        log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                   p_v_string => ' Verifying if  change record is to be deleted or not  '     ||
                                 ' cl version                : ' ||l_n_cl_version             ||
                                 ' loan status               : ' ||l_v_loan_status            ||
                                 ' Processing Type           : ' ||l_v_prc_type_code          ||
                                 ' Loan Record Status        : ' ||l_c_cl_rec_status          ||
                                 ' response disb date        : ' ||l_d_resp_disb_date         ||
                                 ' new reference of disb date: ' ||l_d_new_disb_date          ||
                                 ' fund status               : ' ||'Post Disbursement change' ||
                                 ' change type code          : ' || l_v_new_change_type_code  ||
                                 ' change_field_code         : ' || 'DISB_DATE'
                  );
        -- verify if the existing change record is to be deleted
        l_v_sqlstmt := 'SELECT  chdt.ROWID row_id '                          ||
                       'FROM   igf_sl_clchsn_dtls chdt '                     ||
                       'WHERE  chdt.award_id = :cp_n_award_id '              ||
                       'AND    chdt.disbursement_number = :cp_n_dib_num '    ||
                       'AND    chdt.old_date = :cp_d_new_disb_dt '           ||
                       'AND    chdt.change_field_code = ''DISB_DATE'' '      ||
                       'AND    chdt.change_code_txt = ''A'' '                ||
                       'AND    chdt.status_code IN (''R'',''N'',''D'') '     ||
                       'AND    chdt.change_record_type_txt = ''10'' ';

        OPEN  c_igf_sl_clchsn_dtls FOR l_v_sqlstmt USING l_n_award_id,l_n_disb_num,l_d_new_disb_date;
        FETCH c_igf_sl_clchsn_dtls INTO l_v_rowid;
        IF c_igf_sl_clchsn_dtls%FOUND THEN
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record to be deleted '  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  l_v_rowid);
          log_to_fnd(p_v_module => ' create_disb_chg_rec ',
                     p_v_string => ' Change record deleted  Successfully'  ||
                                   ' Award Id     : '||l_n_award_id ||
                                   ' Disb Num     : '||l_n_disb_num ||
                                   ' New disb Date: '||l_d_new_disb_date
                    );
        END IF;
        CLOSE c_igf_sl_clchsn_dtls;
        p_b_return_status := TRUE;
        p_v_message_name  := NULL;
      END IF;
      -- end of code logic for Change Type = Cancellation
      -- end  of code logic for disbursement date change
    END IF;
    -- end of code logic for post disbursement changes (@10)
  END IF;

EXCEPTION
  WHEN e_resource_busy THEN
    ROLLBACK TO igf_sl_cl_create_chg_disb_sp;
    log_to_fnd(p_v_module => ' Procedure create_disb_chg_rec:  e resource busy exception',
               p_v_string => SQLERRM
               );
    p_b_return_status := FALSE;
    p_v_message_name  := 'IGS_GE_RECORD_LOCKED';
    RETURN;
  WHEN e_valid_edits THEN
    ROLLBACK TO igf_sl_cl_create_chg_disb_sp;
    log_to_fnd(p_v_module => 'Procedure create_disb_chg_rec: validation edits exception handler',
               p_v_string => ' change record validation raised errors '||l_v_message_name
              );
    p_b_return_status := FALSE;
    p_v_message_name  := l_v_message_name;
    igf_sl_cl_chg_prc.g_message_tokens := l_d_message_tokens;
    RETURN;
  WHEN OTHERS THEN
    ROLLBACK TO igf_sl_cl_create_chg_disb_sp;
    log_to_fnd(p_v_module => 'Procedure create_disb_chg_rec: when others exception handler',
               p_v_string => SQLERRM
              );
    fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_cl_create_chg.create_disb_chg_rec');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END create_disb_chg_rec;

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
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_sl_cl_create_chg.'||p_v_module, p_v_string);
  END IF;
END log_to_fnd;

FUNCTION get_sl_clchsn_dtls ( p_rowid ROWID)
RETURN igf_sl_clchsn_dtls%ROWTYPE AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 18 October 2004
--
-- Purpose:
-- Invoked     : from within procedures in this package
-- Function    : Private procedure which returns igf_sl_clchsn_dtls%ROWTYPE
--
-- Parameters  : p_rowid   : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
  CURSOR c_sl_clchsn_dtls (cp_rowid ROWID) IS
  SELECT chdt.*
  FROM   igf_sl_clchsn_dtls chdt
  WHERE  rowid = p_rowid;

  rec_sl_clchsn_dtls c_sl_clchsn_dtls%ROWTYPE;
BEGIN
  OPEN  c_sl_clchsn_dtls (cp_rowid => p_rowid);
  FETCH c_sl_clchsn_dtls  INTO rec_sl_clchsn_dtls ;
  CLOSE c_sl_clchsn_dtls  ;
  RETURN rec_sl_clchsn_dtls;
END get_sl_clchsn_dtls;

END igf_sl_cl_create_chg;

/
