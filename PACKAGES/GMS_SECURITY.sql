--------------------------------------------------------
--  DDL for Package GMS_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_SECURITY" AUTHID CURRENT_USER AS
/* $Header: gmsseses.pls 115.2 2002/07/04 11:25:47 gnema ship $ */

  G_user_id		   NUMBER;
  G_person_id		   NUMBER;
  G_module_name		   VARCHAR2(30);
  G_query_allowed	   VARCHAR2(1);
  G_update_allowed     	   VARCHAR2(1);

  PROCEDURE Initialize ( X_user_id	IN NUMBER
                       , X_calling_module  IN VARCHAR2 );

  FUNCTION allow_query ( X_award_id     IN NUMBER) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (allow_query, WNDS, WNPS);

  FUNCTION allow_update ( X_award_id     IN NUMBER) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (allow_update, WNDS, WNPS);


  PROCEDURE set_value ( X_security_level  IN VARCHAR2
		      , X_value	          IN VARCHAR2 );

  FUNCTION check_key_member ( X_person_id    IN NUMBER
                            , X_award_id   IN NUMBER ) RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES (check_key_member, WNDS, WNPS);


END gms_security;

 

/
