--------------------------------------------------------
--  DDL for Package Body IGS_AS_ATT_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ATT_WF_PKG" AS
/* $Header: IGSAS52B.pls 120.0 2005/07/05 12:38:45 appldev noship $ */

/* ***********************************************************************************************************/
  -- Procedure : Select_Approver
  --This Procedure relates to selecting an Approver (Admin or Lead Instructor), to whom this
  --Notification of Attendance Submission has to be sent. It is  just a notification, it does not
  --require any response from Approver/ Admin/ Lead Instrustor ( who ever is it, based upon the
  --Organization hierarch  set by the Institute or Organization)
/* **********************************************************************************************************/

PROCEDURE   Select_Approver (
                                                       Itemtype        IN           VARCHAR2,
                                                       Itemkey         IN           VARCHAR2,
                                                       Actid           IN           NUMBER,
                                                       Funcmode        IN           VARCHAR2,
                                                       Resultout       OUT NOCOPY        VARCHAR2
                                                     )
IS



l_api_name         CONSTANT VARCHAR2(30)   := 'Select_Approver' ;
l_return_status    VARCHAR2(1);
l_uoo_id           NUMBER(7)    := wf_engine.getItemAttrText(itemtype, itemkey,'UOO_ID');
l_INSTRUCTOR_ID    IGS_PS_USEC_TCH_RESP.INSTRUCTOR_ID%TYPE;
l_user_name        FND_USER.USER_NAME%TYPE;


 CURSOR cur_instruct(lv_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
   SELECT INSTRUCTOR_ID
   FROM   IGS_PS_USEC_TCH_RESP
   WHERE  LEAD_INSTRUCTOR_FLAG = 'Y'      AND
          UOO_ID     = lv_uoo_id;

 CURSOR cur_user(lv_instructor_id igs_ps_usec_tch_resp.instructor_id%TYPE) IS
   SELECT user_name
   FROM   FND_USER
   WHERE  person_party_id = lv_instructor_id ;


BEGIN

  SAVEPOINT Select_Approver;

  IF ( funcmode = 'RUN'  ) THEN

  /* Finding Lead Instructor and corresponding User Name */


   OPEN cur_instruct(l_uoo_id);
   FETCH cur_instruct INTO l_instructor_id ;
   CLOSE cur_instruct;

   OPEN cur_user(l_instructor_id);
   FETCH cur_user INTO l_user_name ;
   CLOSE cur_user;



   wf_engine.setItemAttrText(itemtype, itemkey,'TO_USER_ID',l_INSTRUCTOR_ID);
   wf_engine.setItemAttrText(itemtype, itemkey,'TO_USER',l_user_name);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
   END IF;

/* ########################################################################

    Consulting Solution : Organizations / Institutions will set their organization?s hierarchy, to
    whom this notification has to be sent .

 ######################################################################## */

    resultout := 'SUCCESS';
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'FAILURE';
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := 'FAILURE';
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF
     ROLLBACK TO Select_Approver;
     resultout := 'FAILURE';

     return;

  WHEN NO_DATA_FOUND THEN
       resultout := 'FAILURE';
       return;

  WHEN OTHERS THEN

    RAISE ;

END Select_Approver ;

END  IGS_AS_ATT_WF_PKG;

/
