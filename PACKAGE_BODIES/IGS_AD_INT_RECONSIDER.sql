--------------------------------------------------------
--  DDL for Package Body IGS_AD_INT_RECONSIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_INT_RECONSIDER" AS
/* $Header: IGSADD6B.pls 120.3 2006/05/26 07:17:44 pfotedar noship $ */

FUNCTION  copy_candidacy_records(p_new_admission_appl_number IGS_AD_APPL_ALL.admission_appl_number%TYPE,
                                 p_new_sequence_number       IGS_AD_PS_APPL_INST_ALL.sequence_number%TYPE,
                                 p_person_id                 HZ_PARTIES.party_id%TYPE,
                                 p_old_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                                 p_old_sequence_number       IGS_AD_PS_APPL_INST_ALL.sequence_number%TYPE,
                                 p_nominated_course_cd       IGS_AD_PS_APPL_ALL.nominated_course_cd%TYPE,
                                 p_start_dt                  DATE)
          RETURN BOOLEAN AS

/*******************************************************************************
Created by  : Rishi Ghosh
Date created: 01-JUN-2004

Purpose: To copy candidacy records from the current applicationto the
         Future-Term application. This procedure is also used for
         creating deferment application. (Bug#3656905)


Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/

l_get_modified_comm_dt DATE;

CURSOR c_get_candidature (cp_person_id igs_re_candidature.person_id%TYPE,
                          cp_acai_admission_appl_number igs_re_candidature.acai_admission_appl_number%TYPE,
                          cp_acai_nominated_course_cd igs_re_candidature.acai_nominated_course_cd%TYPE,
                          cp_acai_sequence_number igs_re_candidature.acai_sequence_number%TYPE) IS
  SELECT *
  FROM igs_re_candidature
  WHERE person_id = cp_person_id
  AND acai_admission_appl_number = cp_acai_admission_appl_number
  AND acai_nominated_course_cd = cp_acai_nominated_course_cd
  AND acai_sequence_number = cp_acai_sequence_number;

CURSOR c_get_candidature_sequence IS
  SELECT igs_re_candidature_seq_num_s.nextval
  FROM dual;

l_get_candidature_sequence igs_re_candidature.sequence_number%TYPE;

CURSOR c_get_thesis (cp_person_id igs_re_thesis_all.person_id%TYPE,
                     cp_ca_sequence_number igs_re_thesis_all.ca_sequence_number%TYPE) IS
  SELECT *
  FROM igs_re_thesis_all
  WHERE person_id = cp_person_id
  AND ca_sequence_number = cp_ca_sequence_number;

CURSOR c_get_thesis_sequence IS
  SELECT	igs_re_thesis_seq_num_s.nextval
  FROM	dual;

l_get_thesis_sequence igs_re_thesis_all.sequence_number%TYPE;

CURSOR c_get_cdt_fld_of_sy (cp_person_id igs_re_cdt_fld_of_sy.person_id%TYPE,
                            cp_ca_sequence_number igs_re_cdt_fld_of_sy.ca_sequence_number%TYPE) IS
  SELECT *
  FROM igs_re_cdt_fld_of_sy
  WHERE person_id = cp_person_id
  AND ca_sequence_number = cp_ca_sequence_number;

CURSOR c_get_cand_seo_cls (cp_person_id igs_re_cand_seo_cls.person_id%TYPE,
                           cp_ca_sequence_number igs_re_cand_seo_cls.ca_sequence_number%TYPE) IS
  SELECT *
  FROM igs_re_cand_seo_cls
  WHERE person_id = cp_person_id
  AND ca_sequence_number = cp_ca_sequence_number;

CURSOR c_get_scholarship (cp_person_id igs_re_scholarship_all.person_id%TYPE,
                          cp_ca_sequence_number igs_re_scholarship_all.ca_sequence_number%TYPE) IS
  SELECT *
  FROM igs_re_scholarship_all
  WHERE person_id = cp_person_id
  AND ca_sequence_number = cp_ca_sequence_number;

CURSOR c_get_milestone (cp_person_id igs_pr_milestone_all.person_id%TYPE,
                        cp_ca_sequence_number igs_pr_milestone_all.ca_sequence_number%TYPE) IS
  SELECT *
  FROM igs_pr_milestone_all
  WHERE person_id = cp_person_id
  AND ca_sequence_number = cp_ca_sequence_number;

CURSOR c_get_supervisor (cp_ca_person_id igs_re_sprvsr.ca_person_id%TYPE,
                         cp_ca_sequence_number igs_re_sprvsr.ca_sequence_number%TYPE) IS
  SELECT *
  FROM igs_re_sprvsr
  WHERE ca_person_id = cp_ca_person_id
  AND ca_sequence_number = cp_ca_sequence_number
  ORDER BY start_dt,end_dt;

CURSOR c_get_thesis_exam (cp_person_id igs_re_thesis_exam.person_id%TYPE,
                          cp_ca_sequence_number igs_re_thesis_exam.ca_sequence_number%TYPE,
                          cp_the_sequence_number igs_re_thesis_exam.the_sequence_number%TYPE) IS
  SELECT *
  FROM igs_re_thesis_exam
  WHERE person_id = cp_person_id
  AND ca_sequence_number = cp_ca_sequence_number
  AND the_sequence_number = cp_the_sequence_number;

CURSOR c_get_thesis_panel_memb (cp_ca_person_id  igs_re_ths_pnl_mbr.ca_person_id%TYPE,
                                cp_ca_sequence_number  igs_re_ths_pnl_mbr.ca_sequence_number%TYPE,
                                cp_the_sequence_number  igs_re_ths_pnl_mbr.the_sequence_number%TYPE,
                                cp_creation_dt  igs_re_ths_pnl_mbr.creation_dt%TYPE) IS
  SELECT *
  FROM igs_re_ths_pnl_mbr
  WHERE ca_person_id = cp_ca_person_id
  AND ca_sequence_number = cp_ca_sequence_number
  AND the_sequence_number = cp_the_sequence_number
  AND creation_dt = cp_creation_dt;


l_rowid VARCHAR2(30);
l_rowid_child1 VARCHAR2(30);
l_rowid_child2 VARCHAR2(30);
l_rowid_child3 VARCHAR2(30);

l_min_submission_dt igs_re_candidature.min_submission_dt%TYPE;
l_max_submission_dt igs_re_candidature.max_submission_dt%TYPE;

l_supvsr_start_dt igs_re_sprvsr.start_dt%TYPE;
l_supvsr_end_dt igs_re_sprvsr.end_dt%TYPE;
l_comm_date_offset NUMBER;


l_submission_dt igs_re_thesis_exam.submission_dt%TYPE;
l_expected_submission_dt igs_re_thesis.expected_submission_dt%TYPE;
l_embargo_expiry_dt igs_re_thesis.embargo_expiry_dt%TYPE;

l_sysdate DATE ;

v_message_name VARCHAR2(30);


BEGIN

  l_sysdate := SYSDATE;


  l_get_modified_comm_dt := IGS_RE_GEN_001.RESP_GET_CA_COMM(
                                                            p_person_id,
                                                            NULL,
                                                            p_old_admission_appl_number,
                                                            p_nominated_course_cd,
                                                            p_old_sequence_number);


  FOR  l_get_candidature_rec IN c_get_candidature(p_person_id,
                                                  p_old_admission_appl_number,
                                                  p_nominated_course_cd,
                                                  p_old_sequence_number) LOOP

    v_message_name:= 'IGS_AD_RSCH_CAND';


    l_comm_date_offset := TRUNC(p_start_dt) - TRUNC(l_get_modified_comm_dt);

    l_min_submission_dt := l_get_candidature_rec.min_submission_dt + l_comm_date_offset;
    l_max_submission_dt := l_get_candidature_rec.max_submission_dt + l_comm_date_offset;

    OPEN c_get_candidature_sequence;
    FETCH c_get_candidature_sequence INTO l_get_candidature_sequence;
    CLOSE c_get_candidature_sequence;

    l_rowid := NULL;

    IGS_RE_CANDIDATURE_PKG.INSERT_ROW(
      X_ROWID                        => l_rowid,
      X_PERSON_ID                    => p_person_id,
      X_SEQUENCE_NUMBER              => l_get_candidature_sequence,
      X_SCA_COURSE_CD                => l_get_candidature_rec.sca_course_cd,
      X_ACAI_ADMISSION_APPL_NUMBER   => p_new_admission_appl_number,
      X_ACAI_NOMINATED_COURSE_CD     => p_nominated_course_cd,
      X_ACAI_SEQUENCE_NUMBER         => p_new_sequence_number,
      X_ATTENDANCE_PERCENTAGE        => l_get_candidature_rec.attendance_percentage,
      X_GOVT_TYPE_OF_ACTIVITY_CD     => l_get_candidature_rec.govt_type_of_activity_cd,
      X_MAX_SUBMISSION_DT            => l_max_submission_dt,
      X_MIN_SUBMISSION_DT            => l_min_submission_dt,
      X_RESEARCH_TOPIC               => l_get_candidature_rec.research_topic,
      X_INDUSTRY_LINKS               => l_get_candidature_rec.industry_links,
      X_MODE                         => 'R',
      X_ORG_ID                       => l_get_candidature_rec.org_id
      );

    FOR l_get_thesis_rec IN c_get_thesis(p_person_id,l_get_candidature_rec.sequence_number) LOOP

      v_message_name:= 'IGS_AD_RSCH_THS';

      l_expected_submission_dt := l_get_thesis_rec.expected_submission_dt + l_comm_date_offset;
      l_embargo_expiry_dt := l_get_thesis_rec.embargo_expiry_dt + l_comm_date_offset;

      IF l_get_thesis_rec.logical_delete_dt IS NULL THEN

        OPEN c_get_thesis_sequence;
     	FETCH c_get_thesis_sequence INTO l_get_thesis_sequence;
  	CLOSE c_get_thesis_sequence;

        l_rowid_child1 := NULL;

        IGS_RE_THESIS_PKG.INSERT_ROW(
          X_ROWID                        => l_rowid_child1,
          X_PERSON_ID                    => p_person_id,
          X_CA_SEQUENCE_NUMBER           => l_get_candidature_sequence,
          X_SEQUENCE_NUMBER              => l_get_thesis_sequence,
          X_TITLE                        => l_get_thesis_rec.title,
          X_FINAL_TITLE_IND              => l_get_thesis_rec.final_title_ind,
          X_SHORT_TITLE                  => l_get_thesis_rec.short_title,
          X_ABBREVIATED_TITLE            => l_get_thesis_rec.abbreviated_title,
          X_THESIS_RESULT_CD             => l_get_thesis_rec.thesis_result_cd,
          X_EXPECTED_SUBMISSION_DT       => l_expected_submission_dt,
          X_LIBRARY_LODGEMENT_DT         => l_get_thesis_rec.library_lodgement_dt,
          X_LIBRARY_CATALOGUE_NUMBER     => l_get_thesis_rec.library_catalogue_number,
          X_EMBARGO_EXPIRY_DT            => l_get_thesis_rec.embargo_expiry_dt,
          X_THESIS_FORMAT                => l_get_thesis_rec.thesis_format,
          X_LOGICAL_DELETE_DT            => l_get_thesis_rec.logical_delete_dt,
          X_EMBARGO_DETAILS              => l_embargo_expiry_dt,
          X_THESIS_TOPIC                 => l_get_thesis_rec.thesis_topic,
          X_CITATION                     => l_get_thesis_rec.citation,
          X_COMMENTS                     => l_get_thesis_rec.comments,
          X_MODE                         => 'R',
          X_ORG_ID                       => l_get_thesis_rec.org_id
          );

          FOR l_get_thesis_exam_rec IN c_get_thesis_exam (p_person_id,
                                                          l_get_candidature_rec.sequence_number,
                                                          l_get_thesis_rec.sequence_number) LOOP

            v_message_name:= 'IGS_AD_RSCH_EXAM';

            l_submission_dt := l_get_thesis_exam_rec.submission_dt + l_comm_date_offset;
            l_rowid_child2 := NULL;

            IGS_RE_THESIS_EXAM_PKG.INSERT_ROW(
              X_ROWID                => l_rowid_child2,
              X_PERSON_ID            => p_person_id,
              X_CA_SEQUENCE_NUMBER   => l_get_candidature_sequence,
              X_THE_SEQUENCE_NUMBER  => l_get_thesis_sequence,
              X_CREATION_DT          => l_sysdate,
              X_SUBMISSION_DT        => l_submission_dt,
              X_THESIS_EXAM_TYPE     => l_get_thesis_exam_rec.thesis_exam_type,
              X_THESIS_PANEL_TYPE    => l_get_thesis_exam_rec.thesis_panel_type,
              X_TRACKING_ID          => l_get_thesis_exam_rec.tracking_id,
              X_THESIS_RESULT_CD     => l_get_thesis_exam_rec.thesis_result_cd,
              X_MODE                 => 'R'
              );

              FOR l_get_thesis_panel_memb_rec IN c_get_thesis_panel_memb (p_person_id,
                                                                        l_get_candidature_rec.sequence_number,
                                                                        l_get_thesis_rec.sequence_number,
                                                                        l_get_thesis_exam_rec.creation_dt) LOOP

                v_message_name:= 'IGS_AD_RSCH_EXAM_PNL_MEM';

                l_rowid_child3 := NULL;

                IGS_RE_THS_PNL_MBR_PKG.INSERT_ROW(
                  X_ROWID                        => l_rowid_child3,
                  X_CA_PERSON_ID                 => p_person_id,
                  X_CA_SEQUENCE_NUMBER           => l_get_candidature_sequence,
                  X_THE_SEQUENCE_NUMBER          => l_get_thesis_sequence,
                  X_CREATION_DT                  => l_sysdate,
                  X_PERSON_ID                    => l_get_thesis_panel_memb_rec.person_id,
                  X_PANEL_MEMBER_TYPE            => l_get_thesis_panel_memb_rec.panel_member_type,
                  X_CONFIRMED_DT                 => l_get_thesis_panel_memb_rec.confirmed_dt,
                  X_DECLINED_DT                  => l_get_thesis_panel_memb_rec.declined_dt,
                  X_ANONYMITY_IND                => l_get_thesis_panel_memb_rec.anonymity_ind,
                  X_THESIS_RESULT_CD             => l_get_thesis_panel_memb_rec.thesis_result_cd,
                  X_PAID_DT                      => l_get_thesis_panel_memb_rec.paid_dt,
                  X_TRACKING_ID                  => l_get_thesis_panel_memb_rec.tracking_id,
                  X_RECOMMENDATION_SUMMARY       => l_get_thesis_panel_memb_rec.recommendation_summary,
                  X_MODE                         => 'R'
                  );

              END LOOP;

          END LOOP;

        END IF;

      END LOOP;

    FOR l_get_cdt_fld_of_sy_rec IN c_get_cdt_fld_of_sy(p_person_id,l_get_candidature_rec.sequence_number) LOOP

      v_message_name:= 'IGS_AD_RSCH_CAND_FOS';

      l_rowid_child1 := NULL;

      IGS_RE_CDT_FLD_OF_SY_PKG.INSERT_ROW(
        X_ROWID                => l_rowid_child1,
        X_PERSON_ID            => p_person_id,
        X_CA_SEQUENCE_NUMBER   => l_get_candidature_sequence,
        X_FIELD_OF_STUDY       => l_get_cdt_fld_of_sy_rec.field_of_study,
        X_PERCENTAGE           => l_get_cdt_fld_of_sy_rec.percentage,
        X_MODE                 => 'R'
      );

    END LOOP;

    FOR l_get_cand_seo_cls_rec IN c_get_cand_seo_cls(p_person_id,l_get_candidature_rec.sequence_number) LOOP

      v_message_name:= 'IGS_AD_RSCH_SEO';

      l_rowid_child1 := NULL;

      IGS_RE_CAND_SEO_CLS_PKG.INSERT_ROW(
        X_ROWID                => l_rowid_child1,
        X_PERSON_ID            => p_person_id,
        X_CA_SEQUENCE_NUMBER   => l_get_candidature_sequence,
        X_SEO_CLASS_CD         => l_get_cand_seo_cls_rec.seo_class_cd,
        X_PERCENTAGE           => l_get_cand_seo_cls_rec.percentage,
        X_MODE                 => 'R'
        );

    END LOOP;

    FOR l_get_scholarship_rec IN c_get_scholarship(p_person_id,l_get_candidature_rec.sequence_number) LOOP

      v_message_name:= 'IGS_AD_RSCH_SCH';

      l_rowid_child1 := NULL;

      IGS_RE_SCHOLARSHIP_PKG.INSERT_ROW(
        X_ROWID                => l_rowid_child1,
        X_PERSON_ID            => p_person_id,
        X_CA_SEQUENCE_NUMBER   => l_get_candidature_sequence,
        X_SCHOLARSHIP_TYPE     => l_get_scholarship_rec.scholarship_type,
        X_START_DT             => l_get_scholarship_rec.start_dt,
        X_END_DT               => l_get_scholarship_rec.end_dt,
        X_DOLLAR_VALUE         => l_get_scholarship_rec.dollar_value,
        X_DESCRIPTION          => l_get_scholarship_rec.description,
        X_OTHER_BENEFITS       => l_get_scholarship_rec.other_benefits,
        X_CONDITIONS           => l_get_scholarship_rec.conditions,
        X_MODE                 => 'R',
        X_ORG_ID               => l_get_scholarship_rec.org_id
        );

    END LOOP;

    FOR l_get_milestone_rec IN c_get_milestone(p_person_id,l_get_candidature_rec.sequence_number) LOOP

      v_message_name:= 'IGS_AD_RSCH_PR_MLSTN';

      l_rowid_child1 := NULL;

      IGS_PR_MILESTONE_PKG.INSERT_ROW(
        X_ROWID                        => l_rowid_child1,
        X_PERSON_ID                    => p_person_id,
        X_CA_SEQUENCE_NUMBER           => l_get_candidature_sequence,
        X_SEQUENCE_NUMBER              => l_get_milestone_rec.sequence_number,
        X_MILESTONE_TYPE               => l_get_milestone_rec.milestone_type,
        X_MILESTONE_STATUS             => l_get_milestone_rec.milestone_status,
        X_DUE_DT                       => l_get_milestone_rec.due_dt,
        X_DESCRIPTION                  => l_get_milestone_rec.description,
        X_ACTUAL_REACHED_DT            => l_get_milestone_rec.actual_reached_dt,
        X_PRECED_SEQUENCE_NUMBER       => l_get_milestone_rec.preced_sequence_number,
        X_OVRD_NTFCTN_IMMINENT_DAYS    => l_get_milestone_rec.ovrd_ntfctn_imminent_days,
        X_OVRD_NTFCTN_REMINDER_DAYS    => l_get_milestone_rec.ovrd_ntfctn_reminder_days,
        X_OVRD_NTFCTN_RE_REMINDER_DAYS => l_get_milestone_rec.ovrd_ntfctn_re_reminder_days,
        X_COMMENTS                     => l_get_milestone_rec.comments,
        X_MODE                         => 'R',
        X_ORG_ID                       => l_get_milestone_rec.org_id
        );

    END LOOP;

    FOR l_get_supervisor_rec IN c_get_supervisor(p_person_id,l_get_candidature_rec.sequence_number) LOOP

      v_message_name:= 'IGS_AD_RSCH_SPVSR';

      l_supvsr_start_dt := l_get_supervisor_rec.start_dt + l_comm_date_offset;
      l_supvsr_end_dt := l_get_supervisor_rec.end_dt + l_comm_date_offset;

      l_rowid_child1 := NULL;

      IGS_RE_SPRVSR_PKG.INSERT_ROW(
        X_ROWID                        => l_rowid_child1,
        X_CA_PERSON_ID                 => p_person_id,
        X_CA_SEQUENCE_NUMBER           => l_get_candidature_sequence,
        X_PERSON_ID                    => l_get_supervisor_rec.person_id,
        X_SEQUENCE_NUMBER              => l_get_supervisor_rec.sequence_number,
        X_START_DT                     => l_supvsr_start_dt,
        X_END_DT                       => l_supvsr_end_dt,
        X_RESEARCH_SUPERVISOR_TYPE     => l_get_supervisor_rec.research_supervisor_type,
        X_SUPERVISOR_PROFESSION        => l_get_supervisor_rec.supervisor_profession,
        X_SUPERVISION_PERCENTAGE       => l_get_supervisor_rec.supervision_percentage,
        X_FUNDING_PERCENTAGE           => l_get_supervisor_rec.funding_percentage,
        X_ORG_UNIT_CD                  => l_get_supervisor_rec.org_unit_cd,
        X_OU_START_DT                  => l_get_supervisor_rec.ou_start_dt,
        X_REPLACED_PERSON_ID           => l_get_supervisor_rec.replaced_person_id,
        X_REPLACED_SEQUENCE_NUMBER     => l_get_supervisor_rec.replaced_sequence_number,
        X_COMMENTS                     => l_get_supervisor_rec.comments,
        X_MODE                         => 'R'
        );


    END LOOP;

  END LOOP;

  RETURN TRUE;

EXCEPTION WHEN OTHERS THEN

  FND_MESSAGE.SET_NAME('IGS','IGS_AD_CAND_COPY_FAIL');
  Fnd_File.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGS',v_message_name);
  fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET || SQLERRM);

  RETURN FALSE;

END copy_candidacy_records;


FUNCTION copy_application_child_records (p_person_id                 HZ_PARTIES.party_id%TYPE,
                                         p_new_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                                         p_old_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
					 p_nominated_course_cd       IGS_AD_PS_APPL_INST_ALL.nominated_course_cd%TYPE,
					 p_sequence_number           IGS_AD_PS_APPL_INST_ALL.sequence_number%TYPE)
RETURN BOOLEAN IS

-- other institutitons

CURSOR c_othinst_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE)
IS
SELECT
  other_inst_id,
  person_id ,
  admission_appl_number ,
  nominated_course_cd ,
  sequence_number ,
  institution_code,
  new_institution
FROM
  igs_ad_other_inst
WHERE
  person_id = cp_person_id       and
  admission_appl_number = cp_admission_appl_number;


-- personal statements
CURSOR c_perstat_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE)
IS
SELECT
  appl_perstat_id,
  person_id       ,
  admission_appl_number  ,
  persl_stat_type        ,
  date_received
FROM
  igs_ad_appl_perstat
WHERE
  person_id = cp_person_id       and
  admission_appl_number = cp_admission_appl_number;


-- academic interests
CURSOR c_acadint_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE)
IS
SELECT
  acad_interest_id ,
  person_id ,
  admission_appl_number  ,
  field_of_study
FROM
  igs_ad_acad_interest
WHERE
  person_id = cp_person_id       and
  admission_appl_number = cp_admission_appl_number;

--applicant intent
CURSOR c_appint_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE)
IS
SELECT
  app_intent_id,
  person_id      ,
  admission_appl_number,
  intent_type_id   ,
  attribute_category,
  attribute1   ,
  attribute2  ,
  attribute3  ,
  attribute4  ,
  attribute5  ,
  attribute6  ,
  attribute7  ,
  attribute8  ,
  attribute9  ,
  attribute10 ,
  attribute11 ,
  attribute12 ,
  attribute13 ,
  attribute14 ,
  attribute15 ,
  attribute16 ,
  attribute17 ,
  attribute18 ,
  attribute19 ,
  attribute20
FROM
  igs_ad_app_intent
WHERE
  person_id = cp_person_id       and
  admission_appl_number = cp_admission_appl_number;


-- Special Interests
CURSOR c_splint_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE)
IS
SELECT
  spl_interest_id                ,
  person_id                      ,
  admission_appl_number          ,
  special_interest_type_id
FROM
  igs_ad_spl_interests
WHERE
  person_id = cp_person_id       and
  admission_appl_number = cp_admission_appl_number;

--spl talents
CURSOR c_spltal_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE)
IS
SELECT
  spl_talent_id         ,
  person_id               ,
  admission_appl_number          ,
  special_talent_type_id
FROM
  igs_ad_spl_talents
WHERE
  person_id = cp_person_id       and
  admission_appl_number = cp_admission_appl_number;

-- Fees
CURSOR c_fee_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                 cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE
                )IS
SELECT
  app_req_id ,
  person_id   ,
  admission_appl_number ,
  applicant_fee_type,
  applicant_fee_status,
  fee_date,
  fee_payment_method,
  fee_amount,
  reference_num,
  credit_card_code,
  credit_card_holder_name,
  credit_card_number,
  credit_card_expiration_date,
  rev_gl_ccid,
  cash_gl_ccid,
  rev_account_cd,
  cash_account_cd,
  gl_date,
  gl_posted_date,
  posting_control_id,
  credit_card_tangible_cd,
  credit_card_payee_cd,
  credit_card_status_code
FROM
  igs_ad_app_req
WHERE
  person_id = cp_person_id AND
  admission_appl_number = cp_admission_appl_number;

l_last_error VARCHAR2(50);

l_rowid ROWID;

l_primary_key NUMBER(15);

BEGIN

--OTHER INSTITUTIONS

FOR  c_othinst_rec IN c_othinst_cur(p_person_id, p_old_admission_appl_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_OTH_INST';
IGS_AD_OTHER_INST_PKG.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_OTHER_INST_ID   =>  l_primary_key,
        X_PERSON_ID  => c_othinst_rec.person_id,
        X_ADMISSION_APPL_NUMBER   =>p_new_admission_appl_number,
        X_INSTITUTION_CODE  => c_othinst_rec.institution_code,
        X_MODE => 'R',
	X_NEW_INSTITUTION => c_othinst_rec.new_institution );
END LOOP;

l_rowid := NULL;

-- Personal Statements
FOR  c_perstat_rec IN c_perstat_cur(p_person_id, p_old_admission_appl_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_PER_STAT';
  igs_ad_appl_perstat_pkg.insert_row(
         x_rowid  => l_rowid,
         x_appl_perstat_id => c_perstat_rec.appl_perstat_id,
         x_person_id  => c_perstat_rec.person_id,
         x_admission_appl_number => p_new_admission_appl_number,
         x_persl_stat_type => c_perstat_rec.persl_stat_type,
         x_date_received => c_perstat_rec.date_received,
         x_mode => 'R');
END LOOP;


l_rowid := NULL;

-- ACADMEIC INTERESTS
FOR  c_acadint_rec IN c_acadint_cur(p_person_id, p_old_admission_appl_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_ACAD_INT';
igs_ad_acad_interest_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_ACAD_INTEREST_ID =>  l_primary_key,
        X_PERSON_ID   => c_acadint_rec.person_id,
        X_ADMISSION_APPL_NUMBER => p_new_admission_appl_number,
        X_FIELD_OF_STUDY  => c_acadint_rec.field_of_study,
         X_MODE => 'R');
END LOOP;


l_rowid := NULL;


--applicant intent
FOR  c_appint_rec IN c_appint_cur(p_person_id, p_old_admission_appl_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_APPL_INTENT';
igs_ad_app_intent_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_APP_INTENT_ID  =>  l_primary_key,
        X_PERSON_ID        => c_appint_rec.person_id,
        X_ADMISSION_APPL_NUMBER   => p_new_admission_appl_number,
        X_INTENT_TYPE_ID   => c_appint_rec.intent_type_id,
        X_ATTRIBUTE_CATEGORY   => c_appint_rec.attribute_category,
        X_ATTRIBUTE1    => c_appint_rec.attribute1,
        X_ATTRIBUTE2   => c_appint_rec.attribute2,
        X_ATTRIBUTE3   => c_appint_rec.attribute3,
        X_ATTRIBUTE4  => c_appint_rec.attribute4  ,
        X_ATTRIBUTE5    => c_appint_rec.attribute5,
        X_ATTRIBUTE6    => c_appint_rec.attribute6,
        X_ATTRIBUTE7   => c_appint_rec.attribute7  ,
        X_ATTRIBUTE8  => c_appint_rec.attribute8    ,
        X_ATTRIBUTE9   => c_appint_rec.attribute9    ,
        X_ATTRIBUTE10 => c_appint_rec.attribute10   ,
        X_ATTRIBUTE11   => c_appint_rec.attribute11 ,
        X_ATTRIBUTE12   => c_appint_rec.attribute12 ,
        X_ATTRIBUTE13 => c_appint_rec.attribute13     ,
        X_ATTRIBUTE14   => c_appint_rec.attribute14   ,
        X_ATTRIBUTE15   => c_appint_rec.attribute15   ,
        X_ATTRIBUTE16 => c_appint_rec.attribute16     ,
        X_ATTRIBUTE17   => c_appint_rec.attribute17   ,
        X_ATTRIBUTE18  => c_appint_rec.attribute18    ,
        X_ATTRIBUTE19 => c_appint_rec.attribute19     ,
        X_ATTRIBUTE20   => c_appint_rec.attribute20   ,
         X_MODE => 'R');
END LOOP;

l_rowid := NULL;


-- Special Interests
FOR  c_splint_rec IN c_splint_cur(p_person_id, p_old_admission_appl_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_SPL_INT';
igs_ad_spl_interests_PKG.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_SPL_INTEREST_ID   =>  l_primary_key,
        X_PERSON_ID   => c_splint_rec.person_id,
        X_ADMISSION_APPL_NUMBER  => p_new_admission_appl_number,
        X_SPECIAL_INTEREST_TYPE_ID  => c_splint_rec.special_interest_type_id,
         X_MODE => 'R');
END LOOP;

l_rowid := NULL;

-- Special Talents
FOR  c_spltal_rec IN c_spltal_cur(p_person_id, p_old_admission_appl_number) LOOP
   l_last_error :=  'IGS_AD_CHILD_SPL_TAL';
igs_ad_spl_talents_PKG.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_SPL_TALENT_ID    => l_primary_key,
        X_PERSON_ID   => c_spltal_rec.person_id,
        X_ADMISSION_APPL_NUMBER   => p_new_admission_appl_number,
        X_SPECIAL_TALENT_TYPE_ID  => c_spltal_rec.special_talent_type_id,
         X_MODE => 'R');
END LOOP;

l_rowid := NULL;


-- Fess ( Requirements )


FOR  c_fee_rec IN c_fee_cur(p_person_id, p_old_admission_appl_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_FEE_DET';

igs_ad_app_req_pkg.insert_row(
        x_rowid                        => l_rowid,
        x_app_req_id                   => l_primary_key,
        x_person_id                    => c_fee_rec.person_id,
        x_admission_appl_number        => p_new_admission_appl_number,
        x_applicant_fee_type           => c_fee_rec.applicant_fee_type,
        x_applicant_fee_status         => c_fee_rec.applicant_fee_status,
        x_fee_date                     => c_fee_rec.fee_date,
        x_fee_payment_method           => c_fee_rec.fee_payment_method,
        x_fee_amount                   => c_fee_rec.fee_amount,
        x_reference_num                => c_fee_rec.reference_num,
        x_mode                         => 'R',
        x_credit_card_code             => c_fee_rec.credit_card_code,
        x_credit_card_holder_name      => c_fee_rec.credit_card_holder_name,
        x_credit_card_number           => c_fee_rec.credit_card_number,
        x_credit_card_expiration_date  => c_fee_rec.credit_card_expiration_date,
        x_rev_gl_ccid                  => c_fee_rec.rev_gl_ccid,
        x_cash_gl_ccid                 => c_fee_rec.cash_gl_ccid,
        x_rev_account_cd               => c_fee_rec.rev_account_cd,
        x_cash_account_cd              => c_fee_rec.cash_account_cd,
        x_gl_date                      => c_fee_rec.gl_date,
        x_gl_posted_date               => c_fee_rec.gl_posted_date,
        x_posting_control_id           => c_fee_rec.posting_control_id,
        x_credit_card_tangible_cd      => c_fee_rec.credit_card_tangible_cd,
        x_credit_card_payee_cd         => c_fee_rec.credit_card_payee_cd,
        x_credit_card_status_code      => c_fee_rec.credit_card_status_code
        );
END LOOP;

l_rowid := NULL;

RETURN TRUE;

EXCEPTION WHEN OTHERS THEN

  fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(p_person_id,15,' ') || '; Admission Application Number: ' ||
		    RPAD(p_old_admission_appl_number,2,' ') || '; Course Code: ' || RPAD(p_nominated_course_cd,6,' ') || '; Sequence Number: '||
                    RPAD(p_sequence_number,6,' ') || ' Reason: ');

  FND_MESSAGE.SET_NAME('IGS','IGS_AD_CHILD_COPY_FAILED');
  Fnd_File.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGS',l_last_error);
  fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET || SQLERRM);

  RETURN FALSE;
END copy_application_child_records;

FUNCTION copy_instance_child_records (p_new_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                                      p_new_sequence_number       IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                      p_person_id                 HZ_PARTIES.party_id%TYPE,
                                      p_old_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                                      p_old_sequence_number       IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                      p_nominated_course_cd       IGS_AD_PS_APPL.nominated_course_cd%TYPE,
                                      p_start_dt                  DATE)
RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
-------------------------Cursor Declarations-------------------------------------------------------------------
-- Unitsets
CURSOR c_unitsets_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )
IS
SELECT
  unit_set_id,
  person_id ,
  admission_appl_number ,
  nominated_course_cd,
  sequence_number,
  unit_set_cd,
  version_number,
  rank
FROM
  igs_ad_unit_sets
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;



-- education goals
CURSOR c_edugoal_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )
IS
SELECT
  post_edugoal_id ,
  person_id ,
  admission_appl_number ,
  nominated_course_cd,
  sequence_number ,
  edu_goal_id
FROM
  igs_ad_edugoal
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;

-- rrengara
-- for Build Movement Academic Honors Bug 2647482
-- on 28-oct-2002
--
-- academic honors has been moved to Person
-- So cursor to select the values from the old applicaiton has been removed


-- special consideration
CURSOR c_splcns_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )
IS
SELECT
  spl_adm_cat_id         ,
  person_id              ,
  admission_appl_number  ,
  nominated_course_cd    ,
  sequence_number        ,
  spl_adm_cat
FROM
  igs_ad_spl_adm_cat
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;


-- Trackings
CURSOR c_tracking_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )
IS
SELECT
  aplins_admreq_id ,
  person_id                 ,
  admission_appl_number,
  course_cd                      ,
  sequence_number         ,
  tracking_id
FROM
  igs_ad_aplins_admreq
WHERE
  person_id = cp_person_id       and
  course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;

-- program approval
CURSOR c_pgmapp_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )
 IS
SELECT
  appl_pgmapprv_id    ,
  person_id                      ,
  admission_appl_number,
  nominated_course_cd  ,
  sequence_number            ,
  pgm_approver_id             ,
  assign_type                    ,
  assign_date                    ,
  program_approval_date,
  program_approval_status,
  approval_notes
FROM
  igs_ad_appl_pgmapprv
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;

  -- Test Scores
CURSOR c_test_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )
IS
SELECT
  tstscr_used_id  ,
  comments          ,
  person_id            ,
  admission_appl_number,
  nominated_course_cd  ,
  sequence_number        ,
  attribute_category ,
  attribute1             ,
  attribute2             ,
  attribute3             ,
  attribute4             ,
  attribute5             ,
  attribute6             ,
  attribute7    ,
  attribute8             ,
  attribute9             ,
  attribute10            ,
  attribute11            ,
  attribute12            ,
  attribute13            ,
  attribute14            ,
  attribute15            ,
  attribute16            ,
  attribute17            ,
  attribute18            ,
  attribute19            ,
  attribute20
FROM
  igs_ad_tstscr_used
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;


-- notes
CURSOR c_notes_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )
IS
SELECT
  appl_notes_id          ,
  person_id              ,
  admission_appl_number  ,
  nominated_course_cd    ,
  sequence_number        ,
  note_type_id           ,
  ref_notes_id
FROM
  igs_ad_appl_notes
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;

CURSOR c_evaluators_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )

IS
SELECT
  appl_eval_id,
  person_id    ,
  admission_appl_number,
  nominated_course_cd   ,
  sequence_number        ,
  evaluator_id           ,
  assign_type            ,
  assign_date            ,
  evaluation_date        ,
  rating_type_id         ,
  rating_values_id       ,
  rating_notes           ,
  evaluation_sequence    ,
  rating_scale_id,
  closed_ind  -- added the closed ind check -- rghosh (bug#2871426)
FROM
  igs_ad_appl_eval
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;


 CURSOR c_applrep_cur(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                           cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                           cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                           cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE )

IS
SELECT
  appl_arp_id            ,
  person_id              ,
  admission_appl_number  ,
  nominated_course_cd    ,
  sequence_number        ,
  appl_rev_profile_id    ,
  appl_revprof_revgr_id
FROM
  igs_ad_appl_arp
WHERE
  person_id = cp_person_id       and
  nominated_course_cd = cp_nominated_course_cd      and
  sequence_number = cp_sequence_number     and
  admission_appl_number = cp_admission_appl_number;

-- bug 2395510 ( Deferment changes)
-- by rrengara on 12-SEP-2002

CURSOR c_fee_status IS
SELECT
   ccl.code_id
FROM
  igs_ad_code_classes ccl , igs_lookup_values  lkup
WHERE
  ccl.system_status = lkup.lookup_code
  AND  lkup.lookup_type = 'SYS_FEE_STATUS'
  AND  ccl.system_status = 'WAIVED'
  AND  ccl.system_default = 'Y';

CURSOR c_appl_qual_code(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                        cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
			cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
			cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE ) IS
  SELECT  qual.*
  FROM igs_ad_appqual_code qual
  WHERE  person_id = cp_person_id
  AND  nominated_course_cd = cp_nominated_course_cd
  AND sequence_number = cp_sequence_number
  AND admission_appl_number = cp_admission_appl_number;

CURSOR c_intvw_dtls (cp_person_id  igs_ad_ps_appl_inst_all.person_id%TYPE,
		     cp_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
                     cp_nominated_course_cd igs_ad_ps_appl_inst_all.nomINATED_COURSE_CD%TYPE,
		     cp_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE ) IS
  SELECT pndt.*
  FROM igs_ad_panel_dtls pndt
  WHERE  person_id = cp_person_id
  AND admission_appl_number = cp_admission_appl_number
  AND  nominated_course_cd = cp_nominated_course_cd
  AND sequence_number = cp_sequence_number;

CURSOR c_intvw_pnmem_dtls (cp_panel_dtls_id igs_ad_pnmembr_dtls.panel_dtls_id%TYPE) IS
  SELECT pnmdt.*
  FROM igs_ad_pnmembr_dtls pnmdt
  WHERE panel_dtls_id = cp_panel_dtls_id;


---End cursor Declarations-----------------------------------------------------------------------------

---- Variable declarations-----------------------------------------------------------------------------
l_primary_key NUMBER(15);
l_rowid VARCHAR2(30);
l_last_error VARCHAR2(100);
l_panel_dtls_id igs_ad_panel_dtls.panel_dtls_id%TYPE;

------End variable declarations------------------------------------------------------------------------

BEGIN

-- Unitsets
FOR  c_unitsets_rec IN c_unitsets_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_UNIT_SETS';
  Igs_Ad_Unit_Sets_PKG.INSERT_ROW(
                      X_ROWID   => l_rowid,
                      X_UNIT_SET_ID  => l_primary_key,
                      X_PERSON_ID =>  c_unitsets_rec.person_id ,
                      X_ADMISSION_APPL_NUMBER => p_new_admission_appl_number,
                      X_NOMINATED_COURSE_CD =>  c_unitsets_rec.nominated_course_cd,
                      X_SEQUENCE_NUMBER  =>p_new_sequence_number,
                      X_UNIT_SET_CD    =>  c_unitsets_rec.unit_set_cd,
                      X_VERSION_NUMBER  =>  c_unitsets_rec.version_number,
                      X_RANK  =>  c_unitsets_rec.rank,
                      X_MODE => 'R'
                       );
END LOOP;


l_rowid := NULL;

-- edu goals
FOR  c_edugoal_rec IN c_edugoal_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_EDU_GOAL';
Igs_Ad_Edugoal_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_POST_EDUGOAL_ID   =>  l_primary_key,
        X_PERSON_ID    => c_edugoal_rec.person_id,
        X_ADMISSION_APPL_NUMBER  => p_new_admission_appl_number,
        X_NOMINATED_COURSE_CD => c_edugoal_rec.nominated_course_cd,
        X_SEQUENCE_NUMBER   => p_new_sequence_number,
        X_EDU_GOAL_ID  => c_edugoal_rec.edu_goal_id,
         X_MODE => 'R');
END LOOP;


-- Special Consideration

FOR  c_splcns_rec IN c_splcns_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_SPL_CON';
igs_ad_spl_adm_cat_PKG.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_SPL_ADM_CAT_ID     =>  l_primary_key,
        X_PERSON_ID  => c_splcns_rec.person_id,
        X_ADMISSION_APPL_NUMBER  => p_new_admission_appl_number,
        X_NOMINATED_COURSE_CD  => c_splcns_rec.nominated_course_cd,
        X_SEQUENCE_NUMBER => c_splcns_rec.sequence_number,
        X_SPL_ADM_CAT  => c_splcns_rec.spl_adm_cat,
         X_MODE => 'R');
END LOOP;

l_rowid := NULL;

-- Trackings


FOR  c_tracking_rec IN c_tracking_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_TRACK';
IGS_AD_APLINS_ADMREQ_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_APLINS_ADMREQ_ID    =>  l_primary_key,
        X_PERSON_ID    => c_tracking_rec.person_id,
        X_ADMISSION_APPL_NUMBER  => p_new_admission_appl_number,
        X_COURSE_CD     => c_tracking_rec.course_cd,
        X_SEQUENCE_NUMBER  => p_new_sequence_number            ,
        X_TRACKING_ID => c_tracking_rec.tracking_id,
        X_MODE => 'R');
END LOOP;

l_rowid := NULL;
-- program approval

FOR  c_pgmapp_rec IN c_pgmapp_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_PRG_APPR';
IGS_AD_APPL_PGMAPPRV_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_APPL_PGMAPPRV_ID  =>  l_primary_key,
        X_PERSON_ID    => c_pgmapp_rec.person_id,
        X_ADMISSION_APPL_NUMBER   => p_new_admission_appl_number,
        X_NOMINATED_COURSE_CD => c_pgmapp_rec.nominated_course_cd,
        X_SEQUENCE_NUMBER  => p_new_sequence_number,
        X_PGM_APPROVER_ID  =>  c_pgmapp_rec.pgm_approver_id,
        X_ASSIGN_TYPE     =>  c_pgmapp_rec.assign_type,
        X_ASSIGN_DATE     =>  c_pgmapp_rec.assign_date,
        X_PROGRAM_APPROVAL_DATE   =>  c_pgmapp_rec.program_approval_date,
        X_PROGRAM_APPROVAL_STATUS   =>  c_pgmapp_rec.program_approval_status,
        X_APPROVAL_NOTES     =>  c_pgmapp_rec.approval_notes,
        X_MODE => 'R');
END LOOP;

l_rowid := NULL;
-- testscores


FOR  c_test_rec IN c_test_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
    l_last_error :=  'IGS_AD_CHILD_TST_SCORE';
IGS_AD_TSTSCR_USED_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_TSTSCR_USED_ID       =>  l_primary_key,
        X_COMMENTS    => c_test_rec.comments,
        X_PERSON_ID    => c_test_rec.person_id,
        X_ADMISSION_APPL_NUMBER   => p_new_admission_appl_number,
        X_NOMINATED_COURSE_CD => c_test_rec.nominated_course_cd,
        X_SEQUENCE_NUMBER  => p_new_sequence_number,
        X_ATTRIBUTE_CATEGORY   => c_test_rec.attribute_category,
        X_ATTRIBUTE1    => c_test_rec.attribute1,
        X_ATTRIBUTE2   => c_test_rec.attribute2,
        X_ATTRIBUTE3   => c_test_rec.attribute3,
        X_ATTRIBUTE4  => c_test_rec.attribute4  ,
        X_ATTRIBUTE5    => c_test_rec.attribute5,
        X_ATTRIBUTE6    => c_test_rec.attribute6,
        X_ATTRIBUTE7   => c_test_rec.attribute7  ,
        X_ATTRIBUTE8  => c_test_rec.attribute8    ,
        X_ATTRIBUTE9   => c_test_rec.attribute9    ,
        X_ATTRIBUTE10 => c_test_rec.attribute10   ,
        X_ATTRIBUTE11   => c_test_rec.attribute11 ,
        X_ATTRIBUTE12   => c_test_rec.attribute12 ,
        X_ATTRIBUTE13 => c_test_rec.attribute13     ,
        X_ATTRIBUTE14   => c_test_rec.attribute14   ,
        X_ATTRIBUTE15   => c_test_rec.attribute15   ,
        X_ATTRIBUTE16 => c_test_rec.attribute16     ,
        X_ATTRIBUTE17   => c_test_rec.attribute17   ,
        X_ATTRIBUTE18  => c_test_rec.attribute18    ,
        X_ATTRIBUTE19 => c_test_rec.attribute19     ,
        X_ATTRIBUTE20   => c_test_rec.attribute20   ,
         X_MODE => 'R');
END LOOP;

l_rowid := NULL;

-- NOTES
FOR  c_notes_rec IN c_notes_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
    l_last_error :=  'IGS_AD_CHILD_APPL_NOTES';
igs_ad_appl_notes_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_APPL_NOTES_ID   =>  l_primary_key,
        X_PERSON_ID    => c_notes_rec.person_id,
        X_ADMISSION_APPL_NUMBER   => p_new_admission_appl_number,
        X_NOMINATED_COURSE_CD => c_notes_rec.nominated_course_cd,
        X_SEQUENCE_NUMBER  => p_new_sequence_number,
        X_NOTE_TYPE_ID      =>  c_notes_rec.note_type_id,
        X_REF_NOTES_ID     => c_notes_rec.ref_notes_id,
         X_MODE => 'R'
        );
END LOOP;

l_rowid := NULL;

-- Evaluators
FOR  c_evaluators_rec IN c_evaluators_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
    l_last_error :=  'IGS_AD_CHILD_EVAL';
igs_ad_appl_eval_pkg.INSERT_ROW(
        x_rowid     => l_rowid,
        x_person_id    => c_evaluators_rec.person_id,
        x_admission_appl_number   => p_new_admission_appl_number,
        x_nominated_course_cd => c_evaluators_rec.nominated_course_cd,
        x_sequence_number  => p_new_sequence_number,
        x_appl_eval_id => l_primary_key,
        x_evaluator_id => c_evaluators_rec.evaluator_id,
        x_assign_type => c_evaluators_rec.assign_type,
        x_assign_date => c_evaluators_rec.assign_date,
        x_evaluation_date => c_evaluators_rec.evaluation_date,
        x_rating_type_id => c_evaluators_rec.rating_type_id,
        x_rating_values_id => c_evaluators_rec.rating_values_id,
        x_rating_notes => c_evaluators_rec.rating_notes,
        x_evaluation_sequence => c_evaluators_rec.evaluation_sequence,
        x_rating_scale_id => c_evaluators_rec.rating_scale_id,
        x_mode => 'R',
	x_closed_ind => c_evaluators_rec.closed_ind  -- added the parameter closed ind -- rghosh(bug#2871426)
        );
END LOOP;

l_rowid := NULL;

-- Evaluators Review group
FOR  c_applrep_rec IN c_applrep_cur(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
    l_last_error :=  'IGS_AD_CHILD_EVAL_RGRP';
igs_ad_appl_arp_pkg.INSERT_ROW(
        X_ROWID     => l_rowid,
        X_PERSON_ID    => c_applrep_rec.person_id,
        X_ADMISSION_APPL_NUMBER   => p_new_admission_appl_number,
        X_NOMINATED_COURSE_CD => c_applrep_rec.nominated_course_cd,
        X_SEQUENCE_NUMBER  => p_new_sequence_number,
        X_APPL_ARP_ID  => c_applrep_rec.appl_arp_id,
        X_APPL_REV_PROFILE_ID => c_applrep_rec.APPL_REV_PROFILE_ID,
        X_APPL_REVPROF_REVGR_ID => c_applrep_rec.APPL_REVPROF_REVGR_ID,
         X_MODE => 'R'
        );
END LOOP;


l_rowid := NULL;

--Qualification Codes
FOR  c_appl_qual_rec  IN c_appl_qual_code(p_person_id, p_nominated_course_cd, p_old_admission_appl_number, p_old_sequence_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_QUAL_CODE';
igs_ad_appqual_code_pkg.INSERT_ROW(
    x_rowid                      => l_rowid,
    x_person_id                  => c_appl_qual_rec.person_id,
    x_admission_appl_number      => p_new_admission_appl_number,
    x_nominated_course_cd        => c_appl_qual_rec.nominated_course_cd,
    x_sequence_number            => p_new_sequence_number,
    x_qualifying_type_code       => c_appl_qual_rec.qualifying_type_code,
    x_qualifying_code_id         => c_appl_qual_rec.qualifying_code_id,
    x_qualifying_value           => c_appl_qual_rec.qualifying_value,
    x_mode                       => 'R');

END LOOP;

-- Interview Details

FOR l_intvw_dtls_rec IN c_intvw_dtls(p_person_id, p_old_admission_appl_number, p_nominated_course_cd, p_old_sequence_number) LOOP
  l_last_error := 'IGS_AD_INTV_PNL_DTLS';

  igs_ad_panel_dtls_pkg.insert_row(
    x_rowid                             => l_rowid,
    x_panel_dtls_id                     => l_panel_dtls_id,
    x_person_id                         => l_intvw_dtls_rec.person_id,
    x_admission_appl_number             => l_intvw_dtls_rec.admission_appl_number,
    x_nominated_course_cd               => l_intvw_dtls_rec.nominated_course_cd,
    x_sequence_number                   => l_intvw_dtls_rec.sequence_number,
    x_panel_code                        => l_intvw_dtls_rec.panel_code,
    x_interview_date                    => l_intvw_dtls_rec.interview_date,
    x_interview_time                    => l_intvw_dtls_rec.interview_time,
    x_location_cd                       => l_intvw_dtls_rec.location_cd,
    x_room_id                           => l_intvw_dtls_rec.room_id,
    x_final_decision_code               => l_intvw_dtls_rec.final_decision_code,
    x_final_decision_type               => l_intvw_dtls_rec.final_decision_type,
    x_final_decision_date               => l_intvw_dtls_rec.final_decision_date,
    x_closed_flag                       => l_intvw_dtls_rec.closed_flag,
    x_attribute_category                => l_intvw_dtls_rec.attribute_category,
    x_attribute1                        => l_intvw_dtls_rec.attribute1,
    x_attribute2                        => l_intvw_dtls_rec.attribute2,
    x_attribute3                        => l_intvw_dtls_rec.attribute3,
    x_attribute4                        => l_intvw_dtls_rec.attribute4,
    x_attribute5                        => l_intvw_dtls_rec.attribute5,
    x_attribute6                        => l_intvw_dtls_rec.attribute6,
    x_attribute7                        => l_intvw_dtls_rec.attribute7,
    x_attribute8                        => l_intvw_dtls_rec.attribute8,
    x_attribute9                        => l_intvw_dtls_rec.attribute9,
    x_attribute10                       => l_intvw_dtls_rec.attribute10,
    x_attribute11                       => l_intvw_dtls_rec.attribute11,
    x_attribute12                       => l_intvw_dtls_rec.attribute12,
    x_attribute13                       => l_intvw_dtls_rec.attribute13,
    x_attribute14                       => l_intvw_dtls_rec.attribute14,
    x_attribute15                       => l_intvw_dtls_rec.attribute15,
    x_attribute16                       => l_intvw_dtls_rec.attribute16,
    x_attribute17                       => l_intvw_dtls_rec.attribute17,
    x_attribute18                       => l_intvw_dtls_rec.attribute18,
    x_attribute19                       => l_intvw_dtls_rec.attribute19,
    x_attribute20                       => l_intvw_dtls_rec.attribute20,
    x_mode                              => 'R'
     );


  FOR l_intvw_pnmem_dtls_rec IN c_intvw_pnmem_dtls(l_intvw_dtls_rec.panel_dtls_id) LOOP
    l_last_error := 'IGS_AD_PNL_MEM_DTLS';

    igs_ad_pnmembr_dtls_pkg.insert_row(
        x_rowid                             => l_rowid,
        x_panel_dtls_id                     => l_intvw_pnmem_dtls_rec.panel_dtls_id,
        x_role_type_code                    => l_intvw_pnmem_dtls_rec.role_type_code,
        x_member_person_id                  => l_intvw_pnmem_dtls_rec.member_person_id,
        x_interview_date                    => l_intvw_pnmem_dtls_rec.interview_date,
        x_interview_time                    => l_intvw_pnmem_dtls_rec.interview_time,
        x_location_cd                       => l_intvw_pnmem_dtls_rec.location_cd,
        x_room_id                           => l_intvw_pnmem_dtls_rec.room_id,
        x_member_decision_code              => l_intvw_pnmem_dtls_rec.member_decision_code,
        x_member_decision_type              => l_intvw_pnmem_dtls_rec.member_decision_type,
        x_member_decision_date              => l_intvw_pnmem_dtls_rec.member_decision_date,
        x_attribute_category                => l_intvw_pnmem_dtls_rec.attribute_category,
        x_attribute1                        => l_intvw_pnmem_dtls_rec.attribute1,
        x_attribute2                        => l_intvw_pnmem_dtls_rec.attribute2,
        x_attribute3                        => l_intvw_pnmem_dtls_rec.attribute3,
        x_attribute4                        => l_intvw_pnmem_dtls_rec.attribute4,
        x_attribute5                        => l_intvw_pnmem_dtls_rec.attribute5,
        x_attribute6                        => l_intvw_pnmem_dtls_rec.attribute6,
        x_attribute7                        => l_intvw_pnmem_dtls_rec.attribute7,
        x_attribute8                        => l_intvw_pnmem_dtls_rec.attribute8,
        x_attribute9                        => l_intvw_pnmem_dtls_rec.attribute9,
        x_attribute10                       => l_intvw_pnmem_dtls_rec.attribute10,
        x_attribute11                       => l_intvw_pnmem_dtls_rec.attribute11,
        x_attribute12                       => l_intvw_pnmem_dtls_rec.attribute12,
        x_attribute13                       => l_intvw_pnmem_dtls_rec.attribute13,
        x_attribute14                       => l_intvw_pnmem_dtls_rec.attribute14,
        x_attribute15                       => l_intvw_pnmem_dtls_rec.attribute15,
        x_attribute16                       => l_intvw_pnmem_dtls_rec.attribute16,
        x_attribute17                       => l_intvw_pnmem_dtls_rec.attribute17,
        x_attribute18                       => l_intvw_pnmem_dtls_rec.attribute18,
        x_attribute19                       => l_intvw_pnmem_dtls_rec.attribute19,
        x_attribute20                       => l_intvw_pnmem_dtls_rec.attribute20,
        x_mode                              => 'R'
        );

  END LOOP;

END LOOP;

IF copy_candidacy_records (
                            p_new_admission_appl_number => p_new_admission_appl_number,
                            p_new_sequence_number       => p_new_sequence_number,
                            p_person_id                 => p_person_id,
                            p_old_admission_appl_number => p_old_admission_appl_number,
                            p_old_sequence_number       => p_old_sequence_number,
                            p_nominated_course_cd       => p_nominated_course_cd,
                            p_start_dt                  => p_start_dt) = FALSE THEN
         RETURN FALSE;
END IF;

RETURN TRUE;

EXCEPTION WHEN OTHERS THEN

  fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(p_person_id,15,' ') || '; Admission Application Number: ' ||
		    RPAD(p_old_admission_appl_number,2,' ') || '; Course Code: ' || RPAD(p_nominated_course_cd,6,' ') || '; Sequence Number: '||
                    RPAD(p_old_sequence_number,6,' ') || ' Reason: ');

  FND_MESSAGE.SET_NAME('IGS','IGS_AD_CHILD_COPY_FAILED');
  Fnd_File.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGS',l_last_error);
  fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET || SQLERRM);

  RETURN FALSE;
END copy_instance_child_records;



PROCEDURE admp_init_reconsider(
                        errbuf out NOCOPY varchar2,
                        retcode out NOCOPY number ,
                        p_curr_acad_adm_cal VARCHAR2,
			p_future_acad_adm_cal VARCHAR2,
                        p_application_type VARCHAR2,
                        p_group_id igs_pe_persid_group.group_id%TYPE,
			p_application_id NUMBER,
			p_decision_date VARCHAR2,
			p_dec_maker_id igs_pe_person_base_v.person_id%TYPE,
			p_dec_reason_id IGS_AD_CODE_CLASSES.code_id%TYPE
			)  IS
/*******************************************************************************
Created by  : Rishi Ghosh
Date created: 12 September 2005

Purpose:
  This is the main procedure that is called from the Admission Initialize
  Reconsideration job. If the current application is in the PENDING status
  and future term academic and admission calendars are specified, then this
  job will create an application in the future term with PENDING status and
  make the original application CANCELLED.

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/


    TYPE  c_pers_group_rec IS RECORD (PERSON_ID IGS_PE_PRSID_GRP_MEM_ALL.PERSON_ID%TYPE);
    c_person_group_rec c_pers_group_rec;

    /*This cursor returns the person id from the person id group */
    TYPE c_pers_group_ref IS REF CURSOR;
    c_person_group c_pers_group_ref;

    lv_status     VARCHAR2(1) ;
    lv_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;
    lv_sql_stmt   VARCHAR(32767) ;


   /* This cursor returns the application to be processed for a given combination of person_id, current calendars and future calendars */
   CURSOR c_appl_inst(cp_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                      cp_fut_acad_cal_type igs_ad_ps_appl_inst_all.future_acad_cal_type%TYPE,
		      cp_fut_acad_cal_seq_no igs_ad_ps_appl_inst_all.future_acad_ci_sequence_number%TYPE,
		      cp_fut_adm_cal_type igs_ad_ps_appl_inst_all.future_adm_cal_type%TYPE,
		      cp_fut_adm_cal_seq_no igs_ad_ps_appl_inst_all.future_adm_ci_sequence_number%TYPE,
                      cp_prev_acad_cal_type igs_ad_ps_appl_inst_all.future_acad_cal_type%TYPE,
		      cp_prev_acad_cal_seq_no igs_ad_ps_appl_inst_all.future_acad_ci_sequence_number%TYPE,
		      cp_prev_adm_cal_type igs_ad_ps_appl_inst_all.future_adm_cal_type%TYPE,
		      cp_prev_adm_cal_seq_no igs_ad_ps_appl_inst_all.future_adm_ci_sequence_number%TYPE,
		      cp_admission_cat igs_ad_appl_all.admission_cat%TYPE,
		      cp_s_adm_process_type igs_ad_appl_all.s_admission_process_type%TYPE
		      ) IS
     SELECT acai.*,
            aa.appl_dt,
	    aa.admission_cat,
	    aa.s_admission_process_type,
            aa.spcl_grp_1,
	    aa.spcl_grp_2,
	    aa.common_app,
            aa.adm_appl_status,
	    aa.choice_number,
	    aa.routeb_pref,
            aa.application_type,
	    aa.adm_fee_status,
	    aa.alt_appl_id,
            aa.acad_cal_type,
	    aa.acad_ci_sequence_number,
	    aprog.transfer_course_cd,
	    aprog.basis_for_admission_type,
	    aprog.admission_cd,
	    aprog.req_for_reconsideration_ind,
	    aprog.req_for_adv_standing_ind
     FROM   igs_ad_appl aa,
            igs_ad_ps_appl_inst acai,
            igs_ad_ou_stat aous,
	    igs_ad_ps_appl aprog
     WHERE  acai.adm_outcome_status = aous.adm_outcome_status
     AND    aous.s_adm_outcome_status = 'PENDING'
     AND    acai.future_acad_cal_type = NVL(cp_fut_acad_cal_type, acai.future_acad_cal_type)
     AND    acai.future_acad_ci_sequence_number = NVL(cp_fut_acad_cal_seq_no, acai.future_acad_ci_sequence_number)
     AND    acai.future_adm_cal_type = NVL(cp_fut_adm_cal_type, acai.future_adm_cal_type)
     AND    acai.future_adm_ci_sequence_number = NVL(cp_fut_adm_cal_seq_no, acai.future_adm_ci_sequence_number)
     AND    acai.future_term_adm_appl_number IS NULL
     AND    acai.future_term_sequence_number IS NULL
     AND    acai.person_id = NVL(cp_person_id, acai.person_id)
     AND    aa.person_id = acai.person_id
     AND    aa.admission_appl_number = acai.admission_appl_number
     AND    aa.acad_cal_type = NVL ( cp_prev_acad_cal_type, aa.acad_cal_type)
     AND    aa.acad_ci_sequence_number = NVL ( cp_prev_acad_cal_seq_no, aa.acad_ci_sequence_number)
     AND    NVL(acai.adm_cal_type,aa.adm_cal_type) = NVL( cp_prev_adm_cal_type,  acai.adm_cal_type)
     AND    NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) = NVL ( cp_prev_adm_cal_seq_no, acai.adm_ci_sequence_number)
     AND    aa.application_id = nvl( p_application_id,aa.application_id)
     AND    aa.admission_cat = NVL(cp_admission_cat,aa.admission_cat)
     AND    aa.s_admission_process_type = NVL(cp_s_adm_process_type, aa.s_admission_process_type)
     AND    aprog.person_id = acai.person_id
     AND    aprog.admission_appl_number = acai.admission_appl_number
     AND    aprog.nominated_course_cd = acai.nominated_course_cd
     AND    acai.future_acad_cal_type IS NOT NULL
     AND    acai.future_acad_ci_sequence_number IS NOT NULL
     AND    acai.future_adm_cal_type IS NOT NULL
     AND    acai.future_adm_ci_sequence_number IS NOT NULL
     ORDER BY acai.person_id, acai.admission_appl_number, acai.Future_acad_cal_type, acai.future_acad_ci_sequence_number,
              acai.future_adm_cal_type, acai.future_adm_ci_sequence_number, acai.nominated_course_cd;

   l_appl_inst_rec c_appl_inst%ROWTYPE;


   /* This cursor will return the application instance details for a given combination of
   person id, appl number, course cd and sequence number */
   CURSOR c_get_appl_instance (cp_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                            cp_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
	                    cp_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
			    cp_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE) IS
     SELECT acai.rowid,acai.*
     FROM   igs_ad_ps_appl_inst_all acai
     WHERE  person_id = cp_person_id
     AND    admission_appl_number = cp_admission_appl_number
     AND    nominated_course_cd = cp_nominated_course_cd
     AND    sequence_number = cp_sequence_number;

   l_get_appl_instance c_get_appl_instance%ROWTYPE;


   /* This cursor will return the calenar information for a given application */
   CURSOR c_get_acad_cal_info(cp_person_id igs_ad_appl_all.person_id%TYPE,
                           cp_admission_appl_number igs_ad_appl_all.admission_appl_number%TYPE) IS
     SELECT acad_cal_type,acad_ci_sequence_number
     FROM igs_ad_appl_all
     WHERE person_id = cp_person_id
     AND admission_appl_number = cp_admission_appl_number;

   l_get_acad_cal_info c_get_acad_cal_info%ROWTYPE;


   /* This cursor will return the future calendars (if any) of an application instance*/
   CURSOR c_get_fut_acad_adm_cal_info (cp_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                                    cp_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
	                  	    cp_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
			            cp_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE) IS
  SELECT  future_acad_cal_type,future_acad_ci_sequence_number,future_adm_cal_type,future_adm_ci_sequence_number
  FROM    igs_ad_ps_appl_inst_all
  WHERE   person_id = cp_person_id
  AND     admission_appl_number = cp_admission_appl_number
  AND     nominated_course_cd = cp_nominated_course_cd
  AND     sequence_number = cp_sequence_number;

l_get_fut_acad_adm_cal_info c_get_fut_acad_adm_cal_info%ROWTYPE;

CURSOR c_get_prog_dtls (cp_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                        cp_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
	                cp_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE) IS
  SELECT aprog.*
  FROM   igs_ad_ps_appl aprog
  WHERE  aprog.person_id = cp_person_id
  AND    aprog.admission_appl_number = cp_admission_appl_number
  AND    aprog.nominated_course_cd = cp_nominated_course_cd;

l_get_prog_dtls c_get_prog_dtls%ROWTYPE;

CURSOR c_admission_type (cp_admission_type IGS_AD_SS_APPL_TYP.ADMISSION_APPLICATION_TYPE%TYPE) IS
  SELECT admission_cat, s_admission_process_type
  FROM igs_ad_ss_appl_typ
  WHERE admission_application_type = cp_admission_type;

l_admission_type c_admission_type%ROWTYPE;

l_new_admission_appl_number NUMBER;

l_person_id                 igs_ad_ps_appl_inst_all.person_id%TYPE;
l_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE;
l_future_acad_cal_type      igs_ad_ps_appl_inst_all.future_acad_cal_type%TYPE;
l_fut_acad_ci_seq_no        igs_ad_ps_appl_inst_all.future_acad_ci_sequence_number%TYPE;
l_future_adm_cal_type       igs_ad_ps_appl_inst_all.future_adm_cal_type%TYPE;
l_fut_adm_ci_seq_no         igs_ad_ps_appl_inst_all.future_adm_ci_sequence_number%TYPE;
l_nominated_course_cd       igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE;

l_prev_acad_cal_type     VARCHAR2(30);
l_prev_acad_cal_seq_no   NUMBER;
l_prev_adm_cal_type      VARCHAR2(30);
l_prev_adm_cal_seq_no    NUMBER;

l_fut_acad_cal_type      VARCHAR2(30);
l_fut_acad_cal_seq_no    NUMBER;
l_fut_adm_cal_type       VARCHAR2(30);
l_fut_adm_cal_seq_no     NUMBER;

l_message_name VARCHAR2(30);
l_application_type igs_ad_appl_all.application_type%TYPE;

l_sequence_number NUMBER;

l_return_type  VARCHAR2(100);
l_error_code  VARCHAR2(100);

v_start_dt DATE;

l_application_created BOOLEAN;
l_program_created BOOLEAN;
l_instance_created BOOLEAN;

l_decision_date DATE;

l_total_records NUMBER;
l_successful_records NUMBER;
l_failed_records NUMBER;

l_msg_at_index NUMBER;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

BEGIN

-- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
igs_ge_gen_003.set_org_id(null);

retcode := 0;

l_msg_at_index := igs_ge_msg_stack.count_msg;

l_total_records := 0;
l_successful_records := 0;
l_failed_records := 0;

l_decision_date := igs_ge_date.igsdate(p_decision_date);

l_person_id := NULL;
l_admission_appl_number := NULL;
l_future_acad_cal_type := NULL;
l_fut_acad_ci_seq_no := NULL;
l_future_adm_cal_type := NULL;
l_fut_adm_ci_seq_no := NULL;
l_nominated_course_cd := NULL;

l_prev_acad_cal_type     :=   rtrim (substr (p_curr_acad_adm_cal, 1,10));
l_prev_acad_cal_seq_no   :=   IGS_GE_NUMBER.TO_NUM(substr(p_curr_acad_adm_cal, 13,7));
l_prev_adm_cal_type      :=   rtrim (substr (p_curr_acad_adm_cal, 23,10));
l_prev_adm_cal_seq_no    :=   IGS_GE_NUMBER.TO_NUM (substr (p_curr_acad_adm_cal, 35,7));

l_fut_acad_cal_type      :=   rtrim (substr (p_future_acad_adm_cal, 1,10));
l_fut_acad_cal_seq_no    :=   IGS_GE_NUMBER.TO_NUM (substr (p_future_acad_adm_cal, 13,7));
l_fut_adm_cal_type       :=   rtrim (substr (p_future_acad_adm_cal, 23,10));
l_fut_adm_cal_seq_no     :=   IGS_GE_NUMBER.TO_NUM(substr (p_future_acad_adm_cal, 35,7));


OPEN c_admission_type(p_application_type);
FETCH c_admission_type INTO l_admission_type;
CLOSE c_admission_type;

IF p_group_id IS NOT NULL THEN /* IF 1*/
  --FOR l_person_group_rec IN c_person_group LOOP /* FOR 1 */
  lv_sql_stmt :=  igs_pe_dynamic_persid_group.get_dynamic_sql (p_group_id,lv_status,lv_group_type);
  OPEN c_person_group FOR lv_sql_stmt USING p_group_id;
  LOOP
  FETCH c_person_group  INTO c_person_group_rec;
  EXIT WHEN c_person_group%NOTFOUND;
    FOR l_appl_inst_rec IN c_appl_inst(c_person_group_rec.person_id,
                                       l_fut_acad_cal_type,
				       l_fut_acad_cal_seq_no,
				       l_fut_adm_cal_type,
				       l_fut_adm_cal_seq_no,
				       l_prev_acad_cal_type,
				       l_prev_acad_cal_seq_no,
				       l_prev_adm_cal_type,
				       l_prev_adm_cal_seq_no,
				       l_admission_type.admission_cat,
				       l_admission_type.s_admission_process_type) LOOP
         l_total_records := l_total_records + 1;

         l_application_created := TRUE;
	 l_program_created     := TRUE;
	 l_instance_created    := TRUE;

         SAVEPOINT c_create_application;

         IF       l_appl_inst_rec.person_id                      <>  nvl(l_person_id,-1)                     OR /* IF 2*/
                  l_appl_inst_rec.admission_appl_number          <>  nvl(l_admission_appl_number,-1)          OR
                  l_appl_inst_rec.future_acad_cal_type           <>  nvl(l_future_acad_cal_type,-1)           OR
                  l_appl_inst_rec.future_acad_ci_sequence_number <>  nvl(l_fut_acad_ci_seq_no,-1) OR
                  l_appl_inst_rec.future_adm_cal_type            <>  nvl(l_future_adm_cal_type,-1)            OR
                  l_appl_inst_rec.future_adm_ci_sequence_number  <>  nvl(l_fut_adm_ci_seq_no,-1)  THEN

	       BEGIN

	         IF IGS_AD_GEN_014.insert_adm_appl(      /* IF 3*/
                     p_person_id                    => l_appl_inst_rec.person_id,
                     p_appl_dt                      => l_appl_inst_rec.appl_dt,
                     p_acad_cal_type                => l_appl_inst_rec.future_acad_cal_type ,
                     p_acad_ci_sequence_number      => l_appl_inst_rec.future_acad_ci_sequence_number ,
                     p_adm_cal_type                 => l_appl_inst_rec.future_adm_cal_type ,
                     p_adm_ci_sequence_number       => l_appl_inst_rec.future_adm_ci_sequence_number ,
                     p_admission_cat                => l_appl_inst_rec.admission_cat,
                     p_s_admission_process_type     => l_appl_inst_rec.s_admission_process_type,
                     p_adm_appl_status              => l_appl_inst_rec.adm_appl_status,
                     p_adm_fee_status               => l_appl_inst_rec.adm_fee_status,
                     p_tac_appl_ind                 => 'N',
                     p_adm_appl_number              => l_new_admission_appl_number,
                     p_message_name                 => l_message_name,
                     p_spcl_grp_1                   => l_appl_inst_rec.spcl_grp_1,
                     p_spcl_grp_2                   => l_appl_inst_rec.spcl_grp_2,
                     p_common_app                   => l_appl_inst_rec.common_app,
                     p_application_type             => l_appl_inst_rec.application_type,
                     p_choice_number                => l_appl_inst_rec.choice_number,
                     p_routeb_pref                  => l_appl_inst_rec.routeb_pref,
                     p_alt_appl_id                  => l_appl_inst_rec.alt_appl_id,
		     p_log                          => 'N') THEN

		       IF copy_application_child_records (
                           p_person_id                 => l_appl_inst_rec.person_id,
	                   p_new_admission_appl_number => l_new_admission_appl_number,
	                   p_old_admission_appl_number => l_appl_inst_rec.admission_appl_number,
			   p_nominated_course_cd       => l_appl_inst_rec.nominated_course_cd,
			   p_sequence_number           => l_appl_inst_rec.sequence_number) = FALSE THEN

			 l_failed_records := l_failed_records + 1;

			 ROLLBACK TO c_create_application;
                         l_application_created := FALSE;
		       END IF;

                 ELSE
		   l_application_created := FALSE;
                   l_failed_records := l_failed_records + 1;

		   ROLLBACK TO c_create_application;
		   fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                                    RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                                    RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

		   IF (l_message_name IS NULL) THEN
		     igs_ad_gen_016.extract_msg_from_stack (
                         p_msg_at_index                => l_msg_at_index,
                         p_return_status               => l_return_status,
                         p_msg_count                   => l_msg_count,
                         p_msg_data                    => l_msg_data,
                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		     IF (l_msg_count > 0) THEN
                       fnd_file.put_line(fnd_file.log, l_msg_data);
                     ELSE
		       FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating the new application');
                     END IF;
                   ELSE
		     fnd_file.put_line(fnd_file.log, l_message_name);
		   END IF;

		 END IF;

               EXCEPTION
	       	 WHEN OTHERS THEN
		   l_application_created := FALSE;
                   l_failed_records := l_failed_records + 1;

		   ROLLBACK TO c_create_application;
		   fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                                    RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                                    RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

		   IF (l_message_name IS NULL) THEN
		     igs_ad_gen_016.extract_msg_from_stack (
                         p_msg_at_index                => l_msg_at_index,
                         p_return_status               => l_return_status,
                         p_msg_count                   => l_msg_count,
                         p_msg_data                    => l_msg_data,
                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		     IF (l_msg_count > 0) THEN
                       fnd_file.put_line(fnd_file.log, l_msg_data);
                     ELSE
		       FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating the new application');
                     END IF;
                   ELSE
		     fnd_file.put_line(fnd_file.log, l_message_name);
		   END IF;
               END;

	 END IF;


         IF  ((l_appl_inst_rec.person_id                    <>  nvl(l_person_id,-1)             OR
             l_appl_inst_rec.admission_appl_number          <>  nvl(l_admission_appl_number,-1) OR
             l_appl_inst_rec.future_acad_cal_type           <>  nvl(l_future_acad_cal_type,-1)  OR
             l_appl_inst_rec.future_acad_ci_sequence_number <>  nvl(l_fut_acad_ci_seq_no,-1)    OR
             l_appl_inst_rec.future_adm_cal_type            <>  nvl(l_future_adm_cal_type,-1)   OR
             l_appl_inst_rec.future_adm_ci_sequence_number  <>  nvl(l_fut_adm_ci_seq_no,-1)     OR
	     l_appl_inst_rec.nominated_course_cd            <>  nvl(l_nominated_course_cd,-1))   AND
             l_application_created = TRUE ) THEN

                BEGIN

		  IF IGS_AD_GEN_014.insert_adm_appl_prog(
                       p_person_id                   => l_appl_inst_rec.person_id,
                       p_adm_appl_number             => l_new_admission_appl_number,
                       p_nominated_course_cd         => l_appl_inst_rec.nominated_course_cd,
                       p_transfer_course_cd          => l_appl_inst_rec.transfer_course_cd,
                       p_basis_for_admission_type    => l_appl_inst_rec.basis_for_admission_type,
                       p_admission_cd                => l_appl_inst_rec.admission_cd,
                       p_req_for_reconsideration_ind => l_appl_inst_rec.req_for_reconsideration_ind,
                       p_req_for_adv_standing_ind    => l_appl_inst_rec.req_for_adv_standing_ind,
                       p_message_name                => l_message_name,
		       p_log                         => 'N') THEN

                       OPEN c_get_prog_dtls(l_appl_inst_rec.person_id, l_appl_inst_rec.admission_appl_number, l_appl_inst_rec.nominated_course_cd);
                       FETCH c_get_prog_dtls INTO l_get_prog_dtls;
                       CLOSE c_get_prog_dtls;


                     IF NVL(l_get_prog_dtls.req_for_reconsideration_ind,'N') = 'Y' THEN

	               BEGIN

		         igs_ad_ps_appl_pkg.update_row(
                                 x_rowid                       => l_get_prog_dtls.row_id,
                                 x_person_id                   => l_get_prog_dtls.person_id,
                                 x_admission_appl_number       => l_get_prog_dtls.admission_appl_number,
                                 x_nominated_course_cd         => l_get_prog_dtls.nominated_course_cd,
                                 x_transfer_course_cd          => l_get_prog_dtls.transfer_course_cd,
                                 x_basis_for_admission_type    => l_get_prog_dtls.basis_for_admission_type,
                                 x_admission_cd                => l_get_prog_dtls.admission_cd,
                                 x_course_rank_set             => l_get_prog_dtls.course_rank_set,
                                 x_course_rank_schedule        => l_get_prog_dtls.course_rank_schedule,
                                 x_req_for_reconsideration_ind => 'N',
                                 x_req_for_adv_standing_ind    => l_get_prog_dtls.req_for_adv_standing_ind,
                                 x_mode                        => 'R');

                       EXCEPTION
		         WHEN OTHERS THEN

		         ROLLBACK TO c_create_application;
		         fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                           RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                           RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');
                         fnd_message.set_name('IGS', 'Failed to update the Request for Reconsideration Checkbox: ' || SQLERRM );
		         l_program_created := FALSE;

                       END;

                     END IF;

                  ELSE

	               l_program_created := FALSE;

		       l_failed_records := l_failed_records + 1;

		       ROLLBACK TO c_create_application;
		       fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                         RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                         RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');


		    IF (l_message_name IS NULL) THEN
		      igs_ad_gen_016.extract_msg_from_stack (
                         p_msg_at_index                => l_msg_at_index,
                         p_return_status               => l_return_status,
                         p_msg_count                   => l_msg_count,
                         p_msg_data                    => l_msg_data,
                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		      IF (l_msg_count > 0) THEN
                        fnd_file.put_line(fnd_file.log, l_msg_data);
                      ELSE
		        FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating application program for the new application');
                      END IF;
                    ELSE
		      fnd_file.put_line(fnd_file.log, l_message_name);
		    END IF;
	          END IF;

		EXCEPTION
		  WHEN OTHERS THEN
	               l_program_created := FALSE;

		       l_failed_records := l_failed_records + 1;

		       ROLLBACK TO c_create_application;
		       fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                         RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                         RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');
		    IF (l_message_name IS NULL) THEN
		      igs_ad_gen_016.extract_msg_from_stack (
                         p_msg_at_index                => l_msg_at_index,
                         p_return_status               => l_return_status,
                         p_msg_count                   => l_msg_count,
                         p_msg_data                    => l_msg_data,
                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		      IF (l_msg_count > 0) THEN
                        fnd_file.put_line(fnd_file.log, l_msg_data);
                      ELSE
		        FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating application program for the new application');
                      END IF;
                    ELSE
		      fnd_file.put_line(fnd_file.log, l_message_name);
		    END IF;
                END;

         END IF;

         IF l_application_created = TRUE AND l_program_created = TRUE THEN

			-- Create Admission Application Program Instance
                        BEGIN

                        IF IGS_AD_GEN_014.insert_adm_appl_prog_inst ( /* IF 6*/
                                     p_person_id                   => l_appl_inst_rec.person_id,
                                     p_admission_appl_number       => l_new_admission_appl_number,
                                     p_acad_cal_type               => l_appl_inst_rec.future_acad_cal_type ,
                                     p_acad_ci_sequence_number     => l_appl_inst_rec.future_acad_ci_sequence_number ,
                                     p_adm_cal_type                => l_appl_inst_rec.future_adm_cal_type ,
                                     p_adm_ci_sequence_number      => l_appl_inst_rec.future_adm_ci_sequence_number ,
                                     p_admission_cat               => l_appl_inst_rec.admission_cat,
                                     p_s_admission_process_type    => l_appl_inst_rec.s_admission_process_type,
                                     p_appl_dt                     => l_appl_inst_rec.appl_dt,
                                     p_adm_fee_status              => l_appl_inst_rec.adm_fee_status,
                                     p_preference_number           => l_appl_inst_rec.preference_number,
                                     p_offer_dt                    => NULL,
                                     p_offer_response_dt           => NULL,
                                     p_course_cd                   => l_appl_inst_rec.nominated_course_cd,
                                     p_crv_version_number          => l_appl_inst_rec.crv_version_number,
                                     p_location_cd                 => l_appl_inst_rec.location_cd,
                                     p_attendance_mode             => l_appl_inst_rec.attendance_mode,
                                     p_attendance_type             => l_appl_inst_rec.attendance_type,
                                     p_unit_set_cd                 => l_appl_inst_rec.unit_set_cd,
                                     p_us_version_number           => l_appl_inst_rec.us_version_number,
                                     p_fee_cat                     => l_appl_inst_rec.fee_cat,
                                     p_correspondence_cat          => l_appl_inst_rec.correspondence_cat,
                                     p_enrolment_cat               => l_appl_inst_rec.enrolment_cat,
                                     p_funding_source              => l_appl_inst_rec.funding_source,
                                     p_edu_goal_prior_enroll       => l_appl_inst_rec.edu_goal_prior_enroll_id,
                                     p_app_source_id               => l_appl_inst_rec.app_source_id,
                                     p_apply_for_finaid            => l_appl_inst_rec.apply_for_finaid,
                                     p_finaid_apply_date           => l_appl_inst_rec.finaid_apply_date,
                                     p_attribute_category          => l_appl_inst_rec.attribute_category,
                                     p_attribute1                  => l_appl_inst_rec.attribute1,
                                     p_attribute2                  => l_appl_inst_rec.attribute2,
                                     p_attribute3                  => l_appl_inst_rec.attribute3,
                                     p_attribute4                  => l_appl_inst_rec.attribute4,
                                     p_attribute5                  => l_appl_inst_rec.attribute5,
                                     p_attribute6                  => l_appl_inst_rec.attribute6,
                                     p_attribute7                  => l_appl_inst_rec.attribute7,
                                     p_attribute8                  => l_appl_inst_rec.attribute8,
                                     p_attribute9                  => l_appl_inst_rec.attribute9,
                                     p_attribute10                 => l_appl_inst_rec.attribute10,
                                     p_attribute11                 => l_appl_inst_rec.attribute11,
                                     p_attribute12                 => l_appl_inst_rec.attribute12,
                                     p_attribute13                 => l_appl_inst_rec.attribute13,
                                     p_attribute14                 => l_appl_inst_rec.attribute14,
                                     p_attribute15                 => l_appl_inst_rec.attribute15,
                                     p_attribute16                 => l_appl_inst_rec.attribute16,
                                     p_attribute17                 => l_appl_inst_rec.attribute17,
                                     p_attribute18                 => l_appl_inst_rec.attribute18,
                                     p_attribute19                 => l_appl_inst_rec.attribute19,
                                     p_attribute20                 => l_appl_inst_rec.attribute20,
                                     p_attribute21                 => l_appl_inst_rec.attribute21,
                                     p_attribute22                 => l_appl_inst_rec.attribute22,
                                     p_attribute23                 => l_appl_inst_rec.attribute23,
                                     p_attribute24                 => l_appl_inst_rec.attribute24,
                                     p_attribute25                 => l_appl_inst_rec.attribute25,
                                     p_attribute26                 => l_appl_inst_rec.attribute26,
                                     p_attribute27                 => l_appl_inst_rec.attribute27,
                                     p_attribute28                 => l_appl_inst_rec.attribute28,
                                     p_attribute29                 => l_appl_inst_rec.attribute29,
                                     p_attribute30                 => l_appl_inst_rec.attribute30,
                                     p_attribute31                 => l_appl_inst_rec.attribute31,
                                     p_attribute32                 => l_appl_inst_rec.attribute32,
                                     p_attribute33                 => l_appl_inst_rec.attribute33,
                                     p_attribute34                 => l_appl_inst_rec.attribute34,
                                     p_attribute35                 => l_appl_inst_rec.attribute35,
                                     p_attribute36                 => l_appl_inst_rec.attribute36,
                                     p_attribute37                 => l_appl_inst_rec.attribute37,
                                     p_attribute38                 => l_appl_inst_rec.attribute38,
                                     p_attribute39                 => l_appl_inst_rec.attribute39,
                                     p_attribute40                 => l_appl_inst_rec.attribute40,
                                     p_ss_application_id           => NULL,
                                     p_sequence_number             => l_sequence_number,
                                     p_return_type                 => l_return_type,
                                     p_error_code                  => l_error_code,
                                     p_message_name                => l_message_name,
                                     p_entry_status                => l_appl_inst_rec.entry_status,
                                     p_entry_level                 => l_appl_inst_rec.entry_level,
                                     p_sch_apl_to_id               => l_appl_inst_rec.sch_apl_to_id,
				     p_log                         => 'N') THEN

                                             OPEN c_get_acad_cal_info(l_appl_inst_rec.person_id,l_new_admission_appl_number);
                                             FETCH c_get_acad_cal_info INTO l_get_acad_cal_info;
                                             CLOSE c_get_acad_cal_info;

                                   	     v_start_dt := igs_en_gen_002.enrp_get_acad_comm(
                                                               l_get_acad_cal_info.acad_cal_type,
                                                               l_get_acad_cal_info.acad_ci_sequence_number,
                                                               l_appl_inst_rec.person_id,
                                                               l_appl_inst_rec.nominated_course_cd,
                                                               l_new_admission_appl_number,
                                                               l_appl_inst_rec.nominated_course_cd,
                                                               l_sequence_number,
                                                               'Y');

                                             IF copy_instance_child_records (
		                                    p_new_admission_appl_number => l_new_admission_appl_number,
                                                    p_new_sequence_number       => l_sequence_number,
                                                    p_person_id                 => l_appl_inst_rec.person_id,
                                                    p_old_admission_appl_number => l_appl_inst_rec.admission_appl_number,
                                                    p_old_sequence_number       => l_appl_inst_rec.sequence_number,
                                                    p_nominated_course_cd       => l_appl_inst_rec.nominated_course_cd,
                                                    p_start_dt                  => v_start_dt) THEN

                                                             l_person_id              := l_appl_inst_rec.person_id;
                                                             l_admission_appl_number  := l_appl_inst_rec.admission_appl_number;
                                                             l_future_acad_cal_type   := l_appl_inst_rec.future_acad_cal_type;
                                                             l_fut_acad_ci_seq_no     := l_appl_inst_rec.future_acad_ci_sequence_number;
                                                             l_future_adm_cal_type    := l_appl_inst_rec.future_adm_cal_type;
                                                             l_fut_adm_ci_seq_no      := l_appl_inst_rec.future_adm_ci_sequence_number;
							     l_nominated_course_cd    := l_appl_inst_rec.nominated_course_cd;

	                                     ELSE

					       l_failed_records := l_failed_records + 1;

					       ROLLBACK TO c_create_application;
					       l_instance_created := FALSE;

					     END IF;

	                                    /* Update the existing application instance to CANCELLED and populate the values of
	                                       FUTURE_TERM_ADM_APPL_NUMBER and FUTURE_TERM_SEQUENCE_NUMBER
					       to link with the new application instance*/

                                             IF l_instance_created = TRUE THEN
					       igs_ad_ps_appl_inst_pkg.UPDATE_ROW (
                                                        X_ROWID                            => l_appl_inst_rec.row_id,
                                                        X_PERSON_ID                        => l_appl_inst_rec.person_id,
                                                        X_ADMISSION_APPL_NUMBER            => l_appl_inst_rec.ADMISSION_APPL_NUMBER,
                                                        X_NOMINATED_COURSE_CD              => l_appl_inst_rec.NOMINATED_COURSE_CD,
                                                        X_SEQUENCE_NUMBER                  => l_appl_inst_rec.SEQUENCE_NUMBER,
                                                        X_PREDICTED_GPA                    => l_appl_inst_rec.PREDICTED_GPA,
                                                        X_ACADEMIC_INDEX                   => l_appl_inst_rec.ACADEMIC_INDEX,
                                                        X_ADM_CAL_TYPE                     => l_appl_inst_rec.ADM_CAL_TYPE,
                                                        X_APP_FILE_LOCATION                => l_appl_inst_rec.APP_FILE_LOCATION,
                                                        X_ADM_CI_SEQUENCE_NUMBER           => l_appl_inst_rec.ADM_CI_SEQUENCE_NUMBER,
                                                        X_COURSE_CD                        => l_appl_inst_rec.COURSE_CD,
                                                        X_APP_SOURCE_ID                    => l_appl_inst_rec.APP_SOURCE_ID,
                                                        X_CRV_VERSION_NUMBER               => l_appl_inst_rec.CRV_VERSION_NUMBER,
                                                        X_WAITLIST_RANK                    => l_appl_inst_rec.WAITLIST_RANK,
                                                        X_LOCATION_CD                      => l_appl_inst_rec.LOCATION_CD,
                                                        X_ATTENT_OTHER_INST_CD             => l_appl_inst_rec.ATTENT_OTHER_INST_CD,
                                                        X_ATTENDANCE_MODE                  => l_appl_inst_rec.ATTENDANCE_MODE,
                                                        X_EDU_GOAL_PRIOR_ENROLL_ID         => l_appl_inst_rec.EDU_GOAL_PRIOR_ENROLL_ID,
                                                        X_ATTENDANCE_TYPE                  => l_appl_inst_rec.ATTENDANCE_TYPE,
                                                        X_DECISION_MAKE_ID                 => p_dec_maker_id,
                                                        X_UNIT_SET_CD                      => l_appl_inst_rec.UNIT_SET_CD,
                                                        X_DECISION_DATE                    => l_decision_date,
                                                        X_ATTRIBUTE_CATEGORY               => l_appl_inst_rec.ATTRIBUTE_CATEGORY,
                                                        X_ATTRIBUTE1                       => l_appl_inst_rec.ATTRIBUTE1,
                                                        X_ATTRIBUTE2                       => l_appl_inst_rec.ATTRIBUTE2,
                                                        X_ATTRIBUTE3                       => l_appl_inst_rec.ATTRIBUTE3,
                                                        X_ATTRIBUTE4                       => l_appl_inst_rec.ATTRIBUTE4,
                                                        X_ATTRIBUTE5                       => l_appl_inst_rec.ATTRIBUTE5,
                                                        X_ATTRIBUTE6                       => l_appl_inst_rec.ATTRIBUTE6,
                                                        X_ATTRIBUTE7                       => l_appl_inst_rec.ATTRIBUTE7,
                                                        X_ATTRIBUTE8                       => l_appl_inst_rec.ATTRIBUTE8,
                                                        X_ATTRIBUTE9                       => l_appl_inst_rec.ATTRIBUTE9,
                                                        X_ATTRIBUTE10                      => l_appl_inst_rec.ATTRIBUTE10,
                                                        X_ATTRIBUTE11                      => l_appl_inst_rec.ATTRIBUTE11,
                                                        X_ATTRIBUTE12                      => l_appl_inst_rec.ATTRIBUTE12,
                                                        X_ATTRIBUTE13                      => l_appl_inst_rec.ATTRIBUTE13,
                                                        X_ATTRIBUTE14                      => l_appl_inst_rec.ATTRIBUTE14,
                                                        X_ATTRIBUTE15                      => l_appl_inst_rec.ATTRIBUTE15,
                                                        X_ATTRIBUTE16                      => l_appl_inst_rec.ATTRIBUTE16,
                                                        X_ATTRIBUTE17                      => l_appl_inst_rec.ATTRIBUTE17,
                                                        X_ATTRIBUTE18                      => l_appl_inst_rec.ATTRIBUTE18,
                                                        X_ATTRIBUTE19                      => l_appl_inst_rec.ATTRIBUTE19,
                                                        X_ATTRIBUTE20                      => l_appl_inst_rec.ATTRIBUTE20,
                                                        X_DECISION_REASON_ID               => p_dec_reason_id,
                                                        X_US_VERSION_NUMBER                => l_appl_inst_rec.US_VERSION_NUMBER,
                                                        X_DECISION_NOTES                   => l_appl_inst_rec.DECISION_NOTES,
                                                        X_PENDING_REASON_ID                => NULL,
                                                        X_PREFERENCE_NUMBER                => l_appl_inst_rec.PREFERENCE_NUMBER,
                                                        X_ADM_DOC_STATUS                   => l_appl_inst_rec.ADM_DOC_STATUS,
                                                        X_ADM_ENTRY_QUAL_STATUS            => l_appl_inst_rec.ADM_ENTRY_QUAL_STATUS,
                                                        X_DEFICIENCY_IN_PREP               => l_appl_inst_rec.DEFICIENCY_IN_PREP,
                                                        X_LATE_ADM_FEE_STATUS              => l_appl_inst_rec.LATE_ADM_FEE_STATUS,
                                                        X_SPL_CONSIDER_COMMENTS            => l_appl_inst_rec.SPL_CONSIDER_COMMENTS,
                                                        X_APPLY_FOR_FINAID                 => l_appl_inst_rec.APPLY_FOR_FINAID,
                                                        X_FINAID_APPLY_DATE                => l_appl_inst_rec.FINAID_APPLY_DATE,
                                                        X_ADM_OUTCOME_STATUS               => IGS_AD_GEN_009.ADMP_GET_SYS_AOS('CANCELLED'),
                                                        X_ADM_OTCM_STAT_AUTH_PER_ID        => l_appl_inst_rec.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                                        X_ADM_OUTCOME_STATUS_AUTH_DT       => l_appl_inst_rec.ADM_OUTCOME_STATUS_AUTH_DT,
                                                        X_ADM_OUTCOME_STATUS_REASON        => l_appl_inst_rec.ADM_OUTCOME_STATUS_REASON,
                                                        X_OFFER_DT                         => l_appl_inst_rec.OFFER_DT,
                                                        X_OFFER_RESPONSE_DT                => l_appl_inst_rec.OFFER_RESPONSE_DT,
                                                        X_PRPSD_COMMENCEMENT_DT            => l_appl_inst_rec.PRPSD_COMMENCEMENT_DT,
                                                        X_ADM_CNDTNL_OFFER_STATUS          => l_appl_inst_rec.ADM_CNDTNL_OFFER_STATUS,
                                                        X_CNDTNL_OFFER_SATISFIED_DT        => l_appl_inst_rec.CNDTNL_OFFER_SATISFIED_DT,
                                                        X_CNDNL_OFR_MUST_BE_STSFD_IND      => l_appl_inst_rec.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                                        X_ADM_OFFER_RESP_STATUS            => l_appl_inst_rec.ADM_OFFER_RESP_STATUS,
                                                        X_ACTUAL_RESPONSE_DT               => l_appl_inst_rec.ACTUAL_RESPONSE_DT,
                                                        X_ADM_OFFER_DFRMNT_STATUS          => l_appl_inst_rec.ADM_OFFER_DFRMNT_STATUS,
                                                        X_DEFERRED_ADM_CAL_TYPE            => l_appl_inst_rec.DEFERRED_ADM_CAL_TYPE,
                                                        X_DEFERRED_ADM_CI_SEQUENCE_NUM     => l_appl_inst_rec.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                                        X_DEFERRED_TRACKING_ID             => l_appl_inst_rec.DEFERRED_TRACKING_ID,
                                                        X_ASS_RANK                         => l_appl_inst_rec.ASS_RANK,
                                                        X_SECONDARY_ASS_RANK               => l_appl_inst_rec.SECONDARY_ASS_RANK,
                                                        X_INTR_ACCEPT_ADVICE_NUM           => l_appl_inst_rec.intrntnl_acceptance_advice_num,
                                                        X_ASS_TRACKING_ID                  => l_appl_inst_rec.ASS_TRACKING_ID,
                                                        X_FEE_CAT                          => l_appl_inst_rec.FEE_CAT,
                                                        X_HECS_PAYMENT_OPTION              => l_appl_inst_rec.HECS_PAYMENT_OPTION,
                                                        X_EXPECTED_COMPLETION_YR           => l_appl_inst_rec.EXPECTED_COMPLETION_YR,
                                                        X_EXPECTED_COMPLETION_PERD         => l_appl_inst_rec.EXPECTED_COMPLETION_PERD,
                                                        X_CORRESPONDENCE_CAT               => l_appl_inst_rec.CORRESPONDENCE_CAT,
                                                        X_ENROLMENT_CAT                    => l_appl_inst_rec.ENROLMENT_CAT,
                                                        X_FUNDING_SOURCE                   => l_appl_inst_rec.FUNDING_SOURCE,
                                                        X_APPLICANT_ACPTNCE_CNDTN          => l_appl_inst_rec.APPLICANT_ACPTNCE_CNDTN,
                                                        X_CNDTNL_OFFER_CNDTN               => l_appl_inst_rec.CNDTNL_OFFER_CNDTN,
                                                        X_MODE                             => 'R',
                                                        X_SS_APPLICATION_ID                => l_appl_inst_rec.SS_APPLICATION_ID,
                                                        X_SS_PWD                           => l_appl_inst_rec.SS_PWD,
                                                        X_AUTHORIZED_DT                    => l_appl_inst_rec.AUTHORIZED_DT,
                                                        X_AUTHORIZING_PERS_ID              => l_appl_inst_rec.AUTHORIZING_PERS_ID,
                                                        X_ENTRY_STATUS                     => l_appl_inst_rec.ENTRY_STATUS,
                                                        X_ENTRY_LEVEL                      => l_appl_inst_rec.ENTRY_LEVEL,
                                                        X_SCH_APL_TO_ID                    => l_appl_inst_rec.SCH_APL_TO_ID,
                                                        X_IDX_CALC_DATE                    => l_appl_inst_rec.IDX_CALC_DATE,
                                                        X_WAITLIST_STATUS                  => 'NOT-APPLIC',
                                                        X_ATTRIBUTE21                      => l_appl_inst_rec.ATTRIBUTE21,
                                                        X_ATTRIBUTE22                      => l_appl_inst_rec.ATTRIBUTE22,
                                                        X_ATTRIBUTE23                      => l_appl_inst_rec.ATTRIBUTE23,
                                                        X_ATTRIBUTE24                      => l_appl_inst_rec.ATTRIBUTE24,
                                                        X_ATTRIBUTE25                      => l_appl_inst_rec.ATTRIBUTE25,
                                                        X_ATTRIBUTE26                      => l_appl_inst_rec.ATTRIBUTE26,
                                                        X_ATTRIBUTE27                      => l_appl_inst_rec.ATTRIBUTE27,
                                                        X_ATTRIBUTE28                      => l_appl_inst_rec.ATTRIBUTE28,
                                                        X_ATTRIBUTE29                      => l_appl_inst_rec.ATTRIBUTE29,
                                                        X_ATTRIBUTE30                      => l_appl_inst_rec.ATTRIBUTE30,
                                                        X_ATTRIBUTE31                      => l_appl_inst_rec.ATTRIBUTE31,
                                                        X_ATTRIBUTE32                      => l_appl_inst_rec.ATTRIBUTE32,
                                                        X_ATTRIBUTE33                      => l_appl_inst_rec.ATTRIBUTE33,
                                                        X_ATTRIBUTE34                      => l_appl_inst_rec.ATTRIBUTE34,
                                                        X_ATTRIBUTE35                      => l_appl_inst_rec.ATTRIBUTE35,
                                                        X_ATTRIBUTE36                      => l_appl_inst_rec.ATTRIBUTE36,
                                                        X_ATTRIBUTE37                      => l_appl_inst_rec.ATTRIBUTE37,
                                                        X_ATTRIBUTE38                      => l_appl_inst_rec.ATTRIBUTE38,
                                                        X_ATTRIBUTE39                      => l_appl_inst_rec.ATTRIBUTE39,
                                                        X_ATTRIBUTE40                      => l_appl_inst_rec.ATTRIBUTE40,
                                                        X_FUT_ACAD_CAL_TYPE                => l_appl_inst_rec.FUTURE_ACAD_CAL_TYPE,
                                                        X_FUT_ACAD_CI_SEQUENCE_NUMBER      => l_appl_inst_rec.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
                                                        X_FUT_ADM_CAL_TYPE                 => l_appl_inst_rec.FUTURE_ADM_CAL_TYPE,
                                                        X_FUT_ADM_CI_SEQUENCE_NUMBER       => l_appl_inst_rec.FUTURE_ADM_CI_SEQUENCE_NUMBER,
                                                        X_PREV_TERM_ADM_APPL_NUMBER        => l_appl_inst_rec.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                                        X_PREV_TERM_SEQUENCE_NUMBER        => l_appl_inst_rec.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                                        X_FUT_TERM_ADM_APPL_NUMBER         => l_new_admission_appl_number,
                                                        X_FUT_TERM_SEQUENCE_NUMBER         => l_sequence_number,
                                                        X_DEF_ACAD_CAL_TYPE                => l_appl_inst_rec.DEF_ACAD_CAL_TYPE,
                                                        X_DEF_ACAD_CI_SEQUENCE_NUM         => l_appl_inst_rec.DEF_ACAD_CI_SEQUENCE_NUM,
                                                        X_DEF_PREV_TERM_ADM_APPL_NUM       => l_appl_inst_rec.DEF_PREV_TERM_ADM_APPL_NUM,
                                                        X_DEF_PREV_APPL_SEQUENCE_NUM       => l_appl_inst_rec.DEF_PREV_APPL_SEQUENCE_NUM,
                                                        X_DEF_TERM_ADM_APPL_NUM            => l_appl_inst_rec.DEF_TERM_ADM_APPL_NUM,
                                                        X_DEF_APPL_SEQUENCE_NUM            => l_appl_inst_rec.DEF_APPL_SEQUENCE_NUM,
                                                        X_APPL_INST_STATUS                 => l_appl_inst_rec.APPL_INST_STATUS,
                                                        X_AIS_REASON                       => l_appl_inst_rec.AIS_REASON,
                                                        X_DECLINE_OFR_REASON               => l_appl_inst_rec.DECLINE_OFR_REASON );

                                             /* Update the new application instance PREVIOUS_TERM_ADM_APPL_NUMBER and
					        PREVIOUS_TERM_SEQUENCE_NUMBER columns to link it with the old application */

	                                       OPEN c_get_appl_instance (l_appl_inst_rec.person_id, l_new_admission_appl_number,
	                                                               l_appl_inst_rec.nominated_course_cd, l_sequence_number);
                                               FETCH c_get_appl_instance INTO l_get_appl_instance;
	                                       CLOSE c_get_appl_instance;

                                               igs_ad_ps_appl_inst_pkg.UPDATE_ROW (
                                                        X_ROWID                            => l_get_appl_instance.ROWID,
                                                        X_PERSON_ID                        => l_get_appl_instance.PERSON_ID,
                                                        X_ADMISSION_APPL_NUMBER            => l_get_appl_instance.ADMISSION_APPL_NUMBER,
                                                        X_NOMINATED_COURSE_CD              => l_get_appl_instance.NOMINATED_COURSE_CD,
                                                        X_SEQUENCE_NUMBER                  => l_get_appl_instance.SEQUENCE_NUMBER,
                                                        X_PREDICTED_GPA                    => l_get_appl_instance.PREDICTED_GPA,
                                                        X_ACADEMIC_INDEX                   => l_get_appl_instance.ACADEMIC_INDEX,
                                                        X_ADM_CAL_TYPE                     => l_get_appl_instance.ADM_CAL_TYPE,
                                                        X_APP_FILE_LOCATION                => l_get_appl_instance.APP_FILE_LOCATION,
                                                        X_ADM_CI_SEQUENCE_NUMBER           => l_get_appl_instance.ADM_CI_SEQUENCE_NUMBER,
                                                        X_COURSE_CD                        => l_get_appl_instance.COURSE_CD,
                                                        X_APP_SOURCE_ID                    => l_get_appl_instance.APP_SOURCE_ID,
                                                        X_CRV_VERSION_NUMBER               => l_get_appl_instance.CRV_VERSION_NUMBER,
                                                        X_WAITLIST_RANK                    => l_get_appl_instance.WAITLIST_RANK,
                                                        X_LOCATION_CD                      => l_get_appl_instance.LOCATION_CD,
                                                        X_ATTENT_OTHER_INST_CD             => l_get_appl_instance.ATTENT_OTHER_INST_CD,
                                                        X_ATTENDANCE_MODE                  => l_get_appl_instance.ATTENDANCE_MODE,
                                                        X_EDU_GOAL_PRIOR_ENROLL_ID         => l_get_appl_instance.EDU_GOAL_PRIOR_ENROLL_ID,
                                                        X_ATTENDANCE_TYPE                  => l_get_appl_instance.ATTENDANCE_TYPE,
                                                        X_DECISION_MAKE_ID                 => l_get_appl_instance.DECISION_MAKE_ID,
                                                        X_UNIT_SET_CD                      => l_get_appl_instance.UNIT_SET_CD,
                                                        X_DECISION_DATE                    => l_get_appl_instance.DECISION_DATE,
                                                        X_ATTRIBUTE_CATEGORY               => l_get_appl_instance.ATTRIBUTE_CATEGORY,
                                                        X_ATTRIBUTE1                       => l_get_appl_instance.ATTRIBUTE1,
                                                        X_ATTRIBUTE2                       => l_get_appl_instance.ATTRIBUTE2,
                                                        X_ATTRIBUTE3                       => l_get_appl_instance.ATTRIBUTE3,
                                                        X_ATTRIBUTE4                       => l_get_appl_instance.ATTRIBUTE4,
                                                        X_ATTRIBUTE5                       => l_get_appl_instance.ATTRIBUTE5,
                                                        X_ATTRIBUTE6                       => l_get_appl_instance.ATTRIBUTE6,
                                                        X_ATTRIBUTE7                       => l_get_appl_instance.ATTRIBUTE7,
                                                        X_ATTRIBUTE8                       => l_get_appl_instance.ATTRIBUTE8,
                                                        X_ATTRIBUTE9                       => l_get_appl_instance.ATTRIBUTE9,
                                                        X_ATTRIBUTE10                      => l_get_appl_instance.ATTRIBUTE10,
                                                        X_ATTRIBUTE11                      => l_get_appl_instance.ATTRIBUTE11,
                                                        X_ATTRIBUTE12                      => l_get_appl_instance.ATTRIBUTE12,
                                                        X_ATTRIBUTE13                      => l_get_appl_instance.ATTRIBUTE13,
                                                        X_ATTRIBUTE14                      => l_get_appl_instance.ATTRIBUTE14,
                                                        X_ATTRIBUTE15                      => l_get_appl_instance.ATTRIBUTE15,
                                                        X_ATTRIBUTE16                      => l_get_appl_instance.ATTRIBUTE16,
                                                        X_ATTRIBUTE17                      => l_get_appl_instance.ATTRIBUTE17,
                                                        X_ATTRIBUTE18                      => l_get_appl_instance.ATTRIBUTE18,
                                                        X_ATTRIBUTE19                      => l_get_appl_instance.ATTRIBUTE19,
                                                        X_ATTRIBUTE20                      => l_get_appl_instance.ATTRIBUTE20,
                                                        X_DECISION_REASON_ID               => l_get_appl_instance.DECISION_REASON_ID,
                                                        X_US_VERSION_NUMBER                => l_get_appl_instance.US_VERSION_NUMBER,
                                                        X_DECISION_NOTES                   => l_get_appl_instance.DECISION_NOTES,
                                                        X_PENDING_REASON_ID                => l_get_appl_instance.PENDING_REASON_ID,
                                                        X_PREFERENCE_NUMBER                => l_get_appl_instance.PREFERENCE_NUMBER,
                                                        X_ADM_DOC_STATUS                   => l_get_appl_instance.ADM_DOC_STATUS,
                                                        X_ADM_ENTRY_QUAL_STATUS            => l_get_appl_instance.ADM_ENTRY_QUAL_STATUS,
                                                        X_DEFICIENCY_IN_PREP               => l_get_appl_instance.DEFICIENCY_IN_PREP,
                                                        X_LATE_ADM_FEE_STATUS              => l_get_appl_instance.LATE_ADM_FEE_STATUS,
                                                        X_SPL_CONSIDER_COMMENTS            => l_get_appl_instance.SPL_CONSIDER_COMMENTS,
                                                        X_APPLY_FOR_FINAID                 => l_get_appl_instance.APPLY_FOR_FINAID,
                                                        X_FINAID_APPLY_DATE                => l_get_appl_instance.FINAID_APPLY_DATE,
                                                        X_ADM_OUTCOME_STATUS               => l_get_appl_instance.ADM_OUTCOME_STATUS,
                                                        X_ADM_OTCM_STAT_AUTH_PER_ID        => l_get_appl_instance.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                                        X_ADM_OUTCOME_STATUS_AUTH_DT       => l_get_appl_instance.ADM_OUTCOME_STATUS_AUTH_DT,
                                                        X_ADM_OUTCOME_STATUS_REASON        => l_get_appl_instance.ADM_OUTCOME_STATUS_REASON,
                                                        X_OFFER_DT                         => l_get_appl_instance.OFFER_DT,
                                                        X_OFFER_RESPONSE_DT                => l_get_appl_instance.OFFER_RESPONSE_DT,
                                                        X_PRPSD_COMMENCEMENT_DT            => l_get_appl_instance.PRPSD_COMMENCEMENT_DT,
                                                        X_ADM_CNDTNL_OFFER_STATUS          => l_get_appl_instance.ADM_CNDTNL_OFFER_STATUS,
                                                        X_CNDTNL_OFFER_SATISFIED_DT        => l_get_appl_instance.CNDTNL_OFFER_SATISFIED_DT,
                                                        X_CNDNL_OFR_MUST_BE_STSFD_IND      => l_get_appl_instance.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                                        X_ADM_OFFER_RESP_STATUS            => l_get_appl_instance.ADM_OFFER_RESP_STATUS,
                                                        X_ACTUAL_RESPONSE_DT               => l_get_appl_instance.ACTUAL_RESPONSE_DT,
                                                        X_ADM_OFFER_DFRMNT_STATUS          => l_get_appl_instance.ADM_OFFER_DFRMNT_STATUS,
                                                        X_DEFERRED_ADM_CAL_TYPE            => l_get_appl_instance.DEFERRED_ADM_CAL_TYPE,
                                                        X_DEFERRED_ADM_CI_SEQUENCE_NUM     => l_get_appl_instance.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                                        X_DEFERRED_TRACKING_ID             => l_get_appl_instance.DEFERRED_TRACKING_ID,
                                                        X_ASS_RANK                         => l_get_appl_instance.ASS_RANK,
                                                        X_SECONDARY_ASS_RANK               => l_get_appl_instance.SECONDARY_ASS_RANK,
                                                        X_INTR_ACCEPT_ADVICE_NUM           => l_get_appl_instance.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
                                                        X_ASS_TRACKING_ID                  => l_get_appl_instance.ASS_TRACKING_ID,
                                                        X_FEE_CAT                          => l_get_appl_instance.FEE_CAT,
                                                        X_HECS_PAYMENT_OPTION              => l_get_appl_instance.HECS_PAYMENT_OPTION,
                                                        X_EXPECTED_COMPLETION_YR           => l_get_appl_instance.EXPECTED_COMPLETION_YR,
                                                        X_EXPECTED_COMPLETION_PERD         => l_get_appl_instance.EXPECTED_COMPLETION_PERD,
                                                        X_CORRESPONDENCE_CAT               => l_get_appl_instance.CORRESPONDENCE_CAT,
                                                        X_ENROLMENT_CAT                    => l_get_appl_instance.ENROLMENT_CAT,
                                                        X_FUNDING_SOURCE                   => l_get_appl_instance.FUNDING_SOURCE,
                                                        X_APPLICANT_ACPTNCE_CNDTN          => l_get_appl_instance.APPLICANT_ACPTNCE_CNDTN,
                                                        X_CNDTNL_OFFER_CNDTN               => l_get_appl_instance.CNDTNL_OFFER_CNDTN,
                                                        X_MODE                             => 'R',
                                                        X_SS_APPLICATION_ID                => l_get_appl_instance.SS_APPLICATION_ID,
                                                        X_SS_PWD                           => l_get_appl_instance.SS_PWD,
                                                        X_AUTHORIZED_DT                    => l_get_appl_instance.AUTHORIZED_DT,
                                                        X_AUTHORIZING_PERS_ID              => l_get_appl_instance.AUTHORIZING_PERS_ID,
                                                        X_ENTRY_STATUS                     => l_get_appl_instance.ENTRY_STATUS,
                                                        X_ENTRY_LEVEL                      => l_get_appl_instance.ENTRY_LEVEL,
                                                        X_SCH_APL_TO_ID                    => l_get_appl_instance.SCH_APL_TO_ID,
                                                        X_IDX_CALC_DATE                    => l_get_appl_instance.IDX_CALC_DATE,
                                                        X_WAITLIST_STATUS                  => l_get_appl_instance.WAITLIST_STATUS,
                                                        X_ATTRIBUTE21                      => l_get_appl_instance.ATTRIBUTE21,
                                                        X_ATTRIBUTE22                      => l_get_appl_instance.ATTRIBUTE22,
                                                        X_ATTRIBUTE23                      => l_get_appl_instance.ATTRIBUTE23,
                                                        X_ATTRIBUTE24                      => l_get_appl_instance.ATTRIBUTE24,
                                                        X_ATTRIBUTE25                      => l_get_appl_instance.ATTRIBUTE25,
                                                        X_ATTRIBUTE26                      => l_get_appl_instance.ATTRIBUTE26,
                                                        X_ATTRIBUTE27                      => l_get_appl_instance.ATTRIBUTE27,
                                                        X_ATTRIBUTE28                      => l_get_appl_instance.ATTRIBUTE28,
                                                        X_ATTRIBUTE29                      => l_get_appl_instance.ATTRIBUTE29,
                                                        X_ATTRIBUTE30                      => l_get_appl_instance.ATTRIBUTE30,
                                                        X_ATTRIBUTE31                      => l_get_appl_instance.ATTRIBUTE31,
                                                        X_ATTRIBUTE32                      => l_get_appl_instance.ATTRIBUTE32,
                                                        X_ATTRIBUTE33                      => l_get_appl_instance.ATTRIBUTE33,
                                                        X_ATTRIBUTE34                      => l_get_appl_instance.ATTRIBUTE34,
                                                        X_ATTRIBUTE35                      => l_get_appl_instance.ATTRIBUTE35,
                                                        X_ATTRIBUTE36                      => l_get_appl_instance.ATTRIBUTE36,
                                                        X_ATTRIBUTE37                      => l_get_appl_instance.ATTRIBUTE37,
                                                        X_ATTRIBUTE38                      => l_get_appl_instance.ATTRIBUTE38,
                                                        X_ATTRIBUTE39                      => l_get_appl_instance.ATTRIBUTE39,
                                                        X_ATTRIBUTE40                      => l_get_appl_instance.ATTRIBUTE40,
                                                        X_FUT_ACAD_CAL_TYPE                => l_get_appl_instance.FUTURE_ACAD_CAL_TYPE,
                                                        X_FUT_ACAD_CI_SEQUENCE_NUMBER      => l_get_appl_instance.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
                                                        X_FUT_ADM_CAL_TYPE                 => l_get_appl_instance.FUTURE_ADM_CAL_TYPE,
                                                        X_FUT_ADM_CI_SEQUENCE_NUMBER       => l_get_appl_instance.FUTURE_ADM_CI_SEQUENCE_NUMBER,
                                                        X_PREV_TERM_ADM_APPL_NUMBER        => l_appl_inst_rec.ADMISSION_APPL_NUMBER,
                                                        X_PREV_TERM_SEQUENCE_NUMBER        => l_appl_inst_rec.SEQUENCE_NUMBER,
                                                        X_FUT_TERM_ADM_APPL_NUMBER         => l_get_appl_instance.FUTURE_TERM_ADM_APPL_NUMBER,
                                                        X_FUT_TERM_SEQUENCE_NUMBER         => l_get_appl_instance.FUTURE_TERM_SEQUENCE_NUMBER,
                                                        X_DEF_ACAD_CAL_TYPE                => l_get_appl_instance.DEF_ACAD_CAL_TYPE,
                                                        X_DEF_ACAD_CI_SEQUENCE_NUM         => l_get_appl_instance.DEF_ACAD_CI_SEQUENCE_NUM,
                                                        X_DEF_PREV_TERM_ADM_APPL_NUM       => l_get_appl_instance.DEF_PREV_TERM_ADM_APPL_NUM,
                                                        X_DEF_PREV_APPL_SEQUENCE_NUM       => l_get_appl_instance.DEF_PREV_APPL_SEQUENCE_NUM,
                                                        X_DEF_TERM_ADM_APPL_NUM            => l_get_appl_instance.DEF_TERM_ADM_APPL_NUM,
                                                        X_DEF_APPL_SEQUENCE_NUM            => l_get_appl_instance.DEF_APPL_SEQUENCE_NUM,
                                                        X_APPL_INST_STATUS                 => l_get_appl_instance.APPL_INST_STATUS,
                                                        X_AIS_REASON                       => l_get_appl_instance.AIS_REASON,
                                                        X_DECLINE_OFR_REASON               => l_get_appl_instance.DECLINE_OFR_REASON);


                                               l_successful_records := l_successful_records + 1;

                                               COMMIT;
					     END IF;

                        ELSE

                                fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                                  RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                                  RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

				    IF (l_message_name IS NULL) THEN
				      igs_ad_gen_016.extract_msg_from_stack (
                                         p_msg_at_index                => l_msg_at_index,
                                         p_return_status               => l_return_status,
                                         p_msg_count                   => l_msg_count,
                                         p_msg_data                    => l_msg_data,
                                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

				      IF (l_msg_count > 0) THEN
                                        fnd_file.put_line(fnd_file.log, l_msg_data);
                                      ELSE
				        FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating application instance of the new program');
                                      END IF;
                                    ELSE
				      fnd_file.put_line(fnd_file.log, l_message_name);
				    END IF;

			        l_failed_records := l_failed_records + 1;
                                ROLLBACK TO c_create_application;

			END IF;
			--ELSE  -- Else of Application Instance
			EXCEPTION
			WHEN OTHERS THEN
                                             fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                                               RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                                               RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

			                     l_failed_records := l_failed_records + 1;



                                             IF l_message_name  IN ('IGS_AD_NOMINATE_PRG_OFR_ENTRY', 'IGS_AD_NOMINATED_PRG_ENTRYPNT') THEN

                                                    l_message_name := 'IGS_AD_CAL_PGM_NOT_OFFER';
                                                    fnd_message.set_name('IGS', l_message_name);
                                                    fnd_message.set_token('PGM', l_appl_inst_rec.nominated_course_cd);
                                                    fnd_message.set_token('ALTCODE',l_appl_inst_rec.future_acad_cal_type||','||
			           		                           IGS_GE_NUMBER.TO_CANN(l_appl_inst_rec.future_acad_ci_sequence_number)
                                                                           ||'/'||l_appl_inst_rec.future_adm_cal_type||','||
						           	           IGS_GE_NUMBER.TO_CANN(l_appl_inst_rec.future_adm_ci_sequence_number));
                                                    fnd_file.put_line(fnd_file.log, fnd_message.get);

                                             ELSE

                                                    fnd_message.set_name('IGS', l_message_name);
                                                    fnd_file.put_line(fnd_file.log, fnd_message.get);

                                             END IF;
					     ROLLBACK TO c_create_application;

                        END;

         END IF;


    END LOOP;

  END LOOP;
  CLOSE c_person_group;

ELSE

  FOR l_appl_inst_rec IN c_appl_inst(NULL,
                                     l_fut_acad_cal_type,
				     l_fut_acad_cal_seq_no,
				     l_fut_adm_cal_type,
				     l_fut_adm_cal_seq_no,
				     l_prev_acad_cal_type,
				     l_prev_acad_cal_seq_no,
				     l_prev_adm_cal_type,
				     l_prev_adm_cal_seq_no,
				     l_admission_type.admission_cat,
				     l_admission_type.s_admission_process_type) LOOP

         l_total_records := l_total_records + 1;

	 l_application_created := TRUE;
         l_program_created     := TRUE;
	 l_instance_created    := TRUE;

	 SAVEPOINT c_create_application;

         IF    l_appl_inst_rec.person_id                      <>  nvl(l_person_id,-1)                     OR
               l_appl_inst_rec.admission_appl_number          <>  nvl(l_admission_appl_number,-1)     OR
               l_appl_inst_rec.future_acad_cal_type           <>  nvl(l_future_acad_cal_type,-1)          OR
               l_appl_inst_rec.future_acad_ci_sequence_number <>  nvl(l_fut_acad_ci_seq_no,-1)            OR
               l_appl_inst_rec.future_adm_cal_type            <>  nvl(l_future_adm_cal_type,-1)           OR
               l_appl_inst_rec.future_adm_ci_sequence_number  <>  nvl(l_fut_adm_ci_seq_no,-1)             THEN

               BEGIN

	         IF IGS_AD_GEN_014.insert_adm_appl(
                   p_person_id                    => l_appl_inst_rec.person_id,
                   p_appl_dt                      => l_appl_inst_rec.appl_dt,
                   p_acad_cal_type                => l_appl_inst_rec.future_acad_cal_type ,
                   p_acad_ci_sequence_number      => l_appl_inst_rec.future_acad_ci_sequence_number ,
                   p_adm_cal_type                 => l_appl_inst_rec.future_adm_cal_type ,
                   p_adm_ci_sequence_number       => l_appl_inst_rec.future_adm_ci_sequence_number ,
                   p_admission_cat                => l_appl_inst_rec.admission_cat,
                   p_s_admission_process_type     => l_appl_inst_rec.s_admission_process_type,
                   p_adm_appl_status              => l_appl_inst_rec.adm_appl_status,
                   p_adm_fee_status               => l_appl_inst_rec.adm_fee_status,
                   p_tac_appl_ind                 => 'N',
                   p_adm_appl_number              => l_new_admission_appl_number,
                   p_message_name                 => l_message_name,
                   p_spcl_grp_1                   => l_appl_inst_rec.spcl_grp_1,
                   p_spcl_grp_2                   => l_appl_inst_rec.spcl_grp_2,
                   p_common_app                   => l_appl_inst_rec.common_app,
                   p_application_type             => l_appl_inst_rec.application_type,
                   p_choice_number                => l_appl_inst_rec.choice_number,
                   p_routeb_pref                  => l_appl_inst_rec.routeb_pref,
                   p_alt_appl_id                  => l_appl_inst_rec.alt_appl_id,
		   p_log                          => 'N') THEN

		     IF copy_application_child_records (
                        p_person_id                 => l_appl_inst_rec.person_id,
	                p_new_admission_appl_number => l_new_admission_appl_number,
	                p_old_admission_appl_number => l_appl_inst_rec.admission_appl_number,
			p_nominated_course_cd       => l_appl_inst_rec.nominated_course_cd,
			p_sequence_number           => l_appl_inst_rec.sequence_number) = FALSE THEN

		        l_failed_records := l_failed_records + 1;

		        ROLLBACK TO c_create_application;
			l_application_created := FALSE;
                      END IF;
		 ELSE

		   l_application_created := FALSE;
		   l_failed_records := l_failed_records + 1;
                   ROLLBACK TO c_create_application;

                   fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                                  RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                                  RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');
		   IF (l_message_name IS NULL) THEN
		     igs_ad_gen_016.extract_msg_from_stack (
                         p_msg_at_index                => l_msg_at_index,
                         p_return_status               => l_return_status,
                         p_msg_count                   => l_msg_count,
                         p_msg_data                    => l_msg_data,
                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		     IF (l_msg_count > 0) THEN
                       fnd_file.put_line(fnd_file.log, l_msg_data);
                     ELSE
		       FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating the new application');
                     END IF;
                   ELSE
		     fnd_file.put_line(fnd_file.log, l_message_name);
		   END IF;
                 END IF;
               EXCEPTION
	       	 WHEN OTHERS THEN
		   l_application_created := FALSE;
                   l_failed_records := l_failed_records + 1;

		   ROLLBACK TO c_create_application;
		   fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                                    RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                                    RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

		   IF (l_message_name IS NULL) THEN
		     igs_ad_gen_016.extract_msg_from_stack (
                         p_msg_at_index                => l_msg_at_index,
                         p_return_status               => l_return_status,
                         p_msg_count                   => l_msg_count,
                         p_msg_data                    => l_msg_data,
                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		     IF (l_msg_count > 0) THEN
                       fnd_file.put_line(fnd_file.log, l_msg_data);
                     ELSE
		       FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating the new application');
                     END IF;
                   ELSE
		     fnd_file.put_line(fnd_file.log, l_message_name);
		   END IF;
               END;

	 END IF;

	 IF ((l_appl_inst_rec.person_id                      <>  nvl(l_person_id,-1)             OR
             l_appl_inst_rec.admission_appl_number          <>  nvl(l_admission_appl_number,-1) OR
             l_appl_inst_rec.future_acad_cal_type           <>  nvl(l_future_acad_cal_type,-1)  OR
             l_appl_inst_rec.future_acad_ci_sequence_number <>  nvl(l_fut_acad_ci_seq_no,-1)    OR
             l_appl_inst_rec.future_adm_cal_type            <>  nvl(l_future_adm_cal_type,-1)   OR
             l_appl_inst_rec.future_adm_ci_sequence_number  <>  nvl(l_fut_adm_ci_seq_no,-1)     OR
	     l_appl_inst_rec.nominated_course_cd            <>  nvl(l_nominated_course_cd,-1)) AND
             l_application_created = TRUE) THEN


	     BEGIN

	       IF IGS_AD_GEN_014.insert_adm_appl_prog(
                      p_person_id                   => l_appl_inst_rec.person_id,
                      p_adm_appl_number             => l_new_admission_appl_number,
                      p_nominated_course_cd         => l_appl_inst_rec.nominated_course_cd,
                      p_transfer_course_cd          => l_appl_inst_rec.transfer_course_cd,
                      p_basis_for_admission_type    => l_appl_inst_rec.basis_for_admission_type,
                      p_admission_cd                => l_appl_inst_rec.admission_cd,
                      p_req_for_reconsideration_ind => l_appl_inst_rec.req_for_reconsideration_ind,
                      p_req_for_adv_standing_ind    => l_appl_inst_rec.req_for_adv_standing_ind,
                      p_message_name                => l_message_name,
		      p_log                         => 'N') THEN


                 OPEN c_get_prog_dtls(l_appl_inst_rec.person_id, l_appl_inst_rec.admission_appl_number, l_appl_inst_rec.nominated_course_cd);
                 FETCH c_get_prog_dtls INTO l_get_prog_dtls;
                 CLOSE c_get_prog_dtls;


                 IF NVL(l_get_prog_dtls.req_for_reconsideration_ind,'N') = 'Y' THEN

	           BEGIN

		     igs_ad_ps_appl_pkg.update_row(
                          x_rowid                       => l_get_prog_dtls.row_id,
                          x_person_id                   => l_get_prog_dtls.person_id,
                          x_admission_appl_number       => l_get_prog_dtls.admission_appl_number,
                          x_nominated_course_cd         => l_get_prog_dtls.nominated_course_cd,
                          x_transfer_course_cd          => l_get_prog_dtls.transfer_course_cd,
                          x_basis_for_admission_type    => l_get_prog_dtls.basis_for_admission_type,
                          x_admission_cd                => l_get_prog_dtls.admission_cd,
                          x_course_rank_set             => l_get_prog_dtls.course_rank_set,
                          x_course_rank_schedule        => l_get_prog_dtls.course_rank_schedule,
                          x_req_for_reconsideration_ind => 'N',
                          x_req_for_adv_standing_ind    => l_get_prog_dtls.req_for_adv_standing_ind,
                          x_mode                        => 'R');

                   EXCEPTION
		     WHEN OTHERS THEN
		     ROLLBACK TO c_create_application;
		     fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                       RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                       RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');
                     fnd_message.set_name('IGS', 'Failed to update the Request for Reconsideration Checkbox: ' || SQLERRM );
		     l_program_created:= FALSE;
                   END;

		 END IF;


	     ELSE

                 l_program_created:= FALSE;

                 l_failed_records := l_failed_records + 1;

		 ROLLBACK TO c_create_application;
		 fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                   RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                   RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

		 IF (l_message_name IS NULL) THEN
		   igs_ad_gen_016.extract_msg_from_stack (
                      p_msg_at_index                => l_msg_at_index,
                      p_return_status               => l_return_status,
                      p_msg_count                   => l_msg_count,
                      p_msg_data                    => l_msg_data,
                      p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		   IF (l_msg_count > 0) THEN
                     fnd_file.put_line(fnd_file.log, l_msg_data);
                   ELSE
		     FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating application program for the new application');
                   END IF;
                 ELSE
		   fnd_file.put_line(fnd_file.log, l_message_name);
		 END IF;
	     END IF;
            EXCEPTION

		  WHEN OTHERS THEN
	               l_program_created := FALSE;

		       l_failed_records := l_failed_records + 1;

		       ROLLBACK TO c_create_application;
		       fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                         RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                         RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');
		    IF (l_message_name IS NULL) THEN
		      igs_ad_gen_016.extract_msg_from_stack (
                         p_msg_at_index                => l_msg_at_index,
                         p_return_status               => l_return_status,
                         p_msg_count                   => l_msg_count,
                         p_msg_data                    => l_msg_data,
                         p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		      IF (l_msg_count > 0) THEN
                        fnd_file.put_line(fnd_file.log, l_msg_data);
                      ELSE
		        FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating application program for the new application');
                      END IF;
                    ELSE
		      fnd_file.put_line(fnd_file.log, l_message_name);
		    END IF;
            END;


         END IF;

         IF l_application_created = TRUE AND l_program_created = TRUE THEN

		 BEGIN
		   IF IGS_AD_GEN_014.insert_adm_appl_prog_inst (
                              p_person_id                   => l_appl_inst_rec.person_id,
                              p_admission_appl_number       => l_new_admission_appl_number,
                              p_acad_cal_type               => l_appl_inst_rec.future_acad_cal_type,
                              p_acad_ci_sequence_number     => l_appl_inst_rec.future_acad_ci_sequence_number,
                              p_adm_cal_type                => l_appl_inst_rec.future_adm_cal_type,
                              p_adm_ci_sequence_number      => l_appl_inst_rec.future_adm_ci_sequence_number,
                              p_admission_cat               => l_appl_inst_rec.admission_cat,
                              p_s_admission_process_type    => l_appl_inst_rec.s_admission_process_type,
                              p_appl_dt                     => l_appl_inst_rec.appl_dt,
                              p_adm_fee_status              => l_appl_inst_rec.adm_fee_status,
                              p_preference_number           => l_appl_inst_rec.preference_number,
                              p_offer_dt                    => NULL,
                              p_offer_response_dt           => NULL,
                              p_course_cd                   => l_appl_inst_rec.nominated_course_cd,
                              p_crv_version_number          => l_appl_inst_rec.crv_version_number,
                              p_location_cd                 => l_appl_inst_rec.location_cd,
                              p_attendance_mode             => l_appl_inst_rec.attendance_mode,
                              p_attendance_type             => l_appl_inst_rec.attendance_type,
                              p_unit_set_cd                 => l_appl_inst_rec.unit_set_cd,
                              p_us_version_number           => l_appl_inst_rec.us_version_number,
                              p_fee_cat                     => l_appl_inst_rec.fee_cat,
                              p_correspondence_cat          => l_appl_inst_rec.correspondence_cat,
                              p_enrolment_cat               => l_appl_inst_rec.enrolment_cat,
                              p_funding_source              => l_appl_inst_rec.funding_source,
                              p_edu_goal_prior_enroll       => l_appl_inst_rec.edu_goal_prior_enroll_id,
                              p_app_source_id               => l_appl_inst_rec.app_source_id,
                              p_apply_for_finaid            => l_appl_inst_rec.apply_for_finaid,
                              p_finaid_apply_date           => l_appl_inst_rec.finaid_apply_date,
                              p_attribute_category          => l_appl_inst_rec.attribute_category,
                              p_attribute1                  => l_appl_inst_rec.attribute1,
                              p_attribute2                  => l_appl_inst_rec.attribute2,
                              p_attribute3                  => l_appl_inst_rec.attribute3,
                              p_attribute4                  => l_appl_inst_rec.attribute4,
                              p_attribute5                  => l_appl_inst_rec.attribute5,
                              p_attribute6                  => l_appl_inst_rec.attribute6,
                              p_attribute7                  => l_appl_inst_rec.attribute7,
                              p_attribute8                  => l_appl_inst_rec.attribute8,
                              p_attribute9                  => l_appl_inst_rec.attribute9,
                              p_attribute10                 => l_appl_inst_rec.attribute10,
                              p_attribute11                 => l_appl_inst_rec.attribute11,
                              p_attribute12                 => l_appl_inst_rec.attribute12,
                              p_attribute13                 => l_appl_inst_rec.attribute13,
                              p_attribute14                 => l_appl_inst_rec.attribute14,
                              p_attribute15                 => l_appl_inst_rec.attribute15,
                              p_attribute16                 => l_appl_inst_rec.attribute16,
                              p_attribute17                 => l_appl_inst_rec.attribute17,
                              p_attribute18                 => l_appl_inst_rec.attribute18,
                              p_attribute19                 => l_appl_inst_rec.attribute19,
                              p_attribute20                 => l_appl_inst_rec.attribute20,
                              p_attribute21                 => l_appl_inst_rec.attribute21,
                              p_attribute22                 => l_appl_inst_rec.attribute22,
                              p_attribute23                 => l_appl_inst_rec.attribute23,
                              p_attribute24                 => l_appl_inst_rec.attribute24,
                              p_attribute25                 => l_appl_inst_rec.attribute25,
                              p_attribute26                 => l_appl_inst_rec.attribute26,
                              p_attribute27                 => l_appl_inst_rec.attribute27,
                              p_attribute28                 => l_appl_inst_rec.attribute28,
                              p_attribute29                 => l_appl_inst_rec.attribute29,
                              p_attribute30                 => l_appl_inst_rec.attribute30,
                              p_attribute31                 => l_appl_inst_rec.attribute31,
                              p_attribute32                 => l_appl_inst_rec.attribute32,
                              p_attribute33                 => l_appl_inst_rec.attribute33,
                              p_attribute34                 => l_appl_inst_rec.attribute34,
                              p_attribute35                 => l_appl_inst_rec.attribute35,
                              p_attribute36                 => l_appl_inst_rec.attribute36,
                              p_attribute37                 => l_appl_inst_rec.attribute37,
                              p_attribute38                 => l_appl_inst_rec.attribute38,
                              p_attribute39                 => l_appl_inst_rec.attribute39,
                              p_attribute40                 => l_appl_inst_rec.attribute40,
                              p_ss_application_id           => NULL,
                              p_sequence_number             => l_sequence_number,
                              p_return_type                 => l_return_type,
                              p_error_code                  => l_error_code,
                              p_message_name                => l_message_name,
                              p_entry_status                => l_appl_inst_rec.entry_status,
                              p_entry_level                 => l_appl_inst_rec.entry_level,
                              p_sch_apl_to_id               => l_appl_inst_rec.sch_apl_to_id,
			      p_log                         => 'N') THEN


                       OPEN c_get_acad_cal_info(l_appl_inst_rec.person_id,l_new_admission_appl_number);
                       FETCH c_get_acad_cal_info INTO l_get_acad_cal_info;
                       CLOSE c_get_acad_cal_info;

	               v_start_dt := igs_en_gen_002.enrp_get_acad_comm(
                                         l_get_acad_cal_info.acad_cal_type,
                                         l_get_acad_cal_info.acad_ci_sequence_number,
                                         l_appl_inst_rec.person_id,
                                         l_appl_inst_rec.nominated_course_cd,
                                         l_new_admission_appl_number,
                                         l_appl_inst_rec.nominated_course_cd,
                                         l_sequence_number,
                                         'Y');

                       IF copy_instance_child_records (
		                         p_new_admission_appl_number => l_new_admission_appl_number,
                                         p_new_sequence_number       => l_sequence_number,
                                         p_person_id                 => l_appl_inst_rec.person_id,
                                         p_old_admission_appl_number => l_appl_inst_rec.admission_appl_number,
                                         p_old_sequence_number       => l_appl_inst_rec.sequence_number,
                                         p_nominated_course_cd       => l_appl_inst_rec.nominated_course_cd,
                                         p_start_dt                  => v_start_dt) THEN

	   	              l_person_id                     := l_appl_inst_rec.person_id;
                              l_admission_appl_number     := l_appl_inst_rec.admission_appl_number;
                              l_future_acad_cal_type          := l_appl_inst_rec.future_acad_cal_type;
                              l_fut_acad_ci_seq_no            := l_appl_inst_rec.future_acad_ci_sequence_number;
                              l_future_adm_cal_type           := l_appl_inst_rec.future_adm_cal_type;
                              l_fut_adm_ci_seq_no             := l_appl_inst_rec.future_adm_ci_sequence_number;
			      l_nominated_course_cd    := l_appl_inst_rec.nominated_course_cd;
                       ELSE

			      l_failed_records := l_failed_records + 1;

			      ROLLBACK TO c_create_application;
                              l_instance_created := FALSE;
		       END IF;
                       /* Update the existing application instance to CANCELLED and populate the values of
	               FUTURE_TERM_ADM_APPL_NUMBER and FUTURE_TERM_SEQUENCE_NUMBER
		       to link with the new application instance*/

		       IF l_instance_created = TRUE THEN
		         igs_ad_ps_appl_inst_pkg.UPDATE_ROW (
                                          X_ROWID                            => l_appl_inst_rec.row_id,
                                          X_PERSON_ID                        => l_appl_inst_rec.person_id,
                                          X_ADMISSION_APPL_NUMBER            => l_appl_inst_rec.ADMISSION_APPL_NUMBER,
                                          X_NOMINATED_COURSE_CD              => l_appl_inst_rec.NOMINATED_COURSE_CD,
                                          X_SEQUENCE_NUMBER                  => l_appl_inst_rec.SEQUENCE_NUMBER,
                                          X_PREDICTED_GPA                    => l_appl_inst_rec.PREDICTED_GPA,
                                          X_ACADEMIC_INDEX                   => l_appl_inst_rec.ACADEMIC_INDEX,
                                          X_ADM_CAL_TYPE                     => l_appl_inst_rec.ADM_CAL_TYPE,
                                          X_APP_FILE_LOCATION                => l_appl_inst_rec.APP_FILE_LOCATION,
                                          X_ADM_CI_SEQUENCE_NUMBER           => l_appl_inst_rec.ADM_CI_SEQUENCE_NUMBER,
                                          X_COURSE_CD                        => l_appl_inst_rec.COURSE_CD,
                                          X_APP_SOURCE_ID                    => l_appl_inst_rec.APP_SOURCE_ID,
                                          X_CRV_VERSION_NUMBER               => l_appl_inst_rec.CRV_VERSION_NUMBER,
                                          X_WAITLIST_RANK                    => l_appl_inst_rec.WAITLIST_RANK,
                                          X_LOCATION_CD                      => l_appl_inst_rec.LOCATION_CD,
                                          X_ATTENT_OTHER_INST_CD             => l_appl_inst_rec.ATTENT_OTHER_INST_CD,
                                          X_ATTENDANCE_MODE                  => l_appl_inst_rec.ATTENDANCE_MODE,
                                          X_EDU_GOAL_PRIOR_ENROLL_ID         => l_appl_inst_rec.EDU_GOAL_PRIOR_ENROLL_ID,
                                          X_ATTENDANCE_TYPE                  => l_appl_inst_rec.ATTENDANCE_TYPE,
                                          X_DECISION_MAKE_ID                 => p_dec_maker_id,
                                          X_UNIT_SET_CD                      => l_appl_inst_rec.UNIT_SET_CD,
                                          X_DECISION_DATE                    => l_decision_date,
                                          X_ATTRIBUTE_CATEGORY               => l_appl_inst_rec.ATTRIBUTE_CATEGORY,
                                          X_ATTRIBUTE1                       => l_appl_inst_rec.ATTRIBUTE1,
                                          X_ATTRIBUTE2                       => l_appl_inst_rec.ATTRIBUTE2,
                                          X_ATTRIBUTE3                       => l_appl_inst_rec.ATTRIBUTE3,
                                          X_ATTRIBUTE4                       => l_appl_inst_rec.ATTRIBUTE4,
                                          X_ATTRIBUTE5                       => l_appl_inst_rec.ATTRIBUTE5,
                                          X_ATTRIBUTE6                       => l_appl_inst_rec.ATTRIBUTE6,
                                          X_ATTRIBUTE7                       => l_appl_inst_rec.ATTRIBUTE7,
                                          X_ATTRIBUTE8                       => l_appl_inst_rec.ATTRIBUTE8,
                                          X_ATTRIBUTE9                       => l_appl_inst_rec.ATTRIBUTE9,
                                          X_ATTRIBUTE10                      => l_appl_inst_rec.ATTRIBUTE10,
                                          X_ATTRIBUTE11                      => l_appl_inst_rec.ATTRIBUTE11,
                                          X_ATTRIBUTE12                      => l_appl_inst_rec.ATTRIBUTE12,
                                          X_ATTRIBUTE13                      => l_appl_inst_rec.ATTRIBUTE13,
                                          X_ATTRIBUTE14                      => l_appl_inst_rec.ATTRIBUTE14,
                                          X_ATTRIBUTE15                      => l_appl_inst_rec.ATTRIBUTE15,
                                          X_ATTRIBUTE16                      => l_appl_inst_rec.ATTRIBUTE16,
                                          X_ATTRIBUTE17                      => l_appl_inst_rec.ATTRIBUTE17,
                                          X_ATTRIBUTE18                      => l_appl_inst_rec.ATTRIBUTE18,
                                          X_ATTRIBUTE19                      => l_appl_inst_rec.ATTRIBUTE19,
                                          X_ATTRIBUTE20                      => l_appl_inst_rec.ATTRIBUTE20,
                                          X_DECISION_REASON_ID               => p_dec_reason_id,
                                          X_US_VERSION_NUMBER                => l_appl_inst_rec.US_VERSION_NUMBER,
                                          X_DECISION_NOTES                   => l_appl_inst_rec.DECISION_NOTES,
                                          X_PENDING_REASON_ID                => NULL,
                                          X_PREFERENCE_NUMBER                => l_appl_inst_rec.PREFERENCE_NUMBER,
                                          X_ADM_DOC_STATUS                   => l_appl_inst_rec.ADM_DOC_STATUS,
                                          X_ADM_ENTRY_QUAL_STATUS            => l_appl_inst_rec.ADM_ENTRY_QUAL_STATUS,
                                          X_DEFICIENCY_IN_PREP               => l_appl_inst_rec.DEFICIENCY_IN_PREP,
                                          X_LATE_ADM_FEE_STATUS              => l_appl_inst_rec.LATE_ADM_FEE_STATUS,
                                          X_SPL_CONSIDER_COMMENTS            => l_appl_inst_rec.SPL_CONSIDER_COMMENTS,
                                          X_APPLY_FOR_FINAID                 => l_appl_inst_rec.APPLY_FOR_FINAID,
                                          X_FINAID_APPLY_DATE                => l_appl_inst_rec.FINAID_APPLY_DATE,
                                          X_ADM_OUTCOME_STATUS               => IGS_AD_GEN_009.ADMP_GET_SYS_AOS('CANCELLED'),
                                          X_ADM_OTCM_STAT_AUTH_PER_ID        => l_appl_inst_rec.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                          X_ADM_OUTCOME_STATUS_AUTH_DT       => l_appl_inst_rec.ADM_OUTCOME_STATUS_AUTH_DT,
                                          X_ADM_OUTCOME_STATUS_REASON        => l_appl_inst_rec.ADM_OUTCOME_STATUS_REASON,
                                          X_OFFER_DT                         => l_appl_inst_rec.OFFER_DT,
                                          X_OFFER_RESPONSE_DT                => l_appl_inst_rec.OFFER_RESPONSE_DT,
                                          X_PRPSD_COMMENCEMENT_DT            => l_appl_inst_rec.PRPSD_COMMENCEMENT_DT,
                                          X_ADM_CNDTNL_OFFER_STATUS          => l_appl_inst_rec.ADM_CNDTNL_OFFER_STATUS,
                                          X_CNDTNL_OFFER_SATISFIED_DT        => l_appl_inst_rec.CNDTNL_OFFER_SATISFIED_DT,
                                          X_CNDNL_OFR_MUST_BE_STSFD_IND      => l_appl_inst_rec.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                          X_ADM_OFFER_RESP_STATUS            => l_appl_inst_rec.ADM_OFFER_RESP_STATUS,
                                          X_ACTUAL_RESPONSE_DT               => l_appl_inst_rec.ACTUAL_RESPONSE_DT,
                                          X_ADM_OFFER_DFRMNT_STATUS          => l_appl_inst_rec.ADM_OFFER_DFRMNT_STATUS,
                                          X_DEFERRED_ADM_CAL_TYPE            => l_appl_inst_rec.DEFERRED_ADM_CAL_TYPE,
                                          X_DEFERRED_ADM_CI_SEQUENCE_NUM     => l_appl_inst_rec.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                          X_DEFERRED_TRACKING_ID             => l_appl_inst_rec.DEFERRED_TRACKING_ID,
                                          X_ASS_RANK                         => l_appl_inst_rec.ASS_RANK,
                                          X_SECONDARY_ASS_RANK               => l_appl_inst_rec.SECONDARY_ASS_RANK,
                                          X_INTR_ACCEPT_ADVICE_NUM           => l_appl_inst_rec.intrntnl_acceptance_advice_num,
                                          X_ASS_TRACKING_ID                  => l_appl_inst_rec.ASS_TRACKING_ID,
                                          X_FEE_CAT                          => l_appl_inst_rec.FEE_CAT,
                                          X_HECS_PAYMENT_OPTION              => l_appl_inst_rec.HECS_PAYMENT_OPTION,
                                          X_EXPECTED_COMPLETION_YR           => l_appl_inst_rec.EXPECTED_COMPLETION_YR,
                                          X_EXPECTED_COMPLETION_PERD         => l_appl_inst_rec.EXPECTED_COMPLETION_PERD,
                                          X_CORRESPONDENCE_CAT               => l_appl_inst_rec.CORRESPONDENCE_CAT,
                                          X_ENROLMENT_CAT                    => l_appl_inst_rec.ENROLMENT_CAT,
                                          X_FUNDING_SOURCE                   => l_appl_inst_rec.FUNDING_SOURCE,
                                          X_APPLICANT_ACPTNCE_CNDTN          => l_appl_inst_rec.APPLICANT_ACPTNCE_CNDTN,
                                          X_CNDTNL_OFFER_CNDTN               => l_appl_inst_rec.CNDTNL_OFFER_CNDTN,
                                          X_MODE                             => 'R',
                                          X_SS_APPLICATION_ID                => l_appl_inst_rec.SS_APPLICATION_ID,
                                          X_SS_PWD                           => l_appl_inst_rec.SS_PWD,
                                          X_AUTHORIZED_DT                    => l_appl_inst_rec.AUTHORIZED_DT,
                                          X_AUTHORIZING_PERS_ID              => l_appl_inst_rec.AUTHORIZING_PERS_ID,
                                          X_ENTRY_STATUS                     => l_appl_inst_rec.ENTRY_STATUS,
                                          X_ENTRY_LEVEL                      => l_appl_inst_rec.ENTRY_LEVEL,
                                          X_SCH_APL_TO_ID                    => l_appl_inst_rec.SCH_APL_TO_ID,
                                          X_IDX_CALC_DATE                    => l_appl_inst_rec.IDX_CALC_DATE,
                                          X_WAITLIST_STATUS                  => 'NOT-APPLIC',
                                          X_ATTRIBUTE21                      => l_appl_inst_rec.ATTRIBUTE21,
                                          X_ATTRIBUTE22                      => l_appl_inst_rec.ATTRIBUTE22,
                                          X_ATTRIBUTE23                      => l_appl_inst_rec.ATTRIBUTE23,
                                          X_ATTRIBUTE24                      => l_appl_inst_rec.ATTRIBUTE24,
                                          X_ATTRIBUTE25                      => l_appl_inst_rec.ATTRIBUTE25,
                                          X_ATTRIBUTE26                      => l_appl_inst_rec.ATTRIBUTE26,
                                          X_ATTRIBUTE27                      => l_appl_inst_rec.ATTRIBUTE27,
                                          X_ATTRIBUTE28                      => l_appl_inst_rec.ATTRIBUTE28,
                                          X_ATTRIBUTE29                      => l_appl_inst_rec.ATTRIBUTE29,
                                          X_ATTRIBUTE30                      => l_appl_inst_rec.ATTRIBUTE30,
                                          X_ATTRIBUTE31                      => l_appl_inst_rec.ATTRIBUTE31,
                                          X_ATTRIBUTE32                      => l_appl_inst_rec.ATTRIBUTE32,
                                          X_ATTRIBUTE33                      => l_appl_inst_rec.ATTRIBUTE33,
                                          X_ATTRIBUTE34                      => l_appl_inst_rec.ATTRIBUTE34,
                                          X_ATTRIBUTE35                      => l_appl_inst_rec.ATTRIBUTE35,
                                          X_ATTRIBUTE36                      => l_appl_inst_rec.ATTRIBUTE36,
                                          X_ATTRIBUTE37                      => l_appl_inst_rec.ATTRIBUTE37,
                                          X_ATTRIBUTE38                      => l_appl_inst_rec.ATTRIBUTE38,
                                          X_ATTRIBUTE39                      => l_appl_inst_rec.ATTRIBUTE39,
                                          X_ATTRIBUTE40                      => l_appl_inst_rec.ATTRIBUTE40,
                                          X_FUT_ACAD_CAL_TYPE                => l_appl_inst_rec.FUTURE_ACAD_CAL_TYPE,
                                          X_FUT_ACAD_CI_SEQUENCE_NUMBER      => l_appl_inst_rec.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
                                          X_FUT_ADM_CAL_TYPE                 => l_appl_inst_rec.FUTURE_ADM_CAL_TYPE,
                                          X_FUT_ADM_CI_SEQUENCE_NUMBER       => l_appl_inst_rec.FUTURE_ADM_CI_SEQUENCE_NUMBER,
                                          X_PREV_TERM_ADM_APPL_NUMBER        => l_appl_inst_rec.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                          X_PREV_TERM_SEQUENCE_NUMBER        => l_appl_inst_rec.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                          X_FUT_TERM_ADM_APPL_NUMBER         => l_new_admission_appl_number,
                                          X_FUT_TERM_SEQUENCE_NUMBER         => l_sequence_number,
                                          X_DEF_ACAD_CAL_TYPE                => l_appl_inst_rec.DEF_ACAD_CAL_TYPE,
                                          X_DEF_ACAD_CI_SEQUENCE_NUM         => l_appl_inst_rec.DEF_ACAD_CI_SEQUENCE_NUM,
                                          X_DEF_PREV_TERM_ADM_APPL_NUM       => l_appl_inst_rec.DEF_PREV_TERM_ADM_APPL_NUM,
                                          X_DEF_PREV_APPL_SEQUENCE_NUM       => l_appl_inst_rec.DEF_PREV_APPL_SEQUENCE_NUM,
                                          X_DEF_TERM_ADM_APPL_NUM            => l_appl_inst_rec.DEF_TERM_ADM_APPL_NUM,
                                          X_DEF_APPL_SEQUENCE_NUM            => l_appl_inst_rec.DEF_APPL_SEQUENCE_NUM,
                                          X_APPL_INST_STATUS                 => l_appl_inst_rec.APPL_INST_STATUS,
                                          X_AIS_REASON                       => l_appl_inst_rec.AIS_REASON,
                                          X_DECLINE_OFR_REASON               => l_appl_inst_rec.DECLINE_OFR_REASON
                                          );

                         /* Update the new application instance PREVIOUS_TERM_ADM_APPL_NUMBER and PREVIOUS_TERM_SEQUENCE_NUMBER columns to link
                          it with the old application */

	                 OPEN c_get_appl_instance (l_appl_inst_rec.person_id, l_new_admission_appl_number,
	                                           l_appl_inst_rec.nominated_course_cd, l_sequence_number);
                         FETCH c_get_appl_instance INTO l_get_appl_instance;
                         CLOSE c_get_appl_instance;

                         /* Update the new application instance PREVIOUS_TERM_ADM_APPL_NUMBER and
		            PREVIOUS_TERM_SEQUENCE_NUMBER columns to link it with the old application */


                         igs_ad_ps_appl_inst_pkg.UPDATE_ROW (
                                           X_ROWID                            => l_get_appl_instance.ROWID,
                                           X_PERSON_ID                        => l_get_appl_instance.PERSON_ID,
                                           X_ADMISSION_APPL_NUMBER            => l_get_appl_instance.ADMISSION_APPL_NUMBER,
                                           X_NOMINATED_COURSE_CD              => l_get_appl_instance.NOMINATED_COURSE_CD,
                                           X_SEQUENCE_NUMBER                  => l_get_appl_instance.SEQUENCE_NUMBER,
                                           X_PREDICTED_GPA                    => l_get_appl_instance.PREDICTED_GPA,
                                           X_ACADEMIC_INDEX                   => l_get_appl_instance.ACADEMIC_INDEX,
                                           X_ADM_CAL_TYPE                     => l_get_appl_instance.ADM_CAL_TYPE,
                                           X_APP_FILE_LOCATION                => l_get_appl_instance.APP_FILE_LOCATION,
                                           X_ADM_CI_SEQUENCE_NUMBER           => l_get_appl_instance.ADM_CI_SEQUENCE_NUMBER,
                                           X_COURSE_CD                        => l_get_appl_instance.COURSE_CD,
                                           X_APP_SOURCE_ID                    => l_get_appl_instance.APP_SOURCE_ID,
                                           X_CRV_VERSION_NUMBER               => l_get_appl_instance.CRV_VERSION_NUMBER,
                                           X_WAITLIST_RANK                    => l_get_appl_instance.WAITLIST_RANK,
                                           X_LOCATION_CD                      => l_get_appl_instance.LOCATION_CD,
                                           X_ATTENT_OTHER_INST_CD             => l_get_appl_instance.ATTENT_OTHER_INST_CD,
                                           X_ATTENDANCE_MODE                  => l_get_appl_instance.ATTENDANCE_MODE,
                                           X_EDU_GOAL_PRIOR_ENROLL_ID         => l_get_appl_instance.EDU_GOAL_PRIOR_ENROLL_ID,
                                           X_ATTENDANCE_TYPE                  => l_get_appl_instance.ATTENDANCE_TYPE,
                                           X_DECISION_MAKE_ID                 => l_get_appl_instance.DECISION_MAKE_ID,
                                           X_UNIT_SET_CD                      => l_get_appl_instance.UNIT_SET_CD,
                                           X_DECISION_DATE                    => l_get_appl_instance.DECISION_DATE,
                                           X_ATTRIBUTE_CATEGORY               => l_get_appl_instance.ATTRIBUTE_CATEGORY,
                                           X_ATTRIBUTE1                       => l_get_appl_instance.ATTRIBUTE1,
                                           X_ATTRIBUTE2                       => l_get_appl_instance.ATTRIBUTE2,
                                           X_ATTRIBUTE3                       => l_get_appl_instance.ATTRIBUTE3,
                                           X_ATTRIBUTE4                       => l_get_appl_instance.ATTRIBUTE4,
                                           X_ATTRIBUTE5                       => l_get_appl_instance.ATTRIBUTE5,
                                           X_ATTRIBUTE6                       => l_get_appl_instance.ATTRIBUTE6,
                                           X_ATTRIBUTE7                       => l_get_appl_instance.ATTRIBUTE7,
                                           X_ATTRIBUTE8                       => l_get_appl_instance.ATTRIBUTE8,
                                           X_ATTRIBUTE9                       => l_get_appl_instance.ATTRIBUTE9,
                                           X_ATTRIBUTE10                      => l_get_appl_instance.ATTRIBUTE10,
                                           X_ATTRIBUTE11                      => l_get_appl_instance.ATTRIBUTE11,
                                           X_ATTRIBUTE12                      => l_get_appl_instance.ATTRIBUTE12,
                                           X_ATTRIBUTE13                      => l_get_appl_instance.ATTRIBUTE13,
                                           X_ATTRIBUTE14                      => l_get_appl_instance.ATTRIBUTE14,
                                           X_ATTRIBUTE15                      => l_get_appl_instance.ATTRIBUTE15,
                                           X_ATTRIBUTE16                      => l_get_appl_instance.ATTRIBUTE16,
                                           X_ATTRIBUTE17                      => l_get_appl_instance.ATTRIBUTE17,
                                           X_ATTRIBUTE18                      => l_get_appl_instance.ATTRIBUTE18,
                                           X_ATTRIBUTE19                      => l_get_appl_instance.ATTRIBUTE19,
                                           X_ATTRIBUTE20                      => l_get_appl_instance.ATTRIBUTE20,
                                           X_DECISION_REASON_ID               => l_get_appl_instance.DECISION_REASON_ID,
                                           X_US_VERSION_NUMBER                => l_get_appl_instance.US_VERSION_NUMBER,
                                           X_DECISION_NOTES                   => l_get_appl_instance.DECISION_NOTES,
                                           X_PENDING_REASON_ID                => l_get_appl_instance.PENDING_REASON_ID,
                                           X_PREFERENCE_NUMBER                => l_get_appl_instance.PREFERENCE_NUMBER,
                                           X_ADM_DOC_STATUS                   => l_get_appl_instance.ADM_DOC_STATUS,
                                           X_ADM_ENTRY_QUAL_STATUS            => l_get_appl_instance.ADM_ENTRY_QUAL_STATUS,
                                           X_DEFICIENCY_IN_PREP               => l_get_appl_instance.DEFICIENCY_IN_PREP,
                                           X_LATE_ADM_FEE_STATUS              => l_get_appl_instance.LATE_ADM_FEE_STATUS,
                                           X_SPL_CONSIDER_COMMENTS            => l_get_appl_instance.SPL_CONSIDER_COMMENTS,
                                           X_APPLY_FOR_FINAID                 => l_get_appl_instance.APPLY_FOR_FINAID,
                                           X_FINAID_APPLY_DATE                => l_get_appl_instance.FINAID_APPLY_DATE,
                                           X_ADM_OUTCOME_STATUS               => l_get_appl_instance.ADM_OUTCOME_STATUS,
                                           X_ADM_OTCM_STAT_AUTH_PER_ID        => l_get_appl_instance.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                           X_ADM_OUTCOME_STATUS_AUTH_DT       => l_get_appl_instance.ADM_OUTCOME_STATUS_AUTH_DT,
                                           X_ADM_OUTCOME_STATUS_REASON        => l_get_appl_instance.ADM_OUTCOME_STATUS_REASON,
                                           X_OFFER_DT                         => l_get_appl_instance.OFFER_DT,
                                           X_OFFER_RESPONSE_DT                => l_get_appl_instance.OFFER_RESPONSE_DT,
                                           X_PRPSD_COMMENCEMENT_DT            => l_get_appl_instance.PRPSD_COMMENCEMENT_DT,
                                           X_ADM_CNDTNL_OFFER_STATUS          => l_get_appl_instance.ADM_CNDTNL_OFFER_STATUS,
                                           X_CNDTNL_OFFER_SATISFIED_DT        => l_get_appl_instance.CNDTNL_OFFER_SATISFIED_DT,
                                           X_CNDNL_OFR_MUST_BE_STSFD_IND      => l_get_appl_instance.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                           X_ADM_OFFER_RESP_STATUS            => l_get_appl_instance.ADM_OFFER_RESP_STATUS,
                                           X_ACTUAL_RESPONSE_DT               => l_get_appl_instance.ACTUAL_RESPONSE_DT,
                                           X_ADM_OFFER_DFRMNT_STATUS          => l_get_appl_instance.ADM_OFFER_DFRMNT_STATUS,
                                           X_DEFERRED_ADM_CAL_TYPE            => l_get_appl_instance.DEFERRED_ADM_CAL_TYPE,
                                           X_DEFERRED_ADM_CI_SEQUENCE_NUM     => l_get_appl_instance.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                           X_DEFERRED_TRACKING_ID             => l_get_appl_instance.DEFERRED_TRACKING_ID,
                                           X_ASS_RANK                         => l_get_appl_instance.ASS_RANK,
                                           X_SECONDARY_ASS_RANK               => l_get_appl_instance.SECONDARY_ASS_RANK,
                                           X_INTR_ACCEPT_ADVICE_NUM           => l_get_appl_instance.intrntnl_acceptance_advice_num,
                                           X_ASS_TRACKING_ID                  => l_get_appl_instance.ASS_TRACKING_ID,
                                           X_FEE_CAT                          => l_get_appl_instance.FEE_CAT,
                                           X_HECS_PAYMENT_OPTION              => l_get_appl_instance.HECS_PAYMENT_OPTION,
                                           X_EXPECTED_COMPLETION_YR           => l_get_appl_instance.EXPECTED_COMPLETION_YR,
                                           X_EXPECTED_COMPLETION_PERD         => l_get_appl_instance.EXPECTED_COMPLETION_PERD,
                                           X_CORRESPONDENCE_CAT               => l_get_appl_instance.CORRESPONDENCE_CAT,
                                           X_ENROLMENT_CAT                    => l_get_appl_instance.ENROLMENT_CAT,
                                           X_FUNDING_SOURCE                   => l_get_appl_instance.FUNDING_SOURCE,
                                           X_APPLICANT_ACPTNCE_CNDTN          => l_get_appl_instance.APPLICANT_ACPTNCE_CNDTN,
                                           X_CNDTNL_OFFER_CNDTN               => l_get_appl_instance.CNDTNL_OFFER_CNDTN,
                                           X_MODE                             => 'R',
                                           X_SS_APPLICATION_ID                => l_get_appl_instance.SS_APPLICATION_ID,
                                           X_SS_PWD                           => l_get_appl_instance.SS_PWD,
                                           X_AUTHORIZED_DT                    => l_get_appl_instance.AUTHORIZED_DT,
                                           X_AUTHORIZING_PERS_ID              => l_get_appl_instance.AUTHORIZING_PERS_ID,
                                           X_ENTRY_STATUS                     => l_get_appl_instance.ENTRY_STATUS,
                                           X_ENTRY_LEVEL                      => l_get_appl_instance.ENTRY_LEVEL,
                                           X_SCH_APL_TO_ID                    => l_get_appl_instance.SCH_APL_TO_ID,
                                           X_IDX_CALC_DATE                    => l_get_appl_instance.IDX_CALC_DATE,
                                           X_WAITLIST_STATUS                  => l_get_appl_instance.WAITLIST_STATUS,
                                           X_ATTRIBUTE21                      => l_get_appl_instance.ATTRIBUTE21,
                                           X_ATTRIBUTE22                      => l_get_appl_instance.ATTRIBUTE22,
                                           X_ATTRIBUTE23                      => l_get_appl_instance.ATTRIBUTE23,
                                           X_ATTRIBUTE24                      => l_get_appl_instance.ATTRIBUTE24,
                                           X_ATTRIBUTE25                      => l_get_appl_instance.ATTRIBUTE25,
                                           X_ATTRIBUTE26                      => l_get_appl_instance.ATTRIBUTE26,
                                           X_ATTRIBUTE27                      => l_get_appl_instance.ATTRIBUTE27,
                                           X_ATTRIBUTE28                      => l_get_appl_instance.ATTRIBUTE28,
                                           X_ATTRIBUTE29                      => l_get_appl_instance.ATTRIBUTE29,
                                           X_ATTRIBUTE30                      => l_get_appl_instance.ATTRIBUTE30,
                                           X_ATTRIBUTE31                      => l_get_appl_instance.ATTRIBUTE31,
                                           X_ATTRIBUTE32                      => l_get_appl_instance.ATTRIBUTE32,
                                           X_ATTRIBUTE33                      => l_get_appl_instance.ATTRIBUTE33,
                                           X_ATTRIBUTE34                      => l_get_appl_instance.ATTRIBUTE34,
                                           X_ATTRIBUTE35                      => l_get_appl_instance.ATTRIBUTE35,
                                           X_ATTRIBUTE36                      => l_get_appl_instance.ATTRIBUTE36,
                                           X_ATTRIBUTE37                      => l_get_appl_instance.ATTRIBUTE37,
                                           X_ATTRIBUTE38                      => l_get_appl_instance.ATTRIBUTE38,
                                           X_ATTRIBUTE39                      => l_get_appl_instance.ATTRIBUTE39,
                                           X_ATTRIBUTE40                      => l_get_appl_instance.ATTRIBUTE40,
                                           X_FUT_ACAD_CAL_TYPE                => l_get_appl_instance.FUTURE_ACAD_CAL_TYPE,
                                           X_FUT_ACAD_CI_SEQUENCE_NUMBER      => l_get_appl_instance.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
                                           X_FUT_ADM_CAL_TYPE                 => l_get_appl_instance.FUTURE_ADM_CAL_TYPE,
                                           X_FUT_ADM_CI_SEQUENCE_NUMBER       => l_get_appl_instance.FUTURE_ADM_CI_SEQUENCE_NUMBER,
                                           X_PREV_TERM_ADM_APPL_NUMBER        => l_appl_inst_rec.ADMISSION_APPL_NUMBER,
                                           X_PREV_TERM_SEQUENCE_NUMBER        => l_appl_inst_rec.SEQUENCE_NUMBER,
                                           X_FUT_TERM_ADM_APPL_NUMBER         => l_get_appl_instance.FUTURE_TERM_ADM_APPL_NUMBER,
                                           X_FUT_TERM_SEQUENCE_NUMBER         => l_get_appl_instance.FUTURE_TERM_SEQUENCE_NUMBER,
                                           X_DEF_ACAD_CAL_TYPE                => l_get_appl_instance.DEF_ACAD_CAL_TYPE,
                                           X_DEF_ACAD_CI_SEQUENCE_NUM         => l_get_appl_instance.DEF_ACAD_CI_SEQUENCE_NUM,
                                           X_DEF_PREV_TERM_ADM_APPL_NUM       => l_get_appl_instance.DEF_PREV_TERM_ADM_APPL_NUM,
                                           X_DEF_PREV_APPL_SEQUENCE_NUM       => l_get_appl_instance.DEF_PREV_APPL_SEQUENCE_NUM,
                                           X_DEF_TERM_ADM_APPL_NUM            => l_get_appl_instance.DEF_TERM_ADM_APPL_NUM,
                                           X_DEF_APPL_SEQUENCE_NUM            => l_get_appl_instance.DEF_APPL_SEQUENCE_NUM,
                                           X_APPL_INST_STATUS                 => l_get_appl_instance.APPL_INST_STATUS,
                                           X_AIS_REASON                       => l_get_appl_instance.AIS_REASON,
                                           X_DECLINE_OFR_REASON               => l_get_appl_instance.DECLINE_OFR_REASON
                                           );

		         l_successful_records := l_successful_records + 1;

                         COMMIT;
		       END IF;

                   ELSE  -- Else of Application Instance

		       fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                         RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                         RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

			IF (l_message_name IS NULL) THEN
			  igs_ad_gen_016.extract_msg_from_stack (
                             p_msg_at_index                => l_msg_at_index,
                             p_return_status               => l_return_status,
                             p_msg_count                   => l_msg_count,
                             p_msg_data                    => l_msg_data,
                             p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

			  IF (l_msg_count > 0) THEN
                            fnd_file.put_line(fnd_file.log, l_msg_data);
                          ELSE
			    FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed while creating application instance of the new program');
                          END IF;
                        ELSE
			  fnd_file.put_line(fnd_file.log, l_message_name);
			END IF;
                       l_failed_records := l_failed_records + 1;

                       ROLLBACK TO c_create_application;
                   END IF;
		EXCEPTION
		         WHEN OTHERS THEN

                               fnd_file.put_line(fnd_file.log, 'Application Instance Creation Failed for Person ID: '|| RPAD(l_appl_inst_rec.person_id,15,' ') || '; Admission Application Number: ' ||
		                                 RPAD(l_appl_inst_rec.admission_appl_number,2,' ') || '; Course Code: ' || RPAD(l_appl_inst_rec.nominated_course_cd,6,' ') || '; Sequence Number: '||
                                                 RPAD(l_appl_inst_rec.sequence_number,6,' ') || ' Reason: ');

                               IF l_message_name  IN ('IGS_AD_NOMINATE_PRG_OFR_ENTRY', 'IGS_AD_NOMINATED_PRG_ENTRYPNT') THEN
                                  l_message_name := 'IGS_AD_CAL_PGM_NOT_OFFER';
                                  fnd_message.set_name('IGS', l_message_name);
                                  fnd_message.set_token('PGM', l_appl_inst_rec.nominated_course_cd);
                                  fnd_message.set_token('ALTCODE',l_appl_inst_rec.future_acad_cal_type||','||
				                        IGS_GE_NUMBER.TO_CANN(l_appl_inst_rec.future_acad_ci_sequence_number)
                                                        ||'/'||l_appl_inst_rec.future_adm_cal_type||','||
						        IGS_GE_NUMBER.TO_CANN(l_appl_inst_rec.future_adm_ci_sequence_number));
                                  fnd_file.put_line(fnd_file.log, fnd_message.get);
                               ELSE
                                  fnd_message.set_name('IGS', l_message_name);
                                  fnd_file.put_line(fnd_file.log, fnd_message.get);

                               END IF;
			       ROLLBACK TO c_create_application;
                END;

         END IF;

  END LOOP;

END IF;

fnd_file.put_line(fnd_file.log,'Total Number of Records Processed:   ' || l_total_records);
fnd_file.put_line(fnd_file.log,'Total Number of Successful Records:  ' || l_successful_records);
fnd_file.put_line(fnd_file.log,'Total Number of Unsucessful Records: ' || l_failed_records);

EXCEPTION WHEN OTHERS THEN

    fnd_file.put_line(fnd_file.log, 'Exception From handle application log ' ||   l_message_name);
    retcode:=2;

END admp_init_reconsider;

END igs_ad_int_reconsider;

/
