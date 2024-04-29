--------------------------------------------------------
--  DDL for Package AD_EVENT_REGISTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_EVENT_REGISTRY_PKG" AUTHID CURRENT_USER AS
-- $Header: adevntrgs.pls 120.0 2005/05/25 11:50:30 appldev noship $

  -- Event Types can be the following
  BOOLEAN_TYPE          CONSTANT VARCHAR2(7)  := 'BOOLEAN';
  MULTI_TYPE            CONSTANT VARCHAR2(10) := 'MULTISTATE';

  -- Default Event Context
  DEFAULT_CONTEXT       CONSTANT VARCHAR2(4)  := 'NONE';

  -- Event Status can be the following values
  INITIALIZED_STATUS    CONSTANT VARCHAR2(11) := 'INITIALIZED';
  COMPLETED_STATUS      CONSTANT VARCHAR2(9)  := 'COMPLETED';
  NOTAPPLICABLE_STATUS  CONSTANT VARCHAR2(2)  := 'NA';

  -- Maximum workers
  MAX_ALLOWED_WORKERS   CONSTANT NUMBER       := 999;

  -- If the event is not define return the following status
  EVENT_NOT_DEFINED     CONSTANT VARCHAR2(17) := 'EVENT_NOT_DEFINED';

  -- Exceptions are declared below

  --
  -- The following excption is raised by the assert event procedure
  -- in cases when the event is not complete.
  --
  assert_event_EXP            EXCEPTION;

  --
  -- This is a general exception which will be raised for various conditions.
  --
  event_error_EXP             EXCEPTION;

  PRAGMA EXCEPTION_INIT(assert_event_EXP,            -20007);
  PRAGMA EXCEPTION_INIT(event_error_EXP,             -20010);


  -- Procedure declarations follows
  PROCEDURE Initialize_Event(
              p_Owner            IN VARCHAR2,
              p_Event_Name       IN VARCHAR2,
              p_Module_Name      IN VARCHAR2,
              p_Event_Type       IN VARCHAR2   := NULL ,
              p_Context          IN VARCHAR2   := NULL ,
              p_Version          IN NUMBER     := NULL ,
              p_Worker_Id        IN NUMBER     := NULL ,
              p_Num_Workers      IN NUMBER     := NULL ) ;

  PROCEDURE Start_Event(
              p_Owner            IN VARCHAR2,
              p_Event_Name       IN VARCHAR2,
              p_Context          IN VARCHAR2 := NULL );

  PROCEDURE End_Event(
              p_Owner            IN VARCHAR2,
              p_Event_Name       IN VARCHAR2,
              p_Context          IN VARCHAR2   := NULL );

  FUNCTION Is_Event_Done(
              p_Owner            IN VARCHAR2 ,
	      p_Event_Name       IN VARCHAR2 ,
	      p_Context          IN VARCHAR2   := NULL ,
	      p_Min_Version      IN NUMBER     := NULL ,
	      p_Specific_Version IN NUMBER     := NULL ,
	      p_Worker_Id        IN NUMBER     := NULL ,
	      p_Num_Workers      IN NUMBER     := NULL )
  RETURN   BOOLEAN;

  PROCEDURE Assert_Event(
              p_Owner            IN VARCHAR2 ,
              p_Event_Name       IN VARCHAR2 ,
              p_Context          IN VARCHAR2   := NULL ,
              p_Min_Version      IN VARCHAR2   := NULL ,
              p_Specific_Version IN VARCHAR2   := NULL );

  FUNCTION Check_Min_Completed_Version(
            p_Owner                 IN VARCHAR2 ,
	    p_Event_Name            IN VARCHAR2 ,
	    p_Min_Completed_Version IN NUMBER ,
    	    p_Context               IN VARCHAR2 := NULL )
  RETURN BOOLEAN ;

  FUNCTION Get_Event_Status(
              p_Owner            IN VARCHAR2 ,
              p_Event_Name       IN VARCHAR2 ,
              p_Context          IN VARCHAR2   := NULL ,
              p_Min_Version      IN NUMBER     := NULL ,
              p_Specific_Version IN NUMBER     := NULL )
  RETURN VARCHAR2;

  PROCEDURE Set_Event_Status(
              p_Owner            IN VARCHAR2,
              p_Event_Name       IN VARCHAR2,
	      p_Status           IN VARCHAR2,
              p_Context          IN VARCHAR2  := NULL );

  PROCEDURE   Reset_Event(
              p_Owner            IN VARCHAR2 ,
              p_Event_Name       IN VARCHAR2 ,
      	      p_Module_Name      IN VARCHAR2 ,
              p_Context          IN VARCHAR2 := NULL );

  PROCEDURE Set_Event_As_Done(
             p_Owner             IN VARCHAR2 ,
             p_Event_Name        IN VARCHAR2 ,
	     p_Module_Name       IN VARCHAR2 ,
             p_Context           IN VARCHAR2 := NULL ,
             p_Event_Type        IN VARCHAR2 := NULL ,
             p_Version           IN NUMBER   := NULL ,
             p_Worker_Id         IN NUMBER   := NULL ,
             p_Num_Workers       IN NUMBER   := NULL );
-----------

END Ad_Event_Registry_Pkg;

 

/
