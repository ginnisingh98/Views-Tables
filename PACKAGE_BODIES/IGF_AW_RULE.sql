--------------------------------------------------------
--  DDL for Package Body IGF_AW_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_RULE" AS
/* $Header: IGFAW04B.pls 120.1 2006/02/08 23:39:01 ridas noship $ */
--
-- History :
-- ridas       29-Nov-04      Bug # 3021287 Skip the student if award is locked at the student level
--
-- svuppala    14-Oct-04      Bug # 3416936 Modified TBH call to addeded field
--                            Eligible for Additional Unsubsidized Loans
-- ugummall            26-SEP-2003     FA 126 - Multiple FA Offices
--                                     added new parameter assoc_org_num to TBH call
--                                     igf_ap_fa_base_rec_pkg.update_row  w.r.t. FA 126
--
--
-- Bug ID   :2613546
-- adhawan             28-OCT-2002    The Run procedure has been modified with the new parameters
--                                    p_grp_code for  Target Group assignment
--                                    p_pergrp_id for processing of all students belonging to the Person ID Group
--                                    p_base_id has been removed
--                                    The process RUN would be used for Assignment of Target Groups and not Cost of attendace groups
--                                    The process tgroup_rule has been modified to have p_pergrp_id instead of p_base_id and p_grp_code added
--                                    All the processing associated with the Rules has been obsoleted.

-- Bug ID  : 1818617
-- who                 when            what
--
-- masehgal            25-Sep-2002     FA 104 - To Do Enhancements
--                                     Added manual_disb_hold in FA Base update
------------------------------------------------------------------------

-- sjadhav             24-jul-2001     added parameter p_get_recent_info
-- adhawan
-- 2313791             22-apr-2002    Added messages when the Group or the Cost of Attendance is assigned to the Student
-- | gvarapra   14-sep-2004         FA138 - ISIR Enhancements                    |
-- |                                Changed arguments in call to                 |
-- |                                IGF_AP_FA_BASE_RECORD_PKG.                   |
------------------------------------------------------------------------
--


lv_get_recent_info VARCHAR2(10) := 'N';
l_ci_cal_type        igf_aw_target_grp.cal_type%TYPE ;
l_ci_sequence_number igf_aw_target_grp.sequence_number%TYPE ;


--This process would assign the Award Group to the students for an award year or the students belonging to Person ID Group
PROCEDURE run   ( errbuf              OUT NOCOPY VARCHAR2,
                 retcode              OUT NOCOPY NUMBER,
                 l_award_year         IN  VARCHAR2 ,
                 p_grp_code           IN  igf_aw_target_grp.group_cd%TYPE,
                 p_pergrp_id          IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                 p_org_id             IN  NUMBER
                       )

IS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


    --Cursor to find the User Parameter Award Year (which is same as Alternate Code) to display in the Log
   CURSOR c_alternate_code(cp_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                           cp_ci_sequence_NUMBER  igs_ca_inst.sequence_NUMBER%TYPE)   IS
   SELECT  alternate_code
   FROM    igs_ca_inst
   WHERE   cal_type        = cp_ci_cal_type    AND
           sequence_NUMBER = cp_ci_sequence_NUMBER;

   CURSOR c_get_parameters IS
   SELECT meaning, lookup_code FROM igf_lookups_view
   WHERE lookup_type='IGF_GE_PARAMETERS' AND
   lookup_code IN ('AWARD_YEAR','PERSON_ID_GROUP','PARAMETER_PASS');

   --get person group description
   CURSOR get_grp_desc(lp_per_id igs_pe_persid_group_all.group_id%TYPE) IS
      SELECT description
        FROM igs_pe_persid_group_all
       WHERE group_id = lp_per_id;

    lv_desc    igs_pe_persid_group_all.description%TYPE;


   parameter_rec c_get_parameters%ROWTYPE;
   l_award_years    igf_lookups_view.meaning%TYPE;
   l1_person_number igf_lookups_view.meaning%TYPE;
   l_run_types     igf_lookups_view.meaning%TYPE;
   l_para_pass     igf_lookups_view.meaning%TYPE;
   l_alternate_code igs_ca_inst.alternate_code%TYPE;

BEGIN

     igf_aw_gen.set_org_id(p_org_id);

     lv_get_recent_info   := 'N';

     --Get the Award Year
     l_ci_cal_type        := ltrim(rtrim(substr(l_award_year,1,10))) ;
     l_ci_sequence_number := TO_NUMBER(substr(l_award_year,11)) ;

    --Get the Alternate code for the award year
    OPEN        c_alternate_code(l_ci_cal_type,l_ci_sequence_NUMBER);
    FETCH       c_alternate_code INTO  l_alternate_code;
    CLOSE       c_alternate_code;




    --Preparing the variables for the Parameters passed
     OPEN c_get_parameters;
     LOOP
     FETCH c_get_parameters INTO  parameter_rec;
     EXIT WHEN c_get_parameters%NOTFOUND;
       IF parameter_rec.lookup_code ='AWARD_YEAR' THEN
            l_award_years := parameter_rec.meaning;
       ELSIF parameter_rec.lookup_code ='PERSON_ID_GROUP' THEN
            l1_person_number := parameter_rec.meaning;
       ELSIF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
          l_para_pass := parameter_rec.meaning;
       END IF;
      END LOOP;
      CLOSE c_get_parameters;

    --get group description
     OPEN get_grp_desc(p_pergrp_id);
     FETCH get_grp_desc INTO lv_desc;
     CLOSE get_grp_desc;


    /* Print the Parameters Passed */

      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,l_para_pass);-- -----------Parameters Passed--------------
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l_award_years,35)    || '                         :'||l_alternate_code);
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_GRP'),35)    || '                         :'||p_grp_code);
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(l1_person_number,35) || '                         :'||lv_desc);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'');

      FND_MESSAGE.SET_NAME('IGF','IGF_AW_PROC_AWD');
      FND_MESSAGE.SET_TOKEN('AWD_YR',l_alternate_code);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

          tgroup_rule(l_ci_cal_type        ,
                      l_ci_sequence_NUMBER ,
                      p_pergrp_id  ,
                      p_grp_code) ;
END run;

 PROCEDURE tgroup_rule(   p_ci_cal_type         in igf_aw_target_grp.cal_type%TYPE  ,
                          p_ci_sequence_NUMBER  in igf_aw_target_grp.sequence_number%TYPE,
                          p_pergrp_id           in igs_pe_prsid_grp_mem_all.group_id%TYPE,
                          p_grp_code           IN  igf_aw_target_grp.group_cd%TYPE)

 IS
  /*
  ||  Created By : cdcruz
  ||  Created On : 14-NOV-2000
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  ridas           08-FEB-2006     Bug #5021084. Added new parameter 'lv_group_type' in
  ||                                  call to igf_ap_ss_pkg.get_pid
  ||  rasahoo         17-NOV-2003     FA 128 - ISIR update 2004-05
  ||                                  added new parameter award_fmly_contribution_type to
  ||                                  igf_ap_fa_base_rec_pkg.update_row
  ||  ugummall        26-SEP-2003     FA 126 - Multiple FA Offices
  ||                                  added new parameter assoc_org_num to TBH call
  ||                                  igf_ap_fa_base_rec_pkg.update_row  w.r.t. FA 126
  ||
  ||  rasahoo         27-aug-2003     Removed the call to IGF_AP_OSS_PROCESS.GET_OSS_DETAILS
  ||                                  as part of obsoletion of FA base record history
  ||  masehgal        11-Nov-2002     FA 101 - SAP Obsoletion
  ||                                  removed packaging hold
  */
    --Cursor to find the User Parameter Award Year (which is same as Alternate Code) to display in the Log
   CURSOR c_alternate_code(cp_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                           cp_ci_sequence_NUMBER  igs_ca_inst.sequence_NUMBER%TYPE)   IS
   SELECT  alternate_code
   FROM    igs_ca_inst
   WHERE   cal_type        = cp_ci_cal_type    AND
           sequence_NUMBER = cp_ci_sequence_NUMBER;
   l_alternate_code igs_ca_inst.alternate_code%TYPE;

  CURSOR c_year ( x_ci_cal_type          igf_ap_fa_base_rec.ci_cal_type%type ,
                  x_ci_sequence_NUMBER   igf_ap_fa_base_rec.ci_sequence_NUMBER%type )
  IS
  SELECT
   fa.base_id ,
   fa.person_id,
   hz.party_number
  FROM
   igf_ap_fa_base_rec fa,
   hz_parties         hz
  WHERE
   fa.ci_cal_type        = x_ci_cal_type        AND
   fa.ci_sequence_NUMBER = x_ci_sequence_NUMBER AND
   hz.party_id           = fa.person_id;

  l_year c_year%rowtype ;

   CURSOR c_rule_cd(cp_cal_type igf_aw_target_grp.cal_type%TYPE ,
                    cp_sequence_number igf_aw_target_grp.sequence_number%TYPE,
                    cp_group_cd igf_aw_target_grp.group_cd%TYPE)

   IS
   SELECT
   tgrp.group_cd  R_code
   FROM
   igf_aw_target_grp tgrp
   WHERE cal_type =cp_cal_type AND
   sequence_number =cp_sequence_number AND
   group_cd = cp_group_cd;

  l_rule_cd c_rule_cd%rowtype ;

   CURSOR c_fabase ( x_base_id igf_ap_fa_base_rec.base_id%type )
   IS
   SELECT
     fabase.*
   FROM
     igf_ap_fa_base_rec fabase
   WHERE
     fabase.base_id = x_base_id ;

--Cursor below retrieves all the person belonging to a person id group

 /* Variables for the dynamic person id group */
    lv_status       VARCHAR2(1) := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */
    lv_group_type   igs_pe_persid_group_v.group_type%TYPE;
    lv_sql_stmt     VARCHAR(32767) := igf_ap_ss_pkg.get_pid(p_pergrp_id,lv_status,lv_group_type);


   TYPE CstudCurTyp IS REF CURSOR ;
     c_stud CstudCurTyp ;
   TYPE CstudTyp IS RECORD (  party_id hz_parties.party_id%TYPE,  party_number hz_parties.party_number%TYPE);
     l_stud CstudTyp ;


     CURSOR c_check_group(p_base_id igf_ap_fa_base_rec.base_id%type ) IS
     SELECT target_group  from igf_ap_fa_base_rec
     WHERE base_id=p_base_id;
     l_check_group         c_check_group%ROWTYPE;


    l_fabase c_fabase%rowtype ;

    l_stud_proc   BOOLEAN ;
    l_curr_base_id igf_ap_fa_base_rec.base_id%type ;

    ln_person_id            igs_ad_ps_appl_inst.person_id%TYPE;
    l_person_NUMBER         igf_ap_fa_con_v.person_NUMBER%TYPE;

  -- Get
  CURSOR get_grp_desc(lp_per_id igs_pe_persid_group_all.group_id%TYPE) IS
    SELECT description
      FROM igs_pe_persid_group_all
     WHERE group_id = lp_per_id;
    lv_desc    igs_pe_persid_group_all.description%TYPE;

  -- Get
  CURSOR c_get_base_id(lp_ci_cal_type igf_ap_fa_base_rec.ci_cal_type%TYPE, lp_ci_seq_num igf_ap_fa_base_rec.ci_sequence_number%TYPE, lp_person_id igf_ap_fa_base_rec.person_id%TYPE) IS
    SELECT fa.base_id
      FROM igf_ap_fa_base_rec fa
     WHERE fa.ci_cal_type        =  lp_ci_cal_type
       AND fa.ci_sequence_number =  lp_ci_seq_num
       AND fa.person_id          =  lp_person_id;
  l_get_base_id c_get_base_id%ROWTYPE;

  ln_counter    NUMBER := 0;

 BEGIN
  IF p_pergrp_id is NULL THEN
    l_stud_proc := FALSE ;
  ELSE
    l_stud_proc := TRUE ;
    OPEN get_grp_desc(p_pergrp_id);
    FETCH get_grp_desc into lv_desc;
    FND_MESSAGE.SET_NAME('IGF','IGF_AW_PERSON_ID_GROUP');
    FND_MESSAGE.SET_TOKEN('P_PER_GRP',lv_desc);
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'');
    CLOSE get_grp_desc;
  END IF;


  IF l_stud_proc THEN
     --Bug #5021084. Passing Group ID if the group type is STATIC.
     IF lv_group_type = 'STATIC' THEN
       OPEN  c_stud FOR 'SELECT hz.party_id , hz.party_number FROM
                                     hz_parties hz
                                     WHERE
                                     hz.party_id          in ( '||lv_sql_stmt||' ) ' USING p_pergrp_id;
     ELSIF lv_group_type = 'DYNAMIC' THEN
       OPEN  c_stud FOR 'SELECT hz.party_id , hz.party_number FROM
                                     hz_parties hz
                                     WHERE
                                     hz.party_id          in ( '||lv_sql_stmt||' ) ';
     END IF;

  ELSE
     OPEN c_year ( l_ci_cal_type,
                   l_ci_sequence_NUMBER ) ;
  END IF;

  LOOP

    IF l_stud_proc THEN

        FETCH c_stud INTO l_stud ;
                IF c_stud%NOTFOUND AND c_stud%ROWCOUNT = 0  THEN
                   FND_MESSAGE.SET_NAME('IGF','IGF_DB_NO_PER_GRP');
                   FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get());
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'');
                 CLOSE   c_stud;
                   RETURN ;
                ELSE
                   EXIT WHEN c_stud%notfound ;
                END IF;

        OPEN c_get_base_id(p_ci_cal_type, p_ci_sequence_number, l_stud.party_id);
        FETCH c_get_base_id INTO l_get_base_id;
                IF c_get_base_id%NOTFOUND THEN

                   --Get the Alternate code for the award year
                    OPEN        c_alternate_code(p_ci_cal_type,p_ci_sequence_number);
                    FETCH       c_alternate_code INTO  l_alternate_code;
                    CLOSE       c_alternate_code;

                   FND_MESSAGE.SET_NAME('IGF','IGF_GR_LI_PER_INVALID');
                   FND_MESSAGE.SET_TOKEN('PERSON_NUMBER',l_stud.party_number);
                   FND_MESSAGE.SET_TOKEN('AWD_YR',l_alternate_code);
                   FND_FILE.PUT_LINE(fnd_file.log,fnd_message.get());
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'');

                   ln_counter  := 1;
                 END IF;
        CLOSE c_get_base_id;

        l_curr_base_id  := l_get_base_id.base_id ;
        ln_person_id    := l_stud.party_id ;
        l_person_number := l_stud.party_number ;

    ELSE

      FETCH c_year INTO l_year ;
      EXIT WHEN c_year%notfound ;

      l_curr_base_id  := l_year.base_id ;
      ln_person_id    := l_year.person_id ;
      l_person_number := l_year.party_number;

    END IF;


    IF ln_counter = 0 THEN
    -- Process Target Group Code

      OPEN c_rule_cd(l_ci_cal_type,
                     l_ci_sequence_NUMBER,
                     p_grp_code);
      LOOP


         FETCH c_rule_cd INTO l_rule_cd ;
         EXIT WHEN c_rule_cd%notfound ;

           OPEN  c_fabase(l_curr_base_id);
           FETCH c_fabase INTO l_fabase ;
           CLOSE c_fabase ;

           OPEN c_check_group(l_curr_base_id);
           FETCH c_check_group INTO l_check_group;
           CLOSE c_check_group;

            IF l_check_group.target_group = p_grp_code THEN
              FND_MESSAGE.SET_NAME('IGF','IGF_AW_PROC_GRP_CD_ALRDY_ASGND');
              FND_MESSAGE.SET_TOKEN('GRP_CODE',p_grp_code);
              FND_MESSAGE.SET_TOKEN('PERSON_NUMBER',l_person_number);
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              FND_FILE.PUT_LINE(FND_FILE.LOG,'');
            ELSE
             FND_MESSAGE.SET_NAME('IGF','IGF_AW_PROCESS_GRP_CODE');
             FND_MESSAGE.SET_TOKEN('PERSON_NUMBER',l_person_number);
             FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

             IF NVL(l_fabase.lock_awd_flag,'N') = 'N' THEN
                igf_ap_fa_base_rec_pkg.update_row(
                     x_rowid                          =>  l_fabase.row_id,
                     x_base_id                        =>  l_fabase.base_id,
                     x_ci_cal_type                    =>  l_fabase.ci_cal_type,
                     x_person_id                      =>  l_fabase.person_id,
                     x_ci_sequence_NUMBER             =>  l_fabase.ci_sequence_NUMBER,
                     x_org_id                         =>  l_fabase.org_id,
                     x_coa_pending                    =>  l_fabase.coa_pending,
                     x_verification_process_run       =>  l_fabase.verification_process_run,
                     x_inst_verif_status_date         =>  l_fabase.inst_verif_status_date,
                     x_manual_verif_flag              =>  l_fabase.manual_verif_flag,
                     x_fed_verif_status               =>  l_fabase.fed_verif_status,
                     x_fed_verif_status_date          =>  l_fabase.fed_verif_status_date,
                     x_inst_verif_status              =>  l_fabase.inst_verif_status,
                     x_nslds_eligible                 =>  l_fabase.nslds_eligible,
                     x_ede_correction_batch_id        =>  l_fabase.ede_correction_batch_id,
                     x_fa_process_status_date         =>  l_fabase.fa_process_status_date,
                     x_isir_corr_status               =>  l_fabase.isir_corr_status,
                     x_isir_corr_status_date          =>  l_fabase.isir_corr_status_date,
                     x_isir_status                    =>  l_fabase.isir_status,
                     x_isir_status_date               =>  l_fabase.isir_status_date,
                     x_coa_code_f                     =>  l_fabase.coa_code_f,
                     x_coa_code_i                     =>  l_fabase.coa_code_i,
                     x_coa_f                          =>  l_fabase.coa_f,
                     x_coa_i                          =>  l_fabase.coa_i,
                     x_disbursement_hold              =>  l_fabase.disbursement_hold,
                     x_fa_process_status              =>  l_fabase.fa_process_status,
                     x_notification_status            =>  l_fabase.notification_status,
                     x_notification_status_date       =>  l_fabase.notification_status_date,
                     x_packaging_status               =>  l_fabase.packaging_status,
                     x_packaging_status_date          =>  l_fabase.packaging_status_date,
                     x_total_package_accepted         =>  l_fabase.total_package_accepted,
                     x_total_package_offered          =>  l_fabase.total_package_offered,
                     x_admstruct_id                   =>  l_fabase.admstruct_id,
                     x_admsegment_1                   =>  l_fabase.admsegment_1,
                     x_admsegment_2                   =>  l_fabase.admsegment_2,
                     x_admsegment_3                   =>  l_fabase.admsegment_3,
                     x_admsegment_4                   =>  l_fabase.admsegment_4,
                     x_admsegment_5                   =>  l_fabase.admsegment_5,
                     x_admsegment_6                   =>  l_fabase.admsegment_6,
                     x_admsegment_7                   =>  l_fabase.admsegment_7,
                     x_admsegment_8                   =>  l_fabase.admsegment_8,
                     x_admsegment_9                   =>  l_fabase.admsegment_9,
                     x_admsegment_10                  =>  l_fabase.admsegment_10,
                     x_admsegment_11                  =>  l_fabase.admsegment_11,
                     x_admsegment_12                  =>  l_fabase.admsegment_12,
                     x_admsegment_13                  =>  l_fabase.admsegment_13,
                     x_admsegment_14                  =>  l_fabase.admsegment_14,
                     x_admsegment_15                  =>  l_fabase.admsegment_15,
                     x_admsegment_16                  =>  l_fabase.admsegment_16,
                     x_admsegment_17                  =>  l_fabase.admsegment_17,
                     x_admsegment_18                  =>  l_fabase.admsegment_18,
                     x_admsegment_19                  =>  l_fabase.admsegment_19,
                     x_admsegment_20                  =>  l_fabase.admsegment_20,
                     x_packstruct_id                  =>  l_fabase.packstruct_id,
                     x_packsegment_1                  =>  l_fabase.packsegment_1,
                     x_packsegment_2                  =>  l_fabase.packsegment_2,
                     x_packsegment_3                  =>  l_fabase.packsegment_3,
                     x_packsegment_4                  =>  l_fabase.packsegment_4,
                     x_packsegment_5                  =>  l_fabase.packsegment_5,
                     x_packsegment_6                  =>  l_fabase.packsegment_6,
                     x_packsegment_7                  =>  l_fabase.packsegment_7,
                     x_packsegment_8                  =>  l_fabase.packsegment_8,
                     x_packsegment_9                  =>  l_fabase.packsegment_9,
                     x_packsegment_10                 =>  l_fabase.packsegment_10,
                     x_packsegment_11                 =>  l_fabase.packsegment_11,
                     x_packsegment_12                 =>  l_fabase.packsegment_12,
                     x_packsegment_13                 =>  l_fabase.packsegment_13,
                     x_packsegment_14                 =>  l_fabase.packsegment_14,
                     x_packsegment_15                 =>  l_fabase.packsegment_15,
                     x_packsegment_16                 =>  l_fabase.packsegment_16,
                     x_packsegment_17                 =>  l_fabase.packsegment_17,
                     x_packsegment_18                 =>  l_fabase.packsegment_18,
                     x_packsegment_19                 =>  l_fabase.packsegment_19,
                     x_packsegment_20                 =>  l_fabase.packsegment_20,
                     x_miscstruct_id                  =>  l_fabase.miscstruct_id,
                     x_miscsegment_1                  =>  l_fabase.miscsegment_1,
                     x_miscsegment_2                  =>  l_fabase.miscsegment_2,
                     x_miscsegment_3                  =>  l_fabase.miscsegment_3,
                     x_miscsegment_4                  =>  l_fabase.miscsegment_4,
                     x_miscsegment_5                  =>  l_fabase.miscsegment_5,
                     x_miscsegment_6                  =>  l_fabase.miscsegment_6,
                     x_miscsegment_7                  =>  l_fabase.miscsegment_7,
                     x_miscsegment_8                  =>  l_fabase.miscsegment_8,
                     x_miscsegment_9                  =>  l_fabase.miscsegment_9,
                     x_miscsegment_10                 =>  l_fabase.miscsegment_10,
                     x_miscsegment_11                 =>  l_fabase.miscsegment_11,
                     x_miscsegment_12                 =>  l_fabase.miscsegment_12,
                     x_miscsegment_13                 =>  l_fabase.miscsegment_13,
                     x_miscsegment_14                 =>  l_fabase.miscsegment_14,
                     x_miscsegment_15                 =>  l_fabase.miscsegment_15,
                     x_miscsegment_16                 =>  l_fabase.miscsegment_16,
                     x_miscsegment_17                 =>  l_fabase.miscsegment_17,
                     x_miscsegment_18                 =>  l_fabase.miscsegment_18,
                     x_miscsegment_19                 =>  l_fabase.miscsegment_19,
                     x_miscsegment_20                 =>  l_fabase.miscsegment_20,
                     x_prof_judgement_flg             =>  l_fabase.prof_judgement_flg,
                     x_nslds_data_override_flg        =>  l_fabase.nslds_data_override_flg ,
                     x_target_group                   =>  p_grp_code,
                     x_coa_fixed                      =>  l_fabase.coa_fixed,
                     x_coa_pell                       =>  l_fabase.coa_pell,
                     x_profile_status                 =>  l_fabase.profile_status,
                     x_profile_status_date            =>  l_fabase.profile_status_date,
                     x_profile_fc                     =>  l_fabase.profile_fc,
                     x_manual_disb_hold               =>  l_fabase.manual_disb_hold,
                     x_tolerance_amount               =>  l_fabase.tolerance_amount,
                     x_pell_alt_expense               =>  l_fabase.pell_alt_expense,
                     x_mode                           =>  'R',
                     x_assoc_org_num                  =>  l_fabase.assoc_org_num,
                     x_award_fmly_contribution_type   =>  l_fabase.award_fmly_contribution_type,
                     x_isir_locked_by                 =>  l_fabase.isir_locked_by,
                     x_adnl_unsub_loan_elig_flag      =>  l_fabase.adnl_unsub_loan_elig_flag,
                     x_lock_awd_flag                  =>  l_fabase.lock_awd_flag,
                     x_lock_coa_flag                  =>  l_fabase.lock_coa_flag
                    );

                    FND_MESSAGE.SET_NAME('IGF','IGF_AW_GRP_ASSIGN_STUD');
                    FND_MESSAGE.SET_TOKEN('GRP_CODE',p_grp_code);
                    FND_MESSAGE.SET_TOKEN('PERSON',l_person_number);
                    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

                    FND_MESSAGE.SET_NAME('IGF','IGF_AW_GRP_ASSIGN_COMP');
                    FND_MESSAGE.SET_TOKEN('PERSON_NUMBER',l_person_number);
                    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'');
                  ELSE
                    FND_MESSAGE.SET_NAME('IGF','IGF_AW_LOCK');
                    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'');
                  END IF;
              END IF;

           EXIT ;

      END LOOP ;
      CLOSE c_rule_cd ;
    END IF;

    ln_counter := 0;

  END LOOP ;

  IF l_stud_proc THEN
      CLOSE c_stud ;
  ELSE
      CLOSE c_year ;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AW_RULE.tgroup_rule' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rule.tgroup_rule.exception','sql error:'||SQLERRM);
      END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

 END tgroup_rule ;
END IGF_AW_RULE;

/
