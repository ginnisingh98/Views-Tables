--------------------------------------------------------
--  DDL for Package Body IGS_PR_PROG_OUT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_PROG_OUT_WF_PKG" AS
/* $Header: IGSPR36B.pls 120.0 2005/07/05 12:02:40 appldev noship $ */



PROCEDURE find_prog_out_notification(
                         itemtype    IN VARCHAR2,
                         itemkey     IN VARCHAR2,
                         actid	     IN NUMBER,
                         funcmode    IN VARCHAR2,
                         resultout   IN OUT NOCOPY VARCHAR2
			 )      AS
  /******************************************************************
   Created By         : Deepankar Dey
   Date Created By    : 30-Sept-2002
   Purpose            : This procedure catches the event and it decides which notification
                        is to be send .
   Change History
   Who      When        What
  ******************************************************************/



    l_event_name            VARCHAR2(2000);
    l_show_cause_expiry_dt  VARCHAR2(100);
    l_appeal_expiry_dt      VARCHAR2(100);
    l_person_id             NUMBER;



     -- cursor to get the user_name corresponding to the person_id

    CURSOR c_user_name (cp_person_id igs_pe_person.person_id%TYPE) IS
           SELECT user_name
	   FROM   fnd_user
	   WHERE person_party_id = cp_person_id;

   CURSOR c_student_info (cp_person_id igs_pe_person.person_id%TYPE) IS
           SELECT person_pre_name_adjunct,party_name
	   FROM hz_parties
           WHERE party_id = cp_person_id ;

   CURSOR c_program_title (cp_course_cd igs_ps_ver.course_cd%TYPE) IS
           SELECT title
	   FROM igs_ps_ver
           WHERE course_cd  = cp_course_cd ;

       l_user_name   fnd_user.user_name%TYPE;
       l_person_pre_name_adjunct  hz_parties.person_pre_name_adjunct%TYPE;
       l_party_name hz_parties.party_name%TYPE;
       l_title  igs_ps_ver.title%TYPE ;
       l_course_cd igs_ps_ver.course_cd%TYPE ;


  BEGIN


  l_event_name  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'IA_EVENT_NAME');
  l_show_cause_expiry_dt := Wf_Engine.GetItemAttrText(itemtype,itemkey,'IA_SHOW_CAUSE_EXPIRY_DT');
  l_appeal_expiry_dt  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'IA_APPEAL_EXPIRY_DT');
  l_person_id  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'IA_PERSON_ID');
  l_course_cd  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'IA_COURSE_CD');


  OPEN c_user_name(l_person_id);
  FETCH c_user_name INTO l_user_name;
  CLOSE c_user_name ;

  OPEN c_student_info (l_person_id);
  FETCH c_student_info INTO l_person_pre_name_adjunct,l_party_name;
  CLOSE c_student_info;

  OPEN c_program_title (l_course_cd);
  FETCH c_program_title INTO l_title;
  CLOSE c_program_title;

  IF (l_event_name = 'oracle.apps.igs.pr.approve_otcm') THEN

     IF ((l_show_cause_expiry_dt IS NOT NULL) AND (l_appeal_expiry_dt IS NOT NULL )) THEN


          -- This part of the package would be customized as per the customer requirement .
          NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- which has the Message in the Message Body, which will show Show Cause Expiry Date and Appeal Expiry Date

          resultout := 'COMPLETE:DEFAULT';

     ELSIF ((l_show_cause_expiry_dt IS NOT NULL) AND (l_appeal_expiry_dt IS NULL )) THEN



          -- This is to route flow to the correcponding Notification Activity ,
	  -- which has the Message in the Message Body, which will show only  Show Cause Expiry Date

          resultout := 'COMPLETE:TWO';



	 -- Setting the values for the User Name

          Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                     ItemKey   =>  itemkey,
                                     aname     =>  'IA_USER_NAME',
                                     avalue    =>  l_user_name
			           );

         -- Setting the values for the Person Name

          Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                     ItemKey   =>  itemkey,
                                     aname     =>  'IA_PERSON_NAME',
                                     avalue    =>  l_party_name
			           );


         -- Setting the values for the Person Pre Name Adjunct

          Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                     ItemKey   =>  itemkey,
                                     aname     =>  'IA_PERSON_PREFIX',
                                     avalue    =>  l_person_pre_name_adjunct
			           );

         -- Setting the values for the Person Pre Name Adjunct

          Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                     ItemKey   =>  itemkey,
                                     aname     =>  'IA_PROGRAM_TITLE',
                                     avalue    =>  l_title
			           );



     ELSIF ((l_show_cause_expiry_dt IS NULL) AND (l_appeal_expiry_dt IS NOT NULL )) THEN


          -- This part of the package would be customized as per the customer requirement .
            NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- which has the Message in the Message Body, which will show only  Appeal Expiry Date

          resultout := 'COMPLETE:DEFAULT';

     ELSIF ((l_show_cause_expiry_dt IS NULL) AND (l_appeal_expiry_dt IS NOT NULL )) THEN

          -- This part of the package would be customized as per the customer requirement .
            NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- which has the Message in the Message Body, which will show message without Show Cause Expiry Date and Appeal Expiry Date

          resultout := 'COMPLETE:DEFAULT';

    END IF ;

  ELSIF (l_event_name = 'oracle.apps.igs.pr.apply_positive_otcm') THEN


          -- This part of the package would be customized as per the customer requirement .
          NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- correcponding Notification Activity , which has the corresponding Message in the Message Body

          resultout := 'COMPLETE:DEFAULT';

   ELSIF (l_event_name = 'oracle.apps.igs.pr.apply_otcm') THEN

          -- This part of the package would be customized as per the customer requirement .
          NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- correcponding Notification Activity , which has the corresponding Message in the Message Body

          resultout := 'COMPLETE:DEFAULT';

    ELSIF (l_event_name = 'oracle.apps.igs.pr.showcause_uph_dsm') THEN

          -- This part of the package would be customized as per the customer requirement .
          NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- correcponding Notification Activity , which has the corresponding Message in the Message Body

          resultout := 'COMPLETE:DEFAULT';

    ELSIF (l_event_name = 'oracle.apps.igs.pr.appeal_uph_dsm') THEN


          -- This part of the package would be customized as per the customer requirement .
          NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- correcponding Notification Activity , which has the corresponding Message in the Message Body

          resultout := 'COMPLETE:DEFAULT';

    ELSIF (l_event_name = 'oracle.apps.igs.pr.remove_waive_cancel_otcm') THEN

          -- This part of the package would be customized as per the customer requirement .
          NULL;

          -- This is to route flow to the correcponding Notification Activity ,
	  -- correcponding Notification Activity , which has the corresponding Message in the Message Body

          resultout := 'COMPLETE:DEFAULT';
    END IF;


 END find_prog_out_notification;


END igs_pr_prog_out_wf_pkg;

/
