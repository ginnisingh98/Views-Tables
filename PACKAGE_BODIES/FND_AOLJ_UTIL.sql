--------------------------------------------------------
--  DDL for Package Body FND_AOLJ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_AOLJ_UTIL" as
/* $Header: AFAJUTLB.pls 120.4.12010000.7 2013/11/13 16:38:03 fskinner ship $ */


--
-- GENERIC_ERROR (Internal)
--
-- Set error message and raise exception for unexpected sql errors
--
procedure GENERIC_ERROR(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2) is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    app_exception.raise_exception;
end;


/*
** MULTI_PROFILE_VALUE_SPECIFIC -
**   Get profile values in group for a specific user/resp/appl combo
**   Default is user/resp/appl is current login.
*/

function MULTI_PROFILE_VALUE_SPECIFIC(
                    NUMOFNAMES        in number default 1,
                    NAMES             in varchar2,
                    USER_ID           in number default null,
                    RESPONSIBILITY_ID in number default null,
                    APPLICATION_ID    in number default null)
return varchar2 is

  profvalues VARCHAR2(32767);
  profname VARCHAR2(80);
  idx  INTEGER;
  namestart INTEGER;
  nextdelim INTEGER;
  savenames VARCHAR2(32767);
  profnames VARCHAR2(32767);
  profvalue VARCHAR2(128);

BEGIN
    namestart := 0;
    profnames := NAMES;
    profvalues := '';
    FOR idx IN 1..NUMOFNAMES LOOP
        nextdelim :=INSTR(profnames,';');
        profname:=SUBSTR(profnames,0, nextdelim-1);
        profnames:=SUBSTR(profnames,nextdelim+1,LENGTH(names)-nextdelim);
        profvalue := FND_PROFILE.VALUE_SPECIFIC(profname,USER_ID,RESPONSIBILITY_ID, APPLICATION_ID);
        profvalues := profvalues || profvalue || ';' ;
    END LOOP;
    return profvalues;

end MULTI_PROFILE_VALUE_SPECIFIC;


/*
    -- SET_NLS_CONTEXT
    --
    -- Description:  Calls alter session to set the following values in DB.
    -- NLS_LANGUAGE, NLS_DATE_FORMAT,NLS_DATE_LANGUAGE, NLS_SORT
    -- NLS_TERRITORY,NLS_NUMERIC_CHARACTERS
*/

PROCEDURE set_nls_context( p_nls_language IN VARCHAR2 DEFAULT NULL,
               p_nls_date_format IN VARCHAR2 DEFAULT NULL,
               p_nls_date_language IN VARCHAR2 DEFAULT NULL,
               p_nls_numeric_characters IN VARCHAR2 DEFAULT NULL,
               p_nls_sort IN VARCHAR2 DEFAULT NULL,
               p_nls_territory IN VARCHAR2 DEFAULT NULL,
               p_db_nls_language OUT NOCOPY VARCHAR2,
               p_db_nls_date_format OUT NOCOPY VARCHAR2,
               p_db_nls_date_language OUT NOCOPY VARCHAR2,
               p_db_nls_numeric_characters OUT NOCOPY VARCHAR2,
               p_db_nls_sort OUT NOCOPY VARCHAR2,
               p_db_nls_territory OUT NOCOPY VARCHAR2,
               p_db_nls_charset OUT NOCOPY VARCHAR2
               ) IS
BEGIN
  fnd_global.set_nls(
         p_nls_language,
               p_nls_date_format,
               p_nls_date_language,
               p_nls_numeric_characters,
               p_nls_sort,
               p_nls_territory,
               p_db_nls_language,
               p_db_nls_date_format,
               p_db_nls_date_language,
               p_db_nls_numeric_characters,
               p_db_nls_sort,
               p_db_nls_territory,
               p_db_nls_charset
       );
END set_nls_context;



/* -- getClassVersionFromDB
   --
   -- Prints out version information for Java classes stored in the database
   --
   -- getClassVersionFromDB(p_classname VARCHAR2) -- Print out the version for a single class
   -- getClassVersionFromDB                       -- Print out version information for all Java classes
   --
   -- Calls a Java stored procedure which writes to System.out, so when used from SQL*Plus,
   -- SET SERVEROUTPUT ON needs to be used.
   --
   -- EX: To display the version of Log.java from SQL*Plus:
   --
   -- SQL> set serveroutput on
   -- SQL> execute fnd_aolj_util.getClassVersionFromDB('oracle.apps.fnd.common.Log');
   -- >>> Class: oracle.apps.fnd.common.Log
   -- ... : Log.java 115.21 2002/02/08 19:20:06 mskees ship $
   --
   -- PL/SQL procedure successfully completed.
*/



/* PLSQL Wrapper for Java stored procedure of same name */
PROCEDURE displayClassVersion(p_classname VARCHAR2)
  AS LANGUAGE JAVA NAME 'oracle.apps.fnd.common.VersionInfo.displayClassVersion(java.lang.String)';


/* Print out version information for a single class */
PROCEDURE getClassVersionFromDB(p_classname VARCHAR2) IS
BEGIN

   dbms_java.set_output(20000);

   /* get the full name for the class, and replace all slashes with periods */
   displayClassVersion(replace(dbms_java.longname(p_classname), '/', '.'));

END getClassVersionFromDB;


/* Print out version information for all Java classes owned by this user */
PROCEDURE getClassVersionFromDB IS

   cursor c_classes IS
     SELECT object_name
     from user_objects
     WHERE object_type = 'JAVA CLASS'
     ORDER BY dbms_java.longname(object_name);

BEGIN

   FOR rec IN c_classes LOOP
      getClassVersionFromDB(rec.object_name);
   END LOOP;

END getClassVersionFromDB;

/*
  added for bug 4082741, to do session creation and validation in
  one roundtrip. and added p_language_code parameter.
*/
function createSession(
	    p_user_id   	   in number,
            p_server_id 	   in varchar2,
            p_language_code        in varchar2,
            p_function_code        in varchar2,
            p_validate_only        in varchar2,
            p_commit               in boolean,
            p_update               in boolean,
            p_responsibility_id    in number,
            p_function_id          in number,
            p_resp_appl_id         in number,
            p_security_group_id    in number,
            p_home_url             in varchar2,
            p_proxy_user           in number,
 	    mode_code   	   in out nocopy varchar2,
            session_id             out nocopy number,
            transaction_id         out nocopy number,
            user_id                out nocopy number,
            responsibility_id      out nocopy number,
            resp_appl_id           out nocopy number,
            security_group_id      out nocopy number,
            language_code          out nocopy varchar2,
            nls_language           out nocopy varchar2,
            date_format_mask       out nocopy varchar2,
            nls_date_language      out nocopy varchar2,
            nls_numeric_characters out nocopy varchar2,
            nls_sort               out nocopy varchar2,
            nls_territory          out nocopy varchar2,
            login_id               out nocopy number,
            xsid                   out nocopy varchar2
  ) return VARCHAR2 is
l_session_id  number;
l_sso   varchar2(2048);
l_xsid        varchar2(32);
l_result      varchar2(30);
l_user_id     number;
l_module varchar2(200):= 'fnd.plsql.FND_AOLJ_UTIL.createSession';
begin
 begin
  select user_id into l_user_id from fnd_user
  where user_id = p_user_id and
        (start_date <= sysdate) and
        (end_date is null or end_date>sysdate);
  exception
    when no_data_found then return 'N';
 end;
 -- bug:8314176, default guest sessions to 115P
 -- first create a new icx session
 if (mode_code is null) then
   if (user_id = 6) then
      mode_code:= '115P';
   else
   l_sso := fnd_profile.value('APPS_SSO');
   -- todo: should default to 115P?
   select decode(l_sso,
	       'SSWA', '115P',
               'SSWA_SSO', '115J',
	       '115X') into mode_code from dual;
   end if;
 end if;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: call
fnd_session_management to create session');
  end if;

 l_session_id := fnd_session_management.createSession(
		 p_user_id   => p_user_id,
	  	 c_mode_code => mode_code,
		 p_server_id   => p_server_id,
                 p_language_code => p_language_code,
                 p_home_url => p_home_url,
                 p_proxy_user => p_proxy_user);

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: created
session '||session_id);
  end if;

 if l_session_id = -1 then
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: session id
is -1...return N');
   end if;

   return 'N';
 end if;

 -- then validate the session
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: convert
session id to xsid...not hj related');
  end if;

 l_xsid := FND_SESSION_UTILITIES.SessionID_to_XSID(l_session_id);

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: xsid is: '||
l_xsid);
  end if;

 -- todo: l_xsid should not be NULL, but what if it is? return?
 if l_xsid is null then
   return 'N';
 end if;
 xsid := l_xsid;

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: calling
is_valid_icx....');
  end if;

 l_result := is_Valid_ICX(
          l_xsid,
          p_function_code,
          p_validate_only,
          p_commit,
          p_update,
          p_responsibility_id,
          p_function_id,
          p_resp_appl_id,
          p_security_group_id,
          'N',
          NULL,
          session_id,
          transaction_id,
	  user_id,
	  responsibility_id,
	  resp_appl_id,
	  security_group_id,
	  language_code,
	  nls_language,
	  date_format_mask,
	  nls_date_language,
	  nls_numeric_characters,
	  nls_sort,
	  nls_territory,
	  login_id,
          true);
 if l_result <> 'VALID' then
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: after
is_valid_icx - not VALID');
   end if;

   return 'N';
 else
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: after
is_valid_icx -IS VALID');
   end if;

   return 'Y';
 end if;
end createSession;

function convertGuestSession(
	    p_user_id   	   in number,
            p_server_id 	   in varchar2,
            p_session_id           in varchar2,
            p_language_code        in varchar2,
            p_function_code        in varchar2,
            p_validate_only        in varchar2,
            p_commit               in boolean,
            p_update               in boolean,
            p_responsibility_id    in number,
            p_function_id          in number,
            p_resp_appl_id         in number,
            p_security_group_id    in number,
            p_home_url             in varchar2,
            p_mode_code            in out nocopy varchar2,
            session_id             out nocopy number,
            transaction_id         out nocopy number,
            user_id                out nocopy number,
            responsibility_id      out nocopy number,
            resp_appl_id           out nocopy number,
            security_group_id      out nocopy number,
            language_code          out nocopy varchar2,
            nls_language           out nocopy varchar2,
            date_format_mask       out nocopy varchar2,
            nls_date_language      out nocopy varchar2,
            nls_numeric_characters out nocopy varchar2,
            nls_sort               out nocopy varchar2,
            nls_territory          out nocopy varchar2,
            login_id               out nocopy number
  ) return VARCHAR2 is
l_convert_result varchar2(1);
l_xsid        varchar2(32);
l_result      varchar2(30);
session_id_int number;
l_module varchar2(200):= 'fnd.plsql.FND_AOLJ_UTIL.convertGuestSession';
begin
 -- first update icx session
 -- Session Hijacking fix.
 -- XSID is modified after upgrading GUEST session to authenticated User.
 -- Hence store the session_id here which doesn't change
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: In
convertGuestSession');
   end if;
 session_id_int := fnd_session_utilities.XSID_to_SessionID(p_session_id);
 l_convert_result := fnd_session_management.convertGuestSession(
		 p_user_id   => p_user_id,
		 p_server_id   => p_server_id,
                 p_session_id => p_session_id,
                 p_language_code => p_language_code,
                 p_home_url      => p_home_url,
                 p_mode_code => p_mode_code);
 l_xsid := fnd_session_utilities.SessionID_to_XSID(session_id_int);
 if (l_convert_result = 'N') then
   return 'N';
 end if;

 -- then validate the session
 -- Pass new XSID(l_xsid) instead of the old XSID
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: calling
is_valid_icx with l_xsid: '||l_xsid||'instead of session_id '||p_session_id);
   end if;

 l_result := is_Valid_ICX(
          l_xsid,
          p_function_code,
          p_validate_only,
          p_commit,
          p_update,
          p_responsibility_id,
          p_function_id,
          p_resp_appl_id,
          p_security_group_id,
          'N',
          NULL,
          session_id,
          transaction_id,
	  user_id,
	  responsibility_id,
	  resp_appl_id,
	  security_group_id,
	  language_code,
	  nls_language,
	  date_format_mask,
	  nls_date_language,
	  nls_numeric_characters,
	  nls_sort,
	  nls_territory,
	  login_id,
          true);
 if (p_mode_code is null) then
   p_mode_code := fnd_session_management.g_mode_code;
 end if;
 if (l_result <> 'VALID') then
   return 'N';
 else
   return 'Y';
 end if;
end convertGuestSession;

/*  -- is_Valid_ICX() --  For AOL INTERNAL USE ONLY!!!!
    This function is a wrapper to ICX_SEC.validateSessionPrivate and is added for
    bug 2246010, to synchronise with ICX changes and to provide for a single call
    interface from all WebAppsContext.validateSession() methods via the method
    WebAppsContext.doValidateSession().
*/
function is_Valid_ICX(
            p_session_id           in varchar2,
            p_function_code        in varchar2,
            p_validate_only        in varchar2,
            p_commit               in boolean,
            p_update               in boolean,
            p_responsibility_id    in number,
            p_function_id          in number,
            p_resp_appl_id         in number,
            p_security_group_id    in number,
            p_validate_mode_on     in varchar2,
            p_transaction_id       in varchar2,
            session_id             out nocopy number,
            transaction_id         out nocopy number,
            user_id                out nocopy number,
            responsibility_id      out nocopy number,
            resp_appl_id           out nocopy number,
            security_group_id      out nocopy number,
            language_code          out nocopy varchar2,
            nls_language           out nocopy varchar2,
            date_format_mask       out nocopy varchar2,
            nls_date_language      out nocopy varchar2,
            nls_numeric_characters out nocopy varchar2,
            nls_sort               out nocopy varchar2,
            nls_territory          out nocopy varchar2,
            login_id               out nocopy number,
            p_isEncrypt         in boolean ) return varchar2 is

l_result                    varchar2(30);
l_encrypted_session_id      varchar2(2048);
l_encrypted_tranx_id        varchar2(2048);
l_module varchar2(200):= 'fnd.plsql.FND_AOLJ_UTIL.is_Valid_ICX';
BEGIN

    /* Added code to disable tracing for bug 3310943. */

    if fnd_trace.is_trace_enabled(fnd_trace.SQL_REGULAR) then
      fnd_trace.stop_trace;
    end if;

    /*  If the strings for session_id and tranx_id are already encrypted just pass
        them through else covert back to numbers and encrypt using the routine that
        validateSessionPrivate will use internally - this seems wastefull, but it is
        the only way to unify the many WebAppsContext.validateSession() methods to
        a single call to ICX_SEC.validateSessionPrivate() */
    if p_isEncrypt then
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log:
p_isEncrypt....');
        end if;

        l_encrypted_session_id := p_session_id;
        l_encrypted_tranx_id := p_transaction_id;
    else
        if  p_session_id is null then
            if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module,'Hijack log:
p_session_id is null...');
            end if;

            l_encrypted_session_id := p_session_id;
        else
            if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module,'Hijack log:
call sessionID to xsid for p_session_id');
            end if;

            l_encrypted_session_id := fnd_session_utilities.sessionID_to_xsid( TO_NUMBER(p_session_id) );

        end if;
        if  p_transaction_id is null then
            l_encrypted_tranx_id := p_transaction_id;
        else
            l_encrypted_tranx_id := fnd_session_utilities.transactionID_to_xtid( TO_NUMBER(p_transaction_id) );
        end if;
    end if;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module, 'Hijack log: In
is_valid_icx - now call validateSessionPrivate for xsid:
'||l_encrypted_session_id);
    end if;

    l_result := fnd_session_management.validateSessionPrivate(
                 c_xsid                     =>  l_encrypted_session_id,
                 c_function_code            =>  p_function_code,
                 c_commit                   =>  p_commit,
                 c_update                   =>  p_update,
                 c_responsibility_id        =>  p_responsibility_id,
                 c_function_id              =>  p_function_id,
                 c_resp_appl_id             =>  p_resp_appl_id,
                 c_security_group_id        =>  p_security_group_id,
                 c_validate_mode_on         =>  p_validate_mode_on,
                 c_xtid                     =>  l_encrypted_tranx_id,
                 session_id                 =>  session_id,
                 transaction_id             =>  transaction_id,
                 user_id                    =>  user_id,
                 responsibility_id          =>  responsibility_id,
                 resp_appl_id               =>  resp_appl_id,
                 security_group_id          =>  security_group_id,
                 language_code              =>  language_code,
                 nls_language               =>  nls_language,
                 date_format_mask           =>  date_format_mask,
                 nls_date_language          =>  nls_date_language,
                 nls_numeric_characters     =>  nls_numeric_characters,
                 nls_sort                   =>  nls_sort,
                 nls_territory              =>  nls_territory);

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module,'Hijack log: after
validateSesion private result is: '||l_result);
    end if;

    login_id := fnd_session_management.g_login_id;
    return l_result;

END is_Valid_ICX;


/* PLSQL Wrapper for Java stored procedure of same name */
PROCEDURE AOLJ_RUP(dummy VARCHAR2)
  AS LANGUAGE JAVA NAME 'oracle.apps.fnd.common.VersionInfo.AOLJ_RUP(java.lang.String)';

/* Print out version information for the AOL/J RUP */
PROCEDURE display_AOLJ_RUP IS
BEGIN

   dbms_java.set_output(20000);

   AOLJ_RUP('');

END display_AOLJ_RUP;

end FND_AOLJ_UTIL;

/
