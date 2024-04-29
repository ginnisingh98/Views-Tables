--------------------------------------------------------
--  DDL for Package Body IGS_EN_PLAN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_PLAN_UTILS" AS
/* $Header: IGSEN94B.pls 120.12 2006/08/24 10:20:04 bdeviset noship $ */

 --Procedure to check whether the student has core override for a section.
 FUNCTION check_core_override(  p_person_id          IN  NUMBER,
                                p_course_cd          IN  VARCHAR2,
                                p_uoo_id             IN  NUMBER,
                                p_term_cal           IN  VARCHAR2,
                                p_term_seq_num       IN  NUMBER) RETURN BOOLEAN AS
    l_deny_warn VARCHAR2(10);  --DENY / WARN Flag
 BEGIN
    -- Call the procedure to evaluate core unit drop
    IF igs_en_gen_015.eval_core_unit_drop (p_person_id                => p_person_id,
                                           p_course_cd                => p_course_cd,
                                           p_uoo_id                   => p_uoo_id,
                                           p_step_type                => 'DROP_CORE',
                                           p_term_cal                 => p_term_cal,
                                           p_term_sequence_number     => p_term_seq_num,
                                           p_deny_warn                => l_deny_warn,
					   p_enr_method		      => null) = 'TRUE' THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
 END check_core_override;

PROCEDURE add_units_to_plan(p_person_id IN NUMBER,
                p_course_cd IN VARCHAR2,
                p_load_cal_type IN VARCHAR2,
                p_load_sequence_number IN NUMBER,
                p_uoo_ids IN VARCHAR2,
                p_return_status OUT NOCOPY VARCHAR2,
                p_message_name OUT NOCOPY VARCHAR2,
                p_ss_session_id IN NUMBER) AS

       CURSOR c_get_unitSection(cp_uooid IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
       SELECT unit_cd || '/' || unit_class
       FROM   IGS_PS_UNIT_OFR_OPT
       WHERE  uoo_id = cp_uooid;

       l_strtpoint NUMBER;
       l_endpoint  NUMBER;
       l_cindex    NUMBER;
       l_pre_cindex NUMBER;
       l_nth_occurence NUMBER;

       l_uooid_audit_sep_index   NUMBER;
       l_audit_gscd_sep_index    NUMBER;
       l_gscd_gsver_sep_index    NUMBER;
       l_gsver_credits_sep_index NUMBER;
       l_credits_poo_index       NUMBER;

       l_unitcd VARCHAR2(200);
       l_uooid  NUMBER;
       l_audit  VARCHAR2(1);
       l_grading_code VARCHAR2(100);
       l_grading_version NUMBER;
       l_credits  NUMBER;
       l_unit_dtls_to_be_added VARCHAR2(3000);
       l_uooid_audit_gscd_gsver_crdts VARCHAR2(3000);

       l_sup_uooid NUMBER;

       l_enc_message_name VARCHAR2(2000);
       l_app_short_name VARCHAR2(10);
       l_message_name VARCHAR2(100);
       l_mesg_txt VARCHAR2(4000);
       l_msg_index NUMBER;
       l_row_id   VARCHAR2(1000);
       cst_error   CONSTANT VARCHAR2(5) := 'E';



BEGIN

        igs_en_add_units_api.g_ss_session_id := p_ss_session_id;

        l_strtpoint      :=  0;
        l_pre_cindex     :=  0;
        l_nth_occurence  :=  1;
        l_unit_dtls_to_be_added := p_uoo_ids;
        l_cindex := INSTR(l_unit_dtls_to_be_added,';',1,l_nth_occurence);

         WHILE (l_cindex <> 0 )  LOOP


              l_strtpoint  :=  l_pre_cindex + 1;
              l_endpoint   :=  l_cindex - l_strtpoint;
              l_pre_cindex :=  l_cindex;
              l_uooid_audit_gscd_gsver_crdts  := substr(l_unit_dtls_to_be_added,l_strtpoint,l_endpoint);

              l_uooid_audit_sep_index     := INSTR(l_uooid_audit_gscd_gsver_crdts,',',1);
              l_audit_gscd_sep_index      := INSTR(l_uooid_audit_gscd_gsver_crdts,',',1,2);
              l_gscd_gsver_sep_index      := INSTR(l_uooid_audit_gscd_gsver_crdts,',',1,3);
              l_gsver_credits_sep_index   := INSTR(l_uooid_audit_gscd_gsver_crdts,',',1,4);
	      l_credits_poo_index         := INSTR(l_uooid_audit_gscd_gsver_crdts,',',1,5);

              l_uooid           :=   TO_NUMBER(SUBSTR(l_uooid_audit_gscd_gsver_crdts,1,l_uooid_audit_sep_index - 1));
              l_audit           :=   SUBSTR(l_uooid_audit_gscd_gsver_crdts,l_uooid_audit_sep_index+1,l_audit_gscd_sep_index -(l_uooid_audit_sep_index+1));
              l_grading_code    :=   SUBSTR(l_uooid_audit_gscd_gsver_crdts,l_audit_gscd_sep_index + 1,l_gscd_gsver_sep_index - (l_audit_gscd_sep_index+1));
              l_grading_version :=   TO_NUMBER(SUBSTR(l_uooid_audit_gscd_gsver_crdts,l_gscd_gsver_sep_index + 1,l_gsver_credits_sep_index - (l_gscd_gsver_sep_index+1)));
              IF l_credits_poo_index = 0 THEN
                l_credits :=   TO_NUMBER(SUBSTR(l_uooid_audit_gscd_gsver_crdts,l_gsver_credits_sep_index + 1));
              ELSE
               l_credits :=    TO_NUMBER(SUBSTR(l_uooid_audit_gscd_gsver_crdts,l_gsver_credits_sep_index + 1,l_credits_poo_index - (l_gsver_credits_sep_index+1)));
              END IF;

              OPEN c_get_unitSection(l_uooid);
              FETCH c_get_unitSection INTO l_unitcd;
              CLOSE c_get_unitSection;

            BEGIN
              IGS_EN_PLAN_UNITS_PKG.INSERT_ROW(
                 x_rowid                     => l_row_id,
                 x_person_id                 => p_person_id,
                 x_course_cd                 => p_course_cd,
                 x_uoo_id                    => l_uooid,
                 x_term_cal_type             => p_load_cal_type,
                 x_term_ci_sequence_number   => p_load_sequence_number,
                 x_no_assessment_ind         => l_audit,
                 x_sup_uoo_id                => NULL,
                 x_override_enrolled_cp      => l_credits,
                 x_grading_schema_code       => l_grading_code,
                 x_gs_version_number         => l_grading_version,
                 x_core_indicator_code       => NULL,
                 x_alternative_title         => NULL,
                 x_cart_error_flag           => 'N',
                 x_session_id                => igs_en_add_units_api.g_ss_session_id,
                 x_mode                      => 'R');
            EXCEPTION
                WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
                     IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                     FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
                     IF l_message_name  = 'IGS_GE_RECORD_ALREADY_EXISTS' THEN
                        IF p_message_name IS NOT NULL THEN
                           p_message_name := p_message_name || ';';
                        END IF;
                        p_message_name  := p_message_name || 'IGS_EN_PLAN_RECORD_EXISTS'||'*'||l_unitcd;
                        p_return_status := 'FALSE';
                     ELSE
                        RAISE;
                     END IF;
            END;

            l_nth_occurence := l_nth_occurence + 1;
            l_cindex := INSTR(l_unit_dtls_to_be_added,';',1,l_nth_occurence);

         END LOOP;

         igs_en_add_units_api.g_ss_session_id := NULL;

EXCEPTION
    WHEN OTHERS THEN
              igs_en_add_units_api.g_ss_session_id := NULL;
              p_message_name  := 'IGS_GE_UNHANDLED_EXP';
              p_return_status := 'FALSE';
              RAISE;
END add_units_to_plan;

PROCEDURE update_spa_terms_plan_sht_flag(
            P_PERSON_ID IN NUMBER,
            P_COURSE_CD IN VARCHAR2,
            P_TERM_CAL_TYPE IN VARCHAR2,
            P_TERM_SEQUENCE_NUMBER IN NUMBER,
            P_PLAN_SHT_FLAG IN VARCHAR2
            ) AS
------------------------------------------------------------------
  --Created by  : ctyagi, Oracle IDC
  --Date created: 18-JULY-2005
  --
  --Purpose: update plan_sht_status column of igs_en_spa_terms.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

CURSOR select_rec IS
   SELECT   spt.rowid,spt.*
   FROM     igs_en_spa_terms spt
   WHERE PERSON_ID=P_PERSON_ID
   AND   PROGRAM_CD=P_COURSE_CD
   AND   TERM_CAL_TYPE=P_TERM_CAL_TYPE
   AND   TERM_SEQUENCE_NUMBER=P_TERM_SEQUENCE_NUMBER;

old_references select_rec%ROWTYPE;




    l_message_name VARCHAR2(2000);
    l_plan_sht_status igs_en_spa_terms.plan_sht_status%TYPE;

BEGIN
      OPEN  select_rec ;
      FETCH select_rec INTO old_references;

      IF select_rec%NOTFOUND THEN
        IF P_PLAN_SHT_FLAG = 'SKIP' THEN

            IF p_person_id IS NOT NULL THEN
               -- Call the API to Create/Update the term record.
               igs_en_spa_terms_api.create_update_term_rec(p_person_id => P_PERSON_ID,
                                                          p_program_cd => P_COURSE_CD,
                                                          p_term_cal_type => P_TERM_CAL_TYPE,
                                                          p_term_sequence_number => P_TERM_SEQUENCE_NUMBER,
														  p_plan_sht_status => 'PLAN',
                                                          p_ripple_frwrd => FALSE,
                                                          p_message_name => l_message_name,
                                                          p_update_rec => TRUE);
            END IF;

        END IF; -- if condition of Plan sheet flag as 'SKIP'

      END IF ; -- if condition of terms record exists.
      ClOSE select_rec;

      OPEN  select_rec ;
      FETCH select_rec INTO old_references;
      IF select_rec%FOUND THEN
        igs_en_spa_terms_pkg.update_row(x_rowid               => old_references.rowid ,
                                        x_term_record_id      => old_references.term_record_id,
                                        x_person_id           => old_references.person_id,
                                        x_program_cd          => old_references.program_cd,
                                        x_program_version     => old_references.program_version,
                                        x_acad_cal_type       => old_references.acad_cal_type,
                                        x_term_cal_type       => old_references.term_cal_type ,
                                        x_term_sequence_number => old_references.term_sequence_number,
                                        x_key_program_flag    => old_references.key_program_flag,
                                        x_location_cd         => old_references.location_cd,
                                        x_attendance_mode     => old_references.attendance_mode,
                                        x_attendance_type     => old_references.attendance_type,
                                        x_fee_cat             => old_references.fee_cat,
                                        x_coo_id              => old_references.coo_id,
                                        x_class_standing_id   => old_references.class_standing_id,
                                        x_attribute_category  => old_references.attribute_category,
                                        x_attribute1          => old_references.attribute1,
                                        x_attribute2          => old_references.attribute2 ,
                                        x_attribute3          => old_references.attribute3,
                                        x_attribute4          => old_references.attribute4,
                                        x_attribute5          => old_references.attribute5,
                                        x_attribute6          => old_references.attribute6,
                                        x_attribute7          => old_references.attribute7,
                                        x_attribute8          => old_references.attribute8,
                                        x_attribute9          => old_references.attribute9,
                                        x_attribute10         => old_references.attribute10,
                                        x_attribute11         => old_references.attribute11,
                                        x_attribute12         => old_references.attribute12,
                                        x_attribute13         => old_references.attribute13,
                                        x_attribute14         => old_references.attribute14 ,
                                        x_attribute15         => old_references.attribute15,
                                        x_attribute16         => old_references.attribute16,
                                        x_attribute17         => old_references.attribute17,
                                        x_attribute18         => old_references.attribute18,
                                        x_attribute19         => old_references.attribute19,
                                        x_attribute20         => old_references.attribute20,
                                        x_mode                => 'R',
                                        x_plan_sht_status     => P_PLAN_SHT_FLAG
                                        );
      END IF;
      ClOSE select_rec;

END update_spa_terms_plan_sht_flag;


PROCEDURE update_plansheet_unitdetails(
           P_PERSON_ID IN NUMBER,
           P_COURSE_CD IN VARCHAR2,
           P_UOOID IN NUMBER,
           P_CARTFLAG IN VARCHAR2,
           P_SOURCEFLAG IN VARCHAR2,
           P_FIELDNAME IN VARCHAR2,
           P_auditVAL  IN VARCHAR2,
           P_creditVAL  IN NUMBER,
           P_gradingVAL  IN VARCHAR2
           ) AS

------------------------------------------------------------------
  --Created by  : ctyagi, Oracle IDC
  --Date created: 18-JULY-2005
  --
  --Purpose: update plannig sheet unitdetails .
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

cursor select_sua is
select sua.rowid,sua.* from IGS_EN_SU_ATTEMPT  sua where
PERSON_ID=P_PERSON_ID AND
COURSE_CD=P_COURSE_CD AND
UOO_ID=P_UOOID ;

cursor select_plan is
select plan.rowid,plan.* from igs_en_plan_units  plan where
PERSON_ID=P_PERSON_ID AND
COURSE_CD=P_COURSE_CD AND
UOO_ID=P_UOOID AND
CART_ERROR_FLAG=P_CARTFLAG ;

old_refsua  select_sua%ROWTYPE;
old_refplan select_plan%ROWTYPE;

l_gradingcode IGS_EN_SU_ATTEMPT.GRADING_SCHEMA_CODE%TYPE;
l_gradingver  IGS_EN_SU_ATTEMPT.GS_VERSION_NUMBER%TYPE;
l_enrolled_cp IGS_EN_SU_ATTEMPT.OVERRIDE_ENROLLED_CP%TYPE;
l_no_assessment_ind IGS_EN_SU_ATTEMPT.NO_ASSESSMENT_IND%TYPE;

    -- Internal Procedure to update the Planning Sheet record.
    PROCEDURE update_plan( p_grd_schm_cd IN VARCHAR2,
                           p_gs_ver IN NUMBER,
                           p_audit IN VARCHAR2,
                           p_credit IN NUMBER,
                           p_old_refplan select_plan%ROWTYPE) IS
    BEGIN
       igs_en_plan_units_pkg.update_row(
        x_rowid                    => p_old_refplan.rowid,
        x_person_id                => p_old_refplan.person_id ,
        x_course_cd                => p_old_refplan.course_cd,
        x_uoo_id                   => p_old_refplan.uoo_id,
        x_term_cal_type            => p_old_refplan.term_cal_type,
        x_term_ci_sequence_number  => p_old_refplan.term_ci_sequence_number,
        x_no_assessment_ind        => p_audit,
        x_sup_uoo_id               => p_old_refplan.sup_uoo_id,
        x_override_enrolled_cp     => p_credit,
        x_grading_schema_code      => p_grd_schm_cd,
        x_gs_version_number        => p_gs_ver,
        x_core_indicator_code      => p_old_refplan.core_indicator_code,
        x_alternative_title        => p_old_refplan.alternative_title,
        x_cart_error_flag          => p_old_refplan.cart_error_flag,
        x_session_id              => p_old_refplan.session_id,
        x_mode                     => 'R'
       );
    END update_plan;

    -- Internal procedure to update the sua record.
    PROCEDURE update_sua ( p_grd_schm_cd IN VARCHAR2,
                           p_gs_ver IN NUMBER,
                           p_audit IN VARCHAR2,
                           p_credit IN NUMBER,
                           p_old_refsua select_sua%ROWTYPE) IS
    BEGIN
       igs_en_su_attempt_pkg.UPDATE_ROW(
             X_ROWID              => p_old_refsua.rowid,
             X_PERSON_ID          => p_old_refsua.PERSON_ID,
             X_COURSE_CD          => p_old_refsua.COURSE_CD,
             X_UNIT_CD            => p_old_refsua.UNIT_CD,
             X_CAL_TYPE           => p_old_refsua.CAL_TYPE,
             X_CI_SEQUENCE_NUMBER => p_old_refsua.CI_SEQUENCE_NUMBER,
             X_VERSION_NUMBER     => p_old_refsua.VERSION_NUMBER,
             X_LOCATION_CD        => p_old_refsua.LOCATION_CD,
             X_UNIT_CLASS         => p_old_refsua.UNIT_CLASS,
             X_CI_START_DT        => p_old_refsua.CI_START_DT,
             X_CI_END_DT          => p_old_refsua.CI_END_DT,
             X_UOO_ID             => p_old_refsua.UOO_ID,
             X_ENROLLED_DT        => p_old_refsua.ENROLLED_DT,
             X_UNIT_ATTEMPT_STATUS => p_old_refsua.UNIT_ATTEMPT_STATUS,
             X_ADMINISTRATIVE_UNIT_STATUS => p_old_refsua.ADMINISTRATIVE_UNIT_STATUS,
             X_DISCONTINUED_DT     => p_old_refsua.DISCONTINUED_DT,
             X_RULE_WAIVED_DT      => p_old_refsua.RULE_WAIVED_DT,
             X_RULE_WAIVED_PERSON_ID => p_old_refsua.RULE_WAIVED_PERSON_ID,
             X_NO_ASSESSMENT_IND   => p_audit,
             X_SUP_UNIT_CD         => p_old_refsua.SUP_UNIT_CD,
             X_SUP_VERSION_NUMBER  => p_old_refsua.SUP_VERSION_NUMBER,
             X_EXAM_LOCATION_CD    => p_old_refsua.EXAM_LOCATION_CD,
             X_ALTERNATIVE_TITLE   => p_old_refsua.ALTERNATIVE_TITLE,
             X_OVERRIDE_ENROLLED_CP => p_credit,
             X_OVERRIDE_EFTSU      => p_old_refsua.OVERRIDE_EFTSU,
             X_OVERRIDE_ACHIEVABLE_CP => p_old_refsua.OVERRIDE_ACHIEVABLE_CP,
             X_OVERRIDE_OUTCOME_DUE_DT => p_old_refsua.OVERRIDE_OUTCOME_DUE_DT,
             X_OVERRIDE_CREDIT_REASON => p_old_refsua.OVERRIDE_CREDIT_REASON,
             X_ADMINISTRATIVE_PRIORITY => p_old_refsua.ADMINISTRATIVE_PRIORITY,
             X_WAITLIST_DT          => p_old_refsua.WAITLIST_DT,
             x_dcnt_reason_cd       => p_old_refsua.dcnt_reason_cd,
             X_MODE                  => 'R',
             X_GS_VERSION_NUMBER     => p_gs_ver,
             X_ENR_METHOD_TYPE       => p_old_refsua.ENR_METHOD_TYPE,
             X_FAILED_UNIT_RULE      => p_old_refsua.FAILED_UNIT_RULE,
             X_CART                  => p_old_refsua.CART,
             X_RSV_SEAT_EXT_ID       => p_old_refsua.RSV_SEAT_EXT_ID,
             X_ORG_UNIT_CD           => p_old_refsua.ORG_UNIT_CD,
             X_GRADING_SCHEMA_CODE   => p_grd_schm_cd,
             x_subtitle              => p_old_refsua.subtitle,
             x_session_id            => p_old_refsua.session_id,
             x_deg_aud_detail_id     => p_old_refsua.deg_aud_detail_id,
             x_student_career_transcript        =>   p_old_refsua.student_career_transcript,
             x_student_career_statistics        => p_old_refsua.student_career_statistics,
             x_waitlist_manual_ind              => p_old_refsua.waitlist_manual_ind,
             X_ATTRIBUTE_CATEGORY     => p_old_refsua.ATTRIBUTE_CATEGORY,
             X_ATTRIBUTE1            => p_old_refsua.ATTRIBUTE1,
             X_ATTRIBUTE2             => p_old_refsua.ATTRIBUTE2,
             X_ATTRIBUTE3             => p_old_refsua.ATTRIBUTE3,
             X_ATTRIBUTE4            => p_old_refsua.ATTRIBUTE4,
             X_ATTRIBUTE5            => p_old_refsua.ATTRIBUTE5,
             X_ATTRIBUTE6            => p_old_refsua.ATTRIBUTE6,
             X_ATTRIBUTE7            => p_old_refsua.ATTRIBUTE7,
             X_ATTRIBUTE8            => p_old_refsua.ATTRIBUTE8,
             X_ATTRIBUTE9            => p_old_refsua.ATTRIBUTE9,
             X_ATTRIBUTE10           => p_old_refsua.ATTRIBUTE10,
             X_ATTRIBUTE11           => p_old_refsua.ATTRIBUTE11,
             X_ATTRIBUTE12           => p_old_refsua.ATTRIBUTE12,
             X_ATTRIBUTE13           => p_old_refsua.ATTRIBUTE13,
             X_ATTRIBUTE14           => p_old_refsua.ATTRIBUTE14,
             X_ATTRIBUTE15           => p_old_refsua.ATTRIBUTE15,
             X_ATTRIBUTE16           => p_old_refsua.ATTRIBUTE16,
             X_ATTRIBUTE17           => p_old_refsua.ATTRIBUTE17,
             X_ATTRIBUTE18           => p_old_refsua.ATTRIBUTE18,
             X_ATTRIBUTE19           => p_old_refsua.ATTRIBUTE19,
             x_ATTRIBUTE20           => p_old_refsua.ATTRIBUTE20,
             X_WLST_PRIORITY_WEIGHT_NUM  => p_old_refsua.WLST_PRIORITY_WEIGHT_NUM,
             X_WLST_PREFERENCE_WEIGHT_NUM  => p_old_refsua.WLST_PREFERENCE_WEIGHT_NUM,
             X_CORE_INDICATOR_CODE    => p_old_refsua.CORE_INDICATOR_CODE,
             X_UPD_AUDIT_FLAG      => p_old_refsua.UPD_AUDIT_FLAG,
             X_SS_SOURCE_IND       => p_old_refsua.SS_SOURCE_IND
            );
    END update_sua;

BEGIN

   -- if the SUA record is getting updated.
   IF P_SOURCEFLAG = 'SUA' THEN

      OPEN  select_sua;
      FETCH select_sua INTO old_refsua;
      IF select_sua%FOUND THEN
         IF P_FIELDNAME = 'GRADING' THEN
            l_gradingcode:=substr(P_gradingVAL, 0,instr(P_gradingVAL,  ',')-1);
            l_gradingver:=to_number(substr(P_gradingVAL,instr(P_gradingVAL,  ',')+1,length(P_gradingVAL)));
            l_enrolled_cp := old_refsua.override_enrolled_cp;
            l_no_assessment_ind := old_refsua.no_assessment_ind;
         ELSIF P_FIELDNAME = 'AUDIT' THEN
            l_gradingcode := old_refsua.grading_schema_code;
            l_gradingver := old_refsua.gs_version_number;
            l_enrolled_cp := P_creditVAL;
            l_no_assessment_ind := P_auditVAL;
         ELSIF P_FIELDNAME = 'VARIABLECREDIT' THEN
            l_gradingcode := old_refsua.grading_schema_code;
            l_gradingver := old_refsua.gs_version_number;
            l_enrolled_cp := P_creditVAL;
            l_no_assessment_ind := old_refsua.no_assessment_ind;
         END IF;

	 update_sua ( p_grd_schm_cd  => l_gradingcode,
                      p_gs_ver => l_gradingver,
                      p_audit => l_no_assessment_ind,
                      p_credit => l_enrolled_cp,
                      p_old_refsua =>old_refsua);

      END IF;  -- Sua Exists
      CLOSE select_sua;

   ELSIF P_SOURCEFLAG ='PLAN' THEN  -- if the planning sheet record is getting updated.

      OPEN select_plan;
      FETCH select_plan INTO old_refplan;
      IF select_plan%found THEN
         IF P_FIELDNAME = 'GRADING' THEN
            l_gradingcode:=substr(P_gradingVAL, 0,instr(P_gradingVAL,  ',')-1);
            l_gradingver:=to_number(substr(P_gradingVAL,instr(P_gradingVAL,  ',')+1,length(P_gradingVAL)));
            l_enrolled_cp := old_refplan.override_enrolled_cp;
            l_no_assessment_ind := old_refplan.no_assessment_ind;
         ELSIF P_FIELDNAME = 'AUDIT' THEN
            l_gradingcode := old_refplan.grading_schema_code;
            l_gradingver := old_refplan.gs_version_number;
            l_enrolled_cp := P_creditVAL;
            l_no_assessment_ind := P_auditVAL;
         ELSIF P_FIELDNAME = 'VARIABLECREDIT' THEN
            l_gradingcode := old_refplan.grading_schema_code;
            l_gradingver := old_refplan.gs_version_number;
            l_enrolled_cp := P_creditVAL;
            l_no_assessment_ind := old_refplan.no_assessment_ind;
         END IF;
         update_plan( p_grd_schm_cd => l_gradingcode,
                      p_gs_ver => l_gradingver,
                      p_audit => l_no_assessment_ind,
                      p_credit => l_enrolled_cp,
                      p_old_refplan =>old_refplan);

      END IF; -- if plan exists
      CLOSE select_plan;

   END IF;

END update_plansheet_unitdetails;


PROCEDURE delete_plansheet_unit(
           p_person_id IN NUMBER,
           p_course_cd IN VARCHAR2,
           p_uooid IN NUMBER,
           p_cartflag IN VARCHAR2,
           p_return_status OUT NOCOPY VARCHAR2,
           p_message_name OUT  NOCOPY VARCHAR2
           ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
------------------------------------------------------------------
  --Created by  : ctyagi, Oracle IDC
  --Date created: 18-JULY-2005
  --
  --Purpose: delete record from igs_en_plan_units .
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
     CURSOR cur_plan_unit IS
            SELECT pl.rowid, pl.term_cal_type, pl.term_ci_sequence_number,pl.uoo_id, pl.core_indicator_code, pl.sup_uoo_id
            FROM igs_en_plan_units pl
            WHERE pl.person_id = p_person_id
            AND   pl.course_cd = p_course_cd
            AND   pl.cart_error_flag = P_CARTFLAG
            AND  (pl.uoo_id    = P_UOOID
                  OR ( EXISTS ( SELECT 'X'
                          FROM IGS_PS_UNIT_OFR_OPT UOO
                           WHERE UOO.SUP_UOO_ID = P_UOOID
                               AND UOO.RELATION_TYPE = 'SUBORDINATE'
                              AND UOO.UOO_ID = pl.UOO_ID)
                                )
                        )
                   ORDER BY pl.SUP_Uoo_id;

     cur_plan_unit_rec cur_plan_unit%ROWTYPE;

     CURSOR c_usec_dtls(cp_n_uoo_id IN NUMBER) IS
     SELECT unit_cd || '/' || unit_class UnitSection
     FROM   igs_ps_unit_ofr_opt_all
     WHERE  uoo_id = cp_n_uoo_id;

     CURSOR cur_permission_unit(cp_uoo_id IN NUMBER) IS
            SELECT spl.spl_perm_request_id
            FROM igs_en_spl_perm spl
            WHERE   spl.student_person_id= p_person_id
            AND      spl.uoo_id = cp_uoo_id
            AND    spl.transaction_type <> 'WITHDRAWN';

     cur_permission_unit_rec cur_permission_unit%ROWTYPE;
     l_enc_message_name VARCHAR2(2000);
     l_app_short_name VARCHAR2(10);
     l_msg_index NUMBER;
     rec_usec_dtls c_usec_dtls%ROWTYPE;

BEGIN
     -- Loop through the records.
      FOR cur_plan_unit_rec IN cur_plan_unit  LOOP
        -- imp bmerugu this if is always false as core indicator flag for planning sheet is not being populated, core indicator column added for the future use.
	-- this if block code never executes.
        -- if the unit section is core unit.
        IF cur_plan_unit_rec.core_indicator_code = 'CORE' THEN
           -- if the student does not have override to drop then.
           IF NOT check_core_override( p_person_id       => p_person_id,
                                       p_course_cd       => p_course_cd,
                                       p_uoo_id          => cur_plan_unit_rec.uoo_id,
                                       p_term_cal        => cur_plan_unit_rec.term_cal_type,
                                       p_term_seq_num    => cur_plan_unit_rec.term_ci_sequence_number ) THEN
              -- if the unit section is normal or superior unit section then.
              IF cur_plan_unit_rec.sup_uoo_id IS NULL THEN
                 fnd_message.set_name('IGS','IGS_EN_SS_SWP_DEL_CORE_FAIL');
                 OPEN c_usec_dtls (cur_plan_unit_rec.uoo_id);
                 FETCH c_usec_dtls INTO rec_usec_dtls;
                 CLOSE c_usec_dtls;
                 fnd_message.set_token('UNIT_CD',rec_usec_dtls.UnitSection);
              ELSE
                 -- if the unit section is sub ordinate unit section, it is also core and student does not have override to drop the core unit.
                 fnd_message.set_name('IGS','IGS_EN_SS_SWP_SUB_CORE_FAIL');

                 OPEN c_usec_dtls (cur_plan_unit_rec.sup_uoo_id);
                 FETCH c_usec_dtls INTO rec_usec_dtls;
                 CLOSE c_usec_dtls;
                 fnd_message.set_token('SUP_UNIT_CD',rec_usec_dtls.UnitSection);

                 OPEN c_usec_dtls (cur_plan_unit_rec.uoo_id);
                 FETCH c_usec_dtls INTO rec_usec_dtls;
                 CLOSE c_usec_dtls;
                 fnd_message.set_token('SUB_UNIT_CD',rec_usec_dtls.UnitSection);

              END IF;

              p_message_name := fnd_message.get;
              p_return_status := 'FALSE';
              EXIT;
           END IF;
        END IF;

        --call the TBH for the planning sheet to delete the unit
        --by passing the rowid
        igs_en_plan_units_pkg.delete_row (x_rowid => cur_plan_unit_rec.rowid);

            --call drop_permission_unit to drop the permission unit

        FOR cur_permission_unit_rec IN cur_permission_unit(cur_plan_unit_rec.uoo_id)  LOOP
            igs_ss_en_wrappers.remove_permission_unit(cur_permission_unit_rec.spl_perm_request_id,cur_plan_unit_rec.term_cal_type,cur_plan_unit_rec.term_ci_sequence_number, p_course_cd);
        END LOOP;
         fnd_message.set_name('IGS','IGS_EN_SS_SWP_DEL_SUCCESS');

      END LOOP;
      IF p_return_status = 'FALSE' THEN
         ROLLBACK;
      ELSE

         p_return_status := 'TRUE';   -- Successfully dropped the unit section/s
         p_message_name:= fnd_message.get;
         COMMIT;
      END IF;

EXCEPTION
        WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
             ROLLBACK;
             IF cur_plan_unit%ISOPEN THEN
                CLOSE cur_plan_unit;
             END IF;
             --set the p_message out parameter
             IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
             FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,p_message_name);
             p_return_status := 'DENY';
        WHEN OTHERS THEN
             ROLLBACK;
             p_message_name :='IGS_GE_UNHANDLED_EXCEPTION';
             p_return_status := 'DENY';

END delete_plansheet_unit;

PROCEDURE delete_sua_from_plan(
           p_person_id IN NUMBER,
           p_course_cd IN VARCHAR2,
           p_uoo_id  IN NUMBER,
           p_tch_cal IN VARCHAR2,
           p_tch_seq IN NUMBER,
           p_term_cal IN VARCHAR2,
           p_term_seq_num IN NUMBER,
           p_core  IN VARCHAR2,
           p_return_status OUT NOCOPY VARCHAR2,
           p_message_name OUT NOCOPY VARCHAR2
           )AS
------------------------------------------------------------------
  --Created by  : ctyagi, Oracle IDC
  --Date created: 18-JULY-2005
  --
  --Purpose: delete sua record from planning sheet.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

     CURSOR c_multiple_load(cp_cal_type IN VARCHAR2,
                            cp_seq_num  IN NUMBER ) IS
       SELECT COUNT(*)
       FROM igs_ca_teach_to_load_v
       WHERE teach_cal_type = cp_cal_type
       AND teach_ci_sequence_number = cp_seq_num
       AND rownum < 3;
       l_deny_warn igs_en_cpd_ext.notification_flag%TYPE;
       l_counter NUMBER;
       l_ret_all_uoo_ids VARCHAR2(100);
       l_ret_sub_uoo_ids VARCHAR2(100);
       l_ret_nonsub_uoo_ids VARCHAR2(100);


      FUNCTION eval_plan_core (  p_person_id IN NUMBER,
                                 p_course_cd IN VARCHAR2,
                                 p_uoo_id IN NUMBER,
                                 p_term_cal IN VARCHAR2,
                                 p_term_seq_num IN NUMBER,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_message_name OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

          l_person_type                 igs_pe_person_types.person_type_code%TYPE;
          l_enrollment_category         igs_en_cat_prc_step.enrolment_cat%TYPE;
          l_comm_type                   igs_en_cat_prc_step.s_student_comm_type%TYPE;
          l_enr_method_type             igs_en_cat_prc_step.enr_method_type%TYPE;
          l_acad_cal_type               igs_ca_inst.cal_type%TYPE;
          l_acad_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
          l_step_override_limit         NUMBER;
          l_message                     VARCHAR2(100);
          l_ret_status                  VARCHAR2(10);
          l_en_cal_type                 igs_ca_inst.cal_type%TYPE;
          l_en_ci_seq_num               igs_ca_inst.sequence_number%TYPE;
          l_dummy                       VARCHAR2(200);

        BEGIN
          IF NVL(fnd_profile.value('IGS_EN_CORE_VAL'),'N') = 'N' THEN
             RETURN 'TRUE';
          END IF;

          --  Get the person type
          l_person_type := igs_en_gen_008.enrp_get_person_type(p_course_cd);

          --  Get the superior academic calendar instance
          igs_en_gen_015.get_academic_cal
          (
           p_person_id,
           p_course_cd,
           l_acad_cal_type,
           l_acad_ci_sequence_number,
           p_message_name,
           SYSDATE
          );

          --  Get the enrollment category and commencement type
          l_enrollment_category:=igs_en_gen_003.enrp_get_enr_cat(
                                                                p_person_id,
                                                                p_course_cd,
                                                                l_acad_cal_type,
                                                                l_acad_ci_sequence_number,
                                                                NULL,
                                                                l_en_cal_type,
                                                                l_en_ci_seq_num,
                                                                l_comm_type,
                                                                l_dummy);

          --- Get the enrollment method
          igs_en_gen_017.enrp_get_enr_method(l_enr_method_type,p_message_name,l_ret_status);

          -- Get the value of Deny/Warn Flag for unit step 'DROP_CORE'
          l_deny_warn := igs_ss_enr_details.get_notification(
                              p_person_type            => l_person_type,
                              p_enrollment_category    => l_enrollment_category,
                              p_comm_type              => l_comm_type,
                              p_enr_method_type        => l_enr_method_type,
                              p_step_group_type        => 'UNIT',
                              p_step_type              => 'DROP_CORE',
                              p_person_id              => p_person_id,
                              p_message                => p_message_name
                              ) ;

          -- If the unit step is not defined return TRUE
          IF l_deny_warn IS NULL OR l_deny_warn ='W' OR l_deny_warn = 'WARN' THEN
             RETURN 'TRUE';
          END IF;

          --  If the unit is not a Core Unit, return TRUE. If the unit is a
          --  core unit and the unit step DROP_CORE is overridden for the
          --  student in context, return TRUE else return FALSE.
          IF igs_en_gen_015.validation_step_is_overridden
                           (
                            'DROP_CORE',
                            p_term_cal,
                            p_term_seq_num,
                            p_person_id,
                            p_uoo_id,
                            l_step_override_limit
                            )
          THEN
            RETURN 'TRUE';
          ELSE
            RETURN 'FALSE';
          END IF;

      END eval_plan_core;

   BEGIN

     OPEN c_multiple_load(p_tch_cal,p_tch_seq);
     FETCH c_multiple_load INTO l_counter;
     CLOSE c_multiple_load;
     IF NVL(l_counter,0) >1 THEN
       p_return_status := 'FALSE';
       p_message_name :='IGS_EN_CANT_DROP_PLS';
       RETURN;
     END IF;

     IF p_core = 'CORE' THEN
        IF eval_plan_core (  p_person_id      => p_person_id,
                             p_course_cd      => p_course_cd,
                             p_uoo_id          => p_uoo_id,
                             p_term_cal       => p_term_cal,
                             p_term_seq_num   => p_term_seq_num,
                             p_return_status  => p_return_status,
                             p_message_name   => p_message_name) = 'FALSE' THEN
           p_return_status := 'FALSE';
           p_message_name := 'IGS_EN_SS_SWP_DEL_CORE_FAIL';
           RETURN;
        END IF;
     END IF;

     igs_ss_en_wrappers.enrp_chk_del_sub_units(p_person_id => p_person_id ,
                                               p_course_cd => p_course_cd,
                                               p_load_cal_type => p_term_cal,
                                               p_load_ci_seq_num => p_term_seq_num,
                                               p_selected_uoo_ids => p_uoo_id,
                                               p_ret_all_uoo_ids => l_ret_all_uoo_ids,
                                               p_ret_sub_uoo_ids => l_ret_sub_uoo_ids,
                                               p_ret_nonsub_uoo_ids => l_ret_nonsub_uoo_ids,
                                               p_delete_flag => 'Y') ;
      p_return_status := 'TRUE';
      p_message_name := NULL;

   END delete_sua_from_plan;


PROCEDURE  is_core_replaced(p_n_person_id IN NUMBER,
                            p_c_program_code IN VARCHAR2,
                            p_n_program_ver IN NUMBER,
                            p_c_load_cal IN VARCHAR2,
                            p_n_load_seq_num IN NUMBER,
                            p_c_core_uoo_ids IN VARCHAR2,
                            p_ss_session_id IN NUMBER)
------------------------------------------------------------------
  --Created by  : vijrajag
  --Date created: 04-July-2005
  --
  --Purpose: Checks whether all the core unit section getting dropped has equivalent replacement core unit sections
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --vijrajag    28-Oct-2005     Should create a Deny warning only if the DROP_CORE step fails
-------------------------------------------------------------------
IS
l_uoo_ids varchar2(2000);
l_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
l_found varchar2(1);
l_pos number;
l_row_id ROWID;
l_warning_id igs_en_std_warnings.warning_id%TYPE;
l_deny_warn     VARCHAR2(20);
CURSOR c_unit_sec_rep(cp_uoo_id IN NUMBER) IS
        SELECT 'X' FROM igs_en_su_attempt_all sua, igs_ps_unit_ofr_opt_all uoo
        WHERE uoo.uoo_id = cp_uoo_id
        AND sua.person_id  = p_n_person_id
        AND sua.course_cd = p_c_program_code
        AND sua.core_indicator_code = 'CORE'
        AND sua.ss_source_ind = 'S'
        AND sua.unit_cd = uoo.unit_cd
        AND sua.cal_type = uoo.cal_type
        AND sua.ci_sequence_number = uoo.ci_sequence_number
        AND sua.uoo_id <> uoo.uoo_id
        AND sua.unit_attempt_status = 'UNCONFIRM';
BEGIN

 igs_en_add_units_api.g_ss_session_id := p_ss_session_id;

 l_uoo_ids := p_c_core_uoo_ids;
 WHILE l_uoo_ids is NOT NULL LOOP
   l_pos := instr(l_uoo_ids,',',1);
   if l_pos=0 then
    l_uoo_id := l_uoo_ids;
    l_uoo_ids := NULL;
   else
    l_uoo_id := substr(l_uoo_ids,0,l_pos-1);
    l_uoo_ids := substr(l_uoo_ids,l_pos+1,length(l_uoo_ids));
   end if;
    l_deny_warn := NULL;
    -- If the CORE STEP validation fails, only then create a warning
    IF igs_en_gen_015.eval_core_unit_drop
                       (
                        p_n_person_id,
                        p_c_program_code,
                        l_uoo_id,
                        'DROP_CORE',
                        p_c_load_cal,
                        p_n_load_seq_num,
                        l_deny_warn,
			null
                        ) = 'FALSE'
    THEN
     -- Get the Unit Code
       IF l_deny_warn = 'DENY' THEN

           OPEN c_unit_sec_rep(l_uoo_id);
           FETCH c_unit_sec_rep INTO l_found;
           IF c_unit_sec_rep%NOTFOUND THEN
             igs_en_drop_units_api.create_ss_warning (
                P_PERSON_ID                    =>p_n_person_id,
                P_COURSE_CD                    =>p_c_program_code,
                P_TERM_CAL_TYPE                =>p_c_load_cal,
                P_TERM_CI_SEQUENCE_NUMBER      =>p_n_load_seq_num,
                P_UOO_ID                       =>l_uoo_id,
                P_MESSAGE_FOR                  =>igs_ss_enr_details.get_core_disp_unit(p_n_person_id,p_c_program_code,l_uoo_id),
                P_MESSAGE_ICON                 =>'D',
                P_MESSAGE_NAME                 =>'IGS_SS_DENY_CORE_SWAP',
                P_MESSAGE_RULE_TEXT            => NULL,
                P_MESSAGE_TOKENS               => NULL,
                P_MESSAGE_ACTION               => NULL,
                P_DESTINATION                  => NULL,
                P_PARAMETERS                   => NULL,
                P_STEP_TYPE                    => 'UNIT'
             );
           END IF;
           CLOSE c_unit_sec_rep;
      END IF;
    END IF;
 END LOOP;

 igs_en_add_units_api.g_ss_session_id := NULL;

EXCEPTION
  WHEN OTHERS THEN
    igs_en_add_units_api.g_ss_session_id := NULL;
    RAISE;

END is_core_replaced;

PROCEDURE swap_drop (
              p_uoo_ids IN VARCHAR2,
              p_person_id IN NUMBER,
              p_person_type IN VARCHAR2,
              p_load_cal_type IN VARCHAR2,
              p_load_sequence_number IN NUMBER,
              p_program_cd IN VARCHAR2,
              p_program_version IN NUMBER ,
              p_message OUT NOCOPY VARCHAR2,
              p_ret_status OUT NOCOPY VARCHAR2,
              p_ss_session_id IN NUMBER)
------------------------------------------------------------------
  --Created by  : Vijay Rajagopal, Oracle IDC
  --Date created: 27-JUN-2005
  --
  --Purpose: Drop the unit section selected as a part of drop
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --bdeviset    28-MAR-2006     Modified procedure for Bug# 5070774
  -------------------------------------------------------------------
 IS

  -- Get the discontinuation reason code.
  CURSOR c_drop_reason IS
    SELECT DISCONTINUATION_REASON_CD
    FROM igs_en_dcnt_reasoncd
    WHERE S_DISCONTINUATION_REASON_TYPE = 'SWAP'
    AND   SYS_DFLT_IND = 'Y'
    AND   ROWNUM < 2 ;


  -- Get the SUA Details
  CURSOR c_sua (cp_n_person_id IN NUMBER, cp_c_course_cd IN VARCHAR2, cp_n_uoo_id IN NUMBER) IS
  SELECT *
  FROM   IGS_EN_SU_ATTEMPT sua
  WHERE  sua.person_id = cp_n_person_id
  AND    sua.course_cd = cp_c_course_cd
  AND    sua.uoo_id    = cp_n_uoo_id;

  TYPE c_ref_cursor IS REF CURSOR;
  c_ref_cur_coreq_prereq      c_ref_cursor;
  l_c_reason_cd              igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE;
  l_uoo_ids                  varchar2(32000);
  pos                        number;
  l_cur_uoo_id               igs_ps_unit_ofr_opt_all.uoo_id%TYPE;  -- current uoo_id
  l_start_index              NUMBER;
  l_end_index                NUMBER;
  -- l_sub VARCHAR2(1);      -- indicate whether the current unit section is subordinate or not.

  l_enr_meth_type            igs_en_method_type.enr_method_type%TYPE;
  l_alternate_code           igs_ca_inst.alternate_code%TYPE;
  l_acad_cal_type            igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
  l_acad_start_dt            DATE;
  l_acad_end_dt              DATE;

  l_enr_cat                  igs_ps_type.enrolment_cat%TYPE;
  l_enr_cal_type             IGS_CA_INST.cal_type%TYPE;
  l_enr_ci_seq               IGS_CA_INST.sequence_number%TYPE;
  l_enr_categories           VARCHAR2(255);
  l_enr_comm                 VARCHAR2(1000);

  l_deny_warn_min_cp         VARCHAR2(10);
  l_deny_warn_att_type       VARCHAR2(30);
  l_deny_warn_coreq          VARCHAR2(10);
  l_deny_warn_prereq         VARCHAR2(10);
  l_person_type              igs_pe_typ_instances.person_type_code%TYPE;

  l_message                  VARCHAR2(100);
  l_return_status            VARCHAR2(5);
  l_rule                     VARCHAR2(32000);
  l_icon                     VARCHAR2(1);
  l_display_rule             VARCHAR2(1);
  l_coreq_failed_uoo_ids     VARCHAR2(1000);
  l_prereq_failed_uoo_ids    VARCHAR2(1000);
  l_unit_cd                  igs_en_su_attempt.unit_cd%TYPE;
  l_uoo_id                   igs_en_su_attempt.uoo_id%TYPE;
  l_unit_class               igs_en_su_attempt.unit_class%TYPE;

BEGIN

  -- reset the global variable
  igs_en_add_units_api.g_swap_failed_uooids := NULL;
  igs_en_add_units_api.g_ss_session_id := p_ss_session_id;


  -- Get the enrollment method type by calling the procedure igs_en_gen_017.enrp_get_enr_method
  igs_en_gen_017.enrp_get_enr_method(p_enr_method_type => l_enr_meth_type,
                                     p_error_message   => l_message,
                                     p_ret_status      => l_return_status);

  IF l_return_status = 'FALSE' OR l_message IS NOT NULL THEN
     p_message := l_message;
     p_ret_status := 'E';
     igs_en_add_units_api.g_ss_session_id := NULL;
     RETURN;
  END IF ;

  -- Get the academic calendar by calling the procedure Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd
  l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_load_cal_type,
                        p_ci_sequence_number      => p_load_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => l_message );

  IF l_message IS NOT NULL THEN
     p_message := l_message;
     p_ret_status := 'E';
     igs_en_add_units_api.g_ss_session_id := NULL;
     RETURN;
  END IF;

  -- Derive enrollment category by calling the procedure igs_en_gen_003.enrp_get_enr_cat
  l_enr_cat := igs_en_gen_003.enrp_get_enr_cat(
                                               p_person_id                => p_person_id,
                                               p_course_cd                => p_program_cd,
                                               p_cal_type                 => l_acad_cal_type ,
                                               p_ci_sequence_number       => l_acad_ci_sequence_number,
                                               p_session_enrolment_cat    => NULL,
                                               p_enrol_cal_type           => l_enr_cal_type,
                                               p_enrol_ci_sequence_number => l_enr_ci_seq,
                                               p_commencement_type        => l_enr_comm,
                                               p_enr_categories           => l_enr_categories
                                               );


  IF l_enr_comm = 'BOTH' THEN
     l_enr_comm :='ALL';
  END IF;

  -- Get the Deny Warn flag for Co-req
  l_deny_warn_coreq  := igs_ss_enr_details.get_notification(
                                               p_person_type            => l_person_type,
                                               p_enrollment_category    => l_enr_cat,
                                               p_comm_type              => l_enr_comm,
                                               p_enr_method_type        => l_enr_meth_type,
                                               p_step_group_type        => 'UNIT',
                                               p_step_type              => 'COREQ',
                                               p_person_id              => p_person_id,
                                               p_message                => l_message
                                               ) ;
  IF l_message IS NOT NULL THEN
     p_message := l_message;
     p_ret_status := 'E';
     igs_en_add_units_api.g_ss_session_id := NULL;
     RETURN;
  END IF;

  -- Get the Deny Warn for pre-req
  l_deny_warn_prereq := igs_ss_enr_details.get_notification(
                                                        p_person_type            => l_person_type,
                                                        p_enrollment_category    => l_enr_cat,
                                                        p_comm_type              => l_enr_comm,
                                                        p_enr_method_type        => l_enr_meth_type,
                                                        p_step_group_type        => 'UNIT',
                                                        p_step_type              => 'PREREQ',
                                                        p_person_id              => p_person_id,
                                                        p_message                => l_message
                                                        ) ;
  IF l_message IS NOT NULL THEN
     p_message := l_message;
     p_ret_status := 'E';
     igs_en_add_units_api.g_ss_session_id := NULL;
     RETURN;
  END IF;

  -- Validate prereq and coreq before dropping the units to be swapped
  OPEN c_ref_cur_coreq_prereq FOR
                         'SELECT U.unit_cd, U.unit_class, U.uoo_id
                          FROM  IGS_EN_SU_ATTEMPT U, IGS_CA_LOAD_TO_TEACH_V V
                          WHERE U.person_id = :1
                          AND U.course_cd = :2
                          AND U.unit_attempt_status IN  (''ENROLLED'',''INVALID'')
                          AND U.uoo_id NOT IN('||p_uoo_ids||')
                          AND U.cal_type = V.teach_cal_type
                          AND U.ci_sequence_number = V.teach_ci_sequence_number
                          AND V.load_cal_type = '''||p_load_cal_type||'''
                          AND V.load_ci_sequence_number = '||p_load_sequence_number
                          USING p_person_id,p_program_cd;

  LOOP

  FETCH c_ref_cur_coreq_prereq INTO l_unit_cd,l_unit_class,l_uoo_id;
  EXIT WHEN c_ref_cur_coreq_prereq%NOTFOUND;

     l_message := NULL;
     -- Evaluate Co-req
     IF l_deny_warn_coreq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_coreq(
                                                           p_person_id                =>  p_person_id,
                                                           p_load_cal_type            =>  p_load_cal_type,
                                                           p_load_sequence_number     =>  p_load_sequence_number,
                                                           p_uoo_id                   =>  l_uoo_id,
                                                           p_course_cd                =>  p_program_cd,
                                                           p_course_version           =>  p_program_version,
                                                           p_message                  =>  l_message,
                                                           p_deny_warn                =>  l_deny_warn_coreq,
                                                           p_calling_obj              => 'DROP') THEN

        IF l_coreq_failed_uoo_ids IS NOT NULL THEN
          l_coreq_failed_uoo_ids := l_coreq_failed_uoo_ids  ||','|| TO_CHAR(l_uoo_id);
        ELSE
          l_coreq_failed_uoo_ids := TO_CHAR(l_uoo_id);
        END IF;

    END IF;

    l_message := NULL;
    -- Evaluate Prereq
     IF l_deny_warn_prereq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_prereq(
                                                           p_person_id                =>  p_person_id,
                                                           p_load_cal_type            =>  p_load_cal_type,
                                                           p_load_sequence_number     =>  p_load_sequence_number,
                                                           p_uoo_id                   =>  l_uoo_id,
                                                           p_course_cd                =>  p_program_cd,
                                                           p_course_version           =>  p_program_version,
                                                           p_message                  =>  l_message,
                                                           p_deny_warn                =>  l_deny_warn_prereq,
                                                           p_calling_obj              =>  'DROP') THEN

        IF l_prereq_failed_uoo_ids IS NOT NULL THEN
          l_prereq_failed_uoo_ids := l_prereq_failed_uoo_ids||','||TO_CHAR(l_uoo_id);
        ELSE
          l_prereq_failed_uoo_ids := TO_CHAR(l_uoo_id);
        END IF;

    END IF;
 END LOOP;


   l_uoo_ids := p_uoo_ids;


  -- Get the swap drop reason
  OPEN c_drop_reason;
  FETCH c_drop_reason INTO l_c_reason_cd;
  CLOSE c_drop_reason;

  IF l_uoo_ids IS NOT NULL THEN

    -- Set the calling package as 'SWAP' so that check parent existence in igs_en_su_attempt_pkg will not be called.
    -- This is to overcome the locking issue encountered during Swap.
    --  (i.e) when the user is dropping few sua in the swap to be replaced, the sua is getting updated as 'DROPPED' and
    -- it locks all the parent records like SPA terms, sca...., in the swap to be added page when the user tries to
    -- add few sua, sua records are created in autonomous transaction where the check_parent_existences of TBH is being
    -- called as the parents are already locked in another transaction while dropping, SUA record creation in autonomous
    -- transaction fails.

    igs_en_su_attempt_pkg.pkg_source_of_drop := 'SWAP';

    while l_uoo_ids is not null loop
       pos := instr(l_uoo_ids,',',1);
       if pos=0 then
         l_cur_uoo_id := l_uoo_ids;
         l_uoo_ids := null;
       else
         l_cur_uoo_id := substr(l_uoo_ids,0,pos-1);
         l_uoo_ids := substr(l_uoo_ids,pos+1,length(l_uoo_ids));
       end if;
      -- for the current sua record.
      FOR rec_sua IN c_sua(p_person_id,p_program_cd,l_cur_uoo_id)
      LOOP

         -- Drop the sua with reason code as swap reason code.
         IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW (
            X_ROWID                         => rec_sua.row_id,
            X_PERSON_ID                     => rec_sua.person_id,
            X_COURSE_CD                     => rec_sua.course_cd,
            X_UNIT_CD                       => rec_sua.unit_cd,
            X_CAL_TYPE                      => rec_sua.cal_type,
            X_CI_SEQUENCE_NUMBER            => rec_sua.ci_sequence_number,
            X_VERSION_NUMBER                => rec_sua.version_number,
            X_LOCATION_CD                   => rec_sua.location_cd,
            X_UNIT_CLASS                    => rec_sua.unit_class,
            X_CI_START_DT                   => rec_sua.ci_start_dt,
            X_CI_END_DT                     => rec_sua.ci_end_dt,
            X_UOO_ID                        => rec_sua.uoo_id,
            X_ENROLLED_DT                   => rec_sua.enrolled_dt,
            X_UNIT_ATTEMPT_STATUS           => 'DROPPED',
            X_ADMINISTRATIVE_UNIT_STATUS    => NULL,
            X_DISCONTINUED_DT               => SYSDATE,
            X_RULE_WAIVED_DT                => rec_sua.rule_waived_dt,
            X_RULE_WAIVED_PERSON_ID         => rec_sua.rule_waived_person_id,
            X_NO_ASSESSMENT_IND             => rec_sua.no_assessment_ind,
            X_SUP_UNIT_CD                   => rec_sua.sup_unit_cd,
            X_SUP_VERSION_NUMBER            => rec_sua.sup_version_number,
            X_EXAM_LOCATION_CD              => rec_sua.exam_location_cd,
            X_ALTERNATIVE_TITLE             => rec_sua.alternative_title,
            X_OVERRIDE_ENROLLED_CP          => rec_sua.override_enrolled_cp,
            X_OVERRIDE_EFTSU                => rec_sua.override_eftsu,
            X_OVERRIDE_ACHIEVABLE_CP        => rec_sua.override_achievable_cp,
            X_OVERRIDE_OUTCOME_DUE_DT       => rec_sua.override_outcome_due_dt,
            X_OVERRIDE_CREDIT_REASON        => rec_sua.override_credit_reason,
            X_ADMINISTRATIVE_PRIORITY       => rec_sua.administrative_priority,
            X_WAITLIST_DT                   => rec_sua.waitlist_dt,
            X_DCNT_REASON_CD                => l_c_reason_cd,
            X_MODE                          => 'R',
            X_GS_VERSION_NUMBER             => rec_sua.gs_version_number,
            X_ENR_METHOD_TYPE               => rec_sua.enr_method_type,
            X_FAILED_UNIT_RULE              => rec_sua.failed_unit_rule,
            X_CART                          => rec_sua.cart,
            X_RSV_SEAT_EXT_ID               => rec_sua.rsv_seat_ext_id,
            X_ORG_UNIT_CD                   => rec_sua.org_unit_cd,
            X_GRADING_SCHEMA_CODE           => rec_sua.grading_schema_code,
            X_subtitle                      => rec_sua.subtitle,
            x_session_id                    => rec_sua.session_id,
            X_deg_aud_detail_id             => rec_sua.deg_aud_detail_id,
            x_student_career_transcript     => rec_sua.student_career_transcript,
            x_student_career_statistics     => rec_sua.student_career_statistics,
            X_WAITLIST_MANUAL_IND           => rec_sua.waitlist_manual_ind,
            X_ATTRIBUTE_CATEGORY            => rec_sua.attribute_category,
            X_ATTRIBUTE1                    => rec_sua.attribute1,
            X_ATTRIBUTE2                    => rec_sua.attribute2,
            X_ATTRIBUTE3                    => rec_sua.attribute3,
            X_ATTRIBUTE4                    => rec_sua.attribute4,
            X_ATTRIBUTE5                    => rec_sua.attribute5,
            X_ATTRIBUTE6                    => rec_sua.attribute6,
            X_ATTRIBUTE7                    => rec_sua.attribute7,
            X_ATTRIBUTE8                    => rec_sua.attribute8,
            X_ATTRIBUTE9                    => rec_sua.attribute9,
            X_ATTRIBUTE10                   => rec_sua.attribute10,
            X_ATTRIBUTE11                   => rec_sua.attribute11,
            X_ATTRIBUTE12                   => rec_sua.attribute12,
            X_ATTRIBUTE13                   => rec_sua.attribute13,
            X_ATTRIBUTE14                   => rec_sua.attribute14,
            X_ATTRIBUTE15                   => rec_sua.attribute15,
            X_ATTRIBUTE16                   => rec_sua.attribute16,
            X_ATTRIBUTE17                   => rec_sua.attribute17,
            X_ATTRIBUTE18                   => rec_sua.attribute18,
            X_ATTRIBUTE19                   => rec_sua.attribute19,
            X_ATTRIBUTE20                   => rec_sua.attribute20,
            X_WLST_PRIORITY_WEIGHT_NUM      => rec_sua.wlst_priority_weight_num,
            X_WLST_PREFERENCE_WEIGHT_NUM    => rec_sua.wlst_preference_weight_num,
            X_CORE_INDICATOR_CODE           => rec_sua.core_indicator_code
         );


         IF rec_sua.core_indicator_code = 'CORE' THEN
            igs_en_drop_units_api.create_ss_warning (
              P_PERSON_ID                    => p_person_id,
              P_COURSE_CD                    => p_program_cd,
              P_TERM_CAL_TYPE                => p_load_cal_type,
              P_TERM_CI_SEQUENCE_NUMBER      => p_load_sequence_number,
              P_UOO_ID                       => rec_sua.uoo_id,
              P_MESSAGE_FOR                  => rec_sua.unit_cd || '/' || rec_sua.unit_class,
              P_MESSAGE_ICON                 => 'I',
              P_MESSAGE_NAME                 => 'IGS_SS_INFO_CORE_SWP',
              P_MESSAGE_RULE_TEXT            => null,
              P_MESSAGE_TOKENS               => null,
              P_MESSAGE_ACTION               => null,
              P_DESTINATION                  => null,
              P_PARAMETERS                   => null,
              P_STEP_TYPE                    => 'UNIT'
            );
         END IF;

         IGS_SS_EN_WRAPPERS.call_fee_ass (
           p_person_id => p_person_id,
           p_cal_type => p_load_cal_type, -- load
           p_sequence_number => p_load_sequence_number, -- load
           p_course_cd => p_program_cd,
           p_unit_cd => rec_sua.unit_cd,
           p_uoo_id => rec_sua.uoo_id
         );

      END LOOP; -- FOR loop

    END LOOP; -- While loop
  END IF;

  -- Unsetting the package variable after dropping SUA.
  igs_en_su_attempt_pkg.pkg_source_of_drop := NULL;


  l_display_rule := NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N');

  OPEN c_ref_cur_coreq_prereq FOR
                         'SELECT U.unit_cd, U.unit_class, U.uoo_id
                          FROM  IGS_EN_SU_ATTEMPT U, IGS_CA_LOAD_TO_TEACH_V V
                          WHERE U.person_id = :1
                          AND U.course_cd = :2
                          AND U.unit_attempt_status IN  (''ENROLLED'',''INVALID'')
                          AND U.uoo_id NOT IN('||p_uoo_ids||')
                          AND U.cal_type = V.teach_cal_type
                          AND U.ci_sequence_number = V.teach_ci_sequence_number
                          AND V.load_cal_type = '''||p_load_cal_type||'''
                          AND V.load_ci_sequence_number = '||p_load_sequence_number
                          USING p_person_id,p_program_cd;

  LOOP

  FETCH c_ref_cur_coreq_prereq INTO l_unit_cd,l_unit_class,l_uoo_id;
  EXIT WHEN c_ref_cur_coreq_prereq%NOTFOUND;

     -- Evaluate Co-req
     IF l_deny_warn_coreq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_coreq(
                                                           p_person_id                =>  p_person_id,
                                                           p_load_cal_type            =>  p_load_cal_type,
                                                           p_load_sequence_number     =>  p_load_sequence_number,
                                                           p_uoo_id                   =>  l_uoo_id,
                                                           p_course_cd                =>  p_program_cd,
                                                           p_course_version           =>  p_program_version,
                                                           p_message                  =>  l_message,
                                                           p_deny_warn                =>  l_deny_warn_coreq,
                                                           p_calling_obj              => 'DROP') THEN

    l_message := null;
    l_rule := null;
    l_icon := null;

        -- check if the unit failed the rule because of dropping the unit if so log a warning record
        IF  (l_coreq_failed_uoo_ids IS NULL OR  INSTR(','||l_coreq_failed_uoo_ids||',' , ','||l_uoo_id||',') = 0) THEN

          -- get the error message and icon to be displayed.
          IF l_deny_warn_coreq = 'DENY' THEN
             l_message := 'IGS_SS_DENY_COREQ_SWP';
             l_icon := 'D';
          ELSE
             l_message := 'IGS_SS_WARN_COREQ_SWP';
             l_icon := 'W';
          END IF;

          IF igs_en_add_units_api.g_swap_failed_uooids IS NULL THEN
              igs_en_add_units_api.g_swap_failed_uooids := TO_CHAR(l_uoo_id);
          ELSE
              igs_en_add_units_api.g_swap_failed_uooids := igs_en_add_units_api.g_swap_failed_uooids||','||TO_CHAR(l_uoo_id);
          END IF;


              -- if rule text needs to be displayed, get it.
          IF l_display_rule = 'Y' THEN
             l_rule := igs_ss_enr_details.get_rule_text('COREQ', l_uoo_id);
          END IF;

              -- Create the warnings record for those unit section which are failing co-requisite rule
              igs_en_drop_units_api.create_ss_warning (
                  P_PERSON_ID                    => p_person_id,
                  P_COURSE_CD                    => p_program_cd,
                  P_TERM_CAL_TYPE                => p_load_cal_type,
                  P_TERM_CI_SEQUENCE_NUMBER      => p_load_sequence_number,
                  P_UOO_ID                       => l_uoo_id,
                  P_MESSAGE_FOR                  => l_unit_cd|| '/' ||l_unit_class,
                  P_MESSAGE_ICON                 => l_icon,
                  P_MESSAGE_NAME                 => l_message,
                  P_MESSAGE_RULE_TEXT            => l_rule,
                  P_MESSAGE_TOKENS               => null,
                  P_MESSAGE_ACTION               => null,
                  P_DESTINATION                  => null,
                  P_PARAMETERS                   => null,
                  P_STEP_TYPE                    => 'UNIT'
                );

        END IF;

     END IF;

     -- Evaluate Pre-req
     IF l_deny_warn_prereq IS NOT NULL AND NOT IGS_EN_ELGBL_UNIT.eval_prereq(
                                                           p_person_id                =>  p_person_id,
                                                           p_load_cal_type            =>  p_load_cal_type,
                                                           p_load_sequence_number     =>  p_load_sequence_number,
                                                           p_uoo_id                   =>  l_uoo_id,
                                                           p_course_cd                =>  p_program_cd,
                                                           p_course_version           =>  p_program_version,
                                                           p_message                  =>  l_message,
                                                           p_deny_warn                =>  l_deny_warn_prereq,
                                                           p_calling_obj              =>  'DROP') THEN

    l_message := null;
    l_rule := null;
    l_icon := null;

        -- check if the unit failed the rule because of dropping the unit if so log a warning record
        IF  (l_prereq_failed_uoo_ids IS NULL OR  INSTR(','||l_prereq_failed_uoo_ids||',' , ','||l_uoo_id||',') = 0) THEN

              -- get the error message and icon to be displayed.
              IF l_deny_warn_prereq = 'DENY' THEN
                 l_message := 'IGS_SS_DENY_PREREQ_SWP';
                 l_icon := 'D';
              ELSE
                 l_message := 'IGS_SS_WARN_PREREQ_SWP';
                 l_icon := 'W';
              END IF;

              IF igs_en_add_units_api.g_swap_failed_uooids IS NULL THEN
                  igs_en_add_units_api.g_swap_failed_uooids := TO_CHAR(l_uoo_id);
              ELSE
                  igs_en_add_units_api.g_swap_failed_uooids := igs_en_add_units_api.g_swap_failed_uooids||','||TO_CHAR(l_uoo_id);
              END IF;

                  -- if rule text needs to be displayed, get it.
              IF l_display_rule = 'Y' THEN
                 l_rule := igs_ss_enr_details.get_rule_text('PREREQ', l_uoo_id);
              END IF;

                  -- Create the warnings record for those unit section which are failing co-requisite rule
                  igs_en_drop_units_api.create_ss_warning (
                      P_PERSON_ID                    => p_person_id,
                      P_COURSE_CD                    => p_program_cd,
                      P_TERM_CAL_TYPE                => p_load_cal_type,
                      P_TERM_CI_SEQUENCE_NUMBER      => p_load_sequence_number,
                      P_UOO_ID                       => l_uoo_id,
                      P_MESSAGE_FOR                  => l_unit_cd||'/'||l_unit_class,
                      P_MESSAGE_ICON                 => l_icon,
                      P_MESSAGE_NAME                 => l_message,
                      P_MESSAGE_RULE_TEXT            => l_rule,
                      P_MESSAGE_TOKENS               => null,
                      P_MESSAGE_ACTION               => null,
                      P_DESTINATION                  => null,
                      P_PARAMETERS                   => null,
                      P_STEP_TYPE                    => 'UNIT'
                    );
          END IF;

     END IF;

  END LOOP;
  igs_en_add_units_api.g_ss_session_id := NULL;

EXCEPTION
  WHEN OTHERS THEN
    igs_en_add_units_api.g_ss_session_id := NULL;
    RAISE;

END swap_drop;
-- Procedure to delete the uncofirmed SUA created in the swap cart.
-- p_ret_status returns TRUE or FALSE based on whether the record has been successfully deleted or not
-- p_msg returns sucess/failure message to be displayed in SS page.

PROCEDURE swap_delete ( p_person_id          IN  NUMBER,
                        p_course_cd          IN  VARCHAR2,
                        p_course_version     IN  NUMBER,
                        p_usec_dtls          IN  VARCHAR2,
                        p_uoo_id             IN  NUMBER,
                        p_term_cal           IN  VARCHAR2,
                        p_term_seq_num       IN  NUMBER,
                        p_core               IN  VARCHAR2,
                        p_rel_type           IN  VARCHAR2,
                        p_ret_status         OUT NOCOPY VARCHAR2,
                        p_msg                OUT NOCOPY VARCHAR2) AS
          PRAGMA AUTONOMOUS_TRANSACTION;


   -- Cursor to get the subordinate unit attempts for a superior unit attempt.
   CURSOR   c_sub_sua (cp_person_id IN NUMBER, cp_course_cd IN VARCHAR2, cp_uoo_id IN NUMBER) IS
     SELECT sua.unit_cd || '/' || sua.unit_class  AS UNIT_SECTION,
            sua.uoo_id,
            sua.core_indicator_code AS CORE
     FROM   igs_en_su_attempt_all sua,
            igs_ps_unit_ofr_opt_all uoo
     WHERE sua.person_id = cp_person_id
     AND   sua.course_cd = cp_course_cd
     AND   sua.uoo_id = uoo.uoo_id
     AND   uoo.sup_uoo_id = cp_uoo_id;

   l_sup_us    BOOLEAN; -- indicates whether the unit section is superior or not
   l_sub_found BOOLEAN; -- indicates whether the superior unit section has subordinate or not.
   l_sub_units VARCHAR2(500); -- Stores the list of subordinate unit section getting dropped.
   l_msg       VARCHAR2(30);
   l_denywarn  igs_en_cpd_ext.notification_flag%TYPE;


    -- Procedure to call the delete row for SUA
    PROCEDURE sua_delete (p_person_id IN NUMBER,
                          p_course_cd IN VARCHAR2,
                          p_uoo_id IN NUMBER) IS

       -- Cursor to select the row id of SUA.
       CURSOR c_del (cp_person_id IN NUMBER,
                     cp_course_cd IN VARCHAR2,
                     cp_uoo_id IN NUMBER) IS
         SELECT  sua.row_id AS ROW_ID
         FROM igs_en_su_attempt sua
         WHERE sua.person_id = cp_person_id
         AND   sua.course_cd = cp_course_cd
         AND   sua.uoo_id    = cp_uoo_id;

    BEGIN
      FOR rec_del IN c_del(p_person_id, p_course_cd, p_uoo_id) LOOP
          igs_en_su_attempt_pkg.delete_row ( X_ROWID => rec_del.row_id,
                                             X_MODE  => 'R');
      END LOOP;
    END sua_delete;

BEGIN  -- Main procedure begins

   -- Call the sua_delete procedure to delete
   sua_delete (p_person_id => p_person_id,
               p_course_cd => p_course_cd,
               p_uoo_id    => p_uoo_id);

   -- if the unit section dropped was superior then its subordinates as well as needs to be dropped.
   IF p_rel_type = 'SUPERIOR' THEN
      l_sup_us := TRUE;
      FOR rec_sub_sua IN c_sub_sua(p_person_id, p_course_cd, p_uoo_id) LOOP
          l_sub_units := l_sub_units || ',' || rec_sub_sua.unit_section; -- Store the list of subordinate unit sections.

          -- Delete the subordinate unit section.
          sua_delete (p_person_id => p_person_id,
                      p_course_cd => p_course_cd,
                      p_uoo_id    => rec_sub_sua.uoo_id);
      END LOOP;

      IF p_ret_status = 'FALSE' THEN
         ROLLBACK;
         RETURN;
      END IF;


      fnd_message.set_name ('IGS','IGS_EN_SS_SWP_SUB_CORE_SUCCESS');
      fnd_message.set_token ('SUP_UNIT_CD',p_usec_dtls);
      IF length(l_sub_units) >0 THEN
         fnd_message.set_token ('SUB_UNIT_CD', substr(l_sub_units,2));
      ELSE
         fnd_message.set_token ('SUB_UNIT_CD', igs_ss_enr_details.get_none_desc);
      END IF;

   ELSE

      fnd_message.set_name('IGS','IGS_EN_SS_SWP_DEL_SUCCESS');
      fnd_message.set_token ('UNIT_CD',p_usec_dtls);

   END IF;

   p_ret_status := 'TRUE';   -- Successfully dropped the unit section/s
   p_msg:= fnd_message.get; -- Contains the success/failure message to be displayed in swap to be added page.
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      p_ret_status := 'FALSE';
      p_msg := sqlerrm;
END swap_delete;

-- This procedure releases the sheet as the unit sections are dropped as a part of swap

PROCEDURE swap_submit (person_id IN NUMBER,
                       program_cd IN VARCHAR2,
                       p_uoo_ids IN VARCHAR2) AS
  CURSOR cur_sua(cp_person_id IN NUMBER,cp_program_cd IN VARCHAR2,cp_uoo_id IN NUMBER) IS
    SELECT *
    FROM IGS_EN_SU_ATTEMPT_ALL
    WHERE person_id = cp_person_id
    AND   course_cd = cp_program_cd
    AND   uoo_Id = cp_uoo_Id;

  CURSOR cur_igs_ps_rsv_ext (cp_rsv_ext_id igs_ps_rsv_ext.rsv_ext_id%TYPE) IS
    SELECT rsv.ROWID row_id, rsv.*
    FROM   igs_ps_rsv_ext rsv
    WHERE  rsv_ext_id = cp_rsv_ext_id FOR UPDATE;


  old_rec igs_en_su_attempt_all%rowTYPE;
  new_rec igs_en_su_attempt_all%ROWTYPE;
  l_uoo_ids varchar2(30);
  l_cur_uoo_id varchar2(30);
  pos number;
  v_message_name VARCHAR2(30);

BEGIN
  l_uoo_ids := p_uoo_ids;
  WHILE l_uoo_ids is not null LOOP
     pos := instr(l_uoo_ids,',',1);
     IF pos=0 THEN
      l_cur_uoo_id := l_uoo_ids;
      l_uoo_ids := null;
     ELSE
      l_cur_uoo_id := substr(l_uoo_ids,0,pos-1);
      l_uoo_ids := substr(l_uoo_ids,pos+1,length(l_uoo_ids));
     END IF;
     OPEN cur_sua(person_id, program_cd, l_cur_uoo_id);
     FETCH cur_sua INTO old_rec;
     CLOSE cur_sua;
     new_rec := old_rec;
     old_rec.unit_attempt_status := 'ENROLLED';

     -- if reserve seating is existing then need to decrement the actual seat enrolled
     -- which was not done during swap drop.

     IF new_rec.rsv_seat_ext_id IS NOT NULL THEN
        FOR rec_igs_ps_rsv_ext IN cur_igs_ps_rsv_ext(new_rec.rsv_seat_ext_id) LOOP
            IF ((rec_igs_ps_rsv_ext.actual_seat_enrolled -1) >= 0) THEN
               igs_ps_rsv_ext_pkg.update_row( x_rowid                => rec_igs_ps_rsv_ext.row_id,
                                              x_rsv_ext_id           => rec_igs_ps_rsv_ext.rsv_ext_id,
                                              x_uoo_id               => rec_igs_ps_rsv_ext.uoo_id,
                                              x_priority_id          => rec_igs_ps_rsv_ext.priority_id,
                                              x_preference_id        => rec_igs_ps_rsv_ext.preference_id,
                                              x_rsv_level            => rec_igs_ps_rsv_ext.rsv_level,
                                              x_actual_seat_enrolled => rec_igs_ps_rsv_ext.actual_seat_enrolled -1,
                                              x_mode                 => 'R'
                                            );
            END IF;
        END LOOP;
     END IF;


     IF IGS_EN_GEN_012.ENRP_UPD_SCA_STATUS(
        new_rec.person_id,
        new_rec.course_cd,
        v_message_name) = FALSE THEN
        FND_MESSAGE.SET_NAME('IGS',v_message_name);
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

     IGS_EN_GEN_003.UPD_MAT_MRADM_CAT_TERMS(new_rec.person_id,
                                            new_rec.course_cd,
                                            new_rec.unit_attempt_status,
                                            new_rec.cal_type,
                                            new_rec.ci_sequence_number
                                           ) ;

     igs_en_sua_api.upd_enrollment_counts( 'DELETE',
                                           old_rec,
                                           new_rec);
  END LOOP;
END swap_submit;


PROCEDURE release_swap_cart(p_n_person_id IN NUMBER,
                            p_c_program_code IN VARCHAR2,
                            p_c_load_cal IN VARCHAR2,
                            p_n_load_seq_num IN NUMBER)
------------------------------------------------------------------
  --Created by  : vijrajag
  --Date created: 04-July-2005
  --
  --Purpose: Procedure to release enrollment seats grabbed during swap
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
PRAGMA AUTONOMOUS_TRANSACTION;
 -- cursor to pick up the student attempts created as a part of swap.
  CURSOR c_sua (cp_n_person_id    IN NUMBER,
                cp_c_program_code IN VARCHAR2,
                cp_c_load_cal     IN VARCHAR2,
                cp_n_seq_num      IN NUMBER) IS
        SELECT sua.ROWID ROW_ID,
               sua.uoo_id
         FROM igs_en_su_attempt_all sua,
              igs_ca_teach_to_load_v rel
         WHERE sua.person_id  = cp_n_person_id
          AND      sua.course_cd = cp_c_program_code
          AND      sua.cal_type = rel.teach_cal_type
          AND      sua.ci_sequence_number = rel.teach_ci_sequence_number
          AND      rel.load_cal_type = cp_c_load_cal
          AND      rel.load_ci_sequence_number = cp_n_seq_num
          AND      sua.unit_attempt_status = 'UNCONFIRM'
          AND      sua.SS_SOURCE_IND = 'S';



-- Cursor to select the warning records created as a part of swap.
 CURSOR c_warn (cp_n_person_id    IN NUMBER,
                cp_c_program_code IN VARCHAR2,
                cp_c_load_cal     IN VARCHAR2,
                cp_n_seq_num      IN NUMBER) IS
    SELECT warn.ROWID ROW_ID
    FROM  igs_en_std_warnings warn
    WHERE  warn.person_id = cp_n_person_id
     AND      warn.course_cd = cp_c_program_code
     AND      warn.term_cal_type = cp_c_load_cal
     AND      warn.term_ci_sequence_number = cp_n_seq_num;

BEGIN

 FOR rec_warn in c_warn(p_n_person_id,p_c_program_code,p_c_load_cal,p_n_load_seq_num) LOOP
        IGS_EN_STD_WARNINGS_pkg.delete_row(x_rowid =>rec_warn.row_id);
 END LOOP;

 FOR rec_sua IN c_sua(p_n_person_id,p_c_program_code,p_c_load_cal,p_n_load_seq_num) LOOP

      igs_en_su_attempt_pkg.delete_row(X_ROWID => rec_sua.row_id,
                                    x_mode  => 'R');
 END LOOP;

 COMMIT;

END release_swap_cart;

FUNCTION is_credit_updatable(
                           p_person_id          IN   NUMBER,
                           p_course_cd          IN NUMBER,
                           p_uoo_id             IN   NUMBER,
                           p_cal_type           IN   VARCHAR2,
                           p_ci_sequence_number IN   NUMBER
                         ) RETURN CHAR AS
/******************************************************************
Created By        : Somasekar, IDC
Date Created By   : 04-Oct-2001
Purpose           : This func determines if credit points can be updated
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
******************************************************************/
   l_dummy          VARCHAR2(100);
   -- cursor for getting the Unit_cd and Version Number for the Uoo_id passed
  CURSOR cur_ps_unit_ofr
  IS
  SELECT unit_cd, version_number,cal_type,ci_sequence_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

   -- Check if the unit is set up for variable cp
   CURSOR cur_chk_cp_chg_val (p_unit_cd igs_ps_unit_ver_v.unit_cd%TYPE,p_unit_ver_num igs_ps_unit_ver_v.version_number%TYPE)
   IS SELECT points_override_ind
   FROM igs_ps_unit_ver_v
   WHERE unit_cd = p_unit_cd
   AND version_number = p_unit_ver_num;

   --Check if there exist any user level deadline
  CURSOR cur_pe_usr_arg( cp_person_type  IN igs_pe_person_types.person_type_code%TYPE,
        cp_cal_type igs_ca_inst_all.cal_type%TYPE, cp_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE)
  IS
  SELECT dai.alias_val alias_val
  FROM   igs_ca_da_inst_v dai,igs_pe_usr_arg_all pua
  WHERE  pua.person_type        = cp_person_type
  AND    dai.dt_alias           = pua.grad_sch_dt_alias
  AND    dai.cal_type           = cp_cal_type
  AND    dai.ci_sequence_number = cp_ci_sequence_number
  ORDER BY 1;

  --Check if deadline has passed for cp change at usec level
  CURSOR cur_en_nstd_usec
  IS
  SELECT enr_dl_date  alias_val
  FROM   igs_en_nstd_usec_dl
  WHERE  function_name = 'GRADING_SCHEMA'
  AND    uoo_id        = p_uoo_id
  ORDER BY 1;

 --Check if deadline has passed for cp change at institution level
  CURSOR cur_en_cal_conf(cp_cal_type igs_ca_inst_all.cal_type%TYPE, cp_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE)
  IS
  SELECT dai.alias_val alias_val
  FROM   igs_ca_da_inst_v dai, igs_en_cal_conf ecc
  WHERE  dai.cal_type           = cp_cal_type
  AND    dai.ci_sequence_number = cp_ci_sequence_number
  AND    dai.dt_alias           = ecc.grading_schema_dt_alias
  AND    ecc.s_control_num      =1
  ORDER BY 1;

  -- Cursor to get the System Type corresponding to the Person Type Code
  -- Added as per the bug# 2364461.
  CURSOR cur_sys_per_typ(cp_person_type VARCHAR2) IS
  SELECT system_type
  FROM   igs_pe_person_types
  WHERE  person_type_code = cp_person_type;
  l_cur_sys_per_typ cur_sys_per_typ%ROWTYPE;

  -- Cursor to check for audit attempts
  -- By selecting no_assessment_ind column corresponding
  -- to the Person Id, Unit Offering Options Id, Calendar Type
  -- and Calendar Instance
  CURSOR cur_no_assessment_ind
  IS
  SELECT no_assessment_ind
  FROM igs_en_plan_units
  WHERE person_id = p_person_id
    AND course_cd = p_course_cd
  AND uoo_id = p_uoo_id
  AND cart_error_flag='N';
  l_no_assessment_ind VARCHAR2(1);

  --Row type variables
  l_cur_pe_usr_arg      cur_pe_usr_arg%ROWTYPE;
  l_cur_en_nstd_usec    cur_en_nstd_usec%ROWTYPE;
  l_cur_en_cal_conf     cur_en_cal_conf%ROWTYPE;
  l_cur_chk_cp_chg_val  cur_chk_cp_chg_val%ROWTYPE;
  l_cur_ps_unit_ofr    cur_ps_unit_ofr%ROWTYPE;

  -- Variables
  l_v_person_type   igs_pe_person_types.person_type_code%TYPE;
  l_cp_out NUMBER;

  BEGIN

  -- Check for audit attempt
  OPEN cur_no_assessment_ind;
  FETCH cur_no_assessment_ind INTO l_no_assessment_ind;
  CLOSE cur_no_assessment_ind;
  -- Incase of an audit attempt the enrolled CP should not be
  -- updateable by the student, hence return 'N'
  IF l_no_assessment_ind = 'Y' THEN
      RETURN 'N';
  END IF;

  --Get the person logged in frmo session
  l_v_person_type := igs_en_gen_008.enrp_get_person_type(p_course_cd=>NULL);

  -- According to ENCR012, check that approved cp are not defined for this student
  -- Added as per the bug# 2364461.
  -- Start of new code.
  OPEN cur_sys_per_typ(l_v_person_type);
  FETCH cur_sys_per_typ INTO l_cur_sys_per_typ;
  CLOSE cur_sys_per_typ;
  -- End of new code.
  -- For Bug 2398133,removed the assignment
  -- l_v_person_type := l_cur_sys_per_typ.system_type
  -- as it was overwritting the person type of the logged in user.
  --
  IF l_cur_sys_per_typ.system_type = 'STUDENT' THEN
    IF fnd_profile.value('IGS_EN_UPDATE_CP_GS')='Y' THEN
      RETURN 'N';
    END IF;

    IF igs_en_gen_015.validation_step_is_overridden(
      p_eligibility_step_type        => 'VAR_CREDIT_APPROVAL',
      p_load_cal_type                => p_cal_type,
      p_load_cal_seq_number          => p_ci_sequence_number,
      p_person_id                    => p_person_id,
      p_uoo_id                       => p_uoo_id,
      p_step_override_limit          => l_cp_out) THEN
        RETURN 'N';
      END IF;
  END IF;


  -- Get the Unit, version_number for the UOO_ID passed into the function
  OPEN  cur_ps_unit_ofr;
  FETCH cur_ps_unit_ofr INTO l_cur_ps_unit_ofr;
  CLOSE cur_ps_unit_ofr;

  -- check that the unit is set up as allowing points override in PSP
  OPEN cur_chk_cp_chg_val(l_cur_ps_unit_ofr.unit_cd,l_cur_ps_unit_ofr.version_number);
  FETCH cur_chk_cp_chg_val INTO l_cur_chk_cp_chg_val;
  CLOSE cur_chk_cp_chg_val;

  IF l_cur_chk_cp_chg_val.points_override_ind = 'Y' THEN
  --This above condition means that override cp is allowed
  --So check for deadlines at user,unit section level and institution level



  --If person type exists, check that any user level deadlines are not passed
  IF l_v_person_type IS NOT NULL THEN
    -- check if any date_aliases are defined for the person_type
    -- if found then validate them
    -- else validate dates at Unit Section Level
    OPEN cur_pe_usr_arg(l_v_person_type,l_cur_ps_unit_ofr.cal_type, l_cur_ps_unit_ofr.ci_sequence_number);
    FETCH cur_pe_usr_arg INTO l_cur_pe_usr_arg;
    IF cur_pe_usr_arg%FOUND THEN
      CLOSE cur_pe_usr_arg;
      OPEN cur_pe_usr_arg(l_v_person_type,l_cur_ps_unit_ofr.cal_type, l_cur_ps_unit_ofr.ci_sequence_number);
        LOOP
          EXIT WHEN cur_pe_usr_arg%NOTFOUND;
          FETCH cur_pe_usr_arg INTO l_cur_pe_usr_arg;
          IF ( TRUNC(l_cur_pe_usr_arg.alias_val) < TRUNC(SYSDATE) ) THEN
            RETURN 'N';
          END IF;
        END LOOP;
      CLOSE cur_pe_usr_arg;
      RETURN 'Y';
    ELSE
      CLOSE cur_pe_usr_arg;
    END IF;
  END IF;

  --Check if unit section level deadline has not passed
  OPEN cur_en_nstd_usec;
  FETCH cur_en_nstd_usec INTO l_cur_en_nstd_usec;
  IF cur_en_nstd_usec%FOUND THEN
    CLOSE cur_en_nstd_usec;
    OPEN cur_en_nstd_usec;
    LOOP
      EXIT WHEN cur_en_nstd_usec%NOTFOUND;
      FETCH cur_en_nstd_usec INTO l_cur_en_nstd_usec;
      IF ( TRUNC(l_cur_en_nstd_usec.alias_val) < TRUNC(SYSDATE) ) THEN
        RETURN 'N';
      END IF;
    END LOOP;
    CLOSE cur_en_nstd_usec;
    RETURN 'Y';
  ELSE
      CLOSE cur_en_nstd_usec;
  END IF;

  --Check if institution level deadline has not passed
    OPEN cur_en_cal_conf(l_cur_ps_unit_ofr.cal_type, l_cur_ps_unit_ofr.ci_sequence_number);
    FETCH cur_en_cal_conf INTO l_cur_en_cal_conf;
    IF cur_en_cal_conf%FOUND THEN
      CLOSE cur_en_cal_conf;
      OPEN cur_en_cal_conf(l_cur_ps_unit_ofr.cal_type, l_cur_ps_unit_ofr.ci_sequence_number);
      LOOP
        EXIT WHEN cur_en_cal_conf%NOTFOUND;
        FETCH cur_en_cal_conf INTO l_cur_en_cal_conf;
        IF ( TRUNC(l_cur_en_cal_conf.alias_val) < TRUNC(SYSDATE) ) THEN
          RETURN 'N';
        END IF;
      END LOOP;
      CLOSE cur_en_cal_conf;
      RETURN 'Y';
    ELSE
      CLOSE cur_en_cal_conf;
      RETURN 'Y';
    END IF;

  ELSE
    RETURN 'N';
  END IF;

  END is_credit_updatable;

PROCEDURE swap_update(
              p_person_id                     IN NUMBER,
              p_course_cd                     IN VARCHAR2,
              p_uooid                         IN NUMBER,
              p_fieldname                     IN VARCHAR2,
              p_auditval                      IN VARCHAR2,
              p_creditval                     IN NUMBER,
              p_gradingval                    IN VARCHAR2,
              X_ROWID                         IN VARCHAR2,
              X_UNIT_CD                       IN VARCHAR2,
              X_CAL_TYPE                      IN VARCHAR2,
              X_CI_SEQUENCE_NUMBER            IN NUMBER,
              X_VERSION_NUMBER                IN NUMBER,
              X_LOCATION_CD                   IN VARCHAR2,
              X_UNIT_CLASS                    IN VARCHAR2,
              X_CI_START_DT                   IN DATE,
              X_CI_END_DT                     IN DATE,
              X_ENROLLED_DT                   IN DATE,
              X_UNIT_ATTEMPT_STATUS           IN VARCHAR2,
              X_ADMINISTRATIVE_UNIT_STATUS    IN VARCHAR2,
              X_DISCONTINUED_DT               IN DATE,
              X_RULE_WAIVED_DT                IN DATE,
              X_RULE_WAIVED_PERSON_ID         IN NUMBER,
              X_NO_ASSESSMENT_IND             IN VARCHAR2,
              X_SUP_UNIT_CD                   IN VARCHAR2,
              X_SUP_VERSION_NUMBER            IN NUMBER,
              X_EXAM_LOCATION_CD              IN VARCHAR2,
              X_ALTERNATIVE_TITLE             IN VARCHAR2,
              X_OVERRIDE_ENROLLED_CP          IN NUMBER,
              X_OVERRIDE_EFTSU                IN NUMBER,
              X_OVERRIDE_ACHIEVABLE_CP        IN NUMBER,
              X_OVERRIDE_OUTCOME_DUE_DT       IN DATE,
              X_OVERRIDE_CREDIT_REASON        IN VARCHAR2,
              X_ADMINISTRATIVE_PRIORITY       IN NUMBER,
              X_WAITLIST_DT                   IN DATE,
              X_DCNT_REASON_CD                IN VARCHAR2,
              X_GS_VERSION_NUMBER             IN NUMBER,
              X_ENR_METHOD_TYPE               IN VARCHAR2,
              X_FAILED_UNIT_RULE              IN VARCHAR2,
              X_CART                          IN VARCHAR2,
              X_RSV_SEAT_EXT_ID               IN NUMBER,
              X_ORG_UNIT_CD                   IN VARCHAR2,
              X_GRADING_SCHEMA_CODE           IN VARCHAR2,
              X_subtitle                      IN VARCHAR2,
              x_session_id                    IN NUMBER,
              X_deg_aud_detail_id             IN NUMBER,
              x_student_career_transcript     IN VARCHAR2,
              x_student_career_statistics     IN VARCHAR2,
              x_waitlist_manual_ind           IN VARCHAR2,
              X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
              X_ATTRIBUTE1                    IN VARCHAR2,
              X_ATTRIBUTE2                    IN VARCHAR2,
              X_ATTRIBUTE3                    IN VARCHAR2,
              X_ATTRIBUTE4                    IN VARCHAR2,
              X_ATTRIBUTE5                    IN VARCHAR2,
              X_ATTRIBUTE6                    IN VARCHAR2,
              X_ATTRIBUTE7                    IN VARCHAR2,
              X_ATTRIBUTE8                    IN VARCHAR2,
              X_ATTRIBUTE9                    IN VARCHAR2,
              X_ATTRIBUTE10                   IN VARCHAR2,
              X_ATTRIBUTE11                   IN VARCHAR2,
              X_ATTRIBUTE12                   IN VARCHAR2,
              X_ATTRIBUTE13                   IN VARCHAR2,
              X_ATTRIBUTE14                   IN VARCHAR2,
              X_ATTRIBUTE15                   IN VARCHAR2,
              X_ATTRIBUTE16                   IN VARCHAR2,
              X_ATTRIBUTE17                   IN VARCHAR2,
              X_ATTRIBUTE18                   IN VARCHAR2,
              X_ATTRIBUTE19                   IN VARCHAR2,
              x_ATTRIBUTE20                   IN VARCHAR2,
              X_WLST_PRIORITY_WEIGHT_NUM      IN NUMBER,
              X_WLST_PREFERENCE_WEIGHT_NUM    IN NUMBER,
              X_CORE_INDICATOR_CODE           IN VARCHAR2,
              X_UPD_AUDIT_FLAG                IN VARCHAR2,
              X_SS_SOURCE_IND                 IN VARCHAR2)
------------------------------------------------------------------
  --Created by  : vijrajag
  --Date created: 04-July-2005
  --
  --Purpose: autonomous wrapper over update_plansheet_utnidetails
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   igs_en_su_attempt_pkg.lock_row(
              X_ROWID                         => X_ROWID,
              X_PERSON_ID                     => p_person_id,
              X_COURSE_CD                     => p_course_cd,
              X_UNIT_CD                       => X_UNIT_CD,
              X_CAL_TYPE                      => X_CAL_TYPE,
              X_CI_SEQUENCE_NUMBER            => X_CI_SEQUENCE_NUMBER,
              X_VERSION_NUMBER                => X_VERSION_NUMBER,
              X_LOCATION_CD                   => X_LOCATION_CD,
              X_UNIT_CLASS                    => X_UNIT_CLASS,
              X_CI_START_DT                   => X_CI_START_DT,
              X_CI_END_DT                     => X_CI_END_DT,
              X_UOO_ID                        => p_uooid,
              X_ENROLLED_DT                   => X_ENROLLED_DT,
              X_UNIT_ATTEMPT_STATUS           => X_UNIT_ATTEMPT_STATUS,
              X_ADMINISTRATIVE_UNIT_STATUS    => X_ADMINISTRATIVE_UNIT_STATUS,
              X_DISCONTINUED_DT               => X_DISCONTINUED_DT,
              X_RULE_WAIVED_DT                => X_RULE_WAIVED_DT,
              X_RULE_WAIVED_PERSON_ID         => X_RULE_WAIVED_PERSON_ID,
              X_NO_ASSESSMENT_IND             => X_NO_ASSESSMENT_IND,
              X_SUP_UNIT_CD                   => X_SUP_UNIT_CD,
              X_SUP_VERSION_NUMBER            => X_SUP_VERSION_NUMBER,
              X_EXAM_LOCATION_CD              => X_EXAM_LOCATION_CD,
              X_ALTERNATIVE_TITLE             => X_ALTERNATIVE_TITLE,
              X_OVERRIDE_ENROLLED_CP          => X_OVERRIDE_ENROLLED_CP,
              X_OVERRIDE_EFTSU                => X_OVERRIDE_EFTSU,
              X_OVERRIDE_ACHIEVABLE_CP        => X_OVERRIDE_ACHIEVABLE_CP,
              X_OVERRIDE_OUTCOME_DUE_DT       => X_OVERRIDE_OUTCOME_DUE_DT,
              X_OVERRIDE_CREDIT_REASON        => X_OVERRIDE_CREDIT_REASON,
              X_ADMINISTRATIVE_PRIORITY       => X_ADMINISTRATIVE_PRIORITY,
              X_WAITLIST_DT                   => X_WAITLIST_DT,
              X_DCNT_REASON_CD                => X_DCNT_REASON_CD,
              X_GS_VERSION_NUMBER             => X_GS_VERSION_NUMBER,
              X_ENR_METHOD_TYPE               => X_ENR_METHOD_TYPE,
              X_FAILED_UNIT_RULE              => X_FAILED_UNIT_RULE,
              X_CART                          => X_CART,
              X_RSV_SEAT_EXT_ID               => X_RSV_SEAT_EXT_ID,
              X_ORG_UNIT_CD                   => X_ORG_UNIT_CD,
              X_GRADING_SCHEMA_CODE           => X_GRADING_SCHEMA_CODE,
              X_subtitle                      => X_subtitle,
              x_session_id                    => x_session_id,
              X_deg_aud_detail_id             => X_deg_aud_detail_id,
              x_student_career_transcript     => x_student_career_transcript,
              x_student_career_statistics     => x_student_career_statistics,
              x_waitlist_manual_ind           => x_waitlist_manual_ind,
              X_ATTRIBUTE_CATEGORY            => X_ATTRIBUTE_CATEGORY,
              X_ATTRIBUTE1                    => X_ATTRIBUTE1,
              X_ATTRIBUTE2                    => X_ATTRIBUTE2,
              X_ATTRIBUTE3                    => X_ATTRIBUTE3,
              X_ATTRIBUTE4                    => X_ATTRIBUTE4,
              X_ATTRIBUTE5                    => X_ATTRIBUTE5,
              X_ATTRIBUTE6                    => X_ATTRIBUTE6,
              X_ATTRIBUTE7                    => X_ATTRIBUTE7,
              X_ATTRIBUTE8                    => X_ATTRIBUTE8,
              X_ATTRIBUTE9                    => X_ATTRIBUTE9,
              X_ATTRIBUTE10                   => X_ATTRIBUTE10,
              X_ATTRIBUTE11                   => X_ATTRIBUTE11,
              X_ATTRIBUTE12                   => X_ATTRIBUTE12,
              X_ATTRIBUTE13                   => X_ATTRIBUTE13,
              X_ATTRIBUTE14                   => X_ATTRIBUTE14,
              X_ATTRIBUTE15                   => X_ATTRIBUTE15,
              X_ATTRIBUTE16                   => X_ATTRIBUTE16,
              X_ATTRIBUTE17                   => X_ATTRIBUTE17,
              X_ATTRIBUTE18                   => X_ATTRIBUTE18,
              X_ATTRIBUTE19                   => X_ATTRIBUTE19,
              x_ATTRIBUTE20                   => x_ATTRIBUTE20,
              X_WLST_PRIORITY_WEIGHT_NUM      => X_WLST_PRIORITY_WEIGHT_NUM,
              X_WLST_PREFERENCE_WEIGHT_NUM    => X_WLST_PREFERENCE_WEIGHT_NUM,
              X_CORE_INDICATOR_CODE           => X_CORE_INDICATOR_CODE,
              X_UPD_AUDIT_FLAG                => X_UPD_AUDIT_FLAG,
              X_SS_SOURCE_IND                 => X_SS_SOURCE_IND);

   update_plansheet_unitdetails(
              p_person_id  => p_person_id,
              p_course_cd  => p_course_cd,
              p_uooid      => p_uooid,
              p_cartflag   => NULL,
              p_sourceflag => 'SUA',
              p_fieldname  => p_fieldname,
              p_auditval   => p_auditval,
              p_creditval  => p_creditval,
              p_gradingval => p_gradingval);
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END swap_update;

PROCEDURE plan_update(
              p_person_id                     IN NUMBER,
              p_course_cd                     IN VARCHAR2,
              p_uoo_id                         IN NUMBER,
              p_fieldname                     IN VARCHAR2,
              p_auditval                      IN VARCHAR2,
              p_creditval                     IN NUMBER,
              p_gradingval                    IN VARCHAR2,
              p_row_id                        IN VARCHAR2,
              p_term_cal_type                 IN VARCHAR2,
              p_term_ci_sequence_number       IN NUMBER,
              p_no_assessment_ind             IN VARCHAR2,
              p_sup_uoo_id                    IN NUMBER,
              p_override_enrolled_cp          IN NUMBER,
              p_grading_schema_code           IN VARCHAR2,
              p_gs_version_number             IN NUMBER,
              p_core_indicator_code           IN VARCHAR2,
              p_alternative_title             IN VARCHAR2,
              p_cart_error_flag               IN VARCHAR2,
              p_session_id                    IN NUMBER
              )
------------------------------------------------------------------
  --Created byp  : Chanchal
  --Date creatped: 30-Jul-2005
  --
  --Purpose: autonomous wrapper over update_plansheet_utnidetails to
  --         update planning sheet record.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
-------------------------------------------------------------------
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  igs_en_plan_units_pkg.lock_row (
    x_rowid                             => p_row_id,
    x_person_id                         => p_person_id,
    x_course_cd                         => p_course_cd,
    x_uoo_id                            => p_uoo_id,
    x_term_cal_type                     => p_term_cal_type,
    x_term_ci_sequence_number           => p_term_ci_sequence_number,
    x_no_assessment_ind                 => p_no_assessment_ind,
    x_sup_uoo_id                        => p_sup_uoo_id,
    x_override_enrolled_cp              => p_override_enrolled_cp,
    x_grading_schema_code               => p_grading_schema_code,
    x_gs_version_number                 => p_gs_version_number,
    x_core_indicator_code               => p_core_indicator_code,
    x_alternative_title                 => p_alternative_title,
    x_cart_error_flag                   => p_cart_error_flag,
    x_session_id                        => p_session_id
  );
   update_plansheet_unitdetails(
              p_person_id  => p_person_id,
              p_course_cd  => p_course_cd,
              p_uooid      => p_uoo_id,
              p_cartflag   => p_cart_error_flag,
              p_sourceflag => 'PLAN',
              p_fieldname  => p_fieldname,
              p_auditval   => p_auditval,
              p_creditval  => p_creditval,
              p_gradingval => p_gradingval);
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END plan_update;


-- This procedure releases the seats as the unit sections are dropped as a part of DROP page
-- 	smaddali 8-dec-2005   added new procedure to  update spa status,
-- matriculation , seat counts and reserved seat counts for DROP : bug#4864437
PROCEDURE drop_submit (person_id IN NUMBER,
                       program_cd IN VARCHAR2,
                       p_uoo_ids IN VARCHAR2) AS
  CURSOR cur_sua(cp_person_id IN NUMBER,cp_program_cd IN VARCHAR2,cp_uoo_id IN NUMBER) IS
    SELECT *
    FROM IGS_EN_SU_ATTEMPT_ALL
    WHERE person_id = cp_person_id
    AND   course_cd = cp_program_cd
    AND   uoo_Id = cp_uoo_Id;

  CURSOR cur_igs_ps_rsv_ext (cp_rsv_ext_id igs_ps_rsv_ext.rsv_ext_id%TYPE) IS
    SELECT rsv.ROWID row_id, rsv.*
    FROM   igs_ps_rsv_ext rsv
    WHERE  rsv_ext_id = cp_rsv_ext_id FOR UPDATE;

    l_cur_igs_ps_rsv_ext  cur_igs_ps_rsv_ext%ROWTYPE;
    l_rsv_ext_id          igs_ps_rsv_ext.rsv_ext_id%TYPE;
  old_rec igs_en_su_attempt_all%rowTYPE;
  new_rec igs_en_su_attempt_all%ROWTYPE;
  l_uoo_ids varchar2(30);
  l_cur_uoo_id varchar2(30);
  pos number;
  v_message_name VARCHAR2(30);

  PROCEDURE get_old_sua (p_person_id IN NUMBER,p_program_cd IN VARCHAR2,p_uoo_id IN NUMBER,
                  p_sua_rec OUT NOCOPY igs_en_su_attempt_all%ROWTYPE  ) AS
    PRAGMA AUTONOMOUS_TRANSACTION;

    CURSOR c_old_sua IS
     SELECT *
    FROM IGS_EN_SU_ATTEMPT_ALL
    WHERE person_id = p_person_id
    AND   course_cd = p_program_cd
    AND   uoo_Id = p_uoo_Id;
    c_old_sua_rec c_old_sua%ROWTYPE;

  BEGIN
      OPEN c_old_sua;
       FETCH c_old_sua INTO p_sua_rec;
       CLOSE c_old_sua;
       ROLLBACK;
       RETURN ;

  END;

BEGIN
  l_uoo_ids := p_uoo_ids;
  WHILE l_uoo_ids is not null LOOP
     pos := instr(l_uoo_ids,',',1);
     IF pos=0 THEN
      l_cur_uoo_id := l_uoo_ids;
      l_uoo_ids := null;
     ELSE
      l_cur_uoo_id := substr(l_uoo_ids,0,pos-1);
      l_uoo_ids := substr(l_uoo_ids,pos+1,length(l_uoo_ids));
     END IF;

     -- fetch the old sua record, since this transaction is not commited,
     -- get it from an autonomous transaction
     old_rec := NULL;
     new_rec := NULL;
      get_old_sua(person_id, program_cd, l_cur_uoo_id,old_rec) ;

     -- fetch the new sua record
     OPEN cur_sua(person_id, program_cd, l_cur_uoo_id);
     FETCH cur_sua INTO new_rec;
     CLOSE cur_sua;

       -- if reserve seating is existing then need to decrement the actual seat enrolled
       -- which was not done during swap drop.
       -- checking if the unit attempt status has been changed from ENROLLED/INVALID to DROPPED/DISCONTIN
       IF  (old_rec.unit_attempt_status IN ('ENROLLED','INVALID')
           AND (new_rec.unit_attempt_status IN ('DROPPED','DISCONTIN'))) THEN
            IF ( old_rec.rsv_seat_ext_id =  new_rec.rsv_seat_ext_id ) THEN
               l_rsv_ext_id := old_rec.rsv_seat_ext_id;
            ELSE
               l_rsv_ext_id := new_rec.rsv_seat_ext_id;
            END IF;

            OPEN  cur_igs_ps_rsv_ext(l_rsv_ext_id);
            FETCH cur_igs_ps_rsv_ext INTO l_cur_igs_ps_rsv_ext;
            CLOSE cur_igs_ps_rsv_ext;


            -- If the unit attempt status is changed then the actual seats enrolled column has to be decreased by one
            IF ((l_cur_igs_ps_rsv_ext.actual_seat_enrolled -1) >= 0) THEN
                igs_ps_rsv_ext_pkg.update_row( x_rowid                => l_cur_igs_ps_rsv_ext.row_id,
                                               x_rsv_ext_id           => l_cur_igs_ps_rsv_ext.rsv_ext_id,
                                               x_uoo_id               => l_cur_igs_ps_rsv_ext.uoo_id,
                                               x_priority_id          => l_cur_igs_ps_rsv_ext.priority_id,
                                               x_preference_id        => l_cur_igs_ps_rsv_ext.preference_id,
                                               x_rsv_level            => l_cur_igs_ps_rsv_ext.rsv_level,
                                               x_actual_seat_enrolled => l_cur_igs_ps_rsv_ext.actual_seat_enrolled -1,
                                               x_mode                 => 'R'
                                             );
            END IF;
         END IF;


         IF IGS_EN_GEN_012.ENRP_UPD_SCA_STATUS(
            new_rec.person_id,
            new_rec.course_cd,
            v_message_name) = FALSE THEN
            FND_MESSAGE.SET_NAME('IGS',v_message_name);
            IGS_GE_MSG_STACK.ADD;
            APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

         IGS_EN_GEN_003.UPD_MAT_MRADM_CAT_TERMS(new_rec.person_id,
                                                new_rec.course_cd,
                                                new_rec.unit_attempt_status,
                                                new_rec.cal_type,
                                                new_rec.ci_sequence_number
                                               ) ;

         igs_en_sua_api.upd_enrollment_counts( 'UPDATE',
                                               old_rec,
                                               new_rec);
  END LOOP;

END drop_submit;


    FUNCTION get_sua_fin_mark(p_person_id IN  igs_en_su_attempt_all.person_id%TYPE,
                              p_course_cd IN igs_en_su_attempt_all.course_Cd%TYPE,
                              p_uoo_id IN igs_en_su_attempt_all.uoo_id%TYPE)
     RETURN NUMBER IS

         CURSOR c_suao IS
         SELECT susv.mark
         FROM igs_as_su_stmptout susv
         WHERE
         susv.PERSON_ID = p_person_id  AND
         susv.course_cd =p_course_cd AND
         susv.uoo_id = p_uoo_id AND
         susv.finalised_outcome_ind  = 'Y' and
         susv.grading_period_cd  <> 'MIDTERM'
         ORDER BY susv.outcome_dt DESC ;

         l_mark igs_as_su_stmptout.mark%TYPE;

     BEGIN
          OPEN c_suao;
          FETCH c_suao INTO l_mark;
          CLOSE c_suao;
          RETURN l_mark;
     END get_sua_fin_mark;

     FUNCTION get_sua_fin_grade(p_person_id IN   igs_en_su_attempt_all.person_id%TYPE,
                               p_course_cd IN igs_en_su_attempt_all.course_Cd%TYPE,
                               p_uoo_id IN igs_en_su_attempt_all.uoo_id%TYPE)
     RETURN VARCHAR2 IS

         CURSOR c_suao IS
         SELECT susv.grade
         FROM igs_as_su_stmptout susv
         WHERE
         susv.PERSON_ID = p_person_id  AND
         susv.course_cd =p_course_cd AND
          susv.uoo_id = p_uoo_id AND
          susv.finalised_outcome_ind  = 'Y' and
         susv.grading_period_cd  <> 'MIDTERM'
         ORDER BY susv.outcome_dt DESC ;

         l_grade igs_as_su_stmptout.grade%TYPE;

     BEGIN
          OPEN c_suao;
          FETCH c_suao INTO l_grade;
          CLOSE c_suao;
          RETURN l_grade;

     END get_sua_fin_grade;

END IGS_EN_PLAN_UTILS;

/
