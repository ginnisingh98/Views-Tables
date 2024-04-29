--------------------------------------------------------
--  DDL for Package AD_UPDATE_WORK_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_UPDATE_WORK_PARAMS_PKG" AUTHID CURRENT_USER AS
-- $Header: adupwrks.pls 115.3 2004/09/17 07:36:58 msailoz ship $

UNDEF_VALUE  CONSTANT VARCHAR2(20) := '#~#UNDEFVALUE#~#';
SYSADMIN_VALUE NUMBER := 1;
GLOBAL_SESSION_VALUE NUMBER := 0 ;
--
-- Defines and Sets the value of a parameter at the global level.
--
PROCEDURE SET_PARAMETER(
                 p_owner IN VARCHAR2,
                 p_name  IN VARCHAR2,
                 p_value IN VARCHAR2);

--
-- Returns UNDEF_VALUE if parameter is not defined
--
FUNCTION GET_PARAMETER(
                 p_owner IN VARCHAR2,
                 p_name  IN VARCHAR2) RETURN VARCHAR2;


--
-- Defines and Sets the value of a parameter for a session
--

PROCEDURE SET_SESSION_PARAMETER(
                 p_session_id IN number,
                 p_owner      IN VARCHAR2,
                 p_name       IN VARCHAR2,
                 p_value      IN VARCHAR2);

--
-- Returns UNDEF_VALUE if parameter is not defined
--
FUNCTION GET_SESSION_PARAMETER(
                 p_session_id IN number,
                 p_owner      IN VARCHAR2,
                 p_name       IN VARCHAR2) RETURN VARCHAR2;


END AD_UPDATE_WORK_PARAMS_PKG;

 

/
