--------------------------------------------------------
--  DDL for Package Body IGF_SE_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SE_GEN_001" AS
/* $Header: IGFSE01B.pls 120.7 2006/02/01 02:56:25 ridas ship $ */

  PROCEDURE display_auth_params(p_awd_cal_type  IN  igs_ca_inst.cal_type%TYPE,
                                p_awd_seq_num   IN  igs_ca_inst.sequence_number%TYPE,
                                p_fund_id       IN  igf_aw_fund_mast_all.fund_id%TYPE,
                                p_base_id       IN  igf_ap_fa_base_rec_all.base_id%TYPE
                               ) IS
    ------------------------------------------------------------------------------------
    --Created by   : brajendr
    --Date created : 16-May-2002
    --Purpose      :  Displays all the paramters which are passed into the Job
    --Known limitations/enhancements and/or remarks:
    --Change History:
    --Who         When            What
    --ridas       29/Jul/2005     Bug #3536039. Raise exception IGFSEGEN001 if p_call = 'LEGACY' in procedure SEND_WORK_AUTH
    --veramach    July 2004       Bug #3709292 Parameters are printed only if the value is not null
    --cdcruz      14/Jan/2004     Logging Messges added to track Bug# 3346948
    --                            No check was present for First/Last Name, the same has been done
    --rasingh     6/Jan/2003      Performance Tuning Fixes: 2620242,2620259,2620264
    -------------------------------------------------------------------------------------

    --Cursor to find the User Parameter Award Year (which is same as Alternate Code) to display in the Log
    CURSOR c_alternate_code(cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                            cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE)   IS
       SELECT alternate_code
         FROM igs_ca_inst
        WHERE cal_type        = cp_ci_cal_type
          AND sequence_number = cp_ci_sequence_number;

    CURSOR c_get_parameters IS
       SELECT meaning, lookup_code
         FROM igf_lookups_view
        WHERE lookup_type='IGF_GE_PARAMETERS'
          AND lookup_code IN ('AWARD_YEAR','FUND_CODE','PERSON_NUMBER','PARAMETER_PASS');

    CURSOR c_person_dtls (c_base_id  igf_ap_fa_base_rec_all.base_id%TYPE) IS
       SELECT party_number
         FROM hz_parties hz,
              igf_ap_fa_base_rec_all fa
        WHERE fa.person_id = hz.party_id
          AND fa.base_id   = c_base_id;

    CURSOR c_fund_dtls (c_fund_id  igf_aw_fund_mast_all.fund_id%TYPE) IS
       SELECT fund_code
         FROM igf_aw_fund_mast
        WHERE fund_id = c_fund_id;

    parameter_rec         c_get_parameters%ROWTYPE;
    l_award_year          igf_lookups_view.meaning%TYPE;
    l_fund_code           igf_lookups_view.meaning%TYPE;
    l_person_number       igf_lookups_view.meaning%TYPE;
    l_para_pass           igf_lookups_view.meaning%TYPE;
    l_awd_alternate_code  igs_ca_inst.alternate_code%TYPE := NULL;
    l_fund_id             igf_aw_fund_mast_all.fund_code%TYPE := NULL;
    l_base_id             igs_pe_person.person_number%TYPE := NULL;

  BEGIN

    -- Get all the Parameters
    OPEN c_get_parameters;
    LOOP
      FETCH c_get_parameters INTO  parameter_rec;
      EXIT WHEN c_get_parameters%NOTFOUND;
      IF parameter_rec.lookup_code ='AWARD_YEAR' THEN
         l_award_year := TRIM(parameter_rec.meaning);
      ELSIF parameter_rec.lookup_code ='FUND_CODE' THEN
         l_fund_code := TRIM(parameter_rec.meaning);
      ELSIF parameter_rec.lookup_code ='PERSON_NUMBER' THEN
         l_person_number := TRIM(parameter_rec.meaning);
      ELSIF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
         l_para_pass := TRIM(parameter_rec.meaning);
      END IF;
    END LOOP;
    CLOSE c_get_parameters;

    -- Get the Award Year Alternate Code
    OPEN  c_alternate_code(p_awd_cal_type,p_awd_seq_num);
    FETCH c_alternate_code INTO l_awd_alternate_code;
    CLOSE c_alternate_code;

    -- Get the Load Calendar Alternate Code
    OPEN  c_person_dtls(p_base_id);
    FETCH c_person_dtls INTO l_base_id;
    CLOSE c_person_dtls;

    -- Get the Load Calendar Alternate Code
    OPEN  c_fund_dtls(p_fund_id);
    FETCH c_fund_dtls INTO l_fund_id;
    CLOSE c_fund_dtls;

    /* Print the Parameters Passed */
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,l_para_pass); --------------Parameters Passed--------------
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    IF l_awd_alternate_code IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_award_year,30)    || ' : '|| l_awd_alternate_code);
    END IF;
    IF l_fund_id IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_fund_code,30)     || ' : '|| l_fund_id);
    END IF;
    IF l_base_id IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_person_number,30) || ' : '|| l_base_id);
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

  END display_auth_params;


  PROCEDURE display_auth_process_log(p_person_number  IN  igs_pe_person.person_number%TYPE,
                                     p_fund_code      IN  igf_aw_fund_mast_all.fund_code%TYPE,
                                     p_award_id       IN  igf_aw_award_v.award_id%TYPE
                                    ) IS
    ------------------------------------------------------------------------------------
    --Created by   : brajendr
    --Date created : 16-May-2002
    --Purpose      :  Displays all the paramters which are passed into the Job
    --Known limitations/enhancements and/or remarks:
    --Change History:
    -- Who         When            What
    --veramach     July 2004      Bug #3709292 Parameters are printed only if the value is not null
    -- masehgal    228-dec-2002    # 2445830  Changed log to display the load calendar and
    --                             award id to make it less ambiguous.
    -------------------------------------------------------------------------------------

    CURSOR c_get_parameters IS
       SELECT meaning, lookup_code
         FROM igf_lookups_view
        WHERE lookup_type = 'IGF_GE_PARAMETERS'
          AND lookup_code IN ('FUND_CODE','PERSON_NUMBER','AWARD_ID');

    parameter_rec    c_get_parameters%ROWTYPE;
    l_fund_code      igf_lookups_view.meaning%TYPE;
    l_person_number  igf_lookups_view.meaning%TYPE;
    l_award_id       igf_lookups_view.meaning%TYPE;

  BEGIN

    -- Get all the Parameters
    OPEN c_get_parameters;
    LOOP
      FETCH c_get_parameters INTO  parameter_rec;
      EXIT WHEN c_get_parameters%NOTFOUND;
      IF parameter_rec.lookup_code ='FUND_CODE' THEN
         l_fund_code := TRIM(parameter_rec.meaning);
      ELSIF parameter_rec.lookup_code ='PERSON_NUMBER' THEN
         l_person_number := TRIM(parameter_rec.meaning);
      ELSIF parameter_rec.lookup_code ='AWARD_ID' THEN
         l_award_id := TRIM(parameter_rec.meaning);
      END IF;
    END LOOP;
    CLOSE c_get_parameters;

    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    IF p_person_number IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_person_number,30) || ' : '||p_person_number);
    END IF;

    IF p_fund_code IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_fund_code,30)     || ' : '||p_fund_code);
    END IF;

    IF p_award_id IS NOT NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_award_id,30)      || ' : '||p_award_id);
    END IF;

  END display_auth_process_log;


  PROCEDURE display_payroll_params(p_batch_id        IN  igf_se_payment_int.batch_id%TYPE,
                                   p_auth_id         IN  igf_se_auth.auth_id%TYPE,
                                   p_validation_lvl  IN  VARCHAR2
                                  ) IS
    ------------------------------------------------------------------------------------
    --Created by   : brajendr
    --Date created : 16-May-2002
    --Purpose      :  Displays all the paramters which are passed into the Job
    --Known limitations/enhancements and/or remarks:
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------------------------

    --Cursor to find the User Parameter Award Year (which is same as Alternate Code) to display in the Log
    CURSOR c_get_parameters IS
       SELECT meaning, lookup_code
         FROM igf_lookups_view
        WHERE lookup_type='IGF_GE_PARAMETERS'
          AND lookup_code IN ('BATCH_ID','AUTH_ID','VALIDATION_LVL','PARAMETER_PASS');

    parameter_rec       c_get_parameters%ROWTYPE;
    l_batch_id          igf_lookups_view.meaning%TYPE;
    l_auth_id           igf_lookups_view.meaning%TYPE;
    l_validation_lvl    igf_lookups_view.meaning%TYPE;
    l_para_pass         igf_lookups_view.meaning%TYPE;

  BEGIN

    -- Get all the Parameters
    OPEN c_get_parameters;
    LOOP
     FETCH c_get_parameters INTO  parameter_rec;
     EXIT WHEN c_get_parameters%NOTFOUND;

     IF parameter_rec.lookup_code ='BATCH_ID' THEN
        l_batch_id := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='AUTH_ID' THEN
        l_auth_id := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='VALIDATION_LVL' THEN
        l_validation_lvl := TRIM(parameter_rec.meaning);

     ELSIF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
        l_para_pass := TRIM(parameter_rec.meaning);

     END IF;

    END LOOP;
    CLOSE c_get_parameters;

    -- Print the Parameters Passed
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,l_para_pass); --------------Parameters Passed--------------
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_batch_id,30)       || ' : '|| p_batch_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_auth_id,30)        || ' : '|| p_auth_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_validation_lvl,30) || ' : '|| p_validation_lvl);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

  END display_payroll_params;


  PROCEDURE send_work_auth(p_base_id      IN  igf_ap_fa_base_rec.base_id%TYPE,
                           p_person_id    IN  hz_parties.party_id%TYPE,
                           p_fund_id      IN  igf_aw_fund_mast.fund_id%TYPE,
                           p_award_id     IN  igf_aw_award.award_id%TYPE,
                           p_ld_cal_type  IN  igs_ca_inst.cal_type%TYPE,
                           p_ld_seq_no    IN  igs_ca_inst.sequence_number%TYPE,
                           p_call         IN  VARCHAR2,
                           p_auth_date    IN DATE
                          ) IS
  ------------------------------------------------------------------------------------
  -- Created by  : ssawhney ( Oracle IDC)
  -- Date created: 2nd jan
  -- Purpose: This procedure will be used to create work authorizations for a student
  --          for an award and for a term. The authorization details will be used by Student
  --          Employment module to pass to the external/legacy HR system
  --
  -- Known limitations/enhancements and/or remarks:
  -- Change History:
  -- Who         When            What
  --veramach     July 2004       FA 151 HR Integration (Bug# 3709292) Changes
  --                             New parameter(AUTH_DATE) added
  -- brajendr    03-Jun-2002     Changed the where clause from the Cursor c_awd. Now the
  --                             cursor will pick all the records.
  --                             Added one more Validation, SSN is a mandatory for all
  --                             FWS awarded students.
  -------------------------------------------------------------------------------------

    CURSOR c_fund_mast ( cv_fund_id  igf_aw_fund_mast.fund_id%TYPE) IS
       SELECT threshold_perct, threshold_value
         FROM igf_aw_fund_mast
        WHERE fund_id = cv_fund_id;

    CURSOR c_awd (cv_fund_id   igf_aw_fund_mast.fund_id%TYPE,
                  cv_award_id  igf_aw_award.award_id%TYPE,
                  cv_base_id   igf_ap_fa_base_rec.base_id%TYPE ) IS
    SELECT pit.api_person_id ssn,
           fmast.ci_cal_type,
           fmast.ci_sequence_number,
           awd.base_id,
           awd.award_id
      FROM igf_aw_award awd,
           igf_aw_fund_cat fcat,
           igf_aw_fund_mast fmast,
           igf_ap_fa_base_rec farec,
           igs_pe_alt_pers_id_v pit,
	         igs_pe_person_id_typ pit_2
     WHERE awd.fund_id = fmast.fund_id
       AND awd.base_id = cv_base_id
       AND awd.base_id = farec.base_id
       AND fcat.fund_code = fmast.fund_code
       AND fcat.fed_fund_code = 'FWS'
       AND awd.fund_id = cv_fund_id
       AND awd.award_id = cv_award_id
       AND farec.person_id =  pit.pe_person_id (+)
       AND pit.person_id_type = pit_2.person_id_type
       AND pit_2.s_person_id_type = 'SSN'
       AND SYSDATE BETWEEN pit.start_dt AND NVL(pit.end_dt, SYSDATE);

    -- Cursor used to get the Language transulated tokens
    CURSOR c_get_tokens IS
       SELECT meaning, lookup_code
         FROM igf_lookups_view
        WHERE lookup_type = 'IGF_MATCH_CRITERIA'
          AND lookup_code = 'SSN';

    CURSOR c_hzp (cv_person_id     hz_parties.party_id%TYPE ) IS
    SELECT person_first_name, person_last_name, address1, address2, address3, address4, city,
           state, province, county, country
      FROM hz_parties
     WHERE party_id = cv_person_id;

    CURSOR c_pe (cv_person_id  hz_parties.party_id%TYPE ) IS
    SELECT gender sex, birth_date birth_dt
      FROM igs_pe_person_base_v
     WHERE person_id = cv_person_id;

    CURSOR c_visa (cv_person_id      hz_parties.party_id%TYPE ) IS
    SELECT a.visa_type,a.visa_category,a.visa_number,a.visa_expiry_date, b.visit_start_date entry_date
      FROM igs_pe_visa a,igs_pe_visit_histry b
     WHERE a.person_id = cv_person_id
       AND NVL(a.visa_expiry_date,SYSDATE) >= SYSDATE
       AND a.visa_id = b.visa_id
     ORDER BY a.visa_expiry_date DESC;

    CURSOR c_stat (cv_person_id      hz_parties.party_id%TYPE ) IS
       SELECT NVL(marital_status,'NA') marital_status
         FROM HZ_PERSON_PROFILES
        WHERE party_id = cv_person_id
          AND SYSDATE BETWEEN EFFECTIVE_START_DATE AND NVL(EFFECTIVE_END_DATE, SYSDATE);

    CURSOR c_accept_amnt(
                         cp_award_id  igf_aw_award_all.award_id%TYPE
                        ) IS
    SELECT NVL(awd.accepted_amt,0) accepted_amt
      FROM igf_aw_award awd
     WHERE awd.award_id = cp_award_id;

    CURSOR c_next_auth IS
       SELECT igf_se_auth_s1.NEXTVAL
         FROM dual;

    CURSOR c_auth_check(cv_award_id         igf_aw_award.award_id%TYPE,
                        cv_ld_cal_type      igs_ca_inst.cal_type%TYPE,
                        cv_ld_seq_no        igs_ca_inst.sequence_number%TYPE
                       ) IS
       SELECT auth_id
         FROM igf_se_auth
        WHERE award_id = cv_award_id
          AND auth_id IS NOT NULL
          AND flag = 'A';


    CURSOR c_old_auth (cv_auth_id igf_se_auth.auth_id%TYPE) IS
       SELECT rowid, sai.*
         FROM igf_se_auth sai
        WHERE sai.auth_id = cv_auth_id
          AND sai.flag ='A'
          FOR UPDATE NOWAIT;

    next_record              EXCEPTION;
    visa_details_not_found   EXCEPTION;

    fund_mast_rec    c_fund_mast%ROWTYPE;
    awd_rec          c_awd%ROWTYPE;
    hzp_rec          c_hzp%ROWTYPE;
    pe_rec           c_pe%ROWTYPE;
    visa_rec         c_visa%ROWTYPE;
    stat_rec         c_stat%ROWTYPE;
    accept_amnt_rec  c_accept_amnt%ROWTYPE;
    auth_check_rec   c_auth_check%ROWTYPE;
    old_auth_rec     c_old_auth%ROWTYPE;
    tokens_rec       c_get_tokens%ROWTYPE;

    l_place          VARCHAR2(30);
    l_person_id      hz_parties.party_id%TYPE;
    l_fund_id        igf_aw_fund_mast.fund_id%TYPE;
    l_ld_cal_type    igs_ca_inst.cal_type%TYPE;
    l_ld_seq_no      igs_ca_inst.sequence_number%TYPE;
    l_auth_id        igf_se_auth.auth_id%TYPE := 0;
    l_sequence_no    igf_se_auth.sequence_no%TYPE := 0;
    l_rowid          VARCHAR2(30) := 0;
    l_visa_type      igf_se_auth.visa_type%TYPE;
    l_visa_category  igf_se_auth.visa_category%TYPE;
    l_visa_number    igf_se_auth.visa_number%TYPE;
    l_visa_expiry_dt igf_se_auth.visa_expiry_dt%TYPE;
    l_entry_date     igf_se_auth.entry_date%TYPE;
    l_warning        VARCHAR2(200);

    PROCEDURE insert_auth IS
    --------------------------------------------------------
    --Created by : ssawhney on 2nd Jan
    --Purpose : local procedure to insert into igf_se_auth table
    --Change History :
    --Who         When            What
    ----------------------------------------------------------------
      l_rowid          VARCHAR2(30);
      l_sequence_no    igf_se_auth.sequence_no%TYPE;
    BEGIN
      -- insert a new auth rec

      l_rowid       := NULL;
      l_sequence_no := NULL;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_flag                 =>' || 'A');
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_person_id            =>' || l_person_id);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_first_name           =>' || hzp_rec.person_first_name);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_last_name            =>' || hzp_rec.person_last_name);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_address1             =>' || NVL(hzp_rec.address1,'NA'));
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_address2             =>' || hzp_rec.address2);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_address3             =>' || hzp_rec.address3);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_address4             =>' || hzp_rec.address4);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_city                 =>' || hzp_rec.city);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_state                =>' || hzp_rec.state);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_province             =>' || hzp_rec.province);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_county               =>' || hzp_rec.county);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_country              =>' || hzp_rec.country);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_sex                  =>' || pe_rec.sex);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_birth_dt             =>' || NVL(pe_rec.birth_dt,SYSDATE));
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_ssn_no               =>' || awd_rec.ssn);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_marital_status       =>' || NVL(stat_rec.marital_status,'NA'));
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_visa_type            =>' || l_visa_type);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_visa_category        =>' || l_visa_category);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_visa_number          =>' || l_visa_number);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_visa_expiry_dt       =>' || l_visa_expiry_dt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_entry_date           =>' || l_entry_date);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_fund_id              =>' || l_fund_id);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_threshold_perct      =>' || fund_mast_rec.threshold_perct);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_threshold_value      =>' || fund_mast_rec.threshold_value);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_accepted_amnt        =>' || accept_amnt_rec.accepted_amt);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_aw_cal_type          =>' || awd_rec.ci_cal_type);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_aw_sequence_number   =>' || awd_rec.ci_sequence_number);
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth','x_award_id             =>' || awd_rec.award_id);
         END IF;


      igf_se_auth_pkg.insert_row(
                                 x_rowid                => l_rowid,
                                 x_sequence_no          => l_sequence_no,
                                 x_auth_id              => l_auth_id,
                                 x_flag                 => 'A',  -- this is the active record now.
                                 x_person_id            => l_person_id,
                                 x_first_name           => hzp_rec.person_first_name,
                                 x_last_name            => hzp_rec.person_last_name,
                                 x_address1             => NVL(hzp_rec.address1,'NA'),
                                 x_address2             => hzp_rec.address2,
                                 x_address3             => hzp_rec.address3,
                                 x_address4             => hzp_rec.address4,
                                 x_city                 => hzp_rec.city,
                                 x_state                => hzp_rec.state,
                                 x_province             => hzp_rec.province,
                                 x_county               => hzp_rec.county,
                                 x_country              => hzp_rec.country,
                                 x_sex                  => pe_rec.sex,
                                 x_birth_dt             => NVL(pe_rec.birth_dt,SYSDATE),
                                 x_ssn_no               => awd_rec.ssn,
                                 x_marital_status       => NVL(stat_rec.marital_status,'NA'),
                                 x_visa_type            => l_visa_type,
                                 x_visa_category        => l_visa_category,
                                 x_visa_number          => l_visa_number,
                                 x_visa_expiry_dt       => l_visa_expiry_dt,
                                 x_entry_date           => l_entry_date,
                                 x_fund_id              => l_fund_id,
                                 x_threshold_perct      => fund_mast_rec.threshold_perct,
                                 x_threshold_value      => fund_mast_rec.threshold_value,
                                 x_accepted_amnt        => accept_amnt_rec.accepted_amt,
                                 x_aw_cal_type          => awd_rec.ci_cal_type,
                                 x_aw_sequence_number   => awd_rec.ci_sequence_number,
                                 x_award_id             => awd_rec.award_id,
                                 x_authorization_date   => SYSDATE,
                                 x_notification_date    => NULL
                                );

    EXCEPTION
      WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_se_gen_001.send_work_auth.insert_auth',' Unhandled Exception ->' || SQLERRM);
    END IF;

        FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.send_work_auth:igf_se_auth.insert') ;
        IGS_GE_MSG_STACK.ADD;

        IF p_call = 'JOB' THEN -- continue for next student dont stop
          RAISE NEXT_RECORD; -- user defined exception
        ELSE -- this means its called from FORM
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

    END insert_auth;

    -- begin the main procedure.
    BEGIN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth',
      'Parameters p_base_id->'|| TO_CHAR(p_base_id) ||
                  ' p_person_id'|| TO_CHAR(p_person_id) ||
                  ' p_fund_id'|| TO_CHAR(p_fund_id) ||
                  ' p_award_id'|| TO_CHAR(p_award_id) ||
                  ' p_call'|| p_call);
    END IF;

      l_person_id   := p_person_id ;
      l_fund_id     := p_fund_id;

      -- check all the parameters are NOT NULL
      IF (l_person_id IS NULL)
      OR (l_fund_id IS NULL) THEN

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth',' Parameter Error');
         END IF;

         FND_MESSAGE.SET_NAME('IGF','IGF_AW_PARAM_ERR');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      -- get fund setup details.
      OPEN  c_fund_mast (l_fund_id);
      FETCH c_fund_mast INTO fund_mast_rec;

      IF c_fund_mast%NOTFOUND THEN
        CLOSE c_fund_mast;
        l_place :='FUND';
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c_fund_mast;

      -- get award set up details
      OPEN  c_awd (l_fund_id, p_award_id, p_base_id);
      FETCH c_awd INTO awd_rec;
        IF awd_rec.ssn IS NULL THEN
           l_place :='SSN';
           CLOSE c_awd;
           RAISE NO_DATA_FOUND;
        END IF;
      CLOSE c_awd;

      -- get person specific details
      OPEN  c_hzp (l_person_id);
      FETCH c_hzp INTO hzp_rec;

      IF c_hzp%NOTFOUND THEN
         CLOSE c_hzp;
         l_place :='HZ';
         RAISE no_data_found;
      END IF;
      CLOSE c_hzp;

      OPEN  c_pe (l_person_id);
      FETCH c_pe INTO pe_rec;
      IF c_pe%NOTFOUND THEN
         CLOSE c_pe;
         l_place :='PE';
         RAISE no_data_found;
      END IF;
      CLOSE c_pe;

      IF  hzp_rec.person_first_name IS NULL THEN
         l_place :='F_NAME';
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth',' First Name is null');
         END IF;
         RAISE no_data_found;
      END IF;

      IF  hzp_rec.person_last_name IS NULL THEN
         l_place :='L_NAME';
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth',' Last Name is null');
         END IF;
         RAISE no_data_found;
      END IF;

      IF  hzp_rec.country IS NULL THEN
         l_place :='COUNTRY';
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_se_gen_001.send_work_auth',' Country is null');
         END IF;
         RAISE no_data_found;
      END IF;

      -- get visa details
      OPEN  c_visa (l_person_id);
      FETCH c_visa INTO visa_rec;

      -- Visa Details are not necessary for US residents / citizens
      IF c_visa%NOTFOUND AND (hzp_rec.country IS NULL OR hzp_rec.country <> 'US' ) AND  p_call <> 'LEGACY' THEN
         CLOSE c_visa;
         l_place :='VISA';
         RAISE no_data_found;
      ELSIF c_visa%FOUND THEN
         l_visa_type      := visa_rec.visa_type;
         l_visa_category  := visa_rec.visa_category;
         l_visa_number    := visa_rec.visa_number;
         l_visa_expiry_dt := visa_rec.visa_expiry_date;
         l_entry_date     := visa_rec.entry_date;

      END IF;
      CLOSE c_visa;

      -- get marital details
      OPEN  c_stat (l_person_id);
      FETCH c_stat INTO stat_rec;
      IF c_stat%NOTFOUND THEN
         CLOSE c_stat;
         l_place :='MARITAL';
         RAISE no_data_found;
      END IF;
      CLOSE c_stat;

      -- get the accepted amount by the student for the term.
      OPEN  c_accept_amnt(p_award_id);
      FETCH c_accept_amnt INTO accept_amnt_rec;
      CLOSE c_accept_amnt;

      -- check if the authorization rec is new
      BEGIN
      -- start for auth creation
      -- issue a save point.

        SAVEPOINT se_payment;

        l_auth_id :=NULL;
        OPEN  c_auth_check(awd_rec.award_id,l_ld_cal_type,l_ld_seq_no);
        FETCH c_auth_check INTO l_auth_id;

        -- if auth is not present then it means its a new rec
        IF c_auth_check%NOTFOUND THEN

          -- get the next auth_id from the sequence no
          OPEN  c_next_auth;
          FETCH c_next_auth INTO l_auth_id;
          CLOSE c_next_auth;

          -- insert a new auth rec
          insert_auth ;

          CLOSE c_auth_check;

        ELSE  -- this means that auth_id is present and l_auth_id will have a value in this case

          -- get the record of the interface table which has the FLAG=A and update it as INACTIVE
          -- update the old record which was ACTIVE. There should only be one such rec.

          OPEN  c_old_auth (l_auth_id);
          FETCH c_old_auth INTO old_auth_rec;
          CLOSE c_old_auth;

          BEGIN

            igf_se_auth_pkg.update_row (
                                        old_auth_rec.rowid,
                                        old_auth_rec.sequence_no,
                                        old_auth_rec.auth_id,
                                        'I',   -- this record is inactive now
                                        old_auth_rec.person_id,
                                        old_auth_rec.first_name,
                                        old_auth_rec.last_name,
                                        old_auth_rec.address1,
                                        old_auth_rec.address2,
                                        old_auth_rec.address3,
                                        old_auth_rec.address4,
                                        old_auth_rec.city,
                                        old_auth_rec.state,
                                        old_auth_rec.province,
                                        old_auth_rec.county,
                                        old_auth_rec.country,
                                        old_auth_rec.sex,
                                        old_auth_rec.birth_dt,
                                        old_auth_rec.ssn_no,
                                        old_auth_rec.marital_status,
                                        old_auth_rec.visa_type,
                                        old_auth_rec.visa_category,
                                        old_auth_rec.visa_number,
                                        old_auth_rec.visa_expiry_dt,
                                        old_auth_rec.entry_date,
                                        old_auth_rec.fund_id,
                                        old_auth_rec.threshold_perct,
                                        old_auth_rec.threshold_value,
                                        old_auth_rec.accepted_amnt,
                                        old_auth_rec.aw_cal_type,
                                        old_auth_rec.aw_sequence_number,
                                        'R',
                                        old_auth_rec.award_id,
                                        old_auth_rec.authorization_date,
                                        old_auth_rec.notification_date
                                       );

            -- insert a new auth rec with the updated information in the igf_se_auth table.
            -- this will be the active record now.
            insert_auth;

          EXCEPTION
            WHEN OTHERS THEN
              IF c_auth_check%ISOPEN THEN
                 CLOSE c_auth_check;
              END IF;

              FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
              FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.send_work_auth:igf_se_auth.update');
              IGS_GE_MSG_STACK.ADD;

              IF p_call = 'JOB' THEN -- continue for next student dont stop
                 RAISE next_record; -- user defined exception
              ELSE -- this means its called from FORM
                 app_exception.raise_exception;
              END IF;
          END;
        END IF;

        IF c_auth_check%ISOPEN THEN
           CLOSE c_auth_check;
        END IF;

      EXCEPTION  -- for auth creation
        WHEN next_record THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
           ROLLBACK TO se_payment;
      END ; -- for auth generation

      IF p_call IN ('JOB','SE003') THEN
        /*
          If called from AW016, COMMIT should not be issued.
        */
        COMMIT; --Committing the Transaction
        fnd_message.set_name('IGF','IGF_SE_REQUERY_AUTH');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;

    EXCEPTION -- for main block
      WHEN no_data_found THEN

       FND_MESSAGE.SET_NAME('IGF','IGF_SE_INVALID_SETUP');
       IF l_place = 'FUND' THEN
          FND_MESSAGE.SET_TOKEN('PLACE','FUND');
       ELSIF l_place = 'HZ' THEN
          FND_MESSAGE.SET_TOKEN('PLACE','HZ:PERSON');
       ELSIF l_place = 'PE' THEN
          FND_MESSAGE.SET_TOKEN('PLACE','PERSON');
       ELSIF l_place = 'VISA' THEN
          FND_MESSAGE.SET_TOKEN('PLACE','VISA');

       ELSIF l_place = 'COUNTRY' THEN
          FND_MESSAGE.SET_TOKEN('PLACE',IGF_AP_GEN.GET_LOOKUP_MEANING('IGF_AP_MAP_PROFILE','COUNTRY'));
       ELSIF l_place = 'MARITAL' THEN
          FND_MESSAGE.SET_TOKEN('PLACE',IGF_AP_GEN.GET_LOOKUP_MEANING('IGF_AP_MAP_PROFILE','MARITAL_STATUS'));
       ELSIF l_place = 'F_NAME' THEN
          FND_MESSAGE.SET_TOKEN('PLACE',IGF_AP_GEN.GET_LOOKUP_MEANING('IGF_AP_MAP_PROFILE','FIRST_NAME'));
       ELSIF l_place = 'L_NAME' THEN
          FND_MESSAGE.SET_TOKEN('PLACE',IGF_AP_GEN.GET_LOOKUP_MEANING('IGF_AP_MAP_PROFILE','LAST_NAME'));

       ELSIF l_place = 'SSN' THEN
          OPEN c_get_tokens;
          FETCH c_get_tokens INTO  tokens_rec;
          FND_MESSAGE.SET_TOKEN('PLACE',TRIM(tokens_rec.meaning));
          CLOSE c_get_tokens;
       END IF;

       IGS_GE_MSG_STACK.ADD;

       -- Bug #3536039. Raise exception IGFSEGEN001
       IF p_call = 'LEGACY' THEN -- throw exception
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          RAISE IGFSEGEN001;
       END IF;

       IF p_call = 'JOB' THEN -- continue for next student dont stop
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       ELSE   -- this means its called from FORM
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

     WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,SQLERRM);
        FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.send_work_auth' || SQLERRM);
        IGS_GE_MSG_STACK.ADD;

        APP_EXCEPTION.RAISE_EXCEPTION;
    END send_work_auth;


    PROCEDURE send_work_auth_job(errbuf     OUT NOCOPY VARCHAR2,
                                 retcode    OUT NOCOPY NUMBER,
                                 p_awd_cal  IN         VARCHAR2,
                                 p_fund_id  IN         igf_aw_fund_mast_all.fund_id%TYPE,
                                 p_dummy    IN         NUMBER,
                                 p_base_id  IN         igf_ap_fa_base_rec_all.base_id%TYPE
                                ) IS
    ------------------------------------------------------------------------------------
    -- Created by  : ssawhney ( Oracle IDC)
    -- Date created: 2nd jan
    -- Purpose:  This procedure will be used to create work authorizations for all student
    --        for an award and for a term whose authorizations have not been created.
    --        This will in turn be calling send_work_auth
    --
    -- Known limitations/enhancements and/or remarks:
    -- Change History:
    -- Who         When            What
	--tsailaja	  15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    --veramach     July 2004       FA 151(HR integration) Added a new dummy parameter
    --rasahoo      25/Aug/2003     #3101894  If the procedur is called from legacy process
    --                             and VISA details are not provided by the context person
    --                             It will create work authorization giving warning.
    -- masehgal    228-dec-2002    # 2445830  Restricted process to pick up only accepted
    --                             awards. Changed call to display log
    -- brajendr    20-May-2002     added 3 new parameters as per the bug # 2363887
    --                             Award Year,  Fund_id, and Base Id
    --
    -- brajendr    28-Jun-2002     Added a new message called IGF_SE_WRK_ATUH_NO_MATCH
    --                             This message will be shown if there are no records to process
    --
    -------------------------------------------------------------------------------------

      CURSOR c_auth(cp_awd_cal_type   igs_ca_inst.cal_type%TYPE,
                    cp_awd_seq_no     igs_ca_inst.sequence_number%TYPE,
                    cp_fund_id        igf_aw_fund_mast_all.fund_id%TYPE,
                    cp_base_id        igf_ap_fa_base_rec_all.base_id%TYPE
                   ) IS
        SELECT awd.award_id,
               awd.fund_id fund_id,
               fa.person_id person_id,
               awd.base_id,
               hz.party_number person_number,
               fmast.fund_code
          FROM igf_aw_award_all awd,
               igf_aw_fund_mast_all fmast,
               igf_aw_fund_cat_all fcat,
               igf_ap_fa_base_rec_all fa,
               hz_parties hz
         WHERE fcat.fed_fund_code = 'FWS'
           AND awd.award_status = 'ACCEPTED'
           AND awd.fund_id = NVL(cp_fund_id, awd.fund_id)
           AND awd.base_id = NVL(cp_base_id, awd.base_id)
           AND fa.ci_cal_type = cp_awd_cal_type
           AND fa.ci_sequence_number = cp_awd_seq_no
           AND fmast.fund_id = awd.fund_id
           AND fmast.fund_code = fcat.fund_code
           AND awd.base_id = fa.base_id
           AND fa.person_id = hz.party_id;

      -- Check if authorization already exists
      CURSOR c_auth_exists(
                           cp_award_id igf_aw_award_all.award_id%TYPE
                          ) IS
        SELECT 'x'
          FROM igf_se_auth
         WHERE award_id = cp_award_id
           AND flag     = 'A';
      l_auth_exists      c_auth_exists%ROWTYPE;

      -- Check if accepted amounts are equal at the award and authorization levels
      CURSOR c_amounts(
                        cp_award_id igf_aw_award_all.award_id%TYPE
                      ) IS
        SELECT awd.accepted_amt accepted_amt,
               auth.accepted_amnt accepted_amnt
          FROM igf_aw_award_all awd,
               igf_se_auth auth
         WHERE awd.award_id = auth.award_id
           AND awd.award_id = cp_award_id
           AND auth.flag    = 'A';
      l_amounts         c_amounts%ROWTYPE;

      l_ld_cal_type   igs_ca_inst.cal_type%TYPE;
      l_ld_seq_no     igs_ca_inst.sequence_number%TYPE;
      l_awd_cal_type  igs_ca_inst.cal_type%TYPE;
      l_awd_seq_no    igs_ca_inst.sequence_number%TYPE;

      auth_rec        c_auth%ROWTYPE;
      l_record        VARCHAR2(50);

      lb_rec_found    BOOLEAN := FALSE;

    BEGIN
	   igf_aw_gen.set_org_id(NULL);
      -- capture the variables
      l_awd_cal_type := LTRIM(RTRIM(SUBSTR(p_awd_cal,1,10)));
      l_awd_seq_no   := TO_NUMBER(SUBSTR(p_awd_cal,11));

      -- set the flag to success
      retcode        :=0;
      lb_rec_found   := FALSE;

      -- Print all the parameters passed for the Job
      display_auth_params(l_awd_cal_type, l_awd_seq_no,  p_fund_id, p_base_id);

      OPEN c_auth (l_awd_cal_type, l_awd_seq_no,  p_fund_id, p_base_id) ;
      LOOP
         FETCH c_auth INTO auth_rec;
         EXIT WHEN c_auth%NOTFOUND;

         IF (c_auth%FOUND) THEN
           -- call the send auth procedure
           -- display parameters
           lb_rec_found := TRUE;
           display_auth_process_log( auth_rec.person_number, auth_rec.fund_code, auth_rec.award_id);

           l_auth_exists := NULL;
           OPEN c_auth_exists(auth_rec.award_id);
           FETCH c_auth_exists INTO l_auth_exists;
           IF c_auth_exists%FOUND THEN
             CLOSE c_auth_exists;

             l_amounts := NULL;
             OPEN c_amounts(auth_rec.award_id);
             FETCH c_amounts INTO l_amounts;
             CLOSE c_amounts;

             IF l_amounts.accepted_amt = l_amounts.accepted_amnt THEN
               --no need to recreate authorization
               --log a message
               fnd_message.set_name('IGF','IGF_SE_AUTH_GENERATED');
               fnd_file.put_line(fnd_file.log,fnd_message.get);
             ELSE
               igf_se_gen_001.send_work_auth(
                                           auth_rec.base_id,
                                           auth_rec.person_id,
                                           auth_rec.fund_id,
                                           auth_rec.award_id,
                                           NULL,
                                           NULL,
                                           'JOB'
                                          );
             END IF;
           ELSE
             CLOSE c_auth_exists;
             --authorization not exists
             igf_se_gen_001.send_work_auth(
                                         auth_rec.base_id,
                                         auth_rec.person_id,
                                         auth_rec.fund_id,
                                         auth_rec.award_id,
                                         NULL,
                                         NULL,
                                         'JOB'
                                        );
           END IF;
         END IF;
      END LOOP;

      -- close the loop
      IF c_auth%ISOPEN THEN
         CLOSE c_auth;
      END IF;

      IF lb_rec_found = FALSE THEN
         FND_MESSAGE.SET_NAME('IGF','IGF_SE_WRK_ATUH_NO_MATCH');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

    EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         retcode:=2;
         FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.send_work_auth_job');
         IGS_GE_MSG_STACK.ADD;
         errbuf := FND_MESSAGE.GET ;
         IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
    END send_work_auth_job;


    PROCEDURE payroll_uplaod(errbuf      OUT NOCOPY VARCHAR2,
                             retcode     OUT NOCOPY NUMBER,
                             p_batch_id  IN  igf_se_payment_int.batch_id%TYPE,
                             p_auth_id   IN  igf_se_auth.auth_id%TYPE,
                             p_level     IN  VARCHAR2) IS
    ------------------------------------------------------------------------------------
    --Created by  : ssawhney ( Oracle IDC)
    --Date created: 2nd jan
    --Purpose:
    --
    --Known limitations/enhancements and/or remarks:
    --Change History:
    --Who         When            What
	--tsailaja	  15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    --brajendr    12-Jun-2002     Modified the log messages
    --                            Added check to by pass the validation of not null columns
    -------------------------------------------------------------------------------------

      -- if auth_id is NULL then take all records for the corresponding batch_id
      CURSOR c_payment(cv_batch_id igf_se_payment_int.batch_id%TYPE,
                       cv_auth_id  igf_se_auth.auth_id%TYPE) IS
         SELECT rowid, sei.*
           FROM IGF_SE_PAYMENT_INT sei
          WHERE sei.batch_id = cv_batch_id
            AND sei.auth_id = NVL(cv_auth_id,sei.auth_id)
            AND sei.status IN ('NEW', 'UPLOAD')
       ORDER BY auth_id, person_id
            FOR UPDATE NOWAIT;

         CURSOR c_auth_count(cv_auth_id  igf_se_auth.auth_id%TYPE,
                          cv_person_id hz_parties.party_id%TYPE) IS
         SELECT COUNT(*) count
           FROM igf_se_auth c,igf_aw_award a, igf_ap_fa_base_rec b
          WHERE c.auth_id = cv_auth_id
            AND c.award_id = a.award_id
            AND a.base_id = b.base_id
            AND b.person_id = cv_person_id
            AND flag = 'A';

      CURSOR c_get_se_errors(c_error_cd  igf_se_payment_int.error_code%TYPE) IS
         SELECT meaning
           FROM igf_lookups_view
          WHERE lookup_type = 'IGF_STUD_EMP_ERROR'
            AND lookup_code = c_error_cd;

      CURSOR cur_pymt_int IS
         SELECT pint.status, pint.error_code, hz.party_number, pint.auth_id
           FROM igf_se_payment_int pint, hz_parties hz
          WHERE pint.status IN ('DONE','ERROR')
            AND pint.person_id = hz.party_id
            AND pint.batch_id = p_batch_id;

      payment_rec           c_payment%ROWTYPE;
      l_source              igf_se_payment.source%TYPE;
      l_error_cd            igf_se_payment_int.error_code%TYPE DEFAULT NULL;
      l_transaction_id      igf_se_payment_int.transaction_id%TYPE;
      l_batch_id            igf_se_payment_int.batch_id%TYPE;
      l_auth_id             igf_se_payment_int.auth_id%TYPE;
      l_ld_cal_type         igs_ca_inst.cal_type%TYPE;
      l_ld_sequence_number  igs_ca_inst.sequence_number%TYPE;
      l_error_meaming       igf_lookups_view.meaning%TYPE;
      l_level               VARCHAR2(1);
      l_auth_count          NUMBER(2) DEFAULT 0;
      l_rowid               VARCHAR2(30);
      skip_record           EXCEPTION;
      l_rec_count           NUMBER DEFAULT 0;

      PROCEDURE update_record(payment_rec  IN  c_payment%ROWTYPE,
                              p_error_cd   IN  igf_se_payment_int.error_code%TYPE) IS
      --------------------------------------------------------
      --Created by : ssawhney on 2nd Jan
      --Purpose : local procedure to update IGF_SE_PAYMENT_INT based on p_error_cd
      --Change History :
      --Who         When            What
      ----------------------------------------------------------------


        l_error_cd       igf_se_payment_int.error_code%TYPE;
        l_status         igf_se_payment_int.status%TYPE;
        l_source         igf_se_payment.source%TYPE;

      BEGIN

        -- update is being called 2 times, if the error code passed is NULL then
        -- it means the record was successfully passed from PAYMENT_INT to PAYMENT table.
        l_error_cd := p_error_cd;
        IF l_error_cd IS NULL THEN
           l_status :='DONE';
        ELSIF l_error_cd IS NOT NULL THEN
           l_status :='ERROR';
        END IF;

        igf_se_payment_int_pkg.update_row(
                                          x_rowid                 => payment_rec.rowid,
                                          x_transaction_id        => payment_rec.transaction_id,
                                          x_batch_id              => payment_rec.batch_id,
                                          x_payroll_id            => payment_rec.payroll_id,
                                          x_payroll_date          => payment_rec.payroll_date,
                                          x_auth_id               => payment_rec.auth_id,
                                          x_person_id             => payment_rec.person_id,
                                          x_fund_id               => payment_rec.fund_id,
                                          x_paid_amount           => payment_rec.paid_amount,
                                          x_org_unit_cd           => payment_rec.org_unit_cd,
                                          x_status                => l_status,
                                          x_error_code            => l_error_cd
                                         );

      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.payroll_upload:igf_se_payment_int.update');
          FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
          IGS_GE_MSG_STACK.ADD;
          -- app_exception.raise_exception;

      END update_record;

    -- begin main procedure
    BEGIN
	    igf_aw_gen.set_org_id(NULL);

      l_batch_id := p_batch_id ;
      l_auth_id  := p_auth_id;
      l_level    := p_level;

      -- set the flag to success
      retcode:=0;
      l_rec_count := 0;

      -- Display all the passed Paramters
      display_payroll_params(l_batch_id, l_auth_id, l_level);

      -- batch_id is mandatory parameter.
      IF l_batch_id IS NULL THEN
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_PARAM_ERR');
         FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      -- loop for all records. If auth_id is present then there will be only one record with the combination
      FOR payment_rec IN c_payment (l_batch_id,l_auth_id)
      LOOP
        l_rec_count := l_rec_count + 1;
        BEGIN
          -- validate the auth and person combination
          OPEN  c_auth_count(payment_rec.auth_id,payment_rec.person_id);
          FETCH c_auth_count INTO l_auth_count;
          CLOSE c_auth_count;
          IF (l_auth_count > 0) THEN -- authorization id passed exists for a person.
            l_source :='UPLOAD';
            -- move record from SE_PAYMENT_INT to SE_PAYMENT once the validation was done
            BEGIN
              SAVEPOINT se_adjust;
              -- validate threshold will not be called from here.
              igf_se_payment_pkg.insert_row(
                x_rowid                             => l_rowid,
                x_transaction_id                    => l_transaction_id,
                x_payroll_id                        => payment_rec.payroll_id,
                x_payroll_date                      => payment_rec.payroll_date,
                x_auth_id                           => payment_rec.auth_id,
                x_person_id                         => payment_rec.person_id,
                x_fund_id                           => payment_rec.fund_id,
                x_paid_amount                       => payment_rec.paid_amount,
                x_org_unit_cd                       => payment_rec.org_unit_cd,
                x_source                            => l_source
              );
            EXCEPTION
              WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                ROLLBACK TO se_adjust;
                l_error_cd := 'SE005';
                update_record(payment_rec,l_error_cd);
                RAISE SKIP_RECORD;
            END;
          ELSE  -- l_auth_count < 0
            l_error_cd :='SE006';
            update_record(payment_rec,l_error_cd);
          END IF;  -- l_auth_count >0
        EXCEPTION -- handle user raised exception
          WHEN skip_record THEN
             NULL;
        END;
      END LOOP; --payment_rec

      -- Purge the records now which are already moved successfully
      -- And also Log the relavent messages
      BEGIN

        FOR cur_pymt_int_rec IN cur_pymt_int LOOP
          IF cur_pymt_int_rec.status = 'DONE' THEN
             FND_MESSAGE.SET_NAME('IGF','IGF_SE_SUCCESS');
             FND_MESSAGE.SET_TOKEN('NUMBER',cur_pymt_int_rec.party_number);
             FND_MESSAGE.SET_TOKEN('AUTHID',cur_pymt_int_rec.auth_id);
             FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);

          ELSIF cur_pymt_int_rec.status = 'ERROR' THEN
             OPEN  c_get_se_errors( cur_pymt_int_rec.error_code);
             FETCH c_get_se_errors INTO l_error_meaming;
             CLOSE c_get_se_errors;

             FND_MESSAGE.SET_NAME('IGF','IGF_SE_NOT_SUCCESS');
             FND_MESSAGE.SET_TOKEN('NUMBER',cur_pymt_int_rec.party_number);
             FND_MESSAGE.SET_TOKEN('AUTHID',cur_pymt_int_rec.auth_id);
             FND_MESSAGE.SET_TOKEN('ERROR',l_error_meaming);
             FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);

          END IF;
        END LOOP;

        DELETE FROM igf_se_payment_int
         WHERE status = 'DONE'
           AND batch_id = l_batch_id;

      EXCEPTION
        WHEN OTHERS THEN
           FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
           FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.payroll_upload: delete record');
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
           IGS_GE_MSG_STACK.ADD;
      END;

      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

      IF l_rec_count = 0 THEN
         -- There are no Records to process
         FND_MESSAGE.SET_NAME('IGS','IGS_UC_HE_NO_DATA');
         FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);

      ELSE
         -- Total Records Processed : RCOUNT
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_TOT_REC_PRC');
         FND_MESSAGE.SET_TOKEN('RCOUNT',l_rec_count);
         FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);

      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

    EXCEPTION  -- main exception handling
      WHEN OTHERS THEN
         ROLLBACK ;
         retcode:=2;
         FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.payroll_upload');
         IGS_GE_MSG_STACK.ADD;
         errbuf := FND_MESSAGE.GET ;
         IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;

    END payroll_uplaod;


    PROCEDURE payroll_adjust(
                             p_payment_rec   IN  igf_se_payment%ROWTYPE,
                             p_status OUT NOCOPY igf_se_payment_int.status%TYPE,
                             p_error_cd OUT NOCOPY igf_se_payment_int.error_code%TYPE
                            )IS
    ------------------------------------------------------------------------------------
    -- Created by  : ssawhney ( Oracle IDC)
    -- Date created: 2nd jan
    -- Purpose:  This procedure will be used to adjust the payroll amount into IGF_AW_AWD_DISB
    --           This will be used at the time of moving record from IGF_SE_PAYMENT_INT to IGF_SE_PAYMENT
    --           Hence it will be present in the TBH of IGF_SE_PAYMENT
    -- Known limitations/enhancements and/or remarks:
    -- Change History:
    -- Who         When            What
    --veramach     July 2004       bug 3709292 FA 151 HR integration changes
    -- brajendr    18-Jul-2002     Bug # 2450456
    --                             Added a check for negative adjustments
    -------------------------------------------------------------------------------------
      l_auth_id         igf_se_auth.auth_id%TYPE;
      l_payroll_date    igf_se_payment_int.payroll_date%TYPE;
      l_paid_amount     igf_se_payment_int.paid_amount%TYPE;
      l_status          igf_se_payment_int.status%TYPE;
      l_error_cd        igf_se_payment_int.error_code%TYPE;
      l_disb_amount     igf_aw_awd_disb.disb_accepted_amt%TYPE DEFAULT 0;
      l_sys_awd_status  igf_ap_batch_aw_map.award_year_status_code%TYPE;

      CURSOR c_auth (cv_auth_id  igf_se_auth.auth_id%TYPE) IS
         SELECT rowid row_id,auth.*
           FROM igf_se_auth auth
          WHERE auth_id = cv_auth_id
            AND flag='A';

      CURSOR c_award_det(cp_cal_type VARCHAR2,
                         cp_seq_number NUMBER) IS
      SELECT award_year_status_code
      FROM   igf_ap_batch_aw_map
      WHERE  ci_cal_type = cp_cal_type
      AND    ci_sequence_number = cp_seq_number;

      CURSOR c_sum(
                   cv_auth_id     igf_se_auth.auth_id%TYPE
                  ) IS
         SELECT NVL(accepted_amt,NVL(offered_amt,0)) accepted_amt,
                base_id
           FROM igf_aw_award_all awd,
                igf_se_auth se
          WHERE se.award_id = awd.award_id
            AND se.auth_id  = cv_auth_id
            AND se.flag     = 'A';


      CURSOR c_award(
                     cp_auth_id igf_se_auth.auth_id%TYPE
                    ) IS
      SELECT awd.*
        FROM igf_aw_award awd,
             igf_se_auth auth
       WHERE auth.auth_id  = cp_auth_id
         AND auth.award_id = awd.award_id;

      CURSOR c_payment_total(cv_auth_id  igf_se_auth.auth_id%TYPE) IS
         SELECT SUM( NVL(paid_amount, 0))
           FROM igf_se_payment
          WHERE auth_id = cv_auth_id;

      sum_rec               c_sum%ROWTYPE;
      l_award               c_award%ROWTYPE;
      auth_rec              c_auth%ROWTYPE;
      l_fund_id             igf_aw_fund_mast.fund_id%TYPE;
      l_person_id           igs_pe_person.person_id%TYPE;
      ln_total_paid_amount  igf_se_payment.paid_amount%TYPE;
      l_notification_date   igf_se_auth.notification_date%TYPE;

      -----------local function begin
      FUNCTION validate_threshold(
                                  p_fund_id IN igf_aw_fund_mast.fund_id%TYPE,
                                  p_paid_amount IN igf_aw_awds_sum_v.paid_amt%TYPE,
                                  p_accepted_amt  IN  igf_aw_awds_sum_v.accepted_amt%TYPE
                                 ) RETURN BOOLEAN IS
      ------------------------------------------------------------------------------------
      --Created by  : ssawhney ( Oracle IDC) Date created: 2nd jan
      --Purpose:  Local function : This function will be called to validate if the Paid amount for the fund
      --        has reached its threshold limits as set in the FUND MASTER.
      --
      --Change History:
      --Who         When            What
      --masehgal    26-Dec-2002     # 2516712  Copied Trunc( Sysdate) in notification date
      --                            to resolve locking error.
      -------------------------------------------------------------------------------------

      CURSOR c_fund ( cv_fund_id igf_aw_fund_mast.fund_id%TYPE) IS
         SELECT threshold_perct, threshold_value
           FROM igf_aw_fund_mast
          WHERE fund_id = cv_fund_id;

        fund_rec        c_fund%ROWTYPE;
        l_fund_id       igf_aw_fund_mast.fund_id%TYPE;
        l_paid_amount   NUMBER;
        l_perct         NUMBER(5,2);
        l_accepted_amt  igf_aw_awds_sum_v.accepted_amt%TYPE;

      BEGIN

        l_fund_id      := p_fund_id;
        l_paid_amount  := p_paid_amount ;
        l_accepted_amt := p_accepted_amt;

        -- get fund setup details. If no data found error with the Fund details

        OPEN  c_fund (l_fund_id);
        FETCH c_fund INTO fund_rec;
        IF c_fund%NOTFOUND THEN
           CLOSE c_fund;
           RETURN FALSE;
        END IF;
        CLOSE c_fund;

        -- validate the threshold if threshold value is present
        IF fund_rec.threshold_value IS NOT NULL THEN
           IF l_paid_amount >= fund_rec.threshold_value THEN
              RETURN TRUE;
           END IF;

        -- validate the threshold if threshold percent is present
        ELSIF fund_rec.threshold_perct IS NOT NULL THEN
           BEGIN
              l_perct := ROUND(l_paid_amount/l_accepted_amt)*100;
              IF l_perct >= ROUND(fund_rec.threshold_perct) THEN
                 RETURN TRUE;
              END IF;
           EXCEPTION
              WHEN ZERO_DIVIDE THEN
                 -- there can be a condition where the accepted amount is 0 and we get error.
                 RETURN FALSE;
            END;
        END IF;

        RETURN FALSE;

      EXCEPTION
        WHEN OTHERS THEN
          RETURN FALSE;

      END validate_threshold;

    -----------local function end
    BEGIN

      l_auth_id           := p_payment_rec.auth_id;
      l_fund_id           := p_payment_rec.fund_id;
      l_person_id         := p_payment_rec.person_id;
      l_paid_amount       := NVL(p_payment_rec.paid_amount,0);
      l_notification_date := NULL;

      -- set OUT NOCOPY variables as TRUE.
      p_error_cd := NULL;
      p_status   := 'DONE';

      OPEN c_auth(l_auth_id);
      FETCH c_auth INTO auth_rec;
      IF c_auth%NOTFOUND THEN
         p_error_cd := 'SE006';
         p_status   := 'ERROR';
         CLOSE c_auth;
         RETURN;
        -- app_exception.raise_exception;
      END IF;
      CLOSE c_auth;

      OPEN c_sum(l_auth_id);
      FETCH c_sum INTO sum_rec;
      IF c_sum%NOTFOUND THEN
         p_error_cd := 'SE008';
         p_status   := 'ERROR';
         CLOSE c_sum;
         RETURN;
      END IF;
      CLOSE c_sum;

      -- Check the total payment amount for an auth id and if it is less than zero then show an errror to user
      ln_total_paid_amount := 0;
      OPEN  c_payment_total(p_payment_rec.auth_id);
      FETCH c_payment_total INTO ln_total_paid_amount;
      CLOSE c_payment_total;

      -- compare the payroll amount and the accepted amount by the student for the fund
      -- in the award year in that term. The payroll amount should be less than the accepted amount.
      IF ln_total_paid_amount > sum_rec.accepted_amt THEN
         p_error_cd := 'SE009';
         p_status   := 'ERROR';
         RETURN;

      ELSIF l_paid_amount < 0 AND ln_total_paid_amount < 0 THEN
         p_error_cd := 'SE012';
         p_status   := 'ERROR';
         RETURN;

      END IF;

      -- check up for threshold limits
      IF validate_threshold (l_fund_id,ln_total_paid_amount,sum_rec.accepted_amt) THEN
         l_notification_date := TRUNC(SYSDATE);
      END IF;

      --update the paid amount
      BEGIN
        OPEN c_award(l_auth_id);
        FETCH c_award INTO l_award;
        CLOSE c_award;

        igf_aw_award_pkg.update_row(
                                    x_rowid                => l_award.row_id,
                                    x_award_id             => l_award.award_id,
                                    x_fund_id              => l_award.fund_id,
                                    x_base_id              => l_award.base_id,
                                    x_offered_amt          => l_award.offered_amt,
                                    x_accepted_amt         => l_award.accepted_amt,
                                    x_paid_amt             => ln_total_paid_amount,
                                    x_packaging_type       => l_award.packaging_type,
                                    x_batch_id             => l_award.batch_id,
                                    x_manual_update        => l_award.manual_update,
                                    x_rules_override       => l_award.rules_override,
                                    x_award_date           => l_award.award_date,
                                    x_award_status         => l_award.award_status,
                                    x_attribute_category   => l_award.attribute_category,
                                    x_attribute1           => l_award.attribute1,
                                    x_attribute2           => l_award.attribute2,
                                    x_attribute3           => l_award.attribute3,
                                    x_attribute4           => l_award.attribute4,
                                    x_attribute5           => l_award.attribute5,
                                    x_attribute6           => l_award.attribute6,
                                    x_attribute7           => l_award.attribute7,
                                    x_attribute8           => l_award.attribute8,
                                    x_attribute9           => l_award.attribute9,
                                    x_attribute10          => l_award.attribute10,
                                    x_attribute11          => l_award.attribute11,
                                    x_attribute12          => l_award.attribute12,
                                    x_attribute13          => l_award.attribute13,
                                    x_attribute14          => l_award.attribute14,
                                    x_attribute15          => l_award.attribute15,
                                    x_attribute16          => l_award.attribute16,
                                    x_attribute17          => l_award.attribute17,
                                    x_attribute18          => l_award.attribute18,
                                    x_attribute19          => l_award.attribute19,
                                    x_attribute20          => l_award.attribute20,
                                    x_rvsn_id              => l_award.rvsn_id,
                                    x_alt_pell_schedule    => l_award.alt_pell_schedule,
                                    x_mode                 => 'R',
                                    x_award_number_txt     => l_award.award_number_txt,
                                    x_legacy_record_flag   => l_award.legacy_record_flag,
                                    x_adplans_id           => l_award.adplans_id,
                                    x_lock_award_flag      => l_award.lock_award_flag,
                                    x_app_trans_num_txt    => l_award.app_trans_num_txt,
                                    x_awd_proc_status_code => l_award.awd_proc_status_code,
                                    x_notification_status_code	=> l_award.notification_status_code,
                                    x_notification_status_date	=> l_award.notification_status_date,
                                    x_publish_in_ss_flag        => l_award.publish_in_ss_flag
                                   );
        -- reset the variables
        l_disb_amount:=0;
      EXCEPTION
        WHEN OTHERS THEN
           p_error_cd := 'SE007';
           p_status   := 'ERROR';
           RETURN;
           --app_exception.raise_exception;
           -- reset the variables
           l_disb_amount :=0;
      END;

      -- call Notification
      IF l_notification_date IS NOT NULL AND TRUNC(l_notification_date) = TRUNC(SYSDATE) THEN
        -- Initializing Award status
        l_sys_awd_status := 'LD';

        OPEN  c_award_det(auth_rec.aw_cal_type,auth_rec.aw_sequence_number);
        FETCH c_award_det INTO l_sys_awd_status;
        CLOSE c_award_det;

        IF l_sys_awd_status = 'O' THEN
           igf_se_gen_001.se_notify (l_person_id, l_fund_id,NULL,NULL,auth_rec.award_id);
           igf_se_auth_pkg.update_row(
                                      x_rowid                => auth_rec.row_id,
                                      x_sequence_no          => auth_rec.sequence_no,
                                      x_auth_id              => auth_rec.auth_id,
                                      x_flag                 => auth_rec.flag,
                                      x_person_id            => auth_rec.person_id,
                                      x_first_name           => auth_rec.first_name,
                                      x_last_name            => auth_rec.last_name,
                                      x_address1             => auth_rec.address1,
                                      x_address2             => auth_rec.address2,
                                      x_address3             => auth_rec.address3,
                                      x_address4             => auth_rec.address4,
                                      x_city                 => auth_rec.city,
                                      x_state                => auth_rec.state,
                                      x_province             => auth_rec.province,
                                      x_county               => auth_rec.county,
                                      x_country              => auth_rec.country,
                                      x_sex                  => auth_rec.sex,
                                      x_birth_dt             => auth_rec.birth_dt,
                                      x_ssn_no               => auth_rec.ssn_no,
                                      x_marital_status       => auth_rec.marital_status,
                                      x_visa_type            => auth_rec.visa_type,
                                      x_visa_category        => auth_rec.visa_category,
                                      x_visa_number          => auth_rec.visa_number,
                                      x_visa_expiry_dt       => auth_rec.visa_expiry_dt,
                                      x_entry_date           => auth_rec.entry_date,
                                      x_fund_id              => auth_rec.fund_id,
                                      x_threshold_perct      => auth_rec.threshold_perct,
                                      x_threshold_value      => auth_rec.threshold_value,
                                      x_accepted_amnt        => auth_rec.accepted_amnt,
                                      x_aw_cal_type          => auth_rec.aw_cal_type,
                                      x_aw_sequence_number   => auth_rec.aw_sequence_number,
                                      x_mode                 => 'R',
                                      x_award_id             => auth_rec.award_id,
                                      x_authorization_date   => auth_rec.authorization_date,
                                      x_notification_date    => l_notification_date
                                     );
        END IF;
      END IF;


    -- set OUT NOCOPY variables as TRUE.
    p_error_cd := NULL;
    p_status := 'DONE';


    EXCEPTION
      WHEN OTHERS THEN
        IF p_error_cd IS NULL THEN
           p_error_cd := 'SE007';
        END IF;

        p_status := 'ERROR';
        -- app_exception.raise_exception;
    END payroll_adjust;


    PROCEDURE se_notify(p_person_id    IN  hz_parties.party_id%TYPE,
                        p_fund_id      IN  igf_aw_fund_mast.fund_id%TYPE,
                        p_ld_cal_type  IN  igs_ca_inst.cal_type%TYPE,
                        p_ld_seq_no    IN  igs_ca_inst.sequence_number%TYPE,
                        p_award_id     IN  igf_aw_award_all.award_id%TYPE
                        ) IS
    ------------------------------------------------------------------------------------
    --Created by  : ssawhney ( Oracle IDC)
    --Date created: 2nd jan
    --Purpose:  This procedure will be used to generate Work Flow notifications for the
    --          concerned records, which exceed threshold payment limits.
    --
    --Known limitations/enhancements and/or remarks:
    --Change History:
    --Who         When            What
    --veramach    July 2004       FA 151 HR integration - process raises a business event instead of initiating workflow
    -------------------------------------------------------------------------------------
      CURSOR c_person IS
         SELECT fa.person_number,   fa.full_name
           FROM igs_pe_person_base_v fa
          WHERE fa.person_id  = p_person_id ;

      CURSOR c_fund IS
         SELECT fund_code,threshold_perct,threshold_value
           FROM igf_aw_fund_mast
          WHERE fund_id = p_fund_id;

      CURSOR c_earned_amount IS
        SELECT paid_amt
          FROM igf_se_work_awd_prg_v
         WHERE award_id=p_award_id;

      person_rec      c_person%ROWTYPE ;
      fund_rec        c_fund%ROWTYPE;
      earned_amt_rec  c_earned_amount%ROWTYPE;

      l_seq_val       NUMBER;
      l_wf_installed  fnd_lookups.lookup_code%TYPE;

      l_wf_event_t           WF_EVENT_T;
      l_wf_parameter_list_t  WF_PARAMETER_LIST_T;

    BEGIN

      -- get the profile value that is set for checking if workflow is installed
      fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

      -- if workflow is installed then carry on with the sending notification
      IF NVL(RTRIM(l_wf_installed),'Y') ='Y' THEN

      -- fetch data from all the cursors
      OPEN  c_person;
      FETCH c_person INTO person_rec;
      CLOSE c_person;

      OPEN  c_fund;
      FETCH c_fund INTO fund_rec;
      CLOSE c_fund;

      OPEN c_earned_amount;
      FETCH c_earned_amount INTO earned_amt_rec;
      CLOSE c_earned_amount;

      -- Getting a unique number from the sequence
      -- using a IGS_PE sequence for this.

      SELECT igs_pe_res_chg_s.nextval INTO l_seq_val from DUAL;

      -- Initialize the wf_event_t object
      WF_EVENT_T.Initialize(l_wf_event_t);

      -- Set the event name
      l_wf_event_t.setEventName(pEventName => 'oracle.apps.igf.se.earnings.limit.reached');

      -- Set the event key
      l_wf_event_t.setEventKey(
                               pEventKey => 'oracle.apps.igf.se.earnings.limit.reached' || l_seq_val
                              );

      -- Set the parameter list
      l_wf_event_t.setParameterList(
                                    pParameterList => l_wf_parameter_list_t
                                   );

      -- Pass Person Number, Person Name, Fund Code, Earned Amount and threshold percentage or value that is marked at the Fund Level as the event parameters
      fnd_message.set_name('IGF','IGF_SE_MSG_SUBJ');
      wf_event.addparametertolist(
                                  p_name          => 'SUBJECT',
                                  p_value         => fnd_message.get,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      -- Get the body of the mail from fnd_new_messages and assign it to the attribute defined in the workflow definition
      fnd_message.set_name('IGF','IGF_AP_SAP_MSG_SUBJ');
      wf_event.addparametertolist(
                                  p_name          => 'MESSGAE_BODY',
                                  p_value         => fnd_message.get,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );


      wf_event.addparametertolist(
                                  p_name          => 'PERSON_NUMBER',
                                  p_value         => person_rec.person_number,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      wf_event.addparametertolist(
                                  p_name          => 'NAME',
                                  p_value         => person_rec.full_name,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      wf_event.addparametertolist(
                                  p_name          => 'FUND_CODE',
                                  p_value         => fund_rec.fund_code,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      wf_event.addparametertolist(
                                  p_name          => 'EARNED_AMOUNT',
                                  p_value         => earned_amt_rec.paid_amt,
                                  p_parameterlist => l_wf_parameter_list_t
                                 );

      IF fund_rec.threshold_perct IS NOT NULL THEN
        wf_event.addparametertolist(
                                    p_name          => 'THRESHOLD_PERCT',
                                    p_value         => fund_rec.threshold_perct,
                                    p_parameterlist => l_wf_parameter_list_t
                                   );
      ELSE
        wf_event.addparametertolist(
                                    p_name          => 'THRESHOLD_VALUE',
                                    p_value         => fund_rec.threshold_value,
                                    p_parameterlist => l_wf_parameter_list_t
                                   );
      END IF;
      wf_Event.raise(
                     p_event_name => 'oracle.apps.igf.se.earnings.limit.reached',
                     p_event_key  => 'oracle.apps.igf.se.earnings.limit.reached' || l_seq_val,
                     p_parameters => l_wf_parameter_list_t
                    );

    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igf_se_gen_001.se_notify');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
    END se_notify;

END igf_se_gen_001;

/
