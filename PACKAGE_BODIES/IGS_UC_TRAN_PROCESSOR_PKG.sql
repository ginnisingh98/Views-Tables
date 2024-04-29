--------------------------------------------------------
--  DDL for Package Body IGS_UC_TRAN_PROCESSOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_TRAN_PROCESSOR_PKG" AS
/* $Header: IGSUC23B.pls 120.9 2006/08/21 03:52:08 jbaber noship $ */

  lv_rowid VARCHAR2(26);
  l_uc_tran_id igs_uc_transactions.UC_Tran_Id%TYPE;
  l_tranid NUMBER := 0;

 PROCEDURE trans_build ( P_Tran_type      IN igs_uc_transactions.transaction_type%TYPE,
                         P_App_no         IN igs_uc_transactions.app_no%TYPE,
                         P_Choice_no      IN igs_uc_transactions.choice_no%TYPE,
                         P_Decision       IN igs_uc_transactions.decision%TYPE,
                         P_Course         IN igs_uc_transactions.program_code%TYPE,
                         P_Campus         IN igs_uc_transactions.campus%TYPE,
                         P_Entry_month    IN igs_uc_transactions.entry_month%TYPE,
                         P_Entry_year     IN igs_uc_transactions.entry_year%TYPE,
                         P_Entry_point    IN igs_uc_transactions.entry_point%TYPE,
                         P_SOC            IN igs_uc_transactions.SOC%TYPE,
                         P_Free_Format    IN igs_uc_transactions.comments_in_offer%TYPE,
                         P_Hold           IN igs_uc_transactions.hold_flag%TYPE,
                         P_return1        OUT NOCOPY igs_uc_transactions.return1%TYPE,
                         P_return2        OUT NOCOPY igs_uc_transactions.return2%TYPE,
                         P_Inst_reference IN  igs_uc_transactions.inst_reference%TYPE  ,
                         P_cond_cat       IN igs_uc_transactions.test_cond_cat%TYPE ,
                         P_cond_name      IN igs_uc_transactions.test_cond_name%TYPE ,
                         P_auto_generated IN igs_uc_transactions.auto_generated_flag%TYPE,
                         p_system_code    IN igs_uc_transactions.system_code%TYPE,
                         p_ucas_cycle     IN igs_uc_transactions.ucas_cycle%TYPE,
                         p_modular        IN  igs_uc_transactions.modular%TYPE DEFAULT NULL,
                         p_part_time      IN  igs_uc_transactions.part_time%TYPE DEFAULT NULL,
                         p_uc_tran_id     OUT NOCOPY igs_uc_transactions.uc_tran_id%TYPE,
                         p_validate_error_cd OUT NOCOPY igs_lookup_values.lookup_code%TYPE,
                         p_mode           IN VARCHAR2
   ) IS

    /*************************************************************
    Created By      : solakshm
    Date Created By : 23-JAN-2002
    Purpose : To build transaction records from parameter values and store in
      IGS_UC_TRANSACTIONS.
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    rbezawad     19-Oct-2002  Modified for Bug 2628587
                               While generating the LD transaction, removed the validation which is
                               checking the P_free_format value to be not null when decision = W.
    smaddali     02-oct-2002  modified for bug 2603384
                                1) added 3 new parameters p_cond_cat, p_cond_nae ,p_auto_generated
                                2) modifying tbh calls igs_uc_transactions_pkg to add x_auto_generated_flag
                                3) passing calues of p_cond_cat and p_cond_name to x_test_cond_cat and x_test_cond_name
                                      instead of NULL in tbh calls of igs_uc_transactions_pkg
    rbezawad     02-Apr-2002    Modified w.r.t. UCCR002 DLD. Bug No:2278817.
                                1) Passed Entry year, Entry month fields for LC type transactions.
                                2) RX Transactions are validated to always accept decision value 'A'.
                                3) Inst_reference field is added as data model is effected.
    pmarada      12-nov-2002    Added the system_code parameter.
    pmarada      09-Jun-2003    Added ucas cycle parameter, and transactions generating for only current cycle.
    pmarada      01-nov-03      Added  and p_valide_error_cd parameters as per UC208 build.
    jchakrab     08-Jun-2005    Added parameter p_mode for IGS.M Security Solution - 4380412
    jbaber       18-Jul-03      Added cur_find_appclear_2006 for UC315 - UCAS 2006 Support
    anwest       29-May-06      Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
    (reverse chronological order - newest change first)
    ***************************************************************/

     CURSOR cur_find_deceased IS
      SELECT b.deceased_ind FROM igs_uc_applicants a,igs_pe_hz_parties b
              WHERE a.app_no = P_App_no AND a.oss_person_id = b.party_id;

     -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
     CURSOR cur_find_trans(cp_transaction_type igs_uc_transactions.transaction_type%TYPE) IS
        SELECT COUNT(*)
        FROM   igs_uc_transactions
        WHERE  app_no = P_App_no
        AND    choice_no = P_Choice_no
        AND    ucas_cycle = p_ucas_cycle
        AND    transaction_type = cp_transaction_type;

     CURSOR cur_app_choice_decision IS
        SELECT decision,reply FROM igs_uc_app_choices
              WHERE app_no = P_App_no
                AND choice_no = P_Choice_no
                AND ucas_cycle = p_ucas_cycle;

     CURSOR cur_find_RD IS
        SELECT COUNT(*) FROM igs_uc_transactions
           WHERE app_no = P_App_no
             AND ucas_cycle = p_ucas_cycle
             AND transaction_type = 'RD';

      CURSOR cur_find_appclear IS
        SELECT COUNT(*) FROM  igs_uc_u_cvname_2003
              WHERE appno = P_App_no;

      CURSOR cur_find_appclear_2006 IS
        SELECT COUNT(*) FROM  igs_uc_u_cvname_2003
              WHERE appno =
               (SELECT LPAD((app_no||check_digit),9,0) from IGS_UC_APPLICANTS where app_no = P_App_no);

    -- Check whether there exists any applicant record for generating PE
    CURSOR cur_applicants IS
    SELECT COUNT(*) FROM igs_uc_applicants WHERE app_no = p_app_no;

    -- Get the count of records exists in the choices tabel between 1 to  6 choices, for PE
    CURSOR cur_choices IS
    SELECT COUNT(*) FROM igs_uc_app_choices
    WHERE app_no = p_app_no AND (choice_no BETWEEN 1 AND 6)
      AND ucas_cycle = p_ucas_cycle
      AND institute_code = (SELECT current_inst_code FROM igs_uc_defaults WHERE system_code = p_system_code);

   -- Check whether record exists in app_chocies for the cycle
   CURSOR cur_rec_found(cp_appno igs_uc_app_choices.app_no%TYPE,
                        cp_choice_no   igs_uc_app_choices.choice_no%TYPE,
                        cp_ucas_cycle  igs_uc_app_choices.ucas_cycle%TYPE,
                        cp_system_code igs_uc_app_choices.system_code%TYPE) IS
     SELECT 'X' FROM igs_uc_app_choices
     WHERE app_no      = cp_appno
       AND choice_no   = cp_choice_no
       AND ucas_cycle  = cp_ucas_cycle
       AND system_code = cp_system_code;
    l_rec_found VARCHAR2(1);

   CURSOR c_transactions(cp_uc_tran_id igs_uc_transactions.uc_tran_id%TYPE) IS
   SELECT t.ROWID, t.* FROM igs_uc_transactions t
   WHERE uc_tran_id = cp_uc_tran_id;

   l_transactions c_transactions%ROWTYPE;

     l_decision igs_uc_app_choices.decision%TYPE;
     l_reply igs_uc_app_choices.reply%TYPE;
     l_cnt NUMBER;
     l_cnt1 NUMBER;
     l_deceased_ind igs_pe_hz_parties.deceased_ind%TYPE;
     l_return1 igs_uc_transactions.return1%TYPE;
     l_return2 igs_uc_transactions.return2%TYPE;
     l_generate VARCHAR2(1);
     l_generate_tran VARCHAR2(1);
     l_soc                igs_uc_transactions.soc%TYPE;
     l_comments_in_offer  igs_uc_transactions.comments_in_offer%TYPE;
     l_error_code         igs_lookup_values.lookup_code%TYPE;
     l_hold               igs_uc_transactions.hold_flag%TYPE;
     l_transaction_toy    igs_uc_ucas_control.transaction_toy_code%TYPE;

  BEGIN

    OPEN cur_find_deceased;
    FETCH cur_find_deceased INTO l_deceased_ind;
    CLOSE cur_find_deceased;

    l_return1:=0;
    l_generate_tran := 'N';
    p_uc_tran_id := NULL;

    --Check if the person is deceased or not.  If deseased, raise the error message.
    IF l_deceased_ind = 'Y' THEN
      P_return1 := 1;
      P_return2 := 'IGS_UC_APP_DEAD';
    ELSE
      -- Check whether record exists in app_choices table or not with appno, chocie, cycle, system
      OPEN cur_rec_found(P_App_no, P_Choice_no, p_ucas_cycle, p_system_code );
      FETCH cur_rec_found INTO l_rec_found;
      IF cur_rec_found%NOTFOUND THEN
         CLOSE cur_rec_found;
         p_return1 := 1;
         p_return2 := 'IGS_UC_INVALID_APP_CH_CYCLE';
      ELSE
         CLOSE cur_rec_found;

          -- Get the transaction time of year value, and used to derive hold flag value for some transactions
          -- call to the get_transaction_toy
            l_transaction_toy := NULL;
           igs_uc_gen_001.get_transaction_toy(p_system_code     => p_system_code,
                                              p_ucas_cycle      => p_ucas_cycle ,
                                              p_transaction_toy => l_transaction_toy);

           -- If Hold Profile value set then hold flag value is Y
           IF fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION') = 'Y' THEN
              l_Hold := 'Y' ;
           ELSE
              l_hold := NVL(p_hold,'N');
           END IF;

           -- call the transaction population process to get the SOC and comments in offer values
           IF P_cond_cat IS NOT NULL AND P_cond_name IS NOT NULL THEN
              igs_uc_tran_processor_pkg.transaction_population(
                                p_condition_category1 => P_cond_cat,
                                p_condition_name1     => P_cond_name,
                                p_soc1                => l_soc,
                                p_comments_in_offer   => l_comments_in_offer);

              IF l_soc IS NULL THEN
                l_soc := p_soc;
              END IF;
              IF l_comments_in_offer IS NULL THEN
                 l_comments_in_offer := P_Free_Format;
              END IF;
           ELSE
              l_soc := p_soc;
              l_comments_in_offer := P_Free_Format;
           END IF;

         IF (P_Tran_type = 'LA') THEN
           --Check for Mandatory Parameters.
           IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_Decision IS NOT NULL AND P_Hold IS NOT NULL
                                   AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
             -- For generating a LA transaction, there should exists at least one LD transaction
              -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
              OPEN cur_find_trans('LD');
              FETCH cur_find_trans INTO l_cnt;
              CLOSE cur_find_trans;

              IF l_cnt > 0 THEN
                 P_return1 := 0;
                 igs_uc_transactions_pkg.insert_row (
                                x_mode                              => p_mode,   --jchakrab modified for 4380412
                                x_rowid                             => lv_rowid,
                                x_uc_tran_id                        => l_uc_tran_id,
                                x_transaction_id                    => NULL,
                                x_datetimestamp                     => NULL,
                                x_updater                           => NULL,
                                x_error_code                        => NULL,
                                x_transaction_type                  => P_Tran_type,
                                x_app_no                            => P_App_no,
                                x_choice_no                         => P_Choice_no,
                                x_decision                          => P_Decision,
                                x_program_code                      => P_Course,
                                x_campus                            => P_Campus,
                                x_entry_month                       => P_Entry_month,
                                x_entry_year                        => P_Entry_year,
                                x_entry_point                       => P_Entry_point,
                                x_soc                               => l_soc,
                                x_comments_in_offer                 => l_comments_in_offer,
                                x_return1                           => l_return1,
                                x_return2                           => l_return2,
                                x_hold_flag                         => l_hold,
                                x_sent_to_ucas                      => 'N',
                                x_test_cond_cat                     => P_cond_cat,
                                x_test_cond_name                    => P_cond_name,
                                x_inst_reference                    => P_Inst_reference ,
                                x_auto_generated_flag               => P_auto_generated,
                                x_system_code                       => p_system_code,
                                x_ucas_cycle                        => p_ucas_cycle,
                                x_modular                           => p_modular,
                                x_part_time                         => p_part_time);

                  -- Call the transaction validation process
                   l_error_code := NULL;
                 igs_uc_tran_processor_pkg.transaction_validation(p_transaction_type  => P_Tran_type,
                                                                  p_decision          => P_Decision,
                                                                  p_comments_in_offer => l_comments_in_offer,
                                                                  p_error_code        => l_error_code);

                  -- If transaction has an error then set the hold flag Y
                 IF l_error_code IS NOT NULL AND NVL(fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION'),'N') = 'N' THEN
                     -- get the hold profile value and update the transactions with hold flag Y
                     OPEN c_transactions(l_uc_tran_id);
                     FETCH c_transactions INTO l_transactions;
                     CLOSE c_transactions;

                    igs_uc_transactions_pkg.update_row(
                                x_rowid                => l_transactions.rowid,
                                x_uc_tran_id           => l_transactions.uc_tran_id,
                                x_transaction_id       => l_transactions.transaction_id,
                                x_datetimestamp        => l_transactions.datetimestamp,
                                x_updater              => l_transactions.updater,
                                x_error_code           => l_transactions.error_code,
                                x_transaction_type     => l_transactions.transaction_type,
                                x_app_no               => l_transactions.app_no,
                                x_choice_no            => l_transactions.choice_no,
                                x_decision             => l_transactions.decision,
                                x_program_code         => l_transactions.program_code,
                                x_campus               => l_transactions.campus,
                                x_entry_month          => l_transactions.entry_month,
                                x_entry_year           => l_transactions.entry_year,
                                x_entry_point          => l_transactions.entry_point,
                                x_soc                  => l_transactions.soc ,
                                x_comments_in_offer    => l_transactions.comments_in_offer,
                                x_return1              => l_transactions.return1,
                                x_return2              => l_transactions.return2,
                                x_hold_flag            => 'Y',
                                x_sent_to_ucas         => l_transactions.sent_to_ucas,
                                x_test_cond_cat        => l_transactions.test_cond_cat,
                                x_test_cond_name       => l_transactions.test_cond_name ,
                                x_mode                 => p_mode,   --jchakrab modified for 4380412
                                x_inst_reference       => l_transactions.inst_reference,
                                x_auto_generated_flag  => l_transactions.auto_generated_flag,
                                x_system_code          => l_transactions.system_code,
                                x_ucas_cycle           => l_transactions.ucas_cycle,
                                x_modular              => l_transactions.modular,
                                x_part_time            => l_transactions.part_time);

                 END IF;  -- end if for error code not null
                  p_uc_tran_id := l_uc_tran_id;
                  p_validate_error_cd := l_error_code;
              ELSE
                P_return1 := 1;
                P_return2:= 'IGS_UC_NO_LA_NO_LD';
              END IF;    -- End if for l_cnt >0
           ELSE
             P_return1 := 1;
             P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
           END IF;  -- End if for mandatory parameters null

         ELSIF (P_Tran_type = 'LC') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_Hold IS NOT NULL
                                    AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
              IF P_Course IS NOT NULL OR P_Entry_point IS NOT NULL THEN
                 P_return1 := 0;
                 igs_uc_transactions_pkg.insert_row (
                                x_mode                              => p_mode,   --jchakrab modified for 4380412
                                x_rowid                             => lv_rowid,
                                x_uc_tran_id                        => l_uc_tran_id,
                                x_transaction_id                    => NULL,
                                x_datetimestamp                     => NULL,
                                x_updater                           => NULL,
                                x_error_code                        => NULL,
                                x_transaction_type                  => P_Tran_type,
                                x_app_no                            => P_App_no,
                                x_choice_no                         => P_Choice_no,
                                x_decision                          => p_decision,
                                x_program_code                      => P_Course,
                                x_campus                            => P_Campus,
                                x_entry_month                       => P_Entry_month,
                                x_entry_year                        => P_Entry_year,
                                x_entry_point                       => P_Entry_point,
                                x_soc                               => p_soc,
                                x_comments_in_offer                 => P_Free_Format,
                                x_return1                           => NULL,
                                x_return2                           => NULL,
                                x_hold_flag                         => l_hold,
                                x_sent_to_ucas                      => 'N',
                                x_test_cond_cat                     => NULL,
                                x_test_cond_name                    => NULL,
                                x_inst_reference                    => P_Inst_reference ,
                                x_auto_generated_flag               => P_auto_generated,
                                x_system_code                       => p_system_code,
                                x_ucas_cycle                        => p_ucas_cycle,
                                x_modular                           => p_modular,
                                x_part_time                         => p_part_time);

                  p_uc_tran_id := l_uc_tran_id;

              ELSE
               P_return1 := 1;
               P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
              END IF;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;  -- End if for mandatory parameters null

         ELSIF(P_Tran_type = 'LD') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_Decision IS NOT NULL AND P_Hold IS NOT NULL
                                    AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
               P_return1 := 0;

               igs_uc_transactions_pkg.insert_row (
                                x_mode                              => p_mode,   --jchakrab modified for 4380412
                                x_rowid                             => lv_rowid,
                                x_uc_tran_id                        => l_uc_tran_id,
                                x_transaction_id                    => NULL,
                                x_datetimestamp                     => NULL,
                                x_updater                           => NULL,
                                x_error_code                        => NULL,
                                x_transaction_type                  => P_Tran_type,
                                x_app_no                            => P_App_no,
                                x_choice_no                         => P_Choice_no,
                                x_decision                          => P_Decision,
                                x_program_code                      => P_Course,
                                x_campus                            => P_Campus,
                                x_entry_month                       => P_Entry_month,
                                x_entry_year                        => P_Entry_year,
                                x_entry_point                       => P_Entry_point,
                                x_soc                               => l_soc,
                                x_comments_in_offer                 => l_comments_in_offer,
                                x_return1                           => l_return1,
                                x_return2                           => l_return2,
                                x_hold_flag                         => l_hold,
                                x_sent_to_ucas                      => 'N',
                                x_test_cond_cat                     => P_cond_cat,
                                x_test_cond_name                    => P_cond_name,
                                x_inst_reference                    => P_Inst_reference,
                                x_auto_generated_flag               => P_auto_generated,
                                x_system_code                       => p_system_code,
                                x_ucas_cycle                        => p_ucas_cycle,
                                x_modular                           => p_modular,
                                x_part_time                         => p_part_time);

                  -- Call the transaction validation process
                    l_error_code := NULL;
                 igs_uc_tran_processor_pkg.transaction_validation(p_transaction_type  => P_Tran_type,
                                                                  p_decision          => P_Decision,
                                                                  p_comments_in_offer => l_comments_in_offer,
                                                                  p_error_code        => l_error_code);

                  -- If transaction has an error then set the hold flag Y
                 IF l_error_code IS NOT NULL AND NVL(fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION'),'N') = 'N' THEN
                     -- get the hold profile value and update the transactions with hold flag Y
                     OPEN c_transactions(l_uc_tran_id);
                     FETCH c_transactions INTO l_transactions;
                     CLOSE c_transactions;

                    igs_uc_transactions_pkg.update_row(
                                x_rowid                => l_transactions.rowid,
                                x_uc_tran_id           => l_transactions.uc_tran_id,
                                x_transaction_id       => l_transactions.transaction_id,
                                x_datetimestamp        => l_transactions.datetimestamp,
                                x_updater              => l_transactions.updater,
                                x_error_code           => l_transactions.error_code,
                                x_transaction_type     => l_transactions.transaction_type,
                                x_app_no               => l_transactions.app_no,
                                x_choice_no            => l_transactions.choice_no,
                                x_decision             => l_transactions.decision,
                                x_program_code         => l_transactions.program_code,
                                x_campus               => l_transactions.campus,
                                x_entry_month          => l_transactions.entry_month,
                                x_entry_year           => l_transactions.entry_year,
                                x_entry_point          => l_transactions.entry_point,
                                x_soc                  => l_transactions.soc ,
                                x_comments_in_offer    => l_transactions.comments_in_offer,
                                x_return1              => l_transactions.return1,
                                x_return2              => l_transactions.return2,
                                x_hold_flag            => 'Y',
                                x_sent_to_ucas         => l_transactions.sent_to_ucas,
                                x_test_cond_cat        => l_transactions.test_cond_cat,
                                x_test_cond_name       => l_transactions.test_cond_name ,
                                x_mode                 => p_mode,   --jchakrab modified for 4380412
                                x_inst_reference       => l_transactions.inst_reference,
                                x_auto_generated_flag  => l_transactions.auto_generated_flag,
                                x_system_code          => l_transactions.system_code,
                                x_ucas_cycle           => l_transactions.ucas_cycle,
                                x_modular              => l_transactions.modular,
                                x_part_time            => l_transactions.part_time);

                 END IF;  -- end if for error code not null
                   p_uc_tran_id := l_uc_tran_id;
                   p_validate_error_cd := l_error_code;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF(P_Tran_type = 'LK') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_Hold IS NOT NULL
                                    AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
               -- For generating a LK transaction, there should not exists any LA transaction
               -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
               OPEN cur_find_trans('LA');
               FETCH cur_find_trans INTO l_cnt;
               CLOSE cur_find_trans;

               IF l_cnt > 0 THEN
                 P_return1 := 1;
                 P_return2:= 'IGS_UC_NO_LK_FOR_LA';
               ELSE
                 P_return1 := 0;
                 igs_uc_transactions_pkg.insert_row (
                                x_mode                              => p_mode,   --jchakrab modified for 4380412
                                x_rowid                             => lv_rowid,
                                x_uc_tran_id                        => l_uc_tran_id,
                                x_transaction_id                    => NULL,
                                x_datetimestamp                     => NULL,
                                x_updater                           => NULL,
                                x_error_code                        => NULL,
                                x_transaction_type                  => P_Tran_type,
                                x_app_no                            => P_App_no,
                                x_choice_no                         => P_Choice_no,
                                x_decision                          => NULL,
                                x_program_code                      => NULL,
                                x_campus                            => NULL,
                                x_entry_month                       => NULL,
                                x_entry_year                        => NULL,
                                x_entry_point                       => NULL,
                                x_soc                               => p_soc,
                                x_comments_in_offer                 => P_Free_Format,
                                x_return1                           => NULL,
                                x_return2                           => NULL,
                                x_hold_flag                         => l_hold,
                                x_sent_to_ucas                      => 'N',
                                x_test_cond_cat                     => NULL,
                                x_test_cond_name                    => NULL,
                                x_inst_reference                    => P_Inst_reference,
                                x_auto_generated_flag               => P_auto_generated,
                                x_system_code                       => p_system_code,
                                x_ucas_cycle                        => p_ucas_cycle,
                                x_modular                           => p_modular,
                                x_part_time                         => p_part_time);
                   p_uc_tran_id := l_uc_tran_id;

               END IF;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF(P_Tran_type = 'PE') THEN

            -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
            OPEN cur_find_trans(P_Tran_type);
            FETCH cur_find_trans INTO l_cnt;
            CLOSE cur_find_trans;

            IF l_cnt < 1 THEN

                --Check for Mandatory Parameters.
                IF P_App_no IS NOT NULL AND P_Hold IS NOT NULL AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
                  -- IF the person not exists in applicants then generate PE, if person exists in Applicants and does not exists the
                  -- Choices records between 1 to 6 then generate PE. bug 2632048
                  OPEN cur_applicants;
                  FETCH cur_applicants INTO l_cnt;
                  CLOSE cur_applicants;
                  l_generate := 'N';
                  IF l_cnt > 0 THEN
                   -- If the choices are exist between the 1 to 6 then not generating the transaction.
                    OPEN cur_choices;
                    FETCH cur_choices INTO l_cnt1;
                    CLOSE cur_choices;
                    IF l_cnt1 > 0 THEN
                      l_generate := 'N';
                    ELSE
                      l_generate := 'Y';
                    END IF;
                  ELSE   -- Applicantion not exists in the applicants table generate PE
                    l_generate := 'Y';
                  END IF;

                  IF l_generate = 'Y' THEN
                    P_return1 := 0;
                    igs_uc_transactions_pkg.insert_row (
                                  x_mode                              => p_mode,   --jchakrab modified for 4380412
                                  x_rowid                             => lv_rowid,
                                  x_uc_tran_id                        => l_uc_tran_id,
                                  x_transaction_id                    => NULL,
                                  x_datetimestamp                     => NULL,
                                  x_updater                           => NULL,
                                  x_error_code                        => NULL,
                                  x_transaction_type                  => P_Tran_type,
                                  x_app_no                            => P_App_no,
                                  x_choice_no                         => P_Choice_no,
                                  x_decision                          => p_decision,
                                  x_program_code                      => NULL,
                                  x_campus                            => NULL,
                                  x_entry_month                       => NULL,
                                  x_entry_year                        => NULL,
                                  x_entry_point                       => NULL,
                                  x_soc                               => NULL,
                                  x_comments_in_offer                 => NULL,
                                  x_return1                           => NULL,
                                  x_return2                           => NULL,
                                  x_hold_flag                         => l_hold,
                                  x_sent_to_ucas                      => 'N',
                                  x_test_cond_cat                     => NULL ,
                                  x_test_cond_name                    => NULL,
                                  x_inst_reference                    => P_Inst_reference,
                                  x_auto_generated_flag               => P_auto_generated,
                                  x_system_code                       => p_system_code,
                                  x_ucas_cycle                        => p_ucas_cycle,
                                  x_modular                           => p_modular,
                                  x_part_time                         => p_part_time);

                      p_uc_tran_id := l_uc_tran_id;
                  ELSE
                    P_return1 := 1;
                    P_return2 := 'IGS_UC_PE_NOT_GENERATED';
                  END IF;
                ELSE
                  P_return1 := 1;
                  P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
                END IF;

            END IF; -- l_cnt < 1

         ELSIF (P_Tran_type = 'RA') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Hold IS NOT NULL AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
               OPEN cur_app_choice_decision;
               FETCH cur_app_choice_decision INTO l_decision,l_reply;
               CLOSE cur_app_choice_decision;

               IF l_decision = 'U' AND l_reply = 'F' THEN
                 P_return1 := 0;
                 igs_uc_transactions_pkg.insert_row (
                              x_mode                              => p_mode,   --jchakrab modified for 4380412
                              x_rowid                             => lv_rowid,
                              x_uc_tran_id                        => l_uc_tran_id,
                              x_transaction_id                    => NULL,
                              x_datetimestamp                     => NULL,
                              x_updater                           => NULL,
                              x_error_code                        => NULL,
                              x_transaction_type                  => P_Tran_type,
                              x_app_no                            => P_App_no,
                              x_choice_no                         => P_Choice_no,
                              x_decision                          => NULL,
                              x_program_code                      => P_Course,
                              x_campus                            => P_Campus,
                              x_entry_month                       => P_Entry_month,
                              x_entry_year                        => P_Entry_year,
                              x_entry_point                       => P_Entry_point,
                              x_soc                               => NULL,
                              x_comments_in_offer                 => NULL,
                              x_return1                           => NULL,
                              x_return2                           => NULL,
                              x_hold_flag                         => l_hold,
                              x_sent_to_ucas                      => 'N',
                              x_test_cond_cat                     => NULL,
                              x_test_cond_name                    => NULL,
                              x_inst_reference                    => P_Inst_reference,
                              x_auto_generated_flag               => P_auto_generated,
                              x_system_code                       => p_system_code,
                              x_ucas_cycle                        => p_ucas_cycle,
                              x_modular                           => p_modular,
                              x_part_time                         => p_part_time);

                  p_uc_tran_id := l_uc_tran_id;
               ELSE
                 P_return1 := 1;
                 P_return2 := 'IGS_UC_APP_NOT_UF';
               END IF;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF (P_Tran_type = 'RD') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_Decision IS NOT NULL AND P_Hold IS NOT NULL
                                                                AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
            IF (P_Decision IN ('C','I') AND ((P_Course IS NOT NULL AND P_Campus IS NOT NULL) OR
                                           (P_Entry_month IS NOT NULL AND P_Entry_Year IS NOT NULL) OR (P_Entry_point IS NOT NULL)))
               OR (P_Decision NOT IN ('C','I') AND (P_Course IS NULL AND P_Campus IS NULL AND  P_Entry_month IS NULL AND P_Entry_year IS NULL AND P_Entry_point IS NULL)) THEN
                 P_return1 := 0;
                 igs_uc_transactions_pkg.insert_row (
                              x_mode                              => p_mode,   --jchakrab modified for 4380412
                              x_rowid                             => lv_rowid,
                              x_uc_tran_id                        => l_uc_tran_id,
                              x_transaction_id                    => NULL,
                              x_datetimestamp                     => NULL,
                              x_updater                           => NULL,
                              x_error_code                        => NULL,
                              x_transaction_type                  => P_Tran_type,
                              x_app_no                            => P_App_no,
                              x_choice_no                         => P_Choice_no,
                              x_decision                          => P_Decision,
                              x_program_code                      => P_Course,
                              x_campus                            => P_Campus,
                              x_entry_month                       => P_Entry_month,
                              x_entry_year                        => P_Entry_year,
                              x_entry_point                       => P_Entry_point,
                              x_soc                               => NULL,
                              x_comments_in_offer                 => NULL,
                              x_return1                           => NULL,
                              x_return2                           => NULL,
                              x_hold_flag                         => l_hold,
                              x_sent_to_ucas                      => 'N',
                              x_test_cond_cat                     => NULL,
                              x_test_cond_name                    => NULL,
                              x_inst_reference                    => P_Inst_reference,
                              x_auto_generated_flag               => P_auto_generated,
                              x_system_code                       => p_system_code,
                              x_ucas_cycle                        => p_ucas_cycle,
                              x_modular                           => p_modular,
                              x_part_time                         => p_part_time);

                    p_uc_tran_id := l_uc_tran_id;
              ELSE
                P_return1 := 1;
                --Check the decision value and assign the proper error message.
                IF (P_Decision IN ('C','I') ) THEN
                  P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
                ELSE
                  P_return2 := 'IGS_UC_EXTRA_PARAMS';
                END IF;
              END IF;
            ELSE
             P_return1 := 1;
             P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF (P_Tran_type = 'RE') THEN

           -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
           OPEN cur_find_trans(P_Tran_type);
           FETCH cur_find_trans INTO l_cnt;
           CLOSE cur_find_trans;

           IF l_cnt < 1 THEN

               --Check for Mandatory Parameters.
               IF P_App_no IS NOT NULL AND P_Hold IS NOT NULL AND P_Course IS NOT NULL AND P_Entry_year IS NOT NULL
                                       AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN

                --For FTUG system applicant should exist in the cvname then only generate the transaction for other system applicant does not exists in cvname.
                IF p_system_code = 'U' THEN

                   -- Modified for UC315 - UCAS 2006 Support
                   IF p_ucas_cycle < 2006 THEN
                       OPEN cur_find_appclear;
                       FETCH cur_find_appclear INTO l_cnt;
                       CLOSE cur_find_appclear;
                   ELSE
                       OPEN cur_find_appclear_2006;
                       FETCH cur_find_appclear_2006 INTO l_cnt;
                       CLOSE cur_find_appclear_2006;
                   END IF;

                   IF l_cnt > 0 THEN
                     l_generate_tran := 'Y';
                   END IF;
                ELSE
                   l_generate_tran := 'Y';
                END IF;

                IF l_generate_tran = 'Y' THEN
                  P_return1 := 0;
                  igs_uc_transactions_pkg.insert_row (
                                  x_mode                              => p_mode,   --jchakrab modified for 4380412
                                  x_rowid                             => lv_rowid,
                                  x_uc_tran_id                        => l_uc_tran_id,
                                  x_transaction_id                    => NULL,
                                  x_datetimestamp                     => NULL,
                                  x_updater                           => NULL,
                                  x_error_code                        => NULL,
                                  x_transaction_type                  => P_Tran_type,
                                  x_app_no                            => P_App_no,
                                  x_choice_no                         => P_Choice_no,
                                  x_decision                          => NULL,
                                  x_program_code                      => P_Course,
                                  x_campus                            => P_Campus,
                                  x_entry_month                       => NULL,
                                  x_entry_year                        => P_Entry_year,
                                  x_entry_point                       => NULL,
                                  x_soc                               => NULL,
                                  x_comments_in_offer                 => NULL,
                                  x_return1                           => NULL,
                                  x_return2                           => NULL,
                                  x_hold_flag                         => l_hold,
                                  x_sent_to_ucas                      => 'N',
                                  x_test_cond_cat                     => NULL,
                                  x_test_cond_name                    => NULL,
                                  x_inst_reference                    => P_Inst_reference,
                                  x_auto_generated_flag               => P_auto_generated,
                                  x_system_code                       => p_system_code,
                                  x_ucas_cycle                        => p_ucas_cycle,
                                  x_modular                           => p_modular,
                                  x_part_time                         => p_part_time);

                        p_uc_tran_id := l_uc_tran_id;
                 ELSE
                   P_return1 := 1;
                   P_return2 := 'IGS_UC_APP_NOT_CLEAR';
                 END IF;
               ELSE
                 P_return1 := 1;
                 P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
               END IF;

            END IF; -- l_cnt < 1

         ELSIF (P_Tran_type = 'RK') THEN
           --Check for Mandatory Parameters.
           IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_HOLD IS NOT NULL AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
              OPEN cur_find_RD;
              FETCH cur_find_RD INTO l_cnt;
              CLOSE cur_find_RD;
              IF l_cnt > 0 THEN
                 P_return1 := 0;
                igs_uc_transactions_pkg.insert_row (
                              x_mode                              => p_mode,   --jchakrab modified for 4380412
                              x_rowid                             => lv_rowid,
                              x_uc_tran_id                        => l_uc_tran_id,
                              x_transaction_id                    => NULL,
                              x_datetimestamp                     => NULL,
                              x_updater                           => NULL,
                              x_error_code                        => NULL,
                              x_transaction_type                  => P_Tran_type,
                              x_app_no                            => P_App_no,
                              x_choice_no                         => P_Choice_no,
                              x_decision                          => NULL,
                              x_program_code                      => NULL,
                              x_campus                            => NULL,
                              x_entry_month                       => NULL,
                              x_entry_year                        => NULL,
                              x_entry_point                       => NULL,
                              x_soc                               => NULL,
                              x_comments_in_offer                 => NULL,
                              x_return1                           => NULL,
                              x_return2                           => NULL,
                              x_hold_flag                         => l_hold,
                              x_sent_to_ucas                      => 'N',
                              x_test_cond_cat                     => NULL,
                              x_test_cond_name                    => NULL,
                              x_inst_reference                    => P_Inst_reference,
                              x_auto_generated_flag               => P_auto_generated,
                              x_system_code                       => p_system_code,
                              x_ucas_cycle                        => p_ucas_cycle,
                              x_modular                           => p_modular,
                              x_part_time                         => p_part_time);

                         p_uc_tran_id := l_uc_tran_id;
             ELSE
               P_return1 := 1;
               P_return2 := 'IGS_UC_NO_RD_NO_RK';
             END IF;
           ELSE
            P_return1 := 1;
            P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
           END IF;

         ELSIF (P_Tran_type = 'RQ') THEN

           -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
           OPEN cur_find_trans(P_Tran_type);
           FETCH cur_find_trans INTO l_cnt;
           CLOSE cur_find_trans;

           IF l_cnt < 1 THEN

               --Check for Mandatory Parameters.
               IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_HOLD IS NOT NULL AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN

                   --For FTUG system applicant should exist in the cvname then only generate the transaction for other system applicant does not exists in cvname.
                   IF p_system_code = 'U'  THEN

                      -- Modified for UC315 - UCAS 2006 Support
                      IF p_ucas_cycle < 2006 THEN
                          OPEN cur_find_appclear;
                          FETCH cur_find_appclear INTO l_cnt;
                          CLOSE cur_find_appclear;
                      ELSE
                          OPEN cur_find_appclear_2006;
                          FETCH cur_find_appclear_2006 INTO l_cnt;
                          CLOSE cur_find_appclear_2006;
                      END IF;

                      IF l_cnt > 0 THEN
                         l_generate_tran := 'Y';
                      END IF;
                   ELSE
                      l_generate_tran := 'Y';
                   END IF;

                   -- If processing period is NOT claering then hold falg is Y
                   IF l_transaction_toy <> 'C' THEN
                      l_hold := 'Y';
                   ELSE
                      l_hold := NVL(fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION'),'N');
                   END IF;

                     IF l_generate_tran = 'Y' THEN
                        P_return1 := 0;
                        igs_uc_transactions_pkg.insert_row (
                                  x_mode                              => p_mode,   --jchakrab modified for 4380412
                                  x_rowid                             => lv_rowid,
                                  x_uc_tran_id                        => l_uc_tran_id,
                                  x_transaction_id                    => NULL,
                                  x_datetimestamp                     => NULL,
                                  x_updater                           => NULL,
                                  x_error_code                        => NULL,
                                  x_transaction_type                  => P_Tran_type,
                                  x_app_no                            => P_App_no,
                                  x_choice_no                         => P_Choice_no,
                                  x_decision                          => NULL,
                                  x_program_code                      => P_Course,
                                  x_campus                            => P_Campus,
                                  x_entry_month                       => NULL,
                                  x_entry_year                        => P_Entry_year,
                                  x_entry_point                       => NULL,
                                  x_soc                               => NULL,
                                  x_comments_in_offer                 => NULL,
                                  x_return1                           => NULL,
                                  x_return2                           => NULL,
                                  x_hold_flag                         => l_hold,
                                  x_sent_to_ucas                      => 'N',
                                  x_test_cond_cat                     => NULL,
                                  x_test_cond_name                    => NULL,
                                  x_inst_reference                    => P_Inst_reference,
                                  x_auto_generated_flag               => P_auto_generated,
                                  x_system_code                       => p_system_code,
                                  x_ucas_cycle                        => p_ucas_cycle,
                                  x_modular                           => p_modular,
                                  x_part_time                         => p_part_time);

                           p_uc_tran_id := l_uc_tran_id;

                     ELSE
                       P_return1 := 1;
                       P_return2 := 'IGS_UC_APP_NOT_CLEAR';
                     END IF;
               ELSE
                 P_return1 := 1;
                 P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
               END IF;

            END IF; -- l_cnt < 1

         ELSIF (P_Tran_type = 'RR') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Free_Format IS NOT NULL AND P_HOLD IS NOT NULL
                                    AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
              IF P_Free_Format ='.R1' OR P_Free_Format = '.R2' OR P_Free_Format = '.R3'
                                      OR P_Free_Format = '.R4' OR P_Free_Format = '.R5' OR P_Free_Format = '.R6' THEN
                  P_return1 := 0;
                  igs_uc_transactions_pkg.insert_row (
                              x_mode                              => p_mode,   --jchakrab modified for 4380412
                              x_rowid                             => lv_rowid,
                              x_uc_tran_id                        => l_uc_tran_id,
                              x_transaction_id                    => NULL,
                              x_datetimestamp                     => NULL,
                              x_updater                           => NULL,
                              x_error_code                        => NULL,
                              x_transaction_type                  => P_Tran_type,
                              x_app_no                            => P_App_no,
                              x_choice_no                         => P_Choice_no,
                              x_decision                          => NULL,
                              x_program_code                      => NULL,
                              x_campus                            => NULL,
                              x_entry_month                       => NULL,
                              x_entry_year                        => NULL,
                              x_entry_point                       => NULL,
                              x_soc                               => NULL,
                              x_comments_in_offer                 => P_Free_Format,
                              x_return1                           => NULL,
                              x_return2                           => NULL,
                              x_hold_flag                         => l_hold,
                              x_sent_to_ucas                      => 'N',
                              x_test_cond_cat                     => NULL,
                              x_test_cond_name                    => NULL,
                              x_inst_reference                    => P_Inst_reference,
                              x_auto_generated_flag               => P_auto_generated,
                              x_system_code                       => p_system_code,
                              x_ucas_cycle                        => p_ucas_cycle,
                              x_modular                           => p_modular,
                              x_part_time                         => p_part_time);

                     p_uc_tran_id := l_uc_tran_id;
              ELSE
                P_return1 := 1;
                P_return2 := 'IGS_UC_RR_FREEFORMAT';
              END IF;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF (P_Tran_type = 'RW') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_HOLD IS NOT NULL AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
               OPEN cur_app_choice_decision;
               FETCH cur_app_choice_decision INTO l_decision,l_reply;
               CLOSE cur_app_choice_decision;

               IF l_decision = 'U' AND l_reply = 'F' THEN
                  P_return1 := 0;
                  igs_uc_transactions_pkg.insert_row (
                              x_mode                              => p_mode,   --jchakrab modified for 4380412
                              x_rowid                             => lv_rowid,
                              x_uc_tran_id                        => l_uc_tran_id,
                              x_transaction_id                    => NULL,
                              x_datetimestamp                     => NULL,
                              x_updater                           => NULL,
                              x_error_code                        => NULL,
                              x_transaction_type                  => P_Tran_type,
                              x_app_no                            => P_App_no,
                              x_choice_no                         => P_Choice_no,
                              x_decision                          => NULL,
                              x_program_code                      => NULL,
                              x_campus                            => NULL,
                              x_entry_month                       => NULL,
                              x_entry_year                        => NULL,
                              x_entry_point                       => NULL,
                              x_soc                               => NULL,
                              x_comments_in_offer                 => NULL,
                              x_return1                           => NULL,
                              x_return2                           => NULL,
                              x_hold_flag                         => l_hold,
                              x_sent_to_ucas                      => 'N',
                              x_test_cond_cat                     => NULL,
                              x_test_cond_name                    => NULL,
                              x_inst_reference                    => P_Inst_reference ,
                              x_auto_generated_flag               => P_auto_generated,
                              x_system_code                       => p_system_code,
                              x_ucas_cycle                        => p_ucas_cycle,
                              x_modular                           => p_modular,
                              x_part_time                         => p_part_time);

                      p_uc_tran_id := l_uc_tran_id;
               ELSE
                 P_return1 := 1;
                 P_return2 := 'IGS_UC_APP_NOT_UF';
               END IF;
            ELSE
               P_return1 := 1;
               P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF (P_Tran_type = 'RX') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Decision IS NOT NULL AND P_Hold IS NOT NULL AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
               IF P_Course IS NOT NULL
                AND ((p_system_code IN ('U','N') AND P_Decision = 'A') OR (p_system_code = 'G' AND P_Decision IN ('C','U'))) THEN
                 P_return1 := 0;

                --If processing period is not claering then hold flag is Y
               IF l_transaction_toy <> 'C' THEN
                  l_hold := 'Y';
               ELSE
                  l_hold := NVL(fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION'),'N');
               END IF;

                 igs_uc_transactions_pkg.insert_row (
                              x_mode                              => p_mode,   --jchakrab modified for 4380412
                              x_rowid                             => lv_rowid,
                              x_uc_tran_id                        => l_uc_tran_id,
                              x_transaction_id                    => NULL,
                              x_datetimestamp                     => NULL,
                              x_updater                           => NULL,
                              x_error_code                        => NULL,
                              x_transaction_type                  => P_Tran_type,
                              x_app_no                            => P_App_no,
                              x_choice_no                         => P_Choice_no,
                              x_decision                          => P_Decision,
                              x_program_code                      => NVL(P_Course,NULL),
                              x_campus                            => P_Campus,
                              x_entry_month                       => P_Entry_month,
                              x_entry_year                        => P_Entry_year,
                              x_entry_point                       => P_Entry_point,
                              x_soc                               => NULL,
                              x_comments_in_offer                 => NULL,
                              x_return1                           => NULL,
                              x_return2                           => NULL,
                              x_hold_flag                         => l_hold,
                              x_sent_to_ucas                      => 'N',
                              x_test_cond_cat                     => NULL,
                              x_test_cond_name                    => NULL,
                              x_inst_reference                    => P_Inst_reference,
                              x_auto_generated_flag               => P_auto_generated,
                              x_system_code                       => p_system_code,
                              x_ucas_cycle                        => p_ucas_cycle,
                              x_modular                           => p_modular,
                              x_part_time                         => p_part_time);

                    p_uc_tran_id := l_uc_tran_id;
               ELSE
                 P_return1 := 1;
                 P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
               END IF;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF (P_Tran_type = 'XA') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_Decision IS NOT NULL AND P_Hold IS NOT NULL
                                    AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN

               -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
               OPEN cur_find_trans('LD');
               FETCH cur_find_trans INTO l_cnt;
               CLOSE cur_find_trans;

               IF l_cnt > 0 THEN
                  P_return1 := 0;
                  igs_uc_transactions_pkg.insert_row (
                              x_mode                              => p_mode,   --jchakrab modified for 4380412
                              x_rowid                             => lv_rowid,
                              x_uc_tran_id                        => l_uc_tran_id,
                              x_transaction_id                    => NULL,
                              x_datetimestamp                     => NULL,
                              x_updater                           => NULL,
                              x_error_code                        => NULL,
                              x_transaction_type                  => P_Tran_type,
                              x_app_no                            => P_App_no,
                              x_choice_no                         => P_Choice_no,
                              x_decision                          => P_Decision,
                              x_program_code                      => P_Course,
                              x_campus                            => P_Campus,
                              x_entry_month                       => P_Entry_month,
                              x_entry_year                        => P_Entry_year,
                              x_entry_point                       => P_Entry_point,
                              x_soc                               => l_soc,
                              x_comments_in_offer                 => l_comments_in_offer,
                              x_return1                           => l_return1,
                              x_return2                           => l_return2,
                              x_hold_flag                         => l_hold,
                              x_sent_to_ucas                      => 'N',
                              x_test_cond_cat                     => P_cond_cat,
                              x_test_cond_name                    => P_cond_name,
                              x_inst_reference                    => P_Inst_reference,
                              x_auto_generated_flag               => P_auto_generated,
                              x_system_code                       => p_system_code,
                              x_ucas_cycle                        => p_ucas_cycle,
                              x_modular                           => p_modular,
                              x_part_time                         => p_part_time);

                  -- Call the transaction validation process
                   l_error_code := NULL;
                 igs_uc_tran_processor_pkg.transaction_validation(p_transaction_type  => P_Tran_type,
                                                                  p_decision          => P_Decision,
                                                                  p_comments_in_offer => l_comments_in_offer,
                                                                  p_error_code        => l_error_code);

                  -- If transaction has an error then set the hold flag Y
                 IF l_error_code IS NOT NULL AND NVL(fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION'),'N') = 'N' THEN
                     -- get the hold profile value and update the transactions with hold flag Y
                     OPEN c_transactions(l_uc_tran_id);
                     FETCH c_transactions INTO l_transactions;
                     CLOSE c_transactions;

                    igs_uc_transactions_pkg.update_row(
                                x_rowid                => l_transactions.rowid,
                                x_uc_tran_id           => l_transactions.uc_tran_id,
                                x_transaction_id       => l_transactions.transaction_id,
                                x_datetimestamp        => l_transactions.datetimestamp,
                                x_updater              => l_transactions.updater,
                                x_error_code           => l_transactions.error_code,
                                x_transaction_type     => l_transactions.transaction_type,
                                x_app_no               => l_transactions.app_no,
                                x_choice_no            => l_transactions.choice_no,
                                x_decision             => l_transactions.decision,
                                x_program_code         => l_transactions.program_code,
                                x_campus               => l_transactions.campus,
                                x_entry_month          => l_transactions.entry_month,
                                x_entry_year           => l_transactions.entry_year,
                                x_entry_point          => l_transactions.entry_point,
                                x_soc                  => l_transactions.soc ,
                                x_comments_in_offer    => l_transactions.comments_in_offer,
                                x_return1              => l_transactions.return1,
                                x_return2              => l_transactions.return2,
                                x_hold_flag            => 'Y',
                                x_sent_to_ucas         => l_transactions.sent_to_ucas,
                                x_test_cond_cat        => l_transactions.test_cond_cat,
                                x_test_cond_name       => l_transactions.test_cond_name ,
                                x_mode                 => p_mode,   --jchakrab modified for 4380412
                                x_inst_reference       => l_transactions.inst_reference,
                                x_auto_generated_flag  => l_transactions.auto_generated_flag,
                                x_system_code          => l_transactions.system_code,
                                x_ucas_cycle           => l_transactions.ucas_cycle,
                                x_modular              => l_transactions.modular,
                                x_part_time            => l_transactions.part_time);

                 END IF;  -- end if for error code not null
                   p_uc_tran_id := l_uc_tran_id;
                   p_validate_error_cd := l_error_code;
               ELSE
                 P_return1 := 1;
                 P_return2:= 'IGS_UC_NO_XA_NO_LD';
               END IF;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF (P_Tran_type = 'XD') THEN
            --Check for Mandatory Parameters.
            IF P_App_no IS NOT NULL AND P_Choice_no IS NOT NULL AND P_Decision IS NOT NULL AND P_Hold IS NOT NULL
                                    AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN
               IF P_Decision IN ('W','X') THEN
               IF P_Free_Format IS NOT NULL THEN
                  P_return1 := 0;

                  igs_uc_transactions_pkg.insert_row (
                                      x_mode                              => p_mode,   --jchakrab modified for 4380412
                                      x_rowid                             => lv_rowid,
                                      x_uc_tran_id                        => l_uc_tran_id,
                                      x_transaction_id                    => NULL,
                                      x_datetimestamp                     => NULL,
                                      x_updater                           => NULL,
                                      x_error_code                        => NULL,
                                      x_transaction_type                  => P_Tran_type,
                                      x_app_no                            => P_App_no,
                                      x_choice_no                         => P_Choice_no,
                                      x_decision                          => P_Decision,
                                      x_program_code                      => P_Course,
                                      x_campus                            => P_Campus,
                                      x_entry_month                       => P_Entry_month,
                                      x_entry_year                        => P_Entry_year,
                                      x_entry_point                       => P_Entry_point,
                                      x_soc                               => l_soc,
                                      x_comments_in_offer                 => l_comments_in_offer,
                                      x_return1                           => l_return1,
                                      x_return2                           => l_return2,
                                      x_hold_flag                         => l_hold,
                                      x_sent_to_ucas                      => 'N',
                                      x_test_cond_cat                     => P_cond_cat,
                                      x_test_cond_name                    => P_cond_name,
                                      x_inst_reference                    => P_Inst_reference ,
                                      x_auto_generated_flag               => P_auto_generated,
                                      x_system_code                       => p_system_code,
                                      x_ucas_cycle                        => p_ucas_cycle,
                                      x_modular                           => p_modular,
                                      x_part_time                         => p_part_time);

                  -- Call the transaction validation process
                   l_error_code := NULL;
                 igs_uc_tran_processor_pkg.transaction_validation(p_transaction_type  => P_Tran_type,
                                                                  p_decision          => P_Decision,
                                                                  p_comments_in_offer => l_comments_in_offer,
                                                                  p_error_code        => l_error_code);

                  -- If transaction has an error then set the hold flag Y
                 IF l_error_code IS NOT NULL AND NVL(fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION'),'N') = 'N' THEN
                     -- get the hold profile value and update the transactions with hold flag Y
                     OPEN c_transactions(l_uc_tran_id);
                     FETCH c_transactions INTO l_transactions;
                     CLOSE c_transactions;

                    igs_uc_transactions_pkg.update_row(
                                x_rowid                => l_transactions.rowid,
                                x_uc_tran_id           => l_transactions.uc_tran_id,
                                x_transaction_id       => l_transactions.transaction_id,
                                x_datetimestamp        => l_transactions.datetimestamp,
                                x_updater              => l_transactions.updater,
                                x_error_code           => l_transactions.error_code,
                                x_transaction_type     => l_transactions.transaction_type,
                                x_app_no               => l_transactions.app_no,
                                x_choice_no            => l_transactions.choice_no,
                                x_decision             => l_transactions.decision,
                                x_program_code         => l_transactions.program_code,
                                x_campus               => l_transactions.campus,
                                x_entry_month          => l_transactions.entry_month,
                                x_entry_year           => l_transactions.entry_year,
                                x_entry_point          => l_transactions.entry_point,
                                x_soc                  => l_transactions.soc ,
                                x_comments_in_offer    => l_transactions.comments_in_offer,
                                x_return1              => l_transactions.return1,
                                x_return2              => l_transactions.return2,
                                x_hold_flag            => 'Y',
                                x_sent_to_ucas         => l_transactions.sent_to_ucas,
                                x_test_cond_cat        => l_transactions.test_cond_cat,
                                x_test_cond_name       => l_transactions.test_cond_name ,
                                x_mode                 => p_mode,   --jchakrab modified for 4380412
                                x_inst_reference       => l_transactions.inst_reference,
                                x_auto_generated_flag  => l_transactions.auto_generated_flag,
                                x_system_code          => l_transactions.system_code,
                                x_ucas_cycle           => l_transactions.ucas_cycle,
                                x_modular              => l_transactions.modular,
                                x_part_time            => l_transactions.part_time);

                 END IF;  -- end if for error code not null
                   p_uc_tran_id := l_uc_tran_id;
                   p_validate_error_cd := l_error_code;
               ELSE
                 P_return1 := 1;
                 P_return2 := 'IGS_UC_NO_WITHD_REASON';
               END IF;
               END IF;
            ELSE
              P_return1 := 1;
              P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
            END IF;

         ELSIF (P_Tran_type = 'LE') THEN

            -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
            OPEN cur_find_trans(P_Tran_type);
            FETCH cur_find_trans INTO l_cnt;
            CLOSE cur_find_trans;

            IF l_cnt < 1 THEN

                --Check for Mandatory Parameters.
                IF P_App_no IS NOT NULL AND P_Hold IS NOT NULL AND P_Course IS NOT NULL AND P_Free_Format IS NOT NULL
                                        AND p_system_code IS NOT NULL AND p_ucas_cycle IS NOT NULL THEN

                  IF LENGTH(P_Free_Format) = 7 AND SUBSTR(P_Free_Format,1,1) = 'X'  AND SUBSTR(P_Free_Format,7,1) IN ('Y','N') THEN
                      P_return1 := 0;
                    -- If processing period is not extra then hold flag is Y
                    IF l_transaction_toy <> 'E' THEN
                      l_hold := 'Y';
                    ELSE
                      l_hold := NVL(fnd_profile.value('IGS_UC_HOLD_UCAS_TRANSACTION'),'N');
                    END IF;

                      igs_uc_transactions_pkg.insert_row (
                                  x_mode                              => p_mode,   --jchakrab modified for 4380412
                                  x_rowid                             => lv_rowid,
                                  x_uc_tran_id                        => l_uc_tran_id,
                                  x_transaction_id                    => NULL,
                                  x_datetimestamp                     => NULL,
                                  x_updater                           => NULL,
                                  x_error_code                        => NULL,
                                  x_transaction_type                  => P_Tran_type,
                                  x_app_no                            => P_App_no,
                                  x_choice_no                         => P_Choice_no,
                                  x_decision                          => NULL,
                                  x_program_code                      => P_Course,
                                  x_campus                            => P_Campus,
                                  x_entry_month                       => NULL,
                                  x_entry_year                        => NULL,
                                  x_entry_point                       => NULL,
                                  x_soc                               => NULL,
                                  x_comments_in_offer                 => P_Free_Format,
                                  x_return1                           => l_return1,
                                  x_return2                           => l_return2,
                                  x_hold_flag                         => l_hold,
                                  x_sent_to_ucas                      => 'N',
                                  x_test_cond_cat                     => P_cond_cat,
                                  x_test_cond_name                    => P_cond_name,
                                  x_inst_reference                    => P_Inst_reference,
                                  x_auto_generated_flag               => P_auto_generated,
                                  x_system_code                       => p_system_code,
                                  x_ucas_cycle                        => p_ucas_cycle,
                                  x_modular                           => p_modular,
                                  x_part_time                         => p_part_time);

                      p_uc_tran_id := l_uc_tran_id;
                  ELSE
                    P_return1 := 1;
                    P_return2 := 'IGS_UC_INVALID_EXTRA_ID';
                  END IF;
                ELSE
                  P_return1 := 1;
                  P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
                END IF;  -- End if for mandatory parameters

            END IF; -- l_cnt < 1

         ELSE
            P_return1 := 1;
            P_return2 := 'IGS_UC_NO_MANDATORY_PARAMS';
         END IF; --Tran TYPE check

      END IF;  -- End if for cur_rec_found

   END IF; --deceased check

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

 END trans_build;

PROCEDURE transaction_population(p_condition_category1 IN  igs_uc_transactions.test_cond_cat%TYPE ,
                                 p_condition_name1     IN  igs_uc_transactions.test_cond_name%TYPE ,
                                 p_soc1                OUT NOCOPY igs_uc_transactions.SOC%TYPE,
                                 p_comments_in_offer   OUT NOCOPY igs_uc_offer_conds.marvin_code%TYPE ) IS

  /*********************************************************************
   Created By      : pmarada
   Date Created By : 01-Nov-2003
   Purpose: Returns the derived field value based on the condition categroy and name
            this procedure could be enhanced in future

   Know limitations, enhancements or remarks
   Change History  (reverse chronological order - newest change first)
   Who      When       What

  **********************************************************************/

  CURSOR c_offer_conds (cp_condition_category  igs_uc_offer_conds.condition_category%TYPE,
                        cp_condition_name   igs_uc_offer_conds.condition_name%TYPE) IS
  SELECT marvin_code, summ_of_cond FROM igs_uc_offer_conds
  WHERE condition_category = cp_condition_category
    AND condition_name = cp_condition_name;

  l_offer_conds c_offer_conds%ROWTYPE;

BEGIN
   -- get the Summary of Conds and Marvin code valeus and return to the main procedure
   OPEN c_offer_conds(p_condition_category1, p_condition_name1);
   FETCH c_offer_conds INTO l_offer_conds;
   CLOSE c_offer_conds;

   p_soc1 := l_offer_conds.summ_of_cond;
   p_comments_in_offer := l_offer_conds.marvin_code;

END transaction_population;

PROCEDURE transaction_validation(p_transaction_type  IN igs_uc_transactions.transaction_type%TYPE,
                                 p_decision          IN igs_uc_transactions.decision%TYPE,
                                 p_comments_in_offer IN igs_uc_transactions.comments_in_offer%TYPE,
                                 p_error_code OUT NOCOPY igs_lookup_values.lookup_code%TYPE) IS

  /*********************************************************************
   Created By      : pmarada
   Date Created By : 01-Nov-2003
   Purpose: procedure validates the comments in offer filed value for
            decision and transaction if any error returns the error code

   Know limitations, enhancements or remarks
   Change History  (reverse chronological order - newest change first)
   Who      When       What

  **********************************************************************/

 l_error DATE;

BEGIN

    p_error_code := NULL;
   -- For Interview decision comments in offer field should have Interview date with DDMMYY format.
  IF p_decision = 'I' THEN
    IF p_transaction_type IN ('LA','LD') AND p_comments_in_offer IS NULL THEN
       p_error_code := '1001';
    ELSIF p_transaction_type IN ('LA','LD') AND p_comments_in_offer IS NOT NULL THEN
       BEGIN
         IF length(p_comments_in_offer) <> 6 THEN
           p_error_code := '1002';
         END IF;
         l_error := TO_DATE(p_comments_in_offer,'DDMMYY');
        EXCEPTION
          WHEN OTHERS THEN
           p_error_code := '1002';
       END;
    END IF;
    -- For Conditional offer decision Comments in offer is required.
  ELSIF p_decision = 'C' AND p_transaction_type IN ('LA','LD','XA','XD')
        AND p_comments_in_offer IS NULL THEN
     p_error_code := '1003';
  ELSE
     p_error_code := NULL;
  END IF;

END transaction_validation;


 PROCEDURE proc_tranin_2003(p_conf_cycle IN igs_uc_defaults.configured_cycle%TYPE ) IS

    /*************************************************************
    Created By      : solakshm
    Date Created By : 23-JAN-2002
    Purpose: To write into TRANIN when the 'sent_to_ucas' and 'hold_flag' flag is no.
             and cycle is 2003 then write the transaction details in Tranin and
             Also updates igs_uc_transactions with info. from TRANIN and update the
             igs_uc_offer_conds table with status
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    rbezawad   4-Apr-2002           1) Inistitution Reference Column is added w.r.t. UCCR002 Data Model Change.
                                    2) Exception Handling part is modifiled
    rbezawad   2-May-2002           Modified w.r.t. UCCR003 Build.Bug No: 2311662
                                      In trans_write() procedure added validation for Checking Interface Type and perform validations accordingly.
    rbezawad   11-Jul-2002          Modified code in the exception handling part to raise the error when the exception occurs.
                                      Also while inserting records into traning, the columns TRANSACTIONID,TIMESTAMP,UPDATER,ERRORCODE values are passed as NULL.
                                      These modifications are done as part of 2450438.
    rbezawad   16-Jul-2002          While inserting Transactions into Tranin, for the program_code and Campus fields, logic is added to replace the '*' character with ' '.
                                      Added logic for better reporting while exporting transactions.  Modifications are done w.r.t. Bug 2462096
    rbezawad   16-Jul-2002          Added logic to populate the columns SUMM_OF_COND, LETTER_TEXT columns of table IGS_UC_OFFER_CONDS w.r.t. Bug 2461913.
    smaddali   02-oct-2002    Modified for bug 2603384
                               1) added new column auto_generated_flag to tbh calls to igs_uc_transactions_pkg
                               2) modified cursor cur_records_to_write to fetch column auto_generated_flag
                               3) modified igs_uc_transactions.update_row call to update test_cond_cat and name
                                   fields with proper values rather than with NULL
    ayedubat  05-DEC-2002    Changed the Log file generations of transactions being processed in the current run for bug: 2462078
                             Replaced the message, IGS_UC_TRANS_PROC_LOG with the new message 'IGS_UC_TRANS_LOG_HEADER' for dsiplaying
                             the header line for the transaction records.
    ayedubat  21-Mar-03      Removed local variable l_log_text w.r.t. Bug  2841582.
    pmarada   09-Jun-03      created this procedure Proc_Tranin_2003 and added cycle in required places. as per UCFD203 Multiple cycles
    arvsrini  26-APR-04      Added code to update IGS_UC_TRANSACTIONS.SOC based on errorcode value Bug#3576288

    (reverse chronological order - newest change first)
    ***************************************************************/

    CURSOR cur_records_to_write(cp_conf_cycle igs_uc_defaults.configured_cycle%TYPE) IS
       SELECT a.ROWID,a.uc_tran_id,a.transaction_id, a.datetimestamp,
              a.updater, a.error_code, a.transaction_type, a.app_no,
              a.choice_no, a.decision, a.program_code,
              a.campus, a.entry_month, a.entry_year, a.entry_point,
              a.soc, a.comments_in_offer, a.return1, a.return2,
              a.hold_flag, a.created_by, a.creation_date,
              a.last_updated_by, a.last_update_date, a.last_update_login,
              a.sent_to_ucas, a.test_cond_cat, a.test_cond_name, a.inst_reference ,
              a.auto_generated_flag, a.system_code , a.ucas_cycle, a.modular, a.part_time
       FROM igs_uc_transactions a, igs_uc_cyc_defaults b
       WHERE a.sent_to_ucas = 'N' AND a.hold_flag = 'N'
       AND a.ucas_cycle = cp_conf_cycle
       AND a.system_code = b.system_code
       AND a.ucas_cycle  = b.ucas_cycle
       AND b.ucas_interface = 'H'
       ORDER BY a.creation_date;

    CURSOR cur_update_info(cp_appno igs_uc_transactions.app_no%TYPE) IS
       SELECT appno, choiceno, transactionID, errorcode,
              timestamp, updater, return1, return2, soc
       FROM  igs_uc_u_tranin_2003
       WHERE appno = cp_appno
       AND transactionID = (SELECT MAX(TransactionID)
                            FROM  igs_uc_u_tranin_2003
                            WHERE appno = cp_appno);

    CURSOR cur_offer_conds(cp_test_cond_cat igs_uc_transactions.test_cond_cat%TYPE,
                           cp_test_cond_name igs_uc_transactions.test_cond_name%TYPE) IS
       SELECT a.ROWID,a.condition_category, a.condition_name,
              a.effective_from, a.effective_to, a.status, a.marvin_code,
              a.summ_of_cond, a.letter_text, a.created_by,
              a.creation_date, a.last_updated_by,
              a.last_update_date, a.last_update_login, a.decision
       FROM   igs_uc_offer_conds a
       WHERE a.condition_category = cp_test_cond_cat
       AND   a.condition_name = cp_test_cond_name;

    l_app_no igs_uc_transactions.app_no%TYPE;
    l_user_id Varchar2(20) :=  fnd_global.user_id;
    l_soc igs_uc_transactions.soc%TYPE;

  BEGIN

      -- get the Transaction records from IGS_UC_TRANSACTIONS table and insert into Hercules igs_uc_u_tranin_2003 View.
      FOR uc_transaction_rec IN cur_records_to_write(p_conf_cycle)
      LOOP
        l_app_no := uc_transaction_rec.app_no;

        INSERT INTO igs_uc_u_tranin_2003(transactionid,
                            timestamp,
                            updater,
                            errorcode,
                            transactiontype,
                            appno,
                            choiceno,
                            decision,
                            course,
                            campus,
                            entrymonth,
                            entryyear,
                            entrypoint,
                            SOC,
                            freeformat,
                            return1,
                            return2,
                            instreference
                            )
          VALUES(NULL,
                 NULL,
                 NULL,
                 NULL,
                 uc_transaction_rec.transaction_type,
                 uc_transaction_rec.app_no,
                 uc_transaction_rec.choice_no,
                 uc_transaction_rec.decision,
                 REPLACE(uc_transaction_rec.program_code, '*', ' '),
                 REPLACE(uc_transaction_rec.campus, '*', ' '),
                 uc_transaction_rec.entry_month,
                 uc_transaction_rec.entry_year,
                 uc_transaction_rec.entry_point,
                 uc_transaction_rec.SOC,
                 uc_transaction_rec.comments_in_offer,
                 uc_transaction_rec.return1,
                 uc_transaction_rec.return2,
                 uc_transaction_rec.inst_reference
                 );

        -- Get back the values for transactionID,errorcode,timestamp,updater,return1,return2 columns for
        -- the newly inserted record from TranIn and Update the IGS_UC_TRANSACTIONS Table.

        FOR tranin_rec IN cur_update_info(l_app_no)
        LOOP

      IF tranin_rec.errorcode = 0 THEN  --to update the SOC based on the errorcode value
        l_soc:=tranin_rec.soc;
      ELSE
        l_soc:=uc_transaction_rec.SOC;
      END IF;

          igs_uc_transactions_pkg.update_row (
                  x_mode                              => 'R',
                  x_rowid                             => uc_transaction_rec.ROWID,
                  x_uc_tran_id                        => uc_transaction_rec.UC_Tran_Id,
                  x_transaction_id                    => tranin_rec.transactionid,
                  x_datetimestamp                     => tranin_rec.timestamp,
                  x_updater                           => tranin_rec.updater,
                  x_error_code                        => tranin_rec.errorcode,
                  x_transaction_type                  => uc_transaction_rec.transaction_type,
                  x_app_no                            => uc_transaction_rec.app_no,
                  x_choice_no                         => uc_transaction_rec.choice_no,
                  x_decision                          => uc_transaction_rec.decision,
                  x_program_code                      => uc_transaction_rec.program_code,
                  x_campus                            => uc_transaction_rec.campus,
                  x_entry_month                       => uc_transaction_rec.entry_month,
                  x_entry_year                        => uc_transaction_rec.entry_year,
                  x_entry_point                       => uc_transaction_rec.entry_point,
                  x_soc                               => l_soc,
                  x_comments_in_offer                 => uc_transaction_rec.comments_in_offer,
                  x_return1                           => tranin_rec.return1,
                  x_return2                           => tranin_rec.return2,
                  x_hold_flag                         => uc_transaction_rec.hold_flag,
                  x_sent_to_ucas                      => 'Y',
                  x_test_cond_cat                     => uc_transaction_rec.test_cond_cat,
                  x_test_cond_name                    => uc_transaction_rec.test_cond_name,
                  x_inst_reference                    => uc_transaction_rec.inst_reference ,
                  x_auto_generated_flag               => uc_transaction_rec.auto_generated_flag,
                  x_system_code                       => uc_transaction_rec.system_code,
                  x_ucas_cycle                        => uc_transaction_rec.ucas_cycle,
                  x_modular                           => uc_transaction_rec.modular,
                  x_part_time                         => uc_transaction_rec.part_time);
          -- Check for 'XA' and 'XD' type transactions.

          IF uc_transaction_rec.transaction_type = 'XA' OR uc_transaction_rec.transaction_type = 'XD' THEN
            --If errorcode returned from 'TranIn' view success then the status field in IGS_UC_OFFER_CONDS should be updated accordingly.
            --Also if errorcode returned is not success then the status field in IGS_UC_OFFER_CONDS should be updated with corresponding to failed.

            IF tranin_rec.errorcode = 0 THEN
              FOR offer_conds_rec1 IN cur_offer_conds(uc_transaction_rec.test_cond_cat,uc_transaction_rec.test_cond_name)
              LOOP
                igs_uc_offer_conds_pkg.update_row (
                                  x_mode                              => 'R',
                                  x_rowid                             => offer_conds_rec1.ROWID,
                                  x_condition_category                => offer_conds_rec1.condition_category,
                                  x_condition_name                    => offer_conds_rec1.condition_name,
                                  x_effective_from                    => offer_conds_rec1.effective_from,
                                  x_effective_to                      => offer_conds_rec1.effective_to,
                                  x_status                            => 'A',
                                  x_marvin_code                       => offer_conds_rec1.marvin_code,
                                  x_summ_of_cond                      => NVL(offer_conds_rec1.summ_of_cond, tranin_rec.soc),
                                  x_letter_text                       => tranin_rec.return2,
                                  x_decision                          => offer_conds_rec1.decision
                                  );
              END LOOP;
            ELSE
              FOR offer_conds_rec1 IN cur_offer_conds(uc_transaction_rec.test_cond_cat,uc_transaction_rec.test_cond_name)
              LOOP
                igs_uc_offer_conds_pkg.update_row (
                                  x_mode                              => 'R',
                                  x_rowid                             => offer_conds_rec1.ROWID,
                                  x_condition_category                => offer_conds_rec1.condition_category,
                                  x_condition_name                    => offer_conds_rec1.condition_name,
                                  x_effective_from                    => offer_conds_rec1.effective_from,
                                  x_effective_to                      => offer_conds_rec1.effective_to,
                                  x_status                            => 'F',
                                  x_marvin_code                       => offer_conds_rec1.marvin_code,
                                  x_summ_of_cond                      => NVL(offer_conds_rec1.summ_of_cond, tranin_rec.soc),
                                  x_letter_text                       => tranin_rec.return2,
                                  x_decision                          => offer_conds_rec1.decision
                                  );
              END LOOP;
            END IF; --end error code
          END IF; --end 'XA', 'XD'

          --To generate the Transaction record in the Log file
          FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(tranin_rec.transactionid,16)|| RPAD(tranin_rec.appno,20) || RPAD(tranin_rec.choiceno,15) ||
                                          RPAD(NVL(TO_CHAR(tranin_rec.timestamp,'DD-MON-YYYY HH24:MI:SS'),' '),23) ||
                                          RPAD(NVL(TO_CHAR(tranin_rec.errorcode),' '),12) || RPAD(NVL(TO_CHAR(tranin_rec.return1),' '),9) ||
                                          tranin_rec.return2);

        END LOOP;
      END LOOP;

    EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_uc_tran_processor_pkg.proc_tranin_2003');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

 END proc_tranin_2003;

 PROCEDURE proc_tranin_2004(p_conf_cycle  IN igs_uc_defaults.configured_cycle%TYPE,
                            p_system_code IN igs_uc_ucas_control.system_code%TYPE) IS

  /*********************************************************************
   Created By      : pmarada
   Date Created By : 10-June-2003
   Purpose: To write into TRANIN when the 'sent_to_ucas' and 'hold_flag' flag is no.
            and cycle is 2004 then write the transaction details into Tranin and
            Also updates igs_uc_transactions with info. from TRANIN, and update the
            igs_uc_offer_conds table with status.
   Know limitations, enhancements or remarks
   Change History  (reverse chronological order - newest change first)

   Who        When         What
   jchakrab   23-May-2006  Modified for 5155053 - use roundno column (for choice no) for GTTR transactions
   jbaber     19-Aug-2005  Modified for UC307 - HERCULES Small Systems Support
                           Added p_system_code parameter
   jbaber     12-Jul-2004  Modified for UC315 - UCAS 2006 Support
                           Appended check_digit to appno when configured cycle > 2005
   arvsrini   26-Apr-2004  Added code to update IGS_UC_TRANSACTIONS.SOC based on
               the errorcode value Bug#3576288
  **********************************************************************/

    CURSOR cur_records_to_write(cp_conf_cycle igs_uc_defaults.configured_cycle%TYPE) IS
       SELECT a.ROWID,a.uc_tran_id,a.transaction_id, a.datetimestamp,
              a.updater, a.error_code, a.transaction_type, a.app_no,
              a.choice_no, a.decision, a.program_code,
              a.campus, a.entry_month, a.entry_year, a.entry_point,
              a.soc, a.comments_in_offer, a.return1, a.return2,
              a.hold_flag, a.created_by, a.creation_date,
              a.last_updated_by, a.last_update_date, a.last_update_login,
              a.sent_to_ucas, a.test_cond_cat, a.test_cond_name, a.inst_reference ,
              a.auto_generated_flag, a.system_code , a.ucas_cycle, a.modular, a.part_time
       FROM igs_uc_transactions a, igs_uc_cyc_defaults b
       WHERE a.sent_to_ucas = 'N' AND a.hold_flag = 'N'
       AND a.ucas_cycle = cp_conf_cycle
       AND a.system_code = p_system_code
       AND a.system_code = b.system_code
       AND a.ucas_cycle  = b.ucas_cycle
       AND b.ucas_interface = 'H'
       ORDER BY a.creation_date;

    CURSOR cur_update_info(cp_appno igs_uc_transactions.app_no%TYPE) IS
       SELECT appno, choiceno, transactionID, errorcode,
              timestamp, updater, return1, return2, soc, roundno
       FROM igs_uc_u_tranin_2004
       WHERE appno = cp_appno
       AND transactionID = (SELECT MAX(TransactionID)
                            FROM igs_uc_u_tranin_2004
                            WHERE appno = cp_appno);

    CURSOR cur_offer_conds(cp_test_cond_cat igs_uc_transactions.test_cond_cat%TYPE,
                           cp_test_cond_name igs_uc_transactions.test_cond_name%TYPE) IS
       SELECT a.ROWID,a.condition_category, a.condition_name,
              a.effective_from, a.effective_to, a.status, a.marvin_code,
              a.summ_of_cond, a.letter_text, a.created_by,
              a.creation_date, a.last_updated_by,
              a.last_update_date, a.last_update_login, a.decision
       FROM   igs_uc_offer_conds a
       WHERE a.condition_category = cp_test_cond_cat
       AND   a.condition_name = cp_test_cond_name;

    -- Cursor to convert 8-digit appno to 9 digit NUMBER with check digit for UC315 - UCAS 2006 Support
    CURSOR cur_appno(cp_appno igs_uc_applicants.app_no%TYPE) IS
       SELECT TO_NUMBER(app_no || check_digit)
       FROM igs_uc_applicants
       WHERE app_no = cp_appno;

    l_user_id Varchar2(20) :=  fnd_global.user_id;
    l_soc     igs_uc_transactions.soc%TYPE;
    l_appno   igs_uc_u_tranin_2004.appno%TYPE;

  BEGIN

      --When the Interface is Hercules then get the Transaction records from IGS_UC_TRANSACTIONS table and insert into Hercules igs_uc_u_tranin_2004 .
      FOR uc_transaction_rec IN cur_records_to_write(p_conf_cycle)
      LOOP

        -- For cycle 2004 syscode, roundno, modular, parttime columns are added in tranin table
        -- Determine appno based on configured year.
        IF p_conf_cycle < 2006 THEN
            l_appno := uc_transaction_rec.app_no;
        ELSE
            -- Convert 8-digit appno to 9 digit NUMBER with check digit for UC315 - UCAS 2006 Support
            OPEN cur_appno(uc_transaction_rec.app_no);
            FETCH cur_appno INTO l_appno;
            CLOSE cur_appno;
        END IF;

        IF uc_transaction_rec.system_code = 'G' THEN

             INSERT INTO igs_uc_u_tranin_2004(transactionid,
                                 timestamp,
                                 updater,
                                 errorcode,
                                 transactiontype,
                                 appno,
                                 choiceno,
                                 decision,
                                 course,
                                 campus,
                                 entrymonth,
                                 entryyear,
                                 entrypoint,
                                 SOC,
                                 freeformat,
                                 return1,
                                 return2,
                                 instreference,
                                 syscode,
                                 roundno,
                                 modular,
                                 parttime)
               VALUES(NULL,
                      NULL,
                      NULL,
                      NULL,
                      uc_transaction_rec.transaction_type,
                      l_appno,
                      NULL,
                      uc_transaction_rec.decision,
                      REPLACE(uc_transaction_rec.program_code, '*', ' '),
                      REPLACE(uc_transaction_rec.campus, '*', ' '),
                      uc_transaction_rec.entry_month,
                      uc_transaction_rec.entry_year,
                      uc_transaction_rec.entry_point,
                      uc_transaction_rec.SOC,
                      uc_transaction_rec.comments_in_offer,
                      uc_transaction_rec.return1,
                      uc_transaction_rec.return2,
                      uc_transaction_rec.inst_reference,
                      uc_transaction_rec.system_code,
                      uc_transaction_rec.choice_no,
                      uc_transaction_rec.modular,
                      uc_transaction_rec.part_time);

        ELSE

             INSERT INTO igs_uc_u_tranin_2004(transactionid,
                                timestamp,
                                updater,
                                errorcode,
                                transactiontype,
                                appno,
                                choiceno,
                                decision,
                                course,
                                campus,
                                entrymonth,
                                entryyear,
                                entrypoint,
                                SOC,
                                freeformat,
                                return1,
                                return2,
                                instreference,
                                syscode,
                                roundno,
                                modular,
                                parttime)
               VALUES(NULL,
                      NULL,
                      NULL,
                      NULL,
                      uc_transaction_rec.transaction_type,
                      l_appno,
                      uc_transaction_rec.choice_no,
                      uc_transaction_rec.decision,
                      REPLACE(uc_transaction_rec.program_code, '*', ' '),
                      REPLACE(uc_transaction_rec.campus, '*', ' '),
                      uc_transaction_rec.entry_month,
                      uc_transaction_rec.entry_year,
                      uc_transaction_rec.entry_point,
                      uc_transaction_rec.SOC,
                      uc_transaction_rec.comments_in_offer,
                      uc_transaction_rec.return1,
                      uc_transaction_rec.return2,
                      uc_transaction_rec.inst_reference,
                      uc_transaction_rec.system_code,
                      NULL,
                      NULL,
                      NULL);

        END IF;

        -- Get back the values for transactionID,errorcode,timestamp,updater,return1,return2 columns for
        -- the newly inserted record from igs_uc_u_tranin_2004 and Update the IGS_UC_TRANSACTIONS Table.

        FOR tranin_rec IN cur_update_info(l_appno)
        LOOP

      IF tranin_rec.errorcode = 0 THEN    --to update the SOC based on the errorcode value
        l_soc:=tranin_rec.soc;
      ELSE
        l_soc:=uc_transaction_rec.SOC;
      END IF;

      igs_uc_transactions_pkg.update_row (
                  x_mode                              => 'R',
                  x_rowid                             => uc_transaction_rec.ROWID,
                  x_uc_tran_id                        => uc_transaction_rec.UC_Tran_Id,
                  x_transaction_id                    => tranin_rec.transactionid,
                  x_datetimestamp                     => tranin_rec.timestamp,
                  x_updater                           => tranin_rec.updater,
                  x_error_code                        => tranin_rec.errorcode,
                  x_transaction_type                  => uc_transaction_rec.transaction_type,
                  x_app_no                            => uc_transaction_rec.app_no,
                  x_choice_no                         => uc_transaction_rec.choice_no,
                  x_decision                          => uc_transaction_rec.decision,
                  x_program_code                      => uc_transaction_rec.program_code,
                  x_campus                            => uc_transaction_rec.campus,
                  x_entry_month                       => uc_transaction_rec.entry_month,
                  x_entry_year                        => uc_transaction_rec.entry_year,
                  x_entry_point                       => uc_transaction_rec.entry_point,
                  x_soc                               => l_soc,
                  x_comments_in_offer                 => uc_transaction_rec.comments_in_offer,
                  x_return1                           => tranin_rec.return1,
                  x_return2                           => tranin_rec.return2,
                  x_hold_flag                         => uc_transaction_rec.hold_flag,
                  x_sent_to_ucas                      => 'Y',
                  x_test_cond_cat                     => uc_transaction_rec.test_cond_cat,
                  x_test_cond_name                    => uc_transaction_rec.test_cond_name,
                  x_inst_reference                    => uc_transaction_rec.inst_reference ,
                  x_auto_generated_flag               => uc_transaction_rec.auto_generated_flag,
                  x_system_code                       => uc_transaction_rec.system_code,
                  x_ucas_cycle                        => uc_transaction_rec.ucas_cycle,
                  x_modular                           => uc_transaction_rec.modular,
                  x_part_time                         => uc_transaction_rec.part_time);
          -- Check for 'XA' and 'XD' type transactions.

          IF uc_transaction_rec.transaction_type = 'XA' OR uc_transaction_rec.transaction_type = 'XD' THEN
            --If errorcode returned from 'TranIn' view success then the status field in IGS_UC_OFFER_CONDS should be updated accordingly.
            --Also if errorcode returned is not success then the status field in IGS_UC_OFFER_CONDS should be updated with corresponding to failed.

            IF tranin_rec.errorcode = 0 THEN
              FOR offer_conds_rec1 IN cur_offer_conds(uc_transaction_rec.test_cond_cat,uc_transaction_rec.test_cond_name)
              LOOP
                igs_uc_offer_conds_pkg.update_row (
                                  x_mode                              => 'R',
                                  x_rowid                             => offer_conds_rec1.ROWID,
                                  x_condition_category                => offer_conds_rec1.condition_category,
                                  x_condition_name                    => offer_conds_rec1.condition_name,
                                  x_effective_from                    => offer_conds_rec1.effective_from,
                                  x_effective_to                      => offer_conds_rec1.effective_to,
                                  x_status                            => 'A',
                                  x_marvin_code                       => offer_conds_rec1.marvin_code,
                                  x_summ_of_cond                      => NVL(offer_conds_rec1.summ_of_cond, tranin_rec.soc),
                                  x_letter_text                       => tranin_rec.return2,
                                  x_decision                          => offer_conds_rec1.decision
                                  );

              END LOOP;
            ELSE
              FOR offer_conds_rec1 IN cur_offer_conds(uc_transaction_rec.test_cond_cat,uc_transaction_rec.test_cond_name)
              LOOP
                igs_uc_offer_conds_pkg.update_row (
                                  x_mode                              => 'R',
                                  x_rowid                             => offer_conds_rec1.ROWID,
                                  x_condition_category                => offer_conds_rec1.condition_category,
                                  x_condition_name                    => offer_conds_rec1.condition_name,
                                  x_effective_from                    => offer_conds_rec1.effective_from,
                                  x_effective_to                      => offer_conds_rec1.effective_to,
                                  x_status                            => 'F',
                                  x_marvin_code                       => offer_conds_rec1.marvin_code,
                                  x_summ_of_cond                      => NVL(offer_conds_rec1.summ_of_cond, tranin_rec.soc),
                                  x_letter_text                       => tranin_rec.return2,
                                  x_decision                          => offer_conds_rec1.decision
                                  );
              END LOOP;
            END IF; --end error code
          END IF; --end 'XA', 'XD'

          IF uc_transaction_rec.system_code = 'G' THEN
              --To generate the Transaction record in the Log file
              FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(tranin_rec.transactionid,16)|| RPAD(tranin_rec.appno,20) || RPAD(tranin_rec.roundno,15) ||
                                          RPAD(NVL(TO_CHAR(tranin_rec.timestamp,'DD-MON-YYYY HH24:MI:SS'),' '),23) ||
                                          RPAD(NVL(TO_CHAR(tranin_rec.errorcode),' '),12) || RPAD(NVL(TO_CHAR(tranin_rec.return1),' '),9) ||
                                          tranin_rec.return2);
          ELSE
              --To generate the Transaction record in the Log file
              FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(tranin_rec.transactionid,16)|| RPAD(tranin_rec.appno,20) || RPAD(tranin_rec.choiceno,15) ||
                                          RPAD(NVL(TO_CHAR(tranin_rec.timestamp,'DD-MON-YYYY HH24:MI:SS'),' '),23) ||
                                          RPAD(NVL(TO_CHAR(tranin_rec.errorcode),' '),12) || RPAD(NVL(TO_CHAR(tranin_rec.return1),' '),9) ||
                                          tranin_rec.return2);
          END IF;

        END LOOP;
      END LOOP;

    EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_uc_tran_processor_pkg.proc_tranin_2004'||' - '||SQLERRM);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

 END proc_tranin_2004;

 PROCEDURE trans_write(p_system_code IN  igs_uc_ucas_control.system_code%TYPE,
                       errbuf        OUT NOCOPY VARCHAR2,
                       retcode       OUT NOCOPY NUMBER) IS
/*************************************************************
  Created By      : Pmarada
  Date Created By : 10-Jun-2003
  Purpose :  This is main procedure, the procedure will calls the subprocedures
             dependends on the cycle.as per the UCFD203 Multiple cycles build.
  Know limitations, enhancements or remarks
  Change History  (reverse chronological order - newest change first)
   who         when      what
   jbaber    19-Aug-05  Modified for UC307 - HERCULES Small Systems Support
                        Added p_system_code parameter
   jbaber    12-Jul-05  Modified for UC315 - UCAS Support 2006
                        Replaced reference to igs_uc_cvcontrol_2003_v with igs_uc_ucas_control
   jchakrab  27-Jul-04  Modified for UCFD308 - UCAS - 2005 Regulatory Changes
   rgangara  23-Jan-04  Changed the variable declaration of L_entry_year to type
                        of configured cycle i.e 4 Digit Number from cvcontrol.entryyear
                        which is a 2 Digit Number as fix for bug# 3392506

*************************************************************/

    CURSOR cur_cycle IS
    SELECT max(current_cycle) current_cycle, max(configured_cycle) configured_cycle
    FROM igs_uc_defaults ;

    cur_cycle_rec cur_cycle%ROWTYPE;

    l_entry_year igs_uc_defaults.configured_cycle%TYPE;

 BEGIN
        --To generate the Header Line in the Log File
        FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('-',105,'-'));
        FND_MESSAGE.SET_NAME('IGS','IGS_UC_TRANS_LOG_HEADER');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('-',105,'-'));

         -- get the ucas configured cycle
         OPEN cur_cycle;
         FETCH cur_cycle INTO cur_cycle_rec;
         CLOSE cur_cycle;

         -- Depends on the cycle call the respective cycle procedure
         -- If cycle is 2003 call the Proc_Tranin_2003
         IF cur_cycle_rec.configured_cycle = 2003 THEN
            Proc_Tranin_2003(p_conf_cycle => cur_cycle_rec.configured_cycle);
         -- If cycle is 2004 or 2005 call the Proc_Tranin_2004
         ELSIF cur_cycle_rec.configured_cycle = 2004 OR cur_cycle_rec.configured_cycle = 2005 OR cur_cycle_rec.configured_cycle = 2006 OR cur_cycle_rec.configured_cycle = 2007 THEN
            Proc_Tranin_2004(p_conf_cycle => cur_cycle_rec.configured_cycle,
                             p_system_code => p_system_code);
         END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      retcode :=2;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_UC_TRAN_PROCESSOR_PKG.TRANS_WRITE'||' - '||SQLERRM);
      Errbuf := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.LOG,Errbuf);
      app_exception.raise_exception;

 END trans_write;

 FUNCTION get_adm_offer_resp_stat  (
       p_alt_appl_id IN igs_ad_appl_all.alt_appl_id%TYPE,
       p_choice_number IN  igs_ad_appl_all.choice_number%TYPE,
       p_old_outcome_status IN igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
       p_new_outcome_status IN igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
       p_old_adm_offer_resp_status IN igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
       p_message_name OUT NOCOPY VARCHAR2
       )  RETURN VARCHAR2 IS

/*************************************************************
    Created By      : rghosh
    Date Created By : 01-Apr-2003
    Purpose : this function will return the user defined offer response status mapped with
                        which the Admission Application instance has to be updated with, after validating
                        the Old and New Outcome statuses and Offer Response Status against UCAS setup.
    Know limitations, enhancements or remarks
    Change History

*************************************************************/

  -- Cursor to find the system code associated with the UCAS application

  CURSOR c_sys_cd (cp_alt_appl_id igs_ad_appl_all.alt_appl_id%TYPE ) IS
    SELECT  system_code
    FROM igs_uc_applicants
    WHERE TO_CHAR(app_no) = cp_alt_appl_id;

  l_sys_cd igs_uc_applicants.system_code%TYPE;

  --Cursor to get the decision code associated with the current outcome status and the new outcome status

  CURSOR c_decision_cd(cp_system_code igs_uc_app_choices.system_code%TYPE,
                                                    cp_outcome_status  igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE)  IS
    SELECT decision_code
    FROM igs_uc_map_out_stat
    WHERE system_code = cp_system_code
    AND adm_outcome_status = cp_outcome_status
    AND closed_ind = 'N';

  l_decision_code igs_uc_map_out_stat.decision_code%TYPE;

  -- Cursor to find out if the reply code of Firm Acceptance is mapped to the decision code returned from the cursor (c_decision_cd) with the old outcome status

  CURSOR c_curr_off_resp_status (cp_system_code igs_uc_app_choices.system_code%TYPE,
                                                                        cp_decision_code igs_uc_map_out_stat.decision_code%TYPE,
                                                                        cp_adm_offer_resp_status igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE)  IS
    SELECT 'X'
    FROM igs_uc_map_off_resp
    WHERE decision_code= cp_decision_code
    AND system_code = cp_system_code
    AND closed_ind =  'N'
    AND reply_code = 'F'
    AND adm_offer_resp_status = cp_adm_offer_resp_status;

  l_curr_off_resp_status VARCHAR2(1);

  --Cursor to select the decision code associated with the new outcome status

  l_off_resp_dec_cd igs_uc_map_out_stat.decision_code%TYPE;

  -- Cursor to get the admission offer response mapped out to the reply code of Firm Acceptance and decision code returned from the cursor (c_decision_cd) with the new
  -- outcome status

  CURSOR c_new_off_resp_status(cp_system_code igs_uc_app_choices.system_code%TYPE,
                                                                      cp_decision_code igs_uc_map_out_stat.decision_code%TYPE)  IS
    SELECT adm_offer_resp_status
    FROM igs_uc_map_off_resp
    WHERE system_code = cp_system_code
    AND decision_code= cp_decision_code
    AND  closed_ind =  'N'
    AND reply_code = 'F' ;

  l_new_off_resp_status  igs_uc_map_off_resp.adm_offer_resp_status%TYPE;

 BEGIN

   OPEN  c_sys_cd(p_alt_appl_id);
   FETCH c_sys_cd INTO l_sys_cd;
   IF c_sys_cd%NOTFOUND THEN
     CLOSE c_sys_cd;
     RETURN NULL;
   END IF;
   CLOSE c_sys_cd;

   OPEN c_decision_cd(l_sys_cd,p_old_outcome_status);
   FETCH c_decision_cd INTO l_decision_code;
   IF c_decision_cd%NOTFOUND THEN
     CLOSE c_decision_cd;
     p_message_name := 'IGS_UC_NO_ACT_DEC_CODE_CONDOFR';
     RETURN NULL;
   END IF;
   CLOSE c_decision_cd;

   OPEN c_curr_off_resp_status(l_sys_cd,l_decision_code,p_old_adm_offer_resp_status);
   FETCH c_curr_off_resp_status INTO l_curr_off_resp_status;
   IF c_curr_off_resp_status%NOTFOUND THEN
     CLOSE c_curr_off_resp_status;
     p_message_name := 'IGS_UC_NO_ACTIVE_REPLY_CODE';
     RETURN NULL;
   END IF;
   CLOSE c_curr_off_resp_status;

   OPEN c_decision_cd(l_sys_cd,p_new_outcome_status);
   FETCH c_decision_cd INTO l_off_resp_dec_cd;
   IF c_decision_cd%NOTFOUND THEN
     CLOSE c_decision_cd;
     p_message_name := 'IGS_UC_NO_ACT_DEC_CODE_OFFER';
     RETURN NULL;
   END IF;
   CLOSE c_decision_cd;

   OPEN  c_new_off_resp_status(l_sys_cd,l_off_resp_dec_cd);
   FETCH c_new_off_resp_status INTO l_new_off_resp_status;
   IF c_new_off_resp_status%NOTFOUND THEN
     CLOSE c_new_off_resp_status;
     p_message_name := 'IGS_UC_NO_MAP_REPLY_CODE';
     RETURN NULL;
   END IF;
   CLOSE c_new_off_resp_status;

   RETURN l_new_off_resp_status;


 EXCEPTION

   WHEN OTHERS THEN

   IF  c_sys_cd%ISOPEN THEN
     CLOSE c_sys_cd;
   END IF;

   IF c_decision_cd%ISOPEN THEN
     CLOSE c_decision_cd;
   END IF;

   IF c_curr_off_resp_status%ISOPEN THEN
     CLOSE c_curr_off_resp_status;
   END IF;

   IF c_new_off_resp_status%ISOPEN THEN
     CLOSE c_new_off_resp_status;
   END IF;

   RETURN NULL;

   END get_adm_offer_resp_stat;

END igs_uc_tran_processor_pkg;

/
