--------------------------------------------------------
--  DDL for Package Body POA_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_LOG" AS
/* $Header: POALOGB.pls 115.6 2003/12/29 13:50:05 sriswami ship $  */


-- ------------------------------------------------------------------
-- Name: put_names
-- Desc: Setup which directory to put the log and what the log file
--       name is.  The directory setup is used only if the program
--       is not run thru concurrent manager
-- -----------------------------------------------------------------
PROCEDURE put_names(
	p_log_file		VARCHAR2,
	p_out_file		VARCHAR2,
	p_directory		VARCHAR2) IS
BEGIN
/*
     FND_FILE.PUT_NAMES(p_log_file,p_out_file,p_directory);
*/
return;
END put_names;


-- ------------------------------------------------------------------
-- Name: print_duration
-- Desc: Given a duration in days, it return the dates in
--       a more readable format: x days HH:MM:SS
-- -----------------------------------------------------------------
FUNCTION duration(
	p_duration		number) return VARCHAR2 IS
BEGIN
   return(to_char(floor(p_duration)) ||' Days '||
        to_char(mod(floor(p_duration*24), 24))||':'||
        to_char(mod(floor(p_duration*24*60), 60))||':'||
        to_char(mod(floor(p_duration*24*60*60), 60)));
END duration;


-- ------------------------------------------------------------------
-- Name: debug_line
-- Desc: If debug flag is turned on, the log will be printed
-- -----------------------------------------------------------------
PROCEDURE debug_line(
                p_text			VARCHAR2) IS
BEGIN
  IF (g_debug) THEN
    put_line(p_text);
  END IF;
END debug_line;


-- ------------------------------------------------------------------
-- Name: put_line
-- Desc: For now, just a wrapper on top of fnd_file
-- -----------------------------------------------------------------
PROCEDURE put_line(
                p_text			VARCHAR2) IS
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG, p_text);
END put_line;

-- ------------------------------------------------------------------
-- Name: output_line
-- Desc: For now, just a wrapper on top of fnd_file
PROCEDURE output_line(
                p_text                  VARCHAR2) IS
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, p_text);
END output_line;



PROCEDURE setup(
                filename                 VARCHAR2) IS
BEGIN

   IF (fnd_profile.value('POA_DEBUG') = 'Y') THEN
     poa_log.g_debug := TRUE;
   END IF;

   poa_log.put_names(filename ||'.log',filename||'.out',
      		     '/sqlcom/log');
   poa_log.put_line('System time at the start of the process is: ' ||
		    fnd_date.date_to_charDT(sysdate));
   poa_log.put_line( ' ');

END setup;

PROCEDURE wrapup(
                 status                 VARCHAR2) IS

BEGIN
   IF (status = 'SUCCESS') THEN
     poa_log.put_line('Process completed at: ' ||
		      fnd_date.date_to_charDT(sysdate));
   ELSIF (status = 'ERROR') THEN
     poa_log.put_line('Process terminated with error at: ' ||
		      fnd_date.date_to_charDT(sysdate));
   END IF;

   poa_log.put_line(' ');
END wrapup;

end POA_LOG;

/
