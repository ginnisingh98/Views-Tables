--------------------------------------------------------
--  DDL for Package Body BIS_SAVE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_SAVE_REPORT" AS
/* $Header: BISSAVEB.pls 120.0 2005/06/01 14:43:24 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.12=120.0):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      bis_save_report                                         --
--                                                                        --
--  DESCRIPTION:  use this package to save and retrieve html output       --
--                from fnd_lobs                                           --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  04/10/2001 aleung     Initial creation                                --
--  01/19/2004 nkishore   Save Report to PDF                              --
----------------------------------------------------------------------------

/* New Package for saving and retrieving reports */

function createEntry (file_name    varchar2 default null,
                      content_type varchar2 default 'text/plain',
                      program_name varchar2 default null,
                      program_tag  varchar2 default null) return number is
--pragma autonomous_transaction;

  file_id number;
  file_handler_id integer;

begin
     file_handler_id := fnd_gfm.file_create(file_name, content_type, program_name, program_tag);
     file_id := fnd_gfm.file_close(file_handler_id);
     return file_id;
end createEntry;

procedure initWrite (file_id number, buffer varchar2) is
--pragma autonomous_transaction;
begin
 if lengthb(buffer) > 0 then
  initWrite(file_id, lengthb(buffer), utl_raw.cast_to_raw(buffer));
 end if;
end initWrite;

procedure initWrite (file_id number, amount binary_integer, buffer raw) is
--pragma autonomous_transaction;
  loc blob;
  loc_tmp blob;
  --ocs varchar2(30);
  offset integer := 1;
  length number;
begin

  select file_data
  into   loc
  from   fnd_lobs
  where  file_id = initWrite.file_id
  for update of file_data;

  length := dbms_lob.getLength(loc);
  if length > 0 then
    dbms_lob.trim(loc, offset);
  end if;
  --dbms_lob.write(loc, amount, offset, convert(buffer,ocs));
  dbms_lob.write(loc, amount, offset, buffer);
  commit;
end initWrite;

procedure appendWrite (file_id number, buffer varchar2) is
--pragma autonomous_transaction;
begin
 if lengthb(buffer) > 0 then
  appendWrite(file_id, lengthb(buffer), utl_raw.cast_to_raw(buffer));
 end if;
end appendWrite;

procedure appendWrite (file_id number, amount binary_integer, buffer raw) is
--pragma autonomous_transaction;
  loc blob;
  --ocs varchar2(30);
begin
  select file_data
  into   loc
  from   fnd_lobs
  where  file_id = appendWrite.file_id
  for update of file_data;

  --dbms_lob.writeappend(loc, amount, convert(buffer,ocs));
 -- Fix for bug 3336412
 if lengthb(buffer) > 0 then
  dbms_lob.writeappend(loc, amount, buffer);
  commit;
 end if ;
end appendWrite;

procedure appendLineBreak (file_id number) is
begin
  appendWrite(file_id, 2, hextoraw('0D0A'));
end appendLineBreak;

procedure appendWriteLine (file_id number, buffer varchar2) is
--pragma autonomous_transaction;
begin
 if lengthb(buffer) > 0 then
  appendWriteLine(file_id, lengthb(buffer), utl_raw.cast_to_raw(buffer));
 end if;
end appendWriteLine;

procedure appendWriteLine (file_id number, amount binary_integer, buffer raw) is
--pragma autonomous_transaction;
begin
  appendWrite(file_id, amount, buffer);
  appendLineBreak(file_id);
end appendWriteLine;

procedure retrieve (file_id number) is
--pragma autonomous_transaction;
begin
    if not icx_sec.ValidateSession then
      return;
    end if;
  fnd_gfm.download_blob(file_id);
end retrieve;

procedure retrieve_for_php(file_id varchar2) is
 l_file_id varchar2(100);
begin
  /*gsanap 04/16/04 - Bug Fix 3568859 retrieve_for_php to remove mod_plsql*/
  l_file_id := icx_call.decrypt(file_id);
  fnd_gfm.download_blob(l_file_id);
end retrieve_for_php;

function returnURL(file_id in number) return varchar2 is
   l_url varchar2(1000);
   --fid number;
begin
   --fid := icx_call.encrypt2(file_id);
   l_url := fnd_Web_config.trail_slash(fnd_web_Config.gfm_Agent);
   l_url := replace(l_url,'HTTPS://', 'HTTP://');
   l_url := replace(l_url,'https://', 'http://');
   l_url := replace(l_url,'Https://', 'Http://');
   l_url := l_url|| 'bis_save_report.retrieve_for_php?file_id='||file_id;
   return l_url;
end returnURL;

-- mdamle 07/15/2002 - Set the Expiration date for live portlet graph file at creation time
-- itself since we don't keep track of it in our tables.
procedure setExpirationDate(
         p_file_id  in varchar2
) IS
BEGIN
       -- Expire after n days.
       IF (p_file_id IS NOT NULL) THEN
            update fnd_lobs
            SET expiration_date = SYSDATE + 90
            WHERE file_id = p_file_id;

            COMMIT;
       END IF;
END setExpirationDate;

--Save Report to PDF
procedure retrieve_for_pdf(p_file_id  in varchar2) is
 l_file_id varchar2(100);
begin
  l_file_id := icx_call.decrypt(p_file_id);
  fnd_gfm.download_blob(l_file_id);
end retrieve_for_pdf;

end bis_save_report;

/
