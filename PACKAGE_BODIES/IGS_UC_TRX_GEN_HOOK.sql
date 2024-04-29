--------------------------------------------------------
--  DDL for Package Body IGS_UC_TRX_GEN_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_TRX_GEN_HOOK" AS
/* $Header: IGSUC21B.pls 120.2 2006/08/21 03:51:45 jbaber noship $ */
  l_alt_appl_id  igs_ad_appl.alt_appl_id%TYPE;
  lv_choice_no  igs_uc_transactions.choice_no%TYPE;
  lv_person_number  igs_pe_person.person_number%TYPE;
  lv_admission_appl_number  igs_uc_transactions.app_no%TYPE;
  lv_nominated_course_cd  igs_ad_ps_appl_inst.nominated_course_cd%TYPE;
  lv_sequence_number  igs_ad_ps_appl_inst.sequence_number%TYPE;
  lv_out_come_status  igs_ad_ps_appl_inst.adm_outcome_status%TYPE;
  lv_cond_offer_status  igs_ad_ps_appl_inst.adm_cndtnl_offer_status%TYPE;
  lv_system_outcome_status igs_ad_ou_stat.s_adm_outcome_status%TYPE;
  lv_return1 igs_uc_transactions.return1%TYPE;
  lv_return2 igs_uc_transactions.return2%TYPE;

  PROCEDURE create_ucas_transactions(
    p_ucas_id  IN igs_pe_person.api_person_id%TYPE,
    p_choice_number IN igs_uc_transactions.choice_no%TYPE,
    p_person_number IN igs_pe_person.person_number%TYPE,
    p_admission_appl_number IN igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
    p_nominated_course_cd IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
    p_sequence_number IN igs_ad_ps_appl_inst.sequence_number%TYPE,
    p_outcome_status IN igs_ad_ps_appl_inst.adm_outcome_status%TYPE,
    p_cond_offer_status IN igs_ad_ps_appl_inst.adm_cndtnl_offer_status%TYPE,
    p_alt_appl_id  IN igs_ad_appl.alt_appl_id%TYPE,
    p_condition_category IN igs_uc_offer_conds.condition_category%TYPE DEFAULT NULL,
    p_condition_name IN igs_uc_offer_conds.condition_name%TYPE DEFAULT NULL,
    p_uc_tran_id OUT NOCOPY NUMBER
  ) IS

    /*************************************************************
    Created By      : vbandaru
    Date Created By : 23-JAN-2002
    Purpose :

    Know limitations, enhancements or remarks
    Change History
    Who         When            What
    anwest      29-May-2006     Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
    rbezawad    31-Jul-2002     While creating the LD Transaction with Withdrawn Status(W), the comments_in_offer field was being populated
                                with the text 'WITHDRAWN'.  The code removed and the parameter is passed with NULL value w.r.t. Bug 2483587.
    rbezawad    17-Sep-2002     Added logic to create RD or RX transactions in clearing period.  And also added logic to add the message to stack
                                  which was returned with return1, return2 OUT NOCOPY parameters when some error is occurred in igs_uc_tran_processor_pkg.trans_build().
                                  Modifications are done w.r.t. UCFD06 Build 2570389.
    smaddali   02-oct-2002    Modified for bug 2603384 ,
                              1) added 3 new parameters to trans_build call .passing auto_generated_flag='Y' since
                                 these transactions are automatically generated
    pmarada    14-Nov-2002    Modified as per the small systems TD, added the p_alt_appl_id parameter
    (reverse chronological order - newest change first)
    ***************************************************************/

     -- Get the ucas_cycle from app_choices;
     CURSOR cur_cycle(cp_app_no igs_uc_app_choices.app_no%TYPE, cp_choice_no igs_uc_app_choices.choice_no%TYPE) IS
     SELECT MAX(ucas_cycle) FROM igs_uc_app_choices
       WHERE  app_no = cp_app_no
       AND    choice_no = cp_choice_no;

      l_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE;

     -- Get the decision and reply, program details for the applicant choice.
    CURSOR c_app_choices(cp_app_no  igs_uc_app_choices.app_no%TYPE,
                         cp_choice_no  igs_uc_app_choices.choice_no%TYPE,
                         cp_ucas_cycle igs_uc_app_choices.ucas_cycle%TYPE) IS
      SELECT decision, reply , ucas_program_code, campus
      FROM   igs_uc_app_choices
      WHERE  app_no= cp_app_no
        AND  choice_no = cp_choice_no
        AND  ucas_cycle = cp_ucas_cycle;

      -- Get the system code using the alternate application id (appno)
    CURSOR cur_system_code(cp_appno igs_uc_applicants.app_no%TYPE) IS
    SELECT system_code FROM igs_uc_applicants WHERE app_no = cp_appno;

     -- Check whether clearing flag is set for the system
     CURSOR cur_clearing (cp_system_code igs_uc_cyc_defaults.system_code%TYPE,
                          cp_ucas_cycle  igs_uc_cyc_defaults.ucas_cycle%TYPE  ) IS
     SELECT clearing_flag FROM igs_uc_cyc_defaults
     WHERE system_code = cp_system_code
       AND ucas_cycle = cp_ucas_cycle;
       l_clearing igs_uc_cyc_defaults.clearing_flag%TYPE;

     -- Check whether exists any clearing record for the applicant.
    CURSOR cur_app_clearing(cp_app_no igs_uc_app_clearing.app_no%TYPE) IS
      SELECT 'X'
      FROM igs_uc_app_clearing
      WHERE app_no = cp_app_no;

    app_clearing_rec cur_app_clearing%ROWTYPE;

     -- Check whether exists any clearing round details for the applicant.
    CURSOR cur_app_clr_rnd(cp_app_no igs_uc_app_clr_rnd.app_no%TYPE) IS
      SELECT 'X'
      FROM igs_uc_app_clr_rnd
      WHERE app_no = cp_app_no;

    -- To Fetch the Decision Mapping to Admission Outcome Status for a UCAS System
    CURSOR ucas_decision_cd_cur( p_system_code igs_uc_map_out_stat.system_code%TYPE,
                                 p_adm_outcome_status igs_uc_map_out_stat.adm_outcome_status%TYPE) IS
    SELECT decision_code
    FROM igs_uc_map_out_stat
    WHERE system_code = p_system_code AND
          adm_outcome_status = p_adm_outcome_status AND
          closed_ind = 'N';

    -- To Fetch the Name of the UCAS System
    CURSOR system_name_cur ( p_system_code igs_uc_defaults.system_code%TYPE) IS
      SELECT name
      FROM igs_uc_defaults
      WHERE system_code = p_system_code;

    app_clr_rnd_rec cur_app_clr_rnd%ROWTYPE;

    l_decision_value     igs_uc_app_choices.decision%TYPE;
    l_transaction_type   igs_uc_transactions.transaction_type%TYPE;
    l_decision           igs_uc_app_choices.decision%TYPE;
    l_reply              igs_uc_app_choices.reply%TYPE;
    l_ucas_program_code  igs_uc_app_choices.ucas_program_code%TYPE;
    l_campus             igs_uc_app_choices.campus%TYPE;
    l_system_code        igs_uc_cyc_defaults.system_code%TYPE;
    l_system_name        igs_uc_defaults.name%TYPE;
    l_validate_error_cd  igs_lookup_values.lookup_code%TYPE;
    l_transaction_toy igs_uc_ucas_control.transaction_toy_code%TYPE;

  BEGIN

    SAVEPOINT ucas_transactions;

    l_system_name := NULL;
    l_decision_value := NULL;
    l_alt_appl_id := TO_NUMBER(p_alt_appl_id);        --alternate application id
    lv_choice_no := TO_NUMBER(p_choice_number);
    lv_person_number := p_person_number;
    lv_admission_appl_number := p_admission_appl_number;
    lv_nominated_course_cd := p_nominated_course_cd;
    lv_sequence_number := p_sequence_number;
    lv_out_come_status := p_outcome_status;
    lv_cond_offer_status := p_cond_offer_status;
    lv_system_outcome_status := igs_ad_gen_008.admp_get_saos(lv_out_come_status);  -- It returns the system outcome status
    p_uc_tran_id := NULL;

    OPEN cur_cycle(l_alt_appl_id,lv_choice_no);
    FETCH cur_cycle INTO l_ucas_cycle;
    CLOSE cur_cycle;

    -- Get the Ucas decision, reply and Ucas program ,campus details for further usage
    OPEN c_app_choices(l_alt_appl_id,lv_choice_no,l_ucas_cycle);
    FETCH c_app_choices INTO l_decision, l_reply, l_ucas_program_code, l_campus;

     -- check whether any records exists for the applicant choices
    IF (c_app_choices%NOTFOUND) THEN
        CLOSE c_app_choices;
        fnd_message.set_name('IGS','IGS_UC_DEC_REP_NOT_FOUND');
        fnd_message.set_token('APPNO', l_alt_appl_id);
        fnd_message.set_token('CHOICENO', TO_CHAR(lv_choice_no));
        igs_ge_msg_stack.add;
        RETURN;
    ELSE
       -- get the system code for the applicant.
      OPEN cur_system_code(l_alt_appl_id);
      FETCH cur_system_code INTO l_system_code;
      CLOSE cur_system_code;

       -- get the Decision Code maaped to the System Code and Admission Outcome Status
      OPEN ucas_decision_cd_cur (l_system_code, lv_out_come_status);
      FETCH ucas_decision_cd_cur INTO l_decision_value;

      -- check whether any records exists in the mapping table
      IF (ucas_decision_cd_cur%NOTFOUND) THEN
          CLOSE ucas_decision_cd_cur;

          OPEN system_name_cur(l_system_code);
          FETCH system_name_cur INTO l_system_name;
          CLOSE system_name_cur;

          fnd_message.set_name('IGS','IGS_UC_DECISION_MAP_NOT_FOUND');
          fnd_message.set_token('SYS_NAME',l_system_name );
          fnd_message.set_token('ADM_OUTSTAT', lv_out_come_status);
          igs_ge_msg_stack.add;
          RETURN;
      END IF;
      CLOSE ucas_decision_cd_cur;

        -- Get the clearing flag value for the the system, for checking the system allows clearing or not
      OPEN cur_clearing(l_system_code,l_ucas_cycle);
      FETCH cur_clearing INTO l_clearing;
      CLOSE cur_clearing;

      -- If processing period is clearing then generate RX, RD transactions
      -- Get the transaction time of year, call to the get_transaction_toy
         l_transaction_toy := NULL;
      igs_uc_gen_001.get_transaction_toy(p_system_code     => l_system_code,
                                         p_ucas_cycle      => l_ucas_cycle ,
                                         p_transaction_toy => l_transaction_toy);

      IF (l_transaction_toy = 'C' AND l_clearing = 'Y') THEN
        -- Check whether there exists any clearing details for the applicant
        OPEN cur_app_clearing(l_alt_appl_id);
        FETCH cur_app_clearing INTO app_clearing_rec;
         -- Check whether there exists any clearing round details for the applicant
        OPEN cur_app_clr_rnd(l_alt_appl_id);
        FETCH cur_app_clr_rnd INTO app_clr_rnd_rec;

        -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
        IF cur_app_clearing%FOUND AND
           lv_system_outcome_status IN ('OFFER', 'COND-OFFER') AND
           (l_ucas_cycle >= 2006 OR cur_app_clr_rnd%FOUND) THEN

               -- Create a RX transaction with the decision A
               igs_uc_tran_processor_pkg.trans_build ( p_tran_type       => 'RX',
                                                  p_app_no          => l_alt_appl_id,
                                                  p_choice_no       => lv_choice_no,
                                                  p_decision        => l_decision_value,
                                                  p_course          => l_ucas_program_code,
                                                  p_campus          => l_campus,
                                                  p_entry_month     => NULL,
                                                  p_entry_year      => NULL,
                                                  p_entry_point     => NULL,
                                                  p_soc             => NULL,
                                                  p_free_format     => NULL,
                                                  p_hold            => 'Y',
                                                  p_return1         => lv_return1,
                                                  p_return2         => lv_return2,
                                                  p_inst_reference  => NULL ,
                                                  p_cond_cat        => p_condition_category,
                                                  p_cond_name       => p_condition_name,
                                                  p_auto_generated  => 'Y',
                                                  p_system_code     => l_system_code,
                                                  p_ucas_cycle      => l_ucas_cycle,
                                                  p_modular         => NULL,
                                                  p_part_time       => NULL,
                                                  p_uc_tran_id      => p_uc_tran_id,
                                                  p_validate_error_cd => l_validate_error_cd
                                                );

        -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
        ELSIF (lv_system_outcome_status IN ('OFFER', 'REJECTED')) THEN
            -- Create a RD transaction with decision A
            igs_uc_tran_processor_pkg.trans_build ( p_tran_type       =>  'RD',
                                                    p_app_no          =>  l_alt_appl_id,
                                                    p_choice_no       =>  lv_choice_no,
                                                    p_decision        =>  l_decision_value,
                                                    p_course          =>  NULL,
                                                    p_campus          =>  NULL,
                                                    p_entry_month     =>  NULL,
                                                    p_entry_year      =>  NULL,
                                                    p_entry_point     =>  NULL,
                                                    p_soc             =>  NULL,
                                                    p_free_format     =>  NULL,
                                                    p_hold            =>  'N',
                                                    p_return1         =>  lv_return1,
                                                    p_return2         =>  lv_return2,
                                                    p_inst_reference  =>  NULL,
                                                    p_cond_cat        =>  p_condition_category,
                                                    p_cond_name       =>  p_condition_name,
                                                    p_auto_generated  => 'Y',
                                                    p_system_code     => l_system_code,
                                                    p_ucas_cycle      => l_ucas_cycle,
                                                    p_modular         => NULL,
                                                    p_part_time       => NULL,
                                                    p_uc_tran_id      => p_uc_tran_id,
                                                    p_validate_error_cd => l_validate_error_cd
                                                  );
        ELSE
            fnd_message.set_name('IGS','IGS_UC_CREATE_TRANSACTION');
            igs_ge_msg_stack.add;
            RETURN;
        END IF;

        CLOSE cur_app_clearing;
        CLOSE cur_app_clr_rnd;

      ELSE   -- Processing period is not in clearing

        IF (lv_system_outcome_status IN ('OFFER','REJECTED')) THEN

            -- Both decision and reply are null then call the transaction builder with transaction LD
           IF l_decision IS NULL AND l_reply IS NULL THEN
                 l_transaction_type := 'LD';
           -- smaddali added decision A to the list for bug#3096471
           ELSIF l_decision IN ('U','A','C','W','R','B','F','S','E','I','M','X','G')  AND l_reply IS NULL THEN
                 -- Call the transaction builder with transaction LA
                 l_transaction_type := 'LA';

           ELSIF l_decision IN ('C','I') AND l_reply IN  ('F','I') THEN
                 -- Call the transaction builder with RD transaction.
                 l_transaction_type := 'RD';
           ELSE
                 fnd_message.set_name('IGS','IGS_UC_CREATE_TRANSACTION');
                 igs_ge_msg_stack.add;
                 RETURN;
           END IF;

        -- Smaddali added the check for outcome status = SUSPEND along with WITHDRAWN for bug# 2593568
        -- Even when the outcome status is changed to SUSPEND ,the same transaction should be
        -- generated as for WITHDRAWN
        ELSIF (lv_system_outcome_status IN ('WITHDRAWN','SUSPEND') ) THEN
           IF l_decision IS NULL AND l_reply IS NULL THEN
                 -- Call the transaction builder with LD
                 l_transaction_type := 'LD';
           -- smaddali added decision A to the list for bug#3096471
           ELSIF l_decision IN ('U','A','C','R','B','F','S','E','I','M','X','G') AND l_reply IS NULL THEN
                 -- call the transaction builder with LA
                 l_transaction_type := 'LA';

           ELSIF l_decision IN ('C','I') AND l_reply IN ('F','I') THEN
                 -- Call the transaction builder with LA
                 l_transaction_type := 'LA';
           -- smaddali added decision A to the list for bug#3096471
           ELSIF l_decision IN ('U','A') AND l_reply = 'F' THEN
                 -- Call the transaction builder with RW
                 l_transaction_type := 'RW';

           ELSE
                 fnd_message.set_name('IGS','IGS_UC_CREATE_TRANSACTION');
                 igs_ge_msg_stack.add;
                 RETURN;
           END IF;

        ELSIF (lv_system_outcome_status = 'COND-OFFER') THEN
           IF l_decision IS NULL AND l_reply IS NULL THEN
               -- Call the transaction builder with LD
               l_transaction_type := 'LD';
           -- smaddali Added decisions I and A to the list for bug#3096471
           ELSIF l_decision IN ('U','A','W','R','B','F','S','E','I','M','X','G')  AND l_reply IS NULL THEN
               -- Call the transaction builder with LA
               l_transaction_type := 'LA';

           ELSE
               fnd_message.set_name('IGS','IGS_UC_CREATE_TRANSACTION');
               igs_ge_msg_stack.add;
               RETURN;
           END IF;

        ELSE
           fnd_message.set_name('IGS','IGS_UC_CREATE_TRANSACTION');
           igs_ge_msg_stack.add;
           RETURN;
        END IF; -- End if for system status

        -- Call the transaction builder for the above transactions
        IF l_transaction_type IS NOT NULL AND l_decision_value IS NOT NULL THEN
          igs_uc_tran_processor_pkg.trans_build ( p_tran_type       =>  l_transaction_type,
                                                  p_app_no          =>  l_alt_appl_id,
                                                  p_choice_no       =>  lv_choice_no,
                                                  p_decision        =>  l_decision_value,
                                                  p_course          =>  NULL,
                                                  p_campus          =>  NULL,
                                                  p_entry_month     =>  NULL,
                                                  p_entry_year      =>  NULL,
                                                  p_entry_point     =>  NULL,
                                                  p_soc             =>  NULL,
                                                  p_free_format     =>  NULL,
                                                  p_hold            =>  'N',
                                                  p_return1         =>  lv_return1,
                                                  p_return2         =>  lv_return2,
                                                  p_inst_reference  =>  NULL,
                                                  p_cond_cat        =>  p_condition_category,
                                                  p_cond_name       =>  p_condition_name,
                                                  p_auto_generated  => 'Y',
                                                  p_system_code     => l_system_code,
                                                  p_modular         => NULL,
                                                  p_part_time       => NULL,
                                                  p_ucas_cycle      => l_ucas_cycle,
                                                  p_uc_tran_id      => p_uc_tran_id,
                                                  p_validate_error_cd => l_validate_error_cd
                                                );
        END IF;

      END IF;  -- Clearing Period Check

    END IF;
    CLOSE c_app_choices;

    IF (lv_return1 = 1) THEN
      fnd_message.set_name('IGS',lv_return2);
      igs_ge_msg_stack.add;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
     -- Incase if there is any exception, the rollback is limited to only ucas transaction.
     -- changes as per bug# 2459877.
      ROLLBACK TO ucas_transactions;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_TRX_GEN_HOOK.CREATE_UCAS_TRANSACTIONS');
      igs_ge_msg_stack.add;
  END create_ucas_transactions;

END igs_uc_trx_gen_hook;

/
