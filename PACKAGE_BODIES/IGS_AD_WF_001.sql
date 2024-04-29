--------------------------------------------------------
--  DDL for Package Body IGS_AD_WF_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_WF_001" AS
/* $Header: IGSADC0B.pls 120.6 2006/05/24 09:38:30 arvsrini ship $ */


  PROCEDURE wf_adm_academic_index (
                           p_person_id  IN   NUMBER,
			   p_admission_appl_number IN NUMBER DEFAULT NULL,
			   p_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
			   p_sequence_number IN NUMBER DEFAULT NULL,
			   p_old_academic_index IN VARCHAR2 DEFAULT NULL,
			   p_new_academic_index IN VARCHAR2 DEFAULT NULL
                          ) IS
   /*
   ||  Created By : rboddu
   ||  Created On : 10-OCT-2003
   ||  Purpose :  To raise the Academic Index business event. Financial Aid Integration build. Bug:3202866
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  ||  (reverse chronological order - newest change first)
   */

      CURSOR cur_prof_value IS
      SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
      FROM dual;

    -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_acadindex_wf_s.NEXTVAL
      FROM sys.dual;
      ln_seq_val          NUMBER;

    -- Get Person number and full name.
      CURSOR get_person_attr IS
      SELECT person_number, full_name
      FROM igs_pe_person_base_v
      WHERE person_id = p_person_id;

      CURSOR get_application_id IS
      SELECT application_id
      FROM igs_ad_appl
      WHERE person_id = p_person_id
      AND admission_appl_number = p_admission_appl_number;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;


      l_cur_prof_value   cur_prof_value%ROWTYPE;
      lv_raise_event VARCHAR2(100);
      l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
      l_person_number     igs_pe_person_base_v.person_number%TYPE;
      l_person_name         igs_pe_person_base_v.full_name%TYPE;
      l_application_id     igs_ad_appl_all.application_id%TYPE;
      l_wf_role fnd_user.user_name%TYPE;


  BEGIN
  -- Checking if the Workflow is installed at the environment or not.
    OPEN cur_prof_value;
    FETCH cur_prof_value INTO l_cur_prof_value;
    CLOSE cur_prof_value;

   IF (l_cur_prof_value.value = 'Y') THEN

     -- Get the sequence value
     OPEN  c_seq_num;
     FETCH c_seq_num INTO ln_seq_val ;
     CLOSE c_seq_num ;

       OPEN get_person_attr;
       FETCH get_person_attr INTO l_person_number, l_person_name;
       CLOSE get_person_attr;

       OPEN get_application_id;
       FETCH get_application_id INTO l_application_id;
       CLOSE get_application_id;

       OPEN cur_user_name;
       FETCH cur_user_name INTO l_wf_role;
       CLOSE cur_user_name;

     lv_raise_event := 'oracle.apps.igs.ad.acadindex.changed';

       wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => p_person_id                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_PERSON_NUMBER'                      , p_value => l_person_number                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_NEW_ACADEMIC_INDEX'                      , p_value => p_new_academic_index                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_OLD_ACADEMIC_INDEX'                      , p_value => p_old_academic_index                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_PERSON_NAME'                      , p_value => l_person_name                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_APPLICATION_ID'                      , p_value => l_application_id                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => p_nominated_course_cd                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => p_admission_appl_number                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => p_sequence_number                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);

    -- Raise the event
      wf_event.raise( p_event_name => lv_raise_event, p_event_key  => ln_seq_val, p_parameters => l_parameter_list);
      l_parameter_list.DELETE;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('IGS_AD_WF_001', 'wf_adm_academic_index',
    'IGSADIDX'||ln_seq_val,lv_raise_event);
    raise;

  END wf_adm_academic_index;



  PROCEDURE wf_raise_event(
                           p_person_id                 IN   NUMBER,
                           p_raised_for                IN   VARCHAR2,
			   p_admission_appl_number IN NUMBER DEFAULT NULL,
			   p_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
			   p_sequence_number IN NUMBER DEFAULT NULL,
			   p_old_outcome_status IN VARCHAR2 DEFAULT NULL,
			   p_new_outcome_status IN VARCHAR2 DEFAULT NULL
                          )  AS
   /*
   ||  Created By : vdixit
   ||  Created On : 16-Feb-2002
   ||  Purpose :  To raise the business events in work flow
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  rboddu          15-OCT-2003     Modified signature of procedure for build:
   ||  (reverse chronological order - newest change first)
   */

      ln_seq_val          NUMBER;
      lv_raise_event      VARCHAR2(30);
      lv_item_type        VARCHAR2(100) ;
      l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
      l_person_number     igs_pe_person_base_v.person_number%TYPE;
      l_person_name         igs_pe_person_base_v.full_name%TYPE;
      l_application_id     igs_ad_appl_all.application_id%TYPE;
      l_wf_role fnd_user.user_name%TYPE;


    -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_req_submit_s.NEXTVAL
      FROM sys.dual;

    -- Get Person number and full name.
      CURSOR get_person_attr IS
      SELECT person_number, full_name
      FROM igs_pe_person_base_v
      WHERE person_id = p_person_id;

      CURSOR get_application_id IS
      SELECT application_id
      FROM igs_ad_appl
      WHERE person_id = p_person_id
      AND admission_appl_number = p_admission_appl_number;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

  BEGIN

      IF p_raised_for ='MAC' THEN  --Manual application creation in IGSAD046
         lv_raise_event := 'oracle.apps.igs.pe.rescal.ac';
         lv_item_type := 'IGSAD001' ;
      ELSIF p_raised_for = 'SAC' THEN --Self Service Application creation
         lv_raise_event := 'oracle.apps.igs.pe.rescal.ss';
         lv_item_type := 'IGSAD002';
      ELSIF p_raised_for = 'IAC' THEN  --Import Application creation
         lv_raise_event := 'oracle.apps.igs.pe.rescal.ai';
         lv_item_type := 'IGSAD003';
      ELSIF p_raised_for = 'AOD' THEN  --Admission outcome decision in IGSAD046
         lv_raise_event := 'oracle.apps.igs.pe.rescal.os';
         lv_item_type := 'IGSADOUD';
      ELSIF p_raised_for = 'IOD' THEN  --Import outcome decision in IGSAD081
         lv_raise_event := 'oracle.apps.igs.pe.rescal.io';
         lv_item_type := 'IGSADOUD';
      END IF;

    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;

    --If the Outcome Status is getting updated then pass Additional parameters to the Business event, to identify the Application Instance
    --Old and New Outcome statuses. Financial Aid Integration build -
    IF p_raised_for = 'AOD' OR p_raised_for = 'IOD' THEN

       OPEN get_person_attr;
       FETCH get_person_attr INTO l_person_number, l_person_name;
       CLOSE get_person_attr;

       OPEN get_application_id;
       FETCH get_application_id INTO l_application_id;
       CLOSE get_application_id;

       OPEN cur_user_name;
       FETCH cur_user_name INTO l_wf_role;
       CLOSE cur_user_name;

       wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => p_person_id                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_PERSON_NUMBER'                      , p_value => l_person_number                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_NEW_OUTCOME_STATUS'                      , p_value => p_new_outcome_status                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_OLD_OUTCOME_STATUS'                      , p_value => p_old_outcome_status                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_PERSON_NAME'                      , p_value => l_person_name                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_APPLICATION_ID'                      , p_value => l_application_id                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => p_nominated_course_cd                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => p_admission_appl_number                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => p_sequence_number                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);
    ELSIF  p_raised_for = 'SAC' THEN
       wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => p_person_id                      , p_parameterlist=> l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => p_admission_appl_number                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => p_nominated_course_cd                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => p_sequence_number                      , p_parameterlist => l_parameter_list);
       wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);
    ELSE
       wf_event.AddParameterToList(p_name => 'IA_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist => l_parameter_list);
    END IF;

    -- Raise the event
    wf_event.raise( p_event_name => lv_raise_event,
                    p_event_key  => ln_seq_val,
                    p_parameters => l_parameter_list);
    l_parameter_list.DELETE;

  EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('IGS_AD_WF_001', 'WF_RAISE_EVENT',
    lv_item_type||ln_seq_val,lv_raise_event);
    raise;

  END wf_raise_event;


PROCEDURE transcript_entrd_event(
                           p_person_id                 IN   NUMBER,
                           p_education_id             IN   NUMBER,
                           p_transcript_id             IN   NUMBER
                          )  AS
   /*
   ||  Created By : pbondugu
   ||  Created On : 29-Sep-2003
   ||  Purpose :  To raise the business events in work flow
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  (reverse chronological order - newest change first)
   */

      ln_seq_val          NUMBER;
      lv_raise_event      VARCHAR2(50);
      lv_item_type        VARCHAR2(100) ;
      l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();


    -- Get a unique sequence number
      CURSOR
          c_seq_num
     IS
          SELECT
          IGS_AD_WF_TXCPT_S.NEXTVAL
          FROM     SYS.DUAL;


  BEGIN

     lv_raise_event := 'oracle.apps.igs.ad.appl.mult_trns';
    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;

    wf_event.AddParameterToList(p_name         => 'P_PERSON_ID',
                                p_value        => P_PERSON_ID,
                                p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'P_EDUCATION_ID',
                                p_value        => P_EDUCATION_ID,
                                p_parameterlist=> l_parameter_list);

    wf_event.AddParameterToList(p_name         => 'P_TRANSCRIPT_ID',
                                p_value        => P_TRANSCRIPT_ID,
                                p_parameterlist=> l_parameter_list);

    -- Raise the event
    WF_EVENT.RAISE( p_event_name => lv_raise_event,
                    p_event_key  => ln_seq_val,
                    p_parameters => l_parameter_list);
     l_parameter_list.DELETE;

     -- Call the AV procedure to validate the Advanced Standing records when a new Transcript is submitted.
     -- Added as part of the RECR050; Nalin Kumar; 14-Nov-2003;
     igs_av_val_asuleb.validate_transcript(p_person_id, p_education_id, p_transcript_id);

  EXCEPTION

  WHEN OTHERS THEN
   WF_CORE.CONTEXT('IGS_AD_WF_001', 'TRANSCRIPT_ENTRD_EVENT',
   ln_seq_val,lv_raise_event);
   RAISE;

  END transcript_entrd_event;

PROCEDURE TESTSCORE_CRT_EVENT
(
      P_TEST_RESULTS_ID    IN      NUMBER,
      P_PERSON_ID          IN      NUMBER,
      P_ACTIVE_IND         IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_tstscr_crt_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role fnd_user.user_name%TYPE;
l_seq_val          NUMBER;
lv_raise_event VARCHAR2(100);



BEGIN

	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.test_score';

	wf_event.AddParameterToList(p_name  => 'P_TEST_RESULTS_ID'                      , p_value => P_TEST_RESULTS_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACTIVE_IND'                      , p_value => P_ACTIVE_IND                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;


  WF_CORE.CONTEXT('IGS_AD_WF_001', 'TESTSCORE_CRT_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;



END  TESTSCORE_CRT_EVENT;



PROCEDURE TESTSEG_CRT_EVENT
(
      P_TEST_RESULTS_ID    IN      NUMBER,
      P_TST_RSLT_DTLS_ID   IN      NUMBER,
      P_TEST_SEGMENT_ID    IN      NUMBER,
      P_PERSON_ID          IN      NUMBER
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_tstseg_crt_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN
  -- Checking if the Workflow is installed at the environment or not.

	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.test_score_dtls';

	wf_event.AddParameterToList(p_name  => 'P_TEST_RESULTS_ID'                      , p_value => P_TEST_RESULTS_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TST_RSLT_DTLS_ID'                      , p_value => P_TST_RSLT_DTLS_ID                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TEST_SEGMENT_ID'                      , p_value => P_TEST_SEGMENT_ID                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'TESTSEG_CRT_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  TESTSEG_CRT_EVENT;



PROCEDURE TESTSCORE_UPD_EVENT
(
      P_TEST_RESULTS_ID			IN      NUMBER,
      P_PERSON_ID			IN      NUMBER,
      P_ACTIVE_IND_NEW			IN      VARCHAR2,
      P_ACTIVE_IND_OLD			IN      VARCHAR2,
      P_ADMISSION_TEST_TYPE_NEW		IN      VARCHAR2,
      P_ADMISSION_TEST_TYPE_OLD		IN      VARCHAR2,
      P_GRADE_ID_NEW			IN      NUMBER,
      P_GRADE_ID_OLD                    IN      NUMBER,
      P_COMP_TEST_SCORE_NEW             IN      NUMBER,
      P_COMP_TEST_SCORE_OLD             IN      NUMBER
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_tstscr_upd_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN
  -- Checking if the Workflow is installed at the environment or not.


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.test_score.changed';

	wf_event.AddParameterToList(p_name  => 'P_TEST_RESULTS_ID'                      , p_value => P_TEST_RESULTS_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACTIVE_IND_NEW'                      , p_value => P_ACTIVE_IND_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACTIVE_IND_OLD'                      , p_value => P_ACTIVE_IND_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_TEST_TYPE_NEW'                      , p_value => P_ADMISSION_TEST_TYPE_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_TEST_TYPE_OLD'                      , p_value => P_ADMISSION_TEST_TYPE_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GRADE_ID_NEW'                      , p_value => P_GRADE_ID_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GRADE_ID_OLD'                      , p_value => P_GRADE_ID_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_COMP_TEST_SCORE_NEW'                      , p_value => P_COMP_TEST_SCORE_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_COMP_TEST_SCORE_OLD'                      , p_value => P_COMP_TEST_SCORE_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'TESTSCORE_UPD_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  TESTSCORE_UPD_EVENT;


PROCEDURE TESTSEG_UPD_EVENT
(
      P_TEST_RESULTS_ID			IN      NUMBER,
      P_TST_RSLT_DTLS_ID		IN      NUMBER,
      P_TEST_SEGMENT_ID			IN      NUMBER,
      P_PERSON_ID			IN      NUMBER,
      P_TEST_SCORE_NEW			IN      NUMBER,
      P_TEST_SCORE_OLD			IN      NUMBER
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_tstseg_upd_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.test_score_dtls.changed';

	wf_event.AddParameterToList(p_name  => 'P_TEST_RESULTS_ID'                      , p_value => P_TEST_RESULTS_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TST_RSLT_DTLS_ID'                      , p_value => P_TST_RSLT_DTLS_ID                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TEST_SEGMENT_ID'                      , p_value => P_TEST_SEGMENT_ID                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TEST_SCORE_NEW'                      , p_value => P_TEST_SCORE_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TEST_SCORE_OLD'                      , p_value => P_TEST_SCORE_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'TESTSEG_UPD_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  TESTSEG_UPD_EVENT;


PROCEDURE ACADHIST_CRT_EVENT
(
      P_HZ_ACAD_HIST_ID			IN      NUMBER,
      P_EDUCATION_ID			IN      NUMBER,
      P_PERSON_ID			IN      NUMBER,
      P_ACTIVE_IND			IN      VARCHAR2,
      P_REQUIRED_IND                    IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_acadhist_crt_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.acad_hist';
	wf_event.AddParameterToList(p_name  => 'P_HZ_ACAD_HIST_ID'                      , p_value => P_HZ_ACAD_HIST_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_EDUCATION_ID'                      , p_value => P_EDUCATION_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACTIVE_IND'                      , p_value => P_ACTIVE_IND                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'ACADHIST_CRT_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  ACADHIST_CRT_EVENT;


PROCEDURE ACADHIST_UPD_EVENT
(
      P_HZ_ACAD_HIST_ID			IN      NUMBER,
      P_EDUCATION_ID			IN      NUMBER,
      P_PERSON_ID			IN      NUMBER,
      P_ACTIVE_IND_OLD			IN      VARCHAR2,
      P_ACTIVE_IND_NEW			IN      VARCHAR2,
      P_REQUIRED_IND_NEW                IN      VARCHAR2,
      P_REQUIRED_IND_OLD                IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_acadhist_upd_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.acad_hist.changed';
	wf_event.AddParameterToList(p_name  => 'P_HZ_ACAD_HIST_ID'                      , p_value => P_HZ_ACAD_HIST_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_EDUCATION_ID'                      , p_value => P_EDUCATION_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACTIVE_IND_OLD'                      , p_value => P_ACTIVE_IND_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACTIVE_IND_NEW'                      , p_value => P_ACTIVE_IND_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_REQUIRED_IND_NEW'                      , p_value => P_REQUIRED_IND_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_REQUIRED_IND_OLD'                      , p_value => P_REQUIRED_IND_OLD                      , p_parameterlist => l_parameter_list);
    wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);
	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'ACADHIST_UPD_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  ACADHIST_UPD_EVENT;


PROCEDURE TRANSCRIPT_UPD_EVENT
(
      P_TRANSCRIPT_ID			IN      NUMBER,
      P_EDUCATION_ID			IN      NUMBER,
      P_PERSON_ID			IN      NUMBER,
      P_TRANSCRIPT_STATUS_OLD		IN      VARCHAR2,
      P_TRANSCRIPT_STATUS_NEW		IN      VARCHAR2,
      P_TRANSCRIPT_TYPE_OLD		IN      VARCHAR2,
      P_TRANSCRIPT_TYPE_NEW		IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_txcpt_upd_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.transcript.changed';

	wf_event.AddParameterToList(p_name  => 'P_TRANSCRIPT_ID'                      , p_value => P_TRANSCRIPT_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_EDUCATION_ID'                      , p_value => P_EDUCATION_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TRANSCRIPT_STATUS_OLD'                      , p_value => P_TRANSCRIPT_STATUS_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TRANSCRIPT_STATUS_NEW'                      , p_value => P_TRANSCRIPT_STATUS_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TRANSCRIPT_TYPE_OLD'                      , p_value => P_TRANSCRIPT_TYPE_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_TRANSCRIPT_TYPE_NEW'                      , p_value => P_TRANSCRIPT_TYPE_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'TRANSCRIPT_UPD_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  TRANSCRIPT_UPD_EVENT;


PROCEDURE APPCOMP_STATUS_UPD_EVENT
(
      P_PERSON_ID			IN      NUMBER,
      P_ADMISSION_APPL_NUMBER		IN      NUMBER,
      P_NOMINATED_COURSE_CD		IN      VARCHAR2,
      P_SEQUENCE_NUMBER			IN      NUMBER,
      P_ADM_DOC_STATUS_NEW		IN      VARCHAR2,
      P_ADM_DOC_STATUS_OLD		IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT igs_ad_wf_applcomp_upd_s.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN
  -- Checking if the Workflow is installed at the environment or not.

	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.comp_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => P_ADMISSION_APPL_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_DOC_STATUS_NEW'                      , p_value => P_ADM_DOC_STATUS_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_DOC_STATUS_OLD'                      , p_value => P_ADM_DOC_STATUS_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);


	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;
EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'APPCOMP_STATUS_UPD_EVENT','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  APPCOMP_STATUS_UPD_EVENT;


PROCEDURE ENTRY_QUAL_STATUS_UPD_EVENT
(
      P_PERSON_ID			IN      NUMBER,
      P_ADMISSION_APPL_NUMBER		IN      NUMBER,
      P_NOMINATED_COURSE_CD		IN      VARCHAR2,
      P_SEQUENCE_NUMBER			IN      NUMBER,
      P_ADM_ENTRY_QUAL_STATUS_NEW	IN      VARCHAR2,
      P_ADM_ENTRY_QUAL_STATUS_OLD	IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_ENTQUAL_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();
l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN

	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.ent_qual_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => P_ADMISSION_APPL_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_ENTRY_QUAL_STATUS_NEW'                      , p_value => P_ADM_ENTRY_QUAL_STATUS_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_ENTRY_QUAL_STATUS_OLD'                      , p_value => P_ADM_ENTRY_QUAL_STATUS_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);


	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'ENTRY_QUAL_STATUS_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  ENTRY_QUAL_STATUS_UPD_EVENT ;



PROCEDURE LATE_ADM_FEE_STATUS_UPD_EVENT
(
      P_PERSON_ID			IN      NUMBER,
      P_ADMISSION_APPL_NUMBER		IN      NUMBER,
      P_NOMINATED_COURSE_CD		IN      VARCHAR2,
      P_SEQUENCE_NUMBER			IN      NUMBER,
      P_LATE_ADM_FEE_STATUS_NEW 	IN      VARCHAR2,
      P_LATE_ADM_FEE_STATUS_OLD 	IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_LATEFEE_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.late_fee_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => P_ADMISSION_APPL_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_LATE_ADM_FEE_STATUS_NEW'                      , p_value => P_LATE_ADM_FEE_STATUS_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_LATE_ADM_FEE_STATUS_OLD'                      , p_value => P_LATE_ADM_FEE_STATUS_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);


	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'LATE_ADM_FEE_STATUS_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  LATE_ADM_FEE_STATUS_UPD_EVENT ;

PROCEDURE COND_OFFER_STATUS_UPD_EVENT
(
      P_PERSON_ID			IN      NUMBER,
      P_ADMISSION_APPL_NUMBER		IN      NUMBER,
      P_NOMINATED_COURSE_CD		IN      VARCHAR2,
      P_SEQUENCE_NUMBER			IN      NUMBER,
      P_ADM_CNDTNL_OFFER_STATUS_NEW 	IN      VARCHAR2,
      P_ADM_CNDTNL_OFFER_STATUS_OLD 	IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_CNDOFFER_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN

	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.cond_offer_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => P_ADMISSION_APPL_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_CNDTNL_OFFER_STATUS_NEW'                      , p_value => P_ADM_CNDTNL_OFFER_STATUS_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_CNDTNL_OFFER_STATUS_OLD'                      , p_value => P_ADM_CNDTNL_OFFER_STATUS_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);


	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'COND_OFFER_STATUS_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  COND_OFFER_STATUS_UPD_EVENT ;

PROCEDURE OFFER_DEFER_STATUS_UPD_EVENT
(
      P_PERSON_ID			IN      NUMBER,
      P_ADMISSION_APPL_NUMBER		IN      NUMBER,
      P_NOMINATED_COURSE_CD		IN      VARCHAR2,
      P_SEQUENCE_NUMBER			IN      NUMBER,
      P_ADM_OFFER_DFRMNT_STATUS_NEW 	IN      VARCHAR2,
      P_ADM_OFFER_DFRMNT_STATUS_OLD 	IN      VARCHAR2,
      P_ADM_CAL_TYPE                    IN      VARCHAR2,
      P_ADM_CI_SEQUENCE_NUMBER          IN      NUMBER
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_OFER_DEFER_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.offer_defer_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD', p_value => P_NOMINATED_COURSE_CD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER', p_value => P_SEQUENCE_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_CAL_TYPE', p_value => P_ADM_CAL_TYPE, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_CI_SEQUENCE_NUMBER', p_value => P_ADM_CI_SEQUENCE_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_OFFER_DFRMNT_STATUS_NEW', p_value => P_ADM_OFFER_DFRMNT_STATUS_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_OFFER_DFRMNT_STATUS_OLD', p_value => P_ADM_OFFER_DFRMNT_STATUS_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'OFFER_DEFER_STATUS_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  OFFER_DEFER_STATUS_UPD_EVENT ;

PROCEDURE WAITLIST_STATUS_UPD_EVENT
(
      P_PERSON_ID			IN      NUMBER,
      P_ADMISSION_APPL_NUMBER		IN      NUMBER,
      P_NOMINATED_COURSE_CD		IN      VARCHAR2,
      P_SEQUENCE_NUMBER			IN      NUMBER,
      P_WAITLIST_STATUS_NEW     	IN      VARCHAR2,
      P_WAITLIST_STATUS_OLD     	IN      VARCHAR2
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_WAITLIST_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.waitlist_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID'                      , p_value => P_PERSON_ID                      , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER'                      , p_value => P_ADMISSION_APPL_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD'                      , p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER'                      , p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WAITLIST_STATUS_NEW'                      , p_value => P_WAITLIST_STATUS_NEW                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WAITLIST_STATUS_OLD'                      , p_value => P_WAITLIST_STATUS_OLD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE'                      , p_value => l_wf_role                      , p_parameterlist => l_parameter_list);


	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'WAITLIST_STATUS_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  WAITLIST_STATUS_UPD_EVENT ;


PROCEDURE CREATE_APPLICATION_EVENT
(
    P_PERSON_ID    IN NUMBER,
    P_LOGIN_RESP    IN VARCHAR2,
    P_ACAD_CAL_TYPE    IN VARCHAR2,
    P_ACAD_CAL_SEQ_NUMBER    IN NUMBER,
    P_ADM_CAL_TYPE    IN VARCHAR2,
    P_ADM_CI_SEQUENCE_NUMBER    IN NUMBER,
    P_APPLICATION_TYPE    IN OUT NOCOPY VARCHAR2,
    P_LOCATION_CODE    IN VARCHAR2,
    P_PROGRAM_TYPE    IN VARCHAR2,
    P_SCH_APL_TO_ID    IN NUMBER,
    P_ATTENDANCE_TYPE    IN VARCHAR2,
    P_ATTENDANCE_MODE    IN VARCHAR2,
    P_OO_ATTRIBUTE_1    IN VARCHAR2,
    P_OO_ATTRIBUTE_2    IN VARCHAR2,
    P_OO_ATTRIBUTE_3    IN VARCHAR2,
    P_OO_ATTRIBUTE_4    IN VARCHAR2,
    P_OO_ATTRIBUTE_5    IN VARCHAR2,
    P_OO_ATTRIBUTE_6    IN VARCHAR2,
    P_OO_ATTRIBUTE_7    IN VARCHAR2,
    P_OO_ATTRIBUTE_8    IN VARCHAR2,
    P_OO_ATTRIBUTE_9    IN VARCHAR2,
    P_OO_ATTRIBUTE_10    IN VARCHAR2,
    P_CITIZENSHIP_RESIDENCY_IND    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_1    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_2    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_3    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_4    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_5    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_6    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_7    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_8    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_9    IN VARCHAR2,
    P_CIT_RES_ATTRIBUTE_10    IN VARCHAR2,
    P_STATE_OF_RES_TYPE_CODE    IN VARCHAR2,
    P_DOM_ATTRIBUTE_1    IN VARCHAR2,
    P_DOM_ATTRIBUTE_2    IN VARCHAR2,
    P_DOM_ATTRIBUTE_3    IN VARCHAR2,
    P_DOM_ATTRIBUTE_4    IN VARCHAR2,
    P_DOM_ATTRIBUTE_5    IN VARCHAR2,
    P_DOM_ATTRIBUTE_6    IN VARCHAR2,
    P_DOM_ATTRIBUTE_7    IN VARCHAR2,
    P_DOM_ATTRIBUTE_8    IN VARCHAR2,
    P_DOM_ATTRIBUTE_9    IN VARCHAR2,
    P_DOM_ATTRIBUTE_10    IN VARCHAR2,
    P_GEN_ATTRIBUTE_1    IN VARCHAR2,
    P_GEN_ATTRIBUTE_2    IN VARCHAR2,
    P_GEN_ATTRIBUTE_3    IN VARCHAR2,
    P_GEN_ATTRIBUTE_4    IN VARCHAR2,
    P_GEN_ATTRIBUTE_5    IN VARCHAR2,
    P_GEN_ATTRIBUTE_6    IN VARCHAR2,
    P_GEN_ATTRIBUTE_7    IN VARCHAR2,
    P_GEN_ATTRIBUTE_8    IN VARCHAR2,
    P_GEN_ATTRIBUTE_9    IN VARCHAR2,
    P_GEN_ATTRIBUTE_10    IN VARCHAR2,
    P_GEN_ATTRIBUTE_11    IN VARCHAR2,
    P_GEN_ATTRIBUTE_12    IN VARCHAR2,
    P_GEN_ATTRIBUTE_13    IN VARCHAR2,
    P_GEN_ATTRIBUTE_14    IN VARCHAR2,
    P_GEN_ATTRIBUTE_15    IN VARCHAR2,
    P_GEN_ATTRIBUTE_16    IN VARCHAR2,
    P_GEN_ATTRIBUTE_17    IN VARCHAR2,
    P_GEN_ATTRIBUTE_18    IN VARCHAR2,
    P_GEN_ATTRIBUTE_19    IN VARCHAR2,
    P_GEN_ATTRIBUTE_20    IN VARCHAR2,
    X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
    X_MSG_COUNT           OUT NOCOPY NUMBER,
    X_MSG_DATA            OUT NOCOPY VARCHAR2,
    X_SS_ADM_APPL_ID      OUT NOCOPY NUMBER
) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_CRT_APPL_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

      CURSOR cur_prof_value IS
      SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
      FROM dual;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);
l_cur_prof_value cur_prof_value%ROWTYPE;

 PROCEDURE set_return_message(
            message_name in VARCHAR2,
            message_text  out nocopy VARCHAR2,
            message_token in VARCHAR2 DEFAULT NULL,
            message_token_text in VARCHAR2 DEFAULT NULL) IS

 l_msg_idx_start               NUMBER;
 l_msg_index                   NUMBER;
 l_app_nme                     VARCHAR2(1000);
 l_msg_nme                     VARCHAR2(2000);
 l_msg_txt                     fnd_new_messages.message_text%TYPE;

  BEGIN

    l_msg_index := igs_ge_msg_stack.count_msg;
    FND_MESSAGE.SET_NAME('IGS',message_name);
    IF message_token IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(message_token ,message_token_text);
    END IF;
    IGS_GE_MSG_STACK.ADD;

    igs_ge_msg_stack.get(l_msg_index + 1,'T',l_msg_txt,l_msg_idx_start);
    igs_ge_msg_stack.delete_msg(l_msg_idx_start);
    fnd_message.parse_encoded (l_msg_txt, l_app_nme, l_msg_nme);
    fnd_message.set_encoded (l_msg_txt);
    message_text := fnd_message.get;

  END set_return_message;

BEGIN

    l_wf_role := NULL;
    l_seq_val := NULL;
    lv_raise_event := NULL;
    l_cur_prof_value := NULL;

    OPEN cur_prof_value;
    FETCH cur_prof_value INTO l_cur_prof_value;
    CLOSE cur_prof_value;

   IF (l_cur_prof_value.value = 'Y') THEN

    OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

    lv_raise_event := 'oracle.apps.igs.ad.create_application';

    wf_event.AddParameterToList(p_name  => 'P_PERSON_ID' , p_value => P_PERSON_ID , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_LOGIN_RESP' , p_value => P_LOGIN_RESP , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACAD_CAL_TYPE' , p_value => P_ACAD_CAL_TYPE , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ACAD_CAL_SEQ_NUMBER' , p_value => P_ACAD_CAL_SEQ_NUMBER , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_CAL_TYPE'  , p_value => P_ADM_CAL_TYPE , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_CI_SEQUENCE_NUMBER' , p_value => P_ADM_CI_SEQUENCE_NUMBER , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPLICATION_TYPE'    , p_value => P_APPLICATION_TYPE , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_LOCATION_CODE' , p_value => P_LOCATION_CODE , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_PROGRAM_TYPE'  , p_value => P_PROGRAM_TYPE  , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SCH_APL_TO_ID'  , p_value => P_SCH_APL_TO_ID , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ATTENDANCE_TYPE'  , p_value => P_ATTENDANCE_TYPE , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ATTENDANCE_MODE'  , p_value => P_ATTENDANCE_MODE , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_1' , p_value => P_OO_ATTRIBUTE_1 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_2' , p_value => P_OO_ATTRIBUTE_2 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_3' , p_value => P_OO_ATTRIBUTE_3 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_4' , p_value => P_OO_ATTRIBUTE_4 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_5' , p_value => P_OO_ATTRIBUTE_5 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_6' , p_value => P_OO_ATTRIBUTE_6 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_7' , p_value => P_OO_ATTRIBUTE_7 , p_parameterlist => l_parameter_list);
    wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_8' , p_value => P_OO_ATTRIBUTE_8 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_9' , p_value => P_OO_ATTRIBUTE_9 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_OO_ATTRIBUTE_10', p_value => P_OO_ATTRIBUTE_10, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CITIZENSHIP_RESIDENCY_IND', p_value => P_CITIZENSHIP_RESIDENCY_IND , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_1' , p_value => P_CIT_RES_ATTRIBUTE_1 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_2' , p_value => P_CIT_RES_ATTRIBUTE_2 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_3' , p_value => P_CIT_RES_ATTRIBUTE_3 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_4' , p_value => P_CIT_RES_ATTRIBUTE_4 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_5' , p_value => P_CIT_RES_ATTRIBUTE_5 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_6' , p_value => P_CIT_RES_ATTRIBUTE_6 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_7' , p_value => P_CIT_RES_ATTRIBUTE_7 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_8' , p_value => P_CIT_RES_ATTRIBUTE_8 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_9' , p_value => P_CIT_RES_ATTRIBUTE_9 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_CIT_RES_ATTRIBUTE_10', p_value => P_CIT_RES_ATTRIBUTE_10 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_STATE_OF_RES_TYPE_CODE'  , p_value => P_STATE_OF_RES_TYPE_CODE , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_1' , p_value => P_DOM_ATTRIBUTE_1 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_2' , p_value => P_DOM_ATTRIBUTE_2 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_3' , p_value => P_DOM_ATTRIBUTE_3 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_4' , p_value => P_DOM_ATTRIBUTE_4 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_5' , p_value => P_DOM_ATTRIBUTE_5 , p_parameterlist => l_parameter_list);
    wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_6' , p_value => P_DOM_ATTRIBUTE_6 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_7' , p_value => P_DOM_ATTRIBUTE_7 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_8' , p_value => P_DOM_ATTRIBUTE_8 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_9' , p_value => P_DOM_ATTRIBUTE_9 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_DOM_ATTRIBUTE_10' , p_value => P_DOM_ATTRIBUTE_10 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_1' , p_value => P_GEN_ATTRIBUTE_1 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_2' , p_value => P_GEN_ATTRIBUTE_2 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_3' , p_value => P_GEN_ATTRIBUTE_3 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_4' , p_value => P_GEN_ATTRIBUTE_4 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_5' , p_value => P_GEN_ATTRIBUTE_5 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_6' , p_value => P_GEN_ATTRIBUTE_6 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_7' , p_value => P_GEN_ATTRIBUTE_7 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_8' , p_value => P_GEN_ATTRIBUTE_8 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_9' , p_value => P_GEN_ATTRIBUTE_9 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_10' , p_value => P_GEN_ATTRIBUTE_10 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_11' , p_value => P_GEN_ATTRIBUTE_11 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_12' , p_value => P_GEN_ATTRIBUTE_12 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_13' , p_value => P_GEN_ATTRIBUTE_13 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_14' , p_value => P_GEN_ATTRIBUTE_14 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_15' , p_value => P_GEN_ATTRIBUTE_15 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_16' , p_value => P_GEN_ATTRIBUTE_16 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_17' , p_value => P_GEN_ATTRIBUTE_17 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_18' , p_value => P_GEN_ATTRIBUTE_18 , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_19' , p_value => P_GEN_ATTRIBUTE_19 , p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_GEN_ATTRIBUTE_20' , p_value => P_GEN_ATTRIBUTE_20 , p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

      x_return_status := wf_engine.getitemattrtext('IGSADP2A',l_seq_val,'P_RETURN_STATUS');
      x_msg_count := wf_engine.getitemattrnumber('IGSADP2A',l_seq_val,'P_MSG_COUNT');
      x_msg_data := wf_engine.getitemattrtext('IGSADP2A',l_seq_val,'P_MSG_DATA');
      x_ss_adm_appl_id := wf_engine.getitemattrtext('IGSADP2A',l_seq_val,'P_SS_ADM_APPL_ID');
      p_application_type := wf_engine.getitemattrtext('IGSADP2A',l_seq_val,'P_APPLICATION_TYPE');

      IF x_return_status IS NULL THEN
       x_return_status := 'U';
       x_msg_count := 1;
       set_return_message('IGS_AV_UNHANDLED_ERROR',x_msg_data,'ERROR',sqlerrm);
      END IF;

  ELSE
       x_return_status := 'E';
       x_msg_count := 1;
       set_return_message('IGS_EN_WF_NOT_ENABLE',x_msg_data);

  END IF;


EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;

  IF cur_prof_value%ISOPEN THEN
    CLOSE cur_prof_value;
  END IF;

  WF_CORE.CONTEXT('IGS_AD_WF_001', 'CREATE_APPLICATION_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END  CREATE_APPLICATION_EVENT ;


PROCEDURE ASSIGN_REQUIRMENT_DONE_EVENT
  (
      P_PERSON_ID               IN   NUMBER,
      P_ADMISSION_APPL_NUMBER   IN   NUMBER,
      P_NOMINATED_COURSE_CD     IN   VARCHAR2,
      P_SEQUENCE_NUMBER         IN   NUMBER
   ) AS
          -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_ASSREQ_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.app_requirement';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD', p_value => P_NOMINATED_COURSE_CD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER', p_value => P_SEQUENCE_NUMBER,p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'ASSIGN_REQUIRMENT_DONE_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
END ASSIGN_REQUIRMENT_DONE_EVENT;

PROCEDURE FEE_PAYMENT_CRT_EVENT
     (
      P_PERSON_ID               IN   NUMBER,
      P_ADMISSION_APPL_NUMBER   IN   NUMBER,
      P_APP_REQ_ID              IN   NUMBER,
      P_APPLICANT_FEE_TYPE      IN   NUMBER,
      P_APPLICANT_FEE_STATUS    IN   NUMBER
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_FEE_PAY_CRT_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.app_fee_status';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APP_REQ_ID', p_value => P_APP_REQ_ID, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPLICANT_FEE_TYPE', p_value => P_APPLICANT_FEE_TYPE, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPLICANT_FEE_STATUS', p_value => P_APPLICANT_FEE_STATUS, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'FEE_PAYMENT_CRT_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
 END FEE_PAYMENT_CRT_EVENT;

PROCEDURE FEE_PAYMENT_UPD_EVENT
     (
      P_PERSON_ID                   IN   NUMBER,
      P_ADMISSION_APPL_NUMBER       IN   NUMBER,
      P_APP_REQ_ID                  IN   NUMBER,
      P_APPLICANT_FEE_TYPE          IN   NUMBER,
      P_APPLICANT_FEE_STATUS_NEW    IN   NUMBER,
      P_APPLICANT_FEE_STATUS_OLD    IN   NUMBER
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_FEE_PAY_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);



BEGIN


	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.app_fee_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APP_REQ_ID', p_value => P_APP_REQ_ID, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPLICANT_FEE_TYPE', p_value => P_APPLICANT_FEE_TYPE, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPLICANT_FEE_STATUS_NEW', p_value => P_APPLICANT_FEE_STATUS_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPLICANT_FEE_STATUS_OLD', p_value => P_APPLICANT_FEE_STATUS_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'FEE_PAYMENT_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
 END FEE_PAYMENT_UPD_EVENT;

 PROCEDURE APP_PRCOC_STATUS_UPD_EVENT
     (
      P_PERSON_ID                 IN   NUMBER,
      P_ADMISSION_APPL_NUMBER     IN   NUMBER,
      P_ADM_APPL_STATUS_NEW       IN   VARCHAR2,
      P_ADM_APPL_STATUS_OLD       IN   VARCHAR2
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_APP_PROC_STAT_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);
BEGIN
	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.app_process_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_APPL_STATUS_NEW', p_value => P_ADM_APPL_STATUS_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_APPL_STATUS_OLD', p_value => P_ADM_APPL_STATUS_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'APP_PRCOC_STATUS_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
  END APP_PRCOC_STATUS_UPD_EVENT;

 PROCEDURE APP_INSTANCE_STATUS_UPD_EVENT
     (
      P_PERSON_ID               IN   NUMBER,
      P_ADMISSION_APPL_NUMBER   IN   NUMBER,
      P_NOMINATED_COURSE_CD     IN   VARCHAR2,
      P_SEQUENCE_NUMBER         IN   NUMBER,
      P_APPL_INST_STATUS_NEW    IN   VARCHAR2,
      P_APPL_INST_STATUS_OLD    IN   VARCHAR2
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_APP_INST_STAT_UPD_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);
BEGIN
	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.app_inst_process_status.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD', p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER', p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPL_INST_STATUS_NEW', p_value => P_APPL_INST_STATUS_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_APPL_INST_STATUS_OLD', p_value => P_APPL_INST_STATUS_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'APP_INSTANCE_STATUS_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
  END APP_INSTANCE_STATUS_UPD_EVENT;

 PROCEDURE APP_RECONSIDER_REQUEST_EVENT
     (
      P_PERSON_ID               IN   NUMBER,
      P_ADMISSION_APPL_NUMBER   IN   NUMBER,
      P_NOMINATED_COURSE_CD     IN   VARCHAR2,
      P_SEQUENCE_NUMBER         IN   NUMBER,
      P_ADM_OUTCOME_STATUS      IN   VARCHAR2,
      P_ADM_OFFER_RESP_STATUS   IN   VARCHAR2
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_APP_RECONS_REQ_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);
BEGIN
	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.app_reconsider.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD', p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER', p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_OUTCOME_STATUS', p_value => P_ADM_OUTCOME_STATUS, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_OFFER_RESP_STATUS', p_value => P_ADM_OFFER_RESP_STATUS, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'APP_RECONSIDER_REQUEST_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
  END APP_RECONSIDER_REQUEST_EVENT;

 PROCEDURE APP_RECON_FUT_REQ_UPD_EVENT
     (
      P_PERSON_ID                           IN   NUMBER,
      P_ADMISSION_APPL_NUMBER               IN   NUMBER,
      P_NOMINATED_COURSE_CD                 IN   VARCHAR2,
      P_SEQUENCE_NUMBER                     IN   NUMBER,
      P_ADM_OUTCOME_STATUS                  IN   VARCHAR2,
      P_ADM_OFFER_RESP_STATUS               IN   VARCHAR2,
      P_FUTURE_ADM_CAL_TYPE_NEW             IN   VARCHAR2,
      P_FUTURE_ADM_CAL_TYPE_OLD             IN   VARCHAR2,
      P_FUTURE_ADM_CI_SEQU_NUM_NEW          IN   NUMBER,
      P_FUTURE_ADM_CI_SEQU_NUM_OLD          IN   NUMBER,
      P_FUTURE_ACAD_CAL_TYPE_NEW            IN   VARCHAR2,
      P_FUTURE_ACAD_CAL_TYPE_OLD            IN   VARCHAR2,
      P_FUTURE_ACAD_CI_SEQU_NUM_NEW         IN   NUMBER,
      P_FUTURE_ACAD_CI_SEQ_NUM_OLD          IN   NUMBER,
      P_REQ_FOR_RECONSIDERATION_IND         IN   VARCHAR2
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_APP_RECONS_REQ_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);
BEGIN
	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.app_reconsider_future.changed';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD', p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER', p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_OUTCOME_STATUS', p_value => P_ADM_OUTCOME_STATUS, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADM_OFFER_RESP_STATUS', p_value => P_ADM_OFFER_RESP_STATUS, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ADM_CAL_TYPE_NEW', p_value => P_FUTURE_ADM_CAL_TYPE_NEW, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ADM_CAL_TYPE_OLD', p_value => P_FUTURE_ADM_CAL_TYPE_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ADM_CI_SEQU_NUM_NEW', p_value => P_FUTURE_ADM_CI_SEQU_NUM_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ADM_CI_SEQU_NUM_OLD', p_value => P_FUTURE_ADM_CI_SEQU_NUM_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ACAD_CAL_TYPE_NEW', p_value => P_FUTURE_ACAD_CAL_TYPE_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ACAD_CAL_TYPE_OLD', p_value => P_FUTURE_ACAD_CAL_TYPE_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ACAD_CI_SEQU_NUM_NEW', p_value => P_FUTURE_ACAD_CI_SEQU_NUM_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_FUTURE_ACAD_CI_SEQ_NUM_OLD', p_value => P_FUTURE_ACAD_CI_SEQ_NUM_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_REQ_FOR_RECONSIDERATION_IND', p_value => P_REQ_FOR_RECONSIDERATION_IND, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'APP_RECON_FUT_REQ_UPD_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
  END APP_RECON_FUT_REQ_UPD_EVENT;

 PROCEDURE APP_INST_QUALIFYING_CODE_EVENT
     (
      P_PERSON_ID                           IN   NUMBER,
      P_ADMISSION_APPL_NUMBER               IN   NUMBER,
      P_NOMINATED_COURSE_CD                 IN   VARCHAR2,
      P_SEQUENCE_NUMBER                     IN   NUMBER,
      P_QUALIFYING_TYPE_CODE                IN   VARCHAR2,
      P_QUALIFYING_CODE_ID_NEW              IN   NUMBER,
      P_QUALIFYING_CODE_ID_OLD              IN   NUMBER,
      P_QUALIFYING_VALUE_NEW                IN   VARCHAR2,
      P_QUALIFYING_VALUE_OLD                IN   VARCHAR2
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_WF_APP_QUAL_CODE_S.NEXTVAL
      FROM sys.dual;

      CURSOR cur_user_name IS
      SELECT user_name
      FROM fnd_user
      WHERE user_id = fnd_global.user_id;

l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_wf_role           fnd_user.user_name%TYPE;
l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);
BEGIN
	OPEN cur_user_name;
        FETCH cur_user_name INTO l_wf_role;
        CLOSE cur_user_name;

	OPEN  c_seq_num;
        FETCH c_seq_num INTO l_seq_val ;
        CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.qual_code';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_ADMISSION_APPL_NUMBER', p_value => P_ADMISSION_APPL_NUMBER, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_NOMINATED_COURSE_CD', p_value => P_NOMINATED_COURSE_CD                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SEQUENCE_NUMBER', p_value => P_SEQUENCE_NUMBER                      , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_QUALIFYING_TYPE_CODE', p_value => P_QUALIFYING_TYPE_CODE, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_QUALIFYING_CODE_ID_NEW', p_value => P_QUALIFYING_CODE_ID_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_QUALIFYING_CODE_ID_OLD', p_value => P_QUALIFYING_CODE_ID_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_QUALIFYING_VALUE_NEW', p_value => P_QUALIFYING_VALUE_NEW, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_QUALIFYING_VALUE_OLD', p_value => P_QUALIFYING_VALUE_OLD, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_WF_ROLE', p_value => l_wf_role, p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameters => l_parameter_list);
	l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF cur_user_name%ISOPEN THEN
    CLOSE cur_user_name;
  END IF;
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'APP_INST_QUALIFYING_CODE_EVENT ','IGSADIDX'||l_seq_val,lv_raise_event);
  raise;
  END APP_INST_QUALIFYING_CODE_EVENT;

 PROCEDURE PRE_SUBMIT_EVENT
     (
      P_PERSON_ID                           IN   NUMBER,
      P_SS_ADM_APPL_ID               IN   NUMBER,
      P_RETURN_STATUS                IN OUT NOCOPY   VARCHAR2,
      P_MSG_DATA                      OUT   NOCOPY VARCHAR2
     ) AS
           -- Get a unique sequence number
      CURSOR c_seq_num IS
      SELECT IGS_AD_BE_PRESUB_APPL_S.NEXTVAL
      FROM sys.dual;


l_parameter_list    wf_parameter_list_t  := wf_parameter_list_t();

l_seq_val           NUMBER;
lv_raise_event      VARCHAR2(100);
BEGIN

	OPEN  c_seq_num;
      FETCH c_seq_num INTO l_seq_val ;
    CLOSE c_seq_num ;

	lv_raise_event := 'oracle.apps.igs.ad.onsubmit_application';

	wf_event.AddParameterToList(p_name  => 'P_PERSON_ID', p_value => P_PERSON_ID, p_parameterlist=> l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_SS_ADM_APPL_ID', p_value => P_SS_ADM_APPL_ID, p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_RETURN_STATUS', p_value => P_RETURN_STATUS , p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name  => 'P_MSG_DATA', p_value => P_MSG_DATA, p_parameterlist => l_parameter_list);

	wf_event.raise3( p_event_name => lv_raise_event, p_event_key  => l_seq_val, p_parameter_list => l_parameter_list);
    p_return_status :=  wf_event.GetValueForParameter(p_name  => 'P_RETURN_STATUS',p_parameterlist =>l_parameter_list);
    p_msg_data :=  wf_event.GetValueForParameter(p_name  => 'P_MSG_DATA',p_parameterlist =>l_parameter_list);
    l_parameter_list.DELETE;

EXCEPTION
  WHEN OTHERS THEN
  IF c_seq_num%ISOPEN THEN
    CLOSE c_seq_num;
  END IF;
  WF_CORE.CONTEXT('IGS_AD_WF_001', 'PRE_SUBMIT_EVENT ','IGSADIDX '||l_seq_val,lv_raise_event);
  raise;
  END PRE_SUBMIT_EVENT;

END igs_ad_wf_001;

/
