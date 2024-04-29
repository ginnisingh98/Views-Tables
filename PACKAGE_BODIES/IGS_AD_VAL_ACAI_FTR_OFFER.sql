--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_ACAI_FTR_OFFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_ACAI_FTR_OFFER" AS
/* $Header: IGSADB5B.pls 120.15 2006/05/29 12:07:07 apadegal ship $ */
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
ravishar      5-Sep-2005        Bug:- 4506750 added two new parametrs to Future term job and
                                added to code to copy qualifying code details to new application
pathipat        17-Jun-2003     Enh 2831587 - FI210 Credit Card Fund Transfer build
                                Modified TBH call to igs_ad_app_req_pkg to include 3 new columns
 rrengara  3-DEC-2002   Fix for the Bug 2631918
 vvutukur  27-Nov-2002  Enh#2584986.GL Interface Build.Modifications done in function copy_child_records.
 nshee     29-Aug-2002  Bug 2395510 added 6 columns as part of deferments build
 RRENGARA  13-SEP-2002  Bug 2395510 added p_process parameter to call copy child records
 rghosh     15-may-2003   Bug#2871426(Evaluator Entry and Assignment) Added the closed ind check  in the cursor  c_evaluators_cur
                                               and in the call to insert row of igs_ad_appl_eval_pkg
*******************************************************************************/

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


PROCEDURE admp_val_offer_future_term(
                                        errbuf out NOCOPY varchar2,
                                        retcode out NOCOPY number ,
                                        p_person_id hz_parties.party_id%TYPE,
                                        p_group_id igs_pe_persid_group.group_id%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_prev_acad_adm_cal  VARCHAR2,
                                        p_future_acad_adm_cal VARCHAR2,
                                        p_offer_dt   VARCHAR2,
                                        p_offer_response_dt VARCHAR2,
					p_application_type VARCHAR2 DEFAULT NULL,
					p_application_id NUMBER DEFAULT NULL
                                     )  IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
********************************************************************************
ravishar     5-Sep-2005        Added two new parameters p_application_type,
                               p_application_id to the Procedure
*/

 -- Variable Declarations ----------------------------------------------------------------------------------------------------

 -- Resolve the parameters to get calendar types and sequence numbers
  p_prev_acad_cal_type          igs_ad_appl.acad_cal_type%TYPE;
  p_prev_acad_cal_seq_no        igs_ad_appl.acad_ci_sequence_number%TYPE;
  p_prev_adm_cal_type           igs_ad_appl.adm_cal_type%TYPE;
  p_prev_adm_cal_seq_no         igs_ad_appl.adm_ci_sequence_number%TYPE;

  p_fut_acad_cal_type           igs_ad_appl.acad_cal_type%TYPE;
  p_fut_acad_cal_seq_no         igs_ad_appl.acad_ci_sequence_number%TYPE;
  p_fut_adm_cal_type            igs_ad_appl.adm_cal_type%TYPE;
  p_fut_adm_cal_seq_no          igs_ad_appl.adm_ci_sequence_number%TYPE;

  l_offer_dt  igs_ad_ps_appl_inst.offer_dt%TYPE;
  l_offer_response_dt igs_ad_ps_appl_inst.offer_response_dt%TYPE;

  l_message_name VARCHAR2(1000);
  l_new_admission_appl_number igs_ad_appl.admission_appl_number%TYPE;
  l_new_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE;

  l_person_number hz_parties.party_number%TYPE;
  l_group_desc igs_pe_persid_group.description%TYPE;

  ---End Variable Declarations--------------------------------------------------------------------------------------------

  -------------Cursor Declarations ----------------------------------------------------------------------------------------

  CURSOR c_pernum_cur IS
  SELECT
    person_number
  FROM
    igs_pe_person_base_v
  WHERE
    person_id = p_person_id;


  CURSOR c_pergr_cur IS
  SELECT
    description
  FROM
    igs_pe_persid_group
  WHERE
    group_id = p_group_id;

 -- Cursor for getting the alternade academic/admission code for a given academic/admission cal type and sequence number

CURSOR acad_adm_alt_code (
  p_acad_cal_type igs_ca_inst.cal_type%TYPE,
  p_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
  p_adm_cal_type igs_ca_inst.cal_type%TYPE,
  p_adm_ci_sequence_number igs_ca_inst.sequence_number%TYPE
) IS
SELECT c1.alternate_code||' / '||c2.alternate_code
FROM igs_ca_inst c1, igs_ca_inst c2
WHERE c1.cal_type = p_acad_cal_type
AND c1.sequence_number = p_acad_ci_sequence_number
AND c2.cal_type = p_adm_cal_type
AND c2.sequence_number = p_adm_ci_sequence_number;

cur_acad_adm_alt_code VARCHAR2(200);
fut_acad_adm_alt_code VARCHAR2(200);

  -- Cursor to get the current application attributes -----

  CURSOR c_appl_inst(p_person_id hz_parties.party_id%TYPE) IS
  SELECT
     acai.*
  FROM
     igs_ad_appl aa,
     igs_ad_ps_appl_inst acai, /* Replaced igs_ad_ps_appl_inst_aplinst_v with igs_ad_ps_appl_inst Bug 3150054 */
     igs_ad_ou_stat aous
  WHERE
       acai.adm_outcome_status = aous.adm_outcome_status
       AND      aous.s_adm_outcome_status = 'OFFER-FUTURE-TERM'
       AND      acai.future_acad_cal_type = NVL(p_fut_acad_cal_type, acai.future_acad_cal_type)
       AND      acai.future_acad_ci_sequence_number = NVL(p_fut_acad_cal_seq_no, acai.future_acad_ci_sequence_number)
       AND      acai.future_adm_cal_type = NVL(p_fut_adm_cal_type, acai.future_adm_cal_type)
       AND      acai.future_adm_ci_sequence_number = NVL(p_fut_adm_cal_seq_no, acai.future_adm_ci_sequence_number)
       AND      acai.future_term_adm_appl_number IS NULL
       AND      acai.future_term_sequence_number IS NULL
       AND      acai.person_id = p_person_id
       AND      acai.nominated_course_cd = NVL (p_nominated_course_cd, acai.nominated_course_cd)
       AND      aa.person_id = acai.person_id
       AND      aa.admission_appl_number = acai.admission_appl_number
       AND      aa.acad_cal_type = NVL ( p_prev_acad_cal_type, aa.acad_cal_type)
       AND      aa.acad_ci_sequence_number = NVL ( p_prev_acad_cal_seq_no, aa.acad_ci_sequence_number)
       AND      NVL(acai.adm_cal_type,aa.adm_cal_type) = NVL( p_prev_adm_cal_type,  acai.adm_cal_type)
       AND      NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) = NVL ( p_prev_adm_cal_seq_no, acai.adm_ci_sequence_number)
       AND      aa.APPLICATION_TYPE = NVL(p_application_type,aa.APPLICATION_TYPE)
       AND      aa.APPLICATION_ID   = NVL(p_application_id,aa.APPLICATION_ID);

   CURSOR c_group_id(p_person_id  hz_parties.party_id%TYPE,p_group_id igs_pe_persid_group.group_id%TYPE)  IS
        SELECT 'X'
	FROM igs_pe_prsid_grp_mem
	WHERE  person_id = p_person_id
	AND group_id = p_group_id
  AND NVL(TRUNC(start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE)
  AND NVL(TRUNC(end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);

  l_exists VARCHAR2(1);
  l_pers_grp VARCHAR2(1);

CURSOR c_get_acad_cal_info(cp_person_id igs_ad_appl_all.person_id%TYPE,
                           cp_admission_appl_number igs_ad_appl_all.admission_appl_number%TYPE) IS
  SELECT acad_cal_type,acad_ci_sequence_number
  FROM igs_ad_appl_all
  WHERE person_id = cp_person_id
  AND admission_appl_number = cp_admission_appl_number;

l_get_acad_cal_info c_get_acad_cal_info%ROWTYPE;

v_start_dt DATE;
l_applcreated_flag BOOLEAN;

-- pfotedar bug no. 3713735
l_query VARCHAR2(1000);
TYPE c_ref_cur_typ IS REF CURSOR;
c_ref_cur c_ref_cur_typ;

TYPE c_ref_cur_rec_typ IS RECORD (person_id NUMBER);
    c_ref_cur_rec c_ref_cur_rec_typ;

-- for bug 5245277 and sql id 17651699 and 17651677
 l_status VARCHAR2(1);
 l_group_type IGS_PE_PERSID_GROUP_V.group_type%type;

  -- End cursor declarations -----------------------------------------------------------------------------------------------
BEGIN

  -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
  igs_ge_gen_003.set_org_id(null);

  p_prev_acad_cal_type     :=   rtrim (substr (p_prev_acad_adm_cal, 1,10));
  p_prev_acad_cal_seq_no   :=   IGS_GE_NUMBER.TO_NUM(substr(p_prev_acad_adm_cal, 13,7));
  p_prev_adm_cal_type      :=   rtrim (substr (p_prev_acad_adm_cal, 23,10));
  p_prev_adm_cal_seq_no    :=   IGS_GE_NUMBER.TO_NUM (substr (p_prev_acad_adm_cal, 35,7));

  p_fut_acad_cal_type      :=   rtrim (substr (p_future_acad_adm_cal, 1,10));
  p_fut_acad_cal_seq_no    :=   IGS_GE_NUMBER.TO_NUM (substr (p_future_acad_adm_cal, 13,7));
  p_fut_adm_cal_type       :=   rtrim (substr (p_future_acad_adm_cal, 23,10));
  p_fut_adm_cal_seq_no     :=   IGS_GE_NUMBER.TO_NUM(substr (p_future_acad_adm_cal, 35,7));

  -- Added the Log file entries for the passed parameters
  -- By rrengara for Bug 2690354 on 19-DEC-2002

  OPEN c_pernum_cur;
  FETCH c_pernum_cur INTO l_person_number;
  CLOSE c_pernum_cur;

  OPEN c_pergr_cur;
  FETCH c_pergr_cur INTO l_group_desc;
  CLOSE c_pergr_cur;

  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Person Number',38) || ' : ' || l_person_number);
  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Person ID Group' ,38) || ' : ' || l_group_desc);
  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Program',38) || ' : ' || p_nominated_course_cd);

  IF p_prev_acad_adm_cal IS NOT NULL THEN
    OPEN acad_adm_alt_code( p_prev_acad_cal_type,
                                                             p_prev_acad_cal_seq_no,
							     p_prev_adm_cal_type,
							     p_prev_adm_cal_seq_no);
    FETCH acad_adm_alt_code INTO cur_acad_adm_alt_code;
    CLOSE acad_adm_alt_code;
  END IF;

  IF p_future_acad_adm_cal IS NOT NULL THEN
    OPEN acad_adm_alt_code(p_fut_acad_cal_type,
                                                            p_fut_acad_cal_seq_no,
							    p_fut_adm_cal_type,
							    p_fut_adm_cal_seq_no);
    FETCH acad_adm_alt_code INTO fut_acad_adm_alt_code;
    CLOSE acad_adm_alt_code;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Current Academic / Admission Calendar',38) || ' : ' || cur_acad_adm_alt_code );
  FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Future Academic / Admission Calendar',38) || ' : ' || fut_acad_adm_alt_code );


 l_offer_dt := igs_ge_date.igsdate(p_offer_dt);
 l_offer_response_dt := igs_ge_date.igsdate(p_offer_response_dt);

 FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Offer Date',38) || ' : ' || l_offer_dt);
 FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('Override Offer Response Date',38) || ' : ' || l_offer_response_dt);
 FND_FILE.PUT_LINE(FND_FILE.LOG,'');

  -- check whether the parameter combination passed is correct
  -- if user  gives both person group and person
 -- then it should check whether the person exists in that group
 -- if the person doesnot exists, it gives a message --rghosh bug#2767294

  IF (p_group_id IS NULL AND p_person_id IS NULL AND p_application_id IS NULL)THEN
    fnd_file.put_line(fnd_file.log, 'Application could not be created');
    fnd_file.put_line(fnd_file.log, 'Either Person Number or Person ID Group or Application ID should be passed');
  ELSIF (p_group_id IS NOT NULL AND p_person_id IS NOT NULL) THEN
    OPEN c_group_id(p_person_id,p_group_id);
    FETCH c_group_id INTO l_exists;
    IF c_group_id%NOTFOUND THEN
      fnd_file.put_line(fnd_file.log, 'Application could not be created');
      fnd_file.put_line(fnd_file.log, 'Person does not exists in the Person ID Group');
    END IF;
    CLOSE c_group_id;
  END IF;

  -- If the user wants to do the process for list of persons
  -- use the record group he has given in the parameter and iterate on the list
  -- of persons in the group
l_applcreated_flag := TRUE;

IF p_group_id IS NOT NULL THEN

    ---- begin through bug 5245277 for sql ids 17651699, 17651677
    l_query := IGS_PE_DYNAMIC_PERSID_GROUP.GET_DYNAMIC_SQL(p_group_id, l_status, l_group_type);

    IF (l_query IS NOT NULL AND l_status ='S')
    THEN
    ---- end  through bug 5245277 for sql ids 17651699, 17651677
	    IF p_person_id IS NOT NULL THEN     --When p_group_id is not null and p_person_id is not null

	        l_query :=  l_query || ' and person_id = :2';  --bug 5245277 and sql id 17651699,  17651677
		OPEN c_ref_cur FOR l_query USING p_group_id, p_person_id;

	    ELSE        --When p_group_id is not null and p_person_id is null
		OPEN c_ref_cur FOR l_query USING p_group_id;
	    END IF;
	    LOOP
	      FETCH c_ref_cur INTO c_ref_cur_rec;
	      EXIT WHEN c_ref_cur%NOTFOUND;
		  -- Find out NOCOPY the list applications
		  FOR c_appl_inst_rec IN c_appl_inst(c_ref_cur_rec.person_id) LOOP
		  l_applcreated_flag := FALSE;

		  -- UPDATE the log file with application details
		  fnd_file.put_line(fnd_file.log, 'Creating Future Term Application for ' );
		  fnd_file.put_line(fnd_file.log,RPAD( ' Person Id',29) || ' : ' || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.person_id));
		  fnd_file.put_line(fnd_file.log, RPAD(' Admission Application Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.admission_appl_number));
		  fnd_file.put_line(fnd_file.log, RPAD(' Nominated course Code',29) || ' : '  || c_appl_inst_rec.nominated_course_cd);
		  fnd_file.put_line(fnd_file.log,RPAD(' Sequence Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN( c_appl_inst_rec.sequence_number ));

		  -- Set the save point here
		  -- Since when the application related transaction fails we need to rollback the transaction for that application
		  -- and it should proceed to the next record in the cursor

		  SAVEPOINT sp_save_point1;

		  -- Call handle application
		  -- this procedure returns true if the application, application program and application instance insert is success
		  -- otherwise it returns FALSE.  This procedure also inserts the new application and instances for the future term
		  -- if the new application is created it returns the new admission application number and new sequence number as an
		  -- out NOCOPY parameter. This variables will be used for copying the child related records from the old to the new application

		  IF handle_application(
		     p_person_id                => c_ref_cur_rec.person_id,
		     p_admission_appl_number    => c_appl_inst_rec.admission_appl_number,
		     p_nominated_course_cd      => c_appl_inst_rec.nominated_course_cd,
		     p_sequence_number          => c_appl_inst_rec.sequence_number,
		     p_fut_acad_cal_type        => c_appl_inst_rec.future_acad_cal_type ,
		     p_fut_acad_cal_seq_no      => c_appl_inst_rec.future_acad_ci_sequence_number,
		     p_fut_adm_cal_type         => c_appl_inst_rec.future_adm_cal_type,
		     p_fut_adm_cal_seq_no       => c_appl_inst_rec.future_adm_ci_sequence_number,
		     p_new_admission_appl_number=> l_new_admission_appl_number,
		     p_new_sequence_number      => l_new_sequence_number) THEN


		  -- if the creation is successful then copy all the child records
		  -- if any error occurs during copying of any of the child record
		  -- rollback upto save point 1 and proceed the next record in the cursor

		  OPEN c_get_acad_cal_info(c_ref_cur_rec.person_id,l_new_admission_appl_number);
		  FETCH c_get_acad_cal_info INTO l_get_acad_cal_info;
		  CLOSE c_get_acad_cal_info;


		  v_start_dt := igs_en_gen_002.enrp_get_acad_comm(
				    l_get_acad_cal_info.acad_cal_type,
				    l_get_acad_cal_info.acad_ci_sequence_number,
				    c_ref_cur_rec.person_id,
				    c_appl_inst_rec.nominated_course_cd,
				    l_new_admission_appl_number,
				    c_appl_inst_rec.nominated_course_cd,
				    l_new_sequence_number,
				    'Y');


		  IF copy_child_records(
		       p_new_admission_appl_number      => l_new_admission_appl_number,
		       p_new_sequence_number            => l_new_sequence_number,
		       p_person_id                      => c_ref_cur_rec.person_id,
		       p_old_admission_appl_number      => c_appl_inst_rec.admission_appl_number,
		       p_old_sequence_number            => c_appl_inst_rec.sequence_number,
		       p_nominated_course_cd            => c_appl_inst_rec.nominated_course_cd,
		       p_start_dt                       => v_start_dt,
			     p_process                        => 'F') THEN
		      -- Added p_process for Deferment changes 2395510
		      -- by rrengara on 12-sep-2002
		      -- reusablity of the same code by both defermetn and future term

		  -- if all the validations and copying is successful then update the entry and doc status from old applicaiton to new future term
		  IF copy_entrycomp_qual_status(p_person_id => c_ref_cur_rec.person_id,
					p_nominated_course_cd => c_appl_inst_rec.nominated_course_cd,
					p_admission_appl_number => c_appl_inst_rec.admission_appl_number,
					p_sequence_number => c_appl_inst_rec.sequence_number,
					p_new_admission_appl_number => l_new_admission_appl_number,
					p_new_sequence_number => l_new_sequence_number ) THEN


			-- do the offer validation and update the out NOCOPY come status to offer
			IF validate_offer_validations(p_person_id       => c_ref_cur_rec.person_id,
					    p_nominated_course_cd       => c_appl_inst_rec.nominated_course_cd,
					    p_admission_appl_number     => l_new_admission_appl_number,
					    p_sequence_number           => l_new_sequence_number,
					    p_old_admission_appl_number => c_appl_inst_rec.admission_appl_number,
					    p_old_sequence_number       => c_appl_inst_rec.sequence_number,
					    p_offer_dt                  => l_offer_dt,
					    p_offer_response_dt         => l_offer_response_dt,
					    p_fut_acad_cal_type         => p_fut_acad_cal_type,
					    p_fut_acad_cal_seq_no       =>  p_fut_acad_cal_seq_no,
					    p_fut_adm_cal_type          => p_fut_adm_cal_type,
					    p_fut_adm_cal_seq_no        => p_fut_adm_cal_seq_no,
					    p_start_dt                  => v_start_dt
					    ) THEN


			    -- Proceed to the next record in the cursor
			    NULL;
			 ELSE
			   ROLLBACK TO sp_save_point1;
			 END IF;
		    ELSE
		      ROLLBACK TO sp_save_point1;
		    END IF;
		  ELSE  -- Else if the child record copy failed
		    ROLLBACK TO sp_save_point1;
		  END IF;  -- End if for Copy Child Records
		ELSE  -- Application Creation Failed
		  ROLLBACK TO sp_save_point1;
		END IF;  -- End if for handle application
	      END LOOP;  -- end loop for loop application instances
	     END LOOP;  -- End loop for Ref cursor
    END IF;

ELSE
    -- This case will come into picture if the user has given only Person Id

    -- Find out NOCOPY the list applications
    FOR c_appl_inst_rec IN c_appl_inst(p_person_id) LOOP

      l_applcreated_flag := FALSE;

      -- Set the save point here
      -- Since when the application related transaction fails we need to rollback the transaction for that application
      -- and it should proceed to the next record in the cursor

      fnd_file.put_line(fnd_file.log, 'Creating Future Term Application for ' );
      fnd_file.put_line(fnd_file.log,RPAD(' Person Id' , 29) || ' : ' || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.person_id));
      fnd_file.put_line(fnd_file.log, RPAD(' Admission Application Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.admission_appl_number));
      fnd_file.put_line(fnd_file.log,RPAD(' Nominated course Code',29) || ' : '  || c_appl_inst_rec.nominated_course_cd);
      fnd_file.put_line(fnd_file.log,RPAD(' Sequence Number',29) || ' : '  || IGS_GE_NUMBER.TO_CANN( c_appl_inst_rec.sequence_number ));

      SAVEPOINT sp_save_point2;

        -- Call handle application
        -- this procedure returns true if the application, application program and application instance insert is success
        -- otherwise it returns FALSE.  This procedure also inserts the new application and instances for the future term
        -- if the new application is created it returns the new admission application number and new sequence number as an
        -- out NOCOPY parameter. This variables will be used for copying the child related records from the old to the new application

      IF handle_application(
                                p_person_id             => p_person_id,
                                p_admission_appl_number => c_appl_inst_rec.admission_appl_number,
                                p_nominated_course_cd   => c_appl_inst_rec.nominated_course_cd,
                                p_sequence_number       => c_appl_inst_rec.sequence_number,
                                p_fut_acad_cal_type     => c_appl_inst_rec.future_acad_cal_type ,
                                p_fut_acad_cal_seq_no   => c_appl_inst_rec.future_acad_ci_sequence_number,
                                p_fut_adm_cal_type      => c_appl_inst_rec.future_adm_cal_type,
                                p_fut_adm_cal_seq_no    => c_appl_inst_rec.future_adm_ci_sequence_number,
                                p_new_admission_appl_number => l_new_admission_appl_number,
                                p_new_sequence_number   => l_new_sequence_number
                                ) THEN

          -- if the creation is successful then copy all the child records
          -- if any error occurs during copying of any of the child record
          -- rollback upto save point 2 and proceed the next record in the cursor

          OPEN c_get_acad_cal_info(p_person_id,l_new_admission_appl_number);
          FETCH c_get_acad_cal_info INTO l_get_acad_cal_info;
          CLOSE c_get_acad_cal_info;


          v_start_dt := igs_en_gen_002.enrp_get_acad_comm(
                            l_get_acad_cal_info.acad_cal_type,
                            l_get_acad_cal_info.acad_ci_sequence_number,
                            p_person_id,
                            c_appl_inst_rec.nominated_course_cd,
                            l_new_admission_appl_number,
                            c_appl_inst_rec.nominated_course_cd,
                            l_new_sequence_number,
                            'Y');


        IF copy_child_records(p_new_admission_appl_number => l_new_admission_appl_number,
                              p_new_sequence_number => l_new_sequence_number,
                              p_person_id => c_appl_inst_rec.person_id,
                              p_old_admission_appl_number => c_appl_inst_rec.admission_appl_number,
                              p_old_sequence_number => c_appl_inst_rec.sequence_number,
                              p_nominated_course_cd => c_appl_inst_rec.nominated_course_cd,
                              p_start_dt => v_start_dt,
			                        p_process => 'F') THEN
	      -- Added p_process for Deferment changes 2395510
	      -- by rrengara on 12-sep-2002
	      -- reusablity of the same code by both defermetn and future term



          -- if all the validations and copying is successful then update the entry and doc status from old applicaiton to new future term
          IF copy_entrycomp_qual_status(p_person_id => c_appl_inst_rec.person_id,
                                p_nominated_course_cd => c_appl_inst_rec.nominated_course_cd,
                                p_admission_appl_number => c_appl_inst_rec.admission_appl_number,
                                p_sequence_number => c_appl_inst_rec.sequence_number,
                                p_new_admission_appl_number => l_new_admission_appl_number,
                                p_new_sequence_number => l_new_sequence_number )  THEN


            -- do the offer validation and update the out NOCOPY come status to offer
            IF validate_offer_validations(p_person_id   => c_appl_inst_rec.person_id,
                                    p_nominated_course_cd       => c_appl_inst_rec.nominated_course_cd,
                                    p_admission_appl_number     => l_new_admission_appl_number,
                                    p_sequence_number           => l_new_sequence_number,
                                    p_old_admission_appl_number => c_appl_inst_rec.admission_appl_number,
                                    p_old_sequence_number       => c_appl_inst_rec.sequence_number,
                                    p_offer_dt                  => l_offer_dt,
                                    p_offer_response_dt         => l_offer_response_dt,
                                    p_fut_acad_cal_type         => p_fut_acad_cal_type,
                                    p_fut_acad_cal_seq_no       =>  p_fut_acad_cal_seq_no,
                                    p_fut_adm_cal_type          => p_fut_adm_cal_type,
                                    p_fut_adm_cal_seq_no        => p_fut_adm_cal_seq_no,
                                    p_start_dt                  => v_start_dt
                                    ) THEN
              -- Proceed to the next record in the cursor
              NULL;
            ELSE
              ROLLBACK TO sp_save_point2;
            END IF;
          ELSE
            ROLLBACK TO sp_save_point2;
          END IF;
            -- Do offer validations
        ELSE  -- if the copy child records failed
          ROLLBACK TO sp_save_point2;
        END IF;  -- end if copy child records
      ELSE  -- if the create application failed
        ROLLBACK TO sp_save_point2;
      END IF;  -- end if create application
    END LOOP;  -- end loop list of application instances
 END IF;
  IF  l_applcreated_flag THEN
  --Put the message into log that application could not be found for given parameters.
      fnd_file.put_line(fnd_file.log, fnd_message.get_string('IGS','IGS_AD_FTAPP_NOT_FOUND'));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    retcode:=2;
    errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    Igs_Ge_Msg_Stack.conc_exception_hndl;
    RETURN;
END admp_val_offer_future_term;

FUNCTION handle_application(
                                        p_person_id hz_parties.party_id%TYPE,
                                        p_admission_appl_number igs_ad_appl.admission_appl_number%TYPE,
                                        p_nominated_course_cd  igs_ad_ps_appl.nominated_course_cd%TYPE,
                                        p_sequence_number  igs_ad_ps_appl_inst.sequence_number%TYPE,
                                        p_fut_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                        p_fut_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                        p_fut_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                        p_fut_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                        p_new_admission_appl_number OUT NOCOPY igs_ad_appl.admission_appl_number%TYPE,
                                        p_new_sequence_number OUT NOCOPY igs_ad_ps_appl_inst.sequence_number%TYPE
                                    )  RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
rrengara        11-jul-2002      Added UK Parameters choice_number and routeb pref to insert_adm_appl procedure for bug 2448262 (D) and 2455053 (P)
                                Also changed the cursor c_appl_inst to add the above said parameters
rboddu          04-OCT-2002     Creating application with Application_Type. Bug :2599457
knag            21-NOV-2002     Added alt_appl_id param to call to insert_adm_appl for bug 2664410
pbondugu  28-Mar-2003    Passed  funding_source  to procedure call IGS_AD_GEN_014.insert_adm_appl_prog_inst
*******************************************************************************/
  -- Cursor Declarations-------------------------------------------------------------------
  -- Cursor to get the applications
  CURSOR c_appl_inst IS
  SELECT
    acai.*,
    aa.appl_dt, aa.admission_cat, aa.s_admission_process_type,
    aa.spcl_grp_1, aa.spcl_grp_2,aa.common_app,
    aa.adm_appl_status, aa.choice_number, aa.routeb_pref,
    aa.application_type, aa.adm_fee_status, aa.alt_appl_id,
    aa.acad_cal_type, aa.acad_ci_sequence_number,
    aca.admission_cd, aca.transfer_course_cd,
    aca.basis_for_admission_type,aca.req_for_reconsideration_ind,
    aca.req_for_adv_standing_ind,
    NVL(acai.adm_cal_type,aa.adm_cal_type) final_adm_cal_type,
    NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) final_adm_ci_sequence_number
  FROM
    igs_ad_ps_appl_inst acai, /* Replaced igs_ad_ps_appl_inst_aplinst_v with igs_ad_ps_appl_inst Bug 3150054 */
    igs_ad_appl aa,
    igs_ad_ps_appl aca
  WHERE
  acai.admission_appl_number = p_admission_appl_number
  AND acai.sequence_number = p_sequence_number
  AND acai.nominated_course_cd = p_nominated_course_cd
  AND aa.person_id = acai.person_id
  AND aa.admission_appl_number = acai.admission_appl_number
  AND acai.person_id = p_person_id
  AND aca.person_id = acai.person_id
  AND aca.admission_appl_number = acai.admission_appl_number
  AND aca.nominated_course_cd = acai.nominated_course_cd;

  CURSOR c_sys_def_appl_type(cp_adm_cat igs_ad_appl_all.admission_cat%TYPE,
                             cp_s_adm_prc_typ  igs_ad_appl_all.s_admission_process_type%TYPE
                             )
  IS
  SELECT admission_application_type
	FROM igs_ad_ss_appl_typ
	WHERE admission_cat = cp_adm_cat
  AND S_admission_process_type = cp_s_adm_prc_typ
  AND System_default = 'Y'
  AND NVL(closed_ind, 'N') <> 'Y';


  -----End cursor Declarations------------------------------------------------------------------

  -------------------Variable Declarations------------------------------------------------------
  l_message_name VARCHAR2(1000);
  l_adm_fee_status  igs_ad_appl.adm_fee_status%TYPE;
  l_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE;
  l_return_type  VARCHAR2(100);
  l_error_code  VARCHAR2(100);
  l_adm_appl_status igs_ad_appl.adm_appl_status%TYPE;
  l_admission_appl_number igs_ad_appl.admission_appl_number%TYPE;
  l_application_type igs_ad_appl_all.application_type%TYPE;
  ------------------- End Variable Declarations------------------------------------------------------
BEGIN

  FOR c_appl_inst_rec IN c_appl_inst LOOP

    l_application_type:= c_appl_inst_rec.application_type;
    --If Application Type of existing Future Term Application is NULL, then take the System Default Application Type
    -- And create the application with this application type. Bug: 2599457
    IF l_application_type IS NULL THEN
      OPEN c_sys_def_appl_type(c_appl_inst_rec.admission_cat,c_appl_inst_rec.s_admission_process_type);
      FETCH c_sys_def_appl_type INTO l_application_type;
      CLOSE c_sys_def_appl_type;
    END IF;

    -- Create Admission application
    IF IGS_AD_GEN_014.insert_adm_appl(
      p_person_id                    => p_person_id,
      p_appl_dt                      => c_appl_inst_rec.appl_dt,
      p_acad_cal_type                => p_fut_acad_cal_type ,
      p_acad_ci_sequence_number      => p_fut_acad_cal_seq_no ,
      p_adm_cal_type                 => p_fut_adm_cal_type ,
      p_adm_ci_sequence_number       => p_fut_adm_cal_seq_no ,
      p_admission_cat                => c_appl_inst_rec.admission_cat,
      p_s_admission_process_type     => c_appl_inst_rec.s_admission_process_type,
      p_adm_appl_status              => c_appl_inst_rec.adm_appl_status,
      p_adm_fee_status               => c_appl_inst_rec.adm_fee_status,  --IN/OUT
      p_tac_appl_ind                 =>'N',
      p_adm_appl_number              =>l_admission_appl_number, --OUT
      p_message_name                 =>l_message_name,  --OUT
      p_spcl_grp_1                   =>c_appl_inst_rec.spcl_grp_1,
      p_spcl_grp_2                   =>c_appl_inst_rec.spcl_grp_2,
      p_common_app                   =>c_appl_inst_rec.common_app,
      p_application_type             =>l_application_type,-- Added as part of 2599457
      p_choice_number                =>c_appl_inst_rec.choice_number,
      p_routeb_pref                  =>c_appl_inst_rec.routeb_pref,
      p_alt_appl_id                  =>c_appl_inst_rec.alt_appl_id) = FALSE THEN

      fnd_message.set_name('IGS', l_message_name);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      RETURN FALSE;

    ELSE  -- Else for Application
      IF IGS_AD_GEN_014.insert_adm_appl_prog(
                p_person_id=> p_person_id,
                p_adm_appl_number=>l_admission_appl_number,
                p_nominated_course_cd=>p_nominated_course_cd,
                p_transfer_course_cd=>c_appl_inst_rec.transfer_course_cd,
                p_basis_for_admission_type=>c_appl_inst_rec.basis_for_admission_type,
                p_admission_cd=>c_appl_inst_rec.admission_cd,
                p_req_for_reconsideration_ind=> c_appl_inst_rec.req_for_reconsideration_ind,
                p_req_for_adv_standing_ind=> c_appl_inst_rec.req_for_adv_standing_ind,
                p_message_name => l_message_name) THEN

             -- Create Admission Application Porgram Instance

        IF IGS_AD_GEN_014.insert_adm_appl_prog_inst (
                p_person_id=>p_person_id,
                p_admission_appl_number=>l_admission_appl_number,
                p_acad_cal_type=>p_fut_acad_cal_type,
                p_acad_ci_sequence_number=>p_fut_acad_cal_seq_no ,
                p_adm_cal_type=>p_fut_adm_cal_type ,
                p_adm_ci_sequence_number=>p_fut_adm_cal_seq_no,
                p_admission_cat=>c_appl_inst_rec.admission_cat,
                p_s_admission_process_type=>c_appl_inst_rec.s_admission_process_type,
                p_appl_dt=>c_appl_inst_rec.appl_dt,
            /*    p_adm_fee_status=>l_adm_fee_status, */
                p_adm_fee_status=>c_appl_inst_rec.adm_fee_status,
                p_preference_number=>c_appl_inst_rec.preference_number,
                p_offer_dt=>NULL,
                p_offer_response_dt=>NULL,
                p_course_cd=>c_appl_inst_rec.nominated_course_cd,
                p_crv_version_number=>c_appl_inst_rec.crv_version_number,
                p_location_cd=>c_appl_inst_rec.location_cd,
                p_attendance_mode=>c_appl_inst_rec.attendance_mode,
                p_attendance_type=>c_appl_inst_rec.attendance_type,
                p_unit_set_cd=>c_appl_inst_rec.unit_set_cd,
                p_us_version_number=>c_appl_inst_rec.us_version_number,
                p_fee_cat=>c_appl_inst_rec.fee_cat,
                p_correspondence_cat=>c_appl_inst_rec.correspondence_cat,
                p_enrolment_cat=>c_appl_inst_rec.enrolment_cat,
                p_funding_source=>c_appl_inst_rec.funding_source,
                p_edu_goal_prior_enroll=>c_appl_inst_rec.edu_goal_prior_enroll_id,
                p_app_source_id=>c_appl_inst_rec.app_source_id,
                p_apply_for_finaid=>c_appl_inst_rec.apply_for_finaid,
                p_finaid_apply_date=>c_appl_inst_rec.finaid_apply_date,
                p_attribute_category=>c_appl_inst_rec.attribute_category,
                p_attribute1=>c_appl_inst_rec.attribute1,
                p_attribute2=>c_appl_inst_rec.attribute2,
                p_attribute3=>c_appl_inst_rec.attribute3,
                p_attribute4=>c_appl_inst_rec.attribute4,
                p_attribute5=>c_appl_inst_rec.attribute5,
                p_attribute6=>c_appl_inst_rec.attribute6,
                p_attribute7=>c_appl_inst_rec.attribute7,
                p_attribute8=>c_appl_inst_rec.attribute8,
                p_attribute9=>c_appl_inst_rec.attribute9,
                p_attribute10=>c_appl_inst_rec.attribute10,
                p_attribute11=>c_appl_inst_rec.attribute11,
                p_attribute12=>c_appl_inst_rec.attribute12,
                p_attribute13=>c_appl_inst_rec.attribute13,
                p_attribute14=>c_appl_inst_rec.attribute14,
                p_attribute15=>c_appl_inst_rec.attribute15,
                p_attribute16=>c_appl_inst_rec.attribute16,
                p_attribute17=>c_appl_inst_rec.attribute17,
                p_attribute18=>c_appl_inst_rec.attribute18,
                p_attribute19=>c_appl_inst_rec.attribute19,
                p_attribute20=>c_appl_inst_rec.attribute20,
                p_attribute21=>c_appl_inst_rec.attribute21,
                p_attribute22=>c_appl_inst_rec.attribute22,
                p_attribute23=>c_appl_inst_rec.attribute23,
                p_attribute24=>c_appl_inst_rec.attribute24,
                p_attribute25=>c_appl_inst_rec.attribute25,
                p_attribute26=>c_appl_inst_rec.attribute26,
                p_attribute27=>c_appl_inst_rec.attribute27,
                p_attribute28=>c_appl_inst_rec.attribute28,
                p_attribute29=>c_appl_inst_rec.attribute29,
                p_attribute30=>c_appl_inst_rec.attribute30,
                p_attribute31=>c_appl_inst_rec.attribute31,
                p_attribute32=>c_appl_inst_rec.attribute32,
                p_attribute33=>c_appl_inst_rec.attribute33,
                p_attribute34=>c_appl_inst_rec.attribute34,
                p_attribute35=>c_appl_inst_rec.attribute35,
                p_attribute36=>c_appl_inst_rec.attribute36,
                p_attribute37=>c_appl_inst_rec.attribute37,
                p_attribute38=>c_appl_inst_rec.attribute38,
                p_attribute39=>c_appl_inst_rec.attribute39,
                p_attribute40=>c_appl_inst_rec.attribute40,
                p_ss_application_id =>NULL,
                p_sequence_number   =>l_sequence_number,
                p_return_type       =>l_return_type,
                p_error_code        =>l_error_code,
                p_message_name      =>l_message_name,
                p_entry_status      =>c_appl_inst_rec.entry_status,
                p_entry_level       =>c_appl_inst_rec.entry_level,
                p_sch_apl_to_id     =>c_appl_inst_rec.sch_apl_to_id) THEN
                p_new_admission_appl_number := l_admission_appl_number;
                p_new_sequence_number := l_sequence_number;
                RETURN TRUE;

        ELSE  -- Else of Application Instance

          IF l_message_name  IN ('IGS_AD_NOMINATE_PRG_OFR_ENTRY', 'IGS_AD_NOMINATED_PRG_ENTRYPNT') THEN
            l_message_name := 'IGS_AD_CAL_PGM_NOT_OFFER';
            fnd_message.set_name('IGS', l_message_name);
            fnd_message.set_token('PGM', c_appl_inst_rec.nominated_course_cd);
            fnd_message.set_token('ALTCODE',c_appl_inst_rec.acad_cal_type||','||IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.acad_ci_sequence_number)
                                  ||'/'||c_appl_inst_rec.final_adm_cal_type||','||IGS_GE_NUMBER.TO_CANN(c_appl_inst_rec.final_adm_ci_sequence_number));
            fnd_file.put_line(fnd_file.log, fnd_message.get);
          ELSE
            fnd_message.set_name('IGS', l_message_name);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
          END IF;
          RETURN FALSE;
        END IF;
        RETURN FALSE;
      ELSE  -- Else for Application Program
        fnd_message.set_name('IGS', l_message_name);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        RETURN FALSE;
      END IF;
    END IF;
  END LOOP;
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log, 'Exception From handle application log ' ||   SQLERRM);
    RETURN FALSE;
END handle_application;

FUNCTION copy_child_records(p_new_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                            p_new_sequence_number       IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                            p_person_id                 HZ_PARTIES.party_id%TYPE,
                            p_old_admission_appl_number IGS_AD_APPL.admission_appl_number%TYPE,
                            p_old_sequence_number       IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                            p_nominated_course_cd       IGS_AD_PS_APPL.nominated_course_cd%TYPE,
                            p_start_dt                  DATE,
			                      p_process                   VARCHAR2)
RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
pathipat        17-Jun-2003     Enh 2831587 - FI210 Credit Card Fund Transfer build
                                Modified TBH call to igs_ad_app_req_pkg to include 3 new columns
vvutukur        27-Nov-2002 Enh#2584986.Modified cursor c_fee_cur and also tbh call to igs_ad_app_req_pkg.insert_row
                            to include 11 new columns related to credit card details,accounting information and
                            gl date.
rrengara        30-oct-2002     Removed Academic Honros copying Bug 2647482
rrengara        13-sep-2002     Added p_process to the procedure. If p_process is 'D' then copy the fee details fee status as 'WAIVED'
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
  AND  ccl.system_default = 'Y'
  AND  ccl.CLASS_TYPE_CODE='ADM_CODE_CLASSES';


CURSOR c_appl_qual_code(cp_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                        cp_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
			cp_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
			cp_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE ) IS
  SELECT  QUALIFYING_TYPE_CODE,QUALIFYING_CODE_ID,QUALIFYING_VALUE ,PERSON_ID,NOMINATED_COURSE_CD
  FROM igs_ad_appqual_code
  WHERE  person_id = cp_person_id
  AND  nominated_course_cd = cp_nominated_course_cd
  AND sequence_number = cp_sequence_number
  AND admission_appl_number = cp_admission_appl_number;

---End cursor Declarations-----------------------------------------------------------------------------

---- Variable declarations-----------------------------------------------------------------------------
l_primary_key NUMBER(15);
l_rowid VARCHAR2(30);
l_last_error VARCHAR2(100);
l_waived_fee_status igs_ad_app_req.applicant_fee_status%TYPE;

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


-- rrengara
-- for Build Movement Academic Honors
-- on 28-oct-2002
--
-- academic honors has been moved to Person
-- Removed the TBH call which will insert the values for the new application from here



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

-- Fess ( Requirements )


FOR  c_fee_rec IN c_fee_cur(p_person_id, p_old_admission_appl_number) LOOP
  l_last_error :=  'IGS_AD_CHILD_FEE_DET';

-- Bug 2395510
-- If the process is deferred then set the fee status to 'WAIVED' for all the records
IF p_process = 'D' THEN
  OPEN c_fee_status;
  FETCH c_fee_status INTO l_waived_fee_status;
  IF c_fee_status%NOTFOUND THEN
    CLOSE c_fee_status;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_fee_status;
ELSE
  l_waived_fee_status := c_fee_rec.applicant_fee_status;
END IF;

igs_ad_app_req_pkg.insert_row(
        x_rowid                        => l_rowid,
        x_app_req_id                   => l_primary_key,
        x_person_id                    => c_fee_rec.person_id,
        x_admission_appl_number        => p_new_admission_appl_number,
        x_applicant_fee_type           => c_fee_rec.applicant_fee_type,
        x_applicant_fee_status         => l_waived_fee_status,
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

--Qualification Codes
l_rowid := NULL;

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

l_rowid := NULL;

IF copy_candidacy_records ( p_new_admission_appl_number => p_new_admission_appl_number,
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
  FND_MESSAGE.SET_NAME('IGS','IGS_AD_CHILD_COPY_FAILED');
  Fnd_File.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

  FND_MESSAGE.SET_NAME('IGS',l_last_error);
  fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET || SQLERRM);

  RETURN FALSE;
END copy_child_records;

FUNCTION validate_offer_validations(p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                    p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                    p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                    p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                    p_old_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                    p_old_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                    p_offer_dt igs_ad_ps_appl_inst.offer_dt%TYPE,
                                    p_offer_response_dt igs_ad_ps_appl_inst.offer_response_dt%TYPE,
                                    p_fut_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                                    p_fut_acad_cal_seq_no igs_ad_appl.acad_ci_sequence_number%TYPE,
                                    p_fut_adm_cal_type igs_ad_appl.adm_cal_type%TYPE,
                                    p_fut_adm_cal_seq_no igs_ad_appl.adm_ci_sequence_number%TYPE,
                                    p_start_dt DATE
                                    ) RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
rrengara        30-oct-2002     Build 2647482 Core Vs Optional
*******************************************************************************/
-- Cursor Declarations ----------------------------------------------------------------------------

CURSOR c_appl_inst_old_cur IS
  SELECT
    apai.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_old_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_old_sequence_number;

 c_appl_inst_old_rec c_appl_inst_old_cur%ROWTYPE;


CURSOR c_appl_offer_cur IS
SELECT
  acai.*, aa.acad_cal_type, aa.acad_ci_sequence_number, aa.adm_fee_status, aa.alt_appl_id,
    NVL(acai.adm_cal_type,aa.adm_cal_type) final_adm_cal_type,
    NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) final_adm_ci_sequence_number
FROM
  igs_ad_appl aa,
  igs_ad_ps_appl_inst acai  /* Replaced igs_ad_ps_appl_inst_aplinst_v with igs_ad_ps_appl_inst Bug 3150054 */
WHERE
  acai.person_id = p_person_id       AND
  acai.nominated_course_cd = p_nominated_course_cd      AND
  acai.sequence_number = p_sequence_number     AND
  acai.admission_appl_number = p_admission_appl_number AND
  acai.person_id = aa.person_id AND
  acai.admission_appl_number = aa.admission_appl_number;

  CURSOR c_admcat_cur IS
  SELECT
    admission_cat, s_admission_process_type, appl_dt
  FROM
    igs_ad_appl
  WHERE
    person_id = p_person_id AND
    admission_appl_number = p_admission_appl_number;


  c_admcat_rec c_admcat_cur%ROWTYPE;

CURSOR c_apcs_cur (
        cp_admission_cat              igs_ad_prcs_cat_step.admission_cat%TYPE,
        cp_s_admission_process_type   igs_ad_prcs_cat_step.s_admission_process_type%TYPE
            )
IS
SELECT
  s_admission_step_type, step_type_restriction_num
FROM
  igs_ad_prcs_cat_step
WHERE
  admission_cat = cp_admission_cat
  AND s_admission_process_type = cp_s_admission_process_type
  AND step_group_type <> 'TRACK';

CURSOR c_upd_acai_cur IS
  SELECT
    ROWID, APAI.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_sequence_number;
 -- End Cursor Declarations ----------------------------------------------------------------------------

 -- Variable Declarations -------------------------------------------------------------------------------

  l_offer_response_dt  igs_ad_ps_appl_inst.offer_response_dt%TYPE;
  v_pref_allowed_ind               VARCHAR2 (1);
  v_pref_limit                     NUMBER;
  v_cond_offer_doc_allowed_ind     VARCHAR2 (1);
  v_cond_offer_fee_allowed_ind     VARCHAR2 (1);
  v_cond_offer_ass_allowed_ind     VARCHAR2 (1);
  v_late_appl_allowed_ind          VARCHAR2 (1);
  v_late_fees_required_ind         VARCHAR2 (1);
  v_fees_required_ind              VARCHAR2 (1);
  v_override_outcome_allowed_ind   VARCHAR2 (1);
  v_set_outcome_allowed_ind        VARCHAR2 (1);
  v_mult_offer_allowed_ind         VARCHAR2 (1);
  v_multi_offer_limit              NUMBER;
  v_unit_set_appl_ind              VARCHAR2 (1);
  v_check_person_encumb            VARCHAR2 (1);
  v_check_course_encumb            VARCHAR2 (1);
  v_deferral_allowed_ind           VARCHAR2 (1);
  v_pre_enrol_ind                  VARCHAR2 (1);
  v_warn_level  VARCHAR2(10);
  v_message_name VARCHAR2(100);
  l_adm_cat IGS_AD_APPL.admission_cat%TYPE;
  l_s_adm_process_type IGS_AD_APPL.s_admission_process_type%TYPE;
  l_appl_dt  IGS_AD_APPL.appl_dt%TYPE;
  -- End Variable Declarations -------------------------------------------------------------------------------

BEGIN

  v_pref_allowed_ind                := 'N';
  v_cond_offer_doc_allowed_ind      := 'N';
  v_cond_offer_fee_allowed_ind      := 'N';
  v_cond_offer_ass_allowed_ind      := 'N';
  v_late_appl_allowed_ind           := 'N';
  v_late_fees_required_ind          := 'N';
  v_fees_required_ind               := 'N';
  v_override_outcome_allowed_ind    := 'N';
  v_set_outcome_allowed_ind         := 'N';
  v_mult_offer_allowed_ind          := 'N';
  v_unit_set_appl_ind               := 'N';
  v_check_person_encumb             := 'N';
  v_check_course_encumb             := 'N';
  v_deferral_allowed_ind            := 'N';
  v_pre_enrol_ind                   := 'N';

  FOR c_appl_offer_rec IN c_appl_offer_cur LOOP

    OPEN c_admcat_cur;
    FETCH c_admcat_cur INTO l_adm_cat, l_s_adm_process_type, l_appl_dt;
    CLOSE c_admcat_cur;

    -- This cursor has to be opened to copy the decision related values to the new application

    OPEN c_appl_inst_old_cur;
    FETCH c_appl_inst_old_cur INTO c_appl_inst_old_rec;
    CLOSE c_appl_inst_old_cur;

    --
    -- Determine the admission process category steps.
    --
    FOR l_c_apcs_rec IN c_apcs_cur (
      l_adm_cat,
      l_s_adm_process_type)  LOOP
      IF l_c_apcs_rec.s_admission_step_type = 'CHKCENCUMB' THEN
        v_check_course_encumb := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'CHKPENCUMB' THEN
        v_check_person_encumb := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'PREF-LIMIT'  THEN
        v_pref_allowed_ind := 'Y';
        v_pref_limit := l_c_apcs_rec.step_type_restriction_num;

      ELSIF l_c_apcs_rec.s_admission_step_type = 'DOC-COND'  THEN
        v_cond_offer_doc_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'FEE-COND' THEN
        v_cond_offer_fee_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'ASSES-COND' THEN
        v_cond_offer_ass_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'LATE-APP' THEN
        v_late_appl_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'LATE-FEE' THEN
        v_late_fees_required_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'APP-FEE' THEN
        v_fees_required_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'OVERRIDE-O'  THEN
        v_override_outcome_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'SET-OTCOME' THEN
        v_set_outcome_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'MULTI-OFF'  THEN
        v_mult_offer_allowed_ind := 'Y';
        v_multi_offer_limit := l_c_apcs_rec.step_type_restriction_num;

      ELSIF l_c_apcs_rec.s_admission_step_type = 'UNIT-SET' THEN
        v_unit_set_appl_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'DEFER' THEN
        v_deferral_allowed_ind := 'Y';

      ELSIF l_c_apcs_rec.s_admission_step_type = 'PRE-ENROL' THEN
        v_pre_enrol_ind := 'Y';
      END IF;
    END LOOP;

    IF IGS_AD_VAL_ACAI.admp_val_offer_dt (
                        p_offer_dt,
                        igs_ad_gen_009.admp_get_sys_aos('OFFER'),
                        c_appl_offer_rec.adm_cal_type,
                        c_appl_offer_rec.adm_ci_sequence_number,
                        v_message_name) = FALSE THEN
         fnd_message.set_name('IGS', v_message_name);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;


     -- calculate the offer response date if the user doesn't passes the value
    IF p_offer_response_dt IS NULL THEN

      -- Calculate the Offer response date by calling the following procedure
      l_offer_response_dt := IGS_AD_GEN_007.ADMP_GET_RESP_DT (
                                c_appl_offer_rec.course_cd,
                                c_appl_offer_rec.crv_version_number,
                                c_appl_offer_rec.acad_cal_type,
                                c_appl_offer_rec.location_cd,
                                c_appl_offer_rec.attendance_mode,
                                c_appl_offer_rec.attendance_type,
                                l_adm_cat,
                                l_s_adm_process_type,
                                c_appl_offer_rec.adm_cal_type,
                                c_appl_offer_rec.adm_ci_sequence_number,
                                p_offer_dt );
    ELSE
      l_offer_response_dt := p_offer_response_dt;
    END IF;

    IF igs_ad_val_acai_status.admp_val_acai_aos (
               c_appl_offer_rec.person_id,
               c_appl_offer_rec.admission_appl_number,
               c_appl_offer_rec.nominated_course_cd,
               c_appl_offer_rec.sequence_number,
               c_appl_offer_rec.course_cd,
               c_appl_offer_rec.crv_version_number,
               c_appl_offer_rec.location_cd,
               c_appl_offer_rec.attendance_mode,
               c_appl_offer_rec.attendance_type,
               c_appl_offer_rec.unit_set_cd,
               c_appl_offer_rec.us_version_number,
               c_appl_offer_rec.acad_cal_type,
               c_appl_offer_rec.acad_ci_sequence_number,
               c_appl_offer_rec.adm_cal_type,
               c_appl_offer_rec.adm_ci_sequence_number,
               l_adm_cat,
               l_s_adm_process_type,
               l_appl_dt,
               c_appl_offer_rec.fee_cat,
               c_appl_offer_rec.correspondence_cat,
               c_appl_offer_rec.enrolment_cat,
               igs_ad_gen_009.admp_get_sys_aos('OFFER'),
               c_appl_offer_rec.adm_outcome_status,
               c_appl_offer_rec.adm_doc_status,
               c_appl_offer_rec.adm_fee_status,
               igs_ad_gen_008.admp_get_safs(c_appl_inst_old_rec.late_adm_fee_status),  -- passing the user defined late adm fee status of the old application instead of 'RECEIVED' (bug#3011405 , rghosh)
               c_appl_offer_rec.adm_cndtnl_offer_status,
               c_appl_offer_rec.adm_entry_qual_status,
               igs_ad_gen_009.admp_get_sys_aors('PENDING'),
               c_appl_offer_rec.adm_offer_resp_status,  --old
               c_appl_offer_rec.adm_outcome_status_auth_dt,
               v_set_outcome_allowed_ind,
               v_cond_offer_ass_allowed_ind,
               v_cond_offer_fee_allowed_ind,
               v_cond_offer_doc_allowed_ind,
               v_late_appl_allowed_ind,
               v_fees_required_ind,
               v_mult_offer_allowed_ind,
               v_multi_offer_limit,
               v_pref_allowed_ind,
               v_unit_set_appl_ind,
               v_check_person_encumb,
               v_check_course_encumb,
               'FORM',
               v_message_name
            ) THEN

      FOR c_upd_acai_rec IN c_upd_acai_cur LOOP

        -- Offer validations is successful then update the offer
        Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
                                x_rowid                         => c_upd_acai_rec.row_id ,
                                x_person_id                     => c_upd_acai_rec.person_id ,
                                x_admission_appl_number         => c_upd_acai_rec.admission_appl_number ,
                                x_nominated_course_cd           => c_upd_acai_rec.nominated_course_cd ,
                                x_sequence_number               => c_upd_acai_rec.sequence_number ,
                                x_predicted_gpa                 => c_upd_acai_rec.predicted_gpa ,
                                x_academic_index                => c_upd_acai_rec.academic_index,
                                x_adm_cal_type                  => c_upd_acai_rec.adm_cal_type ,
                                x_app_file_location             => c_upd_acai_rec.app_file_location ,
                                x_adm_ci_sequence_number        => c_upd_acai_rec.adm_ci_sequence_number ,
                                x_course_cd                     => c_upd_acai_rec.course_cd ,
                                x_app_source_id                 => c_upd_acai_rec.app_source_id ,
                                x_crv_version_number            => c_upd_acai_rec.crv_version_number ,
                                x_waitlist_rank                 => c_upd_acai_rec.waitlist_rank,
                                x_waitlist_status               => c_upd_acai_rec.waitlist_status,
                                x_location_cd                   => c_upd_acai_rec.location_cd ,
                                x_attent_other_inst_cd          => c_upd_acai_rec.attent_other_inst_cd,
                                x_attendance_mode               => c_upd_acai_rec.attendance_mode ,
                                x_edu_goal_prior_enroll_id      => c_upd_acai_rec.edu_goal_prior_enroll_id,
                                x_attendance_type               => c_upd_acai_rec.attendance_type ,
                                x_decision_make_id              => c_appl_inst_old_rec.decision_make_id,
                                x_unit_set_cd                   => c_upd_acai_rec.unit_set_cd ,
                                x_decision_date                 => c_appl_inst_old_rec.decision_date,
                                x_attribute_category            => c_upd_acai_rec.attribute_category,
                                x_attribute1                    => c_upd_acai_rec.attribute1,
                                x_attribute2                    => c_upd_acai_rec.attribute2,
                                x_attribute3                    => c_upd_acai_rec.attribute3,
                                x_attribute4                    => c_upd_acai_rec.attribute4,
                                x_attribute5                    => c_upd_acai_rec.attribute5,
                                x_attribute6                    => c_upd_acai_rec.attribute6,
                                x_attribute7                    => c_upd_acai_rec.attribute7,
                                x_attribute8                    => c_upd_acai_rec.attribute8,
                                x_attribute9                    => c_upd_acai_rec.attribute9,
                                x_attribute10                   => c_upd_acai_rec.attribute10,
                                x_attribute11                   => c_upd_acai_rec.attribute11,
                                x_attribute12                   => c_upd_acai_rec.attribute12,
                                x_attribute13                   => c_upd_acai_rec.attribute13,
                                x_attribute14                   => c_upd_acai_rec.attribute14,
                                x_attribute15                   => c_upd_acai_rec.attribute15,
                                x_attribute16                   => c_upd_acai_rec.attribute16,
                                x_attribute17                   => c_upd_acai_rec.attribute17,
                                x_attribute18                   => c_upd_acai_rec.attribute18,
                                x_attribute19                   => c_upd_acai_rec.attribute19,
                                x_attribute20                   => c_upd_acai_rec.attribute20,
                                x_decision_reason_id            => c_appl_inst_old_rec.decision_reason_id,
                                x_us_version_number             => c_upd_acai_rec.us_version_number ,
                                x_decision_notes                => c_appl_inst_old_rec.decision_notes,
                                x_pending_reason_id             => c_upd_acai_rec.pending_reason_id,
                                x_preference_number             => c_upd_acai_rec.preference_number ,
                                x_adm_doc_status                => c_upd_acai_rec.adm_doc_status ,
                                x_adm_entry_qual_status         => c_upd_acai_rec.adm_entry_qual_status,
                                x_deficiency_in_prep            => c_upd_acai_rec.deficiency_in_prep ,
                                x_late_adm_fee_status           => c_appl_inst_old_rec.late_adm_fee_status , -- passing the user defined late adm fee status of the old application instead of 'RECEIVED' (bug#3011405 , rghosh)
                                x_spl_consider_comments         => c_upd_acai_rec.spl_consider_comments,
                                x_adm_outcome_status            => IGS_AD_GEN_009.ADMP_GET_SYS_AOS('OFFER'),
                                x_adm_otcm_stat_auth_per_id     => c_upd_acai_rec.adm_otcm_status_auth_person_id ,
                                x_adm_outcome_status_auth_dt    => c_upd_acai_rec.adm_outcome_status_auth_dt ,
                                x_adm_outcome_status_reason     => c_upd_acai_rec.adm_outcome_status_reason ,
                                x_offer_dt                      => p_offer_dt,
                                x_offer_response_dt             => l_offer_response_dt,
                                x_prpsd_commencement_dt         => p_start_dt,
                                x_adm_cndtnl_offer_status       => c_upd_acai_rec.adm_cndtnl_offer_status ,
                                x_cndtnl_offer_satisfied_dt     => c_upd_acai_rec.cndtnl_offer_satisfied_dt ,
                                x_cndnl_ofr_must_be_stsfd_ind   => c_upd_acai_rec.cndtnl_offer_must_be_stsfd_ind ,
                                x_adm_offer_resp_status         => igs_ad_gen_009.admp_get_sys_aors('PENDING'),
                                x_actual_response_dt            => c_upd_acai_rec.actual_response_dt ,
                                x_adm_offer_dfrmnt_status       => c_upd_acai_rec.adm_offer_dfrmnt_status ,
                                x_deferred_adm_cal_type         => c_upd_acai_rec.deferred_adm_cal_type,
                                x_deferred_adm_ci_sequence_num  => c_upd_acai_rec.deferred_adm_ci_sequence_num  ,
                                x_deferred_tracking_id          => c_upd_acai_rec.deferred_tracking_id ,
                                x_ass_rank                      => c_upd_acai_rec.ass_rank ,
                                x_secondary_ass_rank            => c_upd_acai_rec.secondary_ass_rank ,
                                x_intr_accept_advice_num        => c_upd_acai_rec.intrntnl_acceptance_advice_num  ,
                                x_ass_tracking_id               => c_upd_acai_rec.ass_tracking_id ,
                                x_fee_cat                       => c_upd_acai_rec.fee_cat ,
                                x_hecs_payment_option           => c_upd_acai_rec.hecs_payment_option ,
                                x_expected_completion_yr        => c_upd_acai_rec.expected_completion_yr ,
                                x_expected_completion_perd      => c_upd_acai_rec.expected_completion_perd ,
                                x_correspondence_cat            => c_upd_acai_rec.correspondence_cat ,
                                x_enrolment_cat                 => c_upd_acai_rec.enrolment_cat ,
                                x_funding_source                => c_appl_inst_old_rec.funding_source,
                                x_applicant_acptnce_cndtn       => c_upd_acai_rec.applicant_acptnce_cndtn ,
                                x_cndtnl_offer_cndtn            => c_upd_acai_rec.cndtnl_offer_cndtn ,
                                x_ss_application_id             => c_upd_acai_rec.ss_application_id,
                                x_ss_pwd                        => c_upd_acai_rec.ss_pwd,
                                x_authorized_dt                 => c_upd_acai_rec.authorized_dt,
                                x_authorizing_pers_id           => c_upd_acai_rec.authorizing_pers_id ,
                                x_idx_calc_date                 => c_upd_acai_rec.idx_calc_date,
                                x_mode                          => 'R',
                                x_fut_acad_cal_type             => NULL,--p_fut_acad_cal_type,
                                x_fut_acad_ci_sequence_number   => NULL,--p_fut_acad_cal_seq_no,
                                x_fut_adm_cal_type              => NULL,--p_fut_adm_cal_type,
                                x_fut_adm_ci_sequence_number    => NULL,--p_fut_adm_cal_seq_no ,
                                x_prev_term_adm_appl_number     => p_old_admission_appl_number,
                                x_prev_term_sequence_number     => p_old_sequence_number,
                                x_fut_term_adm_appl_number      => c_upd_acai_rec.future_term_adm_appl_number,
                                x_fut_term_sequence_number      => c_upd_acai_rec.future_term_sequence_number,
		                X_DEF_ACAD_CAL_TYPE             => c_upd_acai_rec.DEF_ACAD_CAL_TYPE, --Bug 2395510
				X_DEF_ACAD_CI_SEQUENCE_NUM      => c_upd_acai_rec.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
		                X_DEF_PREV_TERM_ADM_APPL_NUM    => c_upd_acai_rec.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
		                X_DEF_PREV_APPL_SEQUENCE_NUM    => c_upd_acai_rec.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
		                X_DEF_TERM_ADM_APPL_NUM         => c_upd_acai_rec.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
				X_DEF_APPL_SEQUENCE_NUM         => c_upd_acai_rec.DEF_APPL_SEQUENCE_NUM, --Bug 2395510
			-- Added entry Status, entry level and school applying id and fin aid columns here for Bug 2631918
		        -- by rrengara on 3-DEC-2002
				x_entry_status                  => c_appl_inst_old_rec.entry_status,
				x_entry_level                   => c_appl_inst_old_rec.entry_level,
				x_sch_apl_to_id                 => c_appl_inst_old_rec.sch_apl_to_id,
				x_apply_for_finaid              => c_appl_inst_old_rec.apply_for_finaid,
				x_finaid_apply_date             => c_appl_inst_old_rec.finaid_apply_date,
				x_appl_inst_status		=> c_appl_inst_old_rec.appl_inst_status,
				x_ais_reason			=> c_appl_inst_old_rec.ais_reason,
				x_decline_ofr_reason		=> c_appl_inst_old_rec.decline_ofr_reason
				);
      END LOOP;

      -- Run the pre-enrollment process
      IF v_pre_enrol_ind = 'Y' THEN
        -- Validate the Enrollment Category mapping
        IF IGS_AD_VAL_ACAI.admp_val_acai_ec (
                         l_adm_cat,
                         c_appl_offer_rec.enrolment_cat,
                         v_message_name) = FALSE THEN
          fnd_message.set_name('IGS', v_message_name);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RETURN FALSE;
        END IF;


        -- rrengara
	-- on 28-oct-2002 for Build Core Vs optional Bug 2647482
	-- get the unit set mapping by calling the apc for the application
	-- then pass the value to the Pre-enrollment procedure for the parameter p_units_indicator


        IF igs_ad_upd_initialise.perform_pre_enrol(
             c_appl_offer_rec.person_id,
             c_appl_offer_rec.admission_appl_number,
             c_appl_offer_rec.nominated_course_cd,
             c_appl_offer_rec.sequence_number,
             'N',                     -- Confirm course indicator.
             'N',                     -- Perform eligibility check indicator.
             v_message_name) = FALSE THEN
          fnd_message.set_name('IGS', v_message_name);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;
      END IF;  -- PRE-ENROLL IND = 'Y'

    ELSE
      IF v_message_name  IN ('IGS_AD_NOMINATE_PRG_OFR_ENTRY', 'IGS_AD_NOMINATED_PRG_ENTRYPNT') THEN
        v_message_name := 'IGS_AD_CAL_PGM_NOT_OFFER';
        fnd_message.set_name('IGS', v_message_name);
        fnd_message.set_token('PGM', c_appl_offer_rec.nominated_course_cd);
        fnd_message.set_token('ALTCODE',c_appl_offer_rec.acad_cal_type||','||IGS_GE_NUMBER.TO_CANN(c_appl_offer_rec.acad_ci_sequence_number)
                              ||'/'||c_appl_offer_rec.final_adm_cal_type||','||IGS_GE_NUMBER.TO_CANN(c_appl_offer_rec.final_adm_ci_sequence_number));
        fnd_file.put_line(fnd_file.log, fnd_message.get);
      ELSE
        fnd_message.set_name('IGS', v_message_name);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
      END IF;
      RETURN FALSE;
    END IF;
  END LOOP;
   RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, SQLERRM);
  RETURN FALSE;
END validate_offer_validations;

FUNCTION copy_entrycomp_qual_status(p_person_id  HZ_PARTIES.PARTY_ID%TYPE,
                                p_nominated_course_cd IGS_AD_PS_APPL_INST.NOMINATED_COURSE_CD%TYPE,
                                p_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                p_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE,
                                p_new_admission_appl_number IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                                p_new_sequence_number IGS_AD_PS_APPL_INST.sequence_number%TYPE ) RETURN BOOLEAN IS
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 20 FEB 2002

Purpose:
  To create future term application

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
*******************************************************************************/
  CURSOR c_upd_acai_new_cur IS
  SELECT
    apai.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_new_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_new_sequence_number;


  CURSOR c_upd_acai_old_cur IS
  SELECT
    apai.*
  FROM
    igs_ad_ps_appl_inst apai
  WHERE
    apai.person_id   = p_person_id
    AND apai.admission_appl_number  =  p_admission_appl_number
    AND apai.nominated_course_cd     =   p_nominated_course_cd
    AND apai.sequence_number   = p_sequence_number;

BEGIN

  -- This procedure updates only entry qualification status from old to new future term application
  FOR c_upd_acai_old_rec IN c_upd_acai_old_cur LOOP
    FOR c_upd_acai_new_rec IN c_upd_acai_new_cur LOOP
      Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
                                x_rowid                         => c_upd_acai_new_rec.row_id ,
                                x_person_id                     => c_upd_acai_new_rec.person_id ,
                                x_admission_appl_number         => c_upd_acai_new_rec.admission_appl_number ,
                                x_nominated_course_cd           => c_upd_acai_new_rec.nominated_course_cd ,
                                x_sequence_number               => c_upd_acai_new_rec.sequence_number ,
                                x_predicted_gpa                 => c_upd_acai_new_rec.predicted_gpa ,
                                x_academic_index                => c_upd_acai_new_rec.academic_index,
                                x_adm_cal_type                  => c_upd_acai_new_rec.adm_cal_type ,
                                x_app_file_location             => c_upd_acai_new_rec.app_file_location ,
                                x_adm_ci_sequence_number        => c_upd_acai_new_rec.adm_ci_sequence_number ,
                                x_course_cd                     => c_upd_acai_new_rec.course_cd ,
                                x_app_source_id                 => c_upd_acai_new_rec.app_source_id ,
                                x_crv_version_number            => c_upd_acai_new_rec.crv_version_number ,
                                x_waitlist_rank                 => c_upd_acai_new_rec.waitlist_rank,
                                x_waitlist_status               => c_upd_acai_new_rec.waitlist_status,
                                x_location_cd                   => c_upd_acai_new_rec.location_cd ,
                                x_attent_other_inst_cd          => c_upd_acai_new_rec.attent_other_inst_cd,
                                x_attendance_mode               => c_upd_acai_new_rec.attendance_mode ,
                                x_edu_goal_prior_enroll_id      => c_upd_acai_new_rec.edu_goal_prior_enroll_id,
                                x_attendance_type               => c_upd_acai_new_rec.attendance_type ,
                                x_decision_make_id              => c_upd_acai_new_rec.decision_make_id,
                                x_unit_set_cd                   => c_upd_acai_new_rec.unit_set_cd ,
                                x_decision_date                 => c_upd_acai_new_rec.decision_date,
                                x_attribute_category            => c_upd_acai_new_rec.attribute_category,
                                x_attribute1                    => c_upd_acai_new_rec.attribute1,
                                x_attribute2                    => c_upd_acai_new_rec.attribute2,
                                x_attribute3                    => c_upd_acai_new_rec.attribute3,
                                x_attribute4                    => c_upd_acai_new_rec.attribute4,
                                x_attribute5                    => c_upd_acai_new_rec.attribute5,
                                x_attribute6                    => c_upd_acai_new_rec.attribute6,
                                x_attribute7                    => c_upd_acai_new_rec.attribute7,
                                x_attribute8                    => c_upd_acai_new_rec.attribute8,
                                x_attribute9                    => c_upd_acai_new_rec.attribute9,
                                x_attribute10                   => c_upd_acai_new_rec.attribute10,
                                x_attribute11                   => c_upd_acai_new_rec.attribute11,
                                x_attribute12                   => c_upd_acai_new_rec.attribute12,
                                x_attribute13                   => c_upd_acai_new_rec.attribute13,
                                x_attribute14                   => c_upd_acai_new_rec.attribute14,
                                x_attribute15                   => c_upd_acai_new_rec.attribute15,
                                x_attribute16                   => c_upd_acai_new_rec.attribute16,
                                x_attribute17                   => c_upd_acai_new_rec.attribute17,
                                x_attribute18                   => c_upd_acai_new_rec.attribute18,
                                x_attribute19                   => c_upd_acai_new_rec.attribute19,
                                x_attribute20                   => c_upd_acai_new_rec.attribute20,
                                x_decision_reason_id            => c_upd_acai_new_rec.decision_reason_id,
                                x_us_version_number             => c_upd_acai_new_rec.us_version_number ,
                                x_decision_notes                => c_upd_acai_new_rec.decision_notes,
                                x_pending_reason_id             => c_upd_acai_new_rec.pending_reason_id,
                                x_preference_number             => c_upd_acai_new_rec.preference_number ,
                                x_adm_doc_status                => c_upd_acai_old_rec.adm_doc_status ,   -- updating doc status
                                x_adm_entry_qual_status         => c_upd_acai_old_rec.adm_entry_qual_status,  -- updating entry qualification status
                                x_deficiency_in_prep            => c_upd_acai_new_rec.deficiency_in_prep ,
                                x_late_adm_fee_status           => c_upd_acai_old_rec.late_adm_fee_status,  -- passing the user defined late adm fee status of the old application instead of 'RECEIVED' (bug#3011405 , rghosh)
                                x_spl_consider_comments         => c_upd_acai_new_rec.spl_consider_comments,
                                x_adm_outcome_status            => c_upd_acai_new_rec.adm_outcome_status,
                                x_adm_otcm_stat_auth_per_id     => c_upd_acai_new_rec.adm_otcm_status_auth_person_id,
                                x_adm_outcome_status_auth_dt    => c_upd_acai_new_rec.adm_outcome_status_auth_dt,
                                x_adm_outcome_status_reason     => c_upd_acai_new_rec.adm_outcome_status_reason,
                                x_offer_dt                      => c_upd_acai_new_rec.offer_dt,
                                x_offer_response_dt             => c_upd_acai_new_rec.offer_response_dt,
                                x_prpsd_commencement_dt         => c_upd_acai_new_rec.prpsd_commencement_dt,
                                x_adm_cndtnl_offer_status       => c_upd_acai_new_rec.adm_cndtnl_offer_status,
                                x_cndtnl_offer_satisfied_dt     => c_upd_acai_new_rec.cndtnl_offer_satisfied_dt,
                                x_cndnl_ofr_must_be_stsfd_ind   => c_upd_acai_new_rec.cndtnl_offer_must_be_stsfd_ind,
                                x_adm_offer_resp_status         => c_upd_acai_new_rec.adm_offer_resp_status,
                                x_actual_response_dt            => c_upd_acai_new_rec.actual_response_dt,
                                x_adm_offer_dfrmnt_status       => c_upd_acai_new_rec.adm_offer_dfrmnt_status ,
                                x_deferred_adm_cal_type         => c_upd_acai_new_rec.deferred_adm_cal_type,
                                x_deferred_adm_ci_sequence_num  => c_upd_acai_new_rec.deferred_adm_ci_sequence_num  ,
                                x_deferred_tracking_id          => c_upd_acai_new_rec.deferred_tracking_id ,
                                x_ass_rank                      => c_upd_acai_new_rec.ass_rank ,
                                x_secondary_ass_rank            => c_upd_acai_new_rec.secondary_ass_rank ,
                                x_intr_accept_advice_num        => c_upd_acai_new_rec.intrntnl_acceptance_advice_num  ,
                                x_ass_tracking_id               => c_upd_acai_new_rec.ass_tracking_id ,
                                x_fee_cat                       => c_upd_acai_new_rec.fee_cat ,
                                x_hecs_payment_option           => c_upd_acai_new_rec.hecs_payment_option ,
                                x_expected_completion_yr        => c_upd_acai_new_rec.expected_completion_yr ,
                                x_expected_completion_perd      => c_upd_acai_new_rec.expected_completion_perd ,
                                x_correspondence_cat            => c_upd_acai_new_rec.correspondence_cat ,
                                x_enrolment_cat                 => c_upd_acai_new_rec.enrolment_cat ,
                                x_funding_source                => c_upd_acai_old_rec.funding_source ,
                                x_applicant_acptnce_cndtn       => c_upd_acai_new_rec.applicant_acptnce_cndtn ,
                                x_cndtnl_offer_cndtn            => c_upd_acai_new_rec.cndtnl_offer_cndtn ,
                                x_ss_application_id            => c_upd_acai_new_rec.ss_application_id,
                                x_ss_pwd                       => c_upd_acai_new_rec.ss_pwd,
                                x_authorized_dt                => c_upd_acai_new_rec.authorized_dt,
                                x_authorizing_pers_id          => c_upd_acai_new_rec.authorizing_pers_id ,
                                x_idx_calc_date                => c_upd_acai_new_rec.idx_calc_date,
                                x_mode                          => 'R',
                                x_fut_acad_cal_type             => c_upd_acai_new_rec.future_acad_cal_type,
                                x_fut_acad_ci_sequence_number   => c_upd_acai_new_rec.future_acad_ci_sequence_number,
                                x_fut_adm_cal_type              => c_upd_acai_new_rec.future_adm_cal_type,
                                x_fut_adm_ci_sequence_number    => c_upd_acai_new_rec.future_adm_ci_sequence_number  ,
                                x_prev_term_adm_appl_number     => c_upd_acai_new_rec.previous_term_adm_appl_number,
                                x_prev_term_sequence_number     => c_upd_acai_new_rec.previous_term_sequence_number,
                                x_fut_term_adm_appl_number      => c_upd_acai_new_rec.future_term_adm_appl_number,
                                x_fut_term_sequence_number      => c_upd_acai_new_rec.future_term_sequence_number,
				X_DEF_ACAD_CAL_TYPE                                        => c_upd_acai_new_rec.DEF_ACAD_CAL_TYPE, --Bug 2395510
			        X_DEF_ACAD_CI_SEQUENCE_NUM                   => c_upd_acai_new_rec.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
				X_DEF_PREV_TERM_ADM_APPL_NUM           => c_upd_acai_new_rec.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
		                X_DEF_PREV_APPL_SEQUENCE_NUM              => c_upd_acai_new_rec.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
			        X_DEF_TERM_ADM_APPL_NUM                        => c_upd_acai_new_rec.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
				X_DEF_APPL_SEQUENCE_NUM                           => c_upd_acai_new_rec.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
 		        -- Added entry Status, entry level and school applying id and fin aid columns here for Bug 2631918
 		        -- by rrengara on 3-DEC-2002
				x_entry_status                  => c_upd_acai_old_rec.entry_status,
				x_entry_level                   => c_upd_acai_old_rec.entry_level,
				x_sch_apl_to_id                 => c_upd_acai_old_rec.sch_apl_to_id,
				x_apply_for_finaid              => c_upd_acai_old_rec.apply_for_finaid,
				x_finaid_apply_date             => c_upd_acai_old_rec.finaid_apply_date,
				x_appl_inst_status		=> c_upd_acai_old_rec.appl_inst_status,
				x_ais_reason			=> c_upd_acai_old_rec.ais_reason,
				x_decline_ofr_reason		=> c_upd_acai_old_rec.decline_ofr_reason
				);

              -- Also update the future application number in the old application number for link
              Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
                                x_rowid                         => c_upd_acai_old_rec.row_id ,
                                x_person_id                     => c_upd_acai_old_rec.person_id ,
                                x_admission_appl_number         => c_upd_acai_old_rec.admission_appl_number ,
                                x_nominated_course_cd           => c_upd_acai_old_rec.nominated_course_cd ,
                                x_sequence_number               => c_upd_acai_old_rec.sequence_number ,
                                x_predicted_gpa                 => c_upd_acai_old_rec.predicted_gpa ,
                                x_academic_index                => c_upd_acai_old_rec.academic_index,
                                x_adm_cal_type                  => c_upd_acai_old_rec.adm_cal_type ,
                                x_app_file_location             => c_upd_acai_old_rec.app_file_location ,
                                x_adm_ci_sequence_number        => c_upd_acai_old_rec.adm_ci_sequence_number ,
                                x_course_cd                     => c_upd_acai_old_rec.course_cd ,
                                x_app_source_id                 => c_upd_acai_old_rec.app_source_id ,
                                x_crv_version_number            => c_upd_acai_old_rec.crv_version_number ,
                                x_waitlist_rank                 => c_upd_acai_old_rec.waitlist_rank,
                                x_waitlist_status               => c_upd_acai_old_rec.waitlist_status,
                                x_location_cd                   => c_upd_acai_old_rec.location_cd ,
                                x_attent_other_inst_cd          => c_upd_acai_old_rec.attent_other_inst_cd,
                                x_attendance_mode               => c_upd_acai_old_rec.attendance_mode ,
                                x_edu_goal_prior_enroll_id      => c_upd_acai_old_rec.edu_goal_prior_enroll_id,
                                x_attendance_type               => c_upd_acai_old_rec.attendance_type ,
                                x_decision_make_id              => c_upd_acai_old_rec.decision_make_id,
                                x_unit_set_cd                   => c_upd_acai_old_rec.unit_set_cd ,
                                x_decision_date                 => TRUNC(SYSDATE),--c_upd_acai_old_rec.decision_date,
                                x_attribute_category            => c_upd_acai_old_rec.attribute_category,
                                x_attribute1                    => c_upd_acai_old_rec.attribute1,
                                x_attribute2                    => c_upd_acai_old_rec.attribute2,
                                x_attribute3                    => c_upd_acai_old_rec.attribute3,
                                x_attribute4                    => c_upd_acai_old_rec.attribute4,
                                x_attribute5                    => c_upd_acai_old_rec.attribute5,
                                x_attribute6                    => c_upd_acai_old_rec.attribute6,
                                x_attribute7                    => c_upd_acai_old_rec.attribute7,
                                x_attribute8                    => c_upd_acai_old_rec.attribute8,
                                x_attribute9                    => c_upd_acai_old_rec.attribute9,
                                x_attribute10                   => c_upd_acai_old_rec.attribute10,
                                x_attribute11                   => c_upd_acai_old_rec.attribute11,
                                x_attribute12                   => c_upd_acai_old_rec.attribute12,
                                x_attribute13                   => c_upd_acai_old_rec.attribute13,
                                x_attribute14                   => c_upd_acai_old_rec.attribute14,
                                x_attribute15                   => c_upd_acai_old_rec.attribute15,
                                x_attribute16                   => c_upd_acai_old_rec.attribute16,
                                x_attribute17                   => c_upd_acai_old_rec.attribute17,
                                x_attribute18                   => c_upd_acai_old_rec.attribute18,
                                x_attribute19                   => c_upd_acai_old_rec.attribute19,
                                x_attribute20                   => c_upd_acai_old_rec.attribute20,
                                x_decision_reason_id            => c_upd_acai_old_rec.decision_reason_id,
                                x_us_version_number             => c_upd_acai_old_rec.us_version_number ,
                                x_decision_notes                => c_upd_acai_old_rec.decision_notes,
                                x_pending_reason_id             => c_upd_acai_old_rec.pending_reason_id,
                                x_preference_number             => c_upd_acai_old_rec.preference_number ,
                                x_adm_doc_status                => c_upd_acai_old_rec.adm_doc_status ,   -- updating doc status
                                x_adm_entry_qual_status         => c_upd_acai_old_rec.adm_entry_qual_status,  -- updating entry qualification status
                                x_deficiency_in_prep            => c_upd_acai_old_rec.deficiency_in_prep ,
                                x_late_adm_fee_status           => c_upd_acai_old_rec.late_adm_fee_status ,
                                x_spl_consider_comments         => c_upd_acai_old_rec.spl_consider_comments,
                                x_adm_outcome_status            => IGS_AD_GEN_009.ADMP_GET_SYS_AOS('CANCELLED'),
                                x_adm_otcm_stat_auth_per_id     => c_upd_acai_old_rec.adm_otcm_status_auth_person_id,
                                x_adm_outcome_status_auth_dt    => c_upd_acai_old_rec.adm_outcome_status_auth_dt,
                                x_adm_outcome_status_reason     => c_upd_acai_old_rec.adm_outcome_status_reason,
                                x_offer_dt                      => c_upd_acai_old_rec.offer_dt,
                                x_offer_response_dt             => c_upd_acai_old_rec.offer_response_dt,
                                x_prpsd_commencement_dt         => c_upd_acai_old_rec.prpsd_commencement_dt,
                                x_adm_cndtnl_offer_status       => c_upd_acai_old_rec.adm_cndtnl_offer_status,
                                x_cndtnl_offer_satisfied_dt     => c_upd_acai_old_rec.cndtnl_offer_satisfied_dt,
                                x_cndnl_ofr_must_be_stsfd_ind   => c_upd_acai_old_rec.cndtnl_offer_must_be_stsfd_ind,
                                x_adm_offer_resp_status         => c_upd_acai_old_rec.adm_offer_resp_status,
                                x_actual_response_dt            => c_upd_acai_old_rec.actual_response_dt,
                                x_adm_offer_dfrmnt_status       => c_upd_acai_old_rec.adm_offer_dfrmnt_status ,
                                x_deferred_adm_cal_type         => c_upd_acai_old_rec.deferred_adm_cal_type,
                                x_deferred_adm_ci_sequence_num  => c_upd_acai_old_rec.deferred_adm_ci_sequence_num  ,
                                x_deferred_tracking_id          => c_upd_acai_old_rec.deferred_tracking_id ,
                                x_ass_rank                      => c_upd_acai_old_rec.ass_rank ,
                                x_secondary_ass_rank            => c_upd_acai_old_rec.secondary_ass_rank ,
                                x_intr_accept_advice_num        => c_upd_acai_old_rec.intrntnl_acceptance_advice_num  ,
                                x_ass_tracking_id               => c_upd_acai_old_rec.ass_tracking_id ,
                                x_fee_cat                       => c_upd_acai_old_rec.fee_cat ,
                                x_hecs_payment_option           => c_upd_acai_old_rec.hecs_payment_option ,
                                x_expected_completion_yr        => c_upd_acai_old_rec.expected_completion_yr ,
                                x_expected_completion_perd      => c_upd_acai_old_rec.expected_completion_perd ,
                                x_correspondence_cat            => c_upd_acai_old_rec.correspondence_cat ,
                                x_enrolment_cat                 => c_upd_acai_old_rec.enrolment_cat ,
                                x_funding_source                => c_upd_acai_old_rec.funding_source ,
                                x_applicant_acptnce_cndtn       => c_upd_acai_old_rec.applicant_acptnce_cndtn ,
                                x_cndtnl_offer_cndtn            => c_upd_acai_old_rec.cndtnl_offer_cndtn ,
                                x_ss_application_id            => c_upd_acai_old_rec.ss_application_id,
                                x_ss_pwd                       => c_upd_acai_old_rec.ss_pwd,
                                x_authorized_dt                => c_upd_acai_old_rec.authorized_dt,
                                x_authorizing_pers_id          => c_upd_acai_old_rec.authorizing_pers_id ,
                                x_idx_calc_date                => c_upd_acai_old_rec.idx_calc_date,
                                x_mode                          => 'R',
                                x_fut_acad_cal_type             => c_upd_acai_old_rec.future_acad_cal_type,
                                x_fut_acad_ci_sequence_number   => c_upd_acai_old_rec.future_acad_ci_sequence_number,
                                x_fut_adm_cal_type              => c_upd_acai_old_rec.future_adm_cal_type,
                                x_fut_adm_ci_sequence_number    => c_upd_acai_old_rec.future_adm_ci_sequence_number  ,
                                x_prev_term_adm_appl_number     => c_upd_acai_old_rec.previous_term_adm_appl_number,
                                x_prev_term_sequence_number     => c_upd_acai_old_rec.previous_term_sequence_number,
                                x_fut_term_adm_appl_number      => p_new_admission_appl_number,
                                x_fut_term_sequence_number      => p_new_sequence_number,
		                X_DEF_ACAD_CAL_TYPE                                        => c_upd_acai_old_rec.DEF_ACAD_CAL_TYPE, --Bug 2395510
				X_DEF_ACAD_CI_SEQUENCE_NUM                   => c_upd_acai_old_rec.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
		                X_DEF_PREV_TERM_ADM_APPL_NUM           => c_upd_acai_old_rec.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
				X_DEF_PREV_APPL_SEQUENCE_NUM              => c_upd_acai_old_rec.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
		                X_DEF_TERM_ADM_APPL_NUM                        => c_upd_acai_old_rec.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
				X_DEF_APPL_SEQUENCE_NUM                           => c_upd_acai_old_rec.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
			-- Added entry Status, entry level and school applying id and fin aid columns here for Bug 2631918
		        -- by rrengara on 3-DEC-2002
				x_entry_status                  => c_upd_acai_old_rec.entry_status,
				x_entry_level                   => c_upd_acai_old_rec.entry_level,
				x_sch_apl_to_id                 => c_upd_acai_old_rec.sch_apl_to_id,
				x_apply_for_finaid              => c_upd_acai_old_rec.apply_for_finaid,
				x_finaid_apply_date             => c_upd_acai_old_rec.finaid_apply_date,
				x_appl_inst_status		=> c_upd_acai_old_rec.appl_inst_status,
				x_ais_reason			=> c_upd_acai_old_rec.ais_reason,
				x_decline_ofr_reason		=> c_upd_acai_old_rec.decline_ofr_reason
);

    END LOOP;
  END LOOP;
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.log, SQLERRM);
  RETURN FALSE;
END copy_entrycomp_qual_status;


END igs_ad_val_acai_ftr_offer;

/
