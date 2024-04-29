--------------------------------------------------------
--  DDL for Package Body IGS_AS_CGR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_CGR_WF_PKG" AS
/* $Header: IGSAS54B.pls 120.1 2006/07/11 07:04:11 sepalani noship $ */

/* ***********************************************************************************************************/
  -- Procedure : Select_Approver
  --This Procedure relates to selecting an Approver (Admin or Lead Instructor), to whom this
  --Notification of Change Grade Request Submission has to be sent. This notification requires a
  --response from  Approver/ Admin/ Lead Instructor ( who ever is it, based upon the Organization
  --hierarchy set by the  Institute or Organization). Approver can Reject OR Approve the
  --notification OR ask for More Information.
/* **********************************************************************************************************/
  PROCEDURE select_approver (
    itemtype                       IN     VARCHAR2,
    itemkey                        IN     VARCHAR2,
    actid                          IN     NUMBER,
    funcmode                       IN     VARCHAR2,
    resultout                      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2 (30) := 'Select_Approver';
    l_return_status     VARCHAR2 (1);
    l_uoo_id            NUMBER (7) := wf_engine.getitemattrtext (
                                        itemtype,
                                        itemkey,
                                        'UOO_ID'
                                      );
    l_requester_id      NUMBER (15) := wf_engine.getitemattrtext (
                                         itemtype,
                                         itemkey,
                                         'REQUESTER_ID'
                                       );
    l_instructor_id     igs_ps_usec_tch_resp.instructor_id%TYPE;
    l_user_name_app     fnd_user.user_name%TYPE;
    l_user_name_req     fnd_user.user_name%TYPE;
    CURSOR cur_user (lv_requester_id fnd_user.person_party_id%TYPE) IS
      SELECT user_name
      FROM   fnd_user
      WHERE  person_party_id = lv_requester_id;
    CURSOR cur_instruct (lv_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
      SELECT instructor_id
      FROM   igs_ps_usec_tch_resp
      WHERE  lead_instructor_flag = 'Y'
      AND    uoo_id = lv_uoo_id;
    CURSOR cur_user1 (lv_instructor_id fnd_user.person_party_id%TYPE) IS
      SELECT user_name
      FROM   fnd_user
      WHERE  person_party_id = lv_instructor_id;
  BEGIN
    SAVEPOINT select_approver;
    IF (funcmode = 'RUN') THEN
      /* Requester User Name */
      BEGIN
        OPEN cur_user (l_requester_id);
        FETCH cur_user INTO l_user_name_req;
        CLOSE cur_user;
        wf_engine.setitemattrtext (itemtype, itemkey, 'REQUESTER_USER_NAME', l_user_name_req);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          resultout := 'FAILURE';
          RETURN;
      END;
      /* Finding Lead Instructor and corresponding User Name */
      BEGIN
        OPEN cur_instruct (l_uoo_id);
        FETCH cur_instruct INTO l_instructor_id;
        CLOSE cur_instruct;
        wf_engine.setitemattrtext (itemtype, itemkey, 'TO_USER_ID', l_instructor_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          resultout := 'FAILURE';
          RETURN;
      END;
      /* Approver User Name */
      BEGIN
        OPEN cur_user1 (l_instructor_id);
        FETCH cur_user1 INTO l_user_name_app;
        CLOSE cur_user1;
        wf_engine.setitemattrtext (itemtype, itemkey, 'TO_USER', l_user_name_app);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          resultout := 'FAILURE';
          RETURN;
      END;
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      /* ########################################################################
      Consulting Solution : Organizations / Institutions will set their organization's hierarchy, to
      whom this notification has to be sent .
      ######################################################################## */
      resultout := 'SUCCESS';
      RETURN;
    END IF;
    IF (funcmode = 'CANCEL') THEN
      resultout := 'FAILURE';
      RETURN;
    END IF;
    IF (funcmode NOT IN ('RUN', 'CANCEL')) THEN
      resultout := 'FAILURE';
      RETURN;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --If execution error, rollback all database changes, generate message text
      --and return failure status to the WF
      ROLLBACK TO select_approver;
      resultout := 'FAILURE';
      RETURN;
    WHEN NO_DATA_FOUND THEN
      resultout := 'FAILURE';
      RETURN;
    WHEN OTHERS THEN
      RAISE;
  END select_approver;

  PROCEDURE approve_request (
    itemtype                       IN     VARCHAR2,
    itemkey                        IN     VARCHAR2,
    actid                          IN     NUMBER,
    funcmode                       IN     VARCHAR2,
    resultout                      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name        CONSTANT VARCHAR2 (30)                    := 'Approve_Request';
    l_return_status            VARCHAR2 (1);
    l_rowid                    VARCHAR2 (25);
    l_org_id                   igs_as_su_stmptout.org_id%TYPE;
    l_person_id                NUMBER (15)                     := wf_engine.getitemattrtext (
                                                                    itemtype,
                                                                    itemkey,
                                                                    'PERSON_ID'
                                                                  );
    l_unit_code                VARCHAR2 (10)                   := wf_engine.getitemattrtext (
                                                                    itemtype,
                                                                    itemkey,
                                                                    'UNIT_CODE'
                                                                  );
    l_course_cd                VARCHAR2 (6)                    := wf_engine.getitemattrtext (
                                                                    itemtype,
                                                                    itemkey,
                                                                    'COURSE_CD'
                                                                  );
    l_cal_type                 VARCHAR2 (10)                    := wf_engine.getitemattrtext (
                                                                     itemtype,
                                                                     itemkey,
                                                                     'CAL_TYPE'
                                                                   );
    l_ci_sequence_number       NUMBER (6)             := wf_engine.getitemattrtext (
                                                           itemtype,
                                                           itemkey,
                                                           'CI_SEQUENCE_NUMBER'
                                                         );
    l_ci_start_dt              DATE                          := wf_engine.getitemattrtext (
                                                                  itemtype,
                                                                  itemkey,
                                                                  'CI_START_DT'
                                                                );
    l_ci_end_dt                DATE                            := wf_engine.getitemattrtext (
                                                                    itemtype,
                                                                    itemkey,
                                                                    'CI_END_DT'
                                                                  );
    l_grading_schema           VARCHAR2 (10)              := wf_engine.getitemattrtext (
                                                               itemtype,
                                                               itemkey,
                                                               'GRADING_SCHEMA'
                                                             );
    l_change_grade_version_num NUMBER (6)       := wf_engine.getitemattrtext (
                                                     itemtype,
                                                     itemkey,
                                                     'CHANGE_GRADE_VERSION_NUM'
                                                   );
    l_change_grade             VARCHAR2 (5)                 := wf_engine.getitemattrtext (
                                                                 itemtype,
                                                                 itemkey,
                                                                 'CHANGE_GRADE'
                                                               );
    l_change_mark              NUMBER (6, 3)                 := wf_engine.getitemattrtext (
                                                                  itemtype,
                                                                  itemkey,
                                                                  'CHANGE_MARK'
                                                                );
    l_teach_cal_type           VARCHAR2 (10)              := wf_engine.getitemattrtext (
                                                               itemtype,
                                                               itemkey,
                                                               'TEACH_CAL_TYPE'
                                                             );
    l_teach_ci_sequence_number NUMBER (6)       := wf_engine.getitemattrtext (
                                                     itemtype,
                                                     itemkey,
                                                     'TEACH_CI_SEQUENCE_NUMBER'
                                                   );
    l_request_date             DATE                         := wf_engine.getitemattrtext (
                                                                 itemtype,
                                                                 itemkey,
                                                                 'REQUEST_DATE'
                                                               );
    l_uoo_id                   NUMBER (7)                       := wf_engine.getitemattrtext (
                                                                     itemtype,
                                                                     itemkey,
                                                                     'UOO_ID'
                                                                   );
    l_grading_period_cd        VARCHAR2 (30)           := wf_engine.getitemattrtext (
                                                            itemtype,
                                                            itemkey,
                                                            'GRADING_PERIOD_CD'
                                                          );
    l_approver_id              NUMBER (15)                    := wf_engine.getitemattrtext (
                                                                   itemtype,
                                                                   itemkey,
                                                                   'TO_USER_ID'
                                                                 );
    l_comment                  VARCHAR2 (360)                   := wf_engine.getitemattrtext (
                                                                     itemtype,
                                                                     itemkey,
                                                                     'WF_NOTE'
                                                                   );
    l_sysdate                  DATE;
  BEGIN
    SAVEPOINT approve_request;
    IF (l_grading_period_cd = 'EARLY_FINAL') THEN
        l_grading_period_cd := 'FINAL';
    END IF;

    IF (funcmode = 'RUN') THEN
      l_sysdate := SYSDATE;
      /**************************Updating Change Grade Request Table *************************/
      UPDATE igs_as_chn_grd_req
         SET current_status = 'APPROVED',
             approver_id = l_approver_id,
             approver_date = l_sysdate,
             approver_comments = l_comment
       WHERE person_id = l_person_id
       AND   course_cd = l_course_cd
       AND   uoo_id = l_uoo_id
       AND   current_status = 'IN PROGRESS';
      /***************** Inserting Record in Student Unit Attempt Outcome Table**************/
      igs_as_su_stmptout_pkg.insert_row (
        x_rowid                        => l_rowid,
        x_org_id                       => NULL,
        x_person_id                    => l_person_id,
        x_course_cd                    => l_course_cd,
        x_unit_cd                      => l_unit_code,
        x_cal_type                     => l_teach_cal_type,
        x_ci_sequence_number           => l_teach_ci_sequence_number,
        x_outcome_dt                   => l_sysdate,
        x_ci_start_dt                  => l_ci_start_dt,
        x_ci_end_dt                    => l_ci_end_dt,
        x_grading_schema_cd            => l_grading_schema,
        x_version_number               => l_change_grade_version_num,
        x_grade                        => l_change_grade,
        x_s_grade_creation_method_type => 'KEYED',
        x_finalised_outcome_ind        => 'N',
        x_mark                         => l_change_mark,
        x_number_times_keyed           => NULL,
        x_translated_grading_schema_cd => NULL,
        x_translated_version_number    => NULL,
        x_translated_grade             => NULL,
        x_translated_dt                => NULL,
        x_mode                         => 'R',
        x_grading_period_cd            => l_grading_period_cd,
        x_attribute_category           => NULL,
        x_attribute1                   => NULL,
        x_attribute2                   => NULL,
        x_attribute3                   => NULL,
        x_attribute4                   => NULL,
        x_attribute5                   => NULL,
        x_attribute6                   => NULL,
        x_attribute7                   => NULL,
        x_attribute8                   => NULL,
        x_attribute9                   => NULL,
        x_attribute10                  => NULL,
        x_attribute11                  => NULL,
        x_attribute12                  => NULL,
        x_attribute13                  => NULL,
        x_attribute14                  => NULL,
        x_attribute15                  => NULL,
        x_attribute16                  => NULL,
        x_attribute17                  => NULL,
        x_attribute18                  => NULL,
        x_attribute19                  => NULL,
        x_attribute20                  => NULL,
        x_incomp_deadline_date         => NULL,
        x_incomp_grading_schema_cd     => NULL,
        x_incomp_version_number        => NULL,
        x_incomp_default_grade         => NULL,
        x_incomp_default_mark          => NULL,
        x_comments                     => NULL,
        x_uoo_id                       => l_uoo_id,
        x_mark_capped_flag             => 'N',
        x_release_date                 => NULL,
        x_manual_override_flag         => 'N',
        x_show_on_academic_histry_flag => 'Y'
      );
      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      /****************** Start :  Repeat Process / Translation / Finalization Process ***********/
      igs_as_finalize_grade.finalize_process (
        l_uoo_id,
        l_person_id,
        l_course_cd,
        l_unit_code,
        l_teach_cal_type,
        l_teach_ci_sequence_number
      );
      /***************** End : Repeat Process / Translation / Finalization Process *************/
      resultout := 'Y';
      RETURN;
    END IF;
    IF (funcmode = 'CANCEL') THEN
      resultout := 'N';
      RETURN;
    END IF;
    IF (funcmode NOT IN ('RUN', 'CANCEL')) THEN
      resultout := 'N';
      RETURN;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --If execution error, rollback all database changes, generate message text
      --and return failure status to the WF
      ROLLBACK TO approve_request;
      resultout := 'N';
      RETURN;
    WHEN OTHERS THEN
      RAISE;
  END approve_request;

  PROCEDURE reject_request (
    itemtype                       IN     VARCHAR2,
    itemkey                        IN     VARCHAR2,
    actid                          IN     NUMBER,
    funcmode                       IN     VARCHAR2,
    resultout                      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name        CONSTANT VARCHAR2 (30)  := 'Reject_Request';
    l_return_status            VARCHAR2 (1);
    l_person_id                NUMBER (15)    := wf_engine.getitemattrtext (itemtype, itemkey, 'PERSON_ID');
    l_unit_code                VARCHAR2 (10)  := wf_engine.getitemattrtext (itemtype, itemkey, 'UNIT_CODE');
    l_course_cd                VARCHAR2 (6)   := wf_engine.getitemattrtext (itemtype, itemkey, 'COURSE_CD');
    l_teach_cal_type           VARCHAR2 (10)  := wf_engine.getitemattrtext (itemtype, itemkey, 'TEACH_CAL_TYPE');
    l_teach_ci_sequence_number NUMBER (6)     := wf_engine.getitemattrtext (
                                                   itemtype,
                                                   itemkey,
                                                   'TEACH_CI_SEQUENCE_NUMBER'
                                                 );
    l_request_date             DATE           := wf_engine.getitemattrtext (itemtype, itemkey, 'REQUEST_DATE');
    l_approver_id              NUMBER (15)    := wf_engine.getitemattrtext (itemtype, itemkey, 'TO_USER_ID');
    l_comment                  VARCHAR2 (360) := wf_engine.getitemattrtext (itemtype, itemkey, 'WF_NOTE');
    -- anilk, 22-Apr-2003, Bug# 2829262
    l_uoo_id                   NUMBER (7)     := wf_engine.getitemattrtext (itemtype, itemkey, 'UOO_ID');
  BEGIN
    SAVEPOINT reject_request;
    /**************************Start : Updating Change Grade Request Table *********************/
    UPDATE igs_as_chn_grd_req
       SET current_status = 'REJECTED',
           approver_id = l_approver_id,
           approver_date = SYSDATE,
           approver_comments = l_comment
     WHERE person_id = l_person_id
     AND   course_cd = l_course_cd
     AND   uoo_id = l_uoo_id
     AND   current_status = 'IN PROGRESS';
    /**************************End : Updating Change Grade Request Table *********************/
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --If execution error, rollback all database changes, generate message text
      --and return failure status to the WF
      ROLLBACK TO approve_request;
    WHEN OTHERS THEN
      RAISE;
  END reject_request;

  PROCEDURE need_information (
    itemtype                       IN     VARCHAR2,
    itemkey                        IN     VARCHAR2,
    actid                          IN     NUMBER,
    funcmode                       IN     VARCHAR2,
    resultout                      OUT NOCOPY VARCHAR2
  ) IS
    l_api_name        CONSTANT VARCHAR2 (30)  := 'Need_Information';
    l_return_status            VARCHAR2 (1);
    l_person_id                NUMBER (15)    := wf_engine.getitemattrtext (itemtype, itemkey, 'PERSON_ID');
    l_unit_code                VARCHAR2 (10)  := wf_engine.getitemattrtext (itemtype, itemkey, 'UNIT_CODE');
    l_course_cd                VARCHAR2 (6)   := wf_engine.getitemattrtext (itemtype, itemkey, 'COURSE_CD');
    l_teach_cal_type           VARCHAR2 (10)  := wf_engine.getitemattrtext (itemtype, itemkey, 'TEACH_CAL_TYPE');
    l_teach_ci_sequence_number NUMBER (6)     := wf_engine.getitemattrtext (
                                                   itemtype,
                                                   itemkey,
                                                   'TEACH_CI_SEQUENCE_NUMBER'
                                                 );
    l_request_date             DATE           := wf_engine.getitemattrtext (itemtype, itemkey, 'REQUEST_DATE');
    l_approver_id              NUMBER (15)    := wf_engine.getitemattrtext (itemtype, itemkey, 'TO_USER_ID');
    l_comment                  VARCHAR2 (360) := wf_engine.getitemattrtext (itemtype, itemkey, 'WF_NOTE');
    -- anilk, 22-Apr-2003, Bug# 2829262
    l_uoo_id                   NUMBER (7)     := wf_engine.getitemattrtext (itemtype, itemkey, 'UOO_ID');
  BEGIN
    SAVEPOINT need_information;
    /**************************Start : Updating Change Grade Request Table *************************/
    UPDATE igs_as_chn_grd_req
       SET current_status = 'NEED MORE INFO',
           approver_id = l_approver_id,
           approver_date = SYSDATE,
           approver_comments = l_comment
     WHERE person_id = l_person_id
     AND   course_cd = l_course_cd
     AND   uoo_id = l_uoo_id
     AND   current_status = 'IN PROGRESS';
    /**************************End : Updating Change Grade Request Table *************************/
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      --If execution error, rollback all database changes, generate message text
      --and return failure status to the WF
      ROLLBACK TO approve_request;
    WHEN OTHERS THEN
      RAISE;
  END need_information;
END igs_as_cgr_wf_pkg;

/
