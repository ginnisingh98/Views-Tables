--------------------------------------------------------
--  DDL for Package Body IGS_AS_PROD_DOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_PROD_DOC" AS
/* $Header: IGSAS49B.pls 120.1 2005/09/19 01:34:27 appldev ship $ */



FUNCTION get_hold_status (
    p_person_id NUMBER
  ) RETURN VARCHAR2 AS
  /*************************************************************
  Created By :Imran Jeddy
  Date Created on : 16-Feb-2004
  Purpose : This process is called by the BulkOrderVO to see if the student has a hold placed on him/her.
  Know limitations, enhancements or remarks
  CHANGE HISTORY
  Who        When          What
  (reverse chronological order - newest change first)
  ***************************************************************/
    -- Cursor to get the institution setup for documents.
    --
    CURSOR c_setup IS
      SELECT 'X'
      FROM   igs_as_docproc_stup
      WHERE trans_request_if_hold_ind = 'N';
    --
    -- Cursor to get the holds information for the student which has effect of blocking his transcript
    --
    CURSOR c_hold IS
      SELECT   'X'
      FROM     igs_pe_persenc_effct
      WHERE    person_id = p_person_id
      AND      s_encmb_effect_type IN ('TRANS_BLK','RVK_SRVC','SUS_SRVC','RESULT_BLK')
      AND      NVL (expiry_dt, SYSDATE) >= SYSDATE
      AND      pee_start_dt < SYSDATE
      ORDER BY pee_start_dt DESC;
    --
      l_var VARCHAR2(1);
    --
  BEGIN

    -- Setup allows a Transcript to be processed even if there is a hold.
    OPEN c_setup;
    FETCH c_setup INTO l_var;
    IF c_setup%FOUND THEN
      CLOSE c_setup;
      RETURN 'Y';
    END IF;
    CLOSE c_setup;

    --Check if there is a hold on the student
    OPEN c_hold ;
    FETCH c_hold INTO l_var;
    IF c_hold%FOUND THEN
      CLOSE c_hold;
      RETURN 'N';
    END IF;
    CLOSE c_hold;
    RETURN 'Y';
  END get_hold_status;






  PROCEDURE asp_chk_doc_rdns (
    p_item_number     IN   NUMBER,
    p_document_ready  OUT NOCOPY VARCHAR2,
    p_error_mesg      OUT NOCOPY VARCHAR2
  ) AS
  /*************************************************************
  Created By :Nalin Kumar
  Date Created on : 21-Aug-2002
  Purpose : This process is called by the report producing the documents to check the readiness for production of a document.
  Know limitations, enhancements or remarks
  CHANGE HISTORY
  Who        When          What
  anilk      22-Aug-2003   Fixed GSCC - Date conversion must use date format mask
  (reverse chronological order - newest change first)
  ***************************************************************/
    -- Constant declaration.
    cst_completed         CONSTANT VARCHAR2(20) := 'COMPLETED';
    cst_enrolled          CONSTANT VARCHAR2(20) := 'ENROLLED';
    cst_final             CONSTANT VARCHAR2(20) := 'FINAL';
    cst_in_progress       CONSTANT VARCHAR2(20) := 'IN PROGRESS';
    cst_trans_blk         CONSTANT VARCHAR2(20) := 'TRANS_BLK';
    cst_trans_blk1        CONSTANT VARCHAR2(20) := 'RVK_SRVC';
    cst_trans_blk2        CONSTANT VARCHAR2(20) := 'SUS_SRVC';
    cst_trans_blk3        CONSTANT VARCHAR2(20) := 'RESULT_BLK';

-- This cursor will select the information related to the given Item number.
    CURSOR cur_ord_itm_int IS
    SELECT missing_acad_record_data_ind,
      hold_release_of_final_grades,
      fgrade_cal_type,
      fgrade_seq_num,
      person_id,
      hold_for_grade_chg,
      creation_date,
      hold_degree_expected,
      programs_on_file
    FROM igs_as_ord_itm_int
    WHERE item_number = p_item_number;
    rec_cur_ord_itm_int cur_ord_itm_int%ROWTYPE;

    -- To determine if there exists a Transcript Hold for the student.
    CURSOR cur_hold_dlv_ind IS
    SELECT trans_request_if_hold_ind, hold_deliv_ind
    FROM igs_as_docproc_stup;
    rec_cur_hold_dlv_ind cur_hold_dlv_ind%ROWTYPE;

    -- To determine if the student has a pending transcript hold.
--ijeddy, bug 3410409.
    CURSOR cur_hold_eft (cp_person_id      igs_as_chn_grd_req.person_id%TYPE,
                         cp_creation_date  igs_as_ord_itm_int.creation_date%TYPE) IS
    SELECT 'X'
    FROM igs_pe_persenc_effct
    WHERE person_id = cp_person_id AND
      s_encmb_effect_type IN (cst_trans_blk,cst_trans_blk1,cst_trans_blk2,cst_trans_blk3) AND
      expiry_dt IS NULL AND
      TRUNC(pen_start_dt) <= TRUNC(cp_creation_date);
    rec_cur_hold_eft cur_hold_eft%ROWTYPE;

    -- Cursor to get the student unit attempts.
    CURSOR cur_en_su_att (cp_person_id igs_en_su_attempt.person_id%TYPE,
                          cp_cal_type  igs_en_su_attempt.cal_type%TYPE,
                          cp_ci_sequence_number igs_en_su_attempt.ci_sequence_number%TYPE) IS
    -- anilk, 22-Apr-2003, Bug# 2829262
    SELECT course_cd, unit_cd, uoo_id
    FROM igs_en_su_attempt
    WHERE person_id = cp_person_id AND
      unit_attempt_status IN (cst_completed,cst_enrolled) AND
      cal_type = cp_cal_type AND
      ci_sequence_number = cp_ci_sequence_number ;
    rec_cur_en_su_att cur_en_su_att%ROWTYPE;

    -- Cursor to check the finalised outcome for the student unit attempts.
    CURSOR cur_as_suaoa(cp_person_id          igs_en_su_attempt.person_id%TYPE,
                        cp_cal_type           igs_en_su_attempt.cal_type%TYPE,
                        cp_ci_sequence_number igs_en_su_attempt.ci_sequence_number%TYPE,
                        cp_course_cd          igs_en_su_attempt.course_cd%TYPE,
                        cp_unit_cd            igs_en_su_attempt.unit_cd%TYPE,
                        -- anilk, 22-Apr-2003, Bug# 2829262
			cp_uoo_id             igs_en_su_attempt.uoo_id%TYPE ) IS
    SELECT finalised_outcome_ind
    FROM igs_as_suaoa_v
    WHERE person_id = cp_person_id AND
      course_cd = cp_course_cd AND
      -- anilk, 22-Apr-2003, Bug# 2829262
      uoo_id = cp_uoo_id AND
      grading_period_cd = cst_final AND
      finalised_outcome_ind = 'Y';
    rec_cur_as_suaoa cur_as_suaoa%ROWTYPE;

    -- Cursor to check if the user has requested to 'Hold for Grade Change'.
    CURSOR cur_chn_grd_req (cp_person_id      igs_as_chn_grd_req.person_id%TYPE,
                            cp_creation_date  igs_as_ord_itm_int.creation_date%TYPE)IS
    SELECT 'X'
    FROM igs_as_chn_grd_req
    WHERE person_id  = cp_person_id AND
      current_status = cst_in_progress AND
      request_date < cp_creation_date;
    rec_cur_chn_grd_req cur_chn_grd_req%ROWTYPE;

    -- For Program centric Mode- Check if the program attempt status is 'COMPLETED' (for all the programs if program is not selected).
    CURSOR cur_ps_att (cp_person_id      igs_as_chn_grd_req.person_id%TYPE,
                       cp_creation_date  igs_as_ord_itm_int.creation_date%TYPE,
                       cp_course_cd      igs_en_sca_v.course_cd%TYPE)IS
    SELECT 'X'
    FROM igs_en_stdnt_ps_att_all
    WHERE person_id  = cp_person_id AND
      course_cd = NVL(cp_course_cd, course_cd) AND
      TRUNC(course_rqrmnts_complete_dt) BETWEEN TRUNC(igs_ge_date.igsdate(cp_creation_date)) AND TRUNC(SYSDATE);
    rec_cur_ps_att cur_ps_att%ROWTYPE;

    -- For Career centric Mode- Check if the program attempt status is 'COMPLETED' (under all the career if career is not selected).
    CURSOR cur_en_sca (cp_person_id      igs_as_chn_grd_req.person_id%TYPE,
                       cp_creation_date  igs_as_ord_itm_int.creation_date%TYPE,
                                   cp_course_type    igs_en_sca_v.course_type%TYPE)IS
    SELECT 'X'
    FROM igs_en_sca_v
    WHERE person_id  = cp_person_id AND
      course_type = NVL(cp_course_type, course_type) AND
      TRUNC(course_rqrmnts_complete_dt) BETWEEN TRUNC(igs_ge_date.igsdate(cp_creation_date)) AND TRUNC(SYSDATE);
    rec_cur_en_sca cur_en_sca%ROWTYPE;

    l_su_att_count NUMBER(10);
  BEGIN

    OPEN cur_ord_itm_int;
    FETCH cur_ord_itm_int INTO rec_cur_ord_itm_int;
    CLOSE cur_ord_itm_int;
    --
    -- 1. Check if the "Academic History is missing.
    --
    IF NVL(rec_cur_ord_itm_int.missing_acad_record_data_ind,'N') = 'Y' THEN
      p_document_ready := 'N';
      p_error_mesg := 'IGS_AS_MSNG_ACAD_HIST';
      RETURN;
    END IF;

    --
    -- 2. Determine if there exists a Transcript Hold for the student.
    --
    OPEN cur_hold_dlv_ind;
    FETCH cur_hold_dlv_ind INTO rec_cur_hold_dlv_ind;
    CLOSE cur_hold_dlv_ind;
--IJEDDY
    IF rec_cur_hold_dlv_ind.hold_deliv_ind = 'Y' OR
       rec_cur_hold_dlv_ind.trans_request_if_hold_ind = 'Y' THEN
      -- Determine if the student has a pending transcript hold.
      OPEN cur_hold_eft(rec_cur_ord_itm_int.person_id,
                  rec_cur_ord_itm_int.creation_date);
      FETCH cur_hold_eft INTO rec_cur_hold_eft;
      IF cur_hold_eft%FOUND THEN
        CLOSE cur_hold_eft;
        p_document_ready := 'N';
        p_error_mesg := 'IGS_AS_TRNS_BLK_EXISTS';
        RETURN;
      END IF;
      CLOSE cur_hold_eft;
    END IF;

    --
    -- 3. Determine if the document request specifies to "Hold for Final Grades" in a selected teaching period.
    --
    IF NVL(rec_cur_ord_itm_int.hold_release_of_final_grades,'N') = 'Y' THEN
      l_su_att_count := 0;
      p_error_mesg := NULL;
      FOR rec_cur_en_su_att IN cur_en_su_att(rec_cur_ord_itm_int.person_id,
                                                   rec_cur_ord_itm_int.fgrade_cal_type,
                                                               rec_cur_ord_itm_int.fgrade_seq_num) LOOP
              l_su_att_count := l_su_att_count + 1;
        OPEN cur_as_suaoa(rec_cur_ord_itm_int.person_id,
                          rec_cur_ord_itm_int.fgrade_cal_type,
                          rec_cur_ord_itm_int.fgrade_seq_num,
                          rec_cur_en_su_att.course_cd,
                          rec_cur_en_su_att.unit_cd,
                          -- anilk, 22-Apr-2003, Bug# 2829262
			  rec_cur_en_su_att.uoo_id );
        FETCH cur_as_suaoa INTO rec_cur_as_suaoa;
        IF cur_as_suaoa%NOTFOUND THEN
            CLOSE cur_as_suaoa;
          p_error_mesg := 'IGS_AS_GRD_NOT_FINAL';
          EXIT;
          END IF;
          CLOSE cur_as_suaoa;
      END LOOP;
        IF (l_su_att_count = 0 OR p_error_mesg IS NOT NULL) THEN
          p_document_ready := 'N';
          p_error_mesg := 'IGS_AS_GRD_NOT_FINAL';
          RETURN;
        END IF;
    END IF;

    --
    -- 4. Determine if the document request specifies to "Hold for Grade Change"
    --
    IF NVL(rec_cur_ord_itm_int.hold_for_grade_chg,'N') = 'Y' THEN
      OPEN cur_chn_grd_req(rec_cur_ord_itm_int.person_id,
                             rec_cur_ord_itm_int.creation_date);
      FETCH cur_chn_grd_req INTO rec_cur_chn_grd_req;
      IF cur_chn_grd_req%FOUND THEN
        CLOSE cur_chn_grd_req;
        p_document_ready := 'N';
        p_error_mesg := 'IGS_AS_GRD_CHG_HLD';
        RETURN;
      END IF;
      CLOSE cur_chn_grd_req;
    END IF;

    --
    -- 5. Determine if the document request specified to "Hold for Degree Award".
    --
    IF NVL(rec_cur_ord_itm_int.hold_degree_expected,'N') = 'Y' THEN
      IF rec_cur_ord_itm_int.programs_on_file = 'ALL' THEN
        IF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') <> 'Y' THEN
          OPEN cur_ps_att(rec_cur_ord_itm_int.person_id,
                              rec_cur_ord_itm_int.creation_date,
                              NULL /* To check for all Program Attempts*/);
          FETCH cur_ps_att INTO rec_cur_ps_att;
          IF cur_ps_att%NOTFOUND THEN
            CLOSE cur_ps_att;
            p_document_ready := 'N';
            p_error_mesg := 'IGS_AS_DEG_AWD_HLD';
            RETURN;
          END IF;
          CLOSE cur_ps_att;
      ELSIF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') = 'Y' THEN
          OPEN cur_en_sca(rec_cur_ord_itm_int.person_id,
                          rec_cur_ord_itm_int.creation_date,
                          NULL /* To check for all Careers*/);
          FETCH cur_en_sca INTO rec_cur_en_sca;
          IF cur_en_sca%NOTFOUND THEN
          CLOSE cur_en_sca;
            p_document_ready := 'N';
            p_error_mesg := 'IGS_AS_DEG_AWD_HLD';
            RETURN;
          END IF;
          CLOSE cur_en_sca;
        END IF;
      ELSE
        IF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') <> 'Y' THEN
          OPEN cur_ps_att(rec_cur_ord_itm_int.person_id,
                          rec_cur_ord_itm_int.creation_date,
                          rec_cur_ord_itm_int.programs_on_file);
          FETCH cur_ps_att INTO rec_cur_ps_att;
          IF cur_ps_att%NOTFOUND THEN
            CLOSE cur_ps_att;
            p_document_ready := 'N';
            p_error_mesg := 'IGS_AS_DEG_AWD_HLD';
            RETURN;
          END IF;
          CLOSE cur_ps_att;
        ELSIF FND_PROFILE.VALUE('CAREER_MODEL_ENABLED') = 'Y' THEN
          OPEN cur_en_sca(rec_cur_ord_itm_int.person_id,
                                rec_cur_ord_itm_int.creation_date,
                                rec_cur_ord_itm_int.programs_on_file);
          FETCH cur_en_sca INTO rec_cur_en_sca;
          IF cur_en_sca%NOTFOUND THEN
            CLOSE cur_en_sca;
            p_document_ready := 'N';
            p_error_mesg := 'IGS_AS_DEG_AWD_HLD';
            RETURN;
          END IF;
          CLOSE cur_en_sca;
        END IF;
      END IF;
    END IF;

    --
    -- If control reaches here means the document can be produced.
    --
    p_document_ready := 'Y';
    p_error_mesg := NULL;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_as_prod_doc.asp_chk_doc_rdns');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END asp_chk_doc_rdns;

  PROCEDURE notify_miss_acad_rec_prod (
    p_person_id                         IN     VARCHAR2,
    p_order_number                      IN     VARCHAR2,
    p_item_number                       IN     VARCHAR2,
    p_document_type                     IN     VARCHAR2,
    p_recipient_name                    IN     VARCHAR2,
    p_receiving_inst_name               IN     VARCHAR2,
    p_delivery_method                   IN     VARCHAR2,
    p_fulfillment_date_time             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 29-OCT-2002
  ||  Purpose : To send notification to the student informing him about the
  ||    manual production and delivery of Missing Academic Records document
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    --
    -- Cursor to get the user_name corresponding to the person_id
    --
    CURSOR c_user_name (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
           SELECT user_name
           FROM   fnd_user
           WHERE  person_party_id = cp_person_id;
    --
    -- Get a unique sequence number for use in raising the event
    --
    CURSOR c_seq_num IS
      SELECT   igs_as_wf_beas008_s.NEXTVAL
      FROM     dual;
    --
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             VARCHAR2(100);
    ln_seq_val            NUMBER;
    l_role_name           VARCHAR2(320);
    l_role_display_name   VARCHAR2(320) := 'Adhoc Role for IGSAS008';
    l_user_name           fnd_user.user_name%TYPE;
    --
  BEGIN
    --
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val;
    CLOSE c_seq_num;
    --
    -- initialize the wf_event_t object
    --
    wf_event_t.Initialize (l_event_t);
    -- Create the adhoc role
    l_role_name := 'IGSAS008' || ln_seq_val;
    --
    -- Create adhoc role
    --
    Wf_Directory.CreateAdHocRole (
      role_name         => l_role_name,
      role_display_name => l_role_display_name
    );
    --
    -- Add the user name to the adhoc role
    --
    OPEN c_user_name (p_person_id);
        FETCH c_user_name INTO l_user_name;
    CLOSE c_user_name;
    --
    IF (l_user_name IS NOT NULL) THEN
      Wf_Directory.AddUsersToAdHocRole (
        role_name  => l_role_name,
        role_users => l_user_name
      );
    END IF;
    --
    -- Add the parameters to the parameter list
    --
    wf_event.AddParameterToList ( p_name => 'IA_PERSON_ID', p_value => p_person_id, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_ORDER_NUMBER', p_value => p_order_number, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_DOCUMENT_NUMBER', p_value => p_item_number, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_DOCUMENT_TYPE', p_value => p_document_type, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_RECIPIENT_NAME', p_value => p_recipient_name, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_RECEIVING_INST_NAME', p_value => p_receiving_inst_name, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_DELIVERY_METHOD', p_value => p_delivery_method, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_FULFILLMENT_DATE_TIME', p_value => p_fulfillment_date_time, p_parameterlist => l_parameter_list_t);
    wf_event.AddParameterToList ( p_name => 'IA_ADHOCROLE', p_value => l_role_name, p_parameterlist => l_parameter_list_t);
    --
    -- Raise the Event
    --
    wf_event.raise (
       p_event_name => 'oracle.apps.igs.as.orddoc.notstu',
       p_event_key  => 'AS008' || ln_seq_val,
       p_parameters => l_parameter_list_t
    );
    --
    -- Delete the Parameter list after the event is raised
    --
    l_parameter_list_t.delete;
    --
  END notify_miss_acad_rec_prod;


PROCEDURE wf_launch_as004 (
  p_user          IN VARCHAR2,
  p_date_produced IN VARCHAR2,
  p_doc_type      IN VARCHAR2
) AS
  /******************************************************************
   Created By         : Sameer Manglm
   Date Created By    : 22-AUG-2002
   Purpose            : This procedure will be used for launching
                        the workflow process.
   remarks            : pass p_date_produced in form canonical date
                        format like YYYY/MM/DD HH24:MI:SS
                        and p_doc_type as meaning of lookup_code
   Change History
   Who      When        What
  ******************************************************************/

    lv_item_type       VARCHAR2(100) :='IGSAS004' ;
    ln_seq_val          NUMBER;

    -- Gets a unique sequence number
    CURSOR
          c_seq_num
     IS
          SELECT
                 igs_as_wf_beas004_s.NEXTVAL
          FROM
                dual;
  BEGIN

    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;

    -- Create the process
    Wf_Engine.createprocess( ItemType =>  lv_item_type,
                             ItemKey =>   'AS004'||ln_seq_val,
                             process =>   'P_AS004'
                            );
   -- Attach the item attribute IA_USER_ROLE
   Wf_Engine.SetItemAttrText( ItemType =>  lv_item_type,
                               ItemKey  =>  'AS004'||ln_seq_val,
                               aname    =>  'IA_USERROLE',
                               avalue   =>  p_user
                              );

  -- Attach the item attribute IA_USER_NAME
  Wf_Engine.SetItemAttrText(  ItemType  =>  lv_item_type,
                               ItemKey  =>   'AS004'||ln_seq_val,
                               aname    =>   'IA_USERNAME',
                               avalue   =>   p_user
                             );

   -- Pass the work flow event key
  Wf_Engine.SetItemAttrText( ItemType  =>  lv_item_type,
                              ItemKey   =>  'AS004'||ln_seq_val,
                              aname     =>  'IA_EVENT_KEY',
                              avalue    =>  'BEAS004'||ln_seq_val
                            );

   -- Pass the date of production
  Wf_Engine.SetItemAttrText( ItemType  =>  lv_item_type,
                              ItemKey   =>  'AS004'||ln_seq_val,
                              aname     =>  'EA_DATE_PRODUCED',
                              avalue    =>  p_date_produced
                            );
   -- Pass the date of production
  Wf_Engine.SetItemAttrText( ItemType  =>  lv_item_type,
                              ItemKey   =>  'AS004'||ln_seq_val,
                              aname     =>  'EA_DOC_TYPE',
                              avalue    =>  p_doc_type
                            );

  -- Start the doc type
  Wf_Engine.StartProcess   ( ItemType  =>  lv_item_type,
                             ItemKey   =>  'AS004'||ln_seq_val
                          );

   -- Handle the exception using WF_CORE.Context
  EXCEPTION

  WHEN OTHERS THEN
    Wf_Core.Context('IGS_AS_PROD_DOC', 'WF_LAUNCH_AS004', lv_item_type, 'AS004'||ln_seq_val,'P_AS004');
    RAISE;

END wf_launch_as004;

  PROCEDURE wf_set_role (
    itemtype    IN  VARCHAR2,
    itemkey     IN  VARCHAR2,
    actid       IN  NUMBER,
    funcmode    IN  VARCHAR2,
    resultout   OUT NOCOPY VARCHAR2
  ) AS
  /******************************************************************
   Created By         : Sameer Manglm
   Date Created By    : 22-AUG-2002
   Purpose            : This workflow procedure is a wrapper procedure,
                        which will be called from the workflow builder
                        IGSAS005. This would set the adhoc role for the
                        notification
   Remarks            :
   Change History
   Who      When        What
  ******************************************************************/
  --
  -- Cursor to get details from Order Item Interface table
  --
  CURSOR c_person_id (cp_date_produced IN VARCHAR2) IS
    SELECT aoii.order_number order_number,
           aoii.item_number item_number,
           aoii.person_id   person_id
    FROM   igs_as_ord_itm_int aoii
    WHERE  fnd_date.date_to_canonical(aoii.date_produced) = cp_date_produced
    AND    aoii.item_status = 'PROCESSED';
  --
  -- Cursor to get the oracle applications user_name corresponding to the person_id
  --
  CURSOR c_user_name (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
    SELECT user_name
    FROM   fnd_user
    WHERE  person_party_id = cp_person_id;
  --
  -- Cursor to check if the user_name being added to the Adhoc Role is already duplicated
  --
  CURSOR c_dup_user (cp_user_name VARCHAR2,
                     cp_role_name VARCHAR2) IS
    SELECT count(1)
    FROM WF_LOCAL_USER_ROLES
    WHERE USER_NAME = cp_user_name
    AND ROLE_NAME = cp_role_name
    AND ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
    AND ROLE_ORIG_SYSTEM_ID = 0;
  --
  -- Cursor to check if the user_name being added to the Adhoc Role is already duplicated
  --
  CURSOR cur_order_details (cp_order_number IN NUMBER) IS
    SELECT   request_type
    FROM     igs_as_order_hdr
    WHERE    order_number = cp_order_number;
  --
  l_date_prod            VARCHAR2(30);
  l_doc_type             VARCHAR2(30);
  l_role_name            VARCHAR2(320);
  l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSAS005';
  l_person_id   c_person_id%ROWTYPE;
  l_user_name   fnd_user.user_name%TYPE;
  l_dup_user NUMBER := 0;
  l_send_notification BOOLEAN := TRUE;
  rec_order_details cur_order_details%ROWTYPE;
  --
  BEGIN
    --
    IF (funcmode  = 'RUN') THEN

     -- create the adhoc role
     l_role_name := 'IGS'||substr(itemkey,6);
     Wf_Directory.CreateAdHocRole (role_name         => l_role_name,
                                   role_display_name => l_role_display_name
                                  );

     l_date_prod := Wf_Engine.GetItemAttrText(itemtype,itemkey,'EA_DATE_PRODUCED');
     l_doc_type  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'EA_DOC_TYPE');

     -- set the item attribute of the workflow with date produced
     Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                                ItemKey   =>  itemkey,
                                aname     =>  'IA_DATE_PROD',
                                avalue    =>  l_date_prod
                                  );
      -- set the  item attribute of the workflow with doc type
      Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_DOC_TYPE',
                                 avalue    =>  l_doc_type
                                );
     --
     -- fetch student for whom the record has been processed and add the user name to the adhoc role
     --
     OPEN c_person_id (l_date_prod);
     LOOP
        FETCH c_person_id INTO l_person_id;
        EXIT  WHEN c_person_id%NOTFOUND;
	l_send_notification := TRUE;
	OPEN cur_order_details (l_person_id.order_number);
	FETCH cur_order_details INTO rec_order_details;
	CLOSE cur_order_details;
	IF (rec_order_details.request_type = 'B') THEN
          --
          -- Add the user to the Role only when the User Hook returns a TRUE value
          --
	  l_send_notification := igs_as_user_hook.notify_bulk_doc_production (
                                   p_order_number                 => l_person_id.order_number,
                                   p_item_number                  => l_person_id.item_number,
                                   p_person_id                    => l_person_id.person_id
                                 );
        END IF;
        IF (l_send_notification) THEN
	  OPEN c_user_name (l_person_id.person_id);
          FETCH c_user_name INTO l_user_name;
          CLOSE c_user_name;
          --
          -- Add this user name to the adhoc role if it is not null and unique
          --
          OPEN c_dup_user(l_user_name,l_role_name);
          FETCH c_dup_user INTO l_dup_user;
          CLOSE c_dup_user;
          IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
             Wf_Directory.AddUsersToAdHocRole (
               role_name  => l_role_name,
               role_users => l_user_name
             );
          END IF;
        END IF;
     END LOOP;
     CLOSE c_person_id;
     -- now set this role to the workflow
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_ROLE',
                                 avalue    =>  l_role_name
                                );
     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;

  END wf_set_role;

  PROCEDURE asp_update_order_doc (
    p_item_number   IN NUMBER,
    p_test_mode     IN VARCHAR2
  ) AS
  /******************************************************************
   Created By         : Sameer Manglm
   Date Created By    : 22-AUG-2002
   Purpose            : Update Order Docs interface table with the item status
                        (IGS_AS_ORD_ITM_INT.ITEM_STATUS) to PROCESSED and
                        the line item status (IGS_AS_DOC_DETAILS.ITEM_STATUS)
                        to PROCESSED. Also if all the items are processed,
                        update the Order status (IGS_AS_ORDER_HDR.ORDER_STATUS)
                        to COMPLETED.
   Remarks            :
   Change History
   Who      When        What
  ******************************************************************/
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
  -- Cursor to check the existence of a record in Order Item Interface Table
  --
  CURSOR c_ord_itm_int (cp_item_number  igs_as_ord_itm_int.item_number%TYPE) IS
    SELECT 'x'
    FROM   igs_as_ord_itm_int aoii
    WHERE  aoii.item_number = cp_item_number;
  --
  -- Cursor to fetch the records from Order Item Interface Table.
  -- Discontinue automatic posting of Completion for documents having Missing Academic Records
  --
  CURSOR c_doc_details (cp_item_number igs_as_doc_details.item_number%TYPE) IS
    SELECT dd.rowid, dd.*
    FROM   igs_as_doc_details dd
    WHERE  dd.item_number = cp_item_number
    AND    NVL (missing_acad_record_data_ind, 'N') = 'N';
  --
  -- Cursor to fetch order number from IGS_AS_ORDER_HDR and update order status
  -- to COMPLETED if all the line items are PROCESSED
  --
  CURSOR c_order_hdr IS
    SELECT oh.rowid, oh.*
    FROM   igs_as_order_hdr oh
    WHERE  oh.order_status = 'INPROCESS'
    AND    NOT EXISTS (SELECT 'x'
                       FROM   igs_as_doc_details dd
                       WHERE  dd.order_number = oh.order_number
                       AND    dd.item_status  <> 'PROCESSED');
  --
  l_return_status                VARCHAR2(1);
  l_msg_data                     VARCHAR2(30);
  l_msg_count                    NUMBER;
  --
BEGIN
  --
  -- Update igs_as_ord_itm_int with item_status = PROCESSED and date_produced to sysdate
  -- Discontinue automatic posting of Completion for documents having Missing Academic Records
  --
  FOR rec_ord_itm_int IN c_ord_itm_int (p_item_number)
  LOOP
    UPDATE igs_as_ord_itm_int
    SET    item_status = 'PROCESSED',
           date_produced = SYSDATE
    WHERE  item_number = p_item_number
    AND    NVL (missing_acad_record_data_ind, 'N') = 'N';
  END LOOP;
  --
  -- Update IGS_AS_DOC_DETAILS.ITEM_STATUS and date_produced to sysdate
  --
  FOR rec_doc_details IN c_doc_details (p_item_number)
  LOOP
    igs_as_doc_details_pkg.update_row (
      x_rowid                        => rec_doc_details.rowid,
      x_order_number                 => rec_doc_details.order_number,
      x_document_type                => rec_doc_details.document_type,
      x_document_sub_type            => rec_doc_details.document_sub_type,
      x_item_number                  => rec_doc_details.item_number,
      x_item_status                  => 'PROCESSED',
      x_date_produced                => SYSDATE,
      x_incl_curr_course             => rec_doc_details.incl_curr_course,
      x_num_of_copies                => rec_doc_details.num_of_copies,
      x_comments                     => rec_doc_details.comments,
      x_recip_pers_name              => rec_doc_details.recip_pers_name,
      x_recip_inst_name              => rec_doc_details.recip_inst_name,
      x_recip_addr_line_1            => rec_doc_details.recip_addr_line_1,
      x_recip_addr_line_2            => rec_doc_details.recip_addr_line_2,
      x_recip_addr_line_3            => rec_doc_details.recip_addr_line_3,
      x_recip_addr_line_4            => rec_doc_details.recip_addr_line_4,
      x_recip_city                   => rec_doc_details.recip_city,
      x_recip_postal_code            => rec_doc_details.recip_postal_code,
      x_recip_state                  => rec_doc_details.recip_state,
      x_recip_province               => rec_doc_details.recip_province,
      x_recip_county                 => rec_doc_details.recip_county,
      x_recip_country                => rec_doc_details.recip_country,
      x_recip_fax_area_code          => rec_doc_details.recip_fax_area_code,
      x_recip_fax_country_code       => rec_doc_details.recip_fax_country_code,
      x_recip_fax_number             => rec_doc_details.recip_fax_number,
      x_delivery_method_type         => rec_doc_details.delivery_method_type,
      x_programs_on_file             => rec_doc_details.programs_on_file,
      x_missing_acad_record_data_ind => rec_doc_details.missing_acad_record_data_ind,
      x_missing_academic_record_data => rec_doc_details.missing_academic_record_data,
      x_send_transcript_immediately  => rec_doc_details.send_transcript_immediately,
      x_hold_release_of_final_grades => rec_doc_details.hold_release_of_final_grades,
      x_fgrade_cal_type              => rec_doc_details.fgrade_cal_type,
      x_fgrade_seq_num               => rec_doc_details.fgrade_seq_num,
      x_hold_degree_expected         => rec_doc_details.hold_degree_expected,
      x_deghold_cal_type             => rec_doc_details.deghold_cal_type,
      x_deghold_seq_num              => rec_doc_details.deghold_seq_num,
      x_hold_for_grade_chg           => rec_doc_details.hold_for_grade_chg,
      x_special_instr                => rec_doc_details.special_instr,
      x_express_mail_type            => rec_doc_details.express_mail_type,
      x_express_mail_track_num       => rec_doc_details.express_mail_track_num,
      x_ge_certification             => rec_doc_details.ge_certification,
      x_external_comments            => rec_doc_details.external_comments,
      x_internal_comments            => rec_doc_details.internal_comments,
      x_dup_requested                => rec_doc_details.dup_requested,
      x_dup_req_date                 => rec_doc_details.dup_req_date,
      x_dup_sent_date                => rec_doc_details.dup_sent_date,
      x_enr_term_cal_type            => rec_doc_details.enr_term_cal_type,
      x_enr_ci_sequence_number       => rec_doc_details.enr_ci_sequence_number,
      x_incl_attempted_hours         => rec_doc_details.incl_attempted_hours,
      x_incl_class_rank              => rec_doc_details.incl_class_rank,
      x_incl_progresssion_status     => rec_doc_details.incl_progresssion_status,
      x_incl_class_standing          => rec_doc_details.incl_class_standing,
      x_incl_cum_hours_earned        => rec_doc_details.incl_cum_hours_earned,
      x_incl_gpa                     => rec_doc_details.incl_gpa,
      x_incl_date_of_graduation      => rec_doc_details.incl_date_of_graduation,
      x_incl_degree_dates            => rec_doc_details.incl_degree_dates,
      x_incl_degree_earned           => rec_doc_details.incl_degree_earned,
      x_incl_date_of_entry           => rec_doc_details.incl_date_of_entry,
      x_incl_drop_withdrawal_dates   => rec_doc_details.incl_drop_withdrawal_dates,
      x_incl_hrs_for_curr_term       => rec_doc_details.incl_hrs_earned_for_curr_term,
      x_incl_majors                  => rec_doc_details.incl_majors,
      x_incl_last_date_of_enrollment => rec_doc_details.incl_last_date_of_enrollment,
      x_incl_professional_licensure  => rec_doc_details.incl_professional_licensure,
      x_incl_college_affiliation     => rec_doc_details.incl_college_affiliation,
      x_incl_instruction_dates       => rec_doc_details.incl_instruction_dates,
      x_incl_usec_dates              => rec_doc_details.incl_usec_dates,
      x_incl_program_attempt         => rec_doc_details.incl_program_attempt,
      x_incl_attendence_type         => rec_doc_details.incl_attendence_type,
      x_incl_last_term_enrolled      => rec_doc_details.incl_last_term_enrolled,
      x_incl_ssn                     => rec_doc_details.incl_ssn,
      x_incl_date_of_birth           => rec_doc_details.incl_date_of_birth,
      x_incl_disciplin_standing      => rec_doc_details.incl_disciplin_standing,
      x_incl_no_future_term          => rec_doc_details.incl_no_future_term,
      x_incl_acurat_till_copmp_dt    => rec_doc_details.incl_acurat_till_copmp_dt,
      x_incl_cant_rel_without_sign   => rec_doc_details.incl_cant_rel_without_sign,
      x_mode                         => 'R',
      x_return_status                => l_return_status,
      x_msg_data                     => l_msg_data,
      x_msg_count                    => l_msg_count,
      x_doc_fee_per_copy             => rec_doc_details.doc_fee_per_copy,
      x_delivery_fee                 => rec_doc_details.delivery_fee,
      x_recip_email                  => rec_doc_details.recip_email,
      x_overridden_doc_delivery_fee  => rec_doc_details.overridden_doc_delivery_fee,
      x_overridden_document_fee      => rec_doc_details.overridden_document_fee,
      x_fee_overridden_by            => rec_doc_details.fee_overridden_by,
      x_fee_overridden_date          => rec_doc_details.fee_overridden_date,
      x_incl_department              => rec_doc_details.incl_department,
      x_incl_field_of_stdy           => rec_doc_details.incl_field_of_stdy,
      x_incl_attend_mode             => rec_doc_details.incl_attend_mode,
      x_incl_yop_acad_prd            => rec_doc_details.incl_yop_acad_prd,
      x_incl_intrmsn_st_end          => rec_doc_details.incl_intrmsn_st_end,
      x_incl_hnrs_lvl                => rec_doc_details.incl_hnrs_lvl,
      x_incl_awards                  => rec_doc_details.incl_awards,
      x_incl_award_aim               => rec_doc_details.incl_award_aim,
      x_incl_acad_sessions           => rec_doc_details.incl_acad_sessions,
      x_incl_st_end_acad_ses         => rec_doc_details.incl_st_end_acad_ses,
      x_incl_hesa_num                => rec_doc_details.incl_hesa_num,
      x_incl_location                => rec_doc_details.incl_location,
      x_incl_program_type            => rec_doc_details.incl_program_type,
      x_incl_program_name            => rec_doc_details.incl_program_name,
      x_incl_prog_atmpt_stat         => rec_doc_details.incl_prog_atmpt_stat,
      x_incl_prog_atmpt_end          => rec_doc_details.incl_prog_atmpt_end,
      x_incl_prog_atmpt_strt         => rec_doc_details.incl_prog_atmpt_strt,
      x_incl_req_cmplete             => rec_doc_details.incl_req_cmplete,
      x_incl_expected_compl_dt       => rec_doc_details.incl_expected_compl_dt,
      x_incl_conferral_dt            => rec_doc_details.incl_conferral_dt,
      x_incl_thesis_title            => rec_doc_details.incl_thesis_title,
      x_incl_program_code            => rec_doc_details.incl_program_code,
      x_incl_program_ver             => rec_doc_details.incl_program_ver,
      x_incl_stud_no                 => rec_doc_details.incl_stud_no,
      x_incl_surname                 => rec_doc_details.incl_surname,
      x_incl_fore_name               => rec_doc_details.incl_fore_name,
      x_incl_prev_names              => rec_doc_details.incl_prev_names,
      x_incl_initials                => rec_doc_details.incl_initials,
      x_doc_purpose_code             => rec_doc_details.doc_purpose_code,
      x_plan_id                      => rec_doc_details.plan_id,
      x_produced_by                  => rec_doc_details.produced_by,
      x_person_id                    => rec_doc_details.person_id
    );
  END LOOP;
  --
  -- Fetch order number from IGS_AS_ORDER_HDR and update order status
  -- to COMPLETED if all the line items are PROCESSED
  --
  FOR rec_order_hdr IN c_order_hdr
  LOOP
    igs_as_order_hdr_pkg.update_row(
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      x_return_status        => l_return_status,
      x_rowid                => rec_order_hdr.rowid,
      x_order_number         => rec_order_hdr.order_number,
      x_order_status         => 'COMPLETED',
      x_date_completed       => SYSDATE,
      x_person_id            => rec_order_hdr.person_id,
      x_addr_line_1          => rec_order_hdr.addr_line_1,
      x_addr_line_2          => rec_order_hdr.addr_line_2,
      x_addr_line_3          => rec_order_hdr.addr_line_3,
      x_addr_line_4          => rec_order_hdr.addr_line_4,
      x_city                 => rec_order_hdr.city,
      x_state                => rec_order_hdr.state,
      x_province             => rec_order_hdr.province,
      x_county               => rec_order_hdr.county,
      x_country              => rec_order_hdr.country,
      x_postal_code          => rec_order_hdr.postal_code,
      x_email_address        => rec_order_hdr.email_address,
      x_phone_country_code   => rec_order_hdr.phone_country_code,
      x_phone_area_code      => rec_order_hdr.phone_area_code,
      x_phone_number         => rec_order_hdr.phone_number,
      x_phone_extension      => rec_order_hdr.phone_extension,
      x_fax_country_code     => rec_order_hdr.fax_country_code,
      x_fax_area_code        => rec_order_hdr.fax_area_code,
      x_fax_number           => rec_order_hdr.fax_number,
      x_delivery_fee         => rec_order_hdr.delivery_fee,
      x_order_fee            => rec_order_hdr.order_fee,
      x_request_type         => rec_order_hdr.request_type,
      x_submit_method        => rec_order_hdr.submit_method,
      x_invoice_id           => rec_order_hdr.invoice_id,
      x_mode                 => 'R',
      x_order_description    => rec_order_hdr.order_description,
      x_order_placed_by      => rec_order_hdr.order_placed_by
    );
  END LOOP;
  --
  -- Commit if the job is not run in Test Mode;
  --
  IF (p_test_mode = 'N') THEN
    COMMIT;
  END IF;
  --
  END asp_update_order_doc;

  FUNCTION get_doc_fee(
    p_order_number igs_as_doc_details.order_number%TYPE
  ) RETURN NUMBER
  IS
 /*************************************************************
  Created By :Sandeep Waghmare
  Date Created on : 14-Sep-2005
  Purpose : This process is called by the DocSummaryDtlsVO to display the Document Fees for the particular student.
  Know limitations, enhancements or remarks
  CHANGE HISTORY
  Who        When          What
  (reverse chronological order - newest change first)
 ***************************************************************/
 l_order_fee number;
 BEGIN
    SELECT NVL (SUM (NVL (dtl.overridden_document_fee, dtl.doc_fee_per_copy)), 0)
     INTO l_order_fee
     FROM igs_as_doc_details dtl
    WHERE order_number = p_order_number;
   RETURN l_order_fee;
END get_doc_fee;

 FUNCTION get_del_fee(
    p_order_number igs_as_doc_details.order_number%TYPE
  ) RETURN NUMBER
 IS
 /*************************************************************
  Created By :Sandeep Waghmare
  Date Created on : 14-Sep-2005
  Purpose : This process is called by the DocSummaryDtlsVO to display the Document Delivery Fees for the particular student.
  Know limitations, enhancements or remarks
  CHANGE HISTORY
  Who        When          What
  (reverse chronological order - newest change first)
 ***************************************************************/
    l_order_del_fee   NUMBER;
 BEGIN
   SELECT NVL (SUM (NVL (dtl.overridden_doc_delivery_fee, dtl.delivery_fee)), 0)
     INTO l_order_del_fee
     FROM igs_as_doc_details dtl
    WHERE order_number = p_order_number;

   RETURN l_order_del_fee;
 END get_del_fee;


END igs_as_prod_doc;

/
