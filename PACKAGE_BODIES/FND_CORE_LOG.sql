--------------------------------------------------------
--  DDL for Package Body FND_CORE_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CORE_LOG" as
/* $Header: AFCORLGB.pls 120.7.12010000.2 2009/12/02 16:56:11 pdeluna ship $ */

   UTL_DIR              varchar2(255);
   CORELOG_FILE         utl_file.file_type;
   CORELOG_FNAME        varchar2(255) := NULL;
   CORELOG_OPEN         boolean;
   CORELOG_ENABLED      varchar2(1) := NULL;
   CORELOG_PROFILE      varchar2(80) := NULL;
   CORELOG_IS_ENABLED   boolean;

   /*
   ** FILENAME - returns the filename to be used by the core logging diagnostic
   **            tool. The function uses the hostname and the instance name to
   **            generate a unique filename.
   */
   function FILENAME return varchar2 is
     lhost      varchar2(255);
     linstance  varchar2(255);
     fname      varchar2(2000);
   begin

     select lower(host_name), lower(instance_name)
     into lhost, linstance
     from v$instance;

     fname := 'afcorelog_'||lhost||'_'||linstance||'.txt';

     return fname;
   end FILENAME;

   /*
   ** ENABLED - returns 'Y' if AFCORE_LOGGING_ENABLED is 'Y'
   **           returns 'N' if AFCORE_LOGGING_ENABLED is 'N'
   **           returns 'P' if AFCORE_LOGGING_ENABLED is 'P'
   */
   function ENABLED return varchar2 is
   begin
      /* Determine if AFCORE_LOGGING_ENABLED is 'Y', 'N', or 'P'.  A direct
      ** select is done since Core Logging can be performed in FND_PROFILE APIs
      ** and this could result in conflicts.  AFCORE_LOGGING_ENABLED is
      ** currently only settable only at the site level.
      */
      if CORELOG_ENABLED is NULL then
         select FPOV.PROFILE_OPTION_VALUE
         into CORELOG_ENABLED
         from fnd_profile_option_values FPOV, fnd_profile_options FPO
         where FPO.PROFILE_OPTION_NAME = 'AFCORE_LOGGING_ENABLED'
         and FPO.PROFILE_OPTION_ID = FPOV.PROFILE_OPTION_ID
         and FPOV.level_id = 10001
         and FPO.APPLICATION_ID = FPOV.APPLICATION_ID; -- bug 4620968
      end if;

      /* If AFCORE_LOGGING_ENABLED is 'Y' or 'P', then check if CORELOG_FNAME
      ** has been opened.  If not, it needs to be opened.
      */
      if (CORELOG_ENABLED <> 'N') and (CORELOG_ENABLED is not null) then
         if (CORELOG_OPEN = FALSE) or (CORELOG_OPEN is NULL) then
            if (CORELOG_FNAME is NULL) then
               CORELOG_FNAME := FILENAME;
            end if;
            PUT_NAMES(CORELOG_FNAME, UTL_DIR);
         end if;

      /* If AFCORE_LOGGING_ENABLED is 'N' or NULL, then check if CORELOG_FNAME
      ** is open.  If open, then it needs to be closed.
      */
      else
         CORELOG_ENABLED := 'N'; -- default to 'N' for caching.
         if (CORELOG_OPEN = TRUE) or (CORELOG_OPEN is NULL) then
            CLOSE_FILE;
         end if;
      end if;

      return CORELOG_ENABLED;

   exception
      when no_data_found then
         CORELOG_ENABLED := 'N'; -- default to 'N' for caching.
         if (CORELOG_OPEN = TRUE) or (CORELOG_OPEN is NULL) then
            CLOSE_FILE;
         end if;
         return CORELOG_ENABLED;

   end ENABLED;

   /*
   ** PROFILE_TO_LOG - returns PROFILE_OPTION_NAME to be logged
   */
   function PROFILE_TO_LOG return varchar2 is
   begin
      /* Determine if AFCORE_LOGGING_PROFILE_OPTION is not null.  A direct
      ** select is done since Core Logging can be performed in FND_PROFILE APIs
      ** and this could result in conflicts.  AFCORE_LOGGING_PROFILE_OPTION is
      ** currently only enabled at the site level.
      */
      if CORELOG_PROFILE is NULL then
         select FPOV.PROFILE_OPTION_VALUE
         into CORELOG_PROFILE
         from fnd_profile_option_values FPOV, fnd_profile_options FPO
         where FPO.PROFILE_OPTION_NAME = 'AFCORE_LOGGING_PROFILE_OPTION'
         and FPO.PROFILE_OPTION_ID = FPOV.PROFILE_OPTION_ID
         and FPOV.level_id = 10001
         and FPO.APPLICATION_ID = FPOV.APPLICATION_ID; -- bug 4620968
      end if;

      /* If CORELOG_PROFILE is not null, then check if CORELOG_PROFILE <= 80
      ** characters.  If > 80 chars, return null, else, return CORELOG_PROFILE.
      */
      if CORELOG_PROFILE is not null then
         if (length(CORELOG_PROFILE) > 80) then
            return null;
         else
            return CORELOG_PROFILE;
         end if;

      /* If CORELOG_PROFILE is NULL, then return NULL.
      */
      else
         return null;
      end if;

   exception
      when no_data_found then
         CORELOG_PROFILE := null; -- default to NULL.
         return null;
      when others then
         CORELOG_PROFILE := null; -- default to NULL.
         return null;

   end PROFILE_TO_LOG;

   /*
   ** WRITE - calls PUT to log text with a context
   */
   procedure WRITE(
      CURRENT_API           in varchar2,
      LOG_USER_ID           in number default NULL,
      LOG_RESPONSIBILITY_ID in number default NULL,
      LOG_APPLICATION_ID    in number default NULL,
      LOG_ORG_ID            in number default NULL,
      LOG_SERVER_ID         in number default NULL) is
   begin
      if (FND_CORE_LOG.IS_ENABLED) then

         -- Write a line indicating the context for this session.
         -- The format of this line is based loosely on the event_key format
         -- used in WF.

         -- Removed references to FND_GLOBAL to avoid a possible looping
         -- scenario. PUT_LINE is called in FND_PROFILE and FND_PROFILE will
         -- do the NVL substitution when it calls PUT_LINE.
         PUT_LINE(
            CURRENT_API||':'||
            LOG_USER_ID||':'||
            LOG_RESPONSIBILITY_ID||':'||
            LOG_APPLICATION_ID||':'||
            LOG_ORG_ID||':'||
            LOG_SERVER_ID||':'||
            userenv('sessionid'));

         if CURRENT_API = 'FG.I' then
            PUT_LINE(dbms_utility.format_call_stack);
         end if;
      end if;
   end WRITE;

   /*
   ** WRITE_PROFILE - calls PUT and PUT_LINE to log text with a context
   ** Will log only when FND_CORE_LOG.ENABLED = 'P'.
   */
   procedure WRITE_PROFILE(
      LOG_PROFNAME          in varchar2,
      LOG_PROFVAL           in varchar2 default null,
      CURRENT_API           in varchar2,
      LOG_USER_ID           in number,
      LOG_RESPONSIBILITY_ID in number,
      LOG_APPLICATION_ID    in number,
      LOG_ORG_ID            in number,
      LOG_SERVER_ID         in number)is

      PROF_TO_LOG           varchar2(80);
   begin
      if (FND_CORE_LOG.ENABLED = 'P') then

         PROF_TO_LOG := FND_CORE_LOG.PROFILE_TO_LOG;

         -- Write a line indicating the context for the FND_PROFILE session.
         -- The format of this line is based loosely on the event_key format
         -- used in WF.

         -- If AFCORE_LOGGING_PROFILE_OPTION has a value, log only the lines
         -- for that profile option.
         -- Note: -99 means that no value was passed for context.
         if (LOG_PROFNAME = PROF_TO_LOG) then
            PUT_LINE(
               LOG_PROFNAME,
               nvl(LOG_PROFVAL,'NOVAL')||':'||
               CURRENT_API||':'||
               nvl(LOG_USER_ID,-99)||':'||
               nvl(LOG_RESPONSIBILITY_ID,-99)||':'||
               nvl(LOG_APPLICATION_ID,-99)||':'||
               nvl(LOG_ORG_ID,-99)||':'||
               nvl(LOG_SERVER_ID,-99)||':'||
               userenv('sessionid'));

            -- If CURRENT_API is a Generic FND_PROFILE.PUT call, include the
            -- call stack.
            if (CURRENT_API = 'Enter Generic FP.P') or
               (CURRENT_API = 'VAL in GEN PUT, Exit FP.G') then
               PUT_LINE(dbms_utility.format_call_stack);
            end if;

         -- If AFCORE_LOGGING_PROFILE_OPTION has a value and
         -- CURRENT_API = 'FP.I' then log those lines also.
         elsif (CURRENT_API = 'FP.I') then
            PUT_LINE(
               LOG_PROFNAME||':'||
               nvl(LOG_PROFVAL,'NOVAL')||':'||
               CURRENT_API||':'||
               nvl(LOG_USER_ID, -99)||':'||
               nvl(LOG_RESPONSIBILITY_ID,-99)||':'||
               nvl(LOG_APPLICATION_ID,-99)||':'||
               nvl(LOG_ORG_ID,-99)||':'||
               nvl(LOG_SERVER_ID,-99)||':'||
               userenv('sessionid'));

         -- If AFCORE_LOGGING_PROFILE_OPTION is null, log everything.
         elsif (PROF_TO_LOG is null) then
            PUT_LINE(
               LOG_PROFNAME||':'||
               nvl(LOG_PROFVAL,'NOVAL')||':'||
               CURRENT_API||':'||
               nvl(LOG_USER_ID, -99)||':'||
               nvl(LOG_RESPONSIBILITY_ID,-99)||':'||
               nvl(LOG_APPLICATION_ID,-99)||':'||
               nvl(LOG_ORG_ID,-99)||':'||
               nvl(LOG_SERVER_ID,-99)||':'||
               userenv('sessionid'));
         end if;
      end if;
   end WRITE_PROFILE;

   /*
   ** WRITE_PROFILE_SAVE - write API specifically for FND_PROFILE.SAVE
   ** Will log only when FND_CORE_LOG.ENABLED = 'P'.
   */
   procedure WRITE_PROFILE_SAVE(
      X_NAME in varchar2,
         /* Profile name */
      X_VALUE in varchar2,
         /* Profile value */
      X_LEVEL_NAME in varchar2,
         /* Level: 'SITE','APPL','RESP','USER', 'ORG', 'SERVER', 'SERVRESP' */
      X_LEVEL_VALUE in varchar2 default NULL,
      /* Level value, e.g. user id for 'USER' level.
         X_LEVEL_VALUE is not used at site level. */
      X_LEVEL_VALUE_APP_ID in varchar2 default NULL,
      /* Used for 'RESP' and 'SERVRESP' level; Resp Application_Id. */
      X_LEVEL_VALUE2 in varchar2 default NULL) is

      PROF_TO_LOG           varchar2(80);

   begin
      if (FND_CORE_LOG.ENABLED = 'P') then

         PROF_TO_LOG := FND_CORE_LOG.PROFILE_TO_LOG;

         -- Write a line indicating the context for the FND_PROFILE.SAVE call.
         -- The format of this line is based loosely on the event_key format
         -- used in WF.
         -- If AFCORE_LOGGING_PROFILE_OPTION has a value, log only the lines
         -- for that profile option.
         if (X_NAME = PROF_TO_LOG) then
            PUT_LINE(
               X_NAME,
               nvl(X_VALUE,'NULL')||':'||
               'FP.S'||':'||
               X_LEVEL_NAME||':'||
               nvl(X_LEVEL_VALUE,'NULL')||':'||
               nvl(X_LEVEL_VALUE_APP_ID,'NULL')||':'||
               nvl(X_LEVEL_VALUE2,'NULL')||':'||
               userenv('sessionid'));

         -- If AFCORE_LOGGING_PROFILE_OPTION is null, log everything.
         elsif (PROF_TO_LOG is null) then
            PUT_LINE(
               X_NAME,
               nvl(X_VALUE,'NULL')||':'||
               'FP.S'||':'||
               X_LEVEL_NAME||':'||
               nvl(X_LEVEL_VALUE,'NULL')||':'||
               nvl(X_LEVEL_VALUE_APP_ID,'NULL')||':'||
               nvl(X_LEVEL_VALUE2,'NULL')||':'||
               userenv('sessionid'));
         end if;
      end if;
   end WRITE_PROFILE_SAVE;

   /*
   ** PUT_NAMES - Set the logfile name and directory
   **
   ** IN
   **   P_LOGFILE - logfile name
   **   P_DIRECTORY - directory name
   **
   */
   procedure PUT_NAMES(P_LOGFILE in varchar2, P_DIRECTORY in varchar2) is
      TEMP_DIR varchar2(512);
   begin

      if (CORELOG_FNAME is null) and (P_LOGFILE is not null) then
         CORELOG_FNAME := P_LOGFILE;
      end if;

      if UTL_DIR is null and P_DIRECTORY is null then
         -- Then determine the utl_file_dir value.
         select translate(ltrim(value),',',' ')
         into TEMP_DIR
         from v$parameter
         where lower(name) = 'utl_file_dir';

         if (instr(TEMP_DIR,' ') > 0 and TEMP_DIR is not null) then
            select substrb(TEMP_DIR, 1, instr(TEMP_DIR,' ') - 1)
            into UTL_DIR
            from dual;
         elsif (TEMP_DIR is not null) then
            UTL_DIR := TEMP_DIR;
         end if;

         if (TEMP_DIR is null or UTL_DIR is null ) then
            raise no_data_found;
         end if;
      elsif UTL_DIR is null and P_DIRECTORY is not null then
         UTL_DIR  := P_DIRECTORY;
      end if;

      if (CORELOG_OPEN = FALSE) or (CORELOG_OPEN is NULL) then
         OPEN_FILE;
      end if;

   end PUT_NAMES;

   /*
   ** OPEN_FILE - open or create logfile
   */
   procedure OPEN_FILE is
      MAX_LINESIZE  binary_integer := 32767;
   begin
      if (CORELOG_OPEN = FALSE) or (CORELOG_OPEN is NULL) then
         if (CORELOG_FNAME is NULL) then
           CORELOG_FNAME := FILENAME;
         end if;
         CORELOG_FILE := utl_file.fopen(UTL_DIR, CORELOG_FNAME, 'a');
         begin
            utl_file.fclose(CORELOG_FILE);
         exception
            when others then
               null;
         end;
         CORELOG_FILE := utl_file.fopen(UTL_DIR, CORELOG_FNAME, 'a',
            MAX_LINESIZE);
         CORELOG_OPEN := TRUE;
      end if;
   end OPEN_FILE;

   /*
   ** PUT - Put (write) text to file
   **
   ** IN
   **   LOG_TEXT - Text to write
   */
   procedure PUT(LOG_TEXT in varchar2) is
   begin
      if (CORELOG_ENABLED <> 'N') and (CORELOG_ENABLED is not null) then
         if (CORELOG_OPEN = FALSE) or (CORELOG_OPEN is NULL) then
            OPEN_FILE;
         end if;
         utl_file.put(CORELOG_FILE, LOG_TEXT);
         utl_file.fflush(CORELOG_FILE);
      end if;
   end PUT;

   /*
   ** PUT_LINE - Put (write) a line of text to file
   **
   ** IN
   **   LOG_PROFNAME - Profile Option being monitored
   **   LOG_TEXT - Text to write
   */
   procedure PUT_LINE(LOG_PROFNAME in varchar2, LOG_TEXT in varchar2) is
   begin
      if (LOG_PROFNAME = CORELOG_PROFILE) then
         if (CORELOG_ENABLED <> 'N') and (CORELOG_ENABLED is not null) then
            if (CORELOG_OPEN = FALSE) or (CORELOG_OPEN is NULL) then
               OPEN_FILE;
            end if;
            utl_file.put_line(CORELOG_FILE, LOG_PROFNAME||':'||LOG_TEXT);
            utl_file.fflush(CORELOG_FILE);
         end if;
      end if;
   end PUT_LINE;

   /*
   ** PUT_LINE - Put (write) a line of text to file
   **    Calls PUT and appends a NEW_LINE for better readability.
   **
   ** IN
   **   LOG_TEXT - Text to write
   */
   procedure PUT_LINE(LOG_TEXT in varchar2) is
   begin
      PUT(LOG_TEXT);
      NEW_LINE;
   end PUT_LINE;

   /*
   ** NEW_LINE - Put (write) line terminators to file
   **
   ** IN
   **   LINES - Number of line terminators to write
   */
   procedure NEW_LINE(LINES in natural := 1) is
   begin
      if (CORELOG_ENABLED <> 'N') and (CORELOG_ENABLED is not null) then
         if (CORELOG_OPEN = FALSE) or (CORELOG_OPEN is NULL) then
            OPEN_FILE;
         end if;
         utl_file.new_line(CORELOG_FILE, LINES);
         utl_file.fflush(CORELOG_FILE);
      end if;
   end NEW_LINE;

   /*
   ** CLOSE_FILE   - Close open files.
   **
   */
   procedure CLOSE_FILE is
   BEGIN
      BEGIN
         utl_file.fclose(CORELOG_FILE);
      EXCEPTION
         when others then
            NULL;
      END;
      CORELOG_OPEN := FALSE;
   end CLOSE_FILE;

   /*
   ** IS_ENABLED - returns TRUE if ENABLED <> 'N', i.e. 'Y' or 'P'
   **              returns FALSE if ENABLED = 'N'
   */
   function IS_ENABLED return boolean is
   begin
      if CORELOG_IS_ENABLED is NULL then
         if ENABLED <> 'N' then
            CORELOG_IS_ENABLED := TRUE;
         else
            CORELOG_IS_ENABLED := FALSE;
         end if;
      end if;
      return CORELOG_IS_ENABLED;
   end IS_ENABLED;

end FND_CORE_LOG;

/
