--------------------------------------------------------
--  DDL for Package Body WF_RENDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_RENDER" as
/* $Header: wfrenb.pls 115.3 2004/01/30 08:03:19 vshanmug noship $ */

-- Bug 2580807 Moved Render from Wf_Event to here and rename it to
-- xml_style_sheet
-- Original Bug 2376197
/*
** DefaultRender (PRIVATE)
** Replaces < and > symbols within a XML document with lt; and gt; to be
** displayed within html pages.
*/
PROCEDURE DefaultRender(l_data  in out nocopy clob)
is
  l_amp     varchar2(1) := '&';
  l_lt      varchar2(1) := '<';
  l_gt      varchar2(1) := '>';
  tmp       clob;
  buf       varchar2(32767);
  amt       number;
  chunksize number := 16000;
  offset    number := 1;

begin
  amt := DBMS_LOB.GetLength(l_data);
  DBMS_LOB.CreateTemporary(tmp, TRUE, DBMS_LOB.session);
  -- display XML content in a pre formatted way if the
  dbms_lob.writeappend(tmp, 5, '<PRE>');
  loop
    if amt > chunksize then
      dbms_lob.read(l_data, chunksize, offset, buf);
      buf := replace(buf, l_amp, l_amp||'amp;');
      buf := replace(buf, l_gt, l_amp||'gt;');
      buf := replace(buf, l_lt, l_amp||'lt;');
      dbms_lob.WriteAppend(tmp, length(buf), buf);
      amt := amt - chunksize;
      offset := offset + chunksize;
    else
      dbms_lob.read(l_data, amt, offset, buf);
      buf := replace(buf, l_amp, l_amp||'amp;');
      buf := replace(buf, l_gt, l_amp||'gt;');
      buf := replace(buf, l_lt, l_amp||'lt;');
      dbms_lob.WriteAppend(tmp, length(buf), buf);
      exit;
    end if;
  end loop;
  dbms_lob.writeappend(tmp, 6, '</PRE>');

  amt := dbms_lob.GetLength(tmp);
  dbms_lob.copy(l_data, tmp, amt, 1, 1);

exception
  when others then
    -- don't do anything, give back what you have processed
    null;
end DefaultRender;
---------------------------------------------------------------------------
/*
** Standard PLSQLCLOB API to render the CLOB event data of an event in a
** notification message.
*/
PROCEDURE XML_Style_Sheet (document_id   in     varchar2,
                  display_type  in     varchar2,
                  document      in out nocopy clob,
                  document_type in out nocopy varchar2)
is
  l_sig_text    varchar2(1);
  l_event       wf_event_t;
  l_attr        varchar2(100);
  l_evt_attr    varchar2(30);
  l_nid         number;
  l_txslt_name  varchar2(256);
  l_hxslt_name  varchar2(256);
  l_txslt_ver   varchar2(20);
  l_hxslt_ver   varchar2(20);
  l_tapp_code   varchar2(256);
  l_happ_code   varchar2(256);
  l_retcode     pls_integer;
  l_retmsg      varchar2(2000);
  slash         number;
  next_slash    number;
  l_parser      xmlparser.parser;
  l_amount      number;
  l_data        clob;
  l_temp        clob;
begin
  -- parser instance to parse XML CLOB document
  l_parser := xmlParser.NewParser;

  -- parse document id to get the parameters
  slash := instr(document_id, '/', 1);
  l_attr := substr(document_id, 1, slash-1);
  next_slash := instr(document_id, '/', slash+1);
  l_txslt_name := substr(document_id, slash+1, next_slash-slash-1);
  slash := next_slash;
  next_slash := instr(document_id, '/', slash+1);
  l_txslt_ver := substr(document_id, slash+1, next_slash-slash-1);
  slash := next_slash;
  next_slash := instr(document_id, '/', slash+1);
  l_tapp_code := substr(document_id, slash+1, next_slash-slash-1);
  slash := next_slash;
  next_slash := instr(document_id, '/', slash+1);
  l_hxslt_name := substr(document_id, slash+1, next_slash-slash-1);
  slash := next_slash;
  next_slash := instr(document_id, '/', slash+1);
  l_hxslt_ver := substr(document_id, slash+1, next_slash-slash-1);
  slash := next_slash;
  l_happ_code := substr(document_id, slash+1);

  -- parse for event attribute name and notification id from the
  -- first parameter
  l_evt_attr := substr(l_attr, 1, instr(document_id, ':', 1)-1);
  l_nid := to_number(substr(l_attr, instr(document_id, ':', 1)+1));

  -- get profile value for WF_SIG_TEXT_ONLY
  l_sig_text := fnd_profile.value('WF_SIG_TEXT_ONLY');

  -- get the event from wf_notification_attributes
  dbms_lob.createtemporary(l_data, TRUE, DBMS_LOB.Session);
  l_event := Wf_Notification_Util.GetAttrEvent(l_nid, l_evt_attr);
  l_temp := l_event.GetEventData();
  l_amount := dbms_lob.getLength(l_temp);
  dbms_lob.copy(l_data, l_temp, l_amount, 1, 1);

  -- if no XML document do nothing
  if (l_data is NULL) then
     return;
  end if;

  -- for text only profile
  if (l_sig_text = 'Y') then
     if (l_txslt_name is NULL) then
        -- render XML content without transformation
        wf_core.raise('WFE_DEFAULT_RENDER');
     end if;
     ecx_standard.perform_xslt_transformation
                       (I_XML_FILE       => l_data,
                        I_XSLT_FILE_NAME => l_txslt_name,
                        I_XSLT_FILE_VER  => l_txslt_ver,
                        I_XSLT_APPLICATION_CODE => l_tapp_code,
                        I_RETCODE        => l_retcode,
                        I_RETMSG         => l_retmsg);
     if (l_retcode > 0) then
        -- render XML content without transformation
        wf_core.raise('WFE_DEFAULT_RENDER');
     end if;
     dbms_lob.append(document, l_data);
     return;
  end if;
  if (display_type = WF_NOTIFICATION.doc_text) then
     if (l_txslt_name is NULL) then
        if (l_hxslt_name is NULL) then
           -- render XML content without transformation
           wf_core.raise('WFE_DEFAULT_RENDER');
        else
           -- use html stylesheet if no text style sheet available
           l_txslt_name := l_hxslt_name;
           l_txslt_ver := l_hxslt_ver;
           l_tapp_code := l_happ_code;
        end if;
     end if;
     -- apply style sheet
     ecx_standard.perform_xslt_transformation
                       (I_XML_FILE       => l_data,
                        I_XSLT_FILE_NAME => l_txslt_name,
                        I_XSLT_FILE_VER  => l_txslt_ver,
                        I_XSLT_APPLICATION_CODE => l_tapp_code,
                        I_RETCODE        => l_retcode,
                        I_RETMSG         => l_retmsg);
     if (l_retcode > 0) then
        -- render XML content without transformation
        wf_core.raise('WFE_DEFAULT_RENDER');
     end if;
     dbms_lob.append(document, l_data);
     return;
  end if;

  if (display_type = WF_NOTIFICATION.doc_html) then
     if (l_hxslt_name is NULL) then
        if( l_txslt_name is NULL) then
           -- render XML content without transformation
           wf_core.raise('WFE_DEFAULT_RENDER');
        else
           -- use text stylesheet if no html style sheet available
           l_hxslt_name := l_txslt_name;
           l_hxslt_ver := l_txslt_ver;
           l_happ_code := l_tapp_code;
        end if;
     end if;
     -- apply style sheet
     ecx_standard.perform_xslt_transformation
                       (I_XML_FILE       => l_data,
                        I_XSLT_FILE_NAME => l_hxslt_name,
                        I_XSLT_FILE_VER  => l_hxslt_ver,
                        I_XSLT_APPLICATION_CODE => l_happ_code,
                        I_RETCODE        => l_retcode,
                        I_RETMSG         => l_retmsg);
     if (l_retcode > 0) then
        -- render XML content without transformation
        wf_core.raise('WFE_DEFAULT_RENDER');
     end if;
     dbms_lob.append(document, l_data);
     return;
  end if;
exception
  when others then
     -- parse the XML and display the content after replaing < and > with
     -- appropriate references
     if (l_data IS NOT NULL) then
        xmlparser.parseClob(l_parser, l_data);
        if (display_type = Wf_Notification.doc_html) then
           DefaultRender(l_data);
        end if;
        dbms_lob.append(document, l_data);
     end if;
end XML_Style_Sheet;
---------------------------------------------------------------------------
end WF_RENDER;

/
