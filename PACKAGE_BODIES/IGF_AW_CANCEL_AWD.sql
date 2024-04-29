--------------------------------------------------------
--  DDL for Package Body IGF_AW_CANCEL_AWD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_CANCEL_AWD" AS
/* $Header: IGFAW06B.pls 120.8 2006/02/08 23:39:51 ridas ship $ */

    /*
    ||  Created On : 12-Jun-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  FUNCTION chk_awd_exp_date (
                              p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_fund_id         IN    igf_aw_fund_mast_all.fund_id%TYPE,
                              p_ci_cal_type     IN    igs_ca_inst_all.cal_type%TYPE,
                              p_ci_seq_num      IN    igs_ca_inst_all.sequence_number%TYPE,
                              p_run_mode        IN    igf_lookups_view.lookup_code%TYPE
                            )
  RETURN BOOLEAN
  IS
    /*
    ||  Created By : museshad
    ||  Created On : 05-Oct-2005
    ||  Purpose    : Checks if an award can be cancelled or not based on the
    ||               run mode. If the run mode is unrestricted, then the award
    ||               can be cancelled irrespective of the award expiration date.
    ||               If the run mode is restricted, then only expired awards
    ||               can be cancelled.
    ||
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||
    ||  (reverse chronological order - newest change first)
    */

    CURSOR c_fund_exp_da(cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
    IS
      SELECT  fund_exp_da
      FROM    igf_aw_fund_mast_all
      WHERE   fund_id = cp_fund_id;

    l_awd_exp_date  DATE := NULL;
    l_fund_exp_da   igf_aw_fund_mast_all.fund_exp_da%TYPE;
    l_result        BOOLEAN;

  BEGIN

    IF p_run_mode = 'UNR' THEN
      -- UNRESTRICTED - Cancel award irrespective of award expiration date
      l_result := TRUE;

    ELSIF p_run_mode = 'RES' THEN
      -- RESTRICTED - Check if award expiration date is passed

      OPEN c_fund_exp_da(cp_fund_id => p_fund_id);
      FETCH c_fund_exp_da INTO l_fund_exp_da;
      CLOSE c_fund_exp_da;

      IF l_fund_exp_da IS NOT NULL THEN

        -- Derive award expiration date
        l_awd_exp_date := NVL(igf_aw_packaging.get_date_instance(
                                                                  p_base_id       =>  p_base_id,
                                                                  p_dt_alias      =>  l_fund_exp_da,
                                                                  p_cal_type      =>  p_ci_cal_type,
                                                                  p_cal_sequence  =>  p_ci_seq_num
                                                                ), SYSDATE + 1);

        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_cancel_awd.chk_awd_exp_date.debug',
                        'Award expiration date(l_awd_exp_date): ' ||l_awd_exp_date);
        END IF;

        IF l_awd_exp_date >= SYSDATE THEN
          -- There is some more time for the award to Expire. Do not cancel the award
          l_result := FALSE;

          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_aw_cancel_awd.chk_awd_exp_date.debug',
                          'Award expiration date > SYSDATE. Award NOT expired.');
          END IF;
        ELSE
          -- Award has expired. Cancel award.
          l_result := TRUE;

          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_aw_cancel_awd.chk_awd_exp_date.debug',
                          'Award expiration date < SYSDATE. Award expired.');
          END IF;
        END IF;
      ELSE
        -- Award expiration date is not defined. Do not cancel the award.
        l_result := FALSE;

        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_cancel_awd.chk_awd_exp_date.debug',
                        'Award expiration offset not setup in Fund Manager for fund_id: ' ||p_fund_id);
        END IF;
      END IF;
    END IF;

    RETURN l_result;
  END chk_awd_exp_date;

  PROCEDURE get_base_id_per_num (
                                  p_person_id       IN          hz_parties.party_id%TYPE,
                                  p_ci_cal_type     IN          igs_ca_inst_all.cal_type%TYPE,
                                  p_ci_seq_num      IN          igs_ca_inst_all.sequence_number%TYPE,
                                  p_base_id         OUT NOCOPY  igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_per_num         OUT NOCOPY  igs_pe_person_base_v.person_number%TYPE
                                )
  IS
    /*
    ||  Created By : museshad
    ||  Created On : 06-Oct-2005
    ||  Purpose : Returns the base_id and person number
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||
    ||  (reverse chronological order - newest change first)
    */

    CURSOR cur_get_pers_num (cp_person_id  igf_ap_fa_base_rec_all.person_id%TYPE)
    IS
      SELECT  person_number
      FROM    igs_pe_person_base_v
      WHERE   person_id  = cp_person_id;

    CURSOR cur_get_base (cp_cal_type        igs_ca_inst_all.cal_type%TYPE,
                         cp_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                         cp_person_id       igf_ap_fa_base_rec_all.person_id%TYPE)
    IS
    SELECT  base_id
    FROM    igf_ap_fa_base_rec_all
    WHERE   person_id          = cp_person_id      AND
            ci_cal_type        = cp_cal_type       AND
            ci_sequence_number = cp_sequence_number;
  BEGIN
    p_per_num :=  NULL;
    p_base_id :=  NULL;

    OPEN cur_get_pers_num(p_person_id);
    FETCH cur_get_pers_num INTO p_per_num;
    CLOSE cur_get_pers_num;

    OPEN cur_get_base(p_ci_cal_type, p_ci_seq_num, p_person_id);
    FETCH cur_get_base INTO p_base_id;
    CLOSE cur_get_base;
  END get_base_id_per_num;

  PROCEDURE cancel_award_fabase (
                                  p_ci_cal_type     IN    igs_ca_inst_all.cal_type%TYPE,
                                  p_ci_seq_num      IN    igs_ca_inst_all.sequence_number%TYPE,
                                  p_fund_id         IN    igf_aw_award_all.fund_id%TYPE,
                                  p_base_id         IN    igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_run_mode        IN    igf_lookups_view.lookup_code%TYPE
                                )
  IS
    /*
    ||  Created By : museshad
    ||  Created On : 05-Oct-2005
    ||  Purpose : Cancels the award and all its disbursements
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||
    ||  (reverse chronological order - newest change first)
    */

    CURSOR c_award (cp_ci_cal_type        igs_ca_inst_all.cal_type%TYPE,
                    cp_ci_seq_num         igs_ca_inst_all.sequence_number%TYPE,
                    cp_fund_id            igf_aw_fund_mast.fund_id%TYPE,
                    cp_base_id            igf_ap_fa_con_v.base_id%TYPE)
    IS
    SELECT
    awd.award_id,
    awd.base_id,
    fapv.person_number,
    fmast.fund_code,
    fcat.fed_fund_code
    FROM
    igf_aw_award        awd,
    igf_aw_fund_mast    fmast,
    igf_ap_fa_base_rec  fbase,
    igf_ap_person_v     fapv,
    igf_aw_fund_cat     fcat
    WHERE
          fbase.ci_cal_type                 =  cp_ci_cal_type
    AND   fbase.ci_sequence_number          =  cp_ci_seq_num
    AND   awd.fund_id                       =  NVL(cp_fund_id, awd.fund_id)
    AND   awd.base_id                       =  NVL(cp_base_id, awd.base_id)
    AND   fmast.fund_id                     =  awd.fund_id
    AND   awd.award_status                  = 'OFFERED'
    AND   awd.base_id                       = fbase.base_id
    AND   fbase.person_id                   = fapv.person_id
    AND   fmast.fund_code                   = fcat.fund_code
    AND   fcat.fed_fund_code                <> 'SPNSR'
    AND   fcat.fed_fund_code                <> 'FWS'  ;  --Currently we are not handling FWS funds

    lc_award  c_award%ROWTYPE;

    -- Cursor is opened for udpating awards
    CURSOR c_awd(p_award_id igf_aw_award.award_id%TYPE) IS
    SELECT
    awd.*
    FROM
    igf_aw_award awd
    WHERE
    awd.award_id = p_award_id
    FOR UPDATE OF award_status NOWAIT;

    lc_awd  c_awd%ROWTYPE;

    -- Cursor which fetches all the disbursements for an Award
    CURSOR cur_awd_disb(p_award_id igf_aw_award_all.award_id%TYPE)
    IS
    SELECT row_id,disb_num
    FROM   igf_aw_awd_disb
    WHERE
    award_id  = p_award_id;

    l_retval        BOOLEAN;
    l_msgname       VARCHAR2(80);
    l_fund_type     VARCHAR2(1);
    e_next_record   EXCEPTION;

  BEGIN

    -- Log
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                    'igf.plsql.igf_aw_cancel_awd.cancel_award_fabase.debug',
                    '*** Starting to cancel award for base_id: ' ||p_base_id|| ', fund_id: ' ||p_fund_id|| ',cal_type: ' ||p_ci_cal_type|| ', seq_num: ' ||p_ci_seq_num|| ' ***');
    END IF;

    OPEN c_award(p_ci_cal_type, p_ci_seq_num, p_fund_id, p_base_id);
    fnd_file.put_line(fnd_file.log,' ');
    FETCH c_award INTO lc_award;

    IF c_award%NOTFOUND THEN
      -- No awards found satisfying the criteria
      fnd_message.set_name('IGF','IGF_AW_CANCEL_NOT_FOUND');
      fnd_file.put_line( fnd_file.log, fnd_message.get);
      CLOSE c_award;
      RETURN;
    END IF;

    LOOP
      BEGIN
        IF c_awd%ISOPEN THEN
           CLOSE c_awd;
        END IF;

        OPEN c_awd(lc_award.award_id);
        FETCH c_awd INTO lc_awd;

        IF c_awd%NOTFOUND THEN
           -- This award does not seem to exist ???
           fnd_message.set_name('IGF','IGF_AW_AWARD_NOT_FOUND');
           fnd_file.put_line( fnd_file.log, fnd_message.get);
           CLOSE c_awd;
           RAISE e_next_record;
        END IF;

        l_retval := chk_awd_cancel(lc_awd.award_id,lc_awd.base_id,lc_awd.fund_id,l_msgname);

        fnd_message.set_name('IGF', 'IGF_AW_PROCESS_AWD');
        fnd_message.set_token('AWD_ID', lc_award.award_id);
        fnd_file.put_line( fnd_file.log, fnd_message.get);

        -- Check if award can be cancelled
        IF l_retval AND chk_awd_exp_date(
                                          p_base_id         =>  lc_awd.base_id,
                                          p_fund_id         =>  lc_awd.fund_id,
                                          p_ci_cal_type     =>  p_ci_cal_type,
                                          p_ci_seq_num      =>  p_ci_seq_num,
                                          p_run_mode        =>  p_run_mode
                                        ) THEN
          -- AWARD ELIGIBLE FOR CANCELLATION

          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_aw_cancel_awd.cancel_award_fabase.debug',
                          'Award id :' ||lc_awd.AWARD_ID|| ' passed validation checks and is eligible for cancellation');
          END IF;

          --Create a SavePoint here so that whenever any of the Award/Disb/Loan is Locked then
          --We need to rollback the DMLS made for the award and proceed with the next
          --Award ID

          SAVEPOINT p_award_id;

          l_fund_type := 'G';

          --Arrive at Fund Type value to be sent to the revert disb procedure
          IF  lc_award.fed_fund_code IN ('FLP','FLS','FLU','ALT') THEN
             l_fund_type := 'F';
          ELSIF lc_award.fed_fund_code IN ('DLS','DLU','DLP')  THEN
             l_fund_type := 'D';
          ELSIF lc_award.fed_fund_code='PELL' THEN
             l_fund_type := 'P';
          END IF;

          -- Cancel Award
          igf_aw_award_pkg.update_row (
                                        x_mode                              => 'R',
                                        x_rowid                             => lc_awd.ROW_ID,
                                        x_award_id                          => lc_awd.AWARD_ID,
                                        x_fund_id                           => lc_awd.FUND_ID,
                                        x_base_id                           => lc_awd.BASE_ID,
                                        x_offered_amt                       => 0,
                                        x_accepted_amt                      => 0,
                                        x_paid_amt                          => lc_awd.PAID_AMT,
                                        x_packaging_type                    => lc_awd.PACKAGING_TYPE,
                                        x_batch_id                          => lc_awd.BATCH_ID,
                                        x_manual_update                     => lc_awd.MANUAL_UPDATE,
                                        x_rules_override                    => lc_awd.RULES_OVERRIDE,
                                        x_award_date                        => lc_awd.AWARD_DATE,
                                        x_award_status                      => 'CANCELLED',
                                        x_attribute_category                => lc_awd.ATTRIBUTE_CATEGORY,
                                        x_attribute1                        => lc_awd.ATTRIBUTE1,
                                        x_attribute2                        => lc_awd.ATTRIBUTE2,
                                        x_attribute3                        => lc_awd.ATTRIBUTE3,
                                        x_attribute4                        => lc_awd.ATTRIBUTE4,
                                        x_attribute5                        => lc_awd.ATTRIBUTE5,
                                        x_attribute6                        => lc_awd.ATTRIBUTE6,
                                        x_attribute7                        => lc_awd.ATTRIBUTE7,
                                        x_attribute8                        => lc_awd.ATTRIBUTE8,
                                        x_attribute9                        => lc_awd.ATTRIBUTE9,
                                        x_attribute10                       => lc_awd.ATTRIBUTE10,
                                        x_attribute11                       => lc_awd.ATTRIBUTE11,
                                        x_attribute12                       => lc_awd.ATTRIBUTE12,
                                        x_attribute13                       => lc_awd.ATTRIBUTE13,
                                        x_attribute14                       => lc_awd.ATTRIBUTE14,
                                        x_attribute15                       => lc_awd.ATTRIBUTE15,
                                        x_attribute16                       => lc_awd.ATTRIBUTE16,
                                        x_attribute17                       => lc_awd.ATTRIBUTE17,
                                        x_attribute18                       => lc_awd.ATTRIBUTE18,
                                        x_attribute19                       => lc_awd.ATTRIBUTE19,
                                        x_attribute20                       => lc_awd.ATTRIBUTE20,
                                        x_rvsn_id                           => lc_awd.RVSN_ID ,
                                        x_alt_pell_schedule                 => lc_awd.ALT_PELL_SCHEDULE,
                                        x_award_number_txt                  => lc_awd.AWARD_NUMBER_TXT,
                                        x_legacy_record_flag                => NULL,
                                        x_adplans_id                        => lc_awd.adplans_id,
                                        x_lock_award_flag                   => lc_awd.lock_award_flag,
                                        x_app_trans_num_txt                 => lc_awd.app_trans_num_txt,
                                        x_awd_proc_status_code              => 'AWARDED',
                                        x_notification_status_code	        => lc_awd.notification_status_code,
                                        x_notification_status_date	        => lc_awd.notification_status_date,
                                        x_publish_in_ss_flag                => lc_awd.publish_in_ss_flag
                                      );

          -- Loop Thru all the disbursements
          FOR l_disb IN cur_awd_disb(lc_awd.award_id) LOOP
            igf_db_disb.revert_disb(l_disb.row_id, 'A', l_fund_type);
          END LOOP;

          igf_aw_gen.update_fabase_awds(lc_award.base_id,'CANCELLED');

          fnd_message.set_name('IGF', 'IGF_AW_AWARD_CANCELLED');
          fnd_message.set_token('AWD', lc_award.award_id);
          fnd_message.set_token('FUND', lc_award.fund_code);
          fnd_file.put_line( fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log,1);

          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_aw_cancel_awd.cancel_award_fabase.debug',
                          'Award id :' ||lc_awd.AWARD_ID|| ' cancelled successfully');
          END IF;
      ELSE
          -- AWARD INELIGIBLE FOR CANCELLATION
          IF l_msgname IS NOT NULL THEN
            -- chk_awd_cancel() failed
            fnd_message.set_name('IGF', l_msgname);
            fnd_file.put_line( fnd_file.log, fnd_message.get);

            -- Log
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_aw_cancel_awd.cancel_award_fabase.debug',
                            'Award id :' ||lc_awd.AWARD_ID|| ' CANNOT be cancelled bcoz of the message ' ||l_msgname);
            END IF;
          ELSE
            -- chk_awd_exp_date() failed
            -- Log
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,
                            'igf.plsql.igf_aw_cancel_awd.cancel_award_fabase.debug',
                            'Award id :' ||lc_awd.AWARD_ID|| ' CANNOT be cancelled bcoz  - the award is not expired (or) award expiration offset is not setup');
            END IF;
          END IF;     -- l_msgname IS NOT NULL
      END IF;         -- l_retval AND chk_awd_exp_date

      EXCEPTION

        WHEN app_exception.record_lock_exception THEN
               ROLLBACK TO p_award_id;
               WHEN e_next_record THEN
               NULL;
      END;

      FETCH c_award INTO lc_award;
      IF c_award%NOTFOUND THEN
        CLOSE c_award;
        EXIT;
      END IF;
    END LOOP;

  END cancel_award_fabase;

     PROCEDURE cancel_award(
                             ERRBUF                OUT NOCOPY  VARCHAR2,
                             RETCODE               OUT NOCOPY  NUMBER,
                             p_award_year          IN          VARCHAR2,
                             p_fund_id             IN          igf_aw_award_all.fund_id%TYPE,
                             p_run_mode            IN          igf_lookups_view.lookup_code%TYPE,
                             p_base_id             IN          igf_ap_fa_con_v.base_id%TYPE,
                             p_org_id              IN          igf_aw_award_all.org_id%TYPE,
                             p_pig                 IN          igs_pe_all_persid_group_v.group_id%TYPE
                          ) AS
    /*
    ||  Created By : prchandr
    ||  Created On : 12-Jun-2001
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  ridas           08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
	  ||  tsailaja		    13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  bvisvana        11-Jul-2005     FA 157 and FA 140 - TBH impact for notification status code and date + Publish in ss page
    ||  veramach        1-NOV-2003      # 3160856 Added adplans_id in call to igf_aw_award.update_row
    ||  smadathi        03-Feb-2002     Bug 2154941. Modified cursor c_award to exclude sponsor fund
    ||
    ||  (reverse chronological order - newest change first)
    */

   --Bug No:-2272349 Desc :-Cancel Award Routines
   --Cursor to fetch the Fund COde for the Fund ID
   CURSOR cur_get_fund_code IS
   SELECT fund_code
   FROM   igf_aw_fund_mast
   WHERE  fund_id=p_fund_id;


   --Get the Descriptions for the Parameters Passed:
   CURSOR cur_get_parameters IS
   SELECT meaning FROM igf_lookups_view
   WHERE  lookup_type='IGF_GE_PARAMETERS'
   AND    lookup_code IN ('AWARD_ID', 'FUND_CODE', 'PARAMETER_PASS', 'PERSON_NUMBER', 'RUN_MODE', 'PERSON_ID_GROUP');

   --Cursor to fetch the alternate code for award year instance
   CURSOR cur_alt_code(p_cal_type igs_ca_inst.cal_type%TYPE,p_sequence_number igs_ca_inst.sequence_number%TYPE)
   IS
   SELECT alternate_code FROM igs_ca_inst
   WHERE  cal_type =p_cal_type
   AND    sequence_number = p_sequence_number;

   --Cursor to get the person number for the base id
   CURSOR cur_get_person IS
   SELECT person_number FROM
   igf_ap_fa_con_v
   WHERE  base_id=p_base_id;

   -- Cursor to get pig description
   CURSOR cur_get_pig_desc (cp_pig_id igs_pe_persid_group_all.group_id%TYPE)
   IS
      SELECT  description
      FROM    igs_pe_persid_group_all
      WHERE   group_id = cp_pig_id;

   --For display of heading and parameters passed
   TYPE l_parameters IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
   l_para_rec        l_parameters;
   l_alt_code        igs_ca_inst.alternate_code%TYPE;
   l_i               NUMBER(2);
   l_fund_code       igf_aw_fund_mast.fund_code%TYPE;
   l_person_no       igf_aw_award_v.person_number%TYPE;
   -----------------------------------------------------------------------------------------------------------

   l_ci_cal_type            igf_aw_award_v.ci_cal_type%TYPE;
   l_ci_sequence_number     igf_aw_award_v.ci_sequence_number%TYPE;
   l_year                   VARCHAR2(80) DEFAULT  igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
	 l_base_id								igf_ap_fa_base_rec_all.base_id%TYPE;
   l_party_id               hz_parties.party_id%TYPE;
   l_per_exists             BOOLEAN := FALSE;
   l_list                   VARCHAR2(32767);
   l_status                 VARCHAR2(1);
   l_pig_desc               igs_pe_persid_group_all.description%TYPE;
   PARAM_ERR                EXCEPTION;
   TYPE l_per_ref_cur IS REF CURSOR;
   l_per_cur                l_per_ref_cur;
   lv_group_type            igs_pe_persid_group_v.group_type%TYPE;

BEGIN
  igf_aw_gen.set_org_id(NULL);
  RETCODE:= 0;

  --------------------------------------------------------------------------------------------------------------
  --                                  Display Parameters in the log file                                      --
  --------------------------------------------------------------------------------------------------------------
  l_ci_cal_type := RTRIM(SUBSTR(p_award_year,1,10));
  l_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

  --Get the alternate code
  OPEN cur_alt_code(l_ci_cal_type, l_ci_sequence_number);
  FETCH cur_alt_code INTO l_alt_code;

  IF cur_alt_code%NOTFOUND THEN
    CLOSE cur_alt_code;
    fnd_message.set_name('IGF','IGF_SL_NO_CALENDAR');
    igs_ge_msg_stack.add;
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE cur_alt_code;

  --Get the Fund Code for Fund ID
  OPEN cur_get_fund_code;
  FETCH cur_get_fund_code INTO l_fund_code;
  CLOSE cur_get_fund_code;

  --Get the Person Number for the Base ID
  IF p_base_id IS NOT NULL THEN
     OPEN cur_get_person;
     FETCH cur_get_person INTO l_person_no;
     CLOSE cur_get_person;
  END IF;

  -- Get pig desc
  OPEN cur_get_pig_desc(p_pig);
  FETCH cur_get_pig_desc INTO l_pig_desc;
  CLOSE cur_get_pig_desc;

  --List of all Parameters:
  l_i:=0;
  OPEN cur_get_parameters;
  LOOP
    l_i:=l_i+1;
    FETCH cur_get_parameters INTO l_para_rec(l_i);
    EXIT WHEN cur_get_parameters%NOTFOUND;
  END LOOP;
  CLOSE cur_get_parameters;

  --Show the parameters passed
  fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(3),80,' '));
  fnd_file.put_line(fnd_file.log,RPAD(l_year,80,' ')||':'||RPAD(' ',4,' ')||l_alt_code);
  fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(2),80,' ')||':'||RPAD(' ',4,' ') ||NVL(l_fund_code, ''));
  fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(4),80,' ')||':'||RPAD(' ',4,' ') ||NVL(l_pig_desc, ''));
  fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(5),80,' ')||':'||RPAD(' ',4,' ') ||NVL(l_person_no, ''));
  fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(6),80,' ')||':'||RPAD(' ',4,' ') ||igf_aw_gen.lookup_desc('IGF_AW_CNC_RUN_MODE', p_run_mode));

  -- Log paramaters
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_cancel_awd.cancel_award.debug', '#### Awards - Cancel Offered Awards process - STARTS ####');
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_cancel_awd.cancel_award.debug', 'Concurrent Process Req Id: ' ||fnd_global.conc_request_id ||' ####');
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_cancel_awd.cancel_award.debug', 'PARAMETER Award yr: '      ||p_award_year);
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_cancel_awd.cancel_award.debug', 'PARAMETER Fund code: '     ||NVL(l_fund_code, ''));
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_cancel_awd.cancel_award.debug', 'PARAMETER Run mode: '      ||p_run_mode);
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_cancel_awd.cancel_award.debug', 'PARAMETER Person num: '    ||NVL(l_person_no, ''));
    fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_aw_cancel_awd.cancel_award.debug', 'PARAMETER Person Id Grp: ' ||NVL(p_pig, ''));
   END IF;

  --------------------------------------------------------------------------------------------------------------
  --                                  Parameter Validation																										--
  --------------------------------------------------------------------------------------------------------------

  -- Award Year
  IF l_ci_cal_type IS NULL OR l_ci_sequence_number IS NULL THEN
    -- Err
    fnd_message.set_name('IGS','IGS_AD_SYSCAL_CONFIG_NOT_DTMN');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    RAISE PARAM_ERR;
  END IF;

  -- Base Id and PIG
	IF (p_base_id IS NOT NULL) AND (p_pig IS NOT NULL) THEN
    -- Err
    fnd_message.set_name('IGF','IGF_SL_COD_INV_PARAM');
    fnd_message.set_token('PARAM1',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
    fnd_message.set_token('PARAM2',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);
    fnd_file.new_line(fnd_file.log, 1);
    RAISE PARAM_ERR;
	END IF;

  --------------------------------------------------------------------------------------------------------------
  --                                  Main logic starts here                                                  --
  --------------------------------------------------------------------------------------------------------------

	IF (p_base_id IS NULL) AND (p_pig IS NULL) THEN

    -- Log
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                     'igf.plsql.igf_aw_cancel_awd.cancel_award.debug',
                     'Parameters base_id and pig are NULL. Calling cancel_award_fabase');
     END IF;

		cancel_award_fabase (
													p_ci_cal_type		=>		l_ci_cal_type,
													p_ci_seq_num		=>		l_ci_sequence_number,
													p_fund_id				=>		p_fund_id,
													p_base_id				=>		NULL,
													p_run_mode			=>		p_run_mode
												);
	END IF;

	IF p_base_id IS NOT NULL THEN

    -- Log
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                     'igf.plsql.igf_aw_cancel_awd.cancel_award.debug',
                     'Parameters base_id is available and pig is NULL. Calling cancel_award_fabase');
     END IF;

    fnd_file.new_line(fnd_file.log,1);
    fnd_message.set_name('IGF', 'IGF_AW_PROCESS_STUD');
    fnd_message.set_token('STUD', l_person_no);
    fnd_file.put_line( fnd_file.log, fnd_message.get);

		cancel_award_fabase (
													p_ci_cal_type		=>		l_ci_cal_type,
													p_ci_seq_num		=>		l_ci_sequence_number,
													p_fund_id				=>		p_fund_id,
													p_base_id				=>		p_base_id,
													p_run_mode			=>		p_run_mode
												);
	END IF;

	IF p_pig IS NOT NULL THEN

      -- Log
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,
                     'igf.plsql.igf_aw_cancel_awd.cancel_award.debug',
                     'Parameters pig is available and base_id is NULL. Processing pig');
     END IF;

    --Bug #5021084
		l_list := igf_ap_ss_pkg.get_pid(p_pig, l_status, lv_group_type);
    l_per_exists := FALSE;

    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      OPEN l_per_cur FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ' USING p_pig;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      OPEN l_per_cur FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ';
    END IF;

    LOOP
      FETCH l_per_cur INTO l_party_id;
      EXIT WHEN l_per_cur%NOTFOUND;

      IF l_party_id IS NOT NULL THEN
        -- PIG contains atleast one valid party
        l_per_exists  :=  TRUE;
        l_base_id     :=  NULL;
        l_person_no   :=  NULL;


        -- Derive base_id and person_number
        get_base_id_per_num (
                              p_person_id   =>  l_party_id,
                              p_ci_cal_type =>  l_ci_cal_type,
                              p_ci_seq_num  =>  l_ci_sequence_number,
                              p_base_id     =>  l_base_id,
                              p_per_num     =>  l_person_no
                            );

        -- Check if Person number and base_id are valid
        IF (l_person_no IS NOT NULL) AND (l_base_id IS NOT NULL) THEN

          -- Log
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                         'igf.plsql.igf_aw_cancel_awd.cancel_award.debug',
                         'Calling cancel_award_fabase for base_id: ' ||l_base_id);
          END IF;

          fnd_file.new_line(fnd_file.log,1);
          fnd_message.set_name('IGF', 'IGF_AW_PROCESS_STUD');
          fnd_message.set_token('STUD', l_person_no);
          fnd_file.put_line( fnd_file.log, fnd_message.get);

          cancel_award_fabase (
                                p_ci_cal_type		=>		l_ci_cal_type,
                                p_ci_seq_num		=>		l_ci_sequence_number,
                                p_fund_id				=>		p_fund_id,
                                p_base_id				=>		l_base_id,
                                p_run_mode			=>		p_run_mode
                              );
        ELSE
          IF l_person_no IS NULL THEN
            fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5) ||fnd_message.get);
          END IF;

          IF l_base_id is NULL THEN
            fnd_message.set_name('IGF','IGF_GR_LI_PER_INVALID');
            fnd_message.set_token('PERSON_NUMBER', l_person_no);
            fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code(l_ci_cal_type, l_ci_sequence_number));
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          END IF;

        END IF;
      END IF; -- l_party_id IS NOT NULL
		END LOOP;

    IF NOT l_per_exists THEN
     -- No records found in PIG
     fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

	END IF;

  EXCEPTION

    WHEN PARAM_ERR THEN
      ROLLBACK;
      RETCODE := 2;
      fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
      ERRBUF := fnd_message.get;
      igs_ge_msg_stack.conc_exception_hndl;

    WHEN  NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN
      ROLLBACK ;
      RETCODE := 2;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_aw_cancel_awd.cancel_award');
      ERRBUF := fnd_message.get;
      igs_ge_msg_stack.conc_exception_hndl;

END cancel_award;

FUNCTION chk_awd_cancel(p_award_id       IN   igf_aw_award.award_id%TYPE,
                        p_base_id        IN   igf_aw_award.base_id%TYPE,
                        p_fund_id        IN   igf_aw_award.fund_id%TYPE,
                        p_msg_name       OUT NOCOPY  VARCHAR2) RETURN BOOLEAN IS
/*
    ||  Created On : 19-Apr-2002
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  skoppula        19-Apr-2002     Bug 2272349
    ||  (reverse chronological order - newest change first)
    */

--
-- sjadhav
-- May.14.2002.
-- Modified  for Bug 2272349
--
    CURSOR cur_fund_cd IS
    SELECT
    fcat.*
    FROM
    igf_aw_fund_mast mst,
    igf_aw_fund_Cat fcat
    WHERE
    mst.fund_id = p_fund_id AND
    fcat.fund_code = mst.fund_code;

    l_fund_rec     cur_fund_cd%ROWTYPE;

    CURSOR cur_pell_ack IS
    SELECT
    orig_Action_code,origination_id
    FROM
    igf_gr_rfms
    WHERE
    award_id = p_award_id;
    l_pell_ack_rec cur_pell_ack%ROWTYPE;

    CURSOR cur_pell_disb(cp_orig_id igf_gr_rfms.origination_id%TYPE) IS
    SELECT
    disb.disb_ack_act_status
    FROM
    igf_gr_rfms_disb disb
    WHERE
    disb.origination_id = cp_orig_id;
    l_pell_disb_rec cur_pell_disb%ROWTYPE;

    CURSOR cur_dl_disb IS
    SELECT disb_status
    FROM
    igf_db_Awd_disb_dtl
    WHERE
    award_id = p_award_id;

    l_dl_disb_rec cur_dl_disb%ROWTYPE;
    lv_var        VARCHAR2(30);

    lb_ret_val    BOOLEAN;

BEGIN

    lb_ret_val := TRUE;

    OPEN cur_fund_cd;
    FETCH cur_fund_cd INTO l_fund_rec;
    CLOSE cur_fund_cd;

    IF l_fund_rec.fed_fund_code NOT IN ('PELL',
                                        'DLS','DLP','DLU',
                                        'FLS','FLP','FLU',
                                        'ALT') THEN
       lb_ret_val := TRUE;
    END IF;


    IF l_fund_rec.fed_fund_code = 'PELL' THEN

        OPEN cur_pell_Ack;
        FETCH cur_pell_ack INTO l_pell_Ack_rec;

        IF  cur_pell_Ack%FOUND THEN

            IF l_pell_ack_rec.orig_Action_code = 'S' THEN

              p_msg_name := 'IGF_AW_PELL_ACK_PEND';
              CLOSE cur_pell_ack;
              lb_ret_val := FALSE;

            ELSE

              OPEN cur_pell_disb(l_pell_ack_rec.origination_id);
              LOOP
                      FETCH cur_pell_disb INTO l_pell_disb_rec;
                      EXIT WHEN cur_pell_disb%NOTFOUND;

                      IF l_pell_disb_rec.disb_ack_act_status = 'S' THEN
                            p_msg_name := 'IGF_AW_PELL_DISB_ACK_PEND';
                            lb_ret_val := FALSE;
                            EXIT;
                      END IF;

              END LOOP;

              IF  cur_pell_ack%ISOPEN THEN
                    CLOSE cur_pell_ack;
              END IF;

              IF  cur_pell_disb%ISOPEN THEN
                    CLOSE cur_pell_disb;
              END IF;


            END IF;


        END IF;

    ELSIF l_fund_rec.fed_fund_code IN ('DLP','DLS','DLU') THEN

        lv_var := igf_sl_award.chk_loan_upd_lock(p_award_id);

        IF lv_var='TRUE' THEN
           p_msg_name := 'IGF_AW_LOAN_SENT';
           lb_ret_val := FALSE;

        ELSE
           OPEN cur_dl_disb;
           LOOP

              FETCH cur_dl_disb INTO l_dl_disb_rec;
              EXIT WHEN cur_dl_disb%NOTFOUND;
                 IF l_dl_disb_rec.disb_status = 'S' THEN
                   p_msg_name := 'IGF_AW_DL_DISB_ACK_PEND';
                   lb_ret_val := FALSE;
                   EXIT;
                 END IF;
           END LOOP;

           IF  cur_dl_disb%ISOPEN THEN
               CLOSE cur_dl_disb;
           END IF;

        END IF;

    ELSIF l_fund_rec.fed_fund_code IN ('ALT','FLP','FLS','FLU') THEN

         lv_var := igf_sl_award.chk_loan_upd_lock(p_award_id);

         IF lv_var='TRUE' THEN
            p_msg_name := 'IGF_AW_LOAN_SENT';
            lb_ret_val := FALSE;
         END IF;

    END IF;


   IF  cur_fund_cd%ISOPEN THEN
       CLOSE cur_fund_cd;
   END IF;

   IF  cur_pell_ack%ISOPEN THEN
       CLOSE cur_pell_ack;
   END IF;

   IF  cur_pell_disb%ISOPEN THEN
       CLOSE cur_pell_disb;
   END IF;

   IF  cur_dl_disb%ISOPEN THEN
       CLOSE cur_dl_disb;
   END IF;

   RETURN lb_ret_val;


EXCEPTION

WHEN OTHERS THEN


        IF  cur_fund_cd%ISOPEN THEN
            CLOSE cur_fund_cd;
        END IF;

        IF  cur_pell_ack%ISOPEN THEN
            CLOSE cur_pell_ack;
        END IF;

        IF  cur_pell_disb%ISOPEN THEN
            CLOSE cur_pell_disb;
        END IF;

        IF  cur_dl_disb%ISOPEN THEN
            CLOSE cur_dl_disb;
        END IF;

        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','igf_aw_cancel_awd.chk_awd_cancel');
        igs_ge_msg_stack.conc_exception_hndl;
        RETURN FALSE;

END chk_awd_cancel;

END igf_aw_cancel_awd;

/
