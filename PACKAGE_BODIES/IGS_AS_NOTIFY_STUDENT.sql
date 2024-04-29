--------------------------------------------------------
--  DDL for Package Body IGS_AS_NOTIFY_STUDENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_NOTIFY_STUDENT" AS
/* $Header: IGSAS50B.pls 120.0 2005/07/05 11:30:00 appldev noship $ */



PROCEDURE wf_notify_student(
                             p_busEvent IN  VARCHAR2,
                             p_name IN  VARCHAR2,
                             p_users IN  VARCHAR2,
                             p_subject IN  VARCHAR2,
                             p_message IN  VARCHAR2) AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 21-Sept-2002
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
	         igs_as_wf_beas006_s.NEXTVAL
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


         wf_event.AddParameterToList (p_name=>'IA_NAME',p_value=>p_name,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_USERS', p_Value => p_users, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_SUBJECT', p_Value => p_subject, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_MESSAGE', p_Value => p_message, p_ParameterList => l_parameter_list_t);


       -- Raise the Event



     WF_EVENT.RAISE (p_event_name => p_busEvent,
                     p_event_key  => 'AS006'||ln_seq_val,
                     p_parameters => l_parameter_list_t);


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

END wf_notify_student;

PROCEDURE wf_set_role  (itemtype    IN  VARCHAR2  ,
			itemkey     IN  VARCHAR2  ,
			actid	    IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
			resultout   OUT NOCOPY VARCHAR2
		       ) AS

  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 21-Sept-2002
   Purpose            : This workflow procedure is a wrapper procedure,
                        which will be called from the workflow builder
                        IGSAS006. This would set the adhoc role for the
			notification
   Remarks            :
   Change History
   Who      When        What
  ******************************************************************/

   l_date_prod            VARCHAR2(30);
   l_doc_type             VARCHAR2(30);
   l_role_name            VARCHAR2(320);
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSAS006';
   l_person_id_sep        VARCHAR2(4000);
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

     l_person_id_sep  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'IA_USERS');

     WHILE (LENGTH (l_person_id_sep) > 0)
       LOOP
        IF (INSTR (l_person_id_sep, ',') > 0) THEN
           l_person_id := SUBSTR (l_person_id_sep, 1, INSTR (l_person_id_sep, ',') - 1);
           l_person_id_sep := SUBSTR (l_person_id_sep, INSTR (l_person_id_sep, ',') + 1);

           OPEN c_user_name (l_person_id);
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

        ELSE

	   OPEN c_user_name (l_person_id_sep);
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

          l_person_id := l_person_id_sep;
          l_person_id_sep := NULL;
       END IF;


  END LOOP;

     -- now set this role to the workflow
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_ADHOCROLE',
                                 avalue    =>  l_role_name
			        );

     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;

END wf_set_role;

PROCEDURE wf_launch_as007 (
      p_user IN VARCHAR2,
      p_stud_id IN NUMBER,
      p_stud_number IN VARCHAR2,
      p_stud_name IN VARCHAR2,
      p_order_number IN NUMBER,
      p_item_number IN NUMBER) IS


    lv_item_type        VARCHAR2(100) := 'IGSAS007' ;
    lv_item_key         VARCHAR2(100) :=
'AS007'||to_char(SYSDATE,'YYYYMMDDHH24MISS');

  BEGIN
    -- Create the process
    Wf_Engine.createprocess( ItemType =>  lv_item_type,
                             ItemKey =>   lv_item_key,
        process =>   'P_AS007'
       );
   -- set the attribuites
   Wf_Engine.SetItemAttrText( ItemType =>  lv_item_type,
                               ItemKey  =>  lv_item_key,
                               aname    =>  'IA_USER',
                               avalue   =>  p_user
         );

  Wf_Engine.SetItemAttrText(  ItemType  =>  lv_item_type,
                               ItemKey  =>   lv_item_key,
                               aname    =>   'IA_STUD_ID',
                               avalue   =>   p_stud_id
        );

  Wf_Engine.SetItemAttrText( ItemType  =>  lv_item_type,
                              ItemKey   =>  lv_item_key,
                              aname     =>  'IA_STUD_NUMBER',
                              avalue    =>  p_stud_number
       );

  Wf_Engine.SetItemAttrText( ItemType  =>  lv_item_type,
                              ItemKey   =>  lv_item_key,
                              aname     =>  'IA_STUD_NAME',
                              avalue    =>  p_stud_name
       );
  Wf_Engine.SetItemAttrText( ItemType  =>  lv_item_type,
                              ItemKey   =>  lv_item_key,
                              aname     =>  'IA_ORDER_NUMBER',
                              avalue    =>  p_order_number
       );

  Wf_Engine.SetItemAttrText( ItemType  =>  lv_item_type,
                              ItemKey   =>  lv_item_key,
                              aname     =>  'IA_ITEM_NUMBER',
                              avalue    =>  p_item_number
       );

  Wf_Engine.StartProcess   ( ItemType  =>  lv_item_type,
                             ItemKey   =>  lv_item_key
                          );

   -- Handle the exception using WF_CORE.Context
  EXCEPTION

  WHEN OTHERS THEN
    Wf_Core.Context('IGS_AS_NOTIFY_STUDENT', 'WF_LAUNCH_AS007',
lv_item_type, lv_item_key);
    RAISE;

END wf_launch_as007;



PROCEDURE raise_rel_subdate_event (
	p_unit_cd           IN VARCHAR2,
	p_term              IN VARCHAR2,
	p_location          IN VARCHAR2,
	p_title             IN VARCHAR2,
	p_teaching_cal      IN VARCHAR2,
	p_sec_number        IN VARCHAR2,
	p_instructor        IN NUMBER,
	p_ass_id            IN NUMBER,
	p_ass_type          IN VARCHAR2,
	p_reference         IN VARCHAR2 ,
	p_grading_period    IN VARCHAR2,
	p_rel_sub_dt        IN VARCHAR2 ,
	p_event             IN VARCHAR2
       ) IS
  /*************************************************************
  Created By :Deepankar
  Date Created on : 9-Nov-2003
  Purpose : This procedure will be called to launch workflow IGSAS006.
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    ln_seq_val            NUMBER;

    -- Gets a unique sequence number

    CURSOR c_seq_num IS
          SELECT igs_as_reldate_s.NEXTVAL
          FROM  dual;


  -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment

    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
	FROM dual;

  -- Getting the user name to whom the notification to be send

    CURSOR c_user_name IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE  person_party_id = p_instructor;

 -- Getting the logged in User

    CURSOR cur_from_user IS
        SELECT user_name
	   FROM   fnd_user
	   WHERE  user_id = (SELECT  FND_GLOBAL.USER_ID user_id FROM dual);

   l_cur_prof_value     cur_prof_value%ROWTYPE;
   l_cur_from_user      fnd_user.user_name%TYPE;
   l_c_user_name        fnd_user.user_name%TYPE;

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

    OPEN cur_from_user;
    FETCH cur_from_user INTO l_cur_from_user;
    CLOSE cur_from_user ;

    OPEN c_user_name;
    FETCH c_user_name INTO l_c_user_name;
    CLOSE c_user_name ;

     --
     -- initialize the wf_event_t object
     --

	 wf_event_t.Initialize(l_event_t);


      --
      -- Adding the parameters to the parameter list
      --

	 wf_event.AddParameterToList (p_name => 'P_UNIT_CD',p_value=>p_unit_cd,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_TERM', p_Value => p_term, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_LOCATION', p_Value => p_location, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_TITLE', p_Value => p_title, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_TEACHING_CAL', p_Value => p_teaching_cal, p_ParameterList => l_parameter_list_t);
	 wf_event.AddParameterToList (p_name => 'P_SEC_NUMBER',p_value=>p_sec_number,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_INSTRUCTOR', p_Value => p_instructor, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ASS_ID', p_Value => p_ass_type, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_ASS_TYPE', p_Value => p_title, p_ParameterList => l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'P_REFERENCE', p_Value => p_reference, p_ParameterList => l_parameter_list_t);
	 wf_event.AddParameterToList (p_name => 'IA_FROM_ROLE',p_value=>l_c_user_name,p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList (p_name => 'IA_USER_ROLE', p_Value => l_c_user_name, p_ParameterList => l_parameter_list_t);


	  IF (p_event = 'RELDATE') THEN

           wf_event.AddParameterToList (p_name => 'P_RELEASE_DT', p_Value => p_rel_sub_dt, p_ParameterList => l_parameter_list_t);


         -- Raise the Release Grade Business Event

          WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.as.aigrdrel',
                          p_event_key  => 'IGSAS010'||ln_seq_val,
                          p_parameters => l_parameter_list_t);



          ELSIF (p_event = 'SUBDATE') THEN

           wf_event.AddParameterToList (p_name => 'P_SUB_DT', p_Value => p_rel_sub_dt, p_ParameterList => l_parameter_list_t);
           wf_event.AddParameterToList (p_name => 'P_GRADING_PERIOD', p_Value => p_grading_period, p_ParameterList => l_parameter_list_t);

          -- Raise the Submit Grade Business Event

           WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.as.usgrdsub',
                           p_event_key  => 'IGSAS011'||ln_seq_val,
                           p_parameters => l_parameter_list_t);

	  END IF;


   --
   -- Deleting the Parameter list after the event is raised
   --

     l_parameter_list_t.delete;

   END IF;

END raise_rel_subdate_event;


PROCEDURE set_adhoc_role  (itemtype    IN  VARCHAR2  ,
			itemkey     IN  VARCHAR2  ,
			actid	    IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
			resultout   OUT NOCOPY VARCHAR2
		       ) AS

  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 21-Sept-2002
   Purpose            : This workflow procedure is a wrapper procedure,
                        which will be called from the workflow builder
                        IGSAS006. This would set the adhoc role for the
			notification
   Remarks            :
   Change History
   Who      When        What
  ******************************************************************/

   l_date_prod            VARCHAR2(30);
   l_doc_type             VARCHAR2(30);
   l_role_name            VARCHAR2(320);
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSAS0101';
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

           l_person_id  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_INSTRUCTOR');

           OPEN c_user_name (l_person_id);
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

     -- now set this role to the workflow
     Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_USER_ROLE',
                                 avalue    =>  l_role_name
			        );


     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;

END set_adhoc_role;


END igs_as_notify_student;

/
