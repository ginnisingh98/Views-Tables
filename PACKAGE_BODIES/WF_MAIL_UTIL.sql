--------------------------------------------------------
--  DDL for Package Body WF_MAIL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_MAIL_UTIL" as
/* $Header: wfmlutb.pls 120.5.12010000.2 2011/10/31 09:47:03 skandepu ship $ */

TYPE MIME_SUBTYPE_EXT_MAP_T is table of varchar2(8) index by varchar2(255);
g_mime_subtype_ext_mappings MIME_SUBTYPE_EXT_MAP_T ;

-- EncodeBLOB
--   Receives a BLOB input and encodes it to Base64 CLOB
-- IN
--   BLOB data
-- OUT
--   CLOB data

procedure EncodeBLOB(pIDoc  in     blob,
                     pODoc  in out nocopy clob)
is
   rawData raw(32767);
   chunksize integer;
   amount binary_integer := 32767;
   position integer := 1;
   base64raw RAW(32767);
   chunkcount binary_integer := 0;
   cBuffer varchar2(32000);
begin
   chunksize := 12288;
   amount := dbms_lob.getLength(pIDoc);
   if(chunksize < amount) then
      chunkcount := round((amount / chunksize)+0.5);
   else
      chunkCount := 1;
   end if;

   for i in 1..chunkcount loop
      dbms_lob.read(pIDoc, chunksize, position, rawData);
      base64raw := utl_encode.base64_encode(rawData);
      cBuffer := utl_raw.cast_to_varchar2(base64Raw);
      dbms_lob.writeAppend(pODoc, length(cBuffer), cBuffer);
      position := position + chunksize;
   end loop;
   dbms_lob.WriteAppend(pODoc, 1, wf_core.newline);

exception
   when others then
      wf_core.context('WF_MAIL_UTIL', 'EncodeBLOB');
      raise;
end EncodeBLOB;

-- DecodeBLOB
--   Receives a CLOB input and decodes it from Base64 to BLOB
-- IN
--   CLOB data
-- OUT
--   BLOB data
procedure DecodeBLOB(pIDoc  in     clob,
                     pODoc  in out nocopy blob)
is
   rawData raw(32767);
   chunksize integer;
   amount binary_integer := 32767;
   position number := 1;
   base64raw RAW(32767);
   chunkcount binary_integer := 0;
   cBuffer varchar2(32000);
   bufsize number;
begin
   amount := dbms_lob.getLength(pIDoc);
   chunksize := 16896; -- Do not change
   if(chunksize < amount) then
      chunkcount := round((amount / chunksize)+0.5);
   else
      chunkCount := 1;
   end if;

   dbms_lob.trim(pODoc, 0);
   for i in 1..chunkcount loop
      dbms_lob.read(pIDoc, chunksize, position, cBuffer);
      base64raw := utl_raw.cast_to_raw(cBuffer);
      rawData := utl_encode.base64_decode(base64Raw);
      bufsize := utl_raw.length(rawData);
      dbms_lob.writeAppend(pODoc, bufsize, rawData);
      position := position + chunksize;
   end loop;

exception
   when others then
      wf_core.context('WF_MAIL_UTIL','DecodeBLOB');
      raise;
end DecodeBLOB;

-- getTimezone (PRIVATE)
--   Gets the server timezone message
-- IN
--   contentType - Document Type in varchar2
-- RETURN
--   timezone - Formatted timezone message in varchar2
function getTimezone(contentType in varchar2) return varchar2
is
   timezone varchar2(240);

begin
   if  g_install='EMBEDDED' AND
       FND_TIMEZONES.timezones_enabled = 'Y' then

       -- bug 5043031: When Mailer sends notifications to users
       -- with different lang preferences one after the other;
       -- user some times gets time zone in different langauge rather than user's prefered language.
       --
       g_timezoneName := FND_TIMEZONES.GET_NAME(FND_TIMEZONES.GET_SERVER_TIMEZONE_CODE);
       g_gmt_offset := getGMTDeviation(g_timezoneName);

       if length(g_gmt_offset) > 0 then
         if contentType = g_ntfDocText then
            wf_core.token('TIMEZONE', g_gmt_offset);
            timezone := wf_core.Substitute('WFTKN','WFNTF_TIMEZONE');
         else
            wf_core.token('TIMEZONE', '<SPAN style="font-weight:bold">'||
                          g_gmt_offset||'</SPAN>');
            timezone := wf_core.Substitute('WFTKN','WFNTF_TIMEZONE');
         end if;
      else
         timezone := '';
      end if;
   else
      timezone := '';
   end if;

   return timezone;

end getTimezone;

-- getGMTDeviation (PRIVATE)
--    Function to get the gmtDeviation in String time format, for example,
--  Pacific Time with 8 GMT offset would be displayed as '(GMT -8:00/-7:00)
--  Pacific Time' or '(GMT -8:00) Pacific Time' depending on whether the
--  day light savings is enabled or not.
-- IN
--   pName - Timezone name
-- RETURN
--   l_GMT_deviation - GMT deviation in varchar2 format
function getGMTDeviation(pName in varchar2) return varchar2
is
   l_gmt_offset    number;
   l_name          varchar2(80);
   l_offset_str1   varchar2(100);
   l_offset_str2   varchar2(100);
   l_daylight_flag varchar2(1);
   l_gmt_deviation varchar2(240);

begin

   SELECT name, gmt_offset, daylight_savings_flag
   INTO   l_name, l_gmt_offset, l_daylight_flag
   FROM   FND_TIMEZONES_VL t
   WHERE  t.enabled_flag = 'Y'
   AND    t.name=pName;

   l_offset_str1 := to_char(trunc(l_gmt_offset),'S09') || ':'
                    || to_char(abs(l_gmt_offset - trunc(l_gmt_offset))*60,'FM900');

   if(l_daylight_flag = 'Y') then
      l_gmt_offset := l_gmt_offset + 1;
      l_offset_str2 := to_char(trunc(l_gmt_offset),'S09') || ':'
                       || to_char(abs(l_gmt_offset - trunc(l_gmt_offset))*60,'FM900');
      l_gmt_deviation := '(GMT '
                         || trim(l_offset_str1) || '/'
                         || trim(l_offset_str2) || ') '
                         || l_name;
   else
      l_gmt_deviation := '(GMT '
                         || trim(l_offset_str1) || ') '
                         || l_name;
   end if;

   return l_gmt_deviation;
end getGMTDeviation;

-- StrParser
--   Parse a string and seperate the elements into a memeory table based on the
--   content of the seperators.
-- IN
--    str - The Varchar2 that is to be parsed
--    sep - The list of SINGLE character seprators that will
--          segment the str.
-- RETURN
--    parserStack_t a memory table of Varchar2
--
function strParser(str in varchar2, sep in varchar2) return parserStack_t
is
  quot pls_integer;
  i pls_integer;
  c varchar2(4);
  attr varchar2(2000);
  defv varchar2(2000);
  stack parserStack_t;
  buf varchar2(2000);

begin
  if str is not null or str <> '' then
    quot := 1;
    i := 1;
    buf := '';
    while i <= length(str) loop
      -- Bug 12793695: Retrieving the portion of string based on characters
      c := substr(str, i, 1);
      if instr(sep, c,1 ,1)>0 then
        if buf is not null or buf <> '' then
          -- Push the buffer to the stack and start again
          stack(quot) := trim(buf);
          quot := quot + 1;
          buf := '';
        end if;
      elsif c = '\' then
        -- Escape character. Consume this and the next character.
        i := i + 1;
        c := substr(str, i, 1);
        buf := buf ||c;
      else
        buf := buf || c;
      end if;
      i := i + 1;
    end loop;
    if buf is not null or buf <> '' then
       stack(quot) := trim(buf);
    end if;
  end if;
  return stack;
end strParser;

-- ParseContentType
--   Parses document type returned by the PLSQL/PLSQLCLOB/PLSQLBLOB document
--   APIs and returns the parameters
-- IN
--   pContentType - Document Type
-- OUT
--   pMimeType - Content Type of the document
--   pFileName - File Name
--   pExtn     - File Extension
--   pEncoding - Content Encoding
procedure parseContentType(pContentType in varchar2,
                           pMimeType    out nocopy varchar2,
                           pFileName    out nocopy varchar2,
                           pExtn        out nocopy varchar2,
                           pEncoding    out nocopy varchar2)
is
  i pls_integer;
  l_content_type varchar2(255);
  l_paramlist parserStack_t;
  l_sublist parserStack_t;

begin
  -- Derive the name for the attachment.
  l_content_type := pContentType;
  pExtn := '';
  pFilename := '';
  pMimeType := '';
  pEncoding := '';
  l_paramlist := strParser(l_content_type, ';');
  if (l_paramlist is null) then
    return;
  end if;
  pMimeType := l_paramlist(1);
  for i in 1..l_paramlist.COUNT loop
    l_sublist := strParser(l_paramlist(i),'/');
    if l_sublist.COUNT = 2 then
      pExtn := l_sublist(2);
    end if;
    l_sublist.DELETE;
    l_sublist := strParser(l_paramList(i),'="');
    for i in 1..l_sublist.COUNT loop
      if lower(l_sublist(i)) = 'name' then
        pFilename := l_sublist(i+1);
      end if;
      if lower(l_sublist(i)) = 'encoding' then
        pEncoding := l_sublist(i+1);
      end if;
    end loop;
    l_sublist.DELETE;
  end loop;

  -- Bug 9113411: Get the File extension for the given subtype from the nested table
  -- if exists, else subtype will be used as the File extension

  if(g_mime_subtype_ext_mappings.exists(lower(pExtn))) then
     pExtn := g_mime_subtype_ext_mappings(lower(pExtn));
  elsif lower(pExtn) like '%excel' then
     pExtn := 'xls';
  elsif lower(pExtn) like '%msword' then
     pExtn := 'doc';
  end if;

end parseContentType;

BEGIN
   -- GLOBAL Package level variables that contain static data.
   g_install := wf_core.translate('WF_INSTALL');
   g_timezoneName := '';
   g_gmt_offset := '';
   g_ntfDocText := wf_notification.doc_text;

   -- Bug 9113411: Store all the MIME subtypes and corresponding File Extensions
   -- into nested table whose File extension value is different from the subtype value

   g_mime_subtype_ext_mappings('tab-separated-values') := 'tsv';
   g_mime_subtype_ext_mappings('comma-separated-values') := 'csv';
   g_mime_subtype_ext_mappings('plain') := 'txt';
   g_mime_subtype_ext_mappings('html') := 'htm';
   g_mime_subtype_ext_mappings('richtext') := 'rtf';

   g_mime_subtype_ext_mappings('msword') := 'doc';
   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.wordprocessingml.document') := 'docx';
   g_mime_subtype_ext_mappings('vnd.ms-word.document.macroEnabled.12') := 'docm';
   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.wordprocessingml.template') := 'dotx';
   g_mime_subtype_ext_mappings('vnd.ms-word.template.macroEnabled.12') := 'dotm';

   g_mime_subtype_ext_mappings('vnd.ms-excel') := 'xls';
   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.spreadsheetml.sheet') := 'xlsx';
   g_mime_subtype_ext_mappings('vnd.ms-excel.sheet.macroEnabled.12') := 'xlsm';
   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.spreadsheetml.template') := 'xltx';
   g_mime_subtype_ext_mappings('vnd.ms-excel.template.macroEnabled.12') := 'xltm';
   g_mime_subtype_ext_mappings('vnd.ms-excel.sheet.binary.macroEnabled.12') := 'xlsb';
   g_mime_subtype_ext_mappings('vnd.ms-excel.addin.macroEnabled.12') := 'xlam';

   g_mime_subtype_ext_mappings('vnd.ms-powerpoint') := 'ppt';
   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.presentationml.presentation') := 'pptx';
   g_mime_subtype_ext_mappings('vnd.ms-powerpoint.presentation.macroEnabled.12') := 'pptm';
   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.presentationml.slideshow') := 'ppsx';
   g_mime_subtype_ext_mappings('vnd.ms-powerpoint.slideshow.macroEnabled.12') := 'ppsm';
   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.presentationml.template') := 'potx';
   g_mime_subtype_ext_mappings('vnd.ms-powerpoint.template.macroEnabled.12') :='potm';
   g_mime_subtype_ext_mappings('vnd.ms-powerpoint.addin.macroEnabled.12') :='ppam';

   g_mime_subtype_ext_mappings('vnd.openxmlformats-officedocument.presentationml.slide') := 'sldx';
   g_mime_subtype_ext_mappings('vnd.ms-powerpoint.slide.macroEnabled.12') := 'sldm';


end WF_MAIL_UTIL;

/
