--------------------------------------------------------
--  DDL for Package Body FND_WEB_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEB_CONFIG" as
/* $Header: AFWBCFGB.pls 115.26 2003/04/29 01:24:00 sdstratt ship $ */


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

g_db_id   varchar2(255) default null;   -- 1585055: Global variable;

function PLSQL_AGENT (
  help_mode in varchar2 default 'APPS')
return VARCHAR2
is
   agent_url varchar2(2000) := NULL;
begin

   if (upper(help_mode) = 'HELP') then
     agent_url := fnd_profile.value('HELP_WEB_AGENT');
   end if;
   if (agent_url is null) then
     agent_url := fnd_profile.value('APPS_WEB_AGENT');
   end if;
   if (agent_url is null) then
       FND_MESSAGE.SET_NAME('FND', 'PROFILES-CANNOT READ');
       FND_MESSAGE.SET_TOKEN('OPTION', help_mode||'_WEB_AGENT');
       return NULL;
   else
       return  FND_WEB_CONFIG.TRAIL_SLASH(agent_url);
   end if;

end PLSQL_AGENT;


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
return VARCHAR2 is
   ws_url    varchar2(2000);
   index1 number;
   index2 number;
begin

   ws_url := FND_WEB_CONFIG.PLSQL_AGENT(help_mode);

   if(ws_url is null) then
      return NULL;
   end if;


   index1 := INSTRB(ws_url, '//', 1) + 2;      /* skip 'http://' */

   index2 := INSTRB(ws_url, '/', index1);  /* get to 'http://serv:port/' */

   if(index1 <> index2) AND (index1 <> 2) AND (index2 > 2)
	 AND (index1 is not NULL) AND (index2 is not NULL) then
       return FND_WEB_CONFIG.TRAIL_SLASH(SUBSTRB(ws_url, 1, index2-1));
   else
       /* Incorrect format; give an error message */
       FND_MESSAGE.SET_NAME('FND', 'AF_WCFG_BAD_AGENT_URL_FORMAT');
       FND_MESSAGE.SET_TOKEN('URL', ws_url);
       FND_MESSAGE.SET_TOKEN('PROFILE', help_mode||'_WEB_AGENT');
       FND_MESSAGE.SET_TOKEN('FORMAT', 'http://server[:port]/DAD[/]');
       return NULL;
   end if;

end WEB_SERVER;



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
return VARCHAR2
is
   dad_url    varchar2(2000);
   index1 number;
   index2 number;
   index3 number;
begin

   dad_url := FND_WEB_CONFIG.PLSQL_AGENT(help_mode);

   if(dad_url is null) then
      return NULL;
   end if;

   dad_url := TRAIL_SLASH(dad_url);
   index1 := INSTRB(dad_url, '//', 1) + 2;    /* skip 'http://' */
   index2 := INSTRB(dad_url, '/', index1)+1;  /* get to 'http://serv:port/' */
   index3 := INSTRB(dad_url, '/', index2);/* get to 'http://serv:port/dad/' */

   if(index2 <> index3) AND (index1 > 2) AND (index2 > 4) AND (index3 > 5) then
       return FND_WEB_CONFIG.TRAIL_SLASH(SUBSTRB(dad_url, index2,
	 index3-index2));
   else
       /* Incorrect format; give an error message */
       FND_MESSAGE.SET_NAME('FND', 'AF_WCFG_BAD_AGENT_URL_FORMAT');
       FND_MESSAGE.SET_TOKEN('URL', dad_url);
       FND_MESSAGE.SET_TOKEN('PROFILE', help_mode||'_WEB_AGENT');
       FND_MESSAGE.SET_TOKEN('FORMAT', 'http://server[:port]/DAD[/]');
       return NULL;
   end if;

end DAD;


/* GFM_AGENT- get the GFM agent of the web server machine
**
** Returns the value of the Generic File Manager agent by parsing
** the APPS_WEB_AGENT.  Has a guaranteed trailing slash.
**
** Note: Now that we are using webdb, calling this routine is equivalent
**       to calling fnd_web_config.plsql_agent
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
*/
function GFM_AGENT (help_mode in varchar2 default 'APPS')
return VARCHAR2
is
begin
  return fnd_web_config.plsql_agent(help_mode);
end GFM_AGENT;


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
** Note: As an accomodation to the ICX team who will be using this routine
** even when the profiles are not set, this routine will return
** 'http:' if the profiles are not set, in order to allow their code
** to work.
**
** IN:
**   help_mode - Look for HELP_WEB_AGENT profile over-ride
**               'APPS' - Use APPS_WEB_AGENT
**               'HELP' - Use HELP_WEB_AGENT
**
*/
function PROTOCOL (
  help_mode in varchar2 default 'APPS')
return VARCHAR2
is
   proto_url varchar2(2000) := NULL;
   index1    number;
begin

   proto_url := FND_WEB_CONFIG.PLSQL_AGENT(help_mode);

   if(proto_url is null) then
      FND_MESSAGE.CLEAR; /* Get rid of "Profile not found" error message */
      return 'http:';
   end if;

   index1 := INSTRB(proto_url, '://', 1);    /* Find end of 'http://' */

   if(index1 > 0) then
       return SUBSTRB(proto_url, 1, index1);
   else
       /* Incorrect format; give an error message */
       FND_MESSAGE.SET_NAME('FND', 'AF_WCFG_BAD_AGENT_URL_FORMAT');
       FND_MESSAGE.SET_TOKEN('URL', proto_url);
       FND_MESSAGE.SET_TOKEN('PROFILE', help_mode||'_WEB_AGENT');
       FND_MESSAGE.SET_TOKEN('FORMAT', 'http://server[:port]/DAD[/]');
       return NULL;
   end if;

end PROTOCOL;

/* TRAIL_SLASH- make sure there is a trailing slash on the URL passed in
**
** If URL has a trailing slash, just returns URL
** otherwise adds a trailing slash
**
*/
function TRAIL_SLASH(INVAL in VARCHAR2) return VARCHAR2 is
   copy_val varchar2(2000);
begin
    copy_val := INVAL;
    while (substr(copy_val, -1, 1) = '/') loop
        copy_val := substr(copy_val, 1, length(copy_val)-1);
    end loop;
    return copy_val || '/';
end TRAIL_SLASH;


/* DATABASE_ID- get the database host id
**
** Returns the database host id, lowercased.
**
** The implementation will return an identifier which forms a unique
** database identifier, suitable as a filename for the dbc file.
**
*/
function DATABASE_ID return VARCHAR2 is
  lhost varchar2(2000);
  linstance varchar2(2000);
  ldot pls_integer;
begin
  -- Look to see if already cached
  if (g_db_id is null) then
    -- Check for profile over-ride
    g_db_id := fnd_profile.value('APPS_DATABASE_ID');

    if (g_db_id is null) then
      -- Get default value of <host>_<sid>.
      select lower(host_name), lower(instance_name)
      into lhost, linstance
      from v$instance;

      -- If the host has a domain embedded in it - <host>.<domain>
      -- then strip off the domain bit.
      ldot := instr(lhost, '.');
      if (ldot > 0) then
        lhost := substr(lhost, 1, ldot-1);
      end if;

      g_db_id := lhost||'_'||linstance;
    end if;
  end if;

  return g_db_id;
end DATABASE_ID;


/* JSP_AGENT- get the name of the apps JSP agent
**
** Returns the value of the APPS_SERVLET_AGENT profile, with
** a guaranteed trailing slash. [with servlet zone stuff removed]
**
** Note: if this routine fails, it will return NULL, and
** there will be an error message on the message stack.
** The caller is responsible for either displaying the message
** or clearing the message stack upon failure.
**
*/
function JSP_AGENT return VARCHAR2 is
  agent_url varchar2(2000) := NULL;
  index1 number;
  index2 number;
begin
   agent_url := fnd_profile.value('APPS_SERVLET_AGENT');
   if (agent_url is null) then
       FND_MESSAGE.SET_NAME('FND', 'PROFILES-CANNOT READ');
       FND_MESSAGE.SET_TOKEN('OPTION','APPS_SERVLET_AGENT');
       return NULL;
   end if;

   agent_url := FND_WEB_CONFIG.TRAIL_SLASH(agent_url);

   index1 := INSTRB(agent_url, '//', 1) + 2;      /* skip 'http://' */

   index2 := INSTRB(agent_url, '/', index1);  /* get to 'http://serv:port/' */

   if(index1 <> index2) AND (index1 <> 2) AND (index2 > 2)
	 AND (index1 is not NULL) AND (index2 is not NULL) then
       return FND_WEB_CONFIG.TRAIL_SLASH(SUBSTRB(agent_url, 1, index2-1)) ||
         'OA_HTML/';
   else
       /* Incorrect format; give an error message */
       FND_MESSAGE.SET_NAME('FND', 'AF_WCFG_BAD_AGENT_URL_FORMAT');
       FND_MESSAGE.SET_TOKEN('URL', agent_url);
       FND_MESSAGE.SET_TOKEN('PROFILE', 'APPS_SERVLET_AGENT');
       FND_MESSAGE.SET_TOKEN('FORMAT', 'http://server[:port]/');
       return NULL;
   end if;

end JSP_AGENT;

/*
** server_name - Returns owa_util.get_cgi_env('SERVER_NAME').
*/
function server_name return varchar2 is
  name varchar2(255);
begin
  name := owa_util.get_cgi_env('SERVER_NAME');
  return name;
exception
  when others then
    return '';
end server_name;

/*
** server_port - Returns owa_util.get_cgi_env('SERVER_PORT').
*/
function server_port return varchar2 is
  port varchar2(255);
begin
  port := owa_util.get_cgi_env('SERVER_PORT');
  return port;
exception
  when others then
    return '';
end server_port;

/*
** check_enabled - Returns 'Y' if a PL/SQL procedure is enabled, 'N' otherwise.
**
** The presence of a row in FND_ENABLED_PLQSL for a packaged procedure overrides
** one for the procedure's package.  For example if there are rows in
** FND_ENABLED_PLSQL for PKG.PROC and PKG then this function returns the value
** of the ENABLED column on the row for PKG.PROC
**
*/
function check_enabled (proc in varchar2) return varchar2 is
  curproc           varchar2(100);
  x_package         varchar2(100);
  dot_location      number;
  retval            varchar2(1) := 'N';
  found             boolean := FALSE;
  l_local_server    varchar2(255);
  l_external_server varchar2(255);
  l_defined         boolean;
  is_external       varchar2(1);

  cursor proc_curs(v_procedure varchar2, v_external varchar2) is
    SELECT ENABLED
    FROM   FND_ENABLED_PLSQL
    WHERE  PLSQL_TYPE = 'PROCEDURE'
    AND    PLSQL_NAME = v_procedure
    AND    ENABLED = 'Y'
    AND    decode(v_external, 'Y', EXTERNAL, '*') =
      		 decode(v_external, 'Y', 'Y', '*');

  cursor pack_curs(v_pack varchar2, v_external varchar2) is
    SELECT ENABLED
    FROM   FND_ENABLED_PLSQL
    WHERE  PLSQL_TYPE = 'PACKAGE' AND PLSQL_NAME = v_pack
    AND    ENABLED = 'Y'
    AND    decode(v_external, 'Y', EXTERNAL, '*') =
      		 decode(v_external, 'Y', 'Y', '*');

  cursor packproc_curs(v_packproc varchar2, v_external varchar2) is
    SELECT decode(v_external, 'Y',
              decode(nvl(EXTERNAL, 'N'), 'N', 'N', enabled), enabled)
    FROM   FND_ENABLED_PLSQL
    WHERE  PLSQL_TYPE = 'PACKAGE.PROCEDURE' AND PLSQL_NAME = v_packproc;

begin
  -- Get package being executed.
  curproc := upper(proc);

  dot_location := instr(curproc, '.');

  l_local_server := fnd_web_config.protocol || '//' ||
    fnd_web_config.server_name || ':' || fnd_web_config.server_port;

  FND_PROFILE.GET_SPECIFIC (
	   NAME_Z                  => 'EXTERNAL_SERVERS'           ,
	   USER_ID_Z               => NULL                         ,
	   RESPONSIBILITY_ID_Z     => NULL                         ,
	   APPLICATION_ID_Z        => NULL                         ,
	   VAL_Z                   => l_external_server           ,
	   DEFINED_Z               => l_defined    );

  if ( instr(l_external_server,l_local_server) > 0 ) then
    is_external := 'Y';
  else
    is_external := 'N';
  end if;

  if (dot_location = 0) then
    -- This is a standalone procedure
    -- Check for procedure match.
    open proc_curs(curproc, is_external);
    fetch proc_curs into retval;
    if (proc_curs%notfound) then
      retval := 'N';
    end if;
    close proc_curs;
  else
    -- This is a package.procedure
    -- Check for package.procedure match.
    open packproc_curs(curproc, is_external);
    fetch packproc_curs into retval;
    found := packproc_curs%found;
    close packproc_curs;

    if (not found) then
      -- Check for package match.
      x_package := substr(curproc, 0, dot_location-1);
      open pack_curs(x_package, is_external);
      fetch pack_curs into retval;
      if (pack_curs%notfound) then
        retval := 'N';
      end if;
      close pack_curs;

    end if;

  end if;

  return (retval);

end check_enabled;

END FND_WEB_CONFIG;


/

  GRANT EXECUTE ON "APPS"."FND_WEB_CONFIG" TO "EM_OAM_MONITOR_ROLE";
