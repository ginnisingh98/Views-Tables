--------------------------------------------------------
--  DDL for Package Body FND_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FILE" as
/* $Header: AFCPPIOB.pls 120.4.12010000.8 2018/02/22 20:33:41 ckclark ship $ */


F_LOG		utl_file.file_type;
F_OUT		utl_file.file_type;

LOG_FNAME	varchar2(255) := null;
OUT_FNAME	varchar2(255) := null;
TEMP_DIR	varchar2(255) := null;

LOG_OPEN	boolean := FALSE;
OUT_OPEN	boolean := FALSE;

/* bug8661315                                     */
/* implements utl_file.put_raw into fnd_file      */
/* in PUT_RAW mode, use of termination characters */
/* every 32K is not required                      */

UTL_FILE_MODE	varchar2(12) := 'TRADITIONAL';
RAW_TERM	raw(3);

UTL_FILE_DELAY  number := 0;

/* -------------------------------------------------------------------------
   PRIVATE PROCEDURES
   -------------------------------------------------------------------------
*/

function get_exception (errcode   in number,
			errmsg    in varchar2,
	                func      in varchar2,
	        	temp_file in varchar2) return varchar2 is

   begin

       case errcode
         when UTL_FILE.INVALID_PATH_ERRCODE then
	   fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_PATH');
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.invalid_path');

         when UTL_FILE.INVALID_MODE_ERRCODE then
           fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_MODE');
	   fnd_message.set_token('FILE_MODE', 'w', FALSE);
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.invalid_mode');

         when UTL_FILE.INVALID_OPERATION_ERRCODE then
           fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_OPERATN');
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.invalid_operation');

         when UTL_FILE.INVALID_MAXLINESIZE_ERRCODE then
           fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_MAXLINE');
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.invalid_maxline');

	 when UTL_FILE.INVALID_FILEHANDLE_ERRCODE then
           fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_HANDLE');
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.invalid_handle');

	 when UTL_FILE.WRITE_ERROR_ERRCODE then
           fnd_message.set_name('FND', 'CONC-TEMPFILE_WRITE_ERROR');
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.write_error');

	 when UTL_FILE.READ_ERROR_ERRCODE then
           fnd_message.set_name('FND', 'CONC-TEMPFILE_READ_ERROR');
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.read_error');

	 when UTL_FILE.ACCESS_DENIED_ERRCODE then
           fnd_message.set_name('FND', 'CONC-TEMPFILE_ACCESS_DENIED');
	   fnd_message.set_module('fnd.plsql.fnd_file.' || func || '.access_denied');

       end case;


       fnd_message.set_token('TEMP_DIR', TEMP_DIR, FALSE);
       fnd_message.set_token('TEMP_FILE', temp_file, FALSE);

       return substrb(fnd_message.get, 1, 255);

   exception
      when case_not_found then
        return errmsg;


end get_exception;

  /*
  ** log_simple_msg - Logs a message to FND_LOG_MESSAGES based on current runtime level
  **
   */
procedure log_simple_msg (level in number, fn in varchar2, msg in varchar2) is

BEGIN

   if (level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	 FND_LOG.STRING(level,'fnd.plsql.fnd_file.'||fn, 'sid:'||userenv('SESSIONID')||': '||msg);
   end if;

end;

function GET_BASE return varchar2 is
base_orig varchar2(12);
BASE      varchar2(12);
PRAGMA AUTONOMOUS_TRANSACTION;
begin
   /* Bug 2446909: Delete corrupted filenames from fnd_temp_files */
   select filename, lpad(filename, 10, '0')
     into base_orig, BASE

     from fnd_temp_files
     where type = 'P' and rownum = 1
     for update of filename;

   delete from fnd_temp_files
     where filename = base_orig;

   delete from fnd_temp_files
     where filename = BASE;

   commit;

   return BASE;

exception
   when OTHERS then
      if (Sql%NotFound) then
	 select lpad(to_char(fnd_temp_files_s.nextval), 10, '0')
	   into BASE
	   from sys.dual;
      end if;

      commit;
      return BASE;

end GET_BASE;



procedure OPEN_FILES is
   MAX_LINESIZE  binary_integer := 32767;
   temp_file     varchar2(255);         -- used for messages
   user_error    varchar2(255);         -- to store translated file_error

   function openit(fname in varchar2) return utl_file.file_type is
     log_f    utl_file.file_type;
      begin
      -- Open and close file to use the workaround for bug
      log_f := utl_file.fopen(TEMP_DIR, fname, 'w');

      BEGIN
         utl_file.fclose(log_f);
      EXCEPTION
         when others then
            NULL;
      END;

      if (UTL_FILE_MODE = 'TRADITIONAL') then
      	log_f := utl_file.fopen(TEMP_DIR, fname, 'w', MAX_LINESIZE);
      else
	log_f := utl_file.fopen(TEMP_DIR, fname, 'wb', MAX_LINESIZE);
      end if;

      return log_f;
    end;

begin

   if OUT_OPEN = FALSE then
      temp_file := OUT_FNAME;
      log_simple_msg(fnd_log.level_statement, 'open_files', 'open OUT_FNAME ='|| OUT_FNAME);
      F_OUT := openit(OUT_FNAME);
      OUT_OPEN := TRUE;
   end if;

   if LOG_OPEN = FALSE then
      temp_file := LOG_FNAME;
      log_simple_msg(fnd_log.level_statement, 'open_files', 'open LOG_FNAME ='|| LOG_FNAME);
      F_LOG := openit(LOG_FNAME);
      LOG_OPEN := TRUE;
   end if;

   exception
      when others then
         raise_application_error(-20100,
				 get_exception(SQLCODE, SQLERRM, 'open_files', temp_file));

end OPEN_FILES;




function PUT_NAMES_OS return boolean is
   BASE   varchar2(12);
   TEMP_UTL V$PARAMETER.VALUE%TYPE;

begin

   if LOG_FNAME is null AND
      OUT_FNAME is null AND
      TEMP_DIR  is null then
      -- use first entry of utl_file_dir as the TEMP_DIR
      -- if there is no entry then do not even construct file names
      select translate(ltrim(value),',',' ')
        into TEMP_UTL
        from v$parameter
       where name = 'utl_file_dir';

      if (instr(TEMP_UTL,' ') > 0 and TEMP_UTL is not null) then
        select substrb(TEMP_UTL, 1, instr(TEMP_UTL,' ') - 1)
          into TEMP_DIR
          from dual ;
      elsif (TEMP_UTL is not null) then
        TEMP_DIR := TEMP_UTL;
      end if;

      if (TEMP_UTL is null or TEMP_DIR is null ) then
         raise no_data_found;
      end if;

      -- We are now safe to call GET_BASE after making that as AUTONOMOUS
      -- transaction.
      -- Get the next sequence # from the db or reuse old one.

      BASE := GET_BASE;

      LOG_FNAME := 'l' || BASE || '.tmp';
      OUT_FNAME := 'o' || BASE || '.tmp';

      -- call fnd_file_private.put_names with these values
      fnd_file_private.put_names(LOG_FNAME, OUT_FNAME, TEMP_DIR );

   end if;

      -- CAUTION: for NT, we can ignore this area for NT
      -- log the temp file info in fnd_temp_files table

   if UTL_FILE_DELAY > 0 then
           if IS_OPEN('LOG') = 0 then
              TEMP_UTL := TEMP_DIR || '/' || LOG_FNAME;
              if ( fnd_conc_private_utils.check_temp_file_use(temp_utl,NULL,'F') <> 1) then
                log_simple_msg (fnd_log.level_statement, 'put_names_os',
                                 'call record_temp_file_use for: '|| TEMP_UTL);
                fnd_conc_private_utils.record_temp_file_use(TEMP_UTL, NULL, 'F', NULL);
              end if;
           end if;

           if IS_OPEN('OUT') = 0 then
              TEMP_UTL := TEMP_DIR || '/' || OUT_FNAME;
              if (fnd_conc_private_utils.check_temp_file_use(temp_utl,NULL,'F') <> 1) then
                log_simple_msg (fnd_log.level_statement, 'put_names_os',
                                 'call record_temp_file_use for: '|| TEMP_UTL);
                fnd_conc_private_utils.record_temp_file_use(TEMP_UTL, NULL, 'F', NULL);
              end if;
           end if;
   end if;

   return TRUE;

   exception
      when no_data_found then
         return FALSE;
      when others then
         return FALSE;
end PUT_NAMES_OS;



procedure WRITE_BUFF(WHICH in number, WTYPE in varchar2, BUFF in varchar2) is
   temp_file     varchar2(255);     -- used for messages
   log_f         utl_file.file_type;
begin

   -- if PUT_NAMES_OS is successfull then call OPEN_FILES
   -- and write the buffer into temp file
   if ( PUT_NAMES_OS ) then
      OPEN_FILES;

      if WHICH = FND_FILE.LOG then
        temp_file := LOG_FNAME;
	log_f := F_LOG;
      else
        temp_file := OUT_FNAME;
	log_f := F_OUT;
      end if;

      if (UTL_FILE_MODE = 'TRADITIONAL') then

            if ( WTYPE = 'PUT' ) then
               utl_file.put(log_f, BUFF);
            elsif (WTYPE = 'PUT_LINE' ) then
               utl_file.put_line(log_f, BUFF);
            elsif (WTYPE = 'NEW_LINE') then
               utl_file.new_line(log_f, to_number(BUFF) );
            end if;

     else
            if ( WTYPE = 'PUT' ) then
               utl_file.put_raw(log_f, utl_raw.cast_to_raw(BUFF));
            elsif (WTYPE = 'PUT_LINE' ) then
               utl_file.put_raw(log_f, utl_raw.cast_to_raw(BUFF));
	       utl_file.put_raw(log_f, RAW_TERM);
            elsif (WTYPE = 'NEW_LINE') then
	       for i in 1 .. to_number(BUFF) loop
                 utl_file.put_raw(log_f, RAW_TERM);
               end loop;
            end if;

     end if;

     utl_file.fflush(log_f);

     if WHICH = FND_FILE.LOG then
     	log_simple_msg(fnd_log.level_event, 'write_buff.' || WTYPE, BUFF);
     end if;

   end if;

   exception
      when others then
         raise_application_error(-20100,
				 get_exception(SQLCODE, SQLERRM, 'write_buff', temp_file));

end WRITE_BUFF;


procedure PUT_INTERNAL(WHICH in number,
		       BUFF  in varchar2,
		       FUNC  in varchar2) is

   temp_file     varchar2(255);  -- used for messages
   log_f         utl_file.file_type;
begin

   if WHICH = FND_FILE.LOG then
        temp_file := LOG_FNAME;
	log_f := F_LOG;
   else
        temp_file := OUT_FNAME;
	log_f := F_OUT;
   end if;

   if (UTL_FILE_MODE = 'TRADITIONAL') then
      if FUNC = 'PUT_LINE' then
	 utl_file.put_line(log_f, BUFF);
      else
         utl_file.put(log_f, BUFF);
      end if;
   else
      utl_file.put_raw(log_f, utl_raw.cast_to_raw(BUFF));
      if FUNC = 'PUT_LINE' then
	  utl_file.put_raw(log_f, RAW_TERM);
      end if;
   end if;

   utl_file.fflush(log_f);

   if which = FND_FILE.LOG then
      log_simple_msg(fnd_log.level_event, FUNC, BUFF);
   end if;

exception
      when UTL_FILE.INVALID_FILEHANDLE then
         -- first time this could be file not open case
         -- try opening temp files and write
         WRITE_BUFF(WHICH, FUNC, BUFF);

      when others then
         raise_application_error(-20100,
				 get_exception(SQLCODE, SQLERRM, FUNC, temp_file));

end PUT_INTERNAL;




/* -------------------------------------------------------------------------
   PUBLIC PROCEDURES
   -------------------------------------------------------------------------
*/

 /*
  ** PUT - Put (write) text to file
  **
  ** IN
  **   WHICH - Log or output file?  Either FND_FILE.LOG or FND_FILE.OUTPUT
  **   BUFF - Text to write
  ** EXCEPTIONS
  **   utl_file.invalid_path (*)   - file location or name was invalid
  **   utl_file.invalid_mode (*)   - the open_mode string was invalid
  **   utl_file.invalid_filehandle - file handle is invalid
  **   utl_file.invalid_operation  - file is not open for writing/appending
  **   utl_file.write_error        - OS error occured during write operation
  */
procedure PUT(WHICH in number, BUFF in varchar2) is
   temp_file     varchar2(255);  -- used for messages
   log_f         utl_file.file_type;
begin

   PUT_INTERNAL(WHICH, BUFF, 'PUT');

end PUT;


  /*
  ** PUT_LINE - Put (write) a line of text to file
  **
  ** IN
  **   WHICH - Log or output file?  Either FND_FILE.LOG or FND_FILE.OUTPUT
  **   BUFF - Text to write
  ** EXCEPTIONS
  **   utl_file.invalid_path       - file location or name was invalid
  **   utl_file.invalid_mode       - the open_mode string was invalid
  **   utl_file.invalid_filehandle - file handle is invalid
  **   utl_file.invalid_operation  - file is not open for writing/appending
  **   utl_file.write_error        - OS error occured during write operation
  */
procedure PUT_LINE(WHICH in number, BUFF in varchar2) is
   temp_file     varchar2(255);  -- used for messages
   log_f         utl_file.file_type;
begin

   PUT_INTERNAL(WHICH, BUFF, 'PUT_LINE');

end PUT_LINE;


  /*
  ** NEW_LINE - Put (write) line terminators to file
  **
  ** IN
  **   WHICH - Log or output file?  Either FND_FILE.LOG or FND_FILE.OUTPUT
  **   LINES - Number of line terminators to write
  ** EXCEPTIONS
  **   utl_file.invalid_path       - file location or name was invalid
  **   utl_file.invalid_mode       - the open_mode string was invalid
  **   utl_file.invalid_filehandle - file handle is invalid
  **   utl_file.invalid_operation  - file is not open for writing/appending
  **   utl_file.write_error        - OS error occured during write operation
  */
procedure NEW_LINE(WHICH in number, LINES in natural := 1) is
   temp_file     varchar2(255); -- used for messages
   log_f         utl_file.file_type;
begin

   if WHICH = FND_FILE.LOG then
      temp_file := LOG_FNAME;
      log_f := F_LOG;
   else
      temp_file := OUT_FNAME;
      log_f := F_OUT;
   end if;


   if (UTL_FILE_MODE = 'TRADITIONAL') then
      utl_file.new_line(log_f, LINES);
   else

      for i in 1 .. LINES loop
          utl_file.put_raw(log_f, RAW_TERM);
      end loop;

   end if;

   utl_file.fflush(log_f);

   exception
      when UTL_FILE.INVALID_FILEHANDLE then
         -- first time this could be file not open case
         -- try opening temp files and write
         WRITE_BUFF(WHICH, 'NEW_LINE', to_char(LINES));

      when others then
         raise_application_error(-20100,
				 get_exception(SQLCODE, SQLERRM, 'new_line', temp_file));
end NEW_LINE;


  /*
  ** PUT_NAMES - Set the temp file names and directories
  **		 Has no effect when called from a concurrent program.
  ** IN
  **   P_LOG - Temporary logfile name
  **   P_OUT - Temporary outfile name
  **   P_DIR - Temporary directory name
  **
   */
procedure PUT_NAMES(P_LOG in varchar2, P_OUT in varchar2, P_DIR in varchar2)
is
begin

   if LOG_FNAME is null AND
      OUT_FNAME is null AND
      TEMP_DIR  is null then

      LOG_FNAME := P_LOG;
      OUT_FNAME := P_OUT;
      TEMP_DIR  := P_DIR;

   end if;

end PUT_NAMES;


  /*
  ** PUT_NAMES - Set the temp file names and directories
  **		 Has no effect when called from a concurrent program.
  ** IN
  **   P_LOG - Temporary logfile name
  **   P_OUT - Temporary outfile name
  **   P_DIR - Temporary directory name
  **
   */
procedure RELEASE_NAMES(P_LOG in varchar2, P_OUT in varchar2) is
BASE	varchar2(12);
begin
   BASE := substr(P_LOG, 2, 10);
   insert into fnd_temp_files (filename, type)
     values (BASE, 'P');

end RELEASE_NAMES;


procedure GET_NAMES(P_LOG in out nocopy varchar2,
                    P_OUT in out nocopy varchar2) is
BASE	varchar2(12);
begin

   BASE := GET_BASE;
   P_LOG := 'l' || BASE || '.tmp';
   P_OUT := 'o' || BASE || '.tmp';

end GET_NAMES;


/*
  ** CLOSE   - Close open files.
  **	       Should not be called from a concurrent program.
*/
procedure CLOSE is
  log_recorded boolean := false;
  out_recorded boolean := false;
  file_exists boolean := false;
  file_length number(15) := 0;
  block_size  number(15) := 0;
  temp_utl    varchar2(512) := null;

BEGIN

  BEGIN
     utl_file.fclose(F_LOG);
  EXCEPTION
     when others then
       raise_application_error(-20100,
				 get_exception(SQLCODE, SQLERRM, 'close', LOG_FNAME));
  END;

  BEGIN
     utl_file.fclose(F_OUT);
  EXCEPTION
     when others then
       raise_application_error(-20100,
				 get_exception(SQLCODE, SQLERRM, 'close', OUT_FNAME));
  END;

  if UTL_FILE_DELAY > 0 then
          temp_utl := TEMP_DIR || '/' || LOG_FNAME;
          if (fnd_conc_private_utils.check_temp_file_use(temp_utl,NULL,'F') = 1) then
                log_recorded := TRUE;
          end if;

          if log_recorded then
               log_simple_msg(fnd_log.level_statement, 'close',
                                'temp file: '|| temp_utl ||' recorded');
               fnd_conc_private_utils.erase_temp_file_use(temp_utl,NULL,'F');
          else
               log_simple_msg(fnd_log.level_statement, 'close',
                                'temp file: '|| temp_utl ||' not recorded');
          end if;

          temp_utl := TEMP_DIR || '/' || OUT_FNAME;
          if (fnd_conc_private_utils.check_temp_file_use(temp_utl,NULL,'F') = 1) then
                out_recorded := TRUE;
          end if;
          if out_recorded then
               log_simple_msg(fnd_log.level_statement, 'close',
                                'temp file: '|| temp_utl ||' recorded');
               fnd_conc_private_utils.erase_temp_file_use(temp_utl,NULL,'F');
          else
               log_simple_msg(fnd_log.level_statement, 'close',
                                'temp file: '|| temp_utl ||' not recorded');
          end if;

          if (log_recorded or out_recorded) then
                        dbms_lock.sleep(UTL_FILE_DELAY);
                        begin
                          utl_file.fgetattr(TEMP_DIR, LOG_FNAME, file_exists, file_length, block_size);
                          log_simple_msg(fnd_log.level_statement, 'close',
                                         'utl_file.getattr (after '||to_char(UTL_FILE_DELAY)||' secs) log file: '||LOG_FNAME ||
                                         ' is length: '||file_length||' and block_size: '||block_size);
                        exception
                          when others then
                            raise_application_error(-20100,
                                 get_exception(SQLCODE, SQLERRM, 'close', LOG_FNAME));
                        end;
                        begin
                          utl_file.fgetattr(TEMP_DIR, OUT_FNAME, file_exists, file_length, block_size);
                          log_simple_msg(fnd_log.level_statement,'close',
                                         'utl_file.getattr (after '||to_char(UTL_FILE_DELAY)||' secs) out file: '||OUT_FNAME ||
                                         ' is length: '||file_length||' and block_size: '||block_size);
                        exception
                          when others then
                            raise_application_error(-20100,
                                 get_exception(SQLCODE, SQLERRM, 'close', OUT_FNAME));
                        end;
          end if;
  end if;

  LOG_OPEN := FALSE;
  OUT_OPEN := FALSE;
end;

  /*
  ** IS_OPEN - Returns 1 if file is open, else 0.
  **
   */
function IS_OPEN (WHICH in varchar2) return number is
  isopen number := 0;
BEGIN

   if WHICH = 'LOG' then
     BEGIN
       if (utl_file.is_open(F_LOG)) then
         isopen := 1;
       end if;
     EXCEPTION
       when others then
         raise_application_error(-20100,
                                 get_exception(SQLCODE, SQLERRM, 'is_open', LOG_FNAME));
     END;
   end if;

   if WHICH = 'OUT' then
     BEGIN
       if (utl_file.is_open(F_OUT)) then
         isopen := 1;
       end if;
     EXCEPTION
       when others then
         raise_application_error(-20100,
                                 get_exception(SQLCODE, SQLERRM, 'is_open', OUT_FNAME));
     END;
   end if;

   return isopen;

end;



begin

   -- sets ascii character for the newline.  DO NOT edit the lines below!!
   RAW_TERM:=utl_raw.cast_to_raw('
');
   -- sets ascii character for the newline.  DO NOT edit the lines above!!


   fnd_profile.get('UTL_FILE_MODE', UTL_FILE_MODE);
   if (upper(UTL_FILE_MODE) = 'RAW') then
	UTL_FILE_MODE := 'RAW';
   else
	UTL_FILE_MODE := 'TRADITIONAL';
   end if;

  if FND_PROFILE.defined('CONC_UTL_FILE_DELAY') then
	fnd_profile.get('CONC_UTL_FILE_DELAY', UTL_FILE_DELAY);
  	log_simple_msg(fnd_log.level_statement, 'init', 'UTL_FILE_DELAY ='|| UTL_FILE_DELAY);
  end if;

end fnd_file;

/

  GRANT EXECUTE ON "APPS"."FND_FILE" TO "CS";
  GRANT EXECUTE ON "APPS"."FND_FILE" TO "EM_OAM_MONITOR_ROLE";
