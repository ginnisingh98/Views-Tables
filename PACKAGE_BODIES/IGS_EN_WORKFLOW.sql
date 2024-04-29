--------------------------------------------------------
--  DDL for Package Body IGS_EN_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_WORKFLOW" AS
/* $Header: IGSEN85B.pls 120.6 2006/04/13 01:54:27 smaddali ship $ */

 /******************************************************************
  Created By         :Sanjeeb Rakshit
  Date Created By    :18-Jul-2001
  Purpose            :This package implements procedure concerned to workflow
  remarks            :
  Change History
  Who      When        What
  ddey     30th April,2003 Bug # 2829275 The new procedures are added as a part of UK Correspondence - Part -1 FD
  vchappid 25-Jul-01  Two new procedures are added
  --kkillams   10-03-2003  Replaced wf_event_t.AddParameterToList with wf_event.AddParameterToList api
  --                       to show params in the workflow out queue and able to derive the parameters
                           from the outside after event is raised, w.r.t. bug 2840171
  knaraset 18-Nov-2003 Added procedure student_placement_event, for placement build
  stutta   14-Apr-2005 Replaced all references to FND_USER.customer_id to
                       FND_USER.person_party_id. Bug #4293911

  ckasu   17-JAN-2006  Added igs_ge_gen_003.set_org_id(NULL) in ENR_NOTIFICATION
                       procedure as a part of bug#4958173.
  smaddali  10-apr-06   Added new procedure raise_spi_rcond_event for bug#5091858 BUILD EN324
 ******************************************************************/

  PROCEDURE  sua_status_change_mail(p_unit_status IN VARCHAR2,p_person_id IN NUMBER,p_uoo_id IN NUMBER) IS
  ------------------------------------------------------------------------------------------------
  --Created by  : sarakshi, Oracle India (in)
  --Date created: 18-Jul-2001
  --
  --Purpose:To implement workflow ,to send  mail to student if a particular
  --unit attempt status has changed.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --vchappid   25-Jul-01     Call to initialize method had to be made before raising an event
  -------------------------------------------------------------------------------------------------

  CURSOR cur_seq_val
  IS
  SELECT igs_en_status_mail_req_s.nextval seq_val
  FROM DUAL;

  l_cur_seq_val         cur_seq_val%ROWTYPE;
  l_wf_parameter_list_t WF_PARAMETER_LIST_T:= wf_parameter_list_t();
  l_wf_installed        fnd_lookups.lookup_code%TYPE;

  BEGIN
    -- get the profile value that is set for checking if workflow is installed
    fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

    -- if workflow is installed then carry on with the raising an event
    IF (RTRIM(l_wf_installed) ='Y') THEN
      -- get the next value of the sequence
      OPEN cur_seq_val;
      FETCH cur_seq_val INTO l_cur_seq_val;
      CLOSE cur_seq_val;

      -- set the event parameters
      wf_event.AddParameterToList(p_name=>'STUDENT_ID', p_value=>p_person_id,  p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList(p_name=>'UOO_ID',     p_value=>p_uoo_id,     p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList(p_name=>'UNIT_STATUS',p_value=>p_unit_status,p_parameterlist=>l_wf_parameter_list_t);

      -- raise the event
      WF_EVENT.RAISE(p_event_name=>'oracle.apps.igs.en.enrp.statmail',
                     p_event_key =>'oracle.apps.igs.en.enrp.statmail'||l_cur_seq_val.seq_val,
                     p_parameters=>l_wf_parameter_list_t);
    END IF;

  END sua_status_change_mail;

  PROCEDURE inform_stdnt_instruct_action( p_student_id       IN NUMBER,
                                          p_instructor_id    IN NUMBER,
                                          p_uoo_id           IN NUMBER,
                                          p_approval_status  IN VARCHAR2,
                                          p_date_submission  IN DATE,
  					  p_request_type     IN VARCHAR2
                                        )
  IS
  ------------------------------------------------------------------------------------------------
  --Created by  : vchappid, Oracle India (in)
  --Date created: 25-Jul-2001
  --
  --Purpose: To raise the business event for sending the mail to the student notifying the action
  --         of the Instructor ( Approve/Deny/Need More Information )
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --knaraset   24-oct-02	Added parameter p_request_type, as part of build TD Audit,used to distinguish
  --				whether the request is for Special permission or for Audit.
  -------------------------------------------------------------------------------------------------

  CURSOR cur_seq_val
  IS
  SELECT igs_en_inst_action_s.nextval seq_val
  FROM DUAL;

  l_cur_seq_val         cur_seq_val%ROWTYPE;
  l_wf_parameter_list_t WF_PARAMETER_LIST_T:=wf_parameter_list_t();
  l_wf_installed        fnd_lookups.lookup_code%TYPE;

  BEGIN

    -- get the profile value that is set for checking if workflow is installed
    fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

    -- if workflow is installed then carry on with the raising an event
    IF (RTRIM(l_wf_installed) ='Y') THEN
      -- get the next value of the sequence
      OPEN cur_seq_val;
      FETCH cur_seq_val INTO l_cur_seq_val;
      CLOSE cur_seq_val;

      -- set the event parameters
      wf_event.AddParameterToList(p_name=>  'STUDENT_ID',      p_value => p_student_id,     p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList(p_name => 'INSTRUCTOR_ID',   p_value => p_instructor_id,  p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList(p_name => 'UOO_ID',          p_value => p_uoo_id,         p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList(p_name => 'APPROVAL_STATUS', p_value => p_approval_status,p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList(p_name => 'DATE_SUBMISSION', p_value => p_date_submission,p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList(p_name => 'REQUEST_TYPE',    p_value => p_request_type,   p_parameterlist=>l_wf_parameter_list_t);


      -- raise the event
      WF_EVENT.RAISE(p_event_name=>'oracle.apps.igs.en.enrp.instresp',
                     p_event_key =>'oracle.apps.igs.en.enrp.instresp'||l_cur_seq_val.seq_val,
                     p_parameters=>l_wf_parameter_list_t);
    END IF;

  END inform_stdnt_instruct_action;
  PROCEDURE inform_instruct_stdnt_petition( p_student_id       IN NUMBER,
                                            p_instructor_id    IN NUMBER,
                                            p_uoo_id           IN NUMBER,
                                            p_date_submission  IN DATE,
					    p_transaction_type IN VARCHAR2,
					    p_request_type     IN VARCHAR2
                                          )
  IS
  ------------------------------------------------------------------------------------------------
  --Created by  : vchappid, Oracle India (in)
  --Date created: 18-Jul-2001
  --
  --Purpose:To raise the business event for sending mail to the Instructor when the student submits
  --        his/her petition for special approval
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --knaraset   24-oct-02	Added parameter p_request_type and p_transaction_type, as part of build TD Audit,
  --
  -------------------------------------------------------------------------------------------------

  CURSOR cur_seq_val  IS  SELECT igs_en_stud_splperm_req_s.NEXTVAL seq_val   FROM DUAL;

  l_cur_seq_val         cur_seq_val%ROWTYPE;
  l_wf_parameter_list_t WF_PARAMETER_LIST_T:=wf_parameter_list_t();
  l_wf_installed        fnd_lookups.lookup_code%TYPE;

  BEGIN

    -- get the profile value that is set for checking if workflow is installed
    fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

    -- if workflow is installed then carry on with the raising an event
    IF (RTRIM(l_wf_installed) ='Y') THEN
      -- get the next value of the sequence
      OPEN cur_seq_val;
      FETCH cur_seq_val INTO l_cur_seq_val;
      CLOSE cur_seq_val;

      wf_event.AddParameterToList ( p_Name => 'STUDENT_ID',      p_Value => p_student_id,       p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList ( p_Name => 'INSTRUCTOR_ID',   p_Value => p_instructor_id,    p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList ( p_Name => 'UOO_ID',          p_Value => p_uoo_id,           p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList ( p_Name => 'DATE_SUBMISSION', p_Value => p_date_submission,  p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList ( p_Name => 'TRANSACTION_TYPE',p_Value => p_transaction_type, p_parameterlist=>l_wf_parameter_list_t);
      wf_event.AddParameterToList ( p_Name => 'REQUEST_TYPE',    p_Value => p_request_type,     p_parameterlist=>l_wf_parameter_list_t);

      -- raise the event
      WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.enrp.studreq',
                      p_event_key  => 'oracle.apps.igs.en.enrp.studreq'||l_cur_seq_val.seq_val,
                      p_parameters => l_wf_parameter_list_t);
    END IF;
  END inform_instruct_stdnt_petition;


  PROCEDURE  intermission_event(p_personid	IN  NUMBER  ,
				p_program_cd	IN  VARCHAR2,
				p_intmtype	IN  VARCHAR2,
				p_startdt	IN  DATE,
				p_enddt	        IN  DATE ,
				p_inst_name	IN  VARCHAR2,
				p_max_cp	IN  NUMBER,
				p_max_term	IN  NUMBER,
				p_anti_cp	IN  NUMBER,
				p_approver	IN  NUMBER
                                  )

  IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . UK Correspondence.The TBH needs to be modified to invoke the intermission business event when an
  --                             intermission record is created or certain attributes updated.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_en_intrmn_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Cursor for fetching the Program Type based on the program Attempt.

    CURSOR cur_prog_type IS
     SELECT course_type
     FROM
     igs_en_stdnt_ps_att espa,
     igs_ps_ver psv
     WHERE
     psv.course_cd = espa.course_cd
     AND psv.version_number = espa.version_number
     AND espa.course_cd  = p_program_cd
     AND espa.person_id = p_personid ;

 -- Cursor to fetch the Intermission Type Description

    CURSOR cur_int_type IS
      SELECT intermission_type,description
      FROM igs_en_intm_types
      WHERE intermission_type =  p_intmtype;



   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_prog_type    cur_prog_type%ROWTYPE;
   l_cur_int_type     cur_int_type%ROWTYPE;


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

    -- Getting the Program Type based on the program Attempt

    OPEN cur_prog_type;
    FETCH cur_prog_type INTO l_cur_prog_type;
    CLOSE cur_prog_type;

   -- Getting the Intermission Type Description, based on the Intermission Type Passed

    OPEN cur_int_type;
    FETCH cur_int_type INTO l_cur_int_type;
    CLOSE cur_int_type;

     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);


     --
     -- Adding the parameters to the parameter list
     --

	wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_PROGRAM_CD', p_Value => p_program_cd, p_ParameterList => l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_PROGRAM_TYPE', p_Value => l_cur_prog_type.course_type, p_ParameterList => l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_INTMTYPE', p_Value => p_intmtype, p_ParameterList => l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_INTMDESC',p_value=>l_cur_int_type.description,p_parameterlist=>l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_STARTDT', p_Value => p_startdt, p_ParameterList => l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_ENDDT', p_Value => p_enddt, p_ParameterList => l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_INST_NAME', p_Value => p_inst_name, p_ParameterList => l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_MAX_CP',p_value=>p_max_cp,p_parameterlist=>l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_MAX_TERM', p_Value => p_max_term, p_ParameterList => l_parameter_list_t);
	wf_event.AddParameterToList (p_name => 'P_ANTI_CP',p_value=>p_anti_cp,p_parameterlist=>l_parameter_list_t);
        wf_event.AddParameterToList (p_name => 'P_APPROVER', p_Value => p_approver, p_ParameterList => l_parameter_list_t);


       -- Raise the Event


         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.prog.intrmn',
                         p_event_key  => 'PROGINTRMN'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

END intermission_event;

PROCEDURE  progdiscont_event (
  			        p_personid	IN NUMBER   ,
				p_programcd	IN VARCHAR2,
				p_discontindt	IN DATE ,
				p_discontincd	IN VARCHAR2
                                   ) IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . UK Correspondence.The TBH needs to be modified to invoke the program discontinuation business event when an
  --                         program is discontinued.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_en_prgdsc_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

-- Getting the Discontinuation Reason for a Discontinuation Type

  CURSOR cur_discontinue_reason IS
    SELECT s_discontinuation_reason_type
    FROM igs_en_dcnt_reasoncd
    WHERE discontinuation_reason_cd = p_discontincd;

   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_user_id      cur_user_id%ROWTYPE;
   l_cur_discontinue_reason cur_discontinue_reason%ROWTYPE;


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

    -- Getting the Logged on User

    OPEN  cur_user_id ;
    FETCH cur_user_id  INTO l_cur_user_id ;
    CLOSE cur_user_id  ;

   -- Getting the Discontinuation Reason for a Discontinuation Type

    OPEN cur_discontinue_reason;
    FETCH cur_discontinue_reason INTO l_cur_discontinue_reason;
    CLOSE cur_discontinue_reason;

     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);


     --
     -- Adding the parameters to the parameter list
     --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => p_programcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DISCONTINDT', p_Value => p_discontindt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DISCONTINCD', p_Value => p_discontincd, p_ParameterList => l_parameter_list_t);
	 wf_event.AddParameterToList (p_name => 'P_DISCONTINTYPE',p_value=>l_cur_discontinue_reason.s_discontinuation_reason_type,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);


     -- Raise the Event


         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.prog.discon',
                         p_event_key  => 'PROGDISCON'||ln_seq_val,
                         p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

 END progdiscont_event;


PROCEDURE progtrans_event (
				p_personid	IN NUMBER ,
				p_destprogcd	IN VARCHAR2,
				p_progstartdt	IN DATE ,
				p_location	IN VARCHAR2,
				p_atten_type	IN VARCHAR2,
				p_atten_mode	IN VARCHAR2,
				p_prog_status	IN VARCHAR2,
				p_trsnfrdt	IN DATE,
				p_sourceprogcd	IN VARCHAR2
                             ) IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . UK Correspondence.The program transfer business event is reaised form this procedure when
  --                         program is transfered.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------

    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_en_prgtrn_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_user_id      cur_user_id%ROWTYPE;


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

    -- Getting the Logged on User

    OPEN  cur_user_id ;
    FETCH cur_user_id  INTO l_cur_user_id ;
    CLOSE cur_user_id  ;

     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);


      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DESTPROGCD', p_Value => p_destprogcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGSTARTDT', p_Value => p_progstartdt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_LOCATION', p_Value => p_location, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ATTEN_TYPE',p_value=>p_atten_type,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ATTEN_MODE', p_Value => p_atten_mode, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROG_STATUS', p_Value => p_prog_status, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_TRSNFRDT', p_Value => p_trsnfrdt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SOURCEPROGCD',p_value=>p_sourceprogcd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);


       -- Raise the Event


         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.prog.transfer',
                         p_event_key  => 'PROGTRANSFER'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

  END progtrans_event;


 PROCEDURE progofropt_event (
				p_personid	    IN   NUMBER   ,
				p_programcd	    IN   VARCHAR2 ,
				p_locationcd	    IN   VARCHAR2 ,
				p_prev_location_cd  IN   VARCHAR2 ,
				p_attndmode	    IN   VARCHAR2 ,
				p_prev_attndmode    IN   VARCHAR2 ,
				p_attndtype	    IN   VARCHAR2 ,
				p_prev_attndtype    IN   VARCHAR2

                            ) IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . UK Correspondence.The program option change business event is reaised form this procedure when
  --                         program option is changed.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------

    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_en_profop_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_user_id      cur_user_id%ROWTYPE;


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

    -- Getting the Logged on User

    OPEN  cur_user_id ;
    FETCH cur_user_id  INTO l_cur_user_id ;
    CLOSE cur_user_id  ;

     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);


      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => p_programcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_LOCATIONCD', p_Value => p_locationcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PREV_LOCATION_CD', p_Value => p_prev_location_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ATTNDMODE',p_value=>p_attndmode,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PREV_ATTNDMODE', p_Value => p_prev_attndmode, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ATTNDTYPE', p_Value => p_attndtype, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PREV_ATTNDTYPE', p_Value => p_prev_attndtype, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);


       -- Raise the Event


         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.pgofop.update',
                         p_event_key  => 'PROFOPUPDATE'||ln_seq_val,
                         p_parameters => l_parameter_list_t);



   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

  END progofropt_event;

 PROCEDURE enr_notification (  ERRBUF           OUT NOCOPY VARCHAR2 ,
                               RETCODE          OUT NOCOPY NUMBER ,
                               p_acad_cal_type	IN VARCHAR2 ,
                               p_sub_offset_day	IN NUMBER

                            ) IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . This procedure is the executable for the enrollment notifications concurrent program.
  --                         It will identify the overdue submissions and raise a notification for each one of those.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- ckasu     17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
  -------------------------------------------------------------------------------------------------

   CURSOR cur_acad_cal_type IS
    SELECT 1
    FROM igs_ca_type
    WHERE closed_ind='N'
    AND s_cal_cat = 'ACADEMIC'
    AND cal_type = p_acad_cal_type;

    CURSOR cur_offset_days(cp_offset_date igs_re_candidature_all.research_topic%TYPE) IS
    SELECT rec.person_id,rec.max_submission_dt, esp.course_cd, ret.ca_sequence_number, ret.sequence_number
           ,ret.logical_delete_dt,ret.thesis_result_cd , ret.title , rec.sequence_number can_sequence_number
    FROM igs_re_candidature rec,
         igs_en_stdnt_ps_att esp,
	 igs_re_thesis ret
    WHERE  max_submission_dt  IS NOT NULL
           AND max_submission_dt = (trunc(SYSDATE) - cp_offset_date )
	   AND esp.course_cd = rec.sca_course_cd
	   AND esp.person_id = rec.person_id
	   AND esp.cal_type = p_acad_cal_type
	   AND ret.person_id  = rec.person_id
	   AND ret.ca_sequence_number  = rec.sequence_number
	   ORDER BY rec.person_id;

    CURSOR cur_person_number (cp_person_id igs_pe_person.person_id%TYPE) IS
    SELECT person_number,full_name
     FROM  igs_pe_person_base_v
     WHERE person_id = cp_person_id;

    l_cur_person_number cur_person_number%ROWTYPE;

    CURSOR cur_thesis_supervisor(cp_person_id igs_re_sprvsr.person_id%TYPE,
                                 cp_sequence_number igs_re_sprvsr.ca_sequence_number%TYPE) IS
    SELECT  person_id , sequence_number
    FROM igs_re_sprvsr sup
    WHERE ca_person_id        = cp_person_id
    AND   ca_sequence_number  = cp_sequence_number
    AND   (end_dt IS NULL OR end_dt > SYSDATE );

    l_cur_acad_cal_type  cur_acad_cal_type%ROWTYPE;
    l_num NUMBER(1);
    l_supervisor_gr VARCHAR2(4000);
    l_person_id_old igs_pe_person_base_v.person_id%TYPE := NULL;
    l_person_id_new igs_pe_person_base_v.person_id%TYPE := NULL;

  BEGIN

  igs_ge_gen_003.set_org_id(NULL);
  retcode := 0;
  SAVEPOINT s_enr_notify;


  OPEN cur_acad_cal_type;
  FETCH cur_acad_cal_type INTO l_num ;
  CLOSE cur_acad_cal_type ;

     IF (l_num <> 1) THEN

      FND_MESSAGE.Set_Name('IGS','IGS_EN_INVLD_PARAM');
      FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);
      IGS_GE_MSG_STACK.ADD;
      RAISE FND_API.G_EXC_ERROR;

     END IF;


    -- Processing for all the research candidates depending on the Academinc Calander and the Offset days Parametes passed
    -- If this is a negative integer then the submission date of future .
    -- If this is a positive integer then the submission date of past

     FOR l_cur_offset_days IN cur_offset_days(p_sub_offset_day) LOOP

         l_supervisor_gr := null;
	 l_person_id_new := l_cur_offset_days.person_id;

      -- Checking for the thesis records which has a status of pending.

       IF ( igs_re_gen_002.resp_get_the_status(l_cur_offset_days.person_id,
                                               l_cur_offset_days.ca_sequence_number,
					       l_cur_offset_days.sequence_number,
					       'Y',
					       l_cur_offset_days.logical_delete_dt,
					       l_cur_offset_days.thesis_result_cd ) = 'PENDING' ) THEN


          FOR l_cur_thesis_supervisor IN cur_thesis_supervisor(l_cur_offset_days.person_id ,l_cur_offset_days.can_sequence_number) LOOP

            IF (l_supervisor_gr IS NOT NULL) THEN
            l_supervisor_gr := l_supervisor_gr || ',' || l_cur_thesis_supervisor.person_id ;
            ELSE
            l_supervisor_gr := l_cur_thesis_supervisor.person_id ;
	    END IF;

	  END LOOP;

       -- Raising the Overdue Submission Event

          igs_re_workflow.overduesub_event(
	                                     p_personid    => l_cur_offset_days.person_id ,
					     p_programcd   => l_cur_offset_days.course_cd ,
					     p_thesistitle => l_cur_offset_days.title ,
					     p_maxsubdt    => l_cur_offset_days.max_submission_dt ,
					     p_suprvsr     => l_supervisor_gr

	                                  );

	-- Displaying message in the log. Message used in concurrent log to indicate raising of overdue submission event

	    IF l_person_id_old <> l_person_id_new OR l_person_id_old IS NULL  THEN

 	     OPEN cur_person_number(l_person_id_new);
	     FETCH cur_person_number INTO l_cur_person_number;
	     CLOSE cur_person_number ;

             FND_MESSAGE.SET_NAME('IGS','IGS_FI_PERSON_NUM');
             FND_MESSAGE.SET_TOKEN('PERSON_NUM',l_cur_person_number.person_number);
             FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);

  	     l_person_id_old := l_person_id_new;

	    END IF;

            FND_MESSAGE.SET_NAME('IGS','IGS_EN_OVR_SUB');
            FND_MESSAGE.SET_TOKEN('THSS_TTL',l_cur_offset_days.title);
            FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.Get);


       END IF;

     END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO s_enr_notify;
      errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      retcode := 2;
      FND_MESSAGE.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      FND_MESSAGE.SET_TOKEN ('NAME', 'igs_en_workflow.enr_notification(): '
                             || SUBSTR (SQLERRM,1,80));
      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.Get);
      IGS_GE_MSG_STACK.ADD;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END enr_notification;

 PROCEDURE intermission_not(
                        itemtype    IN  VARCHAR2  ,
			itemkey     IN  VARCHAR2  ,
			actid	    IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
			resultout   OUT NOCOPY VARCHAR2 ) AS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . Creates the User Role and find the full name of the student.
  --
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------
   l_date_prod            VARCHAR2(30);
   l_doc_type             VARCHAR2(30);
   l_role_name            VARCHAR2(320);
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSEN002';
   l_person_id_stu        VARCHAR2(4000);
   l_person_id_app        VARCHAR2(4000);
   l_person_id            VARCHAR2(30);

    -- cursor to get the user_name corresponding to the person_id

    CURSOR c_user_name (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  person_party_id = cp_person_id;

    l_user_name   fnd_user.user_name%TYPE;

    CURSOR c_dup_user (cp_user_name VARCHAR2,
                       cp_role_name VARCHAR2) IS
           SELECT count(1)
           FROM WF_LOCAL_USER_ROLES
           WHERE USER_NAME = cp_user_name
           AND ROLE_NAME = cp_role_name
           AND ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
           AND ROLE_ORIG_SYSTEM_ID = 0;

    l_dup_user NUMBER :=0;

    CURSOR c_full_name (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
          SELECT full_name
	  FROM igs_pe_person_base_v
	  WHERE person_id = cp_person_id;

    l_c_full_name  c_full_name%ROWTYPE;

 BEGIN



   IF (funcmode  = 'RUN') THEN
     -- create the adhoc role
     l_role_name := 'IGS'||substr(itemkey,6);

     Wf_Directory.CreateAdHocRole (role_name         => l_role_name,
                                   role_display_name => l_role_display_name
                                  );



     --
     -- fetch student for whom the record has been procesed and add the user name to the
     -- adhoc role
     --
     --

          l_person_id_stu  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
	  l_person_id_app  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_APPROVER');

     -- Getting the Full Name of the Student

           OPEN c_full_name(l_person_id_stu);
	   FETCH c_full_name INTO l_c_full_name;
	   CLOSE c_full_name;

     -- Setting this full name of the student

     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_PERSONNAME',
                                 avalue    =>  l_c_full_name.full_name
			        );

     -- Checking for User Name for the corresponding person ID of a student

           OPEN c_user_name (l_person_id_stu);
	   FETCH c_user_name INTO l_user_name;
           CLOSE c_user_name;



      -- add this user name to the adhoc role if it is not null and unique
	   OPEN c_dup_user(l_user_name,l_role_name);
	   FETCH c_dup_user INTO l_dup_user;
	   CLOSE c_dup_user;

	  IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
	     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                              role_users => l_user_name);
	  END IF;



           OPEN c_user_name (l_person_id_app);
	   FETCH c_user_name INTO l_user_name;
           CLOSE c_user_name;



      -- add the approve to the adhoc role if it is not null and unique
	   OPEN c_dup_user(l_user_name,l_role_name);
	   FETCH c_dup_user INTO l_dup_user;
	   CLOSE c_dup_user;

	  IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
	     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                              role_users => l_user_name);
	  END IF;



     -- now set this role to the workflow
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_ROLE',
                                 avalue    =>  l_role_name
			        );

     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;

END intermission_not;

 PROCEDURE progtrans_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 ) AS

  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . Creates the User Role and find the full name of the student.
  --
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------
   l_date_prod            VARCHAR2(30);
   l_doc_type             VARCHAR2(30);
   l_role_name            VARCHAR2(320);
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSEN003';
   l_person_id_stu        VARCHAR2(4000);
   l_person_id_app        VARCHAR2(4000);
   l_person_id            VARCHAR2(30);

    -- cursor to get the user_name corresponding to the person_id

    CURSOR c_user_name (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  person_party_id = cp_person_id
	   AND ( end_date IS NULL OR end_date > SYSDATE );

    CURSOR c_user_name_admin (cp_person_id fnd_user.user_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  user_id = cp_person_id
	   AND ( end_date IS NULL OR end_date > SYSDATE );


    l_user_name   fnd_user.user_name%TYPE;
    l_user_name_admin fnd_user.user_name%TYPE;

    CURSOR c_dup_user (cp_user_name VARCHAR2,
                       cp_role_name VARCHAR2) IS
           SELECT count(1)
           FROM WF_LOCAL_USER_ROLES
           WHERE USER_NAME = cp_user_name
           AND ROLE_NAME = cp_role_name
           AND ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
           AND ROLE_ORIG_SYSTEM_ID = 0;

    l_dup_user NUMBER :=0;

    CURSOR c_full_name (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
          SELECT full_name
	  FROM igs_pe_person_base_v
	  WHERE person_id = cp_person_id;

    l_c_full_name  c_full_name%ROWTYPE;

 BEGIN



   IF (funcmode  = 'RUN') THEN
     -- create the adhoc role

     l_role_name := 'IGS' || substr(itemkey,6);

     Wf_Directory.CreateAdHocRole (role_name         => l_role_name,
                                   role_display_name => l_role_display_name
                                  );


     --
     -- fetch student for whom the record has been procesed and add the user name to the
     -- adhoc role
     --
     --

          l_person_id_stu  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
	  l_person_id_app  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ADMIN');


     -- Getting the Full Name of the Student

           OPEN c_full_name(l_person_id_stu);
	   FETCH c_full_name INTO l_c_full_name;
	   CLOSE c_full_name;

     -- Setting this full name of the student

     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_PERSONNAME',
                                 avalue    =>  l_c_full_name.full_name
			        );

     -- Checking for User Name for the corresponding person ID of a student

           OPEN c_user_name (l_person_id_stu);
	   FETCH c_user_name INTO l_user_name;
           CLOSE c_user_name;



      -- add this user name to the adhoc role if it is not null and unique
	   OPEN c_dup_user(l_user_name,l_role_name);
	   FETCH c_dup_user INTO l_dup_user;
	   CLOSE c_dup_user;

	  IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
	     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                              role_users => l_user_name);
	  END IF;


      -- Checking for User Name for the corresponding person ID of a Admin
           OPEN c_user_name_admin (l_person_id_app);
	   FETCH c_user_name_admin INTO l_user_name_admin;
           CLOSE c_user_name_admin;

	-- add this user name to the adhoc role if it is not null and unique
	   OPEN c_dup_user(l_user_name_admin,l_role_name);
	   FETCH c_dup_user INTO l_dup_user;
	   CLOSE c_dup_user;

	  IF l_user_name_admin IS NOT NULL AND l_dup_user = 0 THEN
	     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                               role_users => l_user_name_admin);
	  END IF;

     -- now set this role to the workflow
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_ROLE',
                                 avalue    =>  l_role_name
			        );

     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;


 END progtrans_not;

 PROCEDURE progofropt_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 ) AS

  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . Creates the User Role and find the full name of the student.
  --
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------
   l_date_prod            VARCHAR2(30);
   l_doc_type             VARCHAR2(30);
   l_role_name            VARCHAR2(320);
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSEN004';
   l_person_id_stu        VARCHAR2(4000);
   l_person_id_app        VARCHAR2(4000);
   l_person_id            VARCHAR2(30);

    -- cursor to get the user_name corresponding to the person_id

    CURSOR c_user_name (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  person_party_id = cp_person_id;

   -- cursor to get the user_name corresponding to the user_id

    CURSOR c_user_name_admin (cp_person_id fnd_user.user_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  user_id = cp_person_id
	   AND ( end_date IS NULL OR end_date > SYSDATE );

    l_user_name   fnd_user.user_name%TYPE;
    l_user_name_admin fnd_user.user_name%TYPE;

    CURSOR c_dup_user (cp_user_name VARCHAR2,
                       cp_role_name VARCHAR2) IS
           SELECT count(1)
           FROM WF_LOCAL_USER_ROLES
           WHERE USER_NAME = cp_user_name
           AND ROLE_NAME = cp_role_name
           AND ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
           AND ROLE_ORIG_SYSTEM_ID = 0;

    l_dup_user NUMBER :=0;

    CURSOR c_full_name (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
          SELECT full_name
	  FROM igs_pe_person_base_v
	  WHERE person_id = cp_person_id;

    l_c_full_name  c_full_name%ROWTYPE;

 BEGIN



   IF (funcmode  = 'RUN') THEN
     -- create the adhoc role
     l_role_name := 'IGS'||substr(itemkey,6);

     Wf_Directory.CreateAdHocRole (role_name         => l_role_name,
                                   role_display_name => l_role_display_name
                                  );


     --
     -- fetch student for whom the record has been procesed and add the user name to the
     -- adhoc role
     --
     --

          l_person_id_stu  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
	  l_person_id_app  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ADMIN');

     -- Getting the Full Name of the Student

           OPEN c_full_name(l_person_id_stu);
	   FETCH c_full_name INTO l_c_full_name;
	   CLOSE c_full_name;


     -- Setting this full name of the student

     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_PERSONNAME',
                                 avalue    =>  l_c_full_name.full_name
			        );



     -- Checking for User Name for the corresponding person ID of a student

           OPEN c_user_name (l_person_id_stu);
	   FETCH c_user_name INTO l_user_name;
           CLOSE c_user_name;


      -- add this user name to the adhoc role if it is not null and unique
	   OPEN c_dup_user(l_user_name,l_role_name);
	   FETCH c_dup_user INTO l_dup_user;
	   CLOSE c_dup_user;

	  IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
	     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                              role_users => l_user_name);
	  END IF;


       -- Checking for User Name for the corresponding person ID of a Admin
           OPEN c_user_name_admin (l_person_id_app);
	   FETCH c_user_name_admin INTO l_user_name_admin;
           CLOSE c_user_name_admin;

	-- add this user name to the adhoc role if it is not null and unique
	   OPEN c_dup_user(l_user_name_admin,l_role_name);
	   FETCH c_dup_user INTO l_dup_user;
	   CLOSE c_dup_user;



	  IF l_user_name_admin IS NOT NULL AND l_dup_user = 0 THEN
	     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                               role_users => l_user_name_admin);
	  END IF;

     -- now set this role to the workflow
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_ROLE',
                                 avalue    =>  l_role_name
			        );

     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;


 END progofropt_not;

 PROCEDURE progdiscont_not (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 ) AS


 ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . Creates the User Role and find the full name of the student.
  --
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------
   l_date_prod            VARCHAR2(30);
   l_doc_type             VARCHAR2(30);
   l_role_name            VARCHAR2(320);
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSEN005';
   l_person_id_stu        VARCHAR2(4000);
   l_person_id_app        VARCHAR2(4000);
   l_person_id            VARCHAR2(30);

    -- cursor to get the user_name corresponding to the person_id

    CURSOR c_user_name (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  person_party_id = cp_person_id
	   AND ( end_date IS NULL OR end_date > SYSDATE );

    CURSOR c_user_name_admin (cp_person_id fnd_user.user_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  user_id = cp_person_id
	   AND ( end_date IS NULL OR end_date > SYSDATE );


    l_user_name   fnd_user.user_name%TYPE;
    l_user_name_admin fnd_user.user_name%TYPE;

    CURSOR c_dup_user (cp_user_name VARCHAR2,
                       cp_role_name VARCHAR2) IS
           SELECT count(1)
           FROM WF_LOCAL_USER_ROLES
           WHERE USER_NAME = cp_user_name
           AND ROLE_NAME = cp_role_name
           AND ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES'
           AND ROLE_ORIG_SYSTEM_ID = 0;

    l_dup_user NUMBER :=0;

    CURSOR c_full_name (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
          SELECT full_name
	  FROM igs_pe_person_base_v
	  WHERE person_id = cp_person_id;

   -- Get the description of discontinuation reason code
    CURSOR c_discon_rsn (cp_discon_rsn_cd IGS_EN_DCNT_REASONCD.DISCONTINUATION_REASON_CD%TYPE) IS
    SELECT description
      FROM IGS_EN_DCNT_REASONCD
     WHERE DISCONTINUATION_REASON_CD = cp_discon_rsn_cd;

     -- Get the description of discontinuation reason type
    CURSOR c_discon_type (cp_discon_rsn_type igs_lookup_values.lookup_code%TYPE) IS
    SELECT meaning
      FROM IGS_LOOKUP_VALUES
     WHERE lookup_code = cp_discon_rsn_type
       AND lookup_type = 'DISCONTINUATION_REASON_TYPE';

    l_c_discon_rsn c_discon_rsn%ROWTYPE;
    l_c_discon_type c_discon_type%ROWTYPE;
    l_c_full_name  c_full_name%ROWTYPE;

    l_discon_rsn_cd IGS_EN_DCNT_REASONCD.DISCONTINUATION_REASON_CD%TYPE;
    l_discon_rsn_type igs_lookup_values.lookup_code%TYPE;

 BEGIN



   IF (funcmode  = 'RUN') THEN
     -- create the adhoc role
     l_role_name := 'IGS'||substr(itemkey,6);

     Wf_Directory.CreateAdHocRole (role_name         => l_role_name,
                                   role_display_name => l_role_display_name
                                  );


     --
     -- fetch student for whom the record has been procesed and add the user name to the
     -- adhoc role
     --
     --

          l_person_id_stu  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
	  l_person_id_app  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ADMIN');
          l_discon_rsn_cd  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_DISCONTINCD');
          l_discon_rsn_type  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_DISCONTINTYPE');

     -- getting the description of discontinuation reason code
     -- and setting it in internal attribute

       OPEN c_discon_rsn(l_discon_rsn_cd);
       FETCH c_discon_rsn INTO l_c_discon_rsn;
       CLOSE c_discon_rsn;

       Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_DISCON_RSN_DESC',
                                 avalue    =>  l_c_discon_rsn.description
                               );


     -- getting the description of discontinuation type
     -- and setting it in internal attribute

       OPEN c_discon_type(l_discon_rsn_type);
       FETCH c_discon_type INTO l_c_discon_type;
       CLOSE c_discon_type;

       Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_DISCON_TYPE_DESC',
                                 avalue    =>  l_c_discon_type.meaning
                               );

     -- Getting the Full Name of the Student

           OPEN c_full_name(l_person_id_stu);
	   FETCH c_full_name INTO l_c_full_name;
	   CLOSE c_full_name;

     -- Setting this full name of the student

     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_PERSONNAME',
                                 avalue    =>  l_c_full_name.full_name
			        );

     -- Checking for User Name for the corresponding person ID of a student

           OPEN c_user_name (l_person_id_stu);
	   FETCH c_user_name INTO l_user_name;
           CLOSE c_user_name;

          IF l_user_name IS NULL THEN


      -- Checking for User Name for the corresponding person ID of a Admin
             OPEN c_user_name_admin  (l_person_id_app);
  	     FETCH c_user_name_admin  INTO l_user_name_admin ;
             CLOSE c_user_name_admin ;

 	  -- Add this user name to the adhoc role if it is not null and unique

	     OPEN c_dup_user(l_user_name_admin,l_role_name);
	     FETCH c_dup_user INTO l_dup_user;
	     CLOSE c_dup_user;

	     IF l_user_name_admin IS NOT NULL AND l_dup_user = 0 THEN
	        Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                               role_users => l_user_name_admin);
	     END IF;

            resultout := 'COMPLETE:N' ;

           ELSE


         -- add this user name to the adhoc role if it is not null and unique
	    OPEN c_dup_user(l_user_name,l_role_name);
	    FETCH c_dup_user INTO l_dup_user;
	    CLOSE c_dup_user;

	   IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
	      Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                              role_users => l_user_name);
	   END IF;


       -- Checking for User Name for the corresponding person ID of a Admin
           OPEN c_user_name_admin  (l_person_id_app);
  	   FETCH c_user_name_admin INTO l_user_name_admin;
           CLOSE c_user_name_admin ;

	-- add this user name to the adhoc role if it is not null and unique

	   OPEN c_dup_user(l_user_name_admin,l_role_name);
	   FETCH c_dup_user INTO l_dup_user;
	   CLOSE c_dup_user;

	  IF l_user_name_admin IS NOT NULL AND l_dup_user = 0 THEN
	     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                               role_users => l_user_name_admin);
	  END IF;

            resultout := 'COMPLETE:Y' ;

          END IF;

     -- now set this role to the workflow

      Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_ROLE',
                                 avalue    =>  l_role_name
			        );

     RETURN;
   END IF;

   IF ( funcmode = 'CANCEL' ) THEN
     resultout := 'COMPLETE' ;
     return;
   END IF;

   IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
     resultout := '' ;
     return;
   END IF;

 END progdiscont_not;

  PROCEDURE student_placement_event(p_person_id	IN  NUMBER  ,
				p_program_cd	IN  VARCHAR2,
				p_unit_cd	IN  VARCHAR2,
				p_unit_class IN VARCHAR2,
                p_location_cd IN VARCHAR2,
                p_uoo_id IN NUMBER)
  IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Kamalakar, Oracle India (in)
  -- Date created: 18-Nov-2003
  --
  -- Purpose: Business event is raised to send notiifcation to Admin, when a student attempts a placement unit
  -- This procedure is called from unit attempt TBH(IGSEI36B)
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -------------------------------------------------------------------------------------------------

  -- Gets a unique sequence number
    CURSOR c_seq_num IS
    SELECT igs_en_student_placement_s.NEXTVAL
    FROM  dual;

  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment
    CURSOR cur_prof_value IS
    SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Cursor to fetch the person number
    CURSOR cur_pers_number(cp_person_id NUMBER) IS
    SELECT party_number
    FROM hz_parties
    WHERE party_id = cp_person_id;

   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_pers_number    cur_pers_number%ROWTYPE;
   l_event_t             wf_event_t;
   l_parameter_list_t    wf_parameter_list_t;
   l_itemKey             varchar2(100);
   ln_seq_val            NUMBER;

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

    -- Getting the Person number for the given person id
    OPEN cur_pers_number(p_person_id);
    FETCH cur_pers_number INTO l_cur_pers_number;
    CLOSE cur_pers_number;

     --
     -- initialize the wf_event_t object
     --
	 wf_event_t.Initialize(l_event_t);

     --
     -- Adding the parameters to the parameter list
     --
	 wf_event.AddParameterToList (p_name => 'STUDENT_ID',p_value=>p_person_id,p_parameterlist=>l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'PROGRAM_CD', p_Value => p_program_cd, p_ParameterList => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'UNIT_CD', p_Value => p_unit_cd, p_ParameterList => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'UNIT_CLASS', p_Value => p_unit_class, p_ParameterList => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'LOCATION_CD', p_Value => p_location_cd, p_ParameterList => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'UOO_ID', p_Value => p_uoo_id, p_ParameterList => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'STUDENT_NUMBER',p_Value =>l_cur_pers_number.party_number,p_ParameterList =>l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => 'SYSADMIN', p_ParameterList => l_parameter_list_t);

     -- Raise the Event
     WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.en.student.placemnt',
                     p_event_key  => 'STUDPLCMNT'||ln_seq_val,
                     p_parameters => l_parameter_list_t);
   --
   -- Deleting the Parameter list after the event is raised
   --
   l_parameter_list_t.delete;
 END IF;

END student_placement_event;


procedure raise_withdraw_perm_evt (p_n_uoo_id IN NUMBER,
                                   p_c_load_cal IN VARCHAR2,
                                   p_n_load_seq_num IN NUMBER,
                                   p_n_person_id IN NUMBER,
                                   p_c_course_cd IN VARCHAR2,
                                   p_c_approval_type IN VARCHAR2)
------------------------------------------------------------------
  --Created by  : Vijay Rajagopal, Oracle IDC
  --Date created: 11-JUN-2005
  --
  --Purpose: This procedure raises the withraw permission workflow
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  IS

     l_n_key                   NUMBER;
     l_wf_event_t              WF_EVENT_T;
     l_wf_parameter_list_t     WF_PARAMETER_LIST_T;

  CURSOR c_uoo( cp_n_uoo_id IN NUMBER,
                p_c_load_cal IN VARCHAR2,
		p_n_load_seq_num IN NUMBER) IS
  SELECT uoo.unit_cd  || '/' || uoo.unit_class AS UNIT_SECTION,
          uoo.unit_cd,
          uoo.version_number,
          uoo.cal_type,
          uoo.ci_sequence_number,
          uoo.location_cd,
          uoo.unit_class,
          ca.teach_description || ' (' || ca.teach_start_dt || ' - ' || ca.teach_end_dt || ')' teaching_prd,
          ca.load_description
   FROM   IGS_PS_UNIT_OFR_OPT_ALL uoo,
          IGS_CA_TEACH_TO_LOAD_V  ca
   WHERE  uoo.cal_type = ca.teach_cal_type
   AND    uoo.ci_sequence_number  = ca.teach_ci_sequence_number
   AND    uoo.uoo_id = cp_n_uoo_id
   AND    ca.load_cal_type = p_c_load_cal
   AND    ca.load_ci_sequence_number = p_n_load_seq_num;

  rec_uoo c_uoo%ROWTYPE;

  CURSOR c_usec_tch_resp (cp_n_uoo_id IN NUMBER) IS
     SELECT usec.instructor_id
     FROM   igs_ps_usec_tch_resp usec
     WHERE  usec.uoo_id = cp_n_uoo_id
     AND    usec.lead_instructor_flag = 'Y';

  CURSOR c_person_number (cp_n_person_id IN NUMBER) IS
    SELECT person_number
    FROM   igs_pe_person_base_v
    WHERE  person_id = cp_n_person_id;

  CURSOR c_user_name (cp_n_person_id IN NUMBER) IS
    SELECT user_name
    FROM   fnd_user
    WHERE  person_party_id = cp_n_person_id;

  l_t_temp NUMBER;
  l_c_person_num igs_pe_person_base_v.person_number%TYPE;
  l_n_instuctor_id igs_ps_usec_tch_resp.instructor_id%TYPE;
  l_c_user_name fnd_user.user_name%TYPE;
  l_c_perm_type VARCHAR2(2000);

BEGIN
   -- initialize the wf_event_t object
   --
   WF_EVENT_T.Initialize(l_wf_event_t);
   --
   -- set the event name
   --
   l_wf_event_t.setEventName( pEventName => 'oracle.apps.igs.en.withdraw_perm');
   --
   -- event key to identify uniquely
   --
   -- set the parameter list
   --
   l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );
   --
   -- now add the parameters to the parameter list

   OPEN c_uoo(p_n_uoo_id,p_c_load_cal, p_n_load_seq_num);
   FETCH c_uoo INTO rec_uoo;
   CLOSE c_uoo;

   OPEN c_usec_tch_resp (p_n_uoo_id);
   FETCH c_usec_tch_resp INTO l_n_instuctor_id;
   CLOSE c_usec_tch_resp;

   OPEN c_person_number(p_n_person_id);
   FETCH c_person_number INTO l_c_person_num;
   CLOSE c_person_number;

   OPEN c_user_name (l_n_instuctor_id);
   FETCH c_user_name INTO l_c_user_name;
   CLOSE c_user_name;

   IF p_c_approval_type = 'AUDIT_PERM' THEN
      fnd_message.set_name('IGS','IGS_EN_SPL_AUDIT_LINK');
   ELSE
      fnd_message.set_name('IGS','IGS_EN_SS_SPECIAL_PERM');
   END IF;

   l_c_perm_type := fnd_message.get;

   wf_event.AddParameterToList ( p_name => 'PERSON_ID', p_value =>p_n_person_id , p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'PERSON_NUMBER', p_value =>l_c_person_num, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'UOO_ID', p_value =>p_n_uoo_id , p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'UNIT_CD', p_value =>rec_uoo.unit_cd, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'VERSION_NUMBER', p_value =>rec_uoo.version_number, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'UNIT_LOCATION', p_value =>rec_uoo.location_cd, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'UNIT_CLASS', p_value =>rec_uoo.unit_class, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'TEACHING_PRD', p_value =>rec_uoo.teaching_prd, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'LOAD_CAL_DESC', p_value =>rec_uoo.load_description, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'PERM_TYPE', p_value =>l_c_perm_type, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'UNIT_SECTION', p_value =>rec_uoo.unit_section, p_parameterlist => l_wf_parameter_list_t);
   wf_event.AddParameterToList ( p_name => 'LEAD_INSTRUCTOR', p_value =>l_c_user_name, p_parameterlist => l_wf_parameter_list_t);

   --
   -- raise the event

   SELECT igs_en_withdraw_perm_S.nextval INTO l_t_temp from dual;

   wf_event.raise (
                       p_event_name => 'oracle.apps.igs.en.withdraw_perm',
                       p_event_key  =>  'WITHDRAW'||l_t_temp,
                       p_parameters => l_wf_parameter_list_t
                    );
EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK;
          fnd_file.put_line(fnd_file.log,sqlerrm);
END raise_withdraw_perm_evt;

 PROCEDURE raise_spi_rcond_event ( p_person_id             IN NUMBER,
                                   p_program_cd            IN VARCHAR2,
                                   p_intm_type             IN VARCHAR2,
                                   p_changed_rconds        IN VARCHAR2,
                                   p_changed_rconds_desc   IN VARCHAR2) IS

 ------------------------------------------------------------------
   --Created by  : Basanth Devisetty, Oracle IDC
   --Date created: 11-JUN-2005
   --
   --Purpose: This procedure raises the Student Intremission Return Condition
   --         Status Change Event.(Bug# 5083465)
   --
   --Known limitations/enhancements and/or remarks:
   --
   --Change History:
   --Who         When            What
   -------------------------------------------------------------------


   CURSOR cur_seq_val IS
     SELECT igs_en_intm_rcond_s.nextval seq_val
     FROM DUAL;

   CURSOR c_person_dtls (cp_person_id igs_as_ord_itm_int.person_id%TYPE) IS
     SELECT party_number,party_name
     FROM   hz_parties
     WHERE  party_id = cp_person_id;

   l_person_number   hz_parties.party_number%TYPE;
   l_person_name     hz_parties.party_name%TYPE;
   l_user_name       fnd_user.user_name%TYPE;

   l_cur_seq_val         cur_seq_val%ROWTYPE;
   l_wf_parameter_list_t WF_PARAMETER_LIST_T:= wf_parameter_list_t();
   l_wf_installed        fnd_lookups.lookup_code%TYPE;

   BEGIN
     -- get the profile value that is set for checking if workflow is installed
     fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

     -- if workflow is installed then carry on with the raising an event
     IF (RTRIM(l_wf_installed) ='Y') THEN
       -- get the next value of the sequence
       OPEN cur_seq_val;
       FETCH cur_seq_val INTO l_cur_seq_val;
       CLOSE cur_seq_val;

       OPEN c_person_dtls ( p_person_id);
       FETCH c_person_dtls INTO l_person_number,l_person_name;
       CLOSE c_person_dtls;

       l_user_name := FND_GLOBAL.USER_NAME;

       -- set the event parameters
       wf_event.AddParameterToList(p_name=>'P_PERSON_ID', p_value=>p_person_id,  p_parameterlist=>l_wf_parameter_list_t);
       wf_event.AddParameterToList(p_name=>'P_PROGRAM_CD', p_value=>p_program_cd, p_parameterlist=>l_wf_parameter_list_t);
       wf_event.AddParameterToList(p_name=>'P_INTM_TYPE', p_value=>p_intm_type, p_parameterlist=>l_wf_parameter_list_t);
       wf_event.AddParameterToList(p_name=>'P_RCOND_CHG', p_value=>p_changed_rconds, p_parameterlist=>l_wf_parameter_list_t);
       wf_event.AddParameterToList(p_name=>'P_RCOND_CHG_DESC', p_value=>p_changed_rconds_desc, p_parameterlist=>l_wf_parameter_list_t);
       wf_event.AddParameterToList(p_name=>'P_FULL_NAME', p_value=>l_person_name, p_parameterlist=>l_wf_parameter_list_t);
       wf_event.AddParameterToList(p_name=>'P_PERSON_NUMBER', p_value=>l_person_number, p_parameterlist=>l_wf_parameter_list_t);
       wf_event.AddParameterToList(p_name=>'P_USER_NAME', p_value=>l_user_name, p_parameterlist=>l_wf_parameter_list_t);

       -- raise the event
       WF_EVENT.RAISE(p_event_name=>'oracle.apps.igs.en.prog.intm.rcond',
                      p_event_key =>'INTMRCOND'||l_cur_seq_val.seq_val,
                      p_parameters=>l_wf_parameter_list_t);
     END IF;

 END raise_spi_rcond_event;

END igs_en_workflow;

/
