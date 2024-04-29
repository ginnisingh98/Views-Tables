--------------------------------------------------------
--  DDL for Package HR_EXTERNAL_APPLICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EXTERNAL_APPLICATION" AUTHID CURRENT_USER AS
/* $Header: hrextapp.pkh 115.4 2004/02/10 22:44:43 vkarandi noship $ */


-- WARNING WARNING WARNING WARNING WARNING
--
-- Make sure that only individual procedures from this package are
-- registered in FND_ENABLED_PLSQL.
--
-- WARNING WARNING WARNING WARNING WARNING


--
-- Name
--  launch
--
-- Parameters
--   p_app_code       IN   short code of External Application
--
-- Purpose
--
--  A PL/SQL function that launches an SSO External Application associated
--  with the lookup_code (from 'SSO_EXTERNAL_APPLICATIONS').
--  If the current user has no registered credentials for this application
--  then they are copied from those registered for a fixed user (currently
--  SYSADMIN).
--
--  A limitation of this solution is that users that got credentials
--  copied from the fixed user get them permantently. This somewhat
--  weakens the use of function security as an access control
--  mechanism since we currently provide no means of removing those
--  credentials if the user no longer has access to the function.
--

PROCEDURE launch(p_app_code IN VARCHAR2);

--
-- Name
--  ki_launch
--
-- Parameters
--   p_topic       IN   Topic Key
--   p_provider    IN   Provider Key
--
-- Purpose
--
--  A PL/SQL function which acts as client to KI Servlet.
--  This function extracts Ids associated with the topic key and provider
--  key and gets dbc file and profile options to constructs the request
--  Request is sent to the KI servlet which returns the URL
--  that will be launched by opening browser.
--

PROCEDURE ki_launch(p_topic IN VARCHAR2,p_provider in VARCHAR2);
--
-- Name
--  register
--
-- Parameters
--   p_app_code       IN   short code of External Application
--   p_lookup_code    IN   lookup code
--   p_apptype        IN   application type
--   p_appurl         IN   URL for external application
--   p_logout_url     IN   URL for external application to logout
--   p_userfld        IN   name of user field
--   p_pwdfld         IN   name of password field
--   p_authused       IN   type of authentication used
--   p_fnameN         IN   additional names  (N=1..9)
--   p_fvalN          IN   additional values (N=1..9)
--
-- Purpose
--
--  A PL/SQL function that registers an external application.
--
--  This assumes that there is a lookup code already created.
--
PROCEDURE register (
            p_app_code       IN VARCHAR2,
            p_apptype        IN VARCHAR2,
            p_appurl         IN VARCHAR2,
            p_logout_url     IN VARCHAR2,
            p_userfld        IN VARCHAR2,
            p_pwdfld         IN VARCHAR2,
            p_authused       IN VARCHAR2,
            p_fname1         IN VARCHAR2 DEFAULT NULL,
            p_fval1          IN VARCHAR2 DEFAULT NULL,
            p_fname2         IN VARCHAR2 DEFAULT NULL,
            p_fval2          IN VARCHAR2 DEFAULT NULL,
            p_fname3         IN VARCHAR2 DEFAULT NULL,
            p_fval3          IN VARCHAR2 DEFAULT NULL,
            p_fname4         IN VARCHAR2 DEFAULT NULL,
            p_fval4          IN VARCHAR2 DEFAULT NULL,
            p_fname5         IN VARCHAR2 DEFAULT NULL,
            p_fval5          IN VARCHAR2 DEFAULT NULL,
            p_fname6         IN VARCHAR2 DEFAULT NULL,
            p_fval6          IN VARCHAR2 DEFAULT NULL,
            p_fname7         IN VARCHAR2 DEFAULT NULL,
            p_fval7          IN VARCHAR2 DEFAULT NULL,
            p_fname8         IN VARCHAR2 DEFAULT NULL,
            p_fval8          IN VARCHAR2 DEFAULT NULL,
            p_fname9         IN VARCHAR2 DEFAULT NULL,
            p_fval9          IN VARCHAR2 DEFAULT NULL);

--
-- Returns the URL of the routine responsible for logging into an
-- external application
--
FUNCTION get_extapp_url(p_app_id IN VARCHAR2) RETURN VARCHAR2;


--=========================== get_app_id ================================
--
-- Description: Find the app_id of the external application
--
--
--  Input Parameters
--        p_app_code - Short code identifier for External Application
--        (from SSO_EXTERNAL_APPLICATIONS)
--
--
--  Output Parameters
--        l_app_id - app_id of target
--
--
-- ==========================================================================

--
FUNCTION get_app_id(p_app_code IN VARCHAR2) RETURN VARCHAR2;

END hr_external_application;

 

/
