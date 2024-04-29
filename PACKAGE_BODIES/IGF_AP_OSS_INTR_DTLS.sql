--------------------------------------------------------
--  DDL for Package Body IGF_AP_OSS_INTR_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_OSS_INTR_DTLS" AS
/* $Header: IGFAP20B.pls 115.30 2003/12/11 06:06:21 sjalasut ship $ */

--Added the last 6 parameters as per the FACCR001 DLD Disbursement Build Jul 2002
--Bug No:2145941 Disbursement Build Jul 2002

PROCEDURE get_details (p_person_id      IN     igs_ad_appl_all.person_id%TYPE,
                       p_awd_cal_type   IN     igs_ca_inst_all.cal_type%TYPE,
                       p_awd_seq_num    IN     igs_ca_inst_all.sequence_number%TYPE,
                       lv_oss_dtl_rec   IN OUT NOCOPY oss_dtl_cur
                       )
--
-- this procedure which will be called from other packages / plds
-- the parameters passed to this procedure are
-- person_id             IN
-- awd_cal_type          IN
-- awd_seq_num           IN
-- ref cursor variable   OUT NOCOPY
-- all the packages and pls which will be calling this package procedure
-- must decalre a record type variable as defined in the spec.
--
IS

-- Cursor to get Responsible Org Unit code
--
        CURSOR  resp_org_unit_cur(p_course_cd  igs_ps_ver_all.course_cd%TYPE,
                                  p_ver_num    igs_ps_ver_all.version_number%TYPE)
        IS
        SELECT  responsible_org_unit_cd  org_unit_code
        FROM    igs_ps_ver    pver
        WHERE   pver.course_cd      = p_course_cd
        AND     pver.version_number = p_ver_num;

        org_unit_rec  resp_org_unit_cur%ROWTYPE;
        lv_adm_org_unit_cd          igs_ps_ver_all.responsible_org_unit_cd%TYPE;
        lv_enrl_org_unit_cd         igs_ps_ver_all.responsible_org_unit_cd%TYPE;
--
-- Cursor to get  "Ability to Benefit" test check
-- Below query will return a record, if the Student has taken this test.
--
        CURSOR  check_atb_cur(p_person_id   igs_pe_typ_instances_all.person_id%TYPE)
        IS
        SELECT
        admission_test_type   adm_test_type,
        test_date             adm_test_date
        FROM
        igs_ad_test_results
        WHERE  person_id = p_person_id
        AND    admission_test_type = 'ATB';
-- Note : Though the Admission Test Type is a user defined code, the Implementation Guide
-- would indicate the School to set up this as "ATB".If the Student has taken up this test,
-- then Return "Y". Else "N"

        atb_rec check_atb_cur%ROWTYPE;
        lv_atb          VARCHAR2(30)  DEFAULT 'N';


-- These set of variables are returned from igf_ap_oss_integr.get_adm_appl_details()
-- [
        lv_ad_appl_row_id        ROWID;              -- Retains RowId for  IGS_AD_APPL
        lv_ad_prog_row_id        ROWID;              -- Retains RowId for  IGS_AD_PS_APPL_INST
        lv_adm_appl_number       igs_ad_appl_all.admission_appl_number%TYPE;
        lv_course_cd             igs_ad_ps_appl_inst_all.course_cd%TYPE;
        lv_crv_version_number    igs_ad_ps_appl_inst_all.crv_version_number%TYPE;
        lv_adm_offer_resp_stat   igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE;
        lv_adm_outcome_stat      igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE;
        lv_adm_appl_status       igs_ad_appl_all.adm_appl_status%TYPE;
        lv_multiple              VARCHAR2(10);                 -- Hold 'Y' / 'N'
-- ]

-- These variables are needed to get enrol_credit_pt details
-- [
        lv_req_cp           igs_ps_ver_all.credit_points_required%TYPE;
        lv_passed_cp        NUMBER(15,2);
                             -- this is enrl_total_cp
        lv_adv_stnd_cp       NUMBER(15,2);
                            -- this is enrl_cuml_trans_cp
        lv_enrl_stud_cp      NUMBER(15,2);
                            -- this is cur_enrl_credit_points
        lv_cp_remain        NUMBER;
-- ]
--

-- variables to get anticipated completion date
-- [
        lv_course_start_dt                 DATE;
        lv_expected_completion_yr          igs_ad_ps_appl_inst_all.expected_completion_yr%TYPE;
        lv_expected_completion_perd        igs_ad_ps_appl_inst_all.expected_completion_perd%TYPE;
        lv_completion_dt                   DATE;
-- ]

-- variables to get Cummulative and Current GPA
-- [
      lv_gpa_cum                     NUMBER;
      lv_gpa_curr                    NUMBER;
      lv_gpa_cp                      NUMBER;
      lv_gpa_qp                      NUMBER;
      lv_ret_stat                    VARCHAR2(100);
      lv_msg_count                   NUMBER;
      lv_msg_data                    VARCHAR2(2000);
      lv_earned_cp                   NUMBER;
      lv_attempted_Cp                NUMBER;
      lv_inst_attd                   VARCHAR2(30);
      lv_credit_pts                  NUMBER;
      lv_fte                         NUMBER;
--]
-- [
-- start of declaration of variables for get_enrol_details

        --
        -- Cursor to get details enrolment details  from igs_en_stdnt_ps_att
        --

        --Added the last two AND conditions as per the FACCR004 in Disbursement Build Jul 2002
        --to differentiate between  records having primary program as 'Y' and 'A' or 'E'
        --Bug Id:2154941
        CURSOR enrl_std_cur( p_person_id    igs_en_stdnt_ps_att_all.person_id%TYPE) IS
        SELECT course_cd, adm_admission_appl_number, version_number, commencement_dt, course_attempt_status, attendance_mode, location_cd
          FROM igs_en_stdnt_ps_att
         WHERE person_id       = p_person_id
           AND key_program     = 'Y' ;


       --Added as per the FACCR004 in Disbursement Build Jul 2002
       --Cursor to check if there are more than 1 program attempt for a person.
       --
       CURSOR cur_get_no_of_prg_attempts IS
       SELECT COUNT(person_id)
         FROM   igs_en_stdnt_ps_att
        WHERE person_id = p_person_id;

        --Added the cursor to resolve bug 2296776

  CURSOR get_adm_cnt(cp_course_cd igs_ps_ver.course_cd%TYPE) IS
  SELECT COUNT(*) cnt FROM igs_ad_ps_appl_inst
  WHERE person_id=p_person_id AND
  course_cd = cp_course_cd;

  l_adm_cnt_rec    get_adm_cnt%ROWTYPE;


  CURSOR get_adm_dtls(cp_course_cd igs_ps_ver.course_cd%TYPE) IS
  SELECT  adm.course_type adm_course_type,adps.course_cd adm_course_cd,
  adps.admission_appl_number adm_appl_number
  FROM igs_ad_ps_appl_inst adps,igs_en_stdnt_ps_att enps,
        igs_ps_ver adm,igs_ps_ver enrl
  WHERE adps.person_id=p_person_id AND adps.person_id= enps.person_id
  AND enps.course_cd=cp_course_cd AND enps.course_cd=enrl.course_cd
  AND adps.course_cd = adm.course_cd AND adm.course_type=enrl.course_type;

  l_adm_rec       get_adm_dtls%ROWTYPE;

--
-- Note : For testing purposes WHERE clause will be taken off if oss does not come up with the new
-- table structure to include primary_program column
--
        enrl_std_rec            enrl_std_cur%ROWTYPE;
        enrl_std_mult_rec       enrl_std_cur%ROWTYPE;

--
-- This cursor will also determine if there are more than one records for a person in
-- igs_en_stdnt_ps_att.If there are more than one records then
-- multiple_prog_d = 'Y' else 'N'
--
        lv_mult_prog_d          VARCHAR2(10) DEFAULT 'N';

--
-- Cursor to get enrollment cal_type
--

        CURSOR enrl_dtl_cur(p_acad_cal_type  VARCHAR2,
                            p_acad_seq_num   NUMBER)
        IS
        SELECT
        ci.cal_type        enrl_load_cal_type,
        ci.sequence_number enrl_load_seq_num ,
        ci.alternate_code  enrolled_term
        FROM
        igs_ca_inst ci,
        igs_ca_type cty
        WHERE cty.s_cal_cat = 'LOAD'
        AND   cty.cal_type  = ci.cal_type
        AND   (ci.cal_type, ci.sequence_number)
        IN
        (
                SELECT sup_cal_type,
                sup_ci_sequence_number
                FROM igs_ca_inst_rel
                WHERE sub_cal_type           = p_acad_cal_type
                AND   sub_ci_sequence_number = p_acad_seq_num
                UNION
                SELECT sub_cal_type,
                sub_ci_sequence_number
                FROM igs_ca_inst_rel
                WHERE sup_cal_type           = p_acad_cal_type
                AND   sup_ci_sequence_number = p_acad_seq_num
        )
        AND
        SYSDATE BETWEEN ci.start_dt AND ci.end_dt
        ORDER BY ci.start_dt;

        enrl_dtl_rec enrl_dtl_cur%ROWTYPE;
        lv_message              VARCHAR2(1000);

-- Variables to store acad cal details
        lv_acad_cal_type        igs_ca_inst_all.cal_type%TYPE;
        lv_acad_seq_num         igs_ca_inst_all.sequence_number%TYPE;

--
-- Cursor to get enrlloment details
--
        CURSOR en_std_cur (p_course_cd       igs_ps_ver_all.course_type%TYPE,
                           p_version_number  igs_ps_ver_all.version_number%TYPE)
        IS
        SELECT
        course_type       enrl_program_type
        FROM igs_ps_ver
        WHERE
        course_cd      = p_course_cd
        AND
        version_number = p_version_number;

        en_std_rec en_std_cur%ROWTYPE;

-- The above COURSE_CD and VERSION_NUMBER are the Program details from Enrollment Module i.e.
-- IGS_EN_STDNT_PS_ATT.COURSE_CD      IGS_EN_STDNT_PS_ATT.VERSION_NUMBER
--

-- end of declaration of variables for get_enrl_details
-- ]


--
-- Cursor to get Admission Application Record details
--
        CURSOR adm_appl_cur(lv_ad_appl_row_id ROWID)
        IS
        SELECT adm.adm_cal_type, adm.adm_ci_sequence_number,adm.adm_appl_status, adm.appl_dt,adm.admission_cat, adm.
         adm_fee_status,adm.spcl_grp_1, adm.spcl_grp_2, adm_st.s_adm_appl_status appl_status,
         adm_ct.s_admission_process_type  process_type, adm_ft.s_adm_fee_status fee_status
          FROM IGS_AD_APPL             adm,
               IGS_AD_APPL_STAT        adm_st,
               IGS_AD_PRCS_CAT         adm_ct,
               IGS_AD_FEE_STAT         adm_ft
         WHERE adm.rowid = lv_ad_appl_row_id
           AND adm.adm_appl_status = adm_st.adm_appl_status
           AND adm.admission_cat = adm_ct.admission_cat
           AND adm.adm_fee_status = adm_ft.adm_fee_status;

        adm_appl_rec      adm_appl_cur%ROWTYPE;

--
-- Cursor to get Admission Program Record details
--
        CURSOR appl_prog_cur(lv_ad_prg_row_id  ROWID)
        IS
        SELECT prg.attendance_type, prg.attendance_mode, prg.course_cd , prg.crv_version_number, prg.adm_outcome_status, prg.decision_date, prg.adm_offer_resp_status,
         prg.actual_response_dt,prg.entry_level,prg.academic_index, prg.unit_set_cd, prg.us_version_number, prg_ou.s_adm_outcome_status     ou_status,
               prg_of.s_adm_offer_resp_status  offer_status, prg.location_cd
          FROM igs_ad_ps_appl_inst      prg,
               igs_ad_ou_stat           prg_ou,
               igs_ad_ofr_resp_stat     prg_of
         WHERE prg.rowid = lv_ad_prg_row_id
           AND prg.adm_outcome_status = prg_ou.adm_outcome_status
           AND prg.adm_offer_resp_status = prg_of.adm_offer_resp_status;

        appl_prog_rec   appl_prog_cur%ROWTYPE;

--
--    Cursor to get special program description
--

--
-- variables to store class_standing and pred_class_standing
--

        lv_pred_class_standing     VARCHAR2(60)   DEFAULT NULL;
        lv_class_standing          igs_pr_css_class_std_v.class_standing%TYPE DEFAULT NULL;

--Added this cursor as per the FACCR001 DLD Disbursement Build Jul 2002
--
--Cursor to get the Atheltic Details Count
--
       CURSOR cur_get_athletic_count IS
       SELECT COUNT(person_id)
       FROM   igs_pe_athletic_prg_v
       WHERE  person_id=p_person_id;

       l_athletic_cnt   NUMBER;
       l_athletic_m     VARCHAR2(1);

 --Added the cursor to resolve bug 2296776

      CURSOR get_uset_dtls(cp_person_id igf_ap_fa_base_rec.person_id%TYPE,
                           cp_course_cd igs_ps_ver.course_cd%TYPE) IS
        SELECT susa.unit_set_cd,susa.course_cd,susa.us_version_number
  FROM  igs_as_su_setatmpt susa,
        igs_en_unit_set us ,
        igs_en_unit_set_cat usc,
        igs_en_stdnt_ps_att_all ps
  WHERE susa.person_id = cp_person_id
  AND   ps.person_id = susa.person_id
  AND   susa.course_cd = ps.course_cd
  AND   ps.key_program = 'Y'
  AND   susa.course_cd = cp_course_cd
  AND  susa.PRIMARY_SET_IND = 'Y'
  AND  susa.selection_dt IS NOT NULL
  AND  susa.end_dt IS NULL
  AND  susa.rqrmnts_complete_dt IS NULL
  AND  susa.unit_set_cd = us.unit_set_cd
  AND  us.unit_set_cat = usc.unit_set_cat;

      l_uset_rec   get_uset_dtls%ROWTYPE;

     CURSOR cur_fa_load_awd (p_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
     IS
     SELECT sub_cal_type,
            sub_ci_sequence_number
     FROM igs_ca_inst_rel,
          igf_ap_fa_base_rec_all base
     WHERE sup_cal_type = base.ci_cal_type
       AND sup_ci_sequence_number = base.ci_sequence_number
       AND base.base_id = p_base_id;

     -- Cursor to get the attendance type for the maximum enrollment load
     CURSOR c_att_type(l_cal_type igs_ca_inst_all.cal_type%TYPE) IS
     SELECT attendance_type FROM igs_en_atd_type_load
     WHERE  cal_type = l_cal_type
     AND    lower_enr_load_range = (SELECT MAX(lower_enr_load_range)
                                    FROM  igs_en_atd_type_load
                                    WHERE cal_type = l_cal_type);
     l_full_att    c_att_type%ROWTYPE;

      CURSOR c_get_base_id (cp_person_id           igf_ap_fa_base_rec.person_id%TYPE,
                           cp_ci_cal_type         igf_ap_fa_base_rec.ci_cal_type%TYPE,
                           cp_ci_sequence_number  igf_ap_fa_base_rec.ci_sequence_number%TYPE)
      IS
      SELECT  base_id
      FROM igf_ap_fa_base_rec_all
      WHERE person_id     = cp_person_id
      AND   ci_cal_type   = cp_ci_cal_type
      AND   ci_sequence_number = cp_ci_sequence_number;

      base_id_rec   c_get_base_id%ROWTYPE;

      lv_inst_attd_t              VARCHAR2(30);
      lv_load_cal_type            VARCHAR2(20);
      lv_load_ci_seq_num          NUMBER;
      lv_load_ci_alt_code         VARCHAR2(20);
      lv_load_ci_start_dt         DATE;
      lv_load_ci_end_dt           DATE;
      l_last_load_inst_attd       VARCHAR2(10)  := NULL;
BEGIN
-- Get the details which are independent of award year

       OPEN   enrl_std_cur(p_person_id);
       -- this is the fetch to get the  program details based on whether it is for Primary Program or Admission or Enrollment.
       FETCH  enrl_std_cur INTO enrl_std_rec;
       CLOSE  enrl_std_cur;

       OPEN get_adm_cnt(enrl_std_rec.course_cd);
       FETCH get_adm_cnt INTO l_adm_cnt_rec;
       CLOSE get_adm_cnt;
       IF NVL(l_adm_cnt_rec.cnt,0) >= 1 THEN
          --lv_adm_appl_number    :=enrl_std_rec.adm_admission_appl_number;
          lv_course_cd          :=enrl_std_rec.course_cd;
          --lv_crv_version_number :=enrl_std_rec.version_number;
       ELSE
          OPEN get_adm_dtls(enrl_std_rec.course_cd);
          FETCH get_adm_dtls INTO l_adm_rec;
          CLOSE get_adm_dtls;
          lv_adm_appl_number    := l_adm_rec.adm_appl_number;
          lv_course_cd          := l_adm_rec.adm_course_cd;
          lv_crv_version_number :=enrl_std_rec.version_number;
       END IF;





        --
        -- Call igf_ap_oss_integr.gbefore call to IGFAP20B.pls admissions
        -- set_adm_appl_details to retreive
        -- the Selected Admission Application record [IGS_AD_APPL]
        -- and the Selected Admission Program detail record [IGS_AD_PS_APPL_INST]
        --

  BEGIN

        igf_ap_oss_integr.get_adm_appl_details(
                               p_person_id,
                               p_awd_cal_type,
                               p_awd_seq_num,
                               lv_ad_appl_row_id,
                               lv_ad_prog_row_id,
                               lv_adm_appl_number,
                               lv_course_cd,
                               lv_crv_version_number,
                               lv_adm_offer_resp_stat,
                               lv_adm_outcome_stat,
                               lv_adm_appl_status,
                               lv_multiple);

        EXCEPTION
    WHEN OTHERS THEN
      NULL;
        END;

        OPEN    resp_org_unit_cur(lv_course_cd,
                                  lv_crv_version_number);
        FETCH   resp_org_unit_cur INTO org_unit_rec;
        CLOSE   resp_org_unit_cur;

        lv_adm_org_unit_cd     :=      org_unit_rec.org_unit_code;

        OPEN    check_atb_cur(p_person_id);
        FETCH   check_atb_cur INTO atb_rec;

        IF      check_atb_cur%NOTFOUND THEN
                CLOSE check_atb_cur;
        ELSIF   check_atb_cur%FOUND THEN
                lv_atb   :=    'Y';
                CLOSE  check_atb_cur;
        END IF;

        -- Get admission related fields (IGS_AD_APPL)

        OPEN    adm_appl_cur(lv_ad_appl_row_id);
        FETCH   adm_appl_cur INTO adm_appl_rec;
        CLOSE   adm_appl_cur;

        -- Get Program related fields (IGS_AD_PS_APPL_INST)

        OPEN    appl_prog_cur(lv_ad_prog_row_id);
        FETCH   appl_prog_cur INTO appl_prog_rec;
        CLOSE   appl_prog_cur;




        -- Get enrol related fields   (IGS_EN_STDNT_PS_ATT )

        OPEN    resp_org_unit_cur(enrl_std_rec.course_cd,
                                  enrl_std_rec.version_number);
        FETCH   resp_org_unit_cur INTO org_unit_rec;
        CLOSE   resp_org_unit_cur;

        lv_enrl_org_unit_cd     :=      org_unit_rec.org_unit_code;

        --
        -- get acad cal from igs_en_gen_015 package
        -- do not let any exceptions from this call

        BEGIN


         igs_en_gen_015.enrp_get_eff_load_ci (
            p_person_id,
            enrl_std_rec.course_cd,
            SYSDATE,
            lv_acad_cal_type,        -- OUT NOCOPY parameter
            lv_acad_seq_num,         -- OUT NOCOPY parameter
            lv_load_cal_type,        -- OUT NOCOPY parameter
            lv_load_ci_seq_num,      -- OUT NOCOPY Parameter
            lv_load_ci_alt_code,     -- OUT NOCOPY Parameter
            lv_load_ci_start_dt,     -- OUT NOCOPY Parameter
            lv_load_ci_end_dt,       -- OUT NOCOPY Parameter
            lv_message               -- OUT NOCOPY Parameter
          );

            EXCEPTION
            WHEN OTHERS THEN
                 lv_acad_cal_type := NULL;
                 lv_acad_seq_num := NULL;
                 lv_message := NULL;
        END;


        -- get enrol_cal_type / seq_num / alt_code

        OPEN    enrl_dtl_cur(lv_acad_cal_type,lv_acad_seq_num);
        FETCH   enrl_dtl_cur INTO enrl_dtl_rec;
        CLOSE   enrl_dtl_cur;




        OPEN  en_std_cur(enrl_std_rec.course_cd,
                         enrl_std_rec.version_number);
        FETCH en_std_cur INTO en_std_rec;
        CLOSE en_std_cur;


        -- do not let any exceptions from this call

        BEGIN

           igs_in_gen_001.inqp_get_prg_cp(  p_person_id,
                                         enrl_std_rec.course_cd,
                                         enrl_std_rec.version_number,
                 lv_req_cp,
                 lv_passed_cp,              -- this is enrl_total_cp
                 lv_adv_stnd_cp,            -- this is enrl_cuml_trans_cp
                                         lv_enrl_stud_cp,           -- this is cur_enrl_credit_points
                 lv_cp_remain);
            EXCEPTION
            WHEN OTHERS THEN
           lv_req_cp  := NULL;
           lv_passed_cp  := NULL;
     lv_adv_stnd_cp  := NULL;
                 lv_enrl_stud_cp  := NULL;
           lv_cp_remain    := NULL;

        END;

        BEGIN

           igs_pr_cp_gpa.get_gpa_stats(
                   p_person_id,
                   enrl_std_rec.course_cd,
                   NULL,
                   enrl_dtl_rec.enrl_load_cal_type,
       enrl_dtl_rec.enrl_load_seq_num,
                   NULL,--'FIN_AID', commenting FIN_AID as this was part of FISAP impl
                   'Y',
                    lv_gpa_cum,
                    lv_gpa_cp,
                    lv_gpa_qp,
                    FND_API.G_TRUE,
                    lv_ret_stat,
                    lv_msg_count,
                    lv_msg_data);

        EXCEPTION
            WHEN OTHERS THEN
                lv_gpa_cum := NULL;
                lv_gpa_cp := NULL;
                lv_gpa_qp := NULL;
                lv_ret_stat := NULL;
                lv_msg_count := NULL;
                lv_msg_data  := NULL;
        END;

        BEGIN

           igs_pr_cp_gpa.get_gpa_stats( --Calculation of current GPA
                   p_person_id,
                   enrl_std_rec.course_cd,
                   NULL,
                   enrl_dtl_rec.enrl_load_cal_type,
       enrl_dtl_rec.enrl_load_seq_num,
                   NULL,--'FIN_AID', commenting FIN_AID as this was part of FISAP impl
                   'N',
                   lv_gpa_curr,
                   lv_gpa_cp,
                   lv_gpa_qp,
                   FND_API.G_TRUE,
                   lv_ret_stat,
                   lv_msg_count,
                   lv_msg_data);
        EXCEPTION
            WHEN OTHERS THEN
                lv_gpa_curr  := NULL;
                lv_gpa_cp    := NULL;
                lv_gpa_qp    := NULL;
                lv_ret_stat  := NULL;
                lv_msg_count := NULL;
                lv_msg_data  := NULL;
        END;

  BEGIN    -- Achieved Credit Points

         IGS_PR_CP_GPA.get_cp_stats(
       p_person_id               => p_person_id ,
       p_course_cd               => enrl_std_rec.course_cd,
       p_stat_type               => NULL,
       p_load_cal_type           => enrl_dtl_rec.enrl_load_cal_type,
       p_load_ci_sequence_number => enrl_dtl_rec.enrl_load_seq_num,
       p_system_stat             => NULL, -- 'FIN_AID',  commenting FIN_AID as this was part of FISAP impl
       p_cumulative_ind          => 'Y',
       p_earned_cp               => lv_earned_cp,
       p_attempted_cp            => lv_attempted_cp,
       p_init_msg_list           => FND_API.G_TRUE,
       p_return_status           => lv_ret_stat,
       p_msg_count               => lv_msg_count,
       p_msg_data                => lv_msg_data );
        EXCEPTION
            WHEN OTHERS THEN
                lv_earned_cp := NULL;
                lv_attempted_cp := NULL;
                lv_ret_stat := NULL;
                lv_msg_count := NULL;
                lv_msg_data  := NULL;
        END;

    BEGIN    -- Derived Institutional attendance type
        -- rasahoo replaced igs_en_prc_load.enrp_get_inst_latt
        -- as part of Obsoletion og FA base record

         OPEN  c_get_base_id(p_person_id,p_awd_cal_type ,p_awd_seq_num);
         FETCH c_get_base_id INTO base_id_rec;
         CLOSE c_get_base_id;

         FOR cur_fa_load_awd_rec IN cur_fa_load_awd(base_id_rec.base_id)
         LOOP
           igs_en_prc_load.enrp_get_inst_latt (p_person_id,
                                               cur_fa_load_awd_rec.sub_cal_type,
                                               cur_fa_load_awd_rec.sub_ci_sequence_number,
                                               lv_inst_attd,
                                               lv_credit_pts,
                                               lv_fte);


            OPEN c_att_type(cur_fa_load_awd_rec.sub_cal_type);
            FETCH c_att_type INTO l_full_att;
            CLOSE c_att_type;

            lv_inst_attd := NVL(lv_inst_attd,l_full_att.attendance_type);

            IF(NVL(l_last_load_inst_attd,lv_inst_attd) <> lv_inst_attd) THEN
               lv_inst_attd :=  NULL;
               EXIT;
            END IF;
            l_last_load_inst_attd := lv_inst_attd ;
          END LOOP;

    EXCEPTION
          WHEN OTHERS THEN
              lv_inst_attd  := NULL;
              lv_credit_pts := NULL;
              lv_fte        := NULL;
    END;

    -- Bug 3254448 Added this call to get the current enrolled credit points based on the current term.
    BEGIN
    igs_en_prc_load.enrp_get_inst_latt (p_person_id,
                                        enrl_dtl_rec.enrl_load_cal_type,
                                        enrl_dtl_rec.enrl_load_seq_num,
                                        lv_inst_attd_t,
                                        lv_credit_pts,
                                        lv_fte);
    EXCEPTION
      WHEN OTHERS THEN
        lv_inst_attd_t  := NULL;
        lv_credit_pts   := NULL;
        lv_fte          := NULL;
    END;

  OPEN get_uset_dtls(p_person_id,enrl_std_rec.course_cd);
  FETCH get_uset_dtls INTO l_uset_rec;
  CLOSE get_uset_dtls;
        --
        -- This is end of get_enrl_details
        --
        -- do not let any exceptions from this call

        BEGIN


           lv_course_start_dt := igs_ad_gen_005.admp_get_crv_strt_dt(adm_appl_rec.adm_cal_type,
                                                                  adm_appl_rec.adm_ci_sequence_number);

        -- get the anticipated completion date (v_completion_dt) using the below function.
           igs_ad_gen_004.admp_get_crv_comp_dt (lv_course_cd,
                                             lv_crv_version_number,
                                             lv_acad_cal_type,
                                             appl_prog_rec.attendance_type,
                                             lv_course_start_dt,
                                             lv_expected_completion_yr,
                                             lv_expected_completion_perd,
                                             lv_completion_dt,
                                             appl_prog_rec.attendance_mode,
                                             appl_prog_rec.location_cd
                                             );

            EXCEPTION
            WHEN OTHERS THEN
                lv_expected_completion_yr := NULL;
                lv_expected_completion_perd     := NULL;
                lv_completion_dt    := NULL;

        END;


--
--  we use oss function to get class standing and predictive class standing
--

    -- do not let any exceptions from this call

        BEGIN

                lv_class_standing       :=      igs_pr_get_class_std.get_class_standing(
                                                                p_person_id,
                                                                enrl_std_rec.course_cd,
                                                                'N',
                                                                NULL,
                                                                NULL,
                                                                NULL);

                lv_pred_class_standing  :=      igs_pr_get_class_std.get_class_standing(
                                                                p_person_id,
                                                                enrl_std_rec.course_cd,
                                                                'Y',
                                                                NULL,
                                                                NULL,
                                                                NULL);



            EXCEPTION
            WHEN OTHERS THEN NULL;

        END;


         --Get the ahtletic count for the person id
           OPEN cur_get_athletic_count;
           FETCH cur_get_athletic_count INTO l_athletic_cnt;
           CLOSE cur_get_athletic_count;

           --Added this check as per the FACCR001 DLD Bug No:-2154941

           IF NVL(l_athletic_cnt,0) > 1 THEN
              l_athletic_m := 'Y';
           ELSE
              l_athletic_m  := 'N';
           END IF;

        -- Select all the values into REF cursor

        OPEN lv_oss_dtl_rec FOR
        SELECT
                adm_appl_rec.adm_appl_status,
                adm_appl_rec.appl_status,
                adm_appl_rec.appl_dt,
                lv_class_standing,                -- class_standing
                lv_credit_pts,
                adm_appl_rec.admission_cat,
                adm_appl_rec.process_type,
                appl_prog_rec.course_cd || ' ' || appl_prog_rec.crv_version_number,
                appl_prog_rec.course_cd,
                appl_prog_rec.crv_version_number,
                appl_prog_rec.attendance_mode,
                appl_prog_rec.attendance_type,
                appl_prog_rec.adm_outcome_status,
                appl_prog_rec.ou_status,
                appl_prog_rec.decision_date,
                appl_prog_rec.adm_offer_resp_status,
                appl_prog_rec.offer_status,
                appl_prog_rec.actual_response_dt,
                adm_appl_rec.adm_fee_status,
                adm_appl_rec.fee_status,
                adm_appl_rec.spcl_grp_1,                                           -- sp_program_1
                adm_appl_rec.spcl_grp_2,                                           -- sp_program_2
                appl_prog_rec.entry_level,                                           -- entry_level
                lv_completion_dt,
                appl_prog_rec.academic_index,
                lv_adm_org_unit_cd,
                appl_prog_rec.unit_set_cd || ' ' || appl_prog_rec.us_version_number,
                appl_prog_rec.unit_set_cd,
                appl_prog_rec.us_version_number,
                enrl_std_rec.commencement_dt,
                NULL,                                           -- transfered
                lv_multiple,
                lv_atb,
                enrl_dtl_rec.enrolled_term,
                enrl_dtl_rec.enrl_load_cal_type,
                enrl_dtl_rec.enrl_load_seq_num,
                NULL,                                           -- sap_evaluation_date
                NULL,                                           -- sap_selected_flag
                lv_mult_prog_d,
                enrl_std_rec.course_cd || ' ' || enrl_std_rec.version_number,
                enrl_std_rec.course_cd,
                enrl_std_rec.version_number,
                en_std_rec.enrl_program_type,
                l_uset_rec.unit_set_cd,                                           -- enrl_unit_set
                l_uset_rec.course_cd,                                           -- enrl_uset_course_cd
                l_uset_rec.us_version_number,                                           -- enrl_uset_ver_num
                enrl_std_rec.course_attempt_status,
                lv_inst_attd,
                lv_gpa_curr,                                           -- current_gpa
                lv_gpa_cum,                                         -- cumulative_gpa
                lv_earned_cp,                                      -- acheived_cr_pts
                lv_pred_class_standing,                         -- pred_class_standing
                lv_enrl_org_unit_cd,
                enrl_std_rec.attendance_mode,
                enrl_std_rec.location_cd,
                lv_passed_cp,
                lv_adv_stnd_cp + lv_passed_cp,   -- enrl_cuml_cp= enrl_cuml_trans_cp+ enrl_total_cp
                lv_adv_stnd_cp,
                lv_adm_appl_number
        FROM DUAL;


EXCEPTION

WHEN OTHERS THEN

        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','igf_ap_oss_intr_dtls.get_details');
        igs_ge_msg_stack.add;

END get_details;

END igf_ap_oss_intr_dtls;

/
