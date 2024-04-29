--------------------------------------------------------
--  DDL for Package AD_UPDATE_PREFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_UPDATE_PREFS_PKG" AUTHID CURRENT_USER AS
-- $Header: adupprfs.pls 115.3 2004/09/17 07:37:27 msailoz ship $

UNDEF_VALUE  CONSTANT VARCHAR2(20) := '#~#UNDEFVALUE#~#';
SYSADMIN_VALUE NUMBER := 1;
GLOBAL_SESSION_VALUE NUMBER := 0 ;
--
-- Defines and Sets the value of a parameter at the global level.
--
PROCEDURE DEFINE_PREFERENCE(
                 p_owner          IN VARCHAR2,
                 p_name           IN VARCHAR2,
                 p_description    IN VARCHAR2 DEFAULT NULL,
                 p_default_value  IN VARCHAR2 DEFAULT NULL
                 );

--
-- Updates the definition of a existing parameter.
--

PROCEDURE UPDATE_DEF_PREFERENCE(
                 p_owner          IN  VARCHAR2,
                 p_name           IN  VARCHAR2,
                 p_description    IN  VARCHAR2,
                 p_default_value  IN  VARCHAR2,
		 p_pref_id	  OUT NOCOPY  NUMBER
                 );



--
-- returns NULL if preference is not found
--
FUNCTION GET_PREFERENCE_ID(
                 p_owner          IN VARCHAR2,
                 p_name           IN VARCHAR2)
		 RETURN number;

--
-- Gets the preference value for global if session preference is not found
-- Returns UNDEF_VALUE if parameter is not defined
--
FUNCTION GET_PREFERENCE_VALUE(
                 p_owner IN VARCHAR2,
                 p_name  IN VARCHAR2,
                 p_session_id IN NUMBER DEFAULT NULL )
		 RETURN VARCHAR2;

--
-- Gets Session preference value
--

FUNCTION GET_SESSION_PREFERENCE_VALUE(
                 p_owner IN VARCHAR2,
                 p_name  IN VARCHAR2,
                 p_session_id IN NUMBER) RETURN VARCHAR2;


--
-- Creates an new global value for a preference
--

PROCEDURE CREATE_PREFERENCE_VALUE(
                 p_owner      IN VARCHAR2,
                 p_name       IN VARCHAR2,
                 p_value      IN VARCHAR2);

--
-- Updates the global value for a preference
--

PROCEDURE UPDATE_PREFERENCE_VALUE(
                 p_owner      IN VARCHAR2,
                 p_name       IN VARCHAR2,
                 p_value      IN VARCHAR2);

--
-- Sets value for a preference (Global)
--

PROCEDURE SET_SESSION_PREFERENCE_VALUE(
                 p_owner      IN VARCHAR2,
                 p_name       IN VARCHAR2,
                 p_session_id IN NUMBER,
                 p_value      IN VARCHAR2);


END AD_UPDATE_PREFS_PKG;

 

/
