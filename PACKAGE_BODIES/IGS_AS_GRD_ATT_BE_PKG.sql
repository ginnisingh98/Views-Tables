--------------------------------------------------------
--  DDL for Package Body IGS_AS_GRD_ATT_BE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GRD_ATT_BE_PKG" AS
/* $Header: IGSAS53B.pls 115.0 2002/12/26 09:49:19 ddey noship $ */

/* *************************************************************************************/
-- This Procedure raises an event when Change Grade Submission  is done.
/* *************************************************************************************/

PROCEDURE  Wf_Inform_Admin_CG
                       (  p_person_id          IN   VARCHAR2,
                          p_person_number      IN   hz_parties.party_number%TYPE,
                          p_person_name        IN   hz_parties.party_name%TYPE,
                          p_course_cd          IN   igs_as_chn_grd_req.course_cd%TYPE,
                          p_unit_cd            IN   igs_as_chn_grd_req.unit_cd%TYPE,
                          p_unit_section       IN   igs_as_chn_grd_req.unit_class%TYPE,
                          p_title              IN   igs_ps_unit_ver_all.title%TYPE,
                          p_grading_schema     IN   igs_as_chn_grd_req.current_grading_schema_cd%TYPE,
                          p_current_mark       IN   igs_as_chn_grd_req.current_mark%TYPE,
                          p_current_grade      IN   igs_as_chn_grd_req.current_grade%TYPE,
                          p_change_mark        IN   igs_as_chn_grd_req.change_mark%TYPE,
                          p_change_grade       IN   igs_as_chn_grd_req.change_grade%TYPE,
                          p_requester_id       IN   igs_as_chn_grd_req.requester_id%TYPE,
                          p_requester_name     IN   VARCHAR2,
                          p_requester_number   IN   VARCHAR2,
                          p_request_date       IN   igs_as_chn_grd_req.request_date%TYPE,
                          p_requester_comments IN   igs_as_chn_grd_req.requester_comments%TYPE,
                          p_teach_cal_type     IN   igs_as_chn_grd_req.teach_cal_type%TYPE,
                          p_teach_ci_seq_num   IN   igs_as_chn_grd_req.teach_ci_sequence_number%TYPE,
                          p_start_dt           IN   DATE,
                          p_end_dt             IN   DATE,
                          p_load_cal_type      IN   igs_as_chn_grd_req.load_cal_type%TYPE,
                          p_load_seq_num       IN   igs_as_chn_grd_req.load_ci_sequence_number%TYPE,
                          p_grade_ver_num      IN   igs_as_chn_grd_req.current_gs_version_number%TYPE,
                          p_uoo_id             IN   igs_ps_unit_ofr_opt.uoo_id%TYPE,
                          p_grading_period_cd  IN   igs_as_su_stmptout.grading_period_cd%TYPE
                        )
IS
l_event_t             wf_event_t;
l_parameter_list_t    wf_parameter_list_t;
l_itemKey             varchar2(100);

     CURSOR cur_seq IS
	 SELECT IGS_EN_WF_MAILADM_S.NEXTVAL
	 FROM dual;

BEGIN
         --Changing Date to Character
         --  l_request_date := TO_CHAR(p_request_date,'DD-MON-YY');
         --
         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);
         --
         -- set the event name
         --
         --     wf_event_t.setEventName( pEventName => 'oracle.apps.igs.as.infadmcg');
         --
         -- set the event key but before the select a number from sequence
         --



    OPEN cur_seq ;
    FETCH cur_seq INTO l_itemKey ;
    CLOSE cur_seq ;



         --     l_wf_event_t.setEventKey ( pEventKey => 'infadmcg'||l_key );
         --
         -- set the parameter list
         --
         --      l_event_t.setParameterList ( p_parameterlist => l_parameter_list_t );
         --      wf_event_t.SetParameterList ( p_parameterlist => l_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --

         wf_event.AddParameterToList ( p_Name => 'PERSON_ID',p_Value => p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'PERSON_NAME',p_Value => p_person_name,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'PERSON_NUMBER',p_Value => p_person_number,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'COURSE_CD',p_Value => p_course_cd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_CODE',p_Value => p_unit_cd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_SECTION',p_Value => p_unit_section,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_TITLE',p_Value => p_title,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'GRADING_SCHEMA',p_Value => p_grading_schema,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CURRENT_MARK',p_Value => p_current_mark,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CURRENT_GRADE',p_Value => p_current_grade,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CHANGE_MARK',p_Value => p_change_mark,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CHANGE_GRADE',p_Value => p_change_grade,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'REQUESTER_ID',p_Value => p_requester_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'REQUESTER_NAME',p_Value => p_requester_name,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'REQUESTER_NUMBER',p_Value => p_requester_number,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'REQUEST_DATE',p_Value => p_request_date,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'REQUESTER_COMMENTS',p_Value => p_requester_comments,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'TEACH_CAL_TYPE',p_Value => p_teach_cal_type,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'TEACH_CI_SEQUENCE_NUMBER',p_Value => p_teach_ci_seq_num,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'LOAD_CAL_TYPE',p_Value => p_load_cal_type,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CI_SEQUENCE_NUMBER',p_Value => p_load_seq_num,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CI_START_DT',p_Value => p_start_dt,p_parameterlist=>l_parameter_list_t );
         wf_event.AddParameterToList ( p_Name => 'CI_END_DT',p_Value => p_end_dt,p_parameterlist=>l_parameter_list_t );
         wf_event.AddParameterToList ( p_Name => 'UOO_ID',p_Value => p_uoo_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CHANGE_GRADE_VERSION_NUM',p_Value => p_grade_ver_num,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'GRADING_PERIOD_CD',p_Value => p_grading_period_cd,p_parameterlist=>l_parameter_list_t);
--
-- raise the event
--
WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.as.infadmcg',
                p_event_key  => l_itemKey,
                p_parameters => l_parameter_list_t);


END Wf_Inform_Admin_CG ;

/* *************************************************************************************/
-- This Procedure raises an event when Grade Submission is done.
/* *************************************************************************************/

PROCEDURE  Wf_Inform_Admin_Grd
                        ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                          p_unit_cd             IN   igs_ps_unit_ver_all.unit_cd%TYPE,
                          p_unit_class          IN   igs_ps_unit_ofr_opt.unit_class%TYPE,
                          p_title               IN   igs_ps_unit_ver_all.title%TYPE,
                          p_instructor          IN   hz_parties.party_name%TYPE,
                          p_submission_date     IN   DATE,
			  p_requestor_id        IN   VARCHAR2 /* Added by aiyer for the bug 2403814 */
                        )
IS

l_event_t             wf_event_t;
l_parameter_list_t    wf_parameter_list_t;
l_itemKey             varchar2(100);

CURSOR cur_seq1 IS
      SELECT IGS_EN_WF_MAILADM_S.NEXTVAL
      FROM dual;

BEGIN

         --
         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);
         --
         -- set the event name
         --
         --     wf_event_t.setEventName( pEventName => 'oracle.apps.igs.as.infadmgrd');
         --
         -- set the event key but before the select a number from sequence
         --


    OPEN cur_seq1;
    FETCH cur_seq1 INTO l_itemKey ;
    CLOSE cur_seq1;



         --     l_wf_event_t.setEventKey ( pEventKey => 'infadmgrd'||l_key );
         --
         -- set the parameter list
         --
         --      l_event_t.setParameterList ( p_parameterlist => l_parameter_list_t );
         --      wf_event_t.SetParameterList ( p_parameterlist => l_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --

         wf_event.AddParameterToList (p_name=>'UOO_ID',p_value=>p_uoo_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_CD', p_Value => p_unit_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_SECTION', p_Value => p_unit_class, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_TITLE', p_Value => p_title, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'INSTRUCTOR', p_Value => p_instructor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'SUBMISSION_DATE', p_Value => p_submission_date, p_ParameterList => l_parameter_list_t);
	 /*  This has been added by aiyer for the bug 2430814 . Set the FROM_USER_ID parameter attribute in the Grade Submission Workflow */
         wf_event.AddParameterToList ( p_Name => 'FROM_USER_ID', p_Value => p_requestor_id, p_ParameterList => l_parameter_list_t);
--
-- raise the event
--
WF_EVENT.RAISE (p_event_name =>
'oracle.apps.igs.as.infadmgrd',
                         p_event_key  => l_itemKey,
                         p_parameters => l_parameter_list_t);


l_parameter_list_t.delete;

END Wf_Inform_Admin_Grd ;

/* *************************************************************************************/
-- This Procedure raises an event when Incomplete Grade Conversion Process is done.
/* *************************************************************************************/
 PROCEDURE  Wf_Inform_Admin_Grd_Mt
                        ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                          p_unit_cd             IN   igs_ps_unit_ver_all.unit_cd%TYPE,
                          p_unit_class          IN   igs_ps_unit_ofr_opt.unit_class%TYPE,
                          p_title               IN   igs_ps_unit_ver_all.title%TYPE,
                          p_instructor          IN   hz_parties.party_name%TYPE,
                          p_submission_date     IN   DATE
                        )
IS

l_event_t             wf_event_t;
l_parameter_list_t    wf_parameter_list_t;
l_itemKey             varchar2(100);

  CURSOR cur_seq3 IS
         SELECT IGS_EN_WF_MAILADM_S.NEXTVAL
	 FROM dual;
BEGIN

         --
         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);
         --
         -- set the event name
         --
         --     wf_event_t.setEventName( pEventName => 'oracle.apps.igs.as.infadmgrdmt');
         --
         -- set the event key but before the select a number from sequence
         --

   OPEN cur_seq3;
   FETCH cur_seq3 INTO l_itemKey ;
   CLOSE cur_seq3;

         --     l_wf_event_t.setEventKey ( pEventKey => 'infadmgrdmt'||l_key );
         --
         -- set the parameter list
         --
         --      l_event_t.setParameterList ( p_parameterlist => l_parameter_list_t );
         --      wf_event_t.SetParameterList ( p_parameterlist => l_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --

         wf_event.AddParameterToList (p_name=>'UOO_ID',p_value=>p_uoo_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_CD', p_Value => p_unit_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_SECTION', p_Value => p_unit_class, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_TITLE', p_Value => p_title, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'INSTRUCTOR', p_Value => p_instructor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'SUBMISSION_DATE', p_Value => p_submission_date, p_ParameterList => l_parameter_list_t);

--
-- raise the event
--
WF_EVENT.RAISE (p_event_name =>
'oracle.apps.igs.as.infadmgrdmt',
                         p_event_key  => l_itemKey,
                         p_parameters => l_parameter_list_t);


l_parameter_list_t.delete;

END Wf_Inform_Admin_Grd_Mt ;

/* *************************************************************************************/
-- This Procedure raises an event when Attendance Submission is done.
/* *************************************************************************************/

PROCEDURE  Wf_Inform_Admin_Attd
                        ( p_uoo_id              IN   igs_ps_unit_ofr_opt.uoo_id%TYPE  ,
                          p_unit_cd             IN   igs_ps_unit_ver_all.unit_cd%TYPE,
                          p_unit_class          IN   igs_ps_unit_ofr_opt.unit_class%TYPE,
                          p_title               IN   igs_ps_unit_ver_all.title%TYPE,
                          p_instructor          IN   hz_parties.party_name%TYPE,
                          p_submission_date     IN   DATE
                        )
IS

l_event_t             wf_event_t;
l_parameter_list_t    wf_parameter_list_t;
l_itemKey             varchar2(100);

CURSOR cur_seq4 IS
         SELECT IGS_EN_WF_MAILADM_S.NEXTVAL
	 FROM dual;
BEGIN

         --
         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);
         --
         -- set the event name
         --
         --     wf_event_t.setEventName( pEventName => 'oracle.apps.igs.as.infadmattd');
         --
         -- set the event key but before the select a number from sequence
         --


    OPEN cur_seq4;
    FETCH cur_seq4 INTO l_itemKey ;
    CLOSE cur_seq4;


         --     l_wf_event_t.setEventKey ( pEventKey => 'infadmattd'||l_key );
         --
         -- set the parameter list
         --
         --      l_event_t.setParameterList ( p_parameterlist => l_parameter_list_t );
         --      wf_event_t.SetParameterList ( p_parameterlist => l_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --

         wf_event.AddParameterToList (p_name=>'UOO_ID',p_value=>p_uoo_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_CD', p_Value => p_unit_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_SECTION', p_Value => p_unit_class, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_TITLE', p_Value => p_title, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'INSTRUCTOR', p_Value => p_instructor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'SUBMISSION_DATE', p_Value => p_submission_date, p_ParameterList => l_parameter_list_t);

--
-- raise the event
--
WF_EVENT.RAISE (p_event_name =>
'oracle.apps.igs.as.infadmattd',
                         p_event_key  => l_itemKey,
                         p_parameters => l_parameter_list_t);


l_parameter_list_t.delete;

END Wf_Inform_Admin_Attd ;
/* *************************************************************************************/
-- This Procedure raises an event when Incomplete Grade Conversion Process is done.
/* *************************************************************************************/
PROCEDURE  Wf_Inform_Admin_IncGrd
                        ( p_person_id           IN   igs_as_su_stmptout.person_id%TYPE  ,
                          p_course_cd           IN   igs_as_su_stmptout.course_cd%TYPE,
                          p_unit_cd             IN   igs_as_su_stmptout.unit_cd%TYPE,
                          p_cal_type            IN   igs_as_su_stmptout.cal_type%TYPE,
                          p_ci_seq_num          IN   igs_as_su_stmptout.ci_sequence_number%TYPE,
                          p_date_changed        IN   DATE,
                          p_old_grade           IN   igs_as_su_stmptout.grade%TYPE,
                          p_new_grade           IN   igs_as_su_stmptout.incomp_default_grade%TYPE
                        )
IS
l_event_t             wf_event_t;
l_parameter_list_t    wf_parameter_list_t;
l_itemKey             varchar2(100);

CURSOR cur_seq5 IS
   SELECT IGS_EN_WF_MAILADM_S.NEXTVAL
   FROM dual;

BEGIN

         --
         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);
         --
         -- set the event name
         --
         --     wf_event_t.setEventName( pEventName => 'oracle.apps.igs.as.infadmincgrd');
         --
         -- set the event key but before the select a number from sequence
         --


    OPEN cur_seq5;
    FETCH cur_seq5 INTO l_itemKey ;
    CLOSE cur_seq5;

         --     l_wf_event_t.setEventKey ( pEventKey => 'infadmincgrd'||l_key );
         --
         -- set the parameter list
         --
         --      l_event_t.setParameterList ( p_parameterlist => l_parameter_list_t );
         --      wf_event_t.SetParameterList ( p_parameterlist => l_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --

         wf_event.AddParameterToList ( p_Name => 'PERSON_ID', p_Value => p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'COURSE_CD', p_Value => p_course_cd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_CD', p_Value => p_unit_cd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CAL_TYPE', p_Value => p_cal_type,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CI_SEQUENCE_NUMBER', p_Value => p_ci_seq_num,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'DATE_CHANGED', p_Value => p_date_changed,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'OLD_GRADE', p_Value => p_old_grade,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'NEW_GRADE', p_Value => p_new_grade,p_parameterlist=>l_parameter_list_t);
--
-- raise the event
--
WF_EVENT.RAISE (p_event_name =>
'oracle.apps.igs.as.infadmincgrd',
                         p_event_key  => l_itemKey,
                         p_parameters => l_parameter_list_t);
END Wf_Inform_Admin_IncGrd;

/* *************************************************************************************/
-- This Procedure raises an event when Incomplete Grade is submitted.
/* *************************************************************************************/
PROCEDURE  Wf_Inform_Admin_IncGrdSub
                        ( p_person_id           IN   igs_as_su_stmptout.person_id%TYPE  ,
                          p_course_cd           IN   igs_as_su_stmptout.course_cd%TYPE,
                          p_unit_cd             IN   igs_as_su_stmptout.unit_cd%TYPE,
                          p_cal_type            IN   igs_as_su_stmptout.cal_type%TYPE,
                          p_ci_seq_num          IN   igs_as_su_stmptout.ci_sequence_number%TYPE,
                          p_grade               IN   igs_as_su_stmptout.grade%TYPE,
                          p_incomp_deadline_dt  IN   igs_as_su_stmptout.incomp_deadline_date%TYPE,
                          p_incomp_default_grd  IN   igs_as_su_stmptout.incomp_default_grade%TYPE,
                          p_incomp_default_mark IN   igs_as_su_stmptout.incomp_default_mark%TYPE,
                          p_date_submitted      IN   DATE
                        )
IS
l_event_t             wf_event_t;
l_parameter_list_t    wf_parameter_list_t;
l_itemKey             varchar2(100);

CURSOR cur_seq2 IS
      SELECT IGS_EN_WF_MAILADM_S.NEXTVAL
      FROM dual;

BEGIN
         --
         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);
         --
         -- set the event name
         --
         --     wf_event_t.setEventName( pEventName => 'oracle.apps.igs.as.infadmincgrdsub');
         --
         -- set the event key but before the select a number from sequence
         --

    OPEN cur_seq2;
    FETCH cur_seq2 INTO  l_itemKey ;
    CLOSE cur_seq2;


	 --     l_wf_event_t.setEventKey ( pEventKey => 'infadmincgrdsub'||l_key );
         --
         -- set the parameter list
         --
         --      l_event_t.setParameterList ( p_parameterlist => l_parameter_list_t );
         --      wf_event_t.SetParameterList ( p_parameterlist => l_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --

         wf_event.AddParameterToList ( p_Name => 'PERSON_ID', p_Value => p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'COURSE_CD', p_Value => p_course_cd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'UNIT_CD', p_Value => p_unit_cd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CAL_TYPE', p_Value => p_cal_type,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'CI_SEQUENCE_NUMBER', p_Value => p_ci_seq_num,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'GRADE', p_Value => p_grade,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'INCOMP_DEADLINE_DATE', p_Value => p_incomp_deadline_dt,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'INCOMP_DEFAULT_GRADE', p_Value => p_incomp_default_grd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'INCOMP_DEFAULT_MARK', p_Value => p_incomp_default_mark,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'DATE_SUBMITTED', p_Value => p_date_submitted,p_parameterlist=>l_parameter_list_t);
--
-- raise the event
--
WF_EVENT.RAISE (p_event_name =>
'oracle.apps.igs.as.infadmincgrdsub',
                         p_event_key  => l_itemKey,
                         p_parameters => l_parameter_list_t);
END Wf_Inform_Admin_IncGrdSub;

END  IGS_AS_GRD_ATT_BE_PKG ;

/
