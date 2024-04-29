--------------------------------------------------------
--  DDL for Package Body IGS_HE_PS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_PS_PKG" AS
/* $Header: IGSHE15B.pls 120.1 2006/02/07 14:52:47 jbaber noship $ */

-----------------------------------------------------------------------------
-- Change History
-- Who         When           What
--sbaliga	8-Apr-02     Modified package to reflect datamodel changes in
--                           IGS_HE_ST_PROG_ALL and IGS_HE_POOUS_ALL tables
--                           as part of #2278825.
-- rshergil    03-Jan-02     Created Package to rollover Program
--                           Version information relating to
--                           1.UK Statistics - Program details
--                           2.Program Offering Option Unit Set HESA Details
-- smaddali    20-Aug-03     Modified procedure for hefd208 bug#2717751 to add funding_source column to igs_he_poous_all tbh call
-- ayedubat    28-Aug-03     Created a new procedure, create_prg_cc_rec to copy the Hesa
--                           Statistic Cost Center Details for HE207 Enhancement bug, 2717753
-- jbaber      25-Jan-05     Modified for HE355 - Org Unit Cost Center Link
-- jbaber      24-Nov-05     Included exclude_flag column for HE305
-----------------------------------------------------------------------------

PROCEDURE copy_prog_version(
      p_old_course_cd           IN VARCHAR2,
      p_old_version_number      IN NUMBER,
      p_new_course_cd           IN VARCHAR2,
      p_new_version_number      IN NUMBER,
      p_message_name            OUT NOCOPY VARCHAR2,
      p_status                  OUT NOCOPY NUMBER)
   AS
      cst_max_error_range CONSTANT NUMBER := -20999;
      cst_min_error_range CONSTANT NUMBER := -20000;
      cst_ret_message_name CONSTANT VARCHAR2(240) := 'IGS_HE_FAIL_COPYPRGVER_DET';


   CURSOR gc_hsp_old_rec IS
   SELECT *
   FROM igs_he_st_prog_all
   WHERE course_cd      = p_old_course_cd
   AND version_number   = p_old_version_number;
   gv_hsp_old_rec       gc_hsp_old_rec%ROWTYPE;


   CURSOR gc_hsp_new_rec IS
   SELECT   hesa_st_prog_id
   FROM igs_he_st_prog_all
   WHERE course_cd      = p_new_course_cd
   AND version_number   = p_new_version_number;
   gv_hsp_new_rec       gc_hsp_new_rec%ROWTYPE;

   CURSOR gc_hpus_old_rec IS
   SELECT  *
   FROM igs_he_poous_all
   WHERE course_cd              = p_old_course_cd
   AND crv_version_number       = p_old_version_number;
   gv_hpus_old_rec              gc_hpus_old_rec%ROWTYPE;

   CURSOR gc_hpus_new_rec    (p_cal_type        igs_he_poous.cal_type%TYPE,
                           p_location_cd        igs_he_poous.location_cd%TYPE,
                           p_attendance_mode    igs_he_poous.attendance_mode%TYPE,
                           p_attendance_type    igs_he_poous.attendance_type%TYPE,
                           p_unit_set_cd        igs_he_poous.unit_set_cd%TYPE,
                           p_us_version_number  igs_he_poous.us_version_number%TYPE)
   IS
   SELECT  hesa_poous_id
   FROM igs_he_poous_all
   WHERE course_cd              = p_new_course_cd
   AND crv_version_number       = p_new_version_number
   AND cal_type                 = p_cal_type
   AND location_cd              = p_location_cd
   AND attendance_mode          = p_attendance_mode
   AND attendance_type          = p_attendance_type
   AND unit_set_cd              = p_unit_set_cd
   AND us_version_number        = p_us_version_number;
   gv_hpus_new_rec              gc_hpus_new_rec%ROWTYPE;

    CURSOR gc_hpo_old_rec
    IS   SELECT *
     FROM igs_he_poous_ou_all
     WHERE course_cd            = p_old_course_cd
     AND crv_version_number     = p_old_version_number ;
     gv_hpo_old_rec             gc_hpo_old_rec%ROWTYPE;

   CURSOR gc_hpo_new_rec     (p_cal_type        igs_he_poous_ou.cal_type%TYPE,
                           p_location_cd        igs_he_poous_ou.location_cd%TYPE,
                           p_attendance_mode    igs_he_poous_ou.attendance_mode%TYPE,
                           p_attendance_type    igs_he_poous_ou.attendance_type%TYPE,
                           p_unit_set_cd        igs_he_poous_ou.unit_set_cd%TYPE,
                           p_us_version_number  igs_he_poous_ou.us_version_number%TYPE,
                           p_organization_unit  igs_he_poous_ou.organization_unit%TYPE)
   IS  SELECT hesa_poous_ou_id
    FROM igs_he_poous_ou_all
    WHERE course_cd             = p_new_course_cd
    AND crv_version_number      = p_new_version_number
    AND cal_type                = p_cal_type
    AND location_cd             = p_location_cd
    AND attendance_mode         = p_attendance_mode
    AND attendance_type         = p_attendance_type
    AND unit_set_cd             = p_unit_set_cd
    AND us_version_number       = p_us_version_number
    AND organization_unit       = p_organization_unit;
    gv_hpo_new_rec              gc_hpo_new_rec%ROWTYPE;

    --Procedure inserts into IGS_HE_ST_PROG_ALL table

    PROCEDURE cr_he_st_pr_rec ( p_new_course_cd         igs_he_st_prog.course_cd%TYPE,
                            p_new_version_number        igs_he_st_prog.version_number%TYPE) IS

    BEGIN

       DECLARE
                v_hesa_seq_num  igs_he_st_prog.hesa_st_prog_id%TYPE;

                   CURSOR c_hesa_seq_num IS
                     SELECT igs_he_st_prog_all_s.NEXTVAL
                     FROM dual;

                   x_rowid VARCHAR2(250);
                   l_org_id NUMBER(15);

       BEGIN

                OPEN c_hesa_seq_num;
                FETCH c_hesa_seq_num INTO v_hesa_seq_num;
                CLOSE c_hesa_seq_num;

                l_org_id := igs_ge_gen_003.get_org_id;
                x_rowid := NULL;

                igs_he_st_prog_all_pkg.insert_row(
                    X_ROWID                       => x_rowid,
                    X_HESA_ST_PROG_ID             => v_hesa_seq_num,
                    X_ORG_ID                      => l_org_id,
                    X_COURSE_CD                   => p_new_course_cd,
                    X_VERSION_NUMBER              => p_new_version_number,
                    X_TEACHER_TRAIN_PROG_ID       => gv_hsp_old_rec.teacher_train_prog_id,
                    X_ITT_PHASE                   => gv_hsp_old_rec.itt_phase,
                    X_BILINGUAL_ITT_MARKER        => gv_hsp_old_rec.bilingual_itt_marker,
                    X_TEACHING_QUAL_SOUGHT_SECTOR => gv_hsp_old_rec.teaching_qual_sought_sector,
                    X_TEACHING_QUAL_SOUGHT_SUBJ1  => gv_hsp_old_rec.teaching_qual_sought_subj1,
                    X_TEACHING_QUAL_SOUGHT_SUBJ2  => gv_hsp_old_rec.teaching_qual_sought_subj2,
                    X_TEACHING_QUAL_SOUGHT_SUBJ3  => gv_hsp_old_rec.teaching_qual_sought_subj3,
                    X_LOCATION_OF_STUDY           => gv_hsp_old_rec.location_of_study,
                    X_OTHER_INST_PROV_TEACHING1   => gv_hsp_old_rec.other_inst_prov_teaching1,
                    X_OTHER_INST_PROV_TEACHING2   => gv_hsp_old_rec.other_inst_prov_teaching2,
                    X_PROP_TEACHING_IN_WELSH      => gv_hsp_old_rec.prop_teaching_in_welsh,
                    X_PROP_NOT_TAUGHT             => gv_hsp_old_rec.prop_not_taught,
                    X_CREDIT_TRANSFER_SCHEME      => gv_hsp_old_rec.credit_transfer_scheme,
                    X_RETURN_TYPE                 => gv_hsp_old_rec.return_type,
                    X_DEFAULT_AWARD               => gv_hsp_old_rec.default_award,
                    X_PROGRAM_CALC                => gv_hsp_old_rec.program_calc,
                    X_LEVEL_APPLICABLE_TO_FUNDING => gv_hsp_old_rec.level_applicable_to_funding,
                    X_FRANCHISING_ACTIVITY        => gv_hsp_old_rec.franchising_activity,
                    X_NHS_FUNDING_SOURCE          => gv_hsp_old_rec.nhs_funding_source,
                    X_FE_PROGRAM_MARKER           => gv_hsp_old_rec.fe_program_marker,
                    X_FEE_BAND                    => gv_hsp_old_rec.fee_band,
                    X_FUNDABILITY                 => gv_hsp_old_rec.fundability,
                    X_FTE_INTENSITY               => gv_hsp_old_rec.fte_intensity,
                    X_TEACH_PERIOD_START_DT       => gv_hsp_old_rec.teach_period_start_dt,
                    X_TEACH_PERIOD_END_DT         => gv_hsp_old_rec.teach_period_end_dt,
                    X_MODE                        => 'R',
                    X_IMPLIED_FUND_RATE           => gv_hsp_old_rec.implied_fund_rate,
                    X_GOV_INITIATIVES_CD          => gv_hsp_old_rec.gov_initiatives_cd,
                    X_UNITS_FOR_QUAL              => gv_hsp_old_rec.units_for_qual,
                    X_DISADV_UPLIFT_ELIG_CD       => gv_hsp_old_rec.disadv_uplift_elig_cd,
                    X_FRANCH_PARTNER_CD           => gv_hsp_old_rec.franch_partner_cd,
                    X_FRANCH_OUT_ARR_CD           => gv_hsp_old_rec.franch_out_arr_cd,
                    X_EXCLUDE_FLAG                => gv_hsp_old_rec.exclude_flag );

       END;

    EXCEPTION
       WHEN OTHERS THEN
                p_status := 2;
                IF(SQLCODE >= cst_max_error_range  AND SQLCODE <= cst_min_error_range) THEN
                        p_message_name := cst_ret_message_name;
                ELSE
                        app_exception.raise_exception;
                END IF;
    END cr_he_st_pr_rec;


    -- Procedure inserts a new record into IGS_HE_PROG_OU_CC table
    PROCEDURE create_prg_cc_rec (
      p_old_course_cd      igs_he_prog_ou_cc.course_cd%TYPE,
      p_old_version_number igs_he_prog_ou_cc.version_number%TYPE,
      p_new_course_cd      igs_he_prog_ou_cc.course_cd%TYPE,
      p_new_version_number igs_he_prog_ou_cc.version_number%TYPE) IS
    /******************************************************************
     Created By      : AYEDUBAT
     Date Created By : 13-JUN-2003
     Purpose         :  To copy the Hesa Statistic Cost Center Details defined at Program Version Level

     Change History
     WHO         WHEN           WHAT
     ayedubat   28-Aug-03     Created the new procedure for HE207FD bug, 2717753
     jbaber     25-Jan-05     Modified to use IGS_HE_PROG_OU_CC for HE355 - Org Unit Cost Centre Link
    ***************************************************************** */

      l_rowid VARCHAR2(25) := NULL;
      l_hesa_prog_cc_id igs_he_prog_ou_cc.hesa_prog_cc_id%TYPE := NULL ;
       l_dummy VARCHAR2(1);

      -- Fetch the Cost Centers of the Old version of the Program
      CURSOR old_prg_cc_dtls_cur( cp_course_cd IGS_HE_PROG_OU_CC.course_cd%TYPE,
                                  cp_version_number IGS_HE_PROG_OU_CC.version_number%TYPE) IS
        SELECT spc.*
        FROM IGS_HE_PROG_OU_CC spc
        WHERE spc.course_cd = cp_course_cd
          AND spc.version_number = cp_version_number;

      -- Check whether the Cost Center record already exist in the new program version
      CURSOR new_prg_cc_dtls_cur( cp_course_cd      IGS_HE_PROG_OU_CC.course_cd%TYPE,
                                  cp_version_number IGS_HE_PROG_OU_CC.version_number%TYPE,
                                  cp_org_unit_cd    IGS_HE_PROG_OU_CC.org_unit_cd%TYPE,
                                  cp_cost_centre    IGS_HE_PROG_OU_CC.cost_centre%TYPE,
                                  cp_subject        IGS_HE_PROG_OU_CC.subject%TYPE) IS
        SELECT 'X'
        FROM IGS_HE_PROG_OU_CC spc
        WHERE spc.course_cd = cp_course_cd
          AND spc.version_number = cp_version_number
          AND spc.org_unit_cd = cp_org_unit_cd
          AND spc.cost_centre = cp_cost_centre
          AND spc.subject = cp_subject;

    BEGIN

      -- Loop through all the records in IGS_HE_PROG_OU_CC table for old version of the program
      -- and insert if the record does not exist for new course code and version
      FOR old_prg_cc_dtls_rec IN old_prg_cc_dtls_cur( p_old_course_cd, p_old_version_number) LOOP

         OPEN new_prg_cc_dtls_cur(p_new_course_cd, p_new_version_number, old_prg_cc_dtls_rec.org_unit_cd,
                                  old_prg_cc_dtls_rec.cost_centre, old_prg_cc_dtls_rec.subject );
         FETCH new_prg_cc_dtls_cur INTO l_dummy;
         IF new_prg_cc_dtls_cur%NOTFOUND THEN

            -- create the new program version cost centre record
            igs_he_prog_ou_cc_pkg.insert_row (
              x_rowid            => l_rowid,
              x_hesa_prog_cc_id  => l_hesa_prog_cc_id,
              x_course_cd        => p_new_course_cd,
              x_version_number   => p_new_version_number,
              x_org_unit_cd      => old_prg_cc_dtls_rec.org_unit_cd,
              x_cost_centre      => old_prg_cc_dtls_rec.cost_centre,
              x_subject          => old_prg_cc_dtls_rec.subject,
              x_proportion       => old_prg_cc_dtls_rec.proportion,
              x_mode             => 'R' );

         END IF;
         CLOSE new_prg_cc_dtls_cur;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        p_status := 2;
        IF(SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
          p_message_name := cst_ret_message_name;
        ELSE
          app_exception.raise_exception;
        END IF;

    END create_prg_cc_rec;


    --Procedure inserts into IGS_HE_POOUS_ALL table

    PROCEDURE  cr_he_poo_us_rec (p_new_course_cd        igs_he_poous.course_cd%TYPE,
                                p_new_version_number    igs_he_poous.crv_version_number%TYPE) IS

    BEGIN

       DECLARE
                v_poous_seq_num IGS_HE_POOUS.hesa_poous_id%TYPE;

                CURSOR c_poous_seq_num IS
                 SELECT igs_he_poous_all_s.NEXTVAL
                FROM dual;

                l_org_id NUMBER(15);
                x_rowid VARCHAR2(250);

       BEGIN

                   OPEN c_poous_seq_num;
                   FETCH c_poous_seq_num INTO v_poous_seq_num;
                   CLOSE c_poous_seq_num;

                   x_rowid := NULL;
                   l_org_id := igs_ge_gen_003.get_org_id;

                   igs_he_poous_all_pkg.insert_row(
                         X_ROWID                       => x_rowid,
                         X_ORG_ID                      => l_org_id,
                         X_HESA_POOUS_ID               => v_poous_seq_num,
                         X_COURSE_CD                   => p_new_course_cd,
                         X_CRV_VERSION_NUMBER          => p_new_version_number,
                         X_CAL_TYPE                    => gv_hpus_old_rec.cal_type,
                         X_LOCATION_CD                 => gv_hpus_old_rec.location_cd,
                         X_ATTENDANCE_MODE             => gv_hpus_old_rec.attendance_mode,
                         X_ATTENDANCE_TYPE             => gv_hpus_old_rec.attendance_type,
                         X_UNIT_SET_CD                 => gv_hpus_old_rec.unit_set_cd,
                         X_US_VERSION_NUMBER           => gv_hpus_old_rec.us_version_number,
                         X_LOCATION_OF_STUDY           => gv_hpus_old_rec.location_of_study,
                         X_MODE_OF_STUDY               => gv_hpus_old_rec.mode_of_study,
                         X_UFI_PLACE                   => gv_hpus_old_rec.ufi_place,
                         X_FRANCHISING_ACTIVITY        => gv_hpus_old_rec.franchising_activity,
                         X_TYPE_OF_YEAR                => gv_hpus_old_rec.type_of_year,
                         X_LENG_CURRENT_YEAR           => gv_hpus_old_rec.leng_current_year,
                         X_GRADING_SCHEMA_CD           => gv_hpus_old_rec.grading_schema_cd,
                         X_GS_VERSION_NUMBER           => gv_hpus_old_rec.gs_version_number,
                         X_CREDIT_VALUE_YOP1           => gv_hpus_old_rec.credit_value_yop1,
                         X_LEVEL_CREDIT1               => gv_hpus_old_rec.level_credit1,
                         X_CREDIT_VALUE_YOP2           => gv_hpus_old_rec.credit_value_yop2,
                         X_LEVEL_CREDIT2               => gv_hpus_old_rec.level_credit2,
                         X_CREDIT_VALUE_YOP3           => gv_hpus_old_rec.credit_value_yop3,
                         X_LEVEL_CREDIT3               => gv_hpus_old_rec.level_credit3,
                         X_CREDIT_VALUE_YOP4           => gv_hpus_old_rec.credit_value_yop4,
                         X_LEVEL_CREDIT4               => gv_hpus_old_rec.level_credit4,
                         X_FTE_INTENSITY               => gv_hpus_old_rec.fte_intensity,
                         X_FTE_CALC_TYPE               => gv_hpus_old_rec.fte_calc_type,
                         X_TEACH_PERIOD_START_DT       => gv_hpus_old_rec.teach_period_start_dt,
                         X_TEACH_PERIOD_END_DT         => gv_hpus_old_rec.teach_period_end_dt,
                         X_OTHER_INSTIT_TEACH1         => gv_hpus_old_rec.other_instit_teach1,
                         X_OTHER_INSTIT_TEACH2         => gv_hpus_old_rec.other_instit_teach2,
                         X_PROP_NOT_TAUGHT             => gv_hpus_old_rec.prop_not_taught,
                         X_FUNDABILITY_CD              => gv_hpus_old_rec.fundability_cd,
                         X_FEE_BAND                    => gv_hpus_old_rec.fee_band,
                         X_LEVEL_APPLICABLE_TO_FUNDING => gv_hpus_old_rec.level_applicable_to_funding,
                         X_MODE                        => 'R',
                         X_FUNDING_SOURCE              => gv_hpus_old_rec.funding_source);

       END;

   EXCEPTION
        WHEN OTHERS THEN
                p_status := 2;
                IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range)
                 THEN
                        p_message_name := cst_ret_message_name;
                ELSE
                        app_exception.raise_exception;
                END IF;

    END cr_he_poo_us_rec;


    PROCEDURE create_poous_cc_rec (
      p_old_course_cd      igs_he_prog_ou_cc.course_cd%TYPE,
      p_old_version_number igs_he_prog_ou_cc.version_number%TYPE,
      p_new_course_cd      igs_he_prog_ou_cc.course_cd%TYPE,
      p_new_version_number igs_he_prog_ou_cc.version_number%TYPE) IS
    /******************************************************************
     Created By      : jbaber
     Date Created By : 25-Jan-2005
     Purpose         :  To copy the Hesa Statistic Cost Center Details defined at POOUS Level

     Change History
     WHO         WHEN           WHAT
     jbaber   25-Jan-2005    Created the new procedure for HE355 Org Unit Cost Center Link
    ***************************************************************** */

    CURSOR get_old_poous_cc_dtls_cur IS
      SELECT
           poo.cal_type,
           poo.location_cd,
           poo.attendance_mode,
           poo.attendance_type,
           poo.unit_set_cd,
           poo.us_version_number,
           poo.organization_unit,
           pcc.cost_centre,
           pcc.subject,
           pcc.proportion
      FROM IGS_HE_POOUS_OU_CC pcc,
           IGS_HE_POOUS_OU_ALL poo
      WHERE
           pcc.hesa_poous_ou_id = poo.hesa_poous_ou_id
      AND  poo.course_cd = p_old_course_cd
      AND  poo.crv_version_number = p_old_version_number;


    CURSOR get_new_poous_ou_id (cp_cal_type           igs_he_poous_ou.cal_type%TYPE,
                                cp_location_cd        igs_he_poous_ou.location_cd%TYPE,
                                cp_attendance_mode    igs_he_poous_ou.attendance_mode%TYPE,
                                cp_attendance_type    igs_he_poous_ou.attendance_type%TYPE,
                                cp_unit_set_cd        igs_he_poous_ou.unit_set_cd%TYPE,
                                cp_us_version_number  igs_he_poous_ou.us_version_number%TYPE,
                                cp_organization_unit  igs_he_poous_ou.organization_unit%TYPE) IS
      SELECT hesa_poous_ou_id
      FROM IGS_HE_POOUS_OU_ALL
      WHERE
           course_cd = p_new_course_cd
      AND  crv_version_number = p_new_version_number
      AND  cal_type = cp_cal_type
      AND  location_cd = cp_location_cd
      AND  attendance_mode = cp_attendance_mode
      AND  attendance_type = cp_attendance_type
      AND  unit_set_cd = cp_unit_set_cd
      AND  us_version_number = cp_us_version_number
      AND  organization_unit = cp_organization_unit;



     CURSOR get_new_poous_cc_dtls_cur (cp_poous_ou_id  igs_he_poous_ou_cc.hesa_poous_ou_id%TYPE,
                                       cp_cost_centre  igs_he_poous_ou_cc.cost_centre%TYPE,
                                       cp_subject      igs_he_poous_ou_cc.subject%TYPE) IS
       SELECT 'X'
       FROM IGS_HE_POOUS_OU_CC
       WHERE
            hesa_poous_ou_id = cp_poous_ou_id
       AND  cost_centre = cp_cost_centre
       AND  subject = cp_subject;

    l_new_poous_cc_dtls_rec  get_new_poous_cc_dtls_cur%ROWTYPE;
    l_new_poous_ou_id        igs_he_poous_ou_all.hesa_poous_ou_id%TYPE;

    x_rowid                  VARCHAR2(250);
    x_hesa_poous_cc_id       igs_he_poous_ou_cc.hesa_poous_cc_id%TYPE;

    BEGIN

      FOR l_old_poous_cc_dtls_rec IN get_old_poous_cc_dtls_cur
      LOOP

        OPEN get_new_poous_ou_id ( l_old_poous_cc_dtls_rec.cal_type,
                                   l_old_poous_cc_dtls_rec.location_cd,
                                   l_old_poous_cc_dtls_rec.attendance_mode,
                                   l_old_poous_cc_dtls_rec.attendance_type,
                                   l_old_poous_cc_dtls_rec.unit_set_cd,
                                   l_old_poous_cc_dtls_rec.us_version_number,
                                   l_old_poous_cc_dtls_rec.organization_unit);
        FETCH get_new_poous_ou_id INTO l_new_poous_ou_id;

        IF get_new_poous_ou_id%FOUND THEN

          OPEN get_new_poous_cc_dtls_cur(l_new_poous_ou_id, l_old_poous_cc_dtls_rec.cost_centre, l_old_poous_cc_dtls_rec.subject);
          FETCH get_new_poous_cc_dtls_cur INTO l_new_poous_cc_dtls_rec;
          IF get_new_poous_cc_dtls_cur%NOTFOUND THEN

            x_rowid := NULL;
            x_hesa_poous_cc_id := NULL;

            igs_he_poous_ou_cc_pkg.insert_row(
                X_ROWID               => x_rowid,
                X_HESA_POOUS_CC_ID    => x_hesa_poous_cc_id,
                X_HESA_POOUS_OU_ID    => l_new_poous_ou_id,
                X_COST_CENTRE         => l_old_poous_cc_dtls_rec.cost_centre,
                X_SUBJECT             => l_old_poous_cc_dtls_rec.subject,
                X_PROPORTION          => l_old_poous_cc_dtls_rec.proportion,
                X_MODE                => 'R');


          END IF;
          CLOSE get_new_poous_cc_dtls_cur;

        END IF;
        CLOSE get_new_poous_ou_id;

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        p_status := 2;
        IF(SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range) THEN
          p_message_name := cst_ret_message_name;
        ELSE
          app_exception.raise_exception;
        END IF;

    END create_poous_cc_rec;


    --Procedure inserts into IGS_HE_POOUS_OU_ALL table

    PROCEDURE cr_he_poo_ou_rec (p_new_course_cd         igs_he_poous_ou.course_cd%TYPE,
                            p_new_version_number        igs_he_poous_ou.crv_version_number%TYPE) IS

    BEGIN

        DECLARE

         v_pooou_seq_num igs_he_poous_ou.hesa_poous_ou_id%TYPE;


         CURSOR c_pooou_seq_num IS
          SELECT igs_he_poous_ou_all_s.NEXTVAL
          FROM dual;

         l_org_id NUMBER;
         x_rowid VARCHAR2(250);

       BEGIN

                OPEN c_pooou_seq_num;
                FETCH c_pooou_seq_num INTO v_pooou_seq_num;
                CLOSE c_pooou_seq_num;

                l_org_id := igs_ge_gen_003.get_org_id;
                x_rowid := NULL;


                igs_he_poous_ou_all_pkg.insert_row(
                  X_ROWID             => x_rowid,
                  X_HESA_POOUS_OU_ID  => v_pooou_seq_num,
                  X_ORG_ID            => l_org_id,
                  X_COURSE_CD         => p_new_course_cd,
                  X_CRV_VERSION_NUMBER=> p_new_version_number,
                  X_CAL_TYPE          => gv_hpo_old_rec.cal_type,
                  X_LOCATION_CD       => gv_hpo_old_rec.location_cd,
                  X_ATTENDANCE_MODE   => gv_hpo_old_rec.attendance_mode,
                  X_ATTENDANCE_TYPE   => gv_hpo_old_rec.attendance_type,
                  X_UNIT_SET_CD       => gv_hpo_old_rec.unit_set_cd,
                  X_US_VERSION_NUMBER => gv_hpo_old_rec.us_version_number,
                  X_ORGANIZATION_UNIT => gv_hpo_old_rec.organization_unit,
                  X_PROPORTION        => gv_hpo_old_rec.proportion,
                  X_MODE              => 'R');

       END;


    EXCEPTION
        WHEN OTHERS THEN
                p_status := 2;
                IF (SQLCODE >= cst_max_error_range AND SQLCODE <= cst_min_error_range)
                THEN
                        p_message_name := cst_ret_message_name;
                ELSE
                        app_exception.raise_exception;
                END IF;


    END cr_he_poo_ou_rec;


BEGIN

        p_status := 0;

        -- Check Parameter values passed in correctly

        IF p_old_course_cd is NULL OR
           p_old_version_number is NULL OR
           p_new_course_cd is NULL OR
           p_new_version_number is NULL
        THEN
           p_status := 2;
           p_message_name := 'IGS_HE_INV_PARAMS';
           RETURN;
        END IF;


        -- This checks to see if the specified old IGS_HE_ST_PROG record exists, and if so then need to copy,
        -- if does not exist in IGS_HE_ST_PROG for new course code and version then insert
        OPEN gc_hsp_old_rec;
        FETCH gc_hsp_old_rec into gv_hsp_old_rec;
        IF gc_hsp_old_rec%FOUND THEN
            OPEN gc_hsp_new_rec;
            FETCH gc_hsp_new_rec into gv_hsp_new_rec;
              IF gc_hsp_new_rec%NOTFOUND THEN
                 cr_he_st_pr_rec(p_new_course_cd,p_new_version_number);
              END IF;
            CLOSE gc_hsp_new_rec;
        END IF;
        CLOSE gc_hsp_old_rec;

        -- Call the local procedure to copy the Hesa Statistic Cost Center Details
        -- defined at Program Version Level
        create_prg_cc_rec(p_old_course_cd, p_old_version_number, p_new_course_cd, p_new_version_number );


        -- If IGS_HE_POOUS record does not already exist for new course code and version then call
        -- the procedure to insert IGS_HE_POOUS records
        OPEN gc_hpus_old_rec;
        LOOP
                FETCH gc_hpus_old_rec INTO gv_hpus_old_rec;
                EXIT WHEN gc_hpus_old_rec%NOTFOUND;
                OPEN gc_hpus_new_rec(
                                gv_hpus_old_rec.cal_type,
                                gv_hpus_old_rec.location_cd,
                                gv_hpus_old_rec.attendance_mode,
                                gv_hpus_old_rec.attendance_type,
                                gv_hpus_old_rec.unit_set_cd,
                                gv_hpus_old_rec.us_version_number);
                FETCH gc_hpus_new_rec INTO gv_hpus_new_rec;
                IF gc_hpus_new_rec%NOTFOUND THEN
                        cr_he_poo_us_rec(p_new_course_cd, p_new_version_number);
                END IF;
                CLOSE gc_hpus_new_rec;
         END LOOP;
         CLOSE gc_hpus_old_rec;


        -- if IGS_HE_POOUS_OU record does not exist for new course code and version then call the procedure to insert IGS_HE_POOUS_OU records

        OPEN gc_hpo_old_rec;
        LOOP
                 FETCH gc_hpo_old_rec INTO gv_hpo_old_rec;
                 EXIT WHEN gc_hpo_old_rec%NOTFOUND;
                 OPEN gc_hpo_new_rec(
                                     gv_hpo_old_rec.cal_type,
                                     gv_hpo_old_rec.location_cd,
                                     gv_hpo_old_rec.attendance_mode,
                                     gv_hpo_old_rec.attendance_type,
                                     gv_hpo_old_rec.unit_set_cd,
                                     gv_hpo_old_rec.us_version_number,
                                     gv_hpo_old_rec.organization_unit);
                 FETCH gc_hpo_new_rec INTO gv_hpo_new_rec;
                 IF gc_hpo_new_rec%NOTFOUND THEN
                      cr_he_poo_ou_rec(p_new_course_cd, p_new_version_number);
                 END IF;
                 CLOSE gc_hpo_new_rec;

        END LOOP;
        CLOSE gc_hpo_old_rec;

        -- Call the local procedure to copy the Hesa Statistic Cost Center Details
	-- defined at POOUS Level
	-- must be called AFTER POOUS_OU records have been updated!
        create_poous_cc_rec(p_old_course_cd, p_old_version_number, p_new_course_cd, p_new_version_number );

EXCEPTION

        WHEN OTHERS THEN
           p_status := 2;
           fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
           fnd_message.set_token('NAME','IGS_HE_PS.COPY_PROG_VERSION');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;


END copy_prog_version;


END igs_he_ps_pkg;


/
