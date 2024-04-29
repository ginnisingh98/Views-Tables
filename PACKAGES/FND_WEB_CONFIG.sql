--------------------------------------------------------
--  DDL for Package FND_WEB_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WEB_CONFIG" AUTHID CURRENT_USER as
/* $Header: AFWBCFGS.pls 115.12 2002/04/11 17:39:35 pkm ship  $ */


/* PLSQL_AGENT- get the name of the PLSQL web agent
**
** Returns the value of the APPS_WEB_AGENT profile, with
** a guaranteed trailing slash.
**
** Note: if this routine fails, it will return NULL, and
** there will be an error message on the message stack.
** The caller is responsible for either displaying the message
** or clearing the message stack upon failure.
**
** IN:
**   help_mode - Look for HELP_WEB_AGENT profile over-ride
**               'APPS' - Use APPS_WEB_AGENT
**               'HELP' - Use HELP_WEB_AGENT
**
*/
function PLSQL_AGENT (
  help_mode in varchar2 default 'APPS')
return VARCHAR2;

/* WEB_SERVER- get the URL of the web server machine
**
** Returns the value of the web server from the APPS_WEB_AGENT with
** a guaranteed trailing slash.
**
** e.g. if  APPS_WEB_AGENT = 'http://mysun.us.oracle.com:1234/dad1'
** it returns 'http://mysun.us.oracle.com:1234/'
**
** Note: if this routine fails, it will return NULL, and
** there will be an error message on the message stack.
** The caller is responsible for either displaying the message
** or clearing the message stack upon failure.
**
** IN:
**   help_mode - Look for HELP_WEB_AGENT profile over-ride
**               'APPS' - Use APPS_WEB_AGENT
**               'HELP' - Use HELP_WEB_AGENT
**
*/
function WEB_SERVER (
  help_mode in varchar2 default 'APPS')
return VARCHAR2;

/* DAD- get the DAD component of the URL of the web server machine
**
** Returns the value of the DAD (Database Access Descriptor) from the
** APPS_WEB_AGENT with a guaranteed trailing slash.
**
** e.g. if  APPS_WEB_AGENT = 'http://mysun.us.oracle.com:1234/dad1'
** it returns 'dad1/'
**
** Note: if this routine fails, it will return NULL, and
** there will be an error message on the message stack.
** The caller is responsible for either displaying the message
** or clearing the message stack upon failure.
**
** IN:
**   help_mode - Look for HELP_WEB_AGENT profile over-ride
**               'APPS' - Use APPS_WEB_AGENT
**               'HELP' - Use HELP_WEB_AGENT
**
*/
function DAD (
  help_mode in varchar2 default 'APPS')
return VARCHAR2;

/* GFM_AGENT- get the GFM agent of the web server machine
**
** Returns the value of the Generic File Manager agent by parsing
** the APPS_WEB_AGENT.  Has a guaranteed trailing slash.
**
** Note: Now that we are using webdb, calling this routine is equivalent
**       to calling fnd_web_config.plsql_agent
**
** Note: if this routine fails, it will return NULL, and
**       there will be an error message on the message stack.
**       The caller is responsible for either displaying the message
**       or clearing the message stack upon failure.
**
** IN:
**   help_mode - Look for HELP_WEB_AGENT profile over-ride
**               'APPS' - Use APPS_WEB_AGENT
**               'HELP' - Use HELP_WEB_AGENT
**
*/
function GFM_AGENT (
  help_mode in varchar2 default 'APPS')
return VARCHAR2;

/* PROTOCOL- get the protocol identifier
**
** Returns the protocol of the APPS_WEB_AGENT profile.
**
** e.g. if  APPS_WEB_AGENT = 'http://mysun.us.oracle.com:1234/dad1/plsql'
** it returns 'http:'
**
** Note: if this routine fails, it will return NULL, and
** there will be an error message on the message stack.
** The caller is responsible for either displaying the message
** or clearing the message stack upon failure.
**
** IN:
**   help_mode - Look for HELP_WEB_AGENT profile over-ride
**               'APPS' - Use APPS_WEB_AGENT
**               'HELP' - Use HELP_WEB_AGENT
**
*/
function PROTOCOL (
  help_mode in varchar2 default 'APPS')
return VARCHAR2;

/* TRAIL_SLASH- make sure there is a trailing slash on the URL passed in
**
** If URL has a trailing slash, just returns URL
** otherwise adds a trailing slash
**
*/
function TRAIL_SLASH(INVAL in VARCHAR2) return VARCHAR2;

/* DATABASE_ID- get the database host id
**
** Returns the database host id, lowercased.
**
** The implementation will return an identifier which forms a unique
** database identifier, suitable as a filename for the dbc file.
**
*/
function DATABASE_ID return VARCHAR2;

/* JSP_AGENT- get the name of the apps JSP agent
**
** Returns the value of the APPS_JSP_AGENT profile, with
** a guaranteed trailing slash.
**
** Note: if this routine fails, it will return NULL, and
** there will be an error message on the message stack.
** The caller is responsible for either displaying the message
** or clearing the message stack upon failure.
**
*/
function JSP_AGENT return VARCHAR2;

/*
** check_enabled - Returns 'Y' if a PL/SQL procedure is enabled, 'N' otherwise.
*/
function check_enabled (proc in varchar2) return varchar2;

END FND_WEB_CONFIG;

 

/

  GRANT EXECUTE ON "APPS"."FND_WEB_CONFIG" TO "EM_OAM_MONITOR_ROLE";
