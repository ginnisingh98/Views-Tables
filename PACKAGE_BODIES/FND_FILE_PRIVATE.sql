--------------------------------------------------------
--  DDL for Package Body FND_FILE_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FILE_PRIVATE" as
/* $Header: AFCPPPRB.pls 120.2.12010000.2 2012/07/09 18:25:09 tkamiya ship $ */


LOG		utl_file.file_type;
OUT		utl_file.file_type;

BUFFER_SIZE	constant number := 32500;

LOG_FNAME	varchar2(255);
OUT_FNAME	varchar2(255);
TEMP_DIR	varchar2(255);

NEXT_LOG_LINE	varchar2(32767);
NEXT_OUT_LINE	varchar2(32767);

procedure log_simple_msg (level in number, fn in varchar2, msg in varchar2) is
BEGIN
    if (level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(level,'fnd.plsql.fnd_file_private.'||fn, 'sid:'||userenv('SESSIONID')||': '||msg);
    end if;
end;


procedure PUT_NAMES(P_LOG in varchar2, P_OUT in varchar2, P_DIR in varchar2)
is
begin
	LOG_FNAME := P_LOG;
	OUT_FNAME := P_OUT;
	TEMP_DIR  := P_DIR;
end;


function OPEN_FILE(TYPE in varchar2) return boolean is
  MAX_LINESIZE binary_integer := 32767;
  UTL_FILE_REOPEN_DELAY number := 0;
begin

/* bug12954046                                         */
/* implement a delay before open operation takes place */
/*                                                     */
   if FND_PROFILE.defined('CONC_UTL_FILE_REOPEN_DELAY') then
      fnd_profile.get('CONC_UTL_FILE_REOPEN_DELAY', UTL_FILE_REOPEN_DELAY);
      log_simple_msg(fnd_log.level_statement, 'init', 'UTL_FILE_REOPEN_DELAY ='|| UTL_FILE_REOPEN_DELAY);
   end if;

   if ((UTL_FILE_REOPEN_DELAY IS NOT NULL) and (UTL_FILE_REOPEN_DELAY > 0)) then
      dbms_lock.sleep(UTL_FILE_REOPEN_DELAY);
   end if;

	if TYPE = 'OUT' and
	   OUT_FNAME is not null and
	   TEMP_DIR  is not null then
		OUT := utl_file.fopen(TEMP_DIR, OUT_FNAME, 'r', MAX_LINESIZE);
		return TRUE;
	elsif TYPE = 'LOG' and
	      LOG_FNAME is not null and
	      TEMP_DIR  is not null then
		LOG := utl_file.fopen(TEMP_DIR, LOG_FNAME, 'r', MAX_LINESIZE);
		return TRUE;
	else
		return FALSE;
	end if;

	exception

	when OTHERS then
		return FALSE;

end OPEN_FILE;

procedure OPEN(LOGFILE in out NOCOPY varchar2,
		OUTFILE in out NOCOPY varchar2) is
begin

	OUTFILE := 'F';
	LOGFILE := 'F';

	NEXT_OUT_LINE := '';
	NEXT_LOG_LINE := '';

	if OPEN_FILE('LOG') = TRUE then
		LOGFILE := 'T';
	end if;

	if OPEN_FILE('OUT') = TRUE then
		OUTFILE := 'T';
	end if;

end OPEN;

procedure LOGFILE_GET(STATUS in out NOCOPY varchar2,
			TEXT in out NOCOPY varchar2) is
CR	varchar2(2);
begin

	CR := '
';
	TEXT := '';
	while nvl(lengthb(TEXT), 0) + nvl(lengthb(NEXT_LOG_LINE), 0) < BUFFER_SIZE loop
		TEXT := concat(TEXT, NEXT_LOG_LINE);
		NEXT_LOG_LINE := '';
		utl_file.get_line(LOG, NEXT_LOG_LINE);
		NEXT_LOG_LINE := concat(NEXT_LOG_LINE, CR);
	end loop;

	STATUS := 'OK';

	exception
	when NO_DATA_FOUND then
		if nvl(length(TEXT), 0) > 0 then
			STATUS := 'OK';
			return;
		else
			STATUS := 'EOF';
			return;
		end if;

	when UTL_FILE.INVALID_FILEHANDLE then
		fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_HANDLE');
		fnd_message.set_token('TEMP_FILE', LOG_FNAME, FALSE);
	       	raise_application_error(-20104, fnd_message.get);

	when UTL_FILE.INVALID_OPERATION then
		fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_OPERATN');
		fnd_message.set_token('TEMP_FILE', LOG_FNAME, FALSE);
       		raise_application_error(-20105, fnd_message.get);

	when UTL_FILE.READ_ERROR then
		fnd_message.set_name('FND', 'CONC-TEMPFILE_READ_ERROR');
		fnd_message.set_token('TEMP_FILE', LOG_FNAME, FALSE);
		raise_application_error(-20106, fnd_message.get);


	when OTHERS then
		raise;

end LOGFILE_GET;

procedure OUTFILE_GET(STATUS in out NOCOPY varchar2,
			TEXT in out NOCOPY varchar2) is
CR	varchar2(2);
begin
	CR := '
';
	TEXT := '';
	while nvl(lengthb(TEXT), 0) + nvl(lengthb(NEXT_OUT_LINE), 0) < BUFFER_SIZE loop
		TEXT := concat(TEXT, NEXT_OUT_LINE);
		NEXT_OUT_LINE := '';
		utl_file.get_line(OUT, NEXT_OUT_LINE);
		NEXT_OUT_LINE := concat(NEXT_OUT_LINE, CR);
	end loop;

	STATUS := 'OK';
	exception
	when NO_DATA_FOUND then
		if nvl(length(TEXT), 0) > 0 then
			STATUS := 'OK';
			return;
		else
			STATUS := 'EOF';
			return;
		end if;

	when UTL_FILE.INVALID_FILEHANDLE then
		fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_HANDLE');
		fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
	       	raise_application_error(-20104, fnd_message.get);

	when UTL_FILE.INVALID_OPERATION then
		fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_OPERATN');
		fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
       		raise_application_error(-20105, fnd_message.get);

	when UTL_FILE.READ_ERROR then
		fnd_message.set_name('FND', 'CONC-TEMPFILE_READ_ERROR');
		fnd_message.set_token('TEMP_FILE', OUT_FNAME, FALSE);
		raise_application_error(-20106, fnd_message.get);

	when OTHERS then
		raise;

end OUTFILE_GET;

  /*
  ** CLOSE_FILE - close an open file and make it 0-length
  **		  unfortunately, we can't delete files on the server
  **		  deleting will have to be done with a cron job or something
  **
  ** IN
  **   filetype - file to close log/out
  ** RETURN
  **   BOOLEAN - was file closed successfully ?
  ** EXCEPTIONS
  **   invalid_filehandle - not a valid file handle
  **   write_error        - OS error occured during write operation
  */

  function CLOSE_FILE(filetype in varchar2) return boolean is

  begin

     if (filetype = 'LOG') then
	if (utl_file.is_open(LOG)) then
	    utl_file.fclose(LOG);
	    LOG := utl_file.fopen(TEMP_DIR, LOG_FNAME, 'w');
	    utl_file.fclose(LOG);
	end if;
     end if;

     if (filetype = 'OUT') then
	if (utl_file.is_open(OUT)) then
	    utl_file.fclose(OUT);
	    OUT := utl_file.fopen(TEMP_DIR, OUT_FNAME, 'w');
	    utl_file.fclose(OUT);
	end if;
     end if;

     return TRUE;

     exception
        when UTL_FILE.INVALID_PATH then
		fnd_message.set_name('FND', 'CONC-TEMPFILE_INVALID_PATH');
		fnd_message.set_token('FILE_DIR', TEMP_DIR, FALSE);
       		raise_application_error(-20101, fnd_message.get);

	when OTHERS then
		raise;

     		return  FALSE;

  end CLOSE_FILE;

procedure CLOSE is
success	boolean;
begin
	begin
		success := CLOSE_FILE('LOG');
		exception
			when OTHERS then
			null;
	end;
	begin
		success := CLOSE_FILE('OUT');
		exception
			when OTHERS then
			null;
	end;

end CLOSE;

end FND_FILE_PRIVATE;

/
