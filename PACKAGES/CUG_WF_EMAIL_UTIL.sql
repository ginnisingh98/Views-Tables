--------------------------------------------------------
--  DDL for Package CUG_WF_EMAIL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_WF_EMAIL_UTIL" AUTHID CURRENT_USER AS
/* $Header: CUGWFEUS.pls 115.6 2002/11/24 23:54:50 rhungund noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

--

 PROCEDURE Get_SR_Details
 (   ITEMTYPE IN VARCHAR2
    ,ITEMKEY IN VARCHAR2
    ,ACTID IN NUMBER
    ,FUNCMODE IN VARCHAR2
    ,RESULTOUT OUT NOCOPY VARCHAR2
  );


   PROCEDURE Get_Task_Attrs_Details
     (
        ITEMTYPE       IN VARCHAR2
        , ITEMKEY      IN VARCHAR2
        , INCIDENT_TYPE_ID IN NUMBER
        , TASK_ID      IN NUMBER
        , TASK_TYPE_ID IN NUMBER
        , X_RETURN_STATUS 	OUT NOCOPY VARCHAR2
     ) ;

  PROCEDURE Get_Incident_Addr_Details
     (
        ITEMTYPE       IN VARCHAR2
        , ITEMKEY      IN VARCHAR2
        , INCIDENT_NUMBER IN VARCHAR2
        ,X_RETURN_STATUS 	OUT NOCOPY VARCHAR2
     );

  PROCEDURE Get_SR_Attrs_Details (
    ITEMTYPE       IN VARCHAR2
    , ITEMKEY      IN VARCHAR2
    , INCIDENT_ID IN NUMBER
    , INCIDENT_TYPE_ID IN NUMBER
    , INCIDENT_NUMBER  IN VARCHAR2
    , TASK_NUMBER      IN VARCHAR2
    , X_RETURN_STATUS 	OUT NOCOPY VARCHAR2
 );

  PROCEDURE   Set_Reminder_Interval
        (   ITEMTYPE IN VARCHAR2
           ,ITEMKEY IN VARCHAR2
           ,ACTID IN NUMBER
           ,FUNCMODE IN VARCHAR2
           ,RESULTOUT OUT NOCOPY VARCHAR2
         );

  PROCEDURE Check_For_CIC_SR
 (   ITEMTYPE IN VARCHAR2
    ,ITEMKEY IN VARCHAR2
    ,ACTID IN NUMBER
    ,FUNCMODE IN VARCHAR2
    ,RESULTOUT OUT NOCOPY VARCHAR2
  );

    PROCEDURE Set_Email_status
 (   ITEMTYPE IN VARCHAR2
    ,ITEMKEY IN VARCHAR2
    ,ACTID IN NUMBER
    ,FUNCMODE IN VARCHAR2
    ,RESULTOUT OUT NOCOPY VARCHAR2
  );

END; -- Package spec

 

/
