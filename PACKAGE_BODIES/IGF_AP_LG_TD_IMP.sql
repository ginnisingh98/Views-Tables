--------------------------------------------------------
--  DDL for Package Body IGF_AP_LG_TD_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LG_TD_IMP" AS
/* $Header: IGFAP39B.pls 120.9 2006/03/07 23:25:05 veramach ship $ */

g_log_tab_index   NUMBER := 0;

TYPE log_record IS RECORD
        ( person_number VARCHAR2(30),
          message_text VARCHAR2(500));

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record
           index by binary_integer;

g_log_tab LogTab;

-- THIS IS THE GLOBAL CURSOR THAT IS USED TO UPDATE THE  FA BASE RECORD IF THE TODO ITEMS ARE SUCCESSFULLY IMPORTED

CURSOR c_baseid_exists(cp_base_id NUMBER)
    IS
    SELECT  ROWID  row_id,
            base_id,
            ci_cal_type,
            person_id,
            ci_sequence_number,
            org_id ,
            bbay  ,
            current_enrolled_hrs ,
            special_handling,
            coa_pending,
            sap_evaluation_date,
            sap_selected_flag,
            state_sap_status,
            verification_process_run,
            inst_verif_status_date,
            manual_verif_flag,
            fed_verif_status,
            fed_verif_status_date,
            inst_verif_status,
            nslds_eligible,
            ede_correction_batch_id,
            fa_process_status_date,
            isir_corr_status,
            isir_corr_status_date,
            isir_status,
            isir_status_date,
            profile_status,
            profile_status_date,
            profile_fc,
            pell_eligible,
            award_adjusted,
            change_pending,
            coa_code_f,
            coa_fixed,
            coa_code_i,
            coa_f,
            coa_i                   ,
            coa_pell                ,
            disbursement_hold       ,
            enrolment_status        ,
            enrolment_status_date   ,
            fa_process_status       ,
            federal_sap_status      ,
            grade_level             ,
            grade_level_date        ,
            grade_level_type        ,
            inst_sap_status         ,
            last_packaged           ,
            notification_status     ,
            notification_status_date ,
            packaging_hold          ,
            nslds_data_override_flg ,
            packaging_status        ,
            prof_judgement_flg      ,
            packaging_status_date   ,
            qa_sampling             ,
            target_group            ,
            todo_code               ,
            total_package_accepted  ,
            total_package_offered   ,
            transcript_available    ,
            tolerance_amount ,
            transfered ,
            total_aid ,
            admstruct_id,
            admsegment_1 ,
            admsegment_2 ,
            admsegment_3 ,
            admsegment_4 ,
            admsegment_5 ,
            admsegment_6,
            admsegment_7,
            admsegment_8,
            admsegment_9,
            admsegment_10,
            admsegment_11,
            admsegment_12,
            admsegment_13,
            admsegment_14,
            admsegment_15,
            admsegment_16,
            admsegment_17,
            admsegment_18,
            admsegment_19,
            admsegment_20,
            packstruct_id,
            packsegment_1,
            packsegment_2,
            packsegment_3,
            packsegment_4,
            packsegment_5,
            packsegment_6,
            packsegment_7,
            packsegment_8,
            packsegment_9,
            packsegment_10,
            packsegment_11,
            packsegment_12,
            packsegment_13,
            packsegment_14,
            packsegment_15,
            packsegment_16,
            packsegment_17,
            packsegment_18,
            packsegment_19,
            packsegment_20,
            miscstruct_id ,
            miscsegment_1,
            miscsegment_2 ,
            miscsegment_3 ,
            miscsegment_4,
            miscsegment_5,
            miscsegment_6,
            miscsegment_7,
            miscsegment_8,
            miscsegment_9,
            miscsegment_10,
            miscsegment_11,
            miscsegment_12,
            miscsegment_13,
            miscsegment_14,
            miscsegment_15,
            miscsegment_16,
            miscsegment_17,
            miscsegment_18,
            miscsegment_19,
            miscsegment_20,
            request_id,
            program_application_id,
            program_id            ,
            program_update_date,
            manual_disb_hold,
            pell_alt_expense,
            assoc_org_num,           --Modified(added this attribute) by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
            award_fmly_contribution_type,
            isir_locked_by,
	    adnl_unsub_loan_elig_flag,
            lock_awd_flag,
            lock_coa_flag
    FROM   igf_ap_fa_base_rec_all FA
    WHERE  FA.base_id = cp_base_id;

    g_baseid_exists c_baseid_exists%ROWTYPE;

  -- museshad (FA 140). Forward declaration
  PROCEDURE process_pref_lender(
                                  p_base_id           IN            igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_rel_cd            IN            igf_ap_li_todo_ints.relationship_cd%TYPE,
                                  p_clprl_id          OUT NOCOPY    igf_sl_cl_pref_lenders.clprl_id%TYPE
                               );
  -- museshad (FA 140)

  PROCEDURE main ( errbuf          OUT NOCOPY VARCHAR2,
                                  retcode         OUT NOCOPY NUMBER,
                                  p_award_year    IN         VARCHAR2,
                                  p_batch_id      IN         NUMBER,
                                  p_del_ind       IN         VARCHAR2 )
    IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : Main process which imports the To Do Items attached to a student in the system.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
	||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  museshad        25-Jul-2005     FA 140. Validation for preferred lender. After successful import,
    ||                                  insert Pref lender details
    ||  (reverse chronological order - newest change first)
    */
    l_proc_item_str    VARCHAR2(50) := NULL;
    l_message_str     VARCHAR2(800) := NULL;
    l_terminate_flag  BOOLEAN := FALSE;
    l_error_flag      BOOLEAN := FALSE;
    l_error           VARCHAR2(10);
    lv_row_id         VARCHAR2(80) := NULL;
    lv_person_id           igs_pe_hz_parties.party_id%TYPE := NULL;
    lv_base_id             igf_ap_fa_base_rec_all.base_id%TYPE := NULL;
    l_old_person_number    igf_ap_li_todo_ints.person_number%TYPE := '******';
    l_current_person_number igf_ap_li_todo_ints.person_number%TYPE := NULL;
    l_person_skip_flag   BOOLEAN  := FALSE;
    l_success_record_cnt    NUMBER := 0;
    l_error_record_cnt      NUMBER := 0;
    l_todo_flag          BOOLEAN := FALSE;
    l_chk_batch       VARCHAR2(1) := 'Y';
    l_chk_profile     VARCHAR2(1) := 'Y';
    l_debug_str       VARCHAR2(800) := NULL;
    l_total_record_cnt      NUMBER := 0;
    l_get_meaning         igf_lookups_view.meaning%TYPE := NULL;
    l_todo_number         igf_ap_td_item_mst_all.todo_number%TYPE := NULL;

    l_cal_type   igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
    l_seq_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;

    -- Cursor for getting the context award year details
    CURSOR c_get_status(cp_cal_type VARCHAR2,
                       cp_seq_number NUMBER)
    IS
    SELECT sys_award_year,
           award_year_status_code
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_seq_number;

    l_get_status c_get_status%ROWTYPE;

    CURSOR c_get_alternate_code(cp_cal_type VARCHAR2,
                                cp_seq_number NUMBER)
    IS
    SELECT alternate_code
    FROM   igs_ca_inst
    WHERE  cal_type = cp_cal_type
    AND    sequence_number = cp_seq_number;

    l_get_alternate_code  c_get_alternate_code%ROWTYPE;

    CURSOR c_get_persons(cp_alternate_code VARCHAR2,
                         cp_batch_id NUMBER)
    IS
    SELECT  batch_num,
            tdint_id,
            ci_alternate_code,
            person_number,
            item_code,
            item_add_date,
            item_status_code,
            item_status_date,
            corsp_date,
            corsp_count_num,
            max_attempt_num,
            freq_attempt_num,
            reqd_for_application_flag,
            inactive_flag,
            import_status_type,
            import_record_type,
            relationship_cd,
            ROWID ROW_ID
    FROM    igf_ap_li_todo_ints
    WHERE   ci_alternate_code = cp_alternate_code
    AND     batch_num = cp_batch_id
    AND     import_status_type IN ('U','R')

    ORDER BY person_number;

    l_get_persons c_get_persons%ROWTYPE;

    CURSOR c_get_crsp_hist(cp_cal_type VARCHAR2,
                            cp_seq_number NUMBER,
                            cp_person_number VARCHAR2)
    IS
    SELECT hz.party_number person_id
    FROM   igs_co_interac_hist   hist,
           hz_parties hz
    WHERE  hist.cal_type = cp_cal_type
    AND    hist.ci_sequence_number = cp_seq_number
    AND    hist.student_id = hz.party_id
    AND    hz.party_number = cp_person_number
    AND    rownum = 1;

    l_get_crsp_hist  c_get_crsp_hist%ROWTYPE;

    CURSOR c_todo_item_valid(cp_cal_type VARCHAR2,
                             cp_seq_number NUMBER,
                             cp_item_code VARCHAR2)
    IS
    (
      SELECT todo_number
      FROM   igf_ap_td_item_mst_all
      WHERE  ci_cal_type = cp_cal_type
      AND    ci_sequence_number = cp_seq_number
      AND    item_code = NVL(cp_item_code,item_code)
      AND    CAREER_ITEM = 'N'
      UNION
      SELECT todo_number
      FROM   igf_ap_td_item_mst_all
      WHERE  item_code = NVL(cp_item_code,item_code)
      AND    CAREER_ITEM = 'Y'
    );

    l_todo_item_valid  c_todo_item_valid%ROWTYPE;

    CURSOR c_todo_dup(cp_base_id NUMBER,
                      cp_item_code VARCHAR2)
    IS
    SELECT item_sequence_number
    FROM   igf_ap_td_item_inst_v
    WHERE  base_id  = cp_base_id
    AND    item_code = cp_item_code;

    l_todo_dup c_todo_dup%ROWTYPE;

    CURSOR c_get_rowid(cp_item_seq_number NUMBER,
                       cp_base_id NUMBER)
    IS
    SELECT ROWID ROW_ID
    FROM   igf_ap_td_item_inst
    WHERE  base_id = cp_base_id
    AND    item_sequence_number = cp_item_seq_number;

    l_get_rowid   c_get_rowid%ROWTYPE;

    -- museshad (FA 140)
    CURSOR c_item_system_todo_type_code(
                                        cp_item_code      VARCHAR2,
                                        cp_cal_type       igs_ca_inst_all.cal_type%TYPE,
                                        cp_seq_number     igs_ca_inst_all.sequence_number%TYPE
                                       )
    IS
      SELECT  system_todo_type_code
      FROM    igf_ap_td_item_mst_all
      WHERE
              item_code = cp_item_code  AND
              system_todo_type_code IS NOT NULL;

    l_item_system_todo_type_code    igf_ap_td_item_mst_all.system_todo_type_code%TYPE;

    CURSOR c_chk_lender_rel (cp_rel_cd igf_sl_cl_recipient.relationship_cd%TYPE)
    IS
      SELECT  'X'
      FROM    igf_sl_cl_recipient
      WHERE   relationship_cd = cp_rel_cd AND
              UPPER(ENABLED)  = 'Y';

    l_chk_lender_rel_rec  VARCHAR2(1);
    l_clprl_id            igf_sl_cl_pref_lenders.clprl_id%TYPE;
    -- museshad (FA 140)

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    errbuf             := NULL;
    retcode            := 0;
    l_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_seq_number       := TO_NUMBER(SUBSTR(p_award_year,11));

    l_error := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');

    l_chk_profile := igf_ap_gen.check_profile;
    IF l_chk_profile = 'N' THEN
      fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      RETURN;
    END IF;

    -- this is to get the alternate code
    l_get_alternate_code := NULL;
    OPEN  c_get_alternate_code(l_cal_type,l_seq_number);
    FETCH c_get_alternate_code INTO l_get_alternate_code;
    CLOSE c_get_alternate_code;

    -- this is to check that the award year is valid or not
    l_get_status := NULL;
    OPEN  c_get_status(l_cal_type,l_seq_number);
    FETCH c_get_status INTO l_get_status;
    CLOSE c_get_status;

    IF l_get_status.sys_award_year IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_AWD_YR_NOT_FOUND');
      fnd_message.set_token('P_AWARD_YEAR',p_award_year);
      add_log_table(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    ELSIF
      l_get_status.award_year_status_code NOT IN('LD','O') THEN
      fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
      fnd_message.set_token('AWARD_STATUS',l_get_status.award_year_status_code);
      add_log_table(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    END IF;

    l_chk_batch := igf_ap_gen.check_batch(p_batch_id,'TODO');
    IF l_chk_batch = 'N' THEN
      fnd_message.set_name('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
      add_log_table(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    END IF;

    -- this is to check that the todo item setup is valid or not
    l_todo_item_valid := NULL;
    OPEN  c_todo_item_valid(l_cal_type,l_seq_number,NULL);
    FETCH c_todo_item_valid INTO l_todo_item_valid;
    CLOSE c_todo_item_valid;

    IF l_terminate_flag = TRUE THEN
      print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind);
      RETURN;
    END IF;
    -- THE MAIN LOOP STARTS HERE FOR FETCHING THE RECORD FROM THE INTERFACE TABLE

    OPEN c_get_persons(l_get_alternate_code.alternate_code,p_batch_id);
    LOOP
      BEGIN
        SAVEPOINT sp1;
        FETCH c_get_persons INTO l_get_persons;
        EXIT WHEN c_get_persons%NOTFOUND OR c_get_persons%NOTFOUND IS NULL;
        l_debug_str := 'Tdint_id is:' || l_get_persons.tdint_id;
        IF l_old_person_number <> l_get_persons.person_number THEN   -- THIS IS TO SEE IF THE CURRENT RECORD IS A NEW RECORD (HAVING DIFFERENT PERSON NUMBER)
                l_debug_str := l_debug_str || ' Inside new person check';
                IF l_person_skip_flag = FALSE AND l_old_person_number <> '******' THEN --INDIACTES THAT THE PERSON WAS NOT SKIPPED
                   IF l_todo_flag = TRUE THEN   --- THIS MEANS THAT AT LEAST ONE TODO ITEMS OF THE PERSON HAS BEEN SUCESSFULLY IMPORTED
                      -- updation of the FA Base Record Application Processing Status
                      update_fabase_process(l_old_person_number);
                   END IF;
                END IF;

                l_person_skip_flag := FALSE;
                l_todo_flag := FALSE;
                --set the old person and perform all the person level validations
                l_old_person_number := l_get_persons.person_number;
                lv_base_id := NULL;
                lv_person_id := NULL;
                --HERE CALL TO THE GENERIC WRAPPER IS BEING MADE TO CHEHK THE VALIDITY OF THE PEROSN AND BASE ID
                igf_ap_gen.check_person(l_get_persons.person_number,l_cal_type,l_seq_number,lv_person_id,lv_base_id);
                IF lv_person_id IS NULL THEN
                   fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
                   add_log_table(l_get_persons.person_number,l_error,fnd_message.get);
                   l_person_skip_flag := TRUE;
                ELSE
                   IF lv_base_id IS NULL THEN
                     fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
                     add_log_table(l_get_persons.person_number,l_error,fnd_message.get);
                     l_person_skip_flag := TRUE;
                   ELSE
                     g_baseid_exists := NULL;
                     OPEN  c_baseid_exists(lv_base_id);
                     FETCH c_baseid_exists INTO g_baseid_exists;
                     CLOSE c_baseid_exists;
                   END IF;
                END IF;
                 l_debug_str := l_debug_str || ' Person and Base ID check passed';
                l_get_crsp_hist := NULL;
                OPEN  c_get_crsp_hist(l_cal_type,l_seq_number,l_get_persons.person_number);
                FETCH c_get_crsp_hist INTO l_get_crsp_hist;
                CLOSE c_get_crsp_hist;
                IF l_get_crsp_hist.person_id IS NOT NULL THEN
                  fnd_message.set_name('IGF','IGF_AP_TD_CORSP_HIST_EXIST');
                  add_log_table(l_get_persons.person_number,l_error,fnd_message.get);
                  l_person_skip_flag := TRUE;
                END IF;
                IF l_person_skip_flag = TRUE THEN
                  UPDATE igf_ap_li_todo_ints
                  SET    import_status_type = 'E'
                  WHERE  ci_alternate_code = l_get_alternate_code.alternate_code
                  AND    person_number = l_get_persons.person_number
                  AND    batch_num = p_batch_id;
                END IF;
                 l_debug_str := l_debug_str || ' Correspondence check passed';
        END IF; -- HERE THE CHECK FOR DIFFERENT PERSON ENDS

        IF l_person_skip_flag = FALSE THEN
                -- the person is not to be skipped and the record level validations are to be done
                fnd_message.set_name('IGF','IGF_AP_PROC_ITM');
                fnd_message.set_token('ITEM',l_get_persons.item_code);
                l_proc_item_str := fnd_message.get;
                l_todo_item_valid := NULL;
                OPEN  c_todo_item_valid(l_cal_type,l_seq_number,l_get_persons.item_code);
                FETCH c_todo_item_valid INTO l_todo_item_valid;
                CLOSE c_todo_item_valid;
                IF l_todo_item_valid.todo_number IS NULL THEN
                        fnd_message.set_name('IGF','IGF_AP_TD_INVALID_ITM');
                        fnd_message.set_token('ITEM',l_get_persons.item_code);
                        l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                        add_log_table(l_get_persons.person_number,l_error,l_message_str);
                        l_message_str := NULL;
                        l_error_flag := TRUE;
                ELSE
                        l_debug_str := l_debug_str || ' Valid to do item passed';
                        l_todo_dup := NULL;
                        OPEN  c_todo_dup(g_baseid_exists.base_id,l_get_persons.item_code);
                        FETCH c_todo_dup INTO l_todo_dup;
                        CLOSE c_todo_dup;
                        IF l_todo_dup.item_sequence_number IS NOT NULL AND NVL(l_get_persons.import_record_type,'X') <> 'U' THEN
                          fnd_message.set_name('IGF','IGF_AP_TD_ITM_EXIST');
                          fnd_message.set_token('ITEM',l_get_persons.item_code);
                          l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                          add_log_table(l_get_persons.person_number,l_error,l_message_str);
                          l_message_str := NULL;
                          l_error_flag := TRUE;
                         END IF;
                        ----HERE THE VALIDATION IS TO BE DONE IF NULL AND 'U'
                        IF l_todo_dup.item_sequence_number IS NULL AND NVL(l_get_persons.import_record_type,'X') = 'U' THEN
                          fnd_message.set_name('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
                          l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                          add_log_table(l_get_persons.person_number,l_error,l_message_str);
                          l_message_str := NULL;
                          l_error_flag := TRUE;
                        END IF;
                        -- validation for the add date
                        IF l_get_persons.item_add_date > TRUNC(SYSDATE) THEN
                                fnd_message.set_name('IGF','IGF_AP_TODO_DATE_GR_SYSDT');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;
                        --validation for the item status
                        l_get_meaning      := igf_ap_gen.get_lookup_meaning('IGF_TD_ITEM_STATUS',l_get_persons.item_status_code);
                        IF l_get_meaning IS NULL THEN
                                fnd_message.set_name('IGF','IGF_AP_TODO_INVALID_STAT');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;
                        --VALIDATION FOR THE STATUS DATE
                        IF l_get_persons.item_status_date IS NULL THEN
                                l_get_persons.item_status_date := TRUNC(SYSDATE);
                        ELSIF l_get_persons.item_status_date < l_get_persons.item_add_date OR  l_get_persons.item_status_date > TRUNC(SYSDATE) THEN
                                fnd_message.set_name('IGF','IGF_AP_STATUS_DATE');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;
                         l_debug_str := l_debug_str || ' Status Date passed';
                        --VALIDATION FOR THE CORRESPONDENCE DATE...
                        IF l_get_persons.corsp_date IS NOT NULL AND (l_get_persons.corsp_date < l_get_persons.item_add_date OR  l_get_persons.corsp_date > TRUNC(SYSDATE)) THEN
                                fnd_message.set_name('IGF','IGF_AP_CRSP_INVALID_DT');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;
                        --VALIDATION FOR THE CORRESPONDENCE COUNT
                        --FIRST NEGATIVE CORR COUNT IS CHECKED
                        IF NVL(l_get_persons.corsp_count_num,0) < 0 THEN
                                fnd_message.set_name('IGF','IGF_AP_TD_CORR_COUNT_NEG');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;
                        IF  l_get_persons.corsp_count_num IS NOT NULL AND l_get_persons.corsp_date IS NULL THEN
                                fnd_message.set_name('IGF','IGF_AP_TD_CORR_DATE_REQ');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;
                        IF  NVL(l_get_persons.corsp_count_num,0) = 0 AND l_get_persons.corsp_date IS NOT NULL THEN
                                fnd_message.set_name('IGF','IGF_AP_CRSP_COUNT');
                                l_message_str := l_proc_item_str ||' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;
                        --VALIDATION FOR THE INACTIVE FLAG
                        IF NVL(l_get_persons.inactive_flag,'X') NOT IN ('Y','N') THEN
                                fnd_message.set_name('IGF','IGF_AP_TD_FLAG_INCORR');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number,l_error,l_message_str);
                                l_message_str := NULL;
                                l_error_flag := TRUE;
                        END IF;

                        -- museshad (FA 140)
                        -- VALIDATION FOR PREFERRED LENDER
                        l_item_system_todo_type_code := NULL;
                        OPEN  c_item_system_todo_type_code(
                                                            cp_item_code    =>  l_get_persons.item_code,
                                                            cp_cal_type     =>  l_cal_type,
                                                            cp_seq_number   =>  l_seq_number
                                                           );
                        FETCH c_item_system_todo_type_code INTO l_item_system_todo_type_code;

                        IF (c_item_system_todo_type_code%FOUND) THEN

                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_ap_lg_td_imp.main.debug', 'l_item_system_todo_type_code: '||l_item_system_todo_type_code);
                            fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_ap_lg_td_imp.main.debug', 'l_get_persons.item_status_code: '||l_get_persons.item_status_code);
                          END IF;

                          IF l_item_system_todo_type_code = 'PREFLEND' THEN

                            IF l_get_persons.item_status_code = 'COM' THEN

                              IF (l_get_persons.relationship_cd IS NULL) THEN
                                -- Error
                                fnd_message.set_name('IGF', 'IGF_AP_TD_PREFL_INCOM');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number, l_error, l_message_str);
                                l_message_str :=  NULL;
                                l_error_flag  :=  TRUE;
                              ELSE
                                -- Check if the relationship is valid
                                OPEN  c_chk_lender_rel (cp_rel_cd => l_get_persons.relationship_cd);
                                FETCH c_chk_lender_rel INTO l_chk_lender_rel_rec;

                                IF (c_chk_lender_rel%NOTFOUND) THEN
                                  -- Error
                                  fnd_message.set_name('IGF', 'IGF_AP_TD_PREFL_NTFND');
                                  fnd_message.set_token('RELCD', l_get_persons.relationship_cd);
                                  l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                  add_log_table(l_get_persons.person_number, l_error, l_message_str);
                                  l_message_str :=  NULL;
                                  l_error_flag  :=  TRUE;
                                END IF;
                                CLOSE c_chk_lender_rel;
                              END IF;

                            ELSE
                              -- When the status code is not 'COM', then the Relationship code
                              -- must be NULL
                              IF (l_get_persons.relationship_cd IS NOT NULL) THEN
                                -- Error
                                fnd_message.set_name('IGF','IGF_AP_TD_PREFL_INCOM');
                                l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                                add_log_table(l_get_persons.person_number, l_error, l_message_str);
                                l_message_str :=  NULL;
                                l_error_flag  :=  TRUE;
                              END IF;
                            END IF;

                          ELSE
                            -- When the System todo type code of that item is not 'PREFLEND'
                            -- then Relationship code must be NULL
                            IF (l_get_persons.relationship_cd IS NOT NULL) THEN
                              -- Error
                              fnd_message.set_name('IGF','IGF_AP_TD_PREFL_INCOM');
                              l_message_str := l_proc_item_str || ' ' || fnd_message.get;
                              add_log_table(l_get_persons.person_number,l_error,l_message_str);
                              l_message_str :=  NULL;
                              l_error_flag  :=  TRUE;
                            END IF;
                          END IF;   -- End l_item_system_todo_type_code
                        END IF;     -- End c_item_system_todo_type_code%FOUND

                        CLOSE c_item_system_todo_type_code;
                        -- museshad (FA 140)

                         l_debug_str := l_debug_str || ' Inactive flag and correspondence count item passed';
                        IF l_error_flag = FALSE THEN
                                IF l_todo_dup.item_sequence_number IS NULL AND NVL(l_get_persons.import_record_type,'X') <> 'U' THEN
                                  --insert the record
                                  l_todo_number := l_todo_item_valid.todo_number;
                               ELSE
                                  --delete and insert the record again
                                  --obtain the row_id from the item_sequence_number and the base_id from the
                                  l_todo_number := l_todo_dup.item_sequence_number;
                                  l_get_rowid := NULL;
                                  OPEN  c_get_rowid(l_todo_dup.item_sequence_number,g_baseid_exists.base_id);
                                  FETCH c_get_rowid INTO l_get_rowid;
                                  CLOSE c_get_rowid;
                                  igf_ap_td_item_inst_pkg.delete_row(
                                                  x_ROWID                 => l_get_rowid.ROW_ID
                                                  );
                                 END IF;
                                 -- museshad FA 140
                                 -- Insert Pref lender details
                                 IF l_item_system_todo_type_code = 'PREFLEND' AND l_get_persons.relationship_cd IS NOT NULL THEN
                                  process_pref_lender(g_baseid_exists.base_id, l_get_persons.relationship_cd, l_clprl_id);
                                 END IF;
                                 -- museshad FA 140
                                igf_ap_td_item_inst_pkg.insert_row(
                                       x_MODE                     => 'R',
                                       x_BASE_ID                  => g_baseid_exists.base_id,
                                       x_ROWID                    => lv_row_id,
                                       x_ITEM_SEQUENCE_NUMBER     => l_todo_number,
                                       x_STATUS                   => l_get_persons.item_status_code,
                                       x_STATUS_DATE              => l_get_persons.item_status_date,
                                       x_ADD_DATE                 => l_get_persons.item_add_date,
                                       x_CORSP_DATE               => l_get_persons.corsp_date,
                                       x_CORSP_COUNT              => l_get_persons.corsp_count_num,
                                       x_INACTIVE_FLAG            => l_get_persons.inactive_flag,
                                       x_FREQ_ATTEMPT             => l_get_persons.freq_attempt_num,
                                       x_MAX_ATTEMPT              => l_get_persons.max_attempt_num,
                                       x_REQUIRED_FOR_APPLICATION => l_get_persons.reqd_for_application_flag,
                                       x_LEGACY_RECORD_FLAG       => 'Y',
                                       x_clprl_id                 => l_clprl_id
                                     );
                                 l_debug_str := l_debug_str || ' Record Insertion passed';
                                l_success_record_cnt := l_success_record_cnt + 1;
                                l_todo_flag := TRUE;
                                l_todo_number := NULL;
                                IF p_del_ind = 'Y' THEN
                                  DELETE FROM igf_ap_li_todo_ints
                                  WHERE ROWID = l_get_persons.ROW_ID;
                                ELSE
                                  --update the legacy interface table column import_status to 'I'
                                  UPDATE igf_ap_li_todo_ints
                                  SET import_status_type = 'I'
                                  WHERE ROWID = l_get_persons.ROW_ID;
                                END IF;
                        END IF;
                END IF; -- for the valid todo item
        ELSE
            l_error_record_cnt := l_error_record_cnt + 1;
        END IF; -- for the person skip flag

        IF l_error_flag = TRUE THEN
          l_error_flag := FALSE;
          l_error_record_cnt := l_error_record_cnt + 1;
          --update the legacy interface table column import_status to 'E'
          UPDATE igf_ap_li_todo_ints
          SET import_status_type = 'E'
          WHERE ROWID = l_get_persons.ROW_ID;
        END IF;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_td_imp.main.debug',l_debug_str);
        END IF;
        l_proc_item_str := NULL;
        l_get_meaning := NULL;
        l_debug_str := NULL;
      EXCEPTION
       WHEN others THEN
         l_todo_flag := FALSE;
         l_error_flag := FALSE;
         l_proc_item_str := NULL;
         l_get_meaning := NULL;
         l_debug_str := NULL;
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_AP_LG_TD_IMP.MAIN');
         add_log_table(l_get_persons.person_number,l_error,fnd_message.get);
         ROLLBACK TO sp1;
      END;
      COMMIT;

    END LOOP;
    IF l_person_skip_flag = FALSE AND l_todo_flag = TRUE THEN
      update_fabase_process(l_old_person_number);
    END IF;
    CLOSE c_get_persons;

    IF l_success_record_cnt = 0 AND l_error_record_cnt = 0 THEN
       fnd_message.set_name('IGS','IGS_FI_NO_RECORD_AVAILABLE');
       add_log_table(NULL,l_error,fnd_message.get);
    END IF;

    -- CALL THE PRINT LOG PROCESS
    print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind);

    l_total_record_cnt := l_success_record_cnt + l_error_record_cnt;
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' ' || l_total_record_cnt);
    fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_success_record_cnt);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_error_record_cnt);

 EXCEPTION
        WHEN others THEN
          --CALL TO THE COMMON LOGGING FRAMEWORK FOR DEBUG MESSAGES
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_td_imp.main.exception','Exception: '||SQLERRM);
        END IF;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_TD_IMP.MAIN');
        errbuf  := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;


  END main;

  PROCEDURE update_fabase_process(p_person_number IN VARCHAR2)
  IS
    /*
    ||  Created By  : museshad
    ||  Created On  : 28-Jul-2005
    ||  Purpose     : Build FA 140
    ||                Implements the new logic for deriving the FA Base record
    ||                application status
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    -- Get person_id
    CURSOR c_person_id(cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
      SELECT  person_id
      FROM    igf_ap_fa_base_rec_all
      WHERE   base_id = cp_base_id;

    CURSOR cur_todo(
                      cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                      cp_person_id igf_ap_fa_base_rec_all.person_id%TYPE
                   )
    IS
      SELECT  1
      FROM    igf_ap_td_item_inst_all tdinst,
              igf_ap_td_item_mst_all tdmst
      WHERE   tdinst.base_id = cp_base_id
         AND  tdinst.status IN ('INC','REQ','REC')
         AND  tdinst.required_for_application = 'Y'
         AND  NVL(tdinst.inactive_flag,'N') <> 'Y'
         AND  tdinst.item_sequence_number = tdmst.todo_number
         AND  tdmst.career_item = 'N'
         AND  ROWNUM < 2
      UNION
      SELECT  1
      FROM    igf_ap_td_item_inst_all tdinst,
              igf_ap_td_item_mst_all tdmst,
              igf_ap_fa_base_rec_all fa
      WHERE   tdinst.base_id = fa.base_id
         AND  tdinst.status IN ('INC','REQ','REC')
         AND  tdinst.required_for_application = 'Y'
         AND  NVL(tdinst.inactive_flag,'N') <> 'Y'
         AND  tdinst.item_sequence_number = tdmst.todo_number
         AND  tdmst.career_item = 'Y'
         AND  fa.person_id = cp_person_id
         AND  ROWNUM < 2;

    CURSOR cur_ver_status (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
      SELECT  NVL(fa_process_status,'RECEIVED') fa_process_status
      FROM    igf_ap_fa_base_rec
      WHERE   base_id = cp_base_id;

    ln_count_open_items  NUMBER;
    l_person_id          hz_parties.party_id%TYPE;
    lv_fa_process_status igf_ap_fa_base_rec_all.fa_process_status%TYPE;
    ln_auto_na_complete  VARCHAR2(80);

  BEGIN

    -- Get Person Id
    OPEN c_person_id(g_baseid_exists.base_id);
    FETCH c_person_id INTO l_person_id;
    CLOSE c_person_id;

    fnd_profile.get('IGF_AP_MANUAL_REVIEW_APPL', ln_auto_na_complete);
    ln_auto_na_complete := NVL(ln_auto_na_complete, 'N');

    OPEN cur_ver_status (g_baseid_exists.base_id);
    FETCH cur_ver_status INTO lv_fa_process_status;
    CLOSE cur_ver_status;

    OPEN cur_todo (g_baseid_exists.base_id, l_person_id);
    FETCH cur_todo INTO ln_count_open_items;
    IF cur_todo%NOTFOUND THEN
      ln_count_open_items := 0;
    ELSE
      ln_count_open_items := 1;
    END IF;
    CLOSE cur_todo;

    -- Update FA Base record with the right Application Status
    IF lv_fa_process_status = 'RECEIVED' AND  ln_count_open_items = 0 THEN
      IF ln_auto_na_complete = 'Y' THEN
        update_fabase_rec('MANUAL_REVIEW');
        fnd_message.set_name('IGF','IGF_AP_APP_STAT_RVW');
        add_log_table(p_person_number,' ',fnd_message.get);
      ELSE
        update_fabase_rec('COMPLETE');
        fnd_message.set_name('IGF','IGF_AP_APP_STAT_COMPLETE');
        add_log_table(p_person_number,' ',fnd_message.get);
      END IF;
    ELSIF ln_count_open_items > 0 THEN
      update_fabase_rec('RECEIVED');
      fnd_message.set_name('IGF', 'IGF_AP_APP_STAT_REC');
      add_log_table(p_person_number,' ',fnd_message.get);
    END IF;
  END update_fabase_process;

  PROCEDURE update_fabase_rec(
                              p_fa_process_status     IN VARCHAR2
                             ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process updates the FA Base Record Application Processing Status
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rasahoo        17-NOV-2003   FA 128 - ISIR update 2004-05
    ||                               added new parameter award_fmly_contribution_type to
    ||                               igf_ap_fa_base_rec_pkg.update_row
    ||  ugummall      25-SEP-2003     FA 126 - Multiple FA Offices
    ||                                added new parameter assoc_org_num to
    ||                                igf_ap_fa_base_rec_pkg.update_row call
    */

  BEGIN
      igf_ap_fa_base_rec_pkg.update_row(
                                  x_Mode                                   => 'R' ,
                                  x_rowid                                  => g_baseid_exists.row_id ,
                                  x_base_id                                => g_baseid_exists.base_id ,
                                  x_ci_cal_type                            => g_baseid_exists.ci_cal_type ,
                                  x_person_id                              => g_baseid_exists.person_id ,
                                  x_ci_sequence_number                     => g_baseid_exists.ci_sequence_number ,
                                  x_org_id                                 => g_baseid_exists.org_id ,
                                  x_coa_pending                            => g_baseid_exists.coa_pending ,
                                  x_verification_process_run               => g_baseid_exists.verification_process_run ,
                                  x_inst_verif_status_date                 => g_baseid_exists.inst_verif_status_date ,
                                  x_manual_verif_flag                      => g_baseid_exists.manual_verif_flag ,
                                  x_fed_verif_status                       => g_baseid_exists.fed_verif_status ,
                                  x_fed_verif_status_date                  => g_baseid_exists.fed_verif_status_date ,
                                  x_inst_verif_status                      => g_baseid_exists.inst_verif_status ,
                                  x_nslds_eligible                         => g_baseid_exists.nslds_eligible ,
                                  x_ede_correction_batch_id                => g_baseid_exists.ede_correction_batch_id ,
                                  x_fa_process_status_date                 => TRUNC(SYSDATE) ,
                                  x_isir_corr_status                       => g_baseid_exists.isir_corr_status ,
                                  x_isir_corr_status_date                  => g_baseid_exists.isir_corr_status_date ,
                                  x_isir_status                            => g_baseid_exists.isir_status ,
                                  x_isir_status_date                       => g_baseid_exists.isir_status_date ,
                                  x_coa_code_f                             => g_baseid_exists.coa_code_f ,
                                  x_coa_code_i                             => g_baseid_exists.coa_code_i ,
                                  x_coa_f                                  => g_baseid_exists.coa_f ,
                                  x_coa_i                                  => g_baseid_exists.coa_i ,
                                  x_disbursement_hold                      => g_baseid_exists.disbursement_hold ,
                                  x_fa_process_status                      => p_fa_process_status ,
                                  x_notification_status                    => g_baseid_exists.notification_status ,
                                  x_notification_status_date               => g_baseid_exists.notification_status_date ,
                                  x_packaging_status                       => g_baseid_exists.packaging_status ,
                                  x_packaging_status_date                  => g_baseid_exists.packaging_status_date ,
                                  x_total_package_accepted                 => g_baseid_exists.total_package_accepted ,
                                  x_total_package_offered                  => g_baseid_exists.total_package_offered ,
                                  x_admstruct_id                           => g_baseid_exists.admstruct_id ,
                                  x_admsegment_1                           => g_baseid_exists.admsegment_1 ,
                                  x_admsegment_2                           => g_baseid_exists.admsegment_2 ,
                                  x_admsegment_3                           => g_baseid_exists.admsegment_3 ,
                                  x_admsegment_4                           => g_baseid_exists.admsegment_4 ,
                                  x_admsegment_5                           => g_baseid_exists.admsegment_5 ,
                                  x_admsegment_6                           => g_baseid_exists.admsegment_6 ,
                                  x_admsegment_7                           => g_baseid_exists.admsegment_7 ,
                                  x_admsegment_8                           => g_baseid_exists.admsegment_8 ,
                                  x_admsegment_9                           => g_baseid_exists.admsegment_9 ,
                                  x_admsegment_10                          => g_baseid_exists.admsegment_10 ,
                                  x_admsegment_11                          => g_baseid_exists.admsegment_11 ,
                                  x_admsegment_12                          => g_baseid_exists.admsegment_12 ,
                                  x_admsegment_13                          => g_baseid_exists.admsegment_13 ,
                                  x_admsegment_14                          => g_baseid_exists.admsegment_14 ,
                                  x_admsegment_15                          => g_baseid_exists.admsegment_15 ,
                                  x_admsegment_16                          => g_baseid_exists.admsegment_16 ,
                                  x_admsegment_17                          => g_baseid_exists.admsegment_17 ,
                                  x_admsegment_18                          => g_baseid_exists.admsegment_18 ,
                                  x_admsegment_19                          => g_baseid_exists.admsegment_19 ,
                                  x_admsegment_20                          => g_baseid_exists.admsegment_20 ,
                                  x_packstruct_id                          => g_baseid_exists.packstruct_id ,
                                  x_packsegment_1                          => g_baseid_exists.packsegment_1 ,
                                  x_packsegment_2                          => g_baseid_exists.packsegment_2 ,
                                  x_packsegment_3                          => g_baseid_exists.packsegment_3 ,
                                  x_packsegment_4                          => g_baseid_exists.packsegment_4 ,
                                  x_packsegment_5                          => g_baseid_exists.packsegment_5 ,
                                  x_packsegment_6                          => g_baseid_exists.packsegment_6 ,
                                  x_packsegment_7                          => g_baseid_exists.packsegment_7 ,
                                  x_packsegment_8                          => g_baseid_exists.packsegment_8 ,
                                  x_packsegment_9                          => g_baseid_exists.packsegment_9 ,
                                  x_packsegment_10                         => g_baseid_exists.packsegment_10 ,
                                  x_packsegment_11                         => g_baseid_exists.packsegment_11 ,
                                  x_packsegment_12                         => g_baseid_exists.packsegment_12 ,
                                  x_packsegment_13                         => g_baseid_exists.packsegment_13 ,
                                  x_packsegment_14                         => g_baseid_exists.packsegment_14 ,
                                  x_packsegment_15                         => g_baseid_exists.packsegment_15 ,
                                  x_packsegment_16                         => g_baseid_exists.packsegment_16 ,
                                  x_packsegment_17                         => g_baseid_exists.packsegment_17 ,
                                  x_packsegment_18                         => g_baseid_exists.packsegment_18 ,
                                  x_packsegment_19                         => g_baseid_exists.packsegment_19 ,
                                  x_packsegment_20                         => g_baseid_exists.packsegment_20 ,
                                  x_miscstruct_id                          => g_baseid_exists.miscstruct_id ,
                                  x_miscsegment_1                          => g_baseid_exists.miscsegment_1 ,
                                  x_miscsegment_2                          => g_baseid_exists.miscsegment_2 ,
                                  x_miscsegment_3                          => g_baseid_exists.miscsegment_3 ,
                                  x_miscsegment_4                          => g_baseid_exists.miscsegment_4 ,
                                  x_miscsegment_5                          => g_baseid_exists.miscsegment_5 ,
                                  x_miscsegment_6                          => g_baseid_exists.miscsegment_6 ,
                                  x_miscsegment_7                          => g_baseid_exists.miscsegment_7 ,
                                  x_miscsegment_8                          => g_baseid_exists.miscsegment_8 ,
                                  x_miscsegment_9                          => g_baseid_exists.miscsegment_9 ,
                                  x_miscsegment_10                         => g_baseid_exists.miscsegment_10 ,
                                  x_miscsegment_11                         => g_baseid_exists.miscsegment_11 ,
                                  x_miscsegment_12                         => g_baseid_exists.miscsegment_12 ,
                                  x_miscsegment_13                         => g_baseid_exists.miscsegment_13 ,
                                  x_miscsegment_14                         => g_baseid_exists.miscsegment_14 ,
                                  x_miscsegment_15                         => g_baseid_exists.miscsegment_15 ,
                                  x_miscsegment_16                         => g_baseid_exists.miscsegment_16 ,
                                  x_miscsegment_17                         => g_baseid_exists.miscsegment_17 ,
                                  x_miscsegment_18                         => g_baseid_exists.miscsegment_18 ,
                                  x_miscsegment_19                         => g_baseid_exists.miscsegment_19 ,
                                  x_miscsegment_20                         => g_baseid_exists.miscsegment_20 ,
                                  x_prof_judgement_flg                     => g_baseid_exists.prof_judgement_flg ,
                                  x_nslds_data_override_flg                => g_baseid_exists.nslds_data_override_flg ,
                                  x_target_group                           => g_baseid_exists.target_group ,
                                  x_coa_fixed                              => g_baseid_exists.coa_fixed ,
                                  x_coa_pell                               => g_baseid_exists.coa_pell ,
                                  x_profile_status                         => g_baseid_exists.profile_status ,
                                  x_profile_status_date                    => g_baseid_exists.profile_status_date ,
                                  x_profile_fc                             => g_baseid_exists.profile_fc ,
                                  x_manual_disb_hold                       => g_baseid_exists.manual_disb_hold ,
                                  x_pell_alt_expense                       => g_baseid_exists.pell_alt_expense,
                                  x_assoc_org_num                          => g_baseid_exists.assoc_org_num,
                                  x_award_fmly_contribution_type           => g_baseid_exists.award_fmly_contribution_type,
                                  x_isir_locked_by                         => g_baseid_exists.isir_locked_by,
				  x_adnl_unsub_loan_elig_flag              => g_baseid_exists.adnl_unsub_loan_elig_flag,
                                  x_lock_awd_flag                          => g_baseid_exists.lock_awd_flag,
                                  x_lock_coa_flag                          => g_baseid_exists.lock_coa_flag
                                  );

  END update_fabase_rec;

  PROCEDURE process_pref_lender(
                                  p_base_id           IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_rel_cd            IN          igf_ap_li_todo_ints.relationship_cd%TYPE,
                                  p_clprl_id          OUT NOCOPY  igf_sl_cl_pref_lenders.clprl_id%TYPE
                               )
  IS

    /*
    ||  Created By :  museshad
    ||  Created On :  28-Jul-2005
    ||  Purpose    :  Inserts Pref. lender details. This proc. gets called
    ||                when a completed preferred lender to do item is
    ||                successfully imported.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Get Person Id
    CURSOR c_get_person_id (cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
      SELECT  person_id
      FROM    igf_ap_fa_base_rec_all
      WHERE   base_id = cp_base_id;

    l_person_id   igf_sl_cl_pref_lenders.person_id%TYPE;

    -- Gets the Prferred lender details if it exists
    CURSOR c_chk_pref_lender (cp_person_id  igf_sl_cl_pref_lenders.person_id%TYPE)
    IS
      SELECT
             ROWID row_id,
             pref_lender.clprl_id,
             pref_lender.relationship_cd,
             pref_lender.start_date,
             pref_lender.end_date,
             pref_lender.person_id
      FROM
             igf_sl_cl_pref_lenders pref_lender
      WHERE
             pref_lender.person_id = cp_person_id
      AND    pref_lender.end_date IS NULL;

    l_chk_pref_lender   c_chk_pref_lender%ROWTYPE;
    l_msg_count         NUMBER          := NULL;
    l_msg_number        NUMBER          := NULL;
    l_return_status     VARCHAR2(50)    := NULL;
    l_row_id           VARCHAR2(80)    := NULL;

  BEGIN

    -- Get Person Id
    OPEN  c_get_person_id(p_base_id);
    FETCH c_get_person_id INTO l_person_id;
    IF (c_get_person_id%NOTFOUND) THEN
      p_clprl_id := NULL;
      CLOSE c_get_person_id;
      RETURN;
    END IF;
    CLOSE c_get_person_id;

    -- Get Pref lender details
    OPEN  c_chk_pref_lender(l_person_id);
    FETCH c_chk_pref_lender INTO l_chk_pref_lender;
    CLOSE c_chk_pref_lender;

    IF l_chk_pref_lender.start_date IS NULL THEN
      -- No Active Pref lender exists. So insert lender
      igf_sl_cl_pref_lenders_pkg.insert_row (
                                              x_mode                  =>      'R',
                                              x_rowid                 =>      l_row_id,
                                              x_clprl_id              =>      p_clprl_id,
                                              x_msg_count             =>      l_msg_count,
                                              x_msg_data              =>      l_msg_number,
                                              x_return_status         =>      l_return_status,
                                              x_person_id             =>      l_person_id,
                                              x_start_date            =>      TRUNC(SYSDATE),
                                              x_relationship_cd       =>      p_rel_cd,
                                              x_end_date              =>      NULL
                                            );
    ELSE
      -- Active lender exists
      IF l_chk_pref_lender.relationship_cd <> p_rel_cd THEN
        -- Existing active Pref lender is different from one being imported.
        -- Previous relationship record has to be end dated and
        -- a new record has to be added
        igf_sl_cl_pref_lenders_pkg.update_row(
                                                x_mode                    =>    'R',
                                                x_rowid                   =>    l_chk_pref_lender.row_id,
                                                x_clprl_id                =>    l_chk_pref_lender.clprl_id,
                                                x_msg_count               =>    l_msg_count,
                                                x_msg_data                =>    l_msg_number,
                                                x_return_status           =>    l_return_status,
                                                x_person_id               =>    l_chk_pref_lender.person_id,
                                                x_start_date              =>    l_chk_pref_lender.start_date,
                                                x_relationship_cd         =>    l_chk_pref_lender.relationship_cd,
                                                x_end_date                =>    TRUNC(SYSDATE - 1)
                                           );
        igf_sl_cl_pref_lenders_pkg.insert_row (
                                                x_mode                 =>     'R',
                                                x_rowid                =>     l_row_id,
                                                x_clprl_id             =>     p_clprl_id,
                                                x_msg_count            =>     l_msg_count,
                                                x_msg_data             =>     l_msg_number,
                                                x_return_status        =>     l_return_status,
                                                x_person_id            =>     l_person_id,
                                                x_start_date           =>     TRUNC(SYSDATE),
                                                x_relationship_cd      =>     p_rel_cd,
                                                x_end_date             =>     NULL
                                              );
      ELSE
        -- Existing Pref lender is the same as one being imported.
        -- Just return the existing clprl_id
        p_clprl_id := l_chk_pref_lender.clprl_id;
      END IF;
    END IF;
  END process_pref_lender;

  PROCEDURE add_log_table(
                                  p_person_number     IN VARCHAR2,
                                  p_error             IN VARCHAR2,
                                  p_message_str       IN VARCHAR2
                                 ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process adds a record to the global pl/sql table containing log messages
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  BEGIN

      g_log_tab_index := g_log_tab_index + 1;
      g_log_tab(g_log_tab_index).person_number := p_person_number;
      g_log_tab(g_log_tab_index).message_text := RPAD(p_error,12) || p_message_str;

  END add_log_table;

  PROCEDURE print_log_process(
                              p_alternate_code     IN VARCHAR2,
                              p_batch_id           IN  NUMBER,
                              p_del_ind            IN VARCHAR2
                             ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process gets the records from the pl/sql table and print in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    l_count NUMBER(5) := g_log_tab.COUNT;
    l_old_person igf_ap_li_todo_ints.person_number%TYPE := '*******';

    l_person_number   VARCHAR2(80);
    l_batch_id        VARCHAR2(80);
    l_award_yr        VARCHAR2(80);
    l_del_message     VARCHAR2(200);
    l_batch_desc      VARCHAR2(80);
    l_yes_no          VARCHAR2(10);

    CURSOR c_get_batch_desc(cp_batch_num NUMBER) IS
    SELECT batch_desc
      FROM igf_ap_li_bat_ints
     WHERE batch_num = cp_batch_num;

    l_get_batch_desc c_get_batch_desc%ROWTYPE;

  BEGIN

    l_person_number := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_id      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_yr      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no        := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_del_ind);

    OPEN  c_get_batch_desc(p_batch_id);
    FETCH c_get_batch_desc INTO l_get_batch_desc;
    CLOSE c_get_batch_desc;
    l_batch_desc := l_get_batch_desc.batch_desc ;

    -- HERE THE INPUT PARAMETERS ARE TO BE LOGGED TO THE LOG FILE
    fnd_message.set_name('IGS','IGS_DA_JOB');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,RPAD(l_batch_id,50) || ' : ' || p_batch_id || ' - ' || l_batch_desc);
    fnd_file.put_line(fnd_file.log,RPAD(l_award_yr,50) || ' : ' || p_alternate_code);
    fnd_message.set_name('IGS','IGS_GE_ASK_DEL_REC');
    fnd_file.put_line(fnd_file.log,RPAD(fnd_message.get,50) || ' : ' || l_yes_no);
    fnd_file.put_line(fnd_file.log,'------------------------------------------------------------------------------');

    FOR i IN 1..l_count LOOP
      IF g_log_tab(i).person_number IS NOT NULL THEN
        IF l_old_person <> g_log_tab(i).person_number THEN
          fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------------');
          fnd_file.put_line(fnd_file.log,l_person_number || ' : ' || g_log_tab(i).person_number);
        END IF;
        l_old_person := g_log_tab(i).person_number;
      END IF;
      fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
    END LOOP;

  END print_log_process;

END igf_ap_lg_td_imp;

/
