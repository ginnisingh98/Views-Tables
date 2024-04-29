--------------------------------------------------------
--  DDL for Package Body IGF_AW_LOCK_ASSGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_LOCK_ASSGN_PKG" AS
/* $Header: IGFAW18B.pls 120.3 2006/02/08 23:41:39 ridas noship $ */

------------------------------------------------------------------------------
-- Who        When          What
--------------------------------------------------------------------------------


 -- This procedure is the callable from concurrent manager
 PROCEDURE main(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_run_type                    IN  VARCHAR2,
                p_pid_group                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                p_run_mode                    IN  VARCHAR2,
                p_item_code                   IN  igf_aw_item.item_code%TYPE,
                p_term                        IN  VARCHAR2
               ) IS
  --------------------------------------------------------------------------------
  -- this procedure is called from concurrent manager.
  -- if the parameters passed are not correct then procedure exits
  -- giving reasons for errors.
  -- Created by  : ridas, Oracle India
  -- Date created: 20-OCT-2004

  -- Change History:
  -- Who				When            What
  -- ridas      08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call
  --                            to igf_ap_ss_pkg.get_pid
  -- tsailaja		13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  --------------------------------------------------------------------------------

    param_exception  EXCEPTION;

    -- Variables for the dynamic person id group
    lv_status        VARCHAR2(1);
    lv_sql_stmt      VARCHAR(32767);
    lv_group_type    igs_pe_persid_group_v.group_type%TYPE;

    TYPE CpregrpCurTyp IS REF CURSOR ;
    cur_per_grp CpregrpCurTyp ;

    TYPE CpergrpTyp IS RECORD(
                              person_id     igf_ap_fa_base_rec_all.person_id%TYPE,
                              person_number igs_pe_person_base_v.person_number%TYPE
                             );
    per_grp_rec CpergrpTyp ;


    --Cursor below retrieves all the students belonging to a given AWARD YEAR
    CURSOR c_per_awd_yr(
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                       ) IS
      SELECT fa.base_id
        FROM igf_ap_fa_base_rec_all fa
       WHERE fa.ci_cal_type        =  c_ci_cal_type
         AND fa.ci_sequence_number =  c_ci_sequence_number
       ORDER BY fa.base_id;

    l_per_awd_rec   c_per_awd_yr%ROWTYPE;


    --Cursor below retrieves the group code for the given group id
    CURSOR c_group_code(
                        c_grp_id igs_pe_prsid_grp_mem_all.group_id%TYPE
                       ) IS
      SELECT group_cd
        FROM igs_pe_persid_group_all
       WHERE group_id = c_grp_id;

    l_grp_cd    c_group_code%ROWTYPE;


    --Cursor to fetch person no based on person id
    CURSOR  c_person_no (
                          c_person_id  hz_parties.party_id%TYPE
                        ) IS
      SELECT party_number
        FROM hz_parties
       WHERE party_id = c_person_id;

    l_person_no  c_person_no%ROWTYPE;

    lv_ci_cal_type         igs_ca_inst_all.cal_type%TYPE;
    ln_ci_sequence_number  igs_ca_inst_all.sequence_number%TYPE;
    lv_ld_cal_type         igs_ca_inst_all.cal_type%TYPE;
    ln_ld_sequence_number  igs_ca_inst_all.sequence_number%TYPE;
    ln_base_id             igf_ap_fa_base_rec_all.base_id%TYPE;
    lv_err_msg             fnd_new_messages.message_name%TYPE;
    lv_return_flag         VARCHAR2(1);


  BEGIN
	igf_aw_gen.set_org_id(NULL);
    retcode               := 0;
    errbuf                := NULL;
    lv_ci_cal_type        := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    ln_ci_sequence_number := TO_NUMBER(SUBSTR(p_award_year,11));
    lv_ld_cal_type        := LTRIM(RTRIM(SUBSTR(p_term,1,10)));
    ln_ld_sequence_number := TO_NUMBER(SUBSTR(p_term,11));
    lv_status             := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','p_award_year:'||p_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','p_run_type:'||p_run_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','p_pid_group:'||p_pid_group);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','p_run_mode:'||p_run_mode);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','p_item_code:'||p_item_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','p_term:'||p_term);
    END IF;

    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS'));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'),40) ||': '|| igf_gr_gen.get_alt_code(lv_ci_cal_type,ln_ci_sequence_number));

    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','RUN_TYPE'),40) ||': '||p_run_type );

    OPEN  c_group_code(p_pid_group);
    FETCH c_group_code INTO l_grp_cd;
    CLOSE c_group_code;

    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'),40) ||': '|| l_grp_cd.group_cd);
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),40) ||': '|| igf_gr_gen.get_per_num(p_base_id));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','RUN_MODE'),40) ||': '||igf_aw_gen.lookup_desc('IGF_AW_LOCK_MODE',p_run_mode));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','ITEM_CODE'),40) ||': '|| p_item_code);

    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','TERM'),40) ||': '|| igf_gr_gen.get_alt_code(lv_ld_cal_type,ln_ld_sequence_number));

    fnd_file.new_line(fnd_file.log,2);

    IF (p_award_year IS NULL) OR (p_run_type IS NULL) OR (p_run_mode IS NULL) THEN
      RAISE param_exception;

    ELSIF lv_ci_cal_type IS NULL OR ln_ci_sequence_number IS NULL THEN
      RAISE param_exception;

    ELSIF (p_pid_group IS NOT NULL) AND (p_base_id IS NOT NULL) THEN
      RAISE param_exception;

    --If person selection is for all persons in the Person ID Group and
    --Person ID Group is NULL then log error with exception
    ELSIF p_run_type = 'P' AND p_pid_group IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_P');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    --If person selection is for a single person and
    --Base ID is NULL then log error with exception
    ELSIF p_run_type = 'S' AND p_base_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_S');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    END IF;


    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');

    --COMPUTATION ONLY IF PERSON NUMBER IS PRESENT
    IF p_run_type = 'S' AND (p_pid_group IS NULL) AND (p_base_id IS NOT NULL) THEN

       fnd_file.new_line(fnd_file.log,1);
       fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
       fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(p_base_id));
       fnd_file.put_line(fnd_file.log,fnd_message.get);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','Starting Run_Type=S with base_id:'||p_base_id);
      END IF;

        IF p_run_mode = 'L' THEN
            lv_return_flag := igf_aw_coa_gen.dolock(p_base_id,p_item_code,lv_ld_cal_type,ln_ld_sequence_number);
        ELSIF p_run_mode = 'U' THEN
            lv_return_flag := igf_aw_coa_gen.dounlock(p_base_id,p_item_code,lv_ld_cal_type,ln_ld_sequence_number);
        END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','Run_Type=S done');
      END IF;

    --COMPUTATION FOR AWARD YEAR ONLY
    ELSIF p_run_type = 'Y' AND (p_pid_group IS NULL) AND (p_base_id IS NULL) THEN
      FOR l_per_awd_rec IN c_per_awd_yr(lv_ci_cal_type,ln_ci_sequence_number)
      LOOP
       fnd_file.new_line(fnd_file.log,1);
       fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
       fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(l_per_awd_rec.base_id));
       fnd_file.put_line(fnd_file.log,fnd_message.get);

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','Starting Run_Type=Y with base_id:'||l_per_awd_rec.base_id);
       END IF;

        IF p_run_mode = 'L' THEN
            lv_return_flag := igf_aw_coa_gen.dolock(l_per_awd_rec.base_id,p_item_code,lv_ld_cal_type,ln_ld_sequence_number);
        ELSIF p_run_mode = 'U' THEN
            lv_return_flag := igf_aw_coa_gen.dounlock(l_per_awd_rec.base_id,p_item_code,lv_ld_cal_type,ln_ld_sequence_number);
        END IF;

      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','Run_Type=Y done');
      END IF;

    --COMPUTATION FOR ALL PERSONS IN THE PERSON ID GROUP
    ELSIF (p_run_type = 'P' AND p_pid_group IS NOT NULL) THEN
          --Bug #5021084
          lv_sql_stmt   := igf_ap_ss_pkg.get_pid(p_pid_group,lv_status,lv_group_type);

          --Bug #5021084. Passing Group ID if the group type is STATIC.
          IF lv_group_type = 'STATIC' THEN
            OPEN cur_per_grp FOR
            'SELECT person_id,
                    person_number
               FROM igs_pe_person_base_v
              WHERE person_id IN ('||lv_sql_stmt||') ' USING p_pid_group;
          ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN cur_per_grp FOR
            'SELECT person_id,
                    person_number
               FROM igs_pe_person_base_v
              WHERE person_id IN ('||lv_sql_stmt||')';
          END IF;

          FETCH cur_per_grp INTO per_grp_rec;

          IF (cur_per_grp%NOTFOUND) THEN
            fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          ELSE
            LOOP
              -- check if person has a fa base record
              ln_base_id := NULL;
              lv_err_msg := NULL;

              igf_gr_gen.get_base_id(
                                     lv_ci_cal_type,
                                     ln_ci_sequence_number,
                                     per_grp_rec.person_id,
                                     ln_base_id,
                                     lv_err_msg
                                     );

              IF lv_err_msg = 'NULL' THEN
                    fnd_file.new_line(fnd_file.log,1);
                    fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
                    fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(ln_base_id));
                    fnd_file.put_line(fnd_file.log,fnd_message.get);

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','Starting Run_Type=P with base_id:'||ln_base_id);
                    END IF;

                    IF p_run_mode = 'L' THEN
                      lv_return_flag := igf_aw_coa_gen.dolock(ln_base_id,p_item_code,lv_ld_cal_type,ln_ld_sequence_number);
                    ELSIF p_run_mode = 'U' THEN
                      lv_return_flag := igf_aw_coa_gen.dounlock(ln_base_id,p_item_code,lv_ld_cal_type,ln_ld_sequence_number);
                    END IF;

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_lock_assgn_pkg.main.debug','Run_Type=P done');
                    END IF;

              ELSE
                OPEN  c_person_no(per_grp_rec.person_id);
                FETCH c_person_no INTO l_person_no;
                CLOSE c_person_no;

                fnd_message.set_name('IGF','IGF_AP_NO_BASEREC');
                fnd_message.set_token('STUD',l_person_no.party_number);
                fnd_file.new_line(fnd_file.log,1);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;

              FETCH cur_per_grp INTO per_grp_rec;
              EXIT WHEN cur_per_grp%NOTFOUND;
            END LOOP;
            CLOSE cur_per_grp;

          END IF; -- end of IF (cur_per_grp%NOTFOUND)

    END IF;

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');


    COMMIT;

  EXCEPTION
      WHEN param_exception THEN
        retcode:=2;
        fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN app_exception.record_lock_exception THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN OTHERS THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get || SQLERRM;
  END main;

END igf_aw_lock_assgn_pkg;

/
