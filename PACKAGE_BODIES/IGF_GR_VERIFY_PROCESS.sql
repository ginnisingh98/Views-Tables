--------------------------------------------------------
--  DDL for Package Body IGF_GR_VERIFY_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_VERIFY_PROCESS" AS
/* $Header: IGFGR09B.pls 120.3 2006/02/08 23:48:36 ridas noship $ */

  /***************************************************************
    Created By          : smvk
    Date Created By     : 06-Feb-2003
    Purpose             : To update the Verification status of the person in the person id group p_c_per_grp
                          whose current verification status is p_c_from to p_c_to.

    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
    | svuppala  14-Oct-2004      Bug # 3416936			                 |
    |                            Modified TBH call to addeded field              |
    |                            Eligible for Additional Unsubsidized Loans      |
-- | gvarapra   14-sep-2004         FA138 - ISIR Enhancements                    |
-- |                                Changed arguments in call to                 |
-- |                                IGF_AP_FA_BASE_RECORD_PKG.                   |
  ***************************************************************/

  param_error             EXCEPTION;
  g_n_indent              NUMBER(10)    := 0;
  g_c_indent_space        VARCHAR2(100) := NULL;

--Local PROCEDURES
PROCEDURE get_increment(p_c_msg_string IN VARCHAR) AS
/***************************************************************
    Created By          : smvk
    Date Created By     : 06-Feb-2003
    Purpose             : To increment the indentation dynamically. used for fomatting the log file.
    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
***************************************************************/
BEGIN
  IF g_n_indent = 0 THEN
     g_n_indent := instr(p_c_msg_string,' ');
  ELSE
    FOR i in 1.. g_n_indent LOOP
       g_c_indent_space := g_c_indent_space || ' ';
    END LOOP;
  END IF;
END get_increment;

PROCEDURE get_decrement AS
/***************************************************************
    Created By          : smvk
    Date Created By     : 06-Feb-2003
    Purpose             : To decrement the indentation dynamically. used for fomatting the log file.
    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
***************************************************************/
BEGIN
  IF g_n_indent > 0 THEN
       g_c_indent_space := substr(g_c_indent_space,g_n_indent +1);
  END IF;
END get_decrement;

PROCEDURE print(p_c_msg_string IN VARCHAR2) IS
/***************************************************************
    Created By          : smvk
    Date Created By     : 06-Feb-2003
    Purpose             : Print the string.
    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
***************************************************************/
BEGIN
   fnd_file.put_line(fnd_file.log,g_c_indent_space ||p_c_msg_string);
END print;

PROCEDURE print_increment(p_c_msg_string IN VARCHAR2) IS
/***************************************************************
    Created By          : smvk
    Date Created By     : 06-Feb-2003
    Purpose             : Print the string with proper indentation.
    Known Limitations,Enhancements or Remarks
    Change History      :
    Who                 When            What
***************************************************************/
BEGIN
  get_increment(p_c_msg_string);
  print(p_c_msg_string);
END print_increment;


--
-- MAIN PROCEDURE
--

  PROCEDURE main(
    errbuf               OUT NOCOPY             VARCHAR2,
    retcode              OUT NOCOPY             NUMBER,
    p_c_awd_yr           IN           VARCHAR2,
    p_n_per_grp_id       IN           NUMBER,
    p_c_from             IN           VARCHAR2,
    p_c_to               IN           VARCHAR2
  ) AS
  /***************************************************************
    Created By          : smvk
    Date Created By     : 06-Feb-2003
    Purpose             : To update the Verification status of the person in the person id group p_c_per_grp
                          whose current verification status is p_c_from to p_c_to.

    Known Limitations,Enhancements or Remarks
    Change History      :
    Who       When          What
    ridas     08-FEB-2006   Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
	  tsailaja  13/Jan/2006   Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    rasahoo   17-NOV-2003   FA 128 - ISIR update 2004-05
                            added new parameter award_fmly_contribution_type to
                            igf_ap_fa_base_rec_pkg.update_row
    ugummall  25-SEP-2003   FA 126 - Multiple FA Offices
                            added new parameter assoc_org_num to
                            igf_ap_fa_base_rec_pkg.update_row call
    nsidana   4/28/2003     Bug 2806057 : Log file should be more appropriate.

  ***************************************************************/

  CURSOR     c_group_code(cp_n_grp_id igs_pe_prsid_grp_mem_all.group_id%TYPE) IS
    SELECT   group_cd
      FROM   igs_pe_all_persid_group_v
      WHERE  group_id = cp_n_grp_id;

  CURSOR c_fa_base_dtls ( cp_c_ci_cal_type IN  igf_ap_fa_base_rec.ci_cal_type%TYPE,
                          cp_n_ci_seq_num  IN  igf_ap_fa_base_rec.ci_sequence_number%TYPE,
                                            cp_n_person_id   IN  igf_ap_fa_base_rec.person_id%TYPE ) IS
    SELECT *
    FROM   igf_ap_fa_base_rec
    WHERE  ci_cal_type         = cp_c_ci_cal_type
    AND    ci_sequence_number  = cp_n_ci_seq_num
    AND    person_id           = cp_n_person_id ;

  TYPE c_pregrpcurtyp IS REF CURSOR ;
  cur_per_grp c_pregrpcurtyp;
  TYPE cpergrptyp IS RECORD (  person_id     igf_ap_fa_base_rec_all.person_id%TYPE,
                               person_number igs_pe_person_base_v.person_number%TYPE);
  per_grp_rec cpergrptyp ;

  l_c_ci_cal_type         igf_ap_fa_base_rec.ci_cal_type%TYPE;
  l_n_ci_sequence_number  igf_ap_fa_base_rec.ci_sequence_number%TYPE;
  l_c_status              VARCHAR2(1)    := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */
  l_c_sql_stmt            VARCHAR2(32767);
  rec_grp_cd              c_group_code%ROWTYPE;
  rec_fa_base_dtls        c_fa_base_dtls%ROWTYPE;
  l_c_msg                 VARCHAR2(2000);
  lv_group_type           igs_pe_persid_group_v.group_type%TYPE;

BEGIN
	 igf_aw_gen.set_org_id(NULL);
     retcode := 0;
     l_c_ci_cal_type            :=   LTRIM(RTRIM(SUBSTR(p_c_awd_yr,1,10)));
     l_n_ci_sequence_number     :=   TO_NUMBER(SUBSTR(p_c_awd_yr,11));

     IF l_c_ci_cal_type IS  NULL OR l_n_ci_sequence_number IS NULL  THEN
              RAISE param_error;
     END IF;

     fnd_message.set_name('IGF','IGF_AW_PROC_AWD');
     fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code(l_c_ci_cal_type,l_n_ci_sequence_number));
     l_c_msg := fnd_message.get;
     print_increment(l_c_msg);

     IF p_c_from <> p_c_to THEN
        --Bug #5021084
        l_c_sql_stmt   := igf_ap_ss_pkg.get_pid(p_n_per_grp_id,l_c_status,lv_group_type);

        --Bug #5021084. Passing Group ID if the group type is STATIC.
        IF lv_group_type = 'STATIC' THEN
          OPEN  cur_per_grp
          FOR
          '
           SELECT
             person_id,
             person_number
           FROM
             igs_pe_person_base_v
           WHERE
             person_id IN ('||l_c_sql_stmt||') ' USING p_n_per_grp_id;
        ELSIF lv_group_type = 'DYNAMIC' THEN
          OPEN  cur_per_grp
          FOR
          '
           SELECT
             person_id,
             person_number
           FROM
             igs_pe_person_base_v
           WHERE
             person_id IN ('||l_c_sql_stmt||')
           ';
        END IF;

        FETCH cur_per_grp INTO per_grp_rec;

        IF cur_per_grp%NOTFOUND THEN
           fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
           fnd_file.put_line(fnd_file.log,fnd_message.get);
        ELSE
           OPEN c_group_code(p_n_per_grp_id);
           FETCH c_group_code INTO rec_grp_cd;
              fnd_message.set_name('IGF','IGF_AW_PERSON_ID_GROUP');
              fnd_message.set_token('P_PER_GRP',rec_grp_cd.group_cd);
              l_c_msg := fnd_message.get;
              print_increment(l_c_msg);
           CLOSE c_group_code;
           LOOP
              fnd_message.set_name ('IGF', 'IGF_AW_PROC_STUD');
              fnd_message.set_token('STDNT',per_grp_rec.person_number);
              l_c_msg := fnd_message.get;
        fnd_file.new_line(fnd_file.log,1);
        print_increment(l_c_msg);

              OPEN c_fa_base_dtls(l_c_ci_cal_type,l_n_ci_sequence_number, per_grp_rec.person_id);
                    FETCH c_fa_base_dtls INTO rec_fa_base_dtls;
                    IF c_fa_base_dtls%FOUND THEN
                 IF rec_fa_base_dtls.fed_verif_status IS NULL OR
                                rec_fa_base_dtls.fed_verif_status = p_c_from THEN
                    igf_ap_fa_base_rec_pkg.update_row ( x_rowid                        => rec_fa_base_dtls.row_id                   ,
                                                        x_base_id                      => rec_fa_base_dtls.base_id                  ,
                                                        x_ci_cal_type                  => rec_fa_base_dtls.ci_cal_type              ,
                                                        x_person_id                    => rec_fa_base_dtls.person_id                ,
                                                        x_ci_sequence_number           => rec_fa_base_dtls.ci_sequence_number       ,
                                                        x_org_id                       => rec_fa_base_dtls.org_id                   ,
                                                        x_coa_pending                  => rec_fa_base_dtls.coa_pending              ,
                                                        x_verification_process_run     => rec_fa_base_dtls.verification_process_run ,
                                                        x_inst_verif_status_date       => rec_fa_base_dtls.inst_verif_status_date   ,
                                                        x_manual_verif_flag            => rec_fa_base_dtls.manual_verif_flag        ,
                                                        x_fed_verif_status             => p_c_to                                    ,
                                                        x_fed_verif_status_date        => TRUNC(SYSDATE)                            ,  -- updating the date to system date.
                                                        x_inst_verif_status            => rec_fa_base_dtls.inst_verif_status        ,
                                                        x_nslds_eligible               => rec_fa_base_dtls.nslds_eligible           ,
                                                        x_ede_correction_batch_id      => rec_fa_base_dtls.ede_correction_batch_id  ,
                                                        x_fa_process_status_date       => rec_fa_base_dtls.fa_process_status_date   ,
                                                        x_isir_corr_status             => rec_fa_base_dtls.isir_corr_status         ,
                                                        x_isir_corr_status_date        => rec_fa_base_dtls.isir_corr_status_date    ,
                                                        x_isir_status                  => rec_fa_base_dtls.isir_status              ,
                                                        x_isir_status_date             => rec_fa_base_dtls.isir_status_date         ,
                                                        x_coa_code_f                   => rec_fa_base_dtls.coa_code_f               ,
                                                        x_coa_code_i                   => rec_fa_base_dtls.coa_code_i               ,
                                                        x_coa_f                        => rec_fa_base_dtls.coa_f                    ,
                                                        x_coa_i                        => rec_fa_base_dtls.coa_i                    ,
                                                        x_disbursement_hold            => rec_fa_base_dtls.disbursement_hold        ,
                                                        x_fa_process_status            => rec_fa_base_dtls.fa_process_status        ,
                                                        x_notification_status          => rec_fa_base_dtls.notification_status      ,
                                                        x_notification_status_date     => rec_fa_base_dtls.notification_status_date ,
                                                        x_packaging_hold               => rec_fa_base_dtls.packaging_hold           ,
                                                        x_packaging_status             => rec_fa_base_dtls.packaging_status         ,
                                                        x_packaging_status_date        => rec_fa_base_dtls.packaging_status_date    ,
                                                        x_total_package_accepted       => rec_fa_base_dtls.total_package_accepted   ,
                                                        x_total_package_offered        => rec_fa_base_dtls.total_package_offered    ,
                                                        x_admstruct_id                 => rec_fa_base_dtls.admstruct_id             ,
                                                        x_admsegment_1                 => rec_fa_base_dtls.admsegment_1             ,
                                                        x_admsegment_2                 => rec_fa_base_dtls.admsegment_2             ,
                                                        x_admsegment_3                 => rec_fa_base_dtls.admsegment_3             ,
                                                        x_admsegment_4                 => rec_fa_base_dtls.admsegment_4             ,
                                                        x_admsegment_5                 => rec_fa_base_dtls.admsegment_5             ,
                                                        x_admsegment_6                 => rec_fa_base_dtls.admsegment_6             ,
                                                        x_admsegment_7                 => rec_fa_base_dtls.admsegment_7             ,
                                                        x_admsegment_8                 => rec_fa_base_dtls.admsegment_8             ,
                                                        x_admsegment_9                 => rec_fa_base_dtls.admsegment_9             ,
                                                        x_admsegment_10                => rec_fa_base_dtls.admsegment_10            ,
                                                        x_admsegment_11                => rec_fa_base_dtls.admsegment_11            ,
                                                        x_admsegment_12                => rec_fa_base_dtls.admsegment_12            ,
                                                        x_admsegment_13                => rec_fa_base_dtls.admsegment_13            ,
                                                        x_admsegment_14                => rec_fa_base_dtls.admsegment_14            ,
                                                        x_admsegment_15                => rec_fa_base_dtls.admsegment_15            ,
                                                        x_admsegment_16                => rec_fa_base_dtls.admsegment_16            ,
                                                        x_admsegment_17                => rec_fa_base_dtls.admsegment_17            ,
                                                        x_admsegment_18                => rec_fa_base_dtls.admsegment_18            ,
                                                        x_admsegment_19                => rec_fa_base_dtls.admsegment_19            ,
                                                        x_admsegment_20                => rec_fa_base_dtls.admsegment_20            ,
                                                        x_packstruct_id                => rec_fa_base_dtls.packstruct_id            ,
                                                        x_packsegment_1                => rec_fa_base_dtls.packsegment_1            ,
                                                        x_packsegment_2                => rec_fa_base_dtls.packsegment_2            ,
                                                        x_packsegment_3                => rec_fa_base_dtls.packsegment_3            ,
                                                        x_packsegment_4                => rec_fa_base_dtls.packsegment_4            ,
                                                        x_packsegment_5                => rec_fa_base_dtls.packsegment_5            ,
                                                        x_packsegment_6                => rec_fa_base_dtls.packsegment_6            ,
                                                        x_packsegment_7                => rec_fa_base_dtls.packsegment_7            ,
                                                        x_packsegment_8                => rec_fa_base_dtls.packsegment_8            ,
                                                        x_packsegment_9                => rec_fa_base_dtls.packsegment_9            ,
                                                        x_packsegment_10               => rec_fa_base_dtls.packsegment_10           ,
                                                        x_packsegment_11               => rec_fa_base_dtls.packsegment_11           ,
                                                        x_packsegment_12               => rec_fa_base_dtls.packsegment_12           ,
                                                        x_packsegment_13               => rec_fa_base_dtls.packsegment_13           ,
                                                        x_packsegment_14               => rec_fa_base_dtls.packsegment_14           ,
                                                        x_packsegment_15               => rec_fa_base_dtls.packsegment_15           ,
                                                        x_packsegment_16               => rec_fa_base_dtls.packsegment_16           ,
                                                        x_packsegment_17               => rec_fa_base_dtls.packsegment_17           ,
                                                        x_packsegment_18               => rec_fa_base_dtls.packsegment_18           ,
                                                        x_packsegment_19               => rec_fa_base_dtls.packsegment_19           ,
                                                        x_packsegment_20               => rec_fa_base_dtls.packsegment_20           ,
                                                        x_miscstruct_id                => rec_fa_base_dtls.miscstruct_id            ,
                                                        x_miscsegment_1                => rec_fa_base_dtls.miscsegment_1            ,
                                                        x_miscsegment_2                => rec_fa_base_dtls.miscsegment_2            ,
                                                        x_miscsegment_3                => rec_fa_base_dtls.miscsegment_3            ,
                                                        x_miscsegment_4                => rec_fa_base_dtls.miscsegment_4            ,
                                                        x_miscsegment_5                => rec_fa_base_dtls.miscsegment_5            ,
                                                        x_miscsegment_6                => rec_fa_base_dtls.miscsegment_6            ,
                                                        x_miscsegment_7                => rec_fa_base_dtls.miscsegment_7            ,
                                                        x_miscsegment_8                => rec_fa_base_dtls.miscsegment_8            ,
                                                        x_miscsegment_9                => rec_fa_base_dtls.miscsegment_9            ,
                                                        x_miscsegment_10               => rec_fa_base_dtls.miscsegment_10           ,
                                                        x_miscsegment_11               => rec_fa_base_dtls.miscsegment_11           ,
                                                        x_miscsegment_12               => rec_fa_base_dtls.miscsegment_12           ,
                                                        x_miscsegment_13               => rec_fa_base_dtls.miscsegment_13           ,
                                                        x_miscsegment_14               => rec_fa_base_dtls.miscsegment_14           ,
                                                        x_miscsegment_15               => rec_fa_base_dtls.miscsegment_15           ,
                                                        x_miscsegment_16               => rec_fa_base_dtls.miscsegment_16           ,
                                                        x_miscsegment_17               => rec_fa_base_dtls.miscsegment_17           ,
                                                        x_miscsegment_18               => rec_fa_base_dtls.miscsegment_18           ,
                                                        x_miscsegment_19               => rec_fa_base_dtls.miscsegment_19           ,
                                                        x_miscsegment_20               => rec_fa_base_dtls.miscsegment_20           ,
                                                        x_prof_judgement_flg           => rec_fa_base_dtls.prof_judgement_flg       ,
                                                        x_nslds_data_override_flg      => rec_fa_base_dtls.nslds_data_override_flg  ,
                                                        x_target_group                 => rec_fa_base_dtls.target_group             ,
                                                        x_coa_fixed                    => rec_fa_base_dtls.coa_fixed                ,
                                                        x_coa_pell                     => rec_fa_base_dtls.coa_pell                 ,
                                                        x_mode                         => 'R'                                       ,
                                                        x_profile_status               => rec_fa_base_dtls.profile_status           ,
                                                        x_profile_status_date          => rec_fa_base_dtls.profile_status_date      ,
                                                        x_profile_fc                   => rec_fa_base_dtls.profile_fc               ,
                                                        x_tolerance_amount             => rec_fa_base_dtls.tolerance_amount         ,
                                                        x_manual_disb_hold             => rec_fa_base_dtls.manual_disb_hold         ,
                                                        x_pell_alt_expense             => rec_fa_base_dtls.pell_alt_expense         ,
                                                        x_assoc_org_num                => rec_fa_base_dtls.assoc_org_num            ,
                                                        x_award_fmly_contribution_type => rec_fa_base_dtls.award_fmly_contribution_type,
                                                        x_isir_locked_by               => rec_fa_base_dtls.isir_locked_by,
							                                          x_adnl_unsub_loan_elig_flag    => rec_fa_base_dtls.adnl_unsub_loan_elig_flag,
                                                        x_lock_awd_flag                => rec_fa_base_dtls.lock_awd_flag,
                                                        x_lock_coa_flag                => rec_fa_base_dtls.lock_coa_flag

                                                      );
       -- Bug 2806057 : Log file message should be more appropriate.
       -- nsidana 4/28/2003

       -- If the vale of the FED_VERIF_STATUS is NULL in the FA BASE REC, log the message having no FROM token.

       IF (rec_fa_base_dtls.fed_verif_status IS NULL) THEN
            fnd_message.set_name('IGF','IGF_GR_VERI_COM_FROM_BLANK');
                        fnd_message.set_token('PERSON_NUMBER',per_grp_rec.person_number);
                        fnd_message.set_token('P_TO',igf_aw_gen.LOOKUP_DESC('IGF_FED_VERIFY_STATUS',p_c_to));

       ELSIF (rec_fa_base_dtls.fed_verif_status = p_c_from) THEN
               -- Log the message with the two tokens, as being done before.
               fnd_message.set_name('IGF','IGF_GR_VERI_COMPLETE');
                           fnd_message.set_token('PERSON_NUMBER',per_grp_rec.person_number);
                           fnd_message.set_token('P_FROM',igf_aw_gen.LOOKUP_DESC('IGF_FED_VERIFY_STATUS',p_c_from));
                           fnd_message.set_token('P_TO',igf_aw_gen.LOOKUP_DESC('IGF_FED_VERIFY_STATUS',p_c_to));
       END IF;

                    l_c_msg := fnd_message.get;
                    print_increment(l_c_msg);
                 ELSE
                    fnd_message.set_name('IGF','IGF_GR_VERI_NO_UPDT');
                    fnd_message.set_token('P_FROM',igf_aw_gen.LOOKUP_DESC('IGF_FED_VERIFY_STATUS',p_c_from));
                    l_c_msg := fnd_message.get;
                    print_increment(l_c_msg);
                 END IF;
              ELSE
                fnd_message.set_name('IGF','IGF_DB_NO_FA_PER');
                fnd_message.set_token('PER_NUM',per_grp_rec.person_number);
                l_c_msg := fnd_message.get;
                print_increment(l_c_msg);
              END IF;
              CLOSE c_fa_base_dtls;
              FETCH cur_per_grp INTO per_grp_rec;
              EXIT WHEN cur_per_grp%NOTFOUND;
              get_decrement;get_decrement;
           END LOOP;
        END IF;
        CLOSE cur_per_grp;
     ELSE
        RAISE param_error;
     END IF;

   COMMIT;

EXCEPTION

    WHEN param_error THEN
       ROLLBACK;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_AW_PARAM_ERR');
       fnd_file.put_line(fnd_file.log,errbuf);

    WHEN others THEN
       ROLLBACK;
       retcode := 2;
       fnd_file.put_line(fnd_file.log,sqlerrm);
       errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       igs_ge_msg_stack.conc_exception_hndl;

END main;

END igf_gr_verify_process;

/
