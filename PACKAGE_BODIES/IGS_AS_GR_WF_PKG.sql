--------------------------------------------------------
--  DDL for Package Body IGS_AS_GR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GR_WF_PKG" AS
/* $Header: IGSAS55B.pls 120.0 2005/07/05 11:29:44 appldev noship $ */

/* ***********************************************************************************************************/
  -- Procedure : Select_Approver
  --This Procedure relates to selecting an Approver (Admin or Lead Instructor), to whom this
  --Notification of Grade Submission has to be sent. It is  just a notification, it does not
  --require any response from Approver/ Admin/ Lead Instructor ( who ever is it, based upon the
  --Organization hierarch  set by the Institute or Organization)
/* **********************************************************************************************************/


PROCEDURE   Select_Approver (
                                                       Itemtype        IN           VARCHAR2,
                                                       Itemkey         IN           VARCHAR2,
                                                       Actid                IN           NUMBER,
                                                       Funcmode       IN           VARCHAR2,
                                                       Resultout        OUT NOCOPY        VARCHAR2
                                                     )
/*=============================================================================================================+
 |
 | Change History
 | Who	     When			What
 | Aiyer     07-25-2002                 Fix done for the bug 2403814.
 |                                      Populate the workflow requestor item_attribute when a lead instructor record
 |                                      has not set up in the system.
 ===============================================================================================================+*/
IS

CURSOR c_set_requestor (cp_requestor_id FND_USER.person_party_id%TYPE)
IS
     SELECT
             user_name
     FROM
            fnd_user
     WHERE
            person_party_id = cp_requestor_id;

 CURSOR c_get_lead_instructor (cp_uoo_id IGS_EN_SU_ATTEMPT_ALL.UOO_ID%TYPE)
 IS
     SELECT
             pur.instructor_id    instructor_id,
	     fu.user_name         user_name
     FROM
            igs_ps_usec_tch_resp  pur,
            fnd_user              fu
     WHERE
	    fu.person_party_id           = pur.instructor_id
     AND
            pur.lead_instructor_flag = 'Y'
     AND
            pur.uoo_id               = cp_uoo_id;

l_api_name                   CONSTANT VARCHAR2(30)       := 'Select_Approver' ;
l_return_status              VARCHAR2(1);
l_INSTRUCTOR_ID              IGS_PS_USEC_TCH_RESP.INSTRUCTOR_ID%TYPE;
l_UOO_ID                     NUMBER(7)                   := wf_engine.getItemAttrText(itemtype, itemkey,'UOO_ID');
rec_c_set_requestor          C_SET_REQUESTOR%ROWTYPE;
rec_c_get_lead_instructor    C_GET_LEAD_INSTRUCTOR%ROWTYPE;

BEGIN

  SAVEPOINT Select_Approver;

  IF ( funcmode = 'RUN'  ) THEN

   /******************************** Validation 1 -   Set value for the Workflow Attribute REQUESTER_USER_NAME *****************************/

      OPEN  c_set_requestor (wf_engine.getItemAttrText(itemtype, itemkey,'FROM_USER_ID'));
      FETCH c_set_requestor INTO rec_c_set_requestor;
      CLOSE c_set_requestor;
      wf_engine.setItemAttrText(itemtype, itemkey,'FROM_USER',rec_c_set_requestor.user_name);

   /******************************** Validation 2 -  Set the Value For The Workflow Attributes TO_USER_ID ,TO_USER****************************/

      OPEN  c_get_lead_instructor(wf_engine.getItemAttrText(itemtype, itemkey,'UOO_ID'));
      FETCH c_get_lead_instructor INTO rec_c_get_lead_instructor;

         IF  c_get_lead_instructor%NOTFOUND THEN
	   /* If Lead Instructor not found then return failure */
	   CLOSE c_get_lead_instructor;
	   resultout := 'COMPLETE:FAILURE';
	   RETURN;
         ELSE

           /* Finding Lead Instructor and corresponding User Name */
            wf_engine.setItemAttrText(itemtype, itemkey, 'TO_USER_ID', rec_c_get_lead_instructor.instructor_id);
            wf_engine.setItemAttrText(itemtype, itemkey, 'TO_USER'   , rec_c_get_lead_instructor.user_name    );
         END IF;

       CLOSE c_get_lead_instructor;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      END IF;
      resultout := 'COMPLETE:SUCCESS';
      RETURN;

    END IF;

/* ########################################################################

    Consulting Solution : Organizations / Institutions will set their organization?s hierarchy, to
    whom this notification has to be sent .

 ######################################################################## */

  IF ( funcmode = 'CANCEL' ) THEN
     resultout := 'COMPLETE:FAILURE';
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
     resultout := 'COMPLETE:FAILURE';
    return;
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF
     ROLLBACK TO Select_Approver;
     resultout := 'COMPLETE:FAILURE';
     return;

  WHEN OTHERS THEN
    RAISE ;

END Select_Approver ;

PROCEDURE   Repeat_Process (  Itemtype                 	 IN        VARCHAR2,
                              Itemkey          		 	 IN        VARCHAR2,
                              Actid                      IN        NUMBER,
                              Funcmode         			 IN        VARCHAR2,
                              Resultout           	     OUT NOCOPY       VARCHAR2
                           )
IS

l_api_name           CONSTANT VARCHAR2(30) := 'Repeat_Process' ;
l_return_status               VARCHAR2(1);
l_PERSON_ID                   NUMBER(15)   := wf_engine.getItemAttrText(itemtype, itemkey,'PERSON_ID');
l_UNIT_CD                     VARCHAR2(10) := wf_engine.getItemAttrText(itemtype, itemkey,'UNIT_CD');
l_COURSE_CD                   VARCHAR2(6)  := wf_engine.getItemAttrText(itemtype, itemkey,'COURSE_CD');
l_TEACH_CAL_TYPE              VARCHAR2(10) := wf_engine.getItemAttrText(itemtype, itemkey,'TEACH_CAL_TYPE');
l_TEACH_CI_SEQUENCE_NUMBER    NUMBER(6)    := wf_engine.getItemAttrText(itemtype, itemkey,'TEACH_CI_SEQUENCE_NUMBER');
l_UOO_ID                      NUMBER(7)    := wf_engine.getItemAttrText(itemtype, itemkey,'UOO_ID');
BEGIN

  SAVEPOINT Repeat_Process;

  IF ( funcmode = 'RUN'  ) THEN

  /****************** Start :  Repeat Process / Translation / Finalization Process ***********/

  IGS_AS_FINALIZE_GRADE.finalize_process( l_UOO_ID,
                                          l_PERSON_ID,
                  				          l_COURSE_CD,
                  				          l_UNIT_CD,
                				          l_TEACH_CAL_TYPE,
               			                  l_TEACH_CI_SEQUENCE_NUMBER
                                         );

  /***************** End : Repeat Process / Translation / Finalization Process *************/
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
   END IF;
   resultout := 'Y';
   return;
  IF ( funcmode = 'CANCEL' ) THEN
    resultout :=  'N';
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := 'N';
    return;
  END IF;
 END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF
     ROLLBACK TO Repeat_Process;

WHEN OTHERS THEN

    RAISE ;

END Repeat_Process;


END  IGS_AS_GR_WF_PKG;

/
