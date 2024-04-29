--------------------------------------------------------
--  DDL for Package Body IGS_RE_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_WORKFLOW" AS
/* $Header: IGSRE21B.pls 120.1 2006/01/17 04:20:11 ckasu noship $ */

 /******************************************************************
  Created By         :Deepankar Dey
  Date Created By    :18-Jul-2001
  Purpose            :This package implements procedure concerned to workflow
  remarks            :
  Change History
  Who      When        What
  DDEY 8-Sep-2003 The changes are done as per the
                  Enrollments Notifications TD Bug # 3052429
  stutta 13-Apr-2005 Replaced all references to FND_USER.customer_id to
                     FND_USER.person_party_id. Bug #4293911
  ckasu  17-JAN-2006  Added igs_ge_gen_003.set_org_id(NULL)
                     in enrp_assign_timeslot procedure as a part of bug#4958173.
 ******************************************************************/

CURSOR  c_research( p_person_id  igs_pe_person.person_id%TYPE,
                    p_seq_num igs_re_candidature.sequence_number%TYPE) IS
               SELECT sca_course_cd, research_topic
	       FROM igs_re_candidature
	       WHERE person_id = p_person_id
	       AND sequence_number = p_seq_num;

CURSOR  c_thesis ( p_person_id  igs_pe_person.person_id%TYPE,
                   p_ca_seq_num igs_re_thesis.ca_sequence_number%TYPE,
		   p_seq_num igs_re_thesis.sequence_number%TYPE) IS
               SELECT title, thesis_topic
 	       FROM igs_re_thesis
	       WHERE person_id = p_person_id
	       AND ca_sequence_number=p_ca_seq_num
	       AND sequence_number=p_seq_num;


PROCEDURE get_supervisor(
                        p_personid	      IN    NUMBER,
                        p_ca_sequence_number  IN    NUMBER ,
                        p_supervisor	      OUT NOCOPY  VARCHAR2
                        )  AS
 ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 05-Sept-2003
  --
  -- Purpose: The changes are done as per the Enrollments Notifications TD Bug # 3052429
  --          The procedure is used to get the supervisors.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
 -------------------------------------------------------------------------------------------------

  CURSOR cur_get_supervisor( p_ca_person_id igs_re_sprvsr.ca_person_id%TYPE,
                             p_ca_sequence_number igs_re_sprvsr.ca_sequence_number%TYPE) IS
      SELECT person_id
      FROM igs_re_sprvsr
      WHERE ca_person_id = p_ca_person_id
      AND ca_sequence_number = p_ca_sequence_number ;


BEGIN

    FOR l_cur_get_supervisor IN cur_get_supervisor(p_personid,p_ca_sequence_number) LOOP

     IF (p_supervisor IS NOT NULL) THEN

      p_supervisor := p_supervisor || ',' || l_cur_get_supervisor.person_id ;

     ELSE

      p_supervisor := l_cur_get_supervisor.person_id ;

     END IF;

    END LOOP;


END get_supervisor;


PROCEDURE get_panel_member(
                        p_personid	      IN    NUMBER,
                        p_ca_sequence_number  IN    NUMBER ,
                        p_the_sequence_number IN    NUMBER ,
                        p_creation_dt	      IN    DATE ,
                        p_panel_member	      OUT NOCOPY  VARCHAR2
                        )  AS
 ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 05-Sept-2003
  --
  -- Purpose: This procedure would return the panel members for a thesis in a concatenated format
  --          with ',' as the delimiter.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
 -------------------------------------------------------------------------------------------------

  CURSOR cur_get_panelmem( p_ca_person_id igs_re_ths_pnl_mbr.ca_person_id%TYPE,
                             p_ca_sequence_number igs_re_ths_pnl_mbr.ca_sequence_number%TYPE,
			     p_the_sequence_number igs_re_ths_pnl_mbr.the_sequence_number%TYPE,
			     p_creation_dt igs_re_ths_pnl_mbr.creation_dt%TYPE) IS
      SELECT person_id
      FROM igs_re_ths_pnl_mbr
      WHERE ca_person_id = p_personid
        AND ca_sequence_number= p_ca_sequence_number
	AND the_sequence_number= p_the_sequence_number
	AND creation_dt= p_creation_dt ;

BEGIN

    FOR l_cur_get_panelmem IN cur_get_panelmem(p_personid,p_ca_sequence_number,p_the_sequence_number,p_creation_dt) LOOP

     IF (p_panel_member IS NOT NULL) THEN

      p_panel_member := p_panel_member || ',' || l_cur_get_panelmem.person_id ;

     ELSE

      p_panel_member := l_cur_get_panelmem.person_id ;

     END IF;

    END LOOP;


END get_panel_member;


PROCEDURE   retopic_event (
				p_personid	IN NUMBER ,
				p_programcd	IN VARCHAR2 ,
				p_restopic	IN VARCHAR2
                            )  IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . UK Correspondence.The TBH needs to be modified to invoke the thesis topic change business event when thesis topic
  --                         is changed.
  --
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
          SELECT igs_re_retopc_s.NEXTVAL
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
         wf_event.AddParameterToList (p_name => 'P_RESTOPIC', p_Value => p_restopic, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);


       -- Raise the Event

         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.restop.update',
                         p_event_key  => 'RESTOPUPDATE'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

 END retopic_event;

PROCEDURE  rethesis_event (
				p_personid	IN NUMBER ,
				p_ca_seq_num	IN NUMBER ,
				p_thesistopic	IN VARCHAR2 ,
				p_thesistitle	IN VARCHAR2 ,
				p_approved	IN VARCHAR2 ,
				p_deleted	IN VARCHAR2
                                   ) IS
  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . UK Correspondence.The TBH needs to be modified to invoke the thesis event is raised
  --                         when there is a change in thesis attributes.
  --
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
          SELECT igs_re_thesis_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

 -- Getting the course Code for the research canditure

    CURSOR cur_course_cd IS
       SELECT sca_course_cd
       FROM igs_re_candidature
       WHERE person_id = p_personid
       AND sequence_number = p_ca_seq_num;

   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_user_id      cur_user_id%ROWTYPE;
   l_cur_course_cd    cur_course_cd%ROWTYPE;


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

    -- Getting the course Code for the research canditure

    OPEN cur_course_cd;
    FETCH cur_course_cd INTO l_cur_course_cd;
    CLOSE cur_course_cd;

     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);



      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => l_cur_course_cd.sca_course_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESISTOPIC', p_Value => p_thesistopic, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESISTITLE', p_Value => p_thesistitle, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_APPROVED', p_Value => p_approved, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DELETED', p_Value => p_deleted, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);

       -- Raise the Event

         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.thesis.update',
                         p_event_key  => 'THESISUPDATE'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

END rethesis_event;

PROCEDURE supervision_event (
				p_personid	IN NUMBER  ,
				p_ca_seq_num	IN NUMBER ,
				p_supervisorid	IN NUMBER ,
				p_startdt	IN DATE ,
				p_enddt	        IN DATE ,
				p_spr_percent	IN NUMBER ,
				p_spr_type	IN VARCHAR2,
				p_fund_percent	IN NUMBER ,
				p_org_unit_cd	IN VARCHAR2 ,
				p_rep_person_id	IN VARCHAR2 ,
				p_rep_seq_num	IN NUMBER
                                ) IS

  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . UK Correspondence.Raises the supervision event when supervisor attributes of a student changes.
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
          SELECT igs_re_sprvsn_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

 -- Getting the course Code for the research canditure

    CURSOR cur_course_cd IS
       SELECT sca_course_cd
       FROM igs_re_candidature
       WHERE person_id = p_personid
       AND sequence_number = p_ca_seq_num;

 -- Getting the Start Date for the research Supervisor.

   CURSOR cur_res_start_dt IS
     SELECT
     start_dt
     FROM igs_re_sprvsr
     WHERE
     ca_person_id = p_personid
     AND ca_sequence_number = p_ca_seq_num
     AND person_id = p_rep_person_id
     AND sequence_number  = p_rep_seq_num ;

   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_user_id      cur_user_id%ROWTYPE;
   l_cur_course_cd    cur_course_cd%ROWTYPE;
   l_cur_res_start_dt cur_res_start_dt%ROWTYPE;
   l_staff_ind  VARCHAR2(1);

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

    -- Getting the course Code for the research canditure

    OPEN cur_course_cd;
    FETCH cur_course_cd INTO l_cur_course_cd;
    CLOSE cur_course_cd;

    -- Getting the Start Date for the research Supervisor.

    OPEN cur_res_start_dt ;
    FETCH cur_res_start_dt INTO l_cur_res_start_dt;
    CLOSE cur_res_start_dt;
     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);


     l_staff_ind := IGS_EN_GEN_003.GET_STAFF_IND(p_supervisorid);

      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROG_CD', p_Value => l_cur_course_cd.sca_course_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUPERVISORID', p_Value => p_supervisorid, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_STAFF_IND', p_Value => l_staff_ind, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_STARTDT', p_Value => p_startdt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ENDDT', p_Value => p_enddt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SPR_PERCENT', p_Value => p_spr_percent, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SPR_TYPE', p_Value => p_spr_type, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_FUND_PERCENT', p_Value => p_fund_percent, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ORG_UNIT_CD', p_Value => p_org_unit_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_REP_PERSON_ID', p_Value => p_rep_person_id, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_REP_STARTDT', p_Value => l_cur_res_start_dt.start_dt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);

       -- Raise the Event

         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.sprvsn.update',
                         p_event_key  => 'SPRVSNUPDATE'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

END supervision_event;

 PROCEDURE overduesub_event (
 			p_personid	IN NUMBER   ,
			p_programcd	IN VARCHAR2,
			p_thesistitle	IN VARCHAR2,
			p_maxsubdt	IN DATE,
			p_suprvsr	IN VARCHAR2
     ) IS

  ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 30-04-2003
  --
  -- Purpose:Bug # 2829275 . This procedure would trigger the overdue submission business event.
  --         It is triggered from a concurrent process that identified whether any submissions are overdue.
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
          SELECT igs_en_ovrsub_s.NEXTVAL
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
         wf_event.AddParameterToList (p_name => 'P_THESISTITLE', p_Value => p_thesistitle, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_MAXSUBDT', p_Value => p_maxsubdt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUPRVSR',p_value=>p_suprvsr,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);


       -- Raise the Event


         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.subm.overdue',
                         p_event_key  => 'SUBMOVERDUE'||ln_seq_val,
                         p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;


 END overduesub_event ;

 PROCEDURE retopic_not (
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
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSRE001';
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
     l_role_name := 'IGS'|| itemkey ;

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


      -- Checking for User Name for the corresponding person ID of a approver
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


 END retopic_not;

 PROCEDURE thesis_not (
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
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSRE002';
   l_person_id_stu        VARCHAR2(50);
   l_person_id_app        VARCHAR2(50);
   l_person_id            VARCHAR2(30);
   l_delete               VARCHAR2(10);
   l_approved             VARCHAR2(10);
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

    CURSOR c_mesg_text (cp_message_name fnd_new_messages.message_name%TYPE) IS
          SELECT message_text
	  FROM  fnd_new_messages
	  WHERE message_name = cp_message_name;

    l_c_mesg_text c_mesg_text%ROWTYPE;

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
          l_delete         := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_DELETED');
          l_approved       := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_APPROVED');



     -- Setting the value of the attribute IA_APPROVED_MSG  based on the P_APPROVED value.

          IF l_approved = 'N' THEN

	   OPEN c_mesg_text('IGS_EN_NOT');
	   FETCH c_mesg_text INTO l_c_mesg_text;
	   CLOSE c_mesg_text ;

      -- Setting this the attribute IA_APPROVED_MSG


	      Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
					  ItemKey   =>  itemkey,
					  aname     =>  'IA_APPROVED_MSG',
	 				  avalue    =>  l_c_mesg_text.message_text
					);

	  END IF;


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
       Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                                  ItemKey   =>  itemkey,
                                  aname     =>  'IA_ROLE',
                                  avalue    =>  l_role_name
			        );


     IF (l_delete = 'Y') THEN

     resultout := 'COMPLETE:Y' ;
     RETURN;

     ELSIF (l_delete = 'N' or l_delete IS NULL ) THEN

     resultout := 'COMPLETE:N' ;
     RETURN;

     END IF;

     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;


 END thesis_not;

 PROCEDURE supervision_not (
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
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSRE003';
   l_person_id_stu        VARCHAR2(50);
   l_person_id_suvisor    VARCHAR2(50);
   l_person_id_app        VARCHAR2(50);
   l_person_id            VARCHAR2(30);
   l_staff_ind            VARCHAR2(10);
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


    l_user_name_stu   fnd_user.user_name%TYPE;
    l_user_name_adm   fnd_user.user_name%TYPE;
    l_user_name_sup   fnd_user.user_name%TYPE;

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
    l_c_full_name_sup  c_full_name%ROWTYPE;

    CURSOR c_mesg_text (cp_message_name fnd_new_messages.message_name%TYPE) IS
          SELECT message_text
	  FROM  fnd_new_messages
	  WHERE message_name = cp_message_name;

    l_c_mesg_text c_mesg_text%ROWTYPE;

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

          l_person_id_stu      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
          l_person_id_suvisor  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_SUPERVISORID');
	  l_person_id_app      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ADMIN');
          l_staff_ind          := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_STAFF_IND');



     -- Setting the value of the attribute IA_APPROVED_MSG  based on the P_APPROVED value.

          IF l_staff_ind = 'N' THEN

	   OPEN c_mesg_text('IGS_EN_NOT');
	   FETCH c_mesg_text INTO l_c_mesg_text;
	   CLOSE c_mesg_text ;

      -- Setting this the attribute IA_APPROVED_MSG

	      Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
					  ItemKey   =>  itemkey,
					  aname     =>  'IA_STAFF_IND',
	 				  avalue    =>  l_c_mesg_text.message_text
					);

	  END IF;


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


      -- Getting the Full Name of the Supervisor

	   OPEN c_full_name(l_person_id_suvisor);
           FETCH c_full_name INTO l_c_full_name_sup;
	   CLOSE c_full_name;

          Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
  				      ItemKey   =>  itemkey,
				      aname     =>  'P_SUPERVISORNAME',
	 			      avalue    =>  l_c_full_name_sup.full_name
				    );



     -- Checking for User Name for the corresponding person ID of a student

           OPEN c_user_name (l_person_id_stu);
	   FETCH c_user_name INTO l_user_name_stu;
           CLOSE c_user_name;

      -- add this user name to the adhoc role if it is not null and unique

	     IF ( l_user_name_stu IS NOT NULL ) THEN

		   OPEN c_dup_user(l_user_name_stu,l_role_name);
		   FETCH c_dup_user INTO l_dup_user;
		   CLOSE c_dup_user;

		  IF l_user_name_stu IS NOT NULL AND l_dup_user = 0 THEN
		     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
						       role_users => l_user_name_stu);
 		  END IF;
             END IF;


      -- Checking for User Name for the corresponding person ID of a ADMIN

           OPEN c_user_name_admin (l_person_id_app);
	   FETCH c_user_name_admin INTO l_user_name_adm;
           CLOSE c_user_name_admin;

/***
	-- add this user name to the adhoc role if it is not null and unique

             IF ( l_user_name_adm IS NOT NULL ) THEN

		   OPEN c_dup_user(l_user_name_adm,l_role_name);
		   FETCH c_dup_user INTO l_dup_user;
		   CLOSE c_dup_user;

		  IF l_user_name_adm IS NOT NULL AND l_dup_user = 0 THEN
		     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
						       role_users => l_user_name_adm);
		  END IF;

             END IF;
***/
      -- Checking for User Name for the corresponding Supervisor

           OPEN c_user_name (l_person_id_suvisor);
	   FETCH c_user_name INTO l_user_name_sup;
           CLOSE c_user_name;

    -- add this user name to the adhoc role if it is not null and unique

            IF ( l_user_name_sup IS NOT NULL ) THEN

		   OPEN c_dup_user(l_user_name_sup,l_role_name);
		   FETCH c_dup_user INTO l_dup_user;
		   CLOSE c_dup_user;

		  IF l_user_name_sup IS NOT NULL AND l_dup_user = 0 THEN
		     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
						       role_users => l_user_name_sup);
		  END IF;

            END IF;

      -- now set this role to the workflow
	       Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
					 ItemKey   =>  itemkey,
					 aname     =>  'IA_ROLE',
					 avalue    =>  l_role_name
					);



	     IF (l_user_name_stu IS NULL AND  l_user_name_sup IS NULL ) THEN

              -- Setting this full name of the student

 	        Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
	      			          ItemKey   =>  itemkey,
					  aname     =>  'IA_PERSON1',
					  avalue    =>  l_c_full_name.full_name
					  );



  	     -- Setting this full name of the Supervisor

		    Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
		    			        ItemKey   =>  itemkey,
						aname     =>  'IA_PERSON2',
						avalue    =>  l_c_full_name_sup.full_name
						);

            -- Add the admin to the role
            IF ( l_user_name_adm IS NOT NULL ) THEN

                Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                            ItemKey   =>  itemkey,
                                            aname     =>  'IA_ADMIN_USER',
                                            avalue    =>  l_user_name_adm
                                          );
              END IF;

            resultout := 'COMPLETE:ADMIN' ;
            RETURN;

  	      ELSIF (l_user_name_stu IS NOT NULL AND  l_user_name_sup  IS NULL ) THEN

		   -- Setting this full name of the Supervisor

		    Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
		    			        ItemKey   =>  itemkey,
						aname     =>  'IA_PERSON1',
						avalue    =>  l_c_full_name_sup.full_name
						);

            -- Add the admin to the role
            IF ( l_user_name_adm IS NOT NULL ) THEN

                Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                            ItemKey   =>  itemkey,
                                            aname     =>  'IA_ADMIN_USER',
                                            avalue    =>  l_user_name_adm
                                          );

            END IF;


  	            resultout := 'COMPLETE:BOTH' ;
	            RETURN;

	       ELSIF (l_user_name_stu IS NULL AND  l_user_name_sup IS NOT NULL ) THEN

                    -- Setting this full name of the student

			Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
						   ItemKey   =>  itemkey,
						   aname     =>  'IA_PERSON1',
						   avalue    =>  l_c_full_name.full_name
						   );

            -- Add the admin to the role
            IF ( l_user_name_adm IS NOT NULL ) THEN

                Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                            ItemKey   =>  itemkey,
                                            aname     =>  'IA_ADMIN_USER',
                                            avalue    =>  l_user_name_adm
                                          );
            END IF;

            resultout := 'COMPLETE:BOTH' ;
            RETURN;


	       ELSIF (l_user_name_stu IS NOT NULL AND  l_user_name_sup IS NOT NULL ) THEN

            -- Add the admin to the role
            IF ( l_user_name_adm IS NOT NULL ) THEN

              OPEN c_dup_user(l_user_name_adm,l_role_name);
              FETCH c_dup_user INTO l_dup_user;
              CLOSE c_dup_user;

              IF l_user_name_adm IS NOT NULL AND l_dup_user = 0 THEN
                Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                                  role_users => l_user_name_adm);
              END IF;

            END IF;

    	                resultout := 'COMPLETE:ALL' ;
	                RETURN;

  	       END IF;


          Resultout:= 'COMPLETE:';
          RETURN;

      END IF;

 END supervision_not;

 PROCEDURE overduesub_not (
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
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSRE004';
   l_person_id_stu        VARCHAR2(50);
   l_person_id_suvisor    VARCHAR2(50);
   l_person_id_app        VARCHAR2(50);
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

    l_user_name_stu   fnd_user.user_name%TYPE;
    l_user_name_adm   fnd_user.user_name%TYPE;
    l_user_name       fnd_user.user_name%TYPE;
    l_sup_name VARCHAR2(32000);

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

    CURSOR c_mesg_text (cp_message_name fnd_new_messages.message_name%TYPE) IS
          SELECT message_text
	  FROM  fnd_new_messages
	  WHERE message_name = cp_message_name;

    l_c_mesg_text c_mesg_text%ROWTYPE;

    l_supervisor_flag VARCHAR2(5) := 'TRUE';
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

          l_person_id_stu      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
          l_person_id_suvisor  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_SUPRVSR');
	  l_person_id_app      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ADMIN');

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
	   FETCH c_user_name INTO l_user_name_stu;
           CLOSE c_user_name;

      -- add this user name to the adhoc role if it is not null and unique


	     IF ( l_user_name_stu IS NOT NULL ) THEN

		   OPEN c_dup_user(l_user_name_stu,l_role_name);
		   FETCH c_dup_user INTO l_dup_user;
		   CLOSE c_dup_user;

		  IF l_user_name_stu IS NOT NULL AND l_dup_user = 0 THEN
		     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
						       role_users => l_user_name_stu);
 		  END IF;
             END IF;


      -- Checking for User Name for the corresponding person ID of a ADMIN

        OPEN c_user_name_admin (l_person_id_app);
        FETCH c_user_name_admin INTO l_user_name_adm;
        CLOSE c_user_name_admin;

      -- Checking for User Name for the corresponding Supervisor

     WHILE (LENGTH (l_person_id_suvisor) > 0)
       LOOP

        -- getting the person ID for supervisor from the concatenated string
        IF (INSTR (l_person_id_suvisor, ',') > 0) THEN
           l_person_id := SUBSTR (l_person_id_suvisor, 1, INSTR (l_person_id_suvisor, ',') - 1);
           l_person_id_suvisor := SUBSTR (l_person_id_suvisor, INSTR (l_person_id_suvisor, ',') + 1);

        ELSE

          l_person_id := l_person_id_suvisor;
          l_person_id_suvisor := NULL;

       END IF;
          l_user_name := NULL;
          OPEN c_user_name (l_person_id);
          FETCH c_user_name INTO l_user_name;
          CLOSE c_user_name;

        -- IF the l_user_name is null
          IF l_user_name IS NULL THEN
            -- Getting the full name of the Supervisor
           OPEN c_full_name(l_person_id);
           FETCH c_full_name INTO l_c_full_name;
           CLOSE c_full_name;

           IF l_supervisor_flag = 'FALSE' THEN
             l_sup_name := l_sup_name || ', ';
           ELSE
             l_supervisor_flag := 'FALSE';
           END IF;

           l_sup_name := l_sup_name || l_c_full_name.full_name;

          ELSE
        	-- add this user name to the adhoc role if it is not null and unique
           OPEN c_dup_user(l_user_name,l_role_name);
           FETCH c_dup_user INTO l_dup_user;
           CLOSE c_dup_user;

           IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
             Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                             role_users => l_user_name);
           END IF;
         END IF;

     END LOOP;


      -- Setting the Adhoc Role Attribute

        Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                       ItemKey   =>  itemkey,
                       aname     =>  'IA_ROLE',
                       avalue    =>  l_role_name);


	     IF (l_user_name_stu IS NULL AND  l_supervisor_flag = 'FALSE' ) THEN

            -- Setting this full name of the student
            OPEN c_full_name(l_person_id_stu);
            FETCH c_full_name INTO l_c_full_name;
            CLOSE c_full_name;

 	        Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
	      			          ItemKey   =>  itemkey,
					  aname     =>  'IA_PERSON1',
					  avalue    =>  l_c_full_name.full_name
					  );



		   -- Setting this full name of the Supervisor

		    Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
		    			        ItemKey   =>  itemkey,
						aname     =>  'IA_PERSON2',
						avalue    =>  l_sup_name
						);

            -- setting admin to IA for performer of admin notification
            IF ( l_user_name_adm IS NOT NULL ) THEN

              Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                                       ItemKey   =>  itemkey,
                                       aname     =>  'IA_ADMIN_USER',
                                       avalue    =>  l_user_name_adm
                                       );

            END IF;

  	            resultout := 'COMPLETE:ADMIN' ;
	            RETURN;

  	      ELSIF (l_user_name_stu IS NOT NULL AND  l_supervisor_flag = 'FALSE' ) THEN

		   -- Setting this full name of the Supervisor

		    Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
		    			        ItemKey   =>  itemkey,
						aname     =>  'IA_PERSON1',
						avalue    =>  l_sup_name
						);

            -- setting admin to IA for performer of admin notification
            IF ( l_user_name_adm IS NOT NULL ) THEN

              Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                                       ItemKey   =>  itemkey,
                                       aname     =>  'IA_ADMIN_USER',
                                       avalue    =>  l_user_name_adm
                                       );

            END IF;

                resultout := 'COMPLETE:BOTH' ;
	            RETURN;

	       ELSIF (l_user_name_stu IS NULL AND  l_supervisor_flag = 'TRUE' ) THEN

            -- Setting this full name of the student

           OPEN c_full_name(l_person_id_stu);
           FETCH c_full_name INTO l_c_full_name;
           CLOSE c_full_name;

			Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
						   ItemKey   =>  itemkey,
						   aname     =>  'IA_PERSON1',
						   avalue    =>  l_c_full_name.full_name
						   );

            -- setting admin to IA for performer of admin notification
            IF ( l_user_name_adm IS NOT NULL ) THEN

              Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                                       ItemKey   =>  itemkey,
                                       aname     =>  'IA_ADMIN_USER',
                                       avalue    =>  l_user_name_adm
                                       );
            END IF;

            resultout := 'COMPLETE:BOTH' ;
            RETURN;

	       ELSIF (l_user_name_stu IS NOT NULL AND  l_supervisor_flag = 'TRUE') THEN

            -- adding admin to the role
            IF ( l_user_name_adm IS NOT NULL ) THEN

              OPEN c_dup_user(l_user_name_adm,l_role_name);
              FETCH c_dup_user INTO l_dup_user;
              CLOSE c_dup_user;

              IF l_user_name_adm IS NOT NULL AND l_dup_user = 0 THEN
                Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                                  role_users => l_user_name_adm);
              END IF;

            END IF;

    	                resultout := 'COMPLETE:ALL' ;
	                RETURN;

  	       END IF;

          Resultout:= 'COMPLETE:';
          RETURN;

      END IF;

   END overduesub_not;

  PROCEDURE milestone_event(
			   p_personid     IN   NUMBER  	,
			   p_ca_seq_num	  IN   NUMBER   ,
			   p_milestn_typ  IN   VARCHAR2 ,
			   p_milestn_stat IN   VARCHAR2 ,
			   p_due_dt	  IN   DATE     ,
			   p_dt_reached	  IN   DATE     ,
			   p_deleted	  IN   VARCHAR2
                           )  AS
 ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 05-Sept-2003
  --
  -- Purpose: The changes are done as per the Enrollments Notifications TD Bug # 3052429
  --          The procedure raises the milestone event.
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
    l_programcd           igs_re_candidature.sca_course_cd%TYPE;
    l_res_topic           igs_re_candidature.research_topic%TYPE;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_re_milstn_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

  --
   CURSOR cur_prog_ver ( p_person_id  igs_pe_person.person_id%TYPE,
                         p_course_cd  igs_ps_ver.course_cd%TYPE)IS
      SELECT course_cd , version_number, attendance_type
      FROM igs_en_stdnt_ps_att
      WHERE person_id = p_person_id
      AND course_cd = p_course_cd ;

   CURSOR cur_def_milestone ( p_course_cd       igs_re_dflt_ms_set.course_cd%TYPE,
                              p_version_number  igs_re_dflt_ms_set.version_number%TYPE,
                              p_attendance_type igs_re_dflt_ms_set.attendance_type%TYPE
                             ) IS
      SELECT 1
      FROM  igs_re_dflt_ms_set
      WHERE
      course_cd       =  p_course_cd AND
      version_number  =  p_version_number AND
      attendance_type =  p_attendance_type ;


   l_cur_prof_value   cur_prof_value%ROWTYPE;
   l_cur_user_id      cur_user_id%ROWTYPE;
   l_cur_prog_ver     cur_prog_ver%ROWTYPE;
   ln_def_milestone NUMBER;
   l_source VARCHAR2(100);
   l_supervisor VARCHAR2(32000);


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




       OPEN c_research(p_personid,p_ca_seq_num);
       FETCH c_research INTO l_programcd,l_res_topic;
       CLOSE c_research;

       OPEN  cur_prog_ver(p_personid,l_programcd);
       FETCH cur_prog_ver INTO l_cur_prog_ver;
       CLOSE cur_prog_ver;

       OPEN cur_def_milestone(l_programcd,l_cur_prog_ver.version_number,l_cur_prog_ver.attendance_type);
       FETCH cur_def_milestone INTO ln_def_milestone ;
       CLOSE cur_def_milestone  ;


       IF (ln_def_milestone = 1) THEN
        l_source := 'DEFAULT';
       ELSE
	l_source := 'MANUAL';
       END IF;


      igs_re_workflow.get_supervisor(
                                    p_personid           =>  p_personid ,
                                    p_ca_sequence_number =>  p_ca_seq_num,
                                    p_supervisor         =>  l_supervisor
				    );


      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => l_programcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_RESTOPIC', p_Value => l_res_topic, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_MILESTN_TYP', p_Value => p_milestn_typ , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DUEDT', p_Value => p_due_dt , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_MILESTN_STAT', p_Value => p_milestn_stat, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DT_REACHED', p_Value => p_dt_reached, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_MILESTN_SRC', p_Value => l_source, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_NOMI_ATT_TYP', p_Value => l_cur_prog_ver.attendance_type, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DELETED', p_Value => p_deleted, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUPERVISOR', p_Value => l_supervisor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);



       -- Raise the Event

           WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.milestone.change',
                         p_event_key  => 'MILESTONEEVENT'||ln_seq_val,
                         p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --


     l_parameter_list_t.delete;

   END IF;

  END milestone_event;




PROCEDURE thesis_exam_event(
			  p_personid	        IN NUMBER ,
			  p_ca_sequence_number	IN NUMBER ,
			  p_the_sequence_number	IN NUMBER ,
			  p_creation_dt	        IN DATE ,
			  p_submission_dt	IN DATE ,
			  p_thesis_exam_type	IN VARCHAR2
                             )  AS
 ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 05-Sept-2003
  --
  -- Purpose: The changes are done as per the Enrollments Notifications TD Bug # 3052429
  --          The procedure raises the milestone event.
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
    l_programcd           igs_re_candidature.sca_course_cd%TYPE;
    l_res_topic           igs_re_candidature.research_topic%TYPE;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_re_exmsub_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

  --
   CURSOR cur_prog_stat ( p_person_id  igs_pe_person.person_id%TYPE,
                          p_course_cd  igs_ps_ver.course_cd%TYPE)IS
       SELECT course_attempt_status
       FROM igs_en_stdnt_ps_att
       WHERE person_id = p_person_id
       AND course_cd = p_course_cd ;


   l_cur_prof_value    cur_prof_value%ROWTYPE;
   l_cur_user_id       cur_user_id%ROWTYPE;
   l_cur_prog_stat     cur_prog_stat%ROWTYPE;
   l_panel_member      VARCHAR2(32000);
   l_the_topic         igs_re_thesis.thesis_topic%TYPE;
   l_title             igs_re_thesis.title%TYPE;
   l_supervisor        VARCHAR2(32000);


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


       OPEN c_research(p_personid,p_ca_sequence_number);
       FETCH c_research INTO l_programcd,l_res_topic;
       CLOSE c_research;

       OPEN c_thesis ( p_personid,p_ca_sequence_number,p_the_sequence_number);
       FETCH c_thesis INTO l_the_topic , l_title;
       CLOSE c_thesis ;

       OPEN  cur_prog_stat(p_personid,l_programcd);
       FETCH cur_prog_stat INTO l_cur_prog_stat;
       CLOSE cur_prog_stat;


        igs_re_workflow.get_panel_member(
                                       p_personid	      => p_personid,
                                       p_ca_sequence_number   => p_ca_sequence_number,
                                       p_the_sequence_number  => p_the_sequence_number,
                                       p_creation_dt	      => p_creation_dt,
                                       p_panel_member	      => l_panel_member
                                        ) ;


       igs_re_workflow.get_supervisor(
                                    p_personid           =>  p_personid ,
                                    p_ca_sequence_number =>  p_ca_sequence_number,
                                    p_supervisor         =>  l_supervisor
				    );

      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => l_programcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_RESTOPIC', p_Value => l_res_topic, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_TPC', p_Value => l_the_topic , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_TITLE', p_Value => l_title , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUB_ON', p_Value => p_submission_dt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SPA_STAT', p_Value => l_cur_prog_stat.course_attempt_status, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_EXM_TYP', p_Value => p_thesis_exam_type, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_EXM_PNL', p_Value => l_panel_member, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUPERVISOR', p_Value => l_supervisor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);



       -- Raise the Event

         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.thesis.examsub',
                         p_event_key  => 'THESISEXAMEVENT'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

 END thesis_exam_event;


 PROCEDURE thesis_result_event(
			  p_personid	        IN NUMBER ,
			  p_ca_sequence_number	IN NUMBER,
			  p_the_sequence_number	IN NUMBER ,
			  p_creation_dt	        IN DATE ,
			  p_submission_dt	IN DATE ,
			  p_thesis_exam_type	IN VARCHAR2 ,
			  p_thesis_result_cd	IN VARCHAR2 ) AS
------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 05-Sept-2003
  --
  -- Purpose: The changes are done as per the Enrollments Notifications TD Bug # 3052429
  --          The procedure raises the milestone event.
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
    l_programcd           igs_re_candidature.sca_course_cd%TYPE;
    l_res_topic           igs_re_candidature.research_topic%TYPE;

   -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_re_resupd_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;



   l_cur_prof_value    cur_prof_value%ROWTYPE;
   l_cur_user_id       cur_user_id%ROWTYPE;
   l_panel_member      VARCHAR2(32000);
   l_the_topic         igs_re_thesis.thesis_topic%TYPE;
   l_title             igs_re_thesis.title%TYPE;
   l_supervisor        VARCHAR2(32000);


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


       OPEN c_research(p_personid,p_ca_sequence_number);
       FETCH c_research INTO l_programcd,l_res_topic;
       CLOSE c_research;

       OPEN c_thesis ( p_personid,p_ca_sequence_number,p_the_sequence_number);
       FETCH c_thesis INTO l_the_topic , l_title;
       CLOSE c_thesis ;


        igs_re_workflow.get_panel_member(
                                       p_personid	      => p_personid,
                                       p_ca_sequence_number   => p_ca_sequence_number,
                                       p_the_sequence_number  => p_the_sequence_number,
                                       p_creation_dt	      => p_creation_dt,
                                       p_panel_member	      => l_panel_member
                                        ) ;


       igs_re_workflow.get_supervisor(
                                    p_personid           =>  p_personid ,
                                    p_ca_sequence_number =>  p_ca_sequence_number,
                                    p_supervisor         =>  l_supervisor
				    );


      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => l_programcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_RESTOPIC', p_Value => l_res_topic, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_TPC', p_Value => l_the_topic , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_TITLE', p_Value => l_title , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUB_ON', p_Value => p_submission_dt, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_RSLT', p_Value => p_thesis_result_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_EXM_TYP', p_Value => p_thesis_exam_type, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_THESIS_EXM_PNL', p_Value => l_panel_member, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUPERVISOR', p_Value => l_supervisor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);


       -- Raise the Event


         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.thesis.resultupd',
                         p_event_key  => 'THESISRESULTEVENT'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

      --
      -- Deleting the Parameter list after the event is raised
      --

         l_parameter_list_t.delete;

     END IF;

   END thesis_result_event;

PROCEDURE confirm_reg_event (
                          p_personid	 IN NUMBER  ,
                          p_programcd	 IN VARCHAR2,
                          p_spa_start_dt  IN DATE ,
			  p_prog_attempt_stat IN VARCHAR2

                             ) AS
------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 05-Sept-2003
  --
  -- Purpose: The changes are done as per the Enrollments Notifications TD Bug # 3052429
  --          The procedure raises the milestone event.
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
    l_programcd           igs_re_candidature.sca_course_cd%TYPE;
    l_res_topic           igs_re_candidature.research_topic%TYPE;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_re_regcfm_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;


    CURSOR cur_res_top (p_personid igs_pe_person_base_v.person_id%TYPE,
                        p_programcd  igs_ps_ver.course_cd%TYPE ) IS
        SELECT research_topic,sequence_number
        FROM igs_re_candidature
        WHERE person_id = p_personid
        AND sca_course_cd = p_programcd ;

    CURSOR cur_course_type (p_programcd igs_ps_ver.course_cd%TYPE ) IS
         SELECT course_type
	 FROM igs_ps_ver
	 WHERE course_cd=p_programcd ;

l_cur_res_top  cur_res_top%ROWTYPE;
l_cur_course_type cur_course_type%ROWTYPE;
l_supervisor  VARCHAR2(32000);
l_cur_prof_value    cur_prof_value%ROWTYPE;
l_cur_user_id       cur_user_id%ROWTYPE;

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



       OPEN cur_res_top(p_personid,p_programcd);
       FETCH cur_res_top INTO l_cur_res_top;
       CLOSE cur_res_top;

       OPEN cur_course_type(p_programcd);
       FETCH cur_course_type INTO l_cur_course_type;
       CLOSE cur_course_type;

      igs_re_workflow.get_supervisor(
                                    p_personid           =>  p_personid ,
                                    p_ca_sequence_number =>  l_cur_res_top.sequence_number,
                                    p_supervisor         =>  l_supervisor
				    );

      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>p_personid,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => p_programcd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_RESTOPIC', p_Value => l_cur_res_top.research_topic, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SPA_START_DT', p_Value => p_spa_start_dt , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAM_TYP', p_Value => l_cur_course_type.course_type, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMSTAT', p_Value => p_prog_attempt_stat, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUPERVISOR', p_Value => l_supervisor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);


       -- Raise the Event

         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.registration.confirm',
                         p_event_key  => 'CONFIRMREGEVENT'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

       --
       -- Deleting the Parameter list after the event is raised
       --

         l_parameter_list_t.delete;

   END IF;

 END confirm_reg_event;

PROCEDURE milstn_notify_prcs ( ERRBUF           OUT NOCOPY VARCHAR2 ,
                               RETCODE          OUT NOCOPY NUMBER ) AS
------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 05-Sept-2003
  --
  -- Purpose: The changes are done as per the Enrollments Notifications TD Bug # 3052429
  --          The procedure raises the milestone event.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- ckasu           17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
  -------------------------------------------------------------------------------------------------

  -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_re_milnot_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

 -- Getting the logged in User

    CURSOR cur_user_id IS
       SELECT  FND_GLOBAL.USER_ID user_id
       FROM dual;

 -- Identifying all the student program attempts which are not in the program attempt status of 'DISCONTIN' or 'LAPSED'
 -- and have a research record.

 CURSOR cur_prog_atmpt IS
     SELECT spa.person_id, spa.course_cd, re.sequence_number, spa.attendance_type, re.research_topic
     FROM igs_en_stdnt_ps_att spa, igs_re_candidature re
     WHERE spa.person_id = re.person_id
     AND   spa.course_cd = re.sca_course_cd
     AND   spa.course_attempt_status NOT IN ('LAPSED','DISCONTIN');

-- For each person program attempt identified above select the milestone records, which do not have the
-- status of 'ACHIEVED' and the due date is less than SYSDATE.

 CURSOR cur_achived_milestone ( p_person_id igs_pe_person_base_v.person_id%TYPE,
                                p_seq_num  igs_pr_milestone.ca_sequence_number%TYPE
                               )IS
     SELECT a.due_dt, NVL(ovrd_ntfctn_imminent_days, b.NTFCTN_IMMINENT_DAYS) ovrd_ntfctn_imminent_days,
            nvl(ovrd_ntfctn_reminder_days, b.NTFCTN_REMINDER_DAYS) ovrd_ntfctn_reminder_days,
            nvl(ovrd_ntfctn_re_reminder_days, b.NTFCTN_RE_REMINDER_DAYS) ovrd_ntfctn_re_reminder_days, a.milestone_status, a.milestone_type
     FROM igs_pr_milestone a,
        igs_pr_milestone_typ b
     WHERE a.person_id = p_person_id
     AND a.ca_sequence_number = p_seq_num
     AND a.milestone_status <> 'ACHIEVED'
     AND TRUNC(a.due_dt) >= TRUNC(SYSDATE)
     AND a.milestone_type = b.milestone_type ;


  l_cur_achived_milestone cur_achived_milestone%ROWTYPE;
  l_cur_prog_atmpt        cur_prog_atmpt%ROWTYPE;
  l_notifydays            NUMBER;
  l_notifytype            VARCHAR2(30);
  l_supervisor            VARCHAR2(32000);
  l_cur_prof_value        cur_prof_value%ROWTYPE;
  l_cur_user_id           cur_user_id%ROWTYPE;
  ln_seq_val              NUMBER;
  l_event_t               wf_event_t;
  l_parameter_list_t      wf_parameter_list_t;
  l_itemKey               varchar2(100);
  l_flag                  NUMBER := 0;

  BEGIN

  igs_ge_gen_003.set_org_id(NULL);
  retcode := 0;
  SAVEPOINT sp_milstn_notify_prcs;

  -- Checking if the Workflow is installed at the environment or not.

    OPEN cur_prof_value;
    FETCH cur_prof_value INTO l_cur_prof_value;
    CLOSE cur_prof_value;


    IF (l_cur_prof_value.value = 'Y') THEN


    -- Getting the Logged on User

     OPEN  cur_user_id ;
     FETCH cur_user_id  INTO l_cur_user_id ;
     CLOSE cur_user_id  ;



    FOR l_cur_prog_atmpt IN cur_prog_atmpt LOOP


       igs_re_workflow.get_supervisor(
                                 p_personid           => l_cur_prog_atmpt.person_id ,
                                 p_ca_sequence_number => l_cur_prog_atmpt.sequence_number ,
                                 p_supervisor         => l_supervisor
                                      );


      FOR l_cur_achived_milestone IN cur_achived_milestone(l_cur_prog_atmpt.person_id,l_cur_prog_atmpt.sequence_number) LOOP


     --
     -- initialize the wf_event_t object
     --


	 wf_event_t.Initialize(l_event_t);

     -- Get the sequence value

       OPEN  c_seq_num;
       FETCH c_seq_num INTO ln_seq_val ;
       CLOSE c_seq_num ;

       l_flag := 0;

       IF ( TRUNC(l_cur_achived_milestone.due_dt) = TRUNC(SYSDATE)  ) THEN

         l_notifydays:=0 ;
	 l_notifytype:='DUE' ;
	 l_flag := 1;

       ELSIF ( (TRUNC(l_cur_achived_milestone.due_dt) - NVL(l_cur_achived_milestone.ovrd_ntfctn_re_reminder_days,0) ) = TRUNC(SYSDATE) ) THEN

         l_notifydays := NVL(l_cur_achived_milestone.ovrd_ntfctn_re_reminder_days,0) ;
	 l_notifytype := 'REREMIND';
	 l_flag := 1;

       ELSIF  ((TRUNC(l_cur_achived_milestone.due_dt) - NVL(l_cur_achived_milestone.ovrd_ntfctn_reminder_days,0)) = TRUNC(SYSDATE)) THEN

         l_notifydays := NVL(l_cur_achived_milestone.ovrd_ntfctn_reminder_days,0) ;
	 l_notifytype := 'REMIND';
	 l_flag := 1;

       ELSIF ((TRUNC(l_cur_achived_milestone.due_dt) - NVL(l_cur_achived_milestone.ovrd_ntfctn_imminent_days,0)) = TRUNC(SYSDATE) ) THEN

        l_notifydays := NVL(l_cur_achived_milestone.ovrd_ntfctn_imminent_days,0) ;
        l_notifytype := 'IMMI';
        l_flag := 1;

      END IF;

       IF ( l_flag = 1 ) THEN

       --
       -- Adding the parameters to the parameter list
       --

	 wf_event.AddParameterToList (p_name => 'P_PERSONID',p_value=>l_cur_prog_atmpt.person_id,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_PROGRAMCD', p_Value => l_cur_prog_atmpt.course_cd, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_RESTOPIC', p_Value => l_cur_prog_atmpt.research_topic, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_MILESTN_TYP', p_Value => l_cur_achived_milestone.milestone_type , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_DUEDT', p_Value => l_cur_achived_milestone.due_dt , p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_MILESTN_STAT', p_Value => l_cur_achived_milestone.milestone_status, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_NOTIFY_DAYS', p_Value => l_notifydays, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_NOTIFYTYPE', p_Value => l_notifytype, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_NOMI_ATT_TYP', p_Value => l_cur_prog_atmpt.attendance_type, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_SUPERVISOR', p_Value => l_supervisor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ADMIN', p_Value => l_cur_user_id.user_id, p_ParameterList => l_parameter_list_t);



       -- Raise the Event

         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.re.milestone.notify' ,
                         p_event_key  => 'MILSTNNOTIFYPRCS'||ln_seq_val,
                         p_parameters => l_parameter_list_t);

       --
       -- Deleting the Parameter list after the event is raised
       --

         l_parameter_list_t.delete;

       END IF;

     END LOOP;

   END LOOP;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO sp_milstn_notify_prcs;
      errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      retcode := 2;
      FND_MESSAGE.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      FND_MESSAGE.SET_TOKEN ('NAME', 'igs_re_workflow.milstn_notify_prcs(): '
                             || SUBSTR (SQLERRM,1,80));
      FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.Get);
      IGS_GE_MSG_STACK.ADD;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;


 END milstn_notify_prcs;


 PROCEDURE create_adhoc_role (
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2 ) AS

 ------------------------------------------------------------------------------------------------
  -- Created by  : Deepankar Dey, Oracle India (in)
  -- Date created: 16-Sept-2003
  --
  -- Purpose:
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
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role';
   l_person_id_stu        VARCHAR2(50);
   l_person_id_suvisor    VARCHAR2(50);
   l_person_id_app        VARCHAR2(50);
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

    l_user_name_stu   fnd_user.user_name%TYPE;
    l_user_name_adm   fnd_user.user_name%TYPE;
    l_user_name       fnd_user.user_name%TYPE;
    l_sup_name VARCHAR2(32000);

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

    CURSOR c_mesg_text (cp_message_name fnd_new_messages.message_name%TYPE) IS
          SELECT message_text
	  FROM  fnd_new_messages
	  WHERE message_name = cp_message_name;

    l_c_mesg_text c_mesg_text%ROWTYPE;

    l_supervisor_flag VARCHAR2(5) := 'TRUE';
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


          l_person_id_stu      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
          l_person_id_suvisor  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_SUPERVISOR');
	  l_person_id_app      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ADMIN');


     -- Checking for User Name for the corresponding person ID of a student

           OPEN c_user_name (l_person_id_stu);
	   FETCH c_user_name INTO l_user_name_stu;
           CLOSE c_user_name;

      -- add this user name to the adhoc role if it is not null and unique

	     IF ( l_user_name_stu IS NOT NULL ) THEN

		   OPEN c_dup_user(l_user_name_stu,l_role_name);
		   FETCH c_dup_user INTO l_dup_user;
		   CLOSE c_dup_user;

		  IF l_user_name_stu IS NOT NULL AND l_dup_user = 0 THEN
		     Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
						       role_users => l_user_name_stu);
 		  END IF;

             END IF;


      -- Checking for User Name for the corresponding person ID of a ADMIN

          OPEN c_user_name_admin (l_person_id_app);
          FETCH c_user_name_admin INTO l_user_name_adm;
          CLOSE c_user_name_admin;


      -- adding admin to the role

	   IF ( l_user_name_adm IS NOT NULL ) THEN

             OPEN c_dup_user(l_user_name_adm,l_role_name);
             FETCH c_dup_user INTO l_dup_user;
             CLOSE c_dup_user;

             IF l_user_name_adm IS NOT NULL AND l_dup_user = 0 THEN
               Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                                 role_users => l_user_name_adm);
             END IF;

           END IF;


     -- Checking for User Name for the corresponding Supervisor

     WHILE (LENGTH (l_person_id_suvisor) > 0)
       LOOP

        -- getting the person ID for supervisor from the concatenated string
        IF (INSTR (l_person_id_suvisor, ',') > 0) THEN
           l_person_id := SUBSTR (l_person_id_suvisor, 1, INSTR (l_person_id_suvisor, ',') - 1);
           l_person_id_suvisor := SUBSTR (l_person_id_suvisor, INSTR (l_person_id_suvisor, ',') + 1);

        ELSE

          l_person_id := l_person_id_suvisor;
          l_person_id_suvisor := NULL;

        END IF;

          l_user_name := NULL;
          OPEN c_user_name (l_person_id);
          FETCH c_user_name INTO l_user_name;
          CLOSE c_user_name;

        -- IF the l_user_name is null
          IF l_user_name IS NULL THEN
            -- Getting the full name of the Supervisor
           OPEN c_full_name(l_person_id);
           FETCH c_full_name INTO l_c_full_name;
           CLOSE c_full_name;

           IF l_supervisor_flag = 'FALSE' THEN
             l_sup_name := l_sup_name || ', ';
           ELSE
             l_supervisor_flag := 'FALSE';
           END IF;

           l_sup_name := l_sup_name || l_c_full_name.full_name;

          ELSE
        	-- add this user name to the adhoc role if it is not null and unique
           OPEN c_dup_user(l_user_name,l_role_name);
           FETCH c_dup_user INTO l_dup_user;
           CLOSE c_dup_user;

           IF l_user_name IS NOT NULL AND l_dup_user = 0 THEN
             Wf_Directory.AddUsersToAdHocRole (role_name  => l_role_name,
                                             role_users => l_user_name);
           END IF;
         END IF;

     END LOOP;

      -- Setting the Adhoc Role Attribute

       Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                      ItemKey   =>  itemkey,
                      aname     =>  'P_ROLE',
                      avalue    =>  l_role_name);

       Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                      ItemKey   =>  itemkey,
                      aname     =>  'P_FROM_ROLE',
                      avalue    =>  l_user_name_adm);

         Resultout:= 'COMPLETE:';
         RETURN;

    END IF;

   END create_adhoc_role;

PROCEDURE confirm_reg_not(
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2
                    ) AS

  l_person_id        VARCHAR2(50);

    CURSOR c_person_info (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
          SELECT full_name , person_number
	  FROM igs_pe_person_base_v
	  WHERE person_id = cp_person_id;

   CURSOR c_status (l_lookup_code fnd_lookups.lookup_code%TYPE)IS
         SELECT meaning
	 FROM  igs_lookups_view
	 WHERE lookup_type = 'VS_EN_COURSE_ATMPT_STATUS'
	 AND lookup_code = l_lookup_code ;

  l_c_person_info c_person_info%ROWTYPE;
  l_c_status c_status%ROWTYPE;
  l_lookup fnd_lookups.lookup_code%TYPE;

 BEGIN

 igs_re_workflow.create_adhoc_role( itemtype  => itemtype ,
				   itemkey   => itemkey ,
				   actid     => actid ,
				   funcmode  => funcmode ,
				   resultout => resultout
				   );

  l_person_id      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');
  l_lookup         := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PROGRAMSTAT');

  OPEN  c_person_info(l_person_id);
  FETCH c_person_info INTO l_c_person_info;
  CLOSE c_person_info;

  Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                             ItemKey   =>  itemkey,
                             aname     =>  'IA_PERSON_NUMBER',
                             avalue    =>  l_c_person_info.person_number);


  OPEN  c_status(l_lookup);
  FETCH c_status INTO l_c_status;
  CLOSE c_status;

  Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                             ItemKey   =>  itemkey,
                             aname     =>  'IA_PROG_STATUS',
                             avalue    =>  l_c_status.meaning);


  Resultout:= 'COMPLETE:';
  RETURN;


END confirm_reg_not;


PROCEDURE milstn_notify_not(
                           itemtype    IN  VARCHAR2 ,
			   itemkey     IN  VARCHAR2 ,
			   actid       IN  NUMBER   ,
                           funcmode    IN  VARCHAR2 ,
			   resultout   OUT NOCOPY VARCHAR2
                    ) AS

  l_person_id        VARCHAR2(50);

    CURSOR c_person_info (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
          SELECT full_name , person_number
	  FROM igs_pe_person_base_v
	  WHERE person_id = cp_person_id;


  l_c_person_info c_person_info%ROWTYPE;

 BEGIN

 igs_re_workflow.create_adhoc_role( itemtype  => itemtype ,
				   itemkey   => itemkey ,
				   actid     => actid ,
				   funcmode  => funcmode ,
				   resultout => resultout
				   );

  l_person_id      := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_PERSONID');

  OPEN  c_person_info(l_person_id);
  FETCH c_person_info INTO l_c_person_info;
  CLOSE c_person_info;

  Wf_Engine.SetItemAttrText( ItemType  =>  itemtype,
                             ItemKey   =>  itemkey,
                             aname     =>  'IA_PERSON_NUMBER',
                             avalue    =>  l_c_person_info.person_number);



  Resultout:= 'COMPLETE:';
  RETURN;


END milstn_notify_not;

END igs_re_workflow;

/
