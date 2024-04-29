--------------------------------------------------------
--  DDL for Package Body IGS_PR_STDNT_PR_OU_BE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_STDNT_PR_OU_BE_PKG" AS
/* $Header: IGSPR35B.pls 115.0 2002/10/04 14:53:15 ddey noship $ */



PROCEDURE approve_otcm(
                         p_person_id                  IN NUMBER,
                         p_course_cd                  IN VARCHAR2,
                         p_sequence_number            IN NUMBER,
                         p_decision_status            IN VARCHAR2,
                         p_decision_dt                IN VARCHAR2,
                         p_progression_outcome_type   IN VARCHAR2,
                         p_description                IN VARCHAR2,
                         p_appeal_expiry_dt           IN VARCHAR2,
                         p_show_cause_expiry_dt       IN VARCHAR2
			 )      AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 30-Sept-2002
   Purpose            : This procedure will be used for launching
                        the workflow process.
   Change History
   Who      When        What
  ******************************************************************/


    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number
    CURSOR
          c_seq_num
     IS
          SELECT
	         igs_pr_progout_ntf_s.NEXTVAL
          FROM
	        dual;


  BEGIN


    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;


     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);



      --
      -- Adding the parameters to the parameter list
      --


         wf_event.AddParameterToList ( p_name => 'IA_PERSON_ID',p_value=>p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_COURSE_CD', p_Value => p_course_cd, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SEQUENCE_NUMBER', p_Value => p_sequence_number, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DECISION_STATUS', p_Value => p_decision_status, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_DECISION_DT',p_value=>p_decision_dt,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PROGRESSION_OUTCOME_TYPE', p_Value => p_progression_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DESCRIPTION', p_Value => p_description, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPEAL_EXPIRY_DT', p_Value => p_appeal_expiry_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SHOW_CAUSE_EXPIRY_DT', p_Value => p_show_cause_expiry_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_EVENT_NAME', p_Value => 'oracle.apps.igs.pr.approve_otcm', p_parameterlist => l_parameter_list_t);

     -- Raise the Event


     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.approve_otcm' ,
                     p_event_key  => 'PR001'||ln_seq_val,
                     p_parameters => l_parameter_list_t);

   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

 END approve_otcm;


 PROCEDURE apply_positive_otcm(
			 p_person_id                 IN NUMBER,
			 p_course_cd		     IN VARCHAR2,
			 p_sequence_number	     IN NUMBER,
			 p_decision_status	     IN VARCHAR2,
			 p_decision_dt		     IN VARCHAR2,
			 p_progression_outcome_type  IN VARCHAR2,
			 p_description               IN VARCHAR2,
			 p_applied_dt		     IN VARCHAR2
			)  AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 30-Sept-2002
   Purpose            : This procedure will be used for launching
                        the workflow process.
   Change History
   Who      When        What
  ******************************************************************/


    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number
    CURSOR
          c_seq_num
     IS
          SELECT
	         igs_pr_progout_ntf_s.NEXTVAL
          FROM
	        dual;


  BEGIN



    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;


     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);



      --
      -- Adding the parameters to the parameter list
      --

         wf_event.AddParameterToList ( p_name => 'IA_PERSON_ID',p_value=>p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_COURSE_CD', p_Value => p_course_cd, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SEQUENCE_NUMBER', p_Value => p_sequence_number, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DECISION_STATUS', p_Value => p_decision_status, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_DECISION_DT',p_value=>p_decision_dt,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PROGRESSION_OUTCOME_TYPE', p_Value => p_progression_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPLIED_DT', p_Value => p_applied_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_EVENT_NAME', p_Value => 'oracle.apps.igs.pr.apply_positive_otcm', p_parameterlist => l_parameter_list_t);
	 wf_event.AddParameterToList ( p_Name => 'IA_DESCRIPTION', p_Value => p_description, p_parameterlist => l_parameter_list_t);
       -- Raise the Event


     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.apply_positive_otcm' ,
                     p_event_key  => 'PR001'||ln_seq_val,
                     p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

 END apply_positive_otcm;



 PROCEDURE apply_otcm(
			 p_person_id                 IN NUMBER,
			 p_course_cd		     IN VARCHAR2,
			 p_sequence_number	     IN NUMBER,
			 p_decision_status	     IN VARCHAR2,
			 p_decision_dt		     IN VARCHAR2,
			 p_progression_outcome_type  IN VARCHAR2,
			 p_appeal_expiry_dt	     IN VARCHAR2,
			 p_show_cause_expiry_dt	     IN VARCHAR2,
			 p_applied_dt		     IN VARCHAR2,
			 p_description               IN VARCHAR2
			)    AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 30-Sept-2002
   Purpose            : This procedure will be used for launching
                        the workflow process.
   Change History
   Who      When        What
  ******************************************************************/


    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number
    CURSOR
          c_seq_num
     IS
          SELECT
	         igs_pr_progout_ntf_s.NEXTVAL
          FROM
	        dual;


  BEGIN



    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;


     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);



      --
      -- Adding the parameters to the parameter list
      --

         wf_event.AddParameterToList ( p_name => 'IA_PERSON_ID',p_value=>p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_COURSE_CD', p_Value => p_course_cd, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SEQUENCE_NUMBER', p_Value => p_sequence_number, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DECISION_STATUS', p_Value => p_decision_status, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_DECISION_DT',p_value=>p_decision_dt,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PROGRESSION_OUTCOME_TYPE', p_Value => p_progression_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPEAL_EXPIRY_DT', p_Value => p_appeal_expiry_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SHOW_CAUSE_EXPIRY_DT', p_Value => p_show_cause_expiry_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPLIED_DT', p_Value => p_applied_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_EVENT_NAME', p_Value => 'oracle.apps.igs.pr.apply_otcm', p_parameterlist => l_parameter_list_t);
	 wf_event.AddParameterToList ( p_Name => 'IA_DESCRIPTION', p_Value => p_description, p_parameterlist => l_parameter_list_t);

       -- Raise the Event


     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.apply_otcm' ,
                     p_event_key  => 'PR001'||ln_seq_val,
                     p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

 END apply_otcm;



 PROCEDURE show_cause_uph_dsm(
			p_person_id                    IN NUMBER,
			p_course_cd		       IN VARCHAR2,
			p_sequence_number	       IN NUMBER,
			p_decision_status	       IN VARCHAR2,
			p_decision_dt		       IN VARCHAR2,
			p_progression_outcome_type     IN VARCHAR2,
			p_description		       IN VARCHAR2,
			p_applied_dt		       IN VARCHAR2,
			p_show_cause_dt		       IN VARCHAR2,
			p_show_cause_outcome_dt        IN VARCHAR2,
			p_show_cause_outcome_type      IN VARCHAR2
                          ) AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 30-Sept-2002
   Purpose            : This procedure will be used for launching
                        the workflow process.
   Change History
   Who      When        What
  ******************************************************************/


    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number
    CURSOR
          c_seq_num
     IS
          SELECT
	         igs_pr_progout_ntf_s.NEXTVAL
          FROM
	        dual;


  BEGIN



    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;


     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);



      --
      -- Adding the parameters to the parameter list
      --

         wf_event.AddParameterToList ( p_name => 'IA_PERSON_ID',p_value=>p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_COURSE_CD', p_Value => p_course_cd, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SEQUENCE_NUMBER', p_Value => p_sequence_number, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DECISION_STATUS', p_Value => p_decision_status, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_DECISION_DT',p_value=>p_decision_dt,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PROGRESSION_OUTCOME_TYPE', p_Value => p_progression_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DESCRIPTION', p_Value => p_description, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPLIED_DT', p_Value => p_applied_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SHOW_CAUSE_DT', p_Value => p_show_cause_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SHOW_CAUSE_OUTCOME_DT', p_Value => p_show_cause_outcome_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SHOW_CAUSE_OUTCOME_TYPE', p_Value => p_show_cause_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_EVENT_NAME', p_Value => 'oracle.apps.igs.pr.showcause_uph_dsm', p_parameterlist => l_parameter_list_t);

       -- Raise the Event


     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.showcause_uph_dsm' ,
                     p_event_key  => 'PR001'||ln_seq_val,
                     p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

 END show_cause_uph_dsm;



 PROCEDURE appeal_uph_dsm(
			p_person_id                    IN NUMBER,
			p_course_cd                    IN VARCHAR2,
			p_sequence_number              IN NUMBER,
			p_decision_status              IN VARCHAR2,
			p_decision_dt                  IN VARCHAR2,
			p_progression_outcome_type     IN VARCHAR2,
			p_description                  IN VARCHAR2,
			p_applied_dt                   IN VARCHAR2,
			p_appeal_dt                    IN VARCHAR2,
			p_appeal_outcome_dt            IN VARCHAR2,
			p_appeal_outcome_type          IN VARCHAR2
                          ) AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 30-Sept-2002
   Purpose            : This procedure will be used for launching
                        the workflow process.
   Change History
   Who      When        What
  ******************************************************************/


    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number
    CURSOR
          c_seq_num
     IS
          SELECT
	         igs_pr_progout_ntf_s.NEXTVAL
          FROM
	        dual;


  BEGIN



    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;


     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);



      --
      -- Adding the parameters to the parameter list
      --

         wf_event.AddParameterToList ( p_name => 'IA_PERSON_ID',p_value=>p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_COURSE_CD', p_Value => p_course_cd, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SEQUENCE_NUMBER', p_Value => p_sequence_number, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DECISION_STATUS', p_Value => p_decision_status, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_DECISION_DT',p_value=>p_decision_dt,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PROGRESSION_OUTCOME_TYPE', p_Value => p_progression_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DESCRIPTION', p_Value => p_description, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPLIED_DT', p_Value => p_applied_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPEAL_DT', p_Value => p_appeal_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPEAL_OUTCOME_DT', p_Value => p_appeal_outcome_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPEAL_OUTCOME_TYPE', p_Value => p_appeal_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_EVENT_NAME', p_Value => 'oracle.apps.igs.pr.appeal_uph_dsm', p_parameterlist => l_parameter_list_t);
       -- Raise the Event


     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.appeal_uph_dsm' ,
                     p_event_key  => 'PR001'||ln_seq_val,
                     p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

 END appeal_uph_dsm;


 PROCEDURE remove_waive_cancel_otcm(
                         p_person_id                  IN NUMBER,
                         p_course_cd		      IN VARCHAR2,
                         p_sequence_number	      IN NUMBER,
                         p_decision_status	      IN VARCHAR2,
                         p_decision_dt		      IN VARCHAR2,
                         p_progression_outcome_type   IN VARCHAR2,
                         p_applied_dt                 IN VARCHAR2,
			 p_description                IN VARCHAR2
                          ) AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 30-Sept-2002
   Purpose            : This procedure will be used for launching
                        the workflow process.
   Change History
   Who      When        What
  ******************************************************************/


    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number
    CURSOR
          c_seq_num
     IS
          SELECT
	         igs_pr_progout_ntf_s.NEXTVAL
          FROM
	        dual;


  BEGIN



    -- Get the sequence value
    OPEN  c_seq_num;
    FETCH c_seq_num INTO ln_seq_val ;
    CLOSE c_seq_num ;


     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);



      --
      -- Adding the parameters to the parameter list
      --

         wf_event.AddParameterToList ( p_name => 'IA_PERSON_ID',p_value=>p_person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_COURSE_CD', p_Value => p_course_cd, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SEQUENCE_NUMBER', p_Value => p_sequence_number, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_DECISION_STATUS', p_Value => p_decision_status, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_name => 'IA_DECISION_DT',p_value=>p_decision_dt,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PROGRESSION_OUTCOME_TYPE', p_Value => p_progression_outcome_type, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_APPLIED_DT', p_Value => p_applied_dt, p_parameterlist => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_EVENT_NAME', p_Value => 'oracle.apps.igs.pr.remove_waive_cancel_otcm', p_parameterlist => l_parameter_list_t);
	 wf_event.AddParameterToList ( p_Name => 'IA_DESCRIPTION', p_Value => p_description, p_parameterlist => l_parameter_list_t);


      -- Raise the Event


     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.remove_waive_cancel_otcm' ,
                     p_event_key  => 'PR001'||ln_seq_val,
                     p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

 END remove_waive_cancel_otcm;


END igs_pr_stdnt_pr_ou_be_pkg;

/
